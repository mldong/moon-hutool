// moon-hutool/date —— 第五批补档的参照腿（RFC 3339 取值 + pattern 引号档）。
// 参照件归属（现读）：ISO 那一族用 **JDK java.time.OffsetDateTime.parse**（RFC 3339 的严格档），
// 不用 hutool 的 `DateUtil.parse`（那是"猜测式"多格式入口，位置与语义都不是本库这条严格腿的对位物）；
// pattern 那一族用 **java.text.SimpleDateFormat**（本库 pattern 子集的形状来源）。
// 用法：javac -encoding UTF-8 scripts/Iso2Leg.java -d <cls> ; java -cp <cls> Iso2Leg
// 全部 ASCII 输出（本机控制台 GBK）。行形状：
//   I <序号> <输入> <epoch_millis 或 ERR:类名>
//   P <id> <pattern> <格式化读数或 ERR:类名>
import java.text.SimpleDateFormat;
import java.time.OffsetDateTime;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.TimeZone;

public class Iso2Leg {
  static final String[] ISO = {
      "2026-10-07T12:00:00.52+05:30",
      "2026-10-07T12:00:00.123456+00:00",
      "2026-10-07T12:00:00-05:00",
      "2026-10-07T12:00:00Z",
      "2026-10-07T12:00:00.5Z",
      "2026-10-07T12:00:00.+08:00",
      "2026-10-07T12:00:00Zx",
      "2026-10-07T12:00:00X",
      "2026-10-07T12:00-05:00",
      "2026-10-07T12:00:00+24:00",
      "2026-10-07T12:00:00,52+05:30",
      "2026-10-07T12:00:00.523+05:30",
      "2026-10-07T12:00:00+00:00",
  };

  // 固定瞬间：2026-10-07T00:00:00Z（UTC），pattern 都在这一个瞬间上跑
  static final Date D = new GregorianCalendar(TimeZone.getTimeZone("UTC"))
      .getTime();

  public static void main(String[] args) {
    D.setTime(1791331200000L); // 2026-10-07T00:00:00Z 的毫秒
    TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
    String g1 = iso(ISO[3]), g2 = iso(ISO[5]), g3 = iso(ISO[1]);
    System.out.println("G|guard|" + g1 + "|" + g2 + "|" + g3);
    boolean ok = !g1.equals(g2) && !g2.equals(g3) && !g1.equals(g3);
    System.out.println(ok ? "G|GUARD_OK|distinct3" : "G|GUARD_FAIL|same-reading");
    for (int i = 0; i < ISO.length; i++) {
      System.out.println("I|" + i + "|" + ISO[i] + "|" + iso(ISO[i]));
    }
    System.out.println("P|qq|''|" + pat("''"));
    System.out.println("P|qq_lit|'''x'''|" + pat("'x'"));
    System.out.println("P|unclosed|yyyy'|" + pat("yyyy'"));
    System.out.println("P|dup|yyyy-MM-dd-yyyy|" + pat("yyyy-MM-dd-yyyy"));
    System.out.println("P|time_on_date|HH:mm:ss|" + pat("HH:mm:ss"));
  }

  static String iso(String s) {
    try {
      return String.valueOf(OffsetDateTime.parse(s).toInstant().toEpochMilli());
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String pat(String p) {
    try {
      return esc(new SimpleDateFormat(p).format(D));
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String esc(String s) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < s.length(); i++) {
      char c = s.charAt(i);
      if (c >= 0x20 && c <= 0x7e && c != '|') sb.append(c);
      else sb.append(String.format("{u%04x}", (int) c));
    }
    return sb.toString();
  }
}
