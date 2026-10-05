# 12 · `rand` —— 随机件（第一批）

> 状态：**契约已冻结**（10-05，实现未开工，本批 6 块是设计态红）。
> 对位 hutool `cn.hutool.core.util.RandomUtil`（实测 55 个 `public static`）+ `cn.hutool.core.lang.WeightRandom`；
> 公开接口在 `rand/pkg.generated.mbti`；冻结期望值在 `rand/rand_test.mbt`（6 块 43 条断言）。
> 文件名序号 12 ＝ 该包在 `docs/ROADMAP.md` 逐包表里的行号（稳定 ID，门禁 G13 守）。

## 0. 五条贯穿性规则

1. **随机源一律显式注入**。每一件都收 `@random.Rand`，库内部一次都不取熵——与 `id` 包"时钟与熵全显式注入"
   同一条立场。要可复现由调用方交一个脚本化 `Source`（core 的 `Source` 是 `pub(open)` trait，实现它就行），
   要真随机就交 `Rand::new()`。
2. **不承诺加密安全**。参照实现有 `getSecureRandom()`/`getSecureRandomStrong()`/`getSHA1PRNGRandom(seed)` 三条
   SecureRandom 通道，而 MoonBit 侧只有一条 chacha8 流；更要紧的是实测 `Rand::new()` 在拿不到平台熵的档会
   **静默回落到一个固定种子**（`core/random/random.mbt:52~58`，`id` 包三档实测已撞过）。
   ⇒ "secure/pseudo 双通道"判**不做**：本包能承诺的只有"熵由注入的生成器决定"。
3. **界值语义按实测的四组合**，默认 `[min, max)`。空定义域是错误（`EmptyDomain`），不是"返回某个值"，
   也不搬参照实现那句 `IllegalArgumentException: bound must be positive`（实测这条消息来自底下的
   `ThreadLocalRandom`，它既没说清"空域"也没说清是哪个端点）。
4. **core 的 `limit=0` 那一档不透传**。源码形状是"`limit==0` ⇒ 取 `[0, 2^31)` 全域"（不是报错），
   与"边界为 0"这个输入的含义完全不同 ⇒ 本包自己判域再取数。
5. **字符串族只保证三件事**：长度、字符取自给定表、过滤档真滤掉。出哪个字符由注入的生成器决定——
   契约里**没有**"第 N 次调用等于某个固定串"这种期望。

## 1. 为什么这一包的期望值形状与前面几包不同

参照实现**不可注入随机源**：55 个 `public static` 里没有一个收 `Random` 参数（实测 `javap`），
`randomString`/`randomEle` 全走 `getRandom()`（`ThreadLocalRandom`）或静态 `SecureRandom`。
所以"同一条夹具逐条比读数"这条路在这里走不通——结果序列本来就不可复现。

能量死的是四类，本包只钉这四类：

| 类别 | 怎么量 | 例子 |
|---|---|---|
| 常量表 | 反射读字段原样 | `BASE_CHAR_NUMBER` 是 62 字符且**大写在前** |
| **单点定义域** | 小范围大量抽样，读数只落在一个值上 | `(0,1)` 含下不含上 ⇒ 恒 `0`；`(0,2)` 双不含 ⇒ 恒 `1` |
| 异常档与空输入档 | 直接调用看抛不抛 | `min==max` 半开、空集合、空表 + 非零长度、`count >` 去重数 |
| 与流无关的不变量 | 任意流都成立 | 长度恰为 `count`、字符 ⊂ 表、去重档互不相同、零权重永不中选 |

**没钉的**：1 位生成（`random_boolean`）的取值——它没有任何"与流无关"的性质可钉，钉固定值就等于把 core 的
取数算法冻进本包契约。这一件的期望值在实现轮由脚本化 `Source` 补（见 §4 第 3 条的待复测清单）。

## 2. 错误面

`pub suberror RandError`，四个变体，每个对应**一个** `raise` 点，载荷只带调用方拿不到的读数：

| 变体 | 触发 | 载荷形状（实测/定稿） |
|---|---|---|
| `EmptyDomain(String)` | 定义域为空 | `min=1,max=1,incl_min=true,incl_max=false` / `n=0` / `n=-1` |
| `EmptyCollection(Int)` | 取元素的集合为空、或 `limit=0`、或加权表为空 | `0` |
| `EmptyAlphabet(Int)` | 字符表为空但要求非零长度 | `0` |
| `BadCount(String)` | 去重档要求的条数超过可用条数 | `count=4,available=3`（两个数都给，参照实现只给一句话） |

## 3. 逐件矩阵（#12.1~#12.19）

| # | 签名 | 读数与形状 | 对位 |
|---|---|---|---|
| 12.1 | `alphabet_number() -> String` | `"0123456789"`（`len=10`，实测） | `BASE_NUMBER` |
| 12.2 | `alphabet_lower() -> String` | `"abcdefghijklmnopqrstuvwxyz"`（`len=26`，实测） | `BASE_CHAR` |
| 12.3 | `alphabet_lower_number() -> String` | `"abcdefghijklmnopqrstuvwxyz0123456789"`（`len=36`，实测） | `BASE_CHAR_NUMBER_LOWER` |
| 12.4 | `alphabet_all() -> String` | 大写段 + 小写段 + 数字段（`len=62`，实测**大写在前**） | `BASE_CHAR_NUMBER` |
| 12.5 | `random_int(rng, min, max, incl_min? = true, incl_max? = false) -> Int raise` | 实测四组合：`(0,1)` 默认 ⇒ 恒 `0`；不含下含上 ⇒ 恒 `1`；双不含 `(0,2)` ⇒ 恒 `1`、`(0,1)` ⇒ 空域；双含 `(0,1)` ⇒ 值域恰 `{0,1}`；`min==max` 半开/`min>max` ⇒ `EmptyDomain`；`(0,0,true,true)` ⇒ 恒 `0` | `randomInt(min,max)` / `randomInt(min,max,inclMin,inclMax)` |
| 12.6 | `random_int_under(rng, n) -> Int raise` | `n=1` ⇒ 恒 `0`；`n=3` ⇒ 值域 `{0,1,2}`（实测 3000 次三个值都到齐且取不到 3）；`n<=0` ⇒ `EmptyDomain`（参照实现是 `IllegalArgumentException: bound must be positive`） | `randomInt(n)` |
| 12.7 | `random_boolean(rng) -> Bool` | 参照实现是 `0 == randomInt(2)`（源码），实测 4000 次 0/1 各约一半。**本批不钉期望值**（§1 末段） | `randomBoolean()` |
| 12.8 | `random_char(rng, table) -> String raise` | 实测取到的字符 ⊂ 表；空表 ⇒ 参照实现抛底层异常，本包 `EmptyAlphabet 0` | `randomChar(sourceChar)` |
| 12.9 | `random_string_from(rng, table, length) -> String raise` | **`length=0` 给空串**（§5 第 1 行）；字符 ⊂ 表；空表 + 非零长度 ⇒ `EmptyAlphabet`（实测参照实现此处给空串，§5 第 2 行） | `randomString(sourceChar, length)` |
| 12.10 | `random_string(rng, length) -> String raise` | 表 = `alphabet_all()`，实测 62 字符全可取到 | `randomString(length)` |
| 12.11 | `random_string_lower(rng, length) -> String raise` | 表 = `alphabet_lower()` | `randomStringLower(length)` |
| 12.12 | `random_numbers(rng, length) -> String raise` | 表 = `alphabet_number()` | `randomNumbers(length)` |
| 12.13 | `random_string_upper(rng, length) -> String raise` | 实测结果集是 **36 个字符**（大写 + 数字），不是 26——因为 62 表里本来就带数字，转大写后数字仍在 | `randomStringUpper(length)` |
| 12.14 | `random_string_without(rng, length, filter) -> String raise` | 实测过滤按**字符集**算且大小写分开算：`filter="aA1"` 后 `a`、`A`、`1` 都不出现（其余 59 字符仍全可取到） | `randomStringWithoutStr(length, chars)` |
| 12.15 | `random_ele[A](rng, items, limit?) -> A raise` | **第二参是"只看前 N 个"**（实测 `limit=1` 恒返回第 0 个），不是重试次数；`limit > size` 收敛到 `size`；空集合或 `limit=0` ⇒ `EmptyCollection 0` | `randomEle(list)` / `randomEle(list, limit)` |
| 12.16 | `random_eles[A](rng, items, count) -> Array[A] raise` | 实测**允许重复**且条数就是 `count`（`count=5 > size=3` 仍给 5 条）；空表 ⇒ `EmptyCollection 0` | `randomEles(list, count)` |
| 12.17 | `random_ele_set[A](rng, items, count) -> Array[A] raise` | 实测去重后再取（`[a,a,b,b,c]` 的可用数是 3）、`count=4` ⇒ 抛 `IllegalArgumentException: Count is larger than collection distinct size !`；本包给 `BadCount("count=4,available=3")`。返回顺序不保证（参照实现是 `LinkedHashSet`，实测按插入序） | `randomEleSet(collection, count)` |
| 12.18 | `weight_random[A](Array[(A, Double)]) -> WeightRandom[A]` | 实测构造**不校验**：负权重、空表都构造成功 ⇒ 本包同档（不校验），错误留到 `next` | `RandomUtil.weightRandom(WeightObj[])` |
| 12.19 | `weight_random_next[A](table, rng) -> A raise` | 权重**不需要归一**：实测 `0.1/0.2` 两件 3000 次比例仍是 1:2；`1/2/3` 三件 6000 次读数 `{a=1017, b=2015, c=2968}`；**零权重永不中选**（实测 1000 次全给另一件）；表为空 ⇒ `EmptyCollection 0` | `WeightRandom.next()`（参照实现用静态随机源，本包必须注入） |

## 4. 两条腿与本批统计

1. **腿 A · 参照实现**：真 `hutool-core-5.8.35.jar` + 本机 JDK 17.0.14 跑 `RandomUtil`/`WeightRandom`
   （驱动 `RandRef.java`，读数 `rand_ref.txt` 57 行）。四张表是反射读字段原样，界值是 3000 次抽样的
   **计数分布**（不是"跑一次记一个值"），异常档直接调用记录抛错类型与消息。
2. **腿 B · 运行时引擎**：core `@random` 的**源码形状**（`random.mbt:34~140`）：
   `Rand::chacha8(seed?)` 要求 seed 恰为 32 字节否则 `abort`；`Rand::new(generator?)` 在无参且平台取熵失败时
   回落到固定种子；`Rand::int(limit?)` 对 `limit<0` 走 `abort`、`limit==0` 是"全域 `[0,2^31)`"、
   `limit>0` 是 `[0,limit)`。**这几条本轮是源码读出的，不是探针读数** ⇒ 进 §3 第 3 条的待复测清单。
3. **待复测清单（实现轮必须补，不许拿源码形状当读数交付）**：
   ① `Rand::int(limit=0)` / 负 `limit` 在三档上的确切行为（报错形状与是否 panic）；
   ② 脚本化 `Source` 下 `int`/`boolean`/`double` 的消费轨迹（一次取数消耗几个 `UInt64`、是否拒绝采样），
   这决定 `random_boolean` 那类的固定期望怎么写；
   ③ 三档（wasm/js/wasm-gc）在同一脚本化 `Source` 下输出是否逐字节一致——本包唯一能承诺跨档一致的凭据。
   本轮已把探针（`vproj/cmd/main2`，脚本化 `Source` 实现 + 轨迹收集）写到编译通过前一步，
   因语法与预算未跑完，**没有读数可记**，所以本批一条机制性期望都没冻。
4. **两腿对撞的判据**：§3 里每条带"实测"字样的读数都出自 `rand_ref.txt`；`random_string_upper` 的 36 字符结果集、
   `randomEle(list, limit)` 的"前 N 个"语义、`randomEles` 的可重复与 `count>size`、`WeightRandom` 的归一化与
   零权重档，都是抽出来的**行为**，不是从源码读的。
5. **生成器与语料**：本批 43 条断言由 `RandRef.java` 的读数手工落成"与流无关"的形状（表内容、单点域、错误串、
   不变量），没有一条是"跑一次记下输出"。

## 5. 不跟随清单

| # | 分岔 | 腿 A 实测 | 本包 | 理由 |
|---|---|---|---|---|
| 1 | `randomString(length)` 的 `length=0` | 返回**长度 1** 的串（实测 `LEN!1`，即 `len=0` 时它仍拼出一个字符） | 返回空串 | 要求 0 个字符却拿到 1 个，是没有消费者的行为；这条改动的是参照实现自己 |
| 2 | 空表 + 非零长度 | 返回空串（实测 `LEN!0`，不抛） | `EmptyAlphabet(0)` | "从空集合里取 N 个"没有正确答案；给空串等于让调用方以为取到了 |
| 3 | `randomEle(list, limit)` 的第二参 | 是"只看前 N 个"（`limit=1` 恒返回第 0 个），不是重试次数 | 同名件 `limit`，语义照抄 | 参照实现的 javadoc 与实现一致；本包只是把命名改成 `limit` 不误读为 retry |
| 4 | 非正的 `n` / 空域 / 空表 / 超条数 | 全部透传底下引擎的 `IllegalArgumentException`，消息分别是 `bound must be positive`、`Count is larger than collection distinct size !` | 四条 `RandError` 变体，载荷带读数 | 把内部异常当契约不成立（与 `re` §5 第 4/5 行同一条判断） |
| 5 | secure/pseudo 双通道 | 有 `getSecureRandom()`/`getSecureRandomStrong()`/`getSHA1PRNGRandom(seed)` 三条 | 不做（§0.2） | MoonBit 侧只有一条 chacha8 流，且平台无熵时静默回落固定种子——承诺"安全"没有凭据 |
| 6 | `randomChinese()` | 从 CJK 区段取一个字符（实测 4000 次覆盖数千字） | 不做 | 要引码表；与本库"码表独立成数据件"的立场一致（同 `num` §10.4、`typex` 的区划码表判例） |
| 7 | `randomDay/randomDate` | 走 `DateUtil`/`DateTime`，读墙钟 | 不做，且列入待拍 | 本库时间一律显式传参（`03-date.md`），界值要进签名 |
| 8 | `randomFloat/randomDouble/randomBigDecimal` | 有 `scale` + `RoundingMode` 档 | 第二批 | `randomBigDecimal` 依赖完整十进制算术，与 `num` 的"完整 `BigDecimal` 不做"同一条立场要先解决 |
| 9 | `getRandom()/getRandom(isSecure)` | 把生成器本身当公开件 | 不做 | 本包的生成器是**入参**（§0.1），不需要供应件 |
| 10 | `randomBytes(length)` | 走 `ThreadLocalRandom.nextBytes`，`length=0` 给空数组 | 第二批（与 `Bytes` 的取数档一起定） | 与本包"只钉与流无关的东西"这一批不同，它要给 `Bytes` 类型的公开形状 |

## 6. 分批与状态

| 批 | 内容 | 状态 |
|---|---|---|
| 第一批（本节） | #12.1~#12.19，19 件公开项 + `RandError` 四档，6 块冻结期望值（43 条断言） | **契约已冻结**（10-05），实现未开工 |
| 第二批 | `random_long` / `random_float` / `random_double`（`scale` + 舍入档）、`random_bytes` | 未开工；`BigDecimal` 相关整档不做 |
| 待拍 | 加权件的分布要不要给"可核对的比例"这一档（现在只钉了零权重永不中选这条不变量） | 未定 |
| 待拍 | `random_boolean` 的固定期望（要脚本化 `Source`，见 §4 第 3 条） | 实现轮补 |

## 7. 索引与读数

| 内容 | 位置 |
|---|---|
| 期望值（冻结） | `rand/rand_test.mbt` 的 6 块；表内容与单点域取自 `rand_ref.txt` |
| 参照实现面 | `RandRef.java` 驱动 + `javap` 的 55 个 `public static` 清单（§0.2 与 §1 的依据） |
| core 能力面 | `moonbitlang/core/random/pkg.generated.mbti`（`Rand` 12 件 + `Source` trait）与 `random.mbt:34~140` |
| 状态句与读数 | `docs/ROADMAP.md` 的生成块（`scripts/sync_status.py --write`） |
| 门禁 | `scripts/contract_gate.sh` 的 G1~G13；本批落地前后 `BASELINE_TESTS` 的变动记在门禁头注 |
| 包内导航 | `README.md` 的包索引行、`rand/README.mbt.md`（实现轮补 doctest 档） |
