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
/// - Note: 键与值**都要** `Hash + Eq`——这不是风格选择：空表字面量 `Map([])` 就要求键有界，
///   而本件内部是两张 `Map`（正向键是 K、反向键是 V）。实现那一笔把界补上了，签名以 `.mbti` 为准。
pub fn[K : Hash + Eq, V : Hash + Eq] BiMap::new() -> BiMap[K, V] {
  { forward: Map([]), backward: Map([]), }
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
  let m : BiMap[K, V] = BiMap::new()
  for (k, v) in pairs {
    // 逐条走 `put` 的判据：构造与后续写入共用一套规则，不另开第二套
    let _ = m.put(k, v)
  }
  m
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
  match self.backward.get(value) {
    Some(holder) =>
      if holder != key {
        // 整次调用不生效：半途写下去，两个方向就永久错位了
        raise ValueConflict
      }
    None => ()
  }
  self.link(key, value)
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
  let evicted = match self.backward.get(value) {
    Some(holder) => if holder == key { None } else { Some(holder) }
    None => None
  }
  match evicted {
    Some(old_key) => {
      let _ = self.drop_key(old_key)
    }
    None => ()
  }
  let _ = self.link(key, value)
  evicted
}

///|
/// 键 → 值
pub fn[K : Hash + Eq, V] BiMap::get(self : BiMap[K, V], key : K) -> V? {
  self.forward.get(key)
}

///|
/// 值 → 键（本件存在的理由）
pub fn[K, V : Hash + Eq] BiMap::get_key(self : BiMap[K, V], value : V) -> K? {
  self.backward.get(value)
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
  self.forward.contains(key)
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
  self.backward.contains(value)
}

///|
/// 按键删除，返回被删的值；顺带删掉它的反向条目
///
/// - Returns: 该键原本的值；键不存在 ⇒ `None`（幂等，第二次删同一个键也是 `None`）
pub fn[K : Hash + Eq, V : Hash + Eq] BiMap::remove(
  self : BiMap[K, V],
  key : K,
) -> V? {
  self.drop_key(key)
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
  let out : BiMap[V, K] = BiMap::new()
  for (k, v) in self.forward.to_array() {
    // 顺序取正向的插入序，而不是直接换用 backward——那会丢掉正向的顺序
    out.forward.set(v, k)
    out.backward.set(k, v)
  }
  out
}

///|
/// 条目数。两个方向恒等，所以不需要单独的"反向长度"
pub fn[K, V] BiMap::length(self : BiMap[K, V]) -> Int {
  self.forward.length()
}

///|
/// 键序列：插入序
pub fn[K, V] BiMap::keys(self : BiMap[K, V]) -> Array[K] {
  self.forward.keys().to_array()
}

///|
/// 值序列：插入序，且**互不重复**（双向不变式的直接推论，用例逐档断言）
pub fn[K, V] BiMap::values(self : BiMap[K, V]) -> Array[V] {
  self.forward.values().to_array()
}

///|
/// 键值对序列：插入序。与 `keys()`/`values()`/`length()` 三者必须自洽
pub fn[K, V] BiMap::to_pairs(self : BiMap[K, V]) -> Array[(K, V)] {
  self.forward.to_array()
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
  { slots: Map([]), }
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
  let slot = fold_ascii(key)
  let old = self.slots.get(slot)
  // 原样键取首次写入的那一个：覆盖只换值，不换键
  let orig = match old {
    Some((o, _)) => o
    None => key
  }
  self.slots.set(slot, (orig, value))
  old.map(p => p.1)
}

///|
/// 按折叠键查值
pub fn[V] CiMap::get(self : CiMap[V], key : String) -> V? {
  self.slots.get(fold_ascii(key)).map(p => p.1)
}

///|
/// 读出该槽位**存着的那个原样键**（HTTP 头这类场景要按原样回写，不能拿查询串去覆盖）
///
/// - Returns: 首次写入时的原样键；查不到 ⇒ `None`
pub fn[V] CiMap::get_key_of(self : CiMap[V], key : String) -> String? {
  self.slots.get(fold_ascii(key)).map(p => p.0)
}

///|
/// 槽位在不在（大小写无关）
pub fn[V] CiMap::contains(self : CiMap[V], key : String) -> Bool {
  self.slots.contains(fold_ascii(key))
}

///|
/// 按折叠键删除，返回被删的值
pub fn[V] CiMap::remove(self : CiMap[V], key : String) -> V? {
  let slot = fold_ascii(key)
  let old = self.slots.get(slot)
  let _ = self.slots.remove(slot)
  old.map(p => p.1)
}

///|
/// 槽位数（不是写入次数：撞过同一槽位的 `put` 不增加）
pub fn[V] CiMap::length(self : CiMap[V]) -> Int {
  self.slots.length()
}

///|
/// 原样键序列：按槽位的首次写入顺序
pub fn[V] CiMap::keys(self : CiMap[V]) -> Array[String] {
  self.slots.values().map(p => p.0).to_array()
}

///|
/// 落到一个普通 `Map`：键是**原样键**，槽位序 = 本表的插入序
///
/// - Note: 这是出口，不是中转——返回的 `Map` 之后按普通大小写敏感规则工作，
///   想继续不敏感就留在 `CiMap` 里
pub fn[V] CiMap::to_map(self : CiMap[V]) -> Map[String, V] {
  let out : Map[String, V] = Map([])
  for (_, p) in self.slots.to_array() {
    out.set(p.0, p.1)
  }
  out
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
  let out : Map[K, B] = Map([])
  m.each((k, v) => {
    match f(k, v) {
      Some(y) => out.set(k, y)
      None => ()
    }
  })
  out
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
  // `old_key == new_key` 时自己不算"撞车"——不加这一条，重命名成同名会误报
  if new_key != old_key && m.contains(new_key) {
    raise KeyAlreadyExists
  }
  let out : Map[K, V] = Map([])
  m.each((k, v) => if k != old_key { out.set(k, v) })
  match m.get(old_key) {
    // 原键不存在就什么都不做（同 hutool 的 no-op 档）；存在才把值挂到末尾
    Some(v) => out.set(new_key, v)
    None => ()
  }
  out
}

// ==== 私有件：双向映射的两步底层动作与 ASCII 折叠，都不进 `.mbti` ====

///|
/// 删掉一个键并同步摘掉它的反向条目，返回被删的值
fn[K : Hash + Eq, V : Hash + Eq] BiMap::drop_key(
  self : Self[K, V],
  key : K,
) -> V? {
  let old = self.forward.get(key)
  let _ = self.forward.remove(key)
  match old {
    Some(v) => {
      let _ = self.backward.remove(v)
    }
    None => ()
  }
  old
}

///|
/// 写入一对并同步两个方向，返回该键原来的值。
/// 拆成两件是因为 `put` 与 `force_put` 的**判据**不同（前者先拒绝、后者先挤掉），
/// 而"写完保持互逆"这一步完全一样——两份实现迟早分叉
fn[K : Hash + Eq, V : Hash + Eq] BiMap::link(
  self : Self[K, V],
  key : K,
  value : V,
) -> V? {
  let old = self.forward.get(key)
  match old {
    Some(v) => {
      let _ = self.backward.remove(v)
    }
    None => ()
  }
  // 只 set 不 remove：core 的 `Map` 对已存在的键是就地换值，位置不动。
  // 先删后插会让"改一个已有键"悄悄把它挪到末尾——契约要的是插入序保持（hutool/Java `LinkedHashMap` 同档）
  self.forward.set(key, value)
  self.backward.set(value, key)
  old
}

///|
/// ASCII 小写折叠：只动 `A-Z`。非 ASCII 原样——core 没有 Unicode 大小写表
/// （`Char` 连 `to_lowercase` 都没有，见 AGENTS），拖码表进来就是把发布节奏绑到码表上
fn fold_ascii(text : String) -> String {
  let buf = StringBuilder()
  for c in text.to_array() {
    let v = c.to_int()
    if v >= 65 && v <= 90 {
      buf.write_char(ascii_char(v + 32))
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
/// `Int::to_char()` 返回 `Char?`；这里只喂 `[97, 122]`（折叠后的 ASCII 字母），
/// 那个区间全合法，None 分支不可达
fn ascii_char(v : Int) -> Char {
  v.to_char().unwrap()
}

///|
/// 二维表：`行键 × 列键 → 值`，hutool `cn.hutool.core.map.multi.Table`（+ `AbsTable`/`HashBasedTable`）
/// 与 Guava `Table` 的 MoonBit 对位。
///
/// 内部两张索引：`rows` 是行主索引（行 → 列 → 值），`cols` 只记"哪些行在这一列有值"，
/// 用来把列向读取从 O(格数) 降到 O(该列格数)。**值不建第三张索引**（取舍写在 spec §10：
/// 为一件低频查询维护三份一致性，代价大于收益）。
///
/// 字段刻意不公开：两张索引必须同步，放出去单改一张就破坏了列向读取。
pub struct Table[R, C, V] {
  rows : Map[R, Map[C, V]]
  cols : Map[C, Set[R]]
}

///|
/// 建一张空表
///
/// - Note: 两张索引的键都要 `Hash + Eq`——`Map([])` 字面量与 `Set([])` 就要键有界（界是契约的一部分）
pub fn[R : Hash + Eq, C : Hash + Eq, V] Table::new() -> Table[R, C, V] {
  { rows: Map([]), cols: Map([]), }
}

///|
/// 由三元组序列建表：**逐条走 `put`**，所以同格重复给值时后者胜
///
/// - Parameters: `cells`：`(行键, 列键, 值)` 序列。行键序与列键序都由**首次写入**决定
pub fn[R : Hash + Eq, C : Hash + Eq, V] Table::of(
  cells : Array[(R, C, V)],
) -> Table[R, C, V] {
  let t : Table[R, C, V] = Table::new()
  for (r, c, v) in cells {
    // 逐条走 put：合并语义只有一套，不给第二份「同格谁胜」的答案
    let _ = t.put(r, c, v)
  }
  t
}

///|
/// 放一个格，返回该行该列原来的值
///
/// - Returns: 被覆盖的旧值；这个格原本是空的 ⇒ `None`（**新格与覆盖就靠这个区分**）
/// - Note: 覆盖**不挪位**——行列键序都不动（core `Map` 对已存在的键就地换值）。
///   行/列首次出现时才追加到各自索引的末尾
pub fn[R : Hash + Eq, C : Hash + Eq, V] Table::put(
  self : Table[R, C, V],
  row : R,
  column : C,
  value : V,
) -> V? {
  let row_map = self.rows.get_or_init(row, () => Map([]))
  let old = row_map.get(column)
  if old is None {
    // 只有新格才追加列索引：覆盖已有格什么都不挪（行序、列序、size 都不动）
    self.cols.get_or_init(column, () => Set([])).add(row)
  }
  row_map.set(column, value)
  old
}

///|
/// 取一个格：不给默认值、也不猜邻近行列
pub fn[R : Hash + Eq, C : Hash + Eq, V] Table::get(
  self : Table[R, C, V],
  row : R,
  column : C,
) -> V? {
  match self.rows.get(row) {
    Some(row_map) => row_map.get(column)
    None => None
  }
}

///|
/// 删一个格，返回被删的值
///
/// - Note: **删到空就把键一起摘掉**：某行最后一个格被删 ⇒ 该行从 `rows()` 消失；
///   某列最后一个格被删 ⇒ 该列从 `columns()` 消失。留着空行/空列会让 `size()` 与
///   `rows().length()` 说的是两件事，`row()` 也白给一张空 Map
pub fn[R : Hash + Eq, C : Hash + Eq, V] Table::remove(
  self : Table[R, C, V],
  row : R,
  column : C,
) -> V? {
  let row_map = match self.rows.get(row) {
    Some(m) => m
    None => return None
  }
  let gone = match row_map.get(column) {
    Some(v) => v
    None => return None
  }
  let _ = row_map.remove(column)
  if row_map.length() == 0 {
    // 空行不留：`rows()`、`size()`、`row()` 三处读数才不会各说各话
    let _ = self.rows.remove(row)
  }
  match self.cols.get(column) {
    Some(rows_of_col) => {
      rows_of_col.remove(row)
      if rows_of_col.length() == 0 {
        let _ = self.cols.remove(column)
      }
    }
    None => ()
  }
  Some(gone)
}

///|
/// 这个格在不在
pub fn[R : Hash + Eq, C : Hash + Eq, V] Table::contains(
  self : Table[R, C, V],
  row : R,
  column : C,
) -> Bool {
  match self.rows.get(row) {
    Some(row_map) => row_map.contains(column)
    None => false
  }
}

///|
/// 有没有这一行（这行里至少有一个格）
pub fn[R : Hash + Eq, C, V] Table::contains_row(
  self : Table[R, C, V],
  row : R,
) -> Bool {
  let _ = self.rows
  let _ = self.cols
  let _ = row
  self.rows.contains(row)
}

///|
/// 有没有这一列（这列里至少有一个格）
pub fn[R, C : Hash + Eq, V] Table::contains_column(
  self : Table[R, C, V],
  column : C,
) -> Bool {
  let _ = self.rows
  let _ = self.cols
  let _ = column
  self.cols.contains(column)
}

///|
/// 有没有这个值。O(格数) 的遍历——值不建索引是这一件明码的取舍
pub fn[R, C, V : Eq] Table::contains_value(
  self : Table[R, C, V],
  value : V,
) -> Bool {
  let _ = self.rows
  let _ = self.cols
  let _ = value
  // 值不建第三张索引（spec §10 的明码取舍）：这一档就是 O(格数) 遍历
  let mut found = false
  self.rows.each((_, row_map) => {
    if !found {
      row_map.each((_, v) => if v == value { found = true })
    }
  })
  found
}

///|
/// 取一行（列键 → 值），**返回副本**
///
/// - Note: 改它不动表；行不存在 ⇒ 空 Map（不报错，与 `column` 同档）
pub fn[R : Hash + Eq, C : Hash + Eq, V] Table::row(
  self : Table[R, C, V],
  row : R,
) -> Map[C, V] {
  match self.rows.get(row) {
    Some(row_map) => row_map.copy()
    None => Map([])
  }
}

///|
/// 取一列（行键 → 值），**返回副本**；键序是该列有值的行按 `rows()` 的顺序
pub fn[R : Hash + Eq, C : Hash + Eq, V] Table::column(
  self : Table[R, C, V],
  column : C,
) -> Map[R, V] {
  // 沿 `rows()` 的序扫：列向读出来的键序就是行序，与「行序 = 首次写入该行」同一条口径
  let out : Map[R, V] = Map([])
  self.rows.each((r, row_map) => {
    match row_map.get(column) {
      Some(v) => {
        let _ = out.set(r, v)
      }
      None => ()
    }
  })
  out
}

///|
/// 行键序列：**按首次写入该行的顺序**（core `Map` 保插入序，Java 那侧无从承诺）
pub fn[R, C, V] Table::rows(self : Table[R, C, V]) -> Array[R] {
  self.rows.keys().to_array()
}

///|
/// 列键序列：**按首次写入该列的顺序**（与行序无关——`put` 一个新列时追加到末尾）
pub fn[R, C, V] Table::columns(self : Table[R, C, V]) -> Array[C] {
  self.cols.keys().to_array()
}

///|
/// 格数，**不是行×列**：稀疏表里有几格就是几
pub fn[R, C, V] Table::size(self : Table[R, C, V]) -> Int {
  let mut n = 0
  self.rows.each((_, row_map) => n = n + row_map.length())
  n
}

///|
/// 全部格，**行优先展开**：外层按 `rows()` 的序，行内按该行首次写入的列序
///
/// - Note: 这一件取代 hutool 的 `cellSet()` 与 `forEach(Consumer3)`——给一个可断言的数组，
///   而不是两种遍历姿势
pub fn[R, C, V] Table::to_cells(self : Table[R, C, V]) -> Array[(R, C, V)] {
  // 行优先展开：外层按 `rows()`，行内按该行首次写入的列序
  let out : Array[(R, C, V)] = []
  self.rows.each((r, row_map) => row_map.each((c, v) => out.push((r, c, v))))
  out
}

///|
/// 清空成一张空表（两张索引一起清，键序也随之作废）
pub fn[R, C, V] Table::clear(self : Table[R, C, V]) -> Unit {
  self.rows.clear()
  self.cols.clear()
}
