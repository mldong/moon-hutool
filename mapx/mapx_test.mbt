// moon-hutool/mapx 契约用例（黑盒，第一批：BiMap + CiMap + Map 的两个组合件）。
//
// 状态：**已实现**（10-05，第一批 16 条全绿；wasm / js / wasm-gc 三档读数一致，native 档由 CI 出证）。
// 期望值先冻结、后实现；实现期改任何期望串 = 门禁 G5 拦下，须单独一笔并给外部读数来源
// （本轮确实单独走了一笔：`中文-a` 那条是我契约期手算誊反的，见 `d61524e`，改期望不改实现）。
//
// 读数权威（逐条来源见 docs/spec/07-mapx.md 的「读数来源」列）：
// - 所有期望值由一个 **Python 镜像**现算（同一批夹具、同一套定义，两套独立实现互相对跑）。
// - 四条口径先**现读 hutool 源码**定位，再按"参照系是公认标准"的规则定死：
//   **BiMap.put 撞值报错**——hutool `map/BiMap.java` 的 `put` 只往反向表补一条，
//   `put(a,1); put(b,1)` 之后正向表里 a、b 两条都在而 `getKey(1)` 只认 b，双向索引此时已经不一致；
//   本库按 Guava `BiMap` 的判据拒绝进入这种状态，并给 `force_put` 作显式逃生阀（同 Guava）。
//   **CiMap 原样键取首次写入**——Java `Map.put` 覆盖值不换键，hutool `FuncKeyMap`/`CaseInsensitiveMap` 同约。
//   **rename_key 新键排末尾**——hutool `MapUtil.renameKey` 就是 `put(newKey, remove(oldKey))`，
//   在 `LinkedHashMap` 上落末尾；原键不存在时原样返回（同 hutool，静默 no-op 而不是猜意图）。
//   **`old == new` 不许把自己删掉**（这一档 hutool 会先 put 再 remove 掉同一个键 ⇒ 条目消失，
//   是它的一个坑；本库保留条目，契约里单独立一条断言）。
// - 与 core 的分工（对拍腿，门禁 G8）：`filter_map` 在"全收"闭包下与 core `Map::map` 同结果；
//   `CiMap::to_map()` 的键序 = core `Map` 的插入序。**不重新包装** core 已有的
//   `Map::{of, new, get, set, contains, contains_kv, remove, merge, merge_in_place, retain, update,
//   update_or_default, get_or_default, get_or_init, keys, values, to_array, length, is_empty, iter, each}`；
//   `Map` 本身就是插入序（`builtin/linked_hash_map.mbt`），**不再造 LinkedHashMap**。
//
// 三条最容易写错的档各占一条独立用例：**值撞车的两档分岔**（#7.2 报错 / #7.3 强放）、
// **折叠槽不换原样键**（#7.6）、**rename_key 落末尾而不是原位**（#7.9）。

///|
/// 夹具：三条互不冲突的键值对，多处复用
fn new_bimap() -> @mapx.BiMap[String, Int] {
  unwrap(() => @mapx.BiMap::of([("a", 1), ("b", 2), ("c", 3)]))
}

///|
fn new_bimap1() -> @mapx.BiMap[String, Int] {
  unwrap(() => @mapx.BiMap::of([("a", 1)]))
}

///|
/// 期望"不报错"的用例走这层：报了就把错误形状写进 abort 文案，定位不用二次猜
fn[A] unwrap(r : () -> A raise @mapx.MapError) -> A {
  r() catch {
    err => abort("夹具不该报错：\{show_err(err)}")
  }
}

///|
/// 只关心错误形状的用例走这条
fn[A] err_of(r : () -> A raise @mapx.MapError) -> String {
  try {
    let _ = r()
    "未抛错"
  } catch {
    err => show_err(err)
  }
}

///|
/// 错误面是泛型的：变体携带的读数就是类型参数本身，这里具体化到 String 键
fn show_err(err : @mapx.MapError) -> String {
  match err {
    @mapx.ValueConflict => "ValueConflict"
    @mapx.KeyAlreadyExists => "KeyAlreadyExists"
  }
}

///|
test "@mapx #7.1 BiMap 的两个方向都读得到，键序是正向的插入序" {
  let m = new_bimap()
  assert_eq(m.to_pairs(), [("a", 1), ("b", 2), ("c", 3)])
  assert_eq(m.keys(), ["a", "b", "c"])
  assert_eq(m.values(), [1, 2, 3])
  assert_eq(m.get("b"), Some(2))
  assert_eq(m.get_key(2), Some("b"))
  assert_eq(m.length(), 3)
  assert_eq(m.contains_key("c"), true)
  assert_eq(m.contains_value(3), true)
  assert_eq(m.contains_key("z"), false)
  assert_eq(m.contains_value(99), false)
  let i = m.inverse()
  assert_eq(i.to_pairs(), [(1, "a"), (2, "b"), (3, "c")])
  assert_eq(i.get(2), Some("b"))
  assert_eq(i.get_key("c"), Some(3))
  assert_eq(i.length(), 3)
  assert_eq(m.inverse().inverse().to_pairs(), [("a", 1), ("b", 2), ("c", 3)])
}

///|
test "@mapx #7.2 put：同键后者胜并返回旧值；值被别的键占着就报错并带回**那个键**" {
  let m = new_bimap()
  let ret = unwrap(() => m.put("a", 9))
  assert_eq(ret, Some(1))
  assert_eq(m.to_pairs(), [("a", 9), ("b", 2), ("c", 3)])
  assert_eq(m.get_key(9), Some("a"))
  assert_eq(m.get_key(1), None)
  assert_eq(m.length(), 3)
  assert_eq(err_of(() => m.put("b", 9)), "ValueConflict")
  assert_eq(m.get_key(9), Some("a"))
  assert_eq(m.to_pairs(), [("a", 9), ("b", 2), ("c", 3)])
}

///|
test "@mapx #7.3 force_put 不报错，而是把占着该值的旧键整条摘掉" {
  let m = new_bimap()
  let evicted = unwrap(() => m.force_put("a", 2))
  assert_eq(evicted, Some("b"))
  assert_eq(m.to_pairs(), [("a", 2), ("c", 3)])
  assert_eq(m.length(), 2)
  assert_eq(m.get("b"), None)
  assert_eq(m.get("a"), Some(2))
  assert_eq(m.get_key(2), Some("a"))
  let m2 : @mapx.BiMap[String, Int] = @mapx.BiMap::new()
  let e2 = unwrap(() => m2.force_put("x", 1))
  assert_eq(e2, None)
  assert_eq(m2.to_pairs(), [("x", 1)])
}

///|
test "@mapx #7.4 remove 之后两个方向都读不到；摘不存在的键给 None" {
  let m = new_bimap()
  assert_eq(m.remove("b"), Some(2))
  assert_eq(m.to_pairs(), [("a", 1), ("c", 3)])
  assert_eq(m.length(), 2)
  assert_eq(m.get("b"), None)
  assert_eq(m.get_key(2), None)
  assert_eq(m.remove("b"), None)
  assert_eq(m.remove("zzz"), None)
  assert_eq(m.inverse().to_pairs(), [(1, "a"), (3, "c")])
}

///|
test "@mapx #7.5 BiMap::of 逐条走 put 的判据：值撞了就整条构造失败，不静默覆盖" {
  assert_eq(
    err_of(() => @mapx.BiMap::of([("a", 1), ("b", 1)])),
    "ValueConflict",
  )
  assert_eq(
    err_of(() => @mapx.BiMap::of([("a", 1), ("b", 2), ("c", 1)])),
    "ValueConflict",
  )
  let m = unwrap(() => @mapx.BiMap::of([("a", 1), ("a", 2)]))
  assert_eq(m.to_pairs(), [("a", 2)])
  assert_eq(m.get_key(1), None)
  let e : @mapx.BiMap[String, Int] = unwrap(() => @mapx.BiMap::of([]))
  assert_eq(e.to_pairs(), [])
  assert_eq(e.length(), 0)
}

///|
test "@mapx #7.6 CiMap：折叠查得到，原样键保留**首次写入**的那一个" {
  let m : @mapx.CiMap[String] = @mapx.CiMap::new()
  assert_eq(m.put("Content-Type", "text/plain"), None)
  assert_eq(m.put("content-type", "application/json"), Some("text/plain"))
  assert_eq(m.put("X-Trace-Id", "abc"), None)
  assert_eq(m.keys(), ["Content-Type", "X-Trace-Id"])
  assert_eq(m.length(), 2)
  assert_eq(m.get("CONTENT-TYPE"), Some("application/json"))
  assert_eq(m.get_key_of("content-type"), Some("Content-Type"))
  assert_eq(m.get_key_of("nope"), None)
}

///|
test "@mapx #7.7 contains / remove / to_map 都按折叠槽走；折叠只管 ASCII" {
  let m : @mapx.CiMap[Int] = @mapx.CiMap::new()
  let _ = m.put("AbC", 1)
  let _ = m.put("def", 2)
  assert_eq(m.contains("abc"), true)
  assert_eq(m.contains("ABC"), true)
  assert_eq(m.contains("xyz"), false)
  assert_eq(m.remove("ABC"), Some(1))
  assert_eq(m.contains("abc"), false)
  assert_eq(m.length(), 1)
  assert_eq(m.to_map().keys().to_array(), ["def"])
  assert_eq(m.remove("ABC"), None)
  assert_eq(m.length(), 1)
  let _ = m.put("中文-A", 3)
  // 折叠只看字符是不是 ASCII 字母，不看它周围：混排串里的 `A` 照样折叠，
  // 所以 `中文-a` 命中的是同一个槽位（这条在契约期被我写反了，见更正 commit）
  assert_eq(m.contains("中文-A"), true)
  assert_eq(m.contains("中文-a"), true)
  // 真正"不折叠"的是非 ASCII 字母本身：`Ä` 与 `ä` 是两个槽位
  let non_ascii : @mapx.CiMap[Int] = @mapx.CiMap::new()
  let _ = non_ascii.put("Ä", 1)
  assert_eq(non_ascii.contains("Ä"), true)
  assert_eq(non_ascii.contains("ä"), false)
  assert_eq(non_ascii.length(), 1)
  let e : @mapx.CiMap[Int] = @mapx.CiMap::new()
  assert_eq(e.length(), 0)
  assert_eq(e.get("anything"), None)
}

///|
test "@mapx #7.8 filter_map：core 的 Map 有 map/retain，没有这一件" {
  let src = Map([("a", 1), ("b", 2), ("c", 3)])
  let kept = @mapx.filter_map(src, (k, v) => {
    if v % 2 == 1 {
      Some("\{k}=\{v}")
    } else {
      None
    }
  })
  assert_eq(kept.keys().to_array(), ["a", "c"])
  assert_eq(kept.get("a"), Some("a=1"))
  assert_eq(kept.get("b"), None)
  assert_eq(kept.get("c"), Some("c=3"))
  assert_eq(kept.length(), 2)
  let none : Map[String, String] = @mapx.filter_map(src, (_, _) => None)
  assert_eq(none.keys().to_array(), [])
  assert_eq(none.length(), 0)
  let all = @mapx.filter_map(src, (k, v) => Some("\{k}:\{v}"))
  let via_core = src.map((k, v) => "\{k}:\{v}")
  assert_eq(all.keys().to_array(), via_core.keys().to_array())
  assert_eq(all.get("b"), Some("b:2"))
}

///|
test "@mapx #7.9 rename_key 的新键排在末尾，且不改输入的 Map" {
  let src = Map([("x", 1), ("y", 2), ("z", 3)])
  let out = unwrap(() => @mapx.rename_key(src, "y", "w"))
  assert_eq(out.keys().to_array(), ["x", "z", "w"])
  assert_eq(out.get("w"), Some(2))
  assert_eq(out.get("y"), None)
  assert_eq(src.keys().to_array(), ["x", "y", "z"])
  assert_eq(src.get("y"), Some(2))
}

///|
test "@mapx #7.10 rename_key：目标键已存在报错；原键不存在就原样返回（跟 hutool 同档）" {
  assert_eq(
    err_of(() => @mapx.rename_key(Map([("x", 1), ("y", 2)]), "x", "y")),
    "KeyAlreadyExists",
  )
  let out = unwrap(() => @mapx.rename_key(Map([("x", 1)]), "q", "r"))
  assert_eq(out.keys().to_array(), ["x"])
  assert_eq(out.get("r"), None)
  assert_eq(out.get("x"), Some(1))
  let self_name = unwrap(() => @mapx.rename_key(Map([("k", 9)]), "k", "k"))
  assert_eq(self_name.keys().to_array(), ["k"])
  assert_eq(self_name.get("k"), Some(9))
}

///|
test "@mapx #7.11 空表与极端输入上判据不变形" {
  let b : @mapx.BiMap[String, Int] = @mapx.BiMap::new()
  assert_eq(b.length(), 0)
  assert_eq(b.to_pairs(), [])
  assert_eq(b.get("nope"), None)
  assert_eq(b.get_key(0), None)
  assert_eq(b.keys(), [])
  assert_eq(b.values(), [])
  assert_eq(b.inverse().to_pairs(), [])
  let m = new_bimap1()
  let v = unwrap(() => m.put("a", 1))
  assert_eq(v, Some(1))
  assert_eq(m.to_pairs(), [("a", 1)])
}
