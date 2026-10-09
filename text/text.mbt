///|
/// moon-hutool/text —— 字符串门面（hutool `StrUtil`/`CharSequenceUtil` 的 MoonBit 对位）
///
/// 契约：`docs/spec/01-text.md`；用例：`text_test.mbt` + `README.mbt.md`（两层都真跑）。
/// 边界与差异以 spec 表为准，实现只负责满足已冻结的期望值。
///
/// 三条贯穿性口径（本机编译器与 hutool 实测共同裁决，见 spec 1.1）：
/// 1. **入参一律 `String`**：MoonBit 无 null，不在每个函数上铺 `Option`；只有"缺失本身是业务语义"的
///    `trim_opt`、`first_non_blank` 保留 Option 形态。
/// 2. 空白判定 = core `Char::is_whitespace`（Unicode White_Space 子集）**并集** hutool 独有的 7 个码点；
///    U+0000 算空白这条必须保留（多数实现会漏）。
/// 3. **视图类型不作对外契约**：`String` 字面量不隐式转 `StringView`、`String` 也没有 `as_view` ⇒
///    返回值一律给 `String`。
///
/// 索引口径：core 的 `find`/`length()` 按 **UTF-16 code unit**，而 `hide`、命名法、`format` 按 **码点**。
/// 两套下标混用是这类库最常见的错源，故本包**不用切片语法**，一律走 `substring_units`（按 UTF-16 单元
/// 取子串，内部逐 char 累加 `utf16_len()`，不会切进代理对）或"逐 char 重建"。

///|
/// 是否为空白：空串、或全为空白字符判真（hutool `StrUtil.isBlank`）
pub fn is_blank(s : String) -> Bool {
  s.iter().all(c => is_blank_char(c))
}

///|
/// 是否为空：长度为 0（hutool `isEmpty`）——与 `is_blank` 分档，不合并
pub fn is_empty(s : String) -> Bool {
  s.length() == 0
}

///|
/// 空白字符判定：hutool `CharUtil.isBlankChar` 的**实测码表**（整 BMP 逐位扫，35 位）。
/// 公开的原因不是"给用户一个谓词"，是本仓只许有一张这样的表——`ini`（`is_blank_cp`）与
/// `typex`（`ds_is_blank`）原先各抄一份，三份互不相同：本包多算了 U+0085、少算了 U+001C–U+001F，
/// `typex` 少算了 U+0000/U+180E/U+2800/U+3164，`ini` 少算了 U+200C。腿（`scripts/BlankScanLeg.java`）
/// 对五个出口（`isBlank`/`trim`/`cleanBlank`/`encodeBlank`/`isBlankChar`）逐位对撞，
/// 命中集**完全一致** ⇒ 参照那边本来就是一条谓词，三份副本是移植时抄漏，不是刻意的分档。
/// 与 core `Char::is_whitespace` 的四处差（U+0085 参照不算、U+001C–U+001F 参照算、
/// U+200C 是 5.8.37 才加进 `isBlankChar` 的）一律**跟参照**，见 spec 1.1 第 3 行的更正。
pub fn is_blank_char(c : Char) -> Bool {
  let cp = c.to_int()
  cp == 0 ||
  (cp >= 9 && cp <= 13) ||
  (cp >= 0x1c && cp <= 0x20) ||
  cp == 0xa0 ||
  cp == 0x1680 ||
  cp == 0x180e ||
  (cp >= 0x2000 && cp <= 0x200a) ||
  cp == 0x200c ||
  (cp >= 0x2028 && cp <= 0x202a) ||
  cp == 0x202f ||
  cp == 0x205f ||
  cp == 0x2800 ||
  cp == 0x3000 ||
  cp == 0x3164 ||
  cp == 0xfeff
}

///|
/// 按 UTF-16 单元区间 `[lo, hi)` 取子串（`find`/`length()` 的读数可直接当单元数用）
fn substring_units(s : String, lo : Int, hi : Int) -> String {
  let buf = StringBuilder()
  let mut acc = 0
  for c in s.iter() {
    if acc >= hi {
      break
    }
    if acc >= lo {
      buf.write_char(c)
    }
    acc += c.utf16_len()
  }
  buf.to_string()
}

///|
/// 去两端空白（hutool `trim`）——按本库的空白档判定，不借 core `trim` 的白名单
pub fn trim(s : String) -> String {
  let cs = s.iter().collect()
  let n = cs.length()
  let mut i = 0
  let mut j = n
  while i < j && is_blank_char(cs[i]) {
    i += 1
  }
  while j > i && is_blank_char(cs[j - 1]) {
    j -= 1
  }
  rebuild(cs, i, j)
}

///|
/// Option 形态的去空白：`None` 透传 `None`（hutool `trimToNull`——只管 null，全空白仍出空串）
pub fn trim_opt(s : String?) -> String? {
  match s {
    None => None
    Some(v) => Some(trim(v))
  }
}

///|
/// 按分隔符切分，`trim_result` 为真时逐段去空白（hutool `splitTrim`）
///
/// 空输入返回**空数组**；连续分隔符**保留空段**（Java `String.split` 会吞尾空串，差异见 spec 1.5）
pub fn split(
  s : String,
  sep : Char,
  trim_result? : Bool = false,
) -> Array[String] {
  if s.is_empty() {
    []
  } else {
    let parts = s.split(sep.to_string()).to_array().map(v => v.to_owned())
    if trim_result {
      parts.map(v => trim(v))
    } else {
      parts
    }
  }
}

///|
/// 用分隔符连接（hutool `CollUtil.join`）
pub fn join(items : Array[String], sep : String) -> String {
  let buf = StringBuilder()
  for i in 0..<items.length() {
    if i > 0 {
      buf.write_string(sep)
    }
    buf.write_string(items[i])
  }
  buf.to_string()
}

///|
/// 取分隔符**之前**的部分；未命中返回整串（hutool `subBefore`）
pub fn sub_before(s : String, sep : String) -> String {
  match s.find(sep) {
    None => s
    Some(i) => substring_units(s, 0, i)
  }
}

///|
/// 取分隔符**之后**的部分；未命中返回空串（hutool `subAfter`，与 `sub_before` 不对称）
pub fn sub_after(s : String, sep : String) -> String {
  match s.find(sep) {
    None => ""
    Some(i) => substring_units(s, i + sep.length(), s.length())
  }
}

///|
/// 取两个界定符之间的内容；任一未命中返回空串（hutool `subBetween`）
pub fn sub_between(
  s : String,
  left : String,
  right : String,
  include_sep? : Bool = false,
) -> String {
  match s.find(left) {
    None => ""
    Some(li) => {
      let from = li + left.length()
      let tail = substring_units(s, from, s.length())
      match tail.find(right) {
        None => ""
        Some(ri) =>
          if include_sep {
            // 带界定符档：左界要从 li 起算（from 已经把左界定符跳过去了）
            substring_units(s, li, from + ri + right.length())
          } else {
            substring_units(s, from, from + ri)
          }
      }
    }
  }
}

///|
/// `{}` 占位格式化（hutool `StrUtil.format` → `StrFormatter`）
///
/// 三条硬语义：前一字符是 `\` 的 `{}` 当字面量并吃掉那个反斜杠；参数少于占位符时**未填的原样留着**；
/// 位置索引语法 `{0}` 不做（JDK `MessageFormat` 的语义，与 `{}` 不同）
pub fn format(template : String, args : Array[String]) -> String {
  let cs = template.iter().collect()
  let n = cs.length()
  let buf = StringBuilder()
  let mut ai = 0
  let mut i = 0
  while i < n {
    if cs[i] == '\\' && i + 2 < n && cs[i + 1] == '{' && cs[i + 2] == '}' {
      // 转义档：`\{}` 出字面 `{}`，反斜杠被吃掉
      buf.write_string("{}")
      i += 3
    } else if i + 1 < n && cs[i] == '{' && cs[i + 1] == '}' {
      if ai < args.length() {
        buf.write_string(args[ai])
        ai += 1
      } else {
        buf.write_string("{}")
      }
      i += 2
    } else {
      buf.write_char(cs[i])
      i += 1
    }
  }
  buf.to_string()
}

///|
/// 版本串比较：逐段取前导数字按数值比，缺段补零（hutool `compareVersion`）
///
/// 返回归一到 `-1 / 0 / 1`；数字段相等时再按剩余后缀比（spec 1.9）
pub fn compare_version(a : String, b : String) -> Int {
  let pa = a.split(".").to_array()
  let pb = b.split(".").to_array()
  let n = if pa.length() > pb.length() { pa.length() } else { pb.length() }
  for i in 0..<n {
    let sa = if i < pa.length() { pa[i] } else { "" }
    let sb = if i < pb.length() { pb[i] } else { "" }
    let (na, ta) = leading_number(sa)
    let (nb, tb) = leading_number(sb)
    if na != nb {
      return if na < nb { -1 } else { 1 }
    }
    if ta != tb {
      return if ta < tb { -1 } else { 1 }
    }
  }
  0
}

///|
/// 取一段的前导十进制数与剩余串（`"10-beta"` → `(10, "-beta")`；无数字 → `(0, 原串)`）
fn leading_number(seg : StringView) -> (Int, String) {
  let cs = seg.iter().collect()
  let mut v = 0
  let mut i = 0
  while i < cs.length() && cs[i] >= '0' && cs[i] <= '9' {
    v = v * 10 + (cs[i].to_int() - '0'.to_int())
    i += 1
  }
  (v, rebuild(cs, i, cs.length()))
}

///|
/// 返回第一个非空白项，全空白给 `None`（hutool `firstNonBlank`）
pub fn first_non_blank(candidates : Array[String?]) -> String? {
  for c in candidates {
    match c {
      Some(v) => if !is_blank(v) { return Some(v) }
      None => ()
    }
  }
  None
}

///|
/// 区间掩码：`[start, end)` 用 `mask` 替换（hutool `CharSequenceUtil.hide`）
///
/// 下标按**码点**计；越界夹紧不报错；`start >= end` 时原样返回（spec 1.11）
pub fn hide(s : String, start : Int, end : Int, mask : Char) -> String {
  let cs = s.iter().collect()
  let n = cs.length()
  let lo = if start < 0 { 0 } else if start > n { n } else { start }
  let hi = if end > n { n } else if end < 0 { 0 } else { end }
  if lo >= hi {
    s
  } else {
    let buf = StringBuilder()
    for i in 0..<n {
      buf.write_char(if i >= lo && i < hi { mask } else { cs[i] })
    }
    buf.to_string()
  }
}

///|
/// 下划线（蛇形）命名：`userName` → `user_name`、`HTTPServer` → `http_server`
///
/// 规则坑（spec 1.12）：连续大写当专有名词不拆，只在"大写串尾、后面接小写"处断开一次；首字母转小写
pub fn to_underline_case(name : String) -> String {
  to_symbol_case(name, '_')
}

///|
/// 连字符命名（kebab-case）：同 `to_underline_case`，分隔符换成 `-`
pub fn to_kebab_case(name : String) -> String {
  to_symbol_case(name, '-')
}

///|
/// 分隔符命名的共用实现（hutool `NamingCase.toSymbolCase`）
fn to_symbol_case(name : String, symbol : Char) -> String {
  let cs = name.iter().collect()
  let n = cs.length()
  let buf = StringBuilder()
  for i in 0..<n {
    let c = cs[i]
    if is_upper(c) {
      // 越界位用空格当哨兵：is_upper/is_lower/is_digit 对空格全为假，等价于"没有前/后字符"
      let prev = if i > 0 { cs[i - 1] } else { ' ' }
      let next = if i + 1 < n { cs[i + 1] } else { ' ' }
      let break_before = is_lower(prev) ||
        is_digit(prev) ||
        (is_upper(prev) && is_lower(next))
      if break_before {
        buf.write_char(symbol)
      }
      buf.write_char(c.to_ascii_lowercase())
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
/// 驼峰命名：**只在含 `_` 时转换**，否则原样返回（hutool `toCamelCase` 的真实行为，别当幂等化简）；
/// 转换时分隔符后一位取大写、其余字符全部转小写
pub fn to_camel_case(name : String) -> String {
  if !name.contains("_") {
    name
  } else {
    let buf = StringBuilder()
    let mut up_next = false
    for c in name.iter() {
      if c == '_' {
        up_next = true
      } else if up_next {
        buf.write_char(c.to_ascii_uppercase())
        up_next = false
      } else {
        buf.write_char(c.to_ascii_lowercase())
      }
    }
    buf.to_string()
  }
}

///|
/// 帕斯卡命名：`upperFirst(toCamelCase(name))`（hutool `toPascalCase`）
pub fn to_pascal_case(name : String) -> String {
  upper_first(to_camel_case(name))
}

///|
/// 首字母大写（**ASCII 档**；非 ASCII 原样——core 只有 ASCII 大小写映射，本库不假装 Unicode）
pub fn upper_first(s : String) -> String {
  flip_first(s, true)
}

///|
/// 首字母小写（同上，ASCII 档）
pub fn lower_first(s : String) -> String {
  flip_first(s, false)
}

///|
/// 首字母大小写翻转的共用实现
fn flip_first(s : String, upper : Bool) -> String {
  let cs = s.iter().collect()
  if cs.length() == 0 {
    ""
  } else {
    let buf = StringBuilder()
    let f = cs[0]
    buf.write_char(
      if upper {
        f.to_ascii_uppercase()
      } else {
        f.to_ascii_lowercase()
      },
    )
    for i in 1..<cs.length() {
      buf.write_char(cs[i])
    }
    buf.to_string()
  }
}

///|
/// ASCII 大写判定（命名法只在 ASCII 区间有意义，非 ASCII 一律原样透传）
fn is_upper(c : Char) -> Bool {
  c >= 'A' && c <= 'Z'
}

///|
/// ASCII 小写判定
fn is_lower(c : Char) -> Bool {
  c >= 'a' && c <= 'z'
}

///|
/// 数字判定
fn is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
/// 从 char 数组的 `[from, to)` 区间重建字符串（trim / leading_number 的共用出口）
fn rebuild(cs : Array[Char], from : Int, to : Int) -> String {
  let buf = StringBuilder()
  for i in from..<to {
    buf.write_char(cs[i])
  }
  buf.to_string()
}
