// moon-hutool/cron —— 第二批（Part / CronPatternBuilder / CronPatternUtil）的参照腿
//
// 参照件归属（javap + 源码现读 hutool-cron 5.8.35）：
//   Part            getMin/getMax/getCalendarField/checkValue/of(int)（构造器还会把 min>max 对调）
//   CronPatternBuilder  of/set/setValues/setRange/build —— build() 返回**串**不是 CronPattern，
//     且只对「分~周」四段补默认 `*`，秒与年未设置时被 StrJoiner(NullMode.IGNORE) **整个跳过**
//   CronPatternUtil  nextDateAfter(2 参)/nextDateAfter(3 参,@Deprecated 且 isMatchSecond 无效)/
//     matchedDates 四形状（含"到起始日年底"那一档）
//   **`describe` 在 5.8.35 不存在**（javap 现读 CronPatternUtil 公开面只有上面那几条）——
//     第一批 §1 里"第二批含 describe"那句是早先照旧版本写的，本批更正。
//
// 用法（**必须给 Windows 风格路径**，本机 java 是 Windows 二进制，MSYS 风格 /g/... 会让 -cp 解析不到类）：
//   javac -encoding UTF-8 -cp "hutool-cron.jar;hutool-core.jar" scripts/Cron2Leg.java -d <cls>
//   java -cp "<cls>;hutool-cron.jar;hutool-core.jar" Cron2Leg > cron2_leg.tsv
// 全部 ASCII 输出（本机控制台是 GBK）。
//
// 行形状：
//   B <key> <value>                       守卫自检（三档出口必须互不相同）
//   T <key> <value>                       代次
//   P <part> <ordinal> <min> <max>        Part 的界
//   C <part> <value> <RET|ERR> <读数>      Part.checkValue：返回 value 或 CronException 文案
//   O <i> <part> <calendarField>           Part.of(i) 的反查（段序判据）
//   K <case> <RET|ERR> <读数>              builder 的 build() 串或抛错文案
//   RT <case> <RET|ERR> <读数>             同一 builder 的 build() 结果再喂 CronPattern 构造器（回环）
//   CB <pattern> <count> <RET|ERR> <size|文案> <start毫秒> <end毫秒> <zone>  count 边界（add-then-check 那件事）
//   M <case> <pattern> <SEC|MIN> <count> <tz> <ISO串> <毫秒串> <start毫秒> <end毫秒>  命中（ISO 一律按 UTC 打印）
//   D3 <case> <2 参毫秒> <3 参毫秒>        @Deprecated 三参与二参是否同值
//   N <case> <pattern> <base 毫秒> <tz> <毫秒> <UTC ISO>   nextDateAfter 的下一瞬间
//   N2 <case> <pattern> <base 毫秒> <tz> <毫秒> <UTC ISO>  CronPattern.nextMatch 的下一瞬间（与 N 成对）
//   E <case> <ERR|RET> <读数> <start毫秒> <end毫秒> <pattern> <zone>  参数非法（start>=end 等）的文案
//
// CB/M/E/N/N2 都把**夹具入参与区名一起写进读数行**，生成器因此不用另抄一份夹具表——
// 夹具在腿与测试里各写一份，正是第一批"64 条期望配错基准"那个成因（spec §4 落地轮记录第 ① 条）。
import cn.hutool.cron.pattern.CronPattern;
import cn.hutool.cron.pattern.CronPatternBuilder;
import cn.hutool.cron.pattern.CronPatternUtil;
import cn.hutool.cron.pattern.Part;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;
import java.util.concurrent.atomic.AtomicReference;

public class Cron2Leg {
  /**
   * 一次参照调用最多让它跑这么久。取 20 s 而不是 4 s：`leap_feb` 那一格是**真在算**
   * （matchedDates 按秒线性步进跨一年 ≈ 3.2×10^7 次匹配），4 s 会把它误记成超时无读数。
   */
  static final long GUARD_MS = 20000L;

  static SimpleDateFormat utc(String p) {
    SimpleDateFormat sf = new SimpleDateFormat(p, java.util.Locale.ENGLISH);
    sf.setTimeZone(TimeZone.getTimeZone("UTC"));
    return sf;
  }

  static String iso(long millis) {
    return utc("yyyy-MM-dd HH:mm:ss").format(new Date(millis));
  }

  static long at(String isoUtc) {
    try {
      return utc("yyyy-MM-dd HH:mm:ss").parse(isoUtc).getTime();
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * 腿跑的五个区：UTC（零偏移基线）、Asia/Shanghai（1986 那次前跳 + 空洞）、
   * America/New_York（回拨重叠）、Asia/Kathmandu（+05:45 那种 45 分偏移）、
   * Australia/Lord_Howe（DST 只挪 30 分的那族）——后两族专门试"栅格模 60 秒"与
   * "重叠档取哪一支"，只跑前三区会把这两件事藏住。
   */
  static final String[] ZONES = { "UTC", "Asia/Shanghai", "America/New_York",
      "Asia/Kathmandu", "Australia/Lord_Howe" };

  static void line(String... cols) {
    System.out.println(String.join("\t", cols));
  }

  interface Sup {
    Object run() throws Exception;
  }

  /**
   * 在守护线程里跑一次参照调用；超时/抛错/线程死掉都变成读数，腿自己不挂。
   *
   * - Note: 三条出口必须**各有自己的串**——早先这里只 catch `Exception`，于是无解模式
   *   （`0 0 0 30 2 *` 的逐日递归）把线程打成 `StackOverflowError` 后，`ref` 还停在初始值，
   *   腿把"线程崩了"报成了"超时还在跑"。判据本身坏过一次，就在这里钉住：
   *   `ERR_Timeout`（join 到点仍 alive）/ `ERR_&lt;Throwable 类名&gt;`（catch 到）/
   *   `ERR_ThreadDied`（既没超时又没结果）三档分列。
   */
  static String guarded(Sup f) {
    return guarded(GUARD_MS, f);
  }

  static String guarded(long ms, Sup f) {
    AtomicReference<String> ref = new AtomicReference<>("ERR_NoResult");
    Thread t = new Thread(() -> {
      try {
        ref.set(String.valueOf(f.run()));
      } catch (Throwable e) {
        ref.set("ERR_" + e.getClass().getName() + "|" + e.getMessage());
      }
    });
    t.setDaemon(true);
    t.start();
    try {
      t.join(ms);
    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
    }
    if (t.isAlive()) {
      return "ERR_Timeout";
    }
    String got = ref.get();
    return "ERR_NoResult".equals(got) ? "ERR_ThreadDied" : got;
  }

  /** 守卫自检专用：故意把栈打爆（校验三档出口真能分开，别让判据自己骗人） */
  static Object boom() {
    return boom();
  }

  public static void main(String[] a) {
    line("T", "JAVA", System.getProperty("java.version"));
    line("T", "TZDB_DAT_BYTES", String.valueOf(new java.io.File(
        System.getProperty("java.home"), "lib/tzdb.dat").length()));
    line("T", "HUTOOL", "cron+core 5.8.35");
    line("T", "GUARD_MS", String.valueOf(GUARD_MS));

    // 守卫自检（阳性对照）：抛错/爆栈/超时三条出口必须各给各的串。
    // 上一版只 catch Exception，爆栈的线程死掉后被报成 ERR_Timeout——21 条 feb30 读数就是这么错的。
    String gThrow = guarded(3000L, () -> {
      throw new IllegalStateException("boom_probe");
    });
    String gOver = guarded(6000L, Cron2Leg::boom);
    String gSlow = guarded(300L, () -> {
      Thread.sleep(5000L);
      return "late";
    });
    line("B", "GUARD_THROW", gThrow);
    line("B", "GUARD_OVERFLOW", gOver);
    line("B", "GUARD_SLOW", gSlow);
    line("B", "GUARD_DISTINCT", (!gThrow.equals(gOver) && !gOver.equals(gSlow)
        && !gThrow.equals(gSlow)) ? "true" : "FALSE_COLLAPSE");

    // ---- Part：界、checkValue 文案、of(i) 段序 ----
    for (Part p : Part.values()) {
      line("P", p.name(), String.valueOf(p.ordinal()), String.valueOf(p.getMin()),
          String.valueOf(p.getMax()));
      int min = p.getMin();
      int max = p.getMax();
      int[] vals = { min, max, min - 1, max + 1, -1, 60, 7, 24, 13, 1970, 0 };
      for (int v : vals) {
        try {
          line("C", p.name(), String.valueOf(v), "RET", String.valueOf(p.checkValue(v)));
        } catch (Exception e) {
          line("C", p.name(), String.valueOf(v), "ERR", e.getMessage());
        }
      }
    }
    for (int i = 0; i < Part.values().length; i++) {
      line("O", String.valueOf(i), Part.of(i).name(),
          String.valueOf(Part.of(i).getCalendarField()));
    }
    for (int i : new int[] { -1, 7, 99 }) {
      try {
        line("O", String.valueOf(i), Part.of(i).name(), "RET");
      } catch (Exception e) {
        line("O", String.valueOf(i), "ERR", e.getClass().getSimpleName());
      }
    }

    // ---- CronPatternBuilder：build() 的形状、抛错期点、以及"build 出来的串能不能再解析" ----
    // 每个用例都成对记 K（build 的串）与 RT（把那串喂回 CronPattern 构造器的结果）——
    // 「秒与年未设置就整个跳过」这条规矩的代价必须由回环读数说清，不能靠读源码的直觉。
    Object[][] bcases = {
        { "empty", new Sup[] { () -> CronPatternBuilder.of().build() } },
        { "minute_only", new Sup[] {
            () -> CronPatternBuilder.of().set(Part.MINUTE, "*/5").build() } },
        { "values_hour", new Sup[] {
            () -> CronPatternBuilder.of().setValues(Part.HOUR, 1, 2, 3).build() } },
        { "range_dom", new Sup[] {
            () -> CronPatternBuilder.of().setRange(Part.DAY_OF_MONTH, 1, 15).build() } },
        { "second_set", new Sup[] {
            () -> CronPatternBuilder.of().set(Part.SECOND, "30").build() } },
        { "year_only_no_second", new Sup[] {
            () -> CronPatternBuilder.of().set(Part.YEAR, "2030").build() } },
        { "second_and_year", new Sup[] {
            () -> CronPatternBuilder.of().set(Part.SECOND, "0").set(Part.YEAR, "2030")
                       .build() } },
        { "blank_minute", new Sup[] {
            () -> CronPatternBuilder.of().set(Part.MINUTE, "").build() } },
        { "space_minute", new Sup[] {
            () -> CronPatternBuilder.of().set(Part.MINUTE, "  ").build() } },
        { "null_minute", new Sup[] {
            () -> CronPatternBuilder.of().set(Part.MINUTE, null).build() } },
        { "range_reversed", new Sup[] {
            () -> CronPatternBuilder.of().setRange(Part.DAY_OF_MONTH, 20, 5).build() } },
        { "values_with_second", new Sup[] {
            () -> CronPatternBuilder.of().set(Part.SECOND, "0")
                       .setValues(Part.MINUTE, 0, 30).build() } },
        { "values_empty", new Sup[] {
            () -> CronPatternBuilder.of().setValues(Part.MINUTE).build() } },
        { "dow_seven", new Sup[] {
            () -> CronPatternBuilder.of().set(Part.DAY_OF_WEEK, "7").build() } },
        { "junk_minute", new Sup[] {
            () -> CronPatternBuilder.of().set(Part.MINUTE, "abc").build() } },
        { "values_out_of_range", new Sup[] {
            () -> CronPatternBuilder.of().setValues(Part.HOUR, 25).build() } },
        { "range_out_of_range", new Sup[] {
            () -> CronPatternBuilder.of().setRange(Part.MINUTE, -1, 5).build() } },
        { "second_out_of_range", new Sup[] {
            () -> CronPatternBuilder.of().setValues(Part.SECOND, 60).build() } },
    };
    for (Object[] b : bcases) {
      String name = (String) b[0];
      @SuppressWarnings("unchecked")
      Sup s = ((Sup[]) b[1])[0];
      String got = guarded(s);
      line("K", name, got.startsWith("ERR_") ? "ERR" : "RET", got);
      if (got.startsWith("ERR_")) {
        line("RT", name, "ERR", "ERR_NoBuild");
      } else {
        line("RT", name, guarded2(() -> {
          try {
            return "RET\t" + new CronPattern(got);
          } catch (Exception e) {
            return "ERR\t" + e.getClass().getSimpleName() + "|" + e.getMessage();
          }
        }));
      }
    }

    // ---- CronPatternUtil.matchedDates：线性步进收集 ----
    // (case, pattern, startISO, endISO, count, isMatchSecond)
    String[][] cases = {
        { "m_star", "* * * * *", "2024-03-10 06:00:00", "2024-03-10 06:05:00", "3", "false" },
        { "m_star_sec", "* * * * *", "2024-03-10 06:00:00", "2024-03-10 06:00:05", "10", "true" },
        { "every_min", "0 0 * * * *", "2024-03-10 06:00:00", "2024-03-10 09:00:00", "4", "true" },
        { "daily", "0 30 1 * * *", "2024-11-01 00:00:00", "2024-11-07 00:00:00", "6", "true" },
        { "count_zero", "* * * * *", "2024-03-10 06:00:00", "2024-03-10 06:10:00", "0", "false" },
        { "count_more_than_avail", "0 0 1 1 1 *", "2024-01-01 00:00:00",
            "2024-01-02 00:00:00", "5", "true" },
        { "span_dst_us", "30 1 * * *", "2024-11-02 00:00:00", "2024-11-05 00:00:00", "4", "false" },
        { "span_dst_cn", "30 1 * * *", "1986-05-02 00:00:00", "1986-05-07 00:00:00", "4", "false" },
        { "leap_feb", "0 0 0 29 2 *", "2024-01-01 00:00:00", "2025-01-01 00:00:00", "3", "true" },
        { "dow_mon", "0 0 * * 1", "2024-03-10 00:00:00", "2024-03-25 00:00:00", "3", "false" },
    };
    SimpleDateFormat in = utc("yyyy-MM-dd HH:mm:ss");
    TimeZone before = TimeZone.getDefault();
    for (String[] c : cases) {
      long start, end;
      try {
        start = in.parse(c[2]).getTime();
        end = in.parse(c[3]).getTime();
      } catch (Exception e) {
        line("M", c[0], c[1], "ERR", "fixture_parse");
        continue;
      }
      boolean sec = "true".equals(c[5]);
      int count = Integer.parseInt(c[4]);
      for (String tz : ZONES) {
        TimeZone.setDefault(TimeZone.getTimeZone(tz));
        final long fs = start, fe = end;
        String got = guarded(() -> {
          List<Date> ds = CronPatternUtil.matchedDates(new CronPattern(c[1]), fs, fe, count, sec);
          StringBuilder sb = new StringBuilder();
          StringBuilder ms = new StringBuilder();
          for (Date d : ds) {
            sb.append(sb.length() == 0 ? "" : "|").append(iso(d.getTime()));
            ms.append(ms.length() == 0 ? "" : "|").append(String.valueOf(d.getTime()));
          }
          return (sb.length() == 0 ? "<none>" : sb.toString()) + "\t"
              + (ms.length() == 0 ? "<none>" : ms.toString());
        });
        String[] halves = got.split("\t", -1);
        line("M", c[0], c[1], sec ? "SEC" : "MIN", String.valueOf(count), tz,
            halves[0], halves.length > 1 ? halves[1] : "<none>", String.valueOf(start),
            String.valueOf(end));
      }
    }

    // ---- count 边界：add-then-check 与 ArrayList 初始容量 ----
    long s0 = at("2024-03-10 06:00:00");
    long s1 = at("2024-03-10 06:10:00");
    int[] counts = { -1, 0, 1, 2 };
    for (int n : counts) {
      TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
      String got = guarded(() -> String.valueOf(
          CronPatternUtil.matchedDates(new CronPattern("* * * * *"), s0, s1, n, false).size()));
      line("CB", "* * * * *", String.valueOf(n), got.startsWith("ERR_") ? "ERR" : "RET", got,
          String.valueOf(s0), String.valueOf(s1), "UTC");
    }

    // ---- @Deprecated 三参 vs 二参（javadoc 明写 isMatchSecond 无效）----
    String[] dpat = { "* * * * *", "0 30 1 * * *", "0 0 0 29 2 *" };
    long[] dbase = { s0, at("2024-11-03 05:30:00"), at("2024-02-29 12:00:00") };
    for (int i = 0; i < dpat.length; i++) {
      TimeZone.setDefault(TimeZone.getTimeZone("Asia/Shanghai"));
      final String pp = dpat[i];
      final Date dd = new Date(dbase[i]);
      String two = guarded(() -> String.valueOf(CronPatternUtil.nextDateAfter(
          new CronPattern(pp), dd).getTime()));
      String three = guarded(() -> String.valueOf(CronPatternUtil.nextDateAfter(
          new CronPattern(pp), dd, true).getTime()));
      line("D3", pp, String.valueOf(dbase[i]), two, three);
    }

    // ---- nextDateAfter：同一瞬间在三个默认时区下给哪一瞬（区名入参的那条形理由）----
    String[][] npat = {
        { "star", "* * * * *" },
        { "daily_0130", "0 30 1 * * *" },
        { "daily_0230", "0 30 2 * * *" },      // 前跳空洞正中间那一档
        { "leap_only", "0 0 0 29 2 *" },       // 四年一个点
        { "apr31", "0 12 31 4 *" },            // 不存在的日子夹月末
        { "last_day", "0 0 0 L * *" },
        { "dom_and_dow", "0 12 1 * MON" },     // 日与周同限定＝且
        { "end_of_day", "59 59 23 * * *" },
        { "step15s", "*/15 * * * * *" },
        { "year_2099", "0 0 12 * * ? 2099" },
        { "feb30", "0 0 0 30 2 *" },           // 解析通过但无解：参照挂住还是报错？
    };
    // 基准里刻意放四条"回拨/前跳**之前**"的瞬间：候选墙上时刻正好落在重叠档或空洞档上时,
    // 参照的 Calendar.set 取哪一支（或跳过哪一天）必须由读数定,不能按"取先出现的那一支"想当然。
    long[] nb = { s0, at("2024-11-03 05:30:00"), at("2024-11-03 06:30:00"),
        at("2024-02-29 12:00:00"), at("2024-04-30 00:00:00"), at("1986-05-04 01:30:00"),
        at("2098-12-31 00:00:00"), at("2024-11-03 04:00:00"), at("2024-03-09 12:00:00"),
        at("2024-11-02 12:00:00"), at("1986-05-03 12:00:00") };
    // N = CronPatternUtil.nextDateAfter（已匹配先 +1 秒那一族，= 第一批 #19.3 的带区版）
    // N2 = CronPattern.nextMatch（已匹配返回自身那一族，= 第一批 #19.4 的带区版）
    // 两族在**同一条基线**上成对读数：第一批 §3 第 13 条靠这对读数抓住过变异，带区版必须留同一对。
    for (String[] p : npat) {
      for (long b : nb) {
        for (String tz : ZONES) {
          TimeZone.setDefault(TimeZone.getTimeZone(tz));
          final long bb = b;
          final String pp = p[1];
          String got = guarded(() -> String.valueOf(CronPatternUtil.nextDateAfter(
              new CronPattern(pp), new Date(bb)).getTime()));
          String got2 = guarded(() -> {
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTimeInMillis(bb);
            return String.valueOf(new CronPattern(pp).nextMatch(cal).getTimeInMillis());
          });
          emit_pair("N", p, b, tz, got);
          emit_pair("N2", p, b, tz, got2);
        }
      }
    }
    TimeZone.setDefault(before);

    // ---- 参数非法：start >= end ----
    Object[][] bads = { { "start_gt_end", new long[] { s0 + 60000, s0 } },
        { "start_eq_end", new long[] { s0, s0 } } };
    for (Object[] b : bads) {
      String name = (String) b[0];
      long[] rng = (long[]) b[1];
      TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
      String got = guarded(() -> String.valueOf(CronPatternUtil.matchedDates(
          new CronPattern("* * * * *"), rng[0], rng[1], 3, false).size()));
      line("E", name, got.startsWith("ERR_") ? "ERR" : "RET", got, String.valueOf(rng[0]),
          String.valueOf(rng[1]), "* * * * *", "UTC");
    }
  }

  static void emit_pair(String tag, String[] p, long b, String tz, String got) {
    if (got.startsWith("ERR_")) {
      line(tag, p[0], p[1], String.valueOf(b), tz, got, "-");
    } else {
      line(tag, p[0], p[1], String.valueOf(b), tz, got, iso(Long.parseLong(got)));
    }
  }

  interface Sup2 {
    String run();
  }

  /** RT 行专用：把 build() 的串喂回构造器，读数里已经带好 RET/ERR 前缀 */
  static String guarded2(Sup2 f) {
    String got = guarded(() -> f.run());
    if (got.startsWith("ERR_")) {
      return "ERR\tERR_Pass|" + got;
    }
    return got;
  }
}
