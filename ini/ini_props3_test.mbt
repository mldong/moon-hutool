///|
// ini 第三批补档（10-08）——`Props` 严格语义的行法与转义族：无尾换行的收尾、行续接（奇偶反斜杠）、
// 注释行尾反斜杠不续行、三种行终止符、u 加四位十六进制的转义档（大小写两档）、值尾反斜杠、重复键覆盖。
// 期望全部由 Props3Leg.java 现读灌入（**权威参照 = JDK 17 `java.util.Properties.load(Reader)`**，
// hutool `Props` 只是转手，见 docs/spec/22-ini.md §8），手打零条。
// 键序/值序是本库 #22.37 的"首次出现序"（JDK 侧是 Hashtable、本无顺序），折叠规则见 §10。

///|
fn p3_pairs(p : @ini.Props) -> String {
  let ks = @ini.props_keys(p)
  let vs = @ini.props_values(p)
  let mut out = ""
  for i in 0..<ks.length() {
    if i > 0 {
      out = out + ";"
    }
    out = out + ks[i] + "{kv}" + vs[i]
  }
  out
}

///|
test "ini props3 noeol" {
  // 参照读数=a{kv}1
  assert_eq(p3_pairs(@ini.props_parse("a=1")), "a{kv}1")
}

///|
test "ini props3 noeol_bs" {
  // 参照读数=a{kv}1
  assert_eq(p3_pairs(@ini.props_parse("a=1\\")), "a{kv}1")
}

///|
test "ini props3 lead_ws" {
  // 参照读数=a{kv}1
  assert_eq(p3_pairs(@ini.props_parse(" \ta=1\n")), "a{kv}1")
}

///|
test "ini props3 cont_blank" {
  // 参照读数=a{kv}1;b{kv}2
  assert_eq(p3_pairs(@ini.props_parse("a=1\\\n\nb=2\n")), "a{kv}1;b{kv}2")
}

///|
test "ini props3 cont_ws" {
  // 参照读数=a{kv}12
  assert_eq(p3_pairs(@ini.props_parse("a=1\\\n   2\n")), "a{kv}12")
}

///|
test "ini props3 upper_u" {
  // 参照读数=a{kv}{u00e9}
  assert_eq(p3_pairs(@ini.props_parse("a=\\u00E9")), "a{kv}\u{00e9}")
}

///|
test "ini props3 lower_u" {
  // 参照读数=a{kv}{u00e9}
  assert_eq(p3_pairs(@ini.props_parse("a=\\u00e9")), "a{kv}\u{00e9}")
}

///|
test "ini props3 trail_bs_sp" {
  // 参照读数=a{kv}x 
  assert_eq(p3_pairs(@ini.props_parse("a=x\\ \n")), "a{kv}x ")
}

///|
test "ini props3 trail_bs2" {
  // 参照读数=a{kv}x\
  assert_eq(p3_pairs(@ini.props_parse("a=x\\\\\n")), "a{kv}x\\")
}

///|
test "ini props3 dup_key" {
  // 参照读数=a{kv}2
  assert_eq(p3_pairs(@ini.props_parse("a=1\na=2\n")), "a{kv}2")
}

///|
test "ini props3 key_esc_eq" {
  // 参照读数=a=b{kv}1
  assert_eq(p3_pairs(@ini.props_parse("a\\=b=1\n")), "a=b{kv}1")
}

///|
test "ini props3 comment_bs" {
  // 参照读数=a{kv}1
  assert_eq(p3_pairs(@ini.props_parse("# c\\\na=1\n")), "a{kv}1")
}

///|
test "ini props3 cr_only" {
  // 参照读数=a{kv}1;b{kv}2
  assert_eq(p3_pairs(@ini.props_parse("a=1\rb=2\r")), "a{kv}1;b{kv}2")
}

///|
test "ini props3 crlf" {
  // 参照读数=a{kv}1;b{kv}2
  assert_eq(p3_pairs(@ini.props_parse("a=1\r\nb=2\r\n")), "a{kv}1;b{kv}2")
}

///|
test "ini props3 blank_lead" {
  // 参照读数=a{kv}1
  assert_eq(p3_pairs(@ini.props_parse("\n \n a=1\n")), "a{kv}1")
}

///|
test "ini props3 colon_sep" {
  // 参照读数=a{kv}1
  assert_eq(p3_pairs(@ini.props_parse("a:1\n")), "a{kv}1")
}

///|
test "ini props3 ws_only_line" {
  // 参照读数=a{kv}1;b{kv}2
  assert_eq(p3_pairs(@ini.props_parse("a=1\n   \nb=2\n")), "a{kv}1;b{kv}2")
}

///|
test "ini props3 bs_line" {
  // 参照读数=a{kv}1
  assert_eq(p3_pairs(@ini.props_parse("\\\n\na=1\n")), "a{kv}1")
}

///|
test "ini props3 bs_key" {
  // 参照读数==1{kv}
  assert_eq(p3_pairs(@ini.props_parse("\\=1\n")), "=1{kv}")
}

///|
test "ini props3 bs3_key" {
  // 参照读数=x\=1{kv}
  assert_eq(p3_pairs(@ini.props_parse("x\\\\\\=1\n")), "x\\=1{kv}")
}
