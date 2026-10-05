///|
// 第一批（re）的期望值由生成器从两条腿的读数文件灌入，手打零条：
//   腿 A = 真 hutool-core 5.8.35 + 本机 JDK 17.0.14 跑 ReUtil（923 条：主夹具 859 + 难料补测 58 + 未参与组/择路 6）
//   腿 A′ = JDK `Pattern`/`Matcher` 直接跑（6 条，只在"参照实现自己崩了"的那些档当引擎侧对读）
//   腿 B = core @string.Regex 探针（114 条，wasm/js/wasm-gc 三档逐字节相同）
// 两条腿都有读数的夹具逐条交叉核对；不一致的在注释里给出两侧原读数，并在 spec §5 声明分岔。
// 规则书与全部出处：docs/spec/10-re.md。改任何一条期望串须单独一笔并给外部读数来源（门禁 G5）。

///|
/// 把错误面折成字符串：变体名 + 携带值一起进断言（携带值也是契约的一部分，同 `num`/`coll`/`date` 的写法）
fn show(err : @re.ReError) -> String {
  match err {
    @re.BadPattern(s) => "BadPattern \{s}"
    @re.BadReference(s) => "BadReference \{s}"
  }
}

///|
// 跑一次预期会 raise 的调用，返回错误形状；没 raise 就返回「未抛错」
fn[A] cn_err(g : () -> A raise @re.ReError) -> String {
  try {
    let _ = g()
    "未抛错"
  } catch {
    err => show(err)
  }
}

///|
// is_valid_pattern 与 compile 同一张嘴，判据取腿 B（core 引擎）的编译结果；「Java 能写而 core 不能写」那批写法逐条实测列在下面，本包一律不收、也不自动改写（spec §0.2）。
test "re：编译面与方言（#10.1~#10.2）" {
  assert_eq(@re.is_valid_pattern("[[:digit:]]+"), true)
  assert_eq(@re.is_valid_pattern("(?<y>[0-9]{4})"), true)
  assert_eq(@re.is_valid_pattern("[0-9]+"), true)
  assert_eq(@re.is_valid_pattern("(?<a>[0-9]+)"), true)
  assert_eq(@re.is_valid_pattern("a{256}"), true)
  assert_eq(@re.is_valid_pattern("(?i:abc)"), true)
  assert_eq(@re.is_valid_pattern("[[:ascii:]]"), true)
  assert_eq(@re.is_valid_pattern("[[:alpha:]]"), true)
  assert_eq(@re.is_valid_pattern("[[:word:]]"), true)
  assert_eq(@re.is_valid_pattern("[[:space:]]"), true)
  assert_eq(@re.is_valid_pattern("[[:upper:]]"), true)
  assert_eq(@re.is_valid_pattern("."), true)
  assert_eq(@re.is_valid_pattern("^a$"), true)
  assert_eq(@re.is_valid_pattern("\\b"), true)
  assert_eq(@re.is_valid_pattern("\\B"), true)
  assert_eq(@re.is_valid_pattern("\\u0041"), true)
  assert_eq(@re.is_valid_pattern("\\u{1F600}"), true)
  assert_eq(!@re.is_valid_pattern("\\d+"), true) // 腿 A 合法、腿 B 报错 ⇒ 不收（§5 第 1 行）
  assert_eq(!@re.is_valid_pattern("\\w+"), true) // 腿 A 合法、腿 B 报错 ⇒ 不收（§5 第 1 行）
  assert_eq(!@re.is_valid_pattern("\\s+"), true)
  assert_eq(!@re.is_valid_pattern("\\x41"), true) // 腿 A 合法、腿 B 报错 ⇒ 不收（§5 第 1 行）
  assert_eq(!@re.is_valid_pattern("\\p{L}"), true) // 腿 A 合法、腿 B 报错 ⇒ 不收（§5 第 1 行）
  assert_eq(!@re.is_valid_pattern("\\pL"), true)
  assert_eq(!@re.is_valid_pattern("\\A"), true) // 腿 A 合法、腿 B 报错 ⇒ 不收（§5 第 1 行）
  assert_eq(!@re.is_valid_pattern("\\z"), true)
  assert_eq(!@re.is_valid_pattern("\\Q"), true)
  assert_eq(!@re.is_valid_pattern("\\1"), true) // 腿 A 合法、腿 B 报错 ⇒ 不收（§5 第 1 行）
  assert_eq(!@re.is_valid_pattern("(?=a)"), true)
  assert_eq(!@re.is_valid_pattern("(?!a)"), true)
  assert_eq(!@re.is_valid_pattern("(?<=a)"), true)
  assert_eq(!@re.is_valid_pattern("(?<!a)"), true)
  assert_eq(!@re.is_valid_pattern("a++"), true)
  assert_eq(!@re.is_valid_pattern("(?i)abc"), true) // 腿 A 合法、腿 B 报错 ⇒ 不收（§5 第 1 行）
  assert_eq(!@re.is_valid_pattern("[:ascii:]"), true) // 腿 A 合法、腿 B 报错 ⇒ 不收（§5 第 1 行）
  assert_eq(!@re.is_valid_pattern("[a-]"), true)
  assert_eq(!@re.is_valid_pattern("[-a]"), true)
  assert_eq(!@re.is_valid_pattern("a{300}"), true)
  assert_eq(!@re.is_valid_pattern("a{2,1}"), true)
  assert_eq(!@re.is_valid_pattern("[a-\\d]"), true)
  assert_eq(!@re.is_valid_pattern("("), true)
  assert_eq(!@re.is_valid_pattern(")"), true)
  assert_eq(!@re.is_valid_pattern("(?'y'a)"), true)
  assert_eq(!@re.is_valid_pattern("(?P<y>a)"), true)
  assert_eq(cn_err(() => @re.compile("(")), "BadPattern (")
  assert_eq(cn_err(() => @re.compile("\\d+")), "BadPattern \\d+")
  // \d 在腿 B 是编译期报错而不是静默退化：spec §4 第 4 条按探针改判过一条源码推断
}

///|
// hutool 的 RE_KEYS 只有 15 个字符（$ ( ) * + . [ ] ? \ ^ { } |）：本包对位那张表而不是「绝对安全」，要字面匹配请用 core 的 Regex::string。
test "re：转义表逐字跟随（#10.3）" {
  assert_eq(@re.quote("a.b"), "a\\.b")
  assert_eq(@re.quote("$1|2"), "\\$1\\|2")
  assert_eq(@re.quote("a[b]"), "a\\[b\\]")
  assert_eq(@re.quote("+-*/"), "\\+-\\*/")
  assert_eq(@re.quote("中文"), "中文")
  assert_eq(@re.quote("a\\b"), "a\\\\b")
  assert_eq(@re.quote("^{}()?"), "\\^\\{\\}\\(\\)\\?")
  assert_eq(@re.quote("-"), "-")
  assert_eq(@re.quote("a=b"), "a=b")
  assert_eq(@re.quote(" "), " ")
  assert_eq(@re.quote(""), "")
  // 表里没有的字符不动：`-`、`=`、空格、非 ASCII 逐条量过（腿 A 的 escape）
}

///|
// is_match 对位 Matcher.matches()（整串），不是 find；空模式那一档不跟随 hutool 的短路哨兵。
test "re：整串匹配与空模式哨兵（#10.4）" {
  assert_eq(@re.is_match("[0-9]+", "1234"), true)
  assert_eq(@re.is_match("[0-9]+", "中文1234"), false)
  assert_eq(@re.is_match("[0-9]+", "abc"), false)
  assert_eq(@re.is_match("abc", "axxb"), false)
  assert_eq(@re.is_match("^abc$", "abc"), true)
  assert_eq(@re.is_match("[0-9]+", ""), false)
  assert_eq(@re.is_match("x*", "axxb"), false)
  assert_eq(@re.is_match("(a)?b", "abc"), false)
  assert_eq(@re.is_match("", "abc"), false)
  // 分岔（§5 第 3 行）：hutool 空模式短路 = true；本包按引擎语义（腿 B 实测空模式只在各位置零宽命中）
  assert_eq(cn_err(() => @re.is_match("\\d+", "a")), "BadPattern \\d+")
}

///|
// count 数非重叠匹配条数；零宽模式在每个位置各数一次——两条腿在这一档同读数（x*@abab：腿 A 5 / 腿 B 5）。
test "re：contains 与 count（#10.5~#10.6）" {
  assert_eq(@re.contains("abc", "abc"), true)
  assert_eq(@re.contains("^abc$", "abc"), true)
  assert_eq(@re.contains("[0-9]+", "中文1234"), true)
  assert_eq(@re.contains("[0-9]+", "abc"), false)
  assert_eq(@re.contains("abc", "axxb"), false)
  assert_eq(@re.contains("", "abc"), true)
  assert_eq(@re.count("[0-9]+", "1234"), 1)
  assert_eq(@re.count("[0-9]+", "中文1234"), 1)
  assert_eq(@re.count("abc", "abc"), 1)
  assert_eq(@re.count("x*", "axxb"), 4)
  assert_eq(@re.count("(a)?b", "abc"), 1)
  assert_eq(@re.count("x*", "abab"), 5)
  // 零宽计数两腿同读数：腿 A = 5、腿 B = 5
  assert_eq(cn_err(() => @re.count("\\d+", "a")), "BadPattern \\d+")
}

///|
// 查询类只留一个出口档：没命中、组没参与、组号越界、名字不存在都给 None；hutool 在后两档直接崩（实测附注释里）。
test "re：整段、第 N 组与命名组（#10.7~#10.9）" {
  assert_eq(
    @re.find_first("(?<a>[0-9]+)-(?<b>[0-9]+)", "2026-10-05"),
    Some("2026-10"),
  )
  assert_eq(@re.find_first("(?<a>[0-9]+)-(?<b>[0-9]+)", "bbb"), None)
  assert_eq(@re.find_first("([0-9]+)", "中文1234"), Some("1234"))
  assert_eq(
    @re.find_first_group("(?<a>[0-9]+)-(?<b>[0-9]+)", "2026-10-05", 1),
    Some("2026"),
  )
  assert_eq(@re.find_first_group("([0-9])([0-9])", "a1b22c333", 2), Some("2"))
  assert_eq(@re.find_first_group("([0-9])([0-9])", "a1b22c333", 9), None)
  // 不跟随（§5 第 4 行）：腿 A 这一档 ERR:IndexOutOfBoundsException:No group 9
  assert_eq(@re.find_first_group("(a)?b", "bbb", 1), None)
  // 组没参与那一档两腿同形：腿 A = null ⇒ 本包 None
  assert_eq(
    @re.find_first_named("(?<a>[0-9]+)-(?<b>[0-9]+)", "2026-10-05", "a"),
    Some("2026"),
  )
  assert_eq(
    @re.find_first_named("(?<a>[0-9]+)-(?<b>[0-9]+)", "2026-10-05", "z"),
    None,
  )
  // 不跟随（§5 第 4 行）：腿 A 这一档 ERR:IllegalArgumentException:No group with name <z>
}

///|
// 列表按命中顺序、每条一项；某条命里的组没参与时那一项是 None（hutool 进列表的是 null，同一档）。择路两腿同档：都取 leftmost-first（腿 B 实测 a|ab 于 ab 取 a）。
test "re：全部命中与全部组（#10.10~#10.12）" {
  assert_eq(@re.find_all("[0-9]+", "a1b22c333"), ["1", "22", "333"])
  assert_eq(@re.find_all("[0-9]+", "2026-10-05"), ["2026", "10", "05"])
  assert_eq(@re.find_all("(a)?b", "bbb"), ["b", "b", "b"])
  assert_eq(@re.find_all("a|ab", "a1b22c333"), ["a"])
  assert_eq(@re.find_all("[0-9]+", "中文1234"), ["1234"])
  assert_eq(@re.find_all("(?<a>[0-9]+)-(?<b>[0-9]+)", "2026-10-05"), ["2026-10"])
  assert_eq(@re.find_all_group("([0-9])([0-9])", "2026-10-05", 1), [
    Some("2"),
    Some("2"),
    Some("1"),
    Some("0"),
  ])
  assert_eq(@re.find_all_group("([0-9])([0-9])", "2026-10-05", 0), [
    Some("20"),
    Some("26"),
    Some("10"),
    Some("05"),
  ])
  assert_eq(@re.groups_of_first("([0-9])([0-9])", "a1b22c333"), [
    Some("22"),
    Some("2"),
    Some("2"),
  ])
  assert_eq(
    @re.groups_of_first("([0-9])([0-9])", "a1b22c333", with_group0=false),
    [Some("2"), Some("2")],
  )
  assert_eq(@re.groups_of_first("(a)?b", "bbb", with_group0=false), [None])
  // 带 0 组那份 = [b, null]（未参与的一位是 null ⇒ 本包 None）
  // leftmost-first：腿 A 的 a|ab 于 a1b22c333 = [a]；腿 B 在 ab 上整段取 0=a
}

///|
// hutool 枚举名字靠反射 Pattern.namedGroups()——JDK 17 不加 --add-opens 时整条腿 InaccessibleObjectException（实测），且那份 HashMap 键序不可依赖；本包扫模式串给声明序（腿 A 加 opens 后 = [a, b]）。
test "re：命名组的清单与映射（#10.13~#10.14）" {
  assert_eq(@re.group_names("(?<a>[0-9]+)-(?<b>[0-9]+)"), ["a", "b"])
  assert_eq(@re.group_names("(?:x)(?<y>a)"), ["y"])
  assert_eq(@re.group_names("([0-9])([0-9])"), [])
  assert_eq(
    cn_err(() => @re.group_names("(?<a>x)(?<a>y)")),
    "BadPattern (?<a>x)(?<a>y)",
  )
  // 重名两腿同判断：腿 A = ERR:PatternSyntaxException:Named capturing group <a> is already defined near index 11
  let g1 = @re.named_groups("(?<a>[0-9]+)-(?<b>[0-9]+)", "2026-10-05")
  assert_eq(g1.get("a"), Some("2026"))
  assert_eq(g1.get("b"), Some("10"))
  assert_eq(g1.length(), 2)
  // ↑ 两条 get 与条数都取自腿 A 的 namedmap 读数：{a=2026, b=10}
  assert_eq(@re.named_groups("(?<a>[0-9]+)-(?<b>[0-9]+)", "bbb").length(), 0)
  // 无命中时腿 A 也是空 Map：{}
}

///|
// 半开区间 [start, end)，两腿同口径（UTF-16 码元，spec §0.4）；core 没有直接位置出口：起点靠 before() 长度、终点靠 after() 反推。
test "re：起止位置（#10.15~#10.16）" {
  assert_eq(@re.first_position("[0-9]+", "a1b22c333"), Some((1, 2)))
  assert_eq(@re.last_position("[0-9]+", "a1b22c333"), Some((6, 9)))
  assert_eq(@re.first_position("[0-9]+", "中文1234"), Some((2, 6)))
  assert_eq(@re.last_position("[0-9]+", "中文1234"), Some((2, 6)))
  assert_eq(@re.first_position("[0-9]+", "bbb"), None)
  assert_eq(@re.last_position("[0-9]+", "bbb"), None)
  assert_eq(@re.first_position("[0-9]+", ""), None)
  assert_eq(@re.last_position("[0-9]+", ""), None)
  // 口径 = UTF-16 码元：腿 B 实测 b 于「中文b」起点 = 2、x 于 emoji+x 起点 = 2
  // 手动迭代（起 = 全长 - after 长度）在 a1b22 上 = 1@1,2@3,2@4 ⇒ 终点换算同源
}

///|
// 尾随空段就是分岔（spec §5 第 6 行）：[,;] 于 ,a, 腿 A = [, a]（Java String.split 丢尾随空段）、腿 B = [|a|]（引擎保留）⇒ 本包跟引擎，不二次修剪。
test "re：按模式切分（#10.17）" {
  assert_eq(@re.split("[,;]", "a,b;c"), ["a", "b", "c"]) // 两腿一致
  assert_eq(@re.split("[,;]", ",a,"), ["", "a", ""]) // ★分岔：腿 A = [, a] / 腿 B = [|a|] ⇒ 跟引擎
  assert_eq(@re.split("[,;]", "a,,b"), ["a", "", "b"]) // 两腿一致
  assert_eq(@re.split("[0-9]", "abc"), ["abc"]) // 两腿一致
  assert_eq(@re.split("", "ab"), ["", "a", "b", ""]) // 分岔（§5 第 6 行）：腿 A 于 abc = [a, b, c]（不吐首部空段）
}

///|
// del_pre 删到第一处匹配的**结束**为止（爬取时推进游标那一档：腿 A \d+ 于 a1b22c333 ⇒ b22c333），与 del_first 是两件事。
test "re：删除族四件（#10.18~#10.21）" {
  assert_eq(@re.del_first("[0-9]+", "a1b22c333"), "ab22c333")
  assert_eq(@re.del_last("[0-9]+", "a1b22c333"), "a1b22c")
  assert_eq(@re.del_all("[0-9]+", "a1b22c333"), "abc")
  assert_eq(@re.del_pre("[0-9]+", "a1b22c333"), "b22c333")
  assert_eq(@re.del_first("[0-9]+", "bbb"), "bbb")
  assert_eq(@re.del_last("[0-9]+", "bbb"), "bbb")
  assert_eq(@re.del_all("[0-9]+", "bbb"), "bbb")
  assert_eq(@re.del_pre("[0-9]+", "bbb"), "bbb")
  assert_eq(@re.del_first("[0-9]+", "1"), "")
  assert_eq(@re.del_last("[0-9]+", "1"), "")
  assert_eq(@re.del_all("[0-9]+", "1"), "")
  assert_eq(@re.del_pre("[0-9]+", "1"), "")
  assert_eq(@re.del_first("([0-9])", "a1b22c333"), "ab22c333")
  assert_eq(@re.del_last("([0-9])", "a1b22c333"), "a1b22c33")
  assert_eq(@re.del_all("([0-9])", "a1b22c333"), "abc")
  assert_eq(@re.del_pre("([0-9])", "a1b22c333"), "b22c333")
  assert_eq(@re.del_first("b", "a1b22c333"), "a122c333")
  assert_eq(@re.del_last("b", "a1b22c333"), "a122c333")
  assert_eq(@re.del_all("b", "a1b22c333"), "a122c333")
  assert_eq(@re.del_pre("b", "a1b22c333"), "22c333")
  assert_eq(@re.del_all("x*", "abab"), "abab")
  // 零宽什么都不删：腿 A del_all(x*@abab) = abab
  assert_eq(cn_err(() => @re.del_all("\\d+", "a")), "BadPattern \\d+")
}

///|
// 只回模板、丢掉周围（extract 与 replace 的分界）。$N 的代入顺序是规则不是细节：按位数从长到短，12 组模式上的 $1-$11 是能分辨两种顺序的那条夹具。
test "re：模板提取（#10.22）" {
  assert_eq(
    @re.extract_with_template("([0-9]*)年([0-9]*)月", "2013年5月", "$1-$2"),
    Some("2013-5"),
  )
  assert_eq(@re.extract_with_template("([0-9]+)", "abc", "[$1]"), None)
  // 腿 A 无命中给 null：null
  assert_eq(
    @re.extract_with_template(
      "(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)(k)(l)", "abcdefghijkl", "$1-$11",
    ),
    Some("a-k"),
  )
  // 降序代入的唯一判别夹具：腿 A = a-k；按升序先替 $1 会得到 "a-a-11"
  assert_eq(
    @re.extract_with_template(
      "(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)(k)(l)", "abcdefghijkl", "$11$1",
    ),
    Some("ka"),
  )
  assert_eq(
    @re.extract_with_template(
      "(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)(k)(l)", "abcdefghijkl", "$12",
    ),
    Some("l"),
  )
  assert_eq(
    cn_err(() => {
      @re.extract_with_template(
        "(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)(k)(l)", "abcdefghijkl", "$13",
      )
    }),
    "BadReference $13",
  )
  // 不跟随（§5 第 5 行）：腿 A 引用不存在的组 = ERR:IndexOutOfBoundsException:No group 111
}

///|
// 两条都不暴露 limit：core 的 replace_by 在 limit 为负时一处都不换（腿 B 实测 lim=-1 ⇒ a1b22c333，与 lim=0 同读数），透传等于把陷阱写进契约（spec §5 第 10 行）。
test "re：模板替换与回调替换（#10.23~#10.24）" {
  assert_eq(
    @re.replace_with_template(
      "([0-9])([0-9])([0-9])", "abc xyz 123456", "$1-$2",
    ),
    "abc xyz 1-24-5",
  )
  assert_eq(
    @re.replace_with_template("([0-9])([0-9])([0-9])", "xxx", "$1-$2"),
    "xxx",
  )
  assert_eq(
    @re.replace_with_template(
      "(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)(k)(l)", "abcdefghijkl", "$1-$11",
    ),
    "a-k",
  )
  assert_eq(
    @re.replace_with_template("([0-9])([0-9])([0-9])", "123", "$0"),
    "123",
  )
  assert_eq(@re.replace_with_template("([0-9])([0-9])([0-9])", "123", "$"), "$")
  assert_eq(
    @re.replace_with_template("([0-9])([0-9])([0-9])", "123", "${a}"),
    "${a}",
  )
  // `$` 后不是数字 ⇒ 原样留着；无命中的两条同样原样返回（腿 A 同读数）
  assert_eq(@re.replace_with_template("([$\\])", "$\\", "($1)"), "($)(\\)")
  // 组值里的 $ 与 \ 不被二次解释：这条腿 A 读数 = ($)(\)
  assert_eq(
    cn_err(() => @re.replace_with_template("([0-9])", "a1", "$2")),
    "BadReference $2",
  )
  // 不跟随（§5 第 5 行）：腿 A 这一档 = ERR:IndexOutOfBoundsException:No group 2
  assert_eq(
    @re.replace_by("([0-9]+)", "a1b22", m => "-" + m.content().to_owned() + "-"),
    "a-1-b-22-",
  )
  assert_eq(@re.replace_by("b", "bbb", _ => ""), "")
  // 回调返回值按字面写入：腿 B 实测 core 的 replace_by 把模板串留在输出里 = a$1<1>b$1<22>c333
}

///|
/// 本轮补测两条：未参与组的模板档（契约没冻到的那一档，取值取引擎侧语义）与 `is_match` 的择路整串档。
/// 腿 A（hutool）在前一条上直接 `NullPointerException`，在后一条上现读 `true`——两条都有读数在案。
test "re：模板里的未参与组与整串择路（#10.4/#10.22~#10.23 补测）" {
  assert_eq(@re.extract_with_template("(a)?b", "b", "[$1]"), Some("[]"))
  assert_eq(@re.replace_with_template("(a)?b", "xb", "[$1]"), "x[]")
  // 腿 A：(a)?b 的 1 组未参与时 extractMulti/replaceAll = ERR:NullPointerException（"replacement" is null）
  // JDK 腿：replaceAll("[$1]") 于 "b" = []、appendReplacement 于 "xb" = x[]、"<$1|$2>" 于 "ac" = <a|> ⇒ 空串
  assert_eq(@re.is_match("a|ab", "ab"), true)
  assert_eq(@re.is_match("a|ab", "a"), true)
  // 判别夹具：把 is_match 实现成"最左一段占满"会在第一条给 false，而腿 A 现读 true
}
