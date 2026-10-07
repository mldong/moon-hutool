///|
// moon-hutool/date —— 默认区与无参便捷入口（ROADMAP 第 3 行第五批）
// 契约真相在 `docs/spec/03-date.md` §8。数据表在 §5，本批只做"选哪个区"这一层降级，不加第二套换算判据。

///|
/// 兜底区名：环境变量 `TZ` 没给、或给了但本库内置表不认时，默认区取这个值。
///
/// - Note: 这是**本库自订**的决定，不是参照读数——hutool 没有"读 `TZ` 再降级"这一件，
///   它吃的是 JVM 的 `TimeZone.getDefault()`（进程级、查不到来源、Windows 上还不跟 `TZ`）。
///   判据与代价见 spec §8.3 第 1 行。
/// - Note: 取值必须是 `zone_exists` 认得的区名，这条有独立用例（§8.5 块 1），改它要过门禁。
pub let fallback_zone : String = "Asia/Shanghai"

///|
/// 默认区名是从哪一级降下来的。存在这件的原因：把"隐式全局量"变成**可查询**的东西，
/// 调用方出了意外读数时能一次问出"到底用了哪个区、为什么"，而不用去猜宿主环境。
/// - Note: 本库要交给调用方当参数用，所以写 `pub(all)`——普通 `pub enum` 的变体跨包构造不出来。
pub(all) enum ZoneSource {
  /// 有人调过 `set_default_zone` 且成功，覆盖值生效（优先级最高，压过 `TZ`）
  FromOverride
  /// 环境变量 `TZ` 给了一个内置表认得的区名
  FromEnv
  /// `TZ` 没给，或给了表外值 ⇒ 取 `fallback_zone`
  Fallback
}

///|
// 覆盖槽。本版工具链的顶层 `let mut` 判词法错，可变的全局格子用单元素数组承载（数组是引用语义）。
// 只在本包内出现，不进公开面——读它只能通过 default_zone / default_zone_source 两件。
let override_slot : Array[String?] = [None]

///|
// 三级降级**只有这一处**（§8.2 末行：两件必须同源，一次降级只能有一个出口）。
// 覆盖值 → `TZ`（且必须表内）→ 兜底常量。表外值不收，POSIX 规则串与路径式因此进不来。
fn resolve_default() -> (String, ZoneSource) {
  match override_slot[0] {
    Some(z) => (z, FromOverride)
    None =>
      match @env.get_env_var("TZ") {
        Some(v) if zone_exists(v) => (v, FromEnv)
        _ => (fallback_zone, Fallback)
      }
  }
}

///|
/// 当前生效的默认区名。三级降级：`set_default_zone` 的覆盖值 → 环境变量 `TZ` → `fallback_zone`。
///
/// - Returns: **恒为内置表认得的区名**（`zone_exists` 必给 `true`）。这是这一件的核心承诺：
///   坏的环境变量值不会漏到下游，`now_local` 那批便捷件因此**永远不会因为区名而给 `None`**。
/// - Note: 每次调用现读环境变量，不缓存——实测 `set_env_var` 之后立即读得到新值（三档一致），
///   所以"改环境"这件事在生产与测试里都有确定行为。判据见 spec §8.2 第 1 行。
/// - Note: 不跟随参照的静默回落：JDK 的 `TimeZone.getTimeZone` 对坏名给 GMT=0，本库给 `fallback_zone`。
/// - 示例见 `docs/spec/03-date.md` §8.5。
pub fn default_zone() -> String {
  let (z, _) = resolve_default()
  z
}

///|
/// 当前默认区是从哪一级来的。
/// - Returns: `FromOverride` / `FromEnv` / `Fallback` 之一，与 `default_zone()` 同一次降级结果对应
/// - Note: 两件必须走同一条判据，不许各读一遍环境后给出互相矛盾的一对读数（spec §8.2 第 2 行）
pub fn default_zone_source() -> ZoneSource {
  let (_, s) = resolve_default()
  s
}

///|
/// 显式覆盖默认区，优先级高于 `TZ`。给部署期"我这个进程就要用某个区"这个口。
///
/// - Parameters:
///   - zone: 必须是内置表认得的区名
/// - Returns: `true` = 已生效；`false` = 区名不认，**且当前默认区一律不变**（不留下"设了个坏值"的中间态）
/// - Note: 返回 `Bool` 而不是 `raise`——参照没有对应件，这是本库自订档；新增一个 `DateError` 变体
///   会撞上"设置一次配置"的手感，也会让既有的穷尽 `match` 当场报缺档。取舍见 spec §8.3 第 3 行。
pub fn set_default_zone(zone : String) -> Bool {
  if !zone_exists(zone) {
    false
  } else {
    override_slot[0] = Some(zone)
    true
  }
}

///|
/// 撤销 `set_default_zone` 的覆盖值，回到"`TZ` → `fallback_zone`"那条降级路。
/// - Note: 没有它，覆盖就不可逆——测试现场与多实例场景都需要这个复位口（spec §8.2 第 5 行）
pub fn reset_default_zone() -> Unit {
  override_slot[0] = None
}

///|
/// 默认区下的当前墙上时刻。`now_in(default_zone())` 的薄封装，零新判据。
/// - Returns: 唯一给 `None` 的成因是**瞬间落在内置表的覆盖窗口之外**（2050 年后）；
///   区名那一层已被 `default_zone()` 的"恒在表内"不变式挡掉
/// - Note: 用例只断形状与下界，不断两次读时钟之间的大小关系——计时依赖会在慢机器上假红，
///   这条纪律沿用 §5.5 与第三批 #C 系列（spec §8.4 第 2 行）
pub fn now_local() -> DateTime? {
  now_in(default_zone())
}

///|
/// 默认区下的当前日历日。`today_at(default_zone(), clock_system())` 的薄封装。
/// - Returns: 同 `now_local`，只有窗外给 `None`
pub fn today_local() -> Date? {
  today_at(default_zone(), clock_system())
}

///|
/// 瞬间 + pattern → 默认区下的串。`format_in(millis, pattern, default_zone())` 的薄封装。
///
/// - Parameters:
///   - millis: epoch 毫秒
///   - pattern: 本包 §2.6 那个封闭子集
/// - Returns: 窗外 ⇒ `None`；区名那一层恒有效（见 `default_zone`）
/// - Raises: pattern 表外 token、字段越界 ⇒ `DateError`，沿用 §2.6 已冻判据，本件不改它
pub fn format_local(
  millis : Int64,
  pattern : String,
) -> String? raise DateError {
  format_in(millis, pattern, default_zone())
}

///|
/// 瞬间 → 默认区下的 RFC 3339 带偏移串。`to_rfc3339_in(millis, default_zone())` 的薄封装。
/// - Returns: 窗外 ⇒ `None`
/// - Note: 偏移数字仍由 §5 那张表按**瞬间**取，所以同一区在不同瞬间可以给不同偏移
///   （`Asia/Kathmandu` 在 1970 是 `+05:30`、当下 `+05:45`），这条不是笔误
pub fn to_rfc3339_local(millis : Int64) -> String? {
  to_rfc3339_in(millis, default_zone())
}

///|
/// 串 + pattern → 瞬间，按默认区解释那个墙上时刻。`parse_in(text, pattern, default_zone())` 的薄封装。
///
/// - Returns: 落点在表的覆盖窗口外 ⇒ `None`
/// - Raises:
///   - `ZoneGap(iso)`——该墙上时刻在默认区里不存在（前跳空洞），判据同 §7.3 第 3 行
///   - `DateError` 家族的 pattern/字段档，沿用 §2.7 已冻判据
/// - Note: 回拨重叠档取**转换后那一支**偏移，同 §7.3 第 2 行——这条判据本批原样继承，不重述也不改
pub fn parse_local(text : String, pattern : String) -> Int64? raise DateError {
  parse_in(text, pattern, default_zone())
}
