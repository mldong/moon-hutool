///|
/// moon-hutool 的 `cache` —— 有界/有过期时间的键值缓存（hutool `cn.hutool.cache` 的 MoonBit 对位·第一批）。
///
/// 契约：`docs/spec/16-cache.md`；进度：`docs/ROADMAP.md`。这一批 23 件公开面已落地（契约笔 `a0e49a` 冻期望值，
/// 落地笔只换函数体；每条期望值都与参照腿 146 条读数同形，门禁 G5 对读落地笔）。
///
/// 对位参照实现：`cn.hutool.cache.Cache` 接口 + `AbstractCache`/`FIFOCache`/`LRUCache`/
/// `LFUCache`/`TimedCache`/`NoCache`——件在 **hutool-cache** 这个 artifact 里，hutool-core 的 jar 没有它。
///
/// - Note: 本包**没有墙钟**。参照实现每处判过期都读 `System.currentTimeMillis()`，
///   而 wasm / js 档没有可读当前时间的入口，所以凡是要看时钟的操作都把 `now` 作为参数显式传进来
///   （`put`/`get`/`peek`/`contains_key`/`prune`/`get_or_put*`）。这不是风格选择，是平台约束。
/// - Note: 单线程语义——参照实现的 `ReentrantLock`/`ReadWriteLock` 与
///   `schedulePrune`（守护线程）不进本契约，理由与证据在 spec §5。

///|
/// 淘汰策略。对位参照实现的五个具体类。
///
/// - `Fifo`：先进先出（`FIFOCache`），插入序，满了踢队首
/// - `Lru`：最久未使用（`LRUCache`），**访问序**——任何一次读（含 `peek`）都把键挪到最近端
/// - `Lfu`：最少使用（`LFUCache`），按访问计数淘汰，并做"公平减计"
/// - `Timed`：只按过期淘汰、不限容量（`TimedCache`）
/// - `No`：什么都不缓存（`NoCache`），用于一键关掉缓存
pub(all) enum CachePolicy {
  Fifo
  Lru
  Lfu
  Timed
  No
}

///|
/// 缓存里的一条记录。对位参照实现的 `CacheObj`。
///
/// 字段含义与参照实现一一对应，但 `last_access` 由调用方给的 `now` 决定（见本包头注）。
/// - `key`/`value`：原样存的键值
/// - `ttl`：本条的存活时长（毫秒）；`<= 0` 表示**永不过期**（参照实现判的是 `ttl > 0`，
///   所以负数不是"立即过期"而是"不过期"，读数 `fifo.neg_ttl_alive|1`）
/// - `last_access`：上次刷新时间；判过期用 `now - last_access > ttl`（**相等不算过期**）
/// - `access_count`：被读到的次数；`contains_key` **不**计数（读数 `lfu.count_after_containsKey`）
pub(all) struct CacheObj[K, V] {
  key : K
  value : V
  ttl : Int64
  mut last_access : Int64
  mut access_count : Int
}

///|
/// 有界缓存本体。用 `new_cache` 构造；字段是内部形状，不承诺手工拼装。
///
/// 泛型约束：键要能进 `Map`（`Hash + Eq`）。参照实现用 `MutableObj` 包键，
/// 那只是为了让"可变异对象"当 HashMap 的键，本包直接约束 `K : Hash + Eq`，语义等价。
pub struct Cache[K, V] {
  policy : CachePolicy
  capacity : Int
  timeout : Int64
  mut order : Array[K]
  mut entries : Map[K, CacheObj[K, V]]
  mut hit : Int
  mut miss : Int
  mut listener : ((K, V) -> Unit)?
}

///|
/// 建一个缓存。
///
/// - Parameters:
///   - `policy`：淘汰策略
///   - `capacity`：容量，`0` 表示**不限容量**（参照实现 `AbstractCache.isFull` 判
///     `capacity > 0 && size >= capacity`，读数 `fifo.cap0_size|5`）。
///     `Timed`/`No` 两档忽略这个参数、恒按 0（读数 `timed.capacity|0`）。
///   - `timeout`：默认存活时长（毫秒），`<= 0` 表示不过期；单条可用 `put_ttl` 覆盖。
/// - Note: 参照实现的 `LRUCache`/`LFUCache` 构造器对 `capacity == Int::MAX` 做了 `-1`
///   （`FixedLinkedHashMap`/`HashMap` 的 `capacity + 1` 会溢出），`FIFOCache` 没做、直接抛
///   `IllegalArgumentException`（读数 `fifo.capmax_throws`）。本库不做 map 预分配，
///   两档都不可能出现这个溢出，故**不跟**——这是容器实现细节，不是语义。
pub fn[K : Hash + Eq, V] Cache::new_cache(
  policy : CachePolicy,
  capacity : Int,
  timeout : Int64,
) -> Cache[K, V] {
  let cap = match policy {
    No => 0
    Timed => 0
    _ => capacity
  }
  // No 档连默认时长都不留：参照侧 NoCache.timeout() 恒 0
  let t0 = match policy {
    No => 0L
    _ => timeout
  }
  {
    policy,
    capacity: cap,
    timeout: t0,
    order: [],
    entries: Map([]),
    hit: 0,
    miss: 0,
    listener: None,
  }
}

///|
/// 放入一条，用缓存的默认 `timeout`。等价于 `put_ttl(cache, key, value, cache.timeout(), now)`。
///
/// - Parameters: `now` 作为这条记录的 `last_access`（参照实现在此读系统时钟）。
/// - Note: **覆盖已有键不做满判定**（参照实现 issue#3618 那一支）——满员时只在"新键"这条路上淘汰。
///   读数 `fifo.replace_existing_size|3`。
pub fn[K : Hash + Eq, V] Cache::put(
  self : Cache[K, V],
  key : K,
  value : V,
  now : Int64,
) -> Unit {
  self.put_ttl(key, value, self.timeout, now)
}

///|
/// 放入一条并指定这一条的存活时长（毫秒）。`ttl <= 0` 表示这条**永不过期**。
///
/// - Note: 只要 `ttl != 0`，参照实现就把缓存标记为"存在自定义时长"，从此 `prune` 会去扫过期项
///   （`isPruneExpiredActive`）。本库 `ttl < 0` 同样置该标记但不产生过期，读数是
///   `fifo.neg_ttl_prune|0`。
pub fn[K : Hash + Eq, V] Cache::put_ttl(
  self : Cache[K, V],
  key : K,
  value : V,
  ttl : Int64,
  now : Int64,
) -> Unit {
  match self.policy {
    No => ()
    _ => {
      let co : CacheObj[K, V] = {
        key,
        value,
        ttl,
        last_access: now,
        access_count: 0,
      }
      if self.entries.contains(key) {
        // 覆盖已有键：参照实现不做满判定（issue#3618 那一支），本库同
        self.entries.set(key, co)
        match self.policy {
          Lru => self.touch(key)
          _ => ()
        }
      } else {
        match self.policy {
          Lru => {
            self.entries.set(key, co)
            self.order.push(key)
            self.trim_lru()
          }
          Timed => {
            self.entries.set(key, co)
            self.order.push(key)
          }
          _ => {
            // Fifo / Lfu：只在"满着"的时候先跑一遍本档的 prune（含踢队首、公平减计）
            if self.is_full() {
              let _ = self.prune(now)
            }
            self.entries.set(key, co)
            self.order.push(key)
          }
        }
      }
    }
  }
}

///|
/// 取值，命中则**刷新** `last_access`（滑动过期）并计一次访问、一次命中。对位 `get(key)`。
///
/// - Note: 未命中计一次 `miss`；命中即把该条的 `last_access` 设成 `now`，于是过期窗口重新起算
///   （参照实现的实测腿 `timed.alive_after_refresh|1`）。
/// - Note: 顺带删除已过期条目（对位 `getOrRemoveExpired`）——读数是"取到 null 的同时 size 也掉了"：
///   `fifo.expired_size_after_get|0`。
pub fn[K : Hash + Eq, V] Cache::get(
  self : Cache[K, V],
  key : K,
  now : Int64,
) -> V? {
  self.get_at(key, now, true)
}

///|
/// 取值但**不刷新** `last_access`（对位 `get(key, false)`）。仍然计一次访问数。
///
/// - Note: 不刷新只影响过期窗口，不影响淘汰序——`Lru` 档一次读就把键挪到最近端这件事
///   由 Map 的访问序结构决定，参照实现连 `false` 档也照样重排（读数
///   `lru.get_false_still_reorders_iter|c,a,d`）。
pub fn[K : Hash + Eq, V] Cache::peek(
  self : Cache[K, V],
  key : K,
  now : Int64,
) -> V? {
  self.get_at(key, now, false)
}

///|
/// 取不到就用 `supplier` 造一个并存进去，存进去时用缓存默认时长。对位 `get(key, true, supplier)`。
///
/// - Note: 计数照参照实现——**未命中时 `miss` 加 2**（外层取一次、装回后再取一次），
///   读数 `lru.supplier_hitmiss|0/2`；第二次调用命中、`supplier` 不再被调（`…calls=1`）。
pub fn[K : Hash + Eq, V] Cache::get_or_put(
  self : Cache[K, V],
  key : K,
  now : Int64,
  supplier : () -> V,
) -> V {
  match self.get(key, now) {
    Some(x) => x
    None =>
      // 参照实现的双重检查（那一笔 miss 就是这么来的），第二次仍无值才造
      match self.get(key, now) {
        Some(x) => x
        None => {
          let x = supplier()
          self.put(key, x, now)
          x
        }
      }
  }
}

///|
/// 同 `get_or_put`，但存进去时用给定的 `ttl`。对位 `get(key, true, timeout, supplier)`。
///
/// - Note: 由 `supplier` 造出来的那条 `access_count` 是 0（"存"不算"读"），
///   读数 `lru.supplier_custom_ttl_counts` 里 `y=0:100`。
pub fn[K : Hash + Eq, V] Cache::get_or_put_ttl(
  self : Cache[K, V],
  key : K,
  now : Int64,
  ttl : Int64,
  supplier : () -> V,
) -> V {
  match self.get(key, now) {
    Some(x) => x
    None =>
      match self.get(key, now) {
        Some(x) => x
        None => {
          let x = supplier()
          self.put_ttl(key, x, ttl, now)
          x
        }
      }
  }
}

///|
/// 键是否存在且未过期。过期则**顺手删掉**，但**不计命中/丢失数**、也不加访问数。
///
/// 读数：`fifo.hit_miss_after_containsKey|0/1`、`fifo.expired_size_after_containsKey|0`、
/// `lfu.count_after_containsKey|a=0:0`。
pub fn[K : Hash + Eq, V] Cache::contains_key(
  self : Cache[K, V],
  key : K,
  now : Int64,
) -> Bool {
  match self.entries.get(key) {
    None => false
    Some(co) =>
      if is_expired(co, now) {
        self.drop(key, false)
        false
      } else {
        // 不记命中/丢失，也不加访问数（spec §3 第 3 条）
        true
      }
  }
}

///|
/// 删一条，并触发移除回调。对位 `remove(key)`（参照实现返回 `void`，本库同）。
///
/// 读数 `fifo.remove_listener|a=1`。
pub fn[K : Hash + Eq, V] Cache::remove(self : Cache[K, V], key : K) -> Unit {
  self.drop(key, true)
}

///|
/// 清空。**不触发**移除回调——参照实现的 `clear()` 直接 `cacheMap.clear()`，不走 `onRemove`。
///
/// 读数 `fifo.clear_listener|`（空串）。
pub fn[K : Hash + Eq, V] Cache::clear(self : Cache[K, V]) -> Unit {
  self.entries = Map([])
  self.order = []
}

///|
/// 主动清理，返回删掉的条数。各档语义不同，这条是本契约最容易踩空的地方：
///
/// - `Fifo`：先扫过期，**若清理后仍是满的**再踢队首一条（读数 `fifo.prune_ttl0|1`、
///   `fifo.prune_full_count|1` → `fifo.prune_again_count|0`）
/// - `Lru`：只扫过期（读数 `lru.prune_ttl0|0`）
/// - `Lfu`：先扫过期并找出访问数最小的一条；若仍是满的，把**所有**条目的计数减去那个最小值，
///   减完 `<= 0` 的一律删掉（读数 `lfu.prune_while_full_count|2`）
/// - `Timed`：只扫过期（读数 `timed.prune_count|2`）
/// - `No`：恒 0
/// - Note: 参照实现另有 `schedulePrune(delay)`（守护线程定时清），本库不建，理由见 spec §5。
pub fn[K : Hash + Eq, V] Cache::prune(self : Cache[K, V], now : Int64) -> Int {
  match self.policy {
    No => 0
    Lru => self.sweep(now)
    Timed => self.sweep(now)
    Fifo => {
      let n = self.sweep(now)
      // 清理完仍是满的，再踢队首一条
      if self.is_full() && self.order.length() > 0 {
        self.drop(self.order[0], true)
        n + 1
      } else {
        n
      }
    }
    Lfu => {
      let n = self.sweep(now)
      if self.is_full() {
        let min_count = self.min_access_count()
        if min_count is Some(mc) {
          // 公平减计：全体减去最小值，减完 <= 0 的一起删
          let ks = self.keys()
          let mut count = n
          for k in ks {
            match self.entries.get(k) {
              None => ()
              Some(co) => {
                co.access_count = co.access_count - mc
                if co.access_count <= 0 {
                  self.drop(k, true)
                  count = count + 1
                }
              }
            }
          }
          count
        } else {
          n
        }
      } else {
        n
      }
    }
  }
}

///|
/// 当前条数。对位 `size()`。
pub fn[K, V] Cache::size(self : Cache[K, V]) -> Int {
  self.entries.length()
}

///|
/// 是否为空。本库一律等于 `size() == 0`。
///
/// - Note: 参照实现的 `NoCache.isEmpty()` 返回 **false**（而 `size()` 是 0），
///   这是它自相矛盾的一处，本库**不跟**，两侧读数记在 spec §5 分岔表。
pub fn[K, V] Cache::is_empty(self : Cache[K, V]) -> Bool {
  self.entries.length() == 0
}

///|
/// 是否已满：`capacity > 0 && size >= capacity`（读数 `fifo.is_full3|true`、
/// `fifo.cap0_is_full|false`、`timed.is_full|false`）。
pub fn[K, V] Cache::is_full(self : Cache[K, V]) -> Bool {
  self.capacity > 0 && self.entries.length() >= self.capacity
}

///|
/// 容量（`0` = 不限）。对位 `capacity()`。
pub fn[K, V] Cache::capacity(self : Cache[K, V]) -> Int {
  self.capacity
}

///|
/// 默认存活时长（毫秒）。对位 `timeout()`。
pub fn[K, V] Cache::timeout(self : Cache[K, V]) -> Int64 {
  self.timeout
}

///|
/// 本缓存的淘汰策略。参照实现没有这个 getter（靠具体类型区分），本库补一件，
/// 因为五档收成了一个 `Cache` 类型。
pub fn[K, V] Cache::policy(self : Cache[K, V]) -> CachePolicy {
  self.policy
}

///|
/// 命中次数（`get`/`peek` 计，`contains_key` 不计）。对位 `AbstractCache.getHitCount()`。
pub fn[K, V] Cache::hit_count(self : Cache[K, V]) -> Int {
  self.hit
}

///|
/// 未命中次数。对位 `AbstractCache.getMissCount()`。
pub fn[K, V] Cache::miss_count(self : Cache[K, V]) -> Int {
  self.miss
}

///|
/// 按内部序列出所有键。内部序的含义随档位而定：
///
/// - `Fifo`/`Lfu`/`Timed`/`No`：**插入序**（覆盖已有键不移动位置）
/// - `Lru`：**访问序**，最近被读到的在末尾（读数 `lru.iter_after_get_a|b,c,a`）
/// - Note: 参照实现的 `LFUCache`/`TimedCache` 用的是 `HashMap`，根本没有稳定顺序；
///   本库给这两档承诺插入序，是一条**附加承诺**（不是从参照反推），见 spec §5。
pub fn[K, V] Cache::keys(self : Cache[K, V]) -> Array[K] {
  let out : Array[K] = []
  for k in self.order {
    out.push(k)
  }
  out
}

///|
/// 按 `keys()` 的同一顺序列出所有值。对位 `Cache` 的 `Iterable<V>`（读数 `fifo.values|1,2,3`）。
pub fn[K : Hash + Eq, V] Cache::values(self : Cache[K, V]) -> Array[V] {
  let out : Array[V] = []
  for k in self.order {
    match self.entries.get(k) {
      None => ()
      Some(co) => out.push(co.value)
    }
  }
  out
}

///|
/// 列出所有条目（含 `ttl`/`last_access`/`access_count`）。对位 `cacheObjIterator()`。
///
/// - Note: 参照实现的 `NoCache.cacheObjIterator()` 返回 **null**，本库返回空数组（`No` 档
///   本来就存不下东西），分岔记在 spec §5。
pub fn[K : Hash + Eq, V] Cache::cache_objs(
  self : Cache[K, V],
) -> Array[CacheObj[K, V]] {
  let out : Array[CacheObj[K, V]] = []
  for k in self.order {
    match self.entries.get(k) {
      None => ()
      Some(co) => out.push(co)
    }
  }
  out
}

///|
/// 设移除回调。对位 `setListener(CacheListener)`。
///
/// - Parameters: `listener` 在一条记录被**淘汰或显式 `remove`** 时收到那条的键值。
/// - Note: 参照实现返回 `this` 只为链式调用；本库的 `Cache` 是可变对象，改完就是同一个对象，
///   所以返回 `Unit`（一处刻意不跟的签名形状，记在 spec §5）。
/// - Note: 三条不进契约的触发时机与参照侧一致：`clear()` 不触发、`put` 覆盖不触发；
///   `Lru` 的 `capacity == 0` 那条参照是"放进去立刻被淘汰并回调"（读数 `lru.cap0_listener|a=1`），
///   本库按"0 = 不限容量"，故不会有这次回调——分岔记在 spec §5。
pub fn[K, V] Cache::set_listener(
  self : Cache[K, V],
  listener : (K, V) -> Unit,
) -> Unit {
  self.listener = Some(listener)
}

///|
/// 过期判据只有一条算式：`ttl > 0 && now - last_access > ttl`。
/// 相等不算过期；`ttl <= 0`（含负数）永不过期——参照侧 `CacheObj.isExpired()` 就是这个形状。
fn[K, V] is_expired(co : CacheObj[K, V], now : Int64) -> Bool {
  co.ttl > 0L && now - co.last_access > co.ttl
}

///|
/// `get`/`peek` 的共用体：`refresh` 只决定要不要挪过期窗口，**不**决定要不要改淘汰序
/// （参照侧 `FixedLinkedHashMap` 的 `accessOrder=true` 让任何一次读都重排）。
fn[K : Hash + Eq, V] Cache::get_at(
  self : Cache[K, V],
  key : K,
  now : Int64,
  refresh : Bool,
) -> V? {
  match self.entries.get(key) {
    None => {
      self.miss = self.miss + 1
      None
    }
    Some(co) =>
      if is_expired(co, now) {
        // 顺手删掉这一条：参照侧走的是 `removeWithoutLock`，不触发回调
        self.drop(key, false)
        self.miss = self.miss + 1
        None
      } else {
        self.hit = self.hit + 1
        co.access_count = co.access_count + 1
        if refresh {
          co.last_access = now
        }
        match self.policy {
          Lru => self.touch(key)
          _ => ()
        }
        Some(co.value)
      }
  }
}

///|
/// 删一条；`notify` 决定要不要走移除回调（淘汰/显式 remove 走，读到过期顺手删不走）。
fn[K : Hash + Eq, V] Cache::drop(
  self : Cache[K, V],
  key : K,
  notify : Bool,
) -> Unit {
  match self.entries.get(key) {
    None => ()
    Some(co) => {
      let _ = self.entries.remove(key)
      self.order = self.order.filter(k => k != key)
      if notify {
        match self.listener {
          None => ()
          Some(f) => f(co.key, co.value)
        }
      }
    }
  }
}

///|
/// 扫全部过期条目并回调，返回删掉的条数。先把键抄一份再删——边遍历边删会跳条目。
fn[K : Hash + Eq, V] Cache::sweep(self : Cache[K, V], now : Int64) -> Int {
  let ks = self.keys()
  let mut count = 0
  for k in ks {
    match self.entries.get(k) {
      None => ()
      Some(co) =>
        if is_expired(co, now) {
          self.drop(k, true)
          count = count + 1
        } else {
          ()
        }
    }
  }
  count
}

///|
/// 当前条目里的最小访问数；空表给 `None`。
fn[K : Hash + Eq, V] Cache::min_access_count(self : Cache[K, V]) -> Int? {
  let mut best : Int? = None
  for k in self.order {
    match self.entries.get(k) {
      None => ()
      Some(co) =>
        best = match best {
          None => Some(co.access_count)
          Some(b) => Some(if co.access_count < b { co.access_count } else { b })
        }
    }
  }
  best
}

///|
/// LRU 把键挪到"最近使用"那一端（本库顺序 = 最老在前）。
fn[K : Eq, V] Cache::touch(self : Cache[K, V], key : K) -> Unit {
  self.order = self.order.filter(k => k != key)
  self.order.push(key)
}

///|
/// LRU 的插入后淘汰：超出容量的从最老一端开始删，并走回调。`capacity == 0` 是不限容量。
fn[K : Hash + Eq, V] Cache::trim_lru(self : Cache[K, V]) -> Unit {
  while self.capacity > 0 &&
        self.entries.length() > self.capacity &&
        self.order.length() > 0 {
    self.drop(self.order[0], true)
  }
}
