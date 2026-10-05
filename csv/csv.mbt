///|
// moon-hutool/csv —— CSV 的读（解析）与写（序列化）
// 对位 hutool `cn.hutool.core.text.csv.{CsvReader,CsvBaseReader,CsvParser,CsvRow,CsvData,CsvWriter,CsvReadConfig,CsvWriteConfig}`。
// **件在 hutool-core**：`unzip -l hutool-core.jar | grep -c csv` 现读 **14 条**——与 `dfa`/`cache`/`bloom`/`cron`
// 四格不同，这一格**不用另拉 artifact**。
// 契约真相在 `docs/spec/21-csv.md`；期望值全部来自参照腿读数（标签在 `csv/csv_test.mbt` 每条断言行尾）。
//
// 一句话口径：默认**不认表头**（参照 `headerLineNo` 初值 -1）、默认**跳过空行但行号照推**、
// 注释符只在行首生效、引号要整包裹才剥（`a"b` 与 `"a"x` 原样留引号）、引号内两写 `""` 出一个 `"`、
// 字段只剥首尾 CR/LF 不剥空白（`trim_field` 才剥）、列数不等默认不报错（开关打开走 `UnevenFields`）；
// 写侧只在该字段含引号/分隔符/换行时加引号并把内部引号翻倍、`always_delimit_text` 时每个字段都加，
// null 档默认写空串、在该开关下写 `""`、行分隔符默认 CRLF、`ending_line_break` 控制末尾。
//
// **零 IO**：参照的 `File`/`Path`/`Reader`/`Writer`/`Charset`/`InputStream` 那批入口、`CsvUtil.load/read/write`
// 与 `writeBeans`/`toBean` 一律不收（spec §1、§5 第 6/7 行）。
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
/// 注释行与被跳过的空行都会把号推上去：`a,b\n\nc,d` 默认给行号 0 与 2）。
/// `hdr` 是表头名到列下标的映射，对本包外不可见——参照把 headerMap 塞进每个 CsvRow，本库同形
/// （否则 `get_by_name` 无从查起）
pub(all) struct CsvRow {
  line_no : Int
  fields : Array[String]
  priv hdr : Array[(String, Int)]
}

///|
/// #21.5 整份数据。`header` 在未开表头时是**空数组**（参照侧此时 `getHeader()` 抛
/// `IllegalStateException`，本库不出异常，spec §5 第 2 行）；`rows` **不含表头行**
pub(all) struct CsvData {
  header : Array[String]
  rows : Array[CsvRow]
}

///|
let cr : Int = 13

///|
let lf : Int = 10

///|
/// 默认读配置（与参照 `defaultConfig()` 同值）
pub fn csv_default_read_opts() -> CsvReadOpts {
  {
    delimiter: ',',
    quote: '"',
    comment: Some('#'),
    header_line_no: -1,
    begin_line_no: 0,
    end_line_no: -1,
    skip_empty_rows: true,
    trim_field: false,
    error_on_different_field_count: false,
    header_alias: [],
  }
}

///|
/// 默认写配置（与参照 `defaultConfig()` 同值）
pub fn csv_default_write_opts() -> CsvWriteOpts {
  {
    delimiter: ',',
    quote: '"',
    always_delimit_text: false,
    line_delimiter: "\r\n",
    ending_line_break: false,
  }
}

///|
/// 解析整段 CSV 文本（默认配置 = 不认表头、跳过空行、逗号、双引号、`#` 注释）
///
/// - Raises: `CsvError.UnevenFields` —— 仅在 `error_on_different_field_count` 打开且列数不等时
pub fn csv_parse(text : String) -> CsvData raise CsvError {
  csv_parse_with_opts(text, csv_default_read_opts())
}

///|
/// 按给定配置解析
pub fn csv_parse_with_opts(
  text : String,
  opts : CsvReadOpts,
) -> CsvData raise CsvError {
  let st = {
    src: text.to_array(),
    o: opts,
    pos: 0,
    eof: false,
    pre: -1,
    inq: false,
    line_no: -1,
    q_lines: 0,
    max_fc: 0,
    first_fc: -1,
    done: false,
    header: [],
    hdr: false,
    map: [],
  }
  let rows : Array[CsvRow] = []
  while !st.done {
    let fields = read_line(st)
    if fields.length() < 1 {
      break
    }
    if st.line_no < st.o.begin_line_no {
      continue
    }
    if st.o.end_line_no >= 0 && st.line_no > st.o.end_line_no {
      break
    }
    // 多行条件在本版是解析错（Unexpected line break here, missing `{`）⇒ 先落一个具名 bool
    let empty_row = st.o.skip_empty_rows &&
      fields.length() == 1 &&
      fields[0].to_array().length() == 0
    if empty_row {
      continue
    }
    if st.o.error_on_different_field_count {
      if st.first_fc < 0 {
        st.first_fc = fields.length()
      } else if fields.length() != st.first_fc {
        raise UnevenFields(st.line_no, fields.length(), st.first_fc)
      }
    }
    if fields.length() > st.max_fc {
      st.max_fc = fields.length()
    }
    if st.line_no == st.o.header_line_no && !st.hdr {
      init_header(st, fields)
      continue
    }
    rows.push({ line_no: st.line_no, fields, hdr: st.map, })
  }
  { header: st.header, rows, }
}

///|
/// 把若干行写成 CSV 文本（默认配置：CRLF 行分隔、末尾不加换行、按需加引号）
pub fn csv_write(rows : Array[CsvLine]) -> String {
  csv_write_with_opts(rows, csv_default_write_opts())
}

///|
/// 按给定配置写
pub fn csv_write_with_opts(
  rows : Array[CsvLine],
  opts : CsvWriteOpts,
) -> String {
  // 参照把行分隔符写在**两行之间**（最后一行后面不写，除非 ending_line_break）：
  // 腿 `w.*.0`（无尾）对 `w.*.3`（有尾）
  let mut out = ""
  let mut first_row = true
  for r in rows {
    if !first_row {
      out = out + opts.line_delimiter
    }
    first_row = false
    let mut first_field = true
    for f in r {
      if !first_field {
        out = out + opts.delimiter.to_string()
      }
      first_field = false
      out = out + field_text(f, opts)
    }
  }
  if opts.ending_line_break && rows.length() > 0 {
    out = out + opts.line_delimiter
  }
  out
}

///|
/// 按列下标取值，越界给 `None`（参照是 `List<String>.get`，越界抛 `IndexOutOfBoundsException`，
/// spec §5 第 4 行）
pub fn CsvRow::get(self : CsvRow, index : Int) -> String? {
  if index >= 0 && index < self.fields.length() {
    Some(self.fields[index])
  } else {
    None
  }
}

///|
/// 列数（参照 `CsvRow.getFieldCount()` / `size()`）
pub fn CsvRow::field_count(self : CsvRow) -> Int {
  self.fields.length()
}

///|
/// 按表头名取值；未开表头或名不存在给 `None`（参照 `getByName` 在未开表头时的 headerMap 是 null，
/// spec §5 第 5 行）
pub fn CsvRow::get_by_name(self : CsvRow, name : String) -> String? {
  let mut idx = -1
  for kv in self.hdr {
    if kv.0 == name {
      idx = kv.1
      break
    }
  }
  if idx < 0 {
    None
  } else {
    self.get(idx)
  }
}

///|
/// 行数（不含表头行；参照 `CsvData.getRowCount()`）
pub fn CsvData::row_count(self : CsvData) -> Int {
  self.rows.length()
}

///|
/// 取第 n 行，越界给 `None`（参照 `CsvData.getRow(index)` 越界抛 `IndexOutOfBoundsException`）
pub fn CsvData::get_row(self : CsvData, index : Int) -> CsvRow? {
  if index >= 0 && index < self.rows.length() {
    Some(self.rows[index])
  } else {
    None
  }
}

///|
/// 表头列名数组；未开表头是空数组
pub fn CsvData::header_names(self : CsvData) -> Array[String] {
  self.header
}

///|
// ---------- 内部：解析状态机（逐步对位参照 CsvParser.readLine / addField / initHeader） ----------

priv struct PS {
  src : Array[Char]
  o : CsvReadOpts
  mut pos : Int
  mut eof : Bool
  mut pre : Int
  mut inq : Bool
  mut line_no : Int
  mut q_lines : Int
  mut max_fc : Int
  mut first_fc : Int
  mut done : Bool
  mut header : Array[String]
  mut hdr : Bool
  mut map : Array[(String, Int)]
}

///|
fn tok_next(st : PS) -> Int {
  // 参照 CsvTokener：一旦读到 EOF 就**停在 EOF**——peek 落空之后 back() 不能让最后一个字符复活，
  // 否则 `"a","b"` 的收尾引号会被读两次，多出一个引号（腿 r.5.* 给的是 a/b）
  if st.eof || st.pos >= st.src.length() {
    st.eof = true
    -1
  } else {
    let c = st.src[st.pos].to_int()
    st.pos += 1
    c
  }
}

///|
fn tok_back(st : PS) -> Unit {
  // 参照 CsvTokener.back()：只退一格，且 EOF 之后不退
  if !st.eof && st.pos > 0 {
    st.pos -= 1
  }
}

///|
fn is_line_end(c : Int, pre : Int) -> Bool {
  // 参照原文：`(c == CR || c == LF) && preChar != CR`
  (c == cr || c == lf) && pre != cr
}

///|
fn is_field_begin(pre : Int, sep : Int) -> Bool {
  // 参照：行首、分隔符之后、LF 之后、CR 之后才算"字段起点"
  pre < 0 || pre == sep || pre == lf || pre == cr
}

///|
// 参照 StrUtil.trim(str, 1, c -> c == LF || c == CR)：首尾各**至多一个**换行符
fn strip_edge_newlines(cs : Array[Char]) -> Array[Char] {
  let mut lo = 0
  let mut hi = cs.length()
  if lo < hi && (cs[lo] == '\n' || cs[lo] == '\r') {
    lo += 1
  }
  if hi > lo && (cs[hi - 1] == '\n' || cs[hi - 1] == '\r') {
    hi -= 1
  }
  String::from_array(cs[lo:hi]).to_array()
}

///|
// 参照 StrUtil.trim(str)（空白全剥）——本库不依赖 String.trim 的 StringView 出口
fn ws_trim(cs : Array[Char]) -> Array[Char] {
  let mut lo = 0
  let mut hi = cs.length()
  while lo < hi && cs[lo].is_whitespace() {
    lo += 1
  }
  while hi > lo && cs[hi - 1].is_whitespace() {
    hi -= 1
  }
  String::from_array(cs[lo:hi]).to_array()
}

///|
// 参照 addField：剥首尾 CR/LF ⇒ 整包裹才剥引号 ⇒ 按开关剥空白
fn add_field(st : PS, out : Array[String], raw : Array[Char]) -> Unit {
  let q = st.o.quote.to_int()
  let mut cs = strip_edge_newlines(raw)
  let wrapped = cs.length() >= 2 &&
    cs[0].to_int() == q &&
    cs[cs.length() - 1].to_int() == q
  if wrapped {
    cs = String::from_array(cs[1:cs.length() - 1]).to_array()
  }
  if st.o.trim_field {
    cs = ws_trim(cs)
  }
  out.push(String::from_array(cs))
}

///|
// 参照 readLine 的状态机。三处最容易写错的细节：
// ① 注释分支走 continue，**不更新 preChar** ⇒ 整行被吞；
// ② 引号内的字符一律入缓冲（含包裹用的引号本身，留给 add_field 判"整包裹"）；
// ③ 引号两写塌成一写——腿 `r.7.0` 给的是 `a"b` 而不是 `a""b`。
fn read_line(st : PS) -> Array[String] {
  if st.q_lines > 0 {
    st.line_no += st.q_lines
    st.q_lines = 0
  }
  let out : Array[String] = []
  let buf : Array[Char] = []
  let o = st.o
  let sep = o.delimiter.to_int()
  let q = o.quote.to_int()
  let mut pre = st.pre
  let mut in_comment = false
  let mut go = true
  while go {
    let c = tok_next(st)
    if c < 0 {
      if buf.length() > 0 || pre == sep {
        if st.inq {
          buf.push(o.quote)
        }
        add_field(st, out, buf)
      }
      st.done = true
      go = false
    } else {
      if (pre < 0 || pre == cr || pre == lf) && !st.inq {
        match o.comment {
          Some(cc) => if c == cc.to_int() { in_comment = true }
          None => ()
        }
      }
      if in_comment {
        if c == cr || c == lf {
          st.line_no += 1
          in_comment = false
        }
      } else if st.inq {
        let mut pair = false
        if c == q {
          let n = tok_next(st)
          if n != q {
            st.inq = false
            tok_back(st)
          } else {
            // 两写塌成一写：只入一个引号，且**不再入本字符**（腿 r.7.* 给 `a"b`）
            pair = true
            buf.push(o.quote)
          }
        } else if is_line_end(c, pre) {
          st.q_lines += 1
        }
        if !pair {
          buf.push(c.unsafe_to_char())
        }
      } else if c == sep {
        add_field(st, out, buf)
        buf.clear()
      } else if c == q && is_field_begin(pre, sep) {
        st.inq = true
        buf.push(o.quote)
      } else if c == cr {
        add_field(st, out, buf)
        buf.clear()
        pre = c
        go = false
      } else if c == lf {
        if pre != cr {
          add_field(st, out, buf)
          buf.clear()
          pre = c
          go = false
        }
      } else {
        buf.push(c.unsafe_to_char())
      }
      if go {
        pre = c
      }
    }
  }
  st.pre = pre
  st.line_no += 1
  out
}

///|
// 参照 initHeader：先过别名表；空名与重名列都不进映射
fn init_header(st : PS, fields : Array[String]) -> Unit {
  let map : Array[(String, Int)] = []
  let names : Array[String] = []
  for i = 0; i < fields.length(); i = i + 1 {
    let mut field = fields[i]
    for kv in st.o.header_alias {
      if kv.0 == field {
        field = kv.1
        break
      }
    }
    names.push(fields[i])
    let mut exists = false
    for kv in map {
      if kv.0 == field {
        exists = true
        break
      }
    }
    if field.to_array().length() > 0 && !exists {
      map.push((field, i))
    }
  }
  st.header = names
  st.map = map
  st.hdr = true
}

///|
// 参照 appendField：null 档只在 always_delimit_text 下出 `""`；
// 含引号/分隔符/CR/LF 才包裹，包裹时内部引号翻倍（腿 `w.2.*`）
fn field_text(v : String?, o : CsvWriteOpts) -> String {
  let qs = o.quote.to_string()
  match v {
    None => if o.always_delimit_text { qs + qs } else { "" }
    Some(s) => {
      let cs = s.to_array()
      let mut needs = o.always_delimit_text
      let mut has_quote = false
      for c in cs {
        if c == o.quote {
          has_quote = true
          needs = true
          break
        } else if c == o.delimiter || c == '\n' || c == '\r' {
          needs = true
        }
      }
      let mut body = ""
      for c in cs {
        if has_quote && c == o.quote {
          body = body + qs
        }
        body = body + c.to_string()
      }
      if needs {
        qs + body + qs
      } else {
        body
      }
    }
  }
}
