# 第 7 节 · `mapx`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 07 行（`mapx`）“用例”列的逐字原文。
编号 07 是稳定 ID：与该包契约 `docs/spec/07-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `mapx` | `MapUtil` / `Table`(二维表) / `BiMap` / `CaseInsensitiveMap` | **已实现**（10-05 两批都落地，28 条读数三档一致，`.mbti` 零漂移） | `docs/spec/07-mapx.md` | 28 条（20 断言块 + 8 文档块）；边界现读 core 得出：`Map` **本身就是插入序**（33 条公开面里有 `of/new/merge/retain/update_or_default/get_or_init/keys/values/to_array`）⇒ 不再造 LinkedHashMap、一个都不重新包装；补的只有 `BiMap`（双向唯一，`put` 撞值**整次不生效** + 显式 `force_put`）、`CiMap`（折叠只覆盖 ASCII，原样键取首次写入）、`filter_map`、`rename_key`（新键落末尾、不改输入、`old == new` 不自删）、**第二批 `Table`**（双索引、行优先展开、列向顺序跟 `rows()`、删到空连行列键一起摘、值不建索引是明码取舍）。三条"不跟随 hutool"都有源码级依据（`BiMap.put` 会让双向索引不一致；`renameKey` 原地改且 `old == new` 时把条目自己删掉） |
````
