///|
// moon-hutool/cron 第二批契约用例（黑盒）。**生成件，勿手改**：
// 生成器 scripts/gen_cron2_test.py，每条期望都是参照腿 scripts/Cron2Leg.java 的机器读数。
// 参照代次：JDK 17.0.14 · hutool-cron+core 5.8.35 · lib/tzdb.dat 101731 bytes · 腿的守卫自检 GUARD_DISTINCT=true。
// 三处本库改判（设年未设秒 / `count <= 0` / 窗外）集中在生成器的 DECISION_BUILDER 与两处分支里，每格都注了依据的 spec 行号与参照原读数（spec §11）。
// helper `tag` / `parse_text` 复用 cron/cron_test.mbt 的同名件（同包测试共享顶层命名空间）。

///|
// 建造器每一格的配方（与 scripts/Cron2Leg.java 的 bcases 逐项对应）。参照的校验期点在 setter 那一格，`build()` 自己不抛（spec §9 第 4 条）。
fn pb_case(name : String) -> @cron.CronBuilder raise @cron.CronError {
  match name {
    "empty" => @cron.cron_builder_new()
    "minute_only" =>
      @cron.cron_builder_set(
        @cron.cron_builder_new(),
        @cron.CronPart::Minute,
        "*/5",
      )
    "values_hour" =>
      @cron.cron_builder_set_values(
        @cron.cron_builder_new(),
        @cron.CronPart::Hour,
        [1, 2, 3],
      )
    "range_dom" =>
      @cron.cron_builder_set_range(
        @cron.cron_builder_new(),
        @cron.CronPart::DayOfMonth,
        1,
        15,
      )
    "second_set" =>
      @cron.cron_builder_set(
        @cron.cron_builder_new(),
        @cron.CronPart::Second,
        "30",
      )
    "year_only_no_second" =>
      @cron.cron_builder_set(
        @cron.cron_builder_new(),
        @cron.CronPart::Year,
        "2030",
      )
    "second_and_year" =>
      @cron.cron_builder_set(
        @cron.cron_builder_set(
          @cron.cron_builder_new(),
          @cron.CronPart::Second,
          "0",
        ),
        @cron.CronPart::Year,
        "2030",
      )
    "blank_minute" =>
      @cron.cron_builder_set(
        @cron.cron_builder_new(),
        @cron.CronPart::Minute,
        "",
      )
    "space_minute" =>
      @cron.cron_builder_set(
        @cron.cron_builder_new(),
        @cron.CronPart::Minute,
        "  ",
      )
    "range_reversed" =>
      @cron.cron_builder_set_range(
        @cron.cron_builder_new(),
        @cron.CronPart::DayOfMonth,
        20,
        5,
      )
    "values_with_second" =>
      @cron.cron_builder_set_values(
        @cron.cron_builder_set(
          @cron.cron_builder_new(),
          @cron.CronPart::Second,
          "0",
        ),
        @cron.CronPart::Minute,
        [0, 30],
      )
    "values_empty" =>
      @cron.cron_builder_set_values(
        @cron.cron_builder_new(),
        @cron.CronPart::Minute,
        [],
      )
    "values_empty_second" =>
      @cron.cron_builder_set_values(
        @cron.cron_builder_new(),
        @cron.CronPart::Second,
        [],
      )
    "values_empty_year" =>
      @cron.cron_builder_set_values(
        @cron.cron_builder_new(),
        @cron.CronPart::Year,
        [],
      )
    "blank_second" =>
      @cron.cron_builder_set(
        @cron.cron_builder_new(),
        @cron.CronPart::Second,
        "",
      )
    "space_year" =>
      @cron.cron_builder_set(
        @cron.cron_builder_new(),
        @cron.CronPart::Year,
        " ",
      )
    "blank_second_with_year" =>
      @cron.cron_builder_set(
        @cron.cron_builder_set(
          @cron.cron_builder_new(),
          @cron.CronPart::Second,
          "",
        ),
        @cron.CronPart::Year,
        "2030",
      )
    "dow_seven" =>
      @cron.cron_builder_set(
        @cron.cron_builder_new(),
        @cron.CronPart::DayOfWeek,
        "7",
      )
    "junk_minute" =>
      @cron.cron_builder_set(
        @cron.cron_builder_new(),
        @cron.CronPart::Minute,
        "abc",
      )
    "values_out_of_range" =>
      @cron.cron_builder_set_values(
        @cron.cron_builder_new(),
        @cron.CronPart::Hour,
        [25],
      )
    "range_out_of_range" =>
      @cron.cron_builder_set_range(
        @cron.cron_builder_new(),
        @cron.CronPart::Minute,
        -1,
        5,
      )
    "second_out_of_range" =>
      @cron.cron_builder_set_values(
        @cron.cron_builder_new(),
        @cron.CronPart::Second,
        [60],
      )
    _ =>
      abort("配方表漏格（必须与腿的 bcases 同清单）：" + name)
  }
}

///|
// #19.16 的读数：`OK:<build 出的串>` 或 `ERR:<本库错误档>`
fn pb_tag(name : String) -> String {
  try "OK:" + @cron.cron_builder_build(pb_case(name)) catch {
    e => "ERR:" + tag(e)
  }
}

///|
// 回环读数：把 build 的串喂回 #19.1（参照的 `RT` 行走的就是这条路）
fn pb_round_tag(name : String) -> String {
  parse_text(@cron.cron_builder_build(pb_case(name))) catch {
    e => "ERR:" + tag(e)
  }
}

///|
// #19.10 的读数：`RET:<原值>` 或 `ERR:<本库错误档>`
fn cv_tag(p : @cron.CronPart, v : Int) -> String {
  try "RET:" + @cron.cron_part_check_value(p, v).to_string() catch {
    e => "ERR:" + tag(e)
  }
}

///|
test "@cron2 七段的段名与界（腿 C 的 P 行，第 1 块 21 条）" {
  assert_eq(@cron.cron_part_name(@cron.CronPart::Second), "SECOND") // 腿 C P.SECOND 段名列
  assert_eq(@cron.cron_part_min(@cron.CronPart::Second), 0) // 腿 C P.SECOND min 列
  assert_eq(@cron.cron_part_max(@cron.CronPart::Second), 59) // 腿 C P.SECOND max 列
  assert_eq(@cron.cron_part_name(@cron.CronPart::Minute), "MINUTE") // 腿 C P.MINUTE 段名列
  assert_eq(@cron.cron_part_min(@cron.CronPart::Minute), 0) // 腿 C P.MINUTE min 列
  assert_eq(@cron.cron_part_max(@cron.CronPart::Minute), 59) // 腿 C P.MINUTE max 列
  assert_eq(@cron.cron_part_name(@cron.CronPart::Hour), "HOUR") // 腿 C P.HOUR 段名列
  assert_eq(@cron.cron_part_min(@cron.CronPart::Hour), 0) // 腿 C P.HOUR min 列
  assert_eq(@cron.cron_part_max(@cron.CronPart::Hour), 23) // 腿 C P.HOUR max 列
  assert_eq(@cron.cron_part_name(@cron.CronPart::DayOfMonth), "DAY_OF_MONTH") // 腿 C P.DAY_OF_MONTH 段名列
  assert_eq(@cron.cron_part_min(@cron.CronPart::DayOfMonth), 1) // 腿 C P.DAY_OF_MONTH min 列
  assert_eq(@cron.cron_part_max(@cron.CronPart::DayOfMonth), 31) // 腿 C P.DAY_OF_MONTH max 列
  assert_eq(@cron.cron_part_name(@cron.CronPart::Month), "MONTH") // 腿 C P.MONTH 段名列
  assert_eq(@cron.cron_part_min(@cron.CronPart::Month), 1) // 腿 C P.MONTH min 列
  assert_eq(@cron.cron_part_max(@cron.CronPart::Month), 12) // 腿 C P.MONTH max 列
  assert_eq(@cron.cron_part_name(@cron.CronPart::DayOfWeek), "DAY_OF_WEEK") // 腿 C P.DAY_OF_WEEK 段名列
  assert_eq(@cron.cron_part_min(@cron.CronPart::DayOfWeek), 0) // 腿 C P.DAY_OF_WEEK min 列
  assert_eq(@cron.cron_part_max(@cron.CronPart::DayOfWeek), 6) // 腿 C P.DAY_OF_WEEK max 列
  assert_eq(@cron.cron_part_name(@cron.CronPart::Year), "YEAR") // 腿 C P.YEAR 段名列
  assert_eq(@cron.cron_part_min(@cron.CronPart::Year), 1970) // 腿 C P.YEAR min 列
  assert_eq(@cron.cron_part_max(@cron.CronPart::Year), 2099) // 腿 C P.YEAR max 列
}

///|
test "@cron2 单值校验判而不变（腿 C 的 C 行去重后，第 1 块 61 条）" {
  assert_eq(cv_tag(@cron.CronPart::Second, 0), "RET:0") // 腿 C C.SECOND.0 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Second, 59), "RET:59") // 腿 C C.SECOND.59 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Second, -1), "ERR:OutOfRange[SECOND,-1]") // 腿 C C.SECOND.-1 ERR|SECOND value -1 out of range: [0 , 59]
  assert_eq(cv_tag(@cron.CronPart::Second, 60), "ERR:OutOfRange[SECOND,60]") // 腿 C C.SECOND.60 ERR|SECOND value 60 out of range: [0 , 59]
  assert_eq(cv_tag(@cron.CronPart::Second, 7), "RET:7") // 腿 C C.SECOND.7 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Second, 24), "RET:24") // 腿 C C.SECOND.24 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Second, 13), "RET:13") // 腿 C C.SECOND.13 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Second, 1970), "ERR:OutOfRange[SECOND,1970]") // 腿 C C.SECOND.1970 ERR|SECOND value 1970 out of range: [0 , 59]
  assert_eq(cv_tag(@cron.CronPart::Minute, 0), "RET:0") // 腿 C C.MINUTE.0 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Minute, 59), "RET:59") // 腿 C C.MINUTE.59 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Minute, -1), "ERR:OutOfRange[MINUTE,-1]") // 腿 C C.MINUTE.-1 ERR|MINUTE value -1 out of range: [0 , 59]
  assert_eq(cv_tag(@cron.CronPart::Minute, 60), "ERR:OutOfRange[MINUTE,60]") // 腿 C C.MINUTE.60 ERR|MINUTE value 60 out of range: [0 , 59]
  assert_eq(cv_tag(@cron.CronPart::Minute, 7), "RET:7") // 腿 C C.MINUTE.7 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Minute, 24), "RET:24") // 腿 C C.MINUTE.24 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Minute, 13), "RET:13") // 腿 C C.MINUTE.13 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Minute, 1970), "ERR:OutOfRange[MINUTE,1970]") // 腿 C C.MINUTE.1970 ERR|MINUTE value 1970 out of range: [0 , 59]
  assert_eq(cv_tag(@cron.CronPart::Hour, 0), "RET:0") // 腿 C C.HOUR.0 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Hour, 23), "RET:23") // 腿 C C.HOUR.23 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Hour, -1), "ERR:OutOfRange[HOUR,-1]") // 腿 C C.HOUR.-1 ERR|HOUR value -1 out of range: [0 , 23]
  assert_eq(cv_tag(@cron.CronPart::Hour, 24), "ERR:OutOfRange[HOUR,24]") // 腿 C C.HOUR.24 ERR|HOUR value 24 out of range: [0 , 23]
  assert_eq(cv_tag(@cron.CronPart::Hour, 60), "ERR:OutOfRange[HOUR,60]") // 腿 C C.HOUR.60 ERR|HOUR value 60 out of range: [0 , 23]
  assert_eq(cv_tag(@cron.CronPart::Hour, 7), "RET:7") // 腿 C C.HOUR.7 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Hour, 13), "RET:13") // 腿 C C.HOUR.13 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Hour, 1970), "ERR:OutOfRange[HOUR,1970]") // 腿 C C.HOUR.1970 ERR|HOUR value 1970 out of range: [0 , 23]
  assert_eq(cv_tag(@cron.CronPart::DayOfMonth, 1), "RET:1") // 腿 C C.DAY_OF_MONTH.1 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::DayOfMonth, 31), "RET:31") // 腿 C C.DAY_OF_MONTH.31 RET ⇒ 判而不变，原样返回
  assert_eq(
    cv_tag(@cron.CronPart::DayOfMonth, 0),
    "ERR:OutOfRange[DAY_OF_MONTH,0]",
  ) // 腿 C C.DAY_OF_MONTH.0 ERR|DAY_OF_MONTH value 0 out of range: [1 , 31]
  assert_eq(
    cv_tag(@cron.CronPart::DayOfMonth, 32),
    "ERR:OutOfRange[DAY_OF_MONTH,32]",
  ) // 腿 C C.DAY_OF_MONTH.32 ERR|DAY_OF_MONTH value 32 out of range: [1 , 31]
  assert_eq(
    cv_tag(@cron.CronPart::DayOfMonth, -1),
    "ERR:OutOfRange[DAY_OF_MONTH,-1]",
  ) // 腿 C C.DAY_OF_MONTH.-1 ERR|DAY_OF_MONTH value -1 out of range: [1 , 31]
  assert_eq(
    cv_tag(@cron.CronPart::DayOfMonth, 60),
    "ERR:OutOfRange[DAY_OF_MONTH,60]",
  ) // 腿 C C.DAY_OF_MONTH.60 ERR|DAY_OF_MONTH value 60 out of range: [1 , 31]
  assert_eq(cv_tag(@cron.CronPart::DayOfMonth, 7), "RET:7") // 腿 C C.DAY_OF_MONTH.7 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::DayOfMonth, 24), "RET:24") // 腿 C C.DAY_OF_MONTH.24 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::DayOfMonth, 13), "RET:13") // 腿 C C.DAY_OF_MONTH.13 RET ⇒ 判而不变，原样返回
  assert_eq(
    cv_tag(@cron.CronPart::DayOfMonth, 1970),
    "ERR:OutOfRange[DAY_OF_MONTH,1970]",
  ) // 腿 C C.DAY_OF_MONTH.1970 ERR|DAY_OF_MONTH value 1970 out of range: [1 , 31]
  assert_eq(cv_tag(@cron.CronPart::Month, 1), "RET:1") // 腿 C C.MONTH.1 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Month, 12), "RET:12") // 腿 C C.MONTH.12 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Month, 0), "ERR:OutOfRange[MONTH,0]") // 腿 C C.MONTH.0 ERR|MONTH value 0 out of range: [1 , 12]
  assert_eq(cv_tag(@cron.CronPart::Month, 13), "ERR:OutOfRange[MONTH,13]") // 腿 C C.MONTH.13 ERR|MONTH value 13 out of range: [1 , 12]
  assert_eq(cv_tag(@cron.CronPart::Month, -1), "ERR:OutOfRange[MONTH,-1]") // 腿 C C.MONTH.-1 ERR|MONTH value -1 out of range: [1 , 12]
  assert_eq(cv_tag(@cron.CronPart::Month, 60), "ERR:OutOfRange[MONTH,60]") // 腿 C C.MONTH.60 ERR|MONTH value 60 out of range: [1 , 12]
  assert_eq(cv_tag(@cron.CronPart::Month, 7), "RET:7") // 腿 C C.MONTH.7 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Month, 24), "ERR:OutOfRange[MONTH,24]") // 腿 C C.MONTH.24 ERR|MONTH value 24 out of range: [1 , 12]
  assert_eq(cv_tag(@cron.CronPart::Month, 1970), "ERR:OutOfRange[MONTH,1970]") // 腿 C C.MONTH.1970 ERR|MONTH value 1970 out of range: [1 , 12]
  assert_eq(cv_tag(@cron.CronPart::DayOfWeek, 0), "RET:0") // 腿 C C.DAY_OF_WEEK.0 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::DayOfWeek, 6), "RET:6") // 腿 C C.DAY_OF_WEEK.6 RET ⇒ 判而不变，原样返回
  assert_eq(
    cv_tag(@cron.CronPart::DayOfWeek, -1),
    "ERR:OutOfRange[DAY_OF_WEEK,-1]",
  ) // 腿 C C.DAY_OF_WEEK.-1 ERR|DAY_OF_WEEK value -1 out of range: [0 , 6]
  assert_eq(
    cv_tag(@cron.CronPart::DayOfWeek, 7),
    "ERR:OutOfRange[DAY_OF_WEEK,7]",
  ) // 腿 C C.DAY_OF_WEEK.7 ERR|DAY_OF_WEEK value 7 out of range: [0 , 6]
  assert_eq(
    cv_tag(@cron.CronPart::DayOfWeek, 60),
    "ERR:OutOfRange[DAY_OF_WEEK,60]",
  ) // 腿 C C.DAY_OF_WEEK.60 ERR|DAY_OF_WEEK value 60 out of range: [0 , 6]
  assert_eq(
    cv_tag(@cron.CronPart::DayOfWeek, 24),
    "ERR:OutOfRange[DAY_OF_WEEK,24]",
  ) // 腿 C C.DAY_OF_WEEK.24 ERR|DAY_OF_WEEK value 24 out of range: [0 , 6]
  assert_eq(
    cv_tag(@cron.CronPart::DayOfWeek, 13),
    "ERR:OutOfRange[DAY_OF_WEEK,13]",
  ) // 腿 C C.DAY_OF_WEEK.13 ERR|DAY_OF_WEEK value 13 out of range: [0 , 6]
  assert_eq(
    cv_tag(@cron.CronPart::DayOfWeek, 1970),
    "ERR:OutOfRange[DAY_OF_WEEK,1970]",
  ) // 腿 C C.DAY_OF_WEEK.1970 ERR|DAY_OF_WEEK value 1970 out of range: [0 , 6]
  assert_eq(cv_tag(@cron.CronPart::Year, 1970), "RET:1970") // 腿 C C.YEAR.1970 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Year, 2099), "RET:2099") // 腿 C C.YEAR.2099 RET ⇒ 判而不变，原样返回
  assert_eq(cv_tag(@cron.CronPart::Year, 1969), "ERR:OutOfRange[YEAR,1969]") // 腿 C C.YEAR.1969 ERR|YEAR value 1969 out of range: [1970 , 2099]
  assert_eq(cv_tag(@cron.CronPart::Year, 2100), "ERR:OutOfRange[YEAR,2100]") // 腿 C C.YEAR.2100 ERR|YEAR value 2100 out of range: [1970 , 2099]
  assert_eq(cv_tag(@cron.CronPart::Year, -1), "ERR:OutOfRange[YEAR,-1]") // 腿 C C.YEAR.-1 ERR|YEAR value -1 out of range: [1970 , 2099]
  assert_eq(cv_tag(@cron.CronPart::Year, 60), "ERR:OutOfRange[YEAR,60]") // 腿 C C.YEAR.60 ERR|YEAR value 60 out of range: [1970 , 2099]
  assert_eq(cv_tag(@cron.CronPart::Year, 7), "ERR:OutOfRange[YEAR,7]") // 腿 C C.YEAR.7 ERR|YEAR value 7 out of range: [1970 , 2099]
  assert_eq(cv_tag(@cron.CronPart::Year, 24), "ERR:OutOfRange[YEAR,24]") // 腿 C C.YEAR.24 ERR|YEAR value 24 out of range: [1970 , 2099]
  assert_eq(cv_tag(@cron.CronPart::Year, 13), "ERR:OutOfRange[YEAR,13]") // 腿 C C.YEAR.13 ERR|YEAR value 13 out of range: [1970 , 2099]
  assert_eq(cv_tag(@cron.CronPart::Year, 0), "ERR:OutOfRange[YEAR,0]") // 腿 C C.YEAR.0 ERR|YEAR value 0 out of range: [1970 , 2099]
}

// 不进夹具的格（本库形状产不出这条读数，不是漏挂）：
// K.null_minute 不进夹具：参照的 `set(part, null)` 在本库没有对应形状——未设置就是未设置，没有第二种；参照原读数 RET|* * * * * 在案

///|
test "@cron2 建造器的 build 串与回环（腿 C 的 K/RT 行，第 1 块 44 条）" {
  assert_eq(pb_tag("empty"), "OK:* * * * *") // 腿 C K.empty RET|* * * * *
  assert_eq(pb_tag("minute_only"), "OK:*/5 * * * *") // 腿 C K.minute_only RET|*/5 * * * *
  assert_eq(pb_tag("values_hour"), "OK:* 1,2,3 * * *") // 腿 C K.values_hour RET|* 1,2,3 * * *
  assert_eq(pb_tag("range_dom"), "OK:* * 1-15 * *") // 腿 C K.range_dom RET|* * 1-15 * *
  assert_eq(pb_tag("second_set"), "OK:30 * * * * *") // 腿 C K.second_set RET|30 * * * * *
  assert_eq(pb_tag("year_only_no_second"), "OK:* * * * * * 2030") // spec §11 第 1 行 ⇒ 本库补秒成 7 段；参照原读数 K.year_only_no_second RET|* * * * * 2030 在案
  assert_eq(pb_tag("second_and_year"), "OK:0 * * * * * 2030") // 腿 C K.second_and_year RET|0 * * * * * 2030
  assert_eq(pb_tag("blank_minute"), "OK:* * * * *") // 腿 C K.blank_minute RET|* * * * *
  assert_eq(pb_tag("space_minute"), "OK:* * * * *") // 腿 C K.space_minute RET|* * * * *
  assert_eq(pb_tag("range_reversed"), "OK:* * 20-5 * *") // 腿 C K.range_reversed RET|* * 20-5 * *
  assert_eq(pb_tag("values_with_second"), "OK:0 0,30 * * * *") // 腿 C K.values_with_second RET|0 0,30 * * * *
  assert_eq(pb_tag("values_empty"), "OK:* * * * *") // 腿 C K.values_empty RET|* * * * *
  assert_eq(pb_tag("values_empty_second"), "OK: * * * * *") // 腿 C K.values_empty_second RET| * * * * *
  assert_eq(pb_tag("values_empty_year"), "OK:* * * * * ") // 腿 C K.values_empty_year RET|* * * * * 
  assert_eq(pb_tag("blank_second"), "OK: * * * * *") // 腿 C K.blank_second RET| * * * * *
  assert_eq(pb_tag("space_year"), "OK:* * * * *  ") // 腿 C K.space_year RET|* * * * *  
  assert_eq(pb_tag("blank_second_with_year"), "OK:* * * * * * 2030") // spec §11 第 1 行（秒设成空白也算没给） ⇒ 本库补秒成 7 段；参照原读数 K.blank_second_with_year RET| * * * * * 2030 在案
  assert_eq(pb_tag("dow_seven"), "OK:* * * * 7") // 腿 C K.dow_seven RET|* * * * 7
  assert_eq(pb_tag("junk_minute"), "OK:abc * * * *") // 腿 C K.junk_minute RET|abc * * * *
  assert_eq(pb_tag("values_out_of_range"), "ERR:OutOfRange[HOUR,25]") // 腿 C K.values_out_of_range ERR_cn.hutool.cron.CronException|HOUR value 25 out of range: [0 , 23] ⇒ 参照在 setter 那一格就抛
  assert_eq(pb_tag("range_out_of_range"), "ERR:OutOfRange[MINUTE,-1]") // 腿 C K.range_out_of_range ERR_cn.hutool.cron.CronException|MINUTE value -1 out of range: [0 , 59] ⇒ 参照在 setter 那一格就抛
  assert_eq(pb_tag("second_out_of_range"), "ERR:OutOfRange[SECOND,60]") // 腿 C K.second_out_of_range ERR_cn.hutool.cron.CronException|SECOND value 60 out of range: [0 , 59] ⇒ 参照在 setter 那一格就抛
  assert_eq(pb_round_tag("empty"), "OK:* * * * *") // 腿 C RT.empty RET|* * * * *
  assert_eq(pb_round_tag("minute_only"), "OK:*/5 * * * *") // 腿 C RT.minute_only RET|*/5 * * * *
  assert_eq(pb_round_tag("values_hour"), "OK:* 1,2,3 * * *") // 腿 C RT.values_hour RET|* 1,2,3 * * *
  assert_eq(pb_round_tag("range_dom"), "OK:* * 1-15 * *") // 腿 C RT.range_dom RET|* * 1-15 * *
  assert_eq(pb_round_tag("second_set"), "OK:30 * * * * *") // 腿 C RT.second_set RET|30 * * * * *
  assert_eq(pb_round_tag("year_only_no_second"), "OK:* * * * * * 2030") // spec §11 第 1 行 ⇒ 本库这一格的串可解析；参照原读数 RT.year_only_no_second ERR|CronException|DAY_OF_WEEK value 2030 out of range: [0 , 6] 在案
  assert_eq(pb_round_tag("second_and_year"), "OK:0 * * * * * 2030") // 腿 C RT.second_and_year RET|0 * * * * * 2030
  assert_eq(pb_round_tag("blank_minute"), "OK:* * * * *") // 腿 C RT.blank_minute RET|* * * * *
  assert_eq(pb_round_tag("space_minute"), "OK:* * * * *") // 腿 C RT.space_minute RET|* * * * *
  assert_eq(pb_round_tag("range_reversed"), "OK:* * 20-5 * *") // 腿 C RT.range_reversed RET|* * 20-5 * *
  assert_eq(pb_round_tag("values_with_second"), "OK:0 0,30 * * * *") // 腿 C RT.values_with_second RET|0 0,30 * * * *
  assert_eq(pb_round_tag("values_empty"), "OK:* * * * *") // 腿 C RT.values_empty RET|* * * * *
  assert_eq(pb_round_tag("values_empty_second"), "OK: * * * * *") // 腿 C RT.values_empty_second RET| * * * * *
  assert_eq(pb_round_tag("values_empty_year"), "OK:* * * * * ") // 腿 C RT.values_empty_year RET|* * * * * 
  assert_eq(pb_round_tag("blank_second"), "OK: * * * * *") // 腿 C RT.blank_second RET| * * * * *
  assert_eq(pb_round_tag("space_year"), "OK:* * * * *  ") // 腿 C RT.space_year RET|* * * * *  
  assert_eq(pb_round_tag("blank_second_with_year"), "OK:* * * * * * 2030") // spec §11 第 1 行（秒设成空白也算没给） ⇒ 本库这一格的串可解析；参照原读数 RT.blank_second_with_year ERR|CronException|DAY_OF_WEEK value 2030 out of range: [0 , 6] 在案
  assert_eq(pb_round_tag("dow_seven"), "OK:* * * * 7") // 腿 C RT.dow_seven RET|* * * * 7
  assert_eq(pb_round_tag("junk_minute"), "BadAlias[abc]") // 腿 C RT.junk_minute ERR|CronException|Invalid alias value: [abc] ⇒ 本库同档
  // RT.values_out_of_range：参照没走到 build（setter 就抛）⇒ 上一条 pb_tag 已钉同一件事
  // RT.range_out_of_range：参照没走到 build（setter 就抛）⇒ 上一条 pb_tag 已钉同一件事
  // RT.second_out_of_range：参照没走到 build（setter 就抛）⇒ 上一条 pb_tag 已钉同一件事
}

///|
test "@cron2 参照段序留案（腿 C 的 O 行，第 1 块 10 条）" {
  assert_eq(@cron.cron_part_name(@cron.CronPart::Second), "SECOND") // 腿 C O.0：段序 0=SECOND；字段号 13 是 Calendar 的邻居物，不收
  assert_eq(@cron.cron_part_name(@cron.CronPart::Minute), "MINUTE") // 腿 C O.1：段序 1=MINUTE；字段号 12 是 Calendar 的邻居物，不收
  assert_eq(@cron.cron_part_name(@cron.CronPart::Hour), "HOUR") // 腿 C O.2：段序 2=HOUR；字段号 11 是 Calendar 的邻居物，不收
  assert_eq(@cron.cron_part_name(@cron.CronPart::DayOfMonth), "DAY_OF_MONTH") // 腿 C O.3：段序 3=DAY_OF_MONTH；字段号 5 是 Calendar 的邻居物，不收
  assert_eq(@cron.cron_part_name(@cron.CronPart::Month), "MONTH") // 腿 C O.4：段序 4=MONTH；字段号 2 是 Calendar 的邻居物，不收
  assert_eq(@cron.cron_part_name(@cron.CronPart::DayOfWeek), "DAY_OF_WEEK") // 腿 C O.5：段序 5=DAY_OF_WEEK；字段号 7 是 Calendar 的邻居物，不收
  assert_eq(@cron.cron_part_name(@cron.CronPart::Year), "YEAR") // 腿 C O.6：段序 6=YEAR；字段号 1 是 Calendar 的邻居物，不收
  // 腿 C O.-1：ArrayIndexOutOfBoundsException ⇒ 参照 `Part.of(-1)` 越界抛的是 ArrayIndexOutOfBoundsException，本库不导出这件（spec §8）
  // 腿 C O.7：ArrayIndexOutOfBoundsException ⇒ 参照 `Part.of(7)` 越界抛的是 ArrayIndexOutOfBoundsException，本库不导出这件（spec §8）
  // 腿 C O.99：ArrayIndexOutOfBoundsException ⇒ 参照 `Part.of(99)` 越界抛的是 ArrayIndexOutOfBoundsException，本库不导出这件（spec §8）
}
