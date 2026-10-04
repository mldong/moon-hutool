#!/usr/bin/env python3
"""仓内文档链接自检（门禁 G10）。

两条规则：
1. 指向本仓文件的链接必须真的存在——既查 GitHub 绝对地址（发布页只认这种写法），
   也查相对写法（GitHub 上能点，但按 AGENTS 的规定本仓不该再用，出现就顺手报出来）；
2. 自检：喂它一个含死链的样本，必须被抓到，否则这条判据本身不可信（恒绿的空套件比红灯更危险）。

用法：
  python scripts/check_doc_links.py            # 扫全仓跟踪的 .md
  python scripts/check_doc_links.py --selftest # 只跑阳性对照
"""

import io
import os
import re
import subprocess
import sys

REPO = "mldong/moon-hutool"
LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)")


def tracked_md():
    out = subprocess.run(
        ["git", "ls-files", "*.md"], capture_output=True, text=True
    )
    return [l for l in out.stdout.splitlines() if l and not l.startswith("_build/")]


def resolve(target, base_file):
    """返回 (是否仓内文件链接, 本地路径)；外部链接与纯锚点返回 (False, None)。"""
    if target.startswith("#") or target.startswith("mailto:"):
        return False, None
    if target.startswith("http://") or target.startswith("https://"):
        if "/blob/" in target and REPO in target:
            tail = target.split("/blob/", 1)[1]
            # <branch>/<path>  去掉锚点
            path = tail.split("/", 1)[1] if "/" in tail else ""
            return True, path.split("#", 1)[0]
        return False, None
    if target.startswith("/"):
        return True, target.lstrip("/")
    return True, os.path.normpath(os.path.join(os.path.dirname(base_file), target))


def scan(files):
    dead = []
    for f in files:
        try:
            text = io.open(f, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        for m in LINK.finditer(text):
            internal, path = resolve(m.group(1), f)
            if not internal or not path:
                continue
            if not os.path.exists(path):
                dead.append("{} -> {}".format(f, m.group(1)))
    return dead


SELFTEST = """# probe
[相对死链](docs/spec/__no_such__.md)
[绝对死链](https://github.com/{repo}/blob/master/text/__no_such__.mbt)
[外部链接不算死链](https://mooncakes.io/docs/mldong/moon-hutool/text)
""".format(repo=REPO)


def selftest():
    probe = "_g10_probe.md"
    io.open(probe, "w", encoding="utf-8").write(SELFTEST)
    try:
        dead = scan([probe])
    finally:
        os.remove(probe)
    if len(dead) >= 2:
        print("  PASS 自检：2 条死链样本都被抓到（另有外部链接被正确放过）")
        return 0
    print("  FAIL 自检失效：只抓到 {} 条，这条判据不可信：{}".format(len(dead), dead))
    return 1


def main():
    if "--selftest" in sys.argv:
        return selftest()
    files = tracked_md()
    dead = scan(files)
    if dead:
        print("  FAIL 仓内文档有死链（{} 条）：".format(len(dead)))
        for d in dead[:10]:
            print("    ", d)
        return 1
    print("  PASS {} 份 md 里的仓内链接全部可达".format(len(files)))
    return selftest()


if __name__ == "__main__":
    sys.exit(main())
