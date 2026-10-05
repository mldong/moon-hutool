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
| A | `hutool-core-5.8.35.jar` 的 `AntPathMatcher` + 本机 JDK 17.0.14 | **101 行读数**（33 条 `match`/`matchStart`、11 条 `extract`+`within`、12 条 `combine`（含两条抛点）、4 条排序 + 2 条同级给 0、7 条 `is_pattern`、3 条抛点、默认构造与常量） | `javac -encoding UTF-8`（`digest` 轮那条编码教训开局就带）；每条都带 `sep/trim/case/start` 四个参数列，读数可复算 |
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
| 本文件 10 件 + `PathOptions` + `PathError` | **契约已冻结**（10-05 本笔） | 函数体是 `abort`，7 块用例**预期红**；落地那一笔只许把红变绿（门禁 G5） |
| 变异对照 | PR-B | 至少四条：`**` 的整段判定改成子串判定、`*` 允许跨段、大小写开关接反、排序里"更通用"的判定顺序（`**` 结尾 vs `*` 计数）挪位 |
| `PathMatcher`/`PathPatternParser` 那一族（Spring 的新解析器） | **不做** | 参照实现自己就抛"用 PathPatternParser instead"；本库不引第二套语法 |
| `tokenize*`/`doMatch` 这些 `protected` 扩展点 | 不做 | 那是 Java 继承体系的扩展面，本库无子类语义可承接（对外只承诺上面 10 件） |
| 路径规范化（`normalize`、`..` 折叠、`.` 去除） | 不在本包 | hutool 那件在 `PathUtil`/`FileUtil`，需要 IO 语义，属另一个包 |
