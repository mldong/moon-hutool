// 本文件的每一条期望都由 `scripts/gen_batch1_rest.py` 从参照腿 `scripts/ReplacerLeg.java` 的读数灌入，**手打零条**。
// 参照版本 hutool-all 5.8.37；判据口径见 docs/spec/01-text.md §1.20。
// 期望值冻结（AGENTS）：改这里任何一条都要单独一笔并给新的腿读数。

///|
test "text.replacer #1.20 lookup 择路：长键优先与表序无关（腿 L|full）" {
  assert_eq(
    @text.lookup_replacer([("ab", "X"), ("abc", "Y")]).replace("xaby abc"),
    "xXy Y",
  ) // L|full|set0|xaby abc|xXy Y
  assert_eq(
    @text.lookup_replacer([("abc", "Y"), ("ab", "X")]).replace("xaby abc"),
    "xXy Y",
  ) // L|full|set1|xaby abc|xXy Y
  assert_eq(
    @text.lookup_replacer([("ab", "1"), ("ab", "2")]).replace("ab"),
    "2",
  ) // L|full|set2|ab|2
  assert_eq(@text.lookup_replacer([("a", "A")]).replace("aaa"), "AAA") // L|full|set3|aaa|AAA
  assert_eq(
    @text.lookup_replacer([("a1", "P"), ("a22", "Q"), ("a2", "R")]).replace(
      "a1 a22 a2 a",
    ),
    "P Q R a",
  ) // L|full|set5|a1 a22 a2 a|P Q R a
  assert_eq(
    @text.lookup_replacer([("\u{4e2d}", "M"), ("\u{4e2d}\u{6587}", "N")]).replace(
      "\u{4e2d} \u{4e2d}\u{6587}",
    ),
    "M N",
  ) // L|full|set6|{u4e2d} {u4e2d}{u6587}|M N
  assert_eq(
    @text.lookup_replacer([("|", "PIPE"), ("\\", "BS")]).replace("a|b\\c"),
    "aPIPEbBSc",
  ) // L|full|set7|a{u007c}b\c|aPIPEbBSc
}

///|
test "text.replacer #1.20 空表：一位都不换（腿 L|empty）" {
  assert_eq(@text.lookup_replacer([]).replace("abc"), "abc") // L|empty|abc|abc
  assert_eq(@text.lookup_replacer([]).replace(""), "") // L|empty||
}

///|
test "text.replacer #1.20 空键：参照构造即抛，本库 raise(EmptyKey)" {
  assert_eq(cn_err(() => @text.lookup_replacer([("", "E")])), "EmptyKey") // L|ctor|set4|ERR:StringIndexOutOfBoundsException
}

///|
test "text.replacer #1.20 链的叠加形状（腿 C|empty/dup/overlap）" {
  assert_eq(@text.replacer_chain([]).replace("abc"), "abc") // C|empty|abc|n=0
  assert_eq(
    @text.replacer_chain([
      @text.lookup_replacer([("aa", "b")]),
      @text.lookup_replacer([("aa", "b")]),
    ]).replace("aaaa"),
    "bb",
  ) // C|dup|bb
  assert_eq(
    @text.replacer_chain([
      @text.lookup_replacer([("ab", "1")]),
      @text.lookup_replacer([("1", "X")]),
    ]).replace("ab"),
    "1",
  ) // C|overlap|1
}

///|
test "text.replacer #1.20 链：每位置只问第一个命中的（腿 C|chain）" {
  assert_eq(
    @text.replacer_chain([
      @text.lookup_replacer([("ab", "1")]),
      @text.lookup_replacer([("bc", "2")]),
      @text.lookup_replacer([("cd", "3")]),
    ]).replace("abcd"),
    "13",
  ) // C|chain|abcd|13
  assert_eq(
    @text.replacer_chain([
      @text.lookup_replacer([("ab", "1")]),
      @text.lookup_replacer([("bc", "2")]),
      @text.lookup_replacer([("cd", "3")]),
    ]).replace("ab"),
    "1",
  ) // C|chain|ab|1
  assert_eq(
    @text.replacer_chain([
      @text.lookup_replacer([("ab", "1")]),
      @text.lookup_replacer([("bc", "2")]),
      @text.lookup_replacer([("cd", "3")]),
    ]).replace("bc"),
    "2",
  ) // C|chain|bc|2
  assert_eq(
    @text.replacer_chain([
      @text.lookup_replacer([("ab", "1")]),
      @text.lookup_replacer([("bc", "2")]),
      @text.lookup_replacer([("cd", "3")]),
    ]).replace("zz"),
    "zz",
  ) // C|chain|zz|zz
  assert_eq(
    @text.replacer_chain([
      @text.lookup_replacer([("ab", "1")]),
      @text.lookup_replacer([("bc", "2")]),
      @text.lookup_replacer([("cd", "3")]),
    ]).replace(""),
    "",
  ) // C|chain||
}

// 不落断言的读数（逐条在 spec §1.20 交代，不当"已覆盖"）：
//   腿 L|step 48 条 = 参照 protected 的逐步出口，本库不开放该钩子；
//   腿 B|solo 四档 = 自造 StrReplacer 的返回值形状（含 ret=-1 时驱动循环**永不收敛**那条），
//     没有公开构造点 ⇒ 构造不出对位用例；
//   腿 S|null_input / S|serializable = null 入参与 JDK 序列化面，本库无对位形状。
