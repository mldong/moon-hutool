# 25 · `cron_expr` —— cron 表达式解析与"下一次匹配时刻"（**纯计算**）

对位 hutool `cn.hutool.cron.pattern.CronPattern` 一族。**件不在 hutool-core**：现读 `hutool-cron-5.8.35.jar`
（`unzip -l` 列 `.class`），`pattern/` 5 件 + `pattern/matcher/` 7 件 + `pattern/parser/` 3 件。
进度状态见 `docs/ROADMAP.md` 第 25 行；本文是这一行契约的唯一真相。

---

## 1. 定位：为什么表达式族要从 `cron` 包搬出来

`cron` 包（第 19 行）已经交付并绿着（10-08 终局读数见 `19-cron.md`），本包**不是**它的替代品，而是把
"算"这一半从已交付包里拆出来独立发布，让**只算不调度**的用户能单独依赖：

| | `cron`（19，已交付） | `cron_expr`（25，本包） | `scheduler`（26） |
|---|---|---|---|
| 依赖 | 仅 `date` | 仅 `core` | 本包 + `moonbitlang/async` |
| 承诺目标档 | 四档 | **四档** | 三档（wasm/js/native） |
| 内含 | 表达式 + 时刻算术（`@date.DateTime` 入口） | 表达式 + epoch 毫秒入口 | 任务表 + 触发壳 |

⚠ **搬动的是已交付面，不是新写的面**：本包开工时 `cron/` 整目录冻结、一行不改，本包的实现按
`19-cron.md` 已冻结的判据重写一份到毫秒轴上。两包会**暂时并存**（各自绿各自），去重方式＝待拍 P5
（见 §6），不在本包笔里顺手做。

时刻轴的选择理由：`date` 包依赖 `cron`（`date/system_clock.mbt` 现读 `import "mldong/moon-hutool/cron"`），
反向依赖会成环。表达式层不碰年月日算术，所以它只需要"从给定 epoch 毫秒向前找下一个匹配瞬间"这一件事，
`@date.DateTime` 那一档留在 `cron`/上层做换算。

## 2. 三条硬差异（先说代价，再看契约）

| # | 差异 | 读数来源 |
|---|---|---|
| 1 | 入口是 **epoch 毫秒**（`Int64`）而不是 `@date.DateTime`；时区偏移由调用方以 `offset_minutes : Int` 显式传（与 `date` 的 `offset_minutes` 档同形） | 依赖环事实（§1 末行） |
| 2 | 秒档默认**参与**匹配（`match_second` 无可选参，七段式的年档照旧存在） | `19-cron.md` §3 第 1 条：参照"秒段默认不参与"是 `CronPattern` 的 `matchSecond` 开关行为，本包把它钉成默认开——**这条要在 PR-A 的期望值里逐档钉死**，不许照抄参照默认 |
| 3 | 无解时的形状跟随参照（`19-cron.md` §3 第 5 条"每个合法模式都有解"），但错误面独立成 `CronExprError`（不与 `cron` 包的 `CronError` 共用类型） | 类型分家是依赖分家的必然；两侧同判据处必须逐字同形，判据见 §4 |

## 3. 公开面骨架（PR-A：签名即契约，体一律 `abort`）

| 件 | 语义 | hutool 对位（现读） | 边界 / 错误 | 状态 |
|---|---|---|---|---|
| #25.1 `cron_expr_of(text) -> CronExpr raise CronExprError` | 解析 5~7 段文本 | `CronPattern(String)` 构造器族 | 段数、子表达式、别名、区间四档错误 | 待落地 |
| #25.2 `cron_expr_match_at(expr, millis, offset_minutes) -> Bool` | 给定瞬间是否命中 | `CronPattern.match(long, TimeZone)` | 不解释时区来源，只吃偏移分钟 | 待落地 |
| #25.3 `cron_expr_next_after(expr, millis, offset_minutes) -> Int64` | 严格晚于入参的下一个命中瞬间 | `CronPattern.nextMatchAfter(Calendar)` | 已命中先加一秒（`19-cron.md` §3 第 6 条同判据） | 待落地 |
| #25.4 `cron_expr_next_at(expr, millis, offset_minutes) -> Int64` | 命中则给自身，否则下一个 | `CronPattern.nextMatch(Calendar)`（5.8.30 起） | 与 #25.3 在同一条基线上成对分岔，不许合并 | 待落地 |
| #25.5 `cron_expr_matched_millis(expr, from, to, limit, offset_minutes) -> Array[Int64]` | 区间内一批命中 | `CronPatternUtil.matchedDates` | `limit` 上限与空区间形状待腿核（§6 N1） | 待落地 |
| #25.6 `cron_expr_text(expr) -> String` | 归一化原文本 | `CronPattern.toString()` | 归一化程度＝参照逐字符（`19-cron.md` #19.5 同判据） | 待落地 |
| #25.7 `CronExprPart` 七档 + 界值三件 | 段枚举与每段上下界 | `pattern.Part`（公开枚举） | 段序 `ordinal()` 不进契约（`19-cron.md` §8 已记） | 待落地 |
| #25.8 `CronExprBuilder` 建造器四件 | 按段设值拼表达式 | `pattern.CronPatternBuilder` | 校验时机跟随参照（`19-cron.md` §9） | 待落地 |

**期望值不在本文手写**：判据一律回 `19-cron.md` §3~§11 那些已冻读数，由新增腿
`scripts/Cron5Leg.java`（同一批表达式，改喂 `Calendar(UTC)` + 毫秒轴）产出后由生成脚本灌进
`cron_expr_test.mbt`。手写期望值＝违反 G5。

## 4. 与 `cron` 包的重叠纪律（这条是本包最容易烂的地方）

两包对同一批表达式的判定**必须逐字同形**，否则用户会拿到"换个包结果不一样"的坑。机制不是靠人记，
而是 §5 那条去重决议 + 一条待补门禁（**现读不存在，别当已有**）：计划件名 `scripts/overlap_parity.py`，
形状＝同一批表达式在两包各跑一遍 `match`/`next_after`，两份输出逐字节比对，并配一条阳性对照
（往一侧塞一个坏样本，必须报红）。在该门禁落地前，这条纪律只有人盯——本包 PR-B 之前要么先补上它，
要么把两包的重叠夹具做成同一份生成物。

## 5. 去重与终局（待拍 P5，两案并排）

| 案 | 做法 | 代价 |
|---|---|---|
| A 并存分层 | `cron`（19）永久保留 = 表达式 + `DateTime` 换算；`cron_expr`（25）= 表达式 + 毫秒轴；`scheduler`（26）只依赖 25 | 表达式实现两份，靠 §4 的比对门禁按住 |
| B 逐层下沉 | 落地 25 后，`cron` 包改成薄封装（`@date.DateTime` ⇄ 毫秒的换算 + 转发），表达式实现只留一份 | **动已交付包**：`19-cron.md` 的 `.mbti` 与 364 块用例要复走，G15 基线重算，且 19 那一行状态词得改 |

建议 **A**：19 已交付且带全套冻结期望，把它改成转发层等于复走 364 块（"改九份要复走九条腿"）。
B 只在 §4 的比对门禁证明 A 维护不动时才值得启动。

## 6. 待拍 / 待腿核

| # | 事项 | 现状 |
|---|---|---|
| P5 | §5 的 A/B | **待拍**（本文按 A 写契约；选 B 不改本包签名，只改 `cron` 包那一边） |
| N1 | #25.5 的 `limit` 上限与空区间行为 | 参照侧读数缺，`Cron5Leg.java` 未写 ⇒ 待腿核，不许照本库直觉先钉 |
| P6 | 本包是否公开 `CronExprError` 的消息文本 | 按既有规矩"消息不进契约、档位进契约"（`19-cron.md` §5 第 4 条同判据），除非腿证明外部要文本 |

## 7. 门禁与文档影响

- G13：本包目录名 `cron_expr`，spec 文件名 `25-cron_expr.md`（**下划线包名不在 `sync_status.py` 的
  `ROW`/`SPEC` 正则字符类里**，两处要各加 `_`，并给自检补一条"下划线包名的行号/文件名必须被解析到"，
  否则这条判据对不认识的形状是静默空转）。
- G11：ROADMAP 加第 25 行，状态词按当场读数取 `契约已冻结`（无测试文件的骨架期该词是否被 G11 认可，
  以现跑读数为准，不照本文推断）。
- G14：本包不涉及"不承诺声明"，无 CLAIMS 条目（触发包另立一号，其契约待写，与本包同批评审）。
