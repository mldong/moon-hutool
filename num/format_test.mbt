// moon-hutool/num 第二批契约用例（黑盒）——格式化与薄 Money。
//
// 状态：**契约已冻结、实现未开工**——`num.mbt` 里这一批的函数体是 `abort`，本文件此刻红是设计态。
// 期望值三条腿现算（改任何一条须单独一笔 + 外部读数来源，门禁 G5）：
// - 千分位 / 百分比 / trim：Python `Decimal(repr(x))` 腿 + **本机 JDK 17** 的 `DecimalFormat`
//   （显式 `DecimalFormatSymbols`）与 `BigDecimal(s).stripTrailingZeros().toPlainString()` 腿逐条对撞；
//   两腿不符的**每一条都由 `DecimalFormat` 的二进制精确值路径归因**（族别分岔，spec §5 有表），
//   归因失败就停下——不许把说不清的差异当噪音。
// - Money：元→分走 `BigDecimal.movePointRight(2).setScale(0, mode)`（hutool `Money(BigDecimal)` 那条路），
//   `to_string` 走 `BigDecimal(cent).movePointLeft(2).toPlainString()`；allocate 那条腿是**把 hutool
//   `Money.allocate` 逐字转写成 Java 真跑**（不是把我的 Python 结果打印出去比对）。
//   hutool 自己的 `double` 构造路（`Math.round(amount * 100)`）另算一遍，用来把三处分岔做成有依据的
//   差异声明而不是随口一句「不跟随」。本库负档 allocate 是自定规则，那条不进对撞，改用不变量断言。

///|
test "format_thousands：从右往左三位一隔，负号与分隔符都是明码" {
  assert_eq(@num.format_thousands(1234567.891, 2), "1,234,567.89")
  assert_eq(@num.format_thousands(-1234567.891, 2), "-1,234,567.89")
  assert_eq(@num.format_thousands(1234.5, -2), "1,200")
  assert_eq(@num.format_thousands(0.5, 2), "0.50")
  assert_eq(@num.format_thousands(1.0e21, 0), "1,000,000,000,000,000,000,000")
  assert_eq(@num.format_thousands(1.0e-07, 9), "0.000000100")
  assert_eq(@num.format_thousands(12345.6789, 4), "12,345.6789")
  assert_eq(@num.format_thousands(999.999, 2), "1,000.00")
  assert_eq(@num.format_thousands(-0.0, 2), "0.00")
  assert_eq(@num.format_thousands(2.675, 2), "2.68")
  assert_eq(@num.format_thousands(-2.5, 0), "-3")
  assert_eq(
    @num.format_thousands(1234567.5, 1, sep=' ', decimal_sep='.'),
    "1 234 567.5",
  )
  assert_eq(
    @num.format_thousands(1234567.5, 1, sep='.', decimal_sep=','),
    "1.234.567,5",
  )
  assert_eq(@num.format_thousands(1000000.0, 0), "1,000,000")
  assert_eq(@num.format_thousands(-100.0, 0), "-100")
}

///|
test "format_thousands 复用 #8.11：负 scale 与超过三位的 scale 一起进来" {
  assert_eq(@num.format_thousands(1234.5, -2, mode=@num.HalfUp), "1,200")
  assert_eq(
    @num.format_thousands(1.0e21, 0, mode=@num.HalfUp),
    "1,000,000,000,000,000,000,000",
  )
  assert_eq(@num.format_thousands(1.0e-07, 9, mode=@num.HalfUp), "0.000000100")
  assert_eq(
    @num.format_thousands(12345.6789, 4, mode=@num.HalfUp),
    "12,345.6789",
  )
  assert_eq(@num.format_thousands(-2.5, 0, mode=@num.HalfUp), "-3")
  assert_eq(@num.format_thousands(1000000.0, 0, mode=@num.HalfUp), "1,000,000")
  assert_eq(@num.format_thousands(-100.0, 0, mode=@num.HalfUp), "-100")
}

///|
test "format_percent 挪的是十进制小数点，不是浮点乘 100" {
  assert_eq(@num.format_percent(0.125, 2), "12.50%")
  assert_eq(@num.format_percent(1.0, 0), "100%")
  assert_eq(@num.format_percent(0.005, 2), "0.50%")
  assert_eq(@num.format_percent(0.1, 2), "10.00%")
  assert_eq(@num.format_percent(0.145, 0), "15%")
  assert_eq(@num.format_percent(-0.125, 2), "-12.50%")
  assert_eq(@num.format_percent(0.5, 0, mode=@num.HalfEven), "50%")
  assert_eq(@num.format_percent(0.1255, 2, mode=@num.HalfEven), "12.55%")
  assert_eq(@num.format_percent(0.1255, 2), "12.55%")
  assert_eq(@num.format_percent(0.0, 1), "0.0%")
  assert_eq(@num.format_percent(1.0e-07, 6), "0.000010%")
  assert_eq(@num.format_percent(2.675, 1, mode=@num.HalfDown), "267.5%")
}

///|
test "format_percent 的后缀是显式参数，报错面与 #8.11 同源" {
  assert_eq(@num.format_percent(0.125, 2, suffix=" percent"), "12.50 percent")
  assert_eq(@num.format_percent(0.125, 2, suffix=""), "12.50")
  assert_eq(
    err_shape(() => @num.format_percent(@double.not_a_number, 2)),
    "NotFinite",
  )
  assert_eq(
    err_shape(() => @num.format_percent(@double.neg_infinity, 2)),
    "NotFinite",
  )
  assert_eq(
    err_shape(() => @num.format_percent(0.5, 309)),
    "ScaleOutOfRange 309",
  )
}

///|
test "trim_trailing_zeros 只动小数部分，整数的尾随零不碰（JDK 那一条路）" {
  assert_eq(@num.trim_trailing_zeros("12.3400"), "12.34")
  assert_eq(@num.trim_trailing_zeros("12.00"), "12")
  assert_eq(@num.trim_trailing_zeros("-12.300"), "-12.3")
  assert_eq(@num.trim_trailing_zeros("0.000"), "0")
  assert_eq(@num.trim_trailing_zeros("100.10"), "100.1")
  assert_eq(@num.trim_trailing_zeros("12"), "12")
  assert_eq(@num.trim_trailing_zeros("12."), "12")
  assert_eq(@num.trim_trailing_zeros("0.50"), "0.5")
  assert_eq(@num.trim_trailing_zeros("-0.00"), "0")
  assert_eq(err_shape(() => @num.trim_trailing_zeros("abc")), "NotDecimal abc")
  assert_eq(
    err_shape(() => @num.trim_trailing_zeros("1.2.3")),
    "NotDecimal 1.2.3",
  )
}
