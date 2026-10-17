///|
/// 默认超时 30s：官方件 0.22.4 没有 per-request timeout，`default_client()` 形状的客户端
/// 会在挂死端点上永远等下去——存储线真腿实测一条挂死请求把整轮测试一起带走。
/// 挂死比失败更糟，所以适配层在此设界，调用方可用 `timeout~` 改。
let default_timeout_ms : Int32 = 30000

///|
/// 唯一的具体实现：官方 `moonbitlang/async/http` 之上的薄适配（超时是这层自己 bounds 的）。
///
/// 连接策略（issue #5 落地）：默认按 origin 复用——官方 `Client` 与单一 authority 绑定，
/// 但**不是**一次一条请求状态机：应答体读尽（或 `skip_response_body`）后即可发下一条
/// （官方 `skip_response_body` 文档原话 "so that the next request can be made"；本文件
/// 初版"一次只走一条请求状态机"的判读与官方文档冲突，0.1.5 起更正）。复用判据三条红线
/// 见 `docs/spec/26-http.md` §4：只有读尽的线回池；Timeout/Network 后的线绝不回池；
/// `Connection: close` 与无帧（关线定界）应答不回池。`pool~ = false` 完全退回
/// "每 send 新建" 的旧形状。官方 `Client::Client` 构造期即建连，池省掉的正是每请求一次
/// TCP + TLS 握手（下游 Kodo 腿的重试抖动实测由它来）。
pub struct AsyncHttpTransport {
  priv timeout_ms : Int32
  priv pool : Pool[@ahttp.Client]?
}

///|
pub fn AsyncHttpTransport::new(
  timeout~ : Int32 = default_timeout_ms,
  pool~ : Bool = true,
  max_idle_per_origin~ : Int32 = 4,
  idle_ttl_ms~ : Int64 = 15000,
) -> AsyncHttpTransport {
  let connections : Pool[@ahttp.Client]? = if pool {
    Some(
      pool_new(max_idle_per_origin, idle_ttl_ms, () => @date.now_millis(), fn(
        client,
      ) {
        client.close()
      }),
    )
  } else {
    None
  }
  { timeout_ms: timeout, pool: connections, }
}

///|
/// 收掉池里全部空闲连接。端口 `Transport` trait 刻意不动（send-only；trait 生命周期
/// 方法会逼每个实现方陪跑，而"池"只存在于本实现）——收尾走具体类型的这个口。
pub fn AsyncHttpTransport::drain_connections(self : Self) -> Unit {
  match self.pool {
    Some(p) => p.drain()
    None => ()
  }
}

///|
priv enum Pump {
  NoBody
  Whole(Bytes)
  FromStream(&@io.Reader)
}

///|
priv struct Prepared {
  /// scheme://authority——官方 `Client` 的构造参数（构造期校验 path 必须是 "/"，故只喂 origin）
  base : String
  /// user-agent 走构造期持久头：官方口径 UA 只许 per-client 全局设置；它同时是池键的一部分
  ua : String?
  /// 首个 / 起的剩余部分（含 query），一字不改进请求行（约束①）
  path_and_query : String
  /// 每请求头表：调用方头（去 user-agent）+ content-length 计划 + Accept-Encoding 决策
  extra : Map[@ahttp.CaseInsensitiveString, String]
  pump : Pump
}

///|
/// 约束②的落点：官方件公开面的头表是 `Map`，线上表达不了重复同名头。
/// 签名协议的多条目头（x-amz-meta-* 这类）需要的是"每条一行"的线格式，合并与丢弃都会改语义——
/// 所以这里响亮拒绝，把"静默丢"换成"显式发不出去"。端口形状仍是数组保序，桩实现不受此限。
fn reject_duplicate(
  name : String,
  seen : Set[@ahttp.CaseInsensitiveString],
) -> Unit raise TransportError {
  let key = @ahttp.CaseInsensitiveString(name)
  if seen.contains(key) {
    let reason = "重复同名头在官方 async/http 底座上不可携带（合并会改签名/元数据语义，端口拒绝静默丢）："
    raise TransportError::InvalidRequest(reason + name)
  }
  let _ = seen.add_and_check(key)
}

///|
/// 端口不收传输自有的头：host 由 URL authority 决定，content-length / transfer-encoding
/// 由 body 档推导（这是"Empty 显式带 0"那条实测教训的另一面——让调用方手写会造出两处真相）；
/// connection 由复用策略管（要关线用 `pool~ = false` 或 `drain_connections`，不让调用方
/// 单请求关线——那会把池的判据搅成两处真相）。
fn reject_transport_owned(name : String) -> Unit raise TransportError {
  let key = @ahttp.CaseInsensitiveString(name)
  if key == @ahttp.CaseInsensitiveString("host") {
    raise TransportError::InvalidRequest(
      "host 由 URL 的 authority 决定，端口拒绝显式携带",
    )
  }
  if key == @ahttp.CaseInsensitiveString("content-length") ||
    key == @ahttp.CaseInsensitiveString("transfer-encoding") {
    raise TransportError::InvalidRequest(
      "长度/分块由 body 档推导，端口拒绝显式携带：\{name}",
    )
  }
  if key == @ahttp.CaseInsensitiveString("connection") {
    raise TransportError::InvalidRequest(
      "连接的关/复用由传输策略管（pool~ 关池即每请求新建），端口拒绝显式携带",
    )
  }
}

///|
/// 绝对 URL 切分：`scheme://authority` 与 `首个 / 起的剩余`。切分是纯定位，不是规范化——
/// path?query 原样返回（约束①的落点）。fragment 拒绝（不上线上的东西，静默剥离
/// 会让"传进来的 URL"与"实际发的 URL"不一致）；pathless query 拒绝（官方 resolve_url
/// 会把它并进 host，端口宁可报错也不喂一个必错的输入）。
fn split_url(url : String) -> (String, String) raise TransportError {
  guard url.find("://") is Some(sep) else {
    raise TransportError::InvalidRequest("url 缺 :// 分隔：\{url}")
  }
  let scheme = url[:sep].to_owned()
  guard scheme is ("http" | "https") else {
    raise TransportError::InvalidRequest(
      "scheme 只支持 http/https，现读：\{scheme}",
    )
  }
  let rest = url[sep + 3:]
  guard rest.find("#") is None else {
    raise TransportError::InvalidRequest(
      "url 带 fragment；fragment 不上线上，端口拒绝而不是静默剥离：\{url}",
    )
  }
  match rest.find("/") {
    Some(i) => {
      let authority = rest[:i].to_owned()
      guard authority.length() > 0 else {
        raise TransportError::InvalidRequest("url 缺 authority：\{url}")
      }
      (scheme + "://" + authority, rest[i:].to_owned())
    }
    None =>
      match rest.find("?") {
        Some(_) =>
          raise TransportError::InvalidRequest(
            "pathless query（无 / 直接触 ?）官方底座接不了：\{url}",
          )
        None => {
          guard rest.length() > 0 else {
            raise TransportError::InvalidRequest("url 缺 authority：\{url}")
          }
          (scheme + "://" + rest.to_owned(), "/")
        }
      }
  }
}

///|
/// 纯准备半：请求 → (base, ua, path?query, 头表, 泵体计划)。不发网络，全部端口语义
/// 在这里判（假传输用例的承重面）；`send` 只负责把 Prepared 搬上线。
fn prepare(request : Request) -> Prepared raise TransportError {
  let (base, path_and_query) = split_url(request.url)
  let extra : Map[@ahttp.CaseInsensitiveString, String] = Map([])
  let seen : Set[@ahttp.CaseInsensitiveString] = Set([])
  let mut ua : String? = None
  let mut accept_encoding_seen = false
  for header in request.headers {
    reject_transport_owned(header.name)
    reject_duplicate(header.name, seen)
    let key = @ahttp.CaseInsensitiveString(header.name)
    if key == @ahttp.CaseInsensitiveString("user-agent") {
      ua = Some(header.value)
    } else {
      if key == @ahttp.CaseInsensitiveString("accept-encoding") {
        accept_encoding_seen = true
      }
      extra[key] = header.value
    }
  }
  // 约束③的落点：官方件在"调用方没带 Accept-Encoding"时会自己加 `gzip,identity`
  // 并在响应侧透明解压（0.22.4 send.mbt 的 auto_decompress）——那就是"正文被改写"。
  // 恒显式带 identity 压掉这条自动路径；调用方自带则原样透传、一字不改。
  if !accept_encoding_seen {
    extra[@ahttp.CaseInsensitiveString("accept-encoding")] = "identity"
  }
  let pump : Pump = match request.body {
    Empty => {
      // 空体也要说出口：无长度声明的 PUT 会被对象存储服务器读成分块上传（实测 MinIO 501）。
      extra[@ahttp.CaseInsensitiveString("content-length")] = "0"
      NoBody
    }
    Bytes(data) => {
      extra[@ahttp.CaseInsensitiveString("content-length")] = data
        .length()
        .to_string()
      Whole(data)
    }
    Stream(reader, length) =>
      match length {
        Some(n) => {
          guard n >= 0L else {
            raise TransportError::InvalidRequest("流式体长度为负：\{n}")
          }
          extra[@ahttp.CaseInsensitiveString("content-length")] = n.to_string()
          FromStream(reader)
        }
        // 给不出长度走 chunked——部分对象存储对 chunked PUT 直接 411/501，
        // 能不能用由上层按各家服务器实测决定，端口只保证通道本身忠实。
        None => FromStream(reader)
      }
  }
  { base, ua, path_and_query, extra, pump, }
}

///|
fn to_request_method(verb : Method) -> @ahttp.RequestMethod {
  match verb {
    Get => @ahttp.RequestMethod::Get
    Head => @ahttp.RequestMethod::Head
    Put => @ahttp.RequestMethod::Put
    Post => @ahttp.RequestMethod::Post
    Delete => @ahttp.RequestMethod::Delete
    Patch => @ahttp.RequestMethod::Patch
    Options => @ahttp.RequestMethod::Options
  }
}

///|
fn close_owned(reader : @io.MemoryReader?) -> Unit {
  match reader {
    Some(reader) => reader.close()
    None => ()
  }
}

///|
/// 请求头大小写不敏感的"有没有这条头"（官方应答头表）。
fn header_present(
  headers : Map[@ahttp.CaseInsensitiveString, String],
  name : String,
) -> Bool {
  headers.contains(@ahttp.CaseInsensitiveString(name))
}

///|
/// 请求头大小写不敏感的"这条头是不是这个值"（响应侧重复头已被官方 parser 逗号合并，
/// 只做整值等值判；"keep-alive, close" 这种组合值不在判内，如实记为已知限制）。
fn header_is(
  headers : Map[@ahttp.CaseInsensitiveString, String],
  name : String,
  value : String,
) -> Bool {
  match headers.get(@ahttp.CaseInsensitiveString(name)) {
    Some(actual) =>
      @ahttp.CaseInsensitiveString(actual) ==
      @ahttp.CaseInsensitiveString(value)
    None => false
  }
}

///|
/// 这条应答的连接是否可复用（issue #5 红线 3 的判据面）。官方公开面拿不到 HTTP 版本号
/// （parser 收 1.0/1.1 但 Response 只带 code/reason/headers）⇒ 1.0 不判别，靠两条兜底：
/// ① 1.0 默认关线 ⇒ 走"无帧不回池"；② 1.0 带 keep-alive 却中途关线的，由
/// "池线死了换新线重试一次"兜住。`enter_passthrough_mode` 本层从不调用，天然排除。
fn response_reusable(verb : Method, response : @ahttp.Response) -> Bool {
  if header_is(response.headers, "connection", "close") {
    return false
  }
  // 无体的应答（HEAD / 204 / 304，与官方 should_not_have_body 同判）：帧已知完整 ⇒ 可复用
  if verb is Head || response.code == 204 || response.code == 304 {
    return true
  }
  // 其余应答必须有帧（content-length 或 chunked）；没有就是关线定界（WaitConnectionClose），
  // EOF 即对端关线 ⇒ 这条连接已死，绝不回池
  header_present(response.headers, "content-length") ||
  header_present(response.headers, "transfer-encoding")
}

///|
/// send 的阶段结果：应答头拿到没有，决定"池线死了换新线重试一次"合不合法——
/// 只有"应答不可能已开始"的失败（建连/请求头/写体）才允许重试，应答阶段失败的
/// 状态不可知，重试可能双发。
priv enum SendOutcome {
  Done(@ahttp.Client, @ahttp.Response)
  FailedBeforeResponse(TransportError)
  FailedInResponse(TransportError)
}

///|
/// 单次线上动作：建连（或接池线）→ 请求行/头 → 泵体 → 收应答头。
/// 失败路径就地关线（失败的线绝不递出去，也绝不回池——红线 2）；
/// 成功路径所有权随 Done 上交，处置权在读尽钩子（回池或丢弃）。
async fn run_send(
  pooled : @ahttp.Client?,
  prepared : Prepared,
  verb : Method,
) -> SendOutcome {
  let client : @ahttp.Client = match pooled {
    Some(client) => client
    None => {
      let persistent : Map[@ahttp.CaseInsensitiveString, String] = Map([])
      if prepared.ua is Some(value) {
        persistent[@ahttp.CaseInsensitiveString("user-agent")] = value
      }
      @ahttp.Client::Client(prepared.base, headers=persistent) catch {
        error => {
          let msg = "建连失败（\{prepared.base}）：" + error.to_string()
          return FailedBeforeResponse(TransportError::Network(msg))
        }
      }
    }
  }
  // 阶段一：请求行/头 + 泵体——应答不可能已开始
  send_wire_head(client, prepared, verb) catch {
    error => {
      client.close()
      return FailedBeforeResponse(error)
    }
  }
  // 阶段二：收应答头（写侧的收尾 flush 也在里面；此后状态不可知，不再重试）
  let response = client.end_request() catch {
    error => {
      client.close()
      return FailedInResponse(
        TransportError::Network("应答头接收失败：" + error.to_string()),
      )
    }
  }
  Done(client, response)
}

///|
async fn send_wire_head(
  client : @ahttp.Client,
  prepared : Prepared,
  verb : Method,
) -> Unit raise TransportError {
  client.request(
    to_request_method(verb),
    prepared.path_and_query,
    extra_headers=prepared.extra,
  ) catch {
    error =>
      raise TransportError::Network(
        "请求行/头发送失败：" + error.to_string(),
      )
  }
  // Bytes 体经 MemoryReader 泵出：reader 必须活过整个 send——体是随请求边走边泵的，
  // 在 match 臂尾就地 close 会把未发完的写打断（存储线同一条教训）。
  let owned : @io.MemoryReader? = match prepared.pump {
    Whole(data) =>
      Some(@io.MemoryReader::MemoryReader(writer => writer.write(data)))
    _ => None
  }
  defer close_owned(owned)
  match prepared.pump {
    NoBody => ()
    Whole(_) =>
      client.write_reader(owned.unwrap()) catch {
        @ahttp.IncorrectBodyLength =>
          raise TransportError::InvalidRequest(
            "Bytes 体长度与推导的 content-length 不符",
          )
        error =>
          raise TransportError::Network(
            "请求体发送失败：" + error.to_string(),
          )
      }
    FromStream(reader) =>
      client.write_reader(reader) catch {
        @ahttp.IncorrectBodyLength =>
          raise TransportError::InvalidRequest(
            "流式体实际长度与声明的 content-length 不符",
          )
        error =>
          raise TransportError::Network(
            "请求体发送失败：" + error.to_string(),
          )
      }
  }
}

///|
pub impl Transport for AsyncHttpTransport with fn send(self, request) {
  let prepared = prepare(request)
  let key = pool_key(prepared.base, prepared.ua)
  // 重试资格：连接来自池 + 失败发生在"应答不可能已开始"的阶段 + 体可内存重放。
  // Stream 不能倒带——重试可能双发，直接上报（约束⑤的界由外层 with_timeout 管）。
  let replayable = match request.body {
    Stream(_, _) => false
    _ => true
  }
  let mut attempted_reconnect = false
  for ;; {
    let pooled : @ahttp.Client? = match self.pool {
      Some(p) => p.checkout(key)
      None => None
    }
    let reused = pooled is Some(_)
    // 约束⑤：建连 + 请求头 + 泵体 + 收应答头，整段 bounds 在一个 with_timeout 里。
    // 读体另有逐次 with_timeout（AsyncHttpBody::read）。
    let outcome : SendOutcome = @async.with_timeout(
      self.timeout_ms,
      () => run_send(pooled, prepared, request.http_method),
      error=TransportError::Timeout,
    ) catch {
      TransportError::Timeout => raise TransportError::Timeout
      TransportError::Network(msg) => raise TransportError::Network(msg)
      TransportError::InvalidRequest(msg) =>
        raise TransportError::InvalidRequest(msg)
      TransportError::InvalidResponse(msg) =>
        raise TransportError::InvalidResponse(msg)
      error => raise TransportError::Network(error.to_string())
    }
    match outcome {
      Done(client, response) => {
        let headers : Array[Header] = []
        for k, v in response.headers {
          let header : Header = { name: k.to_string(), value: v, }
          headers.push(header)
        }
        let reusable = self.pool is Some(_) &&
          response_reusable(request.http_method, response)
        let eof_hook : (@ahttp.Client) -> Unit = match (self.pool, reusable) {
          (Some(p), true) => fn(client) { p.deposit(key, client) }
          _ => fn(client) { client.close() }
        }
        let body : &ResponseBody = AsyncHttpBody::{
          client,
          timeout_ms: self.timeout_ms,
          eof_hook,
          finished: false,
        }
        return { status: response.code, headers, body, }
      }
      FailedBeforeResponse(_) if reused && !attempted_reconnect && replayable =>
        // 池里拿的线死了（对端闲置关线是常态）：换新线重试一次。
        attempted_reconnect = true
      FailedBeforeResponse(error) => raise error
      FailedInResponse(error) => raise error
    }
  }
}

///|
/// 应答体：包着官方 `Client`，读走 `read_some`（None 即 EOF），生命周期挂在读尽钩子上。
pub struct AsyncHttpBody {
  priv client : @ahttp.Client
  priv timeout_ms : Int32
  /// 读尽（read 返回 None）时的处置：可复用 ⇒ 回池；无池/不可复用 ⇒ 关线
  priv eof_hook : (@ahttp.Client) -> Unit
  priv mut finished : Bool
}

///|
pub impl ResponseBody for AsyncHttpBody with fn read(self, max_len) {
  // 约束⑤：每次读都 bounds——"拿应答头很快、读体挂死"是另一条会带走整轮测试的路。
  let bytes = @async.with_timeout(
    self.timeout_ms,
    () => self.client.read_some(max_len~),
    error=TransportError::Timeout,
  ) catch {
    TransportError::Timeout => {
      self.abandon()
      raise TransportError::Timeout
    }
    TransportError::Network(msg) => {
      self.abandon()
      raise TransportError::Network(msg)
    }
    TransportError::InvalidRequest(msg) => {
      self.abandon()
      raise TransportError::InvalidRequest(msg)
    }
    TransportError::InvalidResponse(msg) => {
      self.abandon()
      raise TransportError::InvalidResponse(msg)
    }
    error => {
      self.abandon()
      raise TransportError::Network(
        "应答体读取失败：" + error.to_string(),
      )
    }
  }
  // 红线 1：只有读尽的线才回池——EOF 即触发处置；此后消费方再 close 是 no-op
  //（所有权已在池里/已关线）。
  if bytes is None && !self.finished {
    self.finished = true
    (self.eof_hook)(self.client)
  }
  bytes
}

///|
/// 读体出错时就地弃线：半条连接的状态不可知（红线 2），关掉，绝不让它回池。
fn AsyncHttpBody::abandon(self : Self) -> Unit {
  if !self.finished {
    self.finished = true
    self.client.close()
  }
}

///|
pub impl ResponseBody for AsyncHttpBody with fn close(self) {
  if self.finished {
    // 读尽（已回池/已关线）或已弃线：处置权不在消费方，no-op
    return
  }
  self.finished = true
  // 保守默认（issue #5 红线 1）：没读尽就 close ⇒ 该连接状态不可知 ⇒ 丢弃，不回池。
  // 官方 end_request 的 skip 语义能救回这条线，但"少复用一次"换来"绝不错"，取保守档。
  self.client.close()
}

///|
pub extend AsyncHttpBody with ResponseBody::{read, close}

///|
pub extend AsyncHttpTransport with Transport::{send}
