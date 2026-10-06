///|
// moon-hutool/cron —— 第二批之一：段枚举与表达式建造器（ROADMAP 第 19 行第二批）
// 契约真相在 `docs/spec/19-cron.md` §8~§11。本文件的实现体在 PR-B 落地；现在是契约骨架。

///|
/// #19.6 表达式的七段。对位参照的公开枚举 `cn.hutool.cron.pattern.Part`——
/// 它是参照的**公开件**且带行为（每段的界不同、建造器对它的三个 setter 校验时机不同），
/// 所以本库开枚举而不走 typex 那两格的"档位收串"先例（判据写在 spec §8 末段）。
/// - Note: 段序（0=秒 … 6=周 … 年）在参照里是 `Part.ordinal()`，腿 O 行 7 条给出
///   `0=SECOND / 1=MINUTE / 2=HOUR / 3=DAY_OF_MONTH / 4=MONTH / 5=DAY_OF_WEEK / 6=YEAR`。
///   **这个序不进本库契约**：参照另有的 `Part.of(int)` 就是按它取段（越界给
///   `ArrayIndexOutOfBoundsException`，腿 O 行 -1/7/99 三条），本库不导出那个入口（spec §8"不收"表），
///   所以调用方拿不到也不该依赖这里的声明序
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
/// #19.7 段名（大写，与参照 `Part.name()` 逐字符同形）。
/// - Note: 腿 P 行的第一列就是它；错误面 `OutOfRange(档名, 值)` 用的也是这串（spec §5 第 4 行：
///   本库不复制参照的消息模板，只带档名与值）
/// - Note: 之所以公开这一件，是因为参照的报错消息里带的就是 `Part.name()`，
///   调用方要把本库的 `OutOfRange` 与参照的文案对上时需要它
pub fn cron_part_name(p : CronPart) -> String {
  abort(
    "moon-hutool PR-B：契约骨架 —— 七串照腿 P 行的第一列，别写成小写或本库自己的别名",
  )
}

///|
/// #19.8 该段的最小值（含）。
/// - Note: 腿 P 行七条：`SECOND 0`、`MINUTE 0`、`HOUR 0`、`DAY_OF_MONTH 1`、`MONTH 1`、
///   `DAY_OF_WEEK 0`、`YEAR 1970`。周日是 **0~6**：`7` 不在界里（`C|DAY_OF_WEEK|7|ERR` 为凭），
///   它能用是**解析侧**把 `0` 与 `7` 都当周日（spec §3 第 8 条），不是这里的界放宽了
pub fn cron_part_min(p : CronPart) -> Int {
  abort(
    "moon-hutool PR-B：契约骨架 —— 照腿 P 行，别顺手把 DAY_OF_WEEK 的 max 写成 7",
  )
}

///|
/// #19.9 该段的最大值（含）。
/// - Note: `DAY_OF_WEEK` 是 6 不是 7（同上）；`YEAR` 是 2099，且这是**参照的界**，
///   与本库内置时区表的窗口 `[1970-01-01, 2050-01-01)` 是两件事（spec §11 第 4 行）
pub fn cron_part_max(p : CronPart) -> Int {
  abort("moon-hutool PR-B：契约骨架 —— 照腿 P 行七条")
}

///|
/// #19.10 单值校验：合法返回**原值**，越界报 `OutOfRange(档名, 值)`。
/// - Note: 参照 `checkValue` **只判不改**——`C|SECOND|7|RET|7`、`C|HOUR|13|RET|13` 这些读数说明
///   它不做任何归一（不把 24 小时折成 0~23、不把周日 7 折成 0）。本库同形
/// - Note: 参照的文案是 `"{} value {} out of range: [{} , {}]"`（腿 C 行 42 条 ERR 读数的原文，
///   注意区间里那个空格），本库不复制模板，只带档名与值（spec §5 第 4 行）
/// - Raises: `OutOfRange(name, value)`
pub fn cron_part_check_value(p : CronPart, value : Int) -> Int raise CronError {
  abort(
    "moon-hutool PR-B：契约骨架 —— 判而不变：合法就原样返回 value，别在这一件里做归一",
  )
}

///|
/// #19.11 表达式建造器：七段各自一个槽，未设置与已设置为空白都算"没给"。
/// 对位参照 `CronPatternBuilder`（85 行，实现 `Builder<String>`）。
/// - Note: 本库把它做成**值语义**（setter 返回新值，调用方用 `|>` 串），
///   参照是改自己再 `return this`。这条差别没有读数面：两者对同一串设置的**最终 build 结果**同形，
///   腿 K 行只钉后者；值语义只是不让调用方被迫共享可变对象
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
/// #19.12 空建造器（七段都未设置）。
/// - Note: hutool 对位 `CronPatternBuilder.of()`；`K.empty` 那一条钉的是它 build 出来的形状，
///   不是这一件（这一件没有可观测输出）
pub fn cron_builder_new() -> CronBuilder {
  abort(
    "moon-hutool PR-B：契约骨架 —— 七格全 None，别提前塞 `*`（补默认是 build 期的事，见 #19.16）",
  )
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
  abort(
    "moon-hutool PR-B：契约骨架 —— 这里不许调 #19.10，校验期点在另两件里",
  )
}

///|
/// #19.14 设一段为逗号列表：`values` 逐个过 #19.10，**在设置期**报越界。
/// - Note: 参照 `set` 的是 `ArrayUtil.join(values, ",")`（`K.values_hour RET * 1,2,3 * * *`），
///   列表里的重复与顺序不在这里处理——去重是解析侧的事（spec §3 第 3 条）
/// - Note: **空数组视同未设置**：参照 `ArrayUtil.join(空)` 给 null，于是 build 时按未设置补默认
///   （`K.values_empty RET * * * * *`）。本库同形，不报错
/// - Raises: `OutOfRange(档名, 值)` —— 第一个越界值即报（参照逐个 checkValue，不聚合）
/// - Note: hutool 对位 `setValues(Part, int...)`
pub fn cron_builder_set_values(
  b : CronBuilder,
  part : CronPart,
  values : Array[Int],
) -> CronBuilder raise CronError {
  abort(
    "moon-hutool PR-B：契约骨架 —— 逐个过 #19.10 后 join 成 \"a,b,c\"；空数组走\"未设置\"那一档",
  )
}

///|
/// #19.15 设一段为区间 `begin-end`：两端各过 #19.10，**在设置期**报越界。
/// - Note: **不校验 `begin <= end`**：`K.range_reversed RET * * 20-5 * *` 与
///   `RT.range_reversed RET`（反向区间解析侧照收，spec §3 第 12 条）
/// - Raises: `OutOfRange(档名, 值)`（`begin` 先判）
/// - Note: hutool 对位 `setRange(Part, int, int)`，模板 `"{}-{}"`
pub fn cron_builder_set_range(
  b : CronBuilder,
  part : CronPart,
  begin : Int,
  end : Int,
) -> CronBuilder raise CronError {
  abort(
    "moon-hutool PR-B：契约骨架 —— 两端校验但不比大小，产出 \"begin-end\"",
  )
}

///|
/// #19.16 出串。
/// - Returns: 空格分隔的段串。**补默认只补"分~周"四段**，秒与年未设置时整段省略，
///   所以段数随设置变（`K.empty`→5 段、`K.second_set`→6 段、`K.second_and_year`→7 段）
/// - Note: 空白视同未设置：`K.blank_minute`/`K.space_minute`/`K.null_minute` 三条同给 `* * * * *`
/// - Note: **一处本库改判**——只设年、未设秒时，参照给 `* * * * * 2030`（6 段），
///   而 6 段式的第一位是**秒**，于是 `2030` 落到周档，喂回它自家的解析器就报
///   `RT.year_only_no_second ERR CronException|DAY_OF_WEEK value 2030 out of range: [0 , 6]`。
///   本库在这一格把秒补成 `*`（→ 7 段式，可解析），其余"不设就省略"照留。
///   两侧读数都在案（spec §11 第 1 行）
/// - Raises: 无（校验全在 setter 那两件；`build()` 不报错，参照也不报）
/// - Note: hutool 对位 `String build()`——**返回串而不是已解析的表达式**，
///   要表达式还得自己走 #19.1。腿里每一格都成对记了两条：`K.<格>`（build 出的串）与
///   `RT.<格>`（把那条串喂回参照构造器的结果），例如 `RT.values_with_second RET 0 0,30 * * * *`
pub fn cron_builder_build(b : CronBuilder) -> String {
  abort(
    "moon-hutool PR-B：契约骨架 —— 分~周空白补 `*`；秒与年未设置则省略，但**设了年就必须补秒**（本库改判档）",
  )
}
