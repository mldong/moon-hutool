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
| 2 | 5 段 = 分/时/日/月/周；6 段第一位是**秒**、7 段最后一位是**年**；**秒位默认不参与匹配**，只有 `match_second=true` 才参与；**第 7 段既不解析也不匹配**（`YearValueMatcher` 在 5/6/7 段的默认路径里拿不到年份判据） | `m.32.9` 对 `ms.32.9`（`59 59 12 * * *` 在 `09:15:30`/`12:59:00` 类时刻上两档不同值）、`ok.33\|OK:0 0 12 * * ? 2099` + `nx.33.*`（2099 之后照给 ⇒ 年份段没参与） |
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
| 15 | `cron_pattern_text` 返回**原样**表达式（不去空白、不规范化） | `ok.N\|OK:<原表达式>` 全部 66 条（`ok.43\|OK:   ` 三个空格原样回来） |

---

## 4. 参照腿

| 腿 | 载体 | 读数 | 备注 |
|---|---|---|---|
| A 实测 | 真 `hutool-cron-5.8.35.jar` + `hutool-core-5.8.35.jar`（`CronPattern` 依赖 core 的 `StrUtil`/`NumberUtil`/`CollUtil`）+ 本机 JDK 17.0.14，`javac -encoding UTF-8`；全程 `TimeZone("UTC")` | **1386 行**（`cron_ref.txt`）：66 个表达式的 `ok.N`（含 8 条报错消息原文）× 12 个时刻的 `m.N.K`/`ms.N.K` × 6 个基准的 `nx.N.B`/`nm.N.B` | 表达式清单刻意覆盖：`*`、`?`、`,`、`-`（含反向）、`/`（含 `*/0`）、别名大小写、`L`/`LW`/`15L`、`5L`/`6L`/`FRI#2`、`0`/`7` 周日、日与周同限定、6 段与 7 段、`2/29` 闰年、`4/31` 夹月末、空串与纯空白、4 段与 7 段 |
| B 源码 | `CronPattern.java`（215 行）+ `Part.java`（105）+ `parser/PartParser.java`（284）+ `matcher/PatternMatcher.java` 关键路径 | 段数校验在 `PatternParser`、`/ > - > ,` 优先级在 `parseStep`/`parseRange`、`+1 秒` 在 `nextMatchAfter`（注释点了 issue#I9FQUA）、`日/周` 的且关系在 `PatternMatcher.match` | 报错消息模板只用来**对号**，本库不复制模板（§5 第 4 行） |

期望值全部由脚本从腿 A 灌入，**手打零条**；`m/ms/nx/nm` 四类标签在每条断言的注释里逐一回指。

---

## 5. 分岔与不跟随（逐条给两侧读数）

| # | 分岔 | 参照 | 本库 | 依据 |
|---|---|---|---|---|
| 1 | 时区 | `match(long millis, …)` 与 `match(TimeZone, …)` 存在且默认档走 `TimeZone.getDefault()` | 只收 `@date.DateTime`（本地时刻 + 显式偏移），无毫秒/时区入口 | 同输入两机两读；本库全同步且不带 tzdb（`date` 包同一口径） |
| 2 | 空表达式 | 解析通过、`match` 恒 false、`nextMatchAfter` 抛 NPE（`CollUtil.min` 返回 null） | 解析期 `raise BadParts("")` | `ok.42`/`nx.42.0` 两条读数为凭；"能构造但一用就 NPE"不算可观测语义 |
| 3 | 星期侧的 `L`/`#` | `IllegalArgumentException: No enum constant …Week.5L`（枚举查找漏到外面，且**不是** `CronException`） | `raise BadAlias("5L")`——异常种类收进本包错误面 | 消息原文照留在 `ok.14`/`ok.15`/`ok.16`；跟随一个 `IllegalArgumentException` 等于把 Java 枚举机制漏给调用方 |
| 4 | 报错消息 | `"{} value {} out of range: [{} , {}]"` 等模板 | 错误变体带**档名 + offending 文本/值**，不复制模板 | 消息文案随 hutool 版本变；契约要钉的是"哪一档、哪一段、哪个值" |
| 5 | `-1 * * * *` | 接受并参与匹配（`length()<=2` 分支绕过 `checkValue`） | `raise OutOfRange("MINUTE", -1)` | 第 7 条两侧读数；与 `60 * * * *` 报错这条同族规则相矛盾，取"可推导"的一侧 |
| 6 | 第 7 段年份 | 接受解析但**不做匹配**（`Part.YEAR` 区间 1970~2099 只在被解析时用） | 跟随：接受、不匹配（保持 `nx.*` 读数可复现） | 第 2 条 + 第 14 条读数 |
| 7 | `describe`/`CronPatternBuilder`/`nextMany` | 有 | 第二批 | 第 1 节 |
| 8 | 调度族 | 有（含时间轮） | **整族不做** | 第 1 节"只算不调度" |

---

## 6. 变异对照（落地轮必须逐条跑，先在此挂账）

| 变异 | 预期抓到它的读数 |
|---|---|
| `日` 与 `周` 的"且"改成"或" | 第 11 条：`m.19.*` 全表 + `nx.19.*` |
| `next_match_after` 去掉"已匹配先 +1 秒" | 第 13 条成对读数 `nx.11.0` 对 `nm.11.0` |
| 别名大小写改成敏感 | 第 8 条 `m.9.*` 对 `m.10.*` 逐条同值 |
| `?` 不按全匹配处理 | 第 4 条 `m.6.*` 对 `m.0.*` |
| 步进优先级改成 `, > - > /`（`2,3,6/3` 当成 `(2,3,6)/3`） | 第 3 条 `m.5.*` |
| 月末夹取去掉（31 日在 4 月直接不可达） | 第 10 条 `nx.49.*` 三条 |
| 周日 `7` 归一化漏掉（只认 0） | 第 8 条 `m.17.*` 对 `m.18.*` |
| 段数判定改成"≥5 即放行"（8 段也收） | `ok.41`/`ok.40` 两侧（7 段收、4 段拒）+ `BadParts` 档 |
| 反向区间改成报错 | 第 12 条 `ok.30`/`ok.31` + `m.30.*`/`m.31.*` |
| 毫秒清零漏掉 | `nx.*` 全部读数的秒/毫秒位（腿侧毫秒恒 0，本库出口同样必须 0） |

---

## 7. 状态

`docs/ROADMAP.md` 第 19 行的状态与本节同步（`scripts/sync_status.py --write` 生成，勿手改）：
本批用例在契约冻结相位**预期全红**——函数体是 `abort`。
