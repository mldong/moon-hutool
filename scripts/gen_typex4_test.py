#!/usr/bin/env python
# typex 第六批补档生成器：把 TypexLeg4.java 的读数灌成 typex/typex_deep6_test.mbt。
# 一条断言一个 test 块；期望只从腿的读数取，手打零条。
# 用法：python scripts/gen_typex4_test.py <typex4_leg.txt>
import io
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if len(sys.argv) < 2:
    raise SystemExit("用法：python scripts/gen_typex4_test.py <typex4_leg.txt>")
LEG = os.path.abspath(sys.argv[1])
OUT = os.path.join(REPO, "typex", "typex_deep6_test.mbt")

# 已声明的改判档（期望取本库形状，腿的原读数一律留在断言注释里）：
#   R/neg-total —— 参照 `new int[负]` 抛 NegativeArraySizeException，本库给空表
#   （typex.mbt 的注释与 docs/spec/23-typex.md §5 第 6 行都在案）
#   VC/strunit、VC/under —— 参照 `compareTo` 给**原始差值**（字符串档给码元差），
#   spec 23-typex §"compareTo 返回值"第 4 条已写明"腿的 CMP 读数本身就是符号档 ⇒ 本库出口归一成 -1/0/1"
#   IT/A123456(7)、IT/Z324567(8) —— 参照在坏形状上走 `Integer.parseInt` 抛 NumberFormatException，
#   spec 23-typex §港澳台那行已写明"本库三件都不设错误面，这类串一律判假"
DECL = {
    ("R", "neg-total"): "-",
    ("VC", "strunit"): "-1",
    ("VC", "under"): "1",
    ("IT", "A123456(7)"): "false",
    ("IT", "Z324567(8)"): "false",
}

CITE = {
    ("R", "neg-total"): "（本库改判，见 spec 23-typex §5 第 6 行）",
    ("VC", "strunit"): "（参照给原始差值，本库归一成符号档，见 spec 23-typex「compareTo 返回值」第 4 条）",
    ("VC", "under"): "（参照给原始差值 46，本库归一成 1，同号；规格化是本库契约，见同一条）",
    ("IT", "A123456(7)"): "（参照抛 NumberFormatException，本库不设这枚错误面 ⇒ 判假，见 spec 23-typex 港澳台那行）",
    ("IT", "Z324567(8)"): "（同上）",
}

# 没有"登记而不钉"的档了：四条都能在 spec 里指到既有决策行，指不到的整条不进批次。
DROP = set()


HEAD = '''///|
// typex 深档补档（10-08）——rainbow 三档、Version 的构建元数据与字符串单元档、
// DataSize 的空白码点档、港澳台 10 位形状拒收档。
// 期望全部由 TypexLeg4.java 现读灌入（hutool-core 5.8.35 · JDK 17.0.14 · -Dfile.encoding=UTF-8），手打零条。
// 不可见码点夹具在腿里用 codePoint 现构，读数行打的是 0xNN 序列；生成器按同一序列还原成 MoonBit 字面量，
// 人不手打一个字符。异常档只钉"抛不抛"，变体名不由这条腿授权。

///|
fn t4_rain(cur : Int, total : Int, cnt : Int) -> String {
  let mut s = ""
  for v in @typex.page_rainbow_count(cur, total, cnt) {
    if s != "" {
      s = s + ";"
    }
    s = s + v.to_string()
  }
  if s == "" {
    "-"
  } else {
    s
  }
}

///|
fn t4_vc(a : String, b : String) -> String {
  @typex.version_compare(@typex.version_of(a), @typex.version_of(b)).to_string()
}

///|
fn t4_vt(a : String) -> String {
  @typex.version_to_string(@typex.version_of(a))
}

///|
fn t4_dp(s : String) -> String {
  try {
    @typex.data_size_parse_bytes(s).to_string()
  } catch {
    _ => "RAISE"
  }
}

///|
fn t4_hk(s : String) -> String {
  @typex.idcard_is_valid_hk_card(s).to_string()
}

///|
fn t4_tw(s : String) -> String {
  @typex.idcard_is_valid_tw_card(s).to_string()
}

'''

BLOCKS = []


def lit(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def cps_to_moonbit(cps):
    out = ['"']
    for h in cps.split("+"):
        cp = int(h, 16)
        if 0x20 <= cp <= 0x7E and cp not in (0x22, 0x5C):
            out.append(chr(cp))
        else:
            out.append("\\u{%x}" % cp)
    out.append('"')
    return "".join(out)


def blk(name, comment, expr):
    if name in DROP:
        return
    BLOCKS.append((name, comment, expr))


def main():
    rows = []
    for raw in io.open(LEG, encoding="utf-8", errors="replace").read().replace("\r", "").splitlines():
        f = raw.split("|")
        if len(f) < 2 or f[0] == "G":
            continue
        rows.append(f)

    for f in rows:
        k = f[0]
        if k == "R":
            _, name, cur, total, cnt, val = f
            exp = DECL.get(("R", name), val)
            blk("rain-" + name,
                "page_rainbow_count ｜ current=%s total=%s show=%s ｜ 参照 rainbow(pageNo,totalPage,displayCount)=%s%s"
                % (cur, total, cnt, val, "" if exp == val else "（本库改判，见 spec 23-typex §5 第 6 行）"),
                "assert_eq(t4_rain(%s, %s, %s), %s)" % (cur, total, cnt, lit(exp)))
        elif k == "VC":
            _, name, a, b, val = f
            exp = DECL.get(("VC", name), val)
            blk("vc-" + name,
                "version_compare ｜ %s vs %s ｜ 参照 compareTo=%s%s"
                % (a, b, val, CITE.get(("VC", name), "")),
                "assert_eq(t4_vc(%s, %s), %s)" % (lit(a), lit(b), lit(exp)))
        elif k == "VT":
            _, name, a, val = f
            blk("vt-" + name,
                "version_to_string ｜ %s ｜ 参照 toString=%s" % (a, val),
                "assert_eq(t4_vt(%s), %s)" % (lit(a), lit(val)))
        elif k == "DP":
            _, cps, val = f
            exp = "RAISE" if val.startswith("ERR") else val
            blk("dp-" + cps.replace("+", "-"),
                "data_size_parse_bytes ｜ 码点=%s ｜ 参照 DataSizeUtil.parse=%s%s"
                % (cps, val, "" if exp == val else "（参照抛、本库也抛，只钉抛不抛）"),
                "assert_eq(t4_dp(%s), %s)" % (cps_to_moonbit(cps), lit(exp)))
        elif k == "IH":
            blk("ih-" + f[1], "idcard_is_valid_hk_card ｜ %s ｜ 参照 isValidHKCard=%s" % (f[1], f[2]),
                "assert_eq(t4_hk(%s), %s)" % (lit(f[1]), lit(f[2])))
        elif k == "IT":
            exp = DECL.get(("IT", f[1]), f[2])
            blk("it-" + f[1], "idcard_is_valid_tw_card ｜ %s ｜ 参照 isValidTWCard=%s%s"
                % (f[1], f[2], CITE.get(("IT", f[1]), "")),
                "assert_eq(t4_tw(%s), %s)" % (lit(f[1]), lit(exp)))
        elif k == "I10":
            # 参照 isValidCard10 给的是"两种可接受写法"的数组，本库没有同形状出口
            # （#23.111 的 IdcardInfo10 是 region/gender/valid 三槽）⇒ 形状不同源，不比。
            pass

    body = HEAD + "\n\n".join(
        '///|\ntest "typex 深档 %s" {\n  // %s\n  %s\n}' % (n, c, e) for n, c, e in BLOCKS) + "\n"
    io.open(OUT, "w", encoding="utf-8", newline="\n").write(body)
    print("blocks=%d dropped=%d file=%s" % (len(BLOCKS), len(DROP), OUT))


main()
