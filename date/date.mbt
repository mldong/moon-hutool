///|
/// moon-hutool/date —— 日期时间（hutool `DateUtil`/`CalendarUtil`/`DatePattern`/`DateUnit` 的 MoonBit 对位）
///
/// 契约：`docs/spec/03-date.md`。期望值权威在 `date_test.mbt` 与 spec 表——改期望值须单独一笔
/// 并给外部读数来源（门禁 G5），实现只负责把契约里冻好的读数算出来。
///
/// 四条贯穿性口径（core 没有任何时间能力，本包整包自研，所以口径必须在这里写死，不能让调用方猜）：
/// 1. **没有宿主时区可探测**：`DateTime` 是**墙上时钟**（wall clock），不带偏移；同一瞬间在不同偏移下
///    是两个不同的 `DateTime`。凡涉及"瞬间 ↔ 墙上时钟"的换算，显式传 `offset_minutes` 或区名
///    （hutool/JDK 靠进程默认时区，`moonbitlang/core` 里没有任何对应物）。命名时区与 DST 由内置段表支持（§5/§7），
///    "不必每次传"那一档走默认区层（§8）。**10-07 就地删改**：这一条原先写的是"不做命名时区、不做 DST"，已被第二批推翻。
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
  /// 墙上时刻在该区**不存在**（前跳空洞）：携带那个不存在的墙上时刻的 ISO 串
  ZoneGap(String)
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
  let y = year.to_int64()
  y % 4L == 0L && (y % 100L != 0L || y % 400L == 0L)
}

///|
/// 该年月的天数
///
/// - Parameters: `year` 任意 `Int`（proleptic）；`month` 1..12
/// - Returns: 28/29/30/31
/// - Raises: `DateError.MonthOutOfRange` —— `month` 不在 1..12 时**不夹紧也不取绝对值**
pub fn days_in_month(year : Int, month : Int) -> Int raise DateError {
  if month < 1 || month > 12 {
    raise MonthOutOfRange(month)
  }
  month_len(year, month)
}

///|
/// 构造日期并校验
///
/// - Parameters: `year` 任意 `Int`；`month` 1..12；`day` 1..该月天数
/// - Raises: `MonthOutOfRange` / `DayOutOfRange`
/// - Note: 这是唯一的日期构造入口，非法值不会静默变成"下个月的某天"（JDK `Calendar` 的
///   lenient 模式会滚，本库不滚，见 spec 2.1 差异声明）
pub fn Date::of(year : Int, month : Int, day : Int) -> Date raise DateError {
  if month < 1 || month > 12 {
    raise MonthOutOfRange(month)
  }
  let len = month_len(year, month)
  if day < 1 || day > len {
    raise DayOutOfRange(year, month, day)
  }
  { year, month, day, }
}

///|
/// 距 1970-01-01 的天数（1970-01-01 = 0，之前为负）
pub fn Date::epoch_days(self : Self) -> Int64 {
  days_from_civil(
    self.year.to_int64(),
    self.month.to_int64(),
    self.day.to_int64(),
  )
}

///|
/// 由距 1970-01-01 的天数构造日期（负数向更早，向下取整语义）
pub fn Date::from_epoch_days(days : Int64) -> Date {
  let (y, m, d) = civil_from_days(days)
  { year: y.to_int(), month: m.to_int(), day: d.to_int(), }
}

///|
/// 加减天数（跨月/跨年/跨世纪自动进位，`0` 原样返回）
pub fn Date::add_days(self : Self, days : Int) -> Date {
  Date::from_epoch_days(self.epoch_days() + days.to_int64())
}

///|
/// 加减月数，**月内日超出目标月长度时夹紧到该月末**
///
/// - `2024-01-31 +1 → 2024-02-29`、`2023-01-31 +1 → 2023-02-28`、`2024-05-31 +1 → 2024-06-30`
/// - Note: 夹紧而不是滚到 3 月 2/3 日，这是 hutool `DateUtil.offsetMonth`（= JDK
///   `Calendar.add(MONTH)`）的行为，也是业务最不容易出错的一档
pub fn Date::add_months(self : Self, months : Int) -> Date {
  let total = self.month - 1 + months
  let y = self.year + floor_div_i(total, 12)
  let m = floor_mod_i(total, 12) + 1
  let len = month_len(y, m)
  { year: y, month: m, day: if self.day > len { len } else { self.day }, }
}

///|
/// 加减年数，2 月 29 日在平年夹紧到 2 月 28 日
pub fn Date::add_years(self : Self, years : Int) -> Date {
  self.add_months(years * 12)
}

///|
/// ISO 8601 星期：周一 = 1 … 周日 = 7
///
/// - Note: **不是** JDK `Calendar.DAY_OF_WEEK`（那套周日 = 1）。选 ISO 的理由与差异见 spec 2.2
pub fn Date::weekday(self : Self) -> Int {
  floor_mod(self.epoch_days() + 3L, 7L).to_int() + 1
}

///|
/// 是否周末（按 `weekday` ∈ {6, 7}，即周六/周日）
///
/// - Note: 不做调休/法定节假日（那是逐年数据表，见 `docs/ROADMAP.md` 的「暂不做」）
pub fn Date::is_weekend(self : Self) -> Bool {
  let w = self.weekday()
  w == 6 || w == 7
}

///|
/// 该年内的第几天（1 起算：平年 1..365，闰年 1..366）
pub fn Date::day_of_year(self : Self) -> Int {
  (self.epoch_days() - days_from_civil(self.year.to_int64(), 1L, 1L)).to_int() +
  1
}

///|
/// 季度 1..4
pub fn Date::quarter(self : Self) -> Int {
  (self.month - 1) / 3 + 1
}

///|
/// ISO 8601 周序号 1..53
///
/// - Note: 判"第几周"必须先定"以哪一天为周首、哪一周算第一年第一周"。本库固定 ISO 8601：
///   周一为周首，含该年第一个周四的那一周是第 1 周。hutool `DateUtil.weekOfYear` 走
///   `Calendar.WEEK_OF_YEAR`，随 `Locale`/`firstDayOfWeek` 变——那是不可复现的读数，不跟
pub fn Date::week_of_year(self : Self) -> Int {
  let (_wby, week) = iso_week_parts(self)
  week
}

///|
/// ISO 周基准年：可能与日历年不同（`2021-01-01` 属 `2020` 年的第 53 周）
///
/// - Note: 与 `week_of_year` 配对使用；只看 `week_of_year` 而忽略这一位，跨年那一周会归错年
pub fn Date::week_based_year(self : Self) -> Int {
  let (year, _week) = iso_week_parts(self)
  year
}

///|
/// 所在周的周一（周首固定为周一，与 `weekday` 同一套 ISO 口径）
pub fn Date::begin_of_week(self : Self) -> Date {
  Date::from_epoch_days(self.epoch_days() - (self.weekday() - 1).to_int64())
}

///|
/// 当月 1 日
pub fn Date::begin_of_month(self : Self) -> Date {
  { year: self.year, month: self.month, day: 1, }
}

///|
/// 当月最后一日（2 月按闰年判：2024 → 29 日，2023 → 28 日）
pub fn Date::end_of_month(self : Self) -> Date {
  { year: self.year, month: self.month, day: month_len(self.year, self.month), }
}

///|
/// 当季首日
pub fn Date::begin_of_quarter(self : Self) -> Date {
  { year: self.year, month: (self.quarter() - 1) * 3 + 1, day: 1, }
}

///|
/// 当季最后一日
pub fn Date::end_of_quarter(self : Self) -> Date {
  let m = self.quarter() * 3
  { year: self.year, month: m, day: month_len(self.year, m), }
}

///|
/// 当年 1 月 1 日
pub fn Date::begin_of_year(self : Self) -> Date {
  { year: self.year, month: 1, day: 1, }
}

///|
/// 当年 12 月 31 日
pub fn Date::end_of_year(self : Self) -> Date {
  { year: self.year, month: 12, day: 31, }
}

///|
/// `yyyy-MM-dd`（等价 `format(date_pattern)`，但零失败：输出侧不需要 raise）
///
/// - Note: 输入侧刻意**不**给对称的 `from_iso_string`——解析统一走 `parse`，避免两处输入语法漂移
pub fn Date::to_iso_string(self : Self) -> String {
  iso_date_string(self)
}

///|
/// 按 pattern 格式化日期
///
/// - Parameters: `pattern` 见 spec 2.6 的支持表
/// - Note: `Date` 没有时分秒，所以 pattern 里出现时间类占位串（`HH`/`mm`/`ss`/`SSS`…）
///   判 `UnknownPatternToken` —— 输出 `00:00:00` 是编造数据，不是格式化
/// - Raises: `UnknownPatternToken`
pub fn Date::format(self : Self, pattern : String) -> String raise DateError {
  format_pattern(self, None, pattern)
}

///|
/// 按 pattern 解析日期
///
/// - Note: pattern 里的时间占位串**被读出来但丢弃**（只取年月日）；缺省的日期字段按
///   最小合法值补（年 `0`、月 `1`、日 `1`）
/// - Raises: `UnknownPatternToken` / `ParseFailed` / `MonthOutOfRange` / `DayOutOfRange`
pub fn Date::parse(input : String, pattern : String) -> Date raise DateError {
  parse_pattern(input, pattern).date
}

///|
/// 转成当天 00:00:00.000 的墙上时刻
pub fn Date::to_datetime(self : Self) -> DateTime {
  { date: self, hour: 0, minute: 0, second: 0, milli: 0, }
}

///|
/// `other - self` 的天数（有符号；`self == other` 为 0）
pub fn Date::days_between(self : Self, other : Date) -> Int {
  (other.epoch_days() - self.epoch_days()).to_int()
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
  let out_of_range = hour < 0 ||
    hour > 23 ||
    minute < 0 ||
    minute > 59 ||
    second < 0 ||
    second > 59 ||
    milli < 0 ||
    milli > 999
  if out_of_range {
    raise TimeFieldOutOfRange(hour, minute, second, milli)
  }
  { date, hour, minute, second, milli, }
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
  let shifted = millis + offset_minutes.to_int64() * 60000L
  let tod = floor_mod(shifted, 86400000L)
  {
    date: Date::from_epoch_days(floor_div(shifted, 86400000L)),
    hour: (tod / 3600000L).to_int(),
    minute: (tod / 60000L % 60L).to_int(),
    second: (tod / 1000L % 60L).to_int(),
    milli: (tod % 1000L).to_int(),
  }
}

///|
/// 墙上时刻 → 瞬间：与 `from_epoch_millis` 互逆
///
/// - Note: 不做 DST，故不存在"同一个墙上时刻对应两个瞬间"的歧义（这也是本库砍掉命名时区换来的简单）
pub fn DateTime::to_epoch_millis(self : Self, offset_minutes : Int) -> Int64 {
  let h = self.hour.to_int64()
  let mi = self.minute.to_int64()
  let se = self.second.to_int64()
  let time_ms = (h * 3600L + mi * 60L + se) * 1000L + self.milli.to_int64()
  let day_ms = self.date.epoch_days() * 86400000L
  day_ms + time_ms - offset_minutes.to_int64() * 60000L
}

///|
/// 加减固定长度单位（`TimeUnit` 无月/年，理由见该类型文档）
///
/// - Note: 跨日/跨月/跨年进位全部由内部按 epoch 毫秒换算完成；无 DST，故 `add(Day, 1)`
///   恒等于"墙上时钟 +24 小时"
pub fn DateTime::add(self : Self, unit : TimeUnit, n : Int64) -> DateTime {
  // 偏移取 0：这一档是纯墙上时钟算术（无 DST，故 add(Day,1) 恒等于 +24 小时）
  let ms = self.to_epoch_millis(0) + n * unit.to_millis()
  DateTime::from_epoch_millis(ms, 0)
}

///|
/// 加减月数（日夹紧到月末，时刻部分原样保留）
pub fn DateTime::add_months(self : Self, months : Int) -> DateTime {
  {
    date: self.date.add_months(months),
    hour: self.hour,
    minute: self.minute,
    second: self.second,
    milli: self.milli,
  }
}

///|
/// 当天 00:00:00.000
pub fn DateTime::begin_of_day(self : Self) -> DateTime {
  { date: self.date, hour: 0, minute: 0, second: 0, milli: 0, }
}

///|
/// 当天 23:59:59.999（**毫秒档封顶**，不是 23:59:59.999999——本库最细粒度就是毫秒）
pub fn DateTime::end_of_day(self : Self) -> DateTime {
  { date: self.date, hour: 23, minute: 59, second: 59, milli: 999, }
}

///|
/// 所在周周一 00:00:00.000
pub fn DateTime::begin_of_week(self : Self) -> DateTime {
  { date: self.date.begin_of_week(), hour: 0, minute: 0, second: 0, milli: 0, }
}

///|
/// 当月 1 日 00:00:00.000
pub fn DateTime::begin_of_month(self : Self) -> DateTime {
  { date: self.date.begin_of_month(), hour: 0, minute: 0, second: 0, milli: 0, }
}

///|
/// 当月最后一日 23:59:59.999
pub fn DateTime::end_of_month(self : Self) -> DateTime {
  {
    date: self.date.end_of_month(),
    hour: 23,
    minute: 59,
    second: 59,
    milli: 999,
  }
}

///|
/// 当季首日 00:00:00.000
pub fn DateTime::begin_of_quarter(self : Self) -> DateTime {
  {
    date: self.date.begin_of_quarter(),
    hour: 0,
    minute: 0,
    second: 0,
    milli: 0,
  }
}

///|
/// 当季最后一日 23:59:59.999
pub fn DateTime::end_of_quarter(self : Self) -> DateTime {
  {
    date: self.date.end_of_quarter(),
    hour: 23,
    minute: 59,
    second: 59,
    milli: 999,
  }
}

///|
/// 当年 1 月 1 日 00:00:00.000
pub fn DateTime::begin_of_year(self : Self) -> DateTime {
  { date: self.date.begin_of_year(), hour: 0, minute: 0, second: 0, milli: 0, }
}

///|
/// 当年 12 月 31 日 23:59:59.999
pub fn DateTime::end_of_year(self : Self) -> DateTime {
  {
    date: self.date.end_of_year(),
    hour: 23,
    minute: 59,
    second: 59,
    milli: 999,
  }
}

///|
/// `yyyy-MM-ddTHH:mm:ss.SSS`（不带偏移，因为类型本身不带）
pub fn DateTime::to_iso_string(self : Self) -> String {
  let buf = StringBuilder()
  buf.write_string(iso_date_string(self.date))
  buf.write_string("T")
  buf.write_string(pad(self.hour, 2))
  buf.write_string(":")
  buf.write_string(pad(self.minute, 2))
  buf.write_string(":")
  buf.write_string(pad(self.second, 2))
  buf.write_string(".")
  buf.write_string(pad(self.milli, 3))
  buf.to_string()
}

///|
/// 按 pattern 格式化墙上时刻
///
/// - Raises: `UnknownPatternToken`
pub fn DateTime::format(
  self : Self,
  pattern : String,
) -> String raise DateError {
  format_pattern(self.date, Some(self), pattern)
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
  parse_pattern(input, pattern)
}

///|
/// 该单位等于多少毫秒
///
/// - Note: `Month`/`Year` 不在这个类型里，故本函数**不失败**
pub fn TimeUnit::to_millis(self : Self) -> Int64 {
  match self {
    Millisecond => 1L
    Second => 1000L
    Minute => 60000L
    Hour => 3600000L
    Day => 86400000L
    Week => 604800000L
  }
}

///|
/// `b - a` 的毫秒数向下取整到 `unit`，**取绝对值**（hutool `DateUtil.between(begin,end,unit)` 默认档）
pub fn between(a : DateTime, b : DateTime, unit : TimeUnit) -> Int64 {
  let diff = b.to_epoch_millis(0) - a.to_epoch_millis(0)
  let span = if diff < 0L { -diff } else { diff }
  span / unit.to_millis()
}

///|
/// `b - a` 的毫秒数向下取整到 `unit`，**带符号**（hutool `between(..., isAbs=false)` 对位）
pub fn difference(a : DateTime, b : DateTime, unit : TimeUnit) -> Int64 {
  (b.to_epoch_millis(0) - a.to_epoch_millis(0)) / unit.to_millis()
}

///|
/// 两者是否同一"日历日"——比的是**墙上时钟的日期部分**，不是同一瞬间
///
/// - Note: 同一毫秒在 +00:00 与 +08:00 下可能是两个不同日期，这条判 `false`；
///   要判"同一瞬间"请直接比 `to_epoch_millis`
pub fn is_same_day(a : DateTime, b : DateTime) -> Bool {
  a.date == b.date
}

///|
/// 周岁（已过生日则取年差，未过减 1；2 月 29 日出生者在平年按 2 月 28 日过完）
///
/// - Raises: `FutureBirth` —— `on` 早于 `birth` 时不返回负数
pub fn age(birth : Date, on : Date) -> Int raise DateError {
  if on < birth {
    raise FutureBirth
  }
  let same_month = on.month == birth.month && on.day >= birth.day
  let passed = on.month > birth.month || same_month
  let base = on.year - birth.year
  if passed {
    base
  } else {
    base - 1
  }
}

///|
/// 当前瞬间的 Unix epoch 毫秒
///
/// 全库**唯一**读时钟的入口（OS 能力只走 `env.now`，见 `AGENTS.md`「零依赖四条」）。
/// 本包其余函数都吃显式传入的值，所以用例不依赖墙上时钟；这一条的可测性靠"下界断言"，
/// 不做区间断言（CI 机器慢窄了区间会假红）。
pub fn now_millis() -> Int64 {
  @env.now().reinterpret_as_int64()
}

///|
/// 当前墙上时刻 = `DateTime::from_epoch_millis(now_millis(), offset_minutes)`
///
/// - Parameters: `offset_minutes` 调用方所在地的 UTC 偏移（框架层通常来自配置项，不是猜的）
pub fn now(offset_minutes : Int) -> DateTime {
  DateTime::from_epoch_millis(now_millis(), offset_minutes)
}

///|
/// 瞬间 → RFC 3339 文本（ISO 8601 的互联网 profile）
///
/// - Parameters: `millis` epoch 毫秒；`offset_minutes` 输出用的 UTC 偏移
/// - Note: 偏移 0 出 `Z`，其余出 `+HH:MM`/`-HH:MM`；毫秒为 0 时**省略**小数秒，非 0 时出 3 位
///   （定长输出要恒定宽度请改用 `DateTime::format` + `datetime_millis_pattern`）
pub fn to_rfc3339(millis : Int64, offset_minutes : Int) -> String {
  let x = DateTime::from_epoch_millis(millis, offset_minutes)
  let buf = StringBuilder()
  buf.write_string(iso_date_string(x.date))
  buf.write_string("T")
  buf.write_string(pad(x.hour, 2))
  buf.write_string(":")
  buf.write_string(pad(x.minute, 2))
  buf.write_string(":")
  buf.write_string(pad(x.second, 2))
  // 毫秒为 0 就省略小数秒（定长输出请走 format + datetime_millis_pattern）
  if x.milli != 0 {
    buf.write_string(".")
    buf.write_string(pad(x.milli, 3))
  }
  if offset_minutes == 0 {
    buf.write_string("Z")
  } else {
    buf.write_string(if offset_minutes < 0 { "-" } else { "+" })
    let abs = if offset_minutes < 0 { -offset_minutes } else { offset_minutes }
    buf.write_string(pad(abs / 60, 2))
    buf.write_string(":")
    buf.write_string(pad(abs % 60, 2))
  }
  buf.to_string()
}

///|
/// RFC 3339 文本 → 瞬间（epoch 毫秒）
///
/// - Note: 分隔符 `T`/`t`、`Z`/`z` 都接受（RFC 3339 §5 判大小写不敏感）；小数秒**多于 3 位截断**、
///   少于 3 位按十进制补（`.52` = 520 毫秒）；缺偏移量判 `ParseFailed`（不做"当本地时间猜"）；
///   闰秒 `:60` 判 `TimeFieldOutOfRange`（本库不实现闰秒）
pub fn from_rfc3339(text : String) -> Int64 raise DateError {
  from_rfc3339_inner(text)
}

///|
/// 向下取整的除法/取模：MoonBit 的 `/` 与 `%` 对负数**向零**截断，而 epoch 换算必须 floor
/// （`-1L` 毫秒是 1969-12-31T23:59:59.999，不是 1970-01-01）
fn floor_div(a : Int64, b : Int64) -> Int64 {
  let q = a / b
  let r = a % b
  if r != 0L && (r < 0L) != (b < 0L) {
    q - 1L
  } else {
    q
  }
}

///|
fn floor_mod(a : Int64, b : Int64) -> Int64 {
  let r = a % b
  if r != 0L && (r < 0L) != (b < 0L) {
    r + b
  } else {
    r
  }
}

///|
fn floor_div_i(a : Int, b : Int) -> Int {
  floor_div(a.to_int64(), b.to_int64()).to_int()
}

///|
fn floor_mod_i(a : Int, b : Int) -> Int {
  floor_mod(a.to_int64(), b.to_int64()).to_int()
}

///|
/// Howard Hinnant `days_from_civil`（公历 → 距 1970-01-01 的天数）
///
/// 先移位再除：所有除法的操作数天然非负，所以不受本版"向零截断"的影响
fn days_from_civil(y0 : Int64, m : Int64, d : Int64) -> Int64 {
  let y = if m <= 2L { y0 - 1L } else { y0 }
  let era = (if y >= 0L { y } else { y - 399L }) / 400L
  let yoe = y - era * 400L
  let mp = if m > 2L { m - 3L } else { m + 9L }
  let doy = (153L * mp + 2L) / 5L + d - 1L
  let doe = 365L * yoe + yoe / 4L - yoe / 100L + doy
  era * 146097L + doe - 719468L
}

///|
/// Howard Hinnant `civil_from_days`（天数 → (年, 月, 日)）
fn civil_from_days(z0 : Int64) -> (Int64, Int64, Int64) {
  let z = z0 + 719468L
  let era = floor_div(z, 146097L)
  let doe = z - era * 146097L
  let adj = doe - doe / 1460L + doe / 36524L - doe / 146096L
  let yoe = adj / 365L
  let y = yoe + era * 400L
  let doy = doe - (365L * yoe + yoe / 4L - yoe / 100L)
  let mp = (5L * doy + 2L) / 153L
  let d = doy - (153L * mp + 2L) / 5L + 1L
  let m = if mp < 10L { mp + 3L } else { mp - 9L }
  (if m <= 2L { y + 1L } else { y }, m, d)
}

///|
/// 该年月的天数（`month` 已由公开入口校验过 1..12，这里不再判）
fn month_len(year : Int, month : Int) -> Int {
  let table = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  let base = table[month - 1]
  if month == 2 && is_leap_year(year) {
    29
  } else {
    base
  }
}

///|
/// ISO 8601 的 (周基准年, 周序号)
///
/// 先取本周的**周四**定"归属年"，再从"含该年 1 月 4 日那一周的周一"数周——
/// 这样 2021-01-01 归 2020 年第 53 周是靠定义算出来的，不是靠分支猜出来的
fn iso_week_parts(date : Date) -> (Int, Int) {
  let thu = date.epoch_days() + (4L - date.weekday().to_int64())
  let wby = Date::from_epoch_days(thu).year
  let jan4 = Date::{ year: wby, month: 1, day: 4, }
  let week1_monday = jan4.epoch_days() - (jan4.weekday() - 1).to_int64()
  let week = floor_div(thu - week1_monday, 7L).to_int() + 1
  (wby, week)
}

///|
/// 十进制补零（本包只拿它装非负读数）
fn pad(n : Int, width : Int) -> String {
  let s = n.to_string()
  let missing = width - s.char_length()
  if missing <= 0 {
    s
  } else {
    let buf = StringBuilder()
    for _ in 0..<missing {
      buf.write_char('0')
    }
    buf.write_string(s)
    buf.to_string()
  }
}

///|
/// 年份位：绝对值补零到 4 位，负数前缀 `-`（天文纪年下公元 0 年写作 `0000`）
fn write_signed_year(buf : StringBuilder, year : Int) -> Unit {
  if year < 0 {
    buf.write_char('-')
  }
  buf.write_string(pad(if year < 0 { -year } else { year }, 4))
}

///|
fn iso_date_string(date : Date) -> String {
  let buf = StringBuilder()
  write_signed_year(buf, date.year)
  buf.write_string("-")
  buf.write_string(pad(date.month, 2))
  buf.write_string("-")
  buf.write_string(pad(date.day, 2))
  buf.to_string()
}

///|
/// 12 小时制读数：0 点报 12、13 点报 1
fn hour12_of(hour : Int) -> Int {
  let x = hour % 12
  if x == 0 {
    12
  } else {
    x
  }
}

///|
/// pattern 的一段：字段（`is_field=true`，装的是同字母的极大连续串）或字面量
priv struct Seg {
  text : String
  is_field : Bool
}

///|
fn is_ascii_letter(c : Char) -> Bool {
  let v = c.to_int()
  (v >= 65 && v <= 90) || (v >= 97 && v <= 122)
}

///|
fn digit_value(c : Char) -> Int? {
  let v = c.to_int()
  if v >= 48 && v <= 57 {
    Some(v - 48)
  } else {
    None
  }
}

///|
fn digit_value_at(chars : Array[Char], idx : Int) -> Int? {
  if idx < chars.length() {
    digit_value(chars[idx])
  } else {
    None
  }
}

///|
fn single_char(c : Char) -> String {
  let buf = StringBuilder()
  buf.write_char(c)
  buf.to_string()
}

///|
fn slice_chars(chars : Array[Char], lo : Int, hi : Int) -> String {
  let buf = StringBuilder()
  for k in lo..<hi {
    buf.write_char(chars[k])
  }
  buf.to_string()
}

///|
/// 占位串 → 字段类别号，`0` 表示不支持（封闭子集：表外字母显式报错，不当字面量吞掉）
fn field_kind(run : String) -> Int {
  if run == "yyyy" {
    1
  } else if run == "yy" {
    2
  } else if run == "MM" || run == "M" {
    3
  } else if run == "dd" || run == "d" {
    4
  } else if run == "HH" || run == "H" {
    5
  } else if run == "hh" || run == "h" {
    6
  } else if run == "mm" || run == "m" {
    7
  } else if run == "ss" || run == "s" {
    8
  } else if run == "SSS" {
    9
  } else {
    0
  }
}

///|
/// 切段：`'...'` 是字面量段，`''` 是一个单引号本身；未闭合的 `'` 判 `ParseFailed`（位置就是那个引号）
fn tokenize(pattern : String) -> Array[Seg] raise DateError {
  let chars = pattern.to_array()
  let n = chars.length()
  let segs : Array[Seg] = []
  let mut i = 0
  while i < n {
    let c = chars[i]
    if c == '\'' {
      if i + 1 < n && chars[i + 1] == '\'' {
        segs.push({ text: "'", is_field: false, })
        i = i + 2
      } else {
        let inner = StringBuilder()
        let mut j = i + 1
        let mut closed = false
        while j < n {
          if chars[j] == '\'' {
            closed = true
            break
          }
          inner.write_char(chars[j])
          j = j + 1
        }
        if !closed {
          raise ParseFailed(pattern, i)
        }
        segs.push({ text: inner.to_string(), is_field: false, })
        i = j + 1
      }
    } else if is_ascii_letter(c) {
      let mut j = i + 1
      while j < n && chars[j] == c {
        j = j + 1
      }
      segs.push({ text: slice_chars(chars, i, j), is_field: true, })
      i = j
    } else {
      segs.push({ text: single_char(c), is_field: false, })
      i = i + 1
    }
  }
  segs
}

///|
/// **整体**校验 pattern，先于任何输入读取：表外字母、`Date` 侧的时间档、
/// 解析侧的 `hh`/`h`（没有 AM/PM 就不可逆）与同一字段出现两次
fn check_pattern(
  pattern : String,
  allow_time : Bool,
  for_parse : Bool,
) -> Array[Seg] raise DateError {
  let segs = tokenize(pattern)
  let seen : Array[Int] = []
  for s in segs {
    if !s.is_field {
      continue
    }
    let k = field_kind(s.text)
    if k == 0 || (for_parse && k == 6) || (!allow_time && k >= 5) {
      raise UnknownPatternToken(s.text)
    }
    if for_parse {
      for old in seen {
        if old == k {
          raise UnknownPatternToken(s.text)
        }
      }
      seen.push(k)
    }
  }
  segs
}

///|
fn format_pattern(
  date : Date,
  time : DateTime?,
  pattern : String,
) -> String raise DateError {
  let allow = match time {
    Some(_) => true
    None => false
  }
  let segs = check_pattern(pattern, allow, false)
  let buf = StringBuilder()
  for s in segs {
    if s.is_field {
      write_field(buf, s.text, date, time)
    } else {
      buf.write_string(s.text)
    }
  }
  buf.to_string()
}

///|
fn write_field(
  buf : StringBuilder,
  run : String,
  date : Date,
  time : DateTime?,
) -> Unit raise DateError {
  let w = run.char_length()
  if run == "yyyy" {
    write_signed_year(buf, date.year)
  } else if run == "yy" {
    // 年后两位走**向下取模**：公元 -3 年是 `97` 而不是 `-3`
    buf.write_string(pad(floor_mod_i(date.year, 100), 2))
  } else if run == "MM" || run == "M" {
    buf.write_string(pad(date.month, w))
  } else if run == "dd" || run == "d" {
    buf.write_string(pad(date.day, w))
  } else {
    match time {
      None => raise UnknownPatternToken(run)
      Some(t) => write_time_field(buf, run, w, t)
    }
  }
}

///|
fn write_time_field(
  buf : StringBuilder,
  run : String,
  w : Int,
  t : DateTime,
) -> Unit {
  if run == "HH" || run == "H" {
    buf.write_string(pad(t.hour, w))
  } else if run == "hh" || run == "h" {
    buf.write_string(pad(hour12_of(t.hour), w))
  } else if run == "mm" || run == "m" {
    buf.write_string(pad(t.minute, w))
  } else if run == "ss" || run == "s" {
    buf.write_string(pad(t.second, w))
  } else {
    buf.write_string(pad(t.milli, 3))
  }
}

///|
/// 恰好 `len` 位数字；失败位就是**字段的起始位**（用例里 `ParseFailed(_, at)` 的口径）
fn read_exact(
  chars : Array[Char],
  at : Int,
  len : Int,
  input : String,
) -> Int raise DateError {
  let mut v = 0
  let mut k = 0
  while k < len {
    match digit_value_at(chars, at + k) {
      Some(x) => v = v * 10 + x
      None => raise ParseFailed(input, at)
    }
    k = k + 1
  }
  v
}

///|
/// 1~2 位贪婪数字（`M`/`d`/`H`/`m`/`s` 那一档），返回 (值, 新下标)
fn read_greedy(
  chars : Array[Char],
  at : Int,
  input : String,
) -> (Int, Int) raise DateError {
  match digit_value_at(chars, at) {
    None => raise ParseFailed(input, at)
    Some(v0) =>
      match digit_value_at(chars, at + 1) {
        Some(v1) => (v0 * 10 + v1, at + 2)
        None => (v0, at + 1)
      }
  }
}

///|
/// 两位年窗口：`00..69 → 2000..2069`、`70..99 → 1970..1999`
fn year2_window(v : Int) -> Int {
  if v <= 69 {
    2000 + v
  } else {
    // 后一档是 1900+v（`70..99 → 1970..1999`），不是 1970+v
    1900 + v
  }
}

///|
/// 按段消费输入：字面量逐字符相等（不跳空白、不做大小写不敏感），
/// 缺字段补最小合法值（年 `0`、月 `1`、日 `1`、时分秒毫 `0`）
fn parse_pattern(input : String, pattern : String) -> DateTime raise DateError {
  let segs = check_pattern(pattern, true, true)
  let chars = input.to_array()
  let n = chars.length()
  let mut i = 0
  let mut year = 0
  let mut month = 1
  let mut day = 1
  let mut hour = 0
  let mut minute = 0
  let mut second = 0
  let mut milli = 0
  for s in segs {
    if !s.is_field {
      for c in s.text.to_array() {
        if i >= n || chars[i] != c {
          raise ParseFailed(input, i)
        }
        i = i + 1
      }
    } else {
      let run = s.text
      if run == "yyyy" {
        let signed = i < n && chars[i] == '-'
        let at = if signed { i + 1 } else { i }
        let v = read_exact(chars, at, 4, input)
        year = if signed { -v } else { v }
        i = at + 4
      } else if run == "yy" {
        year = year2_window(read_exact(chars, i, 2, input))
        i = i + 2
      } else if run == "MM" {
        month = read_exact(chars, i, 2, input)
        i = i + 2
      } else if run == "M" {
        let (v, next) = read_greedy(chars, i, input)
        month = v
        i = next
      } else if run == "dd" {
        day = read_exact(chars, i, 2, input)
        i = i + 2
      } else if run == "d" {
        let (v, next) = read_greedy(chars, i, input)
        day = v
        i = next
      } else if run == "HH" {
        hour = read_exact(chars, i, 2, input)
        i = i + 2
      } else if run == "H" {
        let (v, next) = read_greedy(chars, i, input)
        hour = v
        i = next
      } else if run == "mm" {
        minute = read_exact(chars, i, 2, input)
        i = i + 2
      } else if run == "m" {
        let (v, next) = read_greedy(chars, i, input)
        minute = v
        i = next
      } else if run == "ss" {
        second = read_exact(chars, i, 2, input)
        i = i + 2
      } else if run == "s" {
        let (v, next) = read_greedy(chars, i, input)
        second = v
        i = next
      } else {
        milli = read_exact(chars, i, 3, input)
        i = i + 3
      }
    }
  }
  if i != n {
    // 段走完输入还有剩余：多出来的那一位就是失败位
    raise ParseFailed(input, i)
  }
  let date = Date::of(year, month, day)
  DateTime::of(date, hour, minute, second, milli)
}

///|
/// RFC 3339 的解析：结构固定，不走 pattern 引擎（`T`/`Z` 大小写不敏感、小数秒可缺）
fn from_rfc3339_inner(text : String) -> Int64 raise DateError {
  let c = text.to_array()
  let n = c.length()
  let year = read_exact(c, 0, 4, text)
  expect_char(c, 4, '-', text)
  let month = read_exact(c, 5, 2, text)
  expect_char(c, 7, '-', text)
  let day = read_exact(c, 8, 2, text)
  if n <= 10 || (c[10] != 'T' && c[10] != 't') {
    raise ParseFailed(text, 10)
  }
  let hour = read_exact(c, 11, 2, text)
  expect_char(c, 13, ':', text)
  let minute = read_exact(c, 14, 2, text)
  expect_char(c, 16, ':', text)
  let second = read_exact(c, 17, 2, text)
  let mut i = 19
  let mut milli = 0
  if i < n && (c[i] == '.' || c[i] == ',') {
    let start = i + 1
    let mut j = start
    while j < n && digit_value_at(c, j) is Some(_) {
      j = j + 1
    }
    if j == start {
      raise ParseFailed(text, start)
    }
    milli = frac_millis(c, start, j)
    i = j
  }
  // 偏移必填：缺了直接报错，不"当本地时间猜"（那会让同一串在不同机器上给出不同瞬间）
  if i >= n {
    raise ParseFailed(text, i)
  }
  let sign = c[i]
  let mut offset = 0
  if sign == 'Z' || sign == 'z' {
    if i + 1 != n {
      raise ParseFailed(text, i + 1)
    }
  } else if sign == '+' || sign == '-' {
    let oh = read_exact(c, i + 1, 2, text)
    expect_char(c, i + 3, ':', text)
    let om = read_exact(c, i + 4, 2, text)
    if i + 6 != n || oh > 23 || om > 59 {
      raise ParseFailed(text, i)
    }
    offset = oh * 60 + om
    if sign == '-' {
      offset = -offset
    }
  } else {
    raise ParseFailed(text, i)
  }
  let date = Date::of(year, month, day)
  let x = DateTime::of(date, hour, minute, second, milli)
  x.to_epoch_millis(offset)
}

///|
fn expect_char(
  chars : Array[Char],
  at : Int,
  want : Char,
  text : String,
) -> Unit raise DateError {
  if at >= chars.length() || chars[at] != want {
    raise ParseFailed(text, at)
  }
}

///|
/// 小数秒 → 毫秒：**多于 3 位截断**（不四舍五入）、少于 3 位右侧补零（`.52` = 520）
fn frac_millis(chars : Array[Char], start : Int, end : Int) -> Int {
  let mut v = 0
  let mut k = 0
  while k < 3 && start + k < end {
    let d = match digit_value(chars[start + k]) {
      Some(x) => x
      None => 0
    }
    v = v * 10 + d
    k = k + 1
  }
  while k < 3 {
    v = v * 10
    k = k + 1
  }
  v
}
