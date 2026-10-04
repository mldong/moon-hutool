///|
/// moon-hutool/codec —— 编码解码（hutool `Codec` 家族的 MoonBit 对位）
///
/// 契约：`docs/spec/05-codec.md`。本文件此刻是**签名骨架**，函数体一律 `abort("…未实现…")`：
/// `moon check` 全绿、`moon test` 本包预期红。期望值权威在 `codec_test.mbt` 与 spec 表——
/// 实现期只许把红变绿，改期望值须单独一笔并给外部读数来源（门禁 G5）。
///
/// 三条贯穿性规则（core 已给的三件——`encoding/base64` 标准表、`encoding/hex`、`encoding/percent`——
/// 本包一律不重新包装，见 spec §7）：
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
  let _ = (data, padding)
  abort("moon-hutool: codec.b64_encode_url 未实现（spec 05-codec #2.1）")
}

///|
/// `b64_encode_url` 的逆（**严格**档）
///
/// - Raises: `CodecError.IllegalChar` —— 出现 `+` 或 `/`（这两个属于标准表，混吃是 `b64_decode_lenient` 的活）、
///   `CodecError.BadPadding` —— `=` 数量不是 0/1/2 或不在末尾
pub fn b64_decode_url(text : String) -> Bytes raise CodecError {
  let _ = text
  abort("moon-hutool: codec.b64_decode_url 未实现（spec 05-codec #2.2）")
}

///|
/// MIME Base64（RFC 2045 §6.8：标准表、每 76 字符一行、CRLF 结尾、**最后一行后也有 CRLF**）
///
/// - Note: 行宽固定 76，不给参数——给了就等于承诺"任意行宽的 MIME"，那已经不是 MIME
pub fn b64_encode_mime(data : Bytes) -> String {
  let _ = data
  abort("moon-hutool: codec.b64_encode_mime 未实现（spec 05-codec #2.3）")
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
  let _ = text
  abort(
    "moon-hutool: codec.b64_decode_lenient 未实现（spec 05-codec #2.4）",
  )
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
  let _ = (data, hex, padding)
  abort("moon-hutool: codec.b32_encode 未实现（spec 05-codec #3）")
}

///|
/// Base32 解码（大小写都收——这张表天然不分大小写，而现实里常见小写）
///
/// - Raises: `CodecError.IllegalChar`、`CodecError.BadPadding`
pub fn b32_decode(text : String, hex? : Bool = false) -> Bytes raise CodecError {
  let _ = (text, hex)
  abort("moon-hutool: codec.b32_decode 未实现（spec 05-codec #3）")
}

///|
/// Base58（Bitcoin 表：没有 `0`、`O`、`I`、`l`；前导零字节折成等长的前导 `1`）
pub fn b58_encode(data : Bytes) -> String {
  let _ = data
  abort("moon-hutool: codec.b58_encode 未实现（spec 05-codec #4）")
}

///|
/// Base58 解码（前导 `1` 折回前导零字节）
///
/// - Raises: `CodecError.IllegalChar`（携带下标——`0OIl` 报 `@0`）
pub fn b58_decode(text : String) -> Bytes raise CodecError {
  let _ = text
  abort("moon-hutool: codec.b58_decode 未实现（spec 05-codec #4）")
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
  let _ = (data, version)
  abort("moon-hutool: codec.b58_check_encode 未实现（spec 05-codec #4）")
}

///|
/// Base58Check 解码：校验位不符就失败，绝不返回一个"看着像地址"的脏 payload
///
/// - Parameters: `version` 给了就同时校验首字节（调用方几乎都是"我知道该是哪个版本才来解"）
/// - Raises: `CodecError.BadPadding`（长度不足 4 字节）、`CodecError.ChecksumMismatch`、
///   `CodecError.IllegalChar`（表外字符；或给了 `version` 而首字节不符，报 `@0`）
pub fn b58_check_decode(
  text : String,
  version? : Int,
) -> Bytes raise CodecError {
  let _ = (text, version)
  abort("moon-hutool: codec.b58_check_decode 未实现（spec 05-codec #4）")
}

///|
/// Base62（GMP 表 `0-9A-Za-z`；`inverted` 走大小写互换表）
pub fn b62_encode(data : Bytes, inverted? : Bool = false) -> String {
  let _ = (data, inverted)
  abort("moon-hutool: codec.b62_encode 未实现（spec 05-codec #5）")
}

///|
/// Base62 解码。两版表**互不兼容**，用错版读出的是另一个值 ⇒ 不做自动识别
///
/// - Raises: `CodecError.IllegalChar`（携带下标）
pub fn b62_decode(
  text : String,
  inverted? : Bool = false,
) -> Bytes raise CodecError {
  let _ = (text, inverted)
  abort("moon-hutool: codec.b62_decode 未实现（spec 05-codec #5）")
}

///|
/// 任意进制编码（2..62，用 `radix_alphabet` 的前 `radix` 个字符），负数出 `-` 前缀
///
/// - Note: 收 `Int64` 且明确支持负数——hutool 那侧收 `int` 且对 `MIN_VALUE` 会翻成正的算。
///   `Int64::min()` 取绝对值这一步本身仍溢出 ⇒ 按无符号位权展开，读数见 spec #6
/// - Raises: `CodecError.RadixOutOfRange(radix, 62)`
pub fn radix_encode(value : Int64, radix : Int) -> String raise CodecError {
  let _ = (value, radix)
  abort("moon-hutool: codec.radix_encode 未实现（spec 05-codec #6）")
}

///|
/// 任意进制解码（允许一个前导 `-`）
///
/// - Raises: `CodecError.RadixOutOfRange`、`CodecError.IllegalChar`（字符不属于该 radix 的前
///   `radix` 个表字符；空串与只有 `-` 也走这条）、`CodecError.ValueOverflow`
/// - Note: **不做** hutool `parseRadix` 的"溢出自动补位"档——静默改变值比报错坏
pub fn radix_decode(text : String, radix : Int) -> Int64 raise CodecError {
  let _ = (text, radix)
  abort("moon-hutool: codec.radix_decode 未实现（spec 05-codec #6）")
}
