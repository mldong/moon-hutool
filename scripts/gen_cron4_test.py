#!/usr/bin/env python
# cron 第四批补档生成器：把腿的读数（scripts/Cron4Leg.java 的 stdout）灌成 cron/cron_zone_test.mbt。
# 一条断言一个 test 块（cron 第一批那条教训：块红会掩盖块内未跑）。
# 期望全部来自腿的读数，手打零条；腿里没给的形状（错误变体名）不进断言，只在注释留原文。
import io
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# 用法：python scripts/gen_cron4_test.py <cron4_leg.txt>
#   腿的跑法：javac -encoding UTF-8 -cp "$HUTOOL_CORE:$HUTOOL_CRON" scripts/Cron4Leg.java
#   java -cp ".:$HUTOOL_CORE:$HUTOOL_CRON" Cron4Leg > cron4_leg.txt（两罐 jar 现读，别写死版本）
if len(sys.argv) < 2:
    raise SystemExit("用法：python scripts/gen_cron4_test.py <cron4_leg.txt>")
LEG = os.path.abspath(sys.argv[1])
OUT = os.path.join(REPO, "cron", "cron_zone_test.mbt")

# 本库自订档（spec 已记为改判，期望按本库形状钉，腿的原读数留在注释里）：
#   cnt-0 / cnt-neg  → Some([])（spec 19-cron §11 第 2 行）
#   z-badname        → NOWINDOW（§11 第 4 行：坏区名不外推）
SKIP = []

# 登记而不钉的档：两侧形状不同，钉任何一侧都是替它立法。参照源码在案：
#   YearValueMatcher.nextAfter 遍历 LinkedHashSet（插入序）返回第一个 >= value，
#   所以 "2030,2024" 从 2024 起算给的是 2030；本库先排序再取最小 ⇒ 给 2024。
# 年列表的"集合命中"那一侧（M 族）两侧同值，照钉，未覆盖行也正好由它转绿。
DROP = {("yr-sort", "N"), ("yr-sort", "N2"), ("yr-desc", "N"), ("yr-desc", "N2"),
        ("yr-jan", "N"), ("yr-jan", "N2")}

OURS = {
    ("cnt-0", "M"): "-",
    ("cnt-neg", "M"): "-",
    ("z-badname", "M"): "NOWINDOW",
    ("z-badname", "N"): "NOWINDOW",
    ("z-badname", "N2"): "NOWINDOW",
    # 窗外 ⇒ None：PR-A 就写死的决定，参照那一侧给的是 2099 年的真读数
    ("z-window", "N"): "NOWINDOW",
    ("z-window", "N2"): "NOWINDOW",
    # 候选在表窗内、折算后的落点出表窗（zone_util:293）：本库不外推，参照给 2050 年的真读数
    ("win-land", "M"): "NOWINDOW",
    ("win-land", "N"): "NOWINDOW",
    ("win-land", "N2"): "NOWINDOW",
}


def unesc(s):
    return s.replace("{bar}", "|").replace("{semi}", ";")


def read_leg():
    cases = {}
    order = []
    for raw in io.open(LEG, encoding="utf-8", errors="replace").read().replace("\r", "").splitlines():
        f = raw.split("|")
        kind = f[0]
        if kind == "G":
            continue
        cid = f[1]
        if cid not in cases:
            cases[cid] = {"pattern": unesc(f[2]), "raw": {}}
            order.append(cid)
        c = cases[cid]
        if kind == "C":
            # C|id|pattern|<RET|ERR:类名>|<payload>
            c["Cst"], c["Cval"] = f[3], (f[4] if len(f) > 4 else "-")
        elif kind == "M":
            # M|id|pattern|zone|start|end|count|exact|<RET|ERR:类名>|<payload>|n=k
            c["zone"], c["start"], c["end"], c["count"] = f[3], f[4], f[5], f[6]
            c["Mst"], c["Mval"] = f[8], f[9]
            c["Mfull"] = raw
        elif kind in ("N", "N2"):
            # N|id|pattern|base|<RET|ERR:类名>|<ms|->|<ISO|->
            c[kind + "st"], c[kind + "val"] = f[4], (f[5] if len(f) > 5 else "-")
    return cases, order


def lit(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


HEAD = '''///|
// cron 区窗与解析档补档（10-08）——别名两档、负步进回绕、列表内通配、零填充步进、三类语法错、
// BadAlias 三档、年列表乱序、`|` 多子表达式、count 非正与坏区名两档、空洞/重叠三档。
// 期望全部由 Cron4Leg.java 现读灌入（hutool-cron 5.8.35 · JDK 17.0.14 · 每条先 setDefault(区)），手打零条。
// 腿只授权"抛不抛"，不授权 CronError 的变体名 ⇒ 错误档一律钉 OK/RAISE 形状，原文消息留在注释。
// 本库自订档（count 非正、坏区名）按 spec 19-cron §11 的改判钉本库形状，腿的原读数同样留在注释。

///|
fn z4_join(arr : Array[Int64]) -> String {
  let mut s = ""
  for v in arr {
    if s.length() > 0 {
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
fn z4_md(pat : String, zone : String, start : Int64, end : Int64, count : Int) -> String {
  try {
    let c = @cron.cron_of(pat)
    match @cron.cron_matched_dates(c, zone, start, end, count, false) {
      None => "NOWINDOW"
      Some(arr) => z4_join(arr)
    }
  } catch {
    _ => "ERR"
  }
}

///|
fn z4_after(pat : String, zone : String, base : Int64) -> String {
  try {
    match @cron.cron_next_match_after_in(@cron.cron_of(pat), zone, base) {
      None => "NOWINDOW"
      Some(v) => v.to_string()
    }
  } catch {
    _ => "ERR"
  }
}

///|
fn z4_next(pat : String, zone : String, base : Int64) -> String {
  try {
    match @cron.cron_next_match_in(@cron.cron_of(pat), zone, base) {
      None => "NOWINDOW"
      Some(v) => v.to_string()
    }
  } catch {
    _ => "ERR"
  }
}

///|
fn z4_tag(pat : String) -> String {
  try {
    let _ = @cron.cron_of(pat)
    "OK"
  } catch {
    _ => "RAISE"
  }
}

///|
fn z4_text(pat : String) -> String {
  try {
    @cron.cron_pattern_text(@cron.cron_of(pat))
  } catch {
    _ => "RAISE"
  }
}

'''


def blocks(cases, order, overrides):
    out = []
    n = 0
    for cid in order:
        c = cases[cid]
        pat = c["pattern"]
        zone = c.get("zone", "UTC")
        start, end, count = c["start"], c["end"], c["count"]
        base = start
        # C 族：解析档 + 原文
        okc = "OK" if c["Cst"].startswith("RET") else "RAISE"
        out.append(
            'test "cron 区窗 %s C" {\n'
            '  // cron_of ｜ pattern=%s ｜ 参照=%s %s\n'
            '  assert_eq(z4_tag(%s), "%s")\n'
            '}' % (cid, pat, c["Cst"], unesc(c["Cval"]), lit(pat), okc)
        )
        n += 1
        if okc == "OK":
            txt = unesc(c["Cval"])
            out.append(
                'test "cron 区窗 %s T" {\n'
                '  // cron_pattern_text ｜ 参照 toString=%s\n'
                '  assert_eq(z4_text(%s), %s)\n'
                '}' % (cid, txt, lit(pat), lit(txt))
            )
            n += 1
        # M 族
        mval = "ERR" if c["Mst"].startswith("ERR") else unesc(c["Mval"])
        mexp = overrides.get((cid, "M"), mval)
        out.append(
            'test "cron 区窗 %s M" {\n'
            '  // matched_dates ｜ pattern=%s ｜ zone=%s ｜ [%s,%s) ｜ count=%s ｜ 参照=%s %s\n'
            '  assert_eq(z4_md(%s, %s, %sL, %sL, %s), %s)\n'
            '}' % (cid, pat, zone, start, end, count, c["Mst"], c.get("Mval", "-"),
                   lit(pat), lit(zone), start, end, count, lit(mexp))
        )
        n += 1
        # N / N2 族
        for k in ("N", "N2"):
            if k + "st" not in c:
                continue
            v = "ERR" if c[k + "st"].startswith("ERR") else unesc(c[k + "val"])
            if (cid, k) in DROP:
                SKIP.append("%s/%s(DROP)" % (cid, k))
                continue
            if v == "-":
                # 腿的 "-" = 参照那一族没往前走（nextMatch 原地返回）——它不是一条"值读数"，
                # 拿它当期望等于替参照发明语义；只进注释不进断言
                SKIP.append("%s/%s" % (cid, k))
                continue
            vexp = overrides.get((cid, k), v)
            fn = "z4_after" if k == "N" else "z4_next"
            out.append(
                'test "cron 区窗 %s %s" {\n'
                '  // %s ｜ pattern=%s ｜ zone=%s ｜ base=%s ｜ 参照=%s %s\n'
                '  assert_eq(%s(%s, %s, %sL), %s)\n'
                '}' % (cid, k, fn, pat, zone, base, c[k + "st"], c[k + "val"],
                       fn, lit(pat), lit(zone), base, lit(vexp))
            )
            n += 1
    return out, n


def main():
    cases, order = read_leg()
    overrides = OURS
    if len(sys.argv) > 1 and sys.argv[1] == "--override":
        # 从 probe 结果文件读入本库形状（仅在改判/分岔已归案后使用）
        overrides = dict(OURS)
        for line in io.open(sys.argv[2], encoding="utf-8").read().splitlines():
            m = re.match(r"^(\S+)\t(\S+)\t(.*)$", line)
            if m:
                overrides[(m.group(1), m.group(2))] = m.group(3)
    bl, n = blocks(cases, order, overrides)
    body = HEAD + "\n\n".join(["///|\n" + b for b in bl]) + "\n"
    io.open(OUT, "w", encoding="utf-8", newline="\n").write(body)
    print("cases=%d blocks=%d file=%s" % (len(order), n, OUT))
    print("skip_no_progress(%d)=%s" % (len(SKIP), ",".join(SKIP)))


main()
