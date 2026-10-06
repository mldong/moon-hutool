// moon-hutool/date —— 第四批（命名时区版格式化与解析）的参照腿
//
// 参照件归属（javap 现读 hutool-core 5.8.35）：
//   DateUtil 里吃 TimeZone/ZoneId 的公开件只有三件——
//     convertTimeZone(Date, ZoneId) / convertTimeZone(Date, TimeZone) → 都是 new DateTime(date, tz)，
//       瞬间不变、只换"显示用的区"；newSimpleFormat(String, Locale, TimeZone) → 造一个带区的 formatter。
//   LocalDateTimeUtil.of(long|Instant, ZoneId|TimeZone) → 瞬间到墙上（date 包 §5 的 datetime_in 已收）。
//   参照**没有** format(date, pattern, timeZone) 这个公开重载，也没有带区名的 parse ⇒
//   本批的 parse_in 属"本库新增档"，它的 0 档/2 档取值判据一律取 JDK SimpleDateFormat 的现读结果，
//   并在 spec §7.3 里写明"哪一条是读数、哪一条是本库决定"。
//
// 用法：javac -encoding UTF-8 scripts/FormatLeg.java -d <cls> ; java -cp <cls> FormatLeg > format_leg.tsv
// 全部 ASCII 输出（本机控制台是 GBK）。
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

public class FormatLeg {
  // 本包 pattern 子集里真存在的两条（spec §2.6~2.7）。
  // 中文式 pattern（`yyyy年MM月dd日`）不进本腿：本格只测"区名接缝"，而 pattern 引擎（§2.6~2.7）
  // 与区名换算（§5）两条都已各自冻过期望，再组合一次测的还是那两条；且中文读数过 GBK 管道会串形。
  static final String[] PATTERNS = {
      "yyyy-MM-dd HH:mm:ss",       // 0
      "yyyy-MM-dd'T'HH:mm:ss.SSS", // 1
  };

  static long LO = Instant.parse("1970-01-01T00:00:00Z").getEpochSecond();
  static long HI = Instant.parse("2050-01-01T00:00:00Z").getEpochSecond();

  static String fmt(long millis, String pattern, String zone) {
    SimpleDateFormat sf = new SimpleDateFormat(pattern, java.util.Locale.ENGLISH);
    sf.setTimeZone(TimeZone.getTimeZone(zone));
    sf.setLenient(false);
    return sf.format(new Date(millis));
  }

  public static void main(String[] a) {
    List<String> ids = new ArrayList<>(ZoneId.getAvailableZoneIds());
    Collections.sort(ids);
    System.out.println("B\tJAVA_VERSION\t" + System.getProperty("java.version"));
    System.out.println("B\tTZDB_DAT_BYTES\t" + new java.io.File(
        System.getProperty("java.home"), "lib/tzdb.dat").length());
    System.out.println("B\tZONES\t" + ids.size());
    System.out.println("B\tLOCALE\tENGLISH");

    // F：全表逐区两瞬间 × pattern 0（与 §5 的 E 行同底本，多要时分秒）
    //   自证（阳性对照）：同一条读数另走一条独立 JDK 路径（LocalDateTime.ofInstant 手摆格式），
    //   两者必须逐字符相同——不同就说明 SimpleDateFormat 自己做了我们看不见的事（宽松滚动、周纪年等）
    long[] two = { LO, Instant.parse("2026-10-06T00:00:00Z").getEpochSecond() };
    long selfBad = 0;
    for (String z : ids) {
      for (long s : two) {
        String got = fmt(s * 1000L, PATTERNS[0], z);
        java.time.LocalDateTime ldt = java.time.LocalDateTime.ofInstant(
            Instant.ofEpochSecond(s), ZoneId.of(z));
        String indep = String.format("%04d-%02d-%02d %02d:%02d:%02d", ldt.getYear(),
            ldt.getMonthValue(), ldt.getDayOfMonth(), ldt.getHour(), ldt.getMinute(),
            ldt.getSecond());
        if (!got.equals(indep)) selfBad++;
        System.out.println("F\t" + z + "\t" + s + "\t0\t" + got);
      }
    }
    System.out.println("B\tSELFCHK_BAD\t" + selfBad);

    // G：特殊档那一小组 × 六个瞬间 × 三条 pattern（45 分/30 分 DST/东西半球/符号陷阱/窗口末）
    String[] special = { "UTC", "Asia/Shanghai", "Asia/Kathmandu", "Pacific/Chatham",
        "Australia/Lord_Howe", "America/New_York", "Europe/London", "Etc/GMT+5",
        "Asia/Taipei", "America/Santiago", "Australia/Sydney", "Africa/Ceuta" };
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
              + fmt(p * 1000L, PATTERNS[pid], z));
        }
      }
    }

    // R：RFC3339 出口（本库 to_rfc3339 的区名版）——偏移串取 SimpleDateFormat 的 X 档现读
    for (String z : special) {
      for (long p : two) {
        System.out.println("R\t" + z + "\t" + p + "\t" + fmt(p * 1000L, "yyyy-MM-dd'T'HH:mm:ssXXX", z));
      }
    }

    // S：解析读数——0 档（前跳空洞）/ 1 档 / 2 档（回拨重叠）在参照侧各落到哪个瞬间
    String[][] walls = {
        { "America/New_York", "2024-11-03 01:30:00", "0" },   // 重叠：两个合法瞬间
        { "America/New_York", "2024-03-10 02:30:00", "0" },   // 空洞：参照怎么取值
        { "Asia/Shanghai", "1986-05-04 02:30:00", "0" },      // 中国 1986 那次前跳
        { "Asia/Shanghai", "1986-05-04 02:00:00", "0" },      // 恰好是跳变点本身
        { "Europe/London", "2024-10-27 01:30:00", "0" },
        { "Pacific/Chatham", "2024-04-07 00:15:00", "0" },    // 45 分偏移那族的重叠
        { "Australia/Lord_Howe", "2024-04-07 02:30:00", "0" }, // 30 分 DST 档
        { "UTC", "2024-06-01 12:00:00", "0" },
        { "Asia/Kathmandu", "2024-06-01 12:00:00", "0" },
        { "Etc/GMT+5", "2024-06-01 12:00:00", "0" },
        { "America/New_York", "2024-13-45 99:99:99", "0" },   // 非法字段（setLenient(false) 后的报错形状）
        { "America/New_York", "2024-06-01", "1" },            // pattern 不匹配整串
        { "No/Where", "2024-06-01 12:00:00", "0" },           // 坏区名（TimeZone 静默回落 GMT）
    };
    for (String[] w : walls) {
      SimpleDateFormat sf = new SimpleDateFormat(PATTERNS[Integer.parseInt(w[2])],
          java.util.Locale.ENGLISH);
      sf.setTimeZone(TimeZone.getTimeZone(w[0]));
      sf.setLenient(false);
      String got;
      try {
        got = String.valueOf(sf.parse(w[1]).getTime());
      } catch (Exception e) {
        got = "ERR_" + e.getClass().getSimpleName();
      }
      System.out.println("S\t" + w[0] + "\t" + w[1] + "\t" + w[2] + "\t" + got);
    }
  }
}
