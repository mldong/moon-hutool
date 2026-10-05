///|
// typex 第一批（Version + PageUtil）的期望值全部由生成脚本从参照腿灌入（手打零条）。
// 腿：真 hutool-core-5.8.35.jar + 本机 JDK 17.0.14，`javac -encoding UTF-8`，读数见 typex_results.tsv。
// PageUtil 的 firstPageNo 在参照是**全局静态** ⇒ 每条用到它的断言都先显式设档再读（腿同样跑 0 档与 1 档两遍）。
// `compareTo` 的具体返回值不进契约（只钉符号档），参照自己给的 `hashCode` 只钉"同不同"这一位。

///|
fn esc(s : String) -> String {
  let digits = [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f",
  ]
  fn h4(v : Int) -> String {
    digits[(v >> 12) & 0xf] +
    digits[(v >> 8) & 0xf] +
    digits[(v >> 4) & 0xf] +
    digits[v & 0xf]
  }
  let mut out = ""
  for c in s.to_array() {
    let cp = c.to_int()
    if cp == 0x5c {
      out = out + "\\\\"
    } else if cp == 0x0d {
      out = out + "\\r"
    } else if cp == 0x0a {
      out = out + "\\n"
    } else if cp == 0x09 {
      out = out + "\\t"
    } else if cp > 0xffff {
      let x = cp - 0x10000
      out = out +
        "\\u" +
        h4(0xd800 + (x >> 10)) +
        "\\u" +
        h4(0xdc00 + (x & 0x3ff))
    } else if cp < 0x20 || cp == 0x7f || cp > 0x7e {
      out = out + "\\u" + h4(cp)
    } else {
      out = out + c.to_string()
    }
  }
  out
}

///|
fn joinx(a : Array[String], sep : String) -> String {
  let mut out = ""
  let mut first = true
  for x in a {
    if !first {
      out = out + sep
    }
    first = false
    out = out + x
  }
  out
}

///|
fn sign_of(v : Int) -> String {
  if v < 0 {
    "-"
  } else if v > 0 {
    "+"
  } else {
    "0"
  }
}

///|
fn arr_str(a : Array[Int]) -> String {
  let r : Array[String] = []
  for x in a {
    r.push(x.to_string())
  }
  joinx(r, ",")
}

///|
test "Version 比较：数字段按数值、段数不等补零" {
  assert_eq(@typex.version_to_string(@typex.version_of("1.0.0")), "1.0.0") // V0.to_string|1.0.0
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.0.0"),
        @typex.version_of("1.0.1"),
      ),
    ),
    "-",
  ) // V0.cmp|-
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.0.0"),
      @typex.version_of("1.0.1"),
    ),
    false,
  ) // V0.eq|false

  assert_eq(@typex.version_to_string(@typex.version_of("1.0.10")), "1.0.10") // V1.to_string|1.0.10
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.0.10"),
        @typex.version_of("1.0.9"),
      ),
    ),
    "+",
  ) // V1.cmp|+
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.0.10"),
      @typex.version_of("1.0.9"),
    ),
    false,
  ) // V1.eq|false

  assert_eq(@typex.version_to_string(@typex.version_of("1.2")), "1.2") // V2.to_string|1.2
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.2"),
        @typex.version_of("1.2.0"),
      ),
    ),
    "0",
  ) // V2.cmp|0
  assert_eq(
    @typex.version_equals(@typex.version_of("1.2"), @typex.version_of("1.2.0")),
    true,
  ) // V2.eq|true

  assert_eq(@typex.version_to_string(@typex.version_of("1.2.0")), "1.2.0") // V3.to_string|1.2.0
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.2.0"),
        @typex.version_of("1.2"),
      ),
    ),
    "0",
  ) // V3.cmp|0
  assert_eq(
    @typex.version_equals(@typex.version_of("1.2.0"), @typex.version_of("1.2")),
    true,
  ) // V3.eq|true

  assert_eq(@typex.version_to_string(@typex.version_of("v1.2.3")), "v1.2.3") // V4.to_string|v1.2.3
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("v1.2.3"),
        @typex.version_of("1.2.3"),
      ),
    ),
    "+",
  ) // V4.cmp|+
  assert_eq(
    @typex.version_equals(
      @typex.version_of("v1.2.3"),
      @typex.version_of("1.2.3"),
    ),
    false,
  ) // V4.eq|false

  assert_eq(@typex.version_to_string(@typex.version_of("V1.2.3")), "V1.2.3") // V5.to_string|V1.2.3
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("V1.2.3"),
        @typex.version_of("v1.2.3"),
      ),
    ),
    "-",
  ) // V5.cmp|-
  assert_eq(
    @typex.version_equals(
      @typex.version_of("V1.2.3"),
      @typex.version_of("v1.2.3"),
    ),
    false,
  ) // V5.eq|false

  assert_eq(
    @typex.version_to_string(@typex.version_of("1.2.3-SNAPSHOT")),
    "1.2.3-SNAPSHOT",
  ) // V6.to_string|1.2.3-SNAPSHOT
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.2.3-SNAPSHOT"),
        @typex.version_of("1.2.3"),
      ),
    ),
    "-",
  ) // V6.cmp|-
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.3-SNAPSHOT"),
      @typex.version_of("1.2.3"),
    ),
    false,
  ) // V6.eq|false

  assert_eq(
    @typex.version_to_string(@typex.version_of("1.2.3.RELEASE")),
    "1.2.3.RELEASE",
  ) // V7.to_string|1.2.3.RELEASE
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.2.3.RELEASE"),
        @typex.version_of("1.2.3.snapshot"),
      ),
    ),
    "-",
  ) // V7.cmp|-
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.3.RELEASE"),
      @typex.version_of("1.2.3.snapshot"),
    ),
    false,
  ) // V7.eq|false

  assert_eq(@typex.version_to_string(@typex.version_of("1.2.3.a")), "1.2.3.a") // V8.to_string|1.2.3.a
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.2.3.a"),
        @typex.version_of("1.2.3.b"),
      ),
    ),
    "-",
  ) // V8.cmp|-
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.3.a"),
      @typex.version_of("1.2.3.b"),
    ),
    false,
  ) // V8.eq|false

  assert_eq(@typex.version_to_string(@typex.version_of("1.2.3.10")), "1.2.3.10") // V9.to_string|1.2.3.10
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.2.3.10"),
        @typex.version_of("1.2.3.9"),
      ),
    ),
    "+",
  ) // V9.cmp|+
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.3.10"),
      @typex.version_of("1.2.3.9"),
    ),
    false,
  ) // V9.eq|false

  assert_eq(@typex.version_to_string(@typex.version_of("1.2.3.0")), "1.2.3.0") // V10.to_string|1.2.3.0
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.2.3.0"),
        @typex.version_of("1.2.3"),
      ),
    ),
    "0",
  ) // V10.cmp|0
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.3.0"),
      @typex.version_of("1.2.3"),
    ),
    true,
  ) // V10.eq|true

  assert_eq(@typex.version_to_string(@typex.version_of("")), "") // V11.to_string|
  assert_eq(
    sign_of(
      @typex.version_compare(@typex.version_of(""), @typex.version_of("")),
    ),
    "0",
  ) // V11.cmp|0
  assert_eq(
    @typex.version_equals(@typex.version_of(""), @typex.version_of("")),
    true,
  ) // V11.eq|true
}

///|
test "Version 比较：非数字段与前后缀、大小写档" {
  assert_eq(@typex.version_to_string(@typex.version_of("1")), "1") // V12.to_string|1
  assert_eq(
    sign_of(
      @typex.version_compare(@typex.version_of("1"), @typex.version_of("1")),
    ),
    "0",
  ) // V12.cmp|0
  assert_eq(
    @typex.version_equals(@typex.version_of("1"), @typex.version_of("1")),
    true,
  ) // V12.eq|true

  assert_eq(
    @typex.version_to_string(@typex.version_of("1.2.3.4.5.6")),
    "1.2.3.4.5.6",
  ) // V13.to_string|1.2.3.4.5.6
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.2.3.4.5.6"),
        @typex.version_of("1.2.3.4.5.7"),
      ),
    ),
    "-",
  ) // V13.cmp|-
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.3.4.5.6"),
      @typex.version_of("1.2.3.4.5.7"),
    ),
    false,
  ) // V13.eq|false

  assert_eq(@typex.version_to_string(@typex.version_of("2.0")), "2.0") // V14.to_string|2.0
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("2.0"),
        @typex.version_of("10.0"),
      ),
    ),
    "-",
  ) // V14.cmp|-
  assert_eq(
    @typex.version_equals(@typex.version_of("2.0"), @typex.version_of("10.0")),
    false,
  ) // V14.eq|false

  assert_eq(
    @typex.version_to_string(@typex.version_of("1.0.0-beta")),
    "1.0.0-beta",
  ) // V15.to_string|1.0.0-beta
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.0.0-beta"),
        @typex.version_of("1.0.0-beta.1"),
      ),
    ),
    "-",
  ) // V15.cmp|-
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.0.0-beta"),
      @typex.version_of("1.0.0-beta.1"),
    ),
    false,
  ) // V15.eq|false

  assert_eq(@typex.version_to_string(@typex.version_of("a.b.c")), "a.b.c") // V16.to_string|a.b.c
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("a.b.c"),
        @typex.version_of("a.b.d"),
      ),
    ),
    "-",
  ) // V16.cmp|-
  assert_eq(
    @typex.version_equals(
      @typex.version_of("a.b.c"),
      @typex.version_of("a.b.d"),
    ),
    false,
  ) // V16.eq|false

  assert_eq(@typex.version_to_string(@typex.version_of("1..2")), "1..2") // V17.to_string|1..2
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1..2"),
        @typex.version_of("1.2"),
      ),
    ),
    "0",
  ) // V17.cmp|0
  assert_eq(
    @typex.version_equals(@typex.version_of("1..2"), @typex.version_of("1.2")),
    true,
  ) // V17.eq|true

  assert_eq(@typex.version_to_string(@typex.version_of("1.2 ")), "1.2 ") // V18.to_string|1.2 
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.2 "),
        @typex.version_of("1.2"),
      ),
    ),
    "+",
  ) // V18.cmp|+
  assert_eq(
    @typex.version_equals(@typex.version_of("1.2 "), @typex.version_of("1.2")),
    false,
  ) // V18.eq|false

  assert_eq(@typex.version_to_string(@typex.version_of(" 1.2")), " 1.2") // V19.to_string| 1.2
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of(" 1.2"),
        @typex.version_of("1.2"),
      ),
    ),
    "-",
  ) // V19.cmp|-
  assert_eq(
    @typex.version_equals(@typex.version_of(" 1.2"), @typex.version_of("1.2")),
    false,
  ) // V19.eq|false

  assert_eq(@typex.version_to_string(@typex.version_of("1.2.3.")), "1.2.3.") // V20.to_string|1.2.3.
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.2.3."),
        @typex.version_of("1.2.3"),
      ),
    ),
    "0",
  ) // V20.cmp|0
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.3."),
      @typex.version_of("1.2.3"),
    ),
    true,
  ) // V20.eq|true

  assert_eq(@typex.version_to_string(@typex.version_of("1-2-3")), "1-2-3") // V21.to_string|1-2-3
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1-2-3"),
        @typex.version_of("1.2.3"),
      ),
    ),
    "-",
  ) // V21.cmp|-
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1-2-3"),
      @typex.version_of("1.2.3"),
    ),
    false,
  ) // V21.eq|false

  assert_eq(@typex.version_to_string(@typex.version_of("1.2.3_4")), "1.2.3_4") // V22.to_string|1.2.3_4
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("1.2.3_4"),
        @typex.version_of("1.2.3.4"),
      ),
    ),
    "+",
  ) // V22.cmp|+
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.3_4"),
      @typex.version_of("1.2.3.4"),
    ),
    false,
  ) // V22.eq|false

  assert_eq(
    @typex.version_to_string(@typex.version_of("9999999999.1.1")),
    "9999999999.1.1",
  ) // V23.to_string|9999999999.1.1
  assert_eq(
    sign_of(
      @typex.version_compare(
        @typex.version_of("9999999999.1.1"),
        @typex.version_of("1.1.1"),
      ),
    ),
    "+",
  ) // V23.cmp|+
  assert_eq(
    @typex.version_equals(
      @typex.version_of("9999999999.1.1"),
      @typex.version_of("1.1.1"),
    ),
    false,
  ) // V23.eq|false
}

///|
test "Version 归一化形状：toString 的重建" {

}

///|
test "PageUtil 首末页号与总页数（firstPageNo = 0 档）" {
  @typex.typex_set_first_page_no(0) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(2, 10), 20) // P2.start|20
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_get_end(2, 10), 30) // P2.end|30
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_trans_to_start_end(2, 10), (20, 30)) // P2.pair|20,30
  @typex.typex_set_first_page_no(0)
  assert_eq(arr_str(@typex.page_rainbow(2, 10)), "1,2,3,4,5") // P2.rainbow|1,2,3,4,5
  @typex.typex_set_first_page_no(0) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(1, 0), 0) // P3.start|0
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_get_end(1, 0), 0) // P3.end|0
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_trans_to_start_end(1, 0), (0, 0)) // P3.pair|0,0
  @typex.typex_set_first_page_no(0)
  assert_eq(arr_str(@typex.page_rainbow(1, 0)), "") // P3.rainbow|
  @typex.typex_set_first_page_no(0) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(-1, 10), 0) // P5.start|0
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_get_end(-1, 10), 10) // P5.end|10
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_trans_to_start_end(-1, 10), (0, 10)) // P5.pair|0,10
  @typex.typex_set_first_page_no(0)
  assert_eq(arr_str(@typex.page_rainbow(-1, 10)), "1,2,3,4,5") // P5.rainbow|1,2,3,4,5
  @typex.typex_set_first_page_no(0) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(3, 7), 21) // P6.start|21
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_get_end(3, 7), 28) // P6.end|28
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_trans_to_start_end(3, 7), (21, 28)) // P6.pair|21,28
  @typex.typex_set_first_page_no(0)
  assert_eq(arr_str(@typex.page_rainbow(3, 7)), "1,2,3,4,5") // P6.rainbow|1,2,3,4,5
  assert_eq(@typex.page_total_page(0, 10), 0) // P2000.total|0
  assert_eq(@typex.page_total_page(1, 10), 1) // P2001.total|1
  assert_eq(@typex.page_total_page(10, 10), 1) // P2002.total|1
  assert_eq(@typex.page_total_page(11, 10), 2) // P2003.total|2
  assert_eq(@typex.page_total_page(0, 0), 0) // P2004.total|0
  assert_eq(@typex.page_total_page(-5, 10), 1) // P2005.total|1
  assert_eq(@typex.page_total_page(99, 10), 10) // P2006.total|10
  assert_eq(@typex.page_total_page_long(0L, 10), 0) // P3000.total_long|0
  assert_eq(@typex.page_total_page_long(1L, 10), 1) // P3001.total_long|1
  assert_eq(@typex.page_total_page_long(10L, 10), 1) // P3002.total_long|1
  assert_eq(@typex.page_total_page_long(11L, 10), 2) // P3003.total_long|2
  assert_eq(@typex.page_total_page_long(2147483647L, 10), 214748365) // P3004.total_long|214748365
  assert_eq(@typex.page_total_page_long(4294967296L, 10), 429496730) // P3005.total_long|429496730
  assert_eq(arr_str(@typex.page_rainbow_count(1, 10, 5)), "1,2,3,4,5") // P50000.rainbow3|1,2,3,4,5
  assert_eq(arr_str(@typex.page_rainbow_count(0, 3, 5)), "1,2,3") // P50001.rainbow3|1,2,3
  assert_eq(arr_str(@typex.page_rainbow_count(5, 5, 9)), "1,2,3,4,5") // P50002.rainbow3|1,2,3,4,5
  assert_eq(arr_str(@typex.page_rainbow_count(2, 2, 1)), "2") // P50003.rainbow3|2
  assert_eq(arr_str(@typex.page_rainbow_count(-3, 8, 4)), "1,2,3,4") // P50004.rainbow3|1,2,3,4
  assert_eq(arr_str(@typex.page_rainbow_count(9, 10, 3)), "8,9,10") // P50005.rainbow3|8,9,10
  // P6000.segment|参照给 Segment 对象（cn.hutool.core.lang.DefaultSegment@4b85612c），本库不收（spec §1）
  // P6001.segment|参照给 Segment 对象（cn.hutool.core.lang.DefaultSegment@5c29bfd），本库不收（spec §1）
  @typex.typex_set_first_page_no(0) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(0, 10), 0) // P0.start|0
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_get_end(0, 10), 10) // P0.end|10
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_trans_to_start_end(0, 10), (0, 10)) // P0.pair|0,10
  @typex.typex_set_first_page_no(0)
  assert_eq(arr_str(@typex.page_rainbow(0, 10)), "1,2,3,4,5") // P0.rainbow|1,2,3,4,5
  @typex.typex_set_first_page_no(0) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(1, 10), 10) // P1.start|10
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_get_end(1, 10), 20) // P1.end|20
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_trans_to_start_end(1, 10), (10, 20)) // P1.pair|10,20
  @typex.typex_set_first_page_no(0)
  assert_eq(arr_str(@typex.page_rainbow(1, 10)), "1,2,3,4,5") // P1.rainbow|1,2,3,4,5
  @typex.typex_set_first_page_no(0) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(2, 10), 20) // P2.start|20
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_get_end(2, 10), 30) // P2.end|30
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_trans_to_start_end(2, 10), (20, 30)) // P2.pair|20,30
  @typex.typex_set_first_page_no(0)
  assert_eq(arr_str(@typex.page_rainbow(2, 10)), "1,2,3,4,5") // P2.rainbow|1,2,3,4,5
  @typex.typex_set_first_page_no(0) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(1, 0), 0) // P3.start|0
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_get_end(1, 0), 0) // P3.end|0
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_trans_to_start_end(1, 0), (0, 0)) // P3.pair|0,0
  @typex.typex_set_first_page_no(0)
  assert_eq(arr_str(@typex.page_rainbow(1, 0)), "") // P3.rainbow|
  @typex.typex_set_first_page_no(0) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(0, 0), 0) // P4.start|0
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_get_end(0, 0), 0) // P4.end|0
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_trans_to_start_end(0, 0), (0, 0)) // P4.pair|0,0
  @typex.typex_set_first_page_no(0)
  assert_eq(arr_str(@typex.page_rainbow(0, 0)), "") // P4.rainbow|
  @typex.typex_set_first_page_no(0) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(-1, 10), 0) // P5.start|0
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_get_end(-1, 10), 10) // P5.end|10
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_trans_to_start_end(-1, 10), (0, 10)) // P5.pair|0,10
  @typex.typex_set_first_page_no(0)
  assert_eq(arr_str(@typex.page_rainbow(-1, 10)), "1,2,3,4,5") // P5.rainbow|1,2,3,4,5
  @typex.typex_set_first_page_no(0) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(3, 7), 21) // P6.start|21
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_get_end(3, 7), 28) // P6.end|28
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_trans_to_start_end(3, 7), (21, 28)) // P6.pair|21,28
  @typex.typex_set_first_page_no(0)
  assert_eq(arr_str(@typex.page_rainbow(3, 7)), "1,2,3,4,5") // P6.rainbow|1,2,3,4,5
  @typex.typex_set_first_page_no(0) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(100, 20), 2000) // P7.start|2000
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_get_end(100, 20), 2020) // P7.end|2020
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.page_trans_to_start_end(100, 20), (2000, 2020)) // P7.pair|2000,2020
  @typex.typex_set_first_page_no(0)
  assert_eq(arr_str(@typex.page_rainbow(100, 20)), "16,17,18,19,20") // P7.rainbow|16,17,18,19,20
}

///|
test "PageUtil 全局首尾页号改设 1 档（firstPageNo = 1）" {
  @typex.typex_set_first_page_no(1) // 档位先设后测（全局静态）
  assert_eq(@typex.page_get_start(0, 10), 0) // P1000.start|0
  @typex.typex_set_first_page_no(1)
  assert_eq(@typex.page_get_end(0, 10), 10) // P1000.end|10
  @typex.typex_set_first_page_no(1)
  assert_eq(@typex.page_trans_to_start_end(0, 10), (0, 10)) // P1000.pair|0,10
  @typex.typex_set_first_page_no(1)
  assert_eq(arr_str(@typex.page_rainbow(0, 10)), "1,2,3,4,5") // P1000.rainbow|1,2,3,4,5
  assert_eq(@typex.page_total_page(0, 10), 0) // P40000.total|0
  assert_eq(@typex.page_total_page(1, 10), 1) // P40001.total|1
  assert_eq(@typex.page_total_page(10, 10), 1) // P40002.total|1
  assert_eq(@typex.page_total_page(11, 10), 2) // P40003.total|2
  assert_eq(@typex.page_total_page(0, 0), 0) // P40004.total|0
  assert_eq(@typex.page_total_page(-5, 10), 1) // P40005.total|1
  assert_eq(@typex.page_total_page(99, 10), 10) // P40006.total|10
}

///|
test "PageUtil 全局档读取" {
  @typex.typex_set_first_page_no(0)
  assert_eq(@typex.typex_first_page_no(), 0) // G0.first|0
  @typex.typex_set_first_page_no(1)
  assert_eq(@typex.typex_first_page_no(), 1) // G1.first|1
}
