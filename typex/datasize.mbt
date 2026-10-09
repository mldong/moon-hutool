///|
// moon-hutool/typex —— 数据量（ROADMAP 第 23 行第三批 E，#23.64–#23.82）
// 对位 hutool `DataSize` / `DataSizeUtil` / `DataUnit`。契约真相在 `docs/spec/23-typex.md` §15。
//
// 三条决定实现形状、且都有腿读数为凭的事实：
// - 参照 `DataUnit.fromSuffix` 走 `StrUtil.startWithIgnoreCase(candidate.suffix, suffix)` ——
//   **候选后缀以入参开头**才算命中：`"K"`→KB、`"g"`→GB、`""`→B（落第一枚），`"PB"`/`"BBB"`/`"TB "` 不认。
//   #23.71 与 #23.65 的后缀解析都共用 #23.81 这张表，不留第二张嘴。
// - `parse` 的数值段是 `of(BigDecimal, unit)`：**十进制精确乘 → 向零截断、不查重**。
//   `1.9999999999999999KB` 给 `2047`（浮点乘会给 `2048`）、`9007199254740993B` 原样给回、`-1.5KB` 给 `-1536`
//   ⇒ 这里按十进制位逐位算，不许换成 `Double`。
// - 五件 `ofXxx(long)` 走 `Math.multiplyExact`（溢出抛），`ofBytes` 不查重；`toXxx()` 是 Java 整除（向零截断）。
//
// 一处腿没覆盖、写在这里而不是留给读者猜：乘积超出 `Int64` 时参照是 `BigDecimal#longValue()` 的**低 64 位窄化**，
// 本库的 `Int64` 算术同为环绕语义 ⇒ 方向一致；但"先环绕乘完再截断"与"精确乘完再窄化"在极大值上可以差
// 一个 2^64 以内的量级，这一档没有读数、不进契约。

///|
/// 数据量件的失败形状（两档，语义见 §15.5）。
pub suberror DataSizeError {
  /// 文本不合 `DataSize` 语法，或后缀不认（参照 `IllegalArgumentException`）
  BadText
  /// `of*` 系乘出 `Int64` 之外（参照 `ArithmeticException: long overflow`）
  Overflow
}

///|
const DS_KB : Int64 = 1024L

///|
const DS_MB : Int64 = 1048576L

///|
const DS_GB : Int64 = 1073741824L

///|
const DS_TB : Int64 = 1099511627776L

///|
const DS_INT64_MAX : Int64 = 9223372036854775807L

///|
const DS_INT64_MIN : Int64 = -9223372036854775807L - 1L

///|
/// 参照 `DataUnit` 的五枚常量：后缀与字节数按常量序一一对应（`UNIT_NAMES` 的七枚另在 #23.82 出）。
let ds_unit_names : Array[String] = ["B", "KB", "MB", "GB", "TB"]

///|
let ds_unit_bytes : Array[Int64] = [1L, DS_KB, DS_MB, DS_GB, DS_TB]

///|
fn ds_clean_blank(text : String) -> String {
  let out : Array[Char] = []
  for c in text.to_array() {
    if !@text.is_blank_char(c) {
      out.push(c)
    }
  }
  String::from_array(out)
}

///|
fn ds_lower(c : Char) -> Int {
  let x = c.to_int()
  if x >= 65 && x <= 90 {
    x + 32
  } else {
    x
  }
}

///|
fn ds_is_digit(c : Char) -> Bool {
  let x = c.to_int()
  x >= 48 && x <= 57
}

///|
fn ds_is_ascii_letter(c : Char) -> Bool {
  let x = ds_lower(c)
  x >= 97 && x <= 122
}

///|
/// `StrUtil.startWithIgnoreCase(候选, 入参)`：入参比候选长必然不认，空入参恒认（⇒ 落到第一枚 `B`）。
fn ds_starts_with_ignore_case(candidate : String, input : String) -> Bool {
  let a = candidate.to_array()
  let b = input.to_array()
  if b.length() > a.length() {
    return false
  }
  for i in 0..<b.length() {
    if ds_lower(a[i]) != ds_lower(b[i]) {
      return false
    }
  }
  true
}

///|
/// #23.81 后缀串反查"一枚单位是多少字节"
/// - Returns: 命中给 `Some(字节数)`；不认（含只进 `UNIT_NAMES` 的 `PB`/`EB`、比候选更长的串、带空白的串）给 `None`
/// - Raises: 无（参照在这一档**抛** `IllegalArgumentException`，本库查表件给 `Option`，§15.5）
/// - Note: hutool 对位 `static DataUnit DataUnit.fromSuffix(String)` + `size().toBytes()`
pub fn data_unit_bytes_by_suffix(suffix : String) -> Int64? {
  for i in 0..<ds_unit_names.length() {
    if ds_starts_with_ignore_case(ds_unit_names[i], suffix) {
      return Some(ds_unit_bytes[i])
    }
  }
  None
}

///|
/// #23.64 解析数据量文本为字节数（无单位段时按字节）
/// - Returns: 合法文本给字节数；非法文本/非法后缀 `raise BadText`
/// - Raises: `DataSizeError::BadText`（参照 `IllegalArgumentException`）
/// - Note: hutool 对位 `static DataSize DataSize.parse(CharSequence)`；空白先整串清掉
pub fn data_size_parse_bytes(text : String) -> Int64 raise DataSizeError {
  ds_parse(text, "B")
}

///|
/// #23.65 解析数据量文本为字节数，无单位段时用给定后缀兜底
/// - Returns: 同 #23.64；文本自带后缀时后缀优先（兜底只填空缺——自带后缀时参照也不看默认单位，本库同样不看）
/// - Raises: `DataSizeError::BadText`（文本非法，或生效的兜底后缀不认——本库新增档，§15.5）
/// - Note: hutool 对位 `static DataSize DataSize.parse(CharSequence, DataUnit)`
pub fn data_size_parse_bytes_with(
  text : String,
  suffix : String,
) -> Int64 raise DataSizeError {
  ds_parse(text, suffix)
}

///|
/// 参照 `PATTERN = ^([+-]?\d+(\.\d+)?)([a-zA-Z]{0,2})$` 的逐字符等价写法：
/// `[+-]?` 只允许开头一个、`\d` 只认 ASCII（全角与阿拉伯-印度数字都不进）、小数点后至少一位、后缀最多两字母。
/// 出 `(数字段, 后缀段)`；任一档不合就 `BadText`——参照把"正则不匹配"与"后缀不认"都包成同一个
/// `IllegalArgumentException`，所以本库不必分子档（两条来源在腿里各有读数，出口都是 `BadText`）。
fn ds_scan(text : String) -> (String, String) raise DataSizeError {
  let cs = text.to_array()
  let n = cs.length()
  let num : Array[Char] = []
  let suf : Array[Char] = []
  let mut i = 0
  if n > 0 && (cs[0] == '+' || cs[0] == '-') {
    num.push(cs[0])
    i = 1
  }
  let mut int_digits = 0
  while i < n && ds_is_digit(cs[i]) {
    num.push(cs[i])
    int_digits += 1
    i += 1
  }
  if int_digits == 0 {
    raise BadText
  }
  if i < n && cs[i] == '.' {
    num.push('.')
    i += 1
    let mut frac_digits = 0
    while i < n && ds_is_digit(cs[i]) {
      num.push(cs[i])
      frac_digits += 1
      i += 1
    }
    if frac_digits == 0 {
      raise BadText
    }
  }
  while i < n && ds_is_ascii_letter(cs[i]) {
    suf.push(cs[i])
    i += 1
  }
  if suf.length() > 2 || i != n {
    raise BadText
  }
  (String::from_array(num), String::from_array(suf))
}

///|
/// `(frac / scale) * unit` 的**截断**值，且不许中间量溢出：先把 `unit` 与 `scale` 的 2 的公因子约掉
/// （五枚单位恒是 2 的幂，`scale` 是 10^k），再用 `(f/s)*u + ((f%s)*u)/s` 恒等拆开。
/// 直算 `(whole*scale + frac) * unit` 在 16 位小数那一档会冲出 `Int64`（`1.9999999999999999KB`
/// 的中间量是 2.05e19），而参照是 `BigDecimal` 精确乘完才窄化——不拆开就会在这儿环绕成别的数。
fn ds_frac_bytes(frac : Int64, scale : Int64, unit : Int64) -> Int64 {
  let mut u = unit
  let mut s = scale
  while s % 2L == 0L && u % 2L == 0L {
    s = s / 2L
    u = u / 2L
  }
  frac / s * u + frac % s * u / s
}

///|
/// 十进制精确乘再向零截断：`(整数段 * 10^k + 小数段) * unit / 10^k`，全程 `Int64`、不查重。
fn ds_decimal_times(text : String, unit : Int64) -> Int64 {
  let cs = text.to_array()
  let neg = cs[0] == '-'
  let mut i = if cs[0] == '-' || cs[0] == '+' { 1 } else { 0 }
  let mut whole : Int64 = 0L
  while i < cs.length() && cs[i] != '.' {
    whole = whole * 10L + (cs[i].to_int() - 48).to_int64()
    i += 1
  }
  let mut frac : Int64 = 0L
  let mut scale : Int64 = 1L
  if i < cs.length() {
    i += 1
    while i < cs.length() {
      frac = frac * 10L + (cs[i].to_int() - 48).to_int64()
      scale = scale * 10L
      i += 1
    }
  }
  let q = whole * unit + ds_frac_bytes(frac, scale, unit)
  if neg {
    0L - q
  } else {
    q
  }
}

///|
/// `parse` 的两条路共用：文本自带后缀就用它（不认则 `BadText`），后缀缺省才去查兜底后缀。
fn ds_parse(
  text : String,
  default_suffix : String,
) -> Int64 raise DataSizeError {
  let (num, suf) = ds_scan(ds_clean_blank(text))
  let key = if suf.length() > 0 { suf } else { default_suffix }
  let unit = match data_unit_bytes_by_suffix(key) {
    Some(u) => u
    None => raise BadText
  }
  ds_decimal_times(num, unit)
}

///|
/// #23.66 字节数原样收成数据量（**不做溢出检查**，参照同款）
/// - Returns: 入参本身
/// - Raises: 无
/// - Note: hutool 对位 `static DataSize DataSize.ofBytes(long)`
pub fn data_size_of_bytes(b : Int64) -> Int64 {
  b
}

///|
/// 参照 `Math.multiplyExact` 的查重：单位恒正，所以两端各算一次整除边界就够
/// （腿把每枚单位的上下边界都读到了：`OF_KB|9007199254740991` 是值、`|9007199254740992` 溢出）。
fn ds_mul_checked(n : Int64, unit : Int64) -> Int64 raise DataSizeError {
  if n > DS_INT64_MAX / unit || n < DS_INT64_MIN / unit {
    raise Overflow
  }
  n * unit
}

///|
/// #23.67 KB 数转字节数
/// - Returns: `n * 1024`
/// - Raises: `DataSizeError::Overflow`（乘出 `Int64`，参照 `Math.multiplyExact`）
/// - Note: hutool 对位 `static DataSize DataSize.ofKilobytes(long)`
pub fn data_size_of_kilobytes(n : Int64) -> Int64 raise DataSizeError {
  ds_mul_checked(n, DS_KB)
}

///|
/// #23.68 MB 数转字节数
/// - Returns: `n * 1048576`
/// - Raises: `DataSizeError::Overflow`
/// - Note: hutool 对位 `static DataSize DataSize.ofMegabytes(long)`
pub fn data_size_of_megabytes(n : Int64) -> Int64 raise DataSizeError {
  ds_mul_checked(n, DS_MB)
}

///|
/// #23.69 GB 数转字节数
/// - Returns: `n * 1073741824`
/// - Raises: `DataSizeError::Overflow`
/// - Note: hutool 对位 `static DataSize DataSize.ofGigabytes(long)`
pub fn data_size_of_gigabytes(n : Int64) -> Int64 raise DataSizeError {
  ds_mul_checked(n, DS_GB)
}

///|
/// #23.70 TB 数转字节数
/// - Returns: `n * 1099511627776`
/// - Raises: `DataSizeError::Overflow`
/// - Note: hutool 对位 `static DataSize DataSize.ofTerabytes(long)`
pub fn data_size_of_terabytes(n : Int64) -> Int64 raise DataSizeError {
  ds_mul_checked(n, DS_TB)
}

///|
/// #23.71 按后缀串指定单位转字节数
/// - Returns: `n * 单位字节数`；后缀按 #23.81 的前缀规则解析
/// - Raises: `DataSizeError::BadText`（后缀不认，参照 `fromSuffix` 抛）/ `DataSizeError::Overflow`
/// - Note: hutool 对位 `static DataSize DataSize.of(long, DataUnit)`；参照的单位是枚举，本库收后缀串
pub fn data_size_of_amount_suffix(
  n : Int64,
  suffix : String,
) -> Int64 raise DataSizeError {
  let unit = match data_unit_bytes_by_suffix(suffix) {
    Some(u) => u
    None => raise BadText
  }
  ds_mul_checked(n, unit)
}

///|
/// #23.72 字节数出口
/// - Returns: 入参本身
/// - Raises: 无
/// - Note: hutool 对位 `long DataSize.toBytes()`
pub fn data_size_to_bytes(n : Int64) -> Int64 {
  n
}

///|
/// #23.73 KB 出口（整除，向零截断）
/// - Returns: `n / 1024`
/// - Raises: 无
/// - Note: hutool 对位 `long DataSize.toKilobytes()`
pub fn data_size_to_kilobytes(n : Int64) -> Int64 {
  n / DS_KB
}

///|
/// #23.74 MB 出口（整除，向零截断）
/// - Returns: `n / 1048576`
/// - Raises: 无
/// - Note: hutool 对位 `long DataSize.toMegabytes()`
pub fn data_size_to_megabytes(n : Int64) -> Int64 {
  n / DS_MB
}

///|
/// #23.75 GB 出口（整除，向零截断）
/// - Returns: `n / 1073741824`
/// - Raises: 无
/// - Note: hutool 对位 `long DataSize.toGigabytes()`
pub fn data_size_to_gigabytes(n : Int64) -> Int64 {
  n / DS_GB
}

///|
/// #23.76 TB 出口（整除，向零截断）
/// - Returns: `n / 1099511627776`
/// - Raises: 无
/// - Note: hutool 对位 `long DataSize.toTerabytes()`
pub fn data_size_to_terabytes(n : Int64) -> Int64 {
  n / DS_TB
}

///|
/// #23.77 是否为负（**不含 0**）
/// - Returns: `n < 0`
/// - Raises: 无
/// - Note: hutool 对位 `boolean DataSize.isNegative()`
pub fn data_size_is_negative(n : Int64) -> Bool {
  n < 0L
}

///|
/// #23.78 数据量的 `toString` 形态
/// - Returns: `"<n>B"`
/// - Raises: 无
/// - Note: hutool 对位 `String DataSize.toString()`（`String.format("%dB", bytes)`）
pub fn data_size_to_string(n : Int64) -> String {
  n.to_string() + "B"
}

///|
/// #23.79 两个字节数比大小
/// - Returns: `-1` / `0` / `1`
/// - Raises: 无
/// - Note: hutool 对位 `int DataSize.compareTo(DataSize)`（`Long.compare`）——写差值会在极值档炸（§15.6 N12）
pub fn data_size_compare(a : Int64, b : Int64) -> Int {
  if a < b {
    -1
  } else if a > b {
    1
  } else {
    0
  }
}

///|
/// #23.80 两个字节数是否相等
/// - Returns: `a == b`
/// - Raises: 无
/// - Note: hutool 对位 `boolean DataSize.equals(Object)`（同类且 `bytes` 相等）
pub fn data_size_equal(a : Int64, b : Int64) -> Bool {
  a == b
}

///|
/// #23.82 单位后缀表（按参照 `UNIT_NAMES` 的原序）
/// - Returns: 七枚 `"B" "KB" "MB" "GB" "TB" "PB" "EB"`——后两枚只进表、#23.81 反查不到（参照同款不对称）
/// - Raises: 无
/// - Note: hutool 对位 `DataUnit.UNIT_NAMES`（反射读的公开数组）
pub fn data_unit_suffixes() -> Array[String] {
  ["B", "KB", "MB", "GB", "TB", "PB", "EB"]
}
