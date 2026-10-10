# 契约 03 · date（日期时间）

> 状态：**前五批都已收口，第六批契约已冻结**（首批 10-05；第二批内置时区表、第三批可注入时钟源、第四批命名时区版 format/parse 各两笔，10-06 完成；第五批默认区与无参便捷入口两笔，10-07 完成；
> 第六批＝§9 计时三件 + 全局自定义格式表，10-10 契约笔——`date/timer.mbt`/`date/between.mbt`/`date/custom_format.mbt`
> 的函数体是 `abort`，本批用例此刻红是设计态，实现笔只许把红变绿）。
> 首批实现在 `date/date.mbt`，公开接口在 `date/pkg.generated.mbti`（契约先行到落地 **`.mbti` 零漂移**——
> 公开签名一字未动），首批期望值在 `date/date_test.mbt` 与 `date/README.mbt.md`：47 条读数在
> wasm / js / wasm-gc 三档一致，native 档由 CI 出证。第二批的数据与期望在 `date/zone_table.mbt` 与
> `date/zone_test.mbt`，两件都是生成件（`scripts/gen_zone_table.py`）。
> 改任何期望串须单独一笔并给出外部读数来源（门禁 G5）；首批落地那一笔**期望串一字未改**，
> 改掉的是一处实现算错（两位年窗口 `70..99` 那档）。
>
> core **没有任何时间能力**：没有 `time`/`date`/`calendar` 包，全树 `grep ZonedDateTime|Instant|calendar|weekday|leap_year`
> 在非测试代码命中 0（**任何人都能自己复跑**：`moon --version` 末行打出工具链目录，对它下面的 `lib/core` 跑
> `grep -rniE "timezone|utc_offset|localtime" --include=*.mbt .`，排除测试文件后就是 0）。能借的只有 `env.now()`（epoch 毫秒）。
> ⇒ 本包整包自研，也是本库最大的一处"从无到有"。
>
> **本包没有 core 对拍腿**（门禁 G8 那条腿在这里天然为空）：没有可对照的 core 函数。唯一的 core 接触点是
> `now_millis()` 里的 `env.now()`，它返回 `UInt64`、且 js/wasm 档语义由宿主给，不能拿来做期望值——
> 所以本包的用例一律吃显式注入的值，只有 #2.10 那一格碰墙上时钟（做法见该节）。

## 0. 四条贯穿性规则（先定死，再谈逐个函数）

| # | 规则 | 为什么必须这么定 |
|---|---|---|
| 0.1 | **偏移一律显式**：`DateTime` 是墙上时钟，不带偏移；"瞬间 ↔ 墙上时钟"的换算显式吃 `offset_minutes`，新增的命名时区入口则显式吃**区名** | hutool/JDK 靠进程默认时区（`TimeZone.getDefault()`）。那是个隐式全局量：同一份代码在两台机器上给出不同的 `begin_of_day`。本库零依赖，索性把"在哪算"做成必填参数。<br>**10-06 第二批就地更正**：这一行后半句原先写的"不做命名时区、也因此没有 DST 歧义"**已被 §5 推翻**——本库现在自带一张 IANA 段表，命名时区与 DST 都收，而 `zone_offsets_at_wall` 的 0 / 1 / 2 三档正是"墙上时刻可以对应多个瞬间"的正面承认。"不跟随进程默认时区"这一半没变，变的是一整块能力从"不做"挪到"做了"。（当时那句是按"零依赖就装不下 tzdb"推的，现读发现参照代次自己就是完整的 tzdb，展开成段存下来并不需要 FFI）<br>**10-07 第五批就地补一句**：本包现在有了**默认区这一层**（§8）——`TZ` 环境变量优先、否则取兜底常量，且 `default_zone_source()` 能查出这一次到底来自哪一级。这与本行不冲突：§2/§5/§7 那些件的签名一字未动，新增的只是"不必每次传"的一组便捷入口，而"隐式全局量查不到来源"这一半被改成了"查得到来源、且可显式覆盖"。理由见 §8.1 的 owner 裁定。 |
| 0.2 | **proleptic Gregorian + 天文纪年**：1582-10-15 之前照公历规则往前推，且存在公元 0 年（= 公元前 1 年） | JDK `GregorianCalendar` 默认有 1582-10-15 切换点（之前按儒略历），同一个 `epoch_days` 会算出不同日期；切换点前后的历史日期对工具库没有价值，规则一致才有可复现的期望值 |
| 0.3 | **向下取整**：epoch 相关的除法/取模一律向下取整（floor） | 本版编译器的 `/` 与 `%` 对负数**向零截断**（本机实测 `-5 % 100 = -5`、`-1000L / 86400000L = 0`）。不自己造 floor 档，`-1L` 毫秒就会算成 1970-01-01T-00:00:00 这一类坏读数。用例 #2.5 与 #2.6 各钉一档 |
| 0.4 | **pattern 是封闭子集**：表外字母显式 `raise`，不当字面量吞掉 | hutool `FastDateFormat`（真上游 Apache Commons Lang3）未识别的字母按其规则原样输出，拼错 `EEEE` 会静默变成字面量 `EEEE` 出现在报表里。本库宁可让它在第一次调用就炸 |

## 1. 类型与错误面

| 签名 | 语义 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 | 血统 |
|---|---|---|---|---|---|---|
| `pub struct Date { year : Int, month : Int, day : Int }` | 公历日期，不含时间、不含时区 | 非法日期**构造不出来**：只有 `of`/`from_epoch_days`/`parse` 三个入口 | `cn.hutool.core.date.DateUtil` 的 `DateTime`（本质是 `java.util.Date`） | Java 的 `Date` 是"瞬间"，本库的 `Date` 是"日历日"；瞬间由 `Int64` epoch 毫秒表示 | proleptic Gregorian | — |
| `pub struct DateTime { date : Date, hour : Int, minute : Int, second : Int, milli : Int }` | 某偏移下的墙上时刻 | 字段由 `of` 校验范围；跨包**只读不可构造**（编译器判 read-only type） | hutool `DateUtil`/`CalendarUtil` 的返回体 | 不带偏移、最细到**毫秒**（core 的 `env.now()` 就是毫秒档，没有微秒/纳秒） | — | — |
| `pub(all) enum TimeUnit { Millisecond Second Minute Hour Day Week }` | 固定长度单位 | **刻意没有 `Month`/`Year`** | hutool `DateUnit`（`MS/S/MINUTE/HOUR/DAY/WEEK`） | hutool 的 `DateUnit` 也只有固定长度档，一致；月/年走 `offset_month`/`offset_year` | — | — |
| `pub suberror DateError { MonthOutOfRange(Int) DayOutOfRange(Int,Int,Int) TimeFieldOutOfRange(Int,Int,Int,Int) UnknownPatternToken(String) ParseFailed(String,Int) FutureBirth }` | 本包唯一错误面 | 只携带**读数**，不携带文案 | hutool `DateException`（一个包打天下的运行时异常） | 本库不内置错误文案：文案是 API 表面，冻结它会让"改个措辞"撞上期望值冻结红线；调用方自己决定怎么写 | — | — |
| `derive(Eq, Compare)` + `date/extends.mbt` 里的 `pub extend ... with Eq::{...}` | `d1 == d2`、`d1 < d2` 的手感 | — | Java 的 `compareTo` | 本版编译器对 `derive` 会报 `implicit_impl_as_method` 警告（隐式提升即将废弃），必须写显式 `extend` 才能守住零警告门禁——形状抄 `moonbitlang/core/argparse/extends.mbt` | 本机编译器裁决 | core 同款姿势 |

## 2. 契约表

表格里的"读数"都是 `date_test.mbt` / `README.mbt.md` 已冻结的期望值，来源列说明它是怎么算出来的。

### 2.1 日历原语

| 签名 | 读数（抽样） | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `is_leap_year(year : Int) -> Bool` | 1900→false、2000→true、2100→false、2400→true、2024→true、4→true、100→false、1→false、0→true、-4→true、-100→false | 全域 `Int` | `CalendarUtil.isLeapYear` | 负年份按天文纪年做数学整除，不套"公元前无闰年"的历史口径（那是尤利乌斯历之前的罗马事） | 格里高历规则；正年份与 Python `calendar.isleap` 逐条核对 |
| `days_in_month(year : Int, month : Int) -> Int raise DateError` | (2024,2)→29、(2023,2)→28、(1900,2)→28、(2000,2)→29、(2026,4)→30 | `month` 不在 1..12 ⇒ `MonthOutOfRange(m)`（原样携带，不夹紧、不取绝对值） | `CalendarUtil.getDayOfMonth` | JDK 会静默把 13 月折成次年 1 月；本库报错 | 同上 |
| `Date::of(year : Int, month : Int, day : Int) -> Date raise DateError` | `of(2024,2,29)` 成功；`of(2026,2,30)`→`DayOutOfRange(2026,2,30)`；`of(2023,2,29)`→同形；`of(2026,4,31)`→同形；`of(2026,1,0)`→`DayOutOfRange(2026,1,0)` | 唯一带校验的构造入口 | `DateUtil.parseDate` 之前的隐式构造 | **不 lenient**：非法值不滚成下个月某天（JDK `Calendar` 默认 lenient 会滚） | proleptic Gregorian |
| `Date::epoch_days(self) -> Int64` | 1970-01-01→0L、1970-01-02→1L、1969-12-31→-1L、2000-03-01→11017L、2026-10-04→20730L、1582-10-15→-141427L、0001-01-01→-719162L、9999-12-31→2932896L、2024-02-29→19782L、-0045-01-01→-735964L | 全域 | `DateUtil` 内部 | — | Howard Hinnant `days_from_civil`；与 Python `datetime` 在 1..9999 逐日抽样核对 **870 组**后冻结。-45 这一档另用手算复核：1970→-45 跨 46 年、其中 12 个闰年 ⇒ 16802 天 |
| `Date::from_epoch_days(days : Int64) -> Date` | 0L→1970-01-01、-1L→1969-12-31、11017L→2000-03-01、-719162L→0001-01-01、2932896L→9999-12-31、3000000L→10183-09-21、-3000000L→-6244-04-12 | 全域 `Int64` | 同上 | — | Howard Hinnant `civil_from_days`；同一批 870 组核对 |

**血统**：格里高历规则本身；换算算法是 Howard Hinnant 的 `days_from_civil`/`civil_from_days`（公开算法，无代码来源问题）。hutool 这一层完全靠 JDK `Calendar`/`GregorianCalendar`，本库不搬它的实现。


### 2.2 日历派生量

| 签名 | 读数（抽样） | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `Date::day_of_week(self) -> Int` | 1970-01-01→4、2026-10-04→7、2026-10-05→1、2024-02-29→4、0001-01-01→1、-0045-01-01→6 | 恒返 1..7 | `DateUtil.dayOfWeek` 返回 `Calendar.DAY_OF_WEEK`（**周日=1**） | 本库取 ISO 8601：**周一=1 … 周日=7**。选 ISO 是因为它与 `week_of_year`、`begin_of_week` 同一套口径，且不需要 `Locale` | `(epoch_days + 3) mod 7 + 1`，mod 取**向下**；与 Python `date.isocalendar()[2]` 逐条核对 |
| `Date::is_weekend(self) -> Bool` | 2026-10-03/04→true、2026-10-05→false、1970-01-03/04→true | — | `DateUtil.isWeekend` | 只判周六/周日，**不含调休与法定节假日**（那是逐年数据表，见 `docs/ROADMAP.md`「暂不做」） | 同 `day_of_week` |
| `Date::day_of_year(self) -> Int` | 2024-01-01→1、2024-03-01→61、2023-03-01→60、2024-12-31→366、2023-12-31→365、2026-10-04→277 | 恒返 1..366 | `DateUtil.dayOfYear` | — | `epoch_days - epoch_days(该年-01-01) + 1`；与 Python `timetuple().tm_yday` 核对 |
| `Date::quarter(self) -> Int` | 1/3 月→1、4/6 月→2、7/9 月→3、10/12 月→4 | 恒返 1..4 | `DateUtil.quarter`（JDK `Calendar` 无此概念，hutool 自算） | 一致：按自然季度，不是财务季度（要别的划分请用 `(month-1)/3+1` 自行推导） | `(month-1)/3+1` |
| `Date::week_of_year(self) -> Int` + `Date::week_based_year(self) -> Int` | 2021-01-01→(53, 2020)、2021-01-03→53、2021-01-04→(1, 2021)、2020-12-31→53、2019-12-30→(1, 2020)、2026-01-01→1、2026-12-31→(53, 2026)、2024-12-30→(1, 2025) | 恒返 1..53 / 年份 | `DateUtil.weekOfYear`（走 `Calendar.WEEK_OF_YEAR`） | hutool 那套随 `Locale` 与 `firstDayOfWeek`/`minimalDays` 变，同一日期在不同机器上不同读数 ⇒ 不可复现。本库固定 ISO 8601：周一为周首、含该年第一个周四的那周是第 1 周。**两个函数必须配对读**，否则 2021-01-01 会被读成"2021 年第 53 周" | ISO 8601；与 Python `isocalendar()` 核对（2026-12-31 是周四 ⇒ 该年确有第 53 周） |

**血统**：星期/周序号/周基准年取 **ISO 8601**（规范文本是权威，不是 hutool——hutool 那套走 `Calendar`，读数随 `Locale` 变）。


### 2.3 区间端点（`begin_of_*` / `end_of_*`）

`Date` 侧返回 `Date`，`DateTime` 侧返回 `DateTime`；`end_of_*` 的时刻档一律 `23:59:59.999`。

| 签名（`Date::` 与 `DateTime::` 同名成对） | 读数（夹具 2026-10-04，周日；另一夹具 2024-02-15） | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `begin_of_day` / `end_of_day`（仅 `DateTime`） | 12:34:56.789 → `2026-10-04T00:00:00.000` / `2026-10-04T23:59:59.999` | — | `DateUtil.beginOfDay/endOfDay` | hutool `endOfDay` 也是 `.999` 档；本库更细没有档（core 时钟就是毫秒） | 定义即契约 |
| `begin_of_week` | 2026-10-04→2026-09-28、2026-10-05→2026-10-05（自身即周一）、2026-10-03→2026-09-28、2024-02-15→2024-02-12、2026-01-01→2025-12-29、2026-12-31→2026-12-28 | 结果可能跨年 | `DateUtil.beginOfWeek(isMonDay=true)` | hutool 有"周日/周一为周首"两个档；本库只有周一档（与 `day_of_week`/ISO 周同一口径）。要周日开头的报表请自己 `-1 天` | `epoch_days - (day_of_week-1)` |
| `begin_of_month` / `end_of_month` | 2026-10 → 10-01 / 10-31；2024-02 → 02-01 / **02-29**；2023-02 → 02-01 / 02-28；2026-12-31 → 12-01 / 12-31 | — | `DateUtil.beginOfMonth/endOfMonth` | hutool 的 `endOfMonth` 是"最后一日的 00:00:00"再补时刻，读数与本库一致（`DateTime` 侧 `.999`） | 该月天数由 `days_in_month` 给 |
| `begin_of_quarter` / `end_of_quarter` | 2026-10 → 10-01 / 12-31；2024-02 → 01-01 / 03-31 | — | `DateUtil.beginOfQuarter/endOfQuarter` | — | 季度首月 = `(quarter-1)*3+1`，末月取其月末 |
| `begin_of_year` / `end_of_year` | 2026 → 01-01 / 12-31 | — | `DateUtil.beginOfYear/endOfYear` | — | — |

**血统**：hutool `DateUtil.beginOf*`/`endOf*` 家族的语义档（内部是 JDK `Calendar` 字段操作）；本库重写实现，并把"周首"固定成 ISO 的周一。


### 2.4 加减与日差

| 签名 | 读数（抽样） | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `Date::offset_day(days : Int) -> Date` | 2024-02-28 +1→2024-02-29；2023-02-28 +1→2023-03-01；2024-12-31 +1→2025-01-01；2025-01-01 −366→2024-01-01；+0→自身；1970-01-01 −1→1969-12-31；2000-03-01 −60→2000-01-01 | — | `DateUtil.offsetDay` | — | `epoch_days ± n` 再反算 |
| `Date::offset_month(months : Int) -> Date` | 2024-01-31 +1→**2024-02-29**；2023-01-31 +1→**2023-02-28**；2024-03-31 −1→2024-02-29；2024-01-30 +1→2024-02-29；2025-01-31 +13→2026-02-28；2024-05-31 +1→2024-06-30；2026-10-04 +12→2027-10-04；+0→自身；2024-02-29 −1→2024-01-29；2026-03-31 −1→2026-02-28 | 目标月没有该日 ⇒ **夹紧到月末** | `DateUtil.offsetMonth` | 与 JDK `Calendar.add(MONTH)` 同档（夹紧），**不是**"滚到下个月某天"（那是 `SimpleDateFormat` lenient 那一路）。这条被业务反复踩，所以逐个方向各钉一条 | 目标年月由 floor 除法/取模给（负数月也要落在正确年份） |
| `Date::offset_year(years : Int) -> Date` | 2024-02-29 +1→2025-02-28；+4→2028-02-29；2023-02-28 +1→2024-02-28（**不动日**）；2026-10-04 −1→2025-10-04；2000-02-29 +4→2004-02-29 | 同上（夹紧） | `DateUtil.offsetYear`（= `offsetMonth(12n)`） | — | 同上 |
| `Date::between_day(other : Date) -> Int` | 2024-01-01→2024-03-01 = 60；反向 = −60；同日 = 0；1969-12-31→1970-01-01 = 1；2000-02-28→2000-03-01 = 2 | 有符号，`other − self` | `DateUtil.betweenDay(begin,end,isResetTime)` 返**绝对值** | 本库保留符号（无符号差值可由 `between`/`difference` 那条给）；hutool 的 `isResetTime` 档在 `DateTime` 侧由 `between` 承担 | 两个 `epoch_days` 相减 |

**血统**：月/年加减的夹紧档来自 JDK `Calendar.add(MONTH)` 语义（hutool `offsetMonth` 即其门面）；本库重写实现，不搬代码。


### 2.5 瞬间、墙上时钟与时刻算术

| 签名 | 读数（抽样） | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `DateTime::of(date, hour, minute, second, milli) -> DateTime raise DateError` | 越界读数：`(…,24,0,0,0)`→`TimeFieldOutOfRange(24,0,0,0)`；`12:60:0.0`、`12:0:60.0`、`12:0:0.1000` 各一条 | hour 0..23、minute/second 0..59、milli 0..999 | hutool 无对应（直接 `new Date(...)`） | 字段范围硬校验，不 mod 不进位 | 定义即契约 |
| `DateTime::from_epoch_millis(millis : Int64, offset_minutes : Int) -> DateTime` | `0L,0`→1970-01-01T00:00:00.000；`0L,480`→1970-01-01T08:00:00.000；`0L,-450`→**1969-12-31**T16:30:00.000；`-1L,0`→1969-12-31T23:59:59.999；`-1000L,0`→1969-12-31T23:59:59.000；`-86400000L,0`→1969-12-31T00:00:00.000；`86399999L,0`→1970-01-01T23:59:59.999；`1791117296789L,0/480/-450`→2026-10-04T12:34:56.789 / T20:34:56.789 / T05:04:56.789；`482196050520L,0`→1985-04-12T23:20:50.520 | `offset_minutes` 不校验范围（见下"差异声明"） | `DateUtil.date(ms)` 再靠默认时区格式化 | **偏移显式传**；且不做 tzdb，所以偏移可以是任何整数（本库不判它像不像真实时区，那是配置层的事） | epoch 毫秒 →（`millis + offset*60000`）的**向下**除法/取模拆出日与日内毫秒，再走 `civil_from_days`；与 Python `datetime.fromtimestamp(tz=timezone(timedelta(...)))` 逐条核对 |
| `DateTime::to_epoch_millis(offset_minutes : Int) -> Int64` | 2026-10-04T12:34:56.789 在 `0/480/-450` 下 → `1791117296789L / 1791088496789L / 1791144296789L`；1970-01-01T00:00:00.000→0L；1969-12-31T23:59:59.999→-1L | 与上一条互逆 | `DateUtil` 无（Java 的 `Date` 本身就是瞬间） | 这是"墙上时钟 → 瞬间"的唯一通道，所以偏移必填 | 同 #2.5 上一条，反方向 |
| `DateTime::offset(unit : TimeUnit, n : Int64) -> DateTime` | 12:34:56.789 起：`Hour +2`→14:34:56.789；`Day −1`→2026-10-03T12:34:56.789；`Week +1`→2026-10-11T12:34:56.789；`Millisecond +213`→12:34:**57.002**（进位）；2024-01-31T23:59:59.999 `Millisecond +1`→**2024-02-01T00:00:00.000**；2024-02-29T23:59:59.999 `Day +1`→2024-03-01T23:59:59.999 | 跨日/月/年进位由内部 epoch 换算完成 | `DateUtil.offset(date, DateField, n)` | hutool 的 `DateField` 含 `MONTH/YEAR`；本库把它们分到 `offset_month`，`offset` 只吃固定长度单位（见 #1 的 `TimeUnit` 说明）。无 DST ⇒ `offset(Day,1)` 恒等于 +24 小时墙上时钟 | 换毫秒、加、再走 `from_epoch_millis` |
| `DateTime::offset_month(months : Int) -> DateTime` | 2026-10-04T12:34:56.789 +4→2027-02-04T12:34:56.789；2024-01-31T12:00:00.000 +1→**2024-02-29**T12:00:00.000 | 夹紧同 #2.4 | `DateUtil.offsetMonth` | 先加月、时刻原样保留（不进位到日） | 同上 |
| `Date::to_datetime(self) -> DateTime` | 2026-10-04→2026-10-04T00:00:00.000 | — | `DateUtil.date(Calendar)` | — | 定义即契约 |
| `DateTime::to_iso_string(self) -> String` / `Date::to_iso_string(self) -> String` | `2026-01-05T09:07:03.045`、`2026-10-04T00:00:00.000`、`2026-10-04`；负年份 `-0003-01-01`、`-0045-01-01` | **恒不失败**（输出侧没有 raise） | `DatePattern.NORM_*` + `formatDate` | 输入侧**不给**对称的 `from_iso_string`：解析统一走 `parse`，避免两处输入语法各漂各的。年份规则：绝对值补零到 4 位，负数前缀 `-` | ISO 8601 表示法 |

**血统**：Unix 时间语义（epoch 毫秒）+ proleptic Gregorian；`to_iso_string` 的表示法取 ISO 8601。


### 2.6 pattern 常量与格式化

`DatePattern` 常量（hutool `DatePattern` 对位，值写死防手抄错）：

| 常量 | 值 | hutool 对位 |
|---|---|---|
| `date_pattern` | `yyyy-MM-dd` | `NORM_DATE_PATTERN` |
| `datetime_pattern` | `yyyy-MM-dd HH:mm:ss` | `NORM_DATETIME_PATTERN` |
| `datetime_millis_pattern` | `yyyy-MM-dd HH:mm:ss.SSS` | `NORM_DATETIME_MS_PATTERN` |
| `pure_date_pattern` | `yyyyMMdd` | `PURE_DATE_PATTERN` |
| `pure_datetime_pattern` | `yyyyMMddHHmmss` | `PURE_DATETIME_PATTERN` |
| `time_pattern` | `HH:mm:ss` | `NORM_TIME_PATTERN` |

**支持表（封闭子集）**——宽度是**格式化时的最小位数**，解析时的位数规则见 #2.7：

| 占位串 | 含义 | 读数样例 |
|---|---|---|
| `yyyy` | 年，绝对值补零到 4 位，负年带 `-` | 2026→`2026`；-3→`-0003` |
| `yy` | 年后两位，取**向下模** 100 | 2026→`26`；2000→`00`；-3→**`97`**（不是 `-3`） |
| `MM` / `M` | 月，2 位补零 / 不补零 | 1→`01` / `1` |
| `dd` / `d` | 日 | 5→`05` / `5` |
| `HH` / `H` | 24 小时制时 | 9→`09` / `9` |
| `hh` / `h` | 12 小时制时（0 点→12、13 点→1） | 0→`12`；13→`01`；9→`09` |
| `mm` / `m`、`ss` / `s` | 分、秒 | 7→`07` / `7` |
| `SSS` | 毫秒，3 位补零 | 45→`045` |
| `'...'`、`''` | 字面量段 / 单引号本身 | `"'<'yyyy'>'MM"`→`<2026>01` |
| **其余 ASCII 字母** | **不支持** ⇒ `UnknownPatternToken(该串)` | `EEEE`、`a`、`S`、`SSSS`、`YYYY`、`ww`、`MMMM`、`XXX` 各钉一条 |

| 签名 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|
| `DateTime::format(pattern : String) -> String raise DateError` | 表外字母 ⇒ `UnknownPatternToken`；未闭合的 `'` ⇒ `ParseFailed`（格式化里也算输入不匹配的一种，位置是那个引号） | `DateUtil.format(date, pattern)` → `FastDateFormat` | **模式先整体校验**（非法占位串先于任何数据读取报出）；不支持 `a`/AMPM（无 AM/PM 概念时 12 小时制不可逆）、`Z`/`X`（偏移由调用方拼）、`ww`/`W`/`D`/`F`/`GG` | 宽度与进位规则见本表；每条读数由本表三条规则（宽度/字面量/缺省）逐一推出——规则即权威，用例是它的落点 |
| `Date::format(pattern : String) -> String raise DateError` | 出现**时间类**占位串 ⇒ `UnknownPatternToken("HH")` 等 | `DateUtil.formatDate` | `Date` 没有时分秒，输出 `00:00:00` 是编造数据而不是格式化 | 定义即契约 |

**血统**：占位串字母含义来自 JDK `java.text.SimpleDateFormat`，其等价开源实现是 Apache Commons Lang3 `FastDateFormat`（Apache-2.0）——hutool `date/format/*` 的真上游就是它。本库只借"字母代表什么"这层语义，宽度与拒绝策略自定并写明，不搬任何实现。


### 2.7 解析

`Date::parse(input, pattern)` 与 `DateTime::parse(input, pattern)` 共用同一套规则：

| 规则 | 定死的样子 | 读数（已冻结） |
|---|---|---|
| 数字宽度 | `yyyy`=可选 `-` + **恰好 4 位**；`yy`/`MM`/`dd`/`HH`/`hh`/`mm`/`ss`=**恰好 2 位**；`M`/`d`/`H`/`h`/`m`/`s`=**1~2 位**（贪婪取 2）；`SSS`=**恰好 3 位** | `"2026-1-4"` 配 `yyyy-MM-dd` ⇒ `ParseFailed("2026-1-4", 5)`；`"2026-10-4"` ⇒ `ParseFailed(…, 8)`；`"2026-01-05 09:07:03.4"` 配 `SSS` ⇒ `ParseFailed(…, 20)`；`"2026-01-05 9:07:03"` 配 `HH` ⇒ `ParseFailed(…, 11)` |
| 字面量 | 逐字符相等，不跳空白、不做大小写不敏感 | `"2026-10-04T12:34:56"` 配 `yyyy-MM-dd HH:mm:ss` ⇒ `ParseFailed(…, 10)`；`"2026.10.04"` ⇒ `ParseFailed(…, 4)` |
| 尾部多余 | 所有段消费完后输入必须刚好用完 | `"2026-10-04 "` ⇒ `ParseFailed(…, 10)` |
| 缺字段补值 | 年 `0`、月 `1`、日 `1`、时/分/秒/毫 `0` | `"2026"` 配 `yyyy` ⇒ `2026-01-01`；`"<2026>01"` 配 `'<'yyyy'>'MM` ⇒ `2026-01-01` |
| 两位年窗口 | `00..69 → 2000..2069`、`70..99 → 1970..1999` | `"69-01-01"`→2069-01-01、`"70-01-01"`→1970-01-01、`"99-12-31"`→1999-12-31 |
| 越界 | 月 ⇒ `MonthOutOfRange`；日 ⇒ `DayOutOfRange`；时分秒毫 ⇒ `TimeFieldOutOfRange(读到的四个值)` | `"2026-13-01"`→`MonthOutOfRange(13)`；`"2026-02-30"`→`DayOutOfRange(2026,2,30)`；`"2026-10-04 25:00:00"`→`TimeFieldOutOfRange(25,0,0,0)`；`12:60:00`→`(12,60,0,0)`；`12:34:60`→`(12,34,60,0)` |
| 12 小时制 | `hh`/`h` **在解析侧判 `UnknownPatternToken`**（格式化侧支持） | `"2026-10-04 09:07:03"` 配 `yyyy-MM-dd hh:mm:ss` ⇒ `UnknownPatternToken("hh")`；`"9:07"` 配 `h:mm` ⇒ `UnknownPatternToken("h")` |
| 同一字段两次 | 判 `UnknownPatternToken`（模式问题，不是输入问题） | — |
| 校验时机 | 先整体校验 pattern（含 `hh`/`h` 拒绝、未知字母、重复字段），再消费输入 | `"2026-10-04"` 配 `yyyy-MM-dd EEEE` ⇒ `UnknownPatternToken("EEEE")` 而不是 `ParseFailed(…, 10)` |
| 正例（已冻结） | — | `"2026-10-04 12:34:56"`→`2026-10-04T12:34:56.000`；`"2026-1-5 9:7:3"` 配 `yyyy-M-d H:m:s`→`2026-01-05T09:07:03.000`；`"20260105090703"`→同前；`"2026-01-05 09:07:03.045"`→`…T09:07:03.045`；`"2024-02-29 23:59:59.999"`→原样；`"2026-10-04T13:05:00"` 配 `yyyy-MM-dd'T'HH:mm:ss`→`…T13:05:00.000`；`"2026-10-04T12:34:56Z"` 配 `yyyy-MM-dd'T'HH:mm:ss'Z'`；`"-0003-01-01"`→`-0003-01-01`；`"2026年10月04日"`→`2026-10-04` |
| `Date::parse` 允许 pattern 带时间占位串 | 读出来再丢弃（"从更宽的输入取日期"） | `"2026-10-04 12:34:56"` 配 `datetime_pattern` ⇒ `Date` = `2026-10-04` |

差异声明：hutool `DateUtil.parse` 会**依次猜** 10 余种日期格式（`Util.parseDate` 那一套智能猜测），本库不做——猜出来的语义依赖输入，无法冻结期望值。要哪种格式就传哪种 pattern。真上游：hutool `date/format/*` 的 pattern 语义来自 JDK `java.text.SimpleDateFormat`，而 `SimpleDateFormat` 的行为在 Apache Commons Lang3 `FastDateFormat`（Apache-2.0）里有一份等价实现；本库只借"字母代表什么"这层语义，宽度、缺省、越界三档规则**自己定死并写明**，不跟 JDK 的宽容档。

**血统**：同 2.6（字母语义是 `SimpleDateFormat`/`FastDateFormat` 那一套；宽度、缺省、越界三档规则本库自定）。


### 2.8 RFC 3339（ISO 8601 的互联网 profile）

| 签名 | 读数（已冻结） | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `to_rfc3339(millis : Int64, offset_minutes : Int) -> String` | `0L,0`→`1970-01-01T00:00:00Z`；`0L,480`→`1970-01-01T08:00:00+08:00`；`482196050520L,0`→`1985-04-12T23:20:50.520Z`；`…,480`→`1985-04-13T07:20:50.520+08:00`；`…,-450`→`1985-04-12T15:50:50.520-07:30`；`-1L,0`→`1969-12-31T23:59:59.999Z`；`-1000L,480`→`1970-01-01T07:59:59+08:00`；`1791117296789L,0`→`2026-10-04T12:34:56.789Z`；`86399999L,-720`→`1970-01-01T11:59:59.999-12:00`；`4294967296000L,840`→`2106-02-07T20:28:16+14:00` | 恒不失败 | `DatePattern.UTC_*` / `DateUtil.formatUTC` 一族 | **毫秒为 0 时省略小数秒**，非 0 时 3 位（定长输出请改用 `format` + `datetime_millis_pattern`）；偏移 0 出 `Z` | RFC 3339 §2.3/§5.6 语法；每个串由 Python `datetime.astimezone(timezone(timedelta(minutes=off)))` 现算 |
| `from_rfc3339(text : String) -> Int64 raise DateError` | `1970-01-01T00:00:00Z`→0L；`1985-04-12T23:20:50.52Z`→482196050520L；`1937-01-01T12:00:27.87+00:20`→-1041337172130L；`1969-07-20T20:17:00Z`→-14182980000L；`1985-04-12t23:20:50.52z`→同上（**大小写不敏感**）；`1985-04-12T23:20:50.5235Z`→482196050523L（**多于 3 位截断，不四舍五入**）；`2026-10-04T00:00:00+14:00`→1791021600000L | 缺分隔符/缺偏移/偏移小时越界 ⇒ `ParseFailed(text, at)`；月日越界 ⇒ `MonthOutOfRange`/`DayOutOfRange`；秒 `60` ⇒ `TimeFieldOutOfRange` | `DateUtil.parseRFC3339`（hutool 无此件，走 `DateTime` 猜格式） | 不接受空格分隔符、不接受缺偏移（不"当本地时间猜"）、**不支持闰秒** | 后两条（`1985-04-12T23:20:50.52Z`、`1937-01-01T12:00:27.87+00:20`）就是 RFC 3339 §5.6 正文里的 ABNF 示例串；`1969-07-20T20:17:00Z` 是额外抽的负 epoch 档 |

负向矩阵（已冻结的失败位置）：`"1985-04-12 23:20:50Z"`→`ParseFailed(_, 10)`；`"1985-04-12T23:20:50"`→`ParseFailed(_, 19)`；`"1998-12-31T23:59:60Z"`→`TimeFieldOutOfRange(23,59,60,0)`；`"1985-04-12T23:20:50+25:00"`→`ParseFailed(_, 19)`；`"1985-13-01T00:00:00Z"`→`MonthOutOfRange(13)`；`"1985-02-30T00:00:00Z"`→`DayOutOfRange(1985,2,30)`。`at` 是**失败处的码元下标**（0 起）。

**血统**：**RFC 3339 §2.3/§5.6**（规范正文的 ABNF 与两条示例串就是期望值本身）。


### 2.9 差值、同日判定与周岁

| 签名 | 读数（已冻结） | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `TimeUnit::to_millis(self) -> Int64` | Millisecond→1L、Second→1000L、Minute→60000L、Hour→3600000L、Day→86400000L、Week→604800000L | 恒不失败（没有月/年） | `DateUnit.getMillis` | 没有月/年这一档正是设计点：它们长度不固定 | 定义即契约 |
| `between(a, b, unit) -> Int64` | a=2024-02-28T23:00、b=2024-03-01T01:30（26.5 小时，闰年 2 月 29 日在中间）：Ms→95400000L、Sec→95400L、Min→1590L、Hour→26L、Day→1L、Week→0L；`between(b,a,Hour)`→26L（绝对值） | 向零截断 | `DateUtil.between(begin,end,unit)`（默认 isAbs=true） | 一致，符号档另给 `difference` | 两个 `to_epoch_millis` 相减再整除 |
| `difference(a, b, unit) -> Int64` | `difference(a,b,Hour)`→26L、`difference(b,a,Hour)`→-26L、`difference(b,a,Day)`→-1L | 同上 | `DateUtil.between(begin,end,unit,false)` | — | 同上 |
| `is_same_day(a, b) -> Bool` | 同一 `86399999L` 在 0 与 480 下→**false**（1970-01-01T23:59:59.999 vs 1970-01-02T07:59:59.999）；`u` 与 `from_epoch_millis(0L,0)`→true；`v` 与 `1970-01-02T00:00:00.000`→true | — | `DateUtil.isSameDay` | 比的是**墙上时钟的日期部分**，不是同一瞬间——偏移已烘进 `DateTime`。要判同一瞬间请比 `to_epoch_millis` | `a.date == b.date` |
| `age(birth, on) -> Int raise DateError` | 2000-02-29 起：on=2024-02-28→23、2024-02-29→24、2027-02-28→26；1949-10-01 起：on=2026-10-01→77、2026-09-30→76 | `on < birth` ⇒ `FutureBirth` | `DateUtil.ageOfNow` / `age(birthDate, endDate)` | 不返回负数：负年龄是没有的东西，猜一个只会把脏数据带到下游。2 月 29 日出生者在平年按 2 月 28 日**还没过完**生日 | 年差再按 (月,日) 比较减 1；闰日出生档与 Python 手算核对 |

**血统**：hutool `DateUtil.between`/`isSameDay`/`age` 的语义档（JDK `Calendar` 门面）；本库按毫秒与日历字段重写。


### 2.10 时钟入口

| 签名 | 语义 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `now_millis() -> Int64` | 全库**唯一**读时钟的入口（`env.now()` 返回 `UInt64`，本包重解释成 `Int64`） | 无参、无注入 | `DateUtil.date()` | 其余函数一律吃显式值，所以本包用例不依赖墙上时钟 | 见"零依赖四条"（`AGENTS.md`） |
| `now(offset_minutes : Int) -> DateTime` | `from_epoch_millis(now_millis(), offset)` | — | `DateUtil.date()` + 默认时区 | 偏移必填 | 同上 |

**这一格怎么测**：只断言**单调下界**（`now_millis() > 1700000000000L`）与"同一次读数的往返恒等"。刻意不写上界、也不拿两次读数互比大小——那是计时依赖，CI 机器一慢就假红。互逆那条用**同一次** `ms` 读数，两次读时钟之间的抖动进不了断言。

**血统**：core `env.now()`（唯一 OS 时钟窗口），无第三方。


## 3. 明确不做（本包范围内）

`java.text` 全套 pattern（`EEEE`/`MMM`/`a`/`Z`/`X`/`ww`/`W`/`D`/`F`/`G`）、JDK 的 lenient 滚动与"猜格式"、闰秒、微秒/纳秒精度、农历/节气/生肖、调休与法定节假日表、RFC 7231 IMF 日期（要英文星期/月名表，随 `EEE`/`MMM` 一起再定，见 `docs/ROADMAP.md`）。

> **10-06 就地更正**：这一条原先首位挂着「命名时区与 DST（tzdb 是要 FFI 或大表的东西）」，
> 现由 **§5 收了**（内置 IANA 段表，603 区 / 18713 段，纯 MoonBit 数据、零 FFI），从本条删掉。
> 其余七件仍是不做的原样。§5.6 记的是第二批**新增**的不收档，与本条不重叠。

## 4. 骨架期的 `warnings` 豁免（首批已删；第二批 PR-A 又压上一行）

`date/moon.pkg` 在骨架期压过一行 `warnings`，把 `struct_never_constructed` / `unused_constructor` /
`unused_error_type` 三类压掉——它们全是"实现还没写"的机械后果（类型没人构造、错误变体没人构造、签名写了
`raise` 而体里没 `raise`），为了消警告去写假实现才是本末倒置。

**首批 PR-B 落地那一笔已把整行删掉**（门禁 G12 的棘轮就是拦"豁免活得比 `abort` 久"，带阳性对照），
删掉之后 `moon check` 0 警告、`moon info` 后 `.mbti` 无 diff、47 条用例逐档对上。

**第二批 PR-A 重新压了一行** `warnings = "-unused_value"`，理由不同但同类：整张段表在骨架期没人读——
`zone.mbt` 七个入口全是 `abort`，那五个 `let` 数组就是纯粹的未用值。PR-B 落地时删，
G12 只认函数体里的 `PR-B：契约骨架` 字样，所以这一行压不过去第二次换代。


## 5. 内置 IANA 时区段表与命名时区入口（第二批）

> 状态：**第二批已收口**（10-06 两笔：契约 `85143d7` + `e60ee84`）。8 块冻结期望先按设计态红，落地轮修腿补回缺段后整表重生成，现在按 200 条切块成 31 块、逐区读数与段界两侧都对得上参照。数据件> `date/zone_test.mbt` 都由 `scripts/gen_zone_table.py` 从参照腿 `scripts/TzLeg.java` 的读数灌出来，
> **一格都没有手打**；换窗口或换参照代次就整文件重生成，不逐条改。

### 5.1 参照代次与体积（全是现读）

| 读数 | 值 | 怎么取的 |
|---|---|---|
| 参照 | JDK 17.0.14（Oracle）· `lib/tzdb.dat` **101731 bytes** | 腿的 `B` 行。tzdb 的版本名这版 JDK 不吐（反射 `sun.util.calendar.ZoneInfoFile.VERSION` 撞 `InaccessibleObjectException`），所以代次改用「JDK 版本 + tzdb.dat 字节数」钉 |
| 区数 | **603** | `ZoneId.getAvailableZoneIds()` 全量，含 legacy link 与 `Etc/*` |
| 段数 | **36701** | 窗口 `[1970-01-01, 2050-01-01)` 内：每区首段 + 每次跳变一段 |
| 腿自证（两道，方向相反） | `VERIFY_BAD_ROWS = 0` + `MISSED_MATERIALIZED = 0` | 正向：按窗口逐日两点反查，表内段必须与 `getOffset` 同读数；反向：`getTransitions()` 落在窗口内的每条段界都必须被采样求出。**少一道就会藏漏段**（见 §5.8 第 1 条） |
| 别名普查 | 603 个区只有 **318 套**不同规则（285 个区与别的区逐段同读数） | 规则指纹分组；本轮不去重，理由见 §5.6 第 3 条 |
| 成本 | 表源 **684 KB**（36701 段）· 期望件 **810 KB** · 全仓 `moon test --target wasm` 由约 3 s 抬到 **36 s** | 本机实测。先按 18713 段那一版量过一轮（349 KB / 424 ms / 8.5 s），修腿补段后翻倍再复测一次——两轮的体积判据都靠实测，没有按"大概能装下"下结论。三档读数一致性由门禁 G1/G3 逐档核 |

### 5.2 公开面七件

| 签名 | 语义 | 边界 / 错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `zone_count() -> Int` | 表内区数 | 无 | — | 本库新增出口，让"覆盖范围"可被调用方数出来 | 腿 `B ZONES` = 603 |
| `zone_names() -> Array[String]` | 区名清单，**返回拷贝** | 无 | — | 返回内部表就是允许调用方把表改坏；拷贝这一条有独立用例（改 `[0]` 再读，仍是原值） | 腿 `Z` 行逐区名 |
| `zone_exists(String) -> Bool` | 认不认这个区名 | 大小写敏感、不认缩写 | `ZoneUtil.exists`（旧版有，5.8.35 的 javap 现读只剩两件、无 `exists`） | 参照没有的档，本库补在"查表前先问一句"这个位置 | 由 `D` 行区名集合决定 |
| `zone_offset_minutes(String, Int64) -> Int?` | **瞬间 → 偏移**（分钟） | 坏名 / 窗外 ⇒ `None` | hutool 全程隐式走 `TimeZone.getDefault()` | 一个瞬间在一个区里恒一个偏移 ⇒ 这一件除坏名窗外是全函数；非整点偏移真实存在（`Asia/Kathmandu` = 345、`Pacific/Chatham` = 825）；`Etc/GMT+5` 腿给 **-300**，符号与直觉相反、照搬不修 | 腿 `P` 行 603×6 + `T` 行段界 1150 条 |
| `zone_offsets_at_wall(String, DateTime) -> Array[Int]` | **墙上 → 合法偏移集合**，0 / 1 / 2 档 | 坏名 ⇒ `[]` | — | 这一件的存在就是"有 DST 之后墙上↔瞬间不是一一映射"的正面承认；要唯一瞬间仍走显式 `offset_minutes` 那条老路 | 腿 `V` 行 10 条：`America/New_York|2024-11-03T01:30 ⇒ -240\|-300`（2 档）、`America/New_York|2024-03-10T02:30 ⇒ 空`（0 档）、`Asia/Shanghai|1986-05-04T02:30 ⇒ 空`（**中国 1986 年那回前跳**） |
| `datetime_in(String, Int64) -> DateTime?` | 瞬间 + 区名 ⇒ 墙上时刻（**纯函数**，不读时钟） | 坏名 / 窗外 ⇒ `None` | `DateUtil.date(.., TimeZone)` 一类 | 纯函数版先立住，才谈得上把它的读数冻进契约 | 腿 `W` 行 42 条（`LocalDateTime.ofInstant`） |
| `now_in(String) -> DateTime?` | 读一次时钟 + 查一次表 | 坏名 ⇒ `None` | `DateUtil.now()` / `DateUtil.date()` | 参照吃进程默认时区，本库把区名做成必填；纪律同 #2.10 | 见 §5.5 |

### 5.3 三条分岔（明写的取舍，不是漏）

| # | 分岔 | 参照那一侧 | 本库 | 代价 |
|---|---|---|---|---|
| 1 | 坏区名 | 腿 `U` 行五条：`TimeZone.getTimeZone` 对 `Nowhere/Nowhere`、空串、`asia/shanghai`（大小写错）一律**静默回落 GMT=0**，`GMT+8:00` 这种怪写法反而**被接受**=480；`ZoneId.of` 全部抛 | `None` / `false` | 调用方拿不到"参照那种悄悄给个 0"的行为。错名早炸比晚炸好，这条不留 |
| 2 | 窗口外 | 参照还能查（1900 前的历史段、2050 后的预测都在 JDK 里） | 一律 `None`，**不外推** | 2050 之后这张表过期。取舍是"过期就取不到"而不是"过期还给个旧偏移"——后者是静默错值 |
| 3 | 表序 | Java 侧无所谓（没有查表） | 表按**逐字节字典序**存，配 `date/zone.mbt` 自带比较器 | 见 §5.4，这条是本轮撞出来的工具链事实 |

### 5.4 表序判据（本工具链的 `String.compare` 不是字典序）

`moonbitlang/core/builtin/string.mbt:221` 的 `impl Compare for String` 写的是**先比长度、长度相同才逐字符比**，
与 Java `String.compareTo` 的字典序**不是同一个序**。三条实测（本机 wasm 真跑）：

| 表达式 | 字典序应当 | 本工具链实际 |
|---|---|---|
| `"abc" < "abd"` | true | true |
| `"Abidjan" < "Accra"` | true | **false**（7 字 vs 5 字，先比长度就判大了） |
| `"aa" < "b"` | true | **false**（2 字 vs 1 字） |

⇒ 后果与判据：
1. 表序与查找必须用**同一个比较器**。`zone.mbt` 里自带的 `zone_name_cmp` 是字典序实现；不许顺手写成 `xs[mid] < v`——那会把 603 个区里所有"长度不同"的相邻区查飞。
2. 表序对不对不需要专门的元测试来兜：**§5.2 那 603×6 条逐区读数本身就是表序证明**，序一对不上某区就给 `None`，那一整块当场红。变异 Z2 打的就是"把比较器换成 core 的 `<`"。
3. 对已交付包的影响已现读查过：`coll.maximum` / `minimum` 的用例只在 `Int` 上跑，`String` 那条走 `char_length()` 键，没踩到这条；但泛型实例化到 `String` 时它给的是**"取最长"而不是"字典序最大"**，这属本仓未承诺的行为，记在这里免得下一轮误当成缺陷。

### 5.5 时钟面：只补"命名时区的现在"，不补缓存时钟

hutool 的 `cn.hutool.core.date.SystemClock`（javap 现读公开面只有 `SystemClock(long)` / `now()` / `nowDate()`）
内部是一条 `ScheduledExecutorService` 每 1 ms 刷一个 `volatile long now`——**`now()` 给的是缓存值不是当下值**；
`nowDate()` 是 `new Timestamp(now).toString()`，吃默认时区。本库全同步、零依赖、起不了那条线程，
也起不了"同一毫秒内恒等读数"这种只能在并发下才成立的判据 ⇒ **整件判不收**，`now_in` 就是一次 `env.now()`
加一次查表。这一件"没有实现"的判据不是猜的：先前对撞过一次——`now()` 缓存语义与 `System.currentTimeMillis()`
在同一条腿里就是两个读数，本轮把腿源读全后按"无对应可冻形状"处置。

`now_in` 的用例沿用 #2.10 的纪律：只断**同一次时钟读数的等价式**（`datetime_in(zone, ms)` 与
`DateTime::from_epoch_millis(ms, 表内偏移)` 同值）与形状下界（年份下界、时分秒字段范围），
不断两次读时钟之间的大小关系——那是计时依赖，CI 一慢就假红。

### 5.6 不收（本批范围内）

| # | 不收 | 理由 |
|---|---|---|
| 1 | RRULE / 规则压缩（"3 月最后一个周日"那种） | 只存展开段。存规则就得自己实现规则解释器，判据立刻从"抄腿读数"变成"我算对了没" |
| 2 | 1970 前与 2050 后 | 见 §5.3 第 2 条 |
| 3 | 285 个别名区去重（可省 38% 行数） | 不改公开面的纯体积优化，多一套"名字→规则号"间接层就多一处能错的地方 |
| 4 | `ZoneUtil.toTimeZone` / `toZoneId` | javap 现读 5.8.35 的 `ZoneUtil` 只有这两件；参照那两个类型 `java.util.TimeZone` / `java.time.ZoneId` 在本库**都没有对应物**，翻译等于同一张表查两遍。`conv` 当年推到 date 的那件 `toTimeZone` 一并结在这条 |
| 5 | `is_dst` 位 | 参照侧 `ZoneRules.isDaylightSaving` 要 JDK 12+，本腿在 JDK 8 API 上跑；且段表已含偏移，DST 与否可由"该段 != 该区标准段"推出但不承诺 |
| 6 | 三字母缩写区名（`CST`/`EST` 这类本就歧义） | 不进表；`zone_exists` 给 `false` |
| 7 | 命名时区版 `format` / `parse`（`DateTime::format` 带区名重载） | 先让查表面站稳；重载会把 §2.6~2.7 那套 pattern 表再拖一遍 |

### 5.7 变异计划（PR-B 填读数；隔离副本 + 基线断言 + 写盘 `flush/fsync/回读断言` + `finally` 还原 + 收尾字节比对）

| 号 | 变异 | 计划打的档 |
|---|---|---|
| Z1 | 段起点二分边界从"最后一个 `<=`"改成"第一个 `<`" | 每条段界 ±1 秒（`T` 行 1150 条里至少一跳就红） |
| Z2 | 区名比较器换成 core 的 `<`（先比长度那条） | 表序判据：603 区里长度不同的邻居当场给 `None` |
| Z3 | 窗外判据去掉（负 millis 也去查表） | 窗口下/上界四条 |
| Z4 | `zone_names()` 直接返回内部表 | 拷贝那条用例（改 `[0]` 后还能查回原区名） |
| Z5 | `zone_offsets_at_wall` 命中 0 档时改给"前一段偏移"（把空洞当正常） | `America/New_York|2024-03-10T02:30` 与 `Asia/Shanghai|1986-05-04T02:30` |
| Z6 | 2 档重叠时只回第一个 | `America/New_York|2024-11-03T01:30`、`Europe/London|2024-10-27T01:30` |
| Z7 | `zone_offset_minutes` 里偏移取首段而非末段 | 所有有 DST 的区在非标准时段 |
| Z8 | `datetime_in` 的偏移符号反了（`millis + off*60000` 写成 `-`） | 全部 `W` 行 42 条 |

**落地轮实测**（10-06，`tar` 出的隔离副本；基线 553 = 绿 553 / 红 0 ⇒ 才开跑；逐条 `flush/fsync/回读断言` 写盘 +
`finally` 还原 + 还原后复跑仍 0 红）：**八条全部抓红，零等价**。

| 号 | 实测新增红块 | 归因（为什么这条打得着） |
|---|---|---|
| Z1 | **+33** | 段界两侧那 12 块 + 逐区六瞬间里落在段界上的档 |
| Z2 | **+36** | core 的 `<` 先比长度 ⇒ 603 个区里几乎所有"长度不同的邻居"直接查飞，逐区那块整片红 |
| Z3 | +1 | 窗口下界那一块（`-1L` 那条） |
| Z4 | +1 | 区名清单那块里"改 `[0]` 再读回原值"那条 |
| Z5 | +1 | 墙上三档那块：比偏移值时同值段全部验过，出来是几十条重复项 |
| Z6 | +1 | 同一块：重叠档丢掉第二支 |
| Z7 | **+32** | 取首段就等于"整块表停在 1970 年那档"，逐区六瞬间几乎全红 |
| Z8 | +2 | `datetime_in` 那块 42 条 + `now_in` 的等价式 |

> Z2 与 Z7 的红块数最多，正说明"表序"和"取当前段"是这张表的两条承重梁；Z5/Z6 各只打 1 块，
> 是因为 `zone_offsets_at_wall` 的夹具只有 10 条——**这一族的覆盖面明显比偏移族薄**，
> 如实记在这儿，下一批若要加"墙上→瞬间"的入口就该先把这块夹具加厚。



### 5.8 落地轮的两条如实记录（都是腿/实现的形状问题，不是夹具缺口）

1. **`ZoneRules.getTransitions()` 不是"全部段界"，照抄会得到一张缺段的表**。
   PR-A 那版图正是这么来的：18713 段。实弹一跑就红——`Africa/Ceuta` 在窗口内的最后一条已展开段是
   `877827600`（1997-10-26），此后到 2050 全靠 EU 规则生成，`getTransitions()` 一条不给，于是
   2000-06-15 那档本库回 `60`、腿回 `120`。
   **最坑的地方在于旧的那道自证抓不到它**：`SELFCHECK_BAD_ROWS` 逐条核的是"存在的行两侧读数对不对"，
   行存在就通过；缺的行压根不进判据 ⇒ 它报了 0，而表是错的。
   修法在腿不在期望：改成按 6 小时步长扫窗口 + 二分定界，把段**求出来**；再加两道方向相反的自证
   （正向逐日反查 `VERIFY_BAD_ROWS`，反向要求每条已展开段界都被求出 `MISSED_MATERIALIZED`）。
   修完段数 18713 ⇒ **36701**，两道自证都 0。**教训固化成一句：腿的自证必须能判"缺了什么"，只判"有的对不对"是不够的。**
2. **`zone_offsets_at_wall` 的验证判据要"比段号"，不是"比偏移值"**。
   第一版写 `tbl_seg_off[base + j] == off`，出来的是 `[-300, -240, -300, -240, ...]`：同一偏移在几十年的表里
   占几十段，任何一段都能验过同一个候选瞬间。改成只加了去重仍然错——顺序变成"哪个偏移在表里出现得早"，
   本例给 `[-300, -240]` 而腿给 `[-240, -300]`。正解是**候选瞬间必须落回自己那一段**（`j == k`）：
   按段序（= 时间序）扫，重叠档自然给出"转换前那一支在前"，与参照 `getValidOffsets` 同序，也不需要去重。
   这条就是变异 Z5 的内容——它不是"锦上添花的对照"，而是本轮真实踩过并翻红的那一步。

> 另记一条工具链事实（§5.4 那条的直接影响面）：一个 test 块塞几千条断言会撞
> `text_segment_excceed` 警告而破零警告门禁 ⇒ 生成器按 200 条切块（本轮 P/T 两大类各切成 19 + 12 块）。


---

## 5.9 表体积与查表耗时（10-07 实测，含一条被推翻的前提）

同一台机器、同一工具链、`moon run --target wasm-gc`，三个最小消费者：只引用 `text` 的对照、只调用日历件的（`days_in_month`）、调用命名区件的（`zone_offset_minutes`）。

| 读数 | 段起点存裸 epoch 秒 | 段起点改基准相对编码 |
|---|---|---|
| 对照 `m_text.wasm` | 14,433 B | 14,433 B |
| 只用日历 `m_date_plain.wasm` | **5,845 B** | **5,845 B**（未变，见结论 1） |
| 用命名区 `m_date_tz.wasm` | 491,053 B | **344,064 B**（-147 KB） |
| 查表 50,000 次（`America/New_York` @ 1710050400000） | 160 ms | 163 ms（抖动内，耗时不变） |
| `date/zone_table.mbt` 源文件 | 684,245 B | 648,959 B |

1. **一条前提被实测推翻，方案撤销**：原本打算「把时区表拆成独立数据包，免得只用日历的消费者背这张表」。实读是 wasm-gc 链接器把**未被引用的表整段 DCE 掉**——`m_date_plain` 与对照档逐字节同值，只用日历的消费者从来就没为表付过钱。拆包省不出任何东西，因此公开面（包结构与件名）不动；表的代价只在「真的用了命名区」那条路上才付。
2. **落地的紧凑化 = 段起点走基准相对编码**：`tbl_seg_start` 从 `Array[Int64]` 换成 `Array[Int]`，存 `秒 - 946684800`（2000-01-01T00:00:00Z），消费侧 `seg_last_le` 加回常量 `tz_sec_base`。动机不只是省字节——窗口上界 2,524,608,000 秒**大于 2^31-1**，而 wasm/js 档 `Int` 是 32 位且**越界静默回绕**（§0.1 同条实测），裸 epoch 秒装不进 `Int`；把原点搬到窗口中段，数值范围变成 [-946,684,800, 1,577,923,200)，两侧都装得下。省下 147 KB = 36,701 × 4 B，与预测逐字节吻合。
3. **等价性的四条凭据**（「测试绿了」只是其中一条）：① 变换前后把两份表各自解回秒域，36,701 条逐条相等，由工装脚本 `assert` 拦住；② `date/zone_test.mbt`（603 区 × 段的冻结期望）**一字未改**，`git diff --numstat` 对该文件为空；③ 全仓 `moon test --target wasm` = 绿 667 / 红 0；④ 生成器 `scripts/gen_zone_table.py` 与落树件**同笔改形**（否则下一次再生就把表打回 `Array[Int64]`——派生件的一致性必须同笔维持）。
4. **仍知的一个热点（本轮未做）**：`zone_name_cmp` 每次比较都把两个区名 `to_array()` 摊成 `Char` 数组，二分每层两次分配 ⇒ 3.2 µs/次查表的大头在比较器而不是查表本身。改成按下标取码位比较属纯内部改动、期望文件不动，挂在待办。

## 6. 可注入的时钟源（第三批，10-06 owner 点名）

> 状态：**第三批已收口**（10-06 两笔：契约 `c984f49` + 落地笔 `cbbc9f9`）。这一批补的是 §5.5 结尾挂着那条——可注入时钟源。

### 6.1 先分清三层，免得又混着说

| 层 | 管什么 | 本包落点 | 参照/宿主在哪 |
|---|---|---|---|
| 时钟源 | "现在的原始读数"从哪来 | `clock_system()`（唯一真读 OS 的口） | core 只有 `env.now()` 一条缝：epoch 毫秒。JS 档它落 `Date.now`，native 档落 libc——**每个目标都得自己开 extern**，这就是 core 至今没有 `time` 包的原因（现读：`moonbitlang/core` 主仓 56 个包，无 `time`/`date`/`calendar`） |
| 时钟（可替换的"现在"） | 测试能不能把"现在"换成假的 | `clock_fixed(ms)` + 吃 `() -> Int64` 的 `now_at` / `today_at` | 语言不管这件事，纯设计问题 |
| 时区 | 同一个瞬间显示成几点 | §5 那张内置表 | 参照代次自带 tzdb，不是算出来的 |

### 6.2 公开面（新增五件）

| 签名 | 语义 | 边界 / 错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `clock_system() -> () -> Int64` | 返回一个"每次调用读一次 OS 时钟"的函数 | 无参 | `SystemClock.now()` / `DateUtil.current()` | 参照 `SystemClock` 内部是**每 1 ms 刷 `volatile long` 的调度线程**，给的是缓存值；本库全同步起不了那条线程，也**不承诺**"同一毫秒内恒等读数"——本库这一件就是 `env.now()` 的一次读数（§5.5 那条"不收"仍然成立，这里收的是它去掉缓存后剩下的那一半） | 本库形状，无期望值可冻（见 §6.4） |
| `clock_fixed(millis : Int64) -> () -> Int64` | 假钟：恒定给同一个读数 | 无（不校验窗外，窗外由查表那一步给 `None`） | 测试替身（参照无可注入口） | 本库新增。刻意**不校验**入参是否在窗口内：校验归 `now_at`/`today_at` 那一步，假钟只管给数 | 组合后的读数由腿 `W`/`P` 行冻 |
| `date_of(zone : String, millis : Int64) -> Date?` | 瞬间 + 区名 → **日历日**（纯函数） | 坏名 / 窗外 ⇒ `None` | `DateUtil.date(.., tz)` 取日期那一半 | 与 `datetime_in` 同一条查表路，只是只要 `date` 那一半——这样 `today_at` 才是薄封装而不是第二套算法 | 腿 `W` 行的 `y-m-d` 列直读 |
| `now_at(zone : String, clock : () -> Int64) -> DateTime?` | 用**注入的钟**取墙上时刻 | 坏名 / 窗外 ⇒ `None` | `DateUtil.date()` + 默认时区 | 参照吃进程默认时区；本库区名必填 + 时钟可换。`now_in(zone)` 保留但重定义为 `now_at(zone, clock_system())`，签名与已冻用例一字不动 | `clock_fixed(T)` 时等价于 `datetime_in(zone, T)`，读数即 §5 已冻的那批 |
| `today_at(zone : String, clock : () -> Int64) -> Date?` | 用注入的钟取**日历日** | 同上 | `DateUtil.today()`（参照返回 `"yyyy-MM-dd"` **串**且吃默认时区） | 本库返回 `Date` 而不是串（要串自己 `.to_iso_string()`），区名必填 | 腿 `W` 行的 `y-m-d` 列直读 |

### 6.3 为什么形状是"传函数"而不是"设全局"

反面例子在本生态里就有现成的：`jeeflow-moon/core/model/clock.mbt:5` 用的是
`let clock_ref : Ref[((() -> String))?]` + `pub fn set_clock(f)` 全局可变槽，
实测后果是**并发/async 用例互相盖住对方的钟**。本包全同步、也没有跨模块状态，
把"现在"做成**首参之后的显式实参**（`() -> Int64`）就完全没有那类耦合：
一条用例一个钟，读数还是纯函数、期望照样能冻。附带好处——`clock_fixed` 让"跨夏令时边界的
换算"这类用例第一次变得可写：§5.2 那 3618 条读数原本就得靠"直接给瞬间"才测得动。

### 6.4 时钟源本身怎么测（不写计时依赖）

`clock_system()` 是唯一没有外部读数的一条：**它的正确性不能靠断一个具体时刻**，
否则 CI 慢一点就假红。判据只有三条，且都是形状级的：
① `clock_system()` 给的读数 `> 1700000000000L`（绝对下界，同 #2.10 那条口径）；
② 同一个钟函数**连取两次**，`第二次 >= 第一次` 不进断言（本包 `Int64` 档不承诺单调，
   wasm 宿主的 `Date.now` 可被系统时间调整往回拨），只断"两次读数各自都能查出一个偏移"；
③ `now_at(zone, clock_system())` 与 `date_of(zone, clock_system()())` 允许来自两次不同的读数
   ⇒ 这一条**也不许互比相等**。能互比的只有 `clock_fixed`：`now_at(zone, clock_fixed(T))`
   必须逐位等于 `datetime_in(zone, T)`（腿读数，已冻）。

### 6.5 不收（本批范围内）

| # | 不收 | 理由 |
|---|---|---|
| 1 | `SystemClock` 的缓存那一半（同毫秒恒等、1 ms 刷新） | 参照内部是 `ScheduledExecutorService` 线程；本库零 extern、全同步，既起不了线程，也无法冻结"同毫秒恒等"这种只能在并发下才成立的判据 |
| 2 | 单调钟 / 秒表（`DateUtil.timer()`、`StopWatch`、`elapsed`） | 需要 monotonic 源。core 的 `env` 只给墙上毫秒；`core/bench` 里那三份 `monotonic_clock_{js,native,wasm}.mbt` 是 bench 自用、没做成公开包，而本库契约禁 extern ⇒ 没有可信的单调源，硬做就是拿墙上钟假装单调（NTP 往回拨就错）<br>**10-10 第六批就地更正：这一行已被 §9 推翻**（owner 点名"注入"）。它拦的是"库自己读时钟并承诺单调"，拦不住"库不读时钟"——`StopWatch`/`TimeInterval`/`GroupTimeInterval` 现在都只吃调用方注入的 `() -> Int64`，G18 白名单一字未动，理由与判据见 §9.1。`DateUtil.timer()`（返回一个预启动的 `TimeInterval`）由 §9.4 的 `time_interval(clock)` 承接；`elapsed` 那族数值差仍由 §2.9 的 `between`/`difference` 承担 |
| 3 | `nowDate()`（参照 `new Timestamp(ms).toString()`，形如 `2026-10-06 12:00:00.123`） | 参照吃默认时区 + 依赖 `Timestamp.toString` 的定宽格式；本库区名必填，而"要串"这一步 `DateTime::format` 已经能做 |
| 4 | 时钟的时区自适应（"本机时区"隐式档） | 与 §0.1 冲突且 wasm 取不到宿主偏移 |
| 5 | `Clock` 结构体 / 枚举抽象 | 一个 `() -> Int64` 就够，套一层类型要多一个公开类型与一份 `.mbti` 面，收益只有好看 |

### 6.6 变异计划（PR-B 填读数；隔离 `tar` 副本 + 基线断言 + `flush/fsync/回读断言` + `finally` 还原 + 收尾字节比对）

| 号 | 变异 | 计划打的档 |
|---|---|---|
| C1 | `clock_fixed(millis)` 返回的闭包里读 `clock_system()`（假钟变真钟） | 所有 `now_at` / `today_at` 用 `clock_fixed` 的档——它们与 §5 已冻读数逐位对照，必红 |
| C2 | `now_at` 不等 clock，自己另读一次 `env.now()` | 同上一族（注入失效 ⇒ 与 `datetime_in(zone, T)` 不再相等） |
| C3 | `date_of` 用 UTC 偏移而不是表内偏移 | 所有 `today_at` / `date_of` 的非 UTC 区档 |
| C4 | `date_of` 的偏移符号反了（`+ off` 当 `- off`） | 东西半球两侧各一档（`Asia/Shanghai` vs `America/New_York` 同瞬间的日历日不同） |
| C5 | `today_at` 走进程式默认档（写死偏移 480） | 除中国外的全部区 |
| C6 | `now_in(zone)` 的薄封装改成"自己读钟 + 自己算偏移" | `now_in` 那一块的形状断言 + 与 `now_at(zone, clock_system())` 的同形断言 |
| C7 | `clock_system()` 里加一层"同毫秒去重缓存"（往参照 `SystemClock` 靠） | **预期等价**——判据见 §6.4：本批刻意不断"同毫秒恒等"，也没有可冻的期望值打得到它。这条挂出来是为了把"为什么它注定测不到"写清楚，而不是当夹具缺口 |

**落地轮实测**（10-06，`tar` 出的隔离副本；基线 `566 = 绿 566 / 红 0` 才开跑；逐条写盘 `flush/fsync/回读断言` +
`finally` 还原 + 收尾复跑仍 0 红）。锚点按落地后的真实接缝重排过：C4 在计划里是"写死偏移 480"，
实现里 `today_at` 只剩一次委托，就打了它最像参照的那一档（写死 `Asia/Shanghai`，等于复刻"吃默认时区"）；
C5 是补上去的"假钟不恒定"档；C7 计划里是加缓存，但实现起不了线程，改成**把真钟整个冻死成常量**——
那是缓存档的极限形态，测不到它就等于测不到缓存档。

| 号 | 实测（新增红块） | 见证 |
|---|---|---|
| C1 | **+5** | `now_at` / `today_at` / 一致性 / `clock_fixed` 恒等 / 坏名窗外 五块 |
| C2 | +3 | 用假钟的两块 + 一致性那块 |
| C3 | **+7** | `date_of` 全表 7 块逐块全红：1970-01-01 那一档按 UTC 取日必然差一天，这正是把 E 行分两半进夹具的收益 |
| C4 | +3 | `today_at` 那块 + 一致性 + 坏名窗外 |
| C5 | +5 | 同 C1 那一族（假钟一旦不恒定，与腿读数逐位对照必失配） |
| C6 | **0（按构造等价）** | 推导 A |
| C7 | **0（可观测上限）** | 推导 B |

**推导 A（为什么 C6 的 0 红是好消息而不是缺口）**：`now_at(zone, clock_system())` 展开就是
`datetime_in(zone, now_millis())`——同一表达式的两种写法。"把 `now_in` 改成绕过封装自己读钟"在语义上是
**空操作**，它 0 红恰好是"第三批的重构没改动已冻件行为"的结构证明（配 `.mbti` 0 行改动一起看）。
这不是"没测到"，是"没有差别可测"。

**推导 B（本批真实的能力边界，写明不许当已覆盖）**：`clock_system()` 冻死成常量，566 条一条不红——
§6.4 那三条形状判据只问"这读数像不像一个时刻"（绝对下界、还能查出偏移、同一次读数下两入口同值），
而 2026-10-06 那个常量三条全过。**给不出不打脸的第二条判据**：断"两次读数会前进"就是计时依赖
（CI 一慢、或宿主时钟被 NTP 往回拨就假红，同 #2.10 的纪律）；断"读数等于今天的日历日"要么再读一次钟
（还是两次读数），要么写死日期（过一天就红）。⇒ 这一档按**不可达**登记，不是夹具缺口：
本包对"真钟是不是真的"验证上限到此为止，再往上要靠集成侧跨进程比较（`mldong-moon` 的 e2e 才是做这件事的位置）。
首批 #2.10 的 `now_millis() > 1700000000000L` 本来也测不到同一档，这条老账一起记在这儿。

## 7. 命名时区版格式化与解析（第四批，10-06 owner 点名）

> 状态：**第四批已收口**（10-06 两笔：契约 `fceabad` + 落地笔）。把 §5 那张表接到格式化与解析出口，结清 §5.6 第 7 条。

### 7.1 件归属先现读，别照名字猜

`javap -cp hutool-core.jar -public cn.hutool.core.date.DateUtil` 里吃 `TimeZone`/`ZoneId` 的公开件**只有三件**：

| 参照件 | 源码语义（读了实现，不是看名字） | 本库落点 |
|---|---|---|
| `convertTimeZone(Date, TimeZone)` / `convertTimeZone(Date, ZoneId)` | `return new DateTime(date, timeZone)`——**瞬间不变**，只换这个 `DateTime` 之后格式化用哪个区 | `format_in`：本库 `DateTime` 不携带区字段，所以把"显示用的区"做成入参、出口给串 |
| `newSimpleFormat(String, Locale, TimeZone)` | 造一个带区的 `SimpleDateFormat` | 同 `format_in`（本库不暴露 formatter 对象）；`Locale` 档不收，见 §7.4 |
| （无）带区名的 parse | 参照的 parse 全族吃默认时区，**没有** `parse(text, pattern, timeZone)` 公开件 | `parse_in` 属**本库新增档**：墙上→瞬间的取值规则一律照 JDK `SimpleDateFormat`（腿 S 行）现读，不自订 |

`LocalDateTimeUtil.of(long|Instant, ZoneId|TimeZone)` 四件 = 瞬间→墙上，**已由 §5 的 `datetime_in` 收**，本批不再开第二条入口。

### 7.2 公开面三件

| 签名 | 语义 | 边界 / 错误 | 读数来源 |
|---|---|---|---|
| `format_in(millis, pattern, zone) -> String? raise DateError` | 瞬间 + pattern 子集 + 区名 → 串 | 坏名 / 窗外 ⇒ `None`；pattern 表外 token、字段越界 ⇒ `raise`（走 §2.6 已冻那套，本件不改） | 腿 `F` 行 603 区 × 两瞬间 + `G` 行 12 区 × 六瞬间 × 两条 pattern |
| `parse_in(text, pattern, zone) -> Int64? raise DateError` | 串 + pattern + 区名 → 瞬间 | 坏名 ⇒ `None`；**表的覆盖窗口外 ⇒ `None`**；墙上时刻在该区不存在 ⇒ `raise ZoneGap(iso)`（新变体，见 §7.3）；串/pattern 本身非法 ⇒ 沿用 §2.7。后三种成因在实现里都是"空表"，**出口必须不同**——`wall_offsets` 的 `by_window` 开关就是为把它们分开而存在 | 腿 `S` 行 13 条（其中 1 条是表外区名，生成器按已知区集分流到坏名块）|
| `to_rfc3339_in(millis, zone) -> String?` | §2.11 的区名版 | 坏名 / 窗外 ⇒ `None` | 腿 `R` 行 12 区 × 两瞬间 |

**两条通道的分工要记牢**（这是本批最容易写错形状的地方）：*区名*的问题走 `None`（与 §5 同形，一个入口一个失败通道）；*串与 pattern* 的问题走 `raise`（§2.6~2.7 已冻）。同一个件同时有两类失败出口是设计决定，不是没收敛。

### 7.3 墙上→瞬间的取值判据（腿按住了我的一条直觉）

| # | 档 | 参照（腿 S 行反推的偏移） | 本库 |
|---|---|---|---|
| 1 | 平常（1 档） | 唯一偏移 | 同一支，`instant = wall - off` |
| 2 | **回拨重叠（2 档）** | **取转换后那一支**：`America/New_York|2024-11-03 01:30:00` ⇒ `-300`（不是 `-240`）；`Europe/London|2024-10-27 01:30:00` ⇒ `0`（不是 `60`）；`Australia/Lord_Howe|2024-04-07 02:30:00` ⇒ `630`（不是 `660`，这区 DST 只差 30 分） | 取 `zone_offsets_at_wall` 的**末支**。注意 §5 已冻的顺序是"转换前的在前"，所以是末支而不是首支——**这一条原本会想当然写成"取第一支"，是三区读数把它按住的** |
| 3 | **前跳空洞（0 档）** | `setLenient(false)` 下**主动抛** `ParseException`：`America/New_York|2024-03-10 02:30:00`、`Asia/Shanghai|1986-05-04 02:30:00`、`Asia/Shanghai|1986-05-04 02:00:00`（跳变点整点本身也不存在） | `raise ZoneGap(iso)`——**错误面新增一个变体**（本批唯一触碰已冻面的地方，加性）。判据是本仓老规矩："参照主动抛、带文案的判据 ⇒ 留变体"；并成 `None` 会把"这个墙上时刻不存在"和"这个区名我不认"混成同一个读数 |

`ZoneGap` 携带的是那个不存在的墙上时刻的 ISO 串（不是输入串），因为"哪一段不存在"才是有效信息，输入串调用方自己手里就有。

**第 4 条判据：本库的偏移是整分钟粒度，这一档与参照有可见差。** 本包 §1 的 `DateTime` 没有秒级偏移字段
（§2 已冻的换算口一律 `offset_minutes`），而窗口内确实还有非整分钟的偏移——腿 X 行点名：
只有 `Africa/Monrovia` 一个区，从 1970-01-01 到 1972-02-24 是 **-00:44:30**（参照 `totalSeconds = -2670`）。
处置不是把读数偷偷对齐，而是**两栏都让腿读**：腿对每条格式化读数同时给"参照原样"与
"把 TimeZone 换成 `GMT±截断分` 再渲染一次"两栏，断言打后者（仍是机器读数，不是本库自算），
前者在两栏不同的行留在注释里看得见。实测差异范围：`1969-12-31 23:15:30`（参照）vs
`1969-12-31 23:16:00`（本库），差 30 秒，只落在那一个区的这两年两个月内。
**代价写明**：本包对"那一档"承诺的是分钟粒度，不承诺复现参照的秒；要秒级偏移得先给 `DateTime`
加一个秒级换算口（§2 的已冻签名要动），本轮不动，理由是本包全线（`Date::format`/`to_rfc3339`/
`DateTime::of`）都按分钟建模，为一区两年改一次类型面不成比例。

### 7.4 腿的两条自证与不收

- **腿自证 `SELFCHK_BAD = 0`**：`F` 行的 1206 条读数另走一条独立 JDK 路径（`LocalDateTime.ofInstant` 手摆 `%04d-%02d-%02d %02d:%02d:%02d`）逐字符比对。不相等就说明 `SimpleDateFormat` 自己做了我们看不见的事（宽松滚动、周年份、locale 影响），整条判据不可信。本轮 0 条不符。
- **非 ASCII 读数一律转义或排除**：中文式 pattern（`yyyy年MM月dd日`）不进本腿——本格只测"区名接缝"，pattern 引擎（§2.6~2.7）与区名换算（§5）两条都已各自冻过，再组合一次测的还是那两条；顺带避开本机 GBK 管道串形。这条是**明写的不冻**，不是漏。
- 不收：`Locale` 档（本包子集里没有 `EEEE`/`MMM`，换 locale 必然同读数）；`lenient=true` 那一路（参照滚动语义与本包 §2.7"不滚不夹"直接冲突，接上就会把已冻件推翻，按分岔处理而不是照抄）；`SimpleDateFormat` 对尾部残留的宽容（同上，沿用本包 parse 的已冻判据）；参照 `DateFormatter`/`FastDateFormat` 的对象形状（本库无状态）。

### 7.5 变异计划（PR-B 填读数）

| 号 | 变异 | 计划打的档 |
|---|---|---|
| D1 | `format_in` 用固定偏移 0（忽略区名） | 除 UTC 外全部 `F`/`G` 行 |
| D2 | `format_in` 取**首段**偏移而不是瞬间所在段 | 有 DST 的区在夏令时档（`G` 行的 1986 / 2024-03 / 2026 三档） |
| D3 | `parse_in` 重叠档取**首支**（就是被我否掉的那个直觉） | 三条 2 档夹具（NY / London / Lord_Howe）——这条存在就是为了证明"取末支"是被读数要求的，不是随手写的 |
| D4 | `parse_in` 空洞档不报 `ZoneGap`，回落成"取前一段偏移" | 三条 0 档夹具 |
| D5 | `parse_in` 空洞档并成 `None`（不分通道） | 同三条 0 档：读数会从 `ZoneGap …` 变成 `null` |
| D6 | `to_rfc3339_in` 偏移符号印反（`+05:30` ⇒ `-05:30`） | 全部 `R` 行 |
| D7 | 坏区名改成静默回落 GMT（照参照 `TimeZone` 的形状） | §7.2 那一族的 None 夹具（含 `No/Where` 那条：参照给 12:00Z，本库给 `None`） |
| D8 | `format_in` 窗外改成立即 `abort`（把 `None` 通道换成崩） | 窗外两条 |

**落地轮实测**（10-06，`tar` 出的隔离副本；基线 `578 = 绿 578 / 红 0` 才开跑；逐条写盘 `flush/fsync/回读断言` +
`finally` 还原 + 收尾复跑仍 0 红）：**八条全部抓红，零等价**。

| 号 | 实测（新增红块） | 归因 |
|---|---|---|
| D1 | +8 | `format_in` 全表 7 块 + R 那一块（按偏移 0 渲染就丢掉全部分区差） |
| D2 | **+46** | 取首段偏移不只打本批，§5 的逐区与段界那一族整片红——两块契约共用的那条根判据钉得住 |
| D3 | +1 | 就是那 1 条重叠块：`[±] 首支 vs 末支` 差在两条夹具上，块级红一次 |
| D4 | +1 | 空洞块（当 UTC 正常档处理 ⇒ 读数与 `ZoneGap …` 不同） |
| D5 | +1 | 同块（并成 `None` ⇒ 两条通道混掉，判据可见） |
| D6 | +1 | R 那一块（符号印反） |
| D7 | +2 | 坏名块 + `zone_exists` 自身那条 |
| D8 | +3 | 窗外三条（当场崩取代 `None`） |

### 7.6 落地轮补的两条（都是"实现接不上参照"那类，不是夹具缺口）

1. **本包偏移是整分钟粒度，窗口内有非整分钟的偏移**：腿点名只有 `Africa/Monrovia`（1970-01-01 ~ 1972-02-24，
   参照 `-00:44:30`）。这条是格式化第一条真红翻出来的（本库给 `23:16:00`、参照给 `23:15:30`）。
   处置不是改期望迁就，也不是为区区一区两年去动 §2 已冻的 `offset_minutes` 类型面，而是**让腿两栏都读**：
   断言打"把 `TimeZone` 换成 `GMT±截断分` 再渲染一次"那一栏（仍是机器读数），参照原样留在注释里看得见。
   判据写在 §7.3 第 4 条，含"为什么不改成秒精度"的理由。
2. **`zone_offsets_at_wall` 的空表有两种成因，`parse_in` 必须分得开**：`America/New_York|2024-03-10 02:30`
   是"这个墙上时刻不存在"，`UTC|1969-12-31 23:59:59` 是"这个时刻超出表的覆盖窗口"——两者在带窗口过滤的
   谓词下都是空数组，第一版直接都抛 `ZoneGap`，窗外那条就红了。修法是把谓词拆成内部
   `wall_offsets(zone, wall, by_window)`：公开件仍走 `by_window=true`（§5 已冻语义一字不动），
   `parse_in` 额外问一次 `by_window=false` 来分辨两者（前者 `raise ZoneGap`、后者 `None`）。
   **这条就是"实现里的一个 Bool 参数为什么值得存在"的判据**——它不是设计洁癖，是两种空表必须走不同出口。

## 8. 默认区与无参便捷入口（第五批，10-07 owner 点名）

> 状态：**第五批已收口**（10-07 两笔：契约 `dcc6bad` + 落地笔）。`date/default_test.mbt` 15 块 305 条冻结期望全部转绿；§8.7 的十一条变异逐条抓红、零等价。

### 8.1 这一批解决的是什么，以及两条实测前提

owner 的裁定是原话：**"每个方法都传入肯定是不对的……环境变量找时区，有就用，没有就使用默认值。"**
本批就装这一层降级，一判据都不新增到换算面——§5 那张表与 §7 那三件一字不动，新件全是它们的薄封装。

动手前先把两条承重前提量了（**都不是推断，是三档真跑的读数**）：

| # | 前提 | 实测读数 | 后果 |
|---|---|---|---|
| 1 | `@env.get_env_var("TZ")` 到底读不读得到 | 宿主设 `TZ=Etc/GMT+5` 时，**js / wasm / wasm-gc 三档全读到** `Etc/GMT+5`；同批自造的 `MOLE_PROBE_ZONE` 也全读到（env 计数随之 +1） | 这条路成立，零 extern、不破「全同步」，`env` 本来就在 `date/moon.pkg` 的依赖里 |
| 2 | 参照那一侧的"默认时区"是不是也走 `TZ` | 同一台机器上 JDK 17：宿主 `TZ=Etc/GMT+5` ⇒ `TimeZone.getDefault()` 仍给 `Asia/Shanghai`(480)，**不跟**；`-Duser.timezone=Asia/Tokyo` 才改成 540 | `TZ` 是 **Linux/glibc（容器）侧的约定**，Windows 上不生效。本库以它为首要来源，线上跟宿主一致、Windows 开发机上与"JVM 会算出的那个"不一致——本库不调 JVM，所以这是**声明差异不是缺陷**，写在 §8.3 第 5 行免得下一轮当成 bug |

⚠ 探针差点被本机 shell 骗掉一次，记在这儿：**git-bash（MSYS runtime）会把 `TZ` 自家征用，再从子进程环境里摘掉**。同一条 `TZ` 在 git-bash 里 `node -e "process.env.TZ"` 打 `undefined`，换 PowerShell 就是 `Asia/Shanghai`。第一遍探测因此报"三档都读不到 TZ"，那个结论**整条是假的**——判"某个环境量读不读得到"，必须换一个自造的对照变量（`MOLE_PROBE_ZONE`）一起喂，只看目标变量会把工装问题读成平台限制。

### 8.2 公开面九件

| 签名 | 语义 | 边界 / 错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `fallback_zone : String` | 兜底区名 = `"Asia/Shanghai"` | — | — | **本库自订**（§8.3 第 1 行） | 无腿读数；它的两条下游判据有 |
| `default_zone() -> String` | 三级降级的结果：`set_default_zone` 覆盖值 → `TZ` → `fallback_zone` | **恒为表内区名**（`zone_exists` 必真） | 参照走 `TimeZone.getDefault()`，查不到来源 | 每次调用**现读环境变量、不缓存**（§8.3 第 6 行） | 区名认不认由 §5 那张表判；`Etc/GMT+5`=`-300`、`Asia/Kathmandu`=`345` 等仍走腿 P 行 |
| `default_zone_source() -> ZoneSource` | 结果来自哪一级（`FromOverride`/`FromEnv`/`Fallback`） | 与 `default_zone()` 同源，一次降级只能有一个出口 | 参照没有这件——JVM 的默认时区是个查不到来源的全局量 | 这一件的存在就是把"隐式全局量"变成**可查询**的东西 | 本库自订 |
| `set_default_zone(zone) -> Bool` | 显式覆盖，优先级最高 | `false` = 区名不认，**且当前默认区一字不动** | — | 返回 `Bool` 不 `raise`：本库新增一个 `DateError` 变体会让既有穷尽 `match` 当场报缺档，而"设一次配置"给 `raise` 手感也不对（§8.3 第 4 行） | 本库自订 |
| `reset_default_zone() -> Unit` | 撤销覆盖，回到 `TZ` → 兜底那一路 | 未设覆盖时调用是幂等的 | — | 没有它覆盖就不可逆，测试现场与多实例都没法复位 | 本库自订 |
| `now_local() -> DateTime?` | `now_in(default_zone())` | 唯一给 `None` 的成因是**瞬间出表窗**（2050 后） | `DateUtil.date()` / `DateUtil.now()` | 参照吃进程默认时区且没法查来源；本库区名由这一层给、失败通道只剩一条 | 等价式对撞第三批已冻的 `now_at ≡ datetime_in`（腿 W 行） |
| `today_local() -> Date?` | `today_at(default_zone(), clock_system())` | 同上 | `DateUtil.today()`（参照给 `"yyyy-MM-dd"` **串**） | 本库给 `Date` 不给串 | 同上（腿 W 行的 `y-m-d` 列） |
| `format_local(millis, pattern) -> String? raise DateError` | `format_in(millis, pattern, default_zone())` | 出表窗 ⇒ `None`；pattern 表外 token / 字段越界 ⇒ `raise`（§2.6 已冻，本件不改） | `convertTimeZone` + `format` 那条组合 | 两条失败通道的分工**原样继承 §7.2**，本批不重述不改 | 腿 F/G 行的串，逐条搬自 §7 已冻断言 |
| `to_rfc3339_local(millis) -> String?` | `to_rfc3339_in(millis, default_zone())` | 出表窗 ⇒ `None` | §2.11 的默认区版 | 偏移数字仍按**瞬间**查表，同一区两瞬间可给两个偏移（`Asia/Kathmandu` 1970 是 `+05:30`、当下 `+05:45`） | 腿 R 行，逐条搬自 §7 |
| `parse_local(text, pattern) -> Int64? raise DateError` | `parse_in(text, pattern, default_zone())` | 落点出表窗 ⇒ `None`；空洞 ⇒ `raise ZoneGap(iso)`；串/pattern 非法 ⇒ 沿用 §2.7 | 参照的 parse 全族吃默认时区，**没有**这一件 | 重叠档取**转换后那一支**（§7.3 第 2 行）原样继承；空洞仍 `raise` 不并成 `None` | 腿 S 行，逐条搬自 §7 |

`ZoneSource` 写 `pub(all) enum`：本版 `pub enum` 的变体跨包构造不出来（`Cannot create values of the read-only type`），而用例要把这三档取出来当参数比。

### 8.3 六条分岔与本库自订（**没有腿读数的档全部点名，不冒充读数**）

| # | 档 | 参照那一侧 | 本库 | 代价 / 依据 |
|---|---|---|---|---|
| 1 | 兜底值 | JVM 取 OS 时区，取不到再退 `UTC` | 写死 `Asia/Shanghai` | 本库用户全在国内。取 `UTC` 的话，"今日 0 点"在 Windows 开发机（OS 给 +08）与容器（TZ 给 UTC）之间差 **28800000 毫秒 = 8 小时**（本机实测两组数：`1791043200000` vs `1791072000000`）；踩这个坑的概率远高于受益概率 |
| 2 | `TZ` 给了表外值 | `TimeZone.getTimeZone(坏名)` **静默按 GMT** 解析成功（腿 U 行） | 回落 `fallback_zone`，`source` 报 `Fallback` | 与 §5.3 第 1 条**不矛盾**：那条管"调用方显式给的区名"（显式错就给 `None`），这条管"环境给的区名"（回落并如实报来源）。用例把这条钉死——坏名八档各断一次"偏移仍是 480 而不是 0" |
| 3 | POSIX 规则串 / 路径式 `TZ` | glibc 认（`TZ=UTC-8`、`TZ=EST5EDT4` 都能出偏移） | **不收**：`UTC-8`、`/usr/share/zoneinfo/…` 实测都在表外 ⇒ 走 §8.3 第 2 行回落 | 收就得自己实现 POSIX 规则解释器（std/offset/dst/rule 四段），判据立刻从"查表"变成"我算对了没"。代价写明：这类容器上默认区是兜底值，不是宿主真实区 |
| 4 | 覆盖口给坏名 | 参照无此件 | `false` + 不改值 | 留下"设了个坏值"的中间态就等于把 §8.3 第 2 行的静默回落又请回来了 |
| 5 | 与 JVM 的优先级不同形 | Windows 上 JVM 根本不看 `TZ`（§8.1 前提 2） | 一律先看 `TZ` | 本库不调 JVM，也没有 `user.timezone` 这个概念可对齐。开发机上"本库默认区"与"那段 Java 代码的默认区"可能不同——这是**声明差异**，两侧行为都写在这里，不许有人拿它当缺陷修 |
| 6 | 读取时机 | JDK 懒读一次后缓存（`getDefault`/`setDefault` 那对） | **每次现读**，另给 `set_default_zone` 当显式覆盖 | 实测 `set_env_var` 之后立即读得到、`unset` 之后回到 `<absent>`（三档一致）⇒ "每次现读"让环境这一档在测试与生产里都有确定行为，不需要一个"重读缓存"的第四件 |

### 8.4 环境变量档的用例纪律（这批最容易写坏的地方）

1. **每块自带前置**：`reset_default_zone()` + 自己 `set_env_var("TZ", …)` 或 `unset_env_var("TZ")`。
   环境变量是**进程级共享**的（实测第二块 set 的值会留在同一档后续用例里），所以不许依赖块序，也不许有"读当前值再假设"的写法。
2. **期望值一律走同包已冻断言**：`scripts/gen_default_test.py` 从 `zone_test.mbt`（腿 P 行）与
   `format_test.mbt`（腿 F/G/R/S 行）**遍历抽取**，逐条注明来源；抽不到就不出断言，并把它打印成欠账。
   本轮唯一欠账是 `parse_in("…","No/Where")`——表外区名档在默认区下**不可达**（`default_zone` 恒表内），不是缺口。
   手打零条。
3. **真钟那一族只断形状与下界**：`now_local()` / `today_local()` 断"有值 + 年份下界 + 时分秒毫字段范围 +
   两次读钟跨不出 1 天之外"。断"两次读钟的大小关系"是计时依赖，CI 一慢就假红——这条纪律原样继承 §5.5 与第三批。
   可冻的等价式全挂在**毫秒作参数**的那批上（`format_local` / `to_rfc3339_local` / `parse_local` /
   `now_at(zone, clock_fixed(ms))`），这是本批判据的承重位置。
4. **成对判别**（块 10）：同一瞬间换默认区，读数必须跟着换。这条挡的是"把区名吞掉、内部写死一个档"的实现——
   那种实现能让块 9 里恰好被写对的那几区蒙过去，却在 25 对成对夹具上必红。
5. **两条失败通道的优先序（本库自订，不是腿读数）**——`format_local` 与 `parse_local` **相反**，
   因为委托对象的实现次序相反：
   - `format_local`：**窗外先**。`format_in` 第一步查区偏移，窗外直接 `None`，pattern 根本没被编译 ⇒
     `format_local(-1L, "yyyy-MM-dd EEEE")` 给 `None` 而不是 `raise UnknownPatternToken`。
   - `parse_local`：**pattern 先**。`parse_in` 先 `DateTime::parse` 解出墙上时刻，才谈得上落点在不在表内 ⇒
     坏 pattern 一律 `raise`，即使那一瞬间在窗外。
   这一档没有参照读数（参照根本没有"默认区 + 坏 pattern + 窗外"三件同时出现的形状），所以按**设计决定**冻，
   错误形状串一律从首批 §2.6~2.7 与 §7 的已冻断言里搬（生成器 `need_tag` 逐条断言该串真的存在于 `date_test.mbt`，
   搬不到就停）——**不许照实现现编一个错误串**。钉法是把两条通道并进同一个出口
   （`dflt_fmt` / `dflt_parse` 把 `None` 与 `raise X` 都渲染成串），否则 `shape(...)` 只看得到 raise、看不见 `None`，
   优先序这一档就永远测不到。

### 8.5 用例面

18 块 / 373 条冻结期望（`default_test.mbt`；PR-A 那一笔立约时是 15 块 305 条，落地轮补了块 16~18 三条失败通道与优先序档，见 §8.4 第 5 条。立约时 14 块按设计态待落地，块 1「兜底常量与闸门读数」只断常量与既有件、当时就已为真）。
落地后 `moon test --package date` = **131 = 绿 131 / 红 0**（18 个第五批断言块 + 31 首批断言块 + 37 第二批 + 13 第三批 + 12 第四批 + 20 个文档块），
`wasm / js / wasm-gc` 三档逐档一致、零警告；全仓 667 条三档全绿。README 的文档块与 `*_test.mbt` 同受期望值冻结约束。

### 8.6 不收（本批范围内）

| # | 不收 | 理由 |
|---|---|---|
| 1 | `env_zone()`（把"TZ 读出来且表内才算数"单列一件） | `default_zone()` + `default_zone_source()` 已能表达同一件事，多一张嘴就多一处能错 |
| 2 | `TZ` 的 POSIX 规则串档 | §8.3 第 3 行 |
| 3 | 进程级"默认偏移分钟数"（跳过区名直接给 `Int`） | 会绕开 §5 那张表，DST 与历史偏移就没了载体；而且 `now(offset)` 这条显式老路本来就在 |
| 4 | 自动探测宿主时区（读 `/etc/localtime`、调 `Intl`） | §0 的零依赖四条：OS 能力只走 `env`，不引 `read_file`/宿主 API，四档一致立刻破 |
| 5 | MoonBit 官方将来出时区口之后的"跟随宿主" | owner 裁定"后续 moonbit 官方出时区获取方式了，再考虑"。本批把降级链留成一处（`default_zone` 一个函数体），届时只在那里加一级，公开面不动 |

### 8.7 变异计划（PR-B 填读数；隔离副本 + 开局断基线 + 逐条 `finally` 还原 + 写盘 `fsync`/回读 + 收尾字节比对）

| 号 | 变异 | 计划打的档 |
|---|---|---|
| E1 | `default_zone` 里把 env 那一级删掉（只走覆盖→兜底） | 块 3 / 块 5 / 块 8 / 块 9 全部 |
| E2 | 优先级反过来（`TZ` 压过显式覆盖） | 块 6 |
| E3 | 表外值不回落，直接返回原串（等于把坏名交给查表去给 `None`） | 块 4 / 块 14 |
| E4 | 表外值回落成 `UTC`（照抄参照的静默 GMT） | 块 4 的"偏移仍 480"那一半 |
| E5 | `set_default_zone` 忽略返回值、坏名也写进槽 | 块 7 |
| E6 | `reset_default_zone` 不清槽 | 块 8 |
| E7 | 便捷件内部写死 `fallback_zone` 而不调 `default_zone()` | 块 9 非沪区 + 块 10 成对判别 |
| E8 | 便捷件内部写死 `UTC` | 块 9 / 块 11 / 块 12 / 块 10 |
| E9 | `default_zone_source` 与 `default_zone` 各算一遍、允许给矛盾的一对 | 块 3 / 块 6 / 块 8 的 tag 断言 |
| E10 | env 读一次后缓存（后续 set 不生效） | 块 8 的"换 env 立刻跟走" |
| E11 | `ZoneGap` 并成 `None` | 块 13 |
| E12 | `format_local` 把 raise 吞成 `None` | 块 16（落地轮补） |
| E13 | `parse_local` 把 raise 吞成 `None` | 块 17（落地轮补） |
| E14 | `to_rfc3339_local` 的区参数写死兜底值 | 块 18（落地轮补） |
| E15 | 窗外不给 `None` 而给空串 | 块 16 的窗外档（落地轮补） |

**10-07 落地轮实测：十五条全部抓红，零等价、零夹具缺口、零挂载失败**（隔离副本跑；开局先断基线 131/0 才开跑、
逐条 `finally` 还原、写盘 `flush`+`fsync`+回读断言、收尾 sha256 相同并复跑仍 0 红）：

| 号 | E1 | E2 | E3 | E4 | E5 | E6 | E7 | E8 | E9 | E10 | E11 | E12 | E13 | E14 | E15 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 红块数 | 8 | 2 | 2 | 3 | 1 | 10 | 2 | 4 | 3 | 9 | 2 | 1 | 2 | 2 | 2 |

补了块 16~18 之后，E1/E6/E8/E10/E11 的见证块数都涨了（7→8、7→10、3→4、8→9、1→2）——
新增的失败通道档确实在给既有判据加证人，不是凑条数。

⚠ **E15 第一版是"挂载失败"不是"0 红"**：写成 `.unwrap_or("")` 编译不过（错误 4014），变异根本没进代码。
这种"等于没测"若与"0 红"记成同一格，就会被当成"这条判据抓不到"而错误放宽契约。
换成 `match … { None => Some("") … }` 的可编译坏实现后立刻红 2 块。
⇒ 工装汇总从此**分三档报**：抓红 / 0 红（夹具缺口·按构造等价·本层不可达三种处置）/ 挂载失败（必须换写法重打）。

「块红会掩盖块内未跑」是本仓老规矩，所以这里报的是**块数下界**，不是断言级覆盖率——
但每条都至少有一块看着它，没有出现"改了实现而用例全绿"的那种变异。

顺带记一条工装自己踩的坑（同族第四次）：汇总那行原先写成 `"失败" in 结果串`，而每条结果串本来就叫
「红 N 块 / 失败 N 条」，于是把十五条全红的正确读数打印成「0 红条数 15」。判据的关键字撞上自家输出格式，
与 G11 的措辞识别、G12 的宽松前缀、G9 的禁词表三案是同一个形状：**判据要能点名坏情况，先要它不吃自己的输出**。

## 9. 第五批补档（10-08，`date/date_deep5_test.mbt` + `scripts/Iso2Leg.java`）

八块新档，date 未覆盖行 13 → **3**、全仓 158。参照腿的归属先说清：**ISO 那一族用 JDK
`java.time.OffsetDateTime.parse`，pattern 那一族用 `java.text.SimpleDateFormat`**；
**不用 hutool `DateUtil.parse`**——那是"猜测式"多格式入口，既不给位置也不给同一语义，
拿它当参照会把本库这条严格腿的对位物找错。腿的自检同样是"三档互不相同才发 `GUARD_OK`"，
生成侧（本件是手写件，取值档逐条从腿读数抄入）在注释里带着 `I`/`P` 行的编号。

**取值档七条与 JDK 逐条同判**（`.52`⇒520、`.123456`⇒123、`-05:00`、`Z`、`.5Z`、`.523+05:30`、`+00:00`）。
报错档五条钉的是**本库位置口径**（`DateError` 只带读数不带文案，§2 那条），逐档写清参照判不判：

| 输入 | 本库 | 参照（JDK 17 现读） | 谁更严 |
|---|---|---|---|
| `…12:00:00.+08:00`（小数点后零位） | `ParseFailed @20` | **接受** ⇒ `1791345600000` | 本库（RFC 3339 §5.6 `time-secfrac = "." 1*DIGIT`） |
| `…12:00:00Zx` | `ParseFailed @20`（多余字符自己那格） | 拒 `DateTimeParseException` | 同判 |
| `…12:00:00X` | `ParseFailed @19` | 拒 | 同判 |
| `…T12:00-05:00`（缺秒） | `ParseFailed @16` | **接受** ⇒ `1791392400000` | 本库（RFC 3339 的 `second` 必填） |
| `…+24:00` | `ParseFailed @19`（偏移起始格） | 拒 | 同判 |

另有两条**本库多收/少给**的分岔，都带参照原读数：
① 小数分隔符收逗号（ISO 8601 的 `,` 与 RFC 3339 的 `.` 取并集），JDK 对 `…00,52+05:30` 给
`DateTimeParseException`、本库给 `1791354600520`；
② `Date`（纯日期）上出现时间字段判 `UnknownPatternToken`，`SimpleDateFormat` 给 `00:00:00`；
③ 解析侧重复字段判 `UnknownPatternToken`，**格式化侧允许**（腿 P 行 dup 现读 `2026-10-07-2026`，同判）。

**一处推导被真跑打回，两条**：`Z` 之后有尾巴报的位置，第一次按"`Z` 在 20"推成 `@21`，实测 `@20`；
顺带把 `X` 那档也从 `@20` 纠到 `@19`。根因是 `"2026-10-07T12:00:00"` **正好占下标 0..18**，
多出来的那个字符在 19——数下标要在串上逐位数，不能拿"长度 19"当成"下一格是 20 之后的 21"。

剩三行全部给推导，不写"待补"：

- `date.mbt:970`（`write_field` 的 `None => raise UnknownPatternToken`）：**结构上到不了**。
  `format_pattern`（`:935`）的 `allow` 直接由 `time` 推得（`Some(_) => true`），
  而 `check_pattern(pattern, allow, false)` 在 `:914` 就把 `!allow_time && k >= 5` 的全部时间字段判掉，
  所以带 `time == None` 进来又活着走到 `write_field` 的分支不存在。
  本批那条"纯日期上写时间字段"的红落在 `:914/915`，不在 `:970` —— 已在测试注释里点明，免得下轮误认为覆盖。
- `date.mbt:1208`（`frac_millis` 的 `None => 0`）：调用点 `:1150` 的扫描守卫与
  `digit_value` 是同一个谓词 ⇒ 进 `frac_millis` 的 `[start,end)` 全是数字 ⇒ `None` 支不可达。
- `zone.mbt:127`（`seg_last_le` 取不到段）：窗口是 `[tbl_window_lo, tbl_window_hi)` = `[0, 2524608000000)`
  （现读 `zone_table.mbt` 两个常数），窗外在 `:118` 就返回 `None`；窗内 `millis ≥ 0`，
  而**探针实测 603 个区在 `0L` 与 `1L` 两档全部有读数、零个 `None`**（临时件跑完即删）
  ⇒ 每个区的首段都不晚于窗口下沿 ⇒ `k < 0` 在公开面到不了。

变异 9 条 **全部抓红、零等价**（D1 4 红、D9 2 红、其余各 1 红；隔离副本、基线先断 0 红、
每条还原并字节级复验）。也就是说：**变异全抓红不是奖状，是这批每块都是为那档新写的**——
红位与行一一对得上。相反的例子在同日的另三批：conv 5 红 1 等价、ini 6 红 1 等价、codec 6 红 1 等价，
那三条各自撕到"覆盖到但不可判别"（`X6`/`M3`/`C7`，推导分别写在 `09-conv.md` §10、
`22-ini.md` §10、`05-codec.md` §11）——共同点是夹具往既有形状上接，不是为那档新写。

## 9. 计时三件与全局自定义格式表（第六批，10-10 owner 点名"注入"）

> 状态：**第六批契约笔**（本节 + `date/timer.mbt` + `date/between.mbt` + `date/custom_format.mbt` 的
> 签名骨架与冻结期望；函数体是 `abort`，用例此刻红是设计态）。实现笔只许把红变绿。
> 读数来源是本仓新增的五条腿 `scripts/TimerLeg.java`（行族 `W`/`T`/`G`/`F`）、`TimerLeg2.java`（`Z`/`P`）、
> `TimerLeg3.java`（`SH`/`LS`/`NF`/`PC`/`PP`/`FB`/`GF`）、`TimerLeg4.java`（`CU`/`NS`/`TI`/`SN`/`ID`/`EP`）、
> `TimerLeg5.java`（`P5`）；参照代次 5.8.37（口径见 `00-hutool-map.md` 的 `hutool-reference-version`）。

### 9.1 为什么要开这一批：§6.5 第 2 行的就地更正

`§6.5` 那行原先判"单调钟 / 秒表（`DateUtil.timer()`、`StopWatch`、`elapsed`）**不收**"，理由是
"core 只给墙上毫秒、没有可信单调源，硬做就是拿墙上钟假装单调（NTP 往回拨就错）"。
**10-10 owner 裁定改判：做，走注入时钟**（原话"可推；注入"）。前提被新证据推翻的经过要写清：

| 项 | 原判据的前提 | 本批的事实 |
|---|---|---|
| 谁读时钟 | **本库自己去读** ⇒ 只能读到墙上毫秒 ⇒ 承诺不了单调 | 本库**一处都不读**：读数由调用方按 `() -> Int64` 注入。G18 白名单一字未动（现读全仓裸读点仍只有 `date/date.mbt` 的 `now_millis()` 一处），本批新增的每个计时件都只能在拿到钟之后才算差值 |
| 单调性是谁的责任 | 库背 | 注入方背：测试给假钟 ⇒ 读数确定；生产由宿主自己决定拿什么喂（能给单调源就给，给不了就用毫秒钟，本库不冒充） |
| §6.5 第 5 行"不做 `Clock` 结构体抽象" | 仍然成立 | 本批所有构造口吃的都是 `() -> Int64`，没有新增时钟类型 |

一句话：**"没有可信单调源"这条拦的是"库自己读时钟并承诺单调"，拦不住"库不读时钟"**。
改判之后 §6.5 那行从"不收"变成"§9 收了"，原判据里对 `SystemClock` 缓存线程的那半条（第 1 行）不受影响。

### 9.2 时钟从哪来：参照有两套时钟，本库因此有两个构造口

现读字节码（`GroupTimeInterval.getTime()`）：参照按一个 `isNano` 布尔在**两个不同的 OS 时钟**之间二选一，
`StopWatch` 则**恒定**读纳秒钟（它没有开关，字段就叫 `startTimeNanos`/`totalTimeNanos`）。

| 参照时钟口 | 参照里谁在用 | 本库落点 | 为什么不能压成一个参数让调用方"顺手声明" |
|---|---|---|---|
| `System.currentTimeMillis()`（epoch 毫秒、墙上） | `getTime()` 的 `isNano=false` 支；`TimeInterval()` 与 `GroupTimeInterval(false)` 默认档 | `time_interval(clock)` / `group_time_interval(clock)` | 单位决定 `interval_in` 里"要不要先除 1_000_000"那一半判据（腿 `G` 行 + 字节码现读：`isNano` ⇒ `interval(key)/1000000` 再 `÷ unit.millis`）。若做成"一个钟 + 一个布尔"，传错就是**静默差 1e6 倍**且没有任何一档会红；做成两个具名构造口，单位与判据同时定死 |
| `System.nanoTime()`（任意起点、单调） | `getTime()` 的 `isNano=true` 支；`StopWatch` 全部（`start`/`stop` 两处 invokestatic） | `time_interval_nanos(clock)` / `group_time_interval_nanos(clock)` / `stop_watch(clock)` | core 没有纳秒口（§1 头注那条：全树唯一 OS 时钟口是 `env.now()` 的毫秒档）⇒ **本库不自带纳秒真钟**，只收调用方给的读数源。要拿毫秒钟凑纳秒档就得自己乘 `1_000_000`，那等于自愿把分辨率降到毫秒——这条是宿主的选择，不是本库的承诺 |

配套判据（都是腿里与时钟无关的确定档）：

- 两个单位下 `interval` 的**算式相同**（`getTime() - 存档读数`，见字节码 `interval(String)`），
  差别只在单位 ⇒ 差值算术、缺键给 `0`、`interval_restart` 的"先存再减旧值"三档两单位共用一套用例。
- `TimeInterval` 的构造口**必须自动 `start()`**（腿 `Z|Ti.interval@fresh` 给的是小正数而非 0，
  而 `GroupTimeInterval` 的 `interval@empty` 给 `0` ⇒ 差的就是 ctor 里那一次 start；字节码现读
  `TimeInterval(boolean)` 第 6 行 `invokevirtual start:()J`）。参照的默认键是**空串**
  （`private static final String DEFAULT_ID = ""`，字节码 `ldc #6` 现读为空串字面量）。
- 参照的 `TimeInterval(boolean)` 参数名在字节码里是 **`isNano`**（不是 `isMillis`）——
  本机被这条骗过一次：`new TimeInterval(true)` 拿到的是**纳秒档**（腿 `Z|isMillis=true|interval|497100`
  对上毫秒档的 `1`），照着参数名猜"true=毫秒"会把两档的用例全写反。

### 9.3 公开面 · StopWatch / TaskInfo / ChronoUnit

`StopWatch` 的参照三个构造器（`()`、`(String)`、`(String, boolean)`）加一个 `create(String)` 在本库塌成
**一个带标签默认值的构造口**；`create` 与 `new StopWatch(id)` 在参照里是同一件事（字节码现读：`create` 就是 `new StopWatch(String)`）。

| 签名 | 语义 | 边界 / 错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `stop_watch(clock : () -> Int64, id~ : String = "", keep_task_list~ : Bool = true) -> StopWatch` | 秒表。`clock` 给**纳秒**读数（参照 `System.nanoTime()`） | 无 | `StopWatch()` / `StopWatch(String)` / `StopWatch(String,boolean)` / `create(String)` | ① 参照的 `id` 可以真是 `null`（腿 `ID|null-id-summary` 读出 `StopWatch 'null': ...`），本库 `id : String` **构造不出 null 档**；② 参照 `new StopWatch(String)` 的 `keep` 恒 `true`（字节码 `iconst_1` 现读）⇒ 默认值不是猜测 | 腿 `ID` 行 |
| `StopWatch::id(self : StopWatch) -> String` | 表号 | — | `getId()` | 本库恒非空（同上） | — |
| `StopWatch::set_keep_task_list(self : StopWatch, keep : Bool) -> Unit` | 开/关"逐条留存任务" | 无 | `setKeepTaskList(boolean)` | 判据照参照字节码：`true` **只在当前不保留时**新建空表（已保留 ⇒ 空操作、行还在）；`false` 直接把表置 null ⇒ **已经记下的行丢**。来回切一次就能观察到"行没了"（腿 `PP|keep-翻true后-pretty` 表头都在、行是空） | 腿 `PP` 行 |
| `StopWatch::start(self : StopWatch, name~ : String? = Some("")) -> Unit` | 开始一条任务 | 已在跑 ⇒ `raise DateError::TimerAlreadyRunning` | `start()`（= `start("")`）与 `start(String)` | 参照的"是否在跑"判的是 `currentTaskName != null`，所以 **`start(name=None)` 等于什么都没开始**：之后 `is_running()` 恒 `false`、`stop()` 报"没在跑"、`start("real")` 还能进（腿 `SN` 行四档全冻）。本库把参数做成 `String?` 就是为了这条暗档仍然可达 | 腿 `W`/`SN` 行 |
| `StopWatch::stop(self : StopWatch) -> Unit` | 结束当前任务 | 不在跑 ⇒ `raise TimerNotRunning` | `stop()` | 参照把 `总时长 += 末读数-起读数`、`last_task = TaskInfo(名, 差)`、**保留时才追进表**、`task_count += 1`、`current_task_name = null` 五步写死一个顺序；本库照同一顺序（`task_count` 与表长**可以不等**，`keep=false` 那档就是证据） | 腿 `W`/`ID` 行 |
| `StopWatch::is_running(self : StopWatch) -> Bool` | 是否有一条在跑 | — | `isRunning()` | 等价于 `current_task_name() is Some(_)`，参照也是这么判的（字节码 `ifnull`） | 腿 `W` 行 |
| `StopWatch::current_task_name(self : StopWatch) -> String?` | 当前任务名 | 没在跑 ⇒ `None` | `currentTaskName()` | `Some("")` 与 `None` 是两档：无名 `start()` 给 `Some("")`，`start(name=None)` 给 `None`（腿两档读数不同：前者空串、后者 `{null}`） | 腿 `W`/`SN` 行 |
| `StopWatch::last_task_nanos / last_task_millis(self : StopWatch) -> Int64` | 上一条任务的时长 | 没跑过 ⇒ `raise NoLastTask` | `getLastTaskTimeNanos/Millis()` | 参照两条 message 不同（`No tasks run: can't get last task interval`），本库错误面不冻文案 ⇒ **一个变体**（§1 那条"只带读数不带文案"的规则） | 腿 `W` 行 |
| `StopWatch::last_task_name(self : StopWatch) -> String?` | 上一条任务的名 | 同上 `raise NoLastTask` | `getLastTaskName()` | 无名任务给 `Some("")`、`start(null)` 之后给 `None`（腿 `W|lastTaskName@after-stop-unnamed` 是空档不是 ERR） | 腿 `W`/`SN` 行 |
| `StopWatch::last_task_info(self : StopWatch) -> TaskInfo` | 上一条任务整条 | 同上 | `getLastTaskInfo()` | — | 腿 `W` 行 |
| `StopWatch::total_in(self : StopWatch, unit : ChronoUnit) -> Int64` | 总时长按单位取 | 无（不抛） | `getTotal(TimeUnit)` | 参照 = `unit.convert(totalNanos, NANOSECONDS)`，整数**向零截断**（腿 `CU` 行负档为凭：`-999999999` 纳秒 ⇒ 毫秒 `-999`、秒 `0`） | 腿 `CU` 行 |
| `StopWatch::total_nanos / total_millis(self : StopWatch) -> Int64`、`total_seconds(self : StopWatch) -> Double` | 三件便捷读数 | — | `getTotalTimeNanos/Millis/Seconds()` | 秒档参照走 `DateUtil.nanosToSeconds(n)` = `n / 1.0E9`（腿 `NS` 行；契约只取能精确表示的档，不断 `Double` 的十进制外形） | 腿 `NS` 行 |
| `StopWatch::task_count(self : StopWatch) -> Int` | 结束过的任务条数 | — | `getTaskCount()` | **与留存表长解耦**：`keep=false` 时参照计数照加（腿 `keep=false|taskCount|2` 对 `taskInfoLen|ERR`） | 腿 `keep=false` 组 |
| `StopWatch::task_infos(self : StopWatch) -> Array[TaskInfo]` | 留存的任务行（按结束顺序） | 不保留 ⇒ `raise TaskInfoNotKept` | `getTaskInfo()` | 参照抛 `UnsupportedOperationException("Task info is not being kept!")`，本库换成同条件的一个变体；返回**新数组**（参照 `toArray` 也是新数组，改它不影响内部） | 腿 `ID`/`keep=false` 组 |
| `StopWatch::short_summary(self : StopWatch, unit~ : ChronoUnit = Nanoseconds) -> String` | 一行摘要 | 无 | `shortSummary()` / `shortSummary(TimeUnit)` | 模板逐字节冻：`StopWatch '<id>': running time = <total_in(unit)> <shot_name(unit)>`；无参档参照传的是 `null` ⇒ 落到 `NANOSECONDS`（字节码现读 `if_acmpne` 那一支） | 腿 `PP|shortSummary*` |
| `StopWatch::pretty_print(self : StopWatch, unit~ : ChronoUnit = Nanoseconds) -> String` | 对齐表格 | 无 | `prettyPrint()` / `prettyPrint(TimeUnit)` | 排版规则整体见 **§9.7**（四条与时钟无关的判据：补零、百分号舍入、列宽、行分隔符） | 腿 `PP`/`NF`/`PC` 行 |
| `StopWatch::to_string(self : StopWatch) -> String` | `toString()` 那行 | 无 | `toString()` | 百分号档参照走 `Math.round(100.0 × n / total)`（**不是** `prettyPrint` 那套 `NumberFormat`）：向数轴正向取整、NaN ⇒ `0`、不补零（腿 `SN|toString` 与 `PC` 行对照；`total=0` 那档参照给 `= 0%` 而 `prettyPrint` 给 `NaN`，两条都必须复现） | 腿 `SN`/`PC` 行 |
| `pub struct TaskInfo { priv name : String?, priv nanos : Int64 }` | 一条任务读数 | 跨包只读（参照的构造器是**包级私有**） | `StopWatch.TaskInfo` | 参照只有 getter，本库同样不给公开构造口 | — |
| `TaskInfo::task_name(self : TaskInfo) -> String?`、`time_nanos -> Int64`、`time_millis -> Int64`、`time_seconds -> Double`、`time_in(self, unit : ChronoUnit) -> Int64` | 五个读数 | 无 | 同名五件 | `time_millis` = `time_in(Millisecond)`、`time_seconds` = `nanosToSeconds(nanos)`，字节码现读的两条委托关系照抄（腿 `TI` 行逐档对上） | 腿 `TI` 行 |
| `pub(all) enum ChronoUnit { Nanoseconds Microseconds Milliseconds Seconds Minutes Hours Days }` | 秒表用的时长单位（**七档**） | — | `java.util.concurrent.TimeUnit` | 与本包 `TimeUnit`（对位 hutool `DateUnit`，六档、无纳秒/微秒）**刻意分成两个类型**：参照自己就是两个枚举，`getTotal`/`prettyPrint` 吃 junit 那个、`interval(key, unit)` 吃 `DateUnit`。合成一个就要给 `TimeUnit` 加纳秒/微秒档，而那两档一进 `to_millis()` 就承诺了"1 纳秒 = 0 毫秒"这种静默归零。<br>**变体名一律用复数**不是口味：本版编译器对"同包两个枚举撞变体名"直接判 `4124 constructor is ambiguous`（实撞：`@date.Hour` 在 `date_test.mbt` 与 README 块里当场 ambiguous），而参照两侧的名字本来就是 junit 复数（`NANOSECONDS`）↔ hutool `DateUnit` 单数（`SECOND`）——**照参照的命名就自然不撞**，改名只是把这条现读事实落到形状上 | 腿 `SH` 行 + 本机编译器裁决 |
| `ChronoUnit::shot_name(self : ChronoUnit) -> String` | 单位短名 | — | `DateUtil.getShotName(TimeUnit)` | 七档读数全部冻成常量：`ns` / `{u03bc}s`（**U+03BC GREEK SMALL LETTER MU**，不是 U+00B5）/ `ms` / `s` / `min` / `h` / `days`。参照那是 `DateUtil` 上的静态法，本库挂在枚举上（结构层，判据不变）。参照传 `null` 抛 NPE，本库没有这一档（类型到不了） | 腿 `SH` 行 |

### 9.4 公开面 · 计时区间（参照 `GroupTimeInterval` + `TimeInterval` 两面合一）

参照是**继承**：`TimeInterval extends GroupTimeInterval`，加一个固定键 `DEFAULT_ID = ""`（空串）和九个无参便捷法，
其余全继承——所以 `TimeInterval` 的实例在参照里**也能**调 `start("别的键")`（腿 `T|extends-group?start(key)` 就是为这条打的）。
MoonBit 没有继承。本库的做法是**一个类型承载两面**：键参数做成 `id~ : String = ""`，
参照的"无参 = 走 DEFAULT_ID"因此就是同一件法的默认值档，两个参照类的公开面一次覆盖，
判据只有一套（不留第二套算法）。

| 签名 | 语义 | 边界 / 错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `group_time_interval(clock : () -> Int64) -> GroupTimeInterval` | 毫秒档分组计时器 | 无 | `GroupTimeInterval(false)` | 参照的 `groupMap` 是 `SafeConcurrentHashMap`（并发安全）；本库全同步，**不承诺并发可见性** | 字节码 ctor |
| `group_time_interval_nanos(clock : () -> Int64) -> GroupTimeInterval` | 纳秒档 | 无 | `GroupTimeInterval(true)` | 同上；单位由构造口定，不再暴露布尔（§9.2） | 腿 `Z` 行两组 |
| `time_interval(clock : () -> Int64) -> GroupTimeInterval` | 毫秒档 + **构造即 start 空键** | 无 | `TimeInterval()` | 参照返回的是子类实例；本库返回同一类型 ⇒ 类型层面的父子区别消失，行为区别（预启动）保留 | 腿 `Z|Ti.interval@fresh` 对 `G.interval@empty` |
| `time_interval_nanos(clock : () -> Int64) -> GroupTimeInterval` | 纳秒档 + 预启动 | 无 | `TimeInterval(true)` | 同上 | 腿 `Z` 行 |
| `GroupTimeInterval::start(self : GroupTimeInterval, id~ : String = "") -> Int64` | 给某键记起点，返回**那次读数** | 无（重复 start 就是覆盖） | `start(String)` / `TimeInterval::start()` | 键存在 ⇒ 覆盖旧读数，无"重复 start 报错"这种档（参照就是把同一个 key `put` 两次；腿 `G|start(k1) again` 照样给数）。返回值是**原始读数**不是差值：毫秒档就是 epoch 毫秒（腿 `T|start||#`，本库用假钟把它冻成确定值） | 腿 `G`/`T` 行 |
| `GroupTimeInterval::restart(self : GroupTimeInterval, id~ : String = "") -> Unit` | 重新起表（参照 `TimeInterval::restart()`） | 无 | `TimeInterval::restart()` | 参照返回 `this` 供链式；本库返回 `Unit`（引用语义下不需要链式）——本包**不承诺链式** | 腿 `T|restart` |
| `GroupTimeInterval::interval(self : GroupTimeInterval, id~ : String = "") -> Int64` | 从起点到此刻的差（原单位） | **键不存在 ⇒ `0`**（不抛、不 None） | `interval(String)` / `TimeInterval::interval()` | 参照字节码现读：先 `map.get`，`null` 就 `lconst_0; lreturn`。"没记过"与"记了但正好 0"两档在公开读数上**不可区分**，这是参照行为不是笔误 | 腿 `G|interval@empty`、`Z|G.interval-unstarted`、`T|interval(unknown-key)` |
| `GroupTimeInterval::interval_restart(self : GroupTimeInterval, id~ : String = "") -> Int64` | 算差**并**把起点推到此刻 | 键不存在 ⇒ 返回**那次读数本身**（不是差） | `intervalRestart(String)` | 参照 = `t - defaultIfNull(map.put(key, t), 0)` ⇒ 未记过的键拿到的是原始读数（毫秒档就是 epoch 毫秒，是个巨大的数）。腿 `Z|Ti.intervalRestart@fresh|2` 那条是因为 ctor 已经 start 过；本库用假钟把"未记过"这一档冻成确定的大数 | 字节码 + 腿 `G|intervalRestart` |
| `GroupTimeInterval::interval_in(self : GroupTimeInterval, unit : TimeUnit, id~ : String = "") -> Int64` | 按单位取差 | 键不存在 ⇒ `0` | `interval(String, DateUnit)` | 算式两步：纳秒档先 `÷1_000_000` 换成毫秒，再 `unit` 非 MS 时 `÷ unit 的毫秒数`；两次都是**向零截断**。`unit == MS` 那一支参照直接返回（等价于 `÷1`，本库不重复除） | 腿 `G|interval(k1,MS/SECOND)` |
| `interval_ms / interval_second / interval_minute / interval_hour / interval_day / interval_week(self, id~ : String = "") -> Int64` | 六档便捷读数 | 同上 | 同名六件 | 全部委托 `interval_in`（参照也是这么委托的，字节码现读六处 `interval(String,DateUnit)`）⇒ 不留第二套算法 | 腿 `G|intervalMs/Second/Minute/Week` |
| `GroupTimeInterval::interval_pretty(self : GroupTimeInterval, id~ : String = "") -> String` | 差值说成中文时长 | 键不存在 ⇒ `0` ⇒ `0毫秒` | `intervalPretty(String)` / `TimeInterval::intervalPretty()` | 参照 = `DateUtil.formatBetween(intervalMs(id))` ⇒ 本库 = `format_between(interval_ms(id~))`，**中间量已经是毫秒**，所以纳秒档在这里已经除过一次 1e6 | 腿 `Z|Ti.intervalPretty@fresh`、`FB` 行 |
| `GroupTimeInterval::clear(self : GroupTimeInterval) -> Unit` | 清空所有键 | 无 | `clear()`（参照返回 `this`） | 参照是 `map.clear()`，**不重建 map**；本库同样只清。链式那半条不承诺（同 `restart`） | 腿 `G|clear then interval` |
| —（不挂载） | 参照 `interval(null)` / `intervalPretty(null)` 抛 NPE | — | 同左 | MoonBit 的 `Map` 键不能是 null ⇒ **这条臂在本库结构上到不了**，不预留、不写"等价处理" | 腿 `Z|G.interval-null-key` 四条 ERR |

### 9.5 公开面 · `format_between`（`interval_pretty` 的唯一依赖）

参照链：`intervalPretty(id)` → `DateUtil.formatBetween(long)` → `new BetweenFormatter(ms, Level.MILLISECOND).format()`
（**字节码现读**：一参版传的就是 `Level.MILLISECOND`，不是 `DAY`——腿 `FB` 行里 `3600000` 一参给"1小时"而 `DAY` 档给"0天"，
这条就是它的对质）。`BetweenFormatter` 那个类本身（`Level` 五档、`levelMaxCount`、`separator`、`levelFormatter`）
**仍挂 gap**，本批只收它默认那条路（census 理由已就地改成这句）。

| 签名 | 语义 | 边界 / 错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `format_between(millis : Int64) -> String` | 时长毫秒数 → 中文串（`1天2小时3分钟4秒5毫秒` 那种，无分隔符） | 无抛错 | `DateUtil.formatBetween(long)` | 见下面三条判据；本库只出这一档（不带 `Level`、不带分隔符、不带条数上限） | 腿 `FB` 行 23 档 |

三条判据（逐条都有腿读数兜着，不是从参照源码"看着像"推的）：

1. **`millis <= 0` 一律 `0毫秒`**（腿 `FB|-1`、`FB|-1000`、`FB|-86400000` 三条全给 `0毫秒`）。
   根因在参照字节码第一行：`betweenMs > 0` 不成立就整段跳过，落到"表空 ⇒ 补 `0` + 当档名"那一步。
   ⇒ 负数**不是**带符号的时长，也不是绝对值。
2. **零值档整段跳过**，最后一个非零档之后不再补零；一个都没进去 ⇒ 补 `0` + 档名。
   证据：`604801000` ⇒ `7天1秒`（中间的 0 小时 0 分**不出现**，但秒出现）；`3600001` ⇒ `1小时1毫秒`；
   `86399999` ⇒ `23小时59分59秒999毫秒`（天为 0 ⇒ 不出现，后面的都出现）。
3. **五个档的算法是"逐级借位"不是"取模"**：参照字节码里 `hours = ms/HOUR - days*24`、
   `minutes = ms/MINUTE - days*24*60 - hours*60`、`seconds = ms/SECOND - 累计秒`、`millis = ms - 累计秒*1000`，
   全是**向零截断**的除法再相减。本库照这个算式（不是 `%`），因为两者在非负输入上同值、
   在 `Long.MAX_VALUE` 这种边界上才能证明没多算：`9223372036854775807` ⇒
   `106751991167天7小时12分55秒807毫秒`（腿 `FB` 行原样），天那一档必须用 `Int64`，装不进 32 位 `Int`。

五个档名是常量（腿 `FB|level-name-*`）：`天` `小时` `分` `秒` `毫秒`；分隔符默认空串（参照在末尾会
`delete` 掉多挂的那一段，本库没有分隔符那一步 ⇒ 不需要，也不承诺可配）。

### 9.6 公开面 · 全局自定义格式表（参照 `GlobalCustomFormat`）与它的挂载点

参照那张表是**进程级静态**，且**两张表不对称**——现读 `isCustomFormat` 只查 formatter 表：

| 现读事实（腿 `P5`/`GF` 行） | 后果 |
|---|---|
| 只 `putParser("#ponly", …)` ⇒ `isCustomFormat("#ponly")` 是 `false` | `DateUtil.parse`/`format` 的挂载点被这个判据挡住，**根本不去查 parser 表**：`DateUtil.parse(x,"#ponly")` 反而拿它当 SimpleDateFormat 图案 ⇒ `IllegalArgumentException: Illegal pattern character 'p'` |
| 只 `putFormatter("#fonly", …)` ⇒ `isCustomFormat` 是 `true`，而 parser 表里没有 | `DateUtil.parse("F1700000000123", "#fonly")` 给**当前时刻**（腿里带 `(是不是现在?true)` 的自证），根因是 `new DateTime((Date) null)` 在 hutool 里取 now；而 `GlobalCustomFormat.parse` 自己给 `null` |
| `DateUtil.format(date, pattern)` 的第一道闸是 `date == null \|\| isBlank(pattern)` ⇒ `null` | 空串/空白图案**永远到不了这张表**：腿里我把 formatter 表 `""` 键注册成 `"EMPTY"`，`DateUtil.format(d,"")` 仍然给 `{null}` |

⇒ 本库的注册表**照抄两张表 + 只查前者**这条不对称，不"顺手统一"（统一了就改了挂载行为）。
"进程级暗全局"这一条按本包既有口径处理：**显式 set、显式 reset**（同 `set_default_zone`/`reset_default_zone`）。

| 签名 | 语义 | 边界 / 错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `custom_format_seconds : String` = `"#sss"`、`custom_format_milliseconds : String` = `"#SSS"` | 两档内置键的常量 | — | `FORMAT_SECONDS` / `FORMAT_MILLISECONDS` | 值由腿现读，不手抄 | 腿 `GF|FORMAT_*` |
| `is_custom_format(key : String) -> Bool` | 这个键在**formatter 表**里吗 | 无抛错 | `isCustomFormat(String)` | 参照传 `null` 抛 NPE（键不可为 null）⇒ 本库类型到不了；大小写**敏感**（腿：注册 `#MiX` 之后 `isCustomFormat("#mix")` 是 `false`） | 腿 `GF`/`P5` 行 |
| `set_custom_format(key : String, fmt : (Int64) -> String) -> Unit` | 登记/覆盖一个键的格式化 | 无 | `putFormatter(String, Function<Date,String>)` | 参照的入参是 `Date`，本库是 **epoch 毫秒 `Int64`**（`Date` 在参照里也只被 `getTime()` 用了一次） | 腿 `GF|override-*` 三档 |
| `set_custom_parser(key : String, parser : (String) -> Int64 raise DateError) -> Unit` | 登记一个键的解析 | 无 | `putParser(String, Function<CharSequence,Date>)` | 参照返回 `Date`，本库返回毫秒；参照的 `Function` 抛的是 unchecked（`NumberFormatException`/`ArithmeticException`），本库换成 `DateError` 两档（见 `custom_parse` 那行） | 腿 `P5|pair` 三档 |
| `custom_format(millis : Int64, key : String) -> String?` | 直接查 formatter 表算串；**未登记 ⇒ `None`** | 不抛（用户闭包自己抛的除外） | `format(Date, CharSequence)` | 参照未登记给 `null`（腿 `GF|format(d,plain)`），本库 `None` 同档 | 腿 `GF|format(d,#sss/#SSS)` |
| `custom_parse(text : String, key : String) -> Int64?` | 直接查 parser 表；**未登记 ⇒ `None`** | 坏数字 ⇒ `raise NotAnInteger(text)`；`#sss` 档 `×1000` 溢出 ⇒ `raise MillisOverflow(text)` | `parse(CharSequence, String)` | 参照两档分别抛 `NumberFormatException`（message 带原串）与 `ArithmeticException: long overflow`，本库换成携带原串的两个变体 | 腿 `GF|parse(...)` 12 档 + 腿 `P5|overflow臂` |
| `reset_custom_format(key : String) -> Unit` | 撤销登记：内置两档**复原**、自定义键**删除** | 无 | —（参照没有删除口） | 本库自订档，理由同 `reset_default_zone`：没有它，一次注册就不可逆，测试现场也无法复位。**代价如实写**：它是进程级可变状态，同进程内跨用例可见 ⇒ 用例必须自己收尾（§9.8 第 4 行） | 本库形状 |
| 挂载点：`format_in` 与 `parse_in` **两处**（`format_local`/`parse_local` 是它们的薄封装，现读 `zone_default.mbt` 的体子就是 `format_in(..., default_zone())` / `parse_in(...)` ⇒ 一处挂载自动作用到四件，不留两套判据） | 命中就用表里的闭包，**区名不参与** | 与四件各自的既有档不冲突（命中时不查表、不校验 pattern token、不查区名） | `DateUtil.format(Date,String)` 与 `DateUtil.parse(CharSequence,String,Locale)` 两处胶水 | 只挂这两个闸（吃**瞬间**的门面件）。**不挂** `Date::format`/`Date::parse`/`DateTime::format`/`DateTime::parse`：参照的挂载点全部要求手上有"瞬间/Date"，`#sss` 的定义就是 `floorDiv(getTime(),1000)`（腿字节码现读 `Math.floorDiv`），墙上值件里没有这个量；参照里与之对应的那两件（`LocalDateTimeUtil.format` 不查表、`LocalDateTimeUtil.parse` 要经 `ZoneId.systemDefault()` 把瞬间折回墙上值）本库都不复制那条默认区依赖 | 腿 `F` 行 + 挂载点现读（三处调用者：`DateUtil.format`、`DateUtil.parse`、`LocalDateTimeUtil.parse`） |
| 内置两档的算法 | `#sss` ⇒ `十进制(floorDiv(millis, 1000))`；`#SSS` ⇒ `十进制(millis)` | 与区名/宿主 locale 无关 | 同左 | **`floorDiv` 不是 `/`**：`-999` 毫秒参照给 `-1`（向零截断会给 `0`），`-1001` 给 `-2`（腿 `EP` 行三档齐）——与本包 §0.3"epoch 除法向下取整"同族 | 腿 `EP` 行 |
| 内置 `#sss` 解析 = `multiplyExact(parseLong(text), 1000)` | 溢出**必抛**（`9223372036854775` ⇒ 溢出；`9223372036` ⇒ `9223372036000` 通过） | 见 `custom_parse` 那行 | 同左 | MoonBit 的 `Int64` 乘法溢出是**静默回绕**（AGENTS 里 conv 轮那条），所以本库必须自己判溢出再 raise，不跟回绕 | 腿 `P5|overflow臂` |
| `parseLong` 那侧的接受集：收 `+` 前缀、收负号、收 `-0`，**不 trim**、不收小数、不收空串、不收超 `long` 范围的纯数字串 | 六档全 ERR（`1.5`/`""`/`abc`/` 1700000000`/`1700000000 `/`99999999999999999999`） | — | `Long.parseLong` | 参照 message 里带原串（`For input string: " 1700000000"`），本库变体携带的就是那个原串 | 腿 `GF|parse(...)` |

### 9.7 `pretty_print` 的排版规则：四条与时钟无关的判据

参照那一段排版全靠 `java.text.NumberFormat` 与 `FileUtil.getLineSeparator()`，四条都能脱离时钟冻结：

| # | 判据 | 参照怎么做 | 本库 | 读数来源 |
|---|---|---|---|---|
| 9.7.1 | **数字列补零到 9 位** | `NumberFormat.getNumberInstance()` + `setMinimumIntegerDigits(9)` + `setGroupingUsed(false)` ⇒ 任意值都出**恰好 9 个数字**（`0` ⇒ `000000000`，`1234567890` ⇒ 十位不截断）；负数把符号放在补齐**之前**：`-1` ⇒ `-000000001` | 同形状，自己补（core 没有 NumberFormat） | 腿 `NF` 行 12 档 |
| 9.7.2 | **百分号档：×100 后 HALF_EVEN 取整、最少 2 位** | `NumberFormat.getPercentInstance()` + `setMinimumIntegerDigits(2)`；`maxFrac=0`、舍入模式现读 `HALF_EVEN` ⇒ `0.005`→`00%`、`0.006`→`01%`、`0.015`→`02%`、`0.025`→`02%`、`0.999`→`100%`、`2/3`→`67%`；`NaN` ⇒ **`NaN`（连 `%` 都不出）**、`±∞` ⇒ `∞%` / `-∞%`（U+221E） | 比值用 `Double` 除（照参照的 `time/total`）、乘 100、自写 HALF_EVEN、补到 2 位；`NaN`/`±∞` 两档照出 | 腿 `PC` 行 30 档 |
| 9.7.3 | **列宽是字面空格，不是格式符** | 表头 = `shot_name` + 9 个空格 + `%` + 5 个空格 + `Task name`；数据行 = 9 位数字 + 2 空格 + 百分号 + 3 空格 + 任务名；分隔行 **45 个连字符**，共两行、整表 5 行（无任务时也是 5 行，只是没有数据行） | 逐字节照抄（腿 `PP|header-seg`、`PP|dash-len`） | 腿 `PP` 行 |
| 9.7.4 | **行分隔符参照吃平台** | `FileUtil.getLineSeparator()` = `System.lineSeparator()`，本机现读 `\r\n` | **本库恒 `\n`**，不跟随宿主；差异写在这里而不是藏在实现里（ini 轮同一招：`PrintWriter.println` 那侧也是平台量） | 腿 `LS` 行两条 |

还有一条必须明写的**参照不确定性**（不是本库的取舍）：9.7.1/9.7.2 那两个 `NumberFormat` 实例都是
**默认 locale** 的，同一条腿换 locale 再跑，读数会变（本机四打，复跑命令写在 `scripts/TimerLeg3.java` 头部）：

| locale | 数字列 | 百分号 |
|---|---|---|
| `zh_CN`（本仓取数档）/ `th_TH` | ASCII 补零 | `50%` |
| `de_DE` | ASCII 补零 | `50{u00a0}%`（`%` 前一个不换行空格） |
| `ar_SA` | `{u0660}{u0661}…` 阿拉伯-印度数码 | `{u0665}0{u066a}{u061c}`（百分号换成 U+066A，尾后还挂 U+061C 方向标记） |

⇒ 本库**恒给 `zh_CN`/root/en 那一档的 ASCII 形状，不跟随宿主 locale**（`short_summary`/`to_string` 三档本来就相同，
它们走 `Long.toString` + `StrUtil.format`，不经 `NumberFormat`）。这是"参照实现不确定 ⇒ 整支不跟随"那条老口径，
不是本库做不到 locale。

### 9.8 不收（本批范围内）

| # | 不收 | 理由（都有现读依据） |
|---|---|---|
| 1 | `BetweenFormatter` 的四件可配旋钮（`Level` 五档、`levelMaxCount`、`separator`、`levelFormatter`） | `interval_pretty` 只用默认那条路；`Level`/`isLevelCountValid` 的字节码已读（腿 `FB` 行五档并排就是它的行为表），但把它做成公开面 = 本库要另立一个枚举 + 三个 setter，而 census 里 `BetweenFormatter` 那行仍该挂 gap（理由已就地改成"只收默认路"） |
| 2 | `DateUtil.formatBetween(Date, Date[, Level])` 那三档双日期入口 | 本库没有 `Date` 值类型上的"瞬间对"表示，两个瞬间的差由 `between`/`difference`（§2.9）出数值，要串就 `format_between(between(..., Millisecond))` |
| 3 | 纳秒真钟、单调性承诺 | core 无纳秒口；§9.1 已把这条责任交给注入方。本库**不**提供 `clock_system_nanos()` 之类的伪件（拿毫秒 ×1e6 冒充纳秒是"假装单调"的同一族问题） |
| 4 | 进程级注册表的并发可见性与"谁改了"审计 | 参照用的是 `SafeConcurrentHashMap`（线程安全）；本库全同步、且 `Map` 不承诺跨线程可见。测试的收尾纪律写进用例：**每个碰过 `set_custom_*` 的用例必须自己 `reset_custom_format`**，否则同包后续用例读到的是一张被上一支改脏的全局表（这类"用例互盖"在 §6.3 那条 `Ref` 槽反例里已经付过一次学费） |
| 5 | `TimeInterval`/`GroupTimeInterval` 的父子类型区别、以及 `StopWatch` 的 `null` id 与 `interval(null)` 两条 NPE 臂 | MoonBit 没有继承（§9.4 用"键参数默认值"一次覆盖两面）；类型里不存在 null ⇒ 那两条臂**结构上到不了**，不预留 `Option` 参数去模拟 Java 的 null。`start(name=null)` 那一档**保留**（它是真行为，不是 null 噪声，腿 `SN` 行四档为凭） |
| 6 | `DateUtil.parse` 在"注册了 formatter、没注册 parser"时给**当前时刻**那条 quirk | 根因是 hutool 的 `new DateTime((Date) null)` 取 now（腿 `P5|formatter-only|DateUtil.parse` 带自证 `(是不是现在?true)`）。本库挂载点在这一档给 `None`：`parse_*` 的返回类型是 `Int64?`，把"读一次墙钟"塞进解析失败档会同时违反 §6.4 那条"不写计时依赖"与本批"库不读时钟"的立身前提。**分岔明写，两侧读数都留** |
| 7 | `GlobalCustomFormat.format(TemporalAccessor, CharSequence)` 那一支 | 参照它经 `DateUtil.date(temporalAccessor)` 折成瞬间，`LocalTime` 那档实测连**今天的日期**都要读（腿 `GF|format(LocalTime,#sss)|1791565323` 两次跑不同）；本库无 Java-time 类型，且这一支会读墙钟 ⇒ 不复制 |
| 8 | `LocalDateTimeUtil.parse(text, "#sss")` 那条挂载 | 参照挂载点现读存在（`isCustomFormat` 三处调用者之一），但它把注册表拿到的瞬间按 `ZoneId.systemDefault()` 折成墙上值（腿 `EP|LocalDateTimeUtil.parse(#sss)` ⇒ `2023-11-15T06:13:20`，+08 是这台机器的默认区）⇒ 与 §0.1"偏移一律显式"冲突，不跟随 |

### 9.9 五条腿各打哪几档（哪几档刻意是掩码，不许进契约）

| 腿 | 行族 | 性质 | 用法 |
|---|---|---|---|
| `TimerLeg.java` | `W`/`T`/`G`/`F` | **混合**：状态机、抛错臂、表内容是确定档；一切时长数字用 `mask()` 掩成 `#` | 确定档直接进契约；`#` 档只作"形状在此"的证据，值一律由本库的**假钟用例**出 |
| `TimerLeg2.java` | `Z`/`P` | 零档打**原值**（本就是确定的 0 或 ERR），宽度档用逐位换 `0` 的保长度掩法（前导空格才看得见） | 零档进契约；宽度档只喂 §9.7.3 的列宽判据 |
| `TimerLeg3.java` | `SH`/`LS`/`NF`/`PC`/`PP`/`FB`/`GF` | 全确定档：`NF`/`PC` 是**直接喂选定数**给 `NumberFormat`，不绕 `prettyPrint` | §9.7.1/9.7.2 的 30+12 档、§9.5 的 23×6 档 `formatBetween`、§9.6 的 `GF` 组 |
| `TimerLeg4.java` | `CU`/`NS`/`TI`/`SN`/`ID`/`EP` | 全确定档：`TimeUnit.convert` 截断表、`nanosToSeconds`、反射构造 `TaskInfo` 喂选定纳秒、`start(null)` 暗档、`null` id 模板、负 epoch 的 `#sss` | §9.3 的六行、§9.6 的截断方向 |
| `TimerLeg5.java` | `P5` | 全确定档（除那条自带 `(是不是现在?true)` 自证的 quirk） | §9.6 表格第一段的不对称三档 |

**计时依赖的处置纪律**（沿用 §5.5/§6.4/#C 系列，本批没有例外）：腿里凡是"跨宿主、跨负载的时长数字"
一律不进契约，本库侧对应改成**假钟显式读数**——注入 `() -> 5_000_000_000L` 恒定值 ⇒ 差值、单位换算、
百分号、补零、`NaN` 与 `∞` 五档全部变成可冻的确定值。判据两条：① 用例里不出现 `clock_system()`；
② 用例里不出现"两次读时钟之间比大小"这种断言（本包 `Int64` 档不承诺单调，见 §6.4 第 ② 条）。

### 9.10 变异计划（PR-B 填读数；隔离副本 + 基线先断 0 红 + 按 fmt 后文本找锚点 + `finally` 还原 + 收尾字节比对）

| # | 变异（打在实现哪一行） | 期望被破坏的判据 |
|---|---|---|
| T1 | `stop()` 里 `task_count` 与留存表**同一来源**（计数改成 `kept.length`） | §9.3 那条"`task_count` 与表长解耦"（`keep=false` 那档必红） |
| T2 | `interval` 的"键不存在"改成 `raise` 或 `Option` | §9.4 判据第 1 条（参照给 `0` 且不抛） |
| T3 | `interval_in` 去掉"纳秒档先除 1e6"那一步 | 纳秒档的 `interval_ms` 会大 1e6 倍 |
| T4 | `interval_restart` 的 `defaultIfNull(旧值, 0)` 改成"键不存在就返回 0" | §9.4 那一行的"未记过 ⇒ 拿到原始读数"档 |
| T5 | `format_between` 的负数档改成取绝对值 | §9.5 判据 1（三条负档全给 `0毫秒`） |
| T6 | `format_between` 里"零值档照打"（去掉 `> 0` 判据） | `7天1秒` / `1小时1毫秒` 两条 |
| T7 | `pretty_print` 的数字列改成不补零（`to_string` 直出） | §9.7.1 |
| T8 | 百分号舍入从 HALF_EVEN 换成"四舍五入"（`>= 0.5` 进位） | 腿里 `0.005`→`00%`、`0.015`→`02%`、`0.025`→`02%` 三条平局档 |
| T9 | `to_string` 的百分号从 `Math.round` 换成复用 `pretty_print` 那套 NumberFormat 规则 | `= 100%` 与 `NaN` 两档（参照两族混用是本批最容易"顺手统一"的地方） |
| T10 | `#sss` 格式化用 `/`（向零截断）替 `floorDiv` | §9.6 最后一行：`-999` ⇒ 参照 `-1`、向零给 `0` |
| T11 | `is_custom_format` 改成"两张表任一命中" | §9.6 的 `parser-only` 三档（挂载点行为会变） |
| T12 | 注册表命中时**继续**校验 pattern token | 腿 `F` 行：注册后 `DateUtil.format` 走的就是表，普通档不受影响那条 |
| T13 | `start(name=null)` 当"未传名字"处理（等同 `Some("")`） | §9.3 那条暗档四连（`is_running` 恒 false 等） |
| T14 | 行分隔符跟随宿主（本库恒 `\n`） | §9.7.4：用例是逐字节比串，跟随宿主在 CI 上会整片红 |

计划先挂在这里；实际抓红/等价与否的读数**由 PR-B 那笔如实回填**（空变异要照记，`rand`/`dfa` 两轮的先例）。
