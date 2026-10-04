// moon-hutool/coll 契约用例（黑盒）。
//
// 状态：**契约已冻结、实现未开工**——函数体是 `abort`，所以本包用例此刻全红是设计态。
// 期望值先冻结、后实现；实现期改任何期望串 = 门禁 G5 拦下，须单独一笔并给外部读数来源。
//
// 读数权威（逐条来源见 docs/spec/06-coll.md 的「读数来源」列）：
// - 本包所有期望值由一个 **Python 镜像**现算（同一批夹具、同一套定义，两套独立实现互相对跑），
//   不是凭记忆誊写。镜像只负责给数，MoonBit 侧负责把数钉成断言。
// - 对拍腿（门禁 G8）三条，钉的是"core 改语义时本包立刻露出来"：
//   `distinct` 在**已排序**输入上与 core `Array::dedup` 同结果；`page` 在范围内与 core
//   `Array::chunks` 的对应一片同结果；`maximum`/`minimum` 与 core `Iter::maximum`/`minimum` 同结果。
// - 并列口径（`maximum` 与 `maximum_by_key` 取**第一个**最大值）与 hutool / Java
//   `Collections.max` 一致；`subtract` **保留左侧重复**而 `union`/`intersection` 去重，
//   这两档都是 hutool `CollUtil.subtract` / `union` / `intersection` 的原样语义。
// - 键序口径：core 的 `Map` **保插入序**，所以 `group_by`/`freq` 的键序就是键的首现序。
//   这条不是实现细节而是契约，用例直接断言 `keys()` 这个数组。
//
// 三条最容易写错的档各占一条独立用例：**页号 1 起且越界给空数组**（#6.5）、
// **`subtract` 不去重而 `union` 去重**（#6.8）、**并列取第一个而不是最后一个**（#6.9 / #6.10）。

///|
/// 把错误面折成字符串：变体名 + 携带值一起进断言——携带值也是契约的一部分。
fn show(err : @coll.CollError) -> String {
  match err {
    @coll.NonPositivePageNumber(n) => "NonPositivePageNumber \{n}"
    @coll.NonPositivePageSize(n) => "NonPositivePageSize \{n}"
    @coll.NegativeTotal(n) => "NegativeTotal \{n}"
  }
}

///|
/// 跑一次预期会 raise 的调用，返回错误形状；没 raise 就返回「未抛错」。
fn[A] err_shape(g : () -> A raise @coll.CollError) -> String {
  try {
    let _ = g()
    "未抛错"
  } catch {
    err => show(err)
  }
}

///|
test "@coll #6.1 group_by：键序＝键的首现序，桶内保原序" {
  let m = @coll.group_by([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5], x => x % 3)
  assert_eq(m.keys().to_array(), [0, 1, 2])
  assert_eq(m.get(0), Some([3, 9, 6, 3]))
  assert_eq(m.get(1), Some([1, 4, 1]))
  assert_eq(m.get(2), Some([5, 2, 5, 5]))
  let g = @coll.group_by(["apple", "bee", "ant", "cat", "bear", "a"], s => {
    s.to_array()[0]
  })
  assert_eq(g.keys().to_array(), ['a', 'b', 'c'])
  assert_eq(g.get('a'), Some(["apple", "ant", "a"]))
  assert_eq(g.get('b'), Some(["bee", "bear"]))
  assert_eq(g.get('c'), Some(["cat"]))
  let empty_nums : Array[Int] = []
  assert_eq(@coll.group_by(empty_nums, x => x % 3).keys().to_array(), [])
  assert_eq(@coll.group_by(empty_nums, x => x % 3).length(), 0)
}

///|
test "@coll #6.2 partition：两桶各自保序，恒不失败（含全真/全假/空三档）" {
  let (even, odd) = @coll.partition([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5], x => {
    x % 2 == 0
  })
  assert_eq(even, [4, 2, 6])
  assert_eq(odd, [3, 1, 1, 5, 9, 5, 3, 5])
  let (three, rest) = @coll.partition(
    ["apple", "bee", "ant", "cat", "bear", "a"],
    s => s.char_length() == 3,
  )
  assert_eq(three, ["bee", "ant", "cat"])
  assert_eq(rest, ["apple", "bear", "a"])
  let (all_true, none_true) = @coll.partition([1, 2, 3], _ => true)
  assert_eq(all_true, [1, 2, 3])
  assert_eq(none_true, [])
  let empty_s : Array[String] = []
  let (e1, e2) = @coll.partition(empty_s, _ => false)
  assert_eq(e1, [])
  assert_eq(e2, [])
}

///|
test "@coll #6.3 distinct / distinct_by：首现胜出（不是尾现，也不是排序后去重）" {
  assert_eq(@coll.distinct([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]), [
    3, 1, 4, 5, 9, 2, 6,
  ])
  assert_eq(@coll.distinct(["apple", "bee", "ant", "cat", "bear", "a"]), [
    "apple", "bee", "ant", "cat", "bear", "a",
  ])
  let empty_i : Array[Int] = []
  assert_eq(@coll.distinct(empty_i), [])
  assert_eq(@coll.distinct([7, 7, 7]), [7])
  assert_eq(
    @coll.distinct_by(["apple", "bee", "ant", "cat", "bear", "a"], s => {
      s.char_length()
    }),
    ["apple", "bee", "bear", "a"],
  )
  assert_eq(@coll.distinct_by([1, 2, 3], x => x % 3), [1, 2, 3])
  assert_eq(@coll.distinct_by([4, 5, 6], x => x % 3), [4, 5, 6])
  assert_eq(@coll.distinct_by([9, 8, 6], x => x % 3), [9, 8])
  let sorted_arr = [1, 1, 2, 3, 3, 4, 5, 5, 5, 6, 9]
  let via_core = sorted_arr.copy()
  via_core.dedup()
  assert_eq(@coll.distinct(sorted_arr), via_core)
}

///|
test "@coll #6.4 freq：键序＝首现序，值是每个元素出现的次数" {
  let f = @coll.freq([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5])
  assert_eq(f.keys().to_array(), [3, 1, 4, 5, 9, 2, 6])
  assert_eq(f.get(3), Some(2))
  assert_eq(f.get(1), Some(2))
  assert_eq(f.get(4), Some(1))
  assert_eq(f.get(5), Some(3))
  assert_eq(f.get(9), Some(1))
  assert_eq(f.get(2), Some(1))
  assert_eq(f.get(6), Some(1))
  let fw = @coll.freq(["apple", "bee", "ant", "cat", "bear", "a"])
  assert_eq(fw.keys().to_array(), ["apple", "bee", "ant", "cat", "bear", "a"])
  assert_eq(fw.length(), 6)
  let empty_w : Array[String] = []
  assert_eq(@coll.freq(empty_w).keys().to_array(), [])
}

///|
test "@coll #6.5 page：页号 1 起，越界给空数组而不是报错" {
  assert_eq(@coll.page([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 1, 3), [1, 2, 3])
  assert_eq(@coll.page([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 2, 3), [4, 5, 6])
  assert_eq(@coll.page([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 3, 3), [7, 8, 9])
  assert_eq(@coll.page([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 4, 3), [10])
  let empty_s : Array[String] = []
  assert_eq(@coll.page(empty_s, 1, 3), [])
  assert_eq(@coll.page([1, 2, 3], 1, 3), [1, 2, 3])
  assert_eq(@coll.page([1, 2, 3], 1, 5), [1, 2, 3])
  assert_eq(@coll.page([1, 2, 3], 2, 3), [])
  let ten = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  assert_eq(@coll.page(ten, 1, 3), ten.chunks(3)[0].to_owned())
  assert_eq(@coll.page(ten, 2, 3), ten.chunks(3)[1].to_owned())
  assert_eq(@coll.page(ten, 3, 3), ten.chunks(3)[2].to_owned())
}

///|
test "@coll #6.6 页号与分页大小的非法档各自报错，并带上给进来的读数" {
  assert_eq(
    err_shape(() => @coll.page([1, 2, 3], 0, 1)),
    "NonPositivePageNumber 0",
  )
  assert_eq(
    err_shape(() => @coll.page([1, 2, 3], -1, 1)),
    "NonPositivePageNumber -1",
  )
  assert_eq(
    err_shape(() => @coll.page([1, 2, 3], 1, 0)),
    "NonPositivePageSize 0",
  )
  assert_eq(
    err_shape(() => @coll.page([1, 2, 3], 1, -3)),
    "NonPositivePageSize -3",
  )
  assert_eq(err_shape(() => @coll.page_count(10, 0)), "NonPositivePageSize 0")
  assert_eq(err_shape(() => @coll.page_count(10, -2)), "NonPositivePageSize -2")
  assert_eq(err_shape(() => @coll.page_count(-1, 3)), "NegativeTotal -1")
  // 两档都非法时**先判分页大小**：它是除数，除零类错误优先，读数也就唯一
  assert_eq(err_shape(() => @coll.page_count(-1, 0)), "NonPositivePageSize 0")
  assert_eq(
    err_shape(() => @coll.page([1, 2, 3], 0, 0)),
    "NonPositivePageSize 0",
  )
}

///|
test "@coll #6.7 page_count：上取整，0 条算 0 页（不算 1 页空页）" {
  assert_eq(@coll.page_count(10, 3), 4)
  assert_eq(@coll.page_count(9, 3), 3)
  assert_eq(@coll.page_count(1, 3), 1)
  assert_eq(@coll.page_count(0, 3), 0)
  assert_eq(@coll.page_count(11, 5), 3)
  assert_eq(@coll.page_count(100, 1), 100)
  assert_eq(@coll.page_count(7, 7), 1)
  assert_eq(@coll.page_count(7, 8), 1)
}

///|
test "@coll #6.8 union / intersection / subtract：去重的两个、保留左侧重复的那一个" {
  let a = [1, 2, 2, 3]
  let b = [2, 3, 4]
  assert_eq(@coll.union(a, b), [1, 2, 3, 4])
  assert_eq(@coll.union(b, a), [2, 3, 4, 1])
  assert_eq(@coll.intersection(a, b), [2, 3])
  assert_eq(@coll.intersection(b, a), [2, 3])
  assert_eq(@coll.subtract(a, b), [1])
  assert_eq(@coll.subtract(b, a), [4])
  let e1 : Array[Int] = []
  let e2 : Array[Int] = []
  assert_eq(@coll.union(e1, e2), [])
  assert_eq(@coll.union(e1, [1, 1, 2]), [1, 2])
  assert_eq(@coll.subtract(e1, [1]), [])
  assert_eq(@coll.intersection([1, 2], e2), [])
  assert_eq(@coll.subtract([1, 1, 2], [9]), [1, 1, 2])
}

///|
test "@coll #6.9 maximum / minimum：空给 None，并列取第一个" {
  assert_eq(@coll.maximum([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]), Some(9))
  assert_eq(@coll.minimum([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]), Some(1))
  assert_eq(@coll.maximum([2, 5, 5, 1]), Some(5))
  assert_eq(@coll.minimum([5, 1, 1, 2]), Some(1))
  assert_eq(@coll.maximum([7]), Some(7))
  let es : Array[Int] = []
  assert_eq(@coll.maximum(es), None)
  assert_eq(@coll.minimum(es), None)
  let xs = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
  assert_eq(@coll.maximum(xs), xs.iter().maximum())
  assert_eq(@coll.minimum(xs), xs.iter().minimum())
}

///|
test "@coll #6.10 maximum_by_key / minimum_by_key：按选出来的键比，返回的是元素本身" {
  let recs = [("x", 5), ("y", 9), ("z", 9), ("w", 1)]
  assert_eq(@coll.maximum_by_key(recs, r => r.1), Some(("y", 9)))
  assert_eq(@coll.minimum_by_key(recs, r => r.1), Some(("w", 1)))
  assert_eq(
    @coll.maximum_by_key(["a", "bbb", "cc"], s => s.char_length()),
    Some("bbb"),
  )
  assert_eq(
    @coll.minimum_by_key(["a", "bbb", "cc"], s => s.char_length()),
    Some("a"),
  )
  let er : Array[(String, Int)] = []
  assert_eq(@coll.maximum_by_key(er, _ => 0), None)
  assert_eq(@coll.minimum_by_key(er, _ => 0), None)
}

///|
test "@coll #6.11 边界三档：单元素、全相同、空输入都不改其它档的形状" {
  let one = @coll.group_by([1], x => x)
  assert_eq(one.keys().to_array(), [1])
  assert_eq(one.get(1), Some([1]))
  assert_eq(@coll.distinct([2, 2, 2, 2]), [2])
  assert_eq(@coll.freq([2, 2, 2, 2]).keys().to_array(), [2])
  assert_eq(@coll.freq([2, 2, 2, 2]).get(2), Some(4))
  let (s0, s1) = @coll.partition([2, 2, 2], x => x == 2)
  assert_eq(s0, [2, 2, 2])
  assert_eq(s1, [])
  assert_eq(@coll.union([2, 2], [2, 2]), [2])
  assert_eq(@coll.subtract([2, 2], [2]), [])
  assert_eq(@coll.page([2, 2], 1, 1), [2])
  assert_eq(@coll.page_count(4, 2), 2)
  assert_eq(@coll.maximum([2, 2, 2]), Some(2))
}
