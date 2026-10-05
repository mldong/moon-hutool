// path 包的内部机器（不进公开面）：行序照参照实现 `AntPathMatcher.java` 逐段搬——
// · `do_match` ← 208~330 行（四段结构，`**` 只在**整段 token** 上起作用）
// · `match_seg` ← 644~698 行（GLOB 表：`?`→`.`、`*`→`.*`、`{name}`→`(.*)`、`{name:re}`→`(re)`，
//   一个 glob 字符都没有就是整段等值比较）
// · `extract_within` ← 494~514 行（**不调 do_match**，只看模式里带 `*`/`?` 的那一段往后拼）
// · `combine` ← 554~618 行（五条前置分支 + `concat`）
// · `compare_patterns` ← 780~880 行（PatternInfo 计数 + 七级判定）
//
// 抽取面的三档抛点只在看得到 `vars` 时才可能触发（参照实现同一条：纯匹配面不抛）。

///|
priv struct SegPlan {
  exact : Bool
  raw : String
  re : String
  names : Array[String]
  // 用户子表达式自带的捕获组数：参照实现拿它跟变量数比，不等就抛（实测档 `{n:(a)(b)}`）
  extra_groups : Int
}

///|
fn is_glob_char(c : Char) -> Bool {
  c == '*' || c == '?' || c == '{'
}

///|
fn regex_meta(c : Char) -> Bool {
  match c {
    '.'
    | '^'
    | '$'
    | '*'
    | '+'
    | '?'
    | '('
    | ')'
    | '['
    | ']'
    | '{'
    | '}'
    | '|'
    | '\\' => true
    _ => false
  }
}

///|
fn quote_literal(s : String) -> String {
  let out = StringBuilder()
  for c in s.to_array() {
    if regex_meta(c) {
      out.write_char('\\')
    }
    out.write_char(c)
  }
  out.to_string()
}

///|
// 括号配对：参照实现的 GLOB 允许一层嵌套（`{path:[a-z]{2}}`），这里跟同一层深度。
fn find_close_brace(cs : Array[Char], from : Int) -> Int {
  let mut depth = 0
  let mut i = from
  let mut hit = -1
  while i < cs.length() && hit < 0 {
    if cs[i] == '{' {
      depth = depth + 1
    } else if cs[i] == '}' {
      depth = depth - 1
      if depth == 0 {
        hit = i
      }
    }
    i = i + 1
  }
  hit
}

///|
fn count_capture_groups(re : String) -> Int {
  let cs = re.to_array()
  let mut n = 0
  let mut i = 0
  let mut esc = false
  while i < cs.length() {
    let c = cs[i]
    if esc {
      esc = false
    } else if c == '\\' {
      esc = true
    } else if c == '(' {
      if !(i + 1 < cs.length() && cs[i + 1] == '?') {
        n = n + 1
      }
    }
    i = i + 1
  }
  n
}

///|
fn chars_of(cs : Array[Char], lo : Int, hi : Int) -> Array[Char] {
  // 半开区间 [lo, hi)。这里不写 `for k in lo..hi`——那层端点语义（Range 含尾 vs IntRange 不含）
  // 本轮实测吃掉过一个变量名（`{name}` 抽出来的键带了尾括号），不赌，手写 while。
  let out : Array[Char] = []
  let mut k = lo
  while k < hi {
    if k >= 0 && k < cs.length() {
      out.push(cs[k])
    }
    k = k + 1
  }
  out
}

///|
fn chars_to_string(cs : Array[Char]) -> String {
  let out = StringBuilder()
  for c in cs {
    out.write_char(c)
  }
  out.to_string()
}

///|
fn index_of_char(cs : Array[Char], c : Char) -> Int {
  let mut i = 0
  let mut hit = -1
  while i < cs.length() && hit < 0 {
    if cs[i] == c {
      hit = i
    }
    i = i + 1
  }
  hit
}

///|
fn has_glob(cs : Array[Char]) -> Bool {
  let mut i = 0
  let mut found = false
  while i < cs.length() && !found {
    if is_glob_char(cs[i]) {
      found = true
    }
    i = i + 1
  }
  found
}

///|
// 按 **UTF-16 码元** 区间 `[lo, hi)` 取子串（承诺口径与 `re`/`text` 同一条：位置一律码元，不用切片语法）。
fn slice_units(s : String, lo : Int, hi : Int) -> String {
  let buf = StringBuilder()
  let mut acc = 0
  for c in s.iter() {
    if acc >= hi {
      break
    }
    if acc >= lo {
      buf.write_char(c)
    }
    acc = acc + c.utf16_len()
  }
  buf.to_string()
}

///|
fn flush_lit(out : StringBuilder, lit : Array[Char]) -> Unit {
  if lit.length() > 0 {
    out.write_string(quote_literal(chars_to_string(lit)))
    let dropped = lit.length()
    let mut k = 0
    while k < dropped {
      let _ : Char? = lit.pop()
      k = k + 1
    }
  }
}

///|
// 模式段 → core 正则（整段锚定）。`{` 不成对就整段按字面走——实测 `/{a` 对 `/x` 给假。
fn seg_plan(token : String) -> SegPlan {
  let cs = token.to_array()
  if !has_glob(cs) {
    SegPlan::{ exact: true, raw: token, re: "", names: [], extra_groups: 0, }
  } else {
    let out = StringBuilder()
    let names : Array[String] = []
    let mut extra = 0
    let lit : Array[Char] = []
    let mut i = 0
    while i < cs.length() {
      let c = cs[i]
      if c == '?' {
        flush_lit(out, lit)
        out.write_char('.')
        i = i + 1
      } else if c == '*' {
        flush_lit(out, lit)
        out.write_string(".*")
        i = i + 1
      } else if c == '{' {
        let close = find_close_brace(cs, i)
        if close < 0 {
          lit.push(c)
          i = i + 1
        } else {
          flush_lit(out, lit)
          let body = chars_of(cs, i + 1, close)
          let colon = index_of_char(body, ':')
          if colon < 0 {
            names.push(chars_to_string(body))
            out.write_string("(.*)")
          } else {
            names.push(chars_to_string(chars_of(body, 0, colon)))
            let sub = chars_to_string(chars_of(body, colon + 1, body.length()))
            out.write_char('(')
            out.write_string(sub)
            out.write_char(')')
            extra = extra + count_capture_groups(sub)
          }
          i = close + 1
        }
      } else {
        lit.push(c)
        i = i + 1
      }
    }
    flush_lit(out, lit)
    SegPlan::{
      exact: false,
      raw: token,
      re: "^(?:" + out.to_string() + ")$",
      names,
      extra_groups: extra,
    }
  }
}

///|
// 单段匹配，返回 `(是否匹配, 抽取面的错误档)`。`vars` 给 Some 才回填变量、才检查两处抛点。
fn match_seg(
  token : String,
  seg : String,
  opts : PathOptions,
  vars : Map[String, String]?,
) -> (Bool, PathError?) {
  let plan = seg_plan(token)
  let target = if opts.case_sensitive { seg } else { seg.to_lower() }
  if plan.exact {
    let want = if opts.case_sensitive { plan.raw } else { plan.raw.to_lower() }
    (want == target, None)
  } else if plan.extra_groups > 0 && vars is Some(_) {
    // 参照实现是在填变量时才数捕获组——纯匹配面这一档照样是真
    (true, Some(CaptureGroupRegex(plan.raw)))
  } else {
    let rx : @string.Regex? = Some(@string.Regex(plan.re.to_string_view())) catch {
      _ => None
    }
    match rx {
      // Java-only 写法（`\d` 等）在 core 方言里编不出来 ⇒ 匹配面给假，契约 §5 第 3 行
      None => (false, None)
      Some(r) =>
        match r.execute(target.to_string_view()) {
          None => (false, None)
          Some(_) =>
            match vars {
              None => (true, None)
              Some(map) => (true, fill_vars(map, plan, r, target))
            }
        }
    }
  }
}

///|
fn fill_vars(
  map : Map[String, String],
  plan : SegPlan,
  rx : @string.Regex,
  target : String,
) -> PathError? {
  if plan.names.length() > 0 {
    let first = plan.names[0]
    if first.has_prefix("*") {
      return Some(CapturingVar(first)) // 实测档：{*path} 在抽取面抛、在匹配面本来就是假
    }
  }
  match rx.execute(target.to_string_view()) {
    None => None
    Some(m) => {
      let mut i = 0
      while i < plan.names.length() {
        match m.group(i + 1) {
          Some(v) => map[plan.names[i]] = v.to_owned()
          None => map[plan.names[i]] = ""
        }
        i = i + 1
      }
      None
    }
  }
}

///|
// 拆段：**保留空段**，`trim` 才逐段去首尾空白。hutool 默认 `trimTokens=false`（Spring 原版是 true）。
fn tokenize(s : String, opts : PathOptions) -> Array[String] {
  let out : Array[String] = []
  let sep = opts.separator
  let n = s.length()
  if sep.length() == 0 {
    out.push(maybe_trim(s, opts.trim_tokens))
    return out
  }
  let mut start = 0
  let mut i = 0
  while i < n {
    if i + sep.length() <= n && slice_units(s, i, i + sep.length()) == sep {
      out.push(maybe_trim(slice_units(s, start, i), opts.trim_tokens))
      i = i + sep.length()
      start = i
    } else {
      i = i + 1
    }
  }
  out.push(maybe_trim(slice_units(s, start, n), opts.trim_tokens))
  out
}

///|
fn maybe_trim(s : String, trim : Bool) -> String {
  if trim {
    s.trim().to_owned()
  } else {
    s
  }
}

///|
fn starts_with_sep(s : String, sep : String) -> Bool {
  if sep.length() == 0 {
    true
  } else {
    s.has_prefix(sep)
  }
}

///|
fn ends_with_sep(s : String, sep : String) -> Bool {
  if sep.length() == 0 {
    true
  } else {
    s.has_suffix(sep)
  }
}

///|
// 整条路径的段匹配（`doMatch` 的移植，含"从两头往中间收"的两级循环）。
fn do_match(
  pattern : String,
  path : String,
  full_match : Bool,
  opts : PathOptions,
  vars : Map[String, String]?,
) -> (Bool, PathError?) {
  let sep = opts.separator
  if starts_with_sep(path, sep) != starts_with_sep(pattern, sep) {
    return (false, None)
  }
  let patt = tokenize(pattern, opts)
  let dirs = tokenize(path, opts)
  let mut ps = 0
  let mut pe = patt.length() - 1
  let mut ss = 0
  let mut se = dirs.length() - 1

  // ① 前段：收到第一个 `**`
  while ps <= pe && ss <= se {
    if patt[ps] == "**" {
      break
    }
    let (ok, err) = match_seg(patt[ps], dirs[ss], opts, vars)
    if err is Some(_) {
      return (false, err)
    }
    if !ok {
      return (false, None)
    }
    ps = ps + 1
    ss = ss + 1
  }

  if ss > se {
    // ② 路径先耗尽：模式余段必须全是 `**`
    if ps > pe {
      return (ends_with_sep(pattern, sep) == ends_with_sep(path, sep), None)
    }
    if !full_match {
      return (true, None)
    }
    if ps == pe && patt[ps] == "*" && ends_with_sep(path, sep) {
      return (true, None)
    }
    let mut i = ps
    while i <= pe {
      if patt[i] != "**" {
        return (false, None)
      }
      i = i + 1
    }
    return (true, None)
  } else if ps > pe {
    return (false, None)
  } else if !full_match && patt[ps] == "**" {
    return (true, None)
  }

  // ③ 后段：从末尾收到上一个 `**`
  while ps <= pe && ss <= se {
    if patt[pe] == "**" {
      break
    }
    let (ok, err) = match_seg(patt[pe], dirs[se], opts, vars)
    if err is Some(_) {
      return (false, err)
    }
    if !ok {
      return (false, None)
    }
    pe = pe - 1
    se = se - 1
  }
  if ss > se {
    let mut i = ps
    while i <= pe {
      if patt[i] != "**" {
        return (false, None)
      }
      i = i + 1
    }
    return (true, None)
  }

  // ④ 中间：两个 `**` 之间的片段在路径里滑动找位
  while ps != pe && ss <= se {
    let mut tmp = -1
    let mut i = ps + 1
    while i <= pe && tmp < 0 {
      if patt[i] == "**" {
        tmp = i
      }
      i = i + 1
    }
    if tmp == ps + 1 {
      // `**/**` 相邻，跳掉一个
      ps = ps + 1
      continue
    }
    let patlen = tmp - ps - 1
    let strlen = se - ss + 1
    let mut found = -1
    let mut k = 0
    while k <= strlen - patlen && found < 0 {
      let mut j = 0
      let mut hit = true
      while j < patlen && hit {
        let (ok, err) = match_seg(
          patt[ps + j + 1],
          dirs[ss + k + j],
          opts,
          vars,
        )
        if err is Some(_) {
          return (false, err)
        }
        if !ok {
          hit = false
        }
        j = j + 1
      }
      if hit {
        found = ss + k
      }
      k = k + 1
    }
    if found < 0 {
      return (false, None)
    }
    ps = tmp
    ss = found + patlen
  }

  let mut i = ps
  while i <= pe {
    if patt[i] != "**" {
      return (false, None)
    }
    i = i + 1
  }
  (true, None)
}

///|
// `extractPathWithinPattern`：模式里带 `*`/`?` 的那一段**之后**的路径段拼回去；
// 全程不调 `do_match`（参照实现也不校验匹不匹配，实测不匹配给空串）。
fn within_of(pattern : String, path : String) -> String {
  let opts = default_options()
  let pp = tokenize(pattern, opts)
  let dp = tokenize(path, opts)
  let out = StringBuilder()
  let mut segment = 0
  let mut path_started = false
  while segment < pp.length() {
    let part = pp[segment]
    if has_star_or_query(part) {
      while segment < dp.length() {
        if path_started || (segment == 0 && !pattern.has_prefix(opts.separator)) {
          out.write_string(opts.separator)
        }
        out.write_string(dp[segment])
        path_started = true
        segment = segment + 1
      }
    }
    segment = segment + 1
  }
  out.to_string()
}

///|
fn has_star_or_query(part : String) -> Bool {
  let cs = part.to_array()
  let mut i = 0
  let mut hit = false
  while i < cs.length() && !hit {
    if cs[i] == '*' || cs[i] == '?' {
      hit = true
    }
    i = i + 1
  }
  hit
}

///|
// `concat`：分隔符既不去重也不补齐（实测 `/test/` + `//hotels.html` → `/test//hotels.html`）。
fn concat_pat(p1 : String, p2 : String, sep : String) -> String {
  let a_end = ends_with_sep(p1, sep)
  let b_start = starts_with_sep(p2, sep)
  if a_end && b_start {
    p1 + slice_units(p2, sep.length(), p2.length())
  } else if a_end || b_start {
    p1 + p2
  } else {
    p1 + sep + p2
  }
}

///|
fn combine_go(prefix : String, suffix : String) -> (String, PathError?) {
  let sep = "/"
  if prefix.length() == 0 && suffix.length() == 0 {
    return ("", None)
  }
  if prefix.length() == 0 {
    return (suffix, None)
  }
  if suffix.length() == 0 {
    return (prefix, None)
  }
  let p1_has_var = prefix.has_prefix("{") || contains_char(prefix, '{')
  if prefix != suffix && !p1_has_var {
    let (ok, _) = do_match(prefix, suffix, true, default_options(), None)
    if ok {
      return (suffix, None)
    }
  }
  if ends_with_pair(prefix, sep + "*") {
    return (
      concat_pat(slice_units(prefix, 0, prefix.length() - 2), suffix, sep),
      None,
    )
  }
  if ends_with_pair(prefix, sep + "**") {
    return (concat_pat(prefix, suffix, sep), None)
  }
  let star_dot = index_of_pair(prefix, "*.")
  if p1_has_var || star_dot < 0 || sep == "." {
    return (concat_pat(prefix, suffix, sep), None)
  }
  let ext1 = slice_units(prefix, star_dot + 1, prefix.length())
  let dot2 = index_of_pair(suffix, ".")
  let file2 = if dot2 < 0 { suffix } else { slice_units(suffix, 0, dot2) }
  let ext2 = if dot2 < 0 {
    ""
  } else {
    slice_units(suffix, dot2, suffix.length())
  }
  let ext1_all = ext1 == ".*" || ext1.length() == 0
  let ext2_all = ext2 == ".*" || ext2.length() == 0
  if !ext1_all && !ext2_all {
    return ("", Some(ExtensionConflict(prefix, suffix)))
  }
  let ext = if ext1_all { ext2 } else { ext1 }
  (file2 + ext, None)
}

///|
fn ends_with_pair(s : String, pair : String) -> Bool {
  let n = pair.length()
  s.length() >= n && slice_units(s, s.length() - n, s.length()) == pair
}

///|
fn contains_char(s : String, c : Char) -> Bool {
  let cs = s.to_array()
  let mut i = 0
  let mut hit = false
  while i < cs.length() && !hit {
    if cs[i] == c {
      hit = true
    }
    i = i + 1
  }
  hit
}

///|
fn index_of_pair(s : String, pair : String) -> Int {
  let n = pair.length()
  let mut i = 0
  let mut hit = -1
  while i + n <= s.length() && hit < 0 {
    if slice_units(s, i, i + n) == pair {
      hit = i
    }
    i = i + 1
  }
  hit
}

///|
// PatternInfo：`{` 计变量、`**` 计跨段、单个 `*` 计段内通配（`.*` 这种"点+星"不算，参照实现那条
// 判据原样搬）。`length` 只在没有变量时参与比较，有变量时给 -1 让后面几级裁决。
priv struct PatInfo {
  uri_vars : Int
  single : Int
  doubles : Int
  catch_all : Bool
  prefix_pat : Bool
  length : Int
}

///|
fn pat_info(p : String) -> PatInfo {
  let cs = p.to_array()
  let mut vars = 0
  let mut single = 0
  let mut doubles = 0
  let mut i = 0
  while i < cs.length() {
    let c = cs[i]
    if c == '{' {
      vars = vars + 1
      i = i + 1
    } else if c == '*' {
      if i + 1 < cs.length() && cs[i + 1] == '*' {
        doubles = doubles + 1
        i = i + 2
      } else if i > 0 && !(slice_units(p, i - 1, i + 1) == ".*") {
        single = single + 1
        i = i + 1
      } else {
        i = i + 1
      }
    } else {
      i = i + 1
    }
  }
  let catch_all = p == "/**"
  let prefix_pat = !catch_all && ends_with_pair(p, "/**")
  let len = if vars == 0 { p.length() } else { -1 }
  PatInfo::{
    uri_vars: vars,
    single,
    doubles,
    catch_all,
    prefix_pat,
    length: len,
  }
}

///|
// 七级判定，照源码 780~828 行的顺序：leastSpecific → 与 against 相等 → 前缀模式 → 计数和
// → 长度 → 单星数 → 变量数。顺序不能重排，实测四条排序读数就是钉这个顺序的。
fn compare_pat(against : String, p1 : String, p2 : String) -> Int {
  let i1 = pat_info(p1)
  let i2 = pat_info(p2)
  if i1.catch_all && i2.catch_all {
    return 0
  } else if i1.catch_all {
    return 1
  } else if i2.catch_all {
    return -1
  }
  let e1 = p1 == against
  let e2 = p2 == against
  if e1 && e2 {
    return 0
  } else if e1 {
    return -1
  } else if e2 {
    return 1
  }
  if i1.prefix_pat && i2.prefix_pat {
    return i2.length - i1.length
  } else if i1.prefix_pat && i2.doubles == 0 {
    return 1
  } else if i2.prefix_pat && i1.doubles == 0 {
    return -1
  }
  let t1 = i1.single + i1.doubles + i1.uri_vars
  let t2 = i2.single + i2.doubles + i2.uri_vars
  if t1 != t2 {
    return t1 - t2
  }
  if i1.length != i2.length {
    return i2.length - i1.length
  }
  if i1.single < i2.single {
    return -1
  } else if i2.single < i1.single {
    return 1
  }
  if i1.uri_vars < i2.uri_vars {
    return -1
  } else if i2.uri_vars < i1.uri_vars {
    return 1
  }
  0
}
