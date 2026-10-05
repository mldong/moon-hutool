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
| `num` | `NumberUtil` / `NumberChineseFormatter` / `MathUtil` / `Calculator` / `Money`(薄) | **已实现**（10-05 三批收口；`Calculator` 留第四批） | `docs/spec/08-num.md` | 300 条里 num 占 67 块、三档全绿：第一批 27（数论五件 + `BigInt` 域四件 + 七档舍入）、第二批 17（千分位/百分比/`trim`/薄 `Money`）、第三批 23（中文数字四模式 + 大小写金额 + 千分位档 + 反向 + 缩写 + 英文 word，#8.26~#8.39）。第三批的参考腿是 **hutool 两个 formatter 的逐字转写跑本机 JDK 17**（主腿 763 条 + 复核轮四批探针），反向另加 Python 算法复刻逐条对撞（71 条一致 / 2 条截断分岔 / 金额 24 一致 + 3 条声明分岔）；三条架构级口径当场定死：**正向只收十进制原文串**（hutool 的 double 路与 BigDecimal 路对同一数给两种答案）、**反向累加走 `Int64`**（实测「一千亿」在 Java 侧截断成 1215752192）、**认「负」前缀 + 没有「元」键不丢值**（两处 hutool 自身缺陷）。实现轮另有一笔前置更正（`8ce9585`：两处自相矛盾/模型错的冻结期望改判 + 51 条实测断言），十条变异对照逐条有块红，读数在 spec §10.3 第 7 条；不跟随清单 15 行在 §10.4 |
| `conv` | `Convert`（无反射版） | **已实现**（10-05 两笔都落地，33 块全绿，wasm/js/wasm-gc 三档一致，`.mbti` 零漂移） | `docs/spec/09-conv.md` | 33 块（`conv_test.mbt` 23 + `README.mbt.md` 10）全绿；17 条公开项 + `JsonConv[A]` 别名 + 唯一 raise 面 `BadPath`。三处架构差按契约实现：**目标类型在函数名里、注册表换成一等闭包 `chain`**（对位 `ConverterRegistry:262` 的 `isCustomFirst=true`）、`Number` 的 `repr` 优先（`9007199254740993` 不撞 Double 精度，实测 19 条 `(d, repr)` 形状）、越界/locale 分组一律 `None`（31 条实测分岔逐条给理由，含 zh_CN↔de_DE 同输入 41 条两读）；**文法判定自写、core 只求值**——实测 core `parse_int` 还收 `1_000` 与 `NaN`/`Infinity`，照单全收就等于跟随 Java 的 `NumberFormat` 分支。实现期更正过两处期望值（镜像腿自身缺陷，读数来源记在 spec §4 第 9~10 条腿）；SBC/DBC 与字节序族 8 件留在第二批 |
| `re` | `ReUtil` / `PatternPool` / `RegexPool` | **已实现**（10-05 两笔：契约 `e58c2f7` + 落地；`RegexPool`/`PatternPool` 常量表留第二批） | `docs/spec/10-re.md` | 22 块全绿（`re_test.mbt` 13 块 162 条断言 + `README.mbt.md` 9 个文档块），wasm / js / wasm-gc 三档读数一致、`.mbti` 零漂移；24 条公开项 + `ReError` 两档（`BadPattern`/`BadReference`），签名在 `re/pkg.generated.mbti`。两腿定档：腿 A 真 `hutool-core-5.8.35.jar` + 本机 JDK 17.0.14 跑 `ReUtil`（859 + 58 + 6 = **923 条**，另有 JDK 引擎侧 6 条只在参照实现自己崩掉的档对读），腿 B core `@string.Regex` 探针 **114 条**跑在 wasm / js / wasm-gc 三档、**三份输出逐字节相同**——引擎侧裁决只能由腿 B 出，腿 A 只作"Java 那里合法"的证据。三条实测事实决定形状：**方言不假装、也不自动改写**（`\d \w \s \xHH \p{L} \1 \A \z \Q (?=) (?<=) (?i) a{300} a{2,1} [a-]` 全是编译期报错；调研阶段"会静默退化成字面反斜杠"的推断被探针当场推翻）、`.` 默认 DOTALL 且 `^`/`$` 恒整串（无 `MULTILINE` 档）、`replace_by` 的替换文本按字面处理且 `limit` 的负数档**一处都不换**。不跟随 13 行每行带两侧读数，其中"切分尾随空段"那条是两腿对撞抓出来的（写契约时判为一致），"重名命名组"那条是实现轮改判出来的（**core 实测接受重名、Java 拒绝**，本包按参照实现预检拦下）；实现轮另有一笔夹具更正（模式串 `([$\\])` 当初按 Java 源码层照抄进 MoonBit 字面量，落到 core 就成了非法模式，期望串一字未改）；五条变异对照逐条有块红（升序代入 3 红 / 修剪尾随空段 2 红 / 静默留 `$9` 2 红 / 去重名预检 1 红 / 最左一段占满 3 红）；第二批（`RegexPool`/`PatternPool` 常量表）的前置普查已做：**34 条里 24 条带 core 不收的写法**，改不动就整批不做 |
| `valid` | `Validator`（79 个 `public static` 里的正则族） | **已实现**（10-05 两笔：契约 `a772ca9` + 落地） | `docs/spec/11-valid.md` | 11 块全绿（`valid_test.mbt` 5 块 127 条断言 + `README.mbt.md` 6 个文档块），三档一致、`.mbti` 零漂移；签名 `String -> Bool`（两件限长的多两个 `Int`），**无错误面**——码表是包内常量，编不过是本包写错，不泄给调用方。两腿对撞：**腿 A** 真 hutool-core-5.8.35 + JDK 17.0.14 跑 `Validator`（393 行读数，且由参照腿自己吐出 `RegexPool`/`PatternPool` 每条 `Pattern` 的**源文与 flags**，码表来源不手抄）、**腿 B** core `@string.Regex` 探针在**同一批样本**上跑（242 行 × wasm/js/wasm-gc 三档逐字节相同）⇒ **127 条一致、0 条分岔**。这一批的立场是"**改写到命中集相同为止**"，两条实测改写规则进了 spec §4：① 字符类里的 `-` 不能与别的字符并排（`[:-]`、`[-:]` 实测编译期报错，只有写成择路 `(:\|-)` 才编得过）；② `isUUID` 用的不是 `UUID` 那条常量——实测它同时认 32 位无横线与混合大小写，按常量改写会漏一档。**没进本批的都带着理由挂账**：`is_email`（`\xHH` 类）、中文族（javac 预处理后落成代理对码元区间）、`is_letter`/`is_upper_case`/`is_lower_case`（参照实现是 Unicode 类别表，core 只有 ASCII 档谓词 ⇒ 先拍口径）、`is_birthday`（走 `find()` + 取组 + `DateUtil.thisYear()` 读时钟）、`is_url`（参照实现走 `java.net.URL` 的协议解析器，`URL`/`URL_HTTP` 两条常量它根本没用）、`is_number`/`has_number`（要与 `conv` 的数值文法对齐成一张嘴）、`is_citizen_id`/`is_credit_code`（mod-11 / mod-31 校验位 + 区划码表，归第 19 行 `typex`）；另实测 **5.8.35 里没有 `ValidatorSetting`/`validator-setting.json`**（jar 里只有 `Validator`/`PatternPool`/`RegexPool` 三个类、零资源文件），码表就是编译期常量。实现轮的三条变异对照逐条有块红（`is_uuid` 退回单形状 2 红 / MAC 分隔符写回 `[:-]` 2 红 / `is_ipv4` 首段放宽 2 红）；文档页两条凭常识写的期望被真跑打回（金额小数位不封顶、IPv4 前导零照收），已按语料改正并记进 spec §4 第 7~8 条 |
| `rand` | `RandomUtil` / `WeightRandom` | **已实现**（10-05 两笔：契约 `5f5097f` + 落地） | `docs/spec/12-rand.md` | 11 块全绿（`rand_test.mbt` 6 块 43 条断言 + `README.mbt.md` 5 个文档块），三档一致；19 件公开项 + `RandError` 四档，签名一律收 `@random.Rand`（**随机源显式注入，库内一次都不取熵**）。这一包的期望值形状与前几家不同：**没有一条是“跑一次记输出”**——参照实现 55 个 `public static` 里没有一个收 `Random` 参数（实测 `javap`），结果序列不可复现，所以只钉四类钉得死的东西：常量表原样（四张表反射读字段，实测 `BASE_CHAR_NUMBER` 62 字符且**大写在前**）、**单点定义域**（`(0,1)` 默认 ⇒ 恒 `0`；不含下含上 ⇒ 恒 `1`；`(0,2)` 双不含 ⇒ 恒 `1`，各抽 3000 次验过）、异常与空输入档（非正 `n`、空域、空表、空集合、`count` 超过去重数）、与流无关的不变量（长度恰为 `count`、字符 ⊂ 表、去重档互不相同、**零权重永不中选**）。三条实测行为改写了直觉：`randomString(0)` 参照实现给**长度 1** 的串（本包给空串，§5 第 1 行）、`randomEle(list, limit)` 的第二参是“只看前 N 个”而不是重试次数、`randomStringUpper` 的结果集是 **36 字符**（62 表里本来就带数字，转大写后数字仍在）。**secure/pseudo 双通道判不做**：core 只有一条 chacha8 流，且实测 `Rand::new()` 在无熵档静默回落固定种子——承诺“安全”没有凭据；`randomChinese`/`randomDay`/`randomDate` 不做（一个要码表、两个读墙钟），`random_float`/`random_double`/`randomBytes` 留第二批。本批的 core 侧只有**源码形状**（`Rand::int(limit=0)` 是取全域而不是报错、`chacha8` 要求 32 字节种子），三条待复测项在落地轮全部跑完并进了 spec §4 第 3~5 条：`int(limit=0)` 不报错而是"取全域"、`int(limit<0)` 走 `abort` 且 **`try` 抓不到 panic**（探针就停在那一行）、同一脚本化 `Source` 下三档输出逐字节相同（本包跨档一致承诺的全部凭据）。三条变异对照逐条有块红（上界 `+1` 丢掉 / 长度循环挪一位 / 累计桶边界挪一位）；落地当场还了一处手工落稿的漏——`(0,1)` 那条少写 `incl_max=true`，把空域当成了单点域，单独一笔更正。去重档的 `Eq` 界随实现补进签名（`.mbti` 跟着变）|
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
| 用例总数 | **344** —— 绿 344 / 红 0 |
| 包状态 | 共 23 个：`已实现` 12 · `契约已冻结` 0 · `未开工` 11 |
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
