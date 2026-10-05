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
| `digest` | `DigestUtil`（MD5 / SHA-256 / HMAC） | **已实现**（10-04，官方向量 14 条全绿） | `docs/spec/02-digest.md` | 7 条 + 6 个文档块 |
| `date` | `DateUtil` / `CalendarUtil` / `DatePattern` / `DateUnit` | **已实现**（10-05，47 条全绿，wasm / js / wasm-gc 三档读数一致，`.mbti` 零漂移） | `docs/spec/03-date.md` | 47 条（31 断言块 + 16 文档块），全绿；core **无任何 time 包**，本库最大"从无到有"块（整包自研：偏移显式传、无 tzdb/DST、proleptic Gregorian + 天文纪年） |
| `id` | `IdUtil`（雪花 / UUID v3·v4 / ObjectId / NanoId） | **已实现**（10-05，32 条全绿，wasm / js / wasm-gc 三档读数一致，native 档由 CI 出证） | `docs/spec/04-id.md` | 32 条（22 断言块 + 10 文档块），全绿；时钟与熵全显式注入，**v5 待 `digest` 的 SHA-1**（hutool 本身无 v5） |
| `codec` | `Base64`(url-safe·MIME·宽松解码) / `Base32` / `Base58`(含 Check) / `Base62` / `RadixUtil` / `x-www-form-urlencoded` / `UrlBuilder` | **已实现**（10-05 两批全落地，37 条全绿，wasm / js / wasm-gc 三档读数一致，`.mbti` 零漂移） | `docs/spec/05-codec.md` | 38 条（25 断言块 + 13 文档块）全绿；读数走 RFC 4648 §10 向量 + 两套独立实现互算（Base58/62 无 RFC），form 档以 HTML 序列化器 ↔ Node `URLSearchParams` 双路互算、URL 档以 RFC 3986 §3/§5.2.4/§6.2.2 加 Python `urlsplit` 对跑；`BCD` 判**不做**（上游已 `@Deprecated`、语义即 core hex），§5.2.2 引用解析与 IDN 另批 |
| `coll` | `CollUtil` / `ListUtil` / `IterUtil` 的高频子集 | **已实现**（10-05，16 条全绿，wasm / js / wasm-gc 三档读数一致，`.mbti` 零漂移） | `docs/spec/06-coll.md` | 16 条（11 断言块 + 5 文档块）全绿；core `Array` 对外可写的方法几十条量级、扫描口径写在 spec §1（`chunks`/`dedup`/`flatten`/`zip`/`join`/`sort_by_key`/`shuffle`/`search_by` 全都有），本包只补**读源码数出来的缺口**：分组、两桶划分、保序去重与按键去重、频次表、分页、数组版并/交/差、`Array` 上的极值与按键极值；对拍腿三条（`distinct`↔`dedup`、`page`↔`chunks`、`maximum`↔`Iter::maximum`）；`index_where` 那种"找不到返 `-1`"的哨兵**不做**（core `search_by` 给 `Int?`） |
| `mapx` | `MapUtil` / `Table`(二维表) / `BiMap` / `CaseInsensitiveMap` | **已实现**（10-05 两批都落地，28 条读数三档一致，`.mbti` 零漂移） | `docs/spec/07-mapx.md` | 28 条（20 断言块 + 8 文档块）；边界现读 core 得出：`Map` **本身就是插入序**（33 条公开面里有 `of/new/merge/retain/update_or_default/get_or_init/keys/values/to_array`）⇒ 不再造 LinkedHashMap、一个都不重新包装；补的只有 `BiMap`（双向唯一，`put` 撞值**整次不生效** + 显式 `force_put`）、`CiMap`（折叠只覆盖 ASCII，原样键取首次写入）、`filter_map`、`rename_key`（新键落末尾、不改输入、`old == new` 不自删）、**第二批 `Table`**（双索引、行优先展开、列向顺序跟 `rows()`、删到空连行列键一起摘、值不建索引是明码取舍）。三条"不跟随 hutool"都有源码级依据（`BiMap.put` 会让双向索引不一致；`renameKey` 原地改且 `old == new` 时把条目自己删掉） |
| `num` | `NumberUtil` / `NumberChineseFormatter` / `MathUtil` / `Calculator` / `Money`(薄) | 契约已冻结 | `docs/spec/08-num.md` | 第一批 13 条公开项已交付：数论 `gcd`/`ext_gcd`/`mod_inverse`/`is_prime`/`isqrt` + 只在 `BigInt` 域的增长型算术 `lcm`/`factorial`/`combination_count`/`arrangement_count` + `RoundingMode` 七档与 `round_to_str`/`round_to`；**分两批**：第一批 27 块 250 条此刻仍绿；第二批（千分位/百分比/薄 `Money`，#8.14~#8.25）17 块此刻是**设计态红**（函数体是 `abort`）。core 侧扫描口径给足：`math` 54 条 / `bigint` 60 条公开面里 `gcd|lcm|mod_inverse|rational` **零命中**；边界规则「增长型算术只在 `BigInt` 域」来自三条实测静默回绕读数（`2147483647*2 = -2`、`Int::MIN.abs() = Int::MIN`、`BigInt::to_int` 超范围回绕）。后三批各自一块：千分位与百分比 + `Money` 薄档 / 中文数字与英文 word / `Calculator` |
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
| 用例总数 | **244** —— 绿 227 / 红 17 |
| 包状态 | 共 23 个：`已实现` 7 · `契约已冻结` 1 · `未开工` 15 |
| 红的是谁 | `num`（17 红） —— 未实现的包红是设计态 |
<!-- READINGS:END -->

| 项 | 值 |
|---|---|
| 门禁 | G1~G13 见 `scripts/contract_gate.sh`（G9 引用红线、G10 死链自检、G11 状态读数一致、G12 骨架豁免棘轮、G13 spec 序号＝表行号）；正向 GREEN、负向对照敢红（基线抬到 99 立刻 RED + 退出码 1） |

## 暂不做（排后，未定日期）

AES / SM4 / ChaCha20、PBKDF2、RSA（门票已在 core：`BigInt::pow(exp, modulus?)` + `math::probable_prime`，缺 ASN.1 DER）、ECDSA / SM2、Blake2b→Argon2、BCrypt、DEFLATE / gzip / zip、SHA-1 / SHA-512（下一批）、SM3、SHA-3、农历·节气·生肖码表、GB/T 2260 区划码表、拼音 / 繁简、GBK 等非 UTF 字符集表、Excel(xlsx)、流式增量摘要 API、`{0,number,…}` 式 `MessageFormat`。

**码表类若要作，一律独立成数据件**（本库被它依赖，反向不成立）：零依赖契约不破、不想拖表的用户不背体积、会过期的区划数据也不把一个工具库的发布节奏绑住。

## 不做（结构上不属于本库）

`BeanUtil`/`ReflectUtil`/`ClassUtil`/`MapProxy`/`aop`/`script`/序列化式 `clone` —— MoonBit **无运行时反射与动态代理**；Bean 拷贝请走内置 `derive(ToJson)/derive(FromJson)` 或手写 `to_map/from_map`。
`FileUtil`/`IoUtil`/`CharsetUtil.convert`/`WatchService`/`NetUtil.localIpv4s`/`ThreadUtil`/`SystemUtil` —— 需要 FFI，直接违反零依赖定义（core 也只给 `env.{now,rand,args,env_var,current_dir}`）。
`http`/`db`/`socket`/`poi`/`captcha`/`extra`/`log` —— 跨栈定位不同；`captcha` 还依赖 AWT 字体栅格化。
命名时区与 DST、`DateUtil` 智能无格式解析、`java.text` 全套 pattern、JDK lenient 语义、Unicode 大小写、完整 `BigDecimal`、cron 调度器。
