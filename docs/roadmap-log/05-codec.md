# 第 5 节 · `codec`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 05 行（`codec`）“用例”列的逐字原文。
编号 05 是稳定 ID：与该包契约 `docs/spec/05-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `codec` | `Base64`(url-safe·MIME·宽松解码) / `Base32` / `Base58`(含 Check) / `Base62` / `RadixUtil` / `x-www-form-urlencoded` / `UrlBuilder` | **已实现**（10-05 两批全落地，wasm / js / wasm-gc 三档读数一致，`.mbti` 零漂移；**10-08 第四批（纯补档）**：三条从没打过的失败通道（Base64/Base32 各一份 `BadPadding`、authority 只写一个 `@`）+ 三处 RFC 3986 形状档，本包未覆盖行 **9 → 0**、自此退出 G15 清单；一块推导被真跑打回（`/x/./../y/.` ⇒ `/y/` 不是 `/x/y/`）记在 spec §11；块数现读 `moon test --package codec`） | `docs/spec/05-codec.md` | 38 条（25 断言块 + 13 文档块）全绿；读数走 RFC 4648 §10 向量 + 两套独立实现互算（Base58/62 无 RFC），form 档以 HTML 序列化器 ↔ Node `URLSearchParams` 双路互算、URL 档以 RFC 3986 §3/§5.2.4/§6.2.2 加 Python `urlsplit` 对跑；`BCD` 判**不做**（上游已 `@Deprecated`、语义即 core hex），§5.2.2 引用解析与 IDN 另批 |
````

---

**10-10 批①（PR-A 契约冻结笔）**：codec 包新增 §12 两件（`codec/url_assemble.mbt`）：
`data_uri(mime, charset, data)` 与 `data_uri_base64(mime, base64)`，冻结期望 **177 条**、手打零条
（腿 `scripts/UrlPureLeg.java`）。四条形状全都有读数、都不"修正"：数据**不编码**（`100%` 照出）、
charset 串**不校验**（`GBK`/`nope` 原样带过，空串 ⇒ 整段 `;charset` 省略）、base64 **不校验**、
mime 为空出 `data:;base64,...`。参照的 null 入参在它那边落成字符串 `"null"`，本库无该形状。

`URLUtil` 其余两半的去向：`encodeBlank` 的谓词与 `text` 那张 35 位空白表同源 ⇒ 收在
`01-text.md` §1.19（归处也写进 `00-hutool-map.md`）；`completeUrl` **改判 deferred**——
批①开工时把它当纯字符串件，腿跑完推翻了这个前提：`java.net.URL` 的协议白名单决定
"是不是绝对 URL"（`data:`/`tel:`/`urn:`/`javascript:` 一律 `ERR:UtilException`）、无 scheme 的基串
被补成 `http://`、`http://a` + `./b` 那点段**不归一**而 `http://a.com/api/` + `../b` 又归一
⇒ 同一个函数两套尾巴。逐条理由与本包 §8 的 RFC 3986 归一为什么不能直接替它，写在
`05-codec.md` §12.2。

本笔状态：`moon check` 零警告；codec 有 **1 块红**（§12 骨架块）⇒ READINGS 此刻记 `契约已冻结`
是工具按红绿分的类，本包 §2~§11 那几批 0 红、0 改动，PR-B 落地后自动回 `已实现`。
