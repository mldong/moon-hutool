///|
// typex 第八批补档（10-08）——Version 预发/构建段的分词支路、港澳台形状闸的收尾档、15 位省码闸、
// 坏后缀与未知档位串。期望全部由 `scripts/TypexLeg5.java` 现读灌入
// （hutool-core 5.8.35 · JDK 17.0.14 · `-Dfile.encoding=UTF-8`），手打零条。
// 两条形状纪律：① 港澳台两族的夹具是**同一串只在收尾形状上变化**，校验位由腿反推（`findHk`/`findTw`），
// 所以 true 档与 false 档成对出现——若整族只有 false，那条闸坏掉也照样全绿（腿的 `G|GUARD_OK` 就是在管这件事）；
// ② `Version.compareTo` 的原始差值只承诺符号（§5 第 4 条），本库出口归一成 `-1/0/1`，
// 断言里打的是符号档，腿的原读数留在注释。
// 参照 `isValidCard10` 返回 `String[]`，与本库 `IdcardInfo10` 三槽形状不同源 ⇒ `O` 行只登记不进断言（§22.2）。

///|
fn t5_vc(a : String, b : String) -> String {
  @typex.version_compare(@typex.version_of(a), @typex.version_of(b)).to_string()
}

///|
fn t5_hk(s : String) -> String {
  @typex.idcard_is_valid_hk_card(s).to_string()
}

///|
fn t5_tw(s : String) -> String {
  @typex.idcard_is_valid_tw_card(s).to_string()
}

///|
fn t5_id15(s : String) -> String {
  @typex.idcard_is_valid_15(s).to_string()
}

///|
fn t5_amount(n : Int64, s : String) -> String {
  @typex.data_size_of_amount_suffix(n, s).to_string() catch {
    _ => "RAISE"
  }
}

///|
// 高代理落在切片尾：`010-123456`（10 码元）+ 一个补充平面字符（第 11、12 码元是高低代理），
// `phone_sub_after` 取第 7..11 码元 ⇒ 切片正好切进代理对
fn t5_phone_sub_after(s : String) -> String {
  @typex.phone_sub_after(s)
}

///|
// 低代理落在切片头：`010-12`（6 码元）+ 一个补充平面字符（第 7、8 码元是高低代理）+ `34567`
fn t5_phone_lo() -> String {
  @typex.phone_sub_after("010-12\u{1F600}34567")
}

///|
fn t5_des(text : String, kind : String) -> String {
  match @typex.desensitize_kind(text, kind) {
    None => "null"
    Some(v) => v
  }
}

///|

///|
test "typex 分词直读 01 · plus-in-pre" {
  // compare(1.0.0-alpha+build, 1.0.0-alpha) ｜ 参照 compareTo=1 ｜ 本库出口只承诺符号（§5 第 4 条）
  assert_eq(t5_vc("1.0.0-alpha+build", "1.0.0-alpha"), "1")
}

///|
test "typex 分词直读 02 · plus-empty" {
  // compare(1.0.0-alpha+, 1.0.0-alpha) ｜ 参照 compareTo=0 ｜ 本库出口只承诺符号（§5 第 4 条）
  assert_eq(t5_vc("1.0.0-alpha+", "1.0.0-alpha"), "0")
}

///|
test "typex 分词直读 03 · build-dots" {
  // compare(1.0.0-alpha+b.c, 1.0.0-alpha+b) ｜ 参照 compareTo=1 ｜ 本库出口只承诺符号（§5 第 4 条）
  assert_eq(t5_vc("1.0.0-alpha+b.c", "1.0.0-alpha+b"), "1")
}

///|
test "typex 分词直读 04 · build-dash" {
  // compare(1.0.0-alpha+b-c, 1.0.0-alpha+b.c) ｜ 参照 compareTo=0 ｜ 本库出口只承诺符号（§5 第 4 条）
  assert_eq(t5_vc("1.0.0-alpha+b-c", "1.0.0-alpha+b.c"), "0")
}

///|
test "typex 分词直读 05 · build-num" {
  // compare(1.0.0+2, 1.0.0+10) ｜ 参照 compareTo=-1 ｜ 本库出口只承诺符号（§5 第 4 条）
  assert_eq(t5_vc("1.0.0+2", "1.0.0+10"), "-1")
}

///|
test "typex 分词直读 06 · pre-plus-num" {
  // compare(1.0.0-1+2, 1.0.0-1) ｜ 参照 compareTo=1 ｜ 本库出口只承诺符号（§5 第 4 条）
  assert_eq(t5_vc("1.0.0-1+2", "1.0.0-1"), "1")
}

///|
test "typex 分词直读 07 · pre-dots" {
  // compare(1.0.0-a.b.c, 1.0.0-a.b) ｜ 参照 compareTo=1 ｜ 本库出口只承诺符号（§5 第 4 条）
  assert_eq(t5_vc("1.0.0-a.b.c", "1.0.0-a.b"), "1")
}

///|
test "typex 分词直读 08 · build-only-dots" {
  // compare(1.0.0+b.c, 1.0.0+b) ｜ 参照 compareTo=1 ｜ 本库出口只承诺符号（§5 第 4 条）
  assert_eq(t5_vc("1.0.0+b.c", "1.0.0+b"), "1")
}

///|
test "typex 分词直读 09 · plus-vs-dash" {
  // compare(1.0.0-alpha+0, 1.0.0-alpha-0) ｜ 参照 compareTo=0 ｜ 本库出口只承诺符号（§5 第 4 条）
  assert_eq(t5_vc("1.0.0-alpha+0", "1.0.0-alpha-0"), "0")
}

///|
test "typex 分词直读 10 · plus-vs-dash2" {
  // compare(1.0.0+b.c, 1.0.0-b-c) ｜ 参照 compareTo=0 ｜ 本库出口只承诺符号（§5 第 4 条）
  assert_eq(t5_vc("1.0.0+b.c", "1.0.0-b-c"), "0")
}

///|
test "typex 港形直读 11 · valid-plain" {
  // isValidHKCard(A1234563) ｜ 参照=true
  assert_eq(t5_hk("A1234563"), "true")
}

///|
test "typex 港形直读 12 · valid-paren" {
  // isValidHKCard(A123456(3)) ｜ 参照=true
  assert_eq(t5_hk("A123456(3)"), "true")
}

///|
test "typex 港形直读 13 · valid-one-open" {
  // isValidHKCard(A123456(3) ｜ 参照=true
  assert_eq(t5_hk("A123456(3"), "true")
}

///|
test "typex 港形直读 14 · valid-one-close" {
  // isValidHKCard(A1234563)) ｜ 参照=true
  assert_eq(t5_hk("A1234563)"), "true")
}

///|
test "typex 港形直读 15 · valid-open-pad" {
  // isValidHKCard(A123456(3!) ｜ 参照=false
  assert_eq(t5_hk("A123456(3!"), "false")
}

///|
test "typex 港形直读 16 · valid-close-pad" {
  // isValidHKCard(A123456!3)) ｜ 参照=false
  assert_eq(t5_hk("A123456!3)"), "false")
}

///|
test "typex 港形直读 17 · valid-over-long" {
  // isValidHKCard(A123456301) ｜ 参照=false
  assert_eq(t5_hk("A123456301"), "false")
}

///|
test "typex 港形直读 18 · two-letter-valid" {
  // isValidHKCard(AB1234563) ｜ 参照=false
  assert_eq(t5_hk("AB1234563"), "false")
}

///|
test "typex 港形直读 19 · two-letter-valid-ch" {
  // isValidHKCard(AB1234569) ｜ 参照=true
  assert_eq(t5_hk("AB1234569"), "true")
}

///|
test "typex 港形直读 20 · rest-gt3" {
  // isValidHKCard(A1234567890) ｜ 参照=false
  assert_eq(t5_hk("A1234567890"), "false")
}

///|
test "typex 港形直读 21 · rest-zero" {
  // isValidHKCard(AB123456) ｜ 参照=false
  assert_eq(t5_hk("AB123456"), "false")
}

///|
test "typex 港形直读 22 · lp-extra" {
  // isValidHKCard(A123456(5!) ｜ 参照=false
  assert_eq(t5_hk("A123456(5!"), "false")
}

///|
test "typex 港形直读 23 · rp-extra" {
  // isValidHKCard(A1234567!)) ｜ 参照=false
  assert_eq(t5_hk("A1234567!)"), "false")
}

///|
test "typex 港形直读 24 · two-letter-long" {
  // isValidHKCard(AB123456789) ｜ 参照=false
  assert_eq(t5_hk("AB123456789"), "false")
}

///|
test "typex 港形直读 25 · plain-ok" {
  // isValidHKCard(A1234567) ｜ 参照=false
  assert_eq(t5_hk("A1234567"), "false")
}

///|
test "typex 港形直读 26 · paren-ok" {
  // isValidHKCard(A123456(7)) ｜ 参照=false
  assert_eq(t5_hk("A123456(7)"), "false")
}

///|
test "typex 港形直读 27 · letter-a-end" {
  // isValidHKCard(A123456A) ｜ 参照=false
  assert_eq(t5_hk("A123456A"), "false")
}

///|
test "typex 港形直读 28 · short-7" {
  // isValidHKCard(A12345) ｜ 参照=false
  assert_eq(t5_hk("A12345"), "false")
}

///|
test "typex 台形直读 29 · valid" {
  // isValidTWCard(A123456789) ｜ 参照=true
  assert_eq(t5_tw("A123456789"), "true")
}

///|
test "typex 台形直读 30 · valid-end-letter（声明档）" {
  // isValidTWCard(A12345678X) ｜ 参照=ERR:NumberFormatException ⇒ 参照在坏形状上抛，本库三件都不设这枚错误面，这类串一律判假（§22.1 那行）
  assert_eq(t5_tw("A12345678X"), "false")
}

///|
test "typex 台形直读 31 · valid-end-paren（声明档）" {
  // isValidTWCard(A12345678)) ｜ 参照=ERR:NumberFormatException ⇒ 参照在坏形状上抛，本库三件都不设这枚错误面，这类串一律判假（§22.1 那行）
  assert_eq(t5_tw("A12345678)"), "false")
}

///|
test "typex 台形直读 32 · valid-end-lower（声明档）" {
  // isValidTWCard(A12345678a) ｜ 参照=ERR:NumberFormatException ⇒ 参照在坏形状上抛，本库三件都不设这枚错误面，这类串一律判假（§22.1 那行）
  assert_eq(t5_tw("A12345678a"), "false")
}

///|
test "typex 台形直读 33 · valid-over-long" {
  // isValidTWCard(A1234567890) ｜ 参照=false
  assert_eq(t5_tw("A1234567890"), "false")
}

///|
test "typex 台形直读 34 · valid-under" {
  // isValidTWCard(A123456780) ｜ 参照=false
  assert_eq(t5_tw("A123456780"), "false")
}

///|
test "typex 台形直读 35 · end-letter（声明档）" {
  // isValidTWCard(A12345678X) ｜ 参照=ERR:NumberFormatException ⇒ 参照在坏形状上抛，本库三件都不设这枚错误面，这类串一律判假（§22.1 那行）
  assert_eq(t5_tw("A12345678X"), "false")
}

///|
test "typex 台形直读 36 · end-paren（声明档）" {
  // isValidTWCard(A12345678)) ｜ 参照=ERR:NumberFormatException ⇒ 参照在坏形状上抛，本库三件都不设这枚错误面，这类串一律判假（§22.1 那行）
  assert_eq(t5_tw("A12345678)"), "false")
}

///|
test "typex 台形直读 37 · end-lower（声明档）" {
  // isValidTWCard(A12345678a) ｜ 参照=ERR:NumberFormatException ⇒ 参照在坏形状上抛，本库三件都不设这枚错误面，这类串一律判假（§22.1 那行）
  assert_eq(t5_tw("A12345678a"), "false")
}

///|
test "typex 台形直读 38 · long-11" {
  // isValidTWCard(A1234567890) ｜ 参照=false
  assert_eq(t5_tw("A1234567890"), "false")
}

///|
test "typex 台形直读 39 · short-9" {
  // isValidTWCard(A12345678) ｜ 参照=false
  assert_eq(t5_tw("A12345678"), "false")
}

///|
test "typex 台形直读 40 · start-lower-ok" {
  // isValidTWCard(a12345671) ｜ 参照=false
  assert_eq(t5_tw("a12345671"), "false")
}

///|
test "typex 十五位省码直读 41 · bad-prov" {
  // isValidCard15(999999900101123) ｜ 参照=false
  assert_eq(t5_id15("999999900101123"), "false")
}

///|
test "typex 十五位省码直读 42 · bad-prov0" {
  // isValidCard15(009999900101123) ｜ 参照=false
  assert_eq(t5_id15("009999900101123"), "false")
}

///|
test "typex 十五位省码直读 43 · ok-prov" {
  // isValidCard15(110101900101123) ｜ 参照=true
  assert_eq(t5_id15("110101900101123"), "true")
}

///|
test "typex 十五位省码直读 44 · ok-prov2" {
  // isValidCard15(510101900101123) ｜ 参照=true
  assert_eq(t5_id15("510101900101123"), "true")
}

///|
test "typex 十五位省码直读 45 · letter" {
  // isValidCard15(11010190010A123) ｜ 参照=false
  assert_eq(t5_id15("11010190010A123"), "false")
}

///|
test "typex 声明档 46 · desens-unknown" {
  // 未知档位串照参照 `switch` 的空 `default` 给原串（#23.96 函数注释那行），枚举穷尽 ⇒ 参照无此档读数
  assert_eq(t5_des("abcDEF", "NOT_A_KIND"), "abcDEF")
}

///|
test "typex 声明档 47 · ds-bad-suffix" {
  // 坏后缀：参照 `DataSizeUtil.parse` 对 `1 XB` 抛 `IllegalArgumentException`（腿 `B` 行），本库同判拒但对位 `DataSizeError::BadText`（§15.5 错误映射那行）
  assert_eq(t5_amount(1L, "XB"), "RAISE")
}

///|
test "typex 声明档 48 · phone-hi-tail" {
  // 高代理恰落在切片尾：参照（Java `String`）留孤立代理项，本库丢弃（§11.5 那行）
  assert_eq(t5_phone_sub_after("010-123456" + "\u{1F600}"), "456")
}

///|
test "typex 声明档 49 · phone-lo-head" {
  // 低代理恰落在切片头：同上，参照留、本库丢（§11.5 那行）
  assert_eq(t5_phone_lo(), "345")
}

// 参照 `isValidCard10` 的 5 条读数（返回 `String[]`，本库无同形状出口 ⇒ 不进断言，§22.2）：
// O|1234567|ERR:NullPointerException|
// O|M123456(7)|OK|香港;N;false
// O|12345678|OK|澳门;N;true
// O|123456(7)|ERR:NullPointerException|
// O|123456(78|ERR:NullPointerException|
// B|1 XB|ERR:IllegalArgumentException
// B|1|OK
// B|1 kb|OK
// B|1 KBB|ERR:IllegalArgumentException
// B| 1 KB|OK
