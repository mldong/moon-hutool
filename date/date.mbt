///|
/// moon-hutool/date —— 日期时间（hutool `DateUtil`/`CalendarUtil`/`DatePattern`/`DateUnit` 的 MoonBit 对位）
///
/// 契约：`docs/spec/02-date.md`。本文件此刻是**签名骨架**，函数体一律 `abort("…未实现…")`：
/// `moon check` 全绿、`moon test` 本包预期红。期望值权威在 `date_test.mbt` 与 spec 表——
/// 实现期只许把红变绿，改期望值须单独一笔并给外部读数来源（门禁 G5）。
///
/// 四条贯穿性口径（core 没有任何时间能力，本包整包自研，所以口径必须在这里写死，不能让调用方猜）：
/// 1. **没有时区库**：`DateTime` 是**墙上时钟**（wall clock），不带偏移；同一瞬间在不同偏移下
///    是两个不同的 `DateTime`。凡涉及"瞬间 ↔ 墙上时钟"的换算，一律**显式传 `offset_minutes`**
///    （hutool/JDK 靠进程默认时区，那个隐式全局量在本库不存在）。不做命名时区、不做 DST。
/// 2. **proleptic Gregorian + 天文纪年**：1582-10-15 之前照公历规则往前算，且存在公元 0 年
///    （`0` = 公元前 1 年）。JDK `GregorianCalendar` 有 1582 切换点，本库没有——差异声明见 spec 2.1。
/// 3. **除法语义**：MoonBit 的 `/` 与 `%` 对负数**向零截断**，而 epoch 换算必须**向下取整**
///    （`-1L` 毫秒是 1969-12-31T23:59:59.999，不是 1970-01-01）。这条是本包最容易写错的一处，
///    `date_test.mbt` 用负 epoch 的三个用例把它钉死。
/// 4. **pattern 是封闭子集**：只认 `yyyy yy MM M dd d HH H hh h mm m ss s SSS` + 单引号转义，
///    其余字母**显式报错**，不做"不认识就当字面量"的宽容处理（那会把 `EEEE` 拼错变成静默错误输出）。

///|
/// 公历日期（不含时间、不含时区）
///
/// 只有 `of`/`from_epoch_days`/`parse` 三个入口，**非法日期无法构造**（2 月 30 日直接 `raise`）。
/// 字段可读、不可改；跨包构造请用这三个入口。
pub struct Date {
  year : Int
  month : Int
  day : Int
} derive(Eq, Compare)

///|
/// 墙上时刻（date + 时分秒毫），**不带偏移**
///
/// 它是"某偏移下的读表结果"，不是瞬间；要拿到瞬间用 `to_epoch_millis(offset_minutes)`。
pub struct DateTime {
  date : Date
  hour : Int
  minute : Int
  second : Int
  milli : Int
} derive(Eq, Compare)

///|
/// 固定长度的时间单位（hutool `DateUnit` 对位）
///
/// **刻意没有 `Month`/`Year`**：它们的长度不固定（28~31 天 / 365~366 天），一旦允许
/// `to_millis()` 就等于承诺"1 个月 = N 毫秒"，那是错的。月/年加减走 `add_months`/`add_years`。
pub(all) enum TimeUnit {
  Millisecond
  Second
  Minute
  Hour
  Day
  Week
}

///|
/// 本包的错误面
///
/// 只暴露**变体 + 读数**，不内置文案：错误消息文本由调用方决定（本库不冻结中文文案，
/// 否则改一个措辞就要撞"期望值冻结"红线）。用例只断言变体形状与携带值。
pub suberror DateError {
  /// 月不在 1..12：携带读到的月值
  MonthOutOfRange(Int)
  /// 该月没有这一天：携带 (year, month, day)
  DayOutOfRange(Int, Int, Int)
  /// 时间字段越界：携带读到的 (hour, minute, second, milli)
  TimeFieldOutOfRange(Int, Int, Int, Int)
  /// pattern 里出现不支持的占位串；`hh`/`h` 在解析侧也算这条（12 小时制无 AM/PM 不可逆）
  UnknownPatternToken(String)
  /// 输入与 pattern 不匹配：携带 (输入, 失败处的码元下标)
  ParseFailed(String, Int)
  /// `age(birth, on)` 里 `on` 早于 `birth`：年龄不存在，不做负数猜测
  FutureBirth
}

///|
/// 常用 pattern 常量（hutool `DatePattern` 对位）
///
/// 值本身就是 `format`/`parse` 的合法输入，写死避免手抄错：`yyyy-MM-dd`
pub let date_pattern : String = "yyyy-MM-dd"

///|
/// `yyyy-MM-dd HH:mm:ss`
pub let datetime_pattern : String = "yyyy-MM-dd HH:mm:ss"

///|
/// `yyyy-MM-dd HH:mm:ss.SSS`
pub let datetime_millis_pattern : String = "yyyy-MM-dd HH:mm:ss.SSS"

///|
/// `yyyyMMdd`（纯数字日期，文件名/分区键常用）
pub let pure_date_pattern : String = "yyyyMMdd"

///|
/// `yyyyMMddHHmmss`（无分隔符，数据库主键/文件名常用）
pub let pure_datetime_pattern : String = "yyyyMMddHHmmss"

///|
/// `HH:mm:ss`
pub let time_pattern : String = "HH:mm:ss"

///|
/// 是否闰年（proleptic Gregorian：4 百年规则，`year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)`）
///
/// - `1900 → false`、`2000 → true`、`2100 → false`、`2400 → true`
/// - 天文纪年下 0 与 -4 都是闰年、-100 不是（负年份按数学整除判，不用"公元前无闰年"的历史口径）
pub fn is_leap_year(year : Int) -> Bool {
  let _ = year
  abort("moon-hutool: date.is_leap_year 未实现（spec 02-date #2.1）")
}

///|
/// 该年月的天数
///
/// - Parameters: `year` 任意 `Int`（proleptic）；`month` 1..12
/// - Returns: 28/29/30/31
/// - Raises: `DateError.MonthOutOfRange` —— `month` 不在 1..12 时**不夹紧也不取绝对值**
pub fn days_in_month(year : Int, month : Int) -> Int raise DateError {
  let _ = (year, month)
  abort("moon-hutool: date.days_in_month 未实现（spec 02-date #2.1）")
}

///|
/// 构造日期并校验
///
/// - Parameters: `year` 任意 `Int`；`month` 1..12；`day` 1..该月天数
/// - Raises: `MonthOutOfRange` / `DayOutOfRange`
/// - Note: 这是唯一的日期构造入口，非法值不会静默变成"下个月的某天"（JDK `Calendar` 的
///   lenient 模式会滚，本库不滚，见 spec 2.1 差异声明）
pub fn Date::of(year : Int, month : Int, day : Int) -> Date raise DateError {
  let _ = (year, month, day)
  abort("moon-hutool: date.Date::of 未实现（spec 02-date #2.1）")
}

///|
/// 距 1970-01-01 的天数（1970-01-01 = 0，之前为负）
pub fn Date::epoch_days(self : Self) -> Int64 {
  let _ = self
  abort("moon-hutool: date.Date::epoch_days 未实现（spec 02-date #2.1）")
}

///|
/// 由距 1970-01-01 的天数构造日期（负数向更早，向下取整语义）
pub fn Date::from_epoch_days(days : Int64) -> Date {
  let _ = days
  abort(
    "moon-hutool: date.Date::from_epoch_days 未实现（spec 02-date #2.1）",
  )
}

///|
/// 加减天数（跨月/跨年/跨世纪自动进位，`0` 原样返回）
pub fn Date::add_days(self : Self, days : Int) -> Date {
  let _ = (self, days)
  abort("moon-hutool: date.Date::add_days 未实现（spec 02-date #2.4）")
}

///|
/// 加减月数，**月内日超出目标月长度时夹紧到该月末**
///
/// - `2024-01-31 +1 → 2024-02-29`、`2023-01-31 +1 → 2023-02-28`、`2024-05-31 +1 → 2024-06-30`
/// - Note: 夹紧而不是滚到 3 月 2/3 日，这是 hutool `DateUtil.offsetMonth`（= JDK
///   `Calendar.add(MONTH)`）的行为，也是业务最不容易出错的一档
pub fn Date::add_months(self : Self, months : Int) -> Date {
  let _ = (self, months)
  abort("moon-hutool: date.Date::add_months 未实现（spec 02-date #2.4）")
}

///|
/// 加减年数，2 月 29 日在平年夹紧到 2 月 28 日
pub fn Date::add_years(self : Self, years : Int) -> Date {
  let _ = (self, years)
  abort("moon-hutool: date.Date::add_years 未实现（spec 02-date #2.4）")
}

///|
/// ISO 8601 星期：周一 = 1 … 周日 = 7
///
/// - Note: **不是** JDK `Calendar.DAY_OF_WEEK`（那套周日 = 1）。选 ISO 的理由与差异见 spec 2.2
pub fn Date::weekday(self : Self) -> Int {
  let _ = self
  abort("moon-hutool: date.Date::weekday 未实现（spec 02-date #2.2）")
}

///|
/// 是否周末（按 `weekday` ∈ {6, 7}，即周六/周日）
///
/// - Note: 不做调休/法定节假日（那是逐年数据表，见 `docs/ROADMAP.md` 的「暂不做」）
pub fn Date::is_weekend(self : Self) -> Bool {
  let _ = self
  abort("moon-hutool: date.Date::is_weekend 未实现（spec 02-date #2.2）")
}

///|
/// 该年内的第几天（1 起算：平年 1..365，闰年 1..366）
pub fn Date::day_of_year(self : Self) -> Int {
  let _ = self
  abort("moon-hutool: date.Date::day_of_year 未实现（spec 02-date #2.2）")
}

///|
/// 季度 1..4
pub fn Date::quarter(self : Self) -> Int {
  let _ = self
  abort("moon-hutool: date.Date::quarter 未实现（spec 02-date #2.2）")
}

///|
/// ISO 8601 周序号 1..53
///
/// - Note: 判"第几周"必须先定"以哪一天为周首、哪一周算第一年第一周"。本库固定 ISO 8601：
///   周一为周首，含该年第一个周四的那一周是第 1 周。hutool `DateUtil.weekOfYear` 走
///   `Calendar.WEEK_OF_YEAR`，随 `Locale`/`firstDayOfWeek` 变——那是不可复现的读数，不跟
pub fn Date::week_of_year(self : Self) -> Int {
  let _ = self
  abort("moon-hutool: date.Date::week_of_year 未实现（spec 02-date #2.2）")
}

///|
/// ISO 周基准年：可能与日历年不同（`2021-01-01` 属 `2020` 年的第 53 周）
///
/// - Note: 与 `week_of_year` 配对使用；只看 `week_of_year` 而忽略这一位，跨年那一周会归错年
pub fn Date::week_based_year(self : Self) -> Int {
  let _ = self
  abort(
    "moon-hutool: date.Date::week_based_year 未实现（spec 02-date #2.2）",
  )
}

///|
/// 所在周的周一（周首固定为周一，与 `weekday` 同一套 ISO 口径）
pub fn Date::begin_of_week(self : Self) -> Date {
  let _ = self
  abort(
    "moon-hutool: date.Date::begin_of_week 未实现（spec 02-date #2.3）",
  )
}

///|
/// 当月 1 日
pub fn Date::begin_of_month(self : Self) -> Date {
  let _ = self
  abort(
    "moon-hutool: date.Date::begin_of_month 未实现（spec 02-date #2.3）",
  )
}

///|
/// 当月最后一日（2 月按闰年判：2024 → 29 日，2023 → 28 日）
pub fn Date::end_of_month(self : Self) -> Date {
  let _ = self
  abort("moon-hutool: date.Date::end_of_month 未实现（spec 02-date #2.3）")
}

///|
/// 当季首日
pub fn Date::begin_of_quarter(self : Self) -> Date {
  let _ = self
  abort(
    "moon-hutool: date.Date::begin_of_quarter 未实现（spec 02-date #2.3）",
  )
}

///|
/// 当季最后一日
pub fn Date::end_of_quarter(self : Self) -> Date {
  let _ = self
  abort(
    "moon-hutool: date.Date::end_of_quarter 未实现（spec 02-date #2.3）",
  )
}

///|
/// 当年 1 月 1 日
pub fn Date::begin_of_year(self : Self) -> Date {
  let _ = self
  abort(
    "moon-hutool: date.Date::begin_of_year 未实现（spec 02-date #2.3）",
  )
}

///|
/// 当年 12 月 31 日
pub fn Date::end_of_year(self : Self) -> Date {
  let _ = self
  abort("moon-hutool: date.Date::end_of_year 未实现（spec 02-date #2.3）")
}

///|
/// `yyyy-MM-dd`（等价 `format(date_pattern)`，但零失败：输出侧不需要 raise）
///
/// - Note: 输入侧刻意**不**给对称的 `from_iso_string`——解析统一走 `parse`，避免两处输入语法漂移
pub fn Date::to_iso_string(self : Self) -> String {
  let _ = self
  abort(
    "moon-hutool: date.Date::to_iso_string 未实现（spec 02-date #2.5）",
  )
}

///|
/// 按 pattern 格式化日期
///
/// - Parameters: `pattern` 见 spec 2.6 的支持表
/// - Note: `Date` 没有时分秒，所以 pattern 里出现时间类占位串（`HH`/`mm`/`ss`/`SSS`…）
///   判 `UnknownPatternToken` —— 输出 `00:00:00` 是编造数据，不是格式化
/// - Raises: `UnknownPatternToken`
pub fn Date::format(self : Self, pattern : String) -> String raise DateError {
  let _ = (self, pattern)
  abort("moon-hutool: date.Date::format 未实现（spec 02-date #2.6）")
}

///|
/// 按 pattern 解析日期
///
/// - Note: pattern 里的时间占位串**被读出来但丢弃**（只取年月日）；缺省的日期字段按
///   最小合法值补（年 `0`、月 `1`、日 `1`）
/// - Raises: `UnknownPatternToken` / `ParseFailed` / `MonthOutOfRange` / `DayOutOfRange`
pub fn Date::parse(input : String, pattern : String) -> Date raise DateError {
  let _ = (input, pattern)
  abort("moon-hutool: date.Date::parse 未实现（spec 02-date #2.7）")
}

///|
/// 转成当天 00:00:00.000 的墙上时刻
pub fn Date::to_datetime(self : Self) -> DateTime {
  let _ = self
  abort("moon-hutool: date.Date::to_datetime 未实现（spec 02-date #2.5）")
}

///|
/// `other - self` 的天数（有符号；`self == other` 为 0）
pub fn Date::days_between(self : Self, other : Date) -> Int {
  let _ = (self, other)
  abort("moon-hutool: date.Date::days_between 未实现（spec 02-date #2.4）")
}

///|
/// 构造墙上时刻并校验各字段范围
///
/// - Parameters: `date` 已合法的日期；`hour` 0..23、`minute`/`second` 0..59、`milli` 0..999
/// - Raises: `TimeFieldOutOfRange`（携带读到的四个值）
pub fn DateTime::of(
  date : Date,
  hour : Int,
  minute : Int,
  second : Int,
  milli : Int,
) -> DateTime raise DateError {
  let _ = (date, hour, minute, second, milli)
  abort("moon-hutool: date.DateTime::of 未实现（spec 02-date #2.5）")
}

///|
/// 瞬间 → 墙上时刻：`millis` 是 Unix epoch 毫秒，`offset_minutes` 是该瞬间所在地的 UTC 偏移
///
/// - Parameters: `millis` 任意 `Int64`（负数表示 1970 年前，**向下取整**）；
///   `offset_minutes` 任意 `Int`（本库不校验它像不像真实时区偏移，见 spec 2.5 口径）
/// - Note: 这是"环境显式化"的核心一格——JDK 用进程默认时区，这里必须显式给
pub fn DateTime::from_epoch_millis(
  millis : Int64,
  offset_minutes : Int,
) -> DateTime {
  let _ = (millis, offset_minutes)
  abort(
    "moon-hutool: date.DateTime::from_epoch_millis 未实现（spec 02-date #2.5）",
  )
}

///|
/// 墙上时刻 → 瞬间：与 `from_epoch_millis` 互逆
///
/// - Note: 不做 DST，故不存在"同一个墙上时刻对应两个瞬间"的歧义（这也是本库砍掉命名时区换来的简单）
pub fn DateTime::to_epoch_millis(self : Self, offset_minutes : Int) -> Int64 {
  let _ = (self, offset_minutes)
  abort(
    "moon-hutool: date.DateTime::to_epoch_millis 未实现（spec 02-date #2.5）",
  )
}

///|
/// 加减固定长度单位（`TimeUnit` 无月/年，理由见该类型文档）
///
/// - Note: 跨日/跨月/跨年进位全部由内部按 epoch 毫秒换算完成；无 DST，故 `add(Day, 1)`
///   恒等于"墙上时钟 +24 小时"
pub fn DateTime::add(self : Self, unit : TimeUnit, n : Int64) -> DateTime {
  let _ = (self, unit, n)
  abort("moon-hutool: date.DateTime::add 未实现（spec 02-date #2.5）")
}

///|
/// 加减月数（日夹紧到月末，时刻部分原样保留）
pub fn DateTime::add_months(self : Self, months : Int) -> DateTime {
  let _ = (self, months)
  abort(
    "moon-hutool: date.DateTime::add_months 未实现（spec 02-date #2.5）",
  )
}

///|
/// 当天 00:00:00.000
pub fn DateTime::begin_of_day(self : Self) -> DateTime {
  let _ = self
  abort(
    "moon-hutool: date.DateTime::begin_of_day 未实现（spec 02-date #2.3）",
  )
}

///|
/// 当天 23:59:59.999（**毫秒档封顶**，不是 23:59:59.999999——本库最细粒度就是毫秒）
pub fn DateTime::end_of_day(self : Self) -> DateTime {
  let _ = self
  abort(
    "moon-hutool: date.DateTime::end_of_day 未实现（spec 02-date #2.3）",
  )
}

///|
/// 所在周周一 00:00:00.000
pub fn DateTime::begin_of_week(self : Self) -> DateTime {
  let _ = self
  abort(
    "moon-hutool: date.DateTime::begin_of_week 未实现（spec 02-date #2.3）",
  )
}

///|
/// 当月 1 日 00:00:00.000
pub fn DateTime::begin_of_month(self : Self) -> DateTime {
  let _ = self
  abort(
    "moon-hutool: date.DateTime::begin_of_month 未实现（spec 02-date #2.3）",
  )
}

///|
/// 当月最后一日 23:59:59.999
pub fn DateTime::end_of_month(self : Self) -> DateTime {
  let _ = self
  abort(
    "moon-hutool: date.DateTime::end_of_month 未实现（spec 02-date #2.3）",
  )
}

///|
/// 当季首日 00:00:00.000
pub fn DateTime::begin_of_quarter(self : Self) -> DateTime {
  let _ = self
  abort(
    "moon-hutool: date.DateTime::begin_of_quarter 未实现（spec 02-date #2.3）",
  )
}

///|
/// 当季最后一日 23:59:59.999
pub fn DateTime::end_of_quarter(self : Self) -> DateTime {
  let _ = self
  abort(
    "moon-hutool: date.DateTime::end_of_quarter 未实现（spec 02-date #2.3）",
  )
}

///|
/// 当年 1 月 1 日 00:00:00.000
pub fn DateTime::begin_of_year(self : Self) -> DateTime {
  let _ = self
  abort(
    "moon-hutool: date.DateTime::begin_of_year 未实现（spec 02-date #2.3）",
  )
}

///|
/// 当年 12 月 31 日 23:59:59.999
pub fn DateTime::end_of_year(self : Self) -> DateTime {
  let _ = self
  abort(
    "moon-hutool: date.DateTime::end_of_year 未实现（spec 02-date #2.3）",
  )
}

///|
/// `yyyy-MM-ddTHH:mm:ss.SSS`（不带偏移，因为类型本身不带）
pub fn DateTime::to_iso_string(self : Self) -> String {
  let _ = self
  abort(
    "moon-hutool: date.DateTime::to_iso_string 未实现（spec 02-date #2.5）",
  )
}

///|
/// 按 pattern 格式化墙上时刻
///
/// - Raises: `UnknownPatternToken`
pub fn DateTime::format(
  self : Self,
  pattern : String,
) -> String raise DateError {
  let _ = (self, pattern)
  abort("moon-hutool: date.DateTime::format 未实现（spec 02-date #2.6）")
}

///|
/// 按 pattern 解析墙上时刻
///
/// - Note: 缺省字段按最小合法值补（年 `0`、月 `1`、日 `1`、时分秒毫 `0`）；
///   `hh`/`h` 在解析侧判 `UnknownPatternToken`
/// - Raises: `UnknownPatternToken` / `ParseFailed` / `MonthOutOfRange` / `DayOutOfRange` /
///   `TimeFieldOutOfRange`
pub fn DateTime::parse(
  input : String,
  pattern : String,
) -> DateTime raise DateError {
  let _ = (input, pattern)
  abort("moon-hutool: date.DateTime::parse 未实现（spec 02-date #2.7）")
}

///|
/// 该单位等于多少毫秒
///
/// - Note: `Month`/`Year` 不在这个类型里，故本函数**不失败**
pub fn TimeUnit::to_millis(self : Self) -> Int64 {
  let _ = self
  abort(
    "moon-hutool: date.TimeUnit::to_millis 未实现（spec 02-date #2.9）",
  )
}

///|
/// `b - a` 的毫秒数向下取整到 `unit`，**取绝对值**（hutool `DateUtil.between(begin,end,unit)` 默认档）
pub fn between(a : DateTime, b : DateTime, unit : TimeUnit) -> Int64 {
  let _ = (a, b, unit)
  abort("moon-hutool: date.between 未实现（spec 02-date #2.9）")
}

///|
/// `b - a` 的毫秒数向下取整到 `unit`，**带符号**（hutool `between(..., isAbs=false)` 对位）
pub fn difference(a : DateTime, b : DateTime, unit : TimeUnit) -> Int64 {
  let _ = (a, b, unit)
  abort("moon-hutool: date.difference 未实现（spec 02-date #2.9）")
}

///|
/// 两者是否同一"日历日"——比的是**墙上时钟的日期部分**，不是同一瞬间
///
/// - Note: 同一毫秒在 +00:00 与 +08:00 下可能是两个不同日期，这条判 `false`；
///   要判"同一瞬间"请直接比 `to_epoch_millis`
pub fn is_same_day(a : DateTime, b : DateTime) -> Bool {
  let _ = (a, b)
  abort("moon-hutool: date.is_same_day 未实现（spec 02-date #2.9）")
}

///|
/// 周岁（已过生日则取年差，未过减 1；2 月 29 日出生者在平年按 2 月 28 日过完）
///
/// - Raises: `FutureBirth` —— `on` 早于 `birth` 时不返回负数
pub fn age(birth : Date, on : Date) -> Int raise DateError {
  let _ = (birth, on)
  abort("moon-hutool: date.age 未实现（spec 02-date #2.9）")
}

///|
/// 当前瞬间的 Unix epoch 毫秒
///
/// 全库**唯一**读时钟的入口（OS 能力只走 `env.now`，见 `AGENTS.md`「零依赖四条」）。
/// 本包其余函数都吃显式传入的值，所以用例不依赖墙上时钟；这一条的可测性靠"下界断言"，
/// 不做区间断言（CI 机器慢窄了区间会假红）。
pub fn now_millis() -> Int64 {
  abort("moon-hutool: date.now_millis 未实现（spec 02-date #2.10）")
}

///|
/// 当前墙上时刻 = `DateTime::from_epoch_millis(now_millis(), offset_minutes)`
///
/// - Parameters: `offset_minutes` 调用方所在地的 UTC 偏移（框架层通常来自配置项，不是猜的）
pub fn now(offset_minutes : Int) -> DateTime {
  let _ = offset_minutes
  abort("moon-hutool: date.now 未实现（spec 02-date #2.10）")
}

///|
/// 瞬间 → RFC 3339 文本（ISO 8601 的互联网 profile）
///
/// - Parameters: `millis` epoch 毫秒；`offset_minutes` 输出用的 UTC 偏移
/// - Note: 偏移 0 出 `Z`，其余出 `+HH:MM`/`-HH:MM`；毫秒为 0 时**省略**小数秒，非 0 时出 3 位
///   （定长输出要恒定宽度请改用 `DateTime::format` + `datetime_millis_pattern`）
pub fn to_rfc3339(millis : Int64, offset_minutes : Int) -> String {
  let _ = (millis, offset_minutes)
  abort("moon-hutool: date.to_rfc3339 未实现（spec 02-date #2.8）")
}

///|
/// RFC 3339 文本 → 瞬间（epoch 毫秒）
///
/// - Note: 分隔符 `T`/`t`、`Z`/`z` 都接受（RFC 3339 §5 判大小写不敏感）；小数秒**多于 3 位截断**、
///   少于 3 位按十进制补（`.52` = 520 毫秒）；缺偏移量判 `ParseFailed`（不做"当本地时间猜"）；
///   闰秒 `:60` 判 `TimeFieldOutOfRange`（本库不实现闰秒）
pub fn from_rfc3339(text : String) -> Int64 raise DateError {
  let _ = text
  abort("moon-hutool: date.from_rfc3339 未实现（spec 02-date #2.8）")
}
