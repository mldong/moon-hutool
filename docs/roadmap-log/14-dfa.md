# 14 · `dfa`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 14 行（`dfa`）“用例”列的逐字原文。
编号 14 是稳定 ID：与该包契约 `docs/spec/14-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `dfa` | `WordTree` / `SensitiveUtil` / `StopChar` | **已实现**（10-05 两笔：契约 `822b8ef` + 落地；10 块全绿，wasm / js / wasm-gc 三档一致，`.mbti` 只变内部形状） | `docs/spec/14-dfa.md` | 10 块全绿（`dfa_test.mbt` 6 块 30 组参照腿读数 + `README.mbt.md` 4 个文档块）；9 件公开函数 + `WordTree`/`FoundWord` 两型 + 停顿字符表。**前置普查现读**：`cn.hutool.dfa` **不在 hutool-core**——core 的 jar 只有 `cn/hutool/core/**`，dfa 是独立 artifact `hutool-dfa-5.8.35.jar`（12,774 字节、7 个 class）⇒ 参照腿要换件取，别拿 core 的 jar 判"类不存在"。三条实测事实决定契约形状：① **`(density, greed)` 只有三档语义**——`greed` 在 `density=false` 时完全惰性（参照实现 `if (!isDensityMatch) { i = j; break }` 排在贪婪判定之前），javadoc 单列的"最长匹配"在实测档不成立，默认档是**最左起点取最短**；② `match()` 出口是 `found`（含词中停顿字符那一串）而不是词表里的 `word`（`FoundWord#toString()` 源码如此），跟随并两形都放进 `FoundWord`；③ **码表规模 303/327**——`STOP_WORD` 去重 303 位，`isStopChar` 全 BMP 真值 327 位，差集 24 位正是 `Character.isWhitespace` 那一半，且 **U+2007 与 U+202F 实测都不在表里**（按"空白字符"常识建表会多收两位）。用例只钉规模读数 + 六条边界谓词，**不逐位钉表**（钉 327 位＝把表抄第二遍）；位置口径 **UTF-16 码元**，与参照腿同读、与 `re` 包同一条（含 emoji 的两条夹具是证据，两侧读数 `ab@2-3`）。不跟三件都带理由：`SensitiveUtil` 静态全局表与 `containsSensitive(Object)` 反射档、`clear`、`setCharFilter`；`match` 是 MoonBit 保留字，两件查询改名 `first_match`/`first_found`。落地轮 **30 组参照腿读数一次转绿**（期望值一字未改、零分岔、编译开局就带 `-encoding UTF-8`）；六条变异逐条有块红（整段跳过 2 / `word`-`found` 写反 3 / 停顿字符进 `word` 3 / `limit` 边界 2 / 二分上界少一项 1 / 词首 `i++` 2），**另有一条"空变异"记在 spec §6**：`<` 写成 `<=` 因等值分支排在前面而语义等价、0 红——变异要先问它能不能改变某个可观测读数 |
````
