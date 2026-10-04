# 契约 00 · hutool → moon-hutool 能力对照表

四列口径（**代码不转发、文档给映射**）：

- **core 直接可用** —— MoonBit 标准库已有同义能力，调用点直接打它，本库**不写转发层**（规则见 `AGENTS.md`「与 core 的边界」）
- **本库补** —— 本库提供，且标明补的是哪类：① hutool 契约形状 / ② 环境显式化 / ③ 分散入口收成可测出口
- **不做** —— JVM 特性、FFI、或明确不承诺（理由见文末与 `AGENTS.md`）

包名 ↔ 相位见 `AGENTS.md` 的路线表；已定契约的包：`01-text.md`、`02-date.md`、`05-digest.md`（编号按交付顺序：01 text、02 date、03 id、04 rand、05 digest）。

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
| `map/filter/reduce/distinct/groupBy/zip/flatten` | `Array::{map,filter,fold,dedup,zip,unzip,chunks,windows,flatten}`、`Iter::*`、`Array::sort/sort_by_key` | ③ 只补 `group_by/partition/split_avg/page/count_map` 这类 core 没有的组合 | **不给 `Array::map` 之类改名转发** |
| `union/intersection/disjunction/subtract` | `HashSet::{union,intersection,difference,symmetric_difference}` | ③ Array 形态的薄组合（保序语义） | — |
| `LinkedHashMap`（插入序） | **`Map` 本身就是插入序**（Robin Hood + 链表，`builtin/LinkedHashMap.mbt.md`） | — | 不另造 LinkedHashMap |
| `sortByProperty/sortByPinyin` | 无（依赖反射/`Collator`） | — | **不做**（无反射、无拼音表） |
| `Table`（二维表）/`BiMap`/`CaseInsensitiveMap`/多值 Map | 无（`Map` 只有一层键） | ③ `mapx`（P2） | — |
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
| `Base64`（标准/去填充） | `encoding/base64::{encode(padding?),decode(ignore_whitespace?),decode_lossy}` | ② url-safe、MIME 76 换行、**严格/宽松双档解码** | 不重抄标准表实现 |
| `Base32/Base58/Base62/RadixUtil/BCD` | 无 | ③ `codec`（P2） | — |
| `HexUtil` | `encoding/hex` | ③ 只在需要 `hexToInt/颜色` 等组合时补 | 不转发 encode/decode |
| `PercentCodec`/`UrlBuilder` | `encoding/percent` | ③ URL 结构化组装（RFC 3986，P2） | — |
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
| `Convert`（注册表 + 反射） | `json::{to_json,from_json,derive}` **已有** | ① `conv`（P3：`Json`→类型显式 `match`，无反射） | 运行时类型探测 |
| `NumberUtil`/`BigDecimal` | `BigInt::pow(exp, modulus?)`、`math::*`、`double::*`；**无 Decimal、无 gcd/lcm** | ③ `num`（P3：含 `gcd/lcm/ext_gcd/mod_inverse`）+ 薄 `Money`（`Int64` 分 + `allocate`） | 完整 `BigDecimal` 语义、`DecimalFormat` 全套 pattern |
| `NumberChineseFormatter` | 无 | ③ `num`（P3） | GB/T 2260 地址表、农历表（二期独立数据件） |
| `IdUtil`（UUID/雪花/ObjectId/NanoId） | `random.Rand` + `env.rand(n)->Bytes?` 是熵源；**无 uuid** | ② `id`（P1：worker/dataCenter/时钟**全显式注入**） | hutool 用 PID+IP 自动派生 workerId（MoonBit 无此接口）；`ObjectId` 布局与 MongoDB 官方不同，按 hutool 实现并注明 |
| `RandomUtil` | `random.Rand::{int,int64,uint64,double,boolean,bigint,shuffle}` + `Array::shuffle` | ③ `rand`（P1：62 字符表、加权抽样、secure/pseudo 双通道） | 无熵时静默降级（必须明确报错） |

## 7. 整模块不做（写进 README 的「不承诺清单」）

`bean`/`annotation`/`reflect`/`getter`/`compiler`/`aop`/`script`/`MapProxy`/序列化式 `clone`（**无运行时反射/动态代理**）；`io.FileUtil`/`IoUtil`/`CharsetUtil.convert`/`watch`/`net.NetUtil` 本机 IP/`ThreadUtil`/`system`（**需要 FFI，违反零依赖定义**）；`http`/`db`/`socket`/`poi`/`captcha`（AWT 栅格化）/`extra`/`log`（跨栈定位不同：web 走 moonback、DB 走 moondb/moonmysql）。

Bean 拷贝在 MoonBit 侧的正确姿势：`derive(ToJson)/derive(FromJson)`（**语言内置，非第三方宏**）或手写 `to_map/from_map`。
