///|
// moon-hutool/date —— 全局自定义格式表的冻结期望（第六批 §9.6）。
// 由 `scripts/gen_timer_test.py` 从 `scripts/TimerLeg3.java`（GF 行）、`TimerLeg4.java`（EP 行）、
// `TimerLeg5.java`（P5 行）、`TimerLeg.java`（F 行）灌出来，一格都没有手打。
//
// 三个到不了的臂不落断言（§9.6/§9.8）：`isCustomFormat(null)`、`format(null, #SSS)`、
// `parse(null, #sss)` 三条 NPE，以及 `format(TemporalAccessor, #sss)` 那支（`LocalTime` 档实测要读今天）。
//
// 进程级表必须收尾复位：每个动过 `set_custom_*` 的块在末尾调 `reset_custom_format`（§9.8 第 4 行）。

///|
/// 本批夹具用的瞬间（腿里全程是 `new Date(1700000000123L)`，逐条读数都对齐这个值）
const CF_MILLIS : Int64 = 1700000000123L

///|
test "date #9.6.1 两个常量键 + is_custom_format 精确匹配九档" {
  assert_eq(@date.custom_format_seconds, "#sss") // 读数腿  GF|FORMAT_SECONDS||#sss
  assert_eq(@date.custom_format_milliseconds, "#SSS") // 读数腿  GF|FORMAT_MILLISECONDS||#SSS
  assert_eq(@date.is_custom_format("#sss"), true) // 读数腿  GF|isCustom[#sss]||true
  assert_eq(@date.is_custom_format("#SSS"), true) // 读数腿  GF|isCustom[#SSS]||true
  assert_eq(@date.is_custom_format("#sss "), false) // 读数腿  GF|isCustom[#sss ]||false
  assert_eq(@date.is_custom_format(" #sss"), false) // 读数腿  GF|isCustom[ #sss]||false
  assert_eq(@date.is_custom_format("#ss"), false) // 读数腿  GF|isCustom[#ss]||false
  assert_eq(@date.is_custom_format("#SS"), false) // 读数腿  GF|isCustom[#SS]||false
  assert_eq(@date.is_custom_format("sss"), false) // 读数腿  GF|isCustom[sss]||false
  assert_eq(@date.is_custom_format(""), false) // 读数腿  GF|isCustom[]||false
  assert_eq(@date.is_custom_format("#SSSS"), false) // 读数腿  GF|isCustom[#SSSS]||false
  // 九档里没有任何大小写折叠：`#SS`/`#ss` 两档同假，内置两档各只在原样那档为真
}

///|
test "date #9.6.2 内置两档的算法（floorDiv 的负半边 + 毫秒原样档）" {
  assert_eq(@date.custom_format(CF_MILLIS, "#sss"), Some("1700000000")) // 读数腿  GF|format(d,#sss)||1700000000
  assert_eq(@date.custom_format(CF_MILLIS, "#SSS"), Some("1700000000123")) // 读数腿  GF|format(d,#SSS)||1700000000123
  assert_eq(@date.custom_format(CF_MILLIS, "yyyy"), None) // 读数腿  GF|format(d,plain)||{null} ⇒ 未登记既不抛也不回落到普通 pattern
  assert_eq(@date.custom_format(0L, "#sss"), Some("0")) // 读数腿  EP|0||0|0|0 的第一列：#sss = Math.floorDiv（负半边向下）
  assert_eq(@date.custom_format(999L, "#sss"), Some("0")) // 读数腿  EP|999||0|999|0 的第一列：#sss = Math.floorDiv（负半边向下）
  assert_eq(@date.custom_format(1000L, "#sss"), Some("1")) // 读数腿  EP|1000||1|1000|1 的第一列：#sss = Math.floorDiv（负半边向下）
  assert_eq(@date.custom_format(-1L, "#sss"), Some("-1")) // 读数腿  EP|-1||-1|-1|-1 的第一列：#sss = Math.floorDiv（负半边向下）
  assert_eq(@date.custom_format(-999L, "#sss"), Some("-1")) // 读数腿  EP|-999||-1|-999|-1 的第一列：#sss = Math.floorDiv（负半边向下）
  assert_eq(@date.custom_format(-1000L, "#sss"), Some("-1")) // 读数腿  EP|-1000||-1|-1000|-1 的第一列：#sss = Math.floorDiv（负半边向下）
  assert_eq(@date.custom_format(-1001L, "#sss"), Some("-2")) // 读数腿  EP|-1001||-2|-1001|-2 的第一列：#sss = Math.floorDiv（负半边向下）
  assert_eq(@date.custom_format(1700000000123L, "#sss"), Some("1700000000")) // 读数腿  EP|1700000000123||1700000000|1700000000123|1700000000 的第一列：#sss = Math.floorDiv（负半边向下）
  assert_eq(@date.custom_format(-1700000000123L, "#sss"), Some("-1700000001")) // 读数腿  EP|-1700000000123||-1700000001|-1700000000123|-1700000001 的第一列：#sss = Math.floorDiv（负半边向下）
  assert_eq(
    @date.custom_format(-9223372036854775808L, "#sss"),
    Some("-9223372036854776"),
  ) // 读数腿  EP|-9223372036854775808||-9223372036854776|-9223372036854775808|-9223372036854776 的第一列：#sss = Math.floorDiv（负半边向下）
  assert_eq(
    @date.custom_format(9223372036854775807L, "#sss"),
    Some("9223372036854775"),
  ) // 读数腿  EP|9223372036854775807||9223372036854775|9223372036854775807|9223372036854775 的第一列：#sss = Math.floorDiv（负半边向下）
  assert_eq(@date.custom_format(0L, "#SSS"), Some("0")) // 读数腿  EP|0||0|0|0 的第二列：#SSS 原样给毫秒
  assert_eq(@date.custom_format(-1L, "#SSS"), Some("-1")) // 读数腿  EP|-1||-1|-1|-1 的第二列：#SSS 原样给毫秒
  assert_eq(@date.custom_format(1700000000123L, "#SSS"), Some("1700000000123")) // 读数腿  EP|1700000000123||1700000000|1700000000123|1700000000 的第二列：#SSS 原样给毫秒
  assert_eq(
    @date.custom_format(-1700000000123L, "#SSS"),
    Some("-1700000000123"),
  ) // 读数腿  EP|-1700000000123||-1700000001|-1700000000123|-1700000001 的第二列：#SSS 原样给毫秒
  assert_eq(@date.custom_format(999L, "#SSS"), Some("999")) // 读数腿  EP|999||0|999|0 的第二列：#SSS 原样给毫秒
  assert_eq(@date.custom_format(-999L, "#SSS"), Some("-999")) // 读数腿  EP|-999||-1|-999|-1 的第二列：#SSS 原样给毫秒
}

///|
test "date #9.6.3 解析侧的接受集（十一档 × 两个键）" {
  assert_eq(@date.custom_parse("1700000000", "#sss"), Some(1700000000000L)) // 读数腿  GF|parse(1700000000,#sss)||1700000000000
  assert_eq(@date.custom_parse("1700000000", "#SSS"), Some(1700000000L)) // 读数腿  GF|parse(1700000000,#SSS)||1700000000
  assert_eq(
    @date.custom_parse("1700000000123", "#sss"),
    Some(1700000000123000L),
  ) // 读数腿  GF|parse(1700000000123,#sss)||1700000000123000
  assert_eq(@date.custom_parse("1700000000123", "#SSS"), Some(1700000000123L)) // 读数腿  GF|parse(1700000000123,#SSS)||1700000000123
  assert_eq(@date.custom_parse("0", "#sss"), Some(0L)) // 读数腿  GF|parse(0,#sss)||0
  assert_eq(@date.custom_parse("0", "#SSS"), Some(0L)) // 读数腿  GF|parse(0,#SSS)||0
  assert_eq(@date.custom_parse("-1", "#sss"), Some(-1000L)) // 读数腿  GF|parse(-1,#sss)||-1000
  assert_eq(@date.custom_parse("-1", "#SSS"), Some(-1L)) // 读数腿  GF|parse(-1,#SSS)||-1
  assert_eq(shape(() => @date.custom_parse("1.5", "#sss")), "NotAnInteger 1.5") // 读数腿  GF|parse(1.5,#sss)||ERR:NumberFormatException:For input string: "1.5" ⇒ 参照 message 带的就是那个原串，本库变体照带
  assert_eq(shape(() => @date.custom_parse("1.5", "#SSS")), "NotAnInteger 1.5") // 读数腿  GF|parse(1.5,#SSS)||ERR:NumberFormatException:For input string: "1.5" ⇒ 参照 message 带的就是那个原串，本库变体照带
  assert_eq(shape(() => @date.custom_parse("", "#sss")), "NotAnInteger ") // 读数腿  GF|parse(,#sss)||ERR:NumberFormatException:For input string: "" ⇒ 参照 message 带的就是那个原串，本库变体照带
  assert_eq(shape(() => @date.custom_parse("", "#SSS")), "NotAnInteger ") // 读数腿  GF|parse(,#SSS)||ERR:NumberFormatException:For input string: "" ⇒ 参照 message 带的就是那个原串，本库变体照带
  assert_eq(shape(() => @date.custom_parse("abc", "#sss")), "NotAnInteger abc") // 读数腿  GF|parse(abc,#sss)||ERR:NumberFormatException:For input string: "abc" ⇒ 参照 message 带的就是那个原串，本库变体照带
  assert_eq(shape(() => @date.custom_parse("abc", "#SSS")), "NotAnInteger abc") // 读数腿  GF|parse(abc,#SSS)||ERR:NumberFormatException:For input string: "abc" ⇒ 参照 message 带的就是那个原串，本库变体照带
  assert_eq(
    shape(() => @date.custom_parse("99999999999999999999", "#sss")),
    "NotAnInteger 99999999999999999999",
  ) // 读数腿  GF|parse(99999999999999999999,#sss)||ERR:NumberFormatException:For input string: "99999999999999999999" ⇒ 参照 message 带的就是那个原串，本库变体照带
  assert_eq(
    shape(() => @date.custom_parse("99999999999999999999", "#SSS")),
    "NotAnInteger 99999999999999999999",
  ) // 读数腿  GF|parse(99999999999999999999,#SSS)||ERR:NumberFormatException:For input string: "99999999999999999999" ⇒ 参照 message 带的就是那个原串，本库变体照带
  assert_eq(
    shape(() => @date.custom_parse(" 1700000000", "#sss")),
    "NotAnInteger  1700000000",
  ) // 读数腿  GF|parse( 1700000000,#sss)||ERR:NumberFormatException:For input string: " 1700000000" ⇒ 参照 message 带的就是那个原串，本库变体照带
  assert_eq(
    shape(() => @date.custom_parse(" 1700000000", "#SSS")),
    "NotAnInteger  1700000000",
  ) // 读数腿  GF|parse( 1700000000,#SSS)||ERR:NumberFormatException:For input string: " 1700000000" ⇒ 参照 message 带的就是那个原串，本库变体照带
  assert_eq(
    shape(() => @date.custom_parse("1700000000 ", "#sss")),
    "NotAnInteger 1700000000 ",
  ) // 读数腿  GF|parse(1700000000 ,#sss)||ERR:NumberFormatException:For input string: "1700000000 " ⇒ 参照 message 带的就是那个原串，本库变体照带
  assert_eq(
    shape(() => @date.custom_parse("1700000000 ", "#SSS")),
    "NotAnInteger 1700000000 ",
  ) // 读数腿  GF|parse(1700000000 ,#SSS)||ERR:NumberFormatException:For input string: "1700000000 " ⇒ 参照 message 带的就是那个原串，本库变体照带
  assert_eq(@date.custom_parse("+1700000000", "#sss"), Some(1700000000000L)) // 读数腿  GF|parse(+1700000000,#sss)||1700000000000
  assert_eq(@date.custom_parse("+1700000000", "#SSS"), Some(1700000000L)) // 读数腿  GF|parse(+1700000000,#SSS)||1700000000
  // 接受集：不 trim、不收小数、不收空串、不收超范围纯数字、**收 `+` 前缀与负号**
}

///|
test "date #9.6.4 `#sss` 的溢出档是另一种错（腿 P5 六档 × 两键）" {
  assert_eq(
    @date.custom_parse("9223372036854775", "#sss"),
    Some(9223372036854775000L),
  ) // 读数腿  P5|overflow臂|parse(9223372036854775,#sss)||9223372036854775000
  assert_eq(
    @date.custom_parse("9223372036854775", "#SSS"),
    Some(9223372036854775L),
  ) // 读数腿  P5|overflow臂|parse(9223372036854775,#SSS)||9223372036854775
  assert_eq(
    shape(() => @date.custom_parse("9223372036854775807", "#sss")),
    "MillisOverflow 9223372036854775807",
  ) // 读数腿  P5|overflow臂|parse(9223372036854775807,#sss)||ERR:ArithmeticException:long overflow ⇒ 参照是 Math.multiplyExact；本库 Int64 乘法静默回绕，必须自己判溢出
  assert_eq(
    @date.custom_parse("9223372036854775807", "#SSS"),
    Some(9223372036854775807L),
  ) // 读数腿  P5|overflow臂|parse(9223372036854775807,#SSS)||9223372036854775807
  assert_eq(
    shape(() => @date.custom_parse("-9223372036854775808", "#sss")),
    "MillisOverflow -9223372036854775808",
  ) // 读数腿  P5|overflow臂|parse(-9223372036854775808,#sss)||ERR:ArithmeticException:long overflow ⇒ 参照是 Math.multiplyExact；本库 Int64 乘法静默回绕，必须自己判溢出
  assert_eq(
    @date.custom_parse("-9223372036854775808", "#SSS"),
    Some(-9223372036854775808L),
  ) // 读数腿  P5|overflow臂|parse(-9223372036854775808,#SSS)||-9223372036854775808
  assert_eq(@date.custom_parse("9223372036", "#sss"), Some(9223372036000L)) // 读数腿  P5|overflow臂|parse(9223372036,#sss)||9223372036000
  assert_eq(@date.custom_parse("9223372036", "#SSS"), Some(9223372036L)) // 读数腿  P5|overflow臂|parse(9223372036,#SSS)||9223372036
  assert_eq(
    shape(() => @date.custom_parse("-9223372036854776", "#sss")),
    "MillisOverflow -9223372036854776",
  ) // 读数腿  P5|overflow臂|parse(-9223372036854776,#sss)||ERR:ArithmeticException:long overflow ⇒ 参照是 Math.multiplyExact；本库 Int64 乘法静默回绕，必须自己判溢出
  assert_eq(
    @date.custom_parse("-9223372036854776", "#SSS"),
    Some(-9223372036854776L),
  ) // 读数腿  P5|overflow臂|parse(-9223372036854776,#SSS)||-9223372036854776
  assert_eq(@date.custom_parse("1700000000", "#sss"), Some(1700000000000L)) // 读数腿  P5|overflow臂|parse(1700000000,#sss)||1700000000000
  assert_eq(@date.custom_parse("1700000000", "#SSS"), Some(1700000000L)) // 读数腿  P5|overflow臂|parse(1700000000,#SSS)||1700000000
  // `#SSS` 那侧没有乘法 ⇒ 同输入不溢出（两列并排就是这条的对照）
}

///|
test "date #9.6.5 未登记的键两表都不给数（不抛错）" {
  assert_eq(@date.custom_parse("2023", "yyyy"), None) // 读数腿  GF|parse(x,plain)||{null} ⇒ 未登记给 None
}

///|
test "date #9.6.6 覆盖与还原内置键（reset 走内置算法复原）" {
  // 覆盖内置键：参照改的就是那张共享表，门面立刻跟着变（腿 GF|override-#sss 三档）
  assert_eq(@date.custom_format(CF_MILLIS, "#sss"), Some("1700000000")) // 读数腿  GF|override-#sss-before||1700000000
  @date.set_custom_format("#sss", ms => "O" + ms.to_string())
  assert_eq(@date.custom_format(CF_MILLIS, "#sss"), Some("O1700000000123")) // 读数腿  GF|override-#sss-after||O1700000000123
  @date.set_custom_format("#sss", ms => (ms / 1000L).to_string())
  assert_eq(@date.custom_format(CF_MILLIS, "#sss"), Some("1700000000")) // 读数腿  GF|override-#sss-还原||1700000000
  @date.reset_custom_format("#sss")
  assert_eq(@date.custom_format(CF_MILLIS, "#sss"), Some("1700000000")) // 读数腿  reset 之后必须回到**内置算法**（同一条读数 override-#sss-还原），而不是把键删掉
}

///|
test "date #9.6.7 两张表的不对称（parser-only 隐形 / formatter-only 看得见 / 收尾自证）" {
  // 只登记 parser ⇒ 门面上隐形（参照 isCustomFormat 只查 formatter 表，字节码现读）
  @date.set_custom_parser("#ponly", _ => 42L)
  assert_eq(@date.is_custom_format("#ponly"), false) // 读数腿  P5|parser-only|isCustomFormat||false
  assert_eq(@date.custom_parse("x", "#ponly"), Some(42L)) // 读数腿  P5|parser-only|GlobalCustomFormat.parse||42 ⇒ 直接查表仍然通
  assert_eq(@date.custom_format(CF_MILLIS, "#ponly"), None) // 读数腿  P5|parser-only|DateUtil.parse(走不走这张表)||ERR:IllegalArgumentException:Illegal pattern character 'p' ⇒ 参照走的是 pattern 支并直接抛；本库 formatter 表没这个键 ⇒ None
  // 只登记 formatter ⇒ 看得见，但 parse 那侧没有落落点
  @date.set_custom_format("#fonly", ms => "F" + ms.to_string())
  assert_eq(@date.is_custom_format("#fonly"), true) // 读数腿  P5|formatter-only|isCustomFormat||true
  assert_eq(@date.custom_format(CF_MILLIS, "#fonly"), Some("F1700000000123")) // 读数腿  P5|formatter-only|DateUtil.format||F1700000000123
  assert_eq(@date.custom_parse("F1700000000123", "#fonly"), None) // 读数腿  P5|formatter-only|GlobalCustomFormat.parse||{null} ⇒ 参照的 DateUtil.parse 这一档给『现在』（P5|formatter-only|DateUtil.parse 带 (是不是现在?true) 自证），本库给 None：见 §9.8 第 6 行
  // 补齐 parser 之后 parse 才通得动（腿 P5|pair 三档）
  @date.set_custom_parser("#pair", _ => 7L)
  assert_eq(@date.is_custom_format("#pair"), false) // 读数腿  P5|pair|补 formatter 之前 isCustom||false
  @date.set_custom_format("#pair", _ => "P")
  assert_eq(@date.is_custom_format("#pair"), true) // 读数腿  P5|pair|补上之后 isCustom||true
  assert_eq(@date.custom_parse("x", "#pair"), Some(7L)) // 读数腿  P5|pair|补上之后 DateUtil.parse||7
  @date.reset_custom_format("#ponly")
  @date.reset_custom_format("#fonly")
  @date.reset_custom_format("#pair")
  assert_eq(@date.is_custom_format("#sss"), true) // 读数腿  P5|收尾|isCustom(#sss)||true
  assert_eq(@date.custom_format(CF_MILLIS, "#sss"), Some("1700000000")) // 读数腿  P5|收尾|#sss 读数||1700000000 ⇒ 前面动的都是别的键，内置档不许被牵连
}

///|
test "date #9.6.9 parseLong 文法边界、非 ASCII 数码的主动窄一档与 #SSS 的 reset" {
  // 参照 Long.parseLong 走 Character.digit(ch, 10)，它**认非 ASCII 的十进制数码**；
  // 本库只收 ASCII 0-9（core 没有 Unicode Nd 表，做假承诺比窄一档更坏）⇒ 这两档是明写的分岔，
  // 期望串是本库形状、参照那一侧的原读数留在注释里（spec §9.6 末行）。
  assert_eq(shape(() => @date.custom_parse("+", "#sss")), "NotAnInteger +") // 读数腿  JU|parseLong|+||ERR:NumberFormatException:For input string: "+"
  assert_eq(shape(() => @date.custom_parse("-", "#sss")), "NotAnInteger -") // 读数腿  JU|parseLong|-||ERR:NumberFormatException:For input string: "-"
  assert_eq(shape(() => @date.custom_parse("--1", "#sss")), "NotAnInteger --1") // 读数腿  JU|parseLong|--1||ERR:NumberFormatException:For input string: "--1"
  assert_eq(
    shape(() => @date.custom_parse("0x10", "#sss")),
    "NotAnInteger 0x10",
  ) // 读数腿  JU|parseLong|0x10||ERR:NumberFormatException:For input string: "0x10"
  assert_eq(@date.custom_parse("-0", "#sss"), Some(0L)) // 读数腿  JU|parseLong|-0||0
  assert_eq(@date.custom_parse("010", "#sss"), Some(10000L)) // 读数腿  JU|parseLong|010||10 ⇒ 前导零照收，GCF#sss 那侧 10000
  assert_eq(
    shape(() => @date.custom_parse("9223372036854775808", "#SSS")),
    "NotAnInteger 9223372036854775808",
  ) // 读数腿  JU|parseLong|9223372036854775808||ERR:NumberFormatException:For input string: "9223372036854775808"
  assert_eq(
    @date.custom_parse("9223372036854775807", "#SSS"),
    Some(9223372036854775807L),
  ) // 读数腿  JU|parseLong|9223372036854775807||9223372036854775807
  assert_eq(
    shape(() => @date.custom_parse("-9223372036854775809", "#SSS")),
    "NotAnInteger -9223372036854775809",
  ) // 读数腿  JU|parseLong|-9223372036854775809||ERR:NumberFormatException:For input string: "-9223372036854775809" —— 负半边的界与正半边差 1，两侧各一条才夹得住
  assert_eq(
    @date.custom_parse("-9223372036854775808", "#SSS"),
    Some(-9223372036854775808L),
  ) // 读数腿  JU|parseLong|-9223372036854775808||-9223372036854775808
  assert_eq(
    shape(() => @date.custom_parse("9223372036854775807", "#sss")),
    "MillisOverflow 9223372036854775807",
  ) // 读数腿  JU|GCF#sss|9223372036854775807||ERR:ArithmeticException:long overflow ⇒ parseLong 过得去、乘 1000 溢出，是另一种错
  assert_eq(shape(() => @date.custom_parse("٣", "#SSS")), "NotAnInteger ٣") // 读数腿  JU|parseLong|{u0663}||3 —— 参照给 3，本库按 ASCII 档拒
  assert_eq(shape(() => @date.custom_parse("1٣", "#SSS")), "NotAnInteger 1٣") // 读数腿  JU|parseLong|1{u0663}||13 —— 参照给 13，本库整串拒
  // 撤销**毫秒档**内置键：覆盖立刻生效、reset 之后回到内置算法（与 #9.6.6 那档同判据的另一侧）
  @date.set_custom_format("#SSS", ms => "Z" + ms.to_string())
  assert_eq(@date.custom_format(CF_MILLIS, "#SSS"), Some("Z1700000000123")) // 规则腿  同 #9.6.6：覆盖内置键改的是共享表
  @date.reset_custom_format("#SSS")
  assert_eq(@date.custom_format(CF_MILLIS, "#SSS"), Some("1700000000123")) // 读数腿  GF|format(d,#SSS)||1700000000123 ⇒ reset 复原内置
}

///|
test "date #9.6.8 挂载点：命中查表、普通档不被污染、reset 后交回 pattern 判据" {
  // 挂进门面件：命中键就查表，区名与 pattern token 都不参与（腿 F 行）
  assert_eq(
    @date.format_in(CF_MILLIS, "#sss", "Asia/Shanghai"),
    Some("1700000000"),
  ) // 读数腿  F|DateUtil.format(#sss)||1700000000（参照那档吃机器默认区；本库区名必填而这一档**不随区变**）
  assert_eq(@date.format_in(CF_MILLIS, "#sss", "UTC"), Some("1700000000")) // 读数腿  同上，换区名读数不变 ⇒ 这条就是「区名不参与」的判别夹具（F 行同一条读数）
  assert_eq(@date.parse_local("1700000000", "#sss"), Some(1700000000000L)) // 读数腿  GF|parse(1700000000,#sss)||1700000000000 同一条走门面
  @date.set_custom_format("mine", ms => "M" + ms.to_string())
  assert_eq(@date.format_local(CF_MILLIS, "mine"), Some("M1700000000123")) // 读数腿  F|after-put|DateUtil.format(mine)||M1700000000123
  assert_eq(@date.format_local(CF_MILLIS, "yyyy-MM-dd"), Some("2023-11-15")) // 读数腿  F|DateUtil.format(plain)||2023-11-15
  assert_eq(@date.is_custom_format("yyyy-MM-dd"), false) // 读数腿  F|after-put|isCustom(yyyy-MM-dd)||false
  @date.reset_custom_format("mine")
  assert_eq(@date.is_custom_format("mine"), false) // 规则腿  复位后 `mine` 不再是自定义档 ⇒ 门面件交回 §2.6 的 pattern 判据（表外 token 必抛，那条早已冻）
}
