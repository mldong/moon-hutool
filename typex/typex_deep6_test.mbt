///|
// typex 深档补档（10-08）——rainbow 三档、Version 的构建元数据与字符串单元档、
// DataSize 的空白码点档、港澳台 10 位形状拒收档。
// 期望全部由 TypexLeg4.java 现读灌入（hutool-core 5.8.35 · JDK 17.0.14 · -Dfile.encoding=UTF-8），手打零条。
// 不可见码点夹具在腿里用 codePoint 现构，读数行打的是 0xNN 序列；生成器按同一序列还原成 MoonBit 字面量，
// 人不手打一个字符。异常档只钉"抛不抛"，变体名不由这条腿授权。

///|
fn t4_rain(cur : Int, total : Int, cnt : Int) -> String {
  let mut s = ""
  for v in @typex.page_rainbow_count(cur, total, cnt) {
    if s != "" {
      s = s + ";"
    }
    s = s + v.to_string()
  }
  if s == "" {
    "-"
  } else {
    s
  }
}

///|
fn t4_vc(a : String, b : String) -> String {
  @typex.version_compare(@typex.version_of(a), @typex.version_of(b)).to_string()
}

///|
fn t4_vt(a : String) -> String {
  @typex.version_to_string(@typex.version_of(a))
}

///|
fn t4_dp(s : String) -> String {
  @typex.data_size_parse_bytes(s).to_string() catch {
    _ => "RAISE"
  }
}

///|
fn t4_hk(s : String) -> String {
  @typex.idcard_is_valid_hk_card(s).to_string()
}

///|
fn t4_tw(s : String) -> String {
  @typex.idcard_is_valid_tw_card(s).to_string()
}

///|
test "typex 深档 rain-mid-even" {
  // page_rainbow_count ｜ current=6 total=20 show=6 ｜ 参照 rainbow(pageNo,totalPage,displayCount)=4;5;6;7;8;9
  assert_eq(t4_rain(6, 20, 6), "4;5;6;7;8;9")
}

///|
test "typex 深档 rain-mid-even2" {
  // page_rainbow_count ｜ current=10 total=20 show=6 ｜ 参照 rainbow(pageNo,totalPage,displayCount)=8;9;10;11;12;13
  assert_eq(t4_rain(10, 20, 6), "8;9;10;11;12;13")
}

///|
test "typex 深档 rain-head-even" {
  // page_rainbow_count ｜ current=3 total=20 show=6 ｜ 参照 rainbow(pageNo,totalPage,displayCount)=1;2;3;4;5;6
  assert_eq(t4_rain(3, 20, 6), "1;2;3;4;5;6")
}

///|
test "typex 深档 rain-tail-even" {
  // page_rainbow_count ｜ current=18 total=20 show=6 ｜ 参照 rainbow(pageNo,totalPage,displayCount)=15;16;17;18;19;20
  assert_eq(t4_rain(18, 20, 6), "15;16;17;18;19;20")
}

///|
test "typex 深档 rain-mid-odd" {
  // page_rainbow_count ｜ current=8 total=20 show=5 ｜ 参照 rainbow(pageNo,totalPage,displayCount)=6;7;8;9;10
  assert_eq(t4_rain(8, 20, 5), "6;7;8;9;10")
}

///|
test "typex 深档 rain-few" {
  // page_rainbow_count ｜ current=2 total=4 show=10 ｜ 参照 rainbow(pageNo,totalPage,displayCount)=1;2;3;4
  assert_eq(t4_rain(2, 4, 10), "1;2;3;4")
}

///|
test "typex 深档 rain-neg-total" {
  // page_rainbow_count ｜ current=2 total=-3 show=10 ｜ 参照 rainbow(pageNo,totalPage,displayCount)=ERR:NegativeArraySizeException（本库改判，见 spec 23-typex §5 第 6 行）
  assert_eq(t4_rain(2, -3, 10), "-")
}

///|
test "typex 深档 rain-d10-head" {
  // page_rainbow_count ｜ current=1 total=20 show=10 ｜ 参照 rainbow(pageNo,totalPage,displayCount)=1;2;3;4;5;6;7;8;9;10
  assert_eq(t4_rain(1, 20, 10), "1;2;3;4;5;6;7;8;9;10")
}

///|
test "typex 深档 vc-build" {
  // version_compare ｜ 1.0+build vs 1.0 ｜ 参照 compareTo=-1
  assert_eq(t4_vc("1.0+build", "1.0"), "-1")
}

///|
test "typex 深档 vt-build" {
  // version_to_string ｜ 1.0+build ｜ 参照 toString=1.0+build
  assert_eq(t4_vt("1.0+build"), "1.0+build")
}

///|
test "typex 深档 vt-buildb" {
  // version_to_string ｜ 1.0 ｜ 参照 toString=1.0
  assert_eq(t4_vt("1.0"), "1.0")
}

///|
test "typex 深档 vc-build2" {
  // version_compare ｜ 1.0+2 vs 1.0+10 ｜ 参照 compareTo=-1
  assert_eq(t4_vc("1.0+2", "1.0+10"), "-1")
}

///|
test "typex 深档 vt-build2" {
  // version_to_string ｜ 1.0+2 ｜ 参照 toString=1.0+2
  assert_eq(t4_vt("1.0+2"), "1.0+2")
}

///|
test "typex 深档 vt-build2b" {
  // version_to_string ｜ 1.0+10 ｜ 参照 toString=1.0+10
  assert_eq(t4_vt("1.0+10"), "1.0+10")
}

///|
test "typex 深档 vc-pre" {
  // version_compare ｜ 1.0.0-beta vs 1.0.0 ｜ 参照 compareTo=-1
  assert_eq(t4_vc("1.0.0-beta", "1.0.0"), "-1")
}

///|
test "typex 深档 vt-pre" {
  // version_to_string ｜ 1.0.0-beta ｜ 参照 toString=1.0.0-beta
  assert_eq(t4_vt("1.0.0-beta"), "1.0.0-beta")
}

///|
test "typex 深档 vt-preb" {
  // version_to_string ｜ 1.0.0 ｜ 参照 toString=1.0.0
  assert_eq(t4_vt("1.0.0"), "1.0.0")
}

///|
test "typex 深档 vc-strunit" {
  // version_compare ｜ 1.0.1 vs 1.0.a ｜ 参照 compareTo=-48（参照给原始差值，本库归一成符号档，见 spec 23-typex「compareTo 返回值」第 4 条）
  assert_eq(t4_vc("1.0.1", "1.0.a"), "-1")
}

///|
test "typex 深档 vt-strunit" {
  // version_to_string ｜ 1.0.1 ｜ 参照 toString=1.0.1
  assert_eq(t4_vt("1.0.1"), "1.0.1")
}

///|
test "typex 深档 vt-strunitb" {
  // version_to_string ｜ 1.0.a ｜ 参照 toString=1.0.a
  assert_eq(t4_vt("1.0.a"), "1.0.a")
}

///|
test "typex 深档 vc-str-vs-str" {
  // version_compare ｜ 1.0.a vs 1.0.aa ｜ 参照 compareTo=-1
  assert_eq(t4_vc("1.0.a", "1.0.aa"), "-1")
}

///|
test "typex 深档 vt-str-vs-str" {
  // version_to_string ｜ 1.0.a ｜ 参照 toString=1.0.a
  assert_eq(t4_vt("1.0.a"), "1.0.a")
}

///|
test "typex 深档 vt-str-vs-strb" {
  // version_to_string ｜ 1.0.aa ｜ 参照 toString=1.0.aa
  assert_eq(t4_vt("1.0.aa"), "1.0.aa")
}

///|
test "typex 深档 vc-str-vs-str2" {
  // version_compare ｜ 1.0.aa vs 1.0.a ｜ 参照 compareTo=1
  assert_eq(t4_vc("1.0.aa", "1.0.a"), "1")
}

///|
test "typex 深档 vt-str-vs-str2" {
  // version_to_string ｜ 1.0.aa ｜ 参照 toString=1.0.aa
  assert_eq(t4_vt("1.0.aa"), "1.0.aa")
}

///|
test "typex 深档 vt-str-vs-str2b" {
  // version_to_string ｜ 1.0.a ｜ 参照 toString=1.0.a
  assert_eq(t4_vt("1.0.a"), "1.0.a")
}

///|
test "typex 深档 vc-snap" {
  // version_compare ｜ 1.2.3 vs 1.2.3-SNAPSHOT ｜ 参照 compareTo=1
  assert_eq(t4_vc("1.2.3", "1.2.3-SNAPSHOT"), "1")
}

///|
test "typex 深档 vt-snap" {
  // version_to_string ｜ 1.2.3 ｜ 参照 toString=1.2.3
  assert_eq(t4_vt("1.2.3"), "1.2.3")
}

///|
test "typex 深档 vt-snapb" {
  // version_to_string ｜ 1.2.3-SNAPSHOT ｜ 参照 toString=1.2.3-SNAPSHOT
  assert_eq(t4_vt("1.2.3-SNAPSHOT"), "1.2.3-SNAPSHOT")
}

///|
test "typex 深档 vc-under" {
  // version_compare ｜ 1.0_1 vs 1.0.1 ｜ 参照 compareTo=46（参照给原始差值 46，本库归一成 1，同号；规格化是本库契约，见同一条）
  assert_eq(t4_vc("1.0_1", "1.0.1"), "1")
}

///|
test "typex 深档 vt-under" {
  // version_to_string ｜ 1.0_1 ｜ 参照 toString=1.0_1
  assert_eq(t4_vt("1.0_1"), "1.0_1")
}

///|
test "typex 深档 vt-underb" {
  // version_to_string ｜ 1.0.1 ｜ 参照 toString=1.0.1
  assert_eq(t4_vt("1.0.1"), "1.0.1")
}

///|
test "typex 深档 dp-31-1c-4b-42" {
  // data_size_parse_bytes ｜ 码点=31+1c+4b+42 ｜ 参照 DataSizeUtil.parse=1024
  assert_eq(t4_dp("1\u{1c}KB"), "1024")
}

///|
test "typex 深档 dp-31-1d-4b-42" {
  // data_size_parse_bytes ｜ 码点=31+1d+4b+42 ｜ 参照 DataSizeUtil.parse=1024
  assert_eq(t4_dp("1\u{1d}KB"), "1024")
}

///|
test "typex 深档 dp-31-2007-4b-42" {
  // data_size_parse_bytes ｜ 码点=31+2007+4b+42 ｜ 参照 DataSizeUtil.parse=1024
  assert_eq(t4_dp("1\u{2007}KB"), "1024")
}

///|
test "typex 深档 dp-31-feff-4b-42" {
  // data_size_parse_bytes ｜ 码点=31+feff+4b+42 ｜ 参照 DataSizeUtil.parse=1024
  assert_eq(t4_dp("1\u{feff}KB"), "1024")
}

///|
test "typex 深档 dp-31-202a-4b-42" {
  // data_size_parse_bytes ｜ 码点=31+202a+4b+42 ｜ 参照 DataSizeUtil.parse=1024
  assert_eq(t4_dp("1\u{202a}KB"), "1024")
}

///|
test "typex 深档 dp-31-85-4b-42" {
  // data_size_parse_bytes ｜ 码点=31+85+4b+42 ｜ 参照 DataSizeUtil.parse=ERR:IllegalArgumentException（参照抛、本库也抛，只钉抛不抛）
  assert_eq(t4_dp("1\u{85}KB"), "RAISE")
}

///|
test "typex 深档 dp-31-20-4b-42" {
  // data_size_parse_bytes ｜ 码点=31+20+4b+42 ｜ 参照 DataSizeUtil.parse=1024
  assert_eq(t4_dp("1 KB"), "1024")
}

///|
test "typex 深档 ih-A123456(7)" {
  // idcard_is_valid_hk_card ｜ A123456(7) ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("A123456(7)"), "false")
}

///|
test "typex 深档 it-A123456(7)" {
  // idcard_is_valid_tw_card ｜ A123456(7) ｜ 参照 isValidTWCard=ERR:NumberFormatException（参照抛 NumberFormatException，本库不设这枚错误面 ⇒ 判假，见 spec 23-typex 港澳台那行）
  assert_eq(t4_tw("A123456(7)"), "false")
}

///|
test "typex 深档 ih-A1234567" {
  // idcard_is_valid_hk_card ｜ A1234567 ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("A1234567"), "false")
}

///|
test "typex 深档 it-A1234567" {
  // idcard_is_valid_tw_card ｜ A1234567 ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("A1234567"), "false")
}

///|
test "typex 深档 ih-a1234567" {
  // idcard_is_valid_hk_card ｜ a1234567 ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("a1234567"), "false")
}

///|
test "typex 深档 it-a1234567" {
  // idcard_is_valid_tw_card ｜ a1234567 ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("a1234567"), "false")
}

///|
test "typex 深档 ih-132456(A)" {
  // idcard_is_valid_hk_card ｜ 132456(A) ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("132456(A)"), "false")
}

///|
test "typex 深档 it-132456(A)" {
  // idcard_is_valid_tw_card ｜ 132456(A) ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("132456(A)"), "false")
}

///|
test "typex 深档 ih-Z324567(8)" {
  // idcard_is_valid_hk_card ｜ Z324567(8) ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("Z324567(8)"), "false")
}

///|
test "typex 深档 it-Z324567(8)" {
  // idcard_is_valid_tw_card ｜ Z324567(8) ｜ 参照 isValidTWCard=ERR:NumberFormatException（同上）
  assert_eq(t4_tw("Z324567(8)"), "false")
}

///|
test "typex 深档 ih-(5)" {
  // idcard_is_valid_hk_card ｜ (5) ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("(5)"), "false")
}

///|
test "typex 深档 it-(5)" {
  // idcard_is_valid_tw_card ｜ (5) ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("(5)"), "false")
}

///|
test "typex 深档 ih-1234567(8)" {
  // idcard_is_valid_hk_card ｜ 1234567(8) ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("1234567(8)"), "false")
}

///|
test "typex 深档 it-1234567(8)" {
  // idcard_is_valid_tw_card ｜ 1234567(8) ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("1234567(8)"), "false")
}

///|
test "typex 深档 ih-A123456(7" {
  // idcard_is_valid_hk_card ｜ A123456(7 ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("A123456(7"), "false")
}

///|
test "typex 深档 it-A123456(7" {
  // idcard_is_valid_tw_card ｜ A123456(7 ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("A123456(7"), "false")
}

///|
test "typex 深档 ih-A12345)6(7)" {
  // idcard_is_valid_hk_card ｜ A12345)6(7) ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("A12345)6(7)"), "false")
}

///|
test "typex 深档 it-A12345)6(7)" {
  // idcard_is_valid_tw_card ｜ A12345)6(7) ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("A12345)6(7)"), "false")
}

///|
test "typex 深档 ih-1324567" {
  // idcard_is_valid_hk_card ｜ 1324567 ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("1324567"), "false")
}

///|
test "typex 深档 it-1324567" {
  // idcard_is_valid_tw_card ｜ 1324567 ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("1324567"), "false")
}

///|
test "typex 深档 ih-ME1234567" {
  // idcard_is_valid_hk_card ｜ ME1234567 ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("ME1234567"), "false")
}

///|
test "typex 深档 it-ME1234567" {
  // idcard_is_valid_tw_card ｜ ME1234567 ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("ME1234567"), "false")
}

///|
test "typex 深档 ih-123456789" {
  // idcard_is_valid_hk_card ｜ 123456789 ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("123456789"), "false")
}

///|
test "typex 深档 it-123456789" {
  // idcard_is_valid_tw_card ｜ 123456789 ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("123456789"), "false")
}

///|
test "typex 深档 ih-X123456()" {
  // idcard_is_valid_hk_card ｜ X123456() ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("X123456()"), "false")
}

///|
test "typex 深档 it-X123456()" {
  // idcard_is_valid_tw_card ｜ X123456() ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("X123456()"), "false")
}

///|
test "typex 深档 ih-1234567890" {
  // idcard_is_valid_hk_card ｜ 1234567890 ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("1234567890"), "false")
}

///|
test "typex 深档 it-1234567890" {
  // idcard_is_valid_tw_card ｜ 1234567890 ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("1234567890"), "false")
}

///|
test "typex 深档 ih-12345(6)" {
  // idcard_is_valid_hk_card ｜ 12345(6) ｜ 参照 isValidHKCard=false
  assert_eq(t4_hk("12345(6)"), "false")
}

///|
test "typex 深档 it-12345(6)" {
  // idcard_is_valid_tw_card ｜ 12345(6) ｜ 参照 isValidTWCard=false
  assert_eq(t4_tw("12345(6)"), "false")
}
