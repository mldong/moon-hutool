///|
/// moon-hutool/re —— 正则查询与替换件（hutool `ReUtil` 的 MoonBit 对位·第一批）
///
/// 契约：`docs/spec/10-re.md`。期望值权威在 `re_test.mbt` 与 spec 的读数表——改任何期望串须单独一笔
/// 并给外部读数来源（门禁 G5），实现只负责把契约里冻好的读数算出来。
///
/// 底座是 `moonbitlang/core` 的 `@string.Regex`（纯 MoonBit 引擎，Brzozowski 导数自动机）。
/// 本包不重新实现引擎，只做四件事：**整串匹配包装、组与位置的出口、模板替换的降序替换、删除族与分割**。
/// 这四件事每一件都有 hutool 对位，且都在 core 没有直接给出的那一侧。
///
/// 五条贯穿性规则（spec §0，这五条决定了本包哪些函数存在、哪些不存在）：
/// 1. **不建全局模式池**。hutool 的 `PatternPool` 是一张进程级可变缓存表（`Map<RegexWithFlag, Pattern>`），
///    本包与 `conv` 的"没有全局可变注册表"同一条立场：要缓存由调用方持有 `compile` 的结果。
/// 2. **方言不假装**。`@string.Regex` 不收 `\d`/`\w`/`\s`/`\xHH`/`\p{…}`/`\1`/`(?i)`/`(?=…)`/`*+`
///    （实测：全部编译期报错，不是静默退化），本包不透传任何"Java 能写而 core 不能写"的模式，
///    也不做 `\d → [[:digit:]]` 这种自动改写——改写会让同一串模式在两个引擎里读成不同的东西。
/// 3. **视图类型不外溢**。core 的 `Regex`/`MatchResult` 是 `StringView` 一族的类型，
///    本包的输入输出一律 `String`/`Array[String]`；唯一例外是 `replace_by` 的回调参数（见 #10.24）。
/// 4. **位置口径是 UTF-16 码元**。core 只给 `before()`/`after()` 视图，起点靠长度换算，
///    与 Java `Matcher.start()/end()` 同口径（两腿实测逐条相等）；不另发"码位下标"那一档。
/// 5. **错误只带读数**：编译失败带模式串，模板引用不存在的组带那个引用原文。
///    core 的 `ParserError` 未导出（`pkg.generated.mbti` 的 Errors 段是空的），
///    位置与提示取不到——把它的文案抄进我们的载荷就等于把 core 的措辞冻进本包契约。

///|
/// 本包唯一错误面。每个变体对应**一个** `raise` 点，载荷只放调用方拿不到的读数
pub suberror ReError {
  /// 模式编译失败。载荷 = 原模式串。
  /// core 的报错位置与提示取不到（`ParserError` 未导出），本包不搬运文案
  BadPattern(String)
  /// 模板里的 `$N` 引用了不存在的组。载荷 = 那个引用原文（如 `"$11"`）
  BadReference(String)
}

///|
/// 编译模式串，得到可复用的 `Regex`。对位 hutool `PatternPool.get(regex, Pattern.DOTALL)`——
/// 但**不建缓存表**（§0 第 1 条），同串重复编译由调用方自己决定是否复用返回值。
///
/// - Parameters:
///   - `pattern`：模式串，方言是 core 的方言（`[[:digit:]]` 而非 `\d`；`(?i:…)` 而非 `(?i)`）
/// - Returns: 编译好的 `Regex`，可直接用 core 的 `execute`/`find`/`split`/`replace_by`
/// - Raises: `ReError.BadPattern(pattern)`：模式不合法
/// - Note: `.` 在本引擎里**含换行**（实测 `find` 于 `"a\nb"` 给 3 条：`a`、`\n`、`b`），
///   相当于 hutool 全线带 `Pattern.DOTALL`——这一点与参照实现一致，不必再声明分岔
pub fn compile(pattern : String) -> @string.Regex raise ReError {
  abort("moon-hutool 契约未实现：compile")
}

///|
/// 模式能不能编译。对位"try/catch 一个 `Pattern.compile`"的常见手写检查。
///
/// - Parameters:
///   - `pattern`：模式串
/// - Returns: 可编译 ⇒ `true`；任何编译失败 ⇒ `false`（不抛错，本件是唯一"吞掉错误"的那一件）
/// - Note: 存在的理由是**校验场景不该被迫处理异常**；判定与 `compile` 用同一张嘴，二者不会给相反答案
pub fn is_valid_pattern(pattern : String) -> Bool {
  abort("moon-hutool 契约未实现：is_valid_pattern")
}

///|
/// 把任意串转义成"只能字面匹配"的模式片段。对位 `ReUtil.escape(CharSequence)`。
///
/// - Parameters:
///   - `text`：待转义原文
/// - Returns: 在 hutool 的 15 个关键字字符（`$ ( ) * + . [ ] ? \ ^ { } |`）前各加一个反斜杠的结果；
///   其余字符原样（含 `-`、`=`、空格与非 ASCII）
/// - Note: 转义表**逐字跟随** hutool，不扩到 core 的全部元字符——本件的对位是那张表，不是"绝对安全"。
///   要绝对安全的字面匹配用 `@string.Regex::string(原文)`
pub fn quote(text : String) -> String {
  abort("moon-hutool 契约未实现：quote")
}

///|
/// 整串匹配。对位 `ReUtil.isMatch(regex, content)`（Java 侧是 `Matcher.matches()`）。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被匹配的内容
/// - Returns: 整个 `text` 被 `pattern` 匹配 ⇒ `true`
/// - Raises: `ReError.BadPattern(pattern)`
/// - Note: **不跟随** hutool 的两条哨兵：`regex` 为空串时 hutool 直接返回 `true`
///   （实测 `isMatch("", "abc") ⇒ true`，而 Java 自己的 `matches()` 在同一输入上是 `false`），
///   本包走引擎语义（空模式只匹配空串）。这一条改的是参照实现，不是参照实现下面的引擎
pub fn is_match(pattern : String, text : String) -> Bool raise ReError {
  abort("moon-hutool 契约未实现：is_match")
}

///|
/// 内容里有没有匹配。对位 `ReUtil.contains`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被查找的内容
/// - Returns: 至少有一处匹配 ⇒ `true`
/// - Raises: `ReError.BadPattern(pattern)`
pub fn contains(pattern : String, text : String) -> Bool raise ReError {
  abort("moon-hutool 契约未实现：contains")
}

///|
/// 匹配个数。对位 `ReUtil.count`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被查找的内容
/// - Returns: 非重叠匹配的条数；零宽模式会数到"每个位置"那一档（实测 `x*` 于 `"abab"` ⇒ 5，两腿一致）
/// - Raises: `ReError.BadPattern(pattern)`
pub fn count(pattern : String, text : String) -> Int raise ReError {
  abort("moon-hutool 契约未实现：count")
}

///|
/// 第一处匹配的整段文本。对位 `ReUtil.getGroup0` / `get(pattern, content, 0)`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被查找的内容
/// - Returns: 命中的整段；没有命中 ⇒ `None`（hutool 在此给 `null`，同一档）
/// - Raises: `ReError.BadPattern(pattern)`
pub fn find_first(pattern : String, text : String) -> String? raise ReError {
  abort("moon-hutool 契约未实现：find_first")
}

///|
/// 第一处匹配的**第 `group` 组**。对位 `ReUtil.get(regex, content, groupIndex)`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被查找的内容
///   - `group`：组号，`0` = 整段，`1` 起是括号组
/// - Returns: 该组文本；没命中、组没参与匹配（如 `(a)?b` 的 `1` 组匹配 `"b"`）、组号越界 ⇒ `None`
/// - Raises: `ReError.BadPattern(pattern)`
/// - Note: **不跟随** hutool 的越界档：它在此 `matcher.group(9)` 直接
///   `IndexOutOfBoundsException: No group 9`（实测），本包把"取不到"统一成 `None`——
///   查询类函数只有一个出口档（同 `conv` 的 `Option` 立场）
pub fn find_first_group(
  pattern : String,
  text : String,
  group : Int,
) -> String? raise ReError {
  abort("moon-hutool 契约未实现：find_first_group")
}

///|
/// 第一处匹配的**命名组**。对位 `ReUtil.get(pattern, content, groupName)`。
///
/// - Parameters:
///   - `pattern`：模式串（命名组写法只有 `(?<name>…)` 一种，实测 `(?'x'…)`/`(?P<x>…)` 编译失败）
///   - `text`：被查找的内容
///   - `name`：组名
/// - Returns: 该组文本；没命中、名字不存在、组没参与 ⇒ `None`
/// - Raises: `ReError.BadPattern(pattern)`
/// - Note: **不跟随** hutool 的"名字不存在"档：它在此抛
///   `IllegalArgumentException: No group with name <z>`（实测），本包给 `None`
pub fn find_first_named(
  pattern : String,
  text : String,
  name : String,
) -> String? raise ReError {
  abort("moon-hutool 契约未实现：find_first_named")
}

///|
/// 所有匹配的整段文本。对位 `ReUtil.findAll(regex, content, 0)`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被查找的内容
/// - Returns: 按出现顺序的整段列表；没有命中 ⇒ 空数组（不是 `None`，hutool 同档）
/// - Raises: `ReError.BadPattern(pattern)`
pub fn find_all(pattern : String, text : String) -> Array[String] raise ReError {
  abort("moon-hutool 契约未实现：find_all")
}

///|
/// 所有匹配的**某一组**。对位 `ReUtil.findAll(regex, content, group)`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被查找的内容
///   - `group`：组号，`0` = 整段
/// - Returns: 每条命中一个元素；该组没参与匹配时是 `None`（hutool 的列表里进的是 `null`，同一档）
/// - Raises: `ReError.BadPattern(pattern)`
pub fn find_all_group(
  pattern : String,
  text : String,
  group : Int,
) -> Array[String?] raise ReError {
  abort("moon-hutool 契约未实现：find_all_group")
}

///|
/// 第一处匹配的全部组。对位 `ReUtil.getAllGroups(pattern, content, withGroup0)`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被查找的内容
///   - `with_group0`：是否带上整段那一组，默认真
/// - Returns: 按组号顺序；没命中 ⇒ 空数组；某组没参与 ⇒ 该元素是 `None`
///   （实测 hutool `(a)?b` 于 `"b"` 给 `[b, null]`）
/// - Raises: `ReError.BadPattern(pattern)`
pub fn groups_of_first(
  pattern : String,
  text : String,
  with_group0? : Bool,
) -> Array[String?] raise ReError {
  abort("moon-hutool 契约未实现：groups_of_first")
}

///|
/// 模式里声明了哪些命名组。对位 `ReUtil.getAllGroupNames` 里"名字从哪来"那一步——
/// 那一步在 hutool 是反射调 `Pattern.namedGroups()`，在 JDK 17 的模块封锁下直接
/// `InaccessibleObjectException`（实测：不加 `--add-opens` 时整条腿炸），本包改为扫模式串。
///
/// - Parameters:
///   - `pattern`：模式串
/// - Returns: 组名数组，**按声明顺序**；没有命名组 ⇒ 空数组
/// - Raises: `ReError.BadPattern(pattern)`：先过编译这一关（`(?<a>x)(?<a>y)` 这种重名同样报错，
///   与 Java 的 `Named capturing group <a> is already defined` 同一判断）
/// - Note: Java 侧那份是 `HashMap`，键序不可依赖；本包给声明序，稳定且可复跑
pub fn group_names(pattern : String) -> Array[String] raise ReError {
  abort("moon-hutool 契约未实现：group_names")
}

///|
/// 第一处匹配的命名组 → 值。对位 `ReUtil.getAllGroupNames(pattern, content)`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被查找的内容
/// - Returns: 名字 → 该组文本，**只收参与了这个匹配的组**；没命中 ⇒ 空 Map
///   （实测 hutool 无命中时同样是空 Map）。某个名字在这一条匹配里没参与（如 `(?<a>x)?y` 里的 `a`）
///   时**这个键不出现**——hutool 那份进的是 `null` 值，本包不让一个值位同时装"有名字没值"和"没这个键"
/// - Raises: `ReError.BadPattern(pattern)`
pub fn named_groups(
  pattern : String,
  text : String,
) -> Map[String, String] raise ReError {
  abort("moon-hutool 契约未实现：named_groups")
}

///|
/// 第一处匹配的起止位置。对位 `ReUtil.indexOf(pattern, content)` 的 `MatchResult.start()/end()`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被查找的内容
/// - Returns: `(起, 止)`，半开区间，口径是 **UTF-16 码元**（§0 第 4 条；两腿实测逐条相等）；
///   没命中 ⇒ `None`
/// - Raises: `ReError.BadPattern(pattern)`
pub fn first_position(
  pattern : String,
  text : String,
) -> (Int, Int)? raise ReError {
  abort("moon-hutool 契约未实现：first_position")
}

///|
/// 最后一处匹配的起止位置。对位 `ReUtil.lastIndexOf`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被查找的内容
/// - Returns: 半开区间 `(起, 止)`；没有命中 ⇒ `None`
/// - Raises: `ReError.BadPattern(pattern)`
pub fn last_position(
  pattern : String,
  text : String,
) -> (Int, Int)? raise ReError {
  abort("moon-hutool 契约未实现：last_position")
}

///|
/// 按模式切分。对位 `ReUtil.splitToArray`（其实现走 Java 的 `String.split(regex)`）。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被切分的内容
/// - Returns: 段数组。**尾部空段保留**（core 的行为，实测 `[,;]` 于 `",a,"` ⇒ `["", "a"]`
///   与 Java 同，而 Java 在**空模式**上不吐首部空段、core 吐 ⇒ 那一档见 spec §5 分岔表）
/// - Raises: `ReError.BadPattern(pattern)`
pub fn split(pattern : String, text : String) -> Array[String] raise ReError {
  abort("moon-hutool 契约未实现：split")
}

///|
/// 删掉第一处匹配。对位 `ReUtil.delFirst`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被处理的内容
/// - Returns: 删掉第一处后的内容；没命中 ⇒ 原文
/// - Raises: `ReError.BadPattern(pattern)`
pub fn del_first(pattern : String, text : String) -> String raise ReError {
  abort("moon-hutool 契约未实现：del_first")
}

///|
/// 删掉最后一处匹配。对位 `ReUtil.delLast`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被处理的内容
/// - Returns: 删掉最后一处后的内容；没命中 ⇒ 原文
/// - Raises: `ReError.BadPattern(pattern)`
pub fn del_last(pattern : String, text : String) -> String raise ReError {
  abort("moon-hutool 契约未实现：del_last")
}

///|
/// 删掉所有匹配。对位 `ReUtil.delAll`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被处理的内容
/// - Returns: 全部删掉后的内容；没命中 ⇒ 原文（零宽模式同样什么都不删，实测 `x*` 于 `"abab"` ⇒ `"abab"`）
/// - Raises: `ReError.BadPattern(pattern)`
pub fn del_all(pattern : String, text : String) -> String raise ReError {
  abort("moon-hutool 契约未实现：del_all")
}

///|
/// 删掉第一处匹配**及其之前**的全部内容。对位 `ReUtil.delPre`（增量爬取时用来推进游标）。
///
/// - Parameters:
///   - `pattern`：定位模式
///   - `text`：被处理的内容
/// - Returns: 从第一处匹配的**结束位置**往后的内容；没命中 ⇒ 原文
/// - Raises: `ReError.BadPattern(pattern)`
pub fn del_pre(pattern : String, text : String) -> String raise ReError {
  abort("moon-hutool 契约未实现：del_pre")
}

///|
/// 按模板从第一处匹配里造一个新串（**丢掉周围内容**）。对位 `ReUtil.extractMulti`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被匹配的内容
///   - `template`：模板，`$1` 表示第 1 组，`$0` 表示整段；`$` 后面不是数字时当普通字符留着
/// - Returns: 模板代入后的字符串；没有命中 ⇒ `None`（hutool 同档给 `null`）
/// - Raises:
///   - `ReError.BadPattern(pattern)`
///   - `ReError.BadReference("$N")`：模板引用了不存在的组。hutool 在此是
///     `IndexOutOfBoundsException: No group 111`（实测），把内部越界当契约不成立 ⇒ 本包给可读错误
/// - Note: **替换顺序是规则不是实现细节**：模板里所有引用按**数字位数从长到短**代入
///   （hutool 用按长度倒序的 `TreeSet`），所以 12 组的模式上 `"$1-$11"` ⇒ `"a-k"`；
///   若按升序先替 `$1`，同输入会得到 `"a-a-11"` —— 判别夹具在 `re_test.mbt`
pub fn extract_with_template(
  pattern : String,
  text : String,
  template : String,
) -> String? raise ReError {
  abort("moon-hutool 契约未实现：extract_with_template")
}

///|
/// 按模板替换所有匹配（**保留周围内容**）。对位 `ReUtil.replaceAll(content, regex, template)`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被替换的内容
///   - `template`：模板，同 `extract_with_template`；每处匹配都重新代入
/// - Returns: 替换后的内容；没有命中 ⇒ 原文。组值里的 `$`、`\` **不会被二次解释**：hutool 在
///   `appendReplacement` 之前先把整个替换串 `escape()` 一遍（实测：模式 `([$\\])`、内容 `"$\\"`、
///   模板 `"($1)"` ⇒ `"($)(\)"`——两个字符各自成段，组值原样落下）
/// - Raises:
///   - `ReError.BadPattern(pattern)`
///   - `ReError.BadReference("$N")`：引用不存在的组，同 `extract_with_template`
/// - Note: 同一套"位数从长到短"代入顺序
pub fn replace_with_template(
  pattern : String,
  text : String,
  template : String,
) -> String raise ReError {
  abort("moon-hutool 契约未实现：replace_with_template")
}

///|
/// 用回调决定每处匹配换成什么。对位 `ReUtil.replaceAll(str, pattern, Func1<Matcher,String>)`。
///
/// - Parameters:
///   - `pattern`：模式串
///   - `text`：被替换的内容
///   - `replacer`：回调，入参是本次匹配（core 的 `MatchResult`，可取组）；返回替换文本
/// - Returns: 替换后的内容；没有命中 ⇒ 原文
/// - Raises: `ReError.BadPattern(pattern)`
/// - Note: 回调返回的串**按字面写入**，不当模板再解释一遍（实测 core 的 `replace_by` 如此）；
///   要模板语义用 `replace_with_template`。本件是 24 条里唯一把视图类型交给调用方的一条（§0 第 3 条例外）
/// - Note: **不许用 `limit = -1` 表达"全部替换"**：core 的 `replace_by` 在 `limit` 为负数时
///   一处都不换（实测 `limit=-1` 与 `limit=0` 同读数），本包不做透传，回调一律全量
pub fn replace_by(
  pattern : String,
  text : String,
  replacer : (@string.MatchResult) -> String,
) -> String raise ReError {
  abort("moon-hutool 契约未实现：replace_by")
}
