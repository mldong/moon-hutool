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
//   ⇒ 凡过了形状闸的串，校验位一定算得出来；`-1` 那一档只能从"没过形状闸"的串来，而那种串第一步就返回 false。
// - 参照先 `isBlank` + 整串正则，**再**算校验位 ⇒ 顺序是契约的一部分（腿里 4 条"区划段含字母但校验位算得出"
//   的样本两档都读回 false，就是这条闸的证据；变异要专门打它）。
// - 版内语法：`expr?` 的可选链在本版**判词法错**（`unexpected token ?`），故校验位下标用参照同款的
//   `-1` 哨兵整型而不是 `Option`。

///|
/// #23.48 形状校验（非空白 + 整串命中 18 位码表正则，**不算校验位**）
/// - Returns: 空白串一律 `false`；长度不是 18、第 3~8 位不是数字、含 I/O/S/V/Z 或小写都 `false`
/// - Raises: 无
/// - Note: hutool 对位 `static boolean isCreditCodeSimple(CharSequence)`
pub fn typex_credit_code_is_simple(code : String) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.48")
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
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.49")
}
