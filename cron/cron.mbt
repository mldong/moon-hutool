///|
// moon-hutool/cron —— cron 表达式的解析、匹配与"下一个匹配时刻"
// 对位 hutool `cn.hutool.cron.pattern.CronPattern`——**件不在 hutool-core**
// （`unzip -l hutool-core.jar | grep -ic cron` 现读 0 条），全在独立 artifact `hutool-cron-5.8.35.jar`。
// 契约真相在 `docs/spec/19-cron.md`；本文件是签名骨架——函数体是 abort，落地笔（PR-B）替换。
//
// 一句话口径：段数 5~7、子表达式文法 `,` `-` `/`（优先级 `/ > - > ,`）、`*` 与 `?` 同义、
// 月份与星期有大小写不敏感的别名、`L` 只在"日"段单 token 时是月末、
// `日` 与 `周` 同时限定是**且**、不存在的日子（4 月 31 日）**夹到月末**、
// 秒段默认不参与匹配、年段"解析但不匹配"、下一时刻毫秒恒 0。
// **只算不调度**：参照侧的 `CronUtil`/`Scheduler`/`TaskTable`/`timingwheel/*` 整族不做（spec §1）。
// 时刻一律收 `@date.DateTime`（无时区入口）——参照侧的 `match(long millis, …)` 走
// `TimeZone.getDefault()`，同输入在两台上两读（腿里 `sys.default_tz` 为凭），本库不跟随。

///|
/// #19.1 解析错误面。每一档都对应参照侧一条实测消息（原文留在 spec §3 与 §4 腿 A），
/// 但本库**只带档名与 offending 文本**，不复制 Java 的消息模板——模板随 hutool 版本变，
/// 契约要钉的是"哪一档、哪一段、哪个值"（spec §5 第 4 行）
pub suberror CronError {
  /// 段数不在 5~7：参照 `CronException:Pattern [* * * *] is invalid, it must be 5-7 parts!`；
  /// 空串与纯空白参照**不报错**（解析成空匹配器，取下一时刻时才 NPE），本库挪到这里报（spec §5 第 2 行）
  BadParts(String)
  /// 子表达式整体不可解析：参照 `Invalid part value: [{}]`
  BadValue(String)
  /// 别名不认识（含 `LW`、`15L`，以及参照侧漏出来的星期 `5L`/`6L`/`FRI#2`——
  /// 参照对后三条抛的是 `IllegalArgumentException: No enum constant …Week.5L`，本库收进同一档）
  BadAlias(String)
  /// 值落在该段区间之外：参照 `MINUTE value 60 out of range: [0 , 59]`；
  /// `-1` 这类"长度 ≤2 的负数"参照会绕过区间校验，本库按同一把尺子报错（spec §5 第 5 行）
  OutOfRange(String, Int)
  /// 步进 ≤ 0：参照 `Non positive divisor for field: [*/0]`
  NonPositiveStep(String)
  /// 语法形状错（多于一个 `/` 等）：参照 `Invalid syntax of field: [{}]`
  BadSyntax(String)
}

///|
/// #19.2 解析后的表达式。内部是"若干匹配器的或"（参照侧支持 `cronA|cronB` 多选表达式），
/// 结构对本包外不可见——本包只暴露判定与下一时刻，不暴露匹配器形状
pub struct Cron {
  text : String
}

///|
/// 解析表达式。段数 5~7：5 段 = 分/时/日/月/周；6 段第一位是**秒**；7 段最后一位是**年**（1970~2099）。
/// 每段的文法：`*`、`?`（与 `*` 同义）、列表 `a,b,c`（**去重**）、区间 `a-b`（反向区间照收）、
/// 步进 `a/b`（`/` 优先于 `-` 优先于 `,`，故 `2,3,6/3` ≡ `{2,3,6}`）、
/// 月份与星期的大小写不敏感别名（`jan`~`dec`、`sun`~`sat`）、星期 `0` 与 `7` 都表示周日、
/// "日"段的单 token `L` 表示当月最后一天。
///
/// - Parameters:
///   - `pattern`：原始表达式，**原样保存**（不去空白、不规范化，见 #19.6）
/// - Returns: 解析后的表达式
/// - Raises: `CronError` 六档之一（逐档的参照消息在 spec §3 与 §4 腿 A 的 `ok.*` 读数里）
/// - Note: hutool 对位 `CronPattern.of(String)` / `new CronPattern(String)`
pub fn cron_of(pattern : String) -> Cron raise CronError {
  abort("moon-hutool cron: 契约已冻结，实现待落地")
}

///|
/// 给定本地时刻是否匹配。秒段**默认不参与匹配**（参照同一条：`isMatchSecond` 关掉时第一位被忽略）。
/// 各段全部命中才算命中；`日` 与 `周` 同时限定时是**且**（不是 Quartz 的或——
/// 读数 `m.19.*` 全表：`0 12 1 * MON` 在 2024-06-01（周六）为假）。
///
/// - Parameters:
///   - `c`：#19.2 解析结果
///   - `dt`：本地时刻（无时区；偏移由调用方决定，理由见本文件头）
///   - `match_second`：是否让秒段参与匹配，默认 `false`
/// - Returns: 是否匹配
/// - Raises: 无（解析失败已经在 #19.2 报过）
/// - Note: hutool 对位 `boolean match(LocalDateTime, boolean)`。参照另有 `match(long millis, …)`
///   与 `match(TimeZone, …)` 两个入口，它们依赖 `TimeZone.getDefault()` ⇒ 不跟随（spec §5 第 1 行）
pub fn cron_match(
  c : Cron,
  dt : @date.DateTime,
  match_second? : Bool = false,
) -> Bool {
  abort("moon-hutool cron: 契约已冻结，实现待落地")
}

///|
/// 严格晚于给定时刻的下一个匹配时刻，**毫秒恒为 0**。
/// 若给定时刻本身已经匹配，参照先加 1 秒再找（它自己注释点了 issue#I9FQUA）⇒
/// 与 #19.4 在同一条基线上成对分岔（`nx.11.0|2024-03-31 12:00:00` 对 `nm.11.0|2024-02-29 12:00:00`）。
///
/// - Parameters:
///   - `c`：#19.2 解析结果
///   - `dt`：基准时刻（本地时刻，毫秒不参与）
/// - Returns: 下一个匹配时刻。年份段不参与匹配 ⇒ 参照侧在 2099 之后照样给出（`nx.17.5|2100-01-03 12:00:00`），
///   本库同点跟随；不接受"找不到就报错"的形状（`日` 段的月末夹取保证每个合法模式都有解，spec §3 第 10 条）
/// - Raises: 无
/// - Note: hutool 对位 `Calendar nextMatchAfter(Calendar)`
pub fn cron_next_match_after(c : Cron, dt : @date.DateTime) -> @date.DateTime {
  abort("moon-hutool cron: 契约已冻结，实现待落地")
}

///|
/// 下一个匹配时刻，但**给定时刻本身已匹配就直接返回它**（参照 5.8.30 才加的这件，与 #19.3 成对）。
///
/// - Parameters:
///   - `c`：#19.2 解析结果
///   - `dt`：基准时刻
/// - Returns: 已匹配则原样返回（毫秒归零），否则同 #19.3
/// - Raises: 无
/// - Note: hutool 对位 `Calendar nextMatch(Calendar)`；参照实现里它带一段"下一次进入新一天再试"的递归回退，
///   本库把回退做成显式循环（语义同，栈深度不随模式变）
pub fn cron_next_match(c : Cron, dt : @date.DateTime) -> @date.DateTime {
  abort("moon-hutool cron: 契约已冻结，实现待落地")
}

///|
/// 原样取回表达式文本（**不去空白、不规范化、不重排**）。
///
/// - Parameters:
///   - `c`：#19.2 解析结果
/// - Returns: 传入的原文。参照侧 `toString()` 就是这个语义，读数里最直白的一条是
///   `ok.43|OK:   `（三个空格原样回来）
/// - Raises: 无
/// - Note: hutool 对位 `String toString()`。本库不叫 `to_string` 以免与 `Show` 撞名，
///   也不承诺 `Debug` 形状（那是 `@debug` 的事）
pub fn cron_pattern_text(c : Cron) -> String {
  abort("moon-hutool cron: 契约已冻结，实现待落地")
}
