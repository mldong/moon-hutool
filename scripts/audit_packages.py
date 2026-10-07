#!/usr/bin/env python
# moon-hutool 全仓审计工装（10-07 owner 定："不只是扫 date，所有工具都要这样处理"）
#
# 三格判据，全部机器取数，不靠人逐包翻：
#   A 未覆盖行  ── `moon coverage analyze` 全仓跑一次，按包归并（新补的失败通道档就靠这格现形）
#   B raise 出口 vs 错误形状断言  ── 包里 `raise <Variant>` 的处数，对上测试里真断过错误形状的处数；
#      比值悬殊就是"声明会抛、用例从没看过那条通道"（date 第五批刚栽过一次，别靠记性，靠这一格）
#   C 与 Java hutool 的命名对位  ── 拿参照 jar 的 javap 公开面，把本包公开件名做 snake_case↔camelCase
#      归一后比对，输出两类清单：本库有而参照无（自订档，须在 spec 标明）、参照有而本库无（待拍缺口）
#
# 用法：python scripts/audit_packages.py [--javap] [--list]
#   --javap 才去调 JDK：参照 jar 走 $HUTOOL_JAR（指 hutool-all 一份就够，crypto/setting/bloomFilter
#   这些独立 artifact 全在里面）；没设则退回 /tmp/convsrc 下的 hutool-*.jar。
#   --list 打印 C 格两份清单（本库名参照无 / 参照有名库无）——改名 triage 用的就是它。
#   C 格取不到参照面时显式 SKIP 并计数，绝不给比值：件数少算（泛型行形状整包漏抽）与空参照集
#   都在这轮被抓出来过，见 public_names / hutool_jar 两处注。
#   默认只跑 A/B（快，纯本地）；--javap 才去调 JDK（需要 /tmp/convsrc 下有 hutool jar）
import glob
import io
import os
import re
import shutil
import subprocess
import sys
import tempfile

JARS = os.path.join(tempfile.gettempdir(), "convsrc")
# 参照腿的 JDK 不写死机器路径：$JAVAP_BIN → PATH 里的 javap → 找不到就把这一格显式报 SKIP。
# （硬写绝对路径既过不了"公开仓不带本机路径"这条线，也让别人根本跑不动这个审计。）
JAVAP = os.environ.get("JAVAP_BIN") or shutil.which("javap") or ""
PKG_SPEC = "docs/spec"


def run(cmd):
    r = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return r.stdout.decode("utf-8", "replace").replace("\r", "")


def coverage_by_pkg():
    out = run("moon coverage analyze")
    # 行形状："<n> uncovered line(s) in <file>:" 后面跟若干 "行号<TAB>代码<-- UNCOVERED"
    per = {}
    cur = None
    for line in out.splitlines():
        m = re.match(r"^(\d+) uncovered line\(s\) in (.+):$", line.strip())
        if m:
            cur = m.group(2).replace("\\", "/")
            per.setdefault(cur, [])
            continue
        m = re.match(r"^(\d+)\s+(.*?)\s*<--\s*UNCOVERED\s*$", line)
        if m and cur:
            per[cur].append((int(m.group(1)), m.group(2).strip()))
    byp = {}
    for f, rows in per.items():
        pkg = f.split("/")[0]
        byp.setdefault(pkg, []).append((f, rows))
    return byp, out


def raise_sites(pkg):
    impl = 0
    variants = set()
    for f in glob.glob(os.path.join(pkg, "*.mbt")):
        if f.endswith(("_test.mbt", "_wbtest.mbt")):
            continue
        s = io.open(f, encoding="utf-8", errors="replace").read()
        for m in re.finditer(r"\braise\s+(?:([A-Z][A-Za-z0-9_]*)::)?([A-Z][A-Za-z0-9_]*)", s):
            impl += 1
            # `raise NumError::NegativeFactorial(...)` 抓出来的是**变体**；旧版把限定名整段当一个变体，
            # 于是错误**类型名**也被计入变体总数（10-07 实测 typex 报 8/9，那"没点名的第 9 个"就是
            # NumError 这个类型，不是任何一条错误通道）——假红会指着一个不存在缺陷让人补用例。
            variants.add(m.group(2))
    tsrc = ""
    for f in glob.glob(os.path.join(pkg, "*_test.mbt")) + glob.glob(os.path.join(pkg, "README.mbt.md")):
        tsrc += io.open(f, encoding="utf-8", errors="replace").read()
    # 逐个错误变体点名：这个变体在测试里被不被提到（match 分支、标签串、shape 出口都算）。
    # 数"命中次数"没意义——一个生成件文件能出现上千次，把信号淹成噪声；只问"有没有人看着它"。
    named = [v for v in sorted(variants) if re.search(r"\b%s\b" % re.escape(v), tsrc)]
    return impl, len(variants), len(named)


def norm(n):
    """camelCase / snake_case / 常见缩写 归一，用于跨语言比名字。"""
    n = re.sub(r"^(is|to|get|set|parse|format)_?", "", n)
    n = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", n)
    return re.sub(r"[^a-z0-9]", "", n.lower())


def same_name(ours, ref):
    """对位判定：**允许族前缀**。本库把多类合一的包（typex 装了 CoordinateUtil/DataSizeUtil/…，
    csv 装了 CsvReader/CsvWriter/…）按 `coord_*` / `csv_*` 前缀命名，而 hutool 的
    `CoordinateUtil.bd09ToGCJ02` 本身没有这个前缀——只比"完全同名"会把 102/109 全判成不对位，
    那份表就不能当改名依据。改成后缀互含：真·命名漂移仍然会被挑出来。

    ⚠ 必须挡空串与超短名：`norm()` 会剥掉 `to/get/is/...` 前缀，于是参照里出现 `""`、`"of"`、
    `"day"` 这类短串，而 `"任何串".endswith("")` 恒真——整格会**静默全通过**（实测 date 一度报 0/64，
    与 javap 现读的 `add_days`↔`offsetDay` 直接矛盾）。判据全通过比有噪声更坏。"""
    if len(ref) < 4 or len(ours) < 4:
        return ours == ref
    return ours == ref or ours.endswith(ref) or ref.endswith(ours)


def public_names(pkg):
    """抽公开件名。三种行形状都要认（旧版只认第一种，于是泛型包整包漏抽——
    10-07 实测 mapx 报 0、coll 报 1，而现读 `mapx/pkg.generated.mbti` 全是
    `pub fn[K : Hash + Eq] BiMap::get(...)` 这种带类型参数的形状）：
      pub fn name(...)
      pub fn[T] name(...)
      pub fn[T] Type::method(...)   /   pub fn Type::method(...)
    抽取数与文件里 `pub fn` 行数不等就记进 EXTRACT_AUDIT 并由 main() 显式点名——
    "件数少算"是静默失效，比多算更危险。"""
    p = os.path.join(pkg, "pkg.generated.mbti")
    if not os.path.exists(p):
        EXTRACT_AUDIT[pkg] = (0, 0)
        return []
    s = io.open(p, encoding="utf-8", errors="replace").read()
    lines = [ln for ln in s.splitlines() if ln.startswith("pub fn")]
    got = re.findall(r"^pub fn(?:\[[^\]]*\])?\s+(?:[A-Za-z_][A-Za-z0-9_]*::)?([a-z_][A-Za-z0-9_]*)\(", s, re.M)
    EXTRACT_AUDIT[pkg] = (len(got), len(lines))
    return sorted(set(got))


# trait / 运算符派生面：这些名字 Java 参照里天然没有（`op_ge` 是 `>=` 的糖，`to_string`/`compare`
# 来自 derive），混进"本库名参照无"会把真漂移淹掉——单列一档，不参与对位比对。
TRAIT_OPS = re.compile(r"^(op_[a-z0-9_]+|new|to_string|compare|equal|not_equal|hash|show|inspect)$")


_JAR_INDEX = {}
EXTRACT_AUDIT = {}   # pkg -> (抽取到的件名数, 该 .mbti 里 pub fn 行数)


def hutool_jar():
    """参照 jar 的取法（旧版写死 /tmp/convsrc/hutool-core.jar，于是对位类只要落在 crypto /
    bloomFilter / setting / cron 这些**独立 artifact** 就整格取不到数，只打一行注记继续给比值——
    "取不到数就当过"那一族）。现在的顺序：
      $HUTOOL_JAR（推荐指 hutool-all，一次覆盖全部 artifact）→ convsrc/hutool-core.jar → 该目录里任意 hutool-*.jar。
    找不到就返回 None，由调用方显式 SKIP，不产出比值。"""
    env = os.environ.get("HUTOOL_JAR")
    if env and os.path.exists(env):
        return env
    cand = [os.path.join(JARS, "hutool-core.jar")]
    cand += sorted(glob.glob(os.path.join(JARS, "hutool-*.jar")))
    for c in cand:
        if os.path.exists(c) and not c.endswith("-sources.jar") and "-src" not in os.path.basename(c):
            return c
    return None


def jar_index():
    """简单类名 -> 全限定名。javap 只认 FQN，喂 `DateUtil` 会静默查不到类、
    返回空表——空表在上一版被当成"参照没有这个方法"，是判据的假阴性。"""
    if _JAR_INDEX:
        return _JAR_INDEX
    import zipfile
    jars = []
    if hutool_jar():
        jars.append(hutool_jar())
    jars += [j for j in sorted(glob.glob(os.path.join(JARS, "*.jar")))
             if not j.endswith("-sources.jar") and "-src" not in os.path.basename(j)]
    for j in jars:
        try:
            zf = zipfile.ZipFile(j)
        except Exception:
            continue
        for n in zf.namelist():
            if not n.endswith(".class") or "$" in n:
                continue
            fqn = n[:-6].replace("/", ".")
            _JAR_INDEX.setdefault(fqn.split(".")[-1], fqn)
    return _JAR_INDEX


def javap_public(classes):
    jar = hutool_jar()
    if not jar:
        return None
    idx = jar_index()
    fqns = sorted({c if "." in c else idx.get(c, c) for c in classes})
    out = run('"%s" -cp "%s" -public %s' % (JAVAP, jar, " ".join(fqns)))
    return re.findall(r"public static [^(]+\b(\w+)\s*\(", out) + re.findall(r"public [^(]+\b(\w+)\s*\(", out)


def missing_classes(classes):
    idx = jar_index()
    return [c for c in classes if "." not in c and c not in idx]


def classes_for(pkg):
    """从 spec 的"hutool 对位"列里取类名（只取简单名，不猜包路径）。"""
    d = os.path.join(PKG_SPEC, "00-hutool-map.md")
    row = None
    for f in glob.glob(os.path.join(PKG_SPEC, "*.md")):
        s = io.open(f, encoding="utf-8", errors="replace").read()
        m = re.search(r"^\|\s*`%s`\s*\|[^\n]*$" % pkg, s, re.M)
        if m:
            row = m.group(0)
            break
    if not row:
        s = io.open("docs/ROADMAP.md", encoding="utf-8", errors="replace").read()
        for line in s.splitlines():
            if line.startswith("| `%s` |" % pkg):
                row = line
                break
    if not row:
        return []
    cells = [c.strip() for c in row.split("|")]
    if len(cells) < 3:
        return []
    cell = cells[2]
    # 全限定名（cron 那行写的是 cn.hutool.cron.pattern.CronPattern）取最后一段；再兜简单名
    got = re.findall(r"cn\.hutool[\w.]*\.([A-Z]\w+)", cell)
    got += re.findall(r"\b([A-Z][A-Za-z0-9]{2,}(?:Util|Pattern|Unit|Matcher|Reader|Writer|Filter|Loader|Parser|Builder|Convert|String|Map|Props))\b", cell)
    return sorted(set(got))


def main():
    do_javap = "--javap" in sys.argv
    list_mode = "--list" in sys.argv
    cskip = 0
    lists = []
    byp, raw = coverage_by_pkg()
    if not byp:
        print("覆盖率一格没取到数（判据先自证：`moon coverage analyze` 是否真跑了）")
        print(raw[-400:])
    pkgs = sorted({os.path.dirname(p).replace("\\", "/") for p in glob.glob("*/moon.pkg")})
    print("%-10s %6s %8s %10s  %s" % ("包", "未覆盖", "raise口", "变体 点名/总",
                                     "对位比对（参照公开件 / 本库公开件 / 名参照无 / 参照有名库无）"))
    for pkg in pkgs:
        unc = sum(len(rows) for _, rows in byp.get(pkg, []))
        impl, nvar, named = raise_sites(pkg)
        note = ""
        if do_javap and not JAVAP:
            note = "对位格 SKIP：找不到 javap（设 JAVAP_BIN 或把它放进 PATH）"
        elif do_javap:
            cls = classes_for(pkg)
            hp = javap_public(cls) if cls else None
            miss = missing_classes(cls)
            if miss:
                note += " [jar 里找不到类: %s]" % ",".join(miss)
            if not cls:
                note += " C 格 SKIP：spec/ROADMAP 那行没登记到参照类名"
                cskip += 1
            elif not hp:
                note += " C 格 SKIP：参照面取到空集（jar 里没有这些类或 javap 失败）⇒ 空表不等于零缺口，比值不算数"
                cskip += 1
            elif miss:
                note += " C 格 SKIP：对位类有 %d 个不在索引里，参照面不完整 ⇒ 比值不可信" % len(miss)
                cskip += 1
            else:
                ours = public_names(pkg)
                rlist = sorted({norm(m) for m in hp})
                core = [x for x in ours if not TRAIT_OPS.match(x)]
                extra = [x for x in core
                         if not any(same_name(norm(x), r) for r in rlist)]
                missing = [r for r in rlist
                           if r and not any(same_name(norm(x), r) for x in core)]
                note = "参照 %d / 本库 %d（trait 面另剔 %d）/ 名参照无 %d / 参照有名库无 %d" % (
                    len(set(hp)), len(ours), len(ours) - len(core), len(extra), len(missing))
                if list_mode:
                    lists.append((pkg, extra, missing[:24]))
        flag = "  <== 看" if unc or (nvar and named < nvar) else ""
        print("%-10s %6d %8d %6d/%-3d  %s%s" % (pkg, unc, impl, named, nvar, note, flag))
        for f, rows in byp.get(pkg, []):
            for ln, code in rows:
                print("           %s:%d  %s" % (f, ln, code[:78]))

    # 抽取器自证：matched 必须等于该 .mbti 的 pub fn 行数。少算＝静默失效（本仓已栽过一次：
    # 泛型形状整包漏抽，mapx 报 0、coll 报 1，那份"比值"因此骗了一轮）。
    if do_javap:
        broken = [(k, m, l) for k, (m, l) in sorted(EXTRACT_AUDIT.items()) if m != l]
        if not EXTRACT_AUDIT:
            print("抽取器自证 SKIP：本轮没走到 public_names（对位格一格没跑）")
        elif broken:
            print("抽取器自证 FAIL：%d 个包的件名数与 pub fn 行数不符 ⇒ C 格比值不可信" % len(broken))
            for k, m, l in broken:
                print("           %s 抽取 %d / 行 %d" % (k, m, l))
        else:
            print("抽取器自证 OK：%d 个包件名数 == pub fn 行数（阳性对照：三种行形状都认）" % len(EXTRACT_AUDIT))
        if cskip:
            print("C 格 SKIP %d 个包（参照类未登记 / jar 取不到 / 对位类不全）——这些包的比值本轮不算数" % cskip)
        if list_mode:
            for pkg, extra, missing in lists:
                print("\n### %s：本库名参照无 %d" % (pkg, len(extra)))
                print("    " + ", ".join(extra))
                print("### %s：参照有名库无 %d（截 24 条，判档前先对 `.mbti` 与 spec 现读）" % (pkg, len(missing)))
                print("    " + ", ".join(missing))


if __name__ == "__main__":
    main()
