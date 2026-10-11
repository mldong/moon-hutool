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
/// 3. **encode 截断取模、负余数直出** ⇒ 负 `shift` 会把字符**甩出字母表**（`A`-13 ⇒ `'4'`、
///    `0`-1 ⇒ `'/'`，腿 `RT|enc|A|-13|true`）。这一档参照就是这么出字符的，本库照抄不夹回来。
///    **decode 与 encode 不是"取负再取模"的对称关系**——参照 `decodeChar` 三段归一策略各异
///    （数字段/大写段 `while` 补到非负、小写段 `if` 只补一次 26，负值落 `(char)` 的 16 位回绕），
///    真源码为凭（hutool 5.8.37 `Rot.java` decodeChar），腿读数逐档对上（`RT|dec` 组）。

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
  let buf = StringBuilder()
  for c in text {
    buf.write_char(rot_shift(c, shift, number_support))
  }
  buf.to_string()
}

///|
/// 三段独立取模的共式（encode 用 `+shift`、decode 用 `-shift`，其余一字不差）。
/// 各段结果恒在 ASCII 区间（负 shift 落点最低 `39`/`40`/`84`，都不越合法码位），
/// `unsafe_to_char` 在这里不会产孤立代理。数字段只在 `number_support` 开着才参与。
fn rot_shift(c : Char, shift : Int, number_support : Bool) -> Char {
  let u = c.to_int()
  if number_support && u >= 48 && u <= 57 {
    ((u - 48 + shift) % 10 + 48).unsafe_to_char()
  } else if u >= 65 && u <= 90 {
    ((u - 65 + shift) % 26 + 65).unsafe_to_char()
  } else if u >= 97 && u <= 122 {
    ((u - 97 + shift) % 26 + 97).unsafe_to_char()
  } else {
    c
  }
}

///|
/// ROT 移位解码（参照 `Rot.decode(String, int, boolean)`）
///
/// - Note: 参照 `decode` 不是 `encode` 取负的对称件（归一策略见 `rot_decode_char`），
///   因此 `rot13_decode(rot13_encode(x))` 只在部分档自逆（腿 `RT|d13` 组分布逐条钉）。
///   把解码"修成"真逆元是一处语义发明，禁止。
pub fn rot_decode(text : String, shift : Int, number_support : Bool) -> String {
  let buf = StringBuilder()
  for c in text {
    buf.write_char(rot_decode_char(c, shift, number_support))
  }
  buf.to_string()
}

///|
/// 解码单码元（参照 `Rot.decodeChar` 的逐字直译）。
///
/// 参照的三个归一策略**各不相同**，不许顺手统一（腿 `RT|dec` 组逐档为凭）：
/// - 数字段：`while (temp < 0) temp += 10`——补到非负为止；
/// - 大写段：`while (temp < 0) temp = 26 + temp`——同样补到非负（所以 `A`/`Z` 在 shift=104
///   档**原样回环**：`A`-104 归一 4 圈回 0 ⇒ `A`，腿 `RT|dec|A|104`）；
/// - 小写段：`if (temp < 0) temp = 26 + temp`——**只补一次 26**，大负值带着负数落
///   `(char)` 的 16 位回绕（`a`-104 ⇒ 19、`z`-104 ⇒ 44，腿同档读数）。
///
/// 数字段处理完**不截断流程**——改写后的码元还要过两段字母判断（结果 48..57 不会落字母段，
/// 但结构照抄不合并）。最终 `(char) temp` 的 16 位截断用 `& 0xFFFF` 对齐；参照腿覆盖
/// `±104`，面内结果恒在 `[19, 226]`，不会走到代理区。
fn rot_decode_char(c : Char, offset : Int, number_support : Bool) -> Char {
  let mut t = c.to_int()
  if number_support && t >= 48 && t <= 57 {
    t = t - 48 - offset
    while t < 0 {
      t += 10
    }
    t += 48
  }
  if t >= 65 && t <= 90 {
    t = t - 65 - offset
    while t < 0 {
      t += 26
    }
    t += 65
  } else if t >= 97 && t <= 122 {
    t = t - 97 - offset
    if t < 0 {
      t = 26 + t
    }
    t += 97
  }
  (t & 0xFFFF).unsafe_to_char()
}

///|
/// ROT13 编码（参照 `Rot.encode13` 两档塌成一个带默认值的口）
///
/// - Parameters: `number_support` 默认 `true`——这一档不是选出来的，是参照单参 `encode13(String)`
///   字节码里那个 `iconst_1` 加上腿对撞出来的（数字夹具 `0189` 只有 `true` 侧相等）。
/// - Returns: 等价于 `rot_encode(text, 13, number_support)`。
pub fn rot13_encode(text : String, number_support? : Bool = true) -> String {
  rot_encode(text, 13, number_support)
}

///|
/// ROT13 解码（参照 `Rot.decode13` 两档）
///
/// - Returns: 等价于 `rot_decode(text, 13, number_support)`；默认档同样是 `true`。
/// - Note: 与 `rot13_encode` **不是互逆**（上一条已给读数），名字照参照留，不改成 `rot13` 单件。
pub fn rot13_decode(text : String, number_support? : Bool = true) -> String {
  rot_decode(text, 13, number_support)
}
