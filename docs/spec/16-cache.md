# 16 · `cache` —— 有界 / 有过期时间的键值缓存

对位 hutool `cn.hutool.cache`（**hutool-cache** artifact，5.8.35）+ `cn.hutool.core.lang.SimpleCache`。
进度状态见 `docs/ROADMAP.md` 第 16 行；本文是这一行契约的唯一真相。

---

## 1. 对位与血统（先划边界，再写代码）

| 参照件 | 在哪 | 本包怎么处置 |
|---|---|---|
| `Cache<K,V>` 接口（18 个方法，javap 现读） | hutool-cache | 收成**一个可变类型 `Cache[K, V]` + 一个 `CachePolicy` 五档枚举**，不再分五个子类（MoonBit 没有继承语义） |
| `AbstractCache` / `FIFOCache` / `LRUCache` / `LFUCache` / `TimedCache` / `NoCache` | hutool-cache | 五档全部落地；`AbstractCache` 的公共字段（`capacity`/`timeout`/`hitCount`/`missCount`/`listener`）进 `Cache` 的私有形状 |
| `CacheObj<K,V>`（`key`/`obj`/`lastAccess`/`accessCount`/`ttl`） | hutool-cache | 落 `CacheObj[K, V]`，字段照读，位置一一对应 |
| `CacheListener<K,V>`（只有 `onRemove` 一个方法） | hutool-cache | 不建接口类型，`set_listener` 直接收 `(K, V) -> Unit` |
| `CacheUtil` 的九枚静态工厂 | hutool-cache | 不建工厂包，只留 `new_cache(policy, capacity, timeout)` 一个入口（表数、表里都记在 §4） |
| `ReentrantCache` / `StampedCache` | hutool-cache | **不建**（见 §5 第 5 行，判据是"件的唯一职责是锁"） |
| `WeakCache`（+ `CacheUtil.newWeakCache`） | hutool-cache | **不建**（见 §5 第 6 行，判据是"平台没有弱引用"） |
| `GlobalPruneTimer` / `schedulePrune` / `cancelPruneSchedule` | hutool-cache | **不建**（见 §5 第 7 行，实测腿是线程性质不是缓存语义） |
| `cn.hutool.cache.file.*`（三件文件缓存） | hutool-cache | **不建**：落盘 IO 不在本库"零依赖纯计算"的范围内（包头注已钉） |
| `cn.hutool.core.lang.SimpleCache` | **hutool-core**，不在 hutool-cache | **不建**（§5 第 8 行）。顺带更正既往文档：`ROADMAP` 这一行原先把 `SimpleCache` 与 `CacheUtil` 并列成"对位类"，读者会以为它们同 artifact——实测 `unzip -l hutool-core-5.8.35.jar` 才有它、`hutool-cache` 里没有 |

许可血统与 `path` 同一档：hutool 是 Apache-2.0，本仓 `LICENSE`/`moon.mod` 从骨架那一笔起就是 Apache-2.0，不构成开工屏障。

---

## 2. 公开面（第一批 23 件 = 21 函数 + 1 枚举 + 1 记录）

| 件 | 签名 | 对位 |
|---|---|---|
| `CachePolicy` | `Fifo / Lru / Lfu / Timed / No` | 五个具体类 |
| `CacheObj[K, V]` | `key, value, ttl : Int64, last_access : Int64, access_count : Int` | `CacheObj` 的五个读方法 |
| `Cache[K, V]` | `new_cache(policy, capacity : Int, timeout : Int64)` | 四个构造器 + `CacheUtil` |
| 写 | `put(key, value, now)` / `put_ttl(key, value, ttl, now)` | `put(K,V)` / `put(K,V,long)` |
| 读 | `get(key, now) -> V?` / `peek(key, now) -> V?` | `get(K)`（刷新）/ `get(K,false)`（不刷新） |
| 读+造 | `get_or_put(key, now, supplier)` / `get_or_put_ttl(key, now, ttl, supplier)` | `get(K,boolean,Func0)` / `get(K,boolean,long,Func0)` |
| 查 | `contains_key(key, now) -> Bool` | `containsKey(K)` |
| 删 | `remove(key)` / `clear()` | 同名 |
| 清 | `prune(now) -> Int` | `prune()` |
| 读数 | `size` / `is_empty` / `is_full` / `capacity` / `timeout` / `policy` / `hit_count` / `miss_count` | `size()`…`getMissCount()`；`policy()` 是本库补的一件（五档收成一个类型后必须能读回档位） |
| 列出 | `keys` / `values` / `cache_objs` | `keySet()` / `Iterable<V>` / `cacheObjIterator()` |
| 回调 | `set_listener((K, V) -> Unit)` | `setListener(CacheListener)` |

不做四件都带理由：四枚可变 setter（`setCapacity`/`setTimeout`/`setExistCustomTimeout`/`setKeyLockMap` 之类，收成构造参数）、
`schedulePrune`/`cancelPruneSchedule`、`keySet()` 的 `Set` 形状（改 `Array[K]` 带顺序承诺）、
`get(K, Func0)` 这枚 default 便捷档（与 `get_or_put` 重复，只留刷新语义明确的两件）。

---

## 3. 语义条目（每条都给参照腿读数编号，编号是 §4 腿 A 的行标签）

| # | 判据 | 参照读数 / 来源 |
|---|---|---|
| 1 | 过期只有一条算式：`ttl > 0 && now - last_access > ttl`。**相等不算过期**；`ttl <= 0`（含负数）**永不过期** | `CacheObj.isExpired()` 源码 + `fifo.expired_prune_count`、`fifo.neg_ttl_alive|1`、`fifo.zero_ttl_alive|1` |
| 2 | 命中即刷新窗口（滑动过期）：`get` 把 `last_access` 置成调用方给的 `now`；`peek` 不置 | `timed.sliding_mid`→`timed.alive_after_refresh`→`timed.dead_after_window` 三行连读 |
| 3 | `get`/`peek` 都加访问计数与命中计数；`contains_key` **两者都不加** | `obj.access_count_after_get|1`、`fifo.hit_miss_after_get|1/1`、`fifo.hit_miss_after_containsKey|0/1`、`lfu.count_after_containsKey|a=0:0` |
| 4 | 读到过期条目 = 返回"无值"并**顺手删掉这一条**（不扫全表） | `fifo.expired_get|null` + `fifo.expired_size_after_get|0`、`fifo.expired_containsKey|false` + `…size_after_containsKey|0` |
| 5 | 满的判据是 `capacity > 0 && size >= capacity`；`capacity == 0` 在 `isFull` 眼里是"不限" | `fifo.is_full3|true`、`fifo.cap0_is_full|false`、`timed.is_full|false` |
| 6 | 覆盖已有键**不做满判定**（参照 issue#3618 那一支），因此不淘汰、不回调 | `fifo.replace_existing_size|3`、`fifo.replace_existing_listener`（空） |
| 7 | `Fifo` 淘汰队首；`Lru` 淘汰访问序最老的一条；`Lfu` 走"公平减计"；`Timed`/`No` 不因容量淘汰 | `fifo.iter_after_4th|b,c,d`、`lru.keys_after_4th|a,c,d`、`lfu.sorted_keys|a,b,d`、`timed.capacity|0` |
| 8 | `Lru` 的"访问"包含**任何一次 map 读**：`peek`（不刷新过期窗口）照样把键挪到最近端；覆盖写也算一次访问 | `lru.get_false_still_reorders_iter|c,a,d`、`lru.order_after_replace_a|c,b,a` |
| 9 | `Fifo` 的内部序是插入序，**读不改变它** | `fifo.iter_order_after_get|b,c,d` |
| 10 | `prune` 三档语义不同：`Fifo`＝扫过期 +（仍满则）踢队首；`Lru`/`Timed`＝只扫过期；`Lfu`＝扫过期 +（仍满则）全体减去最小访问数、把减后 `<= 0` 的一起删 | `fifo.prune_ttl0|1`、`fifo.prune_full_count|1`→`fifo.prune_again_count|0`、`lru.prune_ttl0|0`、`timed.prune_count|2`、`lfu.prune_while_full_count|2` |
| 11 | `Lfu` 公平减计三条形状：三条计数全 0 时插入第 4 条 ⇒ **只剩新来的那条**；有唯一最小值 ⇒ 只删那条并保留其余计数原样；三条计数相同 ⇒ **一起减到 0、一起删** | `lfu.allzero_size|1`、`lfu.sorted_counts|a=2:0,b=1:0,d=0:0`、`lfu.equal_counts_size|1` |
| 12 | `get_or_put` 未命中时 `miss` **加 2**（外层取一次、装回后再取一次），第二次命中不再调 `supplier`；由 `supplier` 造出来的那条 `access_count` 是 0 | `lru.supplier_hitmiss|0/2`、`lru.supplier_hitmiss_second|1/2 calls=1`、`lru.supplier_custom_ttl_counts|a=0:0,x=1:0,y=0:100` |
| 13 | 单条 `ttl` 不改缓存默认 `timeout`；只要出现过 `ttl != 0`，参照实现就永久打开"要扫过期"的开关 | `lru.supplier_ttl_inherited|0`、`fifo.neg_ttl_prune|0`（`existCustomTimeout` 的源码路径） |
| 14 | 回调只在**淘汰**与显式 `remove` 时触发；`clear()` 不逐条回调 | `fifo.listener_on_evict|a=1`、`fifo.remove_listener|a=1`、`fifo.clear_listener`（空） |
| 15 | `Timed` 档忽略构造时的 `capacity`，恒 0（不限容量）；`No` 档写进去就没了 | `timed.capacity|0`、`no.size|0`、`no.supplier|S` + `no.supplier_size|0` |

---

## 4. 参照腿（期望值的两个来源）

| 腿 | 载体 | 读数 | 备注 |
|---|---|---|---|
| A 实测 | `hutool-cache-5.8.35.jar` + `hutool-core-5.8.35.jar` + 本机 JDK 17.0.14，`javac -encoding UTF-8` | **146 条**（`cache_ref.txt` 123 + `cache_ref2.txt` 23），每条带 `tag\|值` 标签，可复算 | 过期那一组只能靠 `Thread.sleep` 造时间差（`ttl=40` 睡 120、滑动那一组 200/100/120/220），**留档给机制判定用**；本库用例一律换成显式 `now` 的确定差值，零计时依赖 |
| B 源码 | `AbstractCache.java` 274 行 / `CacheObj.java` 134 行 / `FIFOCache`·`LRUCache`·`LFUCache`·`TimedCache`·`NoCache`·`ReentrantCache` 全文 + `FixedLinkedHashMap.removeEldestEntry` | 相等边界（条目 1）、覆盖不判满（条目 6）、`peek` 仍重排（条目 8）、`miss` 加两笔（条目 12）四处的**为什么** | 腿 A 能给"是多少"，这四条只有读源码才给得出"为什么"，两者并排记 |

开局两条现读把既往文档更正了（`dfa`/`path` 轮那条"先 unzip/javap 再决定从哪取"）：

1. `unzip -l hutool-core-5.8.35.jar | grep -c cn/hutool/cache` = **0** ⇒ 缓存件不在 core，得另取 `hutool-cache` artifact（与 `dfa` 同形）。
2. `hutool-cache-5.8.35.jar` 里**没有** `SimpleCache`/`MRUCache`/`SoftCache`/`FCFSCache`；`SimpleCache` 在 core 的 `cn/hutool/core/lang/`，
   而 `MRUCache`/`SoftCache`/`FCFSCache` 在 5.8.35 **根本不存在**（是 4.x 的旧件）⇒ 既往"要实现 SimpleCache/LRU/LFU/TTL 全家"这句话
   一半是空的，本批按现读的文件清单立约，不多不少。

---

## 5. 分岔与不跟（两侧读数都留，不许只写我们这一侧）

| # | 分岔 | 参照侧 | 本库 | 理由 |
|---|---|---|---|---|
| 1 | 时钟从哪来 | 三处读 `System.currentTimeMillis()` | 调用方显式传 `now : Int64` | wasm / js 档没有读当前时间的入口；这是平台约束，不是口味 |
| 2 | `capacity == 0` 对 LRU/LFU 意味着什么 | `fifo.cap0_size|5` 却 `lru.cap0_size|0` + `lru.cap0_listener|a=1`（放进即淘汰） | 三档统一"0 = 不限容量" | 参照侧同一份代码两套说法（`AbstractCache.isFull` 判 `capacity > 0`，`FixedLinkedHashMap.removeEldestEntry` 判 `size > capacity`）；本库只留一套，否则 `capacity` 的含义要按档位查表 |
| 3 | `Integer.MAX_VALUE` 容量 | `FIFOCache` 构造直接抛 `IllegalArgumentException: Illegal initial capacity: -2147483648`；`LRUCache`/`LFUCache` 先 `-1` 躲过（`lru.capmax|2147483646`） | 不跟，也不模仿那个 `-1` | 病根是 Java 的 `capacity + 1` 预分配溢出，是容器实现细节；本库不预分配桶，异常没有来源 |
| 4 | `NoCache.isEmpty()` | `size()==0` 而 `isEmpty()==false`（`no.is_empty|false`） | `is_empty` 恒等于 `size() == 0` | 参照侧自相矛盾，跟哪边都得选，本库选可推导的那条 |
| 5 | `NoCache.cacheObjIterator()` | 返回 **null** | 返回空数组 | 本库公开面全是值类型，没有 null；`No` 档本来就存不下东西 |
| 6 | `ReentrantCache` / `StampedCache` | 两件独立类 | **不建** | javap 现读：两件的成员只有锁与 `lock.lock()/unlock()` 包裹的重写方法，去掉锁之后**没有一个新语义**；MoonBit 各档目标运行期是单线程，建了就是给调用方一个假的并发承诺 |
| 7 | `WeakCache` / `SimpleCache` | 依赖 `WeakConcurrentMap` / `java.lang.ref.Reference` | **不建** | 零依赖 ⇒ 只有 core，而 core 没有弱引用；"什么时候被回收"由 GC 决定，行为不可冻、期望值给不出——一条读数的值随 JVM 情绪变的件不进契约 |
| 8 | `schedulePrune(delay)` / `GlobalPruneTimer` | 起一个后台定时清理线程 | **不建**，只留显式 `prune(now)` | 实测：调 `CacheUtil.newTimedCache(100, 50)` 之后进程里多出**非守护**线程 `Pure-Timer-1`（`prune.non_daemon_threads` 那条读数），本机 JVM 因此不退出、工装挂到超时。守护线程语义既与 wasm/js 无关，也不是"缓存语义"，`ROADMAP` 这一行原本的"去掉守护线程语义"就是这条 |

另记一条**附加承诺**（参照侧没给、本库给）：`Lfu`/`Timed` 两档参照用的是 `HashMap`，顺序根本不承诺；
本库 `keys()`/`values()`/`cache_objs()` 对这两档承诺**插入序**（覆盖不移动）。这条不是从参照反推来的，是"要让文档用例可复算"才加的。

---

## 6. 变异对照（PR-B 那一笔要做够五条，逐条必须至少一块红）

| 变异 | 期待抓住它的块 |
|---|---|
| 把过期判据 `>` 改成 `>=` | 条目 1 的相等边界（`过期算术` 那块） |
| 让 `peek` 也刷新 `last_access` | 条目 2 + 条目 3（滑动那组与 `contains_key`/`peek` 计数那两块） |
| 让 `contains_key` 计一次 miss | 条目 3（`contains_key` 那块的两个计数断言） |
| `Lru` 的访问序改成插入序（读不移动） | 条目 8（`lru 访问序` 那块的三次 `keys()` 断言） |
| `Lfu` 的公平减计改成"只删最小那一条、不减其余" | 条目 11（三条形状那块） |
| `Fifo` 的 `prune` 去掉"仍满则踢队首" | 条目 10（`prune 三档` 那块） |
| 覆盖已有键时也做满判定 | 条目 6（`覆盖已有键不淘汰` 那块） |
| `get_or_put` 未命中只计一次 miss | 条目 12（`两次 miss` 那块） |

落地轮实测红块数（`moon test --target wasm`，每条改后跑、跑完按 sha256 字节级还原）：
`>`→`>=` **2** / `peek` 也刷新 **2** / `contains_key` 记 miss **1** / LRU 读不移动 **2** /
FIFO 的 `prune` 去掉踢队首 **4** / 覆盖改走新键分支 **3** / `miss` 只记一笔 **1** /
LFU 最小值判定取反 **3** / LFU 跳过公平减计 **3**。
**一条等价变异如实记着**：把"全体减去最小值、删掉减后 `<= 0` 的"改成"只删等于最小值的几条、不减其余"，
三条夹具形状下红块数 **0**——均匀减法保序，`min` 与"取到 `min` 的集合"都不变，只有访问计数逼近整型溢出
才可能可观测。结论：参照侧那句"以便新对象进入后可以公平计数"是**防溢出**措施，不是选择规则；
本库实现照抄减法（与参照同形），但不给它配独立断言，也不宣称"公平减计被变异覆盖"。

写变异先问"它能改变哪个可观测读数"（`dfa` 轮那条空变异教训）。

---

## 7. 阶段

| 相位 | 状态 | 读数 |
|---|---|---|
| 本文件 23 件公开面 | **已实现**（10-05 两笔：契约 `a0e49a` + 落地） | 14 块全绿（10 断言块 + 4 文档块），wasm / js / wasm-gc 三档一致；`.mbti` 相对契约笔只前进一处形状——`CacheObj.last_access`/`access_count` 与 `Cache` 的五个字段改 `mut`（语义要求可变），公开函数签名一字未改 |
| 变异对照 | **已做九条：八条有块红 + 一条等价变异** | 逐条红块数与那条等价变异的成因写在 §6 末段 |
| `cache` 第二批 | 排期 | `Table`/`WeakCache` 之类已判不建，第二批只可能补 `values` 过滤档与并发档（若平台将来给并发原语） |

## 8. 默认档补档（10-08，`cache/cache_default2_test.mbt`）

`Cache2Leg.java`（hutool-cache 5.8.35 · JDK 17.0.14）7 对夹具，打的是此前**一条用例都没走到**的四支：
`get_or_put` 的命中不回表、新建未写入的 `is_empty`、`remove` 缺键、`prune` 的过期判定。
全仓 **1277 = 绿 1277 / 红 0**（三档一致），G15 基线 192 → **189 行**（cache 12 → 9），`.mbti` 一字未动。

一条踩到的映射错误值得记（不是分岔，是我把两件事混成一件）：腿的 LRU 用的是 `CacheUtil.newLRUCache(4)`，
**没有缺省超时**；本库 `Cache::new_cache(Lru, 4, timeout)` 的第三个参数就是缺省超时，我照抄成 `10L`
就得到"t=30 时 prune 掉 1 条"而参照给 0 条。第一反应会是"分岔"，其实是我给了不同的构造参数——
**对撞前要先确认两件事是同一件事**：改成 `timeout=0L` 之后两侧逐条同判。本库 `Lru`  honor 缺省超时
不是缺陷，参照的 `LRUCache(capacity)` 与 `LRUCache(capacity, timeout)` 也是两档。

| 档 | 参照 | 本库 | 处置 |
|---|---|---|---|
| `get(k, Func0)` 缺键 supplier / 命中不回表 | `42` / `1` | 同值 | 钉（命中不回表那一支就是 `cache.mbt:243`） |
| 新建未写入 `isEmpty()` / `size()` | `true` / `0`（Lru 与 Timed 各一次） | 同值 | 钉（`is_empty` 那件此前只被 NoCache 打过，而 NoCache 的 `isEmpty` 参照自身矛盾、本库不跟随，见 §5） |
| `remove(不存在的键)` | size 不变、`containsKey` 假 | 同值 | 钉（`cache.mbt:518` 的 `None => ()` 支） |
| Timed `prune()`（两条 ttl=10，推进到 30） | `2` 条、size 0、取不到 | 同值 | 钉（`cache.mbt:542` 的"过期就 drop"） |
| `get_or_put` 的**双检命中**（`cache.mbt:220/246`） | 参照没有第二次查表 | 走得到当 supplier 自己回填 | **本库自订契约**，本轮仍未钉——要打得靠 supplier 里回填，那是给参照没有的形状造读数，留待与 §5 那批"自订档"一起单独立行 |

变异对照 3 条：`Z1`（`prune` 不判过期）1 红；`Z2` 将 `remove` 的 `None => ()` 换成 `Some(_) => ()` 让
match 非穷尽、整件编不过（`NO SUMMARY`），属于**工装写坏**不是变异结论；`Z3` 锚点在文件里命中 2 次
（两处双检同形），按"锚点唯一"不作证据。⇒ 本批只有 1 条有效抓红，是这几批里最薄的一次，
原因也写在表里：剩下的 3 行属于"本库自订形状"，不为它造读数的话就只能挂着。
