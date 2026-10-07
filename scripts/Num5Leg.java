// moon-hutool/num —— 第五批补档的参照腿（Money 三族 + 中文数字正向补零档 + 反向坏档与溢出档
// + 缩写小数两位档 + 计算器负指数档）。全部 ASCII 输出（本机控制台 GBK）。
// 行形状：K|<id>|<input>|<reading>，异常档打 ERR:<类名>，生成器按 id 分流。
import cn.hutool.core.convert.NumberChineseFormatter;
import cn.hutool.core.convert.NumberWordFormatter;
import cn.hutool.core.lang.Assert;
import cn.hutool.core.math.Money;
import cn.hutool.core.util.NumberUtil;
import java.math.BigDecimal;
import java.util.Arrays;

public class Num5Leg {
  static String[] MONIES = { "1.5", "0.07", "-3.21", "12345678.99", "0", "100", "0.005", "-1.00" };
  static String[] BAD_MONIES = { "", "abc", "1.2.3", "-", "1e3", "1..2", " " };
  static String[] EVEN = { "1.00|-3", "-1.00|3", "0.05|2", "10.00|7" };
  static String[] RATIO = { "1.00|1,1,1", "-1.00|1,1,1", "10.01|3,7", "0.03|1,1,1" };
  static long[] FWD = {
    0L, 1L, 10L, 100L, 1000L, 1010L, 1001L, 10010L, 100000L, 1000000L, 10000000L,
    100000000L, 10001000L, 100000100L, 20000000L, 100010001L,
  };
  static String[] REV = {
    "零", "一百", "一千零一", "一万", "十万", "一百万", "一千万", "一亿",
    "一二三", "abc", "", "壹佰贰拾叁拾肆万伍仟陆佰柒拾捌元玖角玖分", "壹元",
  };
  static String[] REV_BIG = { "九千九百九十九万万", "九百九十九万九千九百九十九万万", "十亿" };
  static long[] ABBR = { 0L, 1000L, 1005L, 10050L, 10150L, 10500L, 100000L, 105000L, 1000000L, 10050000L, -10050L };
  static String[] CALC = { "1e-3", "2E-2", "1e-3+1", "1e0", "1e-1", "0.001", "1e21", "1e-21" };

  public static void main(String[] a) {
    // 守卫自检：三条出口互不相同（正常 / 异常 / 空串），并断言真的互不相同
    String g1 = row(() -> new Money("1.5").getAmount().toPlainString());
    String g2 = row(() -> new Money("abc").getAmount().toPlainString());
    String g3 = row(() -> new Money("0").getAmount().toPlainString());
    System.out.println("G|guard|" + g1 + "|" + g2 + "|" + g3);
    if (g1.equals(g2) || g1.equals(g3) || g2.equals(g3)) {
      System.out.println("G|GUARD_BAD|exits_not_distinct");
    } else {
      System.out.println("G|GUARD_OK|distinct3");
    }

    for (String s : MONIES) {
      System.out.println("MY|" + s + "|" + row(() -> dbl(new Money(s).getAmount().doubleValue())));
      System.out.println("MC|" + s + "|" + row(() -> String.valueOf(new Money(s).getCent())));
      System.out.println("MS|" + s + "|" + row(() -> String.valueOf(new Money(s).toString())));
    }
    for (String s : BAD_MONIES) {
      System.out.println("MB|" + s + "|" + row(() -> dbl(new Money(s).getAmount().doubleValue())));
    }
    for (String s : EVEN) {
      String[] p = s.split("\\|");
      System.out.println("AE|" + s + "|" + row(() -> {
        Money[] got = new Money(p[0]).allocate(Integer.parseInt(p[1]));
        StringBuilder sb = new StringBuilder();
        for (Money m : got) {
          if (sb.length() > 0) sb.append(";");
          sb.append(m.getCent());
        }
        return sb.toString();
      }));
    }
    for (String s : RATIO) {
      String[] p = s.split("\\|");
      System.out.println("AR|" + s + "|" + row(() -> {
        String[] rs = p[1].split(",");
        long[] rr = new long[rs.length];
        for (int i = 0; i < rs.length; i++) rr[i] = Long.parseLong(rs[i]);
        Money[] got = new Money(p[0]).allocate(rr);
        StringBuilder sb = new StringBuilder();
        for (Money m : got) {
          if (sb.length() > 0) sb.append(";");
          sb.append(m.getCent());
        }
        return sb.toString();
      }));
    }
    for (long v : FWD) {
      System.out.println("CF|" + v + "|" + row(() -> NumberChineseFormatter.format(v, false)));
      System.out.println("CFU|" + v + "|" + row(() -> NumberChineseFormatter.format(v, true)));
    }
    for (String s : REV) {
      System.out.println("RN|" + s + "|" + row(() -> String.valueOf(NumberChineseFormatter.chineseToNumber(s))));
      System.out.println("RM|" + s + "|" + row(() -> String.valueOf(NumberChineseFormatter.chineseMoneyToNumber(s))));
    }
    for (String s : REV_BIG) {
      System.out.println("RB|" + s + "|" + row(() -> String.valueOf(NumberChineseFormatter.chineseToNumber(s))));
      System.out.println("RBM|" + s + "|" + row(() -> String.valueOf(NumberChineseFormatter.chineseMoneyToNumber(s))));
    }
    for (long v : ABBR) {
      System.out.println("AC|" + v + "|" + row(() -> NumberChineseFormatter.formatSimple(v)));
      System.out.println("AW|" + v + "|" + row(() -> NumberWordFormatter.formatSimple(v)));
    }
    for (String s : CALC) {
      System.out.println("CC|" + s + "|" + row(() -> String.valueOf(NumberUtil.calculate(s))));
    }
  }

  static String dbl(double d) {
    return String.valueOf(d);
  }

  interface Body {
    String get() throws Exception;
  }

  static String row(Body b) {
    try {
      String v = b.get();
      return v == null ? "NULL" : v.replace("|", "{bar}").replace("\n", " ");
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName() + ":" + String.valueOf(t.getMessage()).replace("\n", " ");
    }
  }
}
