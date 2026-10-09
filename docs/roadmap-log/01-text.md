# 第 1 节 · `text`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 01 行（`text`）“用例”列的逐字原文。
编号 01 是稳定 ID：与该包契约 `docs/spec/01-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `text` | `StrUtil` / `CharSequenceUtil` / `NamingCase` / `StrFormatter` | **已实现**（10-04，wasm/js/wasm-gc 三档读数一致，native 档由 CI 出证） | `docs/spec/01-text.md` | 13 条断言 + 10 个文档块，全绿 |
````

---

**10-10 批①（PR-A 契约冻结笔，非落地笔）**：text 包新增 **14 件**（`text/escape.mbt` 十三件 +
`text/replacer.mbt` 三件里的公开面，签名现读 `text/pkg.generated.mbti`）：

- 实体族四件 `escape_xml` / `unescape_xml` / `escape_html4` / `unescape_html4`（spec §1.16）
- 百分号族五件 `escape` / `escape_all` / `escape_by` / `unescape` / `safe_unescape`（§1.17）
- UnicodeUtil 四件 `to_unicode` / `to_unicode_all` / `unicode_of` / `unicode_to_string`（§1.18）
- `encode_blank`（§1.19，对位挂在 `URLUtil` 上、谓词与本包 `is_blank` 同源那张 35 位表）
- 替换引擎 `lookup_replacer` / `replacer_chain` / `Replacer::replace`（§1.20）

冻结期望 **779 条**（`escape_test.mbt` 699 + `replacer_test.mbt` 18 + `encode_blank_test.mbt` 62），
**手打零条**——腿五条：`EscapeLeg`（语料与闭环）、`EscapeLeg2`（逐码点扫过滤器与 unescape 出口）、
`EscapeLeg3`（"谓词==行为"的 BMP 全枚举对撞，`MISMATCH|count|0`）、`EntityTableLeg`（反射读四个类
自己的 `String[][]` 实体表 + 数字实体/长键/别名 33+45+22+11 档）、`ReplacerLeg`（择路四判据 +
`protected` 档的逐位 step）、`UnicodeScan`（`to_unicode` 原样档 = `0020-007e` 一段）、
`UrlPureLeg`（`encodeBlank` 的 W 行逐位 + 15 段空白区间表）。生成器 `gen_escape_family.py` /
`gen_batch1_rest.py`，读数与判据口径全在 spec §1.15~§1.20。

三条读数**推翻常识**的账，写在这里防止实现轮"顺手改回去"：
① `escape` 的非 ASCII 出 **`%uXXXX`**（IE 风格、逐 UTF-16 码元），不是 UTF-8 的 `%E4%B8%AD`；
② `escape` 的"不转义集"是 `isDigit‖isLowerCase‖isUpperCase‖"*@-_+./"`（javap -c 现读），
   **不是** `isLetterOrDigit`——所以 ª 留、ƻ(Lt) 与 あ(Lo) 转、Ⅰ(Other_Uppercase) 留，146 段区间表带进库；
③ 参照的逐步钩子返回**负数**时它自己的驱动循环永不收敛（腿两秒守护下 16.5 亿次调用），
   所以本库**不开放**该钩子，公开面只有整串替换。

本笔状态：`moon check --target wasm/js/wasm-gc` **0 警告 0 错误**、`.mbti` 已 `moon info` 重生成；
`moon test` 1548 条里 **17 红**（text 14 块 + path 2 + codec 1，全是本批骨架块），
红是 PR-A 设计态、函数体是 `PR-B：契约骨架` 的 abort。
因此 READINGS 生成块此刻把 text/path/codec 记成 `契约已冻结`——**这是工具按"有没有红"分的类，
不是本包整体退回契约态**：本包已有 20 件全绿用例一条没动，PR-B 落地后计数自动回到 `已实现` 23。
文档可执行示例（`text/README.mbt.md` 的 `​```mbt check` 块）按交付形状归 PR-B——此刻写进去就是死示例。
同笔附带把空白码表收口成整仓一张（`is_blank_char` 转公开、`ini`/`typex` 两份副本删；
两处照 core 抄的旧账更正：U+0085 参照不算空白、U+001C–U+001F 参照算，另一处 U+200C 是 5.8.37 换代新加的），
细节在 `01-text.md` §1.1/§1.14 与 `22-ini.md` §3-1。
