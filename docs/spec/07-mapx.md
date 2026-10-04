# 契约 07 · mapx（Map 的组合件）

> 状态：**契约已冻结、实现未开工**（第一批）。签名骨架在 `mapx/mapx.mbt`（函数体是 `abort`），公开接口在
> `mapx/pkg.generated.mbti`，期望值在 `mapx/mapx_test.mbt` 与 `mapx/README.mbt.md`——本包用例此刻全红是设计态。
> 实现那一笔只许把红变绿；改任何期望串须单独一笔并给外部读数来源（门禁 G5）。
>
> **范围分两批**：第一批 = `BiMap` + `CiMap`（大小写不敏感映射）+ `Map` 的两个组合件；
> `Table`（二维表）自成一块，另起第二批（§9）。理由：`Table` 是"行列两个索引 + 一张网格"的第三种形状，
> 与 `BiMap`/`CiMap` 这两件"键空间变形"混在一份契约里，评审时看不出各自到底承诺了什么。

## 0. 三条贯穿性规则

| # | 规则 | 为什么 |
|---|---|---|
| 0.1 | **core 已有的一个都不重新包装**，`Map` 本身就是插入序 ⇒ **不再造 LinkedHashMap** | hutool 那侧要 `CaseInsensitiveLinkedMap`、`FixedLinkedHashMap` 各一档，是因为 Java 的 `HashMap` 不保序；core 的 `Map` 是 Robin Hood + 链表（`builtin/linked_hash_map.mbt`），键序天然是插入序。再造一份同名件，等于让同一个程序里存在两套"谁先谁后"的口径 |
| 0.2 | **纯函数优先，改状态要指名** | `filter_map`/`rename_key` 返回新 `Map`、不动输入（hutool `MapUtil.renameKey` 是**原地改**传入的 Map，本库不跟随——见 §5）；`BiMap`/`CiMap` 是会变的容器，方法名 `put`/`remove`/`force_put` 就是它的改动契约 |
| 0.3 | **错误只带"调用方拿不到的读数"** | 两个变体都不带载荷：`ValueConflict` 问一句就知道是谁占着（`get_key(value)`），`KeyAlreadyExists` 那个键本来就是调用方传进来的。同 `codec.ChecksumMismatch` 不携带摘要的判断——重复携带就是第二个口径 |

## 1. 与 core 的边界

`Map` 的公开面：当场扫 `builtin/pkg.generated.mbti`，把 `Map::name` 去重得 **33 条**——
`at capacity clear contains contains_kv copy each eachi equal from_iter get get_from_bytes
get_from_string get_or_default get_or_init is_empty iter iter2 keys length map merge merge_in_place
new of remove retain set to_array to_json update update_or_default values`
（`new`/`of`/`set`/`hash` 里有几个是构造/派生形式，扫描口径只认 `Map::` 字面出现的那批，
所以**给的是口径 + 条数**，不是"精确方法数"——同 `coll` 那条规矩）。构造写 `Map([...])`（字面量形式）或 `Map::new()`；
`of` 那一档是**带标签参**的构造函数，按位置传 `Map.of([...])` 会被判
`Function with labelled arguments can only be applied directly`，当方法点出来又判 `has no method of`。

| 能力 | core | 本包 |
|---|---|---|
| 有序 Map、批量构造、`get_or_init`/`update_or_default`/`merge`/`retain`/`update` | **全有** | 不包装。`CiMap::to_map()` 直接交回一个普通 `Map`，不发明第三种 Map 类型 |
| 双向索引（值 → 键） | 无（`Map` 只有一层键；`contains_kv` 也不能反查） | **做** `BiMap` |
| 大小写不敏感的键空间 | 无（`Char`/`String` 都没有 `to_lowercase`，core 只有 ASCII 档可用） | **做** `CiMap`，折叠**只覆盖 ASCII** |
| 一次遍历"又筛又换值" | `Map::map`（只换值）与 `Map::retain`（只筛不换）都有，合用要先建中间表 | **做** `filter_map` |
| 改键名 | 无（得手工 `get` + `remove` + `set` 三步，顺序还会乱） | **做** `rename_key`，并把落位口径写死 |
| Unicode 大小写折叠、`TreeMap` 有序键、`WeakConcurrentMap`、`ForestMap`、`MultiValueMap`、`MapProxy` | 无 | **不做**（码表 / 并发 / 反射代理，见 §9 与 ROADMAP 的「不做」） |

## 2. 错误面

| 签名 | 语义 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `pub suberror MapError { ValueConflict KeyAlreadyExists }` | 本包唯一错误面，两个变体都**不带载荷** | — | hutool 抛 `IllegalArgumentException` 并把键名拼进文案 | 不带载荷的理由见 0.3；文案不进错误面（同四个已交付包） | 定义即契约 |

> ⚠ **编译器裁决**：`pub suberror E[K] { ... }`（泛型错误面）在 moonc v0.10.14 **不支持**——最小样本
> `pub suberror E[K] { Conflict(K) }` 直接判 `Parse error, unexpected token '['`，落在声明的收尾处。
> 所以"携带键"这条路被编译器关掉，不是本库偷懒；这也与 0.3 的结论一致。

## 3. `BiMap` —— 双向唯一

`pub struct BiMap[K, V] { forward : Map[K, V], backward : Map[V, K] }`：**字段不公开**。
一致性（两个方向互逆）只能由本包维护，放出去让用户直接写 `forward` 就等于允许"两个键指向同一个值"
——那正是本件要避免的状态，不是可以权衡的风格偏好。

| # | 签名 | 冻结读数 | 边界/错误 | hutool 对位 | 差异声明 |
|---|---|---|---|---|---|
| 7.1 | `new` / `get` / `get_key` / `contains_key` / `contains_value` / `length` / `keys` / `values` / `to_pairs` / `inverse` | 夹具 `[("a",1),("b",2),("c",3)]`：`to_pairs()` 原序、`keys() = ["a","b","c"]`、`values() = [1,2,3]`、`get("b") = Some(2)`、`get_key(2) = Some("b")`、`length() = 3`；`inverse().to_pairs() = [(1,"a"),(2,"b"),(3,"c")]`、`inverse().get_key("c") = Some(3)`、`inverse().inverse()` 回到原序 | 空表：`length() = 0`、`to_pairs() = []`、`keys() = []`、`get_key(0) = None` | `BiMap`（`MapWrapper` 的子类）+ `getInverse()`/`getKey(v)` | hutool 的 `getInverse()` 是**懒建的共享视图**（`MapUtil.inverse(getRaw())`），一处改动另一处靠判空重建；本库 `inverse()` **新建一张**满足双向不变式的表，代价 O(n)，换来确定性。`values()` 互不重复是双向不变式的推论，用例逐档断言 |
| 7.2 | `put(self, key, value) -> V? raise MapError` | `put("a", 9)` 在夹具上返回 `Some(1)`，之后 `get("a") = Some(9)`、`get_key(9) = Some("a")`、`get_key(1) = None`、表长不变；同键同值再 `put("a", 1)` 返回 `Some(1)` 且表不变 | **值被别的键占着 ⇒ `ValueConflict`，且这次调用整体不生效**；报错后 `to_pairs()` 与报错前逐条相等，`get_key(9)` 仍答 `"a"`（"谁占着"由表自己回答，所以错误不带载荷） | `BiMap.put` | **不跟随 hutool**：它 `super.put` 之后只补反向表，`put(a,1); put(b,1)` 会得到正向 `{a:1,b:1}` + 反向 `{1:b}` —— 双向索引此时已不一致，`getKey(1)` 只认 `b` 而 `a` 那条还活着。本库按 Guava `BiMap` 的判据拒绝进入该状态 |
| 7.3 | `force_put(self, key, value) -> K?` | 夹具上 `force_put("a", 2)` 返回 `Some("b")`，之后 `to_pairs() = [("a",2),("c",3)]`、`length() = 2`、`get("b") = None`、`get_key(2) = Some("a")`；空表上 `force_put("x", 1)` 返回 `None` | 恒不失败（这就是它存在的意义） | 无（hutool 没有这一档） | 对齐 Guava `BiMap.forcePut`：它删的是**调用方没提过的另一个键**，所以必须是显式命名的档，不能当默认 |
| 7.4 | `remove(self, key) -> V?` | 夹具上 `remove("b") = Some(2)`、`to_pairs() = [("a",1),("c",3)]`、`get("b") = None`、`get_key(2) = None`、`inverse().to_pairs() = [(1,"a"),(3,"c")]` | 摘不存在的键 ⇒ `None`；连续摘同一个键两次都 `None` | `BiMap.remove` | hutool 那侧反向表只在非空时才同步；本库两条方向同步删 |
| 7.5 | `of(pairs) -> BiMap raise MapError` | `[("a",1),("a",2)]` ⇒ 合法，`to_pairs() = [("a",2)]`、`get_key(1) = None`（同键后者胜）；`[]` ⇒ 空表 | `[("a",1),("b",1)]` 与 `[("a",1),("b",2),("c",1)]` ⇒ 都报 `ValueConflict`，**整条构造失败**，不做"保第一条"或"保最后一条"的猜 | `new BiMap(map)` 包一层 | 逐条走 `put` 的判据，所以构造与后续写入同一套规则——两套规则迟早分叉 |

## 4. `CiMap` —— ASCII 大小写不敏感的键空间

`pub struct CiMap[V] { slots : Map[String, (String, V)] }`：折叠键做索引，槽里存
`(首次写入的原样键, 值)`。**折叠只覆盖 ASCII**（`A-Z` → `a-z`）——core 没有 Unicode 大小写表，
`Char` 连 `to_lowercase` 都没有（AGENTS 记过），拖一张表进来等于把工具库的发布节奏绑到码表上。

| # | 签名 | 冻结读数 | 边界/错误 | hutool 对位 | 差异声明 |
|---|---|---|---|---|---|
| 7.6 | `new` / `put(key, value) -> V?` / `get(key) -> V?` / `get_key_of(key) -> String?` / `keys()` / `length()` | `put("Content-Type","text/plain")` → `None`；再 `put("content-type","application/json")` → `Some("text/plain")`；再 `put("X-Trace-Id","abc")` → `None`。之后 `keys() = ["Content-Type","X-Trace-Id"]`（**原样键是首次写入那一个**）、`length() = 2`、`get("CONTENT-TYPE") = Some("application/json")`、`get_key_of("content-type") = Some("Content-Type")`、`get_key_of("nope") = None` | 空表 `length() = 0`、`get(...) = None` | `CaseInsensitiveMap`（`FuncKeyMap` + `CaseInsensitiveKey`） | Java 侧靠 `Map.put` 覆盖值不换键得到同一效果；本库把它升格成契约并断言。`length()` 数的是**槽位**，不是写入次数 |
| 7.7 | `contains(key)` / `remove(key) -> V?` / `to_map() -> Map[String, V]` | 表内 `AbC=1, def=2`：`contains("abc") = contains("ABC") = true`、`contains("xyz") = false`；`remove("ABC") = Some(1)`，再 `contains("abc") = false`、`length() = 1`；`to_map().keys().to_array() = ["def"]`；再 `remove("ABC") = None`（幂等） | 非 ASCII 不折叠：写入 `中文-A` 后 `contains("中文-A") = true` 而 `contains("中文-a") = false` | `CaseInsensitiveMap` 的 `containsKey`/`remove` | `to_map()` 是**出口**不是中转：拿到的 `Map` 按普通大小写敏感规则工作 |

## 5. `Map` 的两个组合件

| # | 签名 | 冻结读数 | 边界/错误 | hutool 对位 | 差异声明 |
|---|---|---|---|---|---|
| 7.8 | `filter_map[K : Hash + Eq, A, B](m : Map[K, A], f : (K, A) -> B?) -> Map[K, B]` | `Map([("a",1),("b",2),("c",3)])` 上"奇数留下并写成 `"k=v"`" ⇒ `keys().to_array() = ["a","c"]`、`get("a") = Some("a=1")`、`get("b") = None`、`get("c") = Some("c=3")`、`length() = 2`；闭包恒 `None` ⇒ 空表、`length() = 0` | 键序沿用输入的插入序；输入不被修改 | `MapUtil.filter(map, Filter<Entry>)`（那侧还要 `filterNewMap` 才不换原表） | core 的 `map`（只换值）与 `retain`（只筛不换）合用要先建中间表；一次遍历做完是本件的唯一增量。闭包恒 `Some` 时与 `Map::map` 同结果（对拍腿，门禁 G8） |
| 7.9 / 7.10 | `rename_key[K : Hash + Eq, V](m : Map[K, V], old_key : K, new_key : K) -> Map[K, V] raise MapError` | `Map([("x",1),("y",2),("z",3)])` 把 `y` 改成 `w` ⇒ `keys().to_array() = ["x","z","w"]`（**新键在末尾**）、`get("w") = Some(2)`、`get("y") = None`，而**输入表不变**：`src.keys() = ["x","y","z"]`、`src.get("y") = Some(2)` | `new_key` 已存在 ⇒ `KeyAlreadyExists`（不静默覆盖）；`old_key` 不存在 ⇒ 原样返回（`get("r") = None`，条目不多不少）；`old_key == new_key` ⇒ **保留该条**（`["k"]`、`get("k") = Some(9)`） | `MapUtil.renameKey(map, oldKey, newKey)` | 两处不跟随：**①** hutool **原地改**传入的 Map，本库返回新 Map（0.2）；**②** hutool 的实现是 `put(new) + remove(old)`，当 `old == new` 时它先写再删同一个键 ⇒ **条目被自己删掉**，这是坑，本库保留。落末尾这一档是跟随 hutool 的（`LinkedHashMap` 上就是这个结果），但写死成契约而不是留给实现心情 |

## 6. 读数从哪来

1. **Python 镜像**：`BiMap`（正向 dict + 反向 dict，`put`/`force_put`/`remove` 各按上面口径写一遍）、
   `CiMap`（`fold` 只动 `A-Z`，槽存 `(原样键, 值)` 且覆盖时不换原样键）、`filter_map`、`rename_key`
   四套独立实现，用**同一批夹具**跑出的值灌成断言。测试文件里没有一条期望是我手算誊的。
2. **hutool 源码现读**（只用来定位档位与差异，不搬实现）：`hutool-core/src/main/java/cn/hutool/core/map/`
   下的 `BiMap.java`（`put` 只补反向表、`getInverse()` 懒建）、`CaseInsensitiveMap.java`（继承 `FuncKeyMap`）、
   `MapUtil.java:1311 renameKey`（`put(new)+remove(old)`，`newKey` 已存在抛 `IllegalArgumentException`）。
   三条"不跟随"（双向不一致、原地改、`old == new` 自删）都是读这几份源码时逐行撞出来的。
3. **参照系**：双向映射的拒绝语义取 Guava `BiMap`（`put` 撞值抛异常 + `forcePut` 显式挤掉），
   大小写不敏感映射的"原样键不换"取 Java `Map.put` 的既有约定。
4. **对拍腿（门禁 G8）两条**：`filter_map` 恒 `Some` 闭包下与 core `Map::map` 同结果；
   `CiMap::to_map()` 的键序与 core `Map` 插入序一致（用例直接比 `keys().to_array()`）。

## 7. 键序与"值不重复"是契约，不是实现细节

`BiMap.values()` 必须互不重复（双向不变式的推论）；`keys()`/`values()`/`to_pairs()` 三者必须自洽
（第 i 条 = `(keys()[i], values()[i]) = to_pairs()[i]`）；`CiMap.keys()` 是**原样键**序列而不是折叠键。
这三条都进用例。不写死的话，实现期最容易发生的就是"顺手换成 `HashMap`"——那时键序还在，
但 `values()` 出现重复就没人拦得住。

## 8. 骨架期的两条编译器裁决（进 AGENTS）

- **泛型 `suberror` 不支持**（见 §2 的 ⚠）：错误面想带泛型读数就只能改设计，不是改语法。
- **泛型结构体的方法必须写全 `Self` 的参数**：`self : Self` 判
  `The type constructor Self expects 2 argument(s), but is here given 0` ⇒ 写 `self : BiMap[K, V]`。
  另外骨架体里必须**碰一下字段**（`let _ = self.forward`），否则未使用的类型参数判 **4027 错误**
  （不是警告，`warnings` 豁免串压不住），而 `struct_never_constructed` 是警告、可以豁免。
  这两类的分界在 moon.pkg 的注释里写明了。

## 9. 这一批不含

| 格子 | 结论 | 依据 |
|---|---|---|
| `Table`（二维表）、`TableMap` | **第二批** | 行列双索引 + 一张网格是第三种形状，混进这份契约会让两边各自承诺的东西看不清 |
| `ForestMap`/`LinkedForestMap`（树形键空间）、`MultiValueMap`、`MergeMap`、`FixedLinkedHashMap`、`ReferenceConcurrentMap`/`SafeConcurrentHashMap` | **不做 / 排后** | 树形与多值各自是一整块语义；并发档需要运行时并发能力，与零依赖契约（全同步）结构冲突 |
| `MapProxy`/`MapBuilder`/`CamelCaseMap` | **不做** | 反射动态代理做不到（AGENTS 的 core 边界条）；builder 在同步无 null 的写法里就是 `Map([...])`；驼峰/下划线键转换属 `text` 的 `NamingCase`，已在 text 交付 |
| Unicode 大小写折叠（`İ`/`ı` 这类非 ASCII 一对一特例） | **不做** | 要码表；本库折叠只覆盖 ASCII，非 ASCII 原样（§4） |
| `remove_null_value`/`removeNullKey` | **不做** | 本库无 null，`Option` 才是缺席的表达方式；为它写一档等于教调用方造一个本库不存在的东西 |
| `sortByValue`/`sort`(键排序成 `TreeMap`) | **不做** | core 有 `SortedMap`/`immut/sorted_map`；要"按值排序"就 `to_array()` + `coll` 的按键极值/排序组合，不在本包再造一套比较件 |
