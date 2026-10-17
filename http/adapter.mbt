///|
/// 默认超时 30s：官方件 0.22.4 没有 per-request timeout，`default_client()` 形状的客户端
/// 会在挂死端点上永远等下去——存储线真腿实测一条挂死请求把整轮测试一起带走。
/// 挂死比失败更糟，所以适配层在此设界，调用方可用 `timeout~` 改。
let default_timeout_ms : Int32 = 30000

///|
/// 唯一的具体实现：官方 `moonbitlang/async/http` 之上的薄适配（超时是这层自己 bounds 的）。
/// 每个 `send` 用一条新连接——官方 `Client` 与单一 host 绑定且一次只走一条请求状态机，
/// 按请求新建是保真的最短路径；连接复用不是本包的目标形状（存储线五条真腿无一依赖复用）。
pub struct AsyncHttpTransport {
  priv timeout_ms : Int32
}

///|
pub fn AsyncHttpTransport::new(
  timeout~ : Int32 = default_timeout_ms,
) -> AsyncHttpTransport {
  { timeout_ms: timeout, }
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
  /// user-agent 走构造期持久头：官方口径 UA 只许 per-client 全局设置，而本适配层一条请求一条连接
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
/// 由 body 档推导（这是"Empty 显式带 0"那条实测教训的另一面——让调用方手写会造出两处真相）。
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
pub impl Transport for AsyncHttpTransport with fn send(self, request) {
  let prepared = prepare(request)
  // 约束⑤：建连 + 请求头 + 泵体 + 收应答头，整段 bounds 在一个 with_timeout 里。
  // 读体另有逐次 with_timeout（AsyncHttpBody::read）。
  let outcome : (@ahttp.Client, @ahttp.Response) = @async.with_timeout(
    self.timeout_ms,
    () => {
      let persistent : Map[@ahttp.CaseInsensitiveString, String] = Map([])
      if prepared.ua is Some(value) {
        persistent[@ahttp.CaseInsensitiveString("user-agent")] = value
      }
      let client = @ahttp.Client::Client(prepared.base, headers=persistent) catch {
        error =>
          raise TransportError::Network(
            "建连失败（\{prepared.base}）：" + error.to_string(),
          )
      }
      // 成功路径 client 随应答交给 AsyncHttpBody（close 由消费方负责，约束④）；
      // 失败路径就地回收，不留半条连接。
      errdefer client.close()
      client.request(
        to_request_method(request.http_method),
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
      let response = client.end_request() catch {
        error =>
          raise TransportError::Network(
            "应答头接收失败：" + error.to_string(),
          )
      }
      (client, response)
    },
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
  let (client, response) = outcome
  let headers : Array[Header] = []
  for k, v in response.headers {
    let header : Header = { name: k.to_string(), value: v, }
    headers.push(header)
  }
  let body : &ResponseBody = AsyncHttpBody::{
    client,
    timeout_ms: self.timeout_ms,
  }
  { status: response.code, headers, body, }
}

///|
/// 应答体：包着官方 `Client`，读走 `read_some`（None 即 EOF），close 即连接关闭（幂等）。
pub struct AsyncHttpBody {
  priv client : @ahttp.Client
  priv timeout_ms : Int32
}

///|
pub impl ResponseBody for AsyncHttpBody with fn read(self, max_len) {
  // 约束⑤：每次读都 bounds——"拿应答头很快、读体挂死"是另一条会带走整轮测试的路。
  @async.with_timeout(
    self.timeout_ms,
    () => self.client.read_some(max_len~),
    error=TransportError::Timeout,
  ) catch {
    TransportError::Timeout => raise TransportError::Timeout
    TransportError::Network(msg) => raise TransportError::Network(msg)
    TransportError::InvalidRequest(msg) =>
      raise TransportError::InvalidRequest(msg)
    TransportError::InvalidResponse(msg) =>
      raise TransportError::InvalidResponse(msg)
    error =>
      raise TransportError::Network(
        "应答体读取失败：" + error.to_string(),
      )
  }
}

///|
pub impl ResponseBody for AsyncHttpBody with fn close(self) {
  // 约束④：不 raise——官方 close 幂等，重复调用只有第一次生效。
  self.client.close()
}

///|
pub extend AsyncHttpBody with ResponseBody::{read, close}

///|
pub extend AsyncHttpTransport with Transport::{send}
