// moon-hutool/date 契约用例（黑盒）。
//
// 状态：**首批已收口**（10-05，47 条；wasm / js / wasm-gc 三档读数一致，native 档由 CI 出证）。
// 第二批（`zone_test.mbt` 那 8 块，内置时区表）10-06 契约已冻结，现在是设计态红，等 PR-B 转绿。
// 期望值先冻结、后实现；改任何期望串 = 门禁 G5 拦下，须单独一笔并给外部读数来源。
// 本轮实现落地后**期望串一字未改**，只改掉实现里的一处算错（两位年窗口 `70..99` 那档写成 `1970+v`）。
//
// 读数权威（逐条来源见 docs/spec/03-date.md 的「读数来源」列）：
// - 公历换算：proleptic Gregorian + 天文纪年，算法是 Howard Hinnant 的 days_from_civil /
//   civil_from_days（除法截断、操作数天然非负那一套）。本机用 Python `datetime` 在 1..9999
//   区间**逐日抽样核对 870 组**后冻结，不是凭记忆誊写。
// - 星期与周序号：ISO 8601（周一为周首、含该年第一个周四的那周是第 1 周），与 `date.isocalendar()` 核对过。
// - `to_rfc3339`/`from_rfc3339`：RFC 3339 §5.6 的语法与示例串（`1985-04-12T23:20:50.52Z`、
//   `1937-01-01T12:00:27.87+00:20` 都是规范正文里的原串）。
// - pattern 子集：宽度/缺省/越界三条规则由 spec 2.6~2.7 定死；每条用例的落点（含 `ParseFailed`
//   的失败下标）由一个 Python 镜像解析器现算，避免"我以为会报这个"。
//
// 三处最容易写错的档位各占一条独立用例：负 epoch 的向下取整（#2.5）、月末夹紧（#2.4）、
// `Date::format` 遇到时间占位串必须报错而不是补 `00:00:00`（#2.6）。

///|
fn d(year : Int, month : Int, day : Int) -> @date.Date {
  @date.Date::of(year, month, day) catch {
    _ => abort("夹具日期本身必须合法：\{year}-\{month}-\{day}")
  }
}

///|
fn dt(
  year : Int,
  month : Int,
  day : Int,
  hour : Int,
  minute : Int,
  second : Int,
  milli : Int,
) -> @date.DateTime {
  @date.DateTime::of(d(year, month, day), hour, minute, second, milli) catch {
    _ => abort("夹具时刻本身必须合法")
  }
}

///|
/// 把错误面折成字符串：变体名 + 携带值一起进断言——携带值也是契约的一部分。
fn show(err : @date.DateError) -> String {
  match err {
    @date.MonthOutOfRange(m) => "MonthOutOfRange \{m}"
    @date.DayOutOfRange(y, m, day) => "DayOutOfRange \{y}-\{m}-\{day}"
    @date.TimeFieldOutOfRange(h, mi, se, ms) =>
      "TimeFieldOutOfRange \{h}:\{mi}:\{se}.\{ms}"
    @date.UnknownPatternToken(t) => "UnknownPatternToken \{t}"
    @date.ParseFailed(input, at) => "ParseFailed \{input} @\{at}"
    @date.FutureBirth => "FutureBirth"
  }
}

///|
/// 跑一次预期会 raise 的调用，返回错误形状；没 raise 就返回「未抛错」。
fn[A] shape(g : () -> A raise @date.DateError) -> String {
  try {
    let _ = g()
    "未抛错"
  } catch {
    err => show(err)
  }
}

///|
test "@date #2.1 epoch_days 双向（1970 前后、跨年、极端年）" {
  assert_eq(d(1970, 1, 1).epoch_days(), 0L)
  assert_eq(d(1970, 1, 2).epoch_days(), 1L)
  assert_eq(d(1969, 12, 31).epoch_days(), -1L)
  assert_eq(d(2000, 3, 1).epoch_days(), 11017L)
  assert_eq(d(2026, 10, 4).epoch_days(), 20730L)
  assert_eq(d(1582, 10, 15).epoch_days(), -141427L)
  assert_eq(d(1, 1, 1).epoch_days(), -719162L)
  assert_eq(d(9999, 12, 31).epoch_days(), 2932896L)
  assert_eq(d(2024, 2, 29).epoch_days(), 19782L)
  // 天文纪年（存在公元 0 年）：-45-01-01 = 1-01-01 再往前 46 年，其中 12 个闰年 ⇒ 16802 天
  assert_eq(d(-45, 1, 1).epoch_days(), -735964L)
  assert_eq(@date.Date::from_epoch_days(0L).to_iso_string(), "1970-01-01")
  assert_eq(@date.Date::from_epoch_days(1L).to_iso_string(), "1970-01-02")
  assert_eq(@date.Date::from_epoch_days(-1L).to_iso_string(), "1969-12-31")
  assert_eq(@date.Date::from_epoch_days(11017L).to_iso_string(), "2000-03-01")
  assert_eq(@date.Date::from_epoch_days(-719162L).to_iso_string(), "0001-01-01")
  assert_eq(@date.Date::from_epoch_days(2932896L).to_iso_string(), "9999-12-31")
  // 超出 Python datetime 区间的两档由算法本身定义（proleptic 规则不变）
  assert_eq(
    @date.Date::from_epoch_days(3000000L).to_iso_string(),
    "10183-09-21",
  )
  assert_eq(
    @date.Date::from_epoch_days(-3000000L).to_iso_string(),
    "-6244-04-12",
  )
}

///|
test "@date #2.1 闰年判定（4 百年规则，含公元前后）" {
  assert_eq(@date.is_leap_year(1900), false)
  assert_eq(@date.is_leap_year(2000), true)
  assert_eq(@date.is_leap_year(2100), false)
  assert_eq(@date.is_leap_year(2400), true)
  assert_eq(@date.is_leap_year(2024), true)
  assert_eq(@date.is_leap_year(2023), false)
  assert_eq(@date.is_leap_year(4), true)
  assert_eq(@date.is_leap_year(100), false)
  assert_eq(@date.is_leap_year(1), false)
  // 天文纪年下负年份按数学整除判：0 与 -4 闰，-100 不闰
  assert_eq(@date.is_leap_year(0), true)
  assert_eq(@date.is_leap_year(-4), true)
  assert_eq(@date.is_leap_year(-100), false)
}

///|
test "@date #2.1 days_in_month 与月越界负向（不夹紧也不取绝对值）" {
  assert_eq(@date.days_in_month(2024, 2), 29)
  assert_eq(@date.days_in_month(2023, 2), 28)
  assert_eq(@date.days_in_month(1900, 2), 28)
  assert_eq(@date.days_in_month(2000, 2), 29)
  assert_eq(@date.days_in_month(2026, 1), 31)
  assert_eq(@date.days_in_month(2026, 4), 30)
  assert_eq(@date.days_in_month(2026, 12), 31)
  assert_eq(shape(() => @date.days_in_month(2026, 0)), "MonthOutOfRange 0")
  assert_eq(shape(() => @date.days_in_month(2026, 13)), "MonthOutOfRange 13")
  assert_eq(shape(() => @date.days_in_month(2026, -1)), "MonthOutOfRange -1")
}

///|
test "@date #2.1 Date::of 是唯一的构造闸门（非法值不滚、不夹）" {
  assert_eq(d(2024, 2, 29).to_iso_string(), "2024-02-29")
  assert_eq(d(-45, 1, 1).to_iso_string(), "-0045-01-01")
  assert_eq(shape(() => @date.Date::of(2026, 2, 30)), "DayOutOfRange 2026-2-30")
  assert_eq(shape(() => @date.Date::of(2023, 2, 29)), "DayOutOfRange 2023-2-29")
  assert_eq(shape(() => @date.Date::of(2026, 4, 31)), "DayOutOfRange 2026-4-31")
  assert_eq(shape(() => @date.Date::of(2026, 1, 0)), "DayOutOfRange 2026-1-0")
  assert_eq(shape(() => @date.Date::of(2026, 13, 1)), "MonthOutOfRange 13")
}

///|
test "@date #2.2 weekday 是 ISO 档（周一=1…周日=7），不是 JDK 的周日=1" {
  assert_eq(d(1970, 1, 1).weekday(), 4)
  assert_eq(d(2026, 10, 4).weekday(), 7)
  assert_eq(d(2026, 10, 5).weekday(), 1)
  assert_eq(d(2024, 2, 29).weekday(), 4)
  assert_eq(d(1, 1, 1).weekday(), 1)
  assert_eq(d(-45, 1, 1).weekday(), 6)
  assert_eq(d(2026, 10, 3).is_weekend(), true)
  assert_eq(d(2026, 10, 4).is_weekend(), true)
  assert_eq(d(2026, 10, 5).is_weekend(), false)
  assert_eq(d(1970, 1, 3).is_weekend(), true)
  assert_eq(d(1970, 1, 4).is_weekend(), true)
}

///|
test "@date #2.2 day_of_year 与 quarter" {
  assert_eq(d(2024, 1, 1).day_of_year(), 1)
  assert_eq(d(2024, 3, 1).day_of_year(), 61)
  assert_eq(d(2023, 3, 1).day_of_year(), 60)
  assert_eq(d(2024, 12, 31).day_of_year(), 366)
  assert_eq(d(2023, 12, 31).day_of_year(), 365)
  assert_eq(d(2026, 10, 4).day_of_year(), 277)
  assert_eq(d(2026, 1, 15).quarter(), 1)
  assert_eq(d(2026, 3, 15).quarter(), 1)
  assert_eq(d(2026, 4, 15).quarter(), 2)
  assert_eq(d(2026, 7, 15).quarter(), 3)
  assert_eq(d(2026, 10, 15).quarter(), 4)
  assert_eq(d(2026, 12, 15).quarter(), 4)
}

///|
test "@date #2.2 ISO 周序号必须与周基准年配对读（跨年那一周最容易归错年）" {
  assert_eq(d(2021, 1, 1).week_of_year(), 53)
  assert_eq(d(2021, 1, 1).week_based_year(), 2020)
  assert_eq(d(2021, 1, 3).week_of_year(), 53)
  assert_eq(d(2021, 1, 4).week_of_year(), 1)
  assert_eq(d(2021, 1, 4).week_based_year(), 2021)
  assert_eq(d(2020, 12, 31).week_of_year(), 53)
  assert_eq(d(2020, 12, 31).week_based_year(), 2020)
  assert_eq(d(2019, 12, 30).week_of_year(), 1)
  assert_eq(d(2019, 12, 30).week_based_year(), 2020)
  assert_eq(d(2026, 1, 1).week_of_year(), 1)
  // 2026-12-31 是周四 ⇒ 该年有第 53 周
  assert_eq(d(2026, 12, 31).week_of_year(), 53)
  assert_eq(d(2026, 12, 31).week_based_year(), 2026)
  assert_eq(d(2024, 12, 30).week_of_year(), 1)
  assert_eq(d(2024, 12, 30).week_based_year(), 2025)
}

///|
test "@date #2.3 Date 的 begin/end 家族" {
  assert_eq(d(2026, 10, 4).begin_of_week().to_iso_string(), "2026-09-28")
  assert_eq(d(2026, 10, 5).begin_of_week().to_iso_string(), "2026-10-05")
  assert_eq(d(2026, 10, 3).begin_of_week().to_iso_string(), "2026-09-28")
  assert_eq(d(2024, 2, 15).begin_of_week().to_iso_string(), "2024-02-12")
  // 年初落在上一年那一周里
  assert_eq(d(2026, 1, 1).begin_of_week().to_iso_string(), "2025-12-29")
  assert_eq(d(2026, 12, 31).begin_of_week().to_iso_string(), "2026-12-28")
  assert_eq(d(2026, 10, 4).begin_of_month().to_iso_string(), "2026-10-01")
  assert_eq(d(2026, 10, 4).end_of_month().to_iso_string(), "2026-10-31")
  assert_eq(d(2024, 2, 15).end_of_month().to_iso_string(), "2024-02-29")
  assert_eq(d(2023, 2, 15).end_of_month().to_iso_string(), "2023-02-28")
  assert_eq(d(2026, 12, 31).end_of_month().to_iso_string(), "2026-12-31")
  assert_eq(d(2026, 10, 4).begin_of_quarter().to_iso_string(), "2026-10-01")
  assert_eq(d(2026, 10, 4).end_of_quarter().to_iso_string(), "2026-12-31")
  assert_eq(d(2024, 2, 15).begin_of_quarter().to_iso_string(), "2024-01-01")
  assert_eq(d(2024, 2, 15).end_of_quarter().to_iso_string(), "2024-03-31")
  assert_eq(d(2026, 10, 4).begin_of_year().to_iso_string(), "2026-01-01")
  assert_eq(d(2026, 10, 4).end_of_year().to_iso_string(), "2026-12-31")
}

///|
test "@date #2.4 add_days 跨月跨年跨世纪" {
  assert_eq(d(2024, 2, 28).add_days(1).to_iso_string(), "2024-02-29")
  assert_eq(d(2023, 2, 28).add_days(1).to_iso_string(), "2023-03-01")
  assert_eq(d(2024, 12, 31).add_days(1).to_iso_string(), "2025-01-01")
  assert_eq(d(2025, 1, 1).add_days(-366).to_iso_string(), "2024-01-01")
  assert_eq(d(2026, 10, 4).add_days(0).to_iso_string(), "2026-10-04")
  assert_eq(d(1970, 1, 1).add_days(-1).to_iso_string(), "1969-12-31")
  assert_eq(d(2000, 3, 1).add_days(-60).to_iso_string(), "2000-01-01")
}

///|
test "@date #2.4 add_months 夹紧到月末（不滚到下个月）" {
  assert_eq(d(2024, 1, 31).add_months(1).to_iso_string(), "2024-02-29")
  assert_eq(d(2023, 1, 31).add_months(1).to_iso_string(), "2023-02-28")
  assert_eq(d(2024, 3, 31).add_months(-1).to_iso_string(), "2024-02-29")
  assert_eq(d(2024, 1, 30).add_months(1).to_iso_string(), "2024-02-29")
  assert_eq(d(2025, 1, 31).add_months(13).to_iso_string(), "2026-02-28")
  assert_eq(d(2024, 5, 31).add_months(1).to_iso_string(), "2024-06-30")
  assert_eq(d(2026, 10, 4).add_months(12).to_iso_string(), "2027-10-04")
  assert_eq(d(2026, 10, 4).add_months(0).to_iso_string(), "2026-10-04")
  assert_eq(d(2024, 2, 29).add_months(-1).to_iso_string(), "2024-01-29")
  assert_eq(d(2026, 3, 31).add_months(-1).to_iso_string(), "2026-02-28")
}

///|
test "@date #2.4 add_years 同理（2 月 29 日在平年夹到 28 日）" {
  assert_eq(d(2024, 2, 29).add_years(1).to_iso_string(), "2025-02-28")
  assert_eq(d(2024, 2, 29).add_years(4).to_iso_string(), "2028-02-29")
  assert_eq(d(2023, 2, 28).add_years(1).to_iso_string(), "2024-02-28")
  assert_eq(d(2026, 10, 4).add_years(-1).to_iso_string(), "2025-10-04")
  assert_eq(d(2000, 2, 29).add_years(4).to_iso_string(), "2004-02-29")
}

///|
test "@date #2.4 days_between 是有符号的 other - self" {
  assert_eq(d(2024, 1, 1).days_between(d(2024, 3, 1)), 60)
  assert_eq(d(2024, 3, 1).days_between(d(2024, 1, 1)), -60)
  assert_eq(d(2026, 10, 4).days_between(d(2026, 10, 4)), 0)
  assert_eq(d(1969, 12, 31).days_between(d(1970, 1, 1)), 1)
  assert_eq(d(2000, 2, 28).days_between(d(2000, 3, 1)), 2)
}

///|
test "@date #2.5 负 epoch 必须向下取整（MoonBit 的 / 与 % 向零截断，这一档最容易写错）" {
  assert_eq(
    @date.DateTime::from_epoch_millis(0L, 0).to_iso_string(),
    "1970-01-01T00:00:00.000",
  )
  assert_eq(
    @date.DateTime::from_epoch_millis(0L, 480).to_iso_string(),
    "1970-01-01T08:00:00.000",
  )
  assert_eq(
    @date.DateTime::from_epoch_millis(0L, -450).to_iso_string(),
    "1969-12-31T16:30:00.000",
  )
  assert_eq(
    @date.DateTime::from_epoch_millis(-1L, 0).to_iso_string(),
    "1969-12-31T23:59:59.999",
  )
  assert_eq(
    @date.DateTime::from_epoch_millis(-1000L, 0).to_iso_string(),
    "1969-12-31T23:59:59.000",
  )
  assert_eq(
    @date.DateTime::from_epoch_millis(-86400000L, 0).to_iso_string(),
    "1969-12-31T00:00:00.000",
  )
  assert_eq(
    @date.DateTime::from_epoch_millis(86399999L, 0).to_iso_string(),
    "1970-01-01T23:59:59.999",
  )
  assert_eq(
    @date.DateTime::from_epoch_millis(1791117296789L, 0).to_iso_string(),
    "2026-10-04T12:34:56.789",
  )
  assert_eq(
    @date.DateTime::from_epoch_millis(1791117296789L, 480).to_iso_string(),
    "2026-10-04T20:34:56.789",
  )
  assert_eq(
    @date.DateTime::from_epoch_millis(1791117296789L, -450).to_iso_string(),
    "2026-10-04T05:04:56.789",
  )
  // RFC 3339 §5.6 示例串对应的瞬间（另一半见 #2.8）
  assert_eq(
    @date.DateTime::from_epoch_millis(482196050520L, 0).to_iso_string(),
    "1985-04-12T23:20:50.520",
  )
}

///|
test "@date #2.5 to_epoch_millis 与 from_epoch_millis 互逆（三个偏移档）" {
  assert_eq(dt(2026, 10, 4, 12, 34, 56, 789).to_epoch_millis(0), 1791117296789L)
  assert_eq(
    dt(2026, 10, 4, 12, 34, 56, 789).to_epoch_millis(480),
    1791088496789L,
  )
  assert_eq(
    dt(2026, 10, 4, 12, 34, 56, 789).to_epoch_millis(-450),
    1791144296789L,
  )
  assert_eq(dt(1970, 1, 1, 0, 0, 0, 0).to_epoch_millis(0), 0L)
  assert_eq(dt(1969, 12, 31, 23, 59, 59, 999).to_epoch_millis(0), -1L)
  assert_eq(
    @date.DateTime::from_epoch_millis(
      dt(2024, 2, 29, 23, 59, 59, 999).to_epoch_millis(480),
      480,
    ).to_iso_string(),
    "2024-02-29T23:59:59.999",
  )
}

///|
test "@date #2.5 DateTime::of 的时间字段闸门、to_iso_string 与 Date::to_datetime" {
  assert_eq(
    shape(() => @date.DateTime::of(d(2026, 10, 4), 24, 0, 0, 0)),
    "TimeFieldOutOfRange 24:0:0.0",
  )
  assert_eq(
    shape(() => @date.DateTime::of(d(2026, 10, 4), 12, 60, 0, 0)),
    "TimeFieldOutOfRange 12:60:0.0",
  )
  assert_eq(
    shape(() => @date.DateTime::of(d(2026, 10, 4), 12, 0, 60, 0)),
    "TimeFieldOutOfRange 12:0:60.0",
  )
  assert_eq(
    shape(() => @date.DateTime::of(d(2026, 10, 4), 12, 0, 0, 1000)),
    "TimeFieldOutOfRange 12:0:0.1000",
  )
  assert_eq(
    dt(2026, 1, 5, 9, 7, 3, 45).to_iso_string(),
    "2026-01-05T09:07:03.045",
  )
  assert_eq(
    dt(2026, 10, 4, 0, 0, 0, 0).to_iso_string(),
    "2026-10-04T00:00:00.000",
  )
  assert_eq(
    d(2026, 10, 4).to_datetime().to_iso_string(),
    "2026-10-04T00:00:00.000",
  )
}

///|
test "@date #2.3 DateTime 的 begin/end 家族（end 档毫秒封顶 .999）" {
  let x = dt(2026, 10, 4, 12, 34, 56, 789)
  assert_eq(x.begin_of_day().to_iso_string(), "2026-10-04T00:00:00.000")
  assert_eq(x.end_of_day().to_iso_string(), "2026-10-04T23:59:59.999")
  assert_eq(x.begin_of_week().to_iso_string(), "2026-09-28T00:00:00.000")
  assert_eq(x.begin_of_month().to_iso_string(), "2026-10-01T00:00:00.000")
  assert_eq(x.end_of_month().to_iso_string(), "2026-10-31T23:59:59.999")
  assert_eq(x.begin_of_quarter().to_iso_string(), "2026-10-01T00:00:00.000")
  assert_eq(x.end_of_quarter().to_iso_string(), "2026-12-31T23:59:59.999")
  assert_eq(x.begin_of_year().to_iso_string(), "2026-01-01T00:00:00.000")
  assert_eq(x.end_of_year().to_iso_string(), "2026-12-31T23:59:59.999")
  assert_eq(
    dt(2024, 2, 15, 1, 2, 3, 4).end_of_month().to_iso_string(),
    "2024-02-29T23:59:59.999",
  )
}

///|
test "@date #2.5 DateTime::add 走固定长度单位，跨日跨月进位" {
  let x = dt(2026, 10, 4, 12, 34, 56, 789)
  assert_eq(x.add(@date.Hour, 2L).to_iso_string(), "2026-10-04T14:34:56.789")
  assert_eq(x.add(@date.Day, -1L).to_iso_string(), "2026-10-03T12:34:56.789")
  assert_eq(x.add(@date.Week, 1L).to_iso_string(), "2026-10-11T12:34:56.789")
  // 毫秒溢出进位到秒
  assert_eq(
    x.add(@date.Millisecond, 213L).to_iso_string(),
    "2026-10-04T12:34:57.002",
  )
  assert_eq(
    dt(2024, 1, 31, 23, 59, 59, 999).add(@date.Millisecond, 1L).to_iso_string(),
    "2024-02-01T00:00:00.000",
  )
  assert_eq(
    dt(2024, 2, 29, 23, 59, 59, 999).add(@date.Day, 1L).to_iso_string(),
    "2024-03-01T23:59:59.999",
  )
  assert_eq(x.add_months(4).to_iso_string(), "2027-02-04T12:34:56.789")
  assert_eq(
    dt(2024, 1, 31, 12, 0, 0, 0).add_months(1).to_iso_string(),
    "2024-02-29T12:00:00.000",
  )
}

///|
test "@date #2.6 format 的封闭 pattern 子集" {
  let x = dt(2026, 1, 5, 9, 7, 3, 45)
  assert_eq(x.format(@date.datetime_pattern), "2026-01-05 09:07:03")
  assert_eq(x.format(@date.datetime_millis_pattern), "2026-01-05 09:07:03.045")
  assert_eq(x.format(@date.pure_datetime_pattern), "20260105090703")
  assert_eq(x.format(@date.time_pattern), "09:07:03")
  assert_eq(x.format("yy-M-d H:m:s"), "26-1-5 9:7:3")
  assert_eq(x.format("hh:mm"), "09:07")
  assert_eq(x.format("yyyy年MM月dd日"), "2026年01月05日")
  assert_eq(x.format("'<'yyyy'>'MM"), "<2026>01")
  let y = dt(2024, 12, 31, 23, 59, 59, 999)
  assert_eq(y.format(@date.datetime_pattern), "2024-12-31 23:59:59")
  assert_eq(y.format(@date.datetime_millis_pattern), "2024-12-31 23:59:59.999")
  assert_eq(y.format("yy-M-d H:m:s"), "24-12-31 23:59:59")
  assert_eq(y.format("hh:mm"), "11:59")
  // 12 小时制：0 点报 12、13 点报 1（输出侧支持，输入侧不支持，见 #2.7）
  assert_eq(dt(2026, 10, 4, 0, 0, 0, 0).format("hh:mm"), "12:00")
  assert_eq(dt(2026, 10, 4, 13, 0, 0, 0).format("hh:mm"), "01:00")
  assert_eq(
    dt(2026, 10, 4, 13, 0, 0, 0).format("yyyy-MM-dd'T'HH:mm"),
    "2026-10-04T13:00",
  )
  // 负年份：符号 + 绝对值补零到 4 位；`yy` 走**向下取模**（-3 % 100 = 97，不是 -3）
  assert_eq(d(-3, 1, 1).to_iso_string(), "-0003-01-01")
  assert_eq(d(-3, 1, 1).format("yy"), "97")
  assert_eq(d(2000, 1, 1).format("yy"), "00")
}

///|
test "@date #2.6 未列入子集的占位串一律显式报错（不许当字面量静默输出）" {
  let x = dt(2026, 10, 4, 12, 34, 56, 789)
  assert_eq(shape(() => x.format("EEEE")), "UnknownPatternToken EEEE")
  assert_eq(
    shape(() => x.format("dd/MM/yyyy HH:mm a")),
    "UnknownPatternToken a",
  )
  assert_eq(
    shape(() => x.format("yyyy-MM-dd HH:mm:ss.S")),
    "UnknownPatternToken S",
  )
  assert_eq(shape(() => x.format("SSSS")), "UnknownPatternToken SSSS")
  assert_eq(shape(() => x.format("YYYY")), "UnknownPatternToken YYYY")
  assert_eq(shape(() => x.format("ww")), "UnknownPatternToken ww")
  assert_eq(shape(() => x.format("MMMM")), "UnknownPatternToken MMMM")
  assert_eq(shape(() => x.format("XXX")), "UnknownPatternToken XXX")
  // 模式先整体校验：非法占位串先于输入匹配报出（parse 侧同理，见 #2.7 末尾）
  assert_eq(
    shape(() => @date.Date::parse("2026-10-04", "yyyy-MM-dd EEEE")),
    "UnknownPatternToken EEEE",
  )
  // Date 没有时分秒：给它时间占位串必须报错，而不是编造 00:00:00
  assert_eq(
    shape(() => d(2026, 10, 4).format("yyyy-MM-dd HH:mm:ss")),
    "UnknownPatternToken HH",
  )
  assert_eq(d(2026, 10, 4).format(@date.date_pattern), "2026-10-04")
  assert_eq(d(2026, 10, 4).format(@date.pure_date_pattern), "20261004")
}

///|
test "@date #2.7 parse 正例（宽度规则、缺省补值、两位年窗口）" {
  assert_eq(
    @date.DateTime::parse("2026-10-04 12:34:56", @date.datetime_pattern).to_iso_string(),
    "2026-10-04T12:34:56.000",
  )
  assert_eq(
    @date.DateTime::parse("2026-1-5 9:7:3", "yyyy-M-d H:m:s").to_iso_string(),
    "2026-01-05T09:07:03.000",
  )
  assert_eq(
    @date.DateTime::parse("20260105090703", @date.pure_datetime_pattern).to_iso_string(),
    "2026-01-05T09:07:03.000",
  )
  assert_eq(
    @date.DateTime::parse(
      "2026-01-05 09:07:03.045", @date.datetime_millis_pattern,
    ).to_iso_string(),
    "2026-01-05T09:07:03.045",
  )
  assert_eq(
    @date.DateTime::parse(
      "2024-02-29 23:59:59.999", @date.datetime_millis_pattern,
    ).to_iso_string(),
    "2024-02-29T23:59:59.999",
  )
  assert_eq(
    @date.DateTime::parse("2026-10-04T13:05:00", "yyyy-MM-dd'T'HH:mm:ss").to_iso_string(),
    "2026-10-04T13:05:00.000",
  )
  assert_eq(
    @date.DateTime::parse("2026-10-04T12:34:56Z", "yyyy-MM-dd'T'HH:mm:ss'Z'").to_iso_string(),
    "2026-10-04T12:34:56.000",
  )
  // 缺字段按最小合法值补：年 0、月 1、日 1、时分秒毫 0
  assert_eq(@date.Date::parse("2026", "yyyy").to_iso_string(), "2026-01-01")
  assert_eq(
    @date.Date::parse("<2026>01", "'<'yyyy'>'MM").to_iso_string(),
    "2026-01-01",
  )
  assert_eq(@date.Date::parse("26-1-5", "yy-M-d").to_iso_string(), "2026-01-05")
  // 两位年窗口 [1970, 2069]：69→2069、70→1970、99→1999
  assert_eq(
    @date.Date::parse("69-01-01", "yy-MM-dd").to_iso_string(),
    "2069-01-01",
  )
  assert_eq(
    @date.Date::parse("70-01-01", "yy-MM-dd").to_iso_string(),
    "1970-01-01",
  )
  assert_eq(
    @date.Date::parse("99-12-31", "yy-MM-dd").to_iso_string(),
    "1999-12-31",
  )
  assert_eq(
    @date.Date::parse("-0003-01-01", "yyyy-MM-dd").to_iso_string(),
    "-0003-01-01",
  )
  assert_eq(
    @date.Date::parse("2026年10月04日", "yyyy年MM月dd日").to_iso_string(),
    "2026-10-04",
  )
  // Date::parse 允许 pattern 带时间占位串：读出来再丢弃（从更宽的输入里取日期）
  assert_eq(
    @date.Date::parse("2026-10-04 12:34:56", @date.datetime_pattern).to_iso_string(),
    "2026-10-04",
  )
}

///|
test "@date #2.7 parse 的输入不匹配矩阵（ParseFailed 带失败下标）" {
  assert_eq(
    shape(() => @date.Date::parse("2026-10-4", "yyyy-MM-dd")),
    "ParseFailed 2026-10-4 @8",
  )
  assert_eq(
    shape(() => @date.Date::parse("2026-1-4", "yyyy-MM-dd")),
    "ParseFailed 2026-1-4 @5",
  )
  assert_eq(
    shape(() => @date.Date::parse("2026-10", "yyyy-MM-dd")),
    "ParseFailed 2026-10 @7",
  )
  assert_eq(
    shape(() => @date.Date::parse("2026-10-04 ", "yyyy-MM-dd")),
    "ParseFailed 2026-10-04  @10",
  )
  assert_eq(
    shape(() => @date.Date::parse("abc", "yyyy-MM-dd")),
    "ParseFailed abc @0",
  )
  assert_eq(
    shape(() => @date.Date::parse("2026.10.04", "yyyy-MM-dd")),
    "ParseFailed 2026.10.04 @4",
  )
  assert_eq(
    shape(() => {
      @date.DateTime::parse("2026-01-05 9:07:03", @date.datetime_pattern)
    }),
    "ParseFailed 2026-01-05 9:07:03 @11",
  )
  assert_eq(
    shape(() => {
      @date.DateTime::parse("2026-10-04T12:34:56", @date.datetime_pattern)
    }),
    "ParseFailed 2026-10-04T12:34:56 @10",
  )
  assert_eq(
    shape(() => {
      @date.DateTime::parse(
        "2026-01-05 09:07:03.4", @date.datetime_millis_pattern,
      )
    }),
    "ParseFailed 2026-01-05 09:07:03.4 @20",
  )
  assert_eq(
    shape(() => @date.Date::parse("1-01-2026", "MM-dd-yyyy")),
    "ParseFailed 1-01-2026 @0",
  )
}

///|
test "@date #2.7 parse 的越界矩阵（形状对了值不对也报错，不夹紧）" {
  assert_eq(
    shape(() => @date.Date::parse("2026-13-01", "yyyy-MM-dd")),
    "MonthOutOfRange 13",
  )
  assert_eq(
    shape(() => @date.Date::parse("2026-02-30", "yyyy-MM-dd")),
    "DayOutOfRange 2026-2-30",
  )
  assert_eq(
    shape(() => {
      @date.DateTime::parse("2024-02-30 00:00:00", @date.datetime_pattern)
    }),
    "DayOutOfRange 2024-2-30",
  )
  assert_eq(
    shape(() => {
      @date.DateTime::parse("2026-10-04 25:00:00", @date.datetime_pattern)
    }),
    "TimeFieldOutOfRange 25:0:0.0",
  )
  assert_eq(
    shape(() => {
      @date.DateTime::parse("2026-10-04 12:60:00", @date.datetime_pattern)
    }),
    "TimeFieldOutOfRange 12:60:0.0",
  )
  assert_eq(
    shape(() => {
      @date.DateTime::parse("2026-10-04 12:34:60", @date.datetime_pattern)
    }),
    "TimeFieldOutOfRange 12:34:60.0",
  )
  // 12 小时制在没有 AM/PM 的前提下不可逆 ⇒ parse 侧直接拒收（输出侧支持）
  assert_eq(
    shape(() => {
      @date.DateTime::parse("2026-10-04 09:07:03", "yyyy-MM-dd hh:mm:ss")
    }),
    "UnknownPatternToken hh",
  )
  assert_eq(
    shape(() => @date.DateTime::parse("9:07", "h:mm")),
    "UnknownPatternToken h",
  )
}

///|
test "@date #2.8 to_rfc3339（偏移 0 出 Z；毫秒为 0 时省略小数秒）" {
  assert_eq(@date.to_rfc3339(0L, 0), "1970-01-01T00:00:00Z")
  assert_eq(@date.to_rfc3339(0L, 480), "1970-01-01T08:00:00+08:00")
  assert_eq(@date.to_rfc3339(-1L, 0), "1969-12-31T23:59:59.999Z")
  assert_eq(@date.to_rfc3339(-1000L, 480), "1970-01-01T07:59:59+08:00")
  assert_eq(@date.to_rfc3339(482196050520L, 0), "1985-04-12T23:20:50.520Z")
  assert_eq(
    @date.to_rfc3339(482196050520L, 480),
    "1985-04-13T07:20:50.520+08:00",
  )
  assert_eq(
    @date.to_rfc3339(482196050520L, -450),
    "1985-04-12T15:50:50.520-07:30",
  )
  assert_eq(@date.to_rfc3339(1791117296789L, 0), "2026-10-04T12:34:56.789Z")
  assert_eq(@date.to_rfc3339(86399999L, -720), "1970-01-01T11:59:59.999-12:00")
  assert_eq(@date.to_rfc3339(4294967296000L, 840), "2106-02-07T20:28:16+14:00")
}

///|
test "@date #2.8 from_rfc3339（RFC 3339 §5.6 示例串 + 大小写不敏感 + 分数秒截断）" {
  assert_eq(@date.from_rfc3339("1970-01-01T00:00:00Z"), 0L)
  assert_eq(@date.from_rfc3339("1985-04-12T23:20:50.52Z"), 482196050520L)
  assert_eq(@date.from_rfc3339("1937-01-01T12:00:27.87+00:20"), -1041337172130L)
  assert_eq(@date.from_rfc3339("1969-07-20T20:17:00Z"), -14182980000L)
  assert_eq(@date.from_rfc3339("1985-04-12t23:20:50.52z"), 482196050520L)
  // 多于 3 位的小数秒按毫秒**截断**（不四舍五入）
  assert_eq(@date.from_rfc3339("1985-04-12T23:20:50.5235Z"), 482196050523L)
  assert_eq(@date.from_rfc3339("2026-10-04T00:00:00+14:00"), 1791021600000L)
}

///|
test "@date #2.8 from_rfc3339 负向（缺偏移不猜、闰秒不支持）" {
  assert_eq(
    shape(() => @date.from_rfc3339("1985-04-12 23:20:50Z")),
    "ParseFailed 1985-04-12 23:20:50Z @10",
  )
  assert_eq(
    shape(() => @date.from_rfc3339("1985-04-12T23:20:50")),
    "ParseFailed 1985-04-12T23:20:50 @19",
  )
  // 闰秒：RFC 3339 允许 60 秒，本库不实现（epoch 毫秒没有这一档）
  assert_eq(
    shape(() => @date.from_rfc3339("1998-12-31T23:59:60Z")),
    "TimeFieldOutOfRange 23:59:60.0",
  )
  assert_eq(
    shape(() => @date.from_rfc3339("1985-04-12T23:20:50+25:00")),
    "ParseFailed 1985-04-12T23:20:50+25:00 @19",
  )
  assert_eq(
    shape(() => @date.from_rfc3339("1985-13-01T00:00:00Z")),
    "MonthOutOfRange 13",
  )
  assert_eq(
    shape(() => @date.from_rfc3339("1985-02-30T00:00:00Z")),
    "DayOutOfRange 1985-2-30",
  )
}

///|
test "@date #2.9 TimeUnit 的毫秒数与 between/difference" {
  assert_eq(@date.Millisecond.to_millis(), 1L)
  assert_eq(@date.Second.to_millis(), 1000L)
  assert_eq(@date.Minute.to_millis(), 60000L)
  assert_eq(@date.Hour.to_millis(), 3600000L)
  assert_eq(@date.Day.to_millis(), 86400000L)
  assert_eq(@date.Week.to_millis(), 604800000L)
  let a = dt(2024, 2, 28, 23, 0, 0, 0)
  let b = dt(2024, 3, 1, 1, 30, 0, 0)
  // 26.5 小时（2024 是闰年，2 月 29 日落在中间）
  assert_eq(@date.between(a, b, @date.Millisecond), 95400000L)
  assert_eq(@date.between(a, b, @date.Second), 95400L)
  assert_eq(@date.between(a, b, @date.Minute), 1590L)
  assert_eq(@date.between(a, b, @date.Hour), 26L)
  assert_eq(@date.between(a, b, @date.Day), 1L)
  assert_eq(@date.between(a, b, @date.Week), 0L)
  assert_eq(@date.difference(a, b, @date.Hour), 26L)
  assert_eq(@date.difference(b, a, @date.Hour), -26L)
  assert_eq(@date.between(b, a, @date.Hour), 26L)
  assert_eq(@date.difference(b, a, @date.Day), -1L)
}

///|
test "@date #2.9 is_same_day 比的是墙上时钟，不是同一瞬间" {
  // 同一毫秒在 +00:00 与 +08:00 下跨了两个日历日
  let u = @date.DateTime::from_epoch_millis(86399999L, 0)
  let v = @date.DateTime::from_epoch_millis(86399999L, 480)
  assert_eq(u.to_iso_string(), "1970-01-01T23:59:59.999")
  assert_eq(v.to_iso_string(), "1970-01-02T07:59:59.999")
  assert_eq(@date.is_same_day(u, v), false)
  assert_eq(
    @date.is_same_day(u, @date.DateTime::from_epoch_millis(0L, 0)),
    true,
  )
  assert_eq(@date.is_same_day(v, dt(1970, 1, 2, 0, 0, 0, 0)), true)
}

///|
test "@date #2.9 age 周岁（2 月 29 日出生者在平年 2 月 28 日还没过完生日）" {
  assert_eq(@date.age(d(2000, 2, 29), d(2024, 2, 28)), 23)
  assert_eq(@date.age(d(2000, 2, 29), d(2024, 2, 29)), 24)
  assert_eq(@date.age(d(2000, 2, 29), d(2027, 2, 28)), 26)
  assert_eq(@date.age(d(1949, 10, 1), d(2026, 10, 1)), 77)
  assert_eq(@date.age(d(1949, 10, 1), d(2026, 9, 30)), 76)
  assert_eq(
    shape(() => @date.age(d(2020, 1, 1), d(2019, 12, 31))),
    "FutureBirth",
  )
}

///|
test "@date #2.10 时钟入口：只做单调下界断言（区间断言在慢机器上会假红）" {
  // 时间只朝一个方向走 ⇒ 下界永真；刻意不写上界，也不拿两次读数互比大小
  assert_true(@date.now_millis() > 1700000000000L)
  let x = @date.now(0)
  assert_true(x.date.year >= 2023)
  assert_true(x.hour >= 0 && x.hour <= 23)
  assert_true(x.minute >= 0 && x.minute <= 59)
  // 互逆用**同一次**读数，避免两次读时钟之间的抖动（那是计时依赖，不是契约）
  let ms = @date.now_millis()
  assert_eq(@date.DateTime::from_epoch_millis(ms, 480).to_epoch_millis(480), ms)
}

///|
test "@date #2.5 Eq/Compare 的手感（derive + extends 那一笔的兑现处）" {
  assert_true(d(2026, 10, 4) == d(2026, 10, 4))
  assert_true(d(2026, 10, 4) != d(2026, 10, 5))
  assert_true(d(2026, 10, 4) < d(2026, 10, 5))
  assert_true(d(2026, 10, 5) > d(2026, 10, 4))
  assert_true(d(2026, 10, 4) >= d(2026, 10, 4))
  assert_true(dt(2026, 10, 4, 0, 0, 0, 0) < dt(2026, 10, 4, 0, 0, 0, 1))
  assert_true(dt(2026, 10, 4, 12, 0, 0, 0) == dt(2026, 10, 4, 12, 0, 0, 0))
  // 字段跨包只读（构造只能走 of/from_epoch_days/parse 三个入口）
  let x = d(2026, 10, 4)
  assert_eq(x.year, 2026)
  assert_eq(x.month, 10)
  assert_eq(x.day, 4)
  let y = dt(2026, 10, 4, 12, 34, 56, 789)
  assert_eq(y.date.month, 10)
  assert_eq(y.hour, 12)
  assert_eq(y.milli, 789)
}

///|
test "@date #2.6 pattern 常量表的字面值（写死，免得调用方手抄错）" {
  assert_eq(@date.date_pattern, "yyyy-MM-dd")
  assert_eq(@date.datetime_pattern, "yyyy-MM-dd HH:mm:ss")
  assert_eq(@date.datetime_millis_pattern, "yyyy-MM-dd HH:mm:ss.SSS")
  assert_eq(@date.pure_date_pattern, "yyyyMMdd")
  assert_eq(@date.pure_datetime_pattern, "yyyyMMddHHmmss")
  assert_eq(@date.time_pattern, "HH:mm:ss")
}
