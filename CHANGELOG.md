# Changelog

本文件记录 moon-hutool 的对外可见变化。版本号遵循语义化版本；格式参考 Keep a Changelog。

约定两条，与 `AGENTS.md` 的两条红线一致：

- **公开件签名只前进**：`.mbti` 里既有件的签名不改；要改必须另开主版本。
- **期望值冻结**：断言右侧（参照读数）不因实现而改；确需更正，单独一条并在对应 spec 里写清外部读数来源。

## 0.1.3（2026-10-16 · `hash` 第二批 CRC32 + `digest` 流式/增量入口）

- **`hash` 新增 CRC32 九件**（需求登记：本仓 Issues #2，七牛 Kodo 客户端的块级校验）：`Crc32` 累加器 +
  `new_crc32` / `crc32_update` / `crc32_update_range` / `crc32_update_byte` / `crc32_value` / `crc32_reset`
  + 一次性 `crc32_of_bytes` / `crc32_hex`。**标准 IEEE 802.3 反射位序**（与 `java.util.zip.CRC32` / `zlib.crc32`
  / GZIP 同值），归口落 `hash` 而不是 issue 原文写的 `digest`——CRC 族（`Crc8`/`Crc16`）在本包，`digest` 的
  既定口径是无状态摘要。本件**没有 hutool 对位**（类面清单现读），属基础件补位，所以取向与"照参照的非标准
  CRC8"相反，反差记在 `docs/spec/17-hash.md` §5 第 7 行。出口是无符号 32 位放进 `Int64`（恒 `0..4294967295`，
  零扩展），十六进制恒八位小写零填充。期望值由官方公布值 + Python `zlib` + JDK `java.util.zip.CRC32`
  三级对撞后冻结，分段判据跑到 `1..N` 全档；变异 4/4 抓红（§8）。
- **`digest` 新增流式/增量入口 12 件**（需求登记：本仓 Issues #3——秒传查重要算整份、分块上传要逐块边读边喂，
  一次性入口会逼调用方把整份留在内存里）：`Md5Ctx` / `Sha1Ctx` / `Sha256Ctx` 各 `new` / `update` /
  `finish` / `finish_hex`，加一个 `DigestError::AlreadyFinished`。三个上下文共用同一台私有状态机
  （链字 + 不足一个分组的尾巴 + 长度位 + 已收尾标记），padding 与长度位只有一份实现；
  **一次性入口改造成同一台机器的另一个出口**，所以"分段与整份同值"不是巧合而是同一条代码路径。
  `finish` **幂等**（不改状态，重复调用同值），收尾后再 `update` 走**明确报错**而不是默默续算——
  这两档都是 issue 点名的坑，分岔两侧行为都记在 `docs/spec/02-digest.md` §2.9。
  判据：长度 `0/1/55/56/63/64/65/119/120/1000000` 全档、分段 `1..N` 全档加四张确定性长度表、
  与一次性入口逐字节对拍；官方向量一条未新造，全部是本仓已冻那批的重放。
- `digest` 的这条同时是对本仓旧写「core 无 io ⇒ 不做带状态写接口」的**翻案**：`io` 挡住的是读流，
  不是可续算的状态。`docs/ROADMAP.md` 的「暂不做」清单已摘掉该项，`mac` 行与 `00-hutool-map` 两处
  引用旧原句的地方就地更正（判不建 `mac` 包的结论不变）。

## 0.1.2（2026-10-15 · digest 第三批 SHA-1 + HMAC-SHA1；全仓随 moonc 0.10.15 迁移）

- **`digest` 新增 SHA-1 与 HMAC-SHA1 八件**：`sha1_bytes` / `sha1_hex` / `sha1_of_bytes` 与 `hmac_sha1_bytes` / `_hex` / `_of_bytes` / `_hex_of_bytes` / `_verify_hex`——与既有 md5/sha256 三件套、hmac_sha256 族逐件同形；HMAC 侧共用同一台 pad/xor 机器。官方向量＝NIST 示例文档（FIPS 180-4 附录 A.2 指向）＋ RFC 3174 §7.3 ＋ RFC 2202 §3 全七条，期望值先与 `hashlib`/`hmac` 现算两级对撞后冻结、实现笔零改写；变异 7/7 抓红（`docs/spec/02-digest.md` §2.8）。
- **全仓随 moonc 0.10.15 做显式宽度迁移**（源码拼写层）：`Int`→`Int32`、`UInt`→`UInt32`，另含 `? :`→`~ :` 与 `..=`→`..<=` 两处语法换代。**.mbti 零变化、公开签名零漂移**——迁移是纯机械改名（归一化逐字节相等 + 阴性对照见该笔提交信息）。

## 0.1.1（2026-10-11 · codec 批③ 片一落地）

- **`codec` 的 `caesar_encode` / `caesar_decode` / `rot_encode` / `rot_decode` / `rot13_encode` / `rot13_decode` 从契约骨架落地为真实现**（0.1.0 里这六件调用即 `abort`）。`decodeChar` 的三段归一策略各不相同（数字段/大写段 `while` 补到非负、小写段 `if` 只补一次 26 落 `(char)` 16 位回绕），照 hutool 5.8.37 真源码逐字直译，腿读数一条没动；变异对照 8/8 抓红（`docs/spec/05-codec.md` §13.5 回填）。
- **`caesar_decode` 签名收窄**：去掉 `raise CodecError`（decode 恒有解，spec §13.1"从不抛"与旧签名自相矛盾；0.1.0 该件是 abort 体从未可用）。`ShiftUnderflow` 只挂在 `caesar_encode` 上。
- **期望面三处更正**（单独证据，见对应提交信息）：`rot13_encode("")`／`rot13_decode("")` 两处空夹具期望被生成脚本的 `rpartition("||")` 塌缩解析灌成了腿行判别尾巴（`true?1|false?1`／`dec13selfinv|1`），更正为空串；`cc3` 夹具助手从"码位数组"更正为"UTF-16 码元数组"（😀 夹具 `[55357,56832]` 是代理对两半，按码位构造会炸）。

## 0.1.0（2026-10-11 · 首发）

首个对外版本，包数与用例条数以 `docs/ROADMAP.md` 的逐包表与生成读数块为准（`moon test --target wasm` 现读，不写死——本节初稿的「672」已被后续补档越过多轮）。**除 `sched` 外**的包零第三方依赖、零 `extern`、全同步、四目标可编译（wasm / wasm-gc / js / native）；`sched` 依赖官方 `moonbitlang/async`（触发面绕不开事件循环），只承诺三档（wasm / js / native），`wasm-gc` 档该依赖没有异步可执行入口（`moon check` 能过，`moon run`／`moon test` 报 `[4021] Value run_async_main not found`），已按包级 `supported_targets` 摘掉那一档。

| 包 | 对位 | 这一版给了什么 |
|---|---|---|
| `text` | `StrUtil` / `CharSequenceUtil` / `NamingCase` / `StrFormatter` / `EscapeUtil` / `text.UnicodeUtil` / `util.CharUtil` / `text.replacer.*` | 空白与裁剪档、`{}` 占位格式化、命名法互转、`sub_*` 取段、`hide`（码位档）、逐段数值版序比较；**10-10 批①再加 14 件**：实体转义四件（`escape_xml`/`unescape_xml`/`escape_html4`/`unescape_html4`）、百分号转义五件（`escape`/`escape_all`/`escape_by`/`unescape`/`safe_unescape`）、`\uXXXX` 四件（`to_unicode`/`to_unicode_all`/`unicode_of`/`unicode_to_string`）、`encode_blank`、替换引擎三件（`lookup_replacer`/`replacer_chain`/`Replacer::replace`）+ `is_blank_char` 转公开。两笔落地：契约笔冻 699+18+62 条期望（全由参照腿灌），实现笔只把红变绿、期望串零改写。判据面 `docs/spec/01-text.md` §1.15~§1.20 |
| `digest` | `DigestUtil`（MD5 / SHA-256 / HMAC） | MD5/SHA-256 全套 + HMAC 家族八件（含裸字节键与常量时间校验）；输入固定 UTF-8；**10-15 第三批新增 SHA-1 三件 + HMAC-SHA1 五件**（官方向量 NIST 示例文档 + RFC 3174 §7.3 + RFC 2202 §3，两级对撞后冻结；已随 0.1.2 落地） |
| `date` | `DateUtil` / `CalendarUtil` / `DatePattern` / `DateUnit` | 整包自研日历与格式化（core 无 time 包）+ 内置 IANA 时区段表（603 区 / 36,701 段）+ 可注入时钟源 + 默认区三级降级（`set_default_zone` → `TZ` → 兜底）；**10-10 第六批再加 54 件**：`StopWatch` 秒表一面（含 `TaskInfo`、`ChronoUnit` 七档）、`GroupTimeInterval` 一个类型承参照 `TimeInterval`+`GroupTimeInterval` 父子两面、`format_between` 时长说中文、`GlobalCustomFormat` 对位的全局格式表八件并挂进 `format_in`/`parse_in`。两笔落地：契约笔冻 351 条期望（全由五条参照腿灌），实现笔只把红变绿、期望串两处就地更正单独一笔。计时件**一处都不读时钟**，读数一律注入 `() -> Int64`；判据面 `docs/spec/03-date.md` §9 |
| `id` | `IdUtil` | 雪花、UUID v3/v4、ObjectId、NanoId；时钟与熵全显式注入 |
| `codec` | `Base64` / `Base32` / `Base58` / `Base62` / `RadixUtil` / form / URL / `URLUtil`(部分) | url-safe 与 MIME 档、严格/宽松双档解码、表单 `+` 档、URL 结构化组装与语法归一；**10-10 批①新增 data URI 两件**（`data_uri` / `data_uri_base64`，150 条冻结期望）；**10-10 批③ 片一新增移位七件**（`caesar_table` / `caesar_encode` / `caesar_decode` / `rot_encode` / `rot_decode` / `rot13_encode` / `rot13_decode` + 错误面一个 `ShiftUnderflow(Int)`，3222 条冻结期望由四条腿灌，含一张 BMP 字母判定表 `codec/letter_table.mbt`——契约笔已冻，实现笔紧随）。`URLUtil.completeUrl` **判 deferred**——实测它把"是不是绝对 URL"委托给 `java.net.URL` 的协议白名单，不是纯串面（读数与理由：`05-codec.md` §12.2）|
| `coll` | `CollUtil` / `ListUtil` / `IterUtil` 高频子集 | 分组、两桶划分、保序去重与按键去重、频次表、分页、数组版并/交/差、极值与按键极值 |
| `mapx` | `MapUtil` / `Table` / `BiMap` / `CaseInsensitiveMap` | `BiMap`（双向唯一 + 显式 `force_put`）、`CiMap`、`Table`（行列双索引）、`filter_map` / `rename_key` |
| `num` | `NumberUtil` / `NumberChineseFormatter` / `MathUtil` / `Calculator` / `Money` | 数论件与七档舍入、千分位/百分比/薄 `Money`、中文数字四模式与反向解析、英文 word、十进制精确表达式求值 |
| `conv` | `Convert`（无反射版） | `Json` → 7 类标量宽松转换、`get_by_path` / `field` / `get_ids`、一等闭包 `chain` 组合 |
| `re` | `ReUtil` / `PatternPool` / `RegexPool` | 24 件正则门面 + `ReError` 两档；`RegexPool`/`PatternPool` 常量表按封闭规则表离线改写（不自动改写调用方的串） |
| `valid` | `Validator` 正则族 | 15 件合法性判定，码表为包内常量、无错误面 |
| `rand` | `RandomUtil` / `WeightRandom` | 19 件，随机源显式注入、库内一次都不取熵；常量表原样 + 单点定义域 + 与流无关的不变量 |
| `dfa` | `WordTree` / `SensitiveUtil` | 词树构建与七档查询、停顿字符表；`(density, greed)` 三档语义 |
| `path` | `AntPathMatcher` + `io.file.FileNameUtil`(String 档) | 10 件 + `PathOptions` + `PathError` 四档；默认档跟随 hutool（`trimTokens=false`）；**10-10 批①新增文件名六件**（`name_of`/`main_name`/`ext_name`/`clean_invalid`/`contains_invalid`/`is_type`，263 条冻结期望；`File` 重载判 excluded）|
| `cache` | `Cache` + FIFO/LRU/LFU/Timed/NoCache | 23 件公开面；时钟由调用方显式传 `now`，`prune` 三档语义各按其参照 |
| `hash` | `HashUtil` + murmur/city/metro + CRC8/CRC16 族 | 45 件（含 2 枚举 2 记录）；返回值一律有符号，与参照读数十进制逐字同形。**10-16 第二批 CRC32 九件契约已冻结**（需求登记：本仓 Issues #2；标准 IEEE 802.3 反射位序，官方向量 + `zlib` + JDK `java.util.zip.CRC32` 三级对撞，判据见 `docs/spec/17-hash.md` §8） |
| `bloom` | `BitMapBloomFilter` + `filter/` + `bitMap/` | 位图/过滤器/聚合三层 23 件；哈希全部委托 `hash`，词数地板除截断跟随 |
| `cron` | `CronPattern` | 解析（5~7 段、`/ > - > ,`、别名、`L`）+ 匹配 + 下一瞬间两族 + `Part` 七档 + 建造器；只算不调度；带区名档与内置时区表打通 |
| `textsim` | `TextSimilarity` | 相似比与百分比（按实现的 LCS 口径，非莱文斯坦）、剥离集与判据件提到公开面 |
| `csv` | `CsvReader` / `CsvWriter` | RFC 4180 读写，API 只收 `String`/`Bytes`，不碰文件 |
| `ini` | `Props` / `GroupedMap` / `SettingLoader` | INI 面 + `Props` 的 Java Properties 严格语义（含畸形 `\u` 的错误档） |
| `typex` | `Version` / `PageUtil` / `Ipv4Util` / `DataSize` / `DesensitizedUtil` / `IdcardUtil` / `CreditCodeUtil` / `PhoneUtil` / `CoordinateUtil` | 109 件：版本序、分页、IPv4 族、手机/固话/港澳台号码族、统一社会信用代码、身份证校验与切片、数据容量与格式化、脱敏、坐标换算 |
| `sched` | hutool-cron 的调度族（`TaskTable` / `Scheduler` / `CronUtil` 面） | **已实现（12 块用例全绿，wasm/js 两档；件数现读 `sched/pkg.generated.mbti`）**：任务表三条并行键值 + `due_indices`（给定此刻该触发哪几条，纯函数）+ `scheduler_tick`/`start`/`stop` 触发壳；时钟与时延源一律注入。对位关系全部由 `javap -p` 现读 `hutool-cron-5.8.35.jar` 支撑，据此撤掉两处凭空对位（参照侧无 `CronStatus` 枚举、无 `TaskInfo` 类）；线程/反射/监听器/时间轮四族明写不收。契约 `docs/spec/24-sched.md` |

明确的精度与能力承诺变化点（详见各 spec）：

- `date` 的偏移承诺到整分钟（窗口内仅 `Africa/Monrovia` 一区两年不是整分钟，已作显式分岔双栏读数）。
- `date` 的内置时区段表改走**基准相对编码**（段起点存 `秒 - 2000-01-01`）：引用命名区的消费者产物从 491,053 B 降到 344,064 B（-147 KB，wasm-gc 实测），只用日历的消费者不受影响（未被引用的表本来就被链接器 DCE 掉，5,845 B 逐字节不变）；查表耗时不变，公开签名一字未动。读数与等价性凭据记在 `03-date.md` §5.9。
- `typex` 的坐标九件承诺相对误差 1e-15，**不承诺与 JVM 末位逐位相同**；10-09 又实测出跨宿主也不逐位相同
  （同一档 Linux glibc 的 `native` 与 `wasm`/`js` 在 `WGS84_BD09|-73.985428,40.748817` 那档差 1 ULP），
  所以承诺分两档写：同一宿主内逐位一致 ⇒ 精确字面量；跨 libm ⇒ 相对误差 1e-15，
  且这两档在测试里走带标签的显式判据而不是散落的 `is_close`（凭据与三条变异见 `docs/spec/23-typex.md` §17.10）。
- `re` 不假装 Java 方言、也不自动改写调用方的模式串；等价改写表只作为给调用方看的对照。
- **依赖口径改为包级**（10-09）：`AGENTS.md` 零依赖四条里「`moonbitlang/async` 也算第三方」那句撤下——真正的红线是「同步 + 零 OS 能力」（它撑着同一输入必同一输出这套可测性），而不是「官方 / 第三方」这个分类。例外只登记在 `sched` 一个包上，且 `async` 只准出现在触发壳；G1 判据随之从前缀白名单改成按包归属放行，并带四档自证（含 pin 了却没人用的悬空例外也要报红）。

## 未发布的部分

加密套件（AES/SM4/RSA/ECDSA/BCrypt/Argon2/PBKDF2）、SHA-512/SM3/SHA-3、压缩（gzip/zip）、农历与区划码表、非 UTF 字符集表、Excel、流式增量摘要 API 排在 `docs/ROADMAP.md` 的「暂不做」档；运行时反射类与文件/网络类**结构上不属于本库**（见根 `README.md` 的不承诺清单与 `AGENTS.md` 零依赖四条）。
