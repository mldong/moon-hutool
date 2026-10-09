# moon-hutool/path

Ant 风格路径模式匹配，对位 hutool `cn.hutool.core.text.AntPathMatcher`
（该类是 Spring-framework 同名类的 vendored 拷贝，Apache-2.0 血统，见 [`docs/spec/15-path.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/15-path.md) §0）。

三枚开关（分隔符、大小写、裁空格）收进显式传入的 `PathOptions`，**没有可变对象、也没有全局模式缓存**。

## 通配三件

```mbt check
///|
test "path 通配档位" {
  assert_eq(@path.is_pattern("/hotels/*"), true)
  assert_eq(@path.is_pattern("/hotels"), false)
  // `?` 单段内恰好一个字符
  assert_eq(@path.match_path("/??", "/ab"), true)
  assert_eq(@path.match_path("/??", "/a"), false)
  // `*` 单段内任意，**不跨分隔符**
  assert_eq(@path.match_path("/*.jsp", "/test.jsp"), true)
  assert_eq(@path.match_path("/WEB-INF/*.jsp", "/WEB-INF/a/b.jsp"), false)
  // `**` 必须是整段 token，可跨段、也可吞零段
  assert_eq(@path.match_path("/WEB-INF/**", "/WEB-INF/classes/a.xml"), true)
  assert_eq(@path.match_path("/WEB-INF/**", "/WEB-INF"), true)
}
```

## 开关与自定义分隔符

```mbt check
///|
test "path 三枚开关" {
  let insens = @path.PathOptions::{
    separator: "/",
    case_sensitive: false,
    trim_tokens: false,
  }
  assert_eq(
    @path.match_path_with("/ABC", "/abc", @path.default_options()),
    false,
  )
  assert_eq(@path.match_path_with("/ABC", "/abc", insens), true)
  // hutool 默认**不裁空格**（Spring 原版裁），开了才认
  assert_eq(@path.match_path("/ abc ", "/abc"), false)
  let trim = @path.PathOptions::{
    separator: "/",
    case_sensitive: true,
    trim_tokens: true,
  }
  assert_eq(@path.match_path_with("/ abc ", "/abc", trim), true)
  // 自定义分隔符：模式与路径必须用同一个分隔符，`**` 才落在整段上
  let colon = @path.PathOptions::{
    separator: ":",
    case_sensitive: true,
    trim_tokens: false,
  }
  assert_eq(@path.match_path_with("a:**:c", "a:x:y:c", colon), true)
  assert_eq(@path.match_path_with("a:*:c", "a:b:d:c", colon), false)
}
```

## 抽变量：能匹配不蕴含能抽

```mbt check
///|
test "path 抽变量与错误档" {
  let m = @path.extract_variables("/{p1}/{p2}", "/a/b")
  assert_eq(m["p1"], "a")
  assert_eq(m["p2"], "b")
  // 子表达式按 core 方言写：[[:digit:]] 而非 \d
  assert_eq(@path.is_pattern("/{n:[0-9]+}"), true)
  let e = try {
    let _ = @path.extract_variables("/{name}", "/a/b")
    "ok"
  } catch {
    _ => "NoMatch"
  }
  assert_eq(e, "NoMatch")
  // 模式不匹配时参照实现抛 IllegalStateException，本库收成错误档而不是给空表
  assert_eq(@path.extract_within("/WEB-INF/**", "/WEB-INF/web.xml"), "web.xml")
}
```

## 拼模式与排具体度

```mbt check
///|
test "path combine 与排序" {
  assert_eq(@path.combine("com/**", "*.jsp"), "com/**/*.jsp")
  // 一侧能覆盖另一侧时直接取另一侧
  assert_eq(@path.combine("/*.jsp", "/hotels.jsp"), "/hotels.jsp")
  // 单星结尾会先截掉 `/*`
  assert_eq(@path.combine("/hotels/*", "/bookings"), "/hotels/bookings")
  // 分隔符既不去重也不补齐
  assert_eq(@path.combine("/test/", "//hotels.html"), "/test//hotels.html")
  // 越具体越靠前
  assert_true(@path.compare_patterns("/hotels/chicago", "/hotels/*", "/**") < 0)
}
```

## 文件名六件（10-10 批①）

对位 `io.file.FileNameUtil` 的 **String 档**。四条期望值全部由参照腿 `scripts/FileNameLeg.java`
（含反射读 `SPECIAL_SUFFIX` 与非法字符正则）灌入，不是按"路径库应该怎样"写的。

```mbt check
///|
test "filename 四条会被写错的形状" {
  // 两种分隔符都认，且尾随分隔符先剥（参照不认宿主）
  assert_eq(@path.name_of("a\\b/c.txt"), "c.txt")
  assert_eq(@path.name_of("/tmp/"), "tmp")
  // 复合扩展名整段给主名跟着少两段；表里没有 `tar`，所以 `archive.tar` 退到最后一个点
  assert_eq(@path.ext_name("archive.tar.gz"), "tar.gz")
  assert_eq(@path.main_name("archive.tar.gz"), "archive")
  assert_eq(@path.ext_name("archive.tar"), "tar")
  // 点开头：主名是空串（照参照，不"顺手改成 bashrc"）
  assert_eq(@path.ext_name(".bashrc"), "bashrc")
  assert_eq(@path.main_name(".bashrc"), "")
  // 分隔符本身在非法字符集里 ⇒ clean 会把它删掉；is_type 的类型不带点、大小写不敏感
  assert_eq(@path.clean_invalid("/tmp/"), "tmp")
  assert_true(@path.contains_invalid("bad:name?.txt"))
  assert_true(@path.is_type("a.TXT", ["tar.gz", "txt"]))
  assert_false(@path.is_type("a.txt", [".txt"]))
  // 空类型串是个真值档：无扩展名的名字对 [""] 给 true
  assert_true(@path.is_type("noext", [""]))
}
```

## 本包不做的事

不做 `setCachePatterns` 那类全局模式缓存（要缓存请自己持有编译结果）；不支持 `{*path}` 捕获档——参照实现自己
`match` 恒假、`extract` 抛异常，本库同档判不支持；不收 Java 正则方言（`\d`、`\w` 等在 core 方言里编不出来）；
不做 Spring 的 `PathPatternParser` 那一族；也不做路径规范化（`..`/`.` 折叠属 `PathUtil`，要 IO 语义）。
