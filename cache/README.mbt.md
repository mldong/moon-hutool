# moon-hutool/cache

有界 / 有过期时间的键值缓存，对位 hutool **`hutool-cache`** 模块的
`Cache` + `FIFOCache`/`LRUCache`/`LFUCache`/`TimedCache`/`NoCache`。
契约：[`docs/spec/16-cache.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/16-cache.md)。

一句话定位：**五档淘汰策略收成一个类型，时钟由调用方给**。本库没有墙钟——参照实现每处判过期都读
`System.currentTimeMillis()`，而 wasm / js 档没有读当前时间的入口，所以凡是要看时钟的操作
（`put`/`get`/`peek`/`contains_key`/`prune`）都把 `now : Int64` 显式传进来。用例因此零计时依赖。

## 五档与 FIFO 的淘汰

```mbt check
///|
test "cache 五档一览与 FIFO 踢队首" {
  let f : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Fifo,
    3,
    0L,
  )
  f.put("a", 1, 1000L)
  f.put("b", 2, 1001L)
  f.put("c", 3, 1002L)
  assert_eq(f.keys(), ["a", "b", "c"])
  f.put("d", 4, 1003L)
  // 满员踢**先入**的那条，读操作不改变插入序
  assert_eq(f.keys(), ["b", "c", "d"])
  assert_eq(f.get("a", 1004L), None)
  assert_eq(f.miss_count(), 1)
  assert_eq(f.get("b", 1005L), Some(2))
  assert_eq(f.keys(), ["b", "c", "d"])
}
```

`capacity == 0` 一律是"不限容量"。参照实现这里有两套说法（`AbstractCache.isFull` 判 `capacity > 0`，
而 LRU 的 `FixedLinkedHashMap` 判 `size > capacity`，于是 `capacity=0` 的 LRU 放进去就立刻被淘汰），
本库统一到前者——分岔两侧读数都记在 spec §5。

## LRU：任何一次读都算"最近使用"

```mbt check
///|
test "cache LRU 的访问序由读决定，peek 也不例外" {
  let r : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.Lru, 3, 0L)
  r.put("a", 1, 1000L)
  r.put("b", 2, 1001L)
  r.put("c", 3, 1002L)
  assert_eq(r.peek("a", 1003L), Some(1))
  // 不刷新过期窗口 ≠ 不移动淘汰序：a 已经是"最近使用"
  assert_eq(r.keys(), ["b", "c", "a"])
  r.put("d", 4, 1004L)
  assert_eq(r.keys(), ["c", "a", "d"])
  assert_eq(r.get("b", 1005L), None)
  // 覆盖已有键同样算一次访问
  r.put("c", 9, 1006L)
  assert_eq(r.keys(), ["a", "d", "c"])
}
```

## 过期只有一条算式

```mbt check
///|
test "cache 过期算术：相等不算过期，ttl<=0 永不过期，命中会挪窗口" {
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Timed,
    0,
    100L,
  )
  c.put("a", 1, 1000L)
  assert_eq(c.peek("a", 1100L), Some(1)) // 100 == ttl：还没过
  assert_eq(c.peek("a", 1101L), None) // 101 > ttl：过期，并顺手删掉这一条
  assert_eq(c.size(), 0)
  // 负数不是"立即过期"，参照侧判的是 `ttl > 0`，所以它表示"不过期"
  let n : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Timed,
    0,
    -5L,
  )
  n.put("a", 1, 1000L)
  assert_eq(n.get("a", 4102444800000L), Some(1))
  // get 命中会把 last_access 挪到 now ⇒ 滑动过期
  let s : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Timed,
    0,
    100L,
  )
  s.put("d", 1, 1000L)
  assert_eq(s.get("d", 1090L), Some(1))
  assert_eq(s.get("d", 1180L), Some(1)) // 距上次命中才 90
  assert_eq(s.get("d", 1290L), None)
}
```

`contains_key` 也走同一套过期判定（过期条目会被顺手删掉），但它**既不计命中/丢失、也不加访问数**。

## LFU 的公平减计与 No 档

```mbt check
///|
test "cache LFU 三条形状与 No 档空转" {
  // 三条计数全为 0 ⇒ 减完仍 <=0，一起删，只剩新来的那条
  let l : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.Lfu, 3, 0L)
  l.put("a", 1, 1000L)
  l.put("b", 2, 1001L)
  l.put("c", 3, 1002L)
  l.put("d", 4, 1003L)
  assert_eq(l.size(), 1)
  assert_eq(l.keys(), ["d"])
  // 有唯一最小值 ⇒ 只删它，其余计数原样
  let l2 : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Lfu,
    3,
    0L,
  )
  l2.put("a", 1, 1000L)
  l2.put("b", 2, 1001L)
  l2.put("c", 3, 1002L)
  assert_eq(l2.get("a", 1003L), Some(1))
  assert_eq(l2.get("a", 1004L), Some(1))
  assert_eq(l2.get("b", 1005L), Some(2))
  l2.put("d", 4, 1006L)
  assert_eq(l2.keys(), ["a", "b", "d"])
  let n : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.No,
    3,
    100L,
  )
  n.put("a", 1, 1000L)
  assert_eq(n.size(), 0)
  assert_eq(n.get_or_put("b", 1001L, () => 5), 5) // 造得出来，但存不下
  assert_eq(n.capacity(), 0) // No 档连容量与默认时长都归零
  assert_eq(n.timeout(), 0L)
}
```

`prune` 三档语义不同，这条最容易踩空：`Fifo` 是"扫过期 +（仍满则）踢队首"，`Lru`/`Timed` 是"只扫过期"，
`Lfu` 是"扫过期 +（仍满则）全体减去最小访问数、减后 `<= 0` 的一起删"。参照实现另有
`schedulePrune(delay)` 的后台定时清理，本库不建（实测它起的线程是**非守护**线程，属于线程语义而不是缓存语义），
清理一律走显式 `prune(now)`。
