///|
// moon-hutool/date —— 可注入的时钟源（ROADMAP 第 3 行第三批）
// 契约真相在 `docs/spec/03-date.md` §6。本文件的实现体在 PR-B 落地；现在是契约骨架。

///|
/// 真钟：每次调用读一次 OS 时钟（epoch 毫秒）。全库**唯一**读时钟的口，等价于 `now_millis` 的函数值形态。
/// - Note: 参照 `SystemClock.now()` 内部是每 1 ms 刷 `volatile long` 的调度线程，给的是**缓存值**；
///   本库全同步、零 extern，起不了那条线程，也**不承诺**"同一毫秒内恒等读数"（spec §6.5 第 1 条）。
/// - Note: 不给它编任何期望值——判据只有形状级的三条（spec §6.4），断具体时刻就是计时依赖假红。
pub fn clock_system() -> () -> Int64 {
  abort(
    "moon-hutool PR-B：契约骨架 —— 返回 () => now_millis()，别在闭包里缓存",
  )
}

///|
/// 假钟：恒定给同一个读数。给测试与"跨夏令时边界"这类用例用。
/// - Note: 刻意**不校验** `millis` 在不在时区表窗口内——窗外由 `now_at` / `today_at` 那一步给 `None`，
///   假钟只管给数（否则同一个假钟在 UTC 能用、换个区就不能用，读数会随区名变形状）
pub fn clock_fixed(millis : Int64) -> () -> Int64 {
  abort(
    "moon-hutool PR-B：契约骨架 —— 闭包捕获 millis，不许偷偷读真钟",
  )
}

///|
/// 瞬间 + 区名 → **日历日**（纯函数，只要日期那一半）。
/// - Returns: 未知区名或窗外 ⇒ `None`
/// - Note: 与 `datetime_in` 走同一条查表路，只取 `.date`——`today_at` 必须是这一件的薄封装，
///   不能是第二套日历算法（否则"日界"会在两处按不同偏移算，跨夏令时那天正是要害档）
pub fn date_of(zone : String, millis : Int64) -> Date? {
  abort(
    "moon-hutool PR-B：契约骨架 —— 复用 zone_offset_minutes，别摆第二套偏移换算",
  )
}

///|
/// 用**注入的钟**取当前墙上时刻。
/// - Note: 参照 `DateUtil.date()` 吃进程默认时区且没法注入；本库区名必填、钟可换。
///   `now_in(zone)` 保留，重定义成 `now_at(zone, clock_system())`——签名与已冻用例一字不动。
pub fn now_at(zone : String, clock : () -> Int64) -> DateTime? {
  abort(
    "moon-hutool PR-B：契约骨架 —— 读钟一次交给 datetime_in，别再读第二次",
  )
}

///|
/// 用注入的钟取当前**日历日**。
/// - Note: 参照 `DateUtil.today()` 返回 `"yyyy-MM-dd"` **串**且吃默认时区；本库返回 `Date`
///   （要串自己 `.to_iso_string()`），区名必填。
pub fn today_at(zone : String, clock : () -> Int64) -> Date? {
  abort("moon-hutool PR-B：契约骨架 —— 读钟一次交给 date_of")
}
