///|
/// moon-hutool/num —— 数值计算件（hutool `NumberUtil` / `MathUtil` 的 MoonBit 对位·第一批）
///
/// 契约：`docs/spec/08-num.md`。期望值权威在 `num_test.mbt` 与 spec 的读数表——改任何期望串须单独一笔
/// 并给外部读数来源（门禁 G5），实现只负责把契约里冻好的读数算出来。
///
/// 第一批做**数论 + 十进制舍入**两格，外加只在精确域出的增长型算术。
/// 第二批（#8.14~#8.25）是**输出形状不同的那一半**：千分位与百分比、`trim_trailing_zeros`、
/// 薄 `Money`（"分"这个 `Int64` + 两种分配）。剩下两格各自是一整块，不混进来：
/// 中文数字与英文 word（第三批）、`Calculator` 表达式求值（第四批）。
/// 分界的理由与本批逐条读数来源见 spec §1、§4、§6。
///
/// 四条贯穿性规则（spec §0，这四条决定了本包哪些函数存在、哪些不存在）：
/// 1. **Int 域只收「输出可证明不超过输入量级」的函数**。`Int` 的位宽随目标变（`wasm`/`js`/`wasm-gc` 是 32 位，
///    `native` 是 64 位），而且**越界不报错**：当场实测 `2147483647 * 2` 给 `-2`、`(-2147483648).abs()`
///    给 `-2147483648`、`BigInt::from_string("2147483648").to_int()` 给 `-2147483648`——全是静默回绕。
///    所以会增长的算术（`lcm`、`factorial`、组合数、排列数）一律只在 `BigInt` 域出，不给出第二档。
/// 2. **十进制舍入按最短十进制走**，与 hutool 同路（`NumberUtil.round(double, scale, mode)` 源码就是
///    `round(Double.toString(v), scale, mode)`）。这条不是实现细节而是契约：`2.675` 保留两位给 `2.68`
///    （最短十进制就是 2.675），而"先乘 100 再舍入"那条天真路给 `2.67`（2.675 的真值是 2.67499…）。
/// 3. **错误只带读数**，不带文案，也不带能从输入算出来的常数。
/// 4. **core 有的不重新包装**：`abs`/`min`/`max`/`clamp`/`signum`/`sqrt`/`pow`/`round`/`is_close`/`lerp`
///    在 `Int`/`Double` 上都是现成方法，`@math` 有三角/对数/`scalbn`/二元 `maximum`/`minimum` 与
///    `is_probable_prime`，`@bigint` 有 `pow(exp, modulus?)`。本包一个都不再造同名件（spec §1 逐条列）。

///|
/// 本包唯一错误面。每个变体对应**一个** `raise` 点，载荷只放调用方拿不到的读数
pub suberror NumError {
  /// 给进来的 `scale`（`> 308` 或 `< -323` 的那个值——`Double` 的十进制指数范围之外，舍入没有意义）
  ScaleOutOfRange(Int)
  /// 收到 `NaN` / `±Infinity`（没有十进制舍入这回事，也不替它编一个 0）
  NotFinite
  /// 被开方数 `< 0`（实数域无解；本库不返回 `NaN`，因为 `NaN` 是"值"而这是"没定义"）
  NegativeRadicand(Int)
  /// 模数 `< 2` 的那一个给进来的值（模 1 只剩剩余类 0，负模与 0 模都不是环）
  InvalidModulus(Int)
  /// `(a, m)` 原样两个读数：互质判据没过，`gcd(a, m) != 1` ⇒ 逆元不存在
  NonCoprime(Int, Int)
  /// 给进来的 `n`（`< 0` 的那个值——负数没有阶乘）
  NegativeFactorial(Int)
  /// `(n, m)` 原样两个读数：组合数/排列数的阶乘定义域是自然数
  NegativeCount(Int, Int)
  /// 给进来的原串：它不是一个十进制数（第二批的 `trim_trailing_zeros` / `Money::from_yuan_str` 用）
  NotDecimal(String)
  /// 给进来的份数（`<= 0` 的那个值——分成 0 份不是"空分配"，是没有答案）
  NonPositiveTargets(Int)
  /// 给进来的那个负比例（比例分配里每一项都必须 `>= 0`）
  NegativeRatio(Int)
  /// 比例的**和**（`<= 0` 时没有分母可用；带和是因为逐项符号可能互相抵消，调用方不易一眼看出）
  RatioSumNotPositive(Int64)
  /// 分的加减或 `cent * ratio` 超出 `Int64` 可表范围。
  /// **不带载荷**：两个操作数调用方都有，"越界"这件事本身就是新信息（同 `mapx` 的不带载荷立场）
  MoneyOverflow
  // ---- 第三批（中文数字与英文 word）新增三条：界与反向文法 ----
  ///
  /// 数值越出中文数字件支持的界（±99_9999_9999_9999.99，或千分位档的 ±999）。
  /// 只带原始读数，不带 hutool 那句 `Number support only: …` 文案。
  OutOfRange(String)
  ///
  /// 反向解析撞到不认的单位字，带那个字与它的位置（0 基码点下标）。
  UnknownChineseUnit(Char, Int)
  ///
  /// 反向解析撞到"单位字后面又跟了个数字字"这类坏形状，带 hutool 同款的两字窗口与位置。
  BadChineseNumber(String, Int)
}

///|
/// 七档十进制舍入模式，逐档对齐 `java.math.RoundingMode`（hutool 的 `round` 就是拿它当参数用的）。
/// **不含** `UNNECESSARY`：那一档的语义是"舍入必须无损，否则报错"，hutool 侧没有对应入口，本库也不发明。
///
/// 三组语义不要记混（读数表在 spec #8.10）：
/// - `HalfUp` / `HalfDown` / `HalfEven`：**平局**（正好一半）时向绝对值大 / 绝对值小 / 偶数一侧走
/// - `Up` / `Down`：**一律**向绝对值大 / 绝对值小的方向去尾（非平局也一样）
/// - `Ceiling` / `Floor`：**一律**向数轴正方向 / 负方向（与符号无关，这条和 `Up`/`Down` 在负数上分岔）
pub(all) enum RoundingMode {
  /// 向绝对值增大的方向（`2.1 -> 3`，`-2.1 -> -3`）
  Up
  /// 向绝对值减小的方向，即截断（`2.9 -> 2`，`-2.9 -> -2`）
  Down
  /// 向数轴正方向（`2.1 -> 3`，`-2.1 -> -2`）
  Ceiling
  /// 向数轴负方向（`2.1 -> 2`，`-2.1 -> -3`）
  Floor
  /// 平局向绝对值增大（`2.5 -> 3`，`-2.5 -> -3`）——**本包默认档**，同 hutool `round(v, scale)`
  HalfUp
  /// 平局向绝对值减小（`2.5 -> 2`，`-2.5 -> -2`）
  HalfDown
  /// 平局向偶数（`2.5 -> 2`，`3.5 -> 4`，`-0.5 -> 0`）——统计学/IEEE 754 默认档
  HalfEven
}

///|
/// 最大公约数。`gcd(a, b) = gcd(|a|, |b|)`，结果**恒非负**
///
/// - Parameters:
///   - `a`, `b`：任意 `Int`。两者都为 0 时给 0（`gcd(0, 0) = 0` 是恒等元约定，不是"未定义"）
/// - Returns: 非负公约数里最大的一个；`gcd(0, n) = |n|`
/// - Note: hutool 对位 `NumberUtil.divisor(int, int)`，但它**不跟随**：源码是
///   `while (m % n != 0) { … } return n`——`n == 0` 直接除零崩，负输入原样带出负号
///   （`divisor(-12, 8)` 给 `-4`）。本库把符号与 0 档都收进契约（逐条读数在 spec #8.1）
/// - Note: 结果可表性：`|gcd| <= min(|a|, |b|)`，所以除 `Int::MIN` 自反那一档（wasm 上 2^31 不可表）
///   外恒在 `Int` 内；那一档按 core 同类件的立场交给 `abort`，本包不为其发明错误码（spec §0.1）
/// - 复杂度：欧几里得辗转，O(log min(|a|,|b|))
pub fn gcd(a : Int, b : Int) -> Int {
  i64_to_int(gcd64(a.to_int64(), b.to_int64()))
}

///|
/// 扩展欧几里得：返回 `(s, t, g)` 使 `s * a + t * b == g == gcd(a, b)`（贝祖系数）
///
/// - Parameters:
///   - `a`, `b`：任意 `Int`
/// - Returns: 三元组，`g` 与 `gcd(a, b)` 逐输入相等；`s`、`t` 可为负
/// - Note: **贝祖系数不唯一**（`(s + k*b/g, t - k*a/g)` 全都成立），所以契约钉的是不变量 +
///   本库算法那一支的逐条读数，而不是"唯一解"。可依赖的界是 `|s| <= |b|/g`、`|t| <= |a|/g`
///   （用例对 [-20, 20] 网格逐条断言这两条界与不变量，见 spec #8.2）
/// - Note: `g == 0`（`a = b = 0`）时 `(s, t)` 取 `(1, 0)`——那是算法那一支的读数，
///   不变量成立；不要把它读成"逆元"
/// - Note: hutool 无对位件（`NumberUtil` 只有 `divisor`）；这一件是为 RSA/模逆而补的，
///   与 `mod_inverse` 同族但**独立公开**，因为调用方要的是系数本身
pub fn ext_gcd(a : Int, b : Int) -> (Int, Int, Int) {
  let (s, t, g) = ext_gcd64(a.to_int64(), b.to_int64())
  (i64_to_int(s), i64_to_int(t), i64_to_int(g))
}

///|
/// 模逆元：`a` 在模 `m` 下的乘法逆，取**最小非负剩余**（结果落在 `[0, m)`）
///
/// - Parameters:
///   - `a`：被求逆的数，可为负（内部先归到 `[0, m)`，所以 `-3 mod 11` 与 `8 mod 11` 同逆元）
///   - `m`：模数，必须 `>= 2`
/// - Returns: `x` 使 `a * x ≡ 1 (mod m)`
/// - Raises:
///   - `NumError.InvalidModulus(m)`：`m < 2`
///   - `NumError.NonCoprime(a, m)`：`gcd(a, m) != 1`（逆元不存在，不返回 0 也不返回 -1）
/// - Note: hutool 无对位件；`java.math.BigInteger.modInverse` 是同语义参照（它给 `[0, m)` 档，
///   与本库一致）。本库在 `Int` 域给出同一档，中间量走 `Int64`（64 位定宽，不随目标变）
/// - 复杂度：扩展欧几里得，O(log m)
pub fn mod_inverse(a : Int, m : Int) -> Int raise NumError {
  if m < 2 {
    raise InvalidModulus(m)
  }
  let a64 = a.to_int64()
  let m64 = m.to_int64()
  if gcd64(a64, m64) != 1 {
    raise NonCoprime(a, m)
  }
  let (s, _, _) = ext_gcd64(a64, m64)
  // 归到最小非负剩余：MoonBit 的 `%` 与 Java 同号（实测 -7 % 2 = -1），所以要补一次模数
  i64_to_int((s % m64 + m64) % m64)
}

///|
/// 素数判定（**确定性**试除，不是概率判定）
///
/// - Parameters:
///   - `n`：任意 `Int`
/// - Returns: `n` 是素数则 `true`。`n < 2` 一律 `false`（0、1、负数都不是素数——不报错）
/// - Note: 与 core 的分工：`@math.is_probable_prime(BigInt, Rand)` 是**概率**件且要传熵源，
///   判定大数用的；本件在 `Int` 域给确定答案，不需要熵、不注入时钟，所以三档读数恒等
/// - Note: hutool 对位 `NumberUtil.isPrimes(int)`，但它**不跟随**：源码第一行
///   `Assert.isTrue(n > 1, …)`——`isPrimes(1)` 抛异常而不是给 `false`。判定函数报异常会让
///   "1 是不是素数"这种问题无法回答（逐条差异声明见 spec §5）
/// - 复杂度：试除到 `sqrt(n)` 的 6k±1 档，O(√n)；`Int` 域最坏 2^31 档约 46340 次迭代，够用
pub fn is_prime(n : Int) -> Bool {
  let v = n.to_int64()
  if v < 2 {
    false
  } else if v % 2 == 0 {
    v == 2
  } else if v % 3 == 0 {
    v == 3
  } else {
    // 6k±1 试除；写 `i <= v / i` 而不是 `i * i <= v`，后者在 native 档的大 Int 上会自己先溢出
    let mut i : Int64 = 5
    let mut prime = true
    while i <= v / i {
      if v % i == 0 || v % (i + 2) == 0 {
        prime = false
        break
      }
      i += 6
    }
    prime
  }
}

///|
/// 整数平方根（向下取整）：`isqrt(n)` 是满足 `x * x <= n` 的最大非负 `x`
///
/// - Parameters:
///   - `n`：被开方数，必须 `>= 0`
/// - Returns: `floor(sqrt(n))`，精确到整数，**不经浮点**（`Double` 只有 53 位尾数，大数会失准）
/// - Raises: `NumError.NegativeRadicand(n)`：`n < 0`
/// - Note: hutool 对位 `NumberUtil.sqrt(long)`（逐位开方法）。它**没有负数防线**：
///   `sqrt(-1)` 静默给一个正数读数。本库把这一档改成 `raise`
/// - Note: 读数来源 = Python `math.isqrt`（同为精确整数开方，独立实现）
pub fn isqrt(n : Int) -> Int raise NumError {
  if n < 0 {
    raise NegativeRadicand(n)
  }
  // 逐位开方（hutool `sqrt(long)` 同族算法），全程 Int64 定宽、不经浮点
  let mut num = n.to_int64()
  let mut res : Int64 = 0
  let mut bit : Int64 = 4611686018427387904 // 2^62：Int64 范围内最大的 4 的幂
  while bit > num {
    bit = bit >> 2
  }
  while bit != 0 {
    if num >= res + bit {
      num -= res + bit
      res = (res >> 1) + bit
    } else {
      res = res >> 1
    }
    bit = bit >> 2
  }
  i64_to_int(res)
}

///|
/// 最小公倍数——**只在 `BigInt` 域**，`Int` 域不提供同名件
///
/// - Parameters:
///   - `a`, `b`：任意 `BigInt`
/// - Returns: 非负的最小公共倍数；`lcm(0, x) = 0`（0 是每个整数的倍数），符号一律抹掉
/// - Note: 为什么没有 `Int` 版（spec §0.1、#8.6）：`lcm` 是增长型算术，结果可以远超输入位宽，
///   而"是否越界"取决于目标（wasm 32 位 / native 64 位）——同一条读数在三档与 native 上一个溢出、
///   一个正常，**冻结不了**。hutool 的 `multiple(int, int)` 正是卡在这里：它先算 `long`
///   再拿 `Integer.MAX_VALUE` 手工判界并抛 `ArithmeticException`，那个界就是 int 上界
/// - Note: 小整数用着不别扭：`lcm(BigInt::from_int(12), BigInt::from_int(18))`，
///   取回 `Int` 由调用方自己决定（`.to_int()` 会静默回绕，见 spec §0.1 的三条实测）
pub fn lcm(a : @bigint.BigInt, b : @bigint.BigInt) -> @bigint.BigInt {
  if a.is_zero() || b.is_zero() {
    // 0 是每个整数的倍数 ⇒ lcm(0, x) = 0，这是定义而不是特例补丁
    @bigint.BigInt::from_int(0)
  } else {
    let g = big_gcd(a, b)
    big_abs(a).div(g).mul(big_abs(b))
  }
}

///|
/// 阶乘，`BigInt` 精确域
///
/// - Parameters:
///   - `n`：`>= 0`
/// - Returns: `n!`。`0! = 1`
/// - Raises: `NumError.NegativeFactorial(n)`：`n < 0`
/// - Note: hutool 对位 `NumberUtil.factorial(long)`，它查表到 `20!`（`long` 装得下的最大档），
///   `n > 20` 直接抛 `IllegalArgumentException`。**本库不设上界**：`25!` 与 `100!` 都是可回答的
///   问题，只是回答的形状是 `BigInt`（`BigInteger` 版 hutool 也有，本库把它当唯一一档）
pub fn factorial(n : Int) -> @bigint.BigInt raise NumError {
  if n < 0 {
    raise NegativeFactorial(n)
  }
  let mut acc = @bigint.BigInt::from_int(1)
  let mut i = 2
  while i <= n {
    acc = acc.mul(@bigint.BigInt::from_int(i))
    i += 1
  }
  acc
}

///|
/// 组合数 `C(n, m)`（从 `n` 个里取 `m` 个，不计顺序）
///
/// - Parameters:
///   - `n`, `m`：均须 `>= 0`
/// - Returns: `n! / (m! (n-m)!)`，走 `BigInt`。**`m > n` 给 0**（数学上就是 0，不是错误）
/// - Raises: `NumError.NegativeCount(n, m)`：`n < 0` 或 `m < 0`
/// - Note: hutool 对位 `MathUtil.combinationCount` → `Combination.countBig`，本库逐条跟随它：
///   负数抛、`m > n` 给 0、`m == 0 || m == n` 给 1、取 `m = min(m, n - m)` 后用**每步整除**的
///   迭代式（`result = result * (n - m + i) / i`，每步都是整除，不落分数）
/// - Note: hutool 另有一档 `Combination.count`（返回 `long`）**已标 `@Deprecated`**，
///   原因是 `big.longValue()` 会静默截断高位；`countSafe` 用 `longValueExact()` 抛异常。
///   本库只出精确那一档，截断与判界都不做
pub fn combination_count(n : Int, m : Int) -> @bigint.BigInt raise NumError {
  if n < 0 || m < 0 {
    raise NegativeCount(n, m)
  }
  if m > n {
    @bigint.BigInt::from_int(0)
  } else {
    let k = if m > n - m { n - m } else { m }
    let mut result = @bigint.BigInt::from_int(1)
    let mut i = 1
    while i <= k {
      // 每步都整除（前缀积性质），所以全程不落分数
      result = result
        .mul(@bigint.BigInt::from_int(n - k + i))
        .div(@bigint.BigInt::from_int(i))
      i += 1
    }
    result
  }
}

///|
/// 排列数 `A(n, m)`（从 `n` 个里取 `m` 个并计顺序，`= n! / (n-m)!`）
///
/// - Parameters:
///   - `n`, `m`：均须 `>= 0`
/// - Returns: `n * (n-1) * … * (n-m+1)`，走 `BigInt`；`m == 0` 给 1；**`m > n` 给 0**
/// - Raises: `NumError.NegativeCount(n, m)`：`n < 0` 或 `m < 0`
/// - Note: 与 hutool 的**一处口径分岔**（spec §5）：`Arrangement.count` 在 `m > n` 时抛
///   `IllegalArgumentException`，而同包的 `Combination.countBig` 在同样情形给 `0`——一本书里两个
///   函数两种口径。本库统一按数学值给 `0`，并把这条差异写明，不让调用方去猜
/// - Note: 溢出档：hutool 的 `long` 版在 `A(21, 21)` 这一档靠 `next < result` 检出并抛
///   `ArithmeticException`；本库 `BigInt` 直接给 `21!` 的真值（用例钉的就是这一档）
pub fn arrangement_count(n : Int, m : Int) -> @bigint.BigInt raise NumError {
  if n < 0 || m < 0 {
    raise NegativeCount(n, m)
  }
  if m > n {
    // 与 hutool 的唯一分岔：那侧 `Arrangement.count` 抛，同包组合数却给 0；本库统一按数学值
    @bigint.BigInt::from_int(0)
  } else {
    let mut result = @bigint.BigInt::from_int(1)
    let mut i = 0
    while i < m {
      result = result.mul(@bigint.BigInt::from_int(n - i))
      i += 1
    }
    result
  }
}

///|
/// 按十进制舍入模式把 `x` 舍到 `scale` 位小数，出**平格式字符串**（永不指数记法）
///
/// - Parameters:
///   - `x`：任意有限 `Double`
///   - `scale`：小数位数，可为负（`-2` 就是舍到百位）。可表范围 `[-323, 308]`——这是 `Double`
///     自己的十进制指数范围（实测：`parse_double("1e309")` 报错、`"1e-324"` 给 `0`）
///   - `mode`：舍入模式，默认 `HalfUp`（同 hutool `round(v, scale)` 的默认档）
/// - Returns: 平格式十进制串。**小数位数恰好等于 `scale`**（`3.0` 舍到 2 位给 `"3.00"`，
///   `1e21` 舍到 0 位给 22 位整串 `"1000000000000000000000"`），`scale < 0` 时补的是整数侧的零。
///   **不保留负零**（`-0.0` 舍出 `"0.00"`，同 `BigDecimal`——它没有带符号的 0）
/// - Raises:
///   - `NumError.NotFinite`：`x` 是 `NaN` 或 `±Infinity`
///   - `NumError.ScaleOutOfRange(scale)`：`scale` 超出 `[-323, 308]`
/// - Note: 舍入对象是**最短十进制表示**，不是 `x` 的二进制精确值——这条与 hutool 同路
///   （`NumberUtil.round(double, …)` 源码走 `Double.toString(v)`）。后果：`2.675` 舍到 2 位给
///   `"2.68"`。若换成"乘 100 再舍"的实现会得 `"2.67"`，那是另一种口径，不是本件的读数
///   （分岔夹具在 `num_test.mbt` 与 spec #8.11）
/// - Note: `round_to_str` 是本件的**主形态**，`round_to` 只是它的串再解析回 `Double`
pub fn round_to_str(
  x : Double,
  scale : Int,
  mode? : RoundingMode = RoundingMode::HalfUp,
) -> String raise NumError {
  if x.is_nan() || x.is_inf() {
    raise NotFinite
  }
  if scale < -323 || scale > 308 {
    raise ScaleOutOfRange(scale)
  }
  let (neg, digits, point) = split_decimal(x)
  round_digits(neg, digits, point, scale, mode)
}

///|
/// 同 `round_to_str`，但出 `Double`（把舍入后的十进制串解析回最接近的可表值）
///
/// - Parameters:
///   - `x`：任意有限 `Double`
///   - `scale`：小数位数，可为负；可表范围同 `round_to_str`
///   - `mode`：舍入模式，默认 `HalfUp`
/// - Returns: 最接近舍入结果的 `Double`。**不承诺"结果就是那个十进制数"**——
///   `round_to(0.1 + 0.2, 17)` 回到的是 0.30000000000000004 那一族可表值，
///   要精确形状请用 `round_to_str`（这也是 hutool 用 `BigDecimal` 而本库用 `Double` 的结构性差异）
/// - Raises: 同 `round_to_str`
/// - Note: 与 core 的分岔是**明码的**：core 的 `Double::round()` 是 `floor(x + 0.5)`，
///   实测 `(-0.5).round()` 给 `0`、`(-3.5).round()` 给 `-3`（向数轴正向）；
///   本件 `HalfUp` 档按绝对值走，`round_to(-0.5, 0)` 给 `-1`。所以本件不叫 `round`
pub fn round_to(
  x : Double,
  scale : Int,
  mode? : RoundingMode = RoundingMode::HalfUp,
) -> Double raise NumError {
  let s = round_to_str(x, scale, mode~)
  // 自家产出的平格式十进制串必然可解析；解析不动就是这条实现被改坏了，不静默兜住
  @string.parse_double(s) catch {
    _ =>
      abort(
        "moon-hutool: num.round_to 解析自家平格式串失败（不该发生）：" +
        s,
      )
  }
}

///|
/// `Int64` 最小值。写 `-9223372036854775807 - 1` 而不是裸的 `-9223372036854775808`——
/// 后者是 `Int` 字面量，wasm 档直接判 out of range
let int64_min : Int64 = -9223372036854775807 - 1

///|
/// `Int64` 绝对值。`Int64::MIN` 的绝对值不可表 ⇒ 按 spec §0.1 明码 `abort`，绝不静默回绕
fn i64_abs(v : Int64) -> Int64 {
  if v == int64_min {
    abort(
      "moon-hutool: num 的 Int 域结果/输入落在本目标不可表的一档（spec 08-num §0.1）",
    )
  } else if v < 0 {
    0 - v
  } else {
    v
  }
}

///|
/// `Int64` 取负，同样防 `Int64::MIN` 那一档
fn i64_neg(v : Int64) -> Int64 {
  if v == int64_min {
    abort(
      "moon-hutool: num 的 Int 域结果/输入落在本目标不可表的一档（spec 08-num §0.1）",
    )
  } else {
    0 - v
  }
}

///|
/// `Int64` → `Int` 的**带界**转换。core 的 `Int64::to_int` 越界是静默回绕（本机实测 2^40 给 `0`），
/// 所以先比界再转；越界只可能是 `Int::MIN` 自反那一档，属契约外读数（spec §0.1）
fn i64_to_int(v : Int64) -> Int {
  if v > @int.MAX_VALUE.to_int64() || v < @int.MIN_VALUE.to_int64() {
    abort(
      "moon-hutool: num 的 Int 域结果/输入落在本目标不可表的一档（spec 08-num §0.1）",
    )
  } else {
    v.to_int()
  }
}

///|
/// 欧几里得辗转，全程非负
fn gcd64(a : Int64, b : Int64) -> Int64 {
  let mut x : Int64 = i64_abs(a)
  let mut y : Int64 = i64_abs(b)
  while y != 0 {
    let t = x % y
    x = y
    y = t
  }
  x
}

///|
/// 扩展欧几里得（**向零取整**除法版）：返回 `(s, t, g)` 使 `s * a + t * b == g`，`g` 非负
fn ext_gcd64(a : Int64, b : Int64) -> (Int64, Int64, Int64) {
  if a == int64_min || b == int64_min {
    abort(
      "moon-hutool: num 的 Int 域结果/输入落在本目标不可表的一档（spec 08-num §0.1）",
    )
  }
  let mut old_r = a
  let mut r = b
  let mut old_s : Int64 = 1
  let mut s : Int64 = 0
  let mut old_t : Int64 = 0
  let mut t : Int64 = 1
  while r != 0 {
    let q = old_r / r
    let nr = old_r - q * r
    old_r = r
    r = nr
    let ns = old_s - q * s
    old_s = s
    s = ns
    let nt = old_t - q * t
    old_t = t
    t = nt
  }
  if old_r < 0 {
    (i64_neg(old_s), i64_neg(old_t), i64_neg(old_r))
  } else {
    (old_s, old_t, old_r)
  }
}

///|
/// `BigInt` 绝对值（core 没给 `abs`，只给 `neg`/`compare_int`/`is_zero`）
fn big_abs(x : @bigint.BigInt) -> @bigint.BigInt {
  if x.compare_int(0) < 0 {
    x.neg()
  } else {
    x
  }
}

///|
/// `BigInt` 辗转版 gcd
fn big_gcd(x : @bigint.BigInt, y : @bigint.BigInt) -> @bigint.BigInt {
  let mut a = big_abs(x)
  let mut b = big_abs(y)
  while b.compare_int(0) != 0 {
    let t = a.mod(b)
    a = b
    b = t
  }
  a
}

///|
/// 把 `Double` 拆成 `(是否负, 十进制数字流, 小数点位置)`，约定 **`digits[i]` 落在 `10^(point-1-i)`
/// 这一位**——所以数字流允许前导零（`"0.5"` ⇒ `[0,5]` + point `1`），位置语义不必再折一遍。
/// 数字流取自 core 的 `Double::to_string`：本机实测三档逐值一致（spec #8.11 的依据），
/// 且形如 ECMAScript `Number::toString`（绝对值大到 1e21 走 `1e+21`，极小走 `1e-7`）
fn split_decimal(x : Double) -> (Bool, Array[Int], Int) {
  let text = x.to_string()
  let tc = text.to_array()
  let has_sign = tc.length() > 0 && (tc[0] == '-' || tc[0] == '+')
  let neg = tc.length() > 0 && tc[0] == '-'
  let start = if has_sign { 1 } else { 0 }
  let mut eidx = -1
  let mut i = start
  while i < tc.length() {
    if tc[i] == 'e' || tc[i] == 'E' {
      eidx = i
      i = tc.length()
    } else {
      i += 1
    }
  }
  let mant_end = if eidx < 0 { tc.length() } else { eidx }
  let exp = if eidx < 0 {
    0
  } else {
    read_signed_int(tc, eidx + 1, tc.length())
  }
  let digits : Array[Int] = []
  let mut int_len = -1
  let mut j = start
  while j < mant_end {
    let c = tc[j]
    if c == '.' {
      int_len = digits.length()
    } else {
      digits.push(c.to_int() - 48)
    }
    j += 1
  }
  let point = (if int_len < 0 { digits.length() } else { int_len }) + exp
  (neg, digits, point)
}

///|
/// 读 `tc[from:to]` 这段带符号十进制整数（只服务指数位）
fn read_signed_int(tc : Array[Char], from : Int, to : Int) -> Int {
  let head = if from < to && (tc[from] == '-' || tc[from] == '+') {
    from + 1
  } else {
    from
  }
  let neg = from < to && tc[from] == '-'
  let mut i = head
  let mut acc = 0
  while i < to {
    acc = acc * 10 + (tc[i].to_int() - 48)
    i += 1
  }
  if neg {
    0 - acc
  } else {
    acc
  }
}

///|
/// 舍入核心：按七档模式舍到 `scale` 位小数，再平格式打印。
/// `keep` 是保留几位有效数字；`keep <= 0` 时先补前导零（补零同时抬 `point`，值不变）
fn round_digits(
  neg : Bool,
  digits : Array[Int],
  point : Int,
  scale : Int,
  mode : RoundingMode,
) -> String {
  let mut pt = point
  let mut keep = pt + scale
  let stream = digits.copy()
  while keep <= 0 {
    stream.insert(0, 0)
    pt += 1
    keep += 1
  }
  while stream.length() < keep {
    stream.push(0)
  }
  let has_discard = stream.length() > keep
  let first = if has_discard { stream[keep] } else { 0 }
  let mut tail_nonzero = false
  let mut i = keep + 1
  while has_discard && i < stream.length() {
    if stream[i] != 0 {
      tail_nonzero = true
      i = stream.length()
    } else {
      i += 1
    }
  }
  let exact = if has_discard { first == 0 && !tail_nonzero } else { true }
  // cmp：-1 = 不足一半，0 = 正好一半，1 = 超过一半（exact 档单独走一条，七档都不动）
  let cmp = if first > 5 || (first == 5 && tail_nonzero) {
    1
  } else if first < 5 {
    -1
  } else {
    0
  }
  let away = if exact {
    false
  } else {
    match mode {
      RoundingMode::Up => true
      RoundingMode::Down => false
      // Ceiling/Floor 看数轴方向，与符号无关；Up/Down 看绝对值方向
      RoundingMode::Ceiling => if neg { false } else { true }
      RoundingMode::Floor => if neg { true } else { false }
      // HalfUp 的平局按绝对值增大走——core 的 `Double::round` 是 floor(x+0.5)，
      // 在 -0.5 / -3.5 这一档与本件分岔，那条分岔钉在 `num_test.mbt` 第 17 块
      RoundingMode::HalfUp => cmp >= 0
      RoundingMode::HalfDown => cmp > 0
      RoundingMode::HalfEven =>
        if cmp > 0 {
          true
        } else if cmp < 0 {
          false
        } else {
          stream[keep - 1] % 2 == 1
        }
    }
  }
  let kept = if away {
    add_one(stream[0:keep].to_owned())
  } else {
    stream[0:keep].to_owned()
  }
  if kept.length() > keep {
    pt += 1 // 进位顶出最高位（`9.996` 舍两位 ⇒ `10.00`、`95` 舍到十位 ⇒ `100`）
  }
  // 「结果是不是零」要在**没进位**的前提下看保留位——`&&` 的右边不接受 `if` 这种复杂表达式，所以拆写
  let is_zero = if away { false } else { all_zero(stream, 0, keep) }
  emit_plain(neg, kept, pt, scale, is_zero)
}

///|
fn all_zero(digits : Array[Int], from : Int, to : Int) -> Bool {
  let mut i = from
  while i < to {
    if digits[i] != 0 {
      return false
    }
    i += 1
  }
  true
}

///|
/// 十进制 +1（可能多出一位）
fn add_one(digits : Array[Int]) -> Array[Int] {
  let out = digits.copy()
  let mut i = out.length() - 1
  let mut carry = 1
  while i >= 0 && carry > 0 {
    let v = out[i] + carry
    out[i] = v % 10
    carry = v / 10
    i -= 1
  }
  if carry > 0 {
    out.insert(0, 1)
  }
  out
}

///|
/// 平格式打印：永不指数记法，小数位数恰好 = `scale`（负 scale 就在整数侧补零）。
/// 零的形状照 Java 实测：`scale <= 0` 就是 `"0"`，`scale > 0` 才保留小数位（spec #8.11）
fn emit_plain(
  neg : Bool,
  kept : Array[Int],
  point : Int,
  scale : Int,
  zero : Bool,
) -> String {
  if zero {
    return if scale > 0 { "0." + zero_run(scale) } else { "0" }
  }
  // `point <= 0` 只可能出现在 scale > 0 的档（前面补过前导零），所以整数部分恒为单个 0
  let ip = if point > 0 { point } else { 0 }
  let mut out = if neg { "-" } else { "" }
  let mut i = 0
  while i < ip {
    out = out + digit_char(if i < kept.length() { kept[i] } else { 0 })
    i += 1
  }
  if ip == 0 {
    out = out + "0"
  }
  if scale > 0 {
    out = out + "."
    let mut k = 0
    while k < scale {
      let idx = point + k
      out = out +
        digit_char(if idx >= 0 && idx < kept.length() { kept[idx] } else { 0 })
      k += 1
    }
  }
  out
}

///|
fn digit_char(d : Int) -> String {
  (d + 48).to_char().unwrap().to_string()
}

///|
fn zero_run(n : Int) -> String {
  let mut s = ""
  let mut i = 0
  while i < n {
    s = s + "0"
    i += 1
  }
  s
}

///|
/// 千分位分组：先按 #8.11 的十进制舍入拿到最短十进制的定点串，再对**整数部分**从右往左三位一隔
///
/// - Parameters:
///   - `x`：任意有限 `Double`
///   - `scale`：小数位数，可为负；界与语义与 #8.11 完全一致（复用同一条腿，不另立一套舍入）
///   - `mode`：舍入模式，默认 `HalfUp`
///   - `sep`：分组符，默认 `,`
///   - `decimal_sep`：小数点符，默认 `.`
/// - Returns: 分组后的平格式串。负号在最外层不参与分组（`-1234.5` ⇒ `"-1,234.50"`），
///   小数位数仍恰好 = `scale`，整数位不够三位就不挂分隔符（`123` ⇒ `"123"`）
/// - Raises: 同 #8.11（`NotFinite`、`ScaleOutOfRange`）
/// - Note: hutool 对位是 `NumberUtil.decimalFormat("#,##0.00", v)`，**那一档本库不跟随**，理由有两条实测：
///   ① `DecimalFormat` 对 `double` 的**二进制精确值**舍入，与 `BigDecimal.valueOf`（最短十进制）
///   **是两个族**——本机 JDK 17 同输入对撞：`2.675` 舍两位 `DecimalFormat` 给 `"2.67"`、
///   `BigDecimal` 族给 `"2.68"`；`-0.0` 前者保留负零 `"-0.00"`、后者给 `"0.00"`。
///   本库整个数值件只认最短十进制这一个族（与 #8.11 一致），不允许一个库里对同一个数给两种答案；
///   ② `DecimalFormat` 还跟 JVM 默认 locale（分隔符、负零、组大小都可能变）⇒ 读数无法跨环境冻结。
///   所以这里只承诺"三位一隔"这一档封闭形状，pattern 全套（`#`/`0`/前缀后缀/百分号/千分位混写）在「不做」清单里
pub fn format_thousands(
  x : Double,
  scale : Int,
  mode? : RoundingMode = RoundingMode::HalfUp,
  sep? : Char = ',',
  decimal_sep? : Char = '.',
) -> String raise NumError {
  // 这一件不是第二套舍入：先把 #8.11 那条腿的结果拿过来，再只对整数部分插分隔符
  group_decimal(round_to_str(x, scale, mode~), sep, decimal_sep)
}

///|
/// 百分比：把**十进制小数点右挪两位**（不是浮点乘 100），再按 #8.11 舍到 `scale` 位，最后挂后缀
///
/// - Parameters:
///   - `x`：任意有限 `Double`，`0.125` 就是 12.5%
///   - `scale`：百分号**前**那个数的 decimal 位数，`>= -323` 且 `<= 308`（同 #8.11）
///   - `mode`：舍入模式，默认 `HalfUp`
///   - `suffix`：后缀，默认 `"%"`（要别的自己传，本库不做 locale 货币符号）
/// - Returns: 平格式串挂后缀，如 `"12.50%"`；不保留负零（`-0.0` ⇒ `"0.00%"`）
/// - Raises: 同 #8.11
/// - Note: hutool 对位 `NumberUtil.formatPercent(double, scale)` 走
///   `NumberFormat.getPercentInstance()`——**它随 JVM 默认 locale 变**（分隔符、舍入、组大小都可能不同），
///   且和 `DecimalFormat` 同属"二进制精确值"那一族 ⇒ 本库不跟随，改走最短十进制挪点。
///   实测过分岔一条：`0.145` 舍到 0 位，本库 `HalfUp` 给 `"15%"`（挪点是十进制精确的，
///   14.5 就是 14.5），`DecimalFormat` 给 `"14%"`（它看到的是 14.499999999999998）
pub fn format_percent(
  x : Double,
  scale : Int,
  mode? : RoundingMode = RoundingMode::HalfUp,
  suffix? : String = "%",
) -> String raise NumError {
  if x.is_nan() || x.is_inf() {
    raise NotFinite
  }
  if scale < -323 || scale > 308 {
    raise ScaleOutOfRange(scale)
  }
  // 挪的是十进制小数点（point + 2），不是 x * 100.0——后者会让 0.145 变成 14.499999999999998
  let (neg, digits, point) = shift_point_left(split_decimal(x), 2)
  round_digits(neg, digits, point, scale, mode) + suffix
}

///|
/// 去掉十进制串小数部分的尾随零；小数位清空时连小数点一起去掉
///
/// - Parameters:
///   - `s`：一个十进制串（可带符号、可没有小数部分）
/// - Returns: 最短的等值平格式串。**整数的尾随零不动**（`"100"` 还是 `"100"`，不会变成 `1E+2` 那类指数形状）；
///   零档不保留负号（`"-0.00"` ⇒ `"0"`）
/// - Raises: `NumError.NotDecimal(s)`：输入不是十进制串（实测 JDK 的 `new BigDecimal("abc")` 与
///   `new BigDecimal("1.2.3")` 都抛 `NumberFormatException`，本库把它换成带原串的类型化错误）
/// - Note: hutool 对位 `NumberUtil.toStr(bigDecimal, isStripTrailingZeros)`——它挂在 `BigDecimal` 上，
///   本库没有 `BigDecimal`，所以这一件的输入是**串**而不是数值。逐条读数由本机 JDK 17 的
///   `new BigDecimal(s).stripTrailingZeros().toPlainString()` 出（9 条与我草稿全等，但仍以 JDK 那一份为准）
pub fn trim_trailing_zeros(s : String) -> String raise NumError {
  match parse_decimal_str(s) {
    None => raise NotDecimal(s)
    Some((neg, digits, point)) => emit_shortest(neg, digits, point)
  }
}

///|
/// 薄 `Money`——**固定两位小数，内部就是"分"这个 `Int64`**
///
/// 三条取舍（都在 spec §10 里逐条给了依据）：
/// 1. **不做多币种小数位**：hutool 的 `Money` 带 `Currency`，`centFactor = 10^digit` 会变；
///    本库固定两位（消费端都是人民币/美元这类两位货币），要别的精度请用 #8.11 自己舍。
/// 2. **分用 `Int64` 而不是 `BigInt`**：`Int64` 定宽 64 位，**三档与 native 同宽**，
///    所以"越界"是一条可以冻结的读数（`Int` 做不到——宽度随目标变）。
///    `BigInt` 会让每次加减乘都造大数，而 9.2e18 分 = 9.2e16 元，真实金额量级远够不到；
///    够不到但会越过边界的操作（`add`、`cent * ratio`）**必须显式 `raise`**，
///    因为 hutool 那侧是 `long` 静默回绕（源码 `(cent * ratios[i]) / total` 没有任何防线）。
/// 3. **中文大写不做**：hutool `Money.toStringAndUnit`/`NumberChineseFormatter` 那一档属于第三批
pub(all) struct Money {
  /// 分。可以为负（债务），`0` 就是零
  cent : Int64
}

///|
/// 用"分"直接构造
///
/// - Parameters:
///   - `cent`：分值，可为负
/// - Returns: 表示 `cent / 100` 元的金额
/// - Note: 这是唯一的构造入口以外的直通档——它不做任何舍入（分本来就是整数），
///   所以 `Money::new(5).to_string()` 就是 `"0.05"`
pub fn Money::new(cent : Int64) -> Money {
  Money::{ cent, }
}

///|
/// 从**十进制元串**构造（hutool `Money(String amount)` 那一档的对位）
///
/// - Parameters:
///   - `s`：十进制串，小数位数不限（`"12.345"`）
///   - `mode`：舍到两位时用的模式，默认 **`HalfEven`**
/// - Returns: 分。`"12.345"` ⇒ `1234`（平局向偶数，4 是偶数 ⇒ 舍到 1234）
/// - Raises: `NotDecimal(s)`、`MoneyOverflow`（元值大到分装不进 `Int64`）
/// - Note: 默认档 `HalfEven` 是**照 hutool 的 `Money.DEFAULT_ROUNDING_MODE = RoundingMode.HALF_EVEN`**，
///   与本包 #8.11/#8.14 的默认 `HalfUp` **不对称**——这个不对称是 hutool 自己书里的（`NumberUtil.round`
///   用 HALF_UP、`Money` 用 HALF_EVEN），两处都跟随比"顺手统一"更负责。要 HalfUp 就显式传
pub fn Money::from_yuan_str(
  s : String,
  mode? : RoundingMode = RoundingMode::HalfEven,
) -> Money raise NumError {
  let (neg, digits, point) = match parse_decimal_str(s) {
    None => raise NotDecimal(s)
    Some(t) => t
  }
  // 元 → 分：小数点右挪两位后舍到 0 位，与 #8.11 同一条十进制度量
  let (neg2, digits2, point2) = shift_point_left((neg, digits, point), 2)
  money_from_plain(round_digits(neg2, digits2, point2, 0, mode))
}

///|
/// 从 `Double` 构造元值
///
/// - Parameters:
///   - `yuan`：任意有限 `Double`
///   - `mode`：舍到两位的模式，默认 `HalfEven`
/// - Returns: 分。走**最短十进制**挪点，与 #8.11/#8.14 同一条路
/// - Raises: `NotFinite`、`MoneyOverflow`
/// - Note: **不跟随 hutool 的 `Money(double)`**——那条构造写的是
///   `this.cent = Math.round(amount * getCentFactor())`：先做**浮点乘法**再用 `Math.round`
///   （= `floor(x + 0.5)`），同类的 `Money(BigDecimal)` 那条路才用 `DEFAULT_ROUNDING_MODE`，
///   也就是 hutool 自己两条构造路口径不同，且 `double` 那条根本没走它宣称的银行家舍入。
///   本机三档分岔实测（本库 / hutool 的 double 路）：`0.025` ⇒ `2` / `3`；
///   `0.005` ⇒ `0` / `1`；`12.345` ⇒ `1234` / `1235`。本库只留一条口径：最短十进制 + 显式模式
pub fn Money::from_yuan(
  yuan : Double,
  mode? : RoundingMode = RoundingMode::HalfEven,
) -> Money raise NumError {
  if yuan.is_nan() || yuan.is_inf() {
    raise NotFinite
  }
  let (neg, digits, point) = shift_point_left(split_decimal(yuan), 2)
  money_from_plain(round_digits(neg, digits, point, 0, mode))
}

///|
/// 取回分值
///
/// - Returns: 构造后存储的 `Int64` 分，不做任何换算
/// - Note: 元方向的读数一律走 `to_string`（精确）或 `to_yuan`（`Double`，可能不可表）；
///   `cent` 是这里唯一的"整数出口"，所以溢出检查都发生在**进**的那一侧
pub fn Money::cent(self : Money) -> Int64 {
  self.cent
}

///|
/// 换算成 `Double` 元值
///
/// - Returns: `cent / 100.0`
/// - Note: **不承诺精确**——`0.07` 这类值在 `Double` 里没有精确表示，要形状用 `to_string`。
///   这一件存在的理由是"要和浮点接口对接"，不是"要一个可信的元值"
/// - 恒不失败：`Int64` 的分转成 `Double` 元最多损失尾数，不会溢出
pub fn Money::to_yuan(self : Money) -> Double {
  self.cent.to_double() / 100.0
}

///|
/// 平格式元值串，**恒两位小数**
///
/// - Returns: 如 `"12.34"`、`"0.05"`、`"-12.34"`；`0` 分 ⇒ `"0.00"`，**不保留负零**
///   （`Money::new(0)` 与 `-0` 分是同一个值）
/// - Note: hutool 对位 `Money.toString()`（= `getAmount().toString()`，`BigDecimal` 的 scale=2 读数），
///   本库自己按分拼串，逐条与 JDK 对撞过（含 `Int64::MAX` 分那一条）
pub fn Money::to_string(self : Money) -> String {
  let c = self.cent
  // 全程不取 |cent|（Int64::MIN 的绝对值不可表）：`/` 与 `%` 都向零取整，符号单独处理
  let ip = c / 100
  let fp = c % 100
  let ip_abs = if ip < 0 { ip.neg() } else { ip }
  let fp_abs = if fp < 0 { fp.neg() } else { fp }
  let tail = if fp_abs < 10 { "0" } else { "" }
  let body = ip_abs.to_string() + "." + tail + fp_abs.to_string()
  if c < 0 {
    "-" + body
  } else {
    body
  }
}

///|
/// 加法（分域，无精度损失）
///
/// - Parameters:
///   - `other`：加数
/// - Returns: 两笔金额之和
/// - Raises: `MoneyOverflow`：和越过 `Int64` 边界。**这里不静默回绕**——同族风险见 hutool
///   `Money.allocate` 里那句 `(cent * ratios[i]) / total`，它连溢出检查都没有
pub fn Money::add(self : Money, other : Money) -> Money raise NumError {
  Money::{ cent: add64(self.cent, other.cent), }
}

///|
/// 减法
///
/// - Parameters:
///   - `other`：减数
/// - Returns: 差，可为负
/// - Raises: `MoneyOverflow`（同 `add`）
pub fn Money::sub(self : Money, other : Money) -> Money raise NumError {
  Money::{ cent: add64(self.cent, other.cent.neg()), }
}

///|
/// 平均分成 `targets` 份，**余数发给最前面几份**
///
/// - Parameters:
///   - `targets`：份数，必须 `>= 1`
/// - Returns: 长度为 `targets` 的数组，**和恒等于原值**，任意两份之差 `<= 1` 分。
///   先按 `|cent|` 分配再回贴符号（`-1000` 分 3 份 ⇒ `[-334, -333, -333]`）
/// - Raises: `NonPositiveTargets(targets)`（0 份不是"空分配"，是没有答案）、`MoneyOverflow`
/// - Note: hutool 对位 `Money.allocate(int)`——正档逐条跟随（`low = cent/targets`、
///   `high = low + 1`、前 `cent % targets` 份拿 `high`），**负档不跟随**：那侧
///   `remainder = cent % targets` 是负数，于是 `for (i = 0; i < remainder; i++)` 一次都不跑，
///   分完的和不回原值；份数与索引错配时还会 `ArrayIndexOutOfBoundsException`。
///   本库把负档规则化（对称分配），并由用例断言"和 == 原值"这条不变量
pub fn Money::allocate_even(
  self : Money,
  targets : Int,
) -> Array[Money] raise NumError {
  if targets < 1 {
    raise NonPositiveTargets(targets)
  }
  let t = targets.to_int64()
  let low = self.cent / t
  // 余数与 cent 同号（`%` 跟着被除数），所以「补给最前面几份」对负档同样成立，不需要取绝对值
  let rem = self.cent - low * t
  let step : Int64 = if rem < 0 { 0 - 1 } else { 1 }
  let n = if rem < 0 { rem.neg() } else { rem }
  let out : Array[Money] = []
  let mut i : Int64 = 0
  while i < t {
    let extra : Int64 = if i < n { step } else { 0 }
    out.push(Money::{ cent: low + extra, })
    i += 1
  }
  out
}

///|
/// 按比例分配，**余数发给最前面几份**
///
/// - Parameters:
///   - `ratios`：各项比例，必须全部 `>= 0` 且和 `> 0`
/// - Returns: 与 `ratios` 同长的数组，**和恒等于原值**。逐份 `|cent| * ratio / sum` 向零截断，
///   再把余下的分按索引序每份 +1（这正是 hutool `Money.allocate(long[])` 的算法）
/// - Raises: `NegativeRatio(r)`、`RatioSumNotPositive(sum)`（全零比例没有分母）、
///   `MoneyOverflow`（`|cent| * ratio` 越过 `Int64`——hutool 的 `long` 在这里静默回绕，本库不跟随）
/// - Note: 比例全为 0 与出现负数是**两种不同的错**（前者是"没有分母"，后者是"方向都没定"），
///   所以两个变体不合并
pub fn Money::allocate_by_ratio(
  self : Money,
  ratios : Array[Int],
) -> Array[Money] raise NumError {
  let mut sum : Int64 = 0
  for r in ratios {
    if r < 0 {
      raise NegativeRatio(r)
    }
    sum = add64(sum, r.to_int64())
  }
  if sum <= 0 {
    raise RatioSumNotPositive(sum)
  }
  // `cent * ratio` 这一步在 hutool 是 `long` 直接乘、静默回绕。本库走 BigInt 精确算，于是
  // 这一档**不需要 MoneyOverflow**：`0 <= r_i <= sum` 保证每个结果都不超过 |cent|，
  // `used` 的各项同号且和也不超过 |cent|——两条都在镜像里断言过（spec #8.24）
  let sum_big = @bigint.BigInt::from_int64(sum)
  let cent_big = @bigint.BigInt::from_int64(self.cent)
  let out : Array[Money] = []
  for r in ratios {
    let p = cent_big.mul(@bigint.BigInt::from_int(r)).div(sum_big)
    out.push(Money::{ cent: p.to_int64(), })
  }
  let mut used : Int64 = 0
  for m in out {
    used += m.cent
  }
  let rem = self.cent - used
  let step : Int64 = if rem < 0 { 0 - 1 } else { 1 }
  let n = if rem < 0 { rem.neg() } else { rem }
  let mut i = 0
  while i < out.length() && i.to_int64() < n {
    out[i] = Money::{ cent: out[i].cent + step, }
    i += 1
  }
  out
}

// num 第二批的私有线件：格式化与薄 Money 共用

///|
/// `Int64` 带界加法：hutool 的 `Money` 全程 `long` 裸加，本库越界必报错（spec #8.22）
fn add64(a : Int64, b : Int64) -> Int64 raise NumError {
  if b > 0 && a > @int64.MAX_VALUE - b {
    raise MoneyOverflow
  }
  if b < 0 && a < @int64.MIN_VALUE - b {
    raise MoneyOverflow
  }
  a + b
}

///|
/// `BigInt` → `Int64` 带界换算（分配结果装不下就是真装不下，不回绕）
fn big_to_i64(x : @bigint.BigInt) -> Int64 raise NumError {
  let mx = @bigint.BigInt::from_int64(@int64.MAX_VALUE)
  let mn = @bigint.BigInt::from_int64(@int64.MIN_VALUE)
  if x.compare(mx) > 0 || x.compare(mn) < 0 {
    raise MoneyOverflow
  }
  x.to_int64()
}

///|
/// 把「已舍到 0 位小数」的平格式串读成分。走 BigInt 累加再判界——`Int64::MIN` 那一档的绝对值
/// 装不进正侧，逐位乘加自己会先回绕
fn money_from_plain(plain : String) -> Money raise NumError {
  let cs = plain.to_array()
  let mut i = 0
  let neg = cs.length() > 0 && cs[0] == '-'
  if cs.length() > 0 && (cs[0] == '-' || cs[0] == '+') {
    i = 1
  }
  let mut acc = @bigint.BigInt::from_int(0)
  let mut any = false
  while i < cs.length() {
    let c = cs[i]
    if c == '.' {
      i += 1
      continue
    }
    if c < '0' || c > '9' {
      abort(
        "moon-hutool: num 内部把平格式串读回了非数字（不该发生）：" +
        plain,
      )
    }
    acc = acc
      .mul(@bigint.BigInt::from_int(10))
      .add(@bigint.BigInt::from_int(c.to_int() - 48))
    any = true
    i += 1
  }
  if !any {
    raise MoneyOverflow
  }
  let v = if neg { acc.neg() } else { acc }
  Money::{ cent: big_to_i64(v), }
}

///|
/// 把十进制**串**拆成 `(是否负, 数字流, 小数点位置)`，约定同 `split_decimal`。
/// `"+1.10"`、`".5"`、`"12."` 都认（这三条 JDK 的 `BigDecimal` 也认，23 条实测见 spec #8.16）；
/// 认不出的形状一律 `None`，由调用方报 `NotDecimal`
fn parse_decimal_str(text : String) -> (Bool, Array[Int], Int)? {
  let cs = text.to_array()
  let mut i = 0
  let neg = cs.length() > 0 && cs[0] == '-'
  if cs.length() > 0 && (cs[0] == '-' || cs[0] == '+') {
    i = 1
  }
  let digits : Array[Int] = []
  let mut point = -1
  let mut any_digit = false
  let mut ok = true
  while i < cs.length() && ok {
    let c = cs[i]
    if c == '.' {
      if point >= 0 {
        ok = false
      } else {
        point = digits.length()
      }
    } else if c < '0' || c > '9' {
      ok = false
    } else {
      digits.push(c.to_int() - 48)
      any_digit = true
    }
    i += 1
  }
  if !ok || !any_digit {
    None
  } else {
    let pt = if point < 0 { digits.length() } else { point }
    Some((neg, digits, pt))
  }
}

///|
/// 最短平格式：去小数部分尾随零（清空就连点一起去掉）、去整数部分前导零、零不保留负号。
/// 23 条夹具逐条与 JDK 的 `stripTrailingZeros().toPlainString()` 对撞
fn emit_shortest(neg : Bool, digits : Array[Int], point : Int) -> String {
  let d = digits.copy()
  let pt = point
  while d.length() > pt && d[d.length() - 1] == 0 {
    let _ = d.pop()
  }
  // 前导零用起始索引跳过：本版 Array 没有 `remove_at`，从头上删要么换 API 要么整体搬一次
  let mut lead = 0
  while pt - lead > 1 && lead < d.length() && d[lead] == 0 {
    lead += 1
  }
  let pt2 = pt - lead
  let len = d.length() - lead
  let all_zero = len <= 0 || all_zero(d, lead, d.length())
  if all_zero {
    return "0"
  }
  let mut out = ""
  let mut i = 0
  while i < pt2 {
    out = out + digit_char(if i < len { d[lead + i] } else { 0 })
    i += 1
  }
  if pt2 <= 0 {
    out = out + "0"
  }
  if len > pt2 {
    out = out + "."
    let mut j = pt2
    while j < len {
      out = out + digit_char(d[lead + j])
      j += 1
    }
  }
  if neg {
    "-" + out
  } else {
    out
  }
}

///|
/// 只对**整数部分**插分组符：`round_to_str` 的平格式输出在这里被二次加工，舍入一格都不重做
fn group_decimal(plain : String, sep : Char, dec : Char) -> String {
  let cs = plain.to_array()
  let neg = cs.length() > 0 && cs[0] == '-'
  let start = if neg { 1 } else { 0 }
  let mut dot = -1
  let mut i = start
  while i < cs.length() {
    if cs[i] == '.' {
      dot = i
      i = cs.length()
    } else {
      i += 1
    }
  }
  let int_end = if dot < 0 { cs.length() } else { dot }
  let mut out = if neg { "-" } else { "" }
  let mut k = start
  while k < int_end {
    if k > start && (int_end - k) % 3 == 0 {
      out = out + sep.to_string()
    }
    out = out + cs[k].to_string()
    k += 1
  }
  if dot >= 0 {
    out = out + dec.to_string()
    let mut j = dot + 1
    while j < cs.length() {
      out = out + cs[j].to_string()
      j += 1
    }
  }
  out
}

///|
/// 小数点左移 `k` 位（等价于乘 10^k），并把因此落进**整数区**的前导零跳掉。
/// `split_decimal` 的位置约定下，挪点只是 `point + k`；但 `0.125` 挪两位会得到整数区读数 `012`，
/// 所以这一步必须跳零——否则百分比与元→分会输出 `"012.50%"` 这种带前导零的形状
fn shift_point_left(
  parts : (Bool, Array[Int], Int),
  k : Int,
) -> (Bool, Array[Int], Int) {
  let (neg, digits, point) = parts
  let pt = point + k
  let mut lead = 0
  while pt - lead > 1 && lead < digits.length() && digits[lead] == 0 {
    lead += 1
  }
  let out : Array[Int] = []
  let mut i = lead
  while i < digits.length() {
    out.push(digits[i])
    i += 1
  }
  (neg, out, pt - lead)
}

// ==================== 第三批：中文数字与英文 word（#8.26~#8.39）====================
//
// 对位 hutool `NumberChineseFormatter` / `NumberWordFormatter`（注意这两个件住在
// `core/convert/` 而不是 `core/math/`）。规则与全部读数来源见 spec §10。
// 这一批的入口一律收**十进制原文串**，不收 `Double`：hutool 的 double 路与 BigDecimal 路
// 对同一个数给出两种答案（实测 `1.105` ⇒ "一点一一" / "一点一零五"，spec §10.1）。

///|
/// 十进制原文 → 中文数字（简写、非金额、非口语），对位 `NumberChineseFormatter.format(BigDecimal, false, false)`。
///
/// 小数点读作「点」，小数部分逐位读；负数前缀「负」。越出 ±99_9999_9999_9999.99 ⇒ `OutOfRange`。
/// 整数部分的单位是十/百/千/万/亿，**万与亿之间不叠加"零"**（`1000000 ⇒ "一百万"`），
/// 而千位段内的空位要补零（`1001 ⇒ "一千零一"`、`1010 ⇒ "一千零一十"`）。
pub fn chinese_of(text : String) -> String raise NumError {
  abort("moon-hutool 契约未实现：chinese_of")
}

///|
/// 同上但用繁体（记账大写：壹贰叁…玖、拾佰仟万亿），对位 `format(BigDecimal, true, false)`。
/// 单位表里「万/亿」简繁同形，所以 `10000` ⇒ "壹万"。
pub fn chinese_upper_of(text : String) -> String raise NumError {
  abort("moon-hutool 契约未实现：chinese_upper_of")
}

///|
/// 简写 + 口语档：把「一十」读成「十」，对位 `format(BigDecimal, false, true)`。
///
/// hutool 的口语替换只有四条映射（`一十→十`、`一拾→拾`、`负一十→负十`、`负一拾→负拾`），
/// 所以 `100000 ⇒ "十万"` 但 `115 ⇒ "一百一十五"`（那个"一十"在百位段之后，不在替换表里）。
pub fn chinese_colloquial_of(text : String) -> String raise NumError {
  abort("moon-hutool 契约未实现：chinese_colloquial_of")
}

///|
/// 繁体 + 口语档，对位 `format(BigDecimal, true, true)`。
pub fn chinese_upper_colloquial_of(text : String) -> String raise NumError {
  abort("moon-hutool 契约未实现：chinese_upper_colloquial_of")
}

///|
/// 十进制原文 → 金额大写（繁体 + 元/角/分/整），对位 `format(…, true, true)` 的金额档。
///
/// 先按两位**向零舍入到分**——注意这一档跟的是 `HalfUp`（hutool `NumberUtil.round` 默认），
/// 与第二批 `Money::from_yuan_str` 的 `HalfEven` 不同一族，分岔夹具 `1.105` 两条都在（spec §10.3）。
/// 不足一元时不写"零元"：`0.05 ⇒ "伍分"`、`0.5 ⇒ "伍角"`；整元才带「元整」。
pub fn chinese_money_of(text : String) -> String raise NumError {
  abort("moon-hutool 契约未实现：chinese_money_of")
}

///|
/// 金额简写档（一/二/三 + 元角分整），对位 `format(…, false, true)`。
pub fn chinese_money_simple_of(text : String) -> String raise NumError {
  abort("moon-hutool 契约未实现：chinese_money_simple_of")
}

///|
/// 千分位档：只收 `-999 ~ 999` 的整数，**10~19 去掉「一」**，对位 `formatThousand(int, false)`。
///
/// 这是与 #8.26 不同的一条档：`chinese_of("10") ⇒ "一十"`，而本件给 `"十"`；越界 ⇒ `OutOfRange`
/// （hutool 那句 `Number support only: (-999 ~ 999)！` 只当读数证据，不进错误载荷）。
pub fn chinese_of_thousand(n : Int) -> String raise NumError {
  abort("moon-hutool 契约未实现：chinese_of_thousand")
}

///|
/// 千分位档的繁体版，对位 `formatThousand(int, true)`：`11 ⇒ "拾壹"`、`110 ⇒ "壹佰壹拾"`。
pub fn chinese_upper_of_thousand(n : Int) -> String raise NumError {
  abort("moon-hutool 契约未实现：chinese_upper_of_thousand")
}

///|
/// 单个阿拉伯数字字符 → 对应的中文数字字，对位 `numberCharToChinese(char, isUseTraditional)`。
///
/// 只收 `'0' ~ '9'`；其余字符 ⇒ `NotDecimal`（hutool 在此没有任何校验，本包不把"喂错字符"留成静默）。
pub fn chinese_digit(d : Char, upper? : Bool) -> Char raise NumError {
  abort("moon-hutool 契约未实现：chinese_digit")
}

///|
/// 中文数字 → `Int64`，对位 `chineseToNumber(String)`。
///
/// 认简写与繁体两套字（可混排：`"壹拾贰" ⇒ 12`）、认「两/二」同值、认裸单位补一（`"十" ⇒ 10`、`"百" ⇒ 100`）、
/// 认「拾万」这种跨节组合（⇒ 100000）。**不跟随 hutool 的两条**：
/// ① 本包认「负」前缀（hutool 在此抛 `Unknown unit '负'`，而它自己的正向会产出带"负"的串 ⇒ 往返不通）；
/// ② 累加走 `Int64`，越界给 `OutOfRange`（hutool 用 `int` 累加，超 2^31 静默回绕）。
pub fn int_of_chinese(text : String) -> Int64 raise NumError {
  abort("moon-hutool 契约未实现：int_of_chinese")
}

///|
/// 中文金额 → 第二批的 `Money`（cent 为 `Int64`），对位 `chineseMoneyToNumber(String)`。
///
/// 「元/角/分」三段可省，整串没有「元」时**按元段处理**（hutool 此处把「壹佰」读成 0.00，
/// 是丢值 bug，实测在读数表里）；不认「负」（金额串的负号本就不该出现在记账场景，
/// 且 hutool 在此也抛）。空/全空白 ⇒ `NotDecimal`（hutool 给 null，本包不用哨兵）。
pub fn money_of_chinese(text : String) -> Money raise NumError {
  abort("moon-hutool 契约未实现：money_of_chinese")
}

///|
/// 大数缩写（中文单位），对位 `NumberChineseFormatter.formatSimple(long)`。
///
/// 阈值固定：`>= 1e12` 走「万亿」、`>= 1e8` 走「亿」、`>= 1e4` 走「万」，其余原样十进制；
/// 除数走 `BigDecimal` 两位 `HalfUp`，所以读数与 locale 无关（`10000 ⇒ "1.00万"`、`12345 ⇒ "1.23万"`）。
pub fn chinese_abbrev(n : Int64) -> String {
  abort("moon-hutool 契约未实现：chinese_abbrev")
}

///|
/// 大数缩写（英文单位 w/y 那套），对位 `NumberWordFormatter.formatSimple(long)`。
///
/// 阈值与 #8.36 相同但单位是 `w`/`y` 且**不带尾随零**（`1000000 ⇒ "100w"`）。
/// hutool 走 `NumberUtil.decimalFormat("#.##", …)` ⇒ 随 JVM 默认 locale 变，本包固定 `.`（spec §10.4）。
pub fn english_abbrev(n : Int64) -> String {
  abort("moon-hutool 契约未实现：english_abbrev")
}

///|
/// 十进制原文 → 英文 word，对位 `NumberWordFormatter.format(Object)`。
///
/// 整数部分三位一节（`1234567 ⇒ "ONE MILLION TWO HUNDRED AND THIRTY FOUR THOUSAND FIVE HUNDRED AND
/// SIXTY SEVEN"`），末尾统一带 `ONLY`；有小数时读作 `AND CENTS <逐位>`。
/// 三条不跟随（读数都在 spec §10.4）：负数 hutool 直接炸在内部 `Integer.parseInt("-")` ⇒ 本包给 `OutOfRange`；
/// 零小数（`1.0`）hutool 仍输出 `AND CENTS ` 带两个空格 ⇒ 本包不输出 cents 段；
/// 千位段的百位为 0 但十位非 0 时 huto0l 不补 `AND`——本包按它的读数原样钉住，不改。
pub fn english_word_of(text : String) -> String raise NumError {
  abort("moon-hutool 契约未实现：english_word_of")
}
