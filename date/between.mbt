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
  if millis <= 0L {
    // 参照字节码第一行就是 `betweenMs > 0` 的总闸：负数与 0 都整段跳过，落到"补 0 + 档名"
    return "0毫秒"
  }
  // 逐级借位（参照全是"除后减掉高位累计"，不是取模），两次运算都向零截断
  let days = millis / 86400000L
  let hours = millis / 3600000L - days * 24L
  let minutes = millis / 60000L - days * 1440L - hours * 60L
  let total_secs = ((days * 24L + hours) * 60L + minutes) * 60L
  let seconds = millis / 1000L - total_secs
  let rest = millis - (total_secs + seconds) * 1000L
  let b : Array[String] = []
  if days > 0L {
    b.push(days.to_string() + "天")
  }
  if hours > 0L {
    b.push(hours.to_string() + "小时")
  }
  if minutes > 0L {
    b.push(minutes.to_string() + "分")
  }
  if seconds > 0L {
    b.push(seconds.to_string() + "秒")
  }
  if rest > 0L {
    b.push(rest.to_string() + "毫秒")
  }
  // 一个都没进去 ⇒ 参照补的是 `0` + **当档档名**；本库这条只有 MILLISECOND 一档（spec §9.5）
  if b.length() == 0 {
    "0毫秒"
  } else {
    b.join("")
  }
}
