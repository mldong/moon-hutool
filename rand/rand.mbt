///|
/// moon-hutool/rand —— 随机件（hutool `RandomUtil` 的 MoonBit 对位·第一批）
///
/// 契约：`docs/spec/12-rand.md`。期望值权威在 `rand_test.mbt`——改任何期望须单独一笔并给外部读数来源（门禁 G5）。
///
/// 五条贯穿性规则（spec §0，这五条决定了本包哪些函数存在、哪些不存在）：
/// 1. **随机源一律显式注入**。每一件都收 `@random.Rand`，库内部**一次都不取熵**——
///    与 `id` 包"时钟与熵全显式注入"同一条立场。要可复现就由调用方交一个脚本化 `Source`
///    （core 的 `Source` 是 `pub(open)` trait，实现它即可），要真随机就交 `Rand::new()`。
/// 2. **不承诺加密安全**。core 只给一条 chacha8 流，`Rand::new()` 在无熵的档会**静默回落固定种子**
///    （实测见 spec §4），所以"hutool 的 secure/pseudo 双通道"在本库判**不做**：
///    我们要能说的只有"熵由注入的生成器决定"，说不了"这个生成器是密码学安全的"。
/// 3. **界值语义按参照实现实测的四组合**，默认 `[min, max)`。空定义域是**错误**（`EmptyDomain`），
///    不是"返回某个值"——参照实现在这里透传底下引擎的 `IllegalArgumentException: bound must be positive`，
///    那句话既没说清"空域"也没说清是哪端点，本包不搬。
/// 4. **core 的 `limit=0` 那一档不透传**。实测 core `Rand::int(~limit=0)` 是"取 [0,2^31) 全域"而不是报错，
///    与"边界 0"这个输入含义完全不同 ⇒ 本包自己判域，绝不把界值原样递给 core。
/// 5. **字符串族只保证三件事**：长度、字符取自给定表、以及过滤档真的滤掉了。
///    具体出哪个字符由注入的生成器决定——契约里没有"第 N 次调用等于某个固定串"这种期望。

///|
/// 本包唯一错误面。每个变体对应**一个** `raise` 点，载荷只放调用方拿不到的读数
pub suberror RandError {
  /// 定义域为空（`min == max` 的半开/双开区间，或 `min > max`）。载荷 = 四个界值参数的读数
  EmptyDomain(String)
  /// 取元素的集合是空的。载荷 = 集合长度
  EmptyCollection(Int)
  /// 字符表是空的，没法从中取字符。载荷 = 表长
  EmptyAlphabet(Int)
  /// 要求取出的条数超过可用条数（去重档）。载荷 = `(要的条数, 实际可用条数)`
  BadCount(String)
}

///|
/// 数字表 `0123456789`。对位 `RandomUtil.BASE_NUMBER`（实测内容长度 10，逐字符照抄）
pub fn alphabet_number() -> String {
  abort("moon-hutool 契约未实现：alphabet_number")
}

///|
/// 小写字母表 `a`~`z`。对位 `RandomUtil.BASE_CHAR`（实测长度 26）
pub fn alphabet_lower() -> String {
  abort("moon-hutool 契约未实现：alphabet_lower")
}

///|
/// 小写 + 数字共 36 字符。对位 `RandomUtil.BASE_CHAR_NUMBER_LOWER`（实测长度 36）
pub fn alphabet_lower_number() -> String {
  abort("moon-hutool 契约未实现：alphabet_lower_number")
}

///|
/// 全表：大写段 + 小写段 + 数字段共 62 字符。对位 `RandomUtil.BASE_CHAR_NUMBER`
/// - Note: **顺序是大写在前**（实测原样），所以 `random_string_upper` 的结果集只有 36 个字符——表里本来就带数字
pub fn alphabet_all() -> String {
  abort("moon-hutool 契约未实现：alphabet_all")
}

///|
/// `[min, max)` 档的整数（默认两端含否按参照实现同名件：下界含、上界不含）。
/// 对位 `RandomUtil.randomInt(min, max)`。
/// - Parameters:
///   - `rng`：注入的随机源（规则 1）
///   - `min`/`max`：界值
///   - `incl_min`/`incl_max`：两端是否含进来，默认含下界、不含上界
/// - Raises: `RandError.EmptyDomain("min=..,max=..,incl_min=..,incl_max=..")`——定义域为空
pub fn random_int(
  rng : @random.Rand,
  min : Int,
  max : Int,
  incl_min? : Bool,
  incl_max? : Bool,
) -> Int raise RandError {
  abort("moon-hutool 契约未实现：random_int")
}

///|
/// `[0, n)` 档的整数。对位 `RandomUtil.randomInt(n)`（`n` 必须为正）。
/// - Raises: `RandError.EmptyDomain("n=0")` / `RandError.EmptyDomain("n=-1")`：非正没有定义域
pub fn random_int_under(rng : @random.Rand, n : Int) -> Int raise RandError {
  abort("moon-hutool 契约未实现：random_int_under")
}

///|
/// 掷硬币。对位 `RandomUtil.randomBoolean()`（参照实现是 `0 == randomInt(2)`，同一档）
pub fn random_boolean(rng : @random.Rand) -> Bool {
  abort("moon-hutool 契约未实现：random_boolean")
}

///|
/// 从表里取一个字符。对位 `RandomUtil.randomChar(sourceChar)`。
/// - Raises: `RandError.EmptyAlphabet(0)`：空表取不出字符（参照实现此处是底下引擎的报错，不搬）
pub fn random_char(
  rng : @random.Rand,
  table : String,
) -> String raise RandError {
  abort("moon-hutool 契约未实现：random_char")
}

///|
/// 取 `length` 个字符拼成串，字符取自 `table`。对位 `RandomUtil.randomString(sourceChar, length)`。
/// - Note: **`length = 0` 给空串**——参照实现实测给长度 1 的串（spec §5 第 1 行），这条不跟随
/// - Raises: `RandError.EmptyAlphabet(n)`：空表且 `length > 0`
pub fn random_string_from(
  rng : @random.Rand,
  table : String,
  length : Int,
) -> String raise RandError {
  abort("moon-hutool 契约未实现：random_string_from")
}

///|
/// 62 表（大写在前）取 `length` 个。对位 `RandomUtil.randomString(length)`
pub fn random_string(
  rng : @random.Rand,
  length : Int,
) -> String raise RandError {
  abort("moon-hutool 契约未实现：random_string")
}

///|
/// 26 位小写字母表取 `length` 个。对位 `RandomUtil.randomStringLower(length)`
pub fn random_string_lower(
  rng : @random.Rand,
  length : Int,
) -> String raise RandError {
  abort("moon-hutool 契约未实现：random_string_lower")
}

///|
/// 10 位数字表取 `length` 个。对位 `RandomUtil.randomNumbers(length)`
pub fn random_numbers(
  rng : @random.Rand,
  length : Int,
) -> String raise RandError {
  abort("moon-hutool 契约未实现：random_numbers")
}

///|
/// 62 表取 `length` 个再整体转大写。对位 `RandomUtil.randomStringUpper(length)`——
/// 实测结果集只有 36 个字符（数字 + 大写），因为表里本来就带数字
pub fn random_string_upper(
  rng : @random.Rand,
  length : Int,
) -> String raise RandError {
  abort("moon-hutool 契约未实现：random_string_upper")
}

///|
/// 62 表取 `length` 个，但**排除** `filter` 里出现的字符。对位 `RandomUtil.randomStringWithoutStr`。
/// - Note: 过滤按**字符集**算（不是子串），且大小写**分开算**：`"aA1"` 同时去掉 `a`、`A`、`1` 是参照实现
///   实测的行为（spec §3），本包同档；但"过滤后表为空还要求非空长度"给 `EmptyAlphabet`
pub fn random_string_without(
  rng : @random.Rand,
  length : Int,
  filter : String,
) -> String raise RandError {
  abort("moon-hutool 契约未实现：random_string_without")
}

///|
/// 从数组里取一个元素。对位 `RandomUtil.randomEle(list)`（默认全域），
/// `limit` 档对位 `randomEle(list, limit)`——**第二个参数是"只看前 N 个"，不是重试次数**
/// （实测：`limit=1` 恒返回第 0 个元素，spec §4 第 3 条）。
/// - Raises: `EmptyCollection(0)`：空数组；`EmptyCollection(limit 超界时按收敛后的长度)` 不会出现——
///   `limit > length` 由本包收敛（与参照实现同档）
pub fn[A] random_ele(
  rng : @random.Rand,
  items : Array[A],
  limit? : Int,
) -> A raise RandError {
  abort("moon-hutool 契约未实现：random_ele")
}

///|
/// 取 `count` 个元素，**允许重复**。对位 `RandomUtil.randomEles(list, count)`。
/// - Note: 实测参照实现可以返回 `count > size` 的条数且同一条目重复出现（spec §4 第 4 条），本包同档
/// - Raises: `EmptyCollection(0)`：空数组
pub fn[A] random_eles(
  rng : @random.Rand,
  items : Array[A],
  count : Int,
) -> Array[A] raise RandError {
  abort("moon-hutool 契约未实现：random_eles")
}

///|
/// 取 `count` 个**互不相同**的元素，顺序不保证。对位 `RandomUtil.randomEleSet(collection, count)`。
/// - Note: 需要元素可比对（`Eq + Hash`）——这条界**在实现那一笔补进签名**（骨架期没有体，界用不上会出
///   `unused_trait_bound` 警告，而 G3 是零警告门禁；签名带界与否以 `.mbti` 为准）
/// - Raises: `EmptyCollection(0)`；`BadCount("count=4,available=3")`：条数超过去重后的可用数
///   （参照实现这里也是 `IllegalArgumentException`，但它的消息没给可用数——本包把两个数都带上）
pub fn[A] random_ele_set(
  rng : @random.Rand,
  items : Array[A],
  count : Int,
) -> Array[A] raise RandError {
  abort("moon-hutool 契约未实现：random_ele_set")
}

///|
/// 权重表。对位 `cn.hutool.core.lang.WeightRandom`（`RandomUtil.weightRandom(...)` 造）
pub struct WeightRandom[A] {
  // 契约只承诺"项 + 权重"的语义与 next 的分布，存储形状是实现细节
  entries : Array[(A, Double)]
}

///|
/// 由 (项, 权重) 序列构造。对位 `RandomUtil.weightRandom(WeightObj[])`。
/// 实测参照实现**构造时不校验权重**（负权重、全零权重都能构造成功），本包同档但把"定义域为空"
/// 留到 `next` 时报——理由与判据见 spec §3 #12.15
pub fn[A] weight_random(items : Array[(A, Double)]) -> WeightRandom[A] {
  abort("moon-hutool 契约未实现：weight_random")
}

///|
/// 按权重取一项。对位 `WeightRandom.next()`——参照实现这里用静态随机源，本包必须显式注入（规则 1）。
/// - Note: 权重**不需要归一**：实测 0.1/0.2 两件的比例仍是 1:2（spec §4 第 6 条），零权重永不中选
/// - Raises: `RandError.EmptyCollection(0)`：表为空
pub fn[A] weight_random_next(
  table : WeightRandom[A],
  rng : @random.Rand,
) -> A raise RandError {
  abort("moon-hutool 契约未实现：weight_random_next")
}
