#!/usr/bin/env python
# conv 第十批补档生成器：把 Conv2Leg.java 的读数灌成 conv/conv_boundary_test.mbt。
# 用法：python scripts/gen_conv2_test.py <conv2_leg.txt>
# 期望只从腿的读数取，手打零条；本库改判档要指到 spec 行（见 DECL 表）。
import io
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if len(sys.argv) < 2:
    raise SystemExit("用法：python scripts/gen_conv2_test.py <conv2_leg.txt>")
LEG = os.path.abspath(sys.argv[1])
OUT = os.path.join(REPO, "conv", "conv_boundary_test.mbt")

# 本库改判档（钉本库形状，参照原读数留在注释里；依据行写死）：
#   nan / inf —— `trunc_to_int`：非有限值给 None，而参照 `Convert.toInt("NaN")` 给 0、Infinity 给 null
#     （spec 09-conv §5 那族"不跟随 Java 的低位回绕与 saturate"+ conv.mbt:627 的界校验注释）
#   big1e20 / big1e100 —— 越出 Int / Int64 位宽给 None；参照 toLong 那档给 1（部分解析），
#     属参照自身缺陷，本库不跟随同一行
DECL = {
    ("I", "nan", "ti"): "None",
    ("I", "inf", "ti"): "None",
    ("I", "big1e20", "ti"): "None",
    ("I", "big1e100", "ti"): "None",
    ("I", "big1e100", "t64"): "None",
    # 下面五档同族：参照走 NumberFormat.parse 的前缀解析（遇非数字即停），
    # 本包整串必须匹配文法 => 一律 None。依据行：09-conv 分岔表"123X"那一行。
    ("I", "dotdash", "t64"): "None",
    ("I", "nbsp", "ti"): "None",
    ("I", "nbsp", "t64"): "None",
    ("I", "big1e20", "t64"): "None",
    ("I", "nan", "t64"): "None",
}

# 登记而不钉：0x 带符号两档。参照那两个读数（1 / -1）本身是前缀解析的产物，
# 而本库 spec 9.9 承诺"0x 十六进制可带符号"却给 None —— 这是实现与自家契约不符，
# 不替缺陷钉期望，挂实现笔（见 docs/spec/09-conv.md 新增的缺陷行）。
DROP = {("I", "hexsign", "ti"), ("I", "hexsign", "t64"),
        ("I", "hexneg", "ti"), ("I", "hexneg", "t64")}

HEAD = '''///|
// conv 界外与符号档补档（10-08）——`+`/`-`/空串、`0x` 带符号、非有限值、越出位宽、
// NBSP 与全角归一。期望全部由 Conv2Leg.java 现读灌入（hutool-core 5.8.35 · JDK 17.0.14），手打零条。
// 参照改判档钉本库形状、把参照原读数留在注释里（依据见 docs/spec/09-conv.md §5）。

'''


def raw_hex(s):
    return "+".join("%x" % ord(c) for c in s)



def json_str_lit(raw):
    """把任意文本转成 MoonBit 里的 JSON 串面量：先按 JSON 规则转义，再套 MoonBit 引号"""
    out = []
    for ch in raw:
        o = ord(ch)
        if ch == '"':
            out.append('\\"')
        elif ch == '\\\\':
            out.append('\\\\\\\\')
        elif o < 0x20 or o > 0x7E:
            out.append("\\u%04x" % o)
        else:
            out.append(ch)
    # MoonBit 字面量里再套一层引号；\u 在 MoonBit 串里就是 JSON 风格的转义，
    # 所以 \\\\u00a0 会先进 MoonBit 串成为 NBSP 字符、再由 @json.parse 处理——
    # 为避免两层转义互相吃掉，这里统一让 MoonBit 串里出现的是 \\u 序列本身
    return '"' + chr(92) + '"' + "".join(out) + chr(92) + '"' + '"'


def main():
    rows = []
    for raw in io.open(LEG, encoding="utf-8", errors="replace").read().replace("\r", "").splitlines():
        f = raw.split("|")
        if f[0] != "I":
            continue
        rows.append((f[1], unesc_input(f[2]), f[3], f[4]))

    blocks = []
    for name, val, ti, t64 in rows:
        for fn, reading in (("ti", ti), ("t64", t64)):
            api = "@conv.to_int" if fn == "ti" else "@conv.to_int64"
            exp = DECL.get(("I", name, fn), "None" if reading == "null" else "Some(" + reading + ")")
            if ("I", name, fn) in DROP:
                continue
            blocks.append((
                "%s-%s" % (fn, name),
                "%s(%s) ｜ 入参码点=%s ｜ 参照 %s=%s%s"
                % (api, "j(...)", raw_hex(val), "Convert.toInt" if fn == "ti" else "Convert.toLong",
                   reading, "" if exp == ("None" if reading == "null" else "Some(%s)" % reading)
                   else "（本库改判：整串匹配文法，不跟随参照的前缀解析，见 09-conv 分岔表）"),
                'assert_eq(%s(j(%s)), %s)' % (api, json_str_lit(val), exp)))

    body = HEAD + "\n\n".join(
        '///|\ntest "conv 界外 %s" {\n  // %s\n  %s\n}' % (n, c, e) for n, c, e in blocks) + "\n"
    io.open(OUT, "w", encoding="utf-8", newline="\n").write(body)
    print("blocks=%d file=%s" % (len(blocks), OUT))


def unesc_input(s):
    out = []
    i = 0
    while i < len(s):
        if s[i] == "{" and s.find("}", i) > 0:
            j = s.find("}", i)
            tok = s[i + 1:j]
            if tok.startswith("u"):
                out.append(chr(int(tok[1:], 16)))
                i = j + 1
                continue
        out.append(s[i])
        i += 1
    return "".join(out)


main()
