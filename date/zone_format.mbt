///|
// moon-hutool/date —— 命名时区版格式化与解析（ROADMAP 第 3 行第四批）
// 契约真相在 `docs/spec/03-date.md` §7。本文件的实现体在 PR-B 落地；现在是契约骨架。

///|
/// 瞬间 + 本包 pattern 子集 + 区名 → 串。
/// - Notes: 两条通道分开判，别混——
///   - 区名不在表里 / 读数在窗口外 ⇒ `None`（与 §5 同形，不跟随参照的静默回落）
///   - pattern 表外 token / 字段越界 ⇒ `raise DateError`（沿用 §2.6~2.7 已冻的那套判据，本件不改它）
/// - Note: hutool 没有 `format(date, pattern, timeZone)` 这个公开重载；对位的是
///   `DateUtil.convertTimeZone(Date, TimeZone)`（javap + 源码现读：内部 `new DateTime(date, tz)`，
///   **瞬间不变、只换显示用的区**）与 `newSimpleFormat(pattern, locale, tz)`（造带区的 formatter）。
///   本库 `DateTime` 不携带区字段，所以把"显示用的区"做成入参、出口直接给串。
/// - Note: `Locale` 档不收——本包 pattern 子集里没有 `EEEE`/`MMM`（§3 明写不做），
///   参照的 locale 只影响那两处，换个 locale 在本子集下必然同读数。
pub fn format_in(
  millis : Int64,
  pattern : String,
  zone : String,
) -> String? raise DateError {
  match zone_offset_minutes(zone, millis) {
    None => None
    Some(off) => Some(DateTime::from_epoch_millis(millis, off).format(pattern))
  }
}

///|
/// 串 + pattern + 区名 → 瞬间。
/// - Returns: 区名不在表里 / 落点窗外 ⇒ `None`
/// - Raises:
///   - `DateError` 家族里 pattern/字段那几条：沿用 §2.7 已冻判据，本件不改
///   - **`ZoneGap(String)`（本批新增变体）**——这个墙上时刻在该区**不存在**（前跳空洞）。
///     判据来自参照：`SimpleDateFormat` 在 `setLenient(false)` 下对 `America/New_York|2024-03-10 02:30:00`
///     与 `Asia/Shanghai|1986-05-04 02:30:00` 都是**主动抛** `ParseException`（腿 S 行），
///     按本仓规矩"参照主动抛、带文案的判据 ⇒ 留变体"，不并成 `None`（并了就把"这个时间不存在"
///     和"这个区名我不认"混成同一个读数了）。携带值取那个不存在的墙上时刻的 ISO 串。
/// - Note: 回拨重叠（2 档）在参照取**转换后那一支偏移**，不是先出现的那一支。三个区同证（腿 S 行反推）：
///   `America/New_York|2024-11-03 01:30:00` ⇒ `-300`（不是 `-240`）、`Europe/London|2024-10-27 01:30:00`
///   ⇒ `0`（不是 `60`）、`Australia/Lord_Howe|2024-04-07 02:30:00` ⇒ `630`（不是 `660`，这区 DST 差 30 分）。
///   而 §5 已冻的 `zone_offsets_at_wall` 顺序是"转换前的在前"⇒ 本件取**末支**才接得上参照。
///   这一条本来会想当然写成"取第一支"，是腿把它按住的。
pub fn parse_in(
  text : String,
  pattern : String,
  zone : String,
) -> Int64? raise DateError {
  if !zone_exists(zone) {
    return None
  }
  // 串与 pattern 的判据一律沿用 §2.7 已冻那套，本件不改它
  let wall = DateTime::parse(text, pattern)
  let offs = wall_offsets(zone, wall, true)
  if offs.length() == 0 {
    // 空表有两种成因，出口必须不同：真的不存在（前跳空洞）⇒ 参照在这里主动抛，本库留变体；
    // 只是超出表的覆盖窗口 ⇒ 与 §5 同形给 None（参照那边还能往 1900 前 / 2050 后查，本库不外推）
    if wall_offsets(zone, wall, false).length() == 0 {
      raise ZoneGap(wall.to_iso_string())
    }
    return None
  }
  // 末支 = 转换后那一支：参照 Calendar 在重叠档就是这么取的，三区读数同证（§7.3 第 2 行）
  Some(wall.to_epoch_millis(offs[offs.length() - 1]))
}

///|
/// 瞬间 + 区名 → RFC3339 带偏移串（§2.11 `to_rfc3339(millis, offset)` 的区名版）。
/// - Returns: 区名不在表里 / 窗外 ⇒ `None`
/// - Note: 偏移的数字部分**不自己拼**——腿 R 行给了参照形状：`Asia/Kathmandu` 在 1970 是 `+05:30`、
///   当下是 `+05:45`（同一区两个瞬间不同偏移，正是 §5 那张表必须按瞬间取值的那件事）
pub fn to_rfc3339_in(millis : Int64, zone : String) -> String? {
  match zone_offset_minutes(zone, millis) {
    None => None
    Some(off) => Some(to_rfc3339(millis, off))
  }
}
