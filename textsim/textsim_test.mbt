///|
// textsim 第一批的期望值全部由生成脚本灌入（手打零条），三条腿来源：
//   腿 A `textsim_ref.txt`（524 行）：真 `hutool-core-5.8.35.jar` 的 `cn.hutool.core.text.TextSimilarity`
//     + 本机 JDK 17.0.14，`javac -encoding UTF-8`——公开面 3 件 × 33 组夹具、报错档、locale 档、
//     `formatPercent` 直探针 40 格；
//   腿 B `textsim_ref3.txt`（202 行）：**反射**读三个 `private` 方法 `isValidChar`/`removeSign`/
//     `longestCommonSubstringLength`（`priv.names` 那条读数先把 7 个方法逐个点名，不许猜私有方法存在），
//     并逐条给出分子 `num.N` 与分母 `den.N`；
//   腿 C `textsim_cross.txt`（241 行）：Python `Decimal`（`ROUND_HALF_UP`/`ROUND_HALF_EVEN`）独立实现，
//     生成脚本开头就拿它对撞 A——**任何一格分岔就不出文件**（本批 0 分岔，含 132 格百分比 + 40 格直探针）。
// 串读数一律是 **UTF-16 码元表**（参照侧按 `charAt` 逐位走），脚本配对代理对后写成 `\u{...}` 转义，
// 于是空白和 emoji 不会在文本里看不出来：`lcsu.24|[32]`（一个空格）、`lcsu.30|[55356,57166]`（整个 emoji）。
// 值口径：MoonBit 的 `Char` 是码位、参照的 `char` 是码元——四档区间全在 BMP 内，33 组夹具两侧同值。

///|
// 夹具表：33 组输入串，逐条由腿 A 的 `fx.N.A`/`fx.N.B` 码元读数换算，不许手打
fn fx_a(i : Int) -> String {
  match i {
    1 => ""
    2 => ""
    3 => "a"
    4 => "ab"
    5 => "abc"
    6 => "abcd"
    7 => "ABC"
    8 => "a b c"
    9 => "a,b!c"
    10 => "\u{1f34e}a"
    11 => "\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"
    12 => "\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"
    13 => "\u{4e2d}\u{6587}"
    14 => "12345"
    15 => "ABCBDAB"
    16 => "aXb"
    17 => "banana"
    18 => "\u{ff0c}\u{3002}\u{ff01}\u{4e2d}\u{6587}"
    19 => "hello"
    20 => "abcd"
    21 => "aaa"
    22 => "\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"
    23 => "Java"
    24 => "  "
    25 => "0.5"
    26 => "abcdefgh"
    27 => "abcdefgh"
    28 =>
      "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111"
    29 =>
      "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111"
    30 => "\u{1f34e}x"
    31 => "!!!"
    32 => "a"
    33 =>
      "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbba"
    _ => ""
  }
}

///|
fn fx_b(i : Int) -> String {
  match i {
    1 => ""
    2 => "a"
    3 => "a"
    4 => "ab"
    5 => "axc"
    6 => "bc"
    7 => "abc"
    8 => "abc"
    9 => "abc"
    10 => "a"
    11 => "\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"
    12 => "\u{4e2d}\u{6587}\u{4fa7}\u{8bd5}"
    13 => "\u{6587}\u{4e2d}"
    14 => "135"
    15 => "BDCABA"
    16 => "ab"
    17 => "ananas"
    18 => "\u{4e2d}\u{6587}"
    19 => "hallo"
    20 => "dcba"
    21 => "aa"
    22 => "\u{7528}\u{6237}\u{767b}\u{9646}\u{6210}\u{529f}"
    23 => "JavaScript"
    24 => " "
    25 => "5.0"
    26 => "a"
    27 => "abcde"
    28 => "11111111111111111111111111111"
    29 =>
      "11111111111111111111111111111111111111111111111111111111111111111111111"
    30 => "\u{1f34e}y"
    31 => "???"
    32 => ""
    33 => "a"
    _ => ""
  }
}

///|
// 分母/分子速查（腿 B 反射读数，注释不进断言）：num.1=-1/den.1=0、num.13=1/den.13=2、num.24=-1/den.24=0、num.26=1/den.26=8、num.29=71/den.29=200、num.31=-1/den.31=0、num.33=1/den.33=2048

///|
test "textsim 剥离集：四档区间两端各取一点（腿 B 反射读数）" {
  assert_eq(@textsim.is_valid_char('\u{0009}'), false) // valid.9
  assert_eq(@textsim.is_valid_char('\u{0020}'), false) // valid.20
  assert_eq(@textsim.is_valid_char('\u{002f}'), false) // valid.2f
  assert_eq(@textsim.is_valid_char('\u{0030}'), true) // valid.30
  assert_eq(@textsim.is_valid_char('\u{0039}'), true) // valid.39
  assert_eq(@textsim.is_valid_char('\u{003a}'), false) // valid.3a
  assert_eq(@textsim.is_valid_char('\u{0040}'), false) // valid.40
  assert_eq(@textsim.is_valid_char('\u{0041}'), true) // valid.41
  assert_eq(@textsim.is_valid_char('\u{005a}'), true) // valid.5a
  assert_eq(@textsim.is_valid_char('\u{005b}'), false) // valid.5b
  assert_eq(@textsim.is_valid_char('\u{0060}'), false) // valid.60
  assert_eq(@textsim.is_valid_char('\u{0061}'), true) // valid.61
  assert_eq(@textsim.is_valid_char('\u{007a}'), true) // valid.7a
  assert_eq(@textsim.is_valid_char('\u{007b}'), false) // valid.7b
  assert_eq(@textsim.is_valid_char('\u{00b2}'), false) // valid.b2
  assert_eq(@textsim.is_valid_char('\u{0600}'), false) // valid.600
  assert_eq(@textsim.is_valid_char('\u{2460}'), false) // valid.2460
  assert_eq(@textsim.is_valid_char('\u{3002}'), false) // valid.3002
  assert_eq(@textsim.is_valid_char('\u{3005}'), false) // valid.3005
  assert_eq(@textsim.is_valid_char('\u{3007}'), false) // valid.3007
  assert_eq(@textsim.is_valid_char('\u{30a2}'), false) // valid.30a2
  assert_eq(@textsim.is_valid_char('\u{4dff}'), false) // valid.4dff
  assert_eq(@textsim.is_valid_char('\u{4e00}'), true) // valid.4e00
  assert_eq(@textsim.is_valid_char('\u{4e01}'), true) // valid.4e01
  assert_eq(@textsim.is_valid_char('\u{9fff}'), true) // valid.9fff
  assert_eq(@textsim.is_valid_char('\u{a000}'), false) // valid.a000
  // valid.d83c|false：代理码元作不了 MoonBit 的 `Char`（本库不表示半截代理对），证据留在 spec §3
  // valid.df4e|false：代理码元作不了 MoonBit 的 `Char`（本库不表示半截代理对），证据留在 spec §3
  assert_eq(@textsim.is_valid_char('\u{fe33}'), false) // valid.fe33
  assert_eq(@textsim.is_valid_char('\u{ff0c}'), false) // valid.ff0c
  assert_eq(@textsim.is_valid_char('\u{ff10}'), false) // valid.ff10
  // valid.cp.1f34e|false,false：参照按码元逐位判，代理对两个码元都 false ⇒ 与码位口径同结果
  assert_eq(@textsim.is_valid_char('\u{1f34e}'), false) // valid.cp.1f34e 的两码元
  // 汉字区间的两端、字母两端、数字两端：0x4dff/0x4e00、0x9fff/0xa000、60/61、7a/7b、40/41、5a/5b、2f/30、39/3a
}

///|
test "textsim remove_sign：33 组夹具两侧（腿 B 反射读数 66 条）" {
  assert_eq(@textsim.remove_sign(fx_a(1)), "") // rs.1.A
  assert_eq(@textsim.remove_sign(fx_b(1)), "") // rs.1.B
  assert_eq(@textsim.remove_sign(fx_a(2)), "") // rs.2.A
  assert_eq(@textsim.remove_sign(fx_b(2)), "a") // rs.2.B
  assert_eq(@textsim.remove_sign(fx_a(3)), "a") // rs.3.A
  assert_eq(@textsim.remove_sign(fx_b(3)), "a") // rs.3.B
  assert_eq(@textsim.remove_sign(fx_a(4)), "ab") // rs.4.A
  assert_eq(@textsim.remove_sign(fx_b(4)), "ab") // rs.4.B
  assert_eq(@textsim.remove_sign(fx_a(5)), "abc") // rs.5.A
  assert_eq(@textsim.remove_sign(fx_b(5)), "axc") // rs.5.B
  assert_eq(@textsim.remove_sign(fx_a(6)), "abcd") // rs.6.A
  assert_eq(@textsim.remove_sign(fx_b(6)), "bc") // rs.6.B
  assert_eq(@textsim.remove_sign(fx_a(7)), "ABC") // rs.7.A
  assert_eq(@textsim.remove_sign(fx_b(7)), "abc") // rs.7.B
  assert_eq(@textsim.remove_sign(fx_a(8)), "abc") // rs.8.A
  assert_eq(@textsim.remove_sign(fx_b(8)), "abc") // rs.8.B
  assert_eq(@textsim.remove_sign(fx_a(9)), "abc") // rs.9.A
  assert_eq(@textsim.remove_sign(fx_b(9)), "abc") // rs.9.B
  assert_eq(@textsim.remove_sign(fx_a(10)), "a") // rs.10.A
  assert_eq(@textsim.remove_sign(fx_b(10)), "a") // rs.10.B
  assert_eq(@textsim.remove_sign(fx_a(11)), "\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}") // rs.11.A
  assert_eq(@textsim.remove_sign(fx_b(11)), "\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}") // rs.11.B
  assert_eq(@textsim.remove_sign(fx_a(12)), "\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}") // rs.12.A
  assert_eq(@textsim.remove_sign(fx_b(12)), "\u{4e2d}\u{6587}\u{4fa7}\u{8bd5}") // rs.12.B
  assert_eq(@textsim.remove_sign(fx_a(13)), "\u{4e2d}\u{6587}") // rs.13.A
  assert_eq(@textsim.remove_sign(fx_b(13)), "\u{6587}\u{4e2d}") // rs.13.B
  assert_eq(@textsim.remove_sign(fx_a(14)), "12345") // rs.14.A
  assert_eq(@textsim.remove_sign(fx_b(14)), "135") // rs.14.B
  assert_eq(@textsim.remove_sign(fx_a(15)), "ABCBDAB") // rs.15.A
  assert_eq(@textsim.remove_sign(fx_b(15)), "BDCABA") // rs.15.B
  assert_eq(@textsim.remove_sign(fx_a(16)), "aXb") // rs.16.A
  assert_eq(@textsim.remove_sign(fx_b(16)), "ab") // rs.16.B
  assert_eq(@textsim.remove_sign(fx_a(17)), "banana") // rs.17.A
  assert_eq(@textsim.remove_sign(fx_b(17)), "ananas") // rs.17.B
  assert_eq(@textsim.remove_sign(fx_a(18)), "\u{4e2d}\u{6587}") // rs.18.A
  assert_eq(@textsim.remove_sign(fx_b(18)), "\u{4e2d}\u{6587}") // rs.18.B
  assert_eq(@textsim.remove_sign(fx_a(19)), "hello") // rs.19.A
  assert_eq(@textsim.remove_sign(fx_b(19)), "hallo") // rs.19.B
  assert_eq(@textsim.remove_sign(fx_a(20)), "abcd") // rs.20.A
  assert_eq(@textsim.remove_sign(fx_b(20)), "dcba") // rs.20.B
  assert_eq(@textsim.remove_sign(fx_a(21)), "aaa") // rs.21.A
  assert_eq(@textsim.remove_sign(fx_b(21)), "aa") // rs.21.B
  assert_eq(
    @textsim.remove_sign(fx_a(22)),
    "\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}",
  ) // rs.22.A
  assert_eq(
    @textsim.remove_sign(fx_b(22)),
    "\u{7528}\u{6237}\u{767b}\u{9646}\u{6210}\u{529f}",
  ) // rs.22.B
  assert_eq(@textsim.remove_sign(fx_a(23)), "Java") // rs.23.A
  assert_eq(@textsim.remove_sign(fx_b(23)), "JavaScript") // rs.23.B
  assert_eq(@textsim.remove_sign(fx_a(24)), "") // rs.24.A
  assert_eq(@textsim.remove_sign(fx_b(24)), "") // rs.24.B
  assert_eq(@textsim.remove_sign(fx_a(25)), "05") // rs.25.A
  assert_eq(@textsim.remove_sign(fx_b(25)), "50") // rs.25.B
  assert_eq(@textsim.remove_sign(fx_a(26)), "abcdefgh") // rs.26.A
  assert_eq(@textsim.remove_sign(fx_b(26)), "a") // rs.26.B
  assert_eq(@textsim.remove_sign(fx_a(27)), "abcdefgh") // rs.27.A
  assert_eq(@textsim.remove_sign(fx_b(27)), "abcde") // rs.27.B
  assert_eq(
    @textsim.remove_sign(fx_a(28)),
    "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111",
  ) // rs.28.A
  assert_eq(@textsim.remove_sign(fx_b(28)), "11111111111111111111111111111") // rs.28.B
  assert_eq(
    @textsim.remove_sign(fx_a(29)),
    "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111",
  ) // rs.29.A
  assert_eq(
    @textsim.remove_sign(fx_b(29)),
    "11111111111111111111111111111111111111111111111111111111111111111111111",
  ) // rs.29.B
  assert_eq(@textsim.remove_sign(fx_a(30)), "x") // rs.30.A
  assert_eq(@textsim.remove_sign(fx_b(30)), "y") // rs.30.B
  assert_eq(@textsim.remove_sign(fx_a(31)), "") // rs.31.A
  assert_eq(@textsim.remove_sign(fx_b(31)), "") // rs.31.B
  assert_eq(@textsim.remove_sign(fx_a(32)), "a") // rs.32.A
  assert_eq(@textsim.remove_sign(fx_b(32)), "") // rs.32.B
  assert_eq(
    @textsim.remove_sign(fx_a(33)),
    "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbba",
  ) // rs.33.A
  assert_eq(@textsim.remove_sign(fx_b(33)), "a") // rs.33.B
}

///|
test "textsim 子序列：不剥离、回溯择路、两侧不对称（腿 A 码元读数 66 条）" {
  assert_eq(@textsim.longest_common_subsequence(fx_a(1), fx_b(1)), "") // lcsu.1
  assert_eq(@textsim.longest_common_subsequence(fx_b(1), fx_a(1)), "") // lcsu.rev.1
  assert_eq(@textsim.longest_common_subsequence(fx_a(2), fx_b(2)), "") // lcsu.2
  assert_eq(@textsim.longest_common_subsequence(fx_b(2), fx_a(2)), "") // lcsu.rev.2
  assert_eq(@textsim.longest_common_subsequence(fx_a(3), fx_b(3)), "a") // lcsu.3
  assert_eq(@textsim.longest_common_subsequence(fx_b(3), fx_a(3)), "a") // lcsu.rev.3
  assert_eq(@textsim.longest_common_subsequence(fx_a(4), fx_b(4)), "ab") // lcsu.4
  assert_eq(@textsim.longest_common_subsequence(fx_b(4), fx_a(4)), "ab") // lcsu.rev.4
  assert_eq(@textsim.longest_common_subsequence(fx_a(5), fx_b(5)), "ac") // lcsu.5
  assert_eq(@textsim.longest_common_subsequence(fx_b(5), fx_a(5)), "ac") // lcsu.rev.5
  assert_eq(@textsim.longest_common_subsequence(fx_a(6), fx_b(6)), "bc") // lcsu.6
  assert_eq(@textsim.longest_common_subsequence(fx_b(6), fx_a(6)), "bc") // lcsu.rev.6
  assert_eq(@textsim.longest_common_subsequence(fx_a(7), fx_b(7)), "") // lcsu.7
  assert_eq(@textsim.longest_common_subsequence(fx_b(7), fx_a(7)), "") // lcsu.rev.7
  assert_eq(@textsim.longest_common_subsequence(fx_a(8), fx_b(8)), "abc") // lcsu.8
  assert_eq(@textsim.longest_common_subsequence(fx_b(8), fx_a(8)), "abc") // lcsu.rev.8
  assert_eq(@textsim.longest_common_subsequence(fx_a(9), fx_b(9)), "abc") // lcsu.9
  assert_eq(@textsim.longest_common_subsequence(fx_b(9), fx_a(9)), "abc") // lcsu.rev.9
  assert_eq(@textsim.longest_common_subsequence(fx_a(10), fx_b(10)), "a") // lcsu.10
  assert_eq(@textsim.longest_common_subsequence(fx_b(10), fx_a(10)), "a") // lcsu.rev.10
  assert_eq(
    @textsim.longest_common_subsequence(fx_a(11), fx_b(11)),
    "\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}",
  ) // lcsu.11
  assert_eq(
    @textsim.longest_common_subsequence(fx_b(11), fx_a(11)),
    "\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}",
  ) // lcsu.rev.11
  assert_eq(
    @textsim.longest_common_subsequence(fx_a(12), fx_b(12)),
    "\u{4e2d}\u{6587}\u{8bd5}",
  ) // lcsu.12
  assert_eq(
    @textsim.longest_common_subsequence(fx_b(12), fx_a(12)),
    "\u{4e2d}\u{6587}\u{8bd5}",
  ) // lcsu.rev.12
  assert_eq(@textsim.longest_common_subsequence(fx_a(13), fx_b(13)), "\u{6587}") // lcsu.13
  assert_eq(@textsim.longest_common_subsequence(fx_b(13), fx_a(13)), "\u{4e2d}") // lcsu.rev.13
  assert_eq(@textsim.longest_common_subsequence(fx_a(14), fx_b(14)), "135") // lcsu.14
  assert_eq(@textsim.longest_common_subsequence(fx_b(14), fx_a(14)), "135") // lcsu.rev.14
  assert_eq(@textsim.longest_common_subsequence(fx_a(15), fx_b(15)), "BDAB") // lcsu.15
  assert_eq(@textsim.longest_common_subsequence(fx_b(15), fx_a(15)), "BCBA") // lcsu.rev.15
  assert_eq(@textsim.longest_common_subsequence(fx_a(16), fx_b(16)), "ab") // lcsu.16
  assert_eq(@textsim.longest_common_subsequence(fx_b(16), fx_a(16)), "ab") // lcsu.rev.16
  assert_eq(@textsim.longest_common_subsequence(fx_a(17), fx_b(17)), "anana") // lcsu.17
  assert_eq(@textsim.longest_common_subsequence(fx_b(17), fx_a(17)), "anana") // lcsu.rev.17
  assert_eq(
    @textsim.longest_common_subsequence(fx_a(18), fx_b(18)),
    "\u{4e2d}\u{6587}",
  ) // lcsu.18
  assert_eq(
    @textsim.longest_common_subsequence(fx_b(18), fx_a(18)),
    "\u{4e2d}\u{6587}",
  ) // lcsu.rev.18
  assert_eq(@textsim.longest_common_subsequence(fx_a(19), fx_b(19)), "hllo") // lcsu.19
  assert_eq(@textsim.longest_common_subsequence(fx_b(19), fx_a(19)), "hllo") // lcsu.rev.19
  assert_eq(@textsim.longest_common_subsequence(fx_a(20), fx_b(20)), "d") // lcsu.20
  assert_eq(@textsim.longest_common_subsequence(fx_b(20), fx_a(20)), "a") // lcsu.rev.20
  assert_eq(@textsim.longest_common_subsequence(fx_a(21), fx_b(21)), "aa") // lcsu.21
  assert_eq(@textsim.longest_common_subsequence(fx_b(21), fx_a(21)), "aa") // lcsu.rev.21
  assert_eq(
    @textsim.longest_common_subsequence(fx_a(22), fx_b(22)),
    "\u{7528}\u{6237}\u{767b}\u{6210}\u{529f}",
  ) // lcsu.22
  assert_eq(
    @textsim.longest_common_subsequence(fx_b(22), fx_a(22)),
    "\u{7528}\u{6237}\u{767b}\u{6210}\u{529f}",
  ) // lcsu.rev.22
  assert_eq(@textsim.longest_common_subsequence(fx_a(23), fx_b(23)), "Java") // lcsu.23
  assert_eq(@textsim.longest_common_subsequence(fx_b(23), fx_a(23)), "Java") // lcsu.rev.23
  assert_eq(@textsim.longest_common_subsequence(fx_a(24), fx_b(24)), " ") // lcsu.24
  assert_eq(@textsim.longest_common_subsequence(fx_b(24), fx_a(24)), " ") // lcsu.rev.24
  assert_eq(@textsim.longest_common_subsequence(fx_a(25), fx_b(25)), "5") // lcsu.25
  assert_eq(@textsim.longest_common_subsequence(fx_b(25), fx_a(25)), "0") // lcsu.rev.25
  assert_eq(@textsim.longest_common_subsequence(fx_a(26), fx_b(26)), "a") // lcsu.26
  assert_eq(@textsim.longest_common_subsequence(fx_b(26), fx_a(26)), "a") // lcsu.rev.26
  assert_eq(@textsim.longest_common_subsequence(fx_a(27), fx_b(27)), "abcde") // lcsu.27
  assert_eq(@textsim.longest_common_subsequence(fx_b(27), fx_a(27)), "abcde") // lcsu.rev.27
  assert_eq(
    @textsim.longest_common_subsequence(fx_a(28), fx_b(28)),
    "11111111111111111111111111111",
  ) // lcsu.28
  assert_eq(
    @textsim.longest_common_subsequence(fx_b(28), fx_a(28)),
    "11111111111111111111111111111",
  ) // lcsu.rev.28
  assert_eq(
    @textsim.longest_common_subsequence(fx_a(29), fx_b(29)),
    "11111111111111111111111111111111111111111111111111111111111111111111111",
  ) // lcsu.29
  assert_eq(
    @textsim.longest_common_subsequence(fx_b(29), fx_a(29)),
    "11111111111111111111111111111111111111111111111111111111111111111111111",
  ) // lcsu.rev.29
  assert_eq(
    @textsim.longest_common_subsequence(fx_a(30), fx_b(30)),
    "\u{1f34e}",
  ) // lcsu.30
  assert_eq(
    @textsim.longest_common_subsequence(fx_b(30), fx_a(30)),
    "\u{1f34e}",
  ) // lcsu.rev.30
  assert_eq(@textsim.longest_common_subsequence(fx_a(31), fx_b(31)), "") // lcsu.31
  assert_eq(@textsim.longest_common_subsequence(fx_b(31), fx_a(31)), "") // lcsu.rev.31
  assert_eq(@textsim.longest_common_subsequence(fx_a(32), fx_b(32)), "") // lcsu.32
  assert_eq(@textsim.longest_common_subsequence(fx_b(32), fx_a(32)), "") // lcsu.rev.32
  assert_eq(@textsim.longest_common_subsequence(fx_a(33), fx_b(33)), "a") // lcsu.33
  assert_eq(@textsim.longest_common_subsequence(fx_b(33), fx_a(33)), "a") // lcsu.rev.33
  // 公开面**不剥离**：`"  "` 与 `" "` 给一个空格（`nostrip.proof.A|[32]`、长度 `nostrip.proof.B|1`），
  // 而 #20.4 走剥离路径对同一条夹具给 1.0（`strip.sim.B|1.0`）——两条读数并排就是这两条路径的分工
}

///|
test "textsim similar：33 组两侧（腿 A double 读数 66 条，分子分母见腿 B）" {
  assert_eq(@textsim.similar(fx_a(1), fx_b(1)), 1.0) // sim.1
  assert_eq(@textsim.similar(fx_b(1), fx_a(1)), 1.0) // sim.rev.1
  assert_eq(@textsim.similar(fx_a(2), fx_b(2)), 0.0) // sim.2
  assert_eq(@textsim.similar(fx_b(2), fx_a(2)), 0.0) // sim.rev.2
  assert_eq(@textsim.similar(fx_a(3), fx_b(3)), 1.0) // sim.3
  assert_eq(@textsim.similar(fx_b(3), fx_a(3)), 1.0) // sim.rev.3
  assert_eq(@textsim.similar(fx_a(4), fx_b(4)), 1.0) // sim.4
  assert_eq(@textsim.similar(fx_b(4), fx_a(4)), 1.0) // sim.rev.4
  assert_eq(@textsim.similar(fx_a(5), fx_b(5)), 0.6666666667) // sim.5
  assert_eq(@textsim.similar(fx_b(5), fx_a(5)), 0.6666666667) // sim.rev.5
  assert_eq(@textsim.similar(fx_a(6), fx_b(6)), 0.5) // sim.6
  assert_eq(@textsim.similar(fx_b(6), fx_a(6)), 0.5) // sim.rev.6
  assert_eq(@textsim.similar(fx_a(7), fx_b(7)), 0.0) // sim.7
  assert_eq(@textsim.similar(fx_b(7), fx_a(7)), 0.0) // sim.rev.7
  assert_eq(@textsim.similar(fx_a(8), fx_b(8)), 1.0) // sim.8
  assert_eq(@textsim.similar(fx_b(8), fx_a(8)), 1.0) // sim.rev.8
  assert_eq(@textsim.similar(fx_a(9), fx_b(9)), 1.0) // sim.9
  assert_eq(@textsim.similar(fx_b(9), fx_a(9)), 1.0) // sim.rev.9
  assert_eq(@textsim.similar(fx_a(10), fx_b(10)), 1.0) // sim.10
  assert_eq(@textsim.similar(fx_b(10), fx_a(10)), 1.0) // sim.rev.10
  assert_eq(@textsim.similar(fx_a(11), fx_b(11)), 1.0) // sim.11
  assert_eq(@textsim.similar(fx_b(11), fx_a(11)), 1.0) // sim.rev.11
  assert_eq(@textsim.similar(fx_a(12), fx_b(12)), 0.75) // sim.12
  assert_eq(@textsim.similar(fx_b(12), fx_a(12)), 0.75) // sim.rev.12
  assert_eq(@textsim.similar(fx_a(13), fx_b(13)), 0.5) // sim.13
  assert_eq(@textsim.similar(fx_b(13), fx_a(13)), 0.5) // sim.rev.13
  assert_eq(@textsim.similar(fx_a(14), fx_b(14)), 0.6) // sim.14
  assert_eq(@textsim.similar(fx_b(14), fx_a(14)), 0.6) // sim.rev.14
  assert_eq(@textsim.similar(fx_a(15), fx_b(15)), 0.5714285714) // sim.15
  assert_eq(@textsim.similar(fx_b(15), fx_a(15)), 0.5714285714) // sim.rev.15
  assert_eq(@textsim.similar(fx_a(16), fx_b(16)), 0.6666666667) // sim.16
  assert_eq(@textsim.similar(fx_b(16), fx_a(16)), 0.6666666667) // sim.rev.16
  assert_eq(@textsim.similar(fx_a(17), fx_b(17)), 0.8333333333) // sim.17
  assert_eq(@textsim.similar(fx_b(17), fx_a(17)), 0.8333333333) // sim.rev.17
  assert_eq(@textsim.similar(fx_a(18), fx_b(18)), 1.0) // sim.18
  assert_eq(@textsim.similar(fx_b(18), fx_a(18)), 1.0) // sim.rev.18
  assert_eq(@textsim.similar(fx_a(19), fx_b(19)), 0.8) // sim.19
  assert_eq(@textsim.similar(fx_b(19), fx_a(19)), 0.8) // sim.rev.19
  assert_eq(@textsim.similar(fx_a(20), fx_b(20)), 0.25) // sim.20
  assert_eq(@textsim.similar(fx_b(20), fx_a(20)), 0.25) // sim.rev.20
  assert_eq(@textsim.similar(fx_a(21), fx_b(21)), 0.6666666667) // sim.21
  assert_eq(@textsim.similar(fx_b(21), fx_a(21)), 0.6666666667) // sim.rev.21
  assert_eq(@textsim.similar(fx_a(22), fx_b(22)), 0.8333333333) // sim.22
  assert_eq(@textsim.similar(fx_b(22), fx_a(22)), 0.8333333333) // sim.rev.22
  assert_eq(@textsim.similar(fx_a(23), fx_b(23)), 0.4) // sim.23
  assert_eq(@textsim.similar(fx_b(23), fx_a(23)), 0.4) // sim.rev.23
  assert_eq(@textsim.similar(fx_a(24), fx_b(24)), 1.0) // sim.24
  assert_eq(@textsim.similar(fx_b(24), fx_a(24)), 1.0) // sim.rev.24
  assert_eq(@textsim.similar(fx_a(25), fx_b(25)), 0.5) // sim.25
  assert_eq(@textsim.similar(fx_b(25), fx_a(25)), 0.5) // sim.rev.25
  assert_eq(@textsim.similar(fx_a(26), fx_b(26)), 0.125) // sim.26
  assert_eq(@textsim.similar(fx_b(26), fx_a(26)), 0.125) // sim.rev.26
  assert_eq(@textsim.similar(fx_a(27), fx_b(27)), 0.625) // sim.27
  assert_eq(@textsim.similar(fx_b(27), fx_a(27)), 0.625) // sim.rev.27
  assert_eq(@textsim.similar(fx_a(28), fx_b(28)), 0.145) // sim.28
  assert_eq(@textsim.similar(fx_b(28), fx_a(28)), 0.145) // sim.rev.28
  assert_eq(@textsim.similar(fx_a(29), fx_b(29)), 0.355) // sim.29
  assert_eq(@textsim.similar(fx_b(29), fx_a(29)), 0.355) // sim.rev.29
  assert_eq(@textsim.similar(fx_a(30), fx_b(30)), 0.0) // sim.30
  assert_eq(@textsim.similar(fx_b(30), fx_a(30)), 0.0) // sim.rev.30
  assert_eq(@textsim.similar(fx_a(31), fx_b(31)), 1.0) // sim.31
  assert_eq(@textsim.similar(fx_b(31), fx_a(31)), 1.0) // sim.rev.31
  assert_eq(@textsim.similar(fx_a(32), fx_b(32)), 0.0) // sim.32
  assert_eq(@textsim.similar(fx_b(32), fx_a(32)), 0.0) // sim.rev.32
  assert_eq(@textsim.similar(fx_a(33), fx_b(33)), 0.0004882813) // sim.33
  assert_eq(@textsim.similar(fx_b(33), fx_a(33)), 0.0004882813) // sim.rev.33
}

///|
test "textsim 特殊档：空分母、大小写敏感、分母取较大者、第 10 位 HALF_UP" {
  // 两侧剥离后都是空串 ⇒ 1.0（参照源码 `if (0 == temp) return 1`）：sim.1 / sim.24 / sim.31 三条
  assert_eq(@textsim.similar(fx_a(1), fx_b(1)), 1.0) // sim.1
  assert_eq(@textsim.similar(fx_a(24), fx_b(24)), 1.0) // sim.24
  assert_eq(@textsim.similar(fx_a(31), fx_b(31)), 1.0) // sim.31
  // 分母是**剥离后的较大长度**：a b c（原始 5 码元）对 abc 给 3/3=1.0 而不是 3/5
  assert_eq(@textsim.similar(fx_a(8), fx_b(8)), 1.0) // strip.denom.proof.1
  assert_eq(@textsim.similar(fx_a(16), fx_b(16)), 0.6666666667) // strip.denom.proof.2
  // emoji 整码位剥掉：🍎 对空串 ⇒ 两侧都空 ⇒ 1.0
  assert_eq(@textsim.similar("\u{1f34e}", ""), 1.0) // strip.denom.proof.3
  // 顺序无关（分母取较大者而不是取第一个）：同一条夹具换个方向喂
  assert_eq(@textsim.similar("a", "abcdefgh"), 0.125) // den.swap.proof
  // 第 10 位是 tie：1/2048 = 0.00048828125 ⇒ HALF_UP 给 4.882813E-4（裸商读数 4.8828125E-4 并列作证据）
  assert_eq(@textsim.similar(fx_a(33), fx_b(33)), 0.0004882813) // div.tie.2048 = sim.33
  assert_eq(@textsim.similar(fx_a(7), fx_b(7)), 0.0) // sim.7（大小写敏感）
  // 参照侧收 null 直接 NPE（`exc.sim.null`/`exc.sim.null2`），MoonBit 的 String 不可空 ⇒ 该档不可表示
}

///|
test "textsim 百分比：33 组 × {0,1,2,10}（腿 A 码元读数 132 条）" {
  assert_eq(@textsim.similar_percent(fx_a(1), fx_b(1), 0), "100%") // pct.1.0
  assert_eq(@textsim.similar_percent(fx_a(1), fx_b(1), 1), "100%") // pct.1.1
  assert_eq(@textsim.similar_percent(fx_a(1), fx_b(1), 2), "100%") // pct.1.2
  assert_eq(@textsim.similar_percent(fx_a(1), fx_b(1), 10), "100%") // pct.1.10
  assert_eq(@textsim.similar_percent(fx_a(2), fx_b(2), 0), "0%") // pct.2.0
  assert_eq(@textsim.similar_percent(fx_a(2), fx_b(2), 1), "0%") // pct.2.1
  assert_eq(@textsim.similar_percent(fx_a(2), fx_b(2), 2), "0%") // pct.2.2
  assert_eq(@textsim.similar_percent(fx_a(2), fx_b(2), 10), "0%") // pct.2.10
  assert_eq(@textsim.similar_percent(fx_a(3), fx_b(3), 0), "100%") // pct.3.0
  assert_eq(@textsim.similar_percent(fx_a(3), fx_b(3), 1), "100%") // pct.3.1
  assert_eq(@textsim.similar_percent(fx_a(3), fx_b(3), 2), "100%") // pct.3.2
  assert_eq(@textsim.similar_percent(fx_a(3), fx_b(3), 10), "100%") // pct.3.10
  // §6「负 scale 不再夹成 0」那条等价变形的补强夹具：非 tie 值才钉得住。
  // 腿新读（TextSimNeg.java，真 hutool-core 5.8.35 + JDK 17.0.14）：参照在 scale=-1/-2 上给的是
  // `OK:67%` 而不是推导以为的 `70%`（`DecimalFormat` 拿到负的最大小数位当作不限制），
  // 所以这几条钉的是「本库与参照在非 tie 夹具上同值」，夹 0 与不夹 0 谁输谁赢交给下面的变异重跑说话。
  assert_eq(@textsim.similar_percent("abc", "axc", -1), "67%") // neg.-1|OK:67%
  assert_eq(@textsim.similar_percent("abc", "axc", -2), "67%") // neg.-2|OK:67%
  assert_eq(@textsim.similar_percent("abc", "axc", 0), "67%") // neg.0|OK:67%
  assert_eq(@textsim.similar_percent("ab", "abc", -1), "67%") // neg.swap|OK:67%
  assert_eq(@textsim.similar_percent(fx_a(4), fx_b(4), 0), "100%") // pct.4.0
  assert_eq(@textsim.similar_percent(fx_a(4), fx_b(4), 1), "100%") // pct.4.1
  assert_eq(@textsim.similar_percent(fx_a(4), fx_b(4), 2), "100%") // pct.4.2
  assert_eq(@textsim.similar_percent(fx_a(4), fx_b(4), 10), "100%") // pct.4.10
  assert_eq(@textsim.similar_percent(fx_a(5), fx_b(5), 0), "67%") // pct.5.0
  assert_eq(@textsim.similar_percent(fx_a(5), fx_b(5), 1), "66.7%") // pct.5.1
  assert_eq(@textsim.similar_percent(fx_a(5), fx_b(5), 2), "66.67%") // pct.5.2
  assert_eq(@textsim.similar_percent(fx_a(5), fx_b(5), 10), "66.66666667%") // pct.5.10
  assert_eq(@textsim.similar_percent(fx_a(6), fx_b(6), 0), "50%") // pct.6.0
  assert_eq(@textsim.similar_percent(fx_a(6), fx_b(6), 1), "50%") // pct.6.1
  assert_eq(@textsim.similar_percent(fx_a(6), fx_b(6), 2), "50%") // pct.6.2
  assert_eq(@textsim.similar_percent(fx_a(6), fx_b(6), 10), "50%") // pct.6.10
  assert_eq(@textsim.similar_percent(fx_a(7), fx_b(7), 0), "0%") // pct.7.0
  assert_eq(@textsim.similar_percent(fx_a(7), fx_b(7), 1), "0%") // pct.7.1
  assert_eq(@textsim.similar_percent(fx_a(7), fx_b(7), 2), "0%") // pct.7.2
  assert_eq(@textsim.similar_percent(fx_a(7), fx_b(7), 10), "0%") // pct.7.10
  assert_eq(@textsim.similar_percent(fx_a(8), fx_b(8), 0), "100%") // pct.8.0
  assert_eq(@textsim.similar_percent(fx_a(8), fx_b(8), 1), "100%") // pct.8.1
  assert_eq(@textsim.similar_percent(fx_a(8), fx_b(8), 2), "100%") // pct.8.2
  assert_eq(@textsim.similar_percent(fx_a(8), fx_b(8), 10), "100%") // pct.8.10
  assert_eq(@textsim.similar_percent(fx_a(9), fx_b(9), 0), "100%") // pct.9.0
  assert_eq(@textsim.similar_percent(fx_a(9), fx_b(9), 1), "100%") // pct.9.1
  assert_eq(@textsim.similar_percent(fx_a(9), fx_b(9), 2), "100%") // pct.9.2
  assert_eq(@textsim.similar_percent(fx_a(9), fx_b(9), 10), "100%") // pct.9.10
  assert_eq(@textsim.similar_percent(fx_a(10), fx_b(10), 0), "100%") // pct.10.0
  assert_eq(@textsim.similar_percent(fx_a(10), fx_b(10), 1), "100%") // pct.10.1
  assert_eq(@textsim.similar_percent(fx_a(10), fx_b(10), 2), "100%") // pct.10.2
  assert_eq(@textsim.similar_percent(fx_a(10), fx_b(10), 10), "100%") // pct.10.10
  assert_eq(@textsim.similar_percent(fx_a(11), fx_b(11), 0), "100%") // pct.11.0
  assert_eq(@textsim.similar_percent(fx_a(11), fx_b(11), 1), "100%") // pct.11.1
  assert_eq(@textsim.similar_percent(fx_a(11), fx_b(11), 2), "100%") // pct.11.2
  assert_eq(@textsim.similar_percent(fx_a(11), fx_b(11), 10), "100%") // pct.11.10
  assert_eq(@textsim.similar_percent(fx_a(12), fx_b(12), 0), "75%") // pct.12.0
  assert_eq(@textsim.similar_percent(fx_a(12), fx_b(12), 1), "75%") // pct.12.1
  assert_eq(@textsim.similar_percent(fx_a(12), fx_b(12), 2), "75%") // pct.12.2
  assert_eq(@textsim.similar_percent(fx_a(12), fx_b(12), 10), "75%") // pct.12.10
  assert_eq(@textsim.similar_percent(fx_a(13), fx_b(13), 0), "50%") // pct.13.0
  assert_eq(@textsim.similar_percent(fx_a(13), fx_b(13), 1), "50%") // pct.13.1
  assert_eq(@textsim.similar_percent(fx_a(13), fx_b(13), 2), "50%") // pct.13.2
  assert_eq(@textsim.similar_percent(fx_a(13), fx_b(13), 10), "50%") // pct.13.10
  assert_eq(@textsim.similar_percent(fx_a(14), fx_b(14), 0), "60%") // pct.14.0
  assert_eq(@textsim.similar_percent(fx_a(14), fx_b(14), 1), "60%") // pct.14.1
  assert_eq(@textsim.similar_percent(fx_a(14), fx_b(14), 2), "60%") // pct.14.2
  assert_eq(@textsim.similar_percent(fx_a(14), fx_b(14), 10), "60%") // pct.14.10
  assert_eq(@textsim.similar_percent(fx_a(15), fx_b(15), 0), "57%") // pct.15.0
  assert_eq(@textsim.similar_percent(fx_a(15), fx_b(15), 1), "57.1%") // pct.15.1
  assert_eq(@textsim.similar_percent(fx_a(15), fx_b(15), 2), "57.14%") // pct.15.2
  assert_eq(@textsim.similar_percent(fx_a(15), fx_b(15), 10), "57.14285714%") // pct.15.10
  assert_eq(@textsim.similar_percent(fx_a(16), fx_b(16), 0), "67%") // pct.16.0
  assert_eq(@textsim.similar_percent(fx_a(16), fx_b(16), 1), "66.7%") // pct.16.1
  assert_eq(@textsim.similar_percent(fx_a(16), fx_b(16), 2), "66.67%") // pct.16.2
  assert_eq(@textsim.similar_percent(fx_a(16), fx_b(16), 10), "66.66666667%") // pct.16.10
  assert_eq(@textsim.similar_percent(fx_a(17), fx_b(17), 0), "83%") // pct.17.0
  assert_eq(@textsim.similar_percent(fx_a(17), fx_b(17), 1), "83.3%") // pct.17.1
  assert_eq(@textsim.similar_percent(fx_a(17), fx_b(17), 2), "83.33%") // pct.17.2
  assert_eq(@textsim.similar_percent(fx_a(17), fx_b(17), 10), "83.33333333%") // pct.17.10
  assert_eq(@textsim.similar_percent(fx_a(18), fx_b(18), 0), "100%") // pct.18.0
  assert_eq(@textsim.similar_percent(fx_a(18), fx_b(18), 1), "100%") // pct.18.1
  assert_eq(@textsim.similar_percent(fx_a(18), fx_b(18), 2), "100%") // pct.18.2
  assert_eq(@textsim.similar_percent(fx_a(18), fx_b(18), 10), "100%") // pct.18.10
  assert_eq(@textsim.similar_percent(fx_a(19), fx_b(19), 0), "80%") // pct.19.0
  assert_eq(@textsim.similar_percent(fx_a(19), fx_b(19), 1), "80%") // pct.19.1
  assert_eq(@textsim.similar_percent(fx_a(19), fx_b(19), 2), "80%") // pct.19.2
  assert_eq(@textsim.similar_percent(fx_a(19), fx_b(19), 10), "80%") // pct.19.10
  assert_eq(@textsim.similar_percent(fx_a(20), fx_b(20), 0), "25%") // pct.20.0
  assert_eq(@textsim.similar_percent(fx_a(20), fx_b(20), 1), "25%") // pct.20.1
  assert_eq(@textsim.similar_percent(fx_a(20), fx_b(20), 2), "25%") // pct.20.2
  assert_eq(@textsim.similar_percent(fx_a(20), fx_b(20), 10), "25%") // pct.20.10
  assert_eq(@textsim.similar_percent(fx_a(21), fx_b(21), 0), "67%") // pct.21.0
  assert_eq(@textsim.similar_percent(fx_a(21), fx_b(21), 1), "66.7%") // pct.21.1
  assert_eq(@textsim.similar_percent(fx_a(21), fx_b(21), 2), "66.67%") // pct.21.2
  assert_eq(@textsim.similar_percent(fx_a(21), fx_b(21), 10), "66.66666667%") // pct.21.10
  assert_eq(@textsim.similar_percent(fx_a(22), fx_b(22), 0), "83%") // pct.22.0
  assert_eq(@textsim.similar_percent(fx_a(22), fx_b(22), 1), "83.3%") // pct.22.1
  assert_eq(@textsim.similar_percent(fx_a(22), fx_b(22), 2), "83.33%") // pct.22.2
  assert_eq(@textsim.similar_percent(fx_a(22), fx_b(22), 10), "83.33333333%") // pct.22.10
  assert_eq(@textsim.similar_percent(fx_a(23), fx_b(23), 0), "40%") // pct.23.0
  assert_eq(@textsim.similar_percent(fx_a(23), fx_b(23), 1), "40%") // pct.23.1
  assert_eq(@textsim.similar_percent(fx_a(23), fx_b(23), 2), "40%") // pct.23.2
  assert_eq(@textsim.similar_percent(fx_a(23), fx_b(23), 10), "40%") // pct.23.10
  assert_eq(@textsim.similar_percent(fx_a(24), fx_b(24), 0), "100%") // pct.24.0
  assert_eq(@textsim.similar_percent(fx_a(24), fx_b(24), 1), "100%") // pct.24.1
  assert_eq(@textsim.similar_percent(fx_a(24), fx_b(24), 2), "100%") // pct.24.2
  assert_eq(@textsim.similar_percent(fx_a(24), fx_b(24), 10), "100%") // pct.24.10
  assert_eq(@textsim.similar_percent(fx_a(25), fx_b(25), 0), "50%") // pct.25.0
  assert_eq(@textsim.similar_percent(fx_a(25), fx_b(25), 1), "50%") // pct.25.1
  assert_eq(@textsim.similar_percent(fx_a(25), fx_b(25), 2), "50%") // pct.25.2
  assert_eq(@textsim.similar_percent(fx_a(25), fx_b(25), 10), "50%") // pct.25.10
  assert_eq(@textsim.similar_percent(fx_a(26), fx_b(26), 0), "12%") // pct.26.0
  assert_eq(@textsim.similar_percent(fx_a(26), fx_b(26), 1), "12.5%") // pct.26.1
  assert_eq(@textsim.similar_percent(fx_a(26), fx_b(26), 2), "12.5%") // pct.26.2
  assert_eq(@textsim.similar_percent(fx_a(26), fx_b(26), 10), "12.5%") // pct.26.10
  assert_eq(@textsim.similar_percent(fx_a(27), fx_b(27), 0), "62%") // pct.27.0
  assert_eq(@textsim.similar_percent(fx_a(27), fx_b(27), 1), "62.5%") // pct.27.1
  assert_eq(@textsim.similar_percent(fx_a(27), fx_b(27), 2), "62.5%") // pct.27.2
  assert_eq(@textsim.similar_percent(fx_a(27), fx_b(27), 10), "62.5%") // pct.27.10
  assert_eq(@textsim.similar_percent(fx_a(28), fx_b(28), 0), "14%") // pct.28.0
  assert_eq(@textsim.similar_percent(fx_a(28), fx_b(28), 1), "14.5%") // pct.28.1
  assert_eq(@textsim.similar_percent(fx_a(28), fx_b(28), 2), "14.5%") // pct.28.2
  assert_eq(@textsim.similar_percent(fx_a(28), fx_b(28), 10), "14.5%") // pct.28.10
  assert_eq(@textsim.similar_percent(fx_a(29), fx_b(29), 0), "36%") // pct.29.0
  assert_eq(@textsim.similar_percent(fx_a(29), fx_b(29), 1), "35.5%") // pct.29.1
  assert_eq(@textsim.similar_percent(fx_a(29), fx_b(29), 2), "35.5%") // pct.29.2
  assert_eq(@textsim.similar_percent(fx_a(29), fx_b(29), 10), "35.5%") // pct.29.10
  assert_eq(@textsim.similar_percent(fx_a(30), fx_b(30), 0), "0%") // pct.30.0
  assert_eq(@textsim.similar_percent(fx_a(30), fx_b(30), 1), "0%") // pct.30.1
  assert_eq(@textsim.similar_percent(fx_a(30), fx_b(30), 2), "0%") // pct.30.2
  assert_eq(@textsim.similar_percent(fx_a(30), fx_b(30), 10), "0%") // pct.30.10
  assert_eq(@textsim.similar_percent(fx_a(31), fx_b(31), 0), "100%") // pct.31.0
  assert_eq(@textsim.similar_percent(fx_a(31), fx_b(31), 1), "100%") // pct.31.1
  assert_eq(@textsim.similar_percent(fx_a(31), fx_b(31), 2), "100%") // pct.31.2
  assert_eq(@textsim.similar_percent(fx_a(31), fx_b(31), 10), "100%") // pct.31.10
  assert_eq(@textsim.similar_percent(fx_a(32), fx_b(32), 0), "0%") // pct.32.0
  assert_eq(@textsim.similar_percent(fx_a(32), fx_b(32), 1), "0%") // pct.32.1
  assert_eq(@textsim.similar_percent(fx_a(32), fx_b(32), 2), "0%") // pct.32.2
  assert_eq(@textsim.similar_percent(fx_a(32), fx_b(32), 10), "0%") // pct.32.10
  assert_eq(@textsim.similar_percent(fx_a(33), fx_b(33), 0), "0%") // pct.33.0
  assert_eq(@textsim.similar_percent(fx_a(33), fx_b(33), 1), "0%") // pct.33.1
  assert_eq(@textsim.similar_percent(fx_a(33), fx_b(33), 2), "0.05%") // pct.33.2
  assert_eq(@textsim.similar_percent(fx_a(33), fx_b(33), 10), "0.04882813%") // pct.33.10
  // tie 档把 HALF_EVEN 与 HALF_UP 分开：12.5% 舍到 0 位给 12%（不是 13%），62.5% 给 62%，87.5% 给 88%
  // 四组直探针读数在腿 A：fp.0.0|12%、fp.2.0|62%、fp.3.0|88%、fp.6.0|0%、fp.7.0|2%（Python 腿逐格同值）
}

///|
// raise 面就是 `num.NumError`（#8.11 的既有错误类型），本包不重定义、也不重复钉它的读数
fn pct_ok(scale : Int) -> Bool {
  try {
    let _ = @textsim.similar_percent("a", "b", scale)
    true
  } catch {
    _ => false
  }
}

///|
test "textsim 百分比的 scale 档：负数夹成 0、大档不补零、上限随 num" {
  assert_eq(@textsim.similar_percent("a", "b", -1), "0%") // exc.sim.neg
  assert_eq(pct_ok(-1), true) // exc.pct.neg|OK:50% 同一条 Math.max(0,…) 夹住规则
  assert_eq(pct_ok(100), true) // exc.sim.big|0%：大档不报错也不出新数字
  assert_eq(pct_ok(0), true) // exc.sim.zero|OK:12%
  assert_eq(pct_ok(309), false) // 上限随 num 的 308（spec §5 第 6 行；hutool 那侧无上限）
  // 参照侧的 locale 面不跟随：zh_CN/en_US 给 `66.67%`，de_DE 给 `66,67 %`（U+00A0 在前）
  // 读数：loc.zh|[54,54,46,54,55,37] = 66.67%、loc.en 同、loc.de|[54,54,44,54,55,160,37]
}

///|
test "textsim 不变式：remove_sign 就是逐码位过 is_valid_char（core 的 filter/to_array 作对拍腿）" {
  assert_eq(
    @textsim.remove_sign(fx_a(1)).to_array(),
    fx_a(1).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(1)).to_array(),
    fx_b(1).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(2)).to_array(),
    fx_a(2).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(2)).to_array(),
    fx_b(2).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(3)).to_array(),
    fx_a(3).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(3)).to_array(),
    fx_b(3).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(4)).to_array(),
    fx_a(4).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(4)).to_array(),
    fx_b(4).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(5)).to_array(),
    fx_a(5).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(5)).to_array(),
    fx_b(5).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(6)).to_array(),
    fx_a(6).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(6)).to_array(),
    fx_b(6).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(7)).to_array(),
    fx_a(7).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(7)).to_array(),
    fx_b(7).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(8)).to_array(),
    fx_a(8).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(8)).to_array(),
    fx_b(8).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(9)).to_array(),
    fx_a(9).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(9)).to_array(),
    fx_b(9).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(10)).to_array(),
    fx_a(10).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(10)).to_array(),
    fx_b(10).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(11)).to_array(),
    fx_a(11).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(11)).to_array(),
    fx_b(11).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(12)).to_array(),
    fx_a(12).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(12)).to_array(),
    fx_b(12).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(13)).to_array(),
    fx_a(13).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(13)).to_array(),
    fx_b(13).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(14)).to_array(),
    fx_a(14).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(14)).to_array(),
    fx_b(14).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(15)).to_array(),
    fx_a(15).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(15)).to_array(),
    fx_b(15).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(16)).to_array(),
    fx_a(16).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(16)).to_array(),
    fx_b(16).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(17)).to_array(),
    fx_a(17).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(17)).to_array(),
    fx_b(17).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(18)).to_array(),
    fx_a(18).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(18)).to_array(),
    fx_b(18).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(19)).to_array(),
    fx_a(19).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(19)).to_array(),
    fx_b(19).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(20)).to_array(),
    fx_a(20).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(20)).to_array(),
    fx_b(20).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(21)).to_array(),
    fx_a(21).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(21)).to_array(),
    fx_b(21).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(22)).to_array(),
    fx_a(22).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(22)).to_array(),
    fx_b(22).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(23)).to_array(),
    fx_a(23).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(23)).to_array(),
    fx_b(23).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(24)).to_array(),
    fx_a(24).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(24)).to_array(),
    fx_b(24).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(25)).to_array(),
    fx_a(25).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(25)).to_array(),
    fx_b(25).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(26)).to_array(),
    fx_a(26).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(26)).to_array(),
    fx_b(26).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(27)).to_array(),
    fx_a(27).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(27)).to_array(),
    fx_b(27).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(28)).to_array(),
    fx_a(28).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(28)).to_array(),
    fx_b(28).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(29)).to_array(),
    fx_a(29).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(29)).to_array(),
    fx_b(29).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(30)).to_array(),
    fx_a(30).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(30)).to_array(),
    fx_b(30).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(31)).to_array(),
    fx_a(31).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(31)).to_array(),
    fx_b(31).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(32)).to_array(),
    fx_a(32).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(32)).to_array(),
    fx_b(32).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_a(33)).to_array(),
    fx_a(33).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  assert_eq(
    @textsim.remove_sign(fx_b(33)).to_array(),
    fx_b(33).to_array().filter(c => @textsim.is_valid_char(c)),
  )
  // 分子不超过分母：相似度恒落在 [0,1]（33 组逐条复核，这条不依赖参照读数，防实现写飞）
  assert_true(
    @textsim.similar(fx_a(1), fx_b(1)) >= 0.0 &&
    @textsim.similar(fx_a(1), fx_b(1)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(2), fx_b(2)) >= 0.0 &&
    @textsim.similar(fx_a(2), fx_b(2)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(3), fx_b(3)) >= 0.0 &&
    @textsim.similar(fx_a(3), fx_b(3)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(4), fx_b(4)) >= 0.0 &&
    @textsim.similar(fx_a(4), fx_b(4)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(5), fx_b(5)) >= 0.0 &&
    @textsim.similar(fx_a(5), fx_b(5)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(6), fx_b(6)) >= 0.0 &&
    @textsim.similar(fx_a(6), fx_b(6)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(7), fx_b(7)) >= 0.0 &&
    @textsim.similar(fx_a(7), fx_b(7)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(8), fx_b(8)) >= 0.0 &&
    @textsim.similar(fx_a(8), fx_b(8)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(9), fx_b(9)) >= 0.0 &&
    @textsim.similar(fx_a(9), fx_b(9)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(10), fx_b(10)) >= 0.0 &&
    @textsim.similar(fx_a(10), fx_b(10)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(11), fx_b(11)) >= 0.0 &&
    @textsim.similar(fx_a(11), fx_b(11)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(12), fx_b(12)) >= 0.0 &&
    @textsim.similar(fx_a(12), fx_b(12)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(13), fx_b(13)) >= 0.0 &&
    @textsim.similar(fx_a(13), fx_b(13)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(14), fx_b(14)) >= 0.0 &&
    @textsim.similar(fx_a(14), fx_b(14)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(15), fx_b(15)) >= 0.0 &&
    @textsim.similar(fx_a(15), fx_b(15)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(16), fx_b(16)) >= 0.0 &&
    @textsim.similar(fx_a(16), fx_b(16)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(17), fx_b(17)) >= 0.0 &&
    @textsim.similar(fx_a(17), fx_b(17)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(18), fx_b(18)) >= 0.0 &&
    @textsim.similar(fx_a(18), fx_b(18)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(19), fx_b(19)) >= 0.0 &&
    @textsim.similar(fx_a(19), fx_b(19)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(20), fx_b(20)) >= 0.0 &&
    @textsim.similar(fx_a(20), fx_b(20)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(21), fx_b(21)) >= 0.0 &&
    @textsim.similar(fx_a(21), fx_b(21)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(22), fx_b(22)) >= 0.0 &&
    @textsim.similar(fx_a(22), fx_b(22)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(23), fx_b(23)) >= 0.0 &&
    @textsim.similar(fx_a(23), fx_b(23)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(24), fx_b(24)) >= 0.0 &&
    @textsim.similar(fx_a(24), fx_b(24)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(25), fx_b(25)) >= 0.0 &&
    @textsim.similar(fx_a(25), fx_b(25)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(26), fx_b(26)) >= 0.0 &&
    @textsim.similar(fx_a(26), fx_b(26)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(27), fx_b(27)) >= 0.0 &&
    @textsim.similar(fx_a(27), fx_b(27)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(28), fx_b(28)) >= 0.0 &&
    @textsim.similar(fx_a(28), fx_b(28)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(29), fx_b(29)) >= 0.0 &&
    @textsim.similar(fx_a(29), fx_b(29)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(30), fx_b(30)) >= 0.0 &&
    @textsim.similar(fx_a(30), fx_b(30)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(31), fx_b(31)) >= 0.0 &&
    @textsim.similar(fx_a(31), fx_b(31)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(32), fx_b(32)) >= 0.0 &&
    @textsim.similar(fx_a(32), fx_b(32)) <= 1.0,
  )
  assert_true(
    @textsim.similar(fx_a(33), fx_b(33)) >= 0.0 &&
    @textsim.similar(fx_a(33), fx_b(33)) <= 1.0,
  )
}
