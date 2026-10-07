# moon-hutool/num —— 第四批（Calculator）的期望值生成器
#
#   python scripts/gen_num4_test.py <num4_leg.tsv> --test num/calc_test.mbt
#
# 期望值只从腿的读数来（`scripts/Num4Leg.java` 的 D/S 行）。文件里另有一份**独立求值器**
# （`Fraction` 精确十进制 + 复刻 div 的 scale=10 HALF_UP），它不产期望值，只做两件事：
#   1) 自检：腿给了数值的每一格，求值器必须给同一个数——不一致就直接退出（说明我对算法的理解
#      与参照不符，先把理解修对，别把期望抄上去）；
#   2) 供 §11.4 第 17 行那族"形状合法、参照自己崩"的格子取值（如 7 层嵌套那批），
#     每格注释里都写明"参照读数 = ERR_xxx，本库值由求值器按同一套规则推导"。
import io
import re
import sys
from fractions import Fraction

NL = chr(10)


def unesc(s):
    out, i = [], 0
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
            if n == "u" and len(s) >= i + 6:
                out.append(chr(int(s[i + 2:i + 6], 16)))
                i += 6
                continue
        out.append(s[i])
        i += 1
    return "".join(out)


# ---------------------------------------------------------------- 独立求值器（自检用）
OP = set("+-*/()%")
PRIO = {"(": 0, ")": 3, "*": 2, "+": 1, ",": -1, "-": 1, "/": 2}
SHAPE = "SHAPE"


class Bad(Exception):
    def __init__(self, kind, payload=""):
        Exception.__init__(self, kind)
        self.kind = kind
        self.payload = payload


def transform(expr):
    s = re.sub(r"\s+", "", expr)
    if s.endswith("="):
        s = s[:-1]
    a = list(s)
    for i, c in enumerate(a):
        if c == "-":
            if i == 0 or (i > 0 and a[i - 1] in "+-/*(Ee"):
                a[i] = "~"
        elif c in "xX":
            a[i] = "*"
    if a and a[0] == "~" and len(a) > 1 and a[1] == "(":
        a[0] = "-"
        return "0" + "".join(a)
    return "".join(a)


def prepare(expr):
    postfix, ops, arr = [], [","], list(expr)
    cur, count = 0, 0
    for i in range(len(arr)):
        c = arr[i]
        if c in OP:
            if count > 0:
                postfix.append("".join(arr[cur:cur + count]))
            peek = ops[-1]
            if c == ")":
                if "(" not in ops:
                    raise Bad(SHAPE)
                while ops[-1] != "(":
                    postfix.append(ops.pop())
                ops.pop()
            else:
                want = PRIO["/"] if c == "%" else PRIO[c]
                while c != "(" and peek != "," and (PRIO["/" ] if peek == "%" else PRIO[peek]) >= want:
                    postfix.append(ops.pop())
                    peek = ops[-1]
                ops.append(c)
            count = 0
            cur = i + 1
        else:
            count += 1
    if count > 1 or (count == 1 and not (cur < len(arr) and arr[cur] in OP)):
        postfix.append("".join(arr[cur:cur + count]))
    while ops[-1] != ",":
        postfix.append(ops.pop())
    if "(" in ops or ")" in postfix:
        raise Bad(SHAPE)
    return postfix


def parse_operand(tok):
    # 参照那句 `Unparseable number: "x"` 里的 x 是**替过记号之后**的 token（源码先 `replace("~","-")`
    # 再交给解析器），所以报错载荷也要用替换后的串——`--5` 的载荷是 "-" 而不是 "~-"。
    shown = tok.replace("~", "-")
    s = shown.replace(" ", "")
    i, n = 0, len(s)
    if i < n and s[i] in "+-":
        i += 1
    start = i
    while i < n and s[i].isdigit():
        i += 1
    has_int = i > start
    dot = -1
    if i < n and s[i] == ".":
        dot = i
        i += 1
        while i < n and s[i].isdigit():
            i += 1
    has_frac = dot >= 0 and i > dot + 1
    if not has_int and not has_frac:
        raise Bad("NUM", shown)
    end = i
    while end < n and s[end] == "," and end + 1 < n and s[end + 1].isdigit():
        j = end + 1
        while j < n and s[j].isdigit():
            j += 1
        end = j
    if end < n and s[end] in "eE":
        j = end + 1
        if j < n and s[j] in "+-":
            j += 1
        k = j
        while k < n and s[k].isdigit():
            k += 1
        if k > j and (s[end] == "E" or k == n):
            end = k
    try:
        return Fraction(s[:end].replace(",", ""))
    except ValueError:
        raise Bad("NUM", shown)


def dec_str(x):
    if x.denominator == 1:
        return str(x.numerator)
    d, scale = x.denominator, 0
    while d % 2 == 0 or d % 5 == 0:
        d //= 2 if d % 2 == 0 else 5
        scale += 1
    if d != 1:
        raise Bad(SHAPE)
    n = abs(x.numerator) * (10 ** scale) // x.denominator
    s = str(n).rjust(scale + 1, "0")
    body = s if scale == 0 else s[:-scale] + "." + s[-scale:]
    return ("-" if x < 0 else "") + body


def div10(a, b):
    if b == 0:
        raise Bad("DIV0")
    q = (a * (10 ** 10)) / b
    sign = -1 if q < 0 else 1
    aq = q * sign
    ip = aq.numerator // aq.denominator
    if aq - ip >= Fraction(1, 2):
        ip += 1
    return Fraction(sign * ip, 10 ** 10)


def rem(a, b):
    if b == 0:
        raise Bad("DIV0")
    q = a / b
    t = Fraction(int(abs(q.numerator) // abs(q.denominator)))
    if q < 0:
        t = -t
    return a - t * b


def calc(expr):
    stack = []
    for item in prepare(transform(expr)):
        if len(item) == 1 and item in "+-*/%":
            if len(stack) < 2:
                raise Bad(SHAPE)
            second, first = stack.pop(), stack.pop()
            a = parse_operand(first)
            b = parse_operand(second)
            op = item
            v = {"+": lambda: a + b, "-": lambda: a - b, "*": lambda: a * b,
                 "/": lambda: div10(a, b), "%": lambda: rem(a, b)}[op]()
            stack.append(dec_str(v))
        else:
            stack.append(item)
    if not stack:
        return Fraction(0)
    out = Fraction(1)
    for x in stack:
        out *= parse_operand(x)
    return out


def as_double(x):
    try:
        return float(x)
    except OverflowError:
        return float("inf") if x > 0 else float("-inf")


# ---------------------------------------------------------------- 期望值装配
PRELUDE = '''///|
// 本文件是生成物：`python scripts/gen_num4_test.py <腿.tsv> --test num/calc_test.mbt`
// 期望值只从参照腿 `scripts/Num4Leg.java` 的读数来；本生成器另带一份**独立求值器**，
// 它不产期望值，只做两件事：① 腿给数值的每一格都必须与求值器同值（不同值就拒绝生成），
// ② 给 §11.4 第 17 行那族"式子合法、参照自己崩"的格子取值（注释里逐格写明参照读数）。
// 契约与形状决策：docs/spec/08-num.md §11。改任何一条期望串须单独一笔并给外部读数来源（门禁 G5）。
// 一条读数解释的坑：Java 的 `Double.toString` 不总给最短表示——腿把 `1e23` 打成 `9.999999999999999E22`，
// 那与十进制精确值 `1e23` 落进 `Double` 是同一个数（`new BigDecimal(1e23)` ⇒ `99999999999999991611392`）。
// 本文件比对的是两侧的 `Double`，所以期望写 `(1.0e23)` 是**对的**，别照腿的字面串去"改错期望"。

///|
// 值档：抛错就意味着"这一格本该有答案"，直接 abort 让块红得看得见
fn calc_val(body : String) -> Double {
  @num.num_calculate(body) catch {
    _ => abort("不该抛错：" + body)
  }
}

///|
// 错误档：只带变体名；`NotDecimal` 带 token（参照那句 `Unparseable number: "x"` 的就是 x）。
// 末档兜住 `NumError` 的其余变体（这件的匹配必须穷尽，否则 `partial_match` 判错）：
// 真落到兜底就说明本库把这格抛成了别的档，`show` 把变体名原样报出来，块直接红。
fn calc_err(body : String) -> String {
  try {
    let _ = @num.num_calculate(body)
    "未抛错"
  } catch {
    @num.BadExpression(_) => "BadExpression"
    @num.NotDecimal(t) => "NotDecimal \{t}"
    @num.DivZero => "DivZero"
    e => "其他 " + show(e)
  }
}
'''

CHUNK = 12  # 每块最多 12 格：块太大时一条红会掩盖块内其余（cron 轮记过的教训）


def mb_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def mb_num(v):
    """float → MoonBit 字面量。腿那侧 `String.valueOf(double)` 是最短往返表示，
    回读成字面量即逐位同值；尾数补一个 `.`、指数统一小写（Java 给 `1.0E12`）。"""
    if v != v:
        return "@double.nan()"
    if v == float("inf"):
        return "@double.infinity"
    if v == float("-inf"):
        return "@double.neg_infinity"
    s = repr(v)
    if "e" in s:
        head, tail = s.split("e")
        if "." not in head:
            head += ".0"
        s = head + "e" + tail.lstrip("+")
    elif "." not in s:
        s += ".0"
    return "(" + s + ")"


def classify(expr, reading):
    """腿读数 → (断言行, 注记)。每一格都过一遍求值器做自检。"""
    try:
        mine = as_double(calc(expr))
        mine_bad = None
    except Bad as e:
        mine, mine_bad = None, e
    # 分岔一档：参照的数字扫描走 JDK 的 `Character.digit(c,10)`，任何 Unicode 十进制数字都算数字
    # （腿读数 `١٢`⇒`12.0`）。本库只认 ASCII `0-9`——复刻这一档要带一张 Unicode Nd 表（数百码位），
    # 而这条能力在本库没有任何消费方，spec §11.4 第 19 行按分岔记，期望由这条规则推导而非照抄参照。
    if any(c.isdigit() and not c.isascii() for c in expr):
        return "assert_eq(calc_err(%s), %s)" % (
            mb_str(expr), mb_str("NotDecimal " + expr.replace(" ", ""))), (
            reading + "｜分岔：参照认 Unicode 十进制数字（§11.4 第 19 行），本库只认 ASCII ⇒ 该位置判坏")
    if reading.startswith("ERR_ArithmeticException"):
        need(mine_bad is not None and mine_bad.kind == "DIV0", expr, reading)
        return "assert_eq(calc_err(%s), %s)" % (mb_str(expr), mb_str("DivZero")), reading
    if reading.startswith("ERR_NumberFormatException") or reading.startswith(
            "ERR_IllegalArgumentException") or reading.startswith("ERR_IllegalArgumentException"):
        # 载荷取参照那句里的 token（腿读数里带 \"...\"）。参照不给 token 的那一档
        # （hutool 的 `Number is invalid!` 走的是 isNaN 检查）退回求值器同一格的串，注记里写明来源。
        m = re.search(r"Unparseable number: \\\"(.*)\\\"$", reading)
        tok = unesc(m.group(1)) if m else (mine_bad.payload if mine_bad else "")
        src = "腿" if m else "求值器（参照那句不带 token）"
        if tok in ("(", ")", ""):
            return "assert_eq(calc_err(%s), %s)" % (
                mb_str(expr), mb_str("BadExpression")), reading + "｜token 是括号 ⇒ 形状档"
        need(mine_bad is not None and mine_bad.kind == "NUM" and mine_bad.payload == tok,
             expr, reading)
        return "assert_eq(calc_err(%s), %s)" % (
            mb_str(expr), mb_str("NotDecimal " + tok)), reading + "｜token 来源=" + src
    if reading.startswith("ERR_EmptyStackException") or reading.startswith(
            "ERR_IllegalStateException") or reading.startswith("ERR_ArrayIndexOutOfBounds"):
        if mine_bad is not None:
            return "assert_eq(calc_err(%s), %s)" % (
                mb_str(expr), mb_str("BadExpression")), reading + "｜两档同判"
        return "assert_eq(calc_val(%s), %s)" % (
            mb_str(expr), mb_num(mine)), (
            reading + "｜参照自己崩而式子合法：本库给算术值（spec §11.4 第 17 行，"
            "值由独立求值器按同一套规则推导）")
    need(mine_bad is None, expr, reading + "｜腿有值而求值器判坏")
    need(mb_num(mine) == mb_num(float_of(reading)), expr, reading)
    return "assert_eq(calc_val(%s), %s)" % (mb_str(expr), mb_num(mine)), "RET"


def need(cond, expr, reading):
    if not cond:
        raise SystemExit("自检不过：%r 腿=%s" % (expr, reading))


def float_of(reading):
    return float(reading.replace("E", "e"))


def main():
    path, target = sys.argv[1], sys.argv[sys.argv.index("--test") + 1]
    rows = [l.rstrip("\n").split("\t") for l in io.open(path, encoding="utf-8")]
    fixtures, seen = [], set()
    for r in rows:
        if r[0] == "D" and len(r) == 3:
            e, reading = unesc(r[1]), r[2]
        elif r[0] == "S" and len(r) == 4:
            e, reading = unesc(r[2]), r[3]
        else:
            continue
        if e in seen:  # D/V 两行同式同值，只钉一次
            continue
        seen.add(e)
        fixtures.append((e, reading))
    L = [PRELUDE]
    for bi in range(0, len(fixtures), CHUNK):
        chunk = fixtures[bi:bi + CHUNK]
        n = bi // CHUNK + 1
        L.append("///|")
        L.append('// #8.40 第四批（Calculator）第 %d 块：%d 格，每格一条腿读数' % (n, len(chunk)))
        L.append('test "calc %d" {' % n)
        for e, reading in chunk:
            line, note = classify(e, reading)
            L.append("  %s // 腿 %s" % (line, note.replace("\t", " ")[:96]))
        L.append("}")
        L.append(NL)
    io.open(target, "w", encoding="utf-8", newline=NL).write(NL.join(L) + NL)
    print("calc_test.mbt：%d 格 / %d 块" % (len(fixtures), (len(fixtures) + CHUNK - 1) // CHUNK))


if __name__ == "__main__":
    main()
