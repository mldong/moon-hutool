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

`已实现（第一批）`：14 件公开面全部落地（体里零 `abort`，G12 骨架豁免随落地笔整行删除），
6 块 **172 条**冻结期望在 **wasm / js / wasm-gc 三档全绿**（当场读数：Total tests 459，passed 459，failed 0），
`moon check` 三档零警告，`.mbti` 只多出内部段型的类型名 `type Token`（抽象呈现、不暴露 case），公开 14 件签名一字未动。
参照源码三件（`PageUtil.java` 274 行、`Version.java` 281 行、`CompareUtil.compare` + `CharUtil.isNumber` 两条委托）逐档对照后移植，
其中"首段无条件 `takeNumber`"、"`pre` 空的一侧更大"、"`getEnd` 不减 1"、"码元序且大小写敏感"四条是靠读数与源码双证钉住的，不按语义直觉实现。
native 档本机无 C 编译器（`moon test --target native` 报 `no system C compiler found`），由 CI 覆盖；
`wrap32` 那条位宽处置（§5 第 7 行）正是为 native 与 wasm 同值而设。
第二批 `Ipv4Util` 待开工（§1 分批）。
