///|
// cron 区窗与解析档补档（10-08）——别名两档、负步进回绕、列表内通配、零填充步进、三类语法错、
// BadAlias 三档、年列表乱序、`|` 多子表达式、count 非正与坏区名两档、空洞/重叠三档。
// 期望全部由 Cron4Leg.java 现读灌入（hutool-cron 5.8.35 · JDK 17.0.14 · 每条先 setDefault(区)），手打零条。
// 腿只授权"抛不抛"，不授权 CronError 的变体名 ⇒ 错误档一律钉 OK/RAISE 形状，原文消息留在注释。
// 本库自订档（count 非正、坏区名）按 spec 19-cron §11 的改判钉本库形状，腿的原读数同样留在注释。

///|
fn z4_join(arr : Array[Int64]) -> String {
  let mut s = ""
  for v in arr {
    if s.length() > 0 {
      s = s + ";"
    }
    s = s + v.to_string()
  }
  if s == "" {
    "-"
  } else {
    s
  }
}

///|
fn z4_md(
  pat : String,
  zone : String,
  start : Int64,
  end : Int64,
  count : Int,
) -> String {
  try {
    let c = @cron.cron_of(pat)
    match @cron.cron_matched_dates(c, zone, start, end, count, false) {
      None => "NOWINDOW"
      Some(arr) => z4_join(arr)
    }
  } catch {
    _ => "ERR"
  }
}

///|
fn z4_after(pat : String, zone : String, base : Int64) -> String {
  try {
    match @cron.cron_next_match_after_in(@cron.cron_of(pat), zone, base) {
      None => "NOWINDOW"
      Some(v) => v.to_string()
    }
  } catch {
    _ => "ERR"
  }
}

///|
fn z4_next(pat : String, zone : String, base : Int64) -> String {
  try {
    match @cron.cron_next_match_in(@cron.cron_of(pat), zone, base) {
      None => "NOWINDOW"
      Some(v) => v.to_string()
    }
  } catch {
    _ => "ERR"
  }
}

///|
fn z4_tag(pat : String) -> String {
  try {
    let _ = @cron.cron_of(pat)
    "OK"
  } catch {
    _ => "RAISE"
  }
}

///|
fn z4_text(pat : String) -> String {
  @cron.cron_pattern_text(@cron.cron_of(pat)) catch {
    _ => "RAISE"
  }
}

///|
test "cron 区窗 al-may C" {
  // cron_of ｜ pattern=0 12 ? MAY * ｜ 参照=RET 0 12 ? MAY *
  assert_eq(z4_tag("0 12 ? MAY *"), "OK")
}

///|
test "cron 区窗 al-may T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? MAY *
  assert_eq(z4_text("0 12 ? MAY *"), "0 12 ? MAY *")
}

///|
test "cron 区窗 al-may M" {
  // matched_dates ｜ pattern=0 12 ? MAY * ｜ zone=UTC ｜ [1714521600000,1715126400000) ｜ count=10 ｜ 参照=RET 1714564800000;1714651200000;1714737600000;1714824000000;1714910400000;1714996800000;1715083200000
  assert_eq(
    z4_md("0 12 ? MAY *", "UTC", 1714521600000L, 1715126400000L, 10),
    "1714564800000;1714651200000;1714737600000;1714824000000;1714910400000;1714996800000;1715083200000",
  )
}

///|
test "cron 区窗 al-may N" {
  // z4_after ｜ pattern=0 12 ? MAY * ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_after("0 12 ? MAY *", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 al-may N2" {
  // z4_next ｜ pattern=0 12 ? MAY * ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_next("0 12 ? MAY *", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 al-may-num C" {
  // cron_of ｜ pattern=0 12 ? 5 * ｜ 参照=RET 0 12 ? 5 *
  assert_eq(z4_tag("0 12 ? 5 *"), "OK")
}

///|
test "cron 区窗 al-may-num T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? 5 *
  assert_eq(z4_text("0 12 ? 5 *"), "0 12 ? 5 *")
}

///|
test "cron 区窗 al-may-num M" {
  // matched_dates ｜ pattern=0 12 ? 5 * ｜ zone=UTC ｜ [1714521600000,1715126400000) ｜ count=10 ｜ 参照=RET 1714564800000;1714651200000;1714737600000;1714824000000;1714910400000;1714996800000;1715083200000
  assert_eq(
    z4_md("0 12 ? 5 *", "UTC", 1714521600000L, 1715126400000L, 10),
    "1714564800000;1714651200000;1714737600000;1714824000000;1714910400000;1714996800000;1715083200000",
  )
}

///|
test "cron 区窗 al-may-num N" {
  // z4_after ｜ pattern=0 12 ? 5 * ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_after("0 12 ? 5 *", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 al-may-num N2" {
  // z4_next ｜ pattern=0 12 ? 5 * ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_next("0 12 ? 5 *", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 al-may-mixed C" {
  // cron_of ｜ pattern=0 12 ? May * ｜ 参照=RET 0 12 ? May *
  assert_eq(z4_tag("0 12 ? May *"), "OK")
}

///|
test "cron 区窗 al-may-mixed T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? May *
  assert_eq(z4_text("0 12 ? May *"), "0 12 ? May *")
}

///|
test "cron 区窗 al-may-mixed M" {
  // matched_dates ｜ pattern=0 12 ? May * ｜ zone=UTC ｜ [1714521600000,1715126400000) ｜ count=10 ｜ 参照=RET 1714564800000;1714651200000;1714737600000;1714824000000;1714910400000;1714996800000;1715083200000
  assert_eq(
    z4_md("0 12 ? May *", "UTC", 1714521600000L, 1715126400000L, 10),
    "1714564800000;1714651200000;1714737600000;1714824000000;1714910400000;1714996800000;1715083200000",
  )
}

///|
test "cron 区窗 al-may-mixed N" {
  // z4_after ｜ pattern=0 12 ? May * ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_after("0 12 ? May *", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 al-may-mixed N2" {
  // z4_next ｜ pattern=0 12 ? May * ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_next("0 12 ? May *", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 al-wed C" {
  // cron_of ｜ pattern=0 12 * * WED ｜ 参照=RET 0 12 * * WED
  assert_eq(z4_tag("0 12 * * WED"), "OK")
}

///|
test "cron 区窗 al-wed T" {
  // cron_pattern_text ｜ 参照 toString=0 12 * * WED
  assert_eq(z4_text("0 12 * * WED"), "0 12 * * WED")
}

///|
test "cron 区窗 al-wed M" {
  // matched_dates ｜ pattern=0 12 * * WED ｜ zone=UTC ｜ [1714521600000,1715126400000) ｜ count=10 ｜ 参照=RET 1714564800000
  assert_eq(
    z4_md("0 12 * * WED", "UTC", 1714521600000L, 1715126400000L, 10),
    "1714564800000",
  )
}

///|
test "cron 区窗 al-wed N" {
  // z4_after ｜ pattern=0 12 * * WED ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_after("0 12 * * WED", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 al-wed N2" {
  // z4_next ｜ pattern=0 12 * * WED ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_next("0 12 * * WED", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 al-wed-num C" {
  // cron_of ｜ pattern=0 12 * * 3 ｜ 参照=RET 0 12 * * 3
  assert_eq(z4_tag("0 12 * * 3"), "OK")
}

///|
test "cron 区窗 al-wed-num T" {
  // cron_pattern_text ｜ 参照 toString=0 12 * * 3
  assert_eq(z4_text("0 12 * * 3"), "0 12 * * 3")
}

///|
test "cron 区窗 al-wed-num M" {
  // matched_dates ｜ pattern=0 12 * * 3 ｜ zone=UTC ｜ [1714521600000,1715126400000) ｜ count=10 ｜ 参照=RET 1714564800000
  assert_eq(
    z4_md("0 12 * * 3", "UTC", 1714521600000L, 1715126400000L, 10),
    "1714564800000",
  )
}

///|
test "cron 区窗 al-wed-num N" {
  // z4_after ｜ pattern=0 12 * * 3 ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_after("0 12 * * 3", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 al-wed-num N2" {
  // z4_next ｜ pattern=0 12 * * 3 ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_next("0 12 * * 3", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 al-wed-full C" {
  // cron_of ｜ pattern=0 12 * * wednesday ｜ 参照=RET 0 12 * * wednesday
  assert_eq(z4_tag("0 12 * * wednesday"), "OK")
}

///|
test "cron 区窗 al-wed-full T" {
  // cron_pattern_text ｜ 参照 toString=0 12 * * wednesday
  assert_eq(z4_text("0 12 * * wednesday"), "0 12 * * wednesday")
}

///|
test "cron 区窗 al-wed-full M" {
  // matched_dates ｜ pattern=0 12 * * wednesday ｜ zone=UTC ｜ [1714521600000,1715126400000) ｜ count=10 ｜ 参照=RET 1714564800000
  assert_eq(
    z4_md("0 12 * * wednesday", "UTC", 1714521600000L, 1715126400000L, 10),
    "1714564800000",
  )
}

///|
test "cron 区窗 al-wed-full N" {
  // z4_after ｜ pattern=0 12 * * wednesday ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(
    z4_after("0 12 * * wednesday", "UTC", 1714521600000L),
    "1714564800000",
  )
}

///|
test "cron 区窗 al-wed-full N2" {
  // z4_next ｜ pattern=0 12 * * wednesday ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(
    z4_next("0 12 * * wednesday", "UTC", 1714521600000L),
    "1714564800000",
  )
}

///|
test "cron 区窗 step-neg1 C" {
  // cron_of ｜ pattern=0/-1 * * * * ｜ 参照=RET 0/-1 * * * *
  assert_eq(z4_tag("0/-1 * * * *"), "OK")
}

///|
test "cron 区窗 step-neg1 T" {
  // cron_pattern_text ｜ 参照 toString=0/-1 * * * *
  assert_eq(z4_text("0/-1 * * * *"), "0/-1 * * * *")
}

///|
test "cron 区窗 step-neg1 M" {
  // matched_dates ｜ pattern=0/-1 * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=60 ｜ 参照=RET 1704067200000;1704070680000
  assert_eq(
    z4_md("0/-1 * * * *", "UTC", 1704067200000L, 1704070800000L, 60),
    "1704067200000;1704070680000",
  )
}

///|
test "cron 区窗 step-neg1 N" {
  // z4_after ｜ pattern=0/-1 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 1704070680000
  assert_eq(z4_after("0/-1 * * * *", "UTC", 1704067200000L), "1704070680000")
}

///|
test "cron 区窗 step-58 C" {
  // cron_of ｜ pattern=0/58 * * * * ｜ 参照=RET 0/58 * * * *
  assert_eq(z4_tag("0/58 * * * *"), "OK")
}

///|
test "cron 区窗 step-58 T" {
  // cron_pattern_text ｜ 参照 toString=0/58 * * * *
  assert_eq(z4_text("0/58 * * * *"), "0/58 * * * *")
}

///|
test "cron 区窗 step-58 M" {
  // matched_dates ｜ pattern=0/58 * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=60 ｜ 参照=RET 1704067200000;1704070680000
  assert_eq(
    z4_md("0/58 * * * *", "UTC", 1704067200000L, 1704070800000L, 60),
    "1704067200000;1704070680000",
  )
}

///|
test "cron 区窗 step-58 N" {
  // z4_after ｜ pattern=0/58 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 1704070680000
  assert_eq(z4_after("0/58 * * * *", "UTC", 1704067200000L), "1704070680000")
}

///|
test "cron 区窗 step-neg5 C" {
  // cron_of ｜ pattern=5/-1 * * * * ｜ 参照=RET 5/-1 * * * *
  assert_eq(z4_tag("5/-1 * * * *"), "OK")
}

///|
test "cron 区窗 step-neg5 T" {
  // cron_pattern_text ｜ 参照 toString=5/-1 * * * *
  assert_eq(z4_text("5/-1 * * * *"), "5/-1 * * * *")
}

///|
test "cron 区窗 step-neg5 M" {
  // matched_dates ｜ pattern=5/-1 * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=60 ｜ 参照=RET 1704067500000
  assert_eq(
    z4_md("5/-1 * * * *", "UTC", 1704067200000L, 1704070800000L, 60),
    "1704067500000",
  )
}

///|
test "cron 区窗 step-neg5 N" {
  // z4_after ｜ pattern=5/-1 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 1704067500000
  assert_eq(z4_after("5/-1 * * * *", "UTC", 1704067200000L), "1704067500000")
}

///|
test "cron 区窗 step-neg5 N2" {
  // z4_next ｜ pattern=5/-1 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 1704067500000
  assert_eq(z4_next("5/-1 * * * *", "UTC", 1704067200000L), "1704067500000")
}

///|
test "cron 区窗 star-list C" {
  // cron_of ｜ pattern=0,* * * * * ｜ 参照=RET 0,* * * * *
  assert_eq(z4_tag("0,* * * * *"), "OK")
}

///|
test "cron 区窗 star-list T" {
  // cron_pattern_text ｜ 参照 toString=0,* * * * *
  assert_eq(z4_text("0,* * * * *"), "0,* * * * *")
}

///|
test "cron 区窗 star-list M" {
  // matched_dates ｜ pattern=0,* * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=60 ｜ 参照=RET 1704067200000;1704067260000;1704067320000;1704067380000;1704067440000;1704067500000;1704067560000;1704067620000;1704067680000;1704067740000;1704067800000;1704067860000;1704067920000;1704067980000;1704068040000;1704068100000;1704068160000;1704068220000;1704068280000;1704068340000;1704068400000;1704068460000;1704068520000;1704068580000;1704068640000;1704068700000;1704068760000;1704068820000;1704068880000;1704068940000;1704069000000;1704069060000;1704069120000;1704069180000;1704069240000;1704069300000;1704069360000;1704069420000;1704069480000;1704069540000;1704069600000;1704069660000;1704069720000;1704069780000;1704069840000;1704069900000;1704069960000;1704070020000;1704070080000;1704070140000;1704070200000;1704070260000;1704070320000;1704070380000;1704070440000;1704070500000;1704070560000;1704070620000;1704070680000;1704070740000
  assert_eq(
    z4_md("0,* * * * *", "UTC", 1704067200000L, 1704070800000L, 60),
    "1704067200000;1704067260000;1704067320000;1704067380000;1704067440000;1704067500000;1704067560000;1704067620000;1704067680000;1704067740000;1704067800000;1704067860000;1704067920000;1704067980000;1704068040000;1704068100000;1704068160000;1704068220000;1704068280000;1704068340000;1704068400000;1704068460000;1704068520000;1704068580000;1704068640000;1704068700000;1704068760000;1704068820000;1704068880000;1704068940000;1704069000000;1704069060000;1704069120000;1704069180000;1704069240000;1704069300000;1704069360000;1704069420000;1704069480000;1704069540000;1704069600000;1704069660000;1704069720000;1704069780000;1704069840000;1704069900000;1704069960000;1704070020000;1704070080000;1704070140000;1704070200000;1704070260000;1704070320000;1704070380000;1704070440000;1704070500000;1704070560000;1704070620000;1704070680000;1704070740000",
  )
}

///|
test "cron 区窗 star-list N" {
  // z4_after ｜ pattern=0,* * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 1704067260000
  assert_eq(z4_after("0,* * * * *", "UTC", 1704067200000L), "1704067260000")
}

///|
test "cron 区窗 star-list2 C" {
  // cron_of ｜ pattern=0,? * * * * ｜ 参照=RET 0,? * * * *
  assert_eq(z4_tag("0,? * * * *"), "OK")
}

///|
test "cron 区窗 star-list2 T" {
  // cron_pattern_text ｜ 参照 toString=0,? * * * *
  assert_eq(z4_text("0,? * * * *"), "0,? * * * *")
}

///|
test "cron 区窗 star-list2 M" {
  // matched_dates ｜ pattern=0,? * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=60 ｜ 参照=RET 1704067200000;1704067260000;1704067320000;1704067380000;1704067440000;1704067500000;1704067560000;1704067620000;1704067680000;1704067740000;1704067800000;1704067860000;1704067920000;1704067980000;1704068040000;1704068100000;1704068160000;1704068220000;1704068280000;1704068340000;1704068400000;1704068460000;1704068520000;1704068580000;1704068640000;1704068700000;1704068760000;1704068820000;1704068880000;1704068940000;1704069000000;1704069060000;1704069120000;1704069180000;1704069240000;1704069300000;1704069360000;1704069420000;1704069480000;1704069540000;1704069600000;1704069660000;1704069720000;1704069780000;1704069840000;1704069900000;1704069960000;1704070020000;1704070080000;1704070140000;1704070200000;1704070260000;1704070320000;1704070380000;1704070440000;1704070500000;1704070560000;1704070620000;1704070680000;1704070740000
  assert_eq(
    z4_md("0,? * * * *", "UTC", 1704067200000L, 1704070800000L, 60),
    "1704067200000;1704067260000;1704067320000;1704067380000;1704067440000;1704067500000;1704067560000;1704067620000;1704067680000;1704067740000;1704067800000;1704067860000;1704067920000;1704067980000;1704068040000;1704068100000;1704068160000;1704068220000;1704068280000;1704068340000;1704068400000;1704068460000;1704068520000;1704068580000;1704068640000;1704068700000;1704068760000;1704068820000;1704068880000;1704068940000;1704069000000;1704069060000;1704069120000;1704069180000;1704069240000;1704069300000;1704069360000;1704069420000;1704069480000;1704069540000;1704069600000;1704069660000;1704069720000;1704069780000;1704069840000;1704069900000;1704069960000;1704070020000;1704070080000;1704070140000;1704070200000;1704070260000;1704070320000;1704070380000;1704070440000;1704070500000;1704070560000;1704070620000;1704070680000;1704070740000",
  )
}

///|
test "cron 区窗 star-list2 N" {
  // z4_after ｜ pattern=0,? * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 1704067260000
  assert_eq(z4_after("0,? * * * *", "UTC", 1704067200000L), "1704067260000")
}

///|
test "cron 区窗 pad-step C" {
  // cron_of ｜ pattern=000/5 * * * * ｜ 参照=RET 000/5 * * * *
  assert_eq(z4_tag("000/5 * * * *"), "OK")
}

///|
test "cron 区窗 pad-step T" {
  // cron_pattern_text ｜ 参照 toString=000/5 * * * *
  assert_eq(z4_text("000/5 * * * *"), "000/5 * * * *")
}

///|
test "cron 区窗 pad-step M" {
  // matched_dates ｜ pattern=000/5 * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=60 ｜ 参照=RET 1704067200000;1704067500000;1704067800000;1704068100000;1704068400000;1704068700000;1704069000000;1704069300000;1704069600000;1704069900000;1704070200000;1704070500000
  assert_eq(
    z4_md("000/5 * * * *", "UTC", 1704067200000L, 1704070800000L, 60),
    "1704067200000;1704067500000;1704067800000;1704068100000;1704068400000;1704068700000;1704069000000;1704069300000;1704069600000;1704069900000;1704070200000;1704070500000",
  )
}

///|
test "cron 区窗 pad-step N" {
  // z4_after ｜ pattern=000/5 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 1704067500000
  assert_eq(z4_after("000/5 * * * *", "UTC", 1704067200000L), "1704067500000")
}

///|
test "cron 区窗 plain-step C" {
  // cron_of ｜ pattern=0/5 * * * * ｜ 参照=RET 0/5 * * * *
  assert_eq(z4_tag("0/5 * * * *"), "OK")
}

///|
test "cron 区窗 plain-step T" {
  // cron_pattern_text ｜ 参照 toString=0/5 * * * *
  assert_eq(z4_text("0/5 * * * *"), "0/5 * * * *")
}

///|
test "cron 区窗 plain-step M" {
  // matched_dates ｜ pattern=0/5 * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=60 ｜ 参照=RET 1704067200000;1704067500000;1704067800000;1704068100000;1704068400000;1704068700000;1704069000000;1704069300000;1704069600000;1704069900000;1704070200000;1704070500000
  assert_eq(
    z4_md("0/5 * * * *", "UTC", 1704067200000L, 1704070800000L, 60),
    "1704067200000;1704067500000;1704067800000;1704068100000;1704068400000;1704068700000;1704069000000;1704069300000;1704069600000;1704069900000;1704070200000;1704070500000",
  )
}

///|
test "cron 区窗 plain-step N" {
  // z4_after ｜ pattern=0/5 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 1704067500000
  assert_eq(z4_after("0/5 * * * *", "UTC", 1704067200000L), "1704067500000")
}

///|
test "cron 区窗 pad-step-h C" {
  // cron_of ｜ pattern=0 008 * * * ｜ 参照=RET 0 008 * * *
  assert_eq(z4_tag("0 008 * * *"), "OK")
}

///|
test "cron 区窗 pad-step-h T" {
  // cron_pattern_text ｜ 参照 toString=0 008 * * *
  assert_eq(z4_text("0 008 * * *"), "0 008 * * *")
}

///|
test "cron 区窗 pad-step-h M" {
  // matched_dates ｜ pattern=0 008 * * * ｜ zone=UTC ｜ [1704067200000,1704153600000) ｜ count=60 ｜ 参照=RET 1704096000000
  assert_eq(
    z4_md("0 008 * * *", "UTC", 1704067200000L, 1704153600000L, 60),
    "1704096000000",
  )
}

///|
test "cron 区窗 pad-step-h N" {
  // z4_after ｜ pattern=0 008 * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 1704096000000
  assert_eq(z4_after("0 008 * * *", "UTC", 1704067200000L), "1704096000000")
}

///|
test "cron 区窗 pad-step-h N2" {
  // z4_next ｜ pattern=0 008 * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 1704096000000
  assert_eq(z4_next("0 008 * * *", "UTC", 1704067200000L), "1704096000000")
}

///|
test "cron 区窗 e-dash3 C" {
  // cron_of ｜ pattern=1-2-3 * * * * ｜ 参照=ERR:CronException Invalid syntax of field: [1-2-3]
  assert_eq(z4_tag("1-2-3 * * * *"), "RAISE")
}

///|
test "cron 区窗 e-dash3 M" {
  // matched_dates ｜ pattern=1-2-3 * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=10 ｜ 参照=ERR:CronException Invalid syntax of field: [1-2-3]
  assert_eq(
    z4_md("1-2-3 * * * *", "UTC", 1704067200000L, 1704070800000L, 10),
    "ERR",
  )
}

///|
test "cron 区窗 e-dash3 N" {
  // z4_after ｜ pattern=1-2-3 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_after("1-2-3 * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-dash3 N2" {
  // z4_next ｜ pattern=1-2-3 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_next("1-2-3 * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-slash3 C" {
  // cron_of ｜ pattern=1/2/3 * * * * ｜ 参照=ERR:CronException Invalid syntax of field: [1/2/3]
  assert_eq(z4_tag("1/2/3 * * * *"), "RAISE")
}

///|
test "cron 区窗 e-slash3 M" {
  // matched_dates ｜ pattern=1/2/3 * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=10 ｜ 参照=ERR:CronException Invalid syntax of field: [1/2/3]
  assert_eq(
    z4_md("1/2/3 * * * *", "UTC", 1704067200000L, 1704070800000L, 10),
    "ERR",
  )
}

///|
test "cron 区窗 e-slash3 N" {
  // z4_after ｜ pattern=1/2/3 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_after("1/2/3 * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-slash3 N2" {
  // z4_next ｜ pattern=1/2/3 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_next("1/2/3 * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-plus C" {
  // cron_of ｜ pattern=+ * * * * ｜ 参照=ERR:CronException Invalid alias value: [+]
  assert_eq(z4_tag("+ * * * *"), "RAISE")
}

///|
test "cron 区窗 e-plus M" {
  // matched_dates ｜ pattern=+ * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=10 ｜ 参照=ERR:CronException Invalid alias value: [+]
  assert_eq(
    z4_md("+ * * * *", "UTC", 1704067200000L, 1704070800000L, 10),
    "ERR",
  )
}

///|
test "cron 区窗 e-plus N" {
  // z4_after ｜ pattern=+ * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_after("+ * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-plus N2" {
  // z4_next ｜ pattern=+ * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_next("+ * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-minus C" {
  // cron_of ｜ pattern=- * * * * ｜ 参照=ERR:CronException Invalid alias value: [-]
  assert_eq(z4_tag("- * * * *"), "RAISE")
}

///|
test "cron 区窗 e-minus M" {
  // matched_dates ｜ pattern=- * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=10 ｜ 参照=ERR:CronException Invalid alias value: [-]
  assert_eq(
    z4_md("- * * * *", "UTC", 1704067200000L, 1704070800000L, 10),
    "ERR",
  )
}

///|
test "cron 区窗 e-minus N" {
  // z4_after ｜ pattern=- * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_after("- * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-minus N2" {
  // z4_next ｜ pattern=- * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_next("- * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-over C" {
  // cron_of ｜ pattern=999999999 * * * * ｜ 参照=ERR:CronException MINUTE value 999999999 out of range: [0 , 59]
  assert_eq(z4_tag("999999999 * * * *"), "RAISE")
}

///|
test "cron 区窗 e-over M" {
  // matched_dates ｜ pattern=999999999 * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=10 ｜ 参照=ERR:CronException MINUTE value 999999999 out of range: [0 , 59]
  assert_eq(
    z4_md("999999999 * * * *", "UTC", 1704067200000L, 1704070800000L, 10),
    "ERR",
  )
}

///|
test "cron 区窗 e-over N" {
  // z4_after ｜ pattern=999999999 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_after("999999999 * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-over N2" {
  // z4_next ｜ pattern=999999999 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_next("999999999 * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-edge1e8 C" {
  // cron_of ｜ pattern=100000000 * * * * ｜ 参照=ERR:CronException MINUTE value 100000000 out of range: [0 , 59]
  assert_eq(z4_tag("100000000 * * * *"), "RAISE")
}

///|
test "cron 区窗 e-edge1e8 M" {
  // matched_dates ｜ pattern=100000000 * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=10 ｜ 参照=ERR:CronException MINUTE value 100000000 out of range: [0 , 59]
  assert_eq(
    z4_md("100000000 * * * *", "UTC", 1704067200000L, 1704070800000L, 10),
    "ERR",
  )
}

///|
test "cron 区窗 e-edge1e8 N" {
  // z4_after ｜ pattern=100000000 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_after("100000000 * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-edge1e8 N2" {
  // z4_next ｜ pattern=100000000 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_next("100000000 * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-comma C" {
  // cron_of ｜ pattern=, * * * * ｜ 参照=ERR:CronException Invalid alias value: []
  assert_eq(z4_tag(", * * * *"), "RAISE")
}

///|
test "cron 区窗 e-comma M" {
  // matched_dates ｜ pattern=, * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=10 ｜ 参照=ERR:CronException Invalid alias value: []
  assert_eq(
    z4_md(", * * * *", "UTC", 1704067200000L, 1704070800000L, 10),
    "ERR",
  )
}

///|
test "cron 区窗 e-comma N" {
  // z4_after ｜ pattern=, * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_after(", * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-comma N2" {
  // z4_next ｜ pattern=, * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:CronException -
  assert_eq(z4_next(", * * * *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 yr-sort C" {
  // cron_of ｜ pattern=0 0 12 * * ? 2030,2024 ｜ 参照=RET 0 0 12 * * ? 2030,2024
  assert_eq(z4_tag("0 0 12 * * ? 2030,2024"), "OK")
}

///|
test "cron 区窗 yr-sort T" {
  // cron_pattern_text ｜ 参照 toString=0 0 12 * * ? 2030,2024
  assert_eq(z4_text("0 0 12 * * ? 2030,2024"), "0 0 12 * * ? 2030,2024")
}

///|
test "cron 区窗 yr-sort M" {
  // matched_dates ｜ pattern=0 0 12 * * ? 2030,2024 ｜ zone=UTC ｜ [1714521600000,1715126400000) ｜ count=10 ｜ 参照=RET 1714564800000;1714651200000;1714737600000;1714824000000;1714910400000;1714996800000;1715083200000
  assert_eq(
    z4_md("0 0 12 * * ? 2030,2024", "UTC", 1714521600000L, 1715126400000L, 10),
    "1714564800000;1714651200000;1714737600000;1714824000000;1714910400000;1714996800000;1715083200000",
  )
}

///|
test "cron 区窗 yr-desc C" {
  // cron_of ｜ pattern=0 0 12 * * ? 2026,2025,2024 ｜ 参照=RET 0 0 12 * * ? 2026,2025,2024
  assert_eq(z4_tag("0 0 12 * * ? 2026,2025,2024"), "OK")
}

///|
test "cron 区窗 yr-desc T" {
  // cron_pattern_text ｜ 参照 toString=0 0 12 * * ? 2026,2025,2024
  assert_eq(
    z4_text("0 0 12 * * ? 2026,2025,2024"),
    "0 0 12 * * ? 2026,2025,2024",
  )
}

///|
test "cron 区窗 yr-desc M" {
  // matched_dates ｜ pattern=0 0 12 * * ? 2026,2025,2024 ｜ zone=UTC ｜ [1714521600000,1715126400000) ｜ count=10 ｜ 参照=RET 1714564800000;1714651200000;1714737600000;1714824000000;1714910400000;1714996800000;1715083200000
  assert_eq(
    z4_md(
      "0 0 12 * * ? 2026,2025,2024", "UTC", 1714521600000L, 1715126400000L, 10,
    ),
    "1714564800000;1714651200000;1714737600000;1714824000000;1714910400000;1714996800000;1715083200000",
  )
}

///|
test "cron 区窗 yr-jan C" {
  // cron_of ｜ pattern=0 0 12 1 1 ? 2030,2024,2026 ｜ 参照=RET 0 0 12 1 1 ? 2030,2024,2026
  assert_eq(z4_tag("0 0 12 1 1 ? 2030,2024,2026"), "OK")
}

///|
test "cron 区窗 yr-jan T" {
  // cron_pattern_text ｜ 参照 toString=0 0 12 1 1 ? 2030,2024,2026
  assert_eq(
    z4_text("0 0 12 1 1 ? 2030,2024,2026"),
    "0 0 12 1 1 ? 2030,2024,2026",
  )
}

///|
test "cron 区窗 yr-jan M" {
  // matched_dates ｜ pattern=0 0 12 1 1 ? 2030,2024,2026 ｜ zone=UTC ｜ [1704067200000,1704672000000) ｜ count=10 ｜ 参照=RET 1704110400000
  assert_eq(
    z4_md(
      "0 0 12 1 1 ? 2030,2024,2026", "UTC", 1704067200000L, 1704672000000L, 10,
    ),
    "1704110400000",
  )
}

///|
test "cron 区窗 yr-asc C" {
  // cron_of ｜ pattern=0 0 12 * * ? 2024,2025,2026 ｜ 参照=RET 0 0 12 * * ? 2024,2025,2026
  assert_eq(z4_tag("0 0 12 * * ? 2024,2025,2026"), "OK")
}

///|
test "cron 区窗 yr-asc T" {
  // cron_pattern_text ｜ 参照 toString=0 0 12 * * ? 2024,2025,2026
  assert_eq(
    z4_text("0 0 12 * * ? 2024,2025,2026"),
    "0 0 12 * * ? 2024,2025,2026",
  )
}

///|
test "cron 区窗 yr-asc M" {
  // matched_dates ｜ pattern=0 0 12 * * ? 2024,2025,2026 ｜ zone=UTC ｜ [1714521600000,1715126400000) ｜ count=10 ｜ 参照=RET 1714564800000;1714651200000;1714737600000;1714824000000;1714910400000;1714996800000;1715083200000
  assert_eq(
    z4_md(
      "0 0 12 * * ? 2024,2025,2026", "UTC", 1714521600000L, 1715126400000L, 10,
    ),
    "1714564800000;1714651200000;1714737600000;1714824000000;1714910400000;1714996800000;1715083200000",
  )
}

///|
test "cron 区窗 yr-asc N" {
  // z4_after ｜ pattern=0 0 12 * * ? 2024,2025,2026 ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(
    z4_after("0 0 12 * * ? 2024,2025,2026", "UTC", 1714521600000L),
    "1714564800000",
  )
}

///|
test "cron 区窗 yr-asc N2" {
  // z4_next ｜ pattern=0 0 12 * * ? 2024,2025,2026 ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(
    z4_next("0 0 12 * * ? 2024,2025,2026", "UTC", 1714521600000L),
    "1714564800000",
  )
}

///|
test "cron 区窗 or-two C" {
  // cron_of ｜ pattern=0 12 ? MAY *|0 12 ? 7 * ｜ 参照=RET 0 12 ? MAY *|0 12 ? 7 *
  assert_eq(z4_tag("0 12 ? MAY *|0 12 ? 7 *"), "OK")
}

///|
test "cron 区窗 or-two T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? MAY *|0 12 ? 7 *
  assert_eq(z4_text("0 12 ? MAY *|0 12 ? 7 *"), "0 12 ? MAY *|0 12 ? 7 *")
}

///|
test "cron 区窗 or-two M" {
  // matched_dates ｜ pattern=0 12 ? MAY *|0 12 ? 7 * ｜ zone=UTC ｜ [1719273600000,1719878400000) ｜ count=10 ｜ 参照=RET 1719835200000
  assert_eq(
    z4_md("0 12 ? MAY *|0 12 ? 7 *", "UTC", 1719273600000L, 1719878400000L, 10),
    "1719835200000",
  )
}

///|
test "cron 区窗 or-two N" {
  // z4_after ｜ pattern=0 12 ? MAY *|0 12 ? 7 * ｜ zone=UTC ｜ base=1719273600000 ｜ 参照=RET 1719835200000
  assert_eq(
    z4_after("0 12 ? MAY *|0 12 ? 7 *", "UTC", 1719273600000L),
    "1719835200000",
  )
}

///|
test "cron 区窗 or-two N2" {
  // z4_next ｜ pattern=0 12 ? MAY *|0 12 ? 7 * ｜ zone=UTC ｜ base=1719273600000 ｜ 参照=RET 1719835200000
  assert_eq(
    z4_next("0 12 ? MAY *|0 12 ? 7 *", "UTC", 1719273600000L),
    "1719835200000",
  )
}

///|
test "cron 区窗 or-rev C" {
  // cron_of ｜ pattern=0 12 ? 7 *|0 12 ? MAY * ｜ 参照=RET 0 12 ? 7 *|0 12 ? MAY *
  assert_eq(z4_tag("0 12 ? 7 *|0 12 ? MAY *"), "OK")
}

///|
test "cron 区窗 or-rev T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? 7 *|0 12 ? MAY *
  assert_eq(z4_text("0 12 ? 7 *|0 12 ? MAY *"), "0 12 ? 7 *|0 12 ? MAY *")
}

///|
test "cron 区窗 or-rev M" {
  // matched_dates ｜ pattern=0 12 ? 7 *|0 12 ? MAY * ｜ zone=UTC ｜ [1719273600000,1719878400000) ｜ count=10 ｜ 参照=RET 1719835200000
  assert_eq(
    z4_md("0 12 ? 7 *|0 12 ? MAY *", "UTC", 1719273600000L, 1719878400000L, 10),
    "1719835200000",
  )
}

///|
test "cron 区窗 or-rev N" {
  // z4_after ｜ pattern=0 12 ? 7 *|0 12 ? MAY * ｜ zone=UTC ｜ base=1719273600000 ｜ 参照=RET 1719835200000
  assert_eq(
    z4_after("0 12 ? 7 *|0 12 ? MAY *", "UTC", 1719273600000L),
    "1719835200000",
  )
}

///|
test "cron 区窗 or-rev N2" {
  // z4_next ｜ pattern=0 12 ? 7 *|0 12 ? MAY * ｜ zone=UTC ｜ base=1719273600000 ｜ 参照=RET 1719835200000
  assert_eq(
    z4_next("0 12 ? 7 *|0 12 ? MAY *", "UTC", 1719273600000L),
    "1719835200000",
  )
}

///|
test "cron 区窗 or-same C" {
  // cron_of ｜ pattern=0 12 ? 5 *|0 12 ? 5 * ｜ 参照=RET 0 12 ? 5 *|0 12 ? 5 *
  assert_eq(z4_tag("0 12 ? 5 *|0 12 ? 5 *"), "OK")
}

///|
test "cron 区窗 or-same T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? 5 *|0 12 ? 5 *
  assert_eq(z4_text("0 12 ? 5 *|0 12 ? 5 *"), "0 12 ? 5 *|0 12 ? 5 *")
}

///|
test "cron 区窗 or-same M" {
  // matched_dates ｜ pattern=0 12 ? 5 *|0 12 ? 5 * ｜ zone=UTC ｜ [1719273600000,1719878400000) ｜ count=10 ｜ 参照=RET -
  assert_eq(
    z4_md("0 12 ? 5 *|0 12 ? 5 *", "UTC", 1719273600000L, 1719878400000L, 10),
    "-",
  )
}

///|
test "cron 区窗 or-same N" {
  // z4_after ｜ pattern=0 12 ? 5 *|0 12 ? 5 * ｜ zone=UTC ｜ base=1719273600000 ｜ 参照=RET 1746100800000
  assert_eq(
    z4_after("0 12 ? 5 *|0 12 ? 5 *", "UTC", 1719273600000L),
    "1746100800000",
  )
}

///|
test "cron 区窗 or-same N2" {
  // z4_next ｜ pattern=0 12 ? 5 *|0 12 ? 5 * ｜ zone=UTC ｜ base=1719273600000 ｜ 参照=RET 1746100800000
  assert_eq(
    z4_next("0 12 ? 5 *|0 12 ? 5 *", "UTC", 1719273600000L),
    "1746100800000",
  )
}

///|
test "cron 区窗 cnt-0 C" {
  // cron_of ｜ pattern=0 12 1 * * ｜ 参照=RET 0 12 1 * *
  assert_eq(z4_tag("0 12 1 * *"), "OK")
}

///|
test "cron 区窗 cnt-0 T" {
  // cron_pattern_text ｜ 参照 toString=0 12 1 * *
  assert_eq(z4_text("0 12 1 * *"), "0 12 1 * *")
}

///|
test "cron 区窗 cnt-0 M" {
  // matched_dates ｜ pattern=0 12 1 * * ｜ zone=UTC ｜ [1714521600000,1715126400000) ｜ count=0 ｜ 参照=RET 1714564800000
  assert_eq(z4_md("0 12 1 * *", "UTC", 1714521600000L, 1715126400000L, 0), "-")
}

///|
test "cron 区窗 cnt-0 N" {
  // z4_after ｜ pattern=0 12 1 * * ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_after("0 12 1 * *", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 cnt-0 N2" {
  // z4_next ｜ pattern=0 12 1 * * ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_next("0 12 1 * *", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 cnt-neg C" {
  // cron_of ｜ pattern=0 12 1 * * ｜ 参照=RET 0 12 1 * *
  assert_eq(z4_tag("0 12 1 * *"), "OK")
}

///|
test "cron 区窗 cnt-neg T" {
  // cron_pattern_text ｜ 参照 toString=0 12 1 * *
  assert_eq(z4_text("0 12 1 * *"), "0 12 1 * *")
}

///|
test "cron 区窗 cnt-neg M" {
  // matched_dates ｜ pattern=0 12 1 * * ｜ zone=UTC ｜ [1714521600000,1715126400000) ｜ count=-1 ｜ 参照=ERR:IllegalArgumentException Illegal Capacity: -1
  assert_eq(z4_md("0 12 1 * *", "UTC", 1714521600000L, 1715126400000L, -1), "-")
}

///|
test "cron 区窗 cnt-neg N" {
  // z4_after ｜ pattern=0 12 1 * * ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_after("0 12 1 * *", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 cnt-neg N2" {
  // z4_next ｜ pattern=0 12 1 * * ｜ zone=UTC ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_next("0 12 1 * *", "UTC", 1714521600000L), "1714564800000")
}

///|
test "cron 区窗 z-badname C" {
  // cron_of ｜ pattern=0 12 1 * * ｜ 参照=RET 0 12 1 * *
  assert_eq(z4_tag("0 12 1 * *"), "OK")
}

///|
test "cron 区窗 z-badname T" {
  // cron_pattern_text ｜ 参照 toString=0 12 1 * *
  assert_eq(z4_text("0 12 1 * *"), "0 12 1 * *")
}

///|
test "cron 区窗 z-badname M" {
  // matched_dates ｜ pattern=0 12 1 * * ｜ zone=Not/AZone ｜ [1714521600000,1715126400000) ｜ count=10 ｜ 参照=RET 1714564800000
  assert_eq(
    z4_md("0 12 1 * *", "Not/AZone", 1714521600000L, 1715126400000L, 10),
    "NOWINDOW",
  )
}

///|
test "cron 区窗 z-badname N" {
  // z4_after ｜ pattern=0 12 1 * * ｜ zone=Not/AZone ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_after("0 12 1 * *", "Not/AZone", 1714521600000L), "NOWINDOW")
}

///|
test "cron 区窗 z-badname N2" {
  // z4_next ｜ pattern=0 12 1 * * ｜ zone=Not/AZone ｜ base=1714521600000 ｜ 参照=RET 1714564800000
  assert_eq(z4_next("0 12 1 * *", "Not/AZone", 1714521600000L), "NOWINDOW")
}

///|
test "cron 区窗 z-window C" {
  // cron_of ｜ pattern=0 0 12 1 1 ? 2099 ｜ 参照=RET 0 0 12 1 1 ? 2099
  assert_eq(z4_tag("0 0 12 1 1 ? 2099"), "OK")
}

///|
test "cron 区窗 z-window T" {
  // cron_pattern_text ｜ 参照 toString=0 0 12 1 1 ? 2099
  assert_eq(z4_text("0 0 12 1 1 ? 2099"), "0 0 12 1 1 ? 2099")
}

///|
test "cron 区窗 z-window M" {
  // matched_dates ｜ pattern=0 0 12 1 1 ? 2099 ｜ zone=UTC ｜ [1704067200000,1704672000000) ｜ count=10 ｜ 参照=RET -
  assert_eq(
    z4_md("0 0 12 1 1 ? 2099", "UTC", 1704067200000L, 1704672000000L, 10),
    "-",
  )
}

///|
test "cron 区窗 z-window N" {
  // z4_after ｜ pattern=0 0 12 1 1 ? 2099 ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 4070952000000
  assert_eq(z4_after("0 0 12 1 1 ? 2099", "UTC", 1704067200000L), "NOWINDOW")
}

///|
test "cron 区窗 z-window N2" {
  // z4_next ｜ pattern=0 0 12 1 1 ? 2099 ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 4070952000000
  assert_eq(z4_next("0 0 12 1 1 ? 2099", "UTC", 1704067200000L), "NOWINDOW")
}

///|
test "cron 区窗 gap-la C" {
  // cron_of ｜ pattern=0 30 2 ? 3 * ｜ 参照=RET 0 30 2 ? 3 *
  assert_eq(z4_tag("0 30 2 ? 3 *"), "OK")
}

///|
test "cron 区窗 gap-la T" {
  // cron_pattern_text ｜ 参照 toString=0 30 2 ? 3 *
  assert_eq(z4_text("0 30 2 ? 3 *"), "0 30 2 ? 3 *")
}

///|
test "cron 区窗 gap-la M" {
  // matched_dates ｜ pattern=0 30 2 ? 3 * ｜ zone=America/Los_Angeles ｜ [1710028800000,1710115200000) ｜ count=10 ｜ 参照=RET -
  assert_eq(
    z4_md(
      "0 30 2 ? 3 *", "America/Los_Angeles", 1710028800000L, 1710115200000L, 10,
    ),
    "-",
  )
}

///|
test "cron 区窗 gap-la N" {
  // z4_after ｜ pattern=0 30 2 ? 3 * ｜ zone=America/Los_Angeles ｜ base=1710028800000 ｜ 参照=RET 1710149400000
  assert_eq(
    z4_after("0 30 2 ? 3 *", "America/Los_Angeles", 1710028800000L),
    "1710149400000",
  )
}

///|
test "cron 区窗 gap-la N2" {
  // z4_next ｜ pattern=0 30 2 ? 3 * ｜ zone=America/Los_Angeles ｜ base=1710028800000 ｜ 参照=RET 1710149400000
  assert_eq(
    z4_next("0 30 2 ? 3 *", "America/Los_Angeles", 1710028800000L),
    "1710149400000",
  )
}

///|
test "cron 区窗 fold-ny C" {
  // cron_of ｜ pattern=0 30 1 ? 11 * ｜ 参照=RET 0 30 1 ? 11 *
  assert_eq(z4_tag("0 30 1 ? 11 *"), "OK")
}

///|
test "cron 区窗 fold-ny T" {
  // cron_pattern_text ｜ 参照 toString=0 30 1 ? 11 *
  assert_eq(z4_text("0 30 1 ? 11 *"), "0 30 1 ? 11 *")
}

///|
test "cron 区窗 fold-ny M" {
  // matched_dates ｜ pattern=0 30 1 ? 11 * ｜ zone=America/New_York ｜ [1730505600000,1730592000000) ｜ count=10 ｜ 参照=RET 1730525400000
  assert_eq(
    z4_md(
      "0 30 1 ? 11 *", "America/New_York", 1730505600000L, 1730592000000L, 10,
    ),
    "1730525400000",
  )
}

///|
test "cron 区窗 fold-ny N" {
  // z4_after ｜ pattern=0 30 1 ? 11 * ｜ zone=America/New_York ｜ base=1730505600000 ｜ 参照=RET 1730525400000
  assert_eq(
    z4_after("0 30 1 ? 11 *", "America/New_York", 1730505600000L),
    "1730525400000",
  )
}

///|
test "cron 区窗 fold-ny N2" {
  // z4_next ｜ pattern=0 30 1 ? 11 * ｜ zone=America/New_York ｜ base=1730505600000 ｜ 参照=RET 1730525400000
  assert_eq(
    z4_next("0 30 1 ? 11 *", "America/New_York", 1730505600000L),
    "1730525400000",
  )
}

///|
test "cron 区窗 fold-syd C" {
  // cron_of ｜ pattern=0 30 2 ? 4 * ｜ 参照=RET 0 30 2 ? 4 *
  assert_eq(z4_tag("0 30 2 ? 4 *"), "OK")
}

///|
test "cron 区窗 fold-syd T" {
  // cron_pattern_text ｜ 参照 toString=0 30 2 ? 4 *
  assert_eq(z4_text("0 30 2 ? 4 *"), "0 30 2 ? 4 *")
}

///|
test "cron 区窗 fold-syd M" {
  // matched_dates ｜ pattern=0 30 2 ? 4 * ｜ zone=Australia/Sydney ｜ [1712448000000,1712534400000) ｜ count=10 ｜ 参照=RET 1712507400000
  assert_eq(
    z4_md(
      "0 30 2 ? 4 *", "Australia/Sydney", 1712448000000L, 1712534400000L, 10,
    ),
    "1712507400000",
  )
}

///|
test "cron 区窗 fold-syd N" {
  // z4_after ｜ pattern=0 30 2 ? 4 * ｜ zone=Australia/Sydney ｜ base=1712448000000 ｜ 参照=RET 1712507400000
  assert_eq(
    z4_after("0 30 2 ? 4 *", "Australia/Sydney", 1712448000000L),
    "1712507400000",
  )
}

///|
test "cron 区窗 fold-syd N2" {
  // z4_next ｜ pattern=0 30 2 ? 4 * ｜ zone=Australia/Sydney ｜ base=1712448000000 ｜ 参照=RET 1712507400000
  assert_eq(
    z4_next("0 30 2 ? 4 *", "Australia/Sydney", 1712448000000L),
    "1712507400000",
  )
}

///|
test "cron 区窗 gap-sh86 C" {
  // cron_of ｜ pattern=0 30 2 ? 5 * ｜ 参照=RET 0 30 2 ? 5 *
  assert_eq(z4_tag("0 30 2 ? 5 *"), "OK")
}

///|
test "cron 区窗 gap-sh86 T" {
  // cron_pattern_text ｜ 参照 toString=0 30 2 ? 5 *
  assert_eq(z4_text("0 30 2 ? 5 *"), "0 30 2 ? 5 *")
}

///|
test "cron 区窗 gap-sh86 M" {
  // matched_dates ｜ pattern=0 30 2 ? 5 * ｜ zone=Asia/Shanghai ｜ [514924800000,515011200000) ｜ count=10 ｜ 参照=RET -
  assert_eq(
    z4_md("0 30 2 ? 5 *", "Asia/Shanghai", 514924800000L, 515011200000L, 10),
    "-",
  )
}

///|
test "cron 区窗 gap-sh86 N" {
  // z4_after ｜ pattern=0 30 2 ? 5 * ｜ zone=Asia/Shanghai ｜ base=514924800000 ｜ 参照=RET 515269800000
  assert_eq(
    z4_after("0 30 2 ? 5 *", "Asia/Shanghai", 514924800000L),
    "515269800000",
  )
}

///|
test "cron 区窗 gap-sh86 N2" {
  // z4_next ｜ pattern=0 30 2 ? 5 * ｜ zone=Asia/Shanghai ｜ base=514924800000 ｜ 参照=RET 515269800000
  assert_eq(
    z4_next("0 30 2 ? 5 *", "Asia/Shanghai", 514924800000L),
    "515269800000",
  )
}

///|
test "cron 区窗 cnt-cap C" {
  // cron_of ｜ pattern=0,15,30,45 * * * * ｜ 参照=RET 0,15,30,45 * * * *
  assert_eq(z4_tag("0,15,30,45 * * * *"), "OK")
}

///|
test "cron 区窗 cnt-cap T" {
  // cron_pattern_text ｜ 参照 toString=0,15,30,45 * * * *
  assert_eq(z4_text("0,15,30,45 * * * *"), "0,15,30,45 * * * *")
}

///|
test "cron 区窗 cnt-cap M" {
  // matched_dates ｜ pattern=0,15,30,45 * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=2 ｜ 参照=RET 1704067200000;1704068100000
  assert_eq(
    z4_md("0,15,30,45 * * * *", "UTC", 1704067200000L, 1704070800000L, 2),
    "1704067200000;1704068100000",
  )
}

///|
test "cron 区窗 cnt-cap N" {
  // z4_after ｜ pattern=0,15,30,45 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 1704068100000
  assert_eq(
    z4_after("0,15,30,45 * * * *", "UTC", 1704067200000L),
    "1704068100000",
  )
}

///|
test "cron 区窗 cnt-cap3 C" {
  // cron_of ｜ pattern=0,15,30,45 * * * * ｜ 参照=RET 0,15,30,45 * * * *
  assert_eq(z4_tag("0,15,30,45 * * * *"), "OK")
}

///|
test "cron 区窗 cnt-cap3 T" {
  // cron_pattern_text ｜ 参照 toString=0,15,30,45 * * * *
  assert_eq(z4_text("0,15,30,45 * * * *"), "0,15,30,45 * * * *")
}

///|
test "cron 区窗 cnt-cap3 M" {
  // matched_dates ｜ pattern=0,15,30,45 * * * * ｜ zone=UTC ｜ [1704067200000,1704070800000) ｜ count=3 ｜ 参照=RET 1704067200000;1704068100000;1704069000000
  assert_eq(
    z4_md("0,15,30,45 * * * *", "UTC", 1704067200000L, 1704070800000L, 3),
    "1704067200000;1704068100000;1704069000000",
  )
}

///|
test "cron 区窗 cnt-cap3 N" {
  // z4_after ｜ pattern=0,15,30,45 * * * * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=RET 1704068100000
  assert_eq(
    z4_after("0,15,30,45 * * * *", "UTC", 1704067200000L),
    "1704068100000",
  )
}

///|
test "cron 区窗 al-jun C" {
  // cron_of ｜ pattern=0 12 ? JUN * ｜ 参照=RET 0 12 ? JUN *
  assert_eq(z4_tag("0 12 ? JUN *"), "OK")
}

///|
test "cron 区窗 al-jun T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? JUN *
  assert_eq(z4_text("0 12 ? JUN *"), "0 12 ? JUN *")
}

///|
test "cron 区窗 al-jun M" {
  // matched_dates ｜ pattern=0 12 ? JUN * ｜ zone=UTC ｜ [1717171200000,1717776000000) ｜ count=10 ｜ 参照=RET 1717243200000;1717329600000;1717416000000;1717502400000;1717588800000;1717675200000;1717761600000
  assert_eq(
    z4_md("0 12 ? JUN *", "UTC", 1717171200000L, 1717776000000L, 10),
    "1717243200000;1717329600000;1717416000000;1717502400000;1717588800000;1717675200000;1717761600000",
  )
}

///|
test "cron 区窗 al-jun N" {
  // z4_after ｜ pattern=0 12 ? JUN * ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717243200000
  assert_eq(z4_after("0 12 ? JUN *", "UTC", 1717171200000L), "1717243200000")
}

///|
test "cron 区窗 al-jun N2" {
  // z4_next ｜ pattern=0 12 ? JUN * ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717243200000
  assert_eq(z4_next("0 12 ? JUN *", "UTC", 1717171200000L), "1717243200000")
}

///|
test "cron 区窗 al-jun-num C" {
  // cron_of ｜ pattern=0 12 ? 6 * ｜ 参照=RET 0 12 ? 6 *
  assert_eq(z4_tag("0 12 ? 6 *"), "OK")
}

///|
test "cron 区窗 al-jun-num T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? 6 *
  assert_eq(z4_text("0 12 ? 6 *"), "0 12 ? 6 *")
}

///|
test "cron 区窗 al-jun-num M" {
  // matched_dates ｜ pattern=0 12 ? 6 * ｜ zone=UTC ｜ [1717171200000,1717776000000) ｜ count=10 ｜ 参照=RET 1717243200000;1717329600000;1717416000000;1717502400000;1717588800000;1717675200000;1717761600000
  assert_eq(
    z4_md("0 12 ? 6 *", "UTC", 1717171200000L, 1717776000000L, 10),
    "1717243200000;1717329600000;1717416000000;1717502400000;1717588800000;1717675200000;1717761600000",
  )
}

///|
test "cron 区窗 al-jun-num N" {
  // z4_after ｜ pattern=0 12 ? 6 * ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717243200000
  assert_eq(z4_after("0 12 ? 6 *", "UTC", 1717171200000L), "1717243200000")
}

///|
test "cron 区窗 al-jun-num N2" {
  // z4_next ｜ pattern=0 12 ? 6 * ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717243200000
  assert_eq(z4_next("0 12 ? 6 *", "UTC", 1717171200000L), "1717243200000")
}

///|
test "cron 区窗 al-june C" {
  // cron_of ｜ pattern=0 12 ? june * ｜ 参照=RET 0 12 ? june *
  assert_eq(z4_tag("0 12 ? june *"), "OK")
}

///|
test "cron 区窗 al-june T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? june *
  assert_eq(z4_text("0 12 ? june *"), "0 12 ? june *")
}

///|
test "cron 区窗 al-june M" {
  // matched_dates ｜ pattern=0 12 ? june * ｜ zone=UTC ｜ [1717171200000,1717776000000) ｜ count=10 ｜ 参照=RET 1717243200000;1717329600000;1717416000000;1717502400000;1717588800000;1717675200000;1717761600000
  assert_eq(
    z4_md("0 12 ? june *", "UTC", 1717171200000L, 1717776000000L, 10),
    "1717243200000;1717329600000;1717416000000;1717502400000;1717588800000;1717675200000;1717761600000",
  )
}

///|
test "cron 区窗 al-june N" {
  // z4_after ｜ pattern=0 12 ? june * ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717243200000
  assert_eq(z4_after("0 12 ? june *", "UTC", 1717171200000L), "1717243200000")
}

///|
test "cron 区窗 al-june N2" {
  // z4_next ｜ pattern=0 12 ? june * ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717243200000
  assert_eq(z4_next("0 12 ? june *", "UTC", 1717171200000L), "1717243200000")
}

///|
test "cron 区窗 al-thu C" {
  // cron_of ｜ pattern=0 12 * * THU ｜ 参照=RET 0 12 * * THU
  assert_eq(z4_tag("0 12 * * THU"), "OK")
}

///|
test "cron 区窗 al-thu T" {
  // cron_pattern_text ｜ 参照 toString=0 12 * * THU
  assert_eq(z4_text("0 12 * * THU"), "0 12 * * THU")
}

///|
test "cron 区窗 al-thu M" {
  // matched_dates ｜ pattern=0 12 * * THU ｜ zone=UTC ｜ [1717171200000,1717776000000) ｜ count=10 ｜ 参照=RET 1717675200000
  assert_eq(
    z4_md("0 12 * * THU", "UTC", 1717171200000L, 1717776000000L, 10),
    "1717675200000",
  )
}

///|
test "cron 区窗 al-thu N" {
  // z4_after ｜ pattern=0 12 * * THU ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717675200000
  assert_eq(z4_after("0 12 * * THU", "UTC", 1717171200000L), "1717675200000")
}

///|
test "cron 区窗 al-thu N2" {
  // z4_next ｜ pattern=0 12 * * THU ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717675200000
  assert_eq(z4_next("0 12 * * THU", "UTC", 1717171200000L), "1717675200000")
}

///|
test "cron 区窗 al-thu-num C" {
  // cron_of ｜ pattern=0 12 * * 4 ｜ 参照=RET 0 12 * * 4
  assert_eq(z4_tag("0 12 * * 4"), "OK")
}

///|
test "cron 区窗 al-thu-num T" {
  // cron_pattern_text ｜ 参照 toString=0 12 * * 4
  assert_eq(z4_text("0 12 * * 4"), "0 12 * * 4")
}

///|
test "cron 区窗 al-thu-num M" {
  // matched_dates ｜ pattern=0 12 * * 4 ｜ zone=UTC ｜ [1717171200000,1717776000000) ｜ count=10 ｜ 参照=RET 1717675200000
  assert_eq(
    z4_md("0 12 * * 4", "UTC", 1717171200000L, 1717776000000L, 10),
    "1717675200000",
  )
}

///|
test "cron 区窗 al-thu-num N" {
  // z4_after ｜ pattern=0 12 * * 4 ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717675200000
  assert_eq(z4_after("0 12 * * 4", "UTC", 1717171200000L), "1717675200000")
}

///|
test "cron 区窗 al-thu-num N2" {
  // z4_next ｜ pattern=0 12 * * 4 ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717675200000
  assert_eq(z4_next("0 12 * * 4", "UTC", 1717171200000L), "1717675200000")
}

///|
test "cron 区窗 al-thu-full C" {
  // cron_of ｜ pattern=0 12 * * thursday ｜ 参照=RET 0 12 * * thursday
  assert_eq(z4_tag("0 12 * * thursday"), "OK")
}

///|
test "cron 区窗 al-thu-full T" {
  // cron_pattern_text ｜ 参照 toString=0 12 * * thursday
  assert_eq(z4_text("0 12 * * thursday"), "0 12 * * thursday")
}

///|
test "cron 区窗 al-thu-full M" {
  // matched_dates ｜ pattern=0 12 * * thursday ｜ zone=UTC ｜ [1717171200000,1717776000000) ｜ count=10 ｜ 参照=RET 1717675200000
  assert_eq(
    z4_md("0 12 * * thursday", "UTC", 1717171200000L, 1717776000000L, 10),
    "1717675200000",
  )
}

///|
test "cron 区窗 al-thu-full N" {
  // z4_after ｜ pattern=0 12 * * thursday ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717675200000
  assert_eq(
    z4_after("0 12 * * thursday", "UTC", 1717171200000L),
    "1717675200000",
  )
}

///|
test "cron 区窗 al-thu-full N2" {
  // z4_next ｜ pattern=0 12 * * thursday ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717675200000
  assert_eq(
    z4_next("0 12 * * thursday", "UTC", 1717171200000L),
    "1717675200000",
  )
}

///|
test "cron 区窗 win-land C" {
  // cron_of ｜ pattern=0 20 * * * ｜ 参照=RET 0 20 * * *
  assert_eq(z4_tag("0 20 * * *"), "OK")
}

///|
test "cron 区窗 win-land T" {
  // cron_pattern_text ｜ 参照 toString=0 20 * * *
  assert_eq(z4_text("0 20 * * *"), "0 20 * * *")
}

///|
test "cron 区窗 win-land M" {
  // matched_dates ｜ pattern=0 20 * * * ｜ zone=America/New_York ｜ [2524568400000,2524608000000) ｜ count=10 ｜ 参照=RET -
  assert_eq(
    z4_md("0 20 * * *", "America/New_York", 2524568400000L, 2524608000000L, 10),
    "NOWINDOW",
  )
}

///|
test "cron 区窗 win-land N" {
  // z4_after ｜ pattern=0 20 * * * ｜ zone=America/New_York ｜ base=2524568400000 ｜ 参照=RET 2524611600000
  assert_eq(
    z4_after("0 20 * * *", "America/New_York", 2524568400000L),
    "NOWINDOW",
  )
}

///|
test "cron 区窗 win-land N2" {
  // z4_next ｜ pattern=0 20 * * * ｜ zone=America/New_York ｜ base=2524568400000 ｜ 参照=RET 2524611600000
  assert_eq(
    z4_next("0 20 * * *", "America/New_York", 2524568400000L),
    "NOWINDOW",
  )
}

///|
test "cron 区窗 al-aug C" {
  // cron_of ｜ pattern=0 12 ? AUG * ｜ 参照=RET 0 12 ? AUG *
  assert_eq(z4_tag("0 12 ? AUG *"), "OK")
}

///|
test "cron 区窗 al-aug T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? AUG *
  assert_eq(z4_text("0 12 ? AUG *"), "0 12 ? AUG *")
}

///|
test "cron 区窗 al-aug M" {
  // matched_dates ｜ pattern=0 12 ? AUG * ｜ zone=UTC ｜ [1722470400000,1723075200000) ｜ count=10 ｜ 参照=RET 1722513600000;1722600000000;1722686400000;1722772800000;1722859200000;1722945600000;1723032000000
  assert_eq(
    z4_md("0 12 ? AUG *", "UTC", 1722470400000L, 1723075200000L, 10),
    "1722513600000;1722600000000;1722686400000;1722772800000;1722859200000;1722945600000;1723032000000",
  )
}

///|
test "cron 区窗 al-aug N" {
  // z4_after ｜ pattern=0 12 ? AUG * ｜ zone=UTC ｜ base=1722470400000 ｜ 参照=RET 1722513600000
  assert_eq(z4_after("0 12 ? AUG *", "UTC", 1722470400000L), "1722513600000")
}

///|
test "cron 区窗 al-aug N2" {
  // z4_next ｜ pattern=0 12 ? AUG * ｜ zone=UTC ｜ base=1722470400000 ｜ 参照=RET 1722513600000
  assert_eq(z4_next("0 12 ? AUG *", "UTC", 1722470400000L), "1722513600000")
}

///|
test "cron 区窗 al-aug-num C" {
  // cron_of ｜ pattern=0 12 ? 8 * ｜ 参照=RET 0 12 ? 8 *
  assert_eq(z4_tag("0 12 ? 8 *"), "OK")
}

///|
test "cron 区窗 al-aug-num T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? 8 *
  assert_eq(z4_text("0 12 ? 8 *"), "0 12 ? 8 *")
}

///|
test "cron 区窗 al-aug-num M" {
  // matched_dates ｜ pattern=0 12 ? 8 * ｜ zone=UTC ｜ [1722470400000,1723075200000) ｜ count=10 ｜ 参照=RET 1722513600000;1722600000000;1722686400000;1722772800000;1722859200000;1722945600000;1723032000000
  assert_eq(
    z4_md("0 12 ? 8 *", "UTC", 1722470400000L, 1723075200000L, 10),
    "1722513600000;1722600000000;1722686400000;1722772800000;1722859200000;1722945600000;1723032000000",
  )
}

///|
test "cron 区窗 al-aug-num N" {
  // z4_after ｜ pattern=0 12 ? 8 * ｜ zone=UTC ｜ base=1722470400000 ｜ 参照=RET 1722513600000
  assert_eq(z4_after("0 12 ? 8 *", "UTC", 1722470400000L), "1722513600000")
}

///|
test "cron 区窗 al-aug-num N2" {
  // z4_next ｜ pattern=0 12 ? 8 * ｜ zone=UTC ｜ base=1722470400000 ｜ 参照=RET 1722513600000
  assert_eq(z4_next("0 12 ? 8 *", "UTC", 1722470400000L), "1722513600000")
}

///|
test "cron 区窗 al-sep C" {
  // cron_of ｜ pattern=0 12 ? SEP * ｜ 参照=RET 0 12 ? SEP *
  assert_eq(z4_tag("0 12 ? SEP *"), "OK")
}

///|
test "cron 区窗 al-sep T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? SEP *
  assert_eq(z4_text("0 12 ? SEP *"), "0 12 ? SEP *")
}

///|
test "cron 区窗 al-sep M" {
  // matched_dates ｜ pattern=0 12 ? SEP * ｜ zone=UTC ｜ [1725148800000,1725753600000) ｜ count=10 ｜ 参照=RET 1725192000000;1725278400000;1725364800000;1725451200000;1725537600000;1725624000000;1725710400000
  assert_eq(
    z4_md("0 12 ? SEP *", "UTC", 1725148800000L, 1725753600000L, 10),
    "1725192000000;1725278400000;1725364800000;1725451200000;1725537600000;1725624000000;1725710400000",
  )
}

///|
test "cron 区窗 al-sep N" {
  // z4_after ｜ pattern=0 12 ? SEP * ｜ zone=UTC ｜ base=1725148800000 ｜ 参照=RET 1725192000000
  assert_eq(z4_after("0 12 ? SEP *", "UTC", 1725148800000L), "1725192000000")
}

///|
test "cron 区窗 al-sep N2" {
  // z4_next ｜ pattern=0 12 ? SEP * ｜ zone=UTC ｜ base=1725148800000 ｜ 参照=RET 1725192000000
  assert_eq(z4_next("0 12 ? SEP *", "UTC", 1725148800000L), "1725192000000")
}

///|
test "cron 区窗 al-sep-num C" {
  // cron_of ｜ pattern=0 12 ? 9 * ｜ 参照=RET 0 12 ? 9 *
  assert_eq(z4_tag("0 12 ? 9 *"), "OK")
}

///|
test "cron 区窗 al-sep-num T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? 9 *
  assert_eq(z4_text("0 12 ? 9 *"), "0 12 ? 9 *")
}

///|
test "cron 区窗 al-sep-num M" {
  // matched_dates ｜ pattern=0 12 ? 9 * ｜ zone=UTC ｜ [1725148800000,1725753600000) ｜ count=10 ｜ 参照=RET 1725192000000;1725278400000;1725364800000;1725451200000;1725537600000;1725624000000;1725710400000
  assert_eq(
    z4_md("0 12 ? 9 *", "UTC", 1725148800000L, 1725753600000L, 10),
    "1725192000000;1725278400000;1725364800000;1725451200000;1725537600000;1725624000000;1725710400000",
  )
}

///|
test "cron 区窗 al-sep-num N" {
  // z4_after ｜ pattern=0 12 ? 9 * ｜ zone=UTC ｜ base=1725148800000 ｜ 参照=RET 1725192000000
  assert_eq(z4_after("0 12 ? 9 *", "UTC", 1725148800000L), "1725192000000")
}

///|
test "cron 区窗 al-sep-num N2" {
  // z4_next ｜ pattern=0 12 ? 9 * ｜ zone=UTC ｜ base=1725148800000 ｜ 参照=RET 1725192000000
  assert_eq(z4_next("0 12 ? 9 *", "UTC", 1725148800000L), "1725192000000")
}

///|
test "cron 区窗 al-oct C" {
  // cron_of ｜ pattern=0 12 ? OCT * ｜ 参照=RET 0 12 ? OCT *
  assert_eq(z4_tag("0 12 ? OCT *"), "OK")
}

///|
test "cron 区窗 al-oct T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? OCT *
  assert_eq(z4_text("0 12 ? OCT *"), "0 12 ? OCT *")
}

///|
test "cron 区窗 al-oct M" {
  // matched_dates ｜ pattern=0 12 ? OCT * ｜ zone=UTC ｜ [1727740800000,1728345600000) ｜ count=10 ｜ 参照=RET 1727784000000;1727870400000;1727956800000;1728043200000;1728129600000;1728216000000;1728302400000
  assert_eq(
    z4_md("0 12 ? OCT *", "UTC", 1727740800000L, 1728345600000L, 10),
    "1727784000000;1727870400000;1727956800000;1728043200000;1728129600000;1728216000000;1728302400000",
  )
}

///|
test "cron 区窗 al-oct N" {
  // z4_after ｜ pattern=0 12 ? OCT * ｜ zone=UTC ｜ base=1727740800000 ｜ 参照=RET 1727784000000
  assert_eq(z4_after("0 12 ? OCT *", "UTC", 1727740800000L), "1727784000000")
}

///|
test "cron 区窗 al-oct N2" {
  // z4_next ｜ pattern=0 12 ? OCT * ｜ zone=UTC ｜ base=1727740800000 ｜ 参照=RET 1727784000000
  assert_eq(z4_next("0 12 ? OCT *", "UTC", 1727740800000L), "1727784000000")
}

///|
test "cron 区窗 al-oct-num C" {
  // cron_of ｜ pattern=0 12 ? 10 * ｜ 参照=RET 0 12 ? 10 *
  assert_eq(z4_tag("0 12 ? 10 *"), "OK")
}

///|
test "cron 区窗 al-oct-num T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? 10 *
  assert_eq(z4_text("0 12 ? 10 *"), "0 12 ? 10 *")
}

///|
test "cron 区窗 al-oct-num M" {
  // matched_dates ｜ pattern=0 12 ? 10 * ｜ zone=UTC ｜ [1727740800000,1728345600000) ｜ count=10 ｜ 参照=RET 1727784000000;1727870400000;1727956800000;1728043200000;1728129600000;1728216000000;1728302400000
  assert_eq(
    z4_md("0 12 ? 10 *", "UTC", 1727740800000L, 1728345600000L, 10),
    "1727784000000;1727870400000;1727956800000;1728043200000;1728129600000;1728216000000;1728302400000",
  )
}

///|
test "cron 区窗 al-oct-num N" {
  // z4_after ｜ pattern=0 12 ? 10 * ｜ zone=UTC ｜ base=1727740800000 ｜ 参照=RET 1727784000000
  assert_eq(z4_after("0 12 ? 10 *", "UTC", 1727740800000L), "1727784000000")
}

///|
test "cron 区窗 al-oct-num N2" {
  // z4_next ｜ pattern=0 12 ? 10 * ｜ zone=UTC ｜ base=1727740800000 ｜ 参照=RET 1727784000000
  assert_eq(z4_next("0 12 ? 10 *", "UTC", 1727740800000L), "1727784000000")
}

///|
test "cron 区窗 al-nov C" {
  // cron_of ｜ pattern=0 12 ? NOV * ｜ 参照=RET 0 12 ? NOV *
  assert_eq(z4_tag("0 12 ? NOV *"), "OK")
}

///|
test "cron 区窗 al-nov T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? NOV *
  assert_eq(z4_text("0 12 ? NOV *"), "0 12 ? NOV *")
}

///|
test "cron 区窗 al-nov M" {
  // matched_dates ｜ pattern=0 12 ? NOV * ｜ zone=UTC ｜ [1730419200000,1731024000000) ｜ count=10 ｜ 参照=RET 1730462400000;1730548800000;1730635200000;1730721600000;1730808000000;1730894400000;1730980800000
  assert_eq(
    z4_md("0 12 ? NOV *", "UTC", 1730419200000L, 1731024000000L, 10),
    "1730462400000;1730548800000;1730635200000;1730721600000;1730808000000;1730894400000;1730980800000",
  )
}

///|
test "cron 区窗 al-nov N" {
  // z4_after ｜ pattern=0 12 ? NOV * ｜ zone=UTC ｜ base=1730419200000 ｜ 参照=RET 1730462400000
  assert_eq(z4_after("0 12 ? NOV *", "UTC", 1730419200000L), "1730462400000")
}

///|
test "cron 区窗 al-nov N2" {
  // z4_next ｜ pattern=0 12 ? NOV * ｜ zone=UTC ｜ base=1730419200000 ｜ 参照=RET 1730462400000
  assert_eq(z4_next("0 12 ? NOV *", "UTC", 1730419200000L), "1730462400000")
}

///|
test "cron 区窗 al-nov-num C" {
  // cron_of ｜ pattern=0 12 ? 11 * ｜ 参照=RET 0 12 ? 11 *
  assert_eq(z4_tag("0 12 ? 11 *"), "OK")
}

///|
test "cron 区窗 al-nov-num T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? 11 *
  assert_eq(z4_text("0 12 ? 11 *"), "0 12 ? 11 *")
}

///|
test "cron 区窗 al-nov-num M" {
  // matched_dates ｜ pattern=0 12 ? 11 * ｜ zone=UTC ｜ [1730419200000,1731024000000) ｜ count=10 ｜ 参照=RET 1730462400000;1730548800000;1730635200000;1730721600000;1730808000000;1730894400000;1730980800000
  assert_eq(
    z4_md("0 12 ? 11 *", "UTC", 1730419200000L, 1731024000000L, 10),
    "1730462400000;1730548800000;1730635200000;1730721600000;1730808000000;1730894400000;1730980800000",
  )
}

///|
test "cron 区窗 al-nov-num N" {
  // z4_after ｜ pattern=0 12 ? 11 * ｜ zone=UTC ｜ base=1730419200000 ｜ 参照=RET 1730462400000
  assert_eq(z4_after("0 12 ? 11 *", "UTC", 1730419200000L), "1730462400000")
}

///|
test "cron 区窗 al-nov-num N2" {
  // z4_next ｜ pattern=0 12 ? 11 * ｜ zone=UTC ｜ base=1730419200000 ｜ 参照=RET 1730462400000
  assert_eq(z4_next("0 12 ? 11 *", "UTC", 1730419200000L), "1730462400000")
}

///|
test "cron 区窗 al-dec C" {
  // cron_of ｜ pattern=0 12 ? DEC * ｜ 参照=RET 0 12 ? DEC *
  assert_eq(z4_tag("0 12 ? DEC *"), "OK")
}

///|
test "cron 区窗 al-dec T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? DEC *
  assert_eq(z4_text("0 12 ? DEC *"), "0 12 ? DEC *")
}

///|
test "cron 区窗 al-dec M" {
  // matched_dates ｜ pattern=0 12 ? DEC * ｜ zone=UTC ｜ [1733011200000,1733616000000) ｜ count=10 ｜ 参照=RET 1733054400000;1733140800000;1733227200000;1733313600000;1733400000000;1733486400000;1733572800000
  assert_eq(
    z4_md("0 12 ? DEC *", "UTC", 1733011200000L, 1733616000000L, 10),
    "1733054400000;1733140800000;1733227200000;1733313600000;1733400000000;1733486400000;1733572800000",
  )
}

///|
test "cron 区窗 al-dec N" {
  // z4_after ｜ pattern=0 12 ? DEC * ｜ zone=UTC ｜ base=1733011200000 ｜ 参照=RET 1733054400000
  assert_eq(z4_after("0 12 ? DEC *", "UTC", 1733011200000L), "1733054400000")
}

///|
test "cron 区窗 al-dec N2" {
  // z4_next ｜ pattern=0 12 ? DEC * ｜ zone=UTC ｜ base=1733011200000 ｜ 参照=RET 1733054400000
  assert_eq(z4_next("0 12 ? DEC *", "UTC", 1733011200000L), "1733054400000")
}

///|
test "cron 区窗 al-dec-num C" {
  // cron_of ｜ pattern=0 12 ? 12 * ｜ 参照=RET 0 12 ? 12 *
  assert_eq(z4_tag("0 12 ? 12 *"), "OK")
}

///|
test "cron 区窗 al-dec-num T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? 12 *
  assert_eq(z4_text("0 12 ? 12 *"), "0 12 ? 12 *")
}

///|
test "cron 区窗 al-dec-num M" {
  // matched_dates ｜ pattern=0 12 ? 12 * ｜ zone=UTC ｜ [1733011200000,1733616000000) ｜ count=10 ｜ 参照=RET 1733054400000;1733140800000;1733227200000;1733313600000;1733400000000;1733486400000;1733572800000
  assert_eq(
    z4_md("0 12 ? 12 *", "UTC", 1733011200000L, 1733616000000L, 10),
    "1733054400000;1733140800000;1733227200000;1733313600000;1733400000000;1733486400000;1733572800000",
  )
}

///|
test "cron 区窗 al-dec-num N" {
  // z4_after ｜ pattern=0 12 ? 12 * ｜ zone=UTC ｜ base=1733011200000 ｜ 参照=RET 1733054400000
  assert_eq(z4_after("0 12 ? 12 *", "UTC", 1733011200000L), "1733054400000")
}

///|
test "cron 区窗 al-dec-num N2" {
  // z4_next ｜ pattern=0 12 ? 12 * ｜ zone=UTC ｜ base=1733011200000 ｜ 参照=RET 1733054400000
  assert_eq(z4_next("0 12 ? 12 *", "UTC", 1733011200000L), "1733054400000")
}

///|
test "cron 区窗 al-sat C" {
  // cron_of ｜ pattern=0 12 * * sat ｜ 参照=RET 0 12 * * sat
  assert_eq(z4_tag("0 12 * * sat"), "OK")
}

///|
test "cron 区窗 al-sat T" {
  // cron_pattern_text ｜ 参照 toString=0 12 * * sat
  assert_eq(z4_text("0 12 * * sat"), "0 12 * * sat")
}

///|
test "cron 区窗 al-sat M" {
  // matched_dates ｜ pattern=0 12 * * sat ｜ zone=UTC ｜ [1717171200000,1717776000000) ｜ count=10 ｜ 参照=RET 1717243200000
  assert_eq(
    z4_md("0 12 * * sat", "UTC", 1717171200000L, 1717776000000L, 10),
    "1717243200000",
  )
}

///|
test "cron 区窗 al-sat N" {
  // z4_after ｜ pattern=0 12 * * sat ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717243200000
  assert_eq(z4_after("0 12 * * sat", "UTC", 1717171200000L), "1717243200000")
}

///|
test "cron 区窗 al-sat N2" {
  // z4_next ｜ pattern=0 12 * * sat ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717243200000
  assert_eq(z4_next("0 12 * * sat", "UTC", 1717171200000L), "1717243200000")
}

///|
test "cron 区窗 al-sat-num C" {
  // cron_of ｜ pattern=0 12 * * 6 ｜ 参照=RET 0 12 * * 6
  assert_eq(z4_tag("0 12 * * 6"), "OK")
}

///|
test "cron 区窗 al-sat-num T" {
  // cron_pattern_text ｜ 参照 toString=0 12 * * 6
  assert_eq(z4_text("0 12 * * 6"), "0 12 * * 6")
}

///|
test "cron 区窗 al-sat-num M" {
  // matched_dates ｜ pattern=0 12 * * 6 ｜ zone=UTC ｜ [1717171200000,1717776000000) ｜ count=10 ｜ 参照=RET 1717243200000
  assert_eq(
    z4_md("0 12 * * 6", "UTC", 1717171200000L, 1717776000000L, 10),
    "1717243200000",
  )
}

///|
test "cron 区窗 al-sat-num N" {
  // z4_after ｜ pattern=0 12 * * 6 ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717243200000
  assert_eq(z4_after("0 12 * * 6", "UTC", 1717171200000L), "1717243200000")
}

///|
test "cron 区窗 al-sat-num N2" {
  // z4_next ｜ pattern=0 12 * * 6 ｜ zone=UTC ｜ base=1717171200000 ｜ 参照=RET 1717243200000
  assert_eq(z4_next("0 12 * * 6", "UTC", 1717171200000L), "1717243200000")
}

///|
test "cron 区窗 e-month-1x C" {
  // cron_of ｜ pattern=0 12 ? 1x * ｜ 参照=ERR:IllegalArgumentException No enum constant cn.hutool.core.date.Month.1X
  assert_eq(z4_tag("0 12 ? 1x *"), "RAISE")
}

///|
test "cron 区窗 e-month-1x M" {
  // matched_dates ｜ pattern=0 12 ? 1x * ｜ zone=UTC ｜ [1704067200000,1704672000000) ｜ count=10 ｜ 参照=ERR:IllegalArgumentException No enum constant cn.hutool.core.date.Month.1X
  assert_eq(
    z4_md("0 12 ? 1x *", "UTC", 1704067200000L, 1704672000000L, 10),
    "ERR",
  )
}

///|
test "cron 区窗 e-month-1x N" {
  // z4_after ｜ pattern=0 12 ? 1x * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:IllegalArgumentException -
  assert_eq(z4_after("0 12 ? 1x *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-month-1x N2" {
  // z4_next ｜ pattern=0 12 ? 1x * ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:IllegalArgumentException -
  assert_eq(z4_next("0 12 ? 1x *", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-week-1x C" {
  // cron_of ｜ pattern=0 12 * * 1x ｜ 参照=ERR:IllegalArgumentException No enum constant cn.hutool.core.date.Week.1X
  assert_eq(z4_tag("0 12 * * 1x"), "RAISE")
}

///|
test "cron 区窗 e-week-1x M" {
  // matched_dates ｜ pattern=0 12 * * 1x ｜ zone=UTC ｜ [1704067200000,1704672000000) ｜ count=10 ｜ 参照=ERR:IllegalArgumentException No enum constant cn.hutool.core.date.Week.1X
  assert_eq(
    z4_md("0 12 * * 1x", "UTC", 1704067200000L, 1704672000000L, 10),
    "ERR",
  )
}

///|
test "cron 区窗 e-week-1x N" {
  // z4_after ｜ pattern=0 12 * * 1x ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:IllegalArgumentException -
  assert_eq(z4_after("0 12 * * 1x", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 e-week-1x N2" {
  // z4_next ｜ pattern=0 12 * * 1x ｜ zone=UTC ｜ base=1704067200000 ｜ 参照=ERR:IllegalArgumentException -
  assert_eq(z4_next("0 12 * * 1x", "UTC", 1704067200000L), "ERR")
}

///|
test "cron 区窗 al-jul C" {
  // cron_of ｜ pattern=0 12 ? JUL * ｜ 参照=RET 0 12 ? JUL *
  assert_eq(z4_tag("0 12 ? JUL *"), "OK")
}

///|
test "cron 区窗 al-jul T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? JUL *
  assert_eq(z4_text("0 12 ? JUL *"), "0 12 ? JUL *")
}

///|
test "cron 区窗 al-jul M" {
  // matched_dates ｜ pattern=0 12 ? JUL * ｜ zone=UTC ｜ [1719792000000,1720396800000) ｜ count=10 ｜ 参照=RET 1719835200000;1719921600000;1720008000000;1720094400000;1720180800000;1720267200000;1720353600000
  assert_eq(
    z4_md("0 12 ? JUL *", "UTC", 1719792000000L, 1720396800000L, 10),
    "1719835200000;1719921600000;1720008000000;1720094400000;1720180800000;1720267200000;1720353600000",
  )
}

///|
test "cron 区窗 al-jul N" {
  // z4_after ｜ pattern=0 12 ? JUL * ｜ zone=UTC ｜ base=1719792000000 ｜ 参照=RET 1719835200000
  assert_eq(z4_after("0 12 ? JUL *", "UTC", 1719792000000L), "1719835200000")
}

///|
test "cron 区窗 al-jul N2" {
  // z4_next ｜ pattern=0 12 ? JUL * ｜ zone=UTC ｜ base=1719792000000 ｜ 参照=RET 1719835200000
  assert_eq(z4_next("0 12 ? JUL *", "UTC", 1719792000000L), "1719835200000")
}

///|
test "cron 区窗 al-jul-num C" {
  // cron_of ｜ pattern=0 12 ? 7 * ｜ 参照=RET 0 12 ? 7 *
  assert_eq(z4_tag("0 12 ? 7 *"), "OK")
}

///|
test "cron 区窗 al-jul-num T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? 7 *
  assert_eq(z4_text("0 12 ? 7 *"), "0 12 ? 7 *")
}

///|
test "cron 区窗 al-jul-num M" {
  // matched_dates ｜ pattern=0 12 ? 7 * ｜ zone=UTC ｜ [1719792000000,1720396800000) ｜ count=10 ｜ 参照=RET 1719835200000;1719921600000;1720008000000;1720094400000;1720180800000;1720267200000;1720353600000
  assert_eq(
    z4_md("0 12 ? 7 *", "UTC", 1719792000000L, 1720396800000L, 10),
    "1719835200000;1719921600000;1720008000000;1720094400000;1720180800000;1720267200000;1720353600000",
  )
}

///|
test "cron 区窗 al-jul-num N" {
  // z4_after ｜ pattern=0 12 ? 7 * ｜ zone=UTC ｜ base=1719792000000 ｜ 参照=RET 1719835200000
  assert_eq(z4_after("0 12 ? 7 *", "UTC", 1719792000000L), "1719835200000")
}

///|
test "cron 区窗 al-jul-num N2" {
  // z4_next ｜ pattern=0 12 ? 7 * ｜ zone=UTC ｜ base=1719792000000 ｜ 参照=RET 1719835200000
  assert_eq(z4_next("0 12 ? 7 *", "UTC", 1719792000000L), "1719835200000")
}

///|
test "cron 区窗 al-july C" {
  // cron_of ｜ pattern=0 12 ? july * ｜ 参照=RET 0 12 ? july *
  assert_eq(z4_tag("0 12 ? july *"), "OK")
}

///|
test "cron 区窗 al-july T" {
  // cron_pattern_text ｜ 参照 toString=0 12 ? july *
  assert_eq(z4_text("0 12 ? july *"), "0 12 ? july *")
}

///|
test "cron 区窗 al-july M" {
  // matched_dates ｜ pattern=0 12 ? july * ｜ zone=UTC ｜ [1719792000000,1720396800000) ｜ count=10 ｜ 参照=RET 1719835200000;1719921600000;1720008000000;1720094400000;1720180800000;1720267200000;1720353600000
  assert_eq(
    z4_md("0 12 ? july *", "UTC", 1719792000000L, 1720396800000L, 10),
    "1719835200000;1719921600000;1720008000000;1720094400000;1720180800000;1720267200000;1720353600000",
  )
}

///|
test "cron 区窗 al-july N" {
  // z4_after ｜ pattern=0 12 ? july * ｜ zone=UTC ｜ base=1719792000000 ｜ 参照=RET 1719835200000
  assert_eq(z4_after("0 12 ? july *", "UTC", 1719792000000L), "1719835200000")
}

///|
test "cron 区窗 al-july N2" {
  // z4_next ｜ pattern=0 12 ? july * ｜ zone=UTC ｜ base=1719792000000 ｜ 参照=RET 1719835200000
  assert_eq(z4_next("0 12 ? july *", "UTC", 1719792000000L), "1719835200000")
}

///|
test "cron 区窗 al-fri C" {
  // cron_of ｜ pattern=0 12 * * FRI ｜ 参照=RET 0 12 * * FRI
  assert_eq(z4_tag("0 12 * * FRI"), "OK")
}

///|
test "cron 区窗 al-fri T" {
  // cron_pattern_text ｜ 参照 toString=0 12 * * FRI
  assert_eq(z4_text("0 12 * * FRI"), "0 12 * * FRI")
}

///|
test "cron 区窗 al-fri M" {
  // matched_dates ｜ pattern=0 12 * * FRI ｜ zone=UTC ｜ [1719792000000,1720396800000) ｜ count=10 ｜ 参照=RET 1720180800000
  assert_eq(
    z4_md("0 12 * * FRI", "UTC", 1719792000000L, 1720396800000L, 10),
    "1720180800000",
  )
}

///|
test "cron 区窗 al-fri N" {
  // z4_after ｜ pattern=0 12 * * FRI ｜ zone=UTC ｜ base=1719792000000 ｜ 参照=RET 1720180800000
  assert_eq(z4_after("0 12 * * FRI", "UTC", 1719792000000L), "1720180800000")
}

///|
test "cron 区窗 al-fri N2" {
  // z4_next ｜ pattern=0 12 * * FRI ｜ zone=UTC ｜ base=1719792000000 ｜ 参照=RET 1720180800000
  assert_eq(z4_next("0 12 * * FRI", "UTC", 1719792000000L), "1720180800000")
}

///|
test "cron 区窗 al-fri-num C" {
  // cron_of ｜ pattern=0 12 * * 5 ｜ 参照=RET 0 12 * * 5
  assert_eq(z4_tag("0 12 * * 5"), "OK")
}

///|
test "cron 区窗 al-fri-num T" {
  // cron_pattern_text ｜ 参照 toString=0 12 * * 5
  assert_eq(z4_text("0 12 * * 5"), "0 12 * * 5")
}

///|
test "cron 区窗 al-fri-num M" {
  // matched_dates ｜ pattern=0 12 * * 5 ｜ zone=UTC ｜ [1719792000000,1720396800000) ｜ count=10 ｜ 参照=RET 1720180800000
  assert_eq(
    z4_md("0 12 * * 5", "UTC", 1719792000000L, 1720396800000L, 10),
    "1720180800000",
  )
}

///|
test "cron 区窗 al-fri-num N" {
  // z4_after ｜ pattern=0 12 * * 5 ｜ zone=UTC ｜ base=1719792000000 ｜ 参照=RET 1720180800000
  assert_eq(z4_after("0 12 * * 5", "UTC", 1719792000000L), "1720180800000")
}

///|
test "cron 区窗 al-fri-num N2" {
  // z4_next ｜ pattern=0 12 * * 5 ｜ zone=UTC ｜ base=1719792000000 ｜ 参照=RET 1720180800000
  assert_eq(z4_next("0 12 * * 5", "UTC", 1719792000000L), "1720180800000")
}

///|
test "cron 区窗 al-fri-full C" {
  // cron_of ｜ pattern=0 12 * * friday ｜ 参照=RET 0 12 * * friday
  assert_eq(z4_tag("0 12 * * friday"), "OK")
}

///|
test "cron 区窗 al-fri-full T" {
  // cron_pattern_text ｜ 参照 toString=0 12 * * friday
  assert_eq(z4_text("0 12 * * friday"), "0 12 * * friday")
}

///|
test "cron 区窗 al-fri-full M" {
  // matched_dates ｜ pattern=0 12 * * friday ｜ zone=UTC ｜ [1719792000000,1720396800000) ｜ count=10 ｜ 参照=RET 1720180800000
  assert_eq(
    z4_md("0 12 * * friday", "UTC", 1719792000000L, 1720396800000L, 10),
    "1720180800000",
  )
}

///|
test "cron 区窗 al-fri-full N" {
  // z4_after ｜ pattern=0 12 * * friday ｜ zone=UTC ｜ base=1719792000000 ｜ 参照=RET 1720180800000
  assert_eq(z4_after("0 12 * * friday", "UTC", 1719792000000L), "1720180800000")
}

///|
test "cron 区窗 al-fri-full N2" {
  // z4_next ｜ pattern=0 12 * * friday ｜ zone=UTC ｜ base=1719792000000 ｜ 参照=RET 1720180800000
  assert_eq(z4_next("0 12 * * friday", "UTC", 1719792000000L), "1720180800000")
}

///|
test "cron 区窗 g-la C" {
  // cron_of ｜ pattern=0 30 2 ? 3 * ｜ 参照=RET 0 30 2 ? 3 *
  assert_eq(z4_tag("0 30 2 ? 3 *"), "OK")
}

///|
test "cron 区窗 g-la T" {
  // cron_pattern_text ｜ 参照 toString=0 30 2 ? 3 *
  assert_eq(z4_text("0 30 2 ? 3 *"), "0 30 2 ? 3 *")
}

///|
test "cron 区窗 g-la M" {
  // matched_dates ｜ pattern=0 30 2 ? 3 * ｜ zone=America/Los_Angeles ｜ [1709251200000,1709856000000) ｜ count=10 ｜ 参照=RET 1709289000000;1709375400000;1709461800000;1709548200000;1709634600000;1709721000000;1709807400000
  assert_eq(
    z4_md(
      "0 30 2 ? 3 *", "America/Los_Angeles", 1709251200000L, 1709856000000L, 10,
    ),
    "1709289000000;1709375400000;1709461800000;1709548200000;1709634600000;1709721000000;1709807400000",
  )
}

///|
test "cron 区窗 g-la N" {
  // z4_after ｜ pattern=0 30 2 ? 3 * ｜ zone=America/Los_Angeles ｜ base=1709251200000 ｜ 参照=RET 1709289000000
  assert_eq(
    z4_after("0 30 2 ? 3 *", "America/Los_Angeles", 1709251200000L),
    "1709289000000",
  )
}

///|
test "cron 区窗 g-la N2" {
  // z4_next ｜ pattern=0 30 2 ? 3 * ｜ zone=America/Los_Angeles ｜ base=1709251200000 ｜ 参照=RET 1709289000000
  assert_eq(
    z4_next("0 30 2 ? 3 *", "America/Los_Angeles", 1709251200000L),
    "1709289000000",
  )
}

///|
test "cron 区窗 g-sh C" {
  // cron_of ｜ pattern=0 30 2 ? 5 * ｜ 参照=RET 0 30 2 ? 5 *
  assert_eq(z4_tag("0 30 2 ? 5 *"), "OK")
}

///|
test "cron 区窗 g-sh T" {
  // cron_pattern_text ｜ 参照 toString=0 30 2 ? 5 *
  assert_eq(z4_text("0 30 2 ? 5 *"), "0 30 2 ? 5 *")
}

///|
test "cron 区窗 g-sh M" {
  // matched_dates ｜ pattern=0 30 2 ? 5 * ｜ zone=Asia/Shanghai ｜ [514425600000,515030000000) ｜ count=10 ｜ 参照=RET -
  assert_eq(
    z4_md("0 30 2 ? 5 *", "Asia/Shanghai", 514425600000L, 515030000000L, 10),
    "-",
  )
}

///|
test "cron 区窗 g-sh N" {
  // z4_after ｜ pattern=0 30 2 ? 5 * ｜ zone=Asia/Shanghai ｜ base=514425600000 ｜ 参照=RET 515269800000
  assert_eq(
    z4_after("0 30 2 ? 5 *", "Asia/Shanghai", 514425600000L),
    "515269800000",
  )
}

///|
test "cron 区窗 g-sh N2" {
  // z4_next ｜ pattern=0 30 2 ? 5 * ｜ zone=Asia/Shanghai ｜ base=514425600000 ｜ 参照=RET 515269800000
  assert_eq(
    z4_next("0 30 2 ? 5 *", "Asia/Shanghai", 514425600000L),
    "515269800000",
  )
}

///|
test "cron 区窗 g-ny C" {
  // cron_of ｜ pattern=0 30 1 ? 11 * ｜ 参照=RET 0 30 1 ? 11 *
  assert_eq(z4_tag("0 30 1 ? 11 *"), "OK")
}

///|
test "cron 区窗 g-ny T" {
  // cron_pattern_text ｜ 参照 toString=0 30 1 ? 11 *
  assert_eq(z4_text("0 30 1 ? 11 *"), "0 30 1 ? 11 *")
}

///|
test "cron 区窗 g-ny M" {
  // matched_dates ｜ pattern=0 30 1 ? 11 * ｜ zone=America/New_York ｜ [1729900800000,1730505600000) ｜ count=10 ｜ 参照=RET 1730439000000
  assert_eq(
    z4_md(
      "0 30 1 ? 11 *", "America/New_York", 1729900800000L, 1730505600000L, 10,
    ),
    "1730439000000",
  )
}

///|
test "cron 区窗 g-ny N" {
  // z4_after ｜ pattern=0 30 1 ? 11 * ｜ zone=America/New_York ｜ base=1729900800000 ｜ 参照=RET 1730439000000
  assert_eq(
    z4_after("0 30 1 ? 11 *", "America/New_York", 1729900800000L),
    "1730439000000",
  )
}

///|
test "cron 区窗 g-ny N2" {
  // z4_next ｜ pattern=0 30 1 ? 11 * ｜ zone=America/New_York ｜ base=1729900800000 ｜ 参照=RET 1730439000000
  assert_eq(
    z4_next("0 30 1 ? 11 *", "America/New_York", 1729900800000L),
    "1730439000000",
  )
}
