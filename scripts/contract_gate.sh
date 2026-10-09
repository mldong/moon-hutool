#!/usr/bin/env bash
# moon-hutool 契约门禁 G1~G17
#
# 原则：每条判据都必须"真跑过且敢报红"。凡当前环境跑不了的项，显式打 SKIP + 理由，
# 绝不伪装成 PASS（恒绿但没测的套件比红灯更危险）。
#
# 用法：
#   scripts/contract_gate.sh                 # 全跑（本机默认 wasm 一档做深，其余档做 check）
#   GATE_TARGETS="wasm" scripts/contract_gate.sh
#   GATE_FREEZE_BASE=<commit> scripts/contract_gate.sh   # 打开期望值冻结检查（G5）——
#     直推口径下 CI 不跑这条（10-09 拍 C），实现笔落地前由人在本地复跑这一条
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"
export PYTHONIOENCODING=utf-8
FAILS=0; SKIPS=0
ok()  { echo "  PASS $*"; }
bad() { echo "  FAIL $*"; FAILS=$((FAILS+1)); }
skip(){ echo "  SKIP $*"; SKIPS=$((SKIPS+1)); }
GATE_TARGETS="${GATE_TARGETS:-wasm js}"
# 地板＝`moon test --target <档>` 汇总行的 Total tests（10-10 现读：wasm、js 两档 1557，
#   wasm-gc 1545——差的 12 条是 sched 的 async 用例，该档不收集，见 docs/spec/24-sched.md §1。
#   同一天里这条数走过 1531 →（批① 契约笔）1548 红 17 →（批① 落地笔）1557 红 0；
#   G3 判的是"用例收没收到"，红绿由 targets 那一步逐条点名，两者不混）。
# 负向对照：把这里改成 1558 当场判红 `test wasm 只收集 1557 条 < 基线 1558`。
# 逐包条数别抄在这里，现读 ROADMAP.md 末的 READINGS 生成块（G11 每次都会重生成）。
BASELINE_TESTS="${BASELINE_TESTS:-1557}"

echo "== G1 零第三方 + async 按包归属（10-09 口径翻案：白名单不再等于零依赖）=="
# 三条判据一起跑，任何一条红即 G1 红；判据自身另有三档对照，对照不过 ⇒ 报"G1 自身失效"而不是放过。
if python - <<'PY'
import io, json, os, re, subprocess, sys

ROOT = subprocess.run(["git", "rev-parse", "--show-toplevel"],
                      capture_output=True, text=True).stdout.strip()
ASYNC = "moonbitlang/async"
OWNER = "sched"                      # 唯一被放行 import async 的包目录
THIRD = r'(moonbitstack|Betterlol|mizchi|bobzhang|justjavac|tonyfettes|Lfan-ke|oboard|caijiewei295|iceBear67|suiyunonghen|Asterless|Metalymph|Nanaloveyuki)/'


def pkg_imports(base):
    """{包目录: [import 名]} —— 只看包级 moon.pkg 的 import 段，忽略注释与 _build/.mooncakes。"""
    out = {}
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames[:] = [d for d in dirnames if d not in ("_build", ".mooncakes", ".git", "docs", "scripts")]
        if "moon.pkg" not in filenames:
            continue
        rel = os.path.relpath(dirpath, base).replace("\\", "/")
        text = io.open(os.path.join(dirpath, "moon.pkg"), encoding="utf-8", errors="replace").read()
        text = re.sub(r"//[^\n]*", "", text)
        names = []
        for block in re.findall(r"import\s*\{([^}]*)\}", text, re.S):
            names += re.findall(r'"([^"]+)"', block)
        out[rel] = names
    return out


def mod_imports(base):
    p = os.path.join(base, "moon.mod")
    text = re.sub(r"//[^\n]*", "", io.open(p, encoding="utf-8", errors="replace").read())
    names = []
    for block in re.findall(r"import\s*\{([^}]*)\}", text, re.S):
        names += re.findall(r'"([^"]+)"', block)
    return [n.split("@")[0] for n in names]


def scan(imports, mods):
    """返回违规列表。三类判据：① async 归属；② 任何真第三方；③ 模块级 import 段只许那一条例外。"""
    bad = []
    for pkg, names in sorted(imports.items()):
        for n in names:
            if re.search(THIRD, n):
                bad.append("第三方依赖 %s（包 %s）" % (n, pkg))
            if n == ASYNC and pkg != OWNER:
                bad.append("%s 包 import 了 %s —— 例外只登记在 %s" % (pkg, ASYNC, OWNER))
    for n in mods:
        if re.search(THIRD, n):
            bad.append("moon.mod 有第三方 import：%s" % n)
        if n == ASYNC and OWNER not in imports:
            bad.append("moon.mod pin 了 %s 但包 %s 不存在 ⇒ 例外登记悬空" % (ASYNC, OWNER))
    if ASYNC in mods and sorted(set(mods)) != [ASYNC]:
        bad.append("moon.mod 的 import 段必须只有 %s 这一条例外，现读：%s" % (ASYNC, mods))
    # ④ 反向死格：例外登记了却没人用（pin 漂成摆设），或用了却没登记（构建期才发现）
    used = [p for p, ns in imports.items() if ASYNC in ns]
    if used and ASYNC not in mods:
        bad.append("包 %s 用了 %s，但 moon.mod 没有该 import ⇒ 依赖靠运气解析" % (used, ASYNC))
    if ASYNC in mods and not used:
        bad.append("moon.mod pin 了 %s 但没有任何包 import 它 ⇒ 该从 moon.mod 撤掉，别留悬空 pin" % ASYNC)
    return bad


def show(tag, bad):
    if bad:
        print("  FAIL %s：%s" % (tag, "；".join(bad)))
        return 1
    print("  PASS %s" % tag)
    return 0


imports = pkg_imports(ROOT)
mods = mod_imports(ROOT)
rc = 0


def probe_from(base, pkg, dep):
    """探针：包名->import 列表必须**逐值拷**。
    上一版直接 dict(imports) 再 setdefault(pkg, []).append(...)，拿到的是真实 list 对象，
    于是探针把 coll/text 的真读数改脏，G1 拿自己的坏样本判了本包红——判据自证反而污染了判据。"""
    copy = {k: list(v) for k, v in base.items()}
    copy.setdefault(pkg, []).append(dep)
    return copy

# 判据自证三档（缺一档这条判据就是许愿池）：
#  ① 别的包塞 async 必须红；② 塞真第三方必须红；③ 仓内真实读数必须放。
probe = probe_from(imports, "coll", ASYNC)
b1 = [x for x in scan(probe, mods) if "coll" in x or "例外只登记" in x]
if not b1:
    print("  FAIL G1 自身失效：往 coll 塞一条 async import 没被抓到，归属判据不可信")
    rc = 1
probe2 = probe_from(imports, "text", "moonbitstack/moondate")
b2 = [x for x in scan(probe2, mods) if "第三方依赖" in x]
if not b2:
    print("  FAIL G1 自身失效：塞一个真第三方没被抓到，白名单判据不可信")
    rc = 1
probe3 = dict(imports)
probe3.pop(OWNER, None)
b3 = [x for x in scan(probe3, [ASYNC]) if "悬空" in x or "没有任何包" in x]
if not b3:
    print("  FAIL G1 自身失效：把唯一使用者摘掉后，悬空 pin 没被抓到（判据对'例外没人用'是瞎的）")
    rc = 1

ALLOW = {"moonbitlang/core", "mldong/moon-hutool", ASYNC}

def tree_names(raw):
    """传递依赖腿：`moon tree --json` 的**全部模块名**里，除 core / 本仓 / 那一条例外之外一律红。
    这条是原 G1 的主判据，不能因为改成包级扫描就丢——包级只看得到直接 import，
    传递进来的第三方只有树里照得见。取不到树 ⇒ SKIP 并说明，绝不当通过。
    10-09 现读本版格式是扁平的 `{version, status, modules:[{name,version,source…}], edges:[…]}`，
    **没有 deps/children 嵌套**：旧代码去走嵌套树 ⇒ 一个节点都没读到、永远返回空集，
    是一条比红灯更危险的永真死格（本机 `moon tree --json` 只吐 2 个模块它也报 PASS）。
    所以这里同时判"读到几个节点"，节点数低于 2（本仓 + 那条例外）就是这条腿瞎了。"""
    d = json.loads(raw)
    mods = sorted({(m.get("name") or "") for m in (d.get("modules") or []) if m.get("name")})
    return mods, sorted(set(mods) - ALLOW)

# 阳性对照：塞一个真第三方进扁平 modules 段必须被抓到，且节点数要跟着涨——
# 没有这一档，"改成读 modules"这件事本身是不可证的（旧死格就是这么藏了一整轮）。
_s_seen, _s_bad = tree_names(json.dumps({
    "version": 1, "status": "success", "root": 0,
    "modules": [{"name": "mldong/moon-hutool"}, {"name": ASYNC}, {"name": "evilcorp/stealth"}],
    "edges": []}))
if _s_bad != ["evilcorp/stealth"] or len(_s_seen) != 3:
    print("  FAIL G1 自身失效：传递依赖腿的阳性对照没过（塞进扁平 modules 段的第三方没被抓到）")
    rc = 1

def tree_leg():
    r = subprocess.run(["moon", "tree", "--json"], capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0 or not r.stdout.strip():
        return "skip", []
    try:
        seen, bad = tree_names(r.stdout)
    except Exception as e:
        return ("fail", ["`moon tree --json` 的 JSON 读不出 modules 段（%s）——格式变了，"
                         "这条腿会瞎，判红不判过" % e])
    if len(seen) < 2:
        return ("fail", ["只读到 %d 个模块节点（本仓 + %s 至少该有 2 个）"
                         "⇒ 这条腿没读到节点，PASS 不算数" % (len(seen), ASYNC)])
    if bad:
        return ("fail", ["传递依赖里有未登记模块：%s" % "，".join(bad)])
    return ("ok", seen)


real = scan(imports, mods)
rc |= show("G1 三条判据（async 只归属 %s · 零真第三方 · moon.mod import 段只那一条例外 · 无悬空 pin）" % OWNER, real)
print("     （现读：moon.mod import 段 = %s；import %s 的包 = %s）"
      % (mods or "空", ASYNC, [p for p, ns in imports.items() if ASYNC in ns]))

kind, detail = tree_leg()
if kind == "skip":
    print("  SKIP 传递依赖腿：`moon tree --json` 取不到（本机 moon 或网络）——本轮只判了包级三条")
elif kind == "fail":
    for m in detail:
        print("  FAIL 传递依赖腿：" + m)
    rc = 1
else:
    print("  PASS 传递依赖树里除 core / 本仓 / %s 无其它节点（现读 %d 个模块节点：%s）"
          % (ASYNC, len(detail), "，".join(detail)))
sys.exit(rc)
PY
then ok "G1 绿"
else bad "G1 红（见上）"
fi

echo "== G2 零 FFI =="
n=$(grep -rn 'extern "' --include='*.mbt' . 2>/dev/null | grep -v '_build/' | grep -v '\.mooncakes/' | wc -l | tr -d ' ')
[ "$n" = "0" ] && ok "全仓 extern 命中 0" || bad "有 $n 处 extern —— 违反零依赖定义"
n2=$(grep -rl 'native-stub' --include='moon.pkg' . 2>/dev/null | grep -v '\.mooncakes/' | wc -l | tr -d ' ')
[ "$n2" = "0" ] && ok "无 native-stub" || bad "有 $n2 个包带 native-stub"

echo "== G3 逐档编译 + 用例收集数 =="
for t in $GATE_TARGETS; do
  if moon check --target "$t" >/tmp/mh_check_$t.log 2>&1; then
    w=$(grep -c "Warning" /tmp/mh_check_$t.log || true)
    [ "$w" = "0" ] && ok "check $t 全绿（0 警告）" || bad "check $t 有 $w 条警告（零警告是门禁）"
  else bad "check $t 失败：$(tail -2 /tmp/mh_check_$t.log | tr '\n' ' ')"; fi
  if moon test --target "$t" >/tmp/mh_test_$t.log 2>&1 || true; then
    got=$(grep -oE "Total tests: [0-9]+" /tmp/mh_test_$t.log | head -1 | grep -oE "[0-9]+")
    got=${got:-0}
    # 骨架期允许红（函数体是 abort），但**必须收到用例**——收集数为 0 就是永真死格
    if [ "$got" -ge "$BASELINE_TESTS" ]; then ok "test $t 收集 $got 条（≥ 基线 $BASELINE_TESTS）"; else bad "test $t 只收集 $got 条 < 基线 $BASELINE_TESTS（静默丢用例）"; fi
  else bad "test $t 无法运行"; fi
done

echo "== G4 格式与公开接口 =="
moon fmt --check >/tmp/mh_fmt.log 2>&1 || true
# 只数本仓跟踪的 .mbt 命中行：依赖检出物 .mooncakes/ 里的格式告警不是本仓的账（10-09 引 async 后实测 81 行全是它）
own=$(grep -oE '[^ "`]+\.mbt' /tmp/mh_fmt.log 2>/dev/null | sed 's|^\./||' | grep -v '\.mooncakes/' | sort -u | wc -l | tr -d ' ')
own=${own:-0}
if [ "$own" = "0" ]; then ok "moon fmt --check：本仓跟踪文件无待格式化（依赖树里的行不计）"; else bad "本仓有 $own 个文件需 moon fmt"; fi
if command -v git >/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
  moon info >/tmp/mh_info.log 2>&1 || bad "moon info 执行失败"
  if git diff --quiet -- '*.mbti' 2>/dev/null; then ok ".mbti 无漂移（公开接口未意外变动）"; else bad ".mbti 有未提交漂移——API 变动须显式评审"; fi
else skip "非 git 工作树，跳过 .mbti 漂移检查"
fi

echo "== G5 期望值冻结（直推口径：CI 不跑，靠本地拿上一笔当基准复跑）=="
if [ -n "${GATE_FREEZE_BASE:-}" ]; then
  # 基准号写错时 `git diff` 只会静默给空集 ⇒ 整条检查会变成"永远通过"的空转，
  # 而空转比红更难发现（10-07 实测：一个手打错的 sha 就让 G5 报了 ok）。先钉住它是个可解析的 rev。
  if ! git rev-parse --verify "${GATE_FREEZE_BASE}^{commit}" >/dev/null 2>&1; then
    bad "GATE_FREEZE_BASE=${GATE_FREEZE_BASE} 不是一个可解析的 commit —— G5 拒绝在空转状态下给 ok"
  else
    ch=$(git diff --name-only "$GATE_FREEZE_BASE" -- '*_test.mbt' 'docs/spec/*' 2>/dev/null)
    if [ -z "$ch" ]; then ok "测试与 spec 未被这一笔触碰"
    elif [ "${ALLOW_EXPECTATION_CHANGE:-0}" = "1" ]; then skip "已授权改动：$(echo "$ch" | tr '\n' ' ')"
    else bad "实现期改了期望值/契约，须单独一笔并给外部读数来源：$ch"; fi
  fi
else
  # 没给基准 ≠ 没风险：这道闸现在没人自动跑，所以把它**碰了什么**当场念出来，
  # 免得"恒 SKIP"变成"恒无人理会"（本仓照见过两次恒绿的死格了）。
  touched=""
  # 默认拿上一笔当参照来"念提醒"；给人留一个口子指到契约那一笔：
  #   FREEZE_REMIND_BASE=<PR-A 的 sha> bash scripts/contract_gate.sh
  RB="${FREEZE_REMIND_BASE:-HEAD~1}"
  if git rev-parse --verify "${RB}^{commit}" >/dev/null 2>&1; then
    touched=$(git diff --name-only "$RB" HEAD -- '*_test.mbt' 'docs/spec/*' 2>/dev/null)
  fi
  if [ -n "$touched" ]; then
    skip "未给 GATE_FREEZE_BASE ⇒ G5 本轮没被执行，而上一笔碰了 $(printf '%s\n' "$touched" | wc -l | tr -d ' ') 个冻结面文件（$(printf '%s' "$touched" | tr '\n' ' ')）——复跑：GATE_FREEZE_BASE=<上一笔 sha> bash scripts/contract_gate.sh"
  else
    skip "未给 GATE_FREEZE_BASE ⇒ G5 本轮没被执行（上一笔没碰冻结面，或浅克隆够不到 HEAD~1）"
  fi
fi
# 阳性对照：假基准号必须被识别为不可解析（否则上面那条校验就是摆设）。
# 只在校验过 rev 的分支上跑，比对结果本身不参与判定。
bogus=$(GATE_FREEZE_BASE=deadbeefdeadbeef bash -c 'git rev-parse --verify "deadbeefdeadbeef^{commit}" >/dev/null 2>&1; echo $?')
[ "$bogus" != "0" ] && ok "G5 能识别不可解析的基准号（不会空转）" || bad "G5 基准校验失效：假 sha 竟可解析"

echo "== G6 官方向量在位 =="
vc=$(grep -ohE "RFC [0-9]{4}|FIPS 180-4" docs/spec/*.md 2>/dev/null | sort -u | wc -l | tr -d ' ')
ac=$(grep -rhoE "assert_eq|assert_true|assert_false" */[a-z]*_test.mbt 2>/dev/null | wc -l | tr -d ' ')
if [ "$vc" -ge 2 ] && [ "$ac" -ge 20 ]; then ok "spec 引用 $vc 组规范、测试断言 $ac 条"
else bad "spec 规范引用 $vc / 断言 $ac —— 摘要类必须挂官方向量"; fi
# 阳性对照：故意查一个不存在的关键字，确认 grep 管道本身在干活（防空转）
[ "$(grep -rhoE "NOSUCHTOKEN_zzz" docs/spec/*.md 2>/dev/null | wc -l | tr -d ' ')" = "0" ] && ok "对照项正常（管道能出 0）" || bad "对照项异常：过滤器不可信"

echo "== G7 文档即测试 =="
blocks=$(grep -rhoE '^```mbt check' --include='README.mbt.md' . 2>/dev/null | wc -l | tr -d ' ')
if [ "$blocks" = "0" ]; then
  skip "本仓尚无 README.mbt.md 的 mbt check 块——实现相位**每个已交付包必须自带一份**（AGENTS 规则），否则这条就是没套件"
else
  got=$(moon test --target wasm 2>&1 | grep -oE "Total tests: [0-9]+" | grep -oE "[0-9]+")
  [ "${got:-0}" -gt 0 ] && ok "$blocks 个文档块已被收集（用例总数 $got）" || bad "文档块存在却没被收集（判据档位用错）"
fi

echo "== G8 包 core 的对拍腿 =="
pk=$(grep -rlE "core 直接可用|对拍" docs/spec/*.md 2>/dev/null | wc -l | tr -d ' ')
hb=$(grep -rhoE "对拍" */[a-z]*_test.mbt 2>/dev/null | wc -l | tr -d ' ')
if [ "$hb" -ge 1 ]; then ok "spec 有 $pk 份声明可复用 core，测试里有 $hb 处对拍断言"
else bad "声明复用 core 却没有对拍腿（core 语义漂移会被静默吞掉）"; fi

echo "== G9 公开仓引用红线（不许指向私有台账/内部叙事）=="
# 本仓是 PUBLIC 仓：决策台账在协调仓（不进本仓提交历史），公开文档必须自洽。
# 扫描面 = git 跟踪的文件，排除 scripts/（本脚本自己就要写这些禁词，否则永远命中）。
BAN='moon-hutool-plan|协调仓|14 栈|第 14 栈|夜班|申报书|codeup|glm-flash|hub docs|见 hub|口径 [0-9]|dev-tools|[A-Za-z]:[\\/]{1,2}(Users|develop|Program|Work|work|tmp)|192\.168\.1\.160|HBuilderX|BlueStacks'
hits=$(git ls-files 2>/dev/null | grep -v '^scripts/' | xargs -r grep -nE "$BAN" 2>/dev/null | head -5)
if [ -z "$hits" ]; then ok "跟踪文件里无内部叙事引用与本机路径（禁词表见脚本内 BAN）"
else bad "公开仓出现内部引用/本机路径：$hits"; fi
# 自检：两类坏样本各写一行——① 内部叙事，② 本机盘符路径。
# ⚠ 必须**每类一行**并断言行数：只断 `>=1` 的话，旧词会把新加的那一档"其实没生效"整个藏掉
#   （10-07 就是这条判据放过了 `G:\dev-tools\moon\lib\core` 被写进公开 spec）。
probe=$(mktemp ./_g9_probe_XXXX.md 2>/dev/null || echo ./_g9_probe.md)
printf '%s\n' "参见 hub docs/moon-hutool-plan.md 与 14 栈口径 6" "本机 G:\\dev-tools\\moon\\lib\\core 实测" > "$probe"
caught=$(grep -cE "$BAN" "$probe" 2>/dev/null || true)
rm -f "$probe"
[ "${caught:-0}" -ge 2 ] && ok "阳性对照正常（两类坏样本各 $caught/2 被抓到）" || bad "G9 自身失效：两类坏样本只抓到 ${caught:-0} 条，这条判据不可信"


echo "== G10 仓内文档链接可达（索引不许漂成死链）=="
if python scripts/check_doc_links.py >/tmp/mh_links.log 2>&1; then
  grep -E "^  PASS" /tmp/mh_links.log
else
  bad "有死链或自检失效："; sed -n '1,8p' /tmp/mh_links.log | sed 's/^/    /'
fi


echo "== G11 状态读数：生成块一致 + 逐包表覆盖 + 措辞不矛盾 =="
if python scripts/sync_status.py --check >/tmp/mh_status.log 2>&1; then
  grep -E "^  (PASS|INFO)" /tmp/mh_status.log
else
  bad "状态句与当场读数不一致（见下）："; sed -n '1,12p' /tmp/mh_status.log | sed 's/^/    /'
fi


echo "== G12 骨架豁免棘轮（只有还没实现的包才许压掉那三类警告）=="
# 契约骨架期的包，函数体全是 abort ⇒ 类型没人构造、错误变体没人构造、签名写了 raise 而体里没 raise。
# 这三类警告是"未实现"的机械后果，只能在骨架期用 moon.pkg 的 warnings 豁免。
# 合法性判据取**函数体还是不是 PR-A 骨架的 abort**，不取"用例绿没绿"——后者要再跑一遍逐包测试，慢且与 G11 重复。
# ⚠ 判据必须认骨架那句固定文案（`PR-B：契约骨架`），不能只认 `abort("moon-hutool` 前缀：
# 落地后的包里允许留"不可达分支"的不变量 abort（`typex/phone.mbt` 就有），只认前缀会让这类包
# 把早已该删的骨架豁免一路藏下去——10-06 实测就是这样藏过了第五批落地笔（当时用例全绿、`moon check`
# 也零警告，因为那条豁免顺手压掉了真信号，只是恰好没有真信号被压）。
skel_check() {  # $1 = 待查目录；打印违规的包（无输出即无违规）
  python - "$1" <<'PYEOF'
import glob, io, os, sys
root = sys.argv[1]
bad = []
for pkg in sorted(glob.glob(os.path.join(root, "*", "moon.pkg"))):
    d = os.path.dirname(pkg)
    lines = io.open(pkg, encoding="utf-8", errors="replace").read().splitlines()
    live = [l for l in lines if l.strip().startswith("warnings")]
    if not live:
        continue
    bodies = [f for f in glob.glob(os.path.join(d, "*.mbt"))
              if not f.endswith(("_test.mbt", "_wbtest.mbt"))]
    still_skeleton = any('PR-B：契约骨架' in io.open(f, encoding="utf-8", errors="replace").read()
                         for f in bodies)
    if not still_skeleton:
        bad.append(os.path.relpath(pkg, root))
print(" ".join(bad))
PYEOF
}
viol=$(skel_check .)
if [ -z "$viol" ]; then ok "在用的 warnings 豁免都对应还没实现的包"; else bad "实现已落地却还压着骨架豁免：$viol"; fi
# 阳性对照两条：① 体里已无 abort 却仍带豁免；② 体里只有"不变量 abort"（前缀像骨架、但不是 PR-A 骨架）却仍带豁免
fx=$(mktemp -d ./_g12_fixture_XXXXXX 2>/dev/null || echo ./_g12_fixture)
mkdir -p "$fx/fakepkg" "$fx/fakepkg2"
printf 'warnings = "-unused_constructor"\n' > "$fx/fakepkg/moon.pkg"
printf 'pub fn a() -> Int { 1 }\n' > "$fx/fakepkg/a.mbt"
printf 'warnings = "-unused_value"\n' > "$fx/fakepkg2/moon.pkg"
printf 'pub fn b(x : Int) -> Int { abort("moon-hutool/typex 内部码表编译失败：" + "b") }\n' > "$fx/fakepkg2/b.mbt"
caught=$(skel_check "$fx")
rm -rf "$fx"
if [ -n "$caught" ] && echo "$caught" | grep -q "fakepkg2"; then
  ok "阳性对照正常，且不变量 abort 也骗不过 G12（两类假包都被点名：$caught）"
else
  bad "G12 自身失效：坏样本没被抓到（抓到的是「$caught」），这条判据不可信"
fi

echo "== G13 spec 序号 == 逐包表行号（号是稳定 ID，不许与表各漂各的）=="
if python scripts/sync_status.py --numbers >/tmp/mh_numbers.log 2>&1; then
  grep -E "^  PASS" /tmp/mh_numbers.log
else
  bad "序号与表行号不一致（见下）："; sed -n '1,10p' /tmp/mh_numbers.log | sed 's/^/    /'
fi

echo "== G14 不承诺声明反查（写进公开文档的「不做 X」必须与实现面对得上）=="
# 判据与自检三档（敢红 / 敢放 / 缺证据走 SKIP）都在 scripts/claim_audit.py 里，理由见那份文件头。
if python scripts/claim_audit.py --selftest >/tmp/mh_claims_self.log 2>&1; then
  grep -E "^  (PASS|SKIP|FAIL)" /tmp/mh_claims_self.log
  if python scripts/claim_audit.py >/tmp/mh_claims.log 2>&1; then
    grep -E "^  (PASS|SKIP)" /tmp/mh_claims.log
  else
    bad "不承诺声明过期（见下）："; sed -n '1,10p' /tmp/mh_claims.log | sed 's/^/    /'
  fi
else
  bad "G14 自身失效：三档对照没全过——这条判据不可信（见下）"; sed -n '1,10p' /tmp/mh_claims_self.log | sed 's/^/    /'
fi

echo "== G15 未覆盖行棘轮（基线提交进仓，只许收紧不许放松）=="
# rc=0 判据成立 / rc=1 超基线或自证失效 / rc=2 没有覆盖率数据（显式 SKIP，绝不当通过）
python scripts/coverage_ratchet.py --selftest >/tmp/mh_ratchet_self.log 2>&1; rc=$?
if [ "$rc" = "2" ]; then
  skip "G15 没有覆盖率数据 ⇒ 棘轮本轮不判（跑法：moon test --target wasm --enable-coverage 后再 analyze）"
elif [ "$rc" = "0" ]; then
  grep -E "^  PASS" /tmp/mh_ratchet_self.log
  python scripts/coverage_ratchet.py >/tmp/mh_ratchet.log 2>&1; rc2=$?
  if [ "$rc2" = "0" ]; then
    grep -E "^  (PASS|INFO)" /tmp/mh_ratchet.log
  else
    bad "未覆盖行数超基线或基线缺失（见下）："; sed -n '1,14p' /tmp/mh_ratchet.log | sed 's/^/    /'
  fi
else
  bad "G15 自身失效：三档对照没全过——这条判据不可信（见下）"; sed -n '1,14p' /tmp/mh_ratchet_self.log | sed 's/^/    /'
fi

echo "== G16 hutool-core 顶层类 census（每类必须落一档；漏档、类面漂移、版本口径不一致都判红）=="
python scripts/core_surface.py --selftest >/tmp/mh_surface_self.log 2>&1; rc=$?
if [ "$rc" = "2" ]; then
  skip "G16 既无仓内类面清单 docs/spec/hutool-classes.tsv 也没给 HUTOOL_JAR ⇒ 类面本轮不判"
elif [ "$rc" = "0" ]; then
  grep -E "^  (PASS|INFO)" /tmp/mh_surface_self.log
  python scripts/core_surface.py --check >/tmp/mh_surface.log 2>&1; rc2=$?
  if [ "$rc2" = "0" ]; then grep -E "^  PASS" /tmp/mh_surface.log
  elif [ "$rc2" = "2" ]; then skip "G16 类面为空 ⇒ 不判"
  else bad "类面漏档、表与清单漂移，或版本口径不一致（见下）："; sed -n '1,12p' /tmp/mh_surface.log | sed 's/^/    /'; fi
else
  bad "G16 自身失效：四档对照没全过——这条判据不可信（见下）"; sed -n '1,12p' /tmp/mh_surface_self.log | sed 's/^/    /'
fi

echo "== G17 死格形状棘轮（断言实参位上不许出现参照期望值字面串）=="
# 起因见 scripts/vacuous_assert.py 文件头：path_test.mbt 那 49 条把 "true"/"false" 填进 pattern 位，
# 恒绿却占着"有夹具"的位置，把真分岔按住了。现存债务走棘轮（只许降不许升），不假装已经清零。
python scripts/vacuous_assert.py --selftest >/tmp/mh_vacuous_self.log 2>&1; rc=$?
if [ "$rc" = "2" ]; then
  skip "G17 扫描面为空 ⇒ 本轮不判"
elif [ "$rc" = "0" ]; then
  grep -E "^  PASS" /tmp/mh_vacuous_self.log
  python scripts/vacuous_assert.py >/tmp/mh_vacuous.log 2>&1; rc2=$?
  if [ "$rc2" = "0" ]; then grep -E "^  (PASS|INFO)" /tmp/mh_vacuous.log
  else bad "死格形状上升或基线缺失（见下）："; sed -n '1,10p' /tmp/mh_vacuous.log | sed 's/^/    /'; fi
else
  bad "G17 自身失效：三档对照没全过——这条判据不可信（见下）"; sed -n '1,10p' /tmp/mh_vacuous_self.log | sed 's/^/    /'
fi


echo "== G18 裸读 OS 时钟的收口闸（10-09 拍 P7：「可注入」必须是结构，不能只是约定）=="
# 现读：全仓**代码里**裸读 @env.now() 的只有一处——date/date.mbt 的 now_millis()（该件注释自述"全库唯一"）。
# 本轮第一次跑这条闸时被两处**注释文本**误报（sched 的"也不裸读 @env.now()"、id 的 spec 引文），
# 所以判据必须先剥注释再数——否则闸会在文档句上造假红。
# 闸的作用不是"证明这一处对"，而是**新增第二处就红**；上限按文件计数，防止在白名单文件里再加一处。
if python - <<'PY'
import io, os, re, shutil, subprocess, sys

ROOT = subprocess.run(["git", "rev-parse", "--show-toplevel"],
                      capture_output=True, text=True).stdout.strip()
CAP = re.compile(r"@?env\.now\(\)")
# 白名单 = 文件 → 允许出现的裸读处数上限（现读各 1）
ALLOW = {"date/date.mbt": 1}
SKIP_DIRS = {"_build", ".mooncakes", ".git", "docs", "scripts", "node_modules"}


def sites(base):
    """{相对路径: 裸读命中次数}"""
    out = {}
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames[:] = [d for d in dirnames
                       if d not in SKIP_DIRS and not d.startswith("_g18_fixture")]
        for fn in filenames:
            if not fn.endswith(".mbt"):
                continue
            full = os.path.join(dirpath, fn)
            rel = os.path.relpath(full, base).replace("\\", "/")
            text = io.open(full, encoding="utf-8", errors="replace").read()
            # 剥注释：整行注释 + 行尾注释都不算代码点
            kept = []
            for line in text.splitlines():
                s = line.strip()
                if s.startswith("//"):
                    continue
                cut = line.find("//")
                kept.append(line[:cut] if cut >= 0 else line)
            n = len(CAP.findall(chr(10).join(kept)))
            if n:
                out[rel] = n
    return out


def violations(found, allow):
    bad = []
    for rel, n in sorted(found.items()):
        if rel not in allow:
            bad.append("未登记的裸读点 %s（%d 处）" % (rel, n))
        elif n > allow[rel]:
            bad.append("%s 裸读 %d 处，超过上限 %d" % (rel, n, allow[rel]))
    return bad


found = sites(ROOT)
rc = 0

# 三档自证：缺一档这条判据就是许愿池
#  ① 坏样本必须被抓（在临时目录造一处裸读）
fx = os.path.join(ROOT, "_g18_fixture_probe")
os.makedirs(fx, exist_ok=True)
io.open(os.path.join(fx, "bad.mbt"), "w", encoding="utf-8").write(
    '///|\npub fn sneaky() -> UInt64 {\n  @env.now()\n}\n')
if not violations(sites(fx), {}):
    print("  FAIL G18 自身失效：造了一处裸读却没被抓到")
    rc = 1
#  ② 白名单本身不许误报
if violations(found, ALLOW):
    print("  FAIL 白名单被误报（判据与现读不符）：%s" % violations(found, ALLOW))
    rc = 1
#  ③ 上限那一档必须真起作用（把上限调成 0 ⇒ 必须报红）
if not violations(found, {"date/date.mbt": 0}):
    print("  FAIL G18 自身失效：把上限调成 0 仍不报红，「按文件计数」这半条是摆设")
    rc = 1
shutil.rmtree(fx, ignore_errors=True)

real = violations(found, ALLOW)
if real:
    print("  FAIL 裸读 OS 时钟超出登记：%s" % "；".join(real))
    rc = 1
else:
    print("  PASS 裸读点仍在登记的 %d 处白名单内（%s）"
          % (len(ALLOW), ", ".join("%s<=%d" % (k, v) for k, v in sorted(ALLOW.items()))))
print("     （现读命中明细：%s）" % (", ".join("%s:%d" % (k, v) for k, v in sorted(found.items())) or "无"))
sys.exit(rc)
PY
then ok "G18 绿"
else bad "G18 红（见上）"
fi

echo "== G19 同步性收口闸（10-09 拍：红线实质是「同步 + 零 OS 能力」，就得有闸看着「同步」这半）=="
# 现读：剥掉注释后，全仓代码里的 async 只在 sched/sched.mbt（7 处）与 sched/sched_test.mbt（7 处）。
# 这条闸不是"证明 sched 那两处对"，而是**第二个包一冒 async 就红**。AGENTS 第 2 条边界
# （纯计算半保持同步、零 OS 能力，"这条是外溢检查不是风格偏好"）此前只有文字：extern 有 G2、
# 裸读时钟有 G18，「全同步」这一条一直没绑判据——缺口表第 3 行点名的就是它。
# 扫两种面：*.mbt（剥整行与行尾注释）与 */README.mbt.md（**只数 ```mbt 围栏块里**）——
# 否则散文里一句"本包不做 async"会造出假红（G18 被自家注释误报两次，同一条教训）。
if python - <<'PY'
import io, os, re, shutil, subprocess, sys

ROOT = subprocess.run(["git", "rev-parse", "--show-toplevel"],
                      capture_output=True, text=True).stdout.strip()
OK_DIR = "sched"                 # 唯一登记过允许 async 的包目录
SKIP_DIRS = {"_build", ".mooncakes", ".git", "docs", "scripts", "node_modules"}
TOK = re.compile(r"\basync\b")


def strip_comments(text):
    kept = []
    for line in text.splitlines():
        s = line.strip()
        if s.startswith("//"):
            continue
        cut = line.find("//")
        kept.append(line[:cut] if cut >= 0 else line)
    return "\n".join(kept)


def code_text(path):
    raw = io.open(path, encoding="utf-8", errors="replace").read()
    if path.endswith(".mbt.md"):
        body = [m.group(2) for m in re.finditer(
            r"^```(mbt[^\n]*)\n(.*?)^```", raw, re.S | re.M)]
        return strip_comments("\n".join(body))
    return strip_comments(raw)


def sites(base):
    """({相对路径: 命中数}, 扫到的文件数)"""
    out, seen = {}, 0
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames[:] = [d for d in dirnames
                       if d not in SKIP_DIRS and not d.startswith("_g19_fixture")]
        for fn in filenames:
            if not (fn.endswith(".mbt") or fn.endswith(".mbt.md")):
                continue
            full = os.path.join(dirpath, fn)
            rel = os.path.relpath(full, base).replace("\\", "/")
            seen += 1
            n = len(TOK.findall(code_text(full)))
            if n:
                out[rel] = n
    return out, seen


def violations(found):
    return ["未登记 async 的包 %s（%d 处）" % (rel, n)
            for rel, n in sorted(found.items()) if not rel.startswith(OK_DIR + "/")]


found, seen = sites(ROOT)
rc = 0

# ① 尺子先要有刻度：真实扫描必须读到 sched 那两处。读到 0 个对象就给"没有违规"是自证空转
if not found or OK_DIR + "/sched.mbt" not in found:
    print("  FAIL G19 自身失效：扫描面里没读到 %s/sched.mbt 的 async（现读命中 %s，扫过 %d 件）"
          "⇒ 这条闸此刻什么都测不到" % (OK_DIR, found, seen))
    rc = 1
# ② 坏样本必须被抓：临时造一个不在白名单目录里的 async 件（扫完立刻删）
fx = os.path.join(ROOT, "_g19_fixture_probe")
os.makedirs(fx, exist_ok=True)
io.open(os.path.join(fx, "bad.mbt"), "w", encoding="utf-8").write(
    "///|\npub async fn sneaky() -> Unit {\n  println(\"x\")\n}\n")
try:
    fx_found, _ = sites(fx)
    if not violations(fx_found):
        print("  FAIL G19 自身失效：造了一处非白名单 async 却没被抓到（现读 %s）" % fx_found)
        rc = 1
finally:
    shutil.rmtree(fx, ignore_errors=True)
# ③ 白名单不许误报：现读的 sched 必须判干净
bad = violations(found)
if bad:
    print("  FAIL 非白名单包里出现 async：%s" % "；".join(bad))
    rc = 1
# ④ 目录归属得真是那道口子：把 sched 挪出白名单目录名 ⇒ 必须报红
moved = {("other/" + k if k.startswith(OK_DIR + "/") else k): v for k, v in found.items()}
if not violations(moved):
    print("  FAIL G19 自身失效：把 sched 挪出白名单后仍然不红（判据对目录归属是瞎的）")
    rc = 1
if rc == 0:
    print("  PASS 现读：扫过 %d 个代码/文档件，async 只在 %s" % (seen, "，".join(
        "%s=%d 处" % (k, v) for k, v in sorted(found.items()))))
sys.exit(rc)
PY
then ok "G19 绿"
else bad "G19 红（见上）"
fi


echo
if [ "$FAILS" = "0" ]; then
  echo "GATE GREEN：0 失败，$SKIPS 项 SKIP（SKIP 不等于通过，逐条看理由）"
else
  echo "GATE RED：$FAILS 项失败，$SKIPS 项 SKIP"
fi
[ "$FAILS" = "0" ]
