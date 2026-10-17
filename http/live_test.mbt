// live 档：issue #4 三档契约 + issue #5 连接池五档，合成**一个**串行 suite。
// 为什么合成一个：wasm 测试跑批里多个 async test 会互相穿插（探针实测交错），
// 分档的 accepts 增量窗口会被别的档的连接污染——串行在一个测试体里就没有这个窗口问题。
// 由 MOONHUTOOL_HTTP_LIVE_BASE 门控（本地工装 scripts/http_live_harness.mjs）；
// 无 env 时响亮 SKIP——SKIP 不是 PASS，判据与跑法见 docs/spec/26-http.md §5。

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
/// 计数/状态读数专用：pool=false——探测连接自身不进池、不在 /open 里冒充应用连接。
async fn fetch_int(url : String) -> Int32? {
  let transport : &@http.Transport = @http.AsyncHttpTransport::new(
    timeout=3000,
    pool=false,
  )
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
/// 正常消费一拍：读尽再 close——只有读尽的线才允许回池（红线 1）。
async fn get_status(transport : &@http.Transport, url : String) -> Int32? {
  let request : @http.Request = {
    http_method: Get,
    url,
    headers: [],
    body: Empty,
  }
  let status : Int32? = try {
    let response = transport.send(request)
    let status = response.status
    for ;; {
      match response.body.read(4096) {
        Some(_) => continue
        None => break
      }
    }
    response.body.close()
    Some(status)
  } catch {
    _ => None
  }
  status
}

///|
/// 读一半就 close：红线 1 的保守档 ⇒ 该连接必须被丢弃而不是回池。
async fn get_status_read_some(
  transport : &@http.Transport,
  url : String,
  read_len : Int32,
) -> Int32? {
  let request : @http.Request = {
    http_method: Get,
    url,
    headers: [],
    body: Empty,
  }
  let status : Int32? = try {
    let response = transport.send(request)
    let status = response.status
    let _ = response.body.read(read_len)
    response.body.close()
    Some(status)
  } catch {
    _ => None
  }
  status
}

///|
async fn concurrent_probe_ok(
  transport : &@http.Transport,
  url : String,
) -> Bool {
  @async.with_task_group(group => {
    let t1 = group.spawn(() => get_status(transport, url))
    let t2 = group.spawn(() => get_status(transport, url))
    let t3 = group.spawn(() => get_status(transport, url))
    let t4 = group.spawn(() => get_status(transport, url))
    let r1 = t1.wait()
    let r2 = t2.wait()
    let r3 = t3.wait()
    let r4 = t4.wait()
    r1 == Some(200) && r2 == Some(200) && r3 == Some(200) && r4 == Some(200)
  })
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
async test "live: wire contract and pool tiers (serialized)" {
  match @env.get_env_var("MOONHUTOOL_HTTP_LIVE_BASE") {
    None => {
      println(
        "SKIP live suite (302/gzip/timeout + pool five tiers), MOONHUTOOL_HTTP_LIVE_BASE not supplied",
      )
      println(
        "SKIP IS NOT A PASS: none of the live guarantees were exercised by this run.",
      )
    }
    Some(base) => {
      let transport : &@http.Transport = @http.AsyncHttpTransport::new()
      // ── 契约一（issue #4）：302 原样返回、不自动跟随 ──
      let request : @http.Request = {
        http_method: Get,
        url: base + "/redirect",
        headers: [],
        body: Empty,
      }
      let redirected = transport.send(request)
      assert_eq(redirected.status, 302)
      assert_eq(header_value(redirected, "location"), Some("/target"))
      redirected.body.close()
      match fetch_int(base + "/counter?name=target") {
        None => fail("counter endpoint unreadable")
        Some(hits) => assert_eq(hits, 0)
      }
      // ── 契约二（issue #4）：强制 gzip 拿原字节，正文一字不改 ──
      let gzip_request : @http.Request = {
        http_method: Get,
        url: base + "/gzip",
        headers: [],
        body: Empty,
      }
      let gzipped = transport.send(gzip_request)
      assert_eq(gzipped.status, 200)
      // 适配层显式带了 Accept-Encoding: identity，官方件不得自己加头并透明解压
      assert_eq(header_value(gzipped, "content-encoding"), Some("gzip"))
      let all : Array[Byte] = []
      for ;; {
        match gzipped.body.read(1024) {
          Some(part) => {
            let n = part.length()
            for i in 0..<n {
              all.push(part[i])
            }
          }
          None => break
        }
      }
      gzipped.body.close()
      assert_eq(Bytes::from_array(all), gzip_fixture)
      // ── 契约三（issue #4）：黑洞端点 1.5s 出 Timeout，不挂死 ──
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
          assert_true(elapsed < 20000L)
          println(
            "timeout leg answered Timeout after " + elapsed.to_string() + "ms",
          )
        }
      }
      // ── 池档一（issue #5 回归）：pool=false 退回"每 send 一条新连接" ──
      let legacy : &@http.Transport = @http.AsyncHttpTransport::new(pool=false)
      let before_legacy = fetch_int(base + "/counter?name=accepts")
      for _ in 0..<3 {
        match get_status(legacy, base + "/bytes") {
          Some(200) => ()
          _ => fail("expected 200, got something else")
        }
      }
      let after_legacy = fetch_int(base + "/counter?name=accepts")
      match (before_legacy, after_legacy) {
        (Some(b), Some(a)) => assert_eq(a - b, 3)
        _ => fail("accepts counter unreadable")
      }
      // ── 池档二（issue #5 正向）：8 拍串行复用 1 条连接 ──
      let reuser : &@http.Transport = @http.AsyncHttpTransport::new()
      let before_reuse_accepts = fetch_int(base + "/counter?name=accepts")
      let before_reuse_hits = fetch_int(base + "/counter?name=bytes")
      for _ in 0..<8 {
        match get_status(reuser, base + "/bytes") {
          Some(200) => ()
          _ => fail("expected 200, got something else")
        }
      }
      let after_reuse_accepts = fetch_int(base + "/counter?name=accepts")
      let after_reuse_hits = fetch_int(base + "/counter?name=bytes")
      match
        (
          before_reuse_accepts, after_reuse_accepts, before_reuse_hits, after_reuse_hits,
        ) {
        (Some(ba), Some(aa), Some(bh), Some(ah)) => {
          assert_eq(aa - ba, 1)
          assert_eq(ah - bh, 8)
        }
        _ => fail("counter endpoint unreadable")
      }
      // ── 池档三（issue #5 并发）：4 拍并发各建一线互不踩，随后两拍串行零新建 ──
      let before_conc = fetch_int(base + "/counter?name=accepts")
      let before_conc_hits = fetch_int(base + "/counter?name=bytes")
      let reuser2 : &@http.Transport = @http.AsyncHttpTransport::new()
      assert_true(concurrent_probe_ok(reuser2, base + "/bytes"))
      match get_status(reuser2, base + "/bytes") {
        Some(200) => ()
        _ => fail("expected 200, got something else")
      }
      match get_status(reuser2, base + "/bytes") {
        Some(200) => ()
        _ => fail("expected 200, got something else")
      }
      let after_conc = fetch_int(base + "/counter?name=accepts")
      let after_conc_hits = fetch_int(base + "/counter?name=bytes")
      match (before_conc, after_conc, before_conc_hits, after_conc_hits) {
        (Some(ba), Some(aa), Some(bh), Some(ah)) => {
          // 判上限不判等值：协作式调度下四拍可能串行完成（先回池后取用），
          // 那是正确行为；"互不踩"由 checkout 的结构性独占（取出即移出池）保证
          assert_true(aa - ba <= 4)
          assert_eq(ah - bh, 6)
        }
        _ => fail("counter endpoint unreadable")
      }
      // ── 池档四（issue #5 负向一）：Connection: close 应答 ⇒ 下一拍必须新建 ──
      let closer : &@http.Transport = @http.AsyncHttpTransport::new()
      let before_close3 = fetch_int(base + "/counter?name=accepts")
      // 工装在第 3 个应答上带 Connection: close 并掐线
      for _ in 0..<4 {
        match get_status(closer, base + "/close3") {
          Some(200) => ()
          _ => fail("expected 200, got something else")
        }
      }
      let after_close3 = fetch_int(base + "/counter?name=accepts")
      // 前两拍复用 1 条线，第 3 拍被关 ⇒ 第 4 拍新建；"把死线递上去"的形状是
      // Timeout/Network，不会是 200
      match (before_close3, after_close3) {
        (Some(ba), Some(aa)) => assert_eq(aa - ba, 2)
        _ => fail("counter endpoint unreadable")
      }
      // ── 池档五（issue #5 负向二）：读一半就 close ⇒ 丢弃且不留残留 ──
      let halfer : &@http.Transport = @http.AsyncHttpTransport::new()
      let before_half = fetch_int(base + "/counter?name=accepts")
      for _ in 0..<3 {
        match get_status_read_some(halfer, base + "/big", 64) {
          Some(200) => ()
          _ => fail("expected 200, got something else")
        }
      }
      // 连续三次"读一半"之后，池里不得有残留可复用线 ⇒ 下一拍必须是新建
      match get_status(halfer, base + "/bytes") {
        Some(200) => ()
        _ => fail("expected 200, got something else")
      }
      let after_half = fetch_int(base + "/counter?name=accepts")
      match (before_half, after_half) {
        (Some(ba), Some(aa)) => assert_eq(aa - ba, 4)
        _ => fail("counter endpoint unreadable")
      }
    }
  }
}
