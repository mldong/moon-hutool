// live 三档 + 连接 close 观察：由 MOONHUTOOL_HTTP_LIVE_BASE 门控
// （本地工装 scripts/http_live_harness.mjs：302 不跟 / 强制 gzip / 黑洞不答 / 连接计数）。
// 无 env 时响亮 SKIP——SKIP 不是 PASS，判据与跑法见 docs/spec/26-http.md §live。

///|
/// `TransportError` 没有 Show 实例，读数手动拼写。
fn describe(error : @http.TransportError) -> String {
  match error {
    @http.TransportError::Network(msg) => "Network: " + msg
    @http.TransportError::Timeout => "Timeout"
    @http.TransportError::InvalidRequest(msg) => "InvalidRequest: " + msg
    @http.TransportError::InvalidResponse(msg) => "InvalidResponse: " + msg
  }
}

///|
/// 把指定 URL 当 GET 发出去，读完整应答体并以数字返回（工装的计数端点是纯十进制文本）。
async fn fetch_int(url : String) -> Int32? {
  let transport : &@http.Transport = @http.AsyncHttpTransport::new(timeout=3000)
  let request : @http.Request = {
    http_method: Get,
    url,
    headers: [],
    body: Empty,
  }
  let body : Bytes? = try {
    let response = transport.send(request)
    let chunk = response.body.read(256)
    response.body.close()
    chunk
  } catch {
    _ => None
  }
  match body {
    None => None
    Some(bytes) =>
      if bytes.length() == 0 {
        None
      } else {
        let mut n = 0
        let mut ok = true
        for i in 0..<bytes.length() {
          let b = bytes[i]
          if b < b'0' || b > b'9' {
            ok = false
          } else {
            n = n * 10 + (b - b'0').to_int()
          }
        }
        if ok {
          Some(n)
        } else {
          None
        }
      }
  }
}

///|
async fn probe_error(url : String, timeout_ms : Int32) -> @http.TransportError? {
  let transport : &@http.Transport = @http.AsyncHttpTransport::new(
    timeout=timeout_ms,
  )
  let request : @http.Request = {
    http_method: Get,
    url,
    headers: [],
    body: Empty,
  }
  try {
    let response = transport.send(request)
    response.body.close()
    None
  } catch {
    error => Some(error)
  }
}

///|
fn header_value(response : @http.Response, name : String) -> String? {
  let mut found : String? = None
  for header in response.headers {
    if header.name == name {
      found = Some(header.value)
    }
  }
  found
}

///|
async test "live: a 302 comes back as the answer and is not followed" {
  match @env.get_env_var("MOONHUTOOL_HTTP_LIVE_BASE") {
    None => {
      println("SKIP live 302 tier, MOONHUTOOL_HTTP_LIVE_BASE not supplied")
      println(
        "SKIP IS NOT A PASS: the no-follow guarantee was not exercised by this run.",
      )
    }
    Some(base) => {
      let transport : &@http.Transport = @http.AsyncHttpTransport::new()
      let request : @http.Request = {
        http_method: Get,
        url: base + "/redirect",
        headers: [],
        body: Empty,
      }
      let response = transport.send(request)
      assert_eq(response.status, 302)
      assert_eq(header_value(response, "location"), Some("/target"))
      response.body.close()
      // 不得自动跟随：目标端点的命中数必须仍是 0（工装逐请求计数）
      match fetch_int(base + "/counter?name=target") {
        None => fail("counter endpoint unreadable")
        Some(hits) => assert_eq(hits, 0)
      }
    }
  }
}

///|
let gzip_fixture : Bytes = Bytes::from_array([
  31, 139, 8, 0, 0, 0, 0, 0, 2, 10, 1, 54, 0, 201, 255, 109, 111, 111, 110, 45, 104,
  117, 116, 111, 111, 108, 32, 104, 116, 116, 112, 32, 108, 105, 118, 101, 32, 103,
  122, 105, 112, 32, 108, 101, 103, 32, 226, 128, 148, 32, 230, 173, 163, 230, 150,
  135, 228, 184, 128, 229, 173, 151, 228, 184, 141, 230, 148, 185, 10, 17, 166, 45,
  65, 54, 0, 0, 0,
])

///|
async test "live: a gzip-forcing endpoint is read as raw bytes, not rewritten" {
  match @env.get_env_var("MOONHUTOOL_HTTP_LIVE_BASE") {
    None => {
      println("SKIP live gzip tier, MOONHUTOOL_HTTP_LIVE_BASE not supplied")
      println(
        "SKIP IS NOT A PASS: the no-transparent-rewrite guarantee was not exercised by this run.",
      )
    }
    Some(base) => {
      let transport : &@http.Transport = @http.AsyncHttpTransport::new()
      let request : @http.Request = {
        http_method: Get,
        url: base + "/gzip",
        headers: [],
        body: Empty,
      }
      let response = transport.send(request)
      assert_eq(response.status, 200)
      // 适配层显式带了 Accept-Encoding: identity，官方件不得自己加头并透明解压
      assert_eq(header_value(response, "content-encoding"), Some("gzip"))
      let all : Array[Byte] = []
      for ;; {
        match response.body.read(1024) {
          Some(part) => {
            let n = part.length()
            for i in 0..<n {
              all.push(part[i])
            }
          }
          None => break
        }
      }
      response.body.close()
      assert_eq(Bytes::from_array(all), gzip_fixture)
    }
  }
}

///|
async test "live: a silent endpoint is given up on rather than waited for" {
  match @env.get_env_var("MOONHUTOOL_HTTP_LIVE_BASE") {
    None => {
      println("SKIP live timeout tier, MOONHUTOOL_HTTP_LIVE_BASE not supplied")
      println(
        "SKIP IS NOT A PASS: the request timeout was not exercised by this run.",
      )
    }
    Some(base) => {
      let started = @date.now_millis()
      let outcome = probe_error(base + "/never", 1500)
      let elapsed = @date.now_millis() - started
      match outcome {
        None => fail("a silent endpoint was waited on indefinitely")
        Some(error) => {
          match error {
            @http.TransportError::Timeout => ()
            other => fail("expected Timeout, got " + describe(other))
          }
          // 1.5s 的配置不得拖成半分钟：界是硬的
          assert_true(elapsed < 20000L)
          println(
            "timeout leg answered Timeout after " + elapsed.to_string() + "ms",
          )
        }
      }
    }
  }
}

///|
async test "live: body close releases the server-side connection" {
  match @env.get_env_var("MOONHUTOOL_HTTP_LIVE_BASE") {
    None => {
      println("SKIP live close tier, MOONHUTOOL_HTTP_LIVE_BASE not supplied")
      println(
        "SKIP IS NOT A PASS: the close guarantee was not exercised by this run.",
      )
    }
    Some(base) => {
      let transport : &@http.Transport = @http.AsyncHttpTransport::new()
      let request : @http.Request = {
        http_method: Get,
        url: base + "/bytes",
        headers: [],
        body: Empty,
      }
      let response = transport.send(request)
      assert_eq(response.status, 200)
      let chunk = response.body.read(64)
      assert_true(chunk is Some(_))
      assert_eq(response.body.read(64), None)
      response.body.close()
      // FIN 到达有窗口：轮询几拍等连接数落回 0——"省掉 close"的变异在这条上必红
      let mut released = false
      for _ in 0..<10 {
        match fetch_int(base + "/open") {
          Some(0) => {
            released = true
            break
          }
          _ => ()
        }
        @async.sleep(200)
      }
      assert_true(released)
    }
  }
}
