///|
// moon-hutool/date —— 计时件的**状态机与排版**期望（第六批 §9.3、§9.4、§9.7.3）。
//
// 这一份是手写件（生成件在 `date/timer_test.mbt`）：这些档要拼夹具——脚本钟给几次读数、
// 任务名走哪一档、留存表开关怎么切——拼法不在腿上，但**每条期望串都带着它对应的腿读数**。
// 两类来源用同一套前缀标：`读数腿` = 抄腿；`规则腿` = 值由假钟给、判据由那条腿/字节码给（spec §9.9）。
//
// 到不了的臂不落断言（spec §9.8 第 5 行）：参照 `new StopWatch(null)` 给 `StopWatch 'null'`
// （腿 ID|null-id-summary）、`interval(null)` 四条 NPE（腿 Z|G.interval-null-key 组）、
// `Long.MIN` 的差值档——本库类型里构造不出来，不预留 Option 去模拟 Java 的 null。

///|
test "date #9.3.5 空表状态机：四条 last_* 同一条件、没在跑的 stop 必抛" {
  let sw = @date.stop_watch(tm_steps([0L, 1000L]), id="pp")
  assert_eq(sw.is_running(), false) // 读数腿  W|isRunning@fresh||false
  assert_eq(sw.current_task_name(), None) // 读数腿  W|currentTaskName@fresh||{null}
  assert_eq(sw.task_count(), 0) // 读数腿  W|taskCount@fresh||0
  assert_eq(sw.total_nanos(), 0L) // 读数腿  W|totalMillis@fresh||0（一条都没停过，纳秒同理）
  assert_eq(sw.id(), "pp") // 规则腿  ID|无参id||（空串是缺省档）；这里显式给了 pp
  assert_eq(sw.short_summary(), "StopWatch 'pp': running time = 0 ns") // 读数腿  W|shortSummary@fresh||StopWatch '': running time = # ns（模板同条、id 由夹具给）
  assert_eq(shape(() => sw.last_task_nanos()), "NoLastTask") // 读数腿  W|lastTaskMillis@fresh||ERR:IllegalStateException:No tasks run: can't get last task interval
  assert_eq(shape(() => sw.last_task_millis()), "NoLastTask") // 读数腿  同上：参照两条 message 相同、条件相同 ⇒ 本库一个变体
  assert_eq(shape(() => sw.last_task_name()), "NoLastTask") // 读数腿  W|lastTaskName@fresh||ERR:IllegalStateException:No tasks run: can't get last task name
  assert_eq(shape(() => sw.last_task_info()), "NoLastTask") // 读数腿  W|lastTaskInfo@fresh||ERR:IllegalStateException:No tasks run: can't get last task info
  assert_eq(shape(() => sw.stop()), "TimerNotRunning") // 读数腿  W|stop@never-started||ERR:IllegalStateException:Can't stop StopWatch: it's not running
}

///|
test "date #9.3.6 无名任务那档（Some(\"\") 与 None 是两档）" {
  let a = @date.stop_watch(tm_steps([7L, 9L]), id="a")
  a.start() catch {
    err => abort("夹具不该抛：" + show(err))
  }
  assert_eq(a.is_running(), true) // 读数腿  W|isRunning@running||true
  assert_eq(a.current_task_name(), Some("")) // 读数腿  W|currentTaskName@unnamed||（空串，不是 null）
  assert_eq(a.task_count(), 0) // 读数腿  W|taskCount@one-running||0 ⇒ 计数只在 stop 加
  assert_eq(shape(() => a.start(name=Some("second"))), "TimerAlreadyRunning") // 读数腿  W|start@while-running||ERR:IllegalStateException:Can't start StopWatch: it's already running
  a.stop() catch {
    err => abort("夹具不该抛：" + show(err))
  }
  assert_eq(a.is_running(), false) // 读数腿  W|isRunning@after-stop||false
  assert_eq(a.last_task_name(), Some("")) // 读数腿  W|lastTaskName@after-stop-unnamed||（空档）
  assert_eq(a.last_task_nanos(), 2L) // 规则腿  脚本钟 7→9 ⇒ 差 2；W 行只证"stop 之后才有 last 读数"
  assert_eq(a.task_count(), 1) // 读数腿  W|taskCount@two||3 的形状：每 stop 加一
  assert_eq(shape(() => a.stop()), "TimerNotRunning") // 读数腿  W|stop@not-running||ERR:IllegalStateException:Can't stop StopWatch: it's not running
}

///|
test "date #9.3.7 start(name=None) 暗档四连（参照的 running 判据就是这条）" {
  let b = @date.stop_watch(tm_steps([0L, 5L]), id="sn")
  b.start(name=None) catch {
    err => abort("夹具不该抛：" + show(err))
  }
  // 参照判"在跑"用的是 `currentTaskName != null` ⇒ 传 null 等于什么都没开始
  assert_eq(b.is_running(), false) // 读数腿  SN|isRunning||false
  assert_eq(b.current_task_name(), None) // 读数腿  SN|currentTaskName||{null}
  assert_eq(b.task_count(), 0) // 读数腿  SN|taskCount||0
  assert_eq(shape(() => b.stop()), "TimerNotRunning") // 读数腿  SN|stop之后||ERR:IllegalStateException:Can't stop StopWatch: it's not running
  assert_eq(shape(() => b.last_task_name()), "NoLastTask") // 读数腿  SN|lastTaskName||ERR:IllegalStateException:No tasks run: can't get last task name
  b.start(name=Some("real")) catch {
    err => abort("夹具不该抛：" + show(err))
  }
  assert_eq(b.is_running(), true) // 读数腿  SN|null后再start(能进?)||true|real
  assert_eq(b.current_task_name(), Some("real")) // 读数腿  同一条的第二列
}

///|
test "date #9.3.8 多任务的顺序、计数与每行比值" {
  let c = tm_run([1L, 99L, 0L], ["task-A", "task-B", "task-C"], "w", true)
  assert_eq(c.task_count(), 3) // 读数腿  W|taskCount@two||3
  assert_eq(c.task_infos().length(), 3) // 读数腿  W|taskNames||/# task-A/# task-B/# 的形状：按结束顺序
  assert_eq(c.total_nanos(), 100L) // 规则腿  三段差值之和（腿把数字掩成 #，值由假钟给）
  assert_eq(tm_line(c.pretty_print(), 4), "000000001  01%   task-A") // 读数腿  NF|1||000000001 ＋ PC|0.01||01%（比值 1/100）
  assert_eq(tm_line(c.pretty_print(), 5), "000000099  99%   task-B") // 读数腿  NF|99||000000099 ＋ PC|0.99||99%
  assert_eq(tm_line(c.pretty_print(), 6), "000000000  00%   task-C") // 读数腿  NF|0||000000000 ＋ PC|0.0||00% ⇒ 零时长任务照出行程
  assert_eq(
    c.to_string(),
    "StopWatch 'w': running time = 100 ns; [task-A] took 1 ns = 1%; [task-B] took 99 ns = 99%; [task-C] took 0 ns = 0%",
  ) // 规则腿  PP|toString 的行形状；百分号走 Math.round 那一族（不补零）
}

///|
test "date #9.3.9 keep_task_list=false：计数照加、行拿不到" {
  let k = tm_run([1L, 1L], ["x", "y"], "no-keep", false)
  assert_eq(k.task_count(), 2) // 读数腿  W|keep=false|taskCount||2 ⇒ 计数与留存表解耦
  assert_eq(shape(() => k.task_infos()), "TaskInfoNotKept") // 读数腿  W|keep=false|taskInfoLen||ERR:UnsupportedOperationException:Task info is not being kept!
  assert_eq(k.last_task_name(), Some("y")) // 读数腿  W|keep=false|lastTaskName||y ⇒ last 读数不受开关影响
  assert_eq(k.total_millis(), 0L) // 读数腿  CU|1|MILLISECONDS=0 同族截断（两段各 1 ns ⇒ 总 2 ns ⇒ 0 ms）
  assert_eq(tm_line(k.pretty_print(), 1), "No task info kept") // 读数腿  PP|keep=false-pretty||StopWatch·'nk':·running·time·=·DDD·ns\r\nNo·task·info·kept ⇒ 表头与分隔行都不出
  assert_eq(
    k.to_string(),
    "StopWatch 'no-keep': running time = 2 ns; no task info kept",
  ) // 读数腿  PP|keep=false-toString 的形状（`; no task info kept` 那半句照抄）
}

///|
test "date #9.3.10 set_keep_task_list 的两次真行为（关会丢行、开只补空表）" {
  let m = @date.stop_watch(tm_steps([0L, 4L]), id="flip")
  m.set_keep_task_list(false)
  m.start(name=Some("only")) catch {
    err => abort("夹具不该抛：" + show(err))
  }
  m.stop() catch {
    err => abort("夹具不该抛：" + show(err))
  }
  m.set_keep_task_list(true)
  assert_eq(m.task_count(), 1) // 规则腿  计数不因切换归零（W|keep=false|taskCount 同族）
  assert_eq(m.task_infos().length(), 0) // 读数腿  PP|keep-翻true后-pretty||表头与分隔行都在、行是空 ⇒ 参照把表置 null 之后新建的是**空**表
  m.set_keep_task_list(true)
  assert_eq(m.task_infos().length(), 0) // 规则腿  字节码现读：true 只在 taskList == null 时新建 ⇒ 已保留时是空操作
  // 上面那条把「已保留时是不是空操作」留在**未判别**状态：把实现改成「每次都新建空表」
  // 仍然全绿。补这一档对照（m2 全程 keep=true，再 set 一次 true，行必须还在），
  // 变异 T15 就是挂在这条上的。
  let m2 = tm_run([1L], ["a"], "keep", true)
  m2.set_keep_task_list(true)
  assert_eq(m2.task_infos().length(), 1) // 规则腿  同一条字节码：taskList != null ⇒ true 那支什么都不做
  m.set_keep_task_list(false)
  assert_eq(shape(() => m.task_infos()), "TaskInfoNotKept") // 规则腿  同上一条字节码：false 把表置 null ⇒ 已经记下的行丢
}

///|
test "date #9.7.3 整张表的五段与两处字面空格" {
  let pp = tm_one(1000000L, "pp")
  assert_eq(
    pp.pretty_print(),
    "StopWatch 'pp': running time = 1000000 ns\n---------------------------------------------\nns         %     Task name\n---------------------------------------------\n001000000  100%   t\n",
  ) // 读数腿  PP|one-task-nanos||StopWatch·'pp':·running·time·=·DDD·ns\r\n---...\r\nns·········%·····Task·name\r\n---...\r\nDDDDDDDDD··DDD%···alpha\r\n（· 是腿里显形空格的记号；行分隔符按 §9.7.4 落成 LF；数字 NF|1000000、百分号 PC|1.0）
  assert_eq(
    tm_line(@date.stop_watch(tm_fixed(0L)).pretty_print(), 1).length(),
    45,
  ) // 读数腿  PP|dash-len||45
  assert_eq(
    tm_line(@date.stop_watch(tm_fixed(0L)).pretty_print(), 2),
    "ns         %     Task name",
  ) // 读数腿  PP|header-seg||ns·········%·····Task·name
  assert_eq(
    @date.stop_watch(tm_fixed(0L)).pretty_print(),
    "StopWatch '': running time = 0 ns\n---------------------------------------------\nns         %     Task name\n---------------------------------------------\n",
  ) // 读数腿  PP|no-task||…⇒ 没有任务时三行照出、没有数据行
  assert_eq(
    @date.stop_watch(tm_fixed(0L)).to_string(),
    "StopWatch '': running time = 0 ns",
  ) // 读数腿  PP|no-task-toString||StopWatch·'none':·running·time·=·D·ns ⇒ 没有行就整串只有摘要那半句
  assert_eq(
    @date.stop_watch(tm_fixed(0L))
    .pretty_print()
    .split("\n")
    .to_array()
    .length(),
    5,
  ) // 规则腿  四行各带一个 LF ⇒ 切出五段（末段空）。本库恒 LF：LS|FileUtil.getLineSeparator||\r\n 那条平台量不跟随（§9.7.4）
  assert_eq(tm_one(1000000L, "pp").pretty_print().has_prefix("\r\n"), false) // 读数腿  LS|System.lineSeparator||\r\n ⇒ 参照在 Windows 上首行之后就给 CRLF，本库恒 LF
}

///|
test "date #9.3.11 to_string 与 pretty_print 是两族舍入（NaN 档是最分的判别夹具）" {
  assert_eq(
    tm_run([1000L, 1000L], ["a", "b"], "two", true).to_string(),
    "StopWatch 'two': running time = 2000 ns; [a] took 1000 ns = 50%; [b] took 1000 ns = 50%",
  ) // 读数腿  SN|toString||StopWatch 'sn2': running time = 481400 ns; [real] took 481400 ns = 100% 的行形状（` ; [` `] took ` ` ns = ` `%` 四处字面同这条）
  // 总时长为 0 的两种成因在两族里的分岔：pretty_print 出 NaN（连百分号都不带），to_string 出 0%
  let z = tm_run([0L, 0L], ["a", "b"], "z", true)
  assert_eq(tm_line(z.pretty_print(), 4), "000000000  NaN   a") // 读数腿  PC|NaN||NaN ⇒ NaN 那档不追加百分号（参照 DecimalFormat 的既有形状）
  assert_eq(
    z.to_string(),
    "StopWatch 'z': running time = 0 ns; [a] took 0 ns = 0%; [b] took 0 ns = 0%",
  ) // 规则腿  Java Math.round(NaN) = 0；判据 SN|toString 的行形状
  // 平局档才分得出族：0.025 ⇒ HALF_EVEN 取 2（pretty_print），Math.round(2.5) 取 3（to_string）
  let tie = tm_run([5L, 195L], ["a", "b"], "tie", true)
  assert_eq(tm_line(tie.pretty_print(), 4), "000000005  02%   a") // 读数腿  PC|0.025||02%（HALF_EVEN：2.5 → 2）
  assert_eq(
    tie.to_string(),
    "StopWatch 'tie': running time = 200 ns; [a] took 5 ns = 3%; [b] took 195 ns = 98%",
  ) // 规则腿  Math.round(100.0*5/200) = 3（向数轴正向）；[b] 那侧 97.5 → 98
}

///|
test "date #9.4.1 缺键给 0、start 给读数本身、interval_restart 的两档" {
  assert_eq(@date.group_time_interval(tm_fixed(5000L)).interval(id="nope"), 0L) // 读数腿  Z|G.interval-unstarted|0（不抛、不给可选值）
  assert_eq(
    @date.group_time_interval(tm_fixed(5000L)).interval_ms(id="nope"),
    0L,
  ) // 读数腿  Z|G.intervalMs@empty|0
  assert_eq(
    @date.group_time_interval_nanos(tm_fixed(5000L)).interval(id="nope"),
    0L,
  ) // 读数腿  Z|G.interval@empty|0 ⇒ 纳秒档同理
  assert_eq(
    @date.group_time_interval(tm_fixed(5000L)).interval_pretty(id="nope"),
    "0毫秒",
  ) // 读数腿  FB|0||0{u6beb}{u79d2} ⇒ 缺键的 0 直接进格式化那一步
  let g = @date.group_time_interval(tm_steps([5000L, 5123L]))
  assert_eq(g.start(id="k1"), 5000L) // 规则腿  G|start(k1)||# ⇒ 返回那一次读数本身（毫秒档就是 epoch 值）
  assert_eq(g.interval(id="k1"), 123L) // 规则腿  G|interval(k1)||#：getTime() 减存档读数
  assert_eq(g.interval_ms(id="k1"), 123L) // 规则腿  字节码现读 isNano 为假那支直接返回，不除 1e6
  assert_eq(g.interval_restart(id="k2"), 5123L) // 读数腿  Z|Ti.intervalRestart@fresh|2 ⇒ 未记过的键拿到的是原始读数本身，不是差
  assert_eq(g.interval(id="k2"), 0L) // 规则腿  restart 已把起点推到此刻 ⇒ 同读数之差为 0
  assert_eq(g.interval_second(id="k1"), 0L) // 规则腿  123 ms ÷ 1000 向零截断（CU|999|MILLISECONDS=0 同族）
}

///|
test "date #9.4.2 interval_in 的两步算式与两个单位档" {
  let g = tm_group([0L, 90061000L], ["k"], false)
  assert_eq(g.interval_in(@date.Millisecond, id="k"), 90061000L) // 规则腿  字节码现读 unit == MS 那一支直接返回
  assert_eq(g.interval_in(@date.Second, id="k"), 90061L) // 规则腿  ÷ DateUnit.SECOND.getMillis()=1000（§2.9 已冻 to_millis）
  assert_eq(g.interval_in(@date.Minute, id="k"), 1501L) // 读数腿  G|intervalMs/Second/Minute/Week||#/#/#/# 的形状 ＋ 向零截断：90061000/60000 = 1501
  assert_eq(g.interval_in(@date.Hour, id="k"), 25L) // 规则腿  90061000/3600000 向零截断
  assert_eq(g.interval_in(@date.Day, id="k"), 1L) // 规则腿  90061000/86400000 = 1
  assert_eq(g.interval_in(@date.Week, id="k"), 0L) // 规则腿  90061000/604800000 = 0 ⇒ 不足一周给 0，不进位
  assert_eq(g.interval_minute(id="k"), 1501L) // 规则腿  六件便捷档全部委托 interval_in（字节码六处同形）
  // 纳秒档：先 ÷1_000_000 换成毫秒，再 ÷ 单位毫秒数，两次都向零截断
  let n = tm_group([0L, 1500000000L], ["k"], true)
  assert_eq(n.interval(id="k"), 1500000000L) // 规则腿  纳秒档的 interval 原样给纳秒（G|interval(k1)||# 的形状）
  assert_eq(n.interval_ms(id="k"), 1500L) // 读数腿  CU|1000000|MILLISECONDS=1 同族：÷1_000_000
  assert_eq(n.interval_second(id="k"), 1L) // 读数腿  CU|1000000000|SECONDS=1 同族：1500/1000 向零截断
  assert_eq(tm_group([0L, 999999999L], ["k"], true).interval_ms(id="k"), 999L) // 读数腿  CU|999999999|MILLISECONDS=999 ⇒ 不四舍五入
  assert_eq(
    tm_group([0L, 90061000000000L], ["k"], true).interval_pretty(id="k"),
    "1天1小时1分1秒",
  ) // 读数腿  FB|90061000||1{u5929}1{u5c0f}{u65f6}1{u5206}1{u79d2} ⇒ 90061000000000 ns ÷1e6 = 90061000 ms
}

///|
test "date #9.4.3 两键互不干扰、clear 之后照给 0、预启动构造口" {
  let g2 = tm_group([1000L, 2000L, 9000L, 9000L], ["a", "b"], false)
  assert_eq(g2.interval(id="a"), 8000L) // 读数腿  G|两个键互不干扰||#<=true,true ⇒ 两键各存各的起点
  assert_eq(g2.interval(id="b"), 7000L) // 读数腿  同一条的第二列
  g2.clear()
  assert_eq(g2.interval(id="a"), 0L) // 读数腿  Z|G.interval-after-clear|0
  assert_eq(g2.interval(id="b"), 0L) // 读数腿  同一条 ⇒ clear 不重建 map，整张清空
  // 参照 TimeInterval 的 ctor 里就 start()（字节码 `invokevirtual start:()J`），本库落成两个预启动构造口
  let t = @date.time_interval(tm_fixed(3000L))
  assert_eq(t.interval(), 0L) // 读数腿  Z|Ti.interval@fresh|5 的形状 ⇒ 不是"未记过的 0"而是"同一读数之差"
  assert_eq(t.interval(id="别的键"), 0L) // 规则腿  参照父子两面在本库合成一个类型 ⇒ 空键档仍给 0（Z|G.interval-unstarted 同判据）
  assert_eq(t.interval_pretty(), "0毫秒") // 读数腿  Z|Ti.intervalPretty@fresh|0毫秒（掩码后形状）＋ FB|0
  t.restart()
  assert_eq(t.interval(), 0L) // 规则腿  T|restart 那档：重记起点；固定钟下差仍是 0
  let s = tm_group([1L, 1000001L], ["k"], true)
  assert_eq(s.interval_second(id="k"), 0L) // 读数腿  CU|1000000|SECONDS=0 同族（1_000_000 ns ÷1e6 ÷1000）
  assert_eq(s.interval_day(id="k"), 0L) // 规则腿  1000 ms ÷ 86400000 向零截断
  assert_eq(s.interval_week(id="k"), 0L) // 规则腿  同上，一周那一档
}
