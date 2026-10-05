///|
/// moon-hutool 的 `cache` —— 有界/有过期时间的键值缓存（hutool `cn.hutool.cache` 的 MoonBit 对位·第一批）。
///
/// 契约：`docs/spec/16-cache.md`；进度：`docs/ROADMAP.md`。这一批**只有签名与冻结期望值，函数体是 `abort`**
/// （状态＝契约已冻结，用例预期红）；实现那一笔只许把红变绿（门禁 G5）。
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
  last_access : Int64
  access_count : Int
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
  order : Array[K]
  entries : Map[K, CacheObj[K, V]]
  hit : Int
  miss : Int
  listener : ((K, V) -> Unit)?
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
  abort("moon-hutool cache: 契约已冻结，实现待落地")
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
  abort("moon-hutool cache: 契约已冻结，实现待落地")
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
  abort("moon-hutool cache: 契约已冻结，实现待落地")
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
  abort("moon-hutool cache: 契约已冻结，实现待落地")
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
  abort("moon-hutool cache: 契约已冻结，实现待落地")
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
  abort("moon-hutool cache: 契约已冻结，实现待落地")
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
  abort("moon-hutool cache: 契约已冻结，实现待落地")
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
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 删一条，并触发移除回调。对位 `remove(key)`（参照实现返回 `void`，本库同）。
///
/// 读数 `fifo.remove_listener|a=1`。
pub fn[K : Hash + Eq, V] Cache::remove(self : Cache[K, V], key : K) -> Unit {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 清空。**不触发**移除回调——参照实现的 `clear()` 直接 `cacheMap.clear()`，不走 `onRemove`。
///
/// 读数 `fifo.clear_listener|`（空串）。
pub fn[K : Hash + Eq, V] Cache::clear(self : Cache[K, V]) -> Unit {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
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
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 当前条数。对位 `size()`。
pub fn[K : Hash + Eq, V] Cache::size(self : Cache[K, V]) -> Int {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 是否为空。本库一律等于 `size() == 0`。
///
/// - Note: 参照实现的 `NoCache.isEmpty()` 返回 **false**（而 `size()` 是 0），
///   这是它自相矛盾的一处，本库**不跟**，两侧读数记在 spec §5 分岔表。
pub fn[K : Hash + Eq, V] Cache::is_empty(self : Cache[K, V]) -> Bool {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 是否已满：`capacity > 0 && size >= capacity`（读数 `fifo.is_full3|true`、
/// `fifo.cap0_is_full|false`、`timed.is_full|false`）。
pub fn[K : Hash + Eq, V] Cache::is_full(self : Cache[K, V]) -> Bool {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 容量（`0` = 不限）。对位 `capacity()`。
pub fn[K : Hash + Eq, V] Cache::capacity(self : Cache[K, V]) -> Int {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 默认存活时长（毫秒）。对位 `timeout()`。
pub fn[K : Hash + Eq, V] Cache::timeout(self : Cache[K, V]) -> Int64 {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 本缓存的淘汰策略。参照实现没有这个 getter（靠具体类型区分），本库补一件，
/// 因为五档收成了一个 `Cache` 类型。
pub fn[K : Hash + Eq, V] Cache::policy(self : Cache[K, V]) -> CachePolicy {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 命中次数（`get`/`peek` 计，`contains_key` 不计）。对位 `AbstractCache.getHitCount()`。
pub fn[K : Hash + Eq, V] Cache::hit_count(self : Cache[K, V]) -> Int {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 未命中次数。对位 `AbstractCache.getMissCount()`。
pub fn[K : Hash + Eq, V] Cache::miss_count(self : Cache[K, V]) -> Int {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 按内部序列出所有键。内部序的含义随档位而定：
///
/// - `Fifo`/`Lfu`/`Timed`/`No`：**插入序**（覆盖已有键不移动位置）
/// - `Lru`：**访问序**，最近被读到的在末尾（读数 `lru.iter_after_get_a|b,c,a`）
/// - Note: 参照实现的 `LFUCache`/`TimedCache` 用的是 `HashMap`，根本没有稳定顺序；
///   本库给这两档承诺插入序，是一条**附加承诺**（不是从参照反推），见 spec §5。
pub fn[K : Hash + Eq, V] Cache::keys(self : Cache[K, V]) -> Array[K] {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 按 `keys()` 的同一顺序列出所有值。对位 `Cache` 的 `Iterable<V>`（读数 `fifo.values|1,2,3`）。
pub fn[K : Hash + Eq, V] Cache::values(self : Cache[K, V]) -> Array[V] {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}

///|
/// 列出所有条目（含 `ttl`/`last_access`/`access_count`）。对位 `cacheObjIterator()`。
///
/// - Note: 参照实现的 `NoCache.cacheObjIterator()` 返回 **null**，本库返回空数组（`No` 档
///   本来就存不下东西），分岔记在 spec §5。
pub fn[K : Hash + Eq, V] Cache::cache_objs(
  self : Cache[K, V],
) -> Array[CacheObj[K, V]] {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
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
pub fn[K : Hash + Eq, V] Cache::set_listener(
  self : Cache[K, V],
  listener : (K, V) -> Unit,
) -> Unit {
  abort("moon-hutool cache: 契约已冻结，实现待落地")
}
