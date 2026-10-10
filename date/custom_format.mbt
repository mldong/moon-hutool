///|
// moon-hutool/date —— 全局自定义格式表（ROADMAP 第 3 行第六批）
// 契约真相在 `docs/spec/03-date.md` §9.6；读数来源 `scripts/TimerLeg3.java` 的 `GF` 行、
// `scripts/TimerLeg4.java` 的 `EP` 行、`scripts/TimerLeg5.java` 的 `P5` 行。
//
// 两件必须先交代清楚，否则下面的形状会被读成"设计偏好"：
// ① **两张表不对称**——参照 `isCustomFormat` 只查 formatter 表（字节码现读 `formatterMap.containsKey`），
//   于是"只登记 parser 的键"在门面上是隐形的，`DateUtil.parse` 的挂载点被这个判据挡住、根本不去查 parser 表
//   （腿 `P5|parser-only` 三档：`isCustomFormat` false、直接调 `GlobalCustomFormat.parse` 反倒通、
//   走 `DateUtil.parse` 得到的是 `IllegalArgumentException: Illegal pattern character 'p'`）。
//   本库照抄这条不对称，**不"顺手统一"**：统一了就改挂载行为。
// ② **进程级可变状态按本包既有口径处理**——显式 set、显式 reset，同 `set_default_zone`/`reset_default_zone`。
//   census 里这件的登记理由本来就写着这句（现读 `docs/spec/00-hutool-map.md` §7 第三批那段）。

///|
/// 秒档键（对位 `GlobalCustomFormat.FORMAT_SECONDS`；值由腿 `GF` 行现读，不手抄）
pub let custom_format_seconds : String = "#sss"

///|
/// 毫秒档键（对位 `GlobalCustomFormat.FORMAT_MILLISECONDS`，同上现读）
pub let custom_format_milliseconds : String = "#SSS"

///|
/// 这个键在**formatter 表**里吗（参照 `isCustomFormat(String)` 就只查这一张表）
///
/// - Note: 大小写**敏感**——注册 `#MiX` 之后 `isCustomFormat("#mix")` 是 `false`（腿 `GF` 行）。
/// - Note: 参照传 `null` 抛 NPE（`ConcurrentHashMap` 不接受 null 键）；本库类型到不了那一档。
pub fn is_custom_format(key : String) -> Bool {
  let _ = key
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.6 与腿 GF 行九档")
}

///|
/// 登记/覆盖一个键的格式化函数（参照 `putFormatter(String, Function<Date,String>)`）
///
/// - Parameters:
///   - fmt: 入参是 **epoch 毫秒**（参照的 `Date` 在那条 lambda 里只被 `getTime()` 用了一次）
/// - Note: 覆盖内置键是参照的真行为：注册 `#sss` 之后 `format_*` 立刻改口，改回来也只需一次覆盖
///   （腿 `GF|override-#sss-before/after/还原` 三档）。
pub fn set_custom_format(key : String, fmt : (Int64) -> String) -> Unit {
  let _ = (key, fmt)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.6")
}

///|
/// 登记一个键的解析函数（参照 `putParser(String, Function<CharSequence,Date>)`）
///
/// - Parameters:
///   - parser: 入参是**不 trim** 的原串，返回 epoch 毫秒。参照那侧抛 unchecked 异常
///     （`NumberFormatException` / `ArithmeticException`），本库换成 `DateError` 的两个带读数变体。
/// - Note: 只登记 parser **不会**让这个键变成"自定义格式"（见本文件头注 ①）。
pub fn set_custom_parser(
  key : String,
  parser : (String) -> Int64 raise DateError,
) -> Unit {
  let _ = (key, parser)
  abort(
    "PR-B：契约骨架，docs/spec/03-date.md §9.6 与腿 P5|pair 三档",
  )
}

///|
/// 直接查 formatter 表算串（参照 `format(Date, CharSequence)`）
///
/// - Returns: 键未登记 ⇒ `None`（参照给 `null`，腿 `GF|format(d,plain)`）。**不抛错、不回落**到普通 pattern。
pub fn custom_format(millis : Int64, key : String) -> String? {
  let _ = (millis, key)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.6")
}

///|
/// 直接查 parser 表算瞬间（参照 `parse(CharSequence, String)`）
///
/// - Returns: 键未登记 ⇒ `None`（腿 `GF|parse(x,plain)`）
/// - Raises:
///   - `NotAnInteger(text)`——参照 `Long.parseLong` 拒的六档：不 trim、不收小数、不收空串、不收超范围纯数字
///     （腿 `GF|parse(...)` 十二档，message 里带的就是那个原串）
///   - `MillisOverflow(text)`——`#sss` 档内部是 `multiplyExact(n, 1000)`，"parseLong 过得去、乘 1000 溢出"
///     是另一种异常（腿 `P5|overflow臂`：`9223372036854775` 溢出、`9223372036` 通过）。
///     MoonBit 的 `Int64` 乘法溢出是**静默回绕**，所以这条必须本库自己判，不能跟回绕。
pub fn custom_parse(text : String, key : String) -> Int64? raise DateError {
  let _ = (text, key)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.6 与腿 P5 行")
}

///|
/// 撤销登记：内置两档**复原**成参照的默认算法、自定义键**删除**。
///
/// - Note: 本库自订档（参照没有删除口）。理由同 `reset_default_zone`：没有它，一次注册就不可逆，
///   测试现场也无法复位。**代价如实写**：它是进程级可变状态，同进程内跨用例可见 ⇒
///   碰过 `set_custom_*` 的用例必须自己收尾（spec §9.8 第 4 行）。
pub fn reset_custom_format(key : String) -> Unit {
  let _ = key
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.6")
}
