# 第 3 节 · `date`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 03 行（`date`）“用例”列的逐字原文。
编号 03 是稳定 ID：与该包契约 `docs/spec/03-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `date` | `DateUtil` / `CalendarUtil` / `DatePattern` / `DateUnit` | **已实现**（**10-08 补档一笔**：RFC 3339 严格腿的位置档 + pattern 引号/重复字段/贪婪数字八块，取值档七条与 JDK 逐条同判；date 未覆盖行 13 → 3，三条剩行全给推导（其中一条带 603 个区的全量探针读数），变异 9 条全抓红零等价——判据与两处被真跑打回的推导写在 spec §9）；第五批 10-07 两笔收口：契约 `dcc6bad` + 落地笔——默认区一层九件 + `ZoneSource` 一个类型，`default_test.mbt` 15 块 305 条冻结期望全部转绿，`moon test --package date` 124 = 绿 124 / 红 0（wasm/js/wasm-gc 三档一致、零警告、既有件签名一字未动、`.mbti` 只前进 26 行），§8.7 十一条变异全部抓红零等价；三级降级 `set_default_zone` → `TZ` → `fallback_zone`，`default_zone_source()` 把参照那个查不到来源的进程级全局量做成可查询；动笔前实测三条承重前提（三档都读得到 `TZ`、测试档 `set_env_var` 立即可见、JDK 在 Windows 不跟 `TZ`），并纠掉上一轮我自己一条想当然（`EST5EDT`/`GMT0` 是 IANA legacy 区名、在表内走 env，不是"POSIX 串不收"那一档）。已收口的前四批读数：首批 10-05 的 47 条三档一致；第二批 10-06 两笔 `85143d7` + `e60ee84`，内置 IANA 时区段表 603 区 / **36701 段** + 命名时区入口七件，31 块转绿、Z1–Z8 八条变异全部抓红零等价，落地轮修腿把 `getTransitions()` 漏掉的规则驱动那些年补回来，段数 18713 ⇒ 36701；第三批 10-06 可注入时钟源五件（`clock_system` / `clock_fixed` / `date_of` / `now_at` / `today_at`）两笔收口 `c984f49` + `cbbc9f9`，13 块转绿、C1–C7 五条抓红两条等价各给推导；第四批 10-06 命名时区版 format/parse 三件 + `ZoneGap` 一个错误变体，两笔收口 `fceabad` + 落地笔，12 块转绿、D1–D8 八条变异全部抓红零等价；本包偏移承诺到**整分钟**，窗口内非整分钟只有 `Africa/Monrovia` 一区两年，已作显式分岔两栏并读 | `docs/spec/03-date.md` | 47 条（31 断言块 + 16 文档块），全绿；core **无任何 time 包**，本库最大"从无到有"块（整包自研：偏移显式传、无 tzdb/DST、proleptic Gregorian + 天文纪年） |
````

---

**10-10 第六批（PR-A 契约冻结笔，非落地笔）**：owner 原话"可推；注入"里的后半句，把 `03-date.md`
§6.5 第 2 行那条"单调钟/秒表不做"改判成**做，走注入时钟**。本节记的是判据与腿，读数以现读为准。

- **五条腿**（全部落 `scripts/`，jar 不提交、跑法写在每份文件头）：`TimerLeg.java` 81 行（状态机 +
  三件计时 + `GlobalCustomFormat` 联动，时长数字全掩成 `#`）、`TimerLeg2.java` 33 行（零档原值 +
  保长度掩法看列宽）、`TimerLeg3.java` 153 行（`getShotName` 七档 / `NumberFormat` 两档规则 /
  `prettyPrint` 形状 / 行分隔符 / `formatBetween` 23 档 × 五档 / 全局表）、`TimerLeg4.java` 85 行
  （`TimeUnit.convert` 截断表 17×7、`nanosToSeconds`、反射喂选定纳秒的 `TaskInfo`、`start(null)` 暗档、
  负 epoch）、`TimerLeg5.java` 30 行（两张表的不对称）。**腿二与腿三、腿四各跑两遍逐字节相同**，
  只有 `SN|toString`/`SN|prettyPrint` 两行按时钟浮动 ⇒ 那两行取的是形状不是值。
- **公开面 54 件**（现读 `date/pkg.generated.mbti`，`.mbti` 前进 94 行）：`StopWatch` 一构造口 + 19 法、
  `TaskInfo` 一类型 + 5 法、`ChronoUnit` 一枚举 + `shot_name`、`GroupTimeInterval` 四构造口 + 13 法
  （参照的父子两面合成一个类型）、`format_between`、全局表八件；错误面新增六个 `DateError` 变体。
  期望两份生成件 `date/timer_test.mbt`(263 断言) + `date/custom_format_test.mbt`(88 断言)，
  手写一份 `date/timer_state_test.mbt`(11 块：状态机 / 排版 / 分组计时)——**一格都不手打**，
  每条行尾带 `读数腿` 或 `规则腿` 两种来源之一。
- **本笔状态**：`moon check --target wasm/js/wasm-gc` 0 警告 0 错误；`moon test --target wasm`
  现读 **1584 = 绿 1557 / 红 27**，27 条红全是本批新块（函数体是 `PR-B：契约骨架` 的 abort），
  既有 1557 条一字未动。READINGS 生成块因此把 `date` 记成 `实现中`——**那是工具按"有没有红"分的类**，
  前五批的 1557 条绿与既有签名一条都没改，PR-B 之后自动回到 `已实现`。
- **五条推翻常识的读数**（写在这里防止实现轮"顺手改回去"）：
  ① `prettyPrint` 的两处 `java.text.NumberFormat` 是**默认 locale** 的——同一条腿换 locale 复跑，
     `ar_SA` 给阿拉伯-印度数码 + U+066A 百分号 + 尾挂 U+061C，`de_DE` 在 `%` 前插 U+00A0，
     `zh_CN`/`th_TH` 才是 ASCII ⇒ 本库恒 ASCII 那档（spec §9.7 末那张四行表）；
  ② `DateUtil.formatBetween(long)` 一参版内部档位是 **`Level.MILLISECOND`**，不是想当然的 `DAY`
     （字节码 + 腿 `FB|3600000` 一参"1小时" vs `DAY` 档"0天"对质）；
  ③ `isCustomFormat` 只查 formatter 表 ⇒ **只登记 parser 的键在门面上是隐形的**，
     `DateUtil.parse` 因此压根不去查 parser 表（腿 `P5|parser-only` 三档）；本库照抄这条不对称；
  ④ 内置 `#sss` 格式化是 `Math.floorDiv(ms, 1000)`（`-999` ⇒ `-1`，向零截断会给 `0`），
     而它对应的解析是 `Math.multiplyExact(n, 1000)` ⇒ "parseLong 过得去、乘 1000 溢出"是**另一种异常**
     （`ArithmeticException: long overflow`），本库 `Int64` 乘法静默回绕，必须自己判；
  ⑤ `StopWatch` 的 `prettyPrint` 用 `NumberFormat`(HALF_EVEN)、`toString` 用 `Math.round`，
     **两族在平局档分岔**（0.025 ⇒ `02%` vs `3%`；`total=0` ⇒ `NaN` vs `0%`）——不许"顺手统一"。
- **两条编译器裁决**：`&mut Self` 在本版判词法错（`unexpected token mut`），可变方法照 `cache` 那包写
  `self : TypeName` + `mut` 字段；同包两个枚举变体撞名直接 `4124 ambiguous` ⇒ `ChronoUnit` 用复数档名
  （这本来就是参照 junit 侧的命名，`TimeUnit` 对位的 `DateUnit` 是单数）。骨架期字段刻意不写 `mut`
  （`unused_mut` 是 error 级、豁免压不住），留给落地笔按语义加。
- **不跟随与到不了**（各自带参照读数，全在 spec §9.6/§9.8）：行分隔符（参照 `System.lineSeparator()`
  本机现读 CRLF）、`null` id 与四条 `interval(null)` NPE（类型到不了）、`DateUtil.parse` 在
  "只有 formatter 没有 parser"那档给**当前时刻**（本库给 `None`）、`format(TemporalAccessor, …)` 与
  `LocalDateTimeUtil.parse` 两条挂载（要经 `ZoneId.systemDefault()`）。
- **一处历史引用的更正**：上面 10-08 那条留痕写"推导写在 spec §9"——当时本包只到 §8，那两条推导实际在
  §8.7。本节 §9 是 10-10 第六批新加的，与那句无关；留痕按"逐字"原则不改，在这里更正指向。

---

**10-10 第六批（PR-B 落地笔）**：只把红变绿，公开签名一字未动。

- **读数**：`moon test --target wasm` 现读 **1591 = 绿 1591 / 红 0**，js 档同数，wasm-gc 档 1579
  （差的 12 块是 `sched`——那个包按 `supported_targets` 摘了 wasm-gc，与本批无关）；
  `moon check` 0 警告 0 错误。`date/pkg.generated.mbti` 相对 PR-A 那笔（`6d5e953`）**零漂移**
  （`git diff 6d5e953 -- date/pkg.generated.mbti` 空）。G18 的裸读时钟点仍只有 `date/date.mbt` 一处，
  本批新件一处都不读时钟。
- **三条新档 + 第六条腿**：落地时发现 §9.3/§9.7 有三族判据没有对照档（`to_string` 的 `Math.round`
  四档、百分号超长整数部分与负号位置、纳秒档预启动/`interval_restart` 已记过档/`interval_hour`），
  补 `scripts/TimerLeg6.java`（57 条读数：`JU|round` 24 档 + `JU|pct` 5 档 + `JU|parseLong` 14 档 +
  `JU|GCF#sss` 14 档；按文件头那两行命令重编重跑**两遍逐字节相同**，且与喂给生成器那份逐字节相同）
  灌成三个新块 ⇒ 生成件断言从 PR-A 的 263+88=351 条涨到 **279+103=382 条**，
  手写件 `timer_state_test.mbt` 11 块 90 条。
- **期望面两处就地更正（单独一笔，先于本笔）**：① 生成器把 `PC|1.0` 与 `NF|0` 配成了同一行，
  而腿里 `total=0` 那档的百分号读数就是 `PC|NaN`（`0/0` 是 `NaN` 不是 `0`）⇒ 改配对规则并重出该件；
  ② 手写件里 `pad9(1000000)` 被打成 `000100000`，按 §9.7.1 补零规则真值是 `001000000`（少了一位）。
  同笔另两处是**夹具左侧**不是期望串：注入读数 `90061000000` 算错量级（应为 `90061000000000` ns 才等于
  腿里那条 `FB|90061000`），分组计时器的 tick 序列把两次读数写重了。
- **变异 16 档**（§9.10 全表带红位）：15 档挂载成功、**全部抓红**，红数 1–7；另一档 T15b 是**故意造的
  等价**——把新补的 `m2` 对照夹具拆掉再挂同一条变异，读数回到 0 红，以此证明那条夹具是承重的而不是运气。
  T4 换过形态：第一版改成 `raise` 直接编不过（`interval_restart` 签名不 `raise`），那不算判据抓红，
  换成行为档（未记过的键给 `0` 而不是那次读数）才拿到那 1 红。
- **覆盖率**：`date` 未覆盖行从契约期的 45（基线 `b5e5dd1` 放宽那一格）压回 **6**，本笔随落地一起收紧
  （棘轮规则：变小随时可以，放宽才要单独一笔）；六行全部在 §9.11 给了
  推导——三条是本批新件的到不了档（`task_label` 的 `None` 支结构上到不了、`percent_of` 的 `I64_MAX`
  夹是不承诺档、`between` 的空串补尾是正半边到不了），三条是 §8 早已推导过的既有件。
- **变异工装与读数件是工作树外的临时件**（跑完即删，不进仓），十五档的逐档红位已转录进 spec §9.10；
  判据只有转录进 spec 才算留下。
- **G5 与 G11 的互相拉扯（本包第三次撞上，口径照 AGENTS 那条走）**：落地笔必须把 §9 状态行与头
  状态行从"契约笔/`abort`/预期红"翻成"两笔都已落"，否则 G11 判"措辞与当场读数不一致"；而这一翻就碰了
  `docs/spec/*`，G5 因此不许裸跑。做法：`GATE_FREEZE_BASE=6d5e953`（契约那一笔）+ `ALLOW_EXPECTATION_CHANGE=1`
  复跑，现读 **GATE GREEN：0 失败、1 项 SKIP**；"期望值一条都没动"的机器证明是
  `git diff 9ded005..HEAD -- '*_test.mbt'` **输出为空**（落地笔连测试文件都没碰，比"剔注释比字节"更强），
  期望面那两处更正与第六条腿全部在 `9ded005` 那一笔里。反过来若拿 `9ded005` 当基准跑，G5 会 RED 并点名
  `docs/spec/03-date.md` ——那是这道闸设计上的粗粒度（它把 spec 整体当冻结面），不是本笔改了期望。
- **本包 §8 的行号引用随本批实现漂移过两处**（970→982、1208→1220），已在原文旁标"这些指向会漂"——
  指向具体行号是这份 spec 里最容易过期的一类记号，落地笔顺手校准并留了现读入口。

