#!/usr/bin/env python
# ini 第三批补档生成器：把 Props3Leg.java 的 JDK `Properties.load` 读数灌成 ini/ini_props3_test.mbt。
# 用法：python scripts/gen_ini3_test.py <ini_leg.txt>
# 期望只从腿的读数取，手打零条；`props_keys`/`props_values` 的**序**是本库 #22.37 自定的
# "首次出现序"（JDK 那边是 Hashtable，本来无序），所以腿的写入日志要先折叠成
# "每个键首次出现的位置 + 最后一次写的值"——折叠规则写进 docs/spec/22-ini.md §10，不藏在这里。
import io
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if len(sys.argv) < 2:
    raise SystemExit("用法：python scripts/gen_ini3_test.py <ini_leg.txt>")
LEG = os.path.abspath(sys.argv[1])
OUT = os.path.join(REPO, "ini", "ini_props3_test.mbt")

# 本库与 JDK 不同判的档（钉本库形状、把参照原读数留在注释里；依据行写死）。
# 空表出文件、跑一遍看红样、按实测读数回填——不许先猜后写。
DECL = {}

HEAD = '''///|
// ini 第三批补档（10-08）——`Props` 严格语义的行法与转义族：无尾换行的收尾、行续接（奇偶反斜杠）、
// 注释行尾反斜杠不续行、三种行终止符、u 加四位十六进制的转义档（大小写两档）、值尾反斜杠、重复键覆盖。
// 期望全部由 Props3Leg.java 现读灌入（**权威参照 = JDK 17 `java.util.Properties.load(Reader)`**，
// hutool `Props` 只是转手，见 docs/spec/22-ini.md §8），手打零条。
// 键序/值序是本库 #22.37 的"首次出现序"（JDK 侧是 Hashtable、本无顺序），折叠规则见 §10。

'''


def to_moon(s):
    """腿的 ASCII 记号 → MoonBit 串面量内容"""
    out = []
    i = 0
    while i < len(s):
        if s[i] == '{':
            j = s.find('}', i)
            tok = s[i + 1:j]
            if j > 0 and tok:
                if tok == 'n':
                    out.append('\\n')
                    i = j + 1
                    continue
                if tok == 'r':
                    out.append('\\r')
                    i = j + 1
                    continue
                if tok == 't':
                    out.append('\\t')
                    i = j + 1
                    continue
                if tok == 's':
                    out.append(';')
                    i = j + 1
                    continue
                if tok == 'b':
                    out.append('|')
                    i = j + 1
                    continue
                if tok.startswith('u'):
                    out.append('\\u{%s}' % tok[1:])
                    i = j + 1
                    continue
        if s[i] == '"':
            out.append(chr(92) + '"')
        elif s[i] == chr(92):
            # 单个反斜杠在 MoonBit 串面量里必须写成两个，否则后面的引号被吃掉
            out.append(chr(92) + chr(92))
        elif s[i] == "'":
            out.append("'")
        else:
            out.append(s[i])
        i += 1
    return '"' + ''.join(out) + '"'


def collapse(writes):
    """腿的写入日志 [(k,v),...] → #22.37 首次出现序 + 最后一次写的值"""
    order = []
    last = {}
    for k, v in writes:
        if k not in last:
            order.append(k)
        last[k] = v
    return [(k, last[k]) for k in order]


def parse_pairs(s):
    if not s or s.startswith("ERR:"):
        return None
    out = []
    for piece in s.split(";"):
        if piece == "":
            continue
        k, _, v = piece.partition("{kv}")
        out.append((k, v))
    return out


def main():
    text = io.open(LEG, encoding="utf-8", errors="replace").read().replace("\r", "")
    if "G|GUARD_OK|distinct3" not in text:
        raise SystemExit("腿自检缺失或失败（没有 G|GUARD_OK|distinct3）：%s" % LEG)
    rows = []
    for raw in text.splitlines():
        f = raw.split("|")
        if f[0] != "P":
            continue
        rows.append((f[1], f[2], f[3]))
    assert len(rows) >= 15, "腿只解析出 %d 行，形状不对 ⇒ 不出文件" % len(rows)

    blocks = []
    for name, inp, reading in rows:
        pairs = parse_pairs(reading)
        assert pairs is not None, "%s：腿给出 ERR/空 ⇒ 本批不收这个档" % name
        col = collapse(pairs)
        joined = ";".join("%s{kv}%s" % (k, v) for k, v in col)
        decl = DECL.get(name)
        exp = to_moon(decl if decl is not None else joined)
        note = "参照读数=%s" % joined
        if decl is not None:
            note += " ｜本库改判=%s（依据 22-ini §10 的「值尾反斜杠+空格」那一行）" % decl
        blocks.append((name, to_moon(inp), note, exp))

    body = HEAD
    body += '///|\nfn p3_pairs(p : @ini.Props) -> String {\n'
    body += '  let ks = @ini.props_keys(p)\n  let vs = @ini.props_values(p)\n'
    body += '  let mut out = ""\n  for i in 0..<ks.length() {\n'
    body += '    if i > 0 {\n      out = out + ";"\n    }\n'
    body += '    out = out + ks[i] + "{kv}" + vs[i]\n  }\n  out\n}\n\n'
    for name, lit, note, exp in blocks:
        body += ('///|\ntest "ini props3 %s" {\n  // %s\n'
                 '  assert_eq(p3_pairs(@ini.props_parse(%s)), %s)\n}\n\n'
                 % (name, note, lit, exp))
    io.open(OUT, "w", encoding="utf-8", newline="\n").write(body)
    print("blocks=%d file=%s" % (len(blocks), OUT))
    print("DECL 生效档：%s" % (", ".join(sorted(DECL)) or "无"))


main()
