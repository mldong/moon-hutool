///|
/// moon-hutool/coll —— 集合组合件（hutool `CollUtil` / `ListUtil` 高频子集的 MoonBit 对位）
///
/// 契约：`docs/spec/06-coll.md`。期望值权威在 `coll_test.mbt` 与 spec 表——改任何期望串须单独一笔
/// 并给外部读数来源（门禁 G5），实现只负责把契约里冻好的读数算出来。
///
/// 本包的**立身之本是边界**：core 的 `Array`/`List`/`Map`/`Set` 方法面已经很宽（`chunks`、`dedup`、
/// `flatten`、`zip`、`sort_by_key`、`join`、`filter`、`map`、`count_if`、`search_by` 全都有），
/// 凡 core 已有的能力本包**一律不重新包装**，只补下面这几件确实不存在的事：
/// 分组、划分、保序去重、按键去重、频次表、分页、序列版集合运算、极值（含按键）。
/// 逐条"core 有什么、本包补什么"的对照表见 spec §0 与 §9。
///
/// 三条贯穿性规则：
/// 1. **一切保序**。输入是 `Array`，输出也是 `Array`，顺序就是输入顺序；键序是**首现序**
///    （core 的 `Map` 保插入序，这条直接进契约，用例断言 `keys()` 数组）。
/// 2. **空输入是合法输入**，出空数组 / 空 Map，不报错也不给"1 页空页"这种编造。
/// 3. **不发明哨兵值**。找不到极值给 `A?` 而不是 `null`/极小值；要下标就用 core 的 `search_by`
///    （返回 `Int?`），本包不提供 hutool 那种"找不到返回 -1"。

///|
/// 本包唯一错误面：只携带**读数**，不携带文案（同 `codec`/`date`/`id` 的立场）
pub suberror CollError {
  /// 给进来的页号（`< 1` 的那个值；下界恒为 1，不必再带一个常数）
  NonPositivePageNumber(Int)
  /// 给进来的分页大小（`< 1` 的那个值）
  NonPositivePageSize(Int)
  /// 给进来的条目总数（`< 0` 的那个值——它只可能来自上层算错，不是"没有数据"）
  NegativeTotal(Int)
}

///|
/// 按键分组：同一个键的元素进同一个桶
///
/// - Parameters:
///   - `xs`：输入数组，**不被修改**
///   - `key`：取键函数。键的相等与散列由 `K : Hash + Eq` 决定——按整串分组和按首字母分组
///     就是两个不同的 `K`，编译器会逼调用方说清楚
/// - Returns: `Map[K, Array[A]]`。**键序 = 键在输入里的首现序**（core `Map` 保插入序）；
///   每个桶内的元素保持它们在输入里的相对顺序
/// - Note: hutool `CollUtil.groupBy` 的 `MapType` 参数（`ListMap`/`MultiMapMap`/普通 `Map` 三档）
///   在本库不存在——`Map` 保插入序就是唯一一档，要别的形状自己 `.values()`
/// - 复杂度：一次遍历，O(n)
pub fn[A, K : Hash + Eq] group_by(
  xs : Array[A],
  key : (A) -> K,
) -> Map[K, Array[A]] {
  let _ = xs
  let _ = key
  abort("moon-hutool: coll.group_by 未实现（spec 06-coll #6.1）")
}

///|
/// 按谓词划分成两桶：`(满足, 不满足)`
///
/// - Parameters:
///   - `pred`：判定函数。**必须是纯的**——同一元素被调用两次会掉进两个桶，本库不防
/// - Returns: 元组而不是 `Map[Bool, Array[A]]`：只有两档，用 Map 反而要处理"没有 False 桶"
/// - Note: core 的 `filter` 只给一边，`extract_if` 会**改掉输入**；两桶都要且不动输入，
///   就是这一件。hutool 对位 `CollUtil.splitBy`/`ListUtil.partition`
pub fn[A] partition(xs : Array[A], pred : (A) -> Bool) -> (Array[A], Array[A]) {
  let _ = xs
  let _ = pred
  abort("moon-hutool: coll.partition 未实现（spec 06-coll #6.2）")
}

///|
/// 去重并**保留首次出现的位置**
///
/// - Returns: 每个值只留第一次出现那一次，整体顺序 = 输入顺序
/// - Note: core 的 `Array::dedup` 只去**相邻**重复（文档自己写了"要真正去重请先排序"），
///   所以本件是真缺口。**别和 `dedup` 混用**：`[1, 2, 1]` 走 `dedup` 还是 `[1, 2, 1]`，
///   走本函数是 `[1, 2]`。已排序输入上两者同结果——这条由用例里的对拍腿钉住（门禁 G8）
pub fn[A : Hash + Eq] distinct(xs : Array[A]) -> Array[A] {
  let _ = xs
  abort("moon-hutool: coll.distinct 未实现（spec 06-coll #6.3）")
}

///|
/// 按键去重：同一个键只留**第一个**元素
///
/// - Parameters: `key`：选取键的函数。元素本身**不被转换**，留下的是原元素
/// - Note: hutool `CollUtil.distinct` 只能按 `equals` 去值，按字段去重要 `uniq` 那种
///   反射实现——本库无反射，键由闭包给。与 `distinct` 的关系：`key` 取恒等时两者同结果
pub fn[A, K : Hash + Eq] distinct_by(xs : Array[A], key : (A) -> K) -> Array[A] {
  let _ = xs
  let _ = key
  abort("moon-hutool: coll.distinct_by 未实现（spec 06-coll #6.3）")
}

///|
/// 频次表：每个元素出现了几次
///
/// - Returns: `Map[A, Int]`，**键序 = 元素首现序**，值恒 `> 0`（没出现过的键不出现在表里）
/// - Note: core 的 `Array::count(value)` 只数**一个**值，全量统计要自己折——本件就是那一次折。
///   hutool 对位 `CollUtil.countMap`
pub fn[A : Hash + Eq] freq(xs : Array[A]) -> Map[A, Int] {
  let _ = xs
  abort("moon-hutool: coll.freq 未实现（spec 06-coll #6.4）")
}

///|
/// 取第 `page_number` 页（**页号从 1 起**），每页 `page_size` 条
///
/// - Parameters:
///   - `page_number`：页号，1 起。**第 1 页就是开头 `page_size` 条**
///   - `page_size`：每页条数，必须 `>= 1`
/// - Returns: 页号超出总页数 ⇒ **空数组**（不是报错，也不是"返回最后一页"）；
///   最后一页不足 `page_size` 条 ⇒ 给实际条数
/// - Raises: `CollError.NonPositivePageNumber(给的页号)` —— 页号 `< 1`；
///   `CollError.NonPositivePageSize(给的大小)` —— 分页大小 `< 1`。
///   **两档同时非法时先报 `NonPositivePageSize`**（它是除数，除零类错误优先），读数才唯一
/// - Note: hutool `CollUtil.page(pageNo, pageSize)` 走的是 `sub(list, (pageNo-1)*size, size)`，
///   而它的 `sub` **支持负下标**（从尾部数）——于是 `page(0, 10)` 会返回**尾部 10 条**。
///   本库不跟：负数页号是调用点的 bug，报错比"算出一个看着像数据的垃圾"有用
/// - Note: 范围内的页与 core `Array::chunks` 的对应一片同结果（对拍腿，门禁 G8）
pub fn[A] page(
  xs : Array[A],
  page_number : Int,
  page_size : Int,
) -> Array[A] raise CollError {
  let _ = xs
  let _ = page_number
  let _ = page_size
  abort("moon-hutool: coll.page 未实现（spec 06-coll #6.5）")
}

///|
/// 一共几页：`ceil(total / page_size)`
///
/// - Parameters:
///   - `total`：条目总数。`total < 0` **报错**——它只可能来自上层算错，"没有数据"是 0
///   - `page_size`：每页条数，必须 `>= 1`
/// - Returns: `total = 0 ⇒ 0 页`（不是 1 页空页——1 页空页会让 `for p in 1..page_count` 白跑一轮）
/// - Raises: `CollError.NonPositivePageSize(给的大小)`、`CollError.NegativeTotal(给的总数)`
/// - Note: 与 `page` 的配对读法：`page_count(xs.length(), size)` 是页号的上界，
///   越界页号在 `page` 那一档给空数组，两者不矛盾
pub fn page_count(total : Int, page_size : Int) -> Int raise CollError {
  let _ = total
  let _ = page_size
  abort("moon-hutool: coll.page_count 未实现（spec 06-coll #6.7）")
}

///|
/// 并集：**按顺序去重**——先 `a` 的全部，再 `b` 里没出现过的
///
/// - Note: 与 core 的 `Set::union` 的分工：那边给集合（无重复、无位置概念），
///   这边给**可以安全展示的数组**且顺序确定。hutool 对位 `CollUtil.union`（那侧用
///   `LinkedHashSet` 保序，与本库同判）
pub fn[A : Hash + Eq] union(a : Array[A], b : Array[A]) -> Array[A] {
  let _ = a
  let _ = b
  abort("moon-hutool: coll.union 未实现（spec 06-coll #6.8）")
}

///|
/// 交集：`a` 中出现过、且也在 `b` 中出现的值，**按 `a` 的顺序、去重**
///
/// - Note: 结果里每个值只出一次，即使它在 `a` 中出现两次（这是 hutool `CollUtil.intersection`
///   的档位，它同样落在 `LinkedHashSet` 上）。要"按行保留重复"的交集是 join 语义，归 `mapx`
///   之后的批次再看，本包不掺
pub fn[A : Hash + Eq] intersection(a : Array[A], b : Array[A]) -> Array[A] {
  let _ = a
  let _ = b
  abort("moon-hutool: coll.intersection 未实现（spec 06-coll #6.8）")
}

///|
/// 差集：`a` 中不在 `b` 里的**那些行**，**保留 `a` 的重复**
///
/// - Note: 名字用 `subtract` 而不是 `difference`，是为了把这条与 `union`/`intersection`
///   的"去重档"分开——hutool 正是两个方法：`subtract` 保留左侧重复、`disjunction` 是去重的对称差。
///   本库只做 `subtract` 这一件，`disjunction` **不做**（`Set` 已有 `symmetric_difference`，
///   要保序版本再单独提需求）
pub fn[A : Hash + Eq] subtract(a : Array[A], b : Array[A]) -> Array[A] {
  let _ = a
  let _ = b
  abort("moon-hutool: coll.subtract 未实现（spec 06-coll #6.8）")
}

///|
/// 最大值：`None` 表示"没有元素"
///
/// - Returns: 并列时取**第一个**（与 Java `Collections.max` / hutool 一致）。
///   这条不是可选项：不指定的话，实现写 `>=` 就会取到最后一个，读数静默换元素
/// - Note: core 只有 `Iter::maximum`（要先 `.iter()`）与 `List::maximum`，`Array` 上没有——
///   本件是把那条腿直接接在 `Array` 上，语义与 `Iter::maximum` 一致（对拍腿，门禁 G8）
pub fn[A : Compare] maximum(xs : Array[A]) -> A? {
  let _ = xs
  abort("moon-hutool: coll.maximum 未实现（spec 06-coll #6.9）")
}

///|
/// 最小值，口径与 `maximum` 对称（并列取第一个、空给 `None`）
pub fn[A : Compare] minimum(xs : Array[A]) -> A? {
  let _ = xs
  abort("moon-hutool: coll.minimum 未实现（spec 06-coll #6.9）")
}

///|
/// 按键取最大：返回的是**元素本身**，不是键
///
/// - Parameters: `key`：选取用于比较的键。`K : Compare`，所以 `(String, Int)` 这类
///   带序的键也能直接比
/// - Returns: 并列取第一个（同 `maximum`）。空输入 `None`
/// - Note: 这一件是"取分值最高的那条记录"的常用姿势。core 的 `sort_by_key` 已有但那是排序，
///   只要最大时不必付 O(n log n)；`@cmp.maximum_by_key` 只有二元版，没有折叠版
pub fn[A, K : Compare] maximum_by_key(xs : Array[A], key : (A) -> K) -> A? {
  let _ = xs
  let _ = key
  abort("moon-hutool: coll.maximum_by_key 未实现（spec 06-coll #6.10）")
}

///|
/// 按键取最小，口径与 `maximum_by_key` 对称
pub fn[A, K : Compare] minimum_by_key(xs : Array[A], key : (A) -> K) -> A? {
  let _ = xs
  let _ = key
  abort("moon-hutool: coll.minimum_by_key 未实现（spec 06-coll #6.10）")
}
