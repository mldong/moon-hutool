# 契约 03 · date（日期时间）

> 状态：**首批已收口（10-05）· 第二批契约已冻结（10-06，§5 那 8 块现在是设计态红）**。
> 首批实现在 `date/date.mbt`，公开接口在 `date/pkg.generated.mbti`（契约先行到落地 **`.mbti` 零漂移**——
> 公开签名一字未动），首批期望值在 `date/date_test.mbt` 与 `date/README.mbt.md`：47 条读数在
> wasm / js / wasm-gc 三档一致，native 档由 CI 出证。第二批的数据与期望在 `date/zone_table.mbt` 与
> `date/zone_test.mbt`，两件都是生成件（`scripts/gen_zone_table.py`）。
> 改任何期望串须单独一笔并给出外部读数来源（门禁 G5）；首批落地那一笔**期望串一字未改**，
> 改掉的是一处实现算错（两位年窗口 `70..99` 那档）。
>
> core **没有任何时间能力**：没有 `time`/`date`/`calendar` 包，全树 `grep ZonedDateTime|Instant|calendar|weekday|leap_year`
> 在非测试代码命中 0（本机 `G:\dev-tools\moon\lib\core` 实测）。能借的只有 `env.now()`（epoch 毫秒）。
> ⇒ 本包整包自研，也是本库最大的一处"从无到有"。
>
> **本包没有 core 对拍腿**（门禁 G8 那条腿在这里天然为空）：没有可对照的 core 函数。唯一的 core 接触点是
> `now_millis()` 里的 `env.now()`，它返回 `UInt64`、且 js/wasm 档语义由宿主给，不能拿来做期望值——
> 所以本包的用例一律吃显式注入的值，只有 #2.10 那一格碰墙上时钟（做法见该节）。

## 0. 四条贯穿性规则（先定死，再谈逐个函数）

| # | 规则 | 为什么必须这么定 |
|---|---|---|
| 0.1 | **偏移一律显式**：`DateTime` 是墙上时钟，不带偏移；"瞬间 ↔ 墙上时钟"的换算显式吃 `offset_minutes`，新增的命名时区入口则显式吃**区名** | hutool/JDK 靠进程默认时区（`TimeZone.getDefault()`）。那是个隐式全局量：同一份代码在两台机器上给出不同的 `begin_of_day`。本库零依赖，索性把"在哪算"做成必填参数。<br>**10-06 第二批就地更正**：这一行后半句原先写的"不做命名时区、也因此没有 DST 歧义"**已被 §5 推翻**——本库现在自带一张 IANA 段表，命名时区与 DST 都收，而 `zone_offsets_at_wall` 的 0 / 1 / 2 三档正是"墙上时刻可以对应多个瞬间"的正面承认。"不跟随进程默认时区"这一半没变，变的是一整块能力从"不做"挪到"做了"。（当时那句是按"零依赖就装不下 tzdb"推的，现读发现参照代次自己就是完整的 tzdb，展开成段存下来并不需要 FFI） |
| 0.2 | **proleptic Gregorian + 天文纪年**：1582-10-15 之前照公历规则往前推，且存在公元 0 年（= 公元前 1 年） | JDK `GregorianCalendar` 默认有 1582-10-15 切换点（之前按儒略历），同一个 `epoch_days` 会算出不同日期；切换点前后的历史日期对工具库没有价值，规则一致才有可复现的期望值 |
| 0.3 | **向下取整**：epoch 相关的除法/取模一律向下取整（floor） | 本版编译器的 `/` 与 `%` 对负数**向零截断**（本机实测 `-5 % 100 = -5`、`-1000L / 86400000L = 0`）。不自己造 floor 档，`-1L` 毫秒就会算成 1970-01-01T-00:00:00 这一类坏读数。用例 #2.5 与 #2.6 各钉一档 |
| 0.4 | **pattern 是封闭子集**：表外字母显式 `raise`，不当字面量吞掉 | hutool `FastDateFormat`（真上游 Apache Commons Lang3）未识别的字母按其规则原样输出，拼错 `EEEE` 会静默变成字面量 `EEEE` 出现在报表里。本库宁可让它在第一次调用就炸 |

## 1. 类型与错误面

| 签名 | 语义 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 | 血统 |
|---|---|---|---|---|---|---|
| `pub struct Date { year : Int, month : Int, day : Int }` | 公历日期，不含时间、不含时区 | 非法日期**构造不出来**：只有 `of`/`from_epoch_days`/`parse` 三个入口 | `cn.hutool.core.date.DateUtil` 的 `DateTime`（本质是 `java.util.Date`） | Java 的 `Date` 是"瞬间"，本库的 `Date` 是"日历日"；瞬间由 `Int64` epoch 毫秒表示 | proleptic Gregorian | — |
| `pub struct DateTime { date : Date, hour : Int, minute : Int, second : Int, milli : Int }` | 某偏移下的墙上时刻 | 字段由 `of` 校验范围；跨包**只读不可构造**（编译器判 read-only type） | hutool `DateUtil`/`CalendarUtil` 的返回体 | 不带偏移、最细到**毫秒**（core 的 `env.now()` 就是毫秒档，没有微秒/纳秒） | — | — |
| `pub(all) enum TimeUnit { Millisecond Second Minute Hour Day Week }` | 固定长度单位 | **刻意没有 `Month`/`Year`** | hutool `DateUnit`（`MS/S/MINUTE/HOUR/DAY/WEEK`） | hutool 的 `DateUnit` 也只有固定长度档，一致；月/年走 `add_months`/`add_years` | — | — |
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
| `Date::weekday(self) -> Int` | 1970-01-01→4、2026-10-04→7、2026-10-05→1、2024-02-29→4、0001-01-01→1、-0045-01-01→6 | 恒返 1..7 | `DateUtil.dayOfWeek` 返回 `Calendar.DAY_OF_WEEK`（**周日=1**） | 本库取 ISO 8601：**周一=1 … 周日=7**。选 ISO 是因为它与 `week_of_year`、`begin_of_week` 同一套口径，且不需要 `Locale` | `(epoch_days + 3) mod 7 + 1`，mod 取**向下**；与 Python `date.isocalendar()[2]` 逐条核对 |
| `Date::is_weekend(self) -> Bool` | 2026-10-03/04→true、2026-10-05→false、1970-01-03/04→true | — | `DateUtil.isWeekend` | 只判周六/周日，**不含调休与法定节假日**（那是逐年数据表，见 `docs/ROADMAP.md`「暂不做」） | 同 `weekday` |
| `Date::day_of_year(self) -> Int` | 2024-01-01→1、2024-03-01→61、2023-03-01→60、2024-12-31→366、2023-12-31→365、2026-10-04→277 | 恒返 1..366 | `DateUtil.dayOfYear` | — | `epoch_days - epoch_days(该年-01-01) + 1`；与 Python `timetuple().tm_yday` 核对 |
| `Date::quarter(self) -> Int` | 1/3 月→1、4/6 月→2、7/9 月→3、10/12 月→4 | 恒返 1..4 | `DateUtil.quarter`（JDK `Calendar` 无此概念，hutool 自算） | 一致：按自然季度，不是财务季度（要别的划分请用 `(month-1)/3+1` 自行推导） | `(month-1)/3+1` |
| `Date::week_of_year(self) -> Int` + `Date::week_based_year(self) -> Int` | 2021-01-01→(53, 2020)、2021-01-03→53、2021-01-04→(1, 2021)、2020-12-31→53、2019-12-30→(1, 2020)、2026-01-01→1、2026-12-31→(53, 2026)、2024-12-30→(1, 2025) | 恒返 1..53 / 年份 | `DateUtil.weekOfYear`（走 `Calendar.WEEK_OF_YEAR`） | hutool 那套随 `Locale` 与 `firstDayOfWeek`/`minimalDays` 变，同一日期在不同机器上不同读数 ⇒ 不可复现。本库固定 ISO 8601：周一为周首、含该年第一个周四的那周是第 1 周。**两个函数必须配对读**，否则 2021-01-01 会被读成"2021 年第 53 周" | ISO 8601；与 Python `isocalendar()` 核对（2026-12-31 是周四 ⇒ 该年确有第 53 周） |

**血统**：星期/周序号/周基准年取 **ISO 8601**（规范文本是权威，不是 hutool——hutool 那套走 `Calendar`，读数随 `Locale` 变）。


### 2.3 区间端点（`begin_of_*` / `end_of_*`）

`Date` 侧返回 `Date`，`DateTime` 侧返回 `DateTime`；`end_of_*` 的时刻档一律 `23:59:59.999`。

| 签名（`Date::` 与 `DateTime::` 同名成对） | 读数（夹具 2026-10-04，周日；另一夹具 2024-02-15） | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `begin_of_day` / `end_of_day`（仅 `DateTime`） | 12:34:56.789 → `2026-10-04T00:00:00.000` / `2026-10-04T23:59:59.999` | — | `DateUtil.beginOfDay/endOfDay` | hutool `endOfDay` 也是 `.999` 档；本库更细没有档（core 时钟就是毫秒） | 定义即契约 |
| `begin_of_week` | 2026-10-04→2026-09-28、2026-10-05→2026-10-05（自身即周一）、2026-10-03→2026-09-28、2024-02-15→2024-02-12、2026-01-01→2025-12-29、2026-12-31→2026-12-28 | 结果可能跨年 | `DateUtil.beginOfWeek(isMonDay=true)` | hutool 有"周日/周一为周首"两个档；本库只有周一档（与 `weekday`/ISO 周同一口径）。要周日开头的报表请自己 `-1 天` | `epoch_days - (weekday-1)` |
| `begin_of_month` / `end_of_month` | 2026-10 → 10-01 / 10-31；2024-02 → 02-01 / **02-29**；2023-02 → 02-01 / 02-28；2026-12-31 → 12-01 / 12-31 | — | `DateUtil.beginOfMonth/endOfMonth` | hutool 的 `endOfMonth` 是"最后一日的 00:00:00"再补时刻，读数与本库一致（`DateTime` 侧 `.999`） | 该月天数由 `days_in_month` 给 |
| `begin_of_quarter` / `end_of_quarter` | 2026-10 → 10-01 / 12-31；2024-02 → 01-01 / 03-31 | — | `DateUtil.beginOfQuarter/endOfQuarter` | — | 季度首月 = `(quarter-1)*3+1`，末月取其月末 |
| `begin_of_year` / `end_of_year` | 2026 → 01-01 / 12-31 | — | `DateUtil.beginOfYear/endOfYear` | — | — |

**血统**：hutool `DateUtil.beginOf*`/`endOf*` 家族的语义档（内部是 JDK `Calendar` 字段操作）；本库重写实现，并把"周首"固定成 ISO 的周一。


### 2.4 加减与日差

| 签名 | 读数（抽样） | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `Date::add_days(days : Int) -> Date` | 2024-02-28 +1→2024-02-29；2023-02-28 +1→2023-03-01；2024-12-31 +1→2025-01-01；2025-01-01 −366→2024-01-01；+0→自身；1970-01-01 −1→1969-12-31；2000-03-01 −60→2000-01-01 | — | `DateUtil.offsetDay` | — | `epoch_days ± n` 再反算 |
| `Date::add_months(months : Int) -> Date` | 2024-01-31 +1→**2024-02-29**；2023-01-31 +1→**2023-02-28**；2024-03-31 −1→2024-02-29；2024-01-30 +1→2024-02-29；2025-01-31 +13→2026-02-28；2024-05-31 +1→2024-06-30；2026-10-04 +12→2027-10-04；+0→自身；2024-02-29 −1→2024-01-29；2026-03-31 −1→2026-02-28 | 目标月没有该日 ⇒ **夹紧到月末** | `DateUtil.offsetMonth` | 与 JDK `Calendar.add(MONTH)` 同档（夹紧），**不是**"滚到下个月某天"（那是 `SimpleDateFormat` lenient 那一路）。这条被业务反复踩，所以逐个方向各钉一条 | 目标年月由 floor 除法/取模给（负数月也要落在正确年份） |
| `Date::add_years(years : Int) -> Date` | 2024-02-29 +1→2025-02-28；+4→2028-02-29；2023-02-28 +1→2024-02-28（**不动日**）；2026-10-04 −1→2025-10-04；2000-02-29 +4→2004-02-29 | 同上（夹紧） | `DateUtil.offsetYear`（= `offsetMonth(12n)`） | — | 同上 |
| `Date::days_between(other : Date) -> Int` | 2024-01-01→2024-03-01 = 60；反向 = −60；同日 = 0；1969-12-31→1970-01-01 = 1；2000-02-28→2000-03-01 = 2 | 有符号，`other − self` | `DateUtil.betweenDay(begin,end,isResetTime)` 返**绝对值** | 本库保留符号（无符号差值可由 `between`/`difference` 那条给）；hutool 的 `isResetTime` 档在 `DateTime` 侧由 `between` 承担 | 两个 `epoch_days` 相减 |

**血统**：月/年加减的夹紧档来自 JDK `Calendar.add(MONTH)` 语义（hutool `offsetMonth` 即其门面）；本库重写实现，不搬代码。


### 2.5 瞬间、墙上时钟与时刻算术

| 签名 | 读数（抽样） | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `DateTime::of(date, hour, minute, second, milli) -> DateTime raise DateError` | 越界读数：`(…,24,0,0,0)`→`TimeFieldOutOfRange(24,0,0,0)`；`12:60:0.0`、`12:0:60.0`、`12:0:0.1000` 各一条 | hour 0..23、minute/second 0..59、milli 0..999 | hutool 无对应（直接 `new Date(...)`） | 字段范围硬校验，不 mod 不进位 | 定义即契约 |
| `DateTime::from_epoch_millis(millis : Int64, offset_minutes : Int) -> DateTime` | `0L,0`→1970-01-01T00:00:00.000；`0L,480`→1970-01-01T08:00:00.000；`0L,-450`→**1969-12-31**T16:30:00.000；`-1L,0`→1969-12-31T23:59:59.999；`-1000L,0`→1969-12-31T23:59:59.000；`-86400000L,0`→1969-12-31T00:00:00.000；`86399999L,0`→1970-01-01T23:59:59.999；`1791117296789L,0/480/-450`→2026-10-04T12:34:56.789 / T20:34:56.789 / T05:04:56.789；`482196050520L,0`→1985-04-12T23:20:50.520 | `offset_minutes` 不校验范围（见下"差异声明"） | `DateUtil.date(ms)` 再靠默认时区格式化 | **偏移显式传**；且不做 tzdb，所以偏移可以是任何整数（本库不判它像不像真实时区，那是配置层的事） | epoch 毫秒 →（`millis + offset*60000`）的**向下**除法/取模拆出日与日内毫秒，再走 `civil_from_days`；与 Python `datetime.fromtimestamp(tz=timezone(timedelta(...)))` 逐条核对 |
| `DateTime::to_epoch_millis(offset_minutes : Int) -> Int64` | 2026-10-04T12:34:56.789 在 `0/480/-450` 下 → `1791117296789L / 1791088496789L / 1791144296789L`；1970-01-01T00:00:00.000→0L；1969-12-31T23:59:59.999→-1L | 与上一条互逆 | `DateUtil` 无（Java 的 `Date` 本身就是瞬间） | 这是"墙上时钟 → 瞬间"的唯一通道，所以偏移必填 | 同 #2.5 上一条，反方向 |
| `DateTime::add(unit : TimeUnit, n : Int64) -> DateTime` | 12:34:56.789 起：`Hour +2`→14:34:56.789；`Day −1`→2026-10-03T12:34:56.789；`Week +1`→2026-10-11T12:34:56.789；`Millisecond +213`→12:34:**57.002**（进位）；2024-01-31T23:59:59.999 `Millisecond +1`→**2024-02-01T00:00:00.000**；2024-02-29T23:59:59.999 `Day +1`→2024-03-01T23:59:59.999 | 跨日/月/年进位由内部 epoch 换算完成 | `DateUtil.offset(date, DateField, n)` | hutool 的 `DateField` 含 `MONTH/YEAR`；本库把它们分到 `add_months`，`add` 只吃固定长度单位（见 #1 的 `TimeUnit` 说明）。无 DST ⇒ `add(Day,1)` 恒等于 +24 小时墙上时钟 | 换毫秒、加、再走 `from_epoch_millis` |
| `DateTime::add_months(months : Int) -> DateTime` | 2026-10-04T12:34:56.789 +4→2027-02-04T12:34:56.789；2024-01-31T12:00:00.000 +1→**2024-02-29**T12:00:00.000 | 夹紧同 #2.4 | `DateUtil.offsetMonth` | 先加月、时刻原样保留（不进位到日） | 同上 |
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

> 状态：**契约已冻结**（10-06 PR-A，本批 8 块是设计态红）。数据件 `date/zone_table.mbt` 与期望件
> `date/zone_test.mbt` 都由 `scripts/gen_zone_table.py` 从参照腿 `scripts/TzLeg.java` 的读数灌出来，
> **一格都没有手打**；换窗口或换参照代次就整文件重生成，不逐条改。

### 5.1 参照代次与体积（全是现读）

| 读数 | 值 | 怎么取的 |
|---|---|---|
| 参照 | JDK 17.0.14（Oracle）· `lib/tzdb.dat` **101731 bytes** | 腿的 `B` 行。tzdb 的版本名这版 JDK 不吐（反射 `sun.util.calendar.ZoneInfoFile.VERSION` 撞 `InaccessibleObjectException`），所以代次改用「JDK 版本 + tzdb.dat 字节数」钉 |
| 区数 | **603** | `ZoneId.getAvailableZoneIds()` 全量，含 legacy link 与 `Etc/*` |
| 段数 | **18713** | 窗口 `[1970-01-01, 2050-01-01)` 内：每区首段 + 每次跳变一段 |
| 腿自证 | `SELFCHECK_BAD_ROWS = 0` | 每条段界都要 `getOffset(e) == 段值` 且 `getOffset(e-1) == 上一段值`，逐条反查 |
| 别名普查 | 603 个区只有 **318 套**不同规则（285 个区与别的区逐段同读数） | 规则指纹分组；本轮不去重，理由见 §5.6 第 3 条 |
| 成本 | 表源 349 KB · `moon check` 424 ms · 期望 8 块 5080 条 | 本机隔离副本实测：全表逐区那一块单独把 `moon test --target wasm` 从 2.2 s 抬到 8.5 s、测试 wasm 从 194 KB 抬到 1.7 MB。三档（wasm / js / wasm-gc）读数一致性由门禁 G3 逐档核 |

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
