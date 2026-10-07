# 契约 08 · num（数值计算件·第一批：数论 + 十进制舍入）

> 状态：**三批都已交付**（10-05，第三批见 §10；第四批 `Calculator` 还没开工）。
> 25 条公开项见 `num/pkg.generated.mbti`25 条公开项见 `num/pkg.generated.mbti`（`moon info` 后零漂移）；冻结期望值在 `num/num_test.mbt`（17 块 205 条断言）与
> `num/README.mbt.md`（10 块 45 条断言）。第二批的期望值在 `format_test.mbt`（5 块）、
> `money_test.mbt`（8 块）与 README 的 4 个文档块。两批**都是镜像读数一字未改**地从红变绿：
> `244 = 绿 244 / 红 0`，`wasm`/`js`/`wasm-gc` 三档一致，native 档由 CI 出证。矩阵在 §9。
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
| 8.11 | `round_to_str(x : Double, scale : Int, mode~ : RoundingMode = HalfUp) -> String raise NumError` | 36 条逐条读数只存在于 `num_test.mbt` 的四块舍入用例里（本表不重抄一遍——抄了就有第三份读数，改哪份都无人知道）。三条最容易写错的：`2.675` 舍 2 位 ⇒ `"2.68"`；`1.0e21` 舍 0 位 ⇒ `"1000000000000000000000"`（平格式，22 位）；`1.0e-7` 舍 9 位 ⇒ `"0.000000100"` | 输出**小数位数恰好 = `scale`**；平格式永不指数记法；**零的形状按 Java 实测**：`0.0` 舍到 `scale <= 0` 给 `"0"`（不补整数侧的零），舍到 `scale > 0` 给 `"0." + scale 个零`；**不保留负零**（`-0.0` 舍 2 位 ⇒ `"0.00"`，同 `BigDecimal`——它没有带符号的 0）；`scale ∈ [-323, 308]` 之外 ⇒ `ScaleOutOfRange`；`NaN`/`±Infinity` ⇒ `NotFinite`；**挪后进到整数区的前导零必须跳掉**——`0.125` 舍 2 位是 `"12.50%"` 而不是 `"012.50%"`（实现期真踩过：只挪点不跳零，三块立刻红；变异对照也证实这条判据承重） | `NumberUtil.round(v, scale, mode).toPlainString()`（hutool 另有 `roundStr` 同义档） | `Double.toString` 那一跳本库走 core 的 `Double::to_string`：**三档实测逐值一致**（19 个夹具在 `wasm`/`js`/`wasm-gc` 上串完全相同，形如 ECMAScript `Number::toString`：`1e+21`、`123456789012345680`、`-0.0` 打 `0`）。所以"最短十进制"这条在四档上是同一个数 |
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
7. **错误形状与校验顺序也要有腿，不许手打**。第二批一开始把 5 条错误形状写在发射器里（"该报哪种错"是我直接
   打出来的字符串），实现期两条被抓：`[1, -1]` 我写成先报"和为 0"（正确顺序是先报逐项负数）、
   `from_yuan_str` 的越界档被顺手安到 `trim_trailing_zeros` 头上（trim 是纯串归一化，同一个输入在它那里
   是**正常读数**）。处理不是改注释，是给镜像补 `ratio_err`/`str_err`/`add_err` 三条腿，让所有错误形状从腿里出。
8. **不可达的错误档从契约里删掉**：`allocate_by_ratio` 原写"乘法越界 ⇒ `MoneyOverflow`"，而实现走 BigInt 精确算
   之后这一档数学上不可达（`0 <= r_i <= sum` ⇒ 每个结果不超过 `|cent|`）。留它就是一条永远不红的死格；
   删分支并在契约里写明为什么不需要，比留一个测不到的 `raise` 诚实。
7. **错误形状与校验顺序也要有腿，不许手打**。第二批一开始把 5 条错误形状写在发射器里（"该报哪种错"是我直接
   打出来的字符串），实现期两条被抓：`[1, -1]` 我写成先报"和为 0"（正确顺序是先报逐项负数）、
   `from_yuan_str` 的越界档被顺手安到 `trim_trailing_zeros` 头上（trim 是纯串归一化，同一个输入在它那里
   是**正常读数**）。处理不是改注释，是给镜像补 `ratio_err`/`str_err`/`add_err` 三条腿，让所有错误形状从腿里出。
8. **不可达的错误档从契约里删掉**：`allocate_by_ratio` 原写"乘法越界 ⇒ `MoneyOverflow`"，而实现走 BigInt 精确算
   之后这一档数学上不可达（`0 <= r_i <= sum` ⇒ 每个结果不超过 `|cent|`）。留它就是一条永远不红的死格；
   删分支并在契约里写明为什么不需要，比留一个测不到的 `raise` 诚实。

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
| 第四批 | `Calculator`（`+ - * / % ^ ( )` 表达式求值，hutool 靠 `BigDecimal` 保精度） | **得先决定十进制精确算术用什么形状**：本库不做完整 `BigDecimal`（ROADMAP「不做」），所以这一件要么自建定点、要么走有理数——那是结构决策，不能顺手写进求值器里。**该决策已在 §11.1 落定**（`BigInt` 尾数 + 非负 `scale`），这一格随之出契约 |
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
| 8.24 | `Money::allocate_by_ratio(ratios : Array[Int]) -> Array[Money] raise NumError` | ``1000` 分按 `[1,1,1]` ⇒ `[334,333,333]`；`900` 分按 `[2,1]` ⇒ `[600,300]`；`1000` 分按 `[2,3]` ⇒ `[400,600]`；`100` 分按 `[1,1,1]` ⇒ `[34,33,33]`；`-1000` 分按 `[1,1]` ⇒ `[-500,-500]`；`0` 分按 `[1,2]` ⇒ `[0,0]`；`1000` 分按 `[1,0,1]` ⇒ `[500,0,500]`` | 与 `ratios` 同长；**校验顺序写死：逐项形状错先报（`NegativeRatio`），派生量后报（`RatioSumNotPositive`）**——所以 `[1, -1]` 报的是 `NegativeRatio -1` 而不是"和为 0"（同 `coll` 把除零类排前面的那条判断）。`0 <= r_i <= sum` 保证每个结果都不超过 `|cent|`，中间量又走 BigInt 精确算，**所以这一档不发 `MoneyOverflow`（不可达的分支不留）**；`used` 的各项同号、和不超过 `|cent|`，同理不需要带界加法 | `Money.allocate(long[])` | 那侧 `(cent * ratios[i]) / total` 是 `long` **静默回绕**，没有任何防线；本库先算绝对值再判界。"全零比例"（没有分母）与"出现负比例"（方向都没定）是两种错，所以两个变体不合并。`2^62` 分按 `3:1` 分就是那条越界夹具 |

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

## 10. 第三批契约：中文数字与英文 word（#8.26~#8.39）

对位文件：`hutool-core/src/main/java/cn/hutool/core/convert/NumberChineseFormatter.java`（672 行）
与 `NumberWordFormatter.java`（200 行）——**这两件住在 `core/convert/` 而不是 `core/math/`**，
按包名找会找不到（第一批就找错过一次）。`Convert.java` 那边的入口共 6 条：
`numberToWord` / `numberToSimple` / `numberToChinese` / `chineseToNumber` / `digitToChinese` /
`chineseMoneyToNumber`（行号见 §3 的扫描口径）。

### 10.1 三条贯穿这一批的规则

| # | 规则 | 依据（都是本机实测读数，不是口味） |
|---|---|---|
| 10.1a | **正向入口一律收十进制原文串，不收 `Double`** | hutool 自己两条路对同一个数给两种答案：`1.105` ⇒ BigDecimal 路「一点一零五」、double 路「一点一一」；`0.10` ⇒ 「零点一零」/「零点一」；`1.00` ⇒ 「一点零零」/「一」；`0.0` ⇒ 「零点零」/「零」。收 `Double` 就等于把"先按两位舍一次"藏进入口，同一库里出现两个答案 |
| 10.1b | **反向累加走 `Int64`，给真值而不是低位截断** | hutool 的 `chineseToNumber` 返回 `int`：实测「一千亿」⇒ `1215752192`、「九十九万九千九百九十九亿」⇒ `-826389968`（都是低位截断）。与第一批「增长型算术只在精确域」同一条规矩。实现里带溢出防线，但这条防线的可达性另算过一遍（§10.3 第 5 条）：节单位每次用完就清零，越出 `Int64` 需要 10^7 量级字符的输入，**没有夹具能为它变红**——这一点写在这里，不假装测过 |
| 10.1c | **错误只带读数**（档名 + 那个字符/两字窗口 + 码点位置），hutool 的英文句子不进载荷 | 它那句 `Unknown unit '〇' at: 0` / `Bad number '壹贰' at: 1` 里的**位置与窗口**是有信息的读数，跟；`Unknown unit` 这段文案是英文散文，不跟。位置按码点算（本批夹具全在 BMP 内，UTF-16 下标与码点下标重合，这条已核对） |

### 10.2 契约矩阵

| # | 公开项 | hutool 对位 | 关键读数（参考腿） | 用例块 |
|---|---|---|---|---|
| 8.26 | `chinese_of(String) -> String raise` | `format(BigDecimal, false, false)` | `1000000 ⇒ 一百万`（节间不补零）、`1001 ⇒ 一千零一`、`1010 ⇒ 一千零一十`、`-12345.67 ⇒ 负一万二千三百四十五点六七` | 节权位与零的折叠 / 小数逐位与尾零 |
| 8.27 | `chinese_upper_of(String) -> String raise` | `format(BigDecimal, true, false)` | `10000 ⇒ 壹万`、`11 ⇒ 壹拾壹`、`1.105 ⇒ 壹点壹零伍` | 繁体字表对照 |
| 8.28 | `chinese_colloquial_of(String) -> String raise` | `format(BigDecimal, false, true)` | 只改「一十」前缀：`10 ⇒ 十`、`100000 ⇒ 十万`、`-11 ⇒ 负十一`，而 `115 ⇒ 一百一十五` 不动 | 只改「一十」这一处 |
| 8.29 | `chinese_upper_colloquial_of(String) -> String raise` | `format(BigDecimal, true, true)` | **本包读数与繁体档逐条相等**：`10 ⇒ 壹拾`、`-11 ⇒ 负壹拾壹`、`115 ⇒ 壹佰壹拾伍`。hutool 的口语表只有 `一十/一拾/负一十/负一拾` 四条，而繁体档产出的是「壹拾」⇒ 一条都不命中（`f_bd_trad_coll` 腿逐条实测） | 口语表混排简繁，繁体档走不到 |
| 8.30 | `chinese_money_of(String) -> String raise` | `format(double, true, true)`（金额档） | `1 ⇒ 壹元整`、`0.05 ⇒ 伍分`、`0.5 ⇒ 伍角`、`1.105 ⇒ 壹元壹角壹分`、`-12345.67 ⇒ 负壹万贰仟叁佰肆拾伍元陆角柒分`、`99999999999999.99 ⇒ …元玖角**捌**分`、`0.004 ⇒ 整`、`-0.004 ⇒ 负整` | 元/角/分/整的档 + **金额腿走 double**：`Math.round(double × 100)`，所以 `1.105` 落在 110.5 这条平局上给 111 分，而 `99999999999999.99` 的最近 double 是 `…99.984375` ⇒ 9999999999999998 分（捌分）。这不是"先按两位十进制 HALF_UP"那条腿，两条读数见 §10.3 第 4 条 |
| 8.31 | `chinese_money_simple_of(String) -> String raise` | `format(double, false, true)` | `1 ⇒ 一元整`、`0.05 ⇒ 五分`、`1.105 ⇒ 一元一角一分`、`1.015 ⇒ 一元零一分`、`1000000.01 ⇒ 一百万元零一分` | 简写金额（与繁体档只差字表，段取舍逐条一致） |
| 8.32 | `chinese_of_thousand(Int) -> String raise` | `formatThousand(int, false)`，界 ±999 | `10 ⇒ 十`、`11 ⇒ 十一`、`115 ⇒ 一百一十五`、`909 ⇒ 九百零九`、`1000 ⇒ OutOfRange` | 10~19 去「一」与 ±999 界 |
| 8.33 | `chinese_upper_of_thousand(Int) -> String raise` | `formatThousand(int, true)` | `11 ⇒ 拾壹`、`110 ⇒ 壹佰壹拾` | 繁体千分位 |
| 8.34 | `chinese_digit(Char, upper? : Bool) -> Char raise` | `numberCharToChinese(char, boolean)` | `'0'..'9'` 全表两侧读数；非数字字符 hutool 无校验（查表得 -1 继续走），本包给 `UnknownChineseUnit 十 0` | 单字符档与非数字 |
| 8.35 | `int_of_chinese(String) -> Int64 raise` | `chineseToNumber(String)` 返 `int` | 值档 54 条（模型逐条对撞）、错误档 10 条、截断分岔 2 条；认「负」是本包补的（hutool 在此抛错，实测 4 条） | 基本档与裸单位 / 跨节与怪形状 / 认「负」/ 错误形状 / 界走 Int64 |
| 8.36 | `money_of_chinese(String) -> Money raise` | `chineseMoneyToNumber(String)` 返 `BigDecimal` | 键位切分 32 条与 JDK 逐条相等（含「圆」别名两条、`壹分壹厘` 这种尾随垃圾两边都忽略、`壹角壹拾分 ⇒ 20` 分）；「没有元键」3 条声明分岔；「三个键都没内容」⇒ `NotDecimal`（hutool 给 0.00，实测 `元整`、`元`、`分` 三条，错误档共 7 条） | 键位切分与「没有元」不丢值 / 错误形状 |
| 8.37 | `chinese_abbrev(Int64) -> String` | `NumberChineseFormatter.formatSimple(long)` | 阈值 1e4/1e8/1e12 ⇒ `10000 ⇒ 1.00万`、`12345 ⇒ 1.23万`、`1000000000000 ⇒ 1.00万亿`、`Int64::MAX ⇒ 9223372.04万亿`、`-10000 ⇒ -1.00万`（BigDecimal 两位 HALF_UP，与 locale 无关） | 万/亿/万亿 三档 + 绝对值判档 |
| 8.38 | `english_abbrev(Int64) -> String` | `NumberWordFormatter.formatSimple(long)` | 阈值**更早**：`< 1000` 原样（**所有负数走这条**，`-10000 ⇒ -10000`）、`>= 10000` 才换 `w`，否则 `k`；小数最多两位且去尾零 ⇒ `1000 ⇒ 1k`、`9999 ⇒ 10k`、`1000000 ⇒ 100w`；locale 与 double 尾数两条分岔见 10.4 第 5、15 行 | 同后缀不同阈值 |
| 8.39 | `english_word_of(String) -> String raise` | `NumberWordFormatter.format(Object)` | `255 ⇒ TWO HUNDRED AND FIFTY FIVE ONLY`、`1234567 ⇒ ONE MILLION … ONLY`、`0.05 ⇒ ZERO AND CENTS FIVE ONLY`、`1001 ⇒ ONE THOUSAND ONE ONLY`（节之间不补 AND）、`110 ⇒ ONE HUNDRED AND TEN ONLY`（段内才补）；整数上界 15 位（`NUMBER_MORE` 表长） | 三位一节与 ONLY / AND 的位置 / 零分档与负数档 |

错误面新增三条（都只带读数）：`OutOfRange(String)`、`UnknownChineseUnit(Char, Int)`、
`BadChineseNumber(String, Int)`。`NotDecimal(String)` 复用第二批那条（正向的"不是十进制原文"）。

### 10.3 参考腿与对撞统计（读数来源）

1. **JDK 参考腿**：`NumberChineseFormatter.java` / `NumberWordFormatter.java` **逐字转写**（只删
   `package`/`import`、把 `StrUtil`/`NumberUtil`/`ArrayUtil`/`Assert`/`CharUtil` 五个前缀换成本地
   `H.`，helper 按 hutool 自己的源码写——含 `CharUtil.isBlankChar` 那张码点表），跑在本机
   JDK 17.0.14；夹具 = 56 个金额串 × 7 档 + 24 个千分位整数 × 2 档 + 24 个 long × 3 档 +
   60 余条反向串 + 20 条英文 word。
2. **Python 复刻腿（只做反向）**：`chineseToNumber` 与 `chineseMoneyToNumber` 的算法复刻，
   **逐条与 JDK 对撞**：反向整数 71 条一致 / 2 条截断分岔；金额 24 条一致 / 3 条声明分岔。
   模型与 JDK 不符又不是声明过的类别 ⇒ 生成器直接 assert 失败，不会静默出期望值。
3. **同输入双 locale 实跑**：`-Duser.language=de -Duser.country=DE` 与默认对跑，
   **只有 2 条不同**，都在 `abbrev_en` 上：`1234567890123 ⇒ 123456789.01w` / `123456789,01w`。
   这条件在 hutool 里走 `NumberUtil.decimalFormat("#.##", …)`，即 `new DecimalFormat(pattern)`
   吃 JVM 默认 locale ⇒ 本包固定 `.`（10.4 表第 5 行）。
4. **舍入族对撞**：`1.105` 同时进 #8.30（HALF_UP ⇒ 壹元壹角壹分）与第二批
   `Money::from_yuan_str`（HALF_EVEN ⇒ cent=110）——两条读数并排钉住，不强行统一，
   因为 hutool 自己 `NumberUtil.round` 与 `Money.DEFAULT_ROUNDING_MODE` 就分家。
   **但 #8.30 这一腿本身走的是 double**（`format(double, …)` 里 `Math.round(amount * 100)`），
   所以它的"两位 HALF_UP"是浮点意义上的：`1.105 × 100` 的最近 double 恰是 `110.5` ⇒ 111 分，
   而 `99999999999999.99` 的最近 double 是 `99999999999999.984375` ⇒ 9999999999999998 分（捌分，不是玖分）。
   本包照这条腿实现（`Double` 三档同宽、`floor(x + 0.5)` 语义一致），不换成十进制腿——换了那一档就对不上。
5. **反向档 `OutOfRange` 的可达性核算**（10-05 复核轮补）：hutool 的算法每遇一个节单位就把
   `section` 清零，实测「亿亿亿亿亿亿亿亿亿亿」⇒ **0**（十个节单位互相抵消，不是溢出），
   「壹亿贰拾万」⇒ 100200000。所以增量只随输入长度**线性**增长：每 2~8 个字符最多贡献 1e8~1e12，
   要越出 `Int64` 需要 10^7 量级字符的串——夹具放不下，也没有哪条真实输入会走到。
   实现里保留溢出防线（宁可 `raise` 也不静默回绕，与 §0.1 一条），但**这一档没有夹具能为它变红**，
   记在这儿而不是假装它被测过（原契约把「亿亿…」写成 OutOfRange 是模型错，不是 JDK 读数，已改回 0）。
6. **补测轮（10-05，同一天）**：主腿 763 条之外另跑三轮探针，只为把"冻结夹具没覆盖的形状"从猜测
   变成读数——超 Int64 的低位回绕（`2^64+5 ⇒ 五`、`2^64 ⇒ 零`）、丢号档（`-0.05 ⇒ 零点零五`）、
   文法宽窄（`+1 ⇒ 一`、`1e5 ⇒ 一十万`）、word 的表长（16 位 ⇒ `ArrayIndexOutOfBoundsException`）、
   「圆」别名与空键档（`壹圆贰分 ⇒ 1.02`、`元 ⇒ 0.00`）、空格单位（`" 一十" ⇒ 11`）、
   `DecimalFormat("#.##")` 对大 double 的尾数并档（`Int64::MAX ⇒ 922337203685477.6w`）。
   本包块数 22→23（新增一格「文法允许的怪形状」）、断言 336→387：新增的都是这几轮现取的数，
   删掉的 4 条是同一输入既钉值又钉错的自相矛盾行（「负」前缀，见 10.4 第 2 行）。
7. **变异对照十轮（10-05 实现轮，每条都必须有块红，否则那条规则没人看着）**：
   基线 300 绿 0 红。逐条打在实现体上，跑完按字节还原并校验 sha256：
   - 段内「零的折叠」短路 ⇒ 5 块红；节间补零的剥首早退去掉 ⇒ 8 块红；
   - 简/繁字表切换失效（`upper` 恒假）⇒ 6 块红；
   - 中文缩写平局档 `>=` 改窄 ⇒ 1 块红；英文缩写同一处改窄 ⇒ 1 块红；英文去尾零写成补零 ⇒ 1 块红；
     （前两条是**先跑出来没红**才补的夹具：`10050 / 10150 / -10050 / 100000050` 与 `1005 / 10050 / 10150`，
     读数见 10.4 第 15 行——没有判别夹具的档位等于没有档位）
   - 金额腿换成纯十进制 `HalfUp` ⇒ 2 块红：这条是专门为"跟的是 double 那一族"立的对照，
     `99999999999999.99` 只有走浮点才读得出「捌分」；
   - 反向裸单位不补一（`十二 ⇒ 2`）⇒ 3 块红；反向「零」不让节结束（`unit` 不清零）⇒ 2 块红；
   - 英文百位无条件补 `AND` ⇒ 1 块红；口语替换误吃两位 ⇒ 1 块红。

### 10.4 这一批的不跟随清单

| # | 分岔 | hutool 实测 | 本包 | 理由 |
|---|---|---|---|---|
| 1 | `Double` 入口 | 同一数两种答案（1.105 ⇒ 一点一一 / 一点一零五） | 只收原文串 | 10.1a |
| 2 | 反向「负」前缀 | `Unknown unit '负' at: 0`（4 条实测） | 认，取负 | 正向会产出「负」，反向认不了 ⇒ 往返不通 |
| 3 | 反向累加位宽 | 「一千亿」⇒ 1215752192、「九十九万…」⇒ -826389968 | 真值（Int64 累加，带溢出防线；可达性见 10.3 第 5 条） | 低位截断不是语义 |
| 4 | 金额反向「没有元键」 | `壹佰 ⇒ 0.00`、`壹亿 ⇒ 0.00`、`壹佰贰拾拾 ⇒ 0.00`（整段丢） | 按元段读：10000 分 / 1e10 分 / 12000 分 | 键缺失是输入不完整，不是值为零 |
| 5 | 英文缩写的小数点 | `123456789,01w`（de locale） | 固定 `.` | 参照实现随环境变，见 10.3 第 3 条 |
| 6 | 英文零分 | `ONE AND CENTS  ONLY`（两个空格） | `ONE ONLY` | 段拼接事故，两位空格没有消费方会要 |
| 7 | 英文负数 | 内部 `Integer.parseInt("-")` 抛 `NumberFormatException: For input string: "-"` | `OutOfRange "-1234"` | 把内部异常当契约不成立 |
| 8 | 空输入反向 | `"" ⇒ 0`、`"  " ⇒ 1`（它的 `CHINESE_NAME_VALUE` 第一项是值为 1 的空格单位） | `NotDecimal` | 哨兵行为；两个空格读出 1 尤其不可依赖 |
| 9 | 千分位界外 | 抛 `Number support only: (-999 ~ 999)！` | `OutOfRange "1000"`（只带原串） | 错误只带读数 |
| 10 | 多币种 `Currency.digit` 与「大写金额带币种」 | `Money` 支持任意币种小数位 | 不做，归第四批一起定 | 引币种就要引表，与本库"码表独立成数据件"的立场一致 |
| 11 | 正向的整数部分超 `Int64` | `BigDecimal.longValue()` 先取低 64 位再判界：实测 `2^64+5 ⇒ 五`、`2^64 ⇒ 零`（回绕落点决定读数是错是对） | 判界用**未截断**的整数幅值 ⇒ 一律 `OutOfRange` | 同一个库不能因为回绕而把 1.8×10^19 读成 5；10.1b 同一条规矩 |
| 12 | `format(BigDecimal, …)` 在 `\|x\| < 1` 的负小数上丢符号 | 实测 `-0.05 ⇒ 零点零五`、`-.5 ⇒ 零点五`（整数部分截成 0 就走了「零」那条早退） | 按原串保号：`负零点零五`；真零（`-0`、`-0.00`）仍不带「负」 | 正向产出「负」而输入是负数却不读，是同一族缺陷的两个面；10.4 第 2 行的往返判据在这里同样成立 |
| 13 | 原文串文法的宽窄 | 那两条腿都吃更多：`+1 ⇒ 一`、`1e5 ⇒ 一十万`、`007 ⇒ 七`、`1. ⇒ 一`、`.5 ⇒ 零点五` | 文法固定 `-? D+ ('.' D*)? \| -? '.' D+`：前导零与「1.」「.5」收，`+`、指数、空白、分组符一律 `NotDecimal` | 指数写法要把「e5」当有效数字流还是语法糖，两种读法在 hutool 里没区别；把文法写窄比让它吃下什么都强 |
| 14 | 英文 word 的整数上界 | `NUMBER_MORE` 只有 5 档，16 位起内部数组越界：`ArrayIndexOutOfBoundsException: Index 5 out of bounds for length 5` | 15 位起界外给 `OutOfRange`（`123456789012345` 仍是读数） | 同第 7 行：内部越界不是契约 |
| 15 | 英文缩写的量级尾数与平局档 | 先 `value / 10000.0` 再 `DecimalFormat("#.##")`。四条实测读数：`Int64::MAX ⇒ 922337203685477.6w`、`1005 ⇒ 1k`、`10050 ⇒ 1w`、`10150 ⇒ 1.01w`（机制不在这里解释——同一台 JDK 上 `#.##` 对 `2.675` 给 `2.67`、对 `1.015` 给 `1.01`，属 §9.1 那次对撞的同一族） | 与 #8.37 同一条腿：精确十进制 + `HalfUp` ⇒ 同输入 `922337203685477.58w` / `1.01k` / `1.01w` / `1.02w` | 一个库里对同一个数只许有一种答案；三条平局档断言就是这一行的判别夹具（把 `>=` 改窄当场有块红，读数见 §10.3 第 7 条） |

### 10.5 分批与状态

| 批 | 内容 | 状态 |
|---|---|---|
| 第三批（本节） | #8.26~#8.39，14 条公开项 + 3 条错误档，23 块冻结期望值 | **已交付**（10-05）：契约冻结 → 期望值复核一轮（两处自相矛盾/模型错改判、补 51 条实测断言、不跟随清单 10→15 行）→ 实现落地，67 块在 `wasm`/`js`/`wasm-gc` 三档逐档通过；十条变异对照逐条有块红（§10.3 第 7 条） |
| 第四批 | `Calculator` 表达式求值（#8.40，一件公开项 + 两档新错误） | **已交付**（10-07 两笔：契约 `c51a25d` + 落地笔）：PR-A 冻 17 块 198 条，落地笔补 4 条除法 tie 夹具成 **17 块 202 条**，全部由 `scripts/gen_num4_test.py` 从参照腿 `scripts/Num4Leg.java`（610 行读数）灌入、手打零条；终读数 `642 = 绿 642 / 红 0` 三档一致、已冻期望零改写（差分 `改=0 删=0 增=4`）、十八条变异 16 抓红 + 2 条按构造等价各给推导（§11.6）。结构决策在 §11.1，四段流水在 §11.2，改判五挂在 §11.4 |

第三批的 22 块与包内其余块一起进当场读数（见 `docs/ROADMAP.md` 的生成块）；
实现那一笔只许把红变绿，改任何期望串须单独一笔并给外部读数来源（门禁 G5）。

## 11. 第四批契约：`Calculator` 表达式求值（#8.40）

### 11.1 结构决策先落：十进制精确算术用什么形状

§10.5 挂的那句"动手前先定形状"，答案是**内部用「`BigInt` 尾数 + 非负 `scale`」的十进制定点**，
出口才是 `Double`：

| 选择 | 为什么不是它 |
|---|---|
| 完整 `BigDecimal` | 在 ROADMAP 的"不做"清单里（那是第二套数值类型，本库不建） |
| 有理数（`num/den`） | `div` 的结果会**不是**十进制有限小数，而参照的 `div` 是"定到 10 位、HALF_UP"——用有理数就得再叠一层"什么时候截"，等于把参照的形状藏进第二处 |
| 直接 `Double` 算 | 一步就错：腿 A `0.1+0.2` ⇒ `0.3`、`1.005*100` ⇒ `100.5`、`2.675*100` ⇒ `267.5`，而 `Double` 算给 `0.30000000000000004` / `100.49999999999999` / `267.49999999999994`。**这一批存在的全部理由就是这几条读数** |
| 定点 + `BigInt`（选它） | 加/减=对齐 `scale` 后尾数相加减；乘=尾数相乘、`scale` 相加；除=按参照默认档**恒** `scale=10` + `HALF_UP`；取余=商向零截断、余数符号跟被除数、`scale` 取 `max`——四条都对得上腿 C 行（20 对操作数 × 7 算子）。`BigInt` 已在本包用着（`lcm`/`factorial`），不引新依赖，也没有 `Int64` 尾数溢出这一档 |

除法那条不是猜的：腿 C 行把 `div` 的读数与"显式 `divide(x, 10, HALF_UP)`"逐条比**完全相同**，
与 `FLOOR` 档在 `1/7`、`1/6`、`-7/3`、`1/-3` 四条上不同 ⇒ 默认档＝`scale=10` + `HALF_UP` 定死。

### 11.2 公开面：一件（#8.40）

| # | 签名 | 关键读数 | 边界/错误 | hutool 对位 |
|---|---|---|---|---|
| 8.40 | `num_calculate(String) -> Double raise NumError` | 腿 D 行 99 + S 行 106（深度扫描 12 + 构造补齐 94）：**202 格**逐条读数，摘几条 `5+12*(3+5)/7`⇒`18.7142857143`、`0.1+0.2`⇒`0.3`、`2/3`⇒`0.6666666667`、`1/2048`⇒`4.882813E-4`（除法 tie 档，见 §11.6）、`(1+2)3`⇒`9`、`2+10%3`⇒`3`、`-7%3`⇒`-1`、`1e308*10`⇒`Infinity`、`1E2a`⇒`100` 对 `1e2a`⇒`1` | `BadExpression`、`NotDecimal`、`DivZero` | `Calculator.calculate(String)` 与 `static conversion(String)`——腿 V 行 99 条与 D 行**逐条同值**，所以两件收成一件（参照那侧 `conversion` 就是 `new Calculator().calculate(e)` 的一行壳） |

`+ - * / %` 五个算子、`( )` 括号、一元负号、`x`/`X` 当乘号、隐式乘法、空白与尾随 `=`——**全部跟随**，
不收紧也不修复。四段流水（源码级 + 读数级双证）：

1. **`transform`**：去掉**所有**空白（不是 trim）→ 剥一个尾随 `=` → 处在"串首或紧跟 `+ - * / ( E e`"的
   `-` 改成记号 `~` → `x`/`X` 就地换成 `*` → 串首是 `~` 且第二位是 `(` 时改回 `-` 并在前面补 `0`。
   读数面：`- 5`⇒`-5`（空白无所谓）、`2x3`⇒`6`、`0x10`⇒`0`（变成 `0*10`）、`--5`⇒ 参照报
   `Unparseable number: "-"`（第二个 `-` 前面是 `~`，不在那串字符里 ⇒ 记号不成立）。
2. **`prepare`**：shunting-yard 出后缀栈。优先级是 Java 那句 `operatPriority = {0,3,2,1,-1,1,0,2}`
   按 `ASCII-40` 下标摊开：`+`/`-` = 1、`*`/`/`/`%` = 2、`(` = 0、`)` = 3、栈底哨兵 `,` = -1，
   **`%` 靠"把字符换成 `/`"借到 2 这一档**（源码就改这一个字符）。左到右同优先级（`10-4-3`⇒`3`）。
3. **按推入序消费后缀**：Java 先 `Collections.reverse(栈)` 再一路 `pop()`——**两步相抵就是正向遍历**。
   这条写反过一次：镜像按"后缀式倒着算"写，腿与镜像只对上 117/277；改成正向后 263/277。
4. **余栈整体相乘**：栈里剩下几个数就是隐式乘法（`(1+2)3`⇒`9`、`(1+2)(3)`⇒`9`），
   所以"以算子结尾"与"括号失衡"在参照那侧不是报语法错，而是走到这里 pop 空 ⇒ 见 §11.4。

操作数解析是**最长可解析前缀**（Java `java.text.NumberFormat` 的宽松档，52 个 token × 3 档共 156 条 F 行
钉住解析器层，另在**计算器这一层**补 23 格 S 行——本库发的这件是 `num_calculate`，契约要钉在自己这件上）：
`1,000`⇒`1000`（逗号只在两侧都是数字时当分组符）、`1_000`⇒`1`、`1..2`⇒`1`、`1.2.3`⇒`1.2`、
`.5`⇒`0.5`、`5.`⇒`5`、`5f`⇒`5`、`5d`⇒`5`、`07`⇒`7`、`Infinity`⇒ `NumberFormatException`（带 token）。
**指数档大小写不对称**：大写 `E` 后面跟了垃圾也算数（`1E2a`⇒`100`、`1E2.5`⇒`100`、`1E2e3`⇒`100`），
小写 `e` 必须一路到串尾才算指数（`1e2a`⇒`1`、`1e2,3`⇒`1`、`1.5e3e-1`⇒`1.5`、
但 `12e3`⇒`12000`、`1e23`⇒`1e23`、`1e2 `⇒`100`——空白在第一步就全删了，尾部空格不影响）。
`0x1p3`⇒`0`（`x` 先当乘号，剩下的是 `0*1p3`＝`0*1`）。`NaN` 参照**认作数**再在算术层崩
（`IllegalArgumentException: Number is invalid!`，那句不带 token）——这一族的本库立场见 §11.4 第 19、20 行。
本库**不复刻解释、只复刻读数**——这条不对称是 JDK 内部实现，不是语义。

一条读数解释的坑先记在这，免得下一个人去"改错期望"：**Java 的 `Double.toString` 不总给最短表示**。
腿对 `1e23` 打的是 `9.999999999999999E22`，探针 `String.valueOf(1e23)` 现读同串；而这与十进制精确值
`1e23` 落进 `Double` 是**同一个双精度数**（`new BigDecimal(1e23)` ⇒ `99999999999999991611392`）。
生成器比的是两侧的 `Double` 而非字面串，所以这一格照常过自检、期望写成 `1.0e23`。

`^` **根本不是运算符**（`isOperator` 只列 `+ - * / ( ) %`，源码现读）：`1^2`⇒`1.0`、`2^-3`⇒`-1.0`
（`2^` 被当成一个数的前缀、`-3` 当减号）。ROADMAP 与旧台账里"含 `^` 幂运算"那句是**误记**，就地更正。

### 11.3 错误面新增两档

| 变体 | 载荷 | `raise` 点 | 参照对位 |
|---|---|---|---|
| `NumError.BadExpression(String)` | **整个原式** | 括号失衡、以算子结尾、空串、纯 `=`、后缀栈取空 | 参照在这族输入上随机抛四类：`EmptyStackException`（`(1+2`、`5%`、`+1`）、`IllegalStateException: Unexpected value: (`（`1+(2*3`）、`ArrayIndexOutOfBoundsException`（空串、`=`：`arr[0]` 越界）、`NumberFormatException` |
| `NumError.DivZero` | **不带载荷** | 除与取余的右操作数为 0 | `ArithmeticException: / by zero` 与 `Division by zero`、`Division undefined`（`0%0` 那档文案又是第三种）——三条都是"除数为零"这一件事，操作数调用方自己写的，"越界"才是新信息（`MoneyOverflow` 同一条立场） |

`NotDecimal(String)` 复用第一批那一档（载荷是那个**token 原文**，与参照 `Unparseable number: "abc"` 同形）。

### 11.4 分岔五行（本库改判，参照读数在案）

| # | 分岔 | 参照实测 | 本库 | 依据 |
|---|---|---|---|---|
| 16 | 形状坏了的式子 | 四类异常随机（§11.3 表末列），同一类坏法不同串还不一样 | 一律 `BadExpression(原式)`。**可判定含义**：参照抛的异常属于栈机类（`EmptyStackException` / `IllegalStateException` / `ArrayIndexOutOfBoundsException`），或那个"不是数"的 token 本身就是一对括号之一 | 把"崩成哪一类"当契约 = 把 JVM 栈机的实现细节写进本库错误面；这里没有"更深的第二档"可跟随（不同于 §5 那些行——那几行底下有 JDK 引擎的确定性读数，这族底下是 `Stack.pop` 的空栈异常） |
| 17 | **合法的**深层嵌套式：`1+(2+(3+(4+(5+(6+(7+8)))))))` 起（7 层） | `EmptyStackException`；同形状的 `1+(1+(…))` 十二层却正常给值 ⇒ 崩不崩与深度无关、与"每层操作数各不相同"有关（成因没读源码定论，也不需要） | 给算术值（此式 ⇒`36.0`） | 期望值来源＝同一套规则在其余 **263 格**上与参照逐条同读 + 一份独立镜像实现（Python `Fraction`）同值；不是手打，也不是本库自证 |
| 18 | 结果超出 `Double` 可表范围 | `1e308*10`⇒`Infinity`、`-1e308*10`⇒`-Infinity`、`1e300+1e300`⇒`2.0E300`（内部十进制是**精确**的，只有最后一步 `doubleValue()` 才落到 `Double` 的界上） | 跟随：内部定点不截断，出口按 IEEE 最近舍入，越界 ⇒ `±Infinity` | 腿 D 行三条；这条不是分岔，是"精确在哪一层"的正面证据——顺带定死"中途不许转 `Double`" |
| 19 | 操作数里出现**非 ASCII 十进制数字**（`١٢`） | `١٢`⇒`12.0`（腿 S 行现读；`NumberFormat` 的数字扫描走 `Character.digit(c,10)`，任何 Unicode 十进制数字都算数字） | **只认 ASCII `0-9`**：该位置判 `NotDecimal(token)` ⇒ `١٢` 这一格本库抛 | 复刻这一档要带一张 Unicode `Nd` 表（数百个码位、跨平面），而本库没有任何入口消费"阿拉伯-印度数字写成的表达式"；`Math` 包也没有现成的 `Character.digit` 可用。**期望不是照抄参照、也不是手打**：由生成器里那条"数字字符 ⇒ ASCII"规则推导，注记写明参照读数与本判决的出处（就是本行） |
| 20 | `NaN` 这一族（含 `NaN+1`） | 参照**认它是数**（`MathUtil.isNaN` 分支返回 `Double`），走到算术层才崩：`IllegalArgumentException: Number is invalid!`，那句**不带 token** | `NotDecimal("NaN")`：本库的数值域里没有 NaN，所以它落在"这个位置不是一个数"这一档 | 两档都抛、差别只在**阶段与类名**；参照那句给不出 token，所以载荷由本库的 token（那一段操作数）填。腿 S 行两条读数在案，注记里逐格写"token 来源＝求值器（参照那句不带 token）" |

### 11.5 用例与读数索引（第四批）

| 内容 | 位置 |
|---|---|
| 腿 | `scripts/Num4Leg.java` → 610 行 TSV：T 2（代次）+ D 99（表达式）+ V 99（静态入口对照）+ C 140（20 对操作数 × 7 算子）+ S 12（深度扫描 `depth_1..12`）+ S 94（构造补齐 `more`：23 格操作数前缀档在**计算器这一层**的读数 + 4 格除法 tie 档 + 其余形状档）+ F 156（52 个 token × 解析器三档对照）+ N 8（多操作数与 scale 细节） |
| 期望值 | `num/calc_test.mbt`：**17 块 202 条**，由 `scripts/gen_num4_test.py` 从腿 TSV 灌入。逐格注记的分布＝146 条值档照腿 + 13 条 `NotDecimal` 的 token 照腿那句 + 3 条 `DivZero` 照腿 + 33 条 §11.4 第 16 行（两档同判）+ 4 条第 17 行（参照崩而式子合法）+ 2 条第 20 行（参照那句不带 token）+ 1 条第 19 行（Unicode 数字分岔） |
| 独立求值器 | 随生成器进仓（`scripts/gen_num4_test.py` 内那份 `Fraction` 定点实现）。它**不产期望值**，只做自检：腿给数值的每一格都必须与它同值，不同值就 `SystemExit` 拒绝生成——上一轮那条"镜像只对上 117/277"（后缀倒着算）就是被这道判据抓出来的 |

### 11.6 落地记录（PR-B，10-07）

开局读数 `642 = 绿 625 / 红 17`（17 块是第四批设计态红）→ 实现落地后 `642 = 绿 642 / 红 0`，
`wasm`/`js`/`wasm-gc` 三档逐条一致、`moon check` 零警告、骨架豁免整行删除（G12）、
`.mbti` 只前进不后退。**198 条已冻期望一条没改**（差分 `改=0 删=0 增=4`，新增那 4 条见下面的 tie 档），
G5 按授权通道放行并留此读数。

四条实现层的坑，前两条是本笔自己先写错的（都被留着的期望当场抓回）：

| # | 坑 | 症状与定位 |
|---|---|---|
| 1 | **指数的数字不能进尾数** | 照 Python 那句 `Fraction(s[:end])` 直译时，`end` 在指数档会被推到指数末尾——`Fraction("1e3")` 自己会读指数，而本库是逐位收集数字，于是 `1e3` 收集成尾数 `13` × 10³ ⇒ 读数 `13000`。修法：先记下尾数段的右界 `mend`，收集只到 `mend`，指数单独走 `exp`。当时 6 格红（`1e3`/`1e2`/`1E2a`/`1e300+1e300`…） |
| 2 | **科学记法只摘得掉末尾的零** | 出口把 `m` 的十进制串写成 `d.dddde±NN` 时，第一版顺手跳过了首位之后的零（想的是 `1000`→`1e3`），把 `1005` 中间的两个零也跳了 ⇒ `1.005*100` 出 `150`、`1/11` 出 `0.099090909`。正确形状：`exp = 原始位数 - 1 - scale` 恒按**未摘零**的长度算，摘零只从串尾往前摘 |
| 3 | 本版 MoonBit 的四条 API 事实 | `Array::pop()` 出 `T?`（不是 `T`）⇒ 栈位取出统一过 `Some/None`；`s[i:j]` 出 `StringView` 而拼串要 `String`⇒ 内部一律走 `Array[Char]` + `chars_to_string`；`priv` 不能标 `fn`（只标类型/字段）；非 `mut` 绑定的数组照样 `push`/`pop`，写了 `let mut` 反被 `unused_mut` 判错 |
| 4 | 括号那一档要落在操作数解析口上 | `prepare` 的余栈会把落单的 `(` 当**操作数**交出来（参照同一条路径：`(1+2` 走到最后 `pop` 空栈才崩），所以合成 `BadExpression` 的判别必须写在 `calc_parse` 里而不是 `prepare` 里——写在 `prepare` 会漏掉整族"括号失衡但栈还没空"的式子 |

新增 4 条 tie 夹具的理由（这是上一批遗留的那类"档位没人看着"）：`1/3`⇒`0.3333333333`、
`2/3`⇒`0.6666666667` 这些读数的进位由**第 11 位的 6/9** 决定，把 `HalfUp` 换成 `HalfDown` 同判；
有限小数 `1/2^k` 才会把第 11 位正好落在 5 上。腿读数：`1/2048`⇒`4.882813E-4`、
`-1/2048`⇒`-4.882813E-4`、`3/2048`⇒`0.0014648438`（`1/32768`⇒`3.05176E-5` 是同族的非 tie 对照）。
补档后变异 K4（tie 不进位）从 0 红变 1 红（`calc 15`）。

十八条变异逐条读数（工装：本机临时件 `mutate_num4.py`，每条都先断言锚点唯一、写完 `fsync` 回读、
跑完还原并核对字节相同；基线先跑一次确认 0 红才进循环）：

| 变异 | 红块数 | 红在哪些块 |
|---|---|---|
| K1 后缀倒着消费 | 16 | 除 calc 16 外几乎全表（就是 §11.2 第 3 段那条历史跤） |
| K2 两个实参次序对调 | 11 | 1,2,3,4,6,8,9,11,12,14,15 |
| K3 除的 `scale` 10→8 | 3 | 1,2,15 |
| K4 tie 不进位（退成 HalfDown） | 1 | 15（补档前是 0 红） |
| K5 余数符号跟了除数 | 4 | 1,2,8,12 |
| K6 `%` 不借 `/` 的优先级 | 1 | 8 |
| K7 一元负号锚去掉 `e`/`E` | 3 | 3,8,13 |
| K8 `x`/`X` 不当乘号 | 3 | 4,14,17 |
| K9 空白只 trim 两端 | 2 | 3,6 |
| K10 不剥尾随 `=` | 1 | 6 |
| K11 隐式乘法退成"只留最后一个" | 1 | 5 |
| K12 指数大小写对称（小写 `e` 也容尾随垃圾） | 3 | 13,16,17 |
| K13 指数的数字混进尾数 | 6 | 2,3,8,13,16,17 |
| K14 出口不摘尾随零 | **0（按构造等价）** | 推导：出口的指数按**未摘零**的位数算，摘零只动小数部分的书写，两种写法表示同一个十进制数，而 `parse_double` 是最近舍入 ⇒ 落进 `Double` 是同一个值。这不是"没有夹具能分开"，是"分开不了任何输入" |
| K15 平格式不补前导零 | 2 | 8,15 |
| K16 括号档退回 `NotDecimal` | 1 | 5 |
| K17 加减对齐取了较小的 `scale` | 2 | 1,15 |
| K18 `prepare` 尾游标规则放宽成 `count > 0` | **0（按构造等价）** | 推导：不变式"`count > 0` 时游标 `cur` 指的那一格是本轮的第一个非算子字符"——算子分支一进现场就把 `count` 归零并把 `cur` 推到 `i+1`，所以 `arr[cur]` 永不可能是算子。于是原式 `count > 1 ∨ (count == 1 ∧ ¬(cur < len ∧ is_calc_op(arr[cur])))` 里那个 `cur < len ∧ is_calc_op(...)` 恒假，整条与 `count > 0` 等价。（参照写这一笔是为了它自己的 `substring` 边界，本库的 `chars_to_string` 已经按同一不变式取数） |


