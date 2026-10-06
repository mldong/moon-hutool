///|
// moon-hutool/typex —— 统一社会信用代码面（ROADMAP 第 23 行第三批 B，#23.48–#23.49）
// 对位 hutool `cn.hutool.core.util.CreditCodeUtil`（GB32100-2015）：
// `javap` 现读公开面 = 1 个常量（`CREDIT_CODE_PATTERN`）+ `isCreditCodeSimple` + `isCreditCode` + `randomCreditCode`。
// 本批收两件校验；`randomCreditCode` 走裸 `RandomUtil` ⇒ 按 `rand` 轮口径**不收**（随机一律显式注入种子）。
// 契约真相在 `docs/spec/23-typex.md` §12。
//
// 四条决定实现形状、且都有腿读数为凭的事实：
// - 码表与权重由**反射读参照的 private 常量**（`WEIGHT` 17 枚 = 3 的幂 mod 31、`BASE_CODE_ARRAY` 31 枚），
//   正则由反射读 `PatternPool.CREDIT_CODE` ⇒ 三张表都不手抄。
// - 参照的字符集 `[0-9A-HJ-NPQRTUWXY]` 与码表 `BASE_CODE_ARRAY` **是同一枚集合**（都剔 I/O/S/V/Z）
//   ⇒ 凡过了形状闸的串，校验位一定算得出来（腿的 `getParityBit` 不会返回 -1）；
//   `-1` 那一档只能从"没过形状闸"的串来，而那种串在本件第一步就返回 false。
// - 参照先 `isBlank` + 整串正则，**再**算校验位 ⇒ 顺序是契约的一部分（腿里 4 条"区划段含字母但校验位算得出"
//   的样本两档都读回 false，就是这条闸的证据；变异要专门打它）。
// - 版内语法：`expr?` 的可选链在本版**判词法错**（`unexpected token ?`），故校验位下标用参照同款的
//   `-1` 哨兵整型而不是 `Option`。

///|
// 反射读自 `PatternPool.CREDIT_CODE`（源文 `^[0-9A-HJ-NPQRTUWXY]{2}\d{6}[0-9A-HJ-NPQRTUWXY]{10}$`、flags=0）。
// 本库的 `whole` 已经补 `^(?:P)$`，所以这里去掉两侧的锚记（等价，见 spec §12.3 第 2 条），
// `\d` 按 core 方言写 `[[:digit:]]`（改写规则同 `valid`/`typex` 前两批）。
let pat_credit : String = "[0-9A-HJ-NPQRTUWXY]{2}[[:digit:]]{6}[0-9A-HJ-NPQRTUWXY]{10}"

///|
// 反射读自 `CreditCodeUtil.BASE_CODE_ARRAY`：31 枚，剔 I/O/S/V/Z。
let credit_base : Array[Char] = "0123456789ABCDEFGHJKLMNPQRTUWXY".to_array()

///|
// 反射读自 `CreditCodeUtil.WEIGHT`（17 枚，3 的幂 mod 31）。
let credit_weight : Array[Int] = [
  1, 3, 9, 27, 19, 26, 16, 17, 20, 29, 25, 13, 8, 24, 10, 30, 28,
]

///|
/// 字符在码表里的下标；参照查 `Map<Character, Integer>` 查不到给 `null`、上层落成 `-1` ⇒ 本库直接给 `-1`。
fn credit_index(c : Char) -> Int {
  let mut i = 0
  while i < credit_base.length() {
    if credit_base[i] == c {
      return i
    }
    i = i + 1
  }
  -1
}

///|
/// 校验位下标（参照的 private `getParityBit`：前 17 位加权和，`31 - sum % 31`，等于 31 时归 0）。
/// - 只在过了形状闸之后被调用 ⇒ 入参一定是 18 码位、且前 17 位全在码表内，`-1` 分支本批走不到
///   （spec §12.3 第 1 条），保留它是照参照的形状而不是造一条永不成立的档。
fn credit_parity(cs : Array[Char]) -> Int {
  let mut sum = 0
  let mut i = 0
  while i < 17 {
    let v = credit_index(cs[i])
    if v < 0 {
      return -1
    }
    sum = sum + v * credit_weight[i]
    i = i + 1
  }
  let r = 31 - sum % 31
  if r == 31 {
    0
  } else {
    r
  }
}

///|
/// #23.48 形状校验（非空白 + 整串命中 18 位码表正则，**不算校验位**）
/// - Returns: 空白串一律 `false`；长度不是 18、第 3~8 位不是数字、含 I/O/S/V/Z 或小写都 `false`
/// - Raises: 无
/// - Note: hutool 对位 `static boolean isCreditCodeSimple(CharSequence)`
pub fn typex_credit_code_is_simple(code : String) -> Bool {
  !@text.is_blank(code) && whole(pat_credit, code)
}

///|
/// #23.49 完整校验（形状闸 + 第 18 位等于码表里下标为校验位的那枚）
/// - Returns: 先过 #23.48，再比校验位；两步任一不过都 `false`
/// - Raises: 无
/// - Note: hutool 对位 `static boolean isCreditCode(CharSequence)`。
///   参照的 `charAt(17)` 与加权循环都在 **UTF-16 码元**域，本件用码位域 ⇒ 两者在本批**可证等价**：
///   要走到校验位比较，前 17 位必须全落在 31 枚 ASCII 码表内（非 ASCII 一律在形状闸就出局），
///   此时码元域与码位域逐位同一（spec §12.3 第 3 条）。
pub fn typex_credit_code_is_valid(code : String) -> Bool {
  if !typex_credit_code_is_simple(code) {
    return false
  }
  let cs = code.to_array()
  let p = credit_parity(cs)
  p >= 0 && cs[17] == credit_base[p]
}
