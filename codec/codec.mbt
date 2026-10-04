///|
/// moon-hutool/codec —— 编码解码（hutool `Codec` 家族的 MoonBit 对位）
///
/// 契约：`docs/spec/05-codec.md`。期望值权威在 `codec_test.mbt` 与 spec 表——改任何期望串须单独一笔
/// 并给外部读数来源（门禁 G5），实现只负责把契约里冻好的读数算出来。
///
/// 三条贯穿性规则（core 已给的三件——`encoding/base64` 标准表、`encoding/hex`、`encoding/percent`——
/// 本包一律不重新包装，见 spec §9）：
/// 1. **表的来源写死**：Base32/Base58/Base62 的读数完全由表序决定，不接受调用方传表。
/// 2. **解码默认严格**：表外字符报错并给下标；宽松只出现在名字里点明 `lenient` 的那一档。
/// 3. **空输入是合法输入**：RFC 4648 §10 的官方向量表第一条就是空串。

///|
/// 本包唯一错误面：只携带**读数**，不携带文案（同 `date`/`id` 的立场）
pub suberror CodecError {
  /// (输入原文, 第一个不在表内的字符下标)
  IllegalChar(String, Int)
  /// (输入原文, 出错的填充字符下标)
  BadPadding(String, Int)
  /// (给的值, 被违反的上界)
  RadixOutOfRange(Int, Int)
  /// 位权展开超出 `Int64`：携带输入原文
  ValueOverflow(String)
  /// Base58Check 的 4 字节校验位不符（不带读数——摘要对人没有信息量，也不指向被改过的那一位）
  ChecksumMismatch
  /// `%XX` 流解出来的字节不是合法 UTF-8：只带输入不带下标（出错位置在字节层，硬给个文本下标会指错）
  BadUtf8(String)
}

///|
/// 任意进制用的 62 字符表（`0-9` ‖ `A-Z` ‖ `a-z`，与 Base62 的 GMP 表同序）
///
/// `radix=N` 只用**前 N 个字符** ⇒ base36 里 `Z` 合法而 `z` 非法，这条是跨栈最容易漂的一处
pub let radix_alphabet : String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

///|
/// Base64 的 URL 与安全档（RFC 4648 §5 表 2：`+`→`-`、`/`→`_`）
///
/// - Parameters: `padding` 默认 `true`（保留 `=` 填充）。hutool 的默认档**不去**填充，
///   这里给 2.1 的 `false` 才是那一档——差异写在参数名旁，不让调用方猜
/// - Note: core 的 `encoding/base64` 只有标准表，这一档是真缺口（不是转发）
pub fn b64_encode_url(data : Bytes, padding? : Bool = true) -> String {
  b64_encode_with(b64_url_alphabet, data, padding)
}

///|
/// `b64_encode_url` 的逆（**严格**档）
///
/// - Raises: `CodecError.IllegalChar` —— 出现 `+` 或 `/`（这两个属于标准表，混吃是 `b64_decode_lenient` 的活）、
///   `CodecError.BadPadding` —— `=` 数量不是 0/1/2 或不在末尾
pub fn b64_decode_url(text : String) -> Bytes raise CodecError {
  b64_decode_with(text, ascii_map(b64_url_alphabet), false, false)
}

///|
/// MIME Base64（RFC 2045 §6.8：标准表、每 76 字符一行、CRLF 结尾、**最后一行后也有 CRLF**）
///
/// - Note: 行宽固定 76，不给参数——给了就等于承诺"任意行宽的 MIME"，那已经不是 MIME
pub fn b64_encode_mime(data : Bytes) -> String {
  let flat = b64_encode_with(b64_std_alphabet, data, true)
  if flat.char_length() == 0 {
    ""
  } else {
    let chars = flat.to_array()
    let buf = StringBuilder()
    let mut i = 0
    while i < chars.length() {
      let mut k = 0
      while k < 76 && i + k < chars.length() {
        buf.write_char(chars[i + k])
        k = k + 1
      }
      i = i + k
      buf.write_string("\r\n")
    }
    buf.to_string()
  }
}

///|
/// 宽松解码：`+`/`/` 与 `-`/`_` 都收、忽略空格与 CR/LF、缺失的 `=` 自己补
///
/// 这一档就是 hutool `Base64.decode` 的默认行为；**名字里必须写 `lenient`**，
/// 否则调用方会以为自己在用一个严格解码器
///
/// - Raises: `CodecError.IllegalChar`（表外字符，携带下标）、`CodecError.BadPadding`
///   （去掉空白与填充后长度 `mod 4 == 1`——那种长度不可能来自任何 Base64 流）
pub fn b64_decode_lenient(text : String) -> Bytes raise CodecError {
  b64_decode_with(text, b64_merged_map(), true, true)
}

///|
/// Base32（RFC 4648 §6 默认表 / §7 hex 表，`=` 填充）
///
/// - Parameters: `hex` 选表（`0-9A-V` 那张），`padding` 默认 `true`
pub fn b32_encode(
  data : Bytes,
  hex? : Bool = false,
  padding? : Bool = true,
) -> String {
  b32_encode_with(
    if hex {
      b32_hex_alphabet
    } else {
      b32_std_alphabet
    },
    data,
    padding,
  )
}

///|
/// Base32 解码（大小写都收——这张表天然不分大小写，而现实里常见小写）
///
/// - Raises: `CodecError.IllegalChar`、`CodecError.BadPadding`
pub fn b32_decode(text : String, hex? : Bool = false) -> Bytes raise CodecError {
  b32_decode_with(text, hex)
}

///|
/// Base58（Bitcoin 表：没有 `0`、`O`、`I`、`l`；前导零字节折成等长的前导 `1`）
pub fn b58_encode(data : Bytes) -> String {
  bN_encode(data, b58_alphabet)
}

///|
/// Base58 解码（前导 `1` 折回前导零字节）
///
/// - Raises: `CodecError.IllegalChar`（携带下标——`0OIl` 报 `@0`）
pub fn b58_decode(text : String) -> Bytes raise CodecError {
  bN_decode(text, b58_alphabet)
}

///|
/// Base58Check：`version ‖ data ‖ 双 SHA-256 的前 4 字节`，再整体 Base58
///
/// - Parameters: `version` 0..255，默认 `0`（比特币地址那一档）
/// - Note: 摘要用 `digest` 包已冻结的 SHA-256，本包不重复实现
/// - Raises: `CodecError.RadixOutOfRange`（version 越界）
pub fn b58_check_encode(
  data : Bytes,
  version? : Int = 0,
) -> String raise CodecError {
  if version < 0 || version > 255 {
    raise RadixOutOfRange(version, 255)
  }
  let parts : Array[Byte] = [version.to_byte()]
  for i in 0..<data.length() {
    parts.push(data[i])
  }
  let body = Bytes::from_array(parts)
  bN_encode(body + checksum4(body), b58_alphabet)
}

///|
/// Base58Check 解码：校验位不符就失败，绝不返回一个"看着像地址"的脏 payload
///
/// - Parameters: `version` 给了就同时校验首字节（调用方几乎都是"我知道该是哪个版本才来解"）
/// - Raises: `CodecError.BadPadding`（长度不足 5 字节，连 version ‖ 校验位都拼不出）、`CodecError.ChecksumMismatch`、
///   `CodecError.IllegalChar`（表外字符；或给了 `version` 而首字节不符，报 `@0`）
pub fn b58_check_decode(
  text : String,
  version? : Int,
) -> Bytes raise CodecError {
  let raw = bN_decode(text, b58_alphabet)
  let n = raw.length()
  // 不足 5 字节就连 version ‖ 校验位 都拼不出来
  if n < 5 {
    raise BadPadding(text, 0)
  }
  let body = byte_prefix(raw, n - 4)
  let expect = checksum4(body)
  let mut same = true
  for k in 0..<4 {
    if raw[n - 4 + k] != expect[k] {
      same = false
    }
  }
  if !same {
    raise ChecksumMismatch
  }
  let given = raw[0].to_int()
  match version {
    Some(want) => if want != given { raise IllegalChar(text, 0) }
    None => ()
  }
  let out : Array[Byte] = []
  for k in 1..<(n - 4) {
    out.push(raw[k])
  }
  Bytes::from_array(out)
}

///|
/// Base62（GMP 表 `0-9A-Za-z`；`inverted` 走大小写互换表）
pub fn b62_encode(data : Bytes, inverted? : Bool = false) -> String {
  bN_encode(data, if inverted { b62_inverted_alphabet } else { radix_alphabet })
}

///|
/// Base62 解码。两版表**互不兼容**，用错版读出的是另一个值 ⇒ 不做自动识别
///
/// - Raises: `CodecError.IllegalChar`（携带下标）
pub fn b62_decode(
  text : String,
  inverted? : Bool = false,
) -> Bytes raise CodecError {
  bN_decode(text, if inverted { b62_inverted_alphabet } else { radix_alphabet })
}

///|
/// 任意进制编码（2..62，用 `radix_alphabet` 的前 `radix` 个字符），负数出 `-` 前缀
///
/// - Note: 收 `Int64` 且明确支持负数——hutool 那侧收 `int` 且对 `MIN_VALUE` 会翻成正的算。
///   `Int64::min()` 取绝对值这一步本身仍溢出 ⇒ 按无符号位权展开，读数见 spec #6
/// - Raises: `CodecError.RadixOutOfRange(radix, 62)`
pub fn radix_encode(value : Int64, radix : Int) -> String raise CodecError {
  if radix < 2 || radix > 62 {
    raise RadixOutOfRange(radix, 62)
  }
  let table = radix_alphabet.to_array()
  // 在 UInt64 上取两补码负值：Int64::min() 取绝对值这一步本身就还是溢出
  let zero : UInt64 = 0
  let mag : UInt64 = if value < 0L {
    zero - value.reinterpret_as_uint64()
  } else {
    value.reinterpret_as_uint64()
  }
  if mag == zero {
    "0"
  } else {
    let digits : Array[Char] = []
    let base : UInt64 = radix.to_uint64()
    let mut rest = mag
    while rest > zero {
      digits.push(table[(rest % base).to_int()])
      rest = rest / base
    }
    let buf = StringBuilder()
    if value < 0L {
      buf.write_char('-')
    }
    let mut k = digits.length()
    while k > 0 {
      k = k - 1
      buf.write_char(digits[k])
    }
    buf.to_string()
  }
}

///|
/// 任意进制解码（允许一个前导 `-`）
///
/// - Raises: `CodecError.RadixOutOfRange`、`CodecError.IllegalChar`（字符不属于该 radix 的前
///   `radix` 个表字符；空串与只有 `-` 也走这条）、`CodecError.ValueOverflow`
/// - Note: **不做** hutool `parseRadix` 的"溢出自动补位"档——静默改变值比报错坏
pub fn radix_decode(text : String, radix : Int) -> Int64 raise CodecError {
  if radix < 2 || radix > 62 {
    raise RadixOutOfRange(radix, 62)
  }
  let chars = text.to_array()
  let n = chars.length()
  let neg = n > 0 && chars[0] == '-'
  let mut i = if neg { 1 } else { 0 }
  // 空串报 @0，只有 `-` 报 @1
  if i >= n {
    raise IllegalChar(text, i)
  }
  let limit : UInt64 = if neg {
    9223372036854775808
  } else {
    9223372036854775807
  }
  let base : UInt64 = radix.to_uint64()
  let zero : UInt64 = 0
  let mut acc : UInt64 = zero
  while i < n {
    let d = match radix_index(chars[i], radix) {
      Some(v) => v
      None => raise IllegalChar(text, i)
    }
    let dv : UInt64 = d.to_uint64()
    // 溢出判据：acc * base + dv 不许越过该符号侧的边界（不做 hutool 的"自动补位"）
    if acc > (limit - dv) / base {
      raise ValueOverflow(text)
    }
    acc = acc * base + dv
    i = i + 1
  }
  if neg {
    0L - acc.reinterpret_as_int64()
  } else {
    acc.reinterpret_as_int64()
  }
}

///|
/// x-www-form-urlencoded 的编码（HTML 序列化器：放行 `A-Za-z0-9*-._`、空格出 `+`、其余 `%XX` 大写）。
///
/// - Note: 与 core `encoding/percent.encode` 不是一档——那边走 RFC 3986 unreserved，
///   于是 `~` 原样出、`*` 被转义、空格出 `%20`；表单这三条都不一样（spec §7）。
///   除这三处外两档**同结果**，这条重叠区间由用例里的对拍腿钉住（门禁 G8）
pub fn form_encode(text : String) -> String {
  let _ = text
  abort("moon-hutool: codec.form_encode 未实现（spec 05-codec #7）")
}

///|
/// `form_encode` 的逆：`+` 解回空格，`%XX` 解成字节（十六进制大小写都收）
///
/// - Raises: `CodecError.IllegalChar`（`%` 后不是两位十六进制，携带 `%` 的下标）、
///   `CodecError.BadUtf8`（解出的字节不是合法 UTF-8）
/// - Note: 坏序列**报错**而不是换 U+FFFD——表单值坏掉通常是上游忘了编码
pub fn form_decode(text : String) -> String raise CodecError {
  let _ = text
  abort("moon-hutool: codec.form_decode 未实现（spec 05-codec #7）")
}

///|
/// 键值对 → 查询串：逐项 `key=value` 用 `&` 连接，键与值各走 `form_encode`
///
/// - Note: 保序、允许重复键；空数组出空串。不做 hutool 那个"charset 为 null 就不编码"的静默分档
pub fn form_build(pairs : Array[(String, String)]) -> String {
  let _ = pairs
  abort("moon-hutool: codec.form_build 未实现（spec 05-codec #7）")
}

///|
/// 查询串 → 键值对序列：按 `&` 切项（空串整体是空数组，不是一项），
/// 每项按**第一个** `=` 切；没有 `=` 时值为空串
///
/// - Note: 不给"同名键自动合成数组"那种视图——那是 Map 层语义且各栈不同，要分组自己 `match`
/// - Raises: `CodecError.IllegalChar`、`CodecError.BadUtf8`（键或值走 `form_decode`）
pub fn form_parse(query : String) -> Array[(String, String)] raise CodecError {
  let _ = query
  abort("moon-hutool: codec.form_parse 未实现（spec 05-codec #7）")
}

///|
/// URL 的七个组件（RFC 3986 §3）
///
/// `userinfo`/`host`/`path` 用空串表示"没有"；`port = -1` 表示未给端口；
/// `query`/`fragment` 用 `None` 表示**连 `?`/`#` 都没有**——这个区分决定 `to_string` 的往返恒等。
/// `Url::parse` 只切分不解码、不校验字符集（IDN 不做）
pub(all) struct Url {
  scheme : String
  userinfo : String
  host : String
  port : Int
  path : String
  query : String?
  fragment : String?
}

///|
/// 切分一个 URL 串（scheme → authority → path → query → fragment）
///
/// - Note: 不以 `//` 开头就没有 authority（`mailto:`/`urn:` 那一档），`@` 也就不是 userinfo 的分隔符
/// - Raises: `CodecError.IllegalChar`（结构不对：端口非数字、给了 `:` 而 host 为空等）、
///   `CodecError.RadixOutOfRange(port, 65535)`（端口越界）
pub fn Url::parse(text : String) -> Url raise CodecError {
  let _ = text
  abort("moon-hutool: codec.Url::parse 未实现（spec 05-codec #8）")
}

///|
/// 组件拼回字符串：**一个字都不加**（不补 scheme、不补 `/`、不写没给过的端口）
///
/// - Note: hutool 那侧靠三个 `get*WithDefault` 往输出里塞默认值，最容易漂的一档在这里被剔除
pub fn Url::to_string(self : Self) -> String {
  let _ = self
  abort("moon-hutool: codec.Url::to_string 未实现（spec 05-codec #8）")
}

///|
/// 语法归一化（RFC 3986 §6.2.2 + §5.2.4）：scheme/host 小写、默认端口省略、
/// path 点段删除、`%XX` 统一大写并把 unreserved 三字节还原、有 authority 而 path 空则补 `/`
///
/// - Note: **幂等**，且**只改写法不改语义**——末尾斜杠、`index.html` 省略、协议升级这些一律不做；
///   非法转义（如 `%zz`）原样保留，不猜
pub fn Url::normalize(self : Self) -> Url {
  let _ = self
  abort("moon-hutool: codec.Url::normalize 未实现（spec 05-codec #8）")
}

///|
/// 缺协议就补 `http://` 再解析（hutool `UrlBuilder.ofHttp` 那一档）
///
/// - Parameters: 判"有没有协议"看的是 `http://`/`https://` 前缀，**大小写不敏感**
/// - Note: 单独一条而不是让 `Url::parse` 偷偷补——猜缺失的协议是改语义，必须点名
pub fn url_of_http(text : String) -> Url raise CodecError {
  let _ = text
  abort("moon-hutool: codec.url_of_http 未实现（spec 05-codec #8）")
}

///|
/// Base64 两张表（RFC 4648 §4 标准 / §5 URL 安全）——只差 `+`/`/` 与 `-`/`_` 这两位
let b64_std_alphabet : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

///|
let b64_url_alphabet : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

///|
/// Base32 两张表（RFC 4648 §6 默认 / §7 hex）
let b32_std_alphabet : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

///|
let b32_hex_alphabet : String = "0123456789ABCDEFGHIJKLMNOPQRSTUV"

///|
/// Base58 的 Bitcoin 表：没有 `0`、`O`、`I`、`l` 这四个易混字符
let b58_alphabet : String = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

///|
/// Base62 的第二版表（hutool `Base62Codec.INVERTED`）：与 `radix_alphabet` 只差大小写顺序
let b62_inverted_alphabet : String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

///|
/// ASCII 反查表：字符码 → 表内下标，`-1` 表示表外
fn ascii_map(table : String) -> Array[Int] {
  let m : Array[Int] = []
  for _ in 0..<128 {
    m.push(-1)
  }
  let chars = table.to_array()
  for i in 0..<chars.length() {
    m[chars[i].to_int()] = i
  }
  m
}

///|
/// 宽松 Base64 的反查表：两张表的字符都收（`+`/`/` 与 `-`/`_` 都映到 62/63）
fn b64_merged_map() -> Array[Int] {
  let m = ascii_map(b64_std_alphabet)
  m[45] = 62
  m[95] = 63
  m
}

///|
/// Base32 大小写都收：这张表天然不分大小写，而现实里小写常见
fn b32_map(hex : Bool) -> Array[Int] {
  let table = if hex { b32_hex_alphabet } else { b32_std_alphabet }
  let m = ascii_map(table)
  let chars = table.to_array()
  for i in 0..<chars.length() {
    let code = chars[i].to_int()
    // 表里只有大写字母与数字：大小写都收就把 A-Z 那一格另抄一份到 a-z
    if code >= 65 && code <= 90 {
      m[code + 32] = i
    }
  }
  m
}

///|
/// 每 3 字节折 4 个 6 位组；不足 3 字节时按 `padding` 决定补不补 `=`
fn b64_encode_with(table : String, data : Bytes, padding : Bool) -> String {
  let t = table.to_array()
  let buf = StringBuilder()
  let n = data.length()
  let mut i = 0
  while i < n {
    let b0 = data[i].to_int()
    let rest = n - i
    let b1 = if rest > 1 { data[i + 1].to_int() } else { 0 }
    let b2 = if rest > 2 { data[i + 2].to_int() } else { 0 }
    buf.write_char(t[b0 >> 2])
    buf.write_char(t[((b0 & 0x03) << 4) | (b1 >> 4)])
    if rest > 1 {
      buf.write_char(t[((b1 & 0x0f) << 2) | (b2 >> 6)])
    }
    if rest > 2 {
      buf.write_char(t[b2 & 0x3f])
    }
    if rest == 1 && padding {
      buf.write_string("==")
    } else if rest == 2 && padding {
      buf.write_string("=")
    }
    i = i + 3
  }
  buf.to_string()
}

///|
/// Base64 解码的**一条主序**（spec §1 的下标口径）：
/// 从左到右扫，表外字符先报 `IllegalChar`；撞上 `=` 才校填充数量（必须正好补齐当前 4 字符组），
/// 报 `BadPadding` 并带那个 `=` 的下标；整串没有 `=` 而余数不可能时，报**余数段起始下标**
fn b64_decode_with(
  text : String,
  sextets : Array[Int],
  ignore_ws : Bool,
  auto_complete : Bool,
) -> Bytes raise CodecError {
  let chars = text.to_array()
  let n = chars.length()
  let vals : Array[Int] = []
  let mut pad_at = -1
  let mut i = 0
  while i < n {
    let c = chars[i]
    let v = c.to_int()
    if c == '=' {
      pad_at = i
      break
    } else if ignore_ws && (v == 32 || v == 9 || v == 13 || v == 10) {
      i = i + 1
    } else if v >= 128 || sextets[v] < 0 {
      raise IllegalChar(text, i)
    } else {
      vals.push(sextets[v])
      i = i + 1
    }
  }
  if pad_at >= 0 {
    let mut j = pad_at + 1
    while j < n {
      if chars[j] != '=' {
        raise BadPadding(text, pad_at)
      }
      j = j + 1
    }
  }
  let dl = vals.length()
  if pad_at >= 0 {
    let pads = n - pad_at
    let r = dl % 4
    // 合法的只有两种：没有余数（pads=0，此时不该出现 '='）与 pads 正好补齐一组
    if !(r == 2 && pads == 2) && !(r == 3 && pads == 1) {
      raise BadPadding(text, pad_at)
    }
  } else if dl % 4 == 1 || (!auto_complete && dl % 4 != 0) {
    raise BadPadding(text, dl - dl % 4)
  }
  fold_bits(vals, 6, 8)
}

///|
/// 位权折叠：每 `from` 位一组攒起来，满 `to` 位就吐一个字节（Base64 用 6/8，Base32 用 5/8）
fn fold_bits(groups : Array[Int], from : Int, to : Int) -> Bytes {
  let out : Array[Byte] = []
  let mut acc = 0
  let mut bits = 0
  for v in groups {
    acc = (acc << from) | v
    bits = bits + from
    if bits >= to {
      bits = bits - to
      out.push(((acc >> bits) & 0xff).to_byte())
      acc = acc & ((1 << bits) - 1)
    }
  }
  Bytes::from_array(out)
}

///|
/// 每 5 字节折 8 个 5 位组；末尾不足 5 字节时补零到整组，再按 `padding` 补 `=` 到 8 的倍数
fn b32_encode_with(table : String, data : Bytes, padding : Bool) -> String {
  let t = table.to_array()
  let buf = StringBuilder()
  let n = data.length()
  let mut acc = 0
  let mut bits = 0
  let mut emitted = 0
  for i in 0..<n {
    acc = (acc << 8) | data[i].to_int()
    bits = bits + 8
    while bits >= 5 {
      bits = bits - 5
      buf.write_char(t[(acc >> bits) & 0x1f])
      emitted = emitted + 1
      acc = acc & ((1 << bits) - 1)
    }
  }
  if bits > 0 {
    buf.write_char(t[(acc << (5 - bits)) & 0x1f])
    emitted = emitted + 1
  }
  if padding {
    for _ in 0..<((8 - emitted % 8) % 8) {
      buf.write_char('=')
    }
  }
  buf.to_string()
}

///|
fn b32_decode_with(text : String, hex : Bool) -> Bytes raise CodecError {
  let m = b32_map(hex)
  let chars = text.to_array()
  let n = chars.length()
  let vals : Array[Int] = []
  let mut pad_at = -1
  let mut i = 0
  while i < n {
    let c = chars[i]
    let v = c.to_int()
    if c == '=' {
      pad_at = i
      break
    } else if v >= 128 || m[v] < 0 {
      raise IllegalChar(text, i)
    } else {
      vals.push(m[v])
      i = i + 1
    }
  }
  if pad_at >= 0 {
    let mut j = pad_at + 1
    while j < n {
      if chars[j] != '=' {
        raise BadPadding(text, pad_at)
      }
      j = j + 1
    }
  }
  let dl = vals.length()
  if pad_at >= 0 {
    let pads = n - pad_at
    let r = dl % 8
    // 合法余数 2/4/5/7 各自要补 6/4/3/1 个填充；余 0 就不该有填充
    if pads != 8 - r || r == 1 || r == 3 || r == 6 {
      raise BadPadding(text, pad_at)
    }
  } else if dl % 8 == 1 || dl % 8 == 3 || dl % 8 == 6 {
    raise BadPadding(text, dl - dl % 8)
  }
  fold_bits(vals, 5, 8)
}

///|
/// 任意进制（58/62 这一类"整段大数换表"）的编码：逐字节长除法，
/// **不走 `Int64` 折位**——wasm 档的 `Int` 只有 32 位，大输入会直接溢出
fn bN_encode(data : Bytes, table : String) -> String {
  let t = table.to_array()
  let base = t.length()
  let mut num : Array[Int] = []
  for i in 0..<data.length() {
    num.push(data[i].to_int())
  }
  let digits : Array[Int] = []
  while has_nonzero(num) {
    let mut rem = 0
    let out : Array[Int] = []
    for x in num {
      let v = rem * 256 + x
      let q = v / base
      rem = v % base
      if out.length() > 0 || q > 0 {
        out.push(q)
      }
    }
    digits.push(rem)
    num = out
  }
  let buf = StringBuilder()
  // 前导零字节折成等长的表首字符（Base58 是 `1`、Base62 是 `0`）
  let mut zeros = 0
  for i in 0..<data.length() {
    if data[i].to_int() == 0 {
      zeros = zeros + 1
    } else {
      break
    }
  }
  for _ in 0..<zeros {
    buf.write_char(t[0])
  }
  let mut k = digits.length()
  while k > 0 {
    k = k - 1
    buf.write_char(t[digits[k]])
  }
  buf.to_string()
}

///|
fn has_nonzero(num : Array[Int]) -> Bool {
  let mut found = false
  for x in num {
    if x != 0 {
      found = true
    }
  }
  found
}

///|
/// 任意进制解码：表内字符逐位乘 base 加进来，累加器是**字节数组**（同样避开 Int 宽度）
fn bN_decode(text : String, table : String) -> Bytes raise CodecError {
  let t = table.to_array()
  let base = t.length()
  let m = ascii_map(table)
  let chars = text.to_array()
  let n = chars.length()
  let mut zeros = 0
  let mut i = 0
  while i < n && chars[i] == t[0] {
    zeros = zeros + 1
    i = i + 1
  }
  let acc : Array[Int] = []
  while i < n {
    let c = chars[i].to_int()
    if c >= 128 || m[c] < 0 {
      raise IllegalChar(text, i)
    }
    let mut carry = m[c]
    let mut j = acc.length()
    while j > 0 {
      j = j - 1
      let v = acc[j] * base + carry
      acc[j] = v % 256
      carry = v / 256
    }
    while carry > 0 {
      acc.insert(0, carry % 256)
      carry = carry / 256
    }
    i = i + 1
  }
  let out : Array[Byte] = []
  for _ in 0..<zeros {
    out.push(0)
  }
  for x in acc {
    out.push(x.to_byte())
  }
  Bytes::from_array(out)
}

///|
/// 双 SHA-256 的前 4 字节——Base58Check 的校验位定义
fn checksum4(body : Bytes) -> Bytes {
  take4(@digest.sha256_of_bytes(@digest.sha256_of_bytes(body)))
}

///|
fn take4(data : Bytes) -> Bytes {
  let out : Array[Byte] = []
  for i in 0..<4 {
    out.push(data[i])
  }
  Bytes::from_array(out)
}

///|
fn byte_prefix(data : Bytes, len : Int) -> Bytes {
  let out : Array[Byte] = []
  for i in 0..<len {
    out.push(data[i])
  }
  Bytes::from_array(out)
}

///|
/// 取 `radix` 个表字符的索引（表序写死在 `radix_alphabet`，base36 就是 `0-9A-Z`）
fn radix_index(c : Char, radix : Int) -> Int? {
  let chars = radix_alphabet.to_array()
  let mut found = -1
  let mut i = 0
  while i < radix {
    if chars[i] == c && found < 0 {
      found = i
    }
    i = i + 1
  }
  if found >= 0 {
    Some(found)
  } else {
    None
  }
}
