# 第 11 节 · `valid`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 11 行（`valid`）的“用例”列原文；
状态与条数的真相见该行与文末 READINGS 生成块，索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `valid` | `Validator`（79 个 `public static` 里的正则族） | **已实现**（10-05 两笔：契约 `a772ca9` + 落地） | `docs/spec/11-valid.md` | 11 块全绿（`valid_test.mbt` 5 块 127 条断言 + `README.mbt.md` 6 个文档块），三档一致、`.mbti` 零漂移；签名 `String -> Bool`（两件限长的多两个 `Int`），**无错误面**——码表是包内常量，编不过是本包写错，不泄给调用方。两腿对撞：**腿 A** 真 hutool-core-5.8.35 + JDK 17.0.14 跑 `Validator`（393 行读数，且由参照腿自己吐出 `RegexPool`/`PatternPool` 每条 `Pattern` 的**源文与 flags**，码表来源不手抄）、**腿 B** core `@string.Regex` 探针在**同一批样本**上跑（242 行 × wasm/js/wasm-gc 三档逐字节相同）⇒ **127 条一致、0 条分岔**。这一批的立场是"**改写到命中集相同为止**"，两条实测改写规则进了 spec §4：① 字符类里的 `-` 不能与别的字符并排（`[:-]`、`[-:]` 实测编译期报错，只有写成择路 `(:\|-)` 才编得过）；② `isUUID` 用的不是 `UUID` 那条常量——实测它同时认 32 位无横线与混合大小写，按常量改写会漏一档。**没进本批的都带着理由挂账**：`is_email`（`\xHH` 类）、中文族（javac 预处理后落成代理对码元区间）、`is_letter`/`is_upper_case`/`is_lower_case`（参照实现是 Unicode 类别表，core 只有 ASCII 档谓词 ⇒ 先拍口径）、`is_birthday`（走 `find()` + 取组 + `DateUtil.thisYear()` 读时钟）、`is_url`（参照实现走 `java.net.URL` 的协议解析器，`URL`/`URL_HTTP` 两条常量它根本没用）、`is_number`/`has_number`（要与 `conv` 的数值文法对齐成一张嘴）、`is_citizen_id`/`is_credit_code`（mod-11 / mod-31 校验位 + 区划码表，归第 19 行 `typex`）；另实测 **5.8.35 里没有 `ValidatorSetting`/`validator-setting.json`**（jar 里只有 `Validator`/`PatternPool`/`RegexPool` 三个类、零资源文件），码表就是编译期常量。实现轮的三条变异对照逐条有块红（`is_uuid` 退回单形状 2 红 / MAC 分隔符写回 `[:-]` 2 红 / `is_ipv4` 首段放宽 2 红）；文档页两条凭常识写的期望被真跑打回（金额小数位不封顶、IPv4 前导零照收），已按语料改正并记进 spec §4 第 7~8 条 |
````
