#!/usr/bin/env python
# moon-hutool/date —— 第四批（命名时区版格式化与解析）期望值的生成器
#
# 输入 = 参照腿 TSV（腿源 scripts/FormatLeg.java）。行形状：
#   F/G <zone> <epoch_sec> <pid> <参照串> <本库分钟粒度串>
#   R   <zone> <epoch_sec> <参照串> <本库分钟粒度串>
#   S   <zone> <wall> <pid> <epoch_millis|ERR_*> <合法偏移支数|NA>
#   X   <zone> <from> <to> <参照秒偏移> <本库分钟偏移>       非整分钟档点名
# 断言一律打"本库分钟粒度"那一栏——它同样是腿用 JDK 现渲染的读数（TimeZone 挂 GMT±分），不是本库自算；
# 两栏不同的行把参照原样留在上一行注释里，让分岔看得见（spec §7.3 第 4 行）。
# 产出后过 moon fmt；换参照代次或改窗口就整文件重生成，不手改任何一行。
import argparse
import io
import os
import subprocess

CHUNK = 200
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
    meta = {}
    f_rows, g_rows, r_rows, s_rows, x_rows = [], [], [], [], []
    known = set()
    hi = 2524608000
    for line in io.open(path, encoding="utf-8", errors="replace"):
        p = line.rstrip("\n").split("\t")
        if len(p) < 2:
            continue
        tag = p[0]
        if tag == "B":
            meta[p[1]] = p[2] if len(p) > 2 else ""
            if p[1] == "WINDOW_HI":
                hi = int(p[2])
        elif tag == "F" and len(p) == 6:
            f_rows.append((p[1], int(p[2]), int(p[3]), p[4], p[5]))
        elif tag == "G" and len(p) == 6:
            g_rows.append((p[1], int(p[2]), int(p[3]), p[4], p[5]))
        elif tag == "R" and len(p) == 5:
            r_rows.append((p[1], int(p[2]), p[3], p[4]))
        elif tag == "S" and len(p) == 6:
            s_rows.append((p[1], p[2], int(p[3]), p[4], p[5]))
        elif tag == "X" and len(p) == 6:
            x_rows.append((p[1], int(p[2]), int(p[3]), int(p[4]), int(p[5])))
    # 表内区名集：腿的 F 行覆盖全部 603 区，直接由它取；S 行按它分流，
    # 免得"参照静默回落 GMT"的那条坏名读数混进"正常档"块
    known.update(r[0] for r in f_rows)
    return meta, f_rows, g_rows, r_rows, s_rows, x_rows, hi, known


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


def render_fmt(it):
    lines = []
    if it[3] != it[4]:
        lines.append("  // 分岔（§7.3 第 4 行）：参照原样 %s；本库偏移按整分钟 ⇒ %s"
                     % (it[3], it[4]))
    lines.append("  assert_eq(@date.format_in(%dL, %s, %s), Some(%s))"
                 % (it[1] * 1000, mbstr(PATTERNS[it[2]]), mbstr(it[0]), mbstr(it[4])))
    return lines


def iso_of_wall(wall):
    dpart, tpart = wall.split(" ")
    return dpart + "T" + tpart + ".000"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--leg", required=True)
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    meta, f_rows, g_rows, r_rows, s_rows, x_rows, hi, known = read_leg(args.leg)

    L = [
        "// moon-hutool/date 第四批（命名时区版格式化与解析）契约用例（黑盒）。**生成件，勿手改**：",
        "// 生成器 scripts/gen_format_test.py；每条期望都是参照腿 scripts/FormatLeg.java 的机器读数。",
        "// 参照代次：JDK %s · lib/tzdb.dat %s bytes · 腿自证 SELFCHK_BAD=%s"
        "（F 行另走一条独立 JDK 路径逐字符比过）。"
        % (meta.get("JAVA_VERSION"), meta.get("TZDB_DAT_BYTES"), meta.get("SELFCHK_BAD")),
        "// 断言打的是腿的第二栏（本库整分钟口径：腿把 TimeZone 换成 GMT±分再渲染一次），"
        "两栏不同的行把参照原样留在上一行注释——",
        "// 窗口内非整分钟的区共 %d 个（腿 X 行点名），这条分岔的理由见 spec §7.3 第 4 行。"
        % len(x_rows),
        "// helper shape / dt / d 复用 date/date_test.mbt（同包测试共享顶层命名空间）。",
        "",
    ]
    L += chunked(f_rows, "format_in 全表逐区两瞬间（腿 F 行）", render_fmt)
    L += chunked(g_rows, "format_in 特殊档小组（腿 G 行：45 分/30 分 DST/符号陷阱/窗口末）",
                 render_fmt)

    L.append('test "@date to_rfc3339_in 偏移随瞬间走（腿 R 行；同一区两瞬间可两个偏移）" {')
    for zone, sec, ref_text, our_text in r_rows:
        if ref_text != our_text:
            L.append("  // 分岔（§7.3 第 4 行）：参照原样 %s；本库整分钟口径 ⇒ %s"
                     % (ref_text, our_text))
        L.append("  assert_eq(@date.to_rfc3339_in(%dL, %s), Some(%s))"
                 % (sec * 1000, mbstr(zone), mbstr(our_text)))
    L.append("}")
    L.append("")

    L.append('test "@date parse_in：1 档与 2 档重叠取转换后那一支（腿 S 行的瞬间读数）" {')
    for zone, wall, pid, got, why in s_rows:
        if not got.isdigit() or zone not in known:
            continue
        L.append("  // 腿 S 行：%s|%s -> %s，合法偏移支数 %s" % (zone, wall, got, why))
        L.append("  assert_eq(@date.parse_in(%s, %s, %s), Some(%sL))"
                 % (mbstr(wall), mbstr(PATTERNS[pid]), mbstr(zone), got))
    L.append("}")
    L.append("")

    L.append('test "@date parse_in：0 档（该区没有这个墙上时刻）参照主动抛，本库 raise ZoneGap" {')
    # 只登记腿标"支数=0"的行：那是真的空洞。why=NA 的几条是串/pattern 本身非法，
    # 判据已由 §2.7 冻，本批不重复登记（重复登记会把两条通道的判据混在一块）。
    for zone, wall, pid, got, why in s_rows:
        if why != "0":
            continue
        L.append("  // 腿 S 行：%s|%s -> %s，合法偏移支数 0" % (zone, wall, got))
        L.append("  assert_eq(shape(() => @date.parse_in(%s, %s, %s)), %s)"
                 % (mbstr(wall), mbstr(PATTERNS[pid]), mbstr(zone),
                    mbstr("ZoneGap " + iso_of_wall(wall))))
    L.append("}")
    L.append("")

    L.append('test "@date 坏区名与窗外：三件同形给 None（参照 TimeZone 静默回落 GMT 那条不跟随）" {')
    L += ['  // 表外区名：参照静默按 GMT 解析成功（腿 S 行给了读数），本库三件都给 None']
    for zone, wall, pid, got, why in s_rows:
        if zone in known:
            continue
        L.append("  // 腿 S 行：%s|%s -> %s（成因 %s）" % (zone, wall, got, why))
        L.append("  assert_eq(@date.parse_in(%s, %s, %s), None)"
                 % (mbstr(wall), mbstr(PATTERNS[pid]), mbstr(zone)))
        L.append("  assert_eq(@date.format_in(%sL, %s, %s), None)"
                 % (got if got.isdigit() else "0", mbstr(PATTERNS[pid]), mbstr(zone)))
        L.append("  assert_eq(@date.to_rfc3339_in(%sL, %s), None)"
                 % (got if got.isdigit() else "0", mbstr(zone)))
    L += [
        "  // 覆盖窗口之外 ⇒ None，不判成空洞（§7.3 第 3 行末句：两种空表出口必须不同）",
        '  assert_eq(@date.format_in(-1L, "yyyy-MM-dd HH:mm:ss", "UTC"), None)',
        '  assert_eq(@date.to_rfc3339_in(%dL, "UTC"), None)' % (hi * 1000),
        '  assert_eq(@date.parse_in("1969-12-31 23:59:59", "yyyy-MM-dd HH:mm:ss", "UTC"), None)',
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
    print("F=%d G=%d R=%d S=%d X=%d 断言=%d"
          % (len(f_rows), len(g_rows), len(r_rows), len(s_rows), len(x_rows),
             text.count("assert_eq")))


if __name__ == "__main__":
    main()
