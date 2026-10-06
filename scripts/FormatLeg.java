// moon-hutool/date —— 第四批（命名时区版格式化与解析）的参照腿
//
// 参照件归属（javap 现读 hutool-core 5.8.35）：
//   DateUtil 里吃 TimeZone/ZoneId 的公开件只有三件——
//     convertTimeZone(Date, ZoneId) / convertTimeZone(Date, TimeZone) → 都是 new DateTime(date, tz)，
//       瞬间不变、只换"显示用的区"；newSimpleFormat(String, Locale, TimeZone) → 造一个带区的 formatter。
//   LocalDateTimeUtil.of(long|Instant, ZoneId|TimeZone) → 瞬间到墙上（date 包 §5 的 datetime_in 已收）。
//   参照**没有** format(date, pattern, timeZone) 这个公开重载，也没有带区名的 parse ⇒
//   本批的 parse_in 属"本库新增档"，取值判据一律照 JDK 现读，spec §7.3 写明哪条是读数、哪条是决定。
//
// 用法：javac -encoding UTF-8 scripts/FormatLeg.java -d <cls> ; java -cp <cls> FormatLeg > format_leg.tsv
// 全部 ASCII 输出（本机控制台是 GBK，非 ASCII 读数一律走 esc()）。
//
// 行形状（最后一列一律"本库分钟粒度口径"的读数，与倒数第二列的参照原样成对给出）：
//   B <key> <value>                       代次与自证计数
//   F <zone> <epoch_sec> <pid> <参照串> <本库分钟粒度串>
//   G <zone> <epoch_sec> <pid> <参照串> <本库分钟粒度串>
//   R <zone> <epoch_sec> <参照串> <本库分钟粒度串>
//   S <zone> <wall> <pid> <epoch_millis|ERR_*> <合法偏移支数|NA>
//   X <zone> <from_sec> <to_sec> <参照秒偏移> <本库分钟偏移>   非整分钟档点名
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.zone.ZoneRules;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

public class FormatLeg {
  // 本包 pattern 子集里真存在的两条（spec §2.6~2.7）。
  // 中文式 pattern（yyyy年MM月dd日）不进本腿：本格只测"区名接缝"，pattern 引擎（§2.6~2.7）与
  // 区名换算（§5）两条都已各自冻过，再组合测的还是那两条；顺带避开本机 GBK 管道串形。
  static final String[] PATTERNS = {
      "yyyy-MM-dd HH:mm:ss",       // 0
      "yyyy-MM-dd'T'HH:mm:ss.SSS", // 1
  };
  static final String RFC = "yyyy-MM-dd'T'HH:mm:ssXXX";

  static final long LO = Instant.parse("1970-01-01T00:00:00Z").getEpochSecond();
  static final long HI = Instant.parse("2050-01-01T00:00:00Z").getEpochSecond();

  static String esc(String v) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < v.length(); i++) {
      char c = v.charAt(i);
      if (c >= 32 && c < 127 && c != '\\' && c != '"') {
        sb.append(c);
      } else if (c == '\\') {
        sb.append("\\\\");
      } else if (c == '"') {
        sb.append("\\\"");
      } else {
        sb.append(String.format("\\u%04x", (int) c));
      }
    }
    return sb.toString();
  }

  static String render(String pattern, long millis, TimeZone tz) {
    SimpleDateFormat sf = new SimpleDateFormat(pattern, java.util.Locale.ENGLISH);
    sf.setTimeZone(tz);
    sf.setLenient(false);
    return esc(sf.format(new Date(millis)));
  }

  /** 参照原样：区名走 TimeZone.getTimeZone（与 hutool 那条路一致，含坏名静默回落 GMT） */
  static String ref(String pattern, long epochSec, String zone) {
    return render(pattern, epochSec * 1000L, TimeZone.getTimeZone(zone));
  }

  /**
   * 本库口径：表里的偏移是**整分钟**（§2 的 DateTime 没有秒级偏移字段），
   * 所以用"参照的秒偏移 ÷ 60"再挂一个 GMT±分 的 TimeZone 渲染——同样是机器读数，不手算。
   */
  static String ours(String pattern, long epochSec, String zone) {
    int m = offSeconds(ZoneId.of(zone), epochSec) / 60;
    int sign = m < 0 ? -1 : 1;
    int abs = Math.abs(m);
    String id = String.format("GMT%s%02d:%02d", sign < 0 ? "-" : "+", abs / 60, abs % 60);
    return render(pattern, epochSec * 1000L, TimeZone.getTimeZone(id));
  }

  static int offSeconds(ZoneId z, long epochSec) {
    return z.getRules().getOffset(Instant.ofEpochSecond(epochSec)).getTotalSeconds();
  }

  /** 抛错成因：合法偏移支数（0=空洞、1、2=重叠）；串本身解析不出来 = NA */
  static String validCount(String zone, String wall) {
    try {
      return String.valueOf(ZoneId.of(zone).getRules()
          .getValidOffsets(LocalDateTime.parse(wall.replace(' ', 'T'))).size());
    } catch (Exception e) {
      return "NA";
    }
  }

  public static void main(String[] a) {
    List<String> ids = new ArrayList<>(ZoneId.getAvailableZoneIds());
    Collections.sort(ids);
    System.out.println("B\tJAVA_VERSION\t" + System.getProperty("java.version"));
    System.out.println("B\tTZDB_DAT_BYTES\t" + new java.io.File(
        System.getProperty("java.home"), "lib/tzdb.dat").length());
    System.out.println("B\tZONES\t" + ids.size());
    System.out.println("B\tLOCALE\tENGLISH");
    System.out.println("B\tWINDOW_LO\t" + LO);
    System.out.println("B\tWINDOW_HI\t" + HI);

    long[] two = { LO, Instant.parse("2026-10-06T00:00:00Z").getEpochSecond() };

    // 非整分钟档点名（决定"参照串 vs 本库分钟串"会不会分叉）
    for (String z : ids) {
      ZoneRules r = ZoneId.of(z).getRules();
      long from = -1, prev = 0;
      for (long t = LO; t < HI; t += 3600) {
        int s = offSeconds(ZoneId.of(z), t);
        if (s % 60 != 0) {
          if (from < 0) from = t;
          prev = s;
        } else if (from >= 0) {
          System.out.println("X\t" + z + "\t" + from + "\t" + t + "\t" + prev + "\t" + (prev / 60));
          from = -1;
        }
      }
      if (from >= 0) {
        System.out.println("X\t" + z + "\t" + from + "\t" + HI + "\t" + prev + "\t" + (prev / 60));
      }
    }

    // F：全表逐区两瞬间 × pattern 0。自证（阳性对照）：参照那条读数另走一条独立 JDK 路径
    // （LocalDateTime.ofInstant 手摆格式）逐字符比对；不等就说明 SimpleDateFormat 做了看不见的事。
    long selfBad = 0;
    for (String z : ids) {
      for (long s : two) {
        String got = ref(PATTERNS[0], s, z);
        LocalDateTime ldt = LocalDateTime.ofInstant(Instant.ofEpochSecond(s), ZoneId.of(z));
        String indep = String.format("%04d-%02d-%02d %02d:%02d:%02d", ldt.getYear(),
            ldt.getMonthValue(), ldt.getDayOfMonth(), ldt.getHour(), ldt.getMinute(),
            ldt.getSecond());
        if (!got.equals(esc(indep))) selfBad++;
        System.out.println("F\t" + z + "\t" + s + "\t0\t" + got + "\t" + ours(PATTERNS[0], s, z));
      }
    }
    System.out.println("B\tSELFCHK_BAD\t" + selfBad);

    // G：特殊档那一小组 × 六瞬间 × 两条 pattern（45 分偏移 / 30 分 DST / 东西半球 / 符号陷阱 / 窗口末）
    String[] special = { "UTC", "Asia/Shanghai", "Asia/Kathmandu", "Pacific/Chatham",
        "Australia/Lord_Howe", "America/New_York", "Europe/London", "Etc/GMT+5",
        "Asia/Taipei", "America/Santiago", "Australia/Sydney", "Africa/Ceuta",
        "Africa/Monrovia" };
    long[] probes = { LO,
        Instant.parse("1986-05-04T02:00:00Z").getEpochSecond(),
        Instant.parse("2000-06-15T12:00:00Z").getEpochSecond(),
        Instant.parse("2024-03-10T06:30:00Z").getEpochSecond(),
        Instant.parse("2024-11-03T06:00:00Z").getEpochSecond(),
        HI - 2 };
    for (String z : special) {
      for (long p : probes) {
        for (int pid = 0; pid < PATTERNS.length; pid++) {
          System.out.println("G\t" + z + "\t" + p + "\t" + pid + "\t"
              + ref(PATTERNS[pid], p, z) + "\t" + ours(PATTERNS[pid], p, z));
        }
      }
    }

    // R：RFC3339 出口。参照的 XXX 档给偏移串，本库分钟档同出一条，两栏差就是秒偏移那部分的可见化
    for (String z : special) {
      for (long p : two) {
        System.out.println("R\t" + z + "\t" + p + "\t" + ref(RFC, p, z) + "\t" + ours(RFC, p, z));
      }
    }

    // S：解析读数——1 档 / 2 档（重叠）/ 0 档（空洞）/ 坏区名各落到哪个瞬间；末列给抛错成因
    String[][] walls = {
        { "America/New_York", "2024-11-03 01:30:00", "0" },     // 重叠
        { "America/New_York", "2024-03-10 02:30:00", "0" },     // 空洞
        { "Asia/Shanghai", "1986-05-04 02:30:00", "0" },        // 中国 1986 那次前跳
        { "Asia/Shanghai", "1986-05-04 02:00:00", "0" },        // 跳变点整点本身
        { "Europe/London", "2024-10-27 01:30:00", "0" },        // 重叠
        { "Pacific/Chatham", "2024-04-07 00:15:00", "0" },      // 45 分偏移那族
        { "Australia/Lord_Howe", "2024-04-07 02:30:00", "0" },  // DST 只差 30 分
        { "UTC", "2024-06-01 12:00:00", "0" },
        { "Asia/Kathmandu", "2024-06-01 12:00:00", "0" },       // +05:45
        { "Etc/GMT+5", "2024-06-01 12:00:00", "0" },            // 符号陷阱
        { "America/New_York", "2024-13-45 99:99:99", "0" },     // 字段本身非法（判据归 §2.7）
        { "America/New_York", "2024-06-01", "1" },              // pattern 不匹配整串（同上）
        { "No/Where", "2024-06-01 12:00:00", "0" },             // 坏区名：参照静默回落 GMT
    };
    for (String[] w : walls) {
      String got;
      try {
        SimpleDateFormat sf = new SimpleDateFormat(PATTERNS[Integer.parseInt(w[2])],
            java.util.Locale.ENGLISH);
        sf.setTimeZone(TimeZone.getTimeZone(w[0]));
        sf.setLenient(false);
        got = String.valueOf(sf.parse(w[1]).getTime());
      } catch (Exception e) {
        got = "ERR_" + e.getClass().getSimpleName();
      }
      System.out.println("S\t" + w[0] + "\t" + w[1] + "\t" + w[2] + "\t" + got + "\t"
          + validCount(w[0], w[1]));
    }
  }
}
