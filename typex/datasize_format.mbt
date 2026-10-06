///|
// moon-hutool/typex —— 数据量的可读格式化（ROADMAP 第 23 行第三批 F，#23.106–#23.107）
// 对位 hutool `DataSizeUtil.format(long)` 与 `format(Long, DataUnit)`（件在 `cn.hutool.core.io.unit.DataSizeUtil`，
// **不是 `DataSize` 的方法**）。契约真相在 `docs/spec/23-typex.md` §18。
//
// 三条决定实现形状的事实（两条有腿读数为凭，一条有对撞脚本为凭）：
// - `size <= 0` 一律给**不带单位的 `"0"`**（负数与 0 同档，压根不走格式化）——腿里 `FMT|-1`、`FMT|-1024`、
//   `FMT_AT_TERABYTES|-9223372036854775808` 都是这个形状。
// - 两件的分组**不同**：`format(long)` 用 `"#,##0.##"`（有千分位），`format(Long, DataUnit)` 用 `"##0.##"`
//   （没有千分位）——照抄不抹平，腿各有一档大数读数钉住（`FMT|12345678` 给 `"11.77 MB"` 而 `FMT_AT_BYTES|…` 那种
//   十六七位的量在 `format_at` 下不带逗号）。
// - 选档靠 `(int)(Math.log10(size) / Math.log10(1024))` 再 `min(UNIT_NAMES.length - 1, …)`，
//   然后 `size / Math.pow(1024, digitGroups)`；印数是"最多两位小数 + 去尾零"，默认舍入 `HALF_EVEN`。
//
// 本批**复用 `@num` 的舍入与分组件**而不新写格式化器：`num` 那侧已就 `DecimalFormat` 做过归属裁定
// （只认最短十进制一个族，理由与实测见 num 的 #8.11/#8.12），而冻期望前的对撞脚本实测**两族在这 148 条上逐字节相同**
// （分歧只出现在单位 `B` 且 `size ≥ 2^53` 的两条，参照给的是它内部位数截断的值，那两档不收，见 §18.1）
// ⇒ 本批不需要把任何期望从参照读数改成本库读数。

///|
/// #23.106 把字节数格式化成"数值 + 单位"的可读串（自动选档，带千分位）
/// - Returns: `size <= 0` 给 `"0"`；否则给 `"<最多两位小数的数值> <单位>"`，整数部分带三位一组的千分位
/// - Raises: 无
/// - Note: hutool 对位 `static String DataSizeUtil.format(long size)`
pub fn data_size_format(size : Int64) -> String {
  abort("moon-hutool PR-B：#23.106 data_size_format 待落地")
}

///|
/// 骨架期的"未实现"出口：让 #23.107 的 `raise` 位真实存在（本版 `moon.pkg` 的 `warnings` 只容一个助记符，
/// 压不下 `unused_error_type`，照 §15.7 那条先例用构造消掉）。落地笔随骨架一起删除。
fn dsfmt_unimplemented(what : String) -> DataSizeError {
  abort(
    "moon-hutool PR-B：契约骨架 " +
    what +
    " 待落地，见 docs/spec/23-typex.md §18",
  )
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
  raise dsfmt_unimplemented("#23.107 data_size_format_at")
}
