///|
// moon-hutool/typex —— 数据量（ROADMAP 第 23 行第三批 E，#23.64–#23.82）
// 对位 hutool `DataSize` / `DataSizeUtil` / `DataUnit`。契约真相在 `docs/spec/23-typex.md` §15。
//
// 三条决定实现形状、且都有腿读数为凭的事实：
// - 参照的 `DataUnit` 是"五枚常量 + 一张七枚后缀表（含 PB/EB）"，而 `fromSuffix` 走的是
//   `StrUtil.startWithIgnoreCase(candidate.suffix, suffix)` —— **候选后缀以入参开头**才算命中：
//   所以 `"K"`→KB、`"g"`→GB、`""`→B（落到第一枚），而 `"PB"`/`"BBB"`/`"TB "` 抛（腿 2 有读数）。
//   本库把"单位"这张表直接做成公开的后缀反查件，不暴露枚举值（形状定案见 §15.1）。
// - `parse` 的数值段允许小数，且走 `of(BigDecimal, unit)`：**十进制精确乘 → `longValue()` 向零截断、不查重**。
//   腿里 `1.9999999999999999KB` 给 `2047`（double 乘会给 `2048`）、`-1.5KB` 给 `-1536`——
//   这两条就是"实现必须十进制精确、不许换成浮点"的钉子的夹具。
// - 五件 `ofXxx(long)` 走 `Math.multiplyExact`（溢出抛 `ArithmeticException`），而 `ofBytes` **不查重**；
//   `toXxx()` 一律是 Java 的整除（向零截断），不是四舍五入。
//
// 本批把参照的**两种失败形状**收成显式错误变体 `DataSizeError`（`parse` 系与未知后缀 → `BadText`；
// `of*` 系溢出 → `Overflow`），唯一例外是纯查表的 `data_unit_bytes_by_suffix` 给 `Option`
// （分岔表见 §15.5）。`format` / `format(…, DataUnit)` 两族本批不收——选档靠 `Math.log10` 的浮点边界、
// 印数靠 `DecimalFormat("#,##0.##")` 的千分位 + HALF_EVEN，要先做 core 侧对撞才冻期望（读数已在腿里存着）。

///|
/// 数据量件的失败形状（两档，语义见 §15.5）。
pub suberror DataSizeError {
  /// 文本不合 `DataSize` 语法，或后缀不认（参照 `IllegalArgumentException`）
  BadText
  /// `of*` 系乘出 `Int64` 之外（参照 `ArithmeticException: long overflow`）
  Overflow
}

///|
/// 骨架期的"未实现"出口。两枚变体在这里各构造一次、且每件 raise 都经本件，是为了让
/// "签名声明了 `raise` 而体里没 raise" 与 "错误变体没人构造" 两类警告不盖住真信号——
/// 这一版 `moon.pkg` 的 `warnings` 字段只容一个助记符（数组形与空格形都被 `moonc` 拒），只能压掉 `unused_value`。
/// PR-B 落地笔整体删除本件，十九件签名与两枚变体都已在 `.mbti` 冻住。
fn datasize_unimplemented(what : String) -> DataSizeError {
  let _both : Array[DataSizeError] = [BadText, Overflow]
  abort(
    "moon-hutool PR-B：契约骨架 " +
    what +
    " 待落地，见 docs/spec/23-typex.md §15",
  )
}

///|
/// #23.64 解析数据量文本为字节数（无单位段时按字节）
/// - Returns: 合法文本给字节数；非法文本/非法后缀 `raise BadText`
/// - Raises: `DataSizeError::BadText`（参照 `IllegalArgumentException`）
/// - Note: hutool 对位 `static DataSize DataSize.parse(CharSequence)`；空白先整串清掉
pub fn data_size_parse_bytes(text : String) -> Int64 raise DataSizeError {
  raise datasize_unimplemented("#23.64 data_size_parse_bytes")
}

///|
/// #23.65 解析数据量文本为字节数，无单位段时用给定后缀兜底
/// - Returns: 同 #23.64；文本自带后缀时后缀优先（兜底只填空缺）
/// - Raises: `DataSizeError::BadText`（文本非法，或兜底后缀不认——参照那侧类型上给不出非法单位，此为本库新增档，见 §15.5）
/// - Note: hutool 对位 `static DataSize DataSize.parse(CharSequence, DataUnit)`
pub fn data_size_parse_bytes_with(
  text : String,
  suffix : String,
) -> Int64 raise DataSizeError {
  raise datasize_unimplemented("#23.65 data_size_parse_bytes_with")
}

///|
/// #23.66 字节数原样收成数据量（**不做溢出检查**，参照同款）
/// - Returns: 入参本身
/// - Raises: 无
/// - Note: hutool 对位 `static DataSize DataSize.ofBytes(long)`
pub fn data_size_of_bytes(b : Int64) -> Int64 {
  abort("moon-hutool PR-B：#23.66 data_size_of_bytes 待落地")
}

///|
/// #23.67 KB 数转字节数
/// - Returns: `n * 1024`
/// - Raises: `DataSizeError::Overflow`（乘出 `Int64`，参照 `Math.multiplyExact`）
/// - Note: hutool 对位 `static DataSize DataSize.ofKilobytes(long)`
pub fn data_size_of_kilobytes(n : Int64) -> Int64 raise DataSizeError {
  raise datasize_unimplemented("#23.67 data_size_of_kilobytes")
}

///|
/// #23.68 MB 数转字节数
/// - Returns: `n * 1048576`
/// - Raises: `DataSizeError::Overflow`
/// - Note: hutool 对位 `static DataSize DataSize.ofMegabytes(long)`
pub fn data_size_of_megabytes(n : Int64) -> Int64 raise DataSizeError {
  raise datasize_unimplemented("#23.68 data_size_of_megabytes")
}

///|
/// #23.69 GB 数转字节数
/// - Returns: `n * 1073741824`
/// - Raises: `DataSizeError::Overflow`
/// - Note: hutool 对位 `static DataSize DataSize.ofGigabytes(long)`
pub fn data_size_of_gigabytes(n : Int64) -> Int64 raise DataSizeError {
  raise datasize_unimplemented("#23.69 data_size_of_gigabytes")
}

///|
/// #23.70 TB 数转字节数
/// - Returns: `n * 1099511627776`
/// - Raises: `DataSizeError::Overflow`
/// - Note: hutool 对位 `static DataSize DataSize.ofTerabytes(long)`
pub fn data_size_of_terabytes(n : Int64) -> Int64 raise DataSizeError {
  raise datasize_unimplemented("#23.70 data_size_of_terabytes")
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
  raise datasize_unimplemented("#23.71 data_size_of_amount_suffix")
}

///|
/// #23.72 字节数出口
/// - Returns: 入参本身
/// - Raises: 无
/// - Note: hutool 对位 `long DataSize.toBytes()`
pub fn data_size_to_bytes(n : Int64) -> Int64 {
  abort("moon-hutool PR-B：#23.72 data_size_to_bytes 待落地")
}

///|
/// #23.73 KB 出口（整除，向零截断）
/// - Returns: `n / 1024`
/// - Raises: 无
/// - Note: hutool 对位 `long DataSize.toKilobytes()`
pub fn data_size_to_kilobytes(n : Int64) -> Int64 {
  abort("moon-hutool PR-B：#23.73 data_size_to_kilobytes 待落地")
}

///|
/// #23.74 MB 出口（整除，向零截断）
/// - Returns: `n / 1048576`
/// - Raises: 无
/// - Note: hutool 对位 `long DataSize.toMegabytes()`
pub fn data_size_to_megabytes(n : Int64) -> Int64 {
  abort("moon-hutool PR-B：#23.74 data_size_to_megabytes 待落地")
}

///|
/// #23.75 GB 出口（整除，向零截断）
/// - Returns: `n / 1073741824`
/// - Raises: 无
/// - Note: hutool 对位 `long DataSize.toGigabytes()`
pub fn data_size_to_gigabytes(n : Int64) -> Int64 {
  abort("moon-hutool PR-B：#23.75 data_size_to_gigabytes 待落地")
}

///|
/// #23.76 TB 出口（整除，向零截断）
/// - Returns: `n / 1099511627776`
/// - Raises: 无
/// - Note: hutool 对位 `long DataSize.toTerabytes()`
pub fn data_size_to_terabytes(n : Int64) -> Int64 {
  abort("moon-hutool PR-B：#23.76 data_size_to_terabytes 待落地")
}

///|
/// #23.77 是否为负（**不含 0**）
/// - Returns: `n < 0`
/// - Raises: 无
/// - Note: hutool 对位 `boolean DataSize.isNegative()`
pub fn data_size_is_negative(n : Int64) -> Bool {
  abort("moon-hutool PR-B：#23.77 data_size_is_negative 待落地")
}

///|
/// #23.78 数据量的 `toString` 形态
/// - Returns: `"<n>B"`
/// - Raises: 无
/// - Note: hutool 对位 `String DataSize.toString()`（`String.format("%dB", bytes)`）
pub fn data_size_to_string(n : Int64) -> String {
  abort("moon-hutool PR-B：#23.78 data_size_to_string 待落地")
}

///|
/// #23.79 两个字节数比大小
/// - Returns: `-1` / `0` / `1`
/// - Raises: 无
/// - Note: hutool 对位 `int DataSize.compareTo(DataSize)`（`Long.compare`）
pub fn data_size_compare(a : Int64, b : Int64) -> Int {
  abort("moon-hutool PR-B：#23.79 data_size_compare 待落地")
}

///|
/// #23.80 两个字节数是否相等
/// - Returns: `a == b`
/// - Raises: 无
/// - Note: hutool 对位 `boolean DataSize.equals(Object)`（同类且 `bytes` 相等）
pub fn data_size_equal(a : Int64, b : Int64) -> Bool {
  abort("moon-hutool PR-B：#23.80 data_size_equal 待落地")
}

///|
/// #23.81 后缀串反查"一枚单位是多少字节"
/// - Returns: 命中给 `Some(字节数)`；不认（含 `PB`/`EB`/比候选更长的串/带空白）给 `None`
/// - Raises: 无（参照在此**抛** `IllegalArgumentException`，本库查表件给 `Option`，见 §15.5）
/// - Note: hutool 对位 `static DataUnit DataUnit.fromSuffix(String)` + `size().toBytes()`
pub fn data_unit_bytes_by_suffix(suffix : String) -> Int64? {
  abort("moon-hutool PR-B：#23.81 data_unit_bytes_by_suffix 待落地")
}

///|
/// #23.82 单位后缀表（按参照 `UNIT_NAMES` 的原序）
/// - Returns: 七枚 `"B" "KB" "MB" "GB" "TB" "PB" "EB"`——后两枚只进表、#23.81 反查不到（参照同款不对称）
/// - Raises: 无
/// - Note: hutool 对位 `DataUnit.UNIT_NAMES`（反射读的公开数组）
pub fn data_unit_suffixes() -> Array[String] {
  abort("moon-hutool PR-B：#23.82 data_unit_suffixes 待落地")
}
