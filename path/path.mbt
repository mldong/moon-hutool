///|
/// moon-hutool/path —— Ant 风格路径模式匹配（hutool `cn.hutool.core.text.AntPathMatcher` 的 MoonBit 对位·第一批）
///
/// 契约：`docs/spec/15-path.md`；进度：`docs/ROADMAP.md`。这一批**只有签名与冻结期望值，函数体是 `abort`**
/// （状态＝契约已冻结，用例预期红）；实现那一笔只许把红变绿（门禁 G5）。
///
/// **血统先说清**：参照实现那张类是 Spring-framework `org.springframework.util.AntPathMatcher` 的 vendored 拷贝
/// （hutool 只是把它搬进 `hutool-core`，15 个 `public` 成员 + 4 个内部类，源码 945 行）。
/// 本库按 Apache-2.0 处理这条血统（仓内 `LICENSE` 与 `moon.mod` 从骨架那一笔起就是 Apache-2.0），
/// 且**对着参照实现独立实现，不搬运 Java 源码**。
///
/// 五条贯穿性规则（每条都有本机读数兜底，不是设计偏好）：
/// 1. **不做可变对象与全局缓存**。参照实现是 `setPathSeparator`/`setCaseSensitive`/`setTrimTokens`/
///    `setCachePatterns` 四个 setter 撑起来的状态机；本库把三项开关收进**显式传入的 `PathOptions` 记录**，
///    `setCachePatterns` 那档**不做**——与 `re` 包"不建全局模式池"同一条立场（要缓存由调用方自己持有结果）。
/// 2. **子表达式一律按 core 正则方言**。参照实现把 `{name:regex}` 里的 regex 交给 `java.util.regex`，
///    所以 `{n:\d+}` 在它那儿能用；core 方言不收 `\d`/`\w`（`re` 轮实测：编译期报错）⇒
///    本库这一档**按 core 方言判定**，Java-only 写法是非法模式，不假装支持也不自动改写。
/// 3. **`{*path}` 捕获档判不支持**。参照实现实测：`/resources/{*path}` 对 `/resources/a/b/c` 的 `match` **恒假**，
///    `extract` 抛 `IllegalArgumentException("Capturing patterns (*path) are not supported...")`
///    （源码里那句 `name.startsWith("*")` 分支）⇒ 本库同档判**明确不支持**，错误面摆出来，
///    不照 Spring 新文档去补 `PathPatternParser` 那套。
/// 4. **`extract_*` 有真实错误面，不是"空表"表达式**。实测三条抛点：模式不匹配抛 `IllegalStateException`、
///    `{*name}` 抛 `IllegalArgumentException`、子表达式里带捕获组（`{n:(a)(b)}`）抛 `IllegalArgumentException`
///    ——最后这条尤其阴：**`match` 给真，只有 `extract` 炸**⇒ 本库把三档收成 `PathError` 三个变体。
/// 5. **分隔符档位要写成同一分隔符**。`a:**/c` 对 `a:x:y:c`（自定义分隔符 `:`）实测**恒假**——`**` 必须是**整段**
///    token 才起作用；写成 `a:**:c` 才是真，且 `a:**:c` 对 `a:c` 也为真（`**` 可吞零段）。

///|
/// 匹配开关。默认档 = 参照实现 `new AntPathMatcher()` 的**实测**读数：分隔符 `/`、
/// 大小写**敏感**、token **不裁空格**。
///
/// - Note: 三档默认值都是**源码 + 读数双证**：`caseSensitive = true`、`trimTokens = false`（源文件字段声明），
///   而默认构造对 `/ abc ` vs `/abc` 实测给假。**这一档与 Spring 原版不同**（Spring 默认 `trimTokens = true`）
///   ——本库跟的是**所对位的那个实现**（hutool 的拷贝），不是祖上的文档。
pub(all) struct PathOptions {
  separator : String
  case_sensitive : Bool
  trim_tokens : Bool
}

///|
/// 参照实现默认构造的等价档：`separator="/"`、`case_sensitive=true`、`trim_tokens=false`。
/// - Raises: 无——常量
pub fn default_options() -> PathOptions {
  abort("moon-hutool/path 第一批未实现（契约 docs/spec/15-path.md）")
}

///|
/// 路径匹配错误三档，全部来自参照实现的真抛点（读数见 spec §4 腿 A 的 `raise|` 行）。
///
/// - Note: 参照实现抛的是 `IllegalStateException`（不匹配）与两种 `IllegalArgumentException`，
///   本库不搬 Java 异常类名，只把**语义**收成三档；消息文本不作承诺。
pub suberror PathError {
  /// 模式不匹配该路径。载荷 = `(pattern, path)` 两侧原文；
  /// 参照实现在这一档抛 `IllegalStateException`，本库不搬文案
  NoMatch(String, String)
  /// `{*name}` 档：本库与参照实现同样**不支持**。载荷 = 变量名原文（含前导 `*`）
  CapturingVar(String)
  /// 子表达式里带捕获组（如 `{n:(a)(b)}`）。载荷 = 该段子表达式原文
  CaptureGroupRegex(String)
  /// `combine` 的后缀冲突档：两侧都带**非全能**后缀（如 `/*.jsp` 与 `/*.txt`）时抛。
  /// 参照实现抛 `IllegalArgumentException("Cannot combine patterns: ...")`（源码 596~598 行），
  /// 本档是契约补充笔补进来的——PR-A 把 combine 写成无 raise，把这一档提到了源码里才发现
  ExtensionConflict(String, String)
}

///|
/// 是否含通配语法（`*`、`?`、`{...}`）。参照实现实测：`/hotels` 假、`/hotels/*` 真、`/{name}` 真、
/// `""` 假、`/a:b` 假（**冒号不算模式字符**）、`**` 真。
/// - Raises: 无——纯判定
pub fn is_pattern(pattern : String) -> Bool {
  abort("moon-hutool/path 第一批未实现（契约 docs/spec/15-path.md）")
}

///|
/// 默认档整段匹配（`default_options()` 那三个开关）。名字不叫 `match`——`match` 是 MoonBit 保留字。
/// - Raises: 无——匹配判定自身不抛，非法模式给假（参照实现对非法模式的抛点只出现在 `extract` 那一族）
pub fn match_path(pattern : String, path : String) -> Bool {
  abort("moon-hutool/path 第一批未实现（契约 docs/spec/15-path.md）")
}

///|
/// 带开关的整段匹配。语义档位（全部实测，spec §3.1 的档位表逐条对读）：
/// `?` 单段内单字符、`*` 单段内任意（**不跨分隔符**）、`**` 必须占整段且可跨段（也可吞零段）、
/// `{name}` 单段、`{name:子表达式}` 按 core 方言的子表达式、大小写与裁空格跟着 `opts` 走。
/// - Raises: 无——同上
pub fn match_path_with(
  pattern : String,
  path : String,
  opts : PathOptions,
) -> Bool {
  abort("moon-hutool/path 第一批未实现（契约 docs/spec/15-path.md）")
}

///|
/// 前缀式匹配（参照实现 `matchStart`）：路径可以在模式中途结束。实测档位：
/// `/WEB-INF/**` 对 `/WEB-INF/classes/x/y` 真；`/WEB-INF/*` 对 `/WEB-INF/classes/x` **假**（`*` 不跨段）；
/// `/com/*` 对 `/co` 假（半段不算）。
/// - Raises: 无
pub fn match_start_with(
  pattern : String,
  path : String,
  opts : PathOptions,
) -> Bool {
  abort("moon-hutool/path 第一批未实现（契约 docs/spec/15-path.md）")
}

///|
/// 抽出模板变量（`{name}` → 值）。三档错误见 `PathError`。
///
/// - Raises: `NoMatch`（模式不匹配）、`CapturingVar`（`{*name}` 档，本库判不支持）、
///   `CaptureGroupRegex`（子表达式里带捕获组，如 `{n:(a)(b)}`——注意这种模式 `match_path_with` 仍给真）
pub fn extract_variables_with(
  pattern : String,
  path : String,
  opts : PathOptions,
) -> Map[String, String] raise PathError {
  abort("moon-hutool/path 第一批未实现（契约 docs/spec/15-path.md）")
}

///|
/// 默认档抽变量。
/// - Raises: 同 `extract_variables_with`
pub fn extract_variables(
  pattern : String,
  path : String,
) -> Map[String, String] raise PathError {
  abort("moon-hutool/path 第一批未实现（契约 docs/spec/15-path.md）")
}

///|
/// 取路径落在模式"通配尾部"里的那一段。实测：`/WEB-INF/**` 对 `/WEB-INF/web.xml` 给 `web.xml`；
/// `/**` 对 `/a/b` 给 `a/b`；精确模式 `/a/b` 对 `/a/b` 给**空串**；不匹配也给空串（参照实现不抛）。
/// - Raises: 无
pub fn extract_within(pattern : String, path : String) -> String {
  abort("moon-hutool/path 第一批未实现（契约 docs/spec/15-path.md）")
}

///|
/// 拼两个模式。**不是纯拼接**——前置分支也是契约，全部来自源码 565~600 行与本包读数：
/// 1. 某一侧为空串 → 取另一侧；两边都空 → 空串。
/// 2. `prefix` 不含 `{`、与 `suffix` 不相等、且 `match_path(prefix, suffix)` 成立 → **直接返回 `suffix`**
///    （实测 `combine("/*.jsp", "/hotels.jsp")` 给 `/hotels.jsp`）。
/// 3. `prefix` 以 `<sep>*` 结尾 → 先截掉末尾两个字符再拼（`/hotels/*` + `/bookings` 给 `/hotels/bookings`）；
///    以 `<sep>**` 结尾 → 直接拼（`/hotels/**` + `/bookings` 给 `/hotels/**/bookings`）。
/// 4. 含 `*.` 且两侧后缀**都不全能** → `ExtensionConflict`（`/*.jsp` + `/*.txt`、`/*.jsp` + `/WEB-INF/x.jsp` 均抛）；
///    一侧全能（后缀为 `.*` 或空）则取另一侧的后缀（`/*.jsp` + `/hotels` 给 `/hotels.jsp`）。
/// 5. 其余情况才是拼接，且分隔符**不去重也不补齐**：`combine("/test/", "//hotels.html")` 给 `/test//hotels.html`；
///    两边相等也拼：`combine("/hotels", "/hotels")` 给 `/hotels/hotels`。
/// - Raises: `PathError.ExtensionConflict(prefix, suffix)`
pub fn combine(prefix : String, suffix : String) -> String raise PathError {
  abort("moon-hutool/path 第一批未实现（契约 docs/spec/15-path.md）")
}

///|
/// 模式排序比较器：给 `pattern` 这个"实路径"时，哪个模式**更具体**。用于把候选模式排成"具体在前"。
/// 实测读数（spec §3.4 的四条排序例）：对 `/hotels/chicago`，
/// `/hotels/*` < `/**/hotels/**` < `/hotels/**` < `/**`（越靠前越具体）。
///
/// - Returns: **负数**（`a` 更具体、该排前）、0（同等级）、**正数**；直接可作 `sort` 的比较函数。
///   用 `Int` 而不用 `Ordering`：本仓没有 `Ordering` 的现成前例，而排序函数正好要 `Int`
/// - Raises: 无
pub fn compare_patterns(against : String, a : String, b : String) -> Int {
  abort("moon-hutool/path 第一批未实现（契约 docs/spec/15-path.md）")
}

///|
/// 参照实现的 `DEFAULT_PATH_SEPARATOR` 读数（`"/"`）；注册一个取它的函数而不是常量，
/// 是为了让调用方可以拿它拼 `PathOptions`。
/// - Raises: 无——常量
pub fn default_separator() -> String {
  abort("moon-hutool/path 第一批未实现（契约 docs/spec/15-path.md）")
}
