///|
// Version 族补档（10-07）——typex.mbt 的码元/代理对比较分支此前一条用例都没走到，
// 期望值全部来自 TypexLeg3.java（hutool-all 5.8.37 · JDK 17），手打零条。
// 四种参照入口（new Version().compareTo / Version.of().compareTo / VersionComparator /
// VersionUtil 四个布尔判据）在本批 18 对上 obj==of==cmp 全一致 ⇒ 取 compareTo 那一支当权威；
// equals 的期望由同一 compareTo 读数推（==0 才等），不引入第二个真相源。
// 参照内部不一致的一条：lead-space 上布尔族给 ge+le（视作相等）、compareTo 给 -1。

///|
test "typex Version sp-vs-bmp" {
  // compareTo 参照读数 = 1 ｜ 输入 "1.2.\\ud83d\\ude80" vs "1.2.Z"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("1.2.🚀"),
      @typex.version_of("1.2.Z"),
    ),
    1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.🚀"),
      @typex.version_of("1.2.Z"),
    ),
    false,
  )
}

///|
test "typex Version sp-vs-bmp2" {
  // compareTo 参照读数 = 1 ｜ 输入 "1.2.\\ud83d\\ude80" vs "1.2.\\u00ff"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("1.2.🚀"),
      @typex.version_of("1.2.ÿ"),
    ),
    1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.🚀"),
      @typex.version_of("1.2.ÿ"),
    ),
    false,
  )
}

///|
test "typex Version sp-vs-sp" {
  // compareTo 参照读数 = -1 ｜ 输入 "1.2.\\ud83d\\ude80" vs "1.2.\\ud83d\\ude81"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("1.2.🚀"),
      @typex.version_of("1.2.🚁"),
    ),
    -1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.🚀"),
      @typex.version_of("1.2.🚁"),
    ),
    false,
  )
}

///|
test "typex Version sp-vs-num" {
  // compareTo 参照读数 = 1 ｜ 输入 "1.2.\\ud83d\\ude80" vs "1.2.5"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("1.2.🚀"),
      @typex.version_of("1.2.5"),
    ),
    1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.🚀"),
      @typex.version_of("1.2.5"),
    ),
    false,
  )
}

///|
test "typex Version sp-low" {
  // compareTo 参照读数 = 1 ｜ 输入 "1.\\ud83d\\udca9.3" vs "1.5.3"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("1.💩.3"),
      @typex.version_of("1.5.3"),
    ),
    1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.💩.3"),
      @typex.version_of("1.5.3"),
    ),
    false,
  )
}

///|
test "typex Version case-1" {
  // compareTo 参照读数 = -1 ｜ 输入 "V1.2.3" vs "v1.2.3"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("V1.2.3"),
      @typex.version_of("v1.2.3"),
    ),
    -1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("V1.2.3"),
      @typex.version_of("v1.2.3"),
    ),
    false,
  )
}

///|
test "typex Version case-2" {
  // compareTo 参照读数 = -1 ｜ 输入 "1.2.RELEASE" vs "1.2.snapshot"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("1.2.RELEASE"),
      @typex.version_of("1.2.snapshot"),
    ),
    -1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.RELEASE"),
      @typex.version_of("1.2.snapshot"),
    ),
    false,
  )
}

///|
test "typex Version pre-empty" {
  // compareTo 参照读数 = 1 ｜ 输入 "1.2.3" vs "1.2.3-beta"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("1.2.3"),
      @typex.version_of("1.2.3-beta"),
    ),
    1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.3"),
      @typex.version_of("1.2.3-beta"),
    ),
    false,
  )
}

///|
test "typex Version pre-empty2" {
  // compareTo 参照读数 = -1 ｜ 输入 "1.2.3-beta" vs "1.2.3"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("1.2.3-beta"),
      @typex.version_of("1.2.3"),
    ),
    -1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.3-beta"),
      @typex.version_of("1.2.3"),
    ),
    false,
  )
}

///|
test "typex Version pre-both" {
  // compareTo 参照读数 = -1 ｜ 输入 "1.2.3-alpha" vs "1.2.3-beta"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("1.2.3-alpha"),
      @typex.version_of("1.2.3-beta"),
    ),
    -1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.3-alpha"),
      @typex.version_of("1.2.3-beta"),
    ),
    false,
  )
}

///|
test "typex Version num-pad" {
  // compareTo 参照读数 = 0 ｜ 输入 "1.02.3" vs "1.2.3"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("1.02.3"),
      @typex.version_of("1.2.3"),
    ),
    0,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.02.3"),
      @typex.version_of("1.2.3"),
    ),
    true,
  )
}

///|
test "typex Version num-wide" {
  // compareTo 参照读数 = 1 ｜ 输入 "1.10.0" vs "1.9.9"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("1.10.0"),
      @typex.version_of("1.9.9"),
    ),
    1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.10.0"),
      @typex.version_of("1.9.9"),
    ),
    false,
  )
}

///|
test "typex Version lead-nonnum" {
  // compareTo 参照读数 = 1 ｜ 输入 "v1.2.3" vs "1.2.3"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("v1.2.3"),
      @typex.version_of("1.2.3"),
    ),
    1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("v1.2.3"),
      @typex.version_of("1.2.3"),
    ),
    false,
  )
}

///|
test "typex Version lead-space" {
  // compareTo 参照读数 = -1 ｜ 输入 " 1.2" vs "1.2"
  assert_eq(
    @typex.version_compare(@typex.version_of(" 1.2"), @typex.version_of("1.2")),
    -1,
  )
  assert_eq(
    @typex.version_equals(@typex.version_of(" 1.2"), @typex.version_of("1.2")),
    false,
  )
}

///|
test "typex Version len-diff" {
  // compareTo 参照读数 = 0 ｜ 输入 "1.2" vs "1.2.0"
  assert_eq(
    @typex.version_compare(@typex.version_of("1.2"), @typex.version_of("1.2.0")),
    0,
  )
  assert_eq(
    @typex.version_equals(@typex.version_of("1.2"), @typex.version_of("1.2.0")),
    true,
  )
}

///|
test "typex Version overflow" {
  // compareTo 参照读数 = -1 ｜ 输入 "9999999999.1.1" vs "9999999999.1.2"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("9999999999.1.1"),
      @typex.version_of("9999999999.1.2"),
    ),
    -1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("9999999999.1.1"),
      @typex.version_of("9999999999.1.2"),
    ),
    false,
  )
}

///|
test "typex Version overflow2" {
  // compareTo 参照读数 = -1 ｜ 输入 "2147483648.0" vs "1.0"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("2147483648.0"),
      @typex.version_of("1.0"),
    ),
    -1,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("2147483648.0"),
      @typex.version_of("1.0"),
    ),
    false,
  )
}

///|
test "typex Version equal" {
  // compareTo 参照读数 = 0 ｜ 输入 "1.2.3+build" vs "1.2.3+build"
  assert_eq(
    @typex.version_compare(
      @typex.version_of("1.2.3+build"),
      @typex.version_of("1.2.3+build"),
    ),
    0,
  )
  assert_eq(
    @typex.version_equals(
      @typex.version_of("1.2.3+build"),
      @typex.version_of("1.2.3+build"),
    ),
    true,
  )
}
