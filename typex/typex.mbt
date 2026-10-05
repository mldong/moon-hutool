///|
// moon-hutool/typex —— 类型/工具补充面（ROADMAP 第 23 行）
// 对位 hutool `cn.hutool.core.lang.Version` + `cn.hutool.core.util.PageUtil`（第一批）；
// `Ipv4Util` / `DataSize` / `PhoneUtil` / `IdcardUtil` / `CreditCodeUtil` / `DesensitizedUtil` /
// `CoordinateUtil` 另立后续批（spec §1）。
// **件全在 hutool-core 一个 jar 里**（`unzip -l hutool-core.jar | grep -ciE "lang/Version|PageUtil"` 现读 2 条），本格不另拉 artifact。
// 契约真相在 `docs/spec/23-typex.md`。
//
// 一句话口径（四处与直觉相反，都有腿读数或参照源码为凭）：
// - `version_to_string` **原样吐出构造时那个串**：不剥 `v`/`V` 前缀、不归一分隔符、不裁首尾空格
//   （25 档 `TOSTRING` 读数与输入逐字相同，含 `" 1.2"`、`"1.2 "`、`"1.2.3."`）。
// - 段序比较：数字段按数值，其余段按 **UTF-16 码元字典序且大小写敏感**（`V1.2.3` < `v1.2.3`）；
//   数字段遇字符串段时把数字转十进制串再比（`"_"` 与 `"4"` 那一档）；长度不等时**长出部分全是 0 才相等**
//   （`1.2` == `1.2.0`，但 `"1.2 "` != `"1.2"`——多出的那段是空格串，不是 0）。
// - 解析按 **UTF-16 码元** 走而不是按码位：参照的 `charAt`/`substring` 就是码元口径，且首段那次
//   `takeNumber` 是**无条件**调的，于是 `v1.2.3` 的首段是 `'v' - '0' = 70` 拼出来的 701（数字段，不是字母段），
//   `" 1.2"` 的首段是 `-16` 拼出来的 `-159`——这两条正是 `V4`/`V19` 读数符号的来源。
// - `PageUtil.firstPageNo` 在参照是全局静态可变 ⇒ 本库同样全局（`typex_first_page_no` / `typex_set_first_page_no`），
//   跨用例互盖是它的固有代价，测试每条先显式设档再读。
// 凡参照用 Java `int` 算式处，本库一律走 `Int64` 中间量 + 取低 32 位补码读法：既让 wasm(32 位 `Int`) / js /
// wasm-gc / native(64 位 `Int`) 四档同值，又与参照的溢出回绕同值（spec §3 第 8 条）。

///|
/// #23.1 版本号。对位 `cn.hutool.core.lang.Version implements Comparable<Version>`。
/// 参照把版本串切成三张段表（sequence / pre / build），段要么是被 Java `int` 收下的数字、要么是字符串；
/// 本库原样跟着存，外加构造时那个串——参照 `toString()` 返回的就是它。
pub struct Version {
  priv raw : String
  priv sequence : Array[Token]
  priv pre : Array[Token]
  priv build : Array[Token]
}

///|
/// 段：参照的 `List<Object>` 只有 `Integer` / `String` 两种实际类型，这里收成两变体。
enum Token {
  Num(Int)
  Str(String)
}

///|
// 下面四个是 UTF-16 码元值：'.' '-' '+' '0'。参照全程拿 `char` 比，本库把输入摊成码元数组后比同一些数。
let u_dot : Int = 0x2e

///|
let u_dash : Int = 0x2d

///|
let u_plus : Int = 0x2b

///|
let u_zero : Int = 0x30

///|
fn is_digit_unit(u : Int) -> Bool {
  // 参照 `CharUtil.isNumber`：`ch >= '0' && ch <= '9'`（现读 CharUtil.java:151-153），ASCII 档
  u >= u_zero && u <= 0x39
}

///|
/// 参照 `Math.toIntExact` 之前的 Java `int` 口径：取低 32 位、按补码读。
/// `Int` 位宽随目标变（wasm/js/wasm-gc 是 32 位，native 是 64 位），不回绕就会四档三样，
/// 而这里要的不是"更大范围"，是**与参照同值**。
fn wrap32(v : Int64) -> Int {
  let lo = v & 0xffffffffL
  if lo >= 0x80000000L {
    (lo - 0x100000000L).to_int()
  } else {
    lo.to_int()
  }
}

///|
/// 码元序列 → 串。代理对（高位 0xd800-0xdbff 紧跟低位 0xdc00-0xdfff）合回一个码位；
/// 解析时代理对永不被切断（`take_*` 只在 `.` `-` `+` 与数字处停，代理对两个码元都不在其中），
/// 所以这里不需要处理"半个代理对"。
fn units_to_string(us : Array[Int], b : Int, e : Int) -> String {
  let cs : Array[Char] = []
  let mut i = b
  while i < e {
    let u = us[i]
    let hi_surrogate = u >= 0xd800 && u <= 0xdbff
    if hi_surrogate && i + 1 < e {
      let lo = us[i + 1]
      if lo >= 0xdc00 && lo <= 0xdfff {
        let cp : Int = (u - 0xd800) * 0x400 + (lo - 0xdc00) + 0x10000
        cs.push(cp.unsafe_to_char())
        i = i + 2
        continue
      }
    }
    cs.push(u.unsafe_to_char())
    i = i + 1
  }
  String::from_array(cs)
}

///|
/// 串 → UTF-16 码元序列（代理对拆开）。参照的 `charAt`/`substring`/`String.compareTo` 全是码元口径，
/// 本库解析与比较两侧都走同一条单位。
fn units_of(s : String) -> Array[Int] {
  let out : Array[Int] = []
  for c in s.to_array() {
    let cp = c.to_int()
    if cp > 0xffff {
      let x = cp - 0x10000
      out.push(0xd800 + (x >> 10))
      out.push(0xdc00 + (x & 0x3ff))
    } else {
      out.push(cp)
    }
  }
  out
}

///|
/// 参照 `Version.takeNumber(String, int, List<Object>)`：从 `start` 起把连续数字并进一个 `int`。
/// 两处参照怪癖都跟随：① `start` 处那个字符**无条件**按 `c - '0'` 当首位（于是 `v1.2.3` 首段 701）；
/// ② 累加是 Java `int`，越界回绕 ⇒ 这里先 `Int64` 累加再 `wrap32`（模 2^32 域里 `+`/`*` 同余，一次回绕与逐步回绕同值）。
fn take_number(us : Array[Int], start : Int, acc : Array[Token]) -> Int {
  let n = us.length()
  let mut d : Int64 = (us[start] - u_zero).to_int64()
  let mut i = start + 1
  while i < n {
    let u = us[i]
    if is_digit_unit(u) {
      d = d * 10L + (u - u_zero).to_int64()
      i = i + 1
    } else {
      break
    }
  }
  acc.push(Num(wrap32(d)))
  i
}

///|
/// 参照 `Version.takeString(String, int, List<Object>)`：从 `start` 起吃到 `.` `-` `+` 或数字为止（不含）。
fn take_string(us : Array[Int], start : Int, acc : Array[Token]) -> Int {
  let n = us.length()
  let mut i = start + 1
  while i < n {
    let u = us[i]
    if u == u_dot || u == u_dash || u == u_plus || is_digit_unit(u) {
      break
    }
    i = i + 1
  }
  acc.push(Str(units_to_string(us, start, i)))
  i
}

///|
/// #23.2 解析版本号
/// - Returns: 结构体本身总构造得出（参照 `Version.of` 对空串、缺段、带前后空格都不抛）
/// - Raises: 无（腿对 25 个输入零异常读数；参照真抛的只有 `null`，本库类型上就进不来）
/// - Note: hutool 对位 `static Version of(String)` / `new Version(String)`
pub fn version_of(text : String) -> Version {
  let us = units_of(text)
  let n = us.length()
  let sequence : Array[Token] = []
  let pre : Array[Token] = []
  let build : Array[Token] = []
  if n > 0 {
    // 主版本段。参照在这里是 `while (i < n) { ... }`，`.` 跳过、`-`/`+` 吃掉一个码元后跳出去。
    let mut i = take_number(us, 0, sequence)
    while i < n {
      let u = us[i]
      if u == u_dot {
        i = i + 1
        continue
      }
      if u == u_dash || u == u_plus {
        i = i + 1
        break
      }
      i = if is_digit_unit(u) {
        take_number(us, i, sequence)
      } else {
        take_string(us, i, sequence)
      }
    }
    // 参照这里紧跟 `if (c == '-' && i >= n) return;`——`i >= n` 时下面两个 while 本来就不进，
    // 那句是空转，不搬（搬了反而多一条永假分支）。
    // 次版本段
    while i < n {
      let u = us[i]
      i = if is_digit_unit(u) {
        take_number(us, i, pre)
      } else {
        take_string(us, i, pre)
      }
      if i >= n {
        break
      }
      let v = us[i]
      if v == u_dot || v == u_dash {
        i = i + 1
        continue
      }
      if v == u_plus {
        i = i + 1
        break
      }
    }
    // 构建版本段
    while i < n {
      let u = us[i]
      i = if is_digit_unit(u) {
        take_number(us, i, build)
      } else {
        take_string(us, i, build)
      }
      if i >= n {
        break
      }
      let v = us[i]
      if v == u_dot || v == u_dash || v == u_plus {
        i = i + 1
      }
    }
  }
  Version::{ raw: text, sequence, pre, build, }
}

///|
/// #23.3 版本串出口：参照 `toString()` 返回构造时收到的那个串本身，一个字符都不动。
/// - Raises: 无
/// - Note: hutool 对位 `String toString()`
pub fn version_to_string(v : Version) -> String {
  v.raw
}

///|
fn token_text(t : Token) -> String {
  match t {
    Num(d) => d.to_string()
    Str(s) => s
  }
}

///|
/// 参照的 `String.compareTo` / `o1.toString().compareTo(o2.toString())` 都是 **UTF-16 码元** 序，
/// 逐码元比而不是逐码位比——`V`/`v`、`_`/`4` 两档的符号就是这么来的。
fn cmp_units(a : String, b : String) -> Int {
  let ua = units_of(a)
  let ub = units_of(b)
  let n = if ua.length() < ub.length() { ua.length() } else { ub.length() }
  let mut i = 0
  while i < n {
    if ua[i] < ub[i] {
      return -1
    }
    if ua[i] > ub[i] {
      return 1
    }
    i = i + 1
  }
  if ua.length() < ub.length() {
    -1
  } else if ua.length() > ub.length() {
    1
  } else {
    0
  }
}

///|
/// 参照 `Version.compareTokens(List<Object>, List<Object>)`：同类型按类型比，
/// 类型不同则把两侧都当字符串比（`Integer.toString` 就是十进制）。
/// 参照返回的是原始差值（如 `ts1.size() - ts2.size()`、码元差），本库只承诺符号档（spec §5 第 4 行）。
fn compare_tokens(ts1 : Array[Token], ts2 : Array[Token]) -> Int {
  let n = if ts1.length() < ts2.length() { ts1.length() } else { ts2.length() }
  let mut i = 0
  while i < n {
    let c = cmp_token(ts1[i], ts2[i])
    if c != 0 {
      return c
    }
    i = i + 1
  }
  // 长出的部分：只有全是数字 0 才算相等，一个字符串段就把它拉成不等
  let rest = if ts1.length() > ts2.length() { ts1 } else { ts2 }
  let mut j = n
  while j < rest.length() {
    let zero_pad = match rest[j] {
      Num(d) => d == 0
      Str(_) => false
    }
    if !zero_pad {
      // 参照 here 返回 `ts1.size() - ts2.size()`，本库只取符号档
      return if ts1.length() < ts2.length() { -1 } else { 1 }
    }
    j = j + 1
  }
  0
}

///|
fn cmp_token(a : Token, b : Token) -> Int {
  match a {
    Str(s) => cmp_units(s, token_text(b))
    Num(x) =>
      match b {
        Num(y) => if x < y { -1 } else if x > y { 1 } else { 0 }
        Str(s) => cmp_units(token_text(a), s)
      }
  }
}

///|
/// #23.4 三向比较
/// - Returns: `-1` / `0` / `1`（参照给的是原始差值，如段数差 `-2`、码元差 `-27`；腿只钉符号档，契约也只钉符号）
/// - Raises: 无
/// - Note: hutool 对位 `int compareTo(Version)`
pub fn version_compare(a : Version, b : Version) -> Int {
  let c = compare_tokens(a.sequence, b.sequence)
  if c != 0 {
    return c
  }
  // `pre` 空的一侧**更大**：`1.2.3` > `1.2.3-SNAPSHOT`（V6 读数），这是跟随参照的档，不按语义版本常规
  if a.pre.length() == 0 {
    if b.pre.length() > 0 {
      return 1
    }
  } else if b.pre.length() == 0 {
    return -1
  }
  let c2 = compare_tokens(a.pre, b.pre)
  if c2 != 0 {
    return c2
  }
  compare_tokens(a.build, b.build)
}

///|
/// #23.5 相等判定（参照 `equals` 就是 `compareTo == 0`；
/// 参照的 `hashCode` 走的是原串哈希 ⇒ `1.2` 与 `1.2.0` equals 却不同哈希，那是参照自身的 equals/hashCode 违约，
/// 本库不复制 hashCode，腿里 `HASH` 读数只作旁证）
/// - Raises: 无
/// - Note: hutool 对位 `boolean equals(Object)`
pub fn version_equals(a : Version, b : Version) -> Bool {
  version_compare(a, b) == 0
}

///|
/// 参照 `PageUtil.firstPageNo`：`private static int`，默认 0。本库同样全局可变，
/// 形式是单元素数组当格子（本版顶层 `let mut` 直接判词法错，数组元素本身可变）。
let first_page_cell : Array[Int] = [0]

///|
/// #23.6 首尾页号（参照全局静态 `firstPageNo`，默认 0）
/// - Returns: 当前档位
/// - Raises: 无
/// - Note: hutool 对位 `static int getFirstPageNo()`
pub fn typex_first_page_no() -> Int {
  first_page_cell[0]
}

///|
/// #23.7 设首尾页号
/// - Parameters: `n` 首页号（参照 `setFirstPageNo(int)`；`setOneAsFirstPageNo()` 就是设 1）
/// - Raises: 无
/// - Note: 这是**全局可变状态**，并发或跨用例互盖 ⇒ 测试里每条用例先显式设档。
///   参照不校验取值（注释说"可以为 0 或者 1"，实际任何 `int` 都收，负数档照算），本库同样不校验。
pub fn typex_set_first_page_no(n : Int) -> Unit {
  first_page_cell[0] = n
}

///|
/// #23.8 该页起始行号
/// - Raises: 无
/// - Note: hutool 对位 `static int getStart(int, int)`：页号低于 `firstPageNo` 就夹到 `firstPageNo`
///   （所以负页号给 0，`V P5` 读数），每页条数 `< 1` 一律当 0（不是夹成 1）。
pub fn page_get_start(page : Int, size : Int) -> Int {
  let p = if page < first_page_cell[0] { first_page_cell[0] } else { page }
  let s = if size < 1 { 0 } else { size }
  wrap32((p.to_int64() - first_page_cell[0].to_int64()) * s.to_int64())
}

///|
/// #23.9 该页结束行号
/// - Raises: 无
/// - Note: hutool 对位 `static int getEnd(int, int)` = `getStart + (size < 1 ? 0 : size)`；
///   **不减 1**（`P0.end|10` 而非 9，javadoc 里那句"页码：0，每页10 =》 9"与实现不符，以腿为准）。
pub fn page_get_end(page : Int, size : Int) -> Int {
  let start = page_get_start(page, size)
  end_by_start(start, size)
}

///|
fn end_by_start(start : Int, size : Int) -> Int {
  let s = if size < 1 { 0 } else { size }
  wrap32(start.to_int64() + s.to_int64())
}

///|
/// #23.10 起始与结束行号成对给出
/// - Raises: 无
/// - Note: hutool 对位 `static int[] transToStartEnd(int, int)`（参照出口是长度为 2 的数组，本库给元组）
pub fn page_trans_to_start_end(page : Int, size : Int) -> (Int, Int) {
  let start = page_get_start(page, size)
  (start, end_by_start(start, size))
}

///|
/// #23.11 总页数
/// - Parameters: `count` 总条数（参照另有 `long` 重载，本库合两件、`Int` 档走 23.12 同一算法）
/// - Raises: 无
/// - Note: hutool 对位 `static int totalPage(int, int)`（转手 `totalPage((long) count, size)`）。
///   `size == 0` 直接给 0（不是除零报错，`P2004`）；`count` 为负时 Java 的 `%` 与 `/` 都向零截断，
///   于是 `-5 / 10 + 1 = 1`（`P2005` 读数），MoonBit 的 `Int64` 除余同口径。
pub fn page_total_page(count : Int, size : Int) -> Int {
  page_total_page_long(count.to_int64(), size)
}

///|
/// #23.12 总页数（长条数档）
/// - Raises: 无
/// - Note: hutool 对位 `static int totalPage(long, int)`——腿的 `4294967296|10` 等读数钉这一档。
///   参照出口前有 `Math.toIntExact`（超 int 直接抛 `ArithmeticException`，边腿现读），
///   本库签名没有 raise 面 ⇒ 取低 32 位补码读法，两侧分岔记在 spec §5 第 5 行。
pub fn page_total_page_long(count : Int64, size : Int) -> Int {
  if size == 0 {
    0
  } else {
    let s = size.to_int64()
    let q = if count % s == 0L { count / s } else { count / s + 1L }
    wrap32(q)
  }
}

///|
/// #23.13 页码彩虹条（默认展示 10 个）
/// - Returns: 页号数组（参照从不给 `null`：退化档给长度 0 的数组，`P3`/`P4` 读数即空数组）
/// - Raises: 无
/// - Note: hutool 对位 `static int rainbow(int, int)`，现读源码就是 `rainbow(cur, total, 10)`
pub fn page_rainbow(current : Int, total : Int) -> Array[Int] {
  page_rainbow_count(current, total, 10)
}

///|
/// #23.14 页码彩虹条（指定展示个数）
/// - Raises: 无
/// - Note: hutool 对位 `static int rainbow(int, int, int)`。三条参照固有形状都跟随：
///   `show_count` 为偶数时 `right++`（左右不对称，`P50004`/`P7` 那两档的偏移差就是它）；
///   `total < show_count` 时长度取 `total`；`total >= show_count` 才走三段选位。
///   长度算出负数时（`total` 为负）参照 `new int[负]` 抛 `NegativeArraySizeException`（边腿现读），
///   本库给空数组——分岔记在 spec §5 第 6 行。
pub fn page_rainbow_count(
  current : Int,
  total : Int,
  show_count : Int,
) -> Array[Int] {
  let is_even = (show_count.to_int64() & 1L) == 0L
  let left = show_count >> 1
  let right = if is_even {
    wrap32((show_count >> 1).to_int64() + 1L)
  } else {
    show_count >> 1
  }
  let mut length = show_count
  if total < show_count {
    length = total
  }
  let out : Array[Int] = []
  if length < 0 {
    return out
  }
  let mut i = 0
  while i < length {
    let v : Int64 = if total >= show_count {
      if current <= left {
        (i + 1).to_int64()
      } else if current > wrap32(total.to_int64() - right.to_int64()) {
        i.to_int64() + total.to_int64() - show_count.to_int64() + 1L
      } else {
        let base = i.to_int64() + current.to_int64() - left.to_int64()
        if is_even {
          base + 1L
        } else {
          base
        }
      }
    } else {
      (i + 1).to_int64()
    }
    out.push(wrap32(v))
    i = i + 1
  }
  out
}
