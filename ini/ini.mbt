///|
// moon-hutool/ini —— INI 配置文本的读（分组解析）与写（序列化），以及分组键值容器 `GroupedMap`
// 对位 hutool `cn.hutool.setting.GroupedMap` + `cn.hutool.setting.SettingLoader`（fill/store）
// + `cn.hutool.setting.Setting` 的分组读取面（`getByGroup` / `getStr(key, group, default)` / `getStrNotEmpty` / `toProperties`）。
// **件在 hutool-setting，不在 core**：`unzip -l hutool-core.jar | grep -ciE "props|grouped"` 现读 **0**
// （core 的 `cn/hutool/core/map/` 里只有 `BiMap`/`TableMap`/`ForestMap` 等，没有 `GroupedMap`；`cn/hutool/core/util/` 只有
// `SystemPropsUtil`）。本格因此**另拉 artifact**（与 `dfa`/`cache`/`bloom`/`cron` 同性质，与 `hash`/`csv` 相反）：
// 腿用 `hutool-setting-5.8.35.jar`，运行期还要 `hutool-log-5.8.35.jar`（`SettingLoader` 的静态 `Log` 是类初始化依赖）。
// 契约真相在 `docs/spec/22-ini.md`。
//
// 一句话口径：整行先按实测的 35 位空白码表剥边（比 `Character.isWhitespace` 宽，表在 `@text.is_blank_char`，整仓一张）；
// 剥完为空或以 `#` 起头的行跳过（`;` 不是注释符）；剥完后整行被 `[` `]` 包住才算分组行，分组名再剥一次边，
// 分组行本身不进数据、组在首次写入时才出现；其余行按 `assign_flag`（默认 `=`）只切第一刀，
// 切不开就整行丢弃（与 `java.util.Properties` "裸键当空值"正相反）；键与值各自再剥边（两侧都可为空串，
// 空值恒为 `Some("")` 而非 `None`）；同组重复键后写覆盖值但保留首次位置；
// 变量替换（默认关）只看得见本行之前已写入的值，先同组、再按第一个点跨组，查不到就原样留着 `${...}`，
// 解析成空串也算命中；写侧完全不转义、组名单独一行带方括号、条目 `key 空格 assign 空格 value`、末尾也带换行。
//
// `GroupedMap` 的三处参照语义照搬而不修（都挂读数）：`put/remove/clear/contains*/keys/values/entries` 的组名
// 一律"先空串兜底再剥边"，而双参 `get` 不剥边；总条数带缓存，`put` 失效而 `remove`/`clear` 不失效 ⇒
// 先读过再删会停在旧值，`is_empty` 跟着陈旧；值类型是 `String?`，解析器永不产出 `None`，
// 但 `grouped_map_put` 收 `None`（参照的 `LinkedHashMap` 容 null 值），此时双参 `get` 与"键不存在"同读数。
//
// **零 IO**：参照 `Props`/`Setting` 的 `File`/`URL`/`Resource`/`Charset`/`WatchMonitor` 入口、`SettingUtil`、
// `toBean`/`fillBean`（反射）、以及变量替换的最后一档"系统属性与环境变量"（`SystemPropsUtil`）一律不收。
// `java.util.Properties` 的严格语义（反斜杠续行、`!` 注释、三档分隔符、`\uXXXX` 解码、`store` 转义表）
// 属第二批（`#22.26` 起），权威参照是 JDK 而不是 hutool。

///|
/// #22.1 分组键值容器。对位 `cn.hutool.setting.GroupedMap extends LinkedHashMap<String, LinkedHashMap<String,String>>`。
/// 参照的三个私有字段在这里都是公开的构造细节：组顺序数组 + 每组一个有序条目数组 + 总条数缓存哨兵 -1。
/// 参照的读写锁不进契约（本库全单线程）。
pub struct GroupedMap {
  priv order : Array[String]
  priv buckets : Array[Array[(String, String?)]]
  priv mut cached_size : Int
}

///|
/// #22.2 解析选项。对位 `SettingLoader` 的三个可拧旋钮里本库收两个：
/// `use_variable`（参照构造参数 `isUseVariable`，默认 `false`）、`assign_flag`（参照 `setAssignFlag(char)`，默认 `'='`）。
/// 参照的第三档 `charset` 属 IO，不进本库；注释符 `#` 在参照是 `private final static`，不是旋钮，本库也不开。
pub(all) struct IniParseOpts {
  use_variable : Bool
  assign_flag : Char
}

///|
// 参照 `StrUtil.trim`：按上表剥首尾，整串空白给空串（参照给 `EMPTY_STR`，不是 null）
fn hb_trim(s : String) -> String {
  let cs = s.to_array()
  let n = cs.length()
  let mut lo = 0
  let mut hi = n
  while lo < hi && @text.is_blank_char(cs[lo]) {
    lo += 1
  }
  while hi > lo && @text.is_blank_char(cs[hi - 1]) {
    hi -= 1
  }
  if lo == 0 && hi == n {
    s
  } else {
    String::from_array(cs[lo:hi])
  }
}

///|
// 参照 `StrUtil.isBlank`：空串，或整串都是空白码位
fn hb_is_blank(s : String) -> Bool {
  let cs = s.to_array()
  let n = cs.length()
  let mut i = 0
  let mut blank = true
  while i < n {
    if !@text.is_blank_char(cs[i]) {
      blank = false
      i = n
    } else {
      i += 1
    }
  }
  blank
}

///|
// 组名兜底 + 剥边（参照 `nullToEmpty(group).trim()`）——双参 `get` 不走这条，只兜底不剥边
fn or_empty(g : String?) -> String {
  match g {
    None => ""
    Some(s) => s
  }
}

///|
fn val_text(v : String?) -> String {
  match v {
    None => "null"
    Some(s) => s
  }
}

///|
fn gnorm(group : String?) -> String {
  hb_trim(or_empty(group))
}

///|
fn find_group(gm : GroupedMap, g : String) -> Int {
  let n = gm.order.length()
  let mut i = 0
  let mut hit = -1
  while i < n {
    if gm.order[i] == g {
      hit = i
      i = n
    } else {
      i += 1
    }
  }
  hit
}

///|
fn find_str(arr : Array[String], s : String) -> Int {
  let n = arr.length()
  let mut i = 0
  let mut hit = -1
  while i < n {
    if arr[i] == s {
      hit = i
      i = n
    } else {
      i += 1
    }
  }
  hit
}

///|
// 按参照双参 `get` 的形状取桶：组名只兜底、不剥边
fn bucket_of(gm : GroupedMap, group : String?) -> Array[(String, String?)] {
  let gi = find_group(gm, or_empty(group))
  if gi < 0 {
    []
  } else {
    gm.buckets[gi]
  }
}

///|
// 规范化组名取桶（put/remove/clear/contains/keys/values/entries 走这条）
fn bucket_norm(gm : GroupedMap, group : String?) -> Array[(String, String?)] {
  let gi = find_group(gm, gnorm(group))
  if gi < 0 {
    []
  } else {
    gm.buckets[gi]
  }
}

///|
fn find_key(b : Array[(String, String?)], key : String) -> Int {
  let n = b.length()
  let mut i = 0
  let mut hit = -1
  while i < n {
    if b[i].0 == key {
      hit = i
      i = n
    } else {
      i += 1
    }
  }
  hit
}

///|
fn keys_of(b : Array[(String, String?)]) -> Array[String] {
  let out : Array[String] = []
  let mut i = 0
  while i < b.length() {
    out.push(b[i].0)
    i += 1
  }
  out
}

///|
fn values_of(b : Array[(String, String?)]) -> Array[String?] {
  let out : Array[String?] = []
  let mut i = 0
  while i < b.length() {
    out.push(b[i].1)
    i += 1
  }
  out
}

///|
// `BufferedReader.readLine` 的行分隔集：LF、CR、CRLF 三种，其余（含 U+2028/U+0085）不算换行
fn split_lines(text : String) -> Array[String] {
  let cs = text.to_array()
  let n = cs.length()
  let out : Array[String] = []
  let mut start = 0
  let mut i = 0
  while i < n {
    let c = cs[i].to_int()
    if c == 0x0d || c == 0x0a {
      out.push(String::from_array(cs[start:i]))
      i += 1
      if c == 0x0d && i < n && cs[i].to_int() == 0x0a {
        i += 1
      }
      start = i
    } else {
      i += 1
    }
  }
  if start < n {
    out.push(String::from_array(cs[start:n]))
  }
  out
}

///|
fn replace_all(src : String, pat : String, rep : String) -> String {
  let s = src.to_array()
  let p = pat.to_array()
  let plen = p.length()
  if plen == 0 {
    src
  } else {
    let out : Array[Char] = []
    let mut i = 0
    while i < s.length() {
      let mut k = 0
      while k < plen && i + k < s.length() && s[i + k] == p[k] {
        k += 1
      }
      if k == plen {
        for c in rep.to_array() {
          out.push(c)
        }
        i += plen
      } else {
        out.push(s[i])
        i += 1
      }
    }
    String::from_array(out)
  }
}

///|
// 参照 `SettingLoader.replaceVar`：正则 `\$\{(.*?)\}` 抓非贪婪整串，逐个按字面全量替换；
// 内层空白 ⇒ 整档跳过；同组先查（走不剥边的双参 get），再按第一个点跨组查；
// 参照的第三档"系统属性与环境变量"属宿主状态、本库不收 ⇒ 两档都落空就原样留着
fn replace_var(gm : GroupedMap, group : String, value : String) -> String {
  let cs = value.to_array()
  let n = cs.length()
  let vars : Array[String] = []
  let mut i = 0
  while i + 1 < n {
    if cs[i].to_int() == 0x24 && cs[i + 1].to_int() == 0x7b {
      let mut j = i + 2
      let mut close = -1
      while j < n && close < 0 {
        if cs[j].to_int() == 0x7d {
          close = j
        }
        j += 1
      }
      if close >= 0 {
        let whole = String::from_array(cs[i:close + 1])
        if find_str(vars, whole) < 0 {
          vars.push(whole)
        }
        i = close + 1
      } else {
        i += 2
      }
    } else {
      i += 1
    }
  }
  let mut out = value
  let mut v = 0
  while v < vars.length() {
    let whole = vars[v]
    let wc = whole.to_array()
    let inner = String::from_array(wc[2:wc.length() - 1])
    if !hb_is_blank(inner) {
      let mut found = grouped_map_get(gm, Some(group), inner)
      if found == None {
        let ic = inner.to_array()
        let dot = find_dot(ic)
        if dot >= 0 {
          // 参照 `StrUtil.split(key, '.', 2)`：size>1 才跨组查（第一个点两侧都可以是空串）
          let g2 = String::from_array(ic[0:dot])
          let k2 = String::from_array(ic[dot + 1:ic.length()])
          found = grouped_map_get(gm, Some(g2), k2)
        }
      }
      match found {
        Some(vv) => out = replace_all(out, whole, vv)
        None => ()
      }
    }
    v += 1
  }
  out
}

///|
fn find_dot(ic : Array[Char]) -> Int {
  let n = ic.length()
  let mut i = 0
  let mut hit = -1
  while i < n {
    if ic[i].to_int() == 0x2e {
      hit = i
      i = n
    } else {
      i += 1
    }
  }
  hit
}

///|
fn store_text(gm : GroupedMap, assign : Char) -> String {
  let mut out = ""
  let mut i = 0
  while i < gm.order.length() {
    out = out + "[" + gm.order[i] + "]\n"
    let mut j = 0
    while j < gm.buckets[i].length() {
      let e = gm.buckets[i][j]
      // 参照 `StrUtil.format("{} {} {}", key, assignFlag, value)`：null 值渲染成字面 null，其余原样不转义
      out = out + e.0 + " " + assign.to_string() + " " + val_text(e.1) + "\n"
      j += 1
    }
    i += 1
  }
  out
}

///|
/// #22.3 默认解析选项（`use_variable = false`、`assign_flag = '='`）
/// - Returns: 与参照 `SettingLoader(GroupedMap, charset, false)` + 字段初值 `assignFlag = '='` 同档的选项
/// - Raises: 无
/// - Note: hutool 对位 `new SettingLoader(groupedMap)`（转手 `this(groupedMap, UTF_8, false)`）
pub fn ini_default_parse_opts() -> IniParseOpts {
  IniParseOpts::{ use_variable: false, assign_flag: '=', }
}

///|
/// #22.4 空容器
/// - Returns: 组顺序为空、总条数缓存为哨兵 -1 的新容器
/// - Raises: 无
/// - Note: hutool 对位 `new GroupedMap()`
pub fn grouped_map_new() -> GroupedMap {
  GroupedMap::{ order: [], buckets: [], cached_size: -1, }
}

///|
/// #22.5 写入一条，返回该键在该组下的旧值
/// - Parameters: `group` 组名（`None` 与空串同组；两侧都会先剥边）；`key` 键（不剥边）；`value` 值（可为 `None`）
/// - Returns: 旧值；键首次出现时 `None`
/// - Raises: 无
/// - Note: hutool 对位 `String put(String group, String key, String value)`
pub fn grouped_map_put(
  gm : GroupedMap,
  group : String?,
  key : String,
  value : String?,
) -> String? {
  let g = gnorm(group)
  let mut gi = find_group(gm, g)
  if gi < 0 {
    gm.order.push(g)
    gm.buckets.push([])
    gi = gm.order.length() - 1
  }
  gm.cached_size = -1
  let b = gm.buckets[gi]
  let ki = find_key(b, key)
  if ki < 0 {
    b.push((key, value))
    None
  } else {
    let old = b[ki].1
    b[ki] = (key, value)
    old
  }
}

///|
/// #22.6 按组取值（**组名不剥边**）
/// - Returns: 该组该键的值；组不存在、键不存在、或值为 `None` 时一律 `None`（三档不可分辨，照参照）
/// - Raises: 无
/// - Note: hutool 对位 `String get(String group, String key)`——它只做 `nullToEmpty(group)`、不 trim
pub fn grouped_map_get(
  gm : GroupedMap,
  group : String?,
  key : String,
) -> String? {
  let b = bucket_of(gm, group)
  let ki = find_key(b, key)
  if ki < 0 {
    None
  } else {
    b[ki].1
  }
}

///|
/// #22.7 删一条，返回被删的值
/// - Returns: 被删值；组或键不存在时 `None`
/// - Raises: 无
/// - Note: hutool 对位 `String remove(String group, String key)`。
///   参照在这里不失效总条数缓存 ⇒ 与 #22.9 连用有陈旧读数
pub fn grouped_map_remove(
  gm : GroupedMap,
  group : String?,
  key : String,
) -> String? {
  let gi = find_group(gm, gnorm(group))
  if gi < 0 {
    None
  } else {
    let b = gm.buckets[gi]
    let ki = find_key(b, key)
    if ki < 0 {
      None
    } else {
      let old = b[ki].1
      let nb : Array[(String, String?)] = []
      let mut i = 0
      while i < b.length() {
        if i != ki {
          nb.push(b[i])
        }
        i += 1
      }
      gm.buckets[gi] = nb
      old
    }
  }
}

///|
/// #22.8 清空一个组（组本身留在顺序里，条目清空）
/// - Raises: 无
/// - Note: hutool 对位 `GroupedMap clear(String group)`；组不存在是无操作，同样不失效总条数缓存
pub fn grouped_map_clear_group(gm : GroupedMap, group : String?) -> Unit {
  let gi = find_group(gm, gnorm(group))
  if gi >= 0 {
    gm.buckets[gi] = []
  }
}

///|
/// #22.9 总键值对数（带缓存，可能陈旧）
/// - Returns: 各组条目数之和；若上次缓存填好之后发生过 #22.7/#22.8，读数停在旧值（照参照）
/// - Raises: 无
/// - Note: hutool 对位 `int size()`
pub fn grouped_map_size(gm : GroupedMap) -> Int {
  if gm.cached_size < 0 {
    let mut sum = 0
    let mut i = 0
    while i < gm.buckets.length() {
      sum += gm.buckets[i].length()
      i += 1
    }
    gm.cached_size = sum
  }
  gm.cached_size
}

///|
/// #22.10 整个容器是否"没有条目"
/// - Returns: `grouped_map_size(gm) == 0`——因而跟着 #22.9 的缓存一起陈旧
/// - Raises: 无
/// - Note: hutool 对位 `boolean isEmpty()`
pub fn grouped_map_is_empty(gm : GroupedMap) -> Bool {
  grouped_map_size(gm) == 0
}

///|
/// #22.11 某个组是否"没有条目"（组不存在也算没有条目）
/// - Raises: 无
/// - Note: hutool 对位 `boolean isEmpty(String group)`
pub fn grouped_map_is_group_empty(gm : GroupedMap, group : String?) -> Bool {
  bucket_norm(gm, group).length() == 0
}

///|
/// #22.12 某组是否含该键
/// - Raises: 无
/// - Note: hutool 对位 `boolean containsKey(String group, String key)`
pub fn grouped_map_contains_key(
  gm : GroupedMap,
  group : String?,
  key : String,
) -> Bool {
  find_key(bucket_norm(gm, group), key) >= 0
}

///|
/// #22.13 某组是否含该值
/// - Returns: 组名兜底+剥边；`value` 传 `None` 时参照用 `LinkedHashMap.containsValue(null)`，能命中 `None` 值
/// - Raises: 无
/// - Note: hutool 对位 `boolean containsValue(String group, String value)`
pub fn grouped_map_contains_value(
  gm : GroupedMap,
  group : String?,
  value : String?,
) -> Bool {
  let b = bucket_norm(gm, group)
  let n = b.length()
  let mut i = 0
  let mut hit = false
  while i < n {
    if b[i].1 == value {
      hit = true
      i = n
    } else {
      i += 1
    }
  }
  hit
}

///|
/// #22.14 组名列表（首次写入顺序；空串组也在里面，且组在首次写入时才出现）
/// - Raises: 无
/// - Note: hutool 对位 `keySet()` / `Setting.getGroups()`
pub fn grouped_map_groups(gm : GroupedMap) -> Array[String] {
  gm.order.copy()
}

///|
/// #22.15 某组的键列表（插入顺序；后写覆盖值不改位置；组不存在给空数组）
/// - Raises: 无
/// - Note: hutool 对位 `Set<String> keySet(String group)`
pub fn grouped_map_keys(gm : GroupedMap, group : String?) -> Array[String] {
  keys_of(bucket_norm(gm, group))
}

///|
/// #22.16 某组的值列表（与 #22.15 同序）
/// - Returns: `Array[String?]`；组不存在时为空数组
/// - Raises: 无
/// - Note: hutool 对位 `Collection<String> values(String group)`
pub fn grouped_map_values(gm : GroupedMap, group : String?) -> Array[String?] {
  values_of(bucket_norm(gm, group))
}

///|
/// #22.17 某组的条目列表（与 #22.15 同序；组不存在给空数组）
/// - Raises: 无
/// - Note: hutool 对位 `entrySet(String group)` / `Setting.getMap(group)`
pub fn grouped_map_entries(
  gm : GroupedMap,
  group : String?,
) -> Array[(String, String?)] {
  bucket_norm(gm, group).copy()
}

///|
/// #22.18 批量写入某组
/// - Raises: 无
/// - Note: hutool 对位 `GroupedMap putAll(String group, m)`——逐条转手 #22.5，不是整组合并
pub fn grouped_map_put_all(
  gm : GroupedMap,
  group : String?,
  entries : Array[(String, String?)],
) -> Unit {
  let mut i = 0
  while i < entries.length() {
    let _ = grouped_map_put(gm, group, entries[i].0, entries[i].1)
    i += 1
  }
}

///|
/// #22.19 摊平成 `Properties` 形状的扁平键值（组名当前缀）
/// - Returns: 按组顺序、组内键顺序展开；空串组不加前缀，其余组是 `组名 + "." + 键`
/// - Raises: 无
/// - Note: hutool 对位 `Setting.toProperties()` 的拼接规则（参照给无序 `Hashtable`，本库给有序数组）
pub fn grouped_map_flatten(gm : GroupedMap) -> Array[(String, String?)] {
  let out : Array[(String, String?)] = []
  let mut i = 0
  while i < gm.order.length() {
    let g = gm.order[i]
    let mut j = 0
    while j < gm.buckets[i].length() {
      let e = gm.buckets[i][j]
      let k = if g == "" { e.0 } else { g + "." + e.0 }
      out.push((k, e.1))
      j += 1
    }
    i += 1
  }
  out
}

///|
/// #22.20 解析 INI 文本（默认选项）
/// - Raises: 无——参照在这条路上不报错（不合规的行是丢弃，不是失败）
/// - Note: hutool 对位 `SettingLoader.load(InputStream)` 的逐行主体
pub fn ini_parse(text : String) -> GroupedMap {
  ini_parse_with_opts(text, ini_default_parse_opts())
}

///|
/// #22.21 解析 INI 文本（带选项）
/// - Raises: 无
/// - Note: hutool 对位 `new SettingLoader(groupedMap, charset, isUseVariable)` + `setAssignFlag(char)`
pub fn ini_parse_with_opts(text : String, opts : IniParseOpts) -> GroupedMap {
  let gm = grouped_map_new()
  let assign = opts.assign_flag.to_int()
  let comment = '#'.to_int()
  let open = '['.to_int()
  let close = ']'.to_int()
  let mut group = ""
  for raw in split_lines(text) {
    let line = hb_trim(raw)
    if hb_is_blank(line) {
      continue
    }
    let lc = line.to_array()
    if lc[0].to_int() == comment {
      continue
    }
    if lc.length() >= 2 &&
      lc[0].to_int() == open &&
      lc[lc.length() - 1].to_int() == close {
      group = hb_trim(String::from_array(lc[1:lc.length() - 1]))
      continue
    }
    let mut pos = -1
    let mut i = 0
    while i < lc.length() && pos < 0 {
      if lc[i].to_int() == assign {
        pos = i
      }
      i += 1
    }
    if pos < 0 {
      continue
    }
    let key = hb_trim(String::from_array(lc[0:pos]))
    let raw_value = hb_trim(String::from_array(lc[pos + 1:lc.length()]))
    let value = if opts.use_variable {
      replace_var(gm, group, raw_value)
    } else {
      raw_value
    }
    let _ = grouped_map_put(gm, Some(group), key, Some(value))
  }
  gm
}

///|
/// #22.22 序列化成 INI 文本（默认 `=` 分隔符）
/// - Returns: 每组一行 `[组名]`（空串组是 `[]`），组内每行 `key<空格>=<空格>value`，每条都以换行结尾；
///   空容器给空串；值一律不转义
/// - Raises: 无
/// - Note: hutool 对位 `SettingLoader.store(PrintWriter)`。参照用平台行分隔符（本机腿现读 CRLF），
///   本库钉死 `\n`，见 spec §5 第 7 行
pub fn ini_store(gm : GroupedMap) -> String {
  store_text(gm, '=')
}

///|
/// #22.23 带缺省值读取（只在"读不到"时兜底）
/// - Returns: #22.6 的读数；为 `None` 时给 `default`。空串值不会被兜底
/// - Raises: 无
/// - Note: hutool 对位 `AbsSetting.getStr(String key, String group, String defaultValue)`
pub fn ini_get_str(
  gm : GroupedMap,
  key : String,
  group : String?,
  default : String?,
) -> String? {
  let v = grouped_map_get(gm, group, key)
  if v == None {
    default
  } else {
    v
  }
}

///|
/// #22.24 带缺省值读取（空值也兜底）
/// - Returns: 取不到、或取到的值按空白码表整串为空 ⇒ 给 `default`
/// - Raises: 无
/// - Note: hutool 对位 `AbsSetting.getStrNotEmpty(String key, String group, String defaultValue)`
pub fn ini_get_str_not_empty(
  gm : GroupedMap,
  key : String,
  group : String?,
  default : String?,
) -> String? {
  let v = grouped_map_get(gm, group, key)
  match v {
    None => default
    Some(s) => if hb_is_blank(s) { default } else { v }
  }
}

///|
/// #22.25 序列化成 INI 文本（带选项；分隔符跟着 `assign_flag`）
/// - Returns: 与 #22.22 同形，只是 `key<空格>assign<空格>value` 里的 `assign` 取选项值
///   （腿 `i.assign_colon` 给 `a : b`、`i.assign_is_space` 给 `a` 后三个空格再跟值）
/// - Raises: 无
/// - Note: 参照 `SettingLoader.store(PrintWriter)` 读的是该 loader 自己的 `assignFlag` 字段，
///   所以序列化必须能拿到同一档；PR-A 只给了默认档，落地时补这一件（spec §5 第 10 行）
pub fn ini_store_with_opts(gm : GroupedMap, opts : IniParseOpts) -> String {
  store_text(gm, opts.assign_flag)
}

///|

///|

///|

///|

///|
// —— 第二批：`Props` 的 java.util.Properties 严格语义（`#22.26` 起，权威参照是 JDK 不是 hutool）——
// 参照 `cn.hutool.setting.dialect.Props` 的解析全部转手 `super.load(reader)`，所以这一半的真相在
// `java.util.Properties`（本机 JDK 17.0.14，`java.base/java/util/Properties.java` 的
// `load0` / `LineReader.readLine` / `loadConvert` / `saveConvert` 四段原文已就地读出照抄语义）。
// 与第一批的 INI 面**同名不同语义**：分隔符是 `=`/`:`/空格三档、裸键给空值、注释符 `#` 与 `!` 两个、
// 反斜杠参与语法（续行 + `\t\n\f\r\\` + `\uXXXX`）、"空白"只认 `' '`/`'\t'`/`'\f'` 三个
// （`00a0`/`3000` 在这里原样保留，与 §3-1 的 35 位表（在 `@text.is_blank_char`）逐字符相反）。

///|
/// #22.26 解析错误面。参照唯一实测可复现的失败：畸形的 `\uXXXX`（长度不足或含非十六进制字符）⇒
/// `java.lang.IllegalArgumentException: Malformed \uxxxx encoding.`（腿 4 条 `ERR` 读数全在这一族）。
/// 本库只映射"哪一档"，不复制文案、不带位置；一行里先解出合法 `\u0041` 再撞畸形 ⇒ 整条 load 失败（不留半表）。
pub suberror PropsError {
  BadUnicodeEscape
}

///|
/// #22.27 扁平属性表。对位 `java.util.Properties`（`Hashtable`，但 `load`/`setProperty` 只写 String，
/// null 键或 null 值直接 `NullPointerException` ⇒ 本库两侧都收非空 `String`）。
/// 参照无序，本库把顺序定成"首次出现位置"（后写覆盖值不改位置）——这条是本库自定，声明在 spec §9.1 第 2 条。
pub struct Props {
  priv mut order : Array[String]
  priv mut values : Array[String]
}

///|
// `LineReader` 认的三个空白（不是 `Character.isWhitespace`，也不是第一批的 35 位表（在 `@text.is_blank_char`））
fn is_ws3(cp : Int) -> Bool {
  cp == 0x20 || cp == 0x09 || cp == 0x0c
}

///|
// `\r\n` 算一个终止符
fn eol_len(cs : Array[Char], i : Int, n : Int) -> Int {
  if cs[i].to_int() == 0x0d && i + 1 < n && cs[i + 1].to_int() == 0x0a {
    2
  } else {
    1
  }
}

///|
// 参照 `LineReader.readLine` 的单趟扫描：行首空白吸收 → 注释整行吞（注释行尾的反斜杠不续行）→
// 自然行尾若是奇数个反斜杠则去掉该反斜杠接下一自然行（`skipWhiteSpace` 重新打开）。
// EOF 收尾按参照的 `precedingBackslash ? len - 1 : len`。
fn logical_lines(text : String) -> Array[String] {
  let cs = text.to_array()
  let n = cs.length()
  let out : Array[String] = []
  let mut buf : Array[Char] = []
  let mut skip_ws = true
  let mut appended_begin = false
  let mut preceding_bs = false
  let mut in_comment = false
  let mut i = 0
  while i < n {
    let c = cs[i].to_int()
    if in_comment {
      if c == 0x0a || c == 0x0d {
        in_comment = false
        skip_ws = true
      }
      i = i + eol_len(cs, i, n)
      continue
    }
    if skip_ws {
      if is_ws3(c) {
        i += 1
        continue
      }
      if !appended_begin && (c == 0x0a || c == 0x0d) {
        i = i + eol_len(cs, i, n)
        continue
      }
      skip_ws = false
      appended_begin = false
    }
    if buf.length() == 0 && (c == 0x23 || c == 0x21) {
      in_comment = true
      i += 1
      continue
    }
    if c == 0x0a || c == 0x0d {
      if buf.length() == 0 {
        skip_ws = true
        i = i + eol_len(cs, i, n)
        continue
      }
      if preceding_bs {
        buf = String::from_array(buf[0:buf.length() - 1]).to_array()
        preceding_bs = false
        skip_ws = true
        appended_begin = true
        i = i + eol_len(cs, i, n)
        continue
      }
      out.push(String::from_array(buf))
      buf = []
      preceding_bs = false
      skip_ws = true
      appended_begin = false
      i = i + eol_len(cs, i, n)
      continue
    }
    buf.push(cs[i])
    preceding_bs = if c == 0x5c { !preceding_bs } else { false }
    i += 1
  }
  if buf.length() > 0 {
    if preceding_bs {
      out.push(String::from_array(buf[0:buf.length() - 1]))
    } else {
      out.push(String::from_array(buf))
    }
  }
  out
}

///|
fn is_hex(cp : Int) -> Bool {
  (cp >= 0x30 && cp <= 0x39) ||
  (cp >= 0x61 && cp <= 0x66) ||
  (cp >= 0x41 && cp <= 0x46)
}

///|
fn hex_val(cp : Int) -> Int {
  if cp >= 0x30 && cp <= 0x39 {
    cp - 0x30
  } else if cp >= 0x61 && cp <= 0x66 {
    cp - 0x61 + 10
  } else {
    cp - 0x41 + 10
  }
}

///|
fn ff_char() -> Char {
  let v : Int = 12
  v.unsafe_to_char()
}

///|
// 参照 `loadConvert`：`\t\n\f\r` 各还原、`uXXXX` 解码（畸形 ⇒ raise）、其余转义直接取下一字符
fn load_convert(seg : String) -> Result[String, PropsError] {
  let cs = seg.to_array()
  let n = cs.length()
  let out : Array[Char] = []
  let mut i = 0
  while i < n {
    let c = cs[i].to_int()
    if c != 0x5c {
      out.push(cs[i])
      i += 1
    } else if i + 1 >= n {
      out.push(cs[i])
      i += 1
    } else {
      let d = cs[i + 1].to_int()
      if d == 0x74 {
        out.push('\t')
        i += 2
      } else if d == 0x6e {
        out.push('\n')
        i += 2
      } else if d == 0x66 {
        out.push(ff_char())
        i += 2
      } else if d == 0x72 {
        out.push('\r')
        i += 2
      } else if d == 0x5c {
        out.push('\\')
        i += 2
      } else if d == 0x75 {
        if i + 6 > n {
          return Err(BadUnicodeEscape)
        }
        let mut v = 0
        let mut q = i + 2
        let mut bad = false
        while q < i + 6 {
          if !is_hex(cs[q].to_int()) {
            bad = true
            q = i + 6
          } else {
            v = v * 16 + hex_val(cs[q].to_int())
            q += 1
          }
        }
        if bad {
          return Err(BadUnicodeEscape)
        }
        out.push(v.unsafe_to_char())
        i += 6
      } else {
        out.push(cs[i + 1])
        i += 2
      }
    }
  }
  Ok(String::from_array(out))
}

///|
// 参照 `load0` 的两段循环：键扫到第一个未转义的 `=`/`:`/空白，再从 valueStart 吸收空白并认分隔符
fn split_kv(line : String) -> (String, String) {
  let cs = line.to_array()
  let n = cs.length()
  let mut key_len = 0
  let mut value_start = n
  let mut has_sep = false
  let mut preceding_bs = false
  let mut found = false
  while key_len < n && !found {
    let c = cs[key_len].to_int()
    if (c == 0x3d || c == 0x3a) && !preceding_bs {
      value_start = key_len + 1
      has_sep = true
      found = true
    } else if is_ws3(c) && !preceding_bs {
      value_start = key_len + 1
      found = true
    } else {
      preceding_bs = if c == 0x5c { !preceding_bs } else { false }
      key_len += 1
    }
  }
  let mut vs = value_start
  let mut stop = false
  while vs < n && !stop {
    let c = cs[vs].to_int()
    if is_ws3(c) {
      vs += 1
    } else if !has_sep && (c == 0x3d || c == 0x3a) {
      has_sep = true
      vs += 1
    } else {
      stop = true
    }
  }
  (String::from_array(cs[0:key_len]), String::from_array(cs[vs:n]))
}

///|
/// #22.28 空表
/// - Raises: 无
/// - Note: hutool 对位 `Props.create()`（转手 `new Properties()` 的形状）
pub fn props_new() -> Props {
  Props::{ order: [], values: [], }
}

///|
fn find_pair(p : Props, key : String) -> Int {
  let n = p.order.length()
  let mut i = 0
  let mut hit = -1
  while i < n {
    if p.order[i] == key {
      hit = i
      i = n
    } else {
      i += 1
    }
  }
  hit
}

///|
fn put_pair(p : Props, key : String, value : String) -> String? {
  let hit = find_pair(p, key)
  if hit < 0 {
    p.order.push(key)
    p.values.push(value)
    None
  } else {
    let old = p.values[hit]
    p.values[hit] = value
    Some(old)
  }
}

///|
/// #22.29 严格按 `java.util.Properties.load` 解析
/// - Raises: `PropsError::BadUnicodeEscape`——畸形 `\u` 序列（参照在这一档抛 `IllegalArgumentException`）
/// - Note: hutool 对位 `Props` 转手的 `super.load(reader)`
pub fn props_parse(text : String) -> Props raise PropsError {
  let p = props_new()
  for line in logical_lines(text) {
    let kv = split_kv(line)
    let key = match load_convert(kv.0) {
      Ok(v) => v
      Err(e) => raise e
    }
    let value = match load_convert(kv.1) {
      Ok(v) => v
      Err(e) => raise e
    }
    let _ = put_pair(p, key, value)
  }
  p
}

///|
/// #22.30 取值
/// - Raises: 无
/// - Note: hutool 对位 `Properties.getProperty(String)`
pub fn props_get(p : Props, key : String) -> String? {
  let i = find_pair(p, key)
  if i < 0 {
    None
  } else {
    Some(p.values[i])
  }
}

///|
/// #22.31 取值带缺省
/// - Raises: 无
/// - Note: hutool 对位 `Properties.getProperty(String key, String defaultValue)`
pub fn props_get_or(p : Props, key : String, default : String) -> String {
  match props_get(p, key) {
    None => default
    Some(v) => v
  }
}

///|
/// #22.32 写一条，返回旧值
/// - Raises: 无
/// - Note: hutool 对位 `Object setProperty(String key, String value)` 的返回值
pub fn props_set(p : Props, key : String, value : String) -> String? {
  put_pair(p, key, value)
}

///|
/// #22.33 删一条，返回被删的值
/// - Raises: 无
/// - Note: hutool 对位 `Object remove(Object key)`
pub fn props_remove(p : Props, key : String) -> String? {
  let i = find_pair(p, key)
  if i < 0 {
    None
  } else {
    let old = p.values[i]
    let no : Array[String] = []
    let nv : Array[String] = []
    let n = p.order.length()
    let mut q = 0
    while q < n {
      if q != i {
        no.push(p.order[q])
        nv.push(p.values[q])
      }
      q += 1
    }
    p.order = no
    p.values = nv
    Some(old)
  }
}

///|
/// #22.34 是否含该键
/// - Raises: 无
/// - Note: hutool 对位 `boolean containsKey(Object key)`
pub fn props_has_key(p : Props, key : String) -> Bool {
  find_pair(p, key) >= 0
}

///|
/// #22.35 条数
/// - Raises: 无
/// - Note: hutool 对位 `int size()`（参照无缓存，本库也无）
pub fn props_size(p : Props) -> Int {
  p.order.length()
}

///|
/// #22.36 是否空表
/// - Raises: 无
/// - Note: hutool 对位 `boolean isEmpty()`
pub fn props_is_empty(p : Props) -> Bool {
  p.order.length() == 0
}

///|
/// #22.37 键列表（本库自定的首次出现序）
/// - Raises: 无
/// - Note: hutool 对位 `Set<String> stringPropertyNames()`（参照无序）
pub fn props_keys(p : Props) -> Array[String] {
  p.order.copy()
}

///|
/// #22.38 值列表（与 #22.37 同序）
/// - Raises: 无
/// - Note: hutool 对位 `Collection<Object> values()` 的 String 档
pub fn props_values(p : Props) -> Array[String] {
  p.values.copy()
}

///|
/// #22.39 条目列表（与 #22.37 同序）
/// - Raises: 无
/// - Note: hutool 对位 `entrySet()` 的 String 档
pub fn props_entries(p : Props) -> Array[(String, String)] {
  let out : Array[(String, String)] = []
  let mut i = 0
  while i < p.order.length() {
    out.push((p.order[i], p.values[i]))
    i += 1
  }
  out
}

///|
// 参照 JDK 17 `saveConvert`：`62 < ch < 127` 原样、`\` 出两写、空格只在串首或键侧加反斜杠、
// `\t\n\r\f` 出字母转义、`=` `:` `#` `!` 四个字符键侧与值侧都加反斜杠、
// 其余一律原样（`escapeUnicode = false` ⇒ 中文与 BMP 外字符不写 `\uXXXX`——
// 腿的 `p.value_unicode_esc.store` 与 `p.value_astral.store` 就是这一条的判据）
fn bs_char() -> Char {
  let v : Int = 92
  v.unsafe_to_char()
}

///|
fn save_convert(s : String, is_key : Bool) -> String {
  let bs = bs_char()
  let cs = s.to_array()
  let n = cs.length()
  let out : Array[Char] = []
  let mut x = 0
  while x < n {
    let cp = cs[x].to_int()
    if cp == 0x5c {
      out.push(bs)
      out.push(bs)
    } else if cp > 61 && cp < 127 {
      out.push(cs[x])
    } else if cp == 0x20 {
      if x == 0 || is_key {
        out.push(bs)
      }
      out.push(' ')
    } else if cp == 0x09 {
      out.push(bs)
      out.push('t')
    } else if cp == 0x0a {
      out.push(bs)
      out.push('n')
    } else if cp == 0x0c {
      out.push(bs)
      out.push('f')
    } else if cp == 0x0d {
      out.push(bs)
      out.push('r')
    } else if cp == 0x3d || cp == 0x3a || cp == 0x23 || cp == 0x21 {
      out.push(bs)
      out.push(cs[x])
    } else {
      out.push(cs[x])
    }
    x += 1
  }
  String::from_array(out)
}

///|
/// #22.40 序列化成 `.properties` 文本
/// - Returns: 每条 `键=值` 一行、行分隔符 `\n`、末尾也带换行；不出参照首行的时间戳注释（宿主状态）
/// - Raises: 无
/// - Note: hutool 对位 `Properties.store(Writer, null)` 去掉注释头那一档；写出序是本库的首次出现序（参照无序）
pub fn props_store(p : Props) -> String {
  let mut out = ""
  let mut i = 0
  while i < p.order.length() {
    out = out +
      save_convert(p.order[i], true) +
      "=" +
      save_convert(p.values[i], false) +
      "\n"
    i += 1
  }
  out
}
