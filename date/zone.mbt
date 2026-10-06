///|
// moon-hutool/date —— 内置 IANA 时区段表与命名时区入口（ROADMAP 第 3 行第二批）
// 契约真相在 `docs/spec/03-date.md` §5。数据在 `date/zone_table.mbt`（生成件，勿手改）。

///|
/// 区名比较器：**逐码位字典序**，只有前缀关系才由长度定序。
/// 为什么自带：本工具链 core 的 `impl Compare for String` 是**先比长度、再比内容**
/// （`moonbitlang/core/builtin/string.mbt:221`，实测 `"aa" < "b"` 为 `false`），
/// 与 `tbl_names` 的存储序不是同一个序——顺手写 `tbl_names[mid] < zone` 会把所有"长度不同的邻居"查飞。
fn zone_name_cmp(a : String, b : String) -> Int {
  let ua = a.to_array()
  let ub = b.to_array()
  let n = if ua.length() < ub.length() { ua.length() } else { ub.length() }
  let mut i = 0
  let mut r = 0
  while i < n && r == 0 {
    let x = ua[i]
    let y = ub[i]
    if x != y {
      r = if x < y { -1 } else { 1 }
    }
    i = i + 1
  }
  if r != 0 {
    r
  } else if ua.length() == ub.length() {
    0
  } else if ua.length() < ub.length() {
    -1
  } else {
    1
  }
}

///|
/// 区名 → 表内区号。`tbl_names` 升序 + 上面那条比较器 ⇒ 二分成立。
fn zone_find(zone : String) -> Int? {
  let mut lo = 0
  let mut hi = tbl_names.length() - 1
  let mut found = -1
  while lo <= hi && found < 0 {
    let mid = (lo + hi) / 2
    let c = zone_name_cmp(tbl_names[mid], zone)
    if c == 0 {
      found = mid
    } else if c < 0 {
      lo = mid + 1
    } else {
      hi = mid - 1
    }
  }
  if found < 0 {
    None
  } else {
    Some(found)
  }
}

///|
/// 在区号 `zi` 的段序列里找"起点 `<= sec` 的最后一段"，返回**段内下标**；`-1` 表示早于该区首段。
fn seg_last_le(zi : Int, sec : Int64) -> Int {
  let base = tbl_start[zi]
  let mut lo = 0
  let mut hi = tbl_len[zi] - 1
  let mut found = -1
  while lo <= hi {
    let mid = (lo + hi) / 2
    if tbl_seg_start[base + mid] <= sec {
      found = mid
      lo = mid + 1
    } else {
      hi = mid - 1
    }
  }
  found
}

///|
/// 瞬间（毫秒）是否落在窗口 `[tbl_window_lo, tbl_window_hi)` 内。
/// 上界按**毫秒**比：上界那一秒内的任意毫秒仍算窗内。
fn in_window(millis : Int64) -> Bool {
  millis >= tbl_window_lo * 1000L && millis < tbl_window_hi * 1000L
}

///|
/// 内置表里有多少个区名（参照代次的全部 IANA id，含 legacy link 与 `Etc/*`）。
/// - Returns: 条数，与腿的 `B ZONES` 读数同值
pub fn zone_count() -> Int {
  tbl_names.length()
}

///|
/// 区名清单（**返回拷贝**：改它不影响后续查表）。
/// - Returns: 按逐字节字典序排列的区名，顺序与表内二分区间一致
pub fn zone_names() -> Array[String] {
  tbl_names.copy()
}

///|
/// 这个区名在不在表里。
/// - Note: 大小写敏感、不认缩写 —— 参照侧 `TimeZone.getTimeZone(坏名)` 是**静默回落 GMT**，
///   本库不跟随（spec §5.3 分岔第 1 条），坏名在这里给 `false`
pub fn zone_exists(zone : String) -> Bool {
  match zone_find(zone) {
    None => false
    Some(_) => true
  }
}

///|
/// 瞬间 → 该区的偏移（分钟）。窗口 `[zone_window_lo, zone_window_hi)` 之外一律 `None`，**不向外推**。
/// - Notes:
///   - 一个瞬间在一个区里恒对应**唯一**偏移 ⇒ 这一件是全函数（除坏名/窗外）
///   - 非整点偏移真实存在（`Asia/Kathmandu` = 345、`Pacific/Chatham` = 765/825）
///   - `Etc/GMT+5` 的读数腿给 **-300**：Etc 那一族的符号与直觉相反，照搬不修
/// - Returns: 未知区名或窗外 ⇒ `None`
pub fn zone_offset_minutes(zone : String, millis : Int64) -> Int? {
  if !in_window(millis) {
    return None
  }
  let zi = match zone_find(zone) {
    None => return None
    Some(i) => i
  }
  let k = seg_last_le(zi, millis / 1000L)
  if k < 0 {
    None
  } else {
    Some(tbl_seg_off[tbl_start[zi] + k])
  }
}

///|
/// 墙上候选偏移的内部版。`by_window=true` 就是公开件 `zone_offsets_at_wall` 的已冻语义（窗外一律不收）；
/// `by_window=false` 只多给 `parse_in` 用一次：把首段向窗口以前延伸，好把
/// "这个墙上时刻在该区不存在"（真空洞）与"这个时刻超出表的覆盖窗口"两种空表分开——
/// 两者都返回空数组，但不该给同一个出口（§7.3 第 3 行）。
fn wall_offsets(zone : String, wall : DateTime, by_window : Bool) -> Array[Int] {
  let out : Array[Int] = []
  let zi = match zone_find(zone) {
    None => return out
    Some(i) => i
  }
  let base = tbl_start[zi]
  let n = tbl_len[zi]
  // 把墙上时刻当 UTC 折成"名义毫秒"，减掉候选偏移就是候选瞬间；
  // 候选瞬间回落进**同一段**才算合法 —— 空洞档两支都不合法，重叠档两支都合法。
  let nominal = wall.to_epoch_millis(0)
  let mut k = 0
  while k < n {
    let off = tbl_seg_off[base + k]
    let inst = nominal - off.to_int64() * 60000L
    let j = seg_last_le(zi, inst / 1000L)
    // 判据是"候选瞬间落回**自己这一段**"（比段号）。只比偏移值不行：同一偏移在几十年的表里
    // 占几十段，任何一段都能验过同一个瞬间，出来的会是"哪个偏移在表里出现得早"的任意顺序。
    // 按段序（= 时间序）扫，重叠档自然给出"转换前那一支在前"，与参照 getValidOffsets 同序。
    let jj = if j < 0 && !by_window { 0 } else { j }
    if jj == k && !(by_window && !in_window(inst)) {
      out.push(off)
    }
    k = k + 1
  }
  out
}

///|
/// 墙上时刻 → 该区内所有合法偏移（分钟），顺序照参照 `getValidOffsets`。
/// - Notes:
///   - 0 档 = 前跳空洞（`America/New_York|2024-03-10T02:30`、`Asia/Shanghai|1986-05-04T02:30`）
///   - 2 档 = 回拨重叠（`America/New_York|2024-11-03T01:30` ⇒ `-240|-300`）
///   - 1 档 = 平常
///   - 这一件的存在就是"墙上 ↔ 瞬间"在有 DST 的区里**不是一一映射**的正面承认；
///     要唯一瞬间请走显式偏移那条路（`DateTime::to_epoch_millis(offset)`）
pub fn zone_offsets_at_wall(zone : String, wall : DateTime) -> Array[Int] {
  wall_offsets(zone, wall, true)
}

///|
/// 瞬间 + 区名 → 墙上时刻（纯函数，不读时钟）。
/// - Returns: 坏名/窗外 ⇒ `None`；否则 `DateTime::from_epoch_millis(millis, 表内偏移)`
pub fn datetime_in(zone : String, millis : Int64) -> DateTime? {
  match zone_offset_minutes(zone, millis) {
    None => None
    Some(off) => Some(DateTime::from_epoch_millis(millis, off))
  }
}

///|
/// 当前墙上时刻（读一次时钟 + 查一次表）。这是本包**第二个**读时钟的入口，与 `now(offset)` 同纪律：
/// 只承诺形状与下界，两次读数的抖动不进断言（spec §5.5）。
/// - Returns: 坏名 ⇒ `None`
pub fn now_in(zone : String) -> DateTime? {
  now_at(zone, clock_system())
}
