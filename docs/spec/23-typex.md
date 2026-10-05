# 23 · typex —— `Version` 比较与 `PageUtil` 分页算式（第一批）

对位 hutool：`cn.hutool.core.lang.Version`、`cn.hutool.core.util.PageUtil`。
件都在 **hutool-core 一个 jar 里**（`unzip -l hutool-core.jar | grep -icE "lang/Version|PageUtil"` 现读 2），本格不另拉 artifact。
本文件是 PR-A 的契约草案：**§2 的公开面 + §3 的判据以参照腿读数为唯一依据**，
读数没到的档一律写"待定"，不用常识补全（同 `docs/spec/22-ini.md` §9.3 的处理）。

## 1. 边界

- **不收 IO / 反射 / 网络**：`Ipv4Util` 的 `list(...)`（IP 段展开成 `List<String>`，规模可达 2^31）与
  `NetUtil` 系（要探网卡/本机地址）不进本库；`Version` 的 `Serializable`/`hashCode` 一致性只测"同不同"这一位，
  不承诺跨进程稳定值。
- **分批**：第 23 行注里的九件按可移植性分四批——
  第一批 `Version` + `PageUtil`（本文件）；第二批 `Ipv4Util`（纯算式档：`ipv4ToLong`/`longToIpv4`/`getMask*`/`countBy*`/`isMaskValid`）；
  第三批 `DataSize`/`DataSizeUtil`、`PhoneUtil`、`IdcardUtil`（校验位 + `province_code()`）、`CreditCodeUtil`（只校验）；
  第四批 `DesensitizedUtil`（要一个脱敏类型枚举，形状先拍）、`CoordinateUtil`、`PageUtil` 的 `Segment`/迭代器面。
- 参照的 `PageUtil.setFirstPageNo(int)` 是**全局静态可变**，本库跟随（`typex_set_first_page_no`），
  代价是"跨用例互盖"——测试里每条用到它的断言都先显式设档再读，这一点在 §3 挂两档读数（0 档与 1 档）。

## 2. 公开面（第一批 14 件）

| # | 项 | 参照 |
|---|---|---|
| 23.1 | `pub struct Version`（`priv parts`） | `cn.hutool.core.lang.Version` |
| 23.2 | `version_of(text) -> Version` | `static Version of(String)` / `new Version(String)` |
| 23.3 | `version_to_string(v) -> String` | `String toString()`（归一化重建形状） |
| 23.4 | `version_compare(a, b) -> Int`（只钉符号档） | `int compareTo(Version)` |
| 23.5 | `version_equals(a, b) -> Bool` | `boolean equals(Object)`（`hashCode` 同不同只挂旁证） |
| 23.6 | `typex_first_page_no() -> Int` | `static int getFirstPageNo()` |
| 23.7 | `typex_set_first_page_no(Int) -> Unit` | `static void setFirstPageNo(int)`（`setOneAsFirstPageNo()` 即设 1） |
| 23.8 | `page_get_start(page, size) -> Int` | `static int getStart(int, int)` |
| 23.9 | `page_get_end(page, size) -> Int` | `static int getEnd(int, int)` |
| 23.10 | `page_trans_to_start_end(page, size) -> (Int, Int)` | `static int[] transToStartEnd(int, int)` |
| 23.11 | `page_total_page(count, size) -> Int` | `static int totalPage(int, int)` |
| 23.12 | `page_total_page_long(count : Int64, size) -> Int` | `static int totalPage(long, int)` |
| 23.13 | `page_rainbow(current, total) -> Array[Int]` | `static int[] rainbow(int, int)`（展示数固定 5，与参照的默认档同形） |
| 23.14 | `page_rainbow_count(current, total, show_count) -> Array[Int]` | `static int[] rainbow(int, int, int)` |

## 3. 判据（每条挂腿读数标签；标签形如 `V<i>.<档>` / `P<i>.<档>` / `G<i>.<档>`）

待本轮腿跑完后由生成脚本核对填入；本节的"待定"标记在 PR-A 收口前不许被当作契约引用。

1. 版本串的比较形状（数字段按数值、段数不等怎么补、非数字段与大小写、`-`/`_`/`.` 作分隔符是否等价）——待定，挂 `V*.cmp`。
2. `toString` 的归一化重建（`v`/`V` 前缀、前导零段、多余点号）——待定，挂 `V*.to_string`。
3. 参照对哪些输入抛错（若有）⇒ 本库 `version_of` 的 raise 面怎么定 —— 待定，挂 `V*.ctor_a|ERR`。
4. `getStart/getEnd/transToStartEnd` 在 `firstPageNo = 0` 与 `= 1` 两档、以及 `page` 为负、`size` 为 0 的读数 —— 待定，挂 `P*.start/end/pair`。
5. `totalPage` 两档重载（`int` 与 `long`）在 `count` 为 0 / 负 / 超 int 范围的读数 —— 待定，挂 `P*.total*`。
6. `rainbow` 何时给 `null`（参照可返回 `null`）⇒ 本库映射成空数组还是 raise —— 待定，挂 `P*.rainbow*`。
7. `toSegment` 返回的是 `Segment<Integer>`（迭代器形状）——**不收**（§1），腿只留一行事实读数 `P*.segment`。

## 4. 腿

- `TypexLeg.java`：真 `hutool-core-5.8.35.jar` + 本机 JDK 17.0.14，`javac -encoding UTF-8`；
  夹具全部 ASCII 直写（版本串与页码都是纯数字/字母），读数用与 `csv`/`ini` 同一套 `esc()` 打成可机械还原形状；
  输出 `typex_results.tsv`，期望值由 `gen_typex_test.py` 灌进 `typex/typex_test.mbt`（**手打零条**）。
- PageUtil 全局静态两档各跑一遍（0 与 1），两档读数都留在 `typex_results.tsv` 里，测试逐条 `typex_set_first_page_no` 后再断言。

## 5. 与参照的分岔

待 §3 的读数核对后逐条写（哪些跟随、哪些因形状不可产出而分岔，两侧读数都要在）。已定的一条：
`toSegment` / `Segment` 面不收（迭代器形状与"零依赖、可序列化"的包定位不符，分页算式一侧已由 23.8–23.12 覆盖）。

3. **（10-06 追加，PR-B 开工前必须先修的契约缺陷）#23.13 `page_rainbow`（两参档）的冻结期望串来源错档**：
   腿的 `pprobe` 里那一行实际调的是**三参** `rainbow(page, size, 5)`，而参照的两参重载是
   `rainbow(currentPage, pageCount)` = **`rainbow(current, total, 10)`**（`PageUtil.java` 现读，注释也写着"默认展示 10 页"）
   ——所以 `P*.rainbow` 那 11 条期望钉的是 displayCount=5 的行为，不是 #23.13 承诺的档；
   骨架里"`page_rainbow` 展示数固定 5"的注释同样错。修法：腿补跑两参档（`rainbow(page,size)`）→
   用新读数替换这 11 条期望并改注释，再进 PR-B；在替换前 #23.13 不算已冻结的契约，别照它实现。
   顺带记两条参照事实：`rainbow` 的 `displayCount` 为偶数时 `right++`（左右不对称）、`totalPage < displayCount` 时长度取 `totalPage`；
   `getEnd = getStart + (pageSize < 1 ? 0 : pageSize)`；`totalPage(long,int)` 用 `Math.toIntExact` ⇒ 超 int 会抛（腿未跑到那一档）。

## 6. 变异对照（PR-B 填读数）

计划：分隔符只认点号、非数字段按大小写敏感比、`totalPage` 不向上取整、`getEnd` 少 1、
`firstPageNo` 不参与 `getStart`、`rainbow` 的 `null` 档改成空数组、`show_count` 大于总页时不夹取——每条要么报红要么如实记等价/未挂载。

## 7. 状态

`契约已冻结`（PR-A：14 件签名骨架 + 6 块 152 条冻结期望值就位，腿 245 行读数 0 异常 ⇒ #23.2 `version_of` 无 raise 面已证实；`moon check` 零警告）。§3 的判据行仍要按读数逐条落文（PR-B 之前补齐），别当已完成评审引用。已由读数直接定下的两处事实：`1.2` 与 `1.2.0` **相等但参照的 `hashCode` 不同**（参照自身的 equals/hashCode 违约 ⇒ 本库不复制 hashCode，只钉 equals）；`rainbow` 在退化档给**空数组**而不是 null。

### 5.1 §5 第 3 条已收口（10-06）
腿的 `pprobe` 已改调真正的两参重载 `rainbow(page, size)`，`P*.rainbow` 那批期望随之重生成（两参档的默认展示数是 **10**），
骨架 `#23.13` 的注释同步改成"默认展示 10 个"。至此 #23.13 的期望来源与签名档位一致。
