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
| `hmac*` | 无 | ② `digest` **两批齐**：`hmac_sha256_*`（`String` 档固定 UTF-8、block size 64、长键先哈希）+ 第二批 HMAC-MD5 全套 / `*_of_bytes` 裸字节键 / `*_verify_hex` 常量时间校验 | 空密钥档**不承诺**（参照腿 JDK 抛 `IllegalArgumentException`，RFC 也不给空键向量） |
| `HMac` 对象（`update`/`digest`/`digestHex`/`verify`，ROADMAP 第 13 行） | 无 | ② **判不建 `mac` 包**（10-05）：一次性用法已由 `digest` 八件覆盖，三条判据现读记在 `02-digest.md` §2.6——在 hutool-crypto 不在 core、是有状态对象、剩下的薄一层 | `update` 那半属流式/增量摘要，在「暂不做」档 |
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
| 时区/DST | 无；`moonbitlang/x/time` 也只有固定偏移 + 自备 TZif | ② 显式 `offset_minutes` + **内置 IANA 段表**（第二批：`date/zone_table.mbt`，现读 603 区 / 36,701 段，窗口 [1970,2050)；`zone_names`/`zone_exists`/`zone_count`/`zone_offset_minutes`/`zone_offsets_at_wall` + 命名区版 `format_in`/`parse_in`/`to_rfc3339_in`；第五批默认区三级降级 `set_default_zone` → `TZ` → `fallback_zone`，`default_zone_source()` 把参照那个查不到来源的进程级全局量做成可查询） | **偏移承诺到整分钟**（窗口内只有 `Africa/Monrovia` 一区两年不是整分钟，已作分岔双栏读数）；表窗口外的墙上时刻判 `None`；不追 `java.time` 的规则求值器 |
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
| `ReUtil`/`PatternPool`/`RegexPool` | **core 有公开 `Regex`**（`prelude.mbt:93` 免 import 导出；`find/split/replace_by/命名组/Pattern 构造`）。引擎面四条实测（10-05，探针 114 条跑 wasm/js/wasm-gc **三档逐字节相同**）：纯 MoonBit 的 Brzozowski 导数自动机（`js` 档不借宿主 `RegExp`）、`.` 默认 DOTALL、`^`/`$` 恒整串（无 `MULTILINE`）、`\d \w \s \xHH \p{L} \1 \A \z \Q (?=) (?<=) (?i) a{300}` 一律**编译期报错** | ③ `re`：#10.1~#10.24 共 **24 件**（判断/取组/批量/位置/模板/删除/切分/转义/回调）+ `ReError` 两档，契约表 [`10-re.md`](10-re.md)；`RegexPool`/`PatternPool` 常量表留第二批 | **语法自动翻译**（`\d\w\s`→POSIX 类）**判不做**——**本轮更正**：原计划就是"翻译"，但实测两边**合法集不同**（`(?i)`、`a{300}`、`\1` 在 Java 侧合法、core 侧编译期报错），把改写塞进库里等于在引擎之上再造一份语义，还要替调用方吞掉"这串本来不该用"的信号；等价改写是**给调用方看的对照**（`(?i:…)`、`[[:digit:]]` 这类），表在 `10-re.md` §7，不是本包的义务。曾有调研判"core 无正则"，实测为假 |
| `Validator.isEmail/isIpv4/...` | 靠 core `Regex` 可表达，**但 hutool 那 34 条 `RegexPool` 常量里 24 条带 core 不收的写法**（`\d` 18/`\w` 4/`\xHH` 2，普查见 `10-re.md` §4 第 7 条）⇒ 每条都得先改写成 core 方言 | ① `valid`：第一批 15 件已冻契约（`11-valid.md`，#11.1~#11.15，127 条样本两腿逐条对撞、**0 条分岔**） | **立场是"改写到命中集相同为止"**，不是"承诺逐字节等价"：等价件进契约、不等价的件**整件挂账**（`is_email` 的 `\xHH`、中文族的代理对码元区间、`is_letter`/`is_upper_case`/`is_lower_case` 的 Unicode 类别表、`is_birthday` 的 `find()`+时钟、`is_url` 的 `java.net.URL` 解析器）；`is_citizen_id`/`is_credit_code` 的校验位与区划码表归第 19 行 `typex`；hutool 那 38 个 `validateXxx(value, errorMsg)` 抛 `ValidateException` 的变体与 18 个存在性判定**不搬** |

## 6. 算法件

| hutool | core | 本库补 | 不做 |
|---|---|---|---|
| `DFA/SensitiveUtil` | 无 | ③ `dfa` **已实现**（10-05 两笔：9 件 + `WordTree`/`FoundWord` + 停顿字符表）：`new_word_tree` 建树、`is_match`/`first_match`/`first_found`/`match_all`/`match_all_words`/`match_all_mode`/`match_all_words_mode` 七档查询、`is_stop_char`/`is_not_stop_char` | **`SensitiveUtil` 静态全局表与 `containsSensitive(Object)` 反射档不做**（无全局可变注册表、无反射）；`clear`/`setCharFilter` 不放；**密集档不做性能承诺**（参照实现最坏 `O(n²)`，本库同形状，Aho-Corasick 是另一个算法族）。两条实测更正：默认档是**最左起点里的最短命中**（不是本表旧写的"最大长度命中"——最长要 `density=true` 且 `greed=true` 两条同时开），且 `greed` 在 `density=false` 时**完全惰性**（参照实现的那行 `break` 排在贪婪判定之前） |
| `AntPathMatcher` | 无 | ③ `path`（**契约已冻结**，10-05：10 件 + `PathOptions` + `PathError`）**血统 = Spring-core（Apache-2.0）的 vendored 拷贝，就在 hutool-core 的 jar 里**；本库 `LICENSE` 从骨架起就是 Apache-2.0，许可无悬挂 | `setCachePatterns` 全局模式缓存不做（同 `re` 轮立场）；`{*path}` 捕获档判不支持（参照实现自己 `match` 恒假 + 抛异常）；`PathPatternParser` 那一族不引；`{name:regex}` 子表达式**按 core 方言**（Java-only 写法判非法模式）；本包 raise 面只有 `extract_variables` 三档 |
| `cn.hutool.cache.*`（`Cache`+5 个实现+`CacheObj`+`CacheUtil`，**件在 hutool-cache artifact**，hutool-core 的 jar 里 `cn/hutool/cache` 是 0 条） | 无 | ③ `cache`（**契约已冻结**，10-05：23 件公开面，146 条参照腿读数）——**时钟由调用方显式传 `now`**、`prune` 三档语义不同（`Fifo` 满着踢队首 / `Lru`·`Timed` 只扫过期 / `Lfu` 公平减计） | 不建六件带证据：`ReentrantCache`/`StampedCache`（成员只有锁）、`WeakCache` 与 core 的 `SimpleCache`（零依赖、core 无弱引用，回收时机不可冻）、`schedulePrune`/`GlobalPruneTimer`（实测起**非守护**线程 `Pure-Timer-1`，工装因此挂到超时）、`cache/file/*`（落盘 IO 出界）；`capacity==0` 与 `Integer.MAX_VALUE` 两档参照自相矛盾，处置见 `16-cache.md` §5 |
| `HashUtil`（39 件静态：字符串族 + murmur/city/metro 委托）+ `lang.hash.{MurmurHash,CityHash,MetroHash,KetamaHash,Number128}` + `io.checksum.{CRC8,CRC16}` 与 `crc16/` 十变体 | 无（`Hash` trait 只服务 HashMap，js 档走 extern 不可当摘要用） | ③ `hash`（**契约已冻结**，10-05：40 件公开面、398 条参照腿读数；返回值一律有符号 `Int`/`Int64`，与读数十进制逐字同形） | 不建：`universal`/`zobrist`（值靠调用方传随机表）、`identityHashCode`（JVM 地址派生）；`CRC8` 照抄参照的非标准表构造（实测 2 对标准式 244，两侧都留档）；128 位族（city/metro/murmur128）与 `KetamaHash`/`ConsistentHash` 第二批；`codec/Hashids` **不是哈希**（可逆编码），归属另判待评 |
| `cn.hutool.bloomfilter.*`（`BitMapBloomFilter` + `BitSetBloomFilter` + `filter/` 11 类 + `bitMap/` 3 件 + `BloomFilterUtil`，**件在独立 artifact hutool-bloomFilter**，core 的 jar 里 `bloom` 是 0 条） | 无 | ③ `bloom` 第一批（**已实现**，10-05 两笔，`docs/spec/18-bloom.md` #18.1~#18.23）：位图层（W32/W64 两档，词数按**地板除截断**跟随）+ 过滤器层（`abs(h % size)`，取模在前 abs 在后）+ 聚合层（m 定档 + 默认五过滤器顺序 `java_default/elf/js/pjw/sdbm` + `add` 是逻辑或）；哈希 16 件全部委托 `hash` 包 | 无参构造 `new int[93750000]`（≈375MB）**拒建**；`BitSetBloomFilter`（`ceil(c*k)` + 固定哈希顺序 + `Math.exp/pow` 误判率）第二批，超越函数不承诺三档逐位一致；`init(path, charset)` 文件 IO 出界；`Serializable` 不接；越界从 `AIOOBE` 换成可见的 `IndexOutOfRange(r, len)`；负位置与超 int 位置的**静默回绕跟随**（各有两侧读数） |
| `cn.hutool.cron.pattern.CronPattern`（件在 **hutool-cron** artifact，core 的 jar 里 `grep -ic cron` 是 0 条） | `date` 包已有月末/闰年/epoch 全部算术 | ③ `cron` 第一批（**契约已冻结**，10-05，`docs/spec/19-cron.md` #19.1~#19.6）：解析（5~7 段、`/ > - > ,`、别名、`?`、日段 `L`）+ `match` + `next_match_after` + `next_match` + 原文本 | 调度族已改判：触发面落逐包表第 24 行 `sched`（10-09 立项；本行这一包是表达式层，不内含触发器）；无时区入口（参照的 `match(millis)` 走 `TimeZone.getDefault()`）；`CronPatternBuilder`/`CronPatternUtil` 第二批 |
| `TextSimilarity`（公开 3 件 + 私有 4 件）/`Simhash`/`PasswdStrength`，三件同在 hutool-core 的 `cn/hutool/core/text/` | `diff::{edit_distance_str,edit_distance_str_within,levenshtein_edits}` **已有** | ③ `textsim` 第一批（**已实现**，10-05 两笔，`docs/spec/20-textsim.md` #20.1~#20.5）：`similar`/`similar_percent`/`longest_common_subsequence` + 把私有的 `isValidChar`/`removeSign` 提到公开面（剥离集不可测就不可评审）；`Simhash`（有状态、要拍指纹存储形状）与 `PasswdStrength`（两枚枚举 + 权重表）第二批 | `similar` 按**实现**钉而不是 javadoc：分母 = 剥离后**较大**长度、分子 = 最长公共**子序列**（`lcsu.22｜用户登成功` 非连续）、剥空两侧给 1.0；**没有 Jaro/Dice 这两档**（旧写在本行的"归一化分值、Jaro/Dice"是调研阶段的猜测，现读 jar 里 `TextSimilarity` 只有三个公开方法，已按现读更正）；编辑距离族不重造（core `diff` 已有） |
| `ZipUtil`/gzip/deflate | 无 | — | `docs/ROADMAP.md` 的「暂不做」档（RFC 1951 独立工程） |
| `CSV`/`Props`/`Ini` | 无 | ③ `csv`、`ini`（P5，**API 只收 `String`/`Bytes`**） | 文件读写 |
| `Convert`（注册表 + 反射） | `json::{parse,to_json,from_json,derive}`、`string::{parse_int,parse_int64,parse_double,parse_bigint}`、`@double.infinity` **已有**；而 `Json` 的 8 条取值方法（`value`/`item`/`as_*`）core 已**全线标 `@deprecated`**，建议写法就是自己 `match` | ① `conv` 第一批（`docs/spec/09-conv.md` #9.1~#9.19，10-05 契约已冻结）：`Json`→7 类标量的宽松转换 + 4 条字符串宽松解析腿 + `field`/`get_by_path`/`get_ids` 取值腿 + `JsonConv[A]`/`chain` 闭包组合；第二批留 `toSBC`/`toDBC` 与字节序族 8 件 | 运行时类型探测与「按 `Type` 查表的全局注册表」（`chain` 是它的闭包替身）；`toDate`/`toEnum`/`toBean`/`convertCharset`/`wrap` 等 20+ 件逐条理由见 `09-conv.md` §5.2 |
| `NumberUtil`/`MathUtil`（数论与舍入那一半） | `BigInt::pow(exp, modulus?)`、`math::*`、`double::*`；**无 Decimal、`gcd`/`lcm`/`mod_inverse` 零命中** | ③ `num` **两批都已交付**（`docs/spec/08-num.md` #8.1~#8.25）：`gcd`/`ext_gcd`/`mod_inverse`/`is_prime`/`isqrt` 在 `Int` 域，`lcm`/`factorial`/`combination_count`/`arrangement_count` 只在 `BigInt` 域，`round_to_str`/`round_to` 走 `RoundingMode` 七档 | 完整 `BigDecimal` 语义、`DecimalFormat` 全套 pattern；判定类 `isNumber`/`parseInt(default)` **不做**（不造 `Bool` 哨兵）；`divisor`/`isPrimes`/`sqrt(long)`/`factorial(long)` 四处不跟随各有源码级依据（spec §5） |
| `NumberChineseFormatter`/`NumberWordFormatter`/`Calculator`/`Money` | 无 | ③ `num` **第二批已交付**（#8.14~#8.25：`format_thousands`/`format_percent`/`trim_trailing_zeros` + 薄 `Money` 分 `Int64` 定宽、固定两位、`allocate` 两式；`DecimalFormat` 那一族与 locale 都不跟随，理由在 §5）；第三批中文数字四模式 + 反向解析与英文 word；第四批表达式求值（得先钉十进制精确算术的形状） | GB/T 2260 地址表、农历表（二期独立数据件）；hutool 的 `factorial(start, end)` 在 `start < end` 时返回 0，这条反直觉读数不复制 |
| `IdUtil`（UUID/雪花/ObjectId/NanoId） | `random.Rand` + `env.rand(n)->Bytes?` 是熵源；**无 uuid** | ② `id`（P1：worker/dataCenter/时钟**全显式注入**） | hutool 用 PID+IP 自动派生 workerId（MoonBit 无此接口）；`ObjectId` 布局与 MongoDB 官方不同，按 hutool 实现并注明 |
| `RandomUtil`/`WeightRandom` | core `@random` 有 `Rand`（`int`/`int64`/`uint`/`double`/`boolean`/`shuffle`）与 `pub(open) trait Source` ⇒ **随机源可由调用方注入**（脚本化即完全可复现） | ② `rand`：第一批 19 件已交付（`12-rand.md`：四张表 + 界值四组合 + 字符串族 + 取样三件 + 加权件） | **secure/pseudo 双通道判不做**——实测 core 只有一条 chacha8 流，且 `Rand::new()` 在无熵档**静默回落固定种子**，承诺不了；`randomChinese`（要 CJK 码表）、`randomDay`/`randomDate`（读墙钟）不做；`random_float`/`random_double`/`randomBigDecimal`/`randomBytes` 留第二批；`getRandom()` 一类"供应生成器"的件不做（本包生成器是入参） |

## 7. hutool-core 顶层类 census：每个类必须落一档（机器判据 G16）

上面 §1~§6 只登记了**做过的**那一面，所以"还差多少"这问题过去只能现场 `unzip` + `javap` 手算。现在改成常驻判据：`scripts/core_surface.py` 从参照 jar 里列出 `cn.hutool.core.**` 的**全部顶层类**（剥内部类与 `package-info`），逐类落进五档之一，落不进就红。

| 档 | 含义 | 现读类数（hutool-all **5.8.37**，632 个顶层类，固化在 `docs/spec/hutool-classes.tsv`） |
|---|---|---|
| `done` | **逐条登记过**对位件（`OVERRIDES` 里点名哪个包哪件承接） | 135 |
| `unattested` | 包级规则**整片声称已做但没逐条指回实现件**（10-09 紧闸新增档，棘轮只许降） | 0 |
| `excluded` | 结构上不属于本库：反射/动态代理/宿主 IO/网络/线程/AWT/JVM 内部机制 | 355 |
| `core` | MoonBit core 已有同义能力，本库按规则不写转发层 | 54 |
| `deferred` | 已登记在 [`docs/ROADMAP.md`](https://github.com/mldong/moon-hutool/blob/master/docs/ROADMAP.md) 的「暂不做」档 | 29 |
| `gap` | **够得着、既没做也没登记** ⇒ 这一档就是要拍板的清单 | 59 |


> 这六个数**不是手抄**：`scripts/core_surface.py --check` 会解析本表并与归类表现算的条数逐档比对，任一处对不上或表形状变了（读不到六个档）直接判红（10-10 从临时比对脚本升级成判据，两侧对照进自检⑤：等值镜像必须为空、某一档多 1 条必须被抓到）。


**10-09 紧闸：`done` 从此只能逐条登记**（owner 拍"先让闸不再允许整片算已做，再分批补登记"）

原来有一条包级规则 `(text|convert|codec|collection|map|comparator|builder|lang.hash|lang.id|io.unit)`
**一条就给了 161 个 `done`**，理由串还写着「逐条见 overrides」——可规则命中就 `return` 了，
那批类根本没有逐条 override，那句话对它们是空指。抽验的硬证据：`text.escape.*` 6 类 + `text.replacer.*` 3 类
整片判 done，而 `text/pkg.generated.mbti` 现读 19 件公开函数里 escape/replacer 命中 **0**。

改法（`scripts/core_surface.py`）：
- `classify()` 里新增 `_downgrade_blanket_done()`——**包级规则给的 `done` 一律降成 `unattested`**，
  `OVERRIDES` 的逐条 `done` 保持权威；非 done 档（excluded/core/deferred）不受影响（自检⑤钉着，误降也红）。
- 新棘轮 `scripts/unattested_baseline.txt`：`unattested` 条数**只许降不许升**，基线缺失也判红
  （"没有基线"等于这条棘轮没在跑）。两条负向实测：基线压到 195 ⇒ `FAIL …从 195 涨到 196`；
  删掉基线文件 ⇒ `FAIL … 缺 scripts/unattested_baseline.txt`。
- `--selftest` 从四档扩到**五档**，第⑤档专证"降级与棘轮不是摆设"。

数字因此换代（现读，不是推算）：`done` 272 → **67**，新出 `unattested` **196**，`gap` 18 → **27**。

**同日第一批消化已落**（`convert.impl` 全 35 类逐条指认）：现读 `done` 67 → **80**、`unattested` 196 → **161**、`excluded` 287 → **301**、`core` 35 → **39**、`gap` 27 → **30**、`deferred` 20 → **21**（构成：13 done + 4 core + 1 deferred + 14 excluded + 3 gap = 35，与档位增量逐条对得上），棘轮基线随 `--write` 降到 161——**只许降这条是真的在动**。

**第二批已落（10-10，`collection` + `map`(含 `map.multi`/`map.table`) + `comparator` 全 66 类）**：`unattested` 161 → **95**，构成 17 done + 13 core + 21 excluded + 1 deferred + 14 gap = 66，与档位增量逐条对得上（`done` +17、`core` +13、`excluded` +21、`deferred` +1、`gap` +14）。done 一律点名现读到的件（`coll.partition`/`page`/`group_by`/`distinct`/`distinct_by`、`mapx.CiMap`/`Table`/`filter_map`、`typex.Version`）；excluded 是 JDK 接口适配、反射代理、并发与弱引用那批（`EnumerationIter`/`SpliteratorUtil`/`NodeListIter`/`MapProxy`/`SafeConcurrentHashMap`/`WeakConcurrentMap`/`PropertyComparator`…）；core 靠 `Array::iter`/`eachi`、`Array::sort_by_key`（本轮在 `builtin/array_sort.mbt` 核到）、`String::char_length`、`Map([...])` 字面量与 Option/二元组；**14 条判 gap 的全是“核不到对位件就不硬指认”**——`BoundedPriorityQueue`（无堆容器）、`FilterIter`/`IterChain`（惰性视图 core 有无 filter 没核到）、`CamelCaseLinkedMap`/`CamelCaseMap`/`TolerantMap`（键换形/容错 Map 没登记）、`FuncKeyMap`/`FuncMap`（函数值不能当 Map 键，本仓已核，要做先拍键等价口径）、`LinkedForestMap`/`TreeEntry`（随 tree 族）、`ComparatorChain`/`IndexedComparator`/`InstanceComparator`（通用链式与顺序表比较）、`WindowsExplorerStringComparator`（一整张规则表）。
涨的 9 条就是我抽验到的那批空头，已逐条落 `gap` 并写明证据：`Html4Escape`/`Html4Unescape`/`XmlEscape`/
`XmlUnescape`/`InternalEscapeUtil`/`NumericEntityUnescaper`/`LookupReplacer`/`ReplacerChain`/`StrReplacer`
（HTML/XML 实体与查表替换都是纯串面，能做，血统是 Apache Commons Text）。

**第三批已落（10-10，date 族 25 类：`date` 14 + `date.format` 9 + `date.chinese` 2）**：`unattested` 95 → **70**，构成 12 done + 4 excluded + 2 deferred + 7 gap = 25，与档位增量逐条对得上（`done` +12、`excluded` +4、`deferred` +2、`gap` +7、`core` 不变）。done 全部点名 `date/pkg.generated.mbti` 现读到的件（`offset_*`、`begin_of_*`/`end_of_*`、`zone_names`/`zone_offset_minutes`/`zone_offsets_at_wall`、`parse*`/`format*`/`to_rfc3339*`、`clock_system`/`clock_fixed`、`week_of_year`/`is_weekend` 等）；两条 deferred 是 `ChineseMonth`/`LunarFestival`（农历码表在暂不做档）；7 条 gap 都写明缺什么：`BetweenFormatter`（时长差格式化串）、`DateRange`（区间逐日迭代）、`GlobalCustomFormat`（全局格式表——要做必须走 `set_default_zone` 那条显式可覆盖口径）、`GroupTimeInterval`/`TimeInterval`/`StopWatch`（有状态计时件，与本库“时钟显式注入 + G18 只放行一处裸读”冲突）、`Month`（12 月枚举本体要不要单建）。**这一批还纠了我自己一个抽取错**：第一版只 grep `pub fn ` 会漏掉 `pub fn Date::xxx` 这种方法形式，差点把 `offset_*`/`begin_of_*` 判成“没有该件”；改成按 73 个名字重抽才敢写 done。

**第四批已落（10-10，`io.checksum.crc16` 11 + `lang.hash` 4 + `codec` 11 共 26 类）**：`unattested` 70 → **44**，构成 14 done + 7 excluded + 3 gap + 2 deferred = 26，与档位增量逐条对得上。CRC16 那十个变体类统一指到 `hash.Crc16Variant` 的枚举档（`17-hash` §51 自己写着“对位十个 `CRC16*` 类”，本库是参数化状态机 + 枚举，不建十个同名件——**结构层差异、不是语义差异**，逐变体的初值/多项式读数在 §5 两侧都钉过）；`CRC16Checksum` 与 `Hash`/`Hash32`/`Hash64` 是 hutool 的基类与结果包装类，本库出口直接是数值 ⇒ excluded；`Hash128` 归 deferred（128 位族要先定 `Number128` 形状，17-hash §6 已记排期）；四个 `Base*Codec` 指到 `codec.b32_*`/`b58_*`/`b58_check_*`/`b62_*`/`radix_*`；`BCD` 沿用 codec 行的“不做”判定，`Decoder`/`Encoder` 是内部接口件；`Caesar`/`Rot`/`Morse` 落 gap（纯算法够得着却没登记，Morse 还要先拍码表落点）；`PunyCode` 归 deferred（IDN 在 codec 行已记“另批”）。

### 六批消化完毕（10-10）：`unattested` 归零，棘轮基线现在是 0

累计逐条指认 **226 类**（第一批 `convert.impl` 35 · 第二批 collection/map/comparator 66 · 第三批 date 族 25 · 第四批 crc16/lang.hash/codec 26 · 第五批 text 片 22 · 收尾批 exceptions/convert/builder/math/lang.id 22）。基线为 0 的意义：**今后任何包级规则想再整片算已做，+N > 0 立刻判红**，这条判据不可能悄悄松回去。

第五批（text 片 22）构成 7 done + 7 excluded + 5 gap + 3 deferred；收尾批（22）构成 5 done + 2 core + 15 excluded——`math.Arrangement`/`Combination` 指到 `num.arrangement_count`/`combination_count` 与 `allocate_by_ratio`/`allocate_even`，`lang.id.NanoId` 指到 `id.nano_id*`（熵由调用方注入），`Converter`/`ConverterRegistry` 指到 `conv.JsonConv[A]` 与 `conv.chain`（09-conv 明写「注册表换成一等闭包 chain」，对位 `ConverterRegistry:262` 的 `isCustomFirst`），`Builder`/`GenericBuilder` 判 core（就是一个 `() -> T` 与 consumer 闭包）；三个 `*Builder` 与 `TypeConverter`/`IDKey`/`NumberWithFormat` 判 excluded（反射、identityHashCode、ThreadLocal，全沿用仓内既有判例），六条 `*Exception` 判 excluded（本库错误面一律 raise 具名档；`ValidateException` 另按 valid 包「码表类不 raise」的既定口径）。

**`gap` 从 18 涨到 59 是这轮的真实产出，不是退步**：原先这些格子被整片规则算成“已做”，逐条核下来一部分证实是别的包接的（转 done/core）、一部分证实没做（留 gap）。现在这张待拍清单能逐条读了，几族值得先说：
- **tree 族**（`TreeUtil`/`Tree`/`TreeNode`/`TreeBuilder`/`Node`/`NodeParser`/`DefaultNodeParser`/`LinkedForestMap`/`TreeEntry`）——纯算法不踩线，先拍“节点载荷用什么形状、weight 用什么比较类型”；
- **纯字符串面小件**（`UnicodeUtil`、`EscapeUtil` 的 HTML/XML 实体、`FileNameUtil` String 档、`codec` 的 `complete_url`/`data_uri`）——工作量小、判据好冻；
- **计时与状态件**（`StopWatch`/`TimeInterval`/`GroupTimeInterval`/`GlobalCustomFormat`）——与本库“时钟显式注入、G18 只放行一处裸读”冲突，要做先拍口径；
- **查找器族**（`CharFinder`/`StrFinder`/`TextFinder`/`LengthFinder`/`CharMatcherFinder`）——“从起点找、返回位置”的语义没拍过；
- 其余散件（`BoundedPriorityQueue`、`ComparatorChain`/`IndexedComparator`/`InstanceComparator`、`WindowsExplorerStringComparator`、`Month`/`YearQuarter`、`DurationConverter`/`PeriodConverter`/`EntryConverter`、`Caesar`/`Rot`/`Morse`、`ObjectUtil`/`URLUtil` 的纯串那半等）。

口径照旧：**没核到对位件就不写 done，也不硬指认 core**——宁落 gap。

- 取法：`python scripts/core_surface.py --write` 生成 `docs/spec/core-surface.tsv`（类名｜全限定名｜档｜一句话理由）；`--check` 既查漏档也查"表与 jar 类面漂移"；判状态只认 jar，不依赖 `javap`。
- 版本口径：census 用 **hutool-all 5.8.37**，且这版类面已固化成仓内生成物 `docs/spec/hutool-classes.tsv`（头两行记 `version` 与 `sha256`）；日常判据离线跑，不再联网取 jar。`scripts/core_surface.py` 的常量 `REF_VERSION` 与清单头不一致就判红——这条是 10-09 补的：当时有人拿 5.8.35 去核对 5.8.37 的表，造出一条"表里有 jar 里没有"的假红（一份件覆盖全部 artifact，`$HUTOOL_JAR` 指它），而各包参照腿多数是 5.8.35——**类面是普查、读数腿是逐包**，两件事不同源，换版本时 `--check` 的漂移格会先报出来。
- `gap` 这 18 条就是本轮新登记的欠账（此前四处文档一个字没提）：`TreeUtil`/`Tree`/`TreeNode`/`TreeBuilder`/`TreeNodeConfig`/`Node`/`NodeParser`/`DefaultNodeParser`（扁平列表构树族）、`EscapeUtil`（HTML/XML 实体）、`UnicodeUtil`（`\uXXXX`）、`FileNameUtil`（主名/扩展名/前后缀这类纯路径串档）、`URLUtil`（`isUrl`/`getSuffix`/参数串那半，组装与归一已由 codec 承接）、`ObjectUtil`/`ObjUtil`（null-safe 族：`Option` 惯用法替不掉的那几条）、`YearQuarter`/`TemporalUtil`、`BitStatusUtil`/`RingIndexUtil`。
- 这一节的**初稿被自己的判据抓回去一次**：初稿把 `PadUtil`/`ValidateUtil` 也写进 `gap` 清单，`--check` 的死条目判据（覆盖表里不许有 jar 中不存在的类名）当场点名——那两名在 5.8.37 的 `cn.hutool.core.**` 里根本不存在，连同另外 35 个凭记忆写的对位名一起清掉。**"凭记忆建表"第四次应验，这次是新加的判据第一次跑就抓到作者**，留在这里当反面样本。
- 判据自证四档（`--selftest`）：① 现表零漏档才放行；② **抽一个"由包级规则落档"的类，撤掉那条规则后它必须掉进漏档**——没这条对照，"全部落档"可能只是某条规则在永真兜底；③ 覆盖表里出现 jar 中不存在的类名必须被点名（防凭记忆建表，本仓已犯三次）。jar 取不到或类面为空 ⇒ `SKIP`（退出码 2），不给通过。

## 7b. 参照版本口径（唯一）

<!-- hutool-reference-version: 5.8.37 -->

本库对位的参照实现版本**只有一个口径：hutool 5.8.37**。三处必须同版，由机器钉：
`scripts/core_surface.py` 的 `REF_VERSION`、仓内类面清单 `docs/spec/hutool-classes.tsv` 的 `# version` 头、
以及上面那行声明（G16 自检④现在同时核对这三处，并把"声明被改回旧版"和"声明被删掉"两档都做成必被抓）。

**为什么 10-09 才统一**：既有 22 份 spec 的读数量出自 5.8.35 的 jar（65 处句子写着 `hutool-*-5.8.35.jar`），
而 10-09 把 G16 的类面 census 钉在 5.8.37——两套号并存过一整轮，期间我自己就拿 5.8.35 的 jar 去核对 5.8.37 的表，
把 `VersionUtil`/`YearQuarter` 误判成"表里多出来的死条目"（判据没错，错在没人拦"用错版本去核对"）。

**统一之前先量了代价**（16 支参照腿各跑两版，逐字节比输出；腿是 `scripts/*Leg*.java`，
姿势：`javac -encoding UTF-8 -cp <hutool-all-<ver>.jar> -d <cls> scripts/<Leg>.java`
再 `java -Dfile.encoding=UTF-8 -cp <jar>;<cls> <Leg>`）：

| 对撞结果 | 条数 | 说明 |
|---|---|---|
| 逐字节相同 | 13 | 含最大的几条：`Cron2Leg` 2614 行、`FormatLeg` 1409 行、`Num4Leg` 610 行、`RePoolLeg` 443 行 |
| 只差墙钟量 | 2 | `TzLeg` 差一行 `B\tLEG_MS\t2411` vs `2381`（腿自己的耗时采样）；`Cron5Leg` 差 `firstHitWaitMs=700` vs `500`（首次命中的等待量，另有 hutool 自带 DEBUG 时间戳若干行） |
| 类面差 | — | 顶层类 5.8.35=630、5.8.37=632：**只多 `VersionUtil`、`YearQuarter`，零删除** |

**结论：统一版本 = 零期望值改动。** 那两个墙钟量在 `*_test.mbt` 与全部 spec 里 grep 命中都是 **0**
（它们只是腿自己的诊断输出，从来没进契约），所以没有任何一条已冻期望需要动。

**历史留痕不改写**：各包 spec 里"本批读数取自 5.8.35 的 jar"这类句子是**取数来源的记录**，照原样留着——
把它们批量改成 5.8.37 等于伪造来源。它们的有效性由本节这次对撞兜住：同一支腿在两版上读数逐字相同。
今后新腿一律钉 5.8.37。

## 8. 整模块不做（写进 README 的「不承诺清单」）


`bean`/`annotation`/`reflect`/`getter`/`compiler`/`aop`/`script`/`MapProxy`/序列化式 `clone`（**无运行时反射/动态代理**）；`io.FileUtil`/`IoUtil`/`CharsetUtil.convert`/`watch`/`net.NetUtil` 本机 IP/`ThreadUtil`/`system`（**需要 FFI 与 OS 线程**）；`http`/`db`/`socket`/`poi`/`captcha`（AWT 栅格化）/`extra`/`log`（跨栈定位不同：web 走 moonback、DB 走 moondb/moonmysql）。

Bean 拷贝在 MoonBit 侧的正确姿势：`derive(ToJson)/derive(FromJson)`（**语言内置，非第三方宏**）或手写 `to_map/from_map`。
