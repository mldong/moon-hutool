# http

可注入的 HTTP 传输端口 + 官方 [`moonbitlang/async/http`](https://github.com/moonbitlang/async) 薄适配。本包不是 hutool 对位件——传输是基础件，端口形状在对象存储线五条真腿上实测磨出（需求登记：本仓 Issues #4）。

分层一句话：**端口半只定形状**（`Transport` / `ResponseBody` 两个 trait + 七件数据形状，零 OS 能力，桩实现不发网络即可断言全部端口语义）；**适配半只做忠实搬运**（`AsyncHttpTransport` 把 Request 原样搬上线、把应答原样搬回端口）。状态码不解释、URL 不改写、正文不透明处理；超时是硬界（官方件没有 per-request timeout，这层自己 bounds）。完整契约与实现决策见 [`docs/spec/26-http.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/26-http.md)。

> 状态：**已实现**（10-17）。只承诺 **native + wasm** 两档（官方 async/http 对 js/wasm-gc 是占位件）。本页示例块由 `moon test` 真跑并全绿——全部离线可复现：桩传输不发网络，适配层的形状拒绝发生在任何建连之前。

## 端口契约：桩实现即可全量验收

消费方依赖的是端口语义：URL 与头原样抵达、重复头保序、EOF 是 `None`、close 之后 read 必报错。这些判据不需要网络——桩一发就红：

```mbt check
///|
async test "端口把准备好的东西原样交给传输层" {
  let probe = DocRecordingTransport::{
    received: [],
    body: DocProbeBody::{ closed: false, },
  }
  let transport : &@http.Transport = probe
  let request = @http.Request::{
    http_method: @http.Method::Put,
    url: "https://s3.example.invalid/bucket/key?q=a%20b&x=1&x=2",
    headers: [
      { name: "x-example", value: "first", },
      { name: "x-example", value: "second", },
    ],
    body: @http.RequestBody::Empty,
  }
  let response = transport.send(request)
  assert_eq(
    probe.received[0].url,
    "https://s3.example.invalid/bucket/key?q=a%20b&x=1&x=2",
  )
  // 同名头保序携带（端口语义；官方底座适配层对重复是响亮拒绝，见下节）
  assert_eq(probe.received[0].headers.length(), 2)
  assert_eq(probe.received[0].headers[1].value, "second")
  assert_eq(response.status, 200)
  assert_eq(response.body.read(16), None)
  response.body.close()
  assert_true(probe.body.closed)
}
```

上面用到的桩（典型消费方的测试形状——把这段抄进自己的测试里就能验收任何 Transport 实现）：

```mbt check
///|
priv struct DocProbeBody {
  mut closed : Bool
}

///|
impl @http.ResponseBody for DocProbeBody with fn read(self, _max) {
  if self.closed {
    raise @http.TransportError::InvalidResponse("closed probe body")
  }
  None
}

///|
impl @http.ResponseBody for DocProbeBody with fn close(self) {
  self.closed = true
}

///|
priv struct DocRecordingTransport {
  received : Array[@http.Request]
  body : DocProbeBody
}

///|
impl @http.Transport for DocRecordingTransport with fn send(self, request) {
  self.received.push(request)
  { status: 200, headers: [], body: self.body, }
}
```

## 适配层的形状拒绝发生在建连之前

官方 `moonbitlang/async/http` 的头表是 Map，线上表达不了重复同名头——静默合并会改签名与元数据语义，所以适配层响亮拒绝而不是丢弃。这条判据离线即可复现（拒绝发生在 `prepare` 半，不碰网络）：

```mbt check
///|
async test "重复同名头响亮拒绝，不静默丢" {
  let transport = @http.AsyncHttpTransport::new()
  let request : @http.Request = {
    http_method: @http.Method::Put,
    url: "https://s3.example.invalid/bucket/key",
    headers: [
      { name: "x-amz-meta-a", value: "1", },
      { name: "x-amz-meta-a", value: "2", },
    ],
    body: @http.RequestBody::Empty,
  }
  let rejected = try {
    let _ = transport.send(request)
    false
  } catch {
    @http.TransportError::InvalidRequest(_) => true
    _ => false
  }
  assert_true(rejected)
}
```

传输自有的头同理拒绝：`host` 来自 URL 的 authority，`content-length` / `transfer-encoding` 由 body 档推导（`Empty` 显式带 0——对象存储服务器把无长度声明的 PUT 读成分块上传，实测 MinIO 答 501）：

```mbt check
///|
async test "长度由 body 档推导，端口拒绝显式携带" {
  let transport = @http.AsyncHttpTransport::new()
  let request : @http.Request = {
    http_method: @http.Method::Put,
    url: "https://s3.example.invalid/bucket/key",
    headers: [{ name: "content-length", value: "3", }],
    body: @http.RequestBody::Bytes(Bytes::from_array([1, 2, 3])),
  }
  let rejected = try {
    let _ = transport.send(request)
    false
  } catch {
    @http.TransportError::InvalidRequest(_) => true
    _ => false
  }
  assert_true(rejected)
}
```

## 连接什么时候复用、什么时候新建

默认（`pool~ = true`）：同一 `AsyncHttpTransport` 上，**同 origin（scheme+host+port+user-agent）的请求复用空闲连接**——一次 TCP+TLS 握手服务多次请求；`pool~ = false` 完全退回每 send 新建。`drain_connections()` 收掉池里的空闲连接（测试收尾、进程退出用）。

一条连接回池必须全部满足（红线，错了是协议串位，比慢严重得多）：

- **应答体读到了 EOF**（read 返回 `None`）——读一半就 close 是丢弃，不是回池；
- 应答没带 `Connection: close`；
- 应答有帧（`content-length` 或 `chunked`；HEAD/204/304 视为帧已知完整）——无帧应答靠关线定界，EOF 即对端关线，这条线已死。

绝不复用：任何一次 Timeout/Network 之后（半条连接状态不可知）；空闲超过 `idle_ttl_ms`（取出时静默丢弃）；同键空闲超过 `max_idle_per_origin`（最旧的先关）。从池里取出的线若在应答开始前就死掉（对端闲置关线是常态），Empty/Bytes 体自动换新线重试一次——Stream 体不能倒带，直接上报。

并发口径：协作式单线程调度下 checkout/deposit 无 await 点，结构性原子（上游若引入抢占式调度，这里是第一个要复查的地方）。

## 错误四档

状态码不是错误（2xx 与非 2xx 都算"拿到了应答"，各家错误码族上层自己解释）；端口只报"没拿到应答"与"发不出/解析不了"。`Timeout` 单列——"没在时限内得到应答"与"连接被拒"该走不同重试策略：

```mbt check
///|
fn describe_error(error : @http.TransportError) -> String {
  match error {
    @http.TransportError::Network(msg) => "Network: " + msg
    @http.TransportError::Timeout => "Timeout"
    @http.TransportError::InvalidRequest(msg) => "InvalidRequest: " + msg
    @http.TransportError::InvalidResponse(msg) => "InvalidResponse: " + msg
  }
}

///|
test "错误面四档的形状" {
  // 分型读数靠 match 取出，TransportError 不带 Show（错误串里不夹签名信息）
  assert_eq(describe_error(@http.TransportError::Timeout), "Timeout")
  assert_eq(
    describe_error(@http.TransportError::InvalidRequest("负长度")),
    "InvalidRequest: 负长度",
  )
}
```

超时默认 30s，`@http.AsyncHttpTransport::new(timeout=5000)` 按请求改；建连到收应答头整段一个界，应答体每次读另有界。
