///|
// moon-hutool/ini —— INI 配置文本的读（分组解析）与写（序列化），以及分组键值容器 `GroupedMap`
// 对位 hutool `cn.hutool.setting.GroupedMap` + `cn.hutool.setting.SettingLoader`（fill/store）
// + `cn.hutool.setting.Setting` 的分组读取面（`getStr(key, group, default)` / `getStrNotEmpty` / `toProperties`）。
// **件在 hutool-setting，不在 core**：`unzip -l hutool-core.jar | grep -ciE "props|grouped"` 现读 **0**
// （core 只有 `SystemPropsUtil` 与 `GroupedTypeGetter`），本格的参照面要另拉 artifact——
// 与 `dfa`/`cache`/`bloom`/`cron` 同性质。腿用 `hutool-setting-5.8.35.jar` + `hutool-log`（`SettingLoader` 的静态 `Log` 字段）。
// 契约真相在 `docs/spec/22-ini.md`；本文件是签名骨架——函数体是 abort，落地笔（PR-B）替换。
//
// 一句话口径：整行先按 hutool 的空白码位表剥边（**这张表比 Java 的 `Character.isWhitespace` 宽**：
// 多出 0x00、00a0、180e、202a、2800、3164、feff，而 0085 与 200b-200f 不在表内）；剥完为空或以 `#` 起头的行跳过
// （**`;` 不是注释符**）；剥完后整行被 `[` `]` 包住才算分组行，分组名再剥一次边，**分组行本身不进数据**；
// 其余行按 `assign_flag`（默认 `=`）**只切第一刀**，切不开（无该字符）就整行丢弃——这与 `java.util.Properties`
// "裸键当空值"正相反；键与值各自再剥边（**值可以是空串，键也可以是空串**）；同组重复键后写覆盖值但**保留首次位置**；
// 分组行不预先建组，组是在第一次写入时才出现的，**组的顺序 = 首次写入顺序**（无分组即空串组）；
// 变量替换（`use_variable`，默认关）只在本行之前已写入的值里找，先同组、再按**第一个点**跨组，
// 找不到就**原样留着** `${...}`，替换为空值也是替换；写侧完全不转义、格式固定 `组名` 单独一行带方括号、
// 条目 `key<空格>assign<空格>value`，末尾也带换行。
//
// `GroupedMap` 的三处参照语义**照搬而不是修**（都挂读数）：`put/remove/clear/contains*/keys/values/entries`
// 的组名一律"先空串兜底再剥边"，而**双参 `get` 不剥边**（写 `" x "` 读 `" x "` 取不到）；
// 总条数 `size` 是**带缓存的**，`put` 失效而 `remove`/`clear` 不失效 ⇒ 先读过 `size` 再删，读数会停在旧值；
// `is_empty` 走 `size == 0` 因而跟着一起陈旧。值类型是 `String?`：解析器永不产出 `None`，
// 但 `grouped_map_put` 收 `None`（参照的 `LinkedHashMap` 允许 null 值），此时双参 `get` 与"键不存在"同读数。
//
// **零 IO**：参照 `Props`/`Setting` 的 `File`/`Path`/`URL`/`Resource`/`Charset`/`WatchMonitor` 入口、
// `SettingUtil`、`toBean`/`fillBean`（反射）、以及变量替换的最后一档"系统属性与环境变量"（`SystemPropsUtil`）
// 一律不收——那是宿主状态，跨平台不可复现；本库全同步、零依赖。

///|
/// #22.1 分组键值容器。对位 `cn.hutool.setting.GroupedMap extends LinkedHashMap<String, LinkedHashMap<String,String>>`。
/// 参照的三个私有字段在这里都是公开的构造细节：组顺序数组 + 每组一个有序条目数组 + 总条数缓存哨兵 -1。
/// 参照的读写锁不进契约（本库全单线程）。
pub struct GroupedMap {
  priv order : Array[String]
  priv buckets : Array[Array[(String, String?)]]
  priv cached_size : Int
}

///|
/// #22.2 解析选项。对位 `SettingLoader` 的三个可拧旋钮里本库收两个：
/// `use_variable`（参照构造参数 `isUseVariable`，默认 `false`）、`assign_flag`（参照 `setAssignFlag(char)`，默认 `'='`）。
/// 参照的第三档 `charset` 属 IO，不进本库；注释符 `#` 在参照是 `private final static`，**不是旋钮**，本库也不开。
pub(all) struct IniParseOpts {
  use_variable : Bool
  assign_flag : Char
}

///|
/// #22.3 默认解析选项（`use_variable = false`、`assign_flag = '='`）
/// - Returns: 与参照 `SettingLoader(GroupedMap, charset, false)` + 字段初值 `assignFlag = '='` 同档的选项
/// - Raises: 无
/// - Note: hutool 对位 `new SettingLoader(groupedMap)`（转手 `this(groupedMap, UTF_8, false)`）
pub fn ini_default_parse_opts() -> IniParseOpts {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.3")
}

///|
/// #22.4 空容器
/// - Returns: 组顺序为空、总条数缓存为哨兵 -1 的新容器
/// - Raises: 无
/// - Note: hutool 对位 `new GroupedMap()`
pub fn grouped_map_new() -> GroupedMap {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.4")
}

///|
/// #22.5 写入一条，返回该键在该组下的旧值
/// - Parameters: `group` 组名（`None` 与空串同组；**两侧都会先剥边**）；`key` 键（不剥边）；`value` 值（可为 `None`）
/// - Returns: 旧值；键首次出现时 `None`
/// - Raises: 无
/// - Note: hutool 对位 `String put(String group, String key, String value)`。
///   参照在此处对组名做 `nullToEmpty(group).trim()`，并把总条数缓存打回 -1（i.o.1 组名剥边、o.R1.3 返回旧值）
pub fn grouped_map_put(
  gm : GroupedMap,
  group : String?,
  key : String,
  value : String?,
) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.5")
}

///|
/// #22.6 按组取值（**组名不剥边**）
/// - Returns: 该组该键的值；组不存在、键不存在、或值为 `None` 时一律 `None`（三档不可分辨，照参照）
/// - Raises: 无
/// - Note: hutool 对位 `String get(String group, String key)`——它只做 `nullToEmpty(group)`、**不 trim**，
///   与 #22.5 不对称：`o.R2.3` 写 `" x "` 后 `get(" x ")` 给 `None`，而 `get("x")` 给 `Some("v")`
pub fn grouped_map_get(
  gm : GroupedMap,
  group : String?,
  key : String,
) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.6")
}

///|
/// #22.7 删一条，返回被删的值
/// - Returns: 被删值；组或键不存在时 `None`
/// - Raises: 无
/// - Note: hutool 对位 `String remove(String group, String key)`。
///   **参照不在这里失效总条数缓存**（源码里只有 `put` 写了 `this.size = -1`）⇒ 与 #22.9 连用有陈旧读数（o.S3.4/o.S3.5）
pub fn grouped_map_remove(
  gm : GroupedMap,
  group : String?,
  key : String,
) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.7")
}

///|
/// #22.8 清空一个组（**组本身留在顺序里**，条目清空）
/// - Raises: 无
/// - Note: hutool 对位 `GroupedMap clear(String group)`。组不存在是无操作；
///   与 #22.7 同样**不失效总条数缓存**（o.S4.2/o.S4.3 组仍在、o.S4.5 读数 0 只因缓存此前未填）
pub fn grouped_map_clear_group(gm : GroupedMap, group : String?) -> Unit {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.8")
}

///|
/// #22.9 总键值对数（带缓存，可能陈旧）
/// - Returns: 各组条目数之和；**若上次缓存填好之后发生过 #22.7/#22.8，读数停在旧值**（照参照）
/// - Raises: 无
/// - Note: hutool 对位 `int size()`。`o.S3.3` 删一条后仍读 2、`o.S7.7` 同型；
///   首次读数会把缓存填上（`o.R4.3` 无缓存时删完再读 ⇒ 正确的 0）——两档都要能复现
pub fn grouped_map_size(gm : GroupedMap) -> Int {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.9")
}

///|
/// #22.10 整个容器是否"没有条目"
/// - Returns: `grouped_map_size(gm) == 0`——因而跟着 #22.9 的缓存一起陈旧
/// - Raises: 无
/// - Note: hutool 对位 `boolean isEmpty()`（`o.S8.8` 是全删完之后仍读 `false` 的那一档）
pub fn grouped_map_is_empty(gm : GroupedMap) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.10")
}

///|
/// #22.11 某个组是否"没有条目"（组不存在也算没有条目）
/// - Returns: `Bool`
/// - Raises: 无
/// - Note: hutool 对位 `boolean isEmpty(String group)`，组名走 #22.5 那套兜底+剥边（`o.S4.6`/`o.R5.7`）
pub fn grouped_map_is_group_empty(gm : GroupedMap, group : String?) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.11")
}

///|
/// #22.12 某组是否含该键
/// - Returns: `Bool`；组名兜底+剥边
/// - Raises: 无
/// - Note: hutool 对位 `boolean containsKey(String group, String key)`（`o.S2.5` 带边也命中）
pub fn grouped_map_contains_key(
  gm : GroupedMap,
  group : String?,
  key : String,
) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.12")
}

///|
/// #22.13 某组是否含该值
/// - Returns: `Bool`；组名兜底+剥边；`value` 传 `None` 时参照用 `LinkedHashMap.containsValue(null)`，
///   **能命中 `None` 值**（`o.R3.4` 读数 true）
/// - Raises: 无
/// - Note: hutool 对位 `boolean containsValue(String group, String value)`
pub fn grouped_map_contains_value(
  gm : GroupedMap,
  group : String?,
  value : String?,
) -> Bool {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.13")
}

///|
/// #22.14 组名列表（首次写入顺序）
/// - Returns: `Array[String]`；空串组也在里面（`i.group_then_empty_group.groups` 是 `g|`，组在写入时才出现）
/// - Raises: 无
/// - Note: hutool 对位 `keySet()` / `Setting.getGroups()`
pub fn grouped_map_groups(gm : GroupedMap) -> Array[String] {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.14")
}

///|
/// #22.15 某组的键列表（插入顺序；后写覆盖值**不改位置**）
/// - Returns: 组不存在时为空数组（参照 `Collections.emptySet()`）
/// - Raises: 无
/// - Note: hutool 对位 `Set<String> keySet(String group)`（`i.dup_three` 的 `a,b,c` 顺序钉这一条）
pub fn grouped_map_keys(gm : GroupedMap, group : String?) -> Array[String] {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.15")
}

///|
/// #22.16 某组的值列表（与 #22.15 同序）
/// - Returns: `Array[String?]`；组不存在时为空数组
/// - Raises: 无
/// - Note: hutool 对位 `Collection<String> values(String group)`（`o.S1.10` 覆盖后读数 `9,2` 即"值跟键位走"）
pub fn grouped_map_values(gm : GroupedMap, group : String?) -> Array[String?] {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.16")
}

///|
/// #22.17 某组的条目列表（与 #22.15 同序）
/// - Returns: `Array[(String, String?)]`；组不存在时为空数组
/// - Raises: 无
/// - Note: hutool 对位 `Set<Entry<String,String>> entrySet(String group)`；本库把 `entrySet` 与
///   `Setting.getMap(group)` 合成一个形状（两者给出同一批条目，只是容器不同）
pub fn grouped_map_entries(
  gm : GroupedMap,
  group : String?,
) -> Array[(String, String?)] {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.17")
}

///|
/// #22.18 批量写入某组
/// - Raises: 无
/// - Note: hutool 对位 `GroupedMap putAll(String group, Map<? extends String, ? extends String> m)`
///   ——参照是逐条转手 #22.5，**不是**整组合并（`o.S8.1` 之后 `keys` 给 `a,b`）
pub fn grouped_map_put_all(
  gm : GroupedMap,
  group : String?,
  entries : Array[(String, String?)],
) -> Unit {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.18")
}

///|
/// #22.19 摊平成 `Properties` 形状的扁平键值（组名当前缀）
/// - Returns: 按组顺序、组内键顺序展开的 `Array[(String, String?)]`；
///   **空串组不加前缀**，其余组是 `组名 + "." + 键`
/// - Raises: 无
/// - Note: hutool 对位 `Setting.toProperties()`（`i.group_reopen.flat` 给 `g.a`/`g.c`/`h.b`，
///   `i.basic.flat` 给裸 `name`/`age`）。参照返回的是 `Properties`（`Hashtable` 无序），
///   本库给有序数组；配对规则两侧逐字一致，见 spec §4 的腿口径
pub fn grouped_map_flatten(gm : GroupedMap) -> Array[(String, String?)] {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.19")
}

///|
/// #22.20 解析 INI 文本（默认选项）
/// - Raises: 无——参照在这条路上不报错（不合规的行是**丢弃**，不是失败）
/// - Note: hutool 对位 `SettingLoader.load(InputStream)` 的逐行主体
pub fn ini_parse(text : String) -> GroupedMap {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.20")
}

///|
/// #22.21 解析 INI 文本（带选项）
/// - Parameters: `opts` 见 #22.2
/// - Raises: 无
/// - Note: hutool 对位 `new SettingLoader(groupedMap, charset, isUseVariable)` + `setAssignFlag(char)`
pub fn ini_parse_with_opts(text : String, opts : IniParseOpts) -> GroupedMap {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.21")
}

///|
/// #22.22 序列化成 INI 文本
/// - Returns: 每组一行 `[组名]`（空串组是 `[]`），组内每行 `key<空格>assign<空格>value`，
///   **每条都以换行结尾**；空容器给空串。**值一律不转义**——含换行的值会写出多行、`None` 写成 `null`
///   （`w.W1.10.store` 是这两档的读数）
/// - Raises: 无
/// - Note: hutool 对位 `SettingLoader.store(PrintWriter)`。参照用平台行分隔符（本机腿读数 `\r\n`），
///   本库钉死 `\n`，两侧读数按 spec §5 第 1 行的分隔符口径对齐
pub fn ini_store(gm : GroupedMap) -> String {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.22")
}

///|
/// #22.23 带缺省值读取（**只在"读不到"时兜底**）
/// - Returns: `grouped_map_get` 的读数；为 `None` 时给 `default`。**空串值不会被兜底**
///   （`s.b/g/D.str3` 读数仍是空串——这是它和 #22.24 的分界）
/// - Raises: 无
/// - Note: hutool 对位 `AbsSetting.getStr(String key, String group, String defaultValue)`
pub fn ini_get_str(
  gm : GroupedMap,
  key : String,
  group : String?,
  default : String?,
) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.23")
}

///|
/// #22.24 带缺省值读取（**空值也兜底**）
/// - Returns: 取不到、或取到的值按空白码位表整串为空 ⇒ 给 `default`
///   （`s.b/g/D.notempty` 读数 `D`，而 `s.n/g/D.notempty` 读数 `1`）
/// - Raises: 无
/// - Note: hutool 对位 `AbsSetting.getStrNotEmpty(String key, String group, String defaultValue)`
pub fn ini_get_str_not_empty(
  gm : GroupedMap,
  key : String,
  group : String?,
  default : String?,
) -> String? {
  abort("moon-hutool PR-B：契约骨架，见 docs/spec/22-ini.md #22.24")
}
