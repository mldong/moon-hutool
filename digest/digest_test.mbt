// moon-hutool/digest 契约用例（黑盒）。
//
// 状态：实现未开工，**预期全红**（函数体是 abort）。期望值此刻已冻结，权威是官方向量：
// RFC 1321 附录 A.5（MD5 测试串）、FIPS 180-4 §6.1（SHA-256 示例）、RFC 2104 §5 + RFC 4231 §4（HMAC：
// TC2 短键、"键长 80 > block size 64 ⇒ 先哈希键"那一档）。
// 本机用 hashlib 对同一输入现算并核对过（MD5("abc")、SHA-256("abc")、HMAC TC1 三条与规范公布值一致），
// 不是凭记忆誊写。实现期改这些串 = 门禁 G5 拦下。

///|
test "@digest.md5 #2.1 RFC 1321 A.5 全部七条测试串" {
  inspect(@digest.md5_hex(""), content="d41d8cd98f00b204e9800998ecf8427e")
  inspect(@digest.md5_hex("a"), content="0cc175b9c0f1b6a831c399e269772661")
  inspect(@digest.md5_hex("abc"), content="900150983cd24fb0d6963f7d28e17f72")
  inspect(
    @digest.md5_hex("message digest"),
    content="f96b697d7cb7938d525a2f31aaf161d0",
  )
  inspect(
    @digest.md5_hex("abcdefghijklmnopqrstuvwxyz"),
    content="c3fcd3d76192e4007dfb496cca67e13b",
  )
  inspect(
    @digest.md5_hex(
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
    ),
    content="d174ab98d277d9f5a5611c2c9f419d9f",
  )
  inspect(
    @digest.md5_hex(
      "12345678901234567890123456789012345678901234567890123456789012345678901234567890",
    ),
    content="57edf4a22be3c955ac49da2e2107b67a",
  )
}

///|
test "@digest.md5 #2.1 输入按 UTF-8 字节（中文钉死这一档）" {
  inspect(@digest.md5_hex("中文"), content="a7bac2239fcdcb3a067903d8077c4a07")
  inspect(
    @digest.sha256_hex("中文"),
    content="72726d8818f693066ceb69afa364218b692e62ea92b385782363780f47529c21",
  )
}

///|
test "@digest.md5_hex16 #2.2 hutool 私有行为＝取 32 位 hex 的 8~24 位" {
  inspect(@digest.md5_hex16("message digest"), content="7cb7938d525a2f31")
  inspect(@digest.md5_hex16("中文"), content="9fcdcb3a067903d8")
  // 口令列常见形状 md5(salt + password)，salt 逐用户随机；此处固定串只为钉住算法读数
  inspect(
    @digest.md5_hex("salt123" + "passw0rd"),
    content="96d950b3c3b90997910b05907037133f",
  )
}

///|
test "@digest.sha256 #2.3 FIPS 180-4 示例 + 摘要长度" {
  inspect(
    @digest.sha256_hex(""),
    content="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  )
  inspect(
    @digest.sha256_hex("abc"),
    content="ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
  )
  inspect(
    @digest.sha256_hex(
      "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
    ),
    content="248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1",
  )
  assert_eq(@digest.md5_bytes("abc").length(), 16)
  assert_eq(@digest.sha256_bytes("abc").length(), 32)
  assert_eq(@digest.hmac_sha256_bytes("k", "d").length(), 32)
}

///|
test "@digest.hmac_sha256 #2.4 RFC 4231 TC2（短键）" {
  inspect(
    @digest.hmac_sha256_hex("Jefe", "what do ya want for nothing?"),
    content="5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843",
  )
}

///|
test "@digest.hmac_sha256 #2.4 键长 80 > block size 64 ⇒ 先哈希键（RFC 2104 §5）" {
  inspect(
    @digest.hmac_sha256_hex(
      "a".repeat(80),
      "Test Using Larger Than Block-Size Key - Hash Key First",
    ),
    content="7502d8b2069f64dcbca4d51628fdc86a17200b3fad268755483946baf3d99fa8",
  )
}

///|
test "@digest.equal_digest #2.5 常量时间比较" {
  let a = @digest.md5_bytes("abc")
  let b = @digest.md5_bytes("abd")
  assert_false(@digest.equal_digest(a, b))
  assert_true(@digest.equal_digest(a, @digest.md5_bytes("abc")))
  assert_false(@digest.equal_digest(a, @digest.md5_bytes("")))
}
