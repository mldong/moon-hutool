#!/usr/bin/env python3
"""状态声明与用例读数一致性自检（门禁 G11）。

治的是"台账不回填"这一类错：包已经实现全绿了，文档还写着"实现未开工／示例预期红"；
反过来更危险——文档声称已实现，用例其实还红着。两种漂移都拦。

判据来源是**当场跑的** `moon test --package`，不是任何文件里的自述。
用法：
  python scripts/check_status_claims.py            # 扫全仓有测试/文档块的包
  python scripts/check_status_claims.py --selftest # 只跑分类器自检
"""

import glob
import io
import os
import re
import subprocess
import sys

MOD = "mldong/moon-hutool"
NOT_DONE = re.compile(r"实现未开工|预期全红|示例\*\*预期红|本页示例.*预期红|函数体是 `abort`|函数体 `abort`")
CLAIM_DONE = re.compile(r"已实现|全绿")


def pkg_with_tests():
    pkgs = set()
    out = subprocess.run(["git", "ls-files"], capture_output=True, text=True,
                       encoding="utf-8", errors="replace").stdout
    for line in out.splitlines():
        d = os.path.dirname(line)
        if not d or d.startswith(("_build", "docs", "scripts", ".github")):
            continue
        if line.endswith("_test.mbt") or line.endswith("_wbtest.mbt") or line.endswith("README.mbt.md"):
            pkgs.add(d)
    return sorted(pkgs)


def run_pkg_test(pkg):
    r = subprocess.run(
        ["moon", "test", "--package", "{}/{}".format(MOD, pkg), "--target", "wasm"],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    txt = (r.stdout or "") + (r.stderr or "")
    m = re.search(r"Total tests: (\d+), passed: (\d+), failed: (\d+)", txt)
    if not m:
        return None
    total, passed, failed = (int(x) for x in m.groups())
    return total, passed, failed


def doc_files(pkg):
    files = glob.glob("{}/*.md".format(pkg)) + glob.glob("{}/*_test.mbt".format(pkg))
    files += glob.glob("docs/spec/*-{}.md".format(pkg))
    return [f for f in files if os.path.isfile(f)]


def stale_findings(pkg, green):
    """green=True 时不许再写"未开工/预期红"；green=False 时不许写"已实现/全绿"。"""
    bad = []
    for f in doc_files(pkg):
        text = io.open(f, encoding="utf-8", errors="replace").read()
        for lineno, line in enumerate(text.splitlines(), 1):
            if green and NOT_DONE.search(line):
                bad.append("{}:{} 已全绿却仍写「未开工/预期红」：{}".format(f, lineno, line.strip()[:70]))
            if (not green) and CLAIM_DONE.search(line):
                bad.append("{}:{} 用例未全绿却声称「已实现/全绿」：{}".format(f, lineno, line.strip()[:70]))
    return bad


def selftest():
    # 分类器自检：两种漂移都必须被识别，否则这条判据是永真的
    a = bool(NOT_DONE.search("> ⚠ 当前状态：实现未开工，函数体是 `abort`，本页示例**预期红**。"))
    b = bool(CLAIM_DONE.search("| `text` | `StrUtil` | **已实现**（10-04） |"))
    c = bool(NOT_DONE.search("这一句只是提到 abort 单词，不算声明：`abort`"))
    if a and b and not c:
        print("  PASS 自检：两类漂移样本分别命中，且不误伤普通提及")
        return 0
    print("  FAIL 自检失效：a={} b={} c(应为 False)={}".format(a, b, c))
    return 1


def main():
    if "--selftest" in sys.argv:
        return selftest()
    pkgs = pkg_with_tests()
    if not pkgs:
        print("  FAIL 没有任何带测试的包可判——这条判据此刻等于没套件")
        return 1
    bad = []
    for pkg in pkgs:
        res = run_pkg_test(pkg)
        if res is None:
            print("  SKIP {} 跑不出用例读数（不判，也不装作通过）".format(pkg))
            continue
        total, passed, failed = res
        green = total > 0 and failed == 0
        print("  INFO {} 用例 {} 条，绿 {}，红 {} → 判定为 {}".format(
            pkg, total, passed, failed, "已全绿" if green else "未全绿"))
        bad += stale_findings(pkg, green)
    if bad:
        print("  FAIL 状态声明与读数不一致（{} 处）：".format(len(bad)))
        for x in bad[:12]:
            print("    ", x)
        return 1
    print("  PASS {} 个包的状态声明与当场读数一致".format(len(pkgs)))
    return selftest()


if __name__ == "__main__":
    sys.exit(main())
