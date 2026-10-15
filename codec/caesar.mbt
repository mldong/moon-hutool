///|
/// moon-hutool/codec —— hutool `Caesar` 的 MoonBit 对位（批③第一片）
///
/// 契约：`docs/spec/05-codec.md` §13.1~§13.2；进度：`docs/ROADMAP.md`。
/// 这一批**只有签名与冻结期望值，函数体是 `abort`**（状态＝契约已冻结，用例预期红）；
/// 实现那一笔只许把红变绿（门禁 G5）。
///
/// 三条贯穿性规则（都由参照腿与本机字节码支撑，不是设计偏好）：
/// 1. **不是教科书上的凯撒密码**。参照的表是 52 字符的 `AaBbCc…Zz` 交替串，
///    移位是在这张表里走格子 ⇒ `A`+1 = `a`、`a`+1 = `B`、`z`+1 = `A`（腿 `CC|table-esc`）。
/// 2. **守卫是 Unicode 字母，不是"在不在表里"**（`Character.isLetter(char)`）。本版 core 没有
///    这个谓词，所以字母集由生成件 `codec/letter_table.mbt` 带进来，与参照腿的三条全域读数逐条对撞
///    （`codec/letter_table_wbtest.mbt`）。不收窄成 ASCII 档——那样 `caesar_encode("中文", 3)`
///    会从参照的 `"CC"` 变成 `"中文"`，是语义层分岔，不是结构层。
/// 3. **逐 UTF-16 码元摊**，不是逐码位：参照拿的是 `char`（代理码元 `isLetter` 判 false，
///    所以 emoji 整体不参与移位）。这条与 `Morse` 相反（那边是 `codePointAt`），两件不能互相"统一"。

///|
/// 参照 `Caesar.TABLE`：52 字符的交替大小写表，移位的全部语义都在这张表的**下标**上。
///
/// - Note: 顺序不是 `A-Z` 再 `a-z`，而是 `A`、`a`、`B`、`b`……（腿 `CC|table-esc`／`CC|table-codes`）。
pub let caesar_table : String = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz"

///|
/// 凯撒移位编码（参照 `Caesar.encode(String, int)`）
///
/// 算式（字节码 + 腿 `CC|enc` 双证）：对每个**码元** `c`，
/// - 不是 Unicode 字母 ⇒ 原样留下；
/// - 是字母 ⇒ `j = (caesar_table.indexOf(c) + shift) % 52`，取 `caesar_table[j]`。
///
/// - Parameters: `text` 明文；`shift` 位移量（**可以为负、可以大于 52**，两条都不归类）。
/// - Returns: 移位后的字符串；空串进空串出。
/// - Raises: `CodecError.ShiftUnderflow(j)` —— `j < 0` 的那一档。参照侧在这里抛
///   `StringIndexOutOfBoundsException: String index out of range: <j>`，**消息里带的就是这个负下标**，
///   所以本库把它作为读数交出而不是发明一个"取模归一"。两类输入会走到这里：
///   ①表内字母配负 `shift`（`A`-1 ⇒ -1，腿 `CC|enc|A|-1`）；
///   ②**在 Unicode 里算字母但不在 52 字符表里**的码元（`é`/`中`/`Ω`）——`indexOf` 给 -1，
///     于是 `shift <= 0` 全档负、`shift >= 1` 才出字符（腿 `CC|enc|é|0` 抛、`CC|enc|é|1` 给 `A`）。
/// - Note: 参照的 `null` 入参档（`IllegalArgumentException: message must be not null!`）在本库
///   **结构上到不了**——`String` 非空，不需要也不能造那一条。
pub fn caesar_encode(text : String, shift : Int32) -> String raise CodecError {
  let t = caesar_table.to_array()
  let buf = StringBuilder()
  for c in text {
    let u = c.to_int()
    if is_letter_unit(u) {
      // 表内字母：j = (indexOf(c) + shift) % 52；表外字母 indexOf 给 -1，
      // 于是 shift <= 0 时 j 落负——参照在这里抛，负下标原样交出（spec §13.1 第 3 条）
      let j = (table_index_of(t, c) + shift) % 52
      if j < 0 {
        raise ShiftUnderflow(j)
      }
      buf.write_char(t[j])
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
/// 凯撒移位解码（参照 `Caesar.decode(String, int)`）
///
/// 算式与 `caesar_encode` 只差两处（都在字节码里）：用 `- shift` 而不是 `+ shift`，
/// **并且**取模后多做一步 `if (j < 0) j += 52`。
///
/// - Returns: 恒有解——这一步归一就是解码侧从不抛错的全部原因（腿 `CC|dec` 组 105×15 档零抛错）。
///   签名因此**不带错误面**（0.1.0 曾带 `raise CodecError`，那一代本件还是 abort 体从未可用；
///   spec §13.1"从不抛"的读数与签名自洽，0.1.1 收窄）。
/// - Note: 于是 `decode(encode(x, k), k) == x` **不恒成立**：`encode` 在负档先抛了，
///   而 `decode` 对表外字母照样出字符（`é` 解码给 `z`/`Z` 那一族，腿 `CC|dec|é|*`）。
///   往返判据只在"两边都不抛"的档上钉（腿 `CC|rt` 组）。
pub fn caesar_decode(text : String, shift : Int32) -> String {
  let t = caesar_table.to_array()
  let buf = StringBuilder()
  for c in text {
    let u = c.to_int()
    if is_letter_unit(u) {
      // 与 encode 只差两处：用 -shift，且负 j 归一（这一步就是解码侧从不抛的全部原因）
      let mut j = (table_index_of(t, c) - shift) % 52
      if j < 0 {
        j += 52
      }
      buf.write_char(t[j])
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
/// 码元在 52 字符交替表里的下标；表外（`indexOf == -1` 档）给 -1。
/// 表固定 52 字符，逐格扫描即可，不为这一件引入额外数据件。
fn table_index_of(t : Array[Char], c : Char) -> Int32 {
  for k in 0..<52 {
    if t[k] == c {
      return k
    }
  }
  -1
}
