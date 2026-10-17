///|
/// moon-hutool/http —— 可注入的 HTTP 传输端口 + 官方 `moonbitlang/async/http` 之上的薄适配
/// （需求登记：本仓 Issues #4；端口形状在对象存储线五条真腿上实测磨出，契约真相在 `docs/spec/26-http.md`）。
///
/// 分层（评审先看这段）：
///   端口半（本文件）：纯形状 + 两个 trait，零 OS 能力——桩实现不发网络即可断言全部端口语义；
///   适配半（`adapter.mbt`）：官方 async/http 之上的薄适配，只做"把 Request 忠实搬到线上 +
///   把应答忠实搬回端口"，不做任何协议语义解释。
///
/// 六条实现约束（Issues #4 点名，逐条落点见 spec §5；这里只留导览）：
///   ① URL 一字不改——传进来的绝对 URL 按"首个 /"切成 base 与 path?query，后者原样进请求行；
///   ② 重复同名头不折字典——端口按数组保序携带；官方底座公开面头表是 Map、线上表达不了重复，
///      适配层遇重复显式 `InvalidRequest`，绝不静默丢；
///   ③ 正文一字不改——官方件在调用方不带 `Accept-Encoding` 时会自己加并透明解压（0.22.4
///      `send.mbt` 的 `auto_decompress`），适配层恒显式带 `Accept-Encoding: identity` 压掉这条
///      自动路径；调用方自带该头则原样透传、一个字节不改；
///   ④ 响应体必须显式 close——连接生命周期挂在它上面，端口的 `close` 不 raise（收尾动作
///      不该再制造一种新错误档）；
///   ⑤ 超时不是可选的——建连+收发与每次读都 bounds 在 `@async.with_timeout` 里；官方件
///      0.22.4 没有 per-request timeout，一条挂死请求会把整轮测试带走（实测过）；
///   ⑥ 非 2xx 不在端口里解释——状态码原样上交，端口只负责"没拿到应答"与"应答畸形"两档。

///|
/// #26.1 请求方法。对位官方件的 `RequestMethod` 并裁掉端口消费方用不到的两档：
/// `Connect`（代理隧道是底层能力，端口消费方不走 CONNECT）与 `Trace`（hutool/存储两侧都无消费）。
pub(all) enum Method {
  Get
  Head
  Put
  Post
  Delete
  Patch
  Options
}

///|
/// #26.2 单条头。同名头可以重复、顺序必须保留——这是端口的携带语义（`Array` 不折叠）；
/// 官方底座适配层对重复的处理是响亮拒绝而不是静默合并，理由与代价见 spec §5 第 2 条。
pub(all) struct Header {
  name : String
  value : String
}

///|
/// #26.3 请求体三档。
/// - `Empty`：显式的空体——适配层会带 `content-length: 0`，不留给服务器猜
///   （对象存储服务器把无长度声明的 PUT 读成分块上传，实测 MinIO 答 501）；
/// - `Bytes`：整份字节；
/// - `Stream`：流式体——给得出长度就 `Content-Length`，给不出走 `Transfer-Encoding: chunked`
///   （部分对象存储对 chunked PUT 直接 411/501，能不能用这条档由上层按各家服务器实测决定）。
pub(all) enum RequestBody {
  Empty
  Bytes(Bytes)
  Stream(&@io.Reader, Int64?)
}

///|
/// #26.4 请求。`url` 是已拼好的绝对 URL，端口一字不改（约束①）；
/// `headers` 按数组携带、保序，适配层负责把它投到官方件的头表上。
pub(all) struct Request {
  http_method : Method
  url : String
  headers : Array[Header]
  body : RequestBody
}

///|
/// #26.5 传输错误四档。状态码不是错误（约束⑥）：2xx 与非 2xx 都算"拿到了应答"；
/// 这里只收"没拿到应答"（Network / Timeout）与"请求本身发不出去 / 应答没法解析"
/// （InvalidRequest / InvalidResponse）两族。
/// - Note: `Timeout` 单列不并入 `Network`——"没有在时限内得到应答"与"连接被拒"该走不同重试策略
///   （存储线实测把这两档分开后，重试层才写得出来）。
pub(all) suberror TransportError {
  Network(String)
  Timeout
  InvalidRequest(String)
  InvalidResponse(String)
}

///|
/// #26.6 响应体。`read` 返回 `None` 即 EOF；`close` 之后 `read` 必须报错而不是返回空
/// （把"忘 close"从静默资源泄漏变成显式故障）。`close` 不 raise。
pub(open) trait ResponseBody {
  async fn read(Self, Int32) -> Bytes? raise TransportError
  fn close(Self) -> Unit
}

///|
/// #26.7 应答。`status` 原样（约束⑥）；响应侧重复同名头由官方 parser 以逗号合并
/// （`parser.mbt` 现读 `"\{value0},\{value}"`），端口原样投影合并结果，不再二次折叠；
/// cookies 与 chunked trailer 不投影（存储线五条真腿无一消费，缺了就补是错误方向——先有消费再有形状）。
pub(all) struct Response {
  status : Int32
  headers : Array[Header]
  body : &ResponseBody
}

///|
/// #26.8 传输端口。实现方只有一条义务：忠实搬运。URL 头不动、正文不动、状态码不解释；
/// "没拿到应答"报 `Network`/`Timeout`，"发不出/解析不了"报 `InvalidRequest`/`InvalidResponse`。
pub(open) trait Transport {
  async fn send(Self, Request) -> Response raise TransportError
}
