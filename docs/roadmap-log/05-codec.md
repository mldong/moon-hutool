# 第 5 节 · `codec`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 05 行（`codec`）“用例”列的逐字原文。
编号 05 是稳定 ID：与该包契约 `docs/spec/05-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `codec` | `Base64`(url-safe·MIME·宽松解码) / `Base32` / `Base58`(含 Check) / `Base62` / `RadixUtil` / `x-www-form-urlencoded` / `UrlBuilder` | **已实现**（10-05 两批全落地，wasm / js / wasm-gc 三档读数一致，`.mbti` 零漂移；**10-08 第四批（纯补档）**：三条从没打过的失败通道（Base64/Base32 各一份 `BadPadding`、authority 只写一个 `@`）+ 三处 RFC 3986 形状档，本包未覆盖行 **9 → 0**、自此退出 G15 清单；一块推导被真跑打回（`/x/./../y/.` ⇒ `/y/` 不是 `/x/y/`）记在 spec §11；块数现读 `moon test --package codec`） | `docs/spec/05-codec.md` | 38 条（25 断言块 + 13 文档块）全绿；读数走 RFC 4648 §10 向量 + 两套独立实现互算（Base58/62 无 RFC），form 档以 HTML 序列化器 ↔ Node `URLSearchParams` 双路互算、URL 档以 RFC 3986 §3/§5.2.4/§6.2.2 加 Python `urlsplit` 对跑；`BCD` 判**不做**（上游已 `@Deprecated`、语义即 core hex），§5.2.2 引用解析与 IDN 另批 |
````
