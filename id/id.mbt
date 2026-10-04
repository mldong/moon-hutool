///|
/// moon-hutool/id —— ID 生成（hutool `IdUtil` 家族的 MoonBit 对位）
///
/// 契约：`docs/spec/04-id.md`。期望值权威在 `id_test.mbt` 与 spec 表——实现只把红变绿，
/// 改期望值须单独一笔并给外部读数来源（门禁 G5）。
///
/// 三条贯穿性规则（core 与 hutool 在这里给的都不是"能直接搬"的形状，所以口径写死在这里）：
/// 1. **时钟与熵都是参数**：`Snowflake::next(now_millis)`、`ObjectIdGen::next(timestamp_secs)`、
///    `uuid_v4(rand)`、`nano_id(..., rand)` 全部显式注入；只有带 `_random` 后缀的入口才碰
///    `env.now()`/`env.rand()`。hutool 靠 `SystemClock`/`SecureRandom` 这些静态量，照抄的话
///    这些格子永远不可测（期望值会随机器漂）。
/// 2. **不读 PID、不读网卡、不读 ClassLoader**（那三样全要 FFI）：`machine`、`datacenter_id`、
///    `worker_id` 一律由调用方给。hutool 那侧"取不到就随机"，等于静默降级成可能撞号的 ID——
///    本库宁可**不给默认值**。
/// 3. **不自旋、不 sleep**：同毫秒 4096 个序列号用尽后把**逻辑时间戳**推进 1 毫秒继续发号。
///    hutool 的 `tilNextMillis()` 是忙等真实时钟；这里时钟是传进来的纯数据，对着它自旋
///    既无意义也可能永不返回。

///|
/// 本包唯一错误面：只携带**读数**，不携带文案（同 `date` 包的立场——文案不是要冻结的契约）
pub suberror IdError {
  /// (字段名, 读到的值, 上界)
  FieldOutOfRange(String, Int64, Int64)
  /// 时间戳超出 41 位窗口：携带那个时刻
  TimestampOverflow(Int64)
  /// 时钟回拨超过容忍档：携带回拨的毫秒数
  ClockMovedBackwards(Int64)
  /// 注入的随机字节不够：(需要, 实得)
  EntropyTooShort(Int, Int)
  /// `env.rand` 给不出熵（本机实测 wasm-gc 档就是这种）——绝不静默回落固定种子
  NoEntropy
  /// (输入, 实际长度, 期望长度)
  BadLength(String, Int, Int)
  /// (输入, 第一个非法字符的下标)
  BadHex(String, Int)
}

///|
/// 雪花纪年起点（与 hutool `Snowflake.DEFAULT_TWEPOCH`、MyBatis-Plus `IdWorker` **同 ID 空间**）
///
/// 换掉它就不是同一个号段了，所以这条是常量而不是参数；要自定义请走纯函数自己拼位
pub let snowflake_epoch : Int64 = 1288834974657L

///|
/// 数据中心号与 worker 号的上界（各 5 位 ⇒ 0..31）
pub let snowflake_max_node : Int = 31

///|
/// 序列号上界（12 位 ⇒ 0..4095，即每毫秒每节点最多 4096 个号）
pub let snowflake_max_sequence : Int64 = 4095L

///|
/// 雪花 ID 的四段解析结果（41 位时间戳 ‖ 5 位数据中心 ‖ 5 位 worker ‖ 12 位序列）
pub struct SnowflakeParts {
  timestamp_millis : Int64
  datacenter_id : Int
  worker_id : Int
  sequence : Int64
} derive(Eq, Compare)

///|
/// 一段时间区间的 ID 边界（用于"按时间查 ID"这类范围扫描）
pub struct IdRange {
  start : Int64
  finish : Int64
} derive(Eq, Compare)

///|
/// 发号器：节点编号与容忍回拨量在 `new` 时定下，时钟每次显式传
///
/// 状态（`last_timestamp`/`sequence`）挂在**实例**上而不是类级静态——hutool 是静态的，
/// 多实例共享一个计数器且不可注入。
pub struct Snowflake {
  datacenter_id : Int
  worker_id : Int
  tolerance_millis : Int64
  mut last_timestamp : Int64
  mut sequence : Int64
}

///|
/// ObjectId 发号器：`machine`（4 字节）注入，`counter` 自增并回绕
pub struct ObjectIdGen {
  machine : Int64
  mut counter : Int64
}

///|
/// 41 位窗口能装下的最大时间偏移（`2^41 - 1`）；再加就压到符号位
let ts_delta_max : Int64 = 2199023255551L

///|
/// 位移常数（hutool `Snowflake` 与 MyBatis-Plus `IdWorker` 都是 22/17/12）
let ts_shift : Int = 22

///|
let dc_shift : Int = 17

///|
let worker_shift : Int = 12

///|
/// 一个 Int32 的无符号满值：ObjectId 的 machine/counter 上界，也是时间戳取低 32 位的掩码
let u32_max : Int64 = 4294967295L

///|
/// 规范 UUID 串的长度（32 个十六进制字符 + 4 个连字符）
let uuid_str_len : Int = 36

///|
/// 越界就报 `FieldOutOfRange`，携带**被违反的那一侧**边界（破下界给下界、破上界给上界）
fn check_range(
  name : String,
  value : Int64,
  low : Int64,
  high : Int64,
) -> Unit raise IdError {
  if value < low {
    raise FieldOutOfRange(name, value, low)
  }
  if value > high {
    raise FieldOutOfRange(name, value, high)
  }
}

///|
fn check_int(
  name : String,
  value : Int,
  low : Int,
  high : Int,
) -> Unit raise IdError {
  check_range(name, value.to_int64(), low.to_int64(), high.to_int64())
}

///|
/// 按位组装一个雪花 ID（纯函数，无状态、不读时钟）
///
/// - Parameters: `timestamp_millis` 必须落在 `[snowflake_epoch, snowflake_epoch + 2^41 - 1]`；
///   `datacenter_id`/`worker_id` 0..31；`sequence` 0..4095
/// - Returns: `((ts - epoch) << 22) | (dc << 17) | (worker << 12) | sequence`
/// - Raises: `IdError.FieldOutOfRange`（三个字段任一越界）、`IdError.TimestampOverflow`
///   （41 位装不下——hutool 不校验，符号位翻负后发出的是**负数 ID**）
pub fn snowflake_id(
  timestamp_millis : Int64,
  datacenter_id : Int,
  worker_id : Int,
  sequence : Int64,
) -> Int64 raise IdError {
  check_int("datacenter_id", datacenter_id, 0, snowflake_max_node)
  check_int("worker_id", worker_id, 0, snowflake_max_node)
  check_range("sequence", sequence, 0L, snowflake_max_sequence)
  let delta = timestamp_millis - snowflake_epoch
  if delta < 0L || delta > ts_delta_max {
    raise TimestampOverflow(timestamp_millis)
  }
  let dc_part = datacenter_id.to_int64() << dc_shift
  let worker_part = worker_id.to_int64() << worker_shift
  (delta << ts_shift) | dc_part | worker_part | sequence
}

///|
/// 反解一个雪花 ID 的四段
///
/// - Raises: `IdError.TimestampOverflow` —— 负数 ID 或解出早于纪年起点的时刻
pub fn snowflake_parts(id : Int64) -> SnowflakeParts raise IdError {
  // 算术右移：负数 ID 解出的时刻必然早于纪年起始，由下一个判断兜住
  let ts = (id >> ts_shift) + snowflake_epoch
  if ts < snowflake_epoch {
    raise TimestampOverflow(ts)
  }
  let dc = ((id >> dc_shift) & 31L).to_int()
  let worker = ((id >> worker_shift) & 31L).to_int()
  {
    timestamp_millis: ts,
    datacenter_id: dc,
    worker_id: worker,
    sequence: id & snowflake_max_sequence,
  }
}

///|
/// 给定起止时刻，返回**跨全部节点**的 ID 区间 `[start, finish]`
///
/// 用于按时间做范围扫描（`WHERE id BETWEEN start AND finish`）。只提供这一档：
/// 另一档要节点号，而节点号本库不猜（见文件头规则 2）
pub fn id_range_for_timestamps(
  start_millis : Int64,
  end_millis : Int64,
) -> IdRange raise IdError {
  let start = snowflake_id(start_millis, 0, 0, 0L)
  let finish = snowflake_id(
    end_millis, snowflake_max_node, snowflake_max_node, snowflake_max_sequence,
  )
  { start, finish, }
}

///|
/// 建一个发号器
///
/// - Parameters: `datacenter_id`/`worker_id` 0..31（由部署方分配，不是从机器上猜）；
///   `tolerance_millis` 可容忍的时钟回拨量，默认 2000（对位 hutool `DEFAULT_TIME_OFFSET`），
///   给 0 表示任何回拨都直接失败
/// - Raises: `IdError.FieldOutOfRange`
pub fn Snowflake::new(
  datacenter_id : Int,
  worker_id : Int,
  tolerance_millis? : Int64 = 2000L,
) -> Snowflake raise IdError {
  check_int("datacenter_id", datacenter_id, 0, snowflake_max_node)
  check_int("worker_id", worker_id, 0, snowflake_max_node)
  check_range("tolerance_millis", tolerance_millis, 0L, 9223372036854775807L)
  // -1 是"还没发过号"的哨兵（同 hutool 的 lastTimestamp = -1L）
  {
    datacenter_id,
    worker_id,
    tolerance_millis,
    last_timestamp: -1L,
    sequence: 0L,
  }
}

///|
/// 取下一个 ID
///
/// - Parameters: `now_millis` 调用方当前的 epoch 毫秒（框架层通常来自一次请求上下文）
/// - Note: 回拨不超过 `tolerance_millis` 时钉在 `last_timestamp` 上继续递增序列；
///   超过则 `raise ClockMovedBackwards`。**同毫秒序列用尽时把逻辑时间戳 +1**（不忙等真实时钟）
/// - Raises: `IdError.ClockMovedBackwards`、`IdError.TimestampOverflow`
pub fn Snowflake::next(self : Self, now_millis : Int64) -> Int64 raise IdError {
  let mut ts = if now_millis < self.last_timestamp {
    let offset = self.last_timestamp - now_millis
    if offset > self.tolerance_millis {
      raise ClockMovedBackwards(offset)
    }
    // 容忍内：钉在上次的时刻，绝不把号发回到过去
    self.last_timestamp
  } else {
    now_millis
  }
  if ts == self.last_timestamp {
    self.sequence = (self.sequence + 1L) & snowflake_max_sequence
    if self.sequence == 0L {
      // 同毫秒 4096 个用尽 ⇒ 推进逻辑时间戳（文件头规则 3）
      ts = ts + 1L
    }
  } else {
    self.sequence = 0L
  }
  self.last_timestamp = ts
  snowflake_id(ts, self.datacenter_id, self.worker_id, self.sequence)
}

///|
/// 取下一个 ID 的**十进制字符串**
///
/// 跨栈出口请一律走这条：JS 的 `Number` 只有 53 位精度，64 位 ID 直接进 JSON 会被静默截断
pub fn Snowflake::next_string(
  self : Self,
  now_millis : Int64,
) -> String raise IdError {
  let id = self.next(now_millis)
  id.to_string()
}

///|
/// nil UUID（RFC 4122 §4.2）
pub let uuid_nil : String = "00000000-0000-0000-0000-000000000000"

///|
/// 预定义命名空间：DNS（RFC 4122 §4.3）
pub let uuid_ns_dns : String = "6ba7b810-9dad-11d1-80b4-00c04fd430c8"

///|
/// URL
pub let uuid_ns_url : String = "6ba7b811-9dad-11d1-80b4-00c04fd430c8"

///|
/// OID
pub let uuid_ns_oid : String = "6ba7b812-9dad-11d1-80b4-00c04fd430c8"

///|
/// X.500
pub let uuid_ns_x500 : String = "6ba7b814-9dad-11d1-80b4-00c04fd430c8"

///|
/// 十六进制字符 → 数值，非十六进制给 `None`（大小写都收）
fn hex_value(c : Char) -> Int? {
  let v = c.to_int()
  if v >= 48 && v <= 57 {
    Some(v - 48)
  } else if v >= 97 && v <= 102 {
    Some(v - 87)
  } else if v >= 65 && v <= 70 {
    Some(v - 55)
  } else {
    None
  }
}

///|
/// 取一个十六进制字符的值，非法即 `BadHex`（携带下标，脏串才定位得了）
fn nibble_at(chars : Array[Char], src : String, at : Int) -> Int raise IdError {
  match hex_value(chars[at]) {
    Some(v) => v
    None => raise BadHex(src, at)
  }
}

///|
/// 规范串里连字符固定落在这四个下标
fn dash_slot(i : Int) -> Bool {
  i == 8 || i == 13 || i == 18 || i == 23
}

///|
/// 36 位规范串 → 16 字节（长度、连字符位置、字符集三样都校验）
fn uuid_bytes(canonical : String) -> Bytes raise IdError {
  let chars = canonical.to_array()
  let n = chars.length()
  if n != uuid_str_len {
    raise BadLength(canonical, n, uuid_str_len)
  }
  let buf = @buffer.Buffer()
  let mut i = 0
  while i < n {
    if dash_slot(i) {
      if chars[i] != '-' {
        raise BadHex(canonical, i)
      }
      i = i + 1
    } else {
      let hi = nibble_at(chars, canonical, i)
      let lo = nibble_at(chars, canonical, i + 1)
      buf.write_byte(((hi << 4) | lo).to_byte())
      i = i + 2
    }
  }
  buf.to_bytes()
}

///|
/// 原始字节 → 小写十六进制（`@hex.encode` 的大小写档不赌，显式落小写）
fn to_hex_lower(data : Bytes) -> String {
  @hex.encode(data).to_lower()
}

///|
/// 置 version 与 variant（RFC 4122 §4.1.1）：`byte[6]` 高四位 = version，`byte[8]` 高两位 = 10
fn with_version(data : Bytes, version : Int) -> Bytes {
  let arr = data.to_array()
  arr[6] = ((arr[6].to_int() & 0x0f) | (version << 4)).to_byte()
  arr[8] = ((arr[8].to_int() & 0x3f) | 0x80).to_byte()
  Bytes::from_array(arr.exact_view())
}

///|
/// 16 字节 → 36 位规范串（小写、连字符落 8/13/18/23）
fn to_canonical(data : Bytes) -> String {
  let chars = to_hex_lower(data).to_array()
  let buf = StringBuilder()
  for i in 0..<32 {
    // 字符出口走 StringBuilder，不走 @buffer.Buffer：后者在 wasm/js 档内部是 UTF-16，
    // write_char 还带废弃警告（本包的 @buffer.Buffer 只用来装**字节**，配 to_bytes 用）
    if i == 8 || i == 12 || i == 16 || i == 20 {
      buf.write_char('-')
    }
    buf.write_char(chars[i])
  }
  buf.to_string()
}

///|
/// 名字空间 UUID（MD5(namespace 字节 ‖ name)）——**hutool 没有这一档**，按 RFC 4122 §4.3 补
///
/// - Parameters: `ns` 必须是 36 位规范串（可用本包的 `uuid_ns_*`）；
///   `name` 按 **UTF-8 字节**参与运算（与 `digest` 同口径）
/// - Raises: `IdError.BadLength`、`IdError.BadHex`（namespace 形状不对）
pub fn uuid_v3(ns : String, name : String) -> String raise IdError {
  // namespace 参与运算的是它的 16 个**原始字节**，不是那串 36 字符的文本（同 CPython `uuid.uuid3`）
  let stream = uuid_bytes(ns) + @utf8.encode(name)
  to_canonical(with_version(@digest.md5_of_bytes(stream), 3))
}

///|
/// 随机 UUID 的**注入版**：`rand` 必须恰好 16 字节
///
/// 位改写：`rand[6] = (rand[6] & 0x0f) | 0x40`、`rand[8] = (rand[8] & 0x3f) | 0x80`
///
/// - Raises: `IdError.EntropyTooShort(16, got)`
pub fn uuid_v4(rand : Bytes) -> String raise IdError {
  let n = rand.length()
  if n != 16 {
    raise EntropyTooShort(16, n)
  }
  to_canonical(with_version(rand, 4))
}

///|
/// 随机 UUID 的便捷版（`env.rand(16)`）
///
/// - Raises: `IdError.NoEntropy` —— 取不到熵就失败，**绝不静默回落固定种子**
///   （那会产出"看着能用、实际可预测"的 ID）
pub fn uuid_v4_random() -> String raise IdError {
  match @env.rand(16) {
    Some(data) => uuid_v4(data)
    None => raise NoEntropy
  }
}

///|
/// JDK `UUID.nameUUIDFromBytes` 的兼容档：**只有 name、没有 namespace**
///
/// 与 Java 侧互解时要用这条而不是 `uuid_v3`（hutool `UUID.nameUUIDFromBytes` 同档）。
/// 输入固定按 UTF-8 编码——Java 那侧 `getBytes()` 会随平台默认字符集变，本库不跟
pub fn name_uuid(name : String) -> String {
  to_canonical(with_version(@digest.md5_of_bytes(@utf8.encode(name)), 3))
}

///|
/// 取 UUID 的 version 段（第 15 个十六进制字符）
///
/// - Raises: `IdError.BadLength`、`IdError.BadHex`
/// - Note: 只读 version，不判 variant——"这串是不是合法 UUID"是 `valid` 包的活
pub fn uuid_version(canonical : String) -> Int raise IdError {
  let b = uuid_bytes(canonical)
  b[6].to_int() >> 4
}

///|
/// 大端写一个 Int32（只取低 32 位）
fn write_u32_be(buf : @buffer.Buffer, value : Int64) -> Unit {
  let v = value & u32_max
  buf.write_byte(((v >> 24) & 255L).to_int().to_byte())
  buf.write_byte(((v >> 16) & 255L).to_int().to_byte())
  buf.write_byte(((v >> 8) & 255L).to_int().to_byte())
  buf.write_byte((v & 255L).to_int().to_byte())
}

///|
/// 组一个 ObjectId：三个**大端 Int32**（秒 ‖ machine ‖ counter），输出 24 位小写十六进制
///
/// - Parameters: `timestamp_secs` 只写**低 32 位**（与 hutool `bb.putInt((int) seconds)` 同行为，
///   2038 之后照此环绕，不做"悄悄扩到 8 字节"的兼容破坏）；`machine`/`counter` 0..0xFFFFFFFF
/// - Raises: `IdError.FieldOutOfRange`
pub fn object_id(
  timestamp_secs : Int64,
  machine : Int64,
  counter : Int64,
) -> String raise IdError {
  check_range("machine", machine, 0L, u32_max)
  check_range("counter", counter, 0L, u32_max)
  let buf = @buffer.Buffer()
  write_u32_be(buf, timestamp_secs)
  write_u32_be(buf, machine)
  write_u32_be(buf, counter)
  to_hex_lower(buf.to_bytes())
}

///|
/// 24 位十六进制 → 12 字节（长度与字符集都校验）
fn object_id_bytes(id : String) -> Bytes raise IdError {
  let chars = id.to_array()
  let n = chars.length()
  if n != 24 {
    raise BadLength(id, n, 24)
  }
  let buf = @buffer.Buffer()
  let mut i = 0
  while i < 24 {
    let hi = nibble_at(chars, id, i)
    let lo = nibble_at(chars, id, i + 1)
    buf.write_byte(((hi << 4) | lo).to_byte())
    i = i + 2
  }
  buf.to_bytes()
}

///|
/// 从 ObjectId 解回秒级时间戳（**无符号**低 32 位）
///
/// - Raises: `IdError.BadLength`、`IdError.BadHex`
pub fn object_id_timestamp(id : String) -> Int64 raise IdError {
  let b = object_id_bytes(id)
  // 一律升到 Int64 再移位：wasm 档的 Int 是 32 位，255 << 24 先溢出成 -1 再符号扩展就错了
  let v0 = b[0].to_int().to_int64()
  let v1 = b[1].to_int().to_int64()
  let v2 = b[2].to_int().to_int64()
  let v3 = b[3].to_int().to_int64()
  (v0 << 24) | (v1 << 16) | (v2 << 8) | v3
}

///|
/// 是否 24 位十六进制 ObjectId（大小写都收，**不接受连字符**）
///
/// hutool `isValid` 会先去掉 `-` 再判长度，于是带连字符的串它判真；本库判假——
/// 连字符不是 ObjectId 的合法形状，容它只会让脏数据往下走
pub fn is_object_id(s : String) -> Bool {
  let chars = s.to_array()
  if chars.length() != 24 {
    false
  } else {
    let mut ok = true
    for c in chars {
      match hex_value(c) {
        None => ok = false
        Some(_) => ()
      }
    }
    ok
  }
}

///|
/// 建一个 ObjectId 发号器
///
/// - Parameters: `machine` 0..0xFFFFFFFF（注入，理由见文件头规则 2）；`start_counter` 默认 0
/// - Raises: `IdError.FieldOutOfRange`
pub fn ObjectIdGen::new(
  machine : Int64,
  start_counter? : Int64 = 0L,
) -> ObjectIdGen raise IdError {
  check_range("machine", machine, 0L, u32_max)
  check_range("counter", start_counter, 0L, u32_max)
  { machine, counter: start_counter, }
}

///|
/// 取下一个 ObjectId（counter 自增，到 `0xFFFFFFFF` 后回 0）
pub fn ObjectIdGen::next(
  self : Self,
  timestamp_secs : Int64,
) -> String raise IdError {
  let id = object_id(timestamp_secs, self.machine, self.counter)
  self.counter = (self.counter + 1L) & u32_max
  id
}

///|
/// NanoId 默认表（hutool 的表序：`_`、`-`、数字、小写、大写）
///
/// ⚠ 与 npm `nanoid` 的 `A-Za-z0-9_-` **顺序不同**，表序直接决定读数 ⇒ 跨栈互解必须选边
pub let nano_id_alphabet : String = "_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

///|
/// 默认长度（21 字符，配合 64 字符表 ≈ 126 位熵）
pub let nano_id_size : Int = 21

///|
/// hutool 的 mask 式 `(2 << (int) floor(log(len-1) / log(2))) - 1`，用整数位长代替 `log`。
///
/// `len == 1` 时 Java 那侧 `(int)` 强转把 `-Infinity` 折成 0 ⇒ mask=1；本库照此定死（spec 04 #5）
fn nano_mask(alphabet_len : Int) -> Int {
  if alphabet_len <= 1 {
    1
  } else {
    let mut k = alphabet_len - 1
    let mut shift = 0
    while k > 1 {
      k = k >> 1
      shift = shift + 1
    }
    (2 << shift) - 1
  }
}

///|
fn ceil_div(a : Int, b : Int) -> Int {
  (a + b - 1) / b
}

///|
/// 生成 `size` 个字符需要注入多少随机字节（hutool 的 `step` 公式，暴露出来才凑得了注入）
///
/// `mask = (2 << floor(log2(len - 1))) - 1`、`step = ceil(1.6 * mask * size / len)`；
/// `len == 1` 时按 Java 的 `(int) floor(log 0) == 0` 退化成 `mask = 1`
///
/// - Raises: `IdError.FieldOutOfRange`（`len` 不在 1..255）、`IdError.BadLength`（`size <= 0`）
pub fn nano_id_bytes_needed(
  alphabet_len : Int,
  size : Int,
) -> Int raise IdError {
  check_int("alphabet_len", alphabet_len, 1, 255)
  if size < 1 {
    raise BadLength("nano_id size", size, 1)
  }
  // hutool 写的是 `(int) ceil(1.6 * mask * size / len)`；1.6 = 8/5，走精确有理式免得浮点漂
  ceil_div(8 * nano_mask(alphabet_len) * size, 5 * alphabet_len)
}

///|
/// 拒绝采样：按序吃 `rand`，`(b & mask)` 落在表内才取字符，凑够 `want` 个就停（剩余字节丢掉）
fn nano_fill(
  buf : StringBuilder,
  chars : Array[Char],
  want : Int,
  rand : Bytes,
) -> Int {
  let len = chars.length()
  let mask = nano_mask(len)
  let total = rand.length()
  let mut k = 0
  let mut i = 0
  while k < want && i < total {
    let r = rand[i].to_int() & mask
    if r < len {
      buf.write_char(chars[r])
      k = k + 1
    }
    i = i + 1
  }
  k
}

///|
/// NanoId 的**注入版**（拒绝采样，逐字节与 hutool 同序）
///
/// - Parameters: `alphabet` 按**码点**索引（非 ASCII 表也能用）；`rand` 是注入的随机字节
/// - Raises: `IdError.EntropyTooShort`（注入字节用完仍没凑够，携带应需字节数与实得字节数）、
///   `IdError.FieldOutOfRange`（空表、表长 ≥ 256、`size < 1`——都携带被违反的那一侧边界）
pub fn nano_id(
  alphabet : String,
  size : Int,
  rand : Bytes,
) -> String raise IdError {
  let chars = alphabet.to_array()
  let len = chars.length()
  check_int("alphabet_len", len, 1, 255)
  if size < 1 {
    raise FieldOutOfRange("size", size.to_int64(), 1L)
  }
  let buf = StringBuilder()
  let got = nano_fill(buf, chars, size, rand)
  if got < size {
    // 注入的熵是一次性的，不会像随机源那样再给一轮 ⇒ 明确报缺多少，绝不拿固定字节补齐
    let need = nano_id_bytes_needed(len, size)
    raise EntropyTooShort(need, rand.length())
  }
  buf.to_string()
}

///|
/// NanoId 便捷版：自定义表与长度，熵走 `env.rand`（每轮取 `nano_id_bytes_needed` 个字节）
///
/// - Raises: `IdError.NoEntropy` 及 `nano_id` 的全部错误
pub fn nano_id_random(alphabet : String, size : Int) -> String raise IdError {
  let chars = alphabet.to_array()
  let need = nano_id_bytes_needed(chars.length(), size)
  let buf = StringBuilder()
  let mut k = 0
  while k < size {
    // 一轮取 need 个字节可能因拒绝采样不够（同 hutool 的 do-while），所以再取一轮
    let rand = match @env.rand(need) {
      Some(data) => data
      None => raise NoEntropy
    }
    k = k + nano_fill(buf, chars, size - k, rand)
  }
  buf.to_string()
}

///|
/// NanoId 便捷版：默认表 + 默认长度 + `env.rand`
///
/// - Raises: `IdError.NoEntropy`
pub fn nano_id_default() -> String raise IdError {
  nano_id_random(nano_id_alphabet, nano_id_size)
}
