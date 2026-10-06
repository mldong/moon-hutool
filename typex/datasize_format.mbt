///|
// moon-hutool/typex —— 数据量的可读格式化（ROADMAP 第 23 行第三批 F，#23.106–#23.107）
// 对位 hutool `DataSizeUtil.format(long)` 与 `format(Long, DataUnit)`（件在 `cn.hutool.core.io.unit.DataSizeUtil`，
// **不是 `DataSize` 的方法**）。契约真相在 `docs/spec/23-typex.md` §18。
//
// 三条决定实现形状的事实（都有腿读数为凭）：
// - `size <= 0` 一律给**不带单位的 `"0"`**（负数与 0 同档，压根不走格式化）：`FMT|-1`、`FMT|-1024`、
//   `FMT_AT_TERABYTES|-9223372036854775808` 三条读数都是 `"0"`。
// - 两件的分组**不同**：`format(long)` 用 `"#,##0.##"`（有千分位），`format(Long, DataUnit)` 用 `"##0.##"`
//   （没有千分位）——照抄不抹平。
// - 选档靠 `(int)(Math.log10(size) / Math.log10(1024))` 再 `min(UNIT_NAMES.length - 1, …)`，
//   印的是 `size / 1024^digitGroups` 的"最多两位小数 + 去尾零"，参照的舍入是 `DecimalFormat` 默认的 `HALF_EVEN`。
//
// 实现是**组合 `@num` 的现成件**（`round_to_str` / `trim_trailing_zeros` / `format_thousands`），不新写格式化器：
// `num` 那侧早已就 `DecimalFormat` 做过归属裁定（#8.11/#8.12：只认最短十进制一个族，且 `DecimalFormat` 随 JVM locale 变），
// 而冻期望前的对撞实测两族在这 148 条上逐字节相同（分歧只有单位 `B` 且 `size >= 2^53` 的两条，那两档不收，
// 理由与两条按构造的推导见 §18.1 与 §18.6 末）⇒ 复用不改变任何一条冻结读数。

///|
/// `@num` 那三件都会 `raise NumError`，而本批输入是「有限 Double + 固定 scale ≤ 2」，
/// `NotFinite` 与 `ScaleOutOfRange` 在数学上都到不了。不为不可达分支造第二种答案，直接把不变式写成 `abort`：
/// 真走到这里就是本包自己的缺陷，报错要能指回来。
fn dsfmt_impossible(_e : @num.NumError) -> String {
  abort(
    "moon-hutool/typex：@num 舍入与分组对「有限值 + scale<=2」不可失败，走到这里说明本包不变式破了",
  )
}

///|
/// 单位字节数 → 该字节数的规范后缀名：按 #23.81 那张表的**同序两列**取，不新写第二张单位表
fn dsfmt_unit_name(bytes : Int64) -> String {
  for i in 0..<ds_unit_bytes.length() {
    if ds_unit_bytes[i] == bytes {
      return ds_unit_names[i]
    }
  }
  abort(
    "moon-hutool/typex：单位字节数表与后缀名表同序同长是本包内部不变式",
  )
}

///|
/// 印数顺序 = **先舍入、再去尾零、最后按去尾零后的小数位数挂千分位**。
///
/// 顺序不能反过来（先分组再去尾零）：`@num.trim_trailing_zeros` 认的是**平**十进制串，
/// `"1,023.00"` 会判 `NotDecimal` 而 raise。这条不是设想出来的——第一版就是"分组→去尾零"，
/// `format(long)` 那一块当场炸在上面那个不变式 `abort` 上（正好证明"不可达分支写成 abort 而不是给假答案"是对的）。
fn dsfmt_number(size : Int64, unit_bytes : Int64, grouping : Bool) -> String {
  let v = size.to_double() / unit_bytes.to_double()
  let base = @num.round_to_str(v, 2, mode=@num.RoundingMode::HalfEven) catch {
    e => dsfmt_impossible(e)
  }
  let trimmed = @num.trim_trailing_zeros(base) catch {
    e => dsfmt_impossible(e)
  }
  if !grouping {
    return trimmed
  }
  let mut frac = 0
  let mut after_dot = false
  for c in trimmed.to_array() {
    if c == '.' {
      after_dot = true
    } else if after_dot {
      frac += 1
    }
  }
  let back = @string.parse_double(trimmed) catch {
    _ =>
      abort(
        "moon-hutool/typex：去尾零的产物必是可解析的平十进制串",
      )
  }
  @num.format_thousands(back, frac, mode=@num.RoundingMode::HalfEven) catch {
    e => dsfmt_impossible(e)
  }
}

///|
/// #23.106 把字节数格式化成"数值 + 单位"的可读串（自动选档，带千分位）
/// - Returns: `size <= 0` 给 `"0"`；否则给 `"<最多两位小数的数值> <单位>"`，整数部分带三位一组的千分位
/// - Raises: 无
/// - Note: hutool 对位 `static String DataSizeUtil.format(long size)`
pub fn data_size_format(size : Int64) -> String {
  if size <= 0L {
    return "0"
  }
  let names = data_unit_suffixes()
  let s = size.to_double()
  let raw = (@math.log10(s) / @math.log10(1024.0)).to_int()
  let top = names.length() - 1
  let dig = if raw > top { top } else { raw }
  // 1024^dig 对 dig ≤ 6（= 2^60）在 double 内精确，故按整数值取回单位字节数（§18.5 最后一条）
  let unit_bytes = @math.pow(1024.0, dig.to_double()).to_int64()
  dsfmt_number(size, unit_bytes, true) + " " + names[dig]
}

///|
/// #23.107 按指定单位格式化字节数（**不带**千分位，与 #23.106 的差别是参照自己的）
/// - Returns: `size <= 0` 给 `"0"`；否则按 `suffix` 定档给 `"<数值> <单位>"`，无千分位
/// - Raises: `DataSizeError::BadText`——后缀不认，或后缀是只进 `UNIT_NAMES` 表、不在枚举里的 `PB`/`EB`
///   （参照的单位参数是枚举，那两枚根本传不进来，本库把单位降成串就多出这一档，按 §15.5 同一处置走查表）
/// - Note: hutool 对位 `static String DataSizeUtil.format(Long size, DataUnit unit)`；
///   参照的定档是 `ArrayUtil.indexOf(UNIT_NAMES, unit.getSuffix())`
pub fn data_size_format_at(
  size : Int64,
  suffix : String,
) -> String raise DataSizeError {
  if size <= 0L {
    return "0"
  }
  let unit_bytes = match data_unit_bytes_by_suffix(suffix) {
    Some(b) => b
    None => raise BadText
  }
  dsfmt_number(size, unit_bytes, false) + " " + dsfmt_unit_name(unit_bytes)
}
