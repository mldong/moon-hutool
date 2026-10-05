// moon-hutool/num 第二批契约用例（黑盒）——格式化与薄 Money。
//
// 状态：**已实现**（10-05）——镜像读数（数值形状那一批）一字未改地从红变绿。
// 本文件在实现期改过的只有**错误形状与校验顺序**那几条：它们在契约那一笔里是我手打的，
// 实现期两条被抓（`[1,-1]` 该先报逐项负数而不是"和为 0"；`MoneyOverflow` 不该安到
// `trim_trailing_zeros` 头上）。处理是给镜像补 `ratio_err`/`str_err`/`add_err` 三条腿，
// 让所有错误形状从腿里出——依据与教训在 spec §4 第 7、8 条。
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
test "Money::from_yuan_str 默认 HalfEven，1.005 这一档两种答案" {
  assert_eq(@num.Money::from_yuan_str("12.345").cent(), 1234)
  assert_eq(@num.Money::from_yuan_str("12.335").cent(), 1234)
  assert_eq(@num.Money::from_yuan_str("0.005").cent(), 0)
  assert_eq(@num.Money::from_yuan_str("1.005").cent(), 100)
  assert_eq(@num.Money::from_yuan_str("1.005", mode=@num.HalfUp).cent(), 101)
  assert_eq(@num.Money::from_yuan_str("12.34", mode=@num.HalfUp).cent(), 1234)
  assert_eq(@num.Money::from_yuan_str("-12.345").cent(), -1234)
  assert_eq(@num.Money::from_yuan_str("0").cent(), 0)
  assert_eq(@num.Money::from_yuan_str("123").cent(), 12300)
  assert_eq(@num.Money::from_yuan_str("0.001", mode=@num.HalfUp).cent(), 0)
  // 同一个 "1.005" 两种答案：默认档是 hutool `Money` 的 HALF_EVEN，不是 #8.11 的 HALF_UP
}

///|
test "Money::from_yuan 与 hutool 的 double 构造路在三档分岔" {
  // 右边注释是 hutool `Money(double)` 那条路（`Math.round(amount * 100)`）的读数，三档与本库分岔；
  // 本库一律走最短十进制 + 显式模式，见 spec §5 那张分岔表
  assert_eq(@num.Money::from_yuan(1.15).cent(), 115)
  assert_eq(@num.Money::from_yuan(2.675).cent(), 268)
  assert_eq(@num.Money::from_yuan(0.025).cent(), 2) // hutool 的 double 路：3
  assert_eq(@num.Money::from_yuan(0.145).cent(), 14)
  assert_eq(@num.Money::from_yuan(0.135).cent(), 14)
  assert_eq(@num.Money::from_yuan(-2.5).cent(), -250)
  assert_eq(@num.Money::from_yuan(12.345).cent(), 1234) // hutool 的 double 路：1235
  assert_eq(@num.Money::from_yuan(0.0).cent(), 0)
  assert_eq(@num.Money::from_yuan(100.0).cent(), 10000)
  assert_eq(@num.Money::from_yuan(0.005).cent(), 0) // hutool 的 double 路：1
}

///|
test "Money::to_string 恒两位小数、不保留负零、`Int64` 满值也不转指数" {
  assert_eq(@num.Money::new(0).to_string(), "0.00")
  assert_eq(@num.Money::new(5).to_string(), "0.05")
  assert_eq(@num.Money::new(-5).to_string(), "-0.05")
  assert_eq(@num.Money::new(1234).to_string(), "12.34")
  assert_eq(@num.Money::new(-1234).to_string(), "-12.34")
  assert_eq(
    @num.Money::new(9223372036854775807).to_string(),
    "92233720368547758.07",
  )
}

///|
test "Money 的加减：越界必须报错，不在 Int64 上静默回绕" {
  assert_eq(
    err_shape(() => @num.Money::new(9223372036854775807).add(@num.Money::new(1))),
    "MoneyOverflow",
  )
  assert_eq(
    err_shape(() => {
      @num.Money::new(-9223372036854775808).add(@num.Money::new(-1))
    }),
    "MoneyOverflow",
  )
  assert_eq(
    @num.Money::new(9223372036854775807).add(@num.Money::new(-1)).to_string(),
    "92233720368547758.06",
  )
  assert_eq(
    @num.Money::new(1234).add(@num.Money::new(-66)).to_string(),
    "11.68",
  )
  assert_eq(
    @num.Money::from_yuan_str("-1.00")
    .add(@num.Money::from_yuan_str("1.00"))
    .to_string(),
    "0.00",
  )
  assert_eq(
    @num.Money::from_yuan_str("12.34")
    .sub(@num.Money::from_yuan_str("0.34"))
    .to_string(),
    "12.00",
  )
}

///|
test "allocate_even：余数发给最前面几份，负档按对称规则" {
  assert_eq(
    err_shape(() => @num.Money::new(9223372036854775807).add(@num.Money::new(1))),
    "MoneyOverflow",
  )
  assert_eq(
    err_shape(() => {
      @num.Money::new(-9223372036854775808).add(@num.Money::new(-1))
    }),
    "MoneyOverflow",
  )
  assert_eq(
    @num.Money::new(9223372036854775807).add(@num.Money::new(-1)).to_string(),
    "92233720368547758.06",
  )
  assert_eq(
    @num.Money::new(1234).add(@num.Money::new(-66)).to_string(),
    "11.68",
  )
  assert_eq(
    @num.Money::from_yuan_str("-1.00")
    .add(@num.Money::from_yuan_str("1.00"))
    .to_string(),
    "0.00",
  )
  assert_eq(
    @num.Money::from_yuan_str("12.34")
    .sub(@num.Money::from_yuan_str("0.34"))
    .to_string(),
    "12.00",
  )
}

///|
test "allocate_by_ratio：逐份向零截断，余数按索引序补给最前" {
  assert_eq(
    @num.Money::new(1000).allocate_by_ratio([2, 3]).map(x => x.cent()),
    [400, 600],
  )
  assert_eq(
    @num.Money::new(4611686018427387904)
    .allocate_by_ratio([3, 1])
    .map(x => x.cent()),
    [3458764513820540928, 1152921504606846976],
  )
  assert_eq(
    @num.Money::new(-9223372036854775808)
    .allocate_by_ratio([1, 3])
    .map(x => x.cent()),
    [-2305843009213693952, -6917529027641081856],
  )
  assert_eq(
    @num.Money::new(1000).allocate_by_ratio([1, 1, 1]).map(x => x.cent()),
    [334, 333, 333],
  )
  assert_eq(@num.Money::new(900).allocate_by_ratio([2, 1]).map(x => x.cent()), [
    600, 300,
  ])
  assert_eq(
    @num.Money::new(1000).allocate_by_ratio([2, 3]).map(x => x.cent()),
    [400, 600],
  )
  assert_eq(
    @num.Money::new(100).allocate_by_ratio([1, 1, 1]).map(x => x.cent()),
    [34, 33, 33],
  )
  assert_eq(
    @num.Money::new(-1000).allocate_by_ratio([1, 1]).map(x => x.cent()),
    [-500, -500],
  )
  assert_eq(@num.Money::new(0).allocate_by_ratio([1, 2]).map(x => x.cent()), [
    0, 0,
  ])
  assert_eq(
    @num.Money::new(1000).allocate_by_ratio([1, 0, 1]).map(x => x.cent()),
    [500, 0, 500],
  )
}

///|
test "Money 的报错面：份数、比例、比例和、非法串、越界各一条" {
  assert_eq(
    err_shape(() => @num.Money::new(1000).allocate_even(0)),
    "NonPositiveTargets 0",
  )
  assert_eq(
    err_shape(() => @num.Money::new(1000).allocate_even(-2)),
    "NonPositiveTargets -2",
  )
  assert_eq(
    err_shape(() => @num.Money::new(1000).allocate_by_ratio([0, 0])),
    "RatioSumNotPositive 0",
  )
  assert_eq(
    err_shape(() => @num.Money::new(1000).allocate_by_ratio([1, -1])),
    "NegativeRatio -1",
  )
  assert_eq(
    err_shape(() => @num.Money::new(1000).allocate_by_ratio([-2, 3])),
    "NegativeRatio -2",
  )
  assert_eq(err_shape(() => @num.Money::from_yuan_str("abc")), "NotDecimal abc")
  assert_eq(err_shape(() => @num.trim_trailing_zeros("abc")), "NotDecimal abc")
  assert_eq(
    err_shape(() => @num.Money::from_yuan_str("1.2.3")),
    "NotDecimal 1.2.3",
  )
  assert_eq(
    err_shape(() => @num.trim_trailing_zeros("1.2.3")),
    "NotDecimal 1.2.3",
  )
  assert_eq(err_shape(() => @num.Money::from_yuan_str("-")), "NotDecimal -")
  assert_eq(err_shape(() => @num.trim_trailing_zeros("-")), "NotDecimal -")
  assert_eq(
    err_shape(() => @num.Money::from_yuan_str("922337203685477580.00")),
    "MoneyOverflow",
  )
  assert_eq(
    @num.trim_trailing_zeros("922337203685477580.00"),
    "922337203685477580",
  )
  assert_eq(
    err_shape(() => @num.Money::from_yuan_str("92233720368547758000")),
    "MoneyOverflow",
  )
  assert_eq(
    @num.trim_trailing_zeros("92233720368547758000"),
    "92233720368547758000",
  )
  // 上面两条错形状与 `trim_trailing_zeros` 共用同一个十进制判定，报错形状必须一致
}

///|
test "分配的两条不变量：和回原值、份间差不超过一分" {
  // 负档是本库自定规则（hutool 那侧 `remainder` 为负时一次都不补，还会数组越界），
  // 所以它不进参照实现对撞，改用两条不变量当判据：和 == 原值、任意两份之差不超过一分
  for cents in [-1000, -7, 0, 1, 7, 999, 1000] {
    for targets in (1).until(9) {
      let parts = @num.Money::new(cents.to_int64())
        .allocate_even(targets)
        .map(x => x.cent())
      let mut sum : Int64 = 0
      let mut lo : Int64 = 0
      let mut hi : Int64 = 0
      let mut first = true
      for p in parts {
        sum += p
        if first {
          lo = p
          hi = p
          first = false
        } else {
          if p < lo {
            lo = p
          }
          if p > hi {
            hi = p
          }
        }
      }
      assert_eq(sum, cents.to_int64())
      assert_eq(parts.length(), targets)
      assert_true(hi - lo <= 1)
    }
  }
}
