///|
// csv 第一批的期望值全部由生成脚本从参照腿灌入（手打零条）。
// 腿：真 hutool-core-5.8.35.jar（**件在 core**：`unzip -l` 现读 14 条 csv class）+ JDK 17.0.14，
//   javac -encoding UTF-8，468 行读数（32 输入 x 12 档读配置 + 12 行集 x 7 档写配置）。
// 参照的读写入口全是 IO（File/Path/Reader/Writer/Charset），腿用 StringReader/StringWriter 取读数，
//   本库公开面**只收 String**（spec §1 边界）；参照 5.8.35 的写方法名是 `writeLine`，没有 `writeRow`。
// 异常档的映射表在 spec §5：Java 的消息模板不进契约，只钉"哪一档、哪一行、哪几个读数"。

///|
// 与腿逐字同形的转义：CR/LF/引号/反斜杠各写成两字符的转义串，其余原样
fn esc(s : String) -> String {
  let mut out = ""
  for c in s.to_array() {
    if c == '\r' {
      out = out + "\\r"
    } else if c == '\n' {
      out = out + "\\n"
    } else if c == '"' {
      out = out + "\\\""
    } else if c == '\\' {
      out = out + "\\\\"
    } else {
      out = out + c.to_string()
    }
  }
  out
}

///|
fn tag(e : @csv.CsvError) -> String {
  match e {
    @csv.UnevenFields(l, n, f) =>
      "UnevenFields[" +
      l.to_string() +
      "," +
      n.to_string() +
      "," +
      f.to_string() +
      "]"
  }
}

///|
// 读数形状与腿逐字段对齐：hdr=<none>|a|b;[行号]字段/字段/;...nrows=k[;byName=v]
fn rd_tag(text : String, o : @csv.CsvReadOpts) -> String {
  try {
    let d = @csv.csv_parse_with_opts(text, o)
    let hs = d.header_names()
    let mut out = "hdr="
    if hs.length() == 0 {
      out = out + "<none>"
    } else {
      let mut first = true
      for h in hs {
        if !first {
          out = out + "|"
        }
        first = false
        out = out + esc(h)
      }
    }
    out = out + ";"
    for r in d.rows {
      out = out + "[" + r.line_no.to_string() + "]"
      for f in r.fields {
        out = out + esc(f) + "/"
      }
      out = out + ";"
    }
    out = out + "nrows=" + d.row_count().to_string()
    if hs.length() > 0 && d.row_count() > 0 {
      let by = match d.rows[0].get_by_name(hs[0]) {
        Some(v) => esc(v)
        None => "<null>"
      }
      out = out + ";byName=" + by
    }
    "OK:" + out
  } catch {
    e => tag(e)
  }
}

///|
fn wr_tag(rows : Array[@csv.CsvLine], o : @csv.CsvWriteOpts) -> String {
  "OK:" + esc(@csv.csv_write_with_opts(rows, o))
}

///|
// 读配置 12 档：与腿 cfg(i) 逐字段同值（这些是"喂给参照的输入"，不是期望值）。
// 本版不接受记录更新语法 `{ base with x = 1 }`（实测 Parse error: unexpected token `with`）
// ⇒ 逐字段照抄默认值，只改这一档要改的那个
fn rcfg(i : Int) -> @csv.CsvReadOpts {
  let b = @csv.csv_default_read_opts()
  let delimiter = if i == 8 { ';' } else { b.delimiter }
  let quote = if i == 9 { '\u{0027}' } else { b.quote }
  let comment = if i == 10 { Some('%') } else { b.comment }
  let header_line_no = if i == 1 || i == 11 {
    0
  } else if i == 4 {
    1
  } else {
    b.header_line_no
  }
  let begin_line_no = if i == 5 { 1 } else { b.begin_line_no }
  let end_line_no = if i == 6 { 0 } else { b.end_line_no }
  let skip_empty_rows = if i == 2 { false } else { b.skip_empty_rows }
  let trim_field = if i == 3 { true } else { b.trim_field }
  let uneven = if i == 7 { true } else { b.error_on_different_field_count }
  let halias = if i == 11 {
    [("h1", "H1"), ("h2", "H1")]
  } else {
    b.header_alias
  }
  {
    delimiter,
    quote,
    comment,
    header_line_no,
    begin_line_no,
    end_line_no,
    skip_empty_rows,
    trim_field,
    error_on_different_field_count: uneven,
    header_alias: halias,
  }
}

///|
// 写配置 7 档：与腿 wcfg(i) 逐字段同值
fn wopts(i : Int) -> @csv.CsvWriteOpts {
  let b = @csv.csv_default_write_opts()
  let delimiter = if i == 4 { ';' } else { b.delimiter }
  let quote = if i == 5 { '\u{0027}' } else { b.quote }
  let always = if i == 1 || i == 6 { true } else { b.always_delimit_text }
  let ld = if i == 2 || i == 6 { "\n" } else { b.line_delimiter }
  let elb = if i == 3 || i == 6 { true } else { b.ending_line_break }
  {
    delimiter,
    quote,
    always_delimit_text: always,
    line_delimiter: ld,
    ending_line_break: elb,
  }
}

///|
// 写侧 12 个行集：与腿 ROWSETS 逐格同值（这是"喂给参照的输入"，不是期望值）。
// 腿每档都连写两行——夹具行 + 固定的 `z1,z2` 行（行分隔符只有两行才看得见），这里同形。
// `None` 对位参照的 null 档（腿读数 `w.6.0` 出 `,b`、`w.6.1` 出 `"","b"`）
fn wrow(i : Int) -> Array[@csv.CsvLine] {
  let one : @csv.CsvLine = match i {
    0 => [Some("a"), Some("b")]
    1 => [Some("a,b"), Some("c")]
    2 => [Some("a\"b"), Some("c")]
    3 => [Some("a\nb"), Some("c")]
    4 => [Some("a\r\nb")]
    5 => [Some("")]
    6 => [None, Some("b")]
    7 => [Some(" a "), Some("b")]
    8 => [Some("a"), None]
    9 => [Some("\u{4e2d}\u{6587}"), Some("x")]
    10 => [Some("a")]
    _ => [Some("\"a\""), Some("b")]
  }
  [one, [Some("z1"), Some("z2")]]
}

///|
test "csv 读：默认配置全表（32 个输入）" {
  assert_eq(rd_tag("a,b,c", rcfg(0)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.0.0|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(rd_tag("a,b,c\n", rcfg(0)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.1.0|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(
    rd_tag("a,b,c\nd,e,f", rcfg(0)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.2.0|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\r\nd,e,f", rcfg(0)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.3.0|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\rd,e,f", rcfg(0)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.4.0|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(rd_tag("\"a\",\"b\"", rcfg(0)), "OK:hdr=<none>;[0]a/b/;nrows=1") // r.5.0|OK:hdr=<none>;[0]a/b/;nrows=1
  assert_eq(rd_tag("\"a,b\",c", rcfg(0)), "OK:hdr=<none>;[0]a,b/c/;nrows=1") // r.6.0|OK:hdr=<none>;[0]a,b/c/;nrows=1
  assert_eq(rd_tag("\"a\"\"b\",c", rcfg(0)), "OK:hdr=<none>;[0]a\"b/c/;nrows=1") // r.7.0|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"a\nb\",c", rcfg(0)), "OK:hdr=<none>;[0]a\nb/c/;nrows=1") // r.8.0|OK:hdr=<none>;[0]a\nb/c/;nrows=1
  assert_eq(
    rd_tag("\"a\r\nb\",c", rcfg(0)),
    "OK:hdr=<none>;[0]a\r\nb/c/;nrows=1",
  ) // r.9.0|OK:hdr=<none>;[0]a\r\nb/c/;nrows=1
  assert_eq(rd_tag("a\"b,c", rcfg(0)), "OK:hdr=<none>;[0]a\"b/c/;nrows=1") // r.10.0|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"\",c", rcfg(0)), "OK:hdr=<none>;[0]/c/;nrows=1") // r.11.0|OK:hdr=<none>;[0]/c/;nrows=1
  assert_eq(rd_tag("a,,c", rcfg(0)), "OK:hdr=<none>;[0]a//c/;nrows=1") // r.12.0|OK:hdr=<none>;[0]a//c/;nrows=1
  assert_eq(rd_tag(",,", rcfg(0)), "OK:hdr=<none>;[0]///;nrows=1") // r.13.0|OK:hdr=<none>;[0]///;nrows=1
  assert_eq(rd_tag("", rcfg(0)), "OK:hdr=<none>;nrows=0") // r.14.0|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\n", rcfg(0)), "OK:hdr=<none>;nrows=0") // r.15.0|OK:hdr=<none>;nrows=0
  assert_eq(
    rd_tag("a,b\n\nc,d", rcfg(0)),
    "OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2",
  ) // r.16.0|OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2
  assert_eq(rd_tag("#cmt\na,b", rcfg(0)), "OK:hdr=<none>;[1]a/b/;nrows=1") // r.17.0|OK:hdr=<none>;[1]a/b/;nrows=1
  assert_eq(
    rd_tag("a,b\n#cmt\nc,d", rcfg(0)),
    "OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2",
  ) // r.18.0|OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2
  assert_eq(
    rd_tag("a, \"b\" ,c", rcfg(0)),
    "OK:hdr=<none>;[0]a/ \"b\" /c/;nrows=1",
  ) // r.19.0|OK:hdr=<none>;[0]a/ \"b\" /c/;nrows=1
  assert_eq(rd_tag("\"a\"x,b", rcfg(0)), "OK:hdr=<none>;[0]\"a\"x/b/;nrows=1") // r.20.0|OK:hdr=<none>;[0]\"a\"x/b/;nrows=1
  assert_eq(rd_tag(" a ,b", rcfg(0)), "OK:hdr=<none>;[0] a /b/;nrows=1") // r.21.0|OK:hdr=<none>;[0] a /b/;nrows=1
  assert_eq(rd_tag("a,b\nc", rcfg(0)), "OK:hdr=<none>;[0]a/b/;[1]c/;nrows=2") // r.22.0|OK:hdr=<none>;[0]a/b/;[1]c/;nrows=2
  assert_eq(
    rd_tag("h1,h2\nv1,v2\nv3,v4", rcfg(0)),
    "OK:hdr=<none>;[0]h1/h2/;[1]v1/v2/;[2]v3/v4/;nrows=3",
  ) // r.23.0|OK:hdr=<none>;[0]h1/h2/;[1]v1/v2/;[2]v3/v4/;nrows=3
  assert_eq(
    rd_tag("h1,h2\nv1", rcfg(0)),
    "OK:hdr=<none>;[0]h1/h2/;[1]v1/;nrows=2",
  ) // r.24.0|OK:hdr=<none>;[0]h1/h2/;[1]v1/;nrows=2
  assert_eq(rd_tag("a;b,c", rcfg(0)), "OK:hdr=<none>;[0]a;b/c/;nrows=1") // r.25.0|OK:hdr=<none>;[0]a;b/c/;nrows=1
  assert_eq(rd_tag("\"a\",\"\"", rcfg(0)), "OK:hdr=<none>;[0]a//;nrows=1") // r.26.0|OK:hdr=<none>;[0]a//;nrows=1
  assert_eq(rd_tag("a,b,", rcfg(0)), "OK:hdr=<none>;[0]a/b//;nrows=1") // r.27.0|OK:hdr=<none>;[0]a/b//;nrows=1
  assert_eq(
    rd_tag("a,中文,c", rcfg(0)),
    "OK:hdr=<none>;[0]a/中文/c/;nrows=1",
  ) // r.28.0|OK:hdr=<none>;[0]a/中文/c/;nrows=1
  assert_eq(
    rd_tag("\"a\u{0000}b\",c", rcfg(0)),
    "OK:hdr=<none>;[0]a\u{0000}b/c/;nrows=1",
  ) // r.29.0|OK:hdr=<none>;[0]a\u{0000}b/c/;nrows=1
  assert_eq(rd_tag("a", rcfg(0)), "OK:hdr=<none>;[0]a/;nrows=1") // r.30.0|OK:hdr=<none>;[0]a/;nrows=1
  assert_eq(
    rd_tag("x,y\n\"unclosed,z", rcfg(0)),
    "OK:hdr=<none>;[0]x/y/;[1]unclosed,z/;nrows=2",
  ) // r.31.0|OK:hdr=<none>;[0]x/y/;[1]unclosed,z/;nrows=2
}

///|
test "csv 读：表头三档（含表头别名与第 2 行当表头）" {
  assert_eq(rd_tag("a,b,c", rcfg(1)), "OK:hdr=a|b|c;nrows=0") // r.0.1|OK:hdr=a|b|c;nrows=0
  assert_eq(rd_tag("a,b,c\n", rcfg(1)), "OK:hdr=a|b|c;nrows=0") // r.1.1|OK:hdr=a|b|c;nrows=0
  assert_eq(
    rd_tag("a,b,c\nd,e,f", rcfg(1)),
    "OK:hdr=a|b|c;[1]d/e/f/;nrows=1;byName=d",
  ) // r.2.1|OK:hdr=a|b|c;[1]d/e/f/;nrows=1;byName=d
  assert_eq(
    rd_tag("a,b,c\r\nd,e,f", rcfg(1)),
    "OK:hdr=a|b|c;[1]d/e/f/;nrows=1;byName=d",
  ) // r.3.1|OK:hdr=a|b|c;[1]d/e/f/;nrows=1;byName=d
  assert_eq(
    rd_tag("a,b,c\rd,e,f", rcfg(1)),
    "OK:hdr=a|b|c;[1]d/e/f/;nrows=1;byName=d",
  ) // r.4.1|OK:hdr=a|b|c;[1]d/e/f/;nrows=1;byName=d
  assert_eq(rd_tag("\"a\",\"b\"", rcfg(1)), "OK:hdr=a|b;nrows=0") // r.5.1|OK:hdr=a|b;nrows=0
  assert_eq(rd_tag("\"a,b\",c", rcfg(1)), "OK:hdr=a,b|c;nrows=0") // r.6.1|OK:hdr=a,b|c;nrows=0
  assert_eq(rd_tag("\"a\"\"b\",c", rcfg(1)), "OK:hdr=a\"b|c;nrows=0") // r.7.1|OK:hdr=a\"b|c;nrows=0
  assert_eq(rd_tag("\"a\nb\",c", rcfg(1)), "OK:hdr=a\nb|c;nrows=0") // r.8.1|OK:hdr=a\nb|c;nrows=0
  assert_eq(rd_tag("\"a\r\nb\",c", rcfg(1)), "OK:hdr=a\r\nb|c;nrows=0") // r.9.1|OK:hdr=a\r\nb|c;nrows=0
  assert_eq(rd_tag("a\"b,c", rcfg(1)), "OK:hdr=a\"b|c;nrows=0") // r.10.1|OK:hdr=a\"b|c;nrows=0
  assert_eq(rd_tag("\"\",c", rcfg(1)), "OK:hdr=|c;nrows=0") // r.11.1|OK:hdr=|c;nrows=0
  assert_eq(rd_tag("a,,c", rcfg(1)), "OK:hdr=a||c;nrows=0") // r.12.1|OK:hdr=a||c;nrows=0
  assert_eq(rd_tag(",,", rcfg(1)), "OK:hdr=||;nrows=0") // r.13.1|OK:hdr=||;nrows=0
  assert_eq(
    rd_tag("a,b\n\nc,d", rcfg(1)),
    "OK:hdr=a|b;[2]c/d/;nrows=1;byName=c",
  ) // r.16.1|OK:hdr=a|b;[2]c/d/;nrows=1;byName=c
  assert_eq(
    rd_tag("a,b\n#cmt\nc,d", rcfg(1)),
    "OK:hdr=a|b;[2]c/d/;nrows=1;byName=c",
  ) // r.18.1|OK:hdr=a|b;[2]c/d/;nrows=1;byName=c
  assert_eq(rd_tag("a, \"b\" ,c", rcfg(1)), "OK:hdr=a| \"b\" |c;nrows=0") // r.19.1|OK:hdr=a| \"b\" |c;nrows=0
  assert_eq(rd_tag("\"a\"x,b", rcfg(1)), "OK:hdr=\"a\"x|b;nrows=0") // r.20.1|OK:hdr=\"a\"x|b;nrows=0
  assert_eq(rd_tag(" a ,b", rcfg(1)), "OK:hdr= a |b;nrows=0") // r.21.1|OK:hdr= a |b;nrows=0
  assert_eq(rd_tag("a,b\nc", rcfg(1)), "OK:hdr=a|b;[1]c/;nrows=1;byName=c") // r.22.1|OK:hdr=a|b;[1]c/;nrows=1;byName=c
  assert_eq(
    rd_tag("h1,h2\nv1,v2\nv3,v4", rcfg(1)),
    "OK:hdr=h1|h2;[1]v1/v2/;[2]v3/v4/;nrows=2;byName=v1",
  ) // r.23.1|OK:hdr=h1|h2;[1]v1/v2/;[2]v3/v4/;nrows=2;byName=v1
  assert_eq(
    rd_tag("h1,h2\nv1", rcfg(1)),
    "OK:hdr=h1|h2;[1]v1/;nrows=1;byName=v1",
  ) // r.24.1|OK:hdr=h1|h2;[1]v1/;nrows=1;byName=v1
  assert_eq(rd_tag("a;b,c", rcfg(1)), "OK:hdr=a;b|c;nrows=0") // r.25.1|OK:hdr=a;b|c;nrows=0
  assert_eq(rd_tag("\"a\",\"\"", rcfg(1)), "OK:hdr=a|;nrows=0") // r.26.1|OK:hdr=a|;nrows=0
  assert_eq(rd_tag("a,b,", rcfg(1)), "OK:hdr=a|b|;nrows=0") // r.27.1|OK:hdr=a|b|;nrows=0
  assert_eq(rd_tag("a,中文,c", rcfg(1)), "OK:hdr=a|中文|c;nrows=0") // r.28.1|OK:hdr=a|中文|c;nrows=0
  assert_eq(rd_tag("\"a\u{0000}b\",c", rcfg(1)), "OK:hdr=a\u{0000}b|c;nrows=0") // r.29.1|OK:hdr=a\u{0000}b|c;nrows=0
  assert_eq(rd_tag("a", rcfg(1)), "OK:hdr=a;nrows=0") // r.30.1|OK:hdr=a;nrows=0
  assert_eq(
    rd_tag("x,y\n\"unclosed,z", rcfg(1)),
    "OK:hdr=x|y;[1]unclosed,z/;nrows=1;byName=unclosed,z",
  ) // r.31.1|OK:hdr=x|y;[1]unclosed,z/;nrows=1;byName=unclosed,z
}

///|
test "csv 读：空行、注释行与行号推进" {
  assert_eq(rd_tag("a,b,c", rcfg(2)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.0.2|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(rd_tag("a,b,c\n", rcfg(2)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.1.2|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(
    rd_tag("a,b,c\nd,e,f", rcfg(2)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.2.2|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\r\nd,e,f", rcfg(2)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.3.2|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\rd,e,f", rcfg(2)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.4.2|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(rd_tag("\"a\",\"b\"", rcfg(2)), "OK:hdr=<none>;[0]a/b/;nrows=1") // r.5.2|OK:hdr=<none>;[0]a/b/;nrows=1
  assert_eq(rd_tag("\"a,b\",c", rcfg(2)), "OK:hdr=<none>;[0]a,b/c/;nrows=1") // r.6.2|OK:hdr=<none>;[0]a,b/c/;nrows=1
  assert_eq(rd_tag("\"a\"\"b\",c", rcfg(2)), "OK:hdr=<none>;[0]a\"b/c/;nrows=1") // r.7.2|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"a\nb\",c", rcfg(2)), "OK:hdr=<none>;[0]a\nb/c/;nrows=1") // r.8.2|OK:hdr=<none>;[0]a\nb/c/;nrows=1
  assert_eq(
    rd_tag("\"a\r\nb\",c", rcfg(2)),
    "OK:hdr=<none>;[0]a\r\nb/c/;nrows=1",
  ) // r.9.2|OK:hdr=<none>;[0]a\r\nb/c/;nrows=1
  assert_eq(rd_tag("a\"b,c", rcfg(2)), "OK:hdr=<none>;[0]a\"b/c/;nrows=1") // r.10.2|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"\",c", rcfg(2)), "OK:hdr=<none>;[0]/c/;nrows=1") // r.11.2|OK:hdr=<none>;[0]/c/;nrows=1
  assert_eq(rd_tag("a,,c", rcfg(2)), "OK:hdr=<none>;[0]a//c/;nrows=1") // r.12.2|OK:hdr=<none>;[0]a//c/;nrows=1
  assert_eq(rd_tag(",,", rcfg(2)), "OK:hdr=<none>;[0]///;nrows=1") // r.13.2|OK:hdr=<none>;[0]///;nrows=1
  assert_eq(rd_tag("", rcfg(2)), "OK:hdr=<none>;nrows=0") // r.14.2|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\n", rcfg(2)), "OK:hdr=<none>;[0]/;nrows=1") // r.15.2|OK:hdr=<none>;[0]/;nrows=1
  assert_eq(
    rd_tag("a,b\n\nc,d", rcfg(2)),
    "OK:hdr=<none>;[0]a/b/;[1]/;[2]c/d/;nrows=3",
  ) // r.16.2|OK:hdr=<none>;[0]a/b/;[1]/;[2]c/d/;nrows=3
  assert_eq(rd_tag("#cmt\na,b", rcfg(2)), "OK:hdr=<none>;[1]a/b/;nrows=1") // r.17.2|OK:hdr=<none>;[1]a/b/;nrows=1
  assert_eq(
    rd_tag("a,b\n#cmt\nc,d", rcfg(2)),
    "OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2",
  ) // r.18.2|OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2
  assert_eq(
    rd_tag("a, \"b\" ,c", rcfg(2)),
    "OK:hdr=<none>;[0]a/ \"b\" /c/;nrows=1",
  ) // r.19.2|OK:hdr=<none>;[0]a/ \"b\" /c/;nrows=1
  assert_eq(rd_tag("\"a\"x,b", rcfg(2)), "OK:hdr=<none>;[0]\"a\"x/b/;nrows=1") // r.20.2|OK:hdr=<none>;[0]\"a\"x/b/;nrows=1
  assert_eq(rd_tag(" a ,b", rcfg(2)), "OK:hdr=<none>;[0] a /b/;nrows=1") // r.21.2|OK:hdr=<none>;[0] a /b/;nrows=1
  assert_eq(rd_tag("a,b\nc", rcfg(2)), "OK:hdr=<none>;[0]a/b/;[1]c/;nrows=2") // r.22.2|OK:hdr=<none>;[0]a/b/;[1]c/;nrows=2
  assert_eq(
    rd_tag("h1,h2\nv1,v2\nv3,v4", rcfg(2)),
    "OK:hdr=<none>;[0]h1/h2/;[1]v1/v2/;[2]v3/v4/;nrows=3",
  ) // r.23.2|OK:hdr=<none>;[0]h1/h2/;[1]v1/v2/;[2]v3/v4/;nrows=3
  assert_eq(
    rd_tag("h1,h2\nv1", rcfg(2)),
    "OK:hdr=<none>;[0]h1/h2/;[1]v1/;nrows=2",
  ) // r.24.2|OK:hdr=<none>;[0]h1/h2/;[1]v1/;nrows=2
  assert_eq(rd_tag("a;b,c", rcfg(2)), "OK:hdr=<none>;[0]a;b/c/;nrows=1") // r.25.2|OK:hdr=<none>;[0]a;b/c/;nrows=1
  assert_eq(rd_tag("\"a\",\"\"", rcfg(2)), "OK:hdr=<none>;[0]a//;nrows=1") // r.26.2|OK:hdr=<none>;[0]a//;nrows=1
  assert_eq(rd_tag("a,b,", rcfg(2)), "OK:hdr=<none>;[0]a/b//;nrows=1") // r.27.2|OK:hdr=<none>;[0]a/b//;nrows=1
  assert_eq(
    rd_tag("a,中文,c", rcfg(2)),
    "OK:hdr=<none>;[0]a/中文/c/;nrows=1",
  ) // r.28.2|OK:hdr=<none>;[0]a/中文/c/;nrows=1
  assert_eq(
    rd_tag("\"a\u{0000}b\",c", rcfg(2)),
    "OK:hdr=<none>;[0]a\u{0000}b/c/;nrows=1",
  ) // r.29.2|OK:hdr=<none>;[0]a\u{0000}b/c/;nrows=1
  assert_eq(rd_tag("a", rcfg(2)), "OK:hdr=<none>;[0]a/;nrows=1") // r.30.2|OK:hdr=<none>;[0]a/;nrows=1
  assert_eq(
    rd_tag("x,y\n\"unclosed,z", rcfg(2)),
    "OK:hdr=<none>;[0]x/y/;[1]unclosed,z/;nrows=2",
  ) // r.31.2|OK:hdr=<none>;[0]x/y/;[1]unclosed,z/;nrows=2
}

///|
test "csv 读：trim/自定义分隔符/自定义引号/行范围" {
  assert_eq(rd_tag("a,b,c", rcfg(3)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.0.3|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(rd_tag("a,b,c\n", rcfg(3)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.1.3|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(
    rd_tag("a,b,c\nd,e,f", rcfg(3)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.2.3|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\r\nd,e,f", rcfg(3)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.3.3|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\rd,e,f", rcfg(3)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.4.3|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(rd_tag("\"a\",\"b\"", rcfg(3)), "OK:hdr=<none>;[0]a/b/;nrows=1") // r.5.3|OK:hdr=<none>;[0]a/b/;nrows=1
  assert_eq(rd_tag("\"a,b\",c", rcfg(3)), "OK:hdr=<none>;[0]a,b/c/;nrows=1") // r.6.3|OK:hdr=<none>;[0]a,b/c/;nrows=1
  assert_eq(rd_tag("\"a\"\"b\",c", rcfg(3)), "OK:hdr=<none>;[0]a\"b/c/;nrows=1") // r.7.3|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"a\nb\",c", rcfg(3)), "OK:hdr=<none>;[0]a\nb/c/;nrows=1") // r.8.3|OK:hdr=<none>;[0]a\nb/c/;nrows=1
  assert_eq(
    rd_tag("\"a\r\nb\",c", rcfg(3)),
    "OK:hdr=<none>;[0]a\r\nb/c/;nrows=1",
  ) // r.9.3|OK:hdr=<none>;[0]a\r\nb/c/;nrows=1
  assert_eq(rd_tag("a\"b,c", rcfg(3)), "OK:hdr=<none>;[0]a\"b/c/;nrows=1") // r.10.3|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"\",c", rcfg(3)), "OK:hdr=<none>;[0]/c/;nrows=1") // r.11.3|OK:hdr=<none>;[0]/c/;nrows=1
  assert_eq(rd_tag("a,,c", rcfg(3)), "OK:hdr=<none>;[0]a//c/;nrows=1") // r.12.3|OK:hdr=<none>;[0]a//c/;nrows=1
  assert_eq(rd_tag(",,", rcfg(3)), "OK:hdr=<none>;[0]///;nrows=1") // r.13.3|OK:hdr=<none>;[0]///;nrows=1
  assert_eq(rd_tag("", rcfg(3)), "OK:hdr=<none>;nrows=0") // r.14.3|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\n", rcfg(3)), "OK:hdr=<none>;nrows=0") // r.15.3|OK:hdr=<none>;nrows=0
  assert_eq(
    rd_tag("a,b\n\nc,d", rcfg(3)),
    "OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2",
  ) // r.16.3|OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2
  assert_eq(rd_tag("#cmt\na,b", rcfg(3)), "OK:hdr=<none>;[1]a/b/;nrows=1") // r.17.3|OK:hdr=<none>;[1]a/b/;nrows=1
  assert_eq(
    rd_tag("a,b\n#cmt\nc,d", rcfg(3)),
    "OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2",
  ) // r.18.3|OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2
  assert_eq(
    rd_tag("a, \"b\" ,c", rcfg(3)),
    "OK:hdr=<none>;[0]a/\"b\"/c/;nrows=1",
  ) // r.19.3|OK:hdr=<none>;[0]a/\"b\"/c/;nrows=1
  assert_eq(rd_tag("\"a\"x,b", rcfg(3)), "OK:hdr=<none>;[0]\"a\"x/b/;nrows=1") // r.20.3|OK:hdr=<none>;[0]\"a\"x/b/;nrows=1
  assert_eq(rd_tag(" a ,b", rcfg(3)), "OK:hdr=<none>;[0]a/b/;nrows=1") // r.21.3|OK:hdr=<none>;[0]a/b/;nrows=1
  assert_eq(rd_tag("a,b\nc", rcfg(3)), "OK:hdr=<none>;[0]a/b/;[1]c/;nrows=2") // r.22.3|OK:hdr=<none>;[0]a/b/;[1]c/;nrows=2
  assert_eq(
    rd_tag("h1,h2\nv1,v2\nv3,v4", rcfg(3)),
    "OK:hdr=<none>;[0]h1/h2/;[1]v1/v2/;[2]v3/v4/;nrows=3",
  ) // r.23.3|OK:hdr=<none>;[0]h1/h2/;[1]v1/v2/;[2]v3/v4/;nrows=3
  assert_eq(
    rd_tag("h1,h2\nv1", rcfg(3)),
    "OK:hdr=<none>;[0]h1/h2/;[1]v1/;nrows=2",
  ) // r.24.3|OK:hdr=<none>;[0]h1/h2/;[1]v1/;nrows=2
  assert_eq(rd_tag("a;b,c", rcfg(3)), "OK:hdr=<none>;[0]a;b/c/;nrows=1") // r.25.3|OK:hdr=<none>;[0]a;b/c/;nrows=1
  assert_eq(rd_tag("\"a\",\"\"", rcfg(3)), "OK:hdr=<none>;[0]a//;nrows=1") // r.26.3|OK:hdr=<none>;[0]a//;nrows=1
  assert_eq(rd_tag("a,b,", rcfg(3)), "OK:hdr=<none>;[0]a/b//;nrows=1") // r.27.3|OK:hdr=<none>;[0]a/b//;nrows=1
  assert_eq(
    rd_tag("a,中文,c", rcfg(3)),
    "OK:hdr=<none>;[0]a/中文/c/;nrows=1",
  ) // r.28.3|OK:hdr=<none>;[0]a/中文/c/;nrows=1
  assert_eq(
    rd_tag("\"a\u{0000}b\",c", rcfg(3)),
    "OK:hdr=<none>;[0]a\u{0000}b/c/;nrows=1",
  ) // r.29.3|OK:hdr=<none>;[0]a\u{0000}b/c/;nrows=1
  assert_eq(rd_tag("a", rcfg(3)), "OK:hdr=<none>;[0]a/;nrows=1") // r.30.3|OK:hdr=<none>;[0]a/;nrows=1
  assert_eq(
    rd_tag("x,y\n\"unclosed,z", rcfg(3)),
    "OK:hdr=<none>;[0]x/y/;[1]unclosed,z/;nrows=2",
  ) // r.31.3|OK:hdr=<none>;[0]x/y/;[1]unclosed,z/;nrows=2
}

///|
test "csv 读：列数不等开关与 UnevenFields 档" {
  assert_eq(rd_tag("a,b,c", rcfg(7)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.0.7|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(rd_tag("a,b,c\n", rcfg(7)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.1.7|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(
    rd_tag("a,b,c\nd,e,f", rcfg(7)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.2.7|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\r\nd,e,f", rcfg(7)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.3.7|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\rd,e,f", rcfg(7)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.4.7|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(rd_tag("\"a\",\"b\"", rcfg(7)), "OK:hdr=<none>;[0]a/b/;nrows=1") // r.5.7|OK:hdr=<none>;[0]a/b/;nrows=1
  assert_eq(rd_tag("\"a,b\",c", rcfg(7)), "OK:hdr=<none>;[0]a,b/c/;nrows=1") // r.6.7|OK:hdr=<none>;[0]a,b/c/;nrows=1
  assert_eq(rd_tag("\"a\"\"b\",c", rcfg(7)), "OK:hdr=<none>;[0]a\"b/c/;nrows=1") // r.7.7|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"a\nb\",c", rcfg(7)), "OK:hdr=<none>;[0]a\nb/c/;nrows=1") // r.8.7|OK:hdr=<none>;[0]a\nb/c/;nrows=1
  assert_eq(
    rd_tag("\"a\r\nb\",c", rcfg(7)),
    "OK:hdr=<none>;[0]a\r\nb/c/;nrows=1",
  ) // r.9.7|OK:hdr=<none>;[0]a\r\nb/c/;nrows=1
  assert_eq(rd_tag("a\"b,c", rcfg(7)), "OK:hdr=<none>;[0]a\"b/c/;nrows=1") // r.10.7|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"\",c", rcfg(7)), "OK:hdr=<none>;[0]/c/;nrows=1") // r.11.7|OK:hdr=<none>;[0]/c/;nrows=1
  assert_eq(rd_tag("a,,c", rcfg(7)), "OK:hdr=<none>;[0]a//c/;nrows=1") // r.12.7|OK:hdr=<none>;[0]a//c/;nrows=1
  assert_eq(rd_tag(",,", rcfg(7)), "OK:hdr=<none>;[0]///;nrows=1") // r.13.7|OK:hdr=<none>;[0]///;nrows=1
  assert_eq(rd_tag("", rcfg(7)), "OK:hdr=<none>;nrows=0") // r.14.7|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\n", rcfg(7)), "OK:hdr=<none>;nrows=0") // r.15.7|OK:hdr=<none>;nrows=0
  assert_eq(
    rd_tag("a,b\n\nc,d", rcfg(7)),
    "OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2",
  ) // r.16.7|OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2
  assert_eq(rd_tag("#cmt\na,b", rcfg(7)), "OK:hdr=<none>;[1]a/b/;nrows=1") // r.17.7|OK:hdr=<none>;[1]a/b/;nrows=1
  assert_eq(
    rd_tag("a,b\n#cmt\nc,d", rcfg(7)),
    "OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2",
  ) // r.18.7|OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2
  assert_eq(
    rd_tag("a, \"b\" ,c", rcfg(7)),
    "OK:hdr=<none>;[0]a/ \"b\" /c/;nrows=1",
  ) // r.19.7|OK:hdr=<none>;[0]a/ \"b\" /c/;nrows=1
  assert_eq(rd_tag("\"a\"x,b", rcfg(7)), "OK:hdr=<none>;[0]\"a\"x/b/;nrows=1") // r.20.7|OK:hdr=<none>;[0]\"a\"x/b/;nrows=1
  assert_eq(rd_tag(" a ,b", rcfg(7)), "OK:hdr=<none>;[0] a /b/;nrows=1") // r.21.7|OK:hdr=<none>;[0] a /b/;nrows=1
  assert_eq(rd_tag("a,b\nc", rcfg(7)), "UnevenFields[1,1,2]") // r.22.7|IORuntimeException:Line 1 has 1 fields, but first line has 2 fields
  assert_eq(
    rd_tag("h1,h2\nv1,v2\nv3,v4", rcfg(7)),
    "OK:hdr=<none>;[0]h1/h2/;[1]v1/v2/;[2]v3/v4/;nrows=3",
  ) // r.23.7|OK:hdr=<none>;[0]h1/h2/;[1]v1/v2/;[2]v3/v4/;nrows=3
  assert_eq(rd_tag("h1,h2\nv1", rcfg(7)), "UnevenFields[1,1,2]") // r.24.7|IORuntimeException:Line 1 has 1 fields, but first line has 2 fields
  assert_eq(rd_tag("a;b,c", rcfg(7)), "OK:hdr=<none>;[0]a;b/c/;nrows=1") // r.25.7|OK:hdr=<none>;[0]a;b/c/;nrows=1
  assert_eq(rd_tag("\"a\",\"\"", rcfg(7)), "OK:hdr=<none>;[0]a//;nrows=1") // r.26.7|OK:hdr=<none>;[0]a//;nrows=1
  assert_eq(rd_tag("a,b,", rcfg(7)), "OK:hdr=<none>;[0]a/b//;nrows=1") // r.27.7|OK:hdr=<none>;[0]a/b//;nrows=1
  assert_eq(
    rd_tag("a,中文,c", rcfg(7)),
    "OK:hdr=<none>;[0]a/中文/c/;nrows=1",
  ) // r.28.7|OK:hdr=<none>;[0]a/中文/c/;nrows=1
  assert_eq(
    rd_tag("\"a\u{0000}b\",c", rcfg(7)),
    "OK:hdr=<none>;[0]a\u{0000}b/c/;nrows=1",
  ) // r.29.7|OK:hdr=<none>;[0]a\u{0000}b/c/;nrows=1
  assert_eq(rd_tag("a", rcfg(7)), "OK:hdr=<none>;[0]a/;nrows=1") // r.30.7|OK:hdr=<none>;[0]a/;nrows=1
  assert_eq(rd_tag("x,y\n\"unclosed,z", rcfg(7)), "UnevenFields[1,1,2]") // r.31.7|IORuntimeException:Line 1 has 1 fields, but first line has 2 fields
}

///|
test "csv 读：其余 7 档配置全表" {
  assert_eq(rd_tag("#cmt\na,b", rcfg(4)), "OK:hdr=a|b;nrows=0") // r.17.4|OK:hdr=a|b;nrows=0
  assert_eq(rd_tag("a,b,c", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.0.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("a,b,c\n", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.1.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("a,b,c\nd,e,f", rcfg(5)), "OK:hdr=<none>;[1]d/e/f/;nrows=1") // r.2.5|OK:hdr=<none>;[1]d/e/f/;nrows=1
  assert_eq(
    rd_tag("a,b,c\r\nd,e,f", rcfg(5)),
    "OK:hdr=<none>;[1]d/e/f/;nrows=1",
  ) // r.3.5|OK:hdr=<none>;[1]d/e/f/;nrows=1
  assert_eq(rd_tag("a,b,c\rd,e,f", rcfg(5)), "OK:hdr=<none>;[1]d/e/f/;nrows=1") // r.4.5|OK:hdr=<none>;[1]d/e/f/;nrows=1
  assert_eq(rd_tag("\"a\",\"b\"", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.5.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\"a,b\",c", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.6.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\"a\"\"b\",c", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.7.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\"a\nb\",c", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.8.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\"a\r\nb\",c", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.9.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("a\"b,c", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.10.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\"\",c", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.11.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("a,,c", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.12.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag(",,", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.13.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.14.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\n", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.15.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("a,b\n\nc,d", rcfg(5)), "OK:hdr=<none>;[2]c/d/;nrows=1") // r.16.5|OK:hdr=<none>;[2]c/d/;nrows=1
  assert_eq(rd_tag("#cmt\na,b", rcfg(5)), "OK:hdr=<none>;[1]a/b/;nrows=1") // r.17.5|OK:hdr=<none>;[1]a/b/;nrows=1
  assert_eq(rd_tag("a,b\n#cmt\nc,d", rcfg(5)), "OK:hdr=<none>;[2]c/d/;nrows=1") // r.18.5|OK:hdr=<none>;[2]c/d/;nrows=1
  assert_eq(rd_tag("a, \"b\" ,c", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.19.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\"a\"x,b", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.20.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag(" a ,b", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.21.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("a,b\nc", rcfg(5)), "OK:hdr=<none>;[1]c/;nrows=1") // r.22.5|OK:hdr=<none>;[1]c/;nrows=1
  assert_eq(
    rd_tag("h1,h2\nv1,v2\nv3,v4", rcfg(5)),
    "OK:hdr=<none>;[1]v1/v2/;[2]v3/v4/;nrows=2",
  ) // r.23.5|OK:hdr=<none>;[1]v1/v2/;[2]v3/v4/;nrows=2
  assert_eq(rd_tag("h1,h2\nv1", rcfg(5)), "OK:hdr=<none>;[1]v1/;nrows=1") // r.24.5|OK:hdr=<none>;[1]v1/;nrows=1
  assert_eq(rd_tag("a;b,c", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.25.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\"a\",\"\"", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.26.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("a,b,", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.27.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("a,中文,c", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.28.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\"a\u{0000}b\",c", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.29.5|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("a", rcfg(5)), "OK:hdr=<none>;nrows=0") // r.30.5|OK:hdr=<none>;nrows=0
  assert_eq(
    rd_tag("x,y\n\"unclosed,z", rcfg(5)),
    "OK:hdr=<none>;[1]unclosed,z/;nrows=1",
  ) // r.31.5|OK:hdr=<none>;[1]unclosed,z/;nrows=1
  assert_eq(rd_tag("a,b,c", rcfg(6)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.0.6|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(rd_tag("a,b,c\n", rcfg(6)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.1.6|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(rd_tag("a,b,c\nd,e,f", rcfg(6)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.2.6|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(
    rd_tag("a,b,c\r\nd,e,f", rcfg(6)),
    "OK:hdr=<none>;[0]a/b/c/;nrows=1",
  ) // r.3.6|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(rd_tag("a,b,c\rd,e,f", rcfg(6)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.4.6|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(rd_tag("\"a\",\"b\"", rcfg(6)), "OK:hdr=<none>;[0]a/b/;nrows=1") // r.5.6|OK:hdr=<none>;[0]a/b/;nrows=1
  assert_eq(rd_tag("\"a,b\",c", rcfg(6)), "OK:hdr=<none>;[0]a,b/c/;nrows=1") // r.6.6|OK:hdr=<none>;[0]a,b/c/;nrows=1
  assert_eq(rd_tag("\"a\"\"b\",c", rcfg(6)), "OK:hdr=<none>;[0]a\"b/c/;nrows=1") // r.7.6|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"a\nb\",c", rcfg(6)), "OK:hdr=<none>;[0]a\nb/c/;nrows=1") // r.8.6|OK:hdr=<none>;[0]a\nb/c/;nrows=1
  assert_eq(
    rd_tag("\"a\r\nb\",c", rcfg(6)),
    "OK:hdr=<none>;[0]a\r\nb/c/;nrows=1",
  ) // r.9.6|OK:hdr=<none>;[0]a\r\nb/c/;nrows=1
  assert_eq(rd_tag("a\"b,c", rcfg(6)), "OK:hdr=<none>;[0]a\"b/c/;nrows=1") // r.10.6|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"\",c", rcfg(6)), "OK:hdr=<none>;[0]/c/;nrows=1") // r.11.6|OK:hdr=<none>;[0]/c/;nrows=1
  assert_eq(rd_tag("a,,c", rcfg(6)), "OK:hdr=<none>;[0]a//c/;nrows=1") // r.12.6|OK:hdr=<none>;[0]a//c/;nrows=1
  assert_eq(rd_tag(",,", rcfg(6)), "OK:hdr=<none>;[0]///;nrows=1") // r.13.6|OK:hdr=<none>;[0]///;nrows=1
  assert_eq(rd_tag("", rcfg(6)), "OK:hdr=<none>;nrows=0") // r.14.6|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\n", rcfg(6)), "OK:hdr=<none>;nrows=0") // r.15.6|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("a,b\n\nc,d", rcfg(6)), "OK:hdr=<none>;[0]a/b/;nrows=1") // r.16.6|OK:hdr=<none>;[0]a/b/;nrows=1
  assert_eq(rd_tag("#cmt\na,b", rcfg(6)), "OK:hdr=<none>;nrows=0") // r.17.6|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("a,b\n#cmt\nc,d", rcfg(6)), "OK:hdr=<none>;[0]a/b/;nrows=1") // r.18.6|OK:hdr=<none>;[0]a/b/;nrows=1
  assert_eq(
    rd_tag("a, \"b\" ,c", rcfg(6)),
    "OK:hdr=<none>;[0]a/ \"b\" /c/;nrows=1",
  ) // r.19.6|OK:hdr=<none>;[0]a/ \"b\" /c/;nrows=1
  assert_eq(rd_tag("\"a\"x,b", rcfg(6)), "OK:hdr=<none>;[0]\"a\"x/b/;nrows=1") // r.20.6|OK:hdr=<none>;[0]\"a\"x/b/;nrows=1
  assert_eq(rd_tag(" a ,b", rcfg(6)), "OK:hdr=<none>;[0] a /b/;nrows=1") // r.21.6|OK:hdr=<none>;[0] a /b/;nrows=1
  assert_eq(rd_tag("a,b\nc", rcfg(6)), "OK:hdr=<none>;[0]a/b/;nrows=1") // r.22.6|OK:hdr=<none>;[0]a/b/;nrows=1
  assert_eq(
    rd_tag("h1,h2\nv1,v2\nv3,v4", rcfg(6)),
    "OK:hdr=<none>;[0]h1/h2/;nrows=1",
  ) // r.23.6|OK:hdr=<none>;[0]h1/h2/;nrows=1
  assert_eq(rd_tag("h1,h2\nv1", rcfg(6)), "OK:hdr=<none>;[0]h1/h2/;nrows=1") // r.24.6|OK:hdr=<none>;[0]h1/h2/;nrows=1
  assert_eq(rd_tag("a;b,c", rcfg(6)), "OK:hdr=<none>;[0]a;b/c/;nrows=1") // r.25.6|OK:hdr=<none>;[0]a;b/c/;nrows=1
  assert_eq(rd_tag("\"a\",\"\"", rcfg(6)), "OK:hdr=<none>;[0]a//;nrows=1") // r.26.6|OK:hdr=<none>;[0]a//;nrows=1
  assert_eq(rd_tag("a,b,", rcfg(6)), "OK:hdr=<none>;[0]a/b//;nrows=1") // r.27.6|OK:hdr=<none>;[0]a/b//;nrows=1
  assert_eq(
    rd_tag("a,中文,c", rcfg(6)),
    "OK:hdr=<none>;[0]a/中文/c/;nrows=1",
  ) // r.28.6|OK:hdr=<none>;[0]a/中文/c/;nrows=1
  assert_eq(
    rd_tag("\"a\u{0000}b\",c", rcfg(6)),
    "OK:hdr=<none>;[0]a\u{0000}b/c/;nrows=1",
  ) // r.29.6|OK:hdr=<none>;[0]a\u{0000}b/c/;nrows=1
  assert_eq(rd_tag("a", rcfg(6)), "OK:hdr=<none>;[0]a/;nrows=1") // r.30.6|OK:hdr=<none>;[0]a/;nrows=1
  assert_eq(
    rd_tag("x,y\n\"unclosed,z", rcfg(6)),
    "OK:hdr=<none>;[0]x/y/;nrows=1",
  ) // r.31.6|OK:hdr=<none>;[0]x/y/;nrows=1
  assert_eq(rd_tag("a,b,c", rcfg(8)), "OK:hdr=<none>;[0]a,b,c/;nrows=1") // r.0.8|OK:hdr=<none>;[0]a,b,c/;nrows=1
  assert_eq(rd_tag("a,b,c\n", rcfg(8)), "OK:hdr=<none>;[0]a,b,c/;nrows=1") // r.1.8|OK:hdr=<none>;[0]a,b,c/;nrows=1
  assert_eq(
    rd_tag("a,b,c\nd,e,f", rcfg(8)),
    "OK:hdr=<none>;[0]a,b,c/;[1]d,e,f/;nrows=2",
  ) // r.2.8|OK:hdr=<none>;[0]a,b,c/;[1]d,e,f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\r\nd,e,f", rcfg(8)),
    "OK:hdr=<none>;[0]a,b,c/;[1]d,e,f/;nrows=2",
  ) // r.3.8|OK:hdr=<none>;[0]a,b,c/;[1]d,e,f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\rd,e,f", rcfg(8)),
    "OK:hdr=<none>;[0]a,b,c/;[1]d,e,f/;nrows=2",
  ) // r.4.8|OK:hdr=<none>;[0]a,b,c/;[1]d,e,f/;nrows=2
  assert_eq(rd_tag("\"a\",\"b\"", rcfg(8)), "OK:hdr=<none>;[0]a\",\"b/;nrows=1") // r.5.8|OK:hdr=<none>;[0]a\",\"b/;nrows=1
  assert_eq(rd_tag("\"a,b\",c", rcfg(8)), "OK:hdr=<none>;[0]\"a,b\",c/;nrows=1") // r.6.8|OK:hdr=<none>;[0]\"a,b\",c/;nrows=1
  assert_eq(
    rd_tag("\"a\"\"b\",c", rcfg(8)),
    "OK:hdr=<none>;[0]\"a\"b\",c/;nrows=1",
  ) // r.7.8|OK:hdr=<none>;[0]\"a\"b\",c/;nrows=1
  assert_eq(
    rd_tag("\"a\nb\",c", rcfg(8)),
    "OK:hdr=<none>;[0]\"a\nb\",c/;nrows=1",
  ) // r.8.8|OK:hdr=<none>;[0]\"a\nb\",c/;nrows=1
  assert_eq(
    rd_tag("\"a\r\nb\",c", rcfg(8)),
    "OK:hdr=<none>;[0]\"a\r\nb\",c/;nrows=1",
  ) // r.9.8|OK:hdr=<none>;[0]\"a\r\nb\",c/;nrows=1
  assert_eq(rd_tag("a\"b,c", rcfg(8)), "OK:hdr=<none>;[0]a\"b,c/;nrows=1") // r.10.8|OK:hdr=<none>;[0]a\"b,c/;nrows=1
  assert_eq(rd_tag("\"\",c", rcfg(8)), "OK:hdr=<none>;[0]\"\",c/;nrows=1") // r.11.8|OK:hdr=<none>;[0]\"\",c/;nrows=1
  assert_eq(rd_tag("a,,c", rcfg(8)), "OK:hdr=<none>;[0]a,,c/;nrows=1") // r.12.8|OK:hdr=<none>;[0]a,,c/;nrows=1
  assert_eq(rd_tag(",,", rcfg(8)), "OK:hdr=<none>;[0],,/;nrows=1") // r.13.8|OK:hdr=<none>;[0],,/;nrows=1
  assert_eq(rd_tag("", rcfg(8)), "OK:hdr=<none>;nrows=0") // r.14.8|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\n", rcfg(8)), "OK:hdr=<none>;nrows=0") // r.15.8|OK:hdr=<none>;nrows=0
  assert_eq(
    rd_tag("a,b\n\nc,d", rcfg(8)),
    "OK:hdr=<none>;[0]a,b/;[2]c,d/;nrows=2",
  ) // r.16.8|OK:hdr=<none>;[0]a,b/;[2]c,d/;nrows=2
  assert_eq(rd_tag("#cmt\na,b", rcfg(8)), "OK:hdr=<none>;[1]a,b/;nrows=1") // r.17.8|OK:hdr=<none>;[1]a,b/;nrows=1
  assert_eq(
    rd_tag("a,b\n#cmt\nc,d", rcfg(8)),
    "OK:hdr=<none>;[0]a,b/;[2]c,d/;nrows=2",
  ) // r.18.8|OK:hdr=<none>;[0]a,b/;[2]c,d/;nrows=2
  assert_eq(
    rd_tag("a, \"b\" ,c", rcfg(8)),
    "OK:hdr=<none>;[0]a, \"b\" ,c/;nrows=1",
  ) // r.19.8|OK:hdr=<none>;[0]a, \"b\" ,c/;nrows=1
  assert_eq(rd_tag("\"a\"x,b", rcfg(8)), "OK:hdr=<none>;[0]\"a\"x,b/;nrows=1") // r.20.8|OK:hdr=<none>;[0]\"a\"x,b/;nrows=1
  assert_eq(rd_tag(" a ,b", rcfg(8)), "OK:hdr=<none>;[0] a ,b/;nrows=1") // r.21.8|OK:hdr=<none>;[0] a ,b/;nrows=1
  assert_eq(rd_tag("a,b\nc", rcfg(8)), "OK:hdr=<none>;[0]a,b/;[1]c/;nrows=2") // r.22.8|OK:hdr=<none>;[0]a,b/;[1]c/;nrows=2
  assert_eq(
    rd_tag("h1,h2\nv1,v2\nv3,v4", rcfg(8)),
    "OK:hdr=<none>;[0]h1,h2/;[1]v1,v2/;[2]v3,v4/;nrows=3",
  ) // r.23.8|OK:hdr=<none>;[0]h1,h2/;[1]v1,v2/;[2]v3,v4/;nrows=3
  assert_eq(
    rd_tag("h1,h2\nv1", rcfg(8)),
    "OK:hdr=<none>;[0]h1,h2/;[1]v1/;nrows=2",
  ) // r.24.8|OK:hdr=<none>;[0]h1,h2/;[1]v1/;nrows=2
  assert_eq(rd_tag("a;b,c", rcfg(8)), "OK:hdr=<none>;[0]a/b,c/;nrows=1") // r.25.8|OK:hdr=<none>;[0]a/b,c/;nrows=1
  assert_eq(rd_tag("\"a\",\"\"", rcfg(8)), "OK:hdr=<none>;[0]a\",\"/;nrows=1") // r.26.8|OK:hdr=<none>;[0]a\",\"/;nrows=1
  assert_eq(rd_tag("a,b,", rcfg(8)), "OK:hdr=<none>;[0]a,b,/;nrows=1") // r.27.8|OK:hdr=<none>;[0]a,b,/;nrows=1
  assert_eq(
    rd_tag("a,中文,c", rcfg(8)),
    "OK:hdr=<none>;[0]a,中文,c/;nrows=1",
  ) // r.28.8|OK:hdr=<none>;[0]a,中文,c/;nrows=1
  assert_eq(
    rd_tag("\"a\u{0000}b\",c", rcfg(8)),
    "OK:hdr=<none>;[0]\"a\u{0000}b\",c/;nrows=1",
  ) // r.29.8|OK:hdr=<none>;[0]\"a\u{0000}b\",c/;nrows=1
  assert_eq(rd_tag("a", rcfg(8)), "OK:hdr=<none>;[0]a/;nrows=1") // r.30.8|OK:hdr=<none>;[0]a/;nrows=1
  assert_eq(
    rd_tag("x,y\n\"unclosed,z", rcfg(8)),
    "OK:hdr=<none>;[0]x,y/;[1]unclosed,z/;nrows=2",
  ) // r.31.8|OK:hdr=<none>;[0]x,y/;[1]unclosed,z/;nrows=2
  assert_eq(rd_tag("a,b,c", rcfg(9)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.0.9|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(rd_tag("a,b,c\n", rcfg(9)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.1.9|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(
    rd_tag("a,b,c\nd,e,f", rcfg(9)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.2.9|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\r\nd,e,f", rcfg(9)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.3.9|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\rd,e,f", rcfg(9)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.4.9|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("\"a\",\"b\"", rcfg(9)),
    "OK:hdr=<none>;[0]\"a\"/\"b\"/;nrows=1",
  ) // r.5.9|OK:hdr=<none>;[0]\"a\"/\"b\"/;nrows=1
  assert_eq(rd_tag("\"a,b\",c", rcfg(9)), "OK:hdr=<none>;[0]\"a/b\"/c/;nrows=1") // r.6.9|OK:hdr=<none>;[0]\"a/b\"/c/;nrows=1
  assert_eq(
    rd_tag("\"a\"\"b\",c", rcfg(9)),
    "OK:hdr=<none>;[0]\"a\"\"b\"/c/;nrows=1",
  ) // r.7.9|OK:hdr=<none>;[0]\"a\"\"b\"/c/;nrows=1
  assert_eq(
    rd_tag("\"a\nb\",c", rcfg(9)),
    "OK:hdr=<none>;[0]\"a/;[1]b\"/c/;nrows=2",
  ) // r.8.9|OK:hdr=<none>;[0]\"a/;[1]b\"/c/;nrows=2
  assert_eq(
    rd_tag("\"a\r\nb\",c", rcfg(9)),
    "OK:hdr=<none>;[0]\"a/;[1]b\"/c/;nrows=2",
  ) // r.9.9|OK:hdr=<none>;[0]\"a/;[1]b\"/c/;nrows=2
  assert_eq(rd_tag("a\"b,c", rcfg(9)), "OK:hdr=<none>;[0]a\"b/c/;nrows=1") // r.10.9|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"\",c", rcfg(9)), "OK:hdr=<none>;[0]\"\"/c/;nrows=1") // r.11.9|OK:hdr=<none>;[0]\"\"/c/;nrows=1
  assert_eq(rd_tag("a,,c", rcfg(9)), "OK:hdr=<none>;[0]a//c/;nrows=1") // r.12.9|OK:hdr=<none>;[0]a//c/;nrows=1
  assert_eq(rd_tag(",,", rcfg(9)), "OK:hdr=<none>;[0]///;nrows=1") // r.13.9|OK:hdr=<none>;[0]///;nrows=1
  assert_eq(rd_tag("", rcfg(9)), "OK:hdr=<none>;nrows=0") // r.14.9|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\n", rcfg(9)), "OK:hdr=<none>;nrows=0") // r.15.9|OK:hdr=<none>;nrows=0
  assert_eq(
    rd_tag("a,b\n\nc,d", rcfg(9)),
    "OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2",
  ) // r.16.9|OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2
  assert_eq(rd_tag("#cmt\na,b", rcfg(9)), "OK:hdr=<none>;[1]a/b/;nrows=1") // r.17.9|OK:hdr=<none>;[1]a/b/;nrows=1
  assert_eq(
    rd_tag("a,b\n#cmt\nc,d", rcfg(9)),
    "OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2",
  ) // r.18.9|OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2
  assert_eq(
    rd_tag("a, \"b\" ,c", rcfg(9)),
    "OK:hdr=<none>;[0]a/ \"b\" /c/;nrows=1",
  ) // r.19.9|OK:hdr=<none>;[0]a/ \"b\" /c/;nrows=1
  assert_eq(rd_tag("\"a\"x,b", rcfg(9)), "OK:hdr=<none>;[0]\"a\"x/b/;nrows=1") // r.20.9|OK:hdr=<none>;[0]\"a\"x/b/;nrows=1
  assert_eq(rd_tag(" a ,b", rcfg(9)), "OK:hdr=<none>;[0] a /b/;nrows=1") // r.21.9|OK:hdr=<none>;[0] a /b/;nrows=1
  assert_eq(rd_tag("a,b\nc", rcfg(9)), "OK:hdr=<none>;[0]a/b/;[1]c/;nrows=2") // r.22.9|OK:hdr=<none>;[0]a/b/;[1]c/;nrows=2
  assert_eq(
    rd_tag("h1,h2\nv1,v2\nv3,v4", rcfg(9)),
    "OK:hdr=<none>;[0]h1/h2/;[1]v1/v2/;[2]v3/v4/;nrows=3",
  ) // r.23.9|OK:hdr=<none>;[0]h1/h2/;[1]v1/v2/;[2]v3/v4/;nrows=3
  assert_eq(
    rd_tag("h1,h2\nv1", rcfg(9)),
    "OK:hdr=<none>;[0]h1/h2/;[1]v1/;nrows=2",
  ) // r.24.9|OK:hdr=<none>;[0]h1/h2/;[1]v1/;nrows=2
  assert_eq(rd_tag("a;b,c", rcfg(9)), "OK:hdr=<none>;[0]a;b/c/;nrows=1") // r.25.9|OK:hdr=<none>;[0]a;b/c/;nrows=1
  assert_eq(
    rd_tag("\"a\",\"\"", rcfg(9)),
    "OK:hdr=<none>;[0]\"a\"/\"\"/;nrows=1",
  ) // r.26.9|OK:hdr=<none>;[0]\"a\"/\"\"/;nrows=1
  assert_eq(rd_tag("a,b,", rcfg(9)), "OK:hdr=<none>;[0]a/b//;nrows=1") // r.27.9|OK:hdr=<none>;[0]a/b//;nrows=1
  assert_eq(
    rd_tag("a,中文,c", rcfg(9)),
    "OK:hdr=<none>;[0]a/中文/c/;nrows=1",
  ) // r.28.9|OK:hdr=<none>;[0]a/中文/c/;nrows=1
  assert_eq(
    rd_tag("\"a\u{0000}b\",c", rcfg(9)),
    "OK:hdr=<none>;[0]\"a\u{0000}b\"/c/;nrows=1",
  ) // r.29.9|OK:hdr=<none>;[0]\"a\u{0000}b\"/c/;nrows=1
  assert_eq(rd_tag("a", rcfg(9)), "OK:hdr=<none>;[0]a/;nrows=1") // r.30.9|OK:hdr=<none>;[0]a/;nrows=1
  assert_eq(
    rd_tag("x,y\n\"unclosed,z", rcfg(9)),
    "OK:hdr=<none>;[0]x/y/;[1]\"unclosed/z/;nrows=2",
  ) // r.31.9|OK:hdr=<none>;[0]x/y/;[1]\"unclosed/z/;nrows=2
  assert_eq(rd_tag("a,b,c", rcfg(10)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.0.10|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(rd_tag("a,b,c\n", rcfg(10)), "OK:hdr=<none>;[0]a/b/c/;nrows=1") // r.1.10|OK:hdr=<none>;[0]a/b/c/;nrows=1
  assert_eq(
    rd_tag("a,b,c\nd,e,f", rcfg(10)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.2.10|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\r\nd,e,f", rcfg(10)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.3.10|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(
    rd_tag("a,b,c\rd,e,f", rcfg(10)),
    "OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2",
  ) // r.4.10|OK:hdr=<none>;[0]a/b/c/;[1]d/e/f/;nrows=2
  assert_eq(rd_tag("\"a\",\"b\"", rcfg(10)), "OK:hdr=<none>;[0]a/b/;nrows=1") // r.5.10|OK:hdr=<none>;[0]a/b/;nrows=1
  assert_eq(rd_tag("\"a,b\",c", rcfg(10)), "OK:hdr=<none>;[0]a,b/c/;nrows=1") // r.6.10|OK:hdr=<none>;[0]a,b/c/;nrows=1
  assert_eq(
    rd_tag("\"a\"\"b\",c", rcfg(10)),
    "OK:hdr=<none>;[0]a\"b/c/;nrows=1",
  ) // r.7.10|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"a\nb\",c", rcfg(10)), "OK:hdr=<none>;[0]a\nb/c/;nrows=1") // r.8.10|OK:hdr=<none>;[0]a\nb/c/;nrows=1
  assert_eq(
    rd_tag("\"a\r\nb\",c", rcfg(10)),
    "OK:hdr=<none>;[0]a\r\nb/c/;nrows=1",
  ) // r.9.10|OK:hdr=<none>;[0]a\r\nb/c/;nrows=1
  assert_eq(rd_tag("a\"b,c", rcfg(10)), "OK:hdr=<none>;[0]a\"b/c/;nrows=1") // r.10.10|OK:hdr=<none>;[0]a\"b/c/;nrows=1
  assert_eq(rd_tag("\"\",c", rcfg(10)), "OK:hdr=<none>;[0]/c/;nrows=1") // r.11.10|OK:hdr=<none>;[0]/c/;nrows=1
  assert_eq(rd_tag("a,,c", rcfg(10)), "OK:hdr=<none>;[0]a//c/;nrows=1") // r.12.10|OK:hdr=<none>;[0]a//c/;nrows=1
  assert_eq(rd_tag(",,", rcfg(10)), "OK:hdr=<none>;[0]///;nrows=1") // r.13.10|OK:hdr=<none>;[0]///;nrows=1
  assert_eq(rd_tag("", rcfg(10)), "OK:hdr=<none>;nrows=0") // r.14.10|OK:hdr=<none>;nrows=0
  assert_eq(rd_tag("\n", rcfg(10)), "OK:hdr=<none>;nrows=0") // r.15.10|OK:hdr=<none>;nrows=0
  assert_eq(
    rd_tag("a,b\n\nc,d", rcfg(10)),
    "OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2",
  ) // r.16.10|OK:hdr=<none>;[0]a/b/;[2]c/d/;nrows=2
  assert_eq(
    rd_tag("#cmt\na,b", rcfg(10)),
    "OK:hdr=<none>;[0]#cmt/;[1]a/b/;nrows=2",
  ) // r.17.10|OK:hdr=<none>;[0]#cmt/;[1]a/b/;nrows=2
  assert_eq(
    rd_tag("a,b\n#cmt\nc,d", rcfg(10)),
    "OK:hdr=<none>;[0]a/b/;[1]#cmt/;[2]c/d/;nrows=3",
  ) // r.18.10|OK:hdr=<none>;[0]a/b/;[1]#cmt/;[2]c/d/;nrows=3
  assert_eq(
    rd_tag("a, \"b\" ,c", rcfg(10)),
    "OK:hdr=<none>;[0]a/ \"b\" /c/;nrows=1",
  ) // r.19.10|OK:hdr=<none>;[0]a/ \"b\" /c/;nrows=1
  assert_eq(rd_tag("\"a\"x,b", rcfg(10)), "OK:hdr=<none>;[0]\"a\"x/b/;nrows=1") // r.20.10|OK:hdr=<none>;[0]\"a\"x/b/;nrows=1
  assert_eq(rd_tag(" a ,b", rcfg(10)), "OK:hdr=<none>;[0] a /b/;nrows=1") // r.21.10|OK:hdr=<none>;[0] a /b/;nrows=1
  assert_eq(rd_tag("a,b\nc", rcfg(10)), "OK:hdr=<none>;[0]a/b/;[1]c/;nrows=2") // r.22.10|OK:hdr=<none>;[0]a/b/;[1]c/;nrows=2
  assert_eq(
    rd_tag("h1,h2\nv1,v2\nv3,v4", rcfg(10)),
    "OK:hdr=<none>;[0]h1/h2/;[1]v1/v2/;[2]v3/v4/;nrows=3",
  ) // r.23.10|OK:hdr=<none>;[0]h1/h2/;[1]v1/v2/;[2]v3/v4/;nrows=3
  assert_eq(
    rd_tag("h1,h2\nv1", rcfg(10)),
    "OK:hdr=<none>;[0]h1/h2/;[1]v1/;nrows=2",
  ) // r.24.10|OK:hdr=<none>;[0]h1/h2/;[1]v1/;nrows=2
  assert_eq(rd_tag("a;b,c", rcfg(10)), "OK:hdr=<none>;[0]a;b/c/;nrows=1") // r.25.10|OK:hdr=<none>;[0]a;b/c/;nrows=1
  assert_eq(rd_tag("\"a\",\"\"", rcfg(10)), "OK:hdr=<none>;[0]a//;nrows=1") // r.26.10|OK:hdr=<none>;[0]a//;nrows=1
  assert_eq(rd_tag("a,b,", rcfg(10)), "OK:hdr=<none>;[0]a/b//;nrows=1") // r.27.10|OK:hdr=<none>;[0]a/b//;nrows=1
  assert_eq(
    rd_tag("a,中文,c", rcfg(10)),
    "OK:hdr=<none>;[0]a/中文/c/;nrows=1",
  ) // r.28.10|OK:hdr=<none>;[0]a/中文/c/;nrows=1
  assert_eq(
    rd_tag("\"a\u{0000}b\",c", rcfg(10)),
    "OK:hdr=<none>;[0]a\u{0000}b/c/;nrows=1",
  ) // r.29.10|OK:hdr=<none>;[0]a\u{0000}b/c/;nrows=1
  assert_eq(rd_tag("a", rcfg(10)), "OK:hdr=<none>;[0]a/;nrows=1") // r.30.10|OK:hdr=<none>;[0]a/;nrows=1
  assert_eq(
    rd_tag("x,y\n\"unclosed,z", rcfg(10)),
    "OK:hdr=<none>;[0]x/y/;[1]unclosed,z/;nrows=2",
  ) // r.31.10|OK:hdr=<none>;[0]x/y/;[1]unclosed,z/;nrows=2
  assert_eq(rd_tag("a,b,c", rcfg(11)), "OK:hdr=a|b|c;nrows=0") // r.0.11|OK:hdr=a|b|c;nrows=0
  assert_eq(rd_tag("a,b,c\n", rcfg(11)), "OK:hdr=a|b|c;nrows=0") // r.1.11|OK:hdr=a|b|c;nrows=0
  assert_eq(
    rd_tag("a,b,c\nd,e,f", rcfg(11)),
    "OK:hdr=a|b|c;[1]d/e/f/;nrows=1;byName=d",
  ) // r.2.11|OK:hdr=a|b|c;[1]d/e/f/;nrows=1;byName=d
  assert_eq(
    rd_tag("a,b,c\r\nd,e,f", rcfg(11)),
    "OK:hdr=a|b|c;[1]d/e/f/;nrows=1;byName=d",
  ) // r.3.11|OK:hdr=a|b|c;[1]d/e/f/;nrows=1;byName=d
  assert_eq(
    rd_tag("a,b,c\rd,e,f", rcfg(11)),
    "OK:hdr=a|b|c;[1]d/e/f/;nrows=1;byName=d",
  ) // r.4.11|OK:hdr=a|b|c;[1]d/e/f/;nrows=1;byName=d
  assert_eq(rd_tag("\"a\",\"b\"", rcfg(11)), "OK:hdr=a|b;nrows=0") // r.5.11|OK:hdr=a|b;nrows=0
  assert_eq(rd_tag("\"a,b\",c", rcfg(11)), "OK:hdr=a,b|c;nrows=0") // r.6.11|OK:hdr=a,b|c;nrows=0
  assert_eq(rd_tag("\"a\"\"b\",c", rcfg(11)), "OK:hdr=a\"b|c;nrows=0") // r.7.11|OK:hdr=a\"b|c;nrows=0
  assert_eq(rd_tag("\"a\nb\",c", rcfg(11)), "OK:hdr=a\nb|c;nrows=0") // r.8.11|OK:hdr=a\nb|c;nrows=0
  assert_eq(rd_tag("\"a\r\nb\",c", rcfg(11)), "OK:hdr=a\r\nb|c;nrows=0") // r.9.11|OK:hdr=a\r\nb|c;nrows=0
  assert_eq(rd_tag("a\"b,c", rcfg(11)), "OK:hdr=a\"b|c;nrows=0") // r.10.11|OK:hdr=a\"b|c;nrows=0
  assert_eq(rd_tag("\"\",c", rcfg(11)), "OK:hdr=|c;nrows=0") // r.11.11|OK:hdr=|c;nrows=0
  assert_eq(rd_tag("a,,c", rcfg(11)), "OK:hdr=a||c;nrows=0") // r.12.11|OK:hdr=a||c;nrows=0
  assert_eq(rd_tag(",,", rcfg(11)), "OK:hdr=||;nrows=0") // r.13.11|OK:hdr=||;nrows=0
  assert_eq(
    rd_tag("a,b\n\nc,d", rcfg(11)),
    "OK:hdr=a|b;[2]c/d/;nrows=1;byName=c",
  ) // r.16.11|OK:hdr=a|b;[2]c/d/;nrows=1;byName=c
  assert_eq(
    rd_tag("a,b\n#cmt\nc,d", rcfg(11)),
    "OK:hdr=a|b;[2]c/d/;nrows=1;byName=c",
  ) // r.18.11|OK:hdr=a|b;[2]c/d/;nrows=1;byName=c
  assert_eq(rd_tag("a, \"b\" ,c", rcfg(11)), "OK:hdr=a| \"b\" |c;nrows=0") // r.19.11|OK:hdr=a| \"b\" |c;nrows=0
  assert_eq(rd_tag("\"a\"x,b", rcfg(11)), "OK:hdr=\"a\"x|b;nrows=0") // r.20.11|OK:hdr=\"a\"x|b;nrows=0
  assert_eq(rd_tag(" a ,b", rcfg(11)), "OK:hdr= a |b;nrows=0") // r.21.11|OK:hdr= a |b;nrows=0
  assert_eq(rd_tag("a,b\nc", rcfg(11)), "OK:hdr=a|b;[1]c/;nrows=1;byName=c") // r.22.11|OK:hdr=a|b;[1]c/;nrows=1;byName=c
  assert_eq(
    rd_tag("h1,h2\nv1,v2\nv3,v4", rcfg(11)),
    "OK:hdr=h1|h2;[1]v1/v2/;[2]v3/v4/;nrows=2;byName=<null>",
  ) // r.23.11|OK:hdr=h1|h2;[1]v1/v2/;[2]v3/v4/;nrows=2;byName=<null>
  assert_eq(
    rd_tag("h1,h2\nv1", rcfg(11)),
    "OK:hdr=h1|h2;[1]v1/;nrows=1;byName=<null>",
  ) // r.24.11|OK:hdr=h1|h2;[1]v1/;nrows=1;byName=<null>
  assert_eq(rd_tag("a;b,c", rcfg(11)), "OK:hdr=a;b|c;nrows=0") // r.25.11|OK:hdr=a;b|c;nrows=0
  assert_eq(rd_tag("\"a\",\"\"", rcfg(11)), "OK:hdr=a|;nrows=0") // r.26.11|OK:hdr=a|;nrows=0
  assert_eq(rd_tag("a,b,", rcfg(11)), "OK:hdr=a|b|;nrows=0") // r.27.11|OK:hdr=a|b|;nrows=0
  assert_eq(rd_tag("a,中文,c", rcfg(11)), "OK:hdr=a|中文|c;nrows=0") // r.28.11|OK:hdr=a|中文|c;nrows=0
  assert_eq(rd_tag("\"a\u{0000}b\",c", rcfg(11)), "OK:hdr=a\u{0000}b|c;nrows=0") // r.29.11|OK:hdr=a\u{0000}b|c;nrows=0
  assert_eq(rd_tag("a", rcfg(11)), "OK:hdr=a;nrows=0") // r.30.11|OK:hdr=a;nrows=0
  assert_eq(
    rd_tag("x,y\n\"unclosed,z", rcfg(11)),
    "OK:hdr=x|y;[1]unclosed,z/;nrows=1;byName=unclosed,z",
  ) // r.31.11|OK:hdr=x|y;[1]unclosed,z/;nrows=1;byName=unclosed,z
}

///|
test "csv 写：12 个行集 x 7 档配置" {
  assert_eq(wr_tag(wrow(0), wopts(0)), "OK:a,b\r\nz1,z2") // w.0.0|OK:a,b\r\nz1,z2
  assert_eq(wr_tag(wrow(1), wopts(0)), "OK:\"a,b\",c\r\nz1,z2") // w.1.0|OK:\"a,b\",c\r\nz1,z2
  assert_eq(wr_tag(wrow(2), wopts(0)), "OK:\"a\"\"b\",c\r\nz1,z2") // w.2.0|OK:\"a\"\"b\",c\r\nz1,z2
  assert_eq(wr_tag(wrow(3), wopts(0)), "OK:\"a\nb\",c\r\nz1,z2") // w.3.0|OK:\"a\nb\",c\r\nz1,z2
  assert_eq(wr_tag(wrow(4), wopts(0)), "OK:\"a\r\nb\"\r\nz1,z2") // w.4.0|OK:\"a\r\nb\"\r\nz1,z2
  assert_eq(wr_tag(wrow(5), wopts(0)), "OK:\r\nz1,z2") // w.5.0|OK:\r\nz1,z2
  assert_eq(wr_tag(wrow(6), wopts(0)), "OK:,b\r\nz1,z2") // w.6.0|OK:,b\r\nz1,z2
  assert_eq(wr_tag(wrow(7), wopts(0)), "OK: a ,b\r\nz1,z2") // w.7.0|OK: a ,b\r\nz1,z2
  assert_eq(wr_tag(wrow(8), wopts(0)), "OK:a,\r\nz1,z2") // w.8.0|OK:a,\r\nz1,z2
  assert_eq(wr_tag(wrow(9), wopts(0)), "OK:中文,x\r\nz1,z2") // w.9.0|OK:中文,x\r\nz1,z2
  assert_eq(wr_tag(wrow(10), wopts(0)), "OK:a\r\nz1,z2") // w.10.0|OK:a\r\nz1,z2
  assert_eq(wr_tag(wrow(11), wopts(0)), "OK:\"\"\"a\"\"\",b\r\nz1,z2") // w.11.0|OK:\"\"\"a\"\"\",b\r\nz1,z2
  assert_eq(wr_tag(wrow(0), wopts(1)), "OK:\"a\",\"b\"\r\n\"z1\",\"z2\"") // w.0.1|OK:\"a\",\"b\"\r\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(1), wopts(1)), "OK:\"a,b\",\"c\"\r\n\"z1\",\"z2\"") // w.1.1|OK:\"a,b\",\"c\"\r\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(2), wopts(1)), "OK:\"a\"\"b\",\"c\"\r\n\"z1\",\"z2\"") // w.2.1|OK:\"a\"\"b\",\"c\"\r\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(3), wopts(1)), "OK:\"a\nb\",\"c\"\r\n\"z1\",\"z2\"") // w.3.1|OK:\"a\nb\",\"c\"\r\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(4), wopts(1)), "OK:\"a\r\nb\"\r\n\"z1\",\"z2\"") // w.4.1|OK:\"a\r\nb\"\r\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(5), wopts(1)), "OK:\"\"\r\n\"z1\",\"z2\"") // w.5.1|OK:\"\"\r\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(6), wopts(1)), "OK:\"\",\"b\"\r\n\"z1\",\"z2\"") // w.6.1|OK:\"\",\"b\"\r\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(7), wopts(1)), "OK:\" a \",\"b\"\r\n\"z1\",\"z2\"") // w.7.1|OK:\" a \",\"b\"\r\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(8), wopts(1)), "OK:\"a\",\"\"\r\n\"z1\",\"z2\"") // w.8.1|OK:\"a\",\"\"\r\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(9), wopts(1)), "OK:\"中文\",\"x\"\r\n\"z1\",\"z2\"") // w.9.1|OK:\"中文\",\"x\"\r\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(10), wopts(1)), "OK:\"a\"\r\n\"z1\",\"z2\"") // w.10.1|OK:\"a\"\r\n\"z1\",\"z2\"
  assert_eq(
    wr_tag(wrow(11), wopts(1)),
    "OK:\"\"\"a\"\"\",\"b\"\r\n\"z1\",\"z2\"",
  ) // w.11.1|OK:\"\"\"a\"\"\",\"b\"\r\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(0), wopts(2)), "OK:a,b\nz1,z2") // w.0.2|OK:a,b\nz1,z2
  assert_eq(wr_tag(wrow(1), wopts(2)), "OK:\"a,b\",c\nz1,z2") // w.1.2|OK:\"a,b\",c\nz1,z2
  assert_eq(wr_tag(wrow(2), wopts(2)), "OK:\"a\"\"b\",c\nz1,z2") // w.2.2|OK:\"a\"\"b\",c\nz1,z2
  assert_eq(wr_tag(wrow(3), wopts(2)), "OK:\"a\nb\",c\nz1,z2") // w.3.2|OK:\"a\nb\",c\nz1,z2
  assert_eq(wr_tag(wrow(4), wopts(2)), "OK:\"a\r\nb\"\nz1,z2") // w.4.2|OK:\"a\r\nb\"\nz1,z2
  assert_eq(wr_tag(wrow(5), wopts(2)), "OK:\nz1,z2") // w.5.2|OK:\nz1,z2
  assert_eq(wr_tag(wrow(6), wopts(2)), "OK:,b\nz1,z2") // w.6.2|OK:,b\nz1,z2
  assert_eq(wr_tag(wrow(7), wopts(2)), "OK: a ,b\nz1,z2") // w.7.2|OK: a ,b\nz1,z2
  assert_eq(wr_tag(wrow(8), wopts(2)), "OK:a,\nz1,z2") // w.8.2|OK:a,\nz1,z2
  assert_eq(wr_tag(wrow(9), wopts(2)), "OK:中文,x\nz1,z2") // w.9.2|OK:中文,x\nz1,z2
  assert_eq(wr_tag(wrow(10), wopts(2)), "OK:a\nz1,z2") // w.10.2|OK:a\nz1,z2
  assert_eq(wr_tag(wrow(11), wopts(2)), "OK:\"\"\"a\"\"\",b\nz1,z2") // w.11.2|OK:\"\"\"a\"\"\",b\nz1,z2
  assert_eq(wr_tag(wrow(0), wopts(3)), "OK:a,b\r\nz1,z2") // w.0.3|OK:a,b\r\nz1,z2
  assert_eq(wr_tag(wrow(1), wopts(3)), "OK:\"a,b\",c\r\nz1,z2") // w.1.3|OK:\"a,b\",c\r\nz1,z2
  assert_eq(wr_tag(wrow(2), wopts(3)), "OK:\"a\"\"b\",c\r\nz1,z2") // w.2.3|OK:\"a\"\"b\",c\r\nz1,z2
  assert_eq(wr_tag(wrow(3), wopts(3)), "OK:\"a\nb\",c\r\nz1,z2") // w.3.3|OK:\"a\nb\",c\r\nz1,z2
  assert_eq(wr_tag(wrow(4), wopts(3)), "OK:\"a\r\nb\"\r\nz1,z2") // w.4.3|OK:\"a\r\nb\"\r\nz1,z2
  assert_eq(wr_tag(wrow(5), wopts(3)), "OK:\r\nz1,z2") // w.5.3|OK:\r\nz1,z2
  assert_eq(wr_tag(wrow(6), wopts(3)), "OK:,b\r\nz1,z2") // w.6.3|OK:,b\r\nz1,z2
  assert_eq(wr_tag(wrow(7), wopts(3)), "OK: a ,b\r\nz1,z2") // w.7.3|OK: a ,b\r\nz1,z2
  assert_eq(wr_tag(wrow(8), wopts(3)), "OK:a,\r\nz1,z2") // w.8.3|OK:a,\r\nz1,z2
  assert_eq(wr_tag(wrow(9), wopts(3)), "OK:中文,x\r\nz1,z2") // w.9.3|OK:中文,x\r\nz1,z2
  assert_eq(wr_tag(wrow(10), wopts(3)), "OK:a\r\nz1,z2") // w.10.3|OK:a\r\nz1,z2
  assert_eq(wr_tag(wrow(11), wopts(3)), "OK:\"\"\"a\"\"\",b\r\nz1,z2") // w.11.3|OK:\"\"\"a\"\"\",b\r\nz1,z2
  assert_eq(wr_tag(wrow(0), wopts(4)), "OK:a;b\r\nz1;z2") // w.0.4|OK:a;b\r\nz1;z2
  assert_eq(wr_tag(wrow(1), wopts(4)), "OK:a,b;c\r\nz1;z2") // w.1.4|OK:a,b;c\r\nz1;z2
  assert_eq(wr_tag(wrow(2), wopts(4)), "OK:\"a\"\"b\";c\r\nz1;z2") // w.2.4|OK:\"a\"\"b\";c\r\nz1;z2
  assert_eq(wr_tag(wrow(3), wopts(4)), "OK:\"a\nb\";c\r\nz1;z2") // w.3.4|OK:\"a\nb\";c\r\nz1;z2
  assert_eq(wr_tag(wrow(4), wopts(4)), "OK:\"a\r\nb\"\r\nz1;z2") // w.4.4|OK:\"a\r\nb\"\r\nz1;z2
  assert_eq(wr_tag(wrow(5), wopts(4)), "OK:\r\nz1;z2") // w.5.4|OK:\r\nz1;z2
  assert_eq(wr_tag(wrow(6), wopts(4)), "OK:;b\r\nz1;z2") // w.6.4|OK:;b\r\nz1;z2
  assert_eq(wr_tag(wrow(7), wopts(4)), "OK: a ;b\r\nz1;z2") // w.7.4|OK: a ;b\r\nz1;z2
  assert_eq(wr_tag(wrow(8), wopts(4)), "OK:a;\r\nz1;z2") // w.8.4|OK:a;\r\nz1;z2
  assert_eq(wr_tag(wrow(9), wopts(4)), "OK:中文;x\r\nz1;z2") // w.9.4|OK:中文;x\r\nz1;z2
  assert_eq(wr_tag(wrow(10), wopts(4)), "OK:a\r\nz1;z2") // w.10.4|OK:a\r\nz1;z2
  assert_eq(wr_tag(wrow(11), wopts(4)), "OK:\"\"\"a\"\"\";b\r\nz1;z2") // w.11.4|OK:\"\"\"a\"\"\";b\r\nz1;z2
  assert_eq(wr_tag(wrow(0), wopts(5)), "OK:a,b\r\nz1,z2") // w.0.5|OK:a,b\r\nz1,z2
  assert_eq(wr_tag(wrow(1), wopts(5)), "OK:'a,b',c\r\nz1,z2") // w.1.5|OK:'a,b',c\r\nz1,z2
  assert_eq(wr_tag(wrow(2), wopts(5)), "OK:a\"b,c\r\nz1,z2") // w.2.5|OK:a\"b,c\r\nz1,z2
  assert_eq(wr_tag(wrow(3), wopts(5)), "OK:'a\nb',c\r\nz1,z2") // w.3.5|OK:'a\nb',c\r\nz1,z2
  assert_eq(wr_tag(wrow(4), wopts(5)), "OK:'a\r\nb'\r\nz1,z2") // w.4.5|OK:'a\r\nb'\r\nz1,z2
  assert_eq(wr_tag(wrow(5), wopts(5)), "OK:\r\nz1,z2") // w.5.5|OK:\r\nz1,z2
  assert_eq(wr_tag(wrow(6), wopts(5)), "OK:,b\r\nz1,z2") // w.6.5|OK:,b\r\nz1,z2
  assert_eq(wr_tag(wrow(7), wopts(5)), "OK: a ,b\r\nz1,z2") // w.7.5|OK: a ,b\r\nz1,z2
  assert_eq(wr_tag(wrow(8), wopts(5)), "OK:a,\r\nz1,z2") // w.8.5|OK:a,\r\nz1,z2
  assert_eq(wr_tag(wrow(9), wopts(5)), "OK:中文,x\r\nz1,z2") // w.9.5|OK:中文,x\r\nz1,z2
  assert_eq(wr_tag(wrow(10), wopts(5)), "OK:a\r\nz1,z2") // w.10.5|OK:a\r\nz1,z2
  assert_eq(wr_tag(wrow(11), wopts(5)), "OK:\"a\",b\r\nz1,z2") // w.11.5|OK:\"a\",b\r\nz1,z2
  assert_eq(wr_tag(wrow(0), wopts(6)), "OK:\"a\",\"b\"\n\"z1\",\"z2\"") // w.0.6|OK:\"a\",\"b\"\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(1), wopts(6)), "OK:\"a,b\",\"c\"\n\"z1\",\"z2\"") // w.1.6|OK:\"a,b\",\"c\"\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(2), wopts(6)), "OK:\"a\"\"b\",\"c\"\n\"z1\",\"z2\"") // w.2.6|OK:\"a\"\"b\",\"c\"\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(3), wopts(6)), "OK:\"a\nb\",\"c\"\n\"z1\",\"z2\"") // w.3.6|OK:\"a\nb\",\"c\"\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(4), wopts(6)), "OK:\"a\r\nb\"\n\"z1\",\"z2\"") // w.4.6|OK:\"a\r\nb\"\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(5), wopts(6)), "OK:\"\"\n\"z1\",\"z2\"") // w.5.6|OK:\"\"\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(6), wopts(6)), "OK:\"\",\"b\"\n\"z1\",\"z2\"") // w.6.6|OK:\"\",\"b\"\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(7), wopts(6)), "OK:\" a \",\"b\"\n\"z1\",\"z2\"") // w.7.6|OK:\" a \",\"b\"\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(8), wopts(6)), "OK:\"a\",\"\"\n\"z1\",\"z2\"") // w.8.6|OK:\"a\",\"\"\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(9), wopts(6)), "OK:\"中文\",\"x\"\n\"z1\",\"z2\"") // w.9.6|OK:\"中文\",\"x\"\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(10), wopts(6)), "OK:\"a\"\n\"z1\",\"z2\"") // w.10.6|OK:\"a\"\n\"z1\",\"z2\"
  assert_eq(wr_tag(wrow(11), wopts(6)), "OK:\"\"\"a\"\"\",\"b\"\n\"z1\",\"z2\"") // w.11.6|OK:\"\"\"a\"\"\",\"b\"\n\"z1\",\"z2\"
}
