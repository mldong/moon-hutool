#!/usr/bin/env python
# 未覆盖行棘轮（门禁 G15 的实现体）
#
# 为什么是棘轮而不是"补到达标"：覆盖率一放开就会漂回去——本仓的用法是每轮只推一格，
# 谁的包未覆盖行数**上升**谁就地解释。基线是**提交进仓的一件文件**（scripts/coverage_baseline.txt），
# 改基线必须单独一笔，和期望值冻结同一条纪律。
#
# 三档自证（缺一档这条判据就是许愿池）：
#   ① 用现基线跑 ⇒ 必须放行；
#   ② 把某个包的基线改成 现读数-1 ⇒ 必须报红（否则判据永真）；
#   ③ 解析到总未覆盖行数 == 0 且包数 > 0 时不报错，但**取不到任何数据**（`moon coverage analyze`
#      没跑或输出形状变了）⇒ 必须判 FAIL 并说明"覆盖率一格没取到数"，不许当"全覆盖了"放过。
#
# 用法：
#   python scripts/coverage_ratchet.py            # 检查（超基线退出 1）
#   python scripts/coverage_ratchet.py --write    # 重新生成基线（只许单独一笔）
#   python scripts/coverage_ratchet.py --selftest # 三档对照
import io
import os
import re
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = os.path.join(REPO, "scripts", "coverage_baseline.txt")
LINE_RE = re.compile(r"^(\d+) uncovered line\(s\) in (.+):$")


def measure():
    """跑 `moon coverage analyze`，返回 (每包未覆盖行数, 解析出的文件数, 原始输出)。"""
    r = subprocess.run("moon coverage analyze", shell=True,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    out = r.stdout.decode("utf-8", "replace").replace("\r", "")
    per = {}
    for line in out.splitlines():
        m = LINE_RE.match(line.strip())
        if not m:
            continue
        n = int(m.group(1))
        pkg = m.group(2).replace("\\", "/").split("/")[0]
        per[pkg] = per.get(pkg, 0) + n
    return per, len(per), out


def read_baseline():
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


def compare(per, base):
    """返回 (超基线的包, 低于基线的包)。基线里没有的包按 0 计——新包必须同笔登记基线。"""
    over = [(k, per[k], base.get(k, 0)) for k in per if per[k] > base.get(k, 0)]
    under = [(k, per[k], base.get(k, 0)) for k in per if per[k] < base.get(k, 0)]
    return sorted(over), sorted(under)


def selftest():
    global BASE
    per, nf, raw = measure()
    ok = 0
    if nf == 0:
        print("  SKIP 没有覆盖率数据（跑法：`moon test --target wasm --enable-coverage`），棘轮本轮无法自证")
        return 2
    base = read_baseline()
    if base is None:
        print("  FAIL 基线文件缺失：%s" % BASE)
        return 0
    # ① 现基线必须放行
    over, under = compare(per, base)
    if not over:
        ok += 1
    else:
        print("  FAIL 自检①：现基线之下就已经超了 %d 个包（%s）" % (len(over), over[0]))
    # ② 把最厚的那个包基线压到 现读-1，必须报红
    thick = max(per, key=lambda k: per[k])
    probe = dict(base)
    probe[thick] = per[thick] - 1
    over2, _ = compare(per, probe)
    if over2 and over2[0][0] == thick:
        ok += 1
    else:
        print("  FAIL 自检②：基线压到 现读-1 却没报红（判据对最厚的 %s 失效）" % thick)
    # ③ 基线整张缺失 ⇒ 不许给出"通过"
    if not os.path.exists(BASE):
        ok += 1
    else:
        tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".txt")
        tmp.write(b"# baseline\n"); tmp.close()
        keep, BASE = BASE, tmp.name
        missing_ok = compare({"zzz": 3}, read_baseline() or {})[0]
        BASE = keep
        os.unlink(tmp.name)
        if missing_ok:
            ok += 1
        else:
            print("  FAIL 自检③：空基线之下没判红——新包的未覆盖行会一路静默")
    return ok


def main():
    os.chdir(REPO)
    if "--write" in sys.argv:
        per, nf, raw = measure()
        if nf == 0:
            print("  SKIP 没有覆盖率数据，基线不生成（空基线会让棘轮永真）")
            return 2
        with io.open(BASE, "w", encoding="utf-8", newline="\n") as f:
            f.write("# 未覆盖行棘轮基线 —— 由 `python scripts/coverage_ratchet.py --write` 生成，勿手改\n")
            f.write("# 现读命令：moon coverage analyze（要先 moon test --target wasm --enable-coverage）\n")
            f.write("# 收紧（数字变小）随时可以；放宽或新增包的条目必须单独一笔并写明是哪条通道补/加了\n")
            for k in sorted(per):
                f.write("%s = %d\n" % (k, per[k]))
        print("  OK 基线已生成：%d 个包，合计 %d 行" % (nf, sum(per.values())))
        return 0
    if "--selftest" in sys.argv:
        n = selftest()
        if n == 3:
            print("  PASS 棘轮三档对照全过（现基线放行 / 压基线必红 / 空基线必红）")
            return 0
        print("  FAIL 棘轮自检只有 %d/3 档通过 ⇒ 这条判据不可信" % n)
        return 1
    per, nf, raw = measure()
    if nf == 0:
        print("  SKIP 覆盖率一格没取到数（跑法：`moon test --target wasm --enable-coverage`）——不当通过，也不当红")
        return 2
    base = read_baseline()
    if base is None:
        print("  FAIL 缺基线文件 scripts/coverage_baseline.txt（先 --write 生成并单独一笔提交）")
        return 1
    over, under = compare(per, base)
    total = sum(per.values())
    if over:
        for k, now, lim in over:
            print("  FAIL %s 未覆盖行 %d > 基线 %d（+%d）⇒ 要么补用例，要么单独一笔写清为什么不补" % (k, now, lim, now - lim))
        return 1
    if under:
        print("  INFO 有 %d 个包未覆盖行数低于基线（%s），合计未覆盖 %d 行" % (
            len(under), ", ".join("%s %d→%d" % (k, lim, now) for k, now, lim in under), total))
        print("  INFO 建议同笔或另笔 `python scripts/coverage_ratchet.py --write` 把基线收紧（只许前进方向收紧）")
    print("  PASS 未覆盖行棘轮：%d 个包合计 %d 行，均不高于基线" % (nf, total))
    return 0


if __name__ == "__main__":
    sys.exit(main())
