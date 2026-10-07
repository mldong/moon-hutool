///|
// path 修复笔的逐对直读（10-08）——切分器段表 10 条、匹配/抽段 27 条、失败出口与组合/变量 18 条、
// 比较器 26 对，全部由 `scripts/PathLeg3.java` 现读灌入（hutool-core 5.8.35 · JDK 17.0.14），手打零条。
// 参照件全走公开面：`match` / `matchStart` / `extractPathWithinPattern` /
// `extractUriTemplateVariables` / `combine` / `getPatternComparator(path)`，
// 外加子类化 `AntPathMatcher` 把 protected 的 `tokenizePath` 拖出来逐串打印（T 行，根因证据见 spec §9）。
// M 行钉 §7.1 表里"尾随分隔符 4 + 抽段 1"那五条及受"丢空段"影响的邻档；C 行钉比较器那六条（§8）；
// N 行按 `do_match` 的失败出口配对；E 行的参照在 sep=空串 下**构造即抛**、没有对位行为 ⇒ 钉本库形状（§10）。
// 参照对 `null` 模式给"最不具体"的两档，本库签名 `compare_patterns(String, String, String)` 不收可选值
// ⇒ 没有对位物，两档不进断言（写在这里而不是默默删掉）。

///|
test "path 匹配直读 01" {
  // 参照 match(/a/*, /a/) ⇒ true
  assert_eq(@path.match_path("/a/*", "/a/"), true)
}

///|
test "path 匹配直读 02" {
  // 参照 matchStart(/a/*, /a/) ⇒ true
  assert_eq(
    @path.match_start_with("/a/*", "/a/", @path.default_options()),
    true,
  )
}

///|
test "path 匹配直读 03" {
  // 参照 matchStart(/a/?, /a/) ⇒ true
  assert_eq(
    @path.match_start_with("/a/?", "/a/", @path.default_options()),
    true,
  )
}

///|
test "path 匹配直读 04" {
  // 参照 matchStart(/abc/, /abc) ⇒ false
  assert_eq(
    @path.match_start_with("/abc/", "/abc", @path.default_options()),
    false,
  )
}

///|
test "path 匹配直读 05" {
  // 参照 extractPathWithinPattern(/**/x/, /a/x/) ⇒ a/x
  assert_eq(@path.extract_within("/**/x/", "/a/x/"), "a/x")
}

///|
test "path 匹配直读 06" {
  // 参照 match(/a/**, /a/) ⇒ true
  assert_eq(@path.match_path("/a/**", "/a/"), true)
}

///|
test "path 匹配直读 07" {
  // 参照 match(/a/, /a/) ⇒ true
  assert_eq(@path.match_path("/a/", "/a/"), true)
}

///|
test "path 匹配直读 08" {
  // 参照 match(/a/*, /a) ⇒ false
  assert_eq(@path.match_path("/a/*", "/a"), false)
}

///|
test "path 匹配直读 09" {
  // 参照 match(/*, /) ⇒ true
  assert_eq(@path.match_path("/*", "/"), true)
}

///|
test "path 匹配直读 10" {
  // 参照 match(/**, ) ⇒ false
  assert_eq(@path.match_path("/**", ""), false)
}

///|
test "path 匹配直读 11" {
  // 参照 match(, ) ⇒ true
  assert_eq(@path.match_path("", ""), true)
}

///|
test "path 匹配直读 12" {
  // 参照 match(/, ) ⇒ false
  assert_eq(@path.match_path("/", ""), false)
}

///|
test "path 匹配直读 13" {
  // 参照 match(/a//b, /a/b) ⇒ true
  assert_eq(@path.match_path("/a//b", "/a/b"), true)
}

///|
test "path 匹配直读 14" {
  // 参照 match(/a/b, /a//b) ⇒ true
  assert_eq(@path.match_path("/a/b", "/a//b"), true)
}

///|
test "path 匹配直读 15" {
  // 参照 match(/*/x, /a/x) ⇒ true
  assert_eq(@path.match_path("/*/x", "/a/x"), true)
}

///|
test "path 匹配直读 16" {
  // 参照 match(/{v}/x, /a/x) ⇒ true
  assert_eq(@path.match_path("/{v}/x", "/a/x"), true)
}

///|
test "path 匹配直读 17" {
  // 参照 extractPathWithinPattern(/WEB-INF/**, /WEB-INF/web.xml) ⇒ web.xml
  assert_eq(@path.extract_within("/WEB-INF/**", "/WEB-INF/web.xml"), "web.xml")
}

///|
test "path 匹配直读 18" {
  // 参照 extractPathWithinPattern(/**, /a/b) ⇒ a/b
  assert_eq(@path.extract_within("/**", "/a/b"), "a/b")
}

///|
test "path 匹配直读 19" {
  // 参照 extractPathWithinPattern(/a/b, /a/b) ⇒ 
  assert_eq(@path.extract_within("/a/b", "/a/b"), "")
}

///|
test "path 匹配直读 20" {
  // 参照 extractPathWithinPattern(/a/*, /a/b/c) ⇒ b/c
  assert_eq(@path.extract_within("/a/*", "/a/b/c"), "b/c")
}

///|
test "path 匹配直读 21" {
  // 参照 matchStart(/a/**, /a/b/c) ⇒ true
  assert_eq(
    @path.match_start_with("/a/**", "/a/b/c", @path.default_options()),
    true,
  )
}

///|
test "path 匹配直读 22" {
  // 参照 matchStart(/a/b, /a) ⇒ true
  assert_eq(@path.match_start_with("/a/b", "/a", @path.default_options()), true)
}

///|
test "path 匹配直读 23" {
  // 参照 match(?/x, a/x) ⇒ true
  assert_eq(@path.match_path("?/x", "a/x"), true)
}

///|
test "path 匹配直读 24" {
  // 参照 match(/ /x, / /x) ⇒ true
  assert_eq(@path.match_path("/ /x", "/ /x"), true)
}

///|
test "path 匹配直读 25" {
  // 参照 match(/a/ , /a/ ) ⇒ true
  assert_eq(@path.match_path("/a/ ", "/a/ "), true)
}

///|
test "path 匹配直读 26" {
  // 参照 match(/a//b, /a/ /b) ⇒ false
  assert_eq(@path.match_path("/a//b", "/a/ /b"), false)
}

///|
test "path 匹配直读 27" {
  // 参照 match(/a/**, /a/x) ⇒ true
  assert_eq(@path.match_path("/a/**", "/a/x"), true)
}

///|
fn p6_raise(f : () -> Unit raise @path.PathError) -> String {
  try {
    f()
    "未抛"
  } catch {
    @path.NoMatch(a, b) => "NoMatch " + a + "|" + b
    @path.CapturingVar(n) => "CapturingVar " + n
    @path.CaptureGroupRegex(s) => "CaptureGroupRegex " + s
    @path.ExtensionConflict(a, b) => "ExtensionConflict " + a + "|" + b
  }
}

///|
fn p6_vars(m : Map[String, String]) -> String {
  let keys : Array[String] = []
  for (k, _) in m {
    keys.push(k)
  }
  keys.sort()
  let mut out = ""
  for k in keys {
    let v = match m.get(k) {
      Some(x) => x
      None => ""
    }
    out = out + k + "=" + v + ";"
  }
  out
}

///|
test "path 出口直读 01" {
  // 参照 match(/a/{n:\d+}/b, /a/12/b) ⇒ true ｜钉本库形状（依据 15-path §10）
  assert_eq(@path.match_path("/a/{n:\\d+}/b", "/a/12/b"), false)
}

///|
test "path 出口直读 02" {
  // 参照 match(/a/**/z, /a/b/y) ⇒ false
  assert_eq(@path.match_path("/a/**/z", "/a/b/y"), false)
}

///|
test "path 出口直读 03" {
  // 参照 extractUriTemplateVariables(/a/**/{*p}, /a/b/c) ⇒ ERR:IllegalArgumentException（参照在这一档抛） ｜钉本库形状（依据 15-path §10）
  assert_eq(
    p6_raise(() => {
      let _ = @path.extract_variables("/a/**/{*p}", "/a/b/c")
    }),
    "CapturingVar *p",
  )
}

///|
test "path 出口直读 04" {
  // 参照 extractUriTemplateVariables(/{a}/x/{b}, /p/x/q) ⇒ a=p;b=q;
  assert_eq(
    p6_vars(@path.extract_variables("/{a}/x/{b}", "/p/x/q")),
    "a=p;b=q;",
  )
}

///|
test "path 出口直读 05" {
  // 参照 match(/x/**/a/**/y, /x/b/a/c/z) ⇒ false
  assert_eq(@path.match_path("/x/**/a/**/y", "/x/b/a/c/z"), false)
}

///|
test "path 出口直读 06" {
  // 参照 match(/a/**/b/**, /a/b) ⇒ true
  assert_eq(@path.match_path("/a/**/b/**", "/a/b"), true)
}

///|
test "path 出口直读 07" {
  // 参照 match(/**/a/**/b/**, /a/x/b) ⇒ true
  assert_eq(@path.match_path("/**/a/**/b/**", "/a/x/b"), true)
}

///|
test "path 出口直读 08" {
  // 参照 match(/a/**/b/c, /a/x/b) ⇒ false
  assert_eq(@path.match_path("/a/**/b/c", "/a/x/b"), false)
}

///|
test "path 出口直读 09" {
  // 参照 match(/a/**/*, /a/b/c) ⇒ true
  assert_eq(@path.match_path("/a/**/*", "/a/b/c"), true)
}

///|
test "path 出口直读 10" {
  // 参照 match(/**/**/a, /b/a) ⇒ true
  assert_eq(@path.match_path("/**/**/a", "/b/a"), true)
}

///|
test "path 出口直读 11" {
  // 参照 combine(a/{v}/x, y) ⇒ a/{v}/x/y
  assert_eq(@path.combine("a/{v}/x", "y"), "a/{v}/x/y")
}

///|
test "path 出口直读 12" {
  // 参照 combine(/a/*, /b) ⇒ /a/b
  assert_eq(@path.combine("/a/*", "/b"), "/a/b")
}

///|
test "path 出口直读 13" {
  // 参照 combine(/*.jsp, /x.txt) ⇒ ERR:IllegalArgumentException（参照在这一档抛） ｜钉本库形状（依据 15-path §10）
  assert_eq(
    p6_raise(() => {
      let _ = @path.combine("/*.jsp", "/x.txt")
    }),
    "ExtensionConflict /*.jsp|/x.txt",
  )
}

///|
test "path 出口直读 14" {
  // 参照 match(/a/**/q/**/z, /a/b/x/c/z) ⇒ false
  assert_eq(@path.match_path("/a/**/q/**/z", "/a/b/x/c/z"), false)
}

///|
test "path 出口直读 15" {
  // 参照 match(/a/**/x/y/**/z, /a/b/z) ⇒ false
  assert_eq(@path.match_path("/a/**/x/y/**/z", "/a/b/z"), false)
}

///|
test "path 出口直读 16" {
  // 参照 extractUriTemplateVariables(/**/{a(b)}/**, /p/q/r) ⇒ a(b)=p;
  assert_eq(
    p6_vars(@path.extract_variables("/**/{a(b)}/**", "/p/q/r")),
    "a(b)=p;",
  )
}

///|
test "path 出口直读 17" {
  // 参照 extractUriTemplateVariables(/x/**/{n:(a)(b)}/**/y, /x/p/q/y) ⇒ ERR:IllegalStateException（参照在这一档抛） ｜钉本库形状（依据 15-path §10）
  assert_eq(
    p6_raise(() => {
      let _ = @path.extract_variables("/x/**/{n:(a)(b)}/**/y", "/x/p/q/y")
    }),
    "CaptureGroupRegex {n:(a)(b)}",
  )
}

///|
test "path 出口直读 18" {
  // 参照 extractUriTemplateVariables(/**/{n:(a)(b)}/y, /p/q/y) ⇒ ERR:IllegalStateException（参照在这一档抛） ｜钉本库形状（依据 15-path §10）
  assert_eq(
    p6_raise(() => {
      let _ = @path.extract_variables("/**/{n:(a)(b)}/y", "/p/q/y")
    }),
    "CaptureGroupRegex {n:(a)(b)}",
  )
}

///|
test "path 出口直读 19" {
  // 参照 match(/a/**/b/**/c/d, /a/x/b/y) ⇒ false
  assert_eq(@path.match_path("/a/**/b/**/c/d", "/a/x/b/y"), false)
}

///|
test "path 出口直读 20" {
  // 参照 match(/a/**/x/y/**/z, /a/z) ⇒ false
  assert_eq(@path.match_path("/a/**/x/y/**/z", "/a/z"), false)
}

///|
test "path 出口直读 21" {
  // 参照 `new AntPathMatcher("")` 在这一档抛 ERR:IllegalArgumentException ⇒ sep=空串 无对位行为；本库这两档是防御档，钉本库形状（依据 15-path §10） ｜钉本库形状（依据 15-path §10）
  assert_eq(
    @path.match_path_with("/a/b", "/a/b", @path.PathOptions::{
      separator: "",
      case_sensitive: true,
      trim_tokens: false,
    }),
    true,
  )
}

///|
test "path 出口直读 22" {
  // 参照 `new AntPathMatcher("")` 在这一档抛 ERR:IllegalArgumentException ⇒ sep=空串 无对位行为；本库这两档是防御档，钉本库形状（依据 15-path §10） ｜钉本库形状（依据 15-path §10）
  assert_eq(
    @path.match_path_with("/a/b", "/ab", @path.PathOptions::{
      separator: "",
      case_sensitive: true,
      trim_tokens: false,
    }),
    false,
  )
}

///|
test "path 出口直读 23" {
  // 参照 `new AntPathMatcher("")` 在这一档抛 ERR:IllegalArgumentException ⇒ sep=空串 无对位行为；本库这两档是防御档，钉本库形状（依据 15-path §10） ｜钉本库形状（依据 15-path §10）
  assert_eq(
    @path.match_path_with("abc", "abc", @path.PathOptions::{
      separator: "",
      case_sensitive: true,
      trim_tokens: false,
    }),
    true,
  )
}

///|
test "path 出口直读 24" {
  // 参照 `new AntPathMatcher("")` 在这一档抛 ERR:IllegalArgumentException ⇒ sep=空串 无对位行为；本库这两档是防御档，钉本库形状（依据 15-path §10） ｜钉本库形状（依据 15-path §10）
  assert_eq(
    @path.match_path_with("/a/*", "/a/b", @path.PathOptions::{
      separator: "",
      case_sensitive: true,
      trim_tokens: false,
    }),
    true,
  )
}

///|
test "path 比较器直读 01" {
  // against=/x ｜ p1=/** ｜ p2=/** ｜ 参照=0
  assert_eq(@path.compare_patterns("/x", "/**", "/**"), 0)
}

///|
test "path 比较器直读 02" {
  // against=/x ｜ p1=/** ｜ p2=/a/* ｜ 参照=1
  assert_eq(@path.compare_patterns("/x", "/**", "/a/*"), 1)
}

///|
test "path 比较器直读 03" {
  // against=/x ｜ p1=/a/* ｜ p2=/** ｜ 参照=-1
  assert_eq(@path.compare_patterns("/x", "/a/*", "/**"), -1)
}

///|
test "path 比较器直读 04" {
  // against=/a/b ｜ p1=/a/b ｜ p2=/a/x ｜ 参照=-1
  assert_eq(@path.compare_patterns("/a/b", "/a/b", "/a/x"), -1)
}

///|
test "path 比较器直读 05" {
  // against=/a/b ｜ p1=/a/x ｜ p2=/a/b ｜ 参照=1
  assert_eq(@path.compare_patterns("/a/b", "/a/x", "/a/b"), 1)
}

///|
test "path 比较器直读 06" {
  // against=/a/b ｜ p1=/a/b ｜ p2=/a/b ｜ 参照=0
  assert_eq(@path.compare_patterns("/a/b", "/a/b", "/a/b"), 0)
}

///|
test "path 比较器直读 07" {
  // against=/a/b ｜ p1=/x/** ｜ p2=/y/** ｜ 参照=0
  assert_eq(@path.compare_patterns("/a/b", "/x/**", "/y/**"), 0)
}

///|
test "path 比较器直读 08" {
  // against=/a/b ｜ p1=/x/** ｜ p2=/a/* ｜ 参照=1
  assert_eq(@path.compare_patterns("/a/b", "/x/**", "/a/*"), 1)
}

///|
test "path 比较器直读 09" {
  // against=/a/b ｜ p1=/a/* ｜ p2=/x/** ｜ 参照=-1
  assert_eq(@path.compare_patterns("/a/b", "/a/*", "/x/**"), -1)
}

///|
test "path 比较器直读 10" {
  // against=/a/b ｜ p1=/**/b ｜ p2=/a/* ｜ 参照=1
  assert_eq(@path.compare_patterns("/a/b", "/**/b", "/a/*"), 1)
}

///|
test "path 比较器直读 11" {
  // against=/a/b ｜ p1=/**/b ｜ p2=/a/? ｜ 参照=2
  assert_eq(@path.compare_patterns("/a/b", "/**/b", "/a/?"), 2)
}

///|
test "path 比较器直读 12" {
  // against=/a/b ｜ p1=/**/b ｜ p2=a/* ｜ 参照=1
  assert_eq(@path.compare_patterns("/a/b", "/**/b", "a/*"), 1)
}

///|
test "path 比较器直读 13" {
  // against=/a/b ｜ p1=/a/* ｜ p2=/a/**/b ｜ 参照=-1
  assert_eq(@path.compare_patterns("/a/b", "/a/*", "/a/**/b"), -1)
}

///|
test "path 比较器直读 14" {
  // against=/a/b ｜ p1=/a/? ｜ p2=/a/**/b ｜ 参照=-2
  assert_eq(@path.compare_patterns("/a/b", "/a/?", "/a/**/b"), -2)
}

///|
test "path 比较器直读 15" {
  // against=/a/b ｜ p1=a/* ｜ p2=/a/**/b ｜ 参照=-1
  assert_eq(@path.compare_patterns("/a/b", "a/*", "/a/**/b"), -1)
}

///|
test "path 比较器直读 16" {
  // against=/a/b ｜ p1=/**/y ｜ p2=/*/*/b ｜ 参照=1
  assert_eq(@path.compare_patterns("/a/b", "/**/y", "/*/*/b"), 1)
}

///|
test "path 比较器直读 17" {
  // against=/a/b ｜ p1=/**/xy ｜ p2=/*/*/b ｜ 参照=-1
  assert_eq(@path.compare_patterns("/a/b", "/**/xy", "/*/*/b"), -1)
}

///|
test "path 比较器直读 18" {
  // against=/a/b ｜ p1=/*/*/b ｜ p2=/**/xy ｜ 参照=1
  assert_eq(@path.compare_patterns("/a/b", "/*/*/b", "/**/xy"), 1)
}

///|
test "path 比较器直读 19" {
  // against=/a/b ｜ p1=/{a}/{b} ｜ p2=/**b ｜ 参照=1
  assert_eq(@path.compare_patterns("/a/b", "/{a}/{b}", "/**b"), 1)
}

///|
test "path 比较器直读 20" {
  // against=/a/b ｜ p1=/**b ｜ p2=/{a}/{b} ｜ 参照=-1
  assert_eq(@path.compare_patterns("/a/b", "/**b", "/{a}/{b}"), -1)
}

///|
test "path 比较器直读 21" {
  // against=/a/b ｜ p1=a.* ｜ p2=/x/* ｜ 参照=-1
  assert_eq(@path.compare_patterns("/a/b", "a.*", "/x/*"), -1)
}

///|
test "path 比较器直读 22" {
  // against=/a/b ｜ p1=/x/* ｜ p2=a.* ｜ 参照=1
  assert_eq(@path.compare_patterns("/a/b", "/x/*", "a.*"), 1)
}

///|
test "path 比较器直读 23" {
  // against=/a/b ｜ p1=/a/* ｜ p2=/a/* ｜ 参照=0
  assert_eq(@path.compare_patterns("/a/b", "/a/*", "/a/*"), 0)
}

///|
test "path 比较器直读 24" {
  // against=/a/b ｜ p1=/* ｜ p2=/* ｜ 参照=0
  assert_eq(@path.compare_patterns("/a/b", "/*", "/*"), 0)
}

///|
test "path 比较器直读 25" {
  // against=/a/b ｜ p1=.*x ｜ p2=/x/* ｜ 参照=1
  assert_eq(@path.compare_patterns("/a/b", ".*x", "/x/*"), 1)
}

///|
test "path 比较器直读 26" {
  // against=/a/b ｜ p1=.* ｜ p2=/x/* ｜ 参照=-1
  assert_eq(@path.compare_patterns("/a/b", ".*", "/x/*"), -1)
}

///|
test "path 比较器直读 27" {
  // against=/a/b ｜ p1=/{a ｜ p2=/x/* ｜ 参照=1
  assert_eq(@path.compare_patterns("/a/b", "/{a", "/x/*"), 1)
}

///|
test "path 比较器直读 28" {
  // against=/a/b ｜ p1=/{a}x ｜ p2=/x/*y ｜ 参照=2
  assert_eq(@path.compare_patterns("/a/b", "/{a}x", "/x/*y"), 2)
}
