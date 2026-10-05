# re

hutool `ReUtil` 的 **MoonBit 对位**：整串匹配、组与位置的出口、模板替换、删除族、按模式切分、
按字面写回的回调替换——24 条公开项都建立在 core 的 `@string.Regex` 之上，本包**不重写引擎**。

完整边界矩阵与逐条读数来源见 [`docs/spec/10-re.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/10-re.md)。本页只放**典型用法**，
每条都带期望值——这些 `test` 块会被 `moon test` 真编译真执行。

> 状态：**已交付**（10-05，契约与实现两笔）。文档块与 `re_test.mbt` 的 13 块同受"期望值冻结"约束（门禁 G5），
> `wasm`/`js`/`wasm-gc` 三档读数一致，native 档由 CI 编译出证。

## 先说清这个引擎能写什么

判据来自实测：把 114 条探针跑在 `wasm`/`js`/`wasm-gc` 三档，**三份输出逐字节相同**——所以"能不能写"
由引擎说了算，Java 那边能不能写只说明"那是 Java 的写法"。三件最容易撞的：

- `\d` `\w` `\s` `\xHH` `\p{…}` `\1` `\A` `\z` `\Q` `(?=…)` `(?<=…)` `*+` `(?i)`（全局）**全部编译期报错**，
  不是静默退化。本包既不自动改写（`(?i)` 是全局、`(?i:…)` 是局部，改写会让同一串在两个引擎里读成不同东西），
  也不假装支持；
- `.` **默认含换行**（等于 hutool 全线带的 `Pattern.DOTALL`），而 `^`/`$` 恒整串、没有行级档；
- 位置口径是 **UTF-16 码元**，与 Java `Matcher.start()/end()` 同档。

```mbt check
///|
test "compile 与 is_valid_pattern 同一张嘴" {
  assert_eq(@re.is_valid_pattern("[[:digit:]]+"), true)
  assert_eq(@re.is_valid_pattern("(?<y>[0-9]{4})"), true)
  // Java 风味写法在本方言里是编译期报错，不是"能跑但意思变了"
  assert_eq(@re.is_valid_pattern("\\d+"), false)
  assert_eq(@re.is_valid_pattern("(?=a)"), false)
  let r = @re.compile("[0-9]+")
  assert_eq(r.execute("a12b").map(m => m.content().to_owned()), Some("12"))
}
```

```mbt check
///|
test "quote 跟随的是 hutool 那 15 个关键字，不是 core 的全部元字符" {
  assert_eq(@re.quote("a.b"), "a\\.b")
  assert_eq(@re.quote("$1|2"), "\\$1\\|2")
  // 表里没有的字符原样：`-`、`=`、空格、非 ASCII
  assert_eq(@re.quote("-="), "-=")
  assert_eq(@re.quote("中文"), "中文")
}
```

```mbt check
///|
test "is_match 是整串，contains 是有一处" {
  assert_eq(@re.is_match("[0-9]+", "1234"), true)
  assert_eq(@re.is_match("[0-9]+", "中文1234"), false)
  assert_eq(@re.contains("[0-9]+", "中文1234"), true)
  // 择路档：整串语义不是"最左一段恰好占满"
  assert_eq(@re.is_match("a|ab", "ab"), true)
  assert_eq(@re.count("x*", "abab"), 5)
}
```

```mbt check
///|
test "取组只有一个出口档：没命中、没参与、越界都是 None" {
  let p = "(?<a>[0-9]+)-(?<b>[0-9]+)"
  assert_eq(@re.find_first(p, "2026-10-05"), Some("2026-10"))
  assert_eq(@re.find_first_group(p, "2026-10-05", 1), Some("2026"))
  assert_eq(@re.find_first_named(p, "2026-10-05", "b"), Some("10"))
  // hutool 在后两档直接崩（No group 9 / No group with name <z>），本包不跟随
  assert_eq(@re.find_first_group(p, "2026-10-05", 9), None)
  assert_eq(@re.find_first_named(p, "2026-10-05", "z"), None)
  let g = @re.named_groups(p, "2026-10-05")
  assert_eq(g.get("a"), Some("2026"))
  assert_eq(g.length(), 2)
}
```

```mbt check
///|
test "位置是半开区间，口径 UTF-16 码元" {
  assert_eq(@re.first_position("[0-9]+", "a1b22c333"), Some((1, 2)))
  assert_eq(@re.last_position("[0-9]+", "a1b22c333"), Some((6, 9)))
  // 「中文」两字占 2 个码元，所以数字起点是 2
  assert_eq(@re.first_position("[0-9]+", "中文1234"), Some((2, 6)))
  assert_eq(@re.find_all("[0-9]+", "a1b22c333"), ["1", "22", "333"])
}
```

```mbt check
///|
test "切分保留尾部空段：跟引擎，不二次修剪" {
  assert_eq(@re.split("[,;]", "a,b;c"), ["a", "b", "c"])
  // Java 的 String.split 会丢尾随空段，这一档本包声明为不跟随（spec §5 第 6 行）
  assert_eq(@re.split("[,;]", ",a,"), ["", "a", ""])
  assert_eq(@re.split("[0-9]", "abc"), ["abc"])
}
```

```mbt check
///|
test "删除族四件：del_pre 删到匹配结束为止" {
  assert_eq(@re.del_first("[0-9]+", "a1b22c333"), "ab22c333")
  assert_eq(@re.del_last("[0-9]+", "a1b22c333"), "a1b22c")
  assert_eq(@re.del_all("[0-9]+", "a1b22c333"), "abc")
  assert_eq(@re.del_pre("[0-9]+", "a1b22c333"), "b22c333")
  assert_eq(@re.del_all("b", "bbb"), "")
  // 零宽模式什么都不删
  assert_eq(@re.del_all("x*", "abab"), "abab")
}
```

```mbt check
///|
test "模板代入按位数从长到短：$1-$11 于 12 组模式得 a-k" {
  let p = "(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)(k)(l)"
  assert_eq(@re.extract_with_template(p, "abcdefghijkl", "$1-$11"), Some("a-k"))
  assert_eq(@re.extract_with_template(p, "abcdefghijkl", "$11$1"), Some("ka"))
  // 按升序先替 $1，同输入会得到 "a-a-11"——这条就是分辨两种顺序的夹具
  assert_eq(
    @re.extract_with_template("(.*?)年(.*?)月", "2013年5月", "$1-$2"),
    Some("2013-5"),
  )
  assert_eq(@re.extract_with_template("([0-9]+)", "abc", "[$1]"), None)
}
```

引用不存在的组时，本包给 `BadReference("$13")` 这样的可读错误——hutool 在同一档是
`IndexOutOfBoundsException: No group 111`，把内部越界当契约不成立。这一档的断言在
`re_test.mbt` 第 11、12 块里（文档页只放不抛错的典型用法）。

```mbt check
///|
test "replace_with_template 保留周围，回调 replace_by 按字面写回" {
  assert_eq(
    @re.replace_with_template(
      "([0-9])([0-9])([0-9])", "abc xyz 123456", "$1-$2",
    ),
    "abc xyz 1-24-5",
  )
  assert_eq(@re.replace_with_template("([0-9]+)", "abc", "[$1]"), "abc")
  // 组值里的 $ 与 \ 不会被二次解释
  assert_eq(@re.replace_with_template("([$\\\\])", "$\\", "($1)"), "($)(\\)")
  assert_eq(
    @re.replace_by("([0-9]+)", "a1b22", m => "-" + m.content().to_owned() + "-"),
    "a-1-b-22-",
  )
}
```

## 这一包不做什么

| 不做 | 为什么 |
|---|---|
| 全局模式池（对位 `PatternPool`） | 纯计算库不带进程级可变表；要缓存由调用方持有 `compile` 的结果 |
| `\d → [[:digit:]]` 之类的自动改写 | 两腿的**合法集不同**（`(?i)`、`a{300}` 一边合法一边报错），改写等于在引擎之上再造一份语义。改写对照表在 spec §7，是给调用方看的 |
| `MULTILINE`、lookaround、反向引用、Unicode 块类 | 引擎没有这些档，本包不发明"假装支持"的前缀处理 |
| `replace_first` / `limit` 参数 | core 的 `replace_by` 在 `limit` 为负时**一处都不换**（实测），把 `-1` 当"无限"透传等于把陷阱写进契约；只换第一处用 `del_first` 的语义另议 |
| `RegexPool`/`PatternPool` 常量表 | 第二批。34 条里 24 条带 core 不收的写法，要么逐条改写并逐条对撞命中集，要么整批不做 |
