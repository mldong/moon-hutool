///|
/// moon-hutool 的 `hash` —— 非密码学哈希与校验和（hutool `HashUtil` + `lang.hash.*` + `io.checksum.*` 的 MoonBit 对位·第一批）。
///
/// 契约：`docs/spec/17-hash.md`；进度：`docs/ROADMAP.md`。这一批 41 件函数已落地（契约笔 `56c1077` 冻期望值、
/// 文字更正笔 `c9b5c6d` 逐条对过参照源码，落地笔只填体子；每条期望值都与参照腿 398 条读数同形，门禁 G5 对读落地笔）。
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
  mut value : Int
  table : Array[Int]
}

///|
/// CRC16 累加器。对位 `CRC16` 包装器 + 抽象基类 `CRC16Checksum`。
pub struct Crc16 {
  variant : Crc16Variant
  mut value : Int
}

///|
/// 建 CRC8 累加器。
///
/// - Parameters:
///   - `polynomial` 生成多项式（参照实现按低→高逐位右移构造表）
///   - `init` 初始值，同时是 `crc8_reset` 回到的值
pub fn new_crc8(polynomial : Int, init : Int) -> Crc8 {
  let table : Array[Int] = []
  for d in 0..<256 {
    let mut r = d
    for _ in 0..<8 {
      r = if (r & 0x01) != 0 { lshr32(r, 1) ^ polynomial } else { lshr32(r, 1) }
    }
    table.push(r & 0xffff)
  }
  Crc8::{ polynomial, init, value: init, table, }
}

///|
/// 建 CRC16 累加器；初值由变体决定（对位各变体类里的 `reset`）。
pub fn new_crc16(variant : Crc16Variant) -> Crc16 {
  Crc16::{ variant, value: crc16_init(variant), }
}

///|
/// 累加整段字节。对位 `update(byte[])`。
pub fn Crc8::crc8_update(self : Crc8, data : Bytes) -> Unit {
  self.crc8_update_range(data, 0, data.length())
}

///|
/// 累加 `data` 的 `[offset, offset + length)` 区间。对位 `update(byte[], int, int)`。
pub fn Crc8::crc8_update_range(
  self : Crc8,
  data : Bytes,
  offset : Int,
  length : Int,
) -> Unit {
  let mut v = self.value
  let mut i = 0
  while i < length {
    let b = data[offset + i].to_int()
    let idx = (b ^ v) & 0xff
    v = (self.table[idx] ^ ((v << 8) & 0xffff)) & 0xffff
    i = i + 1
  }
  self.value = v
}

///|
/// 累加单个字节；参照实现取的是 `int` 的低 8 位（`update(int)` 走的是 `new byte[]{(byte)b}`）。
pub fn Crc8::crc8_update_byte(self : Crc8, b : Int) -> Unit {
  self.crc8_update_range(Bytes::from_array([b.to_byte()]), 0, 1)
}

///|
/// 当前校验值，出口是 `value & 0xff`（8 位，恒在 0..255）。
pub fn Crc8::crc8_value(self : Crc8) -> Int {
  self.value & 0xff
}

///|
/// 回到构造时的 `init`。
pub fn Crc8::crc8_reset(self : Crc8) -> Unit {
  self.value = self.init
}

///|
/// 累加整段字节。对位 `CRC16Checksum.update(byte[])`。
pub fn Crc16::crc16_update(self : Crc16, data : Bytes) -> Unit {
  self.crc16_update_range(data, 0, data.length())
}

///|
/// 累加 `data` 的 `[offset, offset + length)` 区间。
pub fn Crc16::crc16_update_range(
  self : Crc16,
  data : Bytes,
  offset : Int,
  length : Int,
) -> Unit {
  let mut v = self.value
  let mut i = 0
  while i < length {
    v = crc16_step(self.variant, v, sbyte(data[offset + i].to_int()))
    i = i + 1
  }
  self.value = crc16_array_tail(self.variant, v)
}

///|
/// 累加单个字节（低 8 位有效）。
pub fn Crc16::crc16_update_byte(self : Crc16, b : Int) -> Unit {
  self.value = crc16_step(self.variant, self.value, b)
}

///|
/// 当前校验值 = `wCRCin` 全值（可达 65535，与 CRC8 的 8 位出口不同）。
pub fn Crc16::crc16_value(self : Crc16) -> Int {
  self.value
}

///|
/// 回到本变体的初值（各变体不同：`Ibm`/`Modbus`/`Ansi` 是 `0xffff`，`Ccitt` 是 `0x0000`…）。
pub fn Crc16::crc16_reset(self : Crc16) -> Unit {
  self.value = crc16_init(self.variant)
}

///|
/// 十六进制文本。对位 `getHexValue()` / `getHexValue(boolean)`。
///
/// - Parameters: `padding` 为 `true` 时补零到 4 位（参照侧 `StrUtil.padPre(hex, 4, '0')`）；
///   为 `false` 时不补——参照侧**无参那个默认是不补**，本库把这个选择摆进参数名。
pub fn Crc16::crc16_hex_value(self : Crc16, padding : Bool) -> String {
  hex_of_u16(self.crc16_value(), padding)
}

///|
/// 加法哈希：初值是**串长**，逐字符相加，末尾直接 `% prime`（参照侧没有 `& 0x7FFFFFFF` 这一步）。
///
/// - Parameters: `prime` 是模数。`prime == 0` 时 `raise HashError::ZeroPrime`
///   （参照侧是 `ArithmeticException: / by zero`）；负数照常算，Java 的 `%` 保留符号。
pub fn additive_hash(text : String, prime : Int) -> Int raise HashError {
  if prime == 0 {
    raise HashError::ZeroPrime
  }
  let mut h = text.length()
  for c in utf16_codes(text) {
    h = add3(h, c)
  }
  java_mod(h, prime)
}

///|
/// 旋转哈希：初值是**串长**，逐字符 `h = (h << 4) ^ (h >> 28) ^ c`，末尾同样 `% prime`。
///
/// - Parameters: `prime` 是模数，`0` 那档 `raise HashError::ZeroPrime`。
pub fn rotating_hash(text : String, prime : Int) -> Int raise HashError {
  if prime == 0 {
    raise HashError::ZeroPrime
  }
  let mut h = text.length()
  for c in utf16_codes(text) {
    h = (h << 4) ^ (h >> 28) ^ c
  }
  java_mod(h, prime)
}

///|
/// 逐字符三拍：`h += c; h += h << 10; h ^= h >> 6`，收尾再来 `h += h << 3; h ^= h >> 11; h += h << 15`。
pub fn one_by_one_hash(text : String) -> Int {
  let mut h = 0
  for c in utf16_codes(text) {
    h = add3(h, c)
    h = add3(h, h << 10)
    h = h ^ (h >> 6)
  }
  h = add3(h, h << 3)
  h = h ^ (h >> 11)
  add3(h, h << 15)
}

///|
/// Bernstein（`h = 33 * h + c`，初值 **0**——5381 那档是 `djb_hash`，两件别混）。
pub fn bernstein(text : String) -> Int {
  let mut h = 0
  for c in utf16_codes(text) {
    h = add3(mul3(33, h), c)
  }
  h
}

///|
/// 改进的 32 位 FNV，**按 UTF-16 码元**遍历（参照侧用 `charAt`），基底 `(int)2166136261`、乘子 `16777619`。
///
/// - Note: 末尾有一段 `<<13 / >>7 / <<3 / >>17 / <<5` 的搅拌，再取 `Math.abs`；
///   而 `abs(Integer.MIN_VALUE)` 仍是负数 ⇒ **返回值可以为负**（spec §3 第 4 条）。
///   与 `fnv_hash_bytes` 只在纯 ASCII 上同值，非 ASCII 必分岔。
pub fn fnv_hash(text : String) -> Int {
  let mut h = -2128831035
  for c in utf16_codes(text) {
    h = mul3(h ^ c, 16777619)
  }
  fnv_mixer(h)
}

///|
/// 同上，但**按字节**遍历，且对每个字节做符号扩展 XOR（参照侧 `hash ^ b`，`b` 是 Java 有符号 `byte`）；
/// 两档的末尾搅拌完全一致：`h += h<<13; h ^= h>>7; h += h<<3; h ^= h>>17; h += h<<5` 再取 `Math.abs`。
pub fn fnv_hash_bytes(data : Bytes) -> Int {
  let mut h = -2128831035
  let n = data.length()
  let mut i = 0
  while i < n {
    h = mul3(h ^ sbyte(data[i].to_int()), 16777619)
    i = i + 1
  }
  fnv_mixer(h)
}

///|
/// Thomas Wang 的整数哈希（用 `>>>` 逻辑右移，与 FNV 那档的算术右移不同）。
pub fn int_hash(key : Int) -> Int {
  let mut k = key
  k = add3(k, not32(shl32(k, 15)))
  k = k ^ lshr32(k, 10)
  k = add3(k, shl32(k, 3))
  k = k ^ lshr32(k, 6)
  k = add3(k, not32(shl32(k, 11)))
  k ^ lshr32(k, 16)
}

///|
/// RS 算法：`h = h * a + c`，同时 `a = a * 378551`（`a` 初值 63689），出口 `& 0x7FFFFFFF`。
pub fn rs_hash(text : String) -> Int {
  let mut h = 0
  let mut a = 63689
  for c in utf16_codes(text) {
    h = add3(mul3(h, a), c)
    a = mul3(a, 378551)
  }
  h & 0x7fffffff
}

///|
/// JS 算法：`h ^= (h << 5) + c + (h >> 2)`（`>>` 是算术右移，逐字照搬），出口 `Math.abs(h) & 0x7FFFFFFF`。
pub fn js_hash(text : String) -> Int {
  let mut h = 1315423911
  for c in utf16_codes(text) {
    h = h ^ add3(add3(h << 5, c), h >> 2)
  }
  abs32(h) & 0x7fffffff
}

///|
/// PJW 算法：`h = (h << 4) + c`，命中高 4 位（`0xF0000000`）时折回 `test >> 24` 并清掉高位，出口 `& 0x7FFFFFFF`。
pub fn pjw_hash(text : String) -> Int {
  let mut h = 0
  for c in utf16_codes(text) {
    h = add3(h << 4, c)
    let hi4 = h & 0xf0000000
    if hi4 != 0 {
      h = (h ^ (hi4 >> 24)) & 0x0fffffff
    }
  }
  h & 0x7fffffff
}

///|
/// ELF 算法：`h = (h << 4) + c`，`x = h & 0xF0000000` 非零时 `h ^= x >> 24; h &= ~x`，出口 `& 0x7FFFFFFF`。
pub fn elf_hash(text : String) -> Int {
  let mut h = 0
  for c in utf16_codes(text) {
    h = add3(h << 4, c)
    let x = h & 0xf0000000
    if x != 0 {
      h = h ^ (x >> 24)
      h = h & not32(x)
    }
  }
  h & 0x7fffffff
}

///|
/// BKDR 算法：`h = h * 131 + c`，出口 `& 0x7FFFFFFF`。
pub fn bkdr_hash(text : String) -> Int {
  let mut h = 0
  for c in utf16_codes(text) {
    h = add3(mul3(h, 131), c)
  }
  h & 0x7fffffff
}

///|
/// SDBM 算法：`h = c + (h << 6) + (h << 16) - h`，出口 `& 0x7FFFFFFF`（参照侧这条**有**掩码）。
pub fn sdbm_hash(text : String) -> Int {
  let mut h = 0
  for c in utf16_codes(text) {
    h = sub3(add3(c, add3(h << 6, h << 16)), h)
  }
  h & 0x7fffffff
}

///|
/// DJB 算法：初值 5381，`h = (h << 5) + h + c`，出口 `& 0x7FFFFFFF`。
pub fn djb_hash(text : String) -> Int {
  let mut h = 5381
  for c in utf16_codes(text) {
    h = add3(add3(h << 5, h), c)
  }
  h & 0x7fffffff
}

///|
/// DEK 算法：初值是**串长**，`h = (h << 5) ^ (h >> 27) ^ c`，出口 `& 0x7FFFFFFF`。
pub fn dek_hash(text : String) -> Int {
  let mut h = text.length()
  for c in utf16_codes(text) {
    h = (h << 5) ^ (h >> 27) ^ c
  }
  h & 0x7fffffff
}

///|
/// AP 算法：偶数下标 `h ^= (h << 7) ^ c ^ (h >> 3)`，奇数下标 `h ^= ~((h << 11) ^ c ^ (h >> 5))`，出口**不掩码**。
pub fn ap_hash(text : String) -> Int {
  let mut h = 0
  let mut i = 0
  for c in utf16_codes(text) {
    h = if (i & 1) == 0 {
      h ^ ((h << 7) ^ c ^ (h >> 3))
    } else {
      h ^ not32((h << 11) ^ c ^ (h >> 5))
    }
    i = i + 1
  }
  h
}

///|
/// 田磊算法：空串给 0；基底按长度 `<= 256` 与 `> 256` 分两档；**字符扫描只看最多 96 个**——
/// 串长 `<= 96` 从头扫，`> 96` 只扫**尾部** 96 个（参照侧 `str.charAt(i + iLength - 96 - 1)`），
/// 期间把 `A`–`Z` 折成小写，每步按 `(3*i*c*c + 5*i*c + 7*i + 11*c) % 16777216` 累加，末了负数取绝对值。
pub fn tianl_hash(text : String) -> Int64 {
  let n = text.length()
  if n == 0 {
    0L
  } else {
    let mut hash = if n <= 256 {
      16777216L * (n - 1).to_int64()
    } else {
      4278190080L
    }
    let chars = utf16_codes(text)
    let take_tail = n > 96
    let lo = if take_tail { n - 96 } else { 0 }
    let stop = if take_tail { 96 } else { n }
    let mut i = 1
    while i <= stop {
      let mut uc = chars[i + lo - 1]
      if uc >= 65 && uc <= 90 {
        uc = uc + 32
      }
      let uci = uc.to_int64()
      let ii = i.to_int64()
      let term = (3L * ii * uci * uci + 5L * ii * uci + 7L * ii + 11L * uci) %
        16777216L
      hash = hash + term
      i = i + 1
    }
    if hash < 0L {
      0L - hash
    } else {
      hash
    }
  }
}

///|
/// `String.hashCode` 的 31 进制展开（与参照实现逐字符同式）。
pub fn java_default_hash(text : String) -> Int {
  let mut h = 0
  for c in utf16_codes(text) {
    h = add3(mul3(31, h), c)
  }
  h
}

///|
/// 混合哈希：`java_default_hash(text) << 32 | fnv_hash(text)`，输出 64 位。
pub fn mix_hash(text : String) -> Int64 {
  (java_default_hash(text).to_int64() << 32) | fnv_hash(text).to_int64()
}

///|
/// HF 算法：`sum(charAt(i) * 3 * i)`，负则取绝对值。
///
/// - Note: 这条与"哈希质量"无关，是参照家族里的历史件；本库照实现对拍值，不承诺分布性（spec §3 第 16 条）。
pub fn hf_hash(text : String) -> Int64 {
  let mut h = 0L
  let mut i = 0
  for c in utf16_codes(text) {
    h = h + 3L * i.to_int64() * c.to_int64()
    i = i + 1
  }
  if h < 0L {
    0L - h
  } else {
    h
  }
}

///|
/// HFIP 算法：`sum(charAt(i % 4) ^ charAt(i))`。
pub fn hf_ip_hash(text : String) -> Int64 {
  let chars = utf16_codes(text)
  let n = chars.length()
  let mut h = 0L
  for i in 0..<n {
    h = h + (chars[i % 4] ^ chars[i]).to_int64()
  }
  h
}

///|
/// Murmur3 32 位，输入是文本——参照实现先按 **UTF-8** 编码再走字节档（类内 `DEFAULT_CHARSET`）。
pub fn murmur32(text : String) -> Int {
  murmur32_bytes(@utf8.encode(text))
}

///|
/// Murmur3 32 位，整段字节，默认 `seed = 0`、小端取字（`DEFAULT_ORDER`）。
pub fn murmur32_bytes(data : Bytes) -> Int {
  murmur32_range(data, 0, data.length(), 0)
}

///|
/// Murmur3 32 位的 `(length, seed)` 档——对位参照的 `hash32(byte[], int length, int seed)`。
///
/// - Parameters: `length` 是**参与哈希的字节数**（从下标 0 起算），`seed` 是种子。
/// - Note: 参照侧这个重载与 `murmur32_range` 只差一个参数位置、名字相同，本库分名把陷阱摆出来。
pub fn murmur32_len_seed(data : Bytes, length : Int, seed : Int) -> Int {
  murmur32_range(data, 0, length, seed)
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
  let mut h : UInt = seed.reinterpret_as_uint()
  let nblocks = length >> 2
  for i in 0..<nblocks {
    h = mix32(read_u32le(data, offset + i * 4), h)
  }
  let idx = offset + nblocks * 4
  let rem = length - nblocks * 4
  if rem > 0 {
    let mut k1 : UInt = 0
    if rem >= 3 {
      k1 = k1 | ((data[idx + 2].to_int() & 0xff).reinterpret_as_uint() << 16)
    }
    if rem >= 2 {
      k1 = k1 | ((data[idx + 1].to_int() & 0xff).reinterpret_as_uint() << 8)
    }
    k1 = k1 | (data[idx].to_int() & 0xff).reinterpret_as_uint()
    k1 = k1 * c1_32
    k1 = rotl32(k1, 15)
    k1 = k1 * c2_32
    h = h ^ k1
  }
  h = h ^ length.reinterpret_as_uint()
  fmix32(h).reinterpret_as_int()
}

///|
/// Murmur3 64 位，输入是文本（UTF-8 编码后走字节档）。
pub fn murmur64(text : String) -> Int64 {
  murmur64_bytes(@utf8.encode(text))
}

///|
/// Murmur3 64 位，整段字节。
pub fn murmur64_bytes(data : Bytes) -> Int64 {
  murmur64_len_seed(data, data.length(), 0)
}

///|
/// Murmur3 64 位的 `(length, seed)` 档。
///
/// - Note: **64 位没有 offset 档**——参照侧只有三个重载（`javap` 现读），本库不替它补。
pub fn murmur64_len_seed(data : Bytes, length : Int, seed : Int) -> Int64 {
  let mut h : UInt64 = seed.to_int64().reinterpret_as_uint64()
  let nblocks = length >> 3
  for i in 0..<nblocks {
    let mut k = read_u64le(data, i * 8)
    k = k * c1_64
    k = rotl64(k, 31)
    k = k * c2_64
    h = h ^ k
    h = rotl64(h, 27) * five_64 + n1_64
  }
  let tail_start = nblocks * 8
  let rem = length - tail_start
  if rem > 0 {
    let mut k1 : UInt64 = 0
    let mut sh = rem - 1
    while sh >= 0 {
      k1 = (k1 << 8) |
        (data[tail_start + sh].to_int().to_int64() & 0xffL).reinterpret_as_uint64()
      sh = sh - 1
    }
    k1 = k1 * c1_64
    k1 = rotl64(k1, 31)
    k1 = k1 * c2_64
    h = h ^ k1
  }
  h = h ^ length.to_int64().reinterpret_as_uint64()
  fmix64(h).reinterpret_as_int64()
}

///|
/// 32 位环路的加减乘走 `UInt`（与 `digest` 同一条口径），出口用 `reinterpret_as_int` 回到有符号，
/// 这样每条断言的右侧都能与参照腿的十进制读数逐字同形。
/// `^`/`&`/`<<`/`>>` 保持参照侧原样——Java 那些位置全是有符号 int，`>>` 是算术右移，
/// 只有 `int_hash` 与 murmur 的 `>>>` 才是逻辑右移（`lshr32`）。
fn add3(a : Int, b : Int) -> Int {
  (a.reinterpret_as_uint() + b.reinterpret_as_uint()).reinterpret_as_int()
}

///|
fn sub3(a : Int, b : Int) -> Int {
  (a.reinterpret_as_uint() - b.reinterpret_as_uint()).reinterpret_as_int()
}

///|
fn mul3(a : Int, b : Int) -> Int {
  (a.reinterpret_as_uint() * b.reinterpret_as_uint()).reinterpret_as_int()
}

///|
fn not32(a : Int) -> Int {
  (a.reinterpret_as_uint() ^ ff_mask).reinterpret_as_int()
}

///|
fn shl32(a : Int, n : Int) -> Int {
  (a.reinterpret_as_uint() << n).reinterpret_as_int()
}

///|
fn lshr32(a : Int, n : Int) -> Int {
  (a.reinterpret_as_uint() >> n).reinterpret_as_int()
}

///|
/// Java 的 `%`：余数符号跟被除数（`/` 向零截断），所以负数档不能套 MoonBit 的 `mod`。
fn java_mod(a : Int, b : Int) -> Int {
  a - a / b * b
}

///|
fn abs32(a : Int) -> Int {
  if a >= 0 || a == -2147483648 {
    a
  } else {
    0 - a
  }
}

///|
fn fnv_mixer(h0 : Int) -> Int {
  let mut h = h0
  h = add3(h, h << 13)
  h = h ^ (h >> 7)
  h = add3(h, h << 3)
  h = h ^ (h >> 17)
  abs32(add3(h, h << 5))
}

///|
fn rotl32(v : UInt, c : Int) -> UInt {
  (v << c) | (v >> (32 - c))
}

///|
fn mix32(k0 : UInt, h0 : UInt) -> UInt {
  let mut k = k0 * c1_32
  k = rotl32(k, 15)
  k = k * c2_32
  let h = h0 ^ k
  rotl32(h, 13) * m_32 + n_32
}

///|
fn fmix32(h0 : UInt) -> UInt {
  let mut h = h0 ^ (h0 >> 16)
  h = h * f1_32
  h = h ^ (h >> 13)
  h = h * f2_32
  h ^ (h >> 16)
}

///|
fn rotl64(v : UInt64, c : Int) -> UInt64 {
  (v << c) | (v >> (64 - c))
}

///|
fn fmix64(h0 : UInt64) -> UInt64 {
  let mut h = h0 ^ (h0 >> 33)
  h = h * d33_a
  h = h ^ (h >> 33)
  h = h * d33_b
  h ^ (h >> 33)
}

///|
/// Java 的 `charAt` 走 UTF-16 码元，而 MoonBit 的 `Char` 是码位 —— 代理对必须展开成两个码元，
/// 否则 `one_by_one_hash("emoji+abc")` 这类会比参照侧少算一步。
fn utf16_codes(text : String) -> Array[Int] {
  let out : Array[Int] = []
  for c in text.to_array() {
    let v = c.to_int()
    if v < 0x10000 {
      out.push(v)
    } else {
      let u = v - 0x10000
      out.push(0xd800 + (u >> 10))
      out.push(0xdc00 + (u & 0x3ff))
    }
  }
  out
}

///|
/// 参照侧 `byte` 是有符号的（0xff 进来是 -1），异或前必须符号扩展。
fn sbyte(v : Int) -> Int {
  if v > 127 {
    v - 256
  } else {
    v
  }
}

///|
fn read_u32le(data : Bytes, off : Int) -> UInt {
  let b0 = (data[off].to_int() & 0xff).reinterpret_as_uint()
  let b1 = (data[off + 1].to_int() & 0xff).reinterpret_as_uint()
  let b2 = (data[off + 2].to_int() & 0xff).reinterpret_as_uint()
  let b3 = (data[off + 3].to_int() & 0xff).reinterpret_as_uint()
  b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
}

///|
fn read_u64le(data : Bytes, off : Int) -> UInt64 {
  let mut v : UInt64 = 0
  let mut i = 7
  while i >= 0 {
    v = (v << 8) |
      (data[off + i].to_int().to_int64() & 0xffL).reinterpret_as_uint64()
    i = i - 1
  }
  v
}

///|
fn crc16_init(v : Crc16Variant) -> Int {
  match v {
    Ansi => 0xffff
    Ccitt => 0
    CcittFalse => 0xffff
    Dnp => 0
    Ibm => 0
    Maxim => 0
    Modbus => 0xffff
    Usb => 0xffff
    X25 => 0xffff
    XModem => 0
  }
}

///|
fn crc16_poly(v : Crc16Variant) -> Int {
  match v {
    Ansi | Ibm | Maxim | Modbus | Usb => 0xa001
    Ccitt | X25 => 0x8408
    CcittFalse | XModem => 0x1021
    Dnp => 0xa6bc
  }
}

///|
fn crc16_step(v : Crc16Variant, crc_in : Int, b : Int) -> Int {
  let poly = crc16_poly(v)
  match v {
    Ansi => {
      let mut w = (crc_in >> 8) ^ b
      for _ in 0..<8 {
        let flag = w & 0x1
        w = w >> 1
        if flag == 1 {
          w = w ^ poly
        }
      }
      w
    }
    CcittFalse | XModem => {
      let mut w = crc_in
      for i in 0..<8 {
        let bit = ((b >> (7 - i)) & 1) == 1
        let c15 = ((w >> 15) & 1) == 1
        w = w << 1
        if bit != c15 {
          w = w ^ poly
        }
      }
      w
    }
    _ => {
      let mut w = crc_in ^ (b & 0xff)
      for _ in 0..<8 {
        w = if (w & 0x1) != 0 { (w >> 1) ^ poly } else { w >> 1 }
      }
      w
    }
  }
}

///|
/// 参照侧把"最终异或/掩码"挂在 `update(byte[], off, len)` 上而不是 `update(int)` 上，
/// 于是逐字节喂与整段喂不同值——这份差异原样留在两个入口里（读数 `crc16.single_int.*` 对 `crc16.digits.*`）。
fn crc16_array_tail(v : Crc16Variant, crc_in : Int) -> Int {
  match v {
    Dnp | Maxim | Usb | X25 => crc_in ^ 0xffff
    CcittFalse | XModem => crc_in & 0xffff
    _ => crc_in
  }
}

///|
/// 对位 `HexUtil.toHex(...)`（小写、无前缀）+ `StrUtil.padPre(hex, 4, '0')`。
fn hex_of_u16(n : Int, padding : Bool) -> String {
  let digits = "0123456789abcdef".to_array()
  let out : Array[Char] = []
  let mut v = if n < 0 { 0 - n } else { n }
  if v == 0 {
    out.push('0')
  }
  while v > 0 {
    out.push(digits[v % 16])
    v = v / 16
  }
  let mut s = ""
  for c in out.rev() {
    s = s + c.to_string()
  }
  if padding {
    while s.length() < 4 {
      s = "0" + s
    }
  }
  s
}

///|
let c1_32 : UInt = 0xcc9e2d51

///|
let c2_32 : UInt = 0x1b873593

///|
let m_32 : UInt = 5

///|
let n_32 : UInt = 0xe6546b64

///|
let f1_32 : UInt = 0x85ebca6b

///|
let f2_32 : UInt = 0xc2b2ae35

///|
let ff_mask : UInt = 0xffffffff

///|
let c1_64 : UInt64 = 0x87c37b91114253d5

///|
let c2_64 : UInt64 = 0x4cf5ad432745937f

///|
let d33_a : UInt64 = 0xff51afd7ed558ccd

///|
let d33_b : UInt64 = 0xc4ceb9fe1a85ec53

///|
let n1_64 : UInt64 = 0x52dce729

///|
let five_64 : UInt64 = 5
