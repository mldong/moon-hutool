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
  must_compile(pattern)
}

///|
/// 模式能不能编译。对位"try/catch 一个 `Pattern.compile`"的常见手写检查。
///
/// - Parameters:
///   - `pattern`：模式串
/// - Returns: 可编译 ⇒ `true`；任何编译失败 ⇒ `false`（不抛错，本件是唯一"吞掉错误"的那一件）
/// - Note: 存在的理由是**校验场景不该被迫处理异常**；判定与 `compile` 用同一张嘴，二者不会给相反答案
pub fn is_valid_pattern(pattern : String) -> Bool {
  try {
    let _ = @string.Regex(pattern.to_string_view())
    true
  } catch {
    _ => false
  }
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
  let out : Array[Char] = []
  for c in text.to_array() {
    if is_re_key(c) {
      out.push('\\')
    }
    out.push(c)
  }
  String::from_array(out)
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
  // 整串语义用锚定包装表达：锚在最左一段上判"占满"会给错答案（判别夹具见 re_test.mbt 第 13 块，
  // 腿 A 现读 isMatch("a|ab","ab") = true）
  match must_compile_whole(pattern).execute(text.to_string_view()) {
    Some(_) => true
    None => false
  }
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
  match must_compile(pattern).execute(text.to_string_view()) {
    Some(_) => true
    None => false
  }
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
  let re = must_compile(pattern)
  let mut n = 0
  for _ in re.find(text.to_string_view()) {
    n = n + 1
  }
  n
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
  match must_compile(pattern).execute(text.to_string_view()) {
    Some(m) => Some(m.content().to_owned())
    None => None
  }
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
  match must_compile(pattern).execute(text.to_string_view()) {
    Some(m) => group_text(m, group)
    None => None
  }
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
  match must_compile(pattern).execute(text.to_string_view()) {
    Some(m) =>
      match m.named_group(name) {
        Some(v) => Some(v.to_owned())
        None => None
      }
    None => None
  }
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
  let out : Array[String] = []
  for m in must_compile(pattern).find(text.to_string_view()) {
    out.push(m.content().to_owned())
  }
  out
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
  let re = must_compile(pattern)
  let out : Array[String?] = []
  for m in re.find(text.to_string_view()) {
    out.push(group_text(m, group))
  }
  out
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
  let re = must_compile(pattern)
  let (cnt, _) = scan_groups(pattern)
  let want0 = match with_group0 {
    None => true
    Some(b) => b
  }
  match re.execute(text.to_string_view()) {
    None => []
    Some(m) => {
      let out : Array[String?] = []
      if want0 {
        out.push(Some(m.content().to_owned()))
      }
      let mut g = 1
      while g <= cnt {
        out.push(group_text(m, g))
        g = g + 1
      }
      out
    }
  }
}

///|
/// 模式里声明了哪些命名组。对位 `ReUtil.getAllGroupNames` 里"名字从哪来"那一步——
/// 那一步在 hutool 是反射调 `Pattern.namedGroups()`，在 JDK 17 的模块封锁下直接
/// `InaccessibleObjectException`（实测：不加 `--add-opens` 时整条腿炸），本包改为扫模式串。
///
/// - Parameters:
///   - `pattern`：模式串
/// - Returns: 组名数组，**按声明顺序**；没有命名组 ⇒ 空数组
/// - Raises: `ReError.BadPattern(pattern)`：先过编译这一关，再查命名组重名——
///   `(?<a>x)(?<a>y)` 实测 **core 接受**、Java 拒绝（`Named capturing group <a> is already defined`），
///   本包按参照实现拦下来（改判过程见 spec §5 第 13 行）
/// - Note: Java 侧那份是 `HashMap`，键序不可依赖；本包给声明序，稳定且可复跑
pub fn group_names(pattern : String) -> Array[String] raise ReError {
  // 先过编译这一关，再查重名：实测 core **接受** `(?<a>x)(?<a>y)`，而参照实现（Java）拒绝 ⇒ 拦在这里
  let _ = must_compile(pattern)
  let (_, names) = scan_groups(pattern)
  names
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
  let re = must_compile(pattern)
  let (_, names) = scan_groups(pattern)
  let out : Map[String, String] = Map([])
  match re.execute(text.to_string_view()) {
    None => out
    Some(m) => {
      for name in names {
        match m.named_group(name) {
          Some(v) => out[name] = v.to_owned()
          // 名字在但这一条匹配里没参与 ⇒ 键不出现（§5 第 11 行）
          None => ()
        }
      }
      out
    }
  }
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
  let re = must_compile(pattern)
  let v = text.to_string_view()
  match re.execute(v) {
    Some(m) => Some(match_range(m, v))
    None => None
  }
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
  let re = must_compile(pattern)
  let v = text.to_string_view()
  let mut last : (Int, Int)? = None
  for m in re.find(v) {
    last = Some(match_range(m, v))
  }
  last
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
  let out : Array[String] = []
  for part in must_compile(pattern).split(text.to_string_view()) {
    out.push(part.to_owned())
  }
  out
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
  let re = must_compile(pattern)
  let v = text.to_string_view()
  match re.execute(v) {
    None => text
    Some(m) => {
      let (start, end) = match_range(m, v)
      splice(v, start, end)
    }
  }
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
  let re = must_compile(pattern)
  let v = text.to_string_view()
  let mut hole : (Int, Int)? = None
  for m in re.find(v) {
    hole = Some(match_range(m, v))
  }
  match hole {
    None => text
    Some((start, end)) => splice(v, start, end)
  }
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
  // 交给引擎的"全部替换成空串"：零宽命中替换成空串等于什么都不动（实测 `x*` 于 `abab` 原样返回）
  must_compile(pattern).replace_by(text.to_string_view(), _ => "").to_owned()
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
  let re = must_compile(pattern)
  let v = text.to_string_view()
  match re.execute(v) {
    None => text
    Some(m) => {
      let (_, end) = match_range(m, v)
      v[end:v.length()].to_owned()
    }
  }
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
  let re = must_compile(pattern)
  let (cnt, _) = scan_groups(pattern)
  let v = text.to_string_view()
  match re.execute(v) {
    None => None
    Some(m) => Some(subst_template(template, cnt, m))
  }
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
  let re = must_compile(pattern)
  let (cnt, _) = scan_groups(pattern)
  let v = text.to_string_view()
  let mut out = ""
  let mut cursor = 0
  let mut hit = false
  for m in re.find(v) {
    let (start, end) = match_range(m, v)
    out = out + v[cursor:start].to_owned() + subst_template(template, cnt, m)
    cursor = end
    hit = true
  }
  if hit {
    out + v[cursor:v.length()].to_owned()
  } else {
    // 一处都没命中 ⇒ 原文（模板里的引用也不校验：没代入就没有"引用不存在"这回事）
    text
  }
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
  // 回调返回值按字面写入：core 的 replace_by 不二次解释替换文本（实测 `$1` 留在输出里）
  must_compile(pattern)
  .replace_by(text.to_string_view(), m => replacer(m).to_string_view())
  .to_owned()
}

///|
// 本包内部件：编译并把 core 的编译异常换成带原模式串的读数（spec §0.5：core 的 ParserError 未导出）
fn must_compile(pattern : String) -> @string.Regex raise ReError {
  @string.Regex(pattern.to_string_view()) catch {
    _ => raise BadPattern(pattern)
  }
}

///|
// 整串匹配用的锚定包装：`^(?:…)$` 不新增捕获组，所以组号与位置口径与裸模式一致；
// 报错载荷仍报**原模式串**，不把包装串漏给调用方
fn must_compile_whole(pattern : String) -> @string.Regex raise ReError {
  @string.Regex(("^(?:" + pattern + ")$").to_string_view()) catch {
    _ => raise BadPattern(pattern)
  }
}

///|
// hutool `ReUtil.RE_KEYS` 那 15 个字符，逐字跟随（不扩到 core 的全部元字符，也不含 `-`/`=`/空格）
fn is_re_key(c : Char) -> Bool {
  match c {
    '$'
    | '('
    | ')'
    | '*'
    | '+'
    | '.'
    | '['
    | ']'
    | '?'
    | '\\'
    | '^'
    | '{'
    | '}'
    | '|' => true
    _ => false
  }
}

///|
// 扫模式串取 (捕获组数, 命名组声明序)。只在**已编译通过**的模式上调用，所以不必处理非法写法。
// 需要它是因为 core 的 `MatchResult` 不公开组数，也不给"越界"和"没参与"的区分
fn scan_groups(pattern : String) -> (Int, Array[String]) raise ReError {
  let cs = pattern.to_array()
  let n = cs.length()
  let mut count = 0
  let names : Array[String] = []
  let mut in_class = false
  let mut i = 0
  while i < n {
    let c = cs[i]
    if in_class {
      // 字符类里 ( ) 都是普通字符，只有反斜杠能转义
      if c == '\\' {
        i = i + 2
      } else {
        if c == ']' {
          in_class = false
        }
        i = i + 1
      }
    } else if c == '\\' {
      i = i + 2
    } else if c == '[' {
      in_class = true
      i = i + 1
    } else if c == '(' {
      if i + 1 < n && cs[i + 1] == '?' {
        if i + 3 < n && cs[i + 2] == '<' && cs[i + 3] != '=' && cs[i + 3] != '!' {
          // (?<name>…：本方言唯一支持的命名写法（(?'x'…) 与 (?P<x>…) 实测编译期报错）
          let mut j = i + 3
          while j < n && cs[j] != '>' {
            j = j + 1
          }
          let nm = String::from_array(cs[i + 3:j])
          for e in names {
            if e == nm {
              // 重名：core 实测**接受**（编译通过），Java 拒绝 ⇒ 本包按参照实现那条判断自己预检
              // （契约 #10.13 冻的是 `BadPattern`；留着两个同名组，`named_groups` 的键就只有一个能读到值）
              raise BadPattern(pattern)
            }
          }
          names.push(nm)
          count = count + 1
          i = j + 1
        } else {
          // (?:… 一类非捕获前缀：不产生组
          i = i + 1
        }
      } else {
        count = count + 1
        i = i + 1
      }
    } else {
      i = i + 1
    }
  }
  (count, names)
}

///|
// core 没给位置出口：起点取 `before()` 的长度，终点用"全长减 `after()` 长度"反推（同 §0.4 的 UTF-16 码元口径）
fn match_range(m : @string.MatchResult, v : StringView) -> (Int, Int) {
  let start = m.before().length()
  (start, v.length() - m.after().length())
}

///|
// 组值取文本：0 组是整段，1 起是括号组；没参与与越界同档给 `None`（§5 第 4 行）
fn group_text(m : @string.MatchResult, g : Int) -> String? {
  if g == 0 {
    Some(m.content().to_owned())
  } else {
    match m.group(g) {
      Some(v) => Some(v.to_owned())
      None => None
    }
  }
}

///|
fn splice(v : StringView, start : Int, end : Int) -> String {
  v[0:start].to_owned() + v[end:v.length()].to_owned()
}

///|
// 模板代入：引用按**数字位数从长到短**替换（参照实现那侧是长度降序的有序集）。
// 同长度的引用互不为前缀，谁先谁后不影响结果；跨长度才分先后——`$1-$11` 于 12 组模式 ⇒ `a-k`
fn subst_template(
  template : String,
  cnt : Int,
  m : @string.MatchResult,
) -> String raise ReError {
  let vars = template_refs(template)
  let mut out = template
  for v in vars {
    let idx = digits_to_int(v)
    if idx > cnt {
      raise BadReference("$" + v)
    }
    let val = match group_text(m, idx) {
      // "存在但没参与"代入空串：参照实现在这档是崩（NPE），崩底下那层 JDK 的替换语义是空串（§5 第 12 行）
      Some(s) => s
      None => ""
    }
    out = str_replace_all(out, "$" + v, val)
  }
  out
}

///|
// 取模板里所有 `$数字` 引用，去重后按位数降序
fn template_refs(template : String) -> Array[String] {
  let cs = template.to_array()
  let n = cs.length()
  let vars : Array[String] = []
  let mut i = 0
  while i < n {
    if cs[i] == '$' {
      let mut j = i + 1
      while j < n && cs[j] >= '0' && cs[j] <= '9' {
        j = j + 1
      }
      if j > i + 1 {
        let name = String::from_array(cs[i + 1:j])
        let mut seen = false
        for e in vars {
          if e == name {
            seen = true
          }
        }
        if seen == false {
          vars.push(name)
        }
      }
      i = j
    } else {
      i = i + 1
    }
  }
  // 位数长的在前：`$1-$11` 先替 `$11` 才不会把 `$11` 拆成 `$1` + `1`。
  // 按位数分桶挑出来，不依赖排序件的签名形状
  let by_len : Array[String] = []
  let mut maxlen = 1
  for e in vars {
    let l = e.to_array().length()
    if l > maxlen {
      maxlen = l
    }
  }
  while maxlen >= 1 {
    for e in vars {
      if e.to_array().length() == maxlen {
        by_len.push(e)
      }
    }
    maxlen = maxlen - 1
  }
  by_len
}

///|
fn digits_to_int(digits : String) -> Int {
  let mut n = 0
  for c in digits.to_array() {
    n = n * 10 + (c.to_int() - '0'.to_int())
  }
  n
}

///|
// 自己写的整串替换：core 的 `replace_all` 会把替换文本再解释一遍，而这里必须按字面落下
// （判别夹具：模式 `([$\\])`、内容 `$\`、模板 `($1)` ⇒ `($)(\)`）
fn str_replace_all(text : String, from : String, into : String) -> String {
  let src = text.to_array()
  let pat = from.to_array()
  let plen = pat.length()
  if plen == 0 {
    text
  } else {
    let out : Array[Char] = []
    let mut i = 0
    while i < src.length() {
      if i + plen <= src.length() && starts_at(src, i, pat) {
        for c in into.to_array() {
          out.push(c)
        }
        i = i + plen
      } else {
        out.push(src[i])
        i = i + 1
      }
    }
    String::from_array(out)
  }
}

///|
fn starts_at(src : Array[Char], at : Int, pat : Array[Char]) -> Bool {
  let mut ok = true
  let mut i = 0
  while i < pat.length() && ok {
    if src[at + i] != pat[i] {
      ok = false
    }
    i = i + 1
  }
  ok
}
