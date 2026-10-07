// moon-hutool/cron —— 第四批补档的参照腿（别名两档、负步进回绕、列表内通配、零填充步进、
// 三类语法错、BadAlias 三档、空数组、年列表排序、`|` 多子表达式、count 非正与区窗两档）。
// 行形状沿用 Cron3Leg.java 的约定，生成器不用另抄夹具表：
//   G|<key>|<value>                     守卫自检：三档出口必须互不相同（防空转）
//   C|<id>|<pattern>|<RET|ERR:类名>|<toString 或 ->   new CronPattern（解析档）
//   M|<id>|<pattern>|<zone>|<start>|<end>|<count>|<exact>|<RET|ERR:类名>|<ms;ms;... 或 ->   matchedDates
//   N|<id>|<pattern>|<base>|<RET|ERR:类名>|<ms|->|<ISO|->    CronPatternUtil.nextDateAfter
//   N2|<id>|<pattern>|<base>|<RET|ERR:类名>|<ms|->|<ISO|->   CronPattern.nextMatch
// 全部 ASCII 输出（本机控制台 GBK）。每条先 TimeZone.setDefault(区)，不读宿主的默认区。
import cn.hutool.cron.pattern.CronPattern;
import cn.hutool.cron.pattern.CronPatternUtil;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

public class Cron4Leg {
  // {id, pattern, zone, start, end, count, exact}
  static String[][] CASES = {
    // —— 别名两档：月 MAY（cron.mbt:339）与周 WED（:357）
    {"al-may", "0 12 ? MAY *", "UTC", "1714521600000", "1715126400000", "10", "true"},
    {"al-may-num", "0 12 ? 5 *", "UTC", "1714521600000", "1715126400000", "10", "true"},
    {"al-may-mixed", "0 12 ? May *", "UTC", "1714521600000", "1715126400000", "10", "true"},
    {"al-wed", "0 12 * * WED", "UTC", "1714521600000", "1715126400000", "10", "true"},
    {"al-wed-num", "0 12 * * 3", "UTC", "1714521600000", "1715126400000", "10", "true"},
    {"al-wed-full", "0 12 * * wednesday", "UTC", "1714521600000", "1715126400000", "10", "true"},
    // —— 负步进回绕（:396，check=false 那一支）与它的对照档 0/58
    {"step-neg1", "0/-1 * * * *", "UTC", "1704067200000", "1704070800000", "60", "true"},
    {"step-58", "0/58 * * * *", "UTC", "1704067200000", "1704070800000", "60", "true"},
    {"step-neg5", "5/-1 * * * *", "UTC", "1704067200000", "1704070800000", "60", "true"},
    // —— 逗号列表里夹通配（:431 step=1 那一支）
    {"star-list", "0,* * * * *", "UTC", "1704067200000", "1704070800000", "60", "true"},
    {"star-list2", "0,? * * * *", "UTC", "1704067200000", "1704070800000", "60", "true"},
    // —— 零填充值 + 步进（:449 长度>2 且无区间符那一支）
    {"pad-step", "000/5 * * * *", "UTC", "1704067200000", "1704070800000", "60", "true"},
    {"plain-step", "0/5 * * * *", "UTC", "1704067200000", "1704070800000", "60", "true"},
    {"pad-step-h", "0 008 * * *", "UTC", "1704067200000", "1704153600000", "60", "true"},
    // —— 三类语法错（:470 三连字符区间、:488 双斜杠）
    {"e-dash3", "1-2-3 * * * *", "UTC", "1704067200000", "1704070800000", "10", "true"},
    {"e-slash3", "1/2/3 * * * *", "UTC", "1704067200000", "1704070800000", "10", "true"},
    // —— BadAlias 三档（:315 只剩符号、:325 溢出）与它的界值对照
    {"e-plus", "+ * * * *", "UTC", "1704067200000", "1704070800000", "10", "true"},
    {"e-minus", "- * * * *", "UTC", "1704067200000", "1704070800000", "10", "true"},
    {"e-over", "999999999 * * * *", "UTC", "1704067200000", "1704070800000", "10", "true"},
    {"e-edge1e8", "100000000 * * * *", "UTC", "1704067200000", "1704070800000", "10", "true"},
    // —— 全空 token ⇒ 零值（:512 BadValue）
    {"e-comma", ", * * * *", "UTC", "1704067200000", "1704070800000", "10", "true"},
    // —— 年列表乱序（:523/:526 插入排序体）
    {"yr-sort", "0 0 12 * * ? 2030,2024", "UTC", "1714521600000", "1715126400000", "10", "true"},
    {"yr-desc", "0 0 12 * * ? 2026,2025,2024", "UTC", "1714521600000", "1715126400000", "10", "true"},
    {"yr-jan", "0 0 12 1 1 ? 2030,2024,2026", "UTC", "1704067200000", "1704672000000", "10", "true"},
    {"yr-asc", "0 0 12 * * ? 2024,2025,2026", "UTC", "1714521600000", "1715126400000", "10", "true"},
    // —— `|` 多子表达式（zone_util:216/218 earliest_of 的循环体）
    {"or-two", "0 12 ? MAY *|0 12 ? 7 *", "UTC", "1719273600000", "1719878400000", "10", "true"},
    {"or-rev", "0 12 ? 7 *|0 12 ? MAY *", "UTC", "1719273600000", "1719878400000", "10", "true"},
    {"or-same", "0 12 ? 5 *|0 12 ? 5 *", "UTC", "1719273600000", "1719878400000", "10", "true"},
    // —— count 非正两档（zone_util:112 Some([])）
    {"cnt-0", "0 12 1 * *", "UTC", "1714521600000", "1715126400000", "0", "true"},
    {"cnt-neg", "0 12 1 * *", "UTC", "1714521600000", "1715126400000", "-1", "true"},
    // —— 区窗两档（zone_util:116 None）：坏区名 与 窗外年份
    {"z-badname", "0 12 1 * *", "Not/AZone", "1714521600000", "1715126400000", "10", "true"},
    {"z-window", "0 0 12 1 1 ? 2099", "UTC", "1704067200000", "1704672000000", "10", "true"},
    // —— 空洞/重叠/淘汰三档（zone_util:293/298/304 与 out.length()>count）
    {"gap-la", "0 30 2 ? 3 *", "America/Los_Angeles", "1710028800000", "1710115200000", "10", "true"},
    {"fold-ny", "0 30 1 ? 11 *", "America/New_York", "1730505600000", "1730592000000", "10", "true"},
    {"fold-syd", "0 30 2 ? 4 *", "Australia/Sydney", "1712448000000", "1712534400000", "10", "true"},
    {"gap-sh86", "0 30 2 ? 5 *", "Asia/Shanghai", "514924800000", "515011200000", "10", "true"},
    {"cnt-cap", "0,15,30,45 * * * *", "UTC", "1704067200000", "1704070800000", "2", "true"},
    {"cnt-cap3", "0,15,30,45 * * * *", "UTC", "1704067200000", "1704070800000", "3", "true"},
    // —— 别名表剩余两档（jun/june 与 thu/thursday）
    {"al-jun", "0 12 ? JUN *", "UTC", "1717171200000", "1717776000000", "10", "true"},
    {"al-jun-num", "0 12 ? 6 *", "UTC", "1717171200000", "1717776000000", "10", "true"},
    {"al-june", "0 12 ? june *", "UTC", "1717171200000", "1717776000000", "10", "true"},
    {"al-thu", "0 12 * * THU", "UTC", "1717171200000", "1717776000000", "10", "true"},
    {"al-thu-num", "0 12 * * 4", "UTC", "1717171200000", "1717776000000", "10", "true"},
    {"al-thu-full", "0 12 * * thursday", "UTC", "1717171200000", "1717776000000", "10", "true"},
    // —— 候选在表窗内、折算后的落点出表窗（zone_util:293）
    {"win-land", "0 20 * * *", "America/New_York", "2524568400000", "2524608000000", "10", "true"},
    // —— 别名表剩余五档月名 + 周六（每月取自己那一周，count=10 收得下）
    {"al-aug", "0 12 ? AUG *", "UTC", "1722470400000", "1723075200000", "10", "true"},
    {"al-aug-num", "0 12 ? 8 *", "UTC", "1722470400000", "1723075200000", "10", "true"},
    {"al-sep", "0 12 ? SEP *", "UTC", "1725148800000", "1725753600000", "10", "true"},
    {"al-sep-num", "0 12 ? 9 *", "UTC", "1725148800000", "1725753600000", "10", "true"},
    {"al-oct", "0 12 ? OCT *", "UTC", "1727740800000", "1728345600000", "10", "true"},
    {"al-oct-num", "0 12 ? 10 *", "UTC", "1727740800000", "1728345600000", "10", "true"},
    {"al-nov", "0 12 ? NOV *", "UTC", "1730419200000", "1731024000000", "10", "true"},
    {"al-nov-num", "0 12 ? 11 *", "UTC", "1730419200000", "1731024000000", "10", "true"},
    {"al-dec", "0 12 ? DEC *", "UTC", "1733011200000", "1733616000000", "10", "true"},
    {"al-dec-num", "0 12 ? 12 *", "UTC", "1733011200000", "1733616000000", "10", "true"},
    {"al-sat", "0 12 * * sat", "UTC", "1717171200000", "1717776000000", "10", "true"},
    {"al-sat-num", "0 12 * * 6", "UTC", "1717171200000", "1717776000000", "10", "true"},
    // —— 月名查表的兜底档（既不是整数也不是别名）
    {"e-month-1x", "0 12 ? 1x *", "UTC", "1704067200000", "1704672000000", "10", "true"},
    {"e-week-1x", "0 12 * * 1x", "UTC", "1704067200000", "1704672000000", "10", "true"},
    // —— 别名表最后两档（jul/july 与 fri/friday）
    {"al-jul", "0 12 ? JUL *", "UTC", "1719792000000", "1720396800000", "10", "true"},
    {"al-jul-num", "0 12 ? 7 *", "UTC", "1719792000000", "1720396800000", "10", "true"},
    {"al-july", "0 12 ? july *", "UTC", "1719792000000", "1720396800000", "10", "true"},
    {"al-fri", "0 12 * * FRI", "UTC", "1719792000000", "1720396800000", "10", "true"},
    {"al-fri-num", "0 12 * * 5", "UTC", "1719792000000", "1720396800000", "10", "true"},
    {"al-fri-full", "0 12 * * friday", "UTC", "1719792000000", "1720396800000", "10", "true"},
    // —— 空洞档与落点窗（zone_util:293/298/304）
    {"g-la", "0 30 2 ? 3 *", "America/Los_Angeles", "1709251200000", "1709856000000", "10", "true"},
    {"g-sh", "0 30 2 ? 5 *", "Asia/Shanghai", "514425600000", "515030000000", "10", "true"},
    {"g-ny", "0 30 1 ? 11 *", "America/New_York", "1729900800000", "1730505600000", "10", "true"},
  };

  static String iso(long ms) {
    SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    f.setTimeZone(TimeZone.getTimeZone("UTC"));
    return f.format(new Date(ms));
  }

  static String esc(String s) {
    if (s == null) return "-";
    return s.replace("|", "{bar}").replace(";", "{semi}").replace("\n", " ").replace("\r", " ");
  }

  public static void main(String[] a) {
    // 守卫自检：三档出口互不相同（正常 / 解析错 / 无命中）
    String g1 = one("0 0 12 * * ?", "UTC", 1704067200000L);
    String g2 = one("bad pattern here", "UTC", 1704067200000L);
    String g3 = one("0 0 0 30 2 ?", "UTC", 1704067200000L);
    System.out.println("G|guard_ok|" + g1);
    System.out.println("G|guard_err|" + g2);
    System.out.println("G|guard_no_match|" + g3);
    if (g1.equals(g2) || g1.equals(g3) || g2.equals(g3)) {
      System.out.println("G|GUARD_THROW|exits_not_distinct");
    } else {
      System.out.println("G|GUARD_OK|distinct3");
    }

    for (String[] c : CASES) {
      String id = c[0], pat = c[1], zone = c[2];
      long start = Long.parseLong(c[3]), end = Long.parseLong(c[4]), base = start;
      int count = Integer.parseInt(c[5]);
      boolean exact = Boolean.parseBoolean(c[6]);
      TimeZone tz = TimeZone.getTimeZone(zone);
      TimeZone.setDefault(tz);

      // C：解析档
      String ct;
      try {
        CronPattern p = new CronPattern(pat);
        ct = "RET|" + esc(p.toString());
      } catch (Throwable t) {
        ct = "ERR:" + t.getClass().getSimpleName() + "|" + esc(msg(t));
      }
      System.out.println("C|" + id + "|" + esc(pat) + "|" + ct);

      // M：matchedDates（count 原样传，含 0/-1 两档）
      String mt;
      try {
        CronPattern p = new CronPattern(pat);
        List<Date> got = CronPatternUtil.matchedDates(p, start, end, count, exact);
        StringBuilder sb = new StringBuilder();
        for (Date d : got) {
          if (sb.length() > 0) sb.append(";");
          sb.append(d.getTime());
        }
        mt = "RET|" + (sb.length() == 0 ? "-" : sb.toString()) + "|n=" + got.size();
      } catch (Throwable t) {
        mt = "ERR:" + t.getClass().getSimpleName() + "|" + esc(msg(t)) + "|n=-";
      }
      System.out.println("M|" + id + "|" + esc(pat) + "|" + zone + "|" + start + "|" + end + "|"
          + count + "|" + exact + "|" + mt);

      // N / N2：两个下一瞬间入口
      System.out.println("N|" + id + "|" + esc(pat) + "|" + base + "|" + go(pat, base));
      System.out.println("N2|" + id + "|" + esc(pat) + "|" + base + "|" + go2(pat, base));
    }
  }

  static String msg(Throwable t) {
    String m = t.getMessage();
    return m == null ? "-" : m;
  }

  static String one(String pat, String zone, long base) {
    TimeZone.setDefault(TimeZone.getTimeZone(zone));
    try {
      Date got = CronPatternUtil.nextDateAfter(new CronPattern(pat), new Date(base));
      return got == null ? "RET|-|-" : "RET|" + got.getTime() + "|" + iso(got.getTime());
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName() + "|-|-";
    }
  }

  static String go(String pat, long base) {
    try {
      Date got = CronPatternUtil.nextDateAfter(new CronPattern(pat), new Date(base));
      if (got == null) return "RET|-|-";
      return "RET|" + got.getTime() + "|" + iso(got.getTime());
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName() + "|-|-";
    }
  }

  static String go2(String pat, long base) {
    try {
      CronPattern p = new CronPattern(pat);
      Calendar cal = Calendar.getInstance();
      cal.setTimeInMillis(base);
      Calendar out = p.nextMatch(cal);
      long nxt = out == null ? -1L : out.getTimeInMillis();
      if (nxt <= base) return "RET|-|-";
      return "RET|" + nxt + "|" + iso(nxt);
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName() + "|-|-";
    }
  }
}
