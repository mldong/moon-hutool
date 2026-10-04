#!/usr/bin/env python3
"""状态读数生成 + 一致性检查（门禁 G11）。

治的根因：**状态数字不许手写**。手写就要靠人记得改，包一多必漏（本轮 text 转绿后三处文档还写着
"实现未开工"，是 owner 逐条点出来的——这种靠人点的机制不算机制）。

三件事：
1. **生成**：把当场 `moon test --package` 的读数写进 README.md 与 docs/ROADMAP.md 的
   `READINGS:BEGIN/END` 标记块里（`--write`），人不再抄数字；
2. **校验**（`--check`，CI 与 pre-commit 用）：
   a. 标记块内容与重新生成的一致（有人手改了数字 → 红）；
   b. `docs/ROADMAP.md` 的逐包表**必须覆盖每个真实存在的包**（新包没登记 → 红），
      且每行的状态词与当场读数一致（绿了写"未开工"、没绿写"已实现" → 红，双向）；
   c. 包内文档（`README.mbt.md` / `*_test.mbt` / `docs/spec/NN-<pkg>.md`）的状态措辞与读数不冲突；
  d. **`docs/spec/NN-<pkg>.md` 的 NN 必须等于该包在逐包表里的行号**（门禁 G13，号是稳定 ID 不是排名）。

用法：
  python scripts/sync_status.py --write    # 生成/刷新读数块
  python scripts/sync_status.py --check    # 只校验，不写（要跑逐包用例，稍慢）
  python scripts/sync_status.py --numbers  # 只查序号一致性（不跑 moon，秒级）
  python scripts/sync_status.py --selftest # 判据自检（坏样本必须被抓到）
"""

import glob
import io
import os
import re
import subprocess
import sys

MOD = "mldong/moon-hutool"
BEGIN = "<!-- READINGS:BEGIN 由 scripts/sync_status.py 生成，勿手改 -->"
END = "<!-- READINGS:END -->"
STATE_DONE = "已实现"
STATE_FROZEN = "契约已冻结"
STATE_TODO = "未开工"
NOT_DONE = re.compile(r"实现未开工|预期全红|预期红|函数体是 `abort`|函数体 `abort`")
CLAIM_DONE = re.compile(r"已实现|全绿")
ROW = re.compile(r"^\|\s*`([a-z0-9_-]+)`\s*\|")


def os_root():
    return subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                          text=True, encoding="utf-8", errors="replace").stdout.strip()


def packages():
    """真实存在的包 = 有 moon.pkg 的目录。"""
    out = subprocess.run(["git", "ls-files", "*/moon.pkg"], capture_output=True, text=True,
                         encoding="utf-8", errors="replace").stdout
    pkgs = []
    for line in out.splitlines():
        d = os.path.dirname(line)
        if d and not d.startswith(("_build", "docs", "scripts", ".github")):
            pkgs.append(d)
    return sorted(set(pkgs))


def has_tests(pkg):
    return bool(glob.glob(os.path.join(pkg, "*_test.mbt")) or glob.glob(os.path.join(pkg, "*_wbtest.mbt"))
                or glob.glob(os.path.join(pkg, "README.mbt.md")))


def read_state(pkg):
    """跑一个包的用例，返回 (状态词, total, passed, failed)。"""
    if not has_tests(pkg):
        return STATE_TODO, 0, 0, 0
    r = subprocess.run(["moon", "test", "--package", "{}/{}".format(MOD, pkg), "--target", "wasm"],
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    txt = (r.stdout or "") + (r.stderr or "")
    m = re.search(r"Total tests: (\d+), passed: (\d+), failed: (\d+)", txt)
    if not m:
        return "读数缺失", 0, 0, 0
    total, passed, failed = (int(x) for x in m.groups())
    if total == 0:
        return STATE_TODO, 0, 0, 0
    return (STATE_DONE if failed == 0 else STATE_FROZEN), total, passed, failed


def collect():
    return [(p,) + read_state(p) for p in packages()]


def block(rows):
    done = sum(1 for r in rows if r[1] == STATE_DONE)
    frozen = sum(1 for r in rows if r[1] == STATE_FROZEN)
    todo = sum(1 for r in rows if r[1] == STATE_TODO)
    t = sum(r[2] for r in rows)
    g = sum(r[3] for r in rows)
    f = sum(r[4] for r in rows)
    lines = [
        "| 读数（`moon test --target wasm`，当场跑） | 值 |",
        "|---|---|",
        "| 用例总数 | **{}** —— 绿 {} / 红 {} |".format(t, g, f),
        "| 包状态 | 共 {} 个：`{}` {} · `{}` {} · `{}` {} |".format(len(rows), STATE_DONE, done, STATE_FROZEN, frozen, STATE_TODO, todo),
    ]
    if f:
        lines.append("| 红的是谁 | " + "、".join(
            "`{}`（{} 红）".format(p, ff) for p, st, tt, pp, ff in rows if ff) + " —— 未实现的包红是设计态 |")
    return "\n".join(lines)


def render(path, rows):
    text = io.open(path, encoding="utf-8").read()
    if BEGIN not in text or END not in text:
        return None
    head, rest = text.split(BEGIN, 1)
    _, tail = rest.split(END, 1)
    return head + BEGIN + "\n" + block(rows) + "\n" + END + tail


def doc_files(pkg):
    return (glob.glob("{}/*.md".format(pkg)) + glob.glob("{}/*_test.mbt".format(pkg))
            + glob.glob("docs/spec/*-{}.md".format(pkg)))


def wording_findings(rows):
    bad = []
    for pkg, state, _t, _p, _f in rows:
        green = state == STATE_DONE
        for f in doc_files(pkg):
            for i, line in enumerate(io.open(f, encoding="utf-8", errors="replace").read().splitlines(), 1):
                if green and NOT_DONE.search(line):
                    bad.append("{}:{} 已全绿却写「未开工/预期红」".format(f, i))
                if not green and state != STATE_TODO and CLAIM_DONE.search(line):
                    bad.append("{}:{} 未全绿却写「已实现/全绿」".format(f, i))
    return bad


def roadmap_findings(rows):
    """逐包表：每个真实包必须有一行，且状态词与读数一致。"""
    path = os.path.join(os.getcwd(), "docs", "ROADMAP.md")
    if not os.path.isfile(path):
        return ["缺 docs/ROADMAP.md"]
    text = io.open(path, encoding="utf-8").read()
    stated = {}
    for line in text.splitlines():
        m = ROW.match(line)
        if m:
            pkg = m.group(1)
            cell = [c.strip() for c in line.strip().strip("|").split("|")]
            stated[pkg] = cell[2] if len(cell) > 2 else ""
    bad = []
    for pkg, state, _t, _p, _f in rows:
        if pkg not in stated:
            bad.append("包 `{}` 在 ROADMAP 逐包表里没有行（新包必须登记）".format(pkg))
            continue
        s = stated[pkg]
        if state == STATE_DONE and STATE_DONE not in s:
            bad.append("`{}` 已全绿，ROADMAP 状态却写「{}」".format(pkg, s[:24]))
        if state == STATE_FROZEN and STATE_DONE in s:
            bad.append("`{}` 还有红用例，ROADMAP 状态却写「{}」".format(pkg, s[:24]))
        if state == STATE_TODO and (STATE_DONE in s or STATE_FROZEN in s):
            bad.append("`{}` 没有任何用例，ROADMAP 状态却写「{}」".format(pkg, s[:24]))
    return bad


def roadmap_rows():
    """按出现顺序返回逐包表的 [(包名, 契约列)]——这个顺序就是包的**序号权威**。"""
    path = os.path.join(os.getcwd(), "docs", "ROADMAP.md")
    if not os.path.isfile(path):
        return []
    rows = []
    for line in io.open(path, encoding="utf-8", errors="replace").read().splitlines():
        m = ROW.match(line)
        if m:
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            rows.append((m.group(1), cells[3] if len(cells) > 3 else ""))
    return rows


def spec_files():
    d = os.path.join(os.getcwd(), "docs", "spec")
    return sorted(f for f in os.listdir(d) if f.endswith(".md")) if os.path.isdir(d) else []


def number_findings(rows, files):
    """spec 文件名序号必须等于该包在逐包表里的行号（门禁 G13）。

    为什么值得钉：号一旦与表序各漂各的，读者就只能猜哪个是真的（本轮就是这么被撞——01/02/05 对
    text/digest/date）。定成**稳定 ID**：包挪进「暂不做」也不改号，号发过就不再动，只有新增包时
    按行号往后编。
    """
    want = {}
    for i, (pkg, _cell) in enumerate(rows, 1):
        want[pkg] = "%02d-%s.md" % (i, pkg)
    bad = []
    for i, (pkg, cell) in enumerate(rows, 1):
        for ref in re.findall(r"docs/spec/([0-9A-Za-z_.\-]+\.md)", cell):
            if ref != want[pkg]:
                bad.append("逐包表第 {} 行是 `{}`，契约列却指向 docs/spec/{}（应为 {}）".format(
                    i, pkg, ref, want[pkg]))
    for f in files:
        if f == "00-hutool-map.md":
            continue
        m = re.match(r"^(\d{2})-([a-z0-9_\-]+)\.md$", f)
        if not m:
            bad.append("docs/spec/{} 不合 `NN-<pkg>.md` 命名（NN＝该包在逐包表里的行号）".format(f))
            continue
        pkg = m.group(2)
        if pkg not in want:
            bad.append("docs/spec/{} 的包 `{}` 在逐包表里没有行".format(f, pkg))
        elif want[pkg] != f:
            idx = [p for p, _c in rows].index(pkg) + 1
            bad.append("包 `{}` 在逐包表里是第 {} 行，spec 文件却叫 {}（应为 {}）".format(
                pkg, idx, f, want[pkg]))
    return bad


def selftest():
    """判据自检：坏读数与坏序号都必须被识别。"""
    ok = (bool(NOT_DONE.search("> 当前状态：实现未开工，函数体是 `abort`"))
          and bool(CLAIM_DONE.search("| `text` | x | **已实现**（10-04） |"))
          and ROW.match("| `text` | `StrUtil` | 已实现 | a | b |") is not None
          and not NOT_DONE.search("这里只是解释 abort 这个函数怎么用：`abort(\"x\")`"))
    # 序号判据的阳性对照：表说 digest 在第 2 行、文件却叫 05-digest.md ⇒ 必须报两条（列与文件各一条）
    probe_rows = [("text", "`docs/spec/01-text.md`"), ("digest", "`docs/spec/05-digest.md`"),
                  ("date", "—")]
    probe_bad = number_findings(probe_rows, ["01-text.md", "05-digest.md", "03-date.md"])
    # 以及一条全对的样本，确认判据不会乱报
    probe_ok = number_findings([("text", "`docs/spec/01-text.md`"), ("digest", "—")],
                               ["00-hutool-map.md", "01-text.md"])
    ok = ok and len(probe_bad) == 2 and not probe_ok
    print("  PASS 自检：措辞、表格行、序号三条识别规则都对得上" if ok else
          "  FAIL 自检失效（坏样本抓到 {} 条，应 2 条；好样本误报 {} 条）".format(
              len(probe_bad), len(probe_ok)))
    return 0 if ok else 1


def numbers_only():
    """G13：只查序号一致性（不跑 moon，秒级）。"""
    bad = number_findings(roadmap_rows(), spec_files())
    if bad:
        print("  FAIL spec 序号与逐包表行号不一致（{} 处）：".format(len(bad)))
        for b in bad:
            print("    ", b)
        return 1
    print("  PASS docs/spec/NN-<pkg>.md 的 NN 与逐包表行号一一对应")
    return selftest() if "--selftest" in sys.argv else 0


def main():
    os.chdir(os_root())
    if "--selftest" in sys.argv:
        return selftest()
    if "--numbers" in sys.argv:
        return numbers_only()
    rows = collect()
    targets = ["README.md", os.path.join("docs", "ROADMAP.md")]
    if "--write" in sys.argv:
        for t in targets:
            out = render(t, rows)
            if out is None:
                print("  SKIP {} 没有 READINGS 标记块".format(t))
                continue
            io.open(t, "w", encoding="utf-8", newline="\n").write(out)
            print("  写 {}".format(t))
        return 0
    bad = []
    for t in targets:
        out = render(t, rows)
        if out is None:
            bad.append("{} 缺 READINGS 标记块（数字会被手写）".format(t))
        elif out != io.open(t, encoding="utf-8").read():
            bad.append("{} 的读数块与当场跑出来的不一致 → 跑 `python scripts/sync_status.py --write`".format(t))
    bad += roadmap_findings(rows)
    bad += wording_findings(rows)
    bad += number_findings(roadmap_rows(), spec_files())
    for pkg, state, t, g, f in rows:
        print("  INFO {:8s} {:12s} 用例 {:>3} 绿 {:>3} 红 {:>3}".format(pkg, state, t, g, f))
    if bad:
        print("  FAIL 状态读数不一致/未生成（{} 处）：".format(len(bad)))
        for b in bad[:12]:
            print("    ", b)
        return 1
    print("  PASS 读数块、逐包表、包内措辞三者与当场读数一致")
    return selftest()


if __name__ == "__main__":
    sys.exit(main())
