#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""批①剩下三族的期望生成器：replacer（text）/ FileNameUtil（path）/ URLUtil 纯串半边（codec）。

用法：
    python scripts/gen_batch1_rest.py <replacer_leg.txt> <filename_leg.txt> <urlpure_leg.txt>

产出三份：<pkg>/<name>_test.mbt，每条断言行尾原样带腿的读数行。
共用的解码/字面量工具从 `gen_escape_family.py` import（一份实现，别两处各写一遍）。

三件必须交代的事：
1. **replacer 的表在腿里是按序号取的**（`set0..set7`），本文件把每张表的原文一并生成，
   这样 `set3` 之类的序号在测试里还能读回是哪几条规则——序号本身不是证据。
2. **参照的 protected/re 面没有对位件**：`B|solo`（Boom 四档，含"负数消费 ⇒ 驱动不收敛"那条）
   与 `S|serializable` 一类读数不落断言，逐条写进文件头的注释，spec §1.20 同处点名。
3. 参照的 `File` 重载、null 入参在本库都**没有对位形状**（零 FFI、String 不收 null）⇒ 不落断言，
   生成器把它们计数打出来，spec 里按"无对位档"逐条交代。
"""
import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_escape_family import (  # noqa: E402
    REPO, decode_units, lit, mb, read_lines, units_to_text,
)

# 腿里 sets[i] 的原文（与 scripts/ReplacerLeg.java 的声明逐条对齐；序号不是证据，原文才是）
SETS = [
    [("ab", "X"), ("abc", "Y")],
    [("abc", "Y"), ("ab", "X")],
    [("ab", "1"), ("ab", "2")],
    [("a", "A")],
    [("", "E")],
    [("a1", "P"), ("a22", "Q"), ("a2", "R")],
    [("中", "M"), ("中文", "N")],
    [("|", "PIPE"), ("\\", "BS")],
]


def arr(pairs):
    return "[%s]" % ", ".join('("%s", "%s")' % (mb(units_to_text(decode_units(k))[0]),
                                               mb(units_to_text(decode_units(v))[0]))
                              for k, v in pairs)


def write(rel, text):
    p = os.path.join(REPO, rel)
    with io.open(p, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    return p


HEAD = """// 本文件的每一条期望都由 `scripts/{gen}` 从参照腿 `{leg}` 的读数灌入，**手打零条**。
// 参照版本 hutool-all 5.8.37；判据口径见 docs/spec/{spec}。
// 期望值冻结（AGENTS）：改这里任何一条都要单独一笔并给新的腿读数。
"""


def gen_replacer(leg):
    blocks = {}

    def add(t, line):
        blocks.setdefault(t, []).append(line)

    skipped = {"step": 0, "no_pair": 0}
    for ln in leg:
        p = ln.split("|")
        if p[0] == "L" and p[1] == "full":
            idx = int(p[2].replace("set", ""))
            inp, out = p[3], p[4]
            exp = lit(out)
            arg = lit(inp)
            if exp is None or arg is None:
                skipped["no_pair"] += 1
                continue
            add("text.replacer #1.20 lookup 择路：长键优先与表序无关（腿 L|full）",
                '  assert_eq(@text.lookup_replacer(%s).replace(%s), %s) // %s'
                % (arr(SETS[idx]), arg, exp, ln))
        elif p[0] == "L" and p[1] == "ctor":
            add("text.replacer #1.20 空键：参照构造即抛，本库 raise(EmptyKey)",
                '  assert_eq(cn_err(() => @text.lookup_replacer([("", "E")])), "EmptyKey") // %s' % ln)
        elif p[0] == "L" and p[1] == "step":
            skipped["step"] += 1     # protected 面：本库不开放逐步钩子（理由见 spec §1.20 与腿 B|solo 那条读数）
        elif p[0] == "L" and p[1] == "empty":
            add("text.replacer #1.20 空表：一位都不换（腿 L|empty）",
                '  assert_eq(@text.lookup_replacer([]).replace(%s), %s) // %s'
                % (lit(p[2]) or '""', lit(p[3]) or '"ME"', ln))
        elif p[0] == "C":
            m = p[1]
            if m == "chain":
                # 腿里这条链的三个孩子是 a=`ab→1`、b=`bc→2`、c=`cd→3`（ReplacerLeg.java 原文），
                # 不是 sets[0] 那张表——序号只是腿内部的编号，落到测试里必须还原成表原文
                call = ("@text.replacer_chain([@text.lookup_replacer(%s), @text.lookup_replacer(%s), "
                        "@text.lookup_replacer(%s)]).replace(%s)" % (arr([("ab", "1")]), arr([("bc", "2")]),
                                                                    arr([("cd", "3")]), lit(p[2])))
                add("text.replacer #1.20 链：每位置只问第一个命中的（腿 C|chain）",
                    "  assert_eq(%s, %s) // %s" % (call, lit(p[3]) or '"ME"', ln))
            elif m in ("empty", "dup", "overlap", "watch"):
                if m == "empty":
                    call = '@text.replacer_chain([]).replace("abc")'
                elif m == "dup":
                    call = ("@text.replacer_chain([@text.lookup_replacer(%s), @text.lookup_replacer(%s)])"
                            '.replace("aaaa")' % (arr([("aa", "b")]), arr([("aa", "b")])))
                elif m == "overlap":
                    call = ("@text.replacer_chain([@text.lookup_replacer(%s), @text.lookup_replacer(%s)])"
                            '.replace("ab")' % (arr([("ab", "1")]), arr([("1", "X")])))
                else:
                    continue      # C|watch 带的是调用计数，本库无对位形状 ⇒ 只在 spec 里交代
                out = p[2 + (0 if m != "empty" else 1)] if m != "empty" else p[2]
                add("text.replacer #1.20 链的叠加形状（腿 C|empty/dup/overlap）",
                    "  assert_eq(%s, %s) // %s" % (call, lit(out) or '"ME"', ln))
    lines = [HEAD.format(gen="gen_batch1_rest.py", leg="scripts/ReplacerLeg.java",
                         spec="01-text.md §1.20"), ""]
    for t in sorted(blocks):
        lines.append('test "%s" {' % t)
        lines.extend(blocks[t])
        lines.append("}")
        lines.append("")
    lines.append("// 不落断言的读数（逐条在 spec §1.20 交代，不当\"已覆盖\"）：")
    lines.append("//   腿 L|step %d 条 = 参照 protected 的逐步出口，本库不开放该钩子；" % skipped["step"])
    lines.append("//   腿 B|solo 四档 = 自造 StrReplacer 的返回值形状（含 ret=-1 时驱动循环**永不收敛**那条），")
    lines.append("//     没有公开构造点 ⇒ 构造不出对位用例；")
    lines.append("//   腿 S|null_input / S|serializable = null 入参与 JDK 序列化面，本库无对位形状。")
    return "\n".join(lines) + "\n", sum(len(v) for v in blocks.values())


FN_MAP = {"getName": "name_of", "getSuffix": None, "getPrefix": None,
          "mainName": "main_name", "extName": "ext_name", "cleanInvalid": "clean_invalid",
          "containsInvalid": "contains_invalid", "isType": "is_type"}


def gen_filename(leg):
    blocks = {}

    def add(t, line):
        blocks.setdefault(t, []).append(line)

    skipped = {"no_pair": 0, "synonym": 0}
    for ln in leg:
        p = ln.split("|")
        if p[0] == "N":
            meth, inp, out = p[1], p[2], p[3]
            if meth in ("getSuffix", "getPrefix"):
                skipped["synonym"] += 1      # 参照那两个是 extName/mainName 的委托，逐档同读数
                continue
            fn = FN_MAP.get(meth)
            if fn is None or inp == "{null}":
                skipped["no_pair"] += 1
                continue
            arg = lit(inp)
            if arg is None:
                skipped["no_pair"] += 1
                continue
            if meth == "containsInvalid":
                exp = "true" if out == "true" else "false"
            else:
                exp = lit(out)
                if exp is None:
                    skipped["no_pair"] += 1
                    continue
            add("path #11.1~#11.5 FileNameUtil 纯串档（腿 N 行）",
                "  assert_eq(@path.%s(%s), %s) // %s" % (fn, arg, exp, ln))
        elif p[0] == "IT":
            # IT|isType|<name>|<types[]>|<out>
            _, _m, name, typeshs, out = ln.split("|", 4)
            # 腿的 typesOf() 给每个元素后都加一个逗号 ⇒ 末尾那个空串是分隔符伪影，不是元素；
            # 但 `[""]`（真空串类型）是参照的真值档，不能被当成伪影丢掉（腿 IT 行：`noext` 对 `[""]` 给 true）
            if name == "{null}" or typeshs == "[{nullArray}]":
                skipped["no_pair"] += 1
                continue
            parts = typeshs[1:-1].split(",")[:-1]
            if "{null}" in parts:
                skipped["no_pair"] += 1     # 表里含 null 元素：本库 Array[String] 无该形状
                continue
            arg_types = "[%s]" % ", ".join('"%s"' % t for t in parts)
            arg = lit(name)
            if arg is None:
                skipped["no_pair"] += 1
                continue
            add("path #11.6 is_type 的类型表择路（腿 IT 行：大小写/带点/空表/含空串）",
                "  assert_eq(@path.is_type(%s, %s), %s) // %s"
                % (arg, arg_types, "true" if out == "true" else "false", ln))
    lines = [HEAD.format(gen="gen_batch1_rest.py", leg="scripts/FileNameLeg.java",
                         spec="15-path.md §11"), ""]
    for t in sorted(blocks):
        lines.append('test "%s" {' % t)
        lines.extend(blocks[t])
        lines.append("}")
        lines.append("")
    lines.append("// 不落断言的读数：参照 `getSuffix`/`getPrefix` 各 %d 条 —— 它们是 `extName`/`mainName`"
                   % skipped["synonym"])
    lines.append("//   的委托，腿里两侧逐档同读数（并排钉在 spec），本库不出第二个同义件；")
    lines.append("//   null 入参与 `File` 重载档共 %d 条 —— 本库无对位形状（String 不收 null、零 FFI）。"
                   % skipped["no_pair"])
    return "\n".join(lines) + "\n", sum(len(v) for v in blocks.values())


def gen_urlpure(leg):
    blocks = {}

    def add(t, line):
        blocks.setdefault(t, []).append(line)

    skipped = {"no_pair": 0, "deferred": 0}
    for ln in leg:
        p = ln.split("|")
        if p[0] == "B" or p[0] == "W":
            if p[1] != "encodeBlank":
                continue
            if p[0] == "B":
                inp, out = p[2], p[3]
            elif p[2] == "astral":
                # `W|encodeBlank|astral|u10000|读数`：输入是码位记号，不是 esc() 形状
                cp = int(p[3][1:], 16)
                inp, out = "{u%04x}" % (0xD800 + ((cp - 0x10000) >> 10)), p[4]
                inp = inp + "{u%04x}" % (0xDC00 + ((cp - 0x10000) & 0x3FF))
            elif p[2] == "mix":
                inp, out = p[3], p[4]
            elif p[2].startswith("u") and p[2][1:].isalnum():
                # `W|encodeBlank|u0085|读数[|isWhitespace=false]`：末段是旁注，不是读数
                inp, out = "{u%04x}" % int(p[2][1:], 16), p[3]
            else:
                continue
            if inp == "{null}":
                skipped["no_pair"] += 1
                continue
            arg, exp = lit(inp), lit(out)
            if arg is None or exp is None:
                skipped["no_pair"] += 1
                continue
            add("text #1.19 encode_blank 空白逐位与混合串（腿 B/W 行）",
                "  assert_eq(@text.encode_blank(%s), %s) // %s" % (arg, exp, ln))
        elif p[0] == "D":
            # 三种行要分清楚：`getDataUri(3)`（6 段）／`getDataUri(4)`（5 段，四参重载不收）／
            # `getDataUriBase64`（5 段，但字段是 mime|base64|读数）
            if p[1] == "getDataUriBase64":
                if len(p) != 5:
                    continue
                a_mime, a_data, out = p[2], p[3], p[4]
                if "{null}" in (a_mime, a_data):
                    skipped["no_pair"] += 1
                    continue
                m, d = lit(a_mime), lit(a_data)
                exp = lit(out)
                if None in (m, d, exp):
                    skipped["no_pair"] += 1
                    continue
                add("@codec #12.2 data_uri_base64 组装（腿 D 行；base64 串**不校验**）",
                    "  assert_eq(@codec.data_uri_base64(%s, %s), %s) // %s" % (m, d, exp, ln))
                continue
            if p[1] == "getDataUri(4)":
                skipped["deferred4"] = skipped.get("deferred4", 0) + 1
                continue      # 四参重载（第 3 参是属性段、第 4 参才是数据）本批不收，理由见 spec §12.1
            if p[1] != "getDataUri(3)" or len(p) != 6:
                continue
            mime, cs, data, out = p[2], p[3], p[4], p[5]
            if "{null}" in (mime, cs, data):
                skipped["no_pair"] += 1     # 参照把 null 打成字符串 "null"（数据位）或整段省略（charset 位），
                continue                    # 本库 String 无 null 档 ⇒ 无对位形状，只在 spec 里交代
            a1, a2, a3 = lit(mime), lit(cs), lit(data)
            exp = lit(out)
            if None in (a1, a2, a3, exp):
                skipped["no_pair"] += 1
                continue
            add("@codec #12.1 data_uri 组装（腿 D 行；charset 串**原样带过**、数据**不编码**）",
                "  assert_eq(@codec.data_uri(%s, %s, %s), %s) // %s" % (a1, a2, a3, exp, ln))
        elif p[0] == "C":
            skipped["deferred"] += 1     # completeUrl：走 java.net.URL 的协议白名单，本批改判 deferred
    lines = [HEAD.format(gen="gen_batch1_rest.py", leg="scripts/UrlPureLeg.java",
                         spec="05-codec.md §12 与 01-text.md §1.19"), ""]
    # 这批读数分属两个包：`encodeBlank` 的谓词与 text 的空白表同源 ⇒ 用例落 text，
    # data_uri 落 codec。按块名前缀切，一份腿读数不拆成两份证据。
    def pkg_of(t):
        # 块名是 `text #1.19 …` / `@codec #12.1 …` 这种前缀，别按 "." 切——`#12.1` 里就有点
        return "codec" if t.startswith("@codec") else "text"
    out = {}
    for t in sorted(blocks):
        pkg = pkg_of(t)
        body = out.setdefault(pkg, [lines[0], ""])
        body.append('test "%s" {' % t)
        body.extend(blocks[t])
        body.append("}")
        body.append("")
    for pkg in out:
        out[pkg].append("// 不落断言的读数：`C|completeUrl` 共 %d 条 —— 它不是纯串面（参照把\"是不是绝对 URL\""
                        % skipped["deferred"])
        out[pkg].append("//   的判断委托给 `java.net.URL` 的协议处理器：`data:`/`tel:`/`urn:`/`javascript:` 一律")
        out[pkg].append("//   ERR:UtilException（本库收不到这种\"协议白名单\"），无 scheme 的基串又被它补成 `http://`，")
        out[pkg].append("//   且 `http://a` + `./b` 那档**不做点段归一**（与 RFC 3986 不同）。判 deferred 的理由与")
        out[pkg].append("//   逐条读数见 docs/spec/05-codec.md §5.10；本库无对位形状档 %d 条。" % skipped["no_pair"])
    return {p: "\n".join(v) + "\n" for p, v in out.items()}, sum(len(v) for v in blocks.values())


def main():
    if len(sys.argv) < 4:
        raise SystemExit(__doc__)
    rep = read_lines(os.path.abspath(sys.argv[1]))
    fn = read_lines(os.path.abspath(sys.argv[2]))
    up = read_lines(os.path.abspath(sys.argv[3]))
    r_txt, r_n = gen_replacer(rep)
    f_txt, f_n = gen_filename(fn)
    u_map, u_n = gen_urlpure(up)
    write(os.path.join("text", "replacer_test.mbt"), r_txt)
    write(os.path.join("path", "filename_test.mbt"), f_txt)
    for pkg, txt in u_map.items():
        name = "encode_blank_test.mbt" if pkg == "text" else "data_uri_test.mbt"
        write(os.path.join(pkg, name), txt)
    print("replacer=%d filename=%d urlpure=%d (分包: %s)" % (
        r_n, f_n, u_n, ", ".join("%s=%d" % (k, sum(1 for l in v.splitlines() if l.startswith("  assert")))
                                 for k, v in u_map.items())))
    return 0


if __name__ == "__main__":
    sys.exit(main())
