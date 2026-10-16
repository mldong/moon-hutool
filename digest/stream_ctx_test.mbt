///|
// 第四批（流式/增量入口，本仓 Issues #3）的期望面：官方向量是本仓已冻结那批（§2.1 RFC 1321 A.5、
// §2.3 FIPS 180-4、§2.8 NIST 示例 + RFC 3174 §7.3），跨分组边界长度没有公布值可用，一律由
// `scripts/gen_ctx_test.py` 走 Python `hashlib` 现算——**并且先用 hashlib 自己的分段腿与整份腿对撞**
// （chunk 取 1/2/7/64/65/整份六档），两级不齐就拒绝出文件。夹具与期望串手打零条。
//
// 判据摆在这里：① 长度分档 `0/1/55/56/63/64/65/119/120/1000000` 全档（`55/63/64/65/119/120` 就是
// 跨 64 字节分组边界那几档，padding 与长度位的形状差在这儿见分晓）；② 分段取 `1..N` **全档**而不是挑两档；
// ③ 一次性入口与增量入口逐字节相等（对拍）；④ `finish` 幂等，`finish` 之后再 `update` 必须是**明确报错**
// 而不是默默给一个错值（issue 点名"不能默默出错值"，本包选 raise 那一档）。

///|
// 整份 → 增量：按 `chunk` 固定分段喂完再出十六进制。`update` 会 raise（正常喂法永不到那一步），
// 所以这里把错误折成一个档名返回——返回档名而不是摘要串就是用例的红。
fn ctx_md5_all(data : Bytes, chunk : Int32) -> String {
  let ctx = @digest.Md5Ctx::new()
  let n = data.length()
  let mut i = 0
  try {
    while i < n {
      let m = if i + chunk < n { i + chunk } else { n }
      let buf = @buffer.Buffer()
      while i < m {
        buf.write_byte(data[i])
        i += 1
      }
      ctx.update(buf.to_bytes())
    }
    ctx.finish_hex()
  } catch {
    @digest.AlreadyFinished => "AlreadyFinished"
  }
}

///|
fn ctx_sha1_all(data : Bytes, chunk : Int32) -> String {
  let ctx = @digest.Sha1Ctx::new()
  let n = data.length()
  let mut i = 0
  try {
    while i < n {
      let m = if i + chunk < n { i + chunk } else { n }
      let buf = @buffer.Buffer()
      while i < m {
        buf.write_byte(data[i])
        i += 1
      }
      ctx.update(buf.to_bytes())
    }
    ctx.finish_hex()
  } catch {
    @digest.AlreadyFinished => "AlreadyFinished"
  }
}

///|
fn ctx_sha256_all(data : Bytes, chunk : Int32) -> String {
  let ctx = @digest.Sha256Ctx::new()
  let n = data.length()
  let mut i = 0
  try {
    while i < n {
      let m = if i + chunk < n { i + chunk } else { n }
      let buf = @buffer.Buffer()
      while i < m {
        buf.write_byte(data[i])
        i += 1
      }
      ctx.update(buf.to_bytes())
    }
    ctx.finish_hex()
  } catch {
    @digest.AlreadyFinished => "AlreadyFinished"
  }
}

///|
// 按一张**分段长度表**喂（"随机分段若干"档；表由脚本用确定性 LCG 生成，三档必须同值）
fn ctx_by_sizes_md5(data : Bytes, sizes : Array[Int32]) -> String {
  let ctx = @digest.Md5Ctx::new()
  let n = data.length()
  let mut i = 0
  let mut s = 0
  try {
    while i < n {
      let chunk = sizes[s]
      s = s + 1
      if s == sizes.length() {
        s = 0
      }
      let m = if i + chunk < n { i + chunk } else { n }
      let buf = @buffer.Buffer()
      while i < m {
        buf.write_byte(data[i])
        i += 1
      }
      ctx.update(buf.to_bytes())
    }
    ctx.finish_hex()
  } catch {
    @digest.AlreadyFinished => "AlreadyFinished"
  }
}

///|
fn ctx_by_sizes_sha1(data : Bytes, sizes : Array[Int32]) -> String {
  let ctx = @digest.Sha1Ctx::new()
  let n = data.length()
  let mut i = 0
  let mut s = 0
  try {
    while i < n {
      let chunk = sizes[s]
      s = s + 1
      if s == sizes.length() {
        s = 0
      }
      let m = if i + chunk < n { i + chunk } else { n }
      let buf = @buffer.Buffer()
      while i < m {
        buf.write_byte(data[i])
        i += 1
      }
      ctx.update(buf.to_bytes())
    }
    ctx.finish_hex()
  } catch {
    @digest.AlreadyFinished => "AlreadyFinished"
  }
}

///|
fn ctx_by_sizes_sha256(data : Bytes, sizes : Array[Int32]) -> String {
  let ctx = @digest.Sha256Ctx::new()
  let n = data.length()
  let mut i = 0
  let mut s = 0
  try {
    while i < n {
      let chunk = sizes[s]
      s = s + 1
      if s == sizes.length() {
        s = 0
      }
      let m = if i + chunk < n { i + chunk } else { n }
      let buf = @buffer.Buffer()
      while i < m {
        buf.write_byte(data[i])
        i += 1
      }
      ctx.update(buf.to_bytes())
    }
    ctx.finish_hex()
  } catch {
    @digest.AlreadyFinished => "AlreadyFinished"
  }
}

///|
test "Md5Ctx 长度分档：跨 64 字节分组边界的一次喂全档" {
  assert_eq(ctx_md5_all(rep(0, 97), 64), "d41d8cd98f00b204e9800998ecf8427e") // md5.L0
  assert_eq(ctx_md5_all(rep(1, 97), 64), "0cc175b9c0f1b6a831c399e269772661") // md5.L1
  assert_eq(ctx_md5_all(rep(55, 97), 64), "ef1772b6dff9a122358552954ad0df65") // md5.L55
  assert_eq(ctx_md5_all(rep(56, 97), 64), "3b0c8ac703f828b04c6c197006d17218") // md5.L56
  assert_eq(ctx_md5_all(rep(63, 97), 64), "b06521f39153d618550606be297466d5") // md5.L63
  assert_eq(ctx_md5_all(rep(64, 97), 64), "014842d480b571495a4a0363793f7367") // md5.L64
  assert_eq(ctx_md5_all(rep(65, 97), 64), "c743a45e0d2e6a95cb859adae0248435") // md5.L65
  assert_eq(ctx_md5_all(rep(119, 97), 64), "8a7bd0732ed6a28ce75f6dabc90e1613") // md5.L119
  assert_eq(ctx_md5_all(rep(120, 97), 64), "5f61c0ccad4cac44c75ff505e1f1e537") // md5.L120
  assert_eq(ctx_md5_all(k_of("abc"), 64), "900150983cd24fb0d6963f7d28e17f72") // md5.abc（官方向量）
}

///|
test "Sha1Ctx / Sha256Ctx 长度分档：同形两把摘要" {
  assert_eq(
    ctx_sha1_all(rep(0, 97), 64),
    "da39a3ee5e6b4b0d3255bfef95601890afd80709",
  ) // sha1.L0
  assert_eq(
    ctx_sha1_all(rep(1, 97), 64),
    "86f7e437faa5a7fce15d1ddcb9eaeaea377667b8",
  ) // sha1.L1
  assert_eq(
    ctx_sha1_all(rep(55, 97), 64),
    "c1c8bbdc22796e28c0e15163d20899b65621d65a",
  ) // sha1.L55
  assert_eq(
    ctx_sha1_all(rep(56, 97), 64),
    "c2db330f6083854c99d4b5bfb6e8f29f201be699",
  ) // sha1.L56
  assert_eq(
    ctx_sha1_all(rep(63, 97), 64),
    "03f09f5b158a7a8cdad920bddc29b81c18a551f5",
  ) // sha1.L63
  assert_eq(
    ctx_sha1_all(rep(64, 97), 64),
    "0098ba824b5c16427bd7a1122a5a442a25ec644d",
  ) // sha1.L64
  assert_eq(
    ctx_sha1_all(rep(65, 97), 64),
    "11655326c708d70319be2610e8a57d9a5b959d3b",
  ) // sha1.L65
  assert_eq(
    ctx_sha1_all(rep(119, 97), 64),
    "ee971065aaa017e0632a8ca6c77bb3bf8b1dfc56",
  ) // sha1.L119
  assert_eq(
    ctx_sha1_all(rep(120, 97), 64),
    "f34c1488385346a55709ba056ddd08280dd4c6d6",
  ) // sha1.L120
  assert_eq(
    ctx_sha1_all(k_of("abc"), 64),
    "a9993e364706816aba3e25717850c26c9cd0d89d",
  ) // sha1.abc（官方向量）
  assert_eq(
    ctx_sha256_all(rep(0, 97), 64),
    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  ) // sha256.L0
  assert_eq(
    ctx_sha256_all(rep(1, 97), 64),
    "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb",
  ) // sha256.L1
  assert_eq(
    ctx_sha256_all(rep(55, 97), 64),
    "9f4390f8d30c2dd92ec9f095b65e2b9ae9b0a925a5258e241c9f1e910f734318",
  ) // sha256.L55
  assert_eq(
    ctx_sha256_all(rep(56, 97), 64),
    "b35439a4ac6f0948b6d6f9e3c6af0f5f590ce20f1bde7090ef7970686ec6738a",
  ) // sha256.L56
  assert_eq(
    ctx_sha256_all(rep(63, 97), 64),
    "7d3e74a05d7db15bce4ad9ec0658ea98e3f06eeecf16b4c6fff2da457ddc2f34",
  ) // sha256.L63
  assert_eq(
    ctx_sha256_all(rep(64, 97), 64),
    "ffe054fe7ae0cb6dc65c3af9b61d5209f439851db43d0ba5997337df154668eb",
  ) // sha256.L64
  assert_eq(
    ctx_sha256_all(rep(65, 97), 64),
    "635361c48bb9eab14198e76ea8ab7f1a41685d6ad62aa9146d301d4f17eb0ae0",
  ) // sha256.L65
  assert_eq(
    ctx_sha256_all(rep(119, 97), 64),
    "31eba51c313a5c08226adf18d4a359cfdfd8d2e816b13f4af952f7ea6584dcfb",
  ) // sha256.L119
  assert_eq(
    ctx_sha256_all(rep(120, 97), 64),
    "2f3d335432c70b580af0e8e1b3674a7c020d683aa5f73aaaedfdc55af904c21c",
  ) // sha256.L120
  assert_eq(
    ctx_sha256_all(k_of("abc"), 64),
    "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
  ) // sha256.abc（官方向量）
}

///|
test "增量入口的官方向量重放：两条整块消息在两个入口上同值" {
  // FIPS 180-4 / RFC 3174 的 56 字节两分块串，和 RFC 1321 的 80 字节串：这些是本仓已冻的公布值
  assert_eq(
    ctx_sha1_all(
      k_of("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
      64,
    ),
    "84983e441c3bd26ebaae4aa1f95129e5e54670f1",
  ) // sha1.2block
  assert_eq(
    ctx_sha256_all(
      k_of("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
      64,
    ),
    "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1",
  ) // sha256.2block
  assert_eq(ctx_md5_all(rep(80, 97), 64), "b15af9cdabbaea0516866a33d8fd0f98") // md5.L80（'a'×80，provider=hashlib）
  assert_eq(
    ctx_md5_all(
      k_of("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
      64,
    ),
    "8215ef0796a20bcaaae116d3876c664a",
  ) // md5.2block（同一条 56 字节串走 md5：无公布值，provider=hashlib）
}

///|
test "增量入口的非文本夹具：中文 UTF-8 与含 0x00 的裸字节流" {
  let cn = k_of("中文")
  let raw = bs_of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])
  assert_eq(ctx_md5_all(cn, 64), "a7bac2239fcdcb3a067903d8077c4a07") // md5.cn
  assert_eq(ctx_sha1_all(cn, 64), "7be2d2d20c106eee0836c9bc2b939890a78e8fb3") // sha1.cn
  assert_eq(
    ctx_sha256_all(cn, 64),
    "72726d8818f693066ceb69afa364218b692e62ea92b385782363780f47529c21",
  ) // sha256.cn
  assert_eq(ctx_md5_all(raw, 64), "1ac1ef01e96caf1be0d329331a4fc2a8") // md5.raw
  assert_eq(ctx_sha1_all(raw, 64), "56178b86a57fac22899a9964185c2cc96e7da589") // sha1.raw
  assert_eq(
    ctx_sha256_all(raw, 64),
    "be45cb2605bf36bebde684841a28f0fd43c69850a3dce5fedba69928ee3a8991",
  ) // sha256.raw
  // 六字节夹具按 1/2/5 段切：跨"不足一个分组"那条尾巴
  assert_eq(ctx_md5_all(cn, 1), "a7bac2239fcdcb3a067903d8077c4a07") // md5.cn.chunk1
  assert_eq(
    ctx_sha256_all(cn, 2),
    "72726d8818f693066ceb69afa364218b692e62ea92b385782363780f47529c21",
  ) // sha256.cn.chunk2
  assert_eq(ctx_sha1_all(cn, 5), "7be2d2d20c106eee0836c9bc2b939890a78e8fb3") // sha1.cn.chunk5
}

///|
test "Md5Ctx 分段全档：1..N 每种分段长度都等于整份读数" {
  for k in 1..<=55 {
    assert_eq(ctx_md5_all(rep(55, 97), k), "ef1772b6dff9a122358552954ad0df65") // md5.55.1..55
  }
  for k in 1..<=64 {
    assert_eq(ctx_md5_all(rep(64, 97), k), "014842d480b571495a4a0363793f7367") // md5.64.1..64
  }
  for k in 1..<=65 {
    assert_eq(ctx_md5_all(rep(65, 97), k), "c743a45e0d2e6a95cb859adae0248435") // md5.65.1..65
  }
  for k in 1..<=120 {
    assert_eq(ctx_md5_all(rep(120, 97), k), "5f61c0ccad4cac44c75ff505e1f1e537") // md5.120.1..120
  }
}

///|
test "Sha1Ctx / Sha256Ctx 分段全档：1..N 每种分段长度都等于整份读数" {
  for k in 1..<=55 {
    assert_eq(
      ctx_sha1_all(rep(55, 97), k),
      "c1c8bbdc22796e28c0e15163d20899b65621d65a",
    ) // sha1.55.1..55
  }
  for k in 1..<=65 {
    assert_eq(
      ctx_sha1_all(rep(65, 97), k),
      "11655326c708d70319be2610e8a57d9a5b959d3b",
    ) // sha1.65.1..65
  }
  for k in 1..<=120 {
    assert_eq(
      ctx_sha1_all(rep(120, 97), k),
      "f34c1488385346a55709ba056ddd08280dd4c6d6",
    ) // sha1.120.1..120
  }
  for k in 1..<=55 {
    assert_eq(
      ctx_sha256_all(rep(55, 97), k),
      "9f4390f8d30c2dd92ec9f095b65e2b9ae9b0a925a5258e241c9f1e910f734318",
    ) // sha256.55.1..55
  }
  for k in 1..<=65 {
    assert_eq(
      ctx_sha256_all(rep(65, 97), k),
      "635361c48bb9eab14198e76ea8ab7f1a41685d6ad62aa9146d301d4f17eb0ae0",
    ) // sha256.65.1..65
  }
  for k in 1..<=120 {
    assert_eq(
      ctx_sha256_all(rep(120, 97), k),
      "2f3d335432c70b580af0e8e1b3674a7c020d683aa5f73aaaedfdc55af904c21c",
    ) // sha256.120.1..120
  }
}

///|
test "增量入口·确定性随机分段：三把摘要各自跑两张长度表" {
  let xs = rep(119, 97)
  assert_eq(
    ctx_by_sizes_md5(xs, [
      19, 21, 1, 21, 11, 14, 18, 17, 7, 1, 15, 22, 1, 16, 8, 19, 7,
    ]),
    "8a7bd0732ed6a28ce75f6dabc90e1613",
  ) // md5.sizes.a
  assert_eq(
    ctx_by_sizes_md5(xs, [
      20, 12, 7, 23, 7, 20, 7, 22, 8, 22, 18, 17, 21, 3, 4, 3, 1, 2, 5, 10, 8, 21,
      9,
    ]),
    "8a7bd0732ed6a28ce75f6dabc90e1613",
  ) // md5.sizes.b
  assert_eq(
    ctx_by_sizes_sha1(xs, [
      19, 21, 1, 21, 11, 14, 18, 17, 7, 1, 15, 22, 1, 16, 8, 19, 7,
    ]),
    "ee971065aaa017e0632a8ca6c77bb3bf8b1dfc56",
  ) // sha1.sizes.a
  assert_eq(
    ctx_by_sizes_sha1(xs, [
      20, 12, 7, 23, 7, 20, 7, 22, 8, 22, 18, 17, 21, 3, 4, 3, 1, 2, 5, 10, 8, 21,
      9,
    ]),
    "ee971065aaa017e0632a8ca6c77bb3bf8b1dfc56",
  ) // sha1.sizes.b
  assert_eq(
    ctx_by_sizes_sha256(k_of("中文"), [14, 23, 7, 9, 22, 5, 2, 19, 11]),
    "72726d8818f693066ceb69afa364218b692e62ea92b385782363780f47529c21",
  ) // sha256.sizes.cn
  assert_eq(
    ctx_by_sizes_md5(
      bs_of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
      [13, 5, 14, 1, 9, 6, 14, 11, 18, 15, 14],
    ),
    "1ac1ef01e96caf1be0d329331a4fc2a8",
  ) // md5.sizes.raw
}

///|
test "增量入口与一次性入口逐字节相等（对拍）" {
  let xs = rep(65, 97)
  let cn = k_of("中文")
  let raw = bs_of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])
  let m = @digest.Md5Ctx::new()
  m.update(xs)
  assert_eq(m.finish(), @digest.md5_of_bytes(xs)) // 对拍 md5.finish
  let s = @digest.Sha1Ctx::new()
  s.update(cn)
  assert_eq(s.finish(), @digest.sha1_of_bytes(cn)) // 对拍 sha1.finish
  let t = @digest.Sha256Ctx::new()
  t.update(raw)
  assert_eq(t.finish(), @digest.sha256_of_bytes(raw)) // 对拍 sha256.finish
  // finish_hex 必须等于 hex(finish())——同一条腿的第二张嘴不许有第二种数
  assert_eq(m.finish_hex(), @hex.encode(m.finish()).to_lower()) // 对拍 md5.finish_hex
  assert_eq(t.finish_hex(), @hex.encode(t.finish()).to_lower()) // 对拍 sha256.finish_hex
}

///|
test "finish 幂等；finish 之后再 update 必须明确报错，不许默默给错值" {
  let m = @digest.Md5Ctx::new()
  m.update(k_of("abc"))
  let h1 = m.finish_hex()
  let h2 = m.finish_hex()
  let h3 = m.finish()
  assert_eq(h1, h2) // 幂等·hex
  assert_eq(h3, m.finish()) // 幂等·bytes
  assert_eq(h1, "900150983cd24fb0d6963f7d28e17f72") // 幂等后读数仍是对的那条
  // 收尾之后再喂：这一档必须走到错误出口，不能出一个"看着像"的摘要
  let tag = try {
    m.update(k_of("再喂一段"))
    "OK"
  } catch {
    @digest.AlreadyFinished => "AlreadyFinished"
  }
  assert_eq(tag, "AlreadyFinished") // md5.update.after_finish
  let s = @digest.Sha256Ctx::new()
  s.update(k_of("abc"))
  let _ = s.finish()
  let tag2 = try {
    s.update(k_of("x"))
    "OK"
  } catch {
    @digest.AlreadyFinished => "AlreadyFinished"
  }
  assert_eq(tag2, "AlreadyFinished") // sha256.update.after_finish
}

///|
test "一百万字节：循环喂（不整份进内存），三把摘要各一条" {
  let m = @digest.Md5Ctx::new()
  let s = @digest.Sha1Ctx::new()
  let t = @digest.Sha256Ctx::new()
  // 单字节喂一百万次：这一档同时挡"每次 update 重算长度位"与"缓冲越界"两类写法
  for _ in 0..<1000000 {
    m.update(rep(1, 97)) catch {
      @digest.AlreadyFinished => ()
    }
  }
  // 另两把用 1024 字节的段喂满同样一百万字节（976×1024 + 576）
  let piece = rep(1024, 97)
  for _ in 0..<976 {
    try {
      s.update(piece)
      t.update(piece)
    } catch {
      @digest.AlreadyFinished => ()
    }
  }
  try {
    s.update(rep(576, 97))
    t.update(rep(576, 97))
  } catch {
    @digest.AlreadyFinished => ()
  }
  assert_eq(m.finish_hex(), "7707d6ae4e027c70eea2a935c2296f21") // md5.big（一百万次单字节）
  assert_eq(s.finish_hex(), "34aa973cd4c4daa4f61eeb2bdbad27316534016f") // sha1.big（含 RFC 3174 Test3 公布值）
  assert_eq(
    t.finish_hex(),
    "cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0",
  ) // sha256.big
}

///|
test "摘要长度与出口形状：16/20/32 字节，hex 32/40/64 位" {
  let m = @digest.Md5Ctx::new()
  m.update(rep(120, 97))
  assert_eq(m.finish().length(), 16) // md5.finish.length
  assert_eq(m.finish_hex().length(), 32) // md5.finish_hex.length
  let s = @digest.Sha1Ctx::new()
  s.update(rep(120, 97))
  assert_eq(s.finish().length(), 20) // sha1.finish.length
  assert_eq(s.finish_hex().length(), 40) // sha1.finish_hex.length
  let t = @digest.Sha256Ctx::new()
  t.update(rep(120, 97))
  assert_eq(t.finish().length(), 32) // sha256.finish.length
  assert_eq(t.finish_hex().length(), 64) // sha256.finish_hex.length
}
