///|
// cron 第一批的期望值全部由生成脚本从参照腿灌入（手打零条）。
// 腿：真 hutool-cron-5.8.35.jar（**件不在 hutool-core**：core 的 jar 里 grep -ic cron 是 0 条）
//   + hutool-core（CronPattern 依赖它的 StrUtil/NumberUtil/CollUtil）+ 本机 JDK 17.0.14，
//   javac -encoding UTF-8，1436 行读数（cron_ref.txt）。
// 参照侧 `match(long millis, …)` 走 TimeZone.getDefault()（本机 Asia/Shanghai），
//   腿全程钉在 UTC 上、只取 LocalDateTime 与 Calendar(UTC) 两条不随默认时区变的路径
//   （spec §5 第 1 行）。时刻与日期算术全部委托 date 包，本包不重算月末与闰年。
// 异常档的映射表在 spec §5 第 2~5 行：Java 的消息模板不进契约，只钉"哪一档、哪一段、哪个值"。

///|
fn dt(
  y : Int,
  mo : Int,
  d : Int,
  h : Int,
  mi : Int,
  se : Int,
) -> @date.DateTime {
  @date.DateTime::of(@date.Date::of(y, mo, d), h, mi, se, 0) catch {
    _ => abort("cron 用例的时刻夹具非法")
  }
}

///|
// 下一时刻的比较走 date 的 format 出口，串形与腿逐字同形（"毫秒恒 0" 也由这一条钉住）
fn fmt(d : @date.DateTime) -> String {
  d.format("yyyy-MM-dd HH:mm:ss") catch {
    _ => "FORMAT_RAISED"
  }
}

///|
// 六档全覆盖，不留 wildcard
fn tag(e : @cron.CronError) -> String {
  match e {
    @cron.BadParts(s) => "BadParts[" + s + "]"
    @cron.BadValue(s) => "BadValue[" + s + "]"
    @cron.BadAlias(s) => "BadAlias[" + s + "]"
    @cron.OutOfRange(f, v) => "OutOfRange[" + f + "," + v.to_string() + "]"
    @cron.NonPositiveStep(s) => "NonPositiveStep[" + s + "]"
    @cron.BadSyntax(s) => "BadSyntax[" + s + "]"
  }
}

///|
// 一条断言同时钉"解析成/拒"与"原文本原样"（参照的 toString 语义）
fn parse_text(p : String) -> String {
  try {
    let c = @cron.cron_of(p)
    "OK:" + @cron.cron_pattern_text(c)
  } catch {
    e => tag(e)
  }
}

///|
fn m_tag(p : String, t : @date.DateTime, sec : Bool) -> String {
  try {
    let c = @cron.cron_of(p)
    "OK:" + @cron.cron_match(c, t, match_second=sec).to_string()
  } catch {
    e => tag(e)
  }
}

///|
fn nx_tag(p : String, t : @date.DateTime) -> String {
  try {
    let c = @cron.cron_of(p)
    fmt(@cron.cron_next_match_after(c, t))
  } catch {
    e => tag(e)
  }
}

///|
fn nm_tag(p : String, t : @date.DateTime) -> String {
  try {
    let c = @cron.cron_of(p)
    fmt(@cron.cron_next_match(c, t))
  } catch {
    e => tag(e)
  }
}

///|
test "cron 解析档：50 个表达式的接受/报错与原文本" {
  assert_eq(parse_text("* * * * *"), "OK:* * * * *") // ok.0|OK:* * * * *
  assert_eq(parse_text("5 * * * *"), "OK:5 * * * *") // ok.1|OK:5 * * * *
  assert_eq(parse_text("*/2 * * * *"), "OK:*/2 * * * *") // ok.2|OK:*/2 * * * *
  assert_eq(parse_text("2-8 * * * *"), "OK:2-8 * * * *") // ok.3|OK:2-8 * * * *
  assert_eq(parse_text("2,3,5,8 * * * *"), "OK:2,3,5,8 * * * *") // ok.4|OK:2,3,5,8 * * * *
  assert_eq(parse_text("2,3,6/3 * * * *"), "OK:2,3,6/3 * * * *") // ok.5|OK:2,3,6/3 * * * *
  assert_eq(parse_text("? * * * *"), "OK:? * * * *") // ok.6|OK:? * * * *
  assert_eq(parse_text("0 12 * * MON"), "OK:0 12 * * MON") // ok.7|OK:0 12 * * MON
  assert_eq(parse_text("0 12 * * mon"), "OK:0 12 * * mon") // ok.8|OK:0 12 * * mon
  assert_eq(parse_text("0 12 * JAN-MAR *"), "OK:0 12 * JAN-MAR *") // ok.9|OK:0 12 * JAN-MAR *
  assert_eq(parse_text("0 12 * jan-mar *"), "OK:0 12 * jan-mar *") // ok.10|OK:0 12 * jan-mar *
  assert_eq(parse_text("0 12 L * *"), "OK:0 12 L * *") // ok.11|OK:0 12 L * *
  assert_eq(parse_text("0 12 LW * *"), "BadAlias[LW]") // ok.12|CronException:Invalid alias value: [LW]
  assert_eq(parse_text("0 12 15L * *"), "BadAlias[15L]") // ok.13|CronException:Invalid alias value: [15L]
  assert_eq(parse_text("0 12 * * 5L"), "BadAlias[5L]") // ok.14|IllegalArgumentException:No enum constant cn.hutool.core.date.Week.5L
  assert_eq(parse_text("0 12 * * 6L"), "BadAlias[6L]") // ok.15|IllegalArgumentException:No enum constant cn.hutool.core.date.Week.6L
  assert_eq(parse_text("0 12 * * FRI#2"), "BadAlias[FRI#2]") // ok.16|IllegalArgumentException:No enum constant cn.hutool.core.date.Week.FRI#2
  assert_eq(parse_text("0 12 * * 7"), "OK:0 12 * * 7") // ok.17|OK:0 12 * * 7
  assert_eq(parse_text("0 12 * * 0"), "OK:0 12 * * 0") // ok.18|OK:0 12 * * 0
  assert_eq(parse_text("0 12 1 * MON"), "OK:0 12 1 * MON") // ok.19|OK:0 12 1 * MON
  assert_eq(parse_text("0 12 * * SAT,SUN"), "OK:0 12 * * SAT,SUN") // ok.20|OK:0 12 * * SAT,SUN
  assert_eq(parse_text("*/15 9-17 * * MON-FRI"), "OK:*/15 9-17 * * MON-FRI") // ok.21|OK:*/15 9-17 * * MON-FRI
  assert_eq(parse_text("0 0 * * SUN"), "OK:0 0 * * SUN") // ok.22|OK:0 0 * * SUN
  assert_eq(parse_text("0 0 1 1 *"), "OK:0 0 1 1 *") // ok.23|OK:0 0 1 1 *
  assert_eq(parse_text("0 0 29 2 *"), "OK:0 0 29 2 *") // ok.24|OK:0 0 29 2 *
  assert_eq(parse_text("0 12 */3 * *"), "OK:0 12 */3 * *") // ok.25|OK:0 12 */3 * *
  assert_eq(parse_text("30 6 * * *"), "OK:30 6 * * *") // ok.26|OK:30 6 * * *
  assert_eq(parse_text("0-59/13 * * * *"), "OK:0-59/13 * * * *") // ok.27|OK:0-59/13 * * * *
  assert_eq(parse_text("*/7 * * * *"), "OK:*/7 * * * *") // ok.28|OK:*/7 * * * *
  assert_eq(parse_text("1,1,1 * * * *"), "OK:1,1,1 * * * *") // ok.29|OK:1,1,1 * * * *
  assert_eq(parse_text("5-1,7 * * * *"), "OK:5-1,7 * * * *") // ok.30|OK:5-1,7 * * * *
  assert_eq(parse_text("8-2 * * * *"), "OK:8-2 * * * *") // ok.31|OK:8-2 * * * *
  assert_eq(parse_text("59 59 12 * * *"), "OK:59 59 12 * * *") // ok.32|OK:59 59 12 * * *
  assert_eq(parse_text("0 0 12 * * ? 2099"), "OK:0 0 12 * * ? 2099") // ok.33|OK:0 0 12 * * ? 2099
  assert_eq(parse_text("0 0 12 * * ? 1970"), "OK:0 0 12 * * ? 1970") // ok.34|OK:0 0 12 * * ? 1970
  assert_eq(parse_text("*/0 * * * *"), "NonPositiveStep[*/0]") // ok.35|CronException:Non positive divisor for field: [*/0]
  assert_eq(parse_text("60 * * * *"), "OutOfRange[MINUTE,60]") // ok.36|CronException:MINUTE value 60 out of range: [0 , 59]
  assert_eq(parse_text("-1 * * * *"), "OutOfRange[MINUTE,-1]") // ok.37|OK:-1 * * * * —— 本库改判（参照侧接受该输入，读数原样留在标签里）
  assert_eq(parse_text("abc * * * *"), "BadAlias[abc]") // ok.38|CronException:Invalid alias value: [abc]
  assert_eq(parse_text("* * * * FOO"), "BadAlias[FOO]") // ok.39|IllegalArgumentException:No enum constant cn.hutool.core.date.Week.FOO
  assert_eq(parse_text("* * * *"), "BadParts[* * * *]") // ok.40|CronException:Pattern [* * * *] is invalid, it must be 5-7 parts!
  assert_eq(parse_text("* * * * * * *"), "OK:* * * * * * *") // ok.41|OK:* * * * * * *
  assert_eq(parse_text(""), "BadParts[]") // ok.42|OK: —— 本库改判（参照侧接受该输入，读数原样留在标签里）
  assert_eq(parse_text("   "), "BadParts[   ]") // ok.43|OK: —— 本库改判（参照侧接受该输入，读数原样留在标签里）
  assert_eq(parse_text("0 12 * * 1-7"), "OK:0 12 * * 1-7") // ok.44|OK:0 12 * * 1-7
  assert_eq(parse_text("0 12 * * 0-7"), "OK:0 12 * * 0-7") // ok.45|OK:0 12 * * 0-7
  assert_eq(parse_text("0 12 32 * *"), "OutOfRange[DAY_OF_MONTH,32]") // ok.46|CronException:DAY_OF_MONTH value 32 out of range: [1 , 31]
  assert_eq(parse_text("0 12 0 * *"), "OutOfRange[DAY_OF_MONTH,0]") // ok.47|CronException:DAY_OF_MONTH value 0 out of range: [1 , 31]
  assert_eq(parse_text("0 24 * * *"), "OutOfRange[HOUR,24]") // ok.48|CronException:HOUR value 24 out of range: [0 , 23]
  assert_eq(parse_text("0 12 31 4 *"), "OK:0 12 31 4 *") // ok.49|OK:0 12 31 4 *
}

///|
test "cron match：50 表达式 × 12 时刻（秒段默认不参与）" {
  assert_eq(m_tag("* * * * *", dt(2024, 2, 29, 12, 0, 0), false), "OK:true") // m.0.0|OK:true
  assert_eq(m_tag("* * * * *", dt(2023, 2, 28, 23, 59, 0), false), "OK:true") // m.0.1|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.0.2|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 4, 30, 12, 0, 0), false), "OK:true") // m.0.3|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 6, 15, 12, 0, 0), false), "OK:true") // m.0.4|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 6, 14, 12, 0, 0), false), "OK:true") // m.0.5|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:true") // m.0.6|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:true") // m.0.7|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 6, 17, 9, 15, 0), false), "OK:true") // m.0.8|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 6, 17, 9, 15, 30), false), "OK:true") // m.0.9|OK:true
  assert_eq(m_tag("* * * * *", dt(2099, 12, 31, 12, 0, 0), false), "OK:true") // m.0.10|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:true") // m.0.11|OK:true
  assert_eq(m_tag("5 * * * *", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.1.0|OK:false
  assert_eq(m_tag("5 * * * *", dt(2023, 2, 28, 23, 59, 0), false), "OK:false") // m.1.1|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 3, 31, 12, 0, 0), false), "OK:false") // m.1.2|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 4, 30, 12, 0, 0), false), "OK:false") // m.1.3|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.1.4|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.1.5|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.1.6|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.1.7|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.1.8|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 6, 17, 9, 15, 30), false), "OK:false") // m.1.9|OK:false
  assert_eq(m_tag("5 * * * *", dt(2099, 12, 31, 12, 0, 0), false), "OK:false") // m.1.10|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.1.11|OK:false
  assert_eq(m_tag("*/2 * * * *", dt(2024, 2, 29, 12, 0, 0), false), "OK:true") // m.2.0|OK:true
  assert_eq(m_tag("*/2 * * * *", dt(2023, 2, 28, 23, 59, 0), false), "OK:false") // m.2.1|OK:false
  assert_eq(m_tag("*/2 * * * *", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.2.2|OK:true
  assert_eq(m_tag("*/2 * * * *", dt(2024, 4, 30, 12, 0, 0), false), "OK:true") // m.2.3|OK:true
  assert_eq(m_tag("*/2 * * * *", dt(2024, 6, 15, 12, 0, 0), false), "OK:true") // m.2.4|OK:true
  assert_eq(m_tag("*/2 * * * *", dt(2024, 6, 14, 12, 0, 0), false), "OK:true") // m.2.5|OK:true
  assert_eq(m_tag("*/2 * * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:true") // m.2.6|OK:true
  assert_eq(m_tag("*/2 * * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:true") // m.2.7|OK:true
  assert_eq(m_tag("*/2 * * * *", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.2.8|OK:false
  assert_eq(m_tag("*/2 * * * *", dt(2024, 6, 17, 9, 15, 30), false), "OK:false") // m.2.9|OK:false
  assert_eq(m_tag("*/2 * * * *", dt(2099, 12, 31, 12, 0, 0), false), "OK:true") // m.2.10|OK:true
  assert_eq(m_tag("*/2 * * * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:true") // m.2.11|OK:true
  assert_eq(m_tag("2-8 * * * *", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.3.0|OK:false
  assert_eq(m_tag("2-8 * * * *", dt(2023, 2, 28, 23, 59, 0), false), "OK:false") // m.3.1|OK:false
  assert_eq(m_tag("2-8 * * * *", dt(2024, 3, 31, 12, 0, 0), false), "OK:false") // m.3.2|OK:false
  assert_eq(m_tag("2-8 * * * *", dt(2024, 4, 30, 12, 0, 0), false), "OK:false") // m.3.3|OK:false
  assert_eq(m_tag("2-8 * * * *", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.3.4|OK:false
  assert_eq(m_tag("2-8 * * * *", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.3.5|OK:false
  assert_eq(m_tag("2-8 * * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.3.6|OK:false
  assert_eq(m_tag("2-8 * * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.3.7|OK:false
  assert_eq(m_tag("2-8 * * * *", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.3.8|OK:false
  assert_eq(m_tag("2-8 * * * *", dt(2024, 6, 17, 9, 15, 30), false), "OK:false") // m.3.9|OK:false
  assert_eq(m_tag("2-8 * * * *", dt(2099, 12, 31, 12, 0, 0), false), "OK:false") // m.3.10|OK:false
  assert_eq(m_tag("2-8 * * * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.3.11|OK:false
  assert_eq(
    m_tag("2,3,5,8 * * * *", dt(2024, 2, 29, 12, 0, 0), false),
    "OK:false",
  ) // m.4.0|OK:false
  assert_eq(
    m_tag("2,3,5,8 * * * *", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.4.1|OK:false
  assert_eq(
    m_tag("2,3,5,8 * * * *", dt(2024, 3, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.4.2|OK:false
  assert_eq(
    m_tag("2,3,5,8 * * * *", dt(2024, 4, 30, 12, 0, 0), false),
    "OK:false",
  ) // m.4.3|OK:false
  assert_eq(
    m_tag("2,3,5,8 * * * *", dt(2024, 6, 15, 12, 0, 0), false),
    "OK:false",
  ) // m.4.4|OK:false
  assert_eq(
    m_tag("2,3,5,8 * * * *", dt(2024, 6, 14, 12, 0, 0), false),
    "OK:false",
  ) // m.4.5|OK:false
  assert_eq(
    m_tag("2,3,5,8 * * * *", dt(2024, 6, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.4.6|OK:false
  assert_eq(
    m_tag("2,3,5,8 * * * *", dt(2024, 1, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.4.7|OK:false
  assert_eq(
    m_tag("2,3,5,8 * * * *", dt(2024, 6, 17, 9, 15, 0), false),
    "OK:false",
  ) // m.4.8|OK:false
  assert_eq(
    m_tag("2,3,5,8 * * * *", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.4.9|OK:false
  assert_eq(
    m_tag("2,3,5,8 * * * *", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.4.10|OK:false
  assert_eq(
    m_tag("2,3,5,8 * * * *", dt(2024, 2, 29, 0, 0, 0), false),
    "OK:false",
  ) // m.4.11|OK:false
  assert_eq(
    m_tag("2,3,6/3 * * * *", dt(2024, 2, 29, 12, 0, 0), false),
    "OK:false",
  ) // m.5.0|OK:false
  assert_eq(
    m_tag("2,3,6/3 * * * *", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.5.1|OK:false
  assert_eq(
    m_tag("2,3,6/3 * * * *", dt(2024, 3, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.5.2|OK:false
  assert_eq(
    m_tag("2,3,6/3 * * * *", dt(2024, 4, 30, 12, 0, 0), false),
    "OK:false",
  ) // m.5.3|OK:false
  assert_eq(
    m_tag("2,3,6/3 * * * *", dt(2024, 6, 15, 12, 0, 0), false),
    "OK:false",
  ) // m.5.4|OK:false
  assert_eq(
    m_tag("2,3,6/3 * * * *", dt(2024, 6, 14, 12, 0, 0), false),
    "OK:false",
  ) // m.5.5|OK:false
  assert_eq(
    m_tag("2,3,6/3 * * * *", dt(2024, 6, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.5.6|OK:false
  assert_eq(
    m_tag("2,3,6/3 * * * *", dt(2024, 1, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.5.7|OK:false
  assert_eq(
    m_tag("2,3,6/3 * * * *", dt(2024, 6, 17, 9, 15, 0), false),
    "OK:true",
  ) // m.5.8|OK:true
  assert_eq(
    m_tag("2,3,6/3 * * * *", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:true",
  ) // m.5.9|OK:true
  assert_eq(
    m_tag("2,3,6/3 * * * *", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.5.10|OK:false
  assert_eq(
    m_tag("2,3,6/3 * * * *", dt(2024, 2, 29, 0, 0, 0), false),
    "OK:false",
  ) // m.5.11|OK:false
  assert_eq(m_tag("? * * * *", dt(2024, 2, 29, 12, 0, 0), false), "OK:true") // m.6.0|OK:true
  assert_eq(m_tag("? * * * *", dt(2023, 2, 28, 23, 59, 0), false), "OK:true") // m.6.1|OK:true
  assert_eq(m_tag("? * * * *", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.6.2|OK:true
  assert_eq(m_tag("? * * * *", dt(2024, 4, 30, 12, 0, 0), false), "OK:true") // m.6.3|OK:true
  assert_eq(m_tag("? * * * *", dt(2024, 6, 15, 12, 0, 0), false), "OK:true") // m.6.4|OK:true
  assert_eq(m_tag("? * * * *", dt(2024, 6, 14, 12, 0, 0), false), "OK:true") // m.6.5|OK:true
  assert_eq(m_tag("? * * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:true") // m.6.6|OK:true
  assert_eq(m_tag("? * * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:true") // m.6.7|OK:true
  assert_eq(m_tag("? * * * *", dt(2024, 6, 17, 9, 15, 0), false), "OK:true") // m.6.8|OK:true
  assert_eq(m_tag("? * * * *", dt(2024, 6, 17, 9, 15, 30), false), "OK:true") // m.6.9|OK:true
  assert_eq(m_tag("? * * * *", dt(2099, 12, 31, 12, 0, 0), false), "OK:true") // m.6.10|OK:true
  assert_eq(m_tag("? * * * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:true") // m.6.11|OK:true
  assert_eq(m_tag("0 12 * * MON", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.7.0|OK:false
  assert_eq(
    m_tag("0 12 * * MON", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.7.1|OK:false
  assert_eq(m_tag("0 12 * * MON", dt(2024, 3, 31, 12, 0, 0), false), "OK:false") // m.7.2|OK:false
  assert_eq(m_tag("0 12 * * MON", dt(2024, 4, 30, 12, 0, 0), false), "OK:false") // m.7.3|OK:false
  assert_eq(m_tag("0 12 * * MON", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.7.4|OK:false
  assert_eq(m_tag("0 12 * * MON", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.7.5|OK:false
  assert_eq(m_tag("0 12 * * MON", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.7.6|OK:false
  assert_eq(m_tag("0 12 * * MON", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.7.7|OK:false
  assert_eq(m_tag("0 12 * * MON", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.7.8|OK:false
  assert_eq(
    m_tag("0 12 * * MON", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.7.9|OK:false
  assert_eq(
    m_tag("0 12 * * MON", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.7.10|OK:false
  assert_eq(m_tag("0 12 * * MON", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.7.11|OK:false
  assert_eq(m_tag("0 12 * * mon", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.8.0|OK:false
  assert_eq(
    m_tag("0 12 * * mon", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.8.1|OK:false
  assert_eq(m_tag("0 12 * * mon", dt(2024, 3, 31, 12, 0, 0), false), "OK:false") // m.8.2|OK:false
  assert_eq(m_tag("0 12 * * mon", dt(2024, 4, 30, 12, 0, 0), false), "OK:false") // m.8.3|OK:false
  assert_eq(m_tag("0 12 * * mon", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.8.4|OK:false
  assert_eq(m_tag("0 12 * * mon", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.8.5|OK:false
  assert_eq(m_tag("0 12 * * mon", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.8.6|OK:false
  assert_eq(m_tag("0 12 * * mon", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.8.7|OK:false
  assert_eq(m_tag("0 12 * * mon", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.8.8|OK:false
  assert_eq(
    m_tag("0 12 * * mon", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.8.9|OK:false
  assert_eq(
    m_tag("0 12 * * mon", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.8.10|OK:false
  assert_eq(m_tag("0 12 * * mon", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.8.11|OK:false
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 2, 29, 12, 0, 0), false),
    "OK:true",
  ) // m.9.0|OK:true
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.9.1|OK:false
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 3, 31, 12, 0, 0), false),
    "OK:true",
  ) // m.9.2|OK:true
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 4, 30, 12, 0, 0), false),
    "OK:false",
  ) // m.9.3|OK:false
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 6, 15, 12, 0, 0), false),
    "OK:false",
  ) // m.9.4|OK:false
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 6, 14, 12, 0, 0), false),
    "OK:false",
  ) // m.9.5|OK:false
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 6, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.9.6|OK:false
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 1, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.9.7|OK:false
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 6, 17, 9, 15, 0), false),
    "OK:false",
  ) // m.9.8|OK:false
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.9.9|OK:false
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.9.10|OK:false
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 2, 29, 0, 0, 0), false),
    "OK:false",
  ) // m.9.11|OK:false
  assert_eq(
    m_tag("0 12 * jan-mar *", dt(2024, 2, 29, 12, 0, 0), false),
    "OK:true",
  ) // m.10.0|OK:true
  assert_eq(
    m_tag("0 12 * jan-mar *", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.10.1|OK:false
  assert_eq(
    m_tag("0 12 * jan-mar *", dt(2024, 3, 31, 12, 0, 0), false),
    "OK:true",
  ) // m.10.2|OK:true
  assert_eq(
    m_tag("0 12 * jan-mar *", dt(2024, 4, 30, 12, 0, 0), false),
    "OK:false",
  ) // m.10.3|OK:false
  assert_eq(
    m_tag("0 12 * jan-mar *", dt(2024, 6, 15, 12, 0, 0), false),
    "OK:false",
  ) // m.10.4|OK:false
  assert_eq(
    m_tag("0 12 * jan-mar *", dt(2024, 6, 14, 12, 0, 0), false),
    "OK:false",
  ) // m.10.5|OK:false
  assert_eq(
    m_tag("0 12 * jan-mar *", dt(2024, 6, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.10.6|OK:false
  assert_eq(
    m_tag("0 12 * jan-mar *", dt(2024, 1, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.10.7|OK:false
  assert_eq(
    m_tag("0 12 * jan-mar *", dt(2024, 6, 17, 9, 15, 0), false),
    "OK:false",
  ) // m.10.8|OK:false
  assert_eq(
    m_tag("0 12 * jan-mar *", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.10.9|OK:false
  assert_eq(
    m_tag("0 12 * jan-mar *", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.10.10|OK:false
  assert_eq(
    m_tag("0 12 * jan-mar *", dt(2024, 2, 29, 0, 0, 0), false),
    "OK:false",
  ) // m.10.11|OK:false
  assert_eq(m_tag("0 12 L * *", dt(2024, 2, 29, 12, 0, 0), false), "OK:true") // m.11.0|OK:true
  assert_eq(m_tag("0 12 L * *", dt(2023, 2, 28, 23, 59, 0), false), "OK:false") // m.11.1|OK:false
  assert_eq(m_tag("0 12 L * *", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.11.2|OK:true
  assert_eq(m_tag("0 12 L * *", dt(2024, 4, 30, 12, 0, 0), false), "OK:true") // m.11.3|OK:true
  assert_eq(m_tag("0 12 L * *", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.11.4|OK:false
  assert_eq(m_tag("0 12 L * *", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.11.5|OK:false
  assert_eq(m_tag("0 12 L * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.11.6|OK:false
  assert_eq(m_tag("0 12 L * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.11.7|OK:false
  assert_eq(m_tag("0 12 L * *", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.11.8|OK:false
  assert_eq(m_tag("0 12 L * *", dt(2024, 6, 17, 9, 15, 30), false), "OK:false") // m.11.9|OK:false
  assert_eq(m_tag("0 12 L * *", dt(2099, 12, 31, 12, 0, 0), false), "OK:true") // m.11.10|OK:true
  assert_eq(m_tag("0 12 L * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.11.11|OK:false
  assert_eq(m_tag("0 12 * * 7", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.17.0|OK:false
  assert_eq(m_tag("0 12 * * 7", dt(2023, 2, 28, 23, 59, 0), false), "OK:false") // m.17.1|OK:false
  assert_eq(m_tag("0 12 * * 7", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.17.2|OK:true
  assert_eq(m_tag("0 12 * * 7", dt(2024, 4, 30, 12, 0, 0), false), "OK:false") // m.17.3|OK:false
  assert_eq(m_tag("0 12 * * 7", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.17.4|OK:false
  assert_eq(m_tag("0 12 * * 7", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.17.5|OK:false
  assert_eq(m_tag("0 12 * * 7", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.17.6|OK:false
  assert_eq(m_tag("0 12 * * 7", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.17.7|OK:false
  assert_eq(m_tag("0 12 * * 7", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.17.8|OK:false
  assert_eq(m_tag("0 12 * * 7", dt(2024, 6, 17, 9, 15, 30), false), "OK:false") // m.17.9|OK:false
  assert_eq(m_tag("0 12 * * 7", dt(2099, 12, 31, 12, 0, 0), false), "OK:false") // m.17.10|OK:false
  assert_eq(m_tag("0 12 * * 7", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.17.11|OK:false
  assert_eq(m_tag("0 12 * * 0", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.18.0|OK:false
  assert_eq(m_tag("0 12 * * 0", dt(2023, 2, 28, 23, 59, 0), false), "OK:false") // m.18.1|OK:false
  assert_eq(m_tag("0 12 * * 0", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.18.2|OK:true
  assert_eq(m_tag("0 12 * * 0", dt(2024, 4, 30, 12, 0, 0), false), "OK:false") // m.18.3|OK:false
  assert_eq(m_tag("0 12 * * 0", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.18.4|OK:false
  assert_eq(m_tag("0 12 * * 0", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.18.5|OK:false
  assert_eq(m_tag("0 12 * * 0", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.18.6|OK:false
  assert_eq(m_tag("0 12 * * 0", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.18.7|OK:false
  assert_eq(m_tag("0 12 * * 0", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.18.8|OK:false
  assert_eq(m_tag("0 12 * * 0", dt(2024, 6, 17, 9, 15, 30), false), "OK:false") // m.18.9|OK:false
  assert_eq(m_tag("0 12 * * 0", dt(2099, 12, 31, 12, 0, 0), false), "OK:false") // m.18.10|OK:false
  assert_eq(m_tag("0 12 * * 0", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.18.11|OK:false
  assert_eq(m_tag("0 12 1 * MON", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.19.0|OK:false
  assert_eq(
    m_tag("0 12 1 * MON", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.19.1|OK:false
  assert_eq(m_tag("0 12 1 * MON", dt(2024, 3, 31, 12, 0, 0), false), "OK:false") // m.19.2|OK:false
  assert_eq(m_tag("0 12 1 * MON", dt(2024, 4, 30, 12, 0, 0), false), "OK:false") // m.19.3|OK:false
  assert_eq(m_tag("0 12 1 * MON", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.19.4|OK:false
  assert_eq(m_tag("0 12 1 * MON", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.19.5|OK:false
  assert_eq(m_tag("0 12 1 * MON", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.19.6|OK:false
  assert_eq(m_tag("0 12 1 * MON", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.19.7|OK:false
  assert_eq(m_tag("0 12 1 * MON", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.19.8|OK:false
  assert_eq(
    m_tag("0 12 1 * MON", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.19.9|OK:false
  assert_eq(
    m_tag("0 12 1 * MON", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.19.10|OK:false
  assert_eq(m_tag("0 12 1 * MON", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.19.11|OK:false
  assert_eq(
    m_tag("0 12 * * SAT,SUN", dt(2024, 2, 29, 12, 0, 0), false),
    "OK:false",
  ) // m.20.0|OK:false
  assert_eq(
    m_tag("0 12 * * SAT,SUN", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.20.1|OK:false
  assert_eq(
    m_tag("0 12 * * SAT,SUN", dt(2024, 3, 31, 12, 0, 0), false),
    "OK:true",
  ) // m.20.2|OK:true
  assert_eq(
    m_tag("0 12 * * SAT,SUN", dt(2024, 4, 30, 12, 0, 0), false),
    "OK:false",
  ) // m.20.3|OK:false
  assert_eq(
    m_tag("0 12 * * SAT,SUN", dt(2024, 6, 15, 12, 0, 0), false),
    "OK:true",
  ) // m.20.4|OK:true
  assert_eq(
    m_tag("0 12 * * SAT,SUN", dt(2024, 6, 14, 12, 0, 0), false),
    "OK:false",
  ) // m.20.5|OK:false
  assert_eq(
    m_tag("0 12 * * SAT,SUN", dt(2024, 6, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.20.6|OK:false
  assert_eq(
    m_tag("0 12 * * SAT,SUN", dt(2024, 1, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.20.7|OK:false
  assert_eq(
    m_tag("0 12 * * SAT,SUN", dt(2024, 6, 17, 9, 15, 0), false),
    "OK:false",
  ) // m.20.8|OK:false
  assert_eq(
    m_tag("0 12 * * SAT,SUN", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.20.9|OK:false
  assert_eq(
    m_tag("0 12 * * SAT,SUN", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.20.10|OK:false
  assert_eq(
    m_tag("0 12 * * SAT,SUN", dt(2024, 2, 29, 0, 0, 0), false),
    "OK:false",
  ) // m.20.11|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 2, 29, 12, 0, 0), false),
    "OK:true",
  ) // m.21.0|OK:true
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.21.1|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 3, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.21.2|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 4, 30, 12, 0, 0), false),
    "OK:true",
  ) // m.21.3|OK:true
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 15, 12, 0, 0), false),
    "OK:false",
  ) // m.21.4|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 14, 12, 0, 0), false),
    "OK:true",
  ) // m.21.5|OK:true
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.21.6|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 1, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.21.7|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 17, 9, 15, 0), false),
    "OK:true",
  ) // m.21.8|OK:true
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:true",
  ) // m.21.9|OK:true
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:true",
  ) // m.21.10|OK:true
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 2, 29, 0, 0, 0), false),
    "OK:false",
  ) // m.21.11|OK:false
  assert_eq(m_tag("0 0 * * SUN", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.22.0|OK:false
  assert_eq(m_tag("0 0 * * SUN", dt(2023, 2, 28, 23, 59, 0), false), "OK:false") // m.22.1|OK:false
  assert_eq(m_tag("0 0 * * SUN", dt(2024, 3, 31, 12, 0, 0), false), "OK:false") // m.22.2|OK:false
  assert_eq(m_tag("0 0 * * SUN", dt(2024, 4, 30, 12, 0, 0), false), "OK:false") // m.22.3|OK:false
  assert_eq(m_tag("0 0 * * SUN", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.22.4|OK:false
  assert_eq(m_tag("0 0 * * SUN", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.22.5|OK:false
  assert_eq(m_tag("0 0 * * SUN", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.22.6|OK:false
  assert_eq(m_tag("0 0 * * SUN", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.22.7|OK:false
  assert_eq(m_tag("0 0 * * SUN", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.22.8|OK:false
  assert_eq(m_tag("0 0 * * SUN", dt(2024, 6, 17, 9, 15, 30), false), "OK:false") // m.22.9|OK:false
  assert_eq(m_tag("0 0 * * SUN", dt(2099, 12, 31, 12, 0, 0), false), "OK:false") // m.22.10|OK:false
  assert_eq(m_tag("0 0 * * SUN", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.22.11|OK:false
  assert_eq(m_tag("0 0 1 1 *", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.23.0|OK:false
  assert_eq(m_tag("0 0 1 1 *", dt(2023, 2, 28, 23, 59, 0), false), "OK:false") // m.23.1|OK:false
  assert_eq(m_tag("0 0 1 1 *", dt(2024, 3, 31, 12, 0, 0), false), "OK:false") // m.23.2|OK:false
  assert_eq(m_tag("0 0 1 1 *", dt(2024, 4, 30, 12, 0, 0), false), "OK:false") // m.23.3|OK:false
  assert_eq(m_tag("0 0 1 1 *", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.23.4|OK:false
  assert_eq(m_tag("0 0 1 1 *", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.23.5|OK:false
  assert_eq(m_tag("0 0 1 1 *", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.23.6|OK:false
  assert_eq(m_tag("0 0 1 1 *", dt(2024, 1, 1, 0, 0, 0), false), "OK:true") // m.23.7|OK:true
  assert_eq(m_tag("0 0 1 1 *", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.23.8|OK:false
  assert_eq(m_tag("0 0 1 1 *", dt(2024, 6, 17, 9, 15, 30), false), "OK:false") // m.23.9|OK:false
  assert_eq(m_tag("0 0 1 1 *", dt(2099, 12, 31, 12, 0, 0), false), "OK:false") // m.23.10|OK:false
  assert_eq(m_tag("0 0 1 1 *", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.23.11|OK:false
  assert_eq(m_tag("0 0 29 2 *", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.24.0|OK:false
  assert_eq(m_tag("0 0 29 2 *", dt(2023, 2, 28, 23, 59, 0), false), "OK:false") // m.24.1|OK:false
  assert_eq(m_tag("0 0 29 2 *", dt(2024, 3, 31, 12, 0, 0), false), "OK:false") // m.24.2|OK:false
  assert_eq(m_tag("0 0 29 2 *", dt(2024, 4, 30, 12, 0, 0), false), "OK:false") // m.24.3|OK:false
  assert_eq(m_tag("0 0 29 2 *", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.24.4|OK:false
  assert_eq(m_tag("0 0 29 2 *", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.24.5|OK:false
  assert_eq(m_tag("0 0 29 2 *", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.24.6|OK:false
  assert_eq(m_tag("0 0 29 2 *", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.24.7|OK:false
  assert_eq(m_tag("0 0 29 2 *", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.24.8|OK:false
  assert_eq(m_tag("0 0 29 2 *", dt(2024, 6, 17, 9, 15, 30), false), "OK:false") // m.24.9|OK:false
  assert_eq(m_tag("0 0 29 2 *", dt(2099, 12, 31, 12, 0, 0), false), "OK:false") // m.24.10|OK:false
  assert_eq(m_tag("0 0 29 2 *", dt(2024, 2, 29, 0, 0, 0), false), "OK:true") // m.24.11|OK:true
  assert_eq(m_tag("0 12 */3 * *", dt(2024, 2, 29, 12, 0, 0), false), "OK:true") // m.25.0|OK:true
  assert_eq(
    m_tag("0 12 */3 * *", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.25.1|OK:false
  assert_eq(m_tag("0 12 */3 * *", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.25.2|OK:true
  assert_eq(m_tag("0 12 */3 * *", dt(2024, 4, 30, 12, 0, 0), false), "OK:true") // m.25.3|OK:true
  assert_eq(m_tag("0 12 */3 * *", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.25.4|OK:false
  assert_eq(m_tag("0 12 */3 * *", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.25.5|OK:false
  assert_eq(m_tag("0 12 */3 * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.25.6|OK:false
  assert_eq(m_tag("0 12 */3 * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.25.7|OK:false
  assert_eq(m_tag("0 12 */3 * *", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.25.8|OK:false
  assert_eq(
    m_tag("0 12 */3 * *", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.25.9|OK:false
  assert_eq(m_tag("0 12 */3 * *", dt(2099, 12, 31, 12, 0, 0), false), "OK:true") // m.25.10|OK:true
  assert_eq(m_tag("0 12 */3 * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.25.11|OK:false
  assert_eq(m_tag("30 6 * * *", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.26.0|OK:false
  assert_eq(m_tag("30 6 * * *", dt(2023, 2, 28, 23, 59, 0), false), "OK:false") // m.26.1|OK:false
  assert_eq(m_tag("30 6 * * *", dt(2024, 3, 31, 12, 0, 0), false), "OK:false") // m.26.2|OK:false
  assert_eq(m_tag("30 6 * * *", dt(2024, 4, 30, 12, 0, 0), false), "OK:false") // m.26.3|OK:false
  assert_eq(m_tag("30 6 * * *", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.26.4|OK:false
  assert_eq(m_tag("30 6 * * *", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.26.5|OK:false
  assert_eq(m_tag("30 6 * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.26.6|OK:false
  assert_eq(m_tag("30 6 * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.26.7|OK:false
  assert_eq(m_tag("30 6 * * *", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.26.8|OK:false
  assert_eq(m_tag("30 6 * * *", dt(2024, 6, 17, 9, 15, 30), false), "OK:false") // m.26.9|OK:false
  assert_eq(m_tag("30 6 * * *", dt(2099, 12, 31, 12, 0, 0), false), "OK:false") // m.26.10|OK:false
  assert_eq(m_tag("30 6 * * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.26.11|OK:false
  assert_eq(
    m_tag("0-59/13 * * * *", dt(2024, 2, 29, 12, 0, 0), false),
    "OK:true",
  ) // m.27.0|OK:true
  assert_eq(
    m_tag("0-59/13 * * * *", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.27.1|OK:false
  assert_eq(
    m_tag("0-59/13 * * * *", dt(2024, 3, 31, 12, 0, 0), false),
    "OK:true",
  ) // m.27.2|OK:true
  assert_eq(
    m_tag("0-59/13 * * * *", dt(2024, 4, 30, 12, 0, 0), false),
    "OK:true",
  ) // m.27.3|OK:true
  assert_eq(
    m_tag("0-59/13 * * * *", dt(2024, 6, 15, 12, 0, 0), false),
    "OK:true",
  ) // m.27.4|OK:true
  assert_eq(
    m_tag("0-59/13 * * * *", dt(2024, 6, 14, 12, 0, 0), false),
    "OK:true",
  ) // m.27.5|OK:true
  assert_eq(m_tag("0-59/13 * * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:true") // m.27.6|OK:true
  assert_eq(m_tag("0-59/13 * * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:true") // m.27.7|OK:true
  assert_eq(
    m_tag("0-59/13 * * * *", dt(2024, 6, 17, 9, 15, 0), false),
    "OK:false",
  ) // m.27.8|OK:false
  assert_eq(
    m_tag("0-59/13 * * * *", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.27.9|OK:false
  assert_eq(
    m_tag("0-59/13 * * * *", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:true",
  ) // m.27.10|OK:true
  assert_eq(
    m_tag("0-59/13 * * * *", dt(2024, 2, 29, 0, 0, 0), false),
    "OK:true",
  ) // m.27.11|OK:true
  assert_eq(m_tag("*/7 * * * *", dt(2024, 2, 29, 12, 0, 0), false), "OK:true") // m.28.0|OK:true
  assert_eq(m_tag("*/7 * * * *", dt(2023, 2, 28, 23, 59, 0), false), "OK:false") // m.28.1|OK:false
  assert_eq(m_tag("*/7 * * * *", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.28.2|OK:true
  assert_eq(m_tag("*/7 * * * *", dt(2024, 4, 30, 12, 0, 0), false), "OK:true") // m.28.3|OK:true
  assert_eq(m_tag("*/7 * * * *", dt(2024, 6, 15, 12, 0, 0), false), "OK:true") // m.28.4|OK:true
  assert_eq(m_tag("*/7 * * * *", dt(2024, 6, 14, 12, 0, 0), false), "OK:true") // m.28.5|OK:true
  assert_eq(m_tag("*/7 * * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:true") // m.28.6|OK:true
  assert_eq(m_tag("*/7 * * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:true") // m.28.7|OK:true
  assert_eq(m_tag("*/7 * * * *", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.28.8|OK:false
  assert_eq(m_tag("*/7 * * * *", dt(2024, 6, 17, 9, 15, 30), false), "OK:false") // m.28.9|OK:false
  assert_eq(m_tag("*/7 * * * *", dt(2099, 12, 31, 12, 0, 0), false), "OK:true") // m.28.10|OK:true
  assert_eq(m_tag("*/7 * * * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:true") // m.28.11|OK:true
  assert_eq(
    m_tag("1,1,1 * * * *", dt(2024, 2, 29, 12, 0, 0), false),
    "OK:false",
  ) // m.29.0|OK:false
  assert_eq(
    m_tag("1,1,1 * * * *", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.29.1|OK:false
  assert_eq(
    m_tag("1,1,1 * * * *", dt(2024, 3, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.29.2|OK:false
  assert_eq(
    m_tag("1,1,1 * * * *", dt(2024, 4, 30, 12, 0, 0), false),
    "OK:false",
  ) // m.29.3|OK:false
  assert_eq(
    m_tag("1,1,1 * * * *", dt(2024, 6, 15, 12, 0, 0), false),
    "OK:false",
  ) // m.29.4|OK:false
  assert_eq(
    m_tag("1,1,1 * * * *", dt(2024, 6, 14, 12, 0, 0), false),
    "OK:false",
  ) // m.29.5|OK:false
  assert_eq(m_tag("1,1,1 * * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.29.6|OK:false
  assert_eq(m_tag("1,1,1 * * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.29.7|OK:false
  assert_eq(
    m_tag("1,1,1 * * * *", dt(2024, 6, 17, 9, 15, 0), false),
    "OK:false",
  ) // m.29.8|OK:false
  assert_eq(
    m_tag("1,1,1 * * * *", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.29.9|OK:false
  assert_eq(
    m_tag("1,1,1 * * * *", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.29.10|OK:false
  assert_eq(m_tag("1,1,1 * * * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.29.11|OK:false
  assert_eq(m_tag("5-1,7 * * * *", dt(2024, 2, 29, 12, 0, 0), false), "OK:true") // m.30.0|OK:true
  assert_eq(
    m_tag("5-1,7 * * * *", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:true",
  ) // m.30.1|OK:true
  assert_eq(m_tag("5-1,7 * * * *", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.30.2|OK:true
  assert_eq(m_tag("5-1,7 * * * *", dt(2024, 4, 30, 12, 0, 0), false), "OK:true") // m.30.3|OK:true
  assert_eq(m_tag("5-1,7 * * * *", dt(2024, 6, 15, 12, 0, 0), false), "OK:true") // m.30.4|OK:true
  assert_eq(m_tag("5-1,7 * * * *", dt(2024, 6, 14, 12, 0, 0), false), "OK:true") // m.30.5|OK:true
  assert_eq(m_tag("5-1,7 * * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:true") // m.30.6|OK:true
  assert_eq(m_tag("5-1,7 * * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:true") // m.30.7|OK:true
  assert_eq(m_tag("5-1,7 * * * *", dt(2024, 6, 17, 9, 15, 0), false), "OK:true") // m.30.8|OK:true
  assert_eq(
    m_tag("5-1,7 * * * *", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:true",
  ) // m.30.9|OK:true
  assert_eq(
    m_tag("5-1,7 * * * *", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:true",
  ) // m.30.10|OK:true
  assert_eq(m_tag("5-1,7 * * * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:true") // m.30.11|OK:true
  assert_eq(m_tag("8-2 * * * *", dt(2024, 2, 29, 12, 0, 0), false), "OK:true") // m.31.0|OK:true
  assert_eq(m_tag("8-2 * * * *", dt(2023, 2, 28, 23, 59, 0), false), "OK:true") // m.31.1|OK:true
  assert_eq(m_tag("8-2 * * * *", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.31.2|OK:true
  assert_eq(m_tag("8-2 * * * *", dt(2024, 4, 30, 12, 0, 0), false), "OK:true") // m.31.3|OK:true
  assert_eq(m_tag("8-2 * * * *", dt(2024, 6, 15, 12, 0, 0), false), "OK:true") // m.31.4|OK:true
  assert_eq(m_tag("8-2 * * * *", dt(2024, 6, 14, 12, 0, 0), false), "OK:true") // m.31.5|OK:true
  assert_eq(m_tag("8-2 * * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:true") // m.31.6|OK:true
  assert_eq(m_tag("8-2 * * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:true") // m.31.7|OK:true
  assert_eq(m_tag("8-2 * * * *", dt(2024, 6, 17, 9, 15, 0), false), "OK:true") // m.31.8|OK:true
  assert_eq(m_tag("8-2 * * * *", dt(2024, 6, 17, 9, 15, 30), false), "OK:true") // m.31.9|OK:true
  assert_eq(m_tag("8-2 * * * *", dt(2099, 12, 31, 12, 0, 0), false), "OK:true") // m.31.10|OK:true
  assert_eq(m_tag("8-2 * * * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:true") // m.31.11|OK:true
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 2, 29, 12, 0, 0), false),
    "OK:false",
  ) // m.32.0|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.32.1|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 3, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.32.2|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 4, 30, 12, 0, 0), false),
    "OK:false",
  ) // m.32.3|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 6, 15, 12, 0, 0), false),
    "OK:false",
  ) // m.32.4|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 6, 14, 12, 0, 0), false),
    "OK:false",
  ) // m.32.5|OK:false
  assert_eq(m_tag("59 59 12 * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.32.6|OK:false
  assert_eq(m_tag("59 59 12 * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.32.7|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 6, 17, 9, 15, 0), false),
    "OK:false",
  ) // m.32.8|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.32.9|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.32.10|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 2, 29, 0, 0, 0), false),
    "OK:false",
  ) // m.32.11|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 2, 29, 12, 0, 0), false),
    "OK:false",
  ) // m.33.0|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.33.1|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 3, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.33.2|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 4, 30, 12, 0, 0), false),
    "OK:false",
  ) // m.33.3|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 6, 15, 12, 0, 0), false),
    "OK:false",
  ) // m.33.4|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 6, 14, 12, 0, 0), false),
    "OK:false",
  ) // m.33.5|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 6, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.33.6|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 1, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.33.7|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 6, 17, 9, 15, 0), false),
    "OK:false",
  ) // m.33.8|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.33.9|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:true",
  ) // m.33.10|OK:true
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 2, 29, 0, 0, 0), false),
    "OK:false",
  ) // m.33.11|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 2, 29, 12, 0, 0), false),
    "OK:false",
  ) // m.34.0|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.34.1|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 3, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.34.2|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 4, 30, 12, 0, 0), false),
    "OK:false",
  ) // m.34.3|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 6, 15, 12, 0, 0), false),
    "OK:false",
  ) // m.34.4|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 6, 14, 12, 0, 0), false),
    "OK:false",
  ) // m.34.5|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 6, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.34.6|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 1, 1, 0, 0, 0), false),
    "OK:false",
  ) // m.34.7|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 6, 17, 9, 15, 0), false),
    "OK:false",
  ) // m.34.8|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.34.9|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.34.10|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 2, 29, 0, 0, 0), false),
    "OK:false",
  ) // m.34.11|OK:false
  assert_eq(m_tag("* * * * * * *", dt(2024, 2, 29, 12, 0, 0), false), "OK:true") // m.41.0|OK:true
  assert_eq(
    m_tag("* * * * * * *", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:true",
  ) // m.41.1|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.41.2|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 4, 30, 12, 0, 0), false), "OK:true") // m.41.3|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 6, 15, 12, 0, 0), false), "OK:true") // m.41.4|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 6, 14, 12, 0, 0), false), "OK:true") // m.41.5|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 6, 1, 0, 0, 0), false), "OK:true") // m.41.6|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 1, 1, 0, 0, 0), false), "OK:true") // m.41.7|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 6, 17, 9, 15, 0), false), "OK:true") // m.41.8|OK:true
  assert_eq(
    m_tag("* * * * * * *", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:true",
  ) // m.41.9|OK:true
  assert_eq(
    m_tag("* * * * * * *", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:true",
  ) // m.41.10|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 2, 29, 0, 0, 0), false), "OK:true") // m.41.11|OK:true
  assert_eq(m_tag("0 12 * * 1-7", dt(2024, 2, 29, 12, 0, 0), false), "OK:true") // m.44.0|OK:true
  assert_eq(
    m_tag("0 12 * * 1-7", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.44.1|OK:false
  assert_eq(m_tag("0 12 * * 1-7", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.44.2|OK:true
  assert_eq(m_tag("0 12 * * 1-7", dt(2024, 4, 30, 12, 0, 0), false), "OK:true") // m.44.3|OK:true
  assert_eq(m_tag("0 12 * * 1-7", dt(2024, 6, 15, 12, 0, 0), false), "OK:true") // m.44.4|OK:true
  assert_eq(m_tag("0 12 * * 1-7", dt(2024, 6, 14, 12, 0, 0), false), "OK:true") // m.44.5|OK:true
  assert_eq(m_tag("0 12 * * 1-7", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.44.6|OK:false
  assert_eq(m_tag("0 12 * * 1-7", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.44.7|OK:false
  assert_eq(m_tag("0 12 * * 1-7", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.44.8|OK:false
  assert_eq(
    m_tag("0 12 * * 1-7", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.44.9|OK:false
  assert_eq(m_tag("0 12 * * 1-7", dt(2099, 12, 31, 12, 0, 0), false), "OK:true") // m.44.10|OK:true
  assert_eq(m_tag("0 12 * * 1-7", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.44.11|OK:false
  assert_eq(m_tag("0 12 * * 0-7", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.45.0|OK:false
  assert_eq(
    m_tag("0 12 * * 0-7", dt(2023, 2, 28, 23, 59, 0), false),
    "OK:false",
  ) // m.45.1|OK:false
  assert_eq(m_tag("0 12 * * 0-7", dt(2024, 3, 31, 12, 0, 0), false), "OK:true") // m.45.2|OK:true
  assert_eq(m_tag("0 12 * * 0-7", dt(2024, 4, 30, 12, 0, 0), false), "OK:false") // m.45.3|OK:false
  assert_eq(m_tag("0 12 * * 0-7", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.45.4|OK:false
  assert_eq(m_tag("0 12 * * 0-7", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.45.5|OK:false
  assert_eq(m_tag("0 12 * * 0-7", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.45.6|OK:false
  assert_eq(m_tag("0 12 * * 0-7", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.45.7|OK:false
  assert_eq(m_tag("0 12 * * 0-7", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.45.8|OK:false
  assert_eq(
    m_tag("0 12 * * 0-7", dt(2024, 6, 17, 9, 15, 30), false),
    "OK:false",
  ) // m.45.9|OK:false
  assert_eq(
    m_tag("0 12 * * 0-7", dt(2099, 12, 31, 12, 0, 0), false),
    "OK:false",
  ) // m.45.10|OK:false
  assert_eq(m_tag("0 12 * * 0-7", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.45.11|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 2, 29, 12, 0, 0), false), "OK:false") // m.49.0|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2023, 2, 28, 23, 59, 0), false), "OK:false") // m.49.1|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 3, 31, 12, 0, 0), false), "OK:false") // m.49.2|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 4, 30, 12, 0, 0), false), "OK:true") // m.49.3|OK:true
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.49.4|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.49.5|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.49.6|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 1, 1, 0, 0, 0), false), "OK:false") // m.49.7|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 6, 17, 9, 15, 0), false), "OK:false") // m.49.8|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 6, 17, 9, 15, 30), false), "OK:false") // m.49.9|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2099, 12, 31, 12, 0, 0), false), "OK:false") // m.49.10|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 2, 29, 0, 0, 0), false), "OK:false") // m.49.11|OK:false
}

///|
test "cron match_second：6/7 段与非秒段的分岔档" {
  assert_eq(m_tag("* * * * *", dt(2024, 2, 29, 12, 0, 0), true), "OK:true") // ms.0.0|OK:true
  assert_eq(m_tag("* * * * *", dt(2023, 2, 28, 23, 59, 0), true), "OK:true") // ms.0.1|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 3, 31, 12, 0, 0), true), "OK:true") // ms.0.2|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 4, 30, 12, 0, 0), true), "OK:true") // ms.0.3|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 6, 15, 12, 0, 0), true), "OK:true") // ms.0.4|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 6, 14, 12, 0, 0), true), "OK:true") // ms.0.5|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 6, 1, 0, 0, 0), true), "OK:true") // ms.0.6|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 1, 1, 0, 0, 0), true), "OK:true") // ms.0.7|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 6, 17, 9, 15, 0), true), "OK:true") // ms.0.8|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 6, 17, 9, 15, 30), true), "OK:false") // ms.0.9|OK:false
  assert_eq(m_tag("* * * * *", dt(2099, 12, 31, 12, 0, 0), true), "OK:true") // ms.0.10|OK:true
  assert_eq(m_tag("* * * * *", dt(2024, 2, 29, 0, 0, 0), true), "OK:true") // ms.0.11|OK:true
  assert_eq(m_tag("5 * * * *", dt(2024, 2, 29, 12, 0, 0), true), "OK:false") // ms.1.0|OK:false
  assert_eq(m_tag("5 * * * *", dt(2023, 2, 28, 23, 59, 0), true), "OK:false") // ms.1.1|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 3, 31, 12, 0, 0), true), "OK:false") // ms.1.2|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 4, 30, 12, 0, 0), true), "OK:false") // ms.1.3|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 6, 15, 12, 0, 0), true), "OK:false") // ms.1.4|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 6, 14, 12, 0, 0), true), "OK:false") // ms.1.5|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 6, 1, 0, 0, 0), true), "OK:false") // ms.1.6|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 1, 1, 0, 0, 0), true), "OK:false") // ms.1.7|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 6, 17, 9, 15, 0), true), "OK:false") // ms.1.8|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 6, 17, 9, 15, 30), true), "OK:false") // ms.1.9|OK:false
  assert_eq(m_tag("5 * * * *", dt(2099, 12, 31, 12, 0, 0), true), "OK:false") // ms.1.10|OK:false
  assert_eq(m_tag("5 * * * *", dt(2024, 2, 29, 0, 0, 0), true), "OK:false") // ms.1.11|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 2, 29, 12, 0, 0), true),
    "OK:true",
  ) // ms.21.0|OK:true
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2023, 2, 28, 23, 59, 0), true),
    "OK:false",
  ) // ms.21.1|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 3, 31, 12, 0, 0), true),
    "OK:false",
  ) // ms.21.2|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 4, 30, 12, 0, 0), true),
    "OK:true",
  ) // ms.21.3|OK:true
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 15, 12, 0, 0), true),
    "OK:false",
  ) // ms.21.4|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 14, 12, 0, 0), true),
    "OK:true",
  ) // ms.21.5|OK:true
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 1, 0, 0, 0), true),
    "OK:false",
  ) // ms.21.6|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 1, 1, 0, 0, 0), true),
    "OK:false",
  ) // ms.21.7|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 17, 9, 15, 0), true),
    "OK:true",
  ) // ms.21.8|OK:true
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 17, 9, 15, 30), true),
    "OK:false",
  ) // ms.21.9|OK:false
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2099, 12, 31, 12, 0, 0), true),
    "OK:true",
  ) // ms.21.10|OK:true
  assert_eq(
    m_tag("*/15 9-17 * * MON-FRI", dt(2024, 2, 29, 0, 0, 0), true),
    "OK:false",
  ) // ms.21.11|OK:false
  assert_eq(m_tag("1,1,1 * * * *", dt(2024, 2, 29, 12, 0, 0), true), "OK:false") // ms.29.0|OK:false
  assert_eq(
    m_tag("1,1,1 * * * *", dt(2023, 2, 28, 23, 59, 0), true),
    "OK:false",
  ) // ms.29.1|OK:false
  assert_eq(m_tag("1,1,1 * * * *", dt(2024, 3, 31, 12, 0, 0), true), "OK:false") // ms.29.2|OK:false
  assert_eq(m_tag("1,1,1 * * * *", dt(2024, 4, 30, 12, 0, 0), true), "OK:false") // ms.29.3|OK:false
  assert_eq(m_tag("1,1,1 * * * *", dt(2024, 6, 15, 12, 0, 0), true), "OK:false") // ms.29.4|OK:false
  assert_eq(m_tag("1,1,1 * * * *", dt(2024, 6, 14, 12, 0, 0), true), "OK:false") // ms.29.5|OK:false
  assert_eq(m_tag("1,1,1 * * * *", dt(2024, 6, 1, 0, 0, 0), true), "OK:false") // ms.29.6|OK:false
  assert_eq(m_tag("1,1,1 * * * *", dt(2024, 1, 1, 0, 0, 0), true), "OK:false") // ms.29.7|OK:false
  assert_eq(m_tag("1,1,1 * * * *", dt(2024, 6, 17, 9, 15, 0), true), "OK:false") // ms.29.8|OK:false
  assert_eq(
    m_tag("1,1,1 * * * *", dt(2024, 6, 17, 9, 15, 30), true),
    "OK:false",
  ) // ms.29.9|OK:false
  assert_eq(
    m_tag("1,1,1 * * * *", dt(2099, 12, 31, 12, 0, 0), true),
    "OK:false",
  ) // ms.29.10|OK:false
  assert_eq(m_tag("1,1,1 * * * *", dt(2024, 2, 29, 0, 0, 0), true), "OK:false") // ms.29.11|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 2, 29, 12, 0, 0), true),
    "OK:false",
  ) // ms.32.0|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2023, 2, 28, 23, 59, 0), true),
    "OK:false",
  ) // ms.32.1|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 3, 31, 12, 0, 0), true),
    "OK:false",
  ) // ms.32.2|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 4, 30, 12, 0, 0), true),
    "OK:false",
  ) // ms.32.3|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 6, 15, 12, 0, 0), true),
    "OK:false",
  ) // ms.32.4|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 6, 14, 12, 0, 0), true),
    "OK:false",
  ) // ms.32.5|OK:false
  assert_eq(m_tag("59 59 12 * * *", dt(2024, 6, 1, 0, 0, 0), true), "OK:false") // ms.32.6|OK:false
  assert_eq(m_tag("59 59 12 * * *", dt(2024, 1, 1, 0, 0, 0), true), "OK:false") // ms.32.7|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 6, 17, 9, 15, 0), true),
    "OK:false",
  ) // ms.32.8|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2024, 6, 17, 9, 15, 30), true),
    "OK:false",
  ) // ms.32.9|OK:false
  assert_eq(
    m_tag("59 59 12 * * *", dt(2099, 12, 31, 12, 0, 0), true),
    "OK:false",
  ) // ms.32.10|OK:false
  assert_eq(m_tag("59 59 12 * * *", dt(2024, 2, 29, 0, 0, 0), true), "OK:false") // ms.32.11|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 2, 29, 12, 0, 0), true),
    "OK:false",
  ) // ms.33.0|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2023, 2, 28, 23, 59, 0), true),
    "OK:false",
  ) // ms.33.1|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 3, 31, 12, 0, 0), true),
    "OK:false",
  ) // ms.33.2|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 4, 30, 12, 0, 0), true),
    "OK:false",
  ) // ms.33.3|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 6, 15, 12, 0, 0), true),
    "OK:false",
  ) // ms.33.4|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 6, 14, 12, 0, 0), true),
    "OK:false",
  ) // ms.33.5|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 6, 1, 0, 0, 0), true),
    "OK:false",
  ) // ms.33.6|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 1, 1, 0, 0, 0), true),
    "OK:false",
  ) // ms.33.7|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 6, 17, 9, 15, 0), true),
    "OK:false",
  ) // ms.33.8|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 6, 17, 9, 15, 30), true),
    "OK:false",
  ) // ms.33.9|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2099, 12, 31, 12, 0, 0), true),
    "OK:true",
  ) // ms.33.10|OK:true
  assert_eq(
    m_tag("0 0 12 * * ? 2099", dt(2024, 2, 29, 0, 0, 0), true),
    "OK:false",
  ) // ms.33.11|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 2, 29, 12, 0, 0), true),
    "OK:false",
  ) // ms.34.0|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2023, 2, 28, 23, 59, 0), true),
    "OK:false",
  ) // ms.34.1|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 3, 31, 12, 0, 0), true),
    "OK:false",
  ) // ms.34.2|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 4, 30, 12, 0, 0), true),
    "OK:false",
  ) // ms.34.3|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 6, 15, 12, 0, 0), true),
    "OK:false",
  ) // ms.34.4|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 6, 14, 12, 0, 0), true),
    "OK:false",
  ) // ms.34.5|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 6, 1, 0, 0, 0), true),
    "OK:false",
  ) // ms.34.6|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 1, 1, 0, 0, 0), true),
    "OK:false",
  ) // ms.34.7|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 6, 17, 9, 15, 0), true),
    "OK:false",
  ) // ms.34.8|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 6, 17, 9, 15, 30), true),
    "OK:false",
  ) // ms.34.9|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2099, 12, 31, 12, 0, 0), true),
    "OK:false",
  ) // ms.34.10|OK:false
  assert_eq(
    m_tag("0 0 12 * * ? 1970", dt(2024, 2, 29, 0, 0, 0), true),
    "OK:false",
  ) // ms.34.11|OK:false
  assert_eq(m_tag("* * * * * * *", dt(2024, 2, 29, 12, 0, 0), true), "OK:true") // ms.41.0|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2023, 2, 28, 23, 59, 0), true), "OK:true") // ms.41.1|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 3, 31, 12, 0, 0), true), "OK:true") // ms.41.2|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 4, 30, 12, 0, 0), true), "OK:true") // ms.41.3|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 6, 15, 12, 0, 0), true), "OK:true") // ms.41.4|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 6, 14, 12, 0, 0), true), "OK:true") // ms.41.5|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 6, 1, 0, 0, 0), true), "OK:true") // ms.41.6|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 1, 1, 0, 0, 0), true), "OK:true") // ms.41.7|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 6, 17, 9, 15, 0), true), "OK:true") // ms.41.8|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 6, 17, 9, 15, 30), true), "OK:true") // ms.41.9|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2099, 12, 31, 12, 0, 0), true), "OK:true") // ms.41.10|OK:true
  assert_eq(m_tag("* * * * * * *", dt(2024, 2, 29, 0, 0, 0), true), "OK:true") // ms.41.11|OK:true
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 2, 29, 12, 0, 0), true), "OK:false") // ms.49.0|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2023, 2, 28, 23, 59, 0), true), "OK:false") // ms.49.1|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 3, 31, 12, 0, 0), true), "OK:false") // ms.49.2|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 4, 30, 12, 0, 0), true), "OK:true") // ms.49.3|OK:true
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 6, 15, 12, 0, 0), true), "OK:false") // ms.49.4|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 6, 14, 12, 0, 0), true), "OK:false") // ms.49.5|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 6, 1, 0, 0, 0), true), "OK:false") // ms.49.6|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 1, 1, 0, 0, 0), true), "OK:false") // ms.49.7|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 6, 17, 9, 15, 0), true), "OK:false") // ms.49.8|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 6, 17, 9, 15, 30), true), "OK:false") // ms.49.9|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2099, 12, 31, 12, 0, 0), true), "OK:false") // ms.49.10|OK:false
  assert_eq(m_tag("0 12 31 4 *", dt(2024, 2, 29, 0, 0, 0), true), "OK:false") // ms.49.11|OK:false
}

///|
test "cron next_match_after：已匹配先加一秒" {
  assert_eq(
    nx_tag("* * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:01:00",
  ) // nx.0.0|OK:2024-02-29 12:01:00
  assert_eq(
    nx_tag("* * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:01:00",
  ) // nx.0.1|OK:2024-06-14 12:01:00
  assert_eq(
    nx_tag("* * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nx.0.2|OK:2025-01-01 00:00:00
  assert_eq(
    nx_tag("* * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:01:00",
  ) // nx.0.3|OK:2024-01-01 00:01:00
  assert_eq(
    nx_tag("* * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:16:00",
  ) // nx.0.4|OK:2024-06-17 09:16:00
  assert_eq(
    nx_tag("* * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:01:00",
  ) // nx.0.5|OK:2099-12-30 12:01:00
  assert_eq(
    nx_tag("5 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:05:00",
  ) // nx.1.0|OK:2024-02-29 12:05:00
  assert_eq(
    nx_tag("5 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:05:00",
  ) // nx.1.1|OK:2024-06-14 12:05:00
  assert_eq(
    nx_tag("5 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:05:00",
  ) // nx.1.2|OK:2025-01-01 00:05:00
  assert_eq(
    nx_tag("5 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:05:00",
  ) // nx.1.3|OK:2024-01-01 00:05:00
  assert_eq(
    nx_tag("5 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 10:05:00",
  ) // nx.1.4|OK:2024-06-17 10:05:00
  assert_eq(
    nx_tag("5 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:05:00",
  ) // nx.1.5|OK:2099-12-30 12:05:00
  assert_eq(
    nx_tag("*/2 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:02:00",
  ) // nx.2.0|OK:2024-02-29 12:02:00
  assert_eq(
    nx_tag("*/2 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:02:00",
  ) // nx.2.1|OK:2024-06-14 12:02:00
  assert_eq(
    nx_tag("*/2 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nx.2.2|OK:2025-01-01 00:00:00
  assert_eq(
    nx_tag("*/2 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:02:00",
  ) // nx.2.3|OK:2024-01-01 00:02:00
  assert_eq(
    nx_tag("*/2 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:16:00",
  ) // nx.2.4|OK:2024-06-17 09:16:00
  assert_eq(
    nx_tag("*/2 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:02:00",
  ) // nx.2.5|OK:2099-12-30 12:02:00
  assert_eq(
    nx_tag("2-8 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:02:00",
  ) // nx.3.0|OK:2024-02-29 12:02:00
  assert_eq(
    nx_tag("2-8 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:02:00",
  ) // nx.3.1|OK:2024-06-14 12:02:00
  assert_eq(
    nx_tag("2-8 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:02:00",
  ) // nx.3.2|OK:2025-01-01 00:02:00
  assert_eq(
    nx_tag("2-8 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:02:00",
  ) // nx.3.3|OK:2024-01-01 00:02:00
  assert_eq(
    nx_tag("2-8 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 10:02:00",
  ) // nx.3.4|OK:2024-06-17 10:02:00
  assert_eq(
    nx_tag("2-8 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:02:00",
  ) // nx.3.5|OK:2099-12-30 12:02:00
  assert_eq(
    nx_tag("2,3,5,8 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:02:00",
  ) // nx.4.0|OK:2024-02-29 12:02:00
  assert_eq(
    nx_tag("2,3,5,8 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:02:00",
  ) // nx.4.1|OK:2024-06-14 12:02:00
  assert_eq(
    nx_tag("2,3,5,8 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:02:00",
  ) // nx.4.2|OK:2025-01-01 00:02:00
  assert_eq(
    nx_tag("2,3,5,8 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:02:00",
  ) // nx.4.3|OK:2024-01-01 00:02:00
  assert_eq(
    nx_tag("2,3,5,8 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 10:02:00",
  ) // nx.4.4|OK:2024-06-17 10:02:00
  assert_eq(
    nx_tag("2,3,5,8 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:02:00",
  ) // nx.4.5|OK:2099-12-30 12:02:00
  assert_eq(
    nx_tag("2,3,6/3 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:02:00",
  ) // nx.5.0|OK:2024-02-29 12:02:00
  assert_eq(
    nx_tag("2,3,6/3 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:02:00",
  ) // nx.5.1|OK:2024-06-14 12:02:00
  assert_eq(
    nx_tag("2,3,6/3 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:02:00",
  ) // nx.5.2|OK:2025-01-01 00:02:00
  assert_eq(
    nx_tag("2,3,6/3 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:02:00",
  ) // nx.5.3|OK:2024-01-01 00:02:00
  assert_eq(
    nx_tag("2,3,6/3 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:18:00",
  ) // nx.5.4|OK:2024-06-17 09:18:00
  assert_eq(
    nx_tag("2,3,6/3 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:02:00",
  ) // nx.5.5|OK:2099-12-30 12:02:00
  assert_eq(
    nx_tag("? * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:01:00",
  ) // nx.6.0|OK:2024-02-29 12:01:00
  assert_eq(
    nx_tag("? * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:01:00",
  ) // nx.6.1|OK:2024-06-14 12:01:00
  assert_eq(
    nx_tag("? * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nx.6.2|OK:2025-01-01 00:00:00
  assert_eq(
    nx_tag("? * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:01:00",
  ) // nx.6.3|OK:2024-01-01 00:01:00
  assert_eq(
    nx_tag("? * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:16:00",
  ) // nx.6.4|OK:2024-06-17 09:16:00
  assert_eq(
    nx_tag("? * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:01:00",
  ) // nx.6.5|OK:2099-12-30 12:01:00
  assert_eq(
    nx_tag("0 12 * * MON", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-04 12:00:00",
  ) // nx.7.0|OK:2024-03-04 12:00:00
  assert_eq(
    nx_tag("0 12 * * MON", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-17 12:00:00",
  ) // nx.7.1|OK:2024-06-17 12:00:00
  assert_eq(
    nx_tag("0 12 * * MON", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-06 12:00:00",
  ) // nx.7.2|OK:2025-01-06 12:00:00
  assert_eq(
    nx_tag("0 12 * * MON", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:00:00",
  ) // nx.7.3|OK:2024-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * * MON", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 12:00:00",
  ) // nx.7.4|OK:2024-06-17 12:00:00
  assert_eq(
    nx_tag("0 12 * * MON", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-04 12:00:00",
  ) // nx.7.5|OK:2100-01-04 12:00:00
  assert_eq(
    nx_tag("0 12 * * mon", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-04 12:00:00",
  ) // nx.8.0|OK:2024-03-04 12:00:00
  assert_eq(
    nx_tag("0 12 * * mon", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-17 12:00:00",
  ) // nx.8.1|OK:2024-06-17 12:00:00
  assert_eq(
    nx_tag("0 12 * * mon", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-06 12:00:00",
  ) // nx.8.2|OK:2025-01-06 12:00:00
  assert_eq(
    nx_tag("0 12 * * mon", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:00:00",
  ) // nx.8.3|OK:2024-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * * mon", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 12:00:00",
  ) // nx.8.4|OK:2024-06-17 12:00:00
  assert_eq(
    nx_tag("0 12 * * mon", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-04 12:00:00",
  ) // nx.8.5|OK:2100-01-04 12:00:00
  assert_eq(
    nx_tag("0 12 * JAN-MAR *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-01 12:00:00",
  ) // nx.9.0|OK:2024-03-01 12:00:00
  assert_eq(
    nx_tag("0 12 * JAN-MAR *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2025-01-01 12:00:00",
  ) // nx.9.1|OK:2025-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * JAN-MAR *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 12:00:00",
  ) // nx.9.2|OK:2025-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * JAN-MAR *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:00:00",
  ) // nx.9.3|OK:2024-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * JAN-MAR *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2025-01-01 12:00:00",
  ) // nx.9.4|OK:2025-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * JAN-MAR *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-01 12:00:00",
  ) // nx.9.5|OK:2100-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * jan-mar *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-01 12:00:00",
  ) // nx.10.0|OK:2024-03-01 12:00:00
  assert_eq(
    nx_tag("0 12 * jan-mar *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2025-01-01 12:00:00",
  ) // nx.10.1|OK:2025-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * jan-mar *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 12:00:00",
  ) // nx.10.2|OK:2025-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * jan-mar *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:00:00",
  ) // nx.10.3|OK:2024-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * jan-mar *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2025-01-01 12:00:00",
  ) // nx.10.4|OK:2025-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * jan-mar *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-01 12:00:00",
  ) // nx.10.5|OK:2100-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 L * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-31 12:00:00",
  ) // nx.11.0|OK:2024-03-31 12:00:00
  assert_eq(
    nx_tag("0 12 L * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-30 12:00:00",
  ) // nx.11.1|OK:2024-06-30 12:00:00
  assert_eq(
    nx_tag("0 12 L * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-31 12:00:00",
  ) // nx.11.2|OK:2025-01-31 12:00:00
  assert_eq(
    nx_tag("0 12 L * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-31 12:00:00",
  ) // nx.11.3|OK:2024-01-31 12:00:00
  assert_eq(
    nx_tag("0 12 L * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-30 12:00:00",
  ) // nx.11.4|OK:2024-06-30 12:00:00
  assert_eq(
    nx_tag("0 12 L * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-31 12:00:00",
  ) // nx.11.5|OK:2099-12-31 12:00:00
  assert_eq(
    nx_tag("0 12 * * 7", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-03 12:00:00",
  ) // nx.17.0|OK:2024-03-03 12:00:00
  assert_eq(
    nx_tag("0 12 * * 7", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-16 12:00:00",
  ) // nx.17.1|OK:2024-06-16 12:00:00
  assert_eq(
    nx_tag("0 12 * * 7", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-05 12:00:00",
  ) // nx.17.2|OK:2025-01-05 12:00:00
  assert_eq(
    nx_tag("0 12 * * 7", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-07 12:00:00",
  ) // nx.17.3|OK:2024-01-07 12:00:00
  assert_eq(
    nx_tag("0 12 * * 7", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-23 12:00:00",
  ) // nx.17.4|OK:2024-06-23 12:00:00
  assert_eq(
    nx_tag("0 12 * * 7", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-03 12:00:00",
  ) // nx.17.5|OK:2100-01-03 12:00:00
  assert_eq(
    nx_tag("0 12 * * 0", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-03 12:00:00",
  ) // nx.18.0|OK:2024-03-03 12:00:00
  assert_eq(
    nx_tag("0 12 * * 0", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-16 12:00:00",
  ) // nx.18.1|OK:2024-06-16 12:00:00
  assert_eq(
    nx_tag("0 12 * * 0", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-05 12:00:00",
  ) // nx.18.2|OK:2025-01-05 12:00:00
  assert_eq(
    nx_tag("0 12 * * 0", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-07 12:00:00",
  ) // nx.18.3|OK:2024-01-07 12:00:00
  assert_eq(
    nx_tag("0 12 * * 0", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-23 12:00:00",
  ) // nx.18.4|OK:2024-06-23 12:00:00
  assert_eq(
    nx_tag("0 12 * * 0", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-03 12:00:00",
  ) // nx.18.5|OK:2100-01-03 12:00:00
  assert_eq(
    nx_tag("0 12 1 * MON", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-04-01 12:00:00",
  ) // nx.19.0|OK:2024-04-01 12:00:00
  assert_eq(
    nx_tag("0 12 1 * MON", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-07-01 12:00:00",
  ) // nx.19.1|OK:2024-07-01 12:00:00
  assert_eq(
    nx_tag("0 12 1 * MON", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-09-01 12:00:00",
  ) // nx.19.2|OK:2025-09-01 12:00:00
  assert_eq(
    nx_tag("0 12 1 * MON", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:00:00",
  ) // nx.19.3|OK:2024-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 1 * MON", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-07-01 12:00:00",
  ) // nx.19.4|OK:2024-07-01 12:00:00
  assert_eq(
    nx_tag("0 12 1 * MON", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-02-01 12:00:00",
  ) // nx.19.5|OK:2100-02-01 12:00:00
  assert_eq(
    nx_tag("0 12 * * SAT,SUN", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-02 12:00:00",
  ) // nx.20.0|OK:2024-03-02 12:00:00
  assert_eq(
    nx_tag("0 12 * * SAT,SUN", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-15 12:00:00",
  ) // nx.20.1|OK:2024-06-15 12:00:00
  assert_eq(
    nx_tag("0 12 * * SAT,SUN", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-04 12:00:00",
  ) // nx.20.2|OK:2025-01-04 12:00:00
  assert_eq(
    nx_tag("0 12 * * SAT,SUN", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-06 12:00:00",
  ) // nx.20.3|OK:2024-01-06 12:00:00
  assert_eq(
    nx_tag("0 12 * * SAT,SUN", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-22 12:00:00",
  ) // nx.20.4|OK:2024-06-22 12:00:00
  assert_eq(
    nx_tag("0 12 * * SAT,SUN", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-02 12:00:00",
  ) // nx.20.5|OK:2100-01-02 12:00:00
  assert_eq(
    nx_tag("*/15 9-17 * * MON-FRI", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:15:00",
  ) // nx.21.0|OK:2024-02-29 12:15:00
  assert_eq(
    nx_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:15:00",
  ) // nx.21.1|OK:2024-06-14 12:15:00
  assert_eq(
    nx_tag("*/15 9-17 * * MON-FRI", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 09:00:00",
  ) // nx.21.2|OK:2025-01-01 09:00:00
  assert_eq(
    nx_tag("*/15 9-17 * * MON-FRI", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 09:00:00",
  ) // nx.21.3|OK:2024-01-01 09:00:00
  assert_eq(
    nx_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:30:00",
  ) // nx.21.4|OK:2024-06-17 09:30:00
  assert_eq(
    nx_tag("*/15 9-17 * * MON-FRI", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:15:00",
  ) // nx.21.5|OK:2099-12-30 12:15:00
  assert_eq(
    nx_tag("0 0 * * SUN", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-03 00:00:00",
  ) // nx.22.0|OK:2024-03-03 00:00:00
  assert_eq(
    nx_tag("0 0 * * SUN", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-16 00:00:00",
  ) // nx.22.1|OK:2024-06-16 00:00:00
  assert_eq(
    nx_tag("0 0 * * SUN", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-05 00:00:00",
  ) // nx.22.2|OK:2025-01-05 00:00:00
  assert_eq(
    nx_tag("0 0 * * SUN", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-07 00:00:00",
  ) // nx.22.3|OK:2024-01-07 00:00:00
  assert_eq(
    nx_tag("0 0 * * SUN", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-23 00:00:00",
  ) // nx.22.4|OK:2024-06-23 00:00:00
  assert_eq(
    nx_tag("0 0 * * SUN", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-03 00:00:00",
  ) // nx.22.5|OK:2100-01-03 00:00:00
  assert_eq(
    nx_tag("0 0 1 1 *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nx.23.0|OK:2025-01-01 00:00:00
  assert_eq(
    nx_tag("0 0 1 1 *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nx.23.1|OK:2025-01-01 00:00:00
  assert_eq(
    nx_tag("0 0 1 1 *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nx.23.2|OK:2025-01-01 00:00:00
  assert_eq(
    nx_tag("0 0 1 1 *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nx.23.3|OK:2025-01-01 00:00:00
  assert_eq(
    nx_tag("0 0 1 1 *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2025-01-01 00:00:00",
  ) // nx.23.4|OK:2025-01-01 00:00:00
  assert_eq(
    nx_tag("0 0 1 1 *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-01 00:00:00",
  ) // nx.23.5|OK:2100-01-01 00:00:00
  assert_eq(
    nx_tag("0 0 29 2 *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2028-02-29 00:00:00",
  ) // nx.24.0|OK:2028-02-29 00:00:00
  assert_eq(
    nx_tag("0 0 29 2 *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2028-02-29 00:00:00",
  ) // nx.24.1|OK:2028-02-29 00:00:00
  assert_eq(
    nx_tag("0 0 29 2 *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2028-02-29 00:00:00",
  ) // nx.24.2|OK:2028-02-29 00:00:00
  assert_eq(
    nx_tag("0 0 29 2 *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-02-29 00:00:00",
  ) // nx.24.3|OK:2024-02-29 00:00:00
  assert_eq(
    nx_tag("0 0 29 2 *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2028-02-29 00:00:00",
  ) // nx.24.4|OK:2028-02-29 00:00:00
  assert_eq(
    nx_tag("0 0 29 2 *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2104-02-29 00:00:00",
  ) // nx.24.5|OK:2104-02-29 00:00:00
  assert_eq(
    nx_tag("0 12 */3 * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-31 12:00:00",
  ) // nx.25.0|OK:2024-03-31 12:00:00
  assert_eq(
    nx_tag("0 12 */3 * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-30 12:00:00",
  ) // nx.25.1|OK:2024-06-30 12:00:00
  assert_eq(
    nx_tag("0 12 */3 * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-31 12:00:00",
  ) // nx.25.2|OK:2025-01-31 12:00:00
  assert_eq(
    nx_tag("0 12 */3 * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-31 12:00:00",
  ) // nx.25.3|OK:2024-01-31 12:00:00
  assert_eq(
    nx_tag("0 12 */3 * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-30 12:00:00",
  ) // nx.25.4|OK:2024-06-30 12:00:00
  assert_eq(
    nx_tag("0 12 */3 * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-31 12:00:00",
  ) // nx.25.5|OK:2099-12-31 12:00:00
  assert_eq(
    nx_tag("30 6 * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-01 06:30:00",
  ) // nx.26.0|OK:2024-03-01 06:30:00
  assert_eq(
    nx_tag("30 6 * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-15 06:30:00",
  ) // nx.26.1|OK:2024-06-15 06:30:00
  assert_eq(
    nx_tag("30 6 * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 06:30:00",
  ) // nx.26.2|OK:2025-01-01 06:30:00
  assert_eq(
    nx_tag("30 6 * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 06:30:00",
  ) // nx.26.3|OK:2024-01-01 06:30:00
  assert_eq(
    nx_tag("30 6 * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-18 06:30:00",
  ) // nx.26.4|OK:2024-06-18 06:30:00
  assert_eq(
    nx_tag("30 6 * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-31 06:30:00",
  ) // nx.26.5|OK:2099-12-31 06:30:00
  assert_eq(
    nx_tag("0-59/13 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:13:00",
  ) // nx.27.0|OK:2024-02-29 12:13:00
  assert_eq(
    nx_tag("0-59/13 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:13:00",
  ) // nx.27.1|OK:2024-06-14 12:13:00
  assert_eq(
    nx_tag("0-59/13 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nx.27.2|OK:2025-01-01 00:00:00
  assert_eq(
    nx_tag("0-59/13 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:13:00",
  ) // nx.27.3|OK:2024-01-01 00:13:00
  assert_eq(
    nx_tag("0-59/13 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:26:00",
  ) // nx.27.4|OK:2024-06-17 09:26:00
  assert_eq(
    nx_tag("0-59/13 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:13:00",
  ) // nx.27.5|OK:2099-12-30 12:13:00
  assert_eq(
    nx_tag("*/7 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:07:00",
  ) // nx.28.0|OK:2024-02-29 12:07:00
  assert_eq(
    nx_tag("*/7 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:07:00",
  ) // nx.28.1|OK:2024-06-14 12:07:00
  assert_eq(
    nx_tag("*/7 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nx.28.2|OK:2025-01-01 00:00:00
  assert_eq(
    nx_tag("*/7 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:07:00",
  ) // nx.28.3|OK:2024-01-01 00:07:00
  assert_eq(
    nx_tag("*/7 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:21:00",
  ) // nx.28.4|OK:2024-06-17 09:21:00
  assert_eq(
    nx_tag("*/7 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:07:00",
  ) // nx.28.5|OK:2099-12-30 12:07:00
  assert_eq(
    nx_tag("1,1,1 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:01:00",
  ) // nx.29.0|OK:2024-02-29 12:01:00
  assert_eq(
    nx_tag("1,1,1 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:01:00",
  ) // nx.29.1|OK:2024-06-14 12:01:00
  assert_eq(
    nx_tag("1,1,1 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:01:00",
  ) // nx.29.2|OK:2025-01-01 00:01:00
  assert_eq(
    nx_tag("1,1,1 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:01:00",
  ) // nx.29.3|OK:2024-01-01 00:01:00
  assert_eq(
    nx_tag("1,1,1 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 10:01:00",
  ) // nx.29.4|OK:2024-06-17 10:01:00
  assert_eq(
    nx_tag("1,1,1 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:01:00",
  ) // nx.29.5|OK:2099-12-30 12:01:00
  assert_eq(
    nx_tag("5-1,7 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:01:00",
  ) // nx.30.0|OK:2024-02-29 12:01:00
  assert_eq(
    nx_tag("5-1,7 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:01:00",
  ) // nx.30.1|OK:2024-06-14 12:01:00
  assert_eq(
    nx_tag("5-1,7 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nx.30.2|OK:2025-01-01 00:00:00
  assert_eq(
    nx_tag("5-1,7 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:01:00",
  ) // nx.30.3|OK:2024-01-01 00:01:00
  assert_eq(
    nx_tag("5-1,7 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:16:00",
  ) // nx.30.4|OK:2024-06-17 09:16:00
  assert_eq(
    nx_tag("5-1,7 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:01:00",
  ) // nx.30.5|OK:2099-12-30 12:01:00
  assert_eq(
    nx_tag("8-2 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:01:00",
  ) // nx.31.0|OK:2024-02-29 12:01:00
  assert_eq(
    nx_tag("8-2 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:01:00",
  ) // nx.31.1|OK:2024-06-14 12:01:00
  assert_eq(
    nx_tag("8-2 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nx.31.2|OK:2025-01-01 00:00:00
  assert_eq(
    nx_tag("8-2 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:01:00",
  ) // nx.31.3|OK:2024-01-01 00:01:00
  assert_eq(
    nx_tag("8-2 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:16:00",
  ) // nx.31.4|OK:2024-06-17 09:16:00
  assert_eq(
    nx_tag("8-2 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:01:00",
  ) // nx.31.5|OK:2099-12-30 12:01:00
  assert_eq(
    nx_tag("59 59 12 * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:59:59",
  ) // nx.32.0|OK:2024-02-29 12:59:59
  assert_eq(
    nx_tag("59 59 12 * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:59:59",
  ) // nx.32.1|OK:2024-06-14 12:59:59
  assert_eq(
    nx_tag("59 59 12 * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 12:59:59",
  ) // nx.32.2|OK:2025-01-01 12:59:59
  assert_eq(
    nx_tag("59 59 12 * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:59:59",
  ) // nx.32.3|OK:2024-01-01 12:59:59
  assert_eq(
    nx_tag("59 59 12 * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 12:59:59",
  ) // nx.32.4|OK:2024-06-17 12:59:59
  assert_eq(
    nx_tag("59 59 12 * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:59:59",
  ) // nx.32.5|OK:2099-12-30 12:59:59
  assert_eq(
    nx_tag("0 0 12 * * ? 2099", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2099-01-01 12:00:00",
  ) // nx.33.0|OK:2099-01-01 12:00:00
  assert_eq(
    nx_tag("0 0 12 * * ? 2099", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2099-01-01 12:00:00",
  ) // nx.33.1|OK:2099-01-01 12:00:00
  assert_eq(
    nx_tag("0 0 12 * * ? 2099", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2099-01-01 12:00:00",
  ) // nx.33.2|OK:2099-01-01 12:00:00
  assert_eq(
    nx_tag("0 0 12 * * ? 2099", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2099-01-01 12:00:00",
  ) // nx.33.3|OK:2099-01-01 12:00:00
  assert_eq(
    nx_tag("0 0 12 * * ? 2099", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2099-01-01 12:00:00",
  ) // nx.33.4|OK:2099-01-01 12:00:00
  assert_eq(
    nx_tag("0 0 12 * * ? 2099", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-31 12:00:00",
  ) // nx.33.5|OK:2099-12-31 12:00:00
  assert_eq(
    nx_tag("0 0 12 * * ? 1970", dt(2024, 2, 29, 12, 0, 0)),
    "IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher",
  ) // nx.34.0|IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher
  assert_eq(
    nx_tag("0 0 12 * * ? 1970", dt(2024, 6, 14, 12, 0, 0)),
    "IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher",
  ) // nx.34.1|IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher
  assert_eq(
    nx_tag("0 0 12 * * ? 1970", dt(2024, 3, 31, 12, 0, 0)),
    "IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher",
  ) // nx.34.2|IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher
  assert_eq(
    nx_tag("0 0 12 * * ? 1970", dt(2024, 1, 1, 0, 0, 0)),
    "IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher",
  ) // nx.34.3|IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher
  assert_eq(
    nx_tag("0 0 12 * * ? 1970", dt(2024, 6, 17, 9, 15, 30)),
    "IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher",
  ) // nx.34.4|IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher
  assert_eq(
    nx_tag("0 0 12 * * ? 1970", dt(2099, 12, 30, 12, 0, 0)),
    "IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher",
  ) // nx.34.5|IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher
  assert_eq(
    nx_tag("* * * * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:01",
  ) // nx.41.0|OK:2024-02-29 12:00:01
  assert_eq(
    nx_tag("* * * * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:00:01",
  ) // nx.41.1|OK:2024-06-14 12:00:01
  assert_eq(
    nx_tag("* * * * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2024-12-31 23:59:01",
  ) // nx.41.2|OK:2024-12-31 23:59:01
  assert_eq(
    nx_tag("* * * * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:00:01",
  ) // nx.41.3|OK:2024-01-01 00:00:01
  assert_eq(
    nx_tag("* * * * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:15:31",
  ) // nx.41.4|OK:2024-06-17 09:15:31
  assert_eq(
    nx_tag("* * * * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:00:01",
  ) // nx.41.5|OK:2099-12-30 12:00:01
  assert_eq(
    nx_tag("0 12 * * 1-7", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-01 12:00:00",
  ) // nx.44.0|OK:2024-03-01 12:00:00
  assert_eq(
    nx_tag("0 12 * * 1-7", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-15 12:00:00",
  ) // nx.44.1|OK:2024-06-15 12:00:00
  assert_eq(
    nx_tag("0 12 * * 1-7", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 12:00:00",
  ) // nx.44.2|OK:2025-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * * 1-7", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:00:00",
  ) // nx.44.3|OK:2024-01-01 12:00:00
  assert_eq(
    nx_tag("0 12 * * 1-7", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 12:00:00",
  ) // nx.44.4|OK:2024-06-17 12:00:00
  assert_eq(
    nx_tag("0 12 * * 1-7", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-31 12:00:00",
  ) // nx.44.5|OK:2099-12-31 12:00:00
  assert_eq(
    nx_tag("0 12 * * 0-7", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-03 12:00:00",
  ) // nx.45.0|OK:2024-03-03 12:00:00
  assert_eq(
    nx_tag("0 12 * * 0-7", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-16 12:00:00",
  ) // nx.45.1|OK:2024-06-16 12:00:00
  assert_eq(
    nx_tag("0 12 * * 0-7", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-05 12:00:00",
  ) // nx.45.2|OK:2025-01-05 12:00:00
  assert_eq(
    nx_tag("0 12 * * 0-7", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-07 12:00:00",
  ) // nx.45.3|OK:2024-01-07 12:00:00
  assert_eq(
    nx_tag("0 12 * * 0-7", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-23 12:00:00",
  ) // nx.45.4|OK:2024-06-23 12:00:00
  assert_eq(
    nx_tag("0 12 * * 0-7", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-03 12:00:00",
  ) // nx.45.5|OK:2100-01-03 12:00:00
  assert_eq(
    nx_tag("0 12 31 4 *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-04-30 12:00:00",
  ) // nx.49.0|OK:2024-04-30 12:00:00
  assert_eq(
    nx_tag("0 12 31 4 *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2025-04-30 12:00:00",
  ) // nx.49.1|OK:2025-04-30 12:00:00
  assert_eq(
    nx_tag("0 12 31 4 *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-04-30 12:00:00",
  ) // nx.49.2|OK:2025-04-30 12:00:00
  assert_eq(
    nx_tag("0 12 31 4 *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-04-30 12:00:00",
  ) // nx.49.3|OK:2024-04-30 12:00:00
  assert_eq(
    nx_tag("0 12 31 4 *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2025-04-30 12:00:00",
  ) // nx.49.4|OK:2025-04-30 12:00:00
  assert_eq(
    nx_tag("0 12 31 4 *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-04-30 12:00:00",
  ) // nx.49.5|OK:2100-04-30 12:00:00
}

///|
test "cron next_match：已匹配就返回自身（与上一块成对）" {
  assert_eq(
    nm_tag("* * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.0.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("* * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:00:00",
  ) // nm.0.1|OK:2024-06-14 12:00:00
  assert_eq(
    nm_tag("* * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2024-12-31 23:59:00",
  ) // nm.0.2|OK:2024-12-31 23:59:00
  assert_eq(
    nm_tag("* * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:00:00",
  ) // nm.0.3|OK:2024-01-01 00:00:00
  assert_eq(
    nm_tag("* * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:16:00",
  ) // nm.0.4|OK:2024-06-17 09:16:00
  assert_eq(
    nm_tag("* * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:00:00",
  ) // nm.0.5|OK:2099-12-30 12:00:00
  assert_eq(
    nm_tag("5 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:05:00",
  ) // nm.1.0|OK:2024-02-29 12:05:00
  assert_eq(
    nm_tag("5 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:05:00",
  ) // nm.1.1|OK:2024-06-14 12:05:00
  assert_eq(
    nm_tag("5 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:05:00",
  ) // nm.1.2|OK:2025-01-01 00:05:00
  assert_eq(
    nm_tag("5 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:05:00",
  ) // nm.1.3|OK:2024-01-01 00:05:00
  assert_eq(
    nm_tag("5 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 10:05:00",
  ) // nm.1.4|OK:2024-06-17 10:05:00
  assert_eq(
    nm_tag("5 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:05:00",
  ) // nm.1.5|OK:2099-12-30 12:05:00
  assert_eq(
    nm_tag("*/2 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.2.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("*/2 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:00:00",
  ) // nm.2.1|OK:2024-06-14 12:00:00
  assert_eq(
    nm_tag("*/2 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nm.2.2|OK:2025-01-01 00:00:00
  assert_eq(
    nm_tag("*/2 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:00:00",
  ) // nm.2.3|OK:2024-01-01 00:00:00
  assert_eq(
    nm_tag("*/2 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:16:00",
  ) // nm.2.4|OK:2024-06-17 09:16:00
  assert_eq(
    nm_tag("*/2 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:00:00",
  ) // nm.2.5|OK:2099-12-30 12:00:00
  assert_eq(
    nm_tag("2-8 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:02:00",
  ) // nm.3.0|OK:2024-02-29 12:02:00
  assert_eq(
    nm_tag("2-8 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:02:00",
  ) // nm.3.1|OK:2024-06-14 12:02:00
  assert_eq(
    nm_tag("2-8 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:02:00",
  ) // nm.3.2|OK:2025-01-01 00:02:00
  assert_eq(
    nm_tag("2-8 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:02:00",
  ) // nm.3.3|OK:2024-01-01 00:02:00
  assert_eq(
    nm_tag("2-8 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 10:02:00",
  ) // nm.3.4|OK:2024-06-17 10:02:00
  assert_eq(
    nm_tag("2-8 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:02:00",
  ) // nm.3.5|OK:2099-12-30 12:02:00
  assert_eq(
    nm_tag("2,3,5,8 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:02:00",
  ) // nm.4.0|OK:2024-02-29 12:02:00
  assert_eq(
    nm_tag("2,3,5,8 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:02:00",
  ) // nm.4.1|OK:2024-06-14 12:02:00
  assert_eq(
    nm_tag("2,3,5,8 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:02:00",
  ) // nm.4.2|OK:2025-01-01 00:02:00
  assert_eq(
    nm_tag("2,3,5,8 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:02:00",
  ) // nm.4.3|OK:2024-01-01 00:02:00
  assert_eq(
    nm_tag("2,3,5,8 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 10:02:00",
  ) // nm.4.4|OK:2024-06-17 10:02:00
  assert_eq(
    nm_tag("2,3,5,8 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:02:00",
  ) // nm.4.5|OK:2099-12-30 12:02:00
  assert_eq(
    nm_tag("2,3,6/3 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:02:00",
  ) // nm.5.0|OK:2024-02-29 12:02:00
  assert_eq(
    nm_tag("2,3,6/3 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:02:00",
  ) // nm.5.1|OK:2024-06-14 12:02:00
  assert_eq(
    nm_tag("2,3,6/3 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:02:00",
  ) // nm.5.2|OK:2025-01-01 00:02:00
  assert_eq(
    nm_tag("2,3,6/3 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:02:00",
  ) // nm.5.3|OK:2024-01-01 00:02:00
  assert_eq(
    nm_tag("2,3,6/3 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:18:00",
  ) // nm.5.4|OK:2024-06-17 09:18:00
  assert_eq(
    nm_tag("2,3,6/3 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:02:00",
  ) // nm.5.5|OK:2099-12-30 12:02:00
  assert_eq(
    nm_tag("? * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.6.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("? * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:00:00",
  ) // nm.6.1|OK:2024-06-14 12:00:00
  assert_eq(
    nm_tag("? * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2024-12-31 23:59:00",
  ) // nm.6.2|OK:2024-12-31 23:59:00
  assert_eq(
    nm_tag("? * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:00:00",
  ) // nm.6.3|OK:2024-01-01 00:00:00
  assert_eq(
    nm_tag("? * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:16:00",
  ) // nm.6.4|OK:2024-06-17 09:16:00
  assert_eq(
    nm_tag("? * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:00:00",
  ) // nm.6.5|OK:2099-12-30 12:00:00
  assert_eq(
    nm_tag("0 12 * * MON", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-04 12:00:00",
  ) // nm.7.0|OK:2024-03-04 12:00:00
  assert_eq(
    nm_tag("0 12 * * MON", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-17 12:00:00",
  ) // nm.7.1|OK:2024-06-17 12:00:00
  assert_eq(
    nm_tag("0 12 * * MON", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-06 12:00:00",
  ) // nm.7.2|OK:2025-01-06 12:00:00
  assert_eq(
    nm_tag("0 12 * * MON", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:00:00",
  ) // nm.7.3|OK:2024-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * * MON", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 12:00:00",
  ) // nm.7.4|OK:2024-06-17 12:00:00
  assert_eq(
    nm_tag("0 12 * * MON", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-04 12:00:00",
  ) // nm.7.5|OK:2100-01-04 12:00:00
  assert_eq(
    nm_tag("0 12 * * mon", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-04 12:00:00",
  ) // nm.8.0|OK:2024-03-04 12:00:00
  assert_eq(
    nm_tag("0 12 * * mon", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-17 12:00:00",
  ) // nm.8.1|OK:2024-06-17 12:00:00
  assert_eq(
    nm_tag("0 12 * * mon", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-06 12:00:00",
  ) // nm.8.2|OK:2025-01-06 12:00:00
  assert_eq(
    nm_tag("0 12 * * mon", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:00:00",
  ) // nm.8.3|OK:2024-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * * mon", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 12:00:00",
  ) // nm.8.4|OK:2024-06-17 12:00:00
  assert_eq(
    nm_tag("0 12 * * mon", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-04 12:00:00",
  ) // nm.8.5|OK:2100-01-04 12:00:00
  assert_eq(
    nm_tag("0 12 * JAN-MAR *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.9.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("0 12 * JAN-MAR *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2025-01-01 12:00:00",
  ) // nm.9.1|OK:2025-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * JAN-MAR *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 12:00:00",
  ) // nm.9.2|OK:2025-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * JAN-MAR *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:00:00",
  ) // nm.9.3|OK:2024-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * JAN-MAR *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2025-01-01 12:00:00",
  ) // nm.9.4|OK:2025-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * JAN-MAR *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-01 12:00:00",
  ) // nm.9.5|OK:2100-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * jan-mar *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.10.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("0 12 * jan-mar *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2025-01-01 12:00:00",
  ) // nm.10.1|OK:2025-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * jan-mar *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 12:00:00",
  ) // nm.10.2|OK:2025-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * jan-mar *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:00:00",
  ) // nm.10.3|OK:2024-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * jan-mar *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2025-01-01 12:00:00",
  ) // nm.10.4|OK:2025-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * jan-mar *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-01 12:00:00",
  ) // nm.10.5|OK:2100-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 L * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.11.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("0 12 L * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-30 12:00:00",
  ) // nm.11.1|OK:2024-06-30 12:00:00
  assert_eq(
    nm_tag("0 12 L * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-31 12:00:00",
  ) // nm.11.2|OK:2025-01-31 12:00:00
  assert_eq(
    nm_tag("0 12 L * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-31 12:00:00",
  ) // nm.11.3|OK:2024-01-31 12:00:00
  assert_eq(
    nm_tag("0 12 L * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-30 12:00:00",
  ) // nm.11.4|OK:2024-06-30 12:00:00
  assert_eq(
    nm_tag("0 12 L * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-31 12:00:00",
  ) // nm.11.5|OK:2099-12-31 12:00:00
  assert_eq(
    nm_tag("0 12 * * 7", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-03 12:00:00",
  ) // nm.17.0|OK:2024-03-03 12:00:00
  assert_eq(
    nm_tag("0 12 * * 7", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-16 12:00:00",
  ) // nm.17.1|OK:2024-06-16 12:00:00
  assert_eq(
    nm_tag("0 12 * * 7", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-05 12:00:00",
  ) // nm.17.2|OK:2025-01-05 12:00:00
  assert_eq(
    nm_tag("0 12 * * 7", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-07 12:00:00",
  ) // nm.17.3|OK:2024-01-07 12:00:00
  assert_eq(
    nm_tag("0 12 * * 7", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-23 12:00:00",
  ) // nm.17.4|OK:2024-06-23 12:00:00
  assert_eq(
    nm_tag("0 12 * * 7", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-03 12:00:00",
  ) // nm.17.5|OK:2100-01-03 12:00:00
  assert_eq(
    nm_tag("0 12 * * 0", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-03 12:00:00",
  ) // nm.18.0|OK:2024-03-03 12:00:00
  assert_eq(
    nm_tag("0 12 * * 0", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-16 12:00:00",
  ) // nm.18.1|OK:2024-06-16 12:00:00
  assert_eq(
    nm_tag("0 12 * * 0", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-05 12:00:00",
  ) // nm.18.2|OK:2025-01-05 12:00:00
  assert_eq(
    nm_tag("0 12 * * 0", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-07 12:00:00",
  ) // nm.18.3|OK:2024-01-07 12:00:00
  assert_eq(
    nm_tag("0 12 * * 0", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-23 12:00:00",
  ) // nm.18.4|OK:2024-06-23 12:00:00
  assert_eq(
    nm_tag("0 12 * * 0", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-03 12:00:00",
  ) // nm.18.5|OK:2100-01-03 12:00:00
  assert_eq(
    nm_tag("0 12 1 * MON", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-04-01 12:00:00",
  ) // nm.19.0|OK:2024-04-01 12:00:00
  assert_eq(
    nm_tag("0 12 1 * MON", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-07-01 12:00:00",
  ) // nm.19.1|OK:2024-07-01 12:00:00
  assert_eq(
    nm_tag("0 12 1 * MON", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-09-01 12:00:00",
  ) // nm.19.2|OK:2025-09-01 12:00:00
  assert_eq(
    nm_tag("0 12 1 * MON", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:00:00",
  ) // nm.19.3|OK:2024-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 1 * MON", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-07-01 12:00:00",
  ) // nm.19.4|OK:2024-07-01 12:00:00
  assert_eq(
    nm_tag("0 12 1 * MON", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-02-01 12:00:00",
  ) // nm.19.5|OK:2100-02-01 12:00:00
  assert_eq(
    nm_tag("0 12 * * SAT,SUN", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-02 12:00:00",
  ) // nm.20.0|OK:2024-03-02 12:00:00
  assert_eq(
    nm_tag("0 12 * * SAT,SUN", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-15 12:00:00",
  ) // nm.20.1|OK:2024-06-15 12:00:00
  assert_eq(
    nm_tag("0 12 * * SAT,SUN", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-04 12:00:00",
  ) // nm.20.2|OK:2025-01-04 12:00:00
  assert_eq(
    nm_tag("0 12 * * SAT,SUN", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-06 12:00:00",
  ) // nm.20.3|OK:2024-01-06 12:00:00
  assert_eq(
    nm_tag("0 12 * * SAT,SUN", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-22 12:00:00",
  ) // nm.20.4|OK:2024-06-22 12:00:00
  assert_eq(
    nm_tag("0 12 * * SAT,SUN", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-02 12:00:00",
  ) // nm.20.5|OK:2100-01-02 12:00:00
  assert_eq(
    nm_tag("*/15 9-17 * * MON-FRI", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.21.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:00:00",
  ) // nm.21.1|OK:2024-06-14 12:00:00
  assert_eq(
    nm_tag("*/15 9-17 * * MON-FRI", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 09:00:00",
  ) // nm.21.2|OK:2025-01-01 09:00:00
  assert_eq(
    nm_tag("*/15 9-17 * * MON-FRI", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 09:00:00",
  ) // nm.21.3|OK:2024-01-01 09:00:00
  assert_eq(
    nm_tag("*/15 9-17 * * MON-FRI", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:30:00",
  ) // nm.21.4|OK:2024-06-17 09:30:00
  assert_eq(
    nm_tag("*/15 9-17 * * MON-FRI", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:00:00",
  ) // nm.21.5|OK:2099-12-30 12:00:00
  assert_eq(
    nm_tag("0 0 * * SUN", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-03 00:00:00",
  ) // nm.22.0|OK:2024-03-03 00:00:00
  assert_eq(
    nm_tag("0 0 * * SUN", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-16 00:00:00",
  ) // nm.22.1|OK:2024-06-16 00:00:00
  assert_eq(
    nm_tag("0 0 * * SUN", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-05 00:00:00",
  ) // nm.22.2|OK:2025-01-05 00:00:00
  assert_eq(
    nm_tag("0 0 * * SUN", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-07 00:00:00",
  ) // nm.22.3|OK:2024-01-07 00:00:00
  assert_eq(
    nm_tag("0 0 * * SUN", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-23 00:00:00",
  ) // nm.22.4|OK:2024-06-23 00:00:00
  assert_eq(
    nm_tag("0 0 * * SUN", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-03 00:00:00",
  ) // nm.22.5|OK:2100-01-03 00:00:00
  assert_eq(
    nm_tag("0 0 1 1 *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nm.23.0|OK:2025-01-01 00:00:00
  assert_eq(
    nm_tag("0 0 1 1 *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nm.23.1|OK:2025-01-01 00:00:00
  assert_eq(
    nm_tag("0 0 1 1 *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nm.23.2|OK:2025-01-01 00:00:00
  assert_eq(
    nm_tag("0 0 1 1 *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:00:00",
  ) // nm.23.3|OK:2024-01-01 00:00:00
  assert_eq(
    nm_tag("0 0 1 1 *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2025-01-01 00:00:00",
  ) // nm.23.4|OK:2025-01-01 00:00:00
  assert_eq(
    nm_tag("0 0 1 1 *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-01 00:00:00",
  ) // nm.23.5|OK:2100-01-01 00:00:00
  assert_eq(
    nm_tag("0 0 29 2 *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2028-02-29 00:00:00",
  ) // nm.24.0|OK:2028-02-29 00:00:00
  assert_eq(
    nm_tag("0 0 29 2 *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2028-02-29 00:00:00",
  ) // nm.24.1|OK:2028-02-29 00:00:00
  assert_eq(
    nm_tag("0 0 29 2 *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2028-02-29 00:00:00",
  ) // nm.24.2|OK:2028-02-29 00:00:00
  assert_eq(
    nm_tag("0 0 29 2 *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-02-29 00:00:00",
  ) // nm.24.3|OK:2024-02-29 00:00:00
  assert_eq(
    nm_tag("0 0 29 2 *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2028-02-29 00:00:00",
  ) // nm.24.4|OK:2028-02-29 00:00:00
  assert_eq(
    nm_tag("0 0 29 2 *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2104-02-29 00:00:00",
  ) // nm.24.5|OK:2104-02-29 00:00:00
  assert_eq(
    nm_tag("0 12 */3 * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.25.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("0 12 */3 * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-30 12:00:00",
  ) // nm.25.1|OK:2024-06-30 12:00:00
  assert_eq(
    nm_tag("0 12 */3 * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-31 12:00:00",
  ) // nm.25.2|OK:2025-01-31 12:00:00
  assert_eq(
    nm_tag("0 12 */3 * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-31 12:00:00",
  ) // nm.25.3|OK:2024-01-31 12:00:00
  assert_eq(
    nm_tag("0 12 */3 * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-30 12:00:00",
  ) // nm.25.4|OK:2024-06-30 12:00:00
  assert_eq(
    nm_tag("0 12 */3 * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-31 12:00:00",
  ) // nm.25.5|OK:2099-12-31 12:00:00
  assert_eq(
    nm_tag("30 6 * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-01 06:30:00",
  ) // nm.26.0|OK:2024-03-01 06:30:00
  assert_eq(
    nm_tag("30 6 * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-15 06:30:00",
  ) // nm.26.1|OK:2024-06-15 06:30:00
  assert_eq(
    nm_tag("30 6 * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 06:30:00",
  ) // nm.26.2|OK:2025-01-01 06:30:00
  assert_eq(
    nm_tag("30 6 * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 06:30:00",
  ) // nm.26.3|OK:2024-01-01 06:30:00
  assert_eq(
    nm_tag("30 6 * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-18 06:30:00",
  ) // nm.26.4|OK:2024-06-18 06:30:00
  assert_eq(
    nm_tag("30 6 * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-31 06:30:00",
  ) // nm.26.5|OK:2099-12-31 06:30:00
  assert_eq(
    nm_tag("0-59/13 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.27.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("0-59/13 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:00:00",
  ) // nm.27.1|OK:2024-06-14 12:00:00
  assert_eq(
    nm_tag("0-59/13 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nm.27.2|OK:2025-01-01 00:00:00
  assert_eq(
    nm_tag("0-59/13 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:00:00",
  ) // nm.27.3|OK:2024-01-01 00:00:00
  assert_eq(
    nm_tag("0-59/13 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:26:00",
  ) // nm.27.4|OK:2024-06-17 09:26:00
  assert_eq(
    nm_tag("0-59/13 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:00:00",
  ) // nm.27.5|OK:2099-12-30 12:00:00
  assert_eq(
    nm_tag("*/7 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.28.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("*/7 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:00:00",
  ) // nm.28.1|OK:2024-06-14 12:00:00
  assert_eq(
    nm_tag("*/7 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:00:00",
  ) // nm.28.2|OK:2025-01-01 00:00:00
  assert_eq(
    nm_tag("*/7 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:00:00",
  ) // nm.28.3|OK:2024-01-01 00:00:00
  assert_eq(
    nm_tag("*/7 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:21:00",
  ) // nm.28.4|OK:2024-06-17 09:21:00
  assert_eq(
    nm_tag("*/7 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:00:00",
  ) // nm.28.5|OK:2099-12-30 12:00:00
  assert_eq(
    nm_tag("1,1,1 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:01:00",
  ) // nm.29.0|OK:2024-02-29 12:01:00
  assert_eq(
    nm_tag("1,1,1 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:01:00",
  ) // nm.29.1|OK:2024-06-14 12:01:00
  assert_eq(
    nm_tag("1,1,1 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 00:01:00",
  ) // nm.29.2|OK:2025-01-01 00:01:00
  assert_eq(
    nm_tag("1,1,1 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:01:00",
  ) // nm.29.3|OK:2024-01-01 00:01:00
  assert_eq(
    nm_tag("1,1,1 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 10:01:00",
  ) // nm.29.4|OK:2024-06-17 10:01:00
  assert_eq(
    nm_tag("1,1,1 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:01:00",
  ) // nm.29.5|OK:2099-12-30 12:01:00
  assert_eq(
    nm_tag("5-1,7 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.30.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("5-1,7 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:00:00",
  ) // nm.30.1|OK:2024-06-14 12:00:00
  assert_eq(
    nm_tag("5-1,7 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2024-12-31 23:59:00",
  ) // nm.30.2|OK:2024-12-31 23:59:00
  assert_eq(
    nm_tag("5-1,7 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:00:00",
  ) // nm.30.3|OK:2024-01-01 00:00:00
  assert_eq(
    nm_tag("5-1,7 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:16:00",
  ) // nm.30.4|OK:2024-06-17 09:16:00
  assert_eq(
    nm_tag("5-1,7 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:00:00",
  ) // nm.30.5|OK:2099-12-30 12:00:00
  assert_eq(
    nm_tag("8-2 * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.31.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("8-2 * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:00:00",
  ) // nm.31.1|OK:2024-06-14 12:00:00
  assert_eq(
    nm_tag("8-2 * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2024-12-31 23:59:00",
  ) // nm.31.2|OK:2024-12-31 23:59:00
  assert_eq(
    nm_tag("8-2 * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:00:00",
  ) // nm.31.3|OK:2024-01-01 00:00:00
  assert_eq(
    nm_tag("8-2 * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:16:00",
  ) // nm.31.4|OK:2024-06-17 09:16:00
  assert_eq(
    nm_tag("8-2 * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:00:00",
  ) // nm.31.5|OK:2099-12-30 12:00:00
  assert_eq(
    nm_tag("59 59 12 * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:59:59",
  ) // nm.32.0|OK:2024-02-29 12:59:59
  assert_eq(
    nm_tag("59 59 12 * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:59:59",
  ) // nm.32.1|OK:2024-06-14 12:59:59
  assert_eq(
    nm_tag("59 59 12 * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 12:59:59",
  ) // nm.32.2|OK:2025-01-01 12:59:59
  assert_eq(
    nm_tag("59 59 12 * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:59:59",
  ) // nm.32.3|OK:2024-01-01 12:59:59
  assert_eq(
    nm_tag("59 59 12 * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 12:59:59",
  ) // nm.32.4|OK:2024-06-17 12:59:59
  assert_eq(
    nm_tag("59 59 12 * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:59:59",
  ) // nm.32.5|OK:2099-12-30 12:59:59
  assert_eq(
    nm_tag("0 0 12 * * ? 2099", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2099-01-01 12:00:00",
  ) // nm.33.0|OK:2099-01-01 12:00:00
  assert_eq(
    nm_tag("0 0 12 * * ? 2099", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2099-01-01 12:00:00",
  ) // nm.33.1|OK:2099-01-01 12:00:00
  assert_eq(
    nm_tag("0 0 12 * * ? 2099", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2099-01-01 12:00:00",
  ) // nm.33.2|OK:2099-01-01 12:00:00
  assert_eq(
    nm_tag("0 0 12 * * ? 2099", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2099-01-01 12:00:00",
  ) // nm.33.3|OK:2099-01-01 12:00:00
  assert_eq(
    nm_tag("0 0 12 * * ? 2099", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2099-01-01 12:00:00",
  ) // nm.33.4|OK:2099-01-01 12:00:00
  assert_eq(
    nm_tag("0 0 12 * * ? 2099", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:00:00",
  ) // nm.33.5|OK:2099-12-30 12:00:00
  assert_eq(
    nm_tag("0 0 12 * * ? 1970", dt(2024, 2, 29, 12, 0, 0)),
    "IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher",
  ) // nm.34.0|IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher
  assert_eq(
    nm_tag("0 0 12 * * ? 1970", dt(2024, 6, 14, 12, 0, 0)),
    "IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher",
  ) // nm.34.1|IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher
  assert_eq(
    nm_tag("0 0 12 * * ? 1970", dt(2024, 3, 31, 12, 0, 0)),
    "IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher",
  ) // nm.34.2|IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher
  assert_eq(
    nm_tag("0 0 12 * * ? 1970", dt(2024, 1, 1, 0, 0, 0)),
    "IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher",
  ) // nm.34.3|IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher
  assert_eq(
    nm_tag("0 0 12 * * ? 1970", dt(2024, 6, 17, 9, 15, 30)),
    "IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher",
  ) // nm.34.4|IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher
  assert_eq(
    nm_tag("0 0 12 * * ? 1970", dt(2099, 12, 30, 12, 0, 0)),
    "IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher",
  ) // nm.34.5|IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher
  assert_eq(
    nm_tag("* * * * * * *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.41.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("* * * * * * *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:00:00",
  ) // nm.41.1|OK:2024-06-14 12:00:00
  assert_eq(
    nm_tag("* * * * * * *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2024-12-31 23:59:00",
  ) // nm.41.2|OK:2024-12-31 23:59:00
  assert_eq(
    nm_tag("* * * * * * *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 00:00:00",
  ) // nm.41.3|OK:2024-01-01 00:00:00
  assert_eq(
    nm_tag("* * * * * * *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 09:15:30",
  ) // nm.41.4|OK:2024-06-17 09:15:30
  assert_eq(
    nm_tag("* * * * * * *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:00:00",
  ) // nm.41.5|OK:2099-12-30 12:00:00
  assert_eq(
    nm_tag("0 12 * * 1-7", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-02-29 12:00:00",
  ) // nm.44.0|OK:2024-02-29 12:00:00
  assert_eq(
    nm_tag("0 12 * * 1-7", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-14 12:00:00",
  ) // nm.44.1|OK:2024-06-14 12:00:00
  assert_eq(
    nm_tag("0 12 * * 1-7", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-01 12:00:00",
  ) // nm.44.2|OK:2025-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * * 1-7", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-01 12:00:00",
  ) // nm.44.3|OK:2024-01-01 12:00:00
  assert_eq(
    nm_tag("0 12 * * 1-7", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-17 12:00:00",
  ) // nm.44.4|OK:2024-06-17 12:00:00
  assert_eq(
    nm_tag("0 12 * * 1-7", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2099-12-30 12:00:00",
  ) // nm.44.5|OK:2099-12-30 12:00:00
  assert_eq(
    nm_tag("0 12 * * 0-7", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-03-03 12:00:00",
  ) // nm.45.0|OK:2024-03-03 12:00:00
  assert_eq(
    nm_tag("0 12 * * 0-7", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2024-06-16 12:00:00",
  ) // nm.45.1|OK:2024-06-16 12:00:00
  assert_eq(
    nm_tag("0 12 * * 0-7", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-01-05 12:00:00",
  ) // nm.45.2|OK:2025-01-05 12:00:00
  assert_eq(
    nm_tag("0 12 * * 0-7", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-01-07 12:00:00",
  ) // nm.45.3|OK:2024-01-07 12:00:00
  assert_eq(
    nm_tag("0 12 * * 0-7", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2024-06-23 12:00:00",
  ) // nm.45.4|OK:2024-06-23 12:00:00
  assert_eq(
    nm_tag("0 12 * * 0-7", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-01-03 12:00:00",
  ) // nm.45.5|OK:2100-01-03 12:00:00
  assert_eq(
    nm_tag("0 12 31 4 *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-04-30 12:00:00",
  ) // nm.49.0|OK:2024-04-30 12:00:00
  assert_eq(
    nm_tag("0 12 31 4 *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2025-04-30 12:00:00",
  ) // nm.49.1|OK:2025-04-30 12:00:00
  assert_eq(
    nm_tag("0 12 31 4 *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-04-30 12:00:00",
  ) // nm.49.2|OK:2025-04-30 12:00:00
  assert_eq(
    nm_tag("0 12 31 4 *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-04-30 12:00:00",
  ) // nm.49.3|OK:2024-04-30 12:00:00
  assert_eq(
    nm_tag("0 12 31 4 *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2025-04-30 12:00:00",
  ) // nm.49.4|OK:2025-04-30 12:00:00
  assert_eq(
    nm_tag("0 12 31 4 *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-04-30 12:00:00",
  ) // nm.49.5|OK:2100-04-30 12:00:00
}

///|
test "cron 同值对：别名大小写、周日 0 与 7、? 与 *" {
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 2, 29, 12, 0, 0), false),
    m_tag("0 12 * jan-mar *", dt(2024, 2, 29, 12, 0, 0), false),
  ) // jan-mar 与 JAN-MAR：m.9.0 与 m.10.0 同值
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2023, 2, 28, 23, 59, 0), false),
    m_tag("0 12 * jan-mar *", dt(2023, 2, 28, 23, 59, 0), false),
  ) // jan-mar 与 JAN-MAR：m.9.1 与 m.10.1 同值
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 3, 31, 12, 0, 0), false),
    m_tag("0 12 * jan-mar *", dt(2024, 3, 31, 12, 0, 0), false),
  ) // jan-mar 与 JAN-MAR：m.9.2 与 m.10.2 同值
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 4, 30, 12, 0, 0), false),
    m_tag("0 12 * jan-mar *", dt(2024, 4, 30, 12, 0, 0), false),
  ) // jan-mar 与 JAN-MAR：m.9.3 与 m.10.3 同值
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 6, 15, 12, 0, 0), false),
    m_tag("0 12 * jan-mar *", dt(2024, 6, 15, 12, 0, 0), false),
  ) // jan-mar 与 JAN-MAR：m.9.4 与 m.10.4 同值
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 6, 14, 12, 0, 0), false),
    m_tag("0 12 * jan-mar *", dt(2024, 6, 14, 12, 0, 0), false),
  ) // jan-mar 与 JAN-MAR：m.9.5 与 m.10.5 同值
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 6, 1, 0, 0, 0), false),
    m_tag("0 12 * jan-mar *", dt(2024, 6, 1, 0, 0, 0), false),
  ) // jan-mar 与 JAN-MAR：m.9.6 与 m.10.6 同值
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 1, 1, 0, 0, 0), false),
    m_tag("0 12 * jan-mar *", dt(2024, 1, 1, 0, 0, 0), false),
  ) // jan-mar 与 JAN-MAR：m.9.7 与 m.10.7 同值
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 6, 17, 9, 15, 0), false),
    m_tag("0 12 * jan-mar *", dt(2024, 6, 17, 9, 15, 0), false),
  ) // jan-mar 与 JAN-MAR：m.9.8 与 m.10.8 同值
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 6, 17, 9, 15, 30), false),
    m_tag("0 12 * jan-mar *", dt(2024, 6, 17, 9, 15, 30), false),
  ) // jan-mar 与 JAN-MAR：m.9.9 与 m.10.9 同值
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2099, 12, 31, 12, 0, 0), false),
    m_tag("0 12 * jan-mar *", dt(2099, 12, 31, 12, 0, 0), false),
  ) // jan-mar 与 JAN-MAR：m.9.10 与 m.10.10 同值
  assert_eq(
    m_tag("0 12 * JAN-MAR *", dt(2024, 2, 29, 0, 0, 0), false),
    m_tag("0 12 * jan-mar *", dt(2024, 2, 29, 0, 0, 0), false),
  ) // jan-mar 与 JAN-MAR：m.9.11 与 m.10.11 同值
  assert_eq(
    nx_tag("0 12 * JAN-MAR *", dt(2024, 2, 29, 12, 0, 0)),
    nx_tag("0 12 * jan-mar *", dt(2024, 2, 29, 12, 0, 0)),
  ) // jan-mar 与 JAN-MAR：nx.9.0 与 nx.10.0 同值
  assert_eq(
    nx_tag("0 12 * JAN-MAR *", dt(2024, 6, 14, 12, 0, 0)),
    nx_tag("0 12 * jan-mar *", dt(2024, 6, 14, 12, 0, 0)),
  ) // jan-mar 与 JAN-MAR：nx.9.1 与 nx.10.1 同值
  assert_eq(
    nx_tag("0 12 * JAN-MAR *", dt(2024, 3, 31, 12, 0, 0)),
    nx_tag("0 12 * jan-mar *", dt(2024, 3, 31, 12, 0, 0)),
  ) // jan-mar 与 JAN-MAR：nx.9.2 与 nx.10.2 同值
  assert_eq(
    nx_tag("0 12 * JAN-MAR *", dt(2024, 1, 1, 0, 0, 0)),
    nx_tag("0 12 * jan-mar *", dt(2024, 1, 1, 0, 0, 0)),
  ) // jan-mar 与 JAN-MAR：nx.9.3 与 nx.10.3 同值
  assert_eq(
    nx_tag("0 12 * JAN-MAR *", dt(2024, 6, 17, 9, 15, 30)),
    nx_tag("0 12 * jan-mar *", dt(2024, 6, 17, 9, 15, 30)),
  ) // jan-mar 与 JAN-MAR：nx.9.4 与 nx.10.4 同值
  assert_eq(
    nx_tag("0 12 * JAN-MAR *", dt(2099, 12, 30, 12, 0, 0)),
    nx_tag("0 12 * jan-mar *", dt(2099, 12, 30, 12, 0, 0)),
  ) // jan-mar 与 JAN-MAR：nx.9.5 与 nx.10.5 同值
  assert_eq(
    m_tag("0 12 * * 7", dt(2024, 2, 29, 12, 0, 0), false),
    m_tag("0 12 * * 0", dt(2024, 2, 29, 12, 0, 0), false),
  ) // 周日写 7 与写 0：m.17.0 与 m.18.0 同值
  assert_eq(
    m_tag("0 12 * * 7", dt(2023, 2, 28, 23, 59, 0), false),
    m_tag("0 12 * * 0", dt(2023, 2, 28, 23, 59, 0), false),
  ) // 周日写 7 与写 0：m.17.1 与 m.18.1 同值
  assert_eq(
    m_tag("0 12 * * 7", dt(2024, 3, 31, 12, 0, 0), false),
    m_tag("0 12 * * 0", dt(2024, 3, 31, 12, 0, 0), false),
  ) // 周日写 7 与写 0：m.17.2 与 m.18.2 同值
  assert_eq(
    m_tag("0 12 * * 7", dt(2024, 4, 30, 12, 0, 0), false),
    m_tag("0 12 * * 0", dt(2024, 4, 30, 12, 0, 0), false),
  ) // 周日写 7 与写 0：m.17.3 与 m.18.3 同值
  assert_eq(
    m_tag("0 12 * * 7", dt(2024, 6, 15, 12, 0, 0), false),
    m_tag("0 12 * * 0", dt(2024, 6, 15, 12, 0, 0), false),
  ) // 周日写 7 与写 0：m.17.4 与 m.18.4 同值
  assert_eq(
    m_tag("0 12 * * 7", dt(2024, 6, 14, 12, 0, 0), false),
    m_tag("0 12 * * 0", dt(2024, 6, 14, 12, 0, 0), false),
  ) // 周日写 7 与写 0：m.17.5 与 m.18.5 同值
  assert_eq(
    m_tag("0 12 * * 7", dt(2024, 6, 1, 0, 0, 0), false),
    m_tag("0 12 * * 0", dt(2024, 6, 1, 0, 0, 0), false),
  ) // 周日写 7 与写 0：m.17.6 与 m.18.6 同值
  assert_eq(
    m_tag("0 12 * * 7", dt(2024, 1, 1, 0, 0, 0), false),
    m_tag("0 12 * * 0", dt(2024, 1, 1, 0, 0, 0), false),
  ) // 周日写 7 与写 0：m.17.7 与 m.18.7 同值
  assert_eq(
    m_tag("0 12 * * 7", dt(2024, 6, 17, 9, 15, 0), false),
    m_tag("0 12 * * 0", dt(2024, 6, 17, 9, 15, 0), false),
  ) // 周日写 7 与写 0：m.17.8 与 m.18.8 同值
  assert_eq(
    m_tag("0 12 * * 7", dt(2024, 6, 17, 9, 15, 30), false),
    m_tag("0 12 * * 0", dt(2024, 6, 17, 9, 15, 30), false),
  ) // 周日写 7 与写 0：m.17.9 与 m.18.9 同值
  assert_eq(
    m_tag("0 12 * * 7", dt(2099, 12, 31, 12, 0, 0), false),
    m_tag("0 12 * * 0", dt(2099, 12, 31, 12, 0, 0), false),
  ) // 周日写 7 与写 0：m.17.10 与 m.18.10 同值
  assert_eq(
    m_tag("0 12 * * 7", dt(2024, 2, 29, 0, 0, 0), false),
    m_tag("0 12 * * 0", dt(2024, 2, 29, 0, 0, 0), false),
  ) // 周日写 7 与写 0：m.17.11 与 m.18.11 同值
  assert_eq(
    nx_tag("0 12 * * 7", dt(2024, 2, 29, 12, 0, 0)),
    nx_tag("0 12 * * 0", dt(2024, 2, 29, 12, 0, 0)),
  ) // 周日写 7 与写 0：nx.17.0 与 nx.18.0 同值
  assert_eq(
    nx_tag("0 12 * * 7", dt(2024, 6, 14, 12, 0, 0)),
    nx_tag("0 12 * * 0", dt(2024, 6, 14, 12, 0, 0)),
  ) // 周日写 7 与写 0：nx.17.1 与 nx.18.1 同值
  assert_eq(
    nx_tag("0 12 * * 7", dt(2024, 3, 31, 12, 0, 0)),
    nx_tag("0 12 * * 0", dt(2024, 3, 31, 12, 0, 0)),
  ) // 周日写 7 与写 0：nx.17.2 与 nx.18.2 同值
  assert_eq(
    nx_tag("0 12 * * 7", dt(2024, 1, 1, 0, 0, 0)),
    nx_tag("0 12 * * 0", dt(2024, 1, 1, 0, 0, 0)),
  ) // 周日写 7 与写 0：nx.17.3 与 nx.18.3 同值
  assert_eq(
    nx_tag("0 12 * * 7", dt(2024, 6, 17, 9, 15, 30)),
    nx_tag("0 12 * * 0", dt(2024, 6, 17, 9, 15, 30)),
  ) // 周日写 7 与写 0：nx.17.4 与 nx.18.4 同值
  assert_eq(
    nx_tag("0 12 * * 7", dt(2099, 12, 30, 12, 0, 0)),
    nx_tag("0 12 * * 0", dt(2099, 12, 30, 12, 0, 0)),
  ) // 周日写 7 与写 0：nx.17.5 与 nx.18.5 同值
  assert_eq(
    m_tag("* * * * *", dt(2024, 2, 29, 12, 0, 0), false),
    m_tag("? * * * *", dt(2024, 2, 29, 12, 0, 0), false),
  ) // `?` 与 `*` 同义（秒段）：m.0.0 与 m.6.0 同值
  assert_eq(
    m_tag("* * * * *", dt(2023, 2, 28, 23, 59, 0), false),
    m_tag("? * * * *", dt(2023, 2, 28, 23, 59, 0), false),
  ) // `?` 与 `*` 同义（秒段）：m.0.1 与 m.6.1 同值
  assert_eq(
    m_tag("* * * * *", dt(2024, 3, 31, 12, 0, 0), false),
    m_tag("? * * * *", dt(2024, 3, 31, 12, 0, 0), false),
  ) // `?` 与 `*` 同义（秒段）：m.0.2 与 m.6.2 同值
  assert_eq(
    m_tag("* * * * *", dt(2024, 4, 30, 12, 0, 0), false),
    m_tag("? * * * *", dt(2024, 4, 30, 12, 0, 0), false),
  ) // `?` 与 `*` 同义（秒段）：m.0.3 与 m.6.3 同值
  assert_eq(
    m_tag("* * * * *", dt(2024, 6, 15, 12, 0, 0), false),
    m_tag("? * * * *", dt(2024, 6, 15, 12, 0, 0), false),
  ) // `?` 与 `*` 同义（秒段）：m.0.4 与 m.6.4 同值
  assert_eq(
    m_tag("* * * * *", dt(2024, 6, 14, 12, 0, 0), false),
    m_tag("? * * * *", dt(2024, 6, 14, 12, 0, 0), false),
  ) // `?` 与 `*` 同义（秒段）：m.0.5 与 m.6.5 同值
  assert_eq(
    m_tag("* * * * *", dt(2024, 6, 1, 0, 0, 0), false),
    m_tag("? * * * *", dt(2024, 6, 1, 0, 0, 0), false),
  ) // `?` 与 `*` 同义（秒段）：m.0.6 与 m.6.6 同值
  assert_eq(
    m_tag("* * * * *", dt(2024, 1, 1, 0, 0, 0), false),
    m_tag("? * * * *", dt(2024, 1, 1, 0, 0, 0), false),
  ) // `?` 与 `*` 同义（秒段）：m.0.7 与 m.6.7 同值
  assert_eq(
    m_tag("* * * * *", dt(2024, 6, 17, 9, 15, 0), false),
    m_tag("? * * * *", dt(2024, 6, 17, 9, 15, 0), false),
  ) // `?` 与 `*` 同义（秒段）：m.0.8 与 m.6.8 同值
  assert_eq(
    m_tag("* * * * *", dt(2024, 6, 17, 9, 15, 30), false),
    m_tag("? * * * *", dt(2024, 6, 17, 9, 15, 30), false),
  ) // `?` 与 `*` 同义（秒段）：m.0.9 与 m.6.9 同值
  assert_eq(
    m_tag("* * * * *", dt(2099, 12, 31, 12, 0, 0), false),
    m_tag("? * * * *", dt(2099, 12, 31, 12, 0, 0), false),
  ) // `?` 与 `*` 同义（秒段）：m.0.10 与 m.6.10 同值
  assert_eq(
    m_tag("* * * * *", dt(2024, 2, 29, 0, 0, 0), false),
    m_tag("? * * * *", dt(2024, 2, 29, 0, 0, 0), false),
  ) // `?` 与 `*` 同义（秒段）：m.0.11 与 m.6.11 同值
  assert_eq(
    nx_tag("* * * * *", dt(2024, 2, 29, 12, 0, 0)),
    nx_tag("? * * * *", dt(2024, 2, 29, 12, 0, 0)),
  ) // `?` 与 `*` 同义（秒段）：nx.0.0 与 nx.6.0 同值
  assert_eq(
    nx_tag("* * * * *", dt(2024, 6, 14, 12, 0, 0)),
    nx_tag("? * * * *", dt(2024, 6, 14, 12, 0, 0)),
  ) // `?` 与 `*` 同义（秒段）：nx.0.1 与 nx.6.1 同值
  assert_eq(
    nx_tag("* * * * *", dt(2024, 3, 31, 12, 0, 0)),
    nx_tag("? * * * *", dt(2024, 3, 31, 12, 0, 0)),
  ) // `?` 与 `*` 同义（秒段）：nx.0.2 与 nx.6.2 同值
  assert_eq(
    nx_tag("* * * * *", dt(2024, 1, 1, 0, 0, 0)),
    nx_tag("? * * * *", dt(2024, 1, 1, 0, 0, 0)),
  ) // `?` 与 `*` 同义（秒段）：nx.0.3 与 nx.6.3 同值
  assert_eq(
    nx_tag("* * * * *", dt(2024, 6, 17, 9, 15, 30)),
    nx_tag("? * * * *", dt(2024, 6, 17, 9, 15, 30)),
  ) // `?` 与 `*` 同义（秒段）：nx.0.4 与 nx.6.4 同值
  assert_eq(
    nx_tag("* * * * *", dt(2099, 12, 30, 12, 0, 0)),
    nx_tag("? * * * *", dt(2099, 12, 30, 12, 0, 0)),
  ) // `?` 与 `*` 同义（秒段）：nx.0.5 与 nx.6.5 同值
}

///|
test "cron 三条承重：日与周同时限定取且、不存在的日子夹到月末、2 月 29 日只给闰年" {
  assert_eq(m_tag("0 12 1 * MON", dt(2024, 6, 1, 0, 0, 0), false), "OK:false") // m.19.6|OK:false —— 2024-06-01 是周六，1 号且周一不成立
  assert_eq(m_tag("0 12 1 * MON", dt(2024, 6, 15, 12, 0, 0), false), "OK:false") // m.19.4|OK:false —— 2024-06-15 是周六
  assert_eq(m_tag("0 12 1 * MON", dt(2024, 6, 14, 12, 0, 0), false), "OK:false") // m.19.5|OK:false —— 2024-06-14 是周五
  assert_eq(
    nx_tag("0 12 31 4 *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2024-04-30 12:00:00",
  ) // nx.49.0|OK:2024-04-30 12:00:00 —— 4 月没有 31 日，夹到月末
  assert_eq(
    nx_tag("0 12 31 4 *", dt(2024, 6, 14, 12, 0, 0)),
    "OK:2025-04-30 12:00:00",
  ) // nx.49.1|OK:2025-04-30 12:00:00 —— 4 月没有 31 日，夹到月末
  assert_eq(
    nx_tag("0 12 31 4 *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2025-04-30 12:00:00",
  ) // nx.49.2|OK:2025-04-30 12:00:00 —— 4 月没有 31 日，夹到月末
  assert_eq(
    nx_tag("0 12 31 4 *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-04-30 12:00:00",
  ) // nx.49.3|OK:2024-04-30 12:00:00 —— 4 月没有 31 日，夹到月末
  assert_eq(
    nx_tag("0 12 31 4 *", dt(2024, 6, 17, 9, 15, 30)),
    "OK:2025-04-30 12:00:00",
  ) // nx.49.4|OK:2025-04-30 12:00:00 —— 4 月没有 31 日，夹到月末
  assert_eq(
    nx_tag("0 12 31 4 *", dt(2099, 12, 30, 12, 0, 0)),
    "OK:2100-04-30 12:00:00",
  ) // nx.49.5|OK:2100-04-30 12:00:00 —— 4 月没有 31 日，夹到月末
  assert_eq(
    nx_tag("0 0 29 2 *", dt(2024, 2, 29, 12, 0, 0)),
    "OK:2028-02-29 00:00:00",
  ) // nx.24.0|OK:2028-02-29 00:00:00 —— 2/29 只落在闰年
  assert_eq(
    nx_tag("0 0 29 2 *", dt(2024, 3, 31, 12, 0, 0)),
    "OK:2028-02-29 00:00:00",
  ) // nx.24.2|OK:2028-02-29 00:00:00 —— 2/29 只落在闰年
  assert_eq(
    nx_tag("0 0 29 2 *", dt(2024, 1, 1, 0, 0, 0)),
    "OK:2024-02-29 00:00:00",
  ) // nx.24.3|OK:2024-02-29 00:00:00 —— 2/29 只落在闰年
}

///|
test "cron 报错档归口：星期侧 L/# 与 5-7 段之外、空串、越界、步进" {
  assert_eq(parse_text("-1 * * * *"), "OutOfRange[MINUTE,-1]") // ok.37|OK:-1 * * * *；参照侧 m.37.0|OK:false、nx.37.0|OK:2024-02-29 12:58:00（本库把失败挪回解析期）
  assert_eq(parse_text(""), "BadParts[]") // ok.42|OK:；参照侧 m.42.0|OK:false、nx.42.0|NullPointerException:Cannot invoke "java.util.Calendar.get(int)" because "calendar" is null（本库把失败挪回解析期）
  assert_eq(parse_text("   "), "BadParts[   ]") // ok.43|OK:；参照侧 m.43.0|OK:false、nx.43.0|NullPointerException:Cannot invoke "java.util.Calendar.get(int)" because "calendar" is null（本库把失败挪回解析期）
  assert_eq(parse_text("0 12 * * 5L"), "BadAlias[5L]") // ok.14|IllegalArgumentException:No enum constant cn.hutool.core.date.Week.5L —— 本库归进 BadAlias 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  assert_eq(parse_text("0 12 * * 6L"), "BadAlias[6L]") // ok.15|IllegalArgumentException:No enum constant cn.hutool.core.date.Week.6L —— 本库归进 BadAlias 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  assert_eq(parse_text("0 12 * * FRI#2"), "BadAlias[FRI#2]") // ok.16|IllegalArgumentException:No enum constant cn.hutool.core.date.Week.FRI#2 —— 本库归进 BadAlias 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  assert_eq(parse_text("0 12 LW * *"), "BadAlias[LW]") // ok.12|CronException:Invalid alias value: [LW] —— 本库归进 BadAlias 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  assert_eq(parse_text("0 12 15L * *"), "BadAlias[15L]") // ok.13|CronException:Invalid alias value: [15L] —— 本库归进 BadAlias 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  assert_eq(parse_text("*/0 * * * *"), "NonPositiveStep[*/0]") // ok.35|CronException:Non positive divisor for field: [*/0] —— 本库归进 NonPositiveStep 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  assert_eq(parse_text("60 * * * *"), "OutOfRange[MINUTE,60]") // ok.36|CronException:MINUTE value 60 out of range: [0 , 59] —— 本库归进 OutOfRange 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  assert_eq(parse_text("0 12 32 * *"), "OutOfRange[DAY_OF_MONTH,32]") // ok.46|CronException:DAY_OF_MONTH value 32 out of range: [1 , 31] —— 本库归进 OutOfRange 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  assert_eq(parse_text("0 12 0 * *"), "OutOfRange[DAY_OF_MONTH,0]") // ok.47|CronException:DAY_OF_MONTH value 0 out of range: [1 , 31] —— 本库归进 OutOfRange 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  assert_eq(parse_text("0 24 * * *"), "OutOfRange[HOUR,24]") // ok.48|CronException:HOUR value 24 out of range: [0 , 23] —— 本库归进 OutOfRange 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  assert_eq(parse_text("abc * * * *"), "BadAlias[abc]") // ok.38|CronException:Invalid alias value: [abc] —— 本库归进 BadAlias 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  assert_eq(parse_text("* * * * FOO"), "BadAlias[FOO]") // ok.39|IllegalArgumentException:No enum constant cn.hutool.core.date.Week.FOO —— 本库归进 BadAlias 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  assert_eq(parse_text("* * * *"), "BadParts[* * * *]") // ok.40|CronException:Pattern [* * * *] is invalid, it must be 5-7 parts! —— 本库归进 BadParts 档（参照侧第 14/15/16 条抛的是 IllegalArgumentException）
  // 参照侧空串与纯空白在解析期不报错（ok.42|OK:），到取下一时刻才 NPE（nx.42.0|NullPointerException:Cannot invoke "java.util.Calendar.get(int)" because "calendar" is null）——
  // 本库把这一档挪回解析期，两侧读数都在案
  assert_eq(parse_text(""), "OK:") // ok.42|OK: —— 本库判 BadParts（spec §5 第 2 行）
  // 参照侧空串与纯空白在解析期不报错（ok.43|OK:），到取下一时刻才 NPE（nx.43.0|NullPointerException:Cannot invoke "java.util.Calendar.get(int)" because "calendar" is null）——
  // 本库把这一档挪回解析期，两侧读数都在案
  assert_eq(parse_text("   "), "OK:") // ok.43|OK: —— 本库判 BadParts（spec §5 第 2 行）
}
