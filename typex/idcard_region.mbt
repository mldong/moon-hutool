///|
// moon-hutool/typex —— 港澳台 10 位身份证族（ROADMAP 第 23 行第五批，#23.108–#23.110）
// 对位 hutool `cn.hutool.core.util.IdcardUtil` 的 `isValidTWCard` / `isValidHKCard` / `isValidCard`。
// 契约真相在 `docs/spec/23-typex.md` §19。
//
// 四条决定实现形状、且都有腿读数为凭的事实：
// - 三件的出口都是 `Bool`：参照 `isValidCard` 本身就是 `boolean`，而它内部对十位那一支只问
//   `cardVal != null && "true".equals(cardVal[2])`——**地区名与性别槽它并不返回**。所以本批不需要
//   `String[]` 那种出口（`isValidCard10` 的公开与否是另一道题，见 §19.1）。
// - 台湾那一支靠一张 26 枚首字母表（`TW_FIRST_CODE`，反射读到的值并非等差：`A=10 … H=17、I=34、J=18 …`），
//   校验位是 `sum % 10` 的补数；腿把 26×10 全扫了一遍，**每枚首字母恰好一枚通过**。
// - 香港那一支的校验档不止 `0-9`，还收字符 `A`（代表 10），且**括号的三种挂法**（成对／只右／只左）
//   在参照的正则里都是合法形状——`replaceAll("[()]","")` 之后才算数（腿各有读数）。
// - `isValidCard` 只对**长度恰为 18/15/10** 的串分派：腿现读 `A1234563`（`isValidHKCard` 为真的 8 位串）
//   在 `isValidCard` 上给 **false**——"某个校验件通过"与"总派发通过"是两件事，别顺手抹平。

///|
/// #23.108 台湾十位身份证校验（首字母表 + 加权 `sum % 10` 补数）
/// - Returns: 长度恰为 10、首字母在表内、且校验位正确才给 `true`；其余一律 `false`
/// - Raises: 无（参照对 `null` 先判长度、不抛；本库入参类型上也不允许 `null`）
/// - Note: hutool 对位 `static boolean isValidTWCard(String)`
pub fn idcard_is_valid_tw_card(id : String) -> Bool {
  abort(
    "moon-hutool PR-B：契约骨架 #23.108 idcard_is_valid_tw_card 待落地，见 docs/spec/23-typex.md §19",
  )
}

///|
/// #23.109 香港十位身份证校验（整串先过文法闸，再按 9-1 加权求和判 `sum % 11 == 0`）
/// - Returns: 文法不合直接 `false`；`A` 当校验位时按 10 计入
/// - Raises: 无（参照在 `null` 上抛 `NullPointerException`，本库入参类型上给不出 `null`，见 §19.2）
/// - Note: hutool 对位 `static boolean isValidHKCard(String)`
pub fn idcard_is_valid_hk_card(id : String) -> Bool {
  abort(
    "moon-hutool PR-B：契约骨架 #23.109 idcard_is_valid_hk_card 待落地，见 docs/spec/23-typex.md §19",
  )
}

///|
/// #23.110 身份证总派发：按长度 18/15/10 分档，其余长度与空白一律 `false`
/// - Parameters: `this_year` 18 位那一支的生日上界（参照读 `DateUtil.thisYear()`，本库做成显式参数）
/// - Returns: 十位那一支只认**港澳台三种文法之一**且校验通过的串（澳门那支参照不做校验、匹配即真）
/// - Raises: 无
/// - Note: hutool 对位 `static boolean isValidCard(String)`（忽略 `X` 的大小写那一档）
pub fn idcard_is_valid_card(id : String, this_year : Int) -> Bool {
  abort(
    "moon-hutool PR-B：契约骨架 #23.110 idcard_is_valid_card 待落地，见 docs/spec/23-typex.md §19",
  )
}
