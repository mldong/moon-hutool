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

TRACKED = None


def tracked_paths():
    """仓内真相 = git 跟踪的文件清单。

    不用 `os.path.exists`：那条判据在两处会骗人——① 本地有、没提交的文件照样"可达"（克隆出去就是死链）；
    ② Windows 的路径规则会把 `...` 这类不像路径的串当存在（本机绿、Linux CI 红，本轮就是这么撞的）。
    """
    global TRACKED
    if TRACKED is None:
        out = subprocess.run(["git", "ls-files"], capture_output=True, text=True,
                             encoding="utf-8", errors="replace")
        TRACKED = set(l.strip().replace("\\", "/") for l in out.stdout.splitlines() if l.strip())
    return TRACKED


def strip_code(text):
    """去掉围栏代码块与行内反引号：代码散文里的 `[A](...)` 不是 markdown 链接（AGENTS 的语法坑就是这么写的）"""
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    return re.sub(r"`[^`\n]*`", "", text)


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
    have = tracked_paths()
    for f in files:
        try:
            text = io.open(f, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        for m in LINK.finditer(strip_code(text)):
            internal, path = resolve(m.group(1), f)
            if not internal or not path:
                continue
            if path.replace("\\", "/") not in have:
                dead.append("{} -> {}".format(f, m.group(1)))
    return dead


SELFTEST = """# probe
[相对死链](docs/spec/__no_such__.md)
[绝对死链](https://github.com/{repo}/blob/master/text/__no_such__.mbt)
[外部链接不算死链](https://mooncakes.io/docs/mldong/moon-hutool/text)
[指向本地未提交文件]({ghost})
 代码散文里的这个形状不算链接：`fn shape[A](__no_such_in_code__)`
"""


def selftest():
    probe = "_g10_probe.md"
    ghost = "_g10_ghost.md"  # 存在于工作树、没进 git ⇒ 克隆出去就是死链
    io.open(ghost, "w", encoding="utf-8").write("# ghost\n")
    io.open(probe, "w", encoding="utf-8").write(
        SELFTEST.format(repo=REPO, ghost=ghost))
    try:
        dead = scan([probe])
    finally:
        os.remove(probe)
        os.remove(ghost)
    # 三条坏样本都要抓到；且代码散文里的 `[A](...)` 形状不许变成假阳性
    want = ("docs/spec/__no_such__.md", "text/__no_such__.mbt", ghost)
    hit = [w for w in want if any(w in d for d in dead)]
    fp = [d for d in dead if "__no_such_in_code__" in d]
    if len(hit) == 3 and not fp:
        print("  PASS 自检：3 条死链样本都抓到（含「本地有但没提交」那一档），代码散文没误判")
        return 0
    print("  FAIL 自检失效：抓到 {} 条（应含 {}），代码内误判 {} 条：{}".format(
        len(dead), list(want), len(fp), dead))
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
