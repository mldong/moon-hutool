// 适配层纯准备半的白盒用例（不发网络）：URL 切分保真、头表决策、长度计划、方法映射。
// 变异刀①（URL 规范化）与刀②（headers 折 Map 静默丢）的红由这批用例出；
// 真端点三档与连接 close 观察在 live_test.mbt。

///|
fn url_rejected(url : String) -> Bool {
  let ok = try {
    let _ = split_url(url)
    false
  } catch {
    TransportError::InvalidRequest(_) => true
    _ => false
  }
  ok
}

///|
test "split_url keeps path and query verbatim" {
  let got = split_url(
    "https://s3.example.invalid:9000/bucket/key?q=a%20b&x=1&x=2",
  ) catch {
    _ => ("!", "!")
  }
  assert_eq(got.0, "https://s3.example.invalid:9000")
  // 百分号编码不改写、query 键序不重排——签名协议把 canonical query 算在 URL 上（约束①）
  assert_eq(got.1, "/bucket/key?q=a%20b&x=1&x=2")
}

///|
test "split_url keeps a pathless origin whole" {
  let got = split_url("http://host.example:8080") catch { _ => ("!", "!") }
  assert_eq(got.0, "http://host.example:8080")
  assert_eq(got.1, "/")
}

///|
test "split_url rejects shapes it must not rewrite" {
  assert_true(url_rejected("/no-scheme.example/x"))
  assert_true(url_rejected("ftp://host.example/x"))
  assert_true(url_rejected("http://host.example/x#frag"))
  assert_true(url_rejected("http://host.example?q=1"))
  assert_true(url_rejected("http:///x"))
  assert_true(url_rejected("http://"))
}

///|
fn prepare_rejected(request : Request) -> Bool {
  let ok = try {
    let _ = prepare(request)
    false
  } catch {
    TransportError::InvalidRequest(_) => true
    _ => false
  }
  ok
}

///|
fn simple_request(headers : Array[Header], body : RequestBody) -> Request {
  {
    http_method: Put,
    url: "http://host.example:9000/bucket/key",
    headers,
    body,
  }
}

///|
test "prepare plans content-length per body shape" {
  let p = prepare(simple_request([], Bytes(Bytes::from_array([1, 2, 3])))) catch {
    _ => abort("prepare must accept a plain bytes request")
  }
  assert_eq(
    p.extra.get(@ahttp.CaseInsensitiveString("content-length")),
    Some("3"),
  )
  let empty = prepare(simple_request([], Empty)) catch {
    _ => abort("prepare must accept an empty request")
  }
  // 空体也要说出口：无长度声明的 PUT 被对象存储读成分块上传（实测 MinIO 501）
  assert_eq(
    empty.extra.get(@ahttp.CaseInsensitiveString("content-length")),
    Some("0"),
  )
  let reader = @io.MemoryReader::MemoryReader(writer => {
    writer.write(Bytes::from_array([1, 2, 3, 4, 5]))
  })
  defer reader.close()
  let known = prepare(simple_request([], Stream(reader, Some(5L)))) catch {
    _ => abort("prepare must accept a known-length stream")
  }
  assert_eq(
    known.extra.get(@ahttp.CaseInsensitiveString("content-length")),
    Some("5"),
  )
  let unknown = prepare(simple_request([], Stream(reader, None))) catch {
    _ => abort("prepare must accept a chunked stream")
  }
  assert_eq(
    unknown.extra.get(@ahttp.CaseInsensitiveString("content-length")),
    None,
  )
}

///|
test "prepare rejects a negative stream length" {
  let reader = @io.MemoryReader::MemoryReader(writer => {
    writer.write(Bytes::from_array([1]))
  })
  defer reader.close()
  assert_true(prepare_rejected(simple_request([], Stream(reader, Some(-1L)))))
}

///|
test "prepare injects accept-encoding identity only when absent" {
  let injected = prepare(simple_request([], Empty)) catch {
    _ => abort("prepare must accept an empty request")
  }
  // 官方件在缺省时会自己加 Accept-Encoding 并透明解压——identity 是压掉这条自动路径的显式选择
  assert_eq(
    injected.extra.get(@ahttp.CaseInsensitiveString("accept-encoding")),
    Some("identity"),
  )
  let caller = prepare(
    simple_request([{ name: "Accept-Encoding", value: "br", }], Empty),
  ) catch {
    _ => abort("prepare must accept a caller-provided accept-encoding")
  }
  // 调用方自带则原样透传、一字不改
  assert_eq(
    caller.extra.get(@ahttp.CaseInsensitiveString("accept-encoding")),
    Some("br"),
  )
}

///|
test "prepare routes user-agent to the per-client persistent header" {
  let p = prepare(
    simple_request([{ name: "user-agent", value: "probe/1", }], Empty),
  ) catch {
    _ => abort("prepare must accept a user-agent header")
  }
  assert_eq(p.ua, Some("probe/1"))
  assert_eq(p.extra.get(@ahttp.CaseInsensitiveString("user-agent")), None)
}

///|
test "prepare rejects duplicate same-name headers loudly" {
  // 官方底座头表是 Map，线上表达不了重复；静默合并/丢弃都会改签名与元数据语义（约束②）
  assert_true(
    prepare_rejected(
      simple_request(
        [
          { name: "x-example", value: "first", },
          { name: "x-example", value: "second", },
        ],
        Empty,
      ),
    ),
  )
}

///|
test "prepare rejects transport-owned headers" {
  assert_true(
    prepare_rejected(simple_request([{ name: "host", value: "h", }], Empty)),
  )
  assert_true(
    prepare_rejected(
      simple_request([{ name: "content-length", value: "3", }], Empty),
    ),
  )
  assert_true(
    prepare_rejected(
      simple_request([{ name: "transfer-encoding", value: "chunked", }], Empty),
    ),
  )
}

///|

///|
test "prepare rejects an explicit connection header" {
  // 连接的关/复用由传输策略管（pool~ 关池即每请求新建），不收调用方单请求关线
  assert_true(
    prepare_rejected(
      simple_request([{ name: "connection", value: "close", }], Empty),
    ),
  )
}

///|
test "response_reusable follows the three exclusions" {
  let framed = simple_response(200, [{ name: "content-length", value: "2", }])
  let chunked = simple_response(200, [
    { name: "transfer-encoding", value: "chunked", },
  ])
  let with_close = simple_response(200, [
    { name: "content-length", value: "2", },
    { name: "connection", value: "close", },
  ])
  let no_frame = simple_response(200, [])
  // ① Connection: close 不回池
  assert_false(response_reusable(Get, with_close))
  // ② 无帧（关线定界）不回池
  assert_false(response_reusable(Get, no_frame))
  // ③ 有帧可复用
  assert_true(response_reusable(Get, framed))
  assert_true(response_reusable(Get, chunked))
  // 无体应答（HEAD/204/304，帧已知完整）可复用
  assert_true(response_reusable(Head, no_frame))
  assert_true(response_reusable(Get, simple_response(204, [])))
  assert_true(response_reusable(Get, simple_response(304, [])))
}

///|
fn simple_response(code : Int32, headers : Array[Header]) -> @ahttp.Response {
  let map : Map[@ahttp.CaseInsensitiveString, String] = Map([])
  for header in headers {
    map[@ahttp.CaseInsensitiveString(header.name)] = header.value
  }
  { code, reason: "OK", headers: map, cookies: [], }
}

///|
test "method mapping covers all seven verbs" {
  assert_eq(to_request_method(Get), @ahttp.RequestMethod::Get)
  assert_eq(to_request_method(Head), @ahttp.RequestMethod::Head)
  assert_eq(to_request_method(Put), @ahttp.RequestMethod::Put)
  assert_eq(to_request_method(Post), @ahttp.RequestMethod::Post)
  assert_eq(to_request_method(Delete), @ahttp.RequestMethod::Delete)
  assert_eq(to_request_method(Patch), @ahttp.RequestMethod::Patch)
  assert_eq(to_request_method(Options), @ahttp.RequestMethod::Options)
}
