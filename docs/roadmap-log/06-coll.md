# 第 6 节 · `coll`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 6 行（`coll`）的“用例”列原文；
状态与条数的真相见该行与文末 READINGS 生成块，索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `coll` | `CollUtil` / `ListUtil` / `IterUtil` 的高频子集 | **已实现**（10-05，16 条全绿，wasm / js / wasm-gc 三档读数一致，`.mbti` 零漂移） | `docs/spec/06-coll.md` | 16 条（11 断言块 + 5 文档块）全绿；core `Array` 对外可写的方法几十条量级、扫描口径写在 spec §1（`chunks`/`dedup`/`flatten`/`zip`/`join`/`sort_by_key`/`shuffle`/`search_by` 全都有），本包只补**读源码数出来的缺口**：分组、两桶划分、保序去重与按键去重、频次表、分页、数组版并/交/差、`Array` 上的极值与按键极值；对拍腿三条（`distinct`↔`dedup`、`page`↔`chunks`、`maximum`↔`Iter::maximum`）；`index_where` 那种"找不到返 `-1`"的哨兵**不做**（core `search_by` 给 `Int?`） |
````
