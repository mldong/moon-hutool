///|
// moon-hutool/typex —— 身份证号面（ROADMAP 第 23 行第三批 C，#23.50–#23.54）
// 对位 hutool `cn.hutool.core.util.IdcardUtil`（GB11643-1999）：本批只收**校验两件 + convert 两件**，
// 切片族（birth/year/month/day/gender/province/city/district/hide）另立一批——它们的失败形状是
// `null` / NPE / `NumberFormatException` / `IllegalArgumentException` 四种混用，映射口径要先单独拍。
// 契约真相在 `docs/spec/23-typex.md` §13。
//
// 四条决定实现形状、且都有腿读数为凭的事实：
// - 省码表 36 枚由反射读 `CITY_CODES` 的**键集**（值是省名，本批不用）；省码闸在生日闸之前，
//   且 `startsWith("9")` 那一支取第 2~3 位当省码（新版外国人永居证），有专用夹具。
// - 校验位是 `sum(前 17 位数字 × 权重) % 11` 查 11 枚字符表 `1 0 X 9 8 7 6 5 4 3 2`，
//   与第三批 B 的 mod-31 那族**不是同一张表**。
// - 参照的生日判据含 `year > DateUtil.thisYear()`（宿主时钟）⇒ 本库把年份做成显式参数 `this_year`，
//   夹具一律传腿执行当年（2026）的读数；`is_valid_15` 不设该参数，因为 15 位的年份恒为 19xx。
// - `convert15To18` 的世纪映射闭式：**yy=00 → 2000，其余 → 1900+yy**（腿对 yy 全扫 100 条读数，
//   且该闭式与 SimpleDateFormat 随年份移动的两位年基准无关——参照那句 `if (sYear > 2000) sYear -= 100`
//   把基准年的影响整体吸收掉了）。

///|
/// #23.50 十八位身份证校验（省码闸 → 生日闸 → 前 17 位数字 → 校验位，忽略 `X` 大小写）
/// - Parameters: `this_year` 参照读的是宿主当年（`DateUtil.thisYear()`），本库做成显式参数
/// - Raises: 无（参照的 `null` 入参档在本库是类型不允许；非数字/越界档一律 `false`）
/// - Note: hutool 对位 `static boolean isValidCard18(String)`
pub fn idcard_is_valid_18(id : String, this_year : Int) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.50")
}

///|
/// #23.51 十八位身份证校验（`ignore_case` 档：`false` 时第 18 位严格匹配大写 `X`）
/// - Note: hutool 对位 `static boolean isValidCard18(String, boolean)`（5.5.7 起）；
///   `ignore_case=true` 与 #23.50 同形（本库让一件走另一件，不留两份判据）
pub fn idcard_is_valid_18_case(
  id : String,
  this_year : Int,
  ignore_case : Bool,
) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.51")
}

///|
/// #23.52 十五位身份证校验（年份恒为 19xx ⇒ 不设 `this_year`）
/// - Raises: 无
/// - Note: hutool 对位 `static boolean isValidCard15(String)`；参照内部把生日补成 `"19" + yyMMdd` 再判
pub fn idcard_is_valid_15(id : String) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.52")
}

///|
/// #23.53 十五位转十八位（世纪闭式 + 补校验位）
/// - Returns: 非 15 位或含非数字给 `None`（参照给 `null`）
/// - Raises: 无
/// - Note: hutool 对位 `static String convert15To18(String)`
pub fn idcard_convert_15_to_18(id : String) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.53")
}

///|
/// #23.54 十八位转十五位（**非法档原样返回入参**，与 #23.53 的失败形状相反）
/// - Returns: 参照是 `isNotBlank && isValidCard18` 才截，否则 `return idCard`；
///   空白串的 `isValidCard18` 必为 false ⇒ 本库不再单独判空白，两处判定等价
/// - Raises: 无
/// - Note: hutool 对位 `static String convert18To15(String)`
pub fn idcard_convert_18_to_15(id : String, this_year : Int) -> String {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.54")
}
