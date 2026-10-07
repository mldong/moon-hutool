// moon-hutool/typex —— 第六批补档的参照腿（rainbow 三档、Version 的构建元数据与字符串单元档、
// DataSize 的空白表档、港澳台 10 位形状拒收档）。全部 ASCII 输出（本机控制台 GBK）。
// 带不可见码点的夹具一律用 codePoint 现构，源文件里不出现双向控制字符。
// 行形状：K|<id>|<input...>|<reading>
import cn.hutool.core.io.unit.DataSizeUtil;
import cn.hutool.core.lang.Version;
import cn.hutool.core.util.IdcardUtil;

public class TypexLeg4 {
  // 空白族码点（datasize.mbt:56..67 的 ds_is_blank 三档）
  static final String FS = new String(Character.toChars(0x1c));
  static final String HYPHEN = new String(Character.toChars(0x1d));
  static final String FIGSPACE = new String(Character.toChars(0x2007));
  static final String BOM = new String(Character.toChars(0xfeff));
  static final String LRE = new String(Character.toChars(0x202a));
  static final String NEL = new String(Character.toChars(0x85));

  static String[][] RAINBOW = {
    {"mid-even", "6", "20", "6"},
    {"mid-even2", "10", "20", "6"},
    {"head-even", "3", "20", "6"},
    {"tail-even", "18", "20", "6"},
    {"mid-odd", "8", "20", "5"},
    {"few", "2", "4", "10"},
    {"neg-total", "2", "-3", "10"},
    {"d10-head", "1", "20", "10"},
  };
  static String[][] VER = {
    {"build", "1.0+build", "1.0"},
    {"build2", "1.0+2", "1.0+10"},
    {"pre", "1.0.0-beta", "1.0.0"},
    {"strunit", "1.0.1", "1.0.a"},
    {"str-vs-str", "1.0.a", "1.0.aa"},
    {"str-vs-str2", "1.0.aa", "1.0.a"},
    {"snap", "1.2.3", "1.2.3-SNAPSHOT"},
    {"under", "1.0_1", "1.0.1"},
  };
  static String[] DS = {
    "1" + FS + "KB",
    "1" + HYPHEN + "KB",
    "1" + FIGSPACE + "KB",
    "1" + BOM + "KB",
    "1" + LRE + "KB",
    "1" + NEL + "KB",
    "1 KB",
  };
  static String[] CARD = {
    "A123456(7)", "A1234567", "a1234567", "132456(A)", "Z324567(8)", "(5)", "1234567(8)",
    "A123456(7", "A12345)6(7)", "1324567", "ME1234567", "123456789", "X123456()",
    "1234567890", "12345(6)",
  };

  public static void main(String[] a) {
    // 守卫自检：三档出口互不相同（正常 / 形状假 / 解析异常）
    String g1 = rain("6", "20", "6");
    String g2 = hk("Z324567(8)");
    String g3 = ds("1" + FIGSPACE + "KB");
    System.out.println("G|guard|" + g1 + "|" + g2 + "|" + g3);
    if (g1.equals(g2) || g1.equals(g3) || g2.equals(g3)) {
      System.out.println("G|GUARD_BAD|not_distinct");
    } else {
      System.out.println("G|GUARD_OK|distinct3");
    }

    for (String[] r : RAINBOW) {
      System.out.println("R|" + r[0] + "|" + r[1] + "|" + r[2] + "|" + r[3] + "|" + rain(r[1], r[2], r[3]));
    }
    for (String[] v : VER) {
      System.out.println("VC|" + v[0] + "|" + esc(v[1]) + "|" + esc(v[2]) + "|" + vcmp(v[1], v[2]));
      System.out.println("VT|" + v[0] + "|" + esc(v[1]) + "|" + vto(v[1]));
      System.out.println("VT|" + v[0] + "b|" + esc(v[2]) + "|" + vto(v[2]));
    }
    for (String s : DS) {
      System.out.println("DP|" + cps(s) + "|" + ds(s));
    }
    for (String s : CARD) {
      System.out.println("IH|" + s + "|" + hk(s));
      System.out.println("IT|" + s + "|" + tw(s));
      System.out.println("I10|" + s + "|" + ten(s));
    }
  }

  // 把码点序列打成 0xNN 形式，避免不可见字符进读数行
  static String cps(String s) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < s.length(); i++) {
      if (sb.length() > 0) sb.append("+");
      sb.append(Integer.toHexString(s.charAt(i)));
    }
    return sb.toString();
  }

  static String esc(String s) {
    return s.replace("|", "{bar}");
  }

  static String rain(String pageNo, String totalPage, String displayCount) {
    try {
      int[] got = cn.hutool.core.util.PageUtil.rainbow(Integer.parseInt(pageNo),
          Integer.parseInt(totalPage), Integer.parseInt(displayCount));
      StringBuilder sb = new StringBuilder();
      for (int v : got) {
        if (sb.length() > 0) sb.append(";");
        sb.append(v);
      }
      return sb.length() == 0 ? "-" : sb.toString();
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String vcmp(String x, String y) {
    try {
      return String.valueOf(new Version(x).compareTo(new Version(y)));
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String vto(String x) {
    try {
      return esc(new Version(x).toString());
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String ds(String s) {
    try {
      return String.valueOf(DataSizeUtil.parse(s));
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String hk(String s) {
    try {
      return String.valueOf(IdcardUtil.isValidHKCard(s));
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String tw(String s) {
    try {
      return String.valueOf(IdcardUtil.isValidTWCard(s));
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String ten(String s) {
    try {
      String[] got = IdcardUtil.isValidCard10(s);
      if (got == null) return "NULL";
      return got.length + ":" + (got.length == 0 ? "-" : esc(got[0]) + "/" + esc(got[got.length - 1]));
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

}
