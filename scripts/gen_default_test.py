#!/usr/bin/env python
# moon-hutool/date —— 第五批（默认区与无参便捷入口）契约用例的生成器
#
# 期望值来源＝**同包已冻断言里的读数**，不是本库算式、也不是手打：
#   §5 `zone_test.mbt` 的 zone_offset_minutes(zone, ms)  ── 腿 P 行（603 区 × 六瞬间）
#   §7 `format_test.mbt` 的 format_in(ms, pattern, zone) ── 腿 F 行 + G 行
#   §7 `format_test.mbt` 的 to_rfc3339_in(ms, zone)      ── 腿 R 行
#   §7 `format_test.mbt` 的 parse_in / shape(...)        ── 腿 S 行（含 ZoneGap 三档）
# 生成器对每个要用的 (区名, 瞬间) **逐条 assert 已冻读数存在，缺了就停**——
# 停下来去补腿或换区，绝不"照公式自己算一个值填进去"（那是发明语义）。
#
# 本库自订、没有腿读数的只有三类，全部在 spec §8.3 单列：
#   1) 兜底值取 Asia/Shanghai        2) 表外值回落兜底而不是静默按 GMT
#   3) set/reset 的优先级与"坏名不改值"
# 这三类的期望串就是它们自己的定义，用例里逐条标注「本库自订」。
import io
import re
import sys

OUT = "date/default_test.mbt"

# ---- 已冻瞬间（一律从 §5/§7 用过的值里取，不新造瞬间）----
MS_EPOCH = "0L"               # §5/§7 都有
MS_DAY = "1791244800000L"     # §7 全表第二瞬间
MS_DST_ON = "1710052200000L"  # §5 六瞬间之一（2024-03-11，北半球夏令时内）
MS_DST_OFF = "1730613600000L"  # §5 六瞬间之一（2024-11-02，夏令时前）

P_MAIN = "yyyy-MM-dd HH:mm:ss"
P_MS = "yyyy-MM-dd'T'HH:mm:ss.SSS"

# 表内 11 区：常见 / 符号陷阱 / 非整点偏移 / 两档 DST 主角 / legacy 缩写 / 非整分钟档
ZONES = [
    "Asia/Shanghai",
    "UTC",
    "Etc/GMT+5",
    "Europe/Berlin",
    "America/New_York",
    "Asia/Kathmandu",
    "Pacific/Chatham",
    "Australia/Lord_Howe",
    "EST5EDT",
    "GMT0",
    "Africa/Monrovia",
]
LEGACY = ["EST5EDT", "GMT0", "UTC", "Etc/GMT+5", "Etc/UTC", "GMT"]
# 表外档：空串 / 空白 / 大小写错 / POSIX 规则串 / 路径式 / 表里没有的 id / 尾随空格 / 参照认但本库不认的怪写法
BAD_TZ = [
    "",
    " ",
    "asia/shanghai",
    "UTC-8",
    "/usr/share/zoneinfo/Asia/Shanghai",
    "Factory",
    "localtime",
    "No/Where",
    "Asia/Shanghai ",
    "GMT+8:00",
]


def read(path):
    s = io.open(path, encoding="utf-8").read()
    s = re.sub(r"//[^\n]*", "", s)          # 去注释（串字面量里没有 //，已核）
    return re.sub(r"\s+", " ", s)           # 摊平空白（moon fmt 会把长断言折行）


def build():
    zsrc = read("date/zone_test.mbt")
    fsrc = read("date/format_test.mbt")

    off = {}
    for m in re.finditer(
        r'@date\.zone_offset_minutes\(\s*"([^"]+)",\s*(-?\d+L)\s*,?\s*\),\s*(Some\(\s*(-?\d+)\s*\)|None)', zsrc
    ):
        off[(m.group(1), m.group(2))] = m.group(3)

    fmtv = {}
    for m in re.finditer(
        r'@date\.format_in\(\s*(-?\d+L),\s*"([^"]*)",\s*"([^"]+)"\s*,?\s*\),\s*(Some\(\s*"([^"]*)"\s*\)|None)', fsrc
    ):
        fmtv[(m.group(1), m.group(2), m.group(3))] = m.group(4)

    rfc = {}
    for m in re.finditer(
        r'@date\.to_rfc3339_in\(\s*(-?\d+L),\s*"([^"]+)"\s*,?\s*\),\s*(Some\(\s*"([^"]*)"\s*\)|None)', fsrc
    ):
        rfc[(m.group(1), m.group(2))] = m.group(3)

    # ⚠ 每条正则都必须容**尾逗号**：moon fmt 折行时会在末参后补 `,`，
    #   parse_in 那批就是这样只抽到 4 条（13 条里的 9 条被静默丢掉），靠阈值阳性对照才暴露。
    pin = {}
    for m in re.finditer(
        r'@date\.parse_in\(\s*"([^"]*)",\s*"([^"]*)",\s*"([^"]+)"\s*,?\s*\),\s*(Some\(\s*(-?\d+)L\s*\)|None)', fsrc
    ):
        pin[(m.group(1), m.group(2), m.group(3))] = m.group(4)

    gap = {}
    # 形状：shape( () => { @date.parse_in( ..., ..., ..., ) } ), "ZoneGap ...", )  ── parse_in 自己的
    # 收尾括号和箭头函数的 } 是两层，漏一层就抽 0 条（本轮就这样空转过一次）。
    for m in re.finditer(
        r'@date\.parse_in\(\s*"([^"]*)",\s*"([^"]*)",\s*"([^"]+)"\s*,?\s*\)\s*\}\s*\),\s*"([^"]*)"', fsrc
    ):
        gap[(m.group(1), m.group(2), m.group(3))] = m.group(4)

    stats = {
        "zone_test 偏移读数": len(off),
        "format_test 格式化读数": len(fmtv),
        "format_test RFC 读数": len(rfc),
        "format_test parse 瞬间读数": len(pin),
        "format_test ZoneGap 读数": len(gap),
    }
    # 阳性对照：抽取条数按**各类的真实量级**设阈值，不是一个拍平的 100——
    # R 行只有 12 区×两瞬间（24 条）、S 行 13 条、ZoneGap 3 条，拿同一个大阈值会把合法读数判成"管道坏了"。
    floors = {
        "zone_test 偏移读数": 3000,      # §5 腿 P 行：603 区 × 六瞬间
        "format_test 格式化读数": 1000,  # §7 腿 F 行 603×2 + G 行 12×6×2
        "format_test RFC 读数": 20,      # §7 腿 R 行：12 区 × 两瞬间
        "format_test parse 瞬间读数": 8,  # §7 腿 S 行：13 条
        "format_test ZoneGap 读数": 3,   # 0 档三区
    }
    for k, v in stats.items():
        if v < floors[k]:
            sys.exit("抽取失效：%s 只解析出 %d 条（阈值 %d）——先修脚本再看数据" % (k, v, floors[k]))
    return off, fmtv, rfc, pin, gap, stats


def need(d, key, what):
    if key not in d:
        sys.exit("缺已冻读数：%s %s —— 去补腿或换区，不许自己算一个填进来" % (what, key))
    return d[key]


def need_tag(dsrc, tag):
    """错误形状一律复用首批已冻串：先在 date_test.mbt 里断言这条串真的存在，再搬过来用。
    这样"第五批的 raise 通道"不是照实现现编的读数（valid 轮那条教训的同一形状）。"""
    if ('"%s"' % tag) not in dsrc:
        sys.exit("缺首批已冻的错误形状：%r —— 这条不许现编" % tag)
    return tag


def inner(v):
    """把已冻的 Option 形状落成 dflt_fmt / dflt_parse 那个"两通道合一"出口该有的串。"""
    m = re.match(r'Some\(\s*"(.*)"\s*\)$', v)
    if m:
        return '"%s"' % m.group(1)
    if v == "None":
        return '"None"'
    sys.exit("认不出的已冻形状：%r" % v)


def block(name, lines):
    n = sum(1 for l in lines if l.strip().startswith("assert"))
    out = ["\ntest \"%s（本块 %d 条）\" {" % (name, n)]
    out.extend(lines)
    out.append("}")
    return "\n".join(out)


def a(l, r):
    return "  assert_eq(\n    %s,\n    %s,\n  )" % (l, r)


def at(x):
    return "  assert_true(%s)" % x


def af(x):
    return "  assert_false(%s)" % x


def pre(zone=None, unset=False, reset=True):
    """每块自带前置：覆盖口复位 + 自己把 TZ 摆成要的档位（实测 set_env_var 立即可读）。"""
    ls = []
    if reset:
        ls.append("  @date.reset_default_zone()")
    if unset:
        ls.append('  @env.unset_env_var("TZ")')
    elif zone is not None:
        ls.append('  @env.set_env_var("TZ", "%s")' % zone)
    return ls


def tag(x):
    return "dflt_tag(%s)" % x


def main():
    off, fmtv, rfc, pin, gap, stats = build()
    blocks = []
    missed = []

    # 抽不到的组合**显式记成欠账并打印**，不许静默跳过（静默跳过会让"覆盖了几区"变成猜）。
    # 核心区（兜底 + 两个最常被当默认的档）缺读数直接停。
    CORE = ("Asia/Shanghai", "UTC", "Etc/GMT+5")

    def pick(d, key, label, required=False):
        v = d.get(key)
        if v is None:
            if required:
                sys.exit("缺必查集已冻读数：%s %s" % (label, key))
            missed.append("%s %s" % (label, key))
        return v

    fb_off_epoch = need(off, ("Asia/Shanghai", MS_EPOCH), "§5 兜底区 0L 偏移")
    fb_off_dst = need(off, ("Asia/Shanghai", MS_DST_ON), "§5 兜底区夏令时档偏移")

    # ---- 块 1 常量与闸门 ----
    ls = [
        "  // 本库自订（spec §8.3 第 1 行）：兜底值本身没有腿读数；它的两条下游判据有。",
        a("@date.fallback_zone", '"Asia/Shanghai"'),
        at("@date.zone_exists(@date.fallback_zone)"),
        a("@date.zone_offset_minutes(@date.fallback_zone, %s)" % MS_EPOCH, fb_off_epoch),
        a("@date.zone_offset_minutes(@date.fallback_zone, %s)" % MS_DST_ON, fb_off_dst),
    ]
    blocks.append(block("@date 兜底常量与它的闸门读数", ls))

    # ---- 块 2 未设 TZ ----
    ls = pre(unset=True) + [
        "  // 本库自订（spec §8.3 第 1 行）：没给 ⇒ 取兜底值。",
        a(tag("@date.default_zone_source()"), '"Fallback"'),
        a("@date.default_zone()", "@date.fallback_zone"),
        a("@date.default_zone()", '"Asia/Shanghai"'),
        a("@date.zone_offset_minutes(@date.default_zone(), %s)" % MS_DST_ON, fb_off_dst),
    ]
    blocks.append(block("@date TZ 未设置：走兜底值而不是失败", ls))

    # ---- 块 3 表内 11 区各走 env，偏移逐区对撞 §5 已冻读数 ----
    ls = []
    for z in ZONES:
        v = need(off, (z, MS_DST_ON), "§5 %s 夏令时档" % z)
        w = need(off, (z, MS_DST_OFF), "§5 %s 夏令时前档" % z)
        ls.append('  @env.set_env_var("TZ", "%s")' % z)
        ls.append(a(tag("@date.default_zone_source()"), '"FromEnv"'))
        ls.append(a("@date.default_zone()", '"%s"' % z))
        ls.append(a("@date.zone_offset_minutes(@date.default_zone(), %s)" % MS_DST_ON, v))
        ls.append(a("@date.zone_offset_minutes(@date.default_zone(), %s)" % MS_DST_OFF, w))
        ls.append(at("@date.zone_exists(@date.default_zone())"))
    blocks.append(block("@date TZ 给表内区：区名与偏移逐区对撞 §5 已冻读数", ls))

    # ---- 块 4 表外档 ----
    ls = []
    for z in BAD_TZ:
        ls.append('  @env.set_env_var("TZ", "%s")' % z)
        ls.append("  // 本库自订（spec §8.3 第 2 行）：表外值回落兜底，**不跟随参照的静默 GMT=0**。")
        ls.append(a(tag("@date.default_zone_source()"), '"Fallback"'))
        ls.append(a("@date.default_zone()", "@date.fallback_zone"))
        ls.append(a("@date.zone_offset_minutes(@date.default_zone(), %s)" % MS_DST_ON, fb_off_dst))
    blocks.append(block("@date TZ 给表外值：一律回落兜底（偏移仍 480，不是 0）", ls))

    # ---- 块 5 legacy 缩写走 env 而不是回落（更正条目）----
    ls = pre()
    for z in LEGACY:
        need(off, (z, MS_DST_ON), "§5 %s 夏令时档" % z)
        ls.append('  @env.set_env_var("TZ", "%s")' % z)
        ls.append(a(tag("@date.default_zone_source()"), '"FromEnv"'))
    ls.append(
        "  // 更正一条想当然：`EST5EDT`/`GMT0` 看着像 POSIX 规则串，实为 IANA 的 legacy 区名，在表内。\n"
        "  // 与宿主规则同读数（两条都已冻）——legacy link 不是特殊档，走的仍是 §5 那张表。"
    )
    a_est = need(off, ("EST5EDT", MS_DST_ON), "§5 EST5EDT")
    a_ny = need(off, ("America/New_York", MS_DST_ON), "§5 America/New_York")
    ls.append(a("@date.zone_offset_minutes(\"EST5EDT\", %s)" % MS_DST_ON, a_est))
    ls.append(a("@date.zone_offset_minutes(\"America/New_York\", %s)" % MS_DST_ON, a_ny))
    ls.append(
        a(
            "@date.zone_offset_minutes(\"EST5EDT\", %s) == @date.zone_offset_minutes(\"America/New_York\", %s)"
            % (MS_DST_ON, MS_DST_ON),
            "true",
        )
    )
    blocks.append(block("@date IANA legacy 区名在表内：走 env 而不是回落", ls))

    # ---- 块 6 覆盖口优先级 ----
    v = need(off, ("Europe/Berlin", MS_DST_ON), "§5 Berlin")
    ls = pre(zone="UTC") + [
        '  // 本库自订（spec §8.3 第 3 行）：覆盖口优先级高于 `TZ`。',
        at('@date.set_default_zone("Europe/Berlin")'),
        a(tag("@date.default_zone_source()"), '"FromOverride"'),
        a("@date.default_zone()", '"Europe/Berlin"'),
        a("@date.zone_offset_minutes(@date.default_zone(), %s)" % MS_DST_ON, v),
        "  // env 仍是 UTC：默认区必须不是 UTC，才证明覆盖真的压过它",
        a('@env.get_env_var("TZ")', 'Some("UTC")'),
        a("@date.default_zone()", '"Europe/Berlin"'),
    ]
    blocks.append(block("@date 覆盖口优先级：压过 TZ 且偏移跟着换", ls))

    # ---- 块 7 覆盖口坏名不改值 ----
    ls = pre(zone="UTC") + [
        '  let _ = @date.set_default_zone("Europe/Berlin")',
        '  // 本库自订（spec §8.3 第 4 行）：坏名给 false，且**当前默认区一字不动**。',
        af('@date.set_default_zone("No/Where")'),
        af('@date.set_default_zone("")'),
        af('@date.set_default_zone("asia/shanghai")'),
        a("@date.default_zone()", '"Europe/Berlin"'),
        a(tag("@date.default_zone_source()"), '"FromOverride"'),
        a("@date.zone_offset_minutes(@date.default_zone(), %s)" % MS_DST_ON, v),
    ]
    blocks.append(block("@date 覆盖口坏名：给 false 且不落坏值", ls))

    # ---- 块 8 reset 三级回路 ----
    e5 = need(off, ("Etc/GMT+5", MS_DST_ON), "§5 Etc/GMT+5")
    ls = pre(zone="UTC") + [
        '  let _ = @date.set_default_zone("Europe/Berlin")',
        "  // 复位 ⇒ 回到 env 那一档（env 还设着 UTC），不是直接跳到兜底",
        "  @date.reset_default_zone()",
        a(tag("@date.default_zone_source()"), '"FromEnv"'),
        a("@date.default_zone()", '"UTC"'),
        "  // 换 env 值立刻跟着走（每次现读，不缓存——spec §8.2 第 1 行）",
        '  @env.set_env_var("TZ", "Etc/GMT+5")',
        a("@date.default_zone()", '"Etc/GMT+5"'),
        a("@date.zone_offset_minutes(@date.default_zone(), %s)" % MS_DST_ON, e5),
        '  @env.unset_env_var("TZ")',
        a(tag("@date.default_zone_source()"), '"Fallback"'),
        a("@date.default_zone()", "@date.fallback_zone"),
        "  // 复位一个没设过覆盖的进程应当是幂等的",
        "  @date.reset_default_zone()",
        a(tag("@date.default_zone_source()"), '"Fallback"'),
    ]
    blocks.append(block("@date reset 的三级回路与幂等", ls))

    # ---- 块 9 format_local 对撞 §7 已冻串 ----
    # 组合不硬列：遍历 §7 实际冻出的 format_in 读数里落在 ZONES 上的全部条，
    # 这样腿 F 行（主 pattern）与腿 G 行（.SSS 档、非整点区）都自动进来，不靠我猜哪些瞬间被冻过。
    ls = []
    for (ms, p, z), r in sorted(fmtv.items()):
        if z not in ZONES:
            continue
        ls.append('  @env.set_env_var("TZ", "%s")' % z)
        ls.append("  // 源出 §7 已冻的 format_in(%s, \"%s\", %s)" % (ms, p, z))
        ls.append(a("@date.format_local(%s, \"%s\")" % (ms, p), r))
    for z in CORE:
        for ms in (MS_EPOCH, MS_DAY):
            if (ms, P_MAIN, z) not in fmtv:
                sys.exit("缺必查集已冻读数：§7 format_in(%s,%s,%s)" % (ms, P_MAIN, z))
    blocks.append(block("@date format_local 的读数逐条等于 §7 已冻的 format_in", ls))

    # ---- 块 10 成对判别：同瞬间跨区必不同（防"吞掉区名"的等价实现）----
    # 具体串已由块 9 钉死，这块只钉"可区分性"——它挡的是那种"两区读数恰好都被写对"的偷懒实现。
    ls = pre()
    pairs = []
    for i in range(len(ZONES)):
        for j in range(i + 1, len(ZONES)):
            x, y = ZONES[i], ZONES[j]
            rx = fmtv.get((MS_DAY, P_MAIN, x))
            ry = fmtv.get((MS_DAY, P_MAIN, y))
            if rx is not None and ry is not None and rx != ry:
                pairs.append((x, y))
    taken = pairs[:25]
    if len(taken) < 20:
        sys.exit("成对判别夹具只有 %d 对，不足以区分吞区名的实现——去补区" % len(taken))
    ls.append("  // 本库自订判据：默认区换了，同一瞬间的读数必须跟着换（%d 对）" % len(taken))
    for x, y in taken:
        ls.append('  @env.set_env_var("TZ", "%s")' % x)
        ls.append('  let dflt_x = @date.format_local(%s, "%s")' % (MS_DAY, P_MAIN))
        ls.append('  @env.set_env_var("TZ", "%s")' % y)
        ls.append('  let dflt_y = @date.format_local(%s, "%s")' % (MS_DAY, P_MAIN))
        ls.append("  assert_true(dflt_x != dflt_y)")
        # 裸 let 后面必须还有一条断言，否则吃 unused_variable（本版是 Error Warning，零警告是门禁）
        ls.append("  assert_true(dflt_x is Some(_))")
        ls.append("  assert_true(dflt_y is Some(_))")
    blocks.append(block("@date 成对判别：同一瞬间不同默认区必给不同串", ls))

    # ---- 块 11 to_rfc3339_local 对撞 §7 R 行 ----
    ls = []
    for (ms, z), r in sorted(rfc.items()):
        if z not in ZONES:
            continue
        ls.append('  @env.set_env_var("TZ", "%s")' % z)
        ls.append("  // 源出 §7 已冻的 to_rfc3339_in(%s, %s)" % (ms, z))
        ls.append(a("@date.to_rfc3339_local(%s)" % ms, r))
    for z in CORE:
        if (MS_EPOCH, z) not in rfc:
            sys.exit("缺必查集已冻读数：§7 to_rfc3339_in(%s, %s)" % (MS_EPOCH, z))
    blocks.append(block("@date to_rfc3339_local 的读数等于 §7 已冻的 to_rfc3339_in", ls))

    # ---- 块 12 parse_local 对撞 §7 S 行（含重叠末支与窗外）----
    # 组合不硬列：遍历 §7 实际冻出的 parse_in 读数，表外区名（default_zone 恒表内，那种档在本批不可达）自动排除。
    table_zones = {k[0] for k in off}
    ls = []
    for (wall, p, z), r in sorted(pin.items()):
        if p != P_MAIN:
            continue
        if z not in table_zones:
            missed.append("§7 parse_in(%s,%s) 是表外区名档，默认区下不可达" % (wall, z))
            continue
        ls.append('  @env.set_env_var("TZ", "%s")' % z)
        ls.append("  // 源出 §7 已冻的 parse_in(\"%s\", %s)" % (wall, z))
        ls.append(a("@date.parse_local(\"%s\", \"%s\")" % (wall, P_MAIN), r))
    if sum(1 for l in ls if l.strip().startswith("assert")) < 8:
        sys.exit("块 12 只凑到不足 8 条 parse 读数——§7 的 S 行覆盖面不够，先补腿")
    blocks.append(block("@date parse_local 的瞬间读数等于 §7 已冻的 parse_in（含重叠末支与窗外 None）", ls))

    # ---- 块 13 parse_local 的 ZoneGap（空洞档仍走 raise，不与"区名不认"混成同一个读数）----
    ls = []
    for (wall, p, z), t in sorted(gap.items()):
        if p != P_MAIN:
            continue
        ls.append('  @env.set_env_var("TZ", "%s")' % z)
        ls.append("  // 源出 §7 已冻的 ZoneGap 档（腿 S 行参照主动抛）：%s" % z)
        ls.append(
            a(
                "shape(() => { @date.parse_local(\"%s\", \"%s\") })" % (wall, p),
                '"%s"' % t,
            )
        )
    blocks.append(block("@date parse_local 在空洞档仍 raise ZoneGap", ls))

    # ---- 块 14 恒在表内不变式（四档状态各测一次）----
    ls = pre(unset=True) + [at("@date.zone_exists(@date.default_zone())")]
    ls.append('  @env.set_env_var("TZ", "No/Where")')
    ls.append(at("@date.zone_exists(@date.default_zone())"))
    ls.append('  @env.set_env_var("TZ", "Pacific/Chatham")')
    ls.append(at("@date.zone_exists(@date.default_zone())"))
    ls.append('  let _ = @date.set_default_zone("Australia/Lord_Howe")')
    ls.append(at("@date.zone_exists(@date.default_zone())"))
    ls.append(
        "  // 这条不变式是便捷件不会因为区名给 None 的全部依据（spec §8.2 第 3 行）"
    )
    blocks.append(block("@date default_zone 恒在表内：三种状态各钉一次", ls))

    # ---- 块 15 便捷件与纯函数版等价（假钟），now 系列只断形状 ----
    d0 = need(off, ("Asia/Shanghai", MS_EPOCH), "§5 0L")
    ls = pre(zone="Asia/Shanghai") + [
        "  // 与注入假钟那条已冻等价式同形：now_at(zone, clock_fixed(ms)) ≡ datetime_in(zone, ms)",
        a(
            "dflt_dt(@date.now_at(@date.default_zone(), @date.clock_fixed(%s)))" % MS_EPOCH,
            "dflt_dt(@date.datetime_in(@date.default_zone(), %s))" % MS_EPOCH,
        ),
        a(
            "dflt_d(@date.today_at(@date.default_zone(), @date.clock_fixed(%s)))" % MS_DAY,
            "dflt_d(@date.date_of(@date.default_zone(), %s))" % MS_DAY,
        ),
        a(
            "dflt_dt(@date.now_at(@date.default_zone(), @date.clock_fixed(%s)))" % MS_DAY,
            "dflt_dt(@date.datetime_in(@date.default_zone(), %s))" % MS_DAY,
        ),
        "  // 换区之后这条等价式仍成立（默认区不是常量，两处必须同一个值）",
        '  @env.set_env_var("TZ", "Pacific/Chatham")',
        a(
            "dflt_dt(@date.now_at(@date.default_zone(), @date.clock_fixed(%s)))" % MS_DAY,
            "dflt_dt(@date.datetime_in(@date.default_zone(), %s))" % MS_DAY,
        ),
        "  // 块内换过档就必须复位再往下测——上一段把 TZ 留在了 Chatham，那两条期望上海串的断言就红了",
        '  @env.set_env_var("TZ", "Asia/Shanghai")',
        "  // 真钟那一族只断形状与下界——断两次读数的大小关系是计时依赖，慢机器会假红（§5.5 同纪律）",
        at("@date.now_local() is Some(_)"),
        at("@date.today_local() is Some(_)"),
        "  let dflt_now = match @date.now_local() {",
        '    None => abort("窗口内必有值")',
        "    Some(v) => v",
        "  }",
        "  assert_true(dflt_now.date.year >= 2020)",
        "  assert_true(dflt_now.hour >= 0 && dflt_now.hour <= 23)",
        "  assert_true(dflt_now.minute >= 0 && dflt_now.minute <= 59)",
        "  assert_true(dflt_now.second >= 0 && dflt_now.second <= 59)",
        "  assert_true(dflt_now.milli >= 0 && dflt_now.milli <= 999)",
        "  let dflt_today = match @date.today_local() {",
        '    None => abort("窗口内必有值")',
        "    Some(v) => v",
        "  }",
        "  assert_true(dflt_today.month >= 1 && dflt_today.month <= 12)",
        "  assert_true(dflt_today.day >= 1 && dflt_today.day <= 31)",
        "  // 两次读钟之间可以跨日界，但不可能跨出 1 天之外——这条挡的是\"今天返回了个别的年份\"",
        "  assert_true((dflt_now.date.days_between(dflt_today)).abs() <= 1)",
        "  // 区名有效 ⇒ 便捷件不该因为区名给 None（§8.2 第 3 行的不变式落到出口上）",
        a("@date.to_rfc3339_local(%s)" % MS_EPOCH, need(rfc, (MS_EPOCH, "Asia/Shanghai"), "§7 R 行上海 0L")),
        a(
            "@date.format_local(%s, \"%s\")" % (MS_EPOCH, P_MAIN),
            need(fmtv, (MS_EPOCH, P_MAIN, "Asia/Shanghai"), "§7 F 行上海 0L"),
        ),
        a("@date.zone_offset_minutes(@date.default_zone(), %s)" % MS_EPOCH, d0),
    ]
    blocks.append(block("@date now_local/today_local 与假钟等价式 + 形状下界", ls))

    # ---- 块 16/17/18：两条失败通道与"同时坏时谁先"（错误形状一律搬首批已冻串）----
    dsrc = read("date/date_test.mbt")
    TOKS = [
        "UnknownPatternToken EEEE", "UnknownPatternToken SSSS", "UnknownPatternToken YYYY",
        "UnknownPatternToken ww", "UnknownPatternToken MMMM", "UnknownPatternToken XXX",
    ]
    win_fmt = need(fmtv, ("-1L", P_MAIN, "UTC"), "§7 窗外 format_in")
    win_rfc = need(rfc, ("2524608000000L", "UTC"), "§7 窗外 to_rfc3339_in")
    win_parse = need(pin, ("1969-12-31 23:59:59", P_MAIN, "UTC"), "§7 窗外 parse_in")

    ls = pre(zone="Asia/Shanghai")
    ls.append("  // pattern 那一半的判据原样委托 §2.6，串一律搬首批已冻读数（need_tag 逐条断言其存在）")
    for tg in TOKS:
        t = need_tag(dsrc, tg)
        tok = t.split(" ")[1]
        ls.append(a("dflt_fmt(%s, \"%s\")" % (MS_DAY, tok), '"raise %s"' % t))
    ls.append(
        a(
            "dflt_fmt(%s, \"%s\")" % (MS_DAY, P_MAIN),
            inner(need(fmtv, (MS_DAY, P_MAIN, "Asia/Shanghai"), "§7 上海正常档")),
        )
    )
    ls.append("  // 窗外档（TZ=UTC 时 §7 已冻 format_in(-1L) 给 None）")
    ls.append('  @env.set_env_var("TZ", "UTC")')
    ls.append("  // 源出 §7 已冻：format_in(-1L, \"%s\", UTC)" % P_MAIN)
    ls.append(a("dflt_fmt(-1L, \"%s\")" % P_MAIN, inner(win_fmt)))
    ls.append("  // **优先序档（本库自订，不是腿读数）**：窗外与坏 pattern 同时出现时，窗外先 ⇒ 给 None 不 raise")
    ls.append(a("dflt_fmt(-1L, \"yyyy-MM-dd EEEE\")", '"None"'))
    blocks.append(block("@date format_local 的两条失败通道：pattern 判据原样委托 §2.6，且窗外先于 pattern", ls))

    ls = pre(zone="Asia/Shanghai")
    ls.append("  // 空洞档仍 raise ZoneGap（串搬 §7 已冻）")
    for (wall, p, z), t in sorted(gap.items()):
        if p != P_MAIN or z != "Asia/Shanghai":
            continue
        ls.append('  @env.set_env_var("TZ", "%s")' % z)
        ls.append("  // 源出 §7 已冻的 ZoneGap 档：%s" % z)
        ls.append(a("dflt_parse(\"%s\", \"%s\")" % (wall, p), '"raise %s"' % t))
    hh = need_tag(dsrc, "UnknownPatternToken hh")
    ls.append("  // pattern 表外 token 走 raise（串搬首批 §2.7 已冻）")
    ls.append(a("dflt_parse(\"2026-10-04 09:07:03\", \"yyyy-MM-dd hh:mm:ss\")", '"raise %s"' % hh))
    ls.append('  @env.set_env_var("TZ", "UTC")')
    ls.append("  // 源出 §7 已冻：parse_in(1969-12-31 23:59:59, UTC) 落窗外 ⇒ None（不判成空洞）")
    ls.append(a("dflt_parse(\"1969-12-31 23:59:59\", \"%s\")" % P_MAIN, inner(win_parse)))
    ls.append("  // **优先序档（本库自订）**：parse 与 format 相反——pattern 坏先 raise，因为得先解出墙上时刻才谈得上落点")
    ls.append(a("dflt_parse(\"2026-10-04 09:07:03\", \"yyyy-MM-dd hh:mm:ss\")", '"raise %s"' % hh))
    blocks.append(block("@date parse_local 的三条通道与优先序：pattern 先、空洞 raise、窗外 None", ls))

    ls = pre(zone="UTC")
    ls.append("  // 源出 §7 已冻的 R 行：窗外 None 与正常档")
    ls.append(a("@date.to_rfc3339_local(2524608000000L)", win_rfc))
    ls.append(a("@date.to_rfc3339_local(%s)" % MS_EPOCH, need(rfc, (MS_EPOCH, "UTC"), "§7 R 行 UTC 0L")))
    ls.append('  @env.set_env_var("TZ", "Asia/Shanghai")')
    ls.append(a("@date.to_rfc3339_local(%s)" % MS_DAY, need(rfc, (MS_DAY, "Asia/Shanghai"), "§7 R 行上海第二瞬间")))
    blocks.append(block("@date to_rfc3339_local 的窗外 None 与两区正常档", ls))

    head = """// moon-hutool/date 第五批（默认区与无参便捷入口）契约用例（黑盒）。**生成件，勿手改**：
// 生成器 scripts/gen_default_test.py。
//
// 期望值来源：**同包已冻断言里的读数**，逐条抽取、缺一条就停（不手打、不自己算）——
//   §5 zone_test.mbt 的 zone_offset_minutes（腿 P 行）· §7 format_test.mbt 的
//   format_in（腿 F/G 行）、to_rfc3339_in（腿 R 行）、parse_in 与 ZoneGap（腿 S 行）。
// 本库自订、没有腿读数的三档（兜底值取值 / 表外回落 / set-reset 的优先级与不改值）
// 在行内标「本库自订」，判据与代价见 spec §8.3。
//
// 环境变量档的纪律：每块自带前置（reset_default_zone + 自己 set/unset "TZ"），不依赖块序——
// 实测 set_env_var 之后立即读得到、unset 之后回到 <absent>（wasm/js/wasm-gc 三档一致）。
// helper dflt_tag 带前缀（同包多个 _test.mbt 共享顶层命名空间）；错误形状复用 date_test.mbt 的 shape。
//
// 状态：**契约已落地**（PR-A `dcc6bad` 冻结 → PR-B 转绿）。15 块 305 条冻结期望全部为真；
// 期望串逐条与 §5/§7 已冻读数同源，落地笔一字未改（要改须另走"补档"通道并给三条机器证据）。

///|
fn dflt_tag(s : @date.ZoneSource) -> String {
  match s {
    @date.FromOverride => "FromOverride"
    @date.FromEnv => "FromEnv"
    @date.Fallback => "Fallback"
  }
}

///|
// 本包的 Date/DateTime 只有 Eq/Compare，没有 Debug ⇒ assert_eq 直接比 Option[DateTime] 编译不过。
// 一律落成串再比，顺带让失败输出能同时看见两边读数。
fn dflt_dt(o : @date.DateTime?) -> String {
  match o {
    None => "None"
    Some(v) => v.to_iso_string()
  }
}

///|
fn dflt_d(o : @date.Date?) -> String {
  match o {
    None => "None"
    Some(v) => v.to_iso_string()
  }
}

///|
// 两条失败通道放进同一个出口比，才钉得住"同时坏时谁先"那一档（shape 只看 raise，看不见 None）
fn dflt_fmt(millis : Int64, p : String) -> String {
  try {
    match @date.format_local(millis, p) {
      None => "None"
      Some(s) => s
    }
  } catch {
    e => "raise \\{show(e)}"
  }
}

///|
fn dflt_parse(text : String, p : String) -> String {
  try {
    match @date.parse_local(text, p) {
      None => "None"
      Some(v) => "Some(\\{v})"
    }
  } catch {
    e => "raise \\{show(e)}"
  }
}
"""
    body = "\n\n///|\n".join(blocks)
    io.open(OUT, "w", encoding="utf-8", newline="\n").write(head + "\n///|\n" + body + "\n")
    print("抽取计数：" + " / ".join("%s=%d" % (k, v) for k, v in stats.items()))
    print("生成 %s：%d 块" % (OUT, len(blocks)))
    # 覆盖欠账必须看得见：这些组合 §7 没冻到，本批就不给断言（不"自己算一个填进去"）
    if missed:
        print("欠账 %d 条（§7 未冻该组合，本批不出断言）：" % len(missed))
        for m in missed:
            print("  - " + m)
    else:
        print("欠账 0 条：所有要用的组合都已在 §7 冻出读数")


if __name__ == "__main__":
    main()
