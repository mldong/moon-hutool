#!/usr/bin/env python
# moon-hutool/date —— 内置时区表与其期望值的生成器
#
# 输入 = 参照腿 TSV。腿源 scripts/TzLeg.java：
#   javac -encoding UTF-8 scripts/TzLeg.java -d <cls>
#   java -cp <cls> TzLeg > tz_leg.tsv
# 输出 = date/zone_table.mbt（数据）+ date/zone_test.mbt（期望值），随后自动过 `moon fmt`。
# 纪律：换参照代次或换窗口就整表重生成，不手改任何一行；改单条期望串会撞门禁 G5。
# 所有期望都是腿的机器读数，本脚本不做任何日期算术（墙上读数由腿的 W 行直给）。
import argparse
import io
import os
import subprocess
from collections import OrderedDict


def read_leg(path):
    meta = {}
    segs, probes, bounds, walls, unknown, instants = OrderedDict(), [], [], [], [], []
    seg_count = {}
    with io.open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            p = line.rstrip("\n").split("\t")
            if len(p) < 2:
                continue
            tag = p[0]
            if tag == "B":
                meta[p[1]] = p[2]
            elif tag == "Z" and len(p) == 4:
                seg_count[p[1]] = int(p[2])
            elif tag == "D" and len(p) == 4:
                segs.setdefault(p[1], []).append((int(p[2]), int(p[3])))
            elif tag == "P" and len(p) == 4:
                probes.append((p[1], int(p[2]), int(p[3])))
            elif tag == "T" and len(p) == 5:
                bounds.append((p[1], int(p[2]), int(p[3]), int(p[4])))
            elif tag == "W" and len(p) == 5 and p[2] != "probe_epoch":
                y, m, d = (int(x) for x in p[3].split("-"))
                hh, mi, ss = (int(x) for x in p[4].split(":"))
                instants.append((p[1], int(p[2]), y, m, d, hh, mi, ss))
            elif tag == "V" and len(p) == 5 and p[2] != "wall":
                offs = [] if p[4] == "" else [int(x) for x in p[4].split("|")]
                walls.append((p[1], p[2], int(p[3]), offs))
            elif tag == "U" and len(p) == 4:
                unknown.append((p[1], p[2], p[3]))
    # 腿的 T 行是"全部段界"的超集，直接灌进期望文件就是 7 万余条断言，太重。
    # 收录判据机械取：按 Z 行段数降序的前 10 个区，逐条段界都收（段最密的那批全在里面）。
    top = {z for z, _ in sorted(seg_count.items(), key=lambda kv: (-kv[1], kv[0]))[:10]}
    bounds = [b for b in bounds if b[0] in top]
    return meta, segs, probes, bounds, walls, unknown, instants


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


def table_text(meta, names, segs):
    start, ln, sstart, soff = [], [], [], []
    for z in names:
        start.append(len(sstart))
        for st, off in segs[z]:
            sstart.append(st)
            soff.append(off)
        ln.append(len(segs[z]))

    def ints(label, vals):
        return ["let %s : Array[Int] = [" % label] + ["  %d," % v for v in vals] + ["]"]

    L = [
        "///|",
        "// zone_table.mbt —— 内置 IANA 时区段表。**生成件，勿手改**：",
        "//   腿 scripts/TzLeg.java 出 TSV，生成器 scripts/gen_zone_table.py 灌本文件与 date/zone_test.mbt，",
        "//   生成后自动过 `moon fmt`（本仓门禁要求全树 fmt 干净）。",
        "// 参照代次：JDK %s（%s）· lib/tzdb.dat %s bytes · 窗口 [%s, %s) 秒 = [1970-01-01, 2050-01-01)。"
        % (meta.get("JAVA_VERSION"), meta.get("JAVA_VENDOR"), meta.get("TZDB_DAT_BYTES"),
           meta.get("WINDOW_LO"), meta.get("WINDOW_HI")),
        "// 表内 %s 个区、%d 段；每区首段起点=窗口下界，其后每段起点=该偏移开始生效的 epoch 秒。"
        % (meta.get("ZONES"), len(sstart)),
        "// 区名序 = **逐字节字典序**，配 date/zone.mbt 里自带的比较器；"
        "本工具链 core 的 `String.compare` 是先比长度再比内容，两者不同序（spec §5.4）。",
        "let tbl_names : Array[String] = [",
    ]
    L += ["  %s," % mbstr(z) for z in names]
    L.append("]")
    L += ints("tbl_start", start)
    L += ints("tbl_len", ln)
    L += ["let tbl_seg_start : Array[Int64] = ["] + ["  %dL," % v for v in sstart] + ["]"]
    L += ints("tbl_seg_off", soff)
    L += [
        "let tbl_window_lo : Int64 = %sL" % meta.get("WINDOW_LO"),
        "let tbl_window_hi : Int64 = %sL" % meta.get("WINDOW_HI"),
    ]
    return "\n".join(L) + "\n"


def parse_wall(text):
    dpart, tpart = text.split("T")
    y, mo, d = (int(x) for x in dpart.split("-"))
    hh, mi, ss = (int(x) for x in (tpart + ":00").split(":")[:3])
    return y, mo, d, hh, mi, ss


def test_text(meta, names, probes, bounds, walls, unknown, instants):
    hi = int(meta.get("WINDOW_HI", "0"))
    lo = int(meta.get("WINDOW_LO", "0"))
    L = [
        "///|",
        "// moon-hutool/date 内置时区表契约用例（黑盒）。**生成件，勿手改**：",
        "// 生成器 scripts/gen_zone_table.py，每条期望都是参照腿 scripts/TzLeg.java 的机器读数。",
        "// 参照代次：JDK %s · lib/tzdb.dat %s bytes · 窗口 [1970-01-01, 2050-01-01)。"
        % (meta.get("JAVA_VERSION"), meta.get("TZDB_DAT_BYTES")),
        "// 夹具构造子 `d` / `dt` 复用 date/date_test.mbt 的同名 helper（同包测试共享顶层命名空间）。",
        "// 本包 DateTime 没有 Debug 实例（assert_eq 要它就把整个类型架上去），⇒ 判等一律两侧过 ztag。",
        "",
        "///|",
        "fn ztag(o : @date.DateTime?) -> String {",
        "  match (o) {",
        '    None => "null"',
        '    Some(v) => v.to_iso_string()',
        "  }",
        "}",
        "",
    ]
    CHUNK = 200

    def chunks(items, title, render):
        # 一个 test 块塞几千条断言会撞 text_segment_excceed（段太长），按 CHUNK 条切块
        n = (len(items) + CHUNK - 1) // CHUNK
        for i in range(n):
            part = items[i * CHUNK:(i + 1) * CHUNK]
            L.append('test "@date %s（第 %d/%d 块，本块 %d 条）" {'
                     % (title, i + 1, n, len(part)))
            for it in part:
                L.extend(render(it))
            L.append("}")
            L.append("")

    chunks(probes, "内置表逐区六瞬间偏移（腿 P 行全量）", lambda it: [
        "  assert_eq(@date.zone_offset_minutes(%s, %dL), Some(%d))"
        % (mbstr(it[0]), it[1] * 1000, it[2])])
    chunks(bounds, "段界两侧各差一段（腿 T 行，段数最多的前 10 区）", lambda it: [
        "  assert_eq(@date.zone_offset_minutes(%s, %dL), Some(%d))"
        % (mbstr(it[0]), (it[1] - 1) * 1000, it[2]),
        "  assert_eq(@date.zone_offset_minutes(%s, %dL), Some(%d))"
        % (mbstr(it[0]), it[1] * 1000, it[3])])
    L += [
        'test "@date 墙上时刻的合法偏移：0 档（前跳空洞）/ 1 档 / 2 档（回拨重叠），顺序照腿 V 行" {']
    for zone, wall, n, offs in walls:
        y, mo, d, hh, mi, ss = parse_wall(wall)
        L.append("  // 腿 V 行：%s|%s -> n=%d %s" % (zone, wall, n, "|".join(str(o) for o in offs)))
        L.append("  assert_eq(@date.zone_offsets_at_wall(%s, dt(%d, %d, %d, %d, %d, %d, 0)), [%s])"
                 % (mbstr(zone), y, mo, d, hh, mi, ss, ", ".join(str(o) for o in offs)))
    L += ["}", "",
          'test "@date datetime_in：瞬间 + 区名 = 墙上时刻（腿 W 行直读，含 45 分偏移与 30 分夏令时档）" {']
    for zone, sec, y, mo, d, hh, mi, ss in instants:
        L.append("  assert_eq(ztag(@date.datetime_in(%s, %dL)),"
                 % (mbstr(zone), sec * 1000))
        L.append("            ztag(Some(dt(%d, %d, %d, %d, %d, %d, 0))))"
                 % (y, mo, d, hh, mi, ss))
    L += ["}", "",
          'test "@date 认不出的区名：本库给 None / false；参照侧 TimeZone 静默回落 GMT（分岔见 spec §5.3）" {']
    for inp, tz, zid in unknown:
        key = "" if inp == "<empty>" else inp.replace("\\t", "\t")
        L.append("  // 参照读数：%s | %s" % (tz, zid))
        L.append("  assert_eq(@date.zone_offset_minutes(%s, %dL), None)" % (mbstr(key), hi * 1000 - 1))
        L.append("  assert_eq(@date.zone_exists(%s), false)" % mbstr(key))
        L.append("  assert_eq(ztag(@date.datetime_in(%s, %dL)), \"null\")" % (mbstr(key), hi * 1000 - 1))
        L.append("  assert_eq(@date.zone_offsets_at_wall(%s, dt(2024, 6, 1, 12, 0, 0, 0)), [])"
                 % mbstr(key))
    L += ["}", "",
          'test "@date 窗口边界：下界含、上界不含，窗外一律 None（不向外推）" {']
    L.append("  // 腿 D 行首段：Asia/Shanghai|%d -> 480 / UTC|%d -> 0" % (lo, hi - 1))
    L.append("  assert_eq(@date.zone_offset_minutes(\"Asia/Shanghai\", %dL), Some(480))" % (lo * 1000))
    L.append("  assert_eq(@date.zone_offset_minutes(\"Asia/Shanghai\", %dL), None)" % (lo * 1000 - 1))
    L.append("  assert_eq(@date.zone_offset_minutes(\"Asia/Shanghai\", %dL), None)" % (hi * 1000))
    L.append("  assert_eq(@date.zone_offset_minutes(\"UTC\", %dL), Some(0))" % (hi * 1000 - 1))
    L += ["}", "",
          'test "@date 区名清单：条数与首尾读数照腿，且返回的是拷贝（改它不影响后续查表）" {']
    for i in (0, 1, 2):
        L.append("  assert_eq(@date.zone_names()[%d], %s)" % (i, mbstr(names[i])))
    for i in (len(names) - 3, len(names) - 2, len(names) - 1):
        L.append("  assert_eq(@date.zone_names()[%d], %s)" % (i, mbstr(names[i])))
    L += [
        "  assert_eq(@date.zone_names().length(), %s)" % meta.get("ZONES"),
        "  assert_eq(@date.zone_count(), %s)" % meta.get("ZONES"),
        "  let dirty = @date.zone_names()",
        "  dirty[0] = %s" % mbstr("Poisoned/Name"),
        "  assert_eq(@date.zone_names()[0], %s)" % mbstr(names[0]),
        "  assert_eq(@date.zone_exists(%s), true)" % mbstr(names[0]),
        "  // 表序判据不靠这一条单独撑：上面「逐区六瞬间」把 %s 个区各查了 6 次，" % meta.get("ZONES"),
        "  // 表序与自带比较器一旦不同序，二分必对某个区给 None，那一整块当场报红。",
        "  assert_eq(@date.zone_exists(%s), true)" % mbstr(names[len(names) // 2]),
    ]
    L += ["}", "",
          'test "@date now_in：同一次时钟读数的等价式 + 形状下界，两次读时钟的抖动不进断言（口径同 #2.10）" {',
          "  let ms = @date.now_millis()",
          "  // 腿 P 行：Asia/Shanghai 在窗口内任一时刻的偏移里，当下这一档是 480",
          "  assert_eq(ztag(@date.datetime_in(\"Asia/Shanghai\", ms)),",
          "            ztag(Some(@date.DateTime::from_epoch_millis(ms, 480))))",
          "  assert_eq(ztag(@date.now_in(\"Nowhere/Nowhere\")), \"null\")",
          "  match (@date.now_in(\"Asia/Shanghai\")) {",
          "    None => assert_eq(0, 1)",
          "    Some(dt2) => {",
          "      assert_eq(dt2.date.year >= 2026, true)",
          "      assert_eq(dt2.hour >= 0 && dt2.hour <= 23, true)",
          "      assert_eq(dt2.minute >= 0 && dt2.minute <= 59, true)",
          "    }",
          "  }",
          "}",
          ]
    return "\n".join(L) + "\n"


def with_markers(text):
    # 每个 test 块前插一行 ///|：不分段会撞 text_segment_excceed 警告，G1 的零警告判据就红
    out = []
    for line in text.split("\n"):
        if line.startswith('test "'):
            out.append("///|")
        out.append(line)
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--leg", required=True)
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    meta, segs, probes, bounds, walls, unknown, instants = read_leg(args.leg)
    names = sorted(segs.keys())
    for z in names:
        segs[z].sort(key=lambda x: x[0])
    if args.write:
        with io.open(os.path.join(root, "date", "zone_table.mbt"), "w",
                     encoding="utf-8", newline="\n") as fh:
            fh.write(table_text(meta, names, segs))
        with io.open(os.path.join(root, "date", "zone_test.mbt"), "w",
                     encoding="utf-8", newline="\n") as fh:
            fh.write(with_markers(test_text(meta, names, probes, bounds, walls, unknown, instants)))
        subprocess.run(["moon", "fmt"], cwd=root, check=False)
    print("zones=%s rows=%d probes=%d bounds=%d walls=%d unknown=%d instants=%d"
          % (meta.get("ZONES"), sum(len(v) for v in segs.values()), len(probes),
             len(bounds), len(walls), len(unknown), len(instants)))


if __name__ == "__main__":
    main()
