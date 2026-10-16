///|
// CRC32（本仓 Issues #2）的期望面：官方值内嵌 + Python `zlib.crc32` + JDK `java.util.zip.CRC32`
// 三级对撞后由 `scripts/gen_crc32_test.py` 灌入，手打零条。算法族：IEEE 802.3 反射位序
// （生成多项式 `0xEDB88320`、寄存器初值 `0xFFFFFFFF`、末异或 `0xFFFFFFFF`、
// check（`"123456789"`）= `0xCBF43926`），与 `java.util.zip.CRC32` / `zlib.crc32` / GZIP 同值。
//
// ⚠ 本批与 `Crc8` 那条"照参照的非标准表构造"取向**相反**：hutool 没有 CRC32 件可照
//   （类面清单现读 `cn.hutool.core.io.checksum` 只有 CRC8 / CRC16 与十个 crc16 变体），
//   参照位由 JDK 与 zlib 两个独立实现同值顶上 ⇒ 本件是标准式。分岔记在 spec §5 第 16 行。
// 出口位扩展：`crc32_value` / `crc32_of_bytes` 出口是 `Int64`，恒在 0..4294967295——
//   无符号 32 位**零扩展**，出现负读数就是符号位泄漏（`"a"` 那条 3904355907 过 2^31，专挡这一档）。

///|
// `Int32` 列表 → `Bytes`（与 `hash_test.mbt` 的 `bytes_of` 同效；加前缀避开同包测试的顶层命名空间相撞）
fn crc32_bts(xs : Array[Int32]) -> Bytes {
  Bytes::from_array(xs.map(x => x.to_byte()))
}

///|
// `'a'` × n 的字节表（长度分档与一百万字节档共用；n 与读数同源于腿的夹具）
fn crc32_rep(n : Int32) -> Array[Int32] {
  let xs : Array[Int32] = []
  for _ in 0..<n {
    xs.push(97)
  }
  xs
}

///|
// 按 `chunk` 分段喂完整份，返回增量出口值（分段全档对拍用；每段都新建，不共享内部数组）
fn crc32_feed(xs : Array[Int32], chunk : Int32) -> Int64 {
  let ctx = @hash.new_crc32()
  let n = xs.length()
  let mut i = 0
  while i < n {
    let m = if i + chunk < n { i + chunk } else { n }
    let piece : Array[Int32] = []
    while i < m {
      piece.push(xs[i])
      i = i + 1
    }
    ctx.crc32_update(crc32_bts(piece))
  }
  ctx.crc32_value()
}

///|
test "crc32 一次性入口：官方向量四条公布值 + 十六进制形状" {
  assert_eq(@hash.crc32_of_bytes(crc32_bts([])), 0L) // empty
  assert_eq(@hash.crc32_hex(crc32_bts([])), "00000000") // empty.hex
  assert_eq(@hash.crc32_of_bytes(crc32_bts([97])), 3904355907L) // a
  assert_eq(@hash.crc32_hex(crc32_bts([97])), "e8b7be43") // a.hex
  assert_eq(
    @hash.crc32_of_bytes(crc32_bts([49, 50, 51, 52, 53, 54, 55, 56, 57])),
    3421780262L,
  ) // digits
  assert_eq(
    @hash.crc32_hex(crc32_bts([49, 50, 51, 52, 53, 54, 55, 56, 57])),
    "cbf43926",
  ) // digits.hex
  assert_eq(
    @hash.crc32_of_bytes(
      crc32_bts([
        84, 104, 101, 32, 113, 117, 105, 99, 107, 32, 98, 114, 111, 119, 110, 32,
        102, 111, 120, 32, 106, 117, 109, 112, 115, 32, 111, 118, 101, 114, 32, 116,
        104, 101, 32, 108, 97, 122, 121, 32, 100, 111, 103,
      ]),
    ),
    1095738169L,
  ) // fox
  assert_eq(
    @hash.crc32_hex(
      crc32_bts([
        84, 104, 101, 32, 113, 117, 105, 99, 107, 32, 98, 114, 111, 119, 110, 32,
        102, 111, 120, 32, 106, 117, 109, 112, 115, 32, 111, 118, 101, 114, 32, 116,
        104, 101, 32, 108, 97, 122, 121, 32, 100, 111, 103,
      ]),
    ),
    "414fa339",
  ) // fox.hex
}

///|
test "crc32 出口值域：无符号 32 位零扩展，不许带符号位" {
  // 全部走实现出口，不拿脚本写死的常数自证：高位那条（`"a"` = 0xE8B7BE43 过 2^31）是关键夹具，
  // 出口一旦先降成 `Int32` 再升 `Int64`，读数变负；十六进制长度恒 8 挡住"不补零"那一档。
  let samples : Array[Bytes] = [
    crc32_bts([]),
    crc32_bts([97]),
    crc32_bts([49, 50, 51, 52, 53, 54, 55, 56, 57]),
    crc32_bts([
      84, 104, 101, 32, 113, 117, 105, 99, 107, 32, 98, 114, 111, 119, 110, 32, 102,
      111, 120, 32, 106, 117, 109, 112, 115, 32, 111, 118, 101, 114, 32, 116, 104,
      101, 32, 108, 97, 122, 121, 32, 100, 111, 103,
    ]),
    crc32_bts([228, 184, 173, 230, 150, 135]),
    crc32_bts([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
    crc32_bts(crc32_rep(120)),
  ]
  for b in samples {
    let v = @hash.crc32_of_bytes(b)
    assert_true(v >= 0L) // 负读数＝符号扩展
    assert_true(v < 4294967296L) // 越过 32 位＝扩展错位
    assert_eq(@hash.crc32_hex(b).length(), 8) // hex 恒八位（empty 那档靠补零撑住）
  }
}

///|
test "crc32 非文本夹具：中文 UTF-8 与含 0x00 的裸字节流" {
  assert_eq(
    @hash.crc32_of_bytes(crc32_bts([228, 184, 173, 230, 150, 135])),
    1510599991L,
  ) // cn
  assert_eq(
    @hash.crc32_hex(crc32_bts([228, 184, 173, 230, 150, 135])),
    "5a09ed37",
  ) // cn.hex
  assert_eq(
    @hash.crc32_of_bytes(
      crc32_bts([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
    ),
    3469664904L,
  ) // raw0f
  assert_eq(
    @hash.crc32_hex(
      crc32_bts([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
    ),
    "cecee288",
  ) // raw0f.hex
}

///|
test "crc32 长度分档：一次性入口跨 55/56/63/64/65/119/120" {
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(55))), 2866799438L) // rep55
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(56))), 2037976375L) // rep56
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(63))), 1747240414L) // rep63
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(64))), 2310301013L) // rep64
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(65))), 4081037149L) // rep65
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(119))), 1095035822L) // rep119
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(120))), 3650647111L) // rep120
}

///|
test "crc32 分段全档：1..N 每种分段长度都等于整份读数" {
  for k in 1..<=6 {
    assert_eq(crc32_feed([228, 184, 173, 230, 150, 135], k), 1510599991L) // cn.1..6
  }
  for k in 1..<=9 {
    assert_eq(crc32_feed([49, 50, 51, 52, 53, 54, 55, 56, 57], k), 3421780262L) // digits.1..9
  }
  for k in 1..<=16 {
    assert_eq(
      crc32_feed([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], k),
      3469664904L,
    ) // raw0f.1..16
  }
  for k in 1..<=43 {
    assert_eq(
      crc32_feed(
        [
          84, 104, 101, 32, 113, 117, 105, 99, 107, 32, 98, 114, 111, 119, 110, 32,
          102, 111, 120, 32, 106, 117, 109, 112, 115, 32, 111, 118, 101, 114, 32,
          116, 104, 101, 32, 108, 97, 122, 121, 32, 100, 111, 103,
        ],
        k,
      ),
      1095738169L,
    ) // fox.1..43
  }
}

///|
test "crc32 分段全档·长夹具：1..120 每种分段都等于整份读数" {
  let xs = crc32_rep(120)
  for k in 1..<=120 {
    assert_eq(crc32_feed(xs, k), 3650647111L) // rep120.1..120
  }
  let ys = crc32_rep(65)
  for k in 1..<=65 {
    assert_eq(crc32_feed(ys, k), 4081037149L) // rep65.1..65
  }
}

///|
test "crc32 一百万字节：分块喂不整份进内存" {
  let ctx = @hash.new_crc32()
  let piece = crc32_bts(crc32_rep(1024))
  // 976 × 1024 + 576 = 1000000，与腿的 rep1m 夹具同量
  for _ in 0..<976 {
    ctx.crc32_update(piece)
  }
  ctx.crc32_update(crc32_bts(crc32_rep(576)))
  assert_eq(ctx.crc32_value(), 3693461436L) // rep1m
  // 小段多次喂（次数级别的"不炸"）：一万个单字节段与整份同值
  let c2 = @hash.new_crc32()
  for _ in 0..<10000 {
    c2.crc32_update(crc32_bts([97]))
  }
  assert_eq(c2.crc32_value(), 1182717079L) // rep10k
}

///|
test "crc32 区间档：update_range 与整段喂同值，带偏移取段等于单独喂那一段" {
  let ctx = @hash.new_crc32()
  ctx.crc32_update_range(crc32_bts([49, 50, 51, 52, 53, 54, 55, 56, 57]), 0, 9)
  assert_eq(ctx.crc32_value(), 3421780262L) // digits.range
  let c2 = @hash.new_crc32()
  c2.crc32_update_range(
    crc32_bts([
      84, 104, 101, 32, 113, 117, 105, 99, 107, 32, 98, 114, 111, 119, 110, 32, 102,
      111, 120, 32, 106, 117, 109, 112, 115, 32, 111, 118, 101, 114, 32, 116, 104,
      101, 32, 108, 97, 122, 121, 32, 100, 111, 103,
    ]),
    0,
    43,
  )
  assert_eq(c2.crc32_value(), 1095738169L) // fox.range
  let c3 = @hash.new_crc32()
  c3.crc32_update_range(
    crc32_bts([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
    0,
    16,
  )
  assert_eq(c3.crc32_value(), 3469664904L) // raw0f.range
  let c4 = @hash.new_crc32()
  c4.crc32_update_range(crc32_bts(crc32_rep(120)), 7, 56)
  assert_eq(c4.crc32_value(), 2037976375L) // offset56
}

///|
test "crc32 逐字节档：update_byte 每字节一次与整段喂同值" {
  let ctx = @hash.new_crc32()
  for x in [49, 50, 51, 52, 53, 54, 55, 56, 57] {
    ctx.crc32_update_byte(x)
  }
  assert_eq(ctx.crc32_value(), 3421780262L) // digits.perbyte
  let c2 = @hash.new_crc32()
  for x in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15] {
    c2.crc32_update_byte(x)
  }
  assert_eq(c2.crc32_value(), 3469664904L) // raw0f.perbyte
  let c3 = @hash.new_crc32()
  for x in [228, 184, 173, 230, 150, 135] {
    c3.crc32_update_byte(x)
  }
  assert_eq(c3.crc32_value(), 1510599991L) // cn.perbyte
}

///|
test "crc32 reset：回到空串读数，reset 后再喂等于新建" {
  let ctx = @hash.new_crc32()
  ctx.crc32_update(
    crc32_bts([
      84, 104, 101, 32, 113, 117, 105, 99, 107, 32, 98, 114, 111, 119, 110, 32, 102,
      111, 120, 32, 106, 117, 109, 112, 115, 32, 111, 118, 101, 114, 32, 116, 104,
      101, 32, 108, 97, 122, 121, 32, 100, 111, 103,
    ]),
  )
  ctx.crc32_reset()
  assert_eq(ctx.crc32_value(), 0L) // after_reset
  ctx.crc32_reset()
  assert_eq(ctx.crc32_value(), 0L) // after_reset.twice
  ctx.crc32_update(crc32_bts([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(ctx.crc32_value(), 3421780262L) // reset.then_feed
  let fresh = @hash.new_crc32()
  fresh.crc32_update(crc32_bts([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(fresh.crc32_value(), ctx.crc32_value()) // reset.eq_fresh
}
