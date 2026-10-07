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
| 第二批（本批） | `CronPatternBuilder`、`CronPatternUtil`（`nextDateAfter`/`matchedDates`）、`Part` 七档、`CronPattern.nextMatch(Calendar)` 的带区名版 | 公开面与判据在 §8~§11；**早先写的"`describe` 人类可读化"要更正：5.8.35 的 `CronPatternUtil` 没有这件**（`javap` 现读），不是决定不做；`TimeZone` 档这一批收（第一批不收它的那条理由"本库不带 tzdb"已被 `date` §5 的内置表推翻，见 §11 第 6 行） |
| **不在本包** | 日期算术（月末、闰年、epoch 换算） | 全部委托 `date` 包（`Date::of`、`DateTime::of`、`days_in_month`、`is_leap_year`、`add_*`），本包不重算 |

**时刻的输入形状**：参照侧有四个入口，其中 `match(long millis, bool)` 与 `match(TimeZone, ...)` 依赖 `TimeZone.getDefault()`——
本机默认是 `Asia/Shanghai`（腿里 `sys.default_tz` 为凭），同一毫秒数在两台机器上会给两个读数。
第一批**只做无时区的本地时刻**：入口收 `@date.DateTime`（`date` 包的形状，偏移由调用方决定），
参照腿因此全程钉在 UTC 上（`sys.tz|UTC`），只取 `match(LocalDateTime, bool)` / `nextMatchAfter(Calendar(UTC))` / `nextMatch(Calendar(UTC))` 三条不随默认时区变的路径。
**第二批把"带区名的瞬间档"补上了**（#19.17~#19.19）——当初不补的那条理由是"本库不带 tzdb"，这条前提已被 `date` §5 的内置表推翻；
第一批那三条本地时刻入口一字不动，两档并排（判据与五区五读数见 §9 第 12 条、§11 第 6 行）。

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
| 1 | 时区 | `match(long millis, …)` 与 `match(TimeZone, …)` 存在且默认档走 `TimeZone.getDefault()` | ~~只收 `@date.DateTime`~~ → **第二批起两档都收**：无区名的 `@date.DateTime` 档（本行原样保留，第一批 1062 条期望一字不动）+ 带区名的瞬间档（#19.17~#19.19，见 §8） | 原依据的后半句"本库不带 tzdb"**已被 `date` §5 的内置表推翻**（603 区 36701 段），本行由第二批 §11 第 6 行改写；"同输入两机两读"这条判据不变，反而更强——腿 C 的 `M`/`N`/`N2` 三个家族就是五区五读数的机器证据 |
| 2 | 空表达式 | 解析通过、`match` 恒 false、`nextMatchAfter` 抛 NPE（`CollUtil.min` 返回 null） | 解析期 `raise BadParts("")` | `ok.42`/`nx.42.0` 两条读数为凭；"能构造但一用就 NPE"不算可观测语义 |
| 3 | 星期侧的 `L`/`#` | `IllegalArgumentException: No enum constant …Week.5L`（枚举查找漏到外面，且**不是** `CronException`） | `raise BadAlias("5L")`——异常种类收进本包错误面 | 消息原文照留在 `ok.14`/`ok.15`/`ok.16`；跟随一个 `IllegalArgumentException` 等于把 Java 枚举机制漏给调用方 |
| 4 | 报错消息 | `"{} value {} out of range: [{} , {}]"` 等模板 | 错误变体带**档名 + offending 文本/值**，不复制模板 | 消息文案随 hutool 版本变；契约要钉的是"哪一档、哪一段、哪个值" |
| 5 | `-1 * * * *` | 接受并参与匹配（`length()<=2` 分支绕过 `checkValue`） | `raise OutOfRange("MINUTE", -1)` | 第 7 条两侧读数；与 `60 * * * *` 报错这条同族规则相矛盾，取"可推导"的一侧 |
| 6 | 第 7 段年份 | 年档**参与匹配**（`Part.YEAR` 的 1970~2099 只在解析时校验；5/6 段压根没有年档） | 跟随 | 第 2 条 + 第 14 条 + `m.33.*`/`nx.33.*` 读数 |
| 7 | `describe`/`CronPatternBuilder`/`nextMany` | `CronPatternBuilder` 与"取 N 个"有；**`describe` 在 5.8.35 不存在** | 建造器与 `matched_dates` 第二批落地（§8）；`describe` 不进契约（参照没有这件，不是决定不做） | 第 1 节 + §8 那张"不收"表 |
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

## 7. 状态（逐批）

第一批：**已实现**（10-05 两笔：`49d2973` 期望落盘 → PR-B 逻辑落地），§6 十条变异逐条实跑（7 条抓到、1 条不收敛、1 条不可挂载；「段数 ≥5 即放行」当时是等价变异，已按腿新读的 3/8/9 段读数补四条断言把判据做成可达并重跑成红 ⇒ 抓到）；落地轮另完成 1112 条用例的逐条反抽重跑对账，抓到并改正 PR-A 四处夹具缺陷（见 §4）。用例总数不变（8 块），断言数 1058 → 1062；第二批又从同一条链上抓出一条**被行注释吞掉的死断言**（见 §12 末）。

第二批：**已实现**，两笔齐（`8d36458` 冻结 → 落地笔），21 块 2428 条断言，18 条变异 17 条抓红 + 1 条"去掉窗外守卫即不收敛"，五处夹具更正与两条新事实都记在 §12。本包合起来 29 块、全仓 599 块，wasm / js / wasm-gc 三档逐档通过。

---

## 8. 第二批公开面（段枚举 / 表达式建造器 / 带区名的三个入口）

```
pub enum CronPart { Second Minute Hour DayOfMonth Month DayOfWeek Year }         // #19.6
pub fn cron_part_name(p : CronPart) -> String                                     // #19.7
pub fn cron_part_min(p : CronPart) -> Int                                         // #19.8
pub fn cron_part_max(p : CronPart) -> Int                                         // #19.9
pub fn cron_part_check_value(p : CronPart, value : Int) -> Int raise CronError    // #19.10
pub struct CronBuilder                                                            // #19.11
pub fn cron_builder_new() -> CronBuilder                                          // #19.12
pub fn cron_builder_set(b : CronBuilder, part : CronPart, value : String) -> CronBuilder
      // #19.13（不校验）
pub fn cron_builder_set_values(b : CronBuilder, part : CronPart,
                               values : Array[Int]) -> CronBuilder raise CronError
      // #19.14（设置期逐值校验）
pub fn cron_builder_set_range(b : CronBuilder, part : CronPart,
                              begin : Int, end : Int) -> CronBuilder raise CronError
      // #19.15（设置期两端校验，不比大小）
pub fn cron_builder_build(b : CronBuilder) -> String                              // #19.16
pub fn cron_next_match_after_in(
  c : Cron, zone : String, millis : Int64) -> Int64?                              // #19.17
pub fn cron_next_match_in(
  c : Cron, zone : String, millis : Int64) -> Int64?                              // #19.18
pub fn cron_matched_dates(
  c : Cron, zone : String, start : Int64, end : Int64,
  count : Int, match_second : Bool) -> Array[Int64]? raise CronError              // #19.19
pub suberror CronError { ... BadRange(Int64, Int64) }                             // 新增变体（additive）
```

件归属（`javap` + 源码现读 hutool-cron 5.8.35，不是猜的）：

| 参照件 | 行数 | 本批收的东西 |
|---|---|---|
| `pattern/Part.java` | 105 | 七档的名字、`min`/`max`、`checkValue` 的判据 |
| `pattern/CronPatternBuilder.java` | 85 | `of`/`set`/`setValues`/`setRange`/`build`——`build()` 返回的是**串**而不是 `CronPattern`（实现 `Builder<String>`） |
| `pattern/CronPatternUtil.java` | 113 | `nextDateAfter`(2 参)、`matchedDates`(带 end 的那一族) |
| `pattern/CronPattern.java` | 215 | `nextMatch(Calendar)`（5.8.30 才有的一件，本批给它带区名的版本） |

**第二批不收的，逐条给理由**（三条是"参照的类型机制漏到接口上"，两条是"本库已有更好的形状"）：

| 不收 | 参照侧 | 理由 |
|---|---|---|
| `Part.getCalendarField()` | 返回 `java.util.Calendar.SECOND` 那套字段号（13/12/11/5/2/7/1，腿 O 行） | 本库没有 `Calendar`，那个整数是调用方拿不去的邻居物；腿的读数只用来证明"段序与 `Calendar` 字段号是两回事" |
| `Part.of(int)` | `ENUMS[i]`，越界给 `ArrayIndexOutOfBoundsException`（腿 O 行 -1/7/99 三条） | 参照的整数就是枚举声明序，Java 枚举的 `ordinal()` 本来也不该进公开契约；本库调用方要哪段就写哪个枚举值，不导出"按下标取段" |
| `nextDateAfter(pattern, start, isMatchSecond)` | `@Deprecated`，javadoc 自己写"isMatchSecond 无效" | 腿 D3 三组实测二参与三参**逐字节同值**（`1710050460000`/`1730655000000`/`1835366400000`）——那个布尔参数确实是死的；已废弃且无效的参数不进契约 |
| `matchedDates(patternStr, start, count, isMatchSecond)`（4 参，无 end） | 源码 `matchedDates(patternStr, start, DateUtil.endOfYear(start), …)` | 让调用方自己给 `end`：窗口是业务决定而不是库决定，且"到起始日年底"那一档在带区名版还要先定"年底按哪个区"，那是第二层语义 |
| `describe` | **5.8.35 没有这件**（`javap cn.hutool.cron.pattern.CronPatternUtil` 现读公开面只有上面那几条） | 第一批 §1 与 ROADMAP 那句"第二批含 `describe`"是照旧版本写的，本批更正——不是"决定不做"，是参照根本没有 |

一处口径要先说明：本包给 `Part` 开的是 `pub enum`，与 typex 那两格的"档位收串"先例不同。判据是这件**带行为**（`min`/`max`/`checkValue` 是按档不同的规则，且建造器的三个 setter 对它的校验时机不同），当串传就得自带一档"坏档名"错误；而 `DataSize` 那 15 档只是查表的键。参照侧它本来也是公开枚举，开枚举不是自创形状。

---

## 9. 第二批语义条目（每条给腿 C 的行标签，标签是 §10 那张表的行首）

| # | 判据 | 参照读数 |
|---|---|---|
| 1 | 七档的界：`SECOND 0~59`、`MINUTE 0~59`、`HOUR 0~23`、`DAY_OF_MONTH 1~31`、`MONTH 1~12`、`DAY_OF_WEEK 0~6`、`YEAR 1970~2099` | `P.*` 七条（腿 C 行首 `P`）——注意周日是 **0~6**，`7` 不在界里（第 3 条解释它为什么还能用） |
| 2 | `checkValue` **只判不改**：合法就原样返回，越界抛带档名与区间的消息 | `C.*` 77 条：`C|SECOND|7|RET|7`（不归一）、`C|MINUTE|60|ERR|MINUTE value 60 out of range: [0 , 59]`。消息模板里的空格位置照抄留在标签里，本库错误面**不复制模板**（沿用 §5 第 4 行） |
| 3 | 建造器的 `set(part, String)` **完全不校验**：文本原样进槽，坏文本要到解析期才报 | `K.junk_minute RET abc * * * *` 配 `RT.junk_minute ERR CronException\|Invalid alias value: [abc]`；`K.dow_seven RET * * * * 7` 配 `RT.dow_seven RET`（7 合法是因为解析侧把周日 `0`/`7` 同义，见 §3 第 8 条，而不是因为 `DAY_OF_WEEK` 的界里有 7） |
| 4 | `setValues`/`setRange` **在设置期**逐值 `checkValue`，不是到 `build()` 才报 | `K.values_out_of_range`、`K.range_out_of_range`、`K.second_out_of_range` 三条都是 `ERR_...CronException`，且 `RT.* = ERR_NoBuild`（根本没走到 build） |
| 5 | `build()` 的默认值只补"分~周"四段；**秒与年未设置就整段省略** ⇒ 段数随设置变 | `K.empty RET * * * * *`（5 段）、`K.second_set RET 30 * * * * *`（6 段）、`K.second_and_year RET 0 * * * * * 2030`（7 段） |
| 6 | 空白视同未设置**只对"分~周"成立**；空值数组给的是**空串**而不是"未设置" | `K.blank_minute`/`K.space_minute` 两条同给 `* * * * *`（那两段落在补默认的圈里）；但 `ArrayUtil.join(空, ",")` 给的是 `""` 而 `StrJoiner` 只跳 null ⇒ 秒/年这两档上"空数组"会留下多余空格：`K.values_empty_second RET " * * * * *"`（行首一格）、`K.values_empty_year RET "* * * * * "`（行尾一格）。**这一条是落地轮补的**：PR-A 那句"空数组视同未设置"只在分档看不出错（`K.values_empty` 与"未设置"同形），补了秒/年两格才露出来（见 §12 变异 K14） |
| 7 | `setRange` 不校验 `begin <= end`：反向区间照建 | `K.range_reversed RET * * 20-5 * *` 配 `RT.range_reversed RET`——与 §3 第 12 条（解析侧照收反向区间）同族，不矛盾 |
| 8 | **只设年不设秒 ⇒ 参照产出它自己解析不了的串** | `K.year_only_no_second RET * * * * * 2030`（6 段）配 `RT.year_only_no_second ERR CronException\|DAY_OF_WEEK value 2030 out of range: [0 , 6]`。6 段式第一位是秒 ⇒ `2030` 落到周档。本库在这一格补秒为 `*`（分岔见 §11 第 1 条） |
| 9 | `matchedDates` 的 `count` 是 **add-then-check**，且直接当 `ArrayList` 初始容量 | `CB.count 0 RET 1`（要 0 条却给 1 条）、`CB.count -1 ERR java.lang.IllegalArgumentException\|Illegal Capacity: -1`（Java 容器内部件漏到调用方）、`CB.count 1 RET 1`、`CB.count 2 RET 2`；`M.count_zero.*` 五区都给一条。本库 `count <= 0 ⇒ 空表`（§11 第 2 条） |
| 10 | 窗口 `[start, end)`：**起算瞬间含、终止瞬间不含**；`start >= end` 报错 | `M.dow_mon`（`count=3`：UTC/纽约各只给 2 条，因为 `2024-03-25 00:00` 那一瞬**不含**；上海/加德满达/洛德豪斯给 3 条，因为它们的"当地周一 00:00"落在 `03-24 16:00Z`/`18:15Z`/`13:00Z`，仍在窗内）；`E.start_gt_end`/`E.start_eq_end` 两条 `IllegalArgumentException\|Start date is later than end !` ⇒ 本库留变体 `BadRange(start, end)`（参照主动抛且带文案，按本仓规矩不并成空表） |
| 11 | 区名必填、瞬间进瞬间出：坏区名或落点窗外 ⇒ 无读数（`Int64?` / `Array[Int64]?`），与"窗内但没命中"（`Some([])`）**两条通道分开判** | 形状判据，来源是 `date` §5 那张表只承诺 `[1970-01-01, 2050-01-01)`：`M.*.<zone>.<none>` 是"窗内无命中"这一档（腿给 `<none>` 的格有 `count_more_than_avail` 的 Kathmandu/Lord_Howe 两格），窗外这一档参照**照样给值**（`N.year_2099.* RET 4070952000000`、`N.leap_only` 从 2098 基准给 `4233686400000`＝2104-02-29）⇒ 本库给 `None`，见 §11 第 4 条 |
| 12 | 同一瞬间在不同区下两读 ⇒ 区必须是入参，不能留"进程默认时区"这条路 | `M.daily SEC 6` 五区五组首条互不相同：UTC `1730424600000…`、上海 `1730482200000…`、纽约 `1730439000000…`、加德满达 `1730490300000…`、洛德豪斯 `1730471400000…`（同一条"当地 01:30"，差在各自的偏移）；`N.daily_0130` 同一基准（`1730548800000`）五区给 `1730597400000`/`1730568600000`/`1730615400000`/`1730576700000`/`1730561400000`。**这一条推翻第一批 §5 第 1 行"不收毫秒/时区入口"的那条理由**（原文写"本库不带 tzdb"——`date` §5 已经内置了），改写见 §11 第 6 行 |
| 13 | 重叠（回拨）档取**转换后那一支**偏移 | `N.daily_0130 0 30 1 * * * 1730548800000 America/New_York → 1730615400000`（纽约 11-03 01:30 有 EDT/EST 两支，转换前那支是 `1730611800000`，参照给的是**后**一支）；`N.daily_0230` 同基准同区 → `1730619000000`（02:30 也是后一支）。与 `date` §7 `parse_in` 的"取末支"是同一条规矩，**两个独立家族各自证一次** |
| 14 | 空洞（前跳）档那堵墙上时刻**整天跳过**，不做"往后挪一小时"的回落 | `N.daily_0230 1709985600000 America/New_York → 1710138600000`（纽约 2024-03-10 02:30 不存在，参照不给 03:30 那一瞬，而是跳到 03-11 02:30）；`N.daily_0230 515505600000 Asia/Shanghai → 515611800000`（1986-05-04 02:30 同样跳过）；同档在 UTC/无 DST 的区则正常给（`N.daily_0230 1709985600000 UTC → 1710037800000`）。机制在参照源码：`Calendar.set` 落在空洞里会滚出该墙上时刻，随后的 `match(next, true)` 读回字段不等 ⇒ 走 `nextMatch` 的"+1 天再试"那条递归 |
| 15 | `next_match_after_in` 与 `next_match_in` 在**已匹配**的输入上分岔，且回拨日分岔得更狠 | 成对读数以 `1730611800000`（纽约 11-03 01:30 **EDT**，本身匹配）为凭：`N.daily_0130 → 1730701800000`（11-04 01:30，**直接跳过当天的第二支**）、`N2.daily_0130 → 1730615400000`（11-03 01:30 **EST**，原地换到后一支）。两族必须各留一条腿，第 13 条与 §3 第 13 条靠这对读数才抓得住变异 |
| 16 | `matched_dates` 与"下一个时刻"在回拨日**不同形**：前者两支都收，后者只走一支 | `M.daily SEC 6 America/New_York → 1730439000000\\|1730525400000\\|1730611800000\\|1730615400000\\|1730701800000\\|1730788200000`（11-03 的 `1730611800000` 与 `1730615400000` 两支都在表里）对 `N.daily_0130` 同区同模式只给一支。原因在参照自己：`matchedDates` 是按步长**线性扫瞬间**，`nextDateAfter` 是**字段进位**。本库两条各自跟随自己那一族的读数，不许互相"对齐"（§11 第 3 条） |
| 17 | 45 分与 30 分偏移的区照样能算，采样栅格按**瞬间**折算而非"墙上秒为 0"；且 `match_second=false` 时秒匹配器**整个跳过**（不是"当成 0"） | `M.every_min SEC 4 Asia/Kathmandu → 1710051300000|1710054900000|1710058500000`（整点在 UTC 是 :15，因为 `+05:45`）、`M.daily SEC 6 Australia/Lord_Howe → 1730471400000…`（DST 只挪 30 分那一族，`+10:30`/`+11:00`）、`M.phase_sec30` 七区首条都是 `1710050430000`（起点带 30 秒 ⇒ 命中也带 30 秒，与区无关）；`M.sec30_min_off`：模式 `30 0 * * * *`（秒位钉死 30）在 `match_second=false` 下仍给 `06:00:00|06:01:00|06:02:00`，而在 `+05:45`/`+03:30` 两个区给 `<none>`——**同一格同时钉住"秒档被跳过"与"分钟对齐看的是墙上"**。这两条都是落地轮补的：只挂整分起点、只挂秒位为 0 的模式，K8/K3 两条变异第一轮都报 0 红（见 §12） |
| 18 | **无解的模式参照不报错，是崩**：`0 0 0 30 2 *`（2 月 30 日）解析通过，取下一时刻把 Java 栈打爆 | `N.feb30`/`N2.feb30` 五区 × 十一个基准共 55 条，落点在表内的 **50 条**全部 `ERR_java.lang.StackOverflowError\|null`（其余 5 条基准在 2098，本库在算之前就先给 `None`）。⇒ §3 第 10 条"每个合法模式都有解、`next_match_after` 是总函数"那句**说过头了**，本批收窄：夹月末只保证"日档含 31 或 `L`"那一族有解；`30 2`、`31 2`（平年）这类"日档不含月末却大于当月天数"的模式两侧都无界。不进期望值，理由见 §11 第 5 条 |

---

## 10. 第二批参照腿

| 腿 | 载体 | 读数 | 备注 |
|---|---|---|---|
| C 实测 | `scripts/Cron2Leg.java`（v5）× 真 `hutool-cron-5.8.35.jar` + `hutool-core-5.8.35.jar` + JDK 17.0.14（`lib/tzdb.dat` 101731 bytes，与 `date` §5 同代）；**每个用例前 `TimeZone.setDefault(...)` 逐个区跑**，因为这一批要测的正是"默认区改变读数"这件事 | **2614 行**：`B` 4（守卫自检）+ `T` 4（代次）+ `P` 7 + `C` 77 + `O` 10 + `K` 23 + `RT` 23 + `CB` 4 + `D3` 3 + `M` 91 + `N` 1183 + `N2` 1183 + `E` 2 | 七个区刻意取 `UTC`（零偏移基线）、`Asia/Shanghai`（1986 那次前跳）、`America/New_York`（回拨重叠）、`Asia/Kathmandu`（**+05:45** 那种 45 分偏移）、`Australia/Lord_Howe`（**DST 只挪 30 分**）、`America/Santiago`（历史上 **24:00** 跳变那一族）、`Asia/Tehran`（历史上 **00:00** 跳变那一族）——后两区专挑"候选墙上时刻本身不存在、且日历滚动会跨过午夜"这一档，只跑前五区的话「跳过一天是从哪一天起算」一次都没被测到。`M` 里另挂两格专供判据：`phase_sec30`（起点带 30 秒 ⇒ 采样栅格的相位跟着走）、`fold_hour_all_min`（重叠那一小时每分钟都命中且 `count=65` 跨过两支的分界 ⇒ 结果必须排序）|
| D 源码 | `CronPatternBuilder.java`（85）+ `CronPatternUtil.java`（113）+ `CronPattern.java`（215）+ `Part.java`（105）+ `matcher/PatternMatcher.java` 的 `nextMatchValuesAfter` | 秒/年"不设就忽略"在 `build()` 的 `StrJoiner.setNullMode(IGNORE)`；`count` 的 add-then-check 在 `matchedDates` 的循环体；`+1 秒` 在 `nextMatchAfter`；"读回字段不等就 +1 天再试"在 `nextMatch`；`Part` 构造器在 `min > max` 时对调（实测七档没有一档触发） | 报错模板只用来对号，本库不复制（§5 第 4 行） |

**守卫自检（阳性对照）**：`B.GUARD_THROW`/`B.GUARD_OVERFLOW`/`B.GUARD_SLOW`/`B.GUARD_DISTINCT` 四行证明"抛错 / 线程死掉 / 仍在跑"三档出口各有自己的串。这一条是本轮自己踩出来的：v2 只 `catch (Exception)`，`feb30` 那 21 条被 `StackOverflowError`（`Error` 不是 `Exception`）打死的线程没设结果，腿把它们**报成了 `ERR_Timeout`**——判据本身坏过一次，就在这里钉住，别让下一个读者再信一次"超时就等于还在跑"。同轮的另一个教训：`GUARD_MS` 从 4 s 放到 20 s，因为 `M.leap_feb`（SEC 档跨一年 ≈ 3.2×10^7 次匹配）是真在算而不是挂住，4 s 会把一条合法读数误记成无读数。

**算法注（PR-B 的验收对象，读数面由 `M`/`N`/`N2` 钉）**：本库 `matched_dates` **不逐秒线性步进**。参照那一档跨年会跑三千万次（腿里那一格实测要几秒），wasm 档不可接受。形状改成：用第一批已冻的字段进位引擎取**候选墙上时刻**，把每个候选墙上时刻按内置表展开成 0/1/2 支瞬间（空洞 0 支自然跳过、重叠 2 支都收），再按 `(瞬间 − start) mod 步长 == 0` 折回参照的采样栅格、排序去重、截到 `count`。三条判据分别钉住这件事：第 17 条（栅格折在瞬间上不折在墙上秒）、第 14 条（0 支 ⇒ 不回落）、第 16 条（2 支 ⇒ 都收）。这条注里唯一"参照没有"的东西是**速度**，不是语义。

---

## 11. 第二批分岔与不跟随（逐条给两侧读数）

| # | 分岔 | 参照 | 本库 | 依据 |
|---|---|---|---|---|
| 1 | 只设年不设秒 | `build()` 给 `* * * * * 2030`，喂回 `new CronPattern(…)` 报 `DAY_OF_WEEK value 2030 out of range: [0 , 6]` | 秒补 `*` ⇒ `* * * * * * 2030`（7 段式，解析通过） | `K.year_only_no_second` 与 `RT.year_only_no_second` 两条读数都在案。参照在这格自相矛盾（自家的建造器产出自家的解析器收不了的串），按 §5 第 5 行同一条规矩取"可推导"那一侧；只动坏的那一格，第 5 条"不设就省略"在其余格照留 |
| 2 | `count <= 0` | `count=0` 给 1 条（add-then-check）；`count=-1` 抛 `IllegalArgumentException: Illegal Capacity: -1` | 一律 `Some([])` | `CB.count` 四条。参照同一件的两个读数互相矛盾，且负数那抛的是 Java 容器内部件；"要 0 条就给 0 条"是可推导那一侧 |
| 3 | 回拨日的两支 | `matchedDates` 两支都给（线性扫瞬间）、`nextDateAfter`/`nextMatch` 只给一支（字段进位） | 两条各自跟随：`cron_matched_dates` 两支都收，两个 `*_in` 只给转换后那一支 | 第 16 条 + 第 13 条。这里**不许**"顺手统一"——统一成哪一侧都会让另一侧的 605 条读数作废，而两侧都是参照的真读数 |
| 4 | 落点出表窗（`[1970, 2050)` 之外） | 照给：`N.year_2099 RET 4070952000000`、`N.leap_only`（2098 基准）`RET 4233686400000`＝2104-02-29 | `None`（基准出窗、或搜索途中出窗，都不猜未来） | `date` §5 那张表的承诺窗口就是 `[1970-01-01, 2050-01-01)`；同一条判据在 `date` §7 `format_in`/`parse_in` 已经冻过 |
| 5 | 无解模式（`0 0 0 30 2 *`） | `StackOverflowError`（50 条读数） | **同样不承诺返回**，且这一档**不进期望值** | 本库跟随参照的引擎，无界递推会把 wasm 侧一并挂住；把一条"会挂住的用例"塞进测试等于把整套件判死，抓不到任何东西。要界请调用方自带 deadline（本库不发明"最多试 N 天"那种参照没有的常数）。第一批 §3 第 10 条那句"每个合法模式都有解"本批就地收窄 |
| 6 | 时区入口（**改写第一批 §5 第 1 行**） | 有 `match(long millis, …)`/`match(TimeZone, …)`，默认档吃 `TimeZone.getDefault()` | 两档都收：无区名的 `@date.DateTime` 档（第一批已冻，一字不动）+ 带区名的瞬间档（本批 #19.17~#19.19） | 原文那条理由是"本库全同步且**不带 tzdb**"——`date` §5 已内置 603 区 36701 段的表，前提没了；第 12 条的五区五读数就是"默认区这条路必须堵掉"的机器证据 |
| 7 | `CronError` 加变体 | 参照抛 `IllegalArgumentException`（`Assert.isTrue`） | 新增 `BadRange(Int64, Int64)`（additive） | `E.*` 两条。异常种类收进本包错误面这条规矩同 §5 第 3 行；带两个整数而不是抄文案，同 §5 第 4 行 |
| 8 | `Part` 的 `getCalendarField`/`of(int)`/`describe`/4 参 `matchedDates`/3 参 `nextDateAfter` | 有（`describe` 例外：5.8.35 没有） | 不收 | 逐条理由在 §8 那张"不收"表 |

---

## 12. 第二批状态与落地轮记录

两笔齐（`8d36458` PR-A 冻结 → 本笔 PR-B 落地）。落地读数：**599 块 = 绿 599 / 红 0**，wasm / js / wasm-gc 三档一致、零警告；本批 21 块 **2428 条断言**全部由 `scripts/gen_cron2_test.py` 从腿 C 的 2614 行读数灌入（手打零条）。

### 12.1 变异对照（18 条，tar 副本里逐条实跑；工装开局先跑基线 29/29 绿，收尾按字节还原后再跑一次基线）

| # | 变异 | 结果 |
|---|---|---|
| K1 | 重叠档取第一支（`offs[len-1]`→`offs[0]`） | **抓到** 绿 25/红 4（N 与 N2 两族同时塌） |
| K2 | `matched_dates` 只收第一支 | **抓到** 28/1（`M.daily` 纽约那格） |
| K3 | 采样栅格不折算（直接用候选瞬间） | **抓到** 28/1（补夹具之后；第一轮 0 红，见 12.2④） |
| K4 | 结果不排序（尾插） | **抓到** 28/1（`M.fold_hour_all_min` 那格，第一轮同样 0 红） |
| K5 | 去掉"窗外先于空洞档"那一刀 | **不收敛**：150 s 墙钟超时——不是"没抓到"，是**抓到就把件挂住**，这条顺序因此是总函数承诺的承重件 |
| K6 | 已匹配不先 +1 秒 | **抓到** 25/4 |
| K7 | `count<=0` 给一条（参照 add-then-check 的形状） | **抓到** 27/2（CB 两格 + `M.count_zero` 七区） |
| K8 | 秒不参与匹配时仍保留秒匹配器 | **抓到** 28/1（补 `M.sec30_min_off` 之后；第一轮 0 红，见 12.2④） |
| K9 | 步进单位与 `match_second` 配反 | **抓到** 28/1 |
| K10 | 补默认补到年档 | **抓到** 28/1（`K.space_year`） |
| K11 | 补默认从秒档补起 | **抓到** 28/1（`K.empty`） |
| K12 | 去掉"设年未设秒 ⇒ 补秒"这一条改判 | **抓到** 28/1（`K.year_only_no_second` 与 `RT.*` 配对） |
| K13 | 空白的秒/年也当未设置跳过 | **抓到** 28/1（`K.blank_second` 的行首空格） |
| K14 | 空数组写成"未设置" | **抓到** 28/1（补 `K.values_empty_second`/`K.values_empty_year` 之后；第一轮 0 红——`K.values_empty` 那格在分档上与"未设置"同形，看不出差别，见 12.2④） |
| K15 | `set` 丢文本改存 `"0"` | **抓到** 28/1（`K.junk_minute`、`K.dow_seven`） |
| K16 | `checkValue` 不报错 | **抓到** 27/2（C 行 42 条 ERR 全塌） |
| K17 | `DAY_OF_WEEK` 的界放宽到 7 | **抓到** 27/2（P 行 + `C|DAY_OF_WEEK|7|ERR`） |
| K18 | `setRange` 端序写反 | **抓到** 28/1（`K.range_reversed`） |

18 条里 17 条抓红、1 条（K5）不收敛，**没有一条按等价记账**。但其中四条（K3/K4/K8/K14）第一轮报 0 红，全部按**夹具缺口**处理而不是按等价放行：补腿 → 重新灌期望 → 复挂成红（缺的那五格见 12.2④）。唯一没单挂的结构性重复是 `matched_dates` 里"读回字段仍匹配"那一判——它与 `cron_match` 同源，`M`/`N` 两族已经钉住，为它造一条变异只会得到按构造等价。

### 12.2 落地轮抓到的五处契约/夹具缺陷

1. **窗外与空洞档同形**：`zone_offsets_at_wall` 对这两种都给 0 支。PR-A 只写了"空洞档整天跳过"，没写"窗外要先判"，于是 `0 0 12 * * ? 2099`（基准在 2024、落点在 2099）一跑就无限递推，测试挂住 10 分钟才定位。现在那一刀排在空洞判定之前，判据写进 §10 算法注，K5 把它钉住。
2. **生成器把 Int64 字面量后缀 `L` 拼进了期望串**（`md_tag` 给的是裸十进制）：纯渲染错，数字一位不差，改的是脚本不是期望。
3. **生成器只按基准判窗外，没按落点判**：`year_2099` 那一族 168 格的期望从"照抄参照读数"改成 §11 第 4 行本就叫得出的 `None`。判据是 PR-A 写死的（"搜索途中落入窗外 ⇒ `None`"），不是照着实现补的；参照原读数（`4070952000000` 等）全部留在注释里。
4. **四条 0 红变异对应的五格夹具缺口**：`M.phase_sec30`（起点带 30 秒 ⇒ 采样相位）、`M.fold_hour_all_min`（重叠小时每分钟都命中且 `count=65` 跨过两支分界 ⇒ 结果必须排序）、`M.sec30_min_off`（6 段式 + 秒位非 0 + `match_second=false` ⇒ 秒匹配器确实被跳过）、`K.values_empty_second` 与 `K.values_empty_year`（空数组给的是空串不是"未设置"，只在秒/年档上看得见）。补完后腿从 1407 行长到 2614 行，四条变异全部复挂成红；顺带把 §9 第 6 条与第 17 条的措辞按新读数改了。
5. **`K.null_minute` 不进夹具**：参照的 `set(part, null)` 在本库类型上没有对应格——未设置就是 `None`，没有第二种形状。读数 `K.null_minute RET * * * * *` 留在测试文件的注释里备查。

另外两处"判据自己坏过"的账（§10 已各留一条，不再重复）：腿的守卫只 `catch (Exception)`，把 `StackOverflowError` 打死的线程误报成 `ERR_Timeout`（21 条 feb30 读数一度是错的，现在 `B` 行四格自检三档出口互不相同）；`cron_test.mbt` 里一条 7 段式阳性断言被上一条的行注释整个吞掉、从未跑过，本批把它搬回自己的行（期望文本本来就是腿 `ok.41` 的原读数）。

**剩下的都不是格子的事**：`describe` 参照没有（§8"不收"表）；`feb30` 那一族 168 格故意不进夹具（§11 第 5 行）；第一批"每个合法模式都有解"那句已在 §11 第 5 行收窄。


## 13. 深分支补档第三批（10-07，`cron_deep_test.mbt`）

参照腿 `Cron3Leg.java`（hutool-all 5.8.37 · JDK 17 · 每条先 `TimeZone.setDefault(区)`，ISO 一律按 UTC 打）出 18 对夹具 × 两个入口（`CronPatternUtil.nextDateAfter(CronPattern, Date)` 与 `CronPattern.nextMatch(Calendar)`）＝ 36 条断言，**零分岔**、手打零条。普查按"一条断言一块"跑，先断 `Total tests >= 29 + 36` 才给结论。

钉住的三族分支（此前一条用例都没走到）：

| 族 | 夹具 | 参照读数（本库同判） |
|---|---|---|
| 别名解析 | `0 0 1 feb *` / `0 0 1 april *` / `0 0 1 january ?` / `0 0 12 * tue` / `0 0 12 * SAT-SUN` | 月名与周名两条查表支路各命中一次（`2024-02-01T00:00`、`2024-04-01`、`2025-01-01`、`2024-11-12`、`2024-10-12`） |
| 月末夹取 | `0 0 12 31 2 ?`（→ `2024-02-29T12:00`）、`0 0 12 31 4 *`（→ `2024-04-30T12:00`）、`0 0 29 2 *`（→ `2024-02-29`） | 夹到月末与闰年支路各一次 |
| 进位 | `0 0 1 1 * ?` 从 2020-06-15 起 → `2020-07-01T01:00` | 月进位 + `nextDateAfter` 与 `nextMatch` 同值（本批两入口没分形；回拨日那族仍按 §11 的"两侧各跟随"） |
| 错误通道 | `0 61 * * *`、`0 0 32 * *`、`0 0 1 13 *`、`0/0 * * * *`、`61 * * * * *`、`0 0 15L * ?`、`0 0 1 ? * 5L`、`0 0 1 1 ? 20x4`、`0 0 1 1 ? 2100` | 参照一律 `CronException` ⇒ 本库**只钉"必抛"**（`deep_tag_of` 返回 `RAISE`），档名不钉——档名要来自 §5 的已冻映射，腿给不了 |

两条口径写在这里免得下一轮重议：① **错误档名不由这条腿授权**——参照只报一个 `CronException`，本库分五档，映射表在 §5，所以本批断言只问抛不抛；② `nextDateAfter` 与 `nextMatch` 在这 18 对上同值，但**这不推翻** §11 那条"回拨日两支不同形"——那需要带区名夹具，本批把 `z-*` 三条留在腿里没进断言（UTC 组先收干净），带区的分形另笔按 `*_in` 补。
