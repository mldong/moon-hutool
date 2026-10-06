///|
// moon-hutool/cron —— cron 表达式的解析、匹配与"下一个匹配时刻"
// 对位 hutool `cn.hutool.cron.pattern.CronPattern`——**件不在 hutool-core**
// （`unzip -l hutool-core.jar | grep -ic cron` 现读 0 条），全在独立 artifact `hutool-cron-5.8.35.jar`。
// 契约真相在 `docs/spec/19-cron.md`；期望值全部来自参照腿读数（`cron/cron_test.mbt` 的标签注释）。
//
// 一句话口径：段数 5~7、子表达式文法 `,` `-` `/`（优先级 `/ > - > ,`）、`*` 与 `?` 同义、
// 月份与星期有大小写不敏感的别名、`L` 只在"日"段单 token 时是月末、
// `日` 与 `周` 同时限定是**且**、不存在的日子（4 月 31 日）**夹到月末**、
// 秒段默认不参与匹配、年档只有 7 段式才存在并参与匹配、下一时刻毫秒恒 0。
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
  /// #19.19 的窗口判据：`start >= end`。参照 `Assert.isTrue(start < end, "Start date is later than end !")`
  /// 抛的是 `IllegalArgumentException`（不是 `CronException`），文案里没有值 ⇒ 本库带两个瞬间进来。
  /// 第二批新增（additive，spec §11 第 7 行）
  BadRange(Int64, Int64)
}

///|
/// #19.2 解析后的表达式。内部是"若干匹配器的或"（参照侧支持 `cronA|cronB` 多选表达式），
/// 结构对本包外不可见——本包只暴露判定与下一时刻，不暴露匹配器形状
pub struct Cron {
  text : String
  priv subs : Array[Sub]
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
  // 参照 PatternParser.parseGroupPattern：StrUtil.splitTrim(pattern, '|')——trim + 丢空。
  // 全空（"" 与 "   "）时参照得到**零个匹配器**而不报错，到取下一时刻才 NPE；本库挪回解析期（spec §5 第 2 行）
  let pieces = pipe_split(pattern)
  if pieces.length() == 0 {
    raise BadParts(pattern)
  }
  let subs : Array[Sub] = []
  for p in pieces {
    subs.push(parse_single(p))
  }
  { text: pattern, subs, }
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
  let f = fields_of(dt, match_second)
  let mut r = false
  for s in c.subs {
    // 参照 CronPattern.match(int[])：若干匹配器取**或**
    if sub_match(s.ms, f) {
      r = true
      break
    }
  }
  r
}

///|
/// 严格晚于给定时刻的下一个匹配时刻，**毫秒恒为 0**。
/// 若给定时刻本身已经匹配，参照先加 1 秒再找（它自己注释点了 issue#I9FQUA）⇒
/// 与 #19.4 在同一条基线上成对分岔（`nx.11.0|2024-03-31 12:00:00` 对 `nm.11.0|2024-02-29 12:00:00`）。
///
/// - Parameters:
///   - `c`：#19.2 解析结果
///   - `dt`：基准时刻（本地时刻，毫秒不参与）
/// - Returns: 下一个匹配时刻。5/6 段式**没有年档**（年档恒真）⇒ 参照侧在 2099 之后照样给出
///   （`nx.17.5|2100-01-03 12:00:00`），本库同点跟随；7 段式的年档**参与匹配**（`m.33.*`/`nx.33.*`）。
///   年档全部落在过去时参照抛 `IllegalArgumentException:Invalid matcher: YearValueMatcher`，
///   本库按参照自己"以下所有值置为最小值"的规矩回绕到年集合最小值（spec §5 第 9 行，两侧读数都在案）
/// - Raises: 无
/// - Note: hutool 对位 `Calendar nextMatchAfter(Calendar)`
pub fn cron_next_match_after(c : Cron, dt : @date.DateTime) -> @date.DateTime {
  // 参照 issue#I9FQUA：已匹配时先 +1000ms，否则永远停在原地
  let base = if cron_match(c, dt, match_second=true) {
    @date.DateTime::from_epoch_millis(dt.to_epoch_millis(0) + 1000L, 0)
  } else {
    dt
  }
  cron_next_match(c, base)
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
  let mut cur = dt
  let mut cand = earliest(c, fields_of(cur, true))
  // 参照 nextMatch：候选不成立就"次日 00:00:00"重来（周段不参与字段推进，只能靠这一条兜）
  while !cron_match(c, cand, match_second=true) {
    cur = day_start(cand.date.add_days(1))
    cand = earliest(c, fields_of(cur, true))
  }
  cand
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
  c.text
}

///|
// ---------- 以下为内部件：段序号 0..6 = 秒/分/时/日/月/周/年（与参照 Part.ordinal() 同序） ----------

///|
// 段名只用于 OutOfRange 的携带值，取参照 Part.name() 的字面（spec §5 第 4 行：钉"哪一档"，不复制模板）
fn part_name(i : Int) -> String {
  match i {
    0 => "SECOND"
    1 => "MINUTE"
    2 => "HOUR"
    3 => "DAY_OF_MONTH"
    4 => "MONTH"
    5 => "DAY_OF_WEEK"
    _ => "YEAR"
  }
}

///|
fn part_lo(i : Int) -> Int {
  match i {
    3 | 4 => 1
    6 => 1970
    _ => 0
  }
}

///|
fn part_hi(i : Int) -> Int {
  match i {
    0 | 1 => 59
    2 => 23
    3 => 31
    4 => 12
    5 => 6
    _ => 2099
  }
}

///|
// 参照侧三档 PartMatcher：AlwaysTrueMatcher / BoolArrayMatcher（日档是其子类）/ YearValueMatcher
priv enum PmKind {
  PmAlways
  PmBool
  PmYear
}

///|
priv struct Pm {
  kind : PmKind
  bits : Array[Bool] // PmBool：下标即值，长度 = 集合最大值 + 1（与参照的 boolean[] 同形）
  min : Int // PmBool：集合最小值；PmYear：年集合最小值
  years : Array[Int] // PmYear：升序去重
  last : Bool // 日档专用：集合含 31 ⇒ 参照 DayOfMonthMatcher.isLast()
}

///|
fn pm_always() -> Pm {
  { kind: PmAlways, bits: [], min: 0, years: [], last: false, }
}

///|
fn has_int(arr : Array[Int], x : Int) -> Bool {
  let mut found = false
  for v in arr {
    if v == x {
      found = true
      break
    }
  }
  found
}

///|
fn pm_match(m : Pm, v : Int) -> Bool {
  match m.kind {
    PmAlways => true
    // 参照：value == null || value >= bValues.length() ⇒ false
    PmBool => v >= 0 && v < m.bits.length() && m.bits[v]
    PmYear => has_int(m.years, v)
  }
}

///|
fn pm_next_after(m : Pm, v : Int) -> Int {
  match m.kind {
    PmAlways => v
    PmYear => {
      let mut r = -1
      for y in m.years {
        if y >= v {
          r = y
          break
        }
      }
      r
    }
    PmBool =>
      if v > m.min {
        let mut j = v
        let n = m.bits.length()
        while j < n {
          if m.bits[j] {
            break
          }
          j += 1
        }
        if j < n {
          j
        } else {
          m.min
        }
      } else {
        m.min
      }
  }
}

///|
// 参照 PatternMatcher.getMin：AlwaysTrue ⇒ 段下界，BoolArray ⇒ 集合最小值。
// 参照对 YearValueMatcher 在这一条上抛 IllegalArgumentException:Invalid matcher（腿读数 nx.34.*/nm.34.*），
// 本库按参照自己"以下所有值置为最小值"的规矩给年集合的最小值（spec §5 第 9 行）
fn pm_min(m : Pm, part : Int) -> Int {
  match m.kind {
    PmAlways => part_lo(part)
    PmBool => m.min
    PmYear => m.years[0]
  }
}

///|
// 一个子表达式 = 7 段匹配器
priv struct Sub {
  ms : Array[Pm]
}

///|
fn is_match_all(v : String) -> Bool {
  // 参照 isMatchAllStr：长度 1 且是 `*` 或 `?`
  v == "*" || v == "?"
}

///|
fn parse_int_opt(v : String) -> Int? {
  let cs = v.to_array()
  let n = cs.length()
  if n == 0 {
    return None
  }
  let neg = cs[0] == '-'
  let mut i = if neg || cs[0] == '+' { 1 } else { 0 }
  if i >= n {
    return None
  }
  let mut acc = 0
  while i < n {
    let c = cs[i]
    if c < '0' || c > '9' {
      return None
    }
    acc = acc * 10 + (c.to_int() - 48)
    if acc > 100000000 {
      return None // 参照 Integer.parseInt 溢出 ⇒ 走别名档 ⇒ BadAlias
    }
    i += 1
  }
  Some(if neg { 0 - acc } else { acc })
}

///|
fn month_alias(s : String) -> Int? {
  match s.to_lower() {
    "jan" | "january" => Some(1)
    "feb" | "february" => Some(2)
    "mar" | "march" => Some(3)
    "apr" | "april" => Some(4)
    "may" => Some(5)
    "jun" | "june" => Some(6)
    "jul" | "july" => Some(7)
    "aug" | "august" => Some(8)
    "sep" | "september" => Some(9)
    "oct" | "october" => Some(10)
    "nov" | "november" => Some(11)
    "dec" | "december" => Some(12)
    _ => None
  }
}

///|
fn week_alias(s : String) -> Int? {
  match s.to_lower() {
    "sun" | "sunday" => Some(0)
    "mon" | "monday" => Some(1)
    "tue" | "tuesday" => Some(2)
    "wed" | "wednesday" => Some(3)
    "thu" | "thursday" => Some(4)
    "fri" | "friday" => Some(5)
    "sat" | "saturday" => Some(6)
    _ => None
  }
}

///|
// 参照 PartParser.parseAlias：`L` 优先（取该段最大值），再按月/周别名；都不中就无别名
fn parse_alias(part : Int, v : String) -> Int? {
  if v.to_lower() == "l" {
    Some(part_hi(part))
  } else if part == 4 {
    month_alias(v)
  } else if part == 5 {
    week_alias(v)
  } else {
    None
  }
}

///|
fn parse_number(part : Int, v : String, check : Bool) -> Int raise CronError {
  let raw = match parse_int_opt(v) {
    Some(n) => n
    None =>
      match parse_alias(part, v) {
        Some(n) => n
        None => raise BadAlias(v)
      }
  }
  let mut i = raw
  if i < 0 {
    // 参照"支持负数"：先 +max 回绕再过检 ⇒ -1 在分档变成 58 且合法。
    // 本库改判：负数按原值判越界（spec §3 第 7 条、§5 第 5 行；参照两侧读数都在案）
    if check {
      raise OutOfRange(part_name(part), i)
    }
    i = i + part_hi(part)
  }
  if part == 5 && i == 7 {
    i = 0 // 周日的 7 归一到 0（参照 Week.SUNDAY.getIso8601Value() 那条）
  }
  if check && (i < part_lo(part) || i > part_hi(part)) {
    raise OutOfRange(part_name(part), i)
  }
  i
}

///|
fn append_range(from : Int, to : Int, step : Int, out : Array[Int]) -> Unit {
  let mut i = from
  while i <= to {
    out.push(i)
    i = i + step
  }
}

///|
fn parse_range(
  part : Int,
  value : String,
  step0 : Int,
) -> Array[Int] raise CronError {
  let out : Array[Int] = []
  let mut step = step0
  if value.to_array().length() <= 2 {
    // 参照：长度 ≤2 时不认区间，"单值/全配 + 可选步进"
    let mut lo = part_lo(part)
    if !is_match_all(value) {
      let n = parse_number(part, value, true)
      lo = if lo > n { lo } else { n }
    } else if step < 1 {
      step = 1
    }
    if step > 0 {
      let hi = part_hi(part)
      if lo > hi {
        raise BadValue(value) // 参照 "Invalid value {} > {}"
      }
      append_range(lo, hi, step, out)
    } else {
      out.push(lo)
    }
    out
  } else {
    let parts = split_drop(value, '-')
    match parts.length() {
      1 => {
        let v1 = parse_number(part, value, true)
        if step > 0 {
          append_range(v1, part_hi(part), step, out)
        } else {
          out.push(v1)
        }
        out
      }
      2 => {
        let v1 = parse_number(part, parts[0], true)
        let v2 = parse_number(part, parts[1], true)
        if step < 1 {
          step = 1
        }
        if v1 <= v2 {
          append_range(v1, v2, step, out)
        } else {
          // 反向区间照收（spec §3 第 12 条）：v1..max 并 min..v2
          append_range(v1, part_hi(part), step, out)
          append_range(part_lo(part), v2, step, out)
        }
        out
      }
      _ => raise BadSyntax(value)
    }
  }
}

///|
fn parse_step(part : Int, value : String) -> Array[Int] raise CronError {
  let parts = split_drop(value, '/')
  match parts.length() {
    1 => parse_range(part, value, -1)
    2 => {
      // 参照 issue#I7SMP7：步进不检查范围，但 <1 就报 NonPositiveStep
      let step = parse_number(part, parts[1], false)
      if step < 1 {
        raise NonPositiveStep(value)
      }
      parse_range(part, parts[0], step)
    }
    _ => raise BadSyntax(value)
  }
}

///|
fn parse_array(part : Int, value : String) -> Array[Int] raise CronError {
  let out : Array[Int] = []
  for tok in split_drop(value, ',') {
    for v in parse_step(part, tok) {
      if !has_int(out, v) {
        out.push(v) // 参照 CollUtil.addAllIfNotContains ⇒ 列表去重
      }
    }
  }
  out
}

///|
fn parse_part(part : Int, value : String) -> Pm raise CronError {
  if is_match_all(value) {
    pm_always()
  } else {
    let vs = parse_array(part, value)
    if vs.length() == 0 {
      raise BadValue(value)
    }
    if part == 6 {
      let ys : Array[Int] = []
      for v in vs {
        if !has_int(ys, v) {
          ys.push(v)
        }
      }
      let mut k = 1
      while k < ys.length() {
        let x = ys[k]
        let mut p = k - 1
        while p >= 0 && ys[p] > x {
          ys[p + 1] = ys[p]
          p -= 1
        }
        ys[p + 1] = x
        k += 1
      }
      { kind: PmYear, bits: [], min: ys[0], years: ys, last: false, }
    } else {
      // 参照 BoolArrayMatcher：数组长度看最大值，getMin/回绕基准看最小值——
      // 反向区间（`5-1`）展开后首元素不是最小元素，只取 vs[0] 会把步进起点算高
      let mut mx = vs[0]
      let mut mn = vs[0]
      for v in vs {
        if v > mx {
          mx = v
        }
        if v < mn {
          mn = v
        }
      }
      let bits : Array[Bool] = []
      let mut k = 0
      while k <= mx {
        bits.push(false)
        k += 1
      }
      for v in vs {
        bits[v] = true
      }
      {
        kind: PmBool,
        bits,
        min: mn,
        years: [],
        last: part == 3 && has_int(vs, 31),
      }
    }
  }
}

///|
fn parse_single(text : String) -> Sub raise CronError {
  let parts = ws_split(text)
  let n = parts.length()
  if n < 5 || n > 7 {
    raise BadParts(text)
  }
  // 参照 parseSingle 的 offset：6/7 段第一位是秒，5 段则把秒钉成 "0"（整分匹配）
  let off = if n >= 6 { 1 } else { 0 }
  let sec_src = if off == 1 { parts[0] } else { "0" }
  let year_pm = if n == 7 { parse_part(6, parts[6]) } else { pm_always() }
  {
    ms: [
      parse_part(0, sec_src),
      parse_part(1, parts[off]),
      parse_part(2, parts[1 + off]),
      parse_part(3, parts[2 + off]),
      parse_part(4, parts[3 + off]),
      parse_part(5, parts[4 + off]),
      year_pm,
    ],
  }
}

///|
fn fields_of(dt : @date.DateTime, match_second : Bool) -> Array[Int] {
  // 参照 PatternUtil.getFields：不匹配秒时秒位给 -1（match 里 `second < 0` 直接放行）
  let w = dt.date.weekday() // date 包是 ISO：周一 1 … 周日 7
  [
    if match_second {
      dt.second
    } else {
      -1
    },
    dt.minute,
    dt.hour,
    dt.date.day,
    dt.date.month,
    if w == 7 {
      0
    } else {
      w
    }, // 参照侧编号：周日 0 … 周六 6
    dt.date.year,
  ]
}

///|
fn sub_match(sm : Array[Pm], f : Array[Int]) -> Bool {
  (f[0] < 0 || pm_match(sm[0], f[0])) &&
  pm_match(sm[1], f[1]) &&
  pm_match(sm[2], f[2]) &&
  match_day(sm[3], f[3], f[4], f[6]) &&
  pm_match(sm[4], f[4]) &&
  // 日与周同时限定是"且"（spec §3 第 11 条），不是 Quartz 的"或"
  pm_match(sm[5], f[5]) &&
  pm_match(sm[6], f[6])
}

///|
fn last_day(year : Int, month : Int) -> Int {
  // 回退查找能把月值送成 13（`0 12 L * *` 在 2024-12-31 23:59:01 实测给 2025-01-31 12:00:00），
  // 参照侧 Month.of 按月数取模，这里同口径折回 1..12 再取月末
  let m = ((month - 1) % 12 + 12) % 12 + 1
  @date.days_in_month(year, m) catch {
    _ => 31
  }
}

///|
fn match_day(m : Pm, v : Int, month : Int, year : Int) -> Bool {
  // 参照 DayOfMonthMatcher.match：集合命中，或"28~31 且集合含 31 且正好是月末"
  pm_match(m, v) || (m.last && v > 27 && v == last_day(year, month))
}

///|
fn set_to_min(sm : Array[Pm], nv : Array[Int], to_part : Int) -> Unit {
  let mut j = 0
  while j <= to_part && j <= 6 {
    if j == 3 && sm[3].last {
      nv[3] = last_day(nv[6], nv[4])
    } else {
      nv[j] = pm_min(sm[j], j)
    }
    j += 1
  }
}

///|
fn sub_next_values(sm : Array[Pm], values : Array[Int]) -> Array[Int] {
  let nv : Array[Int] = []
  for v in values {
    nv.push(v)
  }
  let mut i = 6
  let mut next_value = 0
  let mut rollback = false
  while i >= 0 {
    if i == 5 {
      i -= 1
      continue // 周不参与字段推进（参照同一条注释）
    }
    if i == 3 && sm[3].last {
      next_value = last_day(nv[6], nv[4])
    } else {
      next_value = pm_next_after(sm[i], values[i])
    }
    if next_value > values[i] {
      nv[i] = next_value
      i -= 1
      break
    } else if next_value < values[i] {
      nv[i] = next_value
      i += 1
      rollback = true
      break
    }
    i -= 1
  }
  if rollback {
    while i <= 6 {
      if i == 5 {
        i += 1
        continue
      }
      if i == 3 && sm[3].last {
        next_value = last_day(nv[6], nv[4])
      } else {
        next_value = pm_next_after(sm[i], values[i] + 1)
      }
      if next_value > values[i] {
        nv[i] = next_value
        i -= 1
        break
      }
      i += 1
    }
  }
  set_to_min(sm, nv, i)
  nv
}

///|
fn date_safe(y : Int, m : Int, d : Int) -> @date.Date {
  @date.Date::of(y, m, d) catch {
    _ => @date.Date::from_epoch_days(0L)
  }
}

///|
fn day_start(d : @date.Date) -> @date.DateTime {
  @date.DateTime::of(d, 0, 0, 0, 0) catch {
    _ => @date.DateTime::from_epoch_millis(0L, 0)
  }
}

///|
fn from_values(v : Array[Int]) -> @date.DateTime {
  // 参照把七个字段逐个 set 回 **lenient Calendar**：不仅日超出该月天数会滚进下月，
  // 回退查找还能把分/时给出 60/24 这类越界值（`* * * * *` 在 2024-12-31 23:59:01
  // 实测滚成 2025-01-01 00:00:00），所以这里按 epoch 秒整体折算，逐字段校验反而错
  let mut y = v[6]
  let mut m = v[4]
  // 参照 Calendar.set(MONTH, …) 的 lenient 语义：13 月滚成次年 1 月，逐字段校验会把它吞掉
  while m > 12 {
    m -= 12
    y += 1
  }
  while m < 1 {
    m += 12
    y -= 1
  }
  let d = date_safe(y, m, 1).add_days(v[3] - 1)
  let secs = ((v[2] * 60 + v[1]) * 60 + v[0]).to_int64()
  @date.DateTime::from_epoch_millis(
    d.epoch_days() * 86400000L + secs * 1000L,
    0,
  )
}

///|
fn earliest(c : Cron, values : Array[Int]) -> @date.DateTime {
  // 参照 nextMatchAfter(int[], zone)：各匹配器各给一个候选，取最早的那个
  // （第二批的带区名入口共用同一台引擎，实现挪在 zone_util.mbt 的 `earliest_of`，
  // 这里只留一层转调——一条判据不留两处实现）
  earliest_of(c.subs, values)
}

///|
fn ws_split(v : String) -> Array[String] {
  let out : Array[String] = []
  let cs = v.to_array()
  let n = cs.length()
  let mut i = 0
  while i < n {
    if cs[i].is_whitespace() {
      i += 1
    } else {
      let mut j = i
      while j < n && !cs[j].is_whitespace() {
        j += 1
      }
      out.push(String::from_array(cs[i:j]))
      i = j
    }
  }
  out
}

///|
fn split_drop(v : String, sep : Char) -> Array[String] {
  // 参照 StrUtil.split(str, char)：ignoreEmpty=true ⇒ 空 token 直接丢
  let out : Array[String] = []
  let cs = v.to_array()
  let n = cs.length()
  let mut i = 0
  while i < n {
    let mut j = i
    while j < n && cs[j] != sep {
      j += 1
    }
    if j > i {
      out.push(String::from_array(cs[i:j]))
    }
    i = j + 1
  }
  out
}

///|
fn str_trim(v : String) -> String {
  let cs = v.to_array()
  let n = cs.length()
  let mut i = 0
  let mut j = n
  while i < j && cs[i].is_whitespace() {
    i += 1
  }
  while j > i && cs[j - 1].is_whitespace() {
    j -= 1
  }
  String::from_array(cs[i:j])
}

///|
fn pipe_split(v : String) -> Array[String] {
  let out : Array[String] = []
  for tok in split_drop(v, '|') {
    let t = str_trim(tok)
    if t.length() > 0 {
      out.push(t)
    }
  }
  out
}
