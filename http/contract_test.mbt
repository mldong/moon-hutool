// 端口契约（不发网络）：桩实现断言"端口把调用方准备好的东西原样交给传输层"。
// 形状对位存储线 transport_test.mbt；判据按 Issues #4 验收要求：
//   URL 与 headers 原样抵达、重复头顺序保留、read 到 None 即 EOF、close 之后 read 必报错。
// 适配层自身语义（URL 切分、头表决策、长度计划）在 adapter_wbtest.mbt；真端点三档在 live_test.mbt。

///|
struct ProbeBody {
  mut closed : Bool
}

///|
impl @http.ResponseBody for ProbeBody with fn read(self, max_bytes) {
  let _ = max_bytes
  if self.closed {
    raise @http.TransportError::InvalidResponse("closed probe body")
  }
  None
}

///|
impl @http.ResponseBody for ProbeBody with fn close(self) {
  self.closed = true
}

///|
struct ProbeTransport {
  received : Array[@http.Request]
  fail : Bool
  body : ProbeBody
}

///|
impl @http.Transport for ProbeTransport with fn send(self, request) {
  self.received.push(request)
  if self.fail {
    raise @http.TransportError::Timeout
  }
  { status: 200, headers: [], body: self.body, }
}

///|
async test "port contract preserves the prepared URL and headers" {
  let probe = ProbeTransport::{
    received: [],
    fail: false,
    body: ProbeBody::{ closed: false, },
  }
  let transport : &@http.Transport = probe
  let request = @http.Request::{
    http_method: @http.Method::Get,
    url: "https://s3.example.invalid/bucket/key?q=a%20b&x=1&x=2",
    headers: [
      { name: "x-example", value: "first", },
      { name: "x-example", value: "second", },
    ],
    body: @http.RequestBody::Empty,
  }
  let response = transport.send(request)
  assert_eq(probe.received.length(), 1)
  assert_eq(probe.received[0].url, request.url)
  assert_eq(probe.received[0].headers.length(), 2)
  assert_eq(probe.received[0].headers[0].value, "first")
  assert_eq(probe.received[0].headers[1].value, "second")
  assert_eq(response.status, 200)
  assert_eq(response.body.read(16), None)
  response.body.close()
  assert_true(probe.body.closed)
}

///|
async test "port contract carries a typed failure" {
  let transport : &@http.Transport = ProbeTransport::{
    received: [],
    fail: true,
    body: ProbeBody::{ closed: false, },
  }
  let request = @http.Request::{
    http_method: @http.Method::Head,
    url: "https://s3.example.invalid/bucket/key",
    headers: [],
    body: @http.RequestBody::Empty,
  }
  let timed_out = try {
    let _ = transport.send(request)
    false
  } catch {
    @http.TransportError::Timeout => true
    _ => false
  }
  assert_true(timed_out)
}

///|
async test "closed body must fault rather than answer empty" {
  let body : &@http.ResponseBody = ProbeBody::{ closed: false, }
  assert_eq(body.read(16), None)
  body.close()
  let answered_empty = try {
    let again = body.read(16)
    again is None
  } catch {
    _ => false
  }
  assert_false(answered_empty)
}

///|
async test "stream request retains its reader and 64 bit length" {
  let bytes = Bytes::from_array([0, 255, 128, 1])
  let reader = @io.MemoryReader::MemoryReader(writer => writer.write(bytes))
  defer reader.close()
  let body = @http.RequestBody::Stream(reader, Some(4294967296L))
  match body {
    @http.RequestBody::Stream(source, length) => {
      assert_eq(length, Some(4294967296L))
      assert_eq(source.read_all().binary(), bytes)
    }
    _ => fail("expected stream body")
  }
}
