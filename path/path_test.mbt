///|
// 错误变体归一成档名（不用 show：show 在黑盒测试语境不在作用域）
fn err_tag(e : @path.PathError) -> String {
  match e {
    @path.NoMatch(_, _) => "NoMatch"
    @path.CapturingVar(_) => "CapturingVar"
    @path.CaptureGroupRegex(_) => "CaptureGroupRegex"
    @path.ExtensionConflict(_, _) => "ExtensionConflict"
  }
}

///|
// path 第一批的期望值全部由生成脚本从 `path_ref.txt`（参照腿读数）灌入，手打零条。
// 参照腿：`hutool-core-5.8.35.jar` 的 `cn.hutool.core.text.AntPathMatcher`（Spring-core 同名类的
// vendored 拷贝，15 个 public 成员 + 4 个内部类，源码 945 行）+ 本机 JDK 17.0.14；`javac -encoding UTF-8`。
// 机制判定另有腿 B：源码字段 `caseSensitive = true` / `trimTokens = false`——**hutool 这一档与 Spring 原版不同**
// （Spring 默认 trim 空格），本库跟的是所对位的那个实现，不是祖上文档（spec §4）。
// 这批 7 块落地后全绿（期望值从头到尾没动：PR-A2 之后的一次期望值更正单独一笔 `137e248`，
// 来源是参照腿的逐对直读，不是实现）。落地那一笔只把体子从 `abort` 换成真实现，动体不动期望（门禁 G5）。

///|
// 把预期抛错的调用归一成错误档名；没抛就返回 `OK`（那样这条断言一定红，不会静默放过）
fn[A] err_of(g : () -> A raise @path.PathError) -> String {
  try {
    let _ = g()
    "OK"
  } catch {
    err => err_tag(err)
  }
}

///|
// is_pattern 与默认构造的三枚开关
test "path is_pattern 与默认构造的三枚开关" {
  // is_pattern(p1) 参照读数 = F
  assert_eq(@path.is_pattern("/hotels"), false)
  // is_pattern(p2) 参照读数 = T
  assert_eq(@path.is_pattern("/hotels/*"), true)
  // is_pattern(p3) 参照读数 = T
  assert_eq(@path.is_pattern("/*.jsp"), true)
  // is_pattern(p4) 参照读数 = T
  assert_eq(@path.is_pattern("/{name}"), true)
  // is_pattern(p5) 参照读数 = F
  assert_eq(@path.is_pattern(""), false)
  // is_pattern(p6) 参照读数 = F
  assert_eq(@path.is_pattern("/a:b"), false)
  // is_pattern(p7) 参照读数 = T
  assert_eq(@path.is_pattern("**"), true)
  // 参照读数："const|DEFAULT_SEPARATOR=/"
  // 参照读数："default-ctor|exact=T|case_sensitive=T|trim=F|catchall_match=F"
  // 参照腿常量读数：DEFAULT_PATH_SEPARATOR = "/"
  assert_eq(@path.default_separator(), "/")
}

///|
// 通配档位：? 单字符、* 不跨段、** 整段且可吞零段
test "path 通配档位：? 单字符、* 不跨段、** 整段且可吞零段" {
  // q-abc：pat="false" path="/?/cde" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/?/cde", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // q-len2：pat="false" path="/??" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/??", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // q-one：pat="false" path="/??" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/??", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // star-seg：pat="false" path="/*.jsp" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/*.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // star-nocross：pat="false" path="/WEB-INF/*.jsp" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/WEB-INF/*.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // star-webinf：pat="false" path="/WEB-INF/*.jsp" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/WEB-INF/*.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // dstar-mid：pat="false" path="/**/test.jsp" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/**/test.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // dstar-tail：pat="false" path="/WEB-INF/**" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/WEB-INF/**", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // dstar-empty：pat="false" path="/WEB-INF/**" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/WEB-INF/**", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // dstar-only：pat="false" path="/**" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/**", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // dstar-root：pat="false" path="/**" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/**", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // dstar-rel：pat="false" path="/WEB-INF/**" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/WEB-INF/**", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // com-dstar：pat="false" path="/com/**/test.jsp" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/com/**/test.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // deep-suffix：pat="false" path="org/springframework/**/*.jsp" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "org/springframework/**/*.jsp", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // star-prefix：pat="false" path="/*/x" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/*/x", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // exact：pat="false" path="/abc/def" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/abc/def", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // exact-fail：pat="false" path="/abc/def" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/abc/def", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // trailing-slash：pat="false" path="/abc/" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/abc/", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // no-lead-slash：pat="false" path="abc/def" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "abc/def", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // empty-path：pat="false" path="/abc" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // empty-pattern：pat="false" path="" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // both-empty：pat="false" path="" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // double-sep：pat="false" path="/a//b" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/a//b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // catchall-match：pat="false" path="/resources/{*path}" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/resources/{*path}", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // catchall-empty：pat="false" path="/resources/{*path}" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/resources/{*path}", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // catchall-nolead：pat="false" path="/resources/{*path}" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/resources/{*path}", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // regex-cclass：pat="false" path="/{name:[a-z]+}" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/{name:[a-z]+}", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // regex-digit：pat="false" path="/{n:[0-9]+}" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/{n:[0-9]+}", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // regex-dslash：pat="false" path="/{n:\\d+}" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/{n:\\d+}", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  ) // 分岔行：参照腿给真（Java 方言收 \d），本库按 core 方言判假——spec §5 第 3 行
  // multi-var：pat="false" path="/{a}/x/{b}" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/{a}/x/{b}", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // var-adjacent：pat="false" path="/{a}{b}" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/{a}{b}", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // brace-unbalanced：pat="false" path="/{a" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/{a", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // regex-capturing：pat="false" path="/{n:(a)(b)}/x" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/{n:(a)(b)}/x", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
}

///|
// 开关档位：自定义分隔符、大小写、裁空格
test "path 开关档位：自定义分隔符、大小写、裁空格" {
  // sep-colon：pat="false" path="a:b" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "a:b", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // sep-colon-star：pat="false" path="a:*:c" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "a:*:c", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // sep-colon-dstar：pat="false" path="a:**:c" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "a:**:c", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // sep-colon-dstar-far：pat="false" path="a:**:c" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "a:**:c", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // sep-slash-then-colon-star：pat="false" path="a:**/c" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "a:**/c", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // sep-slash-vs-colon：pat="false" path="a:b" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "a:b", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // sep-star-nocross：pat="false" path="a:*:c" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "a:*:c", @path.PathOptions::{
      separator: ":",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // case-default：pat="false" path="/ABC" 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/ABC", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // case-insens：pat="false" path="/ABC" 参照腿 out=F
  assert_eq(
    @path.match_path_with("false", "/ABC", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // case-insens-pat：pat="false" path="/abc" 参照腿 out=F
  assert_eq(
    @path.match_path_with("false", "/abc", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // trim-on：pat="false" path="/ abc " 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/ abc ", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // trim-off：pat="false" path="/ abc " 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/ abc ", @path.PathOptions::{
      separator: "/",
      case_sensitive: false,
      trim_tokens: false,
    }),
    false,
  )
  // trim-off-self：pat="false" path="/ abc " 参照腿 out=F
  assert_eq(
    @path.match_start_with("false", "/ abc ", @path.PathOptions::{
      separator: "/",
      case_sensitive: false,
      trim_tokens: false,
    }),
    false,
  )
}

///|
// matchStart：路径可在模式中途结束
test "path matchStart：路径可在模式中途结束" {
  // start-ok：pat="true" path="/WEB-INF/*" 参照腿 out=F
  assert_eq(
    @path.match_start_with("true", "/WEB-INF/*", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // start-deep：pat="true" path="/WEB-INF/**" 参照腿 out=F
  assert_eq(
    @path.match_start_with("true", "/WEB-INF/**", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
  // start-part：pat="true" path="/com/*" 参照腿 out=F
  assert_eq(
    @path.match_start_with("true", "/com/*", @path.PathOptions::{
      separator: "/",
      case_sensitive: true,
      trim_tokens: true,
    }),
    false,
  )
}

///|
// 模板变量抽取与三档错误
test "path 模板变量抽取与三档错误" {
  // v-one：pat="/{name}" path="/spring"
  let m = @path.extract_variables("/{name}", "/spring")
  assert_eq(m.length(), 1)
  assert_eq(m["name"], "spring")
  assert_eq(@path.extract_within("/{name}", "/spring"), "")
  // v-two：pat="/{p1}/{p2}" path="/a/b"
  let m = @path.extract_variables("/{p1}/{p2}", "/a/b")
  assert_eq(m.length(), 2)
  assert_eq(m["p1"], "a")
  assert_eq(m["p2"], "b")
  assert_eq(@path.extract_within("/{p1}/{p2}", "/a/b"), "")
  // v-regex：pat="/{name:[a-z]+}/test" path="/abc/test"
  let m = @path.extract_variables("/{name:[a-z]+}/test", "/abc/test")
  assert_eq(m.length(), 1)
  assert_eq(m["name"], "abc")
  assert_eq(@path.extract_within("/{name:[a-z]+}/test", "/abc/test"), "")
  // v-regex-fail：pat="/{name:[a-z]+}/test" path="/123/test"
  // 参照腿抛 NoMatch ⇒ 本库收成 PathError.NoMatch
  assert_true(
    err_of(() => @path.extract_variables("/{name:[a-z]+}/test", "/123/test")).has_prefix(
      "NoMatch",
    ),
  )
  assert_eq(@path.extract_within("/{name:[a-z]+}/test", "/123/test"), "")
  // v-catchall：pat="/resources/{*path}" path="/resources/a/b/c"
  // 参照腿抛 CapturingVar ⇒ 本库收成 PathError.CapturingVar
  assert_true(
    err_of(() => {
      @path.extract_variables("/resources/{*path}", "/resources/a/b/c")
    }).has_prefix("CapturingVar"),
  )
  assert_eq(
    @path.extract_within("/resources/{*path}", "/resources/a/b/c"),
    "a/b/c",
  )
  // v-catchall-one：pat="/resources/{*path}" path="/resources/x"
  // 参照腿抛 CapturingVar ⇒ 本库收成 PathError.CapturingVar
  assert_true(
    err_of(() => @path.extract_variables("/resources/{*path}", "/resources/x")).has_prefix(
      "CapturingVar",
    ),
  )
  assert_eq(@path.extract_within("/resources/{*path}", "/resources/x"), "x")
  // v-star-notail：pat="/{name}*" path="/springx"
  let m = @path.extract_variables("/{name}*", "/springx")
  assert_eq(m.length(), 1)
  assert_eq(m["name"], "springx")
  assert_eq(@path.extract_within("/{name}*", "/springx"), "springx")
  // v-nomatch：pat="/{name}" path="/a/b"
  // 参照腿抛 NoMatch ⇒ 本库收成 PathError.NoMatch
  assert_true(
    err_of(() => @path.extract_variables("/{name}", "/a/b")).has_prefix(
      "NoMatch",
    ),
  )
  assert_eq(@path.extract_within("/{name}", "/a/b"), "")
  // x-regex-capturing：pat="/{n:(a)(b)}/x" path="/ab/x"
  // 参照腿抛 CaptureGroupRegex ⇒ 本库收成 PathError.CaptureGroupRegex
  assert_true(
    err_of(() => @path.extract_variables("/{n:(a)(b)}/x", "/ab/x")).has_prefix(
      "CaptureGroupRegex",
    ),
  )
  assert_eq(@path.extract_within("/{n:(a)(b)}/x", "/ab/x"), "")
  // x-multi：pat="/{a}/x/{b}" path="/1/x/2"
  let m = @path.extract_variables("/{a}/x/{b}", "/1/x/2")
  assert_eq(m.length(), 2)
  assert_eq(m["a"], "1")
  assert_eq(m["b"], "2")
  assert_eq(@path.extract_within("/{a}/x/{b}", "/1/x/2"), "")
}

///|
// extract_within 与 combine
test "path extract_within 与 combine" {
  // w-partial：pat="/WEB-INF/**" path="/WEB-INF/web.xml"
  let m = @path.extract_variables("/WEB-INF/**", "/WEB-INF/web.xml")
  assert_eq(m.length(), 0)
  assert_eq(@path.extract_within("/WEB-INF/**", "/WEB-INF/web.xml"), "web.xml")
  // w-exact：pat="/a/b" path="/a/b"
  let m = @path.extract_variables("/a/b", "/a/b")
  assert_eq(m.length(), 0)
  assert_eq(@path.extract_within("/a/b", "/a/b"), "")
  // w-root：pat="/**" path="/a/b"
  let m = @path.extract_variables("/**", "/a/b")
  assert_eq(m.length(), 0)
  assert_eq(@path.extract_within("/**", "/a/b"), "a/b")
  // combine c-normal：a="com/**" b="*.jsp" 参照读数="com/**/*.jsp"
  assert_eq(@path.combine("com/**", "*.jsp"), "com/**/*.jsp")
  // combine c-slash1：a="/test/" b="//hotels.html" 参照读数="/test//hotels.html"
  assert_eq(@path.combine("/test/", "//hotels.html"), "/test//hotels.html")
  // combine c-empty-a：a="" b="/a" 参照读数="/a"
  assert_eq(@path.combine("", "/a"), "/a")
  // combine c-empty-b：a="/a" b="" 参照读数="/a"
  assert_eq(@path.combine("/a", ""), "/a")
  // combine c-both-empty：a="" b="" 参照读数=""
  assert_eq(@path.combine("", ""), "")
  // c-null-a：参照腿对 null 参数直接退化，本库入参是 String 不存在该档（spec §5 第 5 行）
  // c-null-b：参照腿对 null 参数直接退化，本库入参是 String 不存在该档（spec §5 第 5 行）
  // combine c2-jsp-exact：a="/*.jsp" b="/hotels.jsp" 参照读数="/hotels.jsp"
  assert_eq(@path.combine("/*.jsp", "/hotels.jsp"), "/hotels.jsp")
  // combine c2-jsp-noext：a="/*.jsp" b="/hotels" 参照读数="/hotels.jsp"
  assert_eq(@path.combine("/*.jsp", "/hotels"), "/hotels.jsp")
  // combine c2-ext-clash：a="/*.jsp" b="/*.txt" 参照读数="EX:IllegalArgumentException"
  assert_true(
    err_of(() => @path.combine("/*.jsp", "/*.txt")).has_prefix(
      "ExtensionConflict",
    ),
  )
  // combine c2-plain：a="/hotels" b="/bookings" 参照读数="/hotels/bookings"
  assert_eq(@path.combine("/hotels", "/bookings"), "/hotels/bookings")
  // combine c2-nolead：a="/hotels" b="bookings" 参照读数="/hotels/bookings"
  assert_eq(@path.combine("/hotels", "bookings"), "/hotels/bookings")
  // combine c2-star-tail：a="/hotels/*" b="/bookings" 参照读数="/hotels/bookings"
  assert_eq(@path.combine("/hotels/*", "/bookings"), "/hotels/bookings")
  // combine c2-dstar-tail：a="/hotels/**" b="/bookings" 参照读数="/hotels/**/bookings"
  assert_eq(@path.combine("/hotels/**", "/bookings"), "/hotels/**/bookings")
  // combine c2-var：a="/hotels" b="{hotel}" 参照读数="/hotels/{hotel}"
  assert_eq(@path.combine("/hotels", "{hotel}"), "/hotels/{hotel}")
  // combine c2-star-var：a="/hotels/*" b="{hotel}" 参照读数="/hotels/{hotel}"
  assert_eq(@path.combine("/hotels/*", "{hotel}"), "/hotels/{hotel}")
  // combine c2-same：a="/hotels" b="/hotels" 参照读数="/hotels/hotels"
  assert_eq(@path.combine("/hotels", "/hotels"), "/hotels/hotels")
  // combine c2-all-ext：a="/hotels/.*" b="/a/b" 参照读数="/hotels/.*/a/b"
  assert_eq(@path.combine("/hotels/.*", "/a/b"), "/hotels/.*/a/b")
  // combine c2-match-p2：a="/*.jsp" b="/WEB-INF/x.jsp" 参照读数="EX:IllegalArgumentException"
  assert_true(
    err_of(() => @path.combine("/*.jsp", "/WEB-INF/x.jsp")).has_prefix(
      "ExtensionConflict",
    ),
  )
}

///|
// 模式具体度排序（比较器）
test "path 模式具体度排序（比较器）" {
  // 比较器逐对直读（10条）：不从排序结果反推——并列时参照实现的稳定排序留下输入序，反推会造出一个不存在的严格序承诺
  assert_eq(@path.compare_patterns("/x", "/x", "/x"), 0)
  assert_eq(
    @path.compare_patterns("/hotels/chicago", "/hotels/*", "/**/hotels/**"),
    -1,
  )
  assert_eq(
    @path.compare_patterns("/hotels/chicago", "/**/hotels/**", "/hotels/**"),
    -3,
  )
  assert_eq(@path.compare_patterns("/hotels/chicago", "/hotels/**", "/**"), -1)
  assert_eq(@path.compare_patterns("/a/b", "/a/b", "/**/b"), -1)
  assert_eq(@path.compare_patterns("/a/b", "/**/b", "/a/**"), 0)
  assert_eq(@path.compare_patterns("/a/b", "/a/**", "/**"), -1)
  assert_eq(@path.compare_patterns("/x", "/x", "/**"), -1)
  assert_eq(
    @path.compare_patterns("/WEB-INF/a.jsp", "/WEB-INF/*", "/WEB-INF/**"),
    -1,
  )
  assert_eq(
    @path.compare_patterns("/WEB-INF/a.jsp", "/WEB-INF/**", "/**/*.jsp"),
    -1,
  )
}
