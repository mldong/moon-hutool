# 24 · `sched`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 24 行（`sched`）“用例”列的逐字原文。
编号 24 是稳定 ID：与该包契约 `docs/spec/24-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `sched` | hutool-cron 的调度族（`CronUtil`/`TaskTable`/`Scheduler`/`task/*`/`CronTimer`/`listener/*`/`timingwheel/*`；现读 `hutool-cron-5.8.35.jar` 共 43 个 `.class`，其中调度族 20 件，**件不在 hutool-core**） | 已实现（10-09 两笔：PR-A 冻结签名 → PR-B 落地并撤骨架豁免。公开面以 `sched/pkg.generated.mbti` 现读为准（本行不写死件数）。本包是全仓唯一 `import moonbitlang/async` 的包，四目标一致这一条对它不成立——`wasm-gc` 档 async 根本没有异步可执行入口（实测 `moon run`/`moon test --target wasm-gc` 报 `[4021] Value run_async_main not found in package moonbitlang/async` 且 rc=1），已用包级 `supported_targets` 摘掉该档；native 档只能由 CI 出证（本机 MinGW 编译 async 自带 C stub 时撞 `#error "Currently only MSVC is supported on Windows"`）。对位关系全部改由 `javap -p` 现读支撑，本轮据此照掉三处想当然：参照侧**没有** `CronStatus` 枚举、**没有** `TaskInfo` 类，`TaskTable` 内部是 `ids`/`patterns`/`tasks` 三条并行 List 而不是 Map） | `docs/spec/24-sched.md` | 12 块（判据来源：`scripts/Cron5Leg.java` 四条行为读数 + spec §8 的变异 7 条全抓到；wasm/js 两档各 12 绿 0 红 0 警告） |
````
