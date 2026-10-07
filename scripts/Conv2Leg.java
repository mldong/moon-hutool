// moon-hutool/conv —— 第十批补档的参照腿（宽松取值的界外档、符号/空串档、0x 带符号档、
// JSON 数字带 repr 档、坏路径档）。全部 ASCII 输出（本机控制台 GBK）。
// 行形状：L|<id>|<input>|<reading>；读不出来就抛 ⇒ 打 ERR:<类名>。
import cn.hutool.core.convert.Convert;

public class Conv2Leg {
  static String[][] TOINT = {
    {"plus", "+"}, {"minus", "-"}, {"empty", ""}, {"dotdash", "1.e"},
    {"hexsign", "0x+1F"}, {"hexneg", "0x-1F"},
    {"hexplus", "0x+"}, {"hexminus", "0x-"}, {"hexone", "0x+1"}, {"hexg", "0x+G"},
    {"hexmulti", "0xff"}, {"hexuppersign", "0X+F"}, {"hexbig", "0xFFFFFFFFFF"},
    {"hexd", "0x1FL"}, {"hexsignmulti", "0x-ff"},
    {"hexupper", "0X1F"}, {"hexbig64", "0x7FFFFFFFFFFFFFFF00"},
    {"big1e20", "1e20"}, {"big1e100", "1e100"}, {"nan", "NaN"}, {"inf", "Infinity"},
    {"nbsp", "1 2"}, {"fullwidth", "１２３"}, {"spacey", " 42 "},
  };
  public static void main(String[] args) {
    // 自检：三条已知互不相同的读数（null / -1 / 1）——相等就说明腿自己坏了，后面的读数全部作废
    String g1 = ti("+"), g2 = ti("0x-1F"), g3 = ti("1");
    System.out.println("G|guard|" + g1 + "|" + g2 + "|" + g3);
    boolean ok = !g1.equals(g2) && !g2.equals(g3) && !g1.equals(g3);
    System.out.println(ok ? "G|GUARD_OK|distinct3" : "G|GUARD_FAIL|same-reading");
    for (String[] r : TOINT) {
      System.out.println("I|" + r[0] + "|" + esc(r[1]) + "|" + ti(r[1]) + "|" + t64(r[1]));
    }
  }

  static String esc(String s) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < s.length(); i++) {
      char c = s.charAt(i);
      if (c >= 0x20 && c <= 0x7e && c != '|') sb.append(c);
      else sb.append("{u").append(Integer.toHexString(c)).append("}");
    }
    return sb.toString();
  }

  static String ti(String s) {
    try {
      Integer v = Convert.toInt(s, null);
      return v == null ? "null" : v.toString();
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String t64(String s) {
    try {
      Long v = Convert.toLong(s, null);
      return v == null ? "null" : v.toString();
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String conv(Object v) {
    try {
      Integer got = Convert.toInt(v, null);
      return got == null ? "null" : got.toString();
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

}
