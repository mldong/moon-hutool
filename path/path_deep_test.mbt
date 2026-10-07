///|
// path 深分支补档（10-07）——期望形状全部由 scripts 之外的一次性腿 PathLeg2.java 灌入，手打零条。
// 判据分层：`match`/`matchStart` 两族钉的是**参照在默认与自定义开关下的同一对输入**；
// `extractWithin` 钉的是抽段结果（参照的空串档本库原样保留）。
// 注意：本文件**不改** `path_test.mbt` 的任何已冻期望；那 49 条把参照期望值写进 pattern 实参位
// 的死格另笔处理（见 docs/spec/15-path.md 末节），本笔只补真档并让 G17 拦住这种形状。

///|
test "path 深分支 match：可选组、trim 档、`**` 中段与端点、尾随分隔符（腿 16 对）" {
  // C1.trim-sep：match 参照读数 = true
  assert_eq(@path.match_path_with("/a b/*", "/a b/c", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: true }), true)
  // C2.trim-var：match 参照读数 = true
  assert_eq(@path.match_path_with("/{v}/x", "/ y /x", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: true }), true)
  // C3.trim-false：match 参照读数 = true
  assert_eq(@path.match_path_with("/{v}/x", "/ y /x", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // D1.ci：match 参照读数 = true
  assert_eq(@path.match_path_with("/A/*", "/a/b", @path.PathOptions::{ separator: "/", case_sensitive: false, trim_tokens: false }), true)
  // E1.suffix-dots：match 参照读数 = true
  assert_eq(@path.match_path_with("/**/x", "/a/b/c/x", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // E2.mid-star-multi：match 参照读数 = true
  assert_eq(@path.match_path_with("/a/**/b/**/c", "/a/1/2/b/3/c", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // E3.mid-star-zero：match 参照读数 = true
  assert_eq(@path.match_path_with("/a/**/b", "/a/b", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // E4.star-then-star：match 参照读数 = true
  assert_eq(@path.match_path_with("/**/**", "/a/b", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // E5.lead-dots-trail：match 参照读数 = true
  assert_eq(@path.match_path_with("/**/x/", "/a/x/", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // F1.star-trailing-sep：分岔登记（参照=true / 本库=false），见 spec 末节，本笔不钉
  // F2.qm-trailing-sep：match 参照读数 = false
  assert_eq(@path.match_path_with("/a/?", "/a/", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), false)
  // F3.star-nosep：match 参照读数 = false
  assert_eq(@path.match_path_with("/a/*", "/a", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), false)
  // H1.regex-colon：match 参照读数 = true
  assert_eq(@path.match_path_with("/{v:[a-z]+}/x", "/abc/x", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // H2.regex-miss：match 参照读数 = false
  assert_eq(@path.match_path_with("/{v:[a-z]+}/x", "/123/x", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), false)
  // I1.no-var：match 参照读数 = true
  assert_eq(@path.match_path_with("/a/*/c", "/a/b/c", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // I2.root-pattern：match 参照读数 = true
  assert_eq(@path.match_path_with("/", "/", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
}

///|
test "path 深分支 matchStart：同一批输入走 matchStart 那条路（腿 16 对）" {
  // C1.trim-sep：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/a b/*", "/a b/c", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: true }), true)
  // C2.trim-var：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/{v}/x", "/ y /x", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: true }), true)
  // C3.trim-false：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/{v}/x", "/ y /x", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // D1.ci：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/A/*", "/a/b", @path.PathOptions::{ separator: "/", case_sensitive: false, trim_tokens: false }), true)
  // E1.suffix-dots：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/**/x", "/a/b/c/x", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // E2.mid-star-multi：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/a/**/b/**/c", "/a/1/2/b/3/c", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // E3.mid-star-zero：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/a/**/b", "/a/b", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // E4.star-then-star：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/**/**", "/a/b", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // E5.lead-dots-trail：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/**/x/", "/a/x/", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // F1.star-trailing-sep：分岔登记（参照=true / 本库=false），见 spec 末节，本笔不钉
  // F2.qm-trailing-sep：分岔登记（参照=true / 本库=false），见 spec 末节，本笔不钉
  // F3.star-nosep：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/a/*", "/a", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // H1.regex-colon：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/{v:[a-z]+}/x", "/abc/x", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // H2.regex-miss：matchStart 参照读数 = false
  assert_eq(@path.match_start_with("/{v:[a-z]+}/x", "/123/x", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), false)
  // I1.no-var：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/a/*/c", "/a/b/c", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
  // I2.root-pattern：matchStart 参照读数 = true
  assert_eq(@path.match_start_with("/", "/", @path.PathOptions::{ separator: "/", case_sensitive: true, trim_tokens: false }), true)
}

///|
test "path 深分支 extract_within：抽段结果（参照给空串的档照搬）" {
  // C1.trim-sep：extractPathWithinPattern 参照读数 = 'c'
  assert_eq(@path.extract_within("/a b/*", "/a b/c"), "c")
  // C2.trim-var：extractPathWithinPattern 参照读数 = ''
  assert_eq(@path.extract_within("/{v}/x", "/ y /x"), "")
  // C3.trim-false：extractPathWithinPattern 参照读数 = ''
  assert_eq(@path.extract_within("/{v}/x", "/ y /x"), "")
  // D1.ci：extractPathWithinPattern 参照读数 = 'b'
  assert_eq(@path.extract_within("/A/*", "/a/b"), "b")
  // E1.suffix-dots：extractPathWithinPattern 参照读数 = 'a/b/c/x'
  assert_eq(@path.extract_within("/**/x", "/a/b/c/x"), "a/b/c/x")
  // E2.mid-star-multi：extractPathWithinPattern 参照读数 = '1/2/b/3/c'
  assert_eq(@path.extract_within("/a/**/b/**/c", "/a/1/2/b/3/c"), "1/2/b/3/c")
  // E3.mid-star-zero：extractPathWithinPattern 参照读数 = 'b'
  assert_eq(@path.extract_within("/a/**/b", "/a/b"), "b")
  // E4.star-then-star：extractPathWithinPattern 参照读数 = 'a/b'
  assert_eq(@path.extract_within("/**/**", "/a/b"), "a/b")
  // E5.lead-dots-trail：分岔登记（参照='"a/x"' / 本库='"a/x/"'），见 spec 末节，本笔不钉
  // F1.star-trailing-sep：extractPathWithinPattern 参照读数 = ''
  assert_eq(@path.extract_within("/a/*", "/a/"), "")
  // F2.qm-trailing-sep：extractPathWithinPattern 参照读数 = ''
  assert_eq(@path.extract_within("/a/?", "/a/"), "")
  // F3.star-nosep：extractPathWithinPattern 参照读数 = ''
  assert_eq(@path.extract_within("/a/*", "/a"), "")
  // H1.regex-colon：extractPathWithinPattern 参照读数 = ''
  assert_eq(@path.extract_within("/{v:[a-z]+}/x", "/abc/x"), "")
  // H2.regex-miss：extractPathWithinPattern 参照读数 = ''
  assert_eq(@path.extract_within("/{v:[a-z]+}/x", "/123/x"), "")
  // I1.no-var：extractPathWithinPattern 参照读数 = 'b/c'
  assert_eq(@path.extract_within("/a/*/c", "/a/b/c"), "b/c")
  // I2.root-pattern：extractPathWithinPattern 参照读数 = ''
  assert_eq(@path.extract_within("/", "/"), "")
}

///|
test "path is_pattern 端点档：裸 `**`、单 `?`、空串、带冒号的段" {
  // is_pattern(/a/*) 参照读数 = true
  assert_eq(@path.is_pattern("/a/*"), true)
  // is_pattern(a?) 参照读数 = true
  assert_eq(@path.is_pattern("a?"), true)
  // is_pattern(/) 参照读数 = false
  assert_eq(@path.is_pattern("/"), false)
  // is_pattern() 参照读数 = false
  assert_eq(@path.is_pattern(""), false)
}

///|
test "path combine 四档：一空一非空、两侧都带分隔符、两侧同前缀" {
  // combine(/a/*, b/*) 参照读数 = '/a/b/*'
  assert_eq(@path.combine("/a/*", "b/*"), "/a/b/*")
  // combine(/a/, /b) 参照读数 = '/a/b'
  assert_eq(@path.combine("/a/", "/b"), "/a/b")
  // combine(/a, /b) 参照读数 = '/a/b'
  assert_eq(@path.combine("/a", "/b"), "/a/b")
  // combine(, /a) 参照读数 = '/a'
  assert_eq(@path.combine("", "/a"), "/a")
  // combine(/a/*, ) 参照读数 = '/a/*'
  assert_eq(@path.combine("/a/*", ""), "/a/*")
}

///|
test "path 比较器逐对直读：7 枚模式两两配对（并列档给 0，反推会造出不存在的严格序）" {
  // compare_patterns(/a/b, /a/**, /**/b) 参照读数 = 0
  assert_eq(@path.compare_patterns("/a/b", "/a/**", "/**/b"), 0)
  // compare_patterns(/a/b, /a/**, /a/*) 参照读数 = 1
  assert_eq(@path.compare_patterns("/a/b", "/a/**", "/a/*"), 1)
  // compare_patterns(/a/b, /a/**, /a/?) 参照读数 = 1
  assert_eq(@path.compare_patterns("/a/b", "/a/**", "/a/?"), 1)
  // compare_patterns(/a/b, /a/**, a/*) 参照读数 = 1
  assert_eq(@path.compare_patterns("/a/b", "/a/**", "a/*"), 1)
  // compare_patterns(/a/b, /a/**, /a/**/b) 参照读数 = 2
  assert_eq(@path.compare_patterns("/a/b", "/a/**", "/a/**/b"), 2)
  // compare_patterns(/a/b, /a/**, /**) 参照读数 = -1
  assert_eq(@path.compare_patterns("/a/b", "/a/**", "/**"), -1)
  // 分岔登记：compare_patterns(/a/b, /**/b, /a/*) 参照=1 / 本库=-1，见 spec 末节
  // 分岔登记：compare_patterns(/a/b, /**/b, /a/?) 参照=2 / 本库=1，见 spec 末节
  // 分岔登记：compare_patterns(/a/b, /**/b, a/*) 参照=1 / 本库=-2，见 spec 末节
  // compare_patterns(/a/b, /**/b, /a/**/b) 参照读数 = 2
  assert_eq(@path.compare_patterns("/a/b", "/**/b", "/a/**/b"), 2)
  // compare_patterns(/a/b, /**/b, /**) 参照读数 = -1
  assert_eq(@path.compare_patterns("/a/b", "/**/b", "/**"), -1)
  // compare_patterns(/a/b, /a/*, /a/?) 参照读数 = 1
  assert_eq(@path.compare_patterns("/a/b", "/a/*", "/a/?"), 1)
  // compare_patterns(/a/b, /a/*, a/*) 参照读数 = -1
  assert_eq(@path.compare_patterns("/a/b", "/a/*", "a/*"), -1)
  // 分岔登记：compare_patterns(/a/b, /a/*, /a/**/b) 参照=-1 / 本库=3，见 spec 末节
  // compare_patterns(/a/b, /a/*, /**) 参照读数 = -1
  assert_eq(@path.compare_patterns("/a/b", "/a/*", "/**"), -1)
  // compare_patterns(/a/b, /a/?, a/*) 参照读数 = -1
  assert_eq(@path.compare_patterns("/a/b", "/a/?", "a/*"), -1)
  // 分岔登记：compare_patterns(/a/b, /a/?, /a/**/b) 参照=-2 / 本库=-1，见 spec 末节
  // compare_patterns(/a/b, /a/?, /**) 参照读数 = -1
  assert_eq(@path.compare_patterns("/a/b", "/a/?", "/**"), -1)
  // 分岔登记：compare_patterns(/a/b, a/*, /a/**/b) 参照=-1 / 本库=4，见 spec 末节
  // compare_patterns(/a/b, a/*, /**) 参照读数 = -1
  assert_eq(@path.compare_patterns("/a/b", "a/*", "/**"), -1)
  // compare_patterns(/a/b, /a/**/b, /**) 参照读数 = -1
  assert_eq(@path.compare_patterns("/a/b", "/a/**/b", "/**"), -1)
}

