#!/usr/bin/env python
# 死格形状扫描（门禁 G17 的实现体）
#
# 起因：`path_test.mbt` 有 49 条断言把参照的**期望值字面串**（"true"/"false"）填进了 pattern 实参位，
# 形如 `match_start_with("false", "/?/cde", opts)`。这类断言恒绿（拿 "false" 当模式匹配任何真实路径
# 当然给 false），却占着"这条判据有夹具"的位置——path 与参照的 10 处分岔就是这么潜伏下来的。
#
# 判据形状：**棘轮**而不是清零。现存 49 条是既有债务，逐条回问原始意图要单独一笔（见
# docs/spec/15-path.md §7.2）；本格先钉住"不许再增加"，随更正笔逐格下降。基线文件提交进仓。
#
# 三档自证：① 现基线放行；② 计数上升（往临时文件里加一条坏样本）必须报红；
#           ③ 扫描面为空 ⇒ SKIP，绝不给出"零死格"的通过（"取不到数就当过"那一族）。
#
# 用法：--write 生成基线 / --selftest 三档对照 / 默认检查（上升退出 1，无数据退出 2）
import io
import os
import re
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = os.path.join(REPO, "scripts", "vacuous_baseline.txt")
# 只认"位置实参位上是 true/false 字面串"这一形状；注释与右侧期望位不算
PAT = re.compile(r'(?:match|extract)[a-z_]*\(\s*"(?:true|false)"')


def files():
    out = subprocess.run("git ls-files", shell=True, cwd=REPO,
                         stdout=subprocess.PIPE).stdout.decode("utf-8", "replace")
    return [f.replace("\r", "").strip() for f in out.splitlines()
            if f.endswith(("_test.mbt", ".mbt.md"))]


def scan(paths=None):
    per = {}
    for f in paths if paths is not None else files():
        p = os.path.join(REPO, f)
        if not os.path.exists(p):
            continue
        n = len(PAT.findall(io.open(p, encoding="utf-8", errors="replace").read()))
        if n:
            per[f] = per.get(f, 0) + n
    return per


def read_base():
    if not os.path.exists(BASE):
        return None
    d = {}
    for line in io.open(BASE, encoding="utf-8"):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        k, v = line.split("=")
        d[k.strip()] = int(v.strip())
    return d


def main():
    os.chdir(REPO)
    fs = files()
    if not fs:
        print("  SKIP 扫描面为空（git ls-files 没拿到测试文件）⇒ 这条判据本轮不算数")
        return 2
    per = scan(fs)
    total = sum(per.values())
    if "--write" in sys.argv:
        with io.open(BASE, "w", encoding="utf-8", newline="\n") as f:
            f.write("# 死格形状基线（scripts/vacuous_assert.py --write 生成，勿手改）\n")
            f.write("# 只许降：每更正一条死格，随笔 --write 收紧；上升即 G17 报红\n")
            for k in sorted(per):
                f.write("%s = %d\n" % (k, per[k]))
        print("  OK 基线已生成：扫描面 %d 个文件，命中 %d 处（分文件见基线）" % (len(fs), total))
        return 0
    if "--selftest" in sys.argv:
        ok = 0
        base = read_base()
        if base is None:
            print("  FAIL 自检：缺基线文件")
            return 1
        if total <= sum(base.values()):
            ok += 1
        else:
            print("  FAIL 自检①：现基线之下就已经超标")
        probe = tempfile.NamedTemporaryFile("w", delete=False, suffix="_test.mbt", encoding="utf-8")
        probe.write('test "x" {\n  assert_eq(@p.match_path_with("false", "/a", o), true)\n}\n')
        probe.close()
        hit = scan([probe.name])
        os.unlink(probe.name)
        if hit:
            ok += 1
        else:
            print("  FAIL 自检②：坏样本没被抓到 ⇒ 这条判据是摆设")
        if scan([]) == {} and not files():
            print("  FAIL 自检③：扫描面判空逻辑可疑")
        else:
            ok += 1
        if ok == 3:
            print("  PASS 三档对照全过（现基线放行 / 坏样本必被抓 / 空面不判通过）")
            return 0
        print("  FAIL 自检只有 %d/3 档通过 ⇒ 这条判据不可信" % ok)
        return 1
    base = read_base()
    if base is None:
        print("  FAIL 缺基线文件 scripts/vacuous_baseline.txt（先 --write 并单独一笔提交）")
        return 1
    worse = [(f, n, base.get(f, 0)) for f, n in per.items() if n > base.get(f, 0)]
    if worse:
        for f, n, lim in worse:
            print("  FAIL %s 的死格形状 %d 处 > 基线 %d ⇒ 新写的断言把期望值放进了实参位" % (f, n, lim))
        return 1
    lower = [(f, per[f], base[f]) for f in base if per.get(f, 0) < base[f]]
    if lower:
        print("  INFO 已减少：%s ⇒ 建议同笔或另笔 --write 收紧基线" %
              ", ".join("%s %d→%d" % (f, base[f], per.get(f, 0)) for f in sorted(lower)))
    print("  PASS 死格形状棘轮：扫描面 %d 个文件，命中 %d 处，均不高于基线" % (len(fs), total))
    return 0


if __name__ == "__main__":
    sys.exit(main())
