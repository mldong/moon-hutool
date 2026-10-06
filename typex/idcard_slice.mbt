///|
// moon-hutool/typex —— 身份证号切片族（ROADMAP 第 23 行第三批 D，#23.55–#23.63）
// 对位 hutool `IdcardUtil` 的九件取数件。参照在这些件上把**五种形状混用**
// （给 `null` / `NullPointerException` / `NumberFormatException` / `IllegalArgumentException`（两种文案）/
// `DateException`），本库一律**不 raise**：取不到就给 `None`（映射表见 spec §14.4）。
// 契约真相在 `docs/spec/23-typex.md` §14。
//
// 三条决定实现形状、且都有腿读数为凭的事实：
// - 15 位入参在参照里会先走 `convert15To18`，而那件对**日期不成立**的 15 位号是抛 `DateException` 的
//   （第三批 C 的补档 §13.8）⇒ 本批走 15 位路径的四件都继承这一档，统一给 `None`。
// - 三件"编码切片"（省 / 市 / 区县）**只看长度是不是 15 或 18**，既不校验省码也不校验日期
//   ⇒ 18 位乱码串照给 `"ab"`（腿有读数），长度 20 才出局。
// - `getGenderByIdCard` 取的是 `charAt(16) % 2` —— **字符码位的奇偶**，不是数字的奇偶（腿有专用夹具钉这条）。

///|
/// #23.55 取生日段（`yyyyMMdd`）
/// - Returns: 空白、长度 <15、15 位转不出 ⇒ `None`；其余取第 7~14 位
/// - Raises: 无（参照在空白档抛 `IllegalArgumentException: id card must be not blank!`）
/// - Note: hutool 对位 `static String getBirthByIdCard(String)` 与 `static String getBirth(String)`——
///   参照那两件是同一条实现（前者直接委托后者），本库只留一件不留别名
pub fn idcard_birth(id : String) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.55")
}

///|
/// #23.56 取生日年
/// - Raises: 无
/// - Note: hutool 对位 `static Short getYearByIdCard(String)`。参照**不判空白**（空白走长度 <15 直接给 `null`），
///   所以本件也不设空白闸——两件闸集合不同是参照自己的不对称，照抄不抹平
pub fn idcard_year(id : String) -> Int? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.56")
}

///|
/// #23.57 取生日月
/// - Raises: 无
/// - Note: hutool 对位 `static Short getMonthByIdCard(String)`
pub fn idcard_month(id : String) -> Int? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.57")
}

///|
/// #23.58 取生日日
/// - Raises: 无
/// - Note: hutool 对位 `static Short getDayByIdCard(String)`
pub fn idcard_day(id : String) -> Int? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.58")
}

///|
/// #23.59 取性别（`1` 男 / `0` 女，按第 17 位）
/// - Returns: 空白、长度非 15/18、15 位转不出 ⇒ `None`（参照前两者抛异常、第三者崩在 `requireNonNull`）
/// - Raises: 无
/// - Note: hutool 对位 `static int getGenderByIdCard(String)`；判据是 `charAt(16) % 2 != 0 ⇒ 1`，
///   即**码位奇偶**而非数字奇偶——第 17 位是字母时参照照样按字符编码给值（有夹具钉）
pub fn idcard_gender(id : String) -> Int? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.59")
}

///|
/// #23.60 取户籍省份编码（前 2 位）
/// - Returns: 长度不是 15/18 给 `None`；**不校验内容**（参照同样不校验）
/// - Raises: 无
/// - Note: hutool 对位 `static String getProvinceCodeByIdCard(String)`
pub fn idcard_province_code(id : String) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.60")
}

///|
/// #23.61 取地市级编码（前 4 位）
/// - Raises: 无
/// - Note: hutool 对位 `static String getCityCodeByIdCard(String)`
pub fn idcard_city_code(id : String) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.61")
}

///|
/// #23.62 取区县级编码（前 6 位）
/// - Raises: 无
/// - Note: hutool 对位 `static String getDistrictCodeByIdCard(String)`
pub fn idcard_district_code(id : String) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.62")
}

///|
/// #23.63 掩掉指定位（掩码字符固定 `*`，**码位**口径；参照从不给 null，故出口是 `String` 不是 `String?`）
/// - Raises: 无（越界夹紧、不校验号型：与 #23.40–#23.42 同一口径）
/// - Note: hutool 对位 `static String hide(String, int, int)`，参照就是 `StrUtil.hide(·)` 的转委托 ⇒ 复用 `@text.hide`
pub fn idcard_hide(id : String, start : Int, end : Int) -> String {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.63")
}
