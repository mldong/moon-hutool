// moon-hutool/mapx 的 Table 部分：契约用例（黑盒，与 `mapx_test.mbt` 同包）。
//
// 状态：**已随第二批落地**（10-05）——`Table` 的方法实现完，本文件 11 条与第一批的 16 条同轮转绿，
// 期望串一字未改。实现期改任何期望串 = 门禁 G5 拦下，须单独一笔并给外部读数来源。
//
// 读数权威（逐条来源见 docs/spec/07-mapx.md §10 的「读数来源」列）：
// - 所有期望值由 **Python 镜像**现算（`rows` 一张 dict-of-dict + `cols` 一张 dict-of-list，
//   与 MoonBit 侧是两套独立实现）。四条口径都进断言：行序按首次写入该行、列序按首次写入该列、
//   覆盖已有格**不挪位**、删到空就把行/列键一起摘掉。
// - hutool 对位 `cn.hutool.core.map.multi.Table`（`Table` 接口 + `AbsTable`/`HashBasedTable`），
//   语义参照 Guava `Table`。**本库的三点差异**：`get` 给 `V?` 不给 null；行列键序是**首写序**
//   （Java 那侧 `HashMap` 无序，`columnKeys()` 的返回顺序无从承诺）；`row()`/`column()` 给副本。
// - 值的索引**不做**：`contains_value` 是 O(格数) 的遍历——建第三张索引要为"改一个值"维护一致性，
//   代价大于收益，这条取舍写在 spec §10 的表里，不是遗漏。
//
// 三条最容易写错的档各占一条独立用例：**覆盖不挪位**（#7.13）、
// **删到空就连键一起摘**（#7.16）、**行优先展开的序**（#7.19）。

///|
/// 基础夹具：`r1` 两格、`r2` 一格——非矩形，列数不一致
fn new_table() -> @mapx.Table[String, String, Int] {
  @mapx.Table::of([("r1", "c1", 1), ("r1", "c2", 2), ("r2", "c1", 3)])
}

///|
fn new_single() -> @mapx.Table[String, String, Int] {
  @mapx.Table::of([("a", "x", 1)])
}

///|
test "@mapx #7.12 Table 的格坐标：不是行×列的矩形，size 数的是格" {
  let m = new_table()
  assert_eq(m.size(), 3)
  assert_eq(m.get("r1", "c1"), Some(1))
  assert_eq(m.get("r1", "c3"), None)
  assert_eq(m.get("r3", "c1"), None)
  assert_eq(m.contains("r2", "c1"), true)
  assert_eq(m.contains("r2", "c2"), false)
  assert_eq(m.rows(), ["r1", "r2"])
  assert_eq(m.columns(), ["c1", "c2"])
  assert_eq(m.to_cells(), [("r1", "c1", 1), ("r1", "c2", 2), ("r2", "c1", 3)])
  let e : @mapx.Table[String, String, Int] = @mapx.Table::new()
  assert_eq(e.size(), 0)
  assert_eq(e.rows(), [])
  assert_eq(e.columns(), [])
  assert_eq(e.to_cells(), [])
}

///|
test "@mapx #7.13 put 覆盖已有格：返回旧值，行列键序都不挪位" {
  let m = new_table()
  assert_eq(m.put("r1", "c2", 9), Some(2))
  assert_eq(m.rows(), ["r1", "r2"])
  assert_eq(m.columns(), ["c1", "c2"])
  assert_eq(m.size(), 3)
  assert_eq(m.get("r1", "c2"), Some(9))
  let n : @mapx.Table[String, String, Int] = @mapx.Table::new()
  assert_eq(n.put("r1", "c1", 7), None)
}

///|
test "@mapx #7.14 行序按首次写入该行、列序按首次写入该列，两者互不影响" {
  let m : @mapx.Table[String, String, Int] = @mapx.Table::new()
  let _ = m.put("r1", "later_col", 1)
  let _ = m.put("r2", "earlier_name", 2)
  assert_eq(m.rows(), ["r1", "r2"])
  assert_eq(m.columns(), ["later_col", "earlier_name"])
  let _ = m.put("r1", "later_col", 5)
  assert_eq(m.columns(), ["later_col", "earlier_name"])
}

///|
test "@mapx #7.15 row / column 是副本：改了不动表，也不外借内部索引" {
  let m = new_table()
  assert_eq(m.row("r1").keys().to_array(), ["c1", "c2"])
  assert_eq(m.row("r1").get("c2"), Some(2))
  assert_eq(m.column("c1").keys().to_array(), ["r1", "r2"])
  assert_eq(m.column("c1").get("r2"), Some(3))
  assert_eq(m.row("r9").keys().to_array(), [])
  assert_eq(m.column("c9").keys().to_array(), [])
  let mine = m.row("r1")
  let _ = mine.remove("c1")
  assert_eq(m.row("r1").keys().to_array(), ["c1", "c2"])
  assert_eq(m.get("r1", "c1"), Some(1))
  assert_eq(m.size(), 3)
}

///|
test "@mapx #7.16 remove：某行/某列被清空时，那个键一起消失，不留幽灵行列" {
  let m = new_table()
  assert_eq(m.remove("r2", "c1"), Some(3))
  assert_eq(m.rows(), ["r1"])
  assert_eq(m.columns(), ["c1", "c2"])
  assert_eq(m.size(), 2)
  assert_eq(m.get("r2", "c1"), None)
  let n = new_single()
  let _ = n.remove("a", "x")
  assert_eq(n.rows(), [])
  assert_eq(n.columns(), [])
  assert_eq(n.size(), 0)
  assert_eq(m.remove("r2", "c1"), None)
  assert_eq(m.rows(), ["r1"])
  let _ = m.remove("r1", "c2")
  assert_eq(m.get("r1", "c1"), Some(1))
  assert_eq(m.row("r1").keys().to_array(), ["c1"])
}

///|
test "@mapx #7.17 三种在：行列走索引，值只能遍历（不给值建索引是明码的取舍）" {
  let m = new_table()
  assert_eq(m.contains_row("r1"), true)
  assert_eq(m.contains_row("r9"), false)
  assert_eq(m.contains_column("c2"), true)
  assert_eq(m.contains_column("c3"), false)
  assert_eq(m.contains_value(3), true)
  assert_eq(m.contains_value(99), false)
  let _ = m.put("r1", "c1", 3)
  assert_eq(m.contains_value(3), true)
  assert_eq(m.size(), 3)
}

///|
test "@mapx #7.18 Table::of 逐条 put（同格后者胜）；clear 一次清空" {
  let dup = @mapx.Table::of([("r1", "c1", 1), ("r1", "c1", 2)])
  assert_eq(dup.size(), 1)
  assert_eq(dup.get("r1", "c1"), Some(2))
  assert_eq(dup.rows(), ["r1"])
  assert_eq(dup.columns(), ["c1"])
  let m = @mapx.Table::of([("r1", "c1", 1), ("r1", "c2", 2), ("r2", "c1", 3)])
  assert_eq(m.to_cells(), [("r1", "c1", 1), ("r1", "c2", 2), ("r2", "c1", 3)])
  m.clear()
  assert_eq(m.size(), 0)
  assert_eq(m.rows(), [])
  assert_eq(m.columns(), [])
  assert_eq(m.to_cells(), [])
  let e : @mapx.Table[String, String, Int] = @mapx.Table::of([])
  assert_eq(e.size(), 0)
}

///|
test "@mapx #7.19 to_cells 是行优先展开：行按首写序，行内列按该行首写序" {
  let m = @mapx.Table::of([("b", "y", 1), ("a", "x", 2), ("b", "x", 3)])
  assert_eq(m.rows(), ["b", "a"])
  assert_eq(m.columns(), ["y", "x"])
  assert_eq(m.to_cells(), [("b", "y", 1), ("b", "x", 3), ("a", "x", 2)])
  assert_eq(m.size(), 3)
}
