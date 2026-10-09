# Roadmap · 进度表

一个文件回答三件事：**对位 hutool 的哪个类、现在到什么状态、为什么是这个状态**。每相位收口时**就地改终局值**（不留 `⏳`/`待核` 的旧读数——那张表是别人判进度时最先看的东西）。

## 状态口径（只用这五个值）

| 状态 | 含义 | 出口条件 |
|---|---|---|
| `已实现` | 签名 + 实现 + 用例全绿，四目标都过（`sched` 是登记过的例外：它只承诺三档，见该行状态说明） | `moon check` 0 警告、`moon test` 该包全绿、`.mbti` 已提交 |
| `实现中` | 有人在写，**期望值不许改** | 每次提交只让红变绿，不新增公开 API |
| `契约已冻结` | spec + 签名骨架 + 冻结期望值的用例就位，函数体是 `abort` | `moon check` 全绿，`moon test` 该包**预期红** |
| `未开工` | 只有目录与范围声明，**无任何公开项** | 不许出现签名（签名即契约，契约未评审不出 API） |
| `暂不做` / `不做` | 排后或明确排除 | 见文末两节 |

## 逐包进度

| 包 | hutool 对位 | 状态 | 契约 | 用例 |
|---|---|---|---|---|
| `text` | `StrUtil` / `CharSequenceUtil` / `NamingCase` / `StrFormatter` | **已实现** | `docs/spec/01-text.md` | 详记 [`roadmap-log/01-text.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/01-text.md) |
| `digest` | `DigestUtil`（MD5 / SHA-256 / HMAC） | **已实现** | `docs/spec/02-digest.md` | 详记 [`roadmap-log/02-digest.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/02-digest.md) |
| `date` | `DateUtil` / `CalendarUtil` / `DatePattern` / `DateUnit` | **已实现** | `docs/spec/03-date.md` | 详记 [`roadmap-log/03-date.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/03-date.md) |
| `id` | `IdUtil`（雪花 / UUID v3·v4 / ObjectId / NanoId） | **已实现** | `docs/spec/04-id.md` | 详记 [`roadmap-log/04-id.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/04-id.md) |
| `codec` | `Base64`(url-safe·MIME·宽松解码) / `Base32` / `Base58`(含 Check) / `Base62` / `RadixUtil` / `x-www-form-urlencoded` / `UrlBuilder` | **已实现** | `docs/spec/05-codec.md` | 详记 [`roadmap-log/05-codec.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/05-codec.md) |
| `coll` | `CollUtil` / `ListUtil` / `IterUtil` 的高频子集 | **已实现** | `docs/spec/06-coll.md` | 详记 [`roadmap-log/06-coll.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/06-coll.md) |
| `mapx` | `MapUtil` / `Table`(二维表) / `BiMap` / `CaseInsensitiveMap` | **已实现** | `docs/spec/07-mapx.md` | 详记 [`roadmap-log/07-mapx.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/07-mapx.md) |
| `num` | `NumberUtil` / `NumberChineseFormatter` / `MathUtil` / `Calculator` / `Money`(薄) | **已实现** | `docs/spec/08-num.md` | 详记 [`roadmap-log/08-num.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/08-num.md) |
| `conv` | `Convert`（无反射版） | **已实现** | `docs/spec/09-conv.md` | 详记 [`roadmap-log/09-conv.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/09-conv.md) |
| `re` | `ReUtil` / `PatternPool` / `RegexPool` | **已实现** | `docs/spec/10-re.md` | 详记 [`roadmap-log/10-re.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/10-re.md) |
| `valid` | `Validator`（79 个 `public static` 里的正则族） | **已实现** | `docs/spec/11-valid.md` | 详记 [`roadmap-log/11-valid.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/11-valid.md) |
| `rand` | `RandomUtil` / `WeightRandom` | **已实现** | `docs/spec/12-rand.md` | 详记 [`roadmap-log/12-rand.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/12-rand.md) |
| `mac` | `HMac`（并入 `digest` 还是独立包，出契约时定） | **不做**（10-05 判定：内容并入 `digest` 第二批，不建独立包，占位目录一并删掉） | —（判据与八件签名都记在 `digest` 的 spec §2.6） | 判据三条，都现读：① `HMac` 在 **hutool-crypto** 不在 core（本机 `javap -cp hutool-core-5.8.35.jar cn.hutool.crypto.digest.HMac` 找不到类，同批 `ReUtil`/`Validator` 都在 core）；② 它是**有状态对象**（7 个构造器 + `update`/`digest`/`digestHex`/`verify`），`update` 那半属"流式/增量摘要"，早已在 `digest` 的暂不做档；③ 剩下的一次性用法薄薄一层，已由 `digest` 八件（HMAC-MD5 全套 + 裸字节键 + `*_verify_hex`）全数覆盖 ⇒ 再开一个包只造出第二张嘴。20 块用例与 22 条 JDK 读数挂在 `digest` 行 |
| `dfa` | `WordTree` / `SensitiveUtil` / `StopChar` | **已实现** | `docs/spec/14-dfa.md` | 详记 [`roadmap-log/14-dfa.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/14-dfa.md) |
| `path` | `AntPathMatcher` | **已实现** | `docs/spec/15-path.md` | 详记 [`roadmap-log/15-path.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/15-path.md) |
| `cache` | `Cache` 接口 + `FIFOCache`/`LRUCache`/`LFUCache`/`TimedCache`/`NoCache` + `CacheUtil`（件在 **hutool-cache** 这个 artifact，`unzip -l` 现读 hutool-core 的 jar 里 `cn/hutool/cache` 是 0 条） | **已实现** | `docs/spec/16-cache.md` | 详记 [`roadmap-log/16-cache.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/16-cache.md) |
| `hash` | `HashUtil`（39 个 `public static`，javap 现读）+ `lang.hash.MurmurHash`/`CityHash`/`MetroHash`/`KetamaHash` + `io.checksum.CRC8`/`CRC16` 与 `crc16/` 十变体——**全在 hutool-core 一个 jar 里**（与 `dfa`/`cache` 两行相反，这行不用另取 artifact） | **已实现** | `docs/spec/17-hash.md` | 详记 [`roadmap-log/17-hash.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/17-hash.md) |
| `bloom` | `BitMapBloomFilter` + `BitSetBloomFilter` + `filter/` 11 个类 + `bitMap/{BitMap,IntMap,LongMap}` + `BloomFilterUtil`——**件不在 hutool-core**（`unzip -l hutool-core.jar` 现读 `bloom` 是 0 条），全在独立 artifact `hutool-bloomFilter-5.8.35.jar`（19,216 字节、21 个 class，与 `dfa`/`cache` 两行同形；行内旧写"只有 `BitMapBloomFilter`"已按现读更正，`5.8.35` 里也**没有** `AutoBitBloomFilter`） | **已实现** | `docs/spec/18-bloom.md` | 详记 [`roadmap-log/18-bloom.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/18-bloom.md) |
| `cron` | `cn.hutool.cron.pattern.CronPattern`（+ `parser/{PatternParser,PartParser}`、`matcher/*`、`Part`）——**件不在 hutool-core**：core 的 jar 里 `grep -ic cron` 现读 0 条，全在独立 artifact `hutool-cron-5.8.35.jar`（28 个 class） | **已实现** | `docs/spec/19-cron.md` | 详记 [`roadmap-log/19-cron.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/19-cron.md) |
| `textsim` | `TextSimilarity`（公开 3 件 + 私有 4 件，反射读数 `priv.names` 逐个点名）/ `Simhash` / `PasswdStrength`——三件都在 hutool-core 的 `cn/hutool/core/text/` 里（`unzip -l` 现读） | **已实现** | `docs/spec/20-textsim.md` | 详记 [`roadmap-log/20-textsim.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/20-textsim.md) |
| `csv` | `CsvReader` / `CsvWriter`（RFC 4180） | **已实现** | `docs/spec/21-csv.md` | 详记 [`roadmap-log/21-csv.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/21-csv.md) |
| `ini` | `Props` / `GroupedMap`（Java Properties 严格语义） | **已实现** | `docs/spec/22-ini.md` | 详记 [`roadmap-log/22-ini.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/22-ini.md) |
| `typex` | `Version` / `PageUtil` / `Ipv4Util` / `DataSize` / `DesensitizedUtil` / `IdcardUtil` / `CreditCodeUtil` / `PhoneUtil` / `CoordinateUtil` | **已实现** | `docs/spec/23-typex.md` | 详记 [`roadmap-log/23-typex.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/23-typex.md) |
| `sched` | hutool-cron 的调度族（`CronUtil`/`TaskTable`/`Scheduler`/`task/*`/`CronTimer`/`listener/*`/`timingwheel/*`；现读 `hutool-cron-5.8.35.jar` 共 43 个 `.class`，其中调度族 20 件，**件不在 hutool-core**） | **已实现** | `docs/spec/24-sched.md` | 详记 [`roadmap-log/24-sched.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/24-sched.md) |
| `cron_expr` | `cn.hutool.cron.pattern.*`（`CronPattern` + `parser/{PatternParser,PartParser}` + `matcher/*` + `Part`，与第 19 行同一族） | **未开工** | `docs/spec/25-cron_expr.md` | 详记 [`roadmap-log/25-cron-expr.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/25-cron-expr.md) |

## 当前总读数

这块数字由 `python scripts/sync_status.py --write` 当场跑出来生成，**不手写**（手写必漏，见 `AGENTS.md`）：

<!-- READINGS:BEGIN 由 scripts/sync_status.py 生成，勿手改 -->
| 读数（`moon test --target wasm`，当场跑） | 值 |
|---|---|
| 用例总数 | **1531** —— 绿 1531 / 红 0 |
| 包状态 | 共 23 个：`已实现` 23 · `契约已冻结` 0 · `未开工` 0 |
<!-- READINGS:END -->

| 项 | 值 |
|---|---|
| 门禁 | G1~G18 见 `scripts/contract_gate.sh`（G9 引用红线、G10 死链自检、G11 状态读数一致、G12 骨架豁免棘轮、G13 spec 序号＝表行号、G14 不承诺声明反查——写进公开文档的「不做 X」拿去 `.mbti` 现读对撞，证据取不到走 SKIP 不当通过，自检三档＝敢红/敢放/缺证据必 SKIP；G15 未覆盖行棘轮——基线 `scripts/coverage_baseline.txt` 提交进仓，任一包未覆盖行数上升即红，收紧随时可以、放宽要单独一笔，取不到覆盖率数据走 SKIP；G16 hutool-core 顶层类 census——`scripts/core_surface.py` 从**仓内类面清单** `docs/spec/hutool-classes.tsv`（10-09 固化，带 version+sha256 头，只在升级 hutool 那一笔才用 `$HUTOOL_JAR` 重生成）列全 `cn.hutool.core.**` 顶层类，逐类落 done/core/excluded/deferred/gap 五档，漏档、"表 vs 清单漂移"、以及**清单版本与脚本常量不一致**都判红，`gap` 那档就是待拍清单（现读 18 条，见 `00-hutool-map.md` §7；G17 死格形状棘轮——断言的**实参位**上出现 `"true"`/`"false"` 这类参照期望值字面串即计数（`scripts/vacuous_assert.py`），基线提交进仓只许降不许升，起因是 `path_test.mbt` 有 49 条把期望值填进 pattern 位、恒绿却按住了真分岔（见 `15-path.md` §7.2））；正向 GREEN、负向对照敢红（基线抬到 99 立刻 RED + 退出码 1） |

## 暂不做（排后，未定日期）

AES / SM4 / ChaCha20、PBKDF2、RSA（门票已在 core：`BigInt::pow(exp, modulus?)` + `math::probable_prime`，缺 ASN.1 DER）、ECDSA / SM2、Blake2b→Argon2、BCrypt、DEFLATE / gzip / zip、SHA-1 / SHA-512（下一批）、SM3、SHA-3、农历·节气·生肖码表、GB/T 2260 区划码表、拼音 / 繁简、GBK 等非 UTF 字符集表、Excel(xlsx)、流式增量摘要 API、`{0,number,…}` 式 `MessageFormat`。

**码表类若要作，一律独立成数据件**（本库被它依赖，反向不成立）：零依赖契约不破、不想拖表的用户不背体积、会过期的区划数据也不把一个工具库的发布节奏绑住。

## 不做（结构上不属于本库）

`BeanUtil`/`ReflectUtil`/`ClassUtil`/`MapProxy`/`aop`/`script`/序列化式 `clone` —— MoonBit **无运行时反射与动态代理**；Bean 拷贝请走内置 `derive(ToJson)/derive(FromJson)` 或手写 `to_map/from_map`。
`FileUtil`/`IoUtil`/`CharsetUtil.convert`/`WatchService`/`NetUtil.localIpv4s`/`ThreadUtil`/`SystemUtil` —— 需要 FFI 与 OS 线程（core 只给 `env.{now,rand,args,env_var,current_dir}`，官方生态也没有用户态线程 API，`moonbitlang/async` 那个线程池是内部件、不导出）。
`http`/`db`/`socket`/`poi`/`captcha`/`extra`/`log` —— 跨栈定位不同；`captcha` 还依赖 AWT 字体栅格化。
命名时区的历史声明已随 `date` 第二批翻案（内置 IANA 段表，见逐包表那一行与 `03-date.md` §5），仍不做的是：`DateUtil` 智能无格式解析、`java.text` 全套 pattern、JDK lenient 语义、Unicode 大小写、完整 `BigDecimal`。cron 的调度族已于 10-09 改判、另立逐包表第 24 行 `sched`，不再是「不做」项。
