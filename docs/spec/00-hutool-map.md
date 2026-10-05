# 契约 00 · hutool → moon-hutool 能力对照表

四列口径（**代码不转发、文档给映射**）：

- **core 直接可用** —— MoonBit 标准库已有同义能力，调用点直接打它，本库**不写转发层**（规则见 `AGENTS.md`「与 core 的边界」）
- **本库补** —— 本库提供，且标明补的是哪类：① hutool 契约形状 / ② 环境显式化 / ③ 分散入口收成可测出口
- **不做** —— JVM 特性、FFI、或明确不承诺（理由见文末与 `AGENTS.md`）

**spec 文件名的序号 = 该包在 [`docs/ROADMAP.md`](https://github.com/mldong/moon-hutool/blob/master/docs/ROADMAP.md) 逐包表里的行号**（`01-text`、`02-digest`、`03-date`、`04-id` … `23-typex`）。它是**稳定 ID 不是排名**：包挪进"暂不做"也不改号，号一旦发过就不再动。这条由门禁 G13 守着——某行的「契约」列与它的行号对不上就报红（防止"号"和"表"各漂各的，这个不一致曾经真的存在过）。

已定契约的包：`01-text.md`、`02-digest.md`、`03-date.md`、`04-id.md`。

## 1. 字符串（hutool `StrUtil` / `CharSequenceUtil`，实测 1838 非注释行）

| hutool | core 直接可用 | 本库补 | 不做 |
|---|---|---|---|
| `isEmpty/isBlank` | `String::is_empty`、`String::is_blank`、`Char::is_whitespace`（Unicode 子集） | ① `text.is_blank`（并集 hutool 独有 7 码点，含 U+0000） | 逐字符再抄一遍 Unicode 表 |
| `trim/trimToNull/trimToEmpty` | `String::trim`（给 `StringView`，要 `.to_owned()`） | ① `text.trim`、`text.trim_opt` | — |
| `split/splitTrim` | `String::split`（多分隔符、迭代器） | ① `text.split`（空段保留 + 逐段 trim） | — |
| `startWith/endWith/contains/indexOf/equals(ignCase)` | `has_prefix/has_suffix/contains/contains_any/find/equal_ignore_ascii_case` | — | **不转发** |
| `padPre/padAfter/repeat/wrap` | `pad_start/pad_end/repeat` | ① `text` 只在需要 null 档时补 | wrap/center 暂不列 |
| `format("{}")` | **无**（core 无 `sprintf`/`printf`/`{}`） | ① `text.format` | `indexedFormat`（JDK `MessageFormat`）、Map 模板二期 |
| `subBefore/subAfter/subBetween` | 需手工组合 `find`+切片 | ① `text.sub_*` | — |
| `toCamelCase/toUnderlineCase/toKebabCase/toPascalCase` | **无**（core 全树无命名法互转） | ① `text.to_*_case` | — |
| `toUpperCase/toLowerCase` | `to_upper/to_lower`（**仅 ASCII**） | — | **不承诺 Unicode 大小写**（要数据表，二期） |
| `hide/desensitized` | 无 | ① `text.hide`（码点下标+夹紧） | `DesensitizedUtil` 各字段策略 → P3 `typex` |
| `compareVersion` | `lexical_compare`（字典序，**不等价**） | ① `text.compare_version`（逐段数值） | — |
| `byteLength/truncateUtf8` | `String::to_bytes`（已废弃，改 `@encoding/utf8.encode`）、`char_length`、`length`（UTF-16 单元） | ③ 待 P2 之后再定 | 长度语义三个各不相同 ⇒ 文档必须逐条写清 |

## 2. 摘要 / HMAC（hutool `DigestUtil`，真上游是规范不是 hutool）

| hutool | core | 本库补 | 不做 |
|---|---|---|---|
| `md5/md5Hex/md5Hex16` | **无**（全树 `md5` 命中 0） | ② `digest.md5_*`（输入固定 UTF-8） | 字符集参数（无码表） |
| `sha1/sha256/sha512` | 无 | ② P1 只做 sha256，sha1/sha512 在 P6 | — |
| `hmac*` | 无 | ② `digest.hmac_sha256_*`（block size 64、长键先哈希） | — |
| `Digester(salt,saltPosition,digestCount)` | 无 | P6（hutool 私有行为，先反推再冻结） | — |
| 国密 `sm3`、`ripemd160`、SHA-3 | 无 | — | `docs/ROADMAP.md` 的「暂不做」档 |
| 对称/非对称（AES/DES/RSA/EC/SM2）、BCrypt/Argon2/PBKDF2 | 无；`BigInt::pow(modulus)` + `math::probable_prime` 是门票，缺 gcd 族与 ASN.1 | — | `docs/ROADMAP.md` 的「暂不做」档不排期 |

## 3. 集合与 Map（`CollUtil` 1265 行 / `MapUtil` 590 行）

| hutool | core 直接可用 | 本库补 | 不做 |
|---|---|---|---|
| `map/filter/reduce/distinct/groupBy/zip/flatten` | `Array::{map,filter,fold,dedup,zip,unzip,chunks,windows,flatten}`、`Iter::*`、`Array::sort/sort_by_key` | ③ `coll`（契约已冻结）：`group_by`、`partition`、`distinct`+`distinct_by`、`freq`、`page`+`page_count`、`union`+`intersection`+`subtract`、`maximum`+`minimum` 与按键两版——全是读 core 源码数出来的缺口 | **不给 `Array::map` 之类改名转发**；`index_where` 那种「找不到返 `-1`」的哨兵也不做（core `search_by` 给 `Int?`） |
| `union/intersection/disjunction/subtract` | `HashSet::{union,intersection,difference,symmetric_difference}`（**只在集合类型上**，`Array`/`List`/`Iter` 一个都没有） | ③ `coll` 的数组形态三件：`union`/`intersection` 去重、`subtract` **保留左侧重复** | `disjunction` 不做（`Set::symmetric_difference` 已有，保序版需求没到） |
| `LinkedHashMap`（插入序） | **`Map` 本身就是插入序**（Robin Hood + 链表，`builtin/LinkedHashMap.mbt.md`） | — | 不另造 LinkedHashMap |
| `sortByProperty/sortByPinyin` | 无（依赖反射/`Collator`） | — | **不做**（无反射、无拼音表） |
| `Table`（二维表）/`BiMap`/`CaseInsensitiveMap`/多值 Map | 无（`Map` 只有一层键，且 `contains_kv` 不能反查值） | ③ `mapx` 已交付：`BiMap`（双向唯一，撞值整次不生效 + 显式 `force_put`）、`CiMap`（ASCII 折叠、原样键取首次写入）、`Table`（行列双索引、列向顺序跟 `rows()`、删到空连行列键一起摘）、`filter_map`/`rename_key` | 多值 Map 不做（`Map[K, Array[V]]` 加两行就是，再包一层是第二个名字）；`ForestMap`/`TableMap` 扁平行视图/并发 Map 不做，理由见 `07-mapx.md` §9 |
| `MapProxy`（Bean 视图） | 无（`java.lang.reflect.Proxy`） | — | **不做**，走 `derive(ToJson/FromJson)` 或手写映射 |

## 4. 日期时间（`DateUtil` 859 行 —— core 零 time，本库最大"从无到有"块）

| hutool | core | 本库补 | 不做 |
|---|---|---|---|
| 当前时间 | `env.now() -> UInt64`（epoch ms，唯一时钟） | ② `date.Clock`（注入式） | 直接读系统时区（无接口） |
| 日历换算 | 无 | ③ `date`（civil↔epoch，Hinnant 算法） | — |
| 时区/DST | 无；`moonbitlang/x/time` 也只有固定偏移 + 自备 TZif | ② 显式 `offset_minutes` | **不支持命名时区与 DST**（本库固定口径：不支持命名时区与 DST） |
| `format/parse` | 无 | ① 封闭 pattern 子集（`y M d H h m s S E Z X a`，其余字符**显式拒绝**）+ ISO8601 / RFC 7231 两个专用解析器 | hutool 的"智能无格式 parse"、`java.text` 全套词法、lenient 语义 |
| `ChineseDate`/农历/节气/生肖 | 无 | — | `docs/ROADMAP.md` 的「暂不做」档，且**码表独立成数据件** |

## 5. 编解码 / 正则 / 校验

| hutool | core 直接可用 | 本库补 | 不做 |
|---|---|---|---|
| `Base64`（标准/去填充） | `encoding/base64::{encode(padding?),decode(ignore_whitespace?),decode_lossy}` | ② url-safe、MIME 76 换行、**严格/宽松双档解码**（[`05-codec.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/05-codec.md) #2） | 不重抄标准表实现——标准档只以**对拍腿**出现（G8） |
| `Base32/Base58/Base62/RadixUtil` | 无 | ③ `codec`（[`05-codec.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/05-codec.md) #3~#6） | Base58Check 的校验位复用 `digest` 已冻结的 SHA-256，本包不重复实现摘要 |
| `BCD` / `Base16Codec` | `encoding/hex` | **不做** | hutool `BCD` 自己标了 `@Deprecated`，逻辑就是把两个十六进制位打进一个字节；`Base16Codec` 更是同名转发（AGENTS「与 core 的边界」直接拒） |
| `HexUtil` | `encoding/hex` | ③ 只在需要 `hexToInt/颜色` 等组合时补 | 不转发 encode/decode |
| `PercentCodec`/`UrlBuilder` | `encoding/percent` | ③ URL 结构化组装 + form 的 `+` 档（RFC 3986，**codec 的 PR-A2**） | percent-encoding 本体已在 core；本包只补「空格出 `+`、`+` 解回空格」那一档，与 `UrlBuilder` 同批定契约 |
| `ReUtil`/`PatternPool`/`RegexPool` | **core 有公开 `Regex`**（`prelude.mbt:93` 免 import 导出；`find/split/replace_by/命名组/Pattern 构造`） | ③ `re`：Java 风味语法翻译（`\d\w\s`→POSIX 类）+ 常量表 | 不自写正则引擎（**本轮更正**：曾有调研判"core 无正则"，实测为假） |
| `Validator.isEmail/isIpv4/...` | 靠 core `Regex` 可表达 | ① `valid`（P4，逐个定义语言 + 正反样本对拍） | 不承诺与 hutool 正则逐字节等价（差异写 spec） |

## 6. 算法件

| hutool | core | 本库补 | 不做 |
|---|---|---|---|
| `DFA/SensitiveUtil` | 无 | ③ `dfa`（P5，trie + StopChar + 最大长度命中策略） | — |
| `AntPathMatcher` | 无 | ③ `path`（P5，token 匹配不靠正则）**血统 = Spring-core（Apache-2.0）** | — |
| `CacheUtil`/`SimpleCache`（LRU/LFU/Timed） | 无 | ③ `cache`（P5）**显式 `prune()`** | `schedulePrune` 守护线程语义、`WeakCache` |
| `HashUtil`（murmur/fnv/ketama…）/`CRC8/CRC16` | 无（`Hash` trait 只服务 HashMap，js 档走 extern 不可当摘要用） | ③ `hash`（P5） | — |
| `BloomFilter` | 无 | ③ `bloom`（P5） | — |
| `CronUtil` | 无 | ③ `cron`（P5，5~7 段解析 + `match` + `next_after`） | **调度器不做**（无 async/线程，只算不触发） |
| `TextSimilarity`/`Simhash` | `diff::{edit_distance_str,edit_distance_str_within,levenshtein_edits}` **已有** | ③ `textsim`：归一化分值、Jaro/Dice、SimHash | `similar` 按**实现**（最长公共子串/较大长度）不按 javadoc 的"莱文斯坦"说法 |
| `ZipUtil`/gzip/deflate | 无 | — | `docs/ROADMAP.md` 的「暂不做」档（RFC 1951 独立工程） |
| `CSV`/`Props`/`Ini` | 无 | ③ `csv`、`ini`（P5，**API 只收 `String`/`Bytes`**） | 文件读写 |
| `Convert`（注册表 + 反射） | `json::{parse,to_json,from_json,derive}`、`string::{parse_int,parse_int64,parse_double,parse_bigint}`、`@double.infinity` **已有**；而 `Json` 的 8 条取值方法（`value`/`item`/`as_*`）core 已**全线标 `@deprecated`**，建议写法就是自己 `match` | ① `conv` 第一批（`docs/spec/09-conv.md` #9.1~#9.19，10-05 契约已冻结）：`Json`→7 类标量的宽松转换 + 4 条字符串宽松解析腿 + `field`/`get_by_path`/`get_ids` 取值腿 + `JsonConv[A]`/`chain` 闭包组合；第二批留 `toSBC`/`toDBC` 与字节序族 8 件 | 运行时类型探测与「按 `Type` 查表的全局注册表」（`chain` 是它的闭包替身）；`toDate`/`toEnum`/`toBean`/`convertCharset`/`wrap` 等 20+ 件逐条理由见 `09-conv.md` §5.2 |
| `NumberUtil`/`MathUtil`（数论与舍入那一半） | `BigInt::pow(exp, modulus?)`、`math::*`、`double::*`；**无 Decimal、`gcd`/`lcm`/`mod_inverse` 零命中** | ③ `num` **两批都已交付**（`docs/spec/08-num.md` #8.1~#8.25）：`gcd`/`ext_gcd`/`mod_inverse`/`is_prime`/`isqrt` 在 `Int` 域，`lcm`/`factorial`/`combination_count`/`arrangement_count` 只在 `BigInt` 域，`round_to_str`/`round_to` 走 `RoundingMode` 七档 | 完整 `BigDecimal` 语义、`DecimalFormat` 全套 pattern；判定类 `isNumber`/`parseInt(default)` **不做**（不造 `Bool` 哨兵）；`divisor`/`isPrimes`/`sqrt(long)`/`factorial(long)` 四处不跟随各有源码级依据（spec §5） |
| `NumberChineseFormatter`/`NumberWordFormatter`/`Calculator`/`Money` | 无 | ③ `num` **第二批已交付**（#8.14~#8.25：`format_thousands`/`format_percent`/`trim_trailing_zeros` + 薄 `Money` 分 `Int64` 定宽、固定两位、`allocate` 两式；`DecimalFormat` 那一族与 locale 都不跟随，理由在 §5）；第三批中文数字四模式 + 反向解析与英文 word；第四批表达式求值（得先钉十进制精确算术的形状） | GB/T 2260 地址表、农历表（二期独立数据件）；hutool 的 `factorial(start, end)` 在 `start < end` 时返回 0，这条反直觉读数不复制 |
| `IdUtil`（UUID/雪花/ObjectId/NanoId） | `random.Rand` + `env.rand(n)->Bytes?` 是熵源；**无 uuid** | ② `id`（P1：worker/dataCenter/时钟**全显式注入**） | hutool 用 PID+IP 自动派生 workerId（MoonBit 无此接口）；`ObjectId` 布局与 MongoDB 官方不同，按 hutool 实现并注明 |
| `RandomUtil` | `random.Rand::{int,int64,uint64,double,boolean,bigint,shuffle}` + `Array::shuffle` | ③ `rand`（P1：62 字符表、加权抽样、secure/pseudo 双通道） | 无熵时静默降级（必须明确报错） |

## 7. 整模块不做（写进 README 的「不承诺清单」）

`bean`/`annotation`/`reflect`/`getter`/`compiler`/`aop`/`script`/`MapProxy`/序列化式 `clone`（**无运行时反射/动态代理**）；`io.FileUtil`/`IoUtil`/`CharsetUtil.convert`/`watch`/`net.NetUtil` 本机 IP/`ThreadUtil`/`system`（**需要 FFI，违反零依赖定义**）；`http`/`db`/`socket`/`poi`/`captcha`（AWT 栅格化）/`extra`/`log`（跨栈定位不同：web 走 moonback、DB 走 moondb/moonmysql）。

Bean 拷贝在 MoonBit 侧的正确姿势：`derive(ToJson)/derive(FromJson)`（**语言内置，非第三方宏**）或手写 `to_map/from_map`。
