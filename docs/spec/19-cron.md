# 19 · `cron` —— cron 表达式的解析、匹配与"下一个匹配时刻"

对位 hutool `cn.hutool.cron.pattern.CronPattern`。**件不在 hutool-core**：`unzip -l hutool-core.jar | grep -ic cron` 现读 **0 条**，
本包的参照件全在独立 artifact `hutool-cron-5.8.35.jar`（现读 28 个 class：`pattern/` 4 件 + `matcher/` 6 件 + `parser/` 2 件，
外加 `CronUtil`/`TaskTable`/`Scheduler`/`CronTask`/`InvokeTask`/`CronTimer`/`CronConfig`/`CronException`/`timingwheel/*`/`listener/*`）。
进度状态见 `docs/ROADMAP.md` 第 19 行；本文是这一行契约的唯一真相。

---

## 1. 对位与边界（先划清，再写代码）

| 处置 | 件 | 理由 |
|---|---|---|
| **本批落地** | `CronPattern` 的公开面：解析（5/6/7 段 + `\\|` 多选表达式）、`match`、`nextMatchAfter`、`nextMatch`、`toString` | 纯计算，期望值全部可由参照腿逐条直读（1386 行） |
| **不做（整族）** | `CronUtil`/`TaskTable`/`Scheduler`/`CronTask`/`InvokeTask`/`CronTimer`/`CronConfig`/`timingwheel/*`/`listener/*` | 行内早写的"**只算不调度**"：调度要有线程/定时器，本库全同步、零 OS 能力（`AGENTS` 零依赖四条）；`CronConfig` 还读 `settings` 文件 |
| 第二批（排期） | `CronPatternBuilder`、`CronPatternUtil`（`nextMatchAfter(pattern, zone, n)` 一次取 N 个、`describe` 人类可读化、`TimeZone` 档） | 建造器与"取 N 个"是聚合层，`describe` 要一整套文案表，`TimeZone` 档与本库"偏移显式传"的口径要先拍 |
| **不在本包** | 日期算术（月末、闰年、epoch 换算） | 全部委托 `date` 包（`Date::of`、`DateTime::of`、`days_in_month`、`is_leap_year`、`add_*`），本包不重算 |

**时刻的输入形状**：参照侧有四个入口，其中 `match(long millis, bool)` 与 `match(TimeZone, ...)` 依赖 `TimeZone.getDefault()`——
本机默认是 `Asia/Shanghai`（腿里 `sys.default_tz` 为凭），同一毫秒数在两台机器上会给两个读数。
本库**只做无时区的本地时刻**：入口收 `@date.DateTime`（`date` 包的形状，偏移由调用方决定），
参照腿因此全程钉在 UTC 上（`sys.tz|UTC`），只取 `match(LocalDateTime, bool)` / `nextMatchAfter(Calendar(UTC))` / `nextMatch(Calendar(UTC))` 三条不随默认时区变的路径。

---

## 2. 公开面（第一批 7 件 = 1 错误 + 1 结构 + 5 函数）

```
pub suberror CronError { BadParts(String) BadValue(String) BadAlias(String)
                        OutOfRange(String, Int) NonPositiveStep(String) BadSyntax(String) }
pub struct Cron                                   // 解析后的表达式（内部是若干 PatternMatcher 的等价物）
pub fn cron_of(pattern : String) -> Cron raise CronError         // #19.1
pub fn cron_match(c : Cron, dt : @date.DateTime, match_second? : Bool = false) -> Bool        // #19.2
pub fn cron_next_match_after(c : Cron, dt : @date.DateTime) -> DateTime                        // #19.3
pub fn cron_next_match(c : Cron, dt : @date.DateTime) -> DateTime                              // #19.4
pub fn cron_pattern_text(c : Cron) -> String                                                   // #19.5
```

七段的名字与区间按参照侧 `Part` 枚举现读钉住：`SECOND 0~59`、`MINUTE 0~59`、`HOUR 0~23`、
`DAY_OF_MONTH 1~31`、`MONTH 1~12`、`DAY_OF_WEEK 0~6`（`Week.SUNDAY.ordinal()=0`…`SATURDAY=6`，**7 也当周日**）、
`YEAR 1970~2099`。

---

## 3. 语义条目（每条给参照腿读数标签，标签是 §4 腿 A 的行首）

| # | 判据 | 参照读数 |
|---|---|---|
| 1 | 段数必须是 **5~7**；`""` 与 `"   "` 段数为 0 而**参照不报错**（解析成空匹配器），到"取下一个时刻"才炸 | `ok.40\|CronException:Pattern [* * * *] is invalid, it must be 5-7 parts!`、`ok.42\|OK:`、`ok.43\|OK:   `、`nx.42.0\|NullPointerException:...calendar" is null`（本库把这一档挪到解析期 `BadParts`，两侧读数都在） |
| 2 | 5 段 = 分/时/日/月/周；6 段第一位是**秒**、7 段最后一位是**年**；**秒位默认不参与匹配**，只有 `match_second=true` 才参与；**5/6 段没有年档**（年档恒真 ⇒ 2099 之后照样给下一时刻），**7 段式的年档参与匹配** | `m.32.9` 对 `ms.32.9`（`59 59 12 * * *` 在 `09:15:30`/`12:59:00` 类时刻上两档不同值）、`ok.33\|OK:0 0 12 * * ? 2099` + `nx.33.*`（2099 之后照给 ⇒ 年份段没参与） |
| 3 | 子表达式文法：列表 `,`（**去重**）、区间 `-`、步进 `/`；优先级 **`/` > `-` > `,`**，故 `2,3,6/3` ≡ `{2,3,6}` | `ok.5`、`m.5.*` 真值表、`m.29.0`（`1,1,1` 去重后仍只算一个点） |
| 4 | `*` 与 `?` 都是"全匹配"（`?` 与 `*` 同义，不做互斥校验） | `ok.6\|OK:? * * * *`、`m.6.*` 与 `m.0.*` 逐条同值 |
| 5 | 步进不检查范围、但 `step < 1` 报错；`*/0` 就是这一档 | `ok.35\|CronException:Non positive divisor for field: [*/0]` |
| 6 | 越界值报错，消息带档名与区间 | `ok.36\|MINUTE value 60 out of range: [0 , 59]`、`ok.46\|DAY_OF_MONTH value 32 out of range: [1 , 31]`、`ok.47\|... value 0 out of range`、`ok.48\|HOUR value 24 out of range` |
| 7 | **`-1` 这类"长度 ≤2 的负数"绕过 `checkValue`**（`parseRange` 的短路分支），被当成一个普通值塞进匹配器，参照侧实测**能匹配也能给出下一时刻**（等价于某个回绕位置） | `ok.37\|OK:-1 * * * *`、`m.37.*` 全表、`nx.37.0\|OK:2024-02-29 12:58:00`。本库按第 6 条的区间判 `-1` **非法**（`OutOfRange(MINUTE, -1)`）——两侧都在案，这是"参照自相矛盾时取可推导那一侧 + 两侧读数都留档"的同一条规矩 |
| 8 | 月份与星期支持**不区分大小写的别名**（`jan`~`dec`、`sun`~`sat`）；数字 `0` 与 `7` 都表示周日 | `ok.9`/`ok.10`、`m.9.*` 与 `m.10.*` 逐条同值；`m.17.*` 与 `m.18.*`（`7` 与 `0`）逐条同值 |
| 9 | `L` **只在 `DAY_OF_MONTH` 单 token 时成立**（当月最后一天）；`LW`、`15L` 报 `BadAlias`；星期侧 `5L`/`6L`/`FRI#2` **参照抛 `IllegalArgumentException`**（`Week.valueOf` 的枚举查找漏到外面），没有 `L`/`#` 语义 | `ok.11\|OK:0 12 L * *`、`m.11.0\|OK:true`（2024-02-29）与 `nx.11.0\|OK:2024-03-31 12:00:00`；`ok.12\|CronException:Invalid alias value: [LW]`、`ok.13\|...[15L]`、`ok.14\|IllegalArgumentException:No enum constant cn.hutool.core.date.Week.5L`、`ok.16\|...Week.FRI#2` ⇒ 本库统一成 `CronError.BadAlias(...)`（分岔行，见 §5 第 3 行） |
| 10 | **不存在的日子夹到月末**：`0 12 31 4 *`（4 月没有 31 日）实测给 4 月 30 日 ⇒ `DayOfMonthMatcher` 对 31 的处理与 `L` 同分支 | `nx.49.0\|OK:2024-04-30 12:00:00`、`nx.49.2\|OK:2025-04-30 12:00:00`、`nx.49.5\|OK:2100-04-30 12:00:00`；本库跟随（同一条 `date.days_in_month` 夹取） |
| 11 | `日` 与 `周` 同时限定时是**且**（不是 Quartz 的或）：`0 12 1 * MON` 只给"1 号且周一" | `m.19.*` 全表（`2024-06-01` 是周六 ⇒ false；`2024-06-03` 才是 1 号且周一）与 `nx.19.*` |
| 12 | 反向区间（`8-2`、`5-1,7`）**不报错**，按参照实现给出的展开集合参与匹配 | `ok.30`/`ok.31` + `m.30.*`/`m.31.*` 真值表 + `nx.30.*`/`nx.31.*` |
| 13 | `next_match_after(dt)`：若 `dt` 本身已匹配则**先 +1 秒再找**（参照为 issue#I9FQUA 明写的行为）；`next_match(dt)` 则"已匹配就返回自身" | 同一条基线下两族读数成对：`nx.11.0\|OK:2024-03-31 12:00:00` 对 `nm.11.0\|OK:2024-02-29 12:00:00`；`nx.17.0` 对 `nm.17.0`（不匹配时两族同值，如 `nx.11.1`==`nm.11.1`） |
| 14 | 下一时刻的**毫秒恒为 0**，且跨年后不回退；参照侧对 5/6/7 段都不看年份 ⇒ 2099 之后照样给（`nx.17.5\|OK:2100-01-03 12:00:00`） | 同左 + `nx.*` 全部读数（396 条） |
| 15 | 回退查找会把字段值送出**该段区间之外**（`* * * * *` 在 2024-12-31 23:59:01 给分=60、`0 12 L * *` 给月=13），参照靠 `Calendar` 的 lenient 语义整体滚进下一时/下一年 ⇒ 本库出口前按 epoch 秒/天整体折算，不逐字段校验 | `nx.0.2\|OK:2025-01-01 00:00:00`、`nx.11.2\|OK:2025-01-31 12:00:00` |
| 16 | 年档全部落在过去 ⇒ 参照在 `getMin(YearValueMatcher)` 上抛 `IllegalArgumentException:Invalid matcher`；本库按参照自己「以下所有值置为最小值」的规矩回绕到年集合最小值 | `0 0 12 * * ? 1970` 六个基准一律给 `1970-01-01 12:00:00`（参照原文留在 `nx.34.*`/`nm.34.*` 标签里） |
| 17 | `cron_pattern_text` 返回**原样**表达式（不去空白、不规范化） | `ok.N\|OK:<原表达式>` 全部 66 条（`ok.43\|OK:   ` 三个空格原样回来） |

---

## 4. 参照腿

| 腿 | 载体 | 读数 | 备注 |
|---|---|---|---|
| A 实测 | 真 `hutool-cron-5.8.35.jar` + `hutool-core-5.8.35.jar`（`CronPattern` 依赖 core 的 `StrUtil`/`NumberUtil`/`CollUtil`）+ 本机 JDK 17.0.14，`javac -encoding UTF-8`；全程 `TimeZone("UTC")` | **1386 行**（`cron_ref.txt`）：66 个表达式的 `ok.N`（含 8 条报错消息原文）× 12 个时刻的 `m.N.K`/`ms.N.K` × 6 个基准的 `nx.N.B`/`nm.N.B` | 表达式清单刻意覆盖：`*`、`?`、`,`、`-`（含反向）、`/`（含 `*/0`）、别名大小写、`L`/`LW`/`15L`、`5L`/`6L`/`FRI#2`、`0`/`7` 周日、日与周同限定、6 段与 7 段、`2/29` 闰年、`4/31` 夹月末、空串与纯空白、4 段与 7 段 |
| B 源码 | `CronPattern.java`（215 行）+ `Part.java`（105）+ `parser/PartParser.java`（284）+ `matcher/PatternMatcher.java` 关键路径 | 段数校验在 `PatternParser`、`/ > - > ,` 优先级在 `parseStep`/`parseRange`、`+1 秒` 在 `nextMatchAfter`（注释点了 issue#I9FQUA）、`日/周` 的且关系在 `PatternMatcher.match` | 报错消息模板只用来**对号**，本库不复制模板（§5 第 4 行） |

期望值全部由脚本从腿 A 灌入，**手打零条**；`m/ms/nx/nm` 四类标签在每条断言的注释里逐一回指。

落地轮（PR-B）**把冻结文件里的 1112 条用例逐条反抽出来重跑了一遍腿**（腿按测试文件的形状回读，不是照抄标签），
抓到 PR-A 四处夹具缺陷并当场改正：
① `nx/nm` 两块第 2 号基准，腿用的是 `2024-12-31 23:59:00`，测试写成 `2024-03-31 12:00:00`（64 条期望与错基准配对；改基准后 70 个 `dt(...)` 与标签全吻合）。
② `nx.34.*`/`nm.34.*` 十二条期望直接抄了 Java 异常串——本库的出口形状根本产不出这条读数（改判见 §3 第 16 条，参照原文留在标签注释里）。
③ 块 8 末尾两条把参照值当本库期望，与块 1 的 `BadParts` 断言自相矛盾 ⇒ 降级为留档注释。
④ `nx_tag`/`nm_tag` 辅助件漏了 `OK:` 前缀，与 204 条期望不同形。
**教训：契约轮的期望值除了核对抄写，还要过一遍「本库形状能不能产出这条读数」的机器判据——光对齐字符串是对的，不够。**

---

## 5. 分岔与不跟随（逐条给两侧读数）

| # | 分岔 | 参照 | 本库 | 依据 |
|---|---|---|---|---|
| 1 | 时区 | `match(long millis, …)` 与 `match(TimeZone, …)` 存在且默认档走 `TimeZone.getDefault()` | 只收 `@date.DateTime`（本地时刻 + 显式偏移），无毫秒/时区入口 | 同输入两机两读；本库全同步且不带 tzdb（`date` 包同一口径） |
| 2 | 空表达式 | 解析通过、`match` 恒 false、`nextMatchAfter` 抛 NPE（`CollUtil.min` 返回 null） | 解析期 `raise BadParts("")` | `ok.42`/`nx.42.0` 两条读数为凭；"能构造但一用就 NPE"不算可观测语义 |
| 3 | 星期侧的 `L`/`#` | `IllegalArgumentException: No enum constant …Week.5L`（枚举查找漏到外面，且**不是** `CronException`） | `raise BadAlias("5L")`——异常种类收进本包错误面 | 消息原文照留在 `ok.14`/`ok.15`/`ok.16`；跟随一个 `IllegalArgumentException` 等于把 Java 枚举机制漏给调用方 |
| 4 | 报错消息 | `"{} value {} out of range: [{} , {}]"` 等模板 | 错误变体带**档名 + offending 文本/值**，不复制模板 | 消息文案随 hutool 版本变；契约要钉的是"哪一档、哪一段、哪个值" |
| 5 | `-1 * * * *` | 接受并参与匹配（`length()<=2` 分支绕过 `checkValue`） | `raise OutOfRange("MINUTE", -1)` | 第 7 条两侧读数；与 `60 * * * *` 报错这条同族规则相矛盾，取"可推导"的一侧 |
| 6 | 第 7 段年份 | 年档**参与匹配**（`Part.YEAR` 的 1970~2099 只在解析时校验；5/6 段压根没有年档） | 跟随 | 第 2 条 + 第 14 条 + `m.33.*`/`nx.33.*` 读数 |
| 7 | `describe`/`CronPatternBuilder`/`nextMany` | 有 | 第二批 | 第 1 节 |
| 8 | 调度族 | 有（含时间轮） | **整族不做** | 第 1 节"只算不调度" |
| 9 | 年档无未来解 | `getMin` 没考虑 `YearValueMatcher` ⇒ `IllegalArgumentException:Invalid matcher: cn.hutool.cron.pattern.matcher.YearValueMatcher`（6 个基准实测全部如此） | 按参照自己"置最小值"的同一规矩回绕到年集合最小值，保住 #19.3/#19.4 是总函数 | §3 第 16 条；两侧读数都在案（`nx.34.*`/`nm.34.*` 标签原文即参照值） |
| 10 | 星期中文别名 | `Week.of` 另认 `星期X`/`周X`（issue#3637） | 不跟随（只认三字母与全名，大小写不敏感） | 本库不引中文码表；夹具不覆盖，遇到再议 |
| 11 | 字段越界的出口 | 靠 `Calendar` lenient 滚动 | 出口前按 epoch 秒/天整体折算，效果同滚 | §3 第 15 条 |

---

## 6. 变异对照（落地轮已逐条实跑：wasm 档单包 `moon test -p mldong/moon-hutool/cron`，基线 绿 8/红 0；工装开局先还原并跑一次基线，收尾按 sha256 校验还原）

| 变异 | 实测结果 |
|---|---|
| `日` 与 `周` 的"且"改成"或" | **抓到**：绿 4/红 4（match 块与承重块同时红） |
| `next_match_after` 去掉"已匹配先 +1 秒" | **抓到**：绿 7/红 1（正是 `nx.11.0` 对 `nm.11.0` 那组成对读数） |
| 别名大小写改成敏感 | **抓到**：绿 1/红 7（`JAN-MAR` 与 `jan-mar` 两侧一起塌） |
| `?` 不按全匹配处理 | **抓到**：绿 2/红 6 |
| 逗号不参与拆分（`2,3,6/3` 整串当一个 token，即把 `,` 的优先级压到 `/` 之下） | **抓到**：绿 3/红 5 |
| 月末夹取去掉（`match_day` 的月末分支） | **不是值红，是不收敛**：120s 墙钟超时。`nx.49.*` 能命中全靠"含 31 就按月末判"，去掉后逐日重试永远命中不了 ⇒ **月末夹取是"总函数"承诺的承重件，不只是取值正确性**（#19.3 文档与 §3 第 10 条同批更正） |
| 周日 `7` 归一化漏掉（只认 0） | **抓到**：绿 3/红 5 |
| 段数判定改成「≥5 即放行」（8 段也收） | **当时是等价变异（绿 8/红 0）**——50 条 `ok.*` 里没有 8 段式 ⇒ 判据不可达。**本条欠账已当场清**：腿新读 3/8/9 段与带值 8 段四条全部 `CronException:Pattern [...] is invalid, it must be 5-7 parts!`，补进块 8 四条断言后重跑同一变异 ⇒ **绿 7/红 1，抓到了** |
| 反向区间改成报错 | **抓到**：绿 4/红 4 |
| 毫秒清零漏掉 | **无法作为变异挂载**：出口只走 `from_epoch_millis(天秒 × 1000, 0)`，毫秒位没有第二个来源，改它等于推翻整条 §3 第 15 条。读数面由 204 条 `nx/nm` 的秒位钉住（`:01` 那一档见 `nx.41.*`） |

---

## 7. 状态

`docs/ROADMAP.md` 第 19 行的状态与本节同步（`scripts/sync_status.py --write` 生成，勿手改）：
**已实现**（10-05，两笔：`49d2973` 期望落盘 → PR-B 逻辑落地）。三档一致 425 = 绿 425/红 0；§6 十条变异逐条实跑（7 条抓到、1 条不收敛、1 条不可挂载；「段数 ≥5 即放行」当时是等价变异，已按腿新读的 3/8/9 段读数补四条断言把判据做成可达并重跑成红 ⇒ 抓到）；落地轮另完成 1112 条用例的逐条反抽重跑对账，抓到并改正 PR-A 四处夹具缺陷（见 §4）。用例总数不变（8 块），断言数 1058 → 1062。
