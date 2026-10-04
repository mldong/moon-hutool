///|
/// moon-hutool/digest —— 摘要（hutool `DigestUtil` 的 MoonBit 对位）
///
/// 契约：`docs/spec/05-digest.md`。骨架期函数体 `abort`，`moon check` 绿、`moon test` 预期红。
///
/// **权威是规范不是 hutool**：hutool-crypto 自己几乎不实现算法（是 JCE/`javax.crypto` 门面，
/// 全模块只有 RC4/XXTEA/Vigenere 是手写位运算），所以本包对着 RFC 1321 / FIPS 180-4 / RFC 2104 实现，
/// 验收只认官方向量（门禁 G6）。core 无任何 digest 能力（本机实测 `md5|sha256|hmac` 全树命中 0），
/// 故整包自研；均为纯位运算、无状态。
///
/// 输入一律按 **UTF-8 字节**参与运算（对齐 hutool `digest(String)` 的默认 charset）。

///|
/// MD5 原始 16 字节（RFC 1321）
pub fn md5_bytes(data : String) -> Bytes {
  let _ = data
  abort("moon-hutool: digest.md5_bytes 未实现（spec 05-digest #2.1）")
}

///|
/// MD5 十六进制小写 32 位（hutool `md5Hex`）
pub fn md5_hex(data : String) -> String {
  let _ = data
  abort("moon-hutool: digest.md5_hex 未实现（spec 05-digest #2.1）")
}

///|
/// MD5 中段 16 位（hutool `md5Hex16` = 取 32 位 hex 的第 8~24 位）
///
/// ⚠ 这是 **hutool/mldong 私有行为**，不在任何 RFC 里。mldong 14 栈有存量数据靠它，
/// 语义漂移等于把用户口令校验打散 ⇒ 期望值必须对着 v5-master 反推后冻结，不许凭印象
pub fn md5_hex16(data : String) -> String {
  let _ = data
  abort("moon-hutool: digest.md5_hex16 未实现（spec 05-digest #2.2）")
}

///|
/// SHA-256 原始 32 字节（FIPS 180-4）
pub fn sha256_bytes(data : String) -> Bytes {
  let _ = data
  abort("moon-hutool: digest.sha256_bytes 未实现（spec 05-digest #2.3）")
}

///|
/// SHA-256 十六进制小写 64 位（hutool `sha256Hex`）
pub fn sha256_hex(data : String) -> String {
  let _ = data
  abort("moon-hutool: digest.sha256_hex 未实现（spec 05-digest #2.3）")
}

///|
/// HMAC-SHA-256 原始 32 字节（RFC 2104，block size = 64；键长 > 64 先哈希键）
pub fn hmac_sha256_bytes(key : String, data : String) -> Bytes {
  let _ = (key, data)
  abort(
    "moon-hutool: digest.hmac_sha256_bytes 未实现（spec 05-digest #2.4）",
  )
}

///|
/// HMAC-SHA-256 十六进制小写
pub fn hmac_sha256_hex(key : String, data : String) -> String {
  let _ = (key, data)
  abort(
    "moon-hutool: digest.hmac_sha256_hex 未实现（spec 05-digest #2.4）",
  )
}

///|
/// 常量时间比较两段摘要（签名校验必用：`==` 对 `Bytes` 是短路比较，会泄露前缀时序）
pub fn equal_digest(a : Bytes, b : Bytes) -> Bool {
  let _ = (a, b)
  abort("moon-hutool: digest.equal_digest 未实现（spec 05-digest #2.5）")
}
