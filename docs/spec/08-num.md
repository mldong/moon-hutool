# 契约 08 · num（数值计算件·第一批：数论 + 十进制舍入）

> 状态：**分两批。第一批契约与实现两笔都交完**（10-05）；**第二批契约已冻结、实现未开工**（#8.14~#8.25）。
> 25 条公开项见 `num/pkg.generated.mbti`25 条公开项见 `num/pkg.generated.mbti`（`moon info` 后零漂移）；冻结期望值在 `num/num_test.mbt`（17 块 205 条断言）与
> `num/README.mbt.md`（10 块 45 条断言）——第一批那 27 块已**镜像读数一字未改**地从红变绿
> （三档一致，native 档由 CI 出证）。第二批的期望值在 `format_test.mbt`（5 块）与 `money_test.mbt`（8 块）
> 再加 4 个文档块，此刻 17 块红是设计态；矩阵在 §9。
> 实现期唯一一处测试文件改动是**两条验算腿**（`mod_inverse` 的 `(inv*a) % m` 与 `isqrt` 的平方界），
> 因为它们在 32 位 `Int` 上会静默回绕——单独一笔（`test(num)`），动的只有推导式检查，冻结读数没动。
> 改任何期望串仍须单独一笔并给外部读数来源（门禁 G5）。
>
> 本批只做两格：**数论**（`gcd` / `ext_gcd` / `mod_inverse` / `is_prime` / `isqrt`）与
> **十进制舍入**（`RoundingMode` 七档 + `round_to_str` / `round_to`），外加只在精确域出的四件增长型算术
> （`lcm` / `factorial` / `combination_count` / `arrangement_count`）。
> 千分位与百分比格式化 + `Money` 薄档、中文数字与英文 word、`Calculator` 表达式求值各自是一整块，
> 分界与理由见 §6。

## 0. 四条贯穿性规则

| # | 规则 | 为什么（都是当场实测或读源码得来的，不是偏好） |
|---|---|---|
| 0.1 | **增长型算术一律只在 `BigInt` 域出**；`Int` 域只收"输出可证明不超过输入量级"的函数 | `Int` 位宽随目标变：`wasm`/`js`/`wasm-gc` 是 **32 位**，`native` 是 **64 位**。更糟的是越界**不报错**——本机当场实测：`(2147483647).mul(2)` 给 `-2`、`(-2147483647 - 1).abs()` 给 `-2147483648`、`BigInt::from_string("2147483648").to_int()` 给 `-2147483648`、`BigInt::from_string("99999999999999999999").to_int()` 给 `1661992959`（就是 `99999999999999999999 mod 2^32` 的补码读法，Python 侧同算）。一条会长的算术放进 `Int` 域，"有没有溢出"就变成"跑在哪个目标上"，这种读数**冻结不了**，三档与 native 必有一档在骗人 |
| 0.2 | **十进制舍入按最短十进制串走**，不按二进制精确值，也不按"乘 10^scale 再舍" | hutool `NumberUtil.round(double, int, RoundingMode)` 的源码就是 `round(Double.toString(v), scale, mode)`；本库同路。后果是可测的：`2.675` 舍到两位给 `2.68`，而"乘 100 再舍"给 `2.67`（`2.675` 的二进制真值是 `2.67499999999999982…`）。这不是实现细节，是本件的语义定义（分岔夹具：`num_test.mbt`「十进制分岔」块 + `README.mbt.md`） |
| 0.3 | **错误只带读数**，不带文案、不带能从输入算出的常数 | 与 `codec`/`date`/`id`/`coll`/`mapx` 同一立场。本包七个变体里唯一"看起来能省"的是 `InvalidModulus(m)`——它只带 `m`，不带"下界 2"那个常数，因为常数是契约、不是读数 |
| 0.4 | **不发明哨兵值，也不造 `Bool` 版判定** | `is_number` / `is_integer` / `is_double` / `parseInt(s, default)` 这类 hutool 件**本包一个都不做**：core 的 `@string.parse_int` / `parse_double` / `parse_bigint` 已经给 `raise`，把它包成"返回 `Bool`"或"返回默认值"就是把失败信号降级成猜（同 `coll` 不跟 `-1` 哨兵那条） |

## 1. 与 core 的边界（本包只做这张表右列的事）

判据是**读 `moonbitlang/core` 源码**得出的，版本 `0.10.14+7d59c7ec9`。扫描口径写在表下，可以被复跑。

| 能力 | core 已经有什么（当场核对过） | 本包 |
|---|---|---|
| 取绝对值 / 符号 / 区间约束 | `Int::abs`/`min`/`max`/`clamp(min~,max~)`/`signum`(Double)/`Double::abs`/`clamp`/`signum` | **不做**，一行等价物不重新包装；但 `Int::abs` 在 `Int::MIN` 上**静默回绕**（实测），这条坑见 §0.1 |
| 四则与幂 | `Int`/`Int64`/`Double` 全套算子；`Double::pow`、`@math.pow`、`BigInt::pow(exp, modulus?)` | **不做**同名件。整数幂只在 `BigInt` 上有模幂（core 已给），本包不补 `Int` 版（会溢出，见 §0.1） |
| 取整到整数 | `Double::round`/`ceil`/`floor`/`trunc`、`@math.ceil`/`round`/`floor`/`trunc`/`scalbn` | **做"舍到 N 位小数"** `round_to_str`/`round_to`。core 只有"舍到整数"一档，且**没有模式**：`Double::round` 实测是 `floor(x + 0.5)`（`(-0.5)→0`、`(-3.5)→-3`，向数轴正向），与本包 `HalfUp`（向绝对值增大）在负半边分岔 ⇒ 本件因此**不叫 `round`**（#8.11 / #8.12） |
| 浮点相等容差 | `Double::is_close(a, b, relative_tolerance?, absolute_tolerance?)`、`@double.not_a_number`/`infinity`/`neg_infinity`/`max_value`/`min_positive` | **不做**，也不造 `equals(double,double)`（hutool 那一档就是 `is_close` 的别名） |
| 素性判定 | `@math.is_probable_prime(BigInt, Rand, iters?)`、`@math.probable_prime(Int, Rand)`——**概率**件，且必须传熵源 | **做**确定性 `is_prime(Int) -> Bool`：`Int` 域要的是确定答案，不需要熵，因此三档读数恒等 |
| 最大公约数 / 最小公倍数 / 贝祖 / 模逆 | **零**。`bigint/pkg.generated.mbti` 60 条公开面里没有 `gcd`/`lcm`/`mod_inverse`，`BigInt` 只有 `div`/`mod`/`pow(…, modulus?)` | **做** `gcd`/`ext_gcd`/`mod_inverse`（`Int` 域，中间量走 64 位定宽的 `Int64`）与 `lcm`（`BigInt` 域）。这也是二期 RSA 的门票件 |
| 整数开方 | `Double::sqrt`（浮点，53 位尾数） | **做** `isqrt`：`Int` 精确floor(sqrt)，不经浮点。core 无 `Math::floorSqrt` 类件（`sqrt` 命中只在 `Double::sqrt`） |
| 阶乘 / 组合数 / 排列数 | **零**（`factorial`/`comb`/`perm` 全库零命中） | **做** `factorial`/`combination_count`/`arrangement_count`，全在 `BigInt` 域 |
| 三角 / 对数 / 常数 | `@math` 的 `sin`/`cos`/`tan`/`ln`/`log2`/`log10`/`exp`/`hypot`/`cbrt`/`pi`… 54 条公开面 | **不做**，一个都不包装 |
| 进制转换 | `Int::to_string(radix?)`、`@string.parse_int(s, base?)`、`BigInt::to_string(radix?)`/`from_string(s, radix?)`、`BigInt::to_octets`/`from_octets` | **不做**。hutool 的 `getBinaryStr`/`binaryToInt`/`toBytes`/`toUnsignedByteArray` 全在这几条覆盖范围内，`codec` 已另有 `radix_encode`/`radix_decode`（`Int64` 档） |
| 字符串→数值判定 | `@string.parse_int`/`parse_int64`/`parse_uint`/`parse_double`/`parse_bool`/`parse_bigint`（都 `raise`） | **不做**（§0.4）。顺带记一组实测口径，因为格式化那批要用：`parse_int` **拒绝**首尾空白（`" 42"` 报错）、接受 `_` 分隔与 `0x` 前缀；`parse_double` 接受 `nan`/`inf`/`Infinity`/`.5`/`1.`/`+1.5`、拒绝空白与 `1,0`；`"1e309"` **报错**（不给 Infinity）、`"1e-324"` 给 `0` |
| 随机数 / 范围数组 | `@random.Rand`、`Int::until`、`Array::shuffle(rand~)` | **不做**，归 `rand` 包（ROADMAP 第 12 行） |

**扫描口径**（"core 有什么"这句话必须可以被复跑，而不是等下一个人重新 grep）：
按 `pkg.generated.mbti` 的 `pub` 行计数——`math` **54 条**、`bigint` **60 条**、
`builtin` 里 `Int::` **48 条**、`Double::` **42 条**、`Int64::` **38 条**、`String::` **71 条**；
再按**词法**扫缺口：`--include='*.mbti'` 全库正查 `gcd|lcm|mod_inverse|extended_gcd|egcd|rational`
⇒ **0 命中**，实现源码再正查 `fn (gcd|lcm|mod_inverse)` ⇒ 同样 **0 命中**；
`mean|median|variance|std_dev|percentile` 也 **0 命中**——所以 hutool 侧本来就没有的统计件
（`NumberUtil` 181 条公开面里确实也没有）不在本包出现，**"core 没有"不等于"该补"**。

hutool 侧口径：读 GitHub `dromara/hutool` HEAD 的
`cn/hutool/core/util/NumberUtil.java`（**181** 条 `public static`）、`cn/hutool/core/math/MathUtil.java`（8 条）、
`Combination.java` / `Arrangement.java` / `Money.java` / `Calculator.java`；
中文数字与英文 word 两件在 `cn/hutool/core/convert/`（**不在** `math/`，也不在 `lang/`——找错过一次）。

## 2. 错误面

| 签名 | 语义 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `pub suberror NumError { ScaleOutOfRange(Int) NotFinite NegativeRadicand(Int) InvalidModulus(Int) NonCoprime(Int, Int) NegativeFactorial(Int) NegativeCount(Int, Int) NotDecimal(String) NonPositiveTargets(Int) NegativeRatio(Int) RatioSumNotPositive(Int64) MoneyOverflow }` | 本包唯一错误面，12 个变体各对应**一个** `raise` 点（后五个属第二批） | `NotFinite` 与 `NegativeFactorial` 之类只带一个读数；两个双读数变体（`NonCoprime`、`NegativeCount`）都带**给进来的原值对**，不做归一化 | hutool 一律抛 `IllegalArgumentException` / `ArithmeticException`，把数字拼进文案 | 文案不进错误面（同四个已交付包）；`NonCoprime` 不返回 `-1`——`-1` 在模 11 下是个合法剩余类，拿它当失败信号会和答案混起来 | 定义即契约；逐条形状在 `num_test.mbt`「两类报错各带原读数」块 |

## 3. 契约矩阵（行号 = 用例号 `#8.x`）

| # | 签名 | 冻结读数（夹具与期望都由镜像现算） | 边界/错误 | hutool 对位 | 差异声明 |
|---|---|---|---|---|---|
| 8.1 | `gcd(a : Int, b : Int) -> Int` | `(12,18)⇒6`、`(-12,18)⇒6`、`(12,-18)⇒6`、`(-12,-18)⇒6`、`(0,0)⇒0`、`(0,5)⇒5`、`(-5,0)⇒5`、`(17,13)⇒1`、`(1,1)⇒1`、`(2147483647,2147483647)⇒2147483647`、`(2147483646,2147483647)⇒1`、`(2310,156)⇒6`、`(97,101)⇒1`；另有 `[-30,30]` 网格逐对断言"非负 + 不超非零那一侧的绝对值 + 两边都整除" | 恒不失败。`Int::MIN` 自反档（`gcd(MIN,MIN)` 要 `2^31`）在 wasm 上不可表，按 core 同类件的立场交给 `abort`，本包**不为其发明错误码**，也**不冻结**该档读数（§0.1 的理由） | `NumberUtil.divisor(int, int)` | **不跟随两处**：hutool 源码 `while (m % n != 0)` 在 `n == 0` 时除零崩；负输入原样带出负号（`divisor(-12, 8)` 给 `-4`）。本库结果恒非负且 0 档有定义 |
| 8.2 | `ext_gcd(a : Int, b : Int) -> (Int, Int, Int)` | `(240,46)⇒(-9,47,2)`、`(12,18)⇒(-1,1,6)`、`(7,5)⇒(-2,3,1)`、`(-240,46)⇒(9,47,2)`、`(240,-46)⇒(-9,-47,2)`、`(0,5)⇒(0,1,5)`、`(5,0)⇒(1,0,5)`、`(0,0)⇒(1,0,0)`、`(1,1)⇒(0,1,1)`、`(-7,-5)⇒(2,-3,1)`；另有 `[-20,20]²` 网格逐对断言 `s*a + t*b == g == gcd(a,b)` 与两条界 `|s|·g ≤ |b|`（`b≠0` 时）、`|t|·g ≤ |a|`（`a≠0` 时） | 恒不失败。贝祖系数**不唯一**（`(s + k·b/g, t − k·a/g)` 全都成立），所以契约 = 不变量 + 界 + 本库算法那一支的逐条读数，**不承诺"唯一解"**；界在 `b = 0` 档不适用（`ext_gcd(5,0)` 的 `s = 1`），用例按 `b != 0` 判据分支断言 | 无对位件（hutool 只给 `divisor`） | 这一件是为模逆与二期 RSA 补的；与 `mod_inverse` 同族但**独立公开**，因为调用方要的就是系数本身 |
| 8.3 | `mod_inverse(a : Int, m : Int) -> Int raise NumError` | `(3,11)⇒4`、`(7,26)⇒15`、`(1,2)⇒1`、`(1234567,9999991)⇒9411761`、`(-3,11)⇒7`、`(17,2147483647)⇒252645135`；每条同时断言 `(inv * a) % m == 1`。报错档：`(3,1)⇒InvalidModulus 1`、`(7,0)⇒InvalidModulus 0`、`(2,-5)⇒InvalidModulus -5`、`(6,9)⇒NonCoprime 6 9`、`(0,5)⇒NonCoprime 0 5`、`(-2,4)⇒NonCoprime -2 4` | 结果取**最小非负剩余**（落在 `[0, m)`）；`a` 可为负，先归到 `[0, m)` 再判 | 无对位件；语义参照 `java.math.BigInteger.modInverse`（同为 `[0, m)` 档） | 失败不返回 `-1`（§0.4）；中间量走 `Int64`（64 位定宽，不随目标变），结果可表性由界 `[0, m)` 保证 |
| 8.4 | `is_prime(n : Int) -> Bool` | `0⇒false`、`1⇒false`、`2⇒true`、`3⇒true`、`4⇒false`、`-7⇒false`、`25⇒false`、`7919⇒true`、`15485863⇒true`、`15485864⇒false`、`2147483647⇒true`、`2147483646⇒false` | `n < 2` 一律 `false`，**不报错** | `NumberUtil.isPrimes(int)` | **不跟随**：hutool 源码第一行 `Assert.isTrue(n > 1, …)`，`isPrimes(1)` 抛异常——判定函数不能对"1 是不是素数"这个问题报错。地标读数（7919 = 第 1000 个素数、15485863 = 第 100 万个、2147483647 = 梅森素数 M31）是数论常识，不由本库自算自证 |
| 8.5 | `isqrt(n : Int) -> Int raise NumError` | `0⇒0`、`1⇒1`、`4⇒2`、`8⇒2`、`9⇒3`、`2147395600⇒46340`、`2147483647⇒46340`；每条同时断言 `x² ≤ n < (x+1)²`。报错档：`isqrt(-1)⇒NegativeRadicand -1` | 定义 = 满足 `x*x <= n` 的最大非负 `x`，**不经浮点** | `NumberUtil.sqrt(long)`（逐位开方） | **不跟随**：hutool 那一档没有负数防线，`sqrt(-1)` 静默给正数读数。本库改成显式 `raise` |
| 8.6 | `lcm(a : BigInt, b : BigInt) -> BigInt` | `(0,0)⇒0`、`(0,7)⇒0`、`(12,18)⇒36`、`(-4,6)⇒12`、`(-4,-6)⇒12`、`(2147483647,3)⇒6442450941`、`(103903,132949)⇒13813799947`（后两条**超出任何一档 `Int`**，正是这一件待在 `BigInt` 域的证据） | 结果非负；`lcm(0, x) = 0` 来自"0 是每个整数的倍数"这条定义，不是特例补丁 | `NumberUtil.multiple(int, int)` | **不在 `Int` 域出**：hutool 那档靠"先算 `long` 再拿 `Integer.MAX_VALUE` 判界抛 `ArithmeticException`"，那个界就是 int 上界，换目标换界（§0.1） |
| 8.7 | `factorial(n : Int) -> BigInt raise NumError` | `0⇒1`、`1⇒1`、`5⇒120`、`12⇒479001600`、`20⇒2432902008176640000`、`21⇒51090942171709440000`、`25⇒15511210043330985984000000`。报错档：`factorial(-1)⇒NegativeFactorial -1` | `0! = 1`；输入是 `Int`（计数用的），输出是 `BigInt`（会长的） | `NumberUtil.factorial(long)` / `factorial(long, long)` | **不设 20 的上界**：hutool 查表到 `20!`（`long` 装得下的最大档），`n > 20` 抛 `IllegalArgumentException`；`BigInteger` 版它有，本库把精确版当唯一一档。hutool 的 `factorial(start, end)` 在 `start < end` 时**返回 0**（源码里 `if (start < end) return 0L`），这不像"区间乘积"的语义，本库不补这一件 |
| 8.8 | `combination_count(n : Int, m : Int) -> BigInt raise NumError` | `C(5,2)⇒10`、`C(50,6)⇒15890700`、`C(5,0)⇒1`、`C(5,5)⇒1`、`C(5,6)⇒0`、`C(30,15)⇒155117520`。报错档：`(-1,2)⇒NegativeCount -1 2` | `m > n ⇒ 0`（数学值，不是错误）；负数报错 | `MathUtil.combinationCount` → `Combination.countBig` | **逐条跟随 `countBig`**（负数抛、`m>n` 给 0、`m = min(m, n−m)` 后每步整除的迭代式）。hutool 另有返回 `long` 的 `Combination.count`，源码已标 `@Deprecated`，理由是 `big.longValue()` 静默截断高位；`countSafe` 走 `longValueExact()`。本库只出精确档 |
| 8.9 | `arrangement_count(n : Int, m : Int) -> BigInt raise NumError` | `A(5,2)⇒20`、`A(10,3)⇒720`、`A(7,0)⇒1`、`A(20,20)⇒2432902008176640000`、`A(3,5)⇒0`。报错档：`(3,-1)⇒NegativeCount 3 -1` | 同 8.8 | `MathUtil.arrangementCount` → `Arrangement.count` | **一处口径分岔**：hutool `Arrangement.count` 在 `m > n` 时抛 `IllegalArgumentException`，而同包 `Combination.countBig` 同情形给 `0`——一本书两种口径。本库统一按数学值给 `0` 并写明。hutool 的 `long` 档在 `A(21,21)` 靠 `next < result` 检出溢出抛 `ArithmeticException`；本库直接给 `21!` 真值（8.7 同一档） |
| 8.10 | `pub(all) enum RoundingMode { Up Down Ceiling Floor HalfUp HalfDown HalfEven }` | 七档在 `±2.5` / `±2.1` / `±0.5` 三个网格上的读数（`num_test.mbt` 的「半值网格」与「非平局分道」两块） | 不含 `UNNECESSARY`（Java 那档的语义是"舍入必须无损否则报错"，hutool 无对应入口，本库也不发明） | `java.math.RoundingMode`（hutool `round` 的参数类型） | **七档 = Java 八档去掉 `UNNECESSARY`**。档名与 Python `decimal` 七档双射（`ROUND_UP`/`ROUND_DOWN`/`ROUND_CEILING`/`ROUND_FLOOR`/`ROUND_HALF_UP`/`ROUND_HALF_DOWN`/`ROUND_HALF_EVEN`），两腿同名同义，所以模式本身不需要第三个读数源 |
| 8.11 | `round_to_str(x : Double, scale : Int, mode~ : RoundingMode = HalfUp) -> String raise NumError` | 36 条逐条读数只存在于 `num_test.mbt` 的四块舍入用例里（本表不重抄一遍——抄了就有第三份读数，改哪份都无人知道）。三条最容易写错的：`2.675` 舍 2 位 ⇒ `"2.68"`；`1.0e21` 舍 0 位 ⇒ `"1000000000000000000000"`（平格式，22 位）；`1.0e-7` 舍 9 位 ⇒ `"0.000000100"` | 输出**小数位数恰好 = `scale`**；平格式永不指数记法；**零的形状按 Java 实测**：`0.0` 舍到 `scale <= 0` 给 `"0"`（不补整数侧的零），舍到 `scale > 0` 给 `"0." + scale 个零`；**不保留负零**（`-0.0` 舍 2 位 ⇒ `"0.00"`，同 `BigDecimal`——它没有带符号的 0）；`scale ∈ [-323, 308]` 之外 ⇒ `ScaleOutOfRange`；`NaN`/`±Infinity` ⇒ `NotFinite` | `NumberUtil.round(v, scale, mode).toPlainString()`（hutool 另有 `roundStr` 同义档） | `Double.toString` 那一跳本库走 core 的 `Double::to_string`：**三档实测逐值一致**（19 个夹具在 `wasm`/`js`/`wasm-gc` 上串完全相同，形如 ECMAScript `Number::toString`：`1e+21`、`123456789012345680`、`-0.0` 打 `0`）。所以"最短十进制"这条在四档上是同一个数 |
| 8.12 | `round_to(x : Double, scale : Int, mode~ : RoundingMode = HalfUp) -> Double raise NumError` | 由 8.11 的串解析回最近可表值：`round_to(2.675, 2) = 2.68`、`round_to(1250.0, -2) = 1300.0`、`round_to(9.996, 2) = 10.0`、`round_to(-0.5, 0) = -1.0` | 报错档同 8.11。**不承诺结果就是那个十进制数**——要精确形状取 8.11 | `NumberUtil.round(v, scale)`（返回 `BigDecimal`） | 结构性差异：hutool 出 `BigDecimal`（十进制精确），本库出 `Double`（回到最接近的可表值）。这也是为什么 `round_to_str` 是主形态、`round_to` 是派生形态 |
| 8.13 | 边界三档（`scale` 两端 + 增长档） | `round_to_str(0.0, 308).length() = 310`（`"0."` 后挂 308 个零）；`round_to_str(0.0, -323) = "0"`；`round_to_str(1.5, 309)`/`(-324)`/`(100000)` 三档 ⇒ `ScaleOutOfRange` 带原读数 | 界取 **`[-323, 308]`**：`Double` 自己的十进制指数范围，本机实测 `parse_double("1e309")` **报错**、`"1e-324"` 给 `0`、`"1e-323"` 给 `1e-323`、`"1e308"` 给 `1e+308`。这条界**与目标无关**（`Double` 恒 64 位），所以可以冻结 | `BigDecimal.setScale` 允许任意 `int` scale | 明码拒绝而不是产出一根几十万字符的串：`scale` 大到这个范围外，对一个 `Double` 能携带的信息没有任何影响 |

## 4. 读数从哪来

本包不是编码件（没有 RFC 向量可抄），所以**权威 = 定义 + 第二套实现**，而且两条腿必须是真跑出来的：

1. **Python 镜像**（数论腿）：`math.gcd`、`math.isqrt`、`math.comb`、`math.perm`、`math.factorial`、
   **`pow(a, -1, m)`**（CPython 内置模逆，独立实现）。`ext_gcd` 用一份独立写的截断除法式扩展欧几里得
   （注意：Python 的 `//` 是 floor 除，与 MoonBit/Java 的向零取整不同，镜像里必须显式用 `trunc_div`，
   否则整个负半边全错——这条是本轮生成时真踩到的）。每条断言都还带**不变量复算**（贝祖等式、
   `(inv*a) % m == 1`、`x² ≤ n < (x+1)²`、`m > n ⇒ 0`），不是只看等号。
2. **两腿对撞的舍入腿**：先按 hutool 那条路（最短十进制串 → 十进制舍入）用 Python
   `Decimal(repr(x)).quantize(..., ROUND_*)` 复算，再用**本机 JDK 17** 跑
   `BigDecimal.valueOf(v).setScale(s, RoundingMode.X).toPlainString()` 逐条对撞；
   36 条夹具**两腿全等才冻结**，有一条不等就停下查（生成脚本里是 `assert`，不是注释）。
   Java 这一腿不是装饰：它就是 hutool `round` 的运行时候，用它等于让参照系自己出数。
3. **复核探针自己也要被复核**：本轮把手打的 `round_to_str(0.0, -323)` 期望值灌回复核脚本时，两腿**当场不一致**
   ——我的十进制模型给 `"0"` 后面补 323 个零，Java 给 `"0"`。以 Java 为准修正模型（零值 + `scale <= 0` 不补
   整数侧的零；`scale > 0` 才保留小数位），并把这条形状写进 #8.11。**这就是手打期望值的代价**：错的那份往往是我的模型，
   不是测试。
4. **对拍腿（门禁 G8）与分岔腿**：core `Double::round` 与本包 `HalfUp` 的**分岔**用真实调用钉住
   （`(-0.5).round() == 0.0` 与 `round_to(-0.5, 0) == -1.0` 同时断言，正半边再断言两边相等）；
   `gcd` 与 `ext_gcd` 互相钉（网格里 `g == gcd(a,b)`）；`BigInt` 侧全程只比 `.to_string()`，
   一次 `.to_int()` 都不做（§0.1 的回绕实测就是这条决定的依据）。
5. **数论常识档**：7919（第 1000 个素数）、15485863（第 100 万个）、2147483647（梅森素数 M31）、
   `20!` / `21!` / `25!` 的位数与值——这几条不由本库自算自证，防止"镜像和实现同一套错误"。
6. **hutool 侧只用来反推语义**，不搬实现、不写 Java 式表达式（红线二）。§5 的每条"不跟随"都给了源码位置。

## 5. 不跟随 hutool 清单（逐条源码级证据）

| hutool 件 | 源码事实 | 本库怎么办 |
|---|---|---|
| `NumberUtil.divisor(int,int)` | `while (m % n != 0) { … } return n`——`n = 0` 除零崩；`divisor(-12, 8)` 给 `-4` | `gcd` 结果恒非负、0 档有定义（8.1） |
| `NumberUtil.multiple(int,int)` | `(long) m / gcd * (long) n` 后拿 `Integer.MAX_VALUE` 判界，越界抛 `ArithmeticException` | `lcm` 只在 `BigInt` 域（8.6 / §0.1） |
| `NumberUtil.isPrimes(int)` | 第一行 `Assert.isTrue(n > 1, …)`——`isPrimes(1)` 抛 | `is_prime` 对 `n < 2` 给 `false`（8.4） |
| `NumberUtil.sqrt(long)` | 逐位开方，**没有**负数分支——`sqrt(-1)` 静默给正数 | `isqrt` 对 `n < 0` 报 `NegativeRadicand`（8.5） |
| `NumberUtil.factorial(long)` | 查表 `FACTORIALS` 到 20，`n < 0 \|\| n > 20` 抛 | 不设上界，`BigInt` 精确（8.7） |
| `NumberUtil.factorial(long,long)` | `if (0 == start \|\| start == end) return 1`；`if (start < end) return 0` | **不做这一件**：`start < end ⇒ 0` 与"区间乘积"的直觉相反，本库不复制这种反直觉读数（8.7 备注） |
| `Arrangement.count(n,m)` | `m < 0 \|\| m > n` 抛 `IllegalArgumentException`；`long` 累乘 + `next < result` 溢出抛 | `m > n` 给 `0`、无溢出档（8.9） |
| `Combination.count` | 方法上标了 `@Deprecated`，注释掉的路是 `countBig(...).longValue()`（静默截断） | 只出精确档（8.8） |
| `NumberUtil.roundDown/roundHalfEven/roundCeiling/roundFloor` | 四个都是 `round(v, scale, MODE)` 的薄别名 | **不造同义名**：一档 `mode` 参数覆盖七档（`round_to` / `round_to_str` 各一次） |
| `NumberUtil.isNumber/isInteger/isDouble/isLong`、`parseInt(s, default)` | 把 `parse` 的异常压成 `boolean` 或默认值 | **不做**（§0.4） |
| `NumberUtil.nullToZero` / `null2Zero` / `toStr(Number)` | 全靠 `null` 语义 | **不做**：本库无 `null`，可选值走 `A?` |
| `NumberUtil.decimalFormat(pattern,…)` / `formatPercent` | 底下是 `java.text.DecimalFormat`（locale、分组、货币模式全套） | `decimalFormat` 在 ROADMAP「不做」里（完整 `java.text` pattern）；`format_percent` / 千分位**归第二批**（封闭子集 + 显式拒绝） |
| `NumberUtil.add/sub/mul/div(BigDecimal…)` | `BigDecimal` 精确四则 | **不做**：完整 `BigDecimal` 在「不做」里；第二批的 `Money` 薄档只覆盖定点两位这一种形状 |
| `MathUtil.yuanToCent(double)` / `centToYuan(long)` | `new Money(yuan).getCent()`——挂在 `Money` 上 | 与 `Money` 薄档同批（§6） |
| `NumberUtil.getBinaryStr` / `binaryToInt` / `toBytes` / `toUnsignedByteArray` | 进制与字节互转 | **不做**：core `to_string(radix?)` / `parse_int(base?)` / `BigInt::to_octets`/`from_octets` 已覆盖，`codec` 另有 `radix_encode/decode` |
| `NumberUtil.range` / `generateRandomNumber` / `generateBySet` | 范围数组与随机 | **不做**：core `Int::until` 覆盖范围，随机归 `rand` 包 |
| `NumberUtil.decimalFormat(pattern,…)` / `decimalFormatMoney` / `formatPercent` | 三件都走 `NumberFormat.getXxxInstance()`：① 随 **JVM 默认 locale** 变；② 属"`DecimalFormat` 对二进制精确值舍入"那个族，与 `BigDecimal.valueOf` 的最短十进制族在同一条输入上给两种答案（本表下有实测表） | `format_thousands` / `format_percent` **只承诺最短十进制这一族 + 三位一隔这一档**（#8.14/#8.15），pattern 全套与 locale 在「不做」里 |
| `Money(double amount)` | 源码 `this.cent = Math.round(amount * getCentFactor())`——先浮点乘再 `floor(x+0.5)`，**类头声明的 `DEFAULT_ROUNDING_MODE = HALF_EVEN` 在这条构造路上一次都没生效**（`Money(BigDecimal)` 那条才用） | `Money::from_yuan` 一律走最短十进制 + 显式模式（默认 `HalfEven`）；三档实测分岔写进 #8.19 并做成用例注释 |
| `Money.allocate(int)` | 负 `cent` 时 `remainder = cent % targets` 为负 ⇒ 补余的 `for (i = 0; i < remainder; i++)` 一次都不跑，分完的和不回原值；索引错配还会数组越界 | 负档本库**规则化**（按绝对值分配再回贴符号），所以它不进参照实现对撞，改由两条不变量当判据（§4 第 4 条、#8.23） |
| `Money.allocate(long[])` | `(cent * ratios[i]) / total` 是 `long` 直接乘，**没有溢出防线**（静默回绕） | 本库先取绝对值算再判界，越界 `MoneyOverflow`（#8.24）；`2^62` 分按 `3:1` 分就是那条夹具 |
| `Money` 的 `Currency`/`digit`（`centFactor = 10^digit`）与 `toStringAndUnit`（中文大写） | 多币种小数位与中文金额 | 前者**不做**（薄 `Money` 固定两位，#8.17），后者属**第三批**（中文数字整块） |
| `NumberUtil.decimalFormat(pattern,…)` / `decimalFormatMoney` / `formatPercent` | 三件都走 `NumberFormat.getXxxInstance()`：① 随 **JVM 默认 locale** 变；② 属"`DecimalFormat` 对二进制精确值舍入"那个族，与 `BigDecimal.valueOf` 的最短十进制族在同一条输入上给两种答案（本表下有实测表） | `format_thousands` / `format_percent` **只承诺最短十进制这一族 + 三位一隔这一档**（#8.14/#8.15），pattern 全套与 locale 在「不做」里 |
| `Money(double amount)` | 源码 `this.cent = Math.round(amount * getCentFactor())`——先浮点乘再 `floor(x+0.5)`，**类头声明的 `DEFAULT_ROUNDING_MODE = HALF_EVEN` 在这条构造路上一次都没生效**（`Money(BigDecimal)` 那条才用） | `Money::from_yuan` 一律走最短十进制 + 显式模式（默认 `HalfEven`）；三档实测分岔写进 #8.19 并做成用例注释 |
| `Money.allocate(int)` | 负 `cent` 时 `remainder = cent % targets` 为负 ⇒ 补余的 `for (i = 0; i < remainder; i++)` 一次都不跑，分完的和不回原值；索引错配还会数组越界 | 负档本库**规则化**（按绝对值分配再回贴符号），所以它不进参照实现对撞，改由两条不变量当判据（§4 第 4 条、#8.23） |
| `Money.allocate(long[])` | `(cent * ratios[i]) / total` 是 `long` 直接乘，**没有溢出防线**（静默回绕） | 本库先取绝对值算再判界，越界 `MoneyOverflow`（#8.24）；`2^62` 分按 `3:1` 分就是那条夹具 |
| `Money` 的 `Currency`/`digit`（`centFactor = 10^digit`）与 `toStringAndUnit`（中文大写） | 多币种小数位与中文金额 | 前者**不做**（薄 `Money` 固定两位，#8.17），后者属**第三批**（中文数字整块） |
| `NumberUtil.compare` / `max(...)` / `min(...)` / `equals(double,double)` / `isValid(double)` | `compare`/变参极值/容差相等/有限性判定 | **不做**：core 的 `Compare`、`Double::is_close`、`is_nan`/`is_inf` 全都有（§1 第一、四行） |
| `NumberUtil.calculate(String)` | 走 `Calculator`（`BigDecimal` 精度） | 独立批次（§6 第四批），不混进本契约 |

## 6. 这一批不含（三格各自是一整块）

| 批次 | 内容 | 为什么不和本批一起出契约 |
|---|---|---|
| ~~第二批~~ **已出契约（§9，#8.14~#8.25）** | 千分位与百分比 + `trim_trailing_zeros` + 薄 `Money`（分用 `Int64`、固定两位、`allocate` 两式带余数归属） | 两条前置决策都在 §9 落定：① 分为什么是 `Int64`（定宽 ⇒ 越界这条读数与目标无关，`Int` 做不到）；② 只承诺"三位一隔"这一档，不碰 `java.text` 的 pattern 全套与 locale |
| 第三批 | 中文数字（`NumberChineseFormatter` 简/繁/金额大写/口语四模式 + `chinese_to_number` / `chinese_money_to_number` 反向）与英文 word（`NumberWordFormatter`） | 码表 + 零的折叠 + `formatThousand` 在 10~19 档去"一"这些都是一格格的读数，混进本批会让这份契约的评审面翻倍。hutool 侧两件都在 `cn/hutool/core/convert/`（**不是** `math/`） |
| 第四批 | `Calculator`（`+ - * / % ^ ( )` 表达式求值，hutool 靠 `BigDecimal` 保精度） | **得先决定十进制精确算术用什么形状**：本库不做完整 `BigDecimal`（ROADMAP「不做」），所以这一件要么自建定点、要么走有理数——那是结构决策，不能顺手写进求值器里 |
| 后续可选 | `BigInt` 域数论（`big_gcd` / `big_lcm` / `big_ext_gcd` / `big_mod_inverse`） | `lcm` 已经在 `BigInt` 域；其余四件的真实需求方是二期 RSA（`BigInt::pow(…, modulus?)` 门票 core 已给）。现在出签名就等于替还没评审的 RSA 批次预先承诺 |

## 7. 本轮编译器/工具链裁决（进仓内 AGENTS.md）

| 裁决 | 最小样本与读数 |
|---|---|
| 带默认值的实参必须是**标注参数**，写法是 `mode~ : T = V` | `mode : T~ = V` 判 `Lexing error: unrecognized character "~"`；`mode : T = V` 判 `Only labelled arguments can have default value`（.mbti 里显示为 `mode? : RoundingMode`） |
| 字符串插值要**转义** `\{x}`，裸 `{x}` 就是普通字符 | `println("plain {s}")` 打出 `plain {s}`；`"NonCoprime \{a} \{m}"` 才插值 |
| `expr catch { pat => arm }` 的各分支必须与 `expr` **同型** | `(@num.mod_inverse(0, 5)) catch { … => "NonCoprime…" }` 判 `has type String, wanted Int`；改用 `try { let _ = …; "未抛错" } catch { … }` 通过（`coll`/`date` 的 `err_shape` 就是这个形状） |
| 十进制浮点字面量必须**带小数点**才能用指数 | `[5e-324]` 判 `Parse error, unexpected token id`；`1.0e-7`、`1.0e21` 通过 |
| `Int` 字面量按**当前目标的位宽**校验 | `4611686018427387904` 在 wasm 档判 `Integer literal … is out of range`；大整数夹具走 `BigInt::from_string` |
| 数字字面量点方法要加括号 | `1500000000.next_power_of_two()` 判 `Parse error`；`(1500000000).next_power_of_two()` 通过（同上一轮 `32.to_byte()` 那条） |
| core `Int::next_power_of_two` 把 **32 位写死** | 源码 `let max_power_of_two = 1073741824` 与 `(2147483647 >> ((self - 1).clz() - 1)) + 1`，实测 `1500000000` 档给 `1073741824`（在 64 位 `Int` 的 native 档这个语义就是可疑的）。本包不依赖也不包装它 |
| `@math.pi` 已废弃，改 `@math.PI` | 编译期 `Warning (deprecated): Use `PI` instead`（本包不用常数 π，只在文档里记这条） |
| **方法定义写成 `pub fn (m : Money) cent() -> Int64` 在本版不合法** | 判 `Parse error, unexpected token `(``；正写法是同包既有的 `pub fn Money::cent(self : Money) -> Int64`（core 的 `.mbti` 也是这个形状：`pub fn BigInt::add(Self, Self)`） |
| 结构体字段**不用逗号分隔** | `cent : Int64,` 判 `Expecting a newline or `;` here, but encountered `,`（本仓 `mapx` 的 `BiMap`/`Table` 都是裸换行，跟着抄就行） |
| Char 默认值不能再 `as Char` | `sep~ : Char = ',' as Char` 判 `Char is not a trait object type, it cannot be used on the right hand side of `as``；裸 `','` 已是 `Char` |
| **加错误变体会让既有的穷尽 `match` 当场报 `partial_match`** | 第二批给 `NumError` 加五个变体后，第一批 `num_test.mbt` 里的 `show(err)` 立刻报错——这条是好事：它逼着所有错误形状展示函数一起更新，不会让新变体悄悄漏网（上一轮 `codec` 也撞过同一条） |

## 8. 用例索引（第一批 27 块 = 250 条断言；第二批 17 块见 §9）

`num/num_test.mbt` 17 块（块名就是文件里的名字，不重排）：

1. `gcd 恒非负、0 档与符号档` 2. `ext_gcd 的逐条读数与贝祖不变量` 3. `mod_inverse 取最小非负剩余`
4. `mod_inverse 的两类报错各带原读数` 5. `is_prime 的 0/1/负数档与地标素数`
6. `isqrt 是 floor(sqrt(n))，负被开方数报错` 7. `lcm 只在 BigInt 域（结果可超 Int）`
8. `factorial 不设 20 的上界` 9. `组合数与排列数：m>n 给 0，负数报错`
10. `十进制分岔：2.675 与 1.005 这类最短十进制档` 11. `半值网格上三档平局模式（±2.5 / ±0.5）`
12. `非平局时 Up/Down 与 Ceiling/Floor 分道` 13. `负 scale、指数记法与补零位`
14. `省掉 mode 就是 HalfUp` 15. `round_to 出 Double：舍入后回到最近可表值`
16. `NaN/无穷与 scale 界外一律报错` 17. `分岔夹具：core 的 round 与本包 HalfUp 在负半边不同`

`num/README.mbt.md` 10 块：每条都是对外文档的一部分，同时被 `moon test` 真编译真执行。

**此刻读数（第二批契约态）**：`moon test --target wasm` 收集 **244** 条，`passed 227 / failed 17`——
红的正是第二批的 17 块（`format_test.mbt` 5 + `money_test.mbt` 8 + `README.mbt.md` 4），属设计态；
基线 `BASELINE_TESTS` 抬到 **244**（负向对照：抬到 245 当场 RED）。
第二批 17 块的**每一条字面量都由发射器从 `expectations2.json` 灌进去**（手打零条）——
第一批那次"手打期望值抓出模型错"的教训是这么落的：生成器里没有手打位置，就没有手打机会。
两条变异对照真打过：把 `HalfUp` 的平局档改成"不进位" ⇒ **6 块**立刻红
（`2.675` 那档也红，因为它平局）；拆掉 `lcm` 的 0 档分支 ⇒ `lcm(0, 0)` 那一条红。
第一次打变异时我用 8 空格缩进匹配 `moon fmt` 已改成 6 空格的行，**替换静默没打上、测试仍报 0 失败**——
这种"变异对照自己失效"比没有对照更危险，所以第二条规矩是：**变异必须 assert 打上再跑**（已进 AGENTS）。


## 9. 第二批契约矩阵（#8.14~#8.25：格式化三件 + 薄 `Money`）

第二批的**边界动作**是发现 Java 侧有两个互不一致的舍入族，然后选边——不是顺手加个分隔符。
两条腿的对撞见 §4 第 2 条与本节末尾；所有读数只存在于 `format_test.mbt` / `money_test.mbt` /
`num/README.mbt.md` 的断言里（本表只给形状与最容易写错的几条，抄一遍就有第三份读数）。

| # | 签名 | 冻结读数（夹具与期望都由镜像现算） | 边界/错误 | hutool 对位 | 差异声明 |
|---|---|---|---|---|---|
| 8.14 | `format_thousands(x : Double, scale : Int, mode~ = HalfUp, sep~ = ',', decimal_sep~ = '.') -> String raise NumError` | `1234567.891` 舍 2 位 ⇒ `1,234,567.89`；`-1234.5` 舍 -2 位 ⇒ `-1,200`；`1234567.5` 舍 1 位换 `sep = ' '`、`decimal_sep = ','` ⇒ `1 234 567,5`；`1.0e21` 舍 0 位 ⇒ 22 位整串挂 7 个分隔符 | **定义 = `round_to_str` 之上加一层分组**，与 #8.11 同一条腿、同一个界（`[-323, 308]`）、同一套报错（`NotFinite`、`ScaleOutOfRange`）。分组只作用于整数部分，从右往左三位一隔，负号在外不参与分组 | `NumberUtil.decimalFormat("#,##0.00", v)` / `decimalFormatMoney` | **不跟随，两条实测依据**：① `DecimalFormat` 对 `double` 的**二进制精确值**舍入，`BigDecimal.valueOf` 对**最短十进制**舍入，同输入两种答案（表在本节末）；② 它随 JVM 默认 locale 变（分隔符、组大小、负零都可能不同）⇒ 读数无法跨环境冻结。本库整个数值件只认最短十进制这一族 |
| 8.15 | `format_percent(x : Double, scale : Int, mode~ = HalfUp, suffix~ = "%") -> String raise NumError` | `0.125` 舍 2 位 ⇒ `12.50%`；`0.145` 舍 0 位 ⇒ `15%`；`-0.125` ⇒ `-12.50%`；`1.0e-7` 舍 6 位 ⇒ `0.000010%` | **挪的是十进制小数点，不是 `x * 100.0`**（后者让 `0.145` 变成 `14.499999999999998`）。舍入、`scale` 界、`NotFinite` 全部与 #8.11 同源；`suffix` 是显式参数（要空串就传空串），不做 locale 百分号位置 | `NumberUtil.formatPercent(double, scale)` | **不跟随**：那侧是 `NumberFormat.getPercentInstance()`，随 locale 变且属 `DecimalFormat` 族（`0.145` 舍 0 位它给 `14%`） |
| 8.16 | `trim_trailing_zeros(s : String) -> String raise NumError` | ``"12.3400"` ⇒ `"12.34"`、`"12.00"` ⇒ `"12"`、`"-12.300"` ⇒ `"-12.3"`、`"0.000"` ⇒ `"0"`、`"100.10"` ⇒ `"100.1"`、`"12"` ⇒ `"12"`、`"12."` ⇒ `"12"`、`"0.50"` ⇒ `"0.5"`、`"-0.00"` ⇒ `"0"``；非法串两条：`"abc"`、`"1.2.3"` ⇒ `NotDecimal` 带原串 | 只动**小数部分**的尾随零，小数位清空时连小数点一起去掉；**整数的尾随零不碰**（`"100"` 还是 `"100"`，不会变成 `1E+2` 那类指数形状）；`"-0.00"` ⇒ `"0"`（不保留负零，与 #8.11/#8.21 同族） | `NumberUtil.toStr(bigDecimal, isStripTrailingZeros)` | hutool 那件挂在 `BigDecimal` 上，本库没有 `BigDecimal` ⇒ 输入是**串**。读数腿就是本机 JDK 的 `new BigDecimal(s).stripTrailingZeros().toPlainString()`——我原来手打的那 9 对期望值全部改由这一条腿重新出具（本条恰好一条没错，但规矩是"以腿为准"，不是"以我为准"） |
| 8.17 | `pub(all) struct Money { cent : Int64 }` + `Money::new(cent : Int64) -> Money` | `Money::new(5).to_string()` ⇒ `0.05`；`Money::new(0)` ⇒ `0.00` | 唯一的内部表示就是"分"这个 `Int64`；不做多币种小数位 | `Money(long cent, Currency)` 的 `getCent` 一侧 | **薄档只做两件事**：hutool 的 `Currency`/`digit`（`centFactor = 10^digit`）不做，中文大写（`toStringAndUnit`）属第三批。**分为什么是 `Int64` 而不是 `Int`**：`Int` 位宽随目标变（§0.1），`Int64` 三档与 native 同宽 ⇒ "越界"是一条可以冻结的读数；`Int64` 满值 `9223372036854775807` 分 = `92233720368547758.07` 元，够到任何真实金额，而够不到不等于可以静默回绕 |
| 8.18 | `Money::from_yuan_str(s : String, mode~ = HalfEven) -> Money raise NumError` | ``"12.345"` ⇒ `1234` 分、`"12.335"` ⇒ `1234` 分、`"0.005"` ⇒ `0` 分、`"1.005"` ⇒ `100` 分、`"-12.345"` ⇒ `-1234` 分、`"0"` ⇒ `0` 分、`"123"` ⇒ `12300` 分` | 输入是**元**的十进制串，小数位数不限；输出是分。非十进制 ⇒ `NotDecimal(s)`；大到分装不进 `Int64` ⇒ `MoneyOverflow` | `Money(String amount)`（走 `BigDecimal`） | **默认档 `HalfEven` 与 #8.11/#8.14 的 `HalfUp` 不对称，是故意的**：hutool 自己就是 `NumberUtil.round` 用 `HALF_UP`、`Money.DEFAULT_ROUNDING_MODE = HALF_EVEN`（源码常量就在类头）。两处都跟随比"顺手统一"更负责，要 `HalfUp` 就显式传——`"1.005"` 这一条就是两种答案的现成对照（100 vs 101） |
| 8.19 | `Money::from_yuan(yuan : Double, mode~ = HalfEven) -> Money raise NumError` | ``1.15` ⇒ `115` 分、`2.675` ⇒ `268` 分、`0.025` ⇒ `2` 分、`0.145` ⇒ `14` 分、`0.135` ⇒ `14` 分、`-2.5` ⇒ `-250` 分、`12.345` ⇒ `1234` 分、`0.0` ⇒ `0` 分、`100.0` ⇒ `10000` 分、`0.005` ⇒ `0` 分` | `NaN`/`±Infinity` ⇒ `NotFinite`；越界 ⇒ `MoneyOverflow` | `Money(double amount)` | **不跟随，有源码级证据**：那侧写的是 `this.cent = Math.round(amount * getCentFactor())`——先**浮点乘**再 `Math.round`（= `floor(x + 0.5)`），于是它宣称的 `HALF_EVEN` 在这条构造路上一次都没生效（`Money(BigDecimal)` 那条才用模式）。本机对撞出三档分岔（本库 / 那侧）：`0.025` ⇒ `2` / `3`；`12.345` ⇒ `1234` / `1235`；`0.005` ⇒ `0` / `1`。本库只留一条口径：最短十进制 + 显式模式 |
| 8.20 | `Money::cent() -> Int64` / `Money::to_yuan() -> Double` | `Money::new(1234).cent() = 1234`；`to_yuan()` 就是 `cent / 100.0` | 恒不失败 | `getCent()` / `getAmount()`（后者是 `BigDecimal`） | `to_yuan()` **不承诺精确**（`Double` 装不下 `0.07` 这类值），存在只为对接浮点接口；要可信形状用 `to_string`。整数出口只有 `cent`，所以溢出检查全部发生在"进"的那一侧 |
| 8.21 | `Money::to_string() -> String` | ``0` 分 ⇒ `"0.00"`、`5` 分 ⇒ `"0.05"`、`-5` 分 ⇒ `"-0.05"`、`1234` 分 ⇒ `"12.34"`、`-1234` 分 ⇒ `"-12.34"`、`9223372036854775807` 分 ⇒ `"92233720368547758.07"`` | **恒两位小数**；`0` 分 ⇒ `"0.00"`；不保留负零；满值 `Int64` 分也是平格式（不出指数、不出科学计数） | `Money.toString()` = `getAmount().toString()` | 同一条读数由 JDK 的 `new BigDecimal(cent).movePointLeft(2).toPlainString()` 出具并逐条对撞（含 `Int64::MAX` 那一条） |
| 8.22 | `Money::add(other : Money) -> Money raise NumError` / `sub` | `"12.34" + "0.66" ⇒ "13.00"`、`"12.34" - "0.34" ⇒ "12.00"`、`"-1.00" + "1.00" ⇒ "0.00"`；`Int64::MAX` 分 `+ 1` ⇒ `MoneyOverflow`，`Int64::MIN` 分 `- 1` ⇒ `MoneyOverflow`，`MAX - 1` 分正常 ⇒ `"92233720368547758.06"` | 分域整数加减，无精度损失 | `Money.add/sub`（`long` 直接相加，**没有溢出防线**） | 越界必须 `raise`。`MoneyOverflow` **不带载荷**：两个操作数调用方都有，"越界"这件事本身才是新信息（同 `mapx` 的不带载荷立场，见 0.3） |
| 8.23 | `Money::allocate_even(targets : Int) -> Array[Money] raise NumError` | ``1000` 分分 3 份 ⇒ `[334,333,333]`；`1000` 分分 1 份 ⇒ `[1000]`；`999` 分分 4 份 ⇒ `[250,250,250,249]`；`-1000` 分分 3 份 ⇒ `[-334,-333,-333]`；`0` 分分 5 份 ⇒ `[0,0,0,0,0]`；`7` 分分 3 份 ⇒ `[3,2,2]`；`-7` 分分 2 份 ⇒ `[-4,-3]`` | `targets >= 1`；**和恒等于原值**、任意两份之差不超过一分（这两条在 `[-1000..1000] × 1..8` 网格上逐片断言）；`targets <= 0` ⇒ `NonPositiveTargets` | `Money.allocate(int)` | 正档逐条跟随（`low = cent / targets`、`high = low + 1`、前 `cent % targets` 份拿 `high`）。**负档不跟随**：那侧 `remainder` 为负 ⇒ 补余循环一次都不跑 ⇒ 分完的和不回原值；份数与索引错配时还会踩数组越界。本库按绝对值分配再回贴符号，负档因此**不进参照实现对撞**，改由两条不变量当判据（§4 第 4 条） |
| 8.24 | `Money::allocate_by_ratio(ratios : Array[Int]) -> Array[Money] raise NumError` | ``1000` 分按 `[1,1,1]` ⇒ `[334,333,333]`；`900` 分按 `[2,1]` ⇒ `[600,300]`；`1000` 分按 `[2,3]` ⇒ `[400,600]`；`100` 分按 `[1,1,1]` ⇒ `[34,33,33]`；`-1000` 分按 `[1,1]` ⇒ `[-500,-500]`；`0` 分按 `[1,2]` ⇒ `[0,0]`；`1000` 分按 `[1,0,1]` ⇒ `[500,0,500]`` | 与 `ratios` 同长；逐项 `>= 0` 且和 `> 0`；逐份向零截断，余数按索引序每份 +1（hutool 的算法）；`cent * ratios[i]` 越界 ⇒ `MoneyOverflow`；出现负比例 ⇒ `NegativeRatio(r)`；和 `<= 0` ⇒ `RatioSumNotPositive(sum)` | `Money.allocate(long[])` | 那侧 `(cent * ratios[i]) / total` 是 `long` **静默回绕**，没有任何防线；本库先算绝对值再判界。"全零比例"（没有分母）与"出现负比例"（方向都没定）是两种错，所以两个变体不合并。`2^62` 分按 `3:1` 分就是那条越界夹具 |

### 9.1 两个族：同一台 JDK 对同一个数的两种答案

对撞时两腿确有不符合的条目，逐条归因后确认**不是谁的实现写错了，是 Java 自己有两个族**
（`BigDecimal.valueOf(double)` 内部走 `Double.toString` ⇒ 最短十进制；`DecimalFormat` 直接对 `double`
的二进制精确值取数字）。本库选最短十进制那一族，理由不是偏好而是"一个库里对同一个数只许有一种答案"：

| 夹具 | 本库（最短十进制族） | `DecimalFormat`（二进制精确值族） |
|---|---|---|
| `-0.0` 舍到 2 位 | `0.00` | `-0.00` |
| `2.675` 舍到 2 位 | `2.68` | `2.67` |
| `0.145` 舍到 0 位 | `15%` | `14%` |

`DecimalFormat` 那一列也是 hutool `decimalFormat`/`formatPercent` 实际会给出的值（源码：
`NumberFormat.getNumberInstance()` / `getPercentInstance()`），所以这张表同时就是 §5 那两条"不跟随"的读数依据。

