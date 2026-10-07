///|
// path 家族重建档（10-07）——取代 path_test.mbt 里 49 条恒绿死格（那些断言把参照期望值填进了
// pattern 实参位，且注释的 path= 列其实是模式串，原始 (模式, 路径) 对已不可恢复）。
// 期望值全部由 PathLeg3.java 按 hutool-all 5.8.37 现读灌入，手打零条；分岔条目按普查结果登记为注释。

///|
test "path 家族 both-mix" {
  // 参照读数 true ｜ pattern="/a/**/b" path="/a/b" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/a/**/b", "/a/b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/a/**/b" path="/a/b" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/a/**/b", "/a/b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 brace-open" {
  // 参照读数 false ｜ pattern="/{a" path="/x" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/{a", "/x", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // 参照读数 false ｜ pattern="/{a" path="/x" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/{a", "/x", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
}

///|
test "path 家族 case-off" {
  // 参照读数 true ｜ pattern="/ABC" path="/abc" sep="/" cs=False trim=True
  assert_eq(
    @path.match_path_with("/ABC", "/abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: false,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/ABC" path="/abc" sep="/" cs=False trim=True
  assert_eq(
    @path.match_start_with("/ABC", "/abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: false,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 case-off2" {
  // 参照读数 true ｜ pattern="/abc" path="/ABC" sep="/" cs=False trim=True
  assert_eq(
    @path.match_path_with("/abc", "/ABC", @path.PathOptions::{
      separator: "/",
      case_sensitive: false,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/abc" path="/ABC" sep="/" cs=False trim=True
  assert_eq(
    @path.match_start_with("/abc", "/ABC", @path.PathOptions::{
      separator: "/",
      case_sensitive: false,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 case-on" {
  // 参照读数 false ｜ pattern="/ABC" path="/abc" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/ABC", "/abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // 参照读数 false ｜ pattern="/ABC" path="/abc" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/ABC", "/abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
}

///|
test "path 家族 catchall-var" {
  // 参照读数 false ｜ pattern="/resources/{*path}" path="/resources/a/b/c" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/resources/{*path}", "/resources/a/b/c", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // 参照读数 false ｜ pattern="/resources/{*path}" path="/resources/a/b/c" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/resources/{*path}", "/resources/a/b/c", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
}

///|
test "path 家族 com-mid" {
  // 参照读数 true ｜ pattern="/com/**/test.jsp" path="/com/x/test.jsp" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/com/**/test.jsp", "/com/x/test.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/com/**/test.jsp" path="/com/x/test.jsp" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/com/**/test.jsp", "/com/x/test.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 deep-mid" {
  // 参照读数 true ｜ pattern="org/springframework/**/*.jsp" path="org/springframework/a/b/c.jsp" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with(
      "org/springframework/**/*.jsp",
      "org/springframework/a/b/c.jsp",
      @path.PathOptions::{
        separator: "/",
        case_sensitive: true,
        trim_tokens: true,
      },
    ),
    true,
  )
  // 参照读数 true ｜ pattern="org/springframework/**/*.jsp" path="org/springframework/a/b/c.jsp" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with(
      "org/springframework/**/*.jsp",
      "org/springframework/a/b/c.jsp",
      @path.PathOptions::{
        separator: "/",
        case_sensitive: true,
        trim_tokens: true,
      },
    ),
    true,
  )
}

///|
test "path 家族 double-slash" {
  // 参照读数 true ｜ pattern="/a//b" path="/a//b" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/a//b", "/a//b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/a//b" path="/a//b" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/a//b", "/a//b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 dstar-all" {
  // 参照读数 true ｜ pattern="/**" path="/a/b" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/**", "/a/b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/**" path="/a/b" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/**", "/a/b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 dstar-jsp" {
  // 参照读数 true ｜ pattern="/**/test.jsp" path="/com/x/test.jsp" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/**/test.jsp", "/com/x/test.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/**/test.jsp" path="/com/x/test.jsp" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/**/test.jsp", "/com/x/test.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 dstar-web" {
  // 参照读数 true ｜ pattern="/WEB-INF/**" path="/WEB-INF/web.xml" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/WEB-INF/**", "/WEB-INF/web.xml", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/WEB-INF/**" path="/WEB-INF/web.xml" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/WEB-INF/**", "/WEB-INF/web.xml", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 empty-pat" {
  // 参照读数 false ｜ pattern="" path="/abc" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("", "/abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // 参照读数 false ｜ pattern="" path="/abc" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("", "/abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
}

///|
test "path 家族 empty-path" {
  // 参照读数 false ｜ pattern="/abc" path="" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/abc", "", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // 参照读数 false ｜ pattern="/abc" path="" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/abc", "", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
}

///|
test "path 家族 exact-hit" {
  // 参照读数 true ｜ pattern="/abc/def" path="/abc/def" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/abc/def", "/abc/def", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/abc/def" path="/abc/def" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/abc/def", "/abc/def", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 exact-miss" {
  // 参照读数 false ｜ pattern="/abc/def" path="/abc/xyz" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/abc/def", "/abc/xyz", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // 参照读数 false ｜ pattern="/abc/def" path="/abc/xyz" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/abc/def", "/abc/xyz", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
}

///|
test "path 家族 multi-two" {
  // 参照读数 true ｜ pattern="/{a}/x/{b}" path="/1/x/2" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/{a}/x/{b}", "/1/x/2", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/{a}/x/{b}" path="/1/x/2" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/{a}/x/{b}", "/1/x/2", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 no-lead" {
  // 参照读数 false ｜ pattern="abc/def" path="/abc/def" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("abc/def", "/abc/def", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // 参照读数 false ｜ pattern="abc/def" path="/abc/def" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("abc/def", "/abc/def", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
}

///|
test "path 家族 no-lead2" {
  // 参照读数 true ｜ pattern="abc/def" path="abc/def" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("abc/def", "abc/def", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="abc/def" path="abc/def" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("abc/def", "abc/def", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 q-slash-one" {
  // 参照读数 true ｜ pattern="/?/cde" path="/a/cde" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/?/cde", "/a/cde", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/?/cde" path="/a/cde" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/?/cde", "/a/cde", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 q-two" {
  // 参照读数 true ｜ pattern="/?" path="/a" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/?", "/a", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/?" path="/a" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/?", "/a", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 q-two-ab" {
  // 参照读数 false ｜ pattern="/?" path="/ab" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/?", "/ab", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // 参照读数 false ｜ pattern="/?" path="/ab" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/?", "/ab", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
}

///|
test "path 家族 regex-name" {
  // 参照读数 true ｜ pattern="/{name:[a-z]+}" path="/spring" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/{name:[a-z]+}", "/spring", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/{name:[a-z]+}" path="/spring" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/{name:[a-z]+}", "/spring", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 regex-num" {
  // 参照读数 true ｜ pattern="/{n:[0-9]+}" path="/123" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/{n:[0-9]+}", "/123", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/{n:[0-9]+}" path="/123" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/{n:[0-9]+}", "/123", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 regex-pair" {
  // 参照读数 true ｜ pattern="/{n:(a)(b)}/x" path="/ab/x" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/{n:(a)(b)}/x", "/ab/x", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/{n:(a)(b)}/x" path="/ab/x" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/{n:(a)(b)}/x", "/ab/x", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 sep-colon" {
  // 参照读数 true ｜ pattern="a:*:c" path="a:b:c" sep=":" cs=True trim=True
  assert_eq(
    @path.match_path_with("a:*:c", "a:b:c", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="a:*:c" path="a:b:c" sep=":" cs=True trim=True
  assert_eq(
    @path.match_start_with("a:*:c", "a:b:c", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 sep-colon-dstar" {
  // 参照读数 true ｜ pattern="a:**:c" path="a:b:c" sep=":" cs=True trim=True
  assert_eq(
    @path.match_path_with("a:**:c", "a:b:c", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="a:**:c" path="a:b:c" sep=":" cs=True trim=True
  assert_eq(
    @path.match_start_with("a:**:c", "a:b:c", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 sep-colon-mix" {
  // 参照读数 true ｜ pattern="a:**/c" path="a:b/c" sep=":" cs=True trim=True
  assert_eq(
    @path.match_path_with("a:**/c", "a:b/c", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="a:**/c" path="a:b/c" sep=":" cs=True trim=True
  assert_eq(
    @path.match_start_with("a:**/c", "a:b/c", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 sep-colon-plain" {
  // 参照读数 true ｜ pattern="a:b" path="a:b" sep=":" cs=True trim=True
  assert_eq(
    @path.match_path_with("a:b", "a:b", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="a:b" path="a:b" sep=":" cs=True trim=True
  assert_eq(
    @path.match_start_with("a:b", "a:b", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 sep-slash-colon" {
  // 参照读数 true ｜ pattern="/a:b" path="/a:b" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/a:b", "/a:b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/a:b" path="/a:b" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/a:b", "/a:b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 star-dir" {
  // 参照读数 true ｜ pattern="/WEB-INF/*.jsp" path="/WEB-INF/a.jsp" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/WEB-INF/*.jsp", "/WEB-INF/a.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/WEB-INF/*.jsp" path="/WEB-INF/a.jsp" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/WEB-INF/*.jsp", "/WEB-INF/a.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 star-jsp" {
  // 参照读数 true ｜ pattern="/*.jsp" path="/index.jsp" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/*.jsp", "/index.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/*.jsp" path="/index.jsp" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/*.jsp", "/index.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 star-lead-tail" {
  // 参照读数 true ｜ pattern="/*/x" path="/a/x" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/*/x", "/a/x", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/*/x" path="/a/x" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/*/x", "/a/x", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 start-com" {
  // 参照读数 false ｜ pattern="/com/*" path="/com/a/b" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/com/*", "/com/a/b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // 参照读数 false ｜ pattern="/com/*" path="/com/a/b" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/com/*", "/com/a/b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
}

///|
test "path 家族 start-star" {
  // 参照读数 false ｜ pattern="/WEB-INF/*" path="/WEB-INF/a/b" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/WEB-INF/*", "/WEB-INF/a/b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // 参照读数 false ｜ pattern="/WEB-INF/*" path="/WEB-INF/a/b" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/WEB-INF/*", "/WEB-INF/a/b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
}

///|
test "path 家族 trailing-pat" {
  // 参照读数 false ｜ pattern="/abc/" path="/abc" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/abc/", "/abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // 分岔登记（参照=false / 本库=true）：见 docs/spec/15-path.md §7.1/§7.3，本笔不钉
}

///|
test "path 家族 trim-off" {
  // 参照读数 true ｜ pattern="/ abc" path="/ abc" sep="/" cs=True trim=False
  assert_eq(
    @path.match_path_with("/ abc", "/ abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: false,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/ abc" path="/ abc" sep="/" cs=True trim=False
  assert_eq(
    @path.match_start_with("/ abc", "/ abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: false,
    }),
    true,
  )
}

///|
test "path 家族 trim-on" {
  // 参照读数 true ｜ pattern="/ abc" path="/abc" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/ abc", "/abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/ abc" path="/abc" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/ abc", "/abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}

///|
test "path 家族 var-two" {
  // 参照读数 true ｜ pattern="/{a}{b}" path="/xy" sep="/" cs=True trim=True
  assert_eq(
    @path.match_path_with("/{a}{b}", "/xy", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
  // 参照读数 true ｜ pattern="/{a}{b}" path="/xy" sep="/" cs=True trim=True
  assert_eq(
    @path.match_start_with("/{a}{b}", "/xy", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    true,
  )
}
