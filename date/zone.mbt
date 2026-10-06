///|
// moon-hutool/date —— 内置 IANA 时区表与命名时区入口（ROADMAP 第 3 行第二批）
// 契约真相在 `docs/spec/03-date.md` §5。数据在 `date/zone_table.mbt`（生成件，勿手改）。
// 本文件的实现体在 PR-B 落地；现在是契约骨架。

///|
/// 内置表里有多少个区名（参照代次的全部 IANA id，含 legacy link 与 `Etc/*`）。
/// - Returns: 条数，与腿的 `B ZONES` 读数同值
pub fn zone_count() -> Int {
  abort(
    "moon-hutool PR-B：契约骨架 —— 条数直接取表的区名条目数",
  )
}

///|
/// 区名清单（**返回拷贝**：改它不影响后续查表）。
/// - Returns: 按逐字节字典序排列的区名，顺序与表内二分区间一致
pub fn zone_names() -> Array[String] {
  abort(
    "moon-hutool PR-B：契约骨架 —— 拷贝 zone_names 返回，别把内部表交出去",
  )
}

///|
/// 这个区名在不在表里。
/// - Note: 大小写敏感、不认缩写 —— 参照侧 `TimeZone.getTimeZone(坏名)` 是**静默回落 GMT**，
///   本库不跟随（spec §5.3 分岔第 1 条），坏名在这里给 `false`
pub fn zone_exists(zone : String) -> Bool {
  abort(
    "moon-hutool PR-B：契约骨架 —— 走与 zone_offset_minutes 同一条二分，别摆第二套查找",
  )
}

///|
/// 瞬间 → 该区的偏移（分钟）。窗口 `[zone_window_lo, zone_window_hi)` 之外一律 `None`，**不向外推**。
/// - Notes:
///   - 一个瞬间在一个区里恒对应**唯一**偏移 ⇒ 这一件是全函数（除坏名/窗外）
///   - 非整点偏移真实存在（`Asia/Kathmandu` = 345、`Pacific/Chatham` = 765/825）
///   - `Etc/GMT+5` 的读数腿给 **-300**：Etc 那一族的符号与直觉相反，照搬不修
/// - Returns: 未知区名或窗外 ⇒ `None`
pub fn zone_offset_minutes(zone : String, millis : Int64) -> Int? {
  abort(
    "moon-hutool PR-B：契约骨架 —— 区名二分 + 段起点二分，两处都不能用 core 的 String.compare",
  )
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
  abort(
    "moon-hutool PR-B：契约骨架 —— 逐段候选：instant = wall - off_i，落在第 i 段才算合法",
  )
}

///|
/// 瞬间 + 区名 → 墙上时刻（纯函数，不读时钟）。
/// - Returns: 坏名/窗外 ⇒ `None`；否则 `DateTime::from_epoch_millis(millis, 表内偏移)`
pub fn datetime_in(zone : String, millis : Int64) -> DateTime? {
  abort(
    "moon-hutool PR-B：契约骨架 —— 复用 zone_offset_minutes，别再算一次偏移",
  )
}

///|
/// 当前墙上时刻（读一次时钟 + 查一次表）。这是本包**第二个**读时钟的入口，与 `now(offset)` 同纪律：
/// 只承诺形状与下界，两次读数的抖动不进断言（spec §5.5）。
/// - Returns: 坏名 ⇒ `None`
pub fn now_in(zone : String) -> DateTime? {
  abort(
    "moon-hutool PR-B：契约骨架 —— now_millis() 一次读数交给 datetime_in",
  )
}
