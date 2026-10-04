# mapx

hutool `MapUtil` 家族与 `BiMap` / `CaseInsensitiveMap` 的 MoonBit 对位：双向唯一映射、ASCII 大小写不敏感的键空间，外加 `Map` 缺的两个组合件（一次遍历又筛又换值、改键名）。

完整边界矩阵与逐条读数来源见 [`docs/spec/07-mapx.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/07-mapx.md)。

> 状态：**两批都已落地**（10-05）——第一批 28 个公开项（`BiMap`/`CiMap`/两个组合件）与第二批 `Table` 都实现完，
> 下面每个块的读数都是当场跑出来的，三档（wasm / js / wasm-gc）一致。
> 期望串受"期望值冻结"约束：改任何期望须单独一笔并给外部读数来源（门禁 G5）。
> `Table`（二维表）自成一块，另起第二批。

## 先说这一包不做什么

core 的 `Map` **本身就是插入序**（`builtin/linked_hash_map.mbt`，Robin Hood + 链表），
`of`/`new`/`get`/`set`/`contains`/`remove`/`merge`/`retain`/`update`/`get_or_init`/`update_or_default`/
`keys`/`values`/`to_array`/`iter`/`each` 全都有 ⇒ 本包**一个都不重新包装**，也**不再造 LinkedHashMap**。
hutool 那侧之所以有 `CaseInsensitiveLinkedMap`、`FixedLinkedHashMap` 一堆兄弟类，是因为 Java 的 `HashMap`
不保序；那个前提在这里不存在，跟着抄就是一份同语义的第二套口径。

补的只有三件：值也能反查键（`BiMap`）、键大小写不敏感（`CiMap`）、`Map` 上"又筛又换值"与"改键名"
这两个一次做完比拼 core 更清楚的组合件。

## `BiMap`：两个方向永远互逆

```mbt check
///|
test "双向都读得到，逆表是新的一张" {
  let m : @mapx.BiMap[String, Int] = @mapx.BiMap::of([
    ("a", 1),
    ("b", 2),
    ("c", 3),
  ]) catch {
    _ => abort("夹具本身必须能构造")
  }
  assert_eq(m.to_pairs(), [("a", 1), ("b", 2), ("c", 3)])
  assert_eq(m.keys(), ["a", "b", "c"])
  assert_eq(m.values(), [1, 2, 3])
  assert_eq(m.get("b"), Some(2))
  assert_eq(m.get_key(2), Some("b"))
  assert_eq(m.inverse().to_pairs(), [(1, "a"), (2, "b"), (3, "c")])
  assert_eq(m.inverse().inverse().to_pairs(), [("a", 1), ("b", 2), ("c", 3)])
  // `values()` 互不重复是双向不变式的推论，不是巧合
  assert_eq(m.values().length(), m.length())
}
```

`put` 撞值时**整次调用不生效**——这是与 hutool 的实质分歧：那侧 `BiMap.put` 只往反向表补一条，
`put(a,1); put(b,1)` 之后正向表里 a、b 两条都在而 `getKey(1)` 只认 b，双向索引已经不一致。
本库按 Guava `BiMap` 的判据拒绝进入这种状态；要挤掉别人，用显式命名的 `force_put`。

```mbt check
///|
test "撞值两档：报错不动表，强放删的是你没提过的键" {
  let m = @mapx.BiMap::of([("a", 1), ("b", 2), ("c", 3)]) catch {
    _ => abort("夹具本身必须能构造")
  }
  assert_eq(
    m.put("a", 9) catch {
      _ => abort("同键覆盖不该报错")
    },
    Some(1),
  )
  assert_eq(m.get("a"), Some(9))
  assert_eq(m.get_key(1), None)
  // `err_of` 来自 `mapx_test.mbt`（同一个黑盒测试包）：报错形状要先折成 String 才可比
  assert_eq(err_of(() => m.put("b", 9)), "ValueConflict")
  // 报错后表一条没动；"谁占着"由表自己回答，所以错误面不带这个载荷
  assert_eq(m.to_pairs(), [("a", 9), ("b", 2), ("c", 3)])
  assert_eq(m.get_key(9), Some("a"))
  assert_eq(m.force_put("c", 2), Some("b"))
  assert_eq(m.to_pairs(), [("a", 9), ("c", 2)])
  assert_eq(m.get("b"), None)
}
```

## `CiMap`：折叠用来查，原样键留着写回

HTTP 头这类场景要"大小写随意地查，按原样写回"，所以槽位存的是 `(首次写入的原样键, 值)`——
**覆盖值不换键**（与 Java `Map.put` 的既有约定同一档）。折叠**只覆盖 ASCII**：core 没有 Unicode
大小写表，`Char` 连 `to_lowercase` 都没有，拖一张表进来等于把工具库的发布节奏绑到码表上。

```mbt check
///|
test "三种写法一个槽位，原样键是第一次写进去的那个" {
  let m : @mapx.CiMap[String] = @mapx.CiMap::new()
  assert_eq(m.put("Content-Type", "text/plain"), None)
  assert_eq(m.put("content-type", "application/json"), Some("text/plain"))
  assert_eq(m.put("X-Trace-Id", "abc"), None)
  assert_eq(m.keys(), ["Content-Type", "X-Trace-Id"])
  assert_eq(m.length(), 2)
  assert_eq(m.get("CONTENT-TYPE"), Some("application/json"))
  assert_eq(m.get_key_of("content-type"), Some("Content-Type"))
  assert_eq(m.contains("x-trace-id"), true)
  // 折叠判的是"这个字符是不是 ASCII 字母"，不看它旁边是什么：混排串里的 `A` 照样折叠
  let cjk : @mapx.CiMap[Int] = @mapx.CiMap::new()
  let _ = cjk.put("中文-A", 1)
  assert_eq(cjk.contains("中文-A"), true)
  assert_eq(cjk.contains("中文-a"), true)
  // 真正不折叠的是非 ASCII 字母本身：`Ä` 与 `ä` 是两个槽位
  let umlaut : @mapx.CiMap[Int] = @mapx.CiMap::new()
  let _ = umlaut.put("Ä", 1)
  assert_eq(umlaut.contains("Ä"), true)
  assert_eq(umlaut.contains("ä"), false)
}
```

`to_map()` 是**出口**不是中转：拿到的普通 `Map` 之后按大小写敏感规则工作，想继续不敏感就留在 `CiMap` 里。

## `Map` 的两个组合件

`filter_map` 的增量只有"一次遍历"：core 的 `map` 只换值、`retain` 只筛不换，合用要先建中间表。
键序沿用输入的插入序，输入不被修改。

```mbt check
///|
test "又筛又换值，与 core 的 map 在全收闭包下同结果" {
  let src = Map([("a", 1), ("b", 2), ("c", 3)])
  let kept = @mapx.filter_map(src, (k, v) => {
    if v % 2 == 1 {
      Some("\{k}=\{v}")
    } else {
      None
    }
  })
  assert_eq(kept.keys().to_array(), ["a", "c"])
  assert_eq(kept.get("b"), None)
  assert_eq(kept.get("c"), Some("c=3"))
  // 对拍腿（门禁 G8）：恒 Some 时与 core `Map::map` 同结果
  let all = @mapx.filter_map(src, (k, v) => Some("\{k}:\{v}"))
  assert_eq(
    all.keys().to_array(),
    src.map((k, v) => "\{k}:\{v}").keys().to_array(),
  )
}
```

`rename_key` 的落位口径写死成**新键排末尾**（hutool 就是 `put(new) + remove(old)`，在 `LinkedHashMap`
上落末尾），两处不跟随：不改输入表，以及 `old == new` 时**保留该条**——hutool 那侧先写再删同一个键，
条目会被自己删掉，那是坑。

```mbt check
///|
test "改键名：末尾落位、输入不动、目标撞了就报错" {
  let src = Map([("x", 1), ("y", 2), ("z", 3)])
  let out = @mapx.rename_key(src, "y", "w") catch {
    _ => abort("目标键不冲突，不该报错")
  }
  assert_eq(out.keys().to_array(), ["x", "z", "w"])
  assert_eq(out.get("w"), Some(2))
  assert_eq(out.get("y"), None)
  assert_eq(src.keys().to_array(), ["x", "y", "z"])
  assert_eq(src.get("y"), Some(2))
  assert_eq(err_of(() => @mapx.rename_key(src, "x", "y")), "KeyAlreadyExists")
  // old == new 是最容易写炸的一档：不能把自己删掉
  let same = @mapx.rename_key(Map([("k", 9)]), "k", "k") catch {
    _ => abort("同名不该报错")
  }
  assert_eq(same.keys().to_array(), ["k"])
  assert_eq(same.get("k"), Some(9))
}
```

## 这一层不做的事

Unicode 大小写折叠（要码表，折叠只覆盖 ASCII）、`remove_null_value` 那类"清 null"档（本库无 null，
缺席用 `Option` 表达）、`MapProxy`/`MapBuilder`/`CamelCaseMap`（反射代理做不到；builder 就是 `Map([...])`；
驼峰转换在 `text` 的 `NamingCase`）、`ForestMap` 树形键空间与 `MultiValueMap`（各自一整块语义，未排期）、
`ReferenceConcurrentMap`/`SafeConcurrentHashMap`（并发档与"全同步"的零依赖契约结构冲突）、
按键排序成 `TreeMap`（core 有 `SortedMap`）、按值排序（`to_array()` + `coll` 的组合件即可）。
`Table`（二维表）是本包**第二批**的内容。逐条理由见 [`docs/ROADMAP.md`](https://github.com/mldong/moon-hutool/blob/master/docs/ROADMAP.md)
的「暂不做」「不做」两节与 spec §9。

## `Table`：二维表（第二批）

`Table[R, C, V]` 对位 hutool `cn.hutool.core.map.multi.Table` 与 Guava `Table`：**格坐标**的表，
不是矩阵——`size()` 数的是**格数**，稀疏就小。两条索引（行主索引 + "哪些行在这一列有值"）都藏在结构体里，
所以行向与列向读取都是 O(该行列数 / 该列行数)，而**值不建第三张索引**：`contains_value` 就是遍历，
为一个低频查询维护三份一致性不划算（这条取舍写进 spec §10，不是遗漏）。

```mbt check
///|
test "格坐标读写：稀疏表不必是矩形" {
  let m = @mapx.Table::of([("r1", "c1", 1), ("r1", "c2", 2), ("r2", "c1", 3)])
  assert_eq(m.size(), 3)
  assert_eq(m.get("r1", "c1"), Some(1))
  assert_eq(m.get("r1", "c3"), None)
  assert_eq(m.contains("r2", "c1"), true)
  assert_eq(m.rows(), ["r1", "r2"])
  assert_eq(m.columns(), ["c1", "c2"])
  assert_eq(m.to_cells(), [("r1", "c1", 1), ("r1", "c2", 2), ("r2", "c1", 3)])
}
```

顺序口径是 Java 那侧**没法**承诺的（那边是 `HashMap`，`columnKeys()` 的返回序无从定义）；
本库的 `Map` 保插入序，于是"行序 = 首次写入该行、列序 = 首次写入该列"成了契约。
覆盖一个已有格**什么都不挪**——行序、列序、`size()` 全不变。

```mbt check
///|
test "覆盖不挪位；删到空就连键一起摘" {
  let m = @mapx.Table::of([("r1", "c1", 1), ("r1", "c2", 2), ("r2", "c1", 3)])
  assert_eq(m.put("r1", "c2", 9), Some(2))
  assert_eq(m.rows(), ["r1", "r2"])
  assert_eq(m.columns(), ["c1", "c2"])
  assert_eq(m.size(), 3)
  // r2 只有 c1 一个格：删掉它，r2 这行就从 rows() 消失
  assert_eq(m.remove("r2", "c1"), Some(3))
  assert_eq(m.rows(), ["r1"])
  assert_eq(m.columns(), ["c1", "c2"])
  // c2 最后一个格被删掉 ⇒ 该列也消失；空行/空列都不留幽灵
  assert_eq(m.remove("r1", "c2"), Some(9))
  assert_eq(m.columns(), ["c1"])
  assert_eq(m.remove("r1", "c2"), None)
}
```

`row()` / `column()` 给的是**副本**（内部索引绝不外借），`clear()` 一次清空，`Table::of` 逐条走 `put`
所以同格重复给值是后者胜。

```mbt check
///|
test "行列取副本、of 同格后者胜、clear 清空" {
  let m = @mapx.Table::of([("r1", "c1", 1), ("r1", "c1", 2), ("a", "z", 5)])
  assert_eq(m.size(), 2)
  assert_eq(m.get("r1", "c1"), Some(2))
  assert_eq(m.row("r1").keys().to_array(), ["c1"])
  assert_eq(m.column("c1").keys().to_array(), ["r1"])
  let snapshot = m.row("r1")
  let _ = snapshot.remove("c1")
  assert_eq(m.get("r1", "c1"), Some(2))
  m.clear()
  assert_eq(m.rows(), [])
  assert_eq(m.columns(), [])
  assert_eq(m.to_cells(), [])
}
```
