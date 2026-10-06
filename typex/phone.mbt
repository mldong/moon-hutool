///|
// moon-hutool/typex —— 电话号码面（ROADMAP 第 23 行第三批 A，#23.33–#23.47）
// 对位 hutool `cn.hutool.core.util.PhoneUtil`（15 件公开静态：7 判定 + 8 取串/掩码，`javap` 现读）。
// 契约真相在 `docs/spec/23-typex.md` §11；本文件此刻是签名骨架——函数体是 abort，落地笔（PR-B）替换。
//
// 一句话口径（三条不显眼但决定形状，都有腿读数为凭）：
// - **索引域有两个**：`StrUtil.sub` 按 **UTF-16 码元**，而 `StrUtil.hide` 按**码位**。
//   astral 样本 `"1380013🍎8000"`（13 码元 / 12 码位）上两族同时可见：`subAfter` 给 `🍎80`（码元 7..11），
//   `hideAfter` 给 `1380013****0`（掩掉码位 7..11）。⇒ `hide_*` 三件复用仓内 `@text.hide`（本来就是码位档），
//   `sub_*` 三件必须自带码元切片（`@text` 的 `sub_*` 是分隔符口径，且没有码元档）。
// - `phone_is_mobile` 复用 `@valid.is_mobile`（码表逐字符相同），本包不复制第二张手机号表。
// - `sub_tel_*` 是"查找 + 取组"（不锚定），参照无匹配给 `null` ⇒ 本库出口 `String?`。

///|
/// #23.33 中国大陆手机号。对位 `static boolean isMobile(CharSequence)`
/// - Returns: 整串匹配 `MOBILE` 码表（可带 `0`/`86`/`+86` 前缀，段头 `1[3-9]`，共 11 位）
/// - Raises: 无
/// - Note: hutool 走 `Validator.isMatchRegex(PatternPool.MOBILE, …)`；本库委托 `@valid.is_mobile`（同码表同判据）
pub fn phone_is_mobile(value : String) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.33")
}

///|
/// #23.34 香港手机号。对位 `static boolean isMobileHk(CharSequence)`
/// - Note: 码表 `(?:0|852|\+852)?[[:digit:]]{8}`（腿反射读 `PatternPool.MOBILE_HK`，`flags=0`）
/// - Raises: 无
pub fn phone_is_mobile_hk(value : String) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.34")
}

///|
/// #23.35 台湾手机号。对位 `static boolean isMobileTw(CharSequence)`
/// - Note: 码表 `(?:0|886|\+886)?(-|)?09[[:digit:]]{8}`——**`09` 开头是硬要求**
/// - Raises: 无
pub fn phone_is_mobile_tw(value : String) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.35")
}

///|
/// #23.36 澳门手机号。对位 `static boolean isMobileMo(CharSequence)`
/// - Note: 码表 `(?:0|853|\+853)?(-|)?6[[:digit:]]{7}`
/// - Raises: 无
pub fn phone_is_mobile_mo(value : String) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.36")
}

///|
/// #23.37 固定电话（区号 + 号码）。对位 `static boolean isTel(CharSequence)`
/// - Note: 码表 `(010|02[[:digit:]]|0[3-9][[:digit:]]{2})-?([[:digit:]]{6,8})`——**区号是白名单式**，
///   `0[3-9]` 打头的必须是三位区号（腿有 `0755-1234567` 真、`01012345678` 归 400/800 那档不算 tel 的对照）
/// - Raises: 无
pub fn phone_is_tel(value : String) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.37")
}

///|
/// #23.38 400 / 800 号码。对位 `static boolean isTel400800(CharSequence)`
/// - Note: 码表 `0[[:digit:]]{2,3}(-| )?[1-9][[:digit:]]{6,7}|[48]00(-| )?[1-9][[:digit:]]{2}(-| )?[[:digit:]]{4}`
///   （分隔符可选，`-` 或空格；**改写时丢掉 `?` 会漏掉无分隔符那一档**，腿的 `01012345678` 就是那条夹具）
/// - Raises: 无
pub fn phone_is_tel400800(value : String) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.38")
}

///|
/// #23.39 "是不是电话"。对位 `static boolean isPhone(CharSequence)`
/// - Returns: **五路之或**——手机 / 400·800 / 港 / 台 / 澳，**不含 #23.37 的固话**
/// - Raises: 无
/// - Note: 这条最容易"顺手补上固话"，参照没有：腿读数 `"010-12345678"` 给 `is_tel=true` 而 `is_phone=false`
pub fn phone_is_phone(value : String) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.39")
}

///|
/// #23.40 掩掉前 7 位。对位 `static CharSequence hideBefore(CharSequence)`
/// - Returns: 码位 0..7 换成 `*`（**码位口径**，与 #23.43 的码元口径不同）
/// - Raises: 无（越界夹紧、不校验号型：`"12345"` 也照样掩）
/// - Note: 参照是 `StrUtil.hide(phone, 0, 7)`，本库复用 `@text.hide(_, 0, 7, '*')`
pub fn phone_hide_before(phone : String) -> String {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.40")
}

///|
/// #23.41 掩掉中间 4 位（码位 3..7）。对位 `static CharSequence hideBetween(CharSequence)`
/// - Raises: 无
pub fn phone_hide_between(phone : String) -> String {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.41")
}

///|
/// #23.42 掩掉后段（码位 7..11）。对位 `static CharSequence hideAfter(CharSequence)`
/// - Raises: 无
pub fn phone_hide_after(phone : String) -> String {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.42")
}

///|
/// #23.43 取前 3 段。对位 `static CharSequence subBefore(CharSequence)`
/// - Returns: **码元** 0..3（`hide` 系是码位、`sub` 系是码元，两族不同域）
/// - Raises: 无
pub fn phone_sub_before(phone : String) -> String {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.43")
}

///|
/// #23.44 取码元 3..7。对位 `static CharSequence subBetween(CharSequence)`
/// - Raises: 无
pub fn phone_sub_between(phone : String) -> String {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.44")
}

///|
/// #23.45 取码元 7..11。对位 `static CharSequence subAfter(CharSequence)`
/// - Raises: 无
/// - Note: astral 样本上是**区分两族索引域**的那条读数：给 `🍎80`（码元 7..11），不是 `🍎888`（码位 7..11）
pub fn phone_sub_after(phone : String) -> String {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.45")
}

///|
/// #23.46 取固话的区号段。对位 `static CharSequence subTelBefore(CharSequence)`
/// - Returns: `TEL` 码表的**第 1 组**（查找式，不锚定）；无匹配给 `None`（参照给 `null`）
/// - Raises: 无
pub fn phone_sub_tel_before(value : String) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.46")
}

///|
/// #23.47 取固话的号码段。对位 `static CharSequence subTelAfter(CharSequence)`
/// - Returns: `TEL` 码表的第 2 组；无匹配给 `None`
/// - Raises: 无
pub fn phone_sub_tel_after(value : String) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.47")
}
