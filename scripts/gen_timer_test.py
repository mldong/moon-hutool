#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""批②（date 第六批）期望生成器：把**逐档可直读**的那几族从腿灌成用例。

用法（五条腿的读数文件按腿序给，落在工作树外、不提交）：

    python scripts/gen_timer_test.py \\
        <TimerLeg.txt> <TimerLeg2.txt> <TimerLeg3.txt> <TimerLeg4.txt> <TimerLeg5.txt>

产出两份：`date/timer_test.mbt`（单位换算/补零/百分号/时长格式化四张大表）、
`date/custom_format_test.mbt`（全局格式表的键匹配、内置算法、解析与挂载）。
状态机、`pretty_print` 的整表形状、分组计时器那批**要拼夹具**的档在
`date/timer_state_test.mbt` 里手写，每条同样带着腿读数——两类来源都用同一个前缀标注。

四条纪律（spec §9.9）：

1. **两类来源分开标**。`读数腿` = 期望串就是那条读数；`规则腿` = 值来自注入的假钟、
   判据来自那条腿/字节码（计时件的时长数字在腿里被掩成 `#`，本库一律用假钟变成确定值）。
2. **`pretty_print` 的行是拼出来的**，拼料全是腿读数：数字列 = `NF` 行、百分号 = `PC` 行，
   两处/三处空格 = `PP|one-task-nanos`/`PP|header-seg` 的字面形状，列宽常量在本文件顶部集中列出。
3. **到不了的臂不落断言**（spec §9.6/§9.8）：参照 `interval(null)`、`isCustomFormat(null)`、
   `null` id、`format(null, …)`、`TemporalAccessor` 那支、`Long.MIN` 的差值档。
4. **行分隔符**：参照 `FileUtil.getLineSeparator()` 本机现读 CRLF（腿 `LS` 行），本库恒 LF（§9.7.4）
   ⇒ 多行期望串一律按 LF 拼，不抄腿里的 CRLF。
"""
import io
import re
import sys

# ---- 列宽来源（每条标腿行；要改必须先改腿，不许在这里顺手调） ----
DASH = "---------------------------------------------"      # PP|dash-len||45
HEAD_MID = "         %     Task name"                       # PP|header-seg（shot 名之后那一段）
ROW_MID = "  "                                              # PP|one-task-nanos：数字列后两空格
ROW_TAIL = "   "                                            # 百分号后三空格再任务名

UNITS = ["NANOSECONDS", "MICROSECONDS", "MILLISECONDS", "SECONDS",
         "MINUTES", "HOURS", "DAYS"]
VAR = {
    "NANOSECONDS": "@date.Nanoseconds",
    "MICROSECONDS": "@date.Microseconds",
    "MILLISECONDS": "@date.Milliseconds",
    "SECONDS": "@date.Seconds",
    "MINUTES": "@date.Minutes",
    "HOURS": "@date.Hours",
    "DAYS": "@date.Days",
}
CU_KEYS = ["0", "1", "999", "1000", "1000000", "999999999", "1000000000",
           "60000000000", "3600000000000", "86400000000000", "604800000000000",
           "-1", "-999999999", "-1000000000", "-86400000000000",
           "9223372036854775807"]
NF_KEYS = ["0", "1", "5", "99", "12345", "99999999", "100000000",
           "999999999", "1000000000", "1234567890", "-1", "-12345"]
TI_KEYS = ["0", "1000", "1000000", "999999999", "86400000000000", "-999999999"]
FB_KEYS = ["0", "1", "999", "1000", "1001", "1500", "59000", "60000", "61000",
           "3540000", "3600000", "3600001", "7260000", "86399999", "86400000",
           "90061000", "604800000", "604801000", "8640000000",
           "9223372036854775807"]
FB_NEG = ["-1", "-1000", "-86400000"]
# 百分号档：比值由假钟的两段任务凑，数字列统一走 Days 单位 ⇒ 落回 NF|0（判据互不干扰）
# (PC 键, 第一段纳秒, 第二段纳秒, 断第几行)
PC_CASES = [
    ("0.004", 1, 249, 4), ("0.005", 1, 199, 4), ("0.006", 3, 497, 4),
    ("0.0099", 99, 9901, 4), ("0.01", 1, 99, 4), ("0.015", 3, 197, 4),
    ("0.025", 5, 195, 4), ("0.05", 5, 95, 4), ("0.0999", 999, 9001, 4),
    ("0.1", 1, 9, 4), ("0.15", 3, 17, 4), ("0.25", 1, 3, 4),
    ("0.3333333333333333", 1, 2, 4), ("0.6666666666666666", 1, 2, 5),
    ("0.5", 100, 100, 4), ("0.75", 3, 1, 4), ("0.99", 1, 99, 5),
    ("0.999", 999, 1, 4), ("1.0", 1, 0, 4), ("0.0", 1, 0, 5),
    ("NaN", 0, 0, 4), ("NaN", 0, 0, 5),
    ("Infinity", 1000000, -1000000, 4), ("-Infinity", 1000000, -1000000, 5),
    ("-0.5", -1, 3, 4), ("1.5", -1, 3, 5),
]


def decode(s):
    return re.sub(r"\{u([0-9a-fA-F]{4})\}", lambda m: chr(int(m.group(1), 16)), s)


def slit(s):
    out = []
    for ch in s:
        out.append({"\\": "\\\\", '"': '\\"', "\n": "\\n", "\r": "\\r",
                    "\t": "\\t", "{": "\\{"}.get(ch, ch))
    return '"' + "".join(out) + '"'


def dbl(s):
    """Java `Double.toString` → MoonBit 浮点字面量（最短往返十进制 ⇒ 两侧同一个数）。"""
    t = s.replace("E", "e")
    if "." not in t and "e" not in t:
        t += ".0"
    return t


def i64(v):
    n = int(v)
    return "({}L)".format(n) if n < 0 else "{}L".format(n)


def read_rows(path):
    """`TAG|key|value`（腿二 Z/P 两族）与 `TAG|key|arg|value`（其余）两种形状都吃。"""
    out = []
    for raw in io.open(path, encoding="utf-8", errors="replace").read().split("\n"):
        line = raw.rstrip("\r")
        if not line or line.startswith("LOCALE"):
            continue
        tag = line.split("|", 1)[0]
        if tag in ("Z", "P"):
            parts = line.split("|", 2)
            if len(parts) != 3:
                continue
            out.append((parts[0], parts[1], parts[2]))
        else:
            head, sep, val = line.partition("||")
            if sep == "":
                continue
            segs = head.split("|")
            out.append((segs[0], "|".join(segs[1:]), val))
    return out


def load(paths):
    d = {}
    for p in paths:
        for tag, key, val in read_rows(p):
            d[(tag, key)] = val
    return d


def cols(val):
    out = {}
    for piece in val.strip().split(" "):
        if "=" in piece:
            k, v = piece.split("=", 1)
            out[k] = v
    return out


def ti_cols(val):
    out = {}
    for piece in val.split(" "):
        if "=" in piece:
            k, v = piece.split("=", 1)
            out[k] = v
    return out


class Doc:
    def __init__(self, head):
        self.blocks = [head]

    def test(self, name, lines):
        assert lines, name
        body = "\n".join([l for l in lines if l is not None])
        self.blocks.append("///|\ntest {} {{\n{}\n}}".format(slit(name), body))

    def write(self, path):
        text = "\n\n".join(self.blocks) + "\n"
        io.open(path, "w", encoding="utf-8", newline="\n").write(text)
        print("写出 {}：{} 个 test 块 / {} 条断言".format(
            path, len(self.blocks) - 1, text.count("assert_eq(")))


def eq(expr, expect, kind, src):
    return "  assert_eq({}, {})  // {}  {}".format(expr, expect, kind, src)


def leg(doc, expr, d, tag, key, wrap=None, transform=None, extra=None):
    """期望串 = 这条腿读数本身（`读数腿`）。`transform` 先取子段，`wrap` 决定出口形状。"""
    val = d[(tag, key)]
    text = decode(transform(val)) if transform else decode(val)
    expect = wrap(text) if wrap else slit(text)
    src = extra if extra else "{}|{}||{}".format(tag, key, val)
    return eq(expr, expect, "读数腿", src)


# ============================ timer_test.mbt ============================
HELPERS = """///|
// moon-hutool/date —— 计时件的**逐档可直读**期望（第六批 §9.3、§9.5、§9.7.1/§9.7.2）。
// 由 `scripts/gen_timer_test.py` 从 `scripts/TimerLeg3.java`（SH/NF/PC）与
// `scripts/TimerLeg4.java`（CU/NS/TI）灌出来，一格都没有手打。
// 状态机、整表形状、分组计时器那批要拼夹具的档在 `date/timer_state_test.mbt`。

///|
/// 假钟：恒定给同一个读数（单位由构造口定：毫秒档就是 epoch 毫秒、纳秒档就是纳秒）
fn tm_fixed(v : Int64) -> () -> Int64 {
  () => v
}

///|
/// 脚本钟：按数组依次给读数，用尽之后重复最后一个（夹具因此只需写"变化点"）
fn tm_steps(xs : Array[Int64]) -> () -> Int64 {
  let i : Array[Int] = [0]
  () => {
    let k = i[0]
    i[0] = k + 1
    xs[if k < xs.length() { k } else { xs.length() - 1 }]
  }
}

///|
/// 跑完 `deltas` 这几段任务：每段是"这一段的纳秒数"，名字依次取 `names`（用完走缺省名）
fn tm_run(
  deltas : Array[Int64],
  names : Array[String],
  id : String,
  keep : Bool,
) -> @date.StopWatch {
  let ticks : Array[Int64] = [0L]
  let acc : Array[Int64] = [0L]
  for x in deltas {
    acc[0] = acc[0] + x
    ticks.push(acc[0])
    ticks.push(acc[0])
  }
  let sw = @date.stop_watch(tm_steps(ticks), id=id, keep_task_list=keep)
  for i in 0..<deltas.length() {
    let nm = if i < names.length() { Some(names[i]) } else { Some("") }
    sw.start(name=nm) catch { err => abort("夹具的 start 不该抛：" + show(err)) }
    sw.stop() catch { err => abort("夹具的 stop 不该抛：" + show(err)) }
  }
  sw
}

///|
/// 单任务秒表（一条任务 `n` 纳秒，名字 `t`）
fn tm_one(n : Int64, id : String) -> @date.StopWatch {
  tm_run([n], ["t"], id, true)
}

///|
/// 取 `pretty_print` 的第 n 行（数据行从下标 4 起）
fn tm_line(s : String, n : Int) -> String {
  s.split("\\n").to_array()[n].to_owned()
}

///|
/// 分组计时器夹具：脚本钟 + 依次 start 的键
fn tm_group(ticks : Array[Int64], keys : Array[String], nano : Bool) -> @date.GroupTimeInterval {
  let g = if nano {
    @date.group_time_interval_nanos(tm_steps(ticks))
  } else {
    @date.group_time_interval(tm_steps(ticks))
  }
  for k in keys {
    let _ = g.start(id=k)
  }
  g
}"""


def gen_timer(d):
    doc = Doc(HELPERS)

    lines = [leg(doc, "{}.shot_name()".format(VAR[u]), d, "SH", u) for u in UNITS]
    doc.test("date #9.3.1 ChronoUnit::shot_name 七档（微秒是 U+03BC 不是 U+00B5）", lines)

    lines = []
    for k in CU_KEYS:
        c = cols(d[("CU", k)])
        lines.append("  // CU|{}||{}".format(k, d[("CU", k)].strip()))
        for u in UNITS:
            lines.append(eq(
                "tm_one({}, \"cu\").total_in({})".format(i64(k), VAR[u]),
                i64(c[u]), "读数腿",
                "CU|{} 的 {} 列 = {}".format(k, u, c[u])))
    doc.test("date #9.3.2 total_in 的截断表 16×7（参照 getTotal = convert(totalNanos, NANOSECONDS)）", lines)

    lines = []
    for k in TI_KEYS:
        ti = d[("TI", k)]
        c = ti_cols(ti)
        lines.append("  // TI|{}||{}".format(k, ti))
        base = 'tm_one({}, "ti").last_task_info()'.format(i64(k))
        for u in UNITS:
            lines.append(eq("{}.time_in({})".format(base, VAR[u]), i64(c[u]),
                            "读数腿", "TI|{} 的 {} 列 = {}".format(k, u, c[u])))
        lines.append(eq("{}.time_nanos()".format(base), i64(c["nanos"]),
                        "读数腿", "TI|{} 的 nanos= 列".format(k)))
        lines.append(eq("{}.time_millis()".format(base), i64(c["ms"]),
                        "读数腿", "TI|{} 的 ms= 列".format(k)))
        lines.append(eq("{}.time_seconds()".format(base), dbl(c["sec"]),
                        "读数腿", "TI|{} 的 sec= 列".format(k)))
        lines.append(eq("{}.task_name()".format(base), 'Some("t")',
                        "规则腿", "TI 行的 name=k 列证「名字原样存」；本库名字由夹具给"))
    doc.test("date #9.3.3 TaskInfo 五个读数与 total 同表（参照那两条委托关系）", lines)

    lines = [eq('tm_one({}, "ns").total_seconds()'.format(i64(k)), dbl(d[("NS", k)]),
                "读数腿", "NS|{}||{}".format(k, d[("NS", k)])) for k in CU_KEYS]
    doc.test("date #9.3.4 total_seconds = nanos / 1.0E9（腿 NS 行十六档）", lines)

    lines = [
        "  // 数字列走参照 `NumberFormat.getNumberInstance()` + setMinimumIntegerDigits(9)"
        " + setGroupingUsed(false)（腿 NF 行是直接喂数取的读数）",
        "  // 单任务 ⇒ 比值恒 1.0 ⇒ 百分号取 PC|1.0 那一档"]
    for k in NF_KEYS:
        pad = decode(d[("NF", k)])
        pct = decode(d[("PC", "1.0")])
        lines.append(eq(
            'tm_line(tm_one({}, "nf").pretty_print(), 4)'.format(i64(k)),
            slit(pad + ROW_MID + pct + ROW_TAIL + "t"),
            "读数腿", "NF|{}||{} ＋ PC|1.0||{}（列宽 PP|one-task-nanos）".format(k, pad, pct)))
    doc.test("date #9.7.1 数字列补零到 9 位（含十位不截断、负号在补齐之前）", lines)

    lines = [
        "  // 比值 a/(a+b) 由假钟的两段任务凑；数字列统一走 Days 单位 ⇒ 落回 NF|0 那一档，"
        "这样 §9.7.2 的舍入判据与 §9.7.1 的列宽判据互不干扰"]
    for key, a, b, idx in PC_CASES:
        pad = decode(d[("NF", "0")])
        pct = decode(d[("PC", key)])
        name = "t0" if idx == 4 else "t1"
        lines.append(eq(
            'tm_line(tm_run([{}], [{}], "pc", true).pretty_print(unit=@date.Days), {})'.format(
                ", ".join(i64(str(x)) for x in (a, b)),
                ", ".join(['"{}"'.format(n) for n in ("t0", "t1")]), idx),
            slit(pad + ROW_MID + pct + ROW_TAIL + name),
            "读数腿", "PC|{}||{}（比值 {}）".format(key, pct, key)))
    doc.test("date #9.7.2 百分号：×100 后 HALF_EVEN、最少 2 位、NaN 不出百分号、∞ 出 U+221E", lines)

    lines = []
    for k in FB_KEYS:
        lines.append(leg(doc, "@date.format_between({})".format(i64(k)), d, "FB", k,
                         transform=lambda v: v.split(" ~ ")[0]))
    doc.test("date #9.5.1 format_between 正数档（零值档整段跳过、逐级借位）", lines)

    lines = [
        "  // 判据 1：参照字节码第一行就是 `betweenMs > 0` 的总闸 ⇒ 非正一律走「补 0 + 当档名」那一步"]
    for k in FB_NEG:
        lines.append(leg(doc, "@date.format_between({})".format(i64(k)), d, "FB", k,
                         transform=lambda v: v.split(" ~ ")[0]))
    lines.append("  // 对照：同一绝对值在正半边不是这个读数 ⇒ 负数**不是**取绝对值、也不是带符号")
    lines.append(leg(doc, "@date.format_between(1000L)", d, "FB", "1000",
                     transform=lambda v: v.split(" ~ ")[0]))
    for name in ["DAY", "HOUR", "MINUTE", "SECOND", "MILLISECOND"]:
        lines.append("  // 参照 Level.{} 的档名 = {}（腿 FB|level-name-{}）".format(
            name, decode(d[("FB", "level-name-" + name)]), name))
    doc.test("date #9.5.2 非正档一律 0毫秒，五档档名逐个出场", lines)
    doc.write("date/timer_test.mbt")


# ======================== custom_format_test.mbt ========================
CF_HELPERS = """///|
// moon-hutool/date —— 全局自定义格式表的冻结期望（第六批 §9.6）。
// 由 `scripts/gen_timer_test.py` 从 `scripts/TimerLeg3.java`（GF 行）、`TimerLeg4.java`（EP 行）、
// `TimerLeg5.java`（P5 行）、`TimerLeg.java`（F 行）灌出来，一格都没有手打。
//
// 三个到不了的臂不落断言（§9.6/§9.8）：`isCustomFormat(null)`、`format(null, #SSS)`、
// `parse(null, #sss)` 三条 NPE，以及 `format(TemporalAccessor, #sss)` 那支（`LocalTime` 档实测要读今天）。
//
// 进程级表必须收尾复位：每个动过 `set_custom_*` 的块在末尾调 `reset_custom_format`（§9.8 第 4 行）。

///|
/// 本批夹具用的瞬间（腿里全程是 `new Date(1700000000123L)`，逐条读数都对齐这个值）
const CF_MILLIS : Int64 = 1700000000123L"""


def gen_custom(d):
    doc = Doc(CF_HELPERS)
    M = str(CF_MILLIS)

    lines = [
        leg(doc, "@date.custom_format_seconds", d, "GF", "FORMAT_SECONDS"),
        leg(doc, "@date.custom_format_milliseconds", d, "GF", "FORMAT_MILLISECONDS"),
    ]
    for k in ["#sss", "#SSS", "#sss ", " #sss", "#ss", "#SS", "sss", "", "#SSSS"]:
        key = "isCustom[{}]".format(k)
        lines.append(eq("@date.is_custom_format({})".format(slit(k)),
                        "true" if d[("GF", key)] == "true" else "false",
                        "读数腿", "GF|{}||{}".format(key, d[("GF", key)])))
    lines.append("  // 九档里没有任何大小写折叠：`#SS`/`#ss` 两档同假，内置两档各只在原样那档为真")
    doc.test("date #9.6.1 两个常量键 + is_custom_format 精确匹配九档", lines)

    lines = [
        leg(doc, '@date.custom_format(CF_MILLIS, "#sss")', d, "GF", "format(d,#sss)",
            wrap=lambda s: "Some({})".format(slit(s))),
        leg(doc, '@date.custom_format(CF_MILLIS, "#SSS")', d, "GF", "format(d,#SSS)",
            wrap=lambda s: "Some({})".format(slit(s))),
        eq('@date.custom_format(CF_MILLIS, "yyyy")', "None", "读数腿",
           "GF|format(d,plain)||{} ⇒ 未登记既不抛也不回落到普通 pattern".format(
               d[("GF", "format(d,plain)")])),
    ]
    for k in ["0", "999", "1000", "-1", "-999", "-1000", "-1001", "1700000000123",
              "-1700000000123", "-9223372036854775808", "9223372036854775807"]:
        val = d[("EP", k)].split("|")[0]
        lines.append(eq('@date.custom_format({}, "#sss")'.format(i64(k)), "Some({})".format(slit(val)),
                        "读数腿", "EP|{}||{} 的第一列：#sss = Math.floorDiv（负半边向下）".format(
                            k, d[("EP", k)])))
    for k in ["0", "-1", "1700000000123", "-1700000000123", "999", "-999"]:
        val = d[("EP", k)].split("|")[1]
        lines.append(eq('@date.custom_format({}, "#SSS")'.format(i64(k)), "Some({})".format(slit(val)),
                        "读数腿", "EP|{}||{} 的第二列：#SSS 原样给毫秒".format(k, d[("EP", k)])))
    doc.test("date #9.6.2 内置两档的算法（floorDiv 的负半边 + 毫秒原样档）", lines)

    lines = []
    for s in ["1700000000", "1700000000123", "0", "-1", "1.5", "", "abc",
              "99999999999999999999", " 1700000000", "1700000000 ", "+1700000000"]:
        for unit in ["#sss", "#SSS"]:
            key = "parse({},{})".format(s, unit)
            if ("GF", key) not in d:
                continue
            val = d[("GF", key)]
            expr_shape = "@date.custom_parse({}, {})".format(slit(s), slit(unit))
            if val.startswith("ERR:"):
                lines.append(eq(
                    'shape(() => {})'.format(expr_shape),
                    slit("NotAnInteger " + s), "读数腿",
                    "GF|{}||{} ⇒ 参照 message 带的就是那个原串，本库变体照带".format(key, val)))
            else:
                lines.append(eq(expr_shape, "Some({})".format(i64(val)), "读数腿",
                                "GF|{}||{}".format(key, val)))
    lines.append("  // 接受集：不 trim、不收小数、不收空串、不收超范围纯数字、**收 `+` 前缀与负号**")
    doc.test("date #9.6.3 解析侧的接受集（十一档 × 两个键）", lines)

    lines = []
    for s in ["9223372036854775", "9223372036854775807", "-9223372036854775808",
              "9223372036", "-9223372036854776", "1700000000"]:
        for unit in ["#sss", "#SSS"]:
            key = "overflow臂|parse({},{})".format(s, unit)
            if ("P5", key) not in d:
                continue
            val = d[("P5", key)]
            expr_shape = "@date.custom_parse({}, {})".format(slit(s), slit(unit))
            if val.startswith("ERR:"):
                lines.append(eq('shape(() => {})'.format(expr_shape),
                                slit("MillisOverflow " + s), "读数腿",
                                "P5|{}||{} ⇒ 参照是 Math.multiplyExact；本库 Int64 乘法静默回绕，"
                                "必须自己判溢出".format(key, val)))
            else:
                lines.append(eq(expr_shape, "Some({})".format(i64(val)), "读数腿",
                                "P5|{}||{}".format(key, val)))
    lines.append("  // `#SSS` 那侧没有乘法 ⇒ 同输入不溢出（两列并排就是这条的对照）")
    doc.test("date #9.6.4 `#sss` 的溢出档是另一种错（腿 P5 六档 × 两键）", lines)

    lines = [
        eq('@date.custom_parse("2023", "yyyy")', "None", "读数腿",
           "GF|parse(x,plain)||{} ⇒ 未登记给 None".format(d[("GF", "parse(x,plain)")])),
    ]
    doc.test("date #9.6.5 未登记的键两表都不给数（不抛错）", lines)

    lines = [
        "  // 覆盖内置键：参照改的就是那张共享表，门面立刻跟着变（腿 GF|override-#sss 三档）",
        leg(doc, '@date.custom_format(CF_MILLIS, "#sss")', d, "GF", "override-#sss-before",
            wrap=lambda s: "Some({})".format(slit(s))),
        '  @date.set_custom_format("#sss", ms => "O" + ms.to_string())',
        leg(doc, '@date.custom_format(CF_MILLIS, "#sss")', d, "GF", "override-#sss-after",
            wrap=lambda s: "Some({})".format(slit(s))),
        '  @date.set_custom_format("#sss", ms => (ms / 1000L).to_string())',
        leg(doc, '@date.custom_format(CF_MILLIS, "#sss")', d, "GF", "override-#sss-还原",
            wrap=lambda s: "Some({})".format(slit(s))),
        '  @date.reset_custom_format("#sss")',
        leg(doc, '@date.custom_format(CF_MILLIS, "#sss")', d, "GF", "override-#sss-还原",
            wrap=lambda s: "Some({})".format(slit(s)),
            extra="reset 之后必须回到**内置算法**（同一条读数 override-#sss-还原），而不是把键删掉"),
    ]
    doc.test("date #9.6.6 覆盖与还原内置键（reset 走内置算法复原）", lines)

    lines = [
        "  // 只登记 parser ⇒ 门面上隐形（参照 isCustomFormat 只查 formatter 表，字节码现读）",
        '  @date.set_custom_parser("#ponly", _ => 42L)',
        eq('@date.is_custom_format("#ponly")', "false", "读数腿",
           "P5|parser-only|isCustomFormat||" + d[("P5", "parser-only|isCustomFormat")]),
        eq('@date.custom_parse("x", "#ponly")', "Some(42L)", "读数腿",
           "P5|parser-only|GlobalCustomFormat.parse||{} ⇒ 直接查表仍然通".format(
               d[("P5", "parser-only|GlobalCustomFormat.parse")])),
        eq('@date.custom_format(CF_MILLIS, "#ponly")', "None", "读数腿",
           "P5|parser-only|DateUtil.parse(走不走这张表)||{} ⇒ 参照走的是 pattern 支并直接抛；"
           "本库 formatter 表没这个键 ⇒ None".format(
               d[("P5", "parser-only|DateUtil.parse(走不走这张表)")])),
        "  // 只登记 formatter ⇒ 看得见，但 parse 那侧没有落落点",
        '  @date.set_custom_format("#fonly", ms => "F" + ms.to_string())',
        eq('@date.is_custom_format("#fonly")', "true", "读数腿",
           "P5|formatter-only|isCustomFormat||" + d[("P5", "formatter-only|isCustomFormat")]),
        leg(doc, '@date.custom_format(CF_MILLIS, "#fonly")', d, "P5",
            "formatter-only|DateUtil.format", wrap=lambda s: "Some({})".format(slit(s))),
        eq('@date.custom_parse("F1700000000123", "#fonly")', "None", "读数腿",
           "P5|formatter-only|GlobalCustomFormat.parse||{} ⇒ 参照的 DateUtil.parse 这一档给『现在』"
           "（P5|formatter-only|DateUtil.parse 带 (是不是现在?true) 自证），本库给 None：见 §9.8 第 6 行".format(
               d[("P5", "formatter-only|GlobalCustomFormat.parse")])),
        "  // 补齐 parser 之后 parse 才通得动（腿 P5|pair 三档）",
        '  @date.set_custom_parser("#pair", _ => 7L)',
        eq('@date.is_custom_format("#pair")', "false", "读数腿",
           "P5|pair|补 formatter 之前 isCustom||" + d[("P5", "pair|补 formatter 之前 isCustom")]),
        '  @date.set_custom_format("#pair", _ => "P")',
        eq('@date.is_custom_format("#pair")', "true", "读数腿",
           "P5|pair|补上之后 isCustom||" + d[("P5", "pair|补上之后 isCustom")]),
        eq('@date.custom_parse("x", "#pair")', "Some(7L)", "读数腿",
           "P5|pair|补上之后 DateUtil.parse||" + d[("P5", "pair|补上之后 DateUtil.parse")]),
        '  @date.reset_custom_format("#ponly")',
        '  @date.reset_custom_format("#fonly")',
        '  @date.reset_custom_format("#pair")',
        eq('@date.is_custom_format("#sss")', "true", "读数腿",
           "P5|收尾|isCustom(#sss)||" + d[("P5", "收尾|isCustom(#sss)")]),
        leg(doc, '@date.custom_format(CF_MILLIS, "#sss")', d, "P5", "收尾|#sss 读数",
            wrap=lambda s: "Some({})".format(slit(s)),
            extra="P5|收尾|#sss 读数||{} ⇒ 前面动的都是别的键，内置档不许被牵连".format(
                d[("P5", "收尾|#sss 读数")])),
    ]
    doc.test("date #9.6.7 两张表的不对称（parser-only 隐形 / formatter-only 看得见 / 收尾自证）", lines)

    f_sss = decode(d[("F", "DateUtil.format(#sss)")])
    lines = [
        "  // 挂进门面件：命中键就查表，区名与 pattern token 都不参与（腿 F 行）",
        eq('@date.format_in(CF_MILLIS, "#sss", "Asia/Shanghai")',
           "Some({})".format(slit(f_sss)), "读数腿",
           "F|DateUtil.format(#sss)||{}（参照那档吃机器默认区；本库区名必填而这一档**不随区变**）".format(
               d[("F", "DateUtil.format(#sss)")])),
        eq('@date.format_in(CF_MILLIS, "#sss", "UTC")',
           "Some({})".format(slit(f_sss)), "读数腿",
           "同上，换区名读数不变 ⇒ 这条就是「区名不参与」的判别夹具（F 行同一条读数）"),
        eq('@date.parse_local("1700000000", "#sss")', "Some(1700000000000L)", "读数腿",
           "GF|parse(1700000000,#sss)||1700000000000 同一条走门面"),
        '  @date.set_custom_format("mine", ms => "M" + ms.to_string())',
        leg(doc, '@date.format_local(CF_MILLIS, "mine")', d, "F", "after-put|DateUtil.format(mine)",
            wrap=lambda s: "Some({})".format(slit(s))),
        leg(doc, '@date.format_local(CF_MILLIS, "yyyy-MM-dd")', d, "F", "DateUtil.format(plain)",
            wrap=lambda s: "Some({})".format(slit(s))),
        eq('@date.is_custom_format("yyyy-MM-dd")', "false", "读数腿",
           "F|after-put|isCustom(yyyy-MM-dd)||" + d[("F", "after-put|isCustom(yyyy-MM-dd)")]),
        '  @date.reset_custom_format("mine")',
        eq('@date.is_custom_format("mine")', "false", "规则腿",
           "复位后 `mine` 不再是自定义档 ⇒ 门面件交回 §2.6 的 pattern 判据（表外 token 必抛，那条早已冻）"),
    ]
    doc.test("date #9.6.8 挂载点：命中查表、普通档不被污染、reset 后交回 pattern 判据", lines)
    doc.write("date/custom_format_test.mbt")


CF_MILLIS = 1700000000123

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print(__doc__)
        sys.exit(1)
    D = load(sys.argv[1:])
    gen_timer(D)
    gen_custom(D)
