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
/// 内置 `#sss` 的格式化。参照那支 lambda 字节码现读是 `Math.floorDiv(getTime(), 1000)`
/// ⇒ **向下取整，不是向零截断**：`-999` 毫秒给 `-1`（向零会给 `0`），`-1001` 给 `-2`（腿 `EP` 行三档齐）。
/// 与本包 §0.3 那条"epoch 相关除法一律向下取整"同族，落点复用 `date.mbt` 里的 `floor_div`。
fn builtin_seconds(millis : Int64) -> String {
  floor_div(millis, 1000L).to_string()
}

///|
/// 内置 `#SSS` 的格式化：毫秒原样（腿 `EP` 行第二列）。
fn builtin_millis(millis : Int64) -> String {
  millis.to_string()
}

///|
/// `#sss` 的解析。参照现读是 `Math.multiplyExact(parseLong(text), 1000)` ⇒
/// "parseLong 过得去、乘 1000 溢出"是**另一种异常**（`ArithmeticException: long overflow`，腿 `P5` 六档）。
/// MoonBit 的 `Int64` 乘法溢出是**静默回绕**（AGENTS conv 轮那条实测），所以这里先判界再乘，不跟回绕。
fn parse_seconds(text : String) -> Int64 raise DateError {
  let n = parse_long(text)
  if n > I64_MAX / 1000L || n < I64_MIN / 1000L {
    raise MillisOverflow(text)
  }
  n * 1000L
}

///|
/// `#SSS` 的解析：没有那一步乘法 ⇒ 同输入不溢出（腿 `P5` 两列并排就是这条对照）。
fn parse_millis(text : String) -> Int64 raise DateError {
  parse_long(text)
}

///|
/// Java `Long.parseLong` 那套文法：不 trim、收 `+` 与 `-` 前缀、其余必须全是数字、超范围报错。
///
/// 为什么不交给 core：`@string.parse_int` 收下划线分隔与 `0x` 前缀（AGENTS conv 轮实测），
/// 比参照宽——直接喂就等于把"能不能解析"的判据换成另一套文法，`"1_000"` 那种档会静默多收。
fn parse_long(text : String) -> Int64 raise DateError {
  let cs = text.to_array()
  if cs.length() == 0 {
    raise NotAnInteger(text)
  }
  let mut i = 0
  let mut neg = false
  if cs[0] == '+' {
    i = 1
  } else if cs[0] == '-' {
    neg = true
    i = 1
  }
  if i >= cs.length() {
    // 只剩一个符号也算空（腿 `GF|parse(,#sss)` 那档参照 message 是 `For input string: ""`）
    raise NotAnInteger(text)
  }
  let mut acc : Int64 = 0
  while i < cs.length() {
    let code = cs[i].to_int()
    if code < 48 || code > 57 {
      raise NotAnInteger(text)
    }
    let d = (code - 48).to_int64()
    // 先判界再累积：正负两侧各自的界不同（`-9223372036854775808` 是合法值，必须收）
    if neg {
      if acc < (I64_MIN + d) / 10L {
        raise NotAnInteger(text)
      }
      acc = acc * 10L - d
    } else {
      if acc > (I64_MAX - d) / 10L {
        raise NotAnInteger(text)
      }
      acc = acc * 10L + d
    }
    i += 1
  }
  acc
}

///|
/// formatter 表（参照是静态 `SafeConcurrentHashMap`，本库全同步、**不承诺并发可见性**，§9.8 第 4 行）。
/// 内置两档在这里播种 ⇒ `reset_custom_format` 能把它们复原成下面这两个函数，而不是删掉。
let fmt_slot : Map[String, (Int64) -> String] = Map([
  (custom_format_seconds, builtin_seconds),
  (custom_format_milliseconds, builtin_millis),
])

///|
/// parser 表。它与上一张**各自独立**，"只登记 parser 的键在门面上隐形"那条不对称才成立（§9.6 开头）。
let parse_slot : Map[String, (String) -> Int64 raise DateError] = Map([
  (custom_format_seconds, parse_seconds),
  (custom_format_milliseconds, parse_millis),
])

///|
/// 这个键在**formatter 表**里吗（参照 `isCustomFormat(String)` 就只查这一张表）
///
/// 示例见 `date/README.mbt.md` 的「全局自定义格式表」一节。
///
/// - Note: 大小写**敏感**——注册 `#MiX` 之后 `isCustomFormat("#mix")` 是 `false`（腿 `GF` 行）。
/// - Note: 参照传 `null` 抛 NPE（`ConcurrentHashMap` 不接受 null 键）；本库类型到不了那一档。
pub fn is_custom_format(key : String) -> Bool {
  // 参照只查 formatter 表（字节码现读 formatterMap.containsKey）⇒ 两张表的不对称照抄
  fmt_slot.contains(key)
}

///|
/// 登记/覆盖一个键的格式化函数（参照 `putFormatter(String, Function<Date,String>)`）
///
/// - Parameters:
///   - fmt: 入参是 **epoch 毫秒**（参照的 `Date` 在那条 lambda 里只被 `getTime()` 用了一次）
/// - Note: 覆盖内置键是参照的真行为：注册 `#sss` 之后 `format_*` 立刻改口，改回来也只需一次覆盖
///   （腿 `GF|override-#sss-before/after/还原` 三档）。
pub fn set_custom_format(key : String, fmt : (Int64) -> String) -> Unit {
  fmt_slot[key] = fmt
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
  parse_slot[key] = parser
}

///|
/// 直接查 formatter 表算串（参照 `format(Date, CharSequence)`）
///
/// - Returns: 键未登记 ⇒ `None`（参照给 `null`，腿 `GF|format(d,plain)`）。**不抛错、不回落**到普通 pattern。
pub fn custom_format(millis : Int64, key : String) -> String? {
  match fmt_slot.get(key) {
    None => None
    Some(fmt) => Some(fmt(millis))
  }
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
  match parse_slot.get(key) {
    None => None
    Some(parser) => Some(parser(text))
  }
}

///|
/// 撤销登记：内置两档**复原**成参照的默认算法、自定义键**删除**。
///
/// - Note: 本库自订档（参照没有删除口）。理由同 `reset_default_zone`：没有它，一次注册就不可逆，
///   测试现场也无法复位。**代价如实写**：它是进程级可变状态，同进程内跨用例可见 ⇒
///   碰过 `set_custom_*` 的用例必须自己收尾（spec §9.8 第 4 行）。
pub fn reset_custom_format(key : String) -> Unit {
  if key == custom_format_seconds {
    fmt_slot[key] = builtin_seconds
    parse_slot[key] = parse_seconds
  } else if key == custom_format_milliseconds {
    fmt_slot[key] = builtin_millis
    parse_slot[key] = parse_millis
  } else {
    let _ = fmt_slot.remove(key)
    let _ = parse_slot.remove(key)
  }
}
