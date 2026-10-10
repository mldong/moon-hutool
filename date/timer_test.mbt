///|
// moon-hutool/date —— 计时件的**逐档可直读**期望（第六批 §9.3、§9.5、§9.7.1/§9.7.2）。
// 由 `scripts/gen_timer_test.py` 从 `scripts/TimerLeg3.java`（SH/NF/PC）与
// `scripts/TimerLeg4.java`（CU/NS/TI）灌出来，一格都没有手打。
// 状态机、整表形状、分组计时器那批要拼夹具的档在 `date/timer_state_test.mbt`。

///|
/// 假钟：恒定给同一个读数（单位由构造口定：毫秒档就是 epoch 毫秒、纳秒档就是纳秒）
fn tm_fixed(v : Int64) -> () -> Int64 {
  () => v
}

///|
/// 脚本钟：按数组依次给读数，用尽之后重复最后一个（夹具因此只需写"变化点"）
fn tm_steps(xs : Array[Int64]) -> () -> Int64 {
  let i : Array[Int] = [0]
  () => {
    let k = i[0]
    i[0] = k + 1
    xs[if k < xs.length() { k } else { xs.length() - 1 }]
  }
}

///|
/// 跑完 `deltas` 这几段任务：每段是"这一段的纳秒数"，名字依次取 `names`（用完走缺省名）
fn tm_run(
  deltas : Array[Int64],
  names : Array[String],
  id : String,
  keep : Bool,
) -> @date.StopWatch {
  let ticks : Array[Int64] = [0L]
  let acc : Array[Int64] = [0L]
  for x in deltas {
    acc[0] = acc[0] + x
    ticks.push(acc[0])
    ticks.push(acc[0])
  }
  let sw = @date.stop_watch(tm_steps(ticks), id~, keep_task_list=keep)
  for i in 0..<deltas.length() {
    let nm = if i < names.length() { Some(names[i]) } else { Some("") }
    sw.start(name=nm) catch {
      err => abort("夹具的 start 不该抛：" + show(err))
    }
    sw.stop() catch {
      err => abort("夹具的 stop 不该抛：" + show(err))
    }
  }
  sw
}

///|
/// 单任务秒表（一条任务 `n` 纳秒，名字 `t`）
fn tm_one(n : Int64, id : String) -> @date.StopWatch {
  tm_run([n], ["t"], id, true)
}

///|
/// 取 `pretty_print` 的第 n 行（数据行从下标 4 起）
fn tm_line(s : String, n : Int) -> String {
  s.split("\n").to_array()[n].to_owned()
}

///|
/// 分组计时器夹具：脚本钟 + 依次 start 的键
fn tm_group(
  ticks : Array[Int64],
  keys : Array[String],
  nano : Bool,
) -> @date.GroupTimeInterval {
  let g = if nano {
    @date.group_time_interval_nanos(tm_steps(ticks))
  } else {
    @date.group_time_interval(tm_steps(ticks))
  }
  for k in keys {
    let _ = g.start(id=k)
  }
  g
}

///|
test "date #9.3.1 ChronoUnit::shot_name 七档（微秒是 U+03BC 不是 U+00B5）" {
  assert_eq(@date.Nanoseconds.shot_name(), "ns") // 读数腿  SH|NANOSECONDS||ns
  assert_eq(@date.Microseconds.shot_name(), "μs") // 读数腿  SH|MICROSECONDS||{u03bc}s
  assert_eq(@date.Milliseconds.shot_name(), "ms") // 读数腿  SH|MILLISECONDS||ms
  assert_eq(@date.Seconds.shot_name(), "s") // 读数腿  SH|SECONDS||s
  assert_eq(@date.Minutes.shot_name(), "min") // 读数腿  SH|MINUTES||min
  assert_eq(@date.Hours.shot_name(), "h") // 读数腿  SH|HOURS||h
  assert_eq(@date.Days.shot_name(), "days") // 读数腿  SH|DAYS||days
}

///|
test "date #9.3.2 total_in 的截断表 16×7（参照 getTotal = convert(totalNanos, NANOSECONDS)）" {
  // CU|0||NANOSECONDS=0 MICROSECONDS=0 MILLISECONDS=0 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0
  assert_eq(tm_one(0L, "cu").total_in(@date.Nanoseconds), 0L) // 读数腿  CU|0 的 NANOSECONDS 列 = 0
  assert_eq(tm_one(0L, "cu").total_in(@date.Microseconds), 0L) // 读数腿  CU|0 的 MICROSECONDS 列 = 0
  assert_eq(tm_one(0L, "cu").total_in(@date.Milliseconds), 0L) // 读数腿  CU|0 的 MILLISECONDS 列 = 0
  assert_eq(tm_one(0L, "cu").total_in(@date.Seconds), 0L) // 读数腿  CU|0 的 SECONDS 列 = 0
  assert_eq(tm_one(0L, "cu").total_in(@date.Minutes), 0L) // 读数腿  CU|0 的 MINUTES 列 = 0
  assert_eq(tm_one(0L, "cu").total_in(@date.Hours), 0L) // 读数腿  CU|0 的 HOURS 列 = 0
  assert_eq(tm_one(0L, "cu").total_in(@date.Days), 0L) // 读数腿  CU|0 的 DAYS 列 = 0
  // CU|1||NANOSECONDS=1 MICROSECONDS=0 MILLISECONDS=0 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0
  assert_eq(tm_one(1L, "cu").total_in(@date.Nanoseconds), 1L) // 读数腿  CU|1 的 NANOSECONDS 列 = 1
  assert_eq(tm_one(1L, "cu").total_in(@date.Microseconds), 0L) // 读数腿  CU|1 的 MICROSECONDS 列 = 0
  assert_eq(tm_one(1L, "cu").total_in(@date.Milliseconds), 0L) // 读数腿  CU|1 的 MILLISECONDS 列 = 0
  assert_eq(tm_one(1L, "cu").total_in(@date.Seconds), 0L) // 读数腿  CU|1 的 SECONDS 列 = 0
  assert_eq(tm_one(1L, "cu").total_in(@date.Minutes), 0L) // 读数腿  CU|1 的 MINUTES 列 = 0
  assert_eq(tm_one(1L, "cu").total_in(@date.Hours), 0L) // 读数腿  CU|1 的 HOURS 列 = 0
  assert_eq(tm_one(1L, "cu").total_in(@date.Days), 0L) // 读数腿  CU|1 的 DAYS 列 = 0
  // CU|999||NANOSECONDS=999 MICROSECONDS=0 MILLISECONDS=0 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0
  assert_eq(tm_one(999L, "cu").total_in(@date.Nanoseconds), 999L) // 读数腿  CU|999 的 NANOSECONDS 列 = 999
  assert_eq(tm_one(999L, "cu").total_in(@date.Microseconds), 0L) // 读数腿  CU|999 的 MICROSECONDS 列 = 0
  assert_eq(tm_one(999L, "cu").total_in(@date.Milliseconds), 0L) // 读数腿  CU|999 的 MILLISECONDS 列 = 0
  assert_eq(tm_one(999L, "cu").total_in(@date.Seconds), 0L) // 读数腿  CU|999 的 SECONDS 列 = 0
  assert_eq(tm_one(999L, "cu").total_in(@date.Minutes), 0L) // 读数腿  CU|999 的 MINUTES 列 = 0
  assert_eq(tm_one(999L, "cu").total_in(@date.Hours), 0L) // 读数腿  CU|999 的 HOURS 列 = 0
  assert_eq(tm_one(999L, "cu").total_in(@date.Days), 0L) // 读数腿  CU|999 的 DAYS 列 = 0
  // CU|1000||NANOSECONDS=1000 MICROSECONDS=1 MILLISECONDS=0 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0
  assert_eq(tm_one(1000L, "cu").total_in(@date.Nanoseconds), 1000L) // 读数腿  CU|1000 的 NANOSECONDS 列 = 1000
  assert_eq(tm_one(1000L, "cu").total_in(@date.Microseconds), 1L) // 读数腿  CU|1000 的 MICROSECONDS 列 = 1
  assert_eq(tm_one(1000L, "cu").total_in(@date.Milliseconds), 0L) // 读数腿  CU|1000 的 MILLISECONDS 列 = 0
  assert_eq(tm_one(1000L, "cu").total_in(@date.Seconds), 0L) // 读数腿  CU|1000 的 SECONDS 列 = 0
  assert_eq(tm_one(1000L, "cu").total_in(@date.Minutes), 0L) // 读数腿  CU|1000 的 MINUTES 列 = 0
  assert_eq(tm_one(1000L, "cu").total_in(@date.Hours), 0L) // 读数腿  CU|1000 的 HOURS 列 = 0
  assert_eq(tm_one(1000L, "cu").total_in(@date.Days), 0L) // 读数腿  CU|1000 的 DAYS 列 = 0
  // CU|1000000||NANOSECONDS=1000000 MICROSECONDS=1000 MILLISECONDS=1 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0
  assert_eq(tm_one(1000000L, "cu").total_in(@date.Nanoseconds), 1000000L) // 读数腿  CU|1000000 的 NANOSECONDS 列 = 1000000
  assert_eq(tm_one(1000000L, "cu").total_in(@date.Microseconds), 1000L) // 读数腿  CU|1000000 的 MICROSECONDS 列 = 1000
  assert_eq(tm_one(1000000L, "cu").total_in(@date.Milliseconds), 1L) // 读数腿  CU|1000000 的 MILLISECONDS 列 = 1
  assert_eq(tm_one(1000000L, "cu").total_in(@date.Seconds), 0L) // 读数腿  CU|1000000 的 SECONDS 列 = 0
  assert_eq(tm_one(1000000L, "cu").total_in(@date.Minutes), 0L) // 读数腿  CU|1000000 的 MINUTES 列 = 0
  assert_eq(tm_one(1000000L, "cu").total_in(@date.Hours), 0L) // 读数腿  CU|1000000 的 HOURS 列 = 0
  assert_eq(tm_one(1000000L, "cu").total_in(@date.Days), 0L) // 读数腿  CU|1000000 的 DAYS 列 = 0
  // CU|999999999||NANOSECONDS=999999999 MICROSECONDS=999999 MILLISECONDS=999 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0
  assert_eq(tm_one(999999999L, "cu").total_in(@date.Nanoseconds), 999999999L) // 读数腿  CU|999999999 的 NANOSECONDS 列 = 999999999
  assert_eq(tm_one(999999999L, "cu").total_in(@date.Microseconds), 999999L) // 读数腿  CU|999999999 的 MICROSECONDS 列 = 999999
  assert_eq(tm_one(999999999L, "cu").total_in(@date.Milliseconds), 999L) // 读数腿  CU|999999999 的 MILLISECONDS 列 = 999
  assert_eq(tm_one(999999999L, "cu").total_in(@date.Seconds), 0L) // 读数腿  CU|999999999 的 SECONDS 列 = 0
  assert_eq(tm_one(999999999L, "cu").total_in(@date.Minutes), 0L) // 读数腿  CU|999999999 的 MINUTES 列 = 0
  assert_eq(tm_one(999999999L, "cu").total_in(@date.Hours), 0L) // 读数腿  CU|999999999 的 HOURS 列 = 0
  assert_eq(tm_one(999999999L, "cu").total_in(@date.Days), 0L) // 读数腿  CU|999999999 的 DAYS 列 = 0
  // CU|1000000000||NANOSECONDS=1000000000 MICROSECONDS=1000000 MILLISECONDS=1000 SECONDS=1 MINUTES=0 HOURS=0 DAYS=0
  assert_eq(tm_one(1000000000L, "cu").total_in(@date.Nanoseconds), 1000000000L) // 读数腿  CU|1000000000 的 NANOSECONDS 列 = 1000000000
  assert_eq(tm_one(1000000000L, "cu").total_in(@date.Microseconds), 1000000L) // 读数腿  CU|1000000000 的 MICROSECONDS 列 = 1000000
  assert_eq(tm_one(1000000000L, "cu").total_in(@date.Milliseconds), 1000L) // 读数腿  CU|1000000000 的 MILLISECONDS 列 = 1000
  assert_eq(tm_one(1000000000L, "cu").total_in(@date.Seconds), 1L) // 读数腿  CU|1000000000 的 SECONDS 列 = 1
  assert_eq(tm_one(1000000000L, "cu").total_in(@date.Minutes), 0L) // 读数腿  CU|1000000000 的 MINUTES 列 = 0
  assert_eq(tm_one(1000000000L, "cu").total_in(@date.Hours), 0L) // 读数腿  CU|1000000000 的 HOURS 列 = 0
  assert_eq(tm_one(1000000000L, "cu").total_in(@date.Days), 0L) // 读数腿  CU|1000000000 的 DAYS 列 = 0
  // CU|60000000000||NANOSECONDS=60000000000 MICROSECONDS=60000000 MILLISECONDS=60000 SECONDS=60 MINUTES=1 HOURS=0 DAYS=0
  assert_eq(
    tm_one(60000000000L, "cu").total_in(@date.Nanoseconds),
    60000000000L,
  ) // 读数腿  CU|60000000000 的 NANOSECONDS 列 = 60000000000
  assert_eq(tm_one(60000000000L, "cu").total_in(@date.Microseconds), 60000000L) // 读数腿  CU|60000000000 的 MICROSECONDS 列 = 60000000
  assert_eq(tm_one(60000000000L, "cu").total_in(@date.Milliseconds), 60000L) // 读数腿  CU|60000000000 的 MILLISECONDS 列 = 60000
  assert_eq(tm_one(60000000000L, "cu").total_in(@date.Seconds), 60L) // 读数腿  CU|60000000000 的 SECONDS 列 = 60
  assert_eq(tm_one(60000000000L, "cu").total_in(@date.Minutes), 1L) // 读数腿  CU|60000000000 的 MINUTES 列 = 1
  assert_eq(tm_one(60000000000L, "cu").total_in(@date.Hours), 0L) // 读数腿  CU|60000000000 的 HOURS 列 = 0
  assert_eq(tm_one(60000000000L, "cu").total_in(@date.Days), 0L) // 读数腿  CU|60000000000 的 DAYS 列 = 0
  // CU|3600000000000||NANOSECONDS=3600000000000 MICROSECONDS=3600000000 MILLISECONDS=3600000 SECONDS=3600 MINUTES=60 HOURS=1 DAYS=0
  assert_eq(
    tm_one(3600000000000L, "cu").total_in(@date.Nanoseconds),
    3600000000000L,
  ) // 读数腿  CU|3600000000000 的 NANOSECONDS 列 = 3600000000000
  assert_eq(
    tm_one(3600000000000L, "cu").total_in(@date.Microseconds),
    3600000000L,
  ) // 读数腿  CU|3600000000000 的 MICROSECONDS 列 = 3600000000
  assert_eq(tm_one(3600000000000L, "cu").total_in(@date.Milliseconds), 3600000L) // 读数腿  CU|3600000000000 的 MILLISECONDS 列 = 3600000
  assert_eq(tm_one(3600000000000L, "cu").total_in(@date.Seconds), 3600L) // 读数腿  CU|3600000000000 的 SECONDS 列 = 3600
  assert_eq(tm_one(3600000000000L, "cu").total_in(@date.Minutes), 60L) // 读数腿  CU|3600000000000 的 MINUTES 列 = 60
  assert_eq(tm_one(3600000000000L, "cu").total_in(@date.Hours), 1L) // 读数腿  CU|3600000000000 的 HOURS 列 = 1
  assert_eq(tm_one(3600000000000L, "cu").total_in(@date.Days), 0L) // 读数腿  CU|3600000000000 的 DAYS 列 = 0
  // CU|86400000000000||NANOSECONDS=86400000000000 MICROSECONDS=86400000000 MILLISECONDS=86400000 SECONDS=86400 MINUTES=1440 HOURS=24 DAYS=1
  assert_eq(
    tm_one(86400000000000L, "cu").total_in(@date.Nanoseconds),
    86400000000000L,
  ) // 读数腿  CU|86400000000000 的 NANOSECONDS 列 = 86400000000000
  assert_eq(
    tm_one(86400000000000L, "cu").total_in(@date.Microseconds),
    86400000000L,
  ) // 读数腿  CU|86400000000000 的 MICROSECONDS 列 = 86400000000
  assert_eq(
    tm_one(86400000000000L, "cu").total_in(@date.Milliseconds),
    86400000L,
  ) // 读数腿  CU|86400000000000 的 MILLISECONDS 列 = 86400000
  assert_eq(tm_one(86400000000000L, "cu").total_in(@date.Seconds), 86400L) // 读数腿  CU|86400000000000 的 SECONDS 列 = 86400
  assert_eq(tm_one(86400000000000L, "cu").total_in(@date.Minutes), 1440L) // 读数腿  CU|86400000000000 的 MINUTES 列 = 1440
  assert_eq(tm_one(86400000000000L, "cu").total_in(@date.Hours), 24L) // 读数腿  CU|86400000000000 的 HOURS 列 = 24
  assert_eq(tm_one(86400000000000L, "cu").total_in(@date.Days), 1L) // 读数腿  CU|86400000000000 的 DAYS 列 = 1
  // CU|604800000000000||NANOSECONDS=604800000000000 MICROSECONDS=604800000000 MILLISECONDS=604800000 SECONDS=604800 MINUTES=10080 HOURS=168 DAYS=7
  assert_eq(
    tm_one(604800000000000L, "cu").total_in(@date.Nanoseconds),
    604800000000000L,
  ) // 读数腿  CU|604800000000000 的 NANOSECONDS 列 = 604800000000000
  assert_eq(
    tm_one(604800000000000L, "cu").total_in(@date.Microseconds),
    604800000000L,
  ) // 读数腿  CU|604800000000000 的 MICROSECONDS 列 = 604800000000
  assert_eq(
    tm_one(604800000000000L, "cu").total_in(@date.Milliseconds),
    604800000L,
  ) // 读数腿  CU|604800000000000 的 MILLISECONDS 列 = 604800000
  assert_eq(tm_one(604800000000000L, "cu").total_in(@date.Seconds), 604800L) // 读数腿  CU|604800000000000 的 SECONDS 列 = 604800
  assert_eq(tm_one(604800000000000L, "cu").total_in(@date.Minutes), 10080L) // 读数腿  CU|604800000000000 的 MINUTES 列 = 10080
  assert_eq(tm_one(604800000000000L, "cu").total_in(@date.Hours), 168L) // 读数腿  CU|604800000000000 的 HOURS 列 = 168
  assert_eq(tm_one(604800000000000L, "cu").total_in(@date.Days), 7L) // 读数腿  CU|604800000000000 的 DAYS 列 = 7
  // CU|-1||NANOSECONDS=-1 MICROSECONDS=0 MILLISECONDS=0 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0
  assert_eq(tm_one(-1L, "cu").total_in(@date.Nanoseconds), -1L) // 读数腿  CU|-1 的 NANOSECONDS 列 = -1
  assert_eq(tm_one(-1L, "cu").total_in(@date.Microseconds), 0L) // 读数腿  CU|-1 的 MICROSECONDS 列 = 0
  assert_eq(tm_one(-1L, "cu").total_in(@date.Milliseconds), 0L) // 读数腿  CU|-1 的 MILLISECONDS 列 = 0
  assert_eq(tm_one(-1L, "cu").total_in(@date.Seconds), 0L) // 读数腿  CU|-1 的 SECONDS 列 = 0
  assert_eq(tm_one(-1L, "cu").total_in(@date.Minutes), 0L) // 读数腿  CU|-1 的 MINUTES 列 = 0
  assert_eq(tm_one(-1L, "cu").total_in(@date.Hours), 0L) // 读数腿  CU|-1 的 HOURS 列 = 0
  assert_eq(tm_one(-1L, "cu").total_in(@date.Days), 0L) // 读数腿  CU|-1 的 DAYS 列 = 0
  // CU|-999999999||NANOSECONDS=-999999999 MICROSECONDS=-999999 MILLISECONDS=-999 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0
  assert_eq(tm_one(-999999999L, "cu").total_in(@date.Nanoseconds), -999999999L) // 读数腿  CU|-999999999 的 NANOSECONDS 列 = -999999999
  assert_eq(tm_one(-999999999L, "cu").total_in(@date.Microseconds), -999999L) // 读数腿  CU|-999999999 的 MICROSECONDS 列 = -999999
  assert_eq(tm_one(-999999999L, "cu").total_in(@date.Milliseconds), -999L) // 读数腿  CU|-999999999 的 MILLISECONDS 列 = -999
  assert_eq(tm_one(-999999999L, "cu").total_in(@date.Seconds), 0L) // 读数腿  CU|-999999999 的 SECONDS 列 = 0
  assert_eq(tm_one(-999999999L, "cu").total_in(@date.Minutes), 0L) // 读数腿  CU|-999999999 的 MINUTES 列 = 0
  assert_eq(tm_one(-999999999L, "cu").total_in(@date.Hours), 0L) // 读数腿  CU|-999999999 的 HOURS 列 = 0
  assert_eq(tm_one(-999999999L, "cu").total_in(@date.Days), 0L) // 读数腿  CU|-999999999 的 DAYS 列 = 0
  // CU|-1000000000||NANOSECONDS=-1000000000 MICROSECONDS=-1000000 MILLISECONDS=-1000 SECONDS=-1 MINUTES=0 HOURS=0 DAYS=0
  assert_eq(
    tm_one(-1000000000L, "cu").total_in(@date.Nanoseconds),
    -1000000000L,
  ) // 读数腿  CU|-1000000000 的 NANOSECONDS 列 = -1000000000
  assert_eq(tm_one(-1000000000L, "cu").total_in(@date.Microseconds), -1000000L) // 读数腿  CU|-1000000000 的 MICROSECONDS 列 = -1000000
  assert_eq(tm_one(-1000000000L, "cu").total_in(@date.Milliseconds), -1000L) // 读数腿  CU|-1000000000 的 MILLISECONDS 列 = -1000
  assert_eq(tm_one(-1000000000L, "cu").total_in(@date.Seconds), -1L) // 读数腿  CU|-1000000000 的 SECONDS 列 = -1
  assert_eq(tm_one(-1000000000L, "cu").total_in(@date.Minutes), 0L) // 读数腿  CU|-1000000000 的 MINUTES 列 = 0
  assert_eq(tm_one(-1000000000L, "cu").total_in(@date.Hours), 0L) // 读数腿  CU|-1000000000 的 HOURS 列 = 0
  assert_eq(tm_one(-1000000000L, "cu").total_in(@date.Days), 0L) // 读数腿  CU|-1000000000 的 DAYS 列 = 0
  // CU|-86400000000000||NANOSECONDS=-86400000000000 MICROSECONDS=-86400000000 MILLISECONDS=-86400000 SECONDS=-86400 MINUTES=-1440 HOURS=-24 DAYS=-1
  assert_eq(
    tm_one(-86400000000000L, "cu").total_in(@date.Nanoseconds),
    -86400000000000L,
  ) // 读数腿  CU|-86400000000000 的 NANOSECONDS 列 = -86400000000000
  assert_eq(
    tm_one(-86400000000000L, "cu").total_in(@date.Microseconds),
    -86400000000L,
  ) // 读数腿  CU|-86400000000000 的 MICROSECONDS 列 = -86400000000
  assert_eq(
    tm_one(-86400000000000L, "cu").total_in(@date.Milliseconds),
    -86400000L,
  ) // 读数腿  CU|-86400000000000 的 MILLISECONDS 列 = -86400000
  assert_eq(tm_one(-86400000000000L, "cu").total_in(@date.Seconds), -86400L) // 读数腿  CU|-86400000000000 的 SECONDS 列 = -86400
  assert_eq(tm_one(-86400000000000L, "cu").total_in(@date.Minutes), -1440L) // 读数腿  CU|-86400000000000 的 MINUTES 列 = -1440
  assert_eq(tm_one(-86400000000000L, "cu").total_in(@date.Hours), -24L) // 读数腿  CU|-86400000000000 的 HOURS 列 = -24
  assert_eq(tm_one(-86400000000000L, "cu").total_in(@date.Days), -1L) // 读数腿  CU|-86400000000000 的 DAYS 列 = -1
  // CU|9223372036854775807||NANOSECONDS=9223372036854775807 MICROSECONDS=9223372036854775 MILLISECONDS=9223372036854 SECONDS=9223372036 MINUTES=153722867 HOURS=2562047 DAYS=106751
  assert_eq(
    tm_one(9223372036854775807L, "cu").total_in(@date.Nanoseconds),
    9223372036854775807L,
  ) // 读数腿  CU|9223372036854775807 的 NANOSECONDS 列 = 9223372036854775807
  assert_eq(
    tm_one(9223372036854775807L, "cu").total_in(@date.Microseconds),
    9223372036854775L,
  ) // 读数腿  CU|9223372036854775807 的 MICROSECONDS 列 = 9223372036854775
  assert_eq(
    tm_one(9223372036854775807L, "cu").total_in(@date.Milliseconds),
    9223372036854L,
  ) // 读数腿  CU|9223372036854775807 的 MILLISECONDS 列 = 9223372036854
  assert_eq(
    tm_one(9223372036854775807L, "cu").total_in(@date.Seconds),
    9223372036L,
  ) // 读数腿  CU|9223372036854775807 的 SECONDS 列 = 9223372036
  assert_eq(
    tm_one(9223372036854775807L, "cu").total_in(@date.Minutes),
    153722867L,
  ) // 读数腿  CU|9223372036854775807 的 MINUTES 列 = 153722867
  assert_eq(tm_one(9223372036854775807L, "cu").total_in(@date.Hours), 2562047L) // 读数腿  CU|9223372036854775807 的 HOURS 列 = 2562047
  assert_eq(tm_one(9223372036854775807L, "cu").total_in(@date.Days), 106751L) // 读数腿  CU|9223372036854775807 的 DAYS 列 = 106751
}

///|
test "date #9.3.3 TaskInfo 五个读数与 total 同表（参照那两条委托关系）" {
  // TI|0||name=k NANOSECONDS=0 MICROSECONDS=0 MILLISECONDS=0 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0 ms=0 sec=0.0 nanos=0
  assert_eq(tm_one(0L, "ti").last_task_info().time_in(@date.Nanoseconds), 0L) // 读数腿  TI|0 的 NANOSECONDS 列 = 0
  assert_eq(tm_one(0L, "ti").last_task_info().time_in(@date.Microseconds), 0L) // 读数腿  TI|0 的 MICROSECONDS 列 = 0
  assert_eq(tm_one(0L, "ti").last_task_info().time_in(@date.Milliseconds), 0L) // 读数腿  TI|0 的 MILLISECONDS 列 = 0
  assert_eq(tm_one(0L, "ti").last_task_info().time_in(@date.Seconds), 0L) // 读数腿  TI|0 的 SECONDS 列 = 0
  assert_eq(tm_one(0L, "ti").last_task_info().time_in(@date.Minutes), 0L) // 读数腿  TI|0 的 MINUTES 列 = 0
  assert_eq(tm_one(0L, "ti").last_task_info().time_in(@date.Hours), 0L) // 读数腿  TI|0 的 HOURS 列 = 0
  assert_eq(tm_one(0L, "ti").last_task_info().time_in(@date.Days), 0L) // 读数腿  TI|0 的 DAYS 列 = 0
  assert_eq(tm_one(0L, "ti").last_task_info().time_nanos(), 0L) // 读数腿  TI|0 的 nanos= 列
  assert_eq(tm_one(0L, "ti").last_task_info().time_millis(), 0L) // 读数腿  TI|0 的 ms= 列
  assert_eq(tm_one(0L, "ti").last_task_info().time_seconds(), 0.0) // 读数腿  TI|0 的 sec= 列
  assert_eq(tm_one(0L, "ti").last_task_info().task_name(), Some("t")) // 规则腿  TI 行的 name=k 列证「名字原样存」；本库名字由夹具给
  // TI|1000||name=k NANOSECONDS=1000 MICROSECONDS=1 MILLISECONDS=0 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0 ms=0 sec=1.0E-6 nanos=1000
  assert_eq(
    tm_one(1000L, "ti").last_task_info().time_in(@date.Nanoseconds),
    1000L,
  ) // 读数腿  TI|1000 的 NANOSECONDS 列 = 1000
  assert_eq(
    tm_one(1000L, "ti").last_task_info().time_in(@date.Microseconds),
    1L,
  ) // 读数腿  TI|1000 的 MICROSECONDS 列 = 1
  assert_eq(
    tm_one(1000L, "ti").last_task_info().time_in(@date.Milliseconds),
    0L,
  ) // 读数腿  TI|1000 的 MILLISECONDS 列 = 0
  assert_eq(tm_one(1000L, "ti").last_task_info().time_in(@date.Seconds), 0L) // 读数腿  TI|1000 的 SECONDS 列 = 0
  assert_eq(tm_one(1000L, "ti").last_task_info().time_in(@date.Minutes), 0L) // 读数腿  TI|1000 的 MINUTES 列 = 0
  assert_eq(tm_one(1000L, "ti").last_task_info().time_in(@date.Hours), 0L) // 读数腿  TI|1000 的 HOURS 列 = 0
  assert_eq(tm_one(1000L, "ti").last_task_info().time_in(@date.Days), 0L) // 读数腿  TI|1000 的 DAYS 列 = 0
  assert_eq(tm_one(1000L, "ti").last_task_info().time_nanos(), 1000L) // 读数腿  TI|1000 的 nanos= 列
  assert_eq(tm_one(1000L, "ti").last_task_info().time_millis(), 0L) // 读数腿  TI|1000 的 ms= 列
  assert_eq(tm_one(1000L, "ti").last_task_info().time_seconds(), 1.0e-6) // 读数腿  TI|1000 的 sec= 列
  assert_eq(tm_one(1000L, "ti").last_task_info().task_name(), Some("t")) // 规则腿  TI 行的 name=k 列证「名字原样存」；本库名字由夹具给
  // TI|1000000||name=k NANOSECONDS=1000000 MICROSECONDS=1000 MILLISECONDS=1 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0 ms=1 sec=0.001 nanos=1000000
  assert_eq(
    tm_one(1000000L, "ti").last_task_info().time_in(@date.Nanoseconds),
    1000000L,
  ) // 读数腿  TI|1000000 的 NANOSECONDS 列 = 1000000
  assert_eq(
    tm_one(1000000L, "ti").last_task_info().time_in(@date.Microseconds),
    1000L,
  ) // 读数腿  TI|1000000 的 MICROSECONDS 列 = 1000
  assert_eq(
    tm_one(1000000L, "ti").last_task_info().time_in(@date.Milliseconds),
    1L,
  ) // 读数腿  TI|1000000 的 MILLISECONDS 列 = 1
  assert_eq(tm_one(1000000L, "ti").last_task_info().time_in(@date.Seconds), 0L) // 读数腿  TI|1000000 的 SECONDS 列 = 0
  assert_eq(tm_one(1000000L, "ti").last_task_info().time_in(@date.Minutes), 0L) // 读数腿  TI|1000000 的 MINUTES 列 = 0
  assert_eq(tm_one(1000000L, "ti").last_task_info().time_in(@date.Hours), 0L) // 读数腿  TI|1000000 的 HOURS 列 = 0
  assert_eq(tm_one(1000000L, "ti").last_task_info().time_in(@date.Days), 0L) // 读数腿  TI|1000000 的 DAYS 列 = 0
  assert_eq(tm_one(1000000L, "ti").last_task_info().time_nanos(), 1000000L) // 读数腿  TI|1000000 的 nanos= 列
  assert_eq(tm_one(1000000L, "ti").last_task_info().time_millis(), 1L) // 读数腿  TI|1000000 的 ms= 列
  assert_eq(tm_one(1000000L, "ti").last_task_info().time_seconds(), 0.001) // 读数腿  TI|1000000 的 sec= 列
  assert_eq(tm_one(1000000L, "ti").last_task_info().task_name(), Some("t")) // 规则腿  TI 行的 name=k 列证「名字原样存」；本库名字由夹具给
  // TI|999999999||name=k NANOSECONDS=999999999 MICROSECONDS=999999 MILLISECONDS=999 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0 ms=999 sec=0.999999999 nanos=999999999
  assert_eq(
    tm_one(999999999L, "ti").last_task_info().time_in(@date.Nanoseconds),
    999999999L,
  ) // 读数腿  TI|999999999 的 NANOSECONDS 列 = 999999999
  assert_eq(
    tm_one(999999999L, "ti").last_task_info().time_in(@date.Microseconds),
    999999L,
  ) // 读数腿  TI|999999999 的 MICROSECONDS 列 = 999999
  assert_eq(
    tm_one(999999999L, "ti").last_task_info().time_in(@date.Milliseconds),
    999L,
  ) // 读数腿  TI|999999999 的 MILLISECONDS 列 = 999
  assert_eq(
    tm_one(999999999L, "ti").last_task_info().time_in(@date.Seconds),
    0L,
  ) // 读数腿  TI|999999999 的 SECONDS 列 = 0
  assert_eq(
    tm_one(999999999L, "ti").last_task_info().time_in(@date.Minutes),
    0L,
  ) // 读数腿  TI|999999999 的 MINUTES 列 = 0
  assert_eq(tm_one(999999999L, "ti").last_task_info().time_in(@date.Hours), 0L) // 读数腿  TI|999999999 的 HOURS 列 = 0
  assert_eq(tm_one(999999999L, "ti").last_task_info().time_in(@date.Days), 0L) // 读数腿  TI|999999999 的 DAYS 列 = 0
  assert_eq(tm_one(999999999L, "ti").last_task_info().time_nanos(), 999999999L) // 读数腿  TI|999999999 的 nanos= 列
  assert_eq(tm_one(999999999L, "ti").last_task_info().time_millis(), 999L) // 读数腿  TI|999999999 的 ms= 列
  assert_eq(
    tm_one(999999999L, "ti").last_task_info().time_seconds(),
    0.999999999,
  ) // 读数腿  TI|999999999 的 sec= 列
  assert_eq(tm_one(999999999L, "ti").last_task_info().task_name(), Some("t")) // 规则腿  TI 行的 name=k 列证「名字原样存」；本库名字由夹具给
  // TI|86400000000000||name=k NANOSECONDS=86400000000000 MICROSECONDS=86400000000 MILLISECONDS=86400000 SECONDS=86400 MINUTES=1440 HOURS=24 DAYS=1 ms=86400000 sec=86400.0 nanos=86400000000000
  assert_eq(
    tm_one(86400000000000L, "ti").last_task_info().time_in(@date.Nanoseconds),
    86400000000000L,
  ) // 读数腿  TI|86400000000000 的 NANOSECONDS 列 = 86400000000000
  assert_eq(
    tm_one(86400000000000L, "ti").last_task_info().time_in(@date.Microseconds),
    86400000000L,
  ) // 读数腿  TI|86400000000000 的 MICROSECONDS 列 = 86400000000
  assert_eq(
    tm_one(86400000000000L, "ti").last_task_info().time_in(@date.Milliseconds),
    86400000L,
  ) // 读数腿  TI|86400000000000 的 MILLISECONDS 列 = 86400000
  assert_eq(
    tm_one(86400000000000L, "ti").last_task_info().time_in(@date.Seconds),
    86400L,
  ) // 读数腿  TI|86400000000000 的 SECONDS 列 = 86400
  assert_eq(
    tm_one(86400000000000L, "ti").last_task_info().time_in(@date.Minutes),
    1440L,
  ) // 读数腿  TI|86400000000000 的 MINUTES 列 = 1440
  assert_eq(
    tm_one(86400000000000L, "ti").last_task_info().time_in(@date.Hours),
    24L,
  ) // 读数腿  TI|86400000000000 的 HOURS 列 = 24
  assert_eq(
    tm_one(86400000000000L, "ti").last_task_info().time_in(@date.Days),
    1L,
  ) // 读数腿  TI|86400000000000 的 DAYS 列 = 1
  assert_eq(
    tm_one(86400000000000L, "ti").last_task_info().time_nanos(),
    86400000000000L,
  ) // 读数腿  TI|86400000000000 的 nanos= 列
  assert_eq(
    tm_one(86400000000000L, "ti").last_task_info().time_millis(),
    86400000L,
  ) // 读数腿  TI|86400000000000 的 ms= 列
  assert_eq(
    tm_one(86400000000000L, "ti").last_task_info().time_seconds(),
    86400.0,
  ) // 读数腿  TI|86400000000000 的 sec= 列
  assert_eq(
    tm_one(86400000000000L, "ti").last_task_info().task_name(),
    Some("t"),
  ) // 规则腿  TI 行的 name=k 列证「名字原样存」；本库名字由夹具给
  // TI|-999999999||name=k NANOSECONDS=-999999999 MICROSECONDS=-999999 MILLISECONDS=-999 SECONDS=0 MINUTES=0 HOURS=0 DAYS=0 ms=-999 sec=-0.999999999 nanos=-999999999
  assert_eq(
    tm_one(-999999999L, "ti").last_task_info().time_in(@date.Nanoseconds),
    -999999999L,
  ) // 读数腿  TI|-999999999 的 NANOSECONDS 列 = -999999999
  assert_eq(
    tm_one(-999999999L, "ti").last_task_info().time_in(@date.Microseconds),
    -999999L,
  ) // 读数腿  TI|-999999999 的 MICROSECONDS 列 = -999999
  assert_eq(
    tm_one(-999999999L, "ti").last_task_info().time_in(@date.Milliseconds),
    -999L,
  ) // 读数腿  TI|-999999999 的 MILLISECONDS 列 = -999
  assert_eq(
    tm_one(-999999999L, "ti").last_task_info().time_in(@date.Seconds),
    0L,
  ) // 读数腿  TI|-999999999 的 SECONDS 列 = 0
  assert_eq(
    tm_one(-999999999L, "ti").last_task_info().time_in(@date.Minutes),
    0L,
  ) // 读数腿  TI|-999999999 的 MINUTES 列 = 0
  assert_eq(tm_one(-999999999L, "ti").last_task_info().time_in(@date.Hours), 0L) // 读数腿  TI|-999999999 的 HOURS 列 = 0
  assert_eq(tm_one(-999999999L, "ti").last_task_info().time_in(@date.Days), 0L) // 读数腿  TI|-999999999 的 DAYS 列 = 0
  assert_eq(
    tm_one(-999999999L, "ti").last_task_info().time_nanos(),
    -999999999L,
  ) // 读数腿  TI|-999999999 的 nanos= 列
  assert_eq(tm_one(-999999999L, "ti").last_task_info().time_millis(), -999L) // 读数腿  TI|-999999999 的 ms= 列
  assert_eq(
    tm_one(-999999999L, "ti").last_task_info().time_seconds(),
    -0.999999999,
  ) // 读数腿  TI|-999999999 的 sec= 列
  assert_eq(tm_one(-999999999L, "ti").last_task_info().task_name(), Some("t")) // 规则腿  TI 行的 name=k 列证「名字原样存」；本库名字由夹具给
}

///|
test "date #9.3.4 total_seconds = nanos / 1.0E9（腿 NS 行十六档）" {
  assert_eq(tm_one(0L, "ns").total_seconds(), 0.0) // 读数腿  NS|0||0.0
  assert_eq(tm_one(1L, "ns").total_seconds(), 1.0e-9) // 读数腿  NS|1||1.0E-9
  assert_eq(tm_one(999L, "ns").total_seconds(), 9.99e-7) // 读数腿  NS|999||9.99E-7
  assert_eq(tm_one(1000L, "ns").total_seconds(), 1.0e-6) // 读数腿  NS|1000||1.0E-6
  assert_eq(tm_one(1000000L, "ns").total_seconds(), 0.001) // 读数腿  NS|1000000||0.001
  assert_eq(tm_one(999999999L, "ns").total_seconds(), 0.999999999) // 读数腿  NS|999999999||0.999999999
  assert_eq(tm_one(1000000000L, "ns").total_seconds(), 1.0) // 读数腿  NS|1000000000||1.0
  assert_eq(tm_one(60000000000L, "ns").total_seconds(), 60.0) // 读数腿  NS|60000000000||60.0
  assert_eq(tm_one(3600000000000L, "ns").total_seconds(), 3600.0) // 读数腿  NS|3600000000000||3600.0
  assert_eq(tm_one(86400000000000L, "ns").total_seconds(), 86400.0) // 读数腿  NS|86400000000000||86400.0
  assert_eq(tm_one(604800000000000L, "ns").total_seconds(), 604800.0) // 读数腿  NS|604800000000000||604800.0
  assert_eq(tm_one(-1L, "ns").total_seconds(), -1.0e-9) // 读数腿  NS|-1||-1.0E-9
  assert_eq(tm_one(-999999999L, "ns").total_seconds(), -0.999999999) // 读数腿  NS|-999999999||-0.999999999
  assert_eq(tm_one(-1000000000L, "ns").total_seconds(), -1.0) // 读数腿  NS|-1000000000||-1.0
  assert_eq(tm_one(-86400000000000L, "ns").total_seconds(), -86400.0) // 读数腿  NS|-86400000000000||-86400.0
  assert_eq(
    tm_one(9223372036854775807L, "ns").total_seconds(),
    9.223372036854776e9,
  ) // 读数腿  NS|9223372036854775807||9.223372036854776E9
}

///|
test "date #9.7.1 数字列补零到 9 位（含十位不截断、负号在补齐之前）" {
  // 数字列走参照 `NumberFormat.getNumberInstance()` + setMinimumIntegerDigits(9) + setGroupingUsed(false)（腿 NF 行是直接喂数取的读数）
  // 单任务 ⇒ 比值恒 1.0 ⇒ 百分号取 PC|1.0 那一档
  assert_eq(tm_line(tm_one(0L, "nf").pretty_print(), 4), "000000000  100%   t") // 读数腿  NF|0||000000000 ＋ PC|1.0||100%（列宽 PP|one-task-nanos）
  assert_eq(tm_line(tm_one(1L, "nf").pretty_print(), 4), "000000001  100%   t") // 读数腿  NF|1||000000001 ＋ PC|1.0||100%（列宽 PP|one-task-nanos）
  assert_eq(tm_line(tm_one(5L, "nf").pretty_print(), 4), "000000005  100%   t") // 读数腿  NF|5||000000005 ＋ PC|1.0||100%（列宽 PP|one-task-nanos）
  assert_eq(tm_line(tm_one(99L, "nf").pretty_print(), 4), "000000099  100%   t") // 读数腿  NF|99||000000099 ＋ PC|1.0||100%（列宽 PP|one-task-nanos）
  assert_eq(
    tm_line(tm_one(12345L, "nf").pretty_print(), 4),
    "000012345  100%   t",
  ) // 读数腿  NF|12345||000012345 ＋ PC|1.0||100%（列宽 PP|one-task-nanos）
  assert_eq(
    tm_line(tm_one(99999999L, "nf").pretty_print(), 4),
    "099999999  100%   t",
  ) // 读数腿  NF|99999999||099999999 ＋ PC|1.0||100%（列宽 PP|one-task-nanos）
  assert_eq(
    tm_line(tm_one(100000000L, "nf").pretty_print(), 4),
    "100000000  100%   t",
  ) // 读数腿  NF|100000000||100000000 ＋ PC|1.0||100%（列宽 PP|one-task-nanos）
  assert_eq(
    tm_line(tm_one(999999999L, "nf").pretty_print(), 4),
    "999999999  100%   t",
  ) // 读数腿  NF|999999999||999999999 ＋ PC|1.0||100%（列宽 PP|one-task-nanos）
  assert_eq(
    tm_line(tm_one(1000000000L, "nf").pretty_print(), 4),
    "1000000000  100%   t",
  ) // 读数腿  NF|1000000000||1000000000 ＋ PC|1.0||100%（列宽 PP|one-task-nanos）
  assert_eq(
    tm_line(tm_one(1234567890L, "nf").pretty_print(), 4),
    "1234567890  100%   t",
  ) // 读数腿  NF|1234567890||1234567890 ＋ PC|1.0||100%（列宽 PP|one-task-nanos）
  assert_eq(
    tm_line(tm_one(-1L, "nf").pretty_print(), 4),
    "-000000001  100%   t",
  ) // 读数腿  NF|-1||-000000001 ＋ PC|1.0||100%（列宽 PP|one-task-nanos）
  assert_eq(
    tm_line(tm_one(-12345L, "nf").pretty_print(), 4),
    "-000012345  100%   t",
  ) // 读数腿  NF|-12345||-000012345 ＋ PC|1.0||100%（列宽 PP|one-task-nanos）
}

///|
test "date #9.7.2 百分号：×100 后 HALF_EVEN、最少 2 位、NaN 不出百分号、∞ 出 U+221E" {
  // 比值 a/(a+b) 由假钟的两段任务凑；数字列统一走 Days 单位 ⇒ 落回 NF|0 那一档，这样 §9.7.2 的舍入判据与 §9.7.1 的列宽判据互不干扰
  assert_eq(
    tm_line(
      tm_run([1L, 249L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  00%   t0",
  ) // 读数腿  PC|0.004||00%（比值 0.004）
  assert_eq(
    tm_line(
      tm_run([1L, 199L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  00%   t0",
  ) // 读数腿  PC|0.005||00%（比值 0.005）
  assert_eq(
    tm_line(
      tm_run([3L, 497L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  01%   t0",
  ) // 读数腿  PC|0.006||01%（比值 0.006）
  assert_eq(
    tm_line(
      tm_run([99L, 9901L], ["t0", "t1"], "pc", true).pretty_print(
        unit=@date.Days,
      ),
      4,
    ),
    "000000000  01%   t0",
  ) // 读数腿  PC|0.0099||01%（比值 0.0099）
  assert_eq(
    tm_line(
      tm_run([1L, 99L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  01%   t0",
  ) // 读数腿  PC|0.01||01%（比值 0.01）
  assert_eq(
    tm_line(
      tm_run([3L, 197L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  02%   t0",
  ) // 读数腿  PC|0.015||02%（比值 0.015）
  assert_eq(
    tm_line(
      tm_run([5L, 195L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  02%   t0",
  ) // 读数腿  PC|0.025||02%（比值 0.025）
  assert_eq(
    tm_line(
      tm_run([5L, 95L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  05%   t0",
  ) // 读数腿  PC|0.05||05%（比值 0.05）
  assert_eq(
    tm_line(
      tm_run([999L, 9001L], ["t0", "t1"], "pc", true).pretty_print(
        unit=@date.Days,
      ),
      4,
    ),
    "000000000  10%   t0",
  ) // 读数腿  PC|0.0999||10%（比值 0.0999）
  assert_eq(
    tm_line(
      tm_run([1L, 9L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  10%   t0",
  ) // 读数腿  PC|0.1||10%（比值 0.1）
  assert_eq(
    tm_line(
      tm_run([3L, 17L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  15%   t0",
  ) // 读数腿  PC|0.15||15%（比值 0.15）
  assert_eq(
    tm_line(
      tm_run([1L, 3L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  25%   t0",
  ) // 读数腿  PC|0.25||25%（比值 0.25）
  assert_eq(
    tm_line(
      tm_run([1L, 2L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  33%   t0",
  ) // 读数腿  PC|0.3333333333333333||33%（比值 0.3333333333333333）
  assert_eq(
    tm_line(
      tm_run([1L, 2L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      5,
    ),
    "000000000  67%   t1",
  ) // 读数腿  PC|0.6666666666666666||67%（比值 0.6666666666666666）
  assert_eq(
    tm_line(
      tm_run([100L, 100L], ["t0", "t1"], "pc", true).pretty_print(
        unit=@date.Days,
      ),
      4,
    ),
    "000000000  50%   t0",
  ) // 读数腿  PC|0.5||50%（比值 0.5）
  assert_eq(
    tm_line(
      tm_run([3L, 1L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  75%   t0",
  ) // 读数腿  PC|0.75||75%（比值 0.75）
  assert_eq(
    tm_line(
      tm_run([1L, 99L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      5,
    ),
    "000000000  99%   t1",
  ) // 读数腿  PC|0.99||99%（比值 0.99）
  assert_eq(
    tm_line(
      tm_run([999L, 1L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  100%   t0",
  ) // 读数腿  PC|0.999||100%（比值 0.999）
  assert_eq(
    tm_line(
      tm_run([1L, 0L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  100%   t0",
  ) // 读数腿  PC|1.0||100%（比值 1.0）
  assert_eq(
    tm_line(
      tm_run([1L, 0L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      5,
    ),
    "000000000  00%   t1",
  ) // 读数腿  PC|0.0||00%（比值 0.0）
  assert_eq(
    tm_line(
      tm_run([0L, 0L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  NaN   t0",
  ) // 读数腿  PC|NaN||NaN（比值 NaN）
  assert_eq(
    tm_line(
      tm_run([0L, 0L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      5,
    ),
    "000000000  NaN   t1",
  ) // 读数腿  PC|NaN||NaN（比值 NaN）
  assert_eq(
    tm_line(
      tm_run([1000000L, -1000000L], ["t0", "t1"], "pc", true).pretty_print(
        unit=@date.Days,
      ),
      4,
    ),
    "000000000  ∞%   t0",
  ) // 读数腿  PC|Infinity||∞%（比值 Infinity）
  assert_eq(
    tm_line(
      tm_run([1000000L, -1000000L], ["t0", "t1"], "pc", true).pretty_print(
        unit=@date.Days,
      ),
      5,
    ),
    "000000000  -∞%   t1",
  ) // 读数腿  PC|-Infinity||-∞%（比值 -Infinity）
  assert_eq(
    tm_line(
      tm_run([-1L, 3L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      4,
    ),
    "000000000  -50%   t0",
  ) // 读数腿  PC|-0.5||-50%（比值 -0.5）
  assert_eq(
    tm_line(
      tm_run([-1L, 3L], ["t0", "t1"], "pc", true).pretty_print(unit=@date.Days),
      5,
    ),
    "000000000  150%   t1",
  ) // 读数腿  PC|1.5||150%（比值 1.5）
}

///|
test "date #9.5.1 format_between 正数档（零值档整段跳过、逐级借位）" {
  assert_eq(@date.format_between(0L), "0毫秒") // 读数腿  FB|0||0{u6beb}{u79d2} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=0{u5206} ~ SECOND=0{u79d2} ~ MILLISECOND=0{u6beb}{u79d2}
  assert_eq(@date.format_between(1L), "1毫秒") // 读数腿  FB|1||1{u6beb}{u79d2} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=0{u5206} ~ SECOND=0{u79d2} ~ MILLISECOND=1{u6beb}{u79d2}
  assert_eq(@date.format_between(999L), "999毫秒") // 读数腿  FB|999||999{u6beb}{u79d2} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=0{u5206} ~ SECOND=0{u79d2} ~ MILLISECOND=999{u6beb}{u79d2}
  assert_eq(@date.format_between(1000L), "1秒") // 读数腿  FB|1000||1{u79d2} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=0{u5206} ~ SECOND=1{u79d2} ~ MILLISECOND=1{u79d2}
  assert_eq(@date.format_between(1001L), "1秒1毫秒") // 读数腿  FB|1001||1{u79d2}1{u6beb}{u79d2} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=0{u5206} ~ SECOND=1{u79d2} ~ MILLISECOND=1{u79d2}1{u6beb}{u79d2}
  assert_eq(@date.format_between(1500L), "1秒500毫秒") // 读数腿  FB|1500||1{u79d2}500{u6beb}{u79d2} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=0{u5206} ~ SECOND=1{u79d2} ~ MILLISECOND=1{u79d2}500{u6beb}{u79d2}
  assert_eq(@date.format_between(59000L), "59秒") // 读数腿  FB|59000||59{u79d2} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=0{u5206} ~ SECOND=59{u79d2} ~ MILLISECOND=59{u79d2}
  assert_eq(@date.format_between(60000L), "1分") // 读数腿  FB|60000||1{u5206} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=1{u5206} ~ SECOND=1{u5206} ~ MILLISECOND=1{u5206}
  assert_eq(@date.format_between(61000L), "1分1秒") // 读数腿  FB|61000||1{u5206}1{u79d2} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=1{u5206} ~ SECOND=1{u5206}1{u79d2} ~ MILLISECOND=1{u5206}1{u79d2}
  assert_eq(@date.format_between(3540000L), "59分") // 读数腿  FB|3540000||59{u5206} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=59{u5206} ~ SECOND=59{u5206} ~ MILLISECOND=59{u5206}
  assert_eq(@date.format_between(3600000L), "1小时") // 读数腿  FB|3600000||1{u5c0f}{u65f6} ~ DAY=0{u5929} ~ HOUR=1{u5c0f}{u65f6} ~ MINUTE=1{u5c0f}{u65f6} ~ SECOND=1{u5c0f}{u65f6} ~ MILLISECOND=1{u5c0f}{u65f6}
  assert_eq(@date.format_between(3600001L), "1小时1毫秒") // 读数腿  FB|3600001||1{u5c0f}{u65f6}1{u6beb}{u79d2} ~ DAY=0{u5929} ~ HOUR=1{u5c0f}{u65f6} ~ MINUTE=1{u5c0f}{u65f6} ~ SECOND=1{u5c0f}{u65f6} ~ MILLISECOND=1{u5c0f}{u65f6}1{u6beb}{u79d2}
  assert_eq(@date.format_between(7260000L), "2小时1分") // 读数腿  FB|7260000||2{u5c0f}{u65f6}1{u5206} ~ DAY=0{u5929} ~ HOUR=2{u5c0f}{u65f6} ~ MINUTE=2{u5c0f}{u65f6}1{u5206} ~ SECOND=2{u5c0f}{u65f6}1{u5206} ~ MILLISECOND=2{u5c0f}{u65f6}1{u5206}
  assert_eq(@date.format_between(86399999L), "23小时59分59秒999毫秒") // 读数腿  FB|86399999||23{u5c0f}{u65f6}59{u5206}59{u79d2}999{u6beb}{u79d2} ~ DAY=0{u5929} ~ HOUR=23{u5c0f}{u65f6} ~ MINUTE=23{u5c0f}{u65f6}59{u5206} ~ SECOND=23{u5c0f}{u65f6}59{u5206}59{u79d2} ~ MILLISECOND=23{u5c0f}{u65f6}59{u5206}59{u79d2}999{u6beb}{u79d2}
  assert_eq(@date.format_between(86400000L), "1天") // 读数腿  FB|86400000||1{u5929} ~ DAY=1{u5929} ~ HOUR=1{u5929} ~ MINUTE=1{u5929} ~ SECOND=1{u5929} ~ MILLISECOND=1{u5929}
  assert_eq(@date.format_between(90061000L), "1天1小时1分1秒") // 读数腿  FB|90061000||1{u5929}1{u5c0f}{u65f6}1{u5206}1{u79d2} ~ DAY=1{u5929} ~ HOUR=1{u5929}1{u5c0f}{u65f6} ~ MINUTE=1{u5929}1{u5c0f}{u65f6}1{u5206} ~ SECOND=1{u5929}1{u5c0f}{u65f6}1{u5206}1{u79d2} ~ MILLISECOND=1{u5929}1{u5c0f}{u65f6}1{u5206}1{u79d2}
  assert_eq(@date.format_between(604800000L), "7天") // 读数腿  FB|604800000||7{u5929} ~ DAY=7{u5929} ~ HOUR=7{u5929} ~ MINUTE=7{u5929} ~ SECOND=7{u5929} ~ MILLISECOND=7{u5929}
  assert_eq(@date.format_between(604801000L), "7天1秒") // 读数腿  FB|604801000||7{u5929}1{u79d2} ~ DAY=7{u5929} ~ HOUR=7{u5929} ~ MINUTE=7{u5929} ~ SECOND=7{u5929}1{u79d2} ~ MILLISECOND=7{u5929}1{u79d2}
  assert_eq(@date.format_between(8640000000L), "100天") // 读数腿  FB|8640000000||100{u5929} ~ DAY=100{u5929} ~ HOUR=100{u5929} ~ MINUTE=100{u5929} ~ SECOND=100{u5929} ~ MILLISECOND=100{u5929}
  assert_eq(
    @date.format_between(9223372036854775807L),
    "106751991167天7小时12分55秒807毫秒",
  ) // 读数腿  FB|9223372036854775807||106751991167{u5929}7{u5c0f}{u65f6}12{u5206}55{u79d2}807{u6beb}{u79d2} ~ DAY=106751991167{u5929} ~ HOUR=106751991167{u5929}7{u5c0f}{u65f6} ~ MINUTE=106751991167{u5929}7{u5c0f}{u65f6}12{u5206} ~ SECOND=106751991167{u5929}7{u5c0f}{u65f6}12{u5206}55{u79d2} ~ MILLISECOND=106751991167{u5929}7{u5c0f}{u65f6}12{u5206}55{u79d2}807{u6beb}{u79d2}
}

///|
test "date #9.5.2 非正档一律 0毫秒，五档档名逐个出场" {
  // 判据 1：参照字节码第一行就是 `betweenMs > 0` 的总闸 ⇒ 非正一律走「补 0 + 当档名」那一步
  assert_eq(@date.format_between(-1L), "0毫秒") // 读数腿  FB|-1||0{u6beb}{u79d2} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=0{u5206} ~ SECOND=0{u79d2} ~ MILLISECOND=0{u6beb}{u79d2}
  assert_eq(@date.format_between(-1000L), "0毫秒") // 读数腿  FB|-1000||0{u6beb}{u79d2} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=0{u5206} ~ SECOND=0{u79d2} ~ MILLISECOND=0{u6beb}{u79d2}
  assert_eq(@date.format_between(-86400000L), "0毫秒") // 读数腿  FB|-86400000||0{u6beb}{u79d2} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=0{u5206} ~ SECOND=0{u79d2} ~ MILLISECOND=0{u6beb}{u79d2}
  // 对照：同一绝对值在正半边不是这个读数 ⇒ 负数**不是**取绝对值、也不是带符号
  assert_eq(@date.format_between(1000L), "1秒") // 读数腿  FB|1000||1{u79d2} ~ DAY=0{u5929} ~ HOUR=0{u5c0f}{u65f6} ~ MINUTE=0{u5206} ~ SECOND=1{u79d2} ~ MILLISECOND=1{u79d2}
  // 参照 Level.DAY 的档名 = 天（腿 FB|level-name-DAY）
  // 参照 Level.HOUR 的档名 = 小时（腿 FB|level-name-HOUR）
  // 参照 Level.MINUTE 的档名 = 分（腿 FB|level-name-MINUTE）
  // 参照 Level.SECOND 的档名 = 秒（腿 FB|level-name-SECOND）
  // 参照 Level.MILLISECOND 的档名 = 毫秒（腿 FB|level-name-MILLISECOND）
}
