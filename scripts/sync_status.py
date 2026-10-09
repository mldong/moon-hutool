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
  e. **根 `README.md` 的索引行不许逐包写状态**（括号里既点包名又点状态词的，必须等于当场读数；
     不指名包的状态口径词表放行）——本轮 date/id 转绿时那行索引就漂了，光扫包内文档看不见。

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
STATE_WORDS = ("已实现", "契约已冻结", "实现中", "未开工")
PAREN = re.compile(u"（([^）]*)）")


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


def pkg_token(name):
    """包名要整词匹配——`valid` 里含 `id`，裸子串会误点。"""
    return re.compile(r"(?<![a-z0-9_-])" + re.escape(name) + r"(?![a-z0-9_-])")


def index_findings_text(text, states):
    """根 README 的索引行不许逐包写状态。

    为什么值得钉：`docs/spec/NN-<pkg>.md`（date，契约已冻结）这种括号里的状态，包转绿后没人回来改——
    本轮 date/id 双双转绿时它就漂了。G11 原本只扫**包目录内**的文档与 spec 抬头，根 README 不在面上。
    规则：括号内同时点了某个包与某个状态词的，状态词必须等于当场读数；不指名包的（状态口径词表）放行。
    """
    bad = []
    inside = False
    for i, line in enumerate(text.splitlines(), 1):
        if BEGIN in line:
            inside = True
        if END in line:
            inside = False
            continue
        if inside:
            continue
        for seg in PAREN.findall(line):
            words = [w for w in STATE_WORDS if w in seg]
            if not words:
                continue
            hits = [n for n in states if pkg_token(n).search(seg)]
            if not hits:
                continue
            if len(hits) > 1 or len(words) > 1:
                bad.append("README.md:%d 一个括号里点了 %d 个包 / %d 个状态词，读数没法核：%s"
                           % (i, len(hits), len(words), seg[:40]))
                continue
            pkg, stated = hits[0], words[0]
            if stated != states[pkg]:
                bad.append("README.md:%d 给 `%s` 写了「%s」，当场读数是「%s」→ 索引行别写状态，"
                           "状态只看生成的读数块与 ROADMAP" % (i, pkg, stated, states[pkg]))
    return bad


def index_findings(rows):
    states = dict((p, st) for p, st, _t, _g, _f in rows)
    if not os.path.isfile("README.md"):
        return ["缺 README.md"]
    return index_findings_text(io.open("README.md", encoding="utf-8").read(), states)


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


def log_files():
    d = os.path.join("docs", "roadmap-log")
    return sorted(f for f in os.listdir(d)) if os.path.isdir(d) else []


def roadmap_case_cells():
    """按出现顺序返回逐包表的 [(行号, 包名, 用例列)]。

    `roadmap_rows()` 只给到**契约列**（那是 G13 第一半要看的东西），详记链接在第 5 列，
    所以这里另取一列——别改 roadmap_rows 的返回形状，别处按三列在用。
    """
    path = os.path.join(os.getcwd(), "docs", "ROADMAP.md")
    if not os.path.isfile(path):
        return []
    out = []
    for i, line in enumerate(
            io.open(path, encoding="utf-8", errors="replace").read().splitlines(), 1):
        m = ROW.match(line)
        if not m:
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        out.append((len(out) + 1, m.group(1), cells[4] if len(cells) > 4 else ""))
    return out


def log_number_findings(rows, files):
    """详记件（docs/roadmap-log/NN-<pkg>.md）的文件号必须等于该包在逐包表里的行号。

    G13 的第二半，10-09 补。起因就是拆件那一笔自己造的漂移：工装照着旧日志里“第 N 节”的
    **顺序号**编文件名，而那个顺序号在 `mac`（表第 13 行，判不做、没有详记件）那里少编了一次
    ⇒ 第 13 行往后 12 件全体差一号（`13-dfa.md` 对着 `docs/spec/14-dfa.md`）。
    号是稳定 ID 的话，就不该有两套号。
    """
    bad = []
    linked = set()
    for i, pkg, cell in rows:
        m = re.search(r"roadmap-log/([0-9]{2}-[a-z0-9_\-]+\.md)", cell)
        if not m:
            continue
        expect = "%02d-%s.md" % (i, pkg.replace("_", "-"))
        linked.add(expect)
        if m.group(1) != expect:
            bad.append("逐包表第 {} 行是 `{}`，详记链接却指 {}（应为 {}）".format(
                i, pkg, m.group(1), expect))
    for f in files:
        if f not in linked:
            bad.append("docs/roadmap-log/{} 没有被逐包表任何一行指到（孤儿件）".format(f))
    return bad


def log_selftest():
    """阳性对照：把一件的号挪错一格，判据必须抓到；顺手也要能抓到孤儿件。"""
    filler = [(k, "pad%02d" % k, "") for k in range(1, 14)]   # 让 dfa 落在表第 14 行
    rows = filler + [(14, "dfa", "[`roadmap-log/13-dfa.md`](x)"),
                     (24, "sched", "[`roadmap-log/15-sched.md`](x)")]
    bad = log_number_findings(rows, ["13-dfa.md", "15-sched.md", "99-orphan.md"])
    return (any("应为 14-dfa.md" in b for b in bad) and any("应为 24-sched.md" in b for b in bad)
            and any("孤儿件" in b for b in bad))


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
    # 索引行状态判据：漂了的状态词必须被抓到；不指名包的"状态口径词表"不许误报
    st = {"date": "已实现", "id": "已实现", "text": "已实现", "valid": "未开工"}
    idx_bad = index_findings_text(
        "| 契约 | `docs/spec/03-date.md`（date，契约已冻结） |\n", st)
    idx_multi = index_findings_text(
        "| 契约 | `docs/spec/03-date.md`（date、id，未开工） |\n", st)
    idx_ok = index_findings_text(
        "| 契约 | `docs/spec/03-date.md`（date） |\n"
        "| 进度 | 逐包状态（`已实现`/`实现中`/`契约已冻结`/`未开工`）+ 用例数 |\n"
        "| 校验 | `valid` 包（valid 未开工）——见生成块 |\n"
        + BEGIN + "\n| 包状态 | `已实现` 4 |\n" + END + "\n", st)
    ok = (ok and len(probe_bad) == 2 and not probe_ok and len(idx_bad) == 1
          and len(idx_multi) == 1 and not idx_ok)
    print("  PASS 自检：措辞、表格行、序号、索引状态四条识别规则都对得上" if ok else
          "  FAIL 自检失效（序号坏样本 %d 应 2、好样本误报 %d；索引坏 %d 应 1、多点 %d 应 1、误报 %d）"
          % (len(probe_bad), len(probe_ok), len(idx_bad), len(idx_multi), len(idx_ok)))
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
    lb = log_number_findings(roadmap_case_cells(), log_files())
    if lb:
        print("  FAIL 详记件号与逐包表行号不一致（{} 处）：".format(len(lb)))
        for b in lb:
            print("    ", b)
        return 1
    if not log_selftest():
        print("  FAIL G13 自身失效：详记件号的阳性对照没过（挪错一格没被抓到）")
        return 1
    print("  PASS docs/roadmap-log/NN-<pkg>.md 的 NN 与逐包表行号一一对应"
          "（{} 件，含阳性对照：错一格与孤儿件都要被抓到）".format(len(log_files())))
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
    bad += index_findings(rows)
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
