# Roadmap · 进度表

一个文件回答三件事：**对位 hutool 的哪个类、现在到什么状态、为什么是这个状态**。每相位收口时**就地改终局值**（不留 `⏳`/`待核` 的旧读数——那张表是别人判进度时最先看的东西）。

## 状态口径（只用这五个值）

| 状态 | 含义 | 出口条件 |
|---|---|---|
| `已实现` | 签名 + 实现 + 用例全绿，四目标都过 | `moon check` 0 警告、`moon test` 该包全绿、`.mbti` 已提交 |
| `实现中` | 有人在写，**期望值不许改** | 每次提交只让红变绿，不新增公开 API |
| `契约已冻结` | spec + 签名骨架 + 冻结期望值的用例就位，函数体是 `abort` | `moon check` 全绿，`moon test` 该包**预期红** |
| `未开工` | 只有目录与范围声明，**无任何公开项** | 不许出现签名（签名即契约，契约未评审不出 API） |
| `暂不做` / `不做` | 排后或明确排除 | 见文末两节 |

## 逐包进度

| 包 | hutool 对位 | 状态 | 契约 | 用例 |
|---|---|---|---|---|
| `text` | `StrUtil` / `CharSequenceUtil` / `NamingCase` / `StrFormatter` | **已实现**（10-04，四目标 CI 待跑） | `docs/spec/01-text.md` | 13 条断言 + 10 个文档块，全绿 |
| `digest` | `DigestUtil`（MD5 / SHA-256 / HMAC） | **已实现**（10-04，官方向量 14 条全绿） | `docs/spec/05-digest.md` | 7 条 + 6 个文档块 |
| `date` | `DateUtil` / `CalendarUtil` / `DatePattern` / `DateUnit` | **契约已冻结**（10-04，签名 + 期望值就位，函数体 `abort`；wasm/js/wasm-gc 三档读数一致） | `docs/spec/02-date.md` | 47 条（31 断言块 + 16 文档块），46 红 · 1 绿（绿的那条只碰 pattern 常量）；core **无任何 time 包**，本库最大"从无到有"块 |
| `id` | `IdUtil`（雪花 / UUID v3·v4·v5 / ObjectId / NanoId） | 未开工（下一个出契约） | — | worker/datacenter/时钟全显式注入 |
| `codec` | `Base64`(url-safe·MIME·宽松解码) / `Base32` / `Base58` / `Base62` / `BCD` / `RadixUtil` / `PercentCodec` / `UrlBuilder` | 未开工 | — | core 已有标准 base64/hex/percent，只补缺口不转发 |
| `coll` | `CollUtil` / `ListUtil` / `IterUtil` 的高频子集 | 未开工 | — | `Array` 已有 123 方法，只做分组/分页/分片这类组合 |
| `mapx` | `MapUtil` / `Table`(二维表) / `BiMap` / `CaseInsensitiveMap` | 未开工 | — | `Map` 本身已保插入序，不再造 LinkedHashMap |
| `num` | `NumberUtil` / `NumberChineseFormatter` / `MathUtil` / `Calculator` / `Money`(薄) | 未开工 | — | 含 core 缺的 `gcd/lcm/ext_gcd/mod_inverse` |
| `conv` | `Convert`（无反射版） | 未开工 | — | `Json`→类型显式 `match` + 注册闭包 |
| `re` | `ReUtil` / `PatternPool` / `RegexPool` | 未开工 | — | **core 有公开 `Regex`**（prelude 导出），本包只做语法糖与常量表 |
| `valid` | `Validator` | 未开工 | — | 逐个定义语言 + 与 hutool 正则正反样本对拍 |
| `rand` | `RandomUtil` | 未开工 | — | 62 字符表、加权抽样、secure/pseudo 双通道 |
| `mac` | `HMac`（并入 `digest` 还是独立包，出契约时定） | 未开工 | — | 先证明与 `digest` 的分工再建签名 |
| `dfa` | `WordTree` / `SensitiveUtil` / `StopChar` | 未开工 | — | trie + 停顿字符表 |
| `path` | `AntPathMatcher` | 未开工 | — | **血统 = Spring-core（Apache-2.0）**，见 spec 血统列 |
| `cache` | `CacheUtil` / `SimpleCache`（LRU / LFU / TTL） | 未开工 | — | 显式 `prune()`，**去掉守护线程语义** |
| `hash` | `HashUtil` / `MurmurHash` / `CityHash` / `KetamaHash` / CRC8 / CRC16 变体 | 未开工 | — | 非密码学哈希与校验和 |
| `bloom` | `BitMapBloomFilter` | 未开工 | — | 位图 + 上面的 hash |
| `cron` | `CronPattern`（5~7 段解析 + `next_after`） | 未开工 | — | **只算不调度** |
| `textsim` | `TextSimilarity` / `Simhash` / `PasswdStrength` | 未开工 | — | `diff::edit_distance_str` 已有，只做归一化与 Jaro/Dice/SimHash |
| `csv` | `CsvReader` / `CsvWriter`（RFC 4180） | 未开工 | — | API 只收 `String`/`Bytes`，不碰文件 |
| `ini` | `Props` / `GroupedMap`（Java Properties 严格语义） | 未开工 | — | 生态里未找到对位件 |
| `typex` | `Version` / `PageUtil` / `Ipv4Util` / `DataSize` / `DesensitizedUtil` / `IdcardUtil` / `CreditCodeUtil` / `PhoneUtil` / `CoordinateUtil` | 未开工 | — | 身份证只出校验位 + `province_code()`，**不内置区划码表** |

## 当前总读数

这块数字由 `python scripts/sync_status.py --write` 当场跑出来生成，**不手写**（手写必漏，见 `AGENTS.md`）：

<!-- READINGS:BEGIN 由 scripts/sync_status.py 生成，勿手改 -->
| 读数（`moon test --target wasm`，当场跑） | 值 |
|---|---|
| 用例总数 | **84** —— 绿 38 / 红 46 |
| 包状态 | 共 23 个：`已实现` 2 · `契约已冻结` 1 · `未开工` 20 |
| 红的是谁 | `date`（46 红） —— 未实现的包红是设计态 |
<!-- READINGS:END -->

| 项 | 值 |
|---|---|
| 门禁 | G1~G12 见 `scripts/contract_gate.sh`（G9 引用红线、G10 死链自检、G11 状态读数一致、G12 骨架豁免棘轮）；正向 GREEN、负向对照敢红（基线抬到 99 立刻 RED + 退出码 1） |

## 暂不做（排后，未定日期）

AES / SM4 / ChaCha20、PBKDF2、RSA（门票已在 core：`BigInt::pow(exp, modulus?)` + `math::probable_prime`，缺 ASN.1 DER）、ECDSA / SM2、Blake2b→Argon2、BCrypt、DEFLATE / gzip / zip、SHA-1 / SHA-512（下一批）、SM3、SHA-3、农历·节气·生肖码表、GB/T 2260 区划码表、拼音 / 繁简、GBK 等非 UTF 字符集表、Excel(xlsx)、流式增量摘要 API、`{0,number,…}` 式 `MessageFormat`。

**码表类若要作，一律独立成数据件**（本库被它依赖，反向不成立）：零依赖契约不破、不想拖表的用户不背体积、会过期的区划数据也不把一个工具库的发布节奏绑住。

## 不做（结构上不属于本库）

`BeanUtil`/`ReflectUtil`/`ClassUtil`/`MapProxy`/`aop`/`script`/序列化式 `clone` —— MoonBit **无运行时反射与动态代理**；Bean 拷贝请走内置 `derive(ToJson)/derive(FromJson)` 或手写 `to_map/from_map`。
`FileUtil`/`IoUtil`/`CharsetUtil.convert`/`WatchService`/`NetUtil.localIpv4s`/`ThreadUtil`/`SystemUtil` —— 需要 FFI，直接违反零依赖定义（core 也只给 `env.{now,rand,args,env_var,current_dir}`）。
`http`/`db`/`socket`/`poi`/`captcha`/`extra`/`log` —— 跨栈定位不同；`captcha` 还依赖 AWT 字体栅格化。
命名时区与 DST、`DateUtil` 智能无格式解析、`java.text` 全套 pattern、JDK lenient 语义、Unicode 大小写、完整 `BigDecimal`、cron 调度器。
