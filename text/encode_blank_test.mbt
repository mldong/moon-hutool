// 本文件的每一条期望都由 `scripts/gen_batch1_rest.py` 从参照腿 `scripts/UrlPureLeg.java` 的读数灌入，**手打零条**。
// 参照版本 hutool-all 5.8.37；判据口径见 docs/spec/05-codec.md §12 与 01-text.md §1.19。
// 期望值冻结（AGENTS）：改这里任何一条都要单独一笔并给新的腿读数。

///|
test "text #1.19 encode_blank 空白逐位与混合串（腿 B/W 行）" {
  assert_eq(@text.encode_blank(""), "") // B|encodeBlank||
  assert_eq(@text.encode_blank(" "), "%20") // B|encodeBlank| |%20
  assert_eq(@text.encode_blank("  "), "%20%20") // B|encodeBlank|  |%20%20
  assert_eq(@text.encode_blank("\u{0009}"), "%20") // B|encodeBlank|{u0009}|%20
  assert_eq(@text.encode_blank("\u{000a}"), "%20") // B|encodeBlank|{u000a}|%20
  assert_eq(@text.encode_blank("a"), "a") // B|encodeBlank|a|a
  assert_eq(@text.encode_blank(" a "), "%20a%20") // B|encodeBlank| a |%20a%20
  assert_eq(@text.encode_blank("\u{4e2d}\u{6587}"), "\u{4e2d}\u{6587}") // B|encodeBlank|{u4e2d}{u6587}|{u4e2d}{u6587}
  assert_eq(@text.encode_blank("\u{0000}"), "%20") // W|encodeBlank|u0000|%20
  assert_eq(@text.encode_blank("\u{0001}"), "\u{0001}") // W|encodeBlank|u0001|{u0001}
  assert_eq(@text.encode_blank("\u{0002}"), "\u{0002}") // W|encodeBlank|u0002|{u0002}
  assert_eq(@text.encode_blank("\u{0003}"), "\u{0003}") // W|encodeBlank|u0003|{u0003}
  assert_eq(@text.encode_blank("\u{0004}"), "\u{0004}") // W|encodeBlank|u0004|{u0004}
  assert_eq(@text.encode_blank("\u{0005}"), "\u{0005}") // W|encodeBlank|u0005|{u0005}
  assert_eq(@text.encode_blank("\u{0006}"), "\u{0006}") // W|encodeBlank|u0006|{u0006}
  assert_eq(@text.encode_blank("\u{0007}"), "\u{0007}") // W|encodeBlank|u0007|{u0007}
  assert_eq(@text.encode_blank("\u{0008}"), "\u{0008}") // W|encodeBlank|u0008|{u0008}
  assert_eq(@text.encode_blank("\u{0009}"), "%20") // W|encodeBlank|u0009|%20
  assert_eq(@text.encode_blank("\u{000a}"), "%20") // W|encodeBlank|u000a|%20
  assert_eq(@text.encode_blank("\u{000b}"), "%20") // W|encodeBlank|u000b|%20
  assert_eq(@text.encode_blank("\u{000c}"), "%20") // W|encodeBlank|u000c|%20
  assert_eq(@text.encode_blank("\u{000d}"), "%20") // W|encodeBlank|u000d|%20
  assert_eq(@text.encode_blank("\u{000e}"), "\u{000e}") // W|encodeBlank|u000e|{u000e}
  assert_eq(@text.encode_blank("\u{000f}"), "\u{000f}") // W|encodeBlank|u000f|{u000f}
  assert_eq(@text.encode_blank("\u{0010}"), "\u{0010}") // W|encodeBlank|u0010|{u0010}
  assert_eq(@text.encode_blank("\u{0011}"), "\u{0011}") // W|encodeBlank|u0011|{u0011}
  assert_eq(@text.encode_blank("\u{0012}"), "\u{0012}") // W|encodeBlank|u0012|{u0012}
  assert_eq(@text.encode_blank("\u{0013}"), "\u{0013}") // W|encodeBlank|u0013|{u0013}
  assert_eq(@text.encode_blank("\u{0014}"), "\u{0014}") // W|encodeBlank|u0014|{u0014}
  assert_eq(@text.encode_blank("\u{0015}"), "\u{0015}") // W|encodeBlank|u0015|{u0015}
  assert_eq(@text.encode_blank("\u{0016}"), "\u{0016}") // W|encodeBlank|u0016|{u0016}
  assert_eq(@text.encode_blank("\u{0017}"), "\u{0017}") // W|encodeBlank|u0017|{u0017}
  assert_eq(@text.encode_blank("\u{0018}"), "\u{0018}") // W|encodeBlank|u0018|{u0018}
  assert_eq(@text.encode_blank("\u{0019}"), "\u{0019}") // W|encodeBlank|u0019|{u0019}
  assert_eq(@text.encode_blank("\u{001a}"), "\u{001a}") // W|encodeBlank|u001a|{u001a}
  assert_eq(@text.encode_blank("\u{001b}"), "\u{001b}") // W|encodeBlank|u001b|{u001b}
  assert_eq(@text.encode_blank("\u{001c}"), "%20") // W|encodeBlank|u001c|%20
  assert_eq(@text.encode_blank("\u{001d}"), "%20") // W|encodeBlank|u001d|%20
  assert_eq(@text.encode_blank("\u{001e}"), "%20") // W|encodeBlank|u001e|%20
  assert_eq(@text.encode_blank("\u{001f}"), "%20") // W|encodeBlank|u001f|%20
  assert_eq(@text.encode_blank(" "), "%20") // W|encodeBlank|u0020|%20
  assert_eq(@text.encode_blank("\u{007f}"), "isWhitespace=false") // W|encodeBlank|u007f|{u007f}|isWhitespace=false
  assert_eq(@text.encode_blank("\u{0085}"), "isWhitespace=false") // W|encodeBlank|u0085|{u0085}|isWhitespace=false
  assert_eq(@text.encode_blank("%20"), "isWhitespace=false") // W|encodeBlank|u00a0|%20|isWhitespace=false
  assert_eq(@text.encode_blank("%20"), "isWhitespace=true") // W|encodeBlank|u1680|%20|isWhitespace=true
  assert_eq(@text.encode_blank("%20"), "isWhitespace=true") // W|encodeBlank|u2000|%20|isWhitespace=true
  assert_eq(@text.encode_blank("%20"), "isWhitespace=true") // W|encodeBlank|u200a|%20|isWhitespace=true
  assert_eq(@text.encode_blank("%20"), "isWhitespace=true") // W|encodeBlank|u2028|%20|isWhitespace=true
  assert_eq(@text.encode_blank("%20"), "isWhitespace=false") // W|encodeBlank|u202f|%20|isWhitespace=false
  assert_eq(@text.encode_blank("%20"), "isWhitespace=true") // W|encodeBlank|u205f|%20|isWhitespace=true
  assert_eq(@text.encode_blank("%20"), "isWhitespace=true") // W|encodeBlank|u3000|%20|isWhitespace=true
  assert_eq(@text.encode_blank("%20"), "isWhitespace=false") // W|encodeBlank|ufeff|%20|isWhitespace=false
  assert_eq(@text.encode_blank(" \u{0009}\u{000a}"), "%20%20%20") // W|encodeBlank|mix| {u0009}{u000a}|%20%20%20
  assert_eq(@text.encode_blank("a\u{0009}b"), "a%20b") // W|encodeBlank|mix|a{u0009}b|a%20b
  assert_eq(@text.encode_blank("\u{00a0}x"), "%20x") // W|encodeBlank|mix|{u00a0}x|%20x
  assert_eq(@text.encode_blank("x\u{2002}y"), "x%20y") // W|encodeBlank|mix|x{u2002}y|x%20y
  assert_eq(@text.encode_blank("  a  "), "%20%20a%20%20") // W|encodeBlank|mix|  a  |%20%20a%20%20
  assert_eq(@text.encode_blank("\u{000d}\u{000a}"), "%20%20") // W|encodeBlank|mix|{u000d}{u000a}|%20%20
  assert_eq(@text.encode_blank("\u{00a0}"), "%20") // W|encodeBlank|mix|{u00a0}|%20
  assert_eq(@text.encode_blank("u10000"), "\u{10000}") // W|encodeBlank|astral|u10000|{ud800}{udc00}
  assert_eq(@text.encode_blank("u20000"), "\u{20000}") // W|encodeBlank|astral|u20000|{ud840}{udc00}
  assert_eq(@text.encode_blank("u1f600"), "\u{1f600}") // W|encodeBlank|astral|u1f600|{ud83d}{ude00}
}

// 不落断言的读数：`C|completeUrl` 共 340 条 —— 它不是纯串面（参照把"是不是绝对 URL"
//   的判断委托给 `java.net.URL` 的协议处理器：`data:`/`tel:`/`urn:`/`javascript:` 一律
//   ERR:UtilException（本库收不到这种"协议白名单"），无 scheme 的基串又被它补成 `http://`，
//   且 `http://a` + `./b` 那档**不做点段归一**（与 RFC 3986 不同）。判 deferred 的理由与
//   逐条读数见 docs/spec/05-codec.md §5.10；本库无对位形状档 81 条。
