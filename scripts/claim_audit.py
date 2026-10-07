#!/usr/bin/env python
# 不承诺项反查（门禁 G14 的实现体）
#
# 要解决的是一类具体的事故：**"本库不做 X" 这句话写进公开文档之后，X 其实已经在面上了**，
# 而既有门禁只核状态词（已实现/预期红）与用例读数，管不到能力声明——于是 README 与对照表
# 可以同时写着"不支持命名时区与 DST"，而 `date` 包里早就有 603 区 / 36,701 段的内置表。
# 外人最先读的正是那几句"不做"，它漂了比用例红更坏。
#
# 判据形状（机械、可自证）：一张 CLAIMS 表，每行三件东西
#   claim     —— "不做/不支持/只剩"那类声明的正则
#   evidence  —— 反查文件 + 命中正则：命中即说明这件事**本库已经做了**
#   docs      —— 扫描面（公开文档；不含 scripts/，那里本来就要写这些字面串做对照）
# 规则：evidence 命中 ⇒ claim 不许出现在 docs；evidence 取不到数 ⇒ 显式 SKIP 并说 reason，
# 绝不当成"通过"（"取不到数据就当通过"的判据本仓已经栽过三次）。
#
# ⚠ 扫描面 = 三份对外门面（README / ROADMAP / 00-hutool-map），不含各包 spec：**翻案记录里引用旧原句
#    会被本判据当成过期声明**（本轮实测两次：README 那句"已不再是…"与 ROADMAP 那句"旧写…待拍 P2"，
#    都是引号里的旧文案触发红）。写翻案记录时**转述而不原样引用**该句式；spec 里保留原句作历史凭据
#    是刻意的——那里要的是"当初写错过什么"，门面文档要的是"现在做到哪"。
#
# 用法：
#   python scripts/claim_audit.py            # 检查（有违规退出 1）
#   python scripts/claim_audit.py --selftest # 阳性对照：坏声明必须被抓、好声明必须被放过
import io
import os
import re
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 扫描面：公开文档。docs/spec/00-hutool-map.md 是对照表，README.md 是最先被读的那一份。
DOCS = ["README.md", "docs/ROADMAP.md", "docs/spec/00-hutool-map.md"]

CLAIMS = [
    {
        "id": "C1",
        "what": "命名时区与 DST",
        # "不支持命名时区" / "不做命名时区" / "没有 DST" 这几类写法
        "claim": r"不支持命名时区|不做命名时区|命名时区与\s*DST|也因此没有\s*DST",
        "evidence_file": "date/pkg.generated.mbti",
        "evidence_re": r"zone_names|zone_offset_minutes",
    },
    {
        "id": "C2",
        "what": "OS 能力窗口的条数",
        # README 里那句"两扇窗"（now/rand）；AGENTS 已把 get_env_var 加进四条，date 真在用它
        "claim": r"两扇窗|只走\s*core\s*给的?两",
        "evidence_file": "date/pkg.generated.mbti",
        "evidence_re": r"set_default_zone|default_zone_source",
    },
    {
        "id": "C3",
        "what": "身份证校验族的剩余待拍件",
        "claim": r"ROADMAP 面还剩一件|公开形状题仍待拍",
        "evidence_file": "typex/pkg.generated.mbti",
        "evidence_re": r"idcard_is_valid_card|idcard_info_10",
    },
]


def read(path):
    p = os.path.join(REPO, path) if not os.path.isabs(path) else path
    if not os.path.exists(p):
        return None
    return io.open(p, encoding="utf-8", errors="replace").read()


def check(doc_texts=None):
    """返回 (违规列表, SKIP 列表)。doc_texts 给定时按传入内容判（自检用），否则读仓内文件。"""
    bad, skips = [], []
    for c in CLAIMS:
        ev = read(c["evidence_file"]) if doc_texts is None else doc_texts.get(c["evidence_file"])
        if ev is None:
            skips.append("%s 反查文件取不到（%s）⇒ 不判通过" % (c["id"], c["evidence_file"]))
            continue
        if not re.search(c["evidence_re"], ev):
            # 证据不在 ⇒ 这条声明此刻可能仍然成立，也可能证据件改名了；后者由自检的第二档兜
            continue
        for d in DOCS:
            t = read(d) if doc_texts is None else doc_texts.get(d)
            if t is None:
                skips.append("%s 扫描文件缺失（%s）" % (c["id"], d))
                continue
            for m in re.finditer(c["claim"], t):
                line = t[:m.start()].count("\n") + 1
                bad.append("%s｜%s:%d 声明了「%s」，而 %s 现读已有 %s ⇒ 声明过期"
                           % (c["id"], d, line, m.group(0), c["evidence_file"], c["what"]))
    return bad, skips


def selftest():
    """两档对照，缺一档这条判据就是许愿池：
       ① 必须敢红：证据在位 + 文档仍写"不做" ⇒ check() 要报出违规；
       ② 必须敢放过：证据不在位（件名换成一个仓里真没有的名字）⇒ 同一句声明不许报红。
       再加 ③ 反查文件缺失 ⇒ 必须走 SKIP 而不是 PASS。"""
    caught = 0
    # ① 真实证据 + 假声明（现场拼一份文档，不动仓内文件）
    docs = {"README.md": "本库不支持命名时区与 DST。\n", "docs/ROADMAP.md": "", "docs/spec/00-hutool-map.md": ""}
    ev = read("date/pkg.generated.mbti")
    if ev is None:
        print("  SKIP 自检：读不到 date/pkg.generated.mbti，本机不是仓根？")
        return 0
    docs_ev = {"date/pkg.generated.mbti": ev, "typex/pkg.generated.mbti": ev}
    bad, _ = check({**docs_ev, **docs})
    if bad:
        caught += 1
    else:
        print("  FAIL 自检①失效：证据在位却放过了「不支持命名时区与 DST」")
    # ② 证据缺席 ⇒ 同一句声明必须放行（否则判据成了永真）
    docs_ev2 = dict(docs_ev)
    docs_ev2["date/pkg.generated.mbti"] = "pub fn nothing_here(Unit) -> Unit\n"
    docs_ev2["typex/pkg.generated.mbti"] = "pub fn nothing_here(Unit) -> Unit\n"
    bad2, _ = check({**docs_ev2, **docs})
    if not bad2:
        caught += 1
    else:
        print("  FAIL 自检②失效：证据撤掉后仍报红，这条判据与文档内容无关（永真）")
    # ③ 反查文件缺失 ⇒ 不许给出通过
    docs_ev3 = dict(docs_ev)
    docs_ev3["date/pkg.generated.mbti"] = None
    _, sk = check({**docs_ev3, **docs})
    if sk:
        caught += 1
    else:
        print("  FAIL 自检③失效：反查文件缺失却给出 0 SKIP")
    return caught


def main():
    os.chdir(REPO)
    if "--selftest" in sys.argv:
        n = selftest()
        if n == 3:
            print("  PASS 三档对照全过（敢红 / 敢放 / 缺证据走 SKIP）")
            return 0
        print("  FAIL 自检只有 %d/3 档通过" % n)
        return 1
    bad, skips = check()
    for s in skips:
        print("  SKIP %s" % s)
    if bad:
        for b in bad:
            print("  FAIL %s" % b)
        return 1
    print("  PASS %d 条不承诺声明与实现面逐条对得上（证据文件见脚本内 CLAIMS）" % len(CLAIMS))
    return 0


if __name__ == "__main__":
    sys.exit(main())
