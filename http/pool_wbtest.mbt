// 池纯逻辑（不发网络）：client 类型、关线动作、时钟全是注入口——测试里 C=Int、
// discard 是计数桩、时钟是假钟（G18 口径）。真连接的复用行为由 live 档的 accepts
// 计数验收（issue #5 的正向/负向档都在那里）。

///|
fn close_counter() -> (Array[Int32], (Int32) -> Unit) {
  let closed : Array[Int32] = []
  let record = fn(x : Int32) { closed.push(x) }
  (closed, record)
}

///|
fn fake_clock(start : Int64) -> (Array[Int64], () -> Int64) {
  let now : Array[Int64] = [start]
  let read = fn() { now[0] }
  (now, read)
}

///|
test "checkout on empty pool is None; deposit then checkout returns the same handle" {
  let pool : Pool[Int32] = pool_new(4, 15000L, () => 1000L, fn(_) { () })
  assert_eq(pool.checkout("k"), None)
  pool.deposit("k", 7)
  assert_eq(pool.checkout("k"), Some(7))
  // 只有一条，第二条必须落空
  assert_eq(pool.checkout("k"), None)
}

///|
test "checkout is FIFO within a key" {
  let pool : Pool[Int32] = pool_new(4, 15000L, () => 1000L, fn(_) { () })
  pool.deposit("k", 1)
  pool.deposit("k", 2)
  assert_eq(pool.checkout("k"), Some(1))
  assert_eq(pool.checkout("k"), Some(2))
}

///|
test "expired idle lines are dropped at checkout, not handed out" {
  let (closed, discard) = close_counter()
  let (now, clock) = fake_clock(1000L)
  let pool : Pool[Int32] = pool_new(4, 500L, clock, discard)
  pool.deposit("k", 9)
  now[0] = 1601L
  assert_eq(pool.checkout("k"), None)
  assert_eq(closed.length(), 1)
  assert_eq(closed[0], 9)
}

///|
test "deposit above per-key cap evicts the oldest" {
  let (closed, discard) = close_counter()
  let pool : Pool[Int32] = pool_new(2, 15000L, () => 1000L, discard)
  pool.deposit("k", 1)
  pool.deposit("k", 2)
  // 第三条进池触发淘汰：最旧的 1 被关
  pool.deposit("k", 3)
  assert_eq(closed.length(), 1)
  assert_eq(closed[0], 1)
  assert_eq(pool.checkout("k"), Some(2))
  assert_eq(pool.checkout("k"), Some(3))
}

///|
test "keys do not bleed into each other" {
  let pool : Pool[Int32] = pool_new(4, 15000L, () => 1000L, fn(_) { () })
  pool.deposit("https://a.example:443@@ua/1", 7)
  assert_eq(pool.checkout("https://b.example:443@@ua/1"), None)
  assert_eq(pool.checkout("https://a.example:443@@ua/2"), None)
  assert_eq(pool.checkout("https://a.example:443@@ua/1"), Some(7))
}

///|
test "max_idle_per_origin <= 0 means this key never pools" {
  let (closed, discard) = close_counter()
  let pool : Pool[Int32] = pool_new(0, 15000L, () => 1000L, discard)
  pool.deposit("k", 5)
  assert_eq(closed.length(), 1)
  assert_eq(pool.checkout("k"), None)
}

///|
test "drain closes everything and empties the pool" {
  let (closed, discard) = close_counter()
  let pool : Pool[Int32] = pool_new(4, 15000L, () => 1000L, discard)
  pool.deposit("k", 1)
  pool.deposit("k", 2)
  pool.drain()
  assert_eq(closed.length(), 2)
  assert_eq(pool.checkout("k"), None)
}
