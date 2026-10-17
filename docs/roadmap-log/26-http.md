# 26 · `http`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 26 行（`http`）的逐字原文。
编号 26 是稳定 ID：与该包契约 `docs/spec/26-http.md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `http` | 不是 hutool 对位件——**可注入的 HTTP 传输端口 + 官方 `moonbitlang/async/http` 薄适配**（需求登记：本仓 Issues #4；对象存储线的 HTTP 层归口，签名协议要求 URL/头/正文原样上线） | **已实现**（10-17 两笔：端口形状在存储线五条真腿上实测磨出；官方件 0.22.4 无 per-request timeout ⇒ 适配层自 bounds；头表是 Map ⇒ 重复同名头响亮拒绝；缺省加 `Accept-Encoding` 并透明解压 ⇒ 恒显式带 `identity` 压掉。假传输 5 条 + 真端点 4 腿绿、变异 5 刀全红（含挂死形状）。只承诺 native+wasm：官方 http 包对 js/wasm-gc 是占位件（其 `unimplemented.mbt` 的 `#cfg` 即证），摘档照 sched 先例） | `docs/spec/26-http.md` | 详记 [`roadmap-log/26-http.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/26-http.md) |
````
