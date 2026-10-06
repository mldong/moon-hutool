///|
// moon-hutool/typex —— 身份证号面（ROADMAP 第 23 行第三批 C，#23.50–#23.54）
// 对位 hutool `cn.hutool.core.util.IdcardUtil`（GB11643-1999）：本批只收**校验两件 + convert 两件**，
// 切片族（birth/year/month/day/gender/province/city/district/hide）另立一批——它们的失败形状是
// `null` / NPE / `NumberFormatException` / `IllegalArgumentException` 四种混用，映射口径要先单独拍。
// 契约真相在 `docs/spec/23-typex.md` §13。
//
// 四条决定实现形状、且都有腿读数为凭的事实：
// - 省码表 36 枚由反射读 `CITY_CODES` 的**键集**（值是省名，本批不用）；省码闸在生日闸之前，
//   且 `startsWith("9")` 那一支取第 2~3 位当省码（新版外国人永居证），有专用夹具。
// - 校验位是 `sum(前 17 位数字 × 权重) % 11` 查 11 枚字符表 `1 0 X 9 8 7 6 5 4 3 2`，与第三批 B 的
//   mod-31 那族**不是同一张表**。
// - 参照的生日判据含 `year > DateUtil.thisYear()`（宿主时钟）⇒ 本库把年份做成显式参数 `this_year`，
//   夹具一律传腿执行当年的读数；`is_valid_15` 不设该参数，因为 15 位的年份恒为 19xx（见 §13.3）。
// - `convert15To18` 的世纪映射：参照走 `DateUtil.parse(·, "yyMMdd")` 后再 `if (sYear > 2000) sYear -= 100`，
//   腿对 yy=00..99 全扫给出 **yy=00 → 2000，其余 → 1900+yy**，且该闭式与 SimpleDateFormat 的基准年
//   （随执行当年移动）无关——那条 `> 2000` 的夹正把 pivot 的影响整体吸收掉了（推导 + 100 条读数为凭）。

///|
// 反射读自 `IdcardUtil.CITY_CODES` 的键集（36 枚，字典序）。
let idcard_pro_keys : Array[String] = [
  "11", "12", "13", "14", "15", "21", "22", "23", "31", "32", "33", "34", "35", "36",
  "37", "41", "42", "43", "44", "45", "46", "50", "51", "52", "53", "54", "61", "62",
  "63", "64", "65", "71", "81", "82", "83", "91",
]

///|
// 参照 private `getPowerSum` 的权重（17 枚）。
let idcard_weight : Array[Int] = [
  7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2,
]

///|
// 参照 private `getCheckCode18(int)` 的 `switch (sum % 11)` 表，按下标 0..10 排。
let idcard_check_chars : Array[Char] = "10X98765432".to_array()

///|
/// 本版 `Array` 没有 `slice`（`re` 轮记过），手写字区间。
fn idcard_sub(cs : Array[Char], from : Int, to : Int) -> Array[Char] {
  let out : Array[Char] = []
  let mut i = from
  while i < to {
    out.push(cs[i])
    i = i + 1
  }
  out
}

///|
fn idcard_is_digit(c : Char) -> Bool {
  let v = c.to_int()
  v >= 48 && v <= 57
}

///|
/// 参照用 `ReUtil.isMatch(PatternPool.NUMBERS, ·)`（即 `\d+` 整串匹配）；这里等价改写成"全档数字且非空"。
/// `\d` 在参照侧（无 `UNICODE_CHARACTER_CLASS`）就是 `[0-9]` ⇒ 改写可逐字符核对（spec §13.3 第 5 条）。
fn idcard_all_digits(cs : Array[Char], from : Int, to : Int) -> Bool {
  if from >= to {
    return false
  }
  let mut i = from
  while i < to {
    if !idcard_is_digit(cs[i]) {
      return false
    }
    i = i + 1
  }
  true
}

///|
fn idcard_num(cs : Array[Char], from : Int, len : Int) -> Int {
  let mut v = 0
  let mut i = from
  while i < from + len {
    v = v * 10 + cs[i].to_int() - 48
    i = i + 1
  }
  v
}

///|
fn idcard_is_leap(y : Int) -> Bool {
  (y % 4 == 0 && y % 100 != 0) || y % 400 == 0
}

///|
/// 参照 `Validator.isBirthday(int, int, int)`：年 ∈ [1900, this_year]、月 ∈ [1,12]、日 ∈ [1,31]，
/// 其中 4/6/9/11 月不吃 31 日，2 月只吃 ≤28（闰年可到 29）。
/// 8 位必须全数字——参照侧是 `BIRTHDAY` 正则 `find()` 后取组，本库的入参恒是被切出来的 8 个字符，
/// 全数字这一判与"正则找到 4+2+2"在这些样本上同答案（980 条读数为凭）。
fn idcard_birthday_ok(cs : Array[Char], this_year : Int) -> Bool {
  if !idcard_all_digits(cs, 0, 8) {
    return false
  }
  let y = idcard_num(cs, 0, 4)
  let m = idcard_num(cs, 4, 2)
  let d = idcard_num(cs, 6, 2)
  if y < 1900 || y > this_year {
    return false
  }
  if m < 1 || m > 12 {
    return false
  }
  if d < 1 || d > 31 {
    return false
  }
  if d == 31 && (m == 4 || m == 6 || m == 9 || m == 11) {
    return false
  }
  if m == 2 {
    return d < 29 || (d == 29 && idcard_is_leap(y))
  }
  true
}

///|
fn idcard_has_pro(cs : Array[Char]) -> Bool {
  // 参照：`idcard.startsWith("9") ? substring(1,3) : substring(0,2)`，再查 `CITY_CODES`
  let from = if cs[0].to_int() == 57 { 1 } else { 0 } // 57 = '9'（49 是 '1'，写错会把所有 1 开头省码带偏）
  idcard_pro_keys.contains(String::from_array(idcard_sub(cs, from, from + 2)))
}

///|
/// 前 17 位数字 × 权重求和、mod 11 查表（参照 private `getCheckCode18(String)`）。
fn idcard_check_char(cs : Array[Char]) -> Char {
  let mut sum = 0
  let mut i = 0
  while i < 17 {
    sum = sum + (cs[i].to_int() - 48) * idcard_weight[i]
    i = i + 1
  }
  idcard_check_chars[sum % 11]
}

///|
/// 参照 `CharUtil.equals(char, char, ignoreCase)`：忽略大小写时对两侧取小写再比。
fn idcard_char_eq(a : Char, b : Char, ignore_case : Bool) -> Bool {
  if a == b {
    true
  } else if !ignore_case {
    false
  } else {
    let x = a.to_int()
    let y = b.to_int()
    let la = if x >= 65 && x <= 90 { x + 32 } else { x }
    let lb = if y >= 65 && y <= 90 { y + 32 } else { y }
    la == lb
  }
}

///|
/// #23.50 十八位身份证校验（省码闸 → 生日闸 → 前 17 位数字 → 校验位，忽略 `X` 大小写）
/// - Parameters: `this_year` 参照读的是宿主当年（`DateUtil.thisYear()`），本库做成显式参数
/// - Raises: 无（参照的 `null` 入参档在本库是类型不允许；非数字/越界档一律 `false`）
/// - Note: hutool 对位 `static boolean isValidCard18(String)`
pub fn idcard_is_valid_18(id : String, this_year : Int) -> Bool {
  idcard_is_valid_18_case(id, this_year, true)
}

///|
/// #23.51 十八位身份证校验（`ignore_case` 档：`false` 时第 18 位严格匹配大写 `X`）
/// - Note: hutool 对位 `static boolean isValidCard18(String, boolean)`（5.5.7 起）
pub fn idcard_is_valid_18_case(
  id : String,
  this_year : Int,
  ignore_case : Bool,
) -> Bool {
  let cs = id.to_array()
  if cs.length() != 18 {
    return false
  }
  if !idcard_has_pro(cs) {
    return false
  }
  if !idcard_birthday_ok(idcard_sub(cs, 6, 14), this_year) {
    return false
  }
  if !idcard_all_digits(cs, 0, 17) {
    return false
  }
  idcard_char_eq(idcard_check_char(cs), cs[17], ignore_case)
}

///|
/// #23.52 十五位身份证校验（年份恒为 19xx ⇒ 不设 `this_year`：1900..1999 永不超过执行当年，
/// 故内部把生日年份上界钉成 1999 与参照等价）
/// - Raises: 无
/// - Note: hutool 对位 `static boolean isValidCard15(String)`；参照内部把生日补成 `"19" + yyMMdd` 再判
pub fn idcard_is_valid_15(id : String) -> Bool {
  let cs = id.to_array()
  if cs.length() != 15 || !idcard_all_digits(cs, 0, 15) {
    return false
  }
  if !idcard_has_pro(cs) {
    return false
  }
  idcard_birthday_ok(
    ("19" + String::from_array(idcard_sub(cs, 6, 12))).to_array(),
    1999,
  )
}

///|
/// #23.53 十五位转十八位（世纪映射 `yy=00 → 2000`、其余 `→ 1900+yy`，再补校验位）
/// - Returns: 非 15 位或含非数字给 `None`（参照给 `null`）
/// - Raises: 无
/// - Note: hutool 对位 `static String convert15To18(String)`
pub fn idcard_convert_15_to_18(id : String) -> String? {
  let cs = id.to_array()
  if cs.length() != 15 || !idcard_all_digits(cs, 0, 15) {
    return None
  }
  let yy = idcard_num(cs, 6, 2)
  let s_year = if yy == 0 { 2000 } else { 1900 + yy }
  let body = String::from_array(idcard_sub(cs, 0, 6)) +
    s_year.to_string() +
    String::from_array(idcard_sub(cs, 8, 15))
  let bc = body.to_array()
  Some(body + String::from_array([idcard_check_char(bc)]))
}

///|
/// #23.54 十八位转十五位（**非法档原样返回入参**，与 #23.53 的失败形状相反）
/// - Returns: 参照是 `isNotBlank && isValidCard18` 才截，否则 `return idCard`；
///   空白串的 `isValidCard18` 必为 false ⇒ 本库不再单独判空白，两处判定等价
/// - Raises: 无
/// - Note: hutool 对位 `static String convert18To15(String)`
pub fn idcard_convert_18_to_15(id : String, this_year : Int) -> String {
  if !idcard_is_valid_18(id, this_year) {
    return id
  }
  let cs = id.to_array()
  String::from_array(idcard_sub(cs, 0, 6)) +
  String::from_array(idcard_sub(cs, 8, 17))
}
