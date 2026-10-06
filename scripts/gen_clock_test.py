#!/usr/bin/env python
# moon-hutool/date —— 第三批（可注入时钟源）期望值的生成器
#
# 输入 = 同一支参照腿的 TSV（scripts/TzLeg.java）。用到的行：
#   E <zone> <probe_epoch> <yyyy-MM-dd> <HH:MM:SS>   逐区日历日（date_of / today_at 的底本）
#   W <zone> <probe_epoch> <yyyy-MM-dd> <HH:MM:SS>   七区墙上时刻（now_at 的底本）
#   U <input> <TimeZone 读数> <ZoneId 读数>          坏区名在参照侧的行为
# 纪律：期望全部是腿读数，脚本不做任何日期算术；产出后过 moon fmt。
import argparse
import io
import os
import subprocess
from collections import OrderedDict

CHUNK = 200
NOW_MS = "1791216000000L"   # 2026-10-06T00:00Z，腿 E 行第二个探针


def mbstr(s):
    out = []
    for ch in s:
        o = ord(ch)
        if ch == '"':
            out.append('\\"')
        elif ch == "\\":
            out.append("\\\\")
        elif 32 <= o < 127:
            out.append(ch)
        else:
            out.append("\\u{%x}" % o)
    return '"' + "".join(out) + '"'


def read_leg(path):
    e_rows, w_rows, u_rows, hi = [], [], [], 2524608000
    with io.open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            p = line.rstrip("\n").split("\t")
            if len(p) != 5:
                continue
            if p[0] == "E":
                e_rows.append((p[1], int(p[2]), p[3], p[4]))
            elif p[0] == "W" and p[2] != "probe_epoch":
                w_rows.append((p[1], int(p[2]), p[3], p[4]))
    with io.open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            p = line.rstrip("\n").split("\t")
            if len(p) == 4 and p[0] == "U":
                u_rows.append((p[1], p[2], p[3]))
    return e_rows, w_rows, u_rows, hi


def hms_to_fields(text):
    hh, mi, ss = (int(x) for x in text.split(":"))
    return hh, mi, ss


def date_fields(text):
    y, m, d = (int(x) for x in text.split("-"))
    return y, m, d


def chunked(items, title, render):
    out = []
    n = (len(items) + CHUNK - 1) // CHUNK
    for i in range(n):
        part = items[i * CHUNK:(i + 1) * CHUNK]
        out.append('test "@date %s（第 %d/%d 块，本块 %d 条）" {' % (title, i + 1, n, len(part)))
        for it in part:
            out.extend(render(it))
        out.append("}")
        out.append("")
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--leg", required=True)
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    e_rows, w_rows, u_rows, hi = read_leg(args.leg)

    L = [
        "// moon-hutool/date 第三批（可注入时钟源）契约用例（黑盒）。**生成件，勿手改**：",
        "// 生成器 scripts/gen_clock_test.py，每条期望都是参照腿 scripts/TzLeg.java 的机器读数",
        "// （E 行=逐区日历日、W 行=七区墙上时刻、U 行=坏区名在参照侧的行为）。",
        "// helper d / dt 复用 date/date_test.mbt，ztag 复用 date/zone_test.mbt（同包测试共享顶层命名空间，",
        "// 所以本文件自己的两个 tag 助手一律加 cl_ 前缀）。",
        "",
        "///|",
        "fn cl_date_tag(d : @date.Date?) -> String {",
        "  match (d) {",
        '    None => "null"',
        "    Some(v) => v.to_iso_string()",
        "  }",
        "}",
        "",
    ]
    L += chunked(e_rows, "date_of 全表逐区日历日（腿 E 行，1970 与当下两档）", lambda it: [
        "  assert_eq(cl_date_tag(@date.date_of(%s, %dL)), %s)"
        % (mbstr(it[0]), it[1] * 1000, mbstr(it[2]))])

    L.append('test "@date now_at 用假钟取墙上时刻（腿 W 行直读）" {')
    for zone, sec, ymd, hms in w_rows:
        y, mo, d = date_fields(ymd)
        hh, mi, ss = hms_to_fields(hms)
        L.append("  assert_eq(ztag(@date.now_at(%s, @date.clock_fixed(%dL))),"
                 % (mbstr(zone), sec * 1000))
        L.append("            ztag(Some(dt(%d, %d, %d, %d, %d, %d, 0))))" % (y, mo, d, hh, mi, ss))
    L.append("}")
    L.append("")

    L.append('test "@date today_at 用假钟取日历日（腿 W 行的日期列直读）" {')
    for zone, sec, ymd, _ in w_rows:
        L.append("  assert_eq(cl_date_tag(@date.today_at(%s, @date.clock_fixed(%dL))), %s)"
                 % (mbstr(zone), sec * 1000, mbstr(ymd)))
    L.append("}")
    L.append("")

    L.append('test "@date 坏区名与窗外：五个入口同形给 None（参照侧坏名静默回落 GMT 的那条路不跟随）" {')
    for inp, tz, zid in u_rows:
        key = "" if inp == "<empty>" else inp.replace("\\t", "\t")
        L.append("  // 参照读数：%s | %s" % (tz, zid))
        L.append("  assert_eq(cl_date_tag(@date.date_of(%s, %s)), \"null\")" % (mbstr(key), NOW_MS))
        L.append("  assert_eq(ztag(@date.now_at(%s, @date.clock_fixed(%s))), \"null\")"
                 % (mbstr(key), NOW_MS))
        L.append("  assert_eq(cl_date_tag(@date.today_at(%s, @date.clock_fixed(%s))), \"null\")"
                 % (mbstr(key), NOW_MS))
    L += [
        "  // 窗外：假钟给什么就是什么，校验归查表那一步（§6.2 第 2 行）",
        "  assert_eq(cl_date_tag(@date.date_of(\"UTC\", -1L)), \"null\")",
        "  assert_eq(cl_date_tag(@date.date_of(\"UTC\", %dL)), \"null\")" % (hi * 1000),
        "  assert_eq(ztag(@date.now_at(\"UTC\", @date.clock_fixed(-1L))), \"null\")",
        "}",
        "",
    ]

    L.append('test "@date clock_fixed 是恒定的假钟：同一个钟连取两次必同值" {')
    L += [
        "  let c = @date.clock_fixed(123L)",
        "  assert_eq(c(), 123L)",
        "  assert_eq(c(), 123L)",
        "  let c2 = @date.clock_fixed(123L)",
        "  assert_eq(c2(), 123L)",
        "}",
        "",
    ]

    L.append('test "@date 同一份底本的两个入口必同读数（date_of≡today_at、now_at≡datetime_in）" {')
    for zone, sec, _ymd, _hms in e_rows[0::61]:      # 抽样：避免把 §5 的两千条再抄一遍
        L.append("  assert_eq(cl_date_tag(@date.date_of(%s, %dL)),"
                 % (mbstr(zone), sec * 1000))
        L.append("            cl_date_tag(@date.today_at(%s, @date.clock_fixed(%dL))))"
                 % (mbstr(zone), sec * 1000))
        L.append("  assert_eq(ztag(@date.datetime_in(%s, %dL))," % (mbstr(zone), sec * 1000))
        L.append("            ztag(@date.now_at(%s, @date.clock_fixed(%dL))))"
                 % (mbstr(zone), sec * 1000))
    L.append("}")
    L.append("")

    L.append('test "@date clock_system 只断形状与绝对下界，不断两次读数之间的关系（§6.4）" {')
    L += [
        "  let ms = @date.clock_system()()",
        "  assert_eq(ms > 1700000000000L, true)",
        "  // 真钟的读数必须还能查出偏移（否则等于把 OS 口子接错了地方）",
        "  assert_eq(@date.zone_offset_minutes(\"Asia/Shanghai\", ms) != None, true)",
        "  assert_eq(cl_date_tag(@date.date_of(\"Asia/Shanghai\", ms)) != \"null\", true)",
        "  // 同一次读数下，两个入口必同值；**不**拿两次不同读数互比（计时依赖）",
        "  let one = @date.clock_fixed(ms)",
        "  assert_eq(cl_date_tag(@date.today_at(\"UTC\", one)) != \"null\", true)",
        "  assert_eq(ztag(@date.now_at(\"UTC\", one)), ztag(@date.datetime_in(\"UTC\", ms)))",
        "}",
    ]

    text = "\n".join(L) + "\n"
    out = []
    for line in text.split("\n"):
        if line.startswith('test "'):
            out.append("///|")
        out.append(line)
    text = "\n".join(out) + "\n"
    if args.write:
        with io.open(os.path.join(root, "date", "clock_test.mbt"), "w",
                     encoding="utf-8", newline="\n") as fh:
            fh.write(text)
        subprocess.run(["moon", "fmt"], cwd=root, check=False)
    print("E=%d W=%d U=%d 断言行数=%d 字节=%d" % (len(e_rows), len(w_rows), len(u_rows),
                                                text.count("assert_eq"), len(text)))


if __name__ == "__main__":
    main()
