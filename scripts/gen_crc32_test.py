#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""CRC32（Issues #2）期望面生成器：官方值内嵌 + 两级独立实现现算对撞，撞不齐就拒绝出文件。

用法：

    python scripts/gen_crc32_test.py <jdk腿读数.txt> <合并读数.txt>

  · `<jdk腿读数.txt>`：`scripts/Crc32Leg.java` 的输出（`java.util.zip.CRC32`，列 `标签|值|hex|长度`），
    按本仓惯例落在工作树外、不提交；
  · `<合并读数.txt>`：本脚本写出的三级对撞留痕（同样不提交）。

三级读数（缺任何一级都不出文件）：

  ① **官方向量**：CRC-32 目录（IEEE 802.3 / zlib / PKZIP 同族）公布的 check 值与三条常用样例——
     `""`→`0x00000000`、`"a"`→`0xE8B7BE43`、`"123456789"`→`0xCBF43926`（该族的标准 CHECK 常数）、
     `"The quick brown fox jumps over the lazy dog"`→`0x414FA339`。
  ② **Python `zlib.crc32`** 对同一批夹具现算，与 ① 逐条 `assert` 相等（兜誊写错误与夹具描述不符）。
  ③ **JDK `java.util.zip.CRC32`** 参照腿对同一批夹具现读，与 ② 逐条相等（三条入口 update(byte[]) /
     update(byte[],int,int) / update(int) 各自兜住）。

四条纪律（都是本仓前几轮撞出来的）：

  · 夹具（字节列表）与期望串全走本脚本，测试文件里手打零条；标签**两向完备**——用到的读数必须存在，
    取到的读数必须全被用例用到。
  · 字节夹具由 `s.encode("utf-8")` 现算（`hash` 轮那条"字节夹具不许手打"的形状）。
  · 期望串冻结后，落地笔（PR-B）只许把红变绿（门禁 G5）。
  · 生成物必须 fmt 稳定：先跑 `moon fmt` 收敛，再把收敛后的形状回抄进本脚本模板。
"""
import io
import os
import sys
import zlib

OUT_MBT = os.path.join("hash", "hash_crc32_test.mbt")

# ---------------------------------------------------------------------------
# 夹具（字节一律现算，不手打）
# ---------------------------------------------------------------------------
FIX = {
    "empty": b"",
    "a": b"a",
    "digits": b"123456789",
    "fox": b"The quick brown fox jumps over the lazy dog",
    # 中文夹具与参照腿同源：Java 侧写的是 \u4e2d\u6587 的 Unicode 转义 + UTF-8 取字节
    "cn": "中文".encode("utf-8"),
    "raw0f": bytes(range(16)),
    "rep55": b"a" * 55,
    "rep56": b"a" * 56,
    "rep63": b"a" * 63,
    "rep64": b"a" * 64,
    "rep65": b"a" * 65,
    "rep119": b"a" * 119,
    "rep120": b"a" * 120,
    "rep1m": b"a" * 1_000_000,
}

# ① 官方向量（CRC-32 目录公布值；其余夹具只有 ②③ 两级来源）
OFFICIAL = {
    "empty": 0x00000000,
    "a": 0xE8B7BE43,
    "digits": 0xCBF43926,
    "fox": 0x414FA339,
}


def cross_check(jdk):
    """三级对撞：返回 {标签: 十进制读数}；任何一级不齐直接停。"""
    vals, meta = {}, {}
    for tag, data in FIX.items():
        py = zlib.crc32(data) & 0xFFFFFFFF
        if tag in OFFICIAL:
            assert py == OFFICIAL[tag], "官方向量对不上：%s 现算 %d，公布 %d" % (
                tag,
                py,
                OFFICIAL[tag],
            )
        if tag not in jdk:
            sys.exit("缺读数：JDK 腿没有标签 %s" % tag)
        assert jdk[tag] == py, "参照腿对不上：%s JDK %d，zlib %d" % (tag, jdk[tag], py)
        vals[tag] = py
        meta[tag] = "provider=%s|len=%d" % (
            "official+zlib+jdk" if tag in OFFICIAL else "zlib+jdk",
            len(data),
        )
    # 区间档 / 逐字节档 / reset 档：腿侧的三条形状读数，同样要与整份读数同值
    for tag in ("a", "digits", "fox", "cn", "raw0f"):
        for suffix in ("range", "perbyte"):
            key = "%s.%s" % (tag, suffix)
            if key not in jdk:
                sys.exit("缺读数：JDK 腿没有 %s" % key)
            assert jdk[key] == vals[tag], "%s 与整段喂不同值（腿自相矛盾）" % key
    for extra, expect in (("offset56", "rep56"), ("after_reset", "empty")):
        if extra not in jdk:
            sys.exit("缺读数：JDK 腿没有 %s" % extra)
        assert jdk[extra] == vals[expect], "%s 应等于 %s 的读数" % (extra, expect)
    vals["offset56"] = jdk["offset56"]
    vals["after_reset"] = jdk["after_reset"]
    meta["offset56"] = "provider=jdk+derived|len=56"
    meta["after_reset"] = "provider=jdk+derived|len=0"
    return vals, meta


def parse_jdk(path):
    out = {}
    for line in io.open(path, encoding="utf-8").read().splitlines():
        line = line.strip()
        if not line or "|" not in line:
            continue
        parts = line.split("|")
        out[parts[0]] = int(parts[1])
    return out


def arr(bdata, indent="      "):
    """字节 → MoonBit `Array[Int32]` 字面量（80 列折行，与 fmt 收敛后的形状对齐）。"""
    items = ", ".join(str(b & 0xFF) for b in bdata)
    if len(items) + len(indent) <= 74:
        return "[" + items + "]"
    # 长夹具折行：每行 12 个
    bs = bdata
    rows = [
        ", ".join(str(bs[i] & 0xFF) for i in range(j, min(j + 12, len(bs))))
        for j in range(0, len(bs), 12)
    ]
    inner = (",\n" + indent).join(rows)
    return "[\n" + indent + inner + ",\n" + indent[:-2] + "]"


HEAD = r'''///|
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
  assert_eq(@hash.crc32_of_bytes(crc32_bts([])), @@empty@@L) // empty
  assert_eq(@hash.crc32_hex(crc32_bts([])), "@@empty.hex@@") // empty.hex
  assert_eq(@hash.crc32_of_bytes(crc32_bts([97])), @@a@@L) // a
  assert_eq(@hash.crc32_hex(crc32_bts([97])), "@@a.hex@@") // a.hex
  assert_eq(@hash.crc32_of_bytes(crc32_bts(@@digits.arr@@)), @@digits@@L) // digits
  assert_eq(@hash.crc32_hex(crc32_bts(@@digits.arr@@)), "@@digits.hex@@") // digits.hex
  assert_eq(@hash.crc32_of_bytes(crc32_bts(@@fox.arr@@)), @@fox@@L) // fox
  assert_eq(@hash.crc32_hex(crc32_bts(@@fox.arr@@)), "@@fox.hex@@") // fox.hex
}

///|
test "crc32 出口值域：无符号 32 位零扩展，不许带符号位" {
  // 全部走实现出口，不拿脚本写死的常数自证：高位那条（`"a"` = 0xE8B7BE43 过 2^31）是关键夹具，
  // 出口一旦先降成 `Int32` 再升 `Int64`，读数变负；十六进制长度恒 8 挡住"不补零"那一档。
  let samples : Array[Bytes] = [
    crc32_bts([]),
    crc32_bts([97]),
    crc32_bts(@@digits.arr@@),
    crc32_bts(@@fox.arr@@),
    crc32_bts(@@cn.arr@@),
    crc32_bts(@@raw0f.arr@@),
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
  assert_eq(@hash.crc32_of_bytes(crc32_bts(@@cn.arr@@)), @@cn@@L) // cn
  assert_eq(@hash.crc32_hex(crc32_bts(@@cn.arr@@)), "@@cn.hex@@") // cn.hex
  assert_eq(@hash.crc32_of_bytes(crc32_bts(@@raw0f.arr@@)), @@raw0f@@L) // raw0f
  assert_eq(@hash.crc32_hex(crc32_bts(@@raw0f.arr@@)), "@@raw0f.hex@@") // raw0f.hex
}

///|
test "crc32 长度分档：一次性入口跨 55/56/63/64/65/119/120" {
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(55))), @@rep55@@L) // rep55
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(56))), @@rep56@@L) // rep56
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(63))), @@rep63@@L) // rep63
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(64))), @@rep64@@L) // rep64
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(65))), @@rep65@@L) // rep65
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(119))), @@rep119@@L) // rep119
  assert_eq(@hash.crc32_of_bytes(crc32_bts(crc32_rep(120))), @@rep120@@L) // rep120
}

///|
test "crc32 分段全档：1..N 每种分段长度都等于整份读数" {
  for k in 1..<=6 {
    assert_eq(crc32_feed(@@cn.arr@@, k), @@cn@@L) // cn.1..6
  }
  for k in 1..<=9 {
    assert_eq(crc32_feed(@@digits.arr@@, k), @@digits@@L) // digits.1..9
  }
  for k in 1..<=16 {
    assert_eq(crc32_feed(@@raw0f.arr@@, k), @@raw0f@@L) // raw0f.1..16
  }
  for k in 1..<=43 {
    assert_eq(crc32_feed(@@fox.arr@@, k), @@fox@@L) // fox.1..43
  }
}

///|
test "crc32 分段全档·长夹具：1..120 每种分段都等于整份读数" {
  let xs = crc32_rep(120)
  for k in 1..<=120 {
    assert_eq(crc32_feed(xs, k), @@rep120@@L) // rep120.1..120
  }
  let ys = crc32_rep(65)
  for k in 1..<=65 {
    assert_eq(crc32_feed(ys, k), @@rep65@@L) // rep65.1..65
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
  assert_eq(ctx.crc32_value(), @@rep1m@@L) // rep1m
  // 小段多次喂（次数级别的"不炸"）：一万个单字节段与整份同值
  let c2 = @hash.new_crc32()
  for _ in 0..<10000 {
    c2.crc32_update(crc32_bts([97]))
  }
  assert_eq(c2.crc32_value(), @@rep10k@@L) // rep10k
}

///|
test "crc32 区间档：update_range 与整段喂同值，带偏移取段等于单独喂那一段" {
  let ctx = @hash.new_crc32()
  ctx.crc32_update_range(crc32_bts(@@digits.arr@@), 0, 9)
  assert_eq(ctx.crc32_value(), @@digits@@L) // digits.range
  let c2 = @hash.new_crc32()
  c2.crc32_update_range(crc32_bts(@@fox.arr@@), 0, 43)
  assert_eq(c2.crc32_value(), @@fox@@L) // fox.range
  let c3 = @hash.new_crc32()
  c3.crc32_update_range(crc32_bts(@@raw0f.arr@@), 0, 16)
  assert_eq(c3.crc32_value(), @@raw0f@@L) // raw0f.range
  let c4 = @hash.new_crc32()
  c4.crc32_update_range(crc32_bts(crc32_rep(120)), 7, 56)
  assert_eq(c4.crc32_value(), @@offset56@@L) // offset56
}

///|
test "crc32 逐字节档：update_byte 每字节一次与整段喂同值" {
  let ctx = @hash.new_crc32()
  for x in @@digits.arr@@ {
    ctx.crc32_update_byte(x)
  }
  assert_eq(ctx.crc32_value(), @@digits@@L) // digits.perbyte
  let c2 = @hash.new_crc32()
  for x in @@raw0f.arr@@ {
    c2.crc32_update_byte(x)
  }
  assert_eq(c2.crc32_value(), @@raw0f@@L) // raw0f.perbyte
  let c3 = @hash.new_crc32()
  for x in @@cn.arr@@ {
    c3.crc32_update_byte(x)
  }
  assert_eq(c3.crc32_value(), @@cn@@L) // cn.perbyte
}

///|
test "crc32 reset：回到空串读数，reset 后再喂等于新建" {
  let ctx = @hash.new_crc32()
  ctx.crc32_update(crc32_bts(@@fox.arr@@))
  ctx.crc32_reset()
  assert_eq(ctx.crc32_value(), @@after_reset@@L) // after_reset
  ctx.crc32_reset()
  assert_eq(ctx.crc32_value(), @@after_reset@@L) // after_reset.twice
  ctx.crc32_update(crc32_bts(@@digits.arr@@))
  assert_eq(ctx.crc32_value(), @@digits@@L) // reset.then_feed
  let fresh = @hash.new_crc32()
  fresh.crc32_update(crc32_bts(@@digits.arr@@))
  assert_eq(fresh.crc32_value(), ctx.crc32_value()) // reset.eq_fresh
}
'''


def render(vals):
    """模板注入 + 两向完备检查。"""
    hexed = {"%s.hex" % k: "%08x" % v for k, v in vals.items()}
    lookup = dict(vals)
    lookup.update(hexed)
    for tag in ("digits", "fox", "cn", "raw0f"):
        lookup["%s.arr" % tag] = arr(FIX[tag])
    # 'a' × 10000 的整份读数：腿没单列，用 zlib 现算并入 ② 级来源
    lookup["rep10k"] = zlib.crc32(b"a" * 10000) & 0xFFFFFFFF

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
            out = out[:lo] + str(lookup[label]) + out[hi + 2 :]
        return out

    body = "\n".join(sub_line(l) for l in HEAD.splitlines()) + "\n"
    for tag in list(FIX) + ["offset56", "after_reset"]:
        if tag not in used:
            sys.exit("有读数没被用例用到（悬空）：%s" % tag)
    return body


def main():
    if len(sys.argv) < 3:
        sys.exit("用法：python scripts/gen_crc32_test.py <jdk腿读数.txt> <合并读数.txt>")
    jdk = parse_jdk(sys.argv[1])
    vals, meta = cross_check(jdk)
    n_official = len(OFFICIAL)
    body = render(vals)

    lines = ["# CRC32 读数（scripts/gen_crc32_test.py 生成；列：标签|十进制|元数据）"]
    for label in sorted(vals):
        lines.append("%s|%d|%s" % (label, vals[label], meta[label]))
    io.open(sys.argv[2], "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")
    io.open(OUT_MBT, "w", encoding="utf-8", newline="\n").write(body)

    n_assert = body.count("assert_eq(") + body.count("assert_true(")
    print(
        "三级对撞：官方 %d 条 + 夹具 %d 条 + 形状读数 2 条，zlib 与 JDK 逐条相等"
        % (n_official, len(FIX))
    )
    print("读数 %d 条 → %s" % (len(lines) - 1, sys.argv[2]))
    print("用例 10 块 %d 处断言 → %s" % (n_assert, OUT_MBT))


if __name__ == "__main__":
    main()
