# moon-hutool/re —— 第二批（RegexPool 常量表）的**改写规则表**：腿原文 → 本库方言
#
# 为什么要有这个文件：`docs/spec/10-re.md` §0.2 定了"本包不对调用方的模式串做自动改写"，
# 而常量表这一格又必须给出本库引擎吃得下的串。两条立场不打架的前提是——
# **这里的改写不是逐条手改，而是一张封闭规则表**，每条规则都要能回答"两侧为什么是同一个集合"。
# 规则表在本文件，改写串由它从腿（`scripts/RePoolLeg.java` 的 `R`/`P` 行）机器产出；
# 人不手打任何一个字符，规则改了则表与期望一起重跑。
#
# 用法（stdout 纯 ASCII，本机控制台是 GBK）：
#   python scripts/re_preset_rewrite.py <leg.tsv>            # 逐条判定表
#   python scripts/re_preset_rewrite.py <leg.tsv> --mbt f    # 另把判定 OK 的改写串写成 `名字 => "串"` 档
import io
import sys

# owner 点名的业务码表族：本批**不收**。判据不是"改写不出来"，而是"这一族归 `typex` 的码表件管"——
# 电话/身份证/车牌/信用代码在那几格里带校验位与地区表，正则只是它们的切片之一。
EXCLUDED = (
    "MOBILE",
    "MOBILE_HK",
    "MOBILE_TW",
    "MOBILE_MO",
    "TEL",
    "TEL_400_800",
    "CITIZEN_ID",
    "PLATE_NUMBER",
    "CREDIT_CODE",
    "CAR_VIN",
    "CAR_DRIVING_LICENCE",
)

CASE_INSENSITIVE = 2
UNICODE_CASE = 64
LITERAL = 32
KNOWN_FLAGS = CASE_INSENSITIVE | UNICODE_CASE | LITERAL

HEX = "0123456789abcdefABCDEF"
NL = chr(10)  # 生成物一律 bare LF（本仓新文件惯例）

# R1：Java 默认（不开 UNICODE_CHARACTER_CLASS）下这三个 shorthand 就**等于**右边那个集合，
# 所以这是同一集合的两种写法，不是近似。类内用裸档（不能再套一层方括号），类外用带括号档。
ASCII_SET = {
    "d": ("0-9", "[0-9]"),
    "w": ("0-9A-Za-z_", "[0-9A-Za-z_]"),
    "s": (" \\t\\n\\x0b\\f\\r", "[ \\t\\n\\x0b\\f\\r]"),
}

RULES = (
    ("R1", "\\d \\w \\s → 同一 ASCII 集合的显式写法（类内裸档、类外带括号）"),
    ("R2", "\\xHH → \\u00HH（同一码位的两种写法）"),
    ("R3", "类首的 `:` 挪到末尾（core 把 `[` 紧跟 `:` 读成 POSIX 类的开头；字符类是无序集合，挪位不改集合）"),
    ("R4", "类里**没有 range 身份**的裸 `-` 加反斜杠：三处都算——"
           "紧跟展开式的（Java 里 `[\\w-+]` 的 `-` 是字面量，展开后会被读成 `_` 到 `+` 的 range）、"
           "类首的、类尾的（§7 实测 core 把 `[-a]` 与 `[a-]` 都判编译报错，而 Java 里它们是字面量 `-`）"),
    ("R5", "CASE_INSENSITIVE → scoped `(?i:…)` 包整串（§5 第 8 行实测折叠范围两腿同为 ASCII 档）"),
    ("R6", "代理对 → 码位（Java 的串是 UTF-16 码元，本库是码位序列；成对代理必须合成，"
           "否则改写串里是两个永远匹配不到的码位）"),
    ("R7", "类外的裸 `]` 加反斜杠（Java 把未配对的 `]` 当字面量，core 判语法错；"
           "腿的 J 行实测两侧对 `a]b` 判的是同一个字面值）"),
)

class Reject(Exception):
    """这条常量超出规则表 ⇒ 登记不做，并带上是哪个构造挡住的（进 spec 的"不做"表）。"""


def leg_unesc(s):
    """腿的 `esc()` 反解：`\\\\`→反斜杠、`\\\"`→双引号、`\\uXXXX`→那个字符本身。"""
    out = []
    i = 0
    while i < len(s):
        if s[i] == "\\" and i + 1 < len(s):
            n = s[i + 1]
            if n == "\\":
                out.append("\\")
                i += 2
                continue
            if n == '"':
                out.append('"')
                i += 2
                continue
            if n == "u" and len(s) >= i + 6 and all(c in HEX for c in s[i + 2:i + 6]):
                out.append(chr(int(s[i + 2:i + 6], 16)))
                i += 6
                continue
        out.append(s[i])
        i += 1
    return "".join(out)


def join_pairs(s):
    """R6：把 UTF-16 代理对合成码位；出现孤立代理就 Reject。"""
    out = []
    i = 0
    while i < len(s):
        c = s[i]
        if 0xD800 <= ord(c) <= 0xDBFF:
            if i + 1 < len(s) and 0xDC00 <= ord(s[i + 1]) <= 0xDFFF:
                out.append(chr(0x10000 + ((ord(c) & 0x3FF) << 10) + (ord(s[i + 1]) & 0x3FF)))
                i += 2
                continue
            raise Reject("孤立代理码位（Java 的 UTF-16 内部件，本库没有对应物）")
        if 0xDC00 <= ord(c) <= 0xDFFF:
            raise Reject("无高代理相配的低代理码位")
        out.append(c)
        i += 1
    return "".join(out)


def take_escape(src, i):
    """反斜杠转义的唯一消费口 → `(kind, 值, 消费长度, 规则号)`。
    kind='set' 是 Java 的 shorthand（交给 R1 展开）；kind='lit' 的值就是写进输出串的那几字符。"""
    n = src[i + 1:i + 2]
    if n == "":
        raise Reject("以反斜杠收尾")
    if n in ASCII_SET:
        return ("set", n, 2, "R1")
    if n == "x":
        h = src[i + 2:i + 4]
        if len(h) != 2 or any(c not in HEX for c in h):
            raise Reject("\\x 后面不是两个十六进制位")
        return ("lit", "\\u00" + h, 4, "R2")
    if n == "u":
        h = src[i + 2:i + 6]
        if len(h) != 4 or any(c not in HEX for c in h):
            raise Reject("\\u 后面不是四个十六进制位")
        return ("lit", "\\u" + h, 6, None)
    if n in "nrtf":
        return ("lit", "\\" + n, 2, None)
    if n.isdigit():
        raise Reject("反向引用 \\" + n + "（core 编译期报错）")
    if n in "pPDWSbBAEGQzZuUvV":
        raise Reject("类构造 \\" + n + "（规则表不收；core 侧的编译面读数见 §0.2）")
    if n.isalpha():
        raise Reject("未登记的字母转义 \\" + n)
    return ("lit", "\\" + n, 2, None)


def class_end(src, start):
    """字符类右括号的位置。嵌套类（Java 的 `[a[b]]`）core 未证 ⇒ Reject。"""
    i = start + 2 if src[start + 1:start + 2] == "^" else start + 1
    if src[i:i + 1] == "]":  # 首位 `]` 是字面量（两引擎同规）
        i += 1
    while i < len(src):
        c = src[i]
        if c == "\\":
            i += take_escape(src, i)[2]
            continue
        if c == "]":
            return i
        if c == "[":
            raise Reject("嵌套字符类")
        i += 1
    raise Reject("未闭合的字符类")


def class_items(body):
    """类内容 → 记号表 `[('neg'|'ch'|'esc'|'set'|'range', 值)]`。
    range 只在"单字符字面量 `-` 单字符字面量"上成；紧跟 shorthand 展开的 `-` 记成字面量
    （Java 就这么处理：`[\\w-+]` 不报"非法 range"，因为它不把 `\\w` 当 range 边界）。"""
    items = []
    i = 1 if body.startswith("^") else 0
    if body.startswith("^"):
        items.append(("neg", "^"))
    if body[i:i + 1] == "]":
        items.append(("ch", "]"))
        i += 1
    while i < len(body):
        c = body[i]
        if c == "\\":
            kind, val, width, _r = take_escape(body, i)
            items.append(("set", val) if kind == "set" else ("esc", val))
            i += width
            continue
        if (c == "-" and len(items) > 1 and items[-1][0] == "ch" and i + 1 < len(body)
                and body[i + 1] not in ("]", "\\", "-")):
            hi = body[i + 1]
            if hi == "[":
                raise Reject("嵌套字符类")
            items[-1] = ("range", items[-1][1] + "-" + hi)
            i += 2
            continue
        if c == "[":
            raise Reject("嵌套字符类")
        items.append(("ch", c))
        i += 1
    return items


def rewrite_class(body):
    """类内容 → (改写串, 规则号)：R1/R2 在记号表里定，R3/R4 在这里落。"""
    items = class_items(body)
    notes = []
    neg = ""
    if items and items[0][0] == "neg":
        neg = "^"
        items = items[1:]
    if neg == "" and len(items) > 1 and items[0] == ("ch", ":"):
        # R3：集合无序，把首位的 `:` 挪到末尾。只在**没有 `^` 前缀**时挪——
        # core 拒的是 `[` 紧跟 `:`，`[^:` 实测合法（URI 那一条），多挪一处就是无据改写。
        items = items[1:] + [items[0]]
        notes.append("R3")
    parts = []
    for idx, (k, v) in enumerate(items):
        if k == "set":
            parts.append(ASCII_SET[v][0])
            if "R1" not in notes:
                notes.append("R1")
            continue
        if k == "esc" and v.startswith("\\u00") and "R2" not in notes:
            notes.append("R2")
        # R4：这一项是不是"没有 range 身份的裸 `-`"——类首、类尾、紧跟展开式，三种都算
        edge_dash = (k == "ch" and v == "-" and (
            idx == 0 or idx == len(items) - 1 or items[idx - 1][0] == "set"))
        if edge_dash:
            parts.append("\\-")
            if "R4" not in notes:
                notes.append("R4")
            continue
        parts.append(v)
    return "[" + neg + "".join(parts) + "]", notes


def check_group(src, i):
    """`(` 后面的构造：core 只收 `(`、`(?:`、`(?<name>`；环视与其余 `(?` 构造 Reject（§0.2）。"""
    if src[i + 1:i + 2] != "?":
        return
    a = src[i + 2:i + 3]
    if a == ":":
        return
    if a == "<":
        if src[i + 3:i + 4] in ("=", "!"):
            raise Reject("环视 (?<" + src[i + 3:i + 4] + "…（core 编译期报错）")
        return
    if a in ("=", "!"):
        raise Reject("环视 (?" + a + "…（core 编译期报错）")
    raise Reject("未登记的 (? 构造：" + src[i:i + 6])


def emit(src):
    """整条模式串：类内走 `rewrite_class`，类外落 R1/R2，`(` 只做构造校验（写法两侧同形，不重写）。"""
    out = []
    notes = []
    i = 0
    while i < len(src):
        c = src[i]
        if c == "[":
            j = class_end(src, i)
            txt, ns = rewrite_class(src[i + 1:j])
            out.append(txt)
            for n in ns:
                if n not in notes:
                    notes.append(n)
            i = j + 1
            continue
        if c == "(":
            check_group(src, i)
            out.append("(")
            i += 1
            continue
        if c == "]":
            # R7：类外的裸 `]` 加反斜杠。Java 把未配对的 `]` 当字面量（EMAIL 那条就是这么写的），
            # core 判语法错——腿的 J 行实测两侧对 `a]b` 的判定同为"字面量右方括号"，所以这是同一
            # 个字面值的两种写法。
            out.append("\\]")
            if "R7" not in notes:
                notes.append("R7")
            i += 1
            continue
        if c == "\\":
            kind, val, width, rule = take_escape(src, i)
            if kind == "set":
                out.append(ASCII_SET[val][1])  # R1 类外带括号档
            else:
                out.append(val)
            if rule and rule not in notes:
                notes.append(rule)
            i += width
            continue
        out.append(c)
        i += 1
    return "".join(out), sorted(notes)


def rewrite(raw, flags):
    """腿原文 → (改写串, 规则号列表)。抛 `Reject` 就登记不做。"""
    if flags & ~KNOWN_FLAGS:
        raise Reject("未登记的旗标位 " + str(flags))
    if flags & UNICODE_CASE:
        raise Reject("UNICODE_CASE 档 core 没有对应物")
    if flags & LITERAL:
        raise Reject("LITERAL 档：整串按字面量，本库常量表没有这种件")
    s = join_pairs(leg_unesc(raw))
    txt, notes = emit(s)
    if any(0x10000 <= ord(c) for c in s):  # R6 用上了（CHINESE 那两条的 astral 段）
        notes = sorted(set(notes + ["R6"]))
    if flags & CASE_INSENSITIVE:  # R5
        txt = "(?i:" + txt + ")"
        notes = sorted(set(notes + ["R5"]))
    return txt, notes


def load(path):
    """腿 TSV → {名字: [原文(腿的 esc 形式), 旗标, 出处]}，按腿里的出现序。
    `R` 行给 RegexPool 原文，`P` 行给 PatternPool 的旗标；只在 RegexPool 有的（`URI`）旗标记 0。"""
    items = {}
    for line in io.open(path, encoding="utf-8"):
        f = line.rstrip("\r\n").split("\t")
        if f[0] == "R" and len(f) == 3:
            items[f[1]] = [f[2], 0, "RegexPool"]
        elif f[0] == "P" and len(f) == 4:
            it = items.get(f[1])
            if it is None:
                items[f[1]] = [f[2], int(f[3]), "PatternPool"]
            else:
                it[1] = int(f[3])
                it[2] = "RegexPool+PatternPool"
    return items


def verdicts(path):
    """→ [(名字, 判定, 改写串或不做理由, 规则号, 腿原文)]。"""
    rows = []
    for name, (raw, flags, src) in load(path).items():
        try:
            txt, notes = rewrite(raw, flags)
        except Reject as e:
            rows.append((name, "REJECT", str(e), [], raw))
            continue
        rows.append((name, "EXCLUDED" if name in EXCLUDED else "OK", txt, notes, raw))
    return rows


def mb_lit(txt):
    """MoonBit 字符串字面量：反斜杠翻倍、双引号转义，其余按 UTF-8 原样写（本仓文件都是 UTF-8）。"""
    return '"' + txt.replace("\\", "\\\\").replace('"', '\\"') + '"'


def a(x):
    """stdout 走 ASCII：本机控制台是 GBK，中文与码位字符直接 print 会崩掉连读数一起吞。"""
    return x.encode("unicode_escape", "backslashreplace").decode("ascii")


# 规则表自己的阳性对照：每条都是一个"改写最容易犯错"的形状，输入是腿原文的 esc 形式。
# 断言写成 (说明, 原文, 期望改写, 期望规则) 或 (说明, 原文, "REJECT", 期望理由关键词)。
SELFTEST = (
    ("R1 类外", "\\\\d+", "[0-9]+", ["R1"]),
    ("R1 类内", "^\\\\w+$", "^[0-9A-Za-z_]+$", ["R1"]),
    ("R4 展开后的裸 -", "[\\\\w-+]", "[0-9A-Za-z_\\-+]", ["R1", "R4"]),
    ("R4 类尾裸 -", "[a-]", "[a\\-]", ["R4"]),
    ("R4 类首裸 -", "[-a]", "[\\-a]", ["R4"]),
    ("R3+R4 冒号挪位后露出类首 -", "[:-]", "[\\-:]", ["R3", "R4"]),
    ("R3 类首冒号", "\\\\d{1,2}[:\\u65f6]\\\\d{1,2}", "[0-9]{1,2}[时:][0-9]{1,2}", ["R1", "R3"]),
    ("R3 不碰带脱字符的类", "([^:/?#]+)", "([^:/?#]+)", []),
    ("R2 十六进制", "[\\\\x01-\\\\x08]", "[\\u0001-\\u0008]", ["R2"]),
    ("u 转义透传", "[\\\\u4e00-\\\\u9fa5]", "[\\u4e00-\\u9fa5]", []),
    ("(?: 原样", "^(\\\\d+(?:\\\\.\\\\d+)?)$", "^([0-9]+(?:\\.[0-9]+)?)$", ["R1"]),
    # 这一条喂的是 leg_unesc **之后**的形状（腿里 CHINESE 那两条的真码位段就是代理对），
    # 所以这里直接摆码元，不再套一层 esc。
    ("R6 代理对成 range", "[%s%s-%s%s]" % (chr(0xD840), chr(0xDC00), chr(0xD869), chr(0xDEDF)),
     "[" + chr(0x20000) + "-" + chr(0x2A6DF) + "]", ["R6"]),  # 期望值取 Unicode 块边界：Ext B = U+20000–U+2A6DF
    ("R7 类外裸右方括号", "a]b", "a\\]b", ["R7"]),
    ("R7 组里的裸右方括号", "(?:x|])", "(?:x|\\])", ["R7"]),
    ("R7 不碰类内的]", "[a-z]", "[a-z]", []),
    ("反向引用拦", "\\\\d\\\\1", "REJECT", "反向引用"),
    ("环视拦", "a(?=b)", "REJECT", "环视"),
    ("嵌套类拦", "[a[b]]", "REJECT", "嵌套字符类"),
    ("p 类拦", "\\\\p{L}", "REJECT", "类构造"),
    ("W 取反拦", "\\\\W", "REJECT", "类构造"),
    ("未闭合类拦", "[abc", "REJECT", "未闭合的字符类"),
)


def selftest():
    bad = 0
    for name, raw, want, note_or_rules in SELFTEST:
        want_reject = want == "REJECT"
        try:
            txt, notes = rewrite(raw, 0)
        except Reject as e:
            if not want_reject:
                print("FAIL %s 误拦：%s" % (a(name), a(str(e))))
                bad += 1
            elif note_or_rules not in str(e):
                print("FAIL %s 拦对了但理由不对：%s" % (a(name), a(str(e))))
                bad += 1
            else:
                print("ok   %s 拦住：%s" % (a(name), a(str(e))))
            continue
        if want_reject:
            print("FAIL %s 没拦住：%s" % (a(name), a(txt)))
            bad += 1
            continue
        if txt != want or notes != note_or_rules:
            print("FAIL %s want %s %s / got %s %s" % (a(name), a(want), note_or_rules, a(txt), notes))
            bad += 1
            continue
        print("ok   %s → %s %s" % (a(name), a(txt), notes))
    print("selftest %d/%d" % (len(SELFTEST) - bad, len(SELFTEST)))
    return 1 if bad else 0


def main():
    if "--selftest" in sys.argv:
        sys.exit(selftest())
    rows = verdicts(sys.argv[1])
    print("%-22s %-9s %-11s %s" % ("NAME", "VERDICT", "RULES", "rewritten / raw (unicode-escaped, 72)"))
    for name, verdict, txt, notes, raw in rows:
        shown = raw if verdict == "REJECT" else txt
        print("%-22s %-9s %-11s %s" % (name, verdict, ",".join(notes), a(shown)[:72]))
    print("OK=%d EXCLUDED=%d REJECT=%d total=%d" % (
        sum(1 for r in rows if r[1] == "OK"),
        sum(1 for r in rows if r[1] == "EXCLUDED"),
        sum(1 for r in rows if r[1] == "REJECT"),
        len(rows)))
    print()
    for name, verdict, txt, _notes, _raw in rows:
        if verdict == "REJECT":
            print("REJECT %-22s %s" % (name, a(txt)))
    if "--mbt" in sys.argv:
        target = sys.argv[sys.argv.index("--mbt") + 1]
        lines = ["  %s => %s" % (n, mb_lit(t)) for n, v, t, _ns, _r in rows if v == "OK"]
        io.open(target, "w", encoding="utf-8", newline=NL).write(NL.join(lines) + NL)
        print("mbt rows=%d -> %s" % (len(lines), target))


if __name__ == "__main__":
    main()
