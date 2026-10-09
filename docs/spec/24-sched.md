# 24 · `sched` —— cron 的触发面（任务表 + 到点执行）

对位 hutool `cn.hutool.cron` 的调度族（`CronUtil`/`TaskTable`/`Scheduler`/`task/*`/`CronTimer`/`listener/*`/`timingwheel/*`）。
**件不在 hutool-core**：现读 `hutool-cron-5.8.35.jar`（与仓内参照版本同号），全 jar 43 个 `.class`，其中调度族 20 件。
进度状态见 `docs/ROADMAP.md` 第 24 行；本文是这一行契约的唯一真相。

> 读数来源统一说明：本轮所有"参照侧"主张出自对同一份 jar 的 `javap -p` 现读，**不是**行为读数
> （`javap` 只给签名与字段，给不了"重复 id 时覆盖还是报错"这类行为）。行为类判据一律进 §6 待腿核，
> 由新增腿 `scripts/Cron5Leg.java` 转正后才允许出现在用例里。

---

## 1. 三条硬差异（代价先说，再看契约）

| # | 差异 | 依据 |
|---|---|---|
| 1 | **本包是全仓唯一 `import moonbitlang/async` 的包**（模块级 `moon.mod` 因此带一条 `import` 段） | 口径翻案见 `AGENTS.md` 零依赖四条那节；`CronTimer` 在参照侧 `extends Thread`，本库无 OS 线程 API，事件循环是唯一并发模型 |
| 2 | **本包只承诺三档（wasm / js / native），四目标一致这一条对它不成立** | 实测：`moon check --target wasm-gc` 通过，但 `moon run`／`moon test --target wasm-gc` 一律 `Error: [4021] Value run_async_main not found in package moonbitlang/async` 且 rc=1——**该档根本没有异步可执行入口**，不是丢测试。摘档机制是包级 `supported_targets` |
| 3 | **native 档只能由 CI（Linux）出证** | 本机 MinGW 编译 async 自带 C stub 时撞 `#error "Currently only MSVC is supported on Windows"`（`event_bus.c`、`fs.c` 两处现读命中），与本包实现无关 |

## 2. 分层与验收线

参照的 `TaskTable.executeTaskIfMatch(Scheduler, long)` 把"判定"和"执行"焊在一件 `void` 方法里，
在同步全冻结的测试体系下不可判据化。本包按这条线劈开：

- **纯计算半**（§3 的 `table_*` 与 `due_indices`）：全同步、不推进状态、不读 OS 时钟 ⇒ 期望值可冻、可做变异对照。
- **触发壳半**（`scheduler_*`）：只做"等 + 调 + 推状态"，**时钟与时延源一律注入**（#24.15/#24.16）。

验收线（本包三档判据，缺一档就是恒绿的摆设）：
1. 假 sleeper + 注入时钟下，`scheduler_tick` 的三条各有独立断言：到点该触发、不到点不该、**同一瞬间连喂两次就重复触发两次**（腿 N2 现读 `hits=2`，参照不去重 ⇒ 本库同形，这条断言钉的是"确实会重复"，不是"不重复"）；
2. **阳性对照**：把一个栅格算坏（例如去掉"秒对齐"），上述判据必须转红——"tick 恒返回 0"是自欺，不是通过；
3. 真事件循环只在 wasm/js 两档各做一次抽样：注册一条秒级表达式，确认确实执行过（异步语义不因摘档而漏测）。

跨栈矩阵**不含**本包：现读 `scripts/contract-tests/contract_runner.py` 无 timer 用例，
"调度真的触发"不是 13 栈契约格。所以本包的验收线全部在仓内，不要拿矩阵绿当调度绿。

## 3. 公开面台账（10-09 已落地；`abort` 与包级豁免同笔撤掉）

| 件 | 语义 | hutool 对位（`javap -p` 现读） | 边界 / 差异 |
|---|---|---|---|
| #24.1 `trait Task { async fn execute(self : Self) -> Unit }` | 任务体 | `task/Task`：`public interface Task { void execute() }` | **改判**：参照同步，本库 `async`（任务体要能查库/发请求）；见 §4 第 1 行 |
| #24.2 `struct CronConfig { match_second, zone }` | 配置两档 | `CronConfig`：字段 `boolean matchSecond` + `TimeZone timezone` | 区名用 `String` 接 `date` 内置 IANA 表，不搬 `TimeZone` 对象 |
| #24.3 `config_default() -> CronConfig` | 默认配置 | `CronConfig()` 无参构造 | 默认区来源显式化（§4 第 3 行） |
| #24.4 `table_new() -> TaskTable` | 空表 | `TaskTable()` / `TaskTable(int)` + `DEFAULT_CAPACITY` | 容量不进契约 |
| #24.4b `struct TaskTable { ids, patterns, tasks }` | 内部形状 | 现读为**三条并行 List** + `ReadWriteLock`，`add(String, CronPattern, Task)` | 字段全 `priv`：形状不进契约，只有下标/键两档入口进 |
| #24.5 `table_add(t, id, cron_text, task)` | 登记 | `TaskTable.add` + `CronUtil.schedule(id, expr, task)` | 文本在本包边界解析成 `cron` 对象（参照 `add` 收已构造对象）；重复 id 行为**待腿核**（§6 N1） |
| #24.6 `table_remove(t, id) -> Bool` | 摘除 | `TaskTable.remove(String) -> boolean` | 同形 |
| #24.7 `table_update_pattern(t, id, cron_text) -> Bool` | 运行中改表达式 | `TaskTable.updatePattern(String, CronPattern) -> boolean` | 参照有一等件 ⇒ 跟 |
| #24.8 `table_ids(t) -> Array[String]` | 在册 id | `getIds() -> List<String>` | **本库承诺插入序**（§4 第 4 行） |
| #24.9 `table_task_at(t, index) -> &Task` | 按下标取 | `getTask(int)` | 越界从 `IndexOutOfBoundsException` 换成 `UnknownTask` 档 |
| #24.10 `table_pattern_text(t, id) -> String` | 按 id 取表达式 | `getPattern(String)` | 文本归一委托 `cron` 包公开件，不重造 |
| #24.11 / #24.12 `table_size` / `table_is_empty` | 条数与空判定 | `size()` / `isEmpty()` | 两件都在 ⇒ 都收 |
| #24.13 `due_indices(t, cfg, now) -> Array[Int]` | **核心改判件**：此刻该触发哪些下标 | `executeTaskIfMatch` 的判定半边 | 纯函数、不执行；入参 `@date.DateTime` 而参照是 `long millis`（§4 第 2 行） |
| #24.15 `type Clock = () -> Int64` | 时钟注入口 | 无对位（参照直接 `System.currentTimeMillis`） | 与 `date` 的 `clock_fixed`/`clock_system` 同形，不另造抽象 |
| #24.16 `type Sleeper = async (Int) -> Unit` | 时延源注入口 | 无对位（参照是 `Thread` 睡眠） | 本包能脱离计时依赖被评审的前提 |
| #24.17 `struct Scheduler` + `scheduler_new` | 调度器 | `Scheduler` 现读字段面 `config`/`started`/`daemon`/`timer`/`taskTable`/两 manager/`listenerManager`/`threadExecutor` | 只保留 `table`/`config`/`started` 三件语义面 |
| #24.18 `scheduler_tick(s) -> Int` | 跑一拍（不循环） | `executeTaskIfMatch` 整体 | 返回执行条数；时刻取自注入时钟 ⇒ 可测 |
| #24.19 `scheduler_start` / `scheduler_stop` / `scheduler_is_started` | 启停与状态 | `CronUtil.start`/`stop` + `Scheduler.started` | `start` 是全仓唯一使用 async 定时器处；任务体异常**吞掉**（跟随参照，§6 P1）、`stop` **不等不切**（§6 P2）、同 unit 内**不去重**（§6 N2） |
| #24.20 `suberror SchedError { UnknownTask \| DuplicatedTask \| BadCron }` | 错误三档 | `CronException extends RuntimeException`（只带消息） | 消息不进契约；`DuplicatedTask` 是否可达取决于 §6 N1，不可达就撤档 |
| #24.22 `scheduler_on_failed(s, handler)`，`handler : (String, Error) -> Unit` | 注册失败回调；**缺省不注册 ⇒ 任务体错误被忽略**（与参照同形） | `listener/TaskListener.onFailed(TaskExecutor, Throwable)` | P9 已拍：只收这一件。回调是同步的（不参与事件循环），要在 `start` 前注册；没注册时的行为就是参照那个吞掉，注册了等于把参照"进 Log"那一半显式交给调用方 |

## 4. 本库改判（逐条给理由，不给"统一口径"这种话）

1. `Task.execute` 写 `async`：参照同步，本库唯一并发模型是事件循环。
2. 时刻入参用 `@date.DateTime`，不用参照的 `long millis`：`cron` 包 #19.2 的入口就是 `DateTime`，
   本包与其同源，避免"一个库两套时刻轴"。
3. 默认区不跟随"读宿主"这条隐式路径写进判据：参照 `CronPattern.match(millis)` 内部 `new DateTime(millis)`
   即宿主默认区，而 boot2 侧靠 `CronUtil` 灌入的表达式钉住行为——本包把区名做成显式配置项（#24.2）。
4. `table_ids` 承诺插入序：参照是 `List`（腿 N1 现读 `ids=[dup]`、`add` 追加/`remove` 删除 ⇒ 插入序与参照同形，这一条其实不是改判，只是把序显式写成承诺）。
5. **语义层零改判**（10-09 owner 定，覆盖 P1/N2/P2 三条）：吞异常、不去重、stop 不等不切，一律与 hutool 同形。本包留在契约里的差异只有**结构层**——`execute` 写 `async`（§4 第 1 行）、时刻入参用 `DateTime`（第 2 行）、区名显式化（第 3 行）、无全局单例、判定与执行劈成两件（#24.13 与 #24.18）。

## 5. 不收清单（每条带现读理由）

| 件 | 不收理由 |
|---|---|
| `task/InvokeTask` | 现读字段是 `Object obj` + `java.lang.reflect.Method` ⇒ MoonBit 无运行时反射（与 00-hutool-map 的"无运行时反射/动态代理"同档）；boot2 真实用法也是方法引用（`timerTaskRunner::action`），不是反射查找 |
| `task/RunnableTask` | 参照用它是把 `java.lang.Runnable` 适配成 `Task`；本库任务体直接收 `&Task`，没有需要适配的第二种形状 |
| `CronTimer` | 现读 `extends Thread` ⇒ 线程模型不收 |
| `TaskExecutor` / `TaskExecutorManager` / `TaskLauncher` / `TaskLauncherManager` | 参照的线程池与发射器状态机；本库单事件循环 + 注入时延源，无对应物 |
| `listener/*`（`TaskListener` 三法 `onStart`/`onSucceeded`/`onFailed(TaskExecutor, Throwable)`） | 10-09 已拍 P9：**只收失败那一件**（`on_failed`，见 §3 表 #24.22）——参照的三个回调都以 `TaskExecutor` 为参数，本库没有执行器对象，所以载荷取「触发失败的那条 id + 错误本身」，不照抄 `TaskExecutor`+`Throwable` 的形状。`onStart`/`onSucceeded` 仍不收（本库既没有执行器生命周期，也没有成功事件的可观测需求） |
| `timingwheel/*`（`TimingWheel`/`SystemTimer`/`TimerTask`/`TimerTaskList`） | `SystemTimer` 现读依赖 `DelayQueue` + `bossThreadPool`；`TimingWheel` 的 slot 计算（`tickMs`/`wheelSize`/`advanceClock`）倒是可纯测件，**登记第二批**，本批不开面 |
| `CronUtil` 的 `Setting` 通道（`setCronSetting`/`schedule(Setting)`） | 读配置文件 ⇒ 违反"OS 能力只走 `env` 三件" |
| `CronConfig` 的 `TimeZone` 对象 | 跨对象搬 Java 时区类型无意义，本库用区名字符串 |

## 6. 待拍 / 待腿核

读数来源：`scripts/Cron5Leg.java`（真跑 JVM，参照 jar 与仓内版本同号 5.8.35；jar 不提交）。
下面 §5 之外新添的"同刻重复触发"一条是**本轮腿照出来的**，`javap` 看不出来。

| # | 事项 | 参照侧读数（腿） | 本库处置 |
|---|---|---|---|
| N1 | 重复 id 的 `add` | `CronException: Id [dup] has been existed!`；表**原样不动**（`size=1`、`ids=[dup]`、三条 List 各 1、`getTask` 仍是第一个、`getPattern` 仍是第一个） | **跟随**：`table_add` 对重复 id `raise DuplicatedTask(id)`，且失败后表不变。`DuplicatedTask` 这一档由"可能不可达"转成**在案可达**（§3 那条 note 就地作废） |
| P1 | 任务体抛异常 | 异常**不外漏**：换了 `UncaughtExceptionHandler` 也收到 `surfaced=none`；抛异常那条与同期正常那条**都照常按秒续触发**（`boomHits=4` / `okHits=4`） | **跟随参照**（10-09 owner 定：参照侧语义必须与 hutool 一致，本库不自创）：任务体抛出的错误在 `tick` 里被忽略，调度照常继续。代价要写明白——本库没有日志通道，所以这里是**静默丢弃**，不像参照还能进它的 `Log`；要可见只有把参照 `listener` 族的失败那一件收进来——**P9 已拍（10-09）：收 `on_failed` 一件**（#24.22），不注册就照参照吞掉 |
| P2 | `stop` 撞上执行中的任务 | 任务体睡 1800 ms、900 ms 处 `stop`，结果 `hits=1` **`done=1`** ⇒ 参照**不打断**在跑的任务，放完再收 | **跟随**：`scheduler_stop` 只摘后续定时器、不等不切；本库这条从"待拍"转为已定（要"等到跑完"的语义另说，参照没有） |
| N2 | 同一毫秒连喂两次 `executeTaskIfMatch` | `hits=2` ⇒ **重复触发**。参照的去重不在匹配路径上：`spawnExecutor` 每次都新建一个 `TaskExecutor` 丢进线程池，秒对齐只发生在 `CronTimer.run` 的唤醒时刻 `(now / unit + 1) * unit`（`unit` 由 `matchSecond` 取 1000 或 60000） | **跟随参照，P8 已闭**（10-09 owner 定）：`scheduler_tick` **不做幂等、不去重**，同 unit 内重复喂同一瞬间就重复执行。原本我建议"记住上次已触发瞬间"是自创语义，撤。调用方要防重复，责任在它自己的唤醒对齐上（参照也是这么做的：`CronTimer.run` 的 `(now / unit + 1) * unit`） |

⚠ 本轮更正一条我自己写错的读数：先前把"秒栅格 `millis / 1000 * 1000`"记在 `TaskTable.executeTaskIfMatch`
上，`javap -c` 现读否掉了——匹配路径直接拿原始 `millis` 调 `CronPattern.match(TimeZone, long, boolean)`，
对齐在 `CronTimer.run`。这条更正也说明 §2 验收线里"同刻再调一次不重复"当时是**按我的设想写的，不是参照行为**。

| P5 | `cron_expr` 独立包建不建 | **已拍（10-09）：不建**。`sched` 已经依赖 `cron`+`date`，拆包不会让它少一个依赖，只会多出一份要靠比对门禁按住的重复实现；`docs/spec/25-cron_expr.md` 作决策留痕保留，逐包表第 25 行保持未开工 |
| P10 | 落地后要不要同轮接进 mldong-moon 的 `sys/timer` | **已拍（10-09）：先不接**，本包按库收口。现读 `scripts/contract-tests/contract_runner.py` 没有 timer 用例 ⇒ 跨栈矩阵不含调度触发；接进去等于改一栈的运行行为，且要先跟 boot2 `TimerTaskRunListener` 的「启动灌表 + start」逐件对表，另开一单 |

## 8. 落地轮读数（10-09，两档真跑）

- 用例：`Total tests: 12, passed: 12, failed: 0`，wasm 与 js 两档各跑一遍同读数；零警告。
  前三块是 PR-A 的形状级恒等式，后九块是 spec §2 验收线的判据（到点 / 不到点 / 同瞬间连喂两次就执行两次 /
  唤醒对齐 / 缺省吞异常与注册回调 / 摘除后三条数组同步收缩 / 改表达式 / 重复 id 抛且表不变 / 坏表达式 raise）。
- **变异对照 7 条全抓到**（在副本里打，不碰共享树；每条都断言"文件确实变了"再跑）：

  | 变异 | 结果 |
  |---|---|
  | 匹配恒真（`cron_match` 之后 `|| true`） | 1 块红（不到点那条） |
  | 匹配取反 | 5 块红 |
  | 任务异常不再吞（去掉 catch） | 1 块红（on_failed 那条） |
  | `unit` 随 `match_second` 取反 | 1 块红（唤醒对齐那条） |
  | 对齐算式去掉 `+1` | 1 块红 |
  | 摘除时数组不收缩（少一次 `pop`） | 1 块红 |
  | 重复 id 不查（不 raise） | 1 块红 |

  第五条的第一版形态**不是红而是挂住**：那时实现写成 `if wait > 0 { sleeper(wait) }`，去掉 `+1` 后
  `wait` 恒 0 ⇒ sleeper 永不调用 ⇒ 循环永不退出，测试被超时杀掉（exit 143）。"不收敛"和"报红"是两种
  失效形状，前者在 CI 上表现为挂钟而不是失败。因此实现改成**无条件让出一次**（`wait<=0` 时喂 0），
  这条变异才落成干净的一块红——顺带去掉了一处忙轮询。
- 真事件循环抽样（§2 第 3 条）：一次性探针件（跑完即删，不进常跑套件，避免计时依赖）
  在 wasm 与 js 两档各测得 `sleeps=2 hits=1`，走的是 `default_clock()` + `default_sleeper` 的真等待。
- 本版编译器三条裁决（撞到才写，不靠记忆）：
  ① `Sleeper = async (Int) -> Unit` **不收**普通函数值（"has type (Int) -> Unit, wanted async (Int) -> Unit"），
  而空转的 `async fn` 吃 `unused_async` ⇒ 假 sleeper 必须真 await 一手（用本包 `default_sleeper(0)`）；
  ② 实现 trait 方法时**不写** `async`（照 `mldong-moon` 的 `DevQueryApi` 实现形状），与 ① 不同形；
  ③ 调用方要能构造 `CronConfig` ⇒ 必须 `pub(all) struct`（普通 `pub struct` 判 read-only type）。
  另：`Array::to_string()` 走已废弃的 `Show` ⇒ 断言直接比数组；本版没有 `Array::remove_at`，
  摘除走"前移一位 + `pop`"。

## 7. 门禁影响（口径翻案的机械部分）

- **G1**：从"白名单前缀 `moonbitlang/core`"改成"按包归属放行 `moonbitlang/async`"——只有本包目录可 import，
  其余包照旧报红；判据三条腿一起改（`moon tree` 主判据、`moon.mod` 静态扫、逐包 `moon.pkg` 点名），
  并补阳性对照（① 别的包塞一条 async import 必须红；② 塞一个真第三方必须红）。
- **G14**：新增 C4——文档里"cron 调度器不做/只算不调度"这类声明，反查件 `sched/pkg.generated.mbti`，
  证据正则取现读公开面（`table_add|scheduler_start|due_indices`）。三档自检要一并扩到 C4，
  否则这条新档在自检里是摆设。
- **G3**：逐档矩阵按包区分——本包 `wasm-gc` 是结构性缺档（§1 第 2 行），摘档理由必须能被人复算，
  不许写成"该档跳过"了事。
- **G15**：骨架新增未覆盖行，基线必须单独一笔重算。
