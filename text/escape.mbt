///|
// hutool `EscapeUtil` + `UnicodeUtil` + `URLUtil.encodeBlank` 的对位面（契约 01 §1.16~§1.19）。
//
// 状态：**PR-A 契约骨架**——签名、类型、错误面与全部期望值已按参照腿的读数冻结，函数体是
// `abort`，用例此刻红是设计态（AGENTS「交付形状」）。实现轮只许把红变绿，改期望要单独一笔。
//
// 三条形状口径（不是风格，是被读数逼出来的）：
// 1. **本库的入参是码位序列，参照是 UTF-16 码元序列。** 参照逐码元走 ⇒ 一个星平面字符在它那侧
//    是两个代理码元、各自判"要不要转"，产出 `%uD83D%uDE00` 这种形状。本库把同一件事算成
//    "码位 > 0xffff ⇒ 拆成两个 `%uXXXX`"，两侧对得上；反方向（解出成对代理）合成码位，
//    与参照表示同一个字符，也是零偏差。
// 2. **落单代理是表示域的分界，不是错误。** 参照能把 `&#xD800;` 解成一个孤立代理码元，
//    MoonBit 的 `String` 表示不了那一形状 ⇒ 本库唯一诚实的出口是 `raise(LoneSurrogate)`，
//    既不静默丢、也不替换成 U+FFFD（那两条都是自创语义）。
// 3. **`escape` 的"不转义集"是一张数据表**，不是 `Char::is_ascii_alphabetic` 一类现成谓词：
//    参照的过滤器是 `isDigit||isLowerCase||isUpperCase||"*@-_+./"`（javap -c 现读），
//    跨 Unicode 大小写类别。core 只有 ASCII 档谓词 ⇒ 不自创"只承诺 ASCII"，
//    把 `EscapeLeg3` 逐位对撞出的 146 段区间表带进来（约 1.5 KB，且表外只剩"永远转"的一档）。

///|
/// 本批公开面的失败档（四件 raise 面共用；每条都注明它折的是参照哪个异常）
pub suberror TextError {
  /// `%` 后取 2/4 位却凑不成十六进制 —— 参照 `NumberFormatException`
  BadHex(String)
  /// `%` 落在串尾、取不够位数 —— 参照 `StringIndexOutOfBoundsException`
  ShortInput
  /// 解出来是孤立代理码元 —— 参照能产出，本库的 `String` 表示不了
  LoneSurrogate(Int)
  /// `lookup_replacer` 的表里出现空键 —— 参照在构造器里就 `charAt(0)` 越界
  EmptyKey
}

///|
/// XML 实体转义（hutool `EscapeUtil.escapeXml`）。与 `escape_html4` 的**唯一**读数差是 `'`：
/// XML 出 `&apos;`，HTML4 原样留（腿 E 行两侧同输入并排给出）。
/// 非 ASCII 一律不动；`—`/`–` 这类只在 HTML4 侧出实体名。
pub fn escape_xml(s : String) -> String {
  let _ = xml_escape_pairs
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.16")
}

///|
/// XML 实体还原（`EscapeUtil.unescapeXml`）。只认 XML 那 5 条命名实体 + 数字引用：
/// `&nbsp;` 解得出（参照的 XML 解表带它），`&copy;`/`&pound;` **原样留**（腿 E 行实测）。
pub fn unescape_xml(s : String) -> String raise TextError {
  let _ = xml_unescape_pairs
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.16")
}

///|
/// HTML4 实体转义（`EscapeUtil.escapeHtml4`）——表比 XML 大：BASIC 4 条 + ISO8859_1 96 条 +
/// HTML40_EXTENDED 151 条 = 251 条，逐条由反射读来（见 `escape_tables.mbt` 头注）。
pub fn escape_html4(s : String) -> String {
  let _ = html4_escape_pairs
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.16")
}

///|
/// HTML4 实体还原（`EscapeUtil.unescapeHtml4`）：XML 那 5 条 + 246 条 HTML4 名 = 252 条。
/// 未知名、缺分号、坏数字引用一律**原样留**（腿 E/N 行逐档实测），所以这里只可能因
/// 代理区数字引用而 raise。
pub fn unescape_html4(s : String) -> String raise TextError {
  let _ = html4_unescape_pairs
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.16")
}

///|
/// 百分号转义，默认过滤器版（`EscapeUtil.escape(CharSequence)`）。
/// 非 ASCII 出的是 **`%uXXXX`**（每码元、小写十六进制），不是 UTF-8 三字节 `%E4%B8%AD`——
/// 这是参照的形状（IE 风格 `%u`），别"顺手改成标准百分号编码"，改了就不是 hutool。
pub fn escape(s : String) -> String {
  let _ = escape_keep_ranges
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.17")
}

///|
/// 百分号转义，全转版（`EscapeUtil.escapeAll`）：一位都不留，ASCII 出 `%XX`（两位小写），
/// BMP 其余出 `%uXXXX`（四位小写）。
pub fn escape_all(s : String) -> String {
  let _ = escape_keep_ranges
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.17")
}

///|
/// 百分号转义，自定义过滤器版（`EscapeUtil.escape(CharSequence, Filter<Character>)`）。
/// **方向照参照**：`to_escape(c)` 为真 ⇒ 该字符转义（腿 P 行的 keepAll/keepNone 两档就是这条判据）。
/// 形状差一条（写进 spec §1.17）：参照把过滤器喂给每个 UTF-16 码元，本库喂码位 ⇒
/// 星平面字符在本库是"一次判定 + 两个 `%u`"，参照是"两次判定、各自一个 `%u`"；
/// 表内四位样例（keepAll/keepNone/ASCII 字母/非空白）两侧同读数。
pub fn escape_by(s : String, to_escape : (Char) -> Bool) -> String {
  let _ = to_escape
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.17")
}

///|
/// 百分号还原（`EscapeUtil.unescape`）。**不做 UTF-8 解码**：`%e4%b8%ad` 出三个字符
/// `ä¸\xad`，不是"中"（腿 UN 行实测）；`+` 不当空格。坏 `%` 折成 `TextError`。
pub fn unescape(s : String) -> String raise TextError {
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.17")
}

///|
/// 还原失败就原样返回（`EscapeUtil.safeUnescape`）——参照吞的是**任何**异常，
/// 本库把 `unescape` 的三档失败收成原串返回，判据是腿 UN 行的每一档坏样本。
pub fn safe_unescape(s : String) -> String {
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.17")
}

///|
/// 把"不在 0x20..0x7E 这一段"的字符转成 `\uXXXX`（`UnicodeUtil.toUnicode(String)`，参照第二参默认 true）。
/// 原样档就是可打印 ASCII 那一整段（逐位扫描见 `scripts/UnicodeScan.java`：
/// `KEEP|toUnicode(true)|0020-007e`，只一段）——换行符虽是 ASCII 也照转，
/// 所以"只转非 ASCII"那句常识不能写进契约。十六进制**小写**、最少四位。
pub fn to_unicode(s : String) -> String {
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.18")
}

///|
/// 每一位都转（`UnicodeUtil.toUnicode(String, false)`）——含 ASCII 与反斜杠本身。
pub fn to_unicode_all(s : String) -> String {
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.18")
}

///|
/// 单个码点的 `\uXXXX`（参照的 `toUnicode(char)` 与 `toUnicode(int)` **两件合一**：
/// 腿 N 行成对打这两个出口，BMP 内每一条两侧同字符串 ⇒ 没有第二条语义可承诺）。
/// 形状照参照的 `Integer.toHexString`：取低 32 位、小写十六进制、最少四位（`-1` →
/// `\uffffffff`、`0x10000` → `\u10000`，腿 N 行两位都在）。
pub fn unicode_of(cp : Int) -> String {
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.18")
}

///|
/// `\uXXXX` 串 → 真字符（`UnicodeUtil.toString`）。参照的认法逐条钉住：
/// **固定吃四位**（`\u12345` → 一位 + `5`）、位数不足四位或含非十六进制位 ⇒ 原样留、
/// **双反斜杠不挡它**（`\\u4e2d` → `\` + 中，腿 R 行）、十六进制大小写都认。
pub fn unicode_to_string(s : String) -> String raise TextError {
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.18")
}

///|
/// 空白字符转 `%20`，其余原样（hutool `URLUtil.encodeBlank`——挂在 URLUtil 上，但它只吃空白
/// 判定，而那条谓词整仓只有一张表，所以收在 text，与 `is_blank`/`trim` 同源）。
/// 表里 35 位逐位等价（`scripts/BlankScanLeg.java`：`isBlank`/`trim`/`cleanBlank`/
/// `encodeBlank`/`isBlankChar` 五个出口命中集完全一致）；非 BMP 一律原样。
pub fn encode_blank(s : String) -> String {
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.19")
}
