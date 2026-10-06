///|
// moon-hutool/cron —— 第二批之一：段枚举与表达式建造器（ROADMAP 第 19 行第二批）
// 契约真相在 `docs/spec/19-cron.md` §8~§11。读数标签 `腿 C <行首>.<格>` 一律指
// `scripts/Cron2Leg.java` 的输出行；期望值由 `scripts/gen_cron2_test.py` 从那些行灌入。

///|
/// #19.6 表达式的七段。对位参照的公开枚举 `cn.hutool.cron.pattern.Part`——
/// 它是参照的**公开件**且带行为（每段的界不同、建造器的三个 setter 对它的校验时机不同），
/// 所以本库开枚举而不走 typex 那两格的"档位收串"先例（判据写在 spec §8 末段）。
/// - Note: 参照侧的段序（`ordinal()`，腿 O 行 7 条给出 `0=SECOND … 6=YEAR`）与 `Calendar`
///   字段号都不进契约：前者是实现邻接物（参照另有的 `Part.of(int)` 就是按它取段，越界给
///   `ArrayIndexOutOfBoundsException`，那三条读数因此只留在 spec §8 的"不收"表里），
///   后者是 Java 容器的邻居物
pub(all) enum CronPart {
  Second
  Minute
  Hour
  DayOfMonth
  Month
  DayOfWeek
  Year
}

///|
fn part_index(p : CronPart) -> Int {
  match p {
    Second => 0
    Minute => 1
    Hour => 2
    DayOfMonth => 3
    Month => 4
    DayOfWeek => 5
    Year => 6
  }
}

///|
/// #19.7 段名（大写，与参照 `Part.name()` 逐字符同形）。
/// - Note: 段名表与第一批 #19.1 的 `OutOfRange(档名, 值)` 共用 `cron.mbt` 里那一份，不留第二张
/// - Note: 之所以公开这一件，是因为参照的报错消息里带的就是 `Part.name()`，
///   调用方要把本库的 `OutOfRange` 与参照的文案对上时需要它
pub fn cron_part_name(p : CronPart) -> String {
  part_name(part_index(p))
}

///|
/// #19.8 该段的最小值（含）。
/// - Note: 腿 C 的 P 行第三列七条：`SECOND 0`、`MINUTE 0`、`HOUR 0`、`DAY_OF_MONTH 1`、
///   `MONTH 1`、`DAY_OF_WEEK 0`、`YEAR 1970`
pub fn cron_part_min(p : CronPart) -> Int {
  match p {
    Second => 0
    Minute => 0
    Hour => 0
    DayOfMonth => 1
    Month => 1
    DayOfWeek => 0
    Year => 1970
  }
}

///|
/// #19.9 该段的最大值（含）。
/// - Note: 周日是 **6** 不是 7（`C|DAY_OF_WEEK|7|ERR` 为凭）：`7` 能用是**解析侧**把 `0` 与 `7`
///   都当周日（spec §3 第 8 条），不是这里的界放宽了
/// - Note: `YEAR` 是 2099，且这是**参照的界**，与本库内置时区表的窗口
///   `[1970-01-01, 2050-01-01)` 是两件事（spec §11 第 4 行）
pub fn cron_part_max(p : CronPart) -> Int {
  match p {
    Second => 59
    Minute => 59
    Hour => 23
    DayOfMonth => 31
    Month => 12
    DayOfWeek => 6
    Year => 2099
  }
}

///|
/// #19.10 单值校验：合法返回**原值**，越界报 `OutOfRange(档名, 值)`。
/// - Note: 参照 `checkValue` **判而不变**——`C|SECOND|7|RET|7`、`C|HOUR|13|RET|13` 说明它不做
///   任何归一（不把 24 小时折成 0~23、不把周日 7 折成 0）。本库同形
/// - Note: 参照的文案是 `"{} value {} out of range: [{} , {}]"`（腿 C 的 ERR 行原文，
///   区间里那个空格照留在标签里），本库不复制模板，只带档名与值（spec §5 第 4 行）
pub fn cron_part_check_value(p : CronPart, value : Int) -> Int raise CronError {
  if value < cron_part_min(p) || value > cron_part_max(p) {
    raise OutOfRange(part_name(part_index(p)), value)
  }
  value
}

///|
/// #19.11 表达式建造器：七段各自一个槽。
/// 对位参照 `CronPatternBuilder`（85 行，实现 `Builder<String>`）。
/// - Note: `None`（从未设置）与 `Some("")`/`Some("  ")`（设成空白）**是两格**——参照只对 null 走
///   `StrJoiner` 的 `NullMode.IGNORE`，空串照样占位并留下一个多余空格。两条读数各自在案：
///   `K.blank_second RET " * * * * *"`（**行首一个空格**）对 `K.empty RET "* * * * *"`（没有），
///   `K.space_year RET "* * * * *  "`（行尾两个）
/// - Note: 本库做成**值语义**（setter 返回新值，调用方用 `|>` 串），参照是改自己再 `return this`。
///   这条差别没有读数面：同一批设置下的 build 结果同形，腿 K 行钉的就是后者
pub struct CronBuilder {
  priv second : String?
  priv minute : String?
  priv hour : String?
  priv day_of_month : String?
  priv month : String?
  priv day_of_week : String?
  priv year : String?
}

///|
fn slot_texts(b : CronBuilder) -> Array[String?] {
  [b.second, b.minute, b.hour, b.day_of_month, b.month, b.day_of_week, b.year]
}

///|
// 按段号写一格，其余照抄（值语义 ⇒ 每次造一个新格；记录更新语法在本库不通，逐字段摆）
fn with_slot(b : CronBuilder, i : Int, v : String?) -> CronBuilder {
  let s = slot_texts(b)
  s[i] = v
  {
    second: s[0],
    minute: s[1],
    hour: s[2],
    day_of_month: s[3],
    month: s[4],
    day_of_week: s[5],
    year: s[6],
  }
}

///|
/// #19.12 空建造器（七段都未设置）。
/// - Note: hutool 对位 `CronPatternBuilder.of()`；它 build 出的形状由 #19.16 那条 `K.empty` 钉
pub fn cron_builder_new() -> CronBuilder {
  {
    second: None,
    minute: None,
    hour: None,
    day_of_month: None,
    month: None,
    day_of_week: None,
    year: None,
  }
}

///|
/// #19.13 设一段的文本。**不校验**——文本原样进槽。
/// - Note: 判据是腿的两条配对读数：`K.junk_minute RET abc * * * *` 与
///   `RT.junk_minute ERR CronException|Invalid alias value: [abc]`——坏文本在这里过，
///   到 `cron_of`(#19.1) 才报。校验期点不同是这一族三件 setter 的**唯一**差别（spec §9 第 3 条）
/// - Note: `K.dow_seven RET * * * * 7` 同理：`7` 不在 `DAY_OF_WEEK` 的界里（#19.9），
///   但走文本这条路能过——因为解析侧认 `7` 为周日
/// - Note: hutool 对位 `set(Part, String)`
pub fn cron_builder_set(
  b : CronBuilder,
  part : CronPart,
  value : String,
) -> CronBuilder {
  with_slot(b, part_index(part), Some(value))
}

///|
/// #19.14 设一段为逗号列表：`values` 逐个过 #19.10，**在设置期**报越界。
/// - Note: 参照 `set` 的是 `ArrayUtil.join(values, ",")`（`K.values_hour RET * 1,2,3 * * *`），
///   列表里的重复与顺序不在这里处理——去重是解析侧的事（spec §3 第 3 条）
/// - Note: **空数组给的是空串，不是"未设置"**——参照 `ArrayUtil.join(空, ",")` 给 `""`，
///   而 `StrJoiner` 的 IGNORE 只跳 null。这一条只在秒/年上看得见：分~周的空串会被补默认圈吸收
///   （`K.values_empty RET * * * * *` 与"未设置"同形），秒/年则留下多余空格
///   （`K.values_empty_second RET " * * * * *"` 行首一格、`K.values_empty_year RET "* * * * * "` 行尾一格）
/// - Raises: `OutOfRange(档名, 值)` —— 第一个越界值即报（参照逐个 checkValue，不聚合）
/// - Note: hutool 对位 `setValues(Part, int...)`
pub fn cron_builder_set_values(
  b : CronBuilder,
  part : CronPart,
  values : Array[Int],
) -> CronBuilder raise CronError {
  for v in values {
    let _ = cron_part_check_value(part, v)
  }
  let parts = values.map(v => v.to_string())
  with_slot(b, part_index(part), Some(parts.join(",")))
}

///|
/// #19.15 设一段为区间 `begin-end`：两端各过 #19.10，**在设置期**报越界。
/// - Note: **不校验 `begin <= end`**：`K.range_reversed RET * * 20-5 * *` 与
///   `RT.range_reversed RET`（反向区间解析侧照收，spec §3 第 12 条）
/// - Raises: `OutOfRange(档名, 值)`（`begin` 先判——参照就是先 `checkValue(begin)`）
/// - Note: hutool 对位 `setRange(Part, int, int)`，模板 `"{}-{}"`
pub fn cron_builder_set_range(
  b : CronBuilder,
  part : CronPart,
  begin : Int,
  end : Int,
) -> CronBuilder raise CronError {
  let _ = cron_part_check_value(part, begin)
  let _ = cron_part_check_value(part, end)
  with_slot(
    b,
    part_index(part),
    Some(begin.to_string() + "-" + end.to_string()),
  )
}

///|
/// #19.16 出串。
/// - Returns: 空格分隔的段串。**补默认只补"分~周"四段**，秒与年**从未设置**时整段省略，
///   所以段数随设置变（`K.empty`→5 段、`K.second_set`→6 段、`K.second_and_year`→7 段）；
///   设成空白的秒/年**照留占位**（参照只对 null 忽略），那条读数就是行首/行尾多出来的空格
/// - Note: 空白视同未设置只对"分~周"成立——`K.blank_minute`/`K.space_minute` 都给 `* * * * *`，
///   因为那几段落在补默认的圈里（参照 `build()` 的 `for (i = MINUTE; i < YEAR; i++)`）
/// - Note: **一处本库改判**——只设年、未设秒（含秒设成空白）时，参照给 `* * * * * 2030`（6 段），
///   而 6 段式的第一位是**秒**，于是 `2030` 落到周档，喂回它自家的解析器就报
///   `RT.year_only_no_second ERR CronException|DAY_OF_WEEK value 2030 out of range: [0 , 6]`
///   （`RT.blank_second_with_year` 是同一条失败的第二个读数）。
///   本库在这一格把秒补成 `*`（→ 7 段式，可解析），其余"不设就省略"照留（spec §11 第 1 行）
/// - Raises: 无（校验全在 setter 那两件；`build()` 不报错，参照也不报）
/// - Note: hutool 对位 `String build()`——**返回串而不是已解析的表达式**，
///   要表达式还得自己走 #19.1。腿里每一格都成对记了两条：`K.<格>`（build 出的串）与
///   `RT.<格>`（把那条串喂回参照构造器的结果），例如 `RT.values_with_second RET 0 0,30 * * * *`
pub fn cron_builder_build(b : CronBuilder) -> String {
  let s = slot_texts(b)
  // 分~周（下标 1..5）空白补 `*`——参照那个循环的边界正是 [MINUTE, YEAR)
  let mut i = 1
  while i <= 5 {
    if is_blank_slot(s[i]) {
      s[i] = Some("*")
    }
    i += 1
  }
  // 本库改判档：年给了（且不是空白）而秒没给 ⇒ 补秒，否则产出自家解析器收不了的串
  if !is_blank_slot(s[6]) && is_blank_slot(s[0]) {
    s[0] = Some("*")
  }
  let out : Array[String] = []
  let mut k = 0
  while k < 7 {
    match s[k] {
      // 只有「从未设置」整段跳过（参照 StrJoiner 的 NullMode.IGNORE 只认 null）
      None => ()
      Some(v) => out.push(v)
    }
    k += 1
  }
  out.join(" ")
}

///|
// 参照 `StrUtil.isBlank`：null 或全空白 ⇒ 真
fn is_blank_slot(v : String?) -> Bool {
  match v {
    None => true
    Some(s) => {
      let cs = s.to_array()
      let mut blank = true
      for c in cs {
        if !c.is_whitespace() {
          blank = false
          break
        }
      }
      blank
    }
  }
}
