///|
/// moon-hutool/mapx —— Map 的组合件（hutool `MapUtil` 家族与 `BiMap` / `CaseInsensitiveMap` 的 MoonBit 对位）
///
/// 契约：`docs/spec/07-mapx.md`。期望值权威在 `mapx_test.mbt` 与 spec 表——改任何期望串须单独一笔
/// 并给外部读数来源（门禁 G5），实现只负责把契约里冻好的读数算出来。
///
/// 范围：**第一批**做 `BiMap`、`CaseInsensitiveMap` 与两个 `Map` 组合件；
/// `Table`（二维表）自成一块，另起第二批（spec §9 记着）。
///
/// 三条贯穿性规则：
/// 1. **core 已有的一个都不重新包装**。`Map` 本身就是插入序（`builtin/linked_hash_map.mbt`），
///    所以**不再造 LinkedHashMap**；`of/new/get/set/contains/contains_kv/remove/merge/retain/update/
///    update_or_default/get_or_default/get_or_init/keys/values/to_array/length/is_empty/iter/each`
///    全部直接用 core，本包只在确实缺的地方补（缺口清单见 spec §1）。
/// 2. **纯函数优先，改状态要指名**。`filter_map`/`rename_key` 返回新 `Map`、不动输入；
///    `BiMap`/`CiMap` 是会变的容器，方法名（`put`/`remove`/`force_put`）就是它的改动契约。
/// 3. **不发明哨兵值**（同 `coll`）：查不到给 `V?`，报错只带读数不带文案。

///|
/// 本包错误面：只带**调用方拿不到的读数**，不带文案（同 `codec`/`date`/`id`/`coll` 的立场）
pub suberror MapError {
  /// BiMap 想用的值已被**别的键**持有。不带读数：那个键本表就能答（`get_key(value)`），
  /// 错误里再夹一份就是第二个口径——同 `codec.ChecksumMismatch` 不携带摘要的判断
  ValueConflict
  /// `rename_key` 的目标键已存在。不带读数：那个键是调用方自己传进来的
  KeyAlreadyExists
}

///|
/// 双向映射：键→值与值→键都唯一，两个方向永远一致
///
/// 字段刻意**不公开**：一致性（`forward` 与 `backward` 互为逆）只能由本包的方法维护，
/// 放出去让用户直接改 `forward` 就等于允许构造出"两个键指向同一个值"的坏状态——
/// 那正是本件要避免的事，不是可以权衡的风格偏好。
pub struct BiMap[K, V] {
  forward : Map[K, V]
  backward : Map[V, K]
}

///|
/// 建一张空的双向映射
///
/// - Note: 构造不需要 `Hash + Eq`，因为约束只在真正做查找的方法上出现（core 的 `Map::new` 同样宽松）
pub fn[K, V] BiMap::new() -> BiMap[K, V] {
  abort("moon-hutool: mapx.BiMap::new 未实现（spec 07-mapx #7.1）")
}

///|
/// 由键值对序列构造：**逐条走 `put` 的判据**，撞到就整条失败
///
/// - Parameters:
///   - `pairs`：输入对。顺序就是插入顺序，因此 `to_pairs()` 读回来与输入同序
/// - Raises: `MapError.ValueConflict(第一个占着该值的键)` —— 某个值被**别的键**占着
/// - Note: 同一个键重复给值时**后者胜**（与 `put` 同档），所以 `[("a",1),("a",2)]` 合法、
///   结果只剩 `("a", 2)`；而 `[("a",1),("b",1)]` 报错——不静默丢掉 `"a"`，
///   因为"值撞了该保谁"没有唯一正确答案，让调用方点名（hutool 那侧是既不保也不报错，见 spec §5）
pub fn[K : Hash + Eq, V : Hash + Eq] BiMap::of(
  pairs : Array[(K, V)],
) -> BiMap[K, V] raise MapError {
  let _ = pairs
  abort("moon-hutool: mapx.BiMap::of 未实现（spec 07-mapx #7.5）")
}

///|
/// 放入一对：同键覆盖值并返回旧值；值被别的键占着就报错
///
/// - Returns: 该键原来绑的值（`None` 表示这个键是新的）。覆盖时**旧值的反向条目同步删除**，
///   不留孤儿
/// - Raises: `MapError.ValueConflict(占着该值的那个键)` —— 值已被**别的键**占用。
///   此时整次调用**不生效**（不是"先写正向再报错"——半途写会让两个方向永久错位）
/// - Note: 同键同值重复 put 是幂等的，返回的旧值就是那个值本身
pub fn[K : Hash + Eq, V : Hash + Eq] BiMap::put(
  self : BiMap[K, V],
  key : K,
  value : V,
) -> V? raise MapError {
  let _ = self.forward
  let _ = self.backward
  let _ = key
  let _ = value
  abort("moon-hutool: mapx.BiMap::put 未实现（spec 07-mapx #7.2）")
}

///|
/// 强行放入：值被别的键占着时，把**那个键整条删掉**，并返回被删的键
///
/// - Returns: 被挤掉的旧键（没人占、或占着它的正是这个键 ⇒ `None`）
/// - Note: 这是 `put` 的逃生阀，名字里点明 `force`——它删的是**调用方没提过的另一个键**，
///   所以不能当默认档。对齐 Guava `BiMap.forcePut`
pub fn[K : Hash + Eq, V : Hash + Eq] BiMap::force_put(
  self : BiMap[K, V],
  key : K,
  value : V,
) -> K? {
  let _ = self.forward
  let _ = self.backward
  let _ = key
  let _ = value
  abort("moon-hutool: mapx.BiMap::force_put 未实现（spec 07-mapx #7.3）")
}

///|
/// 键 → 值
pub fn[K : Hash + Eq, V] BiMap::get(self : BiMap[K, V], key : K) -> V? {
  let _ = self.forward
  let _ = self.backward
  let _ = key
  abort("moon-hutool: mapx.BiMap::get 未实现（spec 07-mapx #7.1）")
}

///|
/// 值 → 键（本件存在的理由）
pub fn[K, V : Hash + Eq] BiMap::get_key(self : BiMap[K, V], value : V) -> K? {
  let _ = self.forward
  let _ = self.backward
  let _ = value
  abort("moon-hutool: mapx.BiMap::get_key 未实现（spec 07-mapx #7.1）")
}

///|
/// 键在不在
pub fn[K : Hash + Eq, V] BiMap::contains_key(
  self : BiMap[K, V],
  key : K,
) -> Bool {
  let _ = self.forward
  let _ = self.backward
  let _ = key
  abort(
    "moon-hutool: mapx.BiMap::contains_key 未实现（spec 07-mapx #7.1）",
  )
}

///|
/// 值在不在
pub fn[K, V : Hash + Eq] BiMap::contains_value(
  self : BiMap[K, V],
  value : V,
) -> Bool {
  let _ = self.forward
  let _ = self.backward
  let _ = value
  abort(
    "moon-hutool: mapx.BiMap::contains_value 未实现（spec 07-mapx #7.1）",
  )
}

///|
/// 按键删除，返回被删的值；顺带删掉它的反向条目
///
/// - Returns: 该键原本的值；键不存在 ⇒ `None`（幂等，第二次删同一个键也是 `None`）
pub fn[K : Hash + Eq, V] BiMap::remove(self : BiMap[K, V], key : K) -> V? {
  let _ = self.forward
  let _ = self.backward
  let _ = key
  abort("moon-hutool: mapx.BiMap::remove 未实现（spec 07-mapx #7.4）")
}

///|
/// 取逆：**新建一张**双向映射，方向互换
///
/// - Returns: `BiMap[V, K]`，其 `to_pairs()` 是原 `to_pairs()` 的逐条互换（顺序保留，不反转）
/// - Note: 不做"共享视图的懒逆序"——那是 hutool `getInverse()` 的做法，
///   它让两张视图各自维护一致性、一处改动另一处要判空重建；本库直接复制一次，
///   代价 O(n) 换来"逆过来的那张也满足双向不变式"这个确定结论
pub fn[K : Hash + Eq, V : Hash + Eq] BiMap::inverse(
  self : BiMap[K, V],
) -> BiMap[V, K] {
  let _ = self.forward
  let _ = self.backward
  abort("moon-hutool: mapx.BiMap::inverse 未实现（spec 07-mapx #7.1）")
}

///|
/// 条目数。两个方向恒等，所以不需要单独的"反向长度"
pub fn[K, V] BiMap::length(self : BiMap[K, V]) -> Int {
  let _ = self.forward
  let _ = self.backward
  abort("moon-hutool: mapx.BiMap::length 未实现（spec 07-mapx #7.1）")
}

///|
/// 键序列：插入序
pub fn[K, V] BiMap::keys(self : BiMap[K, V]) -> Array[K] {
  let _ = self.forward
  let _ = self.backward
  abort("moon-hutool: mapx.BiMap::keys 未实现（spec 07-mapx #7.1）")
}

///|
/// 值序列：插入序，且**互不重复**（双向不变式的直接推论，用例逐档断言）
pub fn[K, V] BiMap::values(self : BiMap[K, V]) -> Array[V] {
  let _ = self.forward
  let _ = self.backward
  abort("moon-hutool: mapx.BiMap::values 未实现（spec 07-mapx #7.1）")
}

///|
/// 键值对序列：插入序。与 `keys()`/`values()`/`length()` 三者必须自洽
pub fn[K, V] BiMap::to_pairs(self : BiMap[K, V]) -> Array[(K, V)] {
  let _ = self.forward
  let _ = self.backward
  abort("moon-hutool: mapx.BiMap::to_pairs 未实现（spec 07-mapx #7.1）")
}

///|
/// 键大小写不敏感的映射（ASCII 档）
///
/// 内部存 `折叠键 → (首次写入的原样键, 值)`：折叠键用来查，原样键用来读出去——
/// 与 Java 那侧 `Map.put` 覆盖值而不换键的约定一致。
pub struct CiMap[V] {
  slots : Map[String, (String, V)]
}

///|
/// 建一张空的表
pub fn[V] CiMap::new() -> CiMap[V] {
  abort("moon-hutool: mapx.CiMap::new 未实现（spec 07-mapx #7.6）")
}

///|
/// 放入一对，返回该槽位上的旧值
///
/// - Parameters:
///   - `key`：**原样键**。它的大小写会被保留到第一次写入为止——之后同一槽位再 `put`
///     （哪怕写法不同）只换值、**不换键**
/// - Returns: 该折叠槽位原来的值；槽位是新的 ⇒ `None`
/// - Note: 折叠只做 ASCII（`A-Z` → `a-z`）。非 ASCII 一律原样：Unicode 大小写表在
///   `moonbitlang/core` 里没有，`Char` 连 `to_lowercase` 都没有，拖一张表进来等于把一个
///   工具库的发布节奏绑到码表上（与「不做」清单同口径）
pub fn[V] CiMap::put(self : CiMap[V], key : String, value : V) -> V? {
  let _ = self.slots
  let _ = key
  let _ = value
  abort("moon-hutool: mapx.CiMap::put 未实现（spec 07-mapx #7.6）")
}

///|
/// 按折叠键查值
pub fn[V] CiMap::get(self : CiMap[V], key : String) -> V? {
  let _ = self.slots
  let _ = key
  abort("moon-hutool: mapx.CiMap::get 未实现（spec 07-mapx #7.6）")
}

///|
/// 读出该槽位**存着的那个原样键**（HTTP 头这类场景要按原样回写，不能拿查询串去覆盖）
///
/// - Returns: 首次写入时的原样键；查不到 ⇒ `None`
pub fn[V] CiMap::get_key_of(self : CiMap[V], key : String) -> String? {
  let _ = self.slots
  let _ = key
  abort("moon-hutool: mapx.CiMap::get_key_of 未实现（spec 07-mapx #7.6）")
}

///|
/// 槽位在不在（大小写无关）
pub fn[V] CiMap::contains(self : CiMap[V], key : String) -> Bool {
  let _ = self.slots
  let _ = key
  abort("moon-hutool: mapx.CiMap::contains 未实现（spec 07-mapx #7.7）")
}

///|
/// 按折叠键删除，返回被删的值
pub fn[V] CiMap::remove(self : CiMap[V], key : String) -> V? {
  let _ = self.slots
  let _ = key
  abort("moon-hutool: mapx.CiMap::remove 未实现（spec 07-mapx #7.7）")
}

///|
/// 槽位数（不是写入次数：撞过同一槽位的 `put` 不增加）
pub fn[V] CiMap::length(self : CiMap[V]) -> Int {
  let _ = self.slots
  abort("moon-hutool: mapx.CiMap::length 未实现（spec 07-mapx #7.6）")
}

///|
/// 原样键序列：按槽位的首次写入顺序
pub fn[V] CiMap::keys(self : CiMap[V]) -> Array[String] {
  let _ = self.slots
  abort("moon-hutool: mapx.CiMap::keys 未实现（spec 07-mapx #7.6）")
}

///|
/// 落到一个普通 `Map`：键是**原样键**，槽位序 = 本表的插入序
///
/// - Note: 这是出口，不是中转——返回的 `Map` 之后按普通大小写敏感规则工作，
///   想继续不敏感就留在 `CiMap` 里
pub fn[V] CiMap::to_map(self : CiMap[V]) -> Map[String, V] {
  let _ = self.slots
  abort("moon-hutool: mapx.CiMap::to_map 未实现（spec 07-mapx #7.7）")
}

///|
/// 边走边筛选并换值类型：`core` 的 `Map` 有 `map`（只换值）与 `retain`（只筛不换），
/// 两件合起来用要先建中间表——这一件是一次遍历做完
///
/// - Parameters: `f`：拿键和旧值，返回 `None` 表示这条丢掉
/// - Returns: 新 `Map`，**键序沿用输入的插入序**（core `Map` 保插入序）；输入 `Map` 不被修改
/// - Note: 对拍腿（门禁 G8）：`f` 恒 `Some` 时与 core `Map::map` 同结果
pub fn[K : Hash + Eq, A, B] filter_map(
  m : Map[K, A],
  f : (K, A) -> B?,
) -> Map[K, B] {
  let _ = m
  let _ = f
  abort("moon-hutool: mapx.filter_map 未实现（spec 07-mapx #7.8）")
}

///|
/// 改一个键的名字，值不变
///
/// - Parameters:
///   - `old_key`：要改掉的键。**不存在时原样返回新表**（跟 hutool 同档：不猜"是不是拼错了"，
///     但那意味着这条调用什么都没做，所以读数用键序断言，别靠"报个错更醒目"）
///   - `new_key`：新键。已存在 ⇒ 报错，不做静默覆盖
/// - Returns: **新** `Map`（输入不动），且 `new_key` 排在**末尾**——hutool `MapUtil.renameKey`
///   就是 `put(new) + remove(old)`，在 `LinkedHashMap` 上落末尾，本库跟随并写死
/// - Raises: `MapError.KeyAlreadyExists(new_key)`
/// - Note: `old_key == new_key` 时**保留该条**（hutool 那侧先 `put` 再 `remove` 同一个键，
///   条目会被自己删掉——那是坑，不跟随）
pub fn[K : Hash + Eq, V] rename_key(
  m : Map[K, V],
  old_key : K,
  new_key : K,
) -> Map[K, V] raise MapError {
  let _ = m
  let _ = old_key
  let _ = new_key
  abort("moon-hutool: mapx.rename_key 未实现（spec 07-mapx #7.9）")
}
