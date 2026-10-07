#!/usr/bin/env python
# csv 第八批补档生成器：把 Csv2Leg.java 的读数灌成 csv/csv_default_test.mbt。
# 一条断言一个 test 块；期望只从腿的读数取，手打零条。
# 用法：python scripts/gen_csv2_test.py <csv2_leg.txt>
import io
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if len(sys.argv) < 2:
    raise SystemExit("用法：python scripts/gen_csv2_test.py <csv2_leg.txt>")
LEG = os.path.abspath(sys.argv[1])
OUT = os.path.join(REPO, "csv", "csv_default_test.mbt")

# 本批不钉的档（都在 §7 登记，理由是"两侧形状不同源，钉任一侧都是替对方立法"）：
#   默认写出档 WR/WRQ/WRE —— 参照的 CsvWriter 在本轮读数里 flush/close 都不带行分隔符，
#   与本库 csv_write 的"CRLF + 末尾追加换行"不同形（要先读清参照的分隔符时机才谈对撞）
SKIP_PREFIX = ("WR",)
# 参照在空串上抛 NumberFormatException（`Long.parseLong("")` 走 `beginLineNo` 那条），
# 本库给零行 ⇒ 没有已有决策行可指，登记不钉（见 docs/spec/21-csv.md §8）
SKIP_NAMES = {"parse-empty_text", "skip-empty_text"}

HEAD = '''///|
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
      '\\r' => out + "{CR}"
      '\\n' => out + "{LF}"
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
      s = s + c2_ascii(match row.get(j) {
        Some(v) => v
        None => "<none>"
      })
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
  try {
    c2_dump(@csv.csv_parse_with_opts(text, c2_opts(false)))
  } catch {
    _ => "ERR"
  }
}

///|
fn c2_parse_skip(text : String) -> String {
  // 本库默认档（skip=true）走 csv_parse——这件此前一条用例都没打到
  try {
    c2_dump(@csv.csv_parse(text))
  } catch {
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

'''


def lit(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def cps_to_moonbit(cps):
    if cps == "":
        return '""'
    out = ['"']
    for h in cps.split("+"):
        cp = int(h, 16)
        if 0x20 <= cp <= 0x7E and cp not in (0x22, 0x5C):
            out.append(chr(cp))
        else:
            out.append("\\u{%x}" % cp)
    out.append('"')
    return "".join(out)


BLOCKS = []


def blk(name, comment, expr):
    if name in SKIP_NAMES:
        return
    BLOCKS.append((name, comment, expr))


def main():
    for raw in io.open(LEG, encoding="utf-8", errors="replace").read().replace("\r", "").splitlines():
        f = raw.split("|")
        k = f[0]
        if k == "G" or len(f) < 3:
            continue
        if any(k.startswith(p) for p in SKIP_PREFIX):
            continue
        name, cps, val = f[1], f[2], "|".join(f[3:]).replace("{bar}", "|")
        if k == "RD":
            exp = "ERR" if val.startswith("ERR") else val
            blk("parse-" + name,
                "csv_parse_with_opts(skip=false) ｜ 码点=%s ｜ 参照=%s%s" % (cps, val, "" if exp == val else "（参照抛、本库也抛，只钉抛不抛）"),
                "assert_eq(c2_parse(%s), %s)" % (cps_to_moonbit(cps), lit(exp)))
        elif k == "RS":
            exp = "ERR" if val.startswith("ERR") else val
            blk("skip-" + name,
                "csv_parse（本库默认档 skip=true）｜ 码点=%s ｜ 参照 skipEmptyRows=true=%s" % (cps, val),
                "assert_eq(c2_parse_skip(%s), %s)" % (cps_to_moonbit(cps), lit(exp)))
        elif k == "OOB":
            blk("oob-" + name,
                "越界档 ｜ 码点=%s ｜ 参照=%s（本库给 None，spec 21-csv §5 第 4 行已声明）" % (cps, val),
                "assert_eq(c2_oob(%s), \"row[-1]=None row[n]=None field[-1]=None field[n]=None\")"
                % cps_to_moonbit(cps))

    body = HEAD + "\n\n".join(
        '///|\ntest "csv 默认档 %s" {\n  // %s\n  %s\n}' % (n, c, e) for n, c, e in BLOCKS) + "\n"
    io.open(OUT, "w", encoding="utf-8", newline="\n").write(body)
    print("blocks=%d file=%s" % (len(BLOCKS), OUT))


main()
