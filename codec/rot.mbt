///|
/// moon-hutool/codec —— hutool `Rot` 的 MoonBit 对位（批③第二片）
///
/// 契约：`docs/spec/05-codec.md` §13.3。
///
/// 与 `caesar_*` 的三处不同都必须分开写，不许"顺手合成一件"（腿逐条为凭）：
/// 1. **守卫是 ASCII 码位区间**（`0-9`、`A-Z`、`a-z` 三段分别判），所以 `é`/`中` 原样透传——
///    而 `Caesar` 的守卫是 Unicode 字母档，同一输入两边一个移一个不移。
/// 2. **数字可以参与**，由 `number_support` 这一个开关控制（参照 `encode13(String)` 单参档
///    实测把开关给的是 `true`，腿 `RT|e13|0189||3412|true?1|false?0`）。
/// 3. **各段独立取模、不做负数归一** ⇒ 负 `shift` 会把字符**甩出字母表**（`A`-13 ⇒ `'4'`、
///    `0`-1 ⇒ `'/'`，腿 `RT|enc|A|-13|true`）。这一档参照就是这么出字符的，本库照抄不夹回来。

///|
/// ROT 移位编码（参照 `Rot.encode(String, int, boolean)`）
///
/// 算式（字节码三段 + 腿 `RT|enc` 组 25×15×2 档）：对每个码元
/// - `number_support` 且 `0`~`9` ⇒ `(c - 48 + shift) % 10 + 48`
/// - `A`~`Z` ⇒ `(c - 65 + shift) % 26 + 65`
/// - `a`~`z` ⇒ `(c - 97 + shift) % 26 + 97`
/// - 其余 ⇒ 原样留下（**这三段是码位区间判断，不是字母判断**）
///
/// - Parameters: `text` 明文；`shift` 位移量（可为负）；`number_support` 数字是否参与。
/// - Returns: 恒出字符串、**从不抛错**——负数取模的落点即使掉出字母表也照样是合法字符（见上第 3 条）。
/// - Note: 参照的 `null` 档（`IllegalArgumentException: message must not be null`）结构上到不了。
pub fn rot_encode(text : String, shift : Int, number_support : Bool) -> String {
  let _ = (text, shift, number_support)
  abort(
    "PR-B：契约骨架，docs/spec/05-codec.md §13.3 与腿 RT|enc 组 25×15×2 档",
  )
}

///|
/// ROT 移位解码（参照 `Rot.decode(String, int, boolean)`）
///
/// 与编码同三段，只是把 `+ shift` 换成 `- shift`，**同样不做负数归一**。
///
/// - Note: 因此 `rot13_decode(rot13_encode(x))` 只在字母段自逆，数字段与"甩出字母表"的档都不自逆
///   （腿 `RT|d13` 组 25 条里只有 19 条 `dec13 == enc13`）。把解码"修成"真逆元是一处语义发明，禁止。
pub fn rot_decode(text : String, shift : Int, number_support : Bool) -> String {
  let _ = (text, shift, number_support)
  abort(
    "PR-B：契约骨架，docs/spec/05-codec.md §13.3 与腿 RT|dec 组 25×15×2 档",
  )
}

///|
/// ROT13 编码（参照 `Rot.encode13` 两档塌成一个带默认值的口）
///
/// - Parameters: `number_support` 默认 `true`——这一档不是选出来的，是参照单参 `encode13(String)`
///   字节码里那个 `iconst_1` 加上腿对撞出来的（数字夹具 `0189` 只有 `true` 侧相等）。
/// - Returns: 等价于 `rot_encode(text, 13, number_support)`。
pub fn rot13_encode(text : String, number_support? : Bool = true) -> String {
  let _ = (text, number_support)
  abort("PR-B：契约骨架，docs/spec/05-codec.md §13.3 与腿 RT|e13 组")
}

///|
/// ROT13 解码（参照 `Rot.decode13` 两档）
///
/// - Returns: 等价于 `rot_decode(text, 13, number_support)`；默认档同样是 `true`。
/// - Note: 与 `rot13_encode` **不是互逆**（上一条已给读数），名字照参照留，不改成 `rot13` 单件。
pub fn rot13_decode(text : String, number_support? : Bool = true) -> String {
  let _ = (text, number_support)
  abort("PR-B：契约骨架，docs/spec/05-codec.md §13.3 与腿 RT|d13 组")
}
