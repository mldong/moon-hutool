///|
// moon-hutool/typex —— 港澳台 10 位身份证的信息数组（ROADMAP 第 23 行第六批，#23.111）
// 对位 hutool `cn.hutool.core.util.IdcardUtil.isValidCard10`。契约真相在 `docs/spec/23-typex.md` §20。
//
// 三条决定实现形状、且都有腿读数为凭的事实：
// - 参照的出口是 `String[3]`（`[0]` 地区名、`[1]` 性别、`[2]` `"true"/"false"`）或 `null`。本库收成
//   `IdcardInfo10?`：**只把 `"true"/"false"` 那一槽归一成 `Bool`**（机械映射，两槽其余值原样保留），
//   `null` 走 `None`——参照那一侧的"数组里三个槽都非空"由腿现读保证（29 条读数无一例外）。
// - 地区名是参照自己拼的三个中文串（台湾/澳门/香港），性别三枚 `M`/`F`/`N`；`N` 有两种来路：
//   港澳两支恒 `N`，台湾那一支在第 2 位不是 `1`/`2` 时**早退**成 `N|false`（数组仍给得出，不是 null）。
// - 澳门那一支参照**不做任何校验**，文法命中即 `true`（§19.2 记过该不对称），且校验档是 `[0-9A-Z]`
//   ——比香港那一支的 `[0-9A]` 宽；两档的字符集差别都有腿读数。

///|
/// 港澳台 10 位证件号的信息三槽。构造只经 `idcard_info_10`，本库不导出构造器。
/// - Fields: `region` 地区名（参照第 `[0]` 槽）、`gender` 性别 `M`/`F`/`N`（第 `[1]` 槽）、
///   `valid` 是否合法（第 `[2]` 槽的 `"true"/"false"` 归一成 `Bool`）
pub struct IdcardInfo10 {
  region : String
  gender : String
  valid : Bool
}

///|
/// #23.111 解析港澳台 10 位证件号，给出地区、性别与合法性三槽
/// - Returns: 命中台湾/澳门/香港三种文法之一给 `Some`；空白、长度不合、三种文法都不命中给 `None`
///   （参照给 `null` 的那些档）
/// - Raises: 无（参照对 `null` 入参先判空白、返回 `null`，不抛；本库入参类型上也不允许 `null`）
/// - Note: hutool 对位 `static String[] isValidCard10(String)`；合法性判据与 #23.110 的十位档同源
pub fn idcard_info_10(id : String) -> IdcardInfo10? {
  abort(
    "moon-hutool PR-B：契约骨架 #23.111 idcard_info_10 待落地，见 docs/spec/23-typex.md §20",
  )
}
