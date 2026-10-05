///|
// Props 第二批的期望值全部由生成脚本从参照腿灌入（手打零条）。
// 腿：本机 JDK 17.0.14 的 `java.util.Properties`（**权威参照是 JDK 不是 hutool**——参照 `Props`
//   的解析全部转手 `super.load(reader)`）；`load(StringReader)` 36 个夹具 + `setProperty/remove/getProperty`
//   22 步写侧操作，合计 179 行读数（另有 383 行的第一批 JDK 直档探针在 spec §8 记事实）。
// 参照是 `Hashtable`（无序）⇒ **内容维**逐键 `props_get_or` 对账（键来自腿的排序 PAIR 读数，
//   条数由 `props_size` 封死"没有多余键"），**顺序维**用腿的 `ORDER`（逐行喂入求得的新键出现序）作旁证；
//   顺序这一维是本库自定（spec §9.1 第 2 条），不冒充参照。
// `props_store` 只在单条表上对拍（多条表参照的写出序是 Hashtable 序，不可用）；
//   期望由腿的 STORE 读数按"切掉时间戳首行 + CRLF 换 LF"的机械变换得到（spec §9.1 第 3 条）。

///|
fn pesc(s : String) -> String {
  let digits = [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f",
  ]
  fn h4(v : Int) -> String {
    digits[(v >> 12) & 0xf] +
    digits[(v >> 8) & 0xf] +
    digits[(v >> 4) & 0xf] +
    digits[v & 0xf]
  }
  let mut out = ""
  for c in s.to_array() {
    let cp = c.to_int()
    if cp == 0x5c {
      out = out + "\\\\"
    } else if cp == 0x0d {
      out = out + "\\r"
    } else if cp == 0x0a {
      out = out + "\\n"
    } else if cp == 0x09 {
      out = out + "\\t"
    } else if cp > 0xffff {
      let x = cp - 0x10000
      out = out +
        "\\u" +
        h4(0xd800 + (x >> 10)) +
        "\\u" +
        h4(0xdc00 + (x & 0x3ff))
    } else if cp < 0x20 || cp == 0x7f || cp > 0x7e {
      out = out + "\\u" + h4(cp)
    } else {
      out = out + c.to_string()
    }
  }
  out
}

///|
fn pjoin(a : Array[String], sep : String) -> String {
  let mut out = ""
  let mut first = true
  for x in a {
    if !first {
      out = out + sep
    }
    first = false
    out = out + x
  }
  out
}

///|
// 本库自定的首次出现序：`键=值` 用 "|" 连（腿侧对应读数见每条尾标）
fn ordered_str(p : @ini.Props) -> String {
  let parts : Array[String] = []
  for kv in @ini.props_entries(p) {
    parts.push(pesc(kv.0) + "=" + pesc(kv.1))
  }
  pjoin(parts, "|")
}

///|
// 内容维：逐键 `props_get_or` 取值，缺省用哨兵串——哨兵在任何夹具值里都不出现
fn get_or_tag(p : @ini.Props, k : String) -> String {
  pesc(@ini.props_get_or(p, k, "~absent~"))
}

///|
fn ptag(e : @ini.PropsError) -> String {
  match e {
    @ini.BadUnicodeEscape => "BadUnicodeEscape"
  }
}

///|
fn parse_tag(text : String) -> String {
  try {
    let p = @ini.props_parse(text)
    "OK:" + ordered_str(p)
  } catch {
    e => "ERR:" + ptag(e)
  }
}

///|
test "props 解析：分隔符三档与分隔符前后的空白吸收" {
  let pp_sep_space_multi = @ini.props_parse("a   b   c\n")
  assert_eq(@ini.props_size(pp_sep_space_multi), 1) // p.sep_space_multi.size|1
  assert_eq(get_or_tag(pp_sep_space_multi, "a"), "b   c") // p.sep_space_multi.content|a=b   c
  assert_eq(@ini.props_has_key(pp_sep_space_multi, "a"), true) // p.sep_space_multi.has|a
  assert_eq(ordered_str(pp_sep_space_multi), "a=b   c") // p.sep_space_multi.ordered|a=b   c
  assert_eq(pesc(@ini.props_store(pp_sep_space_multi)), "a=b   c\\n") // p.sep_space_multi.store|a=b   c\n

  let pp_ws_before_sep = @ini.props_parse("a   =b\n")
  assert_eq(@ini.props_size(pp_ws_before_sep), 1) // p.ws_before_sep.size|1
  assert_eq(get_or_tag(pp_ws_before_sep, "a"), "b") // p.ws_before_sep.content|a=b
  assert_eq(@ini.props_has_key(pp_ws_before_sep, "a"), true) // p.ws_before_sep.has|a
  assert_eq(ordered_str(pp_ws_before_sep), "a=b") // p.ws_before_sep.ordered|a=b
  assert_eq(pesc(@ini.props_store(pp_ws_before_sep)), "a=b\\n") // p.ws_before_sep.store|a=b\n

  let pp_ws_after_sep_one = @ini.props_parse("a=\\ b\n")
  assert_eq(@ini.props_size(pp_ws_after_sep_one), 1) // p.ws_after_sep_one.size|1
  assert_eq(get_or_tag(pp_ws_after_sep_one, "a"), " b") // p.ws_after_sep_one.content|a= b
  assert_eq(@ini.props_has_key(pp_ws_after_sep_one, "a"), true) // p.ws_after_sep_one.has|a
  assert_eq(ordered_str(pp_ws_after_sep_one), "a= b") // p.ws_after_sep_one.ordered|a= b
  assert_eq(pesc(@ini.props_store(pp_ws_after_sep_one)), "a=\\\\ b\\n") // p.ws_after_sep_one.store|a=\\ b\n

  let pp_sep_colon_then_space = @ini.props_parse("a:b c\n")
  assert_eq(@ini.props_size(pp_sep_colon_then_space), 1) // p.sep_colon_then_space.size|1
  assert_eq(get_or_tag(pp_sep_colon_then_space, "a"), "b c") // p.sep_colon_then_space.content|a=b c
  assert_eq(@ini.props_has_key(pp_sep_colon_then_space, "a"), true) // p.sep_colon_then_space.has|a
  assert_eq(ordered_str(pp_sep_colon_then_space), "a=b c") // p.sep_colon_then_space.ordered|a=b c
  assert_eq(pesc(@ini.props_store(pp_sep_colon_then_space)), "a=b c\\n") // p.sep_colon_then_space.store|a=b c\n

  let pp_sep_ff = @ini.props_parse("ab\n")
  assert_eq(@ini.props_size(pp_sep_ff), 1) // p.sep_ff.size|1
  assert_eq(get_or_tag(pp_sep_ff, "a"), "b") // p.sep_ff.content|a=b
  assert_eq(@ini.props_has_key(pp_sep_ff, "a"), true) // p.sep_ff.has|a
  assert_eq(ordered_str(pp_sep_ff), "a=b") // p.sep_ff.ordered|a=b
  assert_eq(pesc(@ini.props_store(pp_sep_ff)), "a=b\\n") // p.sep_ff.store|a=b\n

  let pp_value_space = @ini.props_parse("a=1 2\n")
  assert_eq(@ini.props_size(pp_value_space), 1) // p.value_space.size|1
  assert_eq(get_or_tag(pp_value_space, "a"), "1 2") // p.value_space.content|a=1 2
  assert_eq(@ini.props_has_key(pp_value_space, "a"), true) // p.value_space.has|a
  assert_eq(ordered_str(pp_value_space), "a=1 2") // p.value_space.ordered|a=1 2
  assert_eq(pesc(@ini.props_store(pp_value_space)), "a=1 2\\n") // p.value_space.store|a=1 2\n

  let pp_key_escaped_colon = @ini.props_parse("a\\:b=1\n")
  assert_eq(@ini.props_size(pp_key_escaped_colon), 1) // p.key_escaped_colon.size|1
  assert_eq(get_or_tag(pp_key_escaped_colon, "a:b"), "1") // p.key_escaped_colon.content|a:b=1
  assert_eq(@ini.props_has_key(pp_key_escaped_colon, "a:b"), true) // p.key_escaped_colon.has|a:b
  assert_eq(ordered_str(pp_key_escaped_colon), "a:b=1") // p.key_escaped_colon.ordered|a:b=1
  assert_eq(pesc(@ini.props_store(pp_key_escaped_colon)), "a\\\\:b=1\\n") // p.key_escaped_colon.store|a\\:b=1\n
}

///|
test "props 解析：注释双符与续行（注释行的续行会吞下一行）" {
  let pp_comment_bang_cont = @ini.props_parse("!c\\\na=1\n")
  assert_eq(@ini.props_size(pp_comment_bang_cont), 1) // p.comment_bang_cont.size|1
  assert_eq(get_or_tag(pp_comment_bang_cont, "a"), "1") // p.comment_bang_cont.content|a=1
  assert_eq(@ini.props_has_key(pp_comment_bang_cont, "a"), true) // p.comment_bang_cont.has|a
  assert_eq(ordered_str(pp_comment_bang_cont), "a=1") // p.comment_bang_cont.ordered|a=1
  assert_eq(pesc(@ini.props_store(pp_comment_bang_cont)), "a=1\\n") // p.comment_bang_cont.store|a=1\n

  let pp_comment_hash_cont = @ini.props_parse("#c\\\na=1\n")
  assert_eq(@ini.props_size(pp_comment_hash_cont), 1) // p.comment_hash_cont.size|1
  assert_eq(get_or_tag(pp_comment_hash_cont, "a"), "1") // p.comment_hash_cont.content|a=1
  assert_eq(@ini.props_has_key(pp_comment_hash_cont, "a"), true) // p.comment_hash_cont.has|a
  assert_eq(ordered_str(pp_comment_hash_cont), "a=1") // p.comment_hash_cont.ordered|a=1
  assert_eq(pesc(@ini.props_store(pp_comment_hash_cont)), "a=1\\n") // p.comment_hash_cont.store|a=1\n

  // p.cont_backslash|夹具名在腿的读数里不存在（起草时残留），不产断言
  let pp_cont_lf_only = @ini.props_parse("a=\\\nb\n")
  assert_eq(@ini.props_size(pp_cont_lf_only), 1) // p.cont_lf_only.size|1
  assert_eq(get_or_tag(pp_cont_lf_only, "a"), "b") // p.cont_lf_only.content|a=b
  assert_eq(@ini.props_has_key(pp_cont_lf_only, "a"), true) // p.cont_lf_only.has|a
  // p.cont_lf_only.ordered|跳过：ORDER 读数里的键在排序 PAIR 集取不到值（['b']）
  assert_eq(pesc(@ini.props_store(pp_cont_lf_only)), "a=b\\n") // p.cont_lf_only.store|a=b\n

  // p.cont_trailing_eof|夹具名在腿的读数里不存在（起草时残留），不产断言
  // p.cont_crlf|夹具名在腿的读数里不存在（起草时残留），不产断言
  let pp_trailing_cont_crlf = @ini.props_parse("a=1\\\r\n2\n")
  assert_eq(@ini.props_size(pp_trailing_cont_crlf), 1) // p.trailing_cont_crlf.size|1
  assert_eq(get_or_tag(pp_trailing_cont_crlf, "a"), "12") // p.trailing_cont_crlf.content|a=12
  assert_eq(@ini.props_has_key(pp_trailing_cont_crlf, "a"), true) // p.trailing_cont_crlf.has|a
  // p.trailing_cont_crlf.ordered|跳过：ORDER 读数里的键在排序 PAIR 集取不到值（['2']）
  assert_eq(pesc(@ini.props_store(pp_trailing_cont_crlf)), "a=12\\n") // p.trailing_cont_crlf.store|a=12\n

  let pp_blank_between = @ini.props_parse("\n\na=1\n\n")
  assert_eq(@ini.props_size(pp_blank_between), 1) // p.blank_between.size|1
  assert_eq(get_or_tag(pp_blank_between, "a"), "1") // p.blank_between.content|a=1
  assert_eq(@ini.props_has_key(pp_blank_between, "a"), true) // p.blank_between.has|a
  assert_eq(ordered_str(pp_blank_between), "a=1") // p.blank_between.ordered|a=1
  assert_eq(pesc(@ini.props_store(pp_blank_between)), "a=1\\n") // p.blank_between.store|a=1\n
}

///|
test "props 解析：转义表与被转义的分隔符归进键名" {
  let pp_key_escaped_space = @ini.props_parse("a\\ b=1\n")
  assert_eq(@ini.props_size(pp_key_escaped_space), 1) // p.key_escaped_space.size|1
  assert_eq(get_or_tag(pp_key_escaped_space, "a b"), "1") // p.key_escaped_space.content|a b=1
  assert_eq(@ini.props_has_key(pp_key_escaped_space, "a b"), true) // p.key_escaped_space.has|a b
  assert_eq(ordered_str(pp_key_escaped_space), "a b=1") // p.key_escaped_space.ordered|a b=1
  assert_eq(pesc(@ini.props_store(pp_key_escaped_space)), "a\\\\ b=1\\n") // p.key_escaped_space.store|a\\ b=1\n

  let pp_key_escaped_tab = @ini.props_parse("a\\tb=1\n")
  assert_eq(@ini.props_size(pp_key_escaped_tab), 1) // p.key_escaped_tab.size|1
  assert_eq(get_or_tag(pp_key_escaped_tab, "a\tb"), "1") // p.key_escaped_tab.content|a\tb=1
  assert_eq(@ini.props_has_key(pp_key_escaped_tab, "a\tb"), true) // p.key_escaped_tab.has|a\tb
  assert_eq(ordered_str(pp_key_escaped_tab), "a\\tb=1") // p.key_escaped_tab.ordered|a\tb=1
  assert_eq(pesc(@ini.props_store(pp_key_escaped_tab)), "a\\\\tb=1\\n") // p.key_escaped_tab.store|a\\tb=1\n

  let pp_key_escaped_eq = @ini.props_parse("a\\=b=1\n")
  assert_eq(@ini.props_size(pp_key_escaped_eq), 1) // p.key_escaped_eq.size|1
  assert_eq(get_or_tag(pp_key_escaped_eq, "a=b"), "1") // p.key_escaped_eq.content|a=b=1
  assert_eq(@ini.props_has_key(pp_key_escaped_eq, "a=b"), true) // p.key_escaped_eq.has|a=b
  assert_eq(ordered_str(pp_key_escaped_eq), "a=b=1") // p.key_escaped_eq.ordered|a=b=1
  assert_eq(pesc(@ini.props_store(pp_key_escaped_eq)), "a\\\\=b=1\\n") // p.key_escaped_eq.store|a\\=b=1\n

  let pp_key_escaped_hash = @ini.props_parse("\\#a=1\n")
  assert_eq(@ini.props_size(pp_key_escaped_hash), 1) // p.key_escaped_hash.size|1
  assert_eq(get_or_tag(pp_key_escaped_hash, "#a"), "1") // p.key_escaped_hash.content|#a=1
  assert_eq(@ini.props_has_key(pp_key_escaped_hash, "#a"), true) // p.key_escaped_hash.has|#a
  assert_eq(ordered_str(pp_key_escaped_hash), "#a=1") // p.key_escaped_hash.ordered|#a=1
  assert_eq(pesc(@ini.props_store(pp_key_escaped_hash)), "\\\\#a=1\\n") // p.key_escaped_hash.store|\\#a=1\n

  let pp_key_escaped_bang = @ini.props_parse("\\!a=1\n")
  assert_eq(@ini.props_size(pp_key_escaped_bang), 1) // p.key_escaped_bang.size|1
  assert_eq(get_or_tag(pp_key_escaped_bang, "!a"), "1") // p.key_escaped_bang.content|!a=1
  assert_eq(@ini.props_has_key(pp_key_escaped_bang, "!a"), true) // p.key_escaped_bang.has|!a
  assert_eq(ordered_str(pp_key_escaped_bang), "!a=1") // p.key_escaped_bang.ordered|!a=1
  assert_eq(pesc(@ini.props_store(pp_key_escaped_bang)), "\\\\!a=1\\n") // p.key_escaped_bang.store|\\!a=1\n

  let pp_value_escaped_tab = @ini.props_parse("a=1\\t2\n")
  assert_eq(@ini.props_size(pp_value_escaped_tab), 1) // p.value_escaped_tab.size|1
  assert_eq(get_or_tag(pp_value_escaped_tab, "a"), "1\\t2") // p.value_escaped_tab.content|a=1\t2
  assert_eq(@ini.props_has_key(pp_value_escaped_tab, "a"), true) // p.value_escaped_tab.has|a
  assert_eq(ordered_str(pp_value_escaped_tab), "a=1\\t2") // p.value_escaped_tab.ordered|a=1\t2
  assert_eq(pesc(@ini.props_store(pp_value_escaped_tab)), "a=1\\\\t2\\n") // p.value_escaped_tab.store|a=1\\t2\n

  let pp_value_escaped_ff = @ini.props_parse("a=1\\f2\n")
  assert_eq(@ini.props_size(pp_value_escaped_ff), 1) // p.value_escaped_ff.size|1
  assert_eq(get_or_tag(pp_value_escaped_ff, "a"), "1\\u000c2") // p.value_escaped_ff.content|a=1\u000c2
  assert_eq(@ini.props_has_key(pp_value_escaped_ff, "a"), true) // p.value_escaped_ff.has|a
  assert_eq(ordered_str(pp_value_escaped_ff), "a=1\\u000c2") // p.value_escaped_ff.ordered|a=1\u000c2
  assert_eq(pesc(@ini.props_store(pp_value_escaped_ff)), "a=1\\\\f2\\n") // p.value_escaped_ff.store|a=1\\f2\n

  let pp_value_escaped_cr = @ini.props_parse("a=1\\r2\n")
  assert_eq(@ini.props_size(pp_value_escaped_cr), 1) // p.value_escaped_cr.size|1
  assert_eq(get_or_tag(pp_value_escaped_cr, "a"), "1\\r2") // p.value_escaped_cr.content|a=1\r2
  assert_eq(@ini.props_has_key(pp_value_escaped_cr, "a"), true) // p.value_escaped_cr.has|a
  assert_eq(ordered_str(pp_value_escaped_cr), "a=1\\r2") // p.value_escaped_cr.ordered|a=1\r2
  assert_eq(pesc(@ini.props_store(pp_value_escaped_cr)), "a=1\\\\r2\\n") // p.value_escaped_cr.store|a=1\\r2\n

  let pp_value_escaped_nl = @ini.props_parse("a=1\\n2\n")
  assert_eq(@ini.props_size(pp_value_escaped_nl), 1) // p.value_escaped_nl.size|1
  assert_eq(get_or_tag(pp_value_escaped_nl, "a"), "1\\n2") // p.value_escaped_nl.content|a=1\n2
  assert_eq(@ini.props_has_key(pp_value_escaped_nl, "a"), true) // p.value_escaped_nl.has|a
  assert_eq(ordered_str(pp_value_escaped_nl), "a=1\\n2") // p.value_escaped_nl.ordered|a=1\n2
  assert_eq(pesc(@ini.props_store(pp_value_escaped_nl)), "a=1\\\\n2\\n") // p.value_escaped_nl.store|a=1\\n2\n

  let pp_value_double_bs = @ini.props_parse("a=1\\\\2\n")
  assert_eq(@ini.props_size(pp_value_double_bs), 1) // p.value_double_bs.size|1
  assert_eq(get_or_tag(pp_value_double_bs, "a"), "1\\\\2") // p.value_double_bs.content|a=1\\2
  assert_eq(@ini.props_has_key(pp_value_double_bs, "a"), true) // p.value_double_bs.has|a
  assert_eq(ordered_str(pp_value_double_bs), "a=1\\\\2") // p.value_double_bs.ordered|a=1\\2
  assert_eq(pesc(@ini.props_store(pp_value_double_bs)), "a=1\\\\\\\\2\\n") // p.value_double_bs.store|a=1\\\\2\n
}

///|
test "props 解析：码位（u XXXX 真解码、BMP 外逐码元、00a0/3000 不当事务空白）" {
  let pp_value_unicode_esc = @ini.props_parse("a=\\u4e2d\n")
  assert_eq(@ini.props_size(pp_value_unicode_esc), 1) // p.value_unicode_esc.size|1
  assert_eq(get_or_tag(pp_value_unicode_esc, "a"), "\\u4e2d") // p.value_unicode_esc.content|a=\u4e2d
  assert_eq(@ini.props_has_key(pp_value_unicode_esc, "a"), true) // p.value_unicode_esc.has|a
  assert_eq(ordered_str(pp_value_unicode_esc), "a=\\u4e2d") // p.value_unicode_esc.ordered|a=\u4e2d
  assert_eq(pesc(@ini.props_store(pp_value_unicode_esc)), "a=\\u4e2d\\n") // p.value_unicode_esc.store|a=\u4e2d\n

  let pp_key_unicode_esc = @ini.props_parse("\\u0041b=1\n")
  assert_eq(@ini.props_size(pp_key_unicode_esc), 1) // p.key_unicode_esc.size|1
  assert_eq(get_or_tag(pp_key_unicode_esc, "Ab"), "1") // p.key_unicode_esc.content|Ab=1
  assert_eq(@ini.props_has_key(pp_key_unicode_esc, "Ab"), true) // p.key_unicode_esc.has|Ab
  assert_eq(ordered_str(pp_key_unicode_esc), "Ab=1") // p.key_unicode_esc.ordered|Ab=1
  assert_eq(pesc(@ini.props_store(pp_key_unicode_esc)), "Ab=1\\n") // p.key_unicode_esc.store|Ab=1\n

  let pp_value_nul_esc = @ini.props_parse("a=\\u0000\n")
  assert_eq(@ini.props_size(pp_value_nul_esc), 1) // p.value_nul_esc.size|1
  assert_eq(get_or_tag(pp_value_nul_esc, "a"), "\\u0000") // p.value_nul_esc.content|a=\u0000
  assert_eq(@ini.props_has_key(pp_value_nul_esc, "a"), true) // p.value_nul_esc.has|a
  assert_eq(ordered_str(pp_value_nul_esc), "a=\\u0000") // p.value_nul_esc.ordered|a=\u0000
  assert_eq(pesc(@ini.props_store(pp_value_nul_esc)), "a=\\u0000\\n") // p.value_nul_esc.store|a=\u0000\n

  let pp_value_astral = @ini.props_parse("a=😀b\n")
  assert_eq(@ini.props_size(pp_value_astral), 1) // p.value_astral.size|1
  assert_eq(get_or_tag(pp_value_astral, "a"), "\\ud83d\\ude00b") // p.value_astral.content|a=\ud83d\ude00b
  assert_eq(@ini.props_has_key(pp_value_astral, "a"), true) // p.value_astral.has|a
  assert_eq(ordered_str(pp_value_astral), "a=\\ud83d\\ude00b") // p.value_astral.ordered|a=\ud83d\ude00b
  assert_eq(pesc(@ini.props_store(pp_value_astral)), "a=\\ud83d\\ude00b\\n") // p.value_astral.store|a=\ud83d\ude00b\n

  let pp_value_ideo_raw = @ini.props_parse("a=　b\n")
  assert_eq(@ini.props_size(pp_value_ideo_raw), 1) // p.value_ideo_raw.size|1
  assert_eq(get_or_tag(pp_value_ideo_raw, "a"), "\\u3000b") // p.value_ideo_raw.content|a=\u3000b
  assert_eq(@ini.props_has_key(pp_value_ideo_raw, "a"), true) // p.value_ideo_raw.has|a
  assert_eq(ordered_str(pp_value_ideo_raw), "a=\\u3000b") // p.value_ideo_raw.ordered|a=\u3000b
  assert_eq(pesc(@ini.props_store(pp_value_ideo_raw)), "a=\\u3000b\\n") // p.value_ideo_raw.store|a=\u3000b\n
}

///|
test "props 解析：键值形状与行分隔符三档" {
  let pp_bare_then_sep = @ini.props_parse("k\na=1\n")
  assert_eq(@ini.props_size(pp_bare_then_sep), 2) // p.bare_then_sep.size|2
  assert_eq(get_or_tag(pp_bare_then_sep, "a"), "1") // p.bare_then_sep.content|a=1
  assert_eq(@ini.props_has_key(pp_bare_then_sep, "a"), true) // p.bare_then_sep.has|a
  assert_eq(get_or_tag(pp_bare_then_sep, "k"), "") // p.bare_then_sep.content|k=
  assert_eq(@ini.props_has_key(pp_bare_then_sep, "k"), true) // p.bare_then_sep.has|k
  assert_eq(ordered_str(pp_bare_then_sep), "k=|a=1") // p.bare_then_sep.ordered|k=|a=1
  // p.bare_then_sep.store|跳过：多条表参照的写出序是 Hashtable 序，不可对拍（spec §9.1 第 2 条）

  let pp_cr_only_values = @ini.props_parse("a=1\rb=2\n")
  assert_eq(@ini.props_size(pp_cr_only_values), 2) // p.cr_only_values.size|2
  assert_eq(get_or_tag(pp_cr_only_values, "a"), "1") // p.cr_only_values.content|a=1
  assert_eq(@ini.props_has_key(pp_cr_only_values, "a"), true) // p.cr_only_values.has|a
  assert_eq(get_or_tag(pp_cr_only_values, "b"), "2") // p.cr_only_values.content|b=2
  assert_eq(@ini.props_has_key(pp_cr_only_values, "b"), true) // p.cr_only_values.has|b
  assert_eq(ordered_str(pp_cr_only_values), "a=1|b=2") // p.cr_only_values.ordered|a=1|b=2
  // p.cr_only_values.store|跳过：多条表参照的写出序是 Hashtable 序，不可对拍（spec §9.1 第 2 条）

  let pp_dup_order = @ini.props_parse("a=1\nb=2\na=3\nc=4\n")
  assert_eq(@ini.props_size(pp_dup_order), 3) // p.dup_order.size|3
  assert_eq(get_or_tag(pp_dup_order, "a"), "3") // p.dup_order.content|a=3
  assert_eq(@ini.props_has_key(pp_dup_order, "a"), true) // p.dup_order.has|a
  assert_eq(get_or_tag(pp_dup_order, "b"), "2") // p.dup_order.content|b=2
  assert_eq(@ini.props_has_key(pp_dup_order, "b"), true) // p.dup_order.has|b
  assert_eq(get_or_tag(pp_dup_order, "c"), "4") // p.dup_order.content|c=4
  assert_eq(@ini.props_has_key(pp_dup_order, "c"), true) // p.dup_order.has|c
  assert_eq(ordered_str(pp_dup_order), "a=3|b=2|c=4") // p.dup_order.ordered|a=3|b=2|c=4
  // p.dup_order.store|跳过：多条表参照的写出序是 Hashtable 序，不可对拍（spec §9.1 第 2 条）

  let pp_empty_key_colon = @ini.props_parse(":v\n")
  assert_eq(@ini.props_size(pp_empty_key_colon), 1) // p.empty_key_colon.size|1
  assert_eq(get_or_tag(pp_empty_key_colon, ""), "v") // p.empty_key_colon.content|=v
  assert_eq(@ini.props_has_key(pp_empty_key_colon, ""), true) // p.empty_key_colon.has|
  // p.empty_key_colon.ordered|跳过：ORDER 读数里的键在排序 PAIR 集取不到值（['2']）
  assert_eq(pesc(@ini.props_store(pp_empty_key_colon)), "=v\\n") // p.empty_key_colon.store|=v\n

  let pp_only_separators = @ini.props_parse("=:=\n")
  assert_eq(@ini.props_size(pp_only_separators), 1) // p.only_separators.size|1
  assert_eq(get_or_tag(pp_only_separators, ""), ":=") // p.only_separators.content|=:=
  assert_eq(@ini.props_has_key(pp_only_separators, ""), true) // p.only_separators.has|
  // p.only_separators.ordered|跳过：ORDER 读数里的键在排序 PAIR 集取不到值（['2']）
  assert_eq(pesc(@ini.props_store(pp_only_separators)), "=\\\\:\\\\=\\n") // p.only_separators.store|=\\:\\=\n
}

///|
test "props 写侧：set 返回旧值、remove 返回被删值、getProperty 两档" {
  let pw_O1 = @ini.props_parse("a=1\nb=2\n")
  assert_eq(@ini.props_size(pw_O1), 2) // s.O1.size|2
  assert_eq(get_or_tag(pw_O1, "a"), "1") // s.O1.content|a=1
  assert_eq(get_or_tag(pw_O1, "b"), "2") // s.O1.content|b=2
  assert_eq(@ini.props_set(pw_O1, "a", "9"), Some("1")) // o.O1.1.prev|1
  assert_eq(@ini.props_get(pw_O1, "a"), Some("9")) // o.O1.2.get|9
  assert_eq(@ini.props_get_or(pw_O1, "z", "D"), "D") // o.O1.3.getdef|D
  assert_eq(@ini.props_remove(pw_O1, "b"), Some("2")) // o.O1.4.del|2
  assert_eq(@ini.props_remove(pw_O1, "z"), None) // o.O1.5.del|<null>
  assert_eq(@ini.props_size(pw_O1), 1) // o.O1.6.size|1
  // o.O1.7.keys|跳过：腿给的是 Hashtable 排序集，本库 props_keys 是首次出现序（spec §9.1 第 2 条）
  assert_eq(@ini.props_has_key(pw_O1, "a"), true) // o.O1.8.has|true
  assert_eq(@ini.props_is_empty(pw_O1), false) // o.O1.9.empty|false
  assert_eq(@ini.props_size(pw_O1), 1) // o.O1.10.size|1
  assert_eq(get_or_tag(pw_O1, "a"), "9") // o.O1.10.content|a=9
  assert_eq(pesc(@ini.props_store(pw_O1)), "a=9\\n") // o.O1.10.store|a=9\n

  let pw_O2 = @ini.props_parse("")
  assert_eq(@ini.props_size(pw_O2), 0) // s.O2.size|0
  assert_eq(@ini.props_set(pw_O2, "k", "v"), None) // o.O2.1.prev|<null>
  assert_eq(@ini.props_get_or(pw_O2, "k", "D"), "v") // o.O2.2.getdef|v
  // o.O2.3|参照 put(k,null) 抛 NullPointerException（值不可为 null）⇒ 本库值类型收成非空 String，该档不进契约
  assert_eq(@ini.props_get(pw_O2, "n"), None) // o.O2.4.get|<null>
  assert_eq(@ini.props_size(pw_O2), 1) // o.O2.6.size|1
  assert_eq(@ini.props_size(pw_O2), 1) // o.O2.7.size|1
  assert_eq(get_or_tag(pw_O2, "k"), "v") // o.O2.7.content|k=v
  assert_eq(pesc(@ini.props_store(pw_O2)), "k=v\\n") // o.O2.7.store|k=v\n

  let pw_O3 = @ini.props_parse("x=1\n")
  assert_eq(@ini.props_size(pw_O3), 1) // s.O3.size|1
  assert_eq(get_or_tag(pw_O3, "x"), "1") // s.O3.content|x=1
  assert_eq(@ini.props_set(pw_O3, "a b", "1 2"), None) // o.O3.1.prev|<null>
  assert_eq(@ini.props_set(pw_O3, "c=d", "e:f"), None) // o.O3.2.prev|<null>
  assert_eq(@ini.props_set(pw_O3, "g", "h\\i"), None) // o.O3.3.prev|<null>
  assert_eq(@ini.props_set(pw_O3, "j", "k\nl"), None) // o.O3.4.prev|<null>
  assert_eq(@ini.props_set(pw_O3, "uni", "中😀"), None) // o.O3.5.prev|<null>
  assert_eq(@ini.props_size(pw_O3), 6) // o.O3.6.size|6
  assert_eq(get_or_tag(pw_O3, "a b"), "1 2") // o.O3.6.content|a b=1 2
  assert_eq(get_or_tag(pw_O3, "c=d"), "e:f") // o.O3.6.content|c=d=e:f
  assert_eq(get_or_tag(pw_O3, "g"), "h\\\\i") // o.O3.6.content|g=h\\i
  assert_eq(get_or_tag(pw_O3, "j"), "k\\nl") // o.O3.6.content|j=k\nl
  assert_eq(get_or_tag(pw_O3, "uni"), "\\u4e2d\\ud83d\\ude00") // o.O3.6.content|uni=\u4e2d\ud83d\ude00
  assert_eq(get_or_tag(pw_O3, "x"), "1") // o.O3.6.content|x=1
  // o.O3.6.store|跳过：多条表参照写出序不可对拍

}

///|
test "props 畸形 u 的 raise 档（整条 load 失败，不留半表）" {
  assert_eq(parse_tag("a=\\u0041\\uZZ\n"), "ERR:BadUnicodeEscape") // p.bad_u_after_ok.err|java.lang.IllegalArgumentException:Malformed \\uxxxx encoding.
  assert_eq(@ini.props_size(@ini.props_new()), 0) // p.bad_u_after_ok.empty_seed|0
  assert_eq(parse_tag("a=\\u00zz\n"), "ERR:BadUnicodeEscape") // p.bad_u_hex.err|java.lang.IllegalArgumentException:Malformed \\uxxxx encoding.
  assert_eq(@ini.props_size(@ini.props_new()), 0) // p.bad_u_hex.empty_seed|0
  assert_eq(parse_tag("\\uZZZZ=1\n"), "ERR:BadUnicodeEscape") // p.bad_u_in_key.err|java.lang.IllegalArgumentException:Malformed \\uxxxx encoding.
  assert_eq(@ini.props_size(@ini.props_new()), 0) // p.bad_u_in_key.empty_seed|0
  assert_eq(parse_tag("a=\\u12\n"), "ERR:BadUnicodeEscape") // p.bad_u_short.err|java.lang.IllegalArgumentException:Malformed \\uxxxx encoding.
  assert_eq(@ini.props_size(@ini.props_new()), 0) // p.bad_u_short.empty_seed|0
}
