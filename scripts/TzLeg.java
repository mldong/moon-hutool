// moon-hutool/date —— 内置时区表的参照腿
//
// 参照代次：本机 JDK 17（`java -version` 现读，收口时把版本与 lib/tzdb.dat 字节数写进 spec §5.1）
// 用法（TZ_WINDOW 可省，默认 [1970-01-01, 2050-01-01)）：
//   javac -encoding UTF-8 scripts/tz_leg.java -d /tmp/tzleg
//   java -cp /tmp/tzleg TzLeg > tz_leg.tsv
// 输出全部 ASCII（本机控制台是 GBK，中文读数会被重编码）。
//
// 行形状：
//   B <key> <value>                       代次与总量读数
//   Z <zone> <seg_count> <last_start>     逐区段数（选"段数最多的前 N 区"用）
//   D <zone> <seg_start_epoch_sec> <offset_minutes>
//   P <zone> <probe_epoch_sec> <offset_minutes>
//   T <zone> <seg_start> <off_before_min> <off_after_min>   段界两侧读数（阳性对照用）
//   V <zone> <wall_local> <n> <offsets_minutes_pipe_joined> 墙上时刻的合法偏移个数（0/1/2 三档）
//   U <input> <kind> <reading>            坏区名在参照侧的行为（静默回落还是抛）
//   A <zone> <alias_target>               与 canonical 区规则完全同读数的别名
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.zone.ZoneOffsetTransition;
import java.time.zone.ZoneRules;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class TzLeg {
  static long LO = Instant.parse("1970-01-01T00:00:00Z").getEpochSecond();
  static long HI = Instant.parse("2050-01-01T00:00:00Z").getEpochSecond();

  static long instantOf(ZoneOffsetTransition t) {
    return t.getDateTimeBefore().toInstant(t.getOffsetBefore()).getEpochSecond();
  }

  static int minAt(ZoneRules r, long e) {
    return r.getOffset(Instant.ofEpochSecond(e)).getTotalSeconds() / 60;
  }

  public static void main(String[] a) {
    List<String> ids = new ArrayList<>(ZoneId.getAvailableZoneIds());
    Collections.sort(ids);

    System.out.println("B\tJAVA_VERSION\t" + System.getProperty("java.version"));
    System.out.println("B\tJAVA_VENDOR\t" + System.getProperty("java.vendor"));
    System.out.println("B\tTZDB_DAT_BYTES\t" + new java.io.File(
        System.getProperty("java.home"), "lib/tzdb.dat").length());
    System.out.println("B\tWINDOW_LO\t" + LO);
    System.out.println("B\tWINDOW_HI\t" + HI);
    System.out.println("B\tZONES\t" + ids.size());

    long totalRows = 0, bad = 0;
    Map<String, String> alias = new HashMap<>();
    Map<String, Integer> segCount = new TreeMap<>();

    for (String id : ids) {
      ZoneRules r = ZoneId.of(id).getRules();
      List<long[]> segs = new ArrayList<>();
      segs.add(new long[] { LO, minAt(r, LO) });
      for (ZoneOffsetTransition t : r.getTransitions()) {
        long e = instantOf(t);
        if (e < LO || e >= HI) continue;
        segs.add(new long[] { e, t.getOffsetAfter().getTotalSeconds() / 60 });
      }
      Collections.sort(segs, (x, y) -> Long.compare(x[0], y[0]));
      List<long[]> uniq = new ArrayList<>();
      for (long[] s : segs) {
        if (!uniq.isEmpty() && uniq.get(uniq.size() - 1)[1] == s[1]) continue;
        uniq.add(s);
      }
      segs = uniq;
      for (int i = 0; i < segs.size(); i++) {
        long e = segs.get(i)[0];
        if (minAt(r, e) != segs.get(i)[1]) bad++;
        if (i > 0 && minAt(r, e - 1) != segs.get(i - 1)[1]) bad++;
        totalRows++;
      }
      if (minAt(r, HI - 1) != segs.get(segs.size() - 1)[1]) bad++;
      segCount.put(id, segs.size());
      System.out.println("Z\t" + id + "\t" + segs.size() + "\t" + segs.get(segs.size() - 1)[0]);
      for (long[] s : segs) System.out.println("D\t" + id + "\t" + s[0] + "\t" + s[1]);

      // 规则指纹相同的区：记第一条遇到的作 canonical，其余记为别名（表体积判据用）
      StringBuilder fp = new StringBuilder();
      for (long[] s : segs) fp.append(s[0]).append(',').append(s[1]).append(';');
      String prev = alias.get(fp.toString());
      if (prev == null) alias.put(fp.toString(), id);
      else System.out.println("A\t" + id + "\t" + prev);
    }
    System.out.println("B\tTOTAL_ROWS\t" + totalRows);
    System.out.println("B\tSELFCHECK_BAD_ROWS\t" + bad);

    // 取样时刻：窗口首、中国夏令时那三年、世纪之交、美东前后跳当天、当下、窗口末
    long[] probes = {
        LO,
        Instant.parse("1986-05-04T02:00:00Z").getEpochSecond(),
        Instant.parse("2000-06-15T12:00:00Z").getEpochSecond(),
        Instant.parse("2024-03-10T06:30:00Z").getEpochSecond(),
        Instant.parse("2024-11-03T06:00:00Z").getEpochSecond(),
        Instant.parse("2037-12-31T23:59:59Z").getEpochSecond(),
    };
    for (String id : ids) {
      ZoneRules r = ZoneId.of(id).getRules();
      for (long p : probes) System.out.println("P\t" + id + "\t" + p + "\t" + minAt(r, p));
    }

    // 段界两侧读数：只给"段数最多的前 10 区"（按 Z 行段数机械选，别手挑）
    List<String> bySeg = new ArrayList<>(ids);
    bySeg.sort((x, y) -> segCount.get(y) - segCount.get(x));
    for (int k = 0; k < 10 && k < bySeg.size(); k++) {
      String id = bySeg.get(k);
      ZoneRules r = ZoneId.of(id).getRules();
      for (ZoneOffsetTransition t : r.getTransitions()) {
        long e = instantOf(t);
        if (e < LO || e >= HI) continue;
        System.out.println("T\t" + id + "\t" + e + "\t" + minAt(r, e - 1) + "\t" + minAt(r, e));
      }
    }

    // 墙上时刻读数（datetime_in 的期望底本）：只给这 7 个区，含 45 分偏移与 30 分夏令时档
    String[] wzones = { "UTC", "Asia/Shanghai", "Asia/Kathmandu", "Pacific/Chatham",
        "Australia/Lord_Howe", "America/New_York", "Etc/GMT+5" };
    System.out.println("W\tzone\tprobe_epoch\ty-m-d\tH:M:S");
    for (String z : wzones) {
      java.time.ZoneId zi = ZoneId.of(z);
      for (long p : probes) {
        java.time.LocalDateTime ldt = java.time.LocalDateTime.ofInstant(
            Instant.ofEpochSecond(p), zi);
        System.out.println("W\t" + z + "\t" + p + "\t"
            + ldt.toLocalDate() + "\t"
            + String.format("%02d:%02d:%02d", ldt.getHour(), ldt.getMinute(), ldt.getSecond()));
      }
    }

    // 墙上时刻的合法偏移个数：0（前跳空洞）/ 1（正常）/ 2（回拨重叠）三档
    String[][] walls = {
        { "America/New_York", "2024-11-03T01:30" },
        { "America/New_York", "2024-03-10T02:30" },
        { "Asia/Shanghai", "2024-06-01T12:00" },
        { "Asia/Shanghai", "1986-05-04T02:30" },
        { "Pacific/Chatham", "2024-04-07T00:15" },
        { "Europe/London", "2024-10-27T01:30" },
        { "Australia/Lord_Howe", "2024-04-07T02:15" },
        { "Australia/Lord_Howe", "2024-10-06T01:45" },
        { "UTC", "2024-06-01T12:00" },
        { "Asia/Kathmandu", "2024-06-01T12:00" },
    };
    for (String[] w : walls) {
      List<ZoneOffset> offs = ZoneId.of(w[0]).getRules().getValidOffsets(LocalDateTime.parse(w[1]));
      StringBuilder sb = new StringBuilder();
      for (ZoneOffset o : offs) sb.append(sb.length() == 0 ? "" : "|").append(o.getTotalSeconds() / 60);
      System.out.println("V\t" + w[0] + "\t" + w[1] + "\t" + offs.size() + "\t" + sb);
    }

    // 坏区名在参照侧的行为：TimeZone 静默回落 GMT，ZoneId 抛
    String[] bads = { "Nowhere/Nowhere", "", "asia/shanghai", "Shanghai", "GMT+8:00" };
    for (String b : bads) {
      String tz;
      try {
        tz = "TimeZone=" + TimeZoneOf(b).getOffset(0L) / 60000;
      } catch (Throwable t) {
        tz = "TimeZone_ERR_" + t.getClass().getSimpleName();
      }
      String zid;
      try {
        zid = "ZoneId=" + ZoneId.of(b).getRules().getOffset(Instant.EPOCH).getTotalSeconds() / 60;
      } catch (Throwable t) {
        zid = "ZoneId_ERR_" + t.getClass().getSimpleName();
      }
      System.out.println("U\t" + esc(b) + "\t" + tz + "\t" + zid);
    }
  }

  static String esc(String s) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < s.length(); i++) {
      char c = s.charAt(i);
      if (c == '\t') sb.append("\\t");
      else if (c < 32 || c > 126) sb.append(String.format("\\u%04x", (int) c));
      else sb.append(c);
    }
    return sb.length() == 0 ? "<empty>" : sb.toString();
  }

  static java.util.TimeZone TimeZoneOf(String id) {
    return java.util.TimeZone.getTimeZone(id);
  }
}
