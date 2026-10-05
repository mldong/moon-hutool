///|
// moon-hutool/typex —— 类型/工具补充面（ROADMAP 第 23 行）
// 对位 hutool `cn.hutool.core.lang.Version` + `cn.hutool.core.util.PageUtil`（第一批）；
// `Ipv4Util` / `DataSize` / `PhoneUtil` / `IdcardUtil` / `CreditCodeUtil` / `DesensitizedUtil` /
// `CoordinateUtil` 另立后续批（spec §1）。
// **件全在 hutool-core 一个 jar 里**（`unzip -l hutool-core.jar | grep -ciE "lang/Version|PageUtil"` 现读 2 条），本格不另拉 artifact。
// 契约真相在 `docs/spec/23-typex.md`；本文件此刻是签名骨架——函数体是 abort，落地笔（PR-B）替换。
//
// 一句话口径：Version 按参照的"逐段比较，数字段按数值、其余按字典序（大小写不敏感），段数不等时短的一侧补零/补空"，
// 本库公开 `version_of`（**不抛错**——参照也不抛，异常档见 spec §5）+ `version_compare` + `version_to_string`
// （归一化形状由腿给，含 `v`/`V` 前缀剥离与分隔符归一）；PageUtil 的 `firstPageNo` 在参照是**全局静态**，
// 本库同样给全局（`typex_first_page_no` / `typex_set_first_page_no`），因为它会跨用例互相盖住，
// spec §3 把两档读数都钉住、测试里每条用例先显式设档再断言。

///|
/// #23.1 版本号。对位 `cn.hutool.core.lang.Version implements Comparable<Version>`。
/// 参照内部把版本串切成"段数组 + 每段层级（数字 / 非数字）"，这里只留归一化后的段表。
pub struct Version {
  priv parts : Array[String]
}

///|
/// #23.2 解析版本号
/// - Returns: 结构体本身总构造得出（参照 `Version.of` 对空串、缺段、带前后空格都不抛）
/// - Raises: 无（腿对 25 个输入零异常读数；参照真抛的档见 spec §5 第 1 行）
/// - Note: hutool 对位 `static Version of(String)` / `new Version(String)`
pub fn version_of(text : String) -> Version {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.2")
}

///|
/// #23.3 归一化后的版本串（参照 `toString()` 的重建形状：段用 `.` 连，非数字段按参照的大小写归一）
/// - Raises: 无
/// - Note: hutool 对位 `String toString()`
pub fn version_to_string(v : Version) -> String {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.3")
}

///|
/// #23.4 三向比较
/// - Returns: 负数 / 0 / 正数（参照给的具体数值不作契约，只钉符号——腿读数是符号档）
/// - Raises: 无
/// - Note: hutool 对位 `int compareTo(Version)`
pub fn version_compare(a : Version, b : Version) -> Int {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.4")
}

///|
/// #23.5 相等判定（参照 `equals`：与 `compareTo` 同序则相等；腿同时给出 `hashCode` 是否同值那一档）
/// - Raises: 无
/// - Note: hutool 对位 `boolean equals(Object)`
pub fn version_equals(a : Version, b : Version) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.5")
}

///|
/// #23.6 首尾页号（参照全局静态 `firstPageNo`，默认 0）
/// - Returns: 当前档位
/// - Raises: 无
/// - Note: hutool 对位 `static int getFirstPageNo()`
pub fn typex_first_page_no() -> Int {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.6")
}

///|
/// #23.7 设首尾页号
/// - Parameters: `n` 首页号（参照 `setFirstPageNo(int)`；`setOneAsFirstPageNo()` 就是设 1）
/// - Raises: 无
/// - Note: 这是**全局可变状态**，并发或跨用例互盖 ⇒ 测试里每条用例先显式设档
pub fn typex_set_first_page_no(n : Int) -> Unit {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.7")
}

///|
/// #23.8 该页起始行号
/// - Raises: 无
/// - Note: hutool 对位 `static int getStart(int, int)`（`page` 是页号、`size` 是每页条数；负数档照参照）
pub fn page_get_start(page : Int, size : Int) -> Int {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.8")
}

///|
/// #23.9 该页结束行号
/// - Raises: 无
/// - Note: hutool 对位 `static int getEnd(int, int)`
pub fn page_get_end(page : Int, size : Int) -> Int {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.9")
}

///|
/// #23.10 起始与结束行号成对给出
/// - Raises: 无
/// - Note: hutool 对位 `static int[] transToStartEnd(int, int)`
pub fn page_trans_to_start_end(page : Int, size : Int) -> (Int, Int) {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.10")
}

///|
/// #23.11 总页数
/// - Parameters: `count` 总条数（参照另有 `long` 重载，本库合一件、参数取 `Int`——超出 int 范围的档记在 spec §5）
/// - Raises: 无
/// - Note: hutool 对位 `static int totalPage(int, int)` / `totalPage(long, int)`
pub fn page_total_page(count : Int, size : Int) -> Int {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.11")
}

///|
/// #23.12 总页数（长条数档）
/// - Raises: 无
/// - Note: hutool 对位 `static int totalPage(long, int)`——腿的 `4294967296|10` 等读数钉这一档
pub fn page_total_page_long(count : Int64, size : Int) -> Int {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.12")
}

///|
/// #23.13 页码彩虹条（默认展示 10 个）
/// - Returns: 页号数组（参照可能给 `null`——腿的 `P.*.RAINBOW` 读数里带 `<null>` 档，映射成空数组还是 raise 记在 spec §5）
/// - Raises: 无
/// - Note: hutool 对位 `static int[] rainbow(int, int)`
pub fn page_rainbow(current : Int, total : Int) -> Array[Int] {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.13")
}

///|
/// #23.14 页码彩虹条（指定展示个数）
/// - Raises: 无
/// - Note: hutool 对位 `static int[] rainbow(int, int, int)`
pub fn page_rainbow_count(
  current : Int,
  total : Int,
  show_count : Int,
) -> Array[Int] {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.14")
}
