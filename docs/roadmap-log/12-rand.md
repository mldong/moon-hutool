# 第 12 节 · `rand`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 12 行（`rand`）的“用例”列原文；
状态与条数的真相见该行与文末 READINGS 生成块，索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `rand` | `RandomUtil` / `WeightRandom` | **已实现**（10-05 两笔：契约 `5f5097f` + 落地） | `docs/spec/12-rand.md` | 11 块全绿（`rand_test.mbt` 6 块 43 条断言 + `README.mbt.md` 5 个文档块），三档一致；19 件公开项 + `RandError` 四档，签名一律收 `@random.Rand`（**随机源显式注入，库内一次都不取熵**）。这一包的期望值形状与前几家不同：**没有一条是“跑一次记输出”**——参照实现 55 个 `public static` 里没有一个收 `Random` 参数（实测 `javap`），结果序列不可复现，所以只钉四类钉得死的东西：常量表原样（四张表反射读字段，实测 `BASE_CHAR_NUMBER` 62 字符且**大写在前**）、**单点定义域**（`(0,1)` 默认 ⇒ 恒 `0`；不含下含上 ⇒ 恒 `1`；`(0,2)` 双不含 ⇒ 恒 `1`，各抽 3000 次验过）、异常与空输入档（非正 `n`、空域、空表、空集合、`count` 超过去重数）、与流无关的不变量（长度恰为 `count`、字符 ⊂ 表、去重档互不相同、**零权重永不中选**）。三条实测行为改写了直觉：`randomString(0)` 参照实现给**长度 1** 的串（本包给空串，§5 第 1 行）、`randomEle(list, limit)` 的第二参是“只看前 N 个”而不是重试次数、`randomStringUpper` 的结果集是 **36 字符**（62 表里本来就带数字，转大写后数字仍在）。**secure/pseudo 双通道判不做**：core 只有一条 chacha8 流，且实测 `Rand::new()` 在无熵档静默回落固定种子——承诺“安全”没有凭据；`randomChinese`/`randomDay`/`randomDate` 不做（一个要码表、两个读墙钟），`random_float`/`random_double`/`randomBytes` 留第二批。本批的 core 侧只有**源码形状**（`Rand::int(limit=0)` 是取全域而不是报错、`chacha8` 要求 32 字节种子），三条待复测项在落地轮全部跑完并进了 spec §4 第 3~5 条：`int(limit=0)` 不报错而是"取全域"、`int(limit<0)` 走 `abort` 且 **`try` 抓不到 panic**（探针就停在那一行）、同一脚本化 `Source` 下三档输出逐字节相同（本包跨档一致承诺的全部凭据）。三条变异对照逐条有块红（上界 `+1` 丢掉 / 长度循环挪一位 / 累计桶边界挪一位）；落地当场还了一处手工落稿的漏——`(0,1)` 那条少写 `incl_max=true`，把空域当成了单点域，单独一笔更正。去重档的 `Eq` 界随实现补进签名（`.mbti` 跟着变） |
````
