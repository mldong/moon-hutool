// moon-hutool/id 契约用例（黑盒）。
//
// 状态：**已实现**（10-05，32 条全绿；wasm / js / wasm-gc 三档读数一致，native 档由 CI 出证）。
// 期望值先冻结、后实现；改任何期望串 = 门禁 G5 拦下，须单独一笔并给外部读数来源。
// 本包实现落地前只动过两条**契约内部自相矛盾**的期望（渲染器格式对不上、NanoId 夹具字节数不够），
// 判据在那一笔的正文里；其余期望串一字未改。
//
// 读数权威（逐条见 docs/spec/04-id.md 的「读数来源」列）：
// - Snowflake：hutool `lang/Snowflake.java` 实测的位分配（41/5/5/12，shift 22/17/12，
//   TWEPOCH=1288834974657），每条读数由同一位移式现算；与 MyBatis-Plus `IdWorker` 同 ID 空间。
// - `name_uuid`：**本机 JDK 17 实跑** `UUID.nameUUIDFromBytes`，并与 `hashlib.md5` 推算逐条对齐
//   （探针源码必须用 `\u` 转义写非 ASCII 输入——`javac` 在中文 Windows 上按 GBK 读 UTF-8 源文件，
//   会把「中文」解成 3 个错字符，给出一个看着权威其实脏的读数）。
// - `uuid_v3`：RFC 4122 §4.3，Python `uuid.uuid3` 与手算 `hashlib.md5(ns.bytes + name)` 双路互算。
// - ObjectId：hutool `nextBytes()` 的三个大端 Int32 布局，`struct.pack(">III", …)` 现算。
// - NanoId：hutool 的 mask/step 公式与**它自己的 64 字符表**，Python 镜像同一算法逐条现算。

///|
fn sf(dc : Int, worker : Int, tolerance : Int64) -> @id.Snowflake {
  @id.Snowflake::new(dc, worker, tolerance_millis=tolerance) catch {
    _ => abort("夹具节点编号必须合法")
  }
}

///|
fn next_id(s : @id.Snowflake, now : Int64) -> Int64 {
  s.next(now) catch {
    _ => abort("夹具发号不该失败")
  }
}

///|
fn oid_gen(machine : Int64) -> @id.ObjectIdGen {
  @id.ObjectIdGen::new(machine) catch {
    _ => abort("夹具 machine 必须合法")
  }
}

///|
fn bytes_of(xs : Array[Byte]) -> Bytes {
  Bytes::from_array(xs.exact_view())
}

///|
/// 把 raise 的结果折成「变体名 + 携带值」，让携带值也进断言（它同样是契约）。
fn[A] err_shape(g : () -> A raise @id.IdError) -> String {
  try {
    let _ = g()
    "未抛错"
  } catch {
    @id.FieldOutOfRange(name, value, bound) =>
      "FieldOutOfRange \{name}=\{value} bound=\{bound}"
    @id.TimestampOverflow(ts) => "TimestampOverflow \{ts}"
    @id.ClockMovedBackwards(ms) => "ClockMovedBackwards \{ms}"
    @id.EntropyTooShort(need, got) => "EntropyTooShort need=\{need} got=\{got}"
    @id.NoEntropy => "NoEntropy"
    @id.BadLength(input, len, want) =>
      "BadLength \{input} len=\{len} want=\{want}"
    @id.BadHex(input, at) => "BadHex \{input} @\{at}"
  }
}

///|
test "@id #2.1 snowflake_id 位组装（41/5/5/12，与 MyBatis-Plus 同号段）" {
  assert_eq(@id.snowflake_id(1288834974657L, 0, 0, 0L), 0L)
  assert_eq(@id.snowflake_id(1288834974658L, 0, 0, 0L), 4194304L)
  assert_eq(@id.snowflake_id(1288834974658L, 0, 0, 4095L), 4198399L)
  assert_eq(@id.snowflake_id(1759552496789L, 1, 2, 3L), 1974332385948475395L)
  assert_eq(
    @id.snowflake_id(1791117296789L, 31, 31, 4095L),
    2106724752851730431L,
  )
  // 41 位用满：Int64 满格，再往前一毫秒就是符号位
  assert_eq(
    @id.snowflake_id(3487858230208L, 31, 31, 4095L),
    9223372036854775807L,
  )
  // hutool 不校验溢出（发出负数 ID），本库报错
  assert_eq(
    err_shape(() => @id.snowflake_id(3487858230209L, 0, 0, 0L)),
    "TimestampOverflow 3487858230209",
  )
  assert_eq(
    err_shape(() => @id.snowflake_id(1288834974656L, 0, 0, 0L)),
    "TimestampOverflow 1288834974656",
  )
  assert_eq(
    err_shape(() => @id.snowflake_id(1759552496789L, 32, 0, 0L)),
    "FieldOutOfRange datacenter_id=32 bound=31",
  )
  assert_eq(
    err_shape(() => @id.snowflake_id(1759552496789L, 0, 32, 0L)),
    "FieldOutOfRange worker_id=32 bound=31",
  )
  assert_eq(
    err_shape(() => @id.snowflake_id(1759552496789L, 0, 0, 4096L)),
    "FieldOutOfRange sequence=4096 bound=4095",
  )
}

///|
test "@id #2.1 snowflake_parts 与 snowflake_id 互逆" {
  let cases = [
    (0L, 1288834974657L, 0, 0, 0L),
    (4194304L, 1288834974658L, 0, 0, 0L),
    (4198399L, 1288834974658L, 0, 0, 4095L),
    (1974332385948475395L, 1759552496789L, 1, 2, 3L),
    (2106724752851730431L, 1791117296789L, 31, 31, 4095L),
    (9223372036854775807L, 3487858230208L, 31, 31, 4095L),
  ]
  for (id, ts, dc, w, seq) in cases {
    let p = @id.snowflake_parts(id) catch {
      _ => abort("合法 ID 不该解不开")
    }
    assert_eq(p.timestamp_millis, ts)
    assert_eq(p.datacenter_id, dc)
    assert_eq(p.worker_id, w)
    assert_eq(p.sequence, seq)
  }
  assert_eq(
    err_shape(() => @id.snowflake_parts(-1L)),
    "TimestampOverflow 1288834974656",
  )
}

///|
test "@id #2.1 id_range_for_timestamps 给跨全部节点的区间" {
  let r = @id.id_range_for_timestamps(1759552496789L, 1759552496790L) catch {
    _ => abort("夹具时刻必须合法")
  }
  assert_eq(r.start, 1974332385948336128L)
  assert_eq(r.finish, 1974332385956724735L)
  // finish 就是同一时刻把 22 位低段全填满（31‖314095）
  assert_eq(r.finish - r.start, 8388607L)
  assert_eq(
    err_shape(() => @id.id_range_for_timestamps(3487858230209L, 3487858230210L)),
    "TimestampOverflow 3487858230209",
  )
}

///|
test "@id #2.2 同一毫秒连取递增 sequence，换毫秒归零" {
  let s = sf(1, 2, 2000L)
  let t = 1759552496789L
  assert_eq(next_id(s, t), 1974332385948475392L)
  assert_eq(next_id(s, t), 1974332385948475393L)
  assert_eq(next_id(s, t), 1974332385948475394L)
  assert_eq(next_id(s, t), 1974332385948475395L)
  assert_eq(next_id(s, t + 1L), 1974332385952669696L)
}

///|
test "@id #2.2 时钟回拨：容忍内钉住，超容忍报错（携带回拨量）" {
  let s = sf(1, 2, 2000L)
  let t = 1759552496789L
  assert_eq(next_id(s, t), 1974332385948475392L)
  // 换毫秒 ⇒ sequence 归零（不是继续 +1）
  assert_eq(next_id(s, t + 1L), 1974332385952669696L)
  // 回拨 500ms ≤ 2000ms ⇒ 仍用 last_timestamp = t+1，sequence 继续 +1
  assert_eq(next_id(s, t + 1L - 500L), 1974332385952669697L)
  // 回拨 3000ms > 2000ms ⇒ 报错，携带回拨毫秒数
  assert_eq(err_shape(() => s.next(t + 1L - 3000L)), "ClockMovedBackwards 3000")
  // tolerance=0 ⇒ 任何回拨都失败
  let strict = sf(1, 2, 0L)
  assert_eq(next_id(strict, t), 1974332385948475392L)
  assert_eq(err_shape(() => strict.next(t - 1L)), "ClockMovedBackwards 1")
}

///|
test "@id #2.2 同毫秒 4096 个用尽后推进逻辑时间戳（不忙等真实时钟）" {
  let s = sf(1, 2, 2000L)
  let t = 1759552496789L
  let mut last = 0L
  for _ in 0..<4096 {
    last = next_id(s, t)
  }
  assert_eq(last, 1974332385948479487L) // seq=4095
  assert_eq(next_id(s, t), 1974332385952669696L) // ts 前进到 t+1，seq 回 0
  // 之后仍落在同一个注入时刻上：继续从 t+1 的 seq=1 递增
  assert_eq(next_id(s, t), 1974332385952669697L)
}

///|
test "@id #2.2 next_string 出十进制字符串（跨栈出口，JS 只有 53 位精度）" {
  let s = sf(1, 2, 2000L)
  let got = s.next_string(1759552496789L) catch {
    _ => abort("夹具发号不该失败")
  }
  assert_eq(got, "1974332385948475392")
}

///|
test "@id #3.1 #3.2 常量表：nil、四个 namespace、位分配上界" {
  assert_eq(@id.uuid_nil, "00000000-0000-0000-0000-000000000000")
  assert_eq(@id.uuid_ns_dns, "6ba7b810-9dad-11d1-80b4-00c04fd430c8")
  assert_eq(@id.uuid_ns_url, "6ba7b811-9dad-11d1-80b4-00c04fd430c8")
  assert_eq(@id.uuid_ns_oid, "6ba7b812-9dad-11d1-80b4-00c04fd430c8")
  assert_eq(@id.uuid_ns_x500, "6ba7b814-9dad-11d1-80b4-00c04fd430c8")
  assert_eq(@id.snowflake_epoch, 1288834974657L)
  assert_eq(@id.snowflake_max_node, 31)
  assert_eq(@id.snowflake_max_sequence, 4095L)
  assert_eq(@id.nano_id_size, 21)
  assert_eq(
    @id.nano_id_alphabet, "_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
  )
  assert_eq(@id.nano_id_alphabet.char_length(), 64)
}

///|
test "@id #3.3 uuid_v3（RFC 4122 §4.3，MD5(namespace ‖ name)）" {
  let v = @id.uuid_v3(@id.uuid_ns_dns, "www.example.com") catch {
    _ => abort("namespace 常量必须合法")
  }
  assert_eq(v, "5df41881-3aed-3515-88a7-2f4a814cf09e")
  assert_eq(@id.uuid_version(v), 3)
  let g : (String, String) -> String = (ns, name) => {
    @id.uuid_v3(ns, name) catch {
      _ => abort("夹具 namespace 必须合法")
    }
  }
  assert_eq(g(@id.uuid_ns_dns, ""), "c87ee674-4ddc-3efe-a74e-dfe25da5d7b3")
  assert_eq(
    g(@id.uuid_ns_url, "hutool"),
    "6a2fefe3-8842-3671-9f35-f6e5a5ac58fb",
  )
  assert_eq(
    g(@id.uuid_ns_dns, "中文"),
    "16f114b0-3b17-3212-8d00-64c5d765a004",
  )
  assert_eq(
    g(@id.uuid_ns_x500, "cn=hutool"),
    "a79170fa-dbd9-3092-a405-b8adfccca9ae",
  )
  // namespace 形状不对：长度档与非法字符档
  assert_eq(
    err_shape(() => @id.uuid_v3("6ba7b810-9dad-11d1-80b4-00c04fd430c", "x")),
    "BadLength 6ba7b810-9dad-11d1-80b4-00c04fd430c len=35 want=36",
  )
  assert_eq(
    err_shape(() => @id.uuid_v3("zzzzzzzz-9dad-11d1-80b4-00c04fd430c8", "x")),
    "BadHex zzzzzzzz-9dad-11d1-80b4-00c04fd430c8 @0",
  )
}

///|
test "@id #3.4 name_uuid 与 JDK 17 实跑读数逐条一致（无 namespace 的兼容档）" {
  assert_eq(@id.name_uuid(""), "d41d8cd9-8f00-3204-a980-0998ecf8427e")
  assert_eq(@id.name_uuid("abc"), "90015098-3cd2-3fb0-9696-3f7d28e17f72")
  assert_eq(
    @id.name_uuid("www.example.com"),
    "7c1767b3-0512-3600-bfd3-c2e618a86522",
  )
  // 这条与 digest 已冻结的 md5_hex("中文") 同源：a7bac2239fcdcb3a067903d8077c4a07
  assert_eq(@id.name_uuid("中文"), "a7bac223-9fcd-3b3a-8679-03d8077c4a07")
  assert_eq(@id.uuid_version(@id.name_uuid("abc")), 3)
}

///|
test "@id #3.5 uuid_v4 注入 16 字节（version/variant 位改写）" {
  let g : (Array[Byte]) -> String = xs => {
    @id.uuid_v4(bytes_of(xs)) catch {
      _ => abort("夹具必须给满 16 字节")
    }
  }
  assert_eq(
    g([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
    "00000000-0000-4000-8000-000000000000",
  )
  assert_eq(
    g([
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255,
    ]),
    "ffffffff-ffff-4fff-bfff-ffffffffffff",
  )
  assert_eq(
    g([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
    "00010203-0405-4607-8809-0a0b0c0d0e0f",
  )
  assert_eq(
    g([42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57]),
    "2a2b2c2d-2e2f-4031-b233-343536373839",
  )
  assert_eq(
    err_shape(() => @id.uuid_v4(bytes_of([0, 1, 2, 3]))),
    "EntropyTooShort need=16 got=4",
  )
  assert_eq(
    err_shape(() => @id.uuid_v4(bytes_of([]))),
    "EntropyTooShort need=16 got=0",
  )
}

///|
test "@id #3.6 有熵则出 v4 形状，无熵则明确报 NoEntropy（不许静默回落固定种子）" {
  let out = @id.uuid_v4_random() catch {
    @id.NoEntropy => "no-entropy"
    _ => "其它错误"
  }
  assert_true(out == "no-entropy" || (out.length() == 36 && out[14] == '4'))
  // 两次调用（有熵时）不该给出同一个值；无熵时两次都是 no-entropy，这条仍成立
  let again = @id.uuid_v4_random() catch {
    @id.NoEntropy => "no-entropy"
    _ => "其它错误"
  }
  assert_true(out == "no-entropy" || out != again)
}

///|
test "@id #3.7 uuid_version 只读 version 段" {
  let v : (String) -> Int = s => {
    @id.uuid_version(s) catch {
      _ => abort("夹具串必须合法")
    }
  }
  assert_eq(v("5df41881-3aed-3515-88a7-2f4a814cf09e"), 3)
  assert_eq(v("d41d8cd9-8f00-3204-a980-0998ecf8427e"), 3)
  assert_eq(v("00000000-0000-4000-8000-000000000000"), 4)
  assert_eq(v("2ed6657d-e927-568b-95e3-e5a295fed3ad"), 5)
  assert_eq(v("6ba7b810-9dad-11d1-80b4-00c04fd430c8"), 1)
  assert_eq(v(@id.uuid_nil), 0)
  assert_eq(
    err_shape(() => @id.uuid_version("5df418813aed351588a72f4a814cf09e")),
    "BadLength 5df418813aed351588a72f4a814cf09e len=32 want=36",
  )
  assert_eq(
    err_shape(() => @id.uuid_version("5df41881-3aed-3515-88a7-2f4a814cf09z")),
    "BadHex 5df41881-3aed-3515-88a7-2f4a814cf09z @35",
  )
}

///|
test "@id #4 object_id 是三个大端 Int32（秒 ‖ machine ‖ counter）" {
  let g : (Int64, Int64, Int64) -> String = (secs, machine, counter) => {
    @id.object_id(secs, machine, counter) catch {
      _ => abort("夹具参数必须合法")
    }
  }
  assert_eq(g(1759552496L, 305419896L, 2596069104L), "68e0a3f0123456789abcdef0")
  assert_eq(g(0L, 0L, 0L), "000000000000000000000000")
  assert_eq(g(2038L, 4294967295L, 4294967295L), "000007f6ffffffffffffffff")
  // 只写低 32 位：4294967396 = 2^32 + 100 ⇒ 环绕成 100（与 hutool 的 putInt((int) 秒) 同行为）
  assert_eq(g(4294967396L, 1L, 2L), "000000640000000100000002")
  assert_eq(@id.object_id_timestamp(g(4294967396L, 1L, 2L)), 100L)
  assert_eq(
    err_shape(() => @id.object_id(1L, 4294967296L, 1L)),
    "FieldOutOfRange machine=4294967296 bound=4294967295",
  )
  assert_eq(
    err_shape(() => @id.object_id(1L, 1L, -1L)),
    "FieldOutOfRange counter=-1 bound=0",
  )
}

///|
test "@id #4 object_id_timestamp 反解与输入校验" {
  let t : (String) -> Int64 = s => {
    @id.object_id_timestamp(s) catch {
      _ => abort("夹具 ID 必须合法")
    }
  }
  assert_eq(t("68e0a3f0123456789abcdef0"), 1759552496L)
  assert_eq(t("000000000000000000000000"), 0L)
  assert_eq(t("000007f6ffffffffffffffff"), 2038L)
  // 高位置 1 也按无符号读（hutool 那侧 getInt 是有符号读法，负秒没有意义）
  assert_eq(t("ffffffff0000000000000000"), 4294967295L)
  assert_eq(
    err_shape(() => @id.object_id_timestamp("68e0a3f0123456789abcde")),
    "BadLength 68e0a3f0123456789abcde len=22 want=24",
  )
  assert_eq(
    err_shape(() => @id.object_id_timestamp("68e0a3f0123456789abcdezz")),
    "BadHex 68e0a3f0123456789abcdezz @22",
  )
}

///|
test "@id #4 is_object_id：大小写都收，连字符不收" {
  assert_eq(@id.is_object_id("000000000000000000000000"), true)
  assert_eq(@id.is_object_id("ABCDEF0123456789ABCDEF01"), true)
  assert_eq(@id.is_object_id("68e0a3f0123456789abcdef0"), true)
  assert_eq(@id.is_object_id(""), false)
  assert_eq(@id.is_object_id("00000000000000000000000"), false)
  assert_eq(@id.is_object_id("0000000000000000000000000"), false)
  assert_eq(@id.is_object_id("zzzzzzzzzzzzzzzzzzzzzzzz"), false)
  // hutool 会先去掉 `-` 再判长度 ⇒ 它判真，本库判假
  assert_eq(@id.is_object_id("68e0a3f0-1234-5678-9abc-def0"), false)
}

///|
test "@id #4 ObjectIdGen：counter 自增并回绕" {
  let g = oid_gen(0x12345678L)
  assert_eq(next_oid(g, 1759552496L), "68e0a3f01234567800000000")
  assert_eq(next_oid(g, 1759552496L), "68e0a3f01234567800000001")
  assert_eq(next_oid(g, 1759552497L), "68e0a3f11234567800000002")
  let wrap = oid_gen_at(1L, 4294967295L)
  assert_eq(next_oid(wrap, 0L), "0000000000000001ffffffff")
  assert_eq(next_oid(wrap, 0L), "000000000000000100000000") // 回绕到 0
  assert_eq(
    err_shape(() => @id.ObjectIdGen::new(4294967296L)),
    "FieldOutOfRange machine=4294967296 bound=4294967295",
  )
}

///|
fn next_oid(g : @id.ObjectIdGen, secs : Int64) -> String {
  g.next(secs) catch {
    _ => abort("夹具发号不该失败")
  }
}

///|
fn oid_gen_at(machine : Int64, start : Int64) -> @id.ObjectIdGen {
  @id.ObjectIdGen::new(machine, start_counter=start) catch {
    _ => abort("夹具参数必须合法")
  }
}

///|
test "@id #5 nano_id_bytes_needed（hutool 的 mask/step 公式）" {
  let n : (Int, Int) -> Int = (len, size) => {
    @id.nano_id_bytes_needed(len, size) catch {
      _ => abort("夹具表长必须合法")
    }
  }
  assert_eq(n(64, 21), 34)
  assert_eq(n(64, 10), 16)
  assert_eq(n(3, 8), 13)
  assert_eq(n(2, 1), 1)
  assert_eq(n(1, 5), 8) // len==1 时 Java 式子退化成 mask=1
  assert_eq(n(100, 24), 49)
  assert_eq(
    err_shape(() => @id.nano_id_bytes_needed(256, 21)),
    "FieldOutOfRange alphabet_len=256 bound=255",
  )
  assert_eq(
    err_shape(() => @id.nano_id_bytes_needed(0, 21)),
    "FieldOutOfRange alphabet_len=0 bound=1",
  )
  assert_eq(
    err_shape(() => @id.nano_id_bytes_needed(64, 0)),
    "BadLength nano_id size len=0 want=1",
  )
}

///|
test "@id #5 nano_id 注入版（默认表序、拒绝采样逐字节同序）" {
  let g : (String, Int, Array[Byte]) -> String = (alphabet, size, xs) => {
    @id.nano_id(alphabet, size, bytes_of(xs)) catch {
      _ => abort("夹具注入字节必须够")
    }
  }
  assert_eq(
    g(@id.nano_id_alphabet, 21, [
      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
      22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33,
    ]),
    "_-0123456789abcdefghi",
  )
  assert_eq(
    g(@id.nano_id_alphabet, 21, [
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255,
    ]),
    "ZZZZZZZZZZZZZZZZZZZZZ",
  )
  // 非 2 的幂表：mask=3 ⇒ 索引 3 越表被丢，继续吃下一个字节
  assert_eq(g("abc", 4, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]), "abca")
  assert_eq(g("ab", 1, [1]), "b")
  // len==1 时 mask=1 ⇒ 奇数字节被拒，5 个字符至少要 9 字节（Python 镜像 hutool 现算：7 字节只出 4 个）
  assert_eq(g("a", 5, [0, 1, 0, 1, 0, 1, 0, 1, 0]), "aaaaa")
}

///|
test "@id #5 nano_id 的失败档" {
  // 注入字节用完仍没凑够 size
  assert_eq(
    err_shape(() => @id.nano_id("abc", 8, bytes_of([0, 1, 2]))),
    "EntropyTooShort need=13 got=3",
  )
  assert_eq(
    err_shape(() => @id.nano_id("", 10, bytes_of([0, 1, 2, 3]))),
    "FieldOutOfRange alphabet_len=0 bound=1",
  )
  assert_eq(
    err_shape(() => @id.nano_id("ab", 0, bytes_of([0]))),
    "FieldOutOfRange size=0 bound=1",
  )
}

///|
test "@id #5 nano_id_default / nano_id_random：有熵出形状，无熵报 NoEntropy" {
  let out = @id.nano_id_default() catch {
    @id.NoEntropy => "no-entropy"
    _ => "其它错误"
  }
  assert_true(out == "no-entropy" || out.length() == 21)
  let custom = @id.nano_id_random("01", 8) catch {
    @id.NoEntropy => "no-entropy"
    _ => "其它错误"
  }
  assert_true(custom == "no-entropy" || custom.length() == 8)
}

///|
test "@id #2 Eq/Compare 与字段可读（derive + extends 那一笔的兑现处）" {
  let p = @id.snowflake_parts(1974332385948475395L) catch {
    _ => abort("夹具 ID 必须合法")
  }
  assert_eq(p.datacenter_id, 1)
  assert_true(p == p)
  let q = @id.snowflake_parts(1L) catch { _ => abort("夹具 ID 必须合法") }
  assert_true(p != q)
  let r = @id.id_range_for_timestamps(1759552496789L, 1759552496790L) catch {
    _ => abort("夹具时刻必须合法")
  }
  assert_true(r.start < r.finish)
  assert_true(r.start <= r.start)
}
