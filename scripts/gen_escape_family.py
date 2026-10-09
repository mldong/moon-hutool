#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""moon-hutool 批①（escape / UnicodeUtil / 实体表）的期望生成器。

用法：
    python scripts/gen_escape_family.py <escape_leg.txt> <escape_leg2.txt> \\
            <escape_leg3.txt> <entity_leg.txt>

产出两份，都在 `text/`：
  escape_tables.mbt —— 实体码表（反射读四个类的 `String[][]`）+ `escape` 默认过滤器的
      "不转义区间表"（`EscapeLeg3` 对整个 BMP 逐位对撞后的区间）；一条不手打。
  escape_test.mbt   —— 冻结期望，每条断言行尾原样带腿的读数三段（方法|入参形状|输出形状）。
      错误面的 helper（`show`/`cn_err`）**不在这里生成**，在手工维护的
      `text/escape_err_test.mbt`（同包测试共享顶层命名空间）——生成器不往目标语言源码里嵌
      整段代码是 typex 轮记下的规矩。

四条硬规矩（前两轮踩出来的，别改回去）：
1. 期望只从腿取。腿的 `esc()` 形状 = "可见 ASCII 原样 + 其余 `{uXXXX}`（**UTF-16 码元**）"，
   这里解回码元、**成对代理合成码位**再落字面量（Java 那一对码元本来就代表同一个字符）。
2. 落单代理 = 参照能给、本库表示不了的档 ⇒ 折成 `LoneSurrogate` 的 raise 断言；
   总函数（无 raise 面）撞上落单代理就落 ME 并计数，不悄悄替换成 U+FFFD（那是自创语义）。
3. 落盘的字面量一律纯 ASCII：`{`/`}`/`"`/`\\` 与非 ASCII 全写成 `\\u{XXXX}`。
4. 腿的 `ERR:<类名>` 按 `ERR_MAP` 折成本库错误变体；折不了的落 ME，**不替参照猜值**。
"""
import io
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ESC_RE = re.compile(r"\{u([0-9a-fA-F]{4})\}")
NUM_BAD = re.compile(r'ERR:NumberFormatException:For input string: "([^"]*)" under radix 16')
ERR_CLS = re.compile(r"^ERR:([A-Za-z]+)")

# 腿的方法名 → 本库函数名（PR-A 的签名面；一一对应，缺一条就是漏档）
FN = {"escapeXml": "escape_xml", "unescapeXml": "unescape_xml",
      "escapeHtml4": "escape_html4", "unescapeHtml4": "unescape_html4",
      "escape": "escape", "escapeAll": "escape_all",
      "unescape": "unescape", "safeUnescape": "safe_unescape",
      "toUnicode": "to_unicode", "toString": "unicode_to_string",
      "encodeBlank": "encode_blank"}
# 有 raise 面的四件：`unescape`/`unicode_to_string` 收参照自己的抛错档，
# `unescape_xml`/`unescape_html4` 只多一个形状差——数字实体解到代理区时参照能产出落单代理，
# 本库的 String 域表示不了 ⇒ raise（成对代理照常合成码位，那一档零偏差）。
RAISERS = {"unescape", "unicode_to_string", "unescape_xml", "unescape_html4"}


def decode_units(s):
    out, i = [], 0
    while i < len(s):
        m = ESC_RE.match(s, i)
        if m:
            out.append(int(m.group(1), 16))
            i = m.end()
        else:
            out.append(ord(s[i]))
            i += 1
    return out


def units_to_text(units):
    """码元 → (合成后的文本, 落单代理列表)。"""
    res, lone, i = [], [], 0
    while i < len(units):
        u = units[i]
        hi = 0xD800 <= u <= 0xDBFF
        lo = i + 1 < len(units) and 0xDC00 <= units[i + 1] <= 0xDFFF
        if hi and lo:
            res.append(chr(0x10000 + ((u - 0xD800) << 10) + (units[i + 1] - 0xDC00)))
            i += 2
        elif 0xD800 <= u <= 0xDFFF:
            lone.append(u)
            i += 1
        else:
            res.append(chr(u))
            i += 1
    return "".join(res), lone


def mb(s):
    """文本 → MoonBit 串字面量体（纯 ASCII）。"""
    out = []
    for ch in s:
        o = ord(ch)
        if ch == '"':
            out.append('\\"')
        elif ch == "\\":
            out.append("\\\\")
        elif 0x20 <= o <= 0x7E and ch not in "{}":
            out.append(ch)
        else:
            out.append("\\u{%04x}" % o)
    return "".join(out)


def lit(shape):
    """腿形状 → MoonBit 字面量；含落单代理时返回 None（调用方另走一档）。"""
    text, lone = units_to_text(decode_units(shape))
    if lone:
        return None
    return '"%s"' % mb(text)


def read_lines(path):
    with io.open(path, encoding="utf-8") as f:
        return [ln.rstrip("\r\n") for ln in f if ln.strip()]


# ---------------------------------------------------------------- 表
def build_tables(entity):
    t = {"xe": [], "he": [], "xu": [], "hu": []}
    for ln in entity:
        if not ln.startswith("F|"):
            continue
        p = ln.split("|")
        if len(p) != 6 or p[3] == "LEN":
            continue
        cls, key, val = p[1], p[4], p[5]
        if cls == "XmlEscape":
            t["xe"].append((key, val))
        elif cls == "Html4Escape":
            t["he"].append((key, val))
        elif cls == "XmlUnescape":
            t["xu"].append((key, val))
        elif cls == "Html4Unescape":
            t["hu"].append((key, val))
    t["hu"] = t["xu"] + t["hu"]      # 参照那边是继承：Html4Unescape extends XmlUnescape
    return t


def emit_tables(t, rng):
    L = ["// 本文件由 `scripts/gen_escape_family.py` 从参照腿的读数生成，**勿手改、勿手加条目**。",
         "// 来源一：`scripts/EntityTableLeg.java` 反射读 `XmlEscape`/`Html4Escape`/`XmlUnescape`/",
         "//   `Html4Unescape` 四个类自己的 `String[][]` 静态字段——实体码表就是它们本身，",
         "//   不抄 Apache 清单、不抄网页表（hutool 的 HTML4 表是 Apache Commons 派生，条目以 jar 现读为准；",
         "//   反射读常量是 `re` 轮 RegexPool 那批用过的同一条做法）。",
         "// 来源二：`scripts/EscapeLeg3.java` 对整个 BMP 逐位问 `EscapeUtil.escape`，先证",
         "//   \"谓词==行为\"零分岔（MISMATCH|count|0），再把不转义集压成区间表。",
         "// 谓词本体由 javap -c 现读 `EscapeUtil.lambda$static$0`：",
         "//   isDigit(c) || isLowerCase(c) || isUpperCase(c) || \"*@-_+./\".contains(c)",
         "// 是**大小写/数字**、不是 isLetterOrDigit——这解释了 ª(U+00AA) 被留、",
         "// ƻ(U+01BB, Lt) 与 あ(U+3041, Lo) 被转、Ⅰ(U+2160, Other_Uppercase) 被留。",
         "// 参照版本 hutool-all 5.8.37；判据与逐条出处见 docs/spec/01-text.md §1.16。",
         ""]
    docs = [("xml_escape_pairs", "xe", "escape_xml 的实体表（`XmlEscape.BASIC_ESCAPE`）"),
            ("html4_escape_pairs", "he",
             "escape_html4 的实体表（`Html4Escape` 三张字段按 BASIC→ISO8859_1→HTML40_EXTENDED 顺序拼接）"),
            ("xml_unescape_pairs", "xu", "unescape_xml 认的实体名（`XmlUnescape.BASIC_UNESCAPE`）"),
            ("html4_unescape_pairs", "hu",
             "unescape_html4 认的实体名（XML 那 5 条 + ISO8859_1_UNESCAPE 96 + HTML40_EXTENDED_UNESCAPE 151）")]
    for name, key, doc in docs:
        L.append("///|")
        L.append("// %s —— %d 条，逐条来自腿的反射读数" % (doc, len(t[key])))
        L.append("let %s : Array[(String, String)] = [" % name)
        for k, v in t[key]:
            L.append('  ("%s", "%s"),' % (mb(units_to_text(decode_units(k))[0]),
                                          mb(units_to_text(decode_units(v))[0])))
        L.append("]")
        L.append("")
    L.append("///|")
    L.append("// `escape` 默认过滤器的**不转义**码位区间表（%d 段；表内原样出，表外全转）。" % len(rng))
    L.append("// 非 BMP 不在表里是刻意的：参照按 UTF-16 码元走，星平面拆成两个代理码元，")
    L.append("// 两个都不属数字/大小写 ⇒ 永远转（腿的 ASTRAL 行五对现读全 false）。")
    L.append("let escape_keep_ranges : Array[(Int, Int)] = [")
    for a, b in rng:
        L.append("  (0x%04x, 0x%04x)," % (a, b))
    L.append("]")
    return "\n".join(L) + "\n"


# ---------------------------------------------------------------- 断言行
class Gen:
    def __init__(self):
        self.me = []
        self.blocks = {}

    def add(self, title, line):
        self.blocks.setdefault(title, []).append(line)

    def note_me(self, why, raw):
        self.me.append("%s :: %s" % (why, raw))

    # 期望值：返回 ("val", 字面量) / ("err", 形状串) / (None, None)
    def expect(self, fn, out, raw):
        if out.startswith("ERR:"):
            if fn not in RAISERS:
                self.note_me("总函数撞上参照抛错", raw)
                return None, None
            m = NUM_BAD.match(out)
            if m:
                return "err", '"BadHex %s"' % mb(units_to_text(decode_units(m.group(1)))[0])
            cls = (ERR_CLS.match(out) or [None, ""])[1]
            if cls == "StringIndexOutOfBoundsException":
                return "err", '"ShortInput"'
            self.note_me("未映射的异常类 " + cls, raw)
            return None, None
        text, lone = units_to_text(decode_units(out))
        if lone:
            if fn in RAISERS:
                return "err", '"LoneSurrogate %d"' % lone[0]
            self.note_me("总函数造不出落单代理（本库输入域无此形状）", raw)
            return None, None
        return "val", '"%s"' % mb(text)

    def row(self, fn, call, kind, exp, tag):
        if kind == "err":
            body = 'assert_eq(cn_err(() => %s), %s)' % (call, exp)
        else:
            body = 'assert_eq(%s, %s)' % (call, exp)
        return "  %s // %s" % (body, tag)

    def one(self, title, fn_key, inp, out, raw, call=None):
        fn = FN.get(fn_key) if fn_key in FN else fn_key
        if inp == "{null}":
            self.note_me("null 档无对位入参（本库 String 不收 null）", raw)
            return
        arg = lit(inp)
        if arg is None:
            self.note_me("输入含落单代理", raw)
            return
        kind, exp = self.expect(fn, out, raw)
        if exp is None:
            return
        self.add(title, self.row(fn, call or "%s(%s)" % (_pkg(fn), arg), kind, exp, raw))


def _pkg(fn):
    return "@text." + fn


def emit_tests(leg1, leg2, leg3, entity):
    g = Gen()
    # 1) 实体族（E 行）
    for ln in leg1:
        p = ln.split("|")
        if len(p) != 4 or p[0] != "E":
            continue
        g.one("text.escape #1.16 实体族逐条", p[1], p[2], p[3], ln)
    # 2) 百分号族（P / UN 行；filter 档另组）
    FILT = {"escape(filterKeepAll)": "_c => true",
            "escape(filterKeepNone)": "_c => false",
            "escape(filterAsciiAlpha)": "c => c.is_ascii_alphabetic()",
            "escape(filterNotAlnum)": "c => !(c.is_ascii_alphabetic() || c.is_ascii_digit())"}
    for src in (leg1, leg2):
        for ln in src:
            p = ln.split("|")
            if p[0] not in ("P", "UN") or len(p) != 4:
                continue
            meth = p[1]
            if meth in FILT:
                title = "text.escape #1.17 escape_by 的过滤器四档"
                fn = "escape_by"
                arg = lit(p[2])
                if arg is None or p[2] == "{null}":
                    continue
                kind, exp = g.expect(fn, p[3], ln)
                if exp is None:
                    continue
                g.add(title, g.row(fn, "@text.escape_by(%s, %s)" % (arg, FILT[meth]), kind, exp, ln))
                continue
            if meth not in FN:
                continue
            g.one("text.escape #1.17 百分号族逐条", meth, p[2], p[3], ln)
    # 3) UnicodeUtil（U / N / R / I 行）
    for ln in leg1:
        p = ln.split("|")
        if len(p) != 4 or p[0] not in ("U", "N", "R", "I"):
            continue
        fam, meth, inp, out = p[0], p[1], p[2], p[3]
        if fam == "N":
            # 参照的 toUnicode(char) 与 toUnicode(int) 在 BMP 内**逐档同读数**（腿的 N 行成对打出，
            # 每一对两侧字符串相同），所以本库只收一件 `unicode_of(Int)`，char 档在调用点 .to_int()。
            _kind, val = inp.split(":")
            kind, exp = g.expect("unicode_of", out, ln)
            if exp is None:
                continue
            g.add("text.unicode #1.18 unicode_of 逐码点（char/int 两侧同读数）",
                  "  assert_eq(@text.unicode_of(%s), %s) // %s" % (val, exp, ln))
            continue
        if fam == "I":
            # 闭环档：toUnicode∘toString（外罩 unicode_to_string）
            inner = lit(inp)
            if inner is None:
                continue
            fn = "unicode_to_string"
            # 腿的两档 `roundtrip` / `roundtrip(true)` 在参照里都是 `toUnicode(s, true)`
            # （= 本库的 `to_unicode`）；`false` 档的闭环**没有读数**，不许凭形状补一条
            call = "@text.unicode_to_string(@text.to_unicode(%s))" % inner
            kind, exp = g.expect(fn, out, ln)
            if exp:
                g.add("text.unicode #1.18 闭环（to_unicode ∘ unicode_to_string）",
                      g.row(fn, call, kind, exp, ln))
            continue
        if meth == "toUnicode(char)":
            continue
        if meth == "toUnicode(true)":
            fn = "to_unicode"
        elif meth == "toUnicode(false)":
            fn = "to_unicode_all"
        elif meth == "toUnicode":
            fn = "to_unicode"
        elif meth == "toString":
            fn = "unicode_to_string"
        else:
            continue
        g.one("text.unicode #1.18 UnicodeUtil 逐档", fn, inp, out, ln)
    # 4) 实体表逐位产出（S 行）+ 数字实体/长键/别名（N/M/L/A 行）
    for ln in entity:
        p = ln.split("|")
        if len(p) != 4:
            continue
        if p[0] == "S":
            meth, hx, out = p[1], p[2], p[3]
            cp = int(hx[1:], 16)
            if 0xD800 <= cp <= 0xDFFF:
                # 输入侧就是落单代理：本库的 String 域根本构造不出这一位 ⇒ 无对位档（spec 里逐条点名，
                # 不当"已覆盖"，也不留成 ME 噪声）
                g.note_me("输入即落单代理，无对位入参", ln)
                continue
            fn = FN.get(meth)
            kind, exp = g.expect(fn, out, ln)
            if exp:
                g.add("text.escape #1.16 实体表逐位产出（S 行）",
                      g.row(fn, '@text.%s("\\u{%04x}")' % (fn, cp), kind, exp, ln))
        elif p[0] in ("N", "M", "L", "A"):
            if p[1] not in FN:
                continue
            g.one("text.escape #1.16 数字实体/长键/别名择路", p[1], p[2], p[3], ln)
    lines = []
    for title in sorted(g.blocks):
        lines.append('test "%s" {' % title)
        lines.extend([l for l in g.blocks[title] if l.strip()])
        lines.append("}")
        lines.append("")
    head = ["""// 本文件的每一条期望都由 `scripts/gen_escape_family.py` 从参照腿灌入，**手打零条**。
// 腿：scripts/EscapeLeg.java（实体族/百分号族/UnicodeUtil 语料与闭环）、
//     scripts/EscapeLeg2.java（默认过滤器与实体表的逐码点扫、unescape 每条出口、真实文本档）、
//     scripts/EscapeLeg3.java（"谓词==行为"的 BMP 全枚举对撞 + 不转义区间表）、
//     scripts/EntityTableLeg.java（反射读四张实体表 + 数字实体/长键/别名择路）。
// 参照版本 hutool-all 5.8.37；判据口径见 docs/spec/01-text.md §1.16~§1.19。
// `show` / `cn_err` 两个 helper 在 `text/escape_err_test.mbt`（手工维护，本文件全生成）。
// 期望值冻结（AGENTS）：改这里任何一条都要单独一笔并给新的腿读数。
"""]
    return head + lines, g.me


def _first_hex(keep):
    for ch in keep:
        o = ord(ch)
        if 0x21 <= o <= 0x7E:
            return "%04x" % o
    return "0020"


def main():
    if len(sys.argv) < 5:
        raise SystemExit(__doc__)
    leg1 = read_lines(os.path.abspath(sys.argv[1]))
    leg2 = read_lines(os.path.abspath(sys.argv[2]))
    leg3 = read_lines(os.path.abspath(sys.argv[3]))
    entity = read_lines(os.path.abspath(sys.argv[4]))
    rr = [ln.split("|", 1)[1] for ln in leg3
          if ln.startswith("RANGES|") and not ln.startswith("RANGES|count")]
    mm = [ln for ln in leg3 if ln.startswith("MISMATCH|count|")]
    if len(rr) != 1 or len(mm) != 1:
        raise SystemExit("腿 3 形状变了（RANGES %d / MISMATCH %d）⇒ 先读腿再改生成器" % (len(rr), len(mm)))
    if mm[0].split("|")[2] != "0":
        raise SystemExit("谓词与行为有分岔（%s）⇒ 区间表不可信，本批不进" % mm[0])
    rng = [tuple(int(x, 16) for x in seg.split("-")) for seg in rr[0].split(",") if seg]
    t = build_tables(entity)
    with io.open(os.path.join(REPO, "text", "escape_tables.mbt"), "w", encoding="utf-8", newline="\n") as f:
        f.write(emit_tables(t, rng))
    body, me = emit_tests(leg1, leg2, leg3, entity)
    with io.open(os.path.join(REPO, "text", "escape_test.mbt"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(body) + "\n")
    print("tables: xe=%d he=%d xu=%d hu=%d keep_ranges=%d" % (
        len(t["xe"]), len(t["he"]), len(t["xu"]), len(t["hu"]), len(rng)))
    tot = sum(1 for l in body if l.startswith("  assert"))
    print("asserts=%d  ME=%d" % (tot, len(me)))
    for x in sorted(set(me))[:10]:
        print("   ME:", x)
    return 0


if __name__ == "__main__":
    sys.exit(main())
