///|
// cache 默认档补档（10-08）——命中档、空表档、remove 缺键档、prune 过期档此前一条用例都没打到
// （既有测试全走 fifo/lfu 的踢出与公平减计那几支）。
// 期望全部由 Cache2Leg.java 现读灌入（hutool-cache 5.8.35 · JDK 17.0.14），手打零条。
// 本库时钟由调用方显式传 now（参照读墙钟），所以每条都写明用的时刻。

///|
test "cache 默认档 hit-get" {
  // put 之后 get 命中 ｜ 参照=1 ｜ 缺键参照=null
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.CachePolicy::Lru,
    4,
    0L,
  )
  @cache.Cache::put(c, "a", 1, 0L)
  @cache.Cache::put(c, "b", 2, 0L)
  assert_eq(c.get("a", 0L), Some(1))
  assert_eq(c.get("zz", 0L), None)
}

///|
test "cache 默认档 hit-get_or_put" {
  // get_or_put：缺键走 supplier、命中不回表 ｜ 参照 get(k, Func0) 缺键=42 命中=1
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.CachePolicy::Lru,
    4,
    0L,
  )
  @cache.Cache::put(c, "a", 1, 0L)
  assert_eq(c.get_or_put("cc", 0L, () => 42), 42)
  assert_eq(c.get_or_put("a", 0L, () => 99), 1)
}

///|
test "cache 默认档 empty-lru" {
  // 新建未写入 ｜ 参照 isEmpty=true size=0
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.CachePolicy::Lru,
    4,
    10L,
  )
  assert_eq(c.is_empty(), true)
  assert_eq(c.size(), 0)
}

///|
test "cache 默认档 empty-timed" {
  // 新建未写入 ｜ 参照 isEmpty=true size=0
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.CachePolicy::Timed,
    4,
    10L,
  )
  assert_eq(c.is_empty(), true)
  assert_eq(c.size(), 0)
}

///|
test "cache 默认档 remove-missing" {
  // remove 不存在的键 ｜ 参照 remove 后 size=1 a=1 containsKey=false
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.CachePolicy::Lru,
    4,
    0L,
  )
  @cache.Cache::put(c, "a", 1, 0L)
  c.remove("nope")
  assert_eq(c.size(), 1)
  assert_eq(c.get("a", 0L), Some(1))
  assert_eq(c.contains_key("nope", 0L), false)
}

///|
test "cache 默认档 prune-timed" {
  // Timed ttl=10，t=0 写两条，t=30 prune ｜ 参照 prune=2 size=0 get=null isEmpty=true
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.CachePolicy::Timed,
    8,
    10L,
  )
  @cache.Cache::put(c, "a", 1, 0L)
  @cache.Cache::put(c, "b", 2, 0L)
  assert_eq(c.prune(30L), 2)
  assert_eq(c.size(), 0)
  assert_eq(c.get("a", 30L), None)
  assert_eq(c.is_empty(), true)
}

///|
test "cache 默认档 prune-lru" {
  // Lru 且 timeout=0（腿用的是 newLRUCache(4)，无缺省超时）推进到 t=30 ｜ 参照 prune=0 size=1 a=1 isEmpty=false
  let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(
    @cache.CachePolicy::Lru,
    4,
    0L,
  )
  @cache.Cache::put(c, "a", 1, 0L)
  assert_eq(c.prune(30L), 0)
  assert_eq(c.size(), 1)
  assert_eq(c.get("a", 30L), Some(1))
  assert_eq(c.is_empty(), false)
}
