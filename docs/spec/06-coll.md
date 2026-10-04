# 契约 06 · coll（集合组合件）

> 状态：**契约已冻结、实现未开工**。签名骨架在 `coll/coll.mbt`（函数体是 `abort`），公开接口在
> `coll/pkg.generated.mbti`，期望值在 `coll/coll_test.mbt` 与 `coll/README.mbt.md`——本包用例此刻全红是设计态。
> 实现那一笔只许把红变绿；改任何期望串须单独一笔并给外部读数来源（门禁 G5）。
>
> 与 `codec`/`date`/`id` 不同，本包的**主要工作是划边界**：core 的集合方法面已经很宽，
> 能数出来的缺口只有十来个。§1 那张表就是本包的存在理由——不在表里的能力一律不重新包装。

## 0. 三条贯穿性规则

| # | 规则 | 为什么 |
|---|---|---|
| 0.1 | **一切保序**。输入 `Array[A]`，输出 `Array[A]`；`Map` 的键序 = 键的**首现序** | core 的 `Map`/`Set` 保插入序（`linked_hash_map.mbt`/`linked_hash_set.mbt`），这条在本库不是实现细节而是契约：`group_by`/`freq` 的用例直接断言 `keys().to_array()` 这个数组。不写死的话，实现换成 `HashMap` 也是绿的，而下游拿到的顺序就变了 |
| 0.2 | **空输入是合法输入**，出空数组 / 空 Map | hutool 那侧 `CollUtil.isEmpty` 与一堆 `null` 返回混在一起；本库无 null，`page` 越界给空数组、`maximum` 空给 `None`，都是同一句话的两个方向 |
| 0.3 | **不发明哨兵值** | 找不到极值给 `A?`，不给 `-1`/最小值/`null`。**要下标就用 core 已有的 `Array::search_by`（返回 `Int?`）**——hutool 的 `CollUtil.indexOf` 那种"找不到返回 -1"在本库不出现，因为 `-1` 与"合法下标 -1"要靠注释区分，而注释不参与编译 |

## 1. 与 core 的边界（本包只做这张表右列的事）

判据是**读 core 源码**得出的，不是"我以为没有"。计数口径写在表下，两个数都由当场扫描得到。

| 能力 | core 已经有什么（当场核对过） | 本包 |
|---|---|---|
| 定长分片 / 滑窗 | `Array::chunks(Int) -> Array[ArrayView[A]]`、`chunk_by`、`windows`、`suffixes`（`ArrayView`/`ReadOnlyArray`/`Deque` 上同一套） | **不做**，只把 `chunks` 用作 `page` 的对拍腿 |
| 相邻去重 | `Array::dedup(self) -> Unit`（**原地**、只去相邻、文档自己写"要全去重请先排序"） | **做保序全去重** `distinct`，并在已排序输入上与它对拍 |
| 按键去重 | 无（`uniq_by`/`distinct_by` 零命中） | **做** `distinct_by` |
| 分组 | 无（`group_by`/`groupby` 零命中；最近的是 `HashMap::get_or_init`/`update_or_default` 手工拼） | **做** `group_by` |
| 两桶划分 | 无公开件（`fixed_partition*` 是快排私有内部件；`extract_if` **会改输入**） | **做** `partition` |
| 频次表 | `Array::count(value)` 只数**一个**值；全量统计无（`frequency` 命中只在 quickcheck 的加权生成器里） | **做** `freq` |
| 分页 | 无（`page`/`paginate` 零命中）；可拼 `get_view(start?, end?)`/`clamped_view` | **做** `page` + `page_count`，并与 `chunks` 对拍 |
| 序列版并/交/差 | 只在**集合类型**上有：`Set`/`HashSet` 的 `union`/`intersection`/`difference`/`symmetric_difference`；`Array`/`List`/`Deque`/`Iter` 上**一个都没有** | **做** `union`/`intersection`/`subtract`（带顺序与重复口径的数组版） |
| 极值 | `Iter::maximum`/`minimum`（要先 `.iter()`）、`List::maximum`/`minimum`；`Array` 上没有；`@cmp` 的 `maximum_by_key`/`minmax_by_key` 是**二元**版，没有折叠版 | **做** `maximum`/`minimum`/`maximum_by_key`/`minimum_by_key`，前两个与 `Iter::maximum`/`minimum` 对拍 |
| 展平 / 拉链 / 拼接 / 排序 / 洗牌 | `Array::flatten`、`zip`、`@array.zip_with`、`unzip`、`join`、`sort`/`sort_by`/`sort_by_key`、`shuffle(rand~)`（熵已是显式参数） | **全部不做**，签名里不出现同名的第二套 |
| 计数 / 谓词计数 | `count`/`count_if`、`all`/`any`/`is_empty` | **不做**，也不造 `isNotEmpty`（core 的立场是 `!is_empty()`） |
| 找下标 | `Array::search(value)`、`search_by(f)`（都返回 `Int?`，`search_by` 还有 `find_index` 别名） | **不做** `index_where`——hutool 的 `-1` 哨兵在本库没有位置 |

**扫描口径与读数**（写在这里是为了让"core 有什么"这句话可以被复跑，而不是等下一个人重新 grep）：
`moonbitlang/core` 版本 `0.10.14+7d59c7ec9`。**两个口径都当场扫，别再手写第三个数**：
按 `pub fn[...] Array::name` 的**声明**扫（含回溯 3 行找 `#doc(hidden)`）得 **109 条声明，其中 33 条 `#doc(hidden)`**
（绝大多数是 `unsafe_extract_*` 那批位抽取内部件），**对外可写约 76 条**；
按 core 自己生成的接口文件 `builtin/pkg.generated.mbti` 里 `Array::` 去重数得 **111 条**。
两数之差就是"声明扫描"这种正则口径的边界（多行 `fn` 头、trait 提升的算子件），所以这里给的是**量级 + 口径**，
不是"精确到个位的方法数"。同口径下 `ArrayView` 52 条、`List` 62 条、`Set` 28 条、`Map` 32 条、`Deque` 57 条
（这几条与各自 `pkg.generated.mbti` 的条目数逐一对上过）。**ROADMAP 早期那行"Array 已有 123 方法"
是个没数过的手写读数，本轮已改。**
口径差异说清楚：109 与 76 的差是"能不能被文档看到"，不是"能不能调用"。

**本包为什么收 `Array` 而不是收"任意可迭代的东西"**：core **没有 `Iterator`/`Iterable` trait**——`Iter[X]` 是
具体结构体（`builtin/iterator.mbt:23`），各集合靠 duck-typing 各自提供 `iter()`。所以"一个函数服务所有集合"
在这门语言里写不出来；收 `Array` 换来的是索引与顺序都是明码契约，代价是 `List` 用户自己 `.to_array()`（O(n)，
一次调用而不是每次都要读的分支）。

## 2. 错误面

| 签名 | 语义 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `pub suberror CollError { NonPositivePageNumber(Int) NonPositivePageSize(Int) NegativeTotal(Int) }` | 本包唯一错误面，只带**给进来的那个值** | — | hutool 抛 `IllegalArgumentException`，文案里夹着数字 | 下界恒为 1，是常数，所以**不再多带一个 1**（同 `codec` 的 `ChecksumMismatch` 不带读数这条判断）；三个变体各带一个读数 | 定义即契约 |

**校验顺序只有一处，写死**：`page` 与 `page_count` 的**分页大小先判**（它是除数，除零类错误优先），
于是 `page_count(-1, 0)` 报 `NonPositivePageSize 0` 而不是 `NegativeTotal -1`。不写死这一条，两个非法参数
同时出现时报哪个就靠实现者心情，用例也无法冻结。

## 3. 契约矩阵（行号 = 用例号 `#6.x`）

| # | 签名 | 冻结读数（夹具与期望都由镜像现算） | 边界/错误 | hutool 对位 | 差异声明 |
|---|---|---|---|---|---|
| 6.1 | `group_by[A, K : Hash + Eq](xs : Array[A], key : (A) -> K) -> Map[K, Array[A]]` | `[3,1,4,1,5,9,2,6,5,3,5]` 按 `x % 3` → 键序 `[0, 1, 2]`，`0 ⇒ [3,9,6,3]`、`1 ⇒ [1,4,1]`、`2 ⇒ [5,2,5,5]`；`["apple","bee","ant","cat","bear","a"]` 按首字母 → 键序 `['a','b','c']`，`'a' ⇒ ["apple","ant","a"]` | 空输入 ⇒ 空 Map（`keys()` 为空、`length() = 0`）；**不修改输入** | `CollUtil.groupBy(coll, func, MapType)` | hutool 的第三个参数在三种 `Map` 实现间选（`ListMultiMap` 等）；本库只有 `Map[K, Array[A]]` 一档，`Map` 保插入序就是键序契约 |
| 6.2 | `partition[A](xs : Array[A], pred : (A) -> Bool) -> (Array[A], Array[A])` | `[3,1,4,1,5,9,2,6,5,3,5]` 按偶数 → `([4,2,6], [3,1,1,5,9,5,3,5])`；六个词按"长度 3" → `(["bee","ant","cat"], ["apple","bear","a"])` | 恒不失败；`pred` 要求纯（同元素被调两次会掉进两个桶，本库不防）；全真 ⇒ 第二桶空；空输入 ⇒ 两桶都空 | `CollUtil.splitBy` / `ListUtil.partition` | core 的 `filter` 只给一边，`extract_if` **原地改输入**；本件两边都给且不动输入 |
| 6.3 | `distinct[A : Hash + Eq](xs : Array[A]) -> Array[A]`、`distinct_by[A, K : Hash + Eq](xs, key)` | `distinct([3,1,4,1,5,9,2,6,5,3,5]) = [3,1,4,5,9,2,6]`；`distinct([7,7,7]) = [7]`；六个词全不同 ⇒ 原样；`distinct_by(words, char_length) = ["apple","bee","bear","a"]`（`bee`/`ant`/`cat` 都是 3 个字符，只留第一个）；`distinct_by([9,8,6], x => x % 3) = [9,8]` | 空输入 ⇒ 空数组；**首现**胜出而不是尾现 | `CollUtil.distinct` / `filterUnique` | 与 core `dedup` 的分工写进名字：`dedup` 只去相邻且原地，`distinct` 保序全去重新建数组。已排序输入上两者同结果（对拍腿，门禁 G8） |
| 6.4 | `freq[A : Hash + Eq](xs : Array[A]) -> Map[A, Int]` | `[3,1,4,1,5,9,2,6,5,3,5]` → 键序 `[3,1,4,5,9,2,6]`，值 `3⇒2, 1⇒2, 4⇒1, 5⇒3, 9⇒1, 2⇒1, 6⇒1`；六个词 ⇒ `length() = 6` | 空输入 ⇒ 空 Map；值恒 `> 0`（没出现过的键**不出现在表里**，不出 `0` 键） | `CollUtil.countMap` | core 的 `count(value)` 是单值档；全量折一次就是本件。键序同上，是契约 |
| 6.5 | `page[A](xs : Array[A], page_number : Int, page_size : Int) -> Array[A] raise CollError` | `[1..10]` 每页 3 条：第 1 页 `[1,2,3]`、第 2 页 `[4,5,6]`、第 3 页 `[7,8,9]`、第 4 页 `[10]`；`page([1,2,3], 2, 3) = []`；`page([1,2,3], 1, 5) = [1,2,3]` | 页号 **1 起**；越界 ⇒ **空数组**（不报错、不返回最后一页）；`page_number < 1` ⇒ `NonPositivePageNumber`；`page_size < 1` ⇒ `NonPositivePageSize`（两档同时非法先报分页大小） | `CollUtil.page(pageNo, pageSize)` | **不跟 hutool 的负下标**：那侧 `page(0, 10)` 会经 `sub(list, -10, 10)` 返回**尾部 10 条**。本库把这种调用当 bug 报错。范围内的页与 core `chunks(size)[n-1]` 同结果（对拍腿） |
| 6.6 | 同上 + `page_count` 的非法档 | `page([1,2,3], 0, 1)` → `NonPositivePageNumber 0`；`page([1,2,3], -1, 1)` → `NonPositivePageNumber -1`；`page([1,2,3], 1, 0)` → `NonPositivePageSize 0`；`page([1,2,3], 1, -3)` → `NonPositivePageSize -3`；`page_count(10, 0)` → `NonPositivePageSize 0` | 读数就是给进来的那个值 | `Assert`/`IllegalStateException` 混用 | 错误只带读数不带文案（同 `codec`） |
| 6.7 | `page_count(total : Int, page_size : Int) -> Int raise CollError` | `(10,3)⇒4`、`(9,3)⇒3`、`(1,3)⇒1`、`(0,3)⇒0`、`(11,5)⇒3`、`(100,1)⇒100`、`(7,7)⇒1`、`(7,8)⇒1` | `total = 0 ⇒ 0` 页（**不是 1 页空页**：那会让 `for p in 1..page_count` 白跑一轮）；`total < 0` ⇒ `NegativeTotal`；`page_size < 1` ⇒ `NonPositivePageSize` | `CollUtil.count(list, pageSize)` 那一类分页算式 | 与 `page` 配对读：`page_count(xs.length(), size)` 是页号上界，越界页号仍给空数组，两者不矛盾 |
| 6.8 | `union`/`intersection`/`subtract`，均 `[A : Hash + Eq](a : Array[A], b : Array[A]) -> Array[A]` | `a=[1,2,2,3]`、`b=[2,3,4]`：`union(a,b)=[1,2,3,4]`、`union(b,a)=[2,3,4,1]`、`intersection(a,b)=[2,3]`、`intersection(b,a)=[2,3]`、`subtract(a,b)=[1]`、`subtract(b,a)=[4]`；`union([],[1,1,2])=[1,2]`；`subtract([1,1,2],[9])=[1,1,2]` | 空输入出空数组；`intersection` 的结果每个值**只出一次**（即使它在 `a` 里出现两次）；`subtract` **保留 `a` 的重复** | `CollUtil.union` / `intersection` / `subtract` | 三条都在**数组**上做（core 的同名件在 `Set` 上）：`union`/`intersection` 去重、`subtract` 不去重，正是 hutool 那侧 `LinkedHashSet` 版与数组版的分工。`disjunction`（去重的对称差）**不做**——`Set::symmetric_difference` 已有，要保序版另提需求 |
| 6.9 | `maximum[A : Compare](xs : Array[A]) -> A?`、`minimum` | `[3,1,4,1,5,9,2,6,5,3,5]` → `Some(9)` / `Some(1)`；`maximum([2,5,5,1]) = Some(5)`；`minimum([5,1,1,2]) = Some(1)`；`maximum([7]) = Some(7)` | 空输入 ⇒ `None`；**并列取第一个**（写 `>=` 就会取到最后一个，读数静默换元素，所以这条单独立档） | `CollUtil.max(coll)` / Java `Collections.max` | core 只有 `Iter::maximum`（要先 `.iter()`）与 `List::maximum`，`Array` 上没有；语义与 `Iter::maximum` 对拍（同输入同结果，门禁 G8） |
| 6.10 | `maximum_by_key[A, K : Compare](xs, key : (A) -> K) -> A?`、`minimum_by_key` | `[("x",5),("y",9),("z",9),("w",1)]` 按 `.1` → `Some(("y", 9))` / `Some(("w", 1))`；`["a","bbb","cc"]` 按 `char_length` → `Some("bbb")` / `Some("a")` | 空输入 ⇒ `None`；并列取第一个（同 6.9）；返回**元素本身**，不是键 | `CollUtil.max(coll, comparator)` | `@cmp.maximum_by_key` 是**二元**版（比两个值），没有折叠版；`Array::sort_by_key` 有但那是排序，取最大不必付 O(n log n) |
| 6.11 | 边界三档（单元素 / 全相同 / 空） | `group_by([1], x => x)` → 键 `[1]`、`get(1) = Some([1])`；`distinct([2,2,2,2]) = [2]`；`freq([2,2,2,2])` 键 `[2]`、值 `4`；`partition([2,2,2], ==2)` → `([2,2,2], [])`；`union([2,2],[2,2]) = [2]`；`subtract([2,2],[2]) = []`；`page([2,2],1,1) = [2]`；`page_count(4,2) = 2`；`maximum([2,2,2]) = Some(2)` | — | — | 这一档的用意是"空/单元素/全相同不会让别的档变形"，实现期最容易在 `is_empty` 分支上写错 |

## 4. 读数从哪来

本包没有官方向量表（不是编码，是纯函数语义），所以**权威是定义 + 第二套实现**：

1. **Python 镜像**：`group_by`/`partition`/`distinct(_by)`/`freq`/`page`/`page_count`/`union`/`intersection`/
   `subtract`/`maximum(_by_key)`/`minimum(_by_key)` 各写一份独立实现（`dict` 保插入序 = `Map` 保插入序，
   `set` 做首现判定，切片写 `(n-1)*size`），用**同一批夹具**跑出的值灌成断言。测试文件里没有一条是我手算誊的。
2. **对拍腿（门禁 G8）三条**：`distinct` ↔ core `Array::dedup`（已排序输入）、`page` ↔ core `Array::chunks`
   （范围内页号）、`maximum`/`minimum` ↔ core `Iter::maximum`/`Iter::minimum`。这三条的作用不是"复用 core"，
   而是**core 改语义时本包立刻露出来**。
3. **hutool 侧只用来反推语义**，不搬实现、不写 Java 式表达式（红线二）；负下标那档的差异（§3 6.5）
   就是读 `CollUtil.page` → `sub` 这条链时发现的，处理方式是在本库把它掐掉并报错。

## 5. 这一批不做

| 格子 | 结论 | 依据 |
|---|---|---|
| `isEmpty` / `isNotEmpty` / `addAll` / `removeAll` / `join` / `flatten` / `zip` / `sort*` / `shuffle` / `count_if` / `search_by` | **不做** | core 全都有（§1 逐条核对过），再包一层就是第二个名字同一件事 |
| `index_where`（找不到返 `-1`） | **不做** | 哨兵值；core `search`/`search_by` 给 `Int?`，那条是正解 |
| `disjunction`（对称差） | **不做** | `Set::symmetric_difference` 已有；数组保序版需求没到 |
| 链式 `Query`/`CollStream` 流式管道 | **不做** | `Iter[X]` 是具体结构体、无 trait，链式件要么绑死一种集合要么造一个假的"通用可迭代"抽象；需要惰性就 `.iter()` + core 那 41 个方法 |
| `List[A]`/`Deque[A]` 的平行一套 API | **不做** | 同一契约写两遍必然漂移；`List` 用户 `.to_array()` 一次 |
| 二维表 `Table`、`BiMap`、`CaseInsensitiveMap`、`Set` 组合子 | 归 **mapx**（第 7 行） | 键空间与相等性口径是 Map 层的事，混进 coll 会让本包的边界表失去意义 |
| 加权抽样、`Iter` 上的 `chunks`（无界流分片） | **不做 / 排后** | 前者归 `rand`；后者要的是"迭代器适配"，与本包收 `Array` 的立场冲突，真需要时单独一批并先把 trait 缺口写清楚 |

## 6. 血统与来源汇总

| 格子 | 真上游 | 备注 |
|---|---|---|
| 本包全部公开项 | hutool `cn.hutool.core.collection.CollUtil` / `ListUtil` 的**语义档位**（分组、划分、去重、分页、集合运算、极值） | **不搬实现**：Java 那侧靠 `Iterator`/`Collection` 抽象与反射式 `filterUnique`，本库靠显式闭包与 `Hash + Eq` 约束。逐档差异写在 §3 的"差异声明"列，其中 `page` 的负下标一档是**明确不跟随** |
| 顺序口径（键序 = 首现序、结果保输入序） | MoonBit core 的 `Map`/`Set` **保插入序**这一实现事实（`builtin/linked_hash_map.mbt`） | 本库把它升格成契约并写用例；core 若改这个口径，对拍腿与 `keys()` 断言会一起红 |
| 并列取第一个 | Java `Collections.max`（文档明写 return the first occurrence）+ hutool `CollUtil.max` 走同一 JDK 件 | 冻结成 6.9/6.10 的独立断言 |
