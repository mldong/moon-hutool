///|
// csv 默认档补档（10-08）——`csv_parse` / `CsvRow::field_count` / `get` / `get_row` 这四件
// 此前一条用例都没打到（既有测试全走 `_with_opts` 那一支），本批按默认配置逐档对撞。
// 期望全部由 Csv2Leg.java 现读灌入（hutool-core 5.8.35 · JDK 17.0.14），手打零条。
// 夹具里的换行/回车用 0xNN 码点序列承载，生成器按同一序列还原成 MoonBit 字面量。
// 越界档：参照抛 `IndexOutOfBoundsException`，本库给 `None`（spec 21-csv §5 第 4 行已声明），
// 因此钉本库形状并把参照原读数留在注释里。

///|
fn c2_opts(skip : Bool) -> @csv.CsvReadOpts {
  {
    delimiter: ',',
    quote: '"',
    comment: Some('#'),
    header_line_no: -1,
    begin_line_no: 0,
    end_line_no: -1,
    skip_empty_rows: skip,
    trim_field: false,
    error_on_different_field_count: false,
    header_alias: [],
  }
}

///|
fn c2_ascii(s : String) -> String {
  let mut out = ""
  for ch in s.to_array() {
    out = match ch {
      '\r' => out + "{CR}"
      '\n' => out + "{LF}"
      '"' => out + "{DQ}"
      _ => out + ch.to_string()
    }
  }
  out
}

///|
fn c2_dump(data : @csv.CsvData) -> String {
  let n = data.row_count()
  let mut s = "rows=" + n.to_string()
  let mut i = 0
  while i < n {
    let row = match data.get_row(i) {
      Some(r) => r
      None => return s + " | MISSING"
    }
    let k = row.field_count()
    s = s + " | r" + i.to_string() + " n=" + k.to_string() + " ["
    let mut first = true
    for j in 0..<k {
      if !first {
        s = s + ","
      }
      first = false
      s = s +
        c2_ascii(
          match row.get(j) {
            Some(v) => v
            None => "<none>"
          },
        )
    }
    s = s + "]"
    i += 1
  }
  s
}

///|
fn c2_parse(text : String) -> String {
  // 参照的 defaultConfig() 是 skipEmptyRows=false，而本库默认档是 true ⇒
  // RD 族要对撞参照就得显式把 skip 关掉；本库默认档的对撞在 RS 族那组
  c2_dump(@csv.csv_parse_with_opts(text, c2_opts(false))) catch {
    _ => "ERR"
  }
}

///|
fn c2_parse_skip(text : String) -> String {
  // 本库默认档（skip=true）走 csv_parse——这件此前一条用例都没打到
  c2_dump(@csv.csv_parse(text)) catch {
    _ => "ERR"
  }
}

///|
fn c2_oob(text : String) -> String {
  try {
    let data = @csv.csv_parse(text)
    let n = data.row_count()
    let r0 = match data.get_row(0) {
      Some(x) => x
      None => return "no-row"
    }
    let f = r0.field_count()
    let a1 = "row[-1]=" + show_row(data.get_row(-1))
    let a2 = " row[n]=" + show_row(data.get_row(n))
    let a3 = " field[-1]=" + show_field(r0.get(-1))
    let a4 = " field[n]=" + show_field(r0.get(f))
    a1 + a2 + a3 + a4
  } catch {
    _ => "ERR"
  }
}

///|
fn show_row(r : @csv.CsvRow?) -> String {
  match r {
    None => "None"
    Some(_) => "Some"
  }
}

///|
fn show_field(s : String?) -> String {
  match s {
    None => "None"
    Some(_) => "Some"
  }
}

///|
test "csv 默认档 parse-plain" {
  // csv_parse_with_opts(skip=false) ｜ 码点=61+2c+62+2c+63+a+31+2c+32+2c+33+a ｜ 参照=rows=2 | r0 n=3 [a,b,c] | r1 n=3 [1,2,3]
  assert_eq(
    c2_parse("a,b,c\u{a}1,2,3\u{a}"),
    "rows=2 | r0 n=3 [a,b,c] | r1 n=3 [1,2,3]",
  )
}

///|
test "csv 默认档 skip-plain" {
  // csv_parse（本库默认档 skip=true）｜ 码点=61+2c+62+2c+63+a+31+2c+32+2c+33+a ｜ 参照 skipEmptyRows=true=rows=2 | r0 n=3 [a,b,c] | r1 n=3 [1,2,3]
  assert_eq(
    c2_parse_skip("a,b,c\u{a}1,2,3\u{a}"),
    "rows=2 | r0 n=3 [a,b,c] | r1 n=3 [1,2,3]",
  )
}

///|
test "csv 默认档 parse-quoted_multiline" {
  // csv_parse_with_opts(skip=false) ｜ 码点=61+2c+22+62+a+63+22+2c+64+a ｜ 参照=rows=1 | r0 n=3 [a,b{LF}c,d]
  assert_eq(
    c2_parse("a,\u{22}b\u{a}c\u{22},d\u{a}"),
    "rows=1 | r0 n=3 [a,b{LF}c,d]",
  )
}

///|
test "csv 默认档 skip-quoted_multiline" {
  // csv_parse（本库默认档 skip=true）｜ 码点=61+2c+22+62+a+63+22+2c+64+a ｜ 参照 skipEmptyRows=true=rows=1 | r0 n=3 [a,b{LF}c,d]
  assert_eq(
    c2_parse_skip("a,\u{22}b\u{a}c\u{22},d\u{a}"),
    "rows=1 | r0 n=3 [a,b{LF}c,d]",
  )
}

///|
test "csv 默认档 parse-leading_blank_line" {
  // csv_parse_with_opts(skip=false) ｜ 码点=a+61+2c+62+a ｜ 参照=rows=2 | r0 n=1 [] | r1 n=2 [a,b]
  assert_eq(c2_parse("\u{a}a,b\u{a}"), "rows=2 | r0 n=1 [] | r1 n=2 [a,b]")
}

///|
test "csv 默认档 skip-leading_blank_line" {
  // csv_parse（本库默认档 skip=true）｜ 码点=a+61+2c+62+a ｜ 参照 skipEmptyRows=true=rows=1 | r0 n=2 [a,b]
  assert_eq(c2_parse_skip("\u{a}a,b\u{a}"), "rows=1 | r0 n=2 [a,b]")
}

///|
test "csv 默认档 parse-trailing_crlf" {
  // csv_parse_with_opts(skip=false) ｜ 码点=61+2c+62+d+a ｜ 参照=rows=1 | r0 n=2 [a,b]
  assert_eq(c2_parse("a,b\u{d}\u{a}"), "rows=1 | r0 n=2 [a,b]")
}

///|
test "csv 默认档 skip-trailing_crlf" {
  // csv_parse（本库默认档 skip=true）｜ 码点=61+2c+62+d+a ｜ 参照 skipEmptyRows=true=rows=1 | r0 n=2 [a,b]
  assert_eq(c2_parse_skip("a,b\u{d}\u{a}"), "rows=1 | r0 n=2 [a,b]")
}

///|
test "csv 默认档 parse-crlf_only_sep" {
  // csv_parse_with_opts(skip=false) ｜ 码点=61+2c+62+d+a+63+2c+64+d+a ｜ 参照=rows=2 | r0 n=2 [a,b] | r1 n=2 [c,d]
  assert_eq(
    c2_parse("a,b\u{d}\u{a}c,d\u{d}\u{a}"),
    "rows=2 | r0 n=2 [a,b] | r1 n=2 [c,d]",
  )
}

///|
test "csv 默认档 skip-crlf_only_sep" {
  // csv_parse（本库默认档 skip=true）｜ 码点=61+2c+62+d+a+63+2c+64+d+a ｜ 参照 skipEmptyRows=true=rows=2 | r0 n=2 [a,b] | r1 n=2 [c,d]
  assert_eq(
    c2_parse_skip("a,b\u{d}\u{a}c,d\u{d}\u{a}"),
    "rows=2 | r0 n=2 [a,b] | r1 n=2 [c,d]",
  )
}

///|
test "csv 默认档 parse-skip_empty" {
  // csv_parse_with_opts(skip=false) ｜ 码点=61+2c+62+a+a+63+2c+64+a ｜ 参照=rows=3 | r0 n=2 [a,b] | r1 n=1 [] | r2 n=2 [c,d]
  assert_eq(
    c2_parse("a,b\u{a}\u{a}c,d\u{a}"),
    "rows=3 | r0 n=2 [a,b] | r1 n=1 [] | r2 n=2 [c,d]",
  )
}

///|
test "csv 默认档 skip-skip_empty" {
  // csv_parse（本库默认档 skip=true）｜ 码点=61+2c+62+a+a+63+2c+64+a ｜ 参照 skipEmptyRows=true=rows=2 | r0 n=2 [a,b] | r1 n=2 [c,d]
  assert_eq(
    c2_parse_skip("a,b\u{a}\u{a}c,d\u{a}"),
    "rows=2 | r0 n=2 [a,b] | r1 n=2 [c,d]",
  )
}

///|
test "csv 默认档 parse-uneven" {
  // csv_parse_with_opts(skip=false) ｜ 码点=61+2c+62+2c+63+a+31+2c+32+a ｜ 参照=rows=2 | r0 n=3 [a,b,c] | r1 n=2 [1,2]
  assert_eq(
    c2_parse("a,b,c\u{a}1,2\u{a}"),
    "rows=2 | r0 n=3 [a,b,c] | r1 n=2 [1,2]",
  )
}

///|
test "csv 默认档 skip-uneven" {
  // csv_parse（本库默认档 skip=true）｜ 码点=61+2c+62+2c+63+a+31+2c+32+a ｜ 参照 skipEmptyRows=true=rows=2 | r0 n=3 [a,b,c] | r1 n=2 [1,2]
  assert_eq(
    c2_parse_skip("a,b,c\u{a}1,2\u{a}"),
    "rows=2 | r0 n=3 [a,b,c] | r1 n=2 [1,2]",
  )
}

///|
test "csv 默认档 parse-only_newlines" {
  // csv_parse_with_opts(skip=false) ｜ 码点=a+a ｜ 参照=rows=2 | r0 n=1 [] | r1 n=1 []
  assert_eq(c2_parse("\u{a}\u{a}"), "rows=2 | r0 n=1 [] | r1 n=1 []")
}

///|
test "csv 默认档 skip-only_newlines" {
  // csv_parse（本库默认档 skip=true）｜ 码点=a+a ｜ 参照 skipEmptyRows=true=rows=0
  assert_eq(c2_parse_skip("\u{a}\u{a}"), "rows=0")
}

///|
test "csv 默认档 oob-plain" {
  // 越界档 ｜ 码点=61+2c+62+2c+63+a+31+2c+32+2c+33+a ｜ 参照=row[-1]=ERR:IndexOutOfBoundsException row[n]=ERR:IndexOutOfBoundsException field[-1]=ERR:IndexOutOfBoundsException field[n]=null（本库给 None，spec 21-csv §5 第 4 行已声明）
  assert_eq(
    c2_oob("a,b,c\u{a}1,2,3\u{a}"),
    "row[-1]=None row[n]=None field[-1]=None field[n]=None",
  )
}

///|
test "csv 默认档 oob-quoted_multiline" {
  // 越界档 ｜ 码点=61+2c+22+62+a+63+22+2c+64+a ｜ 参照=row[-1]=ERR:IndexOutOfBoundsException row[n]=ERR:IndexOutOfBoundsException field[-1]=ERR:IndexOutOfBoundsException field[n]=null（本库给 None，spec 21-csv §5 第 4 行已声明）
  assert_eq(
    c2_oob("a,\u{22}b\u{a}c\u{22},d\u{a}"),
    "row[-1]=None row[n]=None field[-1]=None field[n]=None",
  )
}
