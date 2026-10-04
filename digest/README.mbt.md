# digest

hutool `DigestUtil` 的 MoonBit 对位：MD5、SHA-256、HMAC-SHA-256，外加一段常量时间比较。

**这里的权威是规范文本，不是 hutool**：hutool-crypto 自己几乎不实现算法（它是 `javax.crypto` 门面，全模块只有 RC4/XXTEA/Vigenere 是手写位运算），所以本包对着 RFC 1321 / FIPS 180-4 / RFC 2104 实现，验收只认**官方向量**。完整边界矩阵见 [`docs/spec/05-digest.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/05-digest.md)。

输入一律按 **UTF-8 字节**参与运算。core 没有任何摘要能力，故整包自研，纯位运算、无状态、无第三方依赖。

> ⚠ 当前状态：实现未开工，函数体是 `abort`，本页示例**预期红**（期望值已对官方向量冻结）。

## MD5

```mbt check
///|
test "md5_hex RFC 1321 A.5 抽样" {
  assert_eq(@digest.md5_hex(""), "d41d8cd98f00b204e9800998ecf8427e")
  assert_eq(@digest.md5_hex("abc"), "900150983cd24fb0d6963f7d28e17f72")
  assert_eq(
    @digest.md5_hex("message digest"),
    "f96b697d7cb7938d525a2f31aaf161d0",
  )
  assert_eq(@digest.md5_bytes("abc").length(), 16)
}
```

中文输入走 UTF-8 档（不是 UTF-16、不是 GB18030——本库没有字符集表，也不打算有）：

```mbt check
///|
test "md5_hex 中文按 UTF-8" {
  assert_eq(@digest.md5_hex("中文"), "a7bac2239fcdcb3a067903d8077c4a07")
}
```

## md5_hex16：hutool 私有行为

取 32 位 hex 的**第 8~24 位**。这条不在任何 RFC 里，但 mldong 系有存量数据靠它，语义漂移等于打散用户口令校验，所以单独一条示例钉住：

```mbt check
///|
test "md5_hex16 取中段" {
  assert_eq(@digest.md5_hex16("message digest"), "7cb7938d525a2f31")
  assert_eq(@digest.md5_hex16("中文"), "9fcdcb3a067903d8")
}
```

## SHA-256

FIPS 180-4 的示例消息摘要：

```mbt check
///|
test "sha256_hex" {
  assert_eq(
    @digest.sha256_hex("abc"),
    "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
  )
  assert_eq(@digest.sha256_bytes("abc").length(), 32)
}
```

## HMAC-SHA-256

block size = 64 字节。**键长超过 64 时必须先把键哈希一次**（RFC 2104 §5）——这是实现最容易漏的一档，故单列一条：

```mbt check
///|
test "hmac_sha256_hex RFC 4231 TC2" {
  assert_eq(
    @digest.hmac_sha256_hex("Jefe", "what do ya want for nothing?"),
    "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843",
  )
}

///|
test "hmac_sha256_hex 长键先哈希" {
  assert_eq(
    @digest.hmac_sha256_hex(
      "a".repeat(80),
      "Test Using Larger Than Block-Size Key - Hash Key First",
    ),
    "7502d8b2069f64dcbca4d51628fdc86a17200b3fad268755483946baf3d99fa8",
  )
}
```

键取 **80 个 `a`**（> 64 ⇒ 走"先哈希键"分支）；期望值由本机 `hashlib` 对同一输入现算得到，与 RFC 2104 §5 的算法路径一致。

## 比较摘要用 equal_digest，别用 `==`

`Bytes` 的 `==` 是逐字节短路，签名校验场景会泄露前缀时序：

```mbt check
///|
test "equal_digest 常量时间" {
  assert_true(
    @digest.equal_digest(@digest.md5_bytes("abc"), @digest.md5_bytes("abc")),
  )
  assert_false(
    @digest.equal_digest(@digest.md5_bytes("abc"), @digest.md5_bytes("abd")),
  )
  assert_false(
    @digest.equal_digest(@digest.md5_bytes("abc"), @digest.md5_bytes("")),
  )
}
```

## 本包不做的事

SHA-1 / SHA-512 在下一批（UUID v5 依赖前者）；国密 SM3、SHA-3、AES、RSA/ECDSA、BCrypt/Argon2/PBKDF2 均未排期；也不做带状态的流式写接口（core 无 io，且那会破坏"纯函数一次调用"的可测形状）。
