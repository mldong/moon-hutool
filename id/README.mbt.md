# id

hutool `IdUtil` 家族的 MoonBit 对位：雪花 ID、UUID（v3 / v4 / JDK 兼容档）、ObjectId、NanoId。

完整边界矩阵与逐条读数来源见 [`docs/spec/04-id.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/04-id.md)。

> 状态：**契约已冻结、实现未开工**——函数体是 `abort`，下面每个块的期望值此刻红是设计态。期望串与 `id_test.mbt` 同受"期望值冻结"约束：实现期只许把红变绿（门禁 G5）。

## 三条先决口径

**一、时钟与熵都是参数。** 发号函数一律显式吃 `now_millis` / `timestamp_secs` / 注入的随机字节；只有带 `_random` 后缀的入口才碰 `env.now()`/`env.rand()`。hutool 那侧靠 `SystemClock`、`SecureRandom` 这些静态量——照抄的话这些格子就永远不可测，期望值会随机器漂。

**二、不读 PID、不读网卡、不读 ClassLoader**（全要 FFI）。`machine`、`datacenter_id`、`worker_id` 由调用方给。hutool 的机器码是这三样的哈希组合且"取不到就随机"，等于静默降级成可能撞号的 ID——本库宁可**不给默认值**。

**三、不自旋、不 sleep。** 同毫秒 4096 个序列号用尽后把**逻辑时间戳**推进 1 毫秒继续发号；hutool 的 `tilNextMillis()` 是忙等真实时钟，而这里的时钟是传进来的纯数据。

## 雪花 ID

位分配 **41 时间戳 ‖ 5 数据中心 ‖ 5 worker ‖ 12 序列**，纪年起点 `1288834974657`——与 hutool、MyBatis-Plus `IdWorker` **同一个号段**，所以跨栈拿到的是同一个 ID 空间。

```mbt check
///|
test "注入时钟发号，并可反解" {
  let sf = @id.Snowflake::new(1, 2) catch {
    _ => abort("夹具节点编号必须合法")
  }
  let t = 1759552496789L
  let a = sf.next(t) catch { _ => abort("夹具发号不该失败") }
  let b = sf.next(t) catch { _ => abort("夹具发号不该失败") }
  assert_eq(a, 1974332385948475392L)
  assert_eq(b, 1974332385948475393L) // 同毫秒，sequence +1
  let p = @id.snowflake_parts(a) catch { _ => abort("合法 ID 该解得开") }
  assert_eq(p.timestamp_millis, 1759552496789L)
  assert_eq(p.datacenter_id, 1)
  assert_eq(p.worker_id, 2)
  assert_eq(p.sequence, 0L)
}
```

跨栈出口走字符串：JS 的 `Number` 只有 53 位精度，64 位 ID 直接进 JSON 会被静默截断。

```mbt check
///|
test "next_string 出十进制字符串" {
  let sf = @id.Snowflake::new(1, 2) catch {
    _ => abort("夹具节点编号必须合法")
  }
  let s = sf.next_string(1759552496789L) catch {
    _ => abort("夹具发号不该失败")
  }
  assert_eq(s, "1974332385948475392")
}
```

**时钟回拨**：默认容忍 2000ms（对位 hutool `DEFAULT_TIME_OFFSET`）——容忍范围内钉在上次的时间戳继续递增序列，超出则报错并携带回拨量。

```mbt check
///|
test "回拨：容忍内钉住，超容忍报错" {
  let sf = @id.Snowflake::new(1, 2) catch {
    _ => abort("夹具节点编号必须合法")
  }
  let t = 1759552496789L
  let n = () => sf.next(t + 1L - 500L) catch { _ => -1L }
  assert_eq(sf.next(t) catch { _ => abort("夹具") }, 1974332385948475392L)
  assert_eq(
    sf.next(t + 1L) catch {
      _ => abort("夹具")
    },
    1974332385948475393L,
  )
  // 回拨 500ms：仍用 last_timestamp = t+1，sequence 继续 +1
  assert_eq(n(), 1974332385948475394L)
  let over = try {
    let _ = sf.next(t + 1L - 3000L)
    "未抛错"
  } catch {
    @id.ClockMovedBackwards(ms) => "ClockMovedBackwards \{ms}"
    _ => "错种"
  }
  assert_eq(over, "ClockMovedBackwards 3000")
}
```

```mbt check
///|
test "同毫秒 4096 个用尽后推进逻辑时间戳" {
  let sf = @id.Snowflake::new(1, 2) catch {
    _ => abort("夹具节点编号必须合法")
  }
  let t = 1759552496789L
  let mut last = 0L
  for _ in 0..<4096 {
    last = sf.next(t) catch { _ => abort("夹具发号不该失败") }
  }
  assert_eq(last, 1974332385948479487L) // sequence=4095
  assert_eq(
    sf.next(t) catch {
      _ => abort("夹具发号不该失败")
    },
    1974332385952669696L, // 逻辑时间戳前进到 t+1，sequence 回 0
  )
}
```

## UUID

三档别混：**v3 要 namespace**（RFC 4122），**`name_uuid` 不要**（JDK/hutool 那套只吃 name）。与 Java 侧互解时用错档，得到的是完全不同的号。

```mbt check
///|
test "v3（带 namespace）与 name_uuid（不带）不是一回事" {
  let v3 = @id.uuid_v3(@id.uuid_ns_dns, "www.example.com") catch {
    _ => abort("夹具 namespace 必须合法")
  }
  assert_eq(v3, "5df41881-3aed-3515-88a7-2f4a814cf09e")
  assert_eq(@id.uuid_version(v3), 3)
  // JDK 17 实跑读数（探针源码用 \u 转义写非 ASCII 输入，避开 javac 的 GBK 源码解码）
  assert_eq(@id.name_uuid("abc"), "90015098-3cd2-3fb0-9696-3f7d28e17f72")
  assert_eq(@id.name_uuid("中文"), "a7bac223-9fcd-3b3a-8679-03d8077c4a07")
  assert_true(v3 != @id.name_uuid("www.example.com"))
}
```

`uuid_v4` 的注入版是纯函数（所以能冻结期望值）；位改写只有两处：`rand[6] = (rand[6] & 0x0f) | 0x40`、`rand[8] = (rand[8] & 0x3f) | 0x80`。

```mbt check
///|
test "注入 16 字节的 v4" {
  let g : (Array[Byte]) -> String = xs => {
    @id.uuid_v4(Bytes::from_array(xs.exact_view())) catch {
      _ => abort("夹具必须给满 16 字节")
    }
  }
  assert_eq(
    g([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
    "00010203-0405-4607-8809-0a0b0c0d0e0f",
  )
  assert_eq(
    g([
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255,
    ]),
    "ffffffff-ffff-4fff-bfff-ffffffffffff",
  )
  let four : Array[Byte] = [0, 1, 2, 3]
  let short = try {
    let _ = @id.uuid_v4(Bytes::from_array(four.exact_view()))
    "未抛错"
  } catch {
    @id.EntropyTooShort(need, got) => "EntropyTooShort \{need}/\{got}"
    _ => "错种"
  }
  assert_eq(short, "EntropyTooShort 16/4")
}
```

```mbt check
///|
test "取不到熵就失败，绝不静默回落固定种子" {
  let out = @id.uuid_v4_random() catch {
    @id.NoEntropy => "no-entropy"
    _ => "其它错误"
  }
  // 本机实测：wasm 档有真熵、wasm-gc 档 env.rand 给 None ⇒ 两种结果都合法，静默给固定值才不合法
  assert_true(out == "no-entropy" || (out.length() == 36 && out[14] == '4'))
}
```

## ObjectId

hutool 的布局实测是**三个大端 Int32**：`[4 字节秒][4 字节 machine][4 字节 counter]`。注意这与 MongoDB 官方的"4 秒 + 5 随机 + 3 计数器"切法**不同**——本库照 hutool，因为要互解的是 Java 侧生成的值。

```mbt check
///|
test "组一个并解回时间戳" {
  let id = @id.object_id(1759552496L, 305419896L, 2596069104L) catch {
    _ => abort("夹具参数必须合法")
  }
  assert_eq(id, "68e0a3f0123456789abcdef0")
  assert_eq(@id.object_id_timestamp(id), 1759552496L)
  // 只写低 32 位：2^32 + 100 环绕成 100（与 hutool putInt((int) 秒) 同行为）
  assert_eq(
    @id.object_id(4294967396L, 1L, 2L) catch {
      _ => abort("夹具参数必须合法")
    },
    "000000640000000100000002",
  )
  // 带连字符的串 hutool 判真（它先去掉 `-`），本库判假
  assert_eq(@id.is_object_id("68e0a3f0-1234-5678-9abc-def0"), false)
  assert_eq(@id.is_object_id("68e0a3f0123456789abcdef0"), true)
}
```

## NanoId

⚠ **表序与 npm `nanoid` 不同**：hutool 的默认表把 `_`、`-` 放在最前，然后数字、小写、大写。表序直接决定读数，跨栈互解必须选边。

```mbt check
///|
test "注入版逐字节确定" {
  let g : (String, Int, Array[Byte]) -> String = (alphabet, size, xs) => {
    @id.nano_id(alphabet, size, Bytes::from_array(xs.exact_view())) catch {
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
  // 非 2 的幂表会有拒绝：mask=3，索引 3 越表被丢
  assert_eq(g("abc", 4, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]), "abca")
}
```

调用方要自己凑注入字节数，所以 hutool 内部那个 `step` 在这里是公开的：

```mbt check
///|
test "凑多少随机字节" {
  let n : (Int, Int) -> Int = (len, size) => {
    @id.nano_id_bytes_needed(len, size) catch {
      _ => abort("夹具表长必须合法")
    }
  }
  assert_eq(@id.nano_id_alphabet.char_length(), 64)
  assert_eq(n(64, 21), 34)
  assert_eq(n(3, 8), 13)
  assert_eq(n(1, 5), 8) // len==1 时 Java 的式子退化，mask=1
}
```

## 这一层不做的事

UUID v1/v2（要 MAC、node、clock sequence，全需 FFI）、v5（要 SHA-1，在 `digest` 的下一批）、v6/v7/v8 草案档、`simpleUUID()` 去连字符（就是 `replace("-", "")`，写了就是转发层）、hutool 的 `fastUUID()`（非安全随机档）、ObjectId 的 `withHyphen` 输出档、NanoId 的 `randomSequenceLimit`（把随机藏进状态机会让它不可测）。逐条理由见 [`docs/ROADMAP.md`](https://github.com/mldong/moon-hutool/blob/master/docs/ROADMAP.md)。
