///|
// date 第五批补档（10-08）——pattern 引号档、解析侧重复字段、时间字段用在纯日期上、
// greedy 数字两档，以及 RFC 3339 那条严格腿的五个报错位置。
// 参照腿 `scripts/Iso2Leg.java`（JDK 17）：ISO 族取 `java.time.OffsetDateTime.parse`，
// pattern 族取 `java.text.SimpleDateFormat`——**不用 hutool `DateUtil.parse`**，
// 那是"猜测式"多格式入口，位置与语义都不是本库这条严格腿的对位物（判据归属写进 spec §9 开头）。
// 取值档一律由腿现读灌入（手打零条）；报错**位置**是本库自定的口径（`DateError` 只携带读数不携带文案，
// spec §2 那条），所以那一档钉的是本库形状、把参照"是否也拒"记在注释里。

///|
fn d5_err(e : @date.DateError) -> String {
  match e {
    @date.ParseFailed(input, at) => "ParseFailed \{input}@\{at}"
    @date.UnknownPatternToken(t) => "UnknownPatternToken \{t}"
    _ => "其他变体"
  }
}

///|
fn d5_iso(text : String) -> String {
  @date.from_rfc3339(text).to_string() catch {
    e => d5_err(e)
  }
}

///|
fn d5_fmt_date(d : @date.Date, pattern : String) -> String {
  d.format(pattern) catch {
    e => d5_err(e)
  }
}

///|
fn d5_parse_date(input : String, pattern : String) -> String {
  @date.Date::parse(input, pattern).to_iso_string() catch {
    e => d5_err(e)
  }
}

///|
test "date RFC 3339 取值：七档与 JDK 逐条同判（腿 I 行）" {
  // 期望来自 Iso2Leg.java 的 I0/I1/I2/I3/I4/I11/I12（epoch_millis），不是手打
  assert_eq(d5_iso("2026-10-07T12:00:00.52+05:30"), "1791354600520")
  assert_eq(d5_iso("2026-10-07T12:00:00.123456+00:00"), "1791374400123")
  assert_eq(d5_iso("2026-10-07T12:00:00-05:00"), "1791392400000")
  assert_eq(d5_iso("2026-10-07T12:00:00Z"), "1791374400000")
  assert_eq(d5_iso("2026-10-07T12:00:00.5Z"), "1791374400500")
  assert_eq(d5_iso("2026-10-07T12:00:00.523+05:30"), "1791354600523")
  assert_eq(d5_iso("2026-10-07T12:00:00+00:00"), "1791374400000")
}

///|
test "date RFC 3339 严格档：五个报错位置（本库形状，参照列在旁边）" {
  // 小数点后零位数字：RFC 3339 §5.6 写的是 `time-secfrac = "." 1*DIGIT` ⇒ 本库拒并报在小数点之后那一格；
  // 参照 JDK 给 1791345600000（**接受**，比 RFC 宽松）⇒ 本库更严，不是不一致
  assert_eq(
    d5_iso("2026-10-07T12:00:00.+08:00"),
    "ParseFailed 2026-10-07T12:00:00.+08:00@20",
  )
  // `Z` 之后还有字符：参照同样拒（DateTimeParseException），本库报在**那个多余字符自己**那格
  // （`Z` 落在下标 19，所以报 20 —— 第一次推导写成了 21，被真跑打回）
  assert_eq(
    d5_iso("2026-10-07T12:00:00Zx"),
    "ParseFailed 2026-10-07T12:00:00Zx@20",
  )
  // 偏移位不是 Z/+/-：参照拒，本库报在**那一格自己**（`"2026-10-07T12:00:00"` 占 0..18，
  // 所以 X 在下标 19 —— 第一次推导按 20 算，被真跑打回）
  assert_eq(
    d5_iso("2026-10-07T12:00:00X"),
    "ParseFailed 2026-10-07T12:00:00X@19",
  )
  // 缺秒：RFC 3339 的 `time = hour ":" minute ":" second` 是必填 ⇒ 本库拒并报在该出现 `:` 的位置；
  // 参照 JDK 给 1791392400000（**接受**缺秒）⇒ 又是"本库更严"那一档
  assert_eq(
    d5_iso("2026-10-07T12:00-05:00"),
    "ParseFailed 2026-10-07T12:00-05:00@16",
  )
  // 小时偏移越界：两侧都拒（参照 DateTimeParseException），本库报在**偏移起始那一格**（`+` 在 19）
  assert_eq(
    d5_iso("2026-10-07T12:00:00+24:00"),
    "ParseFailed 2026-10-07T12:00:00+24:00@19",
  )
}

///|
test "date RFC 3339 的小数点分隔符并集档：本库收逗号、JDK 只收点" {
  // ISO 8601 的小数分隔符允许 `,`，RFC 3339 只写 `.` ⇒ 本库取两者并集（`from_rfc3339` 的那一步）。
  // 参照 JDK 对同串给 DateTimeParseException ⇒ 这一档是**明写的多收**，写进 §9 的分岔表
  assert_eq(d5_iso("2026-10-07T12:00:00,52+05:30"), "1791354600520")
  assert_eq(d5_iso("2026-10-07T12:00:00,5Z"), "1791374400500")
}

///|
test "date pattern 的引号档：'' 是一个单引号本身、未闭合的引号判 ParseFailed" {
  // SimpleDateFormat("''") 现读给 `'`（腿 P 行 qq）⇒ 同判；`'x'` 给 `x`（qq_lit 那行）
  let d = @date.Date::of(2026, 10, 7)
  assert_eq(d5_fmt_date(d, "''"), "'")
  assert_eq(d5_fmt_date(d, "'x'"), "x")
  assert_eq(d5_fmt_date(d, "yyyy'x'"), "2026x")
  // 未闭合的引号：参照 SimpleDateFormat 抛 IllegalArgumentException（也拒，但类型/位置不是契约）
  // ⇒ 钉本库形状：报在那个引号自己那格（pattern "yyyy'" 的引号在下标 4）
  assert_eq(d5_fmt_date(d, "yyyy'"), "ParseFailed yyyy'@4")
}

///|
test "date 时间字段用在纯日期上：本库判不支持、参照给零值" {
  // `Date` 类型本身不带时间 ⇒ 本库不猜 00:00:00；参照 `SimpleDateFormat("HH:mm:ss").format(date)`
  // 现读给 `00:00:00`（腿 P 行 time_on_date）⇒ 这是"本库少给"那一档，依据见 §2 的类型形状决定。
  // 注：这条红落在 `check_pattern` 的 `!allow_time && k >= 5` 那一档（date.mbt:914/915），
  // **不是** `write_field` 里的 `None => raise`（:970）——后者结构上到不了，推导见 §9 末段
  assert_eq(
    d5_fmt_date(@date.Date::of(2026, 10, 7), "HH:mm:ss"),
    "UnknownPatternToken HH",
  )
  // 对照：同一 pattern 挂在 DateTime 上是正常读数
  let dt = @date.DateTime::of(@date.Date::of(2026, 10, 7), 12, 30, 45, 500)
  assert_eq(dt.format("HH:mm:ss"), "12:30:45")
}

///|
test "date 解析侧的重复字段判不支持、格式化侧允许" {
  // 参照 SimpleDateFormat 在**格式化**侧允许重复（腿 P 行 dup 现读 "2026-10-07-2026"）⇒ 同判；
  // 解析侧本库判 UnknownPatternToken：同一字段出现两次时"后者覆盖前者"是参照的静默行为，
  // 而一个解析 pattern 里出现两个年/两个月本身就是歧义，本库不静默采纳任何一侧
  assert_eq(
    d5_fmt_date(@date.Date::of(2026, 10, 7), "yyyy-MM-dd-yyyy"),
    "2026-10-07-2026",
  )
  assert_eq(
    d5_parse_date("2026-10-07-2026", "yyyy-MM-dd-yyyy"),
    "UnknownPatternToken yyyy",
  )
}

///|
test "date 的 M/d 档贪婪吃两位数字、非数字位报在下标" {
  // 1~2 位档（`M`/`d`/`H`/`m`/`s`）：先试两位、不成再退一位 ⇒ "10" 读成 10 而不是 1
  assert_eq(d5_parse_date("2026/10/7", "yyyy/M/d"), "2026-10-07")
  assert_eq(d5_parse_date("2026/1/7", "yyyy/M/d"), "2026-01-07")
  assert_eq(d5_parse_date("2026/12/31", "yyyy/M/d"), "2026-12-31")
  // 该出数字的地方不是数字 ⇒ ParseFailed 报在**那一格**
  assert_eq(d5_parse_date("2026/ab", "yyyy/M"), "ParseFailed 2026/ab@5")
  assert_eq(d5_parse_date("2026/", "yyyy/M"), "ParseFailed 2026/@5")
}

///|
test "date zone_offset_minutes 的窗口下沿档（窗外一律 None、不向外推）" {
  // 窗口是 `[tbl_window_lo, tbl_window_hi)` = `[0, 2524608000000)`（现读 zone_table.mbt 的两个常数），
  // 所以"窗口内但该区首段还没开始"这一支（zone.mbt:127）**公开面到不了**：
  // 探针实测 603 个区在 millis=0 与 millis=1 两档都给出读数、零个 `None`（临时件跑完即删）。
  // 本块钉的是"窗外一律 None"这一档——参照侧不存在对位物（JDK `ZoneRules` 对表外时刻回退到固定偏移），
  // 所以"不向外推"是决定不是读数
  assert_eq(@date.zone_offset_minutes("Asia/Shanghai", -300000000000000L), None)
  assert_eq(@date.zone_offset_minutes("Asia/Shanghai", -1L), None)
  // 对照：同一区在窗口内两端都有读数
  assert_eq(@date.zone_offset_minutes("Asia/Shanghai", 0L), Some(480))
}
