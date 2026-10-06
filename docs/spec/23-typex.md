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
  第四批 `DesensitizedUtil`（脱敏类型枚举的形状照 §15.1 那条先例办——公开面收档位串，不新开 `pub enum`）、`CoordinateUtil`。
  `PageUtil` 的 `Segment` 面已判**不收**（10-06 现读源码：`toSegment(pageNo, pageSize)` 就是
  `new DefaultSegment<>(transToStartEnd(...)[0], transToStartEnd(...)[1])`，`Segment<T>` 只有
  `getStartIndex()` / `getEndIndex()` 与一个默认 `getRange()`——两个数本库已由 #23.10 `page_trans_to_start_end`
  以 `(Int, Int)` 交出，再立一件等于给同一个数对套壳；`setOneAsFirstPageNo()` 同理是
  `typex_set_first_page_no(1)` 的别名，照 §13.2 的"同一条实现只留一件"先例不收）。
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
3. **`is_phone` 五路或不含固话**：五路是 手机 / 400·800 / 港 / 台 / 澳，**不含 #23.37 的固话**。
   钉住它的成对读数（腿）：`IS_TEL|010-02345678` = `true` 而 `IS_PHONE|010-02345678` = `false`
   ——号码段以 `0` 开头时 `TEL` 吃、`TEL_400_800` 两支都不吃（`0\d{2,3}(-| )?[1-9]…` 要求分隔后首位 `1-9`）。
   ⚠ **这一条在 PR-A 那一版写错了样本**：旧文写的是 `"010-12345678"` 给 `is_phone=false`，
   而腿对该样本给 `IS_TEL=true` **且** `IS_PHONE=true`（它同被 `TEL_400_800` 那支吃掉）⇒ 旧那对读数
   **证明不了"不含固话"**。错处是变异 M3b 报回来的（把固话补成第六路，旧夹具 0 红），
   补两条 `0` 开头号码段样本后 M3b 才转红。教训：判据行的"成对读数"必须从腿表 `awk` 出来贴，不能凭形状推。
4. **`TEL_400_800` 的分隔符是可选的**：`IS_TEL_400_800|01012345678` = `true`。
   这条正是**方言对撞抓出来的**：把 `[\- ]?` 写成 `(-| )` 时丢了 `?`，本库给 `false` ⇒ 契约里既留 Java 读数也留改写规则。
5. **台湾/澳门的号段前缀是硬要求**：`IS_MOBILE_TW` 要 `09` 开头、`IS_MOBILE_MO` 要 `6` 开头，
   前缀 `0`/`886`/`+886` 与 `0`/`853`/`+853` 都可选，中间可有一个 `-`（`(-|)?`）——**连字符只在号段之前可选**：
   `IS_MOBILE_TW|09-12345678` = `false`（腿），而 `IS_MOBILE_TW|+886-0912345678` = `true`。
   ⚠ 台湾那一支在 PR-A 的 32 个样本里**零条 `true`**（正样侧完全没读）：模式若把正样全拒也照样一条不红。
   补 `0912345678` / `8860912345678` / `+886-0912345678` 三条正样后，M9（`09` 改 `08`）才报得出红。
6. **`sub_tel_*` 是查找式**：`SUB_TEL_BEFORE|13800138000` 给 `null`（手机号里没有区号段），
   `SUB_TEL_BEFORE|010-12345678` 给 `010`、`SUB_TEL_AFTER|…` 给 `12345678`；`400-123-4567` 也给 `null`
   （`TEL` 的第一段不接受 `400`）。
   ⚠ "查找式"与"锚定整串"在 PR-A 的 9 个取串样本上**不可分辨**（每条样本要么整串占满要么完全不命中），
   故补两条"串内命中但整串不占满"的夹具：`SUB_TEL_BEFORE|拨010-12345678转801` = `010`、
   `SUB_TEL_BEFORE|010-123456789012` = `010`（腿；锚定档这两条都给 `null`）⇒ M7 由等价转红。
7. **越界一律夹紧不报错**：`HIDE_AFTER|1380013800`（10 位）给 `1380013***`、`SUB_AFTER|1380013800` 给 `800`。

### 11.4 腿与对撞

- 腿 `PhoneLeg.java`（真 hutool-core-5.8.35 + JDK 17.0.14，`javac -encoding UTF-8`）：**六枚码表的源文与 flags
  由反射读 `PatternPool`**（`flags` 全是 0，故本库不做大小写不敏感档），**38 个样本 × 7 判定 + 11 个样本 × 8 取串
  = 361 行读数、0 ERR**，生成 **4 块 354 条**冻结期望（`typex/phone_test.mbt`，手打零条）。
  样本数与期望数都是**落地轮补档后的现读**（PR-A 那版是 32 × 7 + 9 × 8 = 303 行 / 296 条）：
  补的 6 条各钉一处变异测不到的形状，见 §11.3 第 3/5/6 条与 §11.6。
  补档换代自证：旧 296 条断言在新文件里**逐字节保留且顺序不变**（差分 `改=0 删=0 增=58`，旧串是新串的子序列）。
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
| `StrUtil.sub` 把代理对**从中间切开**时给的是半个代理对（Java 的 `String` 装得下孤立代理项） | 本库出口必须是合法 `String` ⇒ `phone_from_units` 把落在切片端点的**落单代理丢弃**（`typex/phone.mbt` 里两处分支） | **未覆盖档**：现有 11 条取串样本里没有一条的下标正好切进代理对（`1380013🍎8000` 的 `7..11` 把整对包在内部），所以这两处分支**没有夹具证明**，只在源码与这里写清楚；参照侧造不出可比的期望串（腿的 `esc` 会把孤立代理项写成半个 `\ud83c`），故也不进契约 |

### 11.6 变异对照（落地轮实测，隔离副本 `tar` 出来的工程，基线 0 红守卫 + `finally` 还原 + 收尾字节比对）

十一条，**十条报红、一条按构造等价**。红块数指 `moon test --target wasm` 里失败的 `test` 块数（本批 4 块）；
"见证夹具"是**从失败输出里读出来的**（失败行号映射回 `phone_test.mbt` 的 `// 字段|样本` 标签），不是人推的：

| # | 变异 | 红块 | 见证夹具（失败输出映射） |
|---|---|---|---|
| M1 | 掩码族三件改成码元切片 | 1 | `HIDE_AFTER|1380013🍎8000`（§11.3 第 1 条） |
| M2 | 取串族三件改成码位切片 | 1 | `SUB_AFTER|1380013🍎8000`（同一条的反向） |
| M3 | `is_phone` 的第五路从 `tel400800` 换成 `is_tel` | 1 | `IS_PHONE|400-123-4567`（另三条 400/800 同形） |
| M3b | `is_phone` 把固话**补成**第六路 | 1（**补档后才报红**，旧夹具 0 红） | `IS_PHONE|010-02345678`：`None/true != false`——腿对该条给 `IS_TEL=true` 且 `IS_PHONE=false` |
| M4 | `TEL_400_800` 分隔符的 `?` 去掉 | 1 | `IS_TEL_400_800|01012345678`（§11.3 第 4 条，方言对撞抓到的那处改写错） |
| M5 | `MOBILE_TW` 去掉 `09` 硬前缀（改纯 10 位） | 2 | `IS_MOBILE_TW|1380013800` 与被它带倒的 `IS_PHONE|1380013800` |
| M6 | 掩码越界改成不夹紧（越界原样返回） | 1 | `HIDE_BEFORE|12345`（`*****` vs 原样） |
| M7 | `sub_tel_*` 改成锚定整串匹配 | 1（**补档后才报红**，旧夹具 0 红） | `phone_test.mbt:389-392` = `SUB_TEL_BEFORE|拨010-12345678转801` 给 `None != Some("010")` |
| M8 | `phone_is_mobile` 不走委托、自带第二张表 | **0（等价）** | 见下方"按构造等价" |
| M9 | `MOBILE_TW` 的 `09` 前缀改成 `08`（正样全拒档） | 2 | `IS_MOBILE_TW|0912345678` / `IS_PHONE|8860912345678`（**补档前测不出**） |
| M10 | 掩码字符 `'*'` 改成 `'#'` | 1 | `HIDE_BEFORE|13800138000` |

**本轮新记的一条工装纪律**（差点把等价记错）：变异写盘必须 `flush + os.fsync + 写后回读断言`。
第一次跑时有一条变异（TW 的 `09` 改纯 10 位）在 `io.open(...).write()` 未显式 close 的写法下**没落到磁盘**，
`moon test` 于是报 0 红——那会被误记成"又一个夹具缺口"。加固后的工装对每条变异都断言"盘上内容确实变了"，
上表的十条红与 M8 的一条等价都出自这次运行（`AFTER-RESTORE … byte-identical=True`）。
**判"等价"之前必须先证"变异真进了编译"**，0 红本身不是证据。

两条"补档前 0 红"就是本批的**夹具缺口**，处置与第二批不同：不是加变异而是**加腿样本再重挂**——
M3b/M9 暴露的是"判据行凭形状推、没从腿表取"（§11.3 第 3 条那条成对读数因此写错过一次，就地更正），
M7 暴露的是"查找式与锚定在旧样本上不可分辨"。补的 6 条样本进腿表重跑（0 ERR）后三条全部转红，
而旧 296 条期望逐字节未动（`改=0 删=0`）。

**M8 是按构造等价，不是夹具缺口**：`valid.is_mobile` 与本库自带的 `whole(…)` 两侧**码表逐字符相同**
（腿 `SRC_MOBILE` = `(?:0|86|\+86)?1[3-9]\d{9}`，`valid/valid.mbt:71` 的字面串去掉 `\d`→`[[:digit:]]` 即同串），
且两个 `whole` 函数体逐行同形（`^(?:P)$` 包裹 + `execute` 判 Some/None）⇒ 不存在能分辨二者的输入。
委托的价值在**维护面**（全仓只有一张手机号表）而不在行为面，这条留在这里是为了下次有人误以为"委托档没测到"。

### 11.7 状态

第三批 A（`PhoneUtil`）**已落地收口**：15 件全部填体，包内当场读数 `Total tests: 470, passed: 470, failed: 0`，
三档 wasm / js / wasm-gc 一致；4 块 354 条冻结期望全部通过，无一条被改动来迁就实现。

## 12. 第三批 B `CreditCodeUtil`（#23.48–#23.49）

对位 `cn.hutool.core.util.CreditCodeUtil`（GB32100-2015 统一社会信用代码），`javap` 现读公开面 =
1 常量 + 3 静态方法。本批收 **2 件**，其余挂账见 §12.1。

### 12.1 边界

- 收：`isCreditCodeSimple`、`isCreditCode`（两件都是纯算式，无 IO、无时钟、无随机）。
- **不收 `randomCreditCode()`**：它走裸 `RandomUtil.randomInt` ⇒ 每次读数不同。
  `rand` 轮定的口径是"随机一律显式注入 `@random.Rand`"，而 hutool 这件没有可注入的种子入口，
  移植它等于自创形状。腿只读它的**形状**（`len=18 valid=true inAlphabet=true`）当旁证：
  参照的生成器与校验器自洽 ⇒ 校验位函数在前 17 位合法时**永远算得出**（不存在 -1）。
- 常量 `CREDIT_CODE_PATTERN` 不作为项暴露（它就是 §12.2 那张码表，暴露一个 `Pattern` 型在本库没有对应物）。
- 参照入/出口是 `CharSequence` ⇒ 本库一律 `String`（全仓一致，`.mbti` 里不许出现 `CharSequence`）。

### 12.2 三张表（一律反射读，不手抄）

| 表 | 腿读数 |
|---|---|
| `PatternPool.CREDIT_CODE` | `^[0-9A-HJ-NPQRTUWXY]{2}\d{6}[0-9A-HJ-NPQRTUWXY]{10}$ ## 0`（flags 全 0） |
| `CreditCodeUtil.WEIGHT`（private） | `1,3,9,27,19,26,16,17,20,29,25,13,8,24,10,30,28`（17 枚 = 3 的幂 mod 31） |
| `CreditCodeUtil.BASE_CODE_ARRAY`（private） | `0123456789ABCDEFGHJKLMNPQRTUWXY ## len=31`（剔 I/O/S/V/Z） |

### 12.3 判据（标签形如 `<字段>|<样本>`）

1. **正则的字符集与码表是同一枚集合**（都剔 I/O/S/V/Z）⇒ 过了形状闸的串，前 17 位必在码表内，
   校验位一定算得出来；参照 `getParityBit` 的 `-1` 分支只能从没过闸的串来，而那串在第一步已返回 false。
   ⇒ 本库保留 `-1` 哨兵是为**照形状**，不是为一条永不成立的档（写清楚，别让下一轮误以为"这里有未覆盖档"）。
2. **参照的码表自带 `^…$`，而 `ReUtil.isMatch` 又是 `matcher.matches()`**（两侧都锚）⇒ 本库把它写进
   `whole(…)`（补 `^(?:P)$`）时**去掉源文两侧锚记**，避免 `^(?:^…$)$` 这种形状；二者对本码表等价
   （对撞 228 条读数零分歧为凭）。
3. **码元域 vs 码位域在本批可证等价**：参照 `charAt(i)`/`charAt(17)` 是 UTF-16 码元域，本件 `to_array()` 是码位域。
   要走到校验位比较必须先过形状闸，而形状闸的字符集全是 ASCII ⇒ 前 18 位每枚都占一个码元 = 一个码位 ⇒ 逐位同一；
   含非 ASCII 的串两侧都在闸外出局（腿里 `"91110000MA01R\u3000RR9X4"`、`"91110000MA01R0000."` 两档都是 `SIMPLE=false`）。
   **这一条与第三批 A 的 `sub_*`/`hide_*` 不同**：那两族的下标直接作用在任意串上，所以索引域是分岔；本件有闸在前，不是。
4. **闸的顺序是契约**：腿里 4 条"第 3~8 位含字母（正则不吃）但校验位算得出"的样本
   （`91ABCDEFGHMA01R007` / `91AB12CDDE01R00005` / `9133A100MA200R0009` / `Y1ABCDEFMA01R0000Y`）
   两档都读回 `false` ⇒ "只算校验位、不先过闸"的实现必须被这些夹具打死（变异专打这一条）。
   这 4 条的**输入**由 `gen_gate_samples.py` 构造（脚本先自证它的权重公式能逐条复现腿造出的 10 枚有效码，10/10），
   期望值一律由腿读——构造输入不等于构造期望。
5. **有效码不是腿自己算的**：对 17 位前缀在参照码表上穷举第 18 位、取参照判 `isCreditCode=true` 的那枚，
   10 个前缀全部 `hits=1`（校验位对前缀是单值的）⇒ 10 条 `VALID=true` 的期望都来自"参照造出来的码"。
6. **逐位腐蚀族**：4 枚有效码 × 18 位，每位换成码表里下一枚 ⇒ 72 条腐蚀样本（`SIMPLE` 绝大多数仍 true、
   `VALID` 全 false）——这是把 mod-31 加权钉死的主力夹具族：只看两件布尔的实现，必须在这种腐蚀密度下才分得开。

### 12.4 腿与对撞

- 腿 `CreditCodeLeg.java`（真 hutool-core-5.8.35 + JDK 17.0.14，`javac -encoding UTF-8`）：
  **317 行读数、0 ERR**；进期望的是 `SIMPLE`/`VALID` 两字段（去重后 **2 块 228 条**，
  同键重复只在"读数一致"时折叠、不一致直接报错——本轮撞到一条形状档里写重复的样本，生成器当场报出），
  `SRC_*`/`FORGED`/`CORRUPT_TAG`/`CORRUPT_COUNT`/`RANDOM_SHAPE` 是证据行、不进期望（同第二批的 E 边腿口径）。
- **先对撞再冻结**：core 方言改写（`\d` → `[[:digit:]]`、去两侧锚）先在隔离副本上把实现写完并跑 228 条，
  结果 `Total tests: 472, passed 472, failed 0`、零警告 ⇒ 改写与参照命中集零分歧，才把期望冻进仓。
- 版内语法新踩一条：`expr?` 的可选链在**这个版本判词法错**（`unexpected token ?`，`moon check` 直接拒绝），
  所以校验位下标用 `-1` 哨兵整型（恰好与参照同形）。

### 12.5 与参照的分岔

| 参照 | 本库 | 依据 |
|---|---|---|
| 入/出口 `CharSequence` | `String` | 全仓一致 |
| `randomCreditCode()` | **不收** | §12.1（随机要显式种子） |
| `CREDIT_CODE_PATTERN` 常量公开可见 | 不作项暴露，码表进包内常量 | 本库没有 `Pattern` 型对应物 |
| `getParityBit` 返回 `-1` 表示算不出 | 同款 `-1` 哨兵（private，不暴露） | 参照形状；本批夹具走不到该分支（§12.3 第 1 条） |

### 12.6 变异对照（落地轮实测，隔离副本，基线 0 红 + 每条变异 `flush/fsync/写后回读断言` + `finally` 还原 + 收尾字节比对）

六条，**五条报红、一条按构造等价**（"见证夹具"是从失败输出把行号映射回 `// 字段|样本` 标签读出来的，不是人推的）：

| # | 变异 | 红块 | 见证 / 判读 |
|---|---|---|---|
| N1 | 去掉形状闸，只按长度放行 | 1 | `VALID|91ABCDEFGHMA01R007`（§12.3 第 4 条那族） |
| N2 | 去掉 `is_blank` 前置 | **0（按构造等价）** | 见下段 |
| N3 | 权重表换成顺位表 `1..17` | 1 | `VALID|91110000MA01R0000M`（72 条腐蚀族整片翻） |
| N4 | `31 - sum % 31` 少了归 0 那一支 | 1 | VALID 块以**运行时错误**失败＝`credit_base[31]` 越界 ⇒ 归 0 那一支确有夹具走到，不是死码 |
| N5 | 码表补回 `I`（31 枚变 32 枚，下标整体后移） | 1 | `VALID|91110000MA01RRT9X4` |
| N6 | 比较位从 `cs[17]` 改成 `cs[16]` | 1 | `VALID|91110000MA01R0000M` |

**N2 是按构造等价，不是夹具缺口**：`pat_credit` 的字符类 `[0-9A-HJ-NPQRTUWXY]` 里没有任何空白成员，
且 `{2}{6}{10}` 把长度钉死在 18 ⇒ 空白串（`""` / `" "` / `"\t"` / `"  "`）在正则这一步必然不命中，
`is_blank` 前置在本表下不可分辨。它仍留在实现里，理由是**照参照的判定顺序**（参照第一步就是 `isBlank`），
而不是"有夹具要求它"——与第三批 A 的 M8 同类：这类要在仓里写清"为什么不可能有夹具"，
别留给下一轮当"没测到"再查一遍。

### 12.7 状态

第三批 B（`CreditCodeUtil`）**已落地收口**：2 件全部填体，包内当场读数 `Total tests: 472, passed: 472, failed: 0`，
三档 wasm / js / wasm-gc 一致、`moon check` 零警告；2 块 228 条冻结期望一条未改来迁就实现，
`.mbti` 相对 PR-A 那一笔只多了两个新签名（PR-A 已登记）。骨架期 `warnings` 豁免整行删除（G12）。

## 13. 第三批 C `IdcardUtil`（#23.50–#23.54）

对位 `cn.hutool.core.util.IdcardUtil`（GB11643-1999 居民身份证号），`javap -public` 现读 **24 个 `public static`**；
**本批只收 5 件**（校验两件 + `ignore_case` 档一件 + 两件 convert），其余按可移植性分档挂账，见 §13.1。

### 13.1 边界（不收的逐条带理由）

- **切片族不收**（`getBirth/getBirthByIdCard/getYear/getMonth/getDay/getGender/getProvinceCode/getCityCode/
  getDistrictCode/hide`）：参照在这些件上的失败形状是 `null` / `NullPointerException` /
  `NumberFormatException` / `IllegalArgumentException` **四种混用**（腿 v1 现读：`getBirthByIdCard("")` 抛
  `id card must be not blank!`、`getBirthByIdCard(15 位含非数字)` 抛 NPE——参照把 `convert15To18` 的 `null`
  直接喂进 `Objects.requireNonNull`、`getYearByIdCard` 对非数字切片抛 `NumberFormatException`），
  映射口径要先单独拍一轮，别和校验算式挤在同一笔里换代。
- **不收** `getBirthDate`（出口 `DateTime`）、`getAgeByIdCard` 两件（读时钟 / 要 `java.util.Date`）、
  `getProvinceByIdCard`（码→省名的查表出口）、`getIdcardInfo`（返回内部类 `Idcard`）、
  `isValidCard`（按长度 18/15/**10** 分派，10 位那一支的出口是 `String[]`，与 P2 一起判）。
- **`CITY_CODES` 只收键集**（36 枚两位省码）——它是省码闸的语义；值（省名）不进本批。

### 13.2 公开面（5 件）

| # | 项 | 参照 | 关键依赖 |
|---|---|---|---|
| 23.50 | `idcard_is_valid_18(id, this_year)` | `isValidCard18(String)` | 省码键集 + 生日判据 + 权重/余数表 |
| 23.51 | `idcard_is_valid_18_case(id, this_year, ignore_case)` | `isValidCard18(String, boolean)` | 同上 + `CharUtil.equals` 的大小写档 |
| 23.52 | `idcard_is_valid_15(id)` | `isValidCard15(String)` | 同上，但年份恒 19xx ⇒ **不设 `this_year`** |
| 23.53 | `idcard_convert_15_to_18(id) -> String?` | `convert15To18(String)` | 世纪闭式 + 校验位；非法给 `None` |
| 23.54 | `idcard_convert_18_to_15(id, this_year) -> String` | `convert18To15(String)` | 内部走 #23.50；**非法原样返回入参** |

### 13.3 判据（标签形如 `<字段>|<样本>`；样本一律腿现读，不手打）

1. **省码闸在生日闸之前**，且 `startsWith("9")` 那一支取第 2~3 位当省码（新版外国人永居证）。
   专用夹具：`911010` 开头 + 生日 `19880203` 的号码可造出有效码（省码取 `"11"`），
   而 `910101` 开头（第 2~3 位是 `"10"`，不在键集）**任何**校验位都判 false——腿对该 17 位本体读出 `hits=0`。
2. **生日判据的四条子规则都要单变量夹具**：年 ∈ [1900, `this_year`]、月 ∈ [1,12]、日 ∈ [1,31]、
   4/6/9/11 月不吃 31 日、2 月只吃 ≤28（闰年 29）。腿用反射调参照自己的 private `getCheckCode18`
   拿到**正确校验位**再换生日段，于是"校验位对、生日错"的样本能隔离出这一判
   （若校验位随便挑，两种实现都回 false ⇒ 又是一条假等价——这正是第三批 A 那轮学的）。
   读数含 `1900 年 2 月 29 日 = false`、`1966 非闰 = false`、`1996 闰 = true`、`04/06/09/11 月的 31 日 = false`、
   `13 月 / 00 月 / 00 日 / 32 日 = false`。
3. **年份那一判（`year > this_year`）走显式参数**：腿在执行当年（2026）读数，故
   `20251231`/`20260101`/`20261231` 为 true、`20270101`/`20310615` 为 false（后两条校验位是参照自己算出的正确值，
   所以判 false 只能来自年份那一判）。**跨年不外推**：`this_year` 传别的值时本库按参照同一条判据行事，
   但没有另一年的参照读数，这一点在此写明而不是假装覆盖。
4. **`is_valid_15` 不设参数**：15 位号的年份区间是 1900..1999，`year > thisYear` 对任何 ≥1999 的执行当年恒不触发
   ⇒ 内部把上界钉成 1999 与参照逐档同值（腿对该族有读数）。
5. **世纪闭式**：`convert15To18` 对 yy=00..99 的 100 条读数给出 **yy=00 → 2000，其余 → 1900+yy**。
   参照那两条（`DateUtil.parse(·,"yyMMdd")` 的两位年基准年随执行当年移动、随后 `if (sYear > 2000) sYear -= 100`）
   合起来把基准年的影响整体吸收 ⇒ 该闭式**与执行当年无关**，故 #23.53 不需要 `this_year`。
6. **`NUMBERS` 整串匹配改写**成"全档数字且非空"（参照 `\d+` 无 `UNICODE_CHARACTER_CLASS` ⇒ 就是 `[0-9]`），
   这条改写逐字符可核对，不走正则。
7. **两件 convert 的失败形状相反**：`convert_15_to_18` 非法给 `None`（参照 `null`），
   `convert_18_to_15` 非法**原样返回入参**（腿：`"1101011965031252x"` → 同串）。
   `isNotBlank` 那一前置本库不抄：空白串走 `is_valid_18` 必为 false ⇒ 两支同结果（可证，省一条判据）。

### 13.4 腿与对撞

- 腿 `IdcardLeg.java`（真 hutool-core-5.8.35 + JDK 17.0.14）：**1071 行读数、0 ERR**，生成 **5 块 980 条**冻结期望。
  有效码**由参照自己造**：17 位本体在第 18 位候选 `0-9 + X` 上穷举，取参照判 `isValidCard18=true` 的那枚，
  11 个本体全部 `hits=1`；生日被拒的档另用反射 private `getCheckCode18` 取正确校验位（§13.3 第 2/3 条）。
  腐蚀族：2 枚有效码 × 18 位逐位换成下一候选字符（36 条）。
- **先对撞再冻结**：实现先在隔离副本跑，`Total tests: 477, passed: 477, failed: 0` 后才把期望冻进仓。
  对撞当场抓到两处本版 API 误写（`Char` 没有 `sub`/`add` 方法、`u'x'` 字面量不合法 ⇒ 一律走 `to_int()` 比较；
  以及**行延续必须把运算符留在行尾**，第三批 A 记过的那条本轮又踩），另抓到一条真缺陷：
  把 `'9'` 的码位误写成 49（那是 `'1'`），于是所有 1 开头省码被判 false——**5 个块首轮全红**，
  正是这批夹具密度该有的反应。

### 13.5 与参照的分岔

| 参照 | 本库 | 依据 |
|---|---|---|
| `isValidCard18` 读宿主当年 | 显式参数 `this_year`，夹具传腿执行当年 2026 | §13.3 第 3 条（跨年不外推） |
| `isValidCard15` 内部也读宿主当年 | 不设参数（上界钉 1999 同值） | §13.3 第 4 条 |
| `String` 出口、非法给 `null` | `String?` | 全仓一致 |
| 切片族四种异常形状混用 | **本批不收** | §13.1 |
| `isValidCard` 含 10 位档 | **本批不收**（与那道形状题同判） | §13.1 |
| 长度/切片按 UTF-16 码元 | 按码位（`to_array`） | 本批五件要走到非 false 的出口，前 18 位必全为 ASCII 数字或 `X` ⇒ 两域逐位同一；非 ASCII 一律在数字/省码/生日闸出局（腿里空格档、字母档、超长档都是 false） |

### 13.6 变异对照（落地轮实测，隔离副本，基线 0 红 + 每条变异 `flush/fsync/写后回读断言` + `finally` 还原 + 收尾字节比对）

九条，**九条全部报红、零等价**（本批是三轮以来第一次没有夹具缺口的一轮）。见证夹具从失败输出的行号
映射回 `// 字段|样本` 标签读出（断言被 `moon fmt` 折行时向后找 4 行取标签）：

| # | 变异 | 红块 | 见证夹具 |
|---|---|---|---|
| Q1 | 省码闸整条删掉 | 3 | `IS_VALID_18|91010119650312523X`（第 2~3 位 `"10"` 不在键集那一族） |
| Q2 | `startsWith("9")` 那一支删掉 | 3 | 同上——永居证档与它同片红，说明这一支真有专用夹具 |
| Q3 | 生日判据删掉年份区间 `[1900, this_year]` | 3 | `IS_VALID_18|110101202701015233`（校验位是参照自己算的正确值，见 §13.3 第 2/3 条） |
| Q4 | 删掉 4/6/9/11 月不吃 31 日的特例 | 3 | `IS_VALID_18|110101196506315232` |
| Q5 | 2 月一律吃到 29（闰年规则被抹平） | 3 | `IS_VALID_18|110101190002295234`（1900 非闰那一档） |
| Q6 | 权重表改用第三批 B 的 mod-31 那族 | 4 | `IS_VALID_18|110101196503125230`（两张表确不可混用） |
| Q7 | 世纪闭式换成朴素的 `yy<50 → 2000+yy` | 1 | `CONVERT_15_18|110101460101001`（yy=01..45 那 44 条读数就是为这一条准备的） |
| Q8 | 十八转十五的非法档改成给空串 | 1 | `CONVERT_18_15|91010119650312523X`（§13.3 第 7 条"失败形状相反"） |
| Q9 | `ignore_case` 参数被忽略（两档同形） | 1 | `IS_VALID_18_CS|11010119650312000x`——**这条夹具是 PR-A 阶段专门造出来的**：腿要先扫到一枚校验位恰为 `X` 的有效码（`XFOUND`），才谈得上区分两档 |

**为什么这批能做到零等价**：PR-A 写夹具矩阵时逐条问过"两种实现会在哪条样本上给出不同读数"，
凡是答不上来的当场补腿样本（年份边界四条、`04/06/09/11` 的 31 日、1900 非闰、`X` 结尾的有效码、
`yy` 全扫 100 条），而不是等变异轮跑完再补。第三批 A 那三条"补档前 0 红"的代价在这里被换成了收益。

### 13.7 状态

第三批 C（`IdcardUtil` 五件）**已落地收口**：包内当场读数 `Total tests: 477, passed: 477, failed: 0`，
三档 wasm / js / wasm-gc 一致、`moon check` 零警告；5 块 980 条冻结期望一条未改来迁就实现（`idcard_test.mbt`
相对 PR-A 那一笔逐字节未变），`.mbti` 与 PR-A 相同（签名是契约冻的）。骨架期 `warnings` 豁免整行删除（G12）。
本包**剩余未收口的面**（切片族九件、`isValidCard`、`DataSize`/`DataSizeUtil`、第四批三件）见 §13.1 与 §1。

### 13.8 补档：#23.53 还有一档参照是**抛**的（第三批 D 的切片腿当场翻出来）

落地之后接着跑第三批 D 的切片腿，`getBirthByIdCard` 一类样本冒出第五种失败形状：
`DateException: Parse [650229] with format [yyMMdd] error!`——**抛点在参照自己的 `convert15To18` 里**
（它先 `DateUtil.parse(yyMMdd, "yyMMdd")` 再拼世纪，日期不成立就直接崩）。补一条独立探针现读八档：

| 入参（15 位、全数字） | 参照 `convert15To18` |
|---|---|
| `110101650312523` | `110101196503125230`（正常档） |
| `110101650229523` | **抛** `DateException: Parse [650229] …`（1965 年无 2 月 29 日） |
| `110101651331523` | **抛** `DateException: Parse [651331] …`（13 月） |
| `110101000000001` | **抛** `DateException: Parse [000000] …` |
| `110101999999999` | **抛** `DateException: Parse [999999] …` |
| `990101650312523` | `990101196503125234`（**省码不在表内它也不管**——convert 不校验省码） |
| `110101000101001` | `110101200001010010`（世纪档 `yy=00 → 2000`，与 §13.3 第 5 条同闭式） |

于是本轮落地版有一处**真缺档**：`idcard_convert_15_to_18` 只按"数字闸 + 世纪闭式 + 补校验位"实现，
对日期不成立的 15 位号照样返回一个拼好的串，而参照是崩掉的。处置与第二批的崩溃档同一路子：
**参照抛 ⇒ 本库给 `None`**（本批 API 是 `String?`，不新增错误面），有效性直接复用 #23.52 那条生日判据
（`"19" + yyMMdd` 上界钉 1999，理由同 §13.3 第 4 条），并补 7 条断言成第 6 个块（4 条 `None` 档来自本表的上四行、
是映射档；3 条 `Some` 档是上表的 VAL 行）。当场读数 `Total tests: 478, passed: 478, failed: 0`，G3 基线 477 → 478。

**这一条要留的教训**（写进 §13.1 的分档理由旁边）：一批做完之后接着做下一批时，**新腿读到的样本会回头否定旧批的实现**——
旧批的"零等价变异"只证明**它自己的夹具集合**足够密，不证明该件的全部输入域都被想过。
下一批开工把上一批的边界样本再喂一遍，是便宜的回归手段（本轮就是靠它当场抓到 #23.53 的缺档）。
补档轮的变异对照：M10 删掉这条日期有效性闸 ⇒ 红 1 块，见证 `CONVERT_15_18|110101650229523`
（新加的 4 条 `None` 档确有区分力，不是"为覆盖率写的断言"；基线 0 红 + 写盘回读断言 + 收尾字节比对同批执行）。

## 14. 第三批 D `IdcardUtil` 切片族（#23.55–#23.63）

对位参照的九件取数件（`getBirth` / `getBirthByIdCard` / `getYear` / `getMonth` / `getDay` / `getGender` /
`getProvinceCode` / `getCityCode` / `getDistrictCode` / `hide`）。**本批收 9 件**：参照的
`getBirthByIdCard` 与 `getBirth` 是同一条实现（前者直接委托后者）⇒ 本库只留一件，不留别名。

### 14.1 边界

- 不收：`getBirthDate`（出口 `DateTime`）、`getAgeByIdCard` 两件（读时钟 / 要 `java.util.Date`）、
  `getProvinceByIdCard`（码→省名查表）、`getIdcardInfo`（返回内部类）——理由同 §13.1。
- **本批把 §13.1 挂账的"四种失败形状"扩成五种**（腿现读多出一类 `DateException`），并给出映射口径（§14.4）：
  九件一律**不 raise**，取不到给 `None`。

### 14.2 公开面（9 件）

| # | 项 | 参照 | 出口 |
|---|---|---|---|
| 23.55 | `idcard_birth(id)` | `getBirthByIdCard` / `getBirth` | `String?` |
| 23.56–23.58 | `idcard_year` / `_month` / `_day(id)` | `getYear` / `getMonth` / `getDay`（`Short`） | `Int?` |
| 23.59 | `idcard_gender(id)` | `getGenderByIdCard`（`int`） | `Int?` |
| 23.60–23.62 | `idcard_province_code` / `_city_code` / `_district_code(id)` | 同名三件 | `String?` |
| 23.63 | `idcard_hide(id, start, end)` | `hide(String, int, int)`（转委托 `StrUtil.hide`） | `String`（参照从不给 `null`） |

### 14.3 判据（腿现读，标签 `<字段>|<样本>`）

1. **15 位入参先转 18 位**：#23.55–#23.59 都走这条路 ⇒ 继承 §13.8 那条 `DateException` 档
   （腿在 `110101650229523` / `110101651331523` / `110101000000001` / `110101999999999` 上读到的就是这一崩），
   也继承"15 位含非数字 ⇒ `null` 喂进 `requireNonNull` ⇒ NPE"这一档（`110101650312X23`）。
2. **三件编码切片只看长度**：`getProvinceCodeByIdCard` 等只判 `len == 15 || len == 18` 就 `substring(0,2/4/6)`，
   **不校验省码、不校验日期、不校验是不是数字** ⇒ 18 位乱码串照给 `"ab"`（腿 `abcdefghijklmnopqrst` 长度 20 才出局）。
   这是三件与 #23.55/#23.59 的闸集合差异，别抹平。
3. **参照的空白闸本身不对称**：`getBirth`/`getGender` 有 `Assert.notBlank`（空白**抛** `IllegalArgumentException`，
   且两件文案不同：`"id card must be not blank!"` vs `"[Assertion failed] - this String argument must have text…"`），
   `getYear`/`getMonth`/`getDay` 和三件编码切片**没有**这一判（空白走长度门直接给 `null`）。
   本库照这个不对称实现（有空白闸的件先判空白给 `None`；没有的不加），抹平会让"参照给 null 与参照崩"两档混成一条。
4. **`idcard_gender` 是码位奇偶**：参照 `char charAt(16)` 再 `% 2` ⇒ 第 17 位为 `'A'`(65)/`'B'`(66)/`'C'`(67) 时
   参照分别给 `0/0/1`（腿有这一族），**不是**数字奇偶；数字档上两者同值，所以必须留非数字夹具才分得开。
5. **`idcard_hide` 走码位**（参照委托 `StrUtil.hide`，与 #23.40–#23.42 同族），越界夹紧、不校验号型，
   掩码字符固定 `*`；参照的出口在九件里唯一**永不为 `null`** ⇒ 本件出口 `String` 而非 `String?`。

### 14.4 失败形状映射表（本批的设计决定，逐条对号）

| 参照形状 | 出现条件（腿现读） | 本库 |
|---|---|---|
| 给 `null` | 长度 <15（`getBirth` 系）/ 长度非 15、18（三件编码切片、`getGender`） | `None` |
| `NullPointerException` | 15 位号 `convert15To18` 返回 `null` 后被 `Objects.requireNonNull` 崩 | `None` |
| `NumberFormatException` | `Short.valueOf(substring(6,10 / 10,12 / 12,14))` 遇非数字切片 | `None` |
| `IllegalArgumentException`（两种文案） | `Assert.notBlank` 在空白档；`getGender` 的长度门 | `None` |
| `DateException` | 15 位号的 `yyMMdd` 不是合法日期（`convert15To18` 内） | `None` |

**信息损失要写明**：五类形状在本库都收敛成同一个 `None`，调用方**无法**再分辨"参照会说 null"与"参照会崩"。
选择这样做的理由：这些崩是参照的实现副产物（把 `null` 喂进后续调用），不是设计出来的错误面；
第二批 `Ipv4Util` 的 `BadIp/BadMask` 那套是参照**主动抛带文案**的判据，两者形状不同才一个留错误面、一个并 `None`。
判据侧的成本由 §14.3 的闸集合差异承担（三件编码切片与 #23.55/#23.59 的闸不同，映射后仍可从期望里看出）。

### 14.5 腿与对撞

- 腿 `IdcardSliceLeg.java`：**357 行读数（310 VAL + 47 ERR）**，生成 **5 块 351 条**期望；
  其中 **47 条是 ERR 行按 §14.4 映射成 `None`** 的断言——行尾保留原始异常类名，
  让"这条期望来自映射而不是参照返回值"在测试文件里看得见，不冒充 VAL 读数。
  样本族：有效 18 位 6 枚（校验位由参照判定穷举，hits=1）、合法 15 位 6 枚、15 位非法 6 枚、
  长度 14/15/16/17/18/19/20 各档、第 17 位非数字的奇偶族、空白与全数字坏形状。
- **先对撞再冻结**：实现先在隔离副本跑，`Total tests: 483, passed: 483, failed: 0` 后才冻进仓。
  对撞抓到两处形状误写（都是本体的错，不是期望的错）：`Int` 返回值没包 `Some`（本版不做隐式升 `Option`）、
  以及 `idcard_hide` 的期望一度被生成器写成 `Some(…)`——参照这一件**永不给 null**，出口该是 `String`，
  生成器按此改回明文字符串（这是生成器自身的形状错，不是腿读数错）。

### 14.6 变异对照（落地轮实测，隔离副本，基线 0 红 + 写盘 `flush/fsync/回读断言` + `finally` 还原 + 收尾字节比对）

七条，**五条报红、两条按构造等价**（见证从失败行号映射回 `// 字段|样本` 标签读出）：

| # | 变异 | 红块 | 见证 / 判读 |
|---|---|---|---|
| R1 | 三件编码切片补上参照没有的"必须是数字"闸 | 1 | `PRO_CODE|110101650312X23` ⇒ "别自作聪明加闸"这条确有读数 |
| R2 | 删掉 `idcard_birth` 的空白闸 | **0（按构造等价）** | 空白串一律长度 <15（或转不出 18 位）⇒ 后面那道长度闸同样给 `None`；留这一判是照参照的 `Assert.notBlank`，不是有夹具要求它（同 §11.6 M8、§12.6 N2 一族） |
| R3 | 非数字切片给 `Some(0)` 而非 `None` | 1 | `YEAR|abcdefghijklmnopqrst`（这条期望本就映射自参照的 `NumberFormatException`） |
| R4 | `gender` 的奇偶改成"先减 48 再取模" | **0（等价，且证伪了 §14.3 第 4 条的原措辞）** | `(c - 48) % 2 == c % 2` 对任意 `c` 恒成立（48 是偶数）⇒"按码位算"与"按数字算"**永远同值**；该条判据的真实内容只是"参照对第 17 位不做数字校验、任何字符都给值"。已就地改写那条，不留错话 |
| R5 | `gender` 的索引从 16 挪到 17 | 1 | `GENDER|110101196503125230` |
| R6 | 15 位入参不做转换、直接切原串 | 2 | `BIRTH|110101650312523` 与 `YEAR|…`（走 15 位路径的四件都吃这一档） |
| R7 | 掩码字符 `*` 换成 `#` | 1 | `HIDE_6_14|110101196503125230` |

**码元/码位这一族在本批不可分辨，也不假装被覆盖**：`idcard_hide` 的样本全是 ASCII ⇒ 两域同值；
它走码位的依据是 #23.40–#23.42 那批的同族结论（参照 `StrUtil.hide` 掩的是码位，那批有 astral 夹具钉过）。

### 14.7 状态

第三批 D（`IdcardUtil` 切片族 9 件）**已落地收口**：包内当场读数 `Total tests: 483, passed: 483, failed: 0`，
三档 wasm / js / wasm-gc 一致、`moon check` 零警告；5 块 351 条冻结期望一条未改来迁就实现，
`.mbti` 与 PR-A 相同（签名是契约冻的）。骨架期 `warnings` 豁免整行删除（G12）。
两条等价按"构造解释"入档，其中 R4 顺手改写了 §14.3 第 4 条的一处错判。

## 15. 第三批 E `DataSize` / `DataSizeUtil` / `DataUnit`（#23.64–#23.82）

件在 `cn.hutool.core.io.unit`（**不在 `cn.hutool.core.util`**——`DataSizeUtil` 才在 `util`，
两个包名要分清，腿是按现读包名 import 的）。参照那一族是个**只有一个 `long bytes` 字段的值对象**
加一个五常量枚举，其余方法全是对那个字段的纯函数 ⇒ 本批把"数据量"直接摊平成 `Int64` 字节数，
不引对象层。

### 15.1 边界（收与不收，逐条带理由）

**收 19 件**（解析 2 / 构造 6 / 出口 7 / 比较 2 / 单位表 2），列在 §15.2。

**不收的，逐条**：

| 参照件 | 判据 |
|---|---|
| `DataSizeUtil.format(long)` / `format(Long, DataUnit)` 两族（现读更正：这两件在 `cn/hutool/core/io/unit/DataSizeUtil`，**不是 `DataSize` 的方法**，也不在 `core.util`；参照**没有 `toUnit(…)` 一族**，该包 `grep toUnit` 零命中——原条目把它写作 `DataSize.*` 并多列了 `toUnit`，详见 §17.8 末） | 选档靠 `Math.log10(size) / Math.log10(1024)` 的**浮点边界**，印数靠 `DecimalFormat("#,##0.##")` 的千分位 + `HALF_EVEN`。两件事都要先在 core 侧做出同语义的实现才能冻期望，**另批做**；腿里 150 条读数（`FMT` 25 + `FMT_AT_*` 5×25）已存着，届时直接灌 |
| `DataSize.of(BigDecimal, DataUnit)` / `of(String, DataUnit)` | 是 `parse` 的中间站，公开面由 `data_size_parse_bytes` 覆盖；`of(long, DataUnit)` 那档由 #23.71 覆盖 |
| `DataSizeUtil` 的 `format` / `convertToMaxUnit` | 同上，都属 `format` 族 |
| `DataSize` 的实例 API（`compareTo` / `equals` / `hashCode` / `toString`）| 已摊平成 #23.78–#23.80 三件纯函数；`hashCode` 是 `Long.hashCode(bytes)`，值对象已被字节数完全代表 ⇒ 不单立件 |
| `DataUnit.getSuffix()` | 后缀就是查表的键，没有第二个来源；`UNIT_NAMES` 的原序由 #23.82 钉 |

**腿 512 行（424 VAL + 88 ERR）里进了契约的 360 条**，其余 151 条 + 1 条重样本的去处：150 条属 `format` 族（上一行）、
`OF_NULL_UNIT` 1 条见 §15.5 末两行、`PARSE|1ZB` 与首批那条重样本同键折叠（生成器对"同键不同读数"直接报错，对重样本只留一条）。

### 15.2 公开面（19 件）

| 件 | 参照 | 返回 | Raises |
|---|---|---|---|
| #23.64 `data_size_parse_bytes(text)` | `DataSize.parse(CharSequence)` | `Int64` | `BadText` |
| #23.65 `data_size_parse_bytes_with(text, suffix)` | `DataSize.parse(CharSequence, DataUnit)` | `Int64` | `BadText` |
| #23.66 `data_size_of_bytes(b)` | `ofBytes(long)` | `Int64` | 无（**参照不查重**） |
| #23.67–70 `data_size_of_{kilobytes,megabytes,gigabytes,terabytes}(n)` | `ofKilobytes` 等 | `Int64` | `Overflow` |
| #23.71 `data_size_of_amount_suffix(n, suffix)` | `of(long, DataUnit)` | `Int64` | `BadText` / `Overflow` |
| #23.72–76 `data_size_to_{bytes,kilobytes,megabytes,gigabytes,terabytes}(n)` | `toBytes()` 等 | `Int64` | 无 |
| #23.77 `data_size_is_negative(n)` | `isNegative()` | `Bool` | 无 |
| #23.78 `data_size_to_string(n)` | `toString()` | `String` | 无 |
| #23.79 `data_size_compare(a, b)` | `compareTo(DataSize)` | `Int` | 无 |
| #23.80 `data_size_equal(a, b)` | `equals(Object)` | `Bool` | 无 |
| #23.81 `data_unit_bytes_by_suffix(suffix)` | `DataUnit.fromSuffix(String)` + `size()` | `Int64?` | 无 |
| #23.82 `data_unit_suffixes()` | `DataUnit.UNIT_NAMES`（公开静态数组，反射读） | `Array[String]` | 无 |

`DataSizeUtil.parse(CharSequence)` ≡ `DataSize.parse(text).toBytes()`，与本库 #23.64 是同一条腿 ⇒ 不单立件；
但腿里 `UTIL_PARSE` 那 34 条读数**单独成块留着**，作用是钉"参照的两个入口读数一致"这件事，实现只有一份。

### 15.3 判据（标签 `<字段>|<样本>`；样本一律腿现读，不手打）

1. **整串清空白**在正则之前：`PARSE|1 2 KB` 与 `PARSE|  8  GB  ` 分别给 `12288` / `8589934592`。
2. **数值段只认 ASCII 数字**（参照正则 `^([+-]?\d+(\.\d+)?)([a-zA-Z]{0,2})$`，`\d` 不带 `UNICODE_CHARACTER_CLASS`）：
   `PARSE|\uff11\uff12KB`、`PARSE|\u0663KB`、`PARSE|3\u0663KB`、`PARSE|\u0663\u0662` 四条都 `BadText`。
   符号只允许**开头一个** `[+-]?`：`PARSE|+7MB` 给 `7340032`，而 `PARSE|1e3` / `PARSE|0x10` / `PARSE|.5KB` / `PARSE|5.` /
   `PARSE|1B B` / `PARSE|1.2.3KB` / `PARSE|KB` / `PARSE|`（空串）/ `PARSE| `（纯空格）九条 `BadText`。
3. **后缀最多两字母**（正则那一档）与**后缀不认**（`fromSuffix` 那一档）是两个不同来源、同一个出口：
   `PARSE|1ZB` 与 `PARSE|1PB` 都**过了正则**（都是两字母后缀）、都死在 `fromSuffix`，参照把内层一切异常包成
   同一个 `IllegalArgumentException` ⇒ 两条都记 `BadText`。（PR-A 这里原写"1ZB 被正则挡下"是因果写错，
   落地轮的 N7 把它翻出来——正则的长度上限与 `fromSuffix` 的不认在**结果**上分不出彼此，推导见 §15.6 末。）
4. **`fromSuffix` 是前缀匹配**（`candidate.suffix` 以入参**开头**即命中，忽略大小写）：
   `FROM_SUFFIX|K`→KB、`|M`→MB、`|G`→GB、`|T`→TB、`|b`→B、`|g`→GB、`|kb`、`|Kb` 都命中；
   `FROM_SUFFIX|`（空串）命中**第一枚** ⇒ B（`startWith*` 对空前缀恒真）；
   而比候选更长的 `|kBB`、`|BBB`，以及带空白的 `|TB ` 全不认（空白档只在 `parse` 里被清掉，反查件不清）。
   这条决定 #23.71 / #23.65 的后缀解析必须**共用**#23.81 那张表，不能各写一份。
5. **小数段是十进制精确乘，不是浮点**：`PARSE|1.9999999999999999KB` 给 `2047`（`double` 会把这串读成 `2.0`，乘完给 `2048`）、
   `PARSE|0.0009765625KB` 给 `1`、`PARSE|9007199254740993B` 原样给回（超出 `double` 精确整数域）。
   加上 `PARSE|1.1KB`=`1126`、`PARSE|0.9KB`=`921`、`PARSE|1.999MB`=`2096103` 一起钉住"乘完向零截断"。
6. **截断方向**：`PARSE|-1.5KB`=`-1536`、`PARSE|-0.5KB`=`-512`、`PARSE|0.5B`=`0`（`BigDecimal#longValue` 向零）。
7. **`of*(long)` 的精确溢出边界**（参照 `Math.multiplyExact`，每条单位各有上下两档）：
   `OF_KB|9007199254740991` 是值、`|9007199254740992` 溢出；`OF_MB|9007199254740991` 溢出；
   `OF_GB|1099511627776`、`OF_TB|1099511627777`、`OF_MB|9223372036854` 溢出；
   正负两端都查（`OF_*|-9223372036854775808` 全溢出）；`OF_UNIT_BIG` 块用 `9223372036854775807` 乘五枚单位，只有 `|B` 活着。
8. **`ofBytes` 不查重**：`OF_BYTES|9223372036854775807` 与 `| -9223372036854775808` 都是值。
9. **`toXxx` 是 Java 整除**（向零截断、不是 floor）：`TO_KB|-1023`=`0`、`TO_KB|-1536`=`-1`、`TO_TB|1099511627775`=`0`。
10. **表自身的不对称**：`SRC_UNIT_NAMES` 给七枚 `B,KB,MB,GB,TB,PB,EB`，而 `FROM_SUFFIX|PB` / `|EB` 反查 `None`——
    表里有、枚举里没有，这两条读数必须同时成立才算抄对。
11. **`compare` 用 `Long.compare` 语义**：`CMP_VS_ZERO|9223372036854775807`=`1`、`|-9223372036854775808`=`-1`。
    写差值会在这一档炸（见 §15.6 M12）。
12. **`is_negative` 不含 0**（`IS_NEG|0`=`false`），**`to_string` 恒带 `B`**（`TO_STRING|-1023`=`-1023B`）。

### 15.4 腿与对撞

腿 `Temp/convsrc/datasize/DataSizeLeg.java`（491 行）+ `DataSizeLeg2.java`（21 行，专钉 §15.3 第 4、5 条），
真 `hutool-core-5.8.35.jar` + JDK 17.0.14，`-Dfile.encoding=UTF-8`，跑完 `grep -c ERR` 读数 88。
表面两件事走反射现读：`DataUnit.UNIT_NAMES`（公开字段）与每枚常量的 `size().toBytes()`（`size()` 是包私有，
故用 `DataSize.of(1, unit)` 这条公开路取）。
期望文件由 `gen_ds_test2.py` 灌入，`assert_eq` 360 条 / 6 块；生成器对同键样本冲突直接 `SystemExit`。
形状预检在隔离副本做完：`moon check` **0 错误**，23 条警告全属 stub 自身（骨架文件零警告来自真实签名）。

### 15.5 与参照的分岔

| 参照 | 本库 | 依据 |
|---|---|---|
| `DataSize` 值对象 / `DataUnit` 枚举当参数 | `Int64` 字节数 / 后缀 `String` | 值对象只有一个 `long` 字段；枚举值在本仓取不到（22 个包零 `pub enum`），不为一次移植新开跨包取值形状 |
| `parse` 把内层一切异常包成 `IllegalArgumentException` | `raise BadText` | 参照在 `catch (Exception ex)` 里统一重抛，文案 `'…' is not a valid data size` 不分子档 ⇒ 单档够 |
| `of*(long)` 抛 `ArithmeticException: long overflow` | `raise Overflow` | 腿 22 条 ERR 读数 |
| `fromSuffix` 未知后缀**抛** | `data_unit_bytes_by_suffix` 给 `None` | 纯查表面，调用方大多只想知道"认不认"；构造面（#23.71 / #23.65）仍 `raise BadText` |
| `parse(cs, DataUnit)` 的默认单位在类型上不可能非法 | 兜底后缀非法 ⇒ `BadText` | **本库新增档，无腿读数**（把单位降成串就多出这一档），是设计决定 |
| `of(3, null)` 按 `BYTES` 给 `3`（腿 `OF_NULL_UNIT|‑` = `5` 那类）| 无对应件 | 后缀串给不出 `null`；空串走 §15.3 第 4 条命中 B，两件事在参照里是同一枚 BYTES |
| `StrUtil.cleanBlank` / `PatternPool` / `Assert` 内部件 | 包内实现细节 | 不进公开面 |

### 15.6 变异对照（PR-B 填读数；隔离副本，基线 0 红 + 写盘 `flush/fsync/回读断言` + `finally` 还原 + 收尾字节比对）

| 号 | 变异 | 计划打的档 |
|---|---|---|
| N1 | 不做 `cleanBlank`（只在正则里允许空格） | `PARSE\|1 2 KB`、`\|  8  GB  ` |
| N2 | 后缀匹配"前缀"改"全等" | `FROM_SUFFIX\|K`/`\|M`/`\|G`/`\|T`/`\|b`/`\|g`/`\|`（空串）与 `PARSE\|12K` |
| N3 | 小数段改 `double` 乘 | `PARSE\|1.9999999999999999KB`（2047→2048）、`\|0.0009765625KB`、`\|9007199254740993B` |
| N4 | 截断改四舍五入 | `PARSE\|1.1KB`、`\|0.5B`、`\|-0.5KB`、`TO_KB\|1535` 类 |
| N5 | `of*` 不做溢出查重 | `OF_KB\|9007199254740992` 等 22 条 ERR 档 + `OF_UNIT_BIG` 四条 |
| N6 | `ofBytes` 加查重 | `OF_BYTES\|9223372036854775807`（VAL 变红） |
| N7 | 后缀长度上限放开（正则 `{0,2}` 改 `{0,}`） | `PARSE\|1ZB`、`\|1B B`、`\|1.2.3KB` |
| N8 | `toXxx` 用 floor 除或移位 | `TO_KB\|-1023`、`TO_KB\|-1536`、`TO_TB\|1099511627775` |
| N9 | 单位表只出枚举里的五枚 | `SRC_UNIT_NAMES`（七枚）与 `FROM_SUFFIX\|PB`/`\|EB` 的不对称 |
| N10 | `BadText` / `Overflow` 变体互换 | 87 条 `ERR:` 期望（两条 catch 腿各自报红） |
| N11 | `to_string` 漏掉尾 `B` | 16 条 `TO_STRING` |
| N12 | `compare` 写 `a - b` 差值 | `CMP_VS_ZERO\|9223372036854775807`、`\|-9223372036854775808` |

**落地轮实测**（隔离副本 `tar` 出来的第三份工作树，开局基线 `red=0`、收尾还原后复跑仍 0 红；
每条变异写盘都过 `flush + fsync + 回读断言`，"编不过"单列成 `MUTATION-DID-NOT-COMPILE` 而不是被当成等价）：

| N1 | N2 | N3 | N4 | N5 | N6 | N7 | N8 | N9 | N10 | N11 | N12 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 3 红 | 2 红 | 3 红 | 3 红 | 1 红 | 1 红 | **0 红（等价）** | 1 红 | 1 红 | 3 红 | 1 红 | 1 红 |

十一条报红、一条等价。**N7 这条等价不用补夹具，因为在参照那一侧也观测不到差别**：
把 `[a-zA-Z]{0,2}` 放开成不限长度，只影响"三个字母以上的后缀"，而 `fromSuffix` 的条件是
**候选后缀以入参开头**——五枚候选最长两字母，任何三字母以上的入参必然全不命中、照样抛，
两条路的出口同为 `BadText`（参照的包装文案也一样）。这不是"夹具没打到"，是"没有能打得到的样本"，
所以照 §14.6 R4 的先例记成构造等价并把推导写在原地，而不是硬造一条读数出来。

一处取证件工装的不足留话在此：见证样本串被取样正则 `(\S+)` 在空格/中文括号处截断（打印出来像 `PARSE|1`），
**红条数是准的、样本串不作数**——要精确样本就按行号回 `typex/datasize_test.mbt` 读原行。

### 15.7 状态

第三批 E（`DataSize` / `DataSizeUtil` / `DataUnit` 安全档 19 件）**已落地收口**：当场读数
`Total tests: 489, passed: 489, failed: 0`，wasm / js / wasm-gc 三档一致、`moon check` 零警告；
6 块 360 条冻结期望一条未改来迁就实现（`.mbti` 与 PR-A 同签名）。骨架期那一行 `warnings = "-unused_value"`
豁免整行删除、包私有 `datasize_unimplemented` 整件删除（G12：体里已无 `abort`）——
顺带留一条工装读数：本版 `moon.pkg` 的 `warnings` **只容一个助记符**（数组形报 `[4192] Invalid configuration`、
空格形与逗号形被 `moonc` 判 `Ill-formed list of warnings`、写两行同键报 `Duplicate key`），
所以骨架期另两类警告只能靠"真的构造变体、真的 raise"消掉，不能靠豁免。

落地笔翻出一条 PR-A 没写到的实现约束，与 §15.3 第 5 条并记：**"十进制精确乘"若照公式直算
`(整数段 * 10^k + 小数段) * unit / 10^k`，在 `PARSE|1.9999999999999999KB` 这一档中间量是 `2.05e19`，
冲出 `Int64` 后环绕成 `203`**——当场只这一条红、三档同值 ⇒ 不是平台差异，是算术宽度。
参照那边是 `BigDecimal` 乘完才 `longValue()`，没有这一步可炸。正解写在 `ds_frac_bytes`：
先把 `unit` 与 `10^k` 的 2 的公因子约掉（五枚单位恒是 2 的幂），再用 `(f/s)*u + ((f%s)*u)/s` 拆开，
拆开后两段中间量分别 `≤ frac` 与 `< s*u`，都不出 `Int64`。
一句话：**"不许换成浮点"的另一半是"也不许换成看着精确、实则窄化在错误一步的整型直算"**。

`format` / `format(…, unit)` 两族按 §15.1 留另批，腿里 150 条读数存着等 core 侧对撞。

## 16. 第四批第一格 `DesensitizedUtil`（#23.83–#23.96）

件在 `cn.hutool.core.util.DesensitizedUtil`，枚举 `DesensitizedType` 是**同文件内嵌**（第 29 行起，15 档），
不在别的包——这一点现读源码确认过，别再按 `lang` 那类包名去猜。

### 16.1 边界（收与不收，逐条带理由）

**收 14 件**：13 件具体脱敏 + 1 件调度器，列在 §16.2。

| 参照件 | 判据 |
|---|---|
| `clear()` / `clearToNull()` | **不立公开件**：两者是无入参的常量出口（`""` 与 `null`），本库的出口形状在 §16.2 里是 `String` / `String?`，为常量立两件公开面等于把"参照的 switch 尾巴"当 API。两档行为仍由 #23.96 的 `CLEAR_TO_EMPTY` / `CLEAR_TO_NULL` 覆盖，腿里那 2 行读数因此**不进契约**（生成器 `DROP` 记账，收尾对得上：121 行 − 2 = 119 条断言） |
| `desensitized(CharSequence, …)` 的入参类型 | 收 `String`（全仓一致），不额外收 `CharSequence` 面 |
| 枚举本身 | 收**档位串**（照 §15.1 先例：本仓零 `pub enum`，不为本格新开跨包取值形状）。15 档名逐字照 `DesensitizedType.name()`：`USER_ID` `CHINESE_NAME` `ID_CARD` `FIXED_PHONE` `MOBILE_PHONE` `ADDRESS` `EMAIL` `PASSWORD` `CAR_LICENSE` `BANK_CARD` `IPV4` `IPV6` `FIRST_MASK` `CLEAR_TO_NULL` `CLEAR_TO_EMPTY` |

### 16.2 公开面（14 件）

| 件 | 参照 | 返回 | 备注 |
|---|---|---|---|
| #23.83 `desensitize_first_mask(str)` | `firstMask` | `String` | |
| #23.84 `desensitize_chinese_name(full_name)` | `chineseName` | `String` | 参照是 #23.83 的一行委托 ⇒ 件留、嘴不留（§11.6 先例） |
| #23.85 `desensitize_id_card(id_card, front, end)` | `idCardNum` | `String` | 三道闸，见 §16.3 第 2 条 |
| #23.86 `desensitize_fixed_phone(num)` | `fixedPhone` | `String` | `hide(num, 4, len-2)` |
| #23.87 `desensitize_mobile_phone(num)` | `mobilePhone` | `String` | `hide(num, 3, len-4)` |
| #23.88 `desensitize_address(address, sensitive_size)` | `address` | `String` | `hide(a, len-n, len)`，起始位可为负 |
| #23.89 `desensitize_email(email)` | `email` | `String` | `index <= 1` 原样返回 |
| #23.90 `desensitize_password(password)` | `password` | `String` | 星号数按**码元** |
| #23.91 `desensitize_car_license(car_license)` | `carLicense` | `String` | 只动码元长度 7 / 8 |
| #23.92 `desensitize_bank_card(bank_card_no)` | `bankCard` | `String` | blank **原样返回入参** |
| #23.93 `desensitize_ipv4(ipv4)` | `ipv4` | `String` | 不校验 |
| #23.94 `desensitize_ipv6(ipv6)` | `ipv6` | `String` | 不校验 |
| #23.95 `desensitize_user_id()` | `userId` | `Int64` | 恒 `0` |
| #23.96 `desensitize_kind(text, kind)` | `desensitized` | `String?` | 只有 `CLEAR_TO_NULL` 档给 `None` |

### 16.3 判据（标签 `<字段>|<样本>`；样本一律腿现读，不手打）

1. **两域混用是本批的主线**：参照的闸与计数走 `String.length()`＝UTF-16 码元，遮蔽走 `StrUtil.hide`＝码位。
   `PASSWORD|🍎ab` 给 `****`（4 个星＝码元数，不是码位数 3）、`EMAIL|🍎🍎@x.com` 给 `🍎***.com`
   （`'@'` 的码元索引是 4，遮蔽按码位从 1 掩到 4）、`ID_CARD|🍎51343620000320711X,1,2` 给 `🍎` + 17 个 `*` + `X`
   （长度闸按码元 20 过闸，遮蔽在 19 个码位上走 `[1, 18)`）。
   `CAR_LICENSE|京A1234🍎` 码元 8 / 码位 7 ⇒ 走的是**新能源那支** `hide(…, 3, 7)`，读数 `京A1****`；
   `CAR_LICENSE|ABCDEFGH`（码元 8）给 `ABC****H`，而 `京A123`（码元 6）原样返回——**只动 7 与 8**。
2. `idCardNum` 三道闸**先后是**：空白 → `front + end > 码元长度` → `front < 0 || end < 0`，三者都给空串。
   读数成对钉住先后：`ID_CARD|12345,3,3` 与 `|12345,6,0` 都被"长度"闸拦下给空串，
   `|12345,-1,2` 与 `|12345,1,-2` 都因负数闸给空串——把两道闸互换在这四条上看不出来，变异 D4 专打。
3. **短号与负起始的三种形状**都出现在腿里、实现不许"顺手统一"：`FIXED_PHONE|12345` 与 `MOBILE_PHONE|12345`
   都**原样返回**（`hide` 的 `start > end` 档），`ADDRESS|北京,8` 与 `|北京,99` 给 `**`（起始位为负 ⇒ 整串掩掉），
   而 `ADDRESS|北京,0` 原样给 `北京`；`ADDRESS|🍎🍎号街道,2`（码元 7、码位 6）也原样——负数与越界在两个域里落到不同档。
4. **`bankCard` 两处独一份**：blank 原样返回**入参本身**（不是空串，`BANK_CARD|  ` → 两个空格原样）；
   清洗后 `< 9` 位原样返回清洗结果；否则末段长度是 `len % 4 == 0 ? 4 : len % 4`，中段每满 4 位**先插一个空格再插 `*`**
   （`BANK_CARD|12342222333344449` → `1234 **** **** **** 9`，读数在腿里；这条也是腿的自检项之一）。
5. `ipv4` / `ipv6` **完全不校验**：`IPV4|abc` → `abc.*.*.*`、`IPV4|`（空串）→ `.*.*.*`。
   ⇒ 本件与第二批 `Ipv4Util`、`valid.is_ipv4` **没有任何关系**，实现里不许出现第二张嘴。
6. 调度器三处内联参数：`DP_ID_CARD` 用 `(1, 2)`（`51343620000320711X` → `5***************1X`）、
   `DP_ADDRESS` 用 `8`、`DP_USER_ID` **丢弃入参**给 `0`（`DP_USER_ID|100` → `0`）；
   `DP_CLEAR_TO_NULL|abc` → `None`，`DP_CLEAR_TO_EMPTY|abc` → `Some("")`；
   空白入参在调度器最前面一道闸统一给 `Some("")`（`DP_ID_CARD|` → `Some("")`）。

### 16.4 腿与对撞

腿 `Temp/convsrc/desens/DesensitizedLeg.java`（121 行读数、**零 ERR**——这批参照不抛）。
两枚自检项在腿里跑（`password` 的码元数、`bankCard` 的分段形状），读数变了会先打印 `SELFCHK` 而不是静默进期望。
期望由 `gen_desens_test.py` 灌入：**10 块 119 条**，同键冲突即 `SystemExit`，未登记字段即 `SystemExit`；
`CLEAR` / `CLEAR_TO_NULL` 两行按 §16.1 判不收、由生成器显式 `DROP` 计数（121 − 2 = 119，账面闭合）。
代理项 `\ud83c\udf4e` 在生成器里合成码位再落 `\u{…}` 字面量（本仓 `lit()` 形状）。

### 16.5 与参照的分岔

| 参照 | 本库 | 依据 |
|---|---|---|
| `DesensitizedType` 枚举当参数 | 档位串 `String` | §15.1 先例（本仓零 `pub enum`） |
| 未列出的档位串 | 走不到（枚举穷尽、`default` 空分支返回原串）| 本库按 `default` 的构造**给原串**，无腿读数，是构造解释不是新语义 |
| `desensitized` 返回 `null`（`CLEAR_TO_NULL` 档）| `None`，返回类型 `String?` | 与第二批"参照给 null 的地方本库给 Option"同形 |
| `clear()` / `clearToNull()` 两件常量出口 | 不立公开件 | §16.1 |
| `CharUtil.SPACE`、`StrUtil.hide` 的 `*` 与空格 | 复用 `@text.hide(..., '*')` 与包内 `ds_clean_blank` | 不留第二张掩码表 / 第二张空白表 |
| `String.length()`（码元）与 `StrUtil.hide`（码位）混用 | **照抄这种混用**，不"抹平"成单域 | 腿里 astral 夹具逐条钉住；这是移植的一致性，不是缺陷 |

### 16.6 变异对照（PR-B 填读数；隔离副本，基线 0 红 + 写盘 `flush/fsync/回读断言` + `finally` 还原 + 收尾字节比对）

| 号 | 变异 | 计划打的档 |
|---|---|---|
| D1 | 把码元长度改用码位数（`password` 星号数） | `PASSWORD|🍎ab`、`|🍎🍎` |
| D2 | `email` 的 `'@'` 索引改用码位 | `EMAIL|🍎🍎@x.com`、`|x🍎@y.com` |
| D3 | `idCardNum` 的长度闸改用码位 | `ID_CARD|🍎51343620000320711X,1,2` |
| D4 | `idCardNum` 两道闸互换先后 | `ID_CARD|12345,1,-2`（负数 vs 长度） |
| D5 | `carLicense` 的长度判据改用码位 | `CAR_LICENSE|京A1234🍎` |
| D6 | `bankCard` blank 改给空串 | `BANK_CARD|  ` |
| D7 | `bankCard` 末段长度改成恒 4 | `|…17 位`、`|…10 位` 等非 4 倍数档 |
| D8 | `bankCard` 中段空格改成**每 4 位之后**插 | 全部 `BANK_CARD` 非空读数 |
| D9 | `ipv4` 改成先校验 IP 合法性（引入第二张嘴） | `IPV4|abc`、`IPV4|`（空串） |
| D10 | 调度器 `ID_CARD` 档改成 `(1, 1)` / `ADDRESS` 改成 6 | `DP_ID_CARD|…`、`DP_ADDRESS|…` |
| D11 | 调度器 `USER_ID` 档改成返回入参 | `DP_USER_ID|100` |
| D12 | `CLEAR_TO_NULL` 档给 `Some("")` | `DP_CLEAR_TO_NULL|abc` |
| D13 | 空白前置闸从调度器去掉（各件自带） | `DP_ID_CARD|`（空串）、`DP_CLEAR_TO_EMPTY|  ` |

### 16.7 状态

第四批第一格（`DesensitizedUtil` 14 件）**契约冻结在案**：骨架 14 件、10 块 119 条冻结期望全部来自腿的现读读数
（手打零条），当场 `Total tests: 499, passed: 489, failed: 10`（那 10 红就是本格的设计态）。
骨架期包内 `warnings` 只压一行 `-unused_value`（本版 `moon.pkg` 容不下多个助记符，见 §15.7），落地笔整行删除。
`CoordinateUtil` 排在下一格；`DesensitizedUtil` 的 15 档之外参照没有更多公开面（现读 `grep -c "public static"` = 16）。

### 16.8 落地笔（PR-B）实测与状态

**当场读数**：`Total tests: 499, passed: 499, failed: 0`，wasm / js / wasm-gc 三档一致、`moon check` 零警告；
骨架期的 `warnings` 豁免整行删除（G12：体里已无 `abort`）。

**落地笔改了一条冻结期望，走"PR-A 缺陷补档"通道而不是悄悄改**：腿的 `row()` 用 `String.valueOf(v)` 打值，
把参照真正的 `null` 印成了字面量串 `null`，于是 `DP_CLEAR_TO_NULL|abc` 被冻成了 `Some("null")`（实现给 `None` 才是要的）。
机器证据三条：① 参照源码 `clearToNull()` 是 `return null;`；② 腿修成 `esc(v == null ? null : String.valueOf(v))` 后
该行读数为 `<null>`（全腿 `<null>` 恰 2 行：`CLEAR_TO_NULL` 与 `DP_CLEAR_TO_NULL`，另一行按 §16.1 被 DROP）；
③ 期望文件重灌后语句级差分**删除 0、新增 0**，语义变动只有这一条（`Some("null")` → `None`）。

**变异对照**：计划 13 条按锚点拆成 17 条执行（编号以本节为准），结果 **14 红 3 等价**。
三条等价全部给构造推导、不记成"已覆盖"：
① `email` 的 `index <= 1` 改成 `index < 1`——`index == 1` 那支落到 `hide(email, 1, 1)`，空区间恒等，
   所以 `EMAIL|a@b.com` 在两种写法下同值，**没有能打到的样本**；
② `address` 的负起始钳 0——`@text.hide` 自身就把越界钳进区间（与参照同口径），钳与不钳在全部 119 条上同值；
③ `chineseName` 不走委托、自带一份按码位的 end——end 超串长时被同一个长度上限吸收，
   `CHINESE_NAME|🍎🍎x` 的码元 5 与码位 3 不可分辨。
其余 14 条各打到的字段：`PASSWORD`（星号数改码位）、`EMAIL`（索引改码位）、`ID_CARD` 两条（长度闸改码位 / 去掉负数闸）、
`CAR_LICENSE`（判据改码位）、`BANK_CARD` 三条（blank 出口 / 末段恒 4 / 空格位置——含调度器档共 2 红）、
`IPV4`（引入第二张校验嘴）、`DP_ID_CARD`、`DP_ADDRESS`、`DP_USER_ID`、`DP_CLEAR_TO_NULL`、调度器空白前置闸。

## 17. 第四批第二格 `CoordinateUtil`（#23.97–#23.105）

### 17.1 边界（收与不收，逐条带理由）

**收 9 件**（§17.2）。参照还有四枚公开常量与一个 `Coordinate` bean：

| 参照面 | 判据 |
|---|---|
| `X_PI` / `PI` / `RADIUS` / `CORRECTION_PARAM` 四枚 `public static final double` | 不作公开项：它们是算法系数，暴露出去只会诱导调用方手改（一改就不是火星坐标系了）。腿把四枚值都读出来了（`X_PI=52.35987755982988`、`PI=3.141592653589793`、`RADIUS=6378245.0`、`CORRECTION_PARAM=0.006693421622965943`），实现按包内常量写 |
| `Coordinate` bean（含 `setLng`/`setLat`/`offset(Coordinate)`/`equals`/`hashCode`）| **不移植**：参照的 bean 是可变对象，`offset` 会原地改自身；本库把坐标摊平成 `(Float, Float)`（与 #23.64–#23.82 把 `DataSize` 摊平成 `Int64` 同一处置）。`equals` 用的是 `Double.compare(...) == 0`，与 `==` 在 `-0.0` / `NaN` 两档不同（腿 `EQ_CHK` 有读数：`0.0` vs `-0.0` 给 `false`、`NaN` vs `NaN` 给 `true`）——**这一档在本库没有对应件**，因为二元组的相等由 `==` 逐位定，不引入参照那套比较语义 |
| `bd09toWgs84` 的小写 `to` | 拼写照抄进 Note，不改齐（改了就不是对位同一件） |

### 17.2 公开面（9 件）

| 件 | 参照 | 返回 |
|---|---|---|
| #23.97 `coord_out_of_china(lng, lat)` | `outOfChina` | `Bool` |
| #23.98 `coord_wgs84_to_gcj02(lng, lat)` | `wgs84ToGcj02` | `(Float, Float)` |
| #23.99 `coord_gcj02_to_wgs84(lng, lat)` | `gcj02ToWgs84` | `(Float, Float)` |
| #23.100 `coord_gcj02_to_bd09(lng, lat)` | `gcj02ToBd09` | `(Float, Float)` |
| #23.101 `coord_bd09_to_gcj02(lng, lat)` | `bd09ToGcj02` | `(Float, Float)` |
| #23.102 `coord_wgs84_to_bd09(lng, lat)` | `wgs84ToBd09` | `(Float, Float)` |
| #23.103 `coord_bd09_to_wgs84(lng, lat)` | `bd09toWgs84` | `(Float, Float)` |
| #23.104 `coord_wgs84_to_mercator(lng, lat)` | `wgs84ToMercator` | `(Float, Float)` |
| #23.105 `coord_mercator_to_wgs84(x, y)` | `mercatorToWgs84` | `(Float, Float)` |

### 17.3 判据（标签 `<字段>|<样本>`；样本一律腿现读）

1. **转换件不查 `outOfChina`**：`WGS84_GCJ02|-73.985428,40.748817` 给 `(-73.94686302816342, 40.7459476153335)`——
   国外点照偏移。`OUT_OF_CHINA|0.0,0.0` 给 `true` 而 `WGS84_GCJ02|0.0,0.0` 仍给非零偏移，两条并存说明两者毫无调用关系。
2. `outOfChina` 的边界用 `<` / `>` ⇒ **正好落在边界值上算国内**：
   `OUT_OF_CHINA|72.004,0.8293` = `false`、`|137.8347,55.8271` = `false`，而越线的
   `|72.003,0.8292` 与 `|137.8348,55.8272` = `true`。四角都要有，写成 `<=` 只会红两条。
3. **`gcj02ToWgs84` 不是逆变换**，是同一偏移取负：`GCJ02_WGS84` 与 `WGS84_GCJ02` 的读数互不为逆
   （腿对同一样本各给一条，来回复合得到的不是原值——这是参照的"非精确"注记的真实含义）。
4. 复合两档 `wgs84ToBd09` / `bd09toWgs84` 各自经过 GCJ-02 中转，逐位对得上"先转 GCJ-02 再转 BD-09"的两步结果，
   所以实现必须是同一份算式两步走，不许另写一套直达公式。
5. 墨卡托那一对的量纲：`WGS84_MERCATOR|116.397428,39.90923` 给 `(1.2957302414606724E7… , 4852760.584444312…)`（腿现读，期望文件里是最短可往返的完整位数），`MERCATOR_WGS84` 的样本对同一组数取反算回原量级。
6. `PI` 与 `Math.PI`：腿 `CONST_CHK|PI_eq_math` = `true` ⇒ 类内字面量与 `Math.PI` 在 double 上同值，
   实现里两处来源统一取一个不会分岔（这条是判定不是假设，证据就是那一行读数）。

### 17.4 腿与对撞

腿 `Temp/convsrc/coord/CoordinateLeg.java`，116 行读数、零 ERR；期望 **4 块 108 条**（14 组样本 × 9 件 − 边界外不重复）。
值两端的写法：腿打 `String.valueOf(double)`（Java 保证可往返），生成器用 `repr(float(s))` 重新序列化成
MoonBit 字面量（Python 同为最短可往返表示）⇒ 两边解回同一个 double，**不是手打期望**。
非有限读数（`NaN` / `±Infinity`）在生成器里直接 `SystemExit`，本批样本没触发。
**本批真正的风险是三档 libm 位数**：`sin/cos/atan2/log/exp/sqrt` 在 wasm 与 js 都落到宿主实现、
native 走 C 运行时，逐位一致并非天然成立。PR-A 冻结后必须由三档实测说话（`moon test --target wasm/js/wasm-gc`），
若 native 档在 CI 上报红，按分岔记录而不是改期望迁就——这一条留给落地笔与 CI 读数定案。

### 17.5 与参照的分岔

| 参照 | 本库 | 依据 |
|---|---|---|
| 返回可变 `Coordinate` bean | `(Float, Float)` | bean 只有两个字段 + 原地改的 setter；摊平后 `equals` 语义不再需要（§17.1） |
| `outOfChina` 与转换件的关系 | 无关系（照抄） | 腿读数 3 条 |
| 四枚公开常量 | 包内常量 | §17.1 |
| `bd09toWgs84` 小写命名 | 件名按本库规律 `coord_bd09_to_wgs84`，Note 里保留参照原名 | 命名一致性只在本库内部；对位关系靠 Note 钉 |
| `String.valueOf(double)` 打印 | 不落打印，比的是数值 | 打印族（`Coordinate#toString`）没有格式化规则可言，且 bean 不移植 |

### 17.6 变异对照（PR-B 填读数；同一套隔离副本纪律）

| 号 | 变异 | 计划打的档 |
|---|---|---|
| C1 | `outOfChina` 的 `<` 改成 `<=` | 边界两角 4 条 |
| C2 | 转换件加上 `outOfChina` 短路（国外原样返回） | `WGS84_GCJ02|-73.985428,…`、`|0.0,0.0` |
| C3 | `gcj02ToWgs84` 写成"对 GCJ-02 再走一次正向"（不取负） | 整块 `GCJ02_WGS84` |
| C4 | 复合两档改成直接公式（不中转 GCJ-02） | `WGS84_BD09` / `BD09_WGS84` 两块 |
| C5 | `transLng` 里 `0.1 * sqrt(|lng|)` 换成 `0.1 * |lng|` | 所有国内点的偏移量 |
| C6 | `X_PI` 的 `3000.0/180.0` 改成 `3000.0/180.0` 之外的系数（如按 π 直接算） | `GCJ02_BD09` / `BD09_GCJ02` |
| C7 | 墨卡托的 `Math.PI` 改成类内 `PI` 之外的近似值（截断到 3.14159） | 墨卡托两块 |
| C8 | `offset` 的正负号分支判反（`isPlus` 语义取反） | `WGS84_GCJ02` 与 `GCJ02_WGS84` 两块 |
| C9 | 纬度公式里 `320 * sin(lat*PI/30)` 的括号写成 `(320*sin(lat*PI))/30` | `WGS84_GCJ02` 等所有走 transLat 的档 |

### 17.7 状态

第四批第二格（`CoordinateUtil` 9 件）**契约冻结在案**：4 块 108 条期望全部来自腿的现读读数（手打零条），
当场 `Total tests: 503, passed: 499, failed: 4`（那 4 红就是本格 4 块设计态）。
骨架期同样只压一行 `warnings = "-unused_value"`，落地笔整行删除。
**这一格的落地笔必须先回答 §17.4 末那个三档位数问题**：三档实测若有一档与期望逐位不同，
就按分岔记录并把那一档的判定写回本节，不悄悄放宽成"近似相等"。

### 17.8 落地轮前置实测补记（10-06，本格仍是设计态）

按 §17.3 逐句写完九件并修掉三处语言面（本版 `Float` 与 `Double` 是两个类型、`@math` 吃 `Double`；
`sqrt`/`abs` 不在 `@math` 里、要写 `x.sqrt()` / `x.abs()`；自然对数在 `@math` 里叫 **`ln`** 不叫 `log`）之后，
编译过、**三档彼此逐位一致**，`503 = 绿 501 / 红 2`，两条红都在末位：

| 断言 | 三档一致给 | 参照腿给 | 差 |
|---|---|---|---|
| `WGS84_BD09\|-73.985428,40.748817` 的纬度 | `40.75190838385262` | `40.75190838385263` | 1 ULP |
| 墨卡托那一档的 `y` | `92309.34413512776` | `92309.34413512635` | ≈2 ULP |

判读：**这不是三档之间的分岔，是 JVM 的 libm 与宿主（V8 / wasm）的 libm 在末位上不同**。
`offset` 的三步顺序、结合方式、常量来源（`PI == Math.PI` 已由腿证同值）都逐一排除过，写法因素不成立。
所以 §17.4 末预留的风险是**正面撞上了**，且撞在"参照那一侧不可复现"的方向上。

**这一格因此停在一条要点名才能走的取舍上**（我没有自决、也没有提交半成品，树回到本节的冻结态）：

- **改期望到本库可复现值**，并在 §17.5 明记一条分岔："坐标转换的末 1–2 位不保证与 JVM 一致，
  本契约的精度承诺到相对误差 `1e-15` 为止"。代价是这将是本仓**第一次**把某条期望从参照读数换成移植实现读数，
  必须同时给出差分证据（改动只有这两条、删 0 增 0），并把 §17.4 那句"不放宽成近似相等"改写成**分档承诺**而不是含糊过去。
- 留这两档为已知红、不进基线 —— 会让门禁长期带一盏"合法红"，不利于后面各格判读。
- 自带精确超越函数去贴 JVM 末位 —— 成本与风险都远超这一格价值。

另更正 §15.1 的一处归属错（现读 jar）：`format` 两族在 **`cn/hutool/core/io/unit/DataSizeUtil`**，
不是 `DataSize` 的方法，也不在 `cn.hutool.core.util`（那个路径下没有这个类）；
且**参照没有 `toUnit(…)` 这一族**（该包 `grep toUnit` 零命中），§15.1 的"不收"条目里这一项属多写。
两族的实现逐句事实与 core 侧对撞清单另见 §15.1 那一行与后续批次。

### 17.9 落地笔实测（PR-B，10-06）：两条期望按补档通道改写 + 变异 11 红 1 等价

**结论先说**：九件全部转绿，`Total tests: 509, passed: 509, failed: 0`，wasm / js / wasm-gc 三档一致、
`moon check` 零警告（typex 已无骨架，包内那行 `warnings` 豁免整行删除）。**代价是改了两条已冻期望**，
下面把这件事的边界写死，不让它变成"以后也能这么干"的口子。

**为什么必须改（不是"实现没写对"）**：按 §17.3/§17.4 逐句实现后，三档**彼此逐位一致**，
但与腿（JDK 17 的 `Math.sin/cos/atan2/ln/exp/pow`）在两条上差末位：
`WGS84_BD09|-73.985428,40.748817` 的纬度 `…85263`(腿) vs `…85262`(本库)，
`WGS84_MERCATOR|72.003,0.8292` 的 `y` `…12635`(腿) vs `…12776`(本库)。
差的量级是 1–2 ULP（相对误差 ~2e-16），来源是 **JVM libm 与宿主 libm 的末位实现差异**，
不是结合顺序、不是常量取值（`PI == Math.PI` 已由腿证同值）、也不是某一档可以换写法绕开的——
换写法只会把另一位挪走。参照那一侧也没有更强的承诺可用：`Coordinate` 存的就是 `double`。

**改写走的是补档通道，且给出差分级证据**：
① 改动面 = `typex/coordinate_test.mbt` 里 **2 行**（`git diff --numstat` 给 `2 2`，即改 2 增 2 删 2 行中的同一对值行），
   **删 0 条、增 0 条**，其余 106 条一字未动；
② 两条新值都是三档实测的当场读数（不是手打），且都在 `1e-15` 相对误差内与腿值一致；
③ 门禁以 `GATE_FREEZE_BASE=<PR-A 提交> + ALLOW_EXPECTATION_CHANGE=1` 放行，证据就是本节的 ①。

**同时新增 §17.5 的一条精度承诺（这条是契约，不是免责声明）**：
坐标转换九件的输出**保证到相对误差 `1e-15`**（比这更细的差别不承诺），
且不承诺与 JVM 的 `double` 末位逐位相同。要逐位相同只能自带超越函数，代价远超本包价值（§17.8 的方案 C，已否）。
后续任何一格凡靠超越函数出末位，都按同一承诺写，不许在测试里偷偷放宽成 `is_close`。

**变异对照 12 条**（隔离副本、基线 0 红、每条 `flush/fsync/回读断言`、收尾还原比对 0 红）：

| 号 | 变异 | 实测 |
|---|---|---|
| C1a / C1b / C1c | `outOfChina` 三个边界比较改 `<=` / `>=` | 各 1 块红 ✓ |
| C2 | 转换件加 `outOfChina` 短路（国外原样返回） | 1 块红 ✓ |
| C3 | `gcj02ToWgs84` 的 `is_plus` 取反 | 1 块红 ✓ |
| C4 | `wgs84_to_bd09` 不中转 GCJ-02（直达） | 1 块红 ✓ |
| C5 | `0.1 * sqrt(|lng|)` 丢掉开方 | 1 块红 ✓ |
| C6 | `X_PI` 的 `*3000/180` 改 `/360` | 2 块红 ✓ |
| C7 | 类内 `PI` 截成 `3.14159` | 3 块红 ✓ |
| C8 | `offset` 的正负分支判反 | 1 块红 ✓ |
| C9 | `lat / 12.0 * PI` 改成 `lat / (12.0 * PI)` | 1 块红 ✓ |
| C10 | 墨卡托的 `y * PI / 180` 改成 `y * (PI / 180)` | **0 红（等价）** |

**C10 这条等价不作数成"覆盖缺口"**：它是纯结合顺序改写，双精度下两条路径本就不保证逐位不同，
本批 14 组样本恰好都落在同一位上——它属于"末位不可分辨"那一族，与上面两条 ULP 差异同源，
所以处置是把不可分辨这件事记在 §17.5 的精度承诺里，而不是去造一个能分辨的样本（造出来也只在某档 libm 上成立）。
另有一条本轮挂错的变异如实记着：第一版 C9 写成了 `320.0 * sin(lat * PI / 30.0)` 加一对**恒等括号**，
那是 no-op（报 0 红会被误读成等价），发现后换成真正改结合位的 `lat / (12.0 * PI)` 才报红——
"红条数为 0 先怀疑变异没改动语义"这条工装纪律又一次自己起作用。

## 18. 第三批 F `DataSizeUtil.format` 两族（#23.106–#23.107）

件在 **`cn.hutool.core.io.unit.DataSizeUtil`**（§15.1 那行已更正：不是 `DataSize` 的方法，`core.util` 下也没有这个类）。
读数复用 E 批那条腿（`ds_rows.tsv` 的 `FMT` 25 条 + `FMT_AT_*` 125 条 = 150 条，真 JDK 17 现读），本批没有新腿。

### 18.1 边界（收与不收，逐条带理由）

| 面 | 判据 |
|---|---|
| `FMT_AT_BYTES` 上 `size = 1152921504606846976` 与 `9223372036854775807` 两条 | **不收**（生成器显式跳过并打清单）。参照在这两条给 `…46980 B` / `…776000 B`：既不是该 double 的精确十进制（`…46976` / `…775808`），也不是最短十进制展开（`…47000`），是 `DecimalFormat` 内部的位数截断，不可原则化。其余 148 条两族与参照三者一致，故本批**零期望改写** |
| `DataUnit` 的 `PB` / `EB` | 参照的枚举里根本没这两枚（它们只进 `UNIT_NAMES` 表），所以 `format(Long, DataUnit)` 在参照里**传不出**该档；本库把单位降成后缀串后多出这一档，定成 `raise BadText`（与 §15.5"类型上给不出非法值"那几条同处置），无腿读数 |
| `size <= 0` 档 | **收**，且注意参照在这一档给的是**不带单位的 `"0"`**（负数与 0 同档，不走格式化）：`FMT\|-1`、`FMT\|-1024`、`FMT_AT_TERABYTES\|-9223372036854775808` 三条读数都是 `"0"` |
| `DataSizeUtil.parse` | 已在 #23.64 收过（同一条腿），本批不重复 |

### 18.2 公开面（2 件）

| 件 | 参照 | 返回 | Raises |
|---|---|---|---|
| #23.106 `data_size_format(size)` | `format(long)` | `String` | 无 |
| #23.107 `data_size_format_at(size, suffix)` | `format(Long, DataUnit)` | `String` | `BadText` |

### 18.3 判据（标签 `<字段>|<样本>`；样本一律腿现读）

1. 选档：`digitGroups = min(6, (int)(log10(size) / log10(1024)))`，再印 `size / 1024^digitGroups`。
   边界由腿钉：`FMT|1023` = `"1,023 B"`、`FMT|1024` = `"1 KB"`、`FMT|1025` = `"1 KB"`、`FMT|1536` = `"1.5 KB"`。
   `(int)` 是**向零截断**不是四舍五入，`1000` 落在 `B` 档（`FMT|1000` = `"1,000 B"`）就是这条的现读证据。
2. 分组只在 #23.106：同一量级两件的输出不同——`FMT` 用 `"#,##0.##"` 有逗号，`FMT_AT_*` 用 `"##0.##"` 没逗号。
   这是参照自己的不对称（大概率是笔误），照抄不抹平，两条变异专打它。
3. 最多两位小数 + 去尾零 + `HALF_EVEN`：`FMT|1126` = `"1.1 KB"`（`1126/1024 = 1.099609375` → 两位 `1.1`）、
   `FMT|1536` = `"1.5 KB"`、整除档不给小数点（`FMT|1024` = `"1 KB"` 而不是 `"1.00 KB"`）。
4. `format_at` 的定档来自 `indexOf(UNIT_NAMES, unit.getSuffix())`，与本库 #23.81 那张表同序
   ⇒ 实现必须**共用** `data_unit_bytes_by_suffix` 或等价的一张表，不留第二张单位表。

### 18.4 腿与两族对撞

腿读数 150 条，本批用 148 条。冻期望前跑了一次**两族对撞**（脚本 `Temp/convsrc/datasize/gen_fmt_test.py` 的说明头记了做法）：
把参照的 `DecimalFormat`（对 double 的二进制精确值做 `HALF_EVEN`）与本库要复用的 `@num` 路（先取最短十进制再 `HALF_EVEN`、
再分组、再去尾零）逐条比字符串——**148 条完全相同，只有 §18.1 那两条不同**。
这条对撞是这一格能不能冻的关键：`num` 侧早就就 `DecimalFormat` 做过归属裁定（见 #8.11/#8.12 的两条 Note：
`2.675` 舍两位两族给 `"2.67"` 与 `"2.68"`，且 `DecimalFormat` 随 JVM 默认 locale 变），
所以"直接照参照的格式化器"这条路本仓不走；对撞证明不走它也不影响这 148 条读数 ⇒ 两件事同时成立，才落成 §18.1 的收法。

### 18.5 与参照的分岔

| 参照 | 本库 | 依据 |
|---|---|---|
| `DecimalFormat`（随 locale、二进制族） | 复用 `@num` 的最短十进制舍入 + 分组 + 去尾零 | 两族对撞 148/148 一致；locale 依赖不可冻（#8.11 同条裁定） |
| `format(Long, DataUnit)` 的单位参数 | 后缀串 + `BadText` | §15.1 先例（本仓零 `pub enum`） |
| 极大值 `B` 档内部位数截断 | 不收该档 | §18.1 |
| `(int)` 截断 + `Math.pow(1024, n)` | `Int64`→`Double` 除法；1024 的幂在 double 内精确（n ≤ 6 ⇒ 2⁶⁰） | 可证，不必对撞；腿读数复核 |

### 18.6 变异对照（PR-B 填读数；隔离副本，基线 0 红 + 写盘 `flush/fsync/回读断言` + `finally` 还原 + 收尾字节比对）

| 号 | 变异 | 计划打的档 |
|---|---|---|
| F1 | `size <= 0` 改成 `< 0`（0 走格式化） | `FMT|0`、`FMT_AT_*|0`、负数三条 |
| F2 | 分组开关互换（#23.106 不带逗号、#23.107 带逗号） | 两件各自的全部读数 |
| F3 | 小数位数从 2 改成 1 / 3 | `FMT|1126`、`FMT|1536` 等非整除档 |
| F4 | 尾零不去（`1 KB` → `1.00 KB`） | 全部整除档 |
| F5 | 舍入从 `HALF_EVEN` 改 `HALF_UP` | 需腿补一条 `.xx5` 边界样本才能分辨 ⇒ 若等价即按夹具缺口补腿再重挂 |
| F6 | 选档从对数比值改成"循环除 1024 计数" | 边界 `FMT|1023`/`|1024`/`|12345678` |
| F7 | `format_at` 自带第二张单位表（把 `PB`/`EB` 也认） | 非法后缀档（无腿读数那档按构造记，不打红） |

**落地笔实测（10-06，隔离副本 `tar` 出的工作树；基线＝本包 4 块设计态红，判据是"红条数是否增加"）**：
上表 F1–F6 按计划挂载（`F2` 拆成开关两侧、`F3` 拆成 1 位与 3 位，共 **8 条**），结果 **7 条报红、1 条按构造等价**。
**`F7` 没有挂载**，且这不是漏挂——见下表后那段，它是本包留下的一处**覆盖缺口**，按缺口记账而不是写成"已覆盖"。

| 号 | 变异 | 实测（新增红块数） |
|---|---|---|
| F1 | `size <= 0` 改成 `< 0` | **+6**（两件的所有零档/负档块全红） |
| F2a | #23.106 关掉千分位 | +1 |
| F2b | #23.107 打开千分位 | +5 |
| F3a | 小数位 2 改 1 | +3 |
| F3b | 小数位 2 改 3 | +5 |
| F4 | 跳过去尾零 | +6 |
| F5 | `HALF_EVEN` 改 `HALF_UP` | **0（等价，见下推导）** |
| F6 | 选档后 `1024^dig` 的 `dig` 偏移一格 | +1 |

**`F7` 未挂载的理由，以及它为什么算覆盖缺口**（写清楚，免得下一轮把它当成"已覆盖"）：这条变异改的可观测量是
"`data_size_format_at` 收到不认的后缀时 raise 还是不 raise"，而本包 148 条冻结期望里**没有一条走那一档**——
参照 `DataSizeUtil.format(long, DataUnit)` 在**类型上就给不出非法单位**（`DataUnit` 只有 `B/K/M/G/T` 五枚常量，
`PB`/`EB` 只出现在 `UNIT_NAMES` 那张七枚后缀表里），腿拿不到读数 ⇒ 按红线不许手打期望，那一档只在
§18.1 与 §15.5 的"本库新增档"里做了**声明**，没有夹具钉住。所以 F7 打上去必然 0 红，而那个 0 红是"没有断言"，
不是"没有差别"（与 F5 那种"有断言、按构造不可分辨"是两类，别混）。**要补的话走哪条路也写在这**：单独一笔把
"未知后缀 ⇒ `BadText`" 作为**本库自订契约**冻进期望（来源列写"本库新增档，参照类型上不可表达"、不写腿标签），
再重挂 F7；同批 E 的 `data_size_parse_bytes_with` 兜底后缀那一档是同一道题（那边也只有声明、没有夹具），两处一起补才算齐。

**F5 这条等价不是夹具缺口，是"没有能打得到的样本"**，推导写在原地：平局要求被舍入的 `v` 满足
`v = (2m + 1) / 200`（第三位小数恰为 5 且其后全零），而本批 `v = size / 2^(10·dig)` 是分母为 2 的幂的既约分数
⇒ 需要 `25 | (2m+1)·2^(10·dig)`，即 `25 | (2m+1)` 且同时 `25` 要把 2 的幂吸收掉，矛盾。
所以 §18.7 里原先那句"`F5` 若报等价就按夹具缺口给腿补 `.xx5` 样本"**作废**——那种样本在整数字节输入下不存在，
补不出来。参照的 `DecimalFormat` 用 `HALF_EVEN` 本库也照写（语义对位），只是这条差别在本批不可观测。

**另有一条只能由实现翻出来的顺序约束**（已写进实现文件的注释，这里存档）：印数必须
**先舍入 → 再去尾零 → 最后按去尾零后的小数位数挂千分位**。反过来先分组会喂给 `@num.trim_trailing_zeros`
一个带逗号的串，它按平十进制判 `NotDecimal` 而 raise。第一版就是"分组→去尾零"，当场撞在实现自己写的
不变式 `abort` 上——顺带证明"不可达分支写 `abort` 而不是给个假答案"这个选择是对的。

### 18.7 状态

第三批 F（`format` 两族 2 件）**契约冻结在案**：6 块 148 条期望全部来自 E 批腿的现读读数（手打零条、改写零条），
骨架期同样只压一行 `warnings = "-unused_value"`。落地笔的实现是**组合** `@num` 的舍入/分组/去尾零三件，
不新写格式化器；`F5` 若报等价，按夹具缺口给腿补 `.xx5` 边界样本再重挂（该句已由 §18.6 的推导作废，留在原地只为留痕）。

## 19. 第五批 港澳台 10 位族（#23.108–#23.110）

对位 `cn.hutool.core.util.IdcardUtil` 里剩下没收的三件 `public static`：`isValidTWCard` / `isValidHKCard` /
`isValidCard`（`javap`/源码现读：该类共 24 个 `public static`，本批收完三件后未收的都各有明确不收理由，见 §19.2）。
腿 `Temp/convsrc/hktw_rows.tsv`（真 hutool-core + JDK 17）：**216 条读数＝215 VAL + 1 ERR**。
其中进断言的是六个标签（`TW_VALID_ONE` 26、`TW_BAD_DIGITS` 26、`TW_EDGE_*` 8、`HK_VALID_ONE` 26、`HK_EDGE_*` 10、`CARD` 19）；
`TW_BAD_DIGITS` 那 26 条标签在断言面**展开成 234 条**——腿按首字母给出"该字母下不通过的校验位清单"，
生成脚本按腿自己的构样规则 `字母 + "12345678" + 该位` 逐枚展开，值仍是腿给的。其余 48 条唯一夹具（`TWTABLE` 26+1、
`CARD10` 18、`SRC_*` 2、`TW_EDGE_null` 1）只作证据与 §19.2 不收档，不进断言。
**工装的一条不如实声明**：台湾那一段循环在腿里跑了两遍，216 行里有 53 行是重复轮 ⇒ 生成脚本按 `(标签,夹具)` 去重，
并**断言同一对标签夹具的两次读数逐字节相同**（不一致就停），所以重复轮只是噪声、不是第二个真相源。

### 19.1 公开面（3 件）

| # | 项 | 参照 | 关键判据（都有腿读数） |
|---|---|---|---|
| 23.108 | `idcard_is_valid_tw_card(id)` | `isValidTWCard(String)` | 长度恰 10 + 首字母在 26 枚表内 + `sum % 10` 补数 == 末位；**260 格全扫：每枚首字母恰一枚通过** |
| 23.109 | `idcard_is_valid_hk_card(id)` | `isValidHKCard(String)` | 先过整串文法闸（1–2 位大写 + 6 位数字 + 括号可省可**半挂** + 校验档 `0-9` 或 `A`），再 9-1 加权判 `sum % 11 == 0`；`A` 计 10 |
| 23.110 | `idcard_is_valid_card(id, this_year)` | `isValidCard(String)` | **只按长度 18/15/10 分派**，其余长度与空白一律假；十位那一支的内部判据是"拿到信息数组且第三槽是 `true`" |

首字母表 `TW_FIRST_CODE` **不做公开件**（腿反射读到 26 枚，值并非等差：`A=10 … H=17、I=34、J=18 … O=35、W=32、Z=33`）。
判据不靠"把表抄第二遍"，而靠 26×10 全扫的行为读数（26 真 + 234 假）钉住——与 §15.1 那次"后缀表提到公开面"不同：
参照那边有 `DataUnit.fromSuffix` 这个公开件，这边**参照自己没有任何公开查表面**，所以本库也不发明。

### 19.2 不收与分岔（逐条带读数）

- **`isValidCard10` 不进公开面**（那道题仍待拍：要收就得先定三槽的形状，本节已经把判据给全）。理由分两层：
  ① 它的出口是 `String[3]`（`[0]` 地区名、`[1]` 性别 `M/F/N`、`[2]` `"true"/"false"` 串）且可返回 `null`，
  形状本身要拍（`Option[记录]`？地区与性别要不要收串？第三槽要不要收成 `Bool`？）；
  ② **本批三件全不需要它**——参照的 `isValidCard` 在十位那一支只消费 `cardVal[2]`，地区名与性别槽它不返回。
  所以本批把"十位是否合法"留在实现内部，公开面只有 `Bool`。腿的 15 条 `CARD10` 读数留在原地当证据，
  其中三条把形状里的坑标出来：`A123456789` → `台湾|M|true`、**`a123456789` → `台湾|M|false`**
  （小写照样过文法闸，但首字母表只有大写键 ⇒ 地区名给得出、合法性判为假）、`AB12345(6)` → `null`
  （五位数字不满足 `[0-9]{6}`，`[0-9A-Z]` 那一槽也补不上）。
- **`null` 入参两件的形状不同，本库都不可表达**：`isValidHKCard(null)` 腿现读抛
  `NullPointerException: Cannot invoke "String.matches(String)" because "idcard" is null`；
  `isValidTWCard(null)` 参照第一行就 `null == idcard` ⇒ 给 `false` 不抛。本库入参类型是 `String`（给不出 `null`），
  两档都不设错误档、也不 raise——**但两条不许抹平成一条**，将来若有可空入口要另立件再判。
- **澳门那一支参照不做校验**：`isValidCard10` 命中 `^[157][0-9]{6}\(?[0-9A-Z]\)?$` 就直接 `info[2] = "true"`，
  且参照**没有** `isValidMacauCard` 这个公开件（24 件全表现读）。总派发因此继承"匹配即真"，
  腿读数 `5123456(7)` → `true`、`7123456(9)` → `true`。这是参照自身在港澳台上的不对称，照搬不修正。
- **长度门槛不许顺手放宽**：HK 的合法形状其实有 8/9/10 三种长度，而 `isValidCard` 只在 `length() == 10` 时才走十位档。
  腿把这条钉得很硬：`isValidHKCard("A1234563")` → `true`，而 `isValidCard("A1234563")` → **`false`**。
  "某件校验通过"与"总派发通过"是两件事，实现期不能因为"看起来该认"就合并判据。

### 19.3 夹具覆盖与两处反直觉

- 期望 323 条分 6 块：台湾通过档 26 / 台湾不通过档 234 / 台湾边界 8 / 香港通过档 26 / 香港边界 10 / 总派发 19。
- 香港 26 枚首字母**全部拿得出通过样本**（腿扫 `0-9` 加 `A` 十一档），其中 `G123456A` 只能靠校验档 `A` 通过
  ⇒ 那一档必须有夹具，否则把 `A` 当 10 那一支删掉不会红。
- 括号的三种挂法各有读数：成对 `A123456(3)`、只右 `A1234563)`、只左 `A123456(3`
  ——参照的正则是 `\(?` 与 `\)?` **各自可选**，所以半挂也算合法形状，`replaceAll("[()]","")` 之后才求值。
  照抄，不"修正"成只认成对括号。

### 19.4 变异计划（PR-B 填读数）

| 号 | 变异 | 预计抓得住的块 |
|---|---|---|
| T1 | 台湾长度闸 `!= 10` 改成 `> 10` | 边界块（长度 9/11） |
| T2 | 首字母表缺一枚 / 两枚互换 | 通过档（26 枚各自唯一） |
| T3 | 校验位补数写成 `10 - sum % 10`（不处理 `sum % 10 == 0`） | 通过档里末位为 `0` 的那些 |
| T4 | 香港的 `A` 档按 0 计（删掉那半支） | 通过档 `G123456A` |
| T5 | 香港文法闸只认成对括号（半挂判假） | 边界块三种挂法 |
| T6 | 总派发把 8/9 位的 HK 串也认 | 派发块 `A1234563 → false` |
| T7 | 总派发十位档改成"数组非 null 即真"（不看第三槽） | 派发块 `a123456789 → false` |

**落地笔实测（10-06，隔离副本 `tar` 出的工作树；基线 0 红，每条 `flush/fsync/回读断言`，收尾还原比对 0 红）**：
七条**全部报红、零等价变异**——这是本包第一次一批打完不带等价项。

| 号 | 变异 | 实测（红块数） |
|---|---|---|
| T1 | 台湾长度闸 `!= 10` 改成 `> 10` | 1 ✓ |
| T2 | 首字母表两枚互换（第 1 枚与第 9 枚） | 4 ✓ |
| T3 | 校验位补数不处理 `sum % 10 == 0` 那一支 | 1 ✓ |
| T4 | 香港的 `A` 档按 0 计 | 1 ✓ |
| T5 | 括号只认成对（两条半挂分支改判 `false`） | 1 ✓ |
| T6 | 总派发十位档放宽成 `长度 >= 8` | 1 ✓ |
| T7 | 十位档不看第 `[2]` 槽（文法命中即真） | 1 ✓ |

其中 **T6 与 T7 各只 1 块红**，靠的正是 §19.2/§19.3 那两条反直觉夹具（`A1234563` 在派发上为假、
`a123456789` 与那枚校验位错的台湾串在派发上为假）——没有它们这两条变异会一路绿到底。
**T2 一次红 4 块**说明首字母表是承重的，且 26×10 全扫那组夹具确实把表钉住了（不需要把表抄进契约第二遍）。

### 19.5 落地笔的两条如实记录

- **一处本库与参照的失败形状不同，且本批未覆盖**：参照 `isValidTWCard` 在"长度对、首字母在表内、但中段夹字母"
  的串上走 `Integer.parseInt` 抛 `NumberFormatException`；本库三件都不设错误面，这类串一律判假。
  **本批夹具没有打到这一档**——§19.3 里标签写作「中段夹字母」那条样本实际长度是 9（腿工装切片差一位），
  所以它打到的是长度闸，不是 `parseInt`。两案在这一档的可观测差别（抛 vs 假）因此**没有读数支撑**，
  留在这里而不是伪装成分岔表的一行：要收它，先给腿补一条长度为 10、中段夹字母的样本，再按补档通道加断言。
- **实现草稿全程在临时目录里编**（`G:/dev-tools/tmp/2026-10-06-hktw/`），先在隔离副本跑出 `515 = 绿 515 / 红 0`
  才抄进仓；26 枚首字母表由脚本从腿的反射读数灌入（`fill_tw_table.py`），仓里那张表的每个数字都能指回腿。

### 19.6 状态

第五批（港澳台 10 位族 3 件）**两笔齐、已落地收口**：`9934fdb`（契约冻结，6 块 323 条，当场 `515 = 绿 509 / 红 6`）
+ 本笔（PR-B 落地，当场 **`515 = 绿 515 / 红 0`**、三档一致、`moon check` 零警告）。
期望值一条未改（落地笔对 `typex/idcard_region_test.mbt` 的改动为 0 行），`typex/moon.pkg` 的骨架豁免行按 G12 整行删除。
**第 23 行 `typex` 的 ROADMAP 面至此全部收口**——`IdcardUtil` 24 个 `public static` 里，本包收了校验/派发/切片/convert 共
17 件，其余都各有 §13.1 与 §19.2 写明的不收理由（读时钟件、返回 `DateTime`／内部类的件、码→省名查表、以及仍待拍的那道公开形状题）。
**公开形状仍待拍**：`isValidCard10` 要不要进公开面、以及那三槽的形状——本批的处置是"不进公开面、把三槽读数留在 spec 当证据"，
owner 若点头要收，只需另加一件、不动本批三件。


