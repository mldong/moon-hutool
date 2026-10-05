// moon-hutool/conv —— hutool `Convert` 的无反射版
//
// 边界、规则出处与不跟随清单见 docs/spec/09-conv.md（本文件每条公开项都带一个 #9.x 编号，
// 与 spec §3 契约矩阵逐条对号）。此刻全部公开项都是 `abort`：契约已冻结、实现未开工。

///|
/// 一个「`Json` → `A`」的转换闭包。
///
/// hutool 用 `ConverterRegistry` 按运行时 `Type` 找 `Converter<T>`；MoonBit 没有运行时类型令牌，
/// 目标类型在**编译期**就定了（`to_int`/`to_int64`/… 各自一个函数名）。所以注册表改成
/// **一等闭包**：集合腿与映射腿收这个类型，用户想扩元素转换就传自己的闭包（理由见 spec §0.2）。
pub type JsonConv[A] = (Json) -> A?

///|
/// 转换面的错误。只有路径文法是「输入本身不合法」，其余公开项一律用 `Option` 表达失败
/// （hutool 的 `ConvertException` 面不跟随，理由见 spec §2）。
pub suberror ConvError {
  BadPath(String)
}

// ---- 标量腿：Json → 目标类型（#9.1~#9.7）----

///|
/// `Json` → `String`（#9.1，对位 `Convert.toStr`）。
///
/// - `Null` ⇒ `None`（hutool 的 null 入参走默认值通道，本包用 `Option` 表达）
/// - `String` ⇒ 原样，**不 trim、不转义**
/// - `Number` ⇒ 有 `repr` 用 `repr` 原文，否则用 `Double` 的字符串形态
/// - `True`/`False` ⇒ `"true"`/`"false"`
/// - `Array`/`Object` ⇒ JSON 文本（`stringify`，与 hutool 的 `Arrays.toString` 形状不同，见 spec §5）
pub fn to_str(j : Json) -> String? {
  abort("moon-hutool 契约未实现：to_str")
}

///|
/// `Json` → `Bool`（#9.2，对位 `Convert.toBool`）。
///
/// 只有 `Null`（以及字段缺失）才是 `None`；数字 0 ⇒ `Some(false)`、非 0 ⇒ `Some(true)`；
/// 字符串按 hutool `BooleanUtil.toBoolean` 的两态档走——**未命中 `TRUE_SET` 一律 `Some(false)`**，
/// 与三态的 `parse_bool`（#9.8）是两条不同的腿（spec §3 分岔表）。
pub fn to_bool(j : Json) -> Bool? {
  abort("moon-hutool 契约未实现：to_bool")
}

///|
/// `Json` → `Char`（#9.3，对位 `Convert.toChar`）。
///
/// 规则：取「字符串形态」的**第一个码点**，字符串形态**不 trim**；空白串 ⇒ `None`。
/// `Bool` 入参 ⇒ `None`（hutool 此处给 U+0001/U+0000 控制字符，本包判不跟随，见 spec §5）。
pub fn to_char(j : Json) -> Char? {
  abort("moon-hutool 契约未实现：to_char")
}

///|
/// `Json` → `Int`（#9.4，对位 `Convert.toInt`）。
///
/// `Number` 优先用 `repr` 走 #9.9 的宽松文法（大整数不丢精度），否则向零截断；
/// 非有限值、越出当前 `Int` 位宽 ⇒ `None`（**不跟随** Java 的低位回绕/saturate，读数证据见 spec §5）。
/// `True`/`False` ⇒ 1/0；`String` ⇒ #9.9；`Array`/`Object` ⇒ `None`。
pub fn to_int(j : Json) -> Int? {
  abort("moon-hutool 契约未实现：to_int")
}

///|
/// `Json` → `Int64`（#9.5，对位 `Convert.toLong`）。规则同 #9.4，界换成 `Int64`。
///
/// 这一条是 mldong-moon `jsonx.get_i64` 的收口位：雪花 id 在 JSON 里既可能是字符串也可能是数字，
/// 数字形态的 `repr` 不读就会撞精度（spec §0.3）。
pub fn to_int64(j : Json) -> Int64? {
  abort("moon-hutool 契约未实现：to_int64")
}

///|
/// `Json` → `Double`（#9.6，对位 `Convert.toDouble`）。
///
/// `Number` ⇒ 原值（含 `Infinity`——`1e309` 这类越界 JSON 数在 core 里就是 `Infinity`）；
/// `String` ⇒ #9.11；`True`/`False` ⇒ 1.0/0.0；`Array`/`Object` ⇒ `None`。
pub fn to_double(j : Json) -> Double? {
  abort("moon-hutool 契约未实现：to_double")
}

///|
/// `Json` → `BigInt`（#9.7，对位 `Convert.toBigInteger`）。
///
/// 只认**整数文法**：小数形态的 `Double` ⇒ `None`（hutool 同判，走 `new BigInteger(str)` 抛错），
/// 但字符串入参的空串 ⇒ `Some(0)`（hutool `NumberUtil.toBigInteger` 的 blank⇒ZERO 档，与 #9.4/#9.5
/// 的 blank⇒`None` 分岔，读数见 spec #9.7）。
pub fn to_big_int(j : Json) -> BigInt? {
  abort("moon-hutool 契约未实现：to_big_int")
}

// ---- 字符串入口的宽松解析腿（#9.8~#9.11，规则住在 NumberUtil.parseInt/parseLong/parseDouble）----

///|
/// `String` → `Bool?`，三态档（#9.8，对位 `BooleanUtil.toBooleanObject`）。
///
/// 命中 `TRUE_SET` ⇒ `Some(true)`、`FALSE_SET` ⇒ `Some(false)`，**其余（含空白）⇒ `None`**。
/// 大小写不敏感，比较前先 trim——这里的 trim 是 Java `String.trim()` 档（只吃 `<= U+0020`），
/// 与数值腿的 `@text.trim`（含 U+00A0）不同，两处不对称照抄 hutool 的调用点（spec §3）。
pub fn parse_bool(s : String) -> Bool? {
  abort("moon-hutool 契约未实现：parse_bool")
}

///|
/// `String` → `Int?`，hutool 宽松整数文法（#9.9，对位 `NumberUtil.parseInt`）。
///
/// 顺序：`@text.trim` ⇒ 末字符 `D/d/L/l/F/f` 去尾（会吃掉 hex 尾字母，实测读数）⇒
/// `0x/0X` 十六进制 ⇒ **含 `e/E` 直接判失败**（hutool 明确拒绝科学计数法）⇒
/// 严格十进制 ⇒ 小数形态向零截断 ⇒ 界校验。任何一步不成立 ⇒ `None`。
pub fn parse_int_loose(s : String) -> Int? {
  abort("moon-hutool 契约未实现：parse_int_loose")
}

///|
/// `String` → `Int64?`（#9.10，对位 `NumberUtil.parseLong`）。
///
/// 与 #9.9 同规则，但**不拒绝指数形态**（hutool 两条腿的不对称，实测 `1e5`⇒100000、`1.2e3`⇒1200，
/// 而 int 腿两者都失败）——这条不对称是冻结读数，不是笔误。
pub fn parse_int64_loose(s : String) -> Int64? {
  abort("moon-hutool 契约未实现：parse_int64_loose")
}

///|
/// `String` → `Double?`（#9.11，对位 `NumberUtil.parseDouble`）。
///
/// 十进制子集：可选符号 + 整数/小数 + 可选指数，交 `@string.parse_double` 求值。
/// **不跟随** Java 侧的十六进制浮点（`0x1p3`⇒8.0）、`NaN`/`Infinity` 字面量、
/// `1e309`⇒`Infinity` 与 locale 分组（`1,234.5`⇒1234.5），理由与实测读数见 spec §5。
pub fn parse_double_loose(s : String) -> Double? {
  abort("moon-hutool 契约未实现：parse_double_loose")
}

// ---- 取值腿（#9.12~#9.14：core 已把 `Json::value`/`as_*` 全线标 deprecated，见 spec §1）----

///|
/// 从 `Object` 取一个键（#9.12）。非 `Object` ⇒ `None`，键不存在 ⇒ `None`——
/// 取代 `Json::value(key)`（core 已标 `@deprecated`，推荐写法就是自己 `match`）。
pub fn field(j : Json, key : String) -> Json? {
  abort("moon-hutool 契约未实现：field")
}

///|
/// 点段 + 下标段的路径取值（#9.13，对位 `JSONUtil.getByPath`）。
///
/// 文法：`a.b[0].c`；`[+2]`/`[-1]` 合法（下标走 #9.9 的整数档，越界与非数字 ⇒ `BadPath`）。
/// 路径不命中 ⇒ `None`；路径本身写坏（空段、未闭合 `[`、`]` 无配对、下标非整数）⇒ `raise BadPath`。
pub fn get_by_path(j : Json, path : String) -> Json? raise ConvError {
  abort("moon-hutool 契约未实现：get_by_path")
}

///|
/// 取 `ids` 键的 `Int64` 数组（#9.14，对位 mldong-moon `jsonx.get_ids`——见 spec §0.4 口径）。
///
/// 键缺失、非数组、元素不可转成 `Int64` 都不报错：逐项走 #9.5，转不出的**跳过**。
/// 字符串与数字两种雪花 id 形态都收（数字形态优先读 `repr`，这是这条腿存在的理由）。
pub fn get_ids(j : Json) -> Array[Int64] {
  abort("moon-hutool 契约未实现：get_ids")
}

// ---- 组合腿（#9.15~#9.17）----

///|
/// 通用集合腿（#9.15，对位 `Convert.toArray/toList`）。
///
/// `Array` ⇒ 逐项过闭包；`String` ⇒ 先按逗号切分（hutool `ArrayConverter` 的「单纯字符串按逗号劈开」，
/// 空片段丢弃）再过闭包；其余形态 ⇒ 空数组。闭包返回 `None` 的元素**跳过**（不跟随 Java
/// 基本类型数组填 null / 对象数组保留 null 的两套形状，见 spec §5）。
pub fn[A] to_array(j : Json, conv : JsonConv[A]) -> Array[A] {
  abort("moon-hutool 契约未实现：to_array")
}

///|
/// 通用映射腿（#9.16，对位 `Convert.toMap(Class,Class,Object)`）。
///
/// `Object` ⇒ 键保持原字符串，值过闭包，`None` 的条目**不写入**；其余形态 ⇒ 空 `Map`。
/// 键类型不做转换（JSON 对象键只能是字符串，hutool 的 keyType 转换是为 Bean/Map 泛型服务的，无对位物）。
pub fn[A] to_map(j : Json, conv : JsonConv[A]) -> Map[String, A] {
  abort("moon-hutool 契约未实现：to_map")
}

///|
/// 组合两个闭包，前者优先、前者 `None` 才落后者（#9.17，对位 `ConverterRegistry` 的
/// `isCustomFirst=true`——自定义转换器先于内置转换器，2026-10-05 读 `convert/ConverterRegistry.java:262`）。
pub fn[A] chain(custom : JsonConv[A], base : JsonConv[A]) -> JsonConv[A] {
  abort("moon-hutool 契约未实现：chain")
}
