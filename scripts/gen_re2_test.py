# moon-hutool/re —— 第二批（RegexPool 常量表）的生成器
#
# 一个来源、三条出口，任何一条都不许手打字符串：
#   --test   re/preset_test.mbt    PR-A 的冻结期望（改写串 + 每条常量的两档判定读数）
#   --table  re/preset_table.mbt   PR-B 的数据表（每档的参照名与本库方言改写串）
#   --probe  re/probeN_test.mbt    临时对撞探针（跑完就删，**不进提交**）
#
# 输入只有两样：
#   1) 参照腿 `scripts/RePoolLeg.java` 的读数文件——R=原文、P=旗标、M=matches()、
#      F=find() 的第 0 组、X=单参 get 与带旗标常量的分岔、G=getFirstNumber 的出口形状、
#      J=类外裸 `]` 的两侧同判（规则 R7 的依据）；
#   2) 改写规则表 `scripts/re_preset_rewrite.py`（R1~R7，封闭规则，每条都带"两侧同一集合"的论证）。
#
# 期望值与数据表走同一条推导路径不是巧合，是这一批的**定义**：常量表就是那张表。
# 这张表对不对，判据在腿那一侧——每条常量的 M/F 读数逐条来自参照实现（spec §10）。
import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from re_preset_rewrite import join_pairs, leg_unesc, mb_lit, verdicts  # noqa: E402

NL = chr(10)


def pascal(name):
    """参照常量名 → 本库枚举档名（机械规则：按 `_` 切词，首字母大写、其余小写）。
    `IPV4`→`Ipv4`、`UUID_SIMPLE`→`UuidSimple`、`CHINESES`→`Chineses`（尾缀 S 是参照自己的命名：
    单字档 CHINESE / 一个或多个档 CHINESES）。"""
    return "".join(w[:1].upper() + w[1:].lower() for w in name.split("_") if w)


def leg_rows(path):
    """腿 TSV → (G 行的键值表, M/F 行的逐条读数)。"""
    meta = {}
    reads = {}
    for line in io.open(path, encoding="utf-8"):
        f = line.rstrip("\r\n").split("\t")
        if f[0] == "G" and len(f) == 3:
            meta[f[1]] = f[2]
        elif f[0] in ("M", "F") and len(f) == 4:
            reads.setdefault(f[1], []).append((f[0], f[2], f[3]))
        elif f[0] in ("M", "F"):
            raise SystemExit("腿的 M/F 行字段数不对（样本里出现了制表符）：%r" % line)
    return meta, reads


def build(path):
    """→ (收录清单, G 行读数)。清单 = [(参照名, 枚举档名, 改写串, 规则号, [(档, 样本, 读数)])]，
    顺序＝腿 R 行的声明序（＝参照 RegexPool 的字段序）。"""
    meta, reads = leg_rows(path)
    out = []
    for name, verdict, txt, notes, _raw in verdicts(path):
        if verdict != "OK":
            # EXCLUDED＝owner 点名的业务码表族（归 typex 的码表件管）；REJECT＝超出规则表
            continue
        rows = [(k, join_pairs(leg_unesc(s)), join_pairs(leg_unesc(r)))
                for k, s, r in reads.get(name, [])]
        if not rows:
            raise SystemExit("%s 判定 OK 但腿里没有它的 M/F 读数——补样本后重跑腿" % name)
        out.append((name, pascal(name), txt, notes, rows))
    if not out:
        raise SystemExit("一条常量都没收到——腿读数文件对了吗？")
    return out, meta


PRELUDE = """///|
// 本文件是生成物：`python scripts/gen_re2_test.py <leg.tsv> --test re/preset_test.mbt`
// 期望值全部来自参照腿 `scripts/RePoolLeg.java` 的机器读数与改写规则表
// `scripts/re_preset_rewrite.py`（R1~R7）的推导——手打零条。改规则或重跑腿都要重跑本生成器。
// 契约、边界与全部出处：docs/spec/10-re.md §9~§12。改任何一条期望串须单独一笔并给外部读数来源（门禁 G5）。

///|
// 三档判定的取数helper：命中给 `true`/`false`，取组给第 0 组或 `NONE`，raise 给错误形状（携带值一起进断言）
fn pshow(err : @re.ReError) -> String {
  match err {
    @re.BadPattern(s) => "BadPattern \\{s}"
    @re.BadReference(s) => "BadReference \\{s}"
  }
}

fn pm(p : @re.RePreset, text : String) -> String {
  try {
    @re.re_match_preset(p, text).to_string()
  } catch {
    e => pshow(e)
  }
}

fn pf(p : @re.RePreset, text : String) -> String {
  try {
    match @re.re_find_preset(p, text) {
      None => "NONE"
      Some(v) => v
    }
  } catch {
    e => pshow(e)
  }
}

fn pnum(text : String) -> String {
  try {
    match @re.re_first_number(text) {
      None => "NONE"
      Some(v) => v
    }
  } catch {
    e => pshow(e)
  }
}
"""


def emit_test(target, items, meta):
    L = [PRELUDE]
    for name, case, txt, notes, rows in items:
        L.append("///|")
        L.append("// 常量 %s：参照原文经规则表 %s 得到下面的改写串；每条判定逐条取腿的读数" % (
            name, "+".join(notes) if notes else "无需改写（与参照逐字同形）"))
        L.append('test "preset %s" {' % name)
        L.append("  assert_eq(@re.re_preset_pattern(@re.RePreset::%s), %s)" % (case, mb_lit(txt)))
        for i, (kind, sample, reading) in enumerate(rows):
            fn = "pm" if kind == "M" else "pf"
            L.append("  assert_eq(%s(@re.RePreset::%s, %s), %s) // 腿 %s.%s 第 %d 条" % (
                fn, case, mb_lit(sample), mb_lit(reading), kind, name, i))
        L.append("}")
        L.append(NL)
    L.append("///|")
    L.append("// 名字表：本库档名 → 参照常量名（逐字符取腿 R 行的键名——要把本库的档与参照的文案对上就靠它）")
    L.append('test "preset 名字表" {')
    for name, case, _t, _n, _r in items:
        L.append("  assert_eq(@re.re_preset_name(@re.RePreset::%s), %s) // 腿 R 行的键名" % (
            case, mb_lit(name)))
    L.append("}")
    L.append(NL)
    L.append("///|")
    L.append("// 表全集：条数与顺序都钉住（顺序＝腿 R 行的声明序）。新增或删除一档必须连带改 spec §9 的边界表")
    L.append('test "preset 表全集" {')
    L.append("  assert_eq(@re.re_presets().map(p => @re.re_preset_name(p)), %s)" % (
        "[" + ", ".join(mb_lit(n) for n, _c, _t, _s, _r in items) + "]"))
    L.append("  assert_eq(@re.re_presets().length(), %d)" % len(items))
    # 这一条不来自腿：`re_presets()` 交的是副本，改返回的数组不许动到包内那张表（spec §11 第 17 行）。
    # 来源＝变异 P3 零红暴露的夹具缺口——"交副本"这件事在原来那批断言里没有任何输入能观测到。
    L.append('  // 本库自订（spec §11 第 17 行）：返回的是副本，调用方改它不许影响包内那张表')
    L.append("  let got = @re.re_presets()")
    L.append("  got.push(@re.RePreset::General)")
    L.append("  assert_eq(@re.re_presets().length(), %d)" % len(items))
    L.append("}")
    L.append(NL)
    L.append("///|")
    L.append("// 数字提取：对位 `ReUtil.getFirstNumber`，三条出口形状取腿的 G 行读数。")
    L.append("// 腿另有一条 `getFirstNumber(null)` → `null`（参照对 null 入参不崩），")
    L.append("// 本库的参数类型是 `String`，那一档在类型上不可表达 ⇒ 记在 spec §11，不编成断言")
    L.append('test "first_number" {')
    for key, sample in (("get_first_number", "a20b30"), ("get_first_number_none", "abc"),
                        ("get_first_number_empty", "")):
        if key not in meta:
            raise SystemExit("腿里没有 %s 这条读数" % key)
        want = "NONE" if meta[key] == "null" else meta[key]
        L.append("  assert_eq(pnum(%s), %s) // 腿 G.%s" % (mb_lit(sample), mb_lit(want), key))
    L.append("}")
    io.open(target, "w", encoding="utf-8", newline=NL).write(NL.join(L) + NL)
    n_read = sum(len(r) for _n, _c, _t, _s, r in items)
    print("preset_test.mbt：%d 块 / %d 条断言（判定读数 %d + 改写串 %d + 名字 %d + 表 2 + 数字 3）" % (
        len(items) + 3, n_read + 2 * len(items) + 5, n_read, len(items), len(items)))


def emit_table(target, items):
    L = [
        "// 本文件是生成物：`python scripts/gen_re2_test.py <leg.tsv> --table re/preset_table.mbt`",
        "// 两列都从「参照腿原文 + 改写规则表」机器推导（手打零条）；规则表与逐条出处见 docs/spec/10-re.md §10。",
        NL,
        "fn preset_name(p : RePreset) -> String {",
        "  match p {",
    ]
    for name, case, _t, _n, _r in items:
        L.append("    %s => %s" % (case, mb_lit(name)))
    L += ["  }", "}", NL, "fn preset_pattern(p : RePreset) -> String {", "  match p {"]
    for name, case, txt, _n, _r in items:
        L.append("    %s => %s" % (case, mb_lit(txt)))
    L += ["  }", "}", NL, "// 声明序＝腿 R 行的序（参照 RegexPool 的字段序），本库把它当作表全集的唯一出口"]
    L.append("let presets : Array[RePreset] = [")
    for _n, case, _t, _s, _r in items:
        L.append("  RePreset::%s," % case)
    L += ["]", NL]
    io.open(target, "w", encoding="utf-8", newline=NL).write(NL.join(L) + NL)
    print("preset_table.mbt：%d 档" % len(items))


def emit_probe(target, items):
    """临时对撞探针：本库侧对每条改写串与每个样本的读数（`is_valid_pattern` + 两档判定）。"""
    L = [
        "///|",
        "// 临时探针（**不进提交**）：本库侧读数，供与参照腿逐条对撞。跑完就删。",
        "fn ktag(p : String, text : String) -> String {",
        "  try {",
        "    @re.is_match(p, text).to_string()",
        "  } catch {",
        '    _ => "ERR"',
        "  }",
        "}",
        "",
        "fn kftag(p : String, text : String) -> String {",
        "  try {",
        "    match @re.find_first(p, text) {",
        '      None => "NONE"',
        "      Some(v) => v",
        "    }",
        "  } catch {",
        '    _ => "ERR"',
        "  }",
        "}",
        "",
        "///|",
        'test "@probe re 常量表两侧对撞" {',
    ]
    for name, _case, txt, _notes, rows in items:
        p = mb_lit(txt)
        L.append('  println("VNAME\\t%s\\t" + (if @re.is_valid_pattern(%s) { "OK" } else { "BAD" }))' % (
            name, p))
        for i, (kind, sample, _r) in enumerate(rows):
            fn = "ktag" if kind == "M" else "kftag"
            L.append('  println("P\\t%s\\t%d\\t%s\\t" + %s(%s, %s))' % (
                name, i, kind, fn, p, mb_lit(sample)))
    L.append("}")
    io.open(target, "w", encoding="utf-8", newline=NL).write(NL.join(L) + NL)
    print("探针 %s：%d 条常量、%d 行读数" % (target, len(items), sum(len(x[4]) for x in items)))


def main():
    items, meta = build(sys.argv[1])
    for flag, fn in (("--test", lambda t: emit_test(t, items, meta)),
                     ("--table", lambda t: emit_table(t, items)),
                     ("--probe", lambda t: emit_probe(t, items))):
        if flag in sys.argv:
            fn(sys.argv[sys.argv.index(flag) + 1])


if __name__ == "__main__":
    main()
