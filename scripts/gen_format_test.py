#!/usr/bin/env python
# moon-hutool/date —— 第四批（命名时区版格式化与解析）期望值的生成器
#
# 输入 = 参照腿 TSV（腿源 scripts/FormatLeg.java）：
#   F <zone> <epoch_sec> <pid> <formatted>       全表逐区两瞬间 × pattern 0
#   G <zone> <epoch_sec> <pid> <formatted>       12 个特殊区 × 六瞬间 × 两条 pattern
#   R <zone> <epoch_sec> <rfc3339>               RFC3339 出口
#   S <zone> <wall> <pid> <epoch_millis|ERR_*>    解析读数（0 档 / 1 档 / 2 档 / 坏名）
# 纪律：期望串全部是腿读数；只有"空洞档 raise 什么、携带什么"这一条是本库决定（腿只证明参照会抛），
# 已在 spec §7.3 明写。产出后过 moon fmt。
import argparse
import io
import re
import os
import subprocess

CHUNK = 200
# 腿的 pid 列 → 本包 pattern 串（不是期望值，只是入参名对照表，与 FormatLeg.java 的 PATTERNS 同序）
PATTERNS = ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss.SSS"]


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
    f_rows, g_rows, r_rows, s_rows = [], [], [], []
    meta = {}
    for line in io.open(path, encoding="utf-8", errors="replace"):
        p = line.rstrip("\n").split("\t")
        if len(p) < 2:
            continue
        if p[0] == "B":
            meta[p[1]] = p[2]
        elif p[0] == "F" and len(p) == 5:
            f_rows.append((p[1], int(p[2]), int(p[3]), p[4]))
        elif p[0] == "G" and len(p) == 5:
            g_rows.append((p[1], int(p[2]), int(p[3]), p[4]))
        elif p[0] == "R" and len(p) == 4:
            r_rows.append((p[1], int(p[2]), p[3]))
        elif p[0] == "S" and len(p) == 5:
            s_rows.append((p[1], p[2], int(p[3]), p[4]))
    return meta, f_rows, g_rows, r_rows, s_rows


def iso_of_wall(wall):
    """把腿 S 行的墙上串折成 ISO 带毫秒串——这是本库决定携带的形状（spec §7.3 第 3 行）"""
    dpart, tpart = wall.split(" ")
    return dpart + "T" + tpart + ".000"


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
    meta, f_rows, g_rows, r_rows, s_rows = read_leg(args.leg)

    L = [
        "// moon-hutool/date 第四批（命名时区版格式化与解析）契约用例（黑盒）。**生成件，勿手改**：",
        "// 生成器 scripts/gen_format_test.py，期望串全部来自参照腿 scripts/FormatLeg.java 的机器读数。",
        "// 参照代次：JDK %s · lib/tzdb.dat %s bytes。腿自证 SELFCHK_BAD=%s"
        "（F 行另走一条独立 JDK 路径逐字符比过）。"
        % (meta.get("JAVA_VERSION"), meta.get("TZDB_DAT_BYTES"), meta.get("SELFCHK_BAD")),
        "// helper `shape` 复用 date/date_test.mbt（同包测试共享顶层命名空间）。",
        "",
    ]
    L += chunked(f_rows, "format_in 全表逐区两瞬间（腿 F 行）", lambda it: [
        "  assert_eq(@date.format_in(%dL, %s, %s), Some(%s))"
        % (it[1] * 1000, mbstr(PATTERNS[it[2]]), mbstr(it[0]), mbstr(it[3]))])
    L += chunked(g_rows, "format_in 特殊档小组（腿 G 行：45 分/30 分 DST/符号陷阱/窗口末）", lambda it: [
        "  assert_eq(@date.format_in(%dL, %s, %s), Some(%s))"
        % (it[1] * 1000, mbstr(PATTERNS[it[2]]), mbstr(it[0]), mbstr(it[3]))])

    L.append('test "@date to_rfc3339_in 偏移随瞬间走（腿 R 行；同一区两个瞬间两个偏移）" {')
    for zone, sec, text in r_rows:
        L.append("  assert_eq(@date.to_rfc3339_in(%dL, %s), Some(%s))"
                 % (sec * 1000, mbstr(zone), mbstr(text)))
    L.append("}")
    L.append("")

    L.append('test "@date parse_in：1 档正常与 2 档重叠取末支（腿 S 行的瞬间读数）" {')
    for zone, wall, pid, got in s_rows:
        if not got.isdigit():
            continue
        L.append("  // 腿 S 行：%s|%s -> %s" % (zone, wall, got))
        L.append("  assert_eq(@date.parse_in(%s, %s, %s), Some(%sL))"
                 % (mbstr(wall), mbstr(PATTERNS[pid]), mbstr(zone), got))
    L.append("}")
    L.append("")

    L.append('test "@date parse_in：0 档（该区不存在的墙上时刻）参照主动抛，本库 raise ZoneGap 不并 None" {')
    # 筛档判据：串本身形如合法墙上时刻（能被本包 pattern 吃下）而参照仍抛 ⇒ 那是"这个时刻在该区不存在"；
    # 串/pattern 本身不合法的那几条判据已由 §2.7 冻，本批不重复登记。
    shape_ok = re.compile(r"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$")
    for zone, wall, pid, got in s_rows:
        if got.isdigit() or not got.startswith("ERR_ParseException"):
            continue
        if not shape_ok.match(wall):
            continue
        L.append("  // 腿 S 行：%s|%s -> %s（参照 setLenient(false) 下主动抛）" % (zone, wall, got))
        L.append("  assert_eq(shape(() => @date.parse_in(%s, %s, %s)), %s)"
                 % (mbstr(wall), mbstr(PATTERNS[pid]), mbstr(zone),
                    mbstr("ZoneGap " + iso_of_wall(wall))))
    L.append("}")
    L.append("")

    L.append('test "@date 坏区名与窗外：三件同形给 None（参照 TimeZone 静默回落 GMT 那条不跟随）" {')
    L += [
        "  // 腿 S 行：No/Where|2024-06-01 12:00:00 参照解析成 1717243200000（= 按 GMT），本库不跟",
        "  assert_eq(@date.parse_in(\"2024-06-01 12:00:00\", \"yyyy-MM-dd HH:mm:ss\", \"No/Where\"), None)",
        "  assert_eq(@date.format_in(1717243200000L, \"yyyy-MM-dd HH:mm:ss\", \"No/Where\"), None)",
        "  assert_eq(@date.to_rfc3339_in(1717243200000L, \"No/Where\"), None)",
        "  // 窗外：窗口下界之前、上界及其之后（§5.3 第 2 条同判据）",
        "  assert_eq(@date.format_in(-1L, \"yyyy-MM-dd HH:mm:ss\", \"UTC\"), None)",
        "  assert_eq(@date.to_rfc3339_in(2524608000000L, \"UTC\"), None)",
        "  assert_eq(@date.parse_in(\"1969-12-31 23:59:59\", \"yyyy-MM-dd HH:mm:ss\", \"UTC\"), None)",
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
        with io.open(os.path.join(root, "date", "format_test.mbt"), "w",
                     encoding="utf-8", newline="\n") as fh:
            fh.write(text)
        subprocess.run(["moon", "fmt"], cwd=root, check=False)
    print("F=%d G=%d R=%d S=%d 断言=%d" % (len(f_rows), len(g_rows), len(r_rows), len(s_rows),
                                          text.count("assert_eq")))


if __name__ == "__main__":
    main()
