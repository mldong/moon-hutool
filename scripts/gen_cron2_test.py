#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""cron 第二批期望值生成器（腿 C → `cron/part_builder_test.mbt` + `cron/zone_util_test.mbt`）。

规矩与前面每一批一样：**期望值只从参照腿的读数行取，手打零条**。
只有三类例外，全部集中在下面的表里，每格都必须写清"依据是 spec 的哪一行"，
且**参照那一侧的原读数一律留在注释里**（两侧读数都在案，这是本包 §5 第 5 行立下的规矩）：

1. `year_only_no_second` —— 参照 build 出的串它自家解析器收不了（`RT` 行为凭），本库补秒；
2. `count <= 0` —— 参照 `count=0` 给 1 条、`count=-1` 抛 Java 容器内部件，本库一律空表；
3. **窗外** —— 内置时区表只承诺 `[1970-01-01, 2050-01-01)`（`date` §5），参照在 2099/2104
   这类输入上照样给值，本库给 `None`。

还有一类**故意不进夹具**：`feb30`（`0 0 0 30 2 *`，解析通过但无解）在参照侧是
`StackOverflowError`（腿 C 的 50 条读数），本库跟随的那台引擎同样无界——把一条会挂住的
用例塞进套件等于把整套件判死，抓不到任何东西。计数写在文件头，判据见 spec §11 第 5 行。

用法：python scripts/gen_cron2_test.py <cron2_leg.tsv>
"""
import io
import os
import re
import subprocess
import sys

WINDOW_LO = 0                 # 1970-01-01T00:00:00Z
WINDOW_HI = 2524608000000     # 2050-01-01T00:00:00Z（date §5 的表窗上界）
CHUNK = 180                   # 单个 test 块的断言上限（core 的 text_segment_excceed 在 200 上下）

VARIANT = {
    "SECOND": "Second", "MINUTE": "Minute", "HOUR": "Hour",
    "DAY_OF_MONTH": "DayOfMonth", "MONTH": "Month",
    "DAY_OF_WEEK": "DayOfWeek", "YEAR": "Year",
}

# 建造器每一格的配方：腿名 → MoonBit 侧构造式。**夹具构造是手写的，期望值不是**；
# 每一条都必须与 scripts/Cron2Leg.java 的 bcases 里同一条逐项对应。
NEW = "@cron.cron_builder_new()"
RECIPES = {
    "empty": NEW,
    "minute_only": "set(%s, Minute, \"*/5\")" % NEW,
    "values_hour": "set_values(%s, Hour, [1, 2, 3])" % NEW,
    "range_dom": "set_range(%s, DayOfMonth, 1, 15)" % NEW,
    "second_set": "set(%s, Second, \"30\")" % NEW,
    "year_only_no_second": "set(%s, Year, \"2030\")" % NEW,
    "second_and_year": "set(set(%s, Second, \"0\"), Year, \"2030\")" % NEW,
    "blank_minute": "set(%s, Minute, \"\")" % NEW,
    "space_minute": "set(%s, Minute, \"  \")" % NEW,
    "range_reversed": "set_range(%s, DayOfMonth, 20, 5)" % NEW,
    "values_with_second": "set_values(set(%s, Second, \"0\"), Minute, [0, 30])" % NEW,
    "values_empty": "set_values(%s, Minute, [])" % NEW,
    "values_empty_second": "set_values(%s, Second, [])" % NEW,
    "values_empty_year": "set_values(%s, Year, [])" % NEW,
    # 秒/年这两档"设成空白"与"从未设置"在参照里是两回事（IGNORE 只认 null），
    # 本库只有 String 没有 null ⇒ 空白这一档必须单独读、单独钉
    "blank_second": "set(%s, Second, \"\")" % NEW,
    "space_year": "set(%s, Year, \" \")" % NEW,
    "blank_second_with_year": "set(set(%s, Second, \"\"), Year, \"2030\")" % NEW,
    "dow_seven": "set(%s, DayOfWeek, \"7\")" % NEW,
    "junk_minute": "set(%s, Minute, \"abc\")" % NEW,
    "values_out_of_range": "set_values(%s, Hour, [25])" % NEW,
    "range_out_of_range": "set_range(%s, Minute, -1, 5)" % NEW,
    "second_out_of_range": "set_values(%s, Second, [60])" % NEW,
}
# 配方里的 set/set_values/set_range 在生成时展开成带 @cron. 前缀与 CronPart:: 限定的实调用
EXPAND = {
    "set": "@cron.cron_builder_set",
    "set_values": "@cron.cron_builder_set_values",
    "set_range": "@cron.cron_builder_set_range",
}

# 本库形状产不出这条读数的格（不是漏挂，是类型上没有这一档）
UNFIXTURED_CASES = {
    "null_minute": "参照的 `set(part, null)` 在本库没有对应形状——未设置就是未设置，没有第二种",
}

# 本库改判格：(期望串, 依据, 参照原读数的说明)
DECISION_BUILDER = {
    "year_only_no_second": (
        "* * * * * * 2030",
        "spec §11 第 1 行",
    ),
    # 同一格的第二个读数：秒设成空白而非未设置。参照照样产出自家解析器收不了的串，
    # 本库的补秒规则按"秒这一格给不出可用文本"来判，两种形状同归一处
    "blank_second_with_year": (
        "* * * * * * 2030",
        "spec §11 第 1 行（秒设成空白也算没给）",
    ),
}

OUT_RANGE = re.compile(r"^([A-Z_]+) value (-?\d+) out of range")
REF_MESSAGES = [
    # (正则, 模板) —— 参照的文案 → 本库错误面的档；认不出的一律 SystemExit，
    # 宁可让生成器停住也不许把 Java 文案原样当期望抄进去（第一批就栽在"把异常串当读数"上）
    (re.compile(r"^([A-Z_]+) value (-?\d+) out of range"), "OutOfRange[%s,%s]"),
    (re.compile(r"^Invalid alias value: \[(.*)\]"), "BadAlias[%s]"),
    (re.compile(r"^No enum constant .*\.([^.]*)$"), "BadAlias[%s]"),
    (re.compile(r"^Pattern \[(.*)\] is invalid"), "BadParts[%s]"),
]


def ref_message(read):
    """腿里的 `CronException|<文案>` / `IllegalArgumentException|<文案>` → 本库那一档的读数串"""
    body = read.split("|", 1)[1] if "|" in read else read
    for rx, tpl in REF_MESSAGES:
        m = rx.match(body)
        if m:
            return tpl % m.groups()
    raise SystemExit("参照文案认不出来，不猜：%r" % read)


def root():
    return subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                          text=True).stdout.strip()


def mb(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def ms(v):
    return "%dL" % int(v)


def in_window(v):
    return WINDOW_LO <= int(v) < WINDOW_HI


def expand(recipe):
    out = recipe
    for k, v in EXPAND.items():
        out = re.sub(r"\b%s\(" % k, v + "(", out)
    return re.sub(r"\b(Second|Minute|Hour|DayOfMonth|Month|DayOfWeek|Year)\b",
                  r"@cron.CronPart::\1", out)


def of_range(read):
    """腿的 `...|HOUR value 25 out of range: [0 , 23]` → 本库档位读数 `OutOfRange[HOUR,25]`"""
    body = read.split("|", 1)[1] if "|" in read else read
    m = OUT_RANGE.match(body)
    if not m:
        raise SystemExit("认不出的越界文案：%r" % read)
    return "OutOfRange[%s,%s]" % (m.group(1), m.group(2))


def blocks(lines, title_fmt):
    """把断言行切成若干 test 块（单块过大会撞 core 的 text_segment_excceed）。

    `title_fmt` 收两个 `%d`：块号（从 1 起）与该块断言数，末尾自带 `{"`，形如
    `test "..." {`。
    """
    out = []
    for n, i in enumerate(range(0, len(lines), CHUNK), start=1):
        part = lines[i:i + CHUNK]
        if n > 1:
            out.append("///|")
        out.append(title_fmt % (n, len(part)))
        out.extend(part)
        out.append("}")
        out.append("")
    if not lines:
        out.append("// （这一族没有可钉的格）")
        out.append("")
    return out


def main():
    rows = []
    for line in io.open(sys.argv[1], encoding="utf-8").read().splitlines():
        if line.strip():
            rows.append(line.split("\t"))
    by = {}
    for r in rows:
        by.setdefault(r[0], []).append(r)
    for k in ("P", "C", "K", "RT", "CB", "M", "N", "N2", "E", "D3", "O", "B", "T"):
        if k not in by:
            raise SystemExit("腿里缺 %s 行——先复跑 scripts/Cron2Leg.java" % k)
    meta = dict((r[1], r[2]) for r in by["T"])
    guard = dict((r[1], r[2]) for r in by["B"])
    if guard.get("GUARD_DISTINCT") != "true":
        raise SystemExit("腿的守卫自检不成立（%s）——三档出口混了，读数不可信" % guard)

    head = [
        "///|",
        "// moon-hutool/cron 第二批契约用例（黑盒）。**生成件，勿手改**：",
        "// 生成器 scripts/gen_cron2_test.py，每条期望都是参照腿 scripts/Cron2Leg.java 的机器读数。",
        "// 参照代次：JDK %s · hutool-cron+core %s · lib/tzdb.dat %s bytes · 腿的守卫自检 %s=%s。"
        % (meta["JAVA"], "5.8.35", meta["TZDB_DAT_BYTES"], "GUARD_DISTINCT",
           guard["GUARD_DISTINCT"]),
        "// 三处本库改判（设年未设秒 / `count <= 0` / 窗外）集中在生成器的 DECISION_BUILDER 与两处分支里，"
        "每格都注了依据的 spec 行号与参照原读数（spec §11）。",
        "// helper `tag` / `parse_text` 复用 cron/cron_test.mbt 的同名件（同包测试共享顶层命名空间）。",
        "",
    ]

    # ======================= 文件一：段枚举 + 建造器 =======================
    A = []
    A += [
        "///|",
        "// 建造器每一格的配方（与 scripts/Cron2Leg.java 的 bcases 逐项对应）。"
        "参照的校验期点在 setter 那一格，`build()` 自己不抛（spec §9 第 4 条）。",
        "fn pb_case(name : String) -> @cron.CronBuilder raise @cron.CronError {",
        "  match name {",
    ]
    for k, v in RECIPES.items():
        A.append("    %s => %s" % (mb(k), expand(v)))
    A += ["    _ => abort(\"配方表漏格（必须与腿的 bcases 同清单）：\" + name)", "  }", "}", ""]
    A += [
        "///|",
        "// #19.16 的读数：`OK:<build 出的串>` 或 `ERR:<本库错误档>`",
        "fn pb_tag(name : String) -> String {",
        "  try {",
        "    \"OK:\" + @cron.cron_builder_build(pb_case(name))",
        "  } catch {",
        "    e => \"ERR:\" + tag(e)",
        "  }",
        "}",
        "",
        "///|",
        "// 回环读数：把 build 的串喂回 #19.1（参照的 `RT` 行走的就是这条路）",
        "fn pb_round_tag(name : String) -> String {",
        "  try {",
        "    parse_text(@cron.cron_builder_build(pb_case(name)))",
        "  } catch {",
        "    e => \"ERR:\" + tag(e)",
        "  }",
        "}",
        "",
        "///|",
        "// #19.10 的读数：`RET:<原值>` 或 `ERR:<本库错误档>`",
        "fn cv_tag(p : @cron.CronPart, v : Int) -> String {",
        "  try {",
        "    \"RET:\" + @cron.cron_part_check_value(p, v).to_string()",
        "  } catch {",
        "    e => \"ERR:\" + tag(e)",
        "  }",
        "}",
        "",
    ]

    p = []
    for r in by["P"]:
        _, part, _ord, lo, hi = r
        ctor = "(@cron.CronPart::%s)" % VARIANT[part]
        p.append("  assert_eq(@cron.cron_part_name%s, %s) // 腿 C P.%s 段名列" % (ctor, mb(part), part))
        p.append("  assert_eq(@cron.cron_part_min%s, %s) // 腿 C P.%s min 列" % (ctor, lo, part))
        p.append("  assert_eq(@cron.cron_part_max%s, %s) // 腿 C P.%s max 列" % (ctor, hi, part))
    A += blocks(p, "test \"@cron2 七段的段名与界（腿 C 的 P 行，第 %d 块 %d 条）\" {")

    seen, crows = set(), []
    for r in by["C"]:
        _, part, val, kind, read = r
        if (part, val) in seen:
            continue
        seen.add((part, val))
        crows.append(r)
    p = []
    for r in crows:
        _, part, val, kind, read = r
        if kind == "RET":
            want, note = "RET:%s" % read, "腿 C C.%s.%s RET ⇒ 判而不变，原样返回" % (part, val)
        else:
            want, note = "ERR:" + of_range(read), "腿 C C.%s.%s ERR|%s" % (part, val, read)
        p.append("  assert_eq(cv_tag(@cron.CronPart::%s, %s), %s) // %s"
                 % (VARIANT[part], val, mb(want), note))
    A += blocks(p, "test \"@cron2 单值校验判而不变（腿 C 的 C 行去重后，第 %d 块 %d 条）\" {")

    kmap = dict((r[1], r) for r in by["K"])
    p, unp = [], []
    for r in by["K"]:
        _, case, kind, read = r
        if case in UNFIXTURED_CASES:
            unp.append("// K.%s 不进夹具：%s；参照原读数 RET|%s 在案" % (case, UNFIXTURED_CASES[case], read))
            continue
        dec = DECISION_BUILDER.get(case)
        if kind == "RET":
            want = "OK:" + (dec[0] if dec else read)
            note = ("%s ⇒ 本库补秒成 7 段；参照原读数 K.%s RET|%s 在案" % (dec[1], case, read)) if dec \
                else "腿 C K.%s RET|%s" % (case, read)
        else:
            want, note = "ERR:" + ref_message(read), "腿 C K.%s %s ⇒ 参照在 setter 那一格就抛" % (case, read)
        p.append("  assert_eq(pb_tag(%s), %s) // %s" % (mb(case), mb(want), note))
    for r in by["RT"]:
        _, case, kind, read = r
        if case in UNFIXTURED_CASES:
            continue
        if read == "ERR_NoBuild":
            p.append("  // RT.%s：参照没走到 build（setter 就抛）⇒ 上一条 pb_tag 已钉同一件事" % case)
            continue
        dec = DECISION_BUILDER.get(case)
        if kind == "RET":
            want, note = "OK:" + read, "腿 C RT.%s RET|%s" % (case, read)
        elif dec:
            want, note = "OK:" + dec[0], "%s ⇒ 本库这一格的串可解析；参照原读数 RT.%s ERR|%s 在案" % (
                dec[1], case, read)
        else:
            # 参照的 build 串在它自家解析器那里就报错（junk_minute 那一格）：
            # 本库**照留**这条判据——建造器不校验文本，坏文本到解析期才报（spec §9 第 3 条）
            want, note = ref_message(read), "腿 C RT.%s ERR|%s ⇒ 本库同档" % (case, read)
        p.append("  assert_eq(pb_round_tag(%s), %s) // %s" % (mb(case), mb(want), note))
    A += ["// 不进夹具的格（本库形状产不出这条读数，不是漏挂）："] + unp if unp else []
    A += [""] if unp else []
    A += blocks(p, "test \"@cron2 建造器的 build 串与回环（腿 C 的 K/RT 行，第 %d 块 %d 条）\" {")

    p = []
    for r in by["O"]:
        _, i, part, cf = r
        if part == "ERR":
            p.append("  // 腿 C O.%s：%s ⇒ 参照 `Part.of(%s)` 越界抛的是 %s，本库不导出这件（spec §8）"
                     % (i, cf, i, cf))
        else:
            p.append("  assert_eq(@cron.cron_part_name(@cron.CronPart::%s), %s) // 腿 C O.%s：段序 %s=%s；"
                     "字段号 %s 是 Calendar 的邻居物，不收" % (VARIANT[part], mb(part), i, i, part, cf))
    A += blocks(p, "test \"@cron2 参照段序留案（腿 C 的 O 行，第 %d 块 %d 条）\" {")

    f1 = os.path.join(root(), "cron", "part_builder_test.mbt")
    io.open(f1, "w", encoding="utf-8", newline="\n").write("\n".join(head + A) + "\n")

    # ======================= 文件二：带区名的三个入口 =======================
    B = list(head)
    B += [
        "///|",
        "// #19.19 的读数：`[毫秒|毫秒|…]`；坏区名/窗外 `null`；抛错 `ERR:<档>`",
        "fn md_tag(pat : String, zone : String, st : Int64, en : Int64, n : Int, sec : Bool) -> String {",
        "  try {",
        "    match @cron.cron_matched_dates(@cron.cron_of(pat), zone, st, en, n, sec) {",
        "      None => \"null\"",
        "      Some(v) => {",
        "        let parts = v.map(x => x.to_string())",
        "        if parts.length() == 0 { \"[]\" } else { \"[\" + parts.join(\"|\") + \"]\" }",
        "      }",
        "    }",
        "  } catch {",
        "    e => \"ERR:\" + tag(e)",
        "  }",
        "}",
        "",
        "///|",
        "// 只钉长度的一族格（腿 C 的 CB 行给的就是 size）",
        "fn md_len_tag(pat : String, zone : String, st : Int64, en : Int64, n : Int) -> String {",
        "  try {",
        "    match @cron.cron_matched_dates(@cron.cron_of(pat), zone, st, en, n, false) {",
        "      None => \"null\"",
        "      Some(v) => v.length().to_string()",
        "    }",
        "  } catch {",
        "    e => \"ERR:\" + tag(e)",
        "  }",
        "}",
        "",
        "///|",
        "// #19.17 的读数：`<毫秒>` / `null`",
        "fn znx_tag(pat : String, zone : String, b : Int64) -> String {",
        "  try {",
        "    match @cron.cron_next_match_after_in(@cron.cron_of(pat), zone, b) {",
        "      None => \"null\"",
        "      Some(v) => v.to_string()",
        "    }",
        "  } catch {",
        "    e => \"ERR:\" + tag(e)",
        "  }",
        "}",
        "",
        "///|",
        "// #19.18 的读数，形状同 znx_tag（两族成对，spec §9 第 15 条）",
        "fn znm_tag(pat : String, zone : String, b : Int64) -> String {",
        "  try {",
        "    match @cron.cron_next_match_in(@cron.cron_of(pat), zone, b) {",
        "      None => \"null\"",
        "      Some(v) => v.to_string()",
        "    }",
        "  } catch {",
        "    e => \"ERR:\" + tag(e)",
        "  }",
        "}",
        "",
    ]

    skipped = []
    for fn_, rows_of, kind in (("znx_tag", by["N"], "严格晚于"),
                               ("znm_tag", by["N2"], "已匹配给自身/末支")):
        p = []
        for r in rows_of:
            _, case, pat, base, zone, got, iso = r
            label = "腿 C %s.%s.%s.%s" % (r[0], case, base, zone)
            if not in_window(base):
                p.append("  assert_eq(%s(%s, %s, %s), \"null\") // %s ⇒ 基准已出表窗，本库不外推"
                         "（参照原读数 %s｜UTC %s，spec §11 第 4 行）"
                         % (fn_, mb(pat), mb(zone), ms(base), label, got, iso))
                continue
            if got.startswith("ERR_"):
                skipped.append((label, got))
                continue
            if not in_window(got):
                # 基准在窗内、落点在窗外 ⇒ 本库给 None（spec §11 第 4 行：内置表只承诺
                # [1970, 2050)，不外推）。参照那一侧照样给值，原读数留在注释里
                p.append("  assert_eq(%s(%s, %s, %s), \"null\") // %s ⇒ 落点出表窗，本库不外推"
                         "（参照原读数 %s｜UTC %s，spec §11 第 4 行）"
                         % (fn_, mb(pat), mb(zone), ms(base), label, got, iso))
                continue
            p.append("  assert_eq(%s(%s, %s, %s), %s) // %s|参照读数 %s（UTC 串 %s）"
                     % (fn_, mb(pat), mb(zone), ms(base), mb(got), label, got, iso))
        B += blocks(p, "test \"@cron2 带区名的下一瞬间（腿 C %s 行，%s，第 %%d 块 %%d 条）\" {"
                    % (fn_, kind))

        # 每族各补一条"无解模式"的说明行：不进夹具的格数与原因
    B.append("///|")
    B.append("// 本文件故意不进夹具 %d 格，全部是 `feb30`（`0 0 0 30 2 *`，解析通过但无解）："
             % len(skipped))
    if skipped:
        B.append("// 参照读数一律 %s，本库跟随的那台引擎同样无界——" % skipped[0][1])
        B.append("// 一条会挂住的用例塞进套件等于把整套件判死，抓不到任何东西。判据见 spec §11 第 5 行。")
    B.append("")

    p = []
    for r in by["M"]:
        _, case, pat, sec, count, zone, isos, millis, start, end = r
        label = "腿 C M.%s.%s.%s" % (case, sec, zone)
        secb = "true" if sec == "SEC" else "false"
        if not (in_window(start) and in_window(end)):
            p.append("  assert_eq(md_tag(%s, %s, %s, %s, %s, %s), \"null\") // %s ⇒ 窗口与本库表窗不齐"
                     "（参照原读数 %s）" % (mb(pat), mb(zone), ms(start), ms(end), count, secb, label, millis))
            continue
        if int(count) <= 0:
            p.append("  assert_eq(md_tag(%s, %s, %s, %s, %s, %s), \"[]\") // count<=0 ⇒ 空表（spec §11 第 2 行）；"
                     "参照原读数 %s.count=%s|%s" % (mb(pat), mb(zone), ms(start), ms(end), count, secb, label, count, millis))
            continue
        if millis.startswith("ERR_"):
            p.append("  // %s 不进夹具：参照读数 %s" % (label, millis))
            continue
        # 结果串是 `md_tag` 渲染出来的**十进制文本**（`x.to_string()` 不带 `L` 后缀），
        # 这里拼的必须同样是裸数字——把 MoonBit 的字面量后缀拼进期望串是一条假红（本轮实跑抓到）
        want = ("[]" if millis == "<none>"
                else "[" + "|".join(str(int(x)) for x in millis.split("|")) + "]")
        p.append("  assert_eq(md_tag(%s, %s, %s, %s, %s, %s), %s) // %s|参照 UTC 串 %s"
                 % (mb(pat), mb(zone), ms(start), ms(end), count, secb, mb(want), label, isos))
    B += blocks(p, "test \"@cron2 带区名的一批命中瞬间（腿 C 的 M 行，第 %d 块 %d 条）\" {")

    p = []
    for r in by["CB"]:
        _, pat, count, kind, read, start, end, zone = r
        if int(count) <= 0:
            want = "0"
            note = "count<=0 ⇒ 空表（spec §11 第 2 行）；参照原读数 CB.count=%s %s|%s" % (count, kind, read)
        elif kind == "RET":
            want, note = read, "腿 C CB.count=%s ⇒ 参照给 %s 条" % (count, read)
        else:
            p.append("  // CB.count=%s 不进夹具：参照读数 %s" % (count, read))
            continue
        p.append("  assert_eq(md_len_tag(%s, %s, %s, %s, %s), %s) // %s"
                 % (mb(pat), mb(zone), ms(start), ms(end), count, mb(want), note))
    for r in by["E"]:
        _, case, kind, read, start, end, pat, zone = r
        p.append("  assert_eq(md_tag(%s, %s, %s, %s, 3, false), %s) // 腿 C E.%s|%s ⇒ 本库留变体 BadRange（spec §11 第 7 行）"
                 % (mb(pat), mb(zone), ms(start), ms(end), mb("ERR:BadRange[%s,%s]" % (start, end)), case, read))
    B += blocks(p, "test \"@cron2 count 边界与窗口判据（腿 C 的 CB/E 行，第 %d 块 %d 条）\" {")

    p = []
    for r in by["D3"]:
        _, pat, base, two, three = r
        p.append("  assert_eq(%s, %s) // 腿 C D3.%s.%s ⇒ 二参与三参逐字节同值，那个布尔确实是死的（spec §8\"不收\"表）"
                 % (mb(two), mb(three), pat, base))
    B += blocks(p, "test \"@cron2 参照的废弃三参与二参同值（腿 C 的 D3 行留案，第 %d 块 %d 条）\" {")

    f2 = os.path.join(root(), "cron", "zone_util_test.mbt")
    io.open(f2, "w", encoding="utf-8", newline="\n").write("\n".join(B) + "\n")

    def stat(path, lines):
        a = sum(1 for x in lines if x.strip().startswith("assert_eq"))
        t = sum(1 for x in lines if x.startswith("test "))
        print("写了 %s：%d 行 / 断言 %d / test 块 %d" % (path, len(lines), a, t))
        return a, t

    a1, t1 = stat(f1, head + A)
    a2, t2 = stat(f2, B)
    print("合计：断言 %d，test 块 %d；故意不进夹具 %d 格（全是 feb30）" % (a1 + a2, t1 + t2, len(skipped)))


if __name__ == "__main__":
    main()
