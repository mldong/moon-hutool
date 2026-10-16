///|
/// moon-hutool/digest —— 摘要（hutool `DigestUtil` 的 MoonBit 对位）
///
/// 契约：`docs/spec/02-digest.md`；进度：`docs/ROADMAP.md`。
///
/// **权威是规范文本，不是 hutool**：hutool-crypto 自己几乎不实现算法（它是 `javax.crypto`/JCE 门面，
/// 全模块只有 RC4/XXTEA/Vigenere 是手写位运算），所以本包对着 RFC 1321 / RFC 3174 / FIPS 180-4 / RFC 2104 / RFC 2202 实现，
/// 验收只认**官方向量**（门禁 G6）。core 无任何摘要能力（本机实测 `md5|sha256|hmac` 全树命中 0）⇒ 整包自研。
///
/// 四条实现取向（都被本机编译器裁决过，别再改回去）：
/// · **一组一组压，不物化整份副本**（10-16 第四批改造：原先是"虚拟 padded 消息"按第 i 个字节取值，
///   现在整组直接压输入、只有不足一个分组的 ≤63 字节尾巴进缓冲，见 §2.9 的那台共用状态机）；
///   长度域是 32 位两半带进位累加，所以没有"只吃 512 MiB 以内"这种隐性上限。
/// · **32 位环路全走 `UInt`**：本版 core 里 `UInt32` 不是独立类型（`unsafe_write_uint32_be` 吃的就是 `UInt`），
///   而 js 档 `Int` 只有 31 位语义 ⇒ 用 `Int` 拼字会在 js 上悄悄错。跨目标一致性由四目标 CI 判。
/// · 位运算用中缀 `& | ^ << >>`（`lsl/lsr/land/lor` 那批方法在本版已报废弃），取反没有 `~`，
///   写成 `x ^ 0xffffffff`（`not32`）。十六进制字面量**不加后缀**（`0x..u` 与 `0x..u32` 都判词法错），
///   靠返回类型推断。
/// · 常量表**按公式现算生成**（`floor(2^32·|sin(i+1)|)`、素数立方根/平方根小数部分、`2^30·√k`），不抄录；
///   抄错一个常数，官方向量当场翻脸。

///|
/// MD5 移位表（RFC 1321 §3.4，四轮各 16 条）
fn md5_shifts() -> Array[Int32] {
  [
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 5, 9, 14, 20, 5,
    9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16,
    23, 4, 11, 16, 23, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21,
  ]
}

///|
/// MD5 常数表 `K[i] = floor(2^32 × |sin(i+1)|)`（RFC 1321 §3.4，按公式现算）
fn md5_consts() -> Array[UInt32] {
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
fn sha256_consts() -> Array[UInt32] {
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
fn sha256_iv() -> Array[UInt32] {
  [
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab,
    0x5be0cd19,
  ]
}

///|
/// 增量状态机（三把摘要共用**一份**）：链字 + 不足一个算法分组（64 字节）的尾巴 + 比特长度的
/// 32 位两半 + 已收尾标记。§2.6 那条"两台 HMAC 合成一台"的取向在这里落到 padding 上：
/// 一次性入口与增量入口不许各养一份 padding 与长度位。
priv struct CtxState {
  chain : Array[UInt32]
  mut buf : Array[Byte]
  mut total_lo : UInt32
  mut total_hi : UInt32
  mut closed : Bool
}

///|
/// 新建状态：链字取各算法的 IV，缓冲清空、长度位归零、未收尾
fn ctx_new_state(iv : Array[UInt32]) -> CtxState {
  CtxState::{ chain: iv, buf: [], total_lo: 0, total_hi: 0, closed: false, }
}

///|
/// 长度位用两个 32 位无符号量带进位累加，不走 64 位移位：本版 `0x..u64` 字面量后缀判词法错，
/// 而 js 档 `Int` 只有 31 位语义（文件头那条"32 位环路全走 `UInt`"同形适用）。
/// 低半溢出 ⇒ 高半进 1。**这条进位本套用例碰不到**：`total_lo` 数的是**字节**，要 4 GiB 输入才翻一次，
/// 一百万字节档远够不着（`bits_lo` 那边才是 2^29 字节的界）。留着它不是"够用就行"，而是长度位算错
/// 在任意长消息上都会出错；这一格的覆盖欠账如实记在 spec §2.9 的变异表末尾。
fn ctx_add_len(st : CtxState, n : Int32) -> Unit {
  let old = st.total_lo
  st.total_lo = old + n.reinterpret_as_uint()
  if st.total_lo < old {
    st.total_hi = st.total_hi + 1
  }
}

///|
/// 32 位取反（本版没有 `~` 运算符）
fn not32(x : UInt32) -> UInt32 {
  x ^ 0xffffffff
}

///|
/// 32 位循环左移（`c == 0` 单列：移位量取 32 是未定义形状，不能靠运气）
fn rotl(v : UInt32, c : Int32) -> UInt32 {
  if c == 0 {
    v
  } else {
    (v << c) | (v >> (32 - c))
  }
}

///|
/// 32 位循环右移
fn rotr(v : UInt32, c : Int32) -> UInt32 {
  if c == 0 {
    v
  } else {
    (v >> c) | (v << (32 - c))
  }
}

///|
/// 分块总长：原文 ‖ 0x80 ‖ 补零 ‖ 8 字节比特长度，向上取整到 64 的倍数
fn padded_len(n : Int32) -> Int32 {
  ((n + 8) / 64 + 1) * 64
}

///|
/// 从一个分组取一个 32 位字，`le` 决定字节序（MD5 小端 / SHA 系大端）。
/// 字节一律 `Byte::to_uint` 成无符号，不做符号扩展（`Int` 那条路在 js 档只有 31 位语义）
fn word_at(block : Bytes, off : Int32, le : Bool) -> UInt32 {
  let b0 = block[off].to_uint()
  let b1 = block[off + 1].to_uint()
  let b2 = block[off + 2].to_uint()
  let b3 = block[off + 3].to_uint()
  if le {
    b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
  } else {
    (b0 << 24) | (b1 << 16) | (b2 << 8) | b3
  }
}

///|
/// 一个分组的 16 个字（三个压缩器共用的取字步骤）
fn block_words(block : Bytes, off : Int32, le : Bool) -> Array[UInt32] {
  let w : Array[UInt32] = []
  for j in 0..<16 {
    w.push(word_at(block, off + j * 4, le))
  }
  w
}

///|
/// 追加一段：① 先把上一段留下的尾巴补满一组压掉；② 整组**直接压输入**（不复制）；
/// ③ 不足一组的进缓冲。长度位由 `ctx_add_len` 累加。这三步就是"分段喂与整份喂同值"的全部内容。
fn ctx_feed(
  st : CtxState,
  compress : (Array[UInt32], Bytes, Int32) -> Unit,
  data : Bytes,
) -> Unit {
  let n = data.length()
  let mut i = 0
  if st.buf.length() > 0 {
    while i < n && st.buf.length() < 64 {
      st.buf.push(data[i])
      i = i + 1
    }
    if st.buf.length() == 64 {
      compress(st.chain, Bytes::from_array(st.buf), 0)
      st.buf = []
    }
  }
  while i + 64 <= n {
    compress(st.chain, data, i)
    i = i + 64
  }
  while i < n {
    st.buf.push(data[i])
    i = i + 1
  }
  ctx_add_len(st, n)
}

///|
/// 收尾：补 padding 与 8 字节比特长度，压完最后（一或二）个分组，返回**新的**链字数组。
/// 幂等的根据在这里——`chain` 先 `copy()`（本版 `clone` 已报废弃），`buf` 与长度位一字不动；
/// 唯一副作用是 `closed`。
///
/// 长度域的**摆法跟各算法取字的字节序一致**：MD5 取小端字 ⇒ 偏移越小越是低位；SHA 系取网络字节序
/// ⇒ 偏移越小越是高位。这条统一按大端写时，空串（长度 0）看不出错、SHA 全对、MD5 一有长度就错——
/// 只有"长度非零 + 小端"这一格才暴露，正是官方向量必须含非空串的理由（文件头那条老坑，换了机器照样成立）。
/// 只用 `UInt32` 的两半算，不碰 64 位移位。
fn ctx_finish_chain(
  st : CtxState,
  compress : (Array[UInt32], Bytes, Int32) -> Unit,
  le : Bool,
) -> Array[UInt32] {
  let chain = st.chain.copy()
  let tail = padded_len(st.buf.length())
  let bits_lo = st.total_lo << 3
  let bits_hi = (st.total_hi << 3) | (st.total_lo >> 29)
  let buf_len = st.buf.length()
  let blk : Array[Byte] = []
  for i in 0..<tail {
    let b = if i < buf_len {
      st.buf[i].to_uint()
    } else if i == buf_len {
      0x80
    } else if i < tail - 8 {
      0
    } else {
      let k = if le { i - (tail - 8) } else { tail - 1 - i }
      let half = if k < 4 { bits_lo } else { bits_hi }
      let sh = if k < 4 { k } else { k - 4 }
      (half >> (sh * 8)) & 0xff
    }
    blk.push(b.reinterpret_as_int().to_byte())
  }
  let t = Bytes::from_array(blk)
  compress(chain, t, 0)
  if tail == 128 {
    compress(chain, t, 64)
  }
  st.closed = true
  chain
}

///|
/// 链字数组 → 原始字节（`le` 跟各算法出口约定：MD5 小端、SHA-256 大端）
fn words_to_bytes(ws : Array[UInt32], le : Bool) -> Bytes {
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
fn byte_window(data : Bytes, lo : Int32, hi : Int32) -> Bytes {
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
/// MD5 初值 H(0)（RFC 1321 §3.3）
fn md5_iv() -> Array[UInt32] {
  [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]
}

///|
/// MD5 单组压缩（RFC 1321 §3.4）：一次吃一个 64 字节分组，链字**原地**更新。
/// 取字固定小端（`block_words(..., true)`）——长度域的摆法必须与它一致，见 `ctx_finish_chain`。
fn md5_compress(chain : Array[UInt32], block : Bytes, off : Int32) -> Unit {
  let s = md5_shifts()
  let k = md5_consts()
  let w = block_words(block, off, true)
  let mut a = chain[0]
  let mut b = chain[1]
  let mut c = chain[2]
  let mut d = chain[3]
  for r in 0..<64 {
    let mut f : UInt32 = 0
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
    f = f + a + k[r] + w[g]
    a = d
    d = c
    c = b
    b = b + rotl(f, s[r])
  }
  chain[0] = chain[0] + a
  chain[1] = chain[1] + b
  chain[2] = chain[2] + c
  chain[3] = chain[3] + d
}

///|
/// MD5 一次性入口 = **同一台增量机器的一个出口**（建状态 + 喂一次 + 收尾）。
/// 走这条而不是另养一份 padding，"分段与整份同值"才不是测试碰巧对上（spec §2.9）
fn md5_core(data : Bytes) -> Array[UInt32] {
  let st = ctx_new_state(md5_iv())
  ctx_feed(st, md5_compress, data)
  ctx_finish_chain(st, md5_compress, true)
}

///|
/// SHA-256 单组压缩（FIPS 180-4 §6.2.2）：一次吃一个 64 字节分组，链字**原地**更新。
/// 取字固定大端（网络字节序），与长度域的摆法同侧（见 `ctx_finish_chain`）。
fn sha256_compress(chain : Array[UInt32], block : Bytes, off : Int32) -> Unit {
  let kk = sha256_consts()
  let w = block_words(block, off, false)
  for t in 16..<64 {
    let w15 = w[t - 15]
    let w2 = w[t - 2]
    let s0 = rotr(w15, 7) ^ rotr(w15, 18) ^ (w15 >> 3)
    let s1 = rotr(w2, 17) ^ rotr(w2, 19) ^ (w2 >> 10)
    w.push(w[t - 16] + s0 + w[t - 7] + s1)
  }
  let mut a = chain[0]
  let mut b = chain[1]
  let mut c = chain[2]
  let mut d = chain[3]
  let mut e = chain[4]
  let mut f = chain[5]
  let mut g = chain[6]
  let mut hp = chain[7]
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
  chain[0] = chain[0] + a
  chain[1] = chain[1] + b
  chain[2] = chain[2] + c
  chain[3] = chain[3] + d
  chain[4] = chain[4] + e
  chain[5] = chain[5] + f
  chain[6] = chain[6] + g
  chain[7] = chain[7] + hp
}

///|
/// SHA-256 一次性入口 = 同一台增量机器的一个出口（理由同 `md5_core`，spec §2.9）
fn sha256_core(data : Bytes) -> Array[UInt32] {
  let st = ctx_new_state(sha256_iv())
  ctx_feed(st, sha256_compress, data)
  ctx_finish_chain(st, sha256_compress, false)
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
    let mut diff : UInt32 = 0
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
fn hex_digit(c : Char) -> Int32 {
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

///|
// ===== 第三批：SHA-1 与 HMAC-SHA1（八件；需求登记：本仓 Issues #1）。契约与读数见 spec 2.8 =====

///|
/// SHA-1 轮常量（FIPS 180-4 §4.2.1）：`floor(2^30 × √k)`，k = 2 / 3 / 5 / 10，每 20 轮一换
fn sha1_consts() -> Array[UInt32] {
  [0x5a827999, 0x6ed9eba1, 0x8f1bbcdc, 0xca62c1d6]
}

///|
/// SHA-1 主循环（FIPS 180-4 §6.1.2）。padded 消息与 SHA-256 同族（大端取字、共用 `make_msg`）；
/// 初值 H(0) 五字（§5.3.1）前四个与 MD5 同源，第五个是 `0xc3d2e1f0`。
///
/// 与 SHA-256 的三处结构差：① 消息表从 16 字**线性扩到 80 字**（`rotl(⊕(t-3,t-8,t-14,t-16), 1)`）；
/// ② 每轮只动 5 个链字且 `b` 左转 30 位进 `c`；③ 轮函数与常数按 20 轮一段换（`t / 20` 取段）。
fn sha1_core(data : Bytes) -> Array[UInt32] {
  let st = ctx_new_state(sha1_iv())
  ctx_feed(st, sha1_compress, data)
  ctx_finish_chain(st, sha1_compress, false)
}

///|
/// SHA-1 单组压缩（FIPS 180-4 §6.1.2）：一次吃一个 64 字节分组，链字**原地**更新。
/// 消息表从 16 字线性扩到 80 字，轮函数与常数按 20 轮一段换（`t / 20` 取段）
fn sha1_compress(chain : Array[UInt32], block : Bytes, off : Int32) -> Unit {
  let kk = sha1_consts()
  let w = block_words(block, off, false)
  for t in 16..<80 {
    w.push(rotl(w[t - 3] ^ w[t - 8] ^ w[t - 14] ^ w[t - 16], 1))
  }
  let mut a = chain[0]
  let mut b = chain[1]
  let mut c = chain[2]
  let mut d = chain[3]
  let mut e = chain[4]
  for t in 0..<80 {
    let f = if t < 20 {
      (b & c) | (not32(b) & d)
    } else if t < 40 {
      b ^ c ^ d
    } else if t < 60 {
      (b & c) | (b & d) | (c & d)
    } else {
      b ^ c ^ d
    }
    let temp = rotl(a, 5) + f + e + kk[t / 20] + w[t]
    e = d
    d = c
    c = rotl(b, 30)
    b = a
    a = temp
  }
  chain[0] = chain[0] + a
  chain[1] = chain[1] + b
  chain[2] = chain[2] + c
  chain[3] = chain[3] + d
  chain[4] = chain[4] + e
}

///|
/// SHA-1 初值 H(0) 五字（FIPS 180-4 §5.3.1）：前四个与 MD5 同源，第五个是 `0xc3d2e1f0`
fn sha1_iv() -> Array[UInt32] {
  [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0]
}

///|
/// SHA-1 原始 20 字节。与 `sha256_bytes` 同族：大端取字，共用那台增量状态机（§2.9）
/// 与那一份 padding 实现。
///
/// - Parameters: `data` 参与摘要的文本，按 **UTF-8** 成字节（全包口径）
/// - Returns: 20 字节原始摘要
/// - Note: 官方向量在两处原文互证——NIST 示例文档（FIPS 180-4 附录 A.2 指向的 `SHA1.pdf`）
///   与 RFC 3174 §7.3 的测试驱动；`"abc"` 与 56 字节两分块两条在两处逐字相同，见 spec §2.8
pub fn sha1_bytes(data : String) -> Bytes {
  words_to_bytes(sha1_core(@utf8.encode(data)), false)
}

///|
/// SHA-1 十六进制小写 40 位
/// - Raises: 无——纯计算，`data` 是文本不是可失败输入
pub fn sha1_hex(data : String) -> String {
  to_hex_lower(sha1_bytes(data))
}

///|
/// SHA-1 对**任意字节流**（`sha1_bytes` 的字节版入口，算法完全同一个）
///
/// - Parameters: `data` 任意 `Bytes`——含 `0x00`、非 UTF-8 序列、或多段拼接的结果都行
/// - Returns: 20 字节原始摘要
/// - Note: 存在的理由与 `md5_of_bytes`/`sha256_of_bytes` 两档同形（spec §2.1.1/§2.1.2）：
///   有一类输入不是任何字符串。`id` 包的 UUID v5 会对 `namespace 字节 ‖ name 字节` 做 SHA-1，
///   走 `String` 入口进不去——本批只补原语，v5 的调用点另案（spec §2.7 相位表）
pub fn sha1_of_bytes(data : Bytes) -> Bytes {
  words_to_bytes(sha1_core(data), false)
}

///|
/// HMAC-SHA-1（RFC 2104 §5）：block size 64（与 MD5/SHA-256 相同，共用同一台私有 `hmac_of` 机器）；
/// 键长 > 64 先把键哈希一次，不足右侧补零；`String` 入参按 **UTF-8** 成字节。
///
/// - Raises: 无——纯计算，`key`/`data` 是文本不是可失败输入
/// - Note: 官方向量见 spec §2.8——RFC 2202 §3 全七条，另加 NIST 示例的 `keylen=blocklen`（64 恰在
///   "不哈希键"一侧的边界上）与 `keylen=100` 两条
pub fn hmac_sha1_bytes(key : String, data : String) -> Bytes {
  hmac_sha1_of_bytes(@utf8.encode(key), @utf8.encode(data))
}

///|
/// HMAC-SHA-1 十六进制小写 40 位
/// - Raises: 无——纯计算，`key`/`data` 是文本不是可失败输入
pub fn hmac_sha1_hex(key : String, data : String) -> String {
  to_hex_lower(hmac_sha1_bytes(key, data))
}

///|
/// HMAC-SHA-1 的**字节键**档（密钥是原始二进制时用这一档；RFC 2202 与 NIST 的官方向量都是裸字节键）
/// - Raises: 无——纯计算，`key`/`data` 是字节不是可失败输入
pub fn hmac_sha1_of_bytes(key : Bytes, data : Bytes) -> Bytes {
  hmac_of(sha1_of_bytes, key, data)
}

///|
/// HMAC-SHA-1 字节键 → 十六进制小写
/// - Raises: 无——纯计算，`key`/`data` 是字节不是可失败输入
pub fn hmac_sha1_hex_of_bytes(key : Bytes, data : Bytes) -> String {
  to_hex_lower(hmac_sha1_of_bytes(key, data))
}

///|
/// 校验：重算 HMAC-SHA-1 再与给定十六进制比。比较走 §2.5 `equal_digest` 的常量时间路径；
/// 十六进制按标准解（大小写都收）；奇数长度或含非十六进制字符 ⇒ 解出空字节、长度必然不等 ⇒ 判假。
/// - Raises: 无——纯计算，`key`/`data` 是字节不是可失败输入
pub fn hmac_sha1_verify_hex(
  key : Bytes,
  data : Bytes,
  expected : String,
) -> Bool {
  equal_digest(hmac_sha1_of_bytes(key, data), hex_to_bytes(expected))
}

///|
// ===== 第四批：流式/增量入口（三把摘要 × 四件 + 一个错误档；需求登记：本仓 Issues #3）。契约与读数见 spec §2.9 =====

///|
/// 增量上下文的误用档：`finish` 之后再 `update`。
///
/// - Note: 这一档存在的理由是 issue 点名的"不能默默出错值"——收尾之后再喂如果不报错，
///   下一次 `finish` 会给一个"看着像"的摘要，而调用方无从发现。参照侧（JDK `MessageDigest.update`）
///   是随意续算的，本包不跟随；分岔两侧读数记在 spec §2.9 与 §2.7 相位表
pub suberror DigestError {
  AlreadyFinished
}

///|
/// MD5 增量上下文。对位 hutool `Digest`/`MD5Digest` 的"一次喂一块"用法，
/// 也是 `java.security.MessageDigest` / `hashlib` 的 `update`/`digest` 形状。
///
/// - Note: 存在的理由（Issues #3）：一次性入口要求先把整份递给它，做对象存储客户端时两处躲不开——
///   秒传查重要算整份 md5（文件大小没有上限），分块上传要逐块边读边喂。core 无 io，所以本包不做
///   "读流"那一层，只做**可续算的状态**，取数由调用方负责。
/// - Note: 构造只走 `Md5Ctx::new()`（`pub struct` 的字段是包内私有，外部拿不到也构造不出第二份状态）
pub struct Md5Ctx {
  priv st : CtxState
}

///|
/// SHA-1 增量上下文（与 `Md5Ctx` 逐件同形，共用同一台状态机，只差压缩器与取字字节序）
pub struct Sha1Ctx {
  priv st : CtxState
}

///|
/// SHA-256 增量上下文（同上）
pub struct Sha256Ctx {
  priv st : CtxState
}

///|
/// 建 MD5 增量上下文（链字取 RFC 1321 的 IV，缓冲与长度位清空，`closed` 为假）。
///
/// - Returns: 空上下文，此时 `finish` 给的就是空串的 MD5
/// - Note: `finish` 之后本上下文不可再喂（见 `DigestError`），要算下一条消息得新建
pub fn Md5Ctx::new() -> Md5Ctx {
  Md5Ctx::{ st: ctx_new_state(md5_iv()), }
}

///|
/// 追加一段。分块边界由本件自己处理：不足一个算法分组（64 字节）的尾巴进缓冲，
/// 跨块长度与整份喂必须逐字节等值（用例把 `1..N` 每种分段长度全档跑一遍）。
///
/// - Parameters: `data` 本段字节
/// - Raises: `DigestError::AlreadyFinished` —— 已经 `finish` 过还继续喂
pub fn Md5Ctx::update(self : Md5Ctx, data : Bytes) -> Unit raise DigestError {
  if self.st.closed {
    raise DigestError::AlreadyFinished
  }
  ctx_feed(self.st, md5_compress, data)
}

///|
/// 收尾并给出原始 16 字节摘要。**幂等**：不改动链字、缓冲与长度位，重复调用逐次同值
/// （issue 点名"幂等性请明确写在文档注释里"）。副作用只有一处——把上下文标成已收尾，
/// 于是之后的 `update` 走错误档而不是默默续算。
///
/// - Returns: 16 字节原始摘要（`md5_of_bytes` 同一张嘴）
/// - Raises: 无——纯读，幂等，重复调用不是错误
pub fn Md5Ctx::finish(self : Md5Ctx) -> Bytes {
  words_to_bytes(ctx_finish_chain(self.st, md5_compress, true), true)
}

///|
/// 收尾并出十六进制小写 32 位（= `hex(finish())`，同一条腿的第二档出口）
///
/// - Returns: 32 位小写十六进制
/// - Raises: 无——同 `finish`
pub fn Md5Ctx::finish_hex(self : Md5Ctx) -> String {
  to_hex_lower(self.finish())
}

///|
/// 建 SHA-1 增量上下文（链字取 FIPS 180-4 §5.3.1 的五字初值）
///
/// - Returns: 空上下文
pub fn Sha1Ctx::new() -> Sha1Ctx {
  Sha1Ctx::{ st: ctx_new_state(sha1_iv()), }
}

///|
/// 追加一段（形状与 `Md5Ctx::update` 逐字相同）
///
/// - Parameters: `data` 本段字节
/// - Raises: `DigestError::AlreadyFinished`
pub fn Sha1Ctx::update(self : Sha1Ctx, data : Bytes) -> Unit raise DigestError {
  if self.st.closed {
    raise DigestError::AlreadyFinished
  }
  ctx_feed(self.st, sha1_compress, data)
}

///|
/// 收尾并给出原始 20 字节摘要（幂等，口径同 `Md5Ctx::finish`）
///
/// - Returns: 20 字节原始摘要
/// - Raises: 无
pub fn Sha1Ctx::finish(self : Sha1Ctx) -> Bytes {
  words_to_bytes(ctx_finish_chain(self.st, sha1_compress, false), false)
}

///|
/// 收尾并出十六进制小写 40 位
///
/// - Returns: 40 位小写十六进制
/// - Raises: 无
pub fn Sha1Ctx::finish_hex(self : Sha1Ctx) -> String {
  to_hex_lower(self.finish())
}

///|
/// 建 SHA-256 增量上下文（链字取 FIPS 180-4 §5.3.3 的八字初值）
///
/// - Returns: 空上下文
pub fn Sha256Ctx::new() -> Sha256Ctx {
  Sha256Ctx::{ st: ctx_new_state(sha256_iv()), }
}

///|
/// 追加一段（形状与 `Md5Ctx::update` 逐字相同）
///
/// - Parameters: `data` 本段字节
/// - Raises: `DigestError::AlreadyFinished`
pub fn Sha256Ctx::update(
  self : Sha256Ctx,
  data : Bytes,
) -> Unit raise DigestError {
  if self.st.closed {
    raise DigestError::AlreadyFinished
  }
  ctx_feed(self.st, sha256_compress, data)
}

///|
/// 收尾并给出原始 32 字节摘要（幂等，口径同 `Md5Ctx::finish`）
///
/// - Returns: 32 字节原始摘要
/// - Raises: 无
pub fn Sha256Ctx::finish(self : Sha256Ctx) -> Bytes {
  words_to_bytes(ctx_finish_chain(self.st, sha256_compress, false), false)
}

///|
/// 收尾并出十六进制小写 64 位
///
/// - Returns: 64 位小写十六进制
/// - Raises: 无
pub fn Sha256Ctx::finish_hex(self : Sha256Ctx) -> String {
  to_hex_lower(self.finish())
}
