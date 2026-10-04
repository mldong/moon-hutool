// moon-hutool/digest 契约用例（黑盒）。
//
// 状态：**已实现并全绿**（10-04）。期望值先冻结、后实现，权威是官方向量：
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

///|
test "@digest.md5 #2.5 md5_of_bytes 任意字节流（对拍 + 拼接流绝对读数）" {
  // 对拍：同一内容走 String 入口与走 Bytes 入口必须同结果
  assert_eq(
    @hex.encode(@digest.md5_of_bytes(@utf8.encode("abc"))),
    "900150983cd24fb0d6963f7d28e17f72", // RFC 1321 A.5 的 "abc"（0cc1… 是 "a"）
  )
  assert_true(
    @digest.md5_of_bytes(@utf8.encode("中文")) == @digest.md5_bytes("中文"),
  )
  // 拼接流（id.uuid_v3 的形状）：namespace 字节 ‖ "www.example.com"
  let ns : Bytes = Bytes::from_array([
    0x6b, 0xa7, 0xb8, 0x10, 0x9d, 0xad, 0x11, 0xd1, 0x80, 0xb4, 0x00, 0xc0, 0x4f,
    0xd4, 0x30, 0xc8,
  ])
  let stream : Array[Byte] = ns.to_array()
  stream.append(@utf8.encode("www.example.com").to_array())
  assert_eq(
    @hex.encode(@digest.md5_of_bytes(Bytes::from_array(stream))),
    "5df418813aed051548a72f4a814cf09e",
  )
  // 含 0x00 的原始字节流：String 入口进不去的那一档（0..15 十六字节）
  assert_eq(
    @hex.encode(
      @digest.md5_of_bytes(
        Bytes::from_array([
          0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b,
          0x0c, 0x0d, 0x0e, 0x0f,
        ]),
      ),
    ),
    "1ac1ef01e96caf1be0d329331a4fc2a8",
  )
}

///|
test "@digest.sha256 #2.1.2 sha256_of_bytes 任意字节流（对拍 + 空流 + 含 0x00 + 双摘要）" {
  assert_eq(
    @hex.encode(@digest.sha256_of_bytes(@utf8.encode("abc"))),
    "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", // FIPS 180-4 的 "abc"
  )
  // 对拍：同一内容走 String 入口与走 Bytes 入口必须同结果
  assert_true(
    @digest.sha256_of_bytes(@utf8.encode("中文")) ==
    @digest.sha256_bytes("中文"),
  )
  assert_eq(
    @hex.encode(@digest.sha256_of_bytes(@utf8.encode(""))),
    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", // 空流也是 FIPS 的样例
  )
  // 含 0x00 的原始流：String 入口进不去的那一档
  let raw : Bytes = Bytes::from_array([
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c,
    0x0d, 0x0e, 0x0f,
  ])
  assert_eq(
    @hex.encode(@digest.sha256_of_bytes(raw)),
    "be45cb2605bf36bebde684841a28f0fd43c69850a3dce5fedba69928ee3a8991",
  )
  // codec 的 Base58Check 走的就是这条腿：version 0x00 ‖ hash160 的双摘要（前 4 字节就是校验位）
  let body : Bytes = Bytes::from_array([
    0x00, 0x2d, 0x73, 0xf6, 0xa4, 0x88, 0x5c, 0xe6, 0x21, 0x18, 0x41, 0x7e, 0xb7,
    0x3f, 0xb4, 0x05, 0xa0, 0x53, 0x9e, 0xfa, 0x21,
  ])
  assert_eq(
    @hex.encode(@digest.sha256_of_bytes(@digest.sha256_of_bytes(body))),
    "1691915ba1e735a0da235d3de9484308bc5a388ba782fba717f2ba768e26bcdc",
  )
}
