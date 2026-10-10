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
/// `Int64` 能表示的最大纳秒数那一侧的界（饱和用，参照 `(long)` 转换是饱和语义）
const I64_MAX : Int64 = 9223372036854775807L

///|
/// `Int64` 的下界。`-9223372036854775808L` 这个字面量在本版是"负号 + 越界正数"，写不出来 ⇒ 算出来。
const I64_MIN : Int64 = 0L - I64_MAX - 1L

///|
/// 纳秒数按单位取整（参照 `TimeUnit.convert(nanos, NANOSECONDS)`：**向零截断**，负档同样向零，
/// 腿 `CU` 行 16 档 × 7 单位逐格钉着）。
///
/// 为什么做成包内判据而不是给 `ChronoUnit` 挂一个公开 `to_nanos()`：参照那侧的换算常数属于
/// `java.util.concurrent.TimeUnit` 自己，本库要的是"同一张表只有一处真相"；
/// 而 `TimeUnit::to_millis` 已是公开件（对位 `DateUnit` 的六档），两族不同源、不合（spec §9.3 末行）。
fn nanos_in(nanos : Int64, unit : ChronoUnit) -> Int64 {
  match unit {
    Nanoseconds => nanos
    Microseconds => nanos / 1000L
    Milliseconds => nanos / 1000000L
    Seconds => nanos / 1000000000L
    Minutes => nanos / 60000000000L
    Hours => nanos / 3600000000000L
    Days => nanos / 86400000000000L
  }
}

///|
/// 纳秒 → 秒（参照 `DateUtil.nanosToSeconds(n)` = `n / 1.0E9`，腿 `NS` 行）。走 `Double` 除，
/// 所以超出 `Double` 精度的那几档本库也不假装精确——契约只冻能精确表示的读数。
fn nanos_to_seconds(nanos : Int64) -> Double {
  nanos.to_double() / 1000000000.0
}

///|
/// 摘要那半句（参照的模板常量 `"StopWatch '{}': running time = {} {}"`，腿 `PP|shortSummary`）。
/// 参照走 `StrUtil.format`，`null` 会打成字面 `null`——本库 `id` 非可选，那一档构造不出来。
fn summary_line(id : String, total : Int64, shot : String) -> String {
  "StopWatch '" + id + "': running time = " + total.to_string() + " " + shot
}

///|
/// 任务名那一格。参照是 `StringBuilder.append(String)`，null 进那侧会打成字面 `null`；
/// 本库用同样的字面量，不发明替换字符。
fn task_label(name : String?) -> String {
  match name {
    None => "null"
    Some(s) => s
  }
}

///|
/// 逐行拼串：每行后面都挂一个 LF（参照每行 append 一次 `getLineSeparator()`，腿 `PP` 各行结尾
/// 就带着分隔符）。**本库恒 LF**，差异声明在 spec §9.7.4。
fn join_lines(lines : Array[String]) -> String {
  let mut out = ""
  for line in lines {
    out = out + line + TM_LF
  }
  out
}

///|
/// 参照 `Math.round(double)`：`floor(x + 0.5)`，NaN ⇒ 0，超界饱和。
///
/// 与 `Double::round()` **不是一件事**（那是 `floor(x+0.5)` 没错，但本件还要处理 NaN 与饱和两档，
/// 参照那两档是 `(long)` 转换的既有语义，AGENTS 里 num 轮记过 `(-3.5)→-3` 这条同形判据）。
fn jround(x : Double) -> Int64 {
  if x != x {
    // NaN：参照 Math.round(NaN) == 0
    0L
  } else {
    let y = x + 0.5
    if y >= 9223372036854775807.0 {
      I64_MAX
    } else if y < -9223372036854775808.0 {
      I64_MIN
    } else {
      // to_int64 是向零截断；y 为负且非整时 floor 比截断再小 1
      let t = y.to_int64()
      if y < t.to_double() {
        t - 1L
      } else {
        t
      }
    }
  }
}

///|
/// 补零到 9 位（参照 `NumberFormat.getNumberInstance()` + `setMinimumIntegerDigits(9)` +
/// `setGroupingUsed(false)`，腿 `NF` 行十二档）。负号在补齐**之前**。
fn pad9(v : Int64) -> String {
  let s = v.to_string()
  if v < 0L {
    let digits = String::from_array(s.to_array()[1:])
    if digits.length() >= 9 {
      "-" + digits
    } else {
      "-" + zero_pad(9 - digits.length()) + digits
    }
  } else if s.length() >= 9 {
    s
  } else {
    zero_pad(9 - s.length()) + s
  }
}

///|
/// n 个 `0`
fn zero_pad(n : Int) -> String {
  let b : Array[Char] = []
  for _ in 0..<n {
    b.push('0')
  }
  String::from_array(b)
}

///|
/// 比值 → 百分号串（参照 `NumberFormat.getPercentInstance()` + `setMinimumIntegerDigits(2)`：
/// ×100 后 **HALF_EVEN** 取整、最少 2 位；`NaN` 连百分号都不出，`±∞` 出 U+221E）。
fn percent_of(num : Int64, den : Int64) -> String {
  if den == 0L {
    if num == 0L {
      "NaN"
    } else if num > 0L {
      "∞%"
    } else {
      "-∞%"
    }
  } else {
    // 符号按 IEEE 商的符号规则单独取：`0 / 负` 是 -0.0，参照给 "-00%"（腿 PC|-0.0 那一档）
    let neg = (num < 0L) != (den < 0L) || (num == 0L && den < 0L)
    let scaled = 100.0 * (num.to_double() / den.to_double())
    // 只把绝对值送进取整档，符号由上面那个 neg 单独决定：两处都带符号就写出 "--50%"
    let mag = if scaled < 0.0 { -scaled } else { scaled }
    let whole = if mag >= 9223372036854775807.0 {
      I64_MAX
    } else {
      jround_half_even(mag)
    }
    let digits = whole.to_string()
    let body = if digits.length() >= 2 {
      digits
    } else {
      zero_pad(2 - digits.length()) + digits
    }
    if neg {
      "-" + body + "%"
    } else {
      body + "%"
    }
  }
}

///|
/// HALF_EVEN：先看小数部分，正好 0.5 时取偶（参照 `RoundingMode.HALF_EVEN`，腿 `PC` 行 30 档）。
/// 入参取绝对值，所以这里只需处理非负半边。
fn jround_half_even(x : Double) -> Int64 {
  let t = x.to_int64()
  let frac = x - t.to_double()
  if frac > 0.5 {
    t + 1L
  } else if frac < 0.5 {
    t
  } else if t % 2L == 0L {
    t
  } else {
    t + 1L
  }
}

///|
/// 行分隔符：本库恒 LF。参照走 `FileUtil.getLineSeparator()` = `System.lineSeparator()`，
/// 本机现读 CRLF（腿 `LS` 行两条），换一个宿主就换一个字符 ⇒ 不可冻，spec §9.7.4 明写不跟随。
const TM_LF : String = "\n"

///|
/// 45 个连字符的分隔行与表头后半段（腿 `PP|dash-len||45`、`PP|header-seg`）。
const TM_DASH : String = "---------------------------------------------"

///|
const TM_HEAD_MID : String = "         %     Task name"

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
  match self {
    Nanoseconds => "ns"
    Microseconds => "μs"
    Milliseconds => "ms"
    Seconds => "s"
    Minutes => "min"
    Hours => "h"
    Days => "days"
  }
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
  self.name
}

///|
/// 时长的纳秒读数（参照内部存的就是纳秒）
pub fn TaskInfo::time_nanos(self : TaskInfo) -> Int64 {
  self.nanos
}

///|
/// 按单位取时长（参照 `getTime(TimeUnit)` = `unit.convert(nanos, NANOSECONDS)`，**向零截断**）
///
/// - Note: 负读数（时钟被往回拨）的截断方向由腿 `CU`/`TI` 行逐档冻结，不四舍五入、不夹零。
pub fn TaskInfo::time_in(self : TaskInfo, unit : ChronoUnit) -> Int64 {
  nanos_in(self.nanos, unit)
}

///|
/// 毫秒读数（`time_in(Millisecond)` 的薄封装，参照就是这么委托的）
pub fn TaskInfo::time_millis(self : TaskInfo) -> Int64 {
  self.time_in(Milliseconds)
}

///|
/// 秒读数（参照走 `DateUtil.nanosToSeconds(n)` = `n / 1.0E9`，腿 `NS` 行）
///
/// - Note: 契约只断**能精确表示**的档；`Double` 的十进制外形不参与冻结（参照那侧是 `String.valueOf` 的结果，
///   与本库 `Double::to_string` 的记法不是同一件事，spec §9.3 那行写明）。
pub fn TaskInfo::time_seconds(self : TaskInfo) -> Double {
  nanos_to_seconds(self.nanos)
}

///|
/// 秒表（对位 `cn.hutool.core.date.StopWatch`）
///
/// 参照四个入口（`()`、`(String)`、`(String, boolean)`、`create(String)`）在本库塌成一个带默认值的构造口：
/// 字节码现读 `create` 就是 `new StopWatch(String)`，而 `(String)` 那档的 `keep` 恒 `true`（`iconst_1`）。
pub struct StopWatch {
  priv watch_id : String
  priv clock : () -> Int64
  priv mut keep : Bool
  priv mut kept : Array[TaskInfo]
  priv mut last : TaskInfo?
  priv mut running : String?
  priv mut start_at : Int64
  priv mut total : Int64
  priv mut count : Int
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
/// - 示例见 `date/README.mbt.md` 的「计时：读钟的活儿交给调用方」一节。
pub fn stop_watch(
  clock : () -> Int64,
  id? : String = "",
  keep_task_list? : Bool = true,
) -> StopWatch {
  StopWatch::{
    watch_id: id,
    clock,
    keep: keep_task_list,
    kept: [],
    last: None,
    running: None,
    start_at: 0L,
    total: 0L,
    count: 0,
  }
}

///|
/// 表号（参照 `getId()`）
pub fn StopWatch::id(self : StopWatch) -> String {
  self.watch_id
}

///|
/// 开/关"逐条留存任务行"（参照 `setKeepTaskList(boolean)`）
///
/// - Note: 两条判据都来自参照字节码，不是本库取舍：`true` **只在当前不保留时**新建空表（已保留 ⇒ 空操作，
///   行还在）；`false` 直接把表丢掉 ⇒ **已经记下的行丢**。来回切一次就能观察到"表头还在、行是空"
///   （腿 `PP|keep-翻true后-pretty`）。
pub fn StopWatch::set_keep_task_list(self : StopWatch, keep : Bool) -> Unit {
  if keep {
    // 参照字节码：true 只在 taskList == null 时新建空表 ⇒ 已保留时是空操作，行还在
    if !self.keep {
      self.kept = []
    }
    self.keep = true
  } else {
    // false 是把表丢掉 ⇒ 已经记下的行一起没（腿 PP|keep-翻true后：表头都在、行是空）
    self.keep = false
    self.kept = []
  }
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
  if self.running is Some(_) {
    raise TimerAlreadyRunning
  }
  self.running = name
  self.start_at = (self.clock)()
}

///|
/// 结束当前任务（参照 `stop()`；五步顺序照字节码，`count` 与留存表长**解耦**）。
/// - Raises: `TimerNotRunning`——没在跑（腿 `W|stop@never-started`、`W|stop@not-running` 两档同判）
pub fn StopWatch::stop(self : StopWatch) -> Unit raise DateError {
  if self.running is None {
    raise TimerNotRunning
  }
  // 五步顺序照参照字节码：算差 → 累计 → 造 TaskInfo → 保留时才追进表 → 计数加一 → 清空当前名
  let last = (self.clock)() - self.start_at
  self.total = self.total + last
  let info = TaskInfo::{ name: self.running, nanos: last, }
  self.last = Some(info)
  if self.keep {
    self.kept.push(info)
  }
  self.count = self.count + 1
  self.running = None
}

///|
/// 是否有一条任务在跑（参照 `isRunning()`，字节码现读它判的就是"当前名 != null"）
pub fn StopWatch::is_running(self : StopWatch) -> Bool {
  self.running is Some(_)
}

///|
/// 当前任务名（参照 `currentTaskName()`）
///
/// - Note: `Some("")` 与 `None` 是两档：无名 `start()` 给 `Some("")`，`start(name=None)` 给 `None`。
pub fn StopWatch::current_task_name(self : StopWatch) -> String? {
  self.running
}

///|
/// 上一条任务的纳秒时长（参照 `getLastTaskTimeNanos()`）
/// - Raises: `NoLastTask`——一条都没跑完过（腿 `W|lastTaskMillis@fresh`）
pub fn StopWatch::last_task_nanos(self : StopWatch) -> Int64 raise DateError {
  let info = self.last_task_info()
  info.time_nanos()
}

///|
/// 上一条任务的毫秒时长（参照 `getLastTaskTimeMillis()`；与上一条同条件，参照 message 不同但类型相同）
/// - Raises: `NoLastTask`
pub fn StopWatch::last_task_millis(self : StopWatch) -> Int64 raise DateError {
  let info = self.last_task_info()
  info.time_millis()
}

///|
/// 上一条任务的名（参照 `getLastTaskName()`）
/// - Raises: `NoLastTask`
/// - Note: 无名任务给 `Some("")` 而不是 ERR（腿 `W|lastTaskName@after-stop-unnamed` 是空档）
pub fn StopWatch::last_task_name(self : StopWatch) -> String? raise DateError {
  let info = self.last_task_info()
  info.task_name()
}

///|
/// 上一条任务整条（参照 `getLastTaskInfo()`）
/// - Raises: `NoLastTask`
pub fn StopWatch::last_task_info(self : StopWatch) -> TaskInfo raise DateError {
  match self.last {
    None => raise NoLastTask
    Some(info) => info
  }
}

///|
/// 总时长按单位取（参照 `getTotal(TimeUnit)` = `convert(totalNanos, NANOSECONDS)`，向零截断）
pub fn StopWatch::total_in(self : StopWatch, unit : ChronoUnit) -> Int64 {
  nanos_in(self.total, unit)
}

///|
/// 总纳秒（参照 `getTotalTimeNanos()`——它不换算，直接给内部累计值）
pub fn StopWatch::total_nanos(self : StopWatch) -> Int64 {
  self.total
}

///|
/// 总毫秒（参照 `getTotalTimeMillis()` = `getTotal(MILLISECONDS)`）
pub fn StopWatch::total_millis(self : StopWatch) -> Int64 {
  self.total_in(Milliseconds)
}

///|
/// 总秒（参照 `getTotalTimeSeconds()` 走 `DateUtil.nanosToSeconds`）
pub fn StopWatch::total_seconds(self : StopWatch) -> Double {
  nanos_to_seconds(self.total)
}

///|
/// 结束过的任务条数（参照 `getTaskCount()`）
///
/// - Note: **与留存表长解耦**：`keep_task_list=false` 时参照计数照加、表却拿不到
///   （腿 `keep=false|taskCount|2` 对 `taskInfoLen|ERR`）。
pub fn StopWatch::task_count(self : StopWatch) -> Int {
  self.count
}

///|
/// 留存的任务行，按结束顺序（参照 `getTaskInfo()`）
/// - Raises: `TaskInfoNotKept`——`keep_task_list=false`（参照抛 `UnsupportedOperationException`）
/// - Note: 返回新数组（参照 `toArray` 也是新数组），改它不动内部状态
pub fn StopWatch::task_infos(
  self : StopWatch,
) -> Array[TaskInfo] raise DateError {
  if !self.keep {
    raise TaskInfoNotKept
  }
  // 参照 toArray 给的是新数组 ⇒ 本库同样交副本，改它不动内部留存表
  let out : Array[TaskInfo] = []
  for info in self.kept {
    out.push(info)
  }
  out
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
  summary_line(self.watch_id, self.total_in(unit), unit.shot_name())
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
  let shot = unit.shot_name()
  let head = summary_line(self.watch_id, self.total_in(unit), shot)
  if !self.keep {
    // 参照这一支只补一句 "No task info kept"，不出表头也不出分隔行
    head + TM_LF + "No task info kept"
  } else {
    let b : Array[String] = [head, TM_DASH, shot + TM_HEAD_MID, TM_DASH]
    for info in self.kept {
      let num = pad9(info.time_in(unit))
      let pct = percent_of(info.time_nanos(), self.total)
      let name = task_label(info.task_name())
      b.push(num + "  " + pct + "   " + name)
    }
    join_lines(b)
  }
}

///|
/// 一行汇总（参照 `toString()`）
///
/// - Note: 参照这里**不用** `pretty_print` 那套 `NumberFormat`，而是 `Math.round(100.0 × n / total)`：
///   向数轴正向取整、`NaN ⇒ 0`、不补零。两族混用是参照自己的形状，本库照抄不"顺手统一"
///   （`total=0` 那档参照 `to_string` 给 `= 0%` 而 `pretty_print` 给 `NaN`，两条都必须复现）。
pub fn StopWatch::to_string(self : StopWatch) -> String {
  let mut out = self.short_summary()
  if self.keep {
    // 这一族走 Math.round(100.0 × n / total)，与 pretty_print 的 NumberFormat 不是一套（§9.3 末行）
    for info in self.kept {
      let nanos = info.time_nanos()
      let pct = jround(100.0 * nanos.to_double() / self.total.to_double()).to_string()
      let part = "; [" +
        task_label(info.task_name()) +
        "] took " +
        nanos.to_string() +
        " ns = " +
        pct +
        "%"
      out = out + part
    }
  } else {
    out = out + "; no task info kept"
  }
  out
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
/// - 示例见 `date/README.mbt.md` 的「时长说成人话」一节。
/// - Note: 参照的构造参数名在字节码里是 **`isNano`** 而不是 `isMillis`——`new TimeInterval(true)` 拿到的是纳秒档
///   （腿 `Z|isMillis=true|interval|497100` 对上毫秒档的 `1`）。本库把两档做成两个具名构造口，就是为了不让这个坑重演。
pub fn group_time_interval(clock : () -> Int64) -> GroupTimeInterval {
  GroupTimeInterval::{ clock, is_nano: false, group: Map([]), }
}

///|
/// 纳秒档分组计时器（参照 `GroupTimeInterval(true)`，`getTime()` 那侧对位 `System.nanoTime()`）
pub fn group_time_interval_nanos(clock : () -> Int64) -> GroupTimeInterval {
  GroupTimeInterval::{ clock, is_nano: true, group: Map([]), }
}

///|
/// 毫秒档 + **构造即 start 空键**（参照 `TimeInterval()`：字节码现读 ctor 里就 `invokevirtual start:()J`）
///
/// - Note: 参照返回的是子类实例，本库返回同一类型 ⇒ 类型层面的父子区别消失，行为区别（预启动）保留。
pub fn time_interval(clock : () -> Int64) -> GroupTimeInterval {
  let g = group_time_interval(clock)
  // 参照 TimeInterval() 的字节码第 6 行就是 `invokevirtual start:()J` ⇒ 构造即起表
  let _ = g.start()
  g
}

///|
/// 纳秒档 + 预启动（参照 `TimeInterval(true)`）
pub fn time_interval_nanos(clock : () -> Int64) -> GroupTimeInterval {
  let g = group_time_interval_nanos(clock)
  let _ = g.start()
  g
}

///|
/// 给某个键记起点，返回**那一次读数本身**（不是差）。
///
/// - Note: 毫秒档下返回值就是 epoch 毫秒（腿 `T|start`）；重复 start 就是覆盖，参照没有"重复 start 报错"这一档。
pub fn GroupTimeInterval::start(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  let t = (self.clock)()
  self.group[id] = t
  t
}

///|
/// 重新起表（参照 `TimeInterval::restart()`）。参照返回 `this` 供链式，本库返回 `Unit` ⇒ **不承诺链式**。
pub fn GroupTimeInterval::restart(
  self : GroupTimeInterval,
  id? : String = "",
) -> Unit {
  let _ = self.start(id~)
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
  match self.group.get(id) {
    None => 0L
    Some(begin) => (self.clock)() - begin
  }
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
  let t = (self.clock)()
  // 参照：t - defaultIfNull(map.put(key, t), 0) ⇒ 未记过的键拿到的是那次读数本身
  let prev = match self.group.get(id) {
    None => 0L
    Some(v) => v
  }
  self.group[id] = t
  t - prev
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
  let raw = self.interval(id~)
  // 两步：纳秒档先换成毫秒，再按单位分；参照这两处除法都是向零截断（腿 CU 行负档为凭）
  let ms = if self.is_nano { raw / 1000000L } else { raw }
  match unit {
    // 参照 `unit == DateUnit.MS` 那一支直接返回 ⇒ 本库不重复除（数值同值，形状照它）
    Millisecond => ms
    _ => ms / unit.to_millis()
  }
}

///|
/// 差值毫秒数（参照 `intervalMs(String)` = `interval(key, DateUnit.MS)`）
pub fn GroupTimeInterval::interval_ms(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  self.interval_in(Millisecond, id~)
}

///|
/// 差值秒数（参照 `intervalSecond(String)`；六件全部委托 `interval_in`，不留第二套算法）
pub fn GroupTimeInterval::interval_second(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  self.interval_in(Second, id~)
}

///|
/// 差值分钟数（参照 `intervalMinute(String)`）
pub fn GroupTimeInterval::interval_minute(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  self.interval_in(Minute, id~)
}

///|
/// 差值小时数（参照 `intervalHour(String)`）
pub fn GroupTimeInterval::interval_hour(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  self.interval_in(Hour, id~)
}

///|
/// 差值天数（参照 `intervalDay(String)`）
pub fn GroupTimeInterval::interval_day(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  self.interval_in(Day, id~)
}

///|
/// 差值周数（参照 `intervalWeek(String)`）
pub fn GroupTimeInterval::interval_week(
  self : GroupTimeInterval,
  id? : String = "",
) -> Int64 {
  self.interval_in(Week, id~)
}

///|
/// 差值说成中文时长（参照 `intervalPretty(String)` = `DateUtil.formatBetween(intervalMs(id))`）
///
/// - Note: 中间量已经是毫秒 ⇒ 纳秒档在这里已经除过一次 1e6；本库委托 `format_between`（§9.5），不复制那套档位算法。
pub fn GroupTimeInterval::interval_pretty(
  self : GroupTimeInterval,
  id? : String = "",
) -> String {
  format_between(self.interval_ms(id~))
}

///|
/// 清空所有键（参照 `clear()`，参照是 `map.clear()` 不重建 map；链式那半条不承诺，同 `restart`）
pub fn GroupTimeInterval::clear(self : GroupTimeInterval) -> Unit {
  self.group.clear()
}
