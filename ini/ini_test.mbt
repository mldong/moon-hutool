///|
// ini 第一批的期望值全部由生成脚本从参照腿灌入（手打零条）。
// 腿：真 hutool-setting-5.8.35.jar + hutool-core + hutool-log（`SettingLoader` 的静态 `Log` 字段在 log 件里）
//   + JDK 17.0.14；`javac -encoding UTF-8`；读数 612 + 366 + 139 = 1117 行（96 个输入 + 113 步容器操作 + 空白码位全表）。
// 分组解析走参照的真路径 `new SettingLoader(gm, UTF_8, isUseVariable)` + `load(InputStream)`，
//   序列化走它自己的 `private store(PrintWriter)`（反射取，腿在 Java 侧有 IO 不等于本库有 IO——公开面只有 String）。
// 空白码位表是**全 BMP 扫出来的**（`trim(c+"x"+c)=="x"` 与 `isBlank(c)` 两档读数逐位一致），不是抄规范。
// 参照的行分隔符是平台量（本机腿读数 `\r\n`），本库钉死 `\n`：期望值按 spec §4 末行口径做
//   "整串切 `\r\n` 再拼 `\n`"的变换，且腿读数里出现 `\r\r\n`（值尾带 CR 紧贴分隔符）的夹具**不对拍**，就地标注。

///|
// 与腿逐字同形的转义：CR/LF/TAB/反斜杠各写成两字符的转义串，其余不可打印与所有非 ASCII 写 \uXXXX；
// BMP 外码位展开成 UTF-16 代理对（腿用 charAt 逐码元，本库的 Char 是码位——不展开就会一个给 5 位十六进制）
fn esc(s : String) -> String {
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
fn escn(s : String?) -> String {
  match s {
    None => "<null>"
    Some(v) => esc(v)
  }
}

///|
fn joinx(a : Array[String], sep : String) -> String {
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
// 读形状用的两个转义器（本版匿名函数写法是 `fun`，箭头 `=>` 只在 match 里 ⇒ 全部走显式循环）
fn esc_all(a : Array[String]) -> Array[String] {
  let r : Array[String] = []
  for x in a {
    r.push(esc(x))
  }
  r
}

///|
fn escn_all(a : Array[String?]) -> Array[String] {
  let r : Array[String] = []
  for x in a {
    r.push(escn(x))
  }
  r
}

///|
// 读数形状（spec §4）：组顺序用 "|" 连，每组是 `转义组名?键=值,键=值`，值缺失档写 `<null>`
fn dmp(gm : @ini.GroupedMap) -> String {
  let parts : Array[String] = []
  for g in @ini.grouped_map_groups(gm) {
    let ep : Array[String] = []
    for kv in @ini.grouped_map_entries(gm, Some(g)) {
      ep.push(esc(kv.0) + "=" + escn(kv.1))
    }
    parts.push(esc(g) + "?" + joinx(ep, ","))
  }
  joinx(parts, "|")
}

///|
// 摊平读数形状：与 dmp 同一条 "|" / "=" 规则，只是键换成分组前缀形状
fn flat_str(gm : @ini.GroupedMap) -> String {
  let ep : Array[String] = []
  for kv in @ini.grouped_map_flatten(gm) {
    ep.push(esc(kv.0) + "=" + escn(kv.1))
  }
  joinx(ep, "|")
}

///|
test "ini 解析：注释、空行、切分与丢弃的行规则" {
  let gm_basic = @ini.ini_parse("name = value\nage=18\n")
  assert_eq(dmp(gm_basic), "?name=value,age=18") // i.basic.dmp|?name=value,age=18
  assert_eq(@ini.grouped_map_size(gm_basic), 2) // i.basic.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_basic)), [""]) // i.basic.groups|
  assert_eq(flat_str(gm_basic), "name=value|age=18") // i.basic.flat|name=value|age=18
  assert_eq(esc(@ini.ini_store(gm_basic)), "[]\\nname = value\\nage = 18\\n") // i.basic.store|[]\nname = value\nage = 18\n

  let gm_no_trim_inner = @ini.ini_parse("a=b c\n")
  assert_eq(dmp(gm_no_trim_inner), "?a=b c") // i.no_trim_inner.dmp|?a=b c
  assert_eq(@ini.grouped_map_size(gm_no_trim_inner), 1) // i.no_trim_inner.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_no_trim_inner)), [""]) // i.no_trim_inner.groups|
  assert_eq(flat_str(gm_no_trim_inner), "a=b c") // i.no_trim_inner.flat|a=b c
  assert_eq(esc(@ini.ini_store(gm_no_trim_inner)), "[]\\na = b c\\n") // i.no_trim_inner.store|[]\na = b c\n

  let gm_multi_eq = @ini.ini_parse("a=b=c=d\n")
  assert_eq(dmp(gm_multi_eq), "?a=b=c=d") // i.multi_eq.dmp|?a=b=c=d
  assert_eq(@ini.grouped_map_size(gm_multi_eq), 1) // i.multi_eq.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_multi_eq)), [""]) // i.multi_eq.groups|
  assert_eq(flat_str(gm_multi_eq), "a=b=c=d") // i.multi_eq.flat|a=b=c=d
  assert_eq(esc(@ini.ini_store(gm_multi_eq)), "[]\\na = b=c=d\\n") // i.multi_eq.store|[]\na = b=c=d\n

  let gm_empty_value = @ini.ini_parse("a=\n")
  assert_eq(dmp(gm_empty_value), "?a=") // i.empty_value.dmp|?a=
  assert_eq(@ini.grouped_map_size(gm_empty_value), 1) // i.empty_value.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_empty_value)), [""]) // i.empty_value.groups|
  assert_eq(flat_str(gm_empty_value), "a=") // i.empty_value.flat|a=
  assert_eq(esc(@ini.ini_store(gm_empty_value)), "[]\\na = \\n") // i.empty_value.store|[]\na = \n

  let gm_empty_key = @ini.ini_parse("=v\n")
  assert_eq(dmp(gm_empty_key), "?=v") // i.empty_key.dmp|?=v
  assert_eq(@ini.grouped_map_size(gm_empty_key), 1) // i.empty_key.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_empty_key)), [""]) // i.empty_key.groups|
  assert_eq(flat_str(gm_empty_key), "=v") // i.empty_key.flat|=v
  assert_eq(esc(@ini.ini_store(gm_empty_key)), "[]\\n = v\\n") // i.empty_key.store|[]\n = v\n

  let gm_no_assign = @ini.ini_parse("onlykey\n")
  assert_eq(dmp(gm_no_assign), "") // i.no_assign.dmp|
  assert_eq(@ini.grouped_map_size(gm_no_assign), 0) // i.no_assign.size|0
  assert_eq(esc_all(@ini.grouped_map_groups(gm_no_assign)), []) // i.no_assign.groups|
  assert_eq(flat_str(gm_no_assign), "") // i.no_assign.flat|
  assert_eq(esc(@ini.ini_store(gm_no_assign)), "") // i.no_assign.store|

  let gm_comment_hash = @ini.ini_parse("# c\na=1\n")
  assert_eq(dmp(gm_comment_hash), "?a=1") // i.comment_hash.dmp|?a=1
  assert_eq(@ini.grouped_map_size(gm_comment_hash), 1) // i.comment_hash.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_comment_hash)), [""]) // i.comment_hash.groups|
  assert_eq(flat_str(gm_comment_hash), "a=1") // i.comment_hash.flat|a=1
  assert_eq(esc(@ini.ini_store(gm_comment_hash)), "[]\\na = 1\\n") // i.comment_hash.store|[]\na = 1\n

  let gm_comment_indented = @ini.ini_parse("   # c\na=1\n")
  assert_eq(dmp(gm_comment_indented), "?a=1") // i.comment_indented.dmp|?a=1
  assert_eq(@ini.grouped_map_size(gm_comment_indented), 1) // i.comment_indented.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_comment_indented)), [""]) // i.comment_indented.groups|
  assert_eq(flat_str(gm_comment_indented), "a=1") // i.comment_indented.flat|a=1
  assert_eq(esc(@ini.ini_store(gm_comment_indented)), "[]\\na = 1\\n") // i.comment_indented.store|[]\na = 1\n

  let gm_comment_semi = @ini.ini_parse("; c\na=1\n")
  assert_eq(dmp(gm_comment_semi), "?a=1") // i.comment_semi.dmp|?a=1
  assert_eq(@ini.grouped_map_size(gm_comment_semi), 1) // i.comment_semi.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_comment_semi)), [""]) // i.comment_semi.groups|
  assert_eq(flat_str(gm_comment_semi), "a=1") // i.comment_semi.flat|a=1
  assert_eq(esc(@ini.ini_store(gm_comment_semi)), "[]\\na = 1\\n") // i.comment_semi.store|[]\na = 1\n

  let gm_comment_inline = @ini.ini_parse("a=1 # x\n")
  assert_eq(dmp(gm_comment_inline), "?a=1 # x") // i.comment_inline.dmp|?a=1 # x
  assert_eq(@ini.grouped_map_size(gm_comment_inline), 1) // i.comment_inline.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_comment_inline)), [""]) // i.comment_inline.groups|
  assert_eq(flat_str(gm_comment_inline), "a=1 # x") // i.comment_inline.flat|a=1 # x
  assert_eq(esc(@ini.ini_store(gm_comment_inline)), "[]\\na = 1 # x\\n") // i.comment_inline.store|[]\na = 1 # x\n

  let gm_blank_lines = @ini.ini_parse("\n\n   \n\t\na=1\n")
  assert_eq(dmp(gm_blank_lines), "?a=1") // i.blank_lines.dmp|?a=1
  assert_eq(@ini.grouped_map_size(gm_blank_lines), 1) // i.blank_lines.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_blank_lines)), [""]) // i.blank_lines.groups|
  assert_eq(flat_str(gm_blank_lines), "a=1") // i.blank_lines.flat|a=1
  assert_eq(esc(@ini.ini_store(gm_blank_lines)), "[]\\na = 1\\n") // i.blank_lines.store|[]\na = 1\n

  let gm_line_only_assign = @ini.ini_parse("=\n")
  assert_eq(dmp(gm_line_only_assign), "?=") // i.line_only_assign.dmp|?=
  assert_eq(@ini.grouped_map_size(gm_line_only_assign), 1) // i.line_only_assign.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_line_only_assign)), [""]) // i.line_only_assign.groups|
  assert_eq(flat_str(gm_line_only_assign), "=") // i.line_only_assign.flat|=
  assert_eq(esc(@ini.ini_store(gm_line_only_assign)), "[]\\n = \\n") // i.line_only_assign.store|[]\n = \n

  let gm_line_only_assigns = @ini.ini_parse("===\n")
  assert_eq(dmp(gm_line_only_assigns), "?===") // i.line_only_assigns.dmp|?===
  assert_eq(@ini.grouped_map_size(gm_line_only_assigns), 1) // i.line_only_assigns.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_line_only_assigns)), [""]) // i.line_only_assigns.groups|
  assert_eq(flat_str(gm_line_only_assigns), "===") // i.line_only_assigns.flat|===
  assert_eq(esc(@ini.ini_store(gm_line_only_assigns)), "[]\\n = ==\\n") // i.line_only_assigns.store|[]\n = ==\n

  let gm_key_ws_only = @ini.ini_parse("   =   \n")
  assert_eq(dmp(gm_key_ws_only), "?=") // i.key_ws_only.dmp|?=
  assert_eq(@ini.grouped_map_size(gm_key_ws_only), 1) // i.key_ws_only.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_key_ws_only)), [""]) // i.key_ws_only.groups|
  assert_eq(flat_str(gm_key_ws_only), "=") // i.key_ws_only.flat|=
  assert_eq(esc(@ini.ini_store(gm_key_ws_only)), "[]\\n = \\n") // i.key_ws_only.store|[]\n = \n

  let gm_key_blank_line = @ini.ini_parse("  =  v  \n")
  assert_eq(dmp(gm_key_blank_line), "?=v") // i.key_blank_line.dmp|?=v
  assert_eq(@ini.grouped_map_size(gm_key_blank_line), 1) // i.key_blank_line.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_key_blank_line)), [""]) // i.key_blank_line.groups|
  assert_eq(flat_str(gm_key_blank_line), "=v") // i.key_blank_line.flat|=v
  assert_eq(esc(@ini.ini_store(gm_key_blank_line)), "[]\\n = v\\n") // i.key_blank_line.store|[]\n = v\n

  let gm_trailing_no_nl = @ini.ini_parse("a=1")
  assert_eq(dmp(gm_trailing_no_nl), "?a=1") // i.trailing_no_nl.dmp|?a=1
  assert_eq(@ini.grouped_map_size(gm_trailing_no_nl), 1) // i.trailing_no_nl.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_trailing_no_nl)), [""]) // i.trailing_no_nl.groups|
  assert_eq(flat_str(gm_trailing_no_nl), "a=1") // i.trailing_no_nl.flat|a=1
  assert_eq(esc(@ini.ini_store(gm_trailing_no_nl)), "[]\\na = 1\\n") // i.trailing_no_nl.store|[]\na = 1\n

  let gm_value_tab_mid = @ini.ini_parse("a=x\ty\n")
  assert_eq(dmp(gm_value_tab_mid), "?a=x\\ty") // i.value_tab_mid.dmp|?a=x\ty
  assert_eq(@ini.grouped_map_size(gm_value_tab_mid), 1) // i.value_tab_mid.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_value_tab_mid)), [""]) // i.value_tab_mid.groups|
  assert_eq(flat_str(gm_value_tab_mid), "a=x\\ty") // i.value_tab_mid.flat|a=x\ty
  assert_eq(esc(@ini.ini_store(gm_value_tab_mid)), "[]\\na = x\\ty\\n") // i.value_tab_mid.store|[]\na = x\ty\n

  let gm_tab_around = @ini.ini_parse("\ta\t=\tb\t\n")
  assert_eq(dmp(gm_tab_around), "?a=b") // i.tab_around.dmp|?a=b
  assert_eq(@ini.grouped_map_size(gm_tab_around), 1) // i.tab_around.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_tab_around)), [""]) // i.tab_around.groups|
  assert_eq(flat_str(gm_tab_around), "a=b") // i.tab_around.flat|a=b
  assert_eq(esc(@ini.ini_store(gm_tab_around)), "[]\\na = b\\n") // i.tab_around.store|[]\na = b\n

  let gm_key_inner_space = @ini.ini_parse("a b = c d\n")
  assert_eq(dmp(gm_key_inner_space), "?a b=c d") // i.key_inner_space.dmp|?a b=c d
  assert_eq(@ini.grouped_map_size(gm_key_inner_space), 1) // i.key_inner_space.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_key_inner_space)), [""]) // i.key_inner_space.groups|
  assert_eq(flat_str(gm_key_inner_space), "a b=c d") // i.key_inner_space.flat|a b=c d
  assert_eq(esc(@ini.ini_store(gm_key_inner_space)), "[]\\na b = c d\\n") // i.key_inner_space.store|[]\na b = c d\n

  let gm_empty_text = @ini.ini_parse("")
  assert_eq(dmp(gm_empty_text), "") // i.empty_text.dmp|
  assert_eq(@ini.grouped_map_size(gm_empty_text), 0) // i.empty_text.size|0
  assert_eq(esc_all(@ini.grouped_map_groups(gm_empty_text)), []) // i.empty_text.groups|
  assert_eq(flat_str(gm_empty_text), "") // i.empty_text.flat|
  assert_eq(esc(@ini.ini_store(gm_empty_text)), "") // i.empty_text.store|
}

///|
test "ini 解析：分组行的判定、组顺序与组的出现时机" {
  let gm_group_basic = @ini.ini_parse("[g]\na=1\n")
  assert_eq(dmp(gm_group_basic), "g?a=1") // i.group_basic.dmp|g?a=1
  assert_eq(@ini.grouped_map_size(gm_group_basic), 1) // i.group_basic.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_group_basic)), ["g"]) // i.group_basic.groups|g
  assert_eq(flat_str(gm_group_basic), "g.a=1") // i.group_basic.flat|g.a=1
  assert_eq(esc(@ini.ini_store(gm_group_basic)), "[g]\\na = 1\\n") // i.group_basic.store|[g]\na = 1\n

  let gm_group_empty = @ini.ini_parse("[]\na=1\n")
  assert_eq(dmp(gm_group_empty), "?a=1") // i.group_empty.dmp|?a=1
  assert_eq(@ini.grouped_map_size(gm_group_empty), 1) // i.group_empty.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_group_empty)), [""]) // i.group_empty.groups|
  assert_eq(flat_str(gm_group_empty), "a=1") // i.group_empty.flat|a=1
  assert_eq(esc(@ini.ini_store(gm_group_empty)), "[]\\na = 1\\n") // i.group_empty.store|[]\na = 1\n

  let gm_group_spaces = @ini.ini_parse("[ g ]\na=1\n")
  assert_eq(dmp(gm_group_spaces), "g?a=1") // i.group_spaces.dmp|g?a=1
  assert_eq(@ini.grouped_map_size(gm_group_spaces), 1) // i.group_spaces.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_group_spaces)), ["g"]) // i.group_spaces.groups|g
  assert_eq(flat_str(gm_group_spaces), "g.a=1") // i.group_spaces.flat|g.a=1
  assert_eq(esc(@ini.ini_store(gm_group_spaces)), "[g]\\na = 1\\n") // i.group_spaces.store|[g]\na = 1\n

  let gm_group_open_only = @ini.ini_parse("[\na=1\n")
  assert_eq(dmp(gm_group_open_only), "?a=1") // i.group_open_only.dmp|?a=1
  assert_eq(@ini.grouped_map_size(gm_group_open_only), 1) // i.group_open_only.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_group_open_only)), [""]) // i.group_open_only.groups|
  assert_eq(flat_str(gm_group_open_only), "a=1") // i.group_open_only.flat|a=1
  assert_eq(esc(@ini.ini_store(gm_group_open_only)), "[]\\na = 1\\n") // i.group_open_only.store|[]\na = 1\n

  let gm_group_mixed = @ini.ini_parse("top=1\n[g]\nin=2\n[h]\nhk=3\n")
  assert_eq(dmp(gm_group_mixed), "?top=1|g?in=2|h?hk=3") // i.group_mixed.dmp|?top=1|g?in=2|h?hk=3
  assert_eq(@ini.grouped_map_size(gm_group_mixed), 3) // i.group_mixed.size|3
  assert_eq(esc_all(@ini.grouped_map_groups(gm_group_mixed)), ["", "g", "h"]) // i.group_mixed.groups||g|h
  assert_eq(flat_str(gm_group_mixed), "top=1|g.in=2|h.hk=3") // i.group_mixed.flat|top=1|g.in=2|h.hk=3
  assert_eq(
    esc(@ini.ini_store(gm_group_mixed)),
    "[]\\ntop = 1\\n[g]\\nin = 2\\n[h]\\nhk = 3\\n",
  ) // i.group_mixed.store|[]\ntop = 1\n[g]\nin = 2\n[h]\nhk = 3\n

  let gm_only_group = @ini.ini_parse("[g]\n")
  assert_eq(dmp(gm_only_group), "") // i.only_group.dmp|
  assert_eq(@ini.grouped_map_size(gm_only_group), 0) // i.only_group.size|0
  assert_eq(esc_all(@ini.grouped_map_groups(gm_only_group)), []) // i.only_group.groups|
  assert_eq(flat_str(gm_only_group), "") // i.only_group.flat|
  assert_eq(esc(@ini.ini_store(gm_only_group)), "") // i.only_group.store|

  let gm_group_then_empty_group = @ini.ini_parse("[g]\na=1\n[]\nb=2\n")
  assert_eq(dmp(gm_group_then_empty_group), "g?a=1|?b=2") // i.group_then_empty_group.dmp|g?a=1|?b=2
  assert_eq(@ini.grouped_map_size(gm_group_then_empty_group), 2) // i.group_then_empty_group.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_group_then_empty_group)), [
    "g", "",
  ]) // i.group_then_empty_group.groups|g|
  assert_eq(flat_str(gm_group_then_empty_group), "g.a=1|b=2") // i.group_then_empty_group.flat|g.a=1|b=2
  assert_eq(
    esc(@ini.ini_store(gm_group_then_empty_group)),
    "[g]\\na = 1\\n[]\\nb = 2\\n",
  ) // i.group_then_empty_group.store|[g]\na = 1\n[]\nb = 2\n

  let gm_ws_group = @ini.ini_parse("[  ]\na=1\n")
  assert_eq(dmp(gm_ws_group), "?a=1") // i.ws_group.dmp|?a=1
  assert_eq(@ini.grouped_map_size(gm_ws_group), 1) // i.ws_group.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_ws_group)), [""]) // i.ws_group.groups|
  assert_eq(flat_str(gm_ws_group), "a=1") // i.ws_group.flat|a=1
  assert_eq(esc(@ini.ini_store(gm_ws_group)), "[]\\na = 1\\n") // i.ws_group.store|[]\na = 1\n

  let gm_merge_default = @ini.ini_parse("x=1\n[  ]\ny=2\n")
  assert_eq(dmp(gm_merge_default), "?x=1,y=2") // i.merge_default.dmp|?x=1,y=2
  assert_eq(@ini.grouped_map_size(gm_merge_default), 2) // i.merge_default.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_merge_default)), [""]) // i.merge_default.groups|
  assert_eq(flat_str(gm_merge_default), "x=1|y=2") // i.merge_default.flat|x=1|y=2
  assert_eq(esc(@ini.ini_store(gm_merge_default)), "[]\\nx = 1\\ny = 2\\n") // i.merge_default.store|[]\nx = 1\ny = 2\n

  let gm_both_brackets = @ini.ini_parse("[a]=[b]\n")
  assert_eq(dmp(gm_both_brackets), "") // i.both_brackets.dmp|
  assert_eq(@ini.grouped_map_size(gm_both_brackets), 0) // i.both_brackets.size|0
  assert_eq(esc_all(@ini.grouped_map_groups(gm_both_brackets)), []) // i.both_brackets.groups|
  assert_eq(flat_str(gm_both_brackets), "") // i.both_brackets.flat|
  assert_eq(esc(@ini.ini_store(gm_both_brackets)), "") // i.both_brackets.store|

  let gm_value_brackets = @ini.ini_parse("[a]=b\n")
  assert_eq(dmp(gm_value_brackets), "?[a]=b") // i.value_brackets.dmp|?[a]=b
  assert_eq(@ini.grouped_map_size(gm_value_brackets), 1) // i.value_brackets.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_value_brackets)), [""]) // i.value_brackets.groups|
  assert_eq(flat_str(gm_value_brackets), "[a]=b") // i.value_brackets.flat|[a]=b
  assert_eq(esc(@ini.ini_store(gm_value_brackets)), "[]\\n[a] = b\\n") // i.value_brackets.store|[]\n[a] = b\n

  let gm_group_with_eq = @ini.ini_parse("[a=b]\nk=1\n")
  assert_eq(dmp(gm_group_with_eq), "a=b?k=1") // i.group_with_eq.dmp|a=b?k=1
  assert_eq(@ini.grouped_map_size(gm_group_with_eq), 1) // i.group_with_eq.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_group_with_eq)), ["a=b"]) // i.group_with_eq.groups|a=b
  assert_eq(flat_str(gm_group_with_eq), "a=b.k=1") // i.group_with_eq.flat|a=b.k=1
  assert_eq(esc(@ini.ini_store(gm_group_with_eq)), "[a=b]\\nk = 1\\n") // i.group_with_eq.store|[a=b]\nk = 1\n

  let gm_group_bracket_inner = @ini.ini_parse("[a[b]]\nk=1\n")
  assert_eq(dmp(gm_group_bracket_inner), "a[b]?k=1") // i.group_bracket_inner.dmp|a[b]?k=1
  assert_eq(@ini.grouped_map_size(gm_group_bracket_inner), 1) // i.group_bracket_inner.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_group_bracket_inner)), ["a[b]"]) // i.group_bracket_inner.groups|a[b]
  assert_eq(flat_str(gm_group_bracket_inner), "a[b].k=1") // i.group_bracket_inner.flat|a[b].k=1
  assert_eq(esc(@ini.ini_store(gm_group_bracket_inner)), "[a[b]]\\nk = 1\\n") // i.group_bracket_inner.store|[a[b]]\nk = 1\n

  let gm_group_chinese = @ini.ini_parse("[分组]内=k\n")
  assert_eq(dmp(gm_group_chinese), "?[\\u5206\\u7ec4]\\u5185=k") // i.group_chinese.dmp|?[\u5206\u7ec4]\u5185=k
  assert_eq(@ini.grouped_map_size(gm_group_chinese), 1) // i.group_chinese.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_group_chinese)), [""]) // i.group_chinese.groups|
  assert_eq(flat_str(gm_group_chinese), "[\\u5206\\u7ec4]\\u5185=k") // i.group_chinese.flat|[\u5206\u7ec4]\u5185=k
  assert_eq(
    esc(@ini.ini_store(gm_group_chinese)),
    "[]\\n[\\u5206\\u7ec4]\\u5185 = k\\n",
  ) // i.group_chinese.store|[]\n[\u5206\u7ec4]\u5185 = k\n

  let gm_group_reopen = @ini.ini_parse("[g]\na=1\n[h]\nb=2\n[g]\nc=3\n")
  assert_eq(dmp(gm_group_reopen), "g?a=1,c=3|h?b=2") // i.group_reopen.dmp|g?a=1,c=3|h?b=2
  assert_eq(@ini.grouped_map_size(gm_group_reopen), 3) // i.group_reopen.size|3
  assert_eq(esc_all(@ini.grouped_map_groups(gm_group_reopen)), ["g", "h"]) // i.group_reopen.groups|g|h
  assert_eq(flat_str(gm_group_reopen), "g.a=1|g.c=3|h.b=2") // i.group_reopen.flat|g.a=1|g.c=3|h.b=2
  assert_eq(
    esc(@ini.ini_store(gm_group_reopen)),
    "[g]\\na = 1\\nc = 3\\n[h]\\nb = 2\\n",
  ) // i.group_reopen.store|[g]\na = 1\nc = 3\n[h]\nb = 2\n

  let gm_group_three = @ini.ini_parse("[c]k=1\n[a]k=2\n[b]k=3\n")
  assert_eq(dmp(gm_group_three), "?[c]k=1,[a]k=2,[b]k=3") // i.group_three.dmp|?[c]k=1,[a]k=2,[b]k=3
  assert_eq(@ini.grouped_map_size(gm_group_three), 3) // i.group_three.size|3
  assert_eq(esc_all(@ini.grouped_map_groups(gm_group_three)), [""]) // i.group_three.groups|
  assert_eq(flat_str(gm_group_three), "[c]k=1|[a]k=2|[b]k=3") // i.group_three.flat|[c]k=1|[a]k=2|[b]k=3
  assert_eq(
    esc(@ini.ini_store(gm_group_three)),
    "[]\\n[c]k = 1\\n[a]k = 2\\n[b]k = 3\\n",
  ) // i.group_three.store|[]\n[c]k = 1\n[a]k = 2\n[b]k = 3\n

  let gm_group_order_swap = @ini.ini_parse("[b]x=1\n[a]y=2\n")
  assert_eq(dmp(gm_group_order_swap), "?[b]x=1,[a]y=2") // i.group_order_swap.dmp|?[b]x=1,[a]y=2
  assert_eq(@ini.grouped_map_size(gm_group_order_swap), 2) // i.group_order_swap.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_group_order_swap)), [""]) // i.group_order_swap.groups|
  assert_eq(flat_str(gm_group_order_swap), "[b]x=1|[a]y=2") // i.group_order_swap.flat|[b]x=1|[a]y=2
  assert_eq(
    esc(@ini.ini_store(gm_group_order_swap)),
    "[]\\n[b]x = 1\\n[a]y = 2\\n",
  ) // i.group_order_swap.store|[]\n[b]x = 1\n[a]y = 2\n

  let gm_dup_group = @ini.ini_parse("[g]\na=1\n[g]\na=2\n")
  assert_eq(dmp(gm_dup_group), "g?a=2") // i.dup_group.dmp|g?a=2
  assert_eq(@ini.grouped_map_size(gm_dup_group), 1) // i.dup_group.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_dup_group)), ["g"]) // i.dup_group.groups|g
  assert_eq(flat_str(gm_dup_group), "g.a=2") // i.dup_group.flat|g.a=2
  assert_eq(esc(@ini.ini_store(gm_dup_group)), "[g]\\na = 2\\n") // i.dup_group.store|[g]\na = 2\n
}

///|
test "ini 解析：键值剥边、空值与覆盖顺序" {
  let gm_dup_key = @ini.ini_parse("a=1\na=2\n")
  assert_eq(dmp(gm_dup_key), "?a=2") // i.dup_key.dmp|?a=2
  assert_eq(@ini.grouped_map_size(gm_dup_key), 1) // i.dup_key.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_dup_key)), [""]) // i.dup_key.groups|
  assert_eq(flat_str(gm_dup_key), "a=2") // i.dup_key.flat|a=2
  assert_eq(esc(@ini.ini_store(gm_dup_key)), "[]\\na = 2\\n") // i.dup_key.store|[]\na = 2\n

  let gm_dup_three = @ini.ini_parse("a=1\nb=2\na=3\nc=4\na=5\n")
  assert_eq(dmp(gm_dup_three), "?a=5,b=2,c=4") // i.dup_three.dmp|?a=5,b=2,c=4
  assert_eq(@ini.grouped_map_size(gm_dup_three), 3) // i.dup_three.size|3
  assert_eq(esc_all(@ini.grouped_map_groups(gm_dup_three)), [""]) // i.dup_three.groups|
  assert_eq(flat_str(gm_dup_three), "a=5|b=2|c=4") // i.dup_three.flat|a=5|b=2|c=4
  assert_eq(esc(@ini.ini_store(gm_dup_three)), "[]\\na = 5\\nb = 2\\nc = 4\\n") // i.dup_three.store|[]\na = 5\nb = 2\nc = 4\n

  let gm_val_blank_only = @ini.ini_parse("a=   \n")
  assert_eq(dmp(gm_val_blank_only), "?a=") // i.val_blank_only.dmp|?a=
  assert_eq(@ini.grouped_map_size(gm_val_blank_only), 1) // i.val_blank_only.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_val_blank_only)), [""]) // i.val_blank_only.groups|
  assert_eq(flat_str(gm_val_blank_only), "a=") // i.val_blank_only.flat|a=
  assert_eq(esc(@ini.ini_store(gm_val_blank_only)), "[]\\na = \\n") // i.val_blank_only.store|[]\na = \n

  let gm_val_nbsp_only = @ini.ini_parse("a= \n")
  assert_eq(dmp(gm_val_nbsp_only), "?a=") // i.val_nbsp_only.dmp|?a=
  assert_eq(@ini.grouped_map_size(gm_val_nbsp_only), 1) // i.val_nbsp_only.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_val_nbsp_only)), [""]) // i.val_nbsp_only.groups|
  assert_eq(flat_str(gm_val_nbsp_only), "a=") // i.val_nbsp_only.flat|a=
  assert_eq(esc(@ini.ini_store(gm_val_nbsp_only)), "[]\\na = \\n") // i.val_nbsp_only.store|[]\na = \n

  let gm_value_only_space = @ini.ini_parse("a=   \n")
  assert_eq(dmp(gm_value_only_space), "?a=") // i.value_only_space.dmp|?a=
  assert_eq(@ini.grouped_map_size(gm_value_only_space), 1) // i.value_only_space.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_value_only_space)), [""]) // i.value_only_space.groups|
  assert_eq(flat_str(gm_value_only_space), "a=") // i.value_only_space.flat|a=
  assert_eq(esc(@ini.ini_store(gm_value_only_space)), "[]\\na = \\n") // i.value_only_space.store|[]\na = \n

  let gm_blank_overwrite = @ini.ini_parse("a=1\na=  \n")
  assert_eq(dmp(gm_blank_overwrite), "?a=") // i.blank_overwrite.dmp|?a=
  assert_eq(@ini.grouped_map_size(gm_blank_overwrite), 1) // i.blank_overwrite.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_blank_overwrite)), [""]) // i.blank_overwrite.groups|
  assert_eq(flat_str(gm_blank_overwrite), "a=") // i.blank_overwrite.flat|a=
  assert_eq(esc(@ini.ini_store(gm_blank_overwrite)), "[]\\na = \\n") // i.blank_overwrite.store|[]\na = \n

  let gm_key_with_dot = @ini.ini_parse("a.b=1\n")
  assert_eq(dmp(gm_key_with_dot), "?a.b=1") // i.key_with_dot.dmp|?a.b=1
  assert_eq(@ini.grouped_map_size(gm_key_with_dot), 1) // i.key_with_dot.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_key_with_dot)), [""]) // i.key_with_dot.groups|
  assert_eq(flat_str(gm_key_with_dot), "a.b=1") // i.key_with_dot.flat|a.b=1
  assert_eq(esc(@ini.ini_store(gm_key_with_dot)), "[]\\na.b = 1\\n") // i.key_with_dot.store|[]\na.b = 1\n

  let gm_value_with_brackets = @ini.ini_parse("a=[b]\n")
  assert_eq(dmp(gm_value_with_brackets), "?a=[b]") // i.value_with_brackets.dmp|?a=[b]
  assert_eq(@ini.grouped_map_size(gm_value_with_brackets), 1) // i.value_with_brackets.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_value_with_brackets)), [""]) // i.value_with_brackets.groups|
  assert_eq(flat_str(gm_value_with_brackets), "a=[b]") // i.value_with_brackets.flat|a=[b]
  assert_eq(esc(@ini.ini_store(gm_value_with_brackets)), "[]\\na = [b]\\n") // i.value_with_brackets.store|[]\na = [b]\n

  let gm_value_with_colon = @ini.ini_parse("a=b:c\n")
  assert_eq(dmp(gm_value_with_colon), "?a=b:c") // i.value_with_colon.dmp|?a=b:c
  assert_eq(@ini.grouped_map_size(gm_value_with_colon), 1) // i.value_with_colon.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_value_with_colon)), [""]) // i.value_with_colon.groups|
  assert_eq(flat_str(gm_value_with_colon), "a=b:c") // i.value_with_colon.flat|a=b:c
  assert_eq(esc(@ini.ini_store(gm_value_with_colon)), "[]\\na = b:c\\n") // i.value_with_colon.store|[]\na = b:c\n

  let gm_deep_value = @ini.ini_parse(
    "a=zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz\n",
  )
  assert_eq(dmp(gm_deep_value), "?a=zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz") // i.deep_value.dmp|?a=zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
  assert_eq(@ini.grouped_map_size(gm_deep_value), 1) // i.deep_value.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_deep_value)), [""]) // i.deep_value.groups|
  assert_eq(
    flat_str(gm_deep_value),
    "a=zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",
  ) // i.deep_value.flat|a=zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
  assert_eq(
    esc(@ini.ini_store(gm_deep_value)),
    "[]\\na = zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz\\n",
  ) // i.deep_value.store|[]\na = zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz\n

  let gm_long_line = @ini.ini_parse(
    "k=vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\n",
  )
  assert_eq(
    dmp(gm_long_line),
    "?k=vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
  ) // i.long_line.dmp|?k=vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  assert_eq(@ini.grouped_map_size(gm_long_line), 1) // i.long_line.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_long_line)), [""]) // i.long_line.groups|
  assert_eq(
    flat_str(gm_long_line),
    "k=vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
  ) // i.long_line.flat|k=vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  assert_eq(
    esc(@ini.ini_store(gm_long_line)),
    "[]\\nk = vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\\n",
  ) // i.long_line.store|[]\nk = vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\n
}

///|
test "ini 解析：反斜杠与码位不参与语法（与 java.util.Properties 的分界）" {
  let gm_backslash = @ini.ini_parse("a=c:\\d\n")
  assert_eq(dmp(gm_backslash), "?a=c:\\\\d") // i.backslash.dmp|?a=c:\\d
  assert_eq(@ini.grouped_map_size(gm_backslash), 1) // i.backslash.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_backslash)), [""]) // i.backslash.groups|
  assert_eq(flat_str(gm_backslash), "a=c:\\\\d") // i.backslash.flat|a=c:\\d
  assert_eq(esc(@ini.ini_store(gm_backslash)), "[]\\na = c:\\\\d\\n") // i.backslash.store|[]\na = c:\\d\n

  let gm_unicode_escape = @ini.ini_parse("a=\\u4e2d\n")
  assert_eq(dmp(gm_unicode_escape), "?a=\\\\u4e2d") // i.unicode_escape.dmp|?a=\\u4e2d
  assert_eq(@ini.grouped_map_size(gm_unicode_escape), 1) // i.unicode_escape.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_unicode_escape)), [""]) // i.unicode_escape.groups|
  assert_eq(flat_str(gm_unicode_escape), "a=\\\\u4e2d") // i.unicode_escape.flat|a=\\u4e2d
  assert_eq(esc(@ini.ini_store(gm_unicode_escape)), "[]\\na = \\\\u4e2d\\n") // i.unicode_escape.store|[]\na = \\u4e2d\n

  let gm_esc_seq_value = @ini.ini_parse("a=\\nb\n")
  assert_eq(dmp(gm_esc_seq_value), "?a=\\\\nb") // i.esc_seq_value.dmp|?a=\\nb
  assert_eq(@ini.grouped_map_size(gm_esc_seq_value), 1) // i.esc_seq_value.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_esc_seq_value)), [""]) // i.esc_seq_value.groups|
  assert_eq(flat_str(gm_esc_seq_value), "a=\\\\nb") // i.esc_seq_value.flat|a=\\nb
  assert_eq(esc(@ini.ini_store(gm_esc_seq_value)), "[]\\na = \\\\nb\\n") // i.esc_seq_value.store|[]\na = \\nb\n

  let gm_nbsp = @ini.ini_parse("a= b\n")
  assert_eq(dmp(gm_nbsp), "?a=b") // i.nbsp.dmp|?a=b
  assert_eq(@ini.grouped_map_size(gm_nbsp), 1) // i.nbsp.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_nbsp)), [""]) // i.nbsp.groups|
  assert_eq(flat_str(gm_nbsp), "a=b") // i.nbsp.flat|a=b
  assert_eq(esc(@ini.ini_store(gm_nbsp)), "[]\\na = b\\n") // i.nbsp.store|[]\na = b\n

  let gm_val_nbsp_inner = @ini.ini_parse("a=x y\n")
  assert_eq(dmp(gm_val_nbsp_inner), "?a=x\\u00a0y") // i.val_nbsp_inner.dmp|?a=x\u00a0y
  assert_eq(@ini.grouped_map_size(gm_val_nbsp_inner), 1) // i.val_nbsp_inner.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_val_nbsp_inner)), [""]) // i.val_nbsp_inner.groups|
  assert_eq(flat_str(gm_val_nbsp_inner), "a=x\\u00a0y") // i.val_nbsp_inner.flat|a=x\u00a0y
  assert_eq(esc(@ini.ini_store(gm_val_nbsp_inner)), "[]\\na = x\\u00a0y\\n") // i.val_nbsp_inner.store|[]\na = x\u00a0y\n

  let gm_form_feed = @ini.ini_parse("a=b\n")
  assert_eq(dmp(gm_form_feed), "?a=b") // i.form_feed.dmp|?a=b
  assert_eq(@ini.grouped_map_size(gm_form_feed), 1) // i.form_feed.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_form_feed)), [""]) // i.form_feed.groups|
  assert_eq(flat_str(gm_form_feed), "a=b") // i.form_feed.flat|a=b
  assert_eq(esc(@ini.ini_store(gm_form_feed)), "[]\\na = b\\n") // i.form_feed.store|[]\na = b\n

  let gm_val_ideo_space = @ini.ini_parse("a=　b　\n")
  assert_eq(dmp(gm_val_ideo_space), "?a=b") // i.val_ideo_space.dmp|?a=b
  assert_eq(@ini.grouped_map_size(gm_val_ideo_space), 1) // i.val_ideo_space.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_val_ideo_space)), [""]) // i.val_ideo_space.groups|
  assert_eq(flat_str(gm_val_ideo_space), "a=b") // i.val_ideo_space.flat|a=b
  assert_eq(esc(@ini.ini_store(gm_val_ideo_space)), "[]\\na = b\\n") // i.val_ideo_space.store|[]\na = b\n

  let gm_bom_line = @ini.ini_parse("﻿a=1\n")
  assert_eq(dmp(gm_bom_line), "?a=1") // i.bom_line.dmp|?a=1
  assert_eq(@ini.grouped_map_size(gm_bom_line), 1) // i.bom_line.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_bom_line)), [""]) // i.bom_line.groups|
  assert_eq(flat_str(gm_bom_line), "a=1") // i.bom_line.flat|a=1
  assert_eq(esc(@ini.ini_store(gm_bom_line)), "[]\\na = 1\\n") // i.bom_line.store|[]\na = 1\n

  let gm_u2028_in_value = @ini.ini_parse("a=x y\n")
  assert_eq(dmp(gm_u2028_in_value), "?a=x\\u2028y") // i.u2028_in_value.dmp|?a=x\u2028y
  assert_eq(@ini.grouped_map_size(gm_u2028_in_value), 1) // i.u2028_in_value.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_u2028_in_value)), [""]) // i.u2028_in_value.groups|
  assert_eq(flat_str(gm_u2028_in_value), "a=x\\u2028y") // i.u2028_in_value.flat|a=x\u2028y
  assert_eq(esc(@ini.ini_store(gm_u2028_in_value)), "[]\\na = x\\u2028y\\n") // i.u2028_in_value.store|[]\na = x\u2028y\n

  let gm_u0085_in_value = @ini.ini_parse("a=xy\n")
  assert_eq(dmp(gm_u0085_in_value), "?a=x\\u0085y") // i.u0085_in_value.dmp|?a=x\u0085y
  assert_eq(@ini.grouped_map_size(gm_u0085_in_value), 1) // i.u0085_in_value.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_u0085_in_value)), [""]) // i.u0085_in_value.groups|
  assert_eq(flat_str(gm_u0085_in_value), "a=x\\u0085y") // i.u0085_in_value.flat|a=x\u0085y
  assert_eq(esc(@ini.ini_store(gm_u0085_in_value)), "[]\\na = x\\u0085y\\n") // i.u0085_in_value.store|[]\na = x\u0085y\n

  let gm_chinese = @ini.ini_parse("中文=值\n")
  assert_eq(dmp(gm_chinese), "?\\u4e2d\\u6587=\\u503c") // i.chinese.dmp|?\u4e2d\u6587=\u503c
  assert_eq(@ini.grouped_map_size(gm_chinese), 1) // i.chinese.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_chinese)), [""]) // i.chinese.groups|
  assert_eq(flat_str(gm_chinese), "\\u4e2d\\u6587=\\u503c") // i.chinese.flat|\u4e2d\u6587=\u503c
  assert_eq(esc(@ini.ini_store(gm_chinese)), "[]\\n\\u4e2d\\u6587 = \\u503c\\n") // i.chinese.store|[]\n\u4e2d\u6587 = \u503c\n

  let gm_unicode_mixed = @ini.ini_parse("éè=中文\n")
  assert_eq(dmp(gm_unicode_mixed), "?\\u00e9\\u00e8=\\u4e2d\\u6587") // i.unicode_mixed.dmp|?\u00e9\u00e8=\u4e2d\u6587
  assert_eq(@ini.grouped_map_size(gm_unicode_mixed), 1) // i.unicode_mixed.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_unicode_mixed)), [""]) // i.unicode_mixed.groups|
  assert_eq(flat_str(gm_unicode_mixed), "\\u00e9\\u00e8=\\u4e2d\\u6587") // i.unicode_mixed.flat|\u00e9\u00e8=\u4e2d\u6587
  assert_eq(
    esc(@ini.ini_store(gm_unicode_mixed)),
    "[]\\n\\u00e9\\u00e8 = \\u4e2d\\u6587\\n",
  ) // i.unicode_mixed.store|[]\n\u00e9\u00e8 = \u4e2d\u6587\n

  let gm_emoji_key = @ini.ini_parse("😀k=1\n")
  assert_eq(dmp(gm_emoji_key), "?\\ud83d\\ude00k=1") // i.emoji_key.dmp|?\ud83d\ude00k=1
  assert_eq(@ini.grouped_map_size(gm_emoji_key), 1) // i.emoji_key.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_emoji_key)), [""]) // i.emoji_key.groups|
  assert_eq(flat_str(gm_emoji_key), "\\ud83d\\ude00k=1") // i.emoji_key.flat|\ud83d\ude00k=1
  assert_eq(esc(@ini.ini_store(gm_emoji_key)), "[]\\n\\ud83d\\ude00k = 1\\n") // i.emoji_key.store|[]\n\ud83d\ude00k = 1\n

  let gm_emoji_value = @ini.ini_parse("a=x😀y\n")
  assert_eq(dmp(gm_emoji_value), "?a=x\\ud83d\\ude00y") // i.emoji_value.dmp|?a=x\ud83d\ude00y
  assert_eq(@ini.grouped_map_size(gm_emoji_value), 1) // i.emoji_value.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_emoji_value)), [""]) // i.emoji_value.groups|
  assert_eq(flat_str(gm_emoji_value), "a=x\\ud83d\\ude00y") // i.emoji_value.flat|a=x\ud83d\ude00y
  assert_eq(esc(@ini.ini_store(gm_emoji_value)), "[]\\na = x\\ud83d\\ude00y\\n") // i.emoji_value.store|[]\na = x\ud83d\ude00y\n
}

///|
test "ini 解析：行分隔符三档（LF / CRLF / 裸 CR）" {
  let gm_crlf_input = @ini.ini_parse("a=1\r\nb=2\r\n")
  assert_eq(dmp(gm_crlf_input), "?a=1,b=2") // i.crlf_input.dmp|?a=1,b=2
  assert_eq(@ini.grouped_map_size(gm_crlf_input), 2) // i.crlf_input.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_crlf_input)), [""]) // i.crlf_input.groups|
  assert_eq(flat_str(gm_crlf_input), "a=1|b=2") // i.crlf_input.flat|a=1|b=2
  assert_eq(esc(@ini.ini_store(gm_crlf_input)), "[]\\na = 1\\nb = 2\\n") // i.crlf_input.store|[]\na = 1\nb = 2\n

  let gm_lone_cr = @ini.ini_parse("a=1\rb=2\r")
  assert_eq(dmp(gm_lone_cr), "?a=1,b=2") // i.lone_cr.dmp|?a=1,b=2
  assert_eq(@ini.grouped_map_size(gm_lone_cr), 2) // i.lone_cr.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_lone_cr)), [""]) // i.lone_cr.groups|
  assert_eq(flat_str(gm_lone_cr), "a=1|b=2") // i.lone_cr.flat|a=1|b=2
  assert_eq(esc(@ini.ini_store(gm_lone_cr)), "[]\\na = 1\\nb = 2\\n") // i.lone_cr.store|[]\na = 1\nb = 2\n

  let gm_crlf_mixed = @ini.ini_parse("a=1\r\nb=2\rc=3\n")
  assert_eq(dmp(gm_crlf_mixed), "?a=1,b=2,c=3") // i.crlf_mixed.dmp|?a=1,b=2,c=3
  assert_eq(@ini.grouped_map_size(gm_crlf_mixed), 3) // i.crlf_mixed.size|3
  assert_eq(esc_all(@ini.grouped_map_groups(gm_crlf_mixed)), [""]) // i.crlf_mixed.groups|
  assert_eq(flat_str(gm_crlf_mixed), "a=1|b=2|c=3") // i.crlf_mixed.flat|a=1|b=2|c=3
  assert_eq(esc(@ini.ini_store(gm_crlf_mixed)), "[]\\na = 1\\nb = 2\\nc = 3\\n") // i.crlf_mixed.store|[]\na = 1\nb = 2\nc = 3\n
}

///|
test "ini 解析：变量替换（use_variable 打开）" {
  let gm_var_basic = @ini.ini_parse_with_opts("a=1\nb=${a}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_basic), "?a=1,b=1") // i.var_basic.dmp|?a=1,b=1
  assert_eq(@ini.grouped_map_size(gm_var_basic), 2) // i.var_basic.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_basic)), [""]) // i.var_basic.groups|
  assert_eq(flat_str(gm_var_basic), "a=1|b=1") // i.var_basic.flat|a=1|b=1
  assert_eq(esc(@ini.ini_store(gm_var_basic)), "[]\\na = 1\\nb = 1\\n") // i.var_basic.store|[]\na = 1\nb = 1\n

  let gm_var_same_group = @ini.ini_parse_with_opts("[g]\na=1\nb=${a}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_same_group), "g?a=1,b=1") // i.var_same_group.dmp|g?a=1,b=1
  assert_eq(@ini.grouped_map_size(gm_var_same_group), 2) // i.var_same_group.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_same_group)), ["g"]) // i.var_same_group.groups|g
  assert_eq(flat_str(gm_var_same_group), "g.a=1|g.b=1") // i.var_same_group.flat|g.a=1|g.b=1
  assert_eq(esc(@ini.ini_store(gm_var_same_group)), "[g]\\na = 1\\nb = 1\\n") // i.var_same_group.store|[g]\na = 1\nb = 1\n

  let gm_var_cross_group = @ini.ini_parse_with_opts(
    "[g]\na=1\n[h]\nb=${g.a}\n",
    @ini.IniParseOpts::{ use_variable: true, assign_flag: '=', },
  )
  assert_eq(dmp(gm_var_cross_group), "g?a=1|h?b=1") // i.var_cross_group.dmp|g?a=1|h?b=1
  assert_eq(@ini.grouped_map_size(gm_var_cross_group), 2) // i.var_cross_group.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_cross_group)), ["g", "h"]) // i.var_cross_group.groups|g|h
  assert_eq(flat_str(gm_var_cross_group), "g.a=1|h.b=1") // i.var_cross_group.flat|g.a=1|h.b=1
  assert_eq(
    esc(@ini.ini_store(gm_var_cross_group)),
    "[g]\\na = 1\\n[h]\\nb = 1\\n",
  ) // i.var_cross_group.store|[g]\na = 1\n[h]\nb = 1\n

  let gm_var_cross_missing = @ini.ini_parse_with_opts("[h]\nb=${g.a}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_cross_missing), "h?b=${g.a}") // i.var_cross_missing.dmp|h?b=${g.a}
  assert_eq(@ini.grouped_map_size(gm_var_cross_missing), 1) // i.var_cross_missing.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_cross_missing)), ["h"]) // i.var_cross_missing.groups|h
  assert_eq(flat_str(gm_var_cross_missing), "h.b=${g.a}") // i.var_cross_missing.flat|h.b=${g.a}
  assert_eq(esc(@ini.ini_store(gm_var_cross_missing)), "[h]\\nb = ${g.a}\\n") // i.var_cross_missing.store|[h]\nb = ${g.a}\n

  let gm_var_missing = @ini.ini_parse_with_opts("a=${nope}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_missing), "?a=${nope}") // i.var_missing.dmp|?a=${nope}
  assert_eq(@ini.grouped_map_size(gm_var_missing), 1) // i.var_missing.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_missing)), [""]) // i.var_missing.groups|
  assert_eq(flat_str(gm_var_missing), "a=${nope}") // i.var_missing.flat|a=${nope}
  assert_eq(esc(@ini.ini_store(gm_var_missing)), "[]\\na = ${nope}\\n") // i.var_missing.store|[]\na = ${nope}\n

  let gm_var_empty_inner = @ini.ini_parse_with_opts("a=${}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_empty_inner), "?a=${}") // i.var_empty_inner.dmp|?a=${}
  assert_eq(@ini.grouped_map_size(gm_var_empty_inner), 1) // i.var_empty_inner.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_empty_inner)), [""]) // i.var_empty_inner.groups|
  assert_eq(flat_str(gm_var_empty_inner), "a=${}") // i.var_empty_inner.flat|a=${}
  assert_eq(esc(@ini.ini_store(gm_var_empty_inner)), "[]\\na = ${}\\n") // i.var_empty_inner.store|[]\na = ${}\n

  let gm_var_twice = @ini.ini_parse_with_opts("a=x\nb=${a}${a}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_twice), "?a=x,b=xx") // i.var_twice.dmp|?a=x,b=xx
  assert_eq(@ini.grouped_map_size(gm_var_twice), 2) // i.var_twice.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_twice)), [""]) // i.var_twice.groups|
  assert_eq(flat_str(gm_var_twice), "a=x|b=xx") // i.var_twice.flat|a=x|b=xx
  assert_eq(esc(@ini.ini_store(gm_var_twice)), "[]\\na = x\\nb = xx\\n") // i.var_twice.store|[]\na = x\nb = xx\n

  let gm_var_spaced = @ini.ini_parse_with_opts("a=x\nb=${a} ${a}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_spaced), "?a=x,b=x x") // i.var_spaced.dmp|?a=x,b=x x
  assert_eq(@ini.grouped_map_size(gm_var_spaced), 2) // i.var_spaced.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_spaced)), [""]) // i.var_spaced.groups|
  assert_eq(flat_str(gm_var_spaced), "a=x|b=x x") // i.var_spaced.flat|a=x|b=x x
  assert_eq(esc(@ini.ini_store(gm_var_spaced)), "[]\\na = x\\nb = x x\\n") // i.var_spaced.store|[]\na = x\nb = x x\n

  let gm_var_prefix_collide = @ini.ini_parse_with_opts(
    "ab=2\na=1\nc=${a}-${ab}\n",
    @ini.IniParseOpts::{ use_variable: true, assign_flag: '=', },
  )
  assert_eq(dmp(gm_var_prefix_collide), "?ab=2,a=1,c=1-2") // i.var_prefix_collide.dmp|?ab=2,a=1,c=1-2
  assert_eq(@ini.grouped_map_size(gm_var_prefix_collide), 3) // i.var_prefix_collide.size|3
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_prefix_collide)), [""]) // i.var_prefix_collide.groups|
  assert_eq(flat_str(gm_var_prefix_collide), "ab=2|a=1|c=1-2") // i.var_prefix_collide.flat|ab=2|a=1|c=1-2
  assert_eq(
    esc(@ini.ini_store(gm_var_prefix_collide)),
    "[]\\nab = 2\\na = 1\\nc = 1-2\\n",
  ) // i.var_prefix_collide.store|[]\nab = 2\na = 1\nc = 1-2\n

  let gm_var_dotted_key = @ini.ini_parse_with_opts("g.a=1\nb=${g.a}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_dotted_key), "?g.a=1,b=1") // i.var_dotted_key.dmp|?g.a=1,b=1
  assert_eq(@ini.grouped_map_size(gm_var_dotted_key), 2) // i.var_dotted_key.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_dotted_key)), [""]) // i.var_dotted_key.groups|
  assert_eq(flat_str(gm_var_dotted_key), "g.a=1|b=1") // i.var_dotted_key.flat|g.a=1|b=1
  assert_eq(esc(@ini.ini_store(gm_var_dotted_key)), "[]\\ng.a = 1\\nb = 1\\n") // i.var_dotted_key.store|[]\ng.a = 1\nb = 1\n

  let gm_var_self_ref = @ini.ini_parse_with_opts("a=${a}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_self_ref), "?a=${a}") // i.var_self_ref.dmp|?a=${a}
  assert_eq(@ini.grouped_map_size(gm_var_self_ref), 1) // i.var_self_ref.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_self_ref)), [""]) // i.var_self_ref.groups|
  assert_eq(flat_str(gm_var_self_ref), "a=${a}") // i.var_self_ref.flat|a=${a}
  assert_eq(esc(@ini.ini_store(gm_var_self_ref)), "[]\\na = ${a}\\n") // i.var_self_ref.store|[]\na = ${a}\n

  let gm_var_forward_ref = @ini.ini_parse_with_opts("b=${a}\na=1\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_forward_ref), "?b=${a},a=1") // i.var_forward_ref.dmp|?b=${a},a=1
  assert_eq(@ini.grouped_map_size(gm_var_forward_ref), 2) // i.var_forward_ref.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_forward_ref)), [""]) // i.var_forward_ref.groups|
  assert_eq(flat_str(gm_var_forward_ref), "b=${a}|a=1") // i.var_forward_ref.flat|b=${a}|a=1
  assert_eq(esc(@ini.ini_store(gm_var_forward_ref)), "[]\\nb = ${a}\\na = 1\\n") // i.var_forward_ref.store|[]\nb = ${a}\na = 1\n

  let gm_var_undefined_keeps = @ini.ini_parse_with_opts("a=1-${x}-2\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_undefined_keeps), "?a=1-${x}-2") // i.var_undefined_keeps.dmp|?a=1-${x}-2
  assert_eq(@ini.grouped_map_size(gm_var_undefined_keeps), 1) // i.var_undefined_keeps.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_undefined_keeps)), [""]) // i.var_undefined_keeps.groups|
  assert_eq(flat_str(gm_var_undefined_keeps), "a=1-${x}-2") // i.var_undefined_keeps.flat|a=1-${x}-2
  assert_eq(esc(@ini.ini_store(gm_var_undefined_keeps)), "[]\\na = 1-${x}-2\\n") // i.var_undefined_keeps.store|[]\na = 1-${x}-2\n

  let gm_var_multi_dot = @ini.ini_parse_with_opts(
    "[g]\na=1\n[h]\nb=${g.a.b}\n",
    @ini.IniParseOpts::{ use_variable: true, assign_flag: '=', },
  )
  assert_eq(dmp(gm_var_multi_dot), "g?a=1|h?b=${g.a.b}") // i.var_multi_dot.dmp|g?a=1|h?b=${g.a.b}
  assert_eq(@ini.grouped_map_size(gm_var_multi_dot), 2) // i.var_multi_dot.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_multi_dot)), ["g", "h"]) // i.var_multi_dot.groups|g|h
  assert_eq(flat_str(gm_var_multi_dot), "g.a=1|h.b=${g.a.b}") // i.var_multi_dot.flat|g.a=1|h.b=${g.a.b}
  assert_eq(
    esc(@ini.ini_store(gm_var_multi_dot)),
    "[g]\\na = 1\\n[h]\\nb = ${g.a.b}\\n",
  ) // i.var_multi_dot.store|[g]\na = 1\n[h]\nb = ${g.a.b}\n

  let gm_var_in_group_name = @ini.ini_parse_with_opts(
    "[a.b]\nk=1\n[g]\nx=${a.b.k}\n",
    @ini.IniParseOpts::{ use_variable: true, assign_flag: '=', },
  )
  assert_eq(dmp(gm_var_in_group_name), "a.b?k=1|g?x=${a.b.k}") // i.var_in_group_name.dmp|a.b?k=1|g?x=${a.b.k}
  assert_eq(@ini.grouped_map_size(gm_var_in_group_name), 2) // i.var_in_group_name.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_in_group_name)), ["a.b", "g"]) // i.var_in_group_name.groups|a.b|g
  assert_eq(flat_str(gm_var_in_group_name), "a.b.k=1|g.x=${a.b.k}") // i.var_in_group_name.flat|a.b.k=1|g.x=${a.b.k}
  assert_eq(
    esc(@ini.ini_store(gm_var_in_group_name)),
    "[a.b]\\nk = 1\\n[g]\\nx = ${a.b.k}\\n",
  ) // i.var_in_group_name.store|[a.b]\nk = 1\n[g]\nx = ${a.b.k}\n

  let gm_var_blank_after_trim = @ini.ini_parse_with_opts("a=1\nb=${ a }\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_blank_after_trim), "?a=1,b=${ a }") // i.var_blank_after_trim.dmp|?a=1,b=${ a }
  assert_eq(@ini.grouped_map_size(gm_var_blank_after_trim), 2) // i.var_blank_after_trim.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_blank_after_trim)), [""]) // i.var_blank_after_trim.groups|
  assert_eq(flat_str(gm_var_blank_after_trim), "a=1|b=${ a }") // i.var_blank_after_trim.flat|a=1|b=${ a }
  assert_eq(
    esc(@ini.ini_store(gm_var_blank_after_trim)),
    "[]\\na = 1\\nb = ${ a }\\n",
  ) // i.var_blank_after_trim.store|[]\na = 1\nb = ${ a }\n

  let gm_var_partial = @ini.ini_parse_with_opts("a=1\nb=pre${a}post\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_partial), "?a=1,b=pre1post") // i.var_partial.dmp|?a=1,b=pre1post
  assert_eq(@ini.grouped_map_size(gm_var_partial), 2) // i.var_partial.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_partial)), [""]) // i.var_partial.groups|
  assert_eq(flat_str(gm_var_partial), "a=1|b=pre1post") // i.var_partial.flat|a=1|b=pre1post
  assert_eq(esc(@ini.ini_store(gm_var_partial)), "[]\\na = 1\\nb = pre1post\\n") // i.var_partial.store|[]\na = 1\nb = pre1post\n

  let gm_var_blank_value = @ini.ini_parse_with_opts("a=   \nb=${a}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_var_blank_value), "?a=,b=") // i.var_blank_value.dmp|?a=,b=
  assert_eq(@ini.grouped_map_size(gm_var_blank_value), 2) // i.var_blank_value.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_blank_value)), [""]) // i.var_blank_value.groups|
  assert_eq(flat_str(gm_var_blank_value), "a=|b=") // i.var_blank_value.flat|a=|b=
  assert_eq(esc(@ini.ini_store(gm_var_blank_value)), "[]\\na = \\nb = \\n") // i.var_blank_value.store|[]\na = \nb = \n

  let gm_nested_brace = @ini.ini_parse("a=x\nb=${a\n")
  assert_eq(dmp(gm_nested_brace), "?a=x,b=${a") // i.nested_brace.dmp|?a=x,b=${a
  assert_eq(@ini.grouped_map_size(gm_nested_brace), 2) // i.nested_brace.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_nested_brace)), [""]) // i.nested_brace.groups|
  assert_eq(flat_str(gm_nested_brace), "a=x|b=${a") // i.nested_brace.flat|a=x|b=${a
  assert_eq(esc(@ini.ini_store(gm_nested_brace)), "[]\\na = x\\nb = ${a\\n") // i.nested_brace.store|[]\na = x\nb = ${a\n

  let gm_brace_only = @ini.ini_parse_with_opts("a=}\nb=${a}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(dmp(gm_brace_only), "?a=},b=}") // i.brace_only.dmp|?a=},b=}
  assert_eq(@ini.grouped_map_size(gm_brace_only), 2) // i.brace_only.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_brace_only)), [""]) // i.brace_only.groups|
  assert_eq(flat_str(gm_brace_only), "a=}|b=}") // i.brace_only.flat|a=}|b=}
  assert_eq(esc(@ini.ini_store(gm_brace_only)), "[]\\na = }\\nb = }\\n") // i.brace_only.store|[]\na = }\nb = }\n

  let gm_var_system_prop_missing = @ini.ini_parse_with_opts(
    "a=${no.such.prop.xyz}\n",
    @ini.IniParseOpts::{ use_variable: true, assign_flag: '=', },
  )
  assert_eq(dmp(gm_var_system_prop_missing), "?a=${no.such.prop.xyz}") // i.var_system_prop_missing.dmp|?a=${no.such.prop.xyz}
  assert_eq(@ini.grouped_map_size(gm_var_system_prop_missing), 1) // i.var_system_prop_missing.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_system_prop_missing)), [""]) // i.var_system_prop_missing.groups|
  assert_eq(flat_str(gm_var_system_prop_missing), "a=${no.such.prop.xyz}") // i.var_system_prop_missing.flat|a=${no.such.prop.xyz}
  assert_eq(
    esc(@ini.ini_store(gm_var_system_prop_missing)),
    "[]\\na = ${no.such.prop.xyz}\\n",
  ) // i.var_system_prop_missing.store|[]\na = ${no.such.prop.xyz}\n
}

///|
test "ini 解析：选项面（assign_flag 与开关关闭档）" {
  let gm_assign_colon = @ini.ini_parse_with_opts("a:b\na=b\n", @ini.IniParseOpts::{
    use_variable: false,
    assign_flag: ':',
  })
  assert_eq(dmp(gm_assign_colon), "?a=b") // i.assign_colon.dmp|?a=b
  assert_eq(@ini.grouped_map_size(gm_assign_colon), 1) // i.assign_colon.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_assign_colon)), [""]) // i.assign_colon.groups|
  assert_eq(flat_str(gm_assign_colon), "a=b") // i.assign_colon.flat|a=b
  assert_eq(esc(@ini.ini_store(gm_assign_colon)), "[]\\na : b\\n") // i.assign_colon.store|[]\na : b\n

  let gm_var_assign_colon = @ini.ini_parse_with_opts("a=1\nb=${a}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: ':',
  })
  assert_eq(dmp(gm_var_assign_colon), "") // i.var_assign_colon.dmp|
  assert_eq(@ini.grouped_map_size(gm_var_assign_colon), 0) // i.var_assign_colon.size|0
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_assign_colon)), []) // i.var_assign_colon.groups|
  assert_eq(flat_str(gm_var_assign_colon), "") // i.var_assign_colon.flat|
  assert_eq(esc(@ini.ini_store(gm_var_assign_colon)), "") // i.var_assign_colon.store|

  let gm_var_no_flag = @ini.ini_parse("a=1\nb=${a}\n")
  assert_eq(dmp(gm_var_no_flag), "?a=1,b=${a}") // i.var_no_flag.dmp|?a=1,b=${a}
  assert_eq(@ini.grouped_map_size(gm_var_no_flag), 2) // i.var_no_flag.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_var_no_flag)), [""]) // i.var_no_flag.groups|
  assert_eq(flat_str(gm_var_no_flag), "a=1|b=${a}") // i.var_no_flag.flat|a=1|b=${a}
  assert_eq(esc(@ini.ini_store(gm_var_no_flag)), "[]\\na = 1\\nb = ${a}\\n") // i.var_no_flag.store|[]\na = 1\nb = ${a}\n

  let gm_assign_is_space = @ini.ini_parse_with_opts("a b c\n", @ini.IniParseOpts::{
    use_variable: false,
    assign_flag: ' ',
  })
  assert_eq(dmp(gm_assign_is_space), "?a=b c") // i.assign_is_space.dmp|?a=b c
  assert_eq(@ini.grouped_map_size(gm_assign_is_space), 1) // i.assign_is_space.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_assign_is_space)), [""]) // i.assign_is_space.groups|
  assert_eq(flat_str(gm_assign_is_space), "a=b c") // i.assign_is_space.flat|a=b c
  assert_eq(esc(@ini.ini_store(gm_assign_is_space)), "[]\\na   b c\\n") // i.assign_is_space.store|[]\na   b c\n

  let gm_assign_is_tab = @ini.ini_parse_with_opts("a\tb\tc\n", @ini.IniParseOpts::{
    use_variable: false,
    assign_flag: '\t',
  })
  assert_eq(dmp(gm_assign_is_tab), "?a=b\\tc") // i.assign_is_tab.dmp|?a=b\tc
  assert_eq(@ini.grouped_map_size(gm_assign_is_tab), 1) // i.assign_is_tab.size|1
  assert_eq(esc_all(@ini.grouped_map_groups(gm_assign_is_tab)), [""]) // i.assign_is_tab.groups|
  assert_eq(flat_str(gm_assign_is_tab), "a=b\\tc") // i.assign_is_tab.flat|a=b\tc
  assert_eq(esc(@ini.ini_store(gm_assign_is_tab)), "[]\\na \\t b\\tc\\n") // i.assign_is_tab.store|[]\na \t b\tc\n
}

///|
test "GroupedMap：返回值、插入顺序与后写覆盖" {
  let m_S1 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S1, Some("g"), "a", Some("1")), None) // o.S1.1.prev|<null>
  assert_eq(@ini.grouped_map_put(m_S1, Some("g"), "b", Some("2")), None) // o.S1.2.prev|<null>
  assert_eq(@ini.grouped_map_put(m_S1, Some("g"), "a", Some("9")), Some("1")) // o.S1.3.prev|1
  assert_eq(@ini.grouped_map_get(m_S1, Some("g"), "a"), Some("9")) // o.S1.4.val|9
  assert_eq(@ini.grouped_map_get(m_S1, Some("g"), "z"), None) // o.S1.5.val|<null>
  assert_eq(@ini.grouped_map_get(m_S1, Some("zz"), "a"), None) // o.S1.6.val|<null>
  assert_eq(@ini.grouped_map_size(m_S1), 2) // o.S1.7.size|2
  assert_eq(dmp(m_S1), "g?a=9,b=2") // o.S1.8.dmp|g?a=9,b=2
  assert_eq(@ini.grouped_map_size(m_S1), 2) // o.S1.8.size|2
  assert_eq(esc(@ini.ini_store(m_S1)), "[g]\\na = 9\\nb = 2\\n") // o.S1.8.store|[g]\na = 9\nb = 2\n

  let m_S10 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S10, Some("g1"), "k", Some("v1")), None) // o.S10.1.prev|<null>
  assert_eq(@ini.grouped_map_put(m_S10, Some("g2"), "k", Some("v2")), None) // o.S10.2.prev|<null>
  assert_eq(@ini.grouped_map_get(m_S10, Some("g1"), "k"), Some("v1")) // o.S10.3.val|v1
  assert_eq(@ini.grouped_map_get(m_S10, Some("g2"), "k"), Some("v2")) // o.S10.4.val|v2
  assert_eq(esc_all(@ini.grouped_map_groups(m_S10)), ["g1", "g2"]) // o.S10.5.groups|g1|g2
  assert_eq(@ini.grouped_map_size(m_S10), 2) // o.S10.6.size|2

  let m_S9 = @ini.grouped_map_new()
  @ini.grouped_map_put_all(m_S9, Some("g"), [("a", Some("1")), ("b", Some("2"))]) // o.S9.1.put_all|ok
  assert_eq(esc_all(@ini.grouped_map_keys(m_S9, Some("g"))), ["a", "b"]) // o.S9.2.keys|a|b
  assert_eq(@ini.grouped_map_size(m_S9), 2) // o.S9.3.size|2
  assert_eq(@ini.grouped_map_remove(m_S9, Some("g"), "a"), Some("1")) // o.S9.4.del|1
  assert_eq(@ini.grouped_map_remove(m_S9, Some("g"), "b"), Some("2")) // o.S9.5.del|2
  assert_eq(esc_all(@ini.grouped_map_keys(m_S9, Some("g"))), []) // o.S9.6.keys|
  assert_eq(@ini.grouped_map_size(m_S9), 2) // o.S9.7.size|2
  assert_eq(@ini.grouped_map_is_empty(m_S9), false) // o.S9.8.is_empty|false
}

///|
test "GroupedMap：组名的空串兜底与 get 不剥边" {
  let m_S2 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S2, Some(" x "), "k", Some("v")), None) // o.S2.1.prev|<null>
  assert_eq(esc_all(@ini.grouped_map_groups(m_S2)), ["x"]) // o.S2.2.groups|x
  assert_eq(@ini.grouped_map_get(m_S2, Some(" x "), "k"), None) // o.S2.3.val|<null>
  assert_eq(@ini.grouped_map_get(m_S2, Some("x"), "k"), Some("v")) // o.S2.4.val|v
  assert_eq(@ini.grouped_map_contains_key(m_S2, Some(" x "), "k"), true) // o.S2.5.has_key|true
  assert_eq(@ini.grouped_map_contains_value(m_S2, Some(" x "), Some("v")), true) // o.S2.6.has_value|true
  assert_eq(@ini.grouped_map_contains_value(m_S2, Some("x"), Some("v")), true) // o.S2.7.has_value|true
  assert_eq(@ini.grouped_map_contains_value(m_S2, Some("x"), Some("z")), false) // o.S2.8.has_value|false
  assert_eq(@ini.grouped_map_contains_value(m_S2, Some("q"), Some("v")), false) // o.S2.9.has_value|false
  assert_eq(esc_all(@ini.grouped_map_keys(m_S2, Some(" x "))), ["k"]) // o.S2.10.keys|k
  assert_eq(@ini.grouped_map_remove(m_S2, Some(" x "), "k"), Some("v")) // o.S2.11.del|v
  assert_eq(@ini.grouped_map_get(m_S2, Some("x"), "k"), None) // o.S2.12.val|<null>
  assert_eq(esc_all(@ini.grouped_map_groups(m_S2)), ["x"]) // o.S2.13.groups|x
  assert_eq(@ini.grouped_map_size(m_S2), 0) // o.S2.14.size|0
  assert_eq(escn_all(@ini.grouped_map_values(m_S2, Some("x"))), []) // o.S2.15.values|

  let m_S5 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S5, None, "a", Some("1")), None) // o.S5.1.prev|<null>
  assert_eq(esc_all(@ini.grouped_map_groups(m_S5)), [""]) // o.S5.2.groups|
  assert_eq(@ini.grouped_map_get(m_S5, Some(""), "a"), Some("1")) // o.S5.3.val|1
  assert_eq(@ini.grouped_map_put(m_S5, Some(""), "b", Some("2")), None) // o.S5.4.prev|<null>
  assert_eq(esc_all(@ini.grouped_map_groups(m_S5)), [""]) // o.S5.5.groups|
  assert_eq(@ini.grouped_map_size(m_S5), 2) // o.S5.6.size|2

  let m_S6 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S6, Some(""), "k", Some("v")), None) // o.S6.1.prev|<null>
  assert_eq(esc_all(@ini.grouped_map_groups(m_S6)), [""]) // o.S6.2.groups|
  assert_eq(@ini.grouped_map_get(m_S6, None, "k"), Some("v")) // o.S6.3.val|v
  assert_eq(@ini.grouped_map_contains_key(m_S6, None, "k"), true) // o.S6.4.has_key|true

  let m_S7 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S7, Some("  "), "a", Some("1")), None) // o.S7.1.prev|<null>
  assert_eq(esc_all(@ini.grouped_map_groups(m_S7)), [""]) // o.S7.2.groups|
  assert_eq(@ini.grouped_map_put(m_S7, Some(""), "b", Some("2")), None) // o.S7.3.prev|<null>
  assert_eq(esc_all(@ini.grouped_map_groups(m_S7)), [""]) // o.S7.4.groups|
  assert_eq(@ini.grouped_map_size(m_S7), 2) // o.S7.5.size|2
}

///|
test "GroupedMap：总条数缓存的陈旧读数" {
  let m_S3 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S3, Some("g"), "a", Some("1")), None) // o.S3.1.prev|<null>
  assert_eq(@ini.grouped_map_put(m_S3, Some("g"), "b", Some("2")), None) // o.S3.2.prev|<null>
  assert_eq(@ini.grouped_map_size(m_S3), 2) // o.S3.3.size|2
  assert_eq(@ini.grouped_map_remove(m_S3, Some("g"), "a"), Some("1")) // o.S3.4.del|1
  assert_eq(@ini.grouped_map_size(m_S3), 2) // o.S3.5.size|2
  assert_eq(esc_all(@ini.grouped_map_keys(m_S3, Some("g"))), ["b"]) // o.S3.6.keys|b
  assert_eq(@ini.grouped_map_is_empty(m_S3), false) // o.S3.7.is_empty|false

  let m_S4 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S4, Some("g"), "a", Some("1")), None) // o.S4.1.prev|<null>
  @ini.grouped_map_clear_group(m_S4, Some("g")) // o.S4.2.clear|ok
  assert_eq(esc_all(@ini.grouped_map_groups(m_S4)), ["g"]) // o.S4.3.groups|g
  assert_eq(esc_all(@ini.grouped_map_keys(m_S4, Some("g"))), []) // o.S4.4.keys|
  assert_eq(@ini.grouped_map_size(m_S4), 0) // o.S4.5.size|0
  assert_eq(@ini.grouped_map_is_group_empty(m_S4, Some("g")), true) // o.S4.6.is_group_empty|true
  assert_eq(@ini.grouped_map_is_empty(m_S4), true) // o.S4.7.is_empty|true

  let m_S8 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_size(m_S8), 0) // o.S8.1.size|0
  assert_eq(@ini.grouped_map_put(m_S8, Some("g"), "a", Some("1")), None) // o.S8.2.prev|<null>
  assert_eq(@ini.grouped_map_size(m_S8), 1) // o.S8.3.size|1
  assert_eq(@ini.grouped_map_put(m_S8, Some("g"), "b", Some("2")), None) // o.S8.4.prev|<null>
  assert_eq(@ini.grouped_map_size(m_S8), 2) // o.S8.5.size|2
  assert_eq(@ini.grouped_map_remove(m_S8, Some("g"), "b"), Some("2")) // o.S8.6.del|2
  assert_eq(@ini.grouped_map_size(m_S8), 2) // o.S8.7.size|2
  assert_eq(@ini.grouped_map_put(m_S8, Some("h"), "c", Some("3")), None) // o.S8.8.prev|<null>
  assert_eq(@ini.grouped_map_size(m_S8), 2) // o.S8.9.size|2

  let m_S13 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S13, Some("g"), "a", Some("1")), None) // o.S13.1.prev|<null>
  assert_eq(@ini.grouped_map_remove(m_S13, Some("g"), "a"), Some("1")) // o.S13.2.del|1
  assert_eq(@ini.grouped_map_size(m_S13), 0) // o.S13.3.size|0
  assert_eq(@ini.grouped_map_is_empty(m_S13), true) // o.S13.4.is_empty|true
  assert_eq(esc_all(@ini.grouped_map_groups(m_S13)), ["g"]) // o.S13.5.groups|g

  let m_S9 = @ini.grouped_map_new()
  @ini.grouped_map_put_all(m_S9, Some("g"), [("a", Some("1")), ("b", Some("2"))]) // o.S9.1.put_all|ok
  assert_eq(esc_all(@ini.grouped_map_keys(m_S9, Some("g"))), ["a", "b"]) // o.S9.2.keys|a|b
  assert_eq(@ini.grouped_map_size(m_S9), 2) // o.S9.3.size|2
  assert_eq(@ini.grouped_map_remove(m_S9, Some("g"), "a"), Some("1")) // o.S9.4.del|1
  assert_eq(@ini.grouped_map_remove(m_S9, Some("g"), "b"), Some("2")) // o.S9.5.del|2
  assert_eq(esc_all(@ini.grouped_map_keys(m_S9, Some("g"))), []) // o.S9.6.keys|
  assert_eq(@ini.grouped_map_size(m_S9), 2) // o.S9.7.size|2
  assert_eq(@ini.grouped_map_is_empty(m_S9), false) // o.S9.8.is_empty|false
}

///|
test "GroupedMap：缺组缺键档与 null 值档" {
  let m_S14 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_remove(m_S14, Some("g"), "a"), None) // o.S14.1.del|<null>
  assert_eq(@ini.grouped_map_size(m_S14), 0) // o.S14.2.size|0
  @ini.grouped_map_clear_group(m_S14, Some("nope")) // o.S14.3.clear|ok
  assert_eq(esc_all(@ini.grouped_map_groups(m_S14)), []) // o.S14.4.groups|
  assert_eq(esc_all(@ini.grouped_map_keys(m_S14, Some("nope"))), []) // o.S14.5.keys|
  assert_eq(escn_all(@ini.grouped_map_values(m_S14, Some("nope"))), []) // o.S14.6.values|
  assert_eq(@ini.grouped_map_is_group_empty(m_S14, None), true) // o.S14.7.is_group_empty|true
  // o.S14.8|参照键可为 null（Java 引用），本库键类型是 String ⇒ 该档不进契约

  let m_S12 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S12, Some("g"), "a", None), None) // o.S12.1.prev|<null>
  assert_eq(@ini.grouped_map_get(m_S12, Some("g"), "a"), None) // o.S12.2.val|<null>
  assert_eq(@ini.grouped_map_size(m_S12), 1) // o.S12.3.size|1
  assert_eq(@ini.grouped_map_contains_value(m_S12, Some("g"), None), true) // o.S12.4.has_value|true
  assert_eq(@ini.grouped_map_contains_key(m_S12, Some("g"), "a"), true) // o.S12.5.has_key|true
  assert_eq(escn_all(@ini.grouped_map_values(m_S12, Some("g"))), ["<null>"]) // o.S12.6.values|<null>
  assert_eq(dmp(m_S12), "g?a=<null>") // o.S12.7.dmp|g?a=<null>
  assert_eq(@ini.grouped_map_size(m_S12), 1) // o.S12.7.size|1
  assert_eq(esc(@ini.ini_store(m_S12)), "[g]\\na = null\\n") // o.S12.7.store|[g]\na = null\n

  let m_S11 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S11, Some("g"), " k ", Some("v")), None) // o.S11.1.prev|<null>
  assert_eq(esc_all(@ini.grouped_map_keys(m_S11, Some("g"))), [" k "]) // o.S11.2.keys| k 
  assert_eq(@ini.grouped_map_get(m_S11, Some("g"), "k"), None) // o.S11.3.val|<null>
  assert_eq(@ini.grouped_map_get(m_S11, Some("g"), " k "), Some("v")) // o.S11.4.val|v
  assert_eq(@ini.grouped_map_size(m_S11), 1) // o.S11.5.size|1
}

///|
test "ini_store：写侧不转义的坏形状" {
  let m_S15 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S15, Some("g"), "a", None), None) // o.S15.1.prev|<null>
  assert_eq(@ini.grouped_map_put(m_S15, Some("g"), "nl", Some("x\ny")), None) // o.S15.2.prev|<null>
  assert_eq(@ini.grouped_map_put(m_S15, Some("g"), "cr", Some("x\ry")), None) // o.S15.3.prev|<null>
  assert_eq(@ini.grouped_map_put(m_S15, Some("g"), "eq", Some("a=b")), None) // o.S15.4.prev|<null>
  assert_eq(@ini.grouped_map_put(m_S15, Some("g"), "sp", Some(" x ")), None) // o.S15.5.prev|<null>
  assert_eq(@ini.grouped_map_put(m_S15, Some("g"), "uni", Some("中文")), None) // o.S15.6.prev|<null>
  assert_eq(@ini.grouped_map_put(m_S15, Some(""), "bare", Some("1")), None) // o.S15.7.prev|<null>
  assert_eq(@ini.grouped_map_put(m_S15, Some("a]b"), "k", Some("1")), None) // o.S15.8.prev|<null>
  assert_eq(@ini.grouped_map_put(m_S15, Some("g"), "empty", Some("")), None) // o.S15.9.prev|<null>
  assert_eq(
    dmp(m_S15),
    "g?a=<null>,nl=x\\ny,cr=x\\ry,eq=a=b,sp= x ,uni=\\u4e2d\\u6587,empty=|?bare=1|a]b?k=1",
  ) // o.S15.10.dmp|g?a=<null>,nl=x\ny,cr=x\ry,eq=a=b,sp= x ,uni=\u4e2d\u6587,empty=|?bare=1|a]b?k=1
  assert_eq(@ini.grouped_map_size(m_S15), 9) // o.S15.10.size|9
  assert_eq(
    esc(@ini.ini_store(m_S15)),
    "[g]\\na = null\\nnl = x\\ny\\ncr = x\\ry\\neq = a=b\\nsp =  x \\nuni = \\u4e2d\\u6587\\nempty = \\n[]\\nbare = 1\\n[a]b]\\nk = 1\\n",
  ) // o.S15.10.store|[g]\na = null\nnl = x\ny\ncr = x\ry\neq = a=b\nsp =  x \nuni = \u4e2d\u6587\nempty = \n[]\nbare = 1\n[a]b]\nk = 1\n

  let m_S16 = @ini.grouped_map_new()
  assert_eq(@ini.grouped_map_put(m_S16, Some("g"), "k", Some("v")), None) // o.S16.1.prev|<null>
  @ini.grouped_map_clear_group(m_S16, Some("g")) // o.S16.2.clear|ok
  assert_eq(dmp(m_S16), "g?") // o.S16.3.dmp|g?
  assert_eq(@ini.grouped_map_size(m_S16), 0) // o.S16.3.size|0
  assert_eq(esc(@ini.ini_store(m_S16)), "[g]\\n") // o.S16.3.store|[g]\n
}

///|
test "ini_default_parse_opts 的默认档与 ini_parse 同路" {
  let gm_basic = @ini.ini_parse("name = value\nage=18\n")
  assert_eq(dmp(gm_basic), "?name=value,age=18") // i.basic.dmp|?name=value,age=18
  assert_eq(@ini.grouped_map_size(gm_basic), 2) // i.basic.size|2
  assert_eq(esc_all(@ini.grouped_map_groups(gm_basic)), [""]) // i.basic.groups|
  assert_eq(flat_str(gm_basic), "name=value|age=18") // i.basic.flat|name=value|age=18
  assert_eq(esc(@ini.ini_store(gm_basic)), "[]\\nname = value\\nage = 18\\n") // i.basic.store|[]\nname = value\nage = 18\n

  let o = @ini.ini_default_parse_opts()
  assert_eq(o.use_variable, false) // #22.3|参照构造参数 isUseVariable=false
  assert_eq(o.assign_flag.to_string(), "=") // #22.3|参照字段初值 assignFlag = 等号
  assert_eq(
    dmp(@ini.ini_parse_with_opts("name = value\nage=18\n", o)),
    "?name=value,age=18",
  ) // i.basic.dmp|默认选项档与 #22.20 同读数
}

///|
test "读取面：get_str 只在读不到时兜底，not_empty 连空值一起兜底" {
  let gm = @ini.ini_parse("[g]\nn=1\nb=  \nz=\n[e]\nemp=\n")
  assert_eq(dmp(gm), "g?n=1,b=,z=|e?emp=") // s.seed.dmp|g?n=1,b=,z=|e?emp=
  assert_eq(@ini.grouped_map_size(gm), 4) // s.seed.size|4
  assert_eq(@ini.ini_get_str(gm, "n", Some("g"), Some("D")), Some("1")) // s.n/g/D.str3|1
  assert_eq(@ini.grouped_map_get(gm, Some("g"), "n"), Some("1")) // s.n/g/D.by_group|1
  assert_eq(
    @ini.ini_get_str_not_empty(gm, "n", Some("g"), Some("D")),
    Some("1"),
  ) // s.n/g/D.not_empty|1
  assert_eq(@ini.ini_get_str(gm, "missing", Some("g"), Some("D")), Some("D")) // s.missing/g/D.str3|D
  assert_eq(@ini.grouped_map_get(gm, Some("g"), "missing"), None) // s.missing/g/D.by_group|<null>
  assert_eq(
    @ini.ini_get_str_not_empty(gm, "missing", Some("g"), Some("D")),
    Some("D"),
  ) // s.missing/g/D.not_empty|D
  assert_eq(@ini.ini_get_str(gm, "b", Some("g"), Some("D")), Some("")) // s.b/g/D.str3|
  assert_eq(@ini.grouped_map_get(gm, Some("g"), "b"), Some("")) // s.b/g/D.by_group|
  assert_eq(
    @ini.ini_get_str_not_empty(gm, "b", Some("g"), Some("D")),
    Some("D"),
  ) // s.b/g/D.not_empty|D
  assert_eq(@ini.ini_get_str(gm, "z", Some("g"), Some("D")), Some("")) // s.z/g/D.str3|
  assert_eq(@ini.grouped_map_get(gm, Some("g"), "z"), Some("")) // s.z/g/D.by_group|
  assert_eq(
    @ini.ini_get_str_not_empty(gm, "z", Some("g"), Some("D")),
    Some("D"),
  ) // s.z/g/D.not_empty|D
  assert_eq(@ini.ini_get_str(gm, "emp", Some("e"), Some("D")), Some("")) // s.emp/e/D.str3|
  assert_eq(@ini.grouped_map_get(gm, Some("e"), "emp"), Some("")) // s.emp/e/D.by_group|
  assert_eq(
    @ini.ini_get_str_not_empty(gm, "emp", Some("e"), Some("D")),
    Some("D"),
  ) // s.emp/e/D.not_empty|D
  assert_eq(@ini.ini_get_str(gm, "n", Some("nope"), Some("D")), Some("D")) // s.n/nope/D.str3|D
  assert_eq(@ini.grouped_map_get(gm, Some("nope"), "n"), None) // s.n/nope/D.by_group|<null>
  assert_eq(
    @ini.ini_get_str_not_empty(gm, "n", Some("nope"), Some("D")),
    Some("D"),
  ) // s.n/nope/D.not_empty|D
  assert_eq(@ini.ini_get_str(gm, "n", Some(""), Some("D")), Some("D")) // s.n//D.str3|D
  assert_eq(@ini.grouped_map_get(gm, Some(""), "n"), None) // s.n//D.by_group|<null>
  assert_eq(@ini.ini_get_str_not_empty(gm, "n", Some(""), Some("D")), Some("D")) // s.n//D.not_empty|D
  assert_eq(@ini.ini_get_str(gm, "n", None, Some("D")), Some("D")) // s.n/null/D.str3|D
  assert_eq(@ini.grouped_map_get(gm, None, "n"), None) // s.n/null/D.by_group|<null>
  assert_eq(@ini.ini_get_str_not_empty(gm, "n", None, Some("D")), Some("D")) // s.n/null/D.not_empty|D
  assert_eq(@ini.ini_get_str(gm, "n", Some("g"), None), Some("1")) // s.n/g/null.str3|1
  assert_eq(@ini.grouped_map_get(gm, Some("g"), "n"), Some("1")) // s.n/g/null.by_group|1
  assert_eq(@ini.ini_get_str_not_empty(gm, "n", Some("g"), None), Some("1")) // s.n/g/null.not_empty|1
  assert_eq(@ini.ini_get_str(gm, "n", Some("g"), Some("")), Some("1")) // s.n/g/.str3|1
  assert_eq(@ini.grouped_map_get(gm, Some("g"), "n"), Some("1")) // s.n/g/.by_group|1
  assert_eq(@ini.ini_get_str_not_empty(gm, "n", Some("g"), Some("")), Some("1")) // s.n/g/.not_empty|1
  assert_eq(@ini.ini_get_str(gm, "b", Some("g"), None), Some("")) // s.b/g/null.str3|
  assert_eq(@ini.grouped_map_get(gm, Some("g"), "b"), Some("")) // s.b/g/null.by_group|
  assert_eq(@ini.ini_get_str_not_empty(gm, "b", Some("g"), None), None) // s.b/g/null.not_empty|<null>
  assert_eq(@ini.ini_get_str(gm, "b", Some("g"), Some("")), Some("")) // s.b/g/.str3|
  assert_eq(@ini.grouped_map_get(gm, Some("g"), "b"), Some("")) // s.b/g/.by_group|
  assert_eq(@ini.ini_get_str_not_empty(gm, "b", Some("g"), Some("")), Some("")) // s.b/g/.not_empty|
}
