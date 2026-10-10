///|
// moon-hutool/date —— 时长差说成中文（ROADMAP 第 3 行第六批）
// 契约真相在 `docs/spec/03-date.md` §9.5；读数来源 `scripts/TimerLeg3.java` 的 `FB` 行（23 档 × 五档并排）。
//
// 这一件是 `GroupTimeInterval::interval_pretty` 的唯一依赖，先现读了挂载点才敢定形状：
// 参照 `DateUtil.formatBetween(long)` 内部是 `new BetweenFormatter(ms, Level.MILLISECOND).format()`
// ——**一参版传的档位是 MILLISECOND 而不是 DAY**（字节码现读；腿 `FB` 行里 `3600000` 一参给"1小时"、
// `Level.DAY` 那档给"0天"，这就是它的对质）。`BetweenFormatter` 那个类本身的四件旋钮仍挂 gap（spec §9.8 第 1 行）。

///|
/// 时长毫秒数 → 中文时长串（`1天2小时3分钟4秒5毫秒` 那种，档与档之间没有分隔符）
///
/// 三条判据（每条都有腿读数兜着，写在 spec §9.5）：
/// 1. `millis <= 0` 一律 `0毫秒`——参照字节码第一行就是 `betweenMs > 0` 的总闸，
///    负数**不是**带符号时长、也不是取绝对值（腿 `FB|-1`、`FB|-1000`、`FB|-86400000` 三条同读数）；
/// 2. 零值档整段跳过，最后一个非零档之后不补零；一个都没进去 ⇒ 补 `0` + 档名
///    （`604801000` ⇒ `7天1秒`，中间的 0 小时 0 分不出现；`3600001` ⇒ `1小时1毫秒`）；
/// 3. 五档是"逐级借位"不是"取模"，两次运算都向零截断，天那一档必须是 `Int64`
///    （`9223372036854775807` ⇒ `106751991167天7小时12分55秒807毫秒`，腿 `FB` 行原样）。
///
/// - Note: 参照还有 `formatBetween(Date, Date)` 与带 `Level` 的两档，本库**不收**（spec §9.8 第 2 行）：
///   两个瞬间的差由 §2.9 的 `between`/`difference` 出数值，要串就在外面套这一件。
/// - 示例见 `date/README.mbt.md` 的「时长说成人话」一节。
pub fn format_between(millis : Int64) -> String {
  let _ = millis
  abort("PR-B：契约骨架，docs/spec/03-date.md §9.5 与腿 FB 行 23 档")
}
