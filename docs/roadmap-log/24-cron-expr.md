# 第 24 节 · `cron_expr`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 24 行（`cron_expr`）的“用例”列原文；
状态与条数的真相见该行与文末 READINGS 生成块，索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `cron_expr` | `cn.hutool.cron.pattern.*`（`CronPattern` + `parser/{PatternParser,PartParser}` + `matcher/*` + `Part`，与第 19 行同一族） | 未开工（**只有契约，目录与签名都还没建**）：定位＝把表达式层从已交付的 `cron`（第 19 行）拆出来独立发布，给不需要触发面的用户一条只剩 `core` 依赖、四档承诺不变的选择。⚠ 动的是已交付面，去重两案待拍：A 并存分层（表达式实现两份，靠比对门禁按住）/ B 把第 19 行改成薄转发（复走 364 块已冻期望）。 **owner 10-09 拍定不建**：`sched` 已依赖 `cron`+`date`，拆包不会少一个依赖，只多一份重复实现；' 该行长期保持未开工，契约文档作决策留痕 | `docs/spec/25-cron_expr.md` | 无 |
````
