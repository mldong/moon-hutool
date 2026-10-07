///|
// path 比较器修复笔的逐对直读（10-08）——26 对全部由 `scripts/PathLeg3.java` 现读灌入
// （hutool-core 5.8.35 `AntPathMatcher.getPatternComparator(path)` · JDK 17.0.14），手打零条。
// 夹具形状是照参照 `AntPatternComparator` 源码里七级判定的每一条出口配的，
// 其中六对就是 `docs/spec/15-path.md` §7.1 表里登记的那六条分岔（本笔把它们从"登记"转成断言）。
// 参照对 `null` 模式给"最不具体"的两档，本库签名 `compare_patterns(String, String, String)` 不收可选值
// ⇒ 没有对位物，两档不进断言（写在这里而不是默默删掉）。

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
