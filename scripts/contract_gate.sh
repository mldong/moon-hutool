#!/usr/bin/env bash
# moon-hutool 契约门禁 G1~G13
#
# 原则：每条判据都必须"真跑过且敢报红"。凡当前环境跑不了的项，显式打 SKIP + 理由，
# 绝不伪装成 PASS（恒绿但没测的套件比红灯更危险）。
#
# 用法：
#   scripts/contract_gate.sh                 # 全跑（本机默认 wasm 一档做深，其余档做 check）
#   GATE_TARGETS="wasm" scripts/contract_gate.sh
#   GATE_FREEZE_BASE=<commit> scripts/contract_gate.sh   # PR-B 时打开期望值冻结检查（G5）
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"
export PYTHONIOENCODING=utf-8
FAILS=0; SKIPS=0
ok()  { echo "  PASS $*"; }
bad() { echo "  FAIL $*"; FAILS=$((FAILS+1)); }
skip(){ echo "  SKIP $*"; SKIPS=$((SKIPS+1)); }
GATE_TARGETS="${GATE_TARGETS:-wasm js}"
BASELINE_TESTS="${BASELINE_TESTS:-478}"

echo "== G1 零依赖（moon tree 无第三方节点 + moon.mod 无 deps）=="
if tree_json=$(moon tree --json 2>/dev/null) && [ -n "$tree_json" ]; then
  if python - "$tree_json" <<'PY'
import json,sys
d=json.loads(sys.argv[1]); bad=[]
def walk(n):
    name=n.get("name") or n.get("package") or ""
    if name and not name.startswith("moonbitlang/core") and not name.startswith("mldong/moon-hutool"):
        bad.append(name)
    for c in n.get("deps") or n.get("children") or []: walk(c)
roots=d if isinstance(d,list) else [d]
for r in roots: walk(r)
print("\n".join(sorted(set(bad))) if bad else "")
sys.exit(1 if bad else 0)
PY
  then bad=""
    if grep -qE '^\s*(deps|import)\s*=' moon.mod; then bad="moon.mod 存在 deps/import 段"
    else bad=$(find . -name moon.pkg -not -path './_build/*' -exec grep -l '^\s*"moonbitlang/\(async\|x\|regexp\|moonback\)\|"\(moonbitstack\|Betterlol\|mizchi\|bobzhang\|justjavac\|tonyfettes\)/' {} \; | head -3)
    fi
    [ -z "$bad" ] && ok "零第三方节点，moon.mod 无 deps，包级无注册表依赖" || bad "发现第三方：$bad"
  else bad="树里有第三方节点（见上）"
  fi
else skip "moon tree --json 不可用（本机 moon 版本或网络）；退化为 moon.mod/moon.pkg 静态扫描"
  grep -qE '^\s*(deps|import)\s*=' moon.mod && bad "moon.mod 有 deps" || ok "moon.mod 无 deps"
fi

echo "== G2 零 FFI =="
n=$(grep -rn 'extern "' --include='*.mbt' . 2>/dev/null | grep -v '_build/' | wc -l | tr -d ' ')
[ "$n" = "0" ] && ok "全仓 extern 命中 0" || bad "有 $n 处 extern —— 违反零依赖定义"
n2=$(grep -rl 'native-stub' --include='moon.pkg' . 2>/dev/null | wc -l | tr -d ' ')
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
if moon fmt --check >/tmp/mh_fmt.log 2>&1; then ok "moon fmt --check 干净"; else bad "有文件需 moon fmt：$(grep -c . /tmp/mh_fmt.log) 行输出"; fi
if command -v git >/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
  moon info >/tmp/mh_info.log 2>&1 || bad "moon info 执行失败"
  if git diff --quiet -- '*.mbti' 2>/dev/null; then ok ".mbti 无漂移（公开接口未意外变动）"; else bad ".mbti 有未提交漂移——API 变动须显式评审"; fi
else skip "非 git 工作树，跳过 .mbti 漂移检查"
fi

echo "== G5 期望值冻结（PR-B）=="
if [ -n "${GATE_FREEZE_BASE:-}" ]; then
  ch=$(git diff --name-only "$GATE_FREEZE_BASE" -- '*_test.mbt' 'docs/spec/*' 2>/dev/null)
  if [ -z "$ch" ]; then ok "测试与 spec 未被实现 PR 触碰"
  elif [ "${ALLOW_EXPECTATION_CHANGE:-0}" = "1" ]; then skip "已授权改动：$(echo "$ch" | tr '\n' ' ')"
  else bad "实现期改了期望值/契约，须单独一笔并给外部读数来源：$ch"; fi
else skip "未给 GATE_FREEZE_BASE（仅 CI 的 PR-B job 与该检查有关）"
fi

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
BAN='moon-hutool-plan|协调仓|14 栈|第 14 栈|夜班|申报书|codeup|glm-flash|hub docs|见 hub|口径 [0-9]'
hits=$(git ls-files 2>/dev/null | grep -v '^scripts/' | xargs -r grep -nE "$BAN" 2>/dev/null | head -5)
if [ -z "$hits" ]; then ok "跟踪文件里无内部叙事引用（禁词表 $BAN）"
else bad "公开仓出现内部引用：$hits"; fi
# 自检：往临时文件灌一条禁词，确认这条扫描真的抓得到（否则 G9 是永真格）
probe=$(mktemp ./_g9_probe_XXXX.md 2>/dev/null || echo ./_g9_probe.md)
echo "参见 hub docs/moon-hutool-plan.md 与 14 栈口径 6" > "$probe"
caught=$(grep -nE "$BAN" "$probe" 2>/dev/null | wc -l | tr -d ' ')
rm -f "$probe"
[ "$caught" -ge 1 ] && ok "阳性对照正常（坏样本被抓到）" || bad "G9 自身失效：坏样本没抓到，这条判据不可信"


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
# 合法性判据取**函数体还是不是 abort**，不取"用例绿没绿"——后者要再跑一遍逐包测试，慢且与 G11 重复。
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
    still_abort = any('abort("moon-hutool' in io.open(f, encoding="utf-8", errors="replace").read()
                      for f in bodies)
    if not still_abort:
        bad.append(os.path.relpath(pkg, root))
print(" ".join(bad))
PYEOF
}
viol=$(skel_check .)
if [ -z "$viol" ]; then ok "在用的 warnings 豁免都对应还没实现的包"; else bad "实现已落地却还压着骨架豁免：$viol"; fi
# 阳性对照：造一个"体里已无 abort 却仍带豁免"的假包，必须被抓到
fx=$(mktemp -d ./_g12_fixture_XXXXXX 2>/dev/null || echo ./_g12_fixture)
mkdir -p "$fx/fakepkg"
printf 'warnings = "-unused_constructor"\n' > "$fx/fakepkg/moon.pkg"
printf 'pub fn a() -> Int { 1 }\n' > "$fx/fakepkg/a.mbt"
caught=$(skel_check "$fx")
rm -rf "$fx"
[ -n "$caught" ] && ok "阳性对照正常（假包的豁免被抓到：$caught）" || bad "G12 自身失效：坏样本没抓到，这条判据不可信"

echo "== G13 spec 序号 == 逐包表行号（号是稳定 ID，不许与表各漂各的）=="
if python scripts/sync_status.py --numbers >/tmp/mh_numbers.log 2>&1; then
  grep -E "^  PASS" /tmp/mh_numbers.log
else
  bad "序号与表行号不一致（见下）："; sed -n '1,10p' /tmp/mh_numbers.log | sed 's/^/    /'
fi

echo
if [ "$FAILS" = "0" ]; then
  echo "GATE GREEN：0 失败，$SKIPS 项 SKIP（SKIP 不等于通过，逐条看理由）"
else
  echo "GATE RED：$FAILS 项失败，$SKIPS 项 SKIP"
fi
[ "$FAILS" = "0" ]
