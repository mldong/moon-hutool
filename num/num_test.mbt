///|
/// 把错误面折成字符串：变体名 + 携带值一起进断言——携带值也是契约的一部分（同 `coll`/`date` 的写法）
fn show(err : @num.NumError) -> String {
  match err {
    @num.ScaleOutOfRange(v) => "ScaleOutOfRange \{v}"
    @num.NotFinite => "NotFinite"
    @num.NegativeRadicand(v) => "NegativeRadicand \{v}"
    @num.InvalidModulus(v) => "InvalidModulus \{v}"
    @num.NonCoprime(a, m) => "NonCoprime \{a} \{m}"
    @num.NegativeFactorial(v) => "NegativeFactorial \{v}"
    @num.NegativeCount(n, m) => "NegativeCount \{n} \{m}"
  }
}

///|
/// 跑一次预期会 raise 的调用，返回错误形状；没 raise 就返回「未抛错」。
fn[A] err_shape(g : () -> A raise @num.NumError) -> String {
  try {
    let _ = g()
    "未抛错"
  } catch {
    err => show(err)
  }
}

///|
// 期望值全部由镜像算出：数论腿 = Python 标准库（gcd/isqrt/comb/perm/pow(a,-1,m)），
// 舍入腿 = Python Decimal(repr(x)) + 本机 Java 17 `BigDecimal.valueOf(v).setScale(s, mode)`
// 两腿逐条对撞后才冻结（改任何一条须单独一笔 + 外部读数来源，门禁 G5）。

///|
test "gcd 恒非负、0 档与符号档" {
  assert_eq(@num.gcd(12, 18), 6)
  assert_eq(@num.gcd(-12, 18), 6)
  assert_eq(@num.gcd(12, -18), 6)
  assert_eq(@num.gcd(-12, -18), 6)
  assert_eq(@num.gcd(0, 0), 0)
  assert_eq(@num.gcd(0, 5), 5)
  assert_eq(@num.gcd(-5, 0), 5)
  assert_eq(@num.gcd(17, 13), 1)
  assert_eq(@num.gcd(1, 1), 1)
  assert_eq(@num.gcd(2147483647, 2147483647), 2147483647)
  assert_eq(@num.gcd(2147483646, 2147483647), 1)
  assert_eq(@num.gcd(2310, 156), 6)
  assert_eq(@num.gcd(97, 101), 1)
  // 界与整除性：|gcd| 不超过两输入、且两边都整除（这条不靠字面量，靠输入区间跑一遍）
  for a in (-30).until(31) {
    for b in (-30).until(31) {
      let g = @num.gcd(a, b)
      assert_true(g >= 0)
      // 界：非零那一侧才有上界可谈（gcd(0, 5) = 5，若不加这条判据就会自己造出假红）
      if a != 0 {
        assert_true(g <= (if a < 0 { -a } else { a }))
      }
      if b != 0 {
        assert_true(g <= (if b < 0 { -b } else { b }))
      }
      if g != 0 {
        assert_eq(a % g, 0)
        assert_eq(b % g, 0)
      }
    }
  }
}

///|
test "ext_gcd 的逐条读数与贝祖不变量" {
  assert_eq(@num.ext_gcd(240, 46), (-9, 47, 2))
  assert_eq(@num.ext_gcd(12, 18), (-1, 1, 6))
  assert_eq(@num.ext_gcd(7, 5), (-2, 3, 1))
  assert_eq(@num.ext_gcd(-240, 46), (9, 47, 2))
  assert_eq(@num.ext_gcd(240, -46), (-9, -47, 2))
  assert_eq(@num.ext_gcd(0, 5), (0, 1, 5))
  assert_eq(@num.ext_gcd(5, 0), (1, 0, 5))
  assert_eq(@num.ext_gcd(0, 0), (1, 0, 0))
  assert_eq(@num.ext_gcd(1, 1), (0, 1, 1))
  assert_eq(@num.ext_gcd(-7, -5), (2, -3, 1))
  // 不变量网格：贝祖等式 + 与 gcd 同值 + 两条界（b=0 / a=0 那档界不适用，界是 |s|<=|b|/g）
  for a in (-20).until(21) {
    for b in (-20).until(21) {
      let (s, t, g) = @num.ext_gcd(a, b)
      assert_eq(s * a + t * b, g)
      assert_eq(g, @num.gcd(a, b))
      if b != 0 {
        assert_true(s.abs() * g <= b.abs())
      }
      if a != 0 {
        assert_true(t.abs() * g <= a.abs())
      }
    }
  }
}

///|
test "mod_inverse 取最小非负剩余" {
  assert_eq(@num.mod_inverse(3, 11), 4)
  assert_eq((@num.mod_inverse(3, 11).to_int64() * 3 % 11 + 11) % 11, 1)
  assert_eq(@num.mod_inverse(7, 26), 15)
  assert_eq((@num.mod_inverse(7, 26).to_int64() * 7 % 26 + 26) % 26, 1)
  assert_eq(@num.mod_inverse(1, 2), 1)
  assert_eq((@num.mod_inverse(1, 2).to_int64() * 1 % 2 + 2) % 2, 1)
  assert_eq(@num.mod_inverse(1234567, 9999991), 9411761)
  assert_eq(
    (
      @num.mod_inverse(1234567, 9999991).to_int64() * 1234567 % 9999991 +
      9999991
    ) %
    9999991,
    1,
  )
  assert_eq(@num.mod_inverse(-3, 11), 7)
  assert_eq((@num.mod_inverse(-3, 11).to_int64() * -3 % 11 + 11) % 11, 1)
  assert_eq(@num.mod_inverse(17, 2147483647), 252645135)
  assert_eq(
    (@num.mod_inverse(17, 2147483647).to_int64() * 17 % 2147483647 + 2147483647) %
    2147483647,
    1,
  )
}

///|
test "mod_inverse 的两类报错各带原读数" {
  assert_eq(err_shape(() => @num.mod_inverse(3, 1)), "InvalidModulus 1")
  assert_eq(err_shape(() => @num.mod_inverse(7, 0)), "InvalidModulus 0")
  assert_eq(err_shape(() => @num.mod_inverse(2, -5)), "InvalidModulus -5")
  assert_eq(err_shape(() => @num.mod_inverse(6, 9)), "NonCoprime 6 9")
  assert_eq(err_shape(() => @num.mod_inverse(0, 5)), "NonCoprime 0 5")
  assert_eq(err_shape(() => @num.mod_inverse(-2, 4)), "NonCoprime -2 4")
}

///|
test "is_prime 的 0/1/负数档与地标素数" {
  assert_eq(@num.is_prime(0), false)
  assert_eq(@num.is_prime(1), false)
  assert_eq(@num.is_prime(2), true)
  assert_eq(@num.is_prime(3), true)
  assert_eq(@num.is_prime(4), false)
  assert_eq(@num.is_prime(-7), false)
  assert_eq(@num.is_prime(25), false)
  assert_eq(@num.is_prime(7919), true)
  assert_eq(@num.is_prime(15485863), true)
  assert_eq(@num.is_prime(15485864), false)
  assert_eq(@num.is_prime(2147483647), true)
  assert_eq(@num.is_prime(2147483646), false)
  // 地标素数：2 是唯一的偶素数；7919 是第 1000 个素数；15485863 是第 100 万个；
  // 2147483647 = 2^31 - 1 是梅森素数 M31（这三条是数论常识读数，不是本库算出来的）
}

///|
test "isqrt 是 floor(sqrt(n))，负被开方数报错" {
  let r0 = @num.isqrt(0)
  assert_eq(r0, 0)
  assert_true(r0.to_int64() * r0.to_int64() <= 0)
  assert_true((r0 + 1).to_int64() * (r0 + 1).to_int64() > 0)
  let r1 = @num.isqrt(1)
  assert_eq(r1, 1)
  assert_true(r1.to_int64() * r1.to_int64() <= 1)
  assert_true((r1 + 1).to_int64() * (r1 + 1).to_int64() > 1)
  let r2 = @num.isqrt(4)
  assert_eq(r2, 2)
  assert_true(r2.to_int64() * r2.to_int64() <= 4)
  assert_true((r2 + 1).to_int64() * (r2 + 1).to_int64() > 4)
  let r3 = @num.isqrt(8)
  assert_eq(r3, 2)
  assert_true(r3.to_int64() * r3.to_int64() <= 8)
  assert_true((r3 + 1).to_int64() * (r3 + 1).to_int64() > 8)
  let r4 = @num.isqrt(9)
  assert_eq(r4, 3)
  assert_true(r4.to_int64() * r4.to_int64() <= 9)
  assert_true((r4 + 1).to_int64() * (r4 + 1).to_int64() > 9)
  let r5 = @num.isqrt(2147395600)
  assert_eq(r5, 46340)
  assert_true(r5.to_int64() * r5.to_int64() <= 2147395600)
  assert_true((r5 + 1).to_int64() * (r5 + 1).to_int64() > 2147395600)
  let r6 = @num.isqrt(2147483647)
  assert_eq(r6, 46340)
  assert_true(r6.to_int64() * r6.to_int64() <= 2147483647)
  assert_true((r6 + 1).to_int64() * (r6 + 1).to_int64() > 2147483647)
  assert_eq(err_shape(() => @num.isqrt(-1)), "NegativeRadicand -1")
}

///|
test "lcm 只在 BigInt 域（结果可超 Int）" {
  // 全串比对：BigInt 的读数用十进制串钉死，避免任何一次 `.to_int()` 静默回绕（spec §0.1）
  assert_eq(
    @num.lcm(@bigint.BigInt::from_string("0"), @bigint.BigInt::from_string("0")).to_string(),
    "0",
  )
  assert_eq(
    @num.lcm(@bigint.BigInt::from_string("0"), @bigint.BigInt::from_string("7")).to_string(),
    "0",
  )
  assert_eq(
    @num.lcm(
      @bigint.BigInt::from_string("12"),
      @bigint.BigInt::from_string("18"),
    ).to_string(),
    "36",
  )
  assert_eq(
    @num.lcm(
      @bigint.BigInt::from_string("-4"),
      @bigint.BigInt::from_string("6"),
    ).to_string(),
    "12",
  )
  assert_eq(
    @num.lcm(
      @bigint.BigInt::from_string("-4"),
      @bigint.BigInt::from_string("-6"),
    ).to_string(),
    "12",
  )
  assert_eq(
    @num.lcm(
      @bigint.BigInt::from_string("2147483647"),
      @bigint.BigInt::from_string("3"),
    ).to_string(),
    "6442450941",
  )
  assert_eq(
    @num.lcm(
      @bigint.BigInt::from_string("103903"),
      @bigint.BigInt::from_string("132949"),
    ).to_string(),
    "13813799947",
  )
  assert_eq(
    @num.lcm(@bigint.BigInt::from_int(0), @bigint.BigInt::from_int(0)).to_string(),
    "0",
  )
}

///|
test "factorial 不设 20 的上界" {
  assert_eq(@num.factorial(0).to_string(), "1")
  assert_eq(@num.factorial(1).to_string(), "1")
  assert_eq(@num.factorial(5).to_string(), "120")
  assert_eq(@num.factorial(12).to_string(), "479001600")
  assert_eq(@num.factorial(20).to_string(), "2432902008176640000")
  assert_eq(@num.factorial(21).to_string(), "51090942171709440000")
  assert_eq(@num.factorial(25).to_string(), "15511210043330985984000000")
  // 20! 是 hutool `factorial(long)` 查表的上界，21! 与 25! 那一档它直接抛异常（spec #8.7）
  assert_eq(err_shape(() => @num.factorial(-1)), "NegativeFactorial -1")
}

///|
test "组合数与排列数：m>n 给 0，负数报错" {
  assert_eq(@num.combination_count(5, 2).to_string(), "10")
  assert_eq(@num.combination_count(50, 6).to_string(), "15890700")
  assert_eq(@num.combination_count(5, 0).to_string(), "1")
  assert_eq(@num.combination_count(5, 5).to_string(), "1")
  assert_eq(@num.combination_count(5, 6).to_string(), "0")
  assert_eq(@num.combination_count(30, 15).to_string(), "155117520")
  assert_eq(@num.arrangement_count(5, 2).to_string(), "20")
  assert_eq(@num.arrangement_count(10, 3).to_string(), "720")
  assert_eq(@num.arrangement_count(7, 0).to_string(), "1")
  assert_eq(@num.arrangement_count(20, 20).to_string(), "2432902008176640000")
  assert_eq(@num.arrangement_count(3, 5).to_string(), "0")
  assert_eq(@num.arrangement_count(21, 21).to_string(), "51090942171709440000")
  // m > n 一律给 0：组合数按 hutool `countBig` 跟随，排列数按数学值收（hutool 那一档抛，见 spec §5）
  assert_eq(
    err_shape(() => @num.combination_count(-1, 2)),
    "NegativeCount -1 2",
  )
  assert_eq(
    err_shape(() => @num.arrangement_count(3, -1)),
    "NegativeCount 3 -1",
  )
}

///|
test "十进制分岔：2.675 与 1.005 这类最短十进制档" {
  assert_eq(@num.round_to_str(2.675, 2, mode=@num.HalfUp), "2.68")
  assert_eq(@num.round_to_str(2.675, 2, mode=@num.HalfDown), "2.67")
  assert_eq(@num.round_to_str(2.675, 2, mode=@num.HalfEven), "2.68")
  assert_eq(@num.round_to_str(1.005, 2, mode=@num.HalfUp), "1.01")
  assert_eq(@num.round_to_str(1.005, 2, mode=@num.HalfEven), "1.00")
}

///|
test "半值网格上三档平局模式（±2.5 / ±0.5）" {
  assert_eq(@num.round_to_str(2.5, 0, mode=@num.HalfUp), "3")
  assert_eq(@num.round_to_str(2.5, 0, mode=@num.HalfDown), "2")
  assert_eq(@num.round_to_str(2.5, 0, mode=@num.HalfEven), "2")
  assert_eq(@num.round_to_str(-2.5, 0, mode=@num.HalfUp), "-3")
  assert_eq(@num.round_to_str(-2.5, 0, mode=@num.HalfDown), "-2")
  assert_eq(@num.round_to_str(-2.5, 0, mode=@num.HalfEven), "-2")
  assert_eq(@num.round_to_str(0.5, 0, mode=@num.HalfUp), "1")
  assert_eq(@num.round_to_str(-0.5, 0, mode=@num.HalfUp), "-1")
  assert_eq(@num.round_to_str(-0.5, 0, mode=@num.Ceiling), "0")
  assert_eq(@num.round_to_str(-0.5, 0, mode=@num.Floor), "-1")
  assert_eq(@num.round_to_str(-0.5, 0, mode=@num.Up), "-1")
  assert_eq(@num.round_to_str(-0.5, 0, mode=@num.Down), "0")
  assert_eq(@num.round_to_str(-0.5, 0, mode=@num.HalfEven), "0")
}

///|
test "非平局时 Up/Down 与 Ceiling/Floor 分道" {
  assert_eq(@num.round_to_str(2.1, 0, mode=@num.Up), "3")
  assert_eq(@num.round_to_str(2.1, 0, mode=@num.Down), "2")
  assert_eq(@num.round_to_str(-2.1, 0, mode=@num.Ceiling), "-2")
  assert_eq(@num.round_to_str(-2.1, 0, mode=@num.Floor), "-3")
}

///|
test "负 scale、指数记法与补零位" {
  assert_eq(@num.round_to_str(3.0, 2, mode=@num.HalfUp), "3.00")
  assert_eq(@num.round_to_str(0.30000000000000004, 1, mode=@num.HalfUp), "0.3")
  assert_eq(
    @num.round_to_str(0.30000000000000004, 17, mode=@num.HalfUp),
    "0.30000000000000004",
  )
  assert_eq(@num.round_to_str(1234.5, -2, mode=@num.HalfUp), "1200")
  assert_eq(@num.round_to_str(1250.0, -2, mode=@num.HalfUp), "1300")
  assert_eq(@num.round_to_str(1250.0, -2, mode=@num.HalfEven), "1200")
  assert_eq(@num.round_to_str(100.0, -1, mode=@num.HalfUp), "100")
  assert_eq(
    @num.round_to_str(1.0e21, 0, mode=@num.HalfUp),
    "1000000000000000000000",
  )
  assert_eq(@num.round_to_str(1.0e-07, 9, mode=@num.HalfUp), "0.000000100")
  assert_eq(@num.round_to_str(-0.0, 2, mode=@num.HalfUp), "0.00")
  assert_eq(@num.round_to_str(0.0, 0, mode=@num.HalfUp), "0")
  assert_eq(
    @num.round_to_str(123456789.0, 3, mode=@num.HalfUp),
    "123456789.000",
  )
  assert_eq(@num.round_to_str(2.345678, 4, mode=@num.HalfEven), "2.3457")
  assert_eq(@num.round_to_str(9.996, 2, mode=@num.HalfUp), "10.00")
}

///|
test "省掉 mode 就是 HalfUp" {
  // 省掉 mode 实参 = HalfUp（hutool `round(v, scale)` 的默认档，源码 `RoundingMode.HALF_UP`）
  assert_eq(@num.round_to_str(2.675, 2), "2.68")
  assert_eq(@num.round_to_str(1.005, 2), "1.01")
  assert_eq(@num.round_to_str(2.5, 0), "3")
  assert_eq(@num.round_to_str(-2.5, 0), "-3")
  assert_eq(@num.round_to_str(0.5, 0), "1")
  assert_eq(@num.round_to_str(-0.5, 0), "-1")
  assert_eq(@num.round_to_str(3.0, 2), "3.00")
  assert_eq(@num.round_to_str(0.30000000000000004, 1), "0.3")
  assert_eq(@num.round_to_str(0.30000000000000004, 17), "0.30000000000000004")
  assert_eq(@num.round_to_str(1234.5, -2), "1200")
  assert_eq(@num.round_to_str(1250.0, -2), "1300")
  assert_eq(@num.round_to_str(100.0, -1), "100")
  assert_eq(@num.round_to_str(1.0e21, 0), "1000000000000000000000")
  assert_eq(@num.round_to_str(1.0e-07, 9), "0.000000100")
  assert_eq(@num.round_to_str(-0.0, 2), "0.00")
  assert_eq(@num.round_to_str(0.0, 0), "0")
  assert_eq(@num.round_to_str(123456789.0, 3), "123456789.000")
  assert_eq(@num.round_to_str(9.996, 2), "10.00")
}

///|
test "round_to 出 Double：舍入后回到最近可表值" {
  assert_eq(@num.round_to(2.675, 2), 2.68)
  assert_eq(@num.round_to(1.005, 2), 1.01)
  assert_eq(@num.round_to(2.5, 0), 3.0)
  assert_eq(@num.round_to(-2.5, 0), -3.0)
  assert_eq(@num.round_to(0.5, 0), 1.0)
  assert_eq(@num.round_to(-0.5, 0), -1.0)
  assert_eq(@num.round_to(3.0, 2), 3.0)
  assert_eq(@num.round_to(0.30000000000000004, 1), 0.3)
  assert_eq(@num.round_to(0.30000000000000004, 17), 0.30000000000000004)
  assert_eq(@num.round_to(1234.5, -2), 1200.0)
  assert_eq(@num.round_to(1250.0, -2), 1300.0)
  assert_eq(@num.round_to(100.0, -1), 100.0)
  assert_eq(@num.round_to(1.0e-07, 9), 1.0e-07)
  assert_eq(@num.round_to(-0.0, 2), 0.0)
  assert_eq(@num.round_to(0.0, 0), 0.0)
  assert_eq(@num.round_to(123456789.0, 3), 123456789.0)
  assert_eq(@num.round_to(9.996, 2), 10.0)
}

///|
test "NaN/无穷与 scale 界外一律报错" {
  // NaN / ±Infinity：没有十进制舍入这回事
  assert_eq(
    err_shape(() => @num.round_to(@double.not_a_number, 2)),
    "NotFinite",
  )
  assert_eq(
    err_shape(() => @num.round_to_str(@double.not_a_number, 2)),
    "NotFinite",
  )
  assert_eq(err_shape(() => @num.round_to(@double.infinity, 2)), "NotFinite")
  assert_eq(
    err_shape(() => @num.round_to_str(@double.infinity, 2)),
    "NotFinite",
  )
  assert_eq(
    err_shape(() => @num.round_to(@double.neg_infinity, 2)),
    "NotFinite",
  )
  assert_eq(
    err_shape(() => @num.round_to_str(@double.neg_infinity, 2)),
    "NotFinite",
  )
  // scale 界外：Double 自己的十进制指数范围是 [-323, 308]
  assert_eq(err_shape(() => @num.round_to_str(1.5, 309)), "ScaleOutOfRange 309")
  assert_eq(err_shape(() => @num.round_to(1.5, 309)), "ScaleOutOfRange 309")
  assert_eq(
    err_shape(() => @num.round_to_str(1.5, -324)),
    "ScaleOutOfRange -324",
  )
  assert_eq(err_shape(() => @num.round_to(1.5, -324)), "ScaleOutOfRange -324")
  assert_eq(
    err_shape(() => @num.round_to_str(1.5, 100000)),
    "ScaleOutOfRange 100000",
  )
  assert_eq(
    err_shape(() => @num.round_to(1.5, 100000)),
    "ScaleOutOfRange 100000",
  )
  // 界内两端要能跑通：308 位小数就是 '0.' 后面挂 308 个零
  assert_eq(@num.round_to_str(0.0, 308).length(), 2 + 308)
  assert_eq(@num.round_to_str(0.0, -323), "0")
}

///|
test "分岔夹具：core 的 round 与本包 HalfUp 在负半边不同" {
  // core 的 `Double::round()` 实测是 floor(x + 0.5)：向数轴正方向，不看符号
  assert_eq((-0.5).round(), 0.0)
  assert_eq((-3.5).round(), -3.0)
  // 本包 HalfUp 按绝对值走：同一输入两个读数，这条夹具就是让两者不许互相漂移
  assert_eq(@num.round_to(-0.5, 0), -1.0)
  assert_eq(@num.round_to(-3.5, 0), -4.0)
  // 正半值两边一致（分岔只在负半边）
  assert_eq(0.5.round(), @num.round_to(0.5, 0))
  assert_eq(2.5.round(), @num.round_to(2.5, 0))
}
