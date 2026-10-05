# 11 · `valid` —— 码表判定件（第一批）

> 状态：**已实现**（10-05 两笔：契约 `a772ca9`、落地见 `docs/ROADMAP.md` 第 11 行）。5 块 + 6 个文档块全绿（三档 333 条一致），公开接口在 `valid/pkg.generated.mbti`（`moon info` 后零漂移）。
> 对位 hutool `cn.hutool.core.lang.Validator`；公开接口在 `valid/pkg.generated.mbti`（`moon info` 后零漂移）；
> 冻结期望值在 `valid/valid_test.mbt`（5 块 127 条断言，每条由生成器从两腿读数文件取，手打零条）。
> 文件名序号 11 ＝ 该包在 `docs/ROADMAP.md` 逐包表里的行号（稳定 ID，门禁 G13 守）。

## 0. 五条贯穿性规则

1. **判定件不 `raise`**。码表是本包内部常量，编译失败只能是本包写错，不是调用方的输入问题——
   所以不把 `re` 的 `ReError` 泄到这一层（对位 hutool：`Validator.isXxx` 全部返回 `boolean`，同一档）。
2. **码表逐条改写成 core 方言，并逐条对撞命中集**。hutool 的判定几乎全走 `RegexPool` 常量，
   而实测这些常量 **34 条里 24 条带 core 不收的写法**（`\d` 18 / `\w` 4 / `\xHH` 2，普查见 `10-re.md` §4 第 7 条）。
   本批只收"改写后两腿命中集逐条相同"的 15 件——**0 条分岔不是假设，是对撞出来的结果**（§4）。
3. **整串语义**。hutool 的 `isXxx` 全部是 `Matcher.matches()`（整串），不是 `find()`；本包同档。
   参照实现里唯一走 `find()` + 取组的是 `isBirthday(CharSequence)`，那一件连同它的时钟依赖一起留第二批（§1）。
4. **不建全局模式池**，与 `re` §0.1 同一条立场：要缓存由调用方自己持有。
5. **大小写不敏感只按 ASCII 档**。参照实现用 `Pattern.CASE_INSENSITIVE`（不带 `UNICODE_CASE` 时就是 ASCII 档），
   本包改写成的 scoped `(?i:…)` 折叠范围与它同档（实测 `(?i:é)` 不匹配 `É`）⇒ 这条**不构成分岔**，
   但写法必须换：全局 `(?i)` 在 core 是编译期报错（`10-re.md` §5 第 1 行）。

## 1. 边界：本批收什么、不收什么

| 面 | 收 | 不收，以及为什么不收 |
|---|---|---|
| 判定件 | 15 件正则族（§3 全表）：字母/通用名/金额/邮编/手机/IPv4/IPv6/MAC/UUID/十六进制/VIN/驾驶证档案号/车牌 | `is_email`（码表含 `\xHH` 类，改写后要逐条对撞的样本量最大，第二批）；`is_chinese`/`has_chinese`/`is_general_with_chinese`/`is_chinese_name`（`CHINESE` 常量在 javac 预处理后落成**代理对码元区间**，字符串字面量本身就要重新表达，第二批）；`is_letter`/`is_upper_case`/`is_lower_case`（参照实现是 `Character.isLetter/isUpperCase/isLowerCase`，**Unicode 类别表**；core 只有 ASCII 档谓词 `is_ascii_alphabetic`/`is_ascii_uppercase`，照抄会把 `ì`、`ā`、`中` 判错——要么引码表要么明写"只承诺 ASCII 档"，这一条得先拍口径）；`is_birthday`（`find()` + 取组 + 闰年 + `DateUtil.thisYear()` **读时钟**，与"时间一律显式传参"的本库立场冲突，界值得进签名）；`is_url`（参照实现走 `java.net.URL` 构造器的协议解析器，正则 `URL`/`URL_HTTP` 只是导出字段、`isUrl` 根本没用它们——实测） |
| 校验类 | — | hutool 那 79 个 `public static` 里 **38 个是 `validateXxx(value, errorMsg)` 抛 `ValidateException` 的变体**，还有 18 个是 null/empty/equal/true/false 这类与"码表"无关的存在性判定。本库错误面由调用方自己决定（`Option`/`Result`/自带错误档），不搬 `errorMsg` 模板那一套 |
| 数值/其它 | — | `is_number`/`has_number`（参照实现是 `NumberUtil` 里手写的字符扫描器，认 `0x` 十六进制与 Java 的 `f`/`d`/`L` 类型后缀）留第二批：要先与 `conv` 的数值文法对齐成一张嘴，不能一处两判；`is_between`（纯数值区间，与正则无关）同批；`is_citizen_id`/`is_credit_code` 的实质是 **mod-11 / mod-31 校验位 + 区划码表**，归 ROADMAP 第 19 行 `typex`（`IdcardUtil`/`CreditCodeUtil` 的对位在那里），不在本包重复建表 |

## 2. 错误面

无。15 件全是 `String -> Bool`（两件限长的多两个 `Int` 参数），按 §0.1 不 `raise`。

## 3. 逐件矩阵（#11.1~#11.15）

"码表"列给的是**改写进本包的那条 core 方言模式**；它对应的 hutool 常量名在括号里，
常量源文与 `flags` 由参照腿自己吐出（`valid_ref.txt` 的 `src` 行），不手抄。

| # | 签名 | 码表（core 方言） | 读数摘要 | 对位 |
|---|---|---|---|---|
| 11.1 | `is_word(String) -> Bool` | `[a-zA-Z]+` | `"abc"`/`"ABC"` ⇒ `true`；`"abc123"`/`"a_b"`/`"123"`/`"中文"`/`"ì"` ⇒ `false`（9 样本两腿同） | `Validator.isWord`（`WORD`） |
| 11.2 | `is_general(String) -> Bool` | `^[[:word:]]+$` | `"abc_123"`/`"A"`/`"_"` ⇒ `true`；`""`/`"a b"`/`"a-b"`/`"中文x"`/`"ab\t"` ⇒ `false`（9 样本两腿同，`\w → [[:word:]]` 命中集相同） | `Validator.isGeneral`（`GENERAL`，源码是 `^\w+$`） |
| 11.3 | `is_general_between(String, Int, Int) -> Bool` | `^[[:word:]]{min,max}$`（运行时拼接） | 界值 1/3 的读数与 11.2 同族；**`max` 不建界**——core 的量化上界是硬限制（实测 `a{256}` 合法、`a{300}` 编译报错），超界属调用方问题 | `Validator.isGeneral(v,min,max)`（拼 `"^\\w{"+min+","+max+"}$"`，实测源文） |
| 11.4 | `is_general_at_least(String, Int) -> Bool` | `^[[:word:]]{min,}$` | 同上（9 样本两腿同） | `Validator.isGeneral(v,min)` |
| 11.5 | `is_money(String) -> Bool` | `^([[:digit:]]+(?:\.[[:digit:]]+)?)$` | `"0"`/`"1"`/`"1.2"`/`"1.22"` ⇒ `true`；`"1.222"`/`".5"`/`"-1"`/`"a"`/`""`/`"中文"`/`"1,000"` ⇒ `false` | `Validator.isMoney`（`MONEY`） |
| 11.6 | `is_zip_code(String) -> Bool` | 地区前缀表 + `99907[78]`（`\d → [[:digit:]]`） | `"100000"`/`"999077"`/`"999078"` ⇒ `true`；`"999079"`/`"12345"`/`"1234"`/`"0100000"` ⇒ `false` | `Validator.isZipCode`（`ZIP_CODE`） |
| 11.7 | `is_mobile(String) -> Bool` | `(?:0|86|\+86)?1[3-9][[:digit:]]{9}` | `"13800138000"`/`"86…"`/`"+86…"`/`"0138…"` ⇒ `true`；位数不足/`12345678901`/`138001380001` ⇒ `false` | `Validator.isMobile`（`MOBILE`） |
| 11.8 | `is_ipv4(String) -> Bool` | 四段 `25[0-5]|2[0-4]…` 逐段界值（`\d → [[:digit:]]`） | `"192.168.1.1"`/`"255.255.255.255"`/`"0.0.0.0"` ⇒ `true`；`"256.1.1.1"`/`"1.1.1"`/`"1.1.1.1.1"`/`"01.01.01.01"`/`"1.1.1.1 "` ⇒ `false` | `Validator.isIpv4`（`IPV4`） |
| 11.9 | `is_ipv6(String) -> Bool` | 那条 610 字符的择路式**一字未改**（源码不含 `\d`/`\w`，实测） | `"::"`/`"::1"`/`"2001:0db8:…:7334"`/`"fe80::1%1"` ⇒ `true`；`"1.2.3.4"`/`"gz::1"`/`"2001:db8::::1"` ⇒ `false` | `Validator.isIpv6`（`IPV6`） |
| 11.10 | `is_mac(String) -> Bool` | 四段择路，分隔符写成 `(:\|-)`（见 §4 第 3 条）+ `(?i:` 包整条 | `"00-11-22-33-44-55"`/`"00:11:22:33:44:55"`/`"0011.2233.4455"` ⇒ `true`；`"0x112233445566ETHER"`/`"00-11-22-33-44"`/`"gg:…"` ⇒ `false` | `Validator.isMac`（`MAC_ADDRESS`） |
| 11.11 | `is_uuid(String) -> Bool` | `(?i:^[0-9a-f]{8}-…-[0-9a-f]{12}$\|^[0-9a-f]{32}$)`（**两形状并起来**，见 §4 第 4 条） | 带横线与 32 位无横线两种、含混合大小写 ⇒ `true`；少一位、多尾巴、空串、`"中文"` ⇒ `false`（11 样本两腿同） | `Validator.isUUID` |
| 11.12 | `is_hex(String) -> Bool` | `^[a-fA-F0-9]+$` | `"1a2B3c"`/`"ABCDEF0123456789"` ⇒ `true`；`"g"`/`""`/`"0x1a"`/`"中文"` ⇒ `false` | `Validator.isHex`（`HEX`） |
| 11.13 | `is_car_vin(String) -> Bool` | `[[:digit:]]` 改写 + 排除 `I/O/Q` 的字符类 | 17 位合法 ⇒ `true`；16/18 位、含 `I/O/Q` ⇒ `false` | `Validator.isCarVin`（`CAR_VIN`） |
| 11.14 | `is_car_driving_licence(String) -> Bool` | `^[0-9]{12}$` | 12 位数字 ⇒ `true`；11/13 位、字母 ⇒ `false` | `Validator.isCarDrivingLicence` |
| 11.15 | `is_plate_number(String) -> Bool` | 省简称表 + 序号段（`\d → [[:digit:]]`） | `"京A12345"`/`"京AF12345"`/`"粤Z1234港"` ⇒ `true`；`"京A1234"`/`"A12345"`/`""`/`"中文"` ⇒ `false` | `Validator.isPlateNumber`（`PLATE_NUMBER`） |

## 4. 两条腿与本批统计

1. **腿 A · 参照实现**：真 `hutool-core-5.8.35.jar` + 本机 JDK 17.0.14 跑 `Validator`
   （驱动 `ValidRef.java`，读数 `valid_ref.txt` 393 行）。它**同时吐出** `RegexPool`/`PatternPool`/`Validator`
   三个类里每条 `Pattern` 的源文与 `flags`——码表来源是机器读的，不是我抄的。
2. **腿 B · 运行时引擎**：core `@string.Regex` 探针（驱动 `vproj`，读数 `vp_wasm.txt`/`vp_js.txt`/`vp_wasm-gc.txt`
   各 242 行，**三份逐字节相同**）。匹配口径与本包契约一致：`^(?:P)$` 整串。
3. **实测出来的改写规则：字符类里的 `-` 不能与别的字符并排**。hutool 的 `[:-]`（冒号或连字符）在 core
   **编译期报错**——二分探针逐条量过：`[-:]`、`[:-]` 两种写法都报 `ERR`，改成择路 `(:|-)` 才编得过，
   且改写后在 MAC 全部样本上与腿 A 命中集相同。
4. **实测纠正了一条对参照实现的假设**：`Validator.isUUID` 用的**不是** `UUID` 那条只覆盖"带横线"形状的常量——
   它在 11 条样本上同时认 32 位无横线与混合大小写。按 `UUID` 常量改写会在
   `"DCD01AC8892E4A4788D9F8ED2CB74EEE"` 上给 `false` 而腿 A 给 `true`。契约因此把两种形状并进一条码表（11.11），
   **改的是本包的表达，不是参照系**。
5. **对撞结果：15 件 / 127 条样本，一致 127 条、分岔 0 条。** 这一批没有 §5——不是没检查，
   而是"改写到命中集相同为止"，剩下的差异全在没进本批的那些件里（`is_email` 的 `\xHH`、`is_letter` 的 Unicode 类别、
   `is_birthday` 的时钟、`is_url` 的 `java.net.URL`）。它们各自的分岔在第二批逐条量。
6. **生成器带硬判据**：`emit_valid.py` 对"腿 A 缺样本"和"两腿读数不等"两条都 `assert` 直接终止——
   不一致的夹具不会被静默塞进期望值（`num` 第三轮那条规矩的延续）。

7. **实现轮的三条变异对照**（本机现跑，跑完按 sha256 字节还原）：`is_uuid` 退回"只认带横线"那一档 ⇒ 2 块红（冻结块 + 文档块）；MAC 分隔符写回 `[:-]` ⇒ 2 块红（这条红的是内部不变量终止，等于"改写规则本身有人看着"）；`is_ipv4` 首段放宽成 `[[:digit:]]{1,3}` ⇒ 2 块红（`256.1.1.1` 必须倒）。**每条都有块红，规则才不是纸面上的。**
8. **文档页自己也会写错两条**：我先写的 `is_money("1.222") ⇒ false`（以为金额限两位小数）与`is_ipv4("01.01.01.01") ⇒ false`（以为前导零不算），都被真跑打回 `true`——两条在 `valid_test.mbt` 里本来就有正确读数（第 59、90 行）。**文档页的期望值不许凭常识写**，要么取自语料，要么先跑一遍。
9. **顺带把两件参照实现的真实形状记进 §3**：金额的小数位**不封顶**（`MONEY` 是 `([[:digit:]]+(?:\.[[:digit:]]+)?)`），IPv4 每段允许 1~3 位数字 ⇒ 前导零照收。

## 5. 不跟随清单

本批为空（见 §4 第 5 条）。设计上不搬的东西记在这里，免得被当成漏实现：

| # | 分岔 | hutool | 本包 |
|---|---|---|---|
| 1 | `validateXxx(value, errorMsg)` 那 38 个变体 | 抛 `ValidateException`，errorMsg 走 `{}` 模板 | 不做：错误面由调用方决定 |
| 2 | 存在性判定（`isNull`/`isEmpty`/`equal`/`isTrue`…18 个） | 与码表无关的 `Object` 判等 | 不做：MoonBit 有 `Option`/`==`，搬过来是噪音 |
| 3 | 全局 `PatternPool` 缓存 | 进程级 `WeakKeyValueConcurrentMap` | 不做（§0.4） |
| 4 | `ValidatorSetting`/`validator-setting.json` | —— | **实测不存在**（5.8.35 jar 里只有 `Validator`/`PatternPool`/`RegexPool` 三个类，无资源文件），码表就是编译期常量 |

## 6. 分批与状态

| 批 | 内容 | 状态 |
|---|---|---|
| 第一批（本节） | #11.1~#11.15，15 件、5 块冻结期望值（127 条断言）+ 6 个文档块 | **已实现**（10-05 两笔） |
| 第二批 | `is_email` 一族（`\xHH` 类改写）、中文族（代理对码元区间）、`is_number`/`has_number`（与 `conv` 数值文法对齐成一张嘴）、`is_between` | 未开工 |
| 待拍 | `is_letter`/`is_upper_case`/`is_lower_case`：引 Unicode 类别码表，还是明写"只承诺 ASCII 档" | 未定，先不进契约 |
| 待拍 | `is_birthday`：`DateUtil.thisYear()` 这条时钟腿怎么改写成显式传参（本库"时间一律显式传"的立场见 `03-date.md`） | 未定，先不进契约 |
| 移交 | `is_citizen_id`/`is_credit_code` 的校验位与区划码表 | 归 ROADMAP 第 19 行 `typex` |

## 7. 索引与读数

| 内容 | 位置 |
|---|---|
| 期望值（冻结） | `valid/valid_test.mbt` 的 5 块，由 `emit_valid.py` 从两腿读数文件灌入 |
| 码表来源 | 腿 A 自吐的 `src` 行（`valid_ref.txt`）+ 逐条改写对照（`valid_rewrite.txt`） |
| 普查依据 | `10-re.md` §4 第 7 条（`RegexPool` 34 条里 24 条带 core 不收的写法） |
| 状态句与读数 | `docs/ROADMAP.md` 的生成块（`scripts/sync_status.py --write`） |
| 门禁 | `scripts/contract_gate.sh` 的 G1~G13；本批落地前后 `BASELINE_TESTS` 的变动记在门禁头注 |
| 包内导航 | `README.md` 的包索引行、`valid/README.mbt.md`（6 个 doctest 块，实现轮补） |
