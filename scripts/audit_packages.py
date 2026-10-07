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
# 用法：python scripts/audit_packages.py [--javap]
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
        for m in re.finditer(r"\braise\s+([A-Z][A-Za-z0-9_]*)", s):
            impl += 1
            variants.add(m.group(1))
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
    p = os.path.join(pkg, "pkg.generated.mbti")
    if not os.path.exists(p):
        return []
    s = io.open(p, encoding="utf-8", errors="replace").read()
    names = re.findall(r"^pub fn ([a-zA-Z0-9_]+)\(", s, re.M)
    names += re.findall(r"^pub fn [A-Za-z]+::([a-zA-Z0-9_]+)\(", s, re.M)
    return sorted(set(names))


_JAR_INDEX = {}


def jar_index():
    """简单类名 -> 全限定名。javap 只认 FQN，喂 `DateUtil` 会静默查不到类、
    返回空表——空表在上一版被当成"参照没有这个方法"，是判据的假阴性。"""
    if _JAR_INDEX:
        return _JAR_INDEX
    import zipfile
    for j in sorted(glob.glob(os.path.join(JARS, "*.jar"))):
        if j.endswith("-sources.jar") or "-src" in os.path.basename(j):
            continue
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
    jar = os.path.join(JARS, "hutool-core.jar")
    if not os.path.exists(jar):
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
    byp, raw = coverage_by_pkg()
    if not byp:
        print("覆盖率一格没取到数（判据先自证：`moon coverage analyze` 是否真跑了）")
        print(raw[-400:])
    pkgs = sorted({os.path.dirname(p).replace("\\", "/") for p in glob.glob("*/moon.pkg")})
    print("%-10s %6s %8s %10s  %s" % ("包", "未覆盖", "raise口", "变体 点名/总", "对位比对（参照公开件 / 本库公开件 / 本库名参照无）"))
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
            if hp:
                ours = public_names(pkg)
                hn = {norm(x) for x in hp}
                on = {norm(x) for x in ours}
                rlist = sorted({norm(m) for m in hp})
                extra = [x for x in ours
                         if not any(same_name(norm(x), r) for r in rlist)]
                note = "参照 %d / 本库 %d / 本库名参照无 %d" % (len(set(hp)), len(ours), len(extra))
        flag = "  <== 看" if unc or (nvar and named < nvar) else ""
        print("%-10s %6d %8d %6d/%-3d  %s%s" % (pkg, unc, impl, named, nvar, note, flag))
        for f, rows in byp.get(pkg, []):
            for ln, code in rows:
                print("           %s:%d  %s" % (f, ln, code[:78]))


if __name__ == "__main__":
    main()
