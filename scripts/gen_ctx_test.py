#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""digest 流式/增量入口（Issues #3）期望面生成器：官方向量内嵌 + 独立实现现算对撞。

用法：

    python scripts/gen_ctx_test.py <读数留痕.txt>

两级读数（缺任何一级都不出文件）：

  ① **官方向量**：本仓已冻结的那批（`docs/spec/02-digest.md` §2.1 RFC 1321 A.5、§2.3 FIPS 180-4、
     §2.8 NIST 示例 + RFC 3174 §7.3 含 1M 个 `a`）。这批是外部读数来源，脚本内嵌后**先与 Python
     `hashlib` 现算逐条 assert**——本批不新造任何官方向量，只把既有向量在增量入口上重放一遍。
  ② **Python `hashlib`**：对同一批夹具分别做"整份现算"与"按 chunk 分段 update 后 digest"，
     两级必须逐字节相等（这条是"分段续算与整份同值"的**独立实现证据**，不是我们的推断），
     然后才把值灌进用例。跨分组边界长度 `0/1/55/56/63/64/65/119/120/1000000` 全档覆盖，
     其中 `55/63/64/65/119/120` 六条没有公布值可用，provider 一律标 `hashlib`。

四条纪律（承 `gen_sha1_test.py` / `gen_crc32_test.py`）：

  · 夹具与期望串全走本脚本，测试文件手打零条；标签两向完备。
  · 一百万字节档不进字面量，用例用循环喂（issue 的验收要求第 1 条后半句）。
  · 期望串冻结后，落地笔（PR-B）只许把红变绿（门禁 G5）。
  · 生成物 fmt 稳定：先 `moon fmt` 收敛再把形状回抄进模板。
"""
import hashlib
import io
import os
import sys

OUT_MBT = os.path.join("digest", "stream_ctx_test.mbt")

# ---------------------------------------------------------------------------
# ① 官方向量（本仓已冻结，来源是 RFC 1321 A.5 / FIPS 180-4 / NIST 示例 + RFC 3174 §7.3）
# ---------------------------------------------------------------------------
ALGOS = ("md5", "sha1", "sha256")

OFFICIAL = {
    ("md5", b""): "d41d8cd98f00b204e9800998ecf8427e",
    ("md5", b"abc"): "900150983cd24fb0d6963f7d28e17f72",
    ("md5", b"a" * 80): "57edf4a22be3c955ac49da2e2107b67a",
    ("sha1", b"abc"): "a9993e364706816aba3e25717850c26c9cd0d89d",
    (
        "sha1",
        b"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
    ): "84983e441c3bd26ebaae4aa1f95129e5e54670f1",
    ("sha1", b"a" * 1_000_000): "34aa973cd4c4daa4f61eeb2bdbad27316534016f",
    ("sha256", b""): "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    ("sha256", b"abc"): "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
    (
        "sha256",
        b"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
    ): "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1",
}

# 长度分档（issue 验收要求第 1 条）；一百万档单独走循环喂，不进字面量
LENS = [0, 1, 55, 56, 63, 64, 65, 119, 120]
BIG = 1_000_000

TWO_BLOCK = b"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
CN = "中文".encode("utf-8")
RAW = bytes(range(16))


def py(algo, data):
    return getattr(hashlib, algo)(data).hexdigest()


def py_chunked(algo, data, chunk):
    h = getattr(hashlib, algo)()
    for i in range(0, len(data), chunk):
        h.update(data[i : i + chunk])
    return h.hexdigest()


def build():
    """两级对撞 + 读数表。"""
    vals, meta = {}, {}
    for algo in ALGOS:
        for tag, data in (
            *[("L%d" % n, b"a" * n) for n in LENS],
            ("abc", b"abc"),
            ("2block", TWO_BLOCK),
            ("cn", CN),
            ("raw", RAW),
        ):
            one = py(algo, data)
            src = "hashlib"
            if (algo, data) in OFFICIAL:
                assert (
                    one == OFFICIAL[(algo, data)]
                ), "官方向量对不上：%s/%r 现算 %s，冻结值 %s" % (
                    algo,
                    data[:12],
                    one,
                    OFFICIAL[(algo, data)],
                )
                src = "official+hashlib"
            # 第二级：同一实现的分段腿，必须先自证"分段与整份同值"才配当期望值
            for chunk in (1, 2, 7, 64, 65, len(data) or 1):
                if chunk and data:
                    assert (
                        py_chunked(algo, data, chunk) == one
                    ), "分段腿自相矛盾：%s/%s chunk=%d" % (algo, tag, chunk)
            vals["%s.%s" % (algo, tag)] = one
            meta["%s.%s" % (algo, tag)] = "provider=%s|len=%d" % (src, len(data))
        big = py(algo, b"a" * BIG)
        assert py_chunked(algo, b"a" * BIG, 997) == big
        if (algo, b"a" * BIG) in OFFICIAL:
            assert (
                big == OFFICIAL[(algo, b"a" * BIG)]
            ), "官方向量对不上：%s/1M" % algo
            meta_v = "provider=official+hashlib|len=%d" % BIG
        else:
            meta_v = "provider=hashlib|len=%d" % BIG
        vals["%s.big" % algo] = big
        meta["%s.big" % algo] = meta_v
    return vals, meta


def lcg_sizes(seed, count, lo=1, hi=23):
    """确定性"随机分段"序列（不许依赖宿主熵或时钟；同一条序列三档必须同值）。"""
    s, out = seed, []
    for _ in range(count):
        s = (s * 1103515245 + 12345) & 0x7FFFFFFF
        out.append(lo + s % (hi - lo + 1))
    return out


def sizes_literal(xs):
    return "[" + ", ".join(str(x) for x in xs) + "]"


HEAD = r'''///|
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
  assert_eq(ctx_md5_all(rep(0, 97), 64), "@@md5.L0@@") // md5.L0
  assert_eq(ctx_md5_all(rep(1, 97), 64), "@@md5.L1@@") // md5.L1
  assert_eq(ctx_md5_all(rep(55, 97), 64), "@@md5.L55@@") // md5.L55
  assert_eq(ctx_md5_all(rep(56, 97), 64), "@@md5.L56@@") // md5.L56
  assert_eq(ctx_md5_all(rep(63, 97), 64), "@@md5.L63@@") // md5.L63
  assert_eq(ctx_md5_all(rep(64, 97), 64), "@@md5.L64@@") // md5.L64
  assert_eq(ctx_md5_all(rep(65, 97), 64), "@@md5.L65@@") // md5.L65
  assert_eq(ctx_md5_all(rep(119, 97), 64), "@@md5.L119@@") // md5.L119
  assert_eq(ctx_md5_all(rep(120, 97), 64), "@@md5.L120@@") // md5.L120
  assert_eq(ctx_md5_all(k_of("abc"), 64), "@@md5.abc@@") // md5.abc（官方向量）
}

///|
test "Sha1Ctx / Sha256Ctx 长度分档：同形两把摘要" {
  assert_eq(ctx_sha1_all(rep(0, 97), 64), "@@sha1.L0@@") // sha1.L0
  assert_eq(ctx_sha1_all(rep(1, 97), 64), "@@sha1.L1@@") // sha1.L1
  assert_eq(ctx_sha1_all(rep(55, 97), 64), "@@sha1.L55@@") // sha1.L55
  assert_eq(ctx_sha1_all(rep(56, 97), 64), "@@sha1.L56@@") // sha1.L56
  assert_eq(ctx_sha1_all(rep(63, 97), 64), "@@sha1.L63@@") // sha1.L63
  assert_eq(ctx_sha1_all(rep(64, 97), 64), "@@sha1.L64@@") // sha1.L64
  assert_eq(ctx_sha1_all(rep(65, 97), 64), "@@sha1.L65@@") // sha1.L65
  assert_eq(ctx_sha1_all(rep(119, 97), 64), "@@sha1.L119@@") // sha1.L119
  assert_eq(ctx_sha1_all(rep(120, 97), 64), "@@sha1.L120@@") // sha1.L120
  assert_eq(ctx_sha1_all(k_of("abc"), 64), "@@sha1.abc@@") // sha1.abc（官方向量）
  assert_eq(ctx_sha256_all(rep(0, 97), 64), "@@sha256.L0@@") // sha256.L0
  assert_eq(ctx_sha256_all(rep(1, 97), 64), "@@sha256.L1@@") // sha256.L1
  assert_eq(ctx_sha256_all(rep(55, 97), 64), "@@sha256.L55@@") // sha256.L55
  assert_eq(ctx_sha256_all(rep(56, 97), 64), "@@sha256.L56@@") // sha256.L56
  assert_eq(ctx_sha256_all(rep(63, 97), 64), "@@sha256.L63@@") // sha256.L63
  assert_eq(ctx_sha256_all(rep(64, 97), 64), "@@sha256.L64@@") // sha256.L64
  assert_eq(ctx_sha256_all(rep(65, 97), 64), "@@sha256.L65@@") // sha256.L65
  assert_eq(ctx_sha256_all(rep(119, 97), 64), "@@sha256.L119@@") // sha256.L119
  assert_eq(ctx_sha256_all(rep(120, 97), 64), "@@sha256.L120@@") // sha256.L120
  assert_eq(ctx_sha256_all(k_of("abc"), 64), "@@sha256.abc@@") // sha256.abc（官方向量）
}

///|
test "增量入口的官方向量重放：两条整块消息在两个入口上同值" {
  // FIPS 180-4 / RFC 3174 的 56 字节两分块串，和 RFC 1321 的 80 字节串：这些是本仓已冻的公布值
  assert_eq(
    ctx_sha1_all(k_of("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"), 64),
    "@@sha1.2block@@",
  ) // sha1.2block
  assert_eq(
    ctx_sha256_all(
      k_of("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
      64,
    ),
    "@@sha256.2block@@",
  ) // sha256.2block
  assert_eq(ctx_md5_all(rep(80, 97), 64), "@@md5.L80@@") // md5.L80（'a'×80，provider=hashlib）
  assert_eq(
    ctx_md5_all(k_of("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"), 64),
    "@@md5.2block@@",
  ) // md5.2block（同一条 56 字节串走 md5：无公布值，provider=hashlib）
}

///|
test "增量入口的非文本夹具：中文 UTF-8 与含 0x00 的裸字节流" {
  let cn = k_of("中文")
  let raw = bs_of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])
  assert_eq(ctx_md5_all(cn, 64), "@@md5.cn@@") // md5.cn
  assert_eq(ctx_sha1_all(cn, 64), "@@sha1.cn@@") // sha1.cn
  assert_eq(ctx_sha256_all(cn, 64), "@@sha256.cn@@") // sha256.cn
  assert_eq(ctx_md5_all(raw, 64), "@@md5.raw@@") // md5.raw
  assert_eq(ctx_sha1_all(raw, 64), "@@sha1.raw@@") // sha1.raw
  assert_eq(ctx_sha256_all(raw, 64), "@@sha256.raw@@") // sha256.raw
  // 六字节夹具按 1/2/5 段切：跨"不足一个分组"那条尾巴
  assert_eq(ctx_md5_all(cn, 1), "@@md5.cn@@") // md5.cn.chunk1
  assert_eq(ctx_sha256_all(cn, 2), "@@sha256.cn@@") // sha256.cn.chunk2
  assert_eq(ctx_sha1_all(cn, 5), "@@sha1.cn@@") // sha1.cn.chunk5
}

///|
test "Md5Ctx 分段全档：1..N 每种分段长度都等于整份读数" {
  for k in 1..<=55 {
    assert_eq(ctx_md5_all(rep(55, 97), k), "@@md5.L55@@") // md5.55.1..55
  }
  for k in 1..<=64 {
    assert_eq(ctx_md5_all(rep(64, 97), k), "@@md5.L64@@") // md5.64.1..64
  }
  for k in 1..<=65 {
    assert_eq(ctx_md5_all(rep(65, 97), k), "@@md5.L65@@") // md5.65.1..65
  }
  for k in 1..<=120 {
    assert_eq(ctx_md5_all(rep(120, 97), k), "@@md5.L120@@") // md5.120.1..120
  }
}

///|
test "Sha1Ctx / Sha256Ctx 分段全档：1..N 每种分段长度都等于整份读数" {
  for k in 1..<=55 {
    assert_eq(ctx_sha1_all(rep(55, 97), k), "@@sha1.L55@@") // sha1.55.1..55
  }
  for k in 1..<=65 {
    assert_eq(ctx_sha1_all(rep(65, 97), k), "@@sha1.L65@@") // sha1.65.1..65
  }
  for k in 1..<=120 {
    assert_eq(ctx_sha1_all(rep(120, 97), k), "@@sha1.L120@@") // sha1.120.1..120
  }
  for k in 1..<=55 {
    assert_eq(ctx_sha256_all(rep(55, 97), k), "@@sha256.L55@@") // sha256.55.1..55
  }
  for k in 1..<=65 {
    assert_eq(ctx_sha256_all(rep(65, 97), k), "@@sha256.L65@@") // sha256.65.1..65
  }
  for k in 1..<=120 {
    assert_eq(ctx_sha256_all(rep(120, 97), k), "@@sha256.L120@@") // sha256.120.1..120
  }
}

///|
test "增量入口·确定性随机分段：三把摘要各自跑两张长度表" {
  let xs = rep(119, 97)
  assert_eq(ctx_by_sizes_md5(xs, @@sizes.a@@), "@@md5.L119@@") // md5.sizes.a
  assert_eq(ctx_by_sizes_md5(xs, @@sizes.b@@), "@@md5.L119@@") // md5.sizes.b
  assert_eq(ctx_by_sizes_sha1(xs, @@sizes.a@@), "@@sha1.L119@@") // sha1.sizes.a
  assert_eq(ctx_by_sizes_sha1(xs, @@sizes.b@@), "@@sha1.L119@@") // sha1.sizes.b
  assert_eq(
    ctx_by_sizes_sha256(k_of("中文"), @@sizes.c@@),
    "@@sha256.cn@@",
  ) // sha256.sizes.cn
  assert_eq(
    ctx_by_sizes_md5(bs_of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]), @@sizes.d@@),
    "@@md5.raw@@",
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
  assert_eq(h1, "@@md5.abc@@") // 幂等后读数仍是对的那条
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
    try {
      m.update(rep(1, 97))
    } catch {
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
  assert_eq(m.finish_hex(), "@@md5.big@@") // md5.big（一百万次单字节）
  assert_eq(s.finish_hex(), "@@sha1.big@@") // sha1.big（含 RFC 3174 Test3 公布值）
  assert_eq(t.finish_hex(), "@@sha256.big@@") // sha256.big
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
'''


def render(vals):
    lookup = dict(vals)
    seed_sizes = {
        "sizes.a": lcg_sizes(20261016, 17),
        "sizes.b": lcg_sizes(7, 23),
        "sizes.c": lcg_sizes(99, 9),
        "sizes.d": lcg_sizes(424242, 11),
    }
    for k, v in seed_sizes.items():
        lookup[k] = sizes_literal(v)
    # md5 的 80 字节档：RFC 1321 A.5 的第七条是 80 个数字字符，本批夹具用 'a'×80 ⇒ 现算
    lookup["md5.L80"] = py("md5", b"a" * 80)

    used = set()

    def sub_line(line):
        out = line
        while "@@" in out:
            lo = out.index("@@")
            hi = out.index("@@", lo + 2)
            label = out[lo + 2 : hi]
            if label not in lookup:
                sys.exit("缺读数：模板引用了 %s，读数表里没有" % label)
            used.add(label)
            out = out[:lo] + lookup[label] + out[hi + 2 :]
        return out

    body = "\n".join(sub_line(l) for l in HEAD.splitlines()) + "\n"
    dangling = sorted(set(lookup) - used - {"md5.L80"})
    if dangling:
        sys.exit("有读数没被用例用到（悬空）：%s" % "，".join(dangling))
    return body


def main():
    if len(sys.argv) < 2:
        sys.exit("用法：python scripts/gen_ctx_test.py <读数留痕.txt>")
    vals, meta = build()
    body = render(vals)
    lines = ["# digest 增量入口读数（scripts/gen_ctx_test.py 生成；列：标签|十六进制|元数据）"]
    for label in sorted(vals):
        lines.append("%s|%s|%s" % (label, vals[label], meta[label]))
    io.open(sys.argv[1], "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")
    io.open(OUT_MBT, "w", encoding="utf-8", newline="\n").write(body)
    n_assert = body.count("assert_eq(") + body.count("assert_true(")
    print("两级对撞：官方向量内嵌全部复现；读数 %d 条" % len(vals))
    print("用例 %d 块 %d 处断言 → %s" % (body.count('\ntest "'), n_assert, OUT_MBT))


if __name__ == "__main__":
    main()
