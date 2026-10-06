///|
// moon-hutool/typex —— IPv4 算式面（ROADMAP 第 23 行第二批，#23.15–#23.32）
// 对位 hutool `cn.hutool.core.net.Ipv4Util`（**件在 `core/net` 不在 `core/util`**，
// `unzip -l hutool-core.jar | grep -i ipv4` 现读 `cn/hutool/core/net/Ipv4Util.class`）。
// 契约真相在 `docs/spec/23-typex.md` §10。
//
// 一句话口径（四处与直觉相反，都有腿读数为凭）：
// - **IP 合法性判据复用 `@valid.is_ipv4`**：三方命中集 33 样本零分歧（`Validator.isIpv4`、
//   `PatternPool.IPV4`、本库 `is_ipv4`），阳性对照挂过（翻一条期望立即报红）⇒ 不再自带第二张嘴。
//   前导零照收（`01.2.3.4` 与 `1.2.3.4` 同值），但每段最多 3 位。
// - **`count_by_*` 两件跟随参照的 double→int 饱和窄化**：`2^32` 给 `2147483647` 而不是回绕，
//   `1|false` 是"先饱和再减 2"给 `2147483645`，`2^-1` 给 `0`。这与第一批那条"取低 32 位回绕"的
//   处置并列——**一个管回绕域，一个管窄化域**。
// - **掩码位定义域只有 1..32**（参照表 0 缺席）：`mask_by_mask_bit(0)` 给 `None`，
//   而 `count_by_mask_bit(0, true)` 照算给 `2147483647`——两条形同实不同，都有断言。
// - 参照在掩码位非法时把 `null` 喂进正则，实测 `NullPointerException`；那是崩溃形状不是契约，
//   本库换成 `BadMaskBit`。求值顺序跟随参照（IP 先算 ⇒ 两处同时非法时先报 `BadIp`）。

///|
/// #23.15 本包错误面。四个变体都不带载荷（出错的输入调用方自己有，"哪一类非法"才是新信息）。
/// 映射依据在 spec §10.5 的表里，每行都指着腿读到的一条 `类名:message` 读数。
pub suberror Ipv4Error {
  BadIp
  BadMask
  BadMaskBit
  BadRange
}

///|
fn ipv4_octets(text : String) -> Array[Int] {
  let out : Array[Int] = []
  let mut cur = 0
  for c in text.to_array() {
    if c == '.' {
      out.push(cur)
      cur = 0
    } else {
      cur = cur * 10 + (c.to_int() - 48)
    }
  }
  out.push(cur)
  out
}

///|
fn ipv4_octet_text(text : String) -> Array[String] {
  let out : Array[String] = []
  let cur : Array[Char] = []
  for c in text.to_array() {
    if c == '.' {
      out.push(String::from_array(cur))
      cur.clear()
    } else {
      cur.push(c)
    }
  }
  out.push(String::from_array(cur))
  out
}

///|
fn join_dots(parts : Array[String]) -> String {
  let mut out = ""
  let mut first = true
  for p in parts {
    if !first {
      out = out + "."
    }
    first = false
    out = out + p
  }
  out
}

///|
/// #23.16 long → 点分串
/// - Returns: 恒有值（只取低 32 位、按四段各 `& 0xff` 拆）
/// - Raises: 无
/// - Note: hutool 对位 `static long→String longToIpv4(long)`；`-1` 给 `255.255.255.255`、
///   `4294967296` 与 `Long.MIN_VALUE` 都给 `0.0.0.0`（腿读数 `L2I|*`）
pub fn long_to_ipv4(v : Int64) -> String {
  join_dots([
    ((v >> 24) & 0xffL).to_string(),
    ((v >> 16) & 0xffL).to_string(),
    ((v >> 8) & 0xffL).to_string(),
    (v & 0xffL).to_string(),
  ])
}

///|
fn ipv4_to_long_ok(text : String) -> Int64? {
  if @valid.is_ipv4(text) {
    let o = ipv4_octets(text)
    let v = (o[0].to_int64() << 24) |
      (o[1].to_int64() << 16) |
      (o[2].to_int64() << 8) |
      o[3].to_int64()
    Some(v)
  } else {
    None
  }
}

///|
/// #23.17 点分串 → long（inet_aton 别名）
/// - Raises: `BadIp`（参照腿 `IllegalArgumentException: Invalid IPv4 address!`）
/// - Note: hutool 对位 `static long ipv4ToLong(String)`
pub fn ipv4_to_long(text : String) -> Int64 raise Ipv4Error {
  match ipv4_to_long_ok(text) {
    Some(v) => v
    None => raise BadIp
  }
}

///|
/// #23.18 点分串 → long，非法给默认值
/// - Raises: 无（参照这一档先问合法性再决定，永不抛）
/// - Note: hutool 对位 `static long ipv4ToLong(String, long)`
pub fn ipv4_to_long_or(text : String, default : Int64) -> Int64 {
  ipv4_to_long_ok(text).unwrap_or(default)
}

///|
fn mask_long(mask_bit : Int) -> Int64? {
  // 参照的 `MaskBit` 表就是 1..32 条连续掩码，用算式复现同一张表：高 mask_bit 位为 1。
  // 表里没有 0 这一档，所以 0 与负数、>32 一律 None（腿 `MBMB|0`→null、`IMBV|0`→false）。
  if mask_bit < 1 || mask_bit > 32 {
    None
  } else {
    Some(0xffffffffL - ((1L << (32 - mask_bit)) - 1L))
  }
}

///|
fn mask_long_strict(mask_bit : Int) -> Int64 raise Ipv4Error {
  match mask_long(mask_bit) {
    Some(v) => v
    None => raise BadMaskBit
  }
}

///|
/// #23.19 网段起始 IP（串）
/// - Raises: `BadIp` | `BadMaskBit`
/// - Note: hutool 对位 `static String getBeginIpStr(String, int)`
pub fn ipv4_begin_ip_str(ip : String, mask_bit : Int) -> String raise Ipv4Error {
  long_to_ipv4(ipv4_begin_ip_long(ip, mask_bit))
}

///|
/// #23.20 网段起始 IP（数值）
/// - Raises: `BadIp`（先）| `BadMaskBit`——参照算式 `ipv4ToLong(ip) & ipv4ToLong(mask)`
///   的左操作数先算，两处同时非法时以 `BadIp` 为准（腿 `BSTR|256.1.1.1|0` 就是钉这一条）
/// - Note: hutool 对位 `static Long getBeginIpLong(String, int)`
pub fn ipv4_begin_ip_long(ip : String, mask_bit : Int) -> Int64 raise Ipv4Error {
  let a = ipv4_to_long(ip)
  let m = mask_long_strict(mask_bit)
  a & m
}

///|
/// #23.21 网段终止 IP（串）
/// - Raises: `BadIp` | `BadMaskBit`
/// - Note: hutool 对位 `static String getEndIpStr(String, int)`
pub fn ipv4_end_ip_str(ip : String, mask_bit : Int) -> String raise Ipv4Error {
  long_to_ipv4(ipv4_end_ip_long(ip, mask_bit))
}

///|
/// #23.22 网段终止 IP（数值）
/// - Raises: `BadIp` | `BadMaskBit`
/// - Note: hutool 对位 `static Long getEndIpLong(String, int)`。参照注释写"此接口返回负数"，
///   实测档里都是正数（`ELNG|218.240.38.69|1` = `4294967295`）⇒ 跟随算式不跟随注释。
///   本版没有 `~` 运算符，掩码补集用 `0xffffffffL ^ m`（`m` 已在低 32 位内，二者同值）。
pub fn ipv4_end_ip_long(ip : String, mask_bit : Int) -> Int64 raise Ipv4Error {
  let begin = ipv4_begin_ip_long(ip, mask_bit)
  let m = mask_long_strict(mask_bit)
  begin + (0xffffffffL ^ m)
}

///|
/// #23.23 掩码串 → 掩码位
/// - Raises: `BadMask`（参照 `IllegalArgumentException: Invalid netmask <输入>`）
/// - Note: hutool 对位 `static int getMaskBitByMask(String)`；掩码必须是连续的 1 前缀，
///   `0.0.0.0` 与 `255.0.255.0` 这类非连续形状都在表外
pub fn mask_bit_by_mask(mask : String) -> Int raise Ipv4Error {
  match mask_bit_of(mask) {
    Some(k) => k
    None => raise BadMask
  }
}

///|
fn mask_bit_of(mask : String) -> Int? {
  let mut k = 1
  while k <= 32 {
    if mask_by_mask_bit(k) == Some(mask) {
      return Some(k)
    }
    k = k + 1
  }
  None
}

///|
/// #23.24 掩码位 → 掩码串
/// - Returns: 定义域 1..32 之外给 `None`（参照给 `null`）
/// - Raises: 无
/// - Note: hutool 对位 `static String getMaskByMaskBit(int)`
pub fn mask_by_mask_bit(mask_bit : Int) -> String? {
  match mask_long(mask_bit) {
    Some(v) => Some(long_to_ipv4(v))
    None => None
  }
}

///|
/// #23.25 子网大小
/// - Returns: `all=true` 给全量、`false` 给可用数（减网络与广播两个）
/// - Raises: 无——**非法掩码位不报错**，跟随参照：`(int) Math.pow(2, 32 - maskBit)` 的越界是饱和窄化
/// - Note: hutool 对位 `static int countByMaskBit(int, boolean)`。参照在 `all=false` 一侧先短路
///   `maskBit <= 0 || maskBit >= 32` 给 0；`all=true` 一侧 `maskBit <= 1` 全部饱和在 `2147483647`、
///   `maskBit >= 33` 给 0（`2^-1` 截断）。`1|false` 走的是"先饱和成 MAX 再减 2" ⇒ `2147483645`。
pub fn count_by_mask_bit(mask_bit : Int, all : Bool) -> Int {
  if !all && (mask_bit <= 0 || mask_bit >= 32) {
    return 0
  }
  let e = 32 - mask_bit
  let count = if e < 0 { 0 } else if e >= 31 { 2147483647 } else { 1 << e }
  if all {
    count
  } else {
    count - 2
  }
}

///|
/// #23.26 IP 段 → 掩码串
/// - Raises: `BadIp`（先算 `to` 再算 `from`，与参照同序）| `BadRange`（参照 `Assert.isTrue(from < to)`，
///   **相等也算非法**——与 #23.27 的相等档相反）
/// - Note: hutool 对位 `static String getMaskByIpRange(String, String)`。逐段 `255 - to + from`
///   拼出来的**不是真 CIDR 掩码**（腿读数含 `255.255.255.249`、`0.0.0.0`），本库原样给出。
pub fn mask_by_ip_range(
  from_ip : String,
  to_ip : String,
) -> String raise Ipv4Error {
  let t = ipv4_to_long(to_ip)
  let f = ipv4_to_long(from_ip)
  if !(f < t) {
    raise BadRange
  }
  let a = ipv4_octets(from_ip)
  let b = ipv4_octets(to_ip)
  join_dots([
    (255 - b[0] + a[0]).to_string(),
    (255 - b[1] + a[1]).to_string(),
    (255 - b[2] + a[2]).to_string(),
    (255 - b[3] + a[3]).to_string(),
  ])
}

///|
/// #23.27 IP 段内有多少个 IP
/// - Raises: `BadIp` | `BadRange`（**只有 `from > to` 才抛，相等给 1**）
/// - Note: hutool 对位 `static int countByIpRange(String, String)`。参照逐步做
///   `count += delta * Math.pow(256, k)`（复合赋值的隐式窄化）⇒ 大段饱和在 `2147483647`，
///   `0.0.0.0—255.255.255.255` 实测就是这个数。本库用移位取精确整值再逐步饱和，
///   与参照同值且不随 `Int` 位宽变。
pub fn count_by_ip_range(
  from_ip : String,
  to_ip : String,
) -> Int raise Ipv4Error {
  let t = ipv4_to_long(to_ip)
  let f = ipv4_to_long(from_ip)
  if f > t {
    raise BadRange
  }
  let a = ipv4_octets(from_ip)
  let b = ipv4_octets(to_ip)
  let mut count : Int64 = 1L
  let mut i = 3
  while i >= 0 {
    let term = (b[i] - a[i]).to_int64() << (8 * (3 - i))
    count = narrow_sat32(count + term)
    i = i - 1
  }
  count.to_int()
}

///|
fn narrow_sat32(v : Int64) -> Int64 {
  // Java 的 `(int) 整数值` 是**饱和**窄化（越界给 MAX/MIN），不是回绕。
  // 各项都是精确整数（无小数），所以这里只需比界。
  if v >= 2147483648L {
    2147483647L
  } else if v <= -2147483649L {
    -2147483648L
  } else {
    v
  }
}

///|
/// #23.28 掩码串是否合法
/// - Raises: 无（非法返回 `false` 而不抛——与 #23.23 同判据、不同出口，两档都有断言）
/// - Note: hutool 对位 `static boolean isMaskValid(String)`
pub fn mask_is_valid(mask : String) -> Bool {
  mask_bit_of(mask) is Some(_)
}

///|
/// #23.29 掩码位是否合法
/// - Raises: 无
/// - Note: hutool 对位 `static boolean isMaskBitValid(int)`；定义域 1..32，`0` 不合法（参照表没有这一档）
pub fn mask_bit_is_valid(mask_bit : Int) -> Bool {
  mask_long(mask_bit) is Some(_)
}

///|
fn const_ip(text : String) -> Int64 {
  match ipv4_to_long_ok(text) {
    Some(v) => v
    None =>
      abort(
        "typex：内部 IP 字面量非法（这些串由 IIIP 档覆盖，不可达）",
      )
  }
}

///|
/// #23.30 是否内网地址
/// - Raises: `BadIp`（非法 IP 在这里**抛**，而 #23.31 不抛——同包两副面孔，spec §10.3 第 9/10 条）
/// - Note: hutool 对位 `static boolean isInnerIP(String)`：A `10.0.0.0—10.255.255.255`、
///   B `172.16.0.0—172.31.255.255`、C `192.168.0.0—192.168.255.255`，
///   环回那一档是**字面串比较** ⇒ `127.0.0.1` 真而 `127.0.0.2`、`127.255.255.255` 假。
///   三个边界区间不抄数、由 `const_ip` 现算，避免手抄十进制出错。
pub fn ipv4_is_inner(ip : String) -> Bool raise Ipv4Error {
  let n = ipv4_to_long(ip)
  let in_a = n >= const_ip("10.0.0.0") && n <= const_ip("10.255.255.255")
  let in_b = n >= const_ip("172.16.0.0") && n <= const_ip("172.31.255.255")
  let in_c = n >= const_ip("192.168.0.0") && n <= const_ip("192.168.255.255")
  in_a || in_b || in_c || ip == "127.0.0.1"
}

///|
/// #23.31 通配匹配
/// - Returns: IP 非法 ⇒ `false`（**不抛**）；`*` 只当**整段**通配；段内是字符串相等
///   （`1.2.3.4` 不匹配 `01.2.3.4`）；段数不等 ⇒ `false`
/// - Raises: 无
/// - Note: hutool 对位 `static boolean matches(String wildcard, String ip)`
pub fn ipv4_matches(wildcard : String, ip : String) -> Bool {
  if ipv4_to_long_ok(ip) is None {
    return false
  }
  let ws = ipv4_octet_text(wildcard)
  let os = ipv4_octet_text(ip)
  if ws.length() != os.length() {
    return false
  }
  let mut i = 0
  while i < ws.length() {
    if ws[i] != "*" && ws[i] != os[i] {
      return false
    }
    i = i + 1
  }
  true
}

///|
/// #23.32 拼成 `ip/掩码位`
/// - Raises: `BadMask`——**不校验 IP**（参照就是 `ip + "/" + getMaskBitByMask(mask)`，
///   腿读数 `"bad ip"` → `"bad ip/24"`）
/// - Note: hutool 对位 `static String formatIpBlock(String, String)`
pub fn ipv4_format_block(ip : String, mask : String) -> String raise Ipv4Error {
  ip + "/" + mask_bit_by_mask(mask).to_string()
}
