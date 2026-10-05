# num

hutool `NumberUtil` / `MathUtil` 的 MoonBit 对位·第一批：数论（`gcd` / `ext_gcd` / `mod_inverse` / `is_prime` / `isqrt`）、
只在精确域出的增长型算术（`lcm` / `factorial` / `combination_count` / `arrangement_count`）、
七档十进制舍入（`round_to_str` / `round_to` + `RoundingMode`）。

完整边界矩阵与逐条读数来源见 [`docs/spec/08-num.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/08-num.md)。本页只放**典型用法**，每条都带期望值——这些 `test` 块会被 `moon test` 真编译真执行。

> 状态：**契约已冻结、实现未开工**——`num/num.mbt` 的函数体是 `abort`，下面每个块的期望值此刻红是设计态。
> 期望串与 `num_test.mbt` 同受"期望值冻结"约束：实现期只许把红变绿（门禁 G5）。

## 这一包的立身之本是"哪一类算术不许出现在 `Int` 域"

`Int` 的位宽随目标变：`wasm` / `js` / `wasm-gc` 是 32 位，`native` 是 64 位。更糟的是**越界不报错**，
本机当场实测三条：`2147483647 * 2` 给 `-2`、`(-2147483648).abs()` 给 `-2147483648`、
`BigInt::from_string("2147483648").to_int()` 给 `-2147483648`——全是静默回绕。

所以本包有一条硬规则：**会增长的算术一律只在 `BigInt` 域出**（`lcm`、`factorial`、组合数、排列数），
`Int` 域只收"输出可证明不超过输入量级"的那几件（`gcd`、`ext_gcd`、`mod_inverse`、`is_prime`、`isqrt`）。
hutool 的 `multiple(int, int)` 正是卡在这里：它算完 `long` 再拿 `Integer.MAX_VALUE` 手工判界抛
`ArithmeticException`——那个界就是 int 上界，换个目标就换一个界，这种读数冻结不了。

```mbt check
///|
test "增长型算术在 BigInt 域：结果是真值而不是回绕值" {
  // 2147483647 与 3 的公倍数是 64 亿量级，任何一档 Int 都装不下
  let l = @num.lcm(
    @bigint.BigInt::from_int(2147483647),
    @bigint.BigInt::from_int(3),
  )
  assert_eq(l.to_string(), "6442450941")
  // 0 是每个整数的倍数 ⇒ lcm(0, x) = 0，不是"未定义"
  assert_eq(
    @num.lcm(@bigint.BigInt::from_int(0), @bigint.BigInt::from_int(7)).to_string(),
    "0",
  )
}
```

## 数论四件套：符号、零档与"逆元不存在"

`gcd` 的结果恒非负，`gcd(0, 0) = 0`。hutool 的 `NumberUtil.divisor` 是 `while (m % n != 0)`——
`n == 0` 直接崩，负输入原样带出负号（`divisor(-12, 8)` 给 `-4`），这两条本库都不跟随（spec §5）。

```mbt check
///|
test "gcd 恒非负，负输入不改变结果" {
  assert_eq(@num.gcd(12, 18), 6)
  assert_eq(@num.gcd(-12, 18), 6)
  assert_eq(@num.gcd(0, 0), 0)
  assert_eq(@num.gcd(0, 5), 5)
}
```

`ext_gcd` 出贝祖系数。系数**不唯一**，所以契约钉的是不变量 `s * a + t * b == g` 与两条界，
外加本库算法那一支的逐条读数——用例对 `[-20, 20]` 网格整片跑一遍这两条。

```mbt check
///|
test "ext_gcd 的读数与不变量" {
  assert_eq(@num.ext_gcd(240, 46), (-9, 47, 2))
  assert_eq(@num.ext_gcd(12, 18), (-1, 1, 6))
  // 负半边：g 恒非负，符号进系数
  assert_eq(@num.ext_gcd(-240, 46), (9, 47, 2))
  let (s, t, g) = @num.ext_gcd(240, 46)
  assert_eq(s * 240 + t * 46, g)
}
```

`mod_inverse` 取**最小非负剩余**，逆元不存在时报错而不是回 `-1`——`-1` 在模 11 下是个合法剩余类，
拿它当"失败"信号会和答案混起来（同 `coll` 不发明 `index_where` 那条立场）。

```mbt check
///|
test "mod_inverse 与它的两类报错" {
  assert_eq(@num.mod_inverse(3, 11), 4)
  assert_eq(@num.mod_inverse(-3, 11), 7)
  assert_eq(@num.mod_inverse(3, 11) * 3 % 11, 1)
  // 逆元不存在报 `NonCoprime`、模数 < 2 报 `InvalidModulus`，两类都带原读数。
  // `try/catch` 的两个分支必须同型，所以成功分支要显式占位（`expr catch {...}` 那条糖会拿
  // 被包表达式的类型去要求各个分支，`Int` 调用配 `String` 分支就编不过——这条坑已进仓内 AGENTS.md）
  let shape = try {
    let _ = @num.mod_inverse(0, 5)
    "未抛错"
  } catch {
    @num.NonCoprime(a, m) => "NonCoprime \{a} \{m}"
    @num.InvalidModulus(m) => "InvalidModulus \{m}"
    _ => "错种"
  }
  assert_eq(shape, "NonCoprime 0 5")
}
```

`is_prime` 是**确定性**试除，与 core 的 `@math.is_probable_prime(BigInt, Rand)`（概率件、要传熵源）分工不重叠；
`n < 2` 给 `false` 而不是报错（hutool 的 `isPrimes` 第一行就 `Assert.isTrue(n > 1)`，本库不跟随）。
`isqrt` 不经浮点：`Double` 只有 53 位尾数，拿 `sqrt` 再截断在大数上会失准。

```mbt check
///|
test "is_prime 的边界档与 isqrt 的精确档" {
  assert_eq(@num.is_prime(2), true)
  assert_eq(@num.is_prime(1), false)
  assert_eq(@num.is_prime(-7), false)
  assert_eq(@num.is_prime(2147483647), true) // 2^31 - 1 是梅森素数 M31
  assert_eq(@num.isqrt(2147395600), 46340)
  assert_eq(@num.isqrt(2147483647), 46340)
}
```

## 阶乘与组合：`20!` 不是上界

hutool `factorial(long)` 查表到 `20!`，`n > 20` 抛异常；本库走 `BigInt`，不设上界。
组合数按 hutool 的 `Combination.countBig` 逐条跟随（含它标 `@Deprecated` 的那条理由：
`big.longValue()` 会静默截断高位）；排列数与它**有一处分岔**——`m > n` 时 hutool 抛，
而组合那档给 `0`，同一本书两种口径，本库统一按数学值给 `0`。

```mbt check
///|
test "factorial 与两个计数函数" {
  assert_eq(@num.factorial(0).to_string(), "1")
  assert_eq(@num.factorial(20).to_string(), "2432902008176640000")
  assert_eq(@num.factorial(25).to_string(), "15511210043330985984000000") // hutool 这一档直接抛
  assert_eq(@num.combination_count(50, 6).to_string(), "15890700")
  assert_eq(@num.combination_count(5, 6).to_string(), "0")
  assert_eq(@num.arrangement_count(21, 21).to_string(), "51090942171709440000")
  assert_eq(@num.arrangement_count(3, 5).to_string(), "0") // hutool 那档抛 IllegalArgumentException
}
```

## 舍入：走最短十进制，不走"乘 100 再舍"

hutool `NumberUtil.round(double, scale, mode)` 的源码是 `round(Double.toString(v), scale, mode)`——
先拿到最短十进制串，再按十进制舍。本库同路。后果要用夹具钉住：`2.675` 舍到两位给 `2.68`。
"乘 100 再舍"那条天真实现会得 `2.67`，因为 `2.675` 的二进制真值是 `2.67499…`——那是另一种口径，
不是本件的读数（要十进制精确就取 `round_to_str` 的串）。

```mbt check
///|
test "十进制分岔与默认档 HalfUp" {
  assert_eq(@num.round_to_str(2.675, 2), "2.68")
  assert_eq(@num.round_to_str(2.675, 2, mode=@num.HalfDown), "2.67")
  assert_eq(@num.round_to_str(1.005, 2, mode=@num.HalfEven), "1.00")
  assert_eq(@num.round_to_str(3.0, 2), "3.00") // 小数位数恰好等于 scale
}
```

七档模式在**平局**与**非平局**上的分野，负半边才看得出 `Up`/`Down`（按绝对值）与
`Ceiling`/`Floor`（按数轴）不是一回事：

```mbt check
///|
test "七档模式在 ±2.5 与 ±2.1 上各自站哪边" {
  assert_eq(@num.round_to_str(2.5, 0, mode=@num.HalfUp), "3")
  assert_eq(@num.round_to_str(-2.5, 0, mode=@num.HalfUp), "-3")
  assert_eq(@num.round_to_str(-2.5, 0, mode=@num.HalfEven), "-2")
  assert_eq(@num.round_to_str(-2.1, 0, mode=@num.Ceiling), "-2")
  assert_eq(@num.round_to_str(-2.1, 0, mode=@num.Up), "-3")
  assert_eq(@num.round_to_str(-2.1, 0, mode=@num.Down), "-2")
}
```

`scale` 可以为负（舍到百位），结果用平格式写整数侧的零；`Double` 自己的十进制指数范围是
`[-323, 308]`（本机实测 `parse_double("1e309")` 报错、`"1e-324"` 给 `0`），界外的 `scale` 直接报错。
`NaN` / `±Infinity` 一律 `NotFinite`——本库不替它编一个 0。

```mbt check
///|
test "负 scale、指数记法与界外报错" {
  assert_eq(@num.round_to_str(1250.0, -2), "1300")
  assert_eq(@num.round_to_str(1250.0, -2, mode=@num.HalfEven), "1200")
  assert_eq(@num.round_to_str(1.0e21, 0), "1000000000000000000000")
  assert_eq(@num.round_to_str(1.0e-7, 9), "0.000000100")
  assert_eq(@num.round_to_str(-0.0, 2), "0.00") // 不保留负零
}
```

## 与 core 的分岔是本包唯一一条"同名不同意"

core 的 `Double::round()` 是 `floor(x + 0.5)`——**向数轴正方向**，实测 `(-0.5).round()` 给 `0`、
`(-3.5).round()` 给 `-3`。本包 `HalfUp` 按绝对值走。正因为这两个读数会分岔，本件**不叫 `round`**，
叫 `round_to`，并把分岔本身钉成用例：

```mbt check
///|
test "core 的 round 与本包 round_to 在负半边不同值" {
  assert_eq((-0.5).round(), 0.0)
  assert_eq(@num.round_to(-0.5, 0), -1.0)
  assert_eq(2.5.round(), @num.round_to(2.5, 0))
}
```
