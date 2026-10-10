///|
// moon-hutool/date —— 计时三件（ROADMAP 第 3 行第六批）
// 契约真相在 `docs/spec/03-date.md` §9.2~§9.4 与 §9.7；读数来源 `scripts/TimerLeg.java`（`W`/`T`/`G`/`F`）、
// `scripts/TimerLeg2.java`（`Z`/`P`）、`scripts/TimerLeg3.java`（`SH`/`LS`/`NF`/`PC`/`PP`）、
// `scripts/TimerLeg4.java`（`CU`/`NS`/`TI`/`SN`/`ID`）。
//
// 本批的立身前提是**本库一处都不读时钟**：件只收调用方给的 `() -> Int64`，
// 所以 G18 那条"裸读点只许 `date/date.mbt` 一处"在本批一字未动（spec §9.1）。
// 可变字段照 `cache` 那一包的既有形状：`mut` 字段 + 值接收者（本版编译器不吃 `&mut` 写法，实测判词法错）。

///|
/// 秒表用的时长单位（对位参照里 `java.util.concurrent.TimeUnit` 的七档）
///
/// 与本包 `TimeUnit`（对位 hutool `DateUnit`，六档、没有纳秒/微秒）**是两个类型**，不是漏合：
/// 参照自己就是两个枚举——`getTotal`/`prettyPrint` 吃 junit 那个，`interval(key, unit)` 吃 `DateUnit`。
/// 合成一个就要给 `TimeUnit` 加纳秒/微秒档，那两档一进 `to_millis()` 就承诺了"1 纳秒 = 0 毫秒"
/// 这种静默归零（判据见 spec §9.3 最后一行）。
pub(all) enum ChronoUnit {
  Nanoseconds
  Microseconds
  Milliseconds
  Seconds
  Minutes
  Hours
  Days
}

///|
/// 单位短名（对位 `DateUtil.getShotName(TimeUnit)`，`pretty_print`/`short_summary` 用它拼表头）
///
/// - Note: 七档读数全部由腿 `SH` 行现读冻结，其中微秒档是 **U+03BC GREEK SMALL LETTER MU**（不是 U+00B5）。
/// - Note: 参照那个是 `DateUtil` 上的静态法，本库挂在枚举上——结构层差别，判据不变（spec §9.3）。
/// - Note: 参照传 `null` 抛 NPE；本库类型到不了那一档，不预留。
pub fn ChronoUnit::shot_name(self : ChronoUnit) -> String {
  let _ = self
  abort(
    "PR-B：契约骨架，七档读数见 docs/spec/03-date.md §9.3 与腿 SH 行",
  )
}

///|
/// 一条已结束任务的读数（对位 `StopWatch.TaskInfo`）
///
/// 参照的构造器是**包级私有**（`TaskInfo(String, long)`），本库同样不给公开构造口：
/// 这个类型只能从 `StopWatch::last_task_info` / `task_infos` 拿到。
pub struct TaskInfo {
  priv name : String?
  priv nanos : Int64
}

///|
/// 任务名。无名任务（`start()`）给 `Some("")`，`start(name=None)` 那档给 `None`（腿 `W`/`SN` 行）。
pub fn TaskInfo::task_name(self : TaskInfo) -> String? {
  let _ = (self.name, self.nanos)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 时长的纳秒读数（参照内部存的就是纳秒）
pub fn TaskInfo::time_nanos(self : TaskInfo) -> Int64 {
  let _ = (self.name, self.nanos)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 按单位取时长（参照 `getTime(TimeUnit)` = `unit.convert(nanos, NANOSECONDS)`，**向零截断**）
///
/// - Note: 负读数（时钟被往回拨）的截断方向由腿 `CU`/`TI` 行逐档冻结，不四舍五入、不夹零。
pub fn TaskInfo::time_in(self : TaskInfo, unit : ChronoUnit) -> Int64 {
  let _ = (self.name, self.nanos, unit)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3 与腿 TI 行")
}

///|
/// 毫秒读数（`time_in(Millisecond)` 的薄封装，参照就是这么委托的）
pub fn TaskInfo::time_millis(self : TaskInfo) -> Int64 {
  let _ = (self.name, self.nanos)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 秒读数（参照走 `DateUtil.nanosToSeconds(n)` = `n / 1.0E9`，腿 `NS` 行）
///
/// - Note: 契约只断**能精确表示**的档；`Double` 的十进制外形不参与冻结（参照那侧是 `String.valueOf` 的结果，
///   与本库 `Double::to_string` 的记法不是同一件事，spec §9.3 那行写明）。
pub fn TaskInfo::time_seconds(self : TaskInfo) -> Double {
  let _ = (self.name, self.nanos)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3 与腿 NS 行")
}

///|
/// 秒表（对位 `cn.hutool.core.date.StopWatch`）
///
/// 参照四个入口（`()`、`(String)`、`(String, boolean)`、`create(String)`）在本库塌成一个带默认值的构造口：
/// 字节码现读 `create` 就是 `new StopWatch(String)`，而 `(String)` 那档的 `keep` 恒 `true`（`iconst_1`）。
pub struct StopWatch {
  priv watch_id : String
  priv clock : () -> Int64
  priv keep : Bool
  priv kept : Array[TaskInfo]
  priv last : TaskInfo?
  priv running : String?
  priv start_at : Int64
  priv total : Int64
  priv count : Int
}

///|
/// 造一张秒表。
///
/// - Parameters:
///   - clock: **纳秒**读数源（对位参照内部那两处 `System.nanoTime()`）。本库不自带纳秒真钟，
///     core 也没有纳秒口（spec §9.2 那条表）；给什么源、是否单调，由注入方决定。
///   - id: 表号，进 `short_summary`/`pretty_print` 的第一行。参照的 `id` 可以真是 `null`
///     并打成字面 `null`（腿 `ID|null-id-summary`），本库类型到不了那一档。
///   - keep_task_list: 是否逐条留存任务行；参照无 id 档与单参档都是 `true`。
pub fn stop_watch(
  clock : () -> Int64,
  id? : String = "",
  keep_task_list? : Bool = true,
) -> StopWatch {
  let _ = (clock, id, keep_task_list)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 表号（参照 `getId()`）
pub fn StopWatch::id(self : StopWatch) -> String {
  let _ = self.watch_id
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 开/关"逐条留存任务行"（参照 `setKeepTaskList(boolean)`）
///
/// - Note: 两条判据都来自参照字节码，不是本库取舍：`true` **只在当前不保留时**新建空表（已保留 ⇒ 空操作，
///   行还在）；`false` 直接把表丢掉 ⇒ **已经记下的行丢**。来回切一次就能观察到"表头还在、行是空"
///   （腿 `PP|keep-翻true后-pretty`）。
pub fn StopWatch::set_keep_task_list(self : StopWatch, keep : Bool) -> Unit {
  let _ = (self.keep, self.kept, keep)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 开始一条任务（参照 `start()` 与 `start(String)` 两件在本库合成一件）。
///
/// - Parameters:
///   - name: 任务名。**三档都在明面**：不传 ⇒ `Some("")`（参照 `start()` 往字段里写的就是空串）；
///     `name = Some("x")` ⇒ 参照 `start("x")`；`name = None` ⇒ 参照 `start((String) null)` 那一档。
/// - Raises: `TimerAlreadyRunning`——已经有一条在跑（参照 `IllegalStateException`）
/// - Note: 参照判"是否在跑"用的是 `currentTaskName != null`，所以传 null 那一档的实际行为是
///   **什么都没开始**：之后 `is_running()` 恒 `false`、`stop()` 报"没在跑"、再 `start("real")` 还能进
///   （腿 `SN` 行四档全冻）。本库入参做成 `String?` 就是为了让这条暗档仍然可达，不"顺手"把它当成没传。
pub fn StopWatch::start(
  self : StopWatch,
  name? : String? = Some(""),
) -> Unit raise DateError {
  let _ = (self.running, self.start_at, self.clock, name)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3 与腿 SN 行")
}

///|
/// 结束当前任务（参照 `stop()`；五步顺序照字节码，`count` 与留存表长**解耦**）。
/// - Raises: `TimerNotRunning`——没在跑（腿 `W|stop@never-started`、`W|stop@not-running` 两档同判）
pub fn StopWatch::stop(self : StopWatch) -> Unit raise DateError {
  let _ = (self.running, self.start_at, self.clock, self.total, self.count)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3 与腿 W 行")
}

///|
/// 是否有一条任务在跑（参照 `isRunning()`，字节码现读它判的就是"当前名 != null"）
pub fn StopWatch::is_running(self : StopWatch) -> Bool {
  let _ = self.running
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 当前任务名（参照 `currentTaskName()`）
///
/// - Note: `Some("")` 与 `None` 是两档：无名 `start()` 给 `Some("")`，`start(name=None)` 给 `None`。
pub fn StopWatch::current_task_name(self : StopWatch) -> String? {
  let _ = self.running
  abort(
    "PR-B：契约骨架，docs/spec/03-date.md §9.3 与腿 W|currentTaskName@unnamed",
  )
}

///|
/// 上一条任务的纳秒时长（参照 `getLastTaskTimeNanos()`）
/// - Raises: `NoLastTask`——一条都没跑完过（腿 `W|lastTaskMillis@fresh`）
pub fn StopWatch::last_task_nanos(self : StopWatch) -> Int64 raise DateError {
  let _ = self.last
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 上一条任务的毫秒时长（参照 `getLastTaskTimeMillis()`；与上一条同条件，参照 message 不同但类型相同）
/// - Raises: `NoLastTask`
pub fn StopWatch::last_task_millis(self : StopWatch) -> Int64 raise DateError {
  let _ = self.last
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 上一条任务的名（参照 `getLastTaskName()`）
/// - Raises: `NoLastTask`
/// - Note: 无名任务给 `Some("")` 而不是 ERR（腿 `W|lastTaskName@after-stop-unnamed` 是空档）
pub fn StopWatch::last_task_name(self : StopWatch) -> String? raise DateError {
  let _ = self.last
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 上一条任务整条（参照 `getLastTaskInfo()`）
/// - Raises: `NoLastTask`
pub fn StopWatch::last_task_info(self : StopWatch) -> TaskInfo raise DateError {
  let _ = self.last
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 总时长按单位取（参照 `getTotal(TimeUnit)` = `convert(totalNanos, NANOSECONDS)`，向零截断）
pub fn StopWatch::total_in(self : StopWatch, unit : ChronoUnit) -> Int64 {
  let _ = (self.total, unit)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3 与腿 CU 行")
}

///|
/// 总纳秒（参照 `getTotalTimeNanos()`——它不换算，直接给内部累计值）
pub fn StopWatch::total_nanos(self : StopWatch) -> Int64 {
  let _ = self.total
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 总毫秒（参照 `getTotalTimeMillis()` = `getTotal(MILLISECONDS)`）
pub fn StopWatch::total_millis(self : StopWatch) -> Int64 {
  let _ = self.total
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 总秒（参照 `getTotalTimeSeconds()` 走 `DateUtil.nanosToSeconds`）
pub fn StopWatch::total_seconds(self : StopWatch) -> Double {
  let _ = self.total
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3 与腿 NS 行")
}

///|
/// 结束过的任务条数（参照 `getTaskCount()`）
///
/// - Note: **与留存表长解耦**：`keep_task_list=false` 时参照计数照加、表却拿不到
///   （腿 `keep=false|taskCount|2` 对 `taskInfoLen|ERR`）。
pub fn StopWatch::task_count(self : StopWatch) -> Int {
  let _ = self.count
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 留存的任务行，按结束顺序（参照 `getTaskInfo()`）
/// - Raises: `TaskInfoNotKept`——`keep_task_list=false`（参照抛 `UnsupportedOperationException`）
/// - Note: 返回新数组（参照 `toArray` 也是新数组），改它不动内部状态
pub fn StopWatch::task_infos(
  self : StopWatch,
) -> Array[TaskInfo] raise DateError {
  let _ = (self.kept, self.keep)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3")
}

///|
/// 一行摘要（参照 `shortSummary()` / `shortSummary(TimeUnit)`）
///
/// - Note: 模板逐字节冻成 `StopWatch '<id>': running time = <total_in(unit)> <shot_name(unit)>`；
///   参照无参那档传的是 `null` 单位，字节码现读它落到 `NANOSECONDS` ⇒ 本库的默认值不是猜的。
pub fn StopWatch::short_summary(
  self : StopWatch,
  unit? : ChronoUnit = Nanoseconds,
) -> String {
  let _ = (self.watch_id, self.total, unit)
  abort(
    "PR-B：契约骨架，docs/spec/03-date.md §9.3 与腿 PP|shortSummary 组",
  )
}

///|
/// 对齐表格（参照 `prettyPrint()` / `prettyPrint(TimeUnit)`）
///
/// - Note: 四条排版判据（补零到 9 位、百分号 ×100 后 HALF_EVEN、列宽是字面空格、行分隔符恒 `\n`）
///   整体写在 **spec §9.7**，每条都有与时钟无关的腿读数兜着（`NF`/`PC`/`PP`/`LS` 行）。
pub fn StopWatch::pretty_print(
  self : StopWatch,
  unit? : ChronoUnit = Nanoseconds,
) -> String {
  let _ = (self.watch_id, self.keep, self.kept, self.total, unit)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.7")
}

///|
/// 一行汇总（参照 `toString()`）
///
/// - Note: 参照这里**不用** `pretty_print` 那套 `NumberFormat`，而是 `Math.round(100.0 × n / total)`：
///   向数轴正向取整、`NaN ⇒ 0`、不补零。两族混用是参照自己的形状，本库照抄不"顺手统一"
///   （`total=0` 那档参照 `to_string` 给 `= 0%` 而 `pretty_print` 给 `NaN`，两条都必须复现）。
pub fn StopWatch::to_string(self : StopWatch) -> String {
  let _ = (self.watch_id, self.keep, self.kept, self.total)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.3 与腿 SN|toString")
}

///|
/// 计时区间（对位参照的 `GroupTimeInterval` **与** `TimeInterval` 两面）
///
/// 参照是继承：`TimeInterval extends GroupTimeInterval` + 固定键 `DEFAULT_ID = ""`（字节码现读是**空串**）
/// + 九个无参便捷法，其余全继承——所以参照的 `TimeInterval` 实例也能调 `start("别的键")`。
/// MoonBit 没有继承，本库的做法是**一个类型承载两面**：键参数 `id~ : String = ""`，
/// 参照的"无参 = 走 DEFAULT_ID"因此就是同一件法的默认值档，判据只有一套。取舍与代价见 spec §9.4。
pub struct GroupTimeInterval {
  priv clock : () -> Int64
  priv is_nano : Bool
  priv group : Map[String, Int64]
}

///|
/// 毫秒档分组计时器（参照 `GroupTimeInterval(false)`，`getTime()` 那侧对位 `System.currentTimeMillis()`）
///
/// - Note: 参照的 `groupMap` 是 `SafeConcurrentHashMap`（并发安全）；本库全同步，**不承诺并发可见性**（spec §9.8 第 4 行）。
/// - Note: 参照的构造参数名在字节码里是 **`isNano`** 而不是 `isMillis`——`new TimeInterval(true)` 拿到的是纳秒档
///   （腿 `Z|isMillis=true|interval|497100` 对上毫秒档的 `1`）。本库把两档做成两个具名构造口，就是为了不让这个坑重演。
pub fn group_time_interval(clock : () -> Int64) -> GroupTimeInterval {
  let _ = clock
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.2")
}

///|
/// 纳秒档分组计时器（参照 `GroupTimeInterval(true)`，`getTime()` 那侧对位 `System.nanoTime()`）
pub fn group_time_interval_nanos(clock : () -> Int64) -> GroupTimeInterval {
  let _ = clock
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.2")
}

///|
/// 毫秒档 + **构造即 start 空键**（参照 `TimeInterval()`：字节码现读 ctor 里就 `invokevirtual start:()J`）
///
/// - Note: 参照返回的是子类实例，本库返回同一类型 ⇒ 类型层面的父子区别消失，行为区别（预启动）保留。
pub fn time_interval(clock : () -> Int64) -> GroupTimeInterval {
  let _ = clock
  abort(
    "PR-B：契约骨架，docs/spec/03-date.md §9.4 与腿 Z|Ti.interval@fresh",
  )
}

///|
/// 纳秒档 + 预启动（参照 `TimeInterval(true)`）
pub fn time_interval_nanos(clock : () -> Int64) -> GroupTimeInterval {
  let _ = clock
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.4")
}

///|
/// 给某个键记起点，返回**那一次读数本身**（不是差）。
///
/// - Note: 毫秒档下返回值就是 epoch 毫秒（腿 `T|start`）；重复 start 就是覆盖，参照没有"重复 start 报错"这一档。
pub fn GroupTimeInterval::start(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  let _ = (self.clock, self.is_nano, self.group, id)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.4 与腿 G|start(k1)")
}

///|
/// 重新起表（参照 `TimeInterval::restart()`）。参照返回 `this` 供链式，本库返回 `Unit` ⇒ **不承诺链式**。
pub fn GroupTimeInterval::restart(
  self : GroupTimeInterval,
  id? : String = "",
) -> Unit {
  let _ = (self.clock, self.is_nano, self.group, id)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.4")
}

///|
/// 从起点到此刻的差，**原单位**。
///
/// - Returns: 键不存在 ⇒ `0`（参照字节码现读：`map.get` 为 null 就 `lconst_0; lreturn`，不抛、不给可选值）
/// - Note: 于是"没记过"与"记了但正好 0"两档在公开读数上**不可区分**——这是参照行为，不是本库偷懒。
pub fn GroupTimeInterval::interval(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  let _ = (self.clock, self.is_nano, self.group, id)
  abort(
    "PR-B：契约骨架，docs/spec/03-date.md §9.4 与腿 G|interval@empty",
  )
}

///|
/// 算差**并**把起点推到此刻（参照 `intervalRestart(String)`）。
///
/// - Returns: 键不存在时返回**那一次读数本身**（参照是 `t - defaultIfNull(map.put(key,t), 0)`，
///   毫秒档下就是一个巨大的 epoch 值）。这一档容易想当然写成"给 0"，spec §9.4 那行把算式抄在明面。
pub fn GroupTimeInterval::interval_restart(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  let _ = (self.clock, self.is_nano, self.group, id)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.4")
}

///|
/// 按单位取差（参照 `interval(String, DateUnit)`）。
///
/// - Note: 算式两步，都在明面：纳秒档先 `÷1_000_000` 换成毫秒，单位非毫秒时再 `÷ 该单位的毫秒数`；
///   两次都是**向零截断**（腿 `CU` 行负档为凭）。参照对 `unit == MS` 那一支直接返回，本库不重复除。
pub fn GroupTimeInterval::interval_in(
  self : GroupTimeInterval,
  unit : TimeUnit,
  id? : String = "",
) -> Int64 {
  let _ = (self.clock, self.is_nano, self.group, unit, id)
  abort(
    "PR-B：契约骨架，docs/spec/03-date.md §9.4 与腿 G|interval(k1,MS/SECOND)",
  )
}

///|
/// 差值毫秒数（参照 `intervalMs(String)` = `interval(key, DateUnit.MS)`）
pub fn GroupTimeInterval::interval_ms(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  let _ = (self.is_nano, self.group, id)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.4")
}

///|
/// 差值秒数（参照 `intervalSecond(String)`；六件全部委托 `interval_in`，不留第二套算法）
pub fn GroupTimeInterval::interval_second(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  let _ = (self.is_nano, self.group, id)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.4")
}

///|
/// 差值分钟数（参照 `intervalMinute(String)`）
pub fn GroupTimeInterval::interval_minute(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  let _ = (self.is_nano, self.group, id)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.4")
}

///|
/// 差值小时数（参照 `intervalHour(String)`）
pub fn GroupTimeInterval::interval_hour(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  let _ = (self.is_nano, self.group, id)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.4")
}

///|
/// 差值天数（参照 `intervalDay(String)`）
pub fn GroupTimeInterval::interval_day(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  let _ = (self.is_nano, self.group, id)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.4")
}

///|
/// 差值周数（参照 `intervalWeek(String)`）
pub fn GroupTimeInterval::interval_week(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  let _ = (self.is_nano, self.group, id)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.4")
}

///|
/// 差值说成中文时长（参照 `intervalPretty(String)` = `DateUtil.formatBetween(intervalMs(id))`）
///
/// - Note: 中间量已经是毫秒 ⇒ 纳秒档在这里已经除过一次 1e6；本库委托 `format_between`（§9.5），不复制那套档位算法。
pub fn GroupTimeInterval::interval_pretty(
  self : GroupTimeInterval,
  id? : String = "",
) -> String {
  let _ = (self.is_nano, self.group, id)
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.4 与 §9.5")
}

///|
/// 清空所有键（参照 `clear()`，参照是 `map.clear()` 不重建 map；链式那半条不承诺，同 `restart`）
pub fn GroupTimeInterval::clear(self : GroupTimeInterval) -> Unit {
  let _ = self.group
  abort(
    "PR-B：契约骨架，docs/spec/03-date.md §9.4 与腿 G|clear then interval",
  )
}
