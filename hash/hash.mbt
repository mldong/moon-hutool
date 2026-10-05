///|
/// moon-hutool 的 `hash` —— 非密码学哈希与校验和（hutool `HashUtil` + `lang.hash.*` + `io.checksum.*` 的 MoonBit 对位·第一批）。
///
/// 契约：`docs/spec/17-hash.md`；进度：`docs/ROADMAP.md`。这一批**只有签名与冻结期望值，还没写实现**
/// （状态＝契约已冻结），用例按设计态落库；落地那一笔只许把红变绿（门禁 G5）。
///
/// 三条贯穿性规则（都来自参照腿与本机读数，不是设计偏好）：
/// 1. **与参照实现同值优先于"更正确"**。参照的 CRC8 不是标准 CRC-8（实测 `crc8.digits.7_0|2`，
///    标准式给 244），本库照参照——同名函数在两个库给同一个数，才是这个包的存在理由。分岔两侧读数记在 spec §5。
/// 2. **公开面一律有符号 `Int` / `Int64`**，与参照腿的十进制读数逐字同形；32 位环路内部走 `UInt`
///   （`digest` 包同一条口径），出口再转回有符号。
/// 3. **位置陷阱摆进名字里**：参照的 `hash32(data, length, seed)` 与 `hash32(data, offset, length, seed)`
///   只差一个位置、同名重载看不出，本库分成 `murmur32_len_seed` 与 `murmur32_range`（spec §3 第 8 条）。

///|
/// `additive_hash`/`rotating_hash` 的第二参是**模数**；参照实现在此处 `% prime`，`prime == 0` 时直接除零。
/// 本库把它换成可枚举、可断言的一档错误。
pub suberror HashError {
  ZeroPrime
}

///|
/// CRC16 的十个变体，对位参照实现 `cn.hutool.core.io.checksum.crc16` 下的十个类。
///
/// 每档钉两件事：`reset` 的初值与多项式（有的还带最终异或），逐个由参照腿读数钉住（spec §3 第 15 条）。
/// 本库无参构造那档默认是 `Ibm`（读数 `crc16.default_is_ibm`）。
pub(all) enum Crc16Variant {
  Ansi
  Ccitt
  CcittFalse
  Dnp
  Ibm
  Maxim
  Modbus
  Usb
  X25
  XModem
}

///|
/// CRC8 累加器。对位 `cn.hutool.core.io.checksum.CRC8`——它是个**有状态**的 `java.util.zip.Checksum` 实现，
/// 不是一次性函数，所以本库同样给记录 + `update`/`value`/`reset` 的形状。
///
/// - Note: 参照实现的表构造是 `remainder = dividend`（没有 `<< 8`），因此**不是**标准 CRC-8；
///   本库照抄，理由见包头第 1 条与 spec §5 第 3 行。
pub struct Crc8 {
  polynomial : Int
  init : Int
  value : Int
  table : Array[Int]
}

///|
/// CRC16 累加器。对位 `CRC16` 包装器 + 抽象基类 `CRC16Checksum`。
pub struct Crc16 {
  variant : Crc16Variant
  value : Int
}

///|
/// 建 CRC8 累加器。
///
/// - Parameters:
///   - `polynomial` 生成多项式（参照实现按低→高逐位右移构造表）
///   - `init` 初始值，同时是 `crc8_reset` 回到的值
pub fn new_crc8(polynomial : Int, init : Int) -> Crc8 {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 建 CRC16 累加器；初值由变体决定（对位各变体类里的 `reset`）。
pub fn new_crc16(variant : Crc16Variant) -> Crc16 {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 累加整段字节。对位 `update(byte[])`。
pub fn Crc8::crc8_update(self : Crc8, data : Bytes) -> Unit {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 累加 `data` 的 `[offset, offset + length)` 区间。对位 `update(byte[], int, int)`。
pub fn Crc8::crc8_update_range(
  self : Crc8,
  data : Bytes,
  offset : Int,
  length : Int,
) -> Unit {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 累加单个字节；参照实现取的是 `int` 的低 8 位（`update(int)` 走的是 `new byte[]{(byte)b}`）。
pub fn Crc8::crc8_update_byte(self : Crc8, b : Int) -> Unit {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 当前校验值，出口是 `value & 0xff`（8 位，恒在 0..255）。
pub fn Crc8::crc8_value(self : Crc8) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 回到构造时的 `init`。
pub fn Crc8::crc8_reset(self : Crc8) -> Unit {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 累加整段字节。对位 `CRC16Checksum.update(byte[])`。
pub fn Crc16::crc16_update(self : Crc16, data : Bytes) -> Unit {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 累加 `data` 的 `[offset, offset + length)` 区间。
pub fn Crc16::crc16_update_range(
  self : Crc16,
  data : Bytes,
  offset : Int,
  length : Int,
) -> Unit {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 累加单个字节（低 8 位有效）。
pub fn Crc16::crc16_update_byte(self : Crc16, b : Int) -> Unit {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 当前校验值 = `wCRCin` 全值（可达 65535，与 CRC8 的 8 位出口不同）。
pub fn Crc16::crc16_value(self : Crc16) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 回到本变体的初值（各变体不同：`Ibm`/`Modbus`/`Ansi` 是 `0xffff`，`Ccitt` 是 `0x0000`…）。
pub fn Crc16::crc16_reset(self : Crc16) -> Unit {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 十六进制文本。对位 `getHexValue()` / `getHexValue(boolean)`。
///
/// - Parameters: `padding` 为 `true` 时补零到 4 位（参照侧 `StrUtil.padPre(hex, 4, '0')`）；
///   为 `false` 时不补——参照侧**无参那个默认是不补**，本库把这个选择摆进参数名。
pub fn Crc16::crc16_hex_value(self : Crc16, padding : Bool) -> String {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 加法哈希：逐字符累乘后 `(h & 0x7FFFFFFF) % prime`。
///
/// - Parameters: `prime` 是模数。`prime == 0` 时 `raise HashError::ZeroPrime`
///   （参照侧是 `ArithmeticException: / by zero`）；负数照常算，Java 的 `%` 保留符号。
pub fn additive_hash(text : String, prime : Int) -> Int raise HashError {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 旋转哈希：`h = (h ^ c) + (h << 3)` 逐字符，末尾同样 `% prime`。
///
/// - Parameters: `prime` 是模数，`0` 那档 `raise HashError::ZeroPrime`。
pub fn rotating_hash(text : String, prime : Int) -> Int raise HashError {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 逐字符 `h = h * 65599 + c`。
pub fn one_by_one_hash(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// Bernstein（`h = 5381 * h + c`，初值 5381）。
pub fn bernstein(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 改进的 32 位 FNV，**按 UTF-16 码元**遍历（参照侧用 `charAt`）。
///
/// - Note: 末尾有一段 `<<13 / >>7 / <<3 / >>17 / <<5` 的搅拌，再取 `Math.abs`；
///   而 `abs(Integer.MIN_VALUE)` 仍是负数 ⇒ **返回值可以为负**（spec §3 第 4 条）。
///   与 `fnv_hash_bytes` 只在纯 ASCII 上同值，非 ASCII 必分岔。
pub fn fnv_hash(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 同上，但**按字节**遍历，且对每个字节做符号扩展 XOR（参照侧 `hash ^ b`，`b` 是 Java 有符号 `byte`）。
pub fn fnv_hash_bytes(data : Bytes) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// Thomas Wang 的整数哈希（用 `>>>` 逻辑右移，与 FNV 那档的算术右移不同）。
pub fn int_hash(key : Int) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// RS 算法：`h = (h << 5) - h + c`，并维护一个递增的 `a`。
pub fn rs_hash(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// JS 算法：`h ^= h << 5; h += c; h ^= h >> 2`（这里的 `>>` 是参照侧的移位方向，逐字照搬）。
pub fn js_hash(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// PJW 算法（各 4 位分组移位异或，末尾按溢出位补异或）。
pub fn pjw_hash(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// ELF 算法（`h = (h << 4) + c`，高位溢出那 24 位折回来）。
pub fn elf_hash(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// BKDR 算法（种子 131，末尾 `hash & 0x7FFFFFFF`）。
pub fn bkdr_hash(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// SDBM 算法：`h = c + (h << 6) + (h << 16) - h`。
pub fn sdbm_hash(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// DJB 算法（初值 5381，`h = (h << 5) + h + c`）。
pub fn djb_hash(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// DEK 算法（`h = (h << 5) ^ (h >> 2) ^ c`）。
pub fn dek_hash(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// AP 算法：偶数位与奇数位走两套异或/移位。
pub fn ap_hash(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 田磊算法：长度 `<= 256` 与 `> 256` 是两条分支，空串直接给 0。
pub fn tianl_hash(text : String) -> Int64 {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// `String.hashCode` 的 31 进制展开（与参照实现逐字符同式）。
pub fn java_default_hash(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// 混合哈希：`java_default_hash(text) << 32 | fnv_hash(text)`，输出 64 位。
pub fn mix_hash(text : String) -> Int64 {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// HF 算法：`sum(charAt(i) * 3 * i)`，负则取绝对值。
///
/// - Note: 这条与"哈希质量"无关，是参照家族里的历史件；本库照实现对拍值，不承诺分布性（spec §3 第 16 条）。
pub fn hf_hash(text : String) -> Int64 {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// HFIP 算法：`sum(charAt(i % 4) ^ charAt(i))`。
pub fn hf_ip_hash(text : String) -> Int64 {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// Murmur3 32 位，输入是文本——参照实现先按 **UTF-8** 编码再走字节档（类内 `DEFAULT_CHARSET`）。
pub fn murmur32(text : String) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// Murmur3 32 位，整段字节，默认 `seed = 0`、小端取字（`DEFAULT_ORDER`）。
pub fn murmur32_bytes(data : Bytes) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// Murmur3 32 位的 `(length, seed)` 档——对位参照的 `hash32(byte[], int length, int seed)`。
///
/// - Parameters: `length` 是**参与哈希的字节数**（从下标 0 起算），`seed` 是种子。
/// - Note: 参照侧这个重载与 `murmur32_range` 只差一个参数位置、名字相同，本库分名把陷阱摆出来。
pub fn murmur32_len_seed(data : Bytes, length : Int, seed : Int) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// Murmur3 32 位的 `(offset, length, seed)` 档——对位 `hash32(byte[], int offset, int length, int seed)`。
///
/// - Note: 必须与"先把 `[offset, offset+length)` 切出来再哈希"同值（实测成立，读数 `mmr.hash32.slice_eq`）。
pub fn murmur32_range(
  data : Bytes,
  offset : Int,
  length : Int,
  seed : Int,
) -> Int {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// Murmur3 64 位，输入是文本（UTF-8 编码后走字节档）。
pub fn murmur64(text : String) -> Int64 {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// Murmur3 64 位，整段字节。
pub fn murmur64_bytes(data : Bytes) -> Int64 {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}

///|
/// Murmur3 64 位的 `(length, seed)` 档。
///
/// - Note: **64 位没有 offset 档**——参照侧只有三个重载（`javap` 现读），本库不替它补。
pub fn murmur64_len_seed(data : Bytes, length : Int, seed : Int) -> Int64 {
  abort("moon-hutool hash: 契约已冻结，实现待落地")
}
