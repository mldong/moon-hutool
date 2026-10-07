///|
// path 两笔修复的逐对直读（10-08）——匹配/抽段 23 条 + 比较器 26 对，全部由 `scripts/PathLeg3.java` 现读灌入
// （hutool-core 5.8.35 `AntPathMatcher.getPatternComparator(path)` · JDK 17.0.14），手打零条。
// 夹具形状是照参照 `AntPatternComparator` 源码里七级判定的每一条出口配的，
// 前半（匹配直读）钉的是 §7.1 表里"尾随分隔符 4 + 抽段 1"那五条：根因是参照 `tokenizePath()` 丢空段
// （`splitToArray(..., ignoreEmpty=true)`，T 行逐串读数），本库原先保留空段，于是 `do_match:402`
// 那条"路径先耗尽 + 余一颗 `*` + 路径以分隔符收尾"的特判永远走不到。
// 后半（比较器直读）钉的是那六条：`getTotalCount()` 里双星要按两个计数等，见 §8。
// 十条分岔自此全部从"登记"转成断言。
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
