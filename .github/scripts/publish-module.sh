#!/usr/bin/env bash
# 整模块发布到 mooncakes，可重入：已发过 ⇒ 跳过；没发过 ⇒ publish；发完再复核索引确实命中。
#
# 三条设计理由（都是"恒绿的假判据比红灯危险"那一族）：
#  1) CLI 退出码不作数。实测 `moon publish --dry-run` 服务端回 `202 Accepted`，CLI 仍以非 0 退出
#     并打印 `Error: moon publish failed`。⇒ 判状态只读输出里的 `Server status:` 行。
#  2) "已发布"要能判出来，重跑才不会撞重复版本。索引布局（moon 0.1.x 实测）：
#     $MOON_HOME/registry/index/user/<user>/<mod>.index，每行一个 JSON 对象，
#     `"name"` 与 `"version"` 在同一行，可直接整行匹配。⇒ 命中就跳过，不 bump 版本号绕。
#  3) 成功必须以**副作用真发生**为准：publish 之后 `moon update` 再查索引，
#     索引里没有这个版本就是没发出去，不许只看一句 2xx 就宣布成功。
#
# 用法：publish-module.sh            # 真发（已在注册表则跳过）
#       publish-module.sh --dry-run  # 只走包体校验与状态判读，不上传
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"

DRY=""
[ "${1:-}" = "--dry-run" ] && DRY="--dry-run"

ver=$(sed -nE 's/^version[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' moon.mod | head -1)
mod=$(sed -nE 's/^name[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' moon.mod | head -1)
[ -n "$ver" ] && [ -n "$mod" ] || { echo "!! moon.mod 里读不到 name/version"; exit 1; }
user="${mod%%/*}"
short="${mod##*/}"
idx="${MOON_HOME:-$HOME/.moon}/registry/index/user/$user/$short.index"

moon update >/dev/null 2>&1 || echo "   （moon update 失败，用现有索引继续判读）"

if [ -z "$DRY" ] && [ -f "$idx" ] && grep -q "\"name\":\"$mod\".*\"version\":\"$ver\"" "$idx"; then
  echo "SKIP  $mod@$ver 已在注册表 ⇒ 不重复发布（重入安全）"
  exit 0
fi

out=$(mktemp)
if [ -n "$DRY" ]; then
  echo "DRY   moon publish --dry-run（$mod@$ver，不上传）"
  moon publish --dry-run >"$out" 2>&1
else
  echo "PUB   moon publish（$mod@$ver）"
  moon publish >"$out" 2>&1
fi
cat "$out"

# 判状态只认状态行：202 = 受理，409 = 该版本已存在（都算通道本身没坏）
if grep -qE 'Server status: (202|409)' "$out"; then
  status=$(grep -oE 'Server status: [0-9]+' "$out" | head -1 | awk '{print $3}')
  echo "   状态行：$status"
else
  echo "   ❌ 输出里没有 Server status 行 ⇒ 上传环节之前就把活失败了（看上面的原始输出），本次不算成功"
  rm -f "$out"; exit 1
fi

if [ -n "$DRY" ]; then
  echo "   DRY 通道自检通过：包体校验（解压产物再跑 moon check）与状态判读都走完了，未上传。"
  rm -f "$out"; exit 0
fi

# 副作用复核：索引里必须出现这个版本
moon update >/dev/null 2>&1 || true
if [ -f "$idx" ] && grep -q "\"name\":\"$mod\".*\"version\":\"$ver\"" "$idx"; then
  echo "   ✅ 复核注册表索引：$mod@$ver 已在册"
  rm -f "$out"; exit 0
else
  echo "   ❌ 索引里没有 $mod@$ver —— 这次是真没发出去（或索引尚未刷新，稍后重跑本步即可，重入安全）"
  rm -f "$out"; exit 1
fi
