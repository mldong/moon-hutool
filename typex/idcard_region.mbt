///|
// moon-hutool/typex —— 港澳台 10 位身份证族（ROADMAP 第 23 行第五批，#23.108–#23.110）
// 对位 hutool `cn.hutool.core.util.IdcardUtil` 的 `isValidTWCard` / `isValidHKCard` / `isValidCard`。
// 契约真相在 `docs/spec/23-typex.md` §19。
//
// 【这是 PR-B 的落地草稿，放在临时目录，未进仓】落仓前要先过一遍：
//   1) 用 Temp/convsrc/fill_tw_table.py 把下面那张 26 枚表从腿灌满（不许手打）；
//   2) 删掉 typex/moon.pkg 里那行 `warnings = "-unused_value"`（G12：体里已无 abort）；
//   3) 棘轮 BASELINE_TESTS 515 保持（本笔不减块）；
//   4) 变异 T1–T7 在 tar 出的隔离副本挂载，基线＝本包 6 块设计态红，判据是"红块数是否增加"。
//
// 四条决定实现形状、且都有腿读数为凭的事实：
// - 三件的出口都是 `Bool`：参照 `isValidCard` 本身就是 `boolean`，而它内部对十位那一支只问
//   `cardVal != null && "true".equals(cardVal[2])`——地区名与性别槽它并不返回。
// - 台湾那一支靠一张 26 枚首字母表（反射读到的值并非等差：`A=10 … H=17、I=34、J=18 …`），
//   校验位是 `sum % 10` 的补数；腿把 26×10 全扫了一遍，每枚首字母恰好一枚通过。
// - 香港那一支的校验档不止 `0-9`，还收字符 `A`（代表 10），且括号的三种挂法（成对／只右／只左）
//   在参照的正则里都是合法形状——`replaceAll("[()]","")` 之后才算数（腿各有读数）。
// - `isValidCard` 只对长度恰为 18/15/10 的串分派：腿现读 `A1234563`（`isValidHKCard` 为真的 8 位串）
//   在 `isValidCard` 上给 false——"某个校验件通过"与"总派发通过"是两件事。
//
// 一处与本库出口形状的取舍（写进 §19.3 末，读数补在 §19.5）：参照在算式中段遇到非数字走
// `Integer.parseInt` 而抛 `NumberFormatException`（腿 `TW_EDGE_midLetter10/B4/B5` 三条现读都是
// `For input string: "B"`），本库三件都不设错误面——文法不合就当假。两侧出口形状不同（抛 vs 假），
// 但在"给不给真"上从不分岔：能走到那一步的串参照从不给真。`typex/idcard_midletter_test.mbt`
// 里那两条判别夹具（被替换位的「数字 × 权重」是 10 的倍数）钉的就是这一档。

///|
/// 反射读自 `IdcardUtil.TW_FIRST_CODE` 的 26 枚（下标 `A`..`Z`）。值不等差，别按等差生成。
let idcard_tw_first_code : Array[Int] = [
  10, 11, 12, 13, 14, 15, 16, 17, 34, 18, 19, 20, 21, 22, 35, 23, 24, 25, 26, 27,
  28, 29, 32, 30, 31, 33,
]

///|
/// 首字母 → 参照表里的两位数字；不在 `A`..`Z` 内给 `None`（参照查 `Map` 查不到给 `null`）。
fn idc_tw_start(c : Char) -> Int? {
  let i = c.to_int() - 'A'.to_int()
  if i < 0 || i >= idcard_tw_first_code.length() {
    None
  } else {
    Some(idcard_tw_first_code[i])
  }
}

///|
/// ASCII 数字字符 → 数值
fn idc_digit(c : Char) -> Int? {
  if c >= '0' && c <= '9' {
    Some(c.to_int() - '0'.to_int())
  } else {
    None
  }
}

///|
fn idc_is_letter(c : Char) -> Bool {
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
}

///|
/// 从 `from` 起恰好 `n` 位都是 ASCII 数字
fn idc_digits_at(cs : Array[Char], from : Int, n : Int) -> Bool {
  if from < 0 || from + n > cs.length() {
    return false
  }
  let mut k = 0
  while k < n {
    if idc_digit(cs[from + k]) is None {
      return false
    }
    k = k + 1
  }
  true
}

///|
/// 文法闸的收尾一档：`\(?X\)?$`——`X`、`(X)`、`(X`、`X)` 四种都算合法（参照两条 `\)?` 各自可选）。
/// `which` 选校验字符集：0 = 香港的 `[0-9A]`，1 = 澳门的 `[0-9A-Z]`（本版把闭包当实参传在 `&&` 链里解析不稳，
/// 用档位整数代替，两档都各有腿读数）。
fn idc_opt_check(cs : Array[Char], at : Int, which : Int) -> Bool {
  let rest = cs.length() - at
  if rest < 1 || rest > 3 {
    return false
  }
  let lp = cs[at] == '('
  let rp = cs[cs.length() - 1] == ')'
  // 形状不合时取哨兵空格：它不属于任何一档的字符集
  let c0 : Char = if lp && rp {
    if rest == 3 {
      cs[at + 1]
    } else {
      ' '
    }
  } else if lp {
    if rest == 2 {
      cs[at + 1]
    } else {
      ' '
    }
  } else if rp {
    if rest == 2 {
      cs[at]
    } else {
      ' '
    }
  } else if rest == 1 {
    cs[at]
  } else {
    ' '
  }
  if which == 0 {
    idc_hk_check(c0)
  } else {
    idc_mo_check(c0)
  }
}

///|
/// 香港那一档的校验字符集是 `[0-9A]`（`A` 在算式里代表 10）
fn idc_hk_check(c : Char) -> Bool {
  idc_digit(c) is Some(_) || c == 'A'
}

///|
/// 文法闸：`^[a-zA-Z][0-9]{9}$`（台湾）
fn idc_tw_grammar(cs : Array[Char]) -> Bool {
  cs.length() == 10 && idc_is_letter(cs[0]) && idc_digits_at(cs, 1, 9)
}

///|
/// 澳门那一档的校验字符集是 `[0-9A-Z]`
fn idc_mo_check(c : Char) -> Bool {
  (c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z')
}

///|
/// 文法闸：`^[157][0-9]{6}\(?[0-9A-Z]\)?$`（澳门）
fn idc_mo_grammar(cs : Array[Char]) -> Bool {
  if cs.length() < 8 {
    return false
  }
  let head = cs[0]
  (head == '1' || head == '5' || head == '7') &&
  idc_digits_at(cs, 1, 6) &&
  idc_opt_check(cs, 7, 1)
}

///|
/// 文法闸：`^[A-Z]{1,2}[0-9]{6}\(?[0-9A]\)?$`（香港；校验档只有 `0-9` 与 `A`）
fn idc_hk_grammar(cs : Array[Char]) -> Bool {
  if cs.length() < 8 {
    return false
  }
  // `[A-Z]{1,2}` 贪婪：第 2 位是字母就按两位算，否则按一位（按一位时第 2 位必是数字，两种取法不会都成立）
  let letters = if cs[1] >= 'A' && cs[1] <= 'Z' { 2 } else { 1 }
  let mut k = 0
  while k < letters {
    if !(cs[k] >= 'A' && cs[k] <= 'Z') {
      return false
    }
    k = k + 1
  }
  idc_digits_at(cs, letters, 6) && idc_opt_check(cs, letters + 6, 0)
}

///|
/// 去掉 `(` 与 `)`（参照 `replaceAll("[()]","")`）
fn idc_strip_parens(cs : Array[Char]) -> Array[Char] {
  let out : Array[Char] = []
  for c in cs.iter() {
    if c != '(' && c != ')' {
      out.push(c)
    }
  }
  out
}

///|
/// 手写子串（本版 `Array` 无 `slice`，与 `idcard.mbt` 同一姿势）
fn idc_sub(cs : Array[Char], from : Int, to : Int) -> Array[Char] {
  let out : Array[Char] = []
  let mut k = from
  while k < to {
    out.push(cs[k])
    k = k + 1
  }
  out
}

///|
/// 参照 `Character.toUpperCase(c) - 55`：`A` → 10
fn idc_hk_letter(c : Char) -> Int {
  let mut v = c.to_int()
  if v >= 'a'.to_int() && v <= 'z'.to_int() {
    v = v - 32
  }
  v - 55
}

///|
/// #23.108 台湾十位身份证校验（首字母表 + 加权 `sum % 10` 补数）
/// - Returns: 长度恰为 10、首字母在表内、且校验位正确才给 `true`；其余一律 `false`
/// - Raises: 无（参照对 `null` 先判长度、不抛；本库入参类型上也不允许 `null`）
/// - Note: hutool 对位 `static boolean isValidTWCard(String)`
pub fn idcard_is_valid_tw_card(id : String) -> Bool {
  let cs = id.to_array()
  if cs.length() != 10 {
    return false
  }
  let start = match idc_tw_start(cs[0]) {
    Some(v) => v
    None => return false
  }
  let mut sum = start / 10 + start % 10 * 9
  let mut iflag = 8
  let mut k = 1
  while k <= 8 {
    let d = match idc_digit(cs[k]) {
      Some(v) => v
      None => return false
    }
    sum = sum + d * iflag
    iflag = iflag - 1
    k = k + 1
  }
  let end = match idc_digit(cs[9]) {
    Some(v) => v
    None => return false
  }
  let want = if sum % 10 == 0 { 0 } else { 10 - sum % 10 }
  want == end
}

///|
/// #23.109 香港十位身份证校验（整串先过文法闸，再按 9-1 加权求和判 `sum % 11 == 0`）
/// - Returns: 文法不合直接 `false`；`A` 当校验位时按 10 计入
/// - Raises: 无（参照在 `null` 上抛 `NullPointerException`，本库入参类型上给不出 `null`，见 §19.2）
/// - Note: hutool 对位 `static boolean isValidHKCard(String)`
pub fn idcard_is_valid_hk_card(id : String) -> Bool {
  let cs = id.to_array()
  if !idc_hk_grammar(cs) {
    return false
  }
  let card = idc_strip_parens(cs)
  let mut sum = 0
  let body = if card.length() == 9 {
    sum = idc_hk_letter(card[0]) * 9 + idc_hk_letter(card[1]) * 8
    idc_sub(card, 1, 9)
  } else {
    // 参照的另一支：首位当作"空格"，`58 * 9 = 522`
    sum = 522 + idc_hk_letter(card[0]) * 8
    card
  }
  let mut iflag = 7
  let mut k = 1
  while k <= 6 {
    let d = match idc_digit(body[k]) {
      Some(v) => v
      None => return false
    }
    sum = sum + d * iflag
    iflag = iflag - 1
    k = k + 1
  }
  let end = if body[7] == 'A' {
    10
  } else {
    match idc_digit(body[7]) {
      Some(v) => v
      None => return false
    }
  }
  (sum + end) % 11 == 0
}

///|
/// #23.110 身份证总派发：按长度 18/15/10 分档，其余长度与空白一律 `false`
/// - Parameters: `this_year` 18 位那一支的生日上界（参照读 `DateUtil.thisYear()`，本库做成显式参数）
/// - Returns: 十位那一支只认港澳台三种文法之一且校验通过的串（澳门那支参照不做校验、匹配即真）
/// - Raises: 无
/// - Note: hutool 对位 `static boolean isValidCard(String)`（忽略 `X` 的大小写那一档）
pub fn idcard_is_valid_card(id : String, this_year : Int) -> Bool {
  let cs = id.to_array()
  let mut blank = true
  for c in cs.iter() {
    if !@text.is_blank_char(c) {
      blank = false
    }
  }
  if blank {
    return false
  }
  if cs.length() == 18 {
    idcard_is_valid_18(id, this_year)
  } else if cs.length() == 15 {
    idcard_is_valid_15(id)
  } else if cs.length() == 10 {
    idc_valid_10(id)
  } else {
    false
  }
}

///|
/// 参照 `isValidCard10` 里**只被用来判真/假**的那一半：能否拿到信息数组、且第 `[2]` 槽是 `"true"`。
/// 地区名与性别槽参照在 `isValidCard` 上并不返回，所以本库把这一半留在包内（公开与否见 §19.2）。
fn idc_valid_10(id : String) -> Bool {
  // 参照 `isValidCard` 的十位那一支就是 `cardVal != null && "true".equals(cardVal[2])`：
  // 判据与 #23.111 同源，只取 `valid` 槽，不再摆第二张文法表。
  match idcard_info_10(id) {
    None => false
    Some(info) => info.valid
  }
}
