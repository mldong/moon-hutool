///|
// cache 第一批的期望值全部由脚本从参照腿读数灌入（`cache_ref.txt` 123 条 + `cache_ref2.txt` 23 条），
// 手打零条。参照腿：`hutool-cache-5.8.35.jar`（**hutool-core 的 jar 里没有 `cn/hutool/cache`**，
// 与 `dfa` 轮同一条"先 unzip 现读再决定从哪取"）+ `hutool-core-5.8.35.jar` + 本机 JDK 17.0.14，
// `javac -encoding UTF-8`。
// 这批 10 块落地后全绿，期望值一字未动：契约笔 `a0e49a` 冻的样子里每条 `assert_*` 的右侧都与参照腿读数同形，
// 落地笔只把函数体从骨架换成实现（`.mbti` 只前进 `mut` 字段这一档形状，公开函数签名一字未改）。
//
// **本包一律显式传 `now`**（`Int64` 毫秒）：参照实现在 `CacheObj` 构造、判过期、`get` 刷新三处读
// `System.currentTimeMillis()`，wasm / js 档没有读当前时间的入口。于是参照腿里所有靠
// `Thread.sleep` 造出来的"过期/未过期"，在这里都换成确定的时间差——同一个算术，两条腿可以并排读
// （`fifo.expired_*` / `timed.*` 那几条是 sleep 腿，spec §4 记了两边的量）。

///|
// 档位归一成档名（本包不给 `CachePolicy` 派生 Eq/Show，避免走上 `extends.mbt` 那条隐式提升）
fn policy_tag(p : @cache.CachePolicy) -> String {
  match p {
    @cache.Fifo => "Fifo"
    @cache.Lru => "Lru"
    @cache.Lfu => "Lfu"
    @cache.Timed => "Timed"
    @cache.No => "No"
  }
}

///|
// 把条目归化成 `键=访问数:ttl`，顺序按本库承诺的内部序（插入序 / LRU 的访问序）。
fn dump(objs : Array[@cache.CacheObj[String, Int]]) -> Array[String] {
  let out : Array[String] = []
  for co in objs {
    out.push("\{co.key}=\{co.access_count}:\{co.ttl}")
  }
  out
}

///|
test "cache fifo 满员淘汰与插入序（读不重排）" {
  // 参照读数：fifo.size3|3, fifo.is_full3|true, fifo.capacity|3, fifo.timeout|0,
  //          fifo.keys|a,b,c, fifo.values|1,2,3, fifo.iter_after_4th|b,c,d,
  //          fifo.get_evicted|null + fifo.hit_miss|0/1, fifo.hit_miss_after_get|1/1,
  //          fifo.iter_order_after_get|b,c,d, fifo.get_false_flag_value|2
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Fifo,
    3,
    0L,
  )
  c.put("a", 1, 1000L)
  c.put("b", 2, 1001L)
  c.put("c", 3, 1002L)
  assert_eq(c.size(), 3)
  assert_true(c.is_full())
  assert_eq(c.capacity(), 3)
  assert_eq(c.timeout(), 0L)
  assert_eq(c.keys(), ["a", "b", "c"])
  assert_eq(c.values(), [1, 2, 3])
  c.put("d", 4, 1003L)
  assert_eq(c.size(), 3)
  assert_eq(c.keys(), ["b", "c", "d"])
  assert_eq(c.get("a", 1004L), None)
  assert_eq(c.hit_count(), 0)
  assert_eq(c.miss_count(), 1)
  assert_eq(c.get("b", 1005L), Some(2))
  assert_eq(c.hit_count(), 1)
  assert_eq(c.keys(), ["b", "c", "d"]) // 读不改变 FIFO 的内部序
  assert_eq(c.peek("b", 1006L), Some(2))
  assert_eq(c.keys(), ["b", "c", "d"])
}

///|
test "cache fifo 覆盖已有键不淘汰、remove 回调、clear 不回调" {
  // 参照读数：fifo.replace_existing_size|3, fifo.replace_existing_keys|b,c,d,
  //          fifo.replace_existing_listener|（空）, fifo.listener_on_evict|a=1,
  //          fifo.remove_listener|a=1, fifo.remove_size|1, fifo.clear_listener|（空）
  let log : Array[String] = []
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Fifo,
    3,
    0L,
  )
  c.set_listener((k, v) => log.push("\{k}=\{v}"))
  c.put("a", 1, 1000L)
  c.put("b", 2, 1001L)
  c.put("c", 3, 1002L)
  assert_eq(log.length(), 0)
  c.put("d", 4, 1003L)
  assert_eq(log, ["a=1"]) // 满员踢队首会回调
  c.put("c", 9, 1004L) // 覆盖已有键：不淘汰、不再回调
  assert_eq(c.size(), 3)
  assert_eq(c.keys(), ["b", "c", "d"])
  assert_eq(c.values(), [2, 9, 4])
  assert_eq(log, ["a=1"])
  c.remove("b")
  assert_eq(log, ["a=1", "b=2"])
  assert_eq(c.size(), 2)
  c.clear()
  assert_eq(c.size(), 0)
  assert_eq(log, ["a=1", "b=2"]) // clear 不逐条回调
}

///|
test "cache prune 的三档差异：fifo 踢队首、lru 只扫过期、lfu 公平减计" {
  // 参照读数：fifo.prune_full_count|1, fifo.prune_full_left|b, fifo.prune_again_count|0,
  //          lru.prune_ttl0|0 + lru.size_after_prune|3,
  //          lfu.prune_while_full_before|3, lfu.prune_while_full_count|2,
  //          lfu.prune_while_full_after|1, lfu.prune_while_full_keys|a
  let f : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Fifo,
    2,
    0L,
  )
  f.put("a", 1, 1000L)
  f.put("b", 2, 1001L)
  assert_eq(f.prune(1002L), 1) // 没过期也踢队首：满着就得清
  assert_eq(f.keys(), ["b"])
  assert_eq(f.prune(1003L), 0) // 已经不满，不再踢

  let r : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.Lru, 3, 0L)
  r.put("a", 1, 1000L)
  r.put("b", 2, 1001L)
  r.put("c", 3, 1002L)
  assert_eq(r.prune(1003L), 0)
  assert_eq(r.size(), 3)

  let l : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.Lfu, 3, 0L)
  l.put("a", 1, 1000L)
  l.put("b", 2, 1001L)
  l.put("c", 3, 1002L)
  assert_eq(l.get("a", 1003L), Some(1))
  assert_eq(l.size(), 3)
  assert_eq(l.prune(1004L), 2) // 最小访问数是 0 ⇒ 减完仍 <=0 的两条一起删
  assert_eq(l.keys(), ["a"])
}

///|
test "cache lfu 的公平减计三条形状" {
  // 参照读数：lfu.allzero_size|1 + lfu.allzero_keys|d + lfu.allzero_counts|d=0:0,
  //          lfu.sorted_size|3 + lfu.sorted_keys|a,b,d + lfu.sorted_counts|a=2:0,b=1:0,d=0:0,
  //          lfu.equal_counts_size|1 + lfu.equal_counts_keys|d
  let c1 : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Lfu,
    3,
    0L,
  )
  c1.put("a", 1, 1000L)
  c1.put("b", 2, 1001L)
  c1.put("c", 3, 1002L)
  c1.put("d", 4, 1003L) // 三条计数都是 0 ⇒ 全被删，只剩新来的
  assert_eq(c1.size(), 1)
  assert_eq(c1.keys(), ["d"])
  assert_eq(dump(c1.cache_objs()), ["d=0:0"])

  let c2 : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Lfu,
    3,
    0L,
  )
  c2.put("a", 1, 1000L)
  c2.put("b", 2, 1001L)
  c2.put("c", 3, 1002L)
  let _ = c2.get("a", 1003L)
  let _ = c2.get("a", 1004L)
  let _ = c2.get("b", 1005L)
  c2.put("d", 4, 1006L)
  assert_eq(c2.size(), 3)
  assert_eq(c2.keys(), ["a", "b", "d"])
  assert_eq(dump(c2.cache_objs()), ["a=2:0", "b=1:0", "d=0:0"])

  let c3 : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Lfu,
    3,
    0L,
  )
  c3.put("a", 1, 1000L)
  c3.put("b", 2, 1001L)
  c3.put("c", 3, 1002L)
  let _ = c3.get("a", 1003L)
  let _ = c3.get("b", 1004L)
  let _ = c3.get("c", 1005L)
  c3.put("d", 4, 1006L) // 三条同为 1 ⇒ 一起减到 0、一起删
  assert_eq(c3.size(), 1)
  assert_eq(c3.keys(), ["d"])
}

///|
test "cache lru 访问序：get/peek/覆盖都会移动，踢最久未读的那条" {
  // 参照读数：lru.iter_after_get_a|b,c,a, lru.keys_after_4th|a,c,d, lru.iter_after_4th|c,a,d,
  //          lru.order_after_get_b|a,c,b, lru.order_after_replace_a|c,b,a, lru.order_after_4th|b,a,d,
  //          lru.get_false_still_reorders_iter|c,a,d, lru.evict_is|b
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.Lru, 3, 0L)
  c.put("a", 1, 1000L)
  c.put("b", 2, 1001L)
  c.put("c", 3, 1002L)
  let _ = c.get("b", 1003L)
  assert_eq(c.keys(), ["a", "c", "b"])
  c.put("a", 9, 1004L) // 覆盖也算一次访问 ⇒ 移到最近端
  assert_eq(c.keys(), ["c", "b", "a"])
  c.put("d", 4, 1005L)
  assert_eq(c.keys(), ["b", "a", "d"])
  assert_eq(c.get("c", 1006L), None)
  assert_eq(c.get("a", 1007L), Some(9))

  let p : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.Lru, 3, 0L)
  p.put("a", 1, 1000L)
  p.put("b", 2, 1001L)
  p.put("c", 3, 1002L)
  assert_eq(p.peek("a", 1003L), Some(1)) // peek 不刷新过期窗口，但仍改变访问序
  assert_eq(p.keys(), ["b", "c", "a"])
  p.put("d", 4, 1004L)
  assert_eq(p.keys(), ["c", "a", "d"])
  assert_eq(p.get("b", 1005L), None)
}

///|
test "cache 过期算术：严格大于才过期、ttl<=0 永不过期、命中会刷新窗口" {
  // 参照读数：fifo.expired_prune_count|1, fifo.expired_get|null + …size_after_get|0,
  //          fifo.zero_ttl_alive|1, fifo.neg_ttl_alive|1 + fifo.neg_ttl_prune|0,
  //          timed.sliding_mid|1 + timed.alive_after_refresh|1 + timed.dead_after_window|null
  // 判据（源码 CacheObj.isExpired）：ttl > 0 && now - last_access > ttl —— 相等不算过期。
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Timed,
    0,
    100L,
  )
  c.put("a", 1, 1000L)
  assert_eq(c.peek("a", 1100L), Some(1)) // 恰好 100：未过期
  assert_eq(c.peek("a", 1101L), None) // 101 > 100：过期，并顺手删掉
  assert_eq(c.size(), 0)

  let z : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Timed,
    0,
    0L,
  )
  z.put("a", 1, 1000L)
  assert_eq(z.get("a", 4102444800000L), Some(1)) // ttl=0 永久
  assert_eq(z.prune(4102444800000L), 0)

  let n : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Timed,
    0,
    -5L,
  )
  n.put("a", 1, 1000L)
  assert_eq(n.get("a", 4102444800000L), Some(1)) // **负数不是"立即过期"，是"不过期"**
  assert_eq(n.prune(4102444800000L), 0)

  let s : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Timed,
    0,
    100L,
  )
  s.put("d", 1, 1000L)
  assert_eq(s.get("d", 1090L), Some(1)) // 命中把窗口挪到 1090
  assert_eq(s.get("d", 1180L), Some(1)) // 90 <= 100：因为刷新过才还活着
  assert_eq(s.get("d", 1290L), None) // 距 1180 已 110 > 100
  assert_eq(s.size(), 0)
}

///|
test "cache contains_key 只清被查的那条、不计命中也不加访问数" {
  // 参照读数：fifo.hit_miss_after_containsKey|0/1, fifo.expired_containsKey|false +
  //          fifo.expired_size_after_containsKey|0, lfu.count_after_containsKey|a=0:0,
  //          fifo.containsKey_missing_size|false/1
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Lru,
    3,
    100L,
  )
  c.put("a", 1, 1000L)
  assert_true(c.contains_key("a", 1050L))
  assert_eq(c.hit_count(), 0)
  assert_eq(c.miss_count(), 0)
  assert_eq(dump(c.cache_objs()), ["a=0:100"]) // 没被计数，也没刷新 last_access

  c.put("b", 2, 1050L)
  assert_false(c.contains_key("b", 1200L)) // b 过期（150 > 100）被删
  assert_eq(c.size(), 1) // a 仍留着：contains_key 只处理被查的那条
  assert_eq(c.keys(), ["a"])
  assert_false(c.contains_key("z", 1210L))
  assert_eq(c.miss_count(), 0)
}

///|
test "cache get_or_put 的两次 miss 与 supplier 造出来的那条" {
  // 参照读数：lru.supplier_value|S, lru.supplier_calls|1, lru.supplier_stored_size|2,
  //          lru.supplier_hitmiss|0/2（外层取一次 + 装回后再取一次，两笔都记 miss）,
  //          lru.supplier_hitmiss_second|1/2 calls=1,
  //          lru.supplier_custom_ttl_counts|a=0:0,x=1:0,y=0:100, lru.supplier_ttl_inherited|0
  let calls : Array[Int] = []
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.Lru, 3, 0L)
  c.put("a", 1, 1000L)
  assert_eq(
    c.get_or_put("x", 1001L, () => {
      calls.push(1)
      99
    }),
    99,
  )
  assert_eq(calls.length(), 1)
  assert_eq(c.size(), 2)
  assert_eq(c.keys(), ["a", "x"])
  assert_eq(c.hit_count(), 0)
  assert_eq(c.miss_count(), 2)
  assert_eq(
    c.get_or_put("x", 1002L, () => {
      calls.push(2)
      100
    }),
    99,
  )
  assert_eq(calls.length(), 1) // 命中就不再造
  assert_eq(c.hit_count(), 1)
  assert_eq(c.miss_count(), 2)
  assert_eq(c.get_or_put_ttl("y", 1003L, 100L, () => 7), 7)
  assert_eq(dump(c.cache_objs()), ["a=0:0", "x=1:0", "y=0:100"]) // "造"不算"读"
  assert_eq(c.timeout(), 0L) // 单条时长不改缓存默认值
}

///|
test "cache timed 不限容量 / no 档全空转" {
  // 参照读数：timed.capacity|0, timed.is_full|false, timed.size4|4, timed.prune_ttl0|0,
  //          no.capacity|0/timeout|0/size|0/is_full|false/containsKey|false/get|null/prune|0,
  //          no.supplier|S + no.supplier_size|0
  let t : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Timed,
    2,
    0L,
  )
  assert_eq(t.capacity(), 0) // Timed 档忽略构造参数
  // 五档各建一个，`policy()` 要能读回自己那一档（参照实现靠具体类型区分，本库收成一种类型 + 一件 getter）
  let ps : Array[@cache.CachePolicy] = [
    @cache.Fifo,
    @cache.Lru,
    @cache.Lfu,
    @cache.Timed,
    @cache.No,
  ]
  let tags : Array[String] = []
  for p in ps {
    let one : @cache.Cache[String, Int] = @cache.Cache::new_cache(p, 0, 0L)
    tags.push(policy_tag(one.policy()))
  }
  assert_eq(tags, ["Fifo", "Lru", "Lfu", "Timed", "No"])
  t.put("a", 1, 1000L)
  t.put("b", 2, 1001L)
  t.put("c", 3, 1002L)
  t.put("d", 4, 1003L)
  assert_eq(t.size(), 4)
  assert_false(t.is_full())
  assert_eq(t.prune(1004L), 0)
  assert_eq(t.keys(), ["a", "b", "c", "d"])

  let n : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.No,
    3,
    100L,
  )
  n.put("a", 1, 1000L)
  assert_eq(n.size(), 0)
  assert_eq(n.capacity(), 0)
  assert_eq(n.timeout(), 0L)
  assert_false(n.is_full())
  assert_false(n.contains_key("a", 1001L))
  assert_eq(n.get("a", 1002L), None)
  assert_eq(n.prune(1003L), 0)
  assert_eq(n.keys(), [])
  assert_eq(n.values(), [])
  assert_eq(n.cache_objs().length(), 0) // 参照侧 NoCache.cacheObjIterator() 返回 null，本库给空数组
  assert_eq(n.get_or_put("b", 1004L, () => 5), 5) // 造得出来，但存不下
  assert_eq(n.size(), 0)
}

///|
test "cache capacity==0 一律是不限容量（本库把 lru/lfu 那一档统一到 fifo）" {
  // 参照读数（分岔两侧）：fifo.cap0_size|5 + fifo.cap0_is_full|false 对
  //          lru.cap0_size|0 + lru.cap0_keys|（空）+ lru.cap0_listener|a=1 + lru.cap0_get|null
  // AbstractCache.isFull 判 `capacity > 0 && …`（0 = 不限），而 LRU/LFU 的 map
  // 用 `size > capacity` 逐条踢——同一份代码里两套说法。本库取 `0 = 不限容量`，
  // 于是"放进去立刻被淘汰"那次回调也不存在（spec §5 分岔表第 2 行）。
  let f : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.Fifo,
    0,
    0L,
  )
  for i in 0..<5 {
    f.put("k\{i}", i, 1000L)
  }
  assert_eq(f.size(), 5)
  assert_false(f.is_full())

  let r : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.Lru, 0, 0L)
  let log : Array[String] = []
  r.set_listener((k, v) => log.push("\{k}=\{v}"))
  r.put("a", 1, 1000L)
  assert_eq(r.size(), 1)
  assert_eq(r.keys(), ["a"])
  assert_eq(r.get("a", 1001L), Some(1))
  assert_eq(log.length(), 0) // 没有"装进去就被淘汰"那次回调

  let l : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.Lfu, 0, 0L)
  l.put("a", 1, 1000L)
  l.put("b", 2, 1001L)
  assert_eq(l.prune(1002L), 0) // 不满 ⇒ 不做公平减计
  assert_eq(l.size(), 2)
}
