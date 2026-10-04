// moon-hutool/text 契约用例（黑盒）。
//
// 状态：实现未开工，**预期全红**（被测函数体是 abort）。这正是"文档契约先行"的交付形状——
// 期望值先冻结，实现只负责把红变成绿；PR-B 不许改这里的期望值（门禁 G5）。
// 用例名带 spec 条目号，红的时候能直接指回契约行。
//
// 三点写法约定（都被本机编译器教过）：
// · 包别名来自 `text/moon.pkg` 的 `for "test"` 声明，`.mbt` 里写 `import` 会被判非法；
// · 结果确定的用例一律 `assert_eq`/`assert_true`，不用 `inspect`——core CONTRIBUTING 明说
//   "for solid, well-defined results prefer assertion tests"，且 inspect 对集合走 Show 会吃废弃警告；
// · `\u{...}` 转义只在 char 字面量里合法，写进字符串会被切成插值。

///|
test "text.is_blank #1.2 空白档" {
  assert_true(@text.is_blank(""))
  assert_true(@text.is_blank("   "))
  assert_true(@text.is_blank("\t \n"))
  let nul : Char = '\u{0000}' // hutool 独有码点，多数实现会漏
  assert_true(@text.is_blank("\{nul}"))
  let ideo_space : Char = '\u{3000}' // core Char::is_whitespace 已覆盖
  assert_true(@text.is_blank("\{ideo_space}"))
  assert_false(@text.is_blank("a"))
  assert_false(@text.is_blank(" a"))
}

///|
test "text.is_empty #1.3 与 blank 分档" {
  assert_true(@text.is_empty(""))
  assert_false(@text.is_empty(" ")) // 关键：非空但全空白 → empty 假、blank 真
}

///|
test "text.trim #1.4" {
  assert_eq(@text.trim("  ab  "), "ab")
  assert_eq(@text.trim("\tab\n"), "ab")
  assert_eq(@text.trim(""), "")
  assert_eq(@text.trim_opt(None), None)
  assert_eq(@text.trim_opt(Some("  ab ")), Some("ab"))
  assert_eq(@text.trim_opt(Some("   ")), Some("")) // trimToNull 只管 null，不管全空白串
}

///|
test "text.split #1.5 空段保留" {
  assert_eq(@text.split("a,b,,c", ','), ["a", "b", "", "c"])
  assert_eq(@text.split("", ','), [])
  assert_eq(@text.split(" a , b ", ',', trim_result=true), ["a", "b"])
}

///|
test "text.join #1.6" {
  assert_eq(@text.join(["a", "b"], "-"), "a-b")
  assert_eq(@text.join(["a", "", "b"], "-"), "a--b")
  assert_eq(@text.join([], "-"), "")
}

///|
test "text.sub_* #1.7 未命中行为不对称" {
  // 默认取**第一个**分隔符（hutool subBefore/subAfter 的 isLastSeparator 默认 false，
  // 证据 CharSequenceUtil.java:2369、2446 `pos = isLastSeparator ? lastIndexOf : indexOf`）
  assert_eq(@text.sub_before("path/to/file.txt", "/"), "path")
  assert_eq(@text.sub_before("nope", "/"), "nope") // 未命中→整串
  assert_eq(@text.sub_after("path/to/file.txt", "/"), "to/file.txt")
  assert_eq(@text.sub_after("nope", "/"), "") // 未命中→空串
  assert_eq(@text.sub_between("hutool{abc}end", "{", "}"), "abc")
  assert_eq(
    @text.sub_between("hutool{abc}end", "{", "}", include_sep=true),
    "{abc}",
  )
  assert_eq(@text.sub_between("hutool abc end", "{", "}"), "")
}

///|
test "text.format #1.8 三条硬语义" {
  assert_eq(@text.format("a{}b", ["1"]), "a1b")
  assert_eq(@text.format("id={} name={}", ["7"]), "id=7 name={}") // 参数不足：未填原样留
  assert_eq(@text.format("keep \\{}", []), "keep {}") // 前置反斜杠 → 字面量 {}
  assert_eq(@text.format("", []), "")
}

///|
test "text.compare_version #1.9 逐段数值比较与缺段补零" {
  assert_eq(@text.compare_version("1.2.3", "1.2.10"), -1)
  assert_eq(@text.compare_version("1.0.0", "1.0"), 0)
  assert_eq(@text.compare_version("2", "10"), -1) // 按数值不是按字典序
}

///|
test "text.first_non_blank #1.10" {
  assert_eq(
    @text.first_non_blank([None, Some("  "), Some("x"), Some("y")]),
    Some("x"),
  )
  assert_eq(@text.first_non_blank([Some(" "), None]), None)
}

///|
test "text.hide #1.11 码点下标与越界夹紧" {
  assert_eq(@text.hide("13012345678", 3, 7, '*'), "130****5678")
  // 码点计，且**区间外字符全部保留**（hutool hide javadoc：hide("jackduan@163.com",2,3) → "ja*kduan@163.com"）
  assert_eq(@text.hide("中文测试", 1, 3, '*'), "中**试")
  assert_eq(@text.hide("abc", 1, 99, '*'), "a**") // 越界夹紧
}

// 命名法互转此刻只冻结了最确定的三条：连续大写、全大写串、数字参与判定等形状必须在实现相位
// 从 hutool v5-master 的 NamingCase 逐条反推后再冻结，不在这里凭印象写。

///|
test "text.naming #1.12 已定部分" {
  assert_eq(@text.to_underline_case("userName"), "user_name")
  assert_eq(@text.to_camel_case("user_name"), "userName")
  assert_eq(@text.to_camel_case("userName"), "userName") // 无分隔符→原样返回（hutool 规则）
}

///|
test "text.upper_first #1.13 ASCII 档" {
  assert_eq(@text.upper_first("hutool"), "Hutool")
  assert_eq(@text.upper_first(""), "")
}

// 门禁 G8 的实证腿：is_blank 的空白档建立在 core `Char::is_whitespace` 之上（并集，只可更宽）。
// 这条断言把"core 判空白 ⇒ 本库必判空白"钉住：core 若在未来版本改了语义，这里先红，由我们决定跟不跟，
// 而不是等用户在线上发现漂移。方向是单向的（本库可额外覆盖 hutool 独有码点），所以只断这个方向。

///|
test "text.is_blank #1.2 对拍 core Char::is_whitespace（G8）" {
  let marks : Array[Char] = [
    ' ', '\t', '\n', '\u{00A0}', '\u{1680}', '\u{2000}', '\u{2028}', '\u{3000}',
  ]
  for c in marks {
    assert_true(c.is_whitespace()) // core 侧读数先成立
    let s : String = "\{c}"
    assert_true(@text.is_blank(s)) // 子集关系：core 判空白处本库不许判假
  }
}
