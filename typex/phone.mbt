///|
// moon-hutool/typex —— 电话号码面（ROADMAP 第 23 行第三批 A，#23.33–#23.47）
// 对位 hutool `cn.hutool.core.util.PhoneUtil`（15 件公开静态：7 判定 + 3 掩码 + 3 取串 + 2 固话取组，`javap` 现读）。
// 契约真相在 `docs/spec/23-typex.md` §11。
//
// 三条决定实现形状、且都有腿读数为凭的事实：
// - **两族索引域不同**：`hide_*` 三件按**码位**（参照 `StrUtil.hide`，掩码是就地替换码位，所以 astral 样本
//   `"1380013🍎8000"` 的 `hideAfter` 输出比输入少一个码元），`sub_*` 三件按 **UTF-16 码元**
//   （参照 `StrUtil.sub`，同一样本的 `subAfter` 给 `🍎80` = 码元 7..11）。
//   ⇒ 掩码族直接复用 `@text.hide`（它本来就是码位档），取串族自带码元切片。
// - 六枚码表由反射读 `PatternPool` 的源文与 flags（flags 全 0 ⇒ 不做大小写不敏感档），
//   并逐条在 core 方言下对撞过命中集（`re`/`valid` 轮的规矩；对撞当场抓到过"分隔符组丢掉 `?`"这种改写错档）。
// - `phone_is_mobile` 委托 `@valid.is_mobile`（`MOBILE` 源文与该包已冻结的模式逐字符相同），不留第二张手机号表。

///|
fn phone_units(s : String) -> Array[Int] {
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
/// 码元序列合回合法串：代理对成对时合成一个码位。取串族只在 `sub` 的起止处切开，
/// 参照按码元切片可能把代理对劈开——那时参照给出的就是**半个代理对**，
/// 而 MoonBit 的 `String` 装不下孤立代理项，故本库把落单的低位代理并入相邻码位边界之外（见 spec §11.5 末行）。
fn phone_from_units(us : Array[Int], b : Int, e : Int) -> String {
  let cs : Array[Char] = []
  let mut i = b
  while i < e {
    let u = us[i]
    let hi = u >= 0xd800 && u <= 0xdbff
    if hi && i + 1 < e {
      let lo = us[i + 1]
      if lo >= 0xdc00 && lo <= 0xdfff {
        let cp = (u - 0xd800) * 0x400 + (lo - 0xdc00) + 0x10000
        cs.push(cp.unsafe_to_char())
        i = i + 2
        continue
      }
    }
    if hi && i + 1 >= e {
      // 高代理落在切片尾：参照会吐出一个孤立代理项（Java 的 String 允许），MoonBit 不允许 ⇒ 该位直接丢弃，
      // 差异只在"切片正好切进代理对"时可见，spec §11.5 记这一行
      i = i + 1
      continue
    }
    if !hi &&
      u >= 0xdc00 &&
      u <= 0xdfff &&
      (i == b || us[i - 1] < 0xd800 || us[i - 1] > 0xdbff) {
      // 低代理落在切片头：同上，参照给孤立代理项，本库丢弃
      i = i + 1
      continue
    }
    cs.push(u.unsafe_to_char())
    i = i + 1
  }
  String::from_array(cs)
}

///|
fn phone_sub_units(s : String, b : Int, e : Int) -> String {
  let us = phone_units(s)
  let n = us.length()
  let lo = if b < 0 { 0 } else if b > n { n } else { b }
  let hi = if e < 0 { 0 } else if e > n { n } else { e }
  if lo >= hi {
    return ""
  }
  phone_from_units(us, lo, hi)
}

///|
// 六枚码表：源文与 flags 由反射读 `PatternPool`（见腿 `PhoneLeg`），逐条按 core 方言改写并对撞命中集。
// 改写规则同 `valid` 包：`\d` → `[[:digit:]]`、类内 `[\- ]` → `(-| )`（类里 `-` 与别的字符并排本版判非法），
// 整串匹配靠 `^(?:P)$` 包裹（参照侧 `Validator.isMatchRegex` 就是 `matches()`）。
let pat_mobile_hk : String = "(?:0|852|\\+852)?[[:digit:]]{8}"

///|
let pat_mobile_tw : String = "(?:0|886|\\+886)?(-|)?09[[:digit:]]{8}"

///|
let pat_mobile_mo : String = "(?:0|853|\\+853)?(-|)?6[[:digit:]]{7}"

///|
let pat_tel : String = "(010|02[[:digit:]]|0[3-9][[:digit:]]{2})-?([[:digit:]]{6,8})"

///|
let pat_tel400800 : String = "0[[:digit:]]{2,3}(-| )?[1-9][[:digit:]]{6,7}|[48]00(-| )?[1-9][[:digit:]]{2}(-| )?[[:digit:]]{4}"

///|
/// 整串匹配是本批判定档的底座（同 `valid` 包 §0.3）。
/// 码表编译失败只会发生在**本包自己的常量**上 ⇒ 不变成 `raise`，按不可能到达的路径处理。
fn whole(pat : String, value : String) -> Bool {
  try {
    let r = @string.Regex(("^(?:" + pat + ")$").to_string_view())
    match r.execute(value.to_string_view()) {
      Some(_) => true
      None => false
    }
  } catch {
    _ => abort("moon-hutool/typex 内部码表编译失败：" + pat)
  }
}

///|
/// 参照 `ReUtil.getGroup1` / `get(TEL, v, 2)`：**查找式**（不锚定），无匹配给 `null` ⇒ 本库给 `None`。
fn tel_group(value : String, group : Int) -> String? {
  try {
    let r = @string.Regex(pat_tel.to_string_view())
    match r.execute(value.to_string_view()) {
      None => None
      Some(m) =>
        match m.group(group) {
          None => None
          Some(v) => Some(v.to_owned())
        }
    }
  } catch {
    _ => abort("moon-hutool/typex 内部码表编译失败：" + pat_tel)
  }
}

///|
/// #23.33 中国大陆手机号
/// - Returns: 整串匹配 `MOBILE`（可带 `0`/`86`/`+86` 前缀、段头 `1[3-9]`、共 11 位）
/// - Raises: 无
/// - Note: hutool 对位 `static boolean isMobile(CharSequence)`；本库委托 `@valid.is_mobile`（同码表同判据）
pub fn phone_is_mobile(value : String) -> Bool {
  @valid.is_mobile(value)
}

///|
/// #23.34 香港手机号
/// - Raises: 无
/// - Note: hutool 对位 `isMobileHk`，码表 `(?:0|852|\+852)?[[:digit:]]{8}`
pub fn phone_is_mobile_hk(value : String) -> Bool {
  whole(pat_mobile_hk, value)
}

///|
/// #23.35 台湾手机号
/// - Raises: 无
/// - Note: hutool 对位 `isMobileTw`，码表 `(?:0|886|\+886)?(-|)?09[[:digit:]]{8}`——`09` 开头是硬要求
pub fn phone_is_mobile_tw(value : String) -> Bool {
  whole(pat_mobile_tw, value)
}

///|
/// #23.36 澳门手机号
/// - Raises: 无
/// - Note: hutool 对位 `isMobileMo`，码表 `(?:0|853|\+853)?(-|)?6[[:digit:]]{7}`
pub fn phone_is_mobile_mo(value : String) -> Bool {
  whole(pat_mobile_mo, value)
}

///|
/// #23.37 固定电话（区号 + 号码）
/// - Raises: 无
/// - Note: hutool 对位 `isTel`；区号是白名单式（`010` / `02x` / `0[3-9]` 三位），分隔符 `-` 可选
pub fn phone_is_tel(value : String) -> Bool {
  whole(pat_tel, value)
}

///|
/// #23.38 400 / 800 号码（以及"区号 2~3 位 + 号码"那一支）
/// - Raises: 无
/// - Note: hutool 对位 `isTel400800`；**分隔符是可选的**（`(-| )?`），
///   丢那个 `?` 就会漏掉 `"01012345678"` 这种无分隔档——方言对撞当场抓到过一次
pub fn phone_is_tel400800(value : String) -> Bool {
  whole(pat_tel400800, value)
}

///|
/// #23.39 「是不是电话」
/// - Returns: **五路之或**——手机 / 400·800 / 港 / 台 / 澳；**不含 #23.37 的固话**
///   （腿成对读数：`"010-02345678"` 给 `is_tel=true` 而 `is_phone=false`——号码段以 `0` 开头时
///   `TEL` 吃、`TEL_400_800` 两支都不吃；注意 `"010-12345678"` **不能**当这对读数，它 `is_phone=true`）
/// - Raises: 无
/// - Note: hutool 对位 `isPhone`
pub fn phone_is_phone(value : String) -> Bool {
  phone_is_mobile(value) ||
  phone_is_tel400800(value) ||
  phone_is_mobile_hk(value) ||
  phone_is_mobile_tw(value) ||
  phone_is_mobile_mo(value)
}

///|
/// #23.40 掩掉前 7 位（**码位**口径）
/// - Raises: 无（越界夹紧、不校验号型：`"12345"` 也照样掩）
/// - Note: hutool 对位 `hideBefore` = `StrUtil.hide(phone, 0, 7)`；本库复用 `@text.hide`
pub fn phone_hide_before(phone : String) -> String {
  @text.hide(phone, 0, 7, '*')
}

///|
/// #23.41 掩掉码位 3..7
/// - Raises: 无
/// - Note: hutool 对位 `hideBetween` = `StrUtil.hide(phone, 3, 7)`
pub fn phone_hide_between(phone : String) -> String {
  @text.hide(phone, 3, 7, '*')
}

///|
/// #23.42 掩掉码位 7..11
/// - Raises: 无
/// - Note: hutool 对位 `hideAfter` = `StrUtil.hide(phone, 7, 11)`；
///   astral 样本上输出**比输入少一个码元**（掩的是码位），这条读数就是两族口径的分界证据
pub fn phone_hide_after(phone : String) -> String {
  @text.hide(phone, 7, 11, '*')
}

///|
/// #23.43 取码元 0..3（**码元**口径，与掩码族不同域）
/// - Raises: 无
/// - Note: hutool 对位 `subBefore` = `StrUtil.sub(phone, 0, 3)`
pub fn phone_sub_before(phone : String) -> String {
  phone_sub_units(phone, 0, 3)
}

///|
/// #23.44 取码元 3..7
/// - Raises: 无
/// - Note: hutool 对位 `subBetween` = `StrUtil.sub(phone, 3, 7)`
pub fn phone_sub_between(phone : String) -> String {
  phone_sub_units(phone, 3, 7)
}

///|
/// #23.45 取码元 7..11
/// - Raises: 无
/// - Note: hutool 对位 `subAfter` = `StrUtil.sub(phone, 7, 11)`；
///   样本 `"1380013🍎8000"` 上参照给 `🍎80`（高代理、低代理、`8`、`0`）
pub fn phone_sub_after(phone : String) -> String {
  phone_sub_units(phone, 7, 11)
}

///|
/// #23.46 取固话区号段（`TEL` 的第 1 组，查找式）
/// - Returns: 无匹配给 `None`（参照给 `null`）
/// - Raises: 无
/// - Note: hutool 对位 `subTelBefore` = `ReUtil.getGroup1(PatternPool.TEL, value)`
pub fn phone_sub_tel_before(value : String) -> String? {
  tel_group(value, 1)
}

///|
/// #23.47 取固话号码段（`TEL` 的第 2 组，查找式）
/// - Returns: 无匹配给 `None`
/// - Raises: 无
/// - Note: hutool 对位 `subTelAfter` = `ReUtil.get(PatternPool.TEL, value, 2)`
pub fn phone_sub_tel_after(value : String) -> String? {
  tel_group(value, 2)
}
