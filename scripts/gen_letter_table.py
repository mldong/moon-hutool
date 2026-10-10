#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""批③（codec 第二片）字母区间表生成器：把 `Character.isLetter` 的 BMP 判定灌成一张数据件。

用法（腿读数文件落在工作树外、不提交）：

    python scripts/gen_letter_table.py <LetterRangesLeg.txt>

产出两份：
- `codec/letter_table.mbt` —— 380 段半开区间 `[lo,hi)` 与一个私有的逐码元谓词（二分查表）；
- `codec/letter_table_wbtest.mbt` —— **白盒**用例：扫全 BMP 把「表判出来的字母」与参照的三条全域
  读数（总数、码元和 mod 2147483647、按 0x1000 分块的计数）逐条对撞，另钉边界点与代理码元档。

四条纪律：

1. **表与谓词都不公开**。这是 `Caesar` 守卫的实现机制，不是本库对外承诺的能力；公开面多一个
   `is_unicode_letter_*` 就等于多一条要维护的契约（`.mbti` 是冻结面）。
2. **判据取全域量，不逐位钉**（`dfa` 轮那条）：钉 48909 条等于把表抄第二遍。扫 BMP 的计数与
   码位和两条一起，才够说"表与参照同判"；边界点只补那六个跨界码位。
3. **生产者指纹必须进文件头**：`isLetter` 的底层是 JDK 自带 Unicode 数据，换大版本可能挪区间。
   这张表冻的是"参照代次 5.8.37 × 腿里那台 JDK"的同判，指纹从腿读、不手写。
4. **守恒校验在生成之前**：区间有序、两两不相邻可并、覆盖数 == 腿的全域计数——任何一条不成立
   就停，不出文件。生成器自证的从来不是"跑通了"，是"数字对得上"。
"""
import io
import re
import sys

SRC = sys.argv[1] if len(sys.argv) > 1 else None
if not SRC:
    sys.exit("用法：python scripts/gen_letter_table.py <LetterRangesLeg.txt>")

text = io.open(SRC, encoding="utf-8", newline="").read()
lines = text.split("\n")


def one(prefix):
    hits = [l for l in lines if l.startswith(prefix)]
    assert len(hits) == 1, "%s 命中 %d 条（应为 1 条）" % (prefix, len(hits))
    return hits[0].split("||", 1)[1].strip()


ranges = []
for l in lines:
    if l.startswith("LR|range||"):
        lo, hi = l.split("||", 1)[1].split(",")
        ranges.append((int(lo), int(hi)))
count = int(one("LR|count||"))
sum_mod = int(one("LR|sum-mod||"))
java = one("LR|java-version||")
blocks = one("LR|blocks||")
edge = one("LR|edge||")
surro = one("LR|surrogate||")
rc = int(one("LR|range-count||"))

# ---- 守恒校验（不成立就不出文件） ----
assert ranges == sorted(ranges), "区间没按起点排序"
assert len(ranges) == rc, "区间条数 %d 与腿自报 %d 不符" % (len(ranges), rc)
for i in range(len(ranges)):
    lo, hi = ranges[i]
    assert 0 <= lo < hi <= 0x10000, "第 %d 段 [%d,%d) 越出 BMP" % (i, lo, hi)
    if i + 1 < len(ranges):
        nlo, nhi = ranges[i + 1]
        assert lo < nlo, "第 %d/%d 段起点不严格递增" % (i, i + 1)
        # 相邻可并 = 参照那两个码位之间没有断点，说明腿的收尾逻辑与这里不一致
        assert hi != nlo, "第 %d/%d 段本可合并成 [%d,%d)——腿的区间收尾有问题" % (i, i + 1, lo, nhi)
covered = sum(hi - lo for lo, hi in ranges)
assert covered == count, "覆盖 %d 个码元，腿的全域计数是 %d ⇒ 不同判" % (covered, count)


def pairs(prefix):
    out = []
    for tok in prefix.rstrip(",").split(","):
        k, v = tok.split("=")
        out.append((int(k), int(v)))
    return out


edges = pairs(edge)
surr = pairs(surro)
block_n = []
for tok in blocks.rstrip(",").split(","):
    b, n = tok.split(":")
    block_n.append((int(b), int(n)))
assert sum(n for _, n in block_n) == count, "分块计数之和与全域计数不符"

# ---- 生成件一：表 + 私有谓词 ----
tbl = []
tbl.append("///|")
tbl.append(
    "// letter_table.mbt —— BMP 的 Unicode 字母码位区间表。**生成件，勿手改**："
)
tbl.append(
    "//   腿 scripts/LetterRangesLeg.java 出读数，生成器 scripts/gen_letter_table.py 灌本文件与"
    " codec/letter_table_wbtest.mbt，生成后过 `moon fmt`。"
)
tbl.append(
    "// 用途只有一个：`Caesar` 的守卫。参照侧写的是 `Character.isLetter(char)`（Unicode 档），"
)
tbl.append(
    "// 而本版 MoonBit core 的 `Char` 没有任何 Unicode 字母谓词（公开 is_* 只有 ASCII 档与"
    " control/digit/whitespace/numeric/printable/bmp）——不收窄语义、也不发明近似档，"
    "把这张判定表自己带进来。契约见 docs/spec/05-codec.md。"
)
tbl.append("// 血统：hutool 5.8.37 的 `Caesar`；表的生产者指纹 `%s`——" % java)
tbl.append(
    "// `isLetter` 的底层是 JDK 自带 Unicode 数据，换大版本可能挪区间，所以这里冻的是"
    "「与该 JDK 同判」，用例把三条全域读数逐条对撞（见 `letter_table_wbtest.mbt`）。"
)
tbl.append(
    "// 表体：%d 段半开区间 [lo, hi)，覆盖 %d 个码元；全域码元和 mod 2147483647 = %d。"
    % (len(ranges), count, sum_mod)
)
tbl.append("// 判的是 **UTF-16 码元**不是码位：代理区两个码位都不算字母（腿 `LR|surrogate` 四档），"
           "所以调用方必须逐码元摊（`utf16_codes`），别按码位走。")
tbl.append("")
tbl.append("///|")
tbl.append("/// 字母区间的半开上界表（按起点升序，两两不相邻可并）。")
tbl.append("let letter_ranges : Array[(Int, Int)] = [")
row = []
for lo, hi in ranges:
    row.append("(%d, %d)" % (lo, hi))
for i in range(0, len(row), 6):
    tbl.append("  " + ", ".join(row[i:i + 6]) + ("," if i + 6 < len(row) else ""))
tbl.append("]")
tbl.append("")
tbl.append("///|")
tbl.append("/// 该 UTF-16 码元在参照的 `Character.isLetter` 眼里是不是字母（二分查上面的表）。")
tbl.append("///")
tbl.append("/// - Note: 私有——这是 `Caesar` 守卫的实现机制，不是对外能力；公开它会多一条要维护的契约。")
tbl.append("fn is_letter_unit(unit : Int) -> Bool {")
tbl.append("  let mut lo = 0")
tbl.append("  let mut hi = letter_ranges.length() - 1")
tbl.append("  while lo <= hi {")
tbl.append("    let mid = (lo + hi) / 2")
tbl.append("    let seg = letter_ranges[mid]")
tbl.append("    if unit < seg.0 {")
tbl.append("      hi = mid - 1")
tbl.append("    } else if unit >= seg.1 {")
tbl.append("      lo = mid + 1")
tbl.append("    } else {")
tbl.append("      return true")
tbl.append("    }")
tbl.append("  }")
tbl.append("  false")
tbl.append("}")
io.open("codec/letter_table.mbt", "w", encoding="utf-8", newline="\n").write("\n".join(tbl) + "\n")

# ---- 生成件二：白盒用例（全域对撞） ----
t = []
t.append("///|")
t.append(
    "/// 字母区间表的自证：**扫全 BMP**，把表判出来的字母集与参照腿的三条全域读数逐条对撞"
)
t.append("/// （契约 `docs/spec/05-codec.md` 的表那一节）。表与谓词都是私有的，所以这一份是白盒件。")
t.append("///")
t.append("/// 三条都是守恒判据，缺一就不是同判：")
t.append("/// - 条数与全域码元数（`LR|count`）——少了会漏字母，多了会把标点算进来；")
t.append("/// - 码位和 mod 2147483647（`LR|sum-mod`）——同数不同位的替换（把 A 段挪成 B 段）抓得住；")
t.append("/// - 按 0x1000 分块的 16 个计数（`LR|blocks`）——全域量撞不出来的**局部挪动**抓得住。")
t.append("///")
t.append("/// 生产者指纹 %s；换 JDK 大版本这三条就可能挪，届时重跑腿再重出本件，别手改期望值。" % java)
t.append("test \"codec 字母表与参照 isLetter 逐码元同判（BMP 全域三条读数）\" {")
t.append("  let mut total = 0")
t.append("  let mut sum : Int64 = 0L")
t.append("  let block_counts : Array[Int] = []")
t.append("  for b in 0..<=15 {")
t.append("    let mut n = 0")
t.append("    for i in 0..<=0xfff {")
t.append("      let c = (b << 12) | i")
t.append("      if is_letter_unit(c) {")
t.append("        n += 1")
t.append("        total += 1")
t.append("        sum = (sum + c.to_int64()) % 2147483647L")
t.append("      }")
t.append("    }")
t.append("    block_counts.push(n)")
t.append("  }")
t.append("  assert_eq(total, %d) // 读数腿  LR|count" % count)
t.append("  assert_eq(sum, %dL) // 读数腿  LR|sum-mod" % sum_mod)
blocks_lines = []
for b, n in block_n:
    blocks_lines.append("  assert_eq(block_counts[%d], %d) // 读数腿  LR|blocks 第 %d 块" % (b, n, b))
t.append("\n".join(blocks_lines) if blocks_lines else "  // 无分块读数")
t.append("  // 没读到的块也要显式钉 0，否则分块判据是残缺的")
zeros = [b for b in range(16) if b >= len(block_n)]
for b in zeros:
    t.append("  assert_eq(block_counts[%d], 0) // 腿未列该块 ⇒ 该块零字母" % b)
t.append("}")
t.append("")
t.append("///|")
t.append("/// 六个跨界码位（区间端点的开闭各钉一刀）+ 代理区四档。")
t.append("test \"codec 字母表的边界点与代理码元档\" {")
for c, v in edges:
    t.append("  assert_eq(is_letter_unit(%d), %s) // 读数腿  LR|edge %d=%d"
             % (c, "true" if v == 1 else "false", c, v))
t.append("  // 代理码位两侧都不算字母 ⇒ 逐码元摊时代理对整体也不参与移位")
for c, v in surr:
    t.append("  assert_eq(is_letter_unit(%d), %s) // 读数腿  LR|surrogate %d=%d"
             % (c, "true" if v == 1 else "false", c, v))
t.append("}")
io.open("codec/letter_table_wbtest.mbt", "w", encoding="utf-8", newline="\n").write("\n".join(t) + "\n")

sys.stderr.write(
    "表 %d 段 / 覆盖 %d / sum-mod %d / 用例两份已出（生产者 %s）\n"
    % (len(ranges), covered, sum_mod, java)
)
