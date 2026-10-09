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
  entity_escape(s, xml_escape_pairs)
}

///|
/// XML 实体还原（`EscapeUtil.unescapeXml`）。只认 XML 那 5 条命名实体 + 数字引用：
/// `&nbsp;` 解得出（参照的 XML 解表带它），`&copy;`/`&pound;` **原样留**（腿 E 行实测）。
pub fn unescape_xml(s : String) -> String raise TextError {
  unescape_entities(s, xml_unescape_pairs)
}

///|
/// HTML4 实体转义（`EscapeUtil.escapeHtml4`）——表比 XML 大：BASIC 4 条 + ISO8859_1 96 条 +
/// HTML40_EXTENDED 151 条 = 251 条，逐条由反射读来（见 `escape_tables.mbt` 头注）。
pub fn escape_html4(s : String) -> String {
  entity_escape(s, html4_escape_pairs)
}

///|
/// HTML4 实体还原（`EscapeUtil.unescapeHtml4`）：XML 那 5 条 + 246 条 HTML4 名 = 252 条。
/// 未知名、缺分号、坏数字引用一律**原样留**（腿 E/N 行逐档实测），所以这里只可能因
/// 代理区数字引用而 raise。
pub fn unescape_html4(s : String) -> String raise TextError {
  unescape_entities(s, html4_unescape_pairs)
}

///|
/// 百分号转义，默认过滤器版（`EscapeUtil.escape(CharSequence)`）。
/// 非 ASCII 出的是 **`%uXXXX`**（每码元、小写十六进制），不是 UTF-8 三字节 `%E4%B8%AD`——
/// 这是参照的形状（IE 风格 `%u`），别"顺手改成标准百分号编码"，改了就不是 hutool。
pub fn escape(s : String) -> String {
  escape_by(s, c => !keep_at(c.to_int()))
}

///|
/// 百分号转义，全转版（`EscapeUtil.escapeAll`）：一位都不留，ASCII 出 `%XX`（两位小写），
/// BMP 其余出 `%uXXXX`（四位小写）。
pub fn escape_all(s : String) -> String {
  escape_by(s, _c => true)
}

///|
/// 百分号转义，自定义过滤器版（`EscapeUtil.escape(CharSequence, Filter<Character>)`）。
/// **方向照参照**：`to_escape(c)` 为真 ⇒ 该字符转义（腿 P 行的 keepAll/keepNone 两档就是这条判据）。
/// 形状差一条（写进 spec §1.17）：参照把过滤器喂给每个 UTF-16 码元，本库喂码位 ⇒
/// 星平面字符在本库是"一次判定 + 两个 `%u`"，参照是"两次判定、各自一个 `%u`"；
/// 表内四位样例（keepAll/keepNone/ASCII 字母/非空白）两侧同读数。
pub fn escape_by(s : String, to_escape : (Char) -> Bool) -> String {
  let buf = StringBuilder()
  for c in s.iter() {
    if to_escape(c) {
      // 参照逐 UTF-16 码元走 ⇒ 星平面在这里也出两枚 `%u`（读数是 `%ud83d%ude00`）
      for u in to_units(c.to_int()) {
        if u <= 0xff {
          buf.write_string("%")
          buf.write_string(to_hex(u, 2))
        } else {
          buf.write_string("%u")
          buf.write_string(to_hex(u, 4))
        }
      }
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
/// 百分号还原（`EscapeUtil.unescape`）。**不做 UTF-8 解码**：`%e4%b8%ad` 出三个字符
/// `ä¸\xad`，不是"中"（腿 UN 行实测）；`+` 不当空格。坏 `%` 折成 `TextError`。
pub fn unescape(s : String) -> String raise TextError {
  let cs = s.iter().collect()
  let n = cs.length()
  let units : Array[Int] = []
  let mut i = 0
  while i < n {
    if cs[i] != '%' {
      push_chars_units([cs[i]], units)
      i += 1
    } else {
      let mut j = i + 1
      let wide = j < n && (cs[j] == 'u' || cs[j] == 'U')
      if wide {
        j += 1
      }
      let need = if wide { 4 } else { 2 }
      if j + need > n {
        raise ShortInput // 参照 `StringIndexOutOfBoundsException`（腿 UN 行 `%`、`%2` 两档）
      }
      let body = sub_chars(cs, j, j + need)
      let mut v = 0
      for c in body {
        if !is_hex_digit(c) {
          raise BadHex(join_chars(body)) // 载荷 = 被取走的那几位原文（参照异常消息里就是它）
        }
        v = v * 16 + hex_value(c)
      }
      for u in to_units(v) {
        units.push(u)
      }
      i = j + need
    }
  }
  match units_to_string(units) {
    Some(r) => r
    None => raise LoneSurrogate(first_lone(units))
  }
}

///|
/// 还原失败就原样返回（`EscapeUtil.safeUnescape`）——参照吞的是**任何**异常，
/// 本库把 `unescape` 的三档失败收成原串返回，判据是腿 UN 行的每一档坏样本。
pub fn safe_unescape(s : String) -> String {
  unescape(s) catch {
    // 参照吞掉任何异常并返回**入参**（不是空串、不是 null），腿 UN 行每档坏样本都这么读
    _ => s
  }
}

///|
/// 把"不在 0x20..0x7E 这一段"的字符转成 `\uXXXX`（`UnicodeUtil.toUnicode(String)`，参照第二参默认 true）。
/// 原样档就是可打印 ASCII 那一整段（逐位扫描见 `scripts/UnicodeScan.java`：
/// `KEEP|toUnicode(true)|0020-007e`，只一段）——换行符虽是 ASCII 也照转，
/// 所以"只转非 ASCII"那句常识不能写进契约。十六进制**小写**、最少四位。
pub fn to_unicode(s : String) -> String {
  escape_unicode(s, false)
}

///|
/// 每一位都转（`UnicodeUtil.toUnicode(String, false)`）——含 ASCII 与反斜杠本身。
pub fn to_unicode_all(s : String) -> String {
  escape_unicode(s, true)
}

///|
/// 单个码点的 `\uXXXX`（参照的 `toUnicode(char)` 与 `toUnicode(int)` **两件合一**：
/// 腿 N 行成对打这两个出口，BMP 内每一条两侧同字符串 ⇒ 没有第二条语义可承诺）。
/// 形状照参照的 `Integer.toHexString`：取低 32 位、小写十六进制、最少四位（`-1` →
/// `\uffffffff`、`0x10000` → `\u10000`，腿 N 行两位都在）。
pub fn unicode_of(cp : Int) -> String {
  "\\u" + to_hex(cp, 4)
}

///|
/// `\uXXXX` 串 → 真字符（`UnicodeUtil.toString`）。参照的认法逐条钉住：
/// **固定吃四位**（`\u12345` → 一位 + `5`）、位数不足四位或含非十六进制位 ⇒ 原样留、
/// **双反斜杠不挡它**（`\\u4e2d` → `\` + 中，腿 R 行）、十六进制大小写都认。
pub fn unicode_to_string(s : String) -> String raise TextError {
  let cs = s.iter().collect()
  let n = cs.length()
  let units : Array[Int] = []
  let mut i = 0
  while i < n {
    // 参照只认 "反斜杠 + u + 恰好四位十六进制"；位数不足、含非十六进制位都原样留，
    // 而**双反斜杠挡不住它**（`\u4e2d` → 一个反斜杠 + 中，腿 R 行）
    if cs[i] == '\\' && i + 5 < n && (cs[i + 1] == 'u' || cs[i + 1] == 'U') {
      let body = sub_chars(cs, i + 2, i + 6)
      match parse_hex(body) {
        Some(v) => {
          push_chars_units([v.unsafe_to_char()], units)
          i += 6
        }
        None => {
          units.push(cs[i].to_int())
          i += 1
        }
      }
    } else {
      push_chars_units([cs[i]], units)
      i += 1
    }
  }
  match units_to_string(units) {
    Some(r) => r
    None => raise LoneSurrogate(first_lone(units))
  }
}

///|
/// 空白字符转 `%20`，其余原样（hutool `URLUtil.encodeBlank`——挂在 URLUtil 上，但它只吃空白
/// 判定，而那条谓词整仓只有一张表，所以收在 text，与 `is_blank`/`trim` 同源）。
/// 表里 35 位逐位等价（`scripts/BlankScanLeg.java`：`isBlank`/`trim`/`cleanBlank`/
/// `encodeBlank`/`isBlankChar` 五个出口命中集完全一致）；非 BMP 一律原样。
pub fn encode_blank(s : String) -> String {
  let buf = StringBuilder()
  for c in s.iter() {
    if is_blank_char(c) {
      buf.write_string("%20")
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

// ---- 实现轮的内部件（不公开；契约面看 docs/spec/01-text.md §1.16~§1.19）----

///|
let hex_digits : Array[Char] = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
]

///|
/// 小写十六进制、最少 `width` 位。形状照参照 `Integer.toHexString(int)`：
/// 负数是 32 位补码（`-1` → `ffffffff`），正数不补到 8 位（`0x10000` → `10000`）。
fn to_hex(v : Int, width : Int) -> String {
  let mut x = v
  let nib : Array[Int] = []
  if x == 0 {
    nib.push(0)
  }
  // 8 个 nibble 封顶：负数靠算术右移高位自然填 f，但 `-1 >> 4` 永远是 `-1`，不设限就是死循环
  let mut i = 0
  while x != 0 && i < 8 {
    nib.push(x & 15)
    x = x >> 4
    i += 1
  }
  while nib.length() < width {
    nib.push(0)
  }
  let buf = StringBuilder()
  let mut j = nib.length() - 1
  while j >= 0 {
    buf.write_char(hex_digits[nib[j]])
    j -= 1
  }
  buf.to_string()
}

///|
/// 码位 → UTF-16 码元（BMP 一个、星平面两个）。参照全程按码元走，这一件是把两边对起来的支点。
fn to_units(cp : Int) -> Array[Int] {
  if cp <= 0xffff {
    [cp]
  } else {
    let v = cp - 0x10000
    [0xd800 + (v >> 10), 0xdc00 + (v & 0x3ff)]
  }
}

///|
fn is_high_surrogate(u : Int) -> Bool {
  u >= 0xd800 && u <= 0xdbff
}

///|
fn is_low_surrogate(u : Int) -> Bool {
  u >= 0xdc00 && u <= 0xdfff
}

///|
/// 码元序列 → String。**成对**代理合成码位（与参照表示同一个字符，零偏差）；
/// 落单代理本库表示不了 ⇒ 给 None，由调用方 raise（不静默丢、不替换 U+FFFD）。
fn units_to_string(units : Array[Int]) -> String? {
  let buf = StringBuilder()
  let mut i = 0
  let n = units.length()
  while i < n {
    let u = units[i]
    if is_high_surrogate(u) && i + 1 < n && is_low_surrogate(units[i + 1]) {
      buf.write_char(
        (0x10000 + ((u - 0xd800) << 10) + (units[i + 1] - 0xdc00)).unsafe_to_char(),
      )
      i += 2
    } else if u >= 0xd800 && u <= 0xdfff {
      return None
    } else {
      buf.write_char(u.unsafe_to_char())
      i += 1
    }
  }
  Some(buf.to_string())
}

///|
fn first_lone(units : Array[Int]) -> Int {
  let mut i = 0
  let n = units.length()
  while i < n {
    let u = units[i]
    if is_high_surrogate(u) && i + 1 < n && is_low_surrogate(units[i + 1]) {
      i += 2
    } else if u >= 0xd800 && u <= 0xdfff {
      return u
    } else {
      i += 1
    }
  }
  0
}

///|
fn is_hex_digit(c : Char) -> Bool {
  let x = c.to_int()
  (x >= 48 && x <= 57) || (x >= 97 && x <= 102) || (x >= 65 && x <= 70)
}

///|
fn hex_value(c : Char) -> Int {
  let x = c.to_int()
  if x >= 48 && x <= 57 {
    x - 48
  } else if x >= 97 && x <= 102 {
    x - 87
  } else {
    x - 55
  }
}

///|
fn sub_chars(cs : Array[Char], lo : Int, hi : Int) -> Array[Char] {
  let out : Array[Char] = []
  let mut i = lo
  while i < hi {
    out.push(cs[i])
    i += 1
  }
  out
}

///|
fn join_chars(cs : Array[Char]) -> String {
  let buf = StringBuilder()
  for c in cs {
    buf.write_char(c)
  }
  buf.to_string()
}

///|
fn push_chars_units(cs : Array[Char], units : Array[Int]) -> Unit {
  for c in cs {
    for u in to_units(c.to_int()) {
      units.push(u)
    }
  }
}

///|
/// 剥前导零后数位宽——这才是参照 `Integer.parseInt(body, radix)` 的抛错条件：
/// `&#xFFFFFFFF;`（8 位无前置零 ⇒ 超有符号 32 位）抛、`&#x00FFFF;` 不抛。
/// 直接用 `v > 0x7fffffff` 判在 32 位 Int 的档上是坏的：`v * 16` 先回绕成负数，判据永不成立。
fn trim_zeros(body : Array[Char]) -> Array[Char] {
  // 调用点保证非空（数字实体那两处先判 `k > digits_start`，百分号档固定取 2/4 位），
  // 所以这里不再写"空串"分支——写了就是永远走不到的死码
  let mut i = 0
  while i < body.length() - 1 && body[i] == '0' {
    i += 1
  }
  if body[i] == '0' {
    ['0'] // 全零串：留一个 0，值就是 0
  } else {
    sub_chars(body, i, body.length())
  }
}

///|
fn parse_hex(body : Array[Char]) -> Int? {
  let b = trim_zeros(body)
  if b.length() > 7 {
    return None // 腿 N 行：`&#xFFFFFFFF;` 原样留
  }
  let mut v = 0
  for c in b {
    if !is_hex_digit(c) {
      return None
    }
    v = v * 16 + hex_value(c)
  }
  Some(v)
}

///|
fn parse_dec(body : Array[Char]) -> Int? {
  let b = trim_zeros(body)
  if b.length() > 9 {
    return None // 腿 `&#99999999999;`（11 位）原样留
  }
  let mut v = 0
  for c in b {
    let x = c.to_int()
    if x < 48 || x > 57 {
      return None
    }
    v = v * 10 + (x - 48)
  }
  Some(v)
}

///|
/// 码位是否落在 `escape` 的不转义区间表里（表由 `EscapeLeg3` 对整个 BMP 逐位对撞产出）
fn keep_at(cp : Int) -> Bool {
  if cp > 0xffff {
    return false // 非 BMP 一律转：参照按码元走，两半都不属数字/大小写
  }
  let mut ok = false
  for (lo, hi) in escape_keep_ranges {
    if cp >= lo && cp <= hi {
      ok = true
    }
  }
  ok
}

///|
/// 实体转义器 = 一张查表替换器（参照那边就是 `ReplacerChain` + `LookupReplacer` 拼的同一个形状）
fn entity_escape(s : String, table : Array[(String, String)]) -> String {
  make_lookup(table).replace(s)
}

///|
/// 表里键是串（`&nbsp;` 这种），从 `cs[at]` 起能整段吃下的最长键；给 `(吃了几个码位, 替换值)`
fn longest_entity(
  table : Array[(String, String)],
  cs : Array[Char],
  at : Int,
) -> (Int, String)? {
  let mut best_len = 0
  let mut best_val = ""
  for (key, value) in table {
    let kc = key.iter().collect()
    let m = kc.length()
    if m <= best_len || at + m > cs.length() {
      continue
    }
    let mut hit = true
    let mut k = 0
    while k < m {
      if cs[at + k] != kc[k] {
        hit = false
      }
      k += 1
    }
    if hit {
      best_len = m
      best_val = value
    }
  }
  if best_len == 0 {
    None
  } else {
    Some((best_len, best_val))
  }
}

///|
/// 实体还原：数字档（`&#65;` / `&#x41;` / `&#X41;`）+ 命名档（最长键优先），都不认 ⇒ `&` 原样
fn unescape_entities(
  s : String,
  table : Array[(String, String)],
) -> String raise TextError {
  let cs = s.iter().collect()
  let n = cs.length()
  let units : Array[Int] = []
  let mut i = 0
  while i < n {
    let mut advanced = false
    if cs[i] == '&' {
      if i + 1 < n && cs[i + 1] == '#' {
        let mut k = i + 2
        let hexish = k < n && (cs[k] == 'x' || cs[k] == 'X')
        if hexish {
          k += 1
        }
        let digits_start = k
        while k < n && cs[k] != ';' {
          k += 1
        }
        if k < n && k > digits_start {
          let body = sub_chars(cs, digits_start, k)
          let val = if hexish { parse_hex(body) } else { parse_dec(body) }
          match val {
            Some(v) => {
              // 参照把值当 `(char) v` 用 ⇒ 截到低 16 位（`&#x10000;` 给 U+0000、
              // `&#1000000;` 给 U+4240，腿 N 行两档都在）
              push_chars_units([(v & 0xffff).unsafe_to_char()], units)
              i = k + 1
              advanced = true
            }
            None => ()
          }
        }
      }
      if !advanced {
        match longest_entity(table, cs, i) {
          Some((len, value)) => {
            push_chars_units(value.iter().collect(), units)
            i += len
            advanced = true
          }
          None => ()
        }
      }
      if !advanced {
        units.push(38)
        i += 1
      }
    } else {
      push_chars_units([cs[i]], units)
      i += 1
    }
  }
  match units_to_string(units) {
    Some(r) => r
    None => raise LoneSurrogate(first_lone(units))
  }
}

///|
/// `to_unicode` / `to_unicode_all` 的共用扫描：`all` 为真时一位都不留
fn escape_unicode(s : String, all : Bool) -> String {
  let buf = StringBuilder()
  for c in s.iter() {
    let cp = c.to_int()
    if !all && cp >= 0x20 && cp <= 0x7e {
      buf.write_char(c)
    } else {
      for u in to_units(cp) {
        buf.write_string("\\u")
        buf.write_string(to_hex(u, 4))
      }
    }
  }
  buf.to_string()
}
