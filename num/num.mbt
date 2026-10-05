///|
/// moon-hutool/num —— 数值计算件（hutool `NumberUtil` / `MathUtil` 的 MoonBit 对位·第一批）
///
/// 契约：`docs/spec/08-num.md`。期望值权威在 `num_test.mbt` 与 spec 的读数表——改任何期望串须单独一笔
/// 并给外部读数来源（门禁 G5），实现只负责把契约里冻好的读数算出来。
///
/// 本批只做**数论 + 十进制舍入**这一格。剩下的三格各自是一整块，不混进这份契约：
/// 千分位/百分比格式化 + `Money` 薄档（第二批）、中文数字与英文 word（第三批）、`Calculator` 表达式求值（第四批）。
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
  let _ = a
  let _ = b
  abort("moon-hutool: num.gcd 未实现（spec 08-num #8.1）")
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
  let _ = a
  let _ = b
  abort("moon-hutool: num.ext_gcd 未实现（spec 08-num #8.2）")
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
  let _ = a
  let _ = m
  abort("moon-hutool: num.mod_inverse 未实现（spec 08-num #8.3）")
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
  let _ = n
  abort("moon-hutool: num.is_prime 未实现（spec 08-num #8.4）")
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
  let _ = n
  abort("moon-hutool: num.isqrt 未实现（spec 08-num #8.5）")
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
  let _ = a
  let _ = b
  abort("moon-hutool: num.lcm 未实现（spec 08-num #8.6）")
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
  let _ = n
  abort("moon-hutool: num.factorial 未实现（spec 08-num #8.7）")
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
  let _ = n
  let _ = m
  abort("moon-hutool: num.combination_count 未实现（spec 08-num #8.8）")
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
  let _ = n
  let _ = m
  abort("moon-hutool: num.arrangement_count 未实现（spec 08-num #8.9）")
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
  let _ = x
  let _ = scale
  let _ = mode
  abort("moon-hutool: num.round_to_str 未实现（spec 08-num #8.11）")
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
  let _ = x
  let _ = scale
  let _ = mode
  abort("moon-hutool: num.round_to 未实现（spec 08-num #8.12）")
}
