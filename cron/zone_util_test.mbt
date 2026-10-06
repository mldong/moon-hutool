///|
// moon-hutool/cron 第二批契约用例（黑盒）。**生成件，勿手改**：
// 生成器 scripts/gen_cron2_test.py，每条期望都是参照腿 scripts/Cron2Leg.java 的机器读数。
// 参照代次：JDK 17.0.14 · hutool-cron+core 5.8.35 · lib/tzdb.dat 101731 bytes · 腿的守卫自检 GUARD_DISTINCT=true。
// 三处本库改判（设年未设秒 / `count <= 0` / 窗外）集中在生成器的 DECISION_BUILDER 与两处分支里，每格都注了依据的 spec 行号与参照原读数（spec §11）。
// helper `tag` / `parse_text` 复用 cron/cron_test.mbt 的同名件（同包测试共享顶层命名空间）。

///|
// #19.19 的读数：`[毫秒|毫秒|…]`；坏区名/窗外 `null`；抛错 `ERR:<档>`
fn md_tag(
  pat : String,
  zone : String,
  st : Int64,
  en : Int64,
  n : Int,
  sec : Bool,
) -> String {
  try {
    match @cron.cron_matched_dates(@cron.cron_of(pat), zone, st, en, n, sec) {
      None => "null"
      Some(v) => {
        let parts = v.map(x => x.to_string())
        if parts.length() == 0 {
          "[]"
        } else {
          "[" + parts.join("|") + "]"
        }
      }
    }
  } catch {
    e => "ERR:" + tag(e)
  }
}

///|
// 只钉长度的一族格（腿 C 的 CB 行给的就是 size）
fn md_len_tag(
  pat : String,
  zone : String,
  st : Int64,
  en : Int64,
  n : Int,
) -> String {
  try {
    match @cron.cron_matched_dates(@cron.cron_of(pat), zone, st, en, n, false) {
      None => "null"
      Some(v) => v.length().to_string()
    }
  } catch {
    e => "ERR:" + tag(e)
  }
}

///|
// #19.17 的读数：`<毫秒>` / `null`
fn znx_tag(pat : String, zone : String, b : Int64) -> String {
  try {
    match @cron.cron_next_match_after_in(@cron.cron_of(pat), zone, b) {
      None => "null"
      Some(v) => v.to_string()
    }
  } catch {
    e => "ERR:" + tag(e)
  }
}

///|
// #19.18 的读数，形状同 znx_tag（两族成对，spec §9 第 15 条）
fn znm_tag(pat : String, zone : String, b : Int64) -> String {
  try {
    match @cron.cron_next_match_in(@cron.cron_of(pat), zone, b) {
      None => "null"
      Some(v) => v.to_string()
    }
  } catch {
    e => "ERR:" + tag(e)
  }
}

///|
test "@cron2 带区名的下一瞬间（腿 C znx_tag 行，严格晚于，第 1 块 180 条）" {
  assert_eq(znx_tag("* * * * *", "UTC", 1710050400000L), "1710050460000") // 腿 C N.star.1710050400000.UTC|参照读数 1710050460000（UTC 串 2024-03-10 06:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Shanghai", 1710050400000L),
    "1710050460000",
  ) // 腿 C N.star.1710050400000.Asia/Shanghai|参照读数 1710050460000（UTC 串 2024-03-10 06:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/New_York", 1710050400000L),
    "1710050460000",
  ) // 腿 C N.star.1710050400000.America/New_York|参照读数 1710050460000（UTC 串 2024-03-10 06:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Kathmandu", 1710050400000L),
    "1710050460000",
  ) // 腿 C N.star.1710050400000.Asia/Kathmandu|参照读数 1710050460000（UTC 串 2024-03-10 06:01:00）
  assert_eq(
    znx_tag("* * * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710050460000",
  ) // 腿 C N.star.1710050400000.Australia/Lord_Howe|参照读数 1710050460000（UTC 串 2024-03-10 06:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/Santiago", 1710050400000L),
    "1710050460000",
  ) // 腿 C N.star.1710050400000.America/Santiago|参照读数 1710050460000（UTC 串 2024-03-10 06:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Tehran", 1710050400000L),
    "1710050460000",
  ) // 腿 C N.star.1710050400000.Asia/Tehran|参照读数 1710050460000（UTC 串 2024-03-10 06:01:00）
  assert_eq(znx_tag("* * * * *", "UTC", 1730611800000L), "1730611860000") // 腿 C N.star.1730611800000.UTC|参照读数 1730611860000（UTC 串 2024-11-03 05:31:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Shanghai", 1730611800000L),
    "1730611860000",
  ) // 腿 C N.star.1730611800000.Asia/Shanghai|参照读数 1730611860000（UTC 串 2024-11-03 05:31:00）
  assert_eq(
    znx_tag("* * * * *", "America/New_York", 1730611800000L),
    "1730615460000",
  ) // 腿 C N.star.1730611800000.America/New_York|参照读数 1730615460000（UTC 串 2024-11-03 06:31:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Kathmandu", 1730611800000L),
    "1730611860000",
  ) // 腿 C N.star.1730611800000.Asia/Kathmandu|参照读数 1730611860000（UTC 串 2024-11-03 05:31:00）
  assert_eq(
    znx_tag("* * * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730611860000",
  ) // 腿 C N.star.1730611800000.Australia/Lord_Howe|参照读数 1730611860000（UTC 串 2024-11-03 05:31:00）
  assert_eq(
    znx_tag("* * * * *", "America/Santiago", 1730611800000L),
    "1730611860000",
  ) // 腿 C N.star.1730611800000.America/Santiago|参照读数 1730611860000（UTC 串 2024-11-03 05:31:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Tehran", 1730611800000L),
    "1730611860000",
  ) // 腿 C N.star.1730611800000.Asia/Tehran|参照读数 1730611860000（UTC 串 2024-11-03 05:31:00）
  assert_eq(znx_tag("* * * * *", "UTC", 1730615400000L), "1730615460000") // 腿 C N.star.1730615400000.UTC|参照读数 1730615460000（UTC 串 2024-11-03 06:31:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Shanghai", 1730615400000L),
    "1730615460000",
  ) // 腿 C N.star.1730615400000.Asia/Shanghai|参照读数 1730615460000（UTC 串 2024-11-03 06:31:00）
  assert_eq(
    znx_tag("* * * * *", "America/New_York", 1730615400000L),
    "1730615460000",
  ) // 腿 C N.star.1730615400000.America/New_York|参照读数 1730615460000（UTC 串 2024-11-03 06:31:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Kathmandu", 1730615400000L),
    "1730615460000",
  ) // 腿 C N.star.1730615400000.Asia/Kathmandu|参照读数 1730615460000（UTC 串 2024-11-03 06:31:00）
  assert_eq(
    znx_tag("* * * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730615460000",
  ) // 腿 C N.star.1730615400000.Australia/Lord_Howe|参照读数 1730615460000（UTC 串 2024-11-03 06:31:00）
  assert_eq(
    znx_tag("* * * * *", "America/Santiago", 1730615400000L),
    "1730615460000",
  ) // 腿 C N.star.1730615400000.America/Santiago|参照读数 1730615460000（UTC 串 2024-11-03 06:31:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Tehran", 1730615400000L),
    "1730615460000",
  ) // 腿 C N.star.1730615400000.Asia/Tehran|参照读数 1730615460000（UTC 串 2024-11-03 06:31:00）
  assert_eq(znx_tag("* * * * *", "UTC", 1709208000000L), "1709208060000") // 腿 C N.star.1709208000000.UTC|参照读数 1709208060000（UTC 串 2024-02-29 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Shanghai", 1709208000000L),
    "1709208060000",
  ) // 腿 C N.star.1709208000000.Asia/Shanghai|参照读数 1709208060000（UTC 串 2024-02-29 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/New_York", 1709208000000L),
    "1709208060000",
  ) // 腿 C N.star.1709208000000.America/New_York|参照读数 1709208060000（UTC 串 2024-02-29 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Kathmandu", 1709208000000L),
    "1709208060000",
  ) // 腿 C N.star.1709208000000.Asia/Kathmandu|参照读数 1709208060000（UTC 串 2024-02-29 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709208060000",
  ) // 腿 C N.star.1709208000000.Australia/Lord_Howe|参照读数 1709208060000（UTC 串 2024-02-29 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/Santiago", 1709208000000L),
    "1709208060000",
  ) // 腿 C N.star.1709208000000.America/Santiago|参照读数 1709208060000（UTC 串 2024-02-29 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Tehran", 1709208000000L),
    "1709208060000",
  ) // 腿 C N.star.1709208000000.Asia/Tehran|参照读数 1709208060000（UTC 串 2024-02-29 12:01:00）
  assert_eq(znx_tag("* * * * *", "UTC", 1714435200000L), "1714435260000") // 腿 C N.star.1714435200000.UTC|参照读数 1714435260000（UTC 串 2024-04-30 00:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Shanghai", 1714435200000L),
    "1714435260000",
  ) // 腿 C N.star.1714435200000.Asia/Shanghai|参照读数 1714435260000（UTC 串 2024-04-30 00:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/New_York", 1714435200000L),
    "1714435260000",
  ) // 腿 C N.star.1714435200000.America/New_York|参照读数 1714435260000（UTC 串 2024-04-30 00:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Kathmandu", 1714435200000L),
    "1714435260000",
  ) // 腿 C N.star.1714435200000.Asia/Kathmandu|参照读数 1714435260000（UTC 串 2024-04-30 00:01:00）
  assert_eq(
    znx_tag("* * * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714435260000",
  ) // 腿 C N.star.1714435200000.Australia/Lord_Howe|参照读数 1714435260000（UTC 串 2024-04-30 00:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/Santiago", 1714435200000L),
    "1714435260000",
  ) // 腿 C N.star.1714435200000.America/Santiago|参照读数 1714435260000（UTC 串 2024-04-30 00:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Tehran", 1714435200000L),
    "1714435260000",
  ) // 腿 C N.star.1714435200000.Asia/Tehran|参照读数 1714435260000（UTC 串 2024-04-30 00:01:00）
  assert_eq(znx_tag("* * * * *", "UTC", 515554200000L), "515554260000") // 腿 C N.star.515554200000.UTC|参照读数 515554260000（UTC 串 1986-05-04 01:31:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Shanghai", 515554200000L),
    "515554260000",
  ) // 腿 C N.star.515554200000.Asia/Shanghai|参照读数 515554260000（UTC 串 1986-05-04 01:31:00）
  assert_eq(
    znx_tag("* * * * *", "America/New_York", 515554200000L),
    "515554260000",
  ) // 腿 C N.star.515554200000.America/New_York|参照读数 515554260000（UTC 串 1986-05-04 01:31:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Kathmandu", 515554200000L),
    "515554260000",
  ) // 腿 C N.star.515554200000.Asia/Kathmandu|参照读数 515554260000（UTC 串 1986-05-04 01:31:00）
  assert_eq(
    znx_tag("* * * * *", "Australia/Lord_Howe", 515554200000L),
    "515554260000",
  ) // 腿 C N.star.515554200000.Australia/Lord_Howe|参照读数 515554260000（UTC 串 1986-05-04 01:31:00）
  assert_eq(
    znx_tag("* * * * *", "America/Santiago", 515554200000L),
    "515554260000",
  ) // 腿 C N.star.515554200000.America/Santiago|参照读数 515554260000（UTC 串 1986-05-04 01:31:00）
  assert_eq(znx_tag("* * * * *", "Asia/Tehran", 515554200000L), "515554260000") // 腿 C N.star.515554200000.Asia/Tehran|参照读数 515554260000（UTC 串 1986-05-04 01:31:00）
  assert_eq(znx_tag("* * * * *", "UTC", 4070822400000L), "null") // 腿 C N.star.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070822460000｜UTC 2098-12-31 00:01:00，spec §11 第 4 行）
  assert_eq(znx_tag("* * * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N.star.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070822460000｜UTC 2098-12-31 00:01:00，spec §11 第 4 行）
  assert_eq(znx_tag("* * * * *", "America/New_York", 4070822400000L), "null") // 腿 C N.star.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070822460000｜UTC 2098-12-31 00:01:00，spec §11 第 4 行）
  assert_eq(znx_tag("* * * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N.star.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070822460000｜UTC 2098-12-31 00:01:00，spec §11 第 4 行）
  assert_eq(znx_tag("* * * * *", "Australia/Lord_Howe", 4070822400000L), "null") // 腿 C N.star.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070822460000｜UTC 2098-12-31 00:01:00，spec §11 第 4 行）
  assert_eq(znx_tag("* * * * *", "America/Santiago", 4070822400000L), "null") // 腿 C N.star.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070822460000｜UTC 2098-12-31 00:01:00，spec §11 第 4 行）
  assert_eq(znx_tag("* * * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.star.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070822460000｜UTC 2098-12-31 00:01:00，spec §11 第 4 行）
  assert_eq(znx_tag("* * * * *", "UTC", 1730606400000L), "1730606460000") // 腿 C N.star.1730606400000.UTC|参照读数 1730606460000（UTC 串 2024-11-03 04:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Shanghai", 1730606400000L),
    "1730606460000",
  ) // 腿 C N.star.1730606400000.Asia/Shanghai|参照读数 1730606460000（UTC 串 2024-11-03 04:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/New_York", 1730606400000L),
    "1730606460000",
  ) // 腿 C N.star.1730606400000.America/New_York|参照读数 1730606460000（UTC 串 2024-11-03 04:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Kathmandu", 1730606400000L),
    "1730606460000",
  ) // 腿 C N.star.1730606400000.Asia/Kathmandu|参照读数 1730606460000（UTC 串 2024-11-03 04:01:00）
  assert_eq(
    znx_tag("* * * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730606460000",
  ) // 腿 C N.star.1730606400000.Australia/Lord_Howe|参照读数 1730606460000（UTC 串 2024-11-03 04:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/Santiago", 1730606400000L),
    "1730606460000",
  ) // 腿 C N.star.1730606400000.America/Santiago|参照读数 1730606460000（UTC 串 2024-11-03 04:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Tehran", 1730606400000L),
    "1730606460000",
  ) // 腿 C N.star.1730606400000.Asia/Tehran|参照读数 1730606460000（UTC 串 2024-11-03 04:01:00）
  assert_eq(znx_tag("* * * * *", "UTC", 1709985600000L), "1709985660000") // 腿 C N.star.1709985600000.UTC|参照读数 1709985660000（UTC 串 2024-03-09 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Shanghai", 1709985600000L),
    "1709985660000",
  ) // 腿 C N.star.1709985600000.Asia/Shanghai|参照读数 1709985660000（UTC 串 2024-03-09 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/New_York", 1709985600000L),
    "1709985660000",
  ) // 腿 C N.star.1709985600000.America/New_York|参照读数 1709985660000（UTC 串 2024-03-09 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Kathmandu", 1709985600000L),
    "1709985660000",
  ) // 腿 C N.star.1709985600000.Asia/Kathmandu|参照读数 1709985660000（UTC 串 2024-03-09 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709985660000",
  ) // 腿 C N.star.1709985600000.Australia/Lord_Howe|参照读数 1709985660000（UTC 串 2024-03-09 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/Santiago", 1709985600000L),
    "1709985660000",
  ) // 腿 C N.star.1709985600000.America/Santiago|参照读数 1709985660000（UTC 串 2024-03-09 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Tehran", 1709985600000L),
    "1709985660000",
  ) // 腿 C N.star.1709985600000.Asia/Tehran|参照读数 1709985660000（UTC 串 2024-03-09 12:01:00）
  assert_eq(znx_tag("* * * * *", "UTC", 1730548800000L), "1730548860000") // 腿 C N.star.1730548800000.UTC|参照读数 1730548860000（UTC 串 2024-11-02 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Shanghai", 1730548800000L),
    "1730548860000",
  ) // 腿 C N.star.1730548800000.Asia/Shanghai|参照读数 1730548860000（UTC 串 2024-11-02 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/New_York", 1730548800000L),
    "1730548860000",
  ) // 腿 C N.star.1730548800000.America/New_York|参照读数 1730548860000（UTC 串 2024-11-02 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Kathmandu", 1730548800000L),
    "1730548860000",
  ) // 腿 C N.star.1730548800000.Asia/Kathmandu|参照读数 1730548860000（UTC 串 2024-11-02 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730548860000",
  ) // 腿 C N.star.1730548800000.Australia/Lord_Howe|参照读数 1730548860000（UTC 串 2024-11-02 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/Santiago", 1730548800000L),
    "1730548860000",
  ) // 腿 C N.star.1730548800000.America/Santiago|参照读数 1730548860000（UTC 串 2024-11-02 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Tehran", 1730548800000L),
    "1730548860000",
  ) // 腿 C N.star.1730548800000.Asia/Tehran|参照读数 1730548860000（UTC 串 2024-11-02 12:01:00）
  assert_eq(znx_tag("* * * * *", "UTC", 515505600000L), "515505660000") // 腿 C N.star.515505600000.UTC|参照读数 515505660000（UTC 串 1986-05-03 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Shanghai", 515505600000L),
    "515505660000",
  ) // 腿 C N.star.515505600000.Asia/Shanghai|参照读数 515505660000（UTC 串 1986-05-03 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/New_York", 515505600000L),
    "515505660000",
  ) // 腿 C N.star.515505600000.America/New_York|参照读数 515505660000（UTC 串 1986-05-03 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Kathmandu", 515505600000L),
    "515505660000",
  ) // 腿 C N.star.515505600000.Asia/Kathmandu|参照读数 515505660000（UTC 串 1986-05-03 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Australia/Lord_Howe", 515505600000L),
    "515505660000",
  ) // 腿 C N.star.515505600000.Australia/Lord_Howe|参照读数 515505660000（UTC 串 1986-05-03 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/Santiago", 515505600000L),
    "515505660000",
  ) // 腿 C N.star.515505600000.America/Santiago|参照读数 515505660000（UTC 串 1986-05-03 12:01:00）
  assert_eq(znx_tag("* * * * *", "Asia/Tehran", 515505600000L), "515505660000") // 腿 C N.star.515505600000.Asia/Tehran|参照读数 515505660000（UTC 串 1986-05-03 12:01:00）
  assert_eq(znx_tag("* * * * *", "UTC", 1725710400000L), "1725710460000") // 腿 C N.star.1725710400000.UTC|参照读数 1725710460000（UTC 串 2024-09-07 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Shanghai", 1725710400000L),
    "1725710460000",
  ) // 腿 C N.star.1725710400000.Asia/Shanghai|参照读数 1725710460000（UTC 串 2024-09-07 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/New_York", 1725710400000L),
    "1725710460000",
  ) // 腿 C N.star.1725710400000.America/New_York|参照读数 1725710460000（UTC 串 2024-09-07 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Kathmandu", 1725710400000L),
    "1725710460000",
  ) // 腿 C N.star.1725710400000.Asia/Kathmandu|参照读数 1725710460000（UTC 串 2024-09-07 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725710460000",
  ) // 腿 C N.star.1725710400000.Australia/Lord_Howe|参照读数 1725710460000（UTC 串 2024-09-07 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/Santiago", 1725710400000L),
    "1725710460000",
  ) // 腿 C N.star.1725710400000.America/Santiago|参照读数 1725710460000（UTC 串 2024-09-07 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Tehran", 1725710400000L),
    "1725710460000",
  ) // 腿 C N.star.1725710400000.Asia/Tehran|参照读数 1725710460000（UTC 串 2024-09-07 12:01:00）
  assert_eq(znx_tag("* * * * *", "UTC", 1647864000000L), "1647864060000") // 腿 C N.star.1647864000000.UTC|参照读数 1647864060000（UTC 串 2022-03-21 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Shanghai", 1647864000000L),
    "1647864060000",
  ) // 腿 C N.star.1647864000000.Asia/Shanghai|参照读数 1647864060000（UTC 串 2022-03-21 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/New_York", 1647864000000L),
    "1647864060000",
  ) // 腿 C N.star.1647864000000.America/New_York|参照读数 1647864060000（UTC 串 2022-03-21 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Kathmandu", 1647864000000L),
    "1647864060000",
  ) // 腿 C N.star.1647864000000.Asia/Kathmandu|参照读数 1647864060000（UTC 串 2022-03-21 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647864060000",
  ) // 腿 C N.star.1647864000000.Australia/Lord_Howe|参照读数 1647864060000（UTC 串 2022-03-21 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "America/Santiago", 1647864000000L),
    "1647864060000",
  ) // 腿 C N.star.1647864000000.America/Santiago|参照读数 1647864060000（UTC 串 2022-03-21 12:01:00）
  assert_eq(
    znx_tag("* * * * *", "Asia/Tehran", 1647864000000L),
    "1647864060000",
  ) // 腿 C N.star.1647864000000.Asia/Tehran|参照读数 1647864060000（UTC 串 2022-03-21 12:01:00）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 1710050400000L), "1710120600000") // 腿 C N.daily_0130.1710050400000.UTC|参照读数 1710120600000（UTC 串 2024-03-11 01:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Shanghai", 1710050400000L),
    "1710091800000",
  ) // 腿 C N.daily_0130.1710050400000.Asia/Shanghai|参照读数 1710091800000（UTC 串 2024-03-10 17:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/New_York", 1710050400000L),
    "1710052200000",
  ) // 腿 C N.daily_0130.1710050400000.America/New_York|参照读数 1710052200000（UTC 串 2024-03-10 06:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Kathmandu", 1710050400000L),
    "1710099900000",
  ) // 腿 C N.daily_0130.1710050400000.Asia/Kathmandu|参照读数 1710099900000（UTC 串 2024-03-10 19:45:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710081000000",
  ) // 腿 C N.daily_0130.1710050400000.Australia/Lord_Howe|参照读数 1710081000000（UTC 串 2024-03-10 14:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/Santiago", 1710050400000L),
    "1710131400000",
  ) // 腿 C N.daily_0130.1710050400000.America/Santiago|参照读数 1710131400000（UTC 串 2024-03-11 04:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Tehran", 1710050400000L),
    "1710108000000",
  ) // 腿 C N.daily_0130.1710050400000.Asia/Tehran|参照读数 1710108000000（UTC 串 2024-03-10 22:00:00）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 1730611800000L), "1730683800000") // 腿 C N.daily_0130.1730611800000.UTC|参照读数 1730683800000（UTC 串 2024-11-04 01:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Shanghai", 1730611800000L),
    "1730655000000",
  ) // 腿 C N.daily_0130.1730611800000.Asia/Shanghai|参照读数 1730655000000（UTC 串 2024-11-03 17:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/New_York", 1730611800000L),
    "1730701800000",
  ) // 腿 C N.daily_0130.1730611800000.America/New_York|参照读数 1730701800000（UTC 串 2024-11-04 06:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Kathmandu", 1730611800000L),
    "1730663100000",
  ) // 腿 C N.daily_0130.1730611800000.Asia/Kathmandu|参照读数 1730663100000（UTC 串 2024-11-03 19:45:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730644200000",
  ) // 腿 C N.daily_0130.1730611800000.Australia/Lord_Howe|参照读数 1730644200000（UTC 串 2024-11-03 14:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/Santiago", 1730611800000L),
    "1730694600000",
  ) // 腿 C N.daily_0130.1730611800000.America/Santiago|参照读数 1730694600000（UTC 串 2024-11-04 04:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Tehran", 1730611800000L),
    "1730671200000",
  ) // 腿 C N.daily_0130.1730611800000.Asia/Tehran|参照读数 1730671200000（UTC 串 2024-11-03 22:00:00）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 1730615400000L), "1730683800000") // 腿 C N.daily_0130.1730615400000.UTC|参照读数 1730683800000（UTC 串 2024-11-04 01:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Shanghai", 1730615400000L),
    "1730655000000",
  ) // 腿 C N.daily_0130.1730615400000.Asia/Shanghai|参照读数 1730655000000（UTC 串 2024-11-03 17:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/New_York", 1730615400000L),
    "1730701800000",
  ) // 腿 C N.daily_0130.1730615400000.America/New_York|参照读数 1730701800000（UTC 串 2024-11-04 06:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Kathmandu", 1730615400000L),
    "1730663100000",
  ) // 腿 C N.daily_0130.1730615400000.Asia/Kathmandu|参照读数 1730663100000（UTC 串 2024-11-03 19:45:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730644200000",
  ) // 腿 C N.daily_0130.1730615400000.Australia/Lord_Howe|参照读数 1730644200000（UTC 串 2024-11-03 14:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/Santiago", 1730615400000L),
    "1730694600000",
  ) // 腿 C N.daily_0130.1730615400000.America/Santiago|参照读数 1730694600000（UTC 串 2024-11-04 04:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Tehran", 1730615400000L),
    "1730671200000",
  ) // 腿 C N.daily_0130.1730615400000.Asia/Tehran|参照读数 1730671200000（UTC 串 2024-11-03 22:00:00）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 1709208000000L), "1709256600000") // 腿 C N.daily_0130.1709208000000.UTC|参照读数 1709256600000（UTC 串 2024-03-01 01:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Shanghai", 1709208000000L),
    "1709227800000",
  ) // 腿 C N.daily_0130.1709208000000.Asia/Shanghai|参照读数 1709227800000（UTC 串 2024-02-29 17:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/New_York", 1709208000000L),
    "1709274600000",
  ) // 腿 C N.daily_0130.1709208000000.America/New_York|参照读数 1709274600000（UTC 串 2024-03-01 06:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Kathmandu", 1709208000000L),
    "1709235900000",
  ) // 腿 C N.daily_0130.1709208000000.Asia/Kathmandu|参照读数 1709235900000（UTC 串 2024-02-29 19:45:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709217000000",
  ) // 腿 C N.daily_0130.1709208000000.Australia/Lord_Howe|参照读数 1709217000000（UTC 串 2024-02-29 14:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/Santiago", 1709208000000L),
    "1709267400000",
  ) // 腿 C N.daily_0130.1709208000000.America/Santiago|参照读数 1709267400000（UTC 串 2024-03-01 04:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Tehran", 1709208000000L),
    "1709244000000",
  ) // 腿 C N.daily_0130.1709208000000.Asia/Tehran|参照读数 1709244000000（UTC 串 2024-02-29 22:00:00）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 1714435200000L), "1714440600000") // 腿 C N.daily_0130.1714435200000.UTC|参照读数 1714440600000（UTC 串 2024-04-30 01:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Shanghai", 1714435200000L),
    "1714498200000",
  ) // 腿 C N.daily_0130.1714435200000.Asia/Shanghai|参照读数 1714498200000（UTC 串 2024-04-30 17:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/New_York", 1714435200000L),
    "1714455000000",
  ) // 腿 C N.daily_0130.1714435200000.America/New_York|参照读数 1714455000000（UTC 串 2024-04-30 05:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Kathmandu", 1714435200000L),
    "1714506300000",
  ) // 腿 C N.daily_0130.1714435200000.Asia/Kathmandu|参照读数 1714506300000（UTC 串 2024-04-30 19:45:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714489200000",
  ) // 腿 C N.daily_0130.1714435200000.Australia/Lord_Howe|参照读数 1714489200000（UTC 串 2024-04-30 15:00:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/Santiago", 1714435200000L),
    "1714455000000",
  ) // 腿 C N.daily_0130.1714435200000.America/Santiago|参照读数 1714455000000（UTC 串 2024-04-30 05:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Tehran", 1714435200000L),
    "1714514400000",
  ) // 腿 C N.daily_0130.1714435200000.Asia/Tehran|参照读数 1714514400000（UTC 串 2024-04-30 22:00:00）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 515554200000L), "515640600000") // 腿 C N.daily_0130.515554200000.UTC|参照读数 515640600000（UTC 串 1986-05-05 01:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Shanghai", 515554200000L),
    "515608200000",
  ) // 腿 C N.daily_0130.515554200000.Asia/Shanghai|参照读数 515608200000（UTC 串 1986-05-04 16:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/New_York", 515554200000L),
    "515568600000",
  ) // 腿 C N.daily_0130.515554200000.America/New_York|参照读数 515568600000（UTC 串 1986-05-04 05:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Kathmandu", 515554200000L),
    "515619900000",
  ) // 腿 C N.daily_0130.515554200000.Asia/Kathmandu|参照读数 515619900000（UTC 串 1986-05-04 19:45:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 515554200000L),
    "515602800000",
  ) // 腿 C N.daily_0130.515554200000.Australia/Lord_Howe|参照读数 515602800000（UTC 串 1986-05-04 15:00:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/Santiago", 515554200000L),
    "515568600000",
  ) // 腿 C N.daily_0130.515554200000.America/Santiago|参照读数 515568600000（UTC 串 1986-05-04 05:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Tehran", 515554200000L),
    "515628000000",
  ) // 腿 C N.daily_0130.515554200000.Asia/Tehran|参照读数 515628000000（UTC 串 1986-05-04 22:00:00）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 4070822400000L), "null") // 腿 C N.daily_0130.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070827800000｜UTC 2098-12-31 01:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 1 * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N.daily_0130.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070885400000｜UTC 2098-12-31 17:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 1 * * *", "America/New_York", 4070822400000L), "null") // 腿 C N.daily_0130.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070845800000｜UTC 2098-12-31 06:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 1 * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N.daily_0130.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070893500000｜UTC 2098-12-31 19:45:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N.daily_0130.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070874600000｜UTC 2098-12-31 14:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 1 * * *", "America/Santiago", 4070822400000L), "null") // 腿 C N.daily_0130.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070838600000｜UTC 2098-12-31 04:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 1 * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.daily_0130.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070901600000｜UTC 2098-12-31 22:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 1730606400000L), "1730683800000") // 腿 C N.daily_0130.1730606400000.UTC|参照读数 1730683800000（UTC 串 2024-11-04 01:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Shanghai", 1730606400000L),
    "1730655000000",
  ) // 腿 C N.daily_0130.1730606400000.Asia/Shanghai|参照读数 1730655000000（UTC 串 2024-11-03 17:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/New_York", 1730606400000L),
    "1730615400000",
  ) // 腿 C N.daily_0130.1730606400000.America/New_York|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Kathmandu", 1730606400000L),
    "1730663100000",
  ) // 腿 C N.daily_0130.1730606400000.Asia/Kathmandu|参照读数 1730663100000（UTC 串 2024-11-03 19:45:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730644200000",
  ) // 腿 C N.daily_0130.1730606400000.Australia/Lord_Howe|参照读数 1730644200000（UTC 串 2024-11-03 14:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/Santiago", 1730606400000L),
    "1730608200000",
  ) // 腿 C N.daily_0130.1730606400000.America/Santiago|参照读数 1730608200000（UTC 串 2024-11-03 04:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Tehran", 1730606400000L),
    "1730671200000",
  ) // 腿 C N.daily_0130.1730606400000.Asia/Tehran|参照读数 1730671200000（UTC 串 2024-11-03 22:00:00）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 1709985600000L), "1710034200000") // 腿 C N.daily_0130.1709985600000.UTC|参照读数 1710034200000（UTC 串 2024-03-10 01:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Shanghai", 1709985600000L),
    "1710005400000",
  ) // 腿 C N.daily_0130.1709985600000.Asia/Shanghai|参照读数 1710005400000（UTC 串 2024-03-09 17:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/New_York", 1709985600000L),
    "1710052200000",
  ) // 腿 C N.daily_0130.1709985600000.America/New_York|参照读数 1710052200000（UTC 串 2024-03-10 06:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Kathmandu", 1709985600000L),
    "1710013500000",
  ) // 腿 C N.daily_0130.1709985600000.Asia/Kathmandu|参照读数 1710013500000（UTC 串 2024-03-09 19:45:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709994600000",
  ) // 腿 C N.daily_0130.1709985600000.Australia/Lord_Howe|参照读数 1709994600000（UTC 串 2024-03-09 14:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/Santiago", 1709985600000L),
    "1710045000000",
  ) // 腿 C N.daily_0130.1709985600000.America/Santiago|参照读数 1710045000000（UTC 串 2024-03-10 04:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Tehran", 1709985600000L),
    "1710021600000",
  ) // 腿 C N.daily_0130.1709985600000.Asia/Tehran|参照读数 1710021600000（UTC 串 2024-03-09 22:00:00）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 1730548800000L), "1730597400000") // 腿 C N.daily_0130.1730548800000.UTC|参照读数 1730597400000（UTC 串 2024-11-03 01:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Shanghai", 1730548800000L),
    "1730568600000",
  ) // 腿 C N.daily_0130.1730548800000.Asia/Shanghai|参照读数 1730568600000（UTC 串 2024-11-02 17:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/New_York", 1730548800000L),
    "1730615400000",
  ) // 腿 C N.daily_0130.1730548800000.America/New_York|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Kathmandu", 1730548800000L),
    "1730576700000",
  ) // 腿 C N.daily_0130.1730548800000.Asia/Kathmandu|参照读数 1730576700000（UTC 串 2024-11-02 19:45:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730557800000",
  ) // 腿 C N.daily_0130.1730548800000.Australia/Lord_Howe|参照读数 1730557800000（UTC 串 2024-11-02 14:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/Santiago", 1730548800000L),
    "1730608200000",
  ) // 腿 C N.daily_0130.1730548800000.America/Santiago|参照读数 1730608200000（UTC 串 2024-11-03 04:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Tehran", 1730548800000L),
    "1730584800000",
  ) // 腿 C N.daily_0130.1730548800000.Asia/Tehran|参照读数 1730584800000（UTC 串 2024-11-02 22:00:00）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 515505600000L), "515554200000") // 腿 C N.daily_0130.515505600000.UTC|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Shanghai", 515505600000L),
    "515525400000",
  ) // 腿 C N.daily_0130.515505600000.Asia/Shanghai|参照读数 515525400000（UTC 串 1986-05-03 17:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/New_York", 515505600000L),
    "515568600000",
  ) // 腿 C N.daily_0130.515505600000.America/New_York|参照读数 515568600000（UTC 串 1986-05-04 05:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Kathmandu", 515505600000L),
    "515533500000",
  ) // 腿 C N.daily_0130.515505600000.Asia/Kathmandu|参照读数 515533500000（UTC 串 1986-05-03 19:45:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 515505600000L),
    "515516400000",
  ) // 腿 C N.daily_0130.515505600000.Australia/Lord_Howe|参照读数 515516400000（UTC 串 1986-05-03 15:00:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/Santiago", 515505600000L),
    "515568600000",
  ) // 腿 C N.daily_0130.515505600000.America/Santiago|参照读数 515568600000（UTC 串 1986-05-04 05:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Tehran", 515505600000L),
    "515541600000",
  ) // 腿 C N.daily_0130.515505600000.Asia/Tehran|参照读数 515541600000（UTC 串 1986-05-03 22:00:00）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 1725710400000L), "1725759000000") // 腿 C N.daily_0130.1725710400000.UTC|参照读数 1725759000000（UTC 串 2024-09-08 01:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Shanghai", 1725710400000L),
    "1725730200000",
  ) // 腿 C N.daily_0130.1725710400000.Asia/Shanghai|参照读数 1725730200000（UTC 串 2024-09-07 17:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/New_York", 1725710400000L),
    "1725773400000",
  ) // 腿 C N.daily_0130.1725710400000.America/New_York|参照读数 1725773400000（UTC 串 2024-09-08 05:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Kathmandu", 1725710400000L),
    "1725738300000",
  ) // 腿 C N.daily_0130.1725710400000.Asia/Kathmandu|参照读数 1725738300000（UTC 串 2024-09-07 19:45:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725721200000",
  ) // 腿 C N.daily_0130.1725710400000.Australia/Lord_Howe|参照读数 1725721200000（UTC 串 2024-09-07 15:00:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/Santiago", 1725710400000L),
    "1725769800000",
  ) // 腿 C N.daily_0130.1725710400000.America/Santiago|参照读数 1725769800000（UTC 串 2024-09-08 04:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Tehran", 1725710400000L),
    "1725746400000",
  ) // 腿 C N.daily_0130.1725710400000.Asia/Tehran|参照读数 1725746400000（UTC 串 2024-09-07 22:00:00）
  assert_eq(znx_tag("0 30 1 * * *", "UTC", 1647864000000L), "1647912600000") // 腿 C N.daily_0130.1647864000000.UTC|参照读数 1647912600000（UTC 串 2022-03-22 01:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Shanghai", 1647864000000L),
    "1647883800000",
  ) // 腿 C N.daily_0130.1647864000000.Asia/Shanghai|参照读数 1647883800000（UTC 串 2022-03-21 17:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "America/New_York", 1647864000000L),
    "1647927000000",
  ) // 腿 C N.daily_0130.1647864000000.America/New_York|参照读数 1647927000000（UTC 串 2022-03-22 05:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Kathmandu", 1647864000000L),
    "1647891900000",
  ) // 腿 C N.daily_0130.1647864000000.Asia/Kathmandu|参照读数 1647891900000（UTC 串 2022-03-21 19:45:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647873000000",
  ) // 腿 C N.daily_0130.1647864000000.Australia/Lord_Howe|参照读数 1647873000000（UTC 串 2022-03-21 14:30:00）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znx_tag 行，严格晚于，第 2 块 180 条）" {
  assert_eq(
    znx_tag("0 30 1 * * *", "America/Santiago", 1647864000000L),
    "1647923400000",
  ) // 腿 C N.daily_0130.1647864000000.America/Santiago|参照读数 1647923400000（UTC 串 2022-03-22 04:30:00）
  assert_eq(
    znx_tag("0 30 1 * * *", "Asia/Tehran", 1647864000000L),
    "1647896400000",
  ) // 腿 C N.daily_0130.1647864000000.Asia/Tehran|参照读数 1647896400000（UTC 串 2022-03-21 21:00:00）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 1710050400000L), "1710124200000") // 腿 C N.daily_0230.1710050400000.UTC|参照读数 1710124200000（UTC 串 2024-03-11 02:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Shanghai", 1710050400000L),
    "1710095400000",
  ) // 腿 C N.daily_0230.1710050400000.Asia/Shanghai|参照读数 1710095400000（UTC 串 2024-03-10 18:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/New_York", 1710050400000L),
    "1710138600000",
  ) // 腿 C N.daily_0230.1710050400000.America/New_York|参照读数 1710138600000（UTC 串 2024-03-11 06:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Kathmandu", 1710050400000L),
    "1710103500000",
  ) // 腿 C N.daily_0230.1710050400000.Asia/Kathmandu|参照读数 1710103500000（UTC 串 2024-03-10 20:45:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710084600000",
  ) // 腿 C N.daily_0230.1710050400000.Australia/Lord_Howe|参照读数 1710084600000（UTC 串 2024-03-10 15:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/Santiago", 1710050400000L),
    "1710135000000",
  ) // 腿 C N.daily_0230.1710050400000.America/Santiago|参照读数 1710135000000（UTC 串 2024-03-11 05:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Tehran", 1710050400000L),
    "1710111600000",
  ) // 腿 C N.daily_0230.1710050400000.Asia/Tehran|参照读数 1710111600000（UTC 串 2024-03-10 23:00:00）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 1730611800000L), "1730687400000") // 腿 C N.daily_0230.1730611800000.UTC|参照读数 1730687400000（UTC 串 2024-11-04 02:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Shanghai", 1730611800000L),
    "1730658600000",
  ) // 腿 C N.daily_0230.1730611800000.Asia/Shanghai|参照读数 1730658600000（UTC 串 2024-11-03 18:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/New_York", 1730611800000L),
    "1730619000000",
  ) // 腿 C N.daily_0230.1730611800000.America/New_York|参照读数 1730619000000（UTC 串 2024-11-03 07:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Kathmandu", 1730611800000L),
    "1730666700000",
  ) // 腿 C N.daily_0230.1730611800000.Asia/Kathmandu|参照读数 1730666700000（UTC 串 2024-11-03 20:45:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730647800000",
  ) // 腿 C N.daily_0230.1730611800000.Australia/Lord_Howe|参照读数 1730647800000（UTC 串 2024-11-03 15:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/Santiago", 1730611800000L),
    "1730698200000",
  ) // 腿 C N.daily_0230.1730611800000.America/Santiago|参照读数 1730698200000（UTC 串 2024-11-04 05:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Tehran", 1730611800000L),
    "1730674800000",
  ) // 腿 C N.daily_0230.1730611800000.Asia/Tehran|参照读数 1730674800000（UTC 串 2024-11-03 23:00:00）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 1730615400000L), "1730687400000") // 腿 C N.daily_0230.1730615400000.UTC|参照读数 1730687400000（UTC 串 2024-11-04 02:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Shanghai", 1730615400000L),
    "1730658600000",
  ) // 腿 C N.daily_0230.1730615400000.Asia/Shanghai|参照读数 1730658600000（UTC 串 2024-11-03 18:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/New_York", 1730615400000L),
    "1730619000000",
  ) // 腿 C N.daily_0230.1730615400000.America/New_York|参照读数 1730619000000（UTC 串 2024-11-03 07:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Kathmandu", 1730615400000L),
    "1730666700000",
  ) // 腿 C N.daily_0230.1730615400000.Asia/Kathmandu|参照读数 1730666700000（UTC 串 2024-11-03 20:45:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730647800000",
  ) // 腿 C N.daily_0230.1730615400000.Australia/Lord_Howe|参照读数 1730647800000（UTC 串 2024-11-03 15:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/Santiago", 1730615400000L),
    "1730698200000",
  ) // 腿 C N.daily_0230.1730615400000.America/Santiago|参照读数 1730698200000（UTC 串 2024-11-04 05:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Tehran", 1730615400000L),
    "1730674800000",
  ) // 腿 C N.daily_0230.1730615400000.Asia/Tehran|参照读数 1730674800000（UTC 串 2024-11-03 23:00:00）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 1709208000000L), "1709260200000") // 腿 C N.daily_0230.1709208000000.UTC|参照读数 1709260200000（UTC 串 2024-03-01 02:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Shanghai", 1709208000000L),
    "1709231400000",
  ) // 腿 C N.daily_0230.1709208000000.Asia/Shanghai|参照读数 1709231400000（UTC 串 2024-02-29 18:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/New_York", 1709208000000L),
    "1709278200000",
  ) // 腿 C N.daily_0230.1709208000000.America/New_York|参照读数 1709278200000（UTC 串 2024-03-01 07:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Kathmandu", 1709208000000L),
    "1709239500000",
  ) // 腿 C N.daily_0230.1709208000000.Asia/Kathmandu|参照读数 1709239500000（UTC 串 2024-02-29 20:45:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709220600000",
  ) // 腿 C N.daily_0230.1709208000000.Australia/Lord_Howe|参照读数 1709220600000（UTC 串 2024-02-29 15:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/Santiago", 1709208000000L),
    "1709271000000",
  ) // 腿 C N.daily_0230.1709208000000.America/Santiago|参照读数 1709271000000（UTC 串 2024-03-01 05:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Tehran", 1709208000000L),
    "1709247600000",
  ) // 腿 C N.daily_0230.1709208000000.Asia/Tehran|参照读数 1709247600000（UTC 串 2024-02-29 23:00:00）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 1714435200000L), "1714444200000") // 腿 C N.daily_0230.1714435200000.UTC|参照读数 1714444200000（UTC 串 2024-04-30 02:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Shanghai", 1714435200000L),
    "1714501800000",
  ) // 腿 C N.daily_0230.1714435200000.Asia/Shanghai|参照读数 1714501800000（UTC 串 2024-04-30 18:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/New_York", 1714435200000L),
    "1714458600000",
  ) // 腿 C N.daily_0230.1714435200000.America/New_York|参照读数 1714458600000（UTC 串 2024-04-30 06:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Kathmandu", 1714435200000L),
    "1714509900000",
  ) // 腿 C N.daily_0230.1714435200000.Asia/Kathmandu|参照读数 1714509900000（UTC 串 2024-04-30 20:45:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714492800000",
  ) // 腿 C N.daily_0230.1714435200000.Australia/Lord_Howe|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/Santiago", 1714435200000L),
    "1714458600000",
  ) // 腿 C N.daily_0230.1714435200000.America/Santiago|参照读数 1714458600000（UTC 串 2024-04-30 06:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Tehran", 1714435200000L),
    "1714518000000",
  ) // 腿 C N.daily_0230.1714435200000.Asia/Tehran|参照读数 1714518000000（UTC 串 2024-04-30 23:00:00）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 515554200000L), "515557800000") // 腿 C N.daily_0230.515554200000.UTC|参照读数 515557800000（UTC 串 1986-05-04 02:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Shanghai", 515554200000L),
    "515611800000",
  ) // 腿 C N.daily_0230.515554200000.Asia/Shanghai|参照读数 515611800000（UTC 串 1986-05-04 17:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/New_York", 515554200000L),
    "515572200000",
  ) // 腿 C N.daily_0230.515554200000.America/New_York|参照读数 515572200000（UTC 串 1986-05-04 06:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Kathmandu", 515554200000L),
    "515623500000",
  ) // 腿 C N.daily_0230.515554200000.Asia/Kathmandu|参照读数 515623500000（UTC 串 1986-05-04 20:45:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 515554200000L),
    "515606400000",
  ) // 腿 C N.daily_0230.515554200000.Australia/Lord_Howe|参照读数 515606400000（UTC 串 1986-05-04 16:00:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/Santiago", 515554200000L),
    "515572200000",
  ) // 腿 C N.daily_0230.515554200000.America/Santiago|参照读数 515572200000（UTC 串 1986-05-04 06:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Tehran", 515554200000L),
    "515631600000",
  ) // 腿 C N.daily_0230.515554200000.Asia/Tehran|参照读数 515631600000（UTC 串 1986-05-04 23:00:00）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 4070822400000L), "null") // 腿 C N.daily_0230.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070831400000｜UTC 2098-12-31 02:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 2 * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N.daily_0230.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070889000000｜UTC 2098-12-31 18:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 2 * * *", "America/New_York", 4070822400000L), "null") // 腿 C N.daily_0230.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070849400000｜UTC 2098-12-31 07:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 2 * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N.daily_0230.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070897100000｜UTC 2098-12-31 20:45:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N.daily_0230.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070878200000｜UTC 2098-12-31 15:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 2 * * *", "America/Santiago", 4070822400000L), "null") // 腿 C N.daily_0230.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070842200000｜UTC 2098-12-31 05:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 2 * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.daily_0230.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070905200000｜UTC 2098-12-31 23:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 1730606400000L), "1730687400000") // 腿 C N.daily_0230.1730606400000.UTC|参照读数 1730687400000（UTC 串 2024-11-04 02:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Shanghai", 1730606400000L),
    "1730658600000",
  ) // 腿 C N.daily_0230.1730606400000.Asia/Shanghai|参照读数 1730658600000（UTC 串 2024-11-03 18:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/New_York", 1730606400000L),
    "1730619000000",
  ) // 腿 C N.daily_0230.1730606400000.America/New_York|参照读数 1730619000000（UTC 串 2024-11-03 07:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Kathmandu", 1730606400000L),
    "1730666700000",
  ) // 腿 C N.daily_0230.1730606400000.Asia/Kathmandu|参照读数 1730666700000（UTC 串 2024-11-03 20:45:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730647800000",
  ) // 腿 C N.daily_0230.1730606400000.Australia/Lord_Howe|参照读数 1730647800000（UTC 串 2024-11-03 15:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/Santiago", 1730606400000L),
    "1730611800000",
  ) // 腿 C N.daily_0230.1730606400000.America/Santiago|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Tehran", 1730606400000L),
    "1730674800000",
  ) // 腿 C N.daily_0230.1730606400000.Asia/Tehran|参照读数 1730674800000（UTC 串 2024-11-03 23:00:00）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 1709985600000L), "1710037800000") // 腿 C N.daily_0230.1709985600000.UTC|参照读数 1710037800000（UTC 串 2024-03-10 02:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Shanghai", 1709985600000L),
    "1710009000000",
  ) // 腿 C N.daily_0230.1709985600000.Asia/Shanghai|参照读数 1710009000000（UTC 串 2024-03-09 18:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/New_York", 1709985600000L),
    "1710138600000",
  ) // 腿 C N.daily_0230.1709985600000.America/New_York|参照读数 1710138600000（UTC 串 2024-03-11 06:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Kathmandu", 1709985600000L),
    "1710017100000",
  ) // 腿 C N.daily_0230.1709985600000.Asia/Kathmandu|参照读数 1710017100000（UTC 串 2024-03-09 20:45:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709998200000",
  ) // 腿 C N.daily_0230.1709985600000.Australia/Lord_Howe|参照读数 1709998200000（UTC 串 2024-03-09 15:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/Santiago", 1709985600000L),
    "1710048600000",
  ) // 腿 C N.daily_0230.1709985600000.America/Santiago|参照读数 1710048600000（UTC 串 2024-03-10 05:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Tehran", 1709985600000L),
    "1710025200000",
  ) // 腿 C N.daily_0230.1709985600000.Asia/Tehran|参照读数 1710025200000（UTC 串 2024-03-09 23:00:00）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 1730548800000L), "1730601000000") // 腿 C N.daily_0230.1730548800000.UTC|参照读数 1730601000000（UTC 串 2024-11-03 02:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Shanghai", 1730548800000L),
    "1730572200000",
  ) // 腿 C N.daily_0230.1730548800000.Asia/Shanghai|参照读数 1730572200000（UTC 串 2024-11-02 18:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/New_York", 1730548800000L),
    "1730619000000",
  ) // 腿 C N.daily_0230.1730548800000.America/New_York|参照读数 1730619000000（UTC 串 2024-11-03 07:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Kathmandu", 1730548800000L),
    "1730580300000",
  ) // 腿 C N.daily_0230.1730548800000.Asia/Kathmandu|参照读数 1730580300000（UTC 串 2024-11-02 20:45:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730561400000",
  ) // 腿 C N.daily_0230.1730548800000.Australia/Lord_Howe|参照读数 1730561400000（UTC 串 2024-11-02 15:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/Santiago", 1730548800000L),
    "1730611800000",
  ) // 腿 C N.daily_0230.1730548800000.America/Santiago|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Tehran", 1730548800000L),
    "1730588400000",
  ) // 腿 C N.daily_0230.1730548800000.Asia/Tehran|参照读数 1730588400000（UTC 串 2024-11-02 23:00:00）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 515505600000L), "515557800000") // 腿 C N.daily_0230.515505600000.UTC|参照读数 515557800000（UTC 串 1986-05-04 02:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Shanghai", 515505600000L),
    "515611800000",
  ) // 腿 C N.daily_0230.515505600000.Asia/Shanghai|参照读数 515611800000（UTC 串 1986-05-04 17:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/New_York", 515505600000L),
    "515572200000",
  ) // 腿 C N.daily_0230.515505600000.America/New_York|参照读数 515572200000（UTC 串 1986-05-04 06:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Kathmandu", 515505600000L),
    "515537100000",
  ) // 腿 C N.daily_0230.515505600000.Asia/Kathmandu|参照读数 515537100000（UTC 串 1986-05-03 20:45:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 515505600000L),
    "515520000000",
  ) // 腿 C N.daily_0230.515505600000.Australia/Lord_Howe|参照读数 515520000000（UTC 串 1986-05-03 16:00:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/Santiago", 515505600000L),
    "515572200000",
  ) // 腿 C N.daily_0230.515505600000.America/Santiago|参照读数 515572200000（UTC 串 1986-05-04 06:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Tehran", 515505600000L),
    "515545200000",
  ) // 腿 C N.daily_0230.515505600000.Asia/Tehran|参照读数 515545200000（UTC 串 1986-05-03 23:00:00）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 1725710400000L), "1725762600000") // 腿 C N.daily_0230.1725710400000.UTC|参照读数 1725762600000（UTC 串 2024-09-08 02:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Shanghai", 1725710400000L),
    "1725733800000",
  ) // 腿 C N.daily_0230.1725710400000.Asia/Shanghai|参照读数 1725733800000（UTC 串 2024-09-07 18:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/New_York", 1725710400000L),
    "1725777000000",
  ) // 腿 C N.daily_0230.1725710400000.America/New_York|参照读数 1725777000000（UTC 串 2024-09-08 06:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Kathmandu", 1725710400000L),
    "1725741900000",
  ) // 腿 C N.daily_0230.1725710400000.Asia/Kathmandu|参照读数 1725741900000（UTC 串 2024-09-07 20:45:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725724800000",
  ) // 腿 C N.daily_0230.1725710400000.Australia/Lord_Howe|参照读数 1725724800000（UTC 串 2024-09-07 16:00:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/Santiago", 1725710400000L),
    "1725773400000",
  ) // 腿 C N.daily_0230.1725710400000.America/Santiago|参照读数 1725773400000（UTC 串 2024-09-08 05:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Tehran", 1725710400000L),
    "1725750000000",
  ) // 腿 C N.daily_0230.1725710400000.Asia/Tehran|参照读数 1725750000000（UTC 串 2024-09-07 23:00:00）
  assert_eq(znx_tag("0 30 2 * * *", "UTC", 1647864000000L), "1647916200000") // 腿 C N.daily_0230.1647864000000.UTC|参照读数 1647916200000（UTC 串 2022-03-22 02:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Shanghai", 1647864000000L),
    "1647887400000",
  ) // 腿 C N.daily_0230.1647864000000.Asia/Shanghai|参照读数 1647887400000（UTC 串 2022-03-21 18:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/New_York", 1647864000000L),
    "1647930600000",
  ) // 腿 C N.daily_0230.1647864000000.America/New_York|参照读数 1647930600000（UTC 串 2022-03-22 06:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Kathmandu", 1647864000000L),
    "1647895500000",
  ) // 腿 C N.daily_0230.1647864000000.Asia/Kathmandu|参照读数 1647895500000（UTC 串 2022-03-21 20:45:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647876600000",
  ) // 腿 C N.daily_0230.1647864000000.Australia/Lord_Howe|参照读数 1647876600000（UTC 串 2022-03-21 15:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "America/Santiago", 1647864000000L),
    "1647927000000",
  ) // 腿 C N.daily_0230.1647864000000.America/Santiago|参照读数 1647927000000（UTC 串 2022-03-22 05:30:00）
  assert_eq(
    znx_tag("0 30 2 * * *", "Asia/Tehran", 1647864000000L),
    "1647900000000",
  ) // 腿 C N.daily_0230.1647864000000.Asia/Tehran|参照读数 1647900000000（UTC 串 2022-03-21 22:00:00）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 1710050400000L), "1710117000000") // 腿 C N.daily_0030.1710050400000.UTC|参照读数 1710117000000（UTC 串 2024-03-11 00:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Shanghai", 1710050400000L),
    "1710088200000",
  ) // 腿 C N.daily_0030.1710050400000.Asia/Shanghai|参照读数 1710088200000（UTC 串 2024-03-10 16:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/New_York", 1710050400000L),
    "1710131400000",
  ) // 腿 C N.daily_0030.1710050400000.America/New_York|参照读数 1710131400000（UTC 串 2024-03-11 04:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Kathmandu", 1710050400000L),
    "1710096300000",
  ) // 腿 C N.daily_0030.1710050400000.Asia/Kathmandu|参照读数 1710096300000（UTC 串 2024-03-10 18:45:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710077400000",
  ) // 腿 C N.daily_0030.1710050400000.Australia/Lord_Howe|参照读数 1710077400000（UTC 串 2024-03-10 13:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/Santiago", 1710050400000L),
    "1710127800000",
  ) // 腿 C N.daily_0030.1710050400000.America/Santiago|参照读数 1710127800000（UTC 串 2024-03-11 03:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Tehran", 1710050400000L),
    "1710104400000",
  ) // 腿 C N.daily_0030.1710050400000.Asia/Tehran|参照读数 1710104400000（UTC 串 2024-03-10 21:00:00）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 1730611800000L), "1730680200000") // 腿 C N.daily_0030.1730611800000.UTC|参照读数 1730680200000（UTC 串 2024-11-04 00:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Shanghai", 1730611800000L),
    "1730651400000",
  ) // 腿 C N.daily_0030.1730611800000.Asia/Shanghai|参照读数 1730651400000（UTC 串 2024-11-03 16:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/New_York", 1730611800000L),
    "1730698200000",
  ) // 腿 C N.daily_0030.1730611800000.America/New_York|参照读数 1730698200000（UTC 串 2024-11-04 05:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Kathmandu", 1730611800000L),
    "1730659500000",
  ) // 腿 C N.daily_0030.1730611800000.Asia/Kathmandu|参照读数 1730659500000（UTC 串 2024-11-03 18:45:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730640600000",
  ) // 腿 C N.daily_0030.1730611800000.Australia/Lord_Howe|参照读数 1730640600000（UTC 串 2024-11-03 13:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/Santiago", 1730611800000L),
    "1730691000000",
  ) // 腿 C N.daily_0030.1730611800000.America/Santiago|参照读数 1730691000000（UTC 串 2024-11-04 03:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Tehran", 1730611800000L),
    "1730667600000",
  ) // 腿 C N.daily_0030.1730611800000.Asia/Tehran|参照读数 1730667600000（UTC 串 2024-11-03 21:00:00）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 1730615400000L), "1730680200000") // 腿 C N.daily_0030.1730615400000.UTC|参照读数 1730680200000（UTC 串 2024-11-04 00:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Shanghai", 1730615400000L),
    "1730651400000",
  ) // 腿 C N.daily_0030.1730615400000.Asia/Shanghai|参照读数 1730651400000（UTC 串 2024-11-03 16:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/New_York", 1730615400000L),
    "1730698200000",
  ) // 腿 C N.daily_0030.1730615400000.America/New_York|参照读数 1730698200000（UTC 串 2024-11-04 05:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Kathmandu", 1730615400000L),
    "1730659500000",
  ) // 腿 C N.daily_0030.1730615400000.Asia/Kathmandu|参照读数 1730659500000（UTC 串 2024-11-03 18:45:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730640600000",
  ) // 腿 C N.daily_0030.1730615400000.Australia/Lord_Howe|参照读数 1730640600000（UTC 串 2024-11-03 13:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/Santiago", 1730615400000L),
    "1730691000000",
  ) // 腿 C N.daily_0030.1730615400000.America/Santiago|参照读数 1730691000000（UTC 串 2024-11-04 03:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Tehran", 1730615400000L),
    "1730667600000",
  ) // 腿 C N.daily_0030.1730615400000.Asia/Tehran|参照读数 1730667600000（UTC 串 2024-11-03 21:00:00）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 1709208000000L), "1709253000000") // 腿 C N.daily_0030.1709208000000.UTC|参照读数 1709253000000（UTC 串 2024-03-01 00:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Shanghai", 1709208000000L),
    "1709224200000",
  ) // 腿 C N.daily_0030.1709208000000.Asia/Shanghai|参照读数 1709224200000（UTC 串 2024-02-29 16:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/New_York", 1709208000000L),
    "1709271000000",
  ) // 腿 C N.daily_0030.1709208000000.America/New_York|参照读数 1709271000000（UTC 串 2024-03-01 05:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Kathmandu", 1709208000000L),
    "1709232300000",
  ) // 腿 C N.daily_0030.1709208000000.Asia/Kathmandu|参照读数 1709232300000（UTC 串 2024-02-29 18:45:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709213400000",
  ) // 腿 C N.daily_0030.1709208000000.Australia/Lord_Howe|参照读数 1709213400000（UTC 串 2024-02-29 13:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/Santiago", 1709208000000L),
    "1709263800000",
  ) // 腿 C N.daily_0030.1709208000000.America/Santiago|参照读数 1709263800000（UTC 串 2024-03-01 03:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Tehran", 1709208000000L),
    "1709240400000",
  ) // 腿 C N.daily_0030.1709208000000.Asia/Tehran|参照读数 1709240400000（UTC 串 2024-02-29 21:00:00）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 1714435200000L), "1714437000000") // 腿 C N.daily_0030.1714435200000.UTC|参照读数 1714437000000（UTC 串 2024-04-30 00:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Shanghai", 1714435200000L),
    "1714494600000",
  ) // 腿 C N.daily_0030.1714435200000.Asia/Shanghai|参照读数 1714494600000（UTC 串 2024-04-30 16:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/New_York", 1714435200000L),
    "1714451400000",
  ) // 腿 C N.daily_0030.1714435200000.America/New_York|参照读数 1714451400000（UTC 串 2024-04-30 04:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Kathmandu", 1714435200000L),
    "1714502700000",
  ) // 腿 C N.daily_0030.1714435200000.Asia/Kathmandu|参照读数 1714502700000（UTC 串 2024-04-30 18:45:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714485600000",
  ) // 腿 C N.daily_0030.1714435200000.Australia/Lord_Howe|参照读数 1714485600000（UTC 串 2024-04-30 14:00:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/Santiago", 1714435200000L),
    "1714451400000",
  ) // 腿 C N.daily_0030.1714435200000.America/Santiago|参照读数 1714451400000（UTC 串 2024-04-30 04:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Tehran", 1714435200000L),
    "1714510800000",
  ) // 腿 C N.daily_0030.1714435200000.Asia/Tehran|参照读数 1714510800000（UTC 串 2024-04-30 21:00:00）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 515554200000L), "515637000000") // 腿 C N.daily_0030.515554200000.UTC|参照读数 515637000000（UTC 串 1986-05-05 00:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Shanghai", 515554200000L),
    "515604600000",
  ) // 腿 C N.daily_0030.515554200000.Asia/Shanghai|参照读数 515604600000（UTC 串 1986-05-04 15:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/New_York", 515554200000L),
    "515565000000",
  ) // 腿 C N.daily_0030.515554200000.America/New_York|参照读数 515565000000（UTC 串 1986-05-04 04:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Kathmandu", 515554200000L),
    "515616300000",
  ) // 腿 C N.daily_0030.515554200000.Asia/Kathmandu|参照读数 515616300000（UTC 串 1986-05-04 18:45:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 515554200000L),
    "515599200000",
  ) // 腿 C N.daily_0030.515554200000.Australia/Lord_Howe|参照读数 515599200000（UTC 串 1986-05-04 14:00:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/Santiago", 515554200000L),
    "515565000000",
  ) // 腿 C N.daily_0030.515554200000.America/Santiago|参照读数 515565000000（UTC 串 1986-05-04 04:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Tehran", 515554200000L),
    "515624400000",
  ) // 腿 C N.daily_0030.515554200000.Asia/Tehran|参照读数 515624400000（UTC 串 1986-05-04 21:00:00）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 4070822400000L), "null") // 腿 C N.daily_0030.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070824200000｜UTC 2098-12-31 00:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 0 * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N.daily_0030.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070881800000｜UTC 2098-12-31 16:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 0 * * *", "America/New_York", 4070822400000L), "null") // 腿 C N.daily_0030.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070842200000｜UTC 2098-12-31 05:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 0 * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N.daily_0030.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070889900000｜UTC 2098-12-31 18:45:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N.daily_0030.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070871000000｜UTC 2098-12-31 13:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 0 * * *", "America/Santiago", 4070822400000L), "null") // 腿 C N.daily_0030.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070835000000｜UTC 2098-12-31 03:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 0 * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.daily_0030.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070898000000｜UTC 2098-12-31 21:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 1730606400000L), "1730680200000") // 腿 C N.daily_0030.1730606400000.UTC|参照读数 1730680200000（UTC 串 2024-11-04 00:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Shanghai", 1730606400000L),
    "1730651400000",
  ) // 腿 C N.daily_0030.1730606400000.Asia/Shanghai|参照读数 1730651400000（UTC 串 2024-11-03 16:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/New_York", 1730606400000L),
    "1730608200000",
  ) // 腿 C N.daily_0030.1730606400000.America/New_York|参照读数 1730608200000（UTC 串 2024-11-03 04:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Kathmandu", 1730606400000L),
    "1730659500000",
  ) // 腿 C N.daily_0030.1730606400000.Asia/Kathmandu|参照读数 1730659500000（UTC 串 2024-11-03 18:45:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730640600000",
  ) // 腿 C N.daily_0030.1730606400000.Australia/Lord_Howe|参照读数 1730640600000（UTC 串 2024-11-03 13:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/Santiago", 1730606400000L),
    "1730691000000",
  ) // 腿 C N.daily_0030.1730606400000.America/Santiago|参照读数 1730691000000（UTC 串 2024-11-04 03:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Tehran", 1730606400000L),
    "1730667600000",
  ) // 腿 C N.daily_0030.1730606400000.Asia/Tehran|参照读数 1730667600000（UTC 串 2024-11-03 21:00:00）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 1709985600000L), "1710030600000") // 腿 C N.daily_0030.1709985600000.UTC|参照读数 1710030600000（UTC 串 2024-03-10 00:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Shanghai", 1709985600000L),
    "1710001800000",
  ) // 腿 C N.daily_0030.1709985600000.Asia/Shanghai|参照读数 1710001800000（UTC 串 2024-03-09 16:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/New_York", 1709985600000L),
    "1710048600000",
  ) // 腿 C N.daily_0030.1709985600000.America/New_York|参照读数 1710048600000（UTC 串 2024-03-10 05:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Kathmandu", 1709985600000L),
    "1710009900000",
  ) // 腿 C N.daily_0030.1709985600000.Asia/Kathmandu|参照读数 1710009900000（UTC 串 2024-03-09 18:45:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709991000000",
  ) // 腿 C N.daily_0030.1709985600000.Australia/Lord_Howe|参照读数 1709991000000（UTC 串 2024-03-09 13:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/Santiago", 1709985600000L),
    "1710041400000",
  ) // 腿 C N.daily_0030.1709985600000.America/Santiago|参照读数 1710041400000（UTC 串 2024-03-10 03:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Tehran", 1709985600000L),
    "1710018000000",
  ) // 腿 C N.daily_0030.1709985600000.Asia/Tehran|参照读数 1710018000000（UTC 串 2024-03-09 21:00:00）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 1730548800000L), "1730593800000") // 腿 C N.daily_0030.1730548800000.UTC|参照读数 1730593800000（UTC 串 2024-11-03 00:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Shanghai", 1730548800000L),
    "1730565000000",
  ) // 腿 C N.daily_0030.1730548800000.Asia/Shanghai|参照读数 1730565000000（UTC 串 2024-11-02 16:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/New_York", 1730548800000L),
    "1730608200000",
  ) // 腿 C N.daily_0030.1730548800000.America/New_York|参照读数 1730608200000（UTC 串 2024-11-03 04:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Kathmandu", 1730548800000L),
    "1730573100000",
  ) // 腿 C N.daily_0030.1730548800000.Asia/Kathmandu|参照读数 1730573100000（UTC 串 2024-11-02 18:45:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730554200000",
  ) // 腿 C N.daily_0030.1730548800000.Australia/Lord_Howe|参照读数 1730554200000（UTC 串 2024-11-02 13:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/Santiago", 1730548800000L),
    "1730604600000",
  ) // 腿 C N.daily_0030.1730548800000.America/Santiago|参照读数 1730604600000（UTC 串 2024-11-03 03:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Tehran", 1730548800000L),
    "1730581200000",
  ) // 腿 C N.daily_0030.1730548800000.Asia/Tehran|参照读数 1730581200000（UTC 串 2024-11-02 21:00:00）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 515505600000L), "515550600000") // 腿 C N.daily_0030.515505600000.UTC|参照读数 515550600000（UTC 串 1986-05-04 00:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Shanghai", 515505600000L),
    "515521800000",
  ) // 腿 C N.daily_0030.515505600000.Asia/Shanghai|参照读数 515521800000（UTC 串 1986-05-03 16:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/New_York", 515505600000L),
    "515565000000",
  ) // 腿 C N.daily_0030.515505600000.America/New_York|参照读数 515565000000（UTC 串 1986-05-04 04:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Kathmandu", 515505600000L),
    "515529900000",
  ) // 腿 C N.daily_0030.515505600000.Asia/Kathmandu|参照读数 515529900000（UTC 串 1986-05-03 18:45:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 515505600000L),
    "515512800000",
  ) // 腿 C N.daily_0030.515505600000.Australia/Lord_Howe|参照读数 515512800000（UTC 串 1986-05-03 14:00:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/Santiago", 515505600000L),
    "515565000000",
  ) // 腿 C N.daily_0030.515505600000.America/Santiago|参照读数 515565000000（UTC 串 1986-05-04 04:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Tehran", 515505600000L),
    "515538000000",
  ) // 腿 C N.daily_0030.515505600000.Asia/Tehran|参照读数 515538000000（UTC 串 1986-05-03 21:00:00）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 1725710400000L), "1725755400000") // 腿 C N.daily_0030.1725710400000.UTC|参照读数 1725755400000（UTC 串 2024-09-08 00:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Shanghai", 1725710400000L),
    "1725726600000",
  ) // 腿 C N.daily_0030.1725710400000.Asia/Shanghai|参照读数 1725726600000（UTC 串 2024-09-07 16:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/New_York", 1725710400000L),
    "1725769800000",
  ) // 腿 C N.daily_0030.1725710400000.America/New_York|参照读数 1725769800000（UTC 串 2024-09-08 04:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Kathmandu", 1725710400000L),
    "1725734700000",
  ) // 腿 C N.daily_0030.1725710400000.Asia/Kathmandu|参照读数 1725734700000（UTC 串 2024-09-07 18:45:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725717600000",
  ) // 腿 C N.daily_0030.1725710400000.Australia/Lord_Howe|参照读数 1725717600000（UTC 串 2024-09-07 14:00:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/Santiago", 1725710400000L),
    "1725852600000",
  ) // 腿 C N.daily_0030.1725710400000.America/Santiago|参照读数 1725852600000（UTC 串 2024-09-09 03:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Tehran", 1725710400000L),
    "1725742800000",
  ) // 腿 C N.daily_0030.1725710400000.Asia/Tehran|参照读数 1725742800000（UTC 串 2024-09-07 21:00:00）
  assert_eq(znx_tag("0 30 0 * * *", "UTC", 1647864000000L), "1647909000000") // 腿 C N.daily_0030.1647864000000.UTC|参照读数 1647909000000（UTC 串 2022-03-22 00:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Shanghai", 1647864000000L),
    "1647880200000",
  ) // 腿 C N.daily_0030.1647864000000.Asia/Shanghai|参照读数 1647880200000（UTC 串 2022-03-21 16:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/New_York", 1647864000000L),
    "1647923400000",
  ) // 腿 C N.daily_0030.1647864000000.America/New_York|参照读数 1647923400000（UTC 串 2022-03-22 04:30:00）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znx_tag 行，严格晚于，第 3 块 180 条）" {
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Kathmandu", 1647864000000L),
    "1647888300000",
  ) // 腿 C N.daily_0030.1647864000000.Asia/Kathmandu|参照读数 1647888300000（UTC 串 2022-03-21 18:45:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647869400000",
  ) // 腿 C N.daily_0030.1647864000000.Australia/Lord_Howe|参照读数 1647869400000（UTC 串 2022-03-21 13:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "America/Santiago", 1647864000000L),
    "1647919800000",
  ) // 腿 C N.daily_0030.1647864000000.America/Santiago|参照读数 1647919800000（UTC 串 2022-03-22 03:30:00）
  assert_eq(
    znx_tag("0 30 0 * * *", "Asia/Tehran", 1647864000000L),
    "1647979200000",
  ) // 腿 C N.daily_0030.1647864000000.Asia/Tehran|参照读数 1647979200000（UTC 串 2022-03-22 20:00:00）
  assert_eq(znx_tag("45 23 * * *", "UTC", 1710050400000L), "1710114300000") // 腿 C N.daily_2345.1710050400000.UTC|参照读数 1710114300000（UTC 串 2024-03-10 23:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Shanghai", 1710050400000L),
    "1710085500000",
  ) // 腿 C N.daily_2345.1710050400000.Asia/Shanghai|参照读数 1710085500000（UTC 串 2024-03-10 15:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/New_York", 1710050400000L),
    "1710128700000",
  ) // 腿 C N.daily_2345.1710050400000.America/New_York|参照读数 1710128700000（UTC 串 2024-03-11 03:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Kathmandu", 1710050400000L),
    "1710093600000",
  ) // 腿 C N.daily_2345.1710050400000.Asia/Kathmandu|参照读数 1710093600000（UTC 串 2024-03-10 18:00:00）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710074700000",
  ) // 腿 C N.daily_2345.1710050400000.Australia/Lord_Howe|参照读数 1710074700000（UTC 串 2024-03-10 12:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/Santiago", 1710050400000L),
    "1710125100000",
  ) // 腿 C N.daily_2345.1710050400000.America/Santiago|参照读数 1710125100000（UTC 串 2024-03-11 02:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Tehran", 1710050400000L),
    "1710101700000",
  ) // 腿 C N.daily_2345.1710050400000.Asia/Tehran|参照读数 1710101700000（UTC 串 2024-03-10 20:15:00）
  assert_eq(znx_tag("45 23 * * *", "UTC", 1730611800000L), "1730677500000") // 腿 C N.daily_2345.1730611800000.UTC|参照读数 1730677500000（UTC 串 2024-11-03 23:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Shanghai", 1730611800000L),
    "1730648700000",
  ) // 腿 C N.daily_2345.1730611800000.Asia/Shanghai|参照读数 1730648700000（UTC 串 2024-11-03 15:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/New_York", 1730611800000L),
    "1730695500000",
  ) // 腿 C N.daily_2345.1730611800000.America/New_York|参照读数 1730695500000（UTC 串 2024-11-04 04:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Kathmandu", 1730611800000L),
    "1730656800000",
  ) // 腿 C N.daily_2345.1730611800000.Asia/Kathmandu|参照读数 1730656800000（UTC 串 2024-11-03 18:00:00）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730637900000",
  ) // 腿 C N.daily_2345.1730611800000.Australia/Lord_Howe|参照读数 1730637900000（UTC 串 2024-11-03 12:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/Santiago", 1730611800000L),
    "1730688300000",
  ) // 腿 C N.daily_2345.1730611800000.America/Santiago|参照读数 1730688300000（UTC 串 2024-11-04 02:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Tehran", 1730611800000L),
    "1730664900000",
  ) // 腿 C N.daily_2345.1730611800000.Asia/Tehran|参照读数 1730664900000（UTC 串 2024-11-03 20:15:00）
  assert_eq(znx_tag("45 23 * * *", "UTC", 1730615400000L), "1730677500000") // 腿 C N.daily_2345.1730615400000.UTC|参照读数 1730677500000（UTC 串 2024-11-03 23:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Shanghai", 1730615400000L),
    "1730648700000",
  ) // 腿 C N.daily_2345.1730615400000.Asia/Shanghai|参照读数 1730648700000（UTC 串 2024-11-03 15:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/New_York", 1730615400000L),
    "1730695500000",
  ) // 腿 C N.daily_2345.1730615400000.America/New_York|参照读数 1730695500000（UTC 串 2024-11-04 04:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Kathmandu", 1730615400000L),
    "1730656800000",
  ) // 腿 C N.daily_2345.1730615400000.Asia/Kathmandu|参照读数 1730656800000（UTC 串 2024-11-03 18:00:00）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730637900000",
  ) // 腿 C N.daily_2345.1730615400000.Australia/Lord_Howe|参照读数 1730637900000（UTC 串 2024-11-03 12:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/Santiago", 1730615400000L),
    "1730688300000",
  ) // 腿 C N.daily_2345.1730615400000.America/Santiago|参照读数 1730688300000（UTC 串 2024-11-04 02:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Tehran", 1730615400000L),
    "1730664900000",
  ) // 腿 C N.daily_2345.1730615400000.Asia/Tehran|参照读数 1730664900000（UTC 串 2024-11-03 20:15:00）
  assert_eq(znx_tag("45 23 * * *", "UTC", 1709208000000L), "1709250300000") // 腿 C N.daily_2345.1709208000000.UTC|参照读数 1709250300000（UTC 串 2024-02-29 23:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Shanghai", 1709208000000L),
    "1709221500000",
  ) // 腿 C N.daily_2345.1709208000000.Asia/Shanghai|参照读数 1709221500000（UTC 串 2024-02-29 15:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/New_York", 1709208000000L),
    "1709268300000",
  ) // 腿 C N.daily_2345.1709208000000.America/New_York|参照读数 1709268300000（UTC 串 2024-03-01 04:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Kathmandu", 1709208000000L),
    "1709229600000",
  ) // 腿 C N.daily_2345.1709208000000.Asia/Kathmandu|参照读数 1709229600000（UTC 串 2024-02-29 18:00:00）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709210700000",
  ) // 腿 C N.daily_2345.1709208000000.Australia/Lord_Howe|参照读数 1709210700000（UTC 串 2024-02-29 12:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/Santiago", 1709208000000L),
    "1709261100000",
  ) // 腿 C N.daily_2345.1709208000000.America/Santiago|参照读数 1709261100000（UTC 串 2024-03-01 02:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Tehran", 1709208000000L),
    "1709237700000",
  ) // 腿 C N.daily_2345.1709208000000.Asia/Tehran|参照读数 1709237700000（UTC 串 2024-02-29 20:15:00）
  assert_eq(znx_tag("45 23 * * *", "UTC", 1714435200000L), "1714520700000") // 腿 C N.daily_2345.1714435200000.UTC|参照读数 1714520700000（UTC 串 2024-04-30 23:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Shanghai", 1714435200000L),
    "1714491900000",
  ) // 腿 C N.daily_2345.1714435200000.Asia/Shanghai|参照读数 1714491900000（UTC 串 2024-04-30 15:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/New_York", 1714435200000L),
    "1714448700000",
  ) // 腿 C N.daily_2345.1714435200000.America/New_York|参照读数 1714448700000（UTC 串 2024-04-30 03:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Kathmandu", 1714435200000L),
    "1714500000000",
  ) // 腿 C N.daily_2345.1714435200000.Asia/Kathmandu|参照读数 1714500000000（UTC 串 2024-04-30 18:00:00）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714482900000",
  ) // 腿 C N.daily_2345.1714435200000.Australia/Lord_Howe|参照读数 1714482900000（UTC 串 2024-04-30 13:15:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/Santiago", 1714435200000L),
    "1714448700000",
  ) // 腿 C N.daily_2345.1714435200000.America/Santiago|参照读数 1714448700000（UTC 串 2024-04-30 03:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Tehran", 1714435200000L),
    "1714508100000",
  ) // 腿 C N.daily_2345.1714435200000.Asia/Tehran|参照读数 1714508100000（UTC 串 2024-04-30 20:15:00）
  assert_eq(znx_tag("45 23 * * *", "UTC", 515554200000L), "515634300000") // 腿 C N.daily_2345.515554200000.UTC|参照读数 515634300000（UTC 串 1986-05-04 23:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Shanghai", 515554200000L),
    "515601900000",
  ) // 腿 C N.daily_2345.515554200000.Asia/Shanghai|参照读数 515601900000（UTC 串 1986-05-04 14:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/New_York", 515554200000L),
    "515562300000",
  ) // 腿 C N.daily_2345.515554200000.America/New_York|参照读数 515562300000（UTC 串 1986-05-04 03:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Kathmandu", 515554200000L),
    "515613600000",
  ) // 腿 C N.daily_2345.515554200000.Asia/Kathmandu|参照读数 515613600000（UTC 串 1986-05-04 18:00:00）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 515554200000L),
    "515596500000",
  ) // 腿 C N.daily_2345.515554200000.Australia/Lord_Howe|参照读数 515596500000（UTC 串 1986-05-04 13:15:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/Santiago", 515554200000L),
    "515562300000",
  ) // 腿 C N.daily_2345.515554200000.America/Santiago|参照读数 515562300000（UTC 串 1986-05-04 03:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Tehran", 515554200000L),
    "515621700000",
  ) // 腿 C N.daily_2345.515554200000.Asia/Tehran|参照读数 515621700000（UTC 串 1986-05-04 20:15:00）
  assert_eq(znx_tag("45 23 * * *", "UTC", 4070822400000L), "null") // 腿 C N.daily_2345.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070907900000｜UTC 2098-12-31 23:45:00，spec §11 第 4 行）
  assert_eq(znx_tag("45 23 * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N.daily_2345.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070879100000｜UTC 2098-12-31 15:45:00，spec §11 第 4 行）
  assert_eq(znx_tag("45 23 * * *", "America/New_York", 4070822400000L), "null") // 腿 C N.daily_2345.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070839500000｜UTC 2098-12-31 04:45:00，spec §11 第 4 行）
  assert_eq(znx_tag("45 23 * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N.daily_2345.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070887200000｜UTC 2098-12-31 18:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N.daily_2345.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070868300000｜UTC 2098-12-31 12:45:00，spec §11 第 4 行）
  assert_eq(znx_tag("45 23 * * *", "America/Santiago", 4070822400000L), "null") // 腿 C N.daily_2345.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070832300000｜UTC 2098-12-31 02:45:00，spec §11 第 4 行）
  assert_eq(znx_tag("45 23 * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.daily_2345.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070895300000｜UTC 2098-12-31 20:15:00，spec §11 第 4 行）
  assert_eq(znx_tag("45 23 * * *", "UTC", 1730606400000L), "1730677500000") // 腿 C N.daily_2345.1730606400000.UTC|参照读数 1730677500000（UTC 串 2024-11-03 23:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Shanghai", 1730606400000L),
    "1730648700000",
  ) // 腿 C N.daily_2345.1730606400000.Asia/Shanghai|参照读数 1730648700000（UTC 串 2024-11-03 15:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/New_York", 1730606400000L),
    "1730695500000",
  ) // 腿 C N.daily_2345.1730606400000.America/New_York|参照读数 1730695500000（UTC 串 2024-11-04 04:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Kathmandu", 1730606400000L),
    "1730656800000",
  ) // 腿 C N.daily_2345.1730606400000.Asia/Kathmandu|参照读数 1730656800000（UTC 串 2024-11-03 18:00:00）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730637900000",
  ) // 腿 C N.daily_2345.1730606400000.Australia/Lord_Howe|参照读数 1730637900000（UTC 串 2024-11-03 12:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/Santiago", 1730606400000L),
    "1730688300000",
  ) // 腿 C N.daily_2345.1730606400000.America/Santiago|参照读数 1730688300000（UTC 串 2024-11-04 02:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Tehran", 1730606400000L),
    "1730664900000",
  ) // 腿 C N.daily_2345.1730606400000.Asia/Tehran|参照读数 1730664900000（UTC 串 2024-11-03 20:15:00）
  assert_eq(znx_tag("45 23 * * *", "UTC", 1709985600000L), "1710027900000") // 腿 C N.daily_2345.1709985600000.UTC|参照读数 1710027900000（UTC 串 2024-03-09 23:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Shanghai", 1709985600000L),
    "1709999100000",
  ) // 腿 C N.daily_2345.1709985600000.Asia/Shanghai|参照读数 1709999100000（UTC 串 2024-03-09 15:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/New_York", 1709985600000L),
    "1710045900000",
  ) // 腿 C N.daily_2345.1709985600000.America/New_York|参照读数 1710045900000（UTC 串 2024-03-10 04:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Kathmandu", 1709985600000L),
    "1710007200000",
  ) // 腿 C N.daily_2345.1709985600000.Asia/Kathmandu|参照读数 1710007200000（UTC 串 2024-03-09 18:00:00）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709988300000",
  ) // 腿 C N.daily_2345.1709985600000.Australia/Lord_Howe|参照读数 1709988300000（UTC 串 2024-03-09 12:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/Santiago", 1709985600000L),
    "1710038700000",
  ) // 腿 C N.daily_2345.1709985600000.America/Santiago|参照读数 1710038700000（UTC 串 2024-03-10 02:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Tehran", 1709985600000L),
    "1710015300000",
  ) // 腿 C N.daily_2345.1709985600000.Asia/Tehran|参照读数 1710015300000（UTC 串 2024-03-09 20:15:00）
  assert_eq(znx_tag("45 23 * * *", "UTC", 1730548800000L), "1730591100000") // 腿 C N.daily_2345.1730548800000.UTC|参照读数 1730591100000（UTC 串 2024-11-02 23:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Shanghai", 1730548800000L),
    "1730562300000",
  ) // 腿 C N.daily_2345.1730548800000.Asia/Shanghai|参照读数 1730562300000（UTC 串 2024-11-02 15:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/New_York", 1730548800000L),
    "1730605500000",
  ) // 腿 C N.daily_2345.1730548800000.America/New_York|参照读数 1730605500000（UTC 串 2024-11-03 03:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Kathmandu", 1730548800000L),
    "1730570400000",
  ) // 腿 C N.daily_2345.1730548800000.Asia/Kathmandu|参照读数 1730570400000（UTC 串 2024-11-02 18:00:00）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730551500000",
  ) // 腿 C N.daily_2345.1730548800000.Australia/Lord_Howe|参照读数 1730551500000（UTC 串 2024-11-02 12:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/Santiago", 1730548800000L),
    "1730601900000",
  ) // 腿 C N.daily_2345.1730548800000.America/Santiago|参照读数 1730601900000（UTC 串 2024-11-03 02:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Tehran", 1730548800000L),
    "1730578500000",
  ) // 腿 C N.daily_2345.1730548800000.Asia/Tehran|参照读数 1730578500000（UTC 串 2024-11-02 20:15:00）
  assert_eq(znx_tag("45 23 * * *", "UTC", 515505600000L), "515547900000") // 腿 C N.daily_2345.515505600000.UTC|参照读数 515547900000（UTC 串 1986-05-03 23:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Shanghai", 515505600000L),
    "515519100000",
  ) // 腿 C N.daily_2345.515505600000.Asia/Shanghai|参照读数 515519100000（UTC 串 1986-05-03 15:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/New_York", 515505600000L),
    "515562300000",
  ) // 腿 C N.daily_2345.515505600000.America/New_York|参照读数 515562300000（UTC 串 1986-05-04 03:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Kathmandu", 515505600000L),
    "515527200000",
  ) // 腿 C N.daily_2345.515505600000.Asia/Kathmandu|参照读数 515527200000（UTC 串 1986-05-03 18:00:00）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 515505600000L),
    "515510100000",
  ) // 腿 C N.daily_2345.515505600000.Australia/Lord_Howe|参照读数 515510100000（UTC 串 1986-05-03 13:15:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/Santiago", 515505600000L),
    "515562300000",
  ) // 腿 C N.daily_2345.515505600000.America/Santiago|参照读数 515562300000（UTC 串 1986-05-04 03:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Tehran", 515505600000L),
    "515535300000",
  ) // 腿 C N.daily_2345.515505600000.Asia/Tehran|参照读数 515535300000（UTC 串 1986-05-03 20:15:00）
  assert_eq(znx_tag("45 23 * * *", "UTC", 1725710400000L), "1725752700000") // 腿 C N.daily_2345.1725710400000.UTC|参照读数 1725752700000（UTC 串 2024-09-07 23:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Shanghai", 1725710400000L),
    "1725723900000",
  ) // 腿 C N.daily_2345.1725710400000.Asia/Shanghai|参照读数 1725723900000（UTC 串 2024-09-07 15:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/New_York", 1725710400000L),
    "1725767100000",
  ) // 腿 C N.daily_2345.1725710400000.America/New_York|参照读数 1725767100000（UTC 串 2024-09-08 03:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Kathmandu", 1725710400000L),
    "1725732000000",
  ) // 腿 C N.daily_2345.1725710400000.Asia/Kathmandu|参照读数 1725732000000（UTC 串 2024-09-07 18:00:00）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725714900000",
  ) // 腿 C N.daily_2345.1725710400000.Australia/Lord_Howe|参照读数 1725714900000（UTC 串 2024-09-07 13:15:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/Santiago", 1725710400000L),
    "1725767100000",
  ) // 腿 C N.daily_2345.1725710400000.America/Santiago|参照读数 1725767100000（UTC 串 2024-09-08 03:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Tehran", 1725710400000L),
    "1725740100000",
  ) // 腿 C N.daily_2345.1725710400000.Asia/Tehran|参照读数 1725740100000（UTC 串 2024-09-07 20:15:00）
  assert_eq(znx_tag("45 23 * * *", "UTC", 1647864000000L), "1647906300000") // 腿 C N.daily_2345.1647864000000.UTC|参照读数 1647906300000（UTC 串 2022-03-21 23:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Shanghai", 1647864000000L),
    "1647877500000",
  ) // 腿 C N.daily_2345.1647864000000.Asia/Shanghai|参照读数 1647877500000（UTC 串 2022-03-21 15:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/New_York", 1647864000000L),
    "1647920700000",
  ) // 腿 C N.daily_2345.1647864000000.America/New_York|参照读数 1647920700000（UTC 串 2022-03-22 03:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Kathmandu", 1647864000000L),
    "1647885600000",
  ) // 腿 C N.daily_2345.1647864000000.Asia/Kathmandu|参照读数 1647885600000（UTC 串 2022-03-21 18:00:00）
  assert_eq(
    znx_tag("45 23 * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647866700000",
  ) // 腿 C N.daily_2345.1647864000000.Australia/Lord_Howe|参照读数 1647866700000（UTC 串 2022-03-21 12:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "America/Santiago", 1647864000000L),
    "1647917100000",
  ) // 腿 C N.daily_2345.1647864000000.America/Santiago|参照读数 1647917100000（UTC 串 2022-03-22 02:45:00）
  assert_eq(
    znx_tag("45 23 * * *", "Asia/Tehran", 1647864000000L),
    "1647893700000",
  ) // 腿 C N.daily_2345.1647864000000.Asia/Tehran|参照读数 1647893700000（UTC 串 2022-03-21 20:15:00）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 1710050400000L), "1835395200000") // 腿 C N.leap_only.1710050400000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 1710050400000L),
    "1835366400000",
  ) // 腿 C N.leap_only.1710050400000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/New_York", 1710050400000L),
    "1835413200000",
  ) // 腿 C N.leap_only.1710050400000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1710050400000L),
    "1835374500000",
  ) // 腿 C N.leap_only.1710050400000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1710050400000L),
    "1835355600000",
  ) // 腿 C N.leap_only.1710050400000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/Santiago", 1710050400000L),
    "1835406000000",
  ) // 腿 C N.leap_only.1710050400000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Tehran", 1710050400000L),
    "1835382600000",
  ) // 腿 C N.leap_only.1710050400000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 1730611800000L), "1835395200000") // 腿 C N.leap_only.1730611800000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 1730611800000L),
    "1835366400000",
  ) // 腿 C N.leap_only.1730611800000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/New_York", 1730611800000L),
    "1835413200000",
  ) // 腿 C N.leap_only.1730611800000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1730611800000L),
    "1835374500000",
  ) // 腿 C N.leap_only.1730611800000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1730611800000L),
    "1835355600000",
  ) // 腿 C N.leap_only.1730611800000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/Santiago", 1730611800000L),
    "1835406000000",
  ) // 腿 C N.leap_only.1730611800000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Tehran", 1730611800000L),
    "1835382600000",
  ) // 腿 C N.leap_only.1730611800000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 1730615400000L), "1835395200000") // 腿 C N.leap_only.1730615400000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 1730615400000L),
    "1835366400000",
  ) // 腿 C N.leap_only.1730615400000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/New_York", 1730615400000L),
    "1835413200000",
  ) // 腿 C N.leap_only.1730615400000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1730615400000L),
    "1835374500000",
  ) // 腿 C N.leap_only.1730615400000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1730615400000L),
    "1835355600000",
  ) // 腿 C N.leap_only.1730615400000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/Santiago", 1730615400000L),
    "1835406000000",
  ) // 腿 C N.leap_only.1730615400000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Tehran", 1730615400000L),
    "1835382600000",
  ) // 腿 C N.leap_only.1730615400000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 1709208000000L), "1835395200000") // 腿 C N.leap_only.1709208000000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 1709208000000L),
    "1835366400000",
  ) // 腿 C N.leap_only.1709208000000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/New_York", 1709208000000L),
    "1835413200000",
  ) // 腿 C N.leap_only.1709208000000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1709208000000L),
    "1835374500000",
  ) // 腿 C N.leap_only.1709208000000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1709208000000L),
    "1835355600000",
  ) // 腿 C N.leap_only.1709208000000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/Santiago", 1709208000000L),
    "1835406000000",
  ) // 腿 C N.leap_only.1709208000000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Tehran", 1709208000000L),
    "1835382600000",
  ) // 腿 C N.leap_only.1709208000000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 1714435200000L), "1835395200000") // 腿 C N.leap_only.1714435200000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 1714435200000L),
    "1835366400000",
  ) // 腿 C N.leap_only.1714435200000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/New_York", 1714435200000L),
    "1835413200000",
  ) // 腿 C N.leap_only.1714435200000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1714435200000L),
    "1835374500000",
  ) // 腿 C N.leap_only.1714435200000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1714435200000L),
    "1835355600000",
  ) // 腿 C N.leap_only.1714435200000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/Santiago", 1714435200000L),
    "1835406000000",
  ) // 腿 C N.leap_only.1714435200000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Tehran", 1714435200000L),
    "1835382600000",
  ) // 腿 C N.leap_only.1714435200000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 515554200000L), "573091200000") // 腿 C N.leap_only.515554200000.UTC|参照读数 573091200000（UTC 串 1988-02-29 00:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 515554200000L),
    "573062400000",
  ) // 腿 C N.leap_only.515554200000.Asia/Shanghai|参照读数 573062400000（UTC 串 1988-02-28 16:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/New_York", 515554200000L),
    "573109200000",
  ) // 腿 C N.leap_only.515554200000.America/New_York|参照读数 573109200000（UTC 串 1988-02-29 05:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 515554200000L),
    "573070500000",
  ) // 腿 C N.leap_only.515554200000.Asia/Kathmandu|参照读数 573070500000（UTC 串 1988-02-28 18:15:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 515554200000L),
    "573051600000",
  ) // 腿 C N.leap_only.515554200000.Australia/Lord_Howe|参照读数 573051600000（UTC 串 1988-02-28 13:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/Santiago", 515554200000L),
    "573102000000",
  ) // 腿 C N.leap_only.515554200000.America/Santiago|参照读数 573102000000（UTC 串 1988-02-29 03:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Tehran", 515554200000L),
    "573078600000",
  ) // 腿 C N.leap_only.515554200000.Asia/Tehran|参照读数 573078600000（UTC 串 1988-02-28 20:30:00）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 4070822400000L), "null") // 腿 C N.leap_only.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4233686400000｜UTC 2104-02-29 00:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N.leap_only.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4233657600000｜UTC 2104-02-28 16:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 29 2 *", "America/New_York", 4070822400000L), "null") // 腿 C N.leap_only.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4233704400000｜UTC 2104-02-29 05:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N.leap_only.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4233665700000｜UTC 2104-02-28 18:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N.leap_only.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4233646800000｜UTC 2104-02-28 13:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 29 2 *", "America/Santiago", 4070822400000L), "null") // 腿 C N.leap_only.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4233697200000｜UTC 2104-02-29 03:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 29 2 *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.leap_only.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4233673800000｜UTC 2104-02-28 20:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 1730606400000L), "1835395200000") // 腿 C N.leap_only.1730606400000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 1730606400000L),
    "1835366400000",
  ) // 腿 C N.leap_only.1730606400000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/New_York", 1730606400000L),
    "1835413200000",
  ) // 腿 C N.leap_only.1730606400000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1730606400000L),
    "1835374500000",
  ) // 腿 C N.leap_only.1730606400000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1730606400000L),
    "1835355600000",
  ) // 腿 C N.leap_only.1730606400000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/Santiago", 1730606400000L),
    "1835406000000",
  ) // 腿 C N.leap_only.1730606400000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Tehran", 1730606400000L),
    "1835382600000",
  ) // 腿 C N.leap_only.1730606400000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 1709985600000L), "1835395200000") // 腿 C N.leap_only.1709985600000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 1709985600000L),
    "1835366400000",
  ) // 腿 C N.leap_only.1709985600000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/New_York", 1709985600000L),
    "1835413200000",
  ) // 腿 C N.leap_only.1709985600000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1709985600000L),
    "1835374500000",
  ) // 腿 C N.leap_only.1709985600000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1709985600000L),
    "1835355600000",
  ) // 腿 C N.leap_only.1709985600000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/Santiago", 1709985600000L),
    "1835406000000",
  ) // 腿 C N.leap_only.1709985600000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Tehran", 1709985600000L),
    "1835382600000",
  ) // 腿 C N.leap_only.1709985600000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 1730548800000L), "1835395200000") // 腿 C N.leap_only.1730548800000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 1730548800000L),
    "1835366400000",
  ) // 腿 C N.leap_only.1730548800000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/New_York", 1730548800000L),
    "1835413200000",
  ) // 腿 C N.leap_only.1730548800000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1730548800000L),
    "1835374500000",
  ) // 腿 C N.leap_only.1730548800000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1730548800000L),
    "1835355600000",
  ) // 腿 C N.leap_only.1730548800000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/Santiago", 1730548800000L),
    "1835406000000",
  ) // 腿 C N.leap_only.1730548800000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Tehran", 1730548800000L),
    "1835382600000",
  ) // 腿 C N.leap_only.1730548800000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 515505600000L), "573091200000") // 腿 C N.leap_only.515505600000.UTC|参照读数 573091200000（UTC 串 1988-02-29 00:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 515505600000L),
    "573062400000",
  ) // 腿 C N.leap_only.515505600000.Asia/Shanghai|参照读数 573062400000（UTC 串 1988-02-28 16:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/New_York", 515505600000L),
    "573109200000",
  ) // 腿 C N.leap_only.515505600000.America/New_York|参照读数 573109200000（UTC 串 1988-02-29 05:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 515505600000L),
    "573070500000",
  ) // 腿 C N.leap_only.515505600000.Asia/Kathmandu|参照读数 573070500000（UTC 串 1988-02-28 18:15:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 515505600000L),
    "573051600000",
  ) // 腿 C N.leap_only.515505600000.Australia/Lord_Howe|参照读数 573051600000（UTC 串 1988-02-28 13:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/Santiago", 515505600000L),
    "573102000000",
  ) // 腿 C N.leap_only.515505600000.America/Santiago|参照读数 573102000000（UTC 串 1988-02-29 03:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Tehran", 515505600000L),
    "573078600000",
  ) // 腿 C N.leap_only.515505600000.Asia/Tehran|参照读数 573078600000（UTC 串 1988-02-28 20:30:00）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 1725710400000L), "1835395200000") // 腿 C N.leap_only.1725710400000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 1725710400000L),
    "1835366400000",
  ) // 腿 C N.leap_only.1725710400000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/New_York", 1725710400000L),
    "1835413200000",
  ) // 腿 C N.leap_only.1725710400000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1725710400000L),
    "1835374500000",
  ) // 腿 C N.leap_only.1725710400000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1725710400000L),
    "1835355600000",
  ) // 腿 C N.leap_only.1725710400000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/Santiago", 1725710400000L),
    "1835406000000",
  ) // 腿 C N.leap_only.1725710400000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Tehran", 1725710400000L),
    "1835382600000",
  ) // 腿 C N.leap_only.1725710400000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znx_tag("0 0 0 29 2 *", "UTC", 1647864000000L), "1709164800000") // 腿 C N.leap_only.1647864000000.UTC|参照读数 1709164800000（UTC 串 2024-02-29 00:00:00）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znx_tag 行，严格晚于，第 4 块 180 条）" {
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Shanghai", 1647864000000L),
    "1709136000000",
  ) // 腿 C N.leap_only.1647864000000.Asia/Shanghai|参照读数 1709136000000（UTC 串 2024-02-28 16:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/New_York", 1647864000000L),
    "1709182800000",
  ) // 腿 C N.leap_only.1647864000000.America/New_York|参照读数 1709182800000（UTC 串 2024-02-29 05:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1647864000000L),
    "1709144100000",
  ) // 腿 C N.leap_only.1647864000000.Asia/Kathmandu|参照读数 1709144100000（UTC 串 2024-02-28 18:15:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1647864000000L),
    "1709125200000",
  ) // 腿 C N.leap_only.1647864000000.Australia/Lord_Howe|参照读数 1709125200000（UTC 串 2024-02-28 13:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "America/Santiago", 1647864000000L),
    "1709175600000",
  ) // 腿 C N.leap_only.1647864000000.America/Santiago|参照读数 1709175600000（UTC 串 2024-02-29 03:00:00）
  assert_eq(
    znx_tag("0 0 0 29 2 *", "Asia/Tehran", 1647864000000L),
    "1709152200000",
  ) // 腿 C N.leap_only.1647864000000.Asia/Tehran|参照读数 1709152200000（UTC 串 2024-02-28 20:30:00）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 1710050400000L), "1714478400000") // 腿 C N.apr31.1710050400000.UTC|参照读数 1714478400000（UTC 串 2024-04-30 12:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Shanghai", 1710050400000L),
    "1714449600000",
  ) // 腿 C N.apr31.1710050400000.Asia/Shanghai|参照读数 1714449600000（UTC 串 2024-04-30 04:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/New_York", 1710050400000L),
    "1714492800000",
  ) // 腿 C N.apr31.1710050400000.America/New_York|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Kathmandu", 1710050400000L),
    "1714457700000",
  ) // 腿 C N.apr31.1710050400000.Asia/Kathmandu|参照读数 1714457700000（UTC 串 2024-04-30 06:15:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 1710050400000L),
    "1714440600000",
  ) // 腿 C N.apr31.1710050400000.Australia/Lord_Howe|参照读数 1714440600000（UTC 串 2024-04-30 01:30:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/Santiago", 1710050400000L),
    "1714492800000",
  ) // 腿 C N.apr31.1710050400000.America/Santiago|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Tehran", 1710050400000L),
    "1714465800000",
  ) // 腿 C N.apr31.1710050400000.Asia/Tehran|参照读数 1714465800000（UTC 串 2024-04-30 08:30:00）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 1730611800000L), "1746014400000") // 腿 C N.apr31.1730611800000.UTC|参照读数 1746014400000（UTC 串 2025-04-30 12:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Shanghai", 1730611800000L),
    "1745985600000",
  ) // 腿 C N.apr31.1730611800000.Asia/Shanghai|参照读数 1745985600000（UTC 串 2025-04-30 04:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/New_York", 1730611800000L),
    "1746028800000",
  ) // 腿 C N.apr31.1730611800000.America/New_York|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Kathmandu", 1730611800000L),
    "1745993700000",
  ) // 腿 C N.apr31.1730611800000.Asia/Kathmandu|参照读数 1745993700000（UTC 串 2025-04-30 06:15:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 1730611800000L),
    "1745976600000",
  ) // 腿 C N.apr31.1730611800000.Australia/Lord_Howe|参照读数 1745976600000（UTC 串 2025-04-30 01:30:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/Santiago", 1730611800000L),
    "1746028800000",
  ) // 腿 C N.apr31.1730611800000.America/Santiago|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Tehran", 1730611800000L),
    "1746001800000",
  ) // 腿 C N.apr31.1730611800000.Asia/Tehran|参照读数 1746001800000（UTC 串 2025-04-30 08:30:00）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 1730615400000L), "1746014400000") // 腿 C N.apr31.1730615400000.UTC|参照读数 1746014400000（UTC 串 2025-04-30 12:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Shanghai", 1730615400000L),
    "1745985600000",
  ) // 腿 C N.apr31.1730615400000.Asia/Shanghai|参照读数 1745985600000（UTC 串 2025-04-30 04:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/New_York", 1730615400000L),
    "1746028800000",
  ) // 腿 C N.apr31.1730615400000.America/New_York|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Kathmandu", 1730615400000L),
    "1745993700000",
  ) // 腿 C N.apr31.1730615400000.Asia/Kathmandu|参照读数 1745993700000（UTC 串 2025-04-30 06:15:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 1730615400000L),
    "1745976600000",
  ) // 腿 C N.apr31.1730615400000.Australia/Lord_Howe|参照读数 1745976600000（UTC 串 2025-04-30 01:30:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/Santiago", 1730615400000L),
    "1746028800000",
  ) // 腿 C N.apr31.1730615400000.America/Santiago|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Tehran", 1730615400000L),
    "1746001800000",
  ) // 腿 C N.apr31.1730615400000.Asia/Tehran|参照读数 1746001800000（UTC 串 2025-04-30 08:30:00）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 1709208000000L), "1714478400000") // 腿 C N.apr31.1709208000000.UTC|参照读数 1714478400000（UTC 串 2024-04-30 12:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Shanghai", 1709208000000L),
    "1714449600000",
  ) // 腿 C N.apr31.1709208000000.Asia/Shanghai|参照读数 1714449600000（UTC 串 2024-04-30 04:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/New_York", 1709208000000L),
    "1714492800000",
  ) // 腿 C N.apr31.1709208000000.America/New_York|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Kathmandu", 1709208000000L),
    "1714457700000",
  ) // 腿 C N.apr31.1709208000000.Asia/Kathmandu|参照读数 1714457700000（UTC 串 2024-04-30 06:15:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 1709208000000L),
    "1714440600000",
  ) // 腿 C N.apr31.1709208000000.Australia/Lord_Howe|参照读数 1714440600000（UTC 串 2024-04-30 01:30:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/Santiago", 1709208000000L),
    "1714492800000",
  ) // 腿 C N.apr31.1709208000000.America/Santiago|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Tehran", 1709208000000L),
    "1714465800000",
  ) // 腿 C N.apr31.1709208000000.Asia/Tehran|参照读数 1714465800000（UTC 串 2024-04-30 08:30:00）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 1714435200000L), "1714478400000") // 腿 C N.apr31.1714435200000.UTC|参照读数 1714478400000（UTC 串 2024-04-30 12:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Shanghai", 1714435200000L),
    "1714449600000",
  ) // 腿 C N.apr31.1714435200000.Asia/Shanghai|参照读数 1714449600000（UTC 串 2024-04-30 04:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/New_York", 1714435200000L),
    "1714492800000",
  ) // 腿 C N.apr31.1714435200000.America/New_York|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Kathmandu", 1714435200000L),
    "1714457700000",
  ) // 腿 C N.apr31.1714435200000.Asia/Kathmandu|参照读数 1714457700000（UTC 串 2024-04-30 06:15:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 1714435200000L),
    "1714440600000",
  ) // 腿 C N.apr31.1714435200000.Australia/Lord_Howe|参照读数 1714440600000（UTC 串 2024-04-30 01:30:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/Santiago", 1714435200000L),
    "1714492800000",
  ) // 腿 C N.apr31.1714435200000.America/Santiago|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Tehran", 1714435200000L),
    "1714465800000",
  ) // 腿 C N.apr31.1714435200000.Asia/Tehran|参照读数 1714465800000（UTC 串 2024-04-30 08:30:00）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 515554200000L), "546782400000") // 腿 C N.apr31.515554200000.UTC|参照读数 546782400000（UTC 串 1987-04-30 12:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Shanghai", 515554200000L),
    "546750000000",
  ) // 腿 C N.apr31.515554200000.Asia/Shanghai|参照读数 546750000000（UTC 串 1987-04-30 03:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/New_York", 515554200000L),
    "546796800000",
  ) // 腿 C N.apr31.515554200000.America/New_York|参照读数 546796800000（UTC 串 1987-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Kathmandu", 515554200000L),
    "546761700000",
  ) // 腿 C N.apr31.515554200000.Asia/Kathmandu|参照读数 546761700000（UTC 串 1987-04-30 06:15:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 515554200000L),
    "546744600000",
  ) // 腿 C N.apr31.515554200000.Australia/Lord_Howe|参照读数 546744600000（UTC 串 1987-04-30 01:30:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/Santiago", 515554200000L),
    "546796800000",
  ) // 腿 C N.apr31.515554200000.America/Santiago|参照读数 546796800000（UTC 串 1987-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Tehran", 515554200000L),
    "546769800000",
  ) // 腿 C N.apr31.515554200000.Asia/Tehran|参照读数 546769800000（UTC 串 1987-04-30 08:30:00）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 4070822400000L), "null") // 腿 C N.apr31.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4081233600000｜UTC 2099-04-30 12:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 12 31 4 *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N.apr31.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4081204800000｜UTC 2099-04-30 04:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 12 31 4 *", "America/New_York", 4070822400000L), "null") // 腿 C N.apr31.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4081248000000｜UTC 2099-04-30 16:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 12 31 4 *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N.apr31.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4081212900000｜UTC 2099-04-30 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N.apr31.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4081195800000｜UTC 2099-04-30 01:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 12 31 4 *", "America/Santiago", 4070822400000L), "null") // 腿 C N.apr31.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4081248000000｜UTC 2099-04-30 16:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 12 31 4 *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.apr31.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4081221000000｜UTC 2099-04-30 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 1730606400000L), "1746014400000") // 腿 C N.apr31.1730606400000.UTC|参照读数 1746014400000（UTC 串 2025-04-30 12:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Shanghai", 1730606400000L),
    "1745985600000",
  ) // 腿 C N.apr31.1730606400000.Asia/Shanghai|参照读数 1745985600000（UTC 串 2025-04-30 04:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/New_York", 1730606400000L),
    "1746028800000",
  ) // 腿 C N.apr31.1730606400000.America/New_York|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Kathmandu", 1730606400000L),
    "1745993700000",
  ) // 腿 C N.apr31.1730606400000.Asia/Kathmandu|参照读数 1745993700000（UTC 串 2025-04-30 06:15:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 1730606400000L),
    "1745976600000",
  ) // 腿 C N.apr31.1730606400000.Australia/Lord_Howe|参照读数 1745976600000（UTC 串 2025-04-30 01:30:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/Santiago", 1730606400000L),
    "1746028800000",
  ) // 腿 C N.apr31.1730606400000.America/Santiago|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Tehran", 1730606400000L),
    "1746001800000",
  ) // 腿 C N.apr31.1730606400000.Asia/Tehran|参照读数 1746001800000（UTC 串 2025-04-30 08:30:00）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 1709985600000L), "1714478400000") // 腿 C N.apr31.1709985600000.UTC|参照读数 1714478400000（UTC 串 2024-04-30 12:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Shanghai", 1709985600000L),
    "1714449600000",
  ) // 腿 C N.apr31.1709985600000.Asia/Shanghai|参照读数 1714449600000（UTC 串 2024-04-30 04:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/New_York", 1709985600000L),
    "1714492800000",
  ) // 腿 C N.apr31.1709985600000.America/New_York|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Kathmandu", 1709985600000L),
    "1714457700000",
  ) // 腿 C N.apr31.1709985600000.Asia/Kathmandu|参照读数 1714457700000（UTC 串 2024-04-30 06:15:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 1709985600000L),
    "1714440600000",
  ) // 腿 C N.apr31.1709985600000.Australia/Lord_Howe|参照读数 1714440600000（UTC 串 2024-04-30 01:30:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/Santiago", 1709985600000L),
    "1714492800000",
  ) // 腿 C N.apr31.1709985600000.America/Santiago|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Tehran", 1709985600000L),
    "1714465800000",
  ) // 腿 C N.apr31.1709985600000.Asia/Tehran|参照读数 1714465800000（UTC 串 2024-04-30 08:30:00）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 1730548800000L), "1746014400000") // 腿 C N.apr31.1730548800000.UTC|参照读数 1746014400000（UTC 串 2025-04-30 12:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Shanghai", 1730548800000L),
    "1745985600000",
  ) // 腿 C N.apr31.1730548800000.Asia/Shanghai|参照读数 1745985600000（UTC 串 2025-04-30 04:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/New_York", 1730548800000L),
    "1746028800000",
  ) // 腿 C N.apr31.1730548800000.America/New_York|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Kathmandu", 1730548800000L),
    "1745993700000",
  ) // 腿 C N.apr31.1730548800000.Asia/Kathmandu|参照读数 1745993700000（UTC 串 2025-04-30 06:15:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 1730548800000L),
    "1745976600000",
  ) // 腿 C N.apr31.1730548800000.Australia/Lord_Howe|参照读数 1745976600000（UTC 串 2025-04-30 01:30:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/Santiago", 1730548800000L),
    "1746028800000",
  ) // 腿 C N.apr31.1730548800000.America/Santiago|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Tehran", 1730548800000L),
    "1746001800000",
  ) // 腿 C N.apr31.1730548800000.Asia/Tehran|参照读数 1746001800000（UTC 串 2025-04-30 08:30:00）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 515505600000L), "546782400000") // 腿 C N.apr31.515505600000.UTC|参照读数 546782400000（UTC 串 1987-04-30 12:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Shanghai", 515505600000L),
    "546750000000",
  ) // 腿 C N.apr31.515505600000.Asia/Shanghai|参照读数 546750000000（UTC 串 1987-04-30 03:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/New_York", 515505600000L),
    "546796800000",
  ) // 腿 C N.apr31.515505600000.America/New_York|参照读数 546796800000（UTC 串 1987-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Kathmandu", 515505600000L),
    "546761700000",
  ) // 腿 C N.apr31.515505600000.Asia/Kathmandu|参照读数 546761700000（UTC 串 1987-04-30 06:15:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 515505600000L),
    "546744600000",
  ) // 腿 C N.apr31.515505600000.Australia/Lord_Howe|参照读数 546744600000（UTC 串 1987-04-30 01:30:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/Santiago", 515505600000L),
    "546796800000",
  ) // 腿 C N.apr31.515505600000.America/Santiago|参照读数 546796800000（UTC 串 1987-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Tehran", 515505600000L),
    "546769800000",
  ) // 腿 C N.apr31.515505600000.Asia/Tehran|参照读数 546769800000（UTC 串 1987-04-30 08:30:00）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 1725710400000L), "1746014400000") // 腿 C N.apr31.1725710400000.UTC|参照读数 1746014400000（UTC 串 2025-04-30 12:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Shanghai", 1725710400000L),
    "1745985600000",
  ) // 腿 C N.apr31.1725710400000.Asia/Shanghai|参照读数 1745985600000（UTC 串 2025-04-30 04:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/New_York", 1725710400000L),
    "1746028800000",
  ) // 腿 C N.apr31.1725710400000.America/New_York|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Kathmandu", 1725710400000L),
    "1745993700000",
  ) // 腿 C N.apr31.1725710400000.Asia/Kathmandu|参照读数 1745993700000（UTC 串 2025-04-30 06:15:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 1725710400000L),
    "1745976600000",
  ) // 腿 C N.apr31.1725710400000.Australia/Lord_Howe|参照读数 1745976600000（UTC 串 2025-04-30 01:30:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/Santiago", 1725710400000L),
    "1746028800000",
  ) // 腿 C N.apr31.1725710400000.America/Santiago|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Tehran", 1725710400000L),
    "1746001800000",
  ) // 腿 C N.apr31.1725710400000.Asia/Tehran|参照读数 1746001800000（UTC 串 2025-04-30 08:30:00）
  assert_eq(znx_tag("0 12 31 4 *", "UTC", 1647864000000L), "1651320000000") // 腿 C N.apr31.1647864000000.UTC|参照读数 1651320000000（UTC 串 2022-04-30 12:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Shanghai", 1647864000000L),
    "1651291200000",
  ) // 腿 C N.apr31.1647864000000.Asia/Shanghai|参照读数 1651291200000（UTC 串 2022-04-30 04:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/New_York", 1647864000000L),
    "1651334400000",
  ) // 腿 C N.apr31.1647864000000.America/New_York|参照读数 1651334400000（UTC 串 2022-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Kathmandu", 1647864000000L),
    "1651299300000",
  ) // 腿 C N.apr31.1647864000000.Asia/Kathmandu|参照读数 1651299300000（UTC 串 2022-04-30 06:15:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Australia/Lord_Howe", 1647864000000L),
    "1651282200000",
  ) // 腿 C N.apr31.1647864000000.Australia/Lord_Howe|参照读数 1651282200000（UTC 串 2022-04-30 01:30:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "America/Santiago", 1647864000000L),
    "1651334400000",
  ) // 腿 C N.apr31.1647864000000.America/Santiago|参照读数 1651334400000（UTC 串 2022-04-30 16:00:00）
  assert_eq(
    znx_tag("0 12 31 4 *", "Asia/Tehran", 1647864000000L),
    "1651303800000",
  ) // 腿 C N.apr31.1647864000000.Asia/Tehran|参照读数 1651303800000（UTC 串 2022-04-30 07:30:00）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 1710050400000L), "1711843200000") // 腿 C N.last_day.1710050400000.UTC|参照读数 1711843200000（UTC 串 2024-03-31 00:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Shanghai", 1710050400000L),
    "1711814400000",
  ) // 腿 C N.last_day.1710050400000.Asia/Shanghai|参照读数 1711814400000（UTC 串 2024-03-30 16:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/New_York", 1710050400000L),
    "1711857600000",
  ) // 腿 C N.last_day.1710050400000.America/New_York|参照读数 1711857600000（UTC 串 2024-03-31 04:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Kathmandu", 1710050400000L),
    "1711822500000",
  ) // 腿 C N.last_day.1710050400000.Asia/Kathmandu|参照读数 1711822500000（UTC 串 2024-03-30 18:15:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 1710050400000L),
    "1711803600000",
  ) // 腿 C N.last_day.1710050400000.Australia/Lord_Howe|参照读数 1711803600000（UTC 串 2024-03-30 13:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/Santiago", 1710050400000L),
    "1711854000000",
  ) // 腿 C N.last_day.1710050400000.America/Santiago|参照读数 1711854000000（UTC 串 2024-03-31 03:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Tehran", 1710050400000L),
    "1711830600000",
  ) // 腿 C N.last_day.1710050400000.Asia/Tehran|参照读数 1711830600000（UTC 串 2024-03-30 20:30:00）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 1730611800000L), "1732924800000") // 腿 C N.last_day.1730611800000.UTC|参照读数 1732924800000（UTC 串 2024-11-30 00:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Shanghai", 1730611800000L),
    "1732896000000",
  ) // 腿 C N.last_day.1730611800000.Asia/Shanghai|参照读数 1732896000000（UTC 串 2024-11-29 16:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/New_York", 1730611800000L),
    "1732942800000",
  ) // 腿 C N.last_day.1730611800000.America/New_York|参照读数 1732942800000（UTC 串 2024-11-30 05:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Kathmandu", 1730611800000L),
    "1732904100000",
  ) // 腿 C N.last_day.1730611800000.Asia/Kathmandu|参照读数 1732904100000（UTC 串 2024-11-29 18:15:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 1730611800000L),
    "1732885200000",
  ) // 腿 C N.last_day.1730611800000.Australia/Lord_Howe|参照读数 1732885200000（UTC 串 2024-11-29 13:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/Santiago", 1730611800000L),
    "1732935600000",
  ) // 腿 C N.last_day.1730611800000.America/Santiago|参照读数 1732935600000（UTC 串 2024-11-30 03:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Tehran", 1730611800000L),
    "1732912200000",
  ) // 腿 C N.last_day.1730611800000.Asia/Tehran|参照读数 1732912200000（UTC 串 2024-11-29 20:30:00）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 1730615400000L), "1732924800000") // 腿 C N.last_day.1730615400000.UTC|参照读数 1732924800000（UTC 串 2024-11-30 00:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Shanghai", 1730615400000L),
    "1732896000000",
  ) // 腿 C N.last_day.1730615400000.Asia/Shanghai|参照读数 1732896000000（UTC 串 2024-11-29 16:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/New_York", 1730615400000L),
    "1732942800000",
  ) // 腿 C N.last_day.1730615400000.America/New_York|参照读数 1732942800000（UTC 串 2024-11-30 05:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Kathmandu", 1730615400000L),
    "1732904100000",
  ) // 腿 C N.last_day.1730615400000.Asia/Kathmandu|参照读数 1732904100000（UTC 串 2024-11-29 18:15:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 1730615400000L),
    "1732885200000",
  ) // 腿 C N.last_day.1730615400000.Australia/Lord_Howe|参照读数 1732885200000（UTC 串 2024-11-29 13:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/Santiago", 1730615400000L),
    "1732935600000",
  ) // 腿 C N.last_day.1730615400000.America/Santiago|参照读数 1732935600000（UTC 串 2024-11-30 03:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Tehran", 1730615400000L),
    "1732912200000",
  ) // 腿 C N.last_day.1730615400000.Asia/Tehran|参照读数 1732912200000（UTC 串 2024-11-29 20:30:00）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 1709208000000L), "1711843200000") // 腿 C N.last_day.1709208000000.UTC|参照读数 1711843200000（UTC 串 2024-03-31 00:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Shanghai", 1709208000000L),
    "1711814400000",
  ) // 腿 C N.last_day.1709208000000.Asia/Shanghai|参照读数 1711814400000（UTC 串 2024-03-30 16:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/New_York", 1709208000000L),
    "1711857600000",
  ) // 腿 C N.last_day.1709208000000.America/New_York|参照读数 1711857600000（UTC 串 2024-03-31 04:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Kathmandu", 1709208000000L),
    "1711822500000",
  ) // 腿 C N.last_day.1709208000000.Asia/Kathmandu|参照读数 1711822500000（UTC 串 2024-03-30 18:15:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 1709208000000L),
    "1711803600000",
  ) // 腿 C N.last_day.1709208000000.Australia/Lord_Howe|参照读数 1711803600000（UTC 串 2024-03-30 13:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/Santiago", 1709208000000L),
    "1711854000000",
  ) // 腿 C N.last_day.1709208000000.America/Santiago|参照读数 1711854000000（UTC 串 2024-03-31 03:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Tehran", 1709208000000L),
    "1711830600000",
  ) // 腿 C N.last_day.1709208000000.Asia/Tehran|参照读数 1711830600000（UTC 串 2024-03-30 20:30:00）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 1714435200000L), "1717113600000") // 腿 C N.last_day.1714435200000.UTC|参照读数 1717113600000（UTC 串 2024-05-31 00:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Shanghai", 1714435200000L),
    "1717084800000",
  ) // 腿 C N.last_day.1714435200000.Asia/Shanghai|参照读数 1717084800000（UTC 串 2024-05-30 16:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/New_York", 1714435200000L),
    "1714449600000",
  ) // 腿 C N.last_day.1714435200000.America/New_York|参照读数 1714449600000（UTC 串 2024-04-30 04:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Kathmandu", 1714435200000L),
    "1717092900000",
  ) // 腿 C N.last_day.1714435200000.Asia/Kathmandu|参照读数 1717092900000（UTC 串 2024-05-30 18:15:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 1714435200000L),
    "1717075800000",
  ) // 腿 C N.last_day.1714435200000.Australia/Lord_Howe|参照读数 1717075800000（UTC 串 2024-05-30 13:30:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/Santiago", 1714435200000L),
    "1714449600000",
  ) // 腿 C N.last_day.1714435200000.America/Santiago|参照读数 1714449600000（UTC 串 2024-04-30 04:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Tehran", 1714435200000L),
    "1717101000000",
  ) // 腿 C N.last_day.1714435200000.Asia/Tehran|参照读数 1717101000000（UTC 串 2024-05-30 20:30:00）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 515554200000L), "517881600000") // 腿 C N.last_day.515554200000.UTC|参照读数 517881600000（UTC 串 1986-05-31 00:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Shanghai", 515554200000L),
    "517849200000",
  ) // 腿 C N.last_day.515554200000.Asia/Shanghai|参照读数 517849200000（UTC 串 1986-05-30 15:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/New_York", 515554200000L),
    "517896000000",
  ) // 腿 C N.last_day.515554200000.America/New_York|参照读数 517896000000（UTC 串 1986-05-31 04:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Kathmandu", 515554200000L),
    "517860900000",
  ) // 腿 C N.last_day.515554200000.Asia/Kathmandu|参照读数 517860900000（UTC 串 1986-05-30 18:15:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 515554200000L),
    "517843800000",
  ) // 腿 C N.last_day.515554200000.Australia/Lord_Howe|参照读数 517843800000（UTC 串 1986-05-30 13:30:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/Santiago", 515554200000L),
    "517896000000",
  ) // 腿 C N.last_day.515554200000.America/Santiago|参照读数 517896000000（UTC 串 1986-05-31 04:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Tehran", 515554200000L),
    "517869000000",
  ) // 腿 C N.last_day.515554200000.Asia/Tehran|参照读数 517869000000（UTC 串 1986-05-30 20:30:00）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 4070822400000L), "null") // 腿 C N.last_day.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4073500800000｜UTC 2099-01-31 00:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 L * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N.last_day.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4073472000000｜UTC 2099-01-30 16:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 L * *", "America/New_York", 4070822400000L), "null") // 腿 C N.last_day.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070840400000｜UTC 2098-12-31 05:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 L * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N.last_day.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4073480100000｜UTC 2099-01-30 18:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N.last_day.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4073461200000｜UTC 2099-01-30 13:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 L * *", "America/Santiago", 4070822400000L), "null") // 腿 C N.last_day.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070833200000｜UTC 2098-12-31 03:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 L * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.last_day.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4073488200000｜UTC 2099-01-30 20:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 1730606400000L), "1732924800000") // 腿 C N.last_day.1730606400000.UTC|参照读数 1732924800000（UTC 串 2024-11-30 00:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Shanghai", 1730606400000L),
    "1732896000000",
  ) // 腿 C N.last_day.1730606400000.Asia/Shanghai|参照读数 1732896000000（UTC 串 2024-11-29 16:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/New_York", 1730606400000L),
    "1732942800000",
  ) // 腿 C N.last_day.1730606400000.America/New_York|参照读数 1732942800000（UTC 串 2024-11-30 05:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Kathmandu", 1730606400000L),
    "1732904100000",
  ) // 腿 C N.last_day.1730606400000.Asia/Kathmandu|参照读数 1732904100000（UTC 串 2024-11-29 18:15:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 1730606400000L),
    "1732885200000",
  ) // 腿 C N.last_day.1730606400000.Australia/Lord_Howe|参照读数 1732885200000（UTC 串 2024-11-29 13:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/Santiago", 1730606400000L),
    "1732935600000",
  ) // 腿 C N.last_day.1730606400000.America/Santiago|参照读数 1732935600000（UTC 串 2024-11-30 03:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Tehran", 1730606400000L),
    "1732912200000",
  ) // 腿 C N.last_day.1730606400000.Asia/Tehran|参照读数 1732912200000（UTC 串 2024-11-29 20:30:00）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 1709985600000L), "1711843200000") // 腿 C N.last_day.1709985600000.UTC|参照读数 1711843200000（UTC 串 2024-03-31 00:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Shanghai", 1709985600000L),
    "1711814400000",
  ) // 腿 C N.last_day.1709985600000.Asia/Shanghai|参照读数 1711814400000（UTC 串 2024-03-30 16:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/New_York", 1709985600000L),
    "1711857600000",
  ) // 腿 C N.last_day.1709985600000.America/New_York|参照读数 1711857600000（UTC 串 2024-03-31 04:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Kathmandu", 1709985600000L),
    "1711822500000",
  ) // 腿 C N.last_day.1709985600000.Asia/Kathmandu|参照读数 1711822500000（UTC 串 2024-03-30 18:15:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 1709985600000L),
    "1711803600000",
  ) // 腿 C N.last_day.1709985600000.Australia/Lord_Howe|参照读数 1711803600000（UTC 串 2024-03-30 13:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/Santiago", 1709985600000L),
    "1711854000000",
  ) // 腿 C N.last_day.1709985600000.America/Santiago|参照读数 1711854000000（UTC 串 2024-03-31 03:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Tehran", 1709985600000L),
    "1711830600000",
  ) // 腿 C N.last_day.1709985600000.Asia/Tehran|参照读数 1711830600000（UTC 串 2024-03-30 20:30:00）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 1730548800000L), "1732924800000") // 腿 C N.last_day.1730548800000.UTC|参照读数 1732924800000（UTC 串 2024-11-30 00:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Shanghai", 1730548800000L),
    "1732896000000",
  ) // 腿 C N.last_day.1730548800000.Asia/Shanghai|参照读数 1732896000000（UTC 串 2024-11-29 16:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/New_York", 1730548800000L),
    "1732942800000",
  ) // 腿 C N.last_day.1730548800000.America/New_York|参照读数 1732942800000（UTC 串 2024-11-30 05:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Kathmandu", 1730548800000L),
    "1732904100000",
  ) // 腿 C N.last_day.1730548800000.Asia/Kathmandu|参照读数 1732904100000（UTC 串 2024-11-29 18:15:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 1730548800000L),
    "1732885200000",
  ) // 腿 C N.last_day.1730548800000.Australia/Lord_Howe|参照读数 1732885200000（UTC 串 2024-11-29 13:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/Santiago", 1730548800000L),
    "1732935600000",
  ) // 腿 C N.last_day.1730548800000.America/Santiago|参照读数 1732935600000（UTC 串 2024-11-30 03:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Tehran", 1730548800000L),
    "1732912200000",
  ) // 腿 C N.last_day.1730548800000.Asia/Tehran|参照读数 1732912200000（UTC 串 2024-11-29 20:30:00）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 515505600000L), "517881600000") // 腿 C N.last_day.515505600000.UTC|参照读数 517881600000（UTC 串 1986-05-31 00:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Shanghai", 515505600000L),
    "517849200000",
  ) // 腿 C N.last_day.515505600000.Asia/Shanghai|参照读数 517849200000（UTC 串 1986-05-30 15:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/New_York", 515505600000L),
    "517896000000",
  ) // 腿 C N.last_day.515505600000.America/New_York|参照读数 517896000000（UTC 串 1986-05-31 04:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Kathmandu", 515505600000L),
    "517860900000",
  ) // 腿 C N.last_day.515505600000.Asia/Kathmandu|参照读数 517860900000（UTC 串 1986-05-30 18:15:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 515505600000L),
    "517843800000",
  ) // 腿 C N.last_day.515505600000.Australia/Lord_Howe|参照读数 517843800000（UTC 串 1986-05-30 13:30:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/Santiago", 515505600000L),
    "517896000000",
  ) // 腿 C N.last_day.515505600000.America/Santiago|参照读数 517896000000（UTC 串 1986-05-31 04:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Tehran", 515505600000L),
    "517869000000",
  ) // 腿 C N.last_day.515505600000.Asia/Tehran|参照读数 517869000000（UTC 串 1986-05-30 20:30:00）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 1725710400000L), "1727654400000") // 腿 C N.last_day.1725710400000.UTC|参照读数 1727654400000（UTC 串 2024-09-30 00:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Shanghai", 1725710400000L),
    "1727625600000",
  ) // 腿 C N.last_day.1725710400000.Asia/Shanghai|参照读数 1727625600000（UTC 串 2024-09-29 16:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/New_York", 1725710400000L),
    "1727668800000",
  ) // 腿 C N.last_day.1725710400000.America/New_York|参照读数 1727668800000（UTC 串 2024-09-30 04:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Kathmandu", 1725710400000L),
    "1727633700000",
  ) // 腿 C N.last_day.1725710400000.Asia/Kathmandu|参照读数 1727633700000（UTC 串 2024-09-29 18:15:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 1725710400000L),
    "1727616600000",
  ) // 腿 C N.last_day.1725710400000.Australia/Lord_Howe|参照读数 1727616600000（UTC 串 2024-09-29 13:30:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/Santiago", 1725710400000L),
    "1727665200000",
  ) // 腿 C N.last_day.1725710400000.America/Santiago|参照读数 1727665200000（UTC 串 2024-09-30 03:00:00）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znx_tag 行，严格晚于，第 5 块 180 条）" {
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Tehran", 1725710400000L),
    "1727641800000",
  ) // 腿 C N.last_day.1725710400000.Asia/Tehran|参照读数 1727641800000（UTC 串 2024-09-29 20:30:00）
  assert_eq(znx_tag("0 0 0 L * *", "UTC", 1647864000000L), "1648684800000") // 腿 C N.last_day.1647864000000.UTC|参照读数 1648684800000（UTC 串 2022-03-31 00:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Shanghai", 1647864000000L),
    "1648656000000",
  ) // 腿 C N.last_day.1647864000000.Asia/Shanghai|参照读数 1648656000000（UTC 串 2022-03-30 16:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/New_York", 1647864000000L),
    "1648699200000",
  ) // 腿 C N.last_day.1647864000000.America/New_York|参照读数 1648699200000（UTC 串 2022-03-31 04:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Kathmandu", 1647864000000L),
    "1648664100000",
  ) // 腿 C N.last_day.1647864000000.Asia/Kathmandu|参照读数 1648664100000（UTC 串 2022-03-30 18:15:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Australia/Lord_Howe", 1647864000000L),
    "1648645200000",
  ) // 腿 C N.last_day.1647864000000.Australia/Lord_Howe|参照读数 1648645200000（UTC 串 2022-03-30 13:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "America/Santiago", 1647864000000L),
    "1648695600000",
  ) // 腿 C N.last_day.1647864000000.America/Santiago|参照读数 1648695600000（UTC 串 2022-03-31 03:00:00）
  assert_eq(
    znx_tag("0 0 0 L * *", "Asia/Tehran", 1647864000000L),
    "1648668600000",
  ) // 腿 C N.last_day.1647864000000.Asia/Tehran|参照读数 1648668600000（UTC 串 2022-03-30 19:30:00）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 1710050400000L), "1711972800000") // 腿 C N.dom_and_dow.1710050400000.UTC|参照读数 1711972800000（UTC 串 2024-04-01 12:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Shanghai", 1710050400000L),
    "1711944000000",
  ) // 腿 C N.dom_and_dow.1710050400000.Asia/Shanghai|参照读数 1711944000000（UTC 串 2024-04-01 04:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/New_York", 1710050400000L),
    "1711987200000",
  ) // 腿 C N.dom_and_dow.1710050400000.America/New_York|参照读数 1711987200000（UTC 串 2024-04-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Kathmandu", 1710050400000L),
    "1711952100000",
  ) // 腿 C N.dom_and_dow.1710050400000.Asia/Kathmandu|参照读数 1711952100000（UTC 串 2024-04-01 06:15:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 1710050400000L),
    "1711933200000",
  ) // 腿 C N.dom_and_dow.1710050400000.Australia/Lord_Howe|参照读数 1711933200000（UTC 串 2024-04-01 01:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/Santiago", 1710050400000L),
    "1711983600000",
  ) // 腿 C N.dom_and_dow.1710050400000.America/Santiago|参照读数 1711983600000（UTC 串 2024-04-01 15:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Tehran", 1710050400000L),
    "1711960200000",
  ) // 腿 C N.dom_and_dow.1710050400000.Asia/Tehran|参照读数 1711960200000（UTC 串 2024-04-01 08:30:00）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 1730611800000L), "1756728000000") // 腿 C N.dom_and_dow.1730611800000.UTC|参照读数 1756728000000（UTC 串 2025-09-01 12:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Shanghai", 1730611800000L),
    "1756699200000",
  ) // 腿 C N.dom_and_dow.1730611800000.Asia/Shanghai|参照读数 1756699200000（UTC 串 2025-09-01 04:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/New_York", 1730611800000L),
    "1756742400000",
  ) // 腿 C N.dom_and_dow.1730611800000.America/New_York|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Kathmandu", 1730611800000L),
    "1756707300000",
  ) // 腿 C N.dom_and_dow.1730611800000.Asia/Kathmandu|参照读数 1756707300000（UTC 串 2025-09-01 06:15:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 1730611800000L),
    "1756690200000",
  ) // 腿 C N.dom_and_dow.1730611800000.Australia/Lord_Howe|参照读数 1756690200000（UTC 串 2025-09-01 01:30:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/Santiago", 1730611800000L),
    "1756742400000",
  ) // 腿 C N.dom_and_dow.1730611800000.America/Santiago|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Tehran", 1730611800000L),
    "1756715400000",
  ) // 腿 C N.dom_and_dow.1730611800000.Asia/Tehran|参照读数 1756715400000（UTC 串 2025-09-01 08:30:00）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 1730615400000L), "1756728000000") // 腿 C N.dom_and_dow.1730615400000.UTC|参照读数 1756728000000（UTC 串 2025-09-01 12:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Shanghai", 1730615400000L),
    "1756699200000",
  ) // 腿 C N.dom_and_dow.1730615400000.Asia/Shanghai|参照读数 1756699200000（UTC 串 2025-09-01 04:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/New_York", 1730615400000L),
    "1756742400000",
  ) // 腿 C N.dom_and_dow.1730615400000.America/New_York|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Kathmandu", 1730615400000L),
    "1756707300000",
  ) // 腿 C N.dom_and_dow.1730615400000.Asia/Kathmandu|参照读数 1756707300000（UTC 串 2025-09-01 06:15:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 1730615400000L),
    "1756690200000",
  ) // 腿 C N.dom_and_dow.1730615400000.Australia/Lord_Howe|参照读数 1756690200000（UTC 串 2025-09-01 01:30:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/Santiago", 1730615400000L),
    "1756742400000",
  ) // 腿 C N.dom_and_dow.1730615400000.America/Santiago|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Tehran", 1730615400000L),
    "1756715400000",
  ) // 腿 C N.dom_and_dow.1730615400000.Asia/Tehran|参照读数 1756715400000（UTC 串 2025-09-01 08:30:00）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 1709208000000L), "1711972800000") // 腿 C N.dom_and_dow.1709208000000.UTC|参照读数 1711972800000（UTC 串 2024-04-01 12:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Shanghai", 1709208000000L),
    "1711944000000",
  ) // 腿 C N.dom_and_dow.1709208000000.Asia/Shanghai|参照读数 1711944000000（UTC 串 2024-04-01 04:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/New_York", 1709208000000L),
    "1711987200000",
  ) // 腿 C N.dom_and_dow.1709208000000.America/New_York|参照读数 1711987200000（UTC 串 2024-04-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Kathmandu", 1709208000000L),
    "1711952100000",
  ) // 腿 C N.dom_and_dow.1709208000000.Asia/Kathmandu|参照读数 1711952100000（UTC 串 2024-04-01 06:15:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 1709208000000L),
    "1711933200000",
  ) // 腿 C N.dom_and_dow.1709208000000.Australia/Lord_Howe|参照读数 1711933200000（UTC 串 2024-04-01 01:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/Santiago", 1709208000000L),
    "1711983600000",
  ) // 腿 C N.dom_and_dow.1709208000000.America/Santiago|参照读数 1711983600000（UTC 串 2024-04-01 15:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Tehran", 1709208000000L),
    "1711960200000",
  ) // 腿 C N.dom_and_dow.1709208000000.Asia/Tehran|参照读数 1711960200000（UTC 串 2024-04-01 08:30:00）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 1714435200000L), "1719835200000") // 腿 C N.dom_and_dow.1714435200000.UTC|参照读数 1719835200000（UTC 串 2024-07-01 12:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Shanghai", 1714435200000L),
    "1719806400000",
  ) // 腿 C N.dom_and_dow.1714435200000.Asia/Shanghai|参照读数 1719806400000（UTC 串 2024-07-01 04:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/New_York", 1714435200000L),
    "1719849600000",
  ) // 腿 C N.dom_and_dow.1714435200000.America/New_York|参照读数 1719849600000（UTC 串 2024-07-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Kathmandu", 1714435200000L),
    "1719814500000",
  ) // 腿 C N.dom_and_dow.1714435200000.Asia/Kathmandu|参照读数 1719814500000（UTC 串 2024-07-01 06:15:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 1714435200000L),
    "1719797400000",
  ) // 腿 C N.dom_and_dow.1714435200000.Australia/Lord_Howe|参照读数 1719797400000（UTC 串 2024-07-01 01:30:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/Santiago", 1714435200000L),
    "1719849600000",
  ) // 腿 C N.dom_and_dow.1714435200000.America/Santiago|参照读数 1719849600000（UTC 串 2024-07-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Tehran", 1714435200000L),
    "1719822600000",
  ) // 腿 C N.dom_and_dow.1714435200000.Asia/Tehran|参照读数 1719822600000（UTC 串 2024-07-01 08:30:00）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 515554200000L), "525960000000") // 腿 C N.dom_and_dow.515554200000.UTC|参照读数 525960000000（UTC 串 1986-09-01 12:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Shanghai", 515554200000L),
    "525927600000",
  ) // 腿 C N.dom_and_dow.515554200000.Asia/Shanghai|参照读数 525927600000（UTC 串 1986-09-01 03:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/New_York", 515554200000L),
    "525974400000",
  ) // 腿 C N.dom_and_dow.515554200000.America/New_York|参照读数 525974400000（UTC 串 1986-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Kathmandu", 515554200000L),
    "525939300000",
  ) // 腿 C N.dom_and_dow.515554200000.Asia/Kathmandu|参照读数 525939300000（UTC 串 1986-09-01 06:15:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 515554200000L),
    "525922200000",
  ) // 腿 C N.dom_and_dow.515554200000.Australia/Lord_Howe|参照读数 525922200000（UTC 串 1986-09-01 01:30:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/Santiago", 515554200000L),
    "525974400000",
  ) // 腿 C N.dom_and_dow.515554200000.America/Santiago|参照读数 525974400000（UTC 串 1986-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Tehran", 515554200000L),
    "525947400000",
  ) // 腿 C N.dom_and_dow.515554200000.Asia/Tehran|参照读数 525947400000（UTC 串 1986-09-01 08:30:00）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 4070822400000L), "null") // 腿 C N.dom_and_dow.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4083998400000｜UTC 2099-06-01 12:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 12 1 * MON", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N.dom_and_dow.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4083969600000｜UTC 2099-06-01 04:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 12 1 * MON", "America/New_York", 4070822400000L), "null") // 腿 C N.dom_and_dow.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4084012800000｜UTC 2099-06-01 16:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 12 1 * MON", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N.dom_and_dow.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4083977700000｜UTC 2099-06-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N.dom_and_dow.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4083960600000｜UTC 2099-06-01 01:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 12 1 * MON", "America/Santiago", 4070822400000L), "null") // 腿 C N.dom_and_dow.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4084012800000｜UTC 2099-06-01 16:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 12 1 * MON", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.dom_and_dow.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4083985800000｜UTC 2099-06-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 1730606400000L), "1756728000000") // 腿 C N.dom_and_dow.1730606400000.UTC|参照读数 1756728000000（UTC 串 2025-09-01 12:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Shanghai", 1730606400000L),
    "1756699200000",
  ) // 腿 C N.dom_and_dow.1730606400000.Asia/Shanghai|参照读数 1756699200000（UTC 串 2025-09-01 04:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/New_York", 1730606400000L),
    "1756742400000",
  ) // 腿 C N.dom_and_dow.1730606400000.America/New_York|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Kathmandu", 1730606400000L),
    "1756707300000",
  ) // 腿 C N.dom_and_dow.1730606400000.Asia/Kathmandu|参照读数 1756707300000（UTC 串 2025-09-01 06:15:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 1730606400000L),
    "1756690200000",
  ) // 腿 C N.dom_and_dow.1730606400000.Australia/Lord_Howe|参照读数 1756690200000（UTC 串 2025-09-01 01:30:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/Santiago", 1730606400000L),
    "1756742400000",
  ) // 腿 C N.dom_and_dow.1730606400000.America/Santiago|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Tehran", 1730606400000L),
    "1756715400000",
  ) // 腿 C N.dom_and_dow.1730606400000.Asia/Tehran|参照读数 1756715400000（UTC 串 2025-09-01 08:30:00）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 1709985600000L), "1711972800000") // 腿 C N.dom_and_dow.1709985600000.UTC|参照读数 1711972800000（UTC 串 2024-04-01 12:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Shanghai", 1709985600000L),
    "1711944000000",
  ) // 腿 C N.dom_and_dow.1709985600000.Asia/Shanghai|参照读数 1711944000000（UTC 串 2024-04-01 04:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/New_York", 1709985600000L),
    "1711987200000",
  ) // 腿 C N.dom_and_dow.1709985600000.America/New_York|参照读数 1711987200000（UTC 串 2024-04-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Kathmandu", 1709985600000L),
    "1711952100000",
  ) // 腿 C N.dom_and_dow.1709985600000.Asia/Kathmandu|参照读数 1711952100000（UTC 串 2024-04-01 06:15:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 1709985600000L),
    "1711933200000",
  ) // 腿 C N.dom_and_dow.1709985600000.Australia/Lord_Howe|参照读数 1711933200000（UTC 串 2024-04-01 01:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/Santiago", 1709985600000L),
    "1711983600000",
  ) // 腿 C N.dom_and_dow.1709985600000.America/Santiago|参照读数 1711983600000（UTC 串 2024-04-01 15:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Tehran", 1709985600000L),
    "1711960200000",
  ) // 腿 C N.dom_and_dow.1709985600000.Asia/Tehran|参照读数 1711960200000（UTC 串 2024-04-01 08:30:00）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 1730548800000L), "1756728000000") // 腿 C N.dom_and_dow.1730548800000.UTC|参照读数 1756728000000（UTC 串 2025-09-01 12:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Shanghai", 1730548800000L),
    "1756699200000",
  ) // 腿 C N.dom_and_dow.1730548800000.Asia/Shanghai|参照读数 1756699200000（UTC 串 2025-09-01 04:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/New_York", 1730548800000L),
    "1756742400000",
  ) // 腿 C N.dom_and_dow.1730548800000.America/New_York|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Kathmandu", 1730548800000L),
    "1756707300000",
  ) // 腿 C N.dom_and_dow.1730548800000.Asia/Kathmandu|参照读数 1756707300000（UTC 串 2025-09-01 06:15:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 1730548800000L),
    "1756690200000",
  ) // 腿 C N.dom_and_dow.1730548800000.Australia/Lord_Howe|参照读数 1756690200000（UTC 串 2025-09-01 01:30:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/Santiago", 1730548800000L),
    "1756742400000",
  ) // 腿 C N.dom_and_dow.1730548800000.America/Santiago|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Tehran", 1730548800000L),
    "1756715400000",
  ) // 腿 C N.dom_and_dow.1730548800000.Asia/Tehran|参照读数 1756715400000（UTC 串 2025-09-01 08:30:00）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 515505600000L), "525960000000") // 腿 C N.dom_and_dow.515505600000.UTC|参照读数 525960000000（UTC 串 1986-09-01 12:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Shanghai", 515505600000L),
    "525927600000",
  ) // 腿 C N.dom_and_dow.515505600000.Asia/Shanghai|参照读数 525927600000（UTC 串 1986-09-01 03:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/New_York", 515505600000L),
    "525974400000",
  ) // 腿 C N.dom_and_dow.515505600000.America/New_York|参照读数 525974400000（UTC 串 1986-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Kathmandu", 515505600000L),
    "525939300000",
  ) // 腿 C N.dom_and_dow.515505600000.Asia/Kathmandu|参照读数 525939300000（UTC 串 1986-09-01 06:15:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 515505600000L),
    "525922200000",
  ) // 腿 C N.dom_and_dow.515505600000.Australia/Lord_Howe|参照读数 525922200000（UTC 串 1986-09-01 01:30:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/Santiago", 515505600000L),
    "525974400000",
  ) // 腿 C N.dom_and_dow.515505600000.America/Santiago|参照读数 525974400000（UTC 串 1986-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Tehran", 515505600000L),
    "525947400000",
  ) // 腿 C N.dom_and_dow.515505600000.Asia/Tehran|参照读数 525947400000（UTC 串 1986-09-01 08:30:00）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 1725710400000L), "1756728000000") // 腿 C N.dom_and_dow.1725710400000.UTC|参照读数 1756728000000（UTC 串 2025-09-01 12:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Shanghai", 1725710400000L),
    "1756699200000",
  ) // 腿 C N.dom_and_dow.1725710400000.Asia/Shanghai|参照读数 1756699200000（UTC 串 2025-09-01 04:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/New_York", 1725710400000L),
    "1756742400000",
  ) // 腿 C N.dom_and_dow.1725710400000.America/New_York|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Kathmandu", 1725710400000L),
    "1756707300000",
  ) // 腿 C N.dom_and_dow.1725710400000.Asia/Kathmandu|参照读数 1756707300000（UTC 串 2025-09-01 06:15:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 1725710400000L),
    "1756690200000",
  ) // 腿 C N.dom_and_dow.1725710400000.Australia/Lord_Howe|参照读数 1756690200000（UTC 串 2025-09-01 01:30:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/Santiago", 1725710400000L),
    "1756742400000",
  ) // 腿 C N.dom_and_dow.1725710400000.America/Santiago|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Tehran", 1725710400000L),
    "1756715400000",
  ) // 腿 C N.dom_and_dow.1725710400000.Asia/Tehran|参照读数 1756715400000（UTC 串 2025-09-01 08:30:00）
  assert_eq(znx_tag("0 12 1 * MON", "UTC", 1647864000000L), "1659355200000") // 腿 C N.dom_and_dow.1647864000000.UTC|参照读数 1659355200000（UTC 串 2022-08-01 12:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Shanghai", 1647864000000L),
    "1659326400000",
  ) // 腿 C N.dom_and_dow.1647864000000.Asia/Shanghai|参照读数 1659326400000（UTC 串 2022-08-01 04:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/New_York", 1647864000000L),
    "1659369600000",
  ) // 腿 C N.dom_and_dow.1647864000000.America/New_York|参照读数 1659369600000（UTC 串 2022-08-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Kathmandu", 1647864000000L),
    "1659334500000",
  ) // 腿 C N.dom_and_dow.1647864000000.Asia/Kathmandu|参照读数 1659334500000（UTC 串 2022-08-01 06:15:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Australia/Lord_Howe", 1647864000000L),
    "1659317400000",
  ) // 腿 C N.dom_and_dow.1647864000000.Australia/Lord_Howe|参照读数 1659317400000（UTC 串 2022-08-01 01:30:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "America/Santiago", 1647864000000L),
    "1659369600000",
  ) // 腿 C N.dom_and_dow.1647864000000.America/Santiago|参照读数 1659369600000（UTC 串 2022-08-01 16:00:00）
  assert_eq(
    znx_tag("0 12 1 * MON", "Asia/Tehran", 1647864000000L),
    "1659339000000",
  ) // 腿 C N.dom_and_dow.1647864000000.Asia/Tehran|参照读数 1659339000000（UTC 串 2022-08-01 07:30:00）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 1710050400000L), "1710115199000") // 腿 C N.end_of_day.1710050400000.UTC|参照读数 1710115199000（UTC 串 2024-03-10 23:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Shanghai", 1710050400000L),
    "1710086399000",
  ) // 腿 C N.end_of_day.1710050400000.Asia/Shanghai|参照读数 1710086399000（UTC 串 2024-03-10 15:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 1710050400000L),
    "1710129599000",
  ) // 腿 C N.end_of_day.1710050400000.America/New_York|参照读数 1710129599000（UTC 串 2024-03-11 03:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Kathmandu", 1710050400000L),
    "1710094499000",
  ) // 腿 C N.end_of_day.1710050400000.Asia/Kathmandu|参照读数 1710094499000（UTC 串 2024-03-10 18:14:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710075599000",
  ) // 腿 C N.end_of_day.1710050400000.Australia/Lord_Howe|参照读数 1710075599000（UTC 串 2024-03-10 12:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 1710050400000L),
    "1710125999000",
  ) // 腿 C N.end_of_day.1710050400000.America/Santiago|参照读数 1710125999000（UTC 串 2024-03-11 02:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Tehran", 1710050400000L),
    "1710102599000",
  ) // 腿 C N.end_of_day.1710050400000.Asia/Tehran|参照读数 1710102599000（UTC 串 2024-03-10 20:29:59）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 1730611800000L), "1730678399000") // 腿 C N.end_of_day.1730611800000.UTC|参照读数 1730678399000（UTC 串 2024-11-03 23:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Shanghai", 1730611800000L),
    "1730649599000",
  ) // 腿 C N.end_of_day.1730611800000.Asia/Shanghai|参照读数 1730649599000（UTC 串 2024-11-03 15:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 1730611800000L),
    "1730696399000",
  ) // 腿 C N.end_of_day.1730611800000.America/New_York|参照读数 1730696399000（UTC 串 2024-11-04 04:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Kathmandu", 1730611800000L),
    "1730657699000",
  ) // 腿 C N.end_of_day.1730611800000.Asia/Kathmandu|参照读数 1730657699000（UTC 串 2024-11-03 18:14:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730638799000",
  ) // 腿 C N.end_of_day.1730611800000.Australia/Lord_Howe|参照读数 1730638799000（UTC 串 2024-11-03 12:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 1730611800000L),
    "1730689199000",
  ) // 腿 C N.end_of_day.1730611800000.America/Santiago|参照读数 1730689199000（UTC 串 2024-11-04 02:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Tehran", 1730611800000L),
    "1730665799000",
  ) // 腿 C N.end_of_day.1730611800000.Asia/Tehran|参照读数 1730665799000（UTC 串 2024-11-03 20:29:59）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 1730615400000L), "1730678399000") // 腿 C N.end_of_day.1730615400000.UTC|参照读数 1730678399000（UTC 串 2024-11-03 23:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Shanghai", 1730615400000L),
    "1730649599000",
  ) // 腿 C N.end_of_day.1730615400000.Asia/Shanghai|参照读数 1730649599000（UTC 串 2024-11-03 15:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 1730615400000L),
    "1730696399000",
  ) // 腿 C N.end_of_day.1730615400000.America/New_York|参照读数 1730696399000（UTC 串 2024-11-04 04:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Kathmandu", 1730615400000L),
    "1730657699000",
  ) // 腿 C N.end_of_day.1730615400000.Asia/Kathmandu|参照读数 1730657699000（UTC 串 2024-11-03 18:14:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730638799000",
  ) // 腿 C N.end_of_day.1730615400000.Australia/Lord_Howe|参照读数 1730638799000（UTC 串 2024-11-03 12:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 1730615400000L),
    "1730689199000",
  ) // 腿 C N.end_of_day.1730615400000.America/Santiago|参照读数 1730689199000（UTC 串 2024-11-04 02:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Tehran", 1730615400000L),
    "1730665799000",
  ) // 腿 C N.end_of_day.1730615400000.Asia/Tehran|参照读数 1730665799000（UTC 串 2024-11-03 20:29:59）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 1709208000000L), "1709251199000") // 腿 C N.end_of_day.1709208000000.UTC|参照读数 1709251199000（UTC 串 2024-02-29 23:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Shanghai", 1709208000000L),
    "1709222399000",
  ) // 腿 C N.end_of_day.1709208000000.Asia/Shanghai|参照读数 1709222399000（UTC 串 2024-02-29 15:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 1709208000000L),
    "1709269199000",
  ) // 腿 C N.end_of_day.1709208000000.America/New_York|参照读数 1709269199000（UTC 串 2024-03-01 04:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Kathmandu", 1709208000000L),
    "1709230499000",
  ) // 腿 C N.end_of_day.1709208000000.Asia/Kathmandu|参照读数 1709230499000（UTC 串 2024-02-29 18:14:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709211599000",
  ) // 腿 C N.end_of_day.1709208000000.Australia/Lord_Howe|参照读数 1709211599000（UTC 串 2024-02-29 12:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 1709208000000L),
    "1709261999000",
  ) // 腿 C N.end_of_day.1709208000000.America/Santiago|参照读数 1709261999000（UTC 串 2024-03-01 02:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Tehran", 1709208000000L),
    "1709238599000",
  ) // 腿 C N.end_of_day.1709208000000.Asia/Tehran|参照读数 1709238599000（UTC 串 2024-02-29 20:29:59）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 1714435200000L), "1714521599000") // 腿 C N.end_of_day.1714435200000.UTC|参照读数 1714521599000（UTC 串 2024-04-30 23:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Shanghai", 1714435200000L),
    "1714492799000",
  ) // 腿 C N.end_of_day.1714435200000.Asia/Shanghai|参照读数 1714492799000（UTC 串 2024-04-30 15:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 1714435200000L),
    "1714449599000",
  ) // 腿 C N.end_of_day.1714435200000.America/New_York|参照读数 1714449599000（UTC 串 2024-04-30 03:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Kathmandu", 1714435200000L),
    "1714500899000",
  ) // 腿 C N.end_of_day.1714435200000.Asia/Kathmandu|参照读数 1714500899000（UTC 串 2024-04-30 18:14:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714483799000",
  ) // 腿 C N.end_of_day.1714435200000.Australia/Lord_Howe|参照读数 1714483799000（UTC 串 2024-04-30 13:29:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 1714435200000L),
    "1714449599000",
  ) // 腿 C N.end_of_day.1714435200000.America/Santiago|参照读数 1714449599000（UTC 串 2024-04-30 03:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Tehran", 1714435200000L),
    "1714508999000",
  ) // 腿 C N.end_of_day.1714435200000.Asia/Tehran|参照读数 1714508999000（UTC 串 2024-04-30 20:29:59）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 515554200000L), "515635199000") // 腿 C N.end_of_day.515554200000.UTC|参照读数 515635199000（UTC 串 1986-05-04 23:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Shanghai", 515554200000L),
    "515602799000",
  ) // 腿 C N.end_of_day.515554200000.Asia/Shanghai|参照读数 515602799000（UTC 串 1986-05-04 14:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 515554200000L),
    "515563199000",
  ) // 腿 C N.end_of_day.515554200000.America/New_York|参照读数 515563199000（UTC 串 1986-05-04 03:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Kathmandu", 515554200000L),
    "515614499000",
  ) // 腿 C N.end_of_day.515554200000.Asia/Kathmandu|参照读数 515614499000（UTC 串 1986-05-04 18:14:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 515554200000L),
    "515597399000",
  ) // 腿 C N.end_of_day.515554200000.Australia/Lord_Howe|参照读数 515597399000（UTC 串 1986-05-04 13:29:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 515554200000L),
    "515563199000",
  ) // 腿 C N.end_of_day.515554200000.America/Santiago|参照读数 515563199000（UTC 串 1986-05-04 03:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Tehran", 515554200000L),
    "515622599000",
  ) // 腿 C N.end_of_day.515554200000.Asia/Tehran|参照读数 515622599000（UTC 串 1986-05-04 20:29:59）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 4070822400000L), "null") // 腿 C N.end_of_day.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070908799000｜UTC 2098-12-31 23:59:59，spec §11 第 4 行）
  assert_eq(znx_tag("59 59 23 * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N.end_of_day.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070879999000｜UTC 2098-12-31 15:59:59，spec §11 第 4 行）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 4070822400000L),
    "null",
  ) // 腿 C N.end_of_day.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070840399000｜UTC 2098-12-31 04:59:59，spec §11 第 4 行）
  assert_eq(znx_tag("59 59 23 * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N.end_of_day.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070888099000｜UTC 2098-12-31 18:14:59，spec §11 第 4 行）
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N.end_of_day.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070869199000｜UTC 2098-12-31 12:59:59，spec §11 第 4 行）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 4070822400000L),
    "null",
  ) // 腿 C N.end_of_day.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070833199000｜UTC 2098-12-31 02:59:59，spec §11 第 4 行）
  assert_eq(znx_tag("59 59 23 * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.end_of_day.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070896199000｜UTC 2098-12-31 20:29:59，spec §11 第 4 行）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 1730606400000L), "1730678399000") // 腿 C N.end_of_day.1730606400000.UTC|参照读数 1730678399000（UTC 串 2024-11-03 23:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Shanghai", 1730606400000L),
    "1730649599000",
  ) // 腿 C N.end_of_day.1730606400000.Asia/Shanghai|参照读数 1730649599000（UTC 串 2024-11-03 15:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 1730606400000L),
    "1730696399000",
  ) // 腿 C N.end_of_day.1730606400000.America/New_York|参照读数 1730696399000（UTC 串 2024-11-04 04:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Kathmandu", 1730606400000L),
    "1730657699000",
  ) // 腿 C N.end_of_day.1730606400000.Asia/Kathmandu|参照读数 1730657699000（UTC 串 2024-11-03 18:14:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730638799000",
  ) // 腿 C N.end_of_day.1730606400000.Australia/Lord_Howe|参照读数 1730638799000（UTC 串 2024-11-03 12:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 1730606400000L),
    "1730689199000",
  ) // 腿 C N.end_of_day.1730606400000.America/Santiago|参照读数 1730689199000（UTC 串 2024-11-04 02:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Tehran", 1730606400000L),
    "1730665799000",
  ) // 腿 C N.end_of_day.1730606400000.Asia/Tehran|参照读数 1730665799000（UTC 串 2024-11-03 20:29:59）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 1709985600000L), "1710028799000") // 腿 C N.end_of_day.1709985600000.UTC|参照读数 1710028799000（UTC 串 2024-03-09 23:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Shanghai", 1709985600000L),
    "1709999999000",
  ) // 腿 C N.end_of_day.1709985600000.Asia/Shanghai|参照读数 1709999999000（UTC 串 2024-03-09 15:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 1709985600000L),
    "1710046799000",
  ) // 腿 C N.end_of_day.1709985600000.America/New_York|参照读数 1710046799000（UTC 串 2024-03-10 04:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Kathmandu", 1709985600000L),
    "1710008099000",
  ) // 腿 C N.end_of_day.1709985600000.Asia/Kathmandu|参照读数 1710008099000（UTC 串 2024-03-09 18:14:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709989199000",
  ) // 腿 C N.end_of_day.1709985600000.Australia/Lord_Howe|参照读数 1709989199000（UTC 串 2024-03-09 12:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 1709985600000L),
    "1710039599000",
  ) // 腿 C N.end_of_day.1709985600000.America/Santiago|参照读数 1710039599000（UTC 串 2024-03-10 02:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Tehran", 1709985600000L),
    "1710016199000",
  ) // 腿 C N.end_of_day.1709985600000.Asia/Tehran|参照读数 1710016199000（UTC 串 2024-03-09 20:29:59）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 1730548800000L), "1730591999000") // 腿 C N.end_of_day.1730548800000.UTC|参照读数 1730591999000（UTC 串 2024-11-02 23:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Shanghai", 1730548800000L),
    "1730563199000",
  ) // 腿 C N.end_of_day.1730548800000.Asia/Shanghai|参照读数 1730563199000（UTC 串 2024-11-02 15:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 1730548800000L),
    "1730606399000",
  ) // 腿 C N.end_of_day.1730548800000.America/New_York|参照读数 1730606399000（UTC 串 2024-11-03 03:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Kathmandu", 1730548800000L),
    "1730571299000",
  ) // 腿 C N.end_of_day.1730548800000.Asia/Kathmandu|参照读数 1730571299000（UTC 串 2024-11-02 18:14:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730552399000",
  ) // 腿 C N.end_of_day.1730548800000.Australia/Lord_Howe|参照读数 1730552399000（UTC 串 2024-11-02 12:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 1730548800000L),
    "1730602799000",
  ) // 腿 C N.end_of_day.1730548800000.America/Santiago|参照读数 1730602799000（UTC 串 2024-11-03 02:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Tehran", 1730548800000L),
    "1730579399000",
  ) // 腿 C N.end_of_day.1730548800000.Asia/Tehran|参照读数 1730579399000（UTC 串 2024-11-02 20:29:59）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 515505600000L), "515548799000") // 腿 C N.end_of_day.515505600000.UTC|参照读数 515548799000（UTC 串 1986-05-03 23:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Shanghai", 515505600000L),
    "515519999000",
  ) // 腿 C N.end_of_day.515505600000.Asia/Shanghai|参照读数 515519999000（UTC 串 1986-05-03 15:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 515505600000L),
    "515563199000",
  ) // 腿 C N.end_of_day.515505600000.America/New_York|参照读数 515563199000（UTC 串 1986-05-04 03:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Kathmandu", 515505600000L),
    "515528099000",
  ) // 腿 C N.end_of_day.515505600000.Asia/Kathmandu|参照读数 515528099000（UTC 串 1986-05-03 18:14:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 515505600000L),
    "515510999000",
  ) // 腿 C N.end_of_day.515505600000.Australia/Lord_Howe|参照读数 515510999000（UTC 串 1986-05-03 13:29:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 515505600000L),
    "515563199000",
  ) // 腿 C N.end_of_day.515505600000.America/Santiago|参照读数 515563199000（UTC 串 1986-05-04 03:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Tehran", 515505600000L),
    "515536199000",
  ) // 腿 C N.end_of_day.515505600000.Asia/Tehran|参照读数 515536199000（UTC 串 1986-05-03 20:29:59）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 1725710400000L), "1725753599000") // 腿 C N.end_of_day.1725710400000.UTC|参照读数 1725753599000（UTC 串 2024-09-07 23:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Shanghai", 1725710400000L),
    "1725724799000",
  ) // 腿 C N.end_of_day.1725710400000.Asia/Shanghai|参照读数 1725724799000（UTC 串 2024-09-07 15:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 1725710400000L),
    "1725767999000",
  ) // 腿 C N.end_of_day.1725710400000.America/New_York|参照读数 1725767999000（UTC 串 2024-09-08 03:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Kathmandu", 1725710400000L),
    "1725732899000",
  ) // 腿 C N.end_of_day.1725710400000.Asia/Kathmandu|参照读数 1725732899000（UTC 串 2024-09-07 18:14:59）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znx_tag 行，严格晚于，第 6 块 180 条）" {
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725715799000",
  ) // 腿 C N.end_of_day.1725710400000.Australia/Lord_Howe|参照读数 1725715799000（UTC 串 2024-09-07 13:29:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 1725710400000L),
    "1725767999000",
  ) // 腿 C N.end_of_day.1725710400000.America/Santiago|参照读数 1725767999000（UTC 串 2024-09-08 03:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Tehran", 1725710400000L),
    "1725740999000",
  ) // 腿 C N.end_of_day.1725710400000.Asia/Tehran|参照读数 1725740999000（UTC 串 2024-09-07 20:29:59）
  assert_eq(znx_tag("59 59 23 * * *", "UTC", 1647864000000L), "1647907199000") // 腿 C N.end_of_day.1647864000000.UTC|参照读数 1647907199000（UTC 串 2022-03-21 23:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Shanghai", 1647864000000L),
    "1647878399000",
  ) // 腿 C N.end_of_day.1647864000000.Asia/Shanghai|参照读数 1647878399000（UTC 串 2022-03-21 15:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/New_York", 1647864000000L),
    "1647921599000",
  ) // 腿 C N.end_of_day.1647864000000.America/New_York|参照读数 1647921599000（UTC 串 2022-03-22 03:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Kathmandu", 1647864000000L),
    "1647886499000",
  ) // 腿 C N.end_of_day.1647864000000.Asia/Kathmandu|参照读数 1647886499000（UTC 串 2022-03-21 18:14:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647867599000",
  ) // 腿 C N.end_of_day.1647864000000.Australia/Lord_Howe|参照读数 1647867599000（UTC 串 2022-03-21 12:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "America/Santiago", 1647864000000L),
    "1647917999000",
  ) // 腿 C N.end_of_day.1647864000000.America/Santiago|参照读数 1647917999000（UTC 串 2022-03-22 02:59:59）
  assert_eq(
    znx_tag("59 59 23 * * *", "Asia/Tehran", 1647864000000L),
    "1647894599000",
  ) // 腿 C N.end_of_day.1647864000000.Asia/Tehran|参照读数 1647894599000（UTC 串 2022-03-21 20:29:59）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 1710050400000L), "1710050415000") // 腿 C N.step15s.1710050400000.UTC|参照读数 1710050415000（UTC 串 2024-03-10 06:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Shanghai", 1710050400000L),
    "1710050415000",
  ) // 腿 C N.step15s.1710050400000.Asia/Shanghai|参照读数 1710050415000（UTC 串 2024-03-10 06:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 1710050400000L),
    "1710050415000",
  ) // 腿 C N.step15s.1710050400000.America/New_York|参照读数 1710050415000（UTC 串 2024-03-10 06:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Kathmandu", 1710050400000L),
    "1710050415000",
  ) // 腿 C N.step15s.1710050400000.Asia/Kathmandu|参照读数 1710050415000（UTC 串 2024-03-10 06:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710050415000",
  ) // 腿 C N.step15s.1710050400000.Australia/Lord_Howe|参照读数 1710050415000（UTC 串 2024-03-10 06:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 1710050400000L),
    "1710050415000",
  ) // 腿 C N.step15s.1710050400000.America/Santiago|参照读数 1710050415000（UTC 串 2024-03-10 06:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Tehran", 1710050400000L),
    "1710050415000",
  ) // 腿 C N.step15s.1710050400000.Asia/Tehran|参照读数 1710050415000（UTC 串 2024-03-10 06:00:15）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 1730611800000L), "1730611815000") // 腿 C N.step15s.1730611800000.UTC|参照读数 1730611815000（UTC 串 2024-11-03 05:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Shanghai", 1730611800000L),
    "1730611815000",
  ) // 腿 C N.step15s.1730611800000.Asia/Shanghai|参照读数 1730611815000（UTC 串 2024-11-03 05:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 1730611800000L),
    "1730615415000",
  ) // 腿 C N.step15s.1730611800000.America/New_York|参照读数 1730615415000（UTC 串 2024-11-03 06:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Kathmandu", 1730611800000L),
    "1730611815000",
  ) // 腿 C N.step15s.1730611800000.Asia/Kathmandu|参照读数 1730611815000（UTC 串 2024-11-03 05:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730611815000",
  ) // 腿 C N.step15s.1730611800000.Australia/Lord_Howe|参照读数 1730611815000（UTC 串 2024-11-03 05:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 1730611800000L),
    "1730611815000",
  ) // 腿 C N.step15s.1730611800000.America/Santiago|参照读数 1730611815000（UTC 串 2024-11-03 05:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Tehran", 1730611800000L),
    "1730611815000",
  ) // 腿 C N.step15s.1730611800000.Asia/Tehran|参照读数 1730611815000（UTC 串 2024-11-03 05:30:15）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 1730615400000L), "1730615415000") // 腿 C N.step15s.1730615400000.UTC|参照读数 1730615415000（UTC 串 2024-11-03 06:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Shanghai", 1730615400000L),
    "1730615415000",
  ) // 腿 C N.step15s.1730615400000.Asia/Shanghai|参照读数 1730615415000（UTC 串 2024-11-03 06:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 1730615400000L),
    "1730615415000",
  ) // 腿 C N.step15s.1730615400000.America/New_York|参照读数 1730615415000（UTC 串 2024-11-03 06:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Kathmandu", 1730615400000L),
    "1730615415000",
  ) // 腿 C N.step15s.1730615400000.Asia/Kathmandu|参照读数 1730615415000（UTC 串 2024-11-03 06:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730615415000",
  ) // 腿 C N.step15s.1730615400000.Australia/Lord_Howe|参照读数 1730615415000（UTC 串 2024-11-03 06:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 1730615400000L),
    "1730615415000",
  ) // 腿 C N.step15s.1730615400000.America/Santiago|参照读数 1730615415000（UTC 串 2024-11-03 06:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Tehran", 1730615400000L),
    "1730615415000",
  ) // 腿 C N.step15s.1730615400000.Asia/Tehran|参照读数 1730615415000（UTC 串 2024-11-03 06:30:15）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 1709208000000L), "1709208015000") // 腿 C N.step15s.1709208000000.UTC|参照读数 1709208015000（UTC 串 2024-02-29 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Shanghai", 1709208000000L),
    "1709208015000",
  ) // 腿 C N.step15s.1709208000000.Asia/Shanghai|参照读数 1709208015000（UTC 串 2024-02-29 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 1709208000000L),
    "1709208015000",
  ) // 腿 C N.step15s.1709208000000.America/New_York|参照读数 1709208015000（UTC 串 2024-02-29 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Kathmandu", 1709208000000L),
    "1709208015000",
  ) // 腿 C N.step15s.1709208000000.Asia/Kathmandu|参照读数 1709208015000（UTC 串 2024-02-29 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709208015000",
  ) // 腿 C N.step15s.1709208000000.Australia/Lord_Howe|参照读数 1709208015000（UTC 串 2024-02-29 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 1709208000000L),
    "1709208015000",
  ) // 腿 C N.step15s.1709208000000.America/Santiago|参照读数 1709208015000（UTC 串 2024-02-29 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Tehran", 1709208000000L),
    "1709208015000",
  ) // 腿 C N.step15s.1709208000000.Asia/Tehran|参照读数 1709208015000（UTC 串 2024-02-29 12:00:15）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 1714435200000L), "1714435215000") // 腿 C N.step15s.1714435200000.UTC|参照读数 1714435215000（UTC 串 2024-04-30 00:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Shanghai", 1714435200000L),
    "1714435215000",
  ) // 腿 C N.step15s.1714435200000.Asia/Shanghai|参照读数 1714435215000（UTC 串 2024-04-30 00:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 1714435200000L),
    "1714435215000",
  ) // 腿 C N.step15s.1714435200000.America/New_York|参照读数 1714435215000（UTC 串 2024-04-30 00:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Kathmandu", 1714435200000L),
    "1714435215000",
  ) // 腿 C N.step15s.1714435200000.Asia/Kathmandu|参照读数 1714435215000（UTC 串 2024-04-30 00:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714435215000",
  ) // 腿 C N.step15s.1714435200000.Australia/Lord_Howe|参照读数 1714435215000（UTC 串 2024-04-30 00:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 1714435200000L),
    "1714435215000",
  ) // 腿 C N.step15s.1714435200000.America/Santiago|参照读数 1714435215000（UTC 串 2024-04-30 00:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Tehran", 1714435200000L),
    "1714435215000",
  ) // 腿 C N.step15s.1714435200000.Asia/Tehran|参照读数 1714435215000（UTC 串 2024-04-30 00:00:15）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 515554200000L), "515554215000") // 腿 C N.step15s.515554200000.UTC|参照读数 515554215000（UTC 串 1986-05-04 01:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Shanghai", 515554200000L),
    "515554215000",
  ) // 腿 C N.step15s.515554200000.Asia/Shanghai|参照读数 515554215000（UTC 串 1986-05-04 01:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 515554200000L),
    "515554215000",
  ) // 腿 C N.step15s.515554200000.America/New_York|参照读数 515554215000（UTC 串 1986-05-04 01:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Kathmandu", 515554200000L),
    "515554215000",
  ) // 腿 C N.step15s.515554200000.Asia/Kathmandu|参照读数 515554215000（UTC 串 1986-05-04 01:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 515554200000L),
    "515554215000",
  ) // 腿 C N.step15s.515554200000.Australia/Lord_Howe|参照读数 515554215000（UTC 串 1986-05-04 01:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 515554200000L),
    "515554215000",
  ) // 腿 C N.step15s.515554200000.America/Santiago|参照读数 515554215000（UTC 串 1986-05-04 01:30:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Tehran", 515554200000L),
    "515554215000",
  ) // 腿 C N.step15s.515554200000.Asia/Tehran|参照读数 515554215000（UTC 串 1986-05-04 01:30:15）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 4070822400000L), "null") // 腿 C N.step15s.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070822415000｜UTC 2098-12-31 00:00:15，spec §11 第 4 行）
  assert_eq(znx_tag("*/15 * * * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N.step15s.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070822415000｜UTC 2098-12-31 00:00:15，spec §11 第 4 行）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 4070822400000L),
    "null",
  ) // 腿 C N.step15s.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070822415000｜UTC 2098-12-31 00:00:15，spec §11 第 4 行）
  assert_eq(znx_tag("*/15 * * * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N.step15s.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070822415000｜UTC 2098-12-31 00:00:15，spec §11 第 4 行）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N.step15s.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070822415000｜UTC 2098-12-31 00:00:15，spec §11 第 4 行）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 4070822400000L),
    "null",
  ) // 腿 C N.step15s.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070822415000｜UTC 2098-12-31 00:00:15，spec §11 第 4 行）
  assert_eq(znx_tag("*/15 * * * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.step15s.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070822415000｜UTC 2098-12-31 00:00:15，spec §11 第 4 行）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 1730606400000L), "1730606415000") // 腿 C N.step15s.1730606400000.UTC|参照读数 1730606415000（UTC 串 2024-11-03 04:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Shanghai", 1730606400000L),
    "1730606415000",
  ) // 腿 C N.step15s.1730606400000.Asia/Shanghai|参照读数 1730606415000（UTC 串 2024-11-03 04:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 1730606400000L),
    "1730606415000",
  ) // 腿 C N.step15s.1730606400000.America/New_York|参照读数 1730606415000（UTC 串 2024-11-03 04:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Kathmandu", 1730606400000L),
    "1730606415000",
  ) // 腿 C N.step15s.1730606400000.Asia/Kathmandu|参照读数 1730606415000（UTC 串 2024-11-03 04:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730606415000",
  ) // 腿 C N.step15s.1730606400000.Australia/Lord_Howe|参照读数 1730606415000（UTC 串 2024-11-03 04:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 1730606400000L),
    "1730606415000",
  ) // 腿 C N.step15s.1730606400000.America/Santiago|参照读数 1730606415000（UTC 串 2024-11-03 04:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Tehran", 1730606400000L),
    "1730606415000",
  ) // 腿 C N.step15s.1730606400000.Asia/Tehran|参照读数 1730606415000（UTC 串 2024-11-03 04:00:15）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 1709985600000L), "1709985615000") // 腿 C N.step15s.1709985600000.UTC|参照读数 1709985615000（UTC 串 2024-03-09 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Shanghai", 1709985600000L),
    "1709985615000",
  ) // 腿 C N.step15s.1709985600000.Asia/Shanghai|参照读数 1709985615000（UTC 串 2024-03-09 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 1709985600000L),
    "1709985615000",
  ) // 腿 C N.step15s.1709985600000.America/New_York|参照读数 1709985615000（UTC 串 2024-03-09 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Kathmandu", 1709985600000L),
    "1709985615000",
  ) // 腿 C N.step15s.1709985600000.Asia/Kathmandu|参照读数 1709985615000（UTC 串 2024-03-09 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709985615000",
  ) // 腿 C N.step15s.1709985600000.Australia/Lord_Howe|参照读数 1709985615000（UTC 串 2024-03-09 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 1709985600000L),
    "1709985615000",
  ) // 腿 C N.step15s.1709985600000.America/Santiago|参照读数 1709985615000（UTC 串 2024-03-09 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Tehran", 1709985600000L),
    "1709985615000",
  ) // 腿 C N.step15s.1709985600000.Asia/Tehran|参照读数 1709985615000（UTC 串 2024-03-09 12:00:15）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 1730548800000L), "1730548815000") // 腿 C N.step15s.1730548800000.UTC|参照读数 1730548815000（UTC 串 2024-11-02 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Shanghai", 1730548800000L),
    "1730548815000",
  ) // 腿 C N.step15s.1730548800000.Asia/Shanghai|参照读数 1730548815000（UTC 串 2024-11-02 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 1730548800000L),
    "1730548815000",
  ) // 腿 C N.step15s.1730548800000.America/New_York|参照读数 1730548815000（UTC 串 2024-11-02 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Kathmandu", 1730548800000L),
    "1730548815000",
  ) // 腿 C N.step15s.1730548800000.Asia/Kathmandu|参照读数 1730548815000（UTC 串 2024-11-02 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730548815000",
  ) // 腿 C N.step15s.1730548800000.Australia/Lord_Howe|参照读数 1730548815000（UTC 串 2024-11-02 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 1730548800000L),
    "1730548815000",
  ) // 腿 C N.step15s.1730548800000.America/Santiago|参照读数 1730548815000（UTC 串 2024-11-02 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Tehran", 1730548800000L),
    "1730548815000",
  ) // 腿 C N.step15s.1730548800000.Asia/Tehran|参照读数 1730548815000（UTC 串 2024-11-02 12:00:15）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 515505600000L), "515505615000") // 腿 C N.step15s.515505600000.UTC|参照读数 515505615000（UTC 串 1986-05-03 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Shanghai", 515505600000L),
    "515505615000",
  ) // 腿 C N.step15s.515505600000.Asia/Shanghai|参照读数 515505615000（UTC 串 1986-05-03 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 515505600000L),
    "515505615000",
  ) // 腿 C N.step15s.515505600000.America/New_York|参照读数 515505615000（UTC 串 1986-05-03 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Kathmandu", 515505600000L),
    "515505615000",
  ) // 腿 C N.step15s.515505600000.Asia/Kathmandu|参照读数 515505615000（UTC 串 1986-05-03 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 515505600000L),
    "515505615000",
  ) // 腿 C N.step15s.515505600000.Australia/Lord_Howe|参照读数 515505615000（UTC 串 1986-05-03 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 515505600000L),
    "515505615000",
  ) // 腿 C N.step15s.515505600000.America/Santiago|参照读数 515505615000（UTC 串 1986-05-03 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Tehran", 515505600000L),
    "515505615000",
  ) // 腿 C N.step15s.515505600000.Asia/Tehran|参照读数 515505615000（UTC 串 1986-05-03 12:00:15）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 1725710400000L), "1725710415000") // 腿 C N.step15s.1725710400000.UTC|参照读数 1725710415000（UTC 串 2024-09-07 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Shanghai", 1725710400000L),
    "1725710415000",
  ) // 腿 C N.step15s.1725710400000.Asia/Shanghai|参照读数 1725710415000（UTC 串 2024-09-07 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 1725710400000L),
    "1725710415000",
  ) // 腿 C N.step15s.1725710400000.America/New_York|参照读数 1725710415000（UTC 串 2024-09-07 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Kathmandu", 1725710400000L),
    "1725710415000",
  ) // 腿 C N.step15s.1725710400000.Asia/Kathmandu|参照读数 1725710415000（UTC 串 2024-09-07 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725710415000",
  ) // 腿 C N.step15s.1725710400000.Australia/Lord_Howe|参照读数 1725710415000（UTC 串 2024-09-07 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 1725710400000L),
    "1725710415000",
  ) // 腿 C N.step15s.1725710400000.America/Santiago|参照读数 1725710415000（UTC 串 2024-09-07 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Tehran", 1725710400000L),
    "1725710415000",
  ) // 腿 C N.step15s.1725710400000.Asia/Tehran|参照读数 1725710415000（UTC 串 2024-09-07 12:00:15）
  assert_eq(znx_tag("*/15 * * * * *", "UTC", 1647864000000L), "1647864015000") // 腿 C N.step15s.1647864000000.UTC|参照读数 1647864015000（UTC 串 2022-03-21 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Shanghai", 1647864000000L),
    "1647864015000",
  ) // 腿 C N.step15s.1647864000000.Asia/Shanghai|参照读数 1647864015000（UTC 串 2022-03-21 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/New_York", 1647864000000L),
    "1647864015000",
  ) // 腿 C N.step15s.1647864000000.America/New_York|参照读数 1647864015000（UTC 串 2022-03-21 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Kathmandu", 1647864000000L),
    "1647864015000",
  ) // 腿 C N.step15s.1647864000000.Asia/Kathmandu|参照读数 1647864015000（UTC 串 2022-03-21 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647864015000",
  ) // 腿 C N.step15s.1647864000000.Australia/Lord_Howe|参照读数 1647864015000（UTC 串 2022-03-21 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "America/Santiago", 1647864000000L),
    "1647864015000",
  ) // 腿 C N.step15s.1647864000000.America/Santiago|参照读数 1647864015000（UTC 串 2022-03-21 12:00:15）
  assert_eq(
    znx_tag("*/15 * * * * *", "Asia/Tehran", 1647864000000L),
    "1647864015000",
  ) // 腿 C N.step15s.1647864000000.Asia/Tehran|参照读数 1647864015000（UTC 串 2022-03-21 12:00:15）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 1710050400000L), "null") // 腿 C N.year_2099.1710050400000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1710050400000L),
    "null",
  ) // 腿 C N.year_2099.1710050400000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 1710050400000L),
    "null",
  ) // 腿 C N.year_2099.1710050400000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1710050400000L),
    "null",
  ) // 腿 C N.year_2099.1710050400000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1710050400000L),
    "null",
  ) // 腿 C N.year_2099.1710050400000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 1710050400000L),
    "null",
  ) // 腿 C N.year_2099.1710050400000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1710050400000L), "null") // 腿 C N.year_2099.1710050400000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 1730611800000L), "null") // 腿 C N.year_2099.1730611800000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1730611800000L),
    "null",
  ) // 腿 C N.year_2099.1730611800000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 1730611800000L),
    "null",
  ) // 腿 C N.year_2099.1730611800000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1730611800000L),
    "null",
  ) // 腿 C N.year_2099.1730611800000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1730611800000L),
    "null",
  ) // 腿 C N.year_2099.1730611800000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 1730611800000L),
    "null",
  ) // 腿 C N.year_2099.1730611800000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1730611800000L), "null") // 腿 C N.year_2099.1730611800000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 1730615400000L), "null") // 腿 C N.year_2099.1730615400000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1730615400000L),
    "null",
  ) // 腿 C N.year_2099.1730615400000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 1730615400000L),
    "null",
  ) // 腿 C N.year_2099.1730615400000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1730615400000L),
    "null",
  ) // 腿 C N.year_2099.1730615400000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1730615400000L),
    "null",
  ) // 腿 C N.year_2099.1730615400000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 1730615400000L),
    "null",
  ) // 腿 C N.year_2099.1730615400000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1730615400000L), "null") // 腿 C N.year_2099.1730615400000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 1709208000000L), "null") // 腿 C N.year_2099.1709208000000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1709208000000L),
    "null",
  ) // 腿 C N.year_2099.1709208000000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 1709208000000L),
    "null",
  ) // 腿 C N.year_2099.1709208000000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1709208000000L),
    "null",
  ) // 腿 C N.year_2099.1709208000000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1709208000000L),
    "null",
  ) // 腿 C N.year_2099.1709208000000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 1709208000000L),
    "null",
  ) // 腿 C N.year_2099.1709208000000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1709208000000L), "null") // 腿 C N.year_2099.1709208000000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 1714435200000L), "null") // 腿 C N.year_2099.1714435200000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1714435200000L),
    "null",
  ) // 腿 C N.year_2099.1714435200000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 1714435200000L),
    "null",
  ) // 腿 C N.year_2099.1714435200000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1714435200000L),
    "null",
  ) // 腿 C N.year_2099.1714435200000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1714435200000L),
    "null",
  ) // 腿 C N.year_2099.1714435200000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 1714435200000L),
    "null",
  ) // 腿 C N.year_2099.1714435200000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1714435200000L), "null") // 腿 C N.year_2099.1714435200000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 515554200000L), "null") // 腿 C N.year_2099.515554200000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 515554200000L),
    "null",
  ) // 腿 C N.year_2099.515554200000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 515554200000L),
    "null",
  ) // 腿 C N.year_2099.515554200000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 515554200000L),
    "null",
  ) // 腿 C N.year_2099.515554200000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 515554200000L),
    "null",
  ) // 腿 C N.year_2099.515554200000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 515554200000L),
    "null",
  ) // 腿 C N.year_2099.515554200000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 515554200000L), "null") // 腿 C N.year_2099.515554200000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 4070822400000L), "null") // 腿 C N.year_2099.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 4070822400000L),
    "null",
  ) // 腿 C N.year_2099.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 4070822400000L),
    "null",
  ) // 腿 C N.year_2099.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 4070822400000L),
    "null",
  ) // 腿 C N.year_2099.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N.year_2099.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 4070822400000L),
    "null",
  ) // 腿 C N.year_2099.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.year_2099.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 1730606400000L), "null") // 腿 C N.year_2099.1730606400000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1730606400000L),
    "null",
  ) // 腿 C N.year_2099.1730606400000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 1730606400000L),
    "null",
  ) // 腿 C N.year_2099.1730606400000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1730606400000L),
    "null",
  ) // 腿 C N.year_2099.1730606400000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1730606400000L),
    "null",
  ) // 腿 C N.year_2099.1730606400000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 1730606400000L),
    "null",
  ) // 腿 C N.year_2099.1730606400000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1730606400000L), "null") // 腿 C N.year_2099.1730606400000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 1709985600000L), "null") // 腿 C N.year_2099.1709985600000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1709985600000L),
    "null",
  ) // 腿 C N.year_2099.1709985600000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 1709985600000L),
    "null",
  ) // 腿 C N.year_2099.1709985600000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1709985600000L),
    "null",
  ) // 腿 C N.year_2099.1709985600000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1709985600000L),
    "null",
  ) // 腿 C N.year_2099.1709985600000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 1709985600000L),
    "null",
  ) // 腿 C N.year_2099.1709985600000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1709985600000L), "null") // 腿 C N.year_2099.1709985600000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 1730548800000L), "null") // 腿 C N.year_2099.1730548800000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1730548800000L),
    "null",
  ) // 腿 C N.year_2099.1730548800000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 1730548800000L),
    "null",
  ) // 腿 C N.year_2099.1730548800000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1730548800000L),
    "null",
  ) // 腿 C N.year_2099.1730548800000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1730548800000L),
    "null",
  ) // 腿 C N.year_2099.1730548800000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 1730548800000L),
    "null",
  ) // 腿 C N.year_2099.1730548800000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1730548800000L), "null") // 腿 C N.year_2099.1730548800000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 515505600000L), "null") // 腿 C N.year_2099.515505600000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 515505600000L),
    "null",
  ) // 腿 C N.year_2099.515505600000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 515505600000L),
    "null",
  ) // 腿 C N.year_2099.515505600000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 515505600000L),
    "null",
  ) // 腿 C N.year_2099.515505600000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 515505600000L),
    "null",
  ) // 腿 C N.year_2099.515505600000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 515505600000L),
    "null",
  ) // 腿 C N.year_2099.515505600000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 515505600000L), "null") // 腿 C N.year_2099.515505600000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 1725710400000L), "null") // 腿 C N.year_2099.1725710400000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1725710400000L),
    "null",
  ) // 腿 C N.year_2099.1725710400000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znx_tag 行，严格晚于，第 7 块 19 条）" {
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 1725710400000L),
    "null",
  ) // 腿 C N.year_2099.1725710400000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1725710400000L),
    "null",
  ) // 腿 C N.year_2099.1725710400000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1725710400000L),
    "null",
  ) // 腿 C N.year_2099.1725710400000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 1725710400000L),
    "null",
  ) // 腿 C N.year_2099.1725710400000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1725710400000L), "null") // 腿 C N.year_2099.1725710400000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "UTC", 1647864000000L), "null") // 腿 C N.year_2099.1647864000000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1647864000000L),
    "null",
  ) // 腿 C N.year_2099.1647864000000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/New_York", 1647864000000L),
    "null",
  ) // 腿 C N.year_2099.1647864000000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1647864000000L),
    "null",
  ) // 腿 C N.year_2099.1647864000000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1647864000000L),
    "null",
  ) // 腿 C N.year_2099.1647864000000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 12 * * ? 2099", "America/Santiago", 1647864000000L),
    "null",
  ) // 腿 C N.year_2099.1647864000000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1647864000000L), "null") // 腿 C N.year_2099.1647864000000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 30 2 *", "UTC", 4070822400000L), "null") // 腿 C N.feb30.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 30 2 *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N.feb30.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 30 2 *", "America/New_York", 4070822400000L), "null") // 腿 C N.feb30.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 30 2 *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N.feb30.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
  assert_eq(
    znx_tag("0 0 0 30 2 *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N.feb30.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 30 2 *", "America/Santiago", 4070822400000L), "null") // 腿 C N.feb30.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
  assert_eq(znx_tag("0 0 0 30 2 *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N.feb30.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znm_tag 行，已匹配给自身/末支，第 1 块 180 条）" {
  assert_eq(znm_tag("* * * * *", "UTC", 1710050400000L), "1710050400000") // 腿 C N2.star.1710050400000.UTC|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Shanghai", 1710050400000L),
    "1710050400000",
  ) // 腿 C N2.star.1710050400000.Asia/Shanghai|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/New_York", 1710050400000L),
    "1710050400000",
  ) // 腿 C N2.star.1710050400000.America/New_York|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Kathmandu", 1710050400000L),
    "1710050400000",
  ) // 腿 C N2.star.1710050400000.Asia/Kathmandu|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(
    znm_tag("* * * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710050400000",
  ) // 腿 C N2.star.1710050400000.Australia/Lord_Howe|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/Santiago", 1710050400000L),
    "1710050400000",
  ) // 腿 C N2.star.1710050400000.America/Santiago|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Tehran", 1710050400000L),
    "1710050400000",
  ) // 腿 C N2.star.1710050400000.Asia/Tehran|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(znm_tag("* * * * *", "UTC", 1730611800000L), "1730611800000") // 腿 C N2.star.1730611800000.UTC|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Shanghai", 1730611800000L),
    "1730611800000",
  ) // 腿 C N2.star.1730611800000.Asia/Shanghai|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("* * * * *", "America/New_York", 1730611800000L),
    "1730615400000",
  ) // 腿 C N2.star.1730611800000.America/New_York|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Kathmandu", 1730611800000L),
    "1730611800000",
  ) // 腿 C N2.star.1730611800000.Asia/Kathmandu|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("* * * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730611800000",
  ) // 腿 C N2.star.1730611800000.Australia/Lord_Howe|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("* * * * *", "America/Santiago", 1730611800000L),
    "1730611800000",
  ) // 腿 C N2.star.1730611800000.America/Santiago|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Tehran", 1730611800000L),
    "1730611800000",
  ) // 腿 C N2.star.1730611800000.Asia/Tehran|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(znm_tag("* * * * *", "UTC", 1730615400000L), "1730615400000") // 腿 C N2.star.1730615400000.UTC|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Shanghai", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.star.1730615400000.Asia/Shanghai|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("* * * * *", "America/New_York", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.star.1730615400000.America/New_York|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Kathmandu", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.star.1730615400000.Asia/Kathmandu|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("* * * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.star.1730615400000.Australia/Lord_Howe|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("* * * * *", "America/Santiago", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.star.1730615400000.America/Santiago|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Tehran", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.star.1730615400000.Asia/Tehran|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(znm_tag("* * * * *", "UTC", 1709208000000L), "1709208000000") // 腿 C N2.star.1709208000000.UTC|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Shanghai", 1709208000000L),
    "1709208000000",
  ) // 腿 C N2.star.1709208000000.Asia/Shanghai|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/New_York", 1709208000000L),
    "1709208000000",
  ) // 腿 C N2.star.1709208000000.America/New_York|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Kathmandu", 1709208000000L),
    "1709208000000",
  ) // 腿 C N2.star.1709208000000.Asia/Kathmandu|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709208000000",
  ) // 腿 C N2.star.1709208000000.Australia/Lord_Howe|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/Santiago", 1709208000000L),
    "1709208000000",
  ) // 腿 C N2.star.1709208000000.America/Santiago|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Tehran", 1709208000000L),
    "1709208000000",
  ) // 腿 C N2.star.1709208000000.Asia/Tehran|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(znm_tag("* * * * *", "UTC", 1714435200000L), "1714435200000") // 腿 C N2.star.1714435200000.UTC|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Shanghai", 1714435200000L),
    "1714435200000",
  ) // 腿 C N2.star.1714435200000.Asia/Shanghai|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/New_York", 1714435200000L),
    "1714435200000",
  ) // 腿 C N2.star.1714435200000.America/New_York|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Kathmandu", 1714435200000L),
    "1714435200000",
  ) // 腿 C N2.star.1714435200000.Asia/Kathmandu|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("* * * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714435200000",
  ) // 腿 C N2.star.1714435200000.Australia/Lord_Howe|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/Santiago", 1714435200000L),
    "1714435200000",
  ) // 腿 C N2.star.1714435200000.America/Santiago|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Tehran", 1714435200000L),
    "1714435200000",
  ) // 腿 C N2.star.1714435200000.Asia/Tehran|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(znm_tag("* * * * *", "UTC", 515554200000L), "515554200000") // 腿 C N2.star.515554200000.UTC|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Shanghai", 515554200000L),
    "515554200000",
  ) // 腿 C N2.star.515554200000.Asia/Shanghai|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("* * * * *", "America/New_York", 515554200000L),
    "515554200000",
  ) // 腿 C N2.star.515554200000.America/New_York|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Kathmandu", 515554200000L),
    "515554200000",
  ) // 腿 C N2.star.515554200000.Asia/Kathmandu|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("* * * * *", "Australia/Lord_Howe", 515554200000L),
    "515554200000",
  ) // 腿 C N2.star.515554200000.Australia/Lord_Howe|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("* * * * *", "America/Santiago", 515554200000L),
    "515554200000",
  ) // 腿 C N2.star.515554200000.America/Santiago|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(znm_tag("* * * * *", "Asia/Tehran", 515554200000L), "515554200000") // 腿 C N2.star.515554200000.Asia/Tehran|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(znm_tag("* * * * *", "UTC", 4070822400000L), "null") // 腿 C N2.star.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("* * * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N2.star.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("* * * * *", "America/New_York", 4070822400000L), "null") // 腿 C N2.star.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("* * * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N2.star.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("* * * * *", "Australia/Lord_Howe", 4070822400000L), "null") // 腿 C N2.star.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("* * * * *", "America/Santiago", 4070822400000L), "null") // 腿 C N2.star.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("* * * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.star.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("* * * * *", "UTC", 1730606400000L), "1730606400000") // 腿 C N2.star.1730606400000.UTC|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Shanghai", 1730606400000L),
    "1730606400000",
  ) // 腿 C N2.star.1730606400000.Asia/Shanghai|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/New_York", 1730606400000L),
    "1730606400000",
  ) // 腿 C N2.star.1730606400000.America/New_York|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Kathmandu", 1730606400000L),
    "1730606400000",
  ) // 腿 C N2.star.1730606400000.Asia/Kathmandu|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(
    znm_tag("* * * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730606400000",
  ) // 腿 C N2.star.1730606400000.Australia/Lord_Howe|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/Santiago", 1730606400000L),
    "1730606400000",
  ) // 腿 C N2.star.1730606400000.America/Santiago|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Tehran", 1730606400000L),
    "1730606400000",
  ) // 腿 C N2.star.1730606400000.Asia/Tehran|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(znm_tag("* * * * *", "UTC", 1709985600000L), "1709985600000") // 腿 C N2.star.1709985600000.UTC|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Shanghai", 1709985600000L),
    "1709985600000",
  ) // 腿 C N2.star.1709985600000.Asia/Shanghai|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/New_York", 1709985600000L),
    "1709985600000",
  ) // 腿 C N2.star.1709985600000.America/New_York|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Kathmandu", 1709985600000L),
    "1709985600000",
  ) // 腿 C N2.star.1709985600000.Asia/Kathmandu|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709985600000",
  ) // 腿 C N2.star.1709985600000.Australia/Lord_Howe|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/Santiago", 1709985600000L),
    "1709985600000",
  ) // 腿 C N2.star.1709985600000.America/Santiago|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Tehran", 1709985600000L),
    "1709985600000",
  ) // 腿 C N2.star.1709985600000.Asia/Tehran|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(znm_tag("* * * * *", "UTC", 1730548800000L), "1730548800000") // 腿 C N2.star.1730548800000.UTC|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Shanghai", 1730548800000L),
    "1730548800000",
  ) // 腿 C N2.star.1730548800000.Asia/Shanghai|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/New_York", 1730548800000L),
    "1730548800000",
  ) // 腿 C N2.star.1730548800000.America/New_York|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Kathmandu", 1730548800000L),
    "1730548800000",
  ) // 腿 C N2.star.1730548800000.Asia/Kathmandu|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730548800000",
  ) // 腿 C N2.star.1730548800000.Australia/Lord_Howe|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/Santiago", 1730548800000L),
    "1730548800000",
  ) // 腿 C N2.star.1730548800000.America/Santiago|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Tehran", 1730548800000L),
    "1730548800000",
  ) // 腿 C N2.star.1730548800000.Asia/Tehran|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(znm_tag("* * * * *", "UTC", 515505600000L), "515505600000") // 腿 C N2.star.515505600000.UTC|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Shanghai", 515505600000L),
    "515505600000",
  ) // 腿 C N2.star.515505600000.Asia/Shanghai|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/New_York", 515505600000L),
    "515505600000",
  ) // 腿 C N2.star.515505600000.America/New_York|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Kathmandu", 515505600000L),
    "515505600000",
  ) // 腿 C N2.star.515505600000.Asia/Kathmandu|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Australia/Lord_Howe", 515505600000L),
    "515505600000",
  ) // 腿 C N2.star.515505600000.Australia/Lord_Howe|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/Santiago", 515505600000L),
    "515505600000",
  ) // 腿 C N2.star.515505600000.America/Santiago|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(znm_tag("* * * * *", "Asia/Tehran", 515505600000L), "515505600000") // 腿 C N2.star.515505600000.Asia/Tehran|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(znm_tag("* * * * *", "UTC", 1725710400000L), "1725710400000") // 腿 C N2.star.1725710400000.UTC|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Shanghai", 1725710400000L),
    "1725710400000",
  ) // 腿 C N2.star.1725710400000.Asia/Shanghai|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/New_York", 1725710400000L),
    "1725710400000",
  ) // 腿 C N2.star.1725710400000.America/New_York|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Kathmandu", 1725710400000L),
    "1725710400000",
  ) // 腿 C N2.star.1725710400000.Asia/Kathmandu|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725710400000",
  ) // 腿 C N2.star.1725710400000.Australia/Lord_Howe|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/Santiago", 1725710400000L),
    "1725710400000",
  ) // 腿 C N2.star.1725710400000.America/Santiago|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Tehran", 1725710400000L),
    "1725710400000",
  ) // 腿 C N2.star.1725710400000.Asia/Tehran|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(znm_tag("* * * * *", "UTC", 1647864000000L), "1647864000000") // 腿 C N2.star.1647864000000.UTC|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Shanghai", 1647864000000L),
    "1647864000000",
  ) // 腿 C N2.star.1647864000000.Asia/Shanghai|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/New_York", 1647864000000L),
    "1647864000000",
  ) // 腿 C N2.star.1647864000000.America/New_York|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Kathmandu", 1647864000000L),
    "1647864000000",
  ) // 腿 C N2.star.1647864000000.Asia/Kathmandu|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647864000000",
  ) // 腿 C N2.star.1647864000000.Australia/Lord_Howe|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "America/Santiago", 1647864000000L),
    "1647864000000",
  ) // 腿 C N2.star.1647864000000.America/Santiago|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(
    znm_tag("* * * * *", "Asia/Tehran", 1647864000000L),
    "1647864000000",
  ) // 腿 C N2.star.1647864000000.Asia/Tehran|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 1710050400000L), "1710120600000") // 腿 C N2.daily_0130.1710050400000.UTC|参照读数 1710120600000（UTC 串 2024-03-11 01:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Shanghai", 1710050400000L),
    "1710091800000",
  ) // 腿 C N2.daily_0130.1710050400000.Asia/Shanghai|参照读数 1710091800000（UTC 串 2024-03-10 17:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/New_York", 1710050400000L),
    "1710052200000",
  ) // 腿 C N2.daily_0130.1710050400000.America/New_York|参照读数 1710052200000（UTC 串 2024-03-10 06:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Kathmandu", 1710050400000L),
    "1710099900000",
  ) // 腿 C N2.daily_0130.1710050400000.Asia/Kathmandu|参照读数 1710099900000（UTC 串 2024-03-10 19:45:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710081000000",
  ) // 腿 C N2.daily_0130.1710050400000.Australia/Lord_Howe|参照读数 1710081000000（UTC 串 2024-03-10 14:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/Santiago", 1710050400000L),
    "1710131400000",
  ) // 腿 C N2.daily_0130.1710050400000.America/Santiago|参照读数 1710131400000（UTC 串 2024-03-11 04:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Tehran", 1710050400000L),
    "1710108000000",
  ) // 腿 C N2.daily_0130.1710050400000.Asia/Tehran|参照读数 1710108000000（UTC 串 2024-03-10 22:00:00）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 1730611800000L), "1730683800000") // 腿 C N2.daily_0130.1730611800000.UTC|参照读数 1730683800000（UTC 串 2024-11-04 01:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Shanghai", 1730611800000L),
    "1730655000000",
  ) // 腿 C N2.daily_0130.1730611800000.Asia/Shanghai|参照读数 1730655000000（UTC 串 2024-11-03 17:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/New_York", 1730611800000L),
    "1730615400000",
  ) // 腿 C N2.daily_0130.1730611800000.America/New_York|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Kathmandu", 1730611800000L),
    "1730663100000",
  ) // 腿 C N2.daily_0130.1730611800000.Asia/Kathmandu|参照读数 1730663100000（UTC 串 2024-11-03 19:45:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730644200000",
  ) // 腿 C N2.daily_0130.1730611800000.Australia/Lord_Howe|参照读数 1730644200000（UTC 串 2024-11-03 14:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/Santiago", 1730611800000L),
    "1730694600000",
  ) // 腿 C N2.daily_0130.1730611800000.America/Santiago|参照读数 1730694600000（UTC 串 2024-11-04 04:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Tehran", 1730611800000L),
    "1730671200000",
  ) // 腿 C N2.daily_0130.1730611800000.Asia/Tehran|参照读数 1730671200000（UTC 串 2024-11-03 22:00:00）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 1730615400000L), "1730683800000") // 腿 C N2.daily_0130.1730615400000.UTC|参照读数 1730683800000（UTC 串 2024-11-04 01:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Shanghai", 1730615400000L),
    "1730655000000",
  ) // 腿 C N2.daily_0130.1730615400000.Asia/Shanghai|参照读数 1730655000000（UTC 串 2024-11-03 17:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/New_York", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.daily_0130.1730615400000.America/New_York|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Kathmandu", 1730615400000L),
    "1730663100000",
  ) // 腿 C N2.daily_0130.1730615400000.Asia/Kathmandu|参照读数 1730663100000（UTC 串 2024-11-03 19:45:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730644200000",
  ) // 腿 C N2.daily_0130.1730615400000.Australia/Lord_Howe|参照读数 1730644200000（UTC 串 2024-11-03 14:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/Santiago", 1730615400000L),
    "1730694600000",
  ) // 腿 C N2.daily_0130.1730615400000.America/Santiago|参照读数 1730694600000（UTC 串 2024-11-04 04:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Tehran", 1730615400000L),
    "1730671200000",
  ) // 腿 C N2.daily_0130.1730615400000.Asia/Tehran|参照读数 1730671200000（UTC 串 2024-11-03 22:00:00）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 1709208000000L), "1709256600000") // 腿 C N2.daily_0130.1709208000000.UTC|参照读数 1709256600000（UTC 串 2024-03-01 01:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Shanghai", 1709208000000L),
    "1709227800000",
  ) // 腿 C N2.daily_0130.1709208000000.Asia/Shanghai|参照读数 1709227800000（UTC 串 2024-02-29 17:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/New_York", 1709208000000L),
    "1709274600000",
  ) // 腿 C N2.daily_0130.1709208000000.America/New_York|参照读数 1709274600000（UTC 串 2024-03-01 06:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Kathmandu", 1709208000000L),
    "1709235900000",
  ) // 腿 C N2.daily_0130.1709208000000.Asia/Kathmandu|参照读数 1709235900000（UTC 串 2024-02-29 19:45:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709217000000",
  ) // 腿 C N2.daily_0130.1709208000000.Australia/Lord_Howe|参照读数 1709217000000（UTC 串 2024-02-29 14:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/Santiago", 1709208000000L),
    "1709267400000",
  ) // 腿 C N2.daily_0130.1709208000000.America/Santiago|参照读数 1709267400000（UTC 串 2024-03-01 04:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Tehran", 1709208000000L),
    "1709244000000",
  ) // 腿 C N2.daily_0130.1709208000000.Asia/Tehran|参照读数 1709244000000（UTC 串 2024-02-29 22:00:00）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 1714435200000L), "1714440600000") // 腿 C N2.daily_0130.1714435200000.UTC|参照读数 1714440600000（UTC 串 2024-04-30 01:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Shanghai", 1714435200000L),
    "1714498200000",
  ) // 腿 C N2.daily_0130.1714435200000.Asia/Shanghai|参照读数 1714498200000（UTC 串 2024-04-30 17:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/New_York", 1714435200000L),
    "1714455000000",
  ) // 腿 C N2.daily_0130.1714435200000.America/New_York|参照读数 1714455000000（UTC 串 2024-04-30 05:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Kathmandu", 1714435200000L),
    "1714506300000",
  ) // 腿 C N2.daily_0130.1714435200000.Asia/Kathmandu|参照读数 1714506300000（UTC 串 2024-04-30 19:45:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714489200000",
  ) // 腿 C N2.daily_0130.1714435200000.Australia/Lord_Howe|参照读数 1714489200000（UTC 串 2024-04-30 15:00:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/Santiago", 1714435200000L),
    "1714455000000",
  ) // 腿 C N2.daily_0130.1714435200000.America/Santiago|参照读数 1714455000000（UTC 串 2024-04-30 05:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Tehran", 1714435200000L),
    "1714514400000",
  ) // 腿 C N2.daily_0130.1714435200000.Asia/Tehran|参照读数 1714514400000（UTC 串 2024-04-30 22:00:00）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 515554200000L), "515554200000") // 腿 C N2.daily_0130.515554200000.UTC|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Shanghai", 515554200000L),
    "515608200000",
  ) // 腿 C N2.daily_0130.515554200000.Asia/Shanghai|参照读数 515608200000（UTC 串 1986-05-04 16:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/New_York", 515554200000L),
    "515568600000",
  ) // 腿 C N2.daily_0130.515554200000.America/New_York|参照读数 515568600000（UTC 串 1986-05-04 05:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Kathmandu", 515554200000L),
    "515619900000",
  ) // 腿 C N2.daily_0130.515554200000.Asia/Kathmandu|参照读数 515619900000（UTC 串 1986-05-04 19:45:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 515554200000L),
    "515602800000",
  ) // 腿 C N2.daily_0130.515554200000.Australia/Lord_Howe|参照读数 515602800000（UTC 串 1986-05-04 15:00:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/Santiago", 515554200000L),
    "515568600000",
  ) // 腿 C N2.daily_0130.515554200000.America/Santiago|参照读数 515568600000（UTC 串 1986-05-04 05:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Tehran", 515554200000L),
    "515628000000",
  ) // 腿 C N2.daily_0130.515554200000.Asia/Tehran|参照读数 515628000000（UTC 串 1986-05-04 22:00:00）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 4070822400000L), "null") // 腿 C N2.daily_0130.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070827800000｜UTC 2098-12-31 01:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 1 * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N2.daily_0130.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070885400000｜UTC 2098-12-31 17:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 1 * * *", "America/New_York", 4070822400000L), "null") // 腿 C N2.daily_0130.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070845800000｜UTC 2098-12-31 06:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 1 * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N2.daily_0130.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070893500000｜UTC 2098-12-31 19:45:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N2.daily_0130.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070874600000｜UTC 2098-12-31 14:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 1 * * *", "America/Santiago", 4070822400000L), "null") // 腿 C N2.daily_0130.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070838600000｜UTC 2098-12-31 04:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 1 * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.daily_0130.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070901600000｜UTC 2098-12-31 22:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 1730606400000L), "1730683800000") // 腿 C N2.daily_0130.1730606400000.UTC|参照读数 1730683800000（UTC 串 2024-11-04 01:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Shanghai", 1730606400000L),
    "1730655000000",
  ) // 腿 C N2.daily_0130.1730606400000.Asia/Shanghai|参照读数 1730655000000（UTC 串 2024-11-03 17:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/New_York", 1730606400000L),
    "1730615400000",
  ) // 腿 C N2.daily_0130.1730606400000.America/New_York|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Kathmandu", 1730606400000L),
    "1730663100000",
  ) // 腿 C N2.daily_0130.1730606400000.Asia/Kathmandu|参照读数 1730663100000（UTC 串 2024-11-03 19:45:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730644200000",
  ) // 腿 C N2.daily_0130.1730606400000.Australia/Lord_Howe|参照读数 1730644200000（UTC 串 2024-11-03 14:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/Santiago", 1730606400000L),
    "1730608200000",
  ) // 腿 C N2.daily_0130.1730606400000.America/Santiago|参照读数 1730608200000（UTC 串 2024-11-03 04:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Tehran", 1730606400000L),
    "1730671200000",
  ) // 腿 C N2.daily_0130.1730606400000.Asia/Tehran|参照读数 1730671200000（UTC 串 2024-11-03 22:00:00）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 1709985600000L), "1710034200000") // 腿 C N2.daily_0130.1709985600000.UTC|参照读数 1710034200000（UTC 串 2024-03-10 01:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Shanghai", 1709985600000L),
    "1710005400000",
  ) // 腿 C N2.daily_0130.1709985600000.Asia/Shanghai|参照读数 1710005400000（UTC 串 2024-03-09 17:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/New_York", 1709985600000L),
    "1710052200000",
  ) // 腿 C N2.daily_0130.1709985600000.America/New_York|参照读数 1710052200000（UTC 串 2024-03-10 06:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Kathmandu", 1709985600000L),
    "1710013500000",
  ) // 腿 C N2.daily_0130.1709985600000.Asia/Kathmandu|参照读数 1710013500000（UTC 串 2024-03-09 19:45:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709994600000",
  ) // 腿 C N2.daily_0130.1709985600000.Australia/Lord_Howe|参照读数 1709994600000（UTC 串 2024-03-09 14:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/Santiago", 1709985600000L),
    "1710045000000",
  ) // 腿 C N2.daily_0130.1709985600000.America/Santiago|参照读数 1710045000000（UTC 串 2024-03-10 04:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Tehran", 1709985600000L),
    "1710021600000",
  ) // 腿 C N2.daily_0130.1709985600000.Asia/Tehran|参照读数 1710021600000（UTC 串 2024-03-09 22:00:00）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 1730548800000L), "1730597400000") // 腿 C N2.daily_0130.1730548800000.UTC|参照读数 1730597400000（UTC 串 2024-11-03 01:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Shanghai", 1730548800000L),
    "1730568600000",
  ) // 腿 C N2.daily_0130.1730548800000.Asia/Shanghai|参照读数 1730568600000（UTC 串 2024-11-02 17:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/New_York", 1730548800000L),
    "1730615400000",
  ) // 腿 C N2.daily_0130.1730548800000.America/New_York|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Kathmandu", 1730548800000L),
    "1730576700000",
  ) // 腿 C N2.daily_0130.1730548800000.Asia/Kathmandu|参照读数 1730576700000（UTC 串 2024-11-02 19:45:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730557800000",
  ) // 腿 C N2.daily_0130.1730548800000.Australia/Lord_Howe|参照读数 1730557800000（UTC 串 2024-11-02 14:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/Santiago", 1730548800000L),
    "1730608200000",
  ) // 腿 C N2.daily_0130.1730548800000.America/Santiago|参照读数 1730608200000（UTC 串 2024-11-03 04:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Tehran", 1730548800000L),
    "1730584800000",
  ) // 腿 C N2.daily_0130.1730548800000.Asia/Tehran|参照读数 1730584800000（UTC 串 2024-11-02 22:00:00）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 515505600000L), "515554200000") // 腿 C N2.daily_0130.515505600000.UTC|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Shanghai", 515505600000L),
    "515525400000",
  ) // 腿 C N2.daily_0130.515505600000.Asia/Shanghai|参照读数 515525400000（UTC 串 1986-05-03 17:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/New_York", 515505600000L),
    "515568600000",
  ) // 腿 C N2.daily_0130.515505600000.America/New_York|参照读数 515568600000（UTC 串 1986-05-04 05:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Kathmandu", 515505600000L),
    "515533500000",
  ) // 腿 C N2.daily_0130.515505600000.Asia/Kathmandu|参照读数 515533500000（UTC 串 1986-05-03 19:45:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 515505600000L),
    "515516400000",
  ) // 腿 C N2.daily_0130.515505600000.Australia/Lord_Howe|参照读数 515516400000（UTC 串 1986-05-03 15:00:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/Santiago", 515505600000L),
    "515568600000",
  ) // 腿 C N2.daily_0130.515505600000.America/Santiago|参照读数 515568600000（UTC 串 1986-05-04 05:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Tehran", 515505600000L),
    "515541600000",
  ) // 腿 C N2.daily_0130.515505600000.Asia/Tehran|参照读数 515541600000（UTC 串 1986-05-03 22:00:00）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 1725710400000L), "1725759000000") // 腿 C N2.daily_0130.1725710400000.UTC|参照读数 1725759000000（UTC 串 2024-09-08 01:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Shanghai", 1725710400000L),
    "1725730200000",
  ) // 腿 C N2.daily_0130.1725710400000.Asia/Shanghai|参照读数 1725730200000（UTC 串 2024-09-07 17:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/New_York", 1725710400000L),
    "1725773400000",
  ) // 腿 C N2.daily_0130.1725710400000.America/New_York|参照读数 1725773400000（UTC 串 2024-09-08 05:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Kathmandu", 1725710400000L),
    "1725738300000",
  ) // 腿 C N2.daily_0130.1725710400000.Asia/Kathmandu|参照读数 1725738300000（UTC 串 2024-09-07 19:45:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725721200000",
  ) // 腿 C N2.daily_0130.1725710400000.Australia/Lord_Howe|参照读数 1725721200000（UTC 串 2024-09-07 15:00:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/Santiago", 1725710400000L),
    "1725769800000",
  ) // 腿 C N2.daily_0130.1725710400000.America/Santiago|参照读数 1725769800000（UTC 串 2024-09-08 04:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Tehran", 1725710400000L),
    "1725746400000",
  ) // 腿 C N2.daily_0130.1725710400000.Asia/Tehran|参照读数 1725746400000（UTC 串 2024-09-07 22:00:00）
  assert_eq(znm_tag("0 30 1 * * *", "UTC", 1647864000000L), "1647912600000") // 腿 C N2.daily_0130.1647864000000.UTC|参照读数 1647912600000（UTC 串 2022-03-22 01:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Shanghai", 1647864000000L),
    "1647883800000",
  ) // 腿 C N2.daily_0130.1647864000000.Asia/Shanghai|参照读数 1647883800000（UTC 串 2022-03-21 17:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "America/New_York", 1647864000000L),
    "1647927000000",
  ) // 腿 C N2.daily_0130.1647864000000.America/New_York|参照读数 1647927000000（UTC 串 2022-03-22 05:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Kathmandu", 1647864000000L),
    "1647891900000",
  ) // 腿 C N2.daily_0130.1647864000000.Asia/Kathmandu|参照读数 1647891900000（UTC 串 2022-03-21 19:45:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647873000000",
  ) // 腿 C N2.daily_0130.1647864000000.Australia/Lord_Howe|参照读数 1647873000000（UTC 串 2022-03-21 14:30:00）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znm_tag 行，已匹配给自身/末支，第 2 块 180 条）" {
  assert_eq(
    znm_tag("0 30 1 * * *", "America/Santiago", 1647864000000L),
    "1647923400000",
  ) // 腿 C N2.daily_0130.1647864000000.America/Santiago|参照读数 1647923400000（UTC 串 2022-03-22 04:30:00）
  assert_eq(
    znm_tag("0 30 1 * * *", "Asia/Tehran", 1647864000000L),
    "1647896400000",
  ) // 腿 C N2.daily_0130.1647864000000.Asia/Tehran|参照读数 1647896400000（UTC 串 2022-03-21 21:00:00）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 1710050400000L), "1710124200000") // 腿 C N2.daily_0230.1710050400000.UTC|参照读数 1710124200000（UTC 串 2024-03-11 02:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Shanghai", 1710050400000L),
    "1710095400000",
  ) // 腿 C N2.daily_0230.1710050400000.Asia/Shanghai|参照读数 1710095400000（UTC 串 2024-03-10 18:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/New_York", 1710050400000L),
    "1710138600000",
  ) // 腿 C N2.daily_0230.1710050400000.America/New_York|参照读数 1710138600000（UTC 串 2024-03-11 06:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Kathmandu", 1710050400000L),
    "1710103500000",
  ) // 腿 C N2.daily_0230.1710050400000.Asia/Kathmandu|参照读数 1710103500000（UTC 串 2024-03-10 20:45:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710084600000",
  ) // 腿 C N2.daily_0230.1710050400000.Australia/Lord_Howe|参照读数 1710084600000（UTC 串 2024-03-10 15:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/Santiago", 1710050400000L),
    "1710135000000",
  ) // 腿 C N2.daily_0230.1710050400000.America/Santiago|参照读数 1710135000000（UTC 串 2024-03-11 05:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Tehran", 1710050400000L),
    "1710111600000",
  ) // 腿 C N2.daily_0230.1710050400000.Asia/Tehran|参照读数 1710111600000（UTC 串 2024-03-10 23:00:00）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 1730611800000L), "1730687400000") // 腿 C N2.daily_0230.1730611800000.UTC|参照读数 1730687400000（UTC 串 2024-11-04 02:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Shanghai", 1730611800000L),
    "1730658600000",
  ) // 腿 C N2.daily_0230.1730611800000.Asia/Shanghai|参照读数 1730658600000（UTC 串 2024-11-03 18:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/New_York", 1730611800000L),
    "1730619000000",
  ) // 腿 C N2.daily_0230.1730611800000.America/New_York|参照读数 1730619000000（UTC 串 2024-11-03 07:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Kathmandu", 1730611800000L),
    "1730666700000",
  ) // 腿 C N2.daily_0230.1730611800000.Asia/Kathmandu|参照读数 1730666700000（UTC 串 2024-11-03 20:45:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730647800000",
  ) // 腿 C N2.daily_0230.1730611800000.Australia/Lord_Howe|参照读数 1730647800000（UTC 串 2024-11-03 15:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/Santiago", 1730611800000L),
    "1730611800000",
  ) // 腿 C N2.daily_0230.1730611800000.America/Santiago|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Tehran", 1730611800000L),
    "1730674800000",
  ) // 腿 C N2.daily_0230.1730611800000.Asia/Tehran|参照读数 1730674800000（UTC 串 2024-11-03 23:00:00）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 1730615400000L), "1730687400000") // 腿 C N2.daily_0230.1730615400000.UTC|参照读数 1730687400000（UTC 串 2024-11-04 02:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Shanghai", 1730615400000L),
    "1730658600000",
  ) // 腿 C N2.daily_0230.1730615400000.Asia/Shanghai|参照读数 1730658600000（UTC 串 2024-11-03 18:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/New_York", 1730615400000L),
    "1730619000000",
  ) // 腿 C N2.daily_0230.1730615400000.America/New_York|参照读数 1730619000000（UTC 串 2024-11-03 07:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Kathmandu", 1730615400000L),
    "1730666700000",
  ) // 腿 C N2.daily_0230.1730615400000.Asia/Kathmandu|参照读数 1730666700000（UTC 串 2024-11-03 20:45:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730647800000",
  ) // 腿 C N2.daily_0230.1730615400000.Australia/Lord_Howe|参照读数 1730647800000（UTC 串 2024-11-03 15:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/Santiago", 1730615400000L),
    "1730698200000",
  ) // 腿 C N2.daily_0230.1730615400000.America/Santiago|参照读数 1730698200000（UTC 串 2024-11-04 05:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Tehran", 1730615400000L),
    "1730674800000",
  ) // 腿 C N2.daily_0230.1730615400000.Asia/Tehran|参照读数 1730674800000（UTC 串 2024-11-03 23:00:00）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 1709208000000L), "1709260200000") // 腿 C N2.daily_0230.1709208000000.UTC|参照读数 1709260200000（UTC 串 2024-03-01 02:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Shanghai", 1709208000000L),
    "1709231400000",
  ) // 腿 C N2.daily_0230.1709208000000.Asia/Shanghai|参照读数 1709231400000（UTC 串 2024-02-29 18:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/New_York", 1709208000000L),
    "1709278200000",
  ) // 腿 C N2.daily_0230.1709208000000.America/New_York|参照读数 1709278200000（UTC 串 2024-03-01 07:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Kathmandu", 1709208000000L),
    "1709239500000",
  ) // 腿 C N2.daily_0230.1709208000000.Asia/Kathmandu|参照读数 1709239500000（UTC 串 2024-02-29 20:45:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709220600000",
  ) // 腿 C N2.daily_0230.1709208000000.Australia/Lord_Howe|参照读数 1709220600000（UTC 串 2024-02-29 15:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/Santiago", 1709208000000L),
    "1709271000000",
  ) // 腿 C N2.daily_0230.1709208000000.America/Santiago|参照读数 1709271000000（UTC 串 2024-03-01 05:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Tehran", 1709208000000L),
    "1709247600000",
  ) // 腿 C N2.daily_0230.1709208000000.Asia/Tehran|参照读数 1709247600000（UTC 串 2024-02-29 23:00:00）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 1714435200000L), "1714444200000") // 腿 C N2.daily_0230.1714435200000.UTC|参照读数 1714444200000（UTC 串 2024-04-30 02:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Shanghai", 1714435200000L),
    "1714501800000",
  ) // 腿 C N2.daily_0230.1714435200000.Asia/Shanghai|参照读数 1714501800000（UTC 串 2024-04-30 18:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/New_York", 1714435200000L),
    "1714458600000",
  ) // 腿 C N2.daily_0230.1714435200000.America/New_York|参照读数 1714458600000（UTC 串 2024-04-30 06:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Kathmandu", 1714435200000L),
    "1714509900000",
  ) // 腿 C N2.daily_0230.1714435200000.Asia/Kathmandu|参照读数 1714509900000（UTC 串 2024-04-30 20:45:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714492800000",
  ) // 腿 C N2.daily_0230.1714435200000.Australia/Lord_Howe|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/Santiago", 1714435200000L),
    "1714458600000",
  ) // 腿 C N2.daily_0230.1714435200000.America/Santiago|参照读数 1714458600000（UTC 串 2024-04-30 06:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Tehran", 1714435200000L),
    "1714518000000",
  ) // 腿 C N2.daily_0230.1714435200000.Asia/Tehran|参照读数 1714518000000（UTC 串 2024-04-30 23:00:00）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 515554200000L), "515557800000") // 腿 C N2.daily_0230.515554200000.UTC|参照读数 515557800000（UTC 串 1986-05-04 02:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Shanghai", 515554200000L),
    "515611800000",
  ) // 腿 C N2.daily_0230.515554200000.Asia/Shanghai|参照读数 515611800000（UTC 串 1986-05-04 17:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/New_York", 515554200000L),
    "515572200000",
  ) // 腿 C N2.daily_0230.515554200000.America/New_York|参照读数 515572200000（UTC 串 1986-05-04 06:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Kathmandu", 515554200000L),
    "515623500000",
  ) // 腿 C N2.daily_0230.515554200000.Asia/Kathmandu|参照读数 515623500000（UTC 串 1986-05-04 20:45:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 515554200000L),
    "515606400000",
  ) // 腿 C N2.daily_0230.515554200000.Australia/Lord_Howe|参照读数 515606400000（UTC 串 1986-05-04 16:00:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/Santiago", 515554200000L),
    "515572200000",
  ) // 腿 C N2.daily_0230.515554200000.America/Santiago|参照读数 515572200000（UTC 串 1986-05-04 06:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Tehran", 515554200000L),
    "515631600000",
  ) // 腿 C N2.daily_0230.515554200000.Asia/Tehran|参照读数 515631600000（UTC 串 1986-05-04 23:00:00）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 4070822400000L), "null") // 腿 C N2.daily_0230.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070831400000｜UTC 2098-12-31 02:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 2 * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N2.daily_0230.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070889000000｜UTC 2098-12-31 18:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 2 * * *", "America/New_York", 4070822400000L), "null") // 腿 C N2.daily_0230.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070849400000｜UTC 2098-12-31 07:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 2 * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N2.daily_0230.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070897100000｜UTC 2098-12-31 20:45:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N2.daily_0230.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070878200000｜UTC 2098-12-31 15:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 2 * * *", "America/Santiago", 4070822400000L), "null") // 腿 C N2.daily_0230.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070842200000｜UTC 2098-12-31 05:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 2 * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.daily_0230.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070905200000｜UTC 2098-12-31 23:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 1730606400000L), "1730687400000") // 腿 C N2.daily_0230.1730606400000.UTC|参照读数 1730687400000（UTC 串 2024-11-04 02:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Shanghai", 1730606400000L),
    "1730658600000",
  ) // 腿 C N2.daily_0230.1730606400000.Asia/Shanghai|参照读数 1730658600000（UTC 串 2024-11-03 18:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/New_York", 1730606400000L),
    "1730619000000",
  ) // 腿 C N2.daily_0230.1730606400000.America/New_York|参照读数 1730619000000（UTC 串 2024-11-03 07:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Kathmandu", 1730606400000L),
    "1730666700000",
  ) // 腿 C N2.daily_0230.1730606400000.Asia/Kathmandu|参照读数 1730666700000（UTC 串 2024-11-03 20:45:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730647800000",
  ) // 腿 C N2.daily_0230.1730606400000.Australia/Lord_Howe|参照读数 1730647800000（UTC 串 2024-11-03 15:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/Santiago", 1730606400000L),
    "1730611800000",
  ) // 腿 C N2.daily_0230.1730606400000.America/Santiago|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Tehran", 1730606400000L),
    "1730674800000",
  ) // 腿 C N2.daily_0230.1730606400000.Asia/Tehran|参照读数 1730674800000（UTC 串 2024-11-03 23:00:00）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 1709985600000L), "1710037800000") // 腿 C N2.daily_0230.1709985600000.UTC|参照读数 1710037800000（UTC 串 2024-03-10 02:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Shanghai", 1709985600000L),
    "1710009000000",
  ) // 腿 C N2.daily_0230.1709985600000.Asia/Shanghai|参照读数 1710009000000（UTC 串 2024-03-09 18:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/New_York", 1709985600000L),
    "1710138600000",
  ) // 腿 C N2.daily_0230.1709985600000.America/New_York|参照读数 1710138600000（UTC 串 2024-03-11 06:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Kathmandu", 1709985600000L),
    "1710017100000",
  ) // 腿 C N2.daily_0230.1709985600000.Asia/Kathmandu|参照读数 1710017100000（UTC 串 2024-03-09 20:45:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709998200000",
  ) // 腿 C N2.daily_0230.1709985600000.Australia/Lord_Howe|参照读数 1709998200000（UTC 串 2024-03-09 15:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/Santiago", 1709985600000L),
    "1710048600000",
  ) // 腿 C N2.daily_0230.1709985600000.America/Santiago|参照读数 1710048600000（UTC 串 2024-03-10 05:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Tehran", 1709985600000L),
    "1710025200000",
  ) // 腿 C N2.daily_0230.1709985600000.Asia/Tehran|参照读数 1710025200000（UTC 串 2024-03-09 23:00:00）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 1730548800000L), "1730601000000") // 腿 C N2.daily_0230.1730548800000.UTC|参照读数 1730601000000（UTC 串 2024-11-03 02:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Shanghai", 1730548800000L),
    "1730572200000",
  ) // 腿 C N2.daily_0230.1730548800000.Asia/Shanghai|参照读数 1730572200000（UTC 串 2024-11-02 18:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/New_York", 1730548800000L),
    "1730619000000",
  ) // 腿 C N2.daily_0230.1730548800000.America/New_York|参照读数 1730619000000（UTC 串 2024-11-03 07:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Kathmandu", 1730548800000L),
    "1730580300000",
  ) // 腿 C N2.daily_0230.1730548800000.Asia/Kathmandu|参照读数 1730580300000（UTC 串 2024-11-02 20:45:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730561400000",
  ) // 腿 C N2.daily_0230.1730548800000.Australia/Lord_Howe|参照读数 1730561400000（UTC 串 2024-11-02 15:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/Santiago", 1730548800000L),
    "1730611800000",
  ) // 腿 C N2.daily_0230.1730548800000.America/Santiago|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Tehran", 1730548800000L),
    "1730588400000",
  ) // 腿 C N2.daily_0230.1730548800000.Asia/Tehran|参照读数 1730588400000（UTC 串 2024-11-02 23:00:00）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 515505600000L), "515557800000") // 腿 C N2.daily_0230.515505600000.UTC|参照读数 515557800000（UTC 串 1986-05-04 02:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Shanghai", 515505600000L),
    "515611800000",
  ) // 腿 C N2.daily_0230.515505600000.Asia/Shanghai|参照读数 515611800000（UTC 串 1986-05-04 17:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/New_York", 515505600000L),
    "515572200000",
  ) // 腿 C N2.daily_0230.515505600000.America/New_York|参照读数 515572200000（UTC 串 1986-05-04 06:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Kathmandu", 515505600000L),
    "515537100000",
  ) // 腿 C N2.daily_0230.515505600000.Asia/Kathmandu|参照读数 515537100000（UTC 串 1986-05-03 20:45:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 515505600000L),
    "515520000000",
  ) // 腿 C N2.daily_0230.515505600000.Australia/Lord_Howe|参照读数 515520000000（UTC 串 1986-05-03 16:00:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/Santiago", 515505600000L),
    "515572200000",
  ) // 腿 C N2.daily_0230.515505600000.America/Santiago|参照读数 515572200000（UTC 串 1986-05-04 06:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Tehran", 515505600000L),
    "515545200000",
  ) // 腿 C N2.daily_0230.515505600000.Asia/Tehran|参照读数 515545200000（UTC 串 1986-05-03 23:00:00）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 1725710400000L), "1725762600000") // 腿 C N2.daily_0230.1725710400000.UTC|参照读数 1725762600000（UTC 串 2024-09-08 02:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Shanghai", 1725710400000L),
    "1725733800000",
  ) // 腿 C N2.daily_0230.1725710400000.Asia/Shanghai|参照读数 1725733800000（UTC 串 2024-09-07 18:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/New_York", 1725710400000L),
    "1725777000000",
  ) // 腿 C N2.daily_0230.1725710400000.America/New_York|参照读数 1725777000000（UTC 串 2024-09-08 06:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Kathmandu", 1725710400000L),
    "1725741900000",
  ) // 腿 C N2.daily_0230.1725710400000.Asia/Kathmandu|参照读数 1725741900000（UTC 串 2024-09-07 20:45:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725724800000",
  ) // 腿 C N2.daily_0230.1725710400000.Australia/Lord_Howe|参照读数 1725724800000（UTC 串 2024-09-07 16:00:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/Santiago", 1725710400000L),
    "1725773400000",
  ) // 腿 C N2.daily_0230.1725710400000.America/Santiago|参照读数 1725773400000（UTC 串 2024-09-08 05:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Tehran", 1725710400000L),
    "1725750000000",
  ) // 腿 C N2.daily_0230.1725710400000.Asia/Tehran|参照读数 1725750000000（UTC 串 2024-09-07 23:00:00）
  assert_eq(znm_tag("0 30 2 * * *", "UTC", 1647864000000L), "1647916200000") // 腿 C N2.daily_0230.1647864000000.UTC|参照读数 1647916200000（UTC 串 2022-03-22 02:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Shanghai", 1647864000000L),
    "1647887400000",
  ) // 腿 C N2.daily_0230.1647864000000.Asia/Shanghai|参照读数 1647887400000（UTC 串 2022-03-21 18:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/New_York", 1647864000000L),
    "1647930600000",
  ) // 腿 C N2.daily_0230.1647864000000.America/New_York|参照读数 1647930600000（UTC 串 2022-03-22 06:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Kathmandu", 1647864000000L),
    "1647895500000",
  ) // 腿 C N2.daily_0230.1647864000000.Asia/Kathmandu|参照读数 1647895500000（UTC 串 2022-03-21 20:45:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647876600000",
  ) // 腿 C N2.daily_0230.1647864000000.Australia/Lord_Howe|参照读数 1647876600000（UTC 串 2022-03-21 15:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "America/Santiago", 1647864000000L),
    "1647927000000",
  ) // 腿 C N2.daily_0230.1647864000000.America/Santiago|参照读数 1647927000000（UTC 串 2022-03-22 05:30:00）
  assert_eq(
    znm_tag("0 30 2 * * *", "Asia/Tehran", 1647864000000L),
    "1647900000000",
  ) // 腿 C N2.daily_0230.1647864000000.Asia/Tehran|参照读数 1647900000000（UTC 串 2022-03-21 22:00:00）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 1710050400000L), "1710117000000") // 腿 C N2.daily_0030.1710050400000.UTC|参照读数 1710117000000（UTC 串 2024-03-11 00:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Shanghai", 1710050400000L),
    "1710088200000",
  ) // 腿 C N2.daily_0030.1710050400000.Asia/Shanghai|参照读数 1710088200000（UTC 串 2024-03-10 16:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/New_York", 1710050400000L),
    "1710131400000",
  ) // 腿 C N2.daily_0030.1710050400000.America/New_York|参照读数 1710131400000（UTC 串 2024-03-11 04:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Kathmandu", 1710050400000L),
    "1710096300000",
  ) // 腿 C N2.daily_0030.1710050400000.Asia/Kathmandu|参照读数 1710096300000（UTC 串 2024-03-10 18:45:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710077400000",
  ) // 腿 C N2.daily_0030.1710050400000.Australia/Lord_Howe|参照读数 1710077400000（UTC 串 2024-03-10 13:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/Santiago", 1710050400000L),
    "1710127800000",
  ) // 腿 C N2.daily_0030.1710050400000.America/Santiago|参照读数 1710127800000（UTC 串 2024-03-11 03:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Tehran", 1710050400000L),
    "1710104400000",
  ) // 腿 C N2.daily_0030.1710050400000.Asia/Tehran|参照读数 1710104400000（UTC 串 2024-03-10 21:00:00）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 1730611800000L), "1730680200000") // 腿 C N2.daily_0030.1730611800000.UTC|参照读数 1730680200000（UTC 串 2024-11-04 00:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Shanghai", 1730611800000L),
    "1730651400000",
  ) // 腿 C N2.daily_0030.1730611800000.Asia/Shanghai|参照读数 1730651400000（UTC 串 2024-11-03 16:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/New_York", 1730611800000L),
    "1730698200000",
  ) // 腿 C N2.daily_0030.1730611800000.America/New_York|参照读数 1730698200000（UTC 串 2024-11-04 05:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Kathmandu", 1730611800000L),
    "1730659500000",
  ) // 腿 C N2.daily_0030.1730611800000.Asia/Kathmandu|参照读数 1730659500000（UTC 串 2024-11-03 18:45:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730640600000",
  ) // 腿 C N2.daily_0030.1730611800000.Australia/Lord_Howe|参照读数 1730640600000（UTC 串 2024-11-03 13:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/Santiago", 1730611800000L),
    "1730691000000",
  ) // 腿 C N2.daily_0030.1730611800000.America/Santiago|参照读数 1730691000000（UTC 串 2024-11-04 03:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Tehran", 1730611800000L),
    "1730667600000",
  ) // 腿 C N2.daily_0030.1730611800000.Asia/Tehran|参照读数 1730667600000（UTC 串 2024-11-03 21:00:00）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 1730615400000L), "1730680200000") // 腿 C N2.daily_0030.1730615400000.UTC|参照读数 1730680200000（UTC 串 2024-11-04 00:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Shanghai", 1730615400000L),
    "1730651400000",
  ) // 腿 C N2.daily_0030.1730615400000.Asia/Shanghai|参照读数 1730651400000（UTC 串 2024-11-03 16:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/New_York", 1730615400000L),
    "1730698200000",
  ) // 腿 C N2.daily_0030.1730615400000.America/New_York|参照读数 1730698200000（UTC 串 2024-11-04 05:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Kathmandu", 1730615400000L),
    "1730659500000",
  ) // 腿 C N2.daily_0030.1730615400000.Asia/Kathmandu|参照读数 1730659500000（UTC 串 2024-11-03 18:45:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730640600000",
  ) // 腿 C N2.daily_0030.1730615400000.Australia/Lord_Howe|参照读数 1730640600000（UTC 串 2024-11-03 13:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/Santiago", 1730615400000L),
    "1730691000000",
  ) // 腿 C N2.daily_0030.1730615400000.America/Santiago|参照读数 1730691000000（UTC 串 2024-11-04 03:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Tehran", 1730615400000L),
    "1730667600000",
  ) // 腿 C N2.daily_0030.1730615400000.Asia/Tehran|参照读数 1730667600000（UTC 串 2024-11-03 21:00:00）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 1709208000000L), "1709253000000") // 腿 C N2.daily_0030.1709208000000.UTC|参照读数 1709253000000（UTC 串 2024-03-01 00:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Shanghai", 1709208000000L),
    "1709224200000",
  ) // 腿 C N2.daily_0030.1709208000000.Asia/Shanghai|参照读数 1709224200000（UTC 串 2024-02-29 16:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/New_York", 1709208000000L),
    "1709271000000",
  ) // 腿 C N2.daily_0030.1709208000000.America/New_York|参照读数 1709271000000（UTC 串 2024-03-01 05:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Kathmandu", 1709208000000L),
    "1709232300000",
  ) // 腿 C N2.daily_0030.1709208000000.Asia/Kathmandu|参照读数 1709232300000（UTC 串 2024-02-29 18:45:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709213400000",
  ) // 腿 C N2.daily_0030.1709208000000.Australia/Lord_Howe|参照读数 1709213400000（UTC 串 2024-02-29 13:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/Santiago", 1709208000000L),
    "1709263800000",
  ) // 腿 C N2.daily_0030.1709208000000.America/Santiago|参照读数 1709263800000（UTC 串 2024-03-01 03:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Tehran", 1709208000000L),
    "1709240400000",
  ) // 腿 C N2.daily_0030.1709208000000.Asia/Tehran|参照读数 1709240400000（UTC 串 2024-02-29 21:00:00）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 1714435200000L), "1714437000000") // 腿 C N2.daily_0030.1714435200000.UTC|参照读数 1714437000000（UTC 串 2024-04-30 00:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Shanghai", 1714435200000L),
    "1714494600000",
  ) // 腿 C N2.daily_0030.1714435200000.Asia/Shanghai|参照读数 1714494600000（UTC 串 2024-04-30 16:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/New_York", 1714435200000L),
    "1714451400000",
  ) // 腿 C N2.daily_0030.1714435200000.America/New_York|参照读数 1714451400000（UTC 串 2024-04-30 04:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Kathmandu", 1714435200000L),
    "1714502700000",
  ) // 腿 C N2.daily_0030.1714435200000.Asia/Kathmandu|参照读数 1714502700000（UTC 串 2024-04-30 18:45:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714485600000",
  ) // 腿 C N2.daily_0030.1714435200000.Australia/Lord_Howe|参照读数 1714485600000（UTC 串 2024-04-30 14:00:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/Santiago", 1714435200000L),
    "1714451400000",
  ) // 腿 C N2.daily_0030.1714435200000.America/Santiago|参照读数 1714451400000（UTC 串 2024-04-30 04:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Tehran", 1714435200000L),
    "1714510800000",
  ) // 腿 C N2.daily_0030.1714435200000.Asia/Tehran|参照读数 1714510800000（UTC 串 2024-04-30 21:00:00）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 515554200000L), "515637000000") // 腿 C N2.daily_0030.515554200000.UTC|参照读数 515637000000（UTC 串 1986-05-05 00:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Shanghai", 515554200000L),
    "515604600000",
  ) // 腿 C N2.daily_0030.515554200000.Asia/Shanghai|参照读数 515604600000（UTC 串 1986-05-04 15:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/New_York", 515554200000L),
    "515565000000",
  ) // 腿 C N2.daily_0030.515554200000.America/New_York|参照读数 515565000000（UTC 串 1986-05-04 04:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Kathmandu", 515554200000L),
    "515616300000",
  ) // 腿 C N2.daily_0030.515554200000.Asia/Kathmandu|参照读数 515616300000（UTC 串 1986-05-04 18:45:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 515554200000L),
    "515599200000",
  ) // 腿 C N2.daily_0030.515554200000.Australia/Lord_Howe|参照读数 515599200000（UTC 串 1986-05-04 14:00:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/Santiago", 515554200000L),
    "515565000000",
  ) // 腿 C N2.daily_0030.515554200000.America/Santiago|参照读数 515565000000（UTC 串 1986-05-04 04:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Tehran", 515554200000L),
    "515624400000",
  ) // 腿 C N2.daily_0030.515554200000.Asia/Tehran|参照读数 515624400000（UTC 串 1986-05-04 21:00:00）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 4070822400000L), "null") // 腿 C N2.daily_0030.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070824200000｜UTC 2098-12-31 00:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 0 * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N2.daily_0030.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070881800000｜UTC 2098-12-31 16:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 0 * * *", "America/New_York", 4070822400000L), "null") // 腿 C N2.daily_0030.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070842200000｜UTC 2098-12-31 05:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 0 * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N2.daily_0030.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070889900000｜UTC 2098-12-31 18:45:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N2.daily_0030.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070871000000｜UTC 2098-12-31 13:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 0 * * *", "America/Santiago", 4070822400000L), "null") // 腿 C N2.daily_0030.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070835000000｜UTC 2098-12-31 03:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 0 * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.daily_0030.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070898000000｜UTC 2098-12-31 21:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 1730606400000L), "1730680200000") // 腿 C N2.daily_0030.1730606400000.UTC|参照读数 1730680200000（UTC 串 2024-11-04 00:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Shanghai", 1730606400000L),
    "1730651400000",
  ) // 腿 C N2.daily_0030.1730606400000.Asia/Shanghai|参照读数 1730651400000（UTC 串 2024-11-03 16:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/New_York", 1730606400000L),
    "1730608200000",
  ) // 腿 C N2.daily_0030.1730606400000.America/New_York|参照读数 1730608200000（UTC 串 2024-11-03 04:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Kathmandu", 1730606400000L),
    "1730659500000",
  ) // 腿 C N2.daily_0030.1730606400000.Asia/Kathmandu|参照读数 1730659500000（UTC 串 2024-11-03 18:45:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730640600000",
  ) // 腿 C N2.daily_0030.1730606400000.Australia/Lord_Howe|参照读数 1730640600000（UTC 串 2024-11-03 13:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/Santiago", 1730606400000L),
    "1730691000000",
  ) // 腿 C N2.daily_0030.1730606400000.America/Santiago|参照读数 1730691000000（UTC 串 2024-11-04 03:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Tehran", 1730606400000L),
    "1730667600000",
  ) // 腿 C N2.daily_0030.1730606400000.Asia/Tehran|参照读数 1730667600000（UTC 串 2024-11-03 21:00:00）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 1709985600000L), "1710030600000") // 腿 C N2.daily_0030.1709985600000.UTC|参照读数 1710030600000（UTC 串 2024-03-10 00:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Shanghai", 1709985600000L),
    "1710001800000",
  ) // 腿 C N2.daily_0030.1709985600000.Asia/Shanghai|参照读数 1710001800000（UTC 串 2024-03-09 16:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/New_York", 1709985600000L),
    "1710048600000",
  ) // 腿 C N2.daily_0030.1709985600000.America/New_York|参照读数 1710048600000（UTC 串 2024-03-10 05:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Kathmandu", 1709985600000L),
    "1710009900000",
  ) // 腿 C N2.daily_0030.1709985600000.Asia/Kathmandu|参照读数 1710009900000（UTC 串 2024-03-09 18:45:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709991000000",
  ) // 腿 C N2.daily_0030.1709985600000.Australia/Lord_Howe|参照读数 1709991000000（UTC 串 2024-03-09 13:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/Santiago", 1709985600000L),
    "1710041400000",
  ) // 腿 C N2.daily_0030.1709985600000.America/Santiago|参照读数 1710041400000（UTC 串 2024-03-10 03:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Tehran", 1709985600000L),
    "1710018000000",
  ) // 腿 C N2.daily_0030.1709985600000.Asia/Tehran|参照读数 1710018000000（UTC 串 2024-03-09 21:00:00）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 1730548800000L), "1730593800000") // 腿 C N2.daily_0030.1730548800000.UTC|参照读数 1730593800000（UTC 串 2024-11-03 00:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Shanghai", 1730548800000L),
    "1730565000000",
  ) // 腿 C N2.daily_0030.1730548800000.Asia/Shanghai|参照读数 1730565000000（UTC 串 2024-11-02 16:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/New_York", 1730548800000L),
    "1730608200000",
  ) // 腿 C N2.daily_0030.1730548800000.America/New_York|参照读数 1730608200000（UTC 串 2024-11-03 04:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Kathmandu", 1730548800000L),
    "1730573100000",
  ) // 腿 C N2.daily_0030.1730548800000.Asia/Kathmandu|参照读数 1730573100000（UTC 串 2024-11-02 18:45:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730554200000",
  ) // 腿 C N2.daily_0030.1730548800000.Australia/Lord_Howe|参照读数 1730554200000（UTC 串 2024-11-02 13:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/Santiago", 1730548800000L),
    "1730604600000",
  ) // 腿 C N2.daily_0030.1730548800000.America/Santiago|参照读数 1730604600000（UTC 串 2024-11-03 03:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Tehran", 1730548800000L),
    "1730581200000",
  ) // 腿 C N2.daily_0030.1730548800000.Asia/Tehran|参照读数 1730581200000（UTC 串 2024-11-02 21:00:00）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 515505600000L), "515550600000") // 腿 C N2.daily_0030.515505600000.UTC|参照读数 515550600000（UTC 串 1986-05-04 00:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Shanghai", 515505600000L),
    "515521800000",
  ) // 腿 C N2.daily_0030.515505600000.Asia/Shanghai|参照读数 515521800000（UTC 串 1986-05-03 16:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/New_York", 515505600000L),
    "515565000000",
  ) // 腿 C N2.daily_0030.515505600000.America/New_York|参照读数 515565000000（UTC 串 1986-05-04 04:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Kathmandu", 515505600000L),
    "515529900000",
  ) // 腿 C N2.daily_0030.515505600000.Asia/Kathmandu|参照读数 515529900000（UTC 串 1986-05-03 18:45:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 515505600000L),
    "515512800000",
  ) // 腿 C N2.daily_0030.515505600000.Australia/Lord_Howe|参照读数 515512800000（UTC 串 1986-05-03 14:00:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/Santiago", 515505600000L),
    "515565000000",
  ) // 腿 C N2.daily_0030.515505600000.America/Santiago|参照读数 515565000000（UTC 串 1986-05-04 04:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Tehran", 515505600000L),
    "515538000000",
  ) // 腿 C N2.daily_0030.515505600000.Asia/Tehran|参照读数 515538000000（UTC 串 1986-05-03 21:00:00）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 1725710400000L), "1725755400000") // 腿 C N2.daily_0030.1725710400000.UTC|参照读数 1725755400000（UTC 串 2024-09-08 00:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Shanghai", 1725710400000L),
    "1725726600000",
  ) // 腿 C N2.daily_0030.1725710400000.Asia/Shanghai|参照读数 1725726600000（UTC 串 2024-09-07 16:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/New_York", 1725710400000L),
    "1725769800000",
  ) // 腿 C N2.daily_0030.1725710400000.America/New_York|参照读数 1725769800000（UTC 串 2024-09-08 04:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Kathmandu", 1725710400000L),
    "1725734700000",
  ) // 腿 C N2.daily_0030.1725710400000.Asia/Kathmandu|参照读数 1725734700000（UTC 串 2024-09-07 18:45:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725717600000",
  ) // 腿 C N2.daily_0030.1725710400000.Australia/Lord_Howe|参照读数 1725717600000（UTC 串 2024-09-07 14:00:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/Santiago", 1725710400000L),
    "1725852600000",
  ) // 腿 C N2.daily_0030.1725710400000.America/Santiago|参照读数 1725852600000（UTC 串 2024-09-09 03:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Tehran", 1725710400000L),
    "1725742800000",
  ) // 腿 C N2.daily_0030.1725710400000.Asia/Tehran|参照读数 1725742800000（UTC 串 2024-09-07 21:00:00）
  assert_eq(znm_tag("0 30 0 * * *", "UTC", 1647864000000L), "1647909000000") // 腿 C N2.daily_0030.1647864000000.UTC|参照读数 1647909000000（UTC 串 2022-03-22 00:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Shanghai", 1647864000000L),
    "1647880200000",
  ) // 腿 C N2.daily_0030.1647864000000.Asia/Shanghai|参照读数 1647880200000（UTC 串 2022-03-21 16:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/New_York", 1647864000000L),
    "1647923400000",
  ) // 腿 C N2.daily_0030.1647864000000.America/New_York|参照读数 1647923400000（UTC 串 2022-03-22 04:30:00）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znm_tag 行，已匹配给自身/末支，第 3 块 180 条）" {
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Kathmandu", 1647864000000L),
    "1647888300000",
  ) // 腿 C N2.daily_0030.1647864000000.Asia/Kathmandu|参照读数 1647888300000（UTC 串 2022-03-21 18:45:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647869400000",
  ) // 腿 C N2.daily_0030.1647864000000.Australia/Lord_Howe|参照读数 1647869400000（UTC 串 2022-03-21 13:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "America/Santiago", 1647864000000L),
    "1647919800000",
  ) // 腿 C N2.daily_0030.1647864000000.America/Santiago|参照读数 1647919800000（UTC 串 2022-03-22 03:30:00）
  assert_eq(
    znm_tag("0 30 0 * * *", "Asia/Tehran", 1647864000000L),
    "1647979200000",
  ) // 腿 C N2.daily_0030.1647864000000.Asia/Tehran|参照读数 1647979200000（UTC 串 2022-03-22 20:00:00）
  assert_eq(znm_tag("45 23 * * *", "UTC", 1710050400000L), "1710114300000") // 腿 C N2.daily_2345.1710050400000.UTC|参照读数 1710114300000（UTC 串 2024-03-10 23:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Shanghai", 1710050400000L),
    "1710085500000",
  ) // 腿 C N2.daily_2345.1710050400000.Asia/Shanghai|参照读数 1710085500000（UTC 串 2024-03-10 15:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/New_York", 1710050400000L),
    "1710128700000",
  ) // 腿 C N2.daily_2345.1710050400000.America/New_York|参照读数 1710128700000（UTC 串 2024-03-11 03:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Kathmandu", 1710050400000L),
    "1710093600000",
  ) // 腿 C N2.daily_2345.1710050400000.Asia/Kathmandu|参照读数 1710093600000（UTC 串 2024-03-10 18:00:00）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710074700000",
  ) // 腿 C N2.daily_2345.1710050400000.Australia/Lord_Howe|参照读数 1710074700000（UTC 串 2024-03-10 12:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/Santiago", 1710050400000L),
    "1710125100000",
  ) // 腿 C N2.daily_2345.1710050400000.America/Santiago|参照读数 1710125100000（UTC 串 2024-03-11 02:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Tehran", 1710050400000L),
    "1710101700000",
  ) // 腿 C N2.daily_2345.1710050400000.Asia/Tehran|参照读数 1710101700000（UTC 串 2024-03-10 20:15:00）
  assert_eq(znm_tag("45 23 * * *", "UTC", 1730611800000L), "1730677500000") // 腿 C N2.daily_2345.1730611800000.UTC|参照读数 1730677500000（UTC 串 2024-11-03 23:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Shanghai", 1730611800000L),
    "1730648700000",
  ) // 腿 C N2.daily_2345.1730611800000.Asia/Shanghai|参照读数 1730648700000（UTC 串 2024-11-03 15:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/New_York", 1730611800000L),
    "1730695500000",
  ) // 腿 C N2.daily_2345.1730611800000.America/New_York|参照读数 1730695500000（UTC 串 2024-11-04 04:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Kathmandu", 1730611800000L),
    "1730656800000",
  ) // 腿 C N2.daily_2345.1730611800000.Asia/Kathmandu|参照读数 1730656800000（UTC 串 2024-11-03 18:00:00）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730637900000",
  ) // 腿 C N2.daily_2345.1730611800000.Australia/Lord_Howe|参照读数 1730637900000（UTC 串 2024-11-03 12:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/Santiago", 1730611800000L),
    "1730688300000",
  ) // 腿 C N2.daily_2345.1730611800000.America/Santiago|参照读数 1730688300000（UTC 串 2024-11-04 02:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Tehran", 1730611800000L),
    "1730664900000",
  ) // 腿 C N2.daily_2345.1730611800000.Asia/Tehran|参照读数 1730664900000（UTC 串 2024-11-03 20:15:00）
  assert_eq(znm_tag("45 23 * * *", "UTC", 1730615400000L), "1730677500000") // 腿 C N2.daily_2345.1730615400000.UTC|参照读数 1730677500000（UTC 串 2024-11-03 23:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Shanghai", 1730615400000L),
    "1730648700000",
  ) // 腿 C N2.daily_2345.1730615400000.Asia/Shanghai|参照读数 1730648700000（UTC 串 2024-11-03 15:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/New_York", 1730615400000L),
    "1730695500000",
  ) // 腿 C N2.daily_2345.1730615400000.America/New_York|参照读数 1730695500000（UTC 串 2024-11-04 04:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Kathmandu", 1730615400000L),
    "1730656800000",
  ) // 腿 C N2.daily_2345.1730615400000.Asia/Kathmandu|参照读数 1730656800000（UTC 串 2024-11-03 18:00:00）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730637900000",
  ) // 腿 C N2.daily_2345.1730615400000.Australia/Lord_Howe|参照读数 1730637900000（UTC 串 2024-11-03 12:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/Santiago", 1730615400000L),
    "1730688300000",
  ) // 腿 C N2.daily_2345.1730615400000.America/Santiago|参照读数 1730688300000（UTC 串 2024-11-04 02:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Tehran", 1730615400000L),
    "1730664900000",
  ) // 腿 C N2.daily_2345.1730615400000.Asia/Tehran|参照读数 1730664900000（UTC 串 2024-11-03 20:15:00）
  assert_eq(znm_tag("45 23 * * *", "UTC", 1709208000000L), "1709250300000") // 腿 C N2.daily_2345.1709208000000.UTC|参照读数 1709250300000（UTC 串 2024-02-29 23:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Shanghai", 1709208000000L),
    "1709221500000",
  ) // 腿 C N2.daily_2345.1709208000000.Asia/Shanghai|参照读数 1709221500000（UTC 串 2024-02-29 15:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/New_York", 1709208000000L),
    "1709268300000",
  ) // 腿 C N2.daily_2345.1709208000000.America/New_York|参照读数 1709268300000（UTC 串 2024-03-01 04:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Kathmandu", 1709208000000L),
    "1709229600000",
  ) // 腿 C N2.daily_2345.1709208000000.Asia/Kathmandu|参照读数 1709229600000（UTC 串 2024-02-29 18:00:00）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709210700000",
  ) // 腿 C N2.daily_2345.1709208000000.Australia/Lord_Howe|参照读数 1709210700000（UTC 串 2024-02-29 12:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/Santiago", 1709208000000L),
    "1709261100000",
  ) // 腿 C N2.daily_2345.1709208000000.America/Santiago|参照读数 1709261100000（UTC 串 2024-03-01 02:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Tehran", 1709208000000L),
    "1709237700000",
  ) // 腿 C N2.daily_2345.1709208000000.Asia/Tehran|参照读数 1709237700000（UTC 串 2024-02-29 20:15:00）
  assert_eq(znm_tag("45 23 * * *", "UTC", 1714435200000L), "1714520700000") // 腿 C N2.daily_2345.1714435200000.UTC|参照读数 1714520700000（UTC 串 2024-04-30 23:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Shanghai", 1714435200000L),
    "1714491900000",
  ) // 腿 C N2.daily_2345.1714435200000.Asia/Shanghai|参照读数 1714491900000（UTC 串 2024-04-30 15:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/New_York", 1714435200000L),
    "1714448700000",
  ) // 腿 C N2.daily_2345.1714435200000.America/New_York|参照读数 1714448700000（UTC 串 2024-04-30 03:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Kathmandu", 1714435200000L),
    "1714500000000",
  ) // 腿 C N2.daily_2345.1714435200000.Asia/Kathmandu|参照读数 1714500000000（UTC 串 2024-04-30 18:00:00）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714482900000",
  ) // 腿 C N2.daily_2345.1714435200000.Australia/Lord_Howe|参照读数 1714482900000（UTC 串 2024-04-30 13:15:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/Santiago", 1714435200000L),
    "1714448700000",
  ) // 腿 C N2.daily_2345.1714435200000.America/Santiago|参照读数 1714448700000（UTC 串 2024-04-30 03:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Tehran", 1714435200000L),
    "1714508100000",
  ) // 腿 C N2.daily_2345.1714435200000.Asia/Tehran|参照读数 1714508100000（UTC 串 2024-04-30 20:15:00）
  assert_eq(znm_tag("45 23 * * *", "UTC", 515554200000L), "515634300000") // 腿 C N2.daily_2345.515554200000.UTC|参照读数 515634300000（UTC 串 1986-05-04 23:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Shanghai", 515554200000L),
    "515601900000",
  ) // 腿 C N2.daily_2345.515554200000.Asia/Shanghai|参照读数 515601900000（UTC 串 1986-05-04 14:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/New_York", 515554200000L),
    "515562300000",
  ) // 腿 C N2.daily_2345.515554200000.America/New_York|参照读数 515562300000（UTC 串 1986-05-04 03:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Kathmandu", 515554200000L),
    "515613600000",
  ) // 腿 C N2.daily_2345.515554200000.Asia/Kathmandu|参照读数 515613600000（UTC 串 1986-05-04 18:00:00）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 515554200000L),
    "515596500000",
  ) // 腿 C N2.daily_2345.515554200000.Australia/Lord_Howe|参照读数 515596500000（UTC 串 1986-05-04 13:15:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/Santiago", 515554200000L),
    "515562300000",
  ) // 腿 C N2.daily_2345.515554200000.America/Santiago|参照读数 515562300000（UTC 串 1986-05-04 03:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Tehran", 515554200000L),
    "515621700000",
  ) // 腿 C N2.daily_2345.515554200000.Asia/Tehran|参照读数 515621700000（UTC 串 1986-05-04 20:15:00）
  assert_eq(znm_tag("45 23 * * *", "UTC", 4070822400000L), "null") // 腿 C N2.daily_2345.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070907900000｜UTC 2098-12-31 23:45:00，spec §11 第 4 行）
  assert_eq(znm_tag("45 23 * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N2.daily_2345.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070879100000｜UTC 2098-12-31 15:45:00，spec §11 第 4 行）
  assert_eq(znm_tag("45 23 * * *", "America/New_York", 4070822400000L), "null") // 腿 C N2.daily_2345.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070839500000｜UTC 2098-12-31 04:45:00，spec §11 第 4 行）
  assert_eq(znm_tag("45 23 * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N2.daily_2345.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070887200000｜UTC 2098-12-31 18:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N2.daily_2345.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070868300000｜UTC 2098-12-31 12:45:00，spec §11 第 4 行）
  assert_eq(znm_tag("45 23 * * *", "America/Santiago", 4070822400000L), "null") // 腿 C N2.daily_2345.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070832300000｜UTC 2098-12-31 02:45:00，spec §11 第 4 行）
  assert_eq(znm_tag("45 23 * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.daily_2345.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070895300000｜UTC 2098-12-31 20:15:00，spec §11 第 4 行）
  assert_eq(znm_tag("45 23 * * *", "UTC", 1730606400000L), "1730677500000") // 腿 C N2.daily_2345.1730606400000.UTC|参照读数 1730677500000（UTC 串 2024-11-03 23:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Shanghai", 1730606400000L),
    "1730648700000",
  ) // 腿 C N2.daily_2345.1730606400000.Asia/Shanghai|参照读数 1730648700000（UTC 串 2024-11-03 15:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/New_York", 1730606400000L),
    "1730695500000",
  ) // 腿 C N2.daily_2345.1730606400000.America/New_York|参照读数 1730695500000（UTC 串 2024-11-04 04:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Kathmandu", 1730606400000L),
    "1730656800000",
  ) // 腿 C N2.daily_2345.1730606400000.Asia/Kathmandu|参照读数 1730656800000（UTC 串 2024-11-03 18:00:00）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730637900000",
  ) // 腿 C N2.daily_2345.1730606400000.Australia/Lord_Howe|参照读数 1730637900000（UTC 串 2024-11-03 12:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/Santiago", 1730606400000L),
    "1730688300000",
  ) // 腿 C N2.daily_2345.1730606400000.America/Santiago|参照读数 1730688300000（UTC 串 2024-11-04 02:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Tehran", 1730606400000L),
    "1730664900000",
  ) // 腿 C N2.daily_2345.1730606400000.Asia/Tehran|参照读数 1730664900000（UTC 串 2024-11-03 20:15:00）
  assert_eq(znm_tag("45 23 * * *", "UTC", 1709985600000L), "1710027900000") // 腿 C N2.daily_2345.1709985600000.UTC|参照读数 1710027900000（UTC 串 2024-03-09 23:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Shanghai", 1709985600000L),
    "1709999100000",
  ) // 腿 C N2.daily_2345.1709985600000.Asia/Shanghai|参照读数 1709999100000（UTC 串 2024-03-09 15:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/New_York", 1709985600000L),
    "1710045900000",
  ) // 腿 C N2.daily_2345.1709985600000.America/New_York|参照读数 1710045900000（UTC 串 2024-03-10 04:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Kathmandu", 1709985600000L),
    "1710007200000",
  ) // 腿 C N2.daily_2345.1709985600000.Asia/Kathmandu|参照读数 1710007200000（UTC 串 2024-03-09 18:00:00）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709988300000",
  ) // 腿 C N2.daily_2345.1709985600000.Australia/Lord_Howe|参照读数 1709988300000（UTC 串 2024-03-09 12:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/Santiago", 1709985600000L),
    "1710038700000",
  ) // 腿 C N2.daily_2345.1709985600000.America/Santiago|参照读数 1710038700000（UTC 串 2024-03-10 02:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Tehran", 1709985600000L),
    "1710015300000",
  ) // 腿 C N2.daily_2345.1709985600000.Asia/Tehran|参照读数 1710015300000（UTC 串 2024-03-09 20:15:00）
  assert_eq(znm_tag("45 23 * * *", "UTC", 1730548800000L), "1730591100000") // 腿 C N2.daily_2345.1730548800000.UTC|参照读数 1730591100000（UTC 串 2024-11-02 23:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Shanghai", 1730548800000L),
    "1730562300000",
  ) // 腿 C N2.daily_2345.1730548800000.Asia/Shanghai|参照读数 1730562300000（UTC 串 2024-11-02 15:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/New_York", 1730548800000L),
    "1730605500000",
  ) // 腿 C N2.daily_2345.1730548800000.America/New_York|参照读数 1730605500000（UTC 串 2024-11-03 03:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Kathmandu", 1730548800000L),
    "1730570400000",
  ) // 腿 C N2.daily_2345.1730548800000.Asia/Kathmandu|参照读数 1730570400000（UTC 串 2024-11-02 18:00:00）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730551500000",
  ) // 腿 C N2.daily_2345.1730548800000.Australia/Lord_Howe|参照读数 1730551500000（UTC 串 2024-11-02 12:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/Santiago", 1730548800000L),
    "1730601900000",
  ) // 腿 C N2.daily_2345.1730548800000.America/Santiago|参照读数 1730601900000（UTC 串 2024-11-03 02:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Tehran", 1730548800000L),
    "1730578500000",
  ) // 腿 C N2.daily_2345.1730548800000.Asia/Tehran|参照读数 1730578500000（UTC 串 2024-11-02 20:15:00）
  assert_eq(znm_tag("45 23 * * *", "UTC", 515505600000L), "515547900000") // 腿 C N2.daily_2345.515505600000.UTC|参照读数 515547900000（UTC 串 1986-05-03 23:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Shanghai", 515505600000L),
    "515519100000",
  ) // 腿 C N2.daily_2345.515505600000.Asia/Shanghai|参照读数 515519100000（UTC 串 1986-05-03 15:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/New_York", 515505600000L),
    "515562300000",
  ) // 腿 C N2.daily_2345.515505600000.America/New_York|参照读数 515562300000（UTC 串 1986-05-04 03:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Kathmandu", 515505600000L),
    "515527200000",
  ) // 腿 C N2.daily_2345.515505600000.Asia/Kathmandu|参照读数 515527200000（UTC 串 1986-05-03 18:00:00）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 515505600000L),
    "515510100000",
  ) // 腿 C N2.daily_2345.515505600000.Australia/Lord_Howe|参照读数 515510100000（UTC 串 1986-05-03 13:15:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/Santiago", 515505600000L),
    "515562300000",
  ) // 腿 C N2.daily_2345.515505600000.America/Santiago|参照读数 515562300000（UTC 串 1986-05-04 03:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Tehran", 515505600000L),
    "515535300000",
  ) // 腿 C N2.daily_2345.515505600000.Asia/Tehran|参照读数 515535300000（UTC 串 1986-05-03 20:15:00）
  assert_eq(znm_tag("45 23 * * *", "UTC", 1725710400000L), "1725752700000") // 腿 C N2.daily_2345.1725710400000.UTC|参照读数 1725752700000（UTC 串 2024-09-07 23:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Shanghai", 1725710400000L),
    "1725723900000",
  ) // 腿 C N2.daily_2345.1725710400000.Asia/Shanghai|参照读数 1725723900000（UTC 串 2024-09-07 15:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/New_York", 1725710400000L),
    "1725767100000",
  ) // 腿 C N2.daily_2345.1725710400000.America/New_York|参照读数 1725767100000（UTC 串 2024-09-08 03:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Kathmandu", 1725710400000L),
    "1725732000000",
  ) // 腿 C N2.daily_2345.1725710400000.Asia/Kathmandu|参照读数 1725732000000（UTC 串 2024-09-07 18:00:00）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725714900000",
  ) // 腿 C N2.daily_2345.1725710400000.Australia/Lord_Howe|参照读数 1725714900000（UTC 串 2024-09-07 13:15:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/Santiago", 1725710400000L),
    "1725767100000",
  ) // 腿 C N2.daily_2345.1725710400000.America/Santiago|参照读数 1725767100000（UTC 串 2024-09-08 03:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Tehran", 1725710400000L),
    "1725740100000",
  ) // 腿 C N2.daily_2345.1725710400000.Asia/Tehran|参照读数 1725740100000（UTC 串 2024-09-07 20:15:00）
  assert_eq(znm_tag("45 23 * * *", "UTC", 1647864000000L), "1647906300000") // 腿 C N2.daily_2345.1647864000000.UTC|参照读数 1647906300000（UTC 串 2022-03-21 23:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Shanghai", 1647864000000L),
    "1647877500000",
  ) // 腿 C N2.daily_2345.1647864000000.Asia/Shanghai|参照读数 1647877500000（UTC 串 2022-03-21 15:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/New_York", 1647864000000L),
    "1647920700000",
  ) // 腿 C N2.daily_2345.1647864000000.America/New_York|参照读数 1647920700000（UTC 串 2022-03-22 03:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Kathmandu", 1647864000000L),
    "1647885600000",
  ) // 腿 C N2.daily_2345.1647864000000.Asia/Kathmandu|参照读数 1647885600000（UTC 串 2022-03-21 18:00:00）
  assert_eq(
    znm_tag("45 23 * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647866700000",
  ) // 腿 C N2.daily_2345.1647864000000.Australia/Lord_Howe|参照读数 1647866700000（UTC 串 2022-03-21 12:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "America/Santiago", 1647864000000L),
    "1647917100000",
  ) // 腿 C N2.daily_2345.1647864000000.America/Santiago|参照读数 1647917100000（UTC 串 2022-03-22 02:45:00）
  assert_eq(
    znm_tag("45 23 * * *", "Asia/Tehran", 1647864000000L),
    "1647893700000",
  ) // 腿 C N2.daily_2345.1647864000000.Asia/Tehran|参照读数 1647893700000（UTC 串 2022-03-21 20:15:00）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 1710050400000L), "1835395200000") // 腿 C N2.leap_only.1710050400000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 1710050400000L),
    "1835366400000",
  ) // 腿 C N2.leap_only.1710050400000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/New_York", 1710050400000L),
    "1835413200000",
  ) // 腿 C N2.leap_only.1710050400000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1710050400000L),
    "1835374500000",
  ) // 腿 C N2.leap_only.1710050400000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1710050400000L),
    "1835355600000",
  ) // 腿 C N2.leap_only.1710050400000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/Santiago", 1710050400000L),
    "1835406000000",
  ) // 腿 C N2.leap_only.1710050400000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Tehran", 1710050400000L),
    "1835382600000",
  ) // 腿 C N2.leap_only.1710050400000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 1730611800000L), "1835395200000") // 腿 C N2.leap_only.1730611800000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 1730611800000L),
    "1835366400000",
  ) // 腿 C N2.leap_only.1730611800000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/New_York", 1730611800000L),
    "1835413200000",
  ) // 腿 C N2.leap_only.1730611800000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1730611800000L),
    "1835374500000",
  ) // 腿 C N2.leap_only.1730611800000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1730611800000L),
    "1835355600000",
  ) // 腿 C N2.leap_only.1730611800000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/Santiago", 1730611800000L),
    "1835406000000",
  ) // 腿 C N2.leap_only.1730611800000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Tehran", 1730611800000L),
    "1835382600000",
  ) // 腿 C N2.leap_only.1730611800000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 1730615400000L), "1835395200000") // 腿 C N2.leap_only.1730615400000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 1730615400000L),
    "1835366400000",
  ) // 腿 C N2.leap_only.1730615400000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/New_York", 1730615400000L),
    "1835413200000",
  ) // 腿 C N2.leap_only.1730615400000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1730615400000L),
    "1835374500000",
  ) // 腿 C N2.leap_only.1730615400000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1730615400000L),
    "1835355600000",
  ) // 腿 C N2.leap_only.1730615400000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/Santiago", 1730615400000L),
    "1835406000000",
  ) // 腿 C N2.leap_only.1730615400000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Tehran", 1730615400000L),
    "1835382600000",
  ) // 腿 C N2.leap_only.1730615400000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 1709208000000L), "1835395200000") // 腿 C N2.leap_only.1709208000000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 1709208000000L),
    "1835366400000",
  ) // 腿 C N2.leap_only.1709208000000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/New_York", 1709208000000L),
    "1835413200000",
  ) // 腿 C N2.leap_only.1709208000000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1709208000000L),
    "1835374500000",
  ) // 腿 C N2.leap_only.1709208000000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1709208000000L),
    "1835355600000",
  ) // 腿 C N2.leap_only.1709208000000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/Santiago", 1709208000000L),
    "1835406000000",
  ) // 腿 C N2.leap_only.1709208000000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Tehran", 1709208000000L),
    "1835382600000",
  ) // 腿 C N2.leap_only.1709208000000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 1714435200000L), "1835395200000") // 腿 C N2.leap_only.1714435200000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 1714435200000L),
    "1835366400000",
  ) // 腿 C N2.leap_only.1714435200000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/New_York", 1714435200000L),
    "1835413200000",
  ) // 腿 C N2.leap_only.1714435200000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1714435200000L),
    "1835374500000",
  ) // 腿 C N2.leap_only.1714435200000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1714435200000L),
    "1835355600000",
  ) // 腿 C N2.leap_only.1714435200000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/Santiago", 1714435200000L),
    "1835406000000",
  ) // 腿 C N2.leap_only.1714435200000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Tehran", 1714435200000L),
    "1835382600000",
  ) // 腿 C N2.leap_only.1714435200000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 515554200000L), "573091200000") // 腿 C N2.leap_only.515554200000.UTC|参照读数 573091200000（UTC 串 1988-02-29 00:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 515554200000L),
    "573062400000",
  ) // 腿 C N2.leap_only.515554200000.Asia/Shanghai|参照读数 573062400000（UTC 串 1988-02-28 16:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/New_York", 515554200000L),
    "573109200000",
  ) // 腿 C N2.leap_only.515554200000.America/New_York|参照读数 573109200000（UTC 串 1988-02-29 05:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 515554200000L),
    "573070500000",
  ) // 腿 C N2.leap_only.515554200000.Asia/Kathmandu|参照读数 573070500000（UTC 串 1988-02-28 18:15:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 515554200000L),
    "573051600000",
  ) // 腿 C N2.leap_only.515554200000.Australia/Lord_Howe|参照读数 573051600000（UTC 串 1988-02-28 13:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/Santiago", 515554200000L),
    "573102000000",
  ) // 腿 C N2.leap_only.515554200000.America/Santiago|参照读数 573102000000（UTC 串 1988-02-29 03:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Tehran", 515554200000L),
    "573078600000",
  ) // 腿 C N2.leap_only.515554200000.Asia/Tehran|参照读数 573078600000（UTC 串 1988-02-28 20:30:00）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 4070822400000L), "null") // 腿 C N2.leap_only.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4233686400000｜UTC 2104-02-29 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N2.leap_only.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4233657600000｜UTC 2104-02-28 16:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 29 2 *", "America/New_York", 4070822400000L), "null") // 腿 C N2.leap_only.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4233704400000｜UTC 2104-02-29 05:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N2.leap_only.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4233665700000｜UTC 2104-02-28 18:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N2.leap_only.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4233646800000｜UTC 2104-02-28 13:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 29 2 *", "America/Santiago", 4070822400000L), "null") // 腿 C N2.leap_only.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4233697200000｜UTC 2104-02-29 03:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 29 2 *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.leap_only.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4233673800000｜UTC 2104-02-28 20:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 1730606400000L), "1835395200000") // 腿 C N2.leap_only.1730606400000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 1730606400000L),
    "1835366400000",
  ) // 腿 C N2.leap_only.1730606400000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/New_York", 1730606400000L),
    "1835413200000",
  ) // 腿 C N2.leap_only.1730606400000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1730606400000L),
    "1835374500000",
  ) // 腿 C N2.leap_only.1730606400000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1730606400000L),
    "1835355600000",
  ) // 腿 C N2.leap_only.1730606400000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/Santiago", 1730606400000L),
    "1835406000000",
  ) // 腿 C N2.leap_only.1730606400000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Tehran", 1730606400000L),
    "1835382600000",
  ) // 腿 C N2.leap_only.1730606400000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 1709985600000L), "1835395200000") // 腿 C N2.leap_only.1709985600000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 1709985600000L),
    "1835366400000",
  ) // 腿 C N2.leap_only.1709985600000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/New_York", 1709985600000L),
    "1835413200000",
  ) // 腿 C N2.leap_only.1709985600000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1709985600000L),
    "1835374500000",
  ) // 腿 C N2.leap_only.1709985600000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1709985600000L),
    "1835355600000",
  ) // 腿 C N2.leap_only.1709985600000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/Santiago", 1709985600000L),
    "1835406000000",
  ) // 腿 C N2.leap_only.1709985600000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Tehran", 1709985600000L),
    "1835382600000",
  ) // 腿 C N2.leap_only.1709985600000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 1730548800000L), "1835395200000") // 腿 C N2.leap_only.1730548800000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 1730548800000L),
    "1835366400000",
  ) // 腿 C N2.leap_only.1730548800000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/New_York", 1730548800000L),
    "1835413200000",
  ) // 腿 C N2.leap_only.1730548800000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1730548800000L),
    "1835374500000",
  ) // 腿 C N2.leap_only.1730548800000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1730548800000L),
    "1835355600000",
  ) // 腿 C N2.leap_only.1730548800000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/Santiago", 1730548800000L),
    "1835406000000",
  ) // 腿 C N2.leap_only.1730548800000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Tehran", 1730548800000L),
    "1835382600000",
  ) // 腿 C N2.leap_only.1730548800000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 515505600000L), "573091200000") // 腿 C N2.leap_only.515505600000.UTC|参照读数 573091200000（UTC 串 1988-02-29 00:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 515505600000L),
    "573062400000",
  ) // 腿 C N2.leap_only.515505600000.Asia/Shanghai|参照读数 573062400000（UTC 串 1988-02-28 16:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/New_York", 515505600000L),
    "573109200000",
  ) // 腿 C N2.leap_only.515505600000.America/New_York|参照读数 573109200000（UTC 串 1988-02-29 05:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 515505600000L),
    "573070500000",
  ) // 腿 C N2.leap_only.515505600000.Asia/Kathmandu|参照读数 573070500000（UTC 串 1988-02-28 18:15:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 515505600000L),
    "573051600000",
  ) // 腿 C N2.leap_only.515505600000.Australia/Lord_Howe|参照读数 573051600000（UTC 串 1988-02-28 13:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/Santiago", 515505600000L),
    "573102000000",
  ) // 腿 C N2.leap_only.515505600000.America/Santiago|参照读数 573102000000（UTC 串 1988-02-29 03:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Tehran", 515505600000L),
    "573078600000",
  ) // 腿 C N2.leap_only.515505600000.Asia/Tehran|参照读数 573078600000（UTC 串 1988-02-28 20:30:00）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 1725710400000L), "1835395200000") // 腿 C N2.leap_only.1725710400000.UTC|参照读数 1835395200000（UTC 串 2028-02-29 00:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 1725710400000L),
    "1835366400000",
  ) // 腿 C N2.leap_only.1725710400000.Asia/Shanghai|参照读数 1835366400000（UTC 串 2028-02-28 16:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/New_York", 1725710400000L),
    "1835413200000",
  ) // 腿 C N2.leap_only.1725710400000.America/New_York|参照读数 1835413200000（UTC 串 2028-02-29 05:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1725710400000L),
    "1835374500000",
  ) // 腿 C N2.leap_only.1725710400000.Asia/Kathmandu|参照读数 1835374500000（UTC 串 2028-02-28 18:15:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1725710400000L),
    "1835355600000",
  ) // 腿 C N2.leap_only.1725710400000.Australia/Lord_Howe|参照读数 1835355600000（UTC 串 2028-02-28 13:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/Santiago", 1725710400000L),
    "1835406000000",
  ) // 腿 C N2.leap_only.1725710400000.America/Santiago|参照读数 1835406000000（UTC 串 2028-02-29 03:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Tehran", 1725710400000L),
    "1835382600000",
  ) // 腿 C N2.leap_only.1725710400000.Asia/Tehran|参照读数 1835382600000（UTC 串 2028-02-28 20:30:00）
  assert_eq(znm_tag("0 0 0 29 2 *", "UTC", 1647864000000L), "1709164800000") // 腿 C N2.leap_only.1647864000000.UTC|参照读数 1709164800000（UTC 串 2024-02-29 00:00:00）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znm_tag 行，已匹配给自身/末支，第 4 块 180 条）" {
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Shanghai", 1647864000000L),
    "1709136000000",
  ) // 腿 C N2.leap_only.1647864000000.Asia/Shanghai|参照读数 1709136000000（UTC 串 2024-02-28 16:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/New_York", 1647864000000L),
    "1709182800000",
  ) // 腿 C N2.leap_only.1647864000000.America/New_York|参照读数 1709182800000（UTC 串 2024-02-29 05:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Kathmandu", 1647864000000L),
    "1709144100000",
  ) // 腿 C N2.leap_only.1647864000000.Asia/Kathmandu|参照读数 1709144100000（UTC 串 2024-02-28 18:15:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Australia/Lord_Howe", 1647864000000L),
    "1709125200000",
  ) // 腿 C N2.leap_only.1647864000000.Australia/Lord_Howe|参照读数 1709125200000（UTC 串 2024-02-28 13:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "America/Santiago", 1647864000000L),
    "1709175600000",
  ) // 腿 C N2.leap_only.1647864000000.America/Santiago|参照读数 1709175600000（UTC 串 2024-02-29 03:00:00）
  assert_eq(
    znm_tag("0 0 0 29 2 *", "Asia/Tehran", 1647864000000L),
    "1709152200000",
  ) // 腿 C N2.leap_only.1647864000000.Asia/Tehran|参照读数 1709152200000（UTC 串 2024-02-28 20:30:00）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 1710050400000L), "1714478400000") // 腿 C N2.apr31.1710050400000.UTC|参照读数 1714478400000（UTC 串 2024-04-30 12:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Shanghai", 1710050400000L),
    "1714449600000",
  ) // 腿 C N2.apr31.1710050400000.Asia/Shanghai|参照读数 1714449600000（UTC 串 2024-04-30 04:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/New_York", 1710050400000L),
    "1714492800000",
  ) // 腿 C N2.apr31.1710050400000.America/New_York|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Kathmandu", 1710050400000L),
    "1714457700000",
  ) // 腿 C N2.apr31.1710050400000.Asia/Kathmandu|参照读数 1714457700000（UTC 串 2024-04-30 06:15:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 1710050400000L),
    "1714440600000",
  ) // 腿 C N2.apr31.1710050400000.Australia/Lord_Howe|参照读数 1714440600000（UTC 串 2024-04-30 01:30:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/Santiago", 1710050400000L),
    "1714492800000",
  ) // 腿 C N2.apr31.1710050400000.America/Santiago|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Tehran", 1710050400000L),
    "1714465800000",
  ) // 腿 C N2.apr31.1710050400000.Asia/Tehran|参照读数 1714465800000（UTC 串 2024-04-30 08:30:00）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 1730611800000L), "1746014400000") // 腿 C N2.apr31.1730611800000.UTC|参照读数 1746014400000（UTC 串 2025-04-30 12:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Shanghai", 1730611800000L),
    "1745985600000",
  ) // 腿 C N2.apr31.1730611800000.Asia/Shanghai|参照读数 1745985600000（UTC 串 2025-04-30 04:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/New_York", 1730611800000L),
    "1746028800000",
  ) // 腿 C N2.apr31.1730611800000.America/New_York|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Kathmandu", 1730611800000L),
    "1745993700000",
  ) // 腿 C N2.apr31.1730611800000.Asia/Kathmandu|参照读数 1745993700000（UTC 串 2025-04-30 06:15:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 1730611800000L),
    "1745976600000",
  ) // 腿 C N2.apr31.1730611800000.Australia/Lord_Howe|参照读数 1745976600000（UTC 串 2025-04-30 01:30:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/Santiago", 1730611800000L),
    "1746028800000",
  ) // 腿 C N2.apr31.1730611800000.America/Santiago|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Tehran", 1730611800000L),
    "1746001800000",
  ) // 腿 C N2.apr31.1730611800000.Asia/Tehran|参照读数 1746001800000（UTC 串 2025-04-30 08:30:00）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 1730615400000L), "1746014400000") // 腿 C N2.apr31.1730615400000.UTC|参照读数 1746014400000（UTC 串 2025-04-30 12:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Shanghai", 1730615400000L),
    "1745985600000",
  ) // 腿 C N2.apr31.1730615400000.Asia/Shanghai|参照读数 1745985600000（UTC 串 2025-04-30 04:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/New_York", 1730615400000L),
    "1746028800000",
  ) // 腿 C N2.apr31.1730615400000.America/New_York|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Kathmandu", 1730615400000L),
    "1745993700000",
  ) // 腿 C N2.apr31.1730615400000.Asia/Kathmandu|参照读数 1745993700000（UTC 串 2025-04-30 06:15:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 1730615400000L),
    "1745976600000",
  ) // 腿 C N2.apr31.1730615400000.Australia/Lord_Howe|参照读数 1745976600000（UTC 串 2025-04-30 01:30:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/Santiago", 1730615400000L),
    "1746028800000",
  ) // 腿 C N2.apr31.1730615400000.America/Santiago|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Tehran", 1730615400000L),
    "1746001800000",
  ) // 腿 C N2.apr31.1730615400000.Asia/Tehran|参照读数 1746001800000（UTC 串 2025-04-30 08:30:00）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 1709208000000L), "1714478400000") // 腿 C N2.apr31.1709208000000.UTC|参照读数 1714478400000（UTC 串 2024-04-30 12:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Shanghai", 1709208000000L),
    "1714449600000",
  ) // 腿 C N2.apr31.1709208000000.Asia/Shanghai|参照读数 1714449600000（UTC 串 2024-04-30 04:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/New_York", 1709208000000L),
    "1714492800000",
  ) // 腿 C N2.apr31.1709208000000.America/New_York|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Kathmandu", 1709208000000L),
    "1714457700000",
  ) // 腿 C N2.apr31.1709208000000.Asia/Kathmandu|参照读数 1714457700000（UTC 串 2024-04-30 06:15:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 1709208000000L),
    "1714440600000",
  ) // 腿 C N2.apr31.1709208000000.Australia/Lord_Howe|参照读数 1714440600000（UTC 串 2024-04-30 01:30:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/Santiago", 1709208000000L),
    "1714492800000",
  ) // 腿 C N2.apr31.1709208000000.America/Santiago|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Tehran", 1709208000000L),
    "1714465800000",
  ) // 腿 C N2.apr31.1709208000000.Asia/Tehran|参照读数 1714465800000（UTC 串 2024-04-30 08:30:00）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 1714435200000L), "1714478400000") // 腿 C N2.apr31.1714435200000.UTC|参照读数 1714478400000（UTC 串 2024-04-30 12:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Shanghai", 1714435200000L),
    "1714449600000",
  ) // 腿 C N2.apr31.1714435200000.Asia/Shanghai|参照读数 1714449600000（UTC 串 2024-04-30 04:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/New_York", 1714435200000L),
    "1714492800000",
  ) // 腿 C N2.apr31.1714435200000.America/New_York|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Kathmandu", 1714435200000L),
    "1714457700000",
  ) // 腿 C N2.apr31.1714435200000.Asia/Kathmandu|参照读数 1714457700000（UTC 串 2024-04-30 06:15:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 1714435200000L),
    "1714440600000",
  ) // 腿 C N2.apr31.1714435200000.Australia/Lord_Howe|参照读数 1714440600000（UTC 串 2024-04-30 01:30:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/Santiago", 1714435200000L),
    "1714492800000",
  ) // 腿 C N2.apr31.1714435200000.America/Santiago|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Tehran", 1714435200000L),
    "1714465800000",
  ) // 腿 C N2.apr31.1714435200000.Asia/Tehran|参照读数 1714465800000（UTC 串 2024-04-30 08:30:00）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 515554200000L), "546782400000") // 腿 C N2.apr31.515554200000.UTC|参照读数 546782400000（UTC 串 1987-04-30 12:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Shanghai", 515554200000L),
    "546750000000",
  ) // 腿 C N2.apr31.515554200000.Asia/Shanghai|参照读数 546750000000（UTC 串 1987-04-30 03:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/New_York", 515554200000L),
    "546796800000",
  ) // 腿 C N2.apr31.515554200000.America/New_York|参照读数 546796800000（UTC 串 1987-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Kathmandu", 515554200000L),
    "546761700000",
  ) // 腿 C N2.apr31.515554200000.Asia/Kathmandu|参照读数 546761700000（UTC 串 1987-04-30 06:15:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 515554200000L),
    "546744600000",
  ) // 腿 C N2.apr31.515554200000.Australia/Lord_Howe|参照读数 546744600000（UTC 串 1987-04-30 01:30:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/Santiago", 515554200000L),
    "546796800000",
  ) // 腿 C N2.apr31.515554200000.America/Santiago|参照读数 546796800000（UTC 串 1987-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Tehran", 515554200000L),
    "546769800000",
  ) // 腿 C N2.apr31.515554200000.Asia/Tehran|参照读数 546769800000（UTC 串 1987-04-30 08:30:00）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 4070822400000L), "null") // 腿 C N2.apr31.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4081233600000｜UTC 2099-04-30 12:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 12 31 4 *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N2.apr31.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4081204800000｜UTC 2099-04-30 04:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 12 31 4 *", "America/New_York", 4070822400000L), "null") // 腿 C N2.apr31.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4081248000000｜UTC 2099-04-30 16:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 12 31 4 *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N2.apr31.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4081212900000｜UTC 2099-04-30 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N2.apr31.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4081195800000｜UTC 2099-04-30 01:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 12 31 4 *", "America/Santiago", 4070822400000L), "null") // 腿 C N2.apr31.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4081248000000｜UTC 2099-04-30 16:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 12 31 4 *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.apr31.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4081221000000｜UTC 2099-04-30 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 1730606400000L), "1746014400000") // 腿 C N2.apr31.1730606400000.UTC|参照读数 1746014400000（UTC 串 2025-04-30 12:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Shanghai", 1730606400000L),
    "1745985600000",
  ) // 腿 C N2.apr31.1730606400000.Asia/Shanghai|参照读数 1745985600000（UTC 串 2025-04-30 04:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/New_York", 1730606400000L),
    "1746028800000",
  ) // 腿 C N2.apr31.1730606400000.America/New_York|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Kathmandu", 1730606400000L),
    "1745993700000",
  ) // 腿 C N2.apr31.1730606400000.Asia/Kathmandu|参照读数 1745993700000（UTC 串 2025-04-30 06:15:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 1730606400000L),
    "1745976600000",
  ) // 腿 C N2.apr31.1730606400000.Australia/Lord_Howe|参照读数 1745976600000（UTC 串 2025-04-30 01:30:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/Santiago", 1730606400000L),
    "1746028800000",
  ) // 腿 C N2.apr31.1730606400000.America/Santiago|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Tehran", 1730606400000L),
    "1746001800000",
  ) // 腿 C N2.apr31.1730606400000.Asia/Tehran|参照读数 1746001800000（UTC 串 2025-04-30 08:30:00）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 1709985600000L), "1714478400000") // 腿 C N2.apr31.1709985600000.UTC|参照读数 1714478400000（UTC 串 2024-04-30 12:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Shanghai", 1709985600000L),
    "1714449600000",
  ) // 腿 C N2.apr31.1709985600000.Asia/Shanghai|参照读数 1714449600000（UTC 串 2024-04-30 04:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/New_York", 1709985600000L),
    "1714492800000",
  ) // 腿 C N2.apr31.1709985600000.America/New_York|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Kathmandu", 1709985600000L),
    "1714457700000",
  ) // 腿 C N2.apr31.1709985600000.Asia/Kathmandu|参照读数 1714457700000（UTC 串 2024-04-30 06:15:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 1709985600000L),
    "1714440600000",
  ) // 腿 C N2.apr31.1709985600000.Australia/Lord_Howe|参照读数 1714440600000（UTC 串 2024-04-30 01:30:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/Santiago", 1709985600000L),
    "1714492800000",
  ) // 腿 C N2.apr31.1709985600000.America/Santiago|参照读数 1714492800000（UTC 串 2024-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Tehran", 1709985600000L),
    "1714465800000",
  ) // 腿 C N2.apr31.1709985600000.Asia/Tehran|参照读数 1714465800000（UTC 串 2024-04-30 08:30:00）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 1730548800000L), "1746014400000") // 腿 C N2.apr31.1730548800000.UTC|参照读数 1746014400000（UTC 串 2025-04-30 12:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Shanghai", 1730548800000L),
    "1745985600000",
  ) // 腿 C N2.apr31.1730548800000.Asia/Shanghai|参照读数 1745985600000（UTC 串 2025-04-30 04:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/New_York", 1730548800000L),
    "1746028800000",
  ) // 腿 C N2.apr31.1730548800000.America/New_York|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Kathmandu", 1730548800000L),
    "1745993700000",
  ) // 腿 C N2.apr31.1730548800000.Asia/Kathmandu|参照读数 1745993700000（UTC 串 2025-04-30 06:15:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 1730548800000L),
    "1745976600000",
  ) // 腿 C N2.apr31.1730548800000.Australia/Lord_Howe|参照读数 1745976600000（UTC 串 2025-04-30 01:30:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/Santiago", 1730548800000L),
    "1746028800000",
  ) // 腿 C N2.apr31.1730548800000.America/Santiago|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Tehran", 1730548800000L),
    "1746001800000",
  ) // 腿 C N2.apr31.1730548800000.Asia/Tehran|参照读数 1746001800000（UTC 串 2025-04-30 08:30:00）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 515505600000L), "546782400000") // 腿 C N2.apr31.515505600000.UTC|参照读数 546782400000（UTC 串 1987-04-30 12:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Shanghai", 515505600000L),
    "546750000000",
  ) // 腿 C N2.apr31.515505600000.Asia/Shanghai|参照读数 546750000000（UTC 串 1987-04-30 03:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/New_York", 515505600000L),
    "546796800000",
  ) // 腿 C N2.apr31.515505600000.America/New_York|参照读数 546796800000（UTC 串 1987-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Kathmandu", 515505600000L),
    "546761700000",
  ) // 腿 C N2.apr31.515505600000.Asia/Kathmandu|参照读数 546761700000（UTC 串 1987-04-30 06:15:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 515505600000L),
    "546744600000",
  ) // 腿 C N2.apr31.515505600000.Australia/Lord_Howe|参照读数 546744600000（UTC 串 1987-04-30 01:30:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/Santiago", 515505600000L),
    "546796800000",
  ) // 腿 C N2.apr31.515505600000.America/Santiago|参照读数 546796800000（UTC 串 1987-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Tehran", 515505600000L),
    "546769800000",
  ) // 腿 C N2.apr31.515505600000.Asia/Tehran|参照读数 546769800000（UTC 串 1987-04-30 08:30:00）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 1725710400000L), "1746014400000") // 腿 C N2.apr31.1725710400000.UTC|参照读数 1746014400000（UTC 串 2025-04-30 12:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Shanghai", 1725710400000L),
    "1745985600000",
  ) // 腿 C N2.apr31.1725710400000.Asia/Shanghai|参照读数 1745985600000（UTC 串 2025-04-30 04:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/New_York", 1725710400000L),
    "1746028800000",
  ) // 腿 C N2.apr31.1725710400000.America/New_York|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Kathmandu", 1725710400000L),
    "1745993700000",
  ) // 腿 C N2.apr31.1725710400000.Asia/Kathmandu|参照读数 1745993700000（UTC 串 2025-04-30 06:15:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 1725710400000L),
    "1745976600000",
  ) // 腿 C N2.apr31.1725710400000.Australia/Lord_Howe|参照读数 1745976600000（UTC 串 2025-04-30 01:30:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/Santiago", 1725710400000L),
    "1746028800000",
  ) // 腿 C N2.apr31.1725710400000.America/Santiago|参照读数 1746028800000（UTC 串 2025-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Tehran", 1725710400000L),
    "1746001800000",
  ) // 腿 C N2.apr31.1725710400000.Asia/Tehran|参照读数 1746001800000（UTC 串 2025-04-30 08:30:00）
  assert_eq(znm_tag("0 12 31 4 *", "UTC", 1647864000000L), "1651320000000") // 腿 C N2.apr31.1647864000000.UTC|参照读数 1651320000000（UTC 串 2022-04-30 12:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Shanghai", 1647864000000L),
    "1651291200000",
  ) // 腿 C N2.apr31.1647864000000.Asia/Shanghai|参照读数 1651291200000（UTC 串 2022-04-30 04:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/New_York", 1647864000000L),
    "1651334400000",
  ) // 腿 C N2.apr31.1647864000000.America/New_York|参照读数 1651334400000（UTC 串 2022-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Kathmandu", 1647864000000L),
    "1651299300000",
  ) // 腿 C N2.apr31.1647864000000.Asia/Kathmandu|参照读数 1651299300000（UTC 串 2022-04-30 06:15:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Australia/Lord_Howe", 1647864000000L),
    "1651282200000",
  ) // 腿 C N2.apr31.1647864000000.Australia/Lord_Howe|参照读数 1651282200000（UTC 串 2022-04-30 01:30:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "America/Santiago", 1647864000000L),
    "1651334400000",
  ) // 腿 C N2.apr31.1647864000000.America/Santiago|参照读数 1651334400000（UTC 串 2022-04-30 16:00:00）
  assert_eq(
    znm_tag("0 12 31 4 *", "Asia/Tehran", 1647864000000L),
    "1651303800000",
  ) // 腿 C N2.apr31.1647864000000.Asia/Tehran|参照读数 1651303800000（UTC 串 2022-04-30 07:30:00）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 1710050400000L), "1711843200000") // 腿 C N2.last_day.1710050400000.UTC|参照读数 1711843200000（UTC 串 2024-03-31 00:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Shanghai", 1710050400000L),
    "1711814400000",
  ) // 腿 C N2.last_day.1710050400000.Asia/Shanghai|参照读数 1711814400000（UTC 串 2024-03-30 16:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/New_York", 1710050400000L),
    "1711857600000",
  ) // 腿 C N2.last_day.1710050400000.America/New_York|参照读数 1711857600000（UTC 串 2024-03-31 04:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Kathmandu", 1710050400000L),
    "1711822500000",
  ) // 腿 C N2.last_day.1710050400000.Asia/Kathmandu|参照读数 1711822500000（UTC 串 2024-03-30 18:15:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 1710050400000L),
    "1711803600000",
  ) // 腿 C N2.last_day.1710050400000.Australia/Lord_Howe|参照读数 1711803600000（UTC 串 2024-03-30 13:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/Santiago", 1710050400000L),
    "1711854000000",
  ) // 腿 C N2.last_day.1710050400000.America/Santiago|参照读数 1711854000000（UTC 串 2024-03-31 03:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Tehran", 1710050400000L),
    "1711830600000",
  ) // 腿 C N2.last_day.1710050400000.Asia/Tehran|参照读数 1711830600000（UTC 串 2024-03-30 20:30:00）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 1730611800000L), "1732924800000") // 腿 C N2.last_day.1730611800000.UTC|参照读数 1732924800000（UTC 串 2024-11-30 00:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Shanghai", 1730611800000L),
    "1732896000000",
  ) // 腿 C N2.last_day.1730611800000.Asia/Shanghai|参照读数 1732896000000（UTC 串 2024-11-29 16:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/New_York", 1730611800000L),
    "1732942800000",
  ) // 腿 C N2.last_day.1730611800000.America/New_York|参照读数 1732942800000（UTC 串 2024-11-30 05:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Kathmandu", 1730611800000L),
    "1732904100000",
  ) // 腿 C N2.last_day.1730611800000.Asia/Kathmandu|参照读数 1732904100000（UTC 串 2024-11-29 18:15:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 1730611800000L),
    "1732885200000",
  ) // 腿 C N2.last_day.1730611800000.Australia/Lord_Howe|参照读数 1732885200000（UTC 串 2024-11-29 13:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/Santiago", 1730611800000L),
    "1732935600000",
  ) // 腿 C N2.last_day.1730611800000.America/Santiago|参照读数 1732935600000（UTC 串 2024-11-30 03:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Tehran", 1730611800000L),
    "1732912200000",
  ) // 腿 C N2.last_day.1730611800000.Asia/Tehran|参照读数 1732912200000（UTC 串 2024-11-29 20:30:00）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 1730615400000L), "1732924800000") // 腿 C N2.last_day.1730615400000.UTC|参照读数 1732924800000（UTC 串 2024-11-30 00:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Shanghai", 1730615400000L),
    "1732896000000",
  ) // 腿 C N2.last_day.1730615400000.Asia/Shanghai|参照读数 1732896000000（UTC 串 2024-11-29 16:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/New_York", 1730615400000L),
    "1732942800000",
  ) // 腿 C N2.last_day.1730615400000.America/New_York|参照读数 1732942800000（UTC 串 2024-11-30 05:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Kathmandu", 1730615400000L),
    "1732904100000",
  ) // 腿 C N2.last_day.1730615400000.Asia/Kathmandu|参照读数 1732904100000（UTC 串 2024-11-29 18:15:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 1730615400000L),
    "1732885200000",
  ) // 腿 C N2.last_day.1730615400000.Australia/Lord_Howe|参照读数 1732885200000（UTC 串 2024-11-29 13:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/Santiago", 1730615400000L),
    "1732935600000",
  ) // 腿 C N2.last_day.1730615400000.America/Santiago|参照读数 1732935600000（UTC 串 2024-11-30 03:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Tehran", 1730615400000L),
    "1732912200000",
  ) // 腿 C N2.last_day.1730615400000.Asia/Tehran|参照读数 1732912200000（UTC 串 2024-11-29 20:30:00）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 1709208000000L), "1711843200000") // 腿 C N2.last_day.1709208000000.UTC|参照读数 1711843200000（UTC 串 2024-03-31 00:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Shanghai", 1709208000000L),
    "1711814400000",
  ) // 腿 C N2.last_day.1709208000000.Asia/Shanghai|参照读数 1711814400000（UTC 串 2024-03-30 16:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/New_York", 1709208000000L),
    "1711857600000",
  ) // 腿 C N2.last_day.1709208000000.America/New_York|参照读数 1711857600000（UTC 串 2024-03-31 04:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Kathmandu", 1709208000000L),
    "1711822500000",
  ) // 腿 C N2.last_day.1709208000000.Asia/Kathmandu|参照读数 1711822500000（UTC 串 2024-03-30 18:15:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 1709208000000L),
    "1711803600000",
  ) // 腿 C N2.last_day.1709208000000.Australia/Lord_Howe|参照读数 1711803600000（UTC 串 2024-03-30 13:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/Santiago", 1709208000000L),
    "1711854000000",
  ) // 腿 C N2.last_day.1709208000000.America/Santiago|参照读数 1711854000000（UTC 串 2024-03-31 03:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Tehran", 1709208000000L),
    "1711830600000",
  ) // 腿 C N2.last_day.1709208000000.Asia/Tehran|参照读数 1711830600000（UTC 串 2024-03-30 20:30:00）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 1714435200000L), "1714435200000") // 腿 C N2.last_day.1714435200000.UTC|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Shanghai", 1714435200000L),
    "1717084800000",
  ) // 腿 C N2.last_day.1714435200000.Asia/Shanghai|参照读数 1717084800000（UTC 串 2024-05-30 16:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/New_York", 1714435200000L),
    "1714449600000",
  ) // 腿 C N2.last_day.1714435200000.America/New_York|参照读数 1714449600000（UTC 串 2024-04-30 04:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Kathmandu", 1714435200000L),
    "1717092900000",
  ) // 腿 C N2.last_day.1714435200000.Asia/Kathmandu|参照读数 1717092900000（UTC 串 2024-05-30 18:15:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 1714435200000L),
    "1717075800000",
  ) // 腿 C N2.last_day.1714435200000.Australia/Lord_Howe|参照读数 1717075800000（UTC 串 2024-05-30 13:30:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/Santiago", 1714435200000L),
    "1714449600000",
  ) // 腿 C N2.last_day.1714435200000.America/Santiago|参照读数 1714449600000（UTC 串 2024-04-30 04:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Tehran", 1714435200000L),
    "1717101000000",
  ) // 腿 C N2.last_day.1714435200000.Asia/Tehran|参照读数 1717101000000（UTC 串 2024-05-30 20:30:00）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 515554200000L), "517881600000") // 腿 C N2.last_day.515554200000.UTC|参照读数 517881600000（UTC 串 1986-05-31 00:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Shanghai", 515554200000L),
    "517849200000",
  ) // 腿 C N2.last_day.515554200000.Asia/Shanghai|参照读数 517849200000（UTC 串 1986-05-30 15:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/New_York", 515554200000L),
    "517896000000",
  ) // 腿 C N2.last_day.515554200000.America/New_York|参照读数 517896000000（UTC 串 1986-05-31 04:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Kathmandu", 515554200000L),
    "517860900000",
  ) // 腿 C N2.last_day.515554200000.Asia/Kathmandu|参照读数 517860900000（UTC 串 1986-05-30 18:15:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 515554200000L),
    "517843800000",
  ) // 腿 C N2.last_day.515554200000.Australia/Lord_Howe|参照读数 517843800000（UTC 串 1986-05-30 13:30:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/Santiago", 515554200000L),
    "517896000000",
  ) // 腿 C N2.last_day.515554200000.America/Santiago|参照读数 517896000000（UTC 串 1986-05-31 04:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Tehran", 515554200000L),
    "517869000000",
  ) // 腿 C N2.last_day.515554200000.Asia/Tehran|参照读数 517869000000（UTC 串 1986-05-30 20:30:00）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 4070822400000L), "null") // 腿 C N2.last_day.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 L * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N2.last_day.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4073472000000｜UTC 2099-01-30 16:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 L * *", "America/New_York", 4070822400000L), "null") // 腿 C N2.last_day.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070840400000｜UTC 2098-12-31 05:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 L * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N2.last_day.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4073480100000｜UTC 2099-01-30 18:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N2.last_day.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4073461200000｜UTC 2099-01-30 13:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 L * *", "America/Santiago", 4070822400000L), "null") // 腿 C N2.last_day.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070833200000｜UTC 2098-12-31 03:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 L * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.last_day.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4073488200000｜UTC 2099-01-30 20:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 1730606400000L), "1732924800000") // 腿 C N2.last_day.1730606400000.UTC|参照读数 1732924800000（UTC 串 2024-11-30 00:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Shanghai", 1730606400000L),
    "1732896000000",
  ) // 腿 C N2.last_day.1730606400000.Asia/Shanghai|参照读数 1732896000000（UTC 串 2024-11-29 16:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/New_York", 1730606400000L),
    "1732942800000",
  ) // 腿 C N2.last_day.1730606400000.America/New_York|参照读数 1732942800000（UTC 串 2024-11-30 05:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Kathmandu", 1730606400000L),
    "1732904100000",
  ) // 腿 C N2.last_day.1730606400000.Asia/Kathmandu|参照读数 1732904100000（UTC 串 2024-11-29 18:15:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 1730606400000L),
    "1732885200000",
  ) // 腿 C N2.last_day.1730606400000.Australia/Lord_Howe|参照读数 1732885200000（UTC 串 2024-11-29 13:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/Santiago", 1730606400000L),
    "1732935600000",
  ) // 腿 C N2.last_day.1730606400000.America/Santiago|参照读数 1732935600000（UTC 串 2024-11-30 03:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Tehran", 1730606400000L),
    "1732912200000",
  ) // 腿 C N2.last_day.1730606400000.Asia/Tehran|参照读数 1732912200000（UTC 串 2024-11-29 20:30:00）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 1709985600000L), "1711843200000") // 腿 C N2.last_day.1709985600000.UTC|参照读数 1711843200000（UTC 串 2024-03-31 00:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Shanghai", 1709985600000L),
    "1711814400000",
  ) // 腿 C N2.last_day.1709985600000.Asia/Shanghai|参照读数 1711814400000（UTC 串 2024-03-30 16:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/New_York", 1709985600000L),
    "1711857600000",
  ) // 腿 C N2.last_day.1709985600000.America/New_York|参照读数 1711857600000（UTC 串 2024-03-31 04:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Kathmandu", 1709985600000L),
    "1711822500000",
  ) // 腿 C N2.last_day.1709985600000.Asia/Kathmandu|参照读数 1711822500000（UTC 串 2024-03-30 18:15:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 1709985600000L),
    "1711803600000",
  ) // 腿 C N2.last_day.1709985600000.Australia/Lord_Howe|参照读数 1711803600000（UTC 串 2024-03-30 13:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/Santiago", 1709985600000L),
    "1711854000000",
  ) // 腿 C N2.last_day.1709985600000.America/Santiago|参照读数 1711854000000（UTC 串 2024-03-31 03:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Tehran", 1709985600000L),
    "1711830600000",
  ) // 腿 C N2.last_day.1709985600000.Asia/Tehran|参照读数 1711830600000（UTC 串 2024-03-30 20:30:00）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 1730548800000L), "1732924800000") // 腿 C N2.last_day.1730548800000.UTC|参照读数 1732924800000（UTC 串 2024-11-30 00:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Shanghai", 1730548800000L),
    "1732896000000",
  ) // 腿 C N2.last_day.1730548800000.Asia/Shanghai|参照读数 1732896000000（UTC 串 2024-11-29 16:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/New_York", 1730548800000L),
    "1732942800000",
  ) // 腿 C N2.last_day.1730548800000.America/New_York|参照读数 1732942800000（UTC 串 2024-11-30 05:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Kathmandu", 1730548800000L),
    "1732904100000",
  ) // 腿 C N2.last_day.1730548800000.Asia/Kathmandu|参照读数 1732904100000（UTC 串 2024-11-29 18:15:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 1730548800000L),
    "1732885200000",
  ) // 腿 C N2.last_day.1730548800000.Australia/Lord_Howe|参照读数 1732885200000（UTC 串 2024-11-29 13:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/Santiago", 1730548800000L),
    "1732935600000",
  ) // 腿 C N2.last_day.1730548800000.America/Santiago|参照读数 1732935600000（UTC 串 2024-11-30 03:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Tehran", 1730548800000L),
    "1732912200000",
  ) // 腿 C N2.last_day.1730548800000.Asia/Tehran|参照读数 1732912200000（UTC 串 2024-11-29 20:30:00）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 515505600000L), "517881600000") // 腿 C N2.last_day.515505600000.UTC|参照读数 517881600000（UTC 串 1986-05-31 00:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Shanghai", 515505600000L),
    "517849200000",
  ) // 腿 C N2.last_day.515505600000.Asia/Shanghai|参照读数 517849200000（UTC 串 1986-05-30 15:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/New_York", 515505600000L),
    "517896000000",
  ) // 腿 C N2.last_day.515505600000.America/New_York|参照读数 517896000000（UTC 串 1986-05-31 04:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Kathmandu", 515505600000L),
    "517860900000",
  ) // 腿 C N2.last_day.515505600000.Asia/Kathmandu|参照读数 517860900000（UTC 串 1986-05-30 18:15:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 515505600000L),
    "517843800000",
  ) // 腿 C N2.last_day.515505600000.Australia/Lord_Howe|参照读数 517843800000（UTC 串 1986-05-30 13:30:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/Santiago", 515505600000L),
    "517896000000",
  ) // 腿 C N2.last_day.515505600000.America/Santiago|参照读数 517896000000（UTC 串 1986-05-31 04:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Tehran", 515505600000L),
    "517869000000",
  ) // 腿 C N2.last_day.515505600000.Asia/Tehran|参照读数 517869000000（UTC 串 1986-05-30 20:30:00）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 1725710400000L), "1727654400000") // 腿 C N2.last_day.1725710400000.UTC|参照读数 1727654400000（UTC 串 2024-09-30 00:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Shanghai", 1725710400000L),
    "1727625600000",
  ) // 腿 C N2.last_day.1725710400000.Asia/Shanghai|参照读数 1727625600000（UTC 串 2024-09-29 16:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/New_York", 1725710400000L),
    "1727668800000",
  ) // 腿 C N2.last_day.1725710400000.America/New_York|参照读数 1727668800000（UTC 串 2024-09-30 04:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Kathmandu", 1725710400000L),
    "1727633700000",
  ) // 腿 C N2.last_day.1725710400000.Asia/Kathmandu|参照读数 1727633700000（UTC 串 2024-09-29 18:15:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 1725710400000L),
    "1727616600000",
  ) // 腿 C N2.last_day.1725710400000.Australia/Lord_Howe|参照读数 1727616600000（UTC 串 2024-09-29 13:30:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/Santiago", 1725710400000L),
    "1727665200000",
  ) // 腿 C N2.last_day.1725710400000.America/Santiago|参照读数 1727665200000（UTC 串 2024-09-30 03:00:00）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znm_tag 行，已匹配给自身/末支，第 5 块 180 条）" {
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Tehran", 1725710400000L),
    "1727641800000",
  ) // 腿 C N2.last_day.1725710400000.Asia/Tehran|参照读数 1727641800000（UTC 串 2024-09-29 20:30:00）
  assert_eq(znm_tag("0 0 0 L * *", "UTC", 1647864000000L), "1648684800000") // 腿 C N2.last_day.1647864000000.UTC|参照读数 1648684800000（UTC 串 2022-03-31 00:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Shanghai", 1647864000000L),
    "1648656000000",
  ) // 腿 C N2.last_day.1647864000000.Asia/Shanghai|参照读数 1648656000000（UTC 串 2022-03-30 16:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/New_York", 1647864000000L),
    "1648699200000",
  ) // 腿 C N2.last_day.1647864000000.America/New_York|参照读数 1648699200000（UTC 串 2022-03-31 04:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Kathmandu", 1647864000000L),
    "1648664100000",
  ) // 腿 C N2.last_day.1647864000000.Asia/Kathmandu|参照读数 1648664100000（UTC 串 2022-03-30 18:15:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Australia/Lord_Howe", 1647864000000L),
    "1648645200000",
  ) // 腿 C N2.last_day.1647864000000.Australia/Lord_Howe|参照读数 1648645200000（UTC 串 2022-03-30 13:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "America/Santiago", 1647864000000L),
    "1648695600000",
  ) // 腿 C N2.last_day.1647864000000.America/Santiago|参照读数 1648695600000（UTC 串 2022-03-31 03:00:00）
  assert_eq(
    znm_tag("0 0 0 L * *", "Asia/Tehran", 1647864000000L),
    "1648668600000",
  ) // 腿 C N2.last_day.1647864000000.Asia/Tehran|参照读数 1648668600000（UTC 串 2022-03-30 19:30:00）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 1710050400000L), "1711972800000") // 腿 C N2.dom_and_dow.1710050400000.UTC|参照读数 1711972800000（UTC 串 2024-04-01 12:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Shanghai", 1710050400000L),
    "1711944000000",
  ) // 腿 C N2.dom_and_dow.1710050400000.Asia/Shanghai|参照读数 1711944000000（UTC 串 2024-04-01 04:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/New_York", 1710050400000L),
    "1711987200000",
  ) // 腿 C N2.dom_and_dow.1710050400000.America/New_York|参照读数 1711987200000（UTC 串 2024-04-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Kathmandu", 1710050400000L),
    "1711952100000",
  ) // 腿 C N2.dom_and_dow.1710050400000.Asia/Kathmandu|参照读数 1711952100000（UTC 串 2024-04-01 06:15:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 1710050400000L),
    "1711933200000",
  ) // 腿 C N2.dom_and_dow.1710050400000.Australia/Lord_Howe|参照读数 1711933200000（UTC 串 2024-04-01 01:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/Santiago", 1710050400000L),
    "1711983600000",
  ) // 腿 C N2.dom_and_dow.1710050400000.America/Santiago|参照读数 1711983600000（UTC 串 2024-04-01 15:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Tehran", 1710050400000L),
    "1711960200000",
  ) // 腿 C N2.dom_and_dow.1710050400000.Asia/Tehran|参照读数 1711960200000（UTC 串 2024-04-01 08:30:00）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 1730611800000L), "1756728000000") // 腿 C N2.dom_and_dow.1730611800000.UTC|参照读数 1756728000000（UTC 串 2025-09-01 12:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Shanghai", 1730611800000L),
    "1756699200000",
  ) // 腿 C N2.dom_and_dow.1730611800000.Asia/Shanghai|参照读数 1756699200000（UTC 串 2025-09-01 04:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/New_York", 1730611800000L),
    "1756742400000",
  ) // 腿 C N2.dom_and_dow.1730611800000.America/New_York|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Kathmandu", 1730611800000L),
    "1756707300000",
  ) // 腿 C N2.dom_and_dow.1730611800000.Asia/Kathmandu|参照读数 1756707300000（UTC 串 2025-09-01 06:15:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 1730611800000L),
    "1756690200000",
  ) // 腿 C N2.dom_and_dow.1730611800000.Australia/Lord_Howe|参照读数 1756690200000（UTC 串 2025-09-01 01:30:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/Santiago", 1730611800000L),
    "1756742400000",
  ) // 腿 C N2.dom_and_dow.1730611800000.America/Santiago|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Tehran", 1730611800000L),
    "1756715400000",
  ) // 腿 C N2.dom_and_dow.1730611800000.Asia/Tehran|参照读数 1756715400000（UTC 串 2025-09-01 08:30:00）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 1730615400000L), "1756728000000") // 腿 C N2.dom_and_dow.1730615400000.UTC|参照读数 1756728000000（UTC 串 2025-09-01 12:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Shanghai", 1730615400000L),
    "1756699200000",
  ) // 腿 C N2.dom_and_dow.1730615400000.Asia/Shanghai|参照读数 1756699200000（UTC 串 2025-09-01 04:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/New_York", 1730615400000L),
    "1756742400000",
  ) // 腿 C N2.dom_and_dow.1730615400000.America/New_York|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Kathmandu", 1730615400000L),
    "1756707300000",
  ) // 腿 C N2.dom_and_dow.1730615400000.Asia/Kathmandu|参照读数 1756707300000（UTC 串 2025-09-01 06:15:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 1730615400000L),
    "1756690200000",
  ) // 腿 C N2.dom_and_dow.1730615400000.Australia/Lord_Howe|参照读数 1756690200000（UTC 串 2025-09-01 01:30:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/Santiago", 1730615400000L),
    "1756742400000",
  ) // 腿 C N2.dom_and_dow.1730615400000.America/Santiago|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Tehran", 1730615400000L),
    "1756715400000",
  ) // 腿 C N2.dom_and_dow.1730615400000.Asia/Tehran|参照读数 1756715400000（UTC 串 2025-09-01 08:30:00）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 1709208000000L), "1711972800000") // 腿 C N2.dom_and_dow.1709208000000.UTC|参照读数 1711972800000（UTC 串 2024-04-01 12:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Shanghai", 1709208000000L),
    "1711944000000",
  ) // 腿 C N2.dom_and_dow.1709208000000.Asia/Shanghai|参照读数 1711944000000（UTC 串 2024-04-01 04:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/New_York", 1709208000000L),
    "1711987200000",
  ) // 腿 C N2.dom_and_dow.1709208000000.America/New_York|参照读数 1711987200000（UTC 串 2024-04-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Kathmandu", 1709208000000L),
    "1711952100000",
  ) // 腿 C N2.dom_and_dow.1709208000000.Asia/Kathmandu|参照读数 1711952100000（UTC 串 2024-04-01 06:15:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 1709208000000L),
    "1711933200000",
  ) // 腿 C N2.dom_and_dow.1709208000000.Australia/Lord_Howe|参照读数 1711933200000（UTC 串 2024-04-01 01:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/Santiago", 1709208000000L),
    "1711983600000",
  ) // 腿 C N2.dom_and_dow.1709208000000.America/Santiago|参照读数 1711983600000（UTC 串 2024-04-01 15:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Tehran", 1709208000000L),
    "1711960200000",
  ) // 腿 C N2.dom_and_dow.1709208000000.Asia/Tehran|参照读数 1711960200000（UTC 串 2024-04-01 08:30:00）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 1714435200000L), "1719835200000") // 腿 C N2.dom_and_dow.1714435200000.UTC|参照读数 1719835200000（UTC 串 2024-07-01 12:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Shanghai", 1714435200000L),
    "1719806400000",
  ) // 腿 C N2.dom_and_dow.1714435200000.Asia/Shanghai|参照读数 1719806400000（UTC 串 2024-07-01 04:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/New_York", 1714435200000L),
    "1719849600000",
  ) // 腿 C N2.dom_and_dow.1714435200000.America/New_York|参照读数 1719849600000（UTC 串 2024-07-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Kathmandu", 1714435200000L),
    "1719814500000",
  ) // 腿 C N2.dom_and_dow.1714435200000.Asia/Kathmandu|参照读数 1719814500000（UTC 串 2024-07-01 06:15:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 1714435200000L),
    "1719797400000",
  ) // 腿 C N2.dom_and_dow.1714435200000.Australia/Lord_Howe|参照读数 1719797400000（UTC 串 2024-07-01 01:30:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/Santiago", 1714435200000L),
    "1719849600000",
  ) // 腿 C N2.dom_and_dow.1714435200000.America/Santiago|参照读数 1719849600000（UTC 串 2024-07-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Tehran", 1714435200000L),
    "1719822600000",
  ) // 腿 C N2.dom_and_dow.1714435200000.Asia/Tehran|参照读数 1719822600000（UTC 串 2024-07-01 08:30:00）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 515554200000L), "525960000000") // 腿 C N2.dom_and_dow.515554200000.UTC|参照读数 525960000000（UTC 串 1986-09-01 12:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Shanghai", 515554200000L),
    "525927600000",
  ) // 腿 C N2.dom_and_dow.515554200000.Asia/Shanghai|参照读数 525927600000（UTC 串 1986-09-01 03:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/New_York", 515554200000L),
    "525974400000",
  ) // 腿 C N2.dom_and_dow.515554200000.America/New_York|参照读数 525974400000（UTC 串 1986-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Kathmandu", 515554200000L),
    "525939300000",
  ) // 腿 C N2.dom_and_dow.515554200000.Asia/Kathmandu|参照读数 525939300000（UTC 串 1986-09-01 06:15:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 515554200000L),
    "525922200000",
  ) // 腿 C N2.dom_and_dow.515554200000.Australia/Lord_Howe|参照读数 525922200000（UTC 串 1986-09-01 01:30:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/Santiago", 515554200000L),
    "525974400000",
  ) // 腿 C N2.dom_and_dow.515554200000.America/Santiago|参照读数 525974400000（UTC 串 1986-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Tehran", 515554200000L),
    "525947400000",
  ) // 腿 C N2.dom_and_dow.515554200000.Asia/Tehran|参照读数 525947400000（UTC 串 1986-09-01 08:30:00）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 4070822400000L), "null") // 腿 C N2.dom_and_dow.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4083998400000｜UTC 2099-06-01 12:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 12 1 * MON", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N2.dom_and_dow.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4083969600000｜UTC 2099-06-01 04:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 12 1 * MON", "America/New_York", 4070822400000L), "null") // 腿 C N2.dom_and_dow.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4084012800000｜UTC 2099-06-01 16:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 12 1 * MON", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N2.dom_and_dow.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4083977700000｜UTC 2099-06-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N2.dom_and_dow.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4083960600000｜UTC 2099-06-01 01:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 12 1 * MON", "America/Santiago", 4070822400000L), "null") // 腿 C N2.dom_and_dow.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4084012800000｜UTC 2099-06-01 16:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 12 1 * MON", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.dom_and_dow.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4083985800000｜UTC 2099-06-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 1730606400000L), "1756728000000") // 腿 C N2.dom_and_dow.1730606400000.UTC|参照读数 1756728000000（UTC 串 2025-09-01 12:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Shanghai", 1730606400000L),
    "1756699200000",
  ) // 腿 C N2.dom_and_dow.1730606400000.Asia/Shanghai|参照读数 1756699200000（UTC 串 2025-09-01 04:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/New_York", 1730606400000L),
    "1756742400000",
  ) // 腿 C N2.dom_and_dow.1730606400000.America/New_York|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Kathmandu", 1730606400000L),
    "1756707300000",
  ) // 腿 C N2.dom_and_dow.1730606400000.Asia/Kathmandu|参照读数 1756707300000（UTC 串 2025-09-01 06:15:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 1730606400000L),
    "1756690200000",
  ) // 腿 C N2.dom_and_dow.1730606400000.Australia/Lord_Howe|参照读数 1756690200000（UTC 串 2025-09-01 01:30:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/Santiago", 1730606400000L),
    "1756742400000",
  ) // 腿 C N2.dom_and_dow.1730606400000.America/Santiago|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Tehran", 1730606400000L),
    "1756715400000",
  ) // 腿 C N2.dom_and_dow.1730606400000.Asia/Tehran|参照读数 1756715400000（UTC 串 2025-09-01 08:30:00）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 1709985600000L), "1711972800000") // 腿 C N2.dom_and_dow.1709985600000.UTC|参照读数 1711972800000（UTC 串 2024-04-01 12:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Shanghai", 1709985600000L),
    "1711944000000",
  ) // 腿 C N2.dom_and_dow.1709985600000.Asia/Shanghai|参照读数 1711944000000（UTC 串 2024-04-01 04:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/New_York", 1709985600000L),
    "1711987200000",
  ) // 腿 C N2.dom_and_dow.1709985600000.America/New_York|参照读数 1711987200000（UTC 串 2024-04-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Kathmandu", 1709985600000L),
    "1711952100000",
  ) // 腿 C N2.dom_and_dow.1709985600000.Asia/Kathmandu|参照读数 1711952100000（UTC 串 2024-04-01 06:15:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 1709985600000L),
    "1711933200000",
  ) // 腿 C N2.dom_and_dow.1709985600000.Australia/Lord_Howe|参照读数 1711933200000（UTC 串 2024-04-01 01:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/Santiago", 1709985600000L),
    "1711983600000",
  ) // 腿 C N2.dom_and_dow.1709985600000.America/Santiago|参照读数 1711983600000（UTC 串 2024-04-01 15:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Tehran", 1709985600000L),
    "1711960200000",
  ) // 腿 C N2.dom_and_dow.1709985600000.Asia/Tehran|参照读数 1711960200000（UTC 串 2024-04-01 08:30:00）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 1730548800000L), "1756728000000") // 腿 C N2.dom_and_dow.1730548800000.UTC|参照读数 1756728000000（UTC 串 2025-09-01 12:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Shanghai", 1730548800000L),
    "1756699200000",
  ) // 腿 C N2.dom_and_dow.1730548800000.Asia/Shanghai|参照读数 1756699200000（UTC 串 2025-09-01 04:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/New_York", 1730548800000L),
    "1756742400000",
  ) // 腿 C N2.dom_and_dow.1730548800000.America/New_York|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Kathmandu", 1730548800000L),
    "1756707300000",
  ) // 腿 C N2.dom_and_dow.1730548800000.Asia/Kathmandu|参照读数 1756707300000（UTC 串 2025-09-01 06:15:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 1730548800000L),
    "1756690200000",
  ) // 腿 C N2.dom_and_dow.1730548800000.Australia/Lord_Howe|参照读数 1756690200000（UTC 串 2025-09-01 01:30:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/Santiago", 1730548800000L),
    "1756742400000",
  ) // 腿 C N2.dom_and_dow.1730548800000.America/Santiago|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Tehran", 1730548800000L),
    "1756715400000",
  ) // 腿 C N2.dom_and_dow.1730548800000.Asia/Tehran|参照读数 1756715400000（UTC 串 2025-09-01 08:30:00）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 515505600000L), "525960000000") // 腿 C N2.dom_and_dow.515505600000.UTC|参照读数 525960000000（UTC 串 1986-09-01 12:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Shanghai", 515505600000L),
    "525927600000",
  ) // 腿 C N2.dom_and_dow.515505600000.Asia/Shanghai|参照读数 525927600000（UTC 串 1986-09-01 03:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/New_York", 515505600000L),
    "525974400000",
  ) // 腿 C N2.dom_and_dow.515505600000.America/New_York|参照读数 525974400000（UTC 串 1986-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Kathmandu", 515505600000L),
    "525939300000",
  ) // 腿 C N2.dom_and_dow.515505600000.Asia/Kathmandu|参照读数 525939300000（UTC 串 1986-09-01 06:15:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 515505600000L),
    "525922200000",
  ) // 腿 C N2.dom_and_dow.515505600000.Australia/Lord_Howe|参照读数 525922200000（UTC 串 1986-09-01 01:30:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/Santiago", 515505600000L),
    "525974400000",
  ) // 腿 C N2.dom_and_dow.515505600000.America/Santiago|参照读数 525974400000（UTC 串 1986-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Tehran", 515505600000L),
    "525947400000",
  ) // 腿 C N2.dom_and_dow.515505600000.Asia/Tehran|参照读数 525947400000（UTC 串 1986-09-01 08:30:00）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 1725710400000L), "1756728000000") // 腿 C N2.dom_and_dow.1725710400000.UTC|参照读数 1756728000000（UTC 串 2025-09-01 12:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Shanghai", 1725710400000L),
    "1756699200000",
  ) // 腿 C N2.dom_and_dow.1725710400000.Asia/Shanghai|参照读数 1756699200000（UTC 串 2025-09-01 04:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/New_York", 1725710400000L),
    "1756742400000",
  ) // 腿 C N2.dom_and_dow.1725710400000.America/New_York|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Kathmandu", 1725710400000L),
    "1756707300000",
  ) // 腿 C N2.dom_and_dow.1725710400000.Asia/Kathmandu|参照读数 1756707300000（UTC 串 2025-09-01 06:15:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 1725710400000L),
    "1756690200000",
  ) // 腿 C N2.dom_and_dow.1725710400000.Australia/Lord_Howe|参照读数 1756690200000（UTC 串 2025-09-01 01:30:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/Santiago", 1725710400000L),
    "1756742400000",
  ) // 腿 C N2.dom_and_dow.1725710400000.America/Santiago|参照读数 1756742400000（UTC 串 2025-09-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Tehran", 1725710400000L),
    "1756715400000",
  ) // 腿 C N2.dom_and_dow.1725710400000.Asia/Tehran|参照读数 1756715400000（UTC 串 2025-09-01 08:30:00）
  assert_eq(znm_tag("0 12 1 * MON", "UTC", 1647864000000L), "1659355200000") // 腿 C N2.dom_and_dow.1647864000000.UTC|参照读数 1659355200000（UTC 串 2022-08-01 12:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Shanghai", 1647864000000L),
    "1659326400000",
  ) // 腿 C N2.dom_and_dow.1647864000000.Asia/Shanghai|参照读数 1659326400000（UTC 串 2022-08-01 04:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/New_York", 1647864000000L),
    "1659369600000",
  ) // 腿 C N2.dom_and_dow.1647864000000.America/New_York|参照读数 1659369600000（UTC 串 2022-08-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Kathmandu", 1647864000000L),
    "1659334500000",
  ) // 腿 C N2.dom_and_dow.1647864000000.Asia/Kathmandu|参照读数 1659334500000（UTC 串 2022-08-01 06:15:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Australia/Lord_Howe", 1647864000000L),
    "1659317400000",
  ) // 腿 C N2.dom_and_dow.1647864000000.Australia/Lord_Howe|参照读数 1659317400000（UTC 串 2022-08-01 01:30:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "America/Santiago", 1647864000000L),
    "1659369600000",
  ) // 腿 C N2.dom_and_dow.1647864000000.America/Santiago|参照读数 1659369600000（UTC 串 2022-08-01 16:00:00）
  assert_eq(
    znm_tag("0 12 1 * MON", "Asia/Tehran", 1647864000000L),
    "1659339000000",
  ) // 腿 C N2.dom_and_dow.1647864000000.Asia/Tehran|参照读数 1659339000000（UTC 串 2022-08-01 07:30:00）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 1710050400000L), "1710115199000") // 腿 C N2.end_of_day.1710050400000.UTC|参照读数 1710115199000（UTC 串 2024-03-10 23:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Shanghai", 1710050400000L),
    "1710086399000",
  ) // 腿 C N2.end_of_day.1710050400000.Asia/Shanghai|参照读数 1710086399000（UTC 串 2024-03-10 15:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 1710050400000L),
    "1710129599000",
  ) // 腿 C N2.end_of_day.1710050400000.America/New_York|参照读数 1710129599000（UTC 串 2024-03-11 03:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Kathmandu", 1710050400000L),
    "1710094499000",
  ) // 腿 C N2.end_of_day.1710050400000.Asia/Kathmandu|参照读数 1710094499000（UTC 串 2024-03-10 18:14:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710075599000",
  ) // 腿 C N2.end_of_day.1710050400000.Australia/Lord_Howe|参照读数 1710075599000（UTC 串 2024-03-10 12:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 1710050400000L),
    "1710125999000",
  ) // 腿 C N2.end_of_day.1710050400000.America/Santiago|参照读数 1710125999000（UTC 串 2024-03-11 02:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Tehran", 1710050400000L),
    "1710102599000",
  ) // 腿 C N2.end_of_day.1710050400000.Asia/Tehran|参照读数 1710102599000（UTC 串 2024-03-10 20:29:59）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 1730611800000L), "1730678399000") // 腿 C N2.end_of_day.1730611800000.UTC|参照读数 1730678399000（UTC 串 2024-11-03 23:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Shanghai", 1730611800000L),
    "1730649599000",
  ) // 腿 C N2.end_of_day.1730611800000.Asia/Shanghai|参照读数 1730649599000（UTC 串 2024-11-03 15:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 1730611800000L),
    "1730696399000",
  ) // 腿 C N2.end_of_day.1730611800000.America/New_York|参照读数 1730696399000（UTC 串 2024-11-04 04:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Kathmandu", 1730611800000L),
    "1730657699000",
  ) // 腿 C N2.end_of_day.1730611800000.Asia/Kathmandu|参照读数 1730657699000（UTC 串 2024-11-03 18:14:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730638799000",
  ) // 腿 C N2.end_of_day.1730611800000.Australia/Lord_Howe|参照读数 1730638799000（UTC 串 2024-11-03 12:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 1730611800000L),
    "1730689199000",
  ) // 腿 C N2.end_of_day.1730611800000.America/Santiago|参照读数 1730689199000（UTC 串 2024-11-04 02:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Tehran", 1730611800000L),
    "1730665799000",
  ) // 腿 C N2.end_of_day.1730611800000.Asia/Tehran|参照读数 1730665799000（UTC 串 2024-11-03 20:29:59）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 1730615400000L), "1730678399000") // 腿 C N2.end_of_day.1730615400000.UTC|参照读数 1730678399000（UTC 串 2024-11-03 23:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Shanghai", 1730615400000L),
    "1730649599000",
  ) // 腿 C N2.end_of_day.1730615400000.Asia/Shanghai|参照读数 1730649599000（UTC 串 2024-11-03 15:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 1730615400000L),
    "1730696399000",
  ) // 腿 C N2.end_of_day.1730615400000.America/New_York|参照读数 1730696399000（UTC 串 2024-11-04 04:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Kathmandu", 1730615400000L),
    "1730657699000",
  ) // 腿 C N2.end_of_day.1730615400000.Asia/Kathmandu|参照读数 1730657699000（UTC 串 2024-11-03 18:14:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730638799000",
  ) // 腿 C N2.end_of_day.1730615400000.Australia/Lord_Howe|参照读数 1730638799000（UTC 串 2024-11-03 12:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 1730615400000L),
    "1730689199000",
  ) // 腿 C N2.end_of_day.1730615400000.America/Santiago|参照读数 1730689199000（UTC 串 2024-11-04 02:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Tehran", 1730615400000L),
    "1730665799000",
  ) // 腿 C N2.end_of_day.1730615400000.Asia/Tehran|参照读数 1730665799000（UTC 串 2024-11-03 20:29:59）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 1709208000000L), "1709251199000") // 腿 C N2.end_of_day.1709208000000.UTC|参照读数 1709251199000（UTC 串 2024-02-29 23:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Shanghai", 1709208000000L),
    "1709222399000",
  ) // 腿 C N2.end_of_day.1709208000000.Asia/Shanghai|参照读数 1709222399000（UTC 串 2024-02-29 15:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 1709208000000L),
    "1709269199000",
  ) // 腿 C N2.end_of_day.1709208000000.America/New_York|参照读数 1709269199000（UTC 串 2024-03-01 04:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Kathmandu", 1709208000000L),
    "1709230499000",
  ) // 腿 C N2.end_of_day.1709208000000.Asia/Kathmandu|参照读数 1709230499000（UTC 串 2024-02-29 18:14:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709211599000",
  ) // 腿 C N2.end_of_day.1709208000000.Australia/Lord_Howe|参照读数 1709211599000（UTC 串 2024-02-29 12:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 1709208000000L),
    "1709261999000",
  ) // 腿 C N2.end_of_day.1709208000000.America/Santiago|参照读数 1709261999000（UTC 串 2024-03-01 02:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Tehran", 1709208000000L),
    "1709238599000",
  ) // 腿 C N2.end_of_day.1709208000000.Asia/Tehran|参照读数 1709238599000（UTC 串 2024-02-29 20:29:59）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 1714435200000L), "1714521599000") // 腿 C N2.end_of_day.1714435200000.UTC|参照读数 1714521599000（UTC 串 2024-04-30 23:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Shanghai", 1714435200000L),
    "1714492799000",
  ) // 腿 C N2.end_of_day.1714435200000.Asia/Shanghai|参照读数 1714492799000（UTC 串 2024-04-30 15:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 1714435200000L),
    "1714449599000",
  ) // 腿 C N2.end_of_day.1714435200000.America/New_York|参照读数 1714449599000（UTC 串 2024-04-30 03:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Kathmandu", 1714435200000L),
    "1714500899000",
  ) // 腿 C N2.end_of_day.1714435200000.Asia/Kathmandu|参照读数 1714500899000（UTC 串 2024-04-30 18:14:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714483799000",
  ) // 腿 C N2.end_of_day.1714435200000.Australia/Lord_Howe|参照读数 1714483799000（UTC 串 2024-04-30 13:29:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 1714435200000L),
    "1714449599000",
  ) // 腿 C N2.end_of_day.1714435200000.America/Santiago|参照读数 1714449599000（UTC 串 2024-04-30 03:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Tehran", 1714435200000L),
    "1714508999000",
  ) // 腿 C N2.end_of_day.1714435200000.Asia/Tehran|参照读数 1714508999000（UTC 串 2024-04-30 20:29:59）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 515554200000L), "515635199000") // 腿 C N2.end_of_day.515554200000.UTC|参照读数 515635199000（UTC 串 1986-05-04 23:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Shanghai", 515554200000L),
    "515602799000",
  ) // 腿 C N2.end_of_day.515554200000.Asia/Shanghai|参照读数 515602799000（UTC 串 1986-05-04 14:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 515554200000L),
    "515563199000",
  ) // 腿 C N2.end_of_day.515554200000.America/New_York|参照读数 515563199000（UTC 串 1986-05-04 03:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Kathmandu", 515554200000L),
    "515614499000",
  ) // 腿 C N2.end_of_day.515554200000.Asia/Kathmandu|参照读数 515614499000（UTC 串 1986-05-04 18:14:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 515554200000L),
    "515597399000",
  ) // 腿 C N2.end_of_day.515554200000.Australia/Lord_Howe|参照读数 515597399000（UTC 串 1986-05-04 13:29:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 515554200000L),
    "515563199000",
  ) // 腿 C N2.end_of_day.515554200000.America/Santiago|参照读数 515563199000（UTC 串 1986-05-04 03:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Tehran", 515554200000L),
    "515622599000",
  ) // 腿 C N2.end_of_day.515554200000.Asia/Tehran|参照读数 515622599000（UTC 串 1986-05-04 20:29:59）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 4070822400000L), "null") // 腿 C N2.end_of_day.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070908799000｜UTC 2098-12-31 23:59:59，spec §11 第 4 行）
  assert_eq(znm_tag("59 59 23 * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N2.end_of_day.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070879999000｜UTC 2098-12-31 15:59:59，spec §11 第 4 行）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 4070822400000L),
    "null",
  ) // 腿 C N2.end_of_day.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070840399000｜UTC 2098-12-31 04:59:59，spec §11 第 4 行）
  assert_eq(znm_tag("59 59 23 * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N2.end_of_day.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070888099000｜UTC 2098-12-31 18:14:59，spec §11 第 4 行）
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N2.end_of_day.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070869199000｜UTC 2098-12-31 12:59:59，spec §11 第 4 行）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 4070822400000L),
    "null",
  ) // 腿 C N2.end_of_day.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070833199000｜UTC 2098-12-31 02:59:59，spec §11 第 4 行）
  assert_eq(znm_tag("59 59 23 * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.end_of_day.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070896199000｜UTC 2098-12-31 20:29:59，spec §11 第 4 行）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 1730606400000L), "1730678399000") // 腿 C N2.end_of_day.1730606400000.UTC|参照读数 1730678399000（UTC 串 2024-11-03 23:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Shanghai", 1730606400000L),
    "1730649599000",
  ) // 腿 C N2.end_of_day.1730606400000.Asia/Shanghai|参照读数 1730649599000（UTC 串 2024-11-03 15:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 1730606400000L),
    "1730696399000",
  ) // 腿 C N2.end_of_day.1730606400000.America/New_York|参照读数 1730696399000（UTC 串 2024-11-04 04:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Kathmandu", 1730606400000L),
    "1730657699000",
  ) // 腿 C N2.end_of_day.1730606400000.Asia/Kathmandu|参照读数 1730657699000（UTC 串 2024-11-03 18:14:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730638799000",
  ) // 腿 C N2.end_of_day.1730606400000.Australia/Lord_Howe|参照读数 1730638799000（UTC 串 2024-11-03 12:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 1730606400000L),
    "1730689199000",
  ) // 腿 C N2.end_of_day.1730606400000.America/Santiago|参照读数 1730689199000（UTC 串 2024-11-04 02:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Tehran", 1730606400000L),
    "1730665799000",
  ) // 腿 C N2.end_of_day.1730606400000.Asia/Tehran|参照读数 1730665799000（UTC 串 2024-11-03 20:29:59）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 1709985600000L), "1710028799000") // 腿 C N2.end_of_day.1709985600000.UTC|参照读数 1710028799000（UTC 串 2024-03-09 23:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Shanghai", 1709985600000L),
    "1709999999000",
  ) // 腿 C N2.end_of_day.1709985600000.Asia/Shanghai|参照读数 1709999999000（UTC 串 2024-03-09 15:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 1709985600000L),
    "1710046799000",
  ) // 腿 C N2.end_of_day.1709985600000.America/New_York|参照读数 1710046799000（UTC 串 2024-03-10 04:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Kathmandu", 1709985600000L),
    "1710008099000",
  ) // 腿 C N2.end_of_day.1709985600000.Asia/Kathmandu|参照读数 1710008099000（UTC 串 2024-03-09 18:14:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709989199000",
  ) // 腿 C N2.end_of_day.1709985600000.Australia/Lord_Howe|参照读数 1709989199000（UTC 串 2024-03-09 12:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 1709985600000L),
    "1710039599000",
  ) // 腿 C N2.end_of_day.1709985600000.America/Santiago|参照读数 1710039599000（UTC 串 2024-03-10 02:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Tehran", 1709985600000L),
    "1710016199000",
  ) // 腿 C N2.end_of_day.1709985600000.Asia/Tehran|参照读数 1710016199000（UTC 串 2024-03-09 20:29:59）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 1730548800000L), "1730591999000") // 腿 C N2.end_of_day.1730548800000.UTC|参照读数 1730591999000（UTC 串 2024-11-02 23:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Shanghai", 1730548800000L),
    "1730563199000",
  ) // 腿 C N2.end_of_day.1730548800000.Asia/Shanghai|参照读数 1730563199000（UTC 串 2024-11-02 15:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 1730548800000L),
    "1730606399000",
  ) // 腿 C N2.end_of_day.1730548800000.America/New_York|参照读数 1730606399000（UTC 串 2024-11-03 03:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Kathmandu", 1730548800000L),
    "1730571299000",
  ) // 腿 C N2.end_of_day.1730548800000.Asia/Kathmandu|参照读数 1730571299000（UTC 串 2024-11-02 18:14:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730552399000",
  ) // 腿 C N2.end_of_day.1730548800000.Australia/Lord_Howe|参照读数 1730552399000（UTC 串 2024-11-02 12:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 1730548800000L),
    "1730602799000",
  ) // 腿 C N2.end_of_day.1730548800000.America/Santiago|参照读数 1730602799000（UTC 串 2024-11-03 02:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Tehran", 1730548800000L),
    "1730579399000",
  ) // 腿 C N2.end_of_day.1730548800000.Asia/Tehran|参照读数 1730579399000（UTC 串 2024-11-02 20:29:59）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 515505600000L), "515548799000") // 腿 C N2.end_of_day.515505600000.UTC|参照读数 515548799000（UTC 串 1986-05-03 23:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Shanghai", 515505600000L),
    "515519999000",
  ) // 腿 C N2.end_of_day.515505600000.Asia/Shanghai|参照读数 515519999000（UTC 串 1986-05-03 15:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 515505600000L),
    "515563199000",
  ) // 腿 C N2.end_of_day.515505600000.America/New_York|参照读数 515563199000（UTC 串 1986-05-04 03:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Kathmandu", 515505600000L),
    "515528099000",
  ) // 腿 C N2.end_of_day.515505600000.Asia/Kathmandu|参照读数 515528099000（UTC 串 1986-05-03 18:14:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 515505600000L),
    "515510999000",
  ) // 腿 C N2.end_of_day.515505600000.Australia/Lord_Howe|参照读数 515510999000（UTC 串 1986-05-03 13:29:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 515505600000L),
    "515563199000",
  ) // 腿 C N2.end_of_day.515505600000.America/Santiago|参照读数 515563199000（UTC 串 1986-05-04 03:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Tehran", 515505600000L),
    "515536199000",
  ) // 腿 C N2.end_of_day.515505600000.Asia/Tehran|参照读数 515536199000（UTC 串 1986-05-03 20:29:59）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 1725710400000L), "1725753599000") // 腿 C N2.end_of_day.1725710400000.UTC|参照读数 1725753599000（UTC 串 2024-09-07 23:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Shanghai", 1725710400000L),
    "1725724799000",
  ) // 腿 C N2.end_of_day.1725710400000.Asia/Shanghai|参照读数 1725724799000（UTC 串 2024-09-07 15:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 1725710400000L),
    "1725767999000",
  ) // 腿 C N2.end_of_day.1725710400000.America/New_York|参照读数 1725767999000（UTC 串 2024-09-08 03:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Kathmandu", 1725710400000L),
    "1725732899000",
  ) // 腿 C N2.end_of_day.1725710400000.Asia/Kathmandu|参照读数 1725732899000（UTC 串 2024-09-07 18:14:59）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znm_tag 行，已匹配给自身/末支，第 6 块 180 条）" {
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725715799000",
  ) // 腿 C N2.end_of_day.1725710400000.Australia/Lord_Howe|参照读数 1725715799000（UTC 串 2024-09-07 13:29:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 1725710400000L),
    "1725767999000",
  ) // 腿 C N2.end_of_day.1725710400000.America/Santiago|参照读数 1725767999000（UTC 串 2024-09-08 03:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Tehran", 1725710400000L),
    "1725740999000",
  ) // 腿 C N2.end_of_day.1725710400000.Asia/Tehran|参照读数 1725740999000（UTC 串 2024-09-07 20:29:59）
  assert_eq(znm_tag("59 59 23 * * *", "UTC", 1647864000000L), "1647907199000") // 腿 C N2.end_of_day.1647864000000.UTC|参照读数 1647907199000（UTC 串 2022-03-21 23:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Shanghai", 1647864000000L),
    "1647878399000",
  ) // 腿 C N2.end_of_day.1647864000000.Asia/Shanghai|参照读数 1647878399000（UTC 串 2022-03-21 15:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/New_York", 1647864000000L),
    "1647921599000",
  ) // 腿 C N2.end_of_day.1647864000000.America/New_York|参照读数 1647921599000（UTC 串 2022-03-22 03:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Kathmandu", 1647864000000L),
    "1647886499000",
  ) // 腿 C N2.end_of_day.1647864000000.Asia/Kathmandu|参照读数 1647886499000（UTC 串 2022-03-21 18:14:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647867599000",
  ) // 腿 C N2.end_of_day.1647864000000.Australia/Lord_Howe|参照读数 1647867599000（UTC 串 2022-03-21 12:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "America/Santiago", 1647864000000L),
    "1647917999000",
  ) // 腿 C N2.end_of_day.1647864000000.America/Santiago|参照读数 1647917999000（UTC 串 2022-03-22 02:59:59）
  assert_eq(
    znm_tag("59 59 23 * * *", "Asia/Tehran", 1647864000000L),
    "1647894599000",
  ) // 腿 C N2.end_of_day.1647864000000.Asia/Tehran|参照读数 1647894599000（UTC 串 2022-03-21 20:29:59）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 1710050400000L), "1710050400000") // 腿 C N2.step15s.1710050400000.UTC|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Shanghai", 1710050400000L),
    "1710050400000",
  ) // 腿 C N2.step15s.1710050400000.Asia/Shanghai|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 1710050400000L),
    "1710050400000",
  ) // 腿 C N2.step15s.1710050400000.America/New_York|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Kathmandu", 1710050400000L),
    "1710050400000",
  ) // 腿 C N2.step15s.1710050400000.Asia/Kathmandu|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 1710050400000L),
    "1710050400000",
  ) // 腿 C N2.step15s.1710050400000.Australia/Lord_Howe|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 1710050400000L),
    "1710050400000",
  ) // 腿 C N2.step15s.1710050400000.America/Santiago|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Tehran", 1710050400000L),
    "1710050400000",
  ) // 腿 C N2.step15s.1710050400000.Asia/Tehran|参照读数 1710050400000（UTC 串 2024-03-10 06:00:00）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 1730611800000L), "1730611800000") // 腿 C N2.step15s.1730611800000.UTC|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Shanghai", 1730611800000L),
    "1730611800000",
  ) // 腿 C N2.step15s.1730611800000.Asia/Shanghai|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 1730611800000L),
    "1730615400000",
  ) // 腿 C N2.step15s.1730611800000.America/New_York|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Kathmandu", 1730611800000L),
    "1730611800000",
  ) // 腿 C N2.step15s.1730611800000.Asia/Kathmandu|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 1730611800000L),
    "1730611800000",
  ) // 腿 C N2.step15s.1730611800000.Australia/Lord_Howe|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 1730611800000L),
    "1730611800000",
  ) // 腿 C N2.step15s.1730611800000.America/Santiago|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Tehran", 1730611800000L),
    "1730611800000",
  ) // 腿 C N2.step15s.1730611800000.Asia/Tehran|参照读数 1730611800000（UTC 串 2024-11-03 05:30:00）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 1730615400000L), "1730615400000") // 腿 C N2.step15s.1730615400000.UTC|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Shanghai", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.step15s.1730615400000.Asia/Shanghai|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.step15s.1730615400000.America/New_York|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Kathmandu", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.step15s.1730615400000.Asia/Kathmandu|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.step15s.1730615400000.Australia/Lord_Howe|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.step15s.1730615400000.America/Santiago|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Tehran", 1730615400000L),
    "1730615400000",
  ) // 腿 C N2.step15s.1730615400000.Asia/Tehran|参照读数 1730615400000（UTC 串 2024-11-03 06:30:00）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 1709208000000L), "1709208000000") // 腿 C N2.step15s.1709208000000.UTC|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Shanghai", 1709208000000L),
    "1709208000000",
  ) // 腿 C N2.step15s.1709208000000.Asia/Shanghai|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 1709208000000L),
    "1709208000000",
  ) // 腿 C N2.step15s.1709208000000.America/New_York|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Kathmandu", 1709208000000L),
    "1709208000000",
  ) // 腿 C N2.step15s.1709208000000.Asia/Kathmandu|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 1709208000000L),
    "1709208000000",
  ) // 腿 C N2.step15s.1709208000000.Australia/Lord_Howe|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 1709208000000L),
    "1709208000000",
  ) // 腿 C N2.step15s.1709208000000.America/Santiago|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Tehran", 1709208000000L),
    "1709208000000",
  ) // 腿 C N2.step15s.1709208000000.Asia/Tehran|参照读数 1709208000000（UTC 串 2024-02-29 12:00:00）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 1714435200000L), "1714435200000") // 腿 C N2.step15s.1714435200000.UTC|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Shanghai", 1714435200000L),
    "1714435200000",
  ) // 腿 C N2.step15s.1714435200000.Asia/Shanghai|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 1714435200000L),
    "1714435200000",
  ) // 腿 C N2.step15s.1714435200000.America/New_York|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Kathmandu", 1714435200000L),
    "1714435200000",
  ) // 腿 C N2.step15s.1714435200000.Asia/Kathmandu|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 1714435200000L),
    "1714435200000",
  ) // 腿 C N2.step15s.1714435200000.Australia/Lord_Howe|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 1714435200000L),
    "1714435200000",
  ) // 腿 C N2.step15s.1714435200000.America/Santiago|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Tehran", 1714435200000L),
    "1714435200000",
  ) // 腿 C N2.step15s.1714435200000.Asia/Tehran|参照读数 1714435200000（UTC 串 2024-04-30 00:00:00）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 515554200000L), "515554200000") // 腿 C N2.step15s.515554200000.UTC|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Shanghai", 515554200000L),
    "515554200000",
  ) // 腿 C N2.step15s.515554200000.Asia/Shanghai|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 515554200000L),
    "515554200000",
  ) // 腿 C N2.step15s.515554200000.America/New_York|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Kathmandu", 515554200000L),
    "515554200000",
  ) // 腿 C N2.step15s.515554200000.Asia/Kathmandu|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 515554200000L),
    "515554200000",
  ) // 腿 C N2.step15s.515554200000.Australia/Lord_Howe|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 515554200000L),
    "515554200000",
  ) // 腿 C N2.step15s.515554200000.America/Santiago|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Tehran", 515554200000L),
    "515554200000",
  ) // 腿 C N2.step15s.515554200000.Asia/Tehran|参照读数 515554200000（UTC 串 1986-05-04 01:30:00）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 4070822400000L), "null") // 腿 C N2.step15s.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("*/15 * * * * *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N2.step15s.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 4070822400000L),
    "null",
  ) // 腿 C N2.step15s.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("*/15 * * * * *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N2.step15s.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N2.step15s.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 4070822400000L),
    "null",
  ) // 腿 C N2.step15s.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("*/15 * * * * *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.step15s.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070822400000｜UTC 2098-12-31 00:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 1730606400000L), "1730606400000") // 腿 C N2.step15s.1730606400000.UTC|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Shanghai", 1730606400000L),
    "1730606400000",
  ) // 腿 C N2.step15s.1730606400000.Asia/Shanghai|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 1730606400000L),
    "1730606400000",
  ) // 腿 C N2.step15s.1730606400000.America/New_York|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Kathmandu", 1730606400000L),
    "1730606400000",
  ) // 腿 C N2.step15s.1730606400000.Asia/Kathmandu|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 1730606400000L),
    "1730606400000",
  ) // 腿 C N2.step15s.1730606400000.Australia/Lord_Howe|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 1730606400000L),
    "1730606400000",
  ) // 腿 C N2.step15s.1730606400000.America/Santiago|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Tehran", 1730606400000L),
    "1730606400000",
  ) // 腿 C N2.step15s.1730606400000.Asia/Tehran|参照读数 1730606400000（UTC 串 2024-11-03 04:00:00）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 1709985600000L), "1709985600000") // 腿 C N2.step15s.1709985600000.UTC|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Shanghai", 1709985600000L),
    "1709985600000",
  ) // 腿 C N2.step15s.1709985600000.Asia/Shanghai|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 1709985600000L),
    "1709985600000",
  ) // 腿 C N2.step15s.1709985600000.America/New_York|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Kathmandu", 1709985600000L),
    "1709985600000",
  ) // 腿 C N2.step15s.1709985600000.Asia/Kathmandu|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 1709985600000L),
    "1709985600000",
  ) // 腿 C N2.step15s.1709985600000.Australia/Lord_Howe|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 1709985600000L),
    "1709985600000",
  ) // 腿 C N2.step15s.1709985600000.America/Santiago|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Tehran", 1709985600000L),
    "1709985600000",
  ) // 腿 C N2.step15s.1709985600000.Asia/Tehran|参照读数 1709985600000（UTC 串 2024-03-09 12:00:00）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 1730548800000L), "1730548800000") // 腿 C N2.step15s.1730548800000.UTC|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Shanghai", 1730548800000L),
    "1730548800000",
  ) // 腿 C N2.step15s.1730548800000.Asia/Shanghai|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 1730548800000L),
    "1730548800000",
  ) // 腿 C N2.step15s.1730548800000.America/New_York|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Kathmandu", 1730548800000L),
    "1730548800000",
  ) // 腿 C N2.step15s.1730548800000.Asia/Kathmandu|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 1730548800000L),
    "1730548800000",
  ) // 腿 C N2.step15s.1730548800000.Australia/Lord_Howe|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 1730548800000L),
    "1730548800000",
  ) // 腿 C N2.step15s.1730548800000.America/Santiago|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Tehran", 1730548800000L),
    "1730548800000",
  ) // 腿 C N2.step15s.1730548800000.Asia/Tehran|参照读数 1730548800000（UTC 串 2024-11-02 12:00:00）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 515505600000L), "515505600000") // 腿 C N2.step15s.515505600000.UTC|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Shanghai", 515505600000L),
    "515505600000",
  ) // 腿 C N2.step15s.515505600000.Asia/Shanghai|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 515505600000L),
    "515505600000",
  ) // 腿 C N2.step15s.515505600000.America/New_York|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Kathmandu", 515505600000L),
    "515505600000",
  ) // 腿 C N2.step15s.515505600000.Asia/Kathmandu|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 515505600000L),
    "515505600000",
  ) // 腿 C N2.step15s.515505600000.Australia/Lord_Howe|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 515505600000L),
    "515505600000",
  ) // 腿 C N2.step15s.515505600000.America/Santiago|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Tehran", 515505600000L),
    "515505600000",
  ) // 腿 C N2.step15s.515505600000.Asia/Tehran|参照读数 515505600000（UTC 串 1986-05-03 12:00:00）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 1725710400000L), "1725710400000") // 腿 C N2.step15s.1725710400000.UTC|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Shanghai", 1725710400000L),
    "1725710400000",
  ) // 腿 C N2.step15s.1725710400000.Asia/Shanghai|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 1725710400000L),
    "1725710400000",
  ) // 腿 C N2.step15s.1725710400000.America/New_York|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Kathmandu", 1725710400000L),
    "1725710400000",
  ) // 腿 C N2.step15s.1725710400000.Asia/Kathmandu|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 1725710400000L),
    "1725710400000",
  ) // 腿 C N2.step15s.1725710400000.Australia/Lord_Howe|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 1725710400000L),
    "1725710400000",
  ) // 腿 C N2.step15s.1725710400000.America/Santiago|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Tehran", 1725710400000L),
    "1725710400000",
  ) // 腿 C N2.step15s.1725710400000.Asia/Tehran|参照读数 1725710400000（UTC 串 2024-09-07 12:00:00）
  assert_eq(znm_tag("*/15 * * * * *", "UTC", 1647864000000L), "1647864000000") // 腿 C N2.step15s.1647864000000.UTC|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Shanghai", 1647864000000L),
    "1647864000000",
  ) // 腿 C N2.step15s.1647864000000.Asia/Shanghai|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/New_York", 1647864000000L),
    "1647864000000",
  ) // 腿 C N2.step15s.1647864000000.America/New_York|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Kathmandu", 1647864000000L),
    "1647864000000",
  ) // 腿 C N2.step15s.1647864000000.Asia/Kathmandu|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Australia/Lord_Howe", 1647864000000L),
    "1647864000000",
  ) // 腿 C N2.step15s.1647864000000.Australia/Lord_Howe|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "America/Santiago", 1647864000000L),
    "1647864000000",
  ) // 腿 C N2.step15s.1647864000000.America/Santiago|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(
    znm_tag("*/15 * * * * *", "Asia/Tehran", 1647864000000L),
    "1647864000000",
  ) // 腿 C N2.step15s.1647864000000.Asia/Tehran|参照读数 1647864000000（UTC 串 2022-03-21 12:00:00）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 1710050400000L), "null") // 腿 C N2.year_2099.1710050400000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1710050400000L),
    "null",
  ) // 腿 C N2.year_2099.1710050400000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 1710050400000L),
    "null",
  ) // 腿 C N2.year_2099.1710050400000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1710050400000L),
    "null",
  ) // 腿 C N2.year_2099.1710050400000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1710050400000L),
    "null",
  ) // 腿 C N2.year_2099.1710050400000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 1710050400000L),
    "null",
  ) // 腿 C N2.year_2099.1710050400000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1710050400000L), "null") // 腿 C N2.year_2099.1710050400000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 1730611800000L), "null") // 腿 C N2.year_2099.1730611800000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1730611800000L),
    "null",
  ) // 腿 C N2.year_2099.1730611800000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 1730611800000L),
    "null",
  ) // 腿 C N2.year_2099.1730611800000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1730611800000L),
    "null",
  ) // 腿 C N2.year_2099.1730611800000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1730611800000L),
    "null",
  ) // 腿 C N2.year_2099.1730611800000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 1730611800000L),
    "null",
  ) // 腿 C N2.year_2099.1730611800000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1730611800000L), "null") // 腿 C N2.year_2099.1730611800000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 1730615400000L), "null") // 腿 C N2.year_2099.1730615400000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1730615400000L),
    "null",
  ) // 腿 C N2.year_2099.1730615400000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 1730615400000L),
    "null",
  ) // 腿 C N2.year_2099.1730615400000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1730615400000L),
    "null",
  ) // 腿 C N2.year_2099.1730615400000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1730615400000L),
    "null",
  ) // 腿 C N2.year_2099.1730615400000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 1730615400000L),
    "null",
  ) // 腿 C N2.year_2099.1730615400000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1730615400000L), "null") // 腿 C N2.year_2099.1730615400000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 1709208000000L), "null") // 腿 C N2.year_2099.1709208000000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1709208000000L),
    "null",
  ) // 腿 C N2.year_2099.1709208000000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 1709208000000L),
    "null",
  ) // 腿 C N2.year_2099.1709208000000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1709208000000L),
    "null",
  ) // 腿 C N2.year_2099.1709208000000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1709208000000L),
    "null",
  ) // 腿 C N2.year_2099.1709208000000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 1709208000000L),
    "null",
  ) // 腿 C N2.year_2099.1709208000000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1709208000000L), "null") // 腿 C N2.year_2099.1709208000000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 1714435200000L), "null") // 腿 C N2.year_2099.1714435200000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1714435200000L),
    "null",
  ) // 腿 C N2.year_2099.1714435200000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 1714435200000L),
    "null",
  ) // 腿 C N2.year_2099.1714435200000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1714435200000L),
    "null",
  ) // 腿 C N2.year_2099.1714435200000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1714435200000L),
    "null",
  ) // 腿 C N2.year_2099.1714435200000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 1714435200000L),
    "null",
  ) // 腿 C N2.year_2099.1714435200000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1714435200000L), "null") // 腿 C N2.year_2099.1714435200000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 515554200000L), "null") // 腿 C N2.year_2099.515554200000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 515554200000L),
    "null",
  ) // 腿 C N2.year_2099.515554200000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 515554200000L),
    "null",
  ) // 腿 C N2.year_2099.515554200000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 515554200000L),
    "null",
  ) // 腿 C N2.year_2099.515554200000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 515554200000L),
    "null",
  ) // 腿 C N2.year_2099.515554200000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 515554200000L),
    "null",
  ) // 腿 C N2.year_2099.515554200000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 515554200000L), "null") // 腿 C N2.year_2099.515554200000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 4070822400000L), "null") // 腿 C N2.year_2099.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 4070822400000L),
    "null",
  ) // 腿 C N2.year_2099.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 4070822400000L),
    "null",
  ) // 腿 C N2.year_2099.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 4070822400000L),
    "null",
  ) // 腿 C N2.year_2099.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N2.year_2099.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 4070822400000L),
    "null",
  ) // 腿 C N2.year_2099.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.year_2099.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 1730606400000L), "null") // 腿 C N2.year_2099.1730606400000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1730606400000L),
    "null",
  ) // 腿 C N2.year_2099.1730606400000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 1730606400000L),
    "null",
  ) // 腿 C N2.year_2099.1730606400000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1730606400000L),
    "null",
  ) // 腿 C N2.year_2099.1730606400000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1730606400000L),
    "null",
  ) // 腿 C N2.year_2099.1730606400000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 1730606400000L),
    "null",
  ) // 腿 C N2.year_2099.1730606400000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1730606400000L), "null") // 腿 C N2.year_2099.1730606400000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 1709985600000L), "null") // 腿 C N2.year_2099.1709985600000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1709985600000L),
    "null",
  ) // 腿 C N2.year_2099.1709985600000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 1709985600000L),
    "null",
  ) // 腿 C N2.year_2099.1709985600000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1709985600000L),
    "null",
  ) // 腿 C N2.year_2099.1709985600000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1709985600000L),
    "null",
  ) // 腿 C N2.year_2099.1709985600000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 1709985600000L),
    "null",
  ) // 腿 C N2.year_2099.1709985600000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1709985600000L), "null") // 腿 C N2.year_2099.1709985600000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 1730548800000L), "null") // 腿 C N2.year_2099.1730548800000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1730548800000L),
    "null",
  ) // 腿 C N2.year_2099.1730548800000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 1730548800000L),
    "null",
  ) // 腿 C N2.year_2099.1730548800000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1730548800000L),
    "null",
  ) // 腿 C N2.year_2099.1730548800000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1730548800000L),
    "null",
  ) // 腿 C N2.year_2099.1730548800000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 1730548800000L),
    "null",
  ) // 腿 C N2.year_2099.1730548800000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1730548800000L), "null") // 腿 C N2.year_2099.1730548800000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 515505600000L), "null") // 腿 C N2.year_2099.515505600000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 515505600000L),
    "null",
  ) // 腿 C N2.year_2099.515505600000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 515505600000L),
    "null",
  ) // 腿 C N2.year_2099.515505600000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 515505600000L),
    "null",
  ) // 腿 C N2.year_2099.515505600000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 515505600000L),
    "null",
  ) // 腿 C N2.year_2099.515505600000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 515505600000L),
    "null",
  ) // 腿 C N2.year_2099.515505600000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 515505600000L), "null") // 腿 C N2.year_2099.515505600000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 1725710400000L), "null") // 腿 C N2.year_2099.1725710400000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1725710400000L),
    "null",
  ) // 腿 C N2.year_2099.1725710400000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
}

///|
test "@cron2 带区名的下一瞬间（腿 C znm_tag 行，已匹配给自身/末支，第 7 块 19 条）" {
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 1725710400000L),
    "null",
  ) // 腿 C N2.year_2099.1725710400000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1725710400000L),
    "null",
  ) // 腿 C N2.year_2099.1725710400000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1725710400000L),
    "null",
  ) // 腿 C N2.year_2099.1725710400000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 1725710400000L),
    "null",
  ) // 腿 C N2.year_2099.1725710400000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1725710400000L), "null") // 腿 C N2.year_2099.1725710400000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "UTC", 1647864000000L), "null") // 腿 C N2.year_2099.1647864000000.UTC ⇒ 落点出表窗，本库不外推（参照原读数 4070952000000｜UTC 2099-01-01 12:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Shanghai", 1647864000000L),
    "null",
  ) // 腿 C N2.year_2099.1647864000000.Asia/Shanghai ⇒ 落点出表窗，本库不外推（参照原读数 4070923200000｜UTC 2099-01-01 04:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/New_York", 1647864000000L),
    "null",
  ) // 腿 C N2.year_2099.1647864000000.America/New_York ⇒ 落点出表窗，本库不外推（参照原读数 4070970000000｜UTC 2099-01-01 17:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Asia/Kathmandu", 1647864000000L),
    "null",
  ) // 腿 C N2.year_2099.1647864000000.Asia/Kathmandu ⇒ 落点出表窗，本库不外推（参照原读数 4070931300000｜UTC 2099-01-01 06:15:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "Australia/Lord_Howe", 1647864000000L),
    "null",
  ) // 腿 C N2.year_2099.1647864000000.Australia/Lord_Howe ⇒ 落点出表窗，本库不外推（参照原读数 4070912400000｜UTC 2099-01-01 01:00:00，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 12 * * ? 2099", "America/Santiago", 1647864000000L),
    "null",
  ) // 腿 C N2.year_2099.1647864000000.America/Santiago ⇒ 落点出表窗，本库不外推（参照原读数 4070962800000｜UTC 2099-01-01 15:00:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 12 * * ? 2099", "Asia/Tehran", 1647864000000L), "null") // 腿 C N2.year_2099.1647864000000.Asia/Tehran ⇒ 落点出表窗，本库不外推（参照原读数 4070939400000｜UTC 2099-01-01 08:30:00，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 30 2 *", "UTC", 4070822400000L), "null") // 腿 C N2.feb30.4070822400000.UTC ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 30 2 *", "Asia/Shanghai", 4070822400000L), "null") // 腿 C N2.feb30.4070822400000.Asia/Shanghai ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 30 2 *", "America/New_York", 4070822400000L), "null") // 腿 C N2.feb30.4070822400000.America/New_York ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 30 2 *", "Asia/Kathmandu", 4070822400000L), "null") // 腿 C N2.feb30.4070822400000.Asia/Kathmandu ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
  assert_eq(
    znm_tag("0 0 0 30 2 *", "Australia/Lord_Howe", 4070822400000L),
    "null",
  ) // 腿 C N2.feb30.4070822400000.Australia/Lord_Howe ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 30 2 *", "America/Santiago", 4070822400000L), "null") // 腿 C N2.feb30.4070822400000.America/Santiago ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
  assert_eq(znm_tag("0 0 0 30 2 *", "Asia/Tehran", 4070822400000L), "null") // 腿 C N2.feb30.4070822400000.Asia/Tehran ⇒ 基准已出表窗，本库不外推（参照原读数 ERR_java.lang.StackOverflowError|null｜UTC -，spec §11 第 4 行）
}

///|
// 本文件故意不进夹具 168 格，全部是 `feb30`（`0 0 0 30 2 *`，解析通过但无解）：
// 参照读数一律 ERR_java.lang.StackOverflowError|null，本库跟随的那台引擎同样无界——
// 一条会挂住的用例塞进套件等于把整套件判死，抓不到任何东西。判据见 spec §11 第 5 行。

test "@cron2 带区名的一批命中瞬间（腿 C 的 M 行，第 1 块 91 条）" {
  assert_eq(
    md_tag("* * * * *", "UTC", 1710050400000L, 1710050700000L, 3, false),
    "[1710050400000|1710050460000|1710050520000]",
  ) // 腿 C M.m_star.MIN.UTC|参照 UTC 串 2024-03-10 06:00:00|2024-03-10 06:01:00|2024-03-10 06:02:00
  assert_eq(
    md_tag(
      "* * * * *", "Asia/Shanghai", 1710050400000L, 1710050700000L, 3, false,
    ),
    "[1710050400000|1710050460000|1710050520000]",
  ) // 腿 C M.m_star.MIN.Asia/Shanghai|参照 UTC 串 2024-03-10 06:00:00|2024-03-10 06:01:00|2024-03-10 06:02:00
  assert_eq(
    md_tag(
      "* * * * *", "America/New_York", 1710050400000L, 1710050700000L, 3, false,
    ),
    "[1710050400000|1710050460000|1710050520000]",
  ) // 腿 C M.m_star.MIN.America/New_York|参照 UTC 串 2024-03-10 06:00:00|2024-03-10 06:01:00|2024-03-10 06:02:00
  assert_eq(
    md_tag(
      "* * * * *", "Asia/Kathmandu", 1710050400000L, 1710050700000L, 3, false,
    ),
    "[1710050400000|1710050460000|1710050520000]",
  ) // 腿 C M.m_star.MIN.Asia/Kathmandu|参照 UTC 串 2024-03-10 06:00:00|2024-03-10 06:01:00|2024-03-10 06:02:00
  assert_eq(
    md_tag(
      "* * * * *", "Australia/Lord_Howe", 1710050400000L, 1710050700000L, 3, false,
    ),
    "[1710050400000|1710050460000|1710050520000]",
  ) // 腿 C M.m_star.MIN.Australia/Lord_Howe|参照 UTC 串 2024-03-10 06:00:00|2024-03-10 06:01:00|2024-03-10 06:02:00
  assert_eq(
    md_tag(
      "* * * * *", "America/Santiago", 1710050400000L, 1710050700000L, 3, false,
    ),
    "[1710050400000|1710050460000|1710050520000]",
  ) // 腿 C M.m_star.MIN.America/Santiago|参照 UTC 串 2024-03-10 06:00:00|2024-03-10 06:01:00|2024-03-10 06:02:00
  assert_eq(
    md_tag("* * * * *", "Asia/Tehran", 1710050400000L, 1710050700000L, 3, false),
    "[1710050400000|1710050460000|1710050520000]",
  ) // 腿 C M.m_star.MIN.Asia/Tehran|参照 UTC 串 2024-03-10 06:00:00|2024-03-10 06:01:00|2024-03-10 06:02:00
  assert_eq(
    md_tag("* * * * *", "UTC", 1710050400000L, 1710050405000L, 10, true),
    "[1710050400000]",
  ) // 腿 C M.m_star_sec.SEC.UTC|参照 UTC 串 2024-03-10 06:00:00
  assert_eq(
    md_tag(
      "* * * * *", "Asia/Shanghai", 1710050400000L, 1710050405000L, 10, true,
    ),
    "[1710050400000]",
  ) // 腿 C M.m_star_sec.SEC.Asia/Shanghai|参照 UTC 串 2024-03-10 06:00:00
  assert_eq(
    md_tag(
      "* * * * *", "America/New_York", 1710050400000L, 1710050405000L, 10, true,
    ),
    "[1710050400000]",
  ) // 腿 C M.m_star_sec.SEC.America/New_York|参照 UTC 串 2024-03-10 06:00:00
  assert_eq(
    md_tag(
      "* * * * *", "Asia/Kathmandu", 1710050400000L, 1710050405000L, 10, true,
    ),
    "[1710050400000]",
  ) // 腿 C M.m_star_sec.SEC.Asia/Kathmandu|参照 UTC 串 2024-03-10 06:00:00
  assert_eq(
    md_tag(
      "* * * * *", "Australia/Lord_Howe", 1710050400000L, 1710050405000L, 10, true,
    ),
    "[1710050400000]",
  ) // 腿 C M.m_star_sec.SEC.Australia/Lord_Howe|参照 UTC 串 2024-03-10 06:00:00
  assert_eq(
    md_tag(
      "* * * * *", "America/Santiago", 1710050400000L, 1710050405000L, 10, true,
    ),
    "[1710050400000]",
  ) // 腿 C M.m_star_sec.SEC.America/Santiago|参照 UTC 串 2024-03-10 06:00:00
  assert_eq(
    md_tag("* * * * *", "Asia/Tehran", 1710050400000L, 1710050405000L, 10, true),
    "[1710050400000]",
  ) // 腿 C M.m_star_sec.SEC.Asia/Tehran|参照 UTC 串 2024-03-10 06:00:00
  assert_eq(
    md_tag("0 0 * * * *", "UTC", 1710050400000L, 1710061200000L, 4, true),
    "[1710050400000|1710054000000|1710057600000]",
  ) // 腿 C M.every_min.SEC.UTC|参照 UTC 串 2024-03-10 06:00:00|2024-03-10 07:00:00|2024-03-10 08:00:00
  assert_eq(
    md_tag(
      "0 0 * * * *", "Asia/Shanghai", 1710050400000L, 1710061200000L, 4, true,
    ),
    "[1710050400000|1710054000000|1710057600000]",
  ) // 腿 C M.every_min.SEC.Asia/Shanghai|参照 UTC 串 2024-03-10 06:00:00|2024-03-10 07:00:00|2024-03-10 08:00:00
  assert_eq(
    md_tag(
      "0 0 * * * *", "America/New_York", 1710050400000L, 1710061200000L, 4, true,
    ),
    "[1710050400000|1710054000000|1710057600000]",
  ) // 腿 C M.every_min.SEC.America/New_York|参照 UTC 串 2024-03-10 06:00:00|2024-03-10 07:00:00|2024-03-10 08:00:00
  assert_eq(
    md_tag(
      "0 0 * * * *", "Asia/Kathmandu", 1710050400000L, 1710061200000L, 4, true,
    ),
    "[1710051300000|1710054900000|1710058500000]",
  ) // 腿 C M.every_min.SEC.Asia/Kathmandu|参照 UTC 串 2024-03-10 06:15:00|2024-03-10 07:15:00|2024-03-10 08:15:00
  assert_eq(
    md_tag(
      "0 0 * * * *", "Australia/Lord_Howe", 1710050400000L, 1710061200000L, 4, true,
    ),
    "[1710050400000|1710054000000|1710057600000]",
  ) // 腿 C M.every_min.SEC.Australia/Lord_Howe|参照 UTC 串 2024-03-10 06:00:00|2024-03-10 07:00:00|2024-03-10 08:00:00
  assert_eq(
    md_tag(
      "0 0 * * * *", "America/Santiago", 1710050400000L, 1710061200000L, 4, true,
    ),
    "[1710050400000|1710054000000|1710057600000]",
  ) // 腿 C M.every_min.SEC.America/Santiago|参照 UTC 串 2024-03-10 06:00:00|2024-03-10 07:00:00|2024-03-10 08:00:00
  assert_eq(
    md_tag(
      "0 0 * * * *", "Asia/Tehran", 1710050400000L, 1710061200000L, 4, true,
    ),
    "[1710052200000|1710055800000|1710059400000]",
  ) // 腿 C M.every_min.SEC.Asia/Tehran|参照 UTC 串 2024-03-10 06:30:00|2024-03-10 07:30:00|2024-03-10 08:30:00
  assert_eq(
    md_tag("0 30 1 * * *", "UTC", 1730419200000L, 1730937600000L, 6, true),
    "[1730424600000|1730511000000|1730597400000|1730683800000|1730770200000|1730856600000]",
  ) // 腿 C M.daily.SEC.UTC|参照 UTC 串 2024-11-01 01:30:00|2024-11-02 01:30:00|2024-11-03 01:30:00|2024-11-04 01:30:00|2024-11-05 01:30:00|2024-11-06 01:30:00
  assert_eq(
    md_tag(
      "0 30 1 * * *", "Asia/Shanghai", 1730419200000L, 1730937600000L, 6, true,
    ),
    "[1730482200000|1730568600000|1730655000000|1730741400000|1730827800000|1730914200000]",
  ) // 腿 C M.daily.SEC.Asia/Shanghai|参照 UTC 串 2024-11-01 17:30:00|2024-11-02 17:30:00|2024-11-03 17:30:00|2024-11-04 17:30:00|2024-11-05 17:30:00|2024-11-06 17:30:00
  assert_eq(
    md_tag(
      "0 30 1 * * *", "America/New_York", 1730419200000L, 1730937600000L, 6, true,
    ),
    "[1730439000000|1730525400000|1730611800000|1730615400000|1730701800000|1730788200000]",
  ) // 腿 C M.daily.SEC.America/New_York|参照 UTC 串 2024-11-01 05:30:00|2024-11-02 05:30:00|2024-11-03 05:30:00|2024-11-03 06:30:00|2024-11-04 06:30:00|2024-11-05 06:30:00
  assert_eq(
    md_tag(
      "0 30 1 * * *", "Asia/Kathmandu", 1730419200000L, 1730937600000L, 6, true,
    ),
    "[1730490300000|1730576700000|1730663100000|1730749500000|1730835900000|1730922300000]",
  ) // 腿 C M.daily.SEC.Asia/Kathmandu|参照 UTC 串 2024-11-01 19:45:00|2024-11-02 19:45:00|2024-11-03 19:45:00|2024-11-04 19:45:00|2024-11-05 19:45:00|2024-11-06 19:45:00
  assert_eq(
    md_tag(
      "0 30 1 * * *", "Australia/Lord_Howe", 1730419200000L, 1730937600000L, 6, true,
    ),
    "[1730471400000|1730557800000|1730644200000|1730730600000|1730817000000|1730903400000]",
  ) // 腿 C M.daily.SEC.Australia/Lord_Howe|参照 UTC 串 2024-11-01 14:30:00|2024-11-02 14:30:00|2024-11-03 14:30:00|2024-11-04 14:30:00|2024-11-05 14:30:00|2024-11-06 14:30:00
  assert_eq(
    md_tag(
      "0 30 1 * * *", "America/Santiago", 1730419200000L, 1730937600000L, 6, true,
    ),
    "[1730435400000|1730521800000|1730608200000|1730694600000|1730781000000|1730867400000]",
  ) // 腿 C M.daily.SEC.America/Santiago|参照 UTC 串 2024-11-01 04:30:00|2024-11-02 04:30:00|2024-11-03 04:30:00|2024-11-04 04:30:00|2024-11-05 04:30:00|2024-11-06 04:30:00
  assert_eq(
    md_tag(
      "0 30 1 * * *", "Asia/Tehran", 1730419200000L, 1730937600000L, 6, true,
    ),
    "[1730498400000|1730584800000|1730671200000|1730757600000|1730844000000|1730930400000]",
  ) // 腿 C M.daily.SEC.Asia/Tehran|参照 UTC 串 2024-11-01 22:00:00|2024-11-02 22:00:00|2024-11-03 22:00:00|2024-11-04 22:00:00|2024-11-05 22:00:00|2024-11-06 22:00:00
  assert_eq(
    md_tag("* * * * *", "UTC", 1710050400000L, 1710051000000L, 0, false),
    "[]",
  ) // count<=0 ⇒ 空表（spec §11 第 2 行）；参照原读数 腿 C M.count_zero.MIN.UTC.count=0|1710050400000
  assert_eq(
    md_tag(
      "* * * * *", "Asia/Shanghai", 1710050400000L, 1710051000000L, 0, false,
    ),
    "[]",
  ) // count<=0 ⇒ 空表（spec §11 第 2 行）；参照原读数 腿 C M.count_zero.MIN.Asia/Shanghai.count=0|1710050400000
  assert_eq(
    md_tag(
      "* * * * *", "America/New_York", 1710050400000L, 1710051000000L, 0, false,
    ),
    "[]",
  ) // count<=0 ⇒ 空表（spec §11 第 2 行）；参照原读数 腿 C M.count_zero.MIN.America/New_York.count=0|1710050400000
  assert_eq(
    md_tag(
      "* * * * *", "Asia/Kathmandu", 1710050400000L, 1710051000000L, 0, false,
    ),
    "[]",
  ) // count<=0 ⇒ 空表（spec §11 第 2 行）；参照原读数 腿 C M.count_zero.MIN.Asia/Kathmandu.count=0|1710050400000
  assert_eq(
    md_tag(
      "* * * * *", "Australia/Lord_Howe", 1710050400000L, 1710051000000L, 0, false,
    ),
    "[]",
  ) // count<=0 ⇒ 空表（spec §11 第 2 行）；参照原读数 腿 C M.count_zero.MIN.Australia/Lord_Howe.count=0|1710050400000
  assert_eq(
    md_tag(
      "* * * * *", "America/Santiago", 1710050400000L, 1710051000000L, 0, false,
    ),
    "[]",
  ) // count<=0 ⇒ 空表（spec §11 第 2 行）；参照原读数 腿 C M.count_zero.MIN.America/Santiago.count=0|1710050400000
  assert_eq(
    md_tag("* * * * *", "Asia/Tehran", 1710050400000L, 1710051000000L, 0, false),
    "[]",
  ) // count<=0 ⇒ 空表（spec §11 第 2 行）；参照原读数 腿 C M.count_zero.MIN.Asia/Tehran.count=0|1710050400000
  assert_eq(
    md_tag("0 0 1 1 1 *", "UTC", 1704067200000L, 1704153600000L, 5, true),
    "[1704070800000]",
  ) // 腿 C M.count_more_than_avail.SEC.UTC|参照 UTC 串 2024-01-01 01:00:00
  assert_eq(
    md_tag(
      "0 0 1 1 1 *", "Asia/Shanghai", 1704067200000L, 1704153600000L, 5, true,
    ),
    "[]",
  ) // 腿 C M.count_more_than_avail.SEC.Asia/Shanghai|参照 UTC 串 <none>
  assert_eq(
    md_tag(
      "0 0 1 1 1 *", "America/New_York", 1704067200000L, 1704153600000L, 5, true,
    ),
    "[1704088800000]",
  ) // 腿 C M.count_more_than_avail.SEC.America/New_York|参照 UTC 串 2024-01-01 06:00:00
  assert_eq(
    md_tag(
      "0 0 1 1 1 *", "Asia/Kathmandu", 1704067200000L, 1704153600000L, 5, true,
    ),
    "[]",
  ) // 腿 C M.count_more_than_avail.SEC.Asia/Kathmandu|参照 UTC 串 <none>
  assert_eq(
    md_tag(
      "0 0 1 1 1 *", "Australia/Lord_Howe", 1704067200000L, 1704153600000L, 5, true,
    ),
    "[]",
  ) // 腿 C M.count_more_than_avail.SEC.Australia/Lord_Howe|参照 UTC 串 <none>
  assert_eq(
    md_tag(
      "0 0 1 1 1 *", "America/Santiago", 1704067200000L, 1704153600000L, 5, true,
    ),
    "[1704081600000]",
  ) // 腿 C M.count_more_than_avail.SEC.America/Santiago|参照 UTC 串 2024-01-01 04:00:00
  assert_eq(
    md_tag(
      "0 0 1 1 1 *", "Asia/Tehran", 1704067200000L, 1704153600000L, 5, true,
    ),
    "[]",
  ) // 腿 C M.count_more_than_avail.SEC.Asia/Tehran|参照 UTC 串 <none>
  assert_eq(
    md_tag("30 1 * * *", "UTC", 1730505600000L, 1730764800000L, 4, false),
    "[1730511000000|1730597400000|1730683800000]",
  ) // 腿 C M.span_dst_us.MIN.UTC|参照 UTC 串 2024-11-02 01:30:00|2024-11-03 01:30:00|2024-11-04 01:30:00
  assert_eq(
    md_tag(
      "30 1 * * *", "Asia/Shanghai", 1730505600000L, 1730764800000L, 4, false,
    ),
    "[1730568600000|1730655000000|1730741400000]",
  ) // 腿 C M.span_dst_us.MIN.Asia/Shanghai|参照 UTC 串 2024-11-02 17:30:00|2024-11-03 17:30:00|2024-11-04 17:30:00
  assert_eq(
    md_tag(
      "30 1 * * *", "America/New_York", 1730505600000L, 1730764800000L, 4, false,
    ),
    "[1730525400000|1730611800000|1730615400000|1730701800000]",
  ) // 腿 C M.span_dst_us.MIN.America/New_York|参照 UTC 串 2024-11-02 05:30:00|2024-11-03 05:30:00|2024-11-03 06:30:00|2024-11-04 06:30:00
  assert_eq(
    md_tag(
      "30 1 * * *", "Asia/Kathmandu", 1730505600000L, 1730764800000L, 4, false,
    ),
    "[1730576700000|1730663100000|1730749500000]",
  ) // 腿 C M.span_dst_us.MIN.Asia/Kathmandu|参照 UTC 串 2024-11-02 19:45:00|2024-11-03 19:45:00|2024-11-04 19:45:00
  assert_eq(
    md_tag(
      "30 1 * * *", "Australia/Lord_Howe", 1730505600000L, 1730764800000L, 4, false,
    ),
    "[1730557800000|1730644200000|1730730600000]",
  ) // 腿 C M.span_dst_us.MIN.Australia/Lord_Howe|参照 UTC 串 2024-11-02 14:30:00|2024-11-03 14:30:00|2024-11-04 14:30:00
  assert_eq(
    md_tag(
      "30 1 * * *", "America/Santiago", 1730505600000L, 1730764800000L, 4, false,
    ),
    "[1730521800000|1730608200000|1730694600000]",
  ) // 腿 C M.span_dst_us.MIN.America/Santiago|参照 UTC 串 2024-11-02 04:30:00|2024-11-03 04:30:00|2024-11-04 04:30:00
  assert_eq(
    md_tag(
      "30 1 * * *", "Asia/Tehran", 1730505600000L, 1730764800000L, 4, false,
    ),
    "[1730584800000|1730671200000|1730757600000]",
  ) // 腿 C M.span_dst_us.MIN.Asia/Tehran|参照 UTC 串 2024-11-02 22:00:00|2024-11-03 22:00:00|2024-11-04 22:00:00
  assert_eq(
    md_tag("30 1 * * *", "UTC", 515376000000L, 515808000000L, 4, false),
    "[515381400000|515467800000|515554200000|515640600000]",
  ) // 腿 C M.span_dst_cn.MIN.UTC|参照 UTC 串 1986-05-02 01:30:00|1986-05-03 01:30:00|1986-05-04 01:30:00|1986-05-05 01:30:00
  assert_eq(
    md_tag(
      "30 1 * * *", "Asia/Shanghai", 515376000000L, 515808000000L, 4, false,
    ),
    "[515439000000|515525400000|515608200000|515694600000]",
  ) // 腿 C M.span_dst_cn.MIN.Asia/Shanghai|参照 UTC 串 1986-05-02 17:30:00|1986-05-03 17:30:00|1986-05-04 16:30:00|1986-05-05 16:30:00
  assert_eq(
    md_tag(
      "30 1 * * *", "America/New_York", 515376000000L, 515808000000L, 4, false,
    ),
    "[515395800000|515482200000|515568600000|515655000000]",
  ) // 腿 C M.span_dst_cn.MIN.America/New_York|参照 UTC 串 1986-05-02 05:30:00|1986-05-03 05:30:00|1986-05-04 05:30:00|1986-05-05 05:30:00
  assert_eq(
    md_tag(
      "30 1 * * *", "Asia/Kathmandu", 515376000000L, 515808000000L, 4, false,
    ),
    "[515447100000|515533500000|515619900000|515706300000]",
  ) // 腿 C M.span_dst_cn.MIN.Asia/Kathmandu|参照 UTC 串 1986-05-02 19:45:00|1986-05-03 19:45:00|1986-05-04 19:45:00|1986-05-05 19:45:00
  assert_eq(
    md_tag(
      "30 1 * * *", "Australia/Lord_Howe", 515376000000L, 515808000000L, 4, false,
    ),
    "[515430000000|515516400000|515602800000|515689200000]",
  ) // 腿 C M.span_dst_cn.MIN.Australia/Lord_Howe|参照 UTC 串 1986-05-02 15:00:00|1986-05-03 15:00:00|1986-05-04 15:00:00|1986-05-05 15:00:00
  assert_eq(
    md_tag(
      "30 1 * * *", "America/Santiago", 515376000000L, 515808000000L, 4, false,
    ),
    "[515395800000|515482200000|515568600000|515655000000]",
  ) // 腿 C M.span_dst_cn.MIN.America/Santiago|参照 UTC 串 1986-05-02 05:30:00|1986-05-03 05:30:00|1986-05-04 05:30:00|1986-05-05 05:30:00
  assert_eq(
    md_tag("30 1 * * *", "Asia/Tehran", 515376000000L, 515808000000L, 4, false),
    "[515455200000|515541600000|515628000000|515714400000]",
  ) // 腿 C M.span_dst_cn.MIN.Asia/Tehran|参照 UTC 串 1986-05-02 22:00:00|1986-05-03 22:00:00|1986-05-04 22:00:00|1986-05-05 22:00:00
  assert_eq(
    md_tag("0 0 0 29 2 *", "UTC", 1704067200000L, 1735689600000L, 3, true),
    "[1709164800000]",
  ) // 腿 C M.leap_feb.SEC.UTC|参照 UTC 串 2024-02-29 00:00:00
  assert_eq(
    md_tag(
      "0 0 0 29 2 *", "Asia/Shanghai", 1704067200000L, 1735689600000L, 3, true,
    ),
    "[1709136000000]",
  ) // 腿 C M.leap_feb.SEC.Asia/Shanghai|参照 UTC 串 2024-02-28 16:00:00
  assert_eq(
    md_tag(
      "0 0 0 29 2 *", "America/New_York", 1704067200000L, 1735689600000L, 3, true,
    ),
    "[1709182800000]",
  ) // 腿 C M.leap_feb.SEC.America/New_York|参照 UTC 串 2024-02-29 05:00:00
  assert_eq(
    md_tag(
      "0 0 0 29 2 *", "Asia/Kathmandu", 1704067200000L, 1735689600000L, 3, true,
    ),
    "[1709144100000]",
  ) // 腿 C M.leap_feb.SEC.Asia/Kathmandu|参照 UTC 串 2024-02-28 18:15:00
  assert_eq(
    md_tag(
      "0 0 0 29 2 *", "Australia/Lord_Howe", 1704067200000L, 1735689600000L, 3, true,
    ),
    "[1709125200000]",
  ) // 腿 C M.leap_feb.SEC.Australia/Lord_Howe|参照 UTC 串 2024-02-28 13:00:00
  assert_eq(
    md_tag(
      "0 0 0 29 2 *", "America/Santiago", 1704067200000L, 1735689600000L, 3, true,
    ),
    "[1709175600000]",
  ) // 腿 C M.leap_feb.SEC.America/Santiago|参照 UTC 串 2024-02-29 03:00:00
  assert_eq(
    md_tag(
      "0 0 0 29 2 *", "Asia/Tehran", 1704067200000L, 1735689600000L, 3, true,
    ),
    "[1709152200000]",
  ) // 腿 C M.leap_feb.SEC.Asia/Tehran|参照 UTC 串 2024-02-28 20:30:00
  assert_eq(
    md_tag("0 0 * * 1", "UTC", 1710028800000L, 1711324800000L, 3, false),
    "[1710115200000|1710720000000]",
  ) // 腿 C M.dow_mon.MIN.UTC|参照 UTC 串 2024-03-11 00:00:00|2024-03-18 00:00:00
  assert_eq(
    md_tag(
      "0 0 * * 1", "Asia/Shanghai", 1710028800000L, 1711324800000L, 3, false,
    ),
    "[1710086400000|1710691200000|1711296000000]",
  ) // 腿 C M.dow_mon.MIN.Asia/Shanghai|参照 UTC 串 2024-03-10 16:00:00|2024-03-17 16:00:00|2024-03-24 16:00:00
  assert_eq(
    md_tag(
      "0 0 * * 1", "America/New_York", 1710028800000L, 1711324800000L, 3, false,
    ),
    "[1710129600000|1710734400000]",
  ) // 腿 C M.dow_mon.MIN.America/New_York|参照 UTC 串 2024-03-11 04:00:00|2024-03-18 04:00:00
  assert_eq(
    md_tag(
      "0 0 * * 1", "Asia/Kathmandu", 1710028800000L, 1711324800000L, 3, false,
    ),
    "[1710094500000|1710699300000|1711304100000]",
  ) // 腿 C M.dow_mon.MIN.Asia/Kathmandu|参照 UTC 串 2024-03-10 18:15:00|2024-03-17 18:15:00|2024-03-24 18:15:00
  assert_eq(
    md_tag(
      "0 0 * * 1", "Australia/Lord_Howe", 1710028800000L, 1711324800000L, 3, false,
    ),
    "[1710075600000|1710680400000|1711285200000]",
  ) // 腿 C M.dow_mon.MIN.Australia/Lord_Howe|参照 UTC 串 2024-03-10 13:00:00|2024-03-17 13:00:00|2024-03-24 13:00:00
  assert_eq(
    md_tag(
      "0 0 * * 1", "America/Santiago", 1710028800000L, 1711324800000L, 3, false,
    ),
    "[1710126000000|1710730800000]",
  ) // 腿 C M.dow_mon.MIN.America/Santiago|参照 UTC 串 2024-03-11 03:00:00|2024-03-18 03:00:00
  assert_eq(
    md_tag("0 0 * * 1", "Asia/Tehran", 1710028800000L, 1711324800000L, 3, false),
    "[1710102600000|1710707400000|1711312200000]",
  ) // 腿 C M.dow_mon.MIN.Asia/Tehran|参照 UTC 串 2024-03-10 20:30:00|2024-03-17 20:30:00|2024-03-24 20:30:00
  assert_eq(
    md_tag("* * * * *", "UTC", 1710050430000L, 1710050730000L, 3, false),
    "[1710050430000|1710050490000|1710050550000]",
  ) // 腿 C M.phase_sec30.MIN.UTC|参照 UTC 串 2024-03-10 06:00:30|2024-03-10 06:01:30|2024-03-10 06:02:30
  assert_eq(
    md_tag(
      "* * * * *", "Asia/Shanghai", 1710050430000L, 1710050730000L, 3, false,
    ),
    "[1710050430000|1710050490000|1710050550000]",
  ) // 腿 C M.phase_sec30.MIN.Asia/Shanghai|参照 UTC 串 2024-03-10 06:00:30|2024-03-10 06:01:30|2024-03-10 06:02:30
  assert_eq(
    md_tag(
      "* * * * *", "America/New_York", 1710050430000L, 1710050730000L, 3, false,
    ),
    "[1710050430000|1710050490000|1710050550000]",
  ) // 腿 C M.phase_sec30.MIN.America/New_York|参照 UTC 串 2024-03-10 06:00:30|2024-03-10 06:01:30|2024-03-10 06:02:30
  assert_eq(
    md_tag(
      "* * * * *", "Asia/Kathmandu", 1710050430000L, 1710050730000L, 3, false,
    ),
    "[1710050430000|1710050490000|1710050550000]",
  ) // 腿 C M.phase_sec30.MIN.Asia/Kathmandu|参照 UTC 串 2024-03-10 06:00:30|2024-03-10 06:01:30|2024-03-10 06:02:30
  assert_eq(
    md_tag(
      "* * * * *", "Australia/Lord_Howe", 1710050430000L, 1710050730000L, 3, false,
    ),
    "[1710050430000|1710050490000|1710050550000]",
  ) // 腿 C M.phase_sec30.MIN.Australia/Lord_Howe|参照 UTC 串 2024-03-10 06:00:30|2024-03-10 06:01:30|2024-03-10 06:02:30
  assert_eq(
    md_tag(
      "* * * * *", "America/Santiago", 1710050430000L, 1710050730000L, 3, false,
    ),
    "[1710050430000|1710050490000|1710050550000]",
  ) // 腿 C M.phase_sec30.MIN.America/Santiago|参照 UTC 串 2024-03-10 06:00:30|2024-03-10 06:01:30|2024-03-10 06:02:30
  assert_eq(
    md_tag("* * * * *", "Asia/Tehran", 1710050430000L, 1710050730000L, 3, false),
    "[1710050430000|1710050490000|1710050550000]",
  ) // 腿 C M.phase_sec30.MIN.Asia/Tehran|参照 UTC 串 2024-03-10 06:00:30|2024-03-10 06:01:30|2024-03-10 06:02:30
  assert_eq(
    md_tag("* 1 * * *", "UTC", 1730606400000L, 1730620800000L, 65, false),
    "[]",
  ) // 腿 C M.fold_hour_all_min.MIN.UTC|参照 UTC 串 <none>
  assert_eq(
    md_tag(
      "* 1 * * *", "Asia/Shanghai", 1730606400000L, 1730620800000L, 65, false,
    ),
    "[]",
  ) // 腿 C M.fold_hour_all_min.MIN.Asia/Shanghai|参照 UTC 串 <none>
  assert_eq(
    md_tag(
      "* 1 * * *", "America/New_York", 1730606400000L, 1730620800000L, 65, false,
    ),
    "[1730610000000|1730610060000|1730610120000|1730610180000|1730610240000|1730610300000|1730610360000|1730610420000|1730610480000|1730610540000|1730610600000|1730610660000|1730610720000|1730610780000|1730610840000|1730610900000|1730610960000|1730611020000|1730611080000|1730611140000|1730611200000|1730611260000|1730611320000|1730611380000|1730611440000|1730611500000|1730611560000|1730611620000|1730611680000|1730611740000|1730611800000|1730611860000|1730611920000|1730611980000|1730612040000|1730612100000|1730612160000|1730612220000|1730612280000|1730612340000|1730612400000|1730612460000|1730612520000|1730612580000|1730612640000|1730612700000|1730612760000|1730612820000|1730612880000|1730612940000|1730613000000|1730613060000|1730613120000|1730613180000|1730613240000|1730613300000|1730613360000|1730613420000|1730613480000|1730613540000|1730613600000|1730613660000|1730613720000|1730613780000|1730613840000]",
  ) // 腿 C M.fold_hour_all_min.MIN.America/New_York|参照 UTC 串 2024-11-03 05:00:00|2024-11-03 05:01:00|2024-11-03 05:02:00|2024-11-03 05:03:00|2024-11-03 05:04:00|2024-11-03 05:05:00|2024-11-03 05:06:00|2024-11-03 05:07:00|2024-11-03 05:08:00|2024-11-03 05:09:00|2024-11-03 05:10:00|2024-11-03 05:11:00|2024-11-03 05:12:00|2024-11-03 05:13:00|2024-11-03 05:14:00|2024-11-03 05:15:00|2024-11-03 05:16:00|2024-11-03 05:17:00|2024-11-03 05:18:00|2024-11-03 05:19:00|2024-11-03 05:20:00|2024-11-03 05:21:00|2024-11-03 05:22:00|2024-11-03 05:23:00|2024-11-03 05:24:00|2024-11-03 05:25:00|2024-11-03 05:26:00|2024-11-03 05:27:00|2024-11-03 05:28:00|2024-11-03 05:29:00|2024-11-03 05:30:00|2024-11-03 05:31:00|2024-11-03 05:32:00|2024-11-03 05:33:00|2024-11-03 05:34:00|2024-11-03 05:35:00|2024-11-03 05:36:00|2024-11-03 05:37:00|2024-11-03 05:38:00|2024-11-03 05:39:00|2024-11-03 05:40:00|2024-11-03 05:41:00|2024-11-03 05:42:00|2024-11-03 05:43:00|2024-11-03 05:44:00|2024-11-03 05:45:00|2024-11-03 05:46:00|2024-11-03 05:47:00|2024-11-03 05:48:00|2024-11-03 05:49:00|2024-11-03 05:50:00|2024-11-03 05:51:00|2024-11-03 05:52:00|2024-11-03 05:53:00|2024-11-03 05:54:00|2024-11-03 05:55:00|2024-11-03 05:56:00|2024-11-03 05:57:00|2024-11-03 05:58:00|2024-11-03 05:59:00|2024-11-03 06:00:00|2024-11-03 06:01:00|2024-11-03 06:02:00|2024-11-03 06:03:00|2024-11-03 06:04:00
  assert_eq(
    md_tag(
      "* 1 * * *", "Asia/Kathmandu", 1730606400000L, 1730620800000L, 65, false,
    ),
    "[]",
  ) // 腿 C M.fold_hour_all_min.MIN.Asia/Kathmandu|参照 UTC 串 <none>
  assert_eq(
    md_tag(
      "* 1 * * *", "Australia/Lord_Howe", 1730606400000L, 1730620800000L, 65, false,
    ),
    "[]",
  ) // 腿 C M.fold_hour_all_min.MIN.Australia/Lord_Howe|参照 UTC 串 <none>
  assert_eq(
    md_tag(
      "* 1 * * *", "America/Santiago", 1730606400000L, 1730620800000L, 65, false,
    ),
    "[1730606400000|1730606460000|1730606520000|1730606580000|1730606640000|1730606700000|1730606760000|1730606820000|1730606880000|1730606940000|1730607000000|1730607060000|1730607120000|1730607180000|1730607240000|1730607300000|1730607360000|1730607420000|1730607480000|1730607540000|1730607600000|1730607660000|1730607720000|1730607780000|1730607840000|1730607900000|1730607960000|1730608020000|1730608080000|1730608140000|1730608200000|1730608260000|1730608320000|1730608380000|1730608440000|1730608500000|1730608560000|1730608620000|1730608680000|1730608740000|1730608800000|1730608860000|1730608920000|1730608980000|1730609040000|1730609100000|1730609160000|1730609220000|1730609280000|1730609340000|1730609400000|1730609460000|1730609520000|1730609580000|1730609640000|1730609700000|1730609760000|1730609820000|1730609880000|1730609940000]",
  ) // 腿 C M.fold_hour_all_min.MIN.America/Santiago|参照 UTC 串 2024-11-03 04:00:00|2024-11-03 04:01:00|2024-11-03 04:02:00|2024-11-03 04:03:00|2024-11-03 04:04:00|2024-11-03 04:05:00|2024-11-03 04:06:00|2024-11-03 04:07:00|2024-11-03 04:08:00|2024-11-03 04:09:00|2024-11-03 04:10:00|2024-11-03 04:11:00|2024-11-03 04:12:00|2024-11-03 04:13:00|2024-11-03 04:14:00|2024-11-03 04:15:00|2024-11-03 04:16:00|2024-11-03 04:17:00|2024-11-03 04:18:00|2024-11-03 04:19:00|2024-11-03 04:20:00|2024-11-03 04:21:00|2024-11-03 04:22:00|2024-11-03 04:23:00|2024-11-03 04:24:00|2024-11-03 04:25:00|2024-11-03 04:26:00|2024-11-03 04:27:00|2024-11-03 04:28:00|2024-11-03 04:29:00|2024-11-03 04:30:00|2024-11-03 04:31:00|2024-11-03 04:32:00|2024-11-03 04:33:00|2024-11-03 04:34:00|2024-11-03 04:35:00|2024-11-03 04:36:00|2024-11-03 04:37:00|2024-11-03 04:38:00|2024-11-03 04:39:00|2024-11-03 04:40:00|2024-11-03 04:41:00|2024-11-03 04:42:00|2024-11-03 04:43:00|2024-11-03 04:44:00|2024-11-03 04:45:00|2024-11-03 04:46:00|2024-11-03 04:47:00|2024-11-03 04:48:00|2024-11-03 04:49:00|2024-11-03 04:50:00|2024-11-03 04:51:00|2024-11-03 04:52:00|2024-11-03 04:53:00|2024-11-03 04:54:00|2024-11-03 04:55:00|2024-11-03 04:56:00|2024-11-03 04:57:00|2024-11-03 04:58:00|2024-11-03 04:59:00
  assert_eq(
    md_tag(
      "* 1 * * *", "Asia/Tehran", 1730606400000L, 1730620800000L, 65, false,
    ),
    "[]",
  ) // 腿 C M.fold_hour_all_min.MIN.Asia/Tehran|参照 UTC 串 <none>
  assert_eq(
    md_tag("30 0 * * * *", "UTC", 1710050400000L, 1710050580000L, 3, false),
    "[1710050400000]",
  ) // 腿 C M.sec30_min_off.MIN.UTC|参照 UTC 串 2024-03-10 06:00:00
  assert_eq(
    md_tag(
      "30 0 * * * *", "Asia/Shanghai", 1710050400000L, 1710050580000L, 3, false,
    ),
    "[1710050400000]",
  ) // 腿 C M.sec30_min_off.MIN.Asia/Shanghai|参照 UTC 串 2024-03-10 06:00:00
  assert_eq(
    md_tag(
      "30 0 * * * *", "America/New_York", 1710050400000L, 1710050580000L, 3, false,
    ),
    "[1710050400000]",
  ) // 腿 C M.sec30_min_off.MIN.America/New_York|参照 UTC 串 2024-03-10 06:00:00
  assert_eq(
    md_tag(
      "30 0 * * * *", "Asia/Kathmandu", 1710050400000L, 1710050580000L, 3, false,
    ),
    "[]",
  ) // 腿 C M.sec30_min_off.MIN.Asia/Kathmandu|参照 UTC 串 <none>
  assert_eq(
    md_tag(
      "30 0 * * * *", "Australia/Lord_Howe", 1710050400000L, 1710050580000L, 3, false,
    ),
    "[1710050400000]",
  ) // 腿 C M.sec30_min_off.MIN.Australia/Lord_Howe|参照 UTC 串 2024-03-10 06:00:00
  assert_eq(
    md_tag(
      "30 0 * * * *", "America/Santiago", 1710050400000L, 1710050580000L, 3, false,
    ),
    "[1710050400000]",
  ) // 腿 C M.sec30_min_off.MIN.America/Santiago|参照 UTC 串 2024-03-10 06:00:00
  assert_eq(
    md_tag(
      "30 0 * * * *", "Asia/Tehran", 1710050400000L, 1710050580000L, 3, false,
    ),
    "[]",
  ) // 腿 C M.sec30_min_off.MIN.Asia/Tehran|参照 UTC 串 <none>
}

///|
test "@cron2 count 边界与窗口判据（腿 C 的 CB/E 行，第 1 块 6 条）" {
  assert_eq(
    md_len_tag("* * * * *", "UTC", 1710050400000L, 1710051000000L, -1),
    "0",
  ) // count<=0 ⇒ 空表（spec §11 第 2 行）；参照原读数 CB.count=-1 ERR|ERR_java.lang.IllegalArgumentException|Illegal Capacity: -1
  assert_eq(
    md_len_tag("* * * * *", "UTC", 1710050400000L, 1710051000000L, 0),
    "0",
  ) // count<=0 ⇒ 空表（spec §11 第 2 行）；参照原读数 CB.count=0 RET|1
  assert_eq(
    md_len_tag("* * * * *", "UTC", 1710050400000L, 1710051000000L, 1),
    "1",
  ) // 腿 C CB.count=1 ⇒ 参照给 1 条
  assert_eq(
    md_len_tag("* * * * *", "UTC", 1710050400000L, 1710051000000L, 2),
    "2",
  ) // 腿 C CB.count=2 ⇒ 参照给 2 条
  assert_eq(
    md_tag("* * * * *", "UTC", 1710050460000L, 1710050400000L, 3, false),
    "ERR:BadRange[1710050460000,1710050400000]",
  ) // 腿 C E.start_gt_end|ERR_java.lang.IllegalArgumentException|Start date is later than end ! ⇒ 本库留变体 BadRange（spec §11 第 7 行）
  assert_eq(
    md_tag("* * * * *", "UTC", 1710050400000L, 1710050400000L, 3, false),
    "ERR:BadRange[1710050400000,1710050400000]",
  ) // 腿 C E.start_eq_end|ERR_java.lang.IllegalArgumentException|Start date is later than end ! ⇒ 本库留变体 BadRange（spec §11 第 7 行）
}

///|
test "@cron2 参照的废弃三参与二参同值（腿 C 的 D3 行留案，第 1 块 3 条）" {
  assert_eq("1710050460000", "1710050460000") // 腿 C D3.* * * * *.1710050400000 ⇒ 二参与三参逐字节同值，那个布尔确实是死的（spec §8"不收"表）
  assert_eq("1730655000000", "1730655000000") // 腿 C D3.0 30 1 * * *.1730611800000 ⇒ 二参与三参逐字节同值，那个布尔确实是死的（spec §8"不收"表）
  assert_eq("1835366400000", "1835366400000") // 腿 C D3.0 0 0 29 2 *.1709208000000 ⇒ 二参与三参逐字节同值，那个布尔确实是死的（spec §8"不收"表）
}
