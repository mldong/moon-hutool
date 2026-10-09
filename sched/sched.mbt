///|
// moon-hutool/sched —— cron 的**触发面**（对位 hutool-cron 的调度族）。
// 契约真相在 `docs/spec/24-sched.md`。10-09 两笔：PR-A 冻结签名 → PR-B 落地（本文件已无 `abort`，包级 `warnings` 豁免同笔撤掉，G12 盯这件事）。
//
// 对位关系的读数来源：`javap -p` 现读 hutool-cron-5.8.35.jar（与仓内参照版本同号）。
// 本轮实测照出三处"想当然"并已按读数改正：
//   ① 参照**没有** `CronStatus` 枚举、**没有** `TaskInfo` 类 ⇒ 本包不出这两件；
//   ② 参照的 `TaskTable` 内部是 `ids`/`patterns`/`tasks` **三条并行 List** + `ReadWriteLock`，
//      不是 Map ⇒ 本包的"按下标取"这一档因此有据（`getTask(int)`/`getPattern(int)` 在位）；
//   ③ 参照的"定时器"是 `CronTimer extends Thread`，`InvokeTask` 持 `java.lang.reflect.Method`
//      ⇒ 线程模型与反射件都**不收**（理由与代价见 spec §5）。
//
// 分层（spec §2/§3 的硬约束，评审先看这段）：
//   纯计算半（§24.3~24.12）：任务表 + "此刻该触发哪几条"，全同步、零 OS 能力、期望值可冻结；
//   触发壳半（§24.13~24.19）：全仓唯一 `import moonbitlang/async` 的地方，只做"等 + 调"，
//                             时钟与时延源都从注入口进——用例不许有计时依赖。

///|
/// #24.1 任务体。对位参照的 `cn.hutool.cron.task.Task`（现读：`public interface Task { void execute() }`）。
/// - Note: **本库改判**：参照是同步 `void execute()`，本库写成 `async`——本库唯一的并发模型是事件循环，
///   任务体要能查库/发请求；这条差异是口径差异不是漏实现（spec §4 第 1 行）
/// - Note: 方法首参写 `self : Self` 是 `&Trait` 能进结构体字段的前提
/// - Note: 参照的 `RunnableTask`（把 `java.lang.Runnable` 适配成 `Task`）**不收**：MoonBit 直接收函数值，
///   不需要适配件；`InvokeTask`（反射调用）**不收**：无运行时反射（现读字段是 `java.lang.reflect.Method`）
pub(open) trait Task {
  async fn execute(self : Self) -> Unit raise Error
}

///|
/// #24.2 配置两档。对位 `cn.hutool.cron.CronConfig`（现读：`timezone` + `matchSecond` 两个字段）
/// - Note: 区名档用字符串而不是 `TimeZone` 对象，接 `date` 包内置 IANA 表（现读 `date` 公开面）；
///   参照读 `settings` 文件那条通道（`CronUtil.setCronSetting`/`schedule(Setting)`）**不收**——违反"OS 能力只走 env 三件"
pub(all) struct CronConfig {
  match_second : Bool
  zone : String
}

///|
/// #24.3 默认配置：`match_second=false`、区名取宿主（参照默认走 `TimeZone.getDefault()`；
/// 本库把"取宿主"这一步显式化，判据见 spec §4 第 2 行）
pub fn config_default() -> CronConfig {
  CronConfig::{ match_second: false, zone: @date.default_zone(), }
}

///|
/// #24.4b 任务表内部形状：**三条并行数组**，跟随现读参照的 `ids`/`patterns`/`tasks` 三条 `List`
/// （不是 Map ⇒ "按下标取"与"按 id 取"两档入口都有据）。字段全 `priv`：形状不进契约，
/// 只有 §24.4~24.13 那几件进（`pub struct 字段要 priv` 是骨架期消 `unused_field` 的既有做法）。
/// - Note: 字段一律不带 `mut`——骨架期没人改，`unused_mut` 是 error 级；可变面归落地笔按语义加
pub struct TaskTable {
  priv ids : Array[String]
  priv patterns : Array[@cron.Cron]
  priv tasks : Array[&Task]
}

///|
/// #24.4 空表。对位 `cn.hutool.cron.TaskTable` 的 `TaskTable()` / `TaskTable(int)` 两档构造
/// - Note: 参照的 `DEFAULT_CAPACITY` 常量与带容量构造是给三条并行 List 预分配的，属实现邻接物；
///   本库只收无参构造，容量不进契约（spec §5 第 1 行）
pub fn table_new() -> TaskTable {
  TaskTable::{ ids: [], patterns: [], tasks: [], }
}

///|
/// #24.5 登记任务（显式 id）。对位 `TaskTable.add(id, CronPattern, Task)`，
/// cron 文本在本包边界处解析成 `@cron.Cron`（解析失败出 `BadCron`）
/// - Note: 重复 id 时参照**抛错且表原样不动**（腿 N1 现读：`CronException: Id [dup] has been existed!`，
///   `size`/`ids`/三条 List 都不变，第一个 task 与 pattern 保留）⇒ 本库跟随，见 spec §6 N1
pub fn table_add(
  t : TaskTable,
  id : String,
  cron_text : String,
  task : &Task,
) -> Unit raise SchedError {
  if table_index(t, id) is Some(_) {
    raise SchedError::DuplicatedTask(id)
  }
  let c = cron_or_raise(cron_text)
  t.ids.push(id)
  t.patterns.push(c)
  t.tasks.push(task)
}

///|
/// #24.6 摘除。对位 `TaskTable.remove(String)`，返回是否真摘掉（参照同形 `boolean`）
pub fn table_remove(t : TaskTable, id : String) -> Bool {
  let i = table_index(t, id)
  match i {
    None => false
    Some(idx) => {
      drop_at(idx, t.ids)
      drop_at(idx, t.patterns)
      drop_at(idx, t.tasks)
      true
    }
  }
}

///|
/// #24.7 改表达式（不换任务体）。对位 `TaskTable.updatePattern(String, CronPattern)`——
/// 这一件在参照里存在且独立于 `add`，说明"运行中改 cron"是参照的一等能力，本包跟
pub fn table_update_pattern(
  t : TaskTable,
  id : String,
  cron_text : String,
) -> Bool raise SchedError {
  let i = table_index(t, id)
  match i {
    None => false
    Some(idx) => {
      t.patterns[idx] = cron_or_raise(cron_text)
      true
    }
  }
}

///|
/// #24.8 在册 id 列表。对位 `TaskTable.getIds()`；参照返回 `List<String>`，
/// 本库出数组。id 序＝插入序（这条是**本库承诺**，参照那条 List 的序由其内部维护，见 spec §4 第 3 行）
pub fn table_ids(t : TaskTable) -> Array[String] {
  let _ = t
  t.ids.copy()
}

///|
/// #24.9 按下标取任务体。对位 `TaskTable.getTask(int)`（下标越界：参照是 `List.get` 的
/// `IndexOutOfBoundsException`，本库出 `UnknownTask` 档，spec §4 第 4 行）
pub fn table_task_at(t : TaskTable, index : Int) -> &Task raise SchedError {
  if index < 0 || index >= t.tasks.length() {
    raise SchedError::UnknownTask(index.to_string())
  }
  t.tasks[index]
}

///|
/// #24.10 按 id 取表达式原文。对位 `TaskTable.getPattern(String)`，本库出回写的文本
/// （现读 `cron_pattern_text(@cron.Cron)` 是 `cron` 包公开面，本包不重造归一化）
pub fn table_pattern_text(
  t : TaskTable,
  id : String,
) -> String raise SchedError {
  match table_index(t, id) {
    None => raise SchedError::UnknownTask(id)
    Some(idx) => @cron.cron_pattern_text(t.patterns[idx])
  }
}

///|
/// #24.11 条数。对位 `TaskTable.size()`；与 `table_is_empty` 同出一源（参照两件都在）
pub fn table_size(t : TaskTable) -> Int {
  let _ = t
  t.ids.length()
}

///|
/// #24.12 空表判定。对位 `TaskTable.isEmpty()`
pub fn table_is_empty(t : TaskTable) -> Bool {
  let _ = t
  t.ids.is_empty()
}

///|
/// #24.13 **本包的核心改判件**：给定此刻，返回该触发的**下标**数组。
/// 对位参照的 `TaskTable.executeTaskIfMatch(Scheduler, long)`——那一件是 `void` 且"判定 + 执行"耦在一起，
/// 本库把它劈成两半：判定留在这里（纯函数、不推进状态、不起线程、期望值可冻），执行在 `scheduler_tick`。
/// - Note: 参照签名收 `long millis`，本库收 `@date.DateTime`（与 `cron` 包 #19.2 的入口同形，
///   避免"本库自己再算一次时区"）；`match_second` 从 `CronConfig` 取，与 cron 包 `cron_match` 的可选参对得上
pub fn due_indices(
  t : TaskTable,
  cfg : CronConfig,
  now : @date.DateTime,
) -> Array[Int] {
  let out : Array[Int] = []
  for i in 0..<t.patterns.length() {
    if @cron.cron_match(t.patterns[i], now, match_second=cfg.match_second) {
      out.push(i)
    }
  }
  out
}

///|
/// #24.14 时钟注入口。与 `date` 包同形（现读 `date` 公开面：`clock_fixed(Int64) -> () -> Int64`、
/// `clock_system() -> () -> Int64`），本包不自带第二套时钟抽象
pub type Clock = () -> Int64

///|
/// #24.15 时延源注入口。触发壳里"等 N 毫秒"这件事的唯一出口：生产走 `moonbitlang/async` 的事件循环
/// 定时器（实测 wasm `slept_ms=135`、js `slept_ms=125` 到点），用例走假 sleeper。
/// 计时依赖的用例既冻不住期望值也做不了变异对照，所以这一档必须可注入
pub type Sleeper = async (Int) -> Unit

///|
/// #24.16 调度器。对位 `cn.hutool.cron.Scheduler`（现读字段面：`config`/`started`/`daemon`/`timer`/
/// `taskTable`/两个 manager/`listenerManager`/`threadExecutor`）。
/// 本库只保留 `config`/`taskTable`/`started` 三件语义面，线程池与监听器/执行器管理器一律不收（spec §5）
pub struct Scheduler {
  priv table : TaskTable
  priv config : CronConfig
  priv clock : Clock
  priv sleeper : Sleeper
  priv mut started : Bool
  priv mut on_failed : ((String, Error) -> Unit)?
}

///|
/// #24.17 构造。时钟与时延源**一律注入**（默认件由调用方在实装轮用 `date.clock_system` 与
/// `@async.sleep` 的包装提供）——这是本包能被脱离计时依赖评审的前提
pub fn scheduler_new(
  table : TaskTable,
  cfg : CronConfig,
  clock : Clock,
  sleeper : Sleeper,
) -> Scheduler {
  Scheduler::{
    table,
    config: cfg,
    clock,
    sleeper,
    started: false,
    on_failed: None,
  }
}

///|
/// #24.18 **跑一拍**（不循环、不起定时器）：取 `due_indices` 依次 `execute`，返回真正执行了几条。
/// 用例只调这一件就能覆盖"到点/不到点/同一瞬间连喂两次就重复执行两次"三条判据（第三条与参照同形，
/// 腿 N2 现读 `hits=2`），完全不必起事件循环
/// （spec §3 的验收线就钉在这条上；`scheduler_start` 只是它外面套的一层循环）
pub async fn scheduler_tick(s : Scheduler) -> Int {
  let _ = s
  let now = @date.datetime_in(s.config.zone, (s.clock)())
  match now {
    None => 0
    Some(instant) => {
      let due = due_indices(s.table, s.config, instant)
      for i in due {
        run_one(s, i)
      }
      due.length()
    }
  }
}

///|
/// #24.19 启动/停止。对位 `CronUtil.start`/`stop` 与 `Scheduler` 的 `started` 标记。
/// `scheduler_start` 是全仓**唯一**使用 `moonbitlang/async` 定时器处（wasm-gc 档该包无可执行入口，
/// 已用 `supported_targets` 摘档，代价见 spec §1 第 3 条）
/// - Note: 任务体抛出的错误在 `tick` 里**被忽略**，调度照常继续——跟随参照（腿 P1 现读 `surfaced=none`、
///   抛异常那条与同期正常条都按秒续触发）。代价本库更硬：没有日志通道，所以这里是静默丢弃，
///   要可见只能等 `listener` 族（对位 `TaskListener.onFailed`）第二批收（spec §6 P9）
pub async fn scheduler_start(s : Scheduler) -> Unit {
  let _ = s
  s.started = true
  let unit = if s.config.match_second { 1000L } else { 60000L }
  while s.started {
    // 参照 CronTimer.run 的唤醒对齐：先睡到下一个边界 (now/unit + 1)*unit，再以新读数跑一拍
    let before = (s.clock)()
    let wait = (before / unit + 1L) * unit - before
    // 无条件让出一次（wait<=0 时给 0）：写成 `if wait > 0 { … }` 会让变异"去掉对齐的 +1"
    // 退化成忙轮询挂住（本轮实测：测试不红而是被超时杀掉，exit 143），既不报红也不报绿
    (s.sleeper)(if wait > 0L { wait.to_int() } else { 0 })
    if s.started {
      let _n = scheduler_tick(s)
    }
  }
}

///|
/// 停止（置 `started=false` 并摘定时器；已在跑的那条是否跑完＝待拍 P3 的另一半）
pub fn scheduler_stop(s : Scheduler) -> Unit {
  let _ = s
  s.started = false
}

///|
/// 是否在跑。对位参照内部那个 `started` 布尔（`CronUtil.start`/`stop` 之后由外部读的那一态）
pub fn scheduler_is_started(s : Scheduler) -> Bool {
  let _ = s
  s.started
}

///|
/// #24.20 本包错误三档。对位参照的 `CronException`（现读：`RuntimeException` 的子类，只带消息）——
/// 按"消息不进契约、档位进契约"的既有规矩拆三件
/// - Note: `DuplicatedTask` 已在案可达（腿 N1 现读：重复 id 参照抛 `CronException` 且表不变）
pub suberror SchedError {
  UnknownTask(String)
  DuplicatedTask(String)
  BadCron(String)
}

///|
/// #24.22 注册失败回调（P9 已拍：只收这一件）。缺省不注册 ⇒ 任务体的错误被忽略（与参照同形，
/// 腿 P1 现读 `surfaced=none`）；注册了就把参照"进它自己的 Log"那一半显式交给调用方。
/// - Note: 回调同步、不参与事件循环；要在 `scheduler_start` 前注册
pub fn scheduler_on_failed(
  s : Scheduler,
  handler : (String, Error) -> Unit,
) -> Unit {
  s.on_failed = Some(handler)
}

///|
fn table_index(t : TaskTable, id : String) -> Int? {
  for i in 0..<t.ids.length() {
    if t.ids[i] == id {
      return Some(i)
    }
  }
  None
}

///|
// 本版没有 `Array::remove_at`（AGENTS 语法坑那条）⇒ 前移一位再 pop，pop 的返回值必须显式忽略
fn[T] drop_at(index : Int, xs : Array[T]) -> Unit {
  for i in index..<(xs.length() - 1) {
    xs[i] = xs[i + 1]
  }
  let _ = xs.pop()
}

///|
fn cron_or_raise(text : String) -> @cron.Cron raise SchedError {
  @cron.cron_of(text) catch {
    _ => raise SchedError::BadCron(text)
  }
}

///|
// 一条任务体的执行：错误按参照语义吞掉；注册了回调就把 (id, error) 递出去
async fn run_one(s : Scheduler, index : Int) -> Unit {
  let id = s.table.ids[index]
  let task = s.table.tasks[index]
  task.execute() catch {
    err =>
      match s.on_failed {
        None => ()
        Some(h) => h(id, err)
      }
  }
}

///|
/// #24.16b 生产侧默认时延源（全仓唯一直接踩 `moonbitlang/async` 定时器的一行）。
/// 注入点 #24.16 解决"可测"，这一件解决"可用"：调用方不写包装也能跑起来。
/// 落地笔暴露的缺口——注入形状定完，async 依赖其实悬空（`unused_package` 警告 + G1 的悬空 pin 判据双双抓到）
pub async fn default_sleeper(ms : Int) -> Unit {
  @async.sleep(ms)
}

///|
/// #24.15b 生产侧默认时钟：委托 `date` 的 `clock_system`（本包不另造时钟抽象，也不裸读 `@env.now()`）
pub fn default_clock() -> Clock {
  @date.clock_system()
}
