///|
/// moon-hutool/digest —— 摘要（hutool `DigestUtil` 的 MoonBit 对位）
///
/// 契约：`docs/spec/02-digest.md`；进度：`docs/ROADMAP.md`。
///
/// **权威是规范文本，不是 hutool**：hutool-crypto 自己几乎不实现算法（它是 `javax.crypto`/JCE 门面，
/// 全模块只有 RC4/XXTEA/Vigenere 是手写位运算），所以本包对着 RFC 1321 / FIPS 180-4 / RFC 2104 实现，
/// 验收只认**官方向量**（门禁 G6）。core 无任何摘要能力（本机实测 `md5|sha256|hmac` 全树命中 0）⇒ 整包自研。
///
/// 四条实现取向（都被本机编译器裁决过，别再改回去）：
/// · **零分配压缩**：不物化 padded 副本，按"虚拟消息的第 i 个字节"取值（`pad_byte`/`pad_word`）；
///   长度域用 `UInt64` 编码，所以没有"只吃 512 MiB 以内"这种隐性上限。
/// · **32 位环路全走 `UInt`**：本版 core 里 `UInt32` 不是独立类型（`unsafe_write_uint32_be` 吃的就是 `UInt`），
///   而 js 档 `Int` 只有 31 位语义 ⇒ 用 `Int` 拼字会在 js 上悄悄错。跨目标一致性由四目标 CI 判。
/// · 位运算用中缀 `& | ^ << >>`（`lsl/lsr/land/lor` 那批方法在本版已报废弃），取反没有 `~`，
///   写成 `x ^ 0xffffffff`（`not32`）。十六进制字面量**不加后缀**（`0x..u` 与 `0x..u32` 都判词法错），
///   靠返回类型推断。
/// · 常量表**按公式现算生成**（`floor(2^32·|sin(i+1)|)`、素数立方根/平方根小数部分），不抄录；
///   抄错一个常数，官方向量当场翻脸。

///|
/// MD5 移位表（RFC 1321 §3.4，四轮各 16 条）
fn md5_shifts() -> Array[Int] {
  [
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 5, 9, 14, 20, 5,
    9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16,
    23, 4, 11, 16, 23, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21,
  ]
}

///|
/// MD5 常数表 `K[i] = floor(2^32 × |sin(i+1)|)`（RFC 1321 §3.4，按公式现算）
fn md5_consts() -> Array[UInt] {
  [
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613,
    0xfd469501, 0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 0x6b901122, 0xfd987193,
    0xa679438e, 0x49b40821, 0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d,
    0x02441453, 0xd8a1e681, 0xe7d3fbc8, 0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a, 0xfffa3942, 0x8771f681, 0x6d9d6122,
    0xfde5380c, 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70, 0x289b7ec6, 0xeaa127fa,
    0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665, 0xf4292244,
    0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, 0xf7537e82, 0xbd3af235, 0x2ad7d2bb,
    0xeb86d391,
  ]
}

///|
/// SHA-256 常数表：前 64 个素数立方根的小数部分 × 2^32（FIPS 180-4 §4.2.2，现算）
fn sha256_consts() -> Array[UInt] {
  [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4,
    0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe,
    0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f,
    0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc,
    0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
    0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116,
    0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7,
    0xc67178f2,
  ]
}

///|
/// SHA-256 初值 H：前 8 个素数平方根的小数部分 × 2^32（FIPS 180-4 §5.3.3，现算）
fn sha256_iv() -> Array[UInt] {
  [
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab,
    0x5be0cd19,
  ]
}

///|
/// 虚拟 padded 消息：原文 + 总长 + 比特长度的 32 位两半（都不物化副本）
priv struct Msg {
  data : Bytes
  n : Int
  total : Int
  bits_lo : UInt
  bits_hi : UInt
}

///|
/// 组装虚拟消息。`bits_lo/hi` = `n × 8` 的低/高 32 位，用 `UInt` 的溢出与移位取，
/// 因此与宿主 `Int` 位宽无关（js 档 31 位也不炸）
fn make_msg(data : Bytes) -> Msg {
  let n = data.length()
  let nu = n.reinterpret_as_uint()
  Msg::{ data, n, total: padded_len(n), bits_lo: nu << 3, bits_hi: nu >> 29, }
}

///|
/// 32 位取反（本版没有 `~` 运算符）
fn not32(x : UInt) -> UInt {
  x ^ 0xffffffff
}

///|
/// 32 位循环左移（`c == 0` 单列：移位量取 32 是未定义形状，不能靠运气）
fn rotl(v : UInt, c : Int) -> UInt {
  if c == 0 {
    v
  } else {
    (v << c) | (v >> (32 - c))
  }
}

///|
/// 32 位循环右移
fn rotr(v : UInt, c : Int) -> UInt {
  if c == 0 {
    v
  } else {
    (v >> c) | (v << (32 - c))
  }
}

///|
/// 分块总长：原文 ‖ 0x80 ‖ 补零 ‖ 8 字节比特长度，向上取整到 64 的倍数
fn padded_len(n : Int) -> Int {
  ((n + 8) / 64 + 1) * 64
}

///|
/// 取"虚拟 padded 消息"的第 `i` 个字节（不物化副本）；长度域按大端摊在末尾 8 字节，
/// 各算法再按自己的字节序取字
fn pad_byte(msg : Msg, i : Int, le : Bool) -> UInt {
  let n = msg.n
  if i < n {
    msg.data[i].to_uint()
  } else if i == n {
    0x80
  } else if i < msg.total - 8 {
    0
  } else {
    // 末尾 8 字节是"比特长度"，**摆法跟各算法取字的字节序一致**：
    // MD5 取小端字 ⇒ 偏移越小越是低位；SHA-256 取网络字节序 ⇒ 偏移越小越是高位。
    // 这条统一按大端写时，空串（长度 0）看不出错、SHA 全对、MD5 一有长度就错——
    // 只有"长度非零 + 小端"这一格才暴露，正是官方向量必须含非空串的理由。
    // 只用 UInt 的两半算，不碰 64 位移位（本版 core 的 0x..u64 字面量后缀判词法错，
    // 而 Int 在 js 档只有 31 位）。
    let k = if le { i - (msg.total - 8) } else { msg.total - 1 - i }
    let half = if k < 4 { msg.bits_lo } else { msg.bits_hi }
    let sh = if k < 4 { k } else { k - 4 }
    (half >> (sh * 8)) & 0xff
  }
}

///|
/// 从虚拟消息取一个 32 位字，`le` 决定字节序（MD5 小端 / SHA-256 大端）
fn pad_word(msg : Msg, off : Int, le : Bool) -> UInt {
  let b0 = pad_byte(msg, off, le)
  let b1 = pad_byte(msg, off + 1, le)
  let b2 = pad_byte(msg, off + 2, le)
  let b3 = pad_byte(msg, off + 3, le)
  if le {
    b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
  } else {
    (b0 << 24) | (b1 << 16) | (b2 << 8) | b3
  }
}

///|
/// 链字数组 → 原始字节（`le` 跟各算法出口约定：MD5 小端、SHA-256 大端）
fn words_to_bytes(ws : Array[UInt], le : Bool) -> Bytes {
  let buf = @buffer.Buffer()
  let shifts = if le { [0, 8, 16, 24] } else { [24, 16, 8, 0] }
  for w in ws {
    for s in shifts {
      buf.write_byte(((w >> s) & 0xff).reinterpret_as_int().to_byte())
    }
  }
  buf.to_bytes()
}

///|
/// 取字节的 `[lo, hi)` 窗口（`md5_hex16` 用；不用切片语法，避开下标口径歧义）
fn byte_window(data : Bytes, lo : Int, hi : Int) -> Bytes {
  let buf = @buffer.Buffer()
  for i in lo..<hi {
    buf.write_byte(data[i])
  }
  buf.to_bytes()
}

///|
/// 原始字节 → 小写十六进制（`@hex.encode` 的大小写档不赌，显式落小写）
fn to_hex_lower(data : Bytes) -> String {
  @hex.encode(data).to_lower()
}

///|
/// MD5 主循环（RFC 1321 §3.4）
fn md5_core(data : Bytes) -> Array[UInt] {
  let msg = make_msg(data)
  let total = msg.total
  let s = md5_shifts()
  let k = md5_consts()
  let mut a0 : UInt = 0x67452301
  let mut b0 : UInt = 0xefcdab89
  let mut c0 : UInt = 0x98badcfe
  let mut d0 : UInt = 0x10325476
  for chunk in 0..<(total / 64) {
    let base = chunk * 64
    let mut a = a0
    let mut b = b0
    let mut c = c0
    let mut d = d0
    for r in 0..<64 {
      let mut f : UInt = 0
      let mut g = 0
      if r < 16 {
        f = (b & c) | (not32(b) & d)
        g = r
      } else if r < 32 {
        f = (d & b) | (not32(d) & c)
        g = (5 * r + 1) % 16
      } else if r < 48 {
        f = b ^ c ^ d
        g = (3 * r + 5) % 16
      } else {
        f = c ^ (b | not32(d))
        g = 7 * r % 16
      }
      f = f + a + k[r] + pad_word(msg, base + g * 4, true)
      a = d
      d = c
      c = b
      b = b + rotl(f, s[r])
    }
    a0 = a0 + a
    b0 = b0 + b
    c0 = c0 + c
    d0 = d0 + d
  }
  [a0, b0, c0, d0]
}

///|
/// SHA-256 主循环（FIPS 180-4 §6.2.2）
fn sha256_core(data : Bytes) -> Array[UInt] {
  let msg = make_msg(data)
  let total = msg.total
  let kk = sha256_consts()
  let mut h = sha256_iv()
  for chunk in 0..<(total / 64) {
    let base = chunk * 64
    let w : Array[UInt] = []
    for j in 0..<16 {
      w.push(pad_word(msg, base + j * 4, false))
    }
    for t in 16..<64 {
      let w15 = w[t - 15]
      let w2 = w[t - 2]
      let s0 = rotr(w15, 7) ^ rotr(w15, 18) ^ (w15 >> 3)
      let s1 = rotr(w2, 17) ^ rotr(w2, 19) ^ (w2 >> 10)
      w.push(w[t - 16] + s0 + w[t - 7] + s1)
    }
    let mut a = h[0]
    let mut b = h[1]
    let mut c = h[2]
    let mut d = h[3]
    let mut e = h[4]
    let mut f = h[5]
    let mut g = h[6]
    let mut hp = h[7]
    for t in 0..<64 {
      let s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25)
      let ch = (e & f) | (not32(e) & g)
      let temp1 = hp + s1 + ch + kk[t] + w[t]
      let s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22)
      let maj = (a & b) | (a & c) | (b & c)
      let temp2 = s0 + maj
      hp = g
      g = f
      f = e
      e = d + temp1
      d = c
      c = b
      b = a
      a = temp1 + temp2
    }
    h = [
      h[0] + a,
      h[1] + b,
      h[2] + c,
      h[3] + d,
      h[4] + e,
      h[5] + f,
      h[6] + g,
      h[7] + hp,
    ]
  }
  h
}

///|
/// MD5 原始 16 字节（RFC 1321）
pub fn md5_bytes(data : String) -> Bytes {
  words_to_bytes(md5_core(@utf8.encode(data)), true)
}

///|
/// MD5 对**任意字节流**（`md5_bytes` 的字节版入口，算法完全同一个）
///
/// - Parameters: `data` 任意 `Bytes`——含 `0x00`、非 UTF-8 序列、或多段拼接的结果都行
/// - Returns: 16 字节原始摘要
/// - Note: 存在的理由是 `id.uuid_v3` 要摘要 `namespace 字节 ‖ name 字节` 这种**拼接流**，
///   它不是任何字符串，走 `String` 入口进不去（spec 2.5）。同一输入下
///   `md5_of_bytes(utf8(s)) == md5_bytes(s)`，用例里带这条对拍断言
pub fn md5_of_bytes(data : Bytes) -> Bytes {
  words_to_bytes(md5_core(data), true)
}

///|
/// MD5 十六进制小写 32 位（hutool `md5Hex`）
pub fn md5_hex(data : String) -> String {
  to_hex_lower(md5_bytes(data))
}

///|
/// MD5 中段 16 位（hutool `md5Hex16` = 取 32 位 hex 的第 8~24 位）
///
/// ⚠ 这是 **hutool 的私有行为**，不在任何 RFC 里；不少项目拿它当短摘要或口令列存储，
/// 语义漂移会打散存量数据 ⇒ 期望值对着 v5-master 反推后冻结（spec 2.2）。
/// 等价写法：hex 的第 8~24 位 == 原始字节第 4~12 字节的 hex，这里走后者，避开字符串切片口径
pub fn md5_hex16(data : String) -> String {
  to_hex_lower(byte_window(md5_bytes(data), 4, 12))
}

///|
/// SHA-256 原始 32 字节（FIPS 180-4）
pub fn sha256_bytes(data : String) -> Bytes {
  words_to_bytes(sha256_core(@utf8.encode(data)), false)
}

///|
/// SHA-256 十六进制小写 64 位（hutool `sha256Hex`）
pub fn sha256_hex(data : String) -> String {
  to_hex_lower(sha256_bytes(data))
}

///|
/// SHA-256 对**任意字节流**（`sha256_bytes` 的字节版入口，算法完全同一个）
///
/// - Parameters: `data` 任意 `Bytes`——含 `0x00`、非 UTF-8 序列、或多段拼接的结果都行
/// - Returns: 32 字节原始摘要
/// - Note: 存在的有两条：HMAC 内层要拼原始字节；`codec.b58_check_*` 要对**二进制 payload**
///   做双 SHA-256（Base58Check 的校验位），那也不是任何字符串（spec 2.1.2）。同一输入下
///   `sha256_of_bytes(utf8(s)) == sha256_bytes(s)`，用例里带这条对拍断言
pub fn sha256_of_bytes(data : Bytes) -> Bytes {
  words_to_bytes(sha256_core(data), false)
}

///|
/// HMAC-SHA-256（RFC 2104 §5）：block size 64；键长 > 64 先把键哈希一次，不足右侧补零；
/// `H((key ⊕ opad) ‖ H((key ⊕ ipad) ‖ message))`
///
/// ⚠ 字符串入参一律按 **UTF-8** 成字节。`String::to_bytes()` 打的是 UTF-16 小端码元
/// （core `builtin/string.mbt`，已被标废弃），每个 ASCII 字符都会摊成 2 字节，
/// 任何输入都错——这一格是被 README 里 RFC 4231 TC2 那条 ASCII 用例逮住的，不是中文用例。
pub fn hmac_sha256_bytes(key : String, data : String) -> Bytes {
  hmac_sha256_of_bytes(@utf8.encode(key), @utf8.encode(data))
}

///|
/// HMAC-SHA-256 十六进制小写
pub fn hmac_sha256_hex(key : String, data : String) -> String {
  to_hex_lower(hmac_sha256_bytes(key, data))
}

///|
/// 常量时间比较两段摘要（签名校验必用：`==` 对 `Bytes` 逐字节短路，会泄露前缀时序）。
/// 长度不等直接判假——长度不是秘密，本函数要防的是逐字节比较的早退。
pub fn equal_digest(a : Bytes, b : Bytes) -> Bool {
  let n = a.length()
  if n != b.length() {
    false
  } else {
    let mut diff : UInt = 0
    for i in 0..<n {
      diff = diff ^ (a[i].to_uint() ^ b[i].to_uint())
    }
    diff == 0
  }
}

///|
// ===== 第二批：HMAC 家族（MD5 全套 + 字节键档 + verify）。契约与读数见 spec 2.7 =====

///|
/// HMAC-MD5（RFC 2104 §5，块长 64）。对位 hutool `HMac(HmacAlgorithm.HmacMD5, key)` 的一次性用法。
/// - Raises: 无——纯计算，`key`/`data` 是字节不是可失败输入
pub fn hmac_md5_bytes(key : String, data : String) -> Bytes {
  hmac_md5_of_bytes(@utf8.encode(key), @utf8.encode(data))
}

///|
/// HMAC-MD5 十六进制小写。对位 `HMac#digestHex`。
/// - Raises: 无——纯计算，`key`/`data` 是字节不是可失败输入
pub fn hmac_md5_hex(key : String, data : String) -> String {
  to_hex_lower(hmac_md5_bytes(key, data))
}

///|
/// HMAC-MD5 的**字节键**档。对位 `new HMac(HmacAlgorithm.HmacMD5, byte[] key)`——密钥可以是任意字节（RFC 4231 的官方向量全是裸字节键），字符串档表达不了那一半。
/// - Raises: 无——纯计算，`key`/`data` 是字节不是可失败输入
pub fn hmac_md5_of_bytes(key : Bytes, data : Bytes) -> Bytes {
  hmac_of(md5_of_bytes, key, data)
}

///|
/// HMAC-MD5 字节键 → 十六进制小写
/// - Raises: 无——纯计算，`key`/`data` 是字节不是可失败输入
pub fn hmac_md5_hex_of_bytes(key : Bytes, data : Bytes) -> String {
  to_hex_lower(hmac_md5_of_bytes(key, data))
}

///|
/// HMAC-SHA-256 的字节键档（与已有 `hmac_sha256_bytes(String, String)` 同一张嘴，只是不再假定键是文本）
/// - Raises: 无——纯计算，`key`/`data` 是字节不是可失败输入
pub fn hmac_sha256_of_bytes(key : Bytes, data : Bytes) -> Bytes {
  hmac_of(sha256_of_bytes, key, data)
}

///|
/// HMAC-SHA-256 字节键 → 十六进制小写
/// - Raises: 无——纯计算，`key`/`data` 是字节不是可失败输入
pub fn hmac_sha256_hex_of_bytes(key : Bytes, data : Bytes) -> String {
  to_hex_lower(hmac_sha256_of_bytes(key, data))
}

///|
/// 校验：重算 HMAC-MD5 再与给定十六进制比。对位 `HMac#verify(byte[] expected)` 的十六进制形态——
/// 比较走 `equal_digest`（常量时间）。十六进制按标准解：**大小写都收**（别的工具贴来的大写串应当验得过），
/// 奇数长度或含非十六进制字符 ⇒ 解出空字节、长度必然不等 ⇒ 判假，不另开错误档。
/// - Raises: 无——纯计算，`key`/`data` 是字节不是可失败输入
pub fn hmac_md5_verify_hex(
  key : Bytes,
  data : Bytes,
  expected : String,
) -> Bool {
  equal_digest(hmac_md5_of_bytes(key, data), hex_to_bytes(expected))
}

///|
/// 校验：重算 HMAC-SHA-256 再与给定十六进制比（同上）
/// - Raises: 无——纯计算，`key`/`data` 是字节不是可失败输入
pub fn hmac_sha256_verify_hex(
  key : Bytes,
  data : Bytes,
  expected : String,
) -> Bool {
  equal_digest(hmac_sha256_of_bytes(key, data), hex_to_bytes(expected))
}

///|
// HMAC 的共用机器（RFC 2104 §5）：块长 64（MD5 与 SHA-256 同），键长超块先哈希一次，不足右侧补零，
// 最后 `H((key ⊕ opad) ‖ H((key ⊕ ipad) ‖ message))`。`hash` 传的是**字节进字节出**那一档，
// 所以 MD5 与 SHA-256 共用这一台机器，两把摘要不存在第二份实现。
fn hmac_of(hash : (Bytes) -> Bytes, key : Bytes, data : Bytes) -> Bytes {
  let block = 64
  let keyed = if key.length() > block { hash(key) } else { key }
  let inner = @buffer.Buffer()
  let outer = @buffer.Buffer()
  for i in 0..<block {
    let b = if i < keyed.length() { keyed[i].to_uint() } else { 0 }
    inner.write_byte((b ^ 0x36).reinterpret_as_int().to_byte())
    outer.write_byte((b ^ 0x5c).reinterpret_as_int().to_byte())
  }
  inner.write_bytes(data)
  outer.write_bytes(hash(inner.to_bytes()))
  hash(outer.to_bytes())
}

///|
// verify 档要常量时间比较，所以先把期望的十六进制解成字节再走 `equal_digest`。
// 长度不是十六进制偶数位、或含非十六进制字符 ⇒ 解成空字节（长度必然不等 ⇒ 判假），不另开错误档。
fn hex_to_bytes(hex_ : String) -> Bytes {
  let cs = hex_.to_array()
  let n = cs.length()
  let out = @buffer.Buffer()
  let mut ok = n % 2 == 0
  let mut i = 0
  while ok && i < n {
    let hi = hex_digit(cs[i])
    let lo = hex_digit(cs[i + 1])
    if hi < 0 || lo < 0 {
      ok = false
    } else {
      out.write_byte((hi * 16 + lo).to_byte())
    }
    i += 2
  }
  if ok {
    out.to_bytes()
  } else {
    @buffer.Buffer().to_bytes()
  }
}

///|
fn hex_digit(c : Char) -> Int {
  if c >= '0' && c <= '9' {
    c.to_int() - 48
  } else if c >= 'a' && c <= 'f' {
    c.to_int() - 87
  } else if c >= 'A' && c <= 'F' {
    c.to_int() - 55
  } else {
    -1
  }
}
