# 第 9 节 · `conv`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 9 行（`conv`）的“用例”列原文；
状态与条数的真相见该行与文末 READINGS 生成块，索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `conv` | `Convert`（无反射版） | **已实现**（10-05 两笔都落地，wasm/js/wasm-gc 三档一致；10-08 界外与符号档补档 +22 块，同日另一笔把里面翻出来的「`0x` 带符号被取值层拒」按 #9.9 在取值层收掉——hex 族 13 档两侧逐条同判、一条改判都不需要，缺陷登记随之闭合（`09-conv.md` §9.1 → §10）；块数现读 `moon test --package conv`，收口笔为 81/81 绿），`.mbti` 零漂移） | `docs/spec/09-conv.md` | 33 块（`conv_test.mbt` 23 + `README.mbt.md` 10）全绿；17 条公开项 + `JsonConv[A]` 别名 + 唯一 raise 面 `BadPath`。三处架构差按契约实现：**目标类型在函数名里、注册表换成一等闭包 `chain`**（对位 `ConverterRegistry:262` 的 `isCustomFirst=true`）、`Number` 的 `repr` 优先（`9007199254740993` 不撞 Double 精度，实测 19 条 `(d, repr)` 形状）、越界/locale 分组一律 `None`（31 条实测分岔逐条给理由，含 zh_CN↔de_DE 同输入 41 条两读）；**文法判定自写、core 只求值**——实测 core `parse_int` 还收 `1_000` 与 `NaN`/`Infinity`，照单全收就等于跟随 Java 的 `NumberFormat` 分支。实现期更正过两处期望值（镜像腿自身缺陷，读数来源记在 spec §4 第 9~10 条腿）；SBC/DBC 与字节序族 8 件留在第二批 |
````
