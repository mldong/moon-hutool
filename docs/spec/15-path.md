# 契约 15 · path（Ant 风格路径模式·第一批）

对应 hutool `cn.hutool.core.text.AntPathMatcher`（**这个类是 Spring-framework `org.springframework.util.AntPathMatcher`
的 vendored 拷贝**：945 行、15 个 `public` 成员 + 4 个内部类）。进度状态见 [`docs/ROADMAP.md`](../ROADMAP.md) 第 15 行；
本文件的序号 15 就是那一行的行号（门禁 G13）。

## 0. 血统与许可（这一包必须先读这一节）

| 项 | 现读事实 |
|---|---|
| 参照腿在哪 | **就在 `hutool-core-5.8.35.jar` 里**（`cn/hutool/core/text/AntPathMatcher.class` 11,349 字节 + 4 个内部类）⇒ 不用换 artifact 取 |
| 血统 | 类体是 Spring 的拷贝（javadoc 里还留着 `@since 4.1` 那类 Spring 版本号），**Apache-2.0** |
| 本库许可 | 仓内 `LICENSE` 与 `moon.mod` 自骨架那一笔（`4b2415b`，10-04）起就是 **Apache-2.0**，README「移植来源声明」也已写明"少数带 Spring/Commons 署名的类按 Apache 系处理" ⇒ **无悬挂的许可问题** |
| 做法 | 对着参照实现**独立实现**（读源码 + 跑读数），不搬运 Java 源码；本节把血统留在文档里而不是藏起来 |

## 1. 五条贯穿性规则

1. **不做可变对象、不做全局缓存**。参照实现是四个 setter（`setPathSeparator`/`setCaseSensitive`/`setTrimTokens`/
   `setCachePatterns`）撑起来的状态机。本库把前三枚收进**显式传入的 `PathOptions` 记录**；
   `setCachePatterns` 那档**不做**——与 `re` 包"不建全局模式池"同一条立场，要缓存由调用方自己持有结果。
2. **子表达式一律按 core 正则方言**。参照实现把 `{name:regex}` 里的 regex 交给 `java.util.regex`，
   所以 `{n:\d+}` 在它那儿能用；core 方言不收 `\d`/`\w`（`re` 轮实测：编译期报错）⇒ 本库这一档按 core 方言判定，
   Java-only 写法是**非法模式**，不假装支持、也不自动改写（不写 `\d → [[:digit:]]` 那种"贴心"翻译）。
3. **`{*path}` 捕获档判不支持**，且这是参照实现自己的行为：`/resources/{*path}` 对 `/resources/a/b/c` 的
   `match` **恒假**，`extract` 抛 `IllegalArgumentException("Capturing patterns (*path) are not supported by the
   AntPathMatcher. Use the PathPatternParser instead.")`（源码里那句 `name.startsWith("*")` 分支）。
   本库同档判**明确不支持**，错误面摆出来；不照 Spring 新文档去补 `PathPatternParser` 那套。
4. **抽取与拼接都有真实错误面，不是「给个空表」那种表达式**：`extract_variables` 三条抛点 + `combine` 一条后缀冲突抛点，共四档（§3.3、§3.4）。
5. **默认档跟"所对位的那个实现"，不跟祖上文档**：源码字段是 `caseSensitive = true`、**`trimTokens = false`**，
   而 Spring 原版默认 `trimTokens = true`——hutool 改过。默认档由"源码字段 + 默认构造实测"双证钉住。

## 2. 公开面（10 件 + 1 记录 + 1 错误枚举）

| 项 | 签名 | 对位 |
|---|---|---|
| `PathOptions` | `{ separator : String, case_sensitive : Bool, trim_tokens : Bool }` | 三枚 setter 收成一个记录 |
| `default_options` | `() -> PathOptions` | `new AntPathMatcher()` |
| `default_separator` | `() -> String` | `DEFAULT_PATH_SEPARATOR`（读数 `/`） |
| `is_pattern` | `(String) -> Bool` | `isPattern` |
| `match_path` | `(pattern, path) -> Bool` | `match`（默认档） |
| `match_path_with` | `(pattern, path, opts) -> Bool` | `match` |
| `match_start_with` | `(pattern, path, opts) -> Bool` | `matchStart` |
| `extract_variables` / `extract_variables_with` | `(pattern, path[, opts]) -> Map[String, String] raise PathError` | `extractUriTemplateVariables` |
| `extract_within` | `(pattern, path) -> String` | `extractPathWithinPattern` |
| `combine` | `(prefix, suffix) -> String raise PathError` | `combine` |
| `compare_patterns` | `(against, a, b) -> Int` | `getPatternComparator` |
| `PathError` | `suberror`：`NoMatch` / `CapturingVar` / `CaptureGroupRegex` / `ExtensionConflict` | 实测四种抛点（前三条在 `extract_variables`，第四条在 `combine`） |

**为什么没有 `match` 这个名字**：`match` 是 MoonBit 保留字（骨架期编译器直接判词法错，`dfa` 轮撞过同一处），
所以整段匹配叫 `match_path`。**为什么比较器给 `Int` 不给 `Ordering`**：本仓没有 `Ordering` 的现成先例，
而 `Array::sort` 正好要 `Int`——少一次类型舞蹈。

## 3. 语义档位（全部实测，读数在 `path_ref.txt`）

### 3.1 通配三件

| 写法 | 语义 | 实测读数（参照腿） |
|---|---|---|
| `?` | 单段内**恰好一个字符** | `/??` vs `/ab` 真；`/??` vs `/a` 假 |
| `*` | 单段内任意，**不跨分隔符** | `/*.jsp` vs `/test.jsp` 真；`/WEB-INF/*.jsp` vs `/WEB-INF/a/b.jsp` **假** |
| `**` | **必须是整段 token**，跨段、且可吞零段 | `/WEB-INF/**` vs `/WEB-INF/` 真、vs `/WEB-INF` 真；`a:**:c` vs `a:c` 真 |

`**` 不是整段时完全不生效：把 `:` 设为分隔符后，`a:**/c` 对 `a:x:y:c` 是**假**（`/` 成了字面字符），
同一个意图写成 `a:**:c` 才是真。**这条不是"参照实现的坑"，是本契约的夹具纪律**：测分隔符档位，
模式与路径必须用同一个分隔符（普查初版就因为这个写错，差点把"自定义分隔符不生效"当成结论）。

### 3.2 边界档（都有读数）

| 档 | 读数 |
|---|---|
| 空模式 vs 空路径 | `("", "")` 真；`("", "/abc")` 假；`("/abc", "")` 假 |
| 前导斜杠必须同形 | `abc/def` vs `abc/def` 真（两边都没有前导 `/`）；参照实现的判据是 `path.startsWith(sep) != pattern.startsWith(sep)` 直接假 |
| 连续分隔符 | `/a//b` vs `/a//b` 真（空段两边都在） |
| 大小写 | 默认敏感（`/ABC` vs `/abc` 假）；`case_sensitive=false` 时两个方向都真 |
| 裁空格 | 默认**不裁**（`/ abc ` vs `/abc` 假）；`trim_tokens=true` 时真；关掉裁空格后 `/ abc ` 对自己才真 |
| `is_pattern` | `/hotels` 假、`/hotels/*` 真、`/*.jsp` 真、`/{name}` 真、`""` 假、`**` 真、`/a:b` 假（**冒号不算模式字符**） |
| `matchStart` | `/WEB-INF/**` vs `/WEB-INF/classes/x/y` 真；`/WEB-INF/*` vs `/WEB-INF/classes/x` 假（`*` 不跨段）；`/com/*` vs `/co` 假（半段不算） |

### 3.3 `extract_variables` 的三档错误（第四档在 `combine`，见 §3.4）

| 档 | 参照腿抛点（原样） | 本库 |
|---|---|---|
| 模式不匹配 | `IllegalStateException: Pattern "/{name}" is not a match for "/a/b"` | `PathError.NoMatch(pattern, path)` |
| `{*name}` | `IllegalArgumentException: Capturing patterns (*path) are not supported ...` | `PathError.CapturingVar("*path")` |
| 子表达式带捕获组 | `IllegalArgumentException: The number of capturing groups in the pattern segment ((a)(b)) does not match ...` | `PathError.CaptureGroupRegex("(a)(b)")` |

第三档值得单独钉一条：**同一个模式 `{n:(a)(b)}/x` 对 `/ab/x`，`match_path_with` 给真、`extract_variables` 抛错**。
所以"能匹配"不蕴含"能抽变量"，两件事必须各有错误面（参照实现就是这么分的）。

### 3.4 其余两件

- `extract_within`：`/WEB-INF/**` 对 `/WEB-INF/web.xml` 给 `web.xml`；`/**` 对 `/a/b` 给 `a/b`；
  精确模式给**空串**；不匹配也给**空串**（这一件参照实现**不抛**，与 `extract_variables` 不同，照抄）。
- `combine`：**五条前置分支，不是纯拼接**（源码 565~600 行 + 本包 12 条读数）：
  ① 某侧为空取另一侧、两边空给空串；② `prefix` 不含 `{`、与 `suffix` 不等、且 `match_path(prefix, suffix)` 成立
  → **直接给 `suffix`**（`/*.jsp` + `/hotels.jsp` → `/hotels.jsp`）；③ `prefix` 以 `<sep>*` 结尾 → 先截末尾两个字符再拼
  （`/hotels/*` + `/bookings` → `/hotels/bookings`），以 `<sep>**` 结尾 → 直接拼（`/hotels/**` + `/bookings` → `/hotels/**/bookings`）；
  ④ 含 `*.` 且两侧后缀都非全能 → **`PathError.ExtensionConflict`**（`/*.jsp` + `/*.txt`、`/*.jsp` + `/WEB-INF/x.jsp` 均抛），
  一侧全能（后缀为 `.*` 或空）则取另一侧（`/*.jsp` + `/hotels` → `/hotels.jsp`）；⑤ 其余才拼，且**不补齐也不去重分隔符**
  （`/test/` + `//hotels.html` → `/test//hotels.html`；两边相等也拼：`/hotels` + `/hotels` → `/hotels/hotels`）。
  参照实现另有「参数为 `null` 时退化」的两档——本库入参是 `String`，那一档**结构上不存在**（不是遗漏）。
  **这一族是本包 raise 面的第四档，是 PR-A 之后继续读源码才撞上的**，所以走单独一笔契约补充
  （签名 `-> String` 改成 `-> String raise PathError`），不在实现那一笔顺手改（G5 禁的就是那个）。
- `compare_patterns`（模式具体度排序，实测四条）：对 `/hotels/chicago`，
  `/hotels/*` < `/**/hotels/**` < `/hotels/**` < `/**`；对 `/a/b`，`/a/b` < `/**/b` < `/a/**` < `/**`；
  对 `/WEB-INF/a.jsp`，`/WEB-INF/*` < `/WEB-INF/**` < `/**/*.jsp`。

## 4. 读数腿

| 腿 | 来源 | 条数 | 说明 |
|---|---|---|---|
| A | `hutool-core-5.8.35.jar` 的 `AntPathMatcher` + 本机 JDK 17.0.14 | **101 行读数**（33 条 `match`/`matchStart`、11 条 `extract`+`within`、12 条 `combine`（含两条抛点）、4 条排序 + 10 条比较器逐对直读（含同级给 0 的两条）、7 条 `is_pattern`、3 条抛点、默认构造与常量） | `javac -encoding UTF-8`（`digest` 轮那条编码教训开局就带）；每条都带 `sep/trim/case/start` 四个参数列，读数可复算 |
| B | **参照实现源码**（`hutool-core-5.8.35-sources.jar`，`AntPathMatcher.java` 945 行） | 4 条机制判定 | 只能由源码给：默认字段值（`caseSensitive=true`、`trimTokens=false`）、`{*name}` 抛点的 `startsWith("*")` 分支、`startsWith(sep)` 那条前导斜杠判据、`**` 只在整段 token 上生效的位置 |

**普查阶段自己踩的坑记在这儿**（避免下一包再踩）：分隔符档位初版写成 `a:**/c` 对 `a:x:y:c`（混用两种分隔符，恒假），
差一点把"自定义分隔符不生效"写成结论；另一处是给 Java 源码补 `\\d` 时被脚本剥成一个反斜杠，编译直接报非法转义——
**给参照腿脚本改正则/转义时先 grep 出原始 bytes 再改**（同一类坑第三次）。

## 5. 不跟随与分岔（每条带两侧读数）

| # | 项 | 参照实现 | 本库 | 依据 |
|---|---|---|---|---|
| 1 | 三枚开关的形状 | 可变对象 setter | 显式传 `PathOptions` 记录 | §1.1 |
| 2 | `setCachePatterns`（模式缓存） | 有 | **不做** | `re` 轮"不建全局模式池"同一条 |
| 3 | `{n:\d+}` 这类 Java 方言子表达式 | 真（Java 收 `\d`） | **假**（core 方言不收，判非法模式） | 腿 A `regex-dslash` 那条 + `re` 轮方言实测；用例里按 `false` 生成并写明出处 |
| 4 | `{*path}` | `match` 恒假 + `extract` 抛 | 同档 `match` 假 + `PathError.CapturingVar` | 腿 A/B 双证 |
| 5 | `combine` 的 `null` 参数档 | 退化取另一侧 | 结构上不存在（入参 `String`） | 腿 A 两条 `c-null-*` 读数 |
| 6 | 默认 `trimTokens` | hutool `false`（**Spring 原版是 `true`**） | 跟 hutool：`false` | 腿 B 字段声明 + 腿 A 默认构造实测 |
| 7 | `matchStart(pattern, path)` 无 opts 版 | 有 | 只交 `match_start_with` | 少一件同名不同档的入口；默认档由 `default_options()` 传 |

## 6. 相位与不承诺

| 项 | 相位 | 说明 |
|---|---|---|
| 本文件 10 件 + `PathOptions` + `PathError` | **已实现**（10-05 四笔：骨架 `8bc6423` + 契约补充 `9cfaf16` + 期望值更正 `137e248` + 落地） | 11 块全绿（7 断言块 + 4 文档块），wasm / js / wasm-gc 三档一致，`.mbti` 公开面未变 |
| 变异对照 | **已做五条，逐条有块红** | `**` 的整段判定拿掉 ⇒ 3 红 / 路径不拆段（等于让 `*` 跨段）⇒ 5 红 / 大小写开关接反 ⇒ 2 红 / `combine` 的单星截断分支拿掉 ⇒ 2 红 / 比较器的双前缀分支挪位 ⇒ 1 红；五条全部按 sha256 字节还原。**一条弱点如实记着**：「大小写接反」只被 2 块抓到——现有夹具两侧同升降，改后 `want` 与 `target` 仍对称，反向夹具（模式小写、路径大写）没能把它区分开；补一条"只降一边"的夹具再判，这一格算待补强。 |
| `PathMatcher`/`PathPatternParser` 那一族（Spring 的新解析器） | **不做** | 参照实现自己就抛"用 PathPatternParser instead"；本库不引第二套语法 |
| `tokenize*`/`doMatch` 这些 `protected` 扩展点 | 不做 | 那是 Java 继承体系的扩展面，本库无子类语义可承接（对外只承诺上面 10 件） |
| 路径规范化（`normalize`、`..` 折叠、`.` 去除） | 不在本包 | hutool 那件在 `PathUtil`/`FileUtil`，需要 IO 语义，属另一个包 |

---

## 7. 补档普查翻出的两件事（10-07，`path_deep_test.mbt` 那一笔的由来）

### 7.1 十条实测分岔：登记而不 laundering

普查姿势 = **一条断言一个 test 块**（多断言挤在一块里时，第一条红会掩盖块内其余没跑——`cron` 轮已点过一次，这次直接按这个形状造探针），一次跑出 80 条用例、收割 10 条分岔；`probe` 件用完即删，两份读数都留在下面这张表里（参照列来自 `PathLeg2.java`，本库列来自 `moon test` 输出）。

| 族 | 输入 | 参照（hutool 5.8.37） | 本库现实现 |
|---|---|---|---|
| 尾随分隔符 | `match_path_with("/a/*", "/a/", 默认档)` | `true` | `false` |
| 尾随分隔符 | `match_start_with("/a/*", "/a/", 默认档)` | `true` | `false` |
| 尾随分隔符 | `match_start_with("/a/?", "/a/", 默认档)` | `true` | `false` |
| 抽段 | `extract_within("/**/x/", "/a/x/")` | `"a/x"` | `"a/x/"` |
| 比较器 | `compare_patterns("/a/b", "/**/b", "/a/*")` | `1` | `-1` |
| 比较器 | `compare_patterns("/a/b", "/**/b", "/a/?")` | `2` | `1` |
| 比较器 | `compare_patterns("/a/b", "/**/b", "a/*")` | `1` | `-2` |
| 比较器 | `compare_patterns("/a/b", "/a/*", "/a/**/b")` | `-1` | `3` |
| 比较器 | `compare_patterns("/a/b", "/a/?", "/a/**/b")` | `-2` | `-1` |
| 比较器 | `compare_patterns("/a/b", "a/*", "/a/**/b")` | `-1` | `4` |

处置口径（10-08 收尾：**这十一条已全部闭合并转成断言**——比较器六条见 §8，尾随分隔符四条与抽段一条见 §9；下面这段是当时的处置理由，保留不改）。**未修的那些不进断言**。钉进断言就等于把"实现与参照不同"洗成"本库自订契约"，而这里没有任何自订理由——两族都是可修的偏离。修法是单独一笔（PR-B 型：只让红变绿，附变异对照），修完再把这十条转成断言。`path_deep_test.mbt` 里每条位置都留了一行 `// … 分岔登记（参照=… / 本库=…），见 spec 末节，本笔不钉`，下一轮不必重跑普查。

比较器这族的形状值得留意：**数值量级也差**（不只是符号），而既有夹具里四条排序全绿——说明已冻的那四条没覆盖到"`*` 与 `**` 同前置但段数不同"这类配对，21 对逐对直读才暴露。这与 §7 那条"并列档给 0"是同一片实现。
 
### 7.2 已冻用例里的 49 条死格（为什么上面这些一直没被发现）

`path_test.mbt` 有 **49 条**断言把**参照的期望值写进了 pattern 实参位**：形状是 `match_start_with("false", "/?/cde", opts)`——第一个实参是期望值 `false` 的字面串，不是模式。这类断言恒绿（拿 `"false"` 当模式去匹配任何真实路径当然给 false），却占着"这条判据有夹具"的位置。这就是上面两族分岔能长期潜伏的直接原因，也正是 G15 那格未覆盖行一直降不下来的原因。

处置分两步，都不许混在本笔里顺手做：① 逐条回问"这条本来要测哪一对 (pattern, path)"，取不到原始意图的**整条作废并登记**，而不是照当前形状重挂（重挂＝把死格洗成契约）；② 加一条门禁形状（`match_*`/`extract_*` 的 pattern 实参位出现 `"true"`/`"false"` 即红，带阳性对照），拦住这种写法再产生。两步各自单独一笔。

### 7.3 死格更正的结果：49 条整条作废，家族按腿重挂 39 对（10-07 第二笔）

回问原始意图的结论是**恢复不了**，三条证据：① `path_ref.txt` 那份腿读数从未进仓（`git log --all --diff-filter=A -- '*path_ref*'` 零命中）；② 注释里 `path=` 列填的其实是**模式串**（`/WEB-INF/**`、`/{name:[a-z]+}`、`a:**:c`、`/ abc `），真路径整个丢失；③ 断言第一个实参位（pattern 位）是期望值字面串——两列同时错位，不是单纯笔误。

于是改成**按家族重建**：

- 新的 (模式, 路径, 分隔符, 大小写, 裁空格) 组合 39 对由本轮选定（覆盖死格声称的 23 个家族×opts 组合），参照腿 `PathLeg3.java` 对每对同时打 `match` / `matchStart` / `extractPathWithinPattern` / `extractUriTemplateVariables` / `isPattern` 五个出口，234 行读数、**手打零条**；
- 普查仍按"一条断言一个 test 块"：78 块全进执行（脚本先断言 `Total tests >= 17 + 78`，不满足就拒绝给结论——这条自证第一次跑就抓到探针件写成非 `_test.mbt` 后缀而整件编译失败，"0 条分岔"是假的），最终**只 1 条分岔**：

| 族 | 输入 | 参照 | 本库 |
|---|---|---|---|
| 尾随分隔符 | `match_start_with("/abc/", "/abc", 默认档)` | `false` | `true` |

即 §7.1 那族"尾随分隔符"又多一条（第 11 条），归同一支修复。其余 77 条与参照逐条同判 ⇒ **`path` 的核心档位实际上是好的**，之前的"分岔很多"错觉来自那 49 条不承重的断言把真实覆盖遮住了。

- 落件：`path/path_families_test.mbt`（39 个家族块，全绿）；`path_test.mbt` 的 49 条按命中数断言逐条摘除（其中 1 条带"分岔行：参照腿给真、本库按 core 方言判 `\d` 非法"的尾注，注释保住、断言摘掉，指向 §5 第 3 行）；
- G17 基线 49 → **0**（这条判据从此是"新增即红"的硬闸，不是债务登记）；G15 未覆盖行同步下降（真模式终于走得到 `doMatch` 的深分支）。
- 更正笔不自创期望：摘除动作的机器凭据是"除那 49 段之外，其余行与摘除前逐行相等"（脚本比对，见提交信息），而不是"我看过了"。

## 8. 比较器六条分岔的闭合笔（10-08，PR-B）

**三处实现与参照不符，全部照源码改**（源码 = 本包 §4 腿用的 `hutool-core` 源件里的
`AntPatternComparator`/`PatternInfo`，不是回忆）：

1. `getTotalCount()` 是 `uriVars + singleWildcards + 2 * doubleWildcards`——**双星按两个计数**。
   本库原来漏了那个 `2`，这就是 §7.1 表里"量级也差"的唯一来源：六条配对逐条手推，
   补上 `2 *` 之后**六条全部与参照同值**（`1/2/1/-1/-2/-1`），不需要任何第二条改动。
2. 有变量时 `getLength()` 走 `{...}` **折叠成 1 字符**再取长（未闭合的 `{` 不被匹配、按普通字符算），
   本库原来给 `-1`。这条当时没被普查抓到（那 21 对里没有带变量的配对），
   是读源码读出来的——所以本笔为它**新配了四对夹具**（`/{a}/{b}` 与 `/**b` 正反、`/{a`、`/{a}x` 配 `/x/*y`），
   读数全部来自腿（`PathLeg3.java` 的 C 行），不是从实现抄的。
3. `initCounters` 里那条 `!pattern.substring(pos - 1).equals(".*")` 比的是**从 pos-1 起的整条尾巴**，
   本库原来比的是两字符窗口 ⇒ `.*x` 这一档两侧不同（参照把这颗 `*` 计成单星，本库不计）。
   改成尾巴比较，并配 `.*x` / `.*` 两对夹具把它钉住（`N2` 变异专打这一条）。

**落件**：`path/path_cmp3_test.mbt` 28 块（一对一块、逐对直读，手打零条），
`path` 未覆盖行 26 → **17**、全仓 158 → **149**，比较器那七行（`:700/702/713/731/733/736/738`）
连同 `:664`（`{` 计数）与 `:674`（`.*` 那支）一起转绿。
公开面与 `.mbti` 零漂移；**已冻期望一条没改**（那四条排序读数在本笔之后仍全绿，
`G5` 的差分只有"增"）。变异 7 条全部抓红：`N1` 7 红、`N2` 1 红、`N3` 4 红、`N4` 1 红、`N5` 11 红、`N6` 1 红、`N7` 5 红。
两处点名（免得下一轮把这张表当成"新夹具全包了"）：
`N6`（双前缀档反着减长度）**不是被本笔那 28 对抓到的**——新配的配对里 `/x/**` 与 `/y/**` 等长，
正反都给 0，掩盖得住；抓它的是 `path_test.mbt:211` 那条**已冻的排序读数**（长度不等的双前缀配对，`3 != -3`）。
⇒ 我原本预判"N6 会被掩盖"，跑出来是红：**掩盖与否要跑，不要推**，而且推的方向还会错。
`N2`/`N4` 各只 1 红，是因为它们各自只有一对夹具（`.*x` 与未闭合 `{` 那两对）——
这正是"按出口配对"的意思：一条出口一对，红位与出口一一对得上，不靠数量堆。

**剩下五条（尾随分隔符 4 + 抽段 1）的根因本笔查清了，但没有顺手改**：
参照 `tokenizePath()` 走 `StrSplitter.splitToArray(path, sep, 0, trimTokens, /*ignoreEmpty=*/true)`
——**空段全部丢掉**，`"/a/"` 在参照侧是 `["a"]` 加一个 `endsWith(sep)` 的判断；
本库的 `tokenize` 保留空段，`"/a/"` 是 `["", "a", ""]`，于是 `do_match` 里那条
"路径先耗尽 + 余下一颗 `*` + 路径以分隔符收尾"的特判（`:402`）**永远走不到**
（覆盖率现读：`:403` 至今未覆盖，这就是这条特判的空转证据）。
改法要么把 `tokenize` 换成"丢空段 + 顶上两端各留一个 `startsWith`/`endsWith` 判断"，
要么给 `do_match` 换一套耗尽判定——两种都会同时挪动 `extract_within`、`combine` 与
`match_*_with` 的段序语义，属于另一个 `5` 条夹具之外的独立一笔（普查姿势照 §7.1：先按出口配对，
再一次性重跑 101 条已冻读数）。⇒ 这五条当时仍按"登记而不 laundering"处置，只是登记内容从症状升级成根因；**次日即按此根因闭合，见 §9**。

## 9. 尾随分隔符四条与抽段一条的闭合笔（10-08，`tokenize` 丢空段）

根因在**切分器**，不在匹配器。参照 `tokenizePath()` 走
`StrSplitter.splitToArray(path, sep, 0, trimTokens, /*ignoreEmpty=*/true)`——**第五参是 `ignoreEmpty`，
与第四参 `trimTokens` 是两个独立开关**。本库此前把两者当成一个（原注释写着"hutool 默认 `trimTokens=false`
⇒ 保留空段"），于是把参照丢掉的那些空段留了下来。

这不是推断，是逐串读数：腿里子类化 `AntPathMatcher` 把 `protected tokenizePath` 直接拖出来打印（T 行）——
`"/a/"` ⇒ **1 段** `a`；`"/a//b"` ⇒ **2 段** `a,b`；`"/"` 与 `""` ⇒ **0 段**；`"//a"` ⇒ 1 段；
而 `"/ /x"` 那种**空白段照留**（`ignoreEmpty` 只丢空串，不连空白一起扔）。

改法只有一处：`tokenize` 改成"逐段 `maybe_trim` 之后，**空串不入表**"（新增 `push_seg`）。
改完 §7.1 那五条自己就对上了，而且 `do_match` 里既有那条"路径先耗尽 + 余一颗 `*` + 路径以分隔符收尾"
的特判**从此走得到**——它原本是一件空转件（改前覆盖率现读：那一行的 `return (true, None)` 永远未覆盖），
本笔之后转绿。**没有新增任何匹配规则**，只是把输入切成了参照那种形状。

落件：`path/path_cmp3_test.mbt` 的前 27 块（`match` / `matchStart` / `extractPathWithinPattern`
三个 verb 逐对直读，期望来自腿的 M 行、手打零条），含那五条分岔的原始配对，外加一圈**会受"丢空段"影响的邻档**
（`/a//b` 两侧、`/` 与空串、`/**` 对空串、`{v}` 段、两种空白段、`?/x` 对 `a/x`、
`extract_within` 的四档）——27 对逐对与参照同判。

- 全仓 **1418 = 绿 1418 / 红 0**（wasm/js/wasm-gc 三档一致、零警告）；path 未覆盖行 17 → **16**、全仓 149 → **148**；
- **已冻期望一条没改**：那 101 条读数与 39 个家族块在新 tokenizer 下全绿 ⇒ 丢空段只改变了
  "以前两侧本来就不同"的那些形状，没有撞到别的语义（这正是"整体重跑已冻读数"这一步要回答的问题）；
- 变异 6 条全部抓红：`K1` 退回保留空段 **8 红**、`K2` 把判据扩成"空白段也丢" **1 红**
  （就是那两样空白段配对抓的——`ignoreEmpty` 与 `trimTokens` 的分工自此有夹具钉着）、
  `K3` 特判反判收尾 **4 红**、`K4` 两端收尾恒相等 **2 红**、`K5` 开头守卫反着判 **3 红**、
  `K6` 耗尽后余段不再要求全是 `**` **2 红**。

§7.1 那张表自此零条未决。剩 16 行的归位照旧写明：转义段两行（`:88`/`:90`）、抽变量的两档
（`:259`/`:263`/`:291`/`:297`）、`sep` 为空串的两档（`:355`/`:364`，本库允许、参照无对位物）、
`do_match` 后段与中段的失败出口（`:438`–`:509`）与 `:633`——这些是**可达但要按出口配对**的档，
下一批沿用本笔形状（verb 逐对 + 一块一断言）去打。

## 10. 第五批补档（10-08）：按出口配对打 `do_match` 的失败档，并给三条"到不了"的归位

形状沿用 §8/§9 那两批：腿加行（`N` 动词逐对 + `E` 空分隔符档），生成器把读数灌成断言，一块一断言。
新增 24 块（`path/path_cmp3_test.mbt` 的"匹配直读"27 + "出口直读"24 + "比较器直读"28），
path 未覆盖行 16 → **3**、全仓 148 → **135**、全仓 **1442 = 绿 1442 / 红 0**（三档一致、零警告）。

四条**声明档**（钉本库形状、参照原读数写在注释里，依据就是本文件 §5 那三行）：

| 输入 | 本库 | 参照现读 | 依据 |
|---|---|---|---|
| `match("/a/{n:\d+}/b", "/a/12/b")` | `false` | `true` | §5 第 2 行：core 方言不收 `\d`，Java-only 写法是非法模式，不假装支持 |
| `extract_variables("/a/**/{*p}", "/a/b/c")` | 抛 `CapturingVar *p` | 抛 `IllegalArgumentException` | §5 第 3 行：两侧都不支持，载体不同 |
| `extract_variables(带 `(a)(b)` 的子表达式)` × 2 | 抛 `CaptureGroupRegex {n:(a)(b)}` | 抛 `IllegalStateException` | `PathError` 文档那条"子表达式里带捕获组" |
| `combine("/*.jsp", "/x.txt")` | 抛 `ExtensionConflict …` | 抛 `IllegalArgumentException` | §5 的 `ExtensionConflict` 行 |

四条 `sep=空串` 档（`:355`/`:364`）钉的是本库防御形状（四对直读 `true/false/true/true`）——
参照 **`new AntPathMatcher("")` 构造时就抛**，所以这里根本没有"参照值"可对撞，
这跟"参照给一个不同值"是两回事，表里分开写。

**剩三行给归位，其中两行还带第二种证据**：

- `:291`（`fill_vars` 里 `rx.execute` 落空）与 `:297`（未参与分组的兜底）：
  `fill_vars` 只在调用方 `match_seg` 已经用**同一个 `rx`、同一个 `target`** 拿到 `Some(_)` 之后才被调，
  第二次执行不可能落空 ⇒ `:291` 到不了；`:297` 要"名字对应的组没参与"，而带额外分组的子表达式
  在 `:254` 就已经换成 `CaptureGroupRegex` 抛掉了。
  **两条都做了"删掉/改掉仍然全绿"的变异实验**（`R7`、`R6` 各 0 红）——
  未覆盖 + 推导 + 删掉不改变行为，三种证据凑齐才敢说"到不了"。
- `:509`（收尾循环里"余段必须全是 `**`"）：本轮配了两对都从 `:500`/`:450` 出口先走了，
  这一行仍未命中；`R5` 把整档删掉仍然全绿（第三种证据同样指向"到不了"）。
  **但这条只标"待复核 + 删除实验不改变行为"，不写成结论**——
  中间那段 `ps` 只会落在 `**` 上这条不变式我还没从两个循环的赋值点逐条推严。

### 10.1 变异 7 条：1 红、3 条按构造等价、1 条**新的夹具缺口**、2 条预判被推翻

| 变异 | 结果 | 归位 |
|---|---|---|
| `R4` 中段滑动循环里的错误不再上抛 | **红 1** | 承重（`{n:(a)(b)}` 那对就是为它配的） |
| `R5` 删掉 `:509` 那一档 | 红 0 | 支撑"到不了"的第二种证据（结论仍标待复核） |
| `R6` `:297` 的兜底值改成乱码 | 红 0 | 同上——该行到不了 |
| `R7` `:291` 落空分支改成抛形状 | 红 0 | 同上 |
| `R1` 反斜杠不进入转义态 | 红 0 | **夹具缺口**：现有夹具里没有一条让 `\(` 真的出现在被计数的那个串里；`:88`/`:90` 只是被"反斜杠后跟非括号"走到 ⇒ 覆盖到，但语义分不开（同日第三条同性质账） |
| `R2` `starts_with_sep` 空分隔符档恒假 | 红 0 | **按构造等价**：该件的两个调用点都是"同一函数作用在 pattern 与 path 上再比较"，同时翻转常量返回值不可能改变判定 |
| `R3` `ends_with_sep` 空分隔符档恒假 | 红 0 | 同上（`:397` 那档也是两侧对拍） |

`R1`/`R2`/`R3` 三条都是**我预判会红、跑出来是红 0**——与同日 `path` 比较器那批的 `N6` 正好相反方向，
同一条纪律：判"红不红"只许跑。三条各自的归位都写在上面，不写成"已覆盖"。

## 11. 第五批（10-10 批①）：`FileNameUtil` 的纯字符串档（六件）

契约先行笔（PR-A）：签名 + `.mbti` + 冻结期望 285 条在 `path/filename_test.mbt`，体全是
`PR-B：契约骨架` 的 abort ⇒ `moon check` 绿、本包用例此刻红是设计态。
读数腿 `scripts/FileNameLeg.java`（参照 hutool-all 5.8.37 + 本机 JDK 17.0.14，`javac -encoding UTF-8`），
生成器 `scripts/gen_batch1_rest.py`。

### 11.0 范围切法（先说清哪些不进）

`FileNameUtil` 每个公开方法都有 `File` 与 `String` 两个重载。**只收 String 档**：
`File` 档的语义挂在宿主（`File.separator` 随 OS 变、`isDirectory` 的尾斜杠规则、`File#getName`
对空串的兜底），本库零 FFI ⇒ 该批重载整条判 `excluded`（census `FileNameUtil` 那行的理由栏同此）。
null 入参在参照六件里有四件给 null、`containsInvalid(null)` 给 **false**——本库 `String` 无 null 档，
该形状不在契约面（腿 N 行的 `{null}` 档逐条留在注释里，不当"已覆盖"）。

**两件同义委托不重复出公开面**：参照的 `getSuffix` ≡ `extName`、`getPrefix` ≡ `mainName`，
腿逐档并排打两侧读数、每一条同串（`archive.tar.gz` 两侧都给 `tar.gz` / `archive`）。
再造第二件名字就是"两个名字一件事"，实现轮一改就一漏。

### 11.1 六件签名

| 件 | 签名 | 对位 |
|---|---|---|
| `name_of` | `String -> String` | `getName(String)` |
| `main_name` | `String -> String` | `mainName`（+ 别名 `getPrefix`） |
| `ext_name` | `String -> String` | `extName`（+ 别名 `getSuffix`） |
| `clean_invalid` | `String -> String` | `cleanInvalid` |
| `contains_invalid` | `String -> Bool` | `containsInvalid` |
| `is_type` | `String, Array[String] -> Bool` | `isType(String, String...)` |

### 11.2 语义档（全部实测，一条都不按"路径库应该怎样"写）

1. **两种分隔符都认，且不分宿主**：`a\b/c.txt` 的 `name_of` 给 `c.txt`——参照就是纯串处理，
   本库不引入"当前 OS 的分隔符"概念（本包 §1 的 Ant 匹配那一族同口径）。
2. **尾随分隔符算一段空**：`/tmp/` 与 `tmp/` 都给 `tmp`，`ext_name` 给空串，
   而 `contains_invalid("/tmp/")` 是 **true**（分隔符本身在非法字符集里，见第 5 条）。
3. **点开头**：`.bashrc` 的 `ext_name` 是 `bashrc`、`main_name` 是**空串**（腿 N 行两侧都在）。
   参照不给"隐藏文件整体当主名"那种常见做法，别顺手改。
4. **复合扩展名**只认反射读来的 `SPECIAL_SUFFIX` 四条：`tar.bz2` / `tar.Z` / `tar.gz` / `tar.xz`
   ——注意表里那条是**大写 Z**，`tar.bz` 不在表内。命中时 `ext_name` 给两段、`main_name` 跟着少两段；
   `x.tar.gz.txt` 命中的是尾巴 ⇒ `txt`。`is_type` 同一段比法：`a.tar.gz` 命中 `tar.gz`
   而**不**命中 `gz`（腿 IT 行三档并排）。
5. **非法字符集不靠记忆**：反射读 `FILE_NAME_INVALID_PATTERN_WIN` 现读为
   `[\/:*?"<>|\r\n]`（腿 CONST 行），`clean_invalid` 就是按这一张字符集删。
   于是 `clean_invalid("/tmp/")` 给 `tmp`、`bad:name?.txt` 去掉 `:` 与 `?`。
6. **`is_type` 的四条形状**：大小写不敏感（`a.TXT` 命中 `txt`，类型表里的 `Tar.GZ` 也命中）；
   类型**不带点**（`[".txt"]` 永不命中）；空类型表恒 false；**空串类型是个真值档**——
   无扩展名的 `noext` 对 `[""]` 给 true（腿 IT 行），表里含 null 元素时那一项永不命中
   （本库 `Array[String]` 不收 null，该档无对位形状）。

### 11.3 本批不承诺

`File` 重载、null 入参档、`FileNameUtil` 里的 `EXT_JAVA/EXT_CLASS/EXT_JAR` 三个常量
（腿 CONST 行读数 `.java/.class/.jar`——它们是给 `isType` 当参数用的串，本包不出常量表，
调用点直接写字面量即可；要收的话得先拍"常量表算不算 API 面"，见 `00-hutool-map.md` §7 的 gap 档讨论）。

> 本笔附带一条生成器修正：`FileNameLeg.java` 原先把 null 文件名印成字面量 `null`，
> 生成器据此造出三条 `is_type("null", ...)` 的**假断言**（参照那一档是"入参为 null"，本库 `String` 无该形状）；
> 腿改走 `esc(null)` 打 `{null}` 后，这三条就地删除，§11 冻结期望 285 → **263** 条，逐条删除理由见 `01-text.md` §1.15 末注。
