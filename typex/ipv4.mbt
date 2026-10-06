///|
// moon-hutool/typex —— IPv4 算式面（ROADMAP 第 23 行第二批，续号 #23.15 起）
// 对位 hutool `cn.hutool.core.net.Ipv4Util`（**件在 `core/net` 不在 `core/util`**，
// `unzip -l hutool-core.jar | grep -i ipv4` 现读 `cn/hutool/core/net/Ipv4Util.class`）。
// 本文件此刻是签名骨架——函数体是 abort，落地笔（PR-B）替换。
//
// 一句话口径（三条先说明白，细则全在 `docs/spec/23-typex.md` §10）：
// - **不收 `list(...)` 三件与 `NetUtil` 全系**：参照把 IP 段展开成 `List<String>`（规模可到 2^31，是分配型 API），
//   网卡探测是主机态；两者都在 §1 的边界外。
// - **IP 合法性判据复用 `@valid.is_ipv4`**（三方命中集 33 样本零分歧，普查与阳性对照记在 spec §10.3 第 2 条），
//   本包不再自带第二张 IP 合法性表。
// - 参照的异常档一律换成本包 `Ipv4Error` 的四个变体：`BadIp`（`Invalid IPv4 address!`）、
//   `BadMask`（`Invalid netmask …`）、`BadRange`（`to IP must be greater than from IP!`）、
//   `BadMaskBit`（参照在掩码位非法时把 `null` 喂进正则，实测 `NullPointerException`——那是崩溃形状不是契约）。
//   变体**不带载荷**：出错的输入调用方自己传进来的，"哪一类非法"才是新信息（同 `mapx`/`num` 的不带载荷立场）。

///|
/// #23.15 本包错误面。四个变体各自对应参照腿的一类读数（映射表在 spec §10.5）。
pub suberror Ipv4Error {
  BadIp
  BadMask
  BadMaskBit
  BadRange
}

///|
/// #23.16 long → 点分串。对位 `static String longToIpv4(long)`。
/// - Raises: 无（参照只做四次移位 + `& 0xFF`，任何 `long` 都有值：超 2^32 截高位、负数按补码取低 32 位）
/// - Note: 腿读数含 `4294967296`→`0.0.0.0`、`-1`→`255.255.255.255`、`Long.MIN_VALUE`→`0.0.0.0`
pub fn long_to_ipv4(v : Int64) -> String {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.16")
}

///|
/// #23.17 点分串 → long（别名 inet_aton）。对位 `static long ipv4ToLong(String)`。
/// - Raises: `BadIp`（参照 `IllegalArgumentException("Invalid IPv4 address!")`）
/// - Note: 合法判据是 `@valid.is_ipv4`，**前导零照收**（`01.2.3.4` 合法且与 `1.2.3.4` 同值）、每段最多 3 位
pub fn ipv4_to_long(text : String) -> Int64 raise Ipv4Error {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.17")
}

///|
/// #23.18 点分串 → long，非法给默认值。对位 `static long ipv4ToLong(String, long)`。
/// - Raises: 无（参照这一档先问 `Validator.isIpv4` 再决定，永不抛）
pub fn ipv4_to_long_or(text : String, default : Int64) -> Int64 {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.18")
}

///|
/// #23.19 网段起始 IP（串）。对位 `static String getBeginIpStr(String, int)`
/// - Raises: `BadIp` | `BadMaskBit`（两档同时非法时 `BadIp` 优先——参照算式里左操作数先算，腿有专档）
pub fn ipv4_begin_ip_str(ip : String, mask_bit : Int) -> String raise Ipv4Error {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.19")
}

///|
/// #23.20 网段起始 IP（数值）。对位 `static Long getBeginIpLong(String, int)`
/// - Raises: `BadIp` | `BadMaskBit`
pub fn ipv4_begin_ip_long(ip : String, mask_bit : Int) -> Int64 raise Ipv4Error {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.20")
}

///|
/// #23.21 网段终止 IP（串）。对位 `static String getEndIpStr(String, int)`
/// - Raises: `BadIp` | `BadMaskBit`
pub fn ipv4_end_ip_str(ip : String, mask_bit : Int) -> String raise Ipv4Error {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.21")
}

///|
/// #23.22 网段终止 IP（数值）。对位 `static Long getEndIpLong(String, int)`——参照注释自己写明"此接口返回负数"，
/// 腿在实测档给的都是正数（本库跟随算式，不跟随那句注释）
/// - Raises: `BadIp` | `BadMaskBit`
pub fn ipv4_end_ip_long(ip : String, mask_bit : Int) -> Int64 raise Ipv4Error {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.22")
}

///|
/// #23.23 掩码串 → 掩码位。对位 `static int getMaskBitByMask(String)`
/// - Raises: `BadMask`（参照 `IllegalArgumentException("Invalid netmask " + mask)`；掩码必须是**连续的** 1 前缀，
///   且**位 0 不在参照表内**）
pub fn mask_bit_by_mask(mask : String) -> Int raise Ipv4Error {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.23")
}

///|
/// #23.24 掩码位 → 掩码串。对位 `static String getMaskByMaskBit(int)`（非法位参照给 `null`，本库给 `None`）
/// - Raises: 无
pub fn mask_by_mask_bit(mask_bit : Int) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.24")
}

///|
/// #23.25 子网大小。对位 `static int countByMaskBit(int, boolean)`。
/// - Raises: 无（**非法掩码位不报错**：参照直接 `(int) Math.pow(2, 32 - maskBit)`，
///   越界走 Java 的 double→int **饱和窄化**，`mask_bit ≤ 1` 且 `all=true` 给 `2147483647`、`mask_bit ≥ 33` 给 `0`；
///   `all=false` 时参照先短路 `mask_bit <= 0 || mask_bit >= 32` 给 0）
pub fn count_by_mask_bit(mask_bit : Int, all : Bool) -> Int {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.25")
}

///|
/// #23.26 IP 段 → 掩码串。对位 `static String getMaskByIpRange(String, String)`。
/// - Raises: `BadIp` | `BadRange`（参照是 `Assert.isTrue(from < to)` ⇒ **相等也非法**）
/// - Note: 逐段 `255 - to + from` 拼出来的**不是真 CIDR 掩码**（腿读数有 `255.255.255.249`、`0.0.0.0` 这种形状），
///   本库跟随并原样给出
pub fn mask_by_ip_range(
  from_ip : String,
  to_ip : String,
) -> String raise Ipv4Error {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.26")
}

///|
/// #23.27 IP 段内有多少个 IP。对位 `static int countByIpRange(String, String)`。
/// - Raises: `BadIp` | `BadRange`（与 #23.26 不同：**相等合法且给 1**，只有 `from > to` 才抛）
/// - Note: 参照出口是 `int` 且累加走 `count += delta * Math.pow(256, k)`（复合赋值的隐式窄化）
///   ⇒ 大段**饱和**在 `2147483647`，`0.0.0.0—255.255.255.255` 实测就是这个数
pub fn count_by_ip_range(
  from_ip : String,
  to_ip : String,
) -> Int raise Ipv4Error {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.27")
}

///|
/// #23.28 掩码串是否合法。对位 `static boolean isMaskValid(String)`
/// - Raises: 无（非法返回 false，不抛——与 #23.23 同判据不同出口，两档都钉）
pub fn mask_is_valid(mask : String) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.28")
}

///|
/// #23.29 掩码位是否合法。对位 `static boolean isMaskBitValid(int)`（定义域 1..32，**0 不合法**）
/// - Raises: 无
pub fn mask_bit_is_valid(mask_bit : Int) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.29")
}

///|
/// #23.30 是否内网地址。对位 `static boolean isInnerIP(String)`：A 类 `10.0.0.0—10.255.255.255`、
/// B 类 `172.16.0.0—172.31.255.255`、C 类 `192.168.0.0—192.168.255.255`，**环回只认字面 `127.0.0.1`**
/// （`127.0.0.2` 参照判 false，腿读数如此）
/// - Raises: `BadIp`（非法 IP 在这里**抛**，而 #23.31 不抛——同包两副面孔，都钉住）
pub fn ipv4_is_inner(ip : String) -> Bool raise Ipv4Error {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.30")
}

///|
/// #23.31 通配匹配。对位 `static boolean matches(String wildcard, String ip)`：
/// IP 非法 ⇒ 直接 false（不抛）；`*` **必须占满整段**（`*1.2.3.4` false）；段内是**字符串相等**
/// （`1.2.3.4` 不匹配 `01.2.3.4`）；段数不等 false
/// - Raises: 无
pub fn ipv4_matches(wildcard : String, ip : String) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.31")
}

///|
/// #23.32 拼成 `ip/掩码位` 形式。对位 `static String formatIpBlock(String, String)`。
/// - Raises: `BadMask`（**不校验 IP**：参照就是 `ip + "/" + getMaskBitByMask(mask)`，
///   腿读数 `"bad ip"` → `"bad ip/24"`）
pub fn ipv4_format_block(ip : String, mask : String) -> String raise Ipv4Error {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/23-typex.md #23.32")
}
