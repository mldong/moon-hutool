///|
// moon-hutool/typex —— 港澳台 10 位身份证的信息三槽（ROADMAP 第 23 行第六批，#23.111）
// 对位 hutool `cn.hutool.core.util.IdcardUtil.isValidCard10`。契约真相在 `docs/spec/23-typex.md` §20。
//
// 三条决定实现形状、且都有腿读数为凭的事实：
// - 参照的出口是 `String[3]` 或 `null`；腿 29 条读数里**凡是给出数组的，三个槽都非空**，所以本库只需要
//   `IdcardInfo10?` 一层可选，不往字段上再套 `Option`。唯一的归一是 `[2]` 槽：`"true"/"false"` 串收成 `Bool`。
// - 地区名与性别是参照自己拼的串（三枚地区名、三枚性别码），照搬不建枚举（§15.1 先例）。
// - 长度闸在参照里混用两个长度：剥掉括号后的 `card` 看 8/9，原始串 `idcard` 看 10——
//   所以 `AB12345(6)` 过闸后因三种文法都不命中而给 `None`，而 8 位的 `A1234567` 过闸后落进香港档。

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
/// - Note: hutool 对位 `static String[] isValidCard10(String)`；#23.110 的十位档就是取本件的 `valid` 槽
pub fn idcard_info_10(id : String) -> IdcardInfo10? {
  let cs = id.to_array()
  let mut blank = true
  for c in cs.iter() {
    if !ds_is_blank(c) {
      blank = false
    }
  }
  if cs.length() == 0 || blank {
    return None
  }
  let stripped = idc_strip_parens(cs)
  if stripped.length() != 8 && stripped.length() != 9 && cs.length() != 10 {
    return None
  }
  // 三种文法按参照的 if / else if 顺序试：台湾 → 澳门 → 香港
  if idc_tw_grammar(cs) {
    let c2 = cs[1]
    if c2 != '1' && c2 != '2' {
      // 参照在这一支**早退**：地区名与 `N` 都写进数组，第 [2] 槽写 "false"，不再算校验位
      return Some(IdcardInfo10::{ region: "台湾", gender: "N", valid: false, })
    }
    let gender = if c2 == '1' { "M" } else { "F" }
    Some(IdcardInfo10::{
      region: "台湾",
      gender,
      valid: idcard_is_valid_tw_card(id),
    })
  } else if idc_mo_grammar(cs) {
    // 澳门那一支参照不做任何校验，命中即真（§19.2 记过港澳台三家在这点上的不对称）
    Some(IdcardInfo10::{ region: "澳门", gender: "N", valid: true, })
  } else if idc_hk_grammar(cs) {
    Some(IdcardInfo10::{
      region: "香港",
      gender: "N",
      valid: idcard_is_valid_hk_card(id),
    })
  } else {
    None
  }
}
