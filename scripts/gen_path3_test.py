#!/usr/bin/env python
# path 修复笔的期望生成器：把 PathLeg3.java 的逐对直读灌成 path/path_cmp3_test.mbt。
# 用法：python scripts/gen_path3_test.py <path3_leg.txt>
# 期望只从腿的读数取，手打零条。五类行：
#   T = 参照 tokenizePath 的逐串段表（切分器那一笔的根因证据；本包同包测试可调 private `tokenize`）
#   M = match / matchStart / extractPathWithinPattern
#   N = do_match 的失败出口 + extractUriTemplateVariables + combine
#   E = sep=空串 档（参照构造即抛 ⇒ 无对位行为，钉本库形状）
#   C = getPatternComparator(path) 的逐对比较
# 参照抛错的档（读数形如 ERR:<类名>）先落成占位字面量 "ME"，跑一遍由红样回填本库形状
# （依据行写进 docs/spec/15-path.md §10）——不许拍脑袋替参照"猜"一个本库值。
import io
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if len(sys.argv) < 2:
    raise SystemExit("用法：python scripts/gen_path3_test.py <path3_leg.txt>")
LEG = os.path.abspath(sys.argv[1])
OUT = os.path.join(REPO, "path", "path_cmp3_test.mbt")

# 本库形状档：值 = 最终写进断言的 MoonBit 字面量文本。键 = (verb, pattern, path)。
# 每一条的"本库值"都是上一轮跑出来的红样读数（不是猜的），依据行都在 docs/spec/15-path.md §10：
#   · Java-only 子表达式 `{n:\d+}` —— core 方言编不出来 ⇒ 匹配面给假（§5 第 2 行），参照给真；
#   · `{*p}` 抽变量 —— 两侧**都抛**，只是载体不同（§5 第 3 行）；
#   · combine 两侧后缀都非全能 —— 两侧**都抛**（ExtensionConflict ↔ IllegalArgumentException）；
#   · sep=空串 四档 —— 参照 `new AntPathMatcher("")` 构造即抛、没有对位行为，本库是防御档。
B = chr(92)
DECL = {
    ("m", "/a/{n:" + B + "d+}/b", "/a/12/b"): "false",
    ("x", "/a/**/{*p}", "/a/b/c"): '"CapturingVar *p"',
    ("c", "/*.jsp", "/x.txt"): '"ExtensionConflict /*.jsp|/x.txt"',
    ("x", "/x/**/{n:(a)(b)}/**/y", "/x/p/q/y"): '"CaptureGroupRegex {n:(a)(b)}"',
    ("x", "/**/{n:(a)(b)}/y", "/p/q/y"): '"CaptureGroupRegex {n:(a)(b)}"',
    ("e", "/a/b", "/a/b"): "true",
    ("e", "/a/b", "/ab"): "false",
    ("e", "abc", "abc"): "true",
    ("e", "/a/*", "/a/b"): "true",
}

HEAD = '''///|
// path 修复笔的逐对直读（10-08）——切分器段表 10 条、匹配/抽段 27 条、失败出口与组合/变量 18 条、
// 比较器 26 对，全部由 `scripts/PathLeg3.java` 现读灌入（hutool-core 5.8.35 · JDK 17.0.14），手打零条。
// 参照件全走公开面：`match` / `matchStart` / `extractPathWithinPattern` /
// `extractUriTemplateVariables` / `combine` / `getPatternComparator(path)`，
// 外加子类化 `AntPathMatcher` 把 protected 的 `tokenizePath` 拖出来逐串打印（T 行，根因证据见 spec §9）。
// M 行钉 §7.1 表里"尾随分隔符 4 + 抽段 1"那五条及受"丢空段"影响的邻档；C 行钉比较器那六条（§8）；
// N 行按 `do_match` 的失败出口配对；E 行的参照在 sep=空串 下**构造即抛**、没有对位行为 ⇒ 钉本库形状（§10）。
// 参照对 `null` 模式给"最不具体"的两档，本库签名 `compare_patterns(String, String, String)` 不收可选值
// ⇒ 没有对位物，两档不进断言（写在这里而不是默默删掉）。

'''


def to_moon(s):
    """腿的 ASCII 记号 → MoonBit 串面量"""
    if s == "{null}":
        return None
    out = []
    i = 0
    while i < len(s):
        if s[i] == '{' and s.find('}', i) > 0:
            tok = s[i + 1:s.find('}', i)]
            if tok.startswith('u'):
                out.append('\\u{%s}' % tok[1:])
                i = s.find('}', i) + 1
                continue
        if s[i] == '"':
            out.append('\\"')
        elif s[i] == chr(92):
            out.append(chr(92) + chr(92))
        else:
            out.append(s[i])
        i += 1
    return '"' + ''.join(out) + '"'


def block(title, idx, note, call, exp):
    return ('///|\ntest "%s %02d" {\n  // %s\n  assert_eq(%s, %s)\n}\n\n'
            % (title, idx, note, call, exp))


def main():
    text = io.open(LEG, encoding="utf-8", errors="replace").read().replace("\r", "")
    if "G|GUARD_OK|distinct3" not in text:
        raise SystemExit("腿自检缺失或失败（没有 G|GUARD_OK|distinct3）：%s" % LEG)
    trows, mrows, nrows, rows = [], [], [], []
    skipped = 0
    for raw in text.splitlines():
        f = raw.split("|")
        tag = f[0]
        if tag == "T":
            trows.append((f[1], f[2], f[3]))
        elif tag == "M":
            mp, mq = to_moon(f[2]), to_moon(f[3])
            assert mp is not None and mq is not None, "M 行不该有 null：%s" % raw
            mrows.append((f[1], f[2], f[3], f[4], mp, mq))
        elif tag == "N":
            nrows.append((f[1], f[2], f[3], f[4]))
        elif tag == "E":
            nrows.append(("e", f[1], f[2], f[3]))
        elif tag == "C":
            ma, m1, m2 = to_moon(f[1]), to_moon(f[2]), to_moon(f[3])
            if ma is None or m1 is None or m2 is None:
                skipped += 1
                continue
            rows.append((f[1], f[2], f[3], f[4], ma, m1, m2))
    for need, got, name in ((8, len(trows), "T"), (20, len(mrows), "M"),
                            (15, len(nrows), "N/E"), (20, len(rows), "C")):
        assert got >= need, "腿只解析出 %d 条 %s 行 ⇒ 不出文件" % (got, name)

    body = HEAD
    # ———— T 行不落成断块：`tokenize` 是包内 private，而同目录的 _test.mbt 是"带 test 变体的
    # 外部包"（`path/moon.pkg` 里那句 `for "test"`），拿不到内部件——为测试而导出一个私有件
    # 不划算。T 行的用法是给 spec §9 当根因读数（空段丢不丢逐串现读），它的作用已经由
    # M 行的匹配结果整体承担：切分器一改，那些档自己就变绿。此处只做数量自检。
    assert all(len(r) == 3 for r in trows), "T 行形状不对"
    # ———— M 行：匹配与抽段 ————
    for i, (verb, pat, path, reading, mp, mq) in enumerate(mrows):
        if verb == "m":
            call = "@path.match_path(%s, %s)" % (mp, mq)
            exp = "true" if reading == "true" else "false"
            note = "参照 match(%s, %s) ⇒ %s" % (pat, path, reading)
        elif verb == "s":
            call = "@path.match_start_with(%s, %s, @path.default_options())" % (mp, mq)
            exp = "true" if reading == "true" else "false"
            note = "参照 matchStart(%s, %s) ⇒ %s" % (pat, path, reading)
        else:
            call = "@path.extract_within(%s, %s)" % (mp, mq)
            exp = to_moon(reading)
            note = "参照 extractPathWithinPattern(%s, %s) ⇒ %s" % (pat, path, reading)
        body += block("path 匹配直读", i + 1, note, call, exp)
    # ———— N / E 行：失败出口、抽变量、组合、空分隔符 ————
    body += '///|\nfn p6_raise(f : () -> Unit raise @path.PathError) -> String {\n'
    body += '  try {\n    f()\n    "未抛"\n  } catch {\n'
    body += '    @path.NoMatch(a, b) => "NoMatch " + a + "|" + b\n'
    body += '    @path.CapturingVar(n) => "CapturingVar " + n\n'
    body += '    @path.CaptureGroupRegex(s) => "CaptureGroupRegex " + s\n'
    body += '    @path.ExtensionConflict(a, b) => "ExtensionConflict " + a + "|" + b\n'
    body += '  }\n}\n\n'
    body += '///|\nfn p6_vars(m : Map[String, String]) -> String {\n'
    body += '  let keys : Array[String] = []\n  for (k, _) in m {\n    keys.push(k)\n  }\n'
    body += '  keys.sort()\n  let mut out = ""\n  for k in keys {\n'
    body += '    let v = match m.get(k) {\n      Some(x) => x\n      None => ""\n    }\n'
    body += '    out = out + k + "=" + v + ";"\n  }\n  out\n}\n\n'
    pending = []
    for i, (verb, pat, path, reading) in enumerate(nrows):
        key = (verb, pat, path)
        mp, mq = to_moon(pat), to_moon(path)
        assert mp is not None and mq is not None, "N/E 行不该有 null：%s" % str(key)
        if verb == "m":
            call = "@path.match_path(%s, %s)" % (mp, mq)
            exp = "true" if reading == "true" else "false"
            note = "参照 match(%s, %s) ⇒ %s" % (pat, path, reading)
        elif verb == "e":
            opts = '@path.PathOptions::{ separator: "", case_sensitive: true, trim_tokens: false, }'
            call = "@path.match_path_with(%s, %s, %s)" % (mp, mq, opts)
            # 占位要**带类型**（Bool），所以先用 `true` 探：红 ⇒ 本库给 false，绿 ⇒ 本库给 true。
            # 两个占位互斥，不存在"蒙对了还当没测过"的空档。
            exp = "true"
            note = ('参照 `new AntPathMatcher("")` 在这一档抛 %s ⇒ sep=空串 无对位行为；'
                    '本库这两档是防御档，钉本库形状（依据 15-path §10）' % reading)
        elif verb == "x":
            call = "p6_raise(() => { let _ = @path.extract_variables(%s, %s); })" % (mp, mq)
            if reading.startswith("ERR:"):
                exp = "ME"
                note = "参照 extractUriTemplateVariables(%s, %s) ⇒ %s（参照在这一档抛）" % (pat, path, reading)
            else:
                # 不抛的那档要断**返回的映射**，不是断"没抛"——上一轮红样给的 "未抛" 就是这个设计缺陷现形的样子
                call = "p6_vars(@path.extract_variables(%s, %s))" % (mp, mq)
                exp = to_moon(reading)
                note = "参照 extractUriTemplateVariables(%s, %s) ⇒ %s" % (pat, path, reading)
        else:
            call = "p6_raise(() => { let _ = @path.combine(%s, %s); })" % (mp, mq)
            if reading.startswith("ERR:"):
                exp = "ME"
                note = "参照 combine(%s, %s) ⇒ %s（参照在这一档抛）" % (pat, path, reading)
            else:
                call = "@path.combine(%s, %s)" % (mp, mq)
                exp = to_moon(reading)
                note = "参照 combine(%s, %s) ⇒ %s" % (pat, path, reading)
        if key in DECL:
            exp = DECL[key]
            note += " ｜钉本库形状（依据 15-path §10）"
        elif exp == "ME" or verb == "e":
            # e 行是"带类型的占位 true"，同样要回填；ME 行是 String 占位
            pending.append("%02d:%s(%s,%s)" % (i + 1, verb, pat, path))
            if exp == "ME":
                exp = '"ME"'
        body += block("path 出口直读", i + 1, note, call, exp)
    # ———— C 行：比较器逐对 ————
    for i, (against, p1, p2, reading, ma, m1, m2) in enumerate(rows):
        body += block("path 比较器直读", i + 1,
                      "against=%s ｜ p1=%s ｜ p2=%s ｜ 参照=%s" % (against, p1, p2, reading),
                      "@path.compare_patterns(%s, %s, %s)" % (ma, m1, m2), reading)
    io.open(OUT, "w", encoding="utf-8", newline="\n").write(body)
    print("tokenize=%d match=%d exit=%d cmp=%d skipped_null=%d 待回填=%s file=%s"
          % (len(trows), len(mrows), len(nrows), len(rows), skipped,
             " ".join(pending) or "无", OUT))


main()
