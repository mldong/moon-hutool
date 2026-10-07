#!/usr/bin/env python
# path 比较器修复笔的期望生成器：把 PathLeg3.java 的逐对直读灌成 path/path_cmp3_test.mbt。
# 用法：python scripts/gen_path3_test.py <path3_leg.txt>
# 期望只从腿的读数取，手打零条；参照对 `null` 给"最不具体"的那两档本库签名不收 null ⇒ 跳过并记进 spec。
import io
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if len(sys.argv) < 2:
    raise SystemExit("用法：python scripts/gen_path3_test.py <path3_leg.txt>")
LEG = os.path.abspath(sys.argv[1])
OUT = os.path.join(REPO, "path", "path_cmp3_test.mbt")

HEAD = '''///|
// path 两笔修复的逐对直读（10-08）——匹配/抽段 23 条 + 比较器 26 对，全部由 `scripts/PathLeg3.java` 现读灌入
// （hutool-core 5.8.35 `AntPathMatcher.getPatternComparator(path)` · JDK 17.0.14），手打零条。
// 夹具形状是照参照 `AntPatternComparator` 源码里七级判定的每一条出口配的，
// 前半（匹配直读）钉的是 §7.1 表里"尾随分隔符 4 + 抽段 1"那五条：根因是参照 `tokenizePath()` 丢空段
// （`splitToArray(..., ignoreEmpty=true)`，T 行逐串读数），本库原先保留空段，于是 `do_match:402`
// 那条"路径先耗尽 + 余一颗 `*` + 路径以分隔符收尾"的特判永远走不到。
// 后半（比较器直读）钉的是那六条：`getTotalCount()` 里双星要按两个计数等，见 §8。
// 十条分岔自此全部从"登记"转成断言。
// 参照对 `null` 模式给"最不具体"的两档，本库签名 `compare_patterns(String, String, String)` 不收可选值
// ⇒ 没有对位物，两档不进断言（写在这里而不是默默删掉）。

'''


def to_moon(s):
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


def main():
    text = io.open(LEG, encoding="utf-8", errors="replace").read().replace("\r", "")
    if "G|GUARD_OK|distinct3" not in text:
        raise SystemExit("腿自检缺失或失败（没有 G|GUARD_OK|distinct3）：%s" % LEG)
    rows = []
    skipped = 0
    for raw in text.splitlines():
        f = raw.split("|")
        if f[0] != "C":
            continue
        against, p1, p2, reading = f[1], f[2], f[3], f[4]
        ma, m1, m2 = to_moon(against), to_moon(p1), to_moon(p2)
        if ma is None or m1 is None or m2 is None:
            skipped += 1
            continue
        rows.append((against, p1, p2, reading, ma, m1, m2))
    assert len(rows) >= 20, "腿只解析出 %d 对，形状不对 ⇒ 不出文件" % len(rows)

    # M 行：匹配与抽段的逐对读数。verb：m=match、s=matchStart、w=extractPathWithinPattern
    mrows = []
    for raw in text.splitlines():
        f = raw.split("|")
        if f[0] != "M":
            continue
        verb, pat, path, reading = f[1], f[2], f[3], f[4]
        mp, mq = to_moon(pat), to_moon(path)
        assert mp is not None and mq is not None, "M 行不该有 null：%s" % raw
        mrows.append((verb, pat, path, reading, mp, mq))
    assert len(mrows) >= 20, "腿只解析出 %d 条 M 行，形状不对 ⇒ 不出文件" % len(mrows)

    body = HEAD
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
        body += ('///|\ntest "path 匹配直读 %02d" {\n  // %s\n'
                 '  assert_eq(%s, %s)\n}\n\n' % (i + 1, note, call, exp))
    for i, (against, p1, p2, reading, ma, m1, m2) in enumerate(rows):
        body += ('///|\ntest "path 比较器直读 %02d" {\n'
                 '  // against=%s ｜ p1=%s ｜ p2=%s ｜ 参照=%s\n'
                 '  assert_eq(@path.compare_patterns(%s, %s, %s), %s)\n}\n\n'
                 % (i + 1, against, p1, p2, reading, ma, m1, m2, reading))
    io.open(OUT, "w", encoding="utf-8", newline="\n").write(body)
    print("match_blocks=%d cmp_blocks=%d skipped_null=%d file=%s"
          % (len(mrows), len(rows), skipped, OUT))


main()
