# 23 · typex —— `Version` 比较与 `PageUtil` 分页算式（第一批）

对位 hutool：`cn.hutool.core.lang.Version`、`cn.hutool.core.util.PageUtil`。
件都在 **hutool-core 一个 jar 里**（`unzip -l hutool-core.jar | grep -icE "lang/Version|PageUtil"` 现读 2），本格不另拉 artifact。
本文件第一批已落地：§2 是公开面，§3 的判据逐条挂腿读数标签，§5 是分岔（两侧读数都在），§6 是变异对照。

## 1. 边界

- **不收 IO / 反射 / 网络**：`Ipv4Util` 的 `list(...)`（IP 段展开成 `List<String>`，规模可达 2^31）与
  `NetUtil` 系（要探网卡/本机地址）不进本库；`Version` 的 `Serializable`/`hashCode` 一致性只测"同不同"这一位，
  不承诺跨进程稳定值。
- **分批**：第 23 行注里的九件按可移植性分四批——
  第一批 `Version` + `PageUtil`（本文件）；第二批 `Ipv4Util`（纯算式档：`ipv4ToLong`/`longToIpv4`/`getMask*`/`countBy*`/`isMaskValid`）；
  第三批 `DataSize`/`DataSizeUtil`、`PhoneUtil`、`IdcardUtil`（校验位 + `province_code()`）、`CreditCodeUtil`（只校验）；
  第四批 `DesensitizedUtil`（要一个脱敏类型枚举，形状先拍）、`CoordinateUtil`、`PageUtil` 的 `Segment`/迭代器面。
- 参照的 `PageUtil.setFirstPageNo(int)` 是**全局静态可变**，本库跟随（`typex_set_first_page_no`），
  代价是"跨用例互盖"——测试里每条用到它的断言都先显式设档再读，这一点在 §3 第 6 条挂两档读数（0 档与 1 档）。

## 2. 公开面（第一批 14 件）

| # | 项 | 参照 |
|---|---|---|
| 23.1 | `pub struct Version`（私有字段 `raw` + 三张段表 `sequence`/`pre`/`build`，段型是包内 `enum Token`，`.mbti` 里只以抽象类型名 `type Token` 出现、不暴露 case） | `cn.hutool.core.lang.Version` 的 `version` + 三个 `List<Object>` |
| 23.2 | `version_of(text) -> Version` | `static Version of(String)` / `new Version(String)` |
| 23.3 | `version_to_string(v) -> String`（**输入原样**，见 §3 第 3 条） | `String toString()` |
| 23.4 | `version_compare(a, b) -> Int`（只钉符号档） | `int compareTo(Version)` |
| 23.5 | `version_equals(a, b) -> Bool` | `boolean equals(Object)`（`hashCode` 同不同只挂旁证） |
| 23.6 | `typex_first_page_no() -> Int` | `static int getFirstPageNo()` |
| 23.7 | `typex_set_first_page_no(Int) -> Unit` | `static void setFirstPageNo(int)`（`setOneAsFirstPageNo()` 即设 1） |
| 23.8 | `page_get_start(page, size) -> Int` | `static int getStart(int, int)` |
| 23.9 | `page_get_end(page, size) -> Int` | `static int getEnd(int, int)` |
| 23.10 | `page_trans_to_start_end(page, size) -> (Int, Int)` | `static int[] transToStartEnd(int, int)` |
| 23.11 | `page_total_page(count, size) -> Int` | `static int totalPage(int, int)` |
| 23.12 | `page_total_page_long(count : Int64, size) -> Int` | `static int totalPage(long, int)` |
| 23.13 | `page_rainbow(current, total) -> Array[Int]` | `static int[] rainbow(int, int)` = `rainbow(cur, total, **10**)`（源码现读；旧写"固定 5"是 PR-A 的错档，见 §5 第 3 行） |
| 23.14 | `page_rainbow_count(current, total, show_count) -> Array[Int]` | `static int[] rainbow(int, int, int)` |

## 3. 判据（每条挂腿读数标签；标签形如 `V<i>.<档>` / `P<i>.<档>` / `G<i>.<档>` / `E<i>`）

1. **段序比较**：数字段按数值（`V1.cmp|+` ⇒ `1.0.10` > `1.0.9`）；段数不等时**长出部分全是数字 0 才算相等**
   （`V2.cmp|0`、`V3.cmp|0`、`V10.cmp|0` 给相等，而 `V18.cmp|+` —— 多出来的那段是空格串不是 0，就不等）；
   非数字段按 **UTF-16 码元字典序且大小写敏感**（`V5.cmp|-` ⇒ `V1.2.3` < `v1.2.3`，`V28.cmp|-` / `V29.cmp|+` 两向都钉，
   `V7.cmp|-` ⇒ `"RELEASE"` < `"snapshot"`）；数字段与字符串段相遇时两侧都转字符串再比（`V22.cmp|+`：`"_"`(0x5f) > `"4"`(0x34)）。
2. **首段无条件解析**（参照 `Version` 构造里第一次 `takeNumber` 不带数字判据）：`v1.2.3` 的首段是 `'v'-'0'=70` 拼出的 **701**（数字段，不是字母段，`V4.cmp|+`），
   `" 1.2"` 的首段是 `-16` 拼出的 **-159**（`V19.cmp|-`）。这条只能从源码读出，靠"字母按字典序"的直觉必然实现反 ⇒ 变异 M8 专打它。
3. **`toString` 不归一**：35 档 `TOSTRING` 读数（30 个进构造的输入 + 5 个只看出口的形状档）与输入逐字相同，含空串（`V11`）、前空格（`V19`）、后空格（`V18`）、尾点（`V20`）、
   双点（`V17`）、`-`/`_` 混分隔（`V21`/`V22`）、`v`/`V` 前缀（`V4`/`V5`）⇒ 本库原样存原样出，**没有任何"规范化版本号"承诺**。
4. **`pre` 空的一侧更大**：`V6.cmp|-`（`1.2.3-SNAPSHOT` < `1.2.3`）与 `V26.cmp|+`（反向那一腿）两向都钉；
   这条与语义版本惯例一致，但**判据来自参照源码 `compareTo` 的前置分支**，不是从惯例推的。
5. **equals 跟 compareTo**：`V*.eq` 与同档 `cmp` 的符号一致（`V2.eq|true` 对 `V2.cmp|0`）；
   参照的 `hashCode` 走原串哈希 ⇒ 29 条 `HASH` 读数里 **27 条 false**（equals 真而哈希不同，含 `V2`/`V10`/`V17` 三档），
6. **`getStart`**：页号低于 `firstPageNo` 就夹到 `firstPageNo`（`P5.start|0`，页号 -1），`size < 1` 一律当 0 而不是夹成 1
   （`P3.start|0`、`P4.start|0`）；0 档八组 `P0..P7`、1 档八组 `P1000..P1007` 两两对读（同输入换档 ⇒ 结果平移一页）；
   `firstPageNo` 为负的档由边腿钉：`E5` = 设 -2 后 `getStart(0,10)` 给 **20**、`E6` = 同档 `getStart(-5,-7)` 给 **0**，本库同值（无断言，有算式对照）。
7. **`getEnd = getStart + size`，不减 1**：`P0.end|10`（参照 javadoc 里那句"页码：0，每页10 =》 9"与实现不符，以实现和腿为准）；
   `size < 1` ⇒ 0（`P3.end|0`）。`transToStartEnd` 同式（`P0.pair|0,10`）。
8. **`totalPage`**：`size == 0` 直接给 0 而不是除零（`P2004.total|0`、`P4004.total|0`）；负 `count` 走 Java 的向零截断，
   于是 `-5 / 10 + 1 = 1`（`P2005.total|1`）；`long` 档 `P3004.total_long|214748365`、`P3005.total_long|429496730`
   （`4294967296 / 10` 已超 `int` 输入域但商仍在 `int` 内，正是这一档决定本库必须收 `Int64`）。
9. **`rainbow` 从不给 `null`**：参照源码是 `new int[length]`，腿 22 条 `RAINBOW`/`RAINBOW3` 读数零 `null` ⇒ PR-A 留的"何时给 null"这一问作废；
   退化档（`total = 0`）给**空数组**（`P3.rainbow|`、`P4.rainbow|`）。
10. **两参档的默认展示数是 10**：`P0.rainbow` 等 11 条读数都是十项；`show_count` 为偶数时 `right++`（左右不对称，
    `P7.rainbow|11..20` 与 `P50004.rainbow3|1,2,3,4` 两档共同钉住），`total < show_count` 时长度取 `total`（`P6.rainbow|1..7`、`P50001`）。
11. **全局档位可读回**：`G0.first|0`、`G1.first|1`。
12. **`toSegment` 不收**（§1）：腿只留事实读数 `P6000`/`P6001`；对象身份（`DefaultSegment@…`）是宿主态，已从注释读数里剥掉。

## 4. 腿

- `TypexLeg.java`：真 `hutool-core-5.8.35.jar` + 本机 JDK 17.0.14，`javac -encoding UTF-8`；
  夹具全部 ASCII 直写，读数用与 `csv`/`ini` 同一套 `esc()` 打成可机械还原的形状；
  输出 `typex_results.tsv`，期望值由 `gen_typex_test.py` 灌进 `typex/typex_test.mbt`（**手打零条**）。
- PageUtil 全局静态两档各跑一遍（0 与 1），两档读数都留在 `typex_results.tsv` 里，测试逐条 `typex_set_first_page_no` 后再断言。
- **落地轮追加 5 对新款夹具（V25..V29，30 行读数）**，来源不是"再想想"，而是首轮变异 M2/M8/M9 **等价（0 红）** 暴露的三条缺口：
  大小写敏感（`.A`/`.a` 两向）、首段无条件解析（`z1.0` vs `999.0`）、`pre` 空档的反向（`1.2.3` vs `1.2.3-SNAPSHOT`）。
  追加后三条变异全部转红（§6）。老 157 条断言**逐字节保留**（脚本核对：HEAD 断言行 157/157 原样在位，新增 15 条）。
- **边腿 `E` 七行**（越界与异常档，只作 §5 证据、不进冻结期望）：`E1` `rainbow(1,-3)` ⇒ `NegativeArraySizeException`、
  `E2` `rainbow(1,10,-4)` ⇒ 同上、`E3` `totalPage(Long.MAX_VALUE,1)` ⇒ `ArithmeticException`（`Math.toIntExact`）、
  `E4` `Version.of(null)` ⇒ `IllegalArgumentException`、`E5`/`E6` 负 `firstPageNo` 两档、`E7` `equals(null)` ⇒ false。

## 5. 与参照的分岔（两侧读数都在）

1. **`null` 输入**：参照 `Version.of(null)` 抛 `IllegalArgumentException`（`E4` 现读类名）；本库参数类型是 `String`，
   该档在类型上就进不来 ⇒ `version_of` 无 raise 面（腿对 30 个输入零 `ERR`）。
2. **`hashCode`**：参照 equals/hashCode 违约（29 条 `HASH` 读数 27 条 false，含 `V2`/`V10`/`V17` 三条 equals 真而哈希不同的档），
   本库不提供 hashCode ⇒ 无对应读数档。
3. **#23.13 展示数错档（PR-A 遗留，已在落地前收口）**：腿的 `pprobe` 原先调的是三参 `rainbow(page, size, 5)`，
   而两参重载实为 `rainbow(cur, total, 10)`（`PageUtil.java` 源码现读）⇒ 那 11 条 `RAINBOW` 期望钉错了档。
   修法已走：腿改调真正的两参档、期望重生成、骨架注释同步（`a067c0c` 记缺陷、`e46f7eb` 收口）。
4. **`compareTo` 返回值**：参照给原始差值（段数差档是 `ts1.size() - ts2.size()`，如 `V21` 那档的 -2；字符串档给码元差，
   如 `V7` 的 `'R'-'s'` = -27），腿的 `CMP` 读数本身就是符号档 ⇒ 本库出口归一成 `-1`/`0`/`1`，**只承诺符号**。
5. **`totalPage(long,int)` 越界**：参照在出口前 `Math.toIntExact`，超 `int` 抛 `ArithmeticException`（`E3`）；
   本库 #23.12 签名无 raise 面 ⇒ 取低 32 位补码读法。**这一条是不对称取舍而不是改进**：参照会报错的档本库静默回绕，
   要靠它做校验的调用方应自己判界。
6. **`rainbow` 长度算出负数**：参照 `new int[负]` 抛 `NegativeArraySizeException`（`E1`/`E2` 两档）；本库给空数组。
7. **整数位宽**：MoonBit `Int` 是 32 位（wasm/js/wasm-gc）而 native 是 64 位（同 `08-num.md` §0.1 那条实测），
   参照的算式全是 Java `int`/`long` ⇒ 本库凡溢出可达处一律 `Int64` 中间量 + 取低 32 位补码读（`wrap32`），
   于是**四档同值且与参照的回绕同值**（例 `V23` 首段参照回绕成 1410065407，本库同值；符号档两形都给 `+`）。
8. **码元 vs 码位**：参照 `charAt`/`substring`/`String.compareTo` 全按 UTF-16 码元，本库解析与比较都先摊成码元（代理对拆开），
   段串再合回合法串。**该档现有夹具全 ASCII，M10 变异 0 红 ⇒ 覆盖面缺口，不假装测过**（要钉死得给腿补含 astral 字符的版本串档）。
9. **全局 `firstPageNo` 跟随参照**（不改成显式参数）：代价是跨用例互盖，测试每条先显式设档（§1 第 4 条已拍）。

## 6. 变异对照（落地轮实测，隔离副本内跑）

工装：`tar` 一份副本到 Temp（不动工作树）；三道守卫都在——开局断基线 **0 红**（459 块）、逐条 `finally` 还原并断字节一致、
收尾复跑仍 0 红且字节一致。新款夹具补进后重跑，读数如下（"红块"按测试块计，满仓 459 块）：

| 变异 | 挂的判据 | 红块 |
|---|---|---|
| M1 `-`/`+` 不再切断主版本段（分隔符只认点号） | §3 第 1 条 | **2** |
| M2 非数字段改大小写不敏感（`| 0x20` 折叠） | §3 第 1 条 | **1** |
| M3 `totalPage` 不向上取整 | §3 第 8 条 | **2** |
| M4 `getEnd` 减 1（改闭区间） | §3 第 7 条 | **2** |
| M5 `firstPageNo` 不参与 `getStart` | §3 第 6 条 | **1** |
| M6 两参 `rainbow` 默认展示数复原成 5 | §3 第 10 条 / §5 第 3 行 | **2** |
| M7 `show_count` 大于总页时不夹取长度 | §3 第 10 条 | **1** |
| M8 主版本首段不再无条件按 `c-'0'` 起算 | §3 第 2 条 | **1** |
| M9 `pre` 空的一侧改判成更小 | §3 第 4 条 | **1** |
| M10 摊码元改成按码位（代理对不拆） | §5 第 8 行 | **0 ⇒ 等价，夹具缺口**（全 ASCII，改不动任何读数；已如实挂账而不是当"已覆盖"） |

**未挂载一条**：PR-A 计划里的"`rainbow` 的 `null` 档改成空数组"——落地后确认参照从不返回 `null`（§3 第 9 条：源码 + 22 条读数零 null），
本库根本没有 `null` 分支可改，这条变异是永假分支，不是漏做。

首轮（补夹具之前）M2/M8/M9 曾是 **0 红**，且 M2 那一版因把折叠写成 `.map(u => …)` 而编译失败被判过一次"未挂载"；
两者都是**夹具问题而不是结论**（与 `ini` 轮 M1 同一条教训），故本轮的做法是先补腿读数、再重挂、再取数。

## 7. 状态

**第一批那一格已收口**：14 件公开面全部落地（体里零 `abort`，G12 骨架豁免随落地笔整行删除），
6 块 **172 条**冻结期望在 **wasm / js / wasm-gc 三档同一读数**（落地当场：Total tests 459，passed 459，failed 0），
`moon check` 三档零警告，`.mbti` 只多出内部段型的类型名 `type Token`（抽象呈现、不暴露 case），公开 14 件签名一字未动。
参照源码三件（`PageUtil.java` 274 行、`Version.java` 281 行、`CompareUtil.compare` + `CharUtil.isNumber` 两条委托）逐档对照后移植，
其中"首段无条件 `takeNumber`"、"`pre` 空的一侧更大"、"`getEnd` 不减 1"、"码元序且大小写敏感"四条是靠读数与源码双证钉住的，不按语义直觉实现。
native 档本机无 C 编译器（`moon test --target native` 报 `no system C compiler found`），由 CI 覆盖；
`wrap32` 那条位宽处置（§5 第 7 行）正是为 native 与 wasm 同值而设。

## 10. 第二批 `Ipv4Util`（#23.15–#23.32）

对位 `cn.hutool.core.net.Ipv4Util`（件在 **`core/net`**，不在 `core/util`；`unzip -l hutool-core.jar | grep -i ipv4` 现读
`cn/hutool/core/net/Ipv4Util.class` 10,123 字节，源码 439 行 + 依赖的 `MaskBit.java` 76 行）。
`javap` 现读公开面 4 常量 + 20 静态件，本批改**收 17 件纯算式**。

### 10.1 边界（不收的与为什么）

- `list(...)` 三件：把 IP 段展开成 `List<String>`（`maskBit == 32` 才短路，其余按段生成，规模可到 2^31，是分配型 API）。
- `NetUtil` 全系与 `LOCAL_IP` 之外的主机探测：网卡/本机地址是宿主态。
- 参照的四枚常量不进公开面：`LOCAL_IP`（`"127.0.0.1"`，只服务 `isInnerIP`）、`IP_SPLIT_MARK`(`-`)、
  `IP_MASK_SPLIT_MARK`(`/`) 是纯拼串细节；`IP_MASK_MAX`(`32`) 的定义域由 `mask_bit_is_valid(32)`=真 与
  `(33)`=假 两条读数钉住，不再复制一个数（四枚常量的腿读数都留在 §10.4 里当证据，不产断言）。

### 10.2 公开面（第二批 18 件 = 1 错误面 + 17 函数）

| # | 项 | 参照 | raise |
|---|---|---|---|
| 23.15 | `pub suberror Ipv4Error { BadIp BadMask BadMaskBit BadRange }`（四变体都不带载荷） | 见 §10.5 映射表 | — |
| 23.16 | `long_to_ipv4(v : Int64) -> String` | `static String longToIpv4(long)` | 无 |
| 23.17 | `ipv4_to_long(text : String) -> Int64` | `static long ipv4ToLong(String)` | `BadIp` |
| 23.18 | `ipv4_to_long_or(text : String, default : Int64) -> Int64` | `static long ipv4ToLong(String, long)` | 无 |
| 23.19 | `ipv4_begin_ip_str(ip, mask_bit) -> String` | `static String getBeginIpStr(String, int)` | `BadIp`/`BadMaskBit` |
| 23.20 | `ipv4_begin_ip_long(ip, mask_bit) -> Int64` | `static Long getBeginIpLong(String, int)` | 同上 |
| 23.21 | `ipv4_end_ip_str(ip, mask_bit) -> String` | `static String getEndIpStr(String, int)` | 同上 |
| 23.22 | `ipv4_end_ip_long(ip, mask_bit) -> Int64` | `static Long getEndIpLong(String, int)` | 同上 |
| 23.23 | `mask_bit_by_mask(mask : String) -> Int` | `static int getMaskBitByMask(String)` | `BadMask` |
| 23.24 | `mask_by_mask_bit(mask_bit : Int) -> String?` | `static String getMaskByMaskBit(int)`（`null`→`None`） | 无 |
| 23.25 | `count_by_mask_bit(mask_bit : Int, all : Bool) -> Int` | `static int countByMaskBit(int, boolean)` | 无 |
| 23.26 | `mask_by_ip_range(from_ip, to_ip) -> String` | `static String getMaskByIpRange(String, String)` | `BadIp`/`BadRange` |
| 23.27 | `count_by_ip_range(from_ip, to_ip) -> Int` | `static int countByIpRange(String, String)` | `BadIp`/`BadRange` |
| 23.28 | `mask_is_valid(mask : String) -> Bool` | `static boolean isMaskValid(String)` | 无 |
| 23.29 | `mask_bit_is_valid(mask_bit : Int) -> Bool` | `static boolean isMaskBitValid(int)` | 无 |
| 23.30 | `ipv4_is_inner(ip : String) -> Bool` | `static boolean isInnerIP(String)` | `BadIp` |
| 23.31 | `ipv4_matches(wildcard, ip) -> Bool` | `static boolean matches(String, String)` | 无 |
| 23.32 | `ipv4_format_block(ip, mask) -> String` | `static String formatIpBlock(String, String)` | `BadMask` |

**`Int64` 不是可选的**：`ipv4_to_long` 的值域到 `2^32-1`，而 wasm/js/wasm-gc 的 `Int` 是 32 位有符号（装不下
`4294967295`，`TOL|255.255.255.255` 那条读数就地否决了 `Int` 出口）。

### 10.3 判据（每条挂腿读数标签，标签形如 `<字段>|<参数>`）

1. **`long_to_ipv4` 只取低 32 位、按四段拆**：`4294967296`→`0.0.0.0`、`-1`→`255.255.255.255`、
   `-2`→`255.255.255.254`、`Long.MIN_VALUE`→`0.0.0.0`、`Long.MAX_VALUE`→`255.255.255.255`（`L2I|*` 13 条）。
2. **合法性判据 = `@valid.is_ipv4`**（三方命中集同喂 33 个样本零分歧：参照 `Validator.isIpv4`、`PatternPool.IPV4`、
   本库 `is_ipv4`；阳性对照挂过——把 `256.1.1.1` 的期望翻一条就立即报红）：前导零照收且同值
   （`TOL|01.2.3.4`、`TOL|001.002.003.004`、`TOL|1.2.3.04` 都给 `16909060`），但每段最多 3 位
   （`TOL|1.2.3.0000004` 非法），段数、空格、越界、非 ASCII 数字、BOM、尾随换行全非法（`TOL|*` 14 条 ERR）。
   `ipv4_to_long_or` 同判据但**永不抛**，非法给默认值（`TOLD|*` 28 条两两对读）。
3. **网段起止**：`ip & mask` 与 `begin + ~mask` 的经典算式（`BSTR|218.240.38.69|24`→`218.240.38.0`、
   `ESTR|218.240.38.69|8`→`218.255.255.255`）；掩码位定义域**只有 1..32**，`0`/负数/`33`/`64` 五档 × 三个 IP × 四个件
   = 60 条 `BadMaskBit` 读数（`BSTR|0.0.0.0|0` 等）；`1` 档的 `ELNG` 给 `4294967295`（参照那句"此接口返回负数"
   在实测档不成立，以读数为准）。
4. **错误优先序**：IP 与掩码位同时非法时先报 `BadIp`——参照算式 `ipv4ToLong(ip) & ipv4ToLong(getMaskByMaskBit(b))`
   左操作数先算，`BSTR|256.1.1.1|0` 这条读数就是专门钉它的（若是反过来的实现会报 `BadMaskBit`）。
5. **掩码表只 1..32，且掩码必须连续**：`MBMB|0`→`None`、`MBMB|33`→`None`；`IMV|255.0.255.0`→假、
   `IMV|0.0.0.0`→假（0.0.0.0 不在表内）、`IMV|255.255.255.255.0`→假；`MBM|<32 条>` 全部命中且与 `MBMB` 双向互逆
   （32 档全表，正反各一遍）。
6. **`count_by_mask_bit` 跟随参照的 double→int 饱和窄化**：`CBMB|0|true`、`CBMB|-1|true`、`CBMB|-2|true`、
   `CBMB|1|true` 都给 `2147483647`（`(int) 2^32` 与 `2^31` 越界饱和，**不是回绕**），
   `CBMB|33|true`、`CBMB|64|true` 给 `0`（`2^-1`、`2^-32` 截断为 0）；
   `all=false` 时参照先短路 `maskBit<=0 || maskBit>=32` ⇒ `CBMB|0|false` 与 `CBMB|32|false` 都给 `0`，
   而 `CBMB|31|false` 的 `0` 走的是另一条路（不短路，`2 - 2`）——两条形同实不同，都钉住；
   `CBMB|1|false` = `2147483647 - 2 = 2147483645` ⇒ **饱和发生在减 2 之前**。
7. **`mask_by_ip_range` 不是真 CIDR**：逐段 `255 - to + from` 拼串，读数里有 `MBIR|1.2.3.4|1.2.3.10`→`255.255.255.249`
   与 `MBIR|0.0.0.0|255.255.255.255`→`0.0.0.0`；且 `Assert.isTrue(from < to)` ⇒ **相等也非法**
   （`MBIR|1.2.3.4|1.2.3.4`→`BadRange`）。
8. **`count_by_ip_range` 的相等边界与上一条相反**：`CBIR|1.2.3.4|1.2.3.4`→`1`（只有 `from > to` 才 `BadRange`）；
   出口 `int` 走复合赋值窄化 ⇒ `CBIR|0.0.0.0|255.255.255.255`→`2147483647`（真值 `2^32`，饱和而不是回绕）、
   `CBIR|1.2.3.4|1.2.4.4`→`257`、`CBIR|1.2.3.4|1.2.3.10`→`7`。
9. **内网判定认字面 `127.0.0.1`**：`IIIP|127.0.0.1`→真 而 `IIIP|127.0.0.2`、`IIIP|127.255.255.255`→假
   （环回那一档是 `LOCAL_IP.equals(ipAddress)` 串比较）；A/B/C 三类各钉内外两侧
   （`10.0.0.0`真 / `9.255.255.255`假 / `172.16.0.0`真 / `172.15.255.255`假 / `172.32.0.0`假 /
   `192.168.255.255`真 / `192.169.0.0`假）；非法 IP 在这里**抛** `BadIp`。
10. **`matches` 三件事**：非法 IP **不抛给假**（`MAT|192.168.*.1|bad`→假，与第 9 条同包两副面孔）；
    `*` 必须占满整段（`MAT|*1.2.3.4|1.2.3.4`→假、`MAT|**.*.*.*|1.2.3.4`→假、`MAT|1.2.3.*|1.2.3.4`→真）；
    段内是**字符串相等**（`MAT|1.2.3.4|01.2.3.4`→假、`MAT|192.168.3.1|192.168.03.1`→假，
    而 `MAT|192.168.*.1|192.168.03.1`→真——星号那段根本不比）。
11. **`format_ip_block` 不校验 IP 只校验掩码**：`FIB|bad ip|255.255.255.0`→`"bad ip/24"`、
    `FIB|256.1.1.1|255.255.255.0`→`"256.1.1.1/24"`（参照是 `ip + "/" + getMaskBitByMask(mask)`，串都不看内容）；
    掩码非连续或为 `0.0.0.0` ⇒ `BadMask`。

### 10.4 腿

- `Ipv4ContractLeg.java`：真 `hutool-core-5.8.35.jar` + JDK 17.0.14，`javac -encoding UTF-8`；
  形状 `I <字段> <参数(多参用 | 连)> <VAL|ERR> <值>`，非 ASCII 一律 `\uXXXX`；**415 行读数**，其中
  四枚常量 4 行只作 §10.1 的证据、不进断言 ⇒ 生成 **7 块 411 条**冻结期望（`typex/ipv4_test.mbt`，手打零条）。
- ERR 行读的是 `异常类简名 + ":" + message`（不是期望串）：同一个 `IllegalArgumentException` 在参照里背着三种语义，
  只能靠 message 分流，映射见 §10.5。
- 生成器 `gen_ipv4_test.py` 带三条自证：唯一键（同字段同参数重复即报错）、未登记字段报错、
  **不抛错的件却读到 ERR 就报错**；收尾断言每块断言数 > 0（零断言块静默计绿的教训）。
- 非法 IP 与非法掩码位同时在场的档（§10.3 第 4 条）是**专为优先序补的夹具**，不是顺手多跑的。

### 10.5 与参照的分岔（含异常映射表）

| 参照（类 + message，腿现读） | 本库 | 说明 |
|---|---|---|
| `IllegalArgumentException: Invalid IPv4 address!` | `raise BadIp` | 出口 23.17/23.19–23.22/23.26–23.27/23.30 |
| `IllegalArgumentException: Invalid netmask <输入>` | `raise BadMask` | 参照 message 带输入，本库变体**不带载荷**（输入调用方自己有） |
| `IllegalArgumentException: to IP must be greater than from IP!` | `raise BadRange` | 23.26 与 23.27 的可达条件不同（§10.3 第 7/8 条） |
| `NullPointerException: Cannot invoke "java.lang.CharSequence.length()" because "this.text" is null` | `raise BadMaskBit` | 参照把 `null` 喂进正则的崩溃形状，**不复制崩溃**，改显式变体 |
| `getMaskByMaskBit` 给 `null` | `mask_by_mask_bit` 给 `None` | 唯一一处 `null`→`Option` |
| `countByMaskBit`/`countByIpRange` 的 `int` 饱和 | 同值跟随（显式饱和） | 本库若给 `Int64` 真值就是分岔，这里选**跟随**；与 §5 第 7 行的 `wrap32` 处置并列：那一条管回绕域，这一条管窄化域 |
| `getEndIpLong` 注释"此接口返回负数" | 跟随算式不跟随注释 | `ELNG|218.240.38.69|1` 实测 `4294967295` 为正 |
| 四枚 `public static final` 常量 | 不进公开面 | §10.1 |

### 10.6 变异对照（第二批落地轮实测）

工装同第一批：`tar` 一份副本到 Temp（不动工作树），三道守卫齐全——开局断基线 **0 红**（466 块）、逐条 `finally` 还原并断字节一致、
收尾复跑仍 0 红且字节一致。锚点一律按 **`moon fmt` 之后的真实文本**写，且打完变异断言"文件确实变了"
（`num`/`path` 两轮都有过锚点被 fmt 重排而静默失效的前科）。

| 变异 | 挂的判据 | 红块 |
|---|---|---|
| M1 `long_to_ipv4` 首段不掩码（取满 32 位） | §10.3 第 1 条 | **1** |
| M2 `ipv4_to_long` 段序反接（首段当末段） | §10.3 第 2 条 | **4** |
| M3 合法性判据额外收紧成"禁前导零" | §10.3 第 2 条（复用 `valid` 那张嘴、不加严） | **1** |
| M4 先算掩码位再算 IP（错误优先序反过来） | §10.3 第 4 条 | **1** |
| M5 掩码表补上 0 这一档 | §10.3 第 3/5 条 | **2** |
| M6 `count_by_mask_bit` 不走饱和窄化（越界交给 `Int` 回绕） | §10.3 第 6 条 / §10.5 末两行 | **1** |
| M7 `count_by_mask_bit` 的 `all=false` 短路下界挪一格 | §10.3 第 6 条 | **1** |
| M8 `mask_by_ip_range` 相等边界放宽到与 count 那侧一致 | §10.3 第 7 条 | **1** |
| M9 `count_by_ip_range` 改成相等也抛（与 mask 那侧对齐） | §10.3 第 8 条 | **1** |
| M10 `matches` 段内比较改数值比较（前导零变得无关） | §10.3 第 10 条 | **1** |
| M11 环回档从字面串比较改成整个 127/8 区间 | §10.3 第 9 条 | **1** |

**十一条全部有红，本轮没有等价变异**——这是第一批那三条教训（等价＝夹具缺口）反过来用了一次：
写夹具矩阵时就把"这条判据的两种实现会不会给同一个读数"当准入条件（`M4` 的专用夹具、`M8`/`M9` 的成对相反边界、
`M10`/`M3` 的前导零两侧），所以落地轮不必再补腿。

**未挂载一条**：拆分串时的"码元 vs 码位"变异。IPv4 串里数字与点号全在 ASCII，非 ASCII 输入在合法性那一步
（`@valid.is_ipv4`）就已经出局，走不到拆分——这条判据在本包**不可达**，不是漏做（与第一批 §5 第 8 行那条
"码元口径无夹具可钉"是同一族，但那里是覆盖面缺口、这里是判据不可达）。

### 10.7 状态

第二批（`Ipv4Util`）**已落地收口**：18 件公开面体里零 `abort`（G12 骨架豁免整行删除），
7 块 **411 条**冻结期望在 **wasm / js / wasm-gc 三档同一读数**（当场：`Total tests: 466, passed: 466, failed: 0`），
`moon check` 三档零警告，`.mbti` 与 PR-A 那一笔逐字节相同（实现没有改动任何签名）。
期望值一条未动、一条未加（G5 走授权通道只因 spec 与 `moon.pkg` 同笔换代，`*_test.mbt` 逐字节未变）。

## 11. 第三批 A `PhoneUtil`（#23.33–#23.47）

对位 `cn.hutool.core.util.PhoneUtil`，`javap` 现读 **15 件公开静态**（7 判定 + 3 掩码 + 3 取串 + 2 固话取组）。
本批全收（无 IO、无时钟、无码表外依赖）。

### 11.1 边界

- 判定档一律 `String -> Bool`、**不 raise**（码表是包内常量，与 `valid` 包同口径）。
- 掩码/取串**不校验号型**（参照就是定长下标切串，`"12345"` 也照样掩），所以这两族也不 raise；
  参照的负下标档（`sub(-4,-1)` 从尾部数、`hide(-4,-1)` 原样返回）**本批不覆盖**——六件用的都是固定非负下标，
  写清楚而不假装是全量移植 `StrUtil.sub`。
- `sub_tel_*` 无匹配时参照给 `null` ⇒ 本库出口 `String?`。

### 11.2 公开面（15 件）

| # | 项 | 参照 | 码表来源 |
|---|---|---|---|
| 23.33 | `phone_is_mobile` | `isMobile` | **委托 `@valid.is_mobile`**（同码表，见 §11.4） |
| 23.34 | `phone_is_mobile_hk` | `isMobileHk` | `PatternPool.MOBILE_HK` |
| 23.35 | `phone_is_mobile_tw` | `isMobileTw` | `PatternPool.MOBILE_TW` |
| 23.36 | `phone_is_mobile_mo` | `isMobileMo` | `PatternPool.MOBILE_MO` |
| 23.37 | `phone_is_tel` | `isTel` | `PatternPool.TEL` |
| 23.38 | `phone_is_tel400800` | `isTel400800` | `PatternPool.TEL_400_800` |
| 23.39 | `phone_is_phone` | `isPhone` | 五路之或 |
| 23.40–23.42 | `phone_hide_before` / `_between` / `_after` | `hideBefore/hideBetween/hideAfter` | `StrUtil.hide(·,0,7 / 3,7 / 7,11)`，**码位** |
| 23.43–23.45 | `phone_sub_before` / `_between` / `_after` | `subBefore/subBetween/subAfter` | `StrUtil.sub(·,0,3 / 3,7 / 7,11)`，**码元** |
| 23.46–23.47 | `phone_sub_tel_before` / `_after` | `subTelBefore/subTelAfter` | `ReUtil.getGroup1(TEL,·)` / `get(TEL,·,2)` |

### 11.3 判据（标签形如 `<字段>|<样本>`，字段名用腿里的 `IS_*` / `HIDE_*` / `SUB_*`）

1. **两族索引域不同，且同一条样本同时能看出两侧**：`"1380013🍎8000"`（13 码元 / 12 码位）——
   `SUB_AFTER` 给 `🍎80`（码元 7..11 = 高代理、低代理、`8`、`0`），而 `HIDE_AFTER` 给 `1380013****0`
   （码位 7..11 = 🍎 + 三个 `8` 被掩，尾码位 `0` 留下，**输出比输入少一个码元**）。
   `HIDE_BEFORE`/`HIDE_BETWEEN` 两条也对得上码位模型（`*******🍎8000`、`138****🍎8000`）
   ⇒ 落地时 `hide` 三件复用 `@text.hide`（它就是码位、就地替换、越界夹紧），`sub` 三件自带码元切片。
2. **区号白名单式**：`TEL` 是 `(010|02\d|0[3-9]\d{2})-?(\d{6,8})`——`02x` 只允许两位、`0[3-9]` 必须三位，
   `IS_TEL|0755-1234567` 真而 `IS_TEL|01012345678`（区号后无分隔也吃，但整串要占满）另有 `IS_TEL_400_800` 真。
3. **`is_phone` 五路或不含固话**：`IS_PHONE|010-12345678` = `false` 而 `IS_TEL|010-12345678` = `true`
   （成对夹具；把固话"顺手补进"is_phone 是本包最容易的自我发明，变异要专门打它）。
4. **`TEL_400_800` 的分隔符是可选的**：`IS_TEL_400_800|01012345678` = `true`。
   这条正是**方言对撞抓出来的**：把 `[\- ]?` 写成 `(-| )` 时丢了 `?`，本库给 `false` ⇒ 契约里既留 Java 读数也留改写规则。
5. **台湾/澳门的号段前缀是硬要求**：`IS_MOBILE_TW` 要 `09` 开头、`IS_MOBILE_MO` 要 `6` 开头，
   前缀 `0`/`886`/`+886` 与 `0`/`853`/`+853` 都可选，中间可有一个 `-`（`(-|)?`）。
6. **`sub_tel_*` 是查找式**：`SUB_TEL_BEFORE|13800138000` 给 `null`（手机号里没有区号段），
   `SUB_TEL_BEFORE|010-12345678` 给 `010`、`SUB_TEL_AFTER|…` 给 `12345678`；`400-123-4567` 也给 `null`
   （`TEL` 的第一段不接受 `400`）。
7. **越界一律夹紧不报错**：`HIDE_AFTER|1380013800`（10 位）给 `1380013***`、`SUB_AFTER|1380013800` 给 `800`。

### 11.4 腿与对撞

- 腿 `PhoneLeg.java`（真 hutool-core-5.8.35 + JDK 17.0.14，`javac -encoding UTF-8`）：**六枚码表的源文与 flags
  由反射读 `PatternPool`**（`flags` 全是 0，故本库不做大小写不敏感档），33 个样本 × 7 判定 + 9 个样本 × 8 取串 =
  **303 行读数、0 ERR**，生成 **4 块 296 条**冻结期望（`typex/phone_test.mbt`，手打零条）。
- **先对撞再冻结**（`re`/`valid` 轮的规矩）：core 侧方言改写先在同一份样本上跑探针（隔离副本，不进仓），
  探针差异用 `assert_eq` 出口（本工具链的 wasm 驱动不打印 `abort` 载荷）。第 4 条那条丢 `?` 就是这么抓到的；
  `MOBILE` 改写结果与 `valid` 包已冻结的 `is_mobile` 模式**逐字符相同** ⇒ 直接委托，不留第二张表。
- 生成器自证四条：唯一键、未登记字段报错、判定档读到非布尔就报错、每块断言数 > 0。

### 11.5 与参照的分岔

| 参照 | 本库 | 依据 |
|---|---|---|
| 入参 `CharSequence`、出口 `CharSequence` | `String` → `String` | 全仓一致（`.mbti` 里不许出现 `CharSequence`） |
| `hideBefore` 等出口 `CharSequence`（实测都是 `String`） | `String` | 腿读数值即 `String` |
| `StrUtil.sub` 支持负下标（`sub(-4,-1)` 从尾部数） | 本批六件不涉及负下标，**该档不进契约** | 腿有 `A_SUB_NEG` 读数，写"未覆盖"而不是"已跟随" |
| `Validator.isMatchRegex` = 整串匹配 | `^(?:P)$` 包裹（同 `valid` 包 §0.3 的底座） | `re` 轮实测：`execute` 判"占满"不等价于整串匹配 |
| 6 枚模式带 `[\- ]` 字符类 | core 方言写 `(-| )`（类内并列 `-` 在本版非法） | `re`/`valid` 轮同一条改写规则 |

### 11.6 变异对照（PR-B 填读数）

八条，每条要么报红要么如实记等价/未挂载：`hide` 三件改成码元切片（测两族索引域不串）、`sub` 三件改成码位、
`is_phone` 补进 `is_tel`（测五路或）、`TEL_400_800` 的分隔符 `?` 去掉（回归第 4 条判据）、
`MOBILE_TW` 去掉 `09` 硬前缀、`hide` 的越界改成截断而非夹紧、`sub_tel_*` 改成锚定整串匹配、
`phone_is_mobile` 不走委托而自带第二张表（测同源）。

### 11.7 状态

`契约已冻结`（第三批 A PR-A：15 件签名骨架 + 4 块 296 条冻结期望就位，腿 303 行读数 0 ERR，
core 侧对撞先跑过并抓到一条改写错档；包内当场读数 `Total tests: 470, passed: 466, failed: 4` —— 4 红是本批设计态）。
