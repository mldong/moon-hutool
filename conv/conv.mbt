// moon-hutool/conv —— hutool `Convert` 的无反射版
//
// 边界、规则出处与不跟随清单见 docs/spec/09-conv.md（本文件每条公开项都带一个 #9.x 编号，
// 与 spec §3 契约矩阵逐条对号）。规则改一条，spec 与冻结期望值都要跟着改，别只改实现体。

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
  text_of(j)
}

///|
/// `Json` → `Bool`（#9.2，对位 `Convert.toBool`）。
///
/// 只有 `Null`（以及字段缺失）才是 `None`；数字 0 ⇒ `Some(false)`、非 0 ⇒ `Some(true)`；
/// 字符串按 hutool `BooleanUtil.toBoolean` 的两态档走——**未命中 `TRUE_SET` 一律 `Some(false)`**，
/// 与三态的 `parse_bool`（#9.8）是两条不同的腿（spec §3 分岔表）。
pub fn to_bool(j : Json) -> Bool? {
  match j {
    Null => None
    True => Some(true)
    False => Some(false)
    // hutool 就一句 `0 != doubleValue()`：±0.0 是 false，其余（含 Infinity、NaN）都是 true
    Number(d, ..) => Some(d != 0.0)
    String(s) => Some(two_state_bool(s))
    // 数组/对象：字符串形态查词表，未命中就是 false（与 hutool 同判）
    _ => Some(two_state_bool(j.stringify()))
  }
}

///|
/// `Json` → `Char`（#9.3，对位 `Convert.toChar`）。
///
/// 规则：取「字符串形态」的**第一个码点**，字符串形态**不 trim**；空白串 ⇒ `None`。
/// `Bool` 入参 ⇒ `None`（hutool 此处给 U+0001/U+0000 控制字符，本包判不跟随，见 spec §5）。
pub fn to_char(j : Json) -> Char? {
  match j {
    // Bool 判 None：hutool 给 U+0001/U+0000 控制字符，本包不交付（spec §5.2）
    Null | True | False => None
    _ =>
      match text_of(j) {
        Some(text) =>
          if @text.is_blank(text) {
            None
          } else {
            text.iter().next()
          }
        None => None
      }
  }
}

///|
/// `Json` → `Int`（#9.4，对位 `Convert.toInt`）。
///
/// `Number` 优先用 `repr` 走 #9.9 的宽松文法（大整数不丢精度），否则向零截断；
/// 非有限值、越出当前 `Int` 位宽 ⇒ `None`（**不跟随** Java 的低位回绕/saturate，读数证据见 spec §5）。
/// `True`/`False` ⇒ 1/0；`String` ⇒ #9.9；`Array`/`Object` ⇒ `None`。
pub fn to_int(j : Json) -> Int? {
  match j {
    Null | Array(_) | Object(_) => None
    True => Some(1)
    False => Some(0)
    Number(d, repr~) =>
      match repr {
        Some(r) => loose_int_text(r)
        None => trunc_to_int(d)
      }
    String(s) => loose_int_text(s)
  }
}

///|
/// `Json` → `Int64`（#9.5，对位 `Convert.toLong`）。规则同 #9.4，界换成 `Int64`。
///
/// 这一条是 mldong-moon `jsonx.get_i64` 的收口位：雪花 id 在 JSON 里既可能是字符串也可能是数字，
/// 数字形态的 `repr` 不读就会撞精度（spec §0.3）。
pub fn to_int64(j : Json) -> Int64? {
  match j {
    Null | Array(_) | Object(_) => None
    True => Some(1)
    False => Some(0)
    Number(d, repr~) =>
      match repr {
        Some(r) => loose_int64_text(r)
        None => trunc_to_int64(d)
      }
    String(s) => loose_int64_text(s)
  }
}

///|
/// `Json` → `Double`（#9.6，对位 `Convert.toDouble`）。
///
/// `Number` ⇒ 原值（含 `Infinity`——`1e309` 这类越界 JSON 数在 core 里就是 `Infinity`）；
/// `String` ⇒ #9.11；`True`/`False` ⇒ 1.0/0.0；`Array`/`Object` ⇒ `None`。
pub fn to_double(j : Json) -> Double? {
  match j {
    Null | Array(_) | Object(_) => None
    True => Some(1.0)
    False => Some(0.0)
    Number(d, ..) => Some(d)
    String(s) => loose_double_text(s)
  }
}

///|
/// `Json` → `BigInt`（#9.7，对位 `Convert.toBigInteger`）。
///
/// 只认**整数文法**：小数形态的 `Double` ⇒ `None`（hutool 同判，走 `new BigInteger(str)` 抛错），
/// 但字符串入参的空串 ⇒ `Some(0)`（hutool `NumberUtil.toBigInteger` 的 blank⇒ZERO 档，与 #9.4/#9.5
/// 的 blank⇒`None` 分岔，读数见 spec #9.7）。
pub fn to_big_int(j : Json) -> BigInt? {
  match j {
    Null | Array(_) | Object(_) => None
    True => Some(@bigint.BigInt::from_int(1))
    False => Some(@bigint.BigInt::from_int(0))
    Number(d, repr~) =>
      match repr {
        Some(r) => big_strict(r)
        None =>
          if d != d || d == @double.infinity || d == @double.neg_infinity {
            None
          } else {
            let t = d.trunc()
            // 无 repr 意味着 Double 能回示这个值，界内就精确
            if t != d ||
              t >= 9223372036854775808.0 ||
              t < -9223372036854775808.0 {
              None
            } else {
              Some(@bigint.BigInt::from_int64(t.to_int64()))
            }
          }
      }
    String(s) =>
      // hutool `NumberUtil.toBigInteger`：blank ⇒ ZERO，其余只认整数文法
      match loose_prepare(s) {
        None => Some(@bigint.BigInt::from_int(0))
        Some(t) => big_strict(t)
      }
  }
}

// ---- 字符串入口的宽松解析腿（#9.8~#9.11，规则住在 NumberUtil.parseInt/parseLong/parseDouble）----

///|
/// `String` → `Bool?`，三态档（#9.8，对位 `BooleanUtil.toBooleanObject`）。
///
/// 命中 `TRUE_SET` ⇒ `Some(true)`、`FALSE_SET` ⇒ `Some(false)`，**其余（含空白）⇒ `None`**。
/// 大小写不敏感，比较前先 trim——这里的 trim 是 Java `String.trim()` 档（只吃 `<= U+0020`），
/// 与数值腿的 `@text.trim`（含 U+00A0）不同，两处不对称照抄 hutool 的调用点（spec §3）。
pub fn parse_bool(s : String) -> Bool? {
  let t = ascii_trim(s)
  if @text.is_blank(t) {
    None
  } else {
    let k = ascii_lower(t)
    if true_words.contains(k) {
      Some(true)
    } else if false_words.contains(k) {
      Some(false)
    } else {
      None
    }
  }
}

///|
/// `String` → `Int?`，hutool 宽松整数文法（#9.9，对位 `NumberUtil.parseInt`）。
///
/// 顺序：`@text.trim` ⇒ 末字符 `D/d/L/l/F/f` 去尾（会吃掉 hex 尾字母，实测读数）⇒
/// `0x/0X` 十六进制 ⇒ **含 `e/E` 直接判失败**（hutool 明确拒绝科学计数法）⇒
/// 严格十进制 ⇒ 小数形态向零截断 ⇒ 界校验。任何一步不成立 ⇒ `None`。
pub fn parse_int_loose(s : String) -> Int? {
  loose_int_text(s)
}

///|
/// `String` → `Int64?`（#9.10，对位 `NumberUtil.parseLong`）。
///
/// 与 #9.9 同规则，但**不拒绝指数形态**（hutool 两条腿的不对称，实测 `1e5`⇒100000、`1.2e3`⇒1200，
/// 而 int 腿两者都失败）——这条不对称是冻结读数，不是笔误。
pub fn parse_int64_loose(s : String) -> Int64? {
  loose_int64_text(s)
}

///|
/// `String` → `Double?`（#9.11，对位 `NumberUtil.parseDouble`）。
///
/// 十进制子集：可选符号 + 整数/小数 + 可选指数，交 `@string.parse_double` 求值。
/// **不跟随** Java 侧的十六进制浮点（`0x1p3`⇒8.0）、`NaN`/`Infinity` 字面量、
/// `1e309`⇒`Infinity` 与 locale 分组（`1,234.5`⇒1234.5），理由与实测读数见 spec §5。
pub fn parse_double_loose(s : String) -> Double? {
  loose_double_text(s)
}

// ---- 取值腿（#9.12~#9.14：core 已把 `Json::value`/`as_*` 全线标 deprecated，见 spec §1）----

///|
/// 从 `Object` 取一个键（#9.12）。非 `Object` ⇒ `None`，键不存在 ⇒ `None`——
/// 取代 `Json::value(key)`（core 已标 `@deprecated`，推荐写法就是自己 `match`）。
pub fn field(j : Json, key : String) -> Json? {
  match j {
    Object(m) => m.get(key)
    _ => None
  }
}

///|
/// 点段 + 下标段的路径取值（#9.13，对位 `JSONUtil.getByPath`）。
///
/// 文法：`a.b[0].c`；`[+2]`/`[-1]` 合法（下标走 #9.9 的整数档，越界与非数字 ⇒ `BadPath`）。
/// 路径不命中 ⇒ `None`；路径本身写坏（空段、未闭合 `[`、`]` 无配对、下标非整数）⇒ `raise BadPath`。
pub fn get_by_path(j : Json, path : String) -> Json? raise ConvError {
  let mut cur = j
  for seg in parse_path(path).iter() {
    cur = match seg {
      Key(k) =>
        match cur {
          Object(m) =>
            match m.get(k) {
              Some(v) => v
              None => return None
            }
          _ => return None
        }
      Idx(i) =>
        match cur {
          Array(arr) =>
            if i >= 0 && i < arr.length().to_int64() {
              arr[i.to_int()]
            } else {
              return None
            }
          _ => return None
        }
    }
  }
  Some(cur)
}

///|
/// 取 `ids` 键的 `Int64` 数组（#9.14，对位 mldong-moon `jsonx.get_ids`——见 spec §0.4 口径）。
///
/// 键缺失、非数组、元素不可转成 `Int64` 都不报错：逐项走 #9.5，转不出的**跳过**。
/// 字符串与数字两种雪花 id 形态都收（数字形态优先读 `repr`，这是这条腿存在的理由）。
pub fn get_ids(j : Json) -> Array[Int64] {
  let items = match j {
    Object(m) =>
      match m.get("ids") {
        Some(v) => v
        None => Json::null()
      }
    _ => Json::null()
  }
  to_array(items, to_int64)
}

// ---- 组合腿（#9.15~#9.17）----

///|
/// 通用集合腿（#9.15，对位 `Convert.toArray/toList`）。
///
/// `Array` ⇒ 逐项过闭包；`String` ⇒ 先按逗号切分（hutool `ArrayConverter` 的「单纯字符串按逗号劈开」，
/// 空片段丢弃）再过闭包；其余形态 ⇒ 空数组。闭包返回 `None` 的元素**跳过**（不跟随 Java
/// 基本类型数组填 null / 对象数组保留 null 的两套形状，见 spec §5）。
pub fn[A] to_array(j : Json, conv : JsonConv[A]) -> Array[A] {
  let out : Array[A] = []
  match j {
    Array(items) =>
      for it in items {
        match conv(it) {
          Some(v) => out.push(v)
          None => ()
        }
      }
    String(s) =>
      // hutool `ArrayConverter.convertObjectToArray`（:139）：单纯字符串按逗号劈开，空段丢弃
      for part in @text.split(s, ',') {
        if !part.is_empty() {
          match conv(@json.to_json(part)) {
            Some(v) => out.push(v)
            None => ()
          }
        }
      }
    _ => ()
  }
  out
}

///|
/// 通用映射腿（#9.16，对位 `Convert.toMap(Class,Class,Object)`）。
///
/// `Object` ⇒ 键保持原字符串，值过闭包，`None` 的条目**不写入**；其余形态 ⇒ 空 `Map`。
/// 键类型不做转换（JSON 对象键只能是字符串，hutool 的 keyType 转换是为 Bean/Map 泛型服务的，无对位物）。
pub fn[A] to_map(j : Json, conv : JsonConv[A]) -> Map[String, A] {
  let out : Map[String, A] = Map([])
  match j {
    Object(m) =>
      for (k, v) in m {
        match conv(v) {
          Some(x) => out[k] = x
          None => ()
        }
      }
    _ => ()
  }
  out
}

///|
/// 组合两个闭包，前者优先、前者 `None` 才落后者（#9.17，对位 `ConverterRegistry` 的
/// `isCustomFirst=true`——自定义转换器先于内置转换器，2026-10-05 读 `convert/ConverterRegistry.java:262`）。
pub fn[A] chain(custom : JsonConv[A], base : JsonConv[A]) -> JsonConv[A] {
  fn(j : Json) -> A? {
    match custom(j) {
      Some(v) => Some(v)
      None => base(j)
    }
  }
}

///|
/// 只认「可选符号 + 全数字」的整数文法（hutool `NumberUtil.toBigInteger` 走 `new BigInteger(str)`，
/// 小数与指数都在这里失败 ⇒ `None`）。前导 '+' 自己剥，别赌 core 的 from_string 收不收。
fn big_strict(t : String) -> BigInt? {
  let cs = t.to_array()
  let n = cs.length()
  let neg = n > 0 && cs[0] == '-'
  let k = if n > 0 && (cs[0] == '-' || cs[0] == '+') { 1 } else { 0 }
  if k >= n {
    None
  } else {
    let mut ok = true
    for x in k..<n {
      if !is_digit(cs[x]) {
        ok = false
      }
    }
    if !ok {
      None
    } else {
      let digits = String::from_array(cs[k:n])
      // 上面的循环已经保证"全是数字"，core 的 from_string 不会拿到坏输入
      let v = @bigint.BigInt::from_string(digits)
      Some(if neg { v.neg() } else { v })
    }
  }
}

///|

///|
/// 宽松整数腿的共用体：**前段归一（trim + 去 D/L/F 尾 + 全角归一）在内部做**，
/// 所以 Json 的字符串档、路径下标段都可以直接喂原文（spec #9.9 的顺序就是这条）。
fn loose_int_text(s : String) -> Int? {
  let t = match loose_prepare(s) {
    Some(t) => t
    None => return None
  }
  match num_form(t, false) {
    None => None
    Some(Int) | Some(Hex) => Some(@string.parse_int(t)) catch { _ => None }
    Some(Dec) | Some(Exp) =>
      match parse_double_safe(t) {
        Some(d) => trunc_to_int(d)
        None => None
      }
  }
}

///|
fn loose_double_text(s : String) -> Double? {
  let t = match loose_prepare(s) {
    Some(t) => t
    None => return None
  }
  match num_form(t, true) {
    None => None
    Some(Int) | Some(Hex) =>
      match parse_double_safe(t) {
        Some(d) => Some(d)
        None =>
          // hex 档 core 的 parse_double 不收（实测 ERR），本包也不给
          None
      }
    Some(Dec) | Some(Exp) => parse_double_safe(t)
  }
}

///|
fn loose_int64_text(s : String) -> Int64? {
  let t = match loose_prepare(s) {
    Some(t) => t
    None => return None
  }
  match num_form(t, true) {
    None => None
    Some(Int) | Some(Hex) => Some(@string.parse_int64(t)) catch { _ => None }
    Some(Dec) | Some(Exp) =>
      match parse_double_safe(t) {
        Some(d) => trunc_to_int64(d)
        None => None
      }
  }
}

// ---- 私有件：规则表与文法自检（出处逐条写在 docs/spec/09-conv.md §3/§5）----

// `BooleanUtil.TRUE_SET`（`BooleanUtil.java:17`）——18 条，比较前先 ASCII 小写

///|
let true_words : Array[String] = [
  "true", "yes", "y", "t", "ok", "correct", "success", "on", "1", "是", "对", "真",
  "對", "正确", "开", "开启", "√", "☑",
]
// `BooleanUtil.FALSE_SET`（`:19`）——17 条

///|
let false_words : Array[String] = [
  "false", "no", "n", "f", "wrong", "fail", "off", "0", "否", "错", "假", "錯",
  "错误", "关", "关闭", "×", "☒",
]

///|
/// Java `String.trim()` 档：只吃码点 `<= U+0020`。
/// 布尔腿用它（`BooleanUtil.java:84` 调的就是 `String.trim`），数值腿用 `@text.trim`
/// （`NumberConverter.java:73` 调 `StrUtil.trim`）——两处不对称是 hutool 的既有事实。
fn ascii_trim(s : String) -> String {
  let cs = s.to_array()
  let n = cs.length()
  let mut i = 0
  let mut j = n
  while i < j && cs[i] <= ' ' {
    i += 1
  }
  while j > i && cs[j - 1] <= ' ' {
    j -= 1
  }
  String::from_array(cs[i:j])
}

///|
/// 只做 ASCII 的 A–Z → a–z。
/// 全量 Unicode 大小写映射在「不做」清单里；两张词表里没有受 dotted-I 影响的条目。
fn ascii_lower(s : String) -> String {
  let cs = s.to_array()
  for i in 0..<cs.length() {
    let c = cs[i]
    if c >= 'A' && c <= 'Z' {
      cs[i] = (c.to_int() + 32).unsafe_to_char()
    }
  }
  String::from_array(cs)
}

///|
/// `Convert.toDBC` 的字面转写：四个不间断空格 ⇒ 半角空格，`U+FF01..U+FF5E` ⇒ 减 65248。
fn to_dbc(s : String) -> String {
  let cs = s.to_array()
  for i in 0..<cs.length() {
    let c = cs[i]
    if c == '　' || c == '\u{00A0}' || c == '\u{2007}' || c == '\u{202F}' {
      cs[i] = ' '
    } else if c > '\u{FF00}' && c < '\u{FF5F}' {
      cs[i] = (c.to_int() - 65248).unsafe_to_char()
    }
  }
  String::from_array(cs)
}

///|
/// `NumberConverter.convertToStr`（`:72~83`）：trim ⇒ 末字符是 D/L/F（不分大小写）且长度 > 1 就去掉。
/// 去尾发生在 hex 判定**之前**，所以 "0x1F" 会变成 "0x1"——这是冻结读数不是笔误。
fn normalize_numeric(s : String) -> String? {
  let t = @text.trim(s)
  if @text.is_blank(t) {
    None
  } else {
    let cs = t.to_array()
    let n = cs.length()
    if n > 1 {
      let last = cs[n - 1]
      if last == 'd' ||
        last == 'D' ||
        last == 'l' ||
        last == 'L' ||
        last == 'f' ||
        last == 'F' {
        Some(String::from_array(cs[:n - 1]))
      } else {
        Some(t)
      }
    } else {
      Some(t)
    }
  }
}

///|
/// 文法档：本包自己扫一遍，**不让 core 的宽松面替我们做决定**
/// （实测 core `parse_int` 还收 `1_000` 下划线、`parse_double` 还收 `NaN`/`Infinity`，
/// 这些都不在 hutool 的十进制文法里，见 spec §4 第 9 条腿）。
priv enum NumForm {
  Hex
  Int
  Dec
  Exp
}

///|
fn is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
fn is_hex_digit(c : Char) -> Bool {
  is_digit(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
}

///|
/// 返回这段文本属于哪个文法档；不合法 ⇒ `None`。
/// `allow_exp` 区分两条腿：int 腿拒绝指数（hutool `parseInt` 明确抛 `Unsupported int format`），
/// int64/double 腿收指数（`parseLong`/`parseDouble` 没有那段检查）。
fn num_form(t : String, allow_exp : Bool) -> NumForm? {
  let cs = t.to_array()
  let n = cs.length()
  let mut i = 0
  if n == 0 {
    None
  } else if cs[0] == '0' && n > 1 && (cs[1] == 'x' || cs[1] == 'X') {
    // 0x 十六进制：可带符号，剩余必须全是 hex 位
    let mut k = 2
    if k < n && (cs[k] == '+' || cs[k] == '-') {
      k += 1
    }
    if k >= n {
      None
    } else {
      let mut ok = true
      while k < n {
        if !is_hex_digit(cs[k]) {
          ok = false
        }
        k += 1
      }
      if ok {
        Some(Hex)
      } else {
        None
      }
    }
  } else {
    if i < n && (cs[i] == '+' || cs[i] == '-') {
      i += 1
    }
    let mut digits_before = 0
    while i < n && is_digit(cs[i]) {
      digits_before += 1
      i += 1
    }
    let mut has_frac = false
    let mut digits_after = 0
    if i < n && cs[i] == '.' {
      has_frac = true
      i += 1
      while i < n && is_digit(cs[i]) {
        digits_after += 1
        i += 1
      }
    }
    if digits_before == 0 && digits_after == 0 {
      None
    } else if i >= n {
      Some(if has_frac { Dec } else { Int })
    } else {
      let e = cs[i]
      if !allow_exp || (e != 'e' && e != 'E') {
        None
      } else {
        let mut k = i + 1
        if k < n && (cs[k] == '+' || cs[k] == '-') {
          k += 1
        }
        let mut exp_digits = 0
        while k < n && is_digit(cs[k]) {
          exp_digits += 1
          k += 1
        }
        if exp_digits == 0 || k < n {
          None
        } else {
          Some(Exp)
        }
      }
    }
  }
}

///|
/// 小数/指数档 ⇒ `Double` 求值后**向零截断**（hutool 走 `BigDecimal/Number.intValue()`，同判），
/// 再做本档界校验：非有限值、越出 `Int` 位宽 ⇒ `None`（不跟随 Java 的低位回绕与 saturate）。
fn trunc_to_int(d : Double) -> Int? {
  if d != d {
    None
  } else {
    let t = d.trunc()
    if t > Double::from_int(@int.MAX_VALUE) ||
      t < Double::from_int(@int.MIN_VALUE) {
      None
    } else {
      Some(t.to_int())
    }
  }
}

///|
fn trunc_to_int64(d : Double) -> Int64? {
  if d != d {
    None
  } else {
    let t = d.trunc()
    // Int64::MAX 的最近 Double 是 2^63，用它当上界哨兵；`to_int64` 只在界内被调用，
    // 而界内的 saturate 与截断同值，所以这条不随目标变
    if t >= 9223372036854775808.0 || t < -9223372036854775808.0 {
      None
    } else {
      Some(t.to_int64())
    }
  }
}

///|
fn parse_double_safe(t : String) -> Double? {
  Some(@string.parse_double(t)) catch {
    _ => None
  }
}

///|
/// 宽松整数腿的共同实现：前段归一（trim + 去 D/L/F 尾 + 全角归一）⇒ 文法分档 ⇒ 求值 ⇒ 界校验。
/// `#selected` 里 `to_int`/`to_int64` 各接自己的求值与界（见 #9.9 / #9.10）。
fn loose_prepare(s : String) -> String? {
  match normalize_numeric(s) {
    Some(t) => Some(to_dbc(t))
    None => None
  }
}

///|
/// `Json` 的字符串形态（`AbstractConverter.convertToStr` 的 Json 版，`#9.1` 与 `#9.3` 共用）。
/// `Null` 走 `None`——hutool 里 JSON null 与"没有这个值"是同一件事，本包用 `Option` 表达。
fn text_of(j : Json) -> String? {
  match j {
    Null => None
    True => Some("true")
    False => Some("false")
    Number(d, repr~) =>
      match repr {
        Some(r) => Some(r)
        None => Some(d.to_string())
      }
    String(s) => Some(s)
    _ => Some(j.stringify())
  }
}

///|
/// 两态档（`BooleanUtil.toBoolean`，`:82`）：非空白又不在 `TRUE_SET` 里就是 `false`，**没有第三态**。
fn two_state_bool(text : String) -> Bool {
  let t = ascii_trim(text)
  if @text.is_blank(t) {
    false
  } else {
    true_words.contains(ascii_lower(t))
  }
}

///|
/// 路径段。下标段走 #9.10 的整数档（所以 `[+2]` 合法、`[-1]` 文法合法但取不到）。
priv enum Seg {
  Key(String)
  Idx(Int64)
}

///|
/// 路径文法：`key ('.' key | '[' idx ']')*`。
/// key 非空且不含 `.`/`[`/`]`/空白；空路径、空段、未闭合 `[`、多余 `]`、下标非整数都 raise。
fn parse_path(path : String) -> Array[Seg] raise ConvError {
  let cs = path.to_array()
  let n = cs.length()
  let segs : Array[Seg] = []
  if n == 0 {
    raise ConvError::BadPath(path)
  }
  let mut i = 0
  let mut first = true
  while i < n {
    if !first {
      // 段与段之间只能是 '.' 或直接 '['（`a[1]b` 这种贴在一起的判坏）
      if cs[i] == '.' {
        i += 1
      } else if cs[i] != '[' {
        raise ConvError::BadPath(path)
      }
    }
    first = false
    if i >= n {
      raise ConvError::BadPath(path) // 尾随的 '.' 或空段
    }
    if cs[i] == '[' {
      i += 1
      let start = i
      while i < n && cs[i] != ']' {
        i += 1
      }
      if i >= n {
        raise ConvError::BadPath(path) // 未闭合的 '['
      }
      let idx_text = String::from_array(cs[start:i])
      i += 1
      match loose_int64_text(idx_text) {
        Some(v) => segs.push(Idx(v))
        None => raise ConvError::BadPath(path) // 空下标、非整数下标
      }
      if i < n && cs[i] != '.' && cs[i] != '[' {
        raise ConvError::BadPath(path)
      }
    } else {
      let start = i
      while i < n && cs[i] != '.' && cs[i] != '[' && cs[i] != ']' && cs[i] > ' ' {
        i += 1
      }
      if i == start {
        raise ConvError::BadPath(path) // 空段：'.a'、'a..b'
      }
      let key = String::from_array(cs[start:i])
      if i < n && cs[i] == ']' {
        raise ConvError::BadPath(path) // 多余的 ']'
      }
      segs.push(Key(key))
      if i < n && cs[i] != '.' && cs[i] != '[' && cs[i] > ' ' {
        raise ConvError::BadPath(path)
      }
    }
  }
  segs
}
