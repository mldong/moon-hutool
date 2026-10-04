///|
/// moon-hutool/id —— ID 生成（hutool `IdUtil` 家族的 MoonBit 对位）
///
/// 契约：`docs/spec/04-id.md`。本文件此刻是**签名骨架**，函数体一律 `abort("…未实现…")`：
/// `moon check` 全绿、`moon test` 本包预期红。期望值权威在 `id_test.mbt` 与 spec 表——
/// 实现期只许把红变绿，改期望值须单独一笔并给外部读数来源（门禁 G5）。
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
  let _ = (timestamp_millis, datacenter_id, worker_id, sequence)
  abort("moon-hutool: id.snowflake_id 未实现（spec 04-id #2.1）")
}

///|
/// 反解一个雪花 ID 的四段
///
/// - Raises: `IdError.TimestampOverflow` —— 负数 ID 或解出早于纪年起点的时刻
pub fn snowflake_parts(id : Int64) -> SnowflakeParts raise IdError {
  let _ = id
  abort("moon-hutool: id.snowflake_parts 未实现（spec 04-id #2.1）")
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
  let _ = (start_millis, end_millis)
  abort(
    "moon-hutool: id.id_range_for_timestamps 未实现（spec 04-id #2.1）",
  )
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
  let _ = (datacenter_id, worker_id, tolerance_millis)
  abort("moon-hutool: id.Snowflake::new 未实现（spec 04-id #2.2）")
}

///|
/// 取下一个 ID
///
/// - Parameters: `now_millis` 调用方当前的 epoch 毫秒（框架层通常来自一次请求上下文）
/// - Note: 回拨不超过 `tolerance_millis` 时钉在 `last_timestamp` 上继续递增序列；
///   超过则 `raise ClockMovedBackwards`。**同毫秒序列用尽时把逻辑时间戳 +1**（不忙等真实时钟）
/// - Raises: `IdError.ClockMovedBackwards`、`IdError.TimestampOverflow`
pub fn Snowflake::next(self : Self, now_millis : Int64) -> Int64 raise IdError {
  let _ = (self, now_millis)
  abort("moon-hutool: id.Snowflake::next 未实现（spec 04-id #2.2）")
}

///|
/// 取下一个 ID 的**十进制字符串**
///
/// 跨栈出口请一律走这条：JS 的 `Number` 只有 53 位精度，64 位 ID 直接进 JSON 会被静默截断
pub fn Snowflake::next_string(
  self : Self,
  now_millis : Int64,
) -> String raise IdError {
  let _ = (self, now_millis)
  abort("moon-hutool: id.Snowflake::next_string 未实现（spec 04-id #2.2）")
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
/// 名字空间 UUID（MD5(namespace 字节 ‖ name)）——**hutool 没有这一档**，按 RFC 4122 §4.3 补
///
/// - Parameters: `ns` 必须是 36 位规范串（可用本包的 `uuid_ns_*`）；
///   `name` 按 **UTF-8 字节**参与运算（与 `digest` 同口径）
/// - Raises: `IdError.BadLength`、`IdError.BadHex`（namespace 形状不对）
pub fn uuid_v3(ns : String, name : String) -> String raise IdError {
  let _ = (ns, name)
  abort("moon-hutool: id.uuid_v3 未实现（spec 04-id #3.3）")
}

///|
/// 随机 UUID 的**注入版**：`rand` 必须恰好 16 字节
///
/// 位改写：`rand[6] = (rand[6] & 0x0f) | 0x40`、`rand[8] = (rand[8] & 0x3f) | 0x80`
///
/// - Raises: `IdError.EntropyTooShort(16, got)`
pub fn uuid_v4(rand : Bytes) -> String raise IdError {
  let _ = rand
  abort("moon-hutool: id.uuid_v4 未实现（spec 04-id #3.5）")
}

///|
/// 随机 UUID 的便捷版（`env.rand(16)`）
///
/// - Raises: `IdError.NoEntropy` —— 取不到熵就失败，**绝不静默回落固定种子**
///   （那会产出"看着能用、实际可预测"的 ID）
pub fn uuid_v4_random() -> String raise IdError {
  abort("moon-hutool: id.uuid_v4_random 未实现（spec 04-id #3.6）")
}

///|
/// JDK `UUID.nameUUIDFromBytes` 的兼容档：**只有 name、没有 namespace**
///
/// 与 Java 侧互解时要用这条而不是 `uuid_v3`（hutool `UUID.nameUUIDFromBytes` 同档）。
/// 输入固定按 UTF-8 编码——Java 那侧 `getBytes()` 会随平台默认字符集变，本库不跟
pub fn name_uuid(name : String) -> String {
  let _ = name
  abort("moon-hutool: id.name_uuid 未实现（spec 04-id #3.4）")
}

///|
/// 取 UUID 的 version 段（第 15 个十六进制字符）
///
/// - Raises: `IdError.BadLength`、`IdError.BadHex`
/// - Note: 只读 version，不判 variant——"这串是不是合法 UUID"是 `valid` 包的活
pub fn uuid_version(canonical : String) -> Int raise IdError {
  let _ = canonical
  abort("moon-hutool: id.uuid_version 未实现（spec 04-id #3.7）")
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
  let _ = (timestamp_secs, machine, counter)
  abort("moon-hutool: id.object_id 未实现（spec 04-id #4）")
}

///|
/// 从 ObjectId 解回秒级时间戳（**无符号**低 32 位）
///
/// - Raises: `IdError.BadLength`、`IdError.BadHex`
pub fn object_id_timestamp(id : String) -> Int64 raise IdError {
  let _ = id
  abort("moon-hutool: id.object_id_timestamp 未实现（spec 04-id #4）")
}

///|
/// 是否 24 位十六进制 ObjectId（大小写都收，**不接受连字符**）
///
/// hutool `isValid` 会先去掉 `-` 再判长度，于是带连字符的串它判真；本库判假——
/// 连字符不是 ObjectId 的合法形状，容它只会让脏数据往下走
pub fn is_object_id(s : String) -> Bool {
  let _ = s
  abort("moon-hutool: id.is_object_id 未实现（spec 04-id #4）")
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
  let _ = (machine, start_counter)
  abort("moon-hutool: id.ObjectIdGen::new 未实现（spec 04-id #4）")
}

///|
/// 取下一个 ObjectId（counter 自增，到 `0xFFFFFFFF` 后回 0）
pub fn ObjectIdGen::next(
  self : Self,
  timestamp_secs : Int64,
) -> String raise IdError {
  let _ = (self, timestamp_secs)
  abort("moon-hutool: id.ObjectIdGen::next 未实现（spec 04-id #4）")
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
  let _ = (alphabet_len, size)
  abort("moon-hutool: id.nano_id_bytes_needed 未实现（spec 04-id #5）")
}

///|
/// NanoId 的**注入版**（拒绝采样，逐字节与 hutool 同序）
///
/// - Parameters: `alphabet` 按**码点**索引（非 ASCII 表也能用）；`rand` 是注入的随机字节
/// - Raises: `IdError.EntropyTooShort`（注入字节用完仍没凑够）、`IdError.BadLength`（空表）、
///   `IdError.FieldOutOfRange`（表长 ≥ 256）
pub fn nano_id(
  alphabet : String,
  size : Int,
  rand : Bytes,
) -> String raise IdError {
  let _ = (alphabet, size, rand)
  abort("moon-hutool: id.nano_id 未实现（spec 04-id #5）")
}

///|
/// NanoId 便捷版：默认表 + 默认长度 + `env.rand`
///
/// - Raises: `IdError.NoEntropy`
pub fn nano_id_default() -> String raise IdError {
  abort("moon-hutool: id.nano_id_default 未实现（spec 04-id #5）")
}

///|
/// NanoId 便捷版：自定义表与长度，熵走 `env.rand`（每轮取 `nano_id_bytes_needed` 个字节）
///
/// - Raises: `IdError.NoEntropy` 及 `nano_id` 的全部错误
pub fn nano_id_random(alphabet : String, size : Int) -> String raise IdError {
  let _ = (alphabet, size)
  abort("moon-hutool: id.nano_id_random 未实现（spec 04-id #5）")
}
