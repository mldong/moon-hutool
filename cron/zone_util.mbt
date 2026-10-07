///|
// moon-hutool/cron —— 第二批之二：带区名的"下一个时刻"与"一批时刻"
// 契约真相在 `docs/spec/19-cron.md` §8~§11。读数标签 `腿 C <家族>.<格>.<基准>.<区>` 指
// `scripts/Cron2Leg.java` 的输出行；期望值由 `scripts/gen_cron2_test.py` 从那些行灌入。
//
// 这一档存在的前提：`date` §5 已经把 603 区 / 36701 段的内置表放进了库里，
// 于是第一批那句"本库不带 tzdb ⇒ 不收毫秒/时区入口"的前提没了（spec §11 第 6 行）。
// 输入是**瞬间**（epoch 毫秒），输出也是**瞬间**——中间那层墙上时刻由区名决定，
// 这正是参照侧靠 `TimeZone.getDefault()` 藏起来、而腿 C 用五个区摊开的那件事。

///|
/// #19.17 严格晚于给定瞬间的下一个匹配瞬间（**带区名版**，与 #19.3 同一条语义）。
/// - Notes:
///   - 区名不在表里 / 基准瞬间在表窗口 `[1970-01-01, 2050-01-01)` 外 ⇒ `None`
///     （与 `date` §5/§7 同一判据，两条通道分开判：坏区名与"窗外"都给 `None`，
///     但"窗内无命中"这一档**不存在**于这一件——它是 `Int64?` 不是数组）
///   - 搜索途中落进窗外 ⇒ `None`，不猜 2050 年之后的偏移。参照在同样的输入上照样给值
///     （`N.year_2099` 五区都给 `4070952000000`＝2099-01-01 12:00 UTC 那一瞬，
///     `N.leap_only` 从 2098 基准给 2104-02-29）⇒ 这是本库的**窗外不承诺**，见 spec §11 第 4 行
/// - Note: "已匹配先 +1 秒"这条从 #19.3 原样带过来（参照为 issue#I9FQUA 明写），
///   在带区版里它多一层可观测后果：**回拨日不给第二支**。
///   基线 `1730611800000`（纽约 2024-11-03 01:30 **EDT**，本身匹配）上
///   `N.daily_0130 → 1730701800000`（直接到 11-04），而 #19.18 在同一格给 `1730615400000`
///   （11-03 01:30 **EST**）——两族必须成对留读数（spec §9 第 15 条）
/// - Note: 重叠档取**转换后那一支**偏移：基线 `1730548800000`（11-03 04:00Z）上
///   `N.daily_0130 纽约 → 1730615400000`（01:30 的 EST 支，不是 EDT 支 `1730611800000`）、
///   `N.daily_0230 纽约 → 1730619000000`。与 `date` §7 `parse_in` 的"取末支"是同一条规矩，
///   **两个独立家族各自证过一次**（spec §9 第 13 条）
/// - Note: 空洞档那堵墙上时刻**整天跳过**，不做"往后挪一小时"的回落：
///   `N.daily_0230 1709985600000 纽约 → 1710138600000`（03-10 02:30 不存在 ⇒ 给 03-11），
///   `N.daily_0230 515505600000 上海 → 515611800000`（1986-05-04 02:30 同形跳过），
///   同档在无 DST 的区正常给（`… UTC → 1710037800000`）（spec §9 第 14 条）
/// - Note: hutool 对位 `CronPatternUtil.nextDateAfter(CronPattern, Date)`（其内部用
///   `Calendar.getInstance(TimeZone.getDefault())`；本库把那个"默认"换成入参）
pub fn cron_next_match_after_in(
  c : Cron,
  zone : String,
  millis : Int64,
) -> Int64? {
  // skip_self=true ⇒ 已匹配先 +1000ms（参照 issue#I9FQUA 那条，与 #19.3 同形）
  znext_in(c, zone, millis, true)
}

///|
/// #19.18 下一个匹配瞬间，但**给定瞬间本身已匹配就返回它**（**带区名版**，与 #19.4 成对）。
/// - Returns: 坏区名 / 基准或落点窗外 ⇒ `None`（判据同 #19.17）
/// - Note: 已匹配时的"返回自身"在带区版里不是平凡的一条：**同一堵墙上时刻可能有两支**。
///   基线 `1730611800000`（纽约 01:30 EDT）上参照给的是 `1730615400000`（同一墙上时刻的 EST 支），
///   即"原地换到转换后那一支"；而基线已经是后一支（`1730615400000`）时它给自身
///   （`N2.daily_0130 → 1730615400000`）。这一对读数是本件最容易想当然的地方
/// - Note: hutool 对位 `CronPattern.nextMatch(Calendar)`（5.8.30 才有的一件）
pub fn cron_next_match_in(c : Cron, zone : String, millis : Int64) -> Int64? {
  znext_in(c, zone, millis, false)
}

///|
/// #19.19 窗口 `[start, end)` 内匹配该表达式的瞬间清单，最多 `count` 条。
/// - Parameters:
///   - `zone`：区名。**必填**——同一段窗口在五个区里给出的瞬间互不相同
///     （`M.daily SEC 6` 五区首条 `1730424600000`/`1730482200000`/`1730439000000`/
///     `1730490300000`/`1730471400000`，spec §9 第 12 条）
///   - `start`/`end`：epoch 毫秒。**起算瞬间含、终止瞬间不含**（`M.dow_mon`：`count=3` 时
///     UTC/纽约只给 2 条，因为 `2024-03-25 00:00` 那一瞬落在窗外；上海/加德满达/洛德豪斯给 3 条，
///     因为它们的"当地周一 00:00"折成 UTC 是 03-24 那一天）
///   - `count`：上限。**`count <= 0` ⇒ `Some([])`**——参照那一档是 add-then-check，
///     `CB.count 0 RET 1`（要 0 条给 1 条）、`CB.count -1 ERR java.lang.IllegalArgumentException|
///     Illegal Capacity: -1`（Java 容器内部件漏到调用方），两个读数互相矛盾，本库取可推导那一侧
///     （spec §11 第 2 行）
///   - `match_second`：秒段是否参与匹配（与 #19.2 同一个开关）。它同时决定**采样步长**：
///     `true` ⇒ 1 秒，`false` ⇒ 60 秒（参照 `DateUnit.SECOND`/`MINUTE`）
/// - Returns:
///   - `None`：坏区名，或窗口与本库时区表窗口 `[1970, 2050)` 有交集外的部分需要越表外推
///   - `Some([])`：区名与窗口都合法，只是没有命中（腿里 `<none>` 的那几格，
///     如 `M.count_more_than_avail` 在 `Asia/Kathmandu`/`Australia/Lord_Howe`）
///   - `Some(升序去重后的瞬间)`
/// - Raises: `BadRange(start, end)` —— `start >= end`。参照主动抛且带文案
///   （`E.start_gt_end`/`E.start_eq_end`：`IllegalArgumentException|Start date is later than end !`），
///   按本仓规矩留变体、不并成空表
/// - Note: **回拨日的两支都收**，这是本件与 #19.17/#19.18 的**形状级差别**：
///   `M.daily SEC 6 America/New_York` 给 6 条，其中 11-03 占两条
///   （`1730611800000` 与 `1730615400000`）。原因在参照自己——`matchedDates` 按步长线性扫**瞬间**，
///   而 `nextDateAfter` 走**字段进位**。本库两条各自跟随自己那一族的读数，不许顺手统一（spec §11 第 3 行）
/// - Note: **不逐秒线性步进**（那是参照的做法，跨一年要跑 ≈3.2×10^7 次，腿里 `M.leap_feb` 那一格
///   实测几秒才出来）。本库的做法：用 #19.4 那台引擎取候选**墙上时刻**，把每个候选按内置表展开成
///   0/1/2 支瞬间（空洞 0 支自然跳过、重叠 2 支都收），再按 `(瞬间 − start) mod 步长 == 0`
///   折回参照的采样栅格、升序去重、截到 `count`。栅格折在**瞬间**上这条不是想当然：
///   `M.every_min SEC 4 Asia/Kathmandu` 的首条是 `1710051300000`（UTC 的 :15，因为 `+05:45`），
///   `M.daily SEC 6 Australia/Lord_Howe` 首条 `1730471400000`（DST 只挪 30 分那一族）
///   ——判据与算法注都在 spec §9 第 17 条、§10
/// - Note: hutool 对位 `CronPatternUtil.matchedDates(CronPattern, long, long, int, boolean)`；
///   参照另有的 4 参档（`end` = 起始日的年底）不收——窗口是调用方决定的，
///   且"年底按哪个区"在带区名版里是第二层语义（spec §8"不收"表）
pub fn cron_matched_dates(
  c : Cron,
  zone : String,
  start : Int64,
  end : Int64,
  count : Int,
  match_second : Bool,
) -> Array[Int64]? raise CronError {
  if start >= end {
    // 参照 `Assert.isTrue(start < end, "Start date is later than end !")` —— 主动抛且带文案，
    // 按本仓规矩留变体、不并成空表（spec §9 第 10 条）
    raise BadRange(start, end)
  }
  if count <= 0 {
    // 参照 add-then-check 给 1 条、负数抛 Java 容器内部件；本库取可推导那一侧（spec §11 第 2 行）
    return Some([])
  }
  // 区名与表窗两条通道：任一头拿不到偏移 ⇒ 整格无读数（不外推，spec §11 第 4 行）
  if !zone_covers(zone, start) || !zone_covers(zone, end) {
    return None
  }
  let stop_at = @date.datetime_in(zone, end - 1L)
  let mut wall = match @date.datetime_in(zone, start) {
    None => return None
    Some(w) => w
  }
  let end_wall = match stop_at {
    None => return None
    Some(w) => w
  }
  let step = if match_second { 1000L } else { 60000L }
  let subs = subs_view(c, match_second)
  let out : Array[Int64] = []
  let mut more = true
  while more {
    let cand = earliest_of(subs, zone_fields(wall, match_second))
    let offs = @date.zone_offsets_at_wall(zone, cand)
    let has = offs.length() > 0
    if has {
      let mut k = 0
      while k < offs.length() {
        let g = grid_up(cand.to_epoch_millis(offs[k]), start, step)
        let in_range = g >= start && g < end && zone_covers(zone, g)
        // 三条各自都要过：在窗内、本库表认得这一瞬、**读回字段仍匹配**。最后一条不是冗余——
        // 栅格折算把候选挪到采样点上，挪完若不再匹配，参照在那一瞬同样不计命中（它的判据
        // 就是 `match(i, …)`）
        let back = @date.datetime_in(zone, g)
        let hit = match back {
          Some(w) => in_range && cron_match(c, w, match_second~)
          None => false
        }
        if hit {
          push_sorted(out, g)
          if out.length() > count {
            // 只留最小的 count 个。后来的墙上时刻更晚，唯一例外是重叠档的第二支会插到前一支
            // 前面（腿 `M.daily` 的纽约那格），所以淘汰的一直是当前最大那个
            let _ = out.pop()
          }
        }
        k += 1
      }
    }
    // 前进：秒参与匹配时按秒走，否则按分钟走（候选的秒位恒 0，不按分钟走会原地打转）
    let unit = if match_second {
      @date.TimeUnit::Second
    } else {
      @date.TimeUnit::Minute
    }
    wall = cand.offset(unit, 1L)
    // 停止：已经攒够且后来的排不进了，或墙上时刻过了窗内最后一瞬。
    // 空洞档（0 支）那一轮不做前一条判定——没有瞬间可比，只靠墙上时刻那条兜住
    let done_enough = has &&
      out.length() == count &&
      cand.to_epoch_millis(offs[0]) >= out[count - 1]
    more = cand <= end_wall && !done_enough
  }
  Some(out)
}

///|
// 本库内置表认不认这一瞬（坏区名或窗外都是 false）——`date` §5 的偏移探头就是这条判据的口
fn zone_covers(zone : String, millis : Int64) -> Bool {
  match @date.zone_offset_minutes(zone, millis) {
    Some(_) => true
    None => false
  }
}

///|
// 秒档不参与匹配时把它换成恒真匹配器——参照 `match(fields, isMatchSecond=false)` 跳过的
// 正是秒匹配器（spec §9 第 17 条）
fn subs_view(c : Cron, match_second : Bool) -> Array[Sub] {
  if match_second {
    c.subs
  } else {
    let out : Array[Sub] = []
    for s in c.subs {
      let ms2 = s.ms.copy()
      ms2[0] = pm_always()
      let one : Sub = { ms: ms2, }
      out.push(one)
    }
    out
  }
}

///|
// 候选墙上时刻的七字段。秒不参与匹配时字段里的秒给 0——`fields_of(_, false)` 给的是 -1 哨兵，
// 那是"放行判定"用的，进位引擎要的是一个真的起点
fn zone_fields(w : @date.DateTime, match_second : Bool) -> Array[Int] {
  let f = fields_of(w, match_second)
  if !match_second {
    f[0] = 0
  }
  f
}

///|
// 参照 `PatternMatcher.nextMatchAfter(int[], zone)`：各子表达式各给一个候选，取最早那个
fn earliest_of(subs : Array[Sub], values : Array[Int]) -> @date.DateTime {
  let mut best = from_values(sub_next_values(subs[0].ms, values))
  let mut k = 1
  while k < subs.length() {
    let cand = from_values(sub_next_values(subs[k].ms, values))
    if cand < best {
      best = cand
    }
    k += 1
  }
  best
}

///|
// 参照 `matchedDates` 的采样栅格：它从 `start` 起每 `step` 毫秒取一瞬，所以命中必须折回
// `start + k*step` 那一列。折在**瞬间**上而不是"墙上秒为 0"——
// 腿 `M.every_min` 在 `Asia/Kathmandu` 的首条是 UTC 的 :15（`+05:45`）就是这条的判据
fn grid_up(ci : Int64, start : Int64, step : Int64) -> Int64 {
  let d = ci - start
  // 向上取整到 step 的整数倍（MoonBit 的整数除法截断，负数那侧要单独摆）
  let k = if d >= 0L { (d + step - 1L) / step } else { d / step }
  start + k * step
}

///|
// 升序插入。只有重叠档那一段会出现"后来者排在前"，其余都是尾插
fn push_sorted(out : Array[Int64], v : Int64) -> Unit {
  let n = out.length()
  let mut i = n
  while i > 0 && out[i - 1] > v {
    i -= 1
  }
  let _ = out.push(v)
  let mut j = n
  while j > i {
    out[j] = out[j - 1]
    j -= 1
  }
  out[i] = v
}

///|
// 带区名的"下一个匹配瞬间"内核：#19.17 与 #19.18 只差 `skip_self` 一值
// （参照那两侧用的是同一台字段进位引擎，区别只在要不要先 +1 秒）
fn znext_in(c : Cron, zone : String, from : Int64, skip_self : Bool) -> Int64? {
  let mut cur = from
  if skip_self {
    let same = match @date.datetime_in(zone, cur) {
      Some(w) => cron_match(c, w, match_second=true)
      None => false
    }
    if same {
      // 参照 issue#I9FQUA：已匹配时先 +1000ms，否则永远停在原地
      cur += 1000L
    }
  }
  let mut wall = match @date.datetime_in(zone, cur) {
    None => return None
    Some(w) => w
  }
  let mut answer : Int64? = None
  let mut done = false
  while !done {
    let cand = cron_next_match(c, wall)
    let offs = @date.zone_offsets_at_wall(zone, cand)
    if !zone_covers(zone, cand.to_epoch_millis(0)) {
      // 候选已经出了本库表窗 `[1970, 2050)` ⇒ 不外推（spec §11 第 4 行）。
      // **这一刀必须排在"空洞档"那条之前**：窗外与空洞在 `zone_offsets_at_wall` 里都是 0 支，
      // 先判 0 支就会把窗外当成空洞，"跳过一天重来"从此无限递推——
      // 本轮实测就是这样挂住的（`0 0 12 * * ? 2099` 从 2024 基准起算）
      answer = None
      done = true
    } else if offs.length() == 0 {
      // 空洞档：这堵墙上时刻在本区不存在 ⇒ 整档跳过，不做"往后挪一小时"的回落。
      // 参照是靠 Calendar 滚出去后读回字段不等，走同一条"次日重来"（腿 N.daily_0230 纽约/上海）
      wall = day_start(cand.date.offset_day(1))
    } else {
      // 重叠档取**末支**=转换后那一支（腿 N 与 N2 两个家族各证一次，spec §9 第 13 条）
      let ms = cand.to_epoch_millis(offs[offs.length() - 1])
      if !zone_covers(zone, ms) {
        // 落点出本库表窗 ⇒ 不外推（spec §11 第 4 行）
        answer = None
        done = true
      } else {
        let ok = match @date.datetime_in(zone, ms) {
          Some(w) => cron_match(c, w, match_second=true)
          None => false
        }
        if ok {
          answer = Some(ms)
          done = true
        } else {
          wall = day_start(cand.date.offset_day(1))
        }
      }
    }
  }
  answer
}
