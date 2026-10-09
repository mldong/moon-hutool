///|
// hutool `cn.hutool.core.io.file.FileNameUtil` 的**纯字符串档**（契约 15 §11）。
//
// 范围切法（读数在 `scripts/FileNameLeg.java`）：`FileNameUtil` 每个方法都有 `File` 与 `String`
// 两个重载。**只收 String 档**：`File` 档的语义挂在宿主（`File.separator` 随 OS 变、
// `isDirectory` 的尾斜杠规则、`File#getName` 对空串的兜底），本库零 FFI ⇒ 该批重载整条判
// `excluded`。null 入参在参照六件里有四件给 null、`containsInvalid(null)` 给 **false**——
// 本库 `String` 无 null 档，该形状不在契约面。
//
// **两件同义委托不重复出公开面**：`getSuffix` ≡ `extName`、`getPrefix` ≡ `mainName`，
// 腿逐档并排打两侧读数、每一条同串（`archive.tar.gz` 两侧都给 `tar.gz` / `archive`）。
//
// 两条会咬人的形状（都不是"顺手统一"的对象，逐条有读数）：
//   * **点开头**：`.bashrc` 的 ext 是 `bashrc`、主名是**空串**；
//   * **复合扩展名**只认反射读的 `SPECIAL_SUFFIX` 四条（`tar.bz2`/`tar.Z`/`tar.gz`/`tar.xz`，
//     表里那条是大写 Z），命中时 ext 给两段、主名跟着少两段；`x.tar.gz.txt` 命中的是尾巴 ⇒ `txt`。

fn is_sep(c : Char) -> Bool {
  c == '/' || c == '\\'
}

// 大小写不敏感地比两个码点：只承认 ASCII 那 26 对（参照 `isType` 走 `equalsIgnoreCase`，
// 非 ASCII 的"大小写"不参与——腿的 IT 行里有 `中文.txt` 这一档，靠的就是这条边界）

///|
fn ci_eq(a : Int, b : Int) -> Bool {
  a == b ||
  (a >= 65 && a <= 90 && a + 32 == b) ||
  (b >= 65 && b <= 90 && b + 32 == a)
}

///|
fn join_range(cs : Array[Char], lo : Int, hi : Int) -> String {
  let buf = StringBuilder()
  let mut i = lo
  while i < hi {
    buf.write_char(cs[i])
    i += 1
  }
  buf.to_string()
}

///|
/// 先剥尾部两种分隔符，再取"最后一个分隔符之后"那一段（`/tmp/` → `tmp`、`/` → 空串）
fn name_part(s : String) -> String {
  let cs = s.iter().collect()
  let mut end = cs.length()
  while end > 0 && is_sep(cs[end - 1]) {
    end -= 1
  }
  let mut start = 0
  let mut i = 0
  while i < end {
    if is_sep(cs[i]) {
      start = i + 1
    }
    i += 1
  }
  join_range(cs, start, end)
}

///|
fn last_dot(cs : Array[Char]) -> Int? {
  let mut found = None
  let mut i = 0
  while i < cs.length() {
    if cs[i] == '.' {
      found = Some(i)
    }
    i += 1
  }
  found
}

// 复合扩展名表——**反射读** `FileNameUtil.SPECIAL_SUFFIX` 得来（腿 CONST 行），顺序照表原样。

///|
let special_suffixes : Array[Array[Char]] = [
  ['t', 'a', 'r', '.', 'b', 'z', '2'],
  ['t', 'a', 'r', '.', 'Z'],
  ['t', 'a', 'r', '.', 'g', 'z'],
  ['t', 'a', 'r', '.', 'x', 'z'],
]

///|
/// 名字段是否以 `.SPECIAL_SUFFIX` 中某条结尾（大小写不敏感）；给命中的长度（含前面那个点）
fn special_suffix_len(cs : Array[Char]) -> Int? {
  let n = cs.length()
  for suf in special_suffixes {
    let want = suf.length() + 1
    if n >= want {
      let dot = n - want // 复合扩展名前那个点的位置
      let mut hit = cs[dot] == '.'
      if hit {
        let mut k = 0
        while k < suf.length() {
          if !ci_eq(cs[dot + 1 + k].to_int(), suf[k].to_int()) {
            hit = false
          }
          k += 1
        }
      }
      if hit {
        return Some(want)
      }
    }
  }
  None
}

///|
/// 名字段拆成 `(主名, 扩展名)`：先问复合扩展名，再退到"最后一个点"
fn split_name(name : String) -> (String, String) {
  let cs = name.iter().collect()
  let n = cs.length()
  if n == 0 {
    return ("", "")
  }
  if special_suffix_len(cs) is Some(want) {
    let lo = n - want
    (join_range(cs, 0, lo), join_range(cs, lo + 1, n))
  } else if last_dot(cs) is Some(i) {
    (join_range(cs, 0, i), join_range(cs, i + 1, n))
  } else {
    (name, "")
  }
}

// 非法字符集 = 反射读 `FILE_NAME_INVALID_PATTERN_WIN` 的 `[\\/:*?"<>|\r\n]`（腿 CONST 行）。

///|
fn is_invalid_char(c : Char) -> Bool {
  c == '/' ||
  c == '\\' ||
  c == ':' ||
  c == '*' ||
  c == '?' ||
  c == '"' ||
  c == '<' ||
  c == '>' ||
  c == '|' ||
  c == '\r' ||
  c == '\n'
}

///|
fn ci_eq_str(a : String, b : String) -> Bool {
  let ac = a.iter().collect()
  let bc = b.iter().collect()
  if ac.length() != bc.length() {
    return false
  }
  let mut i = 0
  while i < ac.length() {
    if !ci_eq(ac[i].to_int(), bc[i].to_int()) {
      return false
    }
    i += 1
  }
  true
}

///|
/// 取路径尾巴（`FileNameUtil.getName(String)`）：按 `/` 与 `\` **两种分隔符**取最后一段，
/// 尾随分隔符先剥掉。参照不认宿主——混分隔符 `a\b/c.txt` 给 `c.txt`（腿 N 行）。
pub fn name_of(s : String) -> String {
  name_part(s)
}

///|
/// 主名（`FileNameUtil.mainName`，参照的 `getPrefix` 是它的别名）：去分隔符尾巴后再去最后一个
/// 点及其后——但**复合扩展名整段去**（`archive.tar.gz` → `archive`）。
/// `.bashrc` → 空串（点开头那一档照参照来，不"顺手改成 `bashrc`"）。
pub fn main_name(s : String) -> String {
  let (main, _) = split_name(name_part(s))
  main
}

///|
/// 扩展名（`FileNameUtil.extName`，参照的 `getSuffix` 是它的别名）：最后一个点之后的部分，
/// 复合扩展名给两段（`tar.gz`）；无点、尾随点（`a.`）、只有分隔符尾巴（`/tmp/`）都给空串。
pub fn ext_name(s : String) -> String {
  let (_, ext) = split_name(name_part(s))
  ext
}

///|
/// 清掉 Windows 文件名非法字符（`FileNameUtil.cleanInvalid`）。字符集不是"猜的九个"，
/// 是按反射读到的那张字符集删——分隔符**也在**里面 ⇒ `clean_invalid("/tmp/")` 给 `tmp`，
/// 这是参照行为不是笔误。
pub fn clean_invalid(s : String) -> String {
  let buf = StringBuilder()
  for c in s.iter() {
    if !is_invalid_char(c) {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
/// 是否含上述非法字符（`FileNameUtil.containsInvalid`）：空串 false；`/tmp/` true。
pub fn contains_invalid(s : String) -> Bool {
  s.iter().any(c => is_invalid_char(c))
}

///|
/// 是否属于给定类型之一（`FileNameUtil.isType(String, String...)`）。四条实测形状：
///   * **大小写不敏感**（`a.TXT` 命中 `txt`，类型表里的 `Tar.GZ` 也命中 `tar.gz`）；
///   * 类型**不带点**——`[".txt"]` 永不命中（腿 IT 行）；
///   * 复合扩展名按两段比：`a.tar.gz` 命中 `tar.gz` 而**不**命中 `gz`（腿 IT 行三档都在）；
///   * 空类型串是个真值档：无扩展名的文件（`noext`）对 `[""]` 给 **true**（腿 IT 行）；空表恒 false。
pub fn is_type(s : String, types : Array[String]) -> Bool {
  let ext = ext_name(s)
  types.any(t => ci_eq_str(t, ext))
}
