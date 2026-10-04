# coll

hutool `CollUtil` / `ListUtil` 高频子集的 MoonBit 对位：按键分组、两桶划分、保序去重（含按键）、频次表、分页、序列版并/交/差、极值（含按键）。

完整边界矩阵与逐条读数来源见 [`docs/spec/06-coll.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/06-coll.md)。

> 状态：**契约已冻结、实现未开工**——`coll/coll.mbt` 的函数体是 `abort`，下面每个块的期望值此刻红是设计态。
> 期望串与 `coll_test.mbt` 同受"期望值冻结"约束：实现期只许把红变绿（门禁 G5）。

## 这一包的全部理由是"core 没有哪几件"

core 的集合方法面已经很宽：**`chunks`（定长分片）、`dedup`（只去相邻重复且原地）、`flatten`、`zip`、`join`、
`sort`/`sort_by`/`sort_by_key`、`shuffle`（熵已经要显式传）、`count_if`、`search_by`（返回 `Int?`）全都有**，
本包一个都不重新包装。补的只有这几件：分组、两桶划分、保序全去重、按键去重、频次表、分页、
**在数组上**做并/交/差、以及 `Array` 上的极值。逐条"core 有什么、本包补什么"的对照表在 spec §1，
判据是当场读 `moonbitlang/core` 源码得到的（两个扫描口径与条数写在 spec §1，那里连正则的边界都说清了）。

还有一条语言层面的事实决定了本包的形状：**core 没有 `Iterator`/`Iterable` trait**——`Iter[X]` 是具体结构体，
各集合靠 duck-typing 各自提供 `iter()`。所以"一个函数服务所有集合"写不出来，本包收 `Array[A]`、出 `Array[A]`，
索引与顺序都是明码契约；`List` 用户 `.to_array()` 一次。

## 分组与划分

`group_by` 的键序是**键在输入里的首现序**（core 的 `Map` 保插入序），桶内保原序——这两条都是用例直接断言的契约，
不是实现细节。`partition` 只给两桶的元组：只有两档，用 `Map[Bool, Array[A]]` 反而要处理"没有 False 桶"。

```mbt check
///|
test "分组看键序，划分看两桶" {
  let m = @coll.group_by([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5], x => x % 3)
  assert_eq(m.keys().to_array(), [0, 1, 2])
  assert_eq(m.get(0), Some([3, 9, 6, 3]))
  assert_eq(m.get(2), Some([5, 2, 5, 5]))
  // 键可以是任意 `Hash + Eq` 的类型，这里按键就是首字母（Char）
  let g = @coll.group_by(["apple", "bee", "ant", "cat", "bear", "a"], s => {
    s.to_array()[0]
  })
  assert_eq(g.keys().to_array(), ['a', 'b', 'c'])
  assert_eq(g.get('a'), Some(["apple", "ant", "a"]))
  let (even, odd) = @coll.partition([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5], x => {
    x % 2 == 0
  })
  assert_eq(even, [4, 2, 6])
  assert_eq(odd, [3, 1, 1, 5, 9, 5, 3, 5])
  assert_eq(@coll.partition([1, 2, 3], _ => true), ([1, 2, 3], []))
}
```

## 去重：`dedup` 与本包不是一件事

core 的 `Array::dedup` **只去相邻重复、原地改输入**，文档自己写了"要真正去重请先排序"。
所以 `[1, 2, 1]` 走 `dedup` 还是 `[1, 2, 1]`，走本包的 `distinct` 是 `[1, 2]`。两者在**已排序**输入上同结果——
这条不是巧合，是下面那句对拍断言的内容。

```mbt check
///|
test "保序去重、按键去重与 dedup 的分工" {
  assert_eq(@coll.distinct([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]), [
    3, 1, 4, 5, 9, 2, 6,
  ])
  assert_eq(@coll.distinct([1, 2, 1]), [1, 2])
  assert_eq(@coll.distinct([7, 7, 7]), [7])
  // 按键去重：留下的是原元素，不是键
  assert_eq(
    @coll.distinct_by(["apple", "bee", "ant", "cat", "bear", "a"], s => {
      s.char_length()
    }),
    ["apple", "bee", "bear", "a"],
  )
  // 对拍腿：已排序输入上，本包的 distinct 与 core 的原地 dedup 同结果
  let sorted_arr = [1, 1, 2, 3, 3, 4, 5, 5, 5, 6, 9]
  let via_core = sorted_arr.copy()
  via_core.dedup()
  assert_eq(@coll.distinct(sorted_arr), via_core)
  let f = @coll.freq([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5])
  assert_eq(f.keys().to_array(), [3, 1, 4, 5, 9, 2, 6])
  assert_eq(f.get(5), Some(3))
  assert_eq(@coll.freq(["a", "b", "a"]).get("b"), Some(1))
}
```

## 分页：页号 1 起，越界给空数组

hutool 的 `CollUtil.page(pageNo, pageSize)` 走 `sub(list, (pageNo-1)*size, size)`，而那侧的 `sub` **支持负下标**
（从尾部数）——于是 `page(0, 10)` 会返回**尾部 10 条**。本库不跟：页号 `< 1` 是调用点的 bug，
报错比"算出一个看着像数据的垃圾"有用。分页大小 `< 1` 同理，且**两档同时非法时先报分页大小**（它是除数）。

```mbt check
///|
test "分页的三档：正常页、最后一页不满、越界" {
  let ten = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  assert_eq(@coll.page(ten, 1, 3), [1, 2, 3])
  assert_eq(@coll.page(ten, 2, 3), [4, 5, 6])
  assert_eq(@coll.page(ten, 4, 3), [10])
  // 越界是空数组，不是报错，也不是"给你最后一页"
  assert_eq(@coll.page(ten, 5, 3), [])
  assert_eq(@coll.page([1, 2, 3], 1, 5), [1, 2, 3])
  // 范围内的页 == core chunks 的对应一片（对拍腿）
  assert_eq(@coll.page(ten, 3, 3), ten.chunks(3)[2].to_owned())
  // 0 条是 0 页，不是 1 页空页
  assert_eq(@coll.page_count(10, 3), 4)
  assert_eq(@coll.page_count(9, 3), 3)
  assert_eq(@coll.page_count(0, 3), 0)
  let bad = try {
    let _ = @coll.page(ten, 0, 3)
    "没抛错"
  } catch {
    @coll.NonPositivePageNumber(n) => "NonPositivePageNumber \{n}"
    _ => "错种"
  }
  assert_eq(bad, "NonPositivePageNumber 0")
}
```

## 序列版并 / 交 / 差：重复口径是两条，不是一条

core 的 `union`/`intersection`/`difference` 都在**集合类型**上（`Set`/`HashSet`），`Array` 上一个都没有。
本包的三件里，去重口径**不是统一的**：`union`/`intersection` 去重（落在首现序上），而 `subtract` **保留左侧重复**
——`subtract([1,1,2],[9])` 出 `[1,1,2]`。这正是 hutool 那侧 `CollUtil.union`（`LinkedHashSet` 版）与
`CollUtil.subtract`（数组版）的分工；把它记成"三个都去重"就会静默少掉行。

```mbt check
///|
test "去重的两个、保留左侧重复的那一个" {
  let a = [1, 2, 2, 3]
  let b = [2, 3, 4]
  assert_eq(@coll.union(a, b), [1, 2, 3, 4])
  assert_eq(@coll.union(b, a), [2, 3, 4, 1])
  assert_eq(@coll.intersection(a, b), [2, 3])
  assert_eq(@coll.subtract(a, b), [1])
  assert_eq(@coll.subtract([1, 1, 2], [9]), [1, 1, 2])
  assert_eq(@coll.subtract(b, a), [4])
  assert_eq(@coll.union([], [1, 1, 2]), [1, 2])
  assert_eq(@coll.intersection([1, 2], []), [])
}
```

## 极值：并列取**第一个**

`Array` 上没有 `maximum`/`minimum`（core 只在 `Iter` 与 `List` 上给了），`@cmp.maximum_by_key` 又是**二元**版。
本包四件都收在同一句话上：空输入 `None`，**并列取第一个**——实现写成 `>=` 就会取到最后一个，
读数静默换了元素，所以这条单独立档。

```mbt check
///|
test "极值的三档：正常、并列、空" {
  assert_eq(@coll.maximum([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]), Some(9))
  assert_eq(@coll.minimum([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]), Some(1))
  // 并列取第一个，不是最后一个
  assert_eq(@coll.maximum([2, 5, 5, 1]), Some(5))
  assert_eq(@coll.minimum([5, 1, 1, 2]), Some(1))
  let es : Array[Int] = []
  assert_eq(@coll.maximum(es), None)
  // 按键取极值：比的是键，返回的是元素本身
  let recs = [("x", 5), ("y", 9), ("z", 9), ("w", 1)]
  assert_eq(@coll.maximum_by_key(recs, r => r.1), Some(("y", 9)))
  assert_eq(@coll.minimum_by_key(recs, r => r.1), Some(("w", 1)))
  // 对拍腿：与 core 的 Iter::maximum / Iter::minimum 同结果
  let xs = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
  assert_eq(@coll.maximum(xs), xs.iter().maximum())
  assert_eq(@coll.minimum(xs), xs.iter().minimum())
}
```

## 这一层不做的事

`isEmpty`/`isNotEmpty`（core 到处都有 `is_empty`，要否定就写 `!`）、`addAll`/`removeAll`/`join`/`flatten`/
`zip`/`sort*`/`shuffle`/`count_if`（core 全有）、`index_where` 那种"找不到返回 `-1`"的哨兵（要下标用
core 的 `search`/`search_by`，它们给 `Int?`）、`disjunction`（对称差，`Set::symmetric_difference` 已有）、
链式 `Query`/`CollStream` 流式管道（`Iter` 是具体结构体、没有 trait，链式件要么绑死一种集合要么造假的通用抽象）、
`List[A]`/`Deque[A]` 的平行一套 API（同一契约写两遍必然漂移）、加权抽样（归 `rand`）。
二维表 `Table`、`BiMap`、`CaseInsensitiveMap` 归 `mapx`。逐条理由见 [`docs/ROADMAP.md`](https://github.com/mldong/moon-hutool/blob/master/docs/ROADMAP.md)
的「暂不做」「不做」两节与 spec §1、§5。
