# 契约 09 · conv（`Convert` 的无反射版·第一批：`Json` 宽松转换 + 字符串解析腿 + 取值腿）

> 状态：**契约已冻结、实现未开工**（10-05）。17 条公开项 + 1 条类型别名 + 1 个错误变体，
> 见 `conv/pkg.generated.mbti`（`moon info` 后零漂移）；冻结期望值在 `conv/conv_test.mbt`
> （23 块）与 `conv/README.mbt.md`（10 块），此刻 33 块全红是设计态——`abort` 之前没有人写实现。
> 当场读数：`277 = 绿 244 / 红 33`，`wasm`/`js`/`wasm-gc` 三档一致。
> 实现那一笔只许把红变绿，改任何期望串须单独一笔并给外部读数来源（门禁 G5）。
>
> 这批只做**一条主线**：动态值树（`Json`）→ 静态类型，以及它反方向的取值腿。
> 全角/半角互转（`toSBC`/`toDBC`）与字节序族（`intToBytes`/`bytesToInt`/…）是 hutool
> `Convert` 的成员，但它们是**纯字符串/纯字节**的独立块，分界与理由见 §6。

## 0. 四条贯穿性规则

| # | 规则 | 为什么（当场实测或读源码得来，不是偏好） |
|---|---|---|
| 0.1 | **越界 ⇒ `None`**；`Int` 腿的界随目标变，所以冻结用例只喂 32 位内可判的夹具，"界"这条行为由 `Int64` 腿证 | `Int` 位宽随目标变（`wasm`/`js`/`wasm-gc` 32 位、`native` 64 位，本机 `moon run --target wasm` 实测 `@int.MAX_VALUE = 2147483647`）。而 hutool 走的是 Java 的**低位截断**：`"2147483648"` → `-2147483648`、`"-2147483649"` → `2147483647`、`"9007199254740993"` → `1`（本机 JDK 17 实跑，见 §5）。把回绕值当契约，等于把"跑在哪个目标/哪门语言"写进语义 |
| 0.2 | **目标类型在函数名里，扩展点在闭包里**；不带进程级可变注册表 | hutool 的 `Convert.convert(Class<T>, Object)` 把目标类型当**运行期的值**查表（`ConverterRegistry`），用户 `addConverter(Type, Converter)` 注册。MoonBit 没有运行时类型令牌，`Json` 也没有"任意 Java Object"那种源值。所以：`to_int`/`to_int64`/`to_double`… 各是一个编译期确定的函数；泛型元素转换收 `JsonConv[A] = (Json) -> A?`；组合用 `chain`（优先序对位 `ConverterRegistry.java:262` 的 `isCustomFirst=true`）。全局可变注册表在纯计算库里就是隐性输入——两笔调用的顺序会改变读数，这类东西本库一律不交付 |
| 0.3 | **凡 `Number` 带 `repr` 就优先读 `repr`** | core 的 `Json` 里 `Number(Double, repr~ : String?)`（`builtin/json.mbt:26/30`）。实测三档一致：`9007199254740993` ⇒ `d=9007199254740992 repr=9007199254740993`、`18446744073709551616` ⇒ 同理、`1e309` ⇒ `d=Infinity repr=1e309`；而 `1e5`/`1.0`/`0.1` 的 `repr` 是 `none`（Double 能回示就不留原文）。mldong-moon 的 `jsonx.get_i64` 当年直接 `n.to_int64()` 吃 `Double`——雪花 id 以数字形态进来就会撞精度（同款坑在 13 个栈上都踩过，前端侧叫「雪花 ID 全链字符串化」）。**这条是本包对 hutool 的增强，不是跟随**：hutool 的 JSON 数解析本来就给 `BigDecimal`，动机一致 |
| 0.4 | **只收取值腿，不收响应信封腿** | `Json` 树取值（按键取、按路径取、批量 id）是通用能力 ⇒ 收；`ok_data`/`ok_page`/`fail` 那套**是 mldong 框架各栈的错误码契约**，不是 hutool 能力 ⇒ 留在框架，不收进公共库，否则一个工具库背上私有语义。`ext`/`variable` 那类扩展属性往返（`get_ext_string`/`parse_ext`/`ext_json_opt`）同理——那是某框架的存储约定，本包不交付 |

## 1. 与 core 的边界（本包只做这张表右列的事）

扫描口径：`moon info` 的公开面 `moonbitlang/core/json/pkg.generated.mbti` **124 行**逐行读；
`pub` 声明按文件计数 `json.mbt` 16 · `types.mbt` 5 · `from_json.mbt` 22 · `to_json.mbt` 1 ·
`extends.mbt` 26 · `json_path.mbt` 4（`grep -c '^pub'` 当场数）。core 已有的一个都不重新包装：

| core 直接可用（不重造） | 依据 |
|---|---|
| `@json.parse` / `@json.to_json` / `from_json[T : FromJson]` / `ToJson` / `derive(ToJson)` / `derive(FromJson)` | `FromJson` 已覆盖 `Bool/Char/Int/Int64/UInt/UInt64/Float/Double/String/Option/Result/FixedArray/Bytes/Array/ArrayView/Json/Map[String,V]/元组 2~16/StringView`——**结构体 ↔ JSON** 这条路 core 已经修好，本包只做"值不知道是什么"的那一段 |
| `Json::stringify(escape_slash?, indent?, replacer?)`、`Json::transform(Replacer)`、`Replacer::keep/exclude` | 序列化形状控制归 core，本包不套第二层 |
| `@string.parse_int` / `parse_int64` / `parse_double` / `parse_bigint` | 严格文法的解析件；本包的宽松腿是**在它之上加 hutool 的规则**（`0x`、类型后缀去尾、全角归一、小数截断），不是替代 |
| `@text.trim` / `@text.is_blank` / `@text.split` | 上一包的公开面；`moon.pkg` 里跨包 import 有先例（`codec`→`digest`、`id`→`digest`） |
| `Double::trunc` / `Double::to_int64`、`Int64`/`BigInt` 本身 | 截断与精确域算术都在 core；本包只加界校验 |

扫描同时暴露的**缺口**（这才是要做的原因）：

1. `Json` 的取值方法 `as_null`/`as_bool`/`as_number`/`as_string`/`as_array`/`as_object`/`item`/`value`
   **8 条全部被 core 标了 `@deprecated`**（`json.mbt:17~80`），建议写法就是自己 `match` 变体。
   ⇒ 本包把"官方建议的那个 `match`"收成有名字、有测试的出口（`field`/`get_by_path`/`to_*`）。
2. `JsonPath`（`json_path.mbt`）**只是解码错误路径**——`add_key`/`add_index` 给解码器用，
   `Show` 出 JSON Pointer 串；**没有任何"按路径取值"的公开 API** ⇒ 路径腿得自己立（#9.13）。
3. `Json` 变体是**只读类型**：测试里写 `Number(1.0)` 直接报
   `Cannot create values of the read-only type: Number` ⇒ 夹具一律走 `@json.parse`/`@json.to_json`（§7）。
4. `Double::to_int` / `to_int64` 的 js/wasm 实现是 `%f64_to_i32_saturate` / `%f64_to_i64_saturate`
   （`builtin/double_to_int.mbt:43`、`builtin/double_to_int64_js_wasm.mbt:43`），native 档另写一份
   ⇒ **越界读数分档**，所以本包先自己做界校验、再调它，越界根本不让它算（同 0.1）。
5. `String` **没有** `to_lowercase`/`trim`/`split(Char)` 这类公开面（`string/*.mbt` 的
   `pub fn String::` 全表数下来只有 `all/any/char_length/compare_ignore_ascii_case/equal_ignore_ascii_case/`
   `iter/rev_iter/substring/suffixes/to_array/to_bytes/unsafe_substring/…`）⇒ 大小写折叠与切分只能自写或用 `@text`。

## 2. 错误面：只有一条 `raise`

| 变体 | 携带 | 谁 raise |
|---|---|---|
| `ConvError::BadPath(String)` | 原始路径串 | `get_by_path`（#9.13）——路径文法本身写坏：空段（`a..b`/`.a`/`a.`）、未闭合 `[`、多余 `]`、下标不是整数、空路径 |

**其余公开项一个 `raise` 都没有**，失败就是 `None`。这是本包与 hutool 最大的一处形状差：
hutool 有 `convert`（抛 `ConvertException`）、`convertQuietly`（吞异常回默认值）、
`toXxx(value)`（= `convert`，抛）与 `toXxx(value, defaultValue)`（= `convertQuietly`）四套入口，
根因是 Java 没有 `Option`。MoonBit 里这四套塌缩成一条 `T?`——要默认值自己 `unwrap_or`，
要"失败即报错"自己 `unwrap` 或 `try`。所以：

- `defaultValue` 形参**不跟随**（0.2 的同一逻辑）；
- `ConvertException` **不跟随**；`convertWithCheck` 的 `NumberFunc` 校验档**不跟随**——
  那是"传个函数进默认值通道"的 Java 补丁，在 MoonBit 就是一个 `let x = to_int(j) ?? ...`；
- `AbstractConverter.convert` 那句"目标类型未知时拿默认值的类型当目标类型"
  （`AbstractConverter.java:45~48`）**结构上不可能**，也就无需替代——目标类型永远是编译期事实。

按上一轮立的规矩检查过：**契约里没有永不红的分支**。`BadPath` 有 §3 的 12 条坏路径夹具打到，
不是摆设；反过来，任何"看起来该有但其实到不了"的档（比如 `Money` 那轮的 `MoneyOverflow`
挂在 `trim_trailing_zeros` 上）在这一批一条都没留。

## 3. 契约矩阵（17 条公开项）

hutool 侧扫描口径：`dromara/hutool` HEAD 的 `hutool-core/src/main/java/cn/hutool/core/convert/`
——`Convert.java` 里 `public static` **85 条**当场数（`grep -c`），包目录 12 个文件 +
`impl/` 35 个文件全列过一遍。下表"对位"给到方法名与源码行。

### 3.1 标量腿（`Json` → 目标类型）

| # | 签名 | hutool 对位 | 规则（一句话） | 用例块 |
|---|---|---|---|---|
| 9.1 | `to_str(Json) -> String?` | `Convert.toStr`（`Convert.java:36/48`）→ `StringConverter.convertInternal`（`impl/StringConverter.java:26`）→ `AbstractConverter.convertToStr`（`AbstractConverter.java:93`） | `Null`⇒`None`；`String` 原样不 trim；`Number` 有 `repr` 用原文否则 Double 最短十进制串；`Bool`⇒`"true"/"false"`；`Array`/`Object`⇒`stringify()` | 「to_str 的字符串形态」 |
| 9.2 | `to_bool(Json) -> Bool?` | `Convert.toBool`（`Convert.java:367/379`）→ `impl/BooleanConverter.java:22` | `Null`⇒`None`；数字只看 `0 != d`（`Infinity`/`NaN` 也算 `true`）；**字符串未命中 `TRUE_SET` 一律 `Some(false)`**（`BooleanUtil.toBoolean` 无第三态）；树按字符串形态同判 | 三个块：Null/Bool/Number、TRUE_SET 18 条、FALSE_SET 与未命中 |
| 9.3 | `to_char(Json) -> Char?` | `Convert.toChar`（`Convert.java:72/84`）→ `impl/CharacterConverter.java` | 取字符串形态的**首个码点**且**不 trim**；全空白⇒`None`；`Bool`⇒`None`（不跟随 `U+0001`，见 §5） | 「to_char 取首码点」+「Bool 档不跟随」 |
| 9.4 | `to_int(Json) -> Int?` | `Convert.toInt`（`Convert.java:227/239`）→ `impl/NumberConverter.java:136` | `Number` 优先 `repr` 走 #9.9，否则 Double 向零截断；非有限/越界⇒`None`；`Bool`⇒1/0；`String`⇒#9.9；树⇒`None` | 「to_int：Number 截断与字符串腿」 |
| 9.5 | `to_int64(Json) -> Int64?` | `Convert.toLong`（`Convert.java:262/274`）→ `NumberConverter.java:155` | 同 9.4，界换 `Int64`；**这条腿是 mldong-moon `jsonx.get_i64` 的收口位** | 「to_int64：repr 优先」+「越界一律 None」 |
| 9.6 | `to_double(Json) -> Double?` | `Convert.toDouble`（`Convert.java:297/309`）→ `NumberConverter.java:190` | `Number`⇒原值（含 `Infinity`——JSON `1e309` 在 core 里就是 `Infinity`，实测）；`String`⇒#9.11；`Bool`⇒1.0/0.0；树⇒`None` | 「to_double：原值、字符串腿与不跟随档」 |
| 9.7 | `to_big_int(Json) -> BigInt?` | `Convert.toBigInteger`（`Convert.java:402/414`）→ `NumberConverter.java:252` | 只认整数文法：`Double` 是小数⇒`None`（JDK 实测同判）；**字符串空/全空白⇒`Some(0)`**（`NumberUtil.toBigInteger` 的 blank⇒ZERO 档，与 9.4/9.5 的 blank⇒`None` 分岔，实测）；`repr` 路径无上界 | 「to_big_int：整数文法、小数 None、空串 0」 |

### 3.2 字符串入口的宽松解析腿

规则住在 hutool 的 `NumberUtil`（`parseInt` `:2652`、`parseLong` `:2690`、`parseDouble` `:2747`、
`parseNumber` `:2774`、`toBigDecimal` `:2284/2313`）与 `BooleanUtil`（集合 `:17/19`、
`toBoolean` `:82`、`toBooleanObject` `:100`）。共同的前段：

```
@text.trim（hutool StrUtil.trim 档，含 U+00A0） ⇒ 空 ⇒ None
末字符 ∈ {D,d,L,l,F,f} 且长度 > 1 ⇒ 去掉     ← NumberConverter.convertToStr:72~83
全角归一 Convert.toDBC（U+FF01~U+FF5E 减 65248，U+3000/00A0/2007/202F ⇒ 空格）
```

| # | 签名 | 规则 | 用例块 |
|---|---|---|---|
| 9.8 | `parse_bool(String) -> Bool?` | **三态**：`ascii_trim` ⇒ ASCII 小写 ⇒ 命中 `TRUE_SET`(18 条) ⇒ `Some(true)`、`FALSE_SET`(17 条) ⇒ `Some(false)`、其余（含空白）⇒ `None`。trim 用 **Java `String.trim()` 档**（只吃 `<= U+0020`）——与数值腿不同一处是 hutool 调用点本来就不同（`BooleanUtil.java:84/102` 用 `String.trim`，`NumberConverter.java:73` 用 `StrUtil.trim`），两处不对称照抄并各给夹具 | 「parse_bool 的三态与两处 trim 分岔」 |
| 9.9 | `parse_int_loose(String) -> Int?` | 前段 ⇒ `0x`/`0X` 十六进制（剩余须全为 hex 位，可带符号）⇒ **含 `e`/`E` 直接判失败**（hutool `Unsupported int format`）⇒ 严格十进制（可 `+`、可前导零）⇒ 小数形态向零截断 ⇒ `Int` 界校验。整串必须匹配文法：**不做尾随垃圾的前缀解析**（§5） | 「parse_int_loose：0x 与 D/L/F 去尾相互作用」 |
| 9.10 | `parse_int64_loose(String) -> Int64?` | 同 9.9 但**不拒绝指数**（`parseLong` 没有那段 E 检查，实测 `1e5`⇒100000、`1.2e3`⇒1200、`5e-3`⇒0）。这条不对称是 hutool 的事实，不是本包的选择——所以单独成块钉住 | 「parse_int64_loose 与 int 腿的指数不对称」 |
| 9.11 | `parse_double_loose(String) -> Double?` | 前段 ⇒ 只收「符号 + 整数/小数 + 可选指数」⇒ 交 `@string.parse_double`。十六进制浮点、`NaN`/`Infinity` 字面量、越界指数、分组分隔符、下划线全部 `None`（§5） | 「parse_double_loose 的十进制子集」 |

### 3.3 取值腿与组合腿

| # | 签名 | hutool 对位 | 规则 | 用例块 |
|---|---|---|---|---|
| 9.12 | `field(Json, String) -> Json?` | — （收的是 mldong-moon `core/jsonx.mbt:4~50` 那批手搓取值，见 0.4） | 只在 `Object` 上取；非对象/缺键 ⇒ `None`。取代 core 已 `@deprecated` 的 `Json::value` | 「field 只在 Object 上取值」 |
| 9.13 | `get_by_path(Json, String) -> Json? raise ConvError` | `JSONUtil.getByPath` / `BeanPath`（点段 + `[n]`） | 文法 `a.b[0].c`；下标段走 #9.10（所以 `[+2]` 合法、`[-1]` 文法合法但取不到 ⇒ `None`）；不命中 ⇒ `None`；路径本身坏 ⇒ `BadPath`（§2） | 三个块：命中 / 未命中 / 坏路径 raise |
| 9.14 | `get_ids(Json) -> Array[Int64]` | mldong-moon `core/jsonx.mbt:111` 的同名件（**非 hutool 对位**，0.4 定案收进来的取值腿） | `field(body,"ids")` ⇒ #9.15 + #9.5；键缺失、非数组、元素转不出都不报错 | 「get_ids：字符串与数字两形态」 |
| 9.15 | `to_array[A](Json, JsonConv[A]) -> Array[A]` | `Convert.toList(Class<T>, Object)`（`Convert.java:572`）/ `toArray` → `impl/ArrayConverter.java:122~139`（"单纯字符串按逗号劈开"就在这个方法里）/ `impl/CollectionConverter.java:74` | `Array` 逐项过闭包；`String` 先按逗号切分（丢弃空片段）再过闭包；其余形态 ⇒ 空数组。闭包给 `None` 的元素**跳过**——Java 那两套形状（对象数组填 `null`、基本类型数组 `Array.set(null)` 抛错）都不跟随 | 「to_array：数组逐项、字符串逗号切分、坏元素跳过」 |
| 9.16 | `to_map[A](Json, JsonConv[A]) -> Map[String, A]` | `Convert.toMap(Class<K>,Class<V>,Object)`（`Convert.java:602`）→ `impl/MapConverter.java:53` | `Object` ⇒ 键原样保留（core 的 `Map` 本身就是插入序，同 `mapx` 那轮的结论），值过闭包，`None` 的条目**整条不写**；其余形态 ⇒ 空 `Map`。键类型不做转换：JSON 对象键只能是字符串，hutool 的 `keyType` 是给 Bean/泛型 Map 用的，无对位物 | 「to_map：Object 逐项、坏值整条不写入」 |
| 9.17 | `chain[A](JsonConv[A], JsonConv[A]) -> JsonConv[A]` | `ConverterRegistry.convert(type, value, defaultValue)` ⇒ `convert(..., isCustomFirst=true)`（`ConverterRegistry.java:262/185`） | 前者优先，前者 `None` 才落后者。0.2 那条"注册表换成闭包"的落点就在这里 | 「chain：自定义闭包优先」 |

### 3.4 类型别名与错误

| # | 声明 | 说明 |
|---|---|---|
| 9.18 | `pub type JsonConv[A] = (Json) -> A?` | 透明别名（编译器裁决见 §7：`type alias` 那个写法里 `alias` 是保留字，透明别名就写 `pub type 名[参数] = 类型`） |
| 9.19 | `pub suberror ConvError { BadPath(String) }` | §2 那条唯一 raise 面 |

## 4. 读数腿（每条期望值都有来源，不是当场编的）

1. **JDK 参考腿**：`convert`/`util` 侧规则的字面转写跑在本机 **JDK 17.0.14**（Java 才是 hutool 的运行时）。
   转写清单 = `NumberUtil.parseInt/parseLong/parseFloat/parseDouble/parseNumber/toBigDecimal/
   toBigInteger/toDouble`、`BooleanUtil` 两张集合 + `toBoolean/toBooleanObject/toChar`、
   `NumberConverter.convertToStr`（含 D/L/F 去尾）与 `convert` 的各目标分支、
   `BooleanConverter/CharacterConverter/StringConverter.convertInternal`、
   `AbstractConverter.convert/convertToStr`、`Convert.toDBC`。48 条字符串夹具 × 3 腿 + 48 条布尔夹具 × 2 腿
   + 37 条 `Json` 夹具 × 7 腿 = **一致 200 条**。
2. **同一条输入跑两个 locale**：`-Duser.language=de -Duser.country=DE` 与默认（zh_CN）对跑，
   **41 条读数不同**——`"123.56"` 一边 `123` 一边 `12356`、`".123"` 一边 `0` 一边 `123`、
   `"1,234.5"` 一边 `1234` 一边 `1`。这条不是"我们不喜欢 locale"，是**同一条输入在 hutool 自己的
   运行时上给两个答案**，这种读数冻结不了 ⇒ `NumberFormat.getInstance()` 那条分支整支不跟随（§5）。
3. **三档实测 core 面**：`Double::to_string` 16 条、`Json::stringify` 8 条、`Number` 变体的
   `repr` 命中情况 11 条、`@string.parse_int/parse_int64/parse_double` 接受面 24 条，
   `wasm`/`js`/`wasm-gc` **逐值一致**（本机 `moon run` 现跑，不是推断）。
   这批读数是 `to_str`/`to_char`/`to_double` 期望值的直接来源——尤其 `-0.0` 的字符串形态是 `"0"`、
   `1e5` 的是 `"100000"` 而非原文、`1e309` 的 `d=Infinity repr=1e309`。
4. **分岔表自证**：声明"不跟随"的每一条，脚本都断言两边读数**确实不同**；相同就报"水分"。
   这条真抓到东西——`int` 腿的 `"Infinity"` 两边都是 `None`，被脚本判水分后从表里删掉了。
   反向也一样：不同而没声明 ⇒ 直接 assert 失败。**实测分岔 31 条**（`int` 10 / `int64` 9 / `double` 12），逐条见 §5。
5. **错误形状与合法/非法判定也要有腿**（上一轮立的规矩）：`BadPath` 携带**原始路径串**，12 条坏路径
   逐条断言形状；三态 `parse_bool` 与两态 `to_bool` 的分工各有一块，避免"错误面没人打就当摆设"。
6. **不可达的错误档从契约里删**：本批没有。`to_int`/`to_int64`/`to_double` 里"非有限 ⇒ `None`"
   这一支看着像死格，其实可达——`@json.parse("1e309")` 给的 `Double` 就是 `Infinity`（实测），
   所以它进的是 #9.6 的正值而不是 `None`；`"Infinity"` 字符串则走 #9.11 的 `None`。两条都有夹具。
7. **优先序腿**：`isCustomFirst=true` 是 `ConverterRegistry.java:262` 那行的事实，`chain` 的语义照它定。
8. **变异对照**：留到实现轮，按 `AGENTS.md` 的规矩——先 `assert` 变异真打上，再跑，看红；
   契约期没有实现体可变异，所以这一条在这里只挂判据、不给读数。

## 5. 不跟随 hutool 的清单（31 条实测分岔 + 结构级取舍）

### 5.1 实测分岔（左边 JDK 17 跑出来的，右边是本包契约）

| 腿 | 输入 | hutool（实测） | 本包 | 理由 |
|---|---|---|---|---|
| int | `"2147483648"` | `-2147483648` | `None` | Java `intValue()` 取低 32 位；0.1 |
| int | `"-2147483649"` | `2147483647` | `None` | 同上 |
| int | `"9007199254740993"` | `1` | `None` | 同上 |
| int | `"9223372036854775808"` | `0` | `None` | 同上 |
| int64 | `"9223372036854775808"` | `-9223372036854775808` | `None` | 同上，64 位档 |
| int / int64 / double | `"1,234.5"` | `1234` / `1234` / `1234.5`（zh_CN）；de_DE 给 `1` / `1` / `1.234` | `None` | 分组分隔符随 locale 变（§4 第 2 条） |
| int / int64 / double | `"1.234,5"` | `1` / `1` / `1.234`（zh_CN）；de_DE 反过来 `1234` / `1234` / `1234.5` | `None` | 同上，互反的那一条 |
| int / int64 / double | `"123X"` | `123` | `None` | `NumberFormat.parse` 的**前缀解析**语义；本包整串必须匹配文法 |
| int / int64 / double | `"123.456.789"` | `123` / `123` / `123.456` | `None` | 同上（第二个小数点之后的都被吃掉） |
| int / int64 / double | `"1_000"` | `1` / `1` / `1.0` | `None` | 同上 |
| int | `"NaN"` | `0` | `None` | 同上——`NaN` 根本不是十进制文法 |
| int64 | `"1e309"` | `0` | `None` | 越界指数的 `longValue()` 回绕 |
| int64 / double | `"1e"` | `1` / `1.0` | `None` | `DecimalFormat` 把空指数当 0；畸形指数不收 |
| double | `"NaN"` / `"Infinity"` | `NaN` / `Infinity` | `None` | `Double.parseDouble` 认这两个字面量，core 的 `parse_double` 不认（实测三档） |
| double | `"1e309"` | `Infinity` | `None` | core `parse_double` 对越界指数**报错**（实测），本包同判 |
| double | `"0x1p3"` | `8.0` | `None` | Java 十六进制浮点；core 不认 |
| double | `"0x1F"` / `"0Xff"` | `1.0` / `15.0` | `None` | 这是"去尾发生在 hex 判定之前"的连带后果（见 5.2 的 15），本包 double 腿不认十六进制 |

### 5.2 结构性不跟随（形状对不上，不是数值分歧）

| hutool 的东西 | 为什么不做 |
|---|---|
| `convert`/`convertWithCheck` 的 `ConvertException` 抛出档 | §2：Java 无 `Option` 的补偿；MoonBit 一个 `T?` 就够，要抛自己 `unwrap` |
| 每个 `toXxx(value, defaultValue)` 的默认值形参 | 同上，`unwrap_or` 是语言自带的 |
| `ConverterRegistry` 全局可变注册表 + `addConverter(Type, Converter)` | 0.2：目标类型是编译期事实，运行时没有 `Type` 令牌可当键；进程级可变状态会让两笔调用的顺序改变读数 |
| `AbstractConverter.convert` 里"目标类型未知时取默认值的类型" | 结构上不可能（同上） |
| `toChar(Boolean)` ⇒ `U+0001`/`U+0000` | `BooleanUtil.toChar` = `(char) toInt(bool)`（`:138`），交付的是控制字符。没有消费方需要它，本包对 `Bool` 入参判 `None` |
| `toStr(数组)` ⇒ `Arrays.toString` 的 `"[1, 2]"`（带空格） | 我们手里只有 JSON 树，取 `stringify` 的紧凑形状（实测三档）；要别的排版用 core 的 `indent` |
| `toArray` 元素转换失败：对象数组填 `null`、基本类型数组 `Array.set(null)` 抛 | Java 两套形状都来自"数组元素类型是运行时决定的"；本包统一**跳过**，与 mldong-moon `jsonx.get_i64_array` 现网语义一致 |
| `toMap(Class<K> keyType, …)` 的键类型转换 | JSON 对象键只能是字符串；`keyType` 是给 Bean/泛型 `Map` 服务的，无对位物 |
| `toDate` / `toCalendar` / `toLocalDateTime` / `toTemporalAccessor` / `toTimeZone` | 时间类型与格式串的解析在 `date` 包（ROADMAP 第 3 行，已交付）；本包不再开第二条时间入口 |
| `toEnum` / `toClass` / `toBean` / `toRecord` / `toURL` / `toURI` / `toCharset` / `toCurrency` / `toLocale` / `toDuration` / `toPeriod` / `Optional`/`Opt`/`Atomic*` 系列 | 反射、`java.*` 平台类型、JDK 容器类型——`AGENTS.md` 的"不做"清单同款；`derive(ToJson)/derive(FromJson)` 才是 MoonBit 的结构映射路 |
| `toSBC` / `toDBC` 作为**公开件** | 它们是对位件，但整串字符宽度映射是独立一块（要正反两向 + 边界码点表），且 `parseNumber` 内部已用 `toDBC` 归一。归 **§6 第二批**，不硬塞进这批 |
| `toHex` / `hexToBytes` / `hexToStr` / `strToUnicode` / `unicodeToStr` / `convertCharset` | 前四件归 `codec`（已交付，Base16/URL 编解码同族）与 `text`；`convertCharset` 需要非 UTF 码表 + FFI，在"不做"清单 |
| `convertTime(value, TimeUnit…, target)` | 单位换算与 `date` 的 `DateUnit` 同族，归 `date`/`typex`；本包不接收枚举型单位 |
| `intToByte` / `byteToUnsignedInt` / `bytesToShort` / `shortToBytes` / `bytesToInt` / `intToBytes` / `longToBytes` / `bytesToLong` | 字节序族（8 件）是 `Bytes` 域的独立一块，端序得先定契约。归 §6 第二批 |
| `wrap` / `unWrap`（`Class` 基本类型⇔包装类型） | 纯反射概念，MoonBit 无对应物 |
| `numberToChinese` / `chineseToNumber` / `digitToChinese` / `numberToWord` / `numberToSimple` / `chineseMoneyToNumber` | 中文/英文数字格式化在 `num` 包（ROADMAP 第 8 行，第三批已排期），`convert/` 只是它们物理上住的地方 |

## 6. 分批计划

| 批 | 内容 | 为什么切在这里 |
|---|---|---|
| 第一批（本批） | #9.1~#9.19：`Json` 标量腿 + 字符串宽松腿 + 取值腿 + 闭包组合 | 这是"动态树 → 静态类型"的主干，也是 `get_ids`/`get_by_path` 两条现网手搓的收口位；规则全在 `NumberUtil`/`BooleanUtil` 一处，镜像腿能一次做完 |
| 第二批 | `to_sbc` / `to_dbc`（正反两向 + 边界码点）+ 字节序族 8 件（`int_to_bytes`/`bytes_to_int`/…，端序显式传参） | 两块都是**纯 String / 纯 Bytes** 的独立件，与本批的 `Json` 主干没有共享读数；字节序族要先定端序契约（hutool 有 `ByteUtil.DEFAULT_ORDER`，本库不许有隐式默认） |
| 第三批 | `JsonConv` 的组合子库（`optional`/`array_of`/`map_of`/`one_of`）+ 结构映射薄档（`Json` → 用户手写的 `from_map`，配 `derive` 之外的动态形状） | 等第二批把 `Bytes`/字符宽度定完，再一次性定"组合子"的面；先散着开会让 `JsonConv[A]` 的形状反复动 |

按 ROADMAP 表序，`conv` 第二批排在 `re`/`valid`/`rand`/`mac` 之后（同表序推进，不抢跑）。

## 7. 编译器裁决（本轮实测，语法面一条都没猜）

| 观察 | 裁决 |
|---|---|
| `pub fn apply[A](conv : JsonConv[A], …)` | **报错**：`Parse error, unexpected fn f[T], you may expect fn[T] f`——泛型参数写在 `fn` 后面，不写在函数名后面：`pub fn[A] apply(...)` |
| `pub type alias JsonConv[A] = (Json) -> A?` | **报错**且伴随 `reserved_keyword` 警告（`alias` 是给未来保留的字）。透明别名就写 `pub type JsonConv[A] = (Json) -> A?`，别名可当参数类型、可隐式接闭包与函数值 |
| `var buf = ""` | **警告 deprecated_syntax**：`var x = e` 这种写法已废，改 `let mut x = e`（本仓此前一直用 `let mut`，这次是撞见官方弃用通知） |
| `fn (j) { … }` 作为闭包表达式且里面会 `raise` | **警告 deprecated_syntax**：会 raise 的匿名函数不标 raise 靠效应推断已废 ⇒ 写箭头形 `() => expr`，或显式标 `raise` |
| `Number(1.0)` 直接构造 `Json` 变体 | **报错**：`Cannot create values of the read-only type: Number` + `The labels repr~ are required` ⇒ 夹具一律 `@json.parse`/`@json.to_json`；模式匹配仍可用 `Number(d, repr~)`（core 自己就这么写，见 `json_path.mbt` 的 `Key(parent, key~)`） |
| `Double::inf(1)` | **警告 deprecated**：改用 `@double.infinity` / `@double.neg_infinity`（`pub let`，`double/pkg.generated.mbti:15/26`） |
| `String::to_lowercase()` / `String::trim()` / `String::split(Char)` | **不存在**（`Type String has no method to_lowercase`）⇒ 大小写折叠本包自写 ASCII 档，trim/切分用 `@text` |
| `@string.parse_int` 在 `raise ConvError` 的函数里直接 `match` | **报错**：`The error type is mismatched: wanted ConvError, has Error` ⇒ 先 `try` 折成 `Int?` 再进本包错误面 |
| `"""…"""` 三引号串 | **不支持**（本轮又一次撞到）⇒ 含引号的 JSON 夹具走转义串，由镜像脚本生成，不手写 |
| `Array::remove_at` / `/* */` 块注释 / `1l` 字面量后缀 | 仍是**不存在**（上一轮裁决，本轮沿用：前导零跳过用索引、注释一律 `//`、`Int64` 字面量靠类型标注 `Some((7 : Int64))`） |

## 8. 索引与读数

| 公开项 | 用例块（`conv_test.mbt`） | 文档块（`README.mbt.md`） | 此刻读数 |
|---|---|---|---|
| #9.1 `to_str` | to_str 的字符串形态 | to_str：Number 有 repr 就用原文 | 红（设计态） |
| #9.2 `to_bool` | Null/Bool/Number · TRUE_SET 全表 · FALSE_SET 与未命中 | to_bool 没有第三态 | 红 |
| #9.3 `to_char` | 取首码点 · Bool 档不跟随 | —（在文档块的表格里） | 红 |
| #9.4 `to_int` | Number 截断与字符串腿 | —（与 #9.9 同块） | 红 |
| #9.5 `to_int64` | repr 优先 · 越界一律 None | to_int64：大整数走 repr | 红 |
| #9.6 `to_double` | 原值、字符串腿与不跟随档 | — | 红 |
| #9.7 `to_big_int` | 整数文法、小数 None、空串 0 | — | 红 |
| #9.8 `parse_bool` | 三态与两处 trim 分岔 | parse_bool 才是三态 | 红 |
| #9.9 `parse_int_loose` | 0x 与 D/L/F 去尾 | 同左 | 红 |
| #9.10 `parse_int64_loose` | 与 int 腿的指数不对称 | 同左 | 红 |
| #9.11 `parse_double_loose` | 十进制子集 | — | 红 |
| #9.12 `field` | 只在 Object 上取值 | — | 红 |
| #9.13 `get_by_path` | 命中 · 未命中 · 坏路径 raise | get_by_path 点段与下标段 | 红 |
| #9.14 `get_ids` | ids 两形态 | 同左 | 红 |
| #9.15 `to_array` | 数组逐项、逗号切分、坏元素跳过 | 同左 | 红 |
| #9.16 `to_map` | Object 逐项、坏值不写入 | — | 红 |
| #9.17 `chain` | 自定义闭包优先 | 同左 | 红 |
| 合计 | 23 块 | 10 块 | **33 块全红**，与 §0~§5 的规则一一对得上 |

当场读数（`moon test --target wasm`，由 `scripts/sync_status.py` 生成，不手写）：**277 条 = 绿 244 / 红 33**，
`wasm`/`js`/`wasm-gc` 三档一致；native 档由 CI 编译出证（骨架期 `abort` 会打死 native 测试进程，
所以 native 计数走硬检查，见 `AGENTS.md`）。
