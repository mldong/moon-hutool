///|
// moon-hutool/csv —— CSV 的读（解析）与写（序列化）
// 对位 hutool `cn.hutool.core.text.csv.{CsvReader,CsvBaseReader,CsvParser,CsvRow,CsvData,CsvWriter,CsvReadConfig,CsvWriteConfig}`。
// **件在 hutool-core**：`unzip -l hutool-core.jar | grep -c csv` 现读 **14 条**——与 `dfa`/`cache`/`bloom`/`cron`
// 四格不同，这一格**不用另拉 artifact**。
// 契约真相在 `docs/spec/21-csv.md`；本文件是签名骨架——函数体是 abort，落地笔（PR-B）替换。
//
// 一句话口径：默认**不认表头**（参照 `headerLineNo` 初值 -1）、默认**跳过空行但行号照推**、
// 注释符只在行首生效、引号要整包裹才剥（`a"b` 与 `"a"x` 原样留引号）、引号内两写 `""` 出一个 `"`、
// 字段只剥首尾 CR/LF 不剥空白（`trim_field` 才剥）、列数不等默认不报错（开关打开走 `UnevenFields`）；
// 写侧只在该字段含引号/分隔符/换行时加引号并把内部引号翻倍、`always_delimit_text` 时每个字段都加，
// null 档默认写空串、在该开关下写 `""`、行分隔符默认 CRLF、`ending_line_break` 控制末尾。
//
// **零 IO**：参照的 `File`/`Path`/`Reader`/`Writer`/`Charset`/`InputStream` 那批入口、`CsvUtil.load/read/write`
// 与 `writeBeans`/`toBean` 一律不收——本库全同步、零依赖、不引反射（spec §1、§5 第 6/7 行）。
// 参照 5.8.35 的写方法名是 `writeLine(String...)`，**没有 `writeRow`**（那是 hutool 6 的命名）。

///|
/// #21.1 解析错误面。参照侧只有一条实测可复现的读失败：`error_on_different_field_count` 打开且行列数
/// 与首行不等 ⇒ `IORuntimeException:Line 1 has 1 fields, but first line has 2 fields`。
/// 本库带**行号 / 本行列数 / 首行列数**三个读数，不复制 Java 文案（spec §5 第 3 行）
pub suberror CsvError {
  UnevenFields(Int, Int, Int)
}

///|
/// #21.2 读配置。默认值与参照 `CsvReadConfig.defaultConfig()` 逐字段对齐（源码字段初值现读）：
/// `,` 分隔、`"` 包裹、`#` 注释、`header_line_no = -1`（不认表头）、`begin_line_no = 0`、
/// `end_line_no = -1`（**本库哨兵**——参照是 `Long.MAX_VALUE - 1`，见 spec §5 第 1 行）、
/// `skip_empty_rows = true`、`trim_field = false`、`error_on_different_field_count = false`、空别名表。
///
/// - Note: 参照的 `headerAlias` 是 `Map<String,String>`，本库用 `Array[(String, String)]` 保序——
///   实测两个原名映到同名时表头只留第一次出现的那列（腿 `r.*.11`）
pub(all) struct CsvReadOpts {
  delimiter : Char
  quote : Char
  comment : Char?
  header_line_no : Int
  begin_line_no : Int
  end_line_no : Int
  skip_empty_rows : Bool
  trim_field : Bool
  error_on_different_field_count : Bool
  header_alias : Array[(String, String)]
}

///|
/// #21.3 写配置。默认值对齐参照 `CsvWriteConfig.defaultConfig()`：`,` 分隔、`"` 包裹、
/// `always_delimit_text = false`、行分隔符 `"\r\n"`、`ending_line_break = false`
pub(all) struct CsvWriteOpts {
  delimiter : Char
  quote : Char
  always_delimit_text : Bool
  line_delimiter : String
  ending_line_break : Bool
}

///|
/// 一行的写入形状：`None` 对位参照的 null 档（默认写成空串，`always_delimit_text` 下写成 `""`，
/// 腿读数 `w.6.0` 对 `w.6.1`）
pub type CsvLine = Array[String?]

///|
/// #21.4 一行。`line_no` 是参照 `CsvRow.getOriginalLineNumber()` 的读数（从 0 起，
/// 注释行与被跳过的空行都会把号推上去：`a,b\n\nc,d` 默认给行号 0 与 2）
pub(all) struct CsvRow {
  line_no : Int
  fields : Array[String]
}

///|
/// #21.5 整份数据。`header` 在未开表头时是**空数组**（参照侧此时 `getHeader()` 抛
/// `IllegalStateException`，本库不出异常，spec §5 第 2 行）；`rows` **不含表头行**
pub(all) struct CsvData {
  header : Array[String]
  rows : Array[CsvRow]
}

///|
/// 默认读配置（与参照 `defaultConfig()` 同值）
pub fn csv_default_read_opts() -> CsvReadOpts {
  abort("moon-hutool csv: 契约已冻结，实现待落地")
}

///|
/// 默认写配置（与参照 `defaultConfig()` 同值）
pub fn csv_default_write_opts() -> CsvWriteOpts {
  abort("moon-hutool csv: 契约已冻结，实现待落地")
}

///|
/// 解析整段 CSV 文本（默认配置 = 不认表头、跳过空行、逗号、双引号、`#` 注释）
///
/// - Raises: `CsvError.UnevenFields` —— 仅在 `error_on_different_field_count` 打开且列数不等时
pub fn csv_parse(text : String) -> CsvData raise CsvError {
  abort("moon-hutool csv: 契约已冻结，实现待落地")
}

///|
/// 按给定配置解析
pub fn csv_parse_with_opts(
  text : String,
  opts : CsvReadOpts,
) -> CsvData raise CsvError {
  abort("moon-hutool csv: 契约已冻结，实现待落地")
}

///|
/// 把若干行写成 CSV 文本（默认配置：CRLF 行分隔、末尾不加换行、按需加引号）
pub fn csv_write(rows : Array[CsvLine]) -> String {
  abort("moon-hutool csv: 契约已冻结，实现待落地")
}

///|
/// 按给定配置写
pub fn csv_write_with_opts(
  rows : Array[CsvLine],
  opts : CsvWriteOpts,
) -> String {
  abort("moon-hutool csv: 契约已冻结，实现待落地")
}

///|
/// 按列下标取值，越界给 `None`（参照是 `List<String>.get`，越界抛 `IndexOutOfBoundsException`，
/// spec §5 第 4 行）
pub fn CsvRow::get(self : CsvRow, index : Int) -> String? {
  abort("moon-hutool csv: 契约已冻结，实现待落地")
}

///|
/// 列数（参照 `CsvRow.getFieldCount()` / `size()`）
pub fn CsvRow::field_count(self : CsvRow) -> Int {
  abort("moon-hutool csv: 契约已冻结，实现待落地")
}

///|
/// 按表头名取值；未开表头或名不存在给 `None`（参照 `getByName` 在未开表头时的 headerMap 是 null，
/// spec §5 第 5 行）
pub fn CsvRow::get_by_name(self : CsvRow, name : String) -> String? {
  abort("moon-hutool csv: 契约已冻结，实现待落地")
}

///|
/// 行数（不含表头行；参照 `CsvData.getRowCount()`）
pub fn CsvData::row_count(self : CsvData) -> Int {
  abort("moon-hutool csv: 契约已冻结，实现待落地")
}

///|
/// 取第 n 行，越界给 `None`（参照 `CsvData.getRow(index)` 越界抛 `IndexOutOfBoundsException`）
pub fn CsvData::get_row(self : CsvData, index : Int) -> CsvRow? {
  abort("moon-hutool csv: 契约已冻结，实现待落地")
}

///|
/// 表头列名数组；未开表头是空数组
pub fn CsvData::header_names(self : CsvData) -> Array[String] {
  abort("moon-hutool csv: 契约已冻结，实现待落地")
}
