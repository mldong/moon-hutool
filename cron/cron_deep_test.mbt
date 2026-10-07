///|
// cron 深分支补档（10-07）——别名解析、月末夹取、月/年进位、错误通道四族，
// 期望全部由 Cron3Leg.java 现读灌入（hutool-all 5.8.37 · JDK 17 · 每条先 setDefault(区)），手打零条。
// nextDateAfter(N) 与 nextMatch(N2) 在本批全部同值 ⇒ 两张嘴各钉一次；分岔登记不钉。

///|
// 只问抛不抛：本包既有件不把 CronError 的构造细节给到测试侧，这里钉形状不钉档名
fn deep_tag_of(p : String) -> String {
  try {
    let _ = @cron.cron_of(p)
    "OK"
  } catch {
    _ => "RAISE"
  }
}

///|
test "cron 深分支 al-april" {
  // parse-ok ｜ pattern=0 0 1 april * ｜ base=1706736000000
  assert_eq(deep_tag_of("0 0 1 april *"), "OK")
  // cron_next_match_after_in ｜ pattern=0 0 1 april * ｜ base=1706736000000
  assert_eq(
    @cron.cron_next_match_after_in(
      @cron.cron_of("0 0 1 april *"),
      "UTC",
      1706736000000L,
    ),
    Some(1711929600000L),
  )
  // cron_next_match_in ｜ pattern=0 0 1 april * ｜ base=1706736000000
  assert_eq(
    @cron.cron_next_match_in(
      @cron.cron_of("0 0 1 april *"),
      "UTC",
      1706736000000L,
    ),
    Some(1711929600000L),
  )
}

///|
test "cron 深分支 al-feb" {
  // parse-ok ｜ pattern=0 0 1 feb * ｜ base=1706736000000
  assert_eq(deep_tag_of("0 0 1 feb *"), "OK")
  // cron_next_match_after_in ｜ pattern=0 0 1 feb * ｜ base=1706736000000
  assert_eq(
    @cron.cron_next_match_after_in(
      @cron.cron_of("0 0 1 feb *"),
      "UTC",
      1706736000000L,
    ),
    Some(1706745600000L),
  )
  // cron_next_match_in ｜ pattern=0 0 1 feb * ｜ base=1706736000000
  assert_eq(
    @cron.cron_next_match_in(
      @cron.cron_of("0 0 1 feb *"),
      "UTC",
      1706736000000L,
    ),
    Some(1706745600000L),
  )
}

///|
test "cron 深分支 al-january" {
  // parse-ok ｜ pattern=0 0 1 january ? ｜ base=1707000000000
  assert_eq(deep_tag_of("0 0 1 january ?"), "OK")
  // cron_next_match_after_in ｜ pattern=0 0 1 january ? ｜ base=1707000000000
  assert_eq(
    @cron.cron_next_match_after_in(
      @cron.cron_of("0 0 1 january ?"),
      "UTC",
      1707000000000L,
    ),
    Some(1735689600000L),
  )
  // cron_next_match_in ｜ pattern=0 0 1 january ? ｜ base=1707000000000
  assert_eq(
    @cron.cron_next_match_in(
      @cron.cron_of("0 0 1 january ?"),
      "UTC",
      1707000000000L,
    ),
    Some(1735689600000L),
  )
}

///|
test "cron 深分支 al-sat-range" {
  // parse-ok ｜ pattern=0 0 12 * SAT-SUN ｜ base=1717372800000
  assert_eq(deep_tag_of("0 0 12 * SAT-SUN"), "OK")
  // cron_next_match_after_in ｜ pattern=0 0 12 * SAT-SUN ｜ base=1717372800000
  assert_eq(
    @cron.cron_next_match_after_in(
      @cron.cron_of("0 0 12 * SAT-SUN"),
      "UTC",
      1717372800000L,
    ),
    Some(1728691200000L),
  )
  // cron_next_match_in ｜ pattern=0 0 12 * SAT-SUN ｜ base=1717372800000
  assert_eq(
    @cron.cron_next_match_in(
      @cron.cron_of("0 0 12 * SAT-SUN"),
      "UTC",
      1717372800000L,
    ),
    Some(1728691200000L),
  )
}

///|
test "cron 深分支 al-tue" {
  // parse-ok ｜ pattern=0 0 12 * tue ｜ base=1717372800000
  assert_eq(deep_tag_of("0 0 12 * tue"), "OK")
  // cron_next_match_after_in ｜ pattern=0 0 12 * tue ｜ base=1717372800000
  assert_eq(
    @cron.cron_next_match_after_in(
      @cron.cron_of("0 0 12 * tue"),
      "UTC",
      1717372800000L,
    ),
    Some(1731369600000L),
  )
  // cron_next_match_in ｜ pattern=0 0 12 * tue ｜ base=1717372800000
  assert_eq(
    @cron.cron_next_match_in(
      @cron.cron_of("0 0 12 * tue"),
      "UTC",
      1717372800000L,
    ),
    Some(1731369600000L),
  )
}

///|
test "cron 深分支 clamp-31feb" {
  // parse-ok ｜ pattern=0 0 12 31 2 ? ｜ base=1704070000000
  assert_eq(deep_tag_of("0 0 12 31 2 ?"), "OK")
  // cron_next_match_after_in ｜ pattern=0 0 12 31 2 ? ｜ base=1704070000000
  assert_eq(
    @cron.cron_next_match_after_in(
      @cron.cron_of("0 0 12 31 2 ?"),
      "UTC",
      1704070000000L,
    ),
    Some(1709208000000L),
  )
  // cron_next_match_in ｜ pattern=0 0 12 31 2 ? ｜ base=1704070000000
  assert_eq(
    @cron.cron_next_match_in(
      @cron.cron_of("0 0 12 31 2 ?"),
      "UTC",
      1704070000000L,
    ),
    Some(1709208000000L),
  )
}

///|
test "cron 深分支 day31-apr" {
  // parse-ok ｜ pattern=0 0 12 31 4 * ｜ base=1704070000000
  assert_eq(deep_tag_of("0 0 12 31 4 *"), "OK")
  // cron_next_match_after_in ｜ pattern=0 0 12 31 4 * ｜ base=1704070000000
  assert_eq(
    @cron.cron_next_match_after_in(
      @cron.cron_of("0 0 12 31 4 *"),
      "UTC",
      1704070000000L,
    ),
    Some(1714478400000L),
  )
  // cron_next_match_in ｜ pattern=0 0 12 31 4 * ｜ base=1704070000000
  assert_eq(
    @cron.cron_next_match_in(
      @cron.cron_of("0 0 12 31 4 *"),
      "UTC",
      1704070000000L,
    ),
    Some(1714478400000L),
  )
}

///|
test "cron 深分支 e-day-L" {
  // parse-raises ｜ pattern=0 0 15L * ? ｜ base=1704070000000
  assert_eq(deep_tag_of("0 0 15L * ?"), "RAISE")
}

///|
test "cron 深分支 e-day32" {
  // parse-raises ｜ pattern=0 0 32 * * ｜ base=1704070000000
  assert_eq(deep_tag_of("0 0 32 * *"), "RAISE")
}

///|
test "cron 深分支 e-min61" {
  // parse-raises ｜ pattern=0 61 * * * ｜ base=1704070000000
  assert_eq(deep_tag_of("0 61 * * *"), "RAISE")
}

///|
test "cron 深分支 e-month13" {
  // parse-raises ｜ pattern=0 0 1 13 * ｜ base=1704070000000
  assert_eq(deep_tag_of("0 0 1 13 *"), "RAISE")
}

///|
test "cron 深分支 e-sec61" {
  // parse-raises ｜ pattern=61 * * * * * ｜ base=1704070000000
  assert_eq(deep_tag_of("61 * * * * *"), "RAISE")
}

///|
test "cron 深分支 e-step0" {
  // parse-raises ｜ pattern=0/0 * * * * ｜ base=1704070000000
  assert_eq(deep_tag_of("0/0 * * * *"), "RAISE")
}

///|
test "cron 深分支 e-wday-L" {
  // parse-raises ｜ pattern=0 0 1 ? * 5L ｜ base=1704070000000
  assert_eq(deep_tag_of("0 0 1 ? * 5L"), "RAISE")
}

///|
test "cron 深分支 e-year-badtok" {
  // parse-raises ｜ pattern=0 0 1 1 ? 20x4 ｜ base=1704070000000
  assert_eq(deep_tag_of("0 0 1 1 ? 20x4"), "RAISE")
}

///|
test "cron 深分支 e-year-out" {
  // parse-raises ｜ pattern=0 0 1 1 ? 2100 ｜ base=1704070000000
  assert_eq(deep_tag_of("0 0 1 1 ? 2100"), "RAISE")
}

///|
test "cron 深分支 leap-29feb" {
  // parse-ok ｜ pattern=0 0 29 2 * ｜ base=1704070000000
  assert_eq(deep_tag_of("0 0 29 2 *"), "OK")
  // cron_next_match_after_in ｜ pattern=0 0 29 2 * ｜ base=1704070000000
  assert_eq(
    @cron.cron_next_match_after_in(
      @cron.cron_of("0 0 29 2 *"),
      "UTC",
      1704070000000L,
    ),
    Some(1709164800000L),
  )
  // cron_next_match_in ｜ pattern=0 0 29 2 * ｜ base=1704070000000
  assert_eq(
    @cron.cron_next_match_in(@cron.cron_of("0 0 29 2 *"), "UTC", 1704070000000L),
    Some(1709164800000L),
  )
}

///|
test "cron 深分支 wrap12" {
  // parse-ok ｜ pattern=0 0 1 1 * ? ｜ base=1592200000000
  assert_eq(deep_tag_of("0 0 1 1 * ?"), "OK")
  // cron_next_match_after_in ｜ pattern=0 0 1 1 * ? ｜ base=1592200000000
  assert_eq(
    @cron.cron_next_match_after_in(
      @cron.cron_of("0 0 1 1 * ?"),
      "UTC",
      1592200000000L,
    ),
    Some(1593565200000L),
  )
  // cron_next_match_in ｜ pattern=0 0 1 1 * ? ｜ base=1592200000000
  assert_eq(
    @cron.cron_next_match_in(
      @cron.cron_of("0 0 1 1 * ?"),
      "UTC",
      1592200000000L,
    ),
    Some(1593565200000L),
  )
}
