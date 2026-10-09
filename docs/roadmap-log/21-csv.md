# 21 · `csv`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 21 行（`csv`）“用例”列的逐字原文。
编号 21 是稳定 ID：与该包契约 `docs/spec/21-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `csv` | `CsvReader` / `CsvWriter`（RFC 4180） | **已实现**（10-06 两笔：契约 `PR-A` + 落地；10-08 默认档补档 +18 块（`csv_parse`/`field_count`/`get`/`get_row` 四件此前零覆盖，见 `21-csv.md` §8）；三档一致 432 = 绿 432/红 0。落地轮另改正 PR-A 写侧 84 条期望的锚点——腿只 `flush()` 而参照的 `endingLineBreak` 到 `close()` 才落笔） | `docs/spec/21-csv.md` | API 只收 `String`/`Bytes`，不碰文件 |
````
