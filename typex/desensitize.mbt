///|
// moon-hutool/typex —— 脱敏（ROADMAP 第 23 行第四批第一格，#23.83–#23.96）
// 对位 hutool `DesensitizedUtil`（件在 `cn.hutool.core.util`，枚举 `DesensitizedType` 是**同文件内嵌**）。
// 契约真相在 `docs/spec/23-typex.md` §16。
//
// 本文件最反直觉的一点：**参照自己混用两个索引域，移植必须照抄而不是抹平**。
// - 闸与计数走 `String.length()`＝UTF-16 码元（`password` 的星号数、`email` 里 `'@'` 的索引、
//   `idCardNum` 与 `carLicense` 的长度判据、以及所有传给 `hide` 的边界数字）；
// - 遮蔽走 `StrUtil.hide`＝码位（本库复用 `@text.hide`，同一口径、不留第二张掩码表）。
//   ⇒ `dsk_utf16_len` 与 `dsk_index_of` 必须按码元算，切进去的位置却交给按码位工作的 `hide`。
//   腿的 astral 夹具（`🍎`＝2 码元 1 码位）逐条钉住这个组合，spec §16.3 有对号读数。

///|
/// UTF-16 码元数（＝参照 `String.length()`）：码位大于 `0xFFFF` 的算 2。
fn dsk_utf16_len(s : String) -> Int {
  let mut n = 0
  for c in s.to_array() {
    n = n + (if c.to_int() > 0xffff { 2 } else { 1 })
  }
  n
}

///|
/// 参照 `StrUtil.indexOf(str, ch)`：给**码元**索引，找不到给 -1。
fn dsk_index_of(s : String, target : Char) -> Int {
  let cs = s.to_array()
  let mut i = 0
  for c in cs {
    if c == target {
      return i
    }
    i = i + (if c.to_int() > 0xffff { 2 } else { 1 })
  }
  -1
}

///|
/// 参照 `CharUtil.SPACE` 那一支：`StrUtil.repeat('*', n)`，`n` 由调用方按码元数给出。
fn dsk_repeat_mask(n : Int) -> String {
  let out : Array[Char] = []
  for _ in 0..<n {
    out.push('*')
  }
  String::from_array(out)
}

///|
/// 参照 `StrUtil.subBefore(s, delim, false)`：取第一个分隔符之前的段，没有分隔符时给整串。
fn dsk_sub_before(s : String, delim : Char) -> String {
  let cs = s.to_array()
  let out : Array[Char] = []
  for c in cs {
    if c == delim {
      return String::from_array(out)
    }
    out.push(c)
  }
  s
}

///|
/// #23.83 只显示第一个字符，其余按码位全掩
/// - Returns: 空白入参给空串；其余给"首字符 + 其余位全 `*`"
/// - Raises: 无
/// - Note: hutool 对位 `static String firstMask(String)`（`StrUtil.hide(str, 1, str.length())`）
pub fn desensitize_first_mask(str : String) -> String {
  if @text.is_blank(str) {
    ""
  } else {
    @text.hide(str, 1, dsk_utf16_len(str), '*')
  }
}

///|
/// #23.84 中文姓名脱敏（参照就是 #23.83 的一行委托，件保留、嘴不留第二张）
/// - Returns: 同 #23.83
/// - Raises: 无
/// - Note: hutool 对位 `static String chineseName(String fullName)`
pub fn desensitize_chinese_name(full_name : String) -> String {
  desensitize_first_mask(full_name)
}

///|
/// #23.85 身份证按"保留前 front 位、后 end 位"脱敏
/// - Returns: 三道闸依次是 空白 / `front + end > 码元长度` / `front < 0 || end < 0`，命中任一条给空串；
///   其余给 `[front, 码元长度 - end)` 段全掩（边界按码元、遮蔽按码位，照参照不抹平）
/// - Raises: 无
/// - Note: hutool 对位 `static String idCardNum(String, int, int)`
pub fn desensitize_id_card(id_card : String, front : Int, end : Int) -> String {
  if @text.is_blank(id_card) {
    return ""
  }
  let len = dsk_utf16_len(id_card)
  if front + end > len {
    return ""
  }
  if front < 0 || end < 0 {
    return ""
  }
  @text.hide(id_card, front, len - end, '*')
}

///|
/// #23.86 固定电话脱敏（前 4 位、后 2 位保留）
/// - Returns: 空白给空串；短到 `start > end` 时由 `hide` 消化（腿给原样返回的读数）
/// - Raises: 无
/// - Note: hutool 对位 `static String fixedPhone(String)`（`hide(num, 4, len - 2)`）
pub fn desensitize_fixed_phone(num : String) -> String {
  if @text.is_blank(num) {
    return ""
  }
  @text.hide(num, 4, dsk_utf16_len(num) - 2, '*')
}

///|
/// #23.87 手机号脱敏（前 3 位、后 4 位保留）
/// - Returns: 同 #23.86 的形状（`hide(num, 3, len - 4)`）
/// - Raises: 无
/// - Note: hutool 对位 `static String mobilePhone(String)`
pub fn desensitize_mobile_phone(num : String) -> String {
  if @text.is_blank(num) {
    return ""
  }
  @text.hide(num, 3, dsk_utf16_len(num) - 4, '*')
}

///|
/// #23.88 地址脱敏：从尾部去掉 `sensitive_size` 位，其余保留
/// - Returns: 空白给空串；`sensitive_size > 码元长度` 时起始位为负，参照不报错、由 `hide` 把整串掩掉
/// - Raises: 无
/// - Note: hutool 对位 `static String address(String, int)`（`hide(a, len - n, len)`）
pub fn desensitize_address(address : String, sensitive_size : Int) -> String {
  if @text.is_blank(address) {
    return ""
  }
  let len = dsk_utf16_len(address)
  @text.hide(address, len - sensitive_size, len, '*')
}

///|
/// #23.89 邮箱脱敏：`'@'` 之前只留首字符，`@` 及其后原样
/// - Returns: 空白给空串；无 `@` 或 `'@'` 的**码元**索引 `<= 1` 时原样返回
/// - Raises: 无
/// - Note: hutool 对位 `static String email(String)`（`StrUtil.indexOf` 给码元索引）
pub fn desensitize_email(email : String) -> String {
  if @text.is_blank(email) {
    return ""
  }
  let index = dsk_index_of(email, '@')
  if index <= 1 {
    email
  } else {
    @text.hide(email, 1, index, '*')
  }
}

///|
/// #23.90 密码全掩
/// - Returns: 空白给空串；否则 `*` 重复**码元数**次——astral 密码的星号会比码位数多（腿有读数钉这条）
/// - Raises: 无
/// - Note: hutool 对位 `static String password(String)`（`StrUtil.repeat('*', length())`）
pub fn desensitize_password(password : String) -> String {
  if @text.is_blank(password) {
    return ""
  }
  dsk_repeat_mask(dsk_utf16_len(password))
}

///|
/// #23.91 车牌脱敏
/// - Returns: 空白给空串；**只有码元长度为 7 或 8** 的车牌动手（分别掩 `[3,6)` / `[3,7)`），其余长度原样
/// - Raises: 无
/// - Note: hutool 对位 `static String carLicense(String)`
pub fn desensitize_car_license(car_license : String) -> String {
  if @text.is_blank(car_license) {
    return ""
  }
  if dsk_utf16_len(car_license) == 7 {
    @text.hide(car_license, 3, 6, '*')
  } else if dsk_utf16_len(car_license) == 8 {
    @text.hide(car_license, 3, 7, '*')
  } else {
    car_license
  }
}

///|
/// #23.92 银行卡脱敏
/// - Returns: 空白**原样返回入参**（本批独一份的不对称）；先去全部空白，清洗后长度 `< 9` 给清洗后的原串；
///   否则 `前 4 位 + 中段星号（每满 4 位先插一个空格）+ 空格 + 末 (len%4==0?4:len%4) 位`
/// - Raises: 无
/// - Note: hutool 对位 `static String bankCard(String)`
pub fn desensitize_bank_card(bank_card_no : String) -> String {
  if @text.is_blank(bank_card_no) {
    return bank_card_no
  }
  let cleaned = ds_clean_blank(bank_card_no)
  let length = dsk_utf16_len(cleaned)
  if length < 9 {
    return cleaned
  }
  let end_length = if length % 4 == 0 { 4 } else { length % 4 }
  let mid_length = length - 4 - end_length
  let cs = cleaned.to_array()
  let buf : Array[Char] = []
  for i in 0..<4 {
    buf.push(cs[i])
  }
  for i in 0..<mid_length {
    if i % 4 == 0 {
      buf.push(' ')
    }
    buf.push('*')
  }
  buf.push(' ')
  for i in (length - end_length)..<length {
    buf.push(cs[i])
  }
  String::from_array(buf)
}

///|
/// #23.93 IPv4 脱敏：**不做任何校验**，取第一个 `.` 之前的段再补 `.*.*.*`
/// - Returns: 无 `.` 时整串当第一段，空串给 `".*.*.*"`
/// - Raises: 无
/// - Note: hutool 对位 `static String ipv4(String)`；与第二批 `Ipv4Util`、`valid.is_ipv4` 无关，不许引校验嘴
pub fn desensitize_ipv4(ipv4 : String) -> String {
  dsk_sub_before(ipv4, '.') + ".*.*.*"
}

///|
/// #23.94 IPv6 脱敏：同 #23.93，分隔符换 `:`、尾巴是 7 段 `:*`
/// - Returns: 无 `:` 时整串当第一段
/// - Raises: 无
/// - Note: hutool 对位 `static String ipv6(String)`
pub fn desensitize_ipv6(ipv6 : String) -> String {
  dsk_sub_before(ipv6, ':') + ":*:*:*:*:*:*:*"
}

///|
/// #23.95 用户 ID 的"不给真值"出口
/// - Returns: 恒给 `0`（参照 `userId()` 就是 `return 0L`，无任何入参）
/// - Raises: 无
/// - Note: hutool 对位 `static Long userId()`
pub fn desensitize_user_id() -> Int64 {
  0L
}

///|
/// #23.96 按档位串调度
/// - Returns: 空白入参一律 `Some("")`；15 档各自委派对应件；`CLEAR_TO_NULL` 给 `None`（参照给 `null`）；
///   `USER_ID` 丢弃入参给 `Some("0")`；未列出的档位串照参照 `switch` 的空 `default` 给原串
///   （枚举穷尽、那一档在参照里走不到，无腿读数，是构造解释不是新语义）
/// - Raises: 无
/// - Note: hutool 对位 `static String desensitized(CharSequence, DesensitizedType)`；
///   枚举 15 档在本库收**档位串**（照 §15.1 先例：不为本格新开 `pub enum`）
pub fn desensitize_kind(text : String, kind : String) -> String? {
  if @text.is_blank(text) {
    return Some("")
  }
  match kind {
    "USER_ID" => Some("0")
    "CHINESE_NAME" => Some(desensitize_chinese_name(text))
    "ID_CARD" => Some(desensitize_id_card(text, 1, 2))
    "FIXED_PHONE" => Some(desensitize_fixed_phone(text))
    "MOBILE_PHONE" => Some(desensitize_mobile_phone(text))
    "ADDRESS" => Some(desensitize_address(text, 8))
    "EMAIL" => Some(desensitize_email(text))
    "PASSWORD" => Some(desensitize_password(text))
    "CAR_LICENSE" => Some(desensitize_car_license(text))
    "BANK_CARD" => Some(desensitize_bank_card(text))
    "IPV4" => Some(desensitize_ipv4(text))
    "IPV6" => Some(desensitize_ipv6(text))
    "FIRST_MASK" => Some(desensitize_first_mask(text))
    "CLEAR_TO_NULL" => None
    "CLEAR_TO_EMPTY" => Some("")
    _ => Some(text)
  }
}
