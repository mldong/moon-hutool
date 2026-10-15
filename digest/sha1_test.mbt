///|
// 第三批（SHA-1 / HMAC-SHA1）期望面：**全部由 `scripts/gen_sha1_test.py` 灌入，手打零条**。
// 权威是官方向量（2026-10-15 现读三重原文）：NIST 示例文档（FIPS 180-4 附录 A.2 指向）的 SHA-1
// 单块/两块两条与 HMAC-SHA1 的 64 恰边界、100 超块两条；RFC 3174 §7.3 四条（含 1M 个 a 与
// 恰整除 640 字节档）；RFC 2202 §3 的 HMAC-SHA1 全部七条 TC。其余读数（空串 / 中文 UTF-8 /
// 裸字节流 / 键长 65 档 / verify 档）由本机 Python hashlib/hmac 现算，脚本先与官方值逐条对撞，
// 分岔即拒绝出文件 ⇒ 期望串不经过手打这一环。
// 夹具复用 `hmac_family_test.mbt` 的 `k_of` / `rep` / `bs_of`（同包多个 `_test.mbt` 共享顶层命名空间，
// 不重复定义）；`seq` 只在本文件定义（后续要用直接引用，别复制）。
// 本批已落地（10-15，0.1.2）：契约笔冻的期望一条未改（落地笔对 `*_test.mbt` 零触碰），`digest` 包现读 27 条全绿。

///|
/// 顺序字节夹具：`0x00, 0x01, …`（NIST 案例的键形状；`rep` 表达不了等差序列，故补这一件）。
fn seq(n : Int32) -> Bytes {
  let buf = @buffer.Buffer()
  for i in 0..<n {
    buf.write_byte(i.to_byte())
  }
  buf.to_bytes()
}

///|
test "sha1 #2.8 RFC 3174 §7.3 四条经典测试串（含恰整除 640 字节与百万个 a）" {
  assert_eq(@digest.sha1_hex("abc"), "a9993e364706816aba3e25717850c26c9cd0d89d")
  assert_eq(
    @digest.sha1_hex("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
    "84983e441c3bd26ebaae4aa1f95129e5e54670f1",
  )
  assert_eq(
    @digest.sha1_hex("01234567".repeat(80)),
    "dea356a2cddd90c7a7ecedc5ebb563934f460452",
  )
  assert_eq(
    @digest.sha1_hex("a".repeat(1000000)),
    "34aa973cd4c4daa4f61eeb2bdbad27316534016f",
  )
}

///|
test "sha1 #2.8 空串 / UTF-8 中文 / 裸字节流 / 长度与 of_bytes 对拍" {
  assert_eq(@digest.sha1_hex(""), "da39a3ee5e6b4b0d3255bfef95601890afd80709")
  assert_eq(
    @digest.sha1_hex("中文"),
    "7be2d2d20c106eee0836c9bc2b939890a78e8fb3",
  )
  assert_eq(@digest.sha1_bytes("abc").length(), 20)
  assert_eq(
    @hex.encode(@digest.sha1_of_bytes(@utf8.encode("abc"))),
    "a9993e364706816aba3e25717850c26c9cd0d89d",
  )
  assert_true(
    @digest.sha1_of_bytes(@utf8.encode("中文")) ==
    @digest.sha1_bytes("中文"),
  )
  assert_eq(
    @hex.encode(
      @digest.sha1_of_bytes(
        Bytes::from_array([
          0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b,
          0x0c, 0x0d, 0x0e, 0x0f,
        ]),
      ),
    ),
    "56178b86a57fac22899a9964185c2cc96e7da589",
  )
}

///|
test "hmac_sha1 #2.8 RFC 2202 §3 全部七条 TC（裸字节键与数据）" {
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(rep(20, 0x0b), k_of("Hi There")),
    "b617318655057264e28bc0b6fb378c8ef146be00",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(
      k_of("Jefe"),
      k_of("what do ya want for nothing?"),
    ),
    "effcdf6ae5eb2fa2d27416d5f184df9c259a7c79",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(rep(20, 0xaa), rep(50, 0xdd)),
    "125d7342b9ac11cd91a39af48aa17b4f63f175d3",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(
      bs_of([
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
        22, 23, 24, 25,
      ]),
      rep(50, 0xcd),
    ),
    "4c9007f4026250c6bc8414f9bf50c86c2d7235da",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(rep(20, 0x0c), k_of("Test With Truncation")),
    "4c1a03424b55e07fe7f27be1d58bb9324a9a5a04",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(
      rep(80, 0xaa),
      k_of("Test Using Larger Than Block-Size Key - Hash Key First"),
    ),
    "aa4ae5e15272d00e95705637ce8a3b55ed402112",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(
      rep(80, 0xaa),
      k_of(
        "Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data",
      ),
    ),
    "e8e99d0f45237d786d6bbaa7965c7808bbff1a91",
  )
}

///|
test "hmac_sha1 #2.8 NIST 示例两档（keylen=blocklen 64 恰边界 / keylen=100 超块）" {
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(
      seq(0x40),
      k_of("Sample message for keylen=blocklen"),
    ),
    "5fd596ee78d5553c8ff4e72d266dfd192366da29",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(
      seq(100),
      k_of("Sample message for keylen=blocklen"),
    ),
    "2d51b2f7750e410584662e38f133435f4c4fd42a",
  )
}

///|
test "hmac_sha1 #2.8 键长 65 档 + String 档与字节档同读" {
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(rep(65, 0x0b), k_of("Hi There")),
    "29daa9e9cc4b9f094829dcd403c06927d8a95393",
  )
  assert_eq(
    @digest.hmac_sha1_hex("key", ""),
    "f42bb0eeb018ebbd4597ae7213711ec60760843f",
  )
  assert_eq(
    @digest.hmac_sha1_hex("密钥K", "中文数据"),
    "a4668d552fd5e64c9c27cf926300ecc316d87ef2",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(
      k_of("Jefe"),
      k_of("what do ya want for nothing?"),
    ),
    @digest.hmac_sha1_hex("Jefe", "what do ya want for nothing?"),
  )
}

///|
test "hmac_sha1 #2.8 verify（真 / 改一位 / 大写 / 非十六进制 / 奇数长度）" {
  let k = k_of("Jefe")
  let d = k_of("what do ya want for nothing?")
  assert_eq(
    @digest.hmac_sha1_verify_hex(
      k, d, "effcdf6ae5eb2fa2d27416d5f184df9c259a7c79",
    ),
    true,
  )
  assert_eq(
    @digest.hmac_sha1_verify_hex(
      k, d, "effcdf6ae5eb2fa2d27416d5f184df9c259a7c7a",
    ),
    false,
  )
  assert_eq(
    @digest.hmac_sha1_verify_hex(
      k, d, "EFFCDF6AE5EB2FA2D27416D5F184DF9C259A7C79",
    ),
    true,
  )
  assert_eq(
    @digest.hmac_sha1_verify_hex(
      k, d, "zffcdf6ae5eb2fa2d27416d5f184df9c259a7c79",
    ),
    false,
  )
  assert_eq(
    @digest.hmac_sha1_verify_hex(
      k, d, "effcdf6ae5eb2fa2d27416d5f184df9c259a7c7",
    ),
    false,
  )
}
