///|
// 第二批（HMAC 家族）的期望值全部由脚本从 `jdk_hmac.txt` 灌入，手打零条：那条文件是**参照腿**——
// JDK 17 自带的 `javax.crypto.Mac`（HmacMD5 / HmacSHA256，RFC 2104 的实现）在同一批夹具上的十六进制读数。
// 锚点：`key-20` 那条的 SHA-256 读数与 **RFC 4231 Case 1** 的官方向量逐字符相同（`b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7`）——
// 也就是"参照腿与官方向量同读"，这一包验收只认官方向量的规矩（门禁 G6）在这批上成立。
// **`keylen=0`（空密钥）那一档不钉**：参照腿直接 `IllegalArgumentException`，本包不承诺这一档（spec 2.7）。

///|
// 夹具构造器：字符串走 UTF-8 字节，重复字节与裸字节数组各一条
// （参照腿 JDK 那边取的就是 `String.getBytes(UTF_8)`，这里必须同编码；`to_bytes()` 是 UTF-16 小端，不能用）
fn k_of(s : String) -> Bytes {
  @utf8.encode(s)
}

///|
fn rep(n : Int, v : Int) -> Bytes {
  let buf = @buffer.Buffer()
  let mut i = 0
  while i < n {
    buf.write_byte(v.to_byte())
    i += 1
  }
  buf.to_bytes()
}

///|
fn bs_of(xs : Array[Int]) -> Bytes {
  rep_of(xs)
}

///|
fn rep_of(xs : Array[Int]) -> Bytes {
  let buf = @buffer.Buffer()
  for v in xs {
    buf.write_byte(v.to_byte())
  }
  buf.to_bytes()
}

///|
// HMAC-MD5：块长 64，键长 1/20/25/64/65/100/131 各钉一条——**64 与 65 是"要不要先把键哈希一次"的分界两侧**
test "hmac 第二批：HMAC-MD5 与键长分界" {
  assert_eq(
    @digest.hmac_md5_hex_of_bytes(
      k_of("key"),
      k_of("what do you want for lunch today"),
    ),
    "8141d87875d4fe5bcf3b6dd15343ea82",
  )
  assert_eq(
    @digest.hmac_md5_hex_of_bytes(k_of("key"), k_of("")),
    "63530468a04e386459855da0063b6596",
  )
  assert_eq(
    @digest.hmac_md5_hex_of_bytes(rep(1, 0x0b), k_of("Hi There")),
    "adb84805b88d03e5901e4b0569ce35ea",
  )
  assert_eq(
    @digest.hmac_md5_hex_of_bytes(rep(20, 0x0b), k_of("Hi There")),
    "5ccec34ea9656392457fa1ac27f08fbc",
  )
  assert_eq(
    @digest.hmac_md5_hex_of_bytes(
      rep(25, 0xaa),
      k_of(
        "Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data",
      ),
    ),
    "178516092f6c9b27f460fa5bf942dd92",
  )
  assert_eq(
    @digest.hmac_md5_hex_of_bytes(rep(64, 0x0b), k_of("Hi There")),
    "9901fb2cc405836204730f2a3d553855",
  )
  assert_eq(
    @digest.hmac_md5_hex_of_bytes(rep(65, 0x0b), k_of("Hi There")),
    "d6075bee4d9180d8d1a299295e7cc9cb",
  )
  assert_eq(
    @digest.hmac_md5_hex_of_bytes(rep(100, 0x0b), k_of("Hi There")),
    "d58f09427e8b3d99b4ee19bb24b6fc8b",
  )
  assert_eq(
    @digest.hmac_md5_hex_of_bytes(
      rep(131, 0x55),
      k_of(
        "Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data",
      ),
    ),
    "4866e1f9cef9990a828db8bf1d550891",
  )
  assert_eq(
    @digest.hmac_md5_hex_of_bytes(k_of("密钥K"), k_of("中文数据")),
    "fe38ba35a0c3901e511ad30f0dc148f0",
  )
  assert_eq(
    @digest.hmac_md5_hex_of_bytes(bs_of([0, 1, 2, 255]), bs_of([0, 128])),
    "d5f22fe9e80a3fa0acd2611f197d77a7",
  )
}

///|
// HMAC-SHA-256 的字节键档：同一批夹具，两把摘要各自钉死
test "hmac 第二批：HMAC-SHA-256 字节键档" {
  assert_eq(
    @digest.hmac_sha256_hex_of_bytes(
      k_of("key"),
      k_of("what do you want for lunch today"),
    ),
    "1330dcd834b4a882a2dd8c8c7e0b5c90c94c0646602932fd961b71a088b36495",
  )
  assert_eq(
    @digest.hmac_sha256_hex_of_bytes(k_of("key"), k_of("")),
    "5d5d139563c95b5967b9bd9a8c9b233a9dedb45072794cd232dc1b74832607d0",
  )
  assert_eq(
    @digest.hmac_sha256_hex_of_bytes(rep(1, 0x0b), k_of("Hi There")),
    "4ba8d7ff5303ea4037e322f685ce82d056ccb6432cdc00456c73ab7398ae63f8",
  )
  assert_eq(
    @digest.hmac_sha256_hex_of_bytes(rep(20, 0x0b), k_of("Hi There")),
    "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7",
  )
  assert_eq(
    @digest.hmac_sha256_hex_of_bytes(
      rep(25, 0xaa),
      k_of(
        "Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data",
      ),
    ),
    "29b6de09d3387458cc367c1447c39bd308d036e4840739600ae1f284b7d1f258",
  )
  assert_eq(
    @digest.hmac_sha256_hex_of_bytes(rep(64, 0x0b), k_of("Hi There")),
    "21cd586aeca0579d99a1c938127c92525a371f807bc5ba6eb78bc825bd4f2be3",
  )
  assert_eq(
    @digest.hmac_sha256_hex_of_bytes(rep(65, 0x0b), k_of("Hi There")),
    "727b82fba264393c5d67fd6d6ad783e9019a1fa6a857fccb70f5852f04be5d5d",
  )
  assert_eq(
    @digest.hmac_sha256_hex_of_bytes(rep(100, 0x0b), k_of("Hi There")),
    "2387be3765fbbe963f0f20860a11c0b72bf93b455e5b7efb673dc114e0a8b1ed",
  )
  assert_eq(
    @digest.hmac_sha256_hex_of_bytes(
      rep(131, 0x55),
      k_of(
        "Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data",
      ),
    ),
    "57c751724c4af88ff8e95e78e1ef4656a3d6d8061ce479c3b80e9f3a72abee9e",
  )
  assert_eq(
    @digest.hmac_sha256_hex_of_bytes(k_of("密钥K"), k_of("中文数据")),
    "93a5ca6e26d24031f3a830a62f9012bd75d17b70ada5c8d3538b949200bcf098",
  )
  assert_eq(
    @digest.hmac_sha256_hex_of_bytes(bs_of([0, 1, 2, 255]), bs_of([0, 128])),
    "d90373250b4184ad39805e6e9709f3e55f962993bce5621fc1f0c212c99b89d6",
  )
}

///|
// 三条同读：字符串键件与字节键件在 UTF-8 下必须给同一个答案（这是"新件不另起一套语义"的凭据）；verify 两条钉住"改一个字符就判假"
test "hmac 第二批：两种键形状同读 + verify" {
  assert_eq(
    @digest.hmac_md5_of_bytes(
      k_of("key"),
      k_of("what do you want for lunch today"),
    ),
    @digest.hmac_md5_bytes("key", "what do you want for lunch today"),
  )
  assert_eq(
    @digest.hmac_sha256_of_bytes(rep(20, 0x0b), k_of("Hi There")).length(),
    32,
  )
  assert_eq(
    @digest.hmac_sha256_verify_hex(
      rep(20, 0x0b),
      k_of("Hi There"),
      "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7",
    ),
    true,
  )
  assert_eq(
    @digest.hmac_sha256_verify_hex(
      rep(20, 0x0b),
      k_of("Hi There"),
      "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff8",
    ),
    false,
  )
  assert_eq(
    @digest.hmac_md5_verify_hex(
      k_of("key"),
      k_of("what do you want for lunch today"),
      "8141d87875d4fe5bcf3b6dd15343ea82",
    ),
    true,
  )
  assert_eq(
    @digest.hmac_md5_verify_hex(
      k_of("key"),
      k_of("what do you want for lunch today"),
      "8141d87875d4fe5bcf3b6dd15343ea83",
    ),
    false,
  )
  // 十六进制按标准解，大小写都收（大写档验得过——别处贴来的串不该判假）
  assert_eq(
    @digest.hmac_md5_verify_hex(
      k_of("key"),
      k_of("what do you want for lunch today"),
      "8141D87875D4FE5BCF3B6DD15343EA82",
    ),
    true,
  )
  // 非十六进制字符 / 奇数长度 ⇒ 解出空字节，长度必然不等 ⇒ 判假（不另开错误档）
  assert_eq(
    @digest.hmac_sha256_verify_hex(
      rep(20, 0x0b),
      k_of("Hi There"),
      "z0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7",
    ),
    false,
  )
  assert_eq(
    @digest.hmac_sha256_verify_hex(
      rep(20, 0x0b),
      k_of("Hi There"),
      "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff",
    ),
    false,
  )
}
