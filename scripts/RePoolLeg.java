// moon-hutool/re —— 第二批（RegexPool / PatternPool 常量表）的参照腿
//
// 参照件归属（javap 现读，**不在 `cn.hutool.core.regex`**——那个包里只有 ReUtil/Splitter 等，
// 两个 Pool 实际在 `cn.hutool.core.lang`）：
//   RegexPool   （interface）34 个 String 常量：正则原文
//   PatternPool （class）    33 个 Pattern 常量（全是 Pattern.compile(RegexPool.X, 旗标)，零自带字面量）
//                            + get(key)/get(key,flags)/remove/clear（进程级可变缓存）
//
// 这条腿回答三件事，全部只出机器读数：
//   1) 每个常量的**原文与旗标**（R/P/D/S 行）——改写规则表的输入（`scripts/re_preset_rewrite.py`）；
//   2) 每个常量在**样本串**上的两档判定（M = Matcher.matches()、F = find() 的第 0 组）——
//      改写串必须逐条给出同一个读数，这是"直译"的全部依据；
//   3) 单参 `PatternPool.get(原文)` 与那个带旗标的常量**不是同一个 Pattern**（X 行）——
//      这一条决定本库的 UUID/EMAIL/MAC/URL_HTTP 档到底认不认大写。
//
// 本库的底座是 core 的 `@string.Regex`（纯 MoonBit 的 Brzozowski 导数自动机，**不是 RE2、
// 也不借宿主 RegExp**）——Java 侧的 `\d`/`\w`/`\xHH`/旗标/UTF-16 代理对这几处与它有没有差集，
// 全由第 2) 项的逐条对撞判出，不靠"应该差不多"。
//
// 用法（必须给 Windows 风格路径，分号分隔）：
//   javac -encoding UTF-8 -cp "hutool-core.jar" RePoolLeg.java -d <cls>
//   java -cp "<cls>;hutool-core.jar" RePoolLeg > re_pool_leg.tsv
// 全部 ASCII 输出（本机控制台是 GBK）；中文样本走 esc() 成 \\uXXXX，所以 .java 源码也全 ASCII。
//
// 行形状（制表符分隔）：
//   T <键> <值>                                   代次（JAVA / HUTOOL / 两个 Pool 的常量条数）
//   R <name> <原文 esc>                           RegexPool 常量原文
//   P <name> <原文 esc> <flags>                    PatternPool 常量（flags 是 Java 位标）
//   D only_regex_pool|only_pattern_pool <name>     两张表的差集
//   S <name> [<name>…]                            与谁同文（表里的重复常量）
//   M <name> <样本 esc> <true|false|ERR_…>         pt.matcher(样本).matches()
//   F <name> <样本 esc> <第 0 组 esc|NONE|ERR_…>    pt.matcher(样本).find() 后 group()
//   X <name> <样本 esc> <get(原文) 的 matches> <常量的 matches>  单参 get 与带旗标常量的分岔
//   G <键> <读数>                                  get/remove/clear 的查找语义
//   B <键> <读数>                                  守卫自检（三档出口必须互不相同）
import cn.hutool.core.lang.PatternPool;
import cn.hutool.core.lang.RegexPool;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.concurrent.atomic.AtomicReference;
import java.util.regex.Pattern;

public class RePoolLeg {
  static final long GUARD_MS = 8000;  // EMAIL 那类嵌套量词在坏输入上会指数回溯：超时也是一种读数

  static String esc(String s) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < s.length(); i++) {
      char c = s.charAt(i);
      if (c >= 0x20 && c < 0x7f && c != '\\' && c != '"') {
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

  interface Sup {
    String run() throws Exception;
  }

  /** 崩/超时都不吞掉：Java 侧的异常类名是"本库要不要同形"的判据之一，超时是"这条夹具不可用"的判据。 */
  static String guarded(Sup f) {
    AtomicReference<String> ref = new AtomicReference<>("ERR_NoResult");
    Thread t = new Thread(() -> {
      try {
        ref.set(String.valueOf(f.run()));
      } catch (Throwable e) {
        ref.set("ERR_" + e.getClass().getSimpleName() + "|" + e.getMessage());
      }
    });
    t.setDaemon(true);
    t.start();
    try {
      t.join(GUARD_MS);
    } catch (InterruptedException e) {
      return "ERR_Interrupted";
    }
    if (t.isAlive()) {
      return "ERR_Timeout";
    }
    return "ERR_NoResult".equals(ref.get()) ? "ERR_ThreadDied" : ref.get();
  }

  // ---- 样本表：每个常量给"正、负、边界、（带旗标的那五个再加大小写）"----
  // 只放**这条常量自己的**判据；不改写规则表能改出什么，由 python 侧的规则表管（R1~R6）。
  static Map<String, List<String>> samples() {
    Map<String, List<String>> m = new LinkedHashMap<>();
    m.put("GENERAL", list("abc_1", "12", "", "ab c", "\u4e2d\u6587", "_", "\u4e2d"));
    m.put("NUMBERS", list("123", "12a", "a1", "", "0", "\u4e2d"));
    m.put("WORD", list("abc", "ab1", "1", "", "\u4e2d"));
    m.put("CHINESE", list("\u4e2d", "a", "\u2e80", "\uf900", "\u9fff", "\ud840\udc00",
        "\ud869\udedf", "\ud869\udf00", "\ud87e\udc00", "\ud87e\ude20", " "));
    m.put("CHINESES", list("\u4e2d\u6587", "\u4e2da", "\ud840\udc00\ud840\udc00", ""));
    m.put("GROUP_VAR", list("$12", "x12", "$", "$0", "12"));
    m.put("IPV4", list("1.2.3.4", "255.255.255.255", "0.0.0.0", "256.1.1.1", "1.2.3", "01.2.3.4",
        "1.2.3.4.5", "x1.2.3.4"));
    m.put("IPV6", list("::1", "2001:db8::1", "fe80::1%eth0", "::ffff:1.2.3.4", "12345::", "::",
        "1:2:3:4:5:6:7:8", "1:2:3:4:5:6:7:8:9"));
    m.put("MONEY", list("12.30", "12", "12.", "-12", "1e3", ".", "0.0"));
    m.put("EMAIL", list("a@b.co", "A@B.CO", "a@b", "\u4e2d\u6587@a.com", "x.y@z.cn", "a b@c.com",
        "\"a b\"@c.com", "a@b.co."));
    m.put("EMAIL_WITH_CHINESE", list("\u4e2d\u6587@b.co", "a@b.co", "A@B.CO", "a@b"));
    m.put("ZIP_CODE", list("100000", "999077", "999078", "999079", "010000", "12345", "99907",
        "1000000"));
    m.put("BIRTHDAY", list("1991-01-01", "1991\u5e741\u67081\u65e5", "91.1.1", "1991-01-0",
        "1991/13/1", "\u4e2d"));
    m.put("URI", list("a/b", "", "http://x/y?z#w", "urn:x:x", "\u4e2d"));
    m.put("URL", list("http://a", "://a", "ftp://x.cn/p?a=b#c", "HTTP://A", "http://", "a://b"));
    m.put("URL_HTTP", list("https://x.cn/a", "x.cn", "HTTPS://X.CN", "file:///a", "mailto:a@b"));
    m.put("GENERAL_WITH_CHINESE", list("\u4e2d\u6587_1", "abc", "a b", "\u4e2d \u6587", "12", ""));
    m.put("UUID", list("6ba7b810-9dad-11d1-80b4-00c04fd430c8",
        "6BA7B810-9DAD-11D1-80B4-00C04FD430C8", "6ba7b810-9dad-11d1-80b4-00c04fd430c",
        "6ba7b8109dad11d180b400c04fd430c8", "gba7b810-9dad-11d1-80b4-00c04fd430c8"));
    m.put("UUID_SIMPLE", list("6ba7b8109dad11d180b400c04fd430c8",
        "6BA7B8109DAD11D180B400C04FD430C8", "6ba7b810", "6ba7b8109dad11d180b400c04fd430c8g"));
    m.put("MAC_ADDRESS", list("00-1A-2B-3C-4D-5E", "00:1a:2b:3c:4d:5e", "001A.2B3C.4D5E",
        "001122334455", "0x123456789012 abcETHER", "00-1A-2B-3C-4D", "zz:1a:2b:3c:4d:5e"));
    m.put("HEX", list("deadBEEF", "dead BE E", "g", "", "0"));
    m.put("TIME", list("12:30", "12\u65f630\u5206", "1:2", "12:30:61", "25:00", "\u4e2d", "12\u65f630\u520615\u79d2"));
    m.put("CHINESE_NAME", list("\u6b27\u9633\u00b7\u4e09", "\u674e\u4e09", "\u674e", "\u6b27\u9633 ",
        "\u3400", "\u4e2d\u00b7\u4e2d\u00b7\u4e2d"));
    return m;
  }

  static List<String> list(String... a) {
    List<String> l = new ArrayList<>();
    for (String s : a) {
      l.add(s);
    }
    return l;
  }

  public static void main(String[] a) throws Exception {
    System.out.println("T\tJAVA\t" + System.getProperty("java.version"));
    System.out.println("T\tHUTOOL\tcore 5.8.35");

    Map<String, String> rx = new LinkedHashMap<>();
    Class<?> rxc = Class.forName("cn.hutool.core.lang.RegexPool");
    for (Field f : rxc.getFields()) {
      if (f.getType() == String.class) {
        rx.put(f.getName(), (String) f.get(null));
      }
    }
    Map<String, Pattern> pp = new LinkedHashMap<>();
    Class<?> ppc = Class.forName("cn.hutool.core.lang.PatternPool");
    for (Field f : ppc.getFields()) {
      if (f.getType() == Pattern.class) {
        pp.put(f.getName(), (Pattern) f.get(null));
      }
    }

    // 守卫自检：正常/崩/超时三档出口必须互不相同，否则下面的 ERR_Timeout 就不可信（cron2 同一条纪律）。
    System.out.println("B\tok\t" + guarded(() -> "RET"));
    System.out.println("B\tboom\t" + guarded(() -> String.valueOf(boom())));
    System.out.println("B\thang\t" + guarded(() -> {
      Thread.sleep(GUARD_MS + 4000);
      return "late";
    }));

    for (String k : rx.keySet()) {
      System.out.println("R\t" + k + "\t" + esc(rx.get(k)));
    }
    System.out.println("T\tREGEX_POOL_CONSTS\t" + rx.size());
    for (String k : pp.keySet()) {
      Pattern p = pp.get(k);
      System.out.println("P\t" + k + "\t" + esc(p.pattern()) + "\t" + p.flags());
    }
    System.out.println("T\tPATTERN_POOL_CONSTS\t" + pp.size());

    Set<String> rxs = new TreeSet<>(rx.keySet());
    Set<String> pats = new TreeSet<>(pp.keySet());
    for (String s : rxs) {
      if (!pats.contains(s)) {
        System.out.println("D\tonly_regex_pool\t" + s);
      }
    }
    for (String s : pats) {
      if (!rxs.contains(s)) {
        System.out.println("D\tonly_pattern_pool\t" + s);
      }
    }

    // 同文常量：表里有没有两条一模一样的（本库要不要共用一格）
    Map<String, String> byText = new LinkedHashMap<>();
    for (String k : rx.keySet()) {
      String prev = byText.get(rx.get(k));
      System.out.println("S\t" + k + "\t" + (prev == null ? "" : "同 " + prev));
      byText.put(rx.get(k), k);
    }

    // ---- 样本对撞：M = matches()（整串），F = find() 的第 0 组 ----
    // "常量本身"是这一批的判据主体：PatternPool 有的走常量（带旗标），只有 RegexPool 有的（URI）走
    // Pattern.compile(原文)——旗标 0，与 PatternPool 的常量同档（它本来就是 Pattern.compile(X, 0)）。
    for (String name : rx.keySet()) {
      List<String> ss = samples().get(name);
      if (ss == null) {
        continue;
      }
      Pattern constant = pp.get(name);
      final Pattern pt = constant != null ? constant : Pattern.compile(rx.get(name));
      final Pattern pt0 = PatternPool.get(rx.get(name));  // 单参 get：旗标恒 0
      for (final String s : ss) {
        System.out.println("M\t" + name + "\t" + esc(s) + "\t" + guarded(() -> String.valueOf(
            pt.matcher(s).matches())));
        System.out.println("F\t" + name + "\t" + esc(s) + "\t" + guarded(() -> {
          java.util.regex.Matcher m = pt.matcher(s);
          return m.find() ? esc(m.group()) : "NONE";
        }));
        if (pt.flags() != 0) {  // 只有带旗标的那几条才谈"单参 get 丢不丢旗标"
          System.out.println("X\t" + name + "\t" + esc(s) + "\t" + guarded(() -> String.valueOf(
              pt0.matcher(s).matches())) + "\t" + guarded(() -> String.valueOf(
              pt.matcher(s).matches())));
        }
      }
    }

    // ---- R7 的依据：类外**未配对的 `]`** 在 Java 里是字面量右方括号（EMAIL 那条常量就是这么写的），
    //      core 判语法错。两侧必须对同一个输入给同一个判定，这一条改写规则才算"同一字面值两种写法"。
    System.out.println("J\tbare_close_matches\t" + guarded(() -> String.valueOf(
        Pattern.compile("a]b").matcher("a]b").matches())));
    System.out.println("J\tbare_close_only\t" + guarded(() -> String.valueOf(
        Pattern.compile("]").matcher("]").matches())));
    System.out.println("J\tescaped_close_matches\t" + guarded(() -> String.valueOf(
        Pattern.compile("a\\]b").matcher("a]b").matches())));
    System.out.println("J\tescaped_close_only\t" + guarded(() -> String.valueOf(
        Pattern.compile("\\]").matcher("]").matches())));
    System.out.println("J\tbare_close_find\t" + guarded(() -> {
      java.util.regex.Matcher m = Pattern.compile("(?:x|])").matcher("]x]");
      return m.find() ? esc(m.group()) : "NONE";
    }));

    // ---- get/remove/clear 的查找语义（决定这三件收不收）----
    System.out.println("G\tget_missing\t" + guarded(() -> String.valueOf(
        PatternPool.get("NoSuchKey").pattern())));
    System.out.println("G\tget_missing_flags\t" + guarded(() -> String.valueOf(
        PatternPool.get("NoSuchKey", Pattern.CASE_INSENSITIVE).pattern())));
    System.out.println("G\tget_null_key\t" + guarded(() -> String.valueOf(
        PatternPool.get(null))));
    System.out.println("G\tget_empty_key\t" + guarded(() -> String.valueOf(
        PatternPool.get(""))));
    System.out.println("G\tget_same_instance_twice\t" + guarded(() -> {
      Pattern x = PatternPool.get(RegexPool.UUID);
      Pattern y = PatternPool.get(RegexPool.UUID);
      return String.valueOf(x == y);
    }));
    System.out.println("G\tget_after_clear_same\t" + guarded(() -> {
      Pattern x = PatternPool.get(RegexPool.MAC_ADDRESS);
      PatternPool.clear();
      Pattern y = PatternPool.get(RegexPool.MAC_ADDRESS);
      return String.valueOf(x == y);
    }));
    System.out.println("G\tremove_returns\t" + guarded(() -> String.valueOf(
        PatternPool.remove(RegexPool.HEX, 0))));
    System.out.println("G\tbad_regex_in_pool\t" + guarded(() -> String.valueOf(
        PatternPool.get("[unclosed"))));
    // getFirstNumber 的出口形状：无命中给什么、命中第 0 组还是第 1 组
    System.out.println("G\tget_first_number\t" + guarded(() -> String.valueOf(
        cn.hutool.core.util.ReUtil.getFirstNumber("a20b30"))));
    System.out.println("G\tget_first_number_none\t" + guarded(() -> String.valueOf(
        cn.hutool.core.util.ReUtil.getFirstNumber("abc"))));
    System.out.println("G\tget_first_number_empty\t" + guarded(() -> String.valueOf(
        cn.hutool.core.util.ReUtil.getFirstNumber(""))));
    System.out.println("G\tget_first_number_null\t" + guarded(() -> String.valueOf(
        cn.hutool.core.util.ReUtil.getFirstNumber(null))));
  }

  static Object boom() {
    return boom();
  }
}
