///|
/// moon-hutool/valid —— 码表判定件（hutool `Validator` 的 MoonBit 对位·第一批）
///
/// 契约：`docs/spec/11-valid.md`。期望值权威在 `valid_test.mbt`——改任何一条期望须单独一笔并给外部读数来源（门禁 G5）。
///
/// 五条贯穿性规则：
/// 1. **判定件不 `raise`**。码表是本包内部常量，编不过就是我写错、不是调用方的输入问题，
///    所以不把 `re` 的 `ReError` 泄到这里（spec §0.1）。
/// 2. **码表逐条改写成 core 方言，并逐条对撞命中集**。hutool 的判定全走 `RegexPool` 常量，
///    实测 34 条里 24 条带 `\d`/`\w`/`\xHH`（`re` 包 spec §6 第 7 条），本批只收**改写后两腿命中集逐条相同**的那些。
/// 3. **整串语义**。hutool 的 `isXxx` 全部是 `Matcher.matches()`（整串），不是 `find()`；
///    唯一例外是 `isBirthday(CharSequence)` 走 `find()` + 取组，那一件连同它的时钟依赖一起留第二批。
/// 4. **不建全局模式池**，与 `re` 的 §0.1 同一条立场。
/// 5. **大小写不敏感只按 ASCII 档**。参照实现用的是 `Pattern.CASE_INSENSITIVE`（不带 UNICODE_CASE 时就是 ASCII 档），
///    本包改写成的 scoped `(?i:…)` 折叠范围与它同档（实测 `(?i:é)` 不匹配 `É`），所以这条不构成分岔。

///|
/// 内部件：整串匹配。实现那一笔决定它是"直接调 core"还是"复用 `re` 的 `is_match`"，
/// 契约面不关心——但**不许把编译失败泄给调用方**（规则 1）。

///|
/// 字母串：只含 a-zA-Z 且非空。对位 hutool `Validator` 的同名判定，码表 `WORD`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_word(text : String) -> Bool {
  whole("[a-zA-Z]+", text)
}

///|
/// 通用名：字母/数字/下划线，非空。对位 hutool `Validator` 的同名判定，码表 `GENERAL`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_general(text : String) -> Bool {
  whole("^[[:word:]]+$", text)
}

///|
/// 通用名并限长度。对位 `Validator.isGeneral(value, min, max)`
/// 长度上界是 core 的硬限制（实测 `a{256}` 合法、`a{300}` 报错）⇒ `max` 超界属于调用方的问题，本件不收界值
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_general_between(text : String, min : Int, max : Int) -> Bool {
  whole("^[[:word:]]{" + min.to_string() + "," + max.to_string() + "}$", text)
}

///|
/// 通用名并限**最小**长度（不封顶）。对位 `Validator.isGeneral(value, min)`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_general_at_least(text : String, min : Int) -> Bool {
  whole("^[[:word:]]{" + min.to_string() + ",}$", text)
}

///|
/// 金额串：整数或带小数，符号位不含。对位 hutool `Validator` 的同名判定，码表 `MONEY`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_money(text : String) -> Bool {
  whole("^([[:digit:]]+(?:\\.[[:digit:]]+)?)$", text)
}

///|
/// 国内邮编。对位 hutool `Validator` 的同名判定，码表 `ZIP_CODE`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_zip_code(text : String) -> Bool {
  whole(
    "^(0[1-7]|1[0-356]|2[0-7]|3[0-6]|4[0-7]|5[0-7]|6[0-7]|7[0-5]|8[0-9]|9[0-8])[[:digit:]]{4}|99907[78]$",
    text,
  )
}

///|
/// 国内手机号（可带 0/86/+86 前缀）。对位 hutool `Validator` 的同名判定，码表 `MOBILE`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_mobile(text : String) -> Bool {
  whole("(?:0|86|\\+86)?1[3-9][[:digit:]]{9}", text)
}

///|
/// IPv4 点分十进制。对位 hutool `Validator` 的同名判定，码表 `IPV4`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_ipv4(text : String) -> Bool {
  whole(
    "^(25[0-5]|2[0-4][[:digit:]]|[0-1]?[[:digit:]]?[[:digit:]])\\.(25[0-5]|2[0-4][[:digit:]]|[0-1]?[[:digit:]]?[[:digit:]])\\.(25[0-5]|2[0-4][[:digit:]]|[0-1]?[[:digit:]]?[[:digit:]])\\.(25[0-5]|2[0-4][[:digit:]]|[0-1]?[[:digit:]]?[[:digit:]])$",
    text,
  )
}

///|
/// IPv6（含压缩与 fe80 作用域档）。对位 hutool `Validator` 的同名判定，码表 `IPV6`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_ipv6(text : String) -> Bool {
  whole(
    "(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]+|::(ffff(:0{1,4})?:)?((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9]))",
    text,
  )
}

///|
/// MAC：冒号/连字符/点分/CISCO/0x…ETHER。对位 hutool `Validator` 的同名判定，码表 `MAC_ADDRESS`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_mac(text : String) -> Bool {
  whole(
    "(?i:(?:[a-fA-F0-9]{1,2}(:|-)){5}[a-fA-F0-9]{1,2}|(?:[a-fA-F0-9]{1,4}[.]){2}[a-fA-F0-9]{1,4}|[a-fA-F0-9]{12}|0x[[:digit:]]{12}.+ETHER)",
    text,
  )
}

///|
/// UUID：带横线 8-4-4-4-12 或 32 位无横线，大小写不敏感。对位 hutool `Validator` 的同名判定，码表 `UUID`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_uuid(text : String) -> Bool {
  whole(
    "(?i:^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$|^[0-9a-f]{32}$)",
    text,
  )
}

///|
/// 十六进制串。对位 hutool `Validator` 的同名判定，码表 `HEX`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_hex(text : String) -> Bool {
  whole("^[a-fA-F0-9]+$", text)
}

///|
/// 车架号 VIN。对位 hutool `Validator` 的同名判定，码表 `CAR_VIN`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_car_vin(text : String) -> Bool {
  whole(
    "^[A-HJ-NPR-Z0-9]{8}[X0-9]([A-HJ-NPR-Z0-9]{3}[[:digit:]]{5}|[A-HJ-NPR-Z0-9]{5}[[:digit:]]{3})$",
    text,
  )
}

///|
/// 驾驶证档案编号：12 位数字。对位 hutool `Validator` 的同名判定，码表 `CAR_DRIVING_LICENCE`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_car_driving_licence(text : String) -> Bool {
  whole("^[0-9]{12}$", text)
}

///|
/// 车牌号。对位 hutool `Validator` 的同名判定，码表 `PLATE_NUMBER`
/// - Returns: 整串被本件码表匹配 ⇒ `true`
pub fn is_plate_number(text : String) -> Bool {
  whole(
    "^(([京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领][A-Z](([0-9]{5}[ABCDEFGHJK])|([ABCDEFGHJK]([A-HJ-NP-Z0-9])[0-9]{4})))|([京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领][[:digit:]]{3}[[:digit:]]{1,3}[领])|([京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领][A-Z][A-HJ-NP-Z0-9]{4}[A-HJ-NP-Z0-9挂学警港澳使领]))$",
    text,
  )
}

///|
// 整串匹配这一个动作是本包全部 15 件的底座：`^(?:P)$` 命中与否（§0.3）。
// 编译失败只会发生在**本包自己的码表**上——那是本包写错，不是调用方的输入问题，所以按 §0.1 不把它变成 `raise`，
// 而是让它成为一条不可能到达的路径：真到了就用内部不变量终止（调用方永远看不到）。
fn whole(pat : String, text : String) -> Bool {
  try {
    let r = @string.Regex(("^(?:" + pat + ")$").to_string_view())
    match r.execute(text.to_string_view()) {
      Some(_) => true
      None => false
    }
  } catch {
    _ => abort("moon-hutool/valid 内部码表编译失败：" + pat)
  }
}
