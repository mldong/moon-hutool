#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""第三批（SHA-1 / HMAC-SHA1）期望面生成器：官方值内嵌，先与独立实现现算对撞，撞不齐就拒绝出文件。

用法：

    python scripts/gen_sha1_test.py <readings.txt>

`<readings.txt>` 是留痕读数（按本仓惯例落在工作树外、不提交）；用例文件写死到 `digest/sha1_test.mbt`。

两级读数（缺任何一级都不出文件）：

  ① **官方向量**（验收只认这批，门禁 G6）——值逐字摘自原文（2026-10-15 现读，三种原文互为交叉）：
     · NIST 示例文档（FIPS 180-4 附录 A.2 指向 csrc.nist.gov 的 `SHA1.pdf` / `HMAC_SHA1.pdf`）：
       SHA-1 单块/两块消息两条；HMAC-SHA1 的 `keylen=blocklen`（**64 恰在边界**）与 `keylen=100` 两条；
     · RFC 3174 §7.3（官方测试驱动，四条；单块/两块两条与 NIST 同值，另含 1M 个 `a` 与
       "恰为 512 位整数倍"的 640 字节档——该档消息是 `"01234567"` 重复 80 次）；
     · RFC 2202 §3（HMAC-SHA1 全部七条 TC）。
  ② **独立实现**：Python `hashlib.sha1` / `hmac.new(sha1)` 对同一夹具现算，与 ① 逐条 `assert` 相等——
     这一步同时兜住"誊写错误"与"夹具与原文描述不符"两类事故（首轮跑就抓到过一次：TEST4 的消息
     曾被误记成另一条 112 字节串，现算对不上、脚本当场拒绝出文件）。
  其余读数（空串 / 中文 UTF-8 / 裸字节流 / 键长 65 档 / verify 档）只有 ② 一条来源，读数文件逐条标注。

四条纪律（都是本仓前几轮撞出来的）：

  · 夹具与期望串全走同一条通道（本脚本），测试文件里手打零条；标签**两向完备**——
    用到的读数必须存在（缺一条就停），读到的读数必须全被用例用到（防"生成了没人用"的悬空读数）。
  · 读数文件带 `msglen` / `keylen` / `datalen` 元数据——上一批（HMAC 家族）就是靠这类字段才看出
    参照腿自己踩了编码坑（`keylen=10` 自证 mojibake）；本批的"腿"是官方原文 + 独立实现两级，也照此留痕。
  · 期望串冻结后，落地笔（PR-B）只许把红变绿（门禁 G5）；要改期望值必须单独一笔并给外部读数来源。
  · 生成物必须 fmt 稳定：先跑一次 `moon fmt` 收敛（对齐 80 列折行），把收敛后的形状回抄进本脚本的模板。
"""
import hashlib
import hmac as hmaclib
import io
import os
import sys

OUT_MBT = os.path.join("digest", "sha1_test.mbt")

# ---------------------------------------------------------------------------
# ① 官方向量（逐字摘自原文）
# ---------------------------------------------------------------------------

# NIST 示例文档（SHA1.pdf：单块 "abc"、两块 56 字节串；HMAC_SHA1.pdf：四案例里的两条）
NIST_SHA1 = {
    "abc": "a9993e364706816aba3e25717850c26c9cd0d89d",
    "2block": "84983e441c3bd26ebaae4aa1f95129e5e54670f1",
}
NIST_HMAC = {
    # keylen=blocklen：键 00 01 … 3f（64 字节），恰在"不哈希键"一侧的边界上
    "nist64": "5fd596ee78d5553c8ff4e72d266dfd192366da29",
    # keylen=100：键 00 01 … 63，超块档（该案例的消息文本原文就是 "Sample message for keylen=blocklen"）
    "nist100": "2d51b2f7750e410584662e38f133435f4c4fd42a",
}

# RFC 3174 §7.3 测试驱动的 resultarray 四条（与 NIST 单块/两块两条同值）
RFC3174 = {
    "abc": "a9993e364706816aba3e25717850c26c9cd0d89d",
    "2block": "84983e441c3bd26ebaae4aa1f95129e5e54670f1",
    "million": "34aa973cd4c4daa4f61eeb2bdbad27316534016f",
    "exact": "dea356a2cddd90c7a7ecedc5ebb563934f460452",
}

# RFC 2202 §3 全部七条 TC（HMAC-SHA1）
RFC2202 = {
    "tc1": "b617318655057264e28bc0b6fb378c8ef146be00",
    "tc2": "effcdf6ae5eb2fa2d27416d5f184df9c259a7c79",
    "tc3": "125d7342b9ac11cd91a39af48aa17b4f63f175d3",
    "tc4": "4c9007f4026250c6bc8414f9bf50c86c2d7235da",
    "tc5": "4c1a03424b55e07fe7f27be1d58bb9324a9a5a04",
    "tc6": "aa4ae5e15272d00e95705637ce8a3b55ed402112",
    "tc7": "e8e99d0f45237d786d6bbaa7965c7808bbff1a91",
}

# ---------------------------------------------------------------------------
# 夹具（原文逐字；长度附断言，防拼接时静默截断）
# ---------------------------------------------------------------------------


def rep(n, v):
    return bytes([v]) * n


def k_of(s):
    return s.encode("utf-8")


def bs_of(xs):
    return bytes(xs)


# NIST 案例的消息文本（原文两行，注意 keylen=100 案例用的也是 "=blocklen" 这句）
NIST_MSG_64 = b"Sample message for keylen=blocklen"
NIST_KEY_64 = bytes(range(0x40))
NIST_KEY_100 = bytes(range(100))

MSGS = {
    "abc": b"abc",
    "2block": b"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
    "million": b"a" * 1000000,
    # RFC 3174 §7.3 的 TEST4："0123456701234567…"（32 字符）逐块喂十次 ⇒ 等价于 640 字节恰整除档
    "exact": b"01234567" * 80,
}
assert len(MSGS["2block"]) == 56, "两分块夹具应为 56 字节"
assert len(MSGS["exact"]) == 640, "恰整除档夹具应为 640 字节"
assert len(NIST_KEY_64) == 64 and len(NIST_KEY_100) == 100, "NIST 键长应为 64 / 100"

HMAC_CASES = {
    "tc1": (rep(20, 0x0B), b"Hi There"),
    "tc2": (b"Jefe", b"what do ya want for nothing?"),
    "tc3": (rep(20, 0xAA), rep(50, 0xDD)),
    "tc4": (bytes(range(1, 26)), rep(50, 0xCD)),
    "tc5": (rep(20, 0x0C), b"Test With Truncation"),
    "tc6": (rep(80, 0xAA), b"Test Using Larger Than Block-Size Key - Hash Key First"),
    "tc7": (
        rep(80, 0xAA),
        b"Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data",
    ),
}
NIST_CASES = {
    "nist64": (NIST_KEY_64, NIST_MSG_64),
    "nist100": (NIST_KEY_100, NIST_MSG_64),
}

# ② 只有独立实现一条来源的补档读数（读数文件会标注 hashlib）
EXTRA_SHA = {
    "s1.empty": b"",
    "s1.cn": k_of("中文"),
    "s1.raw": bytes(range(0, 16)),
}
EXTRA_HMAC = {
    "hs1.k65": (rep(65, 0x0B), b"Hi There"),
    "hs1.cn": (k_of("密钥K"), k_of("中文数据")),
    "hs1.emptydata": (b"key", b""),
}


def sha1_hex(b):
    return hashlib.sha1(b).hexdigest()


def hmac_sha1_hex(key, data):
    return hmaclib.new(key, data, hashlib.sha1).hexdigest()


def cross_check():
    """两级读数对撞：官方值必须等于独立实现现算值，一条不符就停。"""
    rows = [(sha1_hex(MSGS[t]), RFC3174[t], "RFC 3174 §7.3 " + t) for t in MSGS]
    rows += [(hmac_sha1_hex(*HMAC_CASES[t]), RFC2202[t], "RFC 2202 §3 " + t)
             for t in HMAC_CASES]
    rows += [(hmac_sha1_hex(*NIST_CASES[t]), NIST_HMAC[t], "NIST HMAC_SHA1.pdf " + t)
             for t in NIST_CASES]
    # 双源交叉：单块/两块两条在 NIST 与 RFC 3174 两处都要逐字相同
    for t in NIST_SHA1:
        assert NIST_SHA1[t] == RFC3174[t], "NIST 与 RFC 3174 的 %s 值不一致" % t
    for got, want, tag in rows:
        assert got == want, "%s 对撞失败：现算 %s ≠ 原文 %s" % (tag, got, want)
    return len(rows)


# ---------------------------------------------------------------------------
# 用例文件（模板；`@@标签@@` 由读数注入，其余一字不改）
# ---------------------------------------------------------------------------

HEAD = """///|
// 第三批（SHA-1 / HMAC-SHA1）期望面：**全部由 `scripts/gen_sha1_test.py` 灌入，手打零条**。
// 权威是官方向量（2026-10-15 现读三重原文）：NIST 示例文档（FIPS 180-4 附录 A.2 指向）的 SHA-1
// 单块/两块两条与 HMAC-SHA1 的 64 恰边界、100 超块两条；RFC 3174 §7.3 四条（含 1M 个 a 与
// 恰整除 640 字节档）；RFC 2202 §3 的 HMAC-SHA1 全部七条 TC。其余读数（空串 / 中文 UTF-8 /
// 裸字节流 / 键长 65 档 / verify 档）由本机 Python hashlib/hmac 现算，脚本先与官方值逐条对撞，
// 分岔即拒绝出文件 ⇒ 期望串不经过手打这一环。
// 夹具复用 `hmac_family_test.mbt` 的 `k_of` / `rep` / `bs_of`（同包多个 `_test.mbt` 共享顶层命名空间，
// 不重复定义）；`seq` 只在本文件定义（后续要用直接引用，别复制）。
// 契约笔落地时体是 `PR-B：契约骨架` 的 abort ⇒ 这批用例红是设计态（门禁 G5：落地笔只许把红变绿）。

///|
/// 顺序字节夹具：`0x00, 0x01, …`（NIST 案例的键形状；`rep` 表达不了等差序列，故补这一件）。
fn seq(n : Int) -> Bytes {
  let buf = @buffer.Buffer()
  for i in 0..<n {
    buf.write_byte(i.to_byte())
  }
  buf.to_bytes()
}

///|
test "sha1 #2.8 RFC 3174 §7.3 四条经典测试串（含恰整除 640 字节与百万个 a）" {
  assert_eq(@digest.sha1_hex("abc"), "@@s1.abc@@")
  assert_eq(
    @digest.sha1_hex("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
    "@@s1.2block@@",
  )
  assert_eq(
    @digest.sha1_hex("01234567".repeat(80)),
    "@@s1.exact@@",
  )
  assert_eq(@digest.sha1_hex("a".repeat(1000000)), "@@s1.million@@")
}

///|
test "sha1 #2.8 空串 / UTF-8 中文 / 裸字节流 / 长度与 of_bytes 对拍" {
  assert_eq(@digest.sha1_hex(""), "@@s1.empty@@")
  assert_eq(@digest.sha1_hex("中文"), "@@s1.cn@@")
  assert_eq(@digest.sha1_bytes("abc").length(), 20)
  assert_eq(
    @hex.encode(@digest.sha1_of_bytes(@utf8.encode("abc"))),
    "@@s1.abc@@",
  )
  assert_true(
    @digest.sha1_of_bytes(@utf8.encode("中文")) == @digest.sha1_bytes("中文"),
  )
  assert_eq(
    @hex.encode(
      @digest.sha1_of_bytes(
        Bytes::from_array([
          0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c,
          0x0d, 0x0e, 0x0f,
        ]),
      ),
    ),
    "@@s1.raw@@",
  )
}

///|
test "hmac_sha1 #2.8 RFC 2202 §3 全部七条 TC（裸字节键与数据）" {
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(rep(20, 0x0b), k_of("Hi There")),
    "@@hs1.tc1@@",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(k_of("Jefe"), k_of("what do ya want for nothing?")),
    "@@hs1.tc2@@",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(rep(20, 0xaa), rep(50, 0xdd)),
    "@@hs1.tc3@@",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(
      bs_of([
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
        24, 25,
      ]),
      rep(50, 0xcd),
    ),
    "@@hs1.tc4@@",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(rep(20, 0x0c), k_of("Test With Truncation")),
    "@@hs1.tc5@@",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(
      rep(80, 0xaa),
      k_of("Test Using Larger Than Block-Size Key - Hash Key First"),
    ),
    "@@hs1.tc6@@",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(
      rep(80, 0xaa),
      k_of(
        "Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data",
      ),
    ),
    "@@hs1.tc7@@",
  )
}

///|
test "hmac_sha1 #2.8 NIST 示例两档（keylen=blocklen 64 恰边界 / keylen=100 超块）" {
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(seq(0x40), k_of("Sample message for keylen=blocklen")),
    "@@hs1.nist64@@",
  )
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(seq(100), k_of("Sample message for keylen=blocklen")),
    "@@hs1.nist100@@",
  )
}

///|
test "hmac_sha1 #2.8 键长 65 档 + String 档与字节档同读" {
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(rep(65, 0x0b), k_of("Hi There")),
    "@@hs1.k65@@",
  )
  assert_eq(@digest.hmac_sha1_hex("key", ""), "@@hs1.emptydata@@")
  assert_eq(@digest.hmac_sha1_hex("密钥K", "中文数据"), "@@hs1.cn@@")
  assert_eq(
    @digest.hmac_sha1_hex_of_bytes(k_of("Jefe"), k_of("what do ya want for nothing?")),
    @digest.hmac_sha1_hex("Jefe", "what do ya want for nothing?"),
  )
}

///|
test "hmac_sha1 #2.8 verify（真 / 改一位 / 大写 / 非十六进制 / 奇数长度）" {
  let k = k_of("Jefe")
  let d = k_of("what do ya want for nothing?")
  assert_eq(@digest.hmac_sha1_verify_hex(k, d, "@@hs1.tc2@@"), true)
  assert_eq(@digest.hmac_sha1_verify_hex(k, d, "@@hs1.tc2.flip@@"), false)
  assert_eq(@digest.hmac_sha1_verify_hex(k, d, "@@hs1.tc2.upper@@"), true)
  assert_eq(@digest.hmac_sha1_verify_hex(k, d, "@@hs1.tc2.badhex@@"), false)
  assert_eq(@digest.hmac_sha1_verify_hex(k, d, "@@hs1.tc2.odd@@"), false)
}
"""


def build_readings():
    """组装 (标签 → (值, 元数据))。"""
    vals = {}
    meta = {}

    for tag, msg in MSGS.items():
        vals["s1." + tag] = sha1_hex(msg)
        src = "RFC 3174 §7.3" + (" + NIST SHA1.pdf" if tag in NIST_SHA1 else "")
        meta["s1." + tag] = "msglen=%d|official=%s" % (len(msg), src)
    for tag, msg in EXTRA_SHA.items():
        vals[tag] = sha1_hex(msg)
        meta[tag] = "msglen=%d|provider=hashlib.sha1" % len(msg)
    for tag, (key, data) in HMAC_CASES.items():
        vals["hs1." + tag] = hmac_sha1_hex(key, data)
        meta["hs1." + tag] = "keylen=%d,datalen=%d|official=RFC 2202 §3 %s" % (
            len(key),
            len(data),
            tag.upper(),
        )
    for tag, (key, data) in NIST_CASES.items():
        vals["hs1." + tag] = hmac_sha1_hex(key, data)
        meta["hs1." + tag] = "keylen=%d,datalen=%d|official=NIST HMAC_SHA1.pdf" % (
            len(key),
            len(data),
        )
    for tag, (key, data) in EXTRA_HMAC.items():
        vals[tag] = hmac_sha1_hex(key, data)
        meta[tag] = "keylen=%d,datalen=%d|provider=hashlib/hmac" % (len(key), len(data))

    # verify 档的四个派生夹具（同一读数上的机械变换：翻末位 / 大写 / 换非法字符 / 截一位）
    tc2 = vals["hs1.tc2"]
    last = "a" if tc2[-1] != "a" else "b"
    vals["hs1.tc2.flip"] = tc2[:-1] + last
    vals["hs1.tc2.upper"] = tc2.upper()
    vals["hs1.tc2.badhex"] = "z" + tc2[1:]
    vals["hs1.tc2.odd"] = tc2[:-1]
    for tag in ("hs1.tc2.flip", "hs1.tc2.upper", "hs1.tc2.badhex", "hs1.tc2.odd"):
        meta[tag] = "derived=hs1.tc2|provider=mechanical"
    return vals, meta


def render(vals):
    """模板注入 + 两向完备检查。"""
    used = set()

    def sub_line(line):
        out = line
        while "@@" in out:
            lo = out.index("@@")
            hi = out.index("@@", lo + 2)
            label = out[lo + 2 : hi]
            if label not in vals:
                sys.exit("缺读数：模板引用了 %s，读数表里没有" % label)
            used.add(label)
            out = out[:lo] + vals[label] + out[hi + 2 :]
        return out

    body = "\n".join(sub_line(l) for l in HEAD.splitlines()) + "\n"
    missing = sorted(set(vals) - used)
    if missing:
        sys.exit("有读数没被用例用到（悬空）：%s" % "，".join(missing))
    return body


def main():
    if len(sys.argv) < 2:
        sys.exit("用法：python scripts/gen_sha1_test.py <readings.txt>")

    n_cross = cross_check()
    print("官方对撞：RFC 3174 四条 + RFC 2202 七条 + NIST 两条 = %d/%d 与现算逐条相等" % (n_cross, n_cross))

    vals, meta = build_readings()
    body = render(vals)

    lines = [
        "# SHA-1 / HMAC-SHA1 读数（scripts/gen_sha1_test.py 生成；列：标签|十六进制|元数据）",
    ]
    for label in sorted(vals):
        lines.append("%s|%s|%s" % (label, vals[label], meta[label]))
    io.open(sys.argv[1], "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")

    io.open(OUT_MBT, "w", encoding="utf-8", newline="\n").write(body)

    n_assert = body.count("assert_eq(") + body.count("assert_true(")
    print("读数 %d 条 → %s" % (len(vals), sys.argv[1]))
    print("用例 6 块 %d 断言 → %s" % (n_assert, OUT_MBT))


if __name__ == "__main__":
    main()
