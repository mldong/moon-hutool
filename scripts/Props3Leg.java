// moon-hutool/ini —— 第三批补档的参照腿（#22.29 严格 Properties 语义的行法与转义族）。
// 权威参照是 JDK 的 java.util.Properties.load(Reader)，不是 hutool（hutool Props 只是转手，
// 见 docs/spec/22-ini.md §8）。全部 ASCII 输出（本机控制台 GBK），非 ASCII 走 {uXXXX} 记号。
// 注意：源码里不能出现反斜杠+u 的六连字符（javac 的 unicode 预处理在词法之前），
// 所以下面用 "\\" + "u00E9" 拼出被测串。
// 行形状：P|<id>|<入参码位>|<k>{kv}<v>;<k>{kv}<v>…（按 load 的写入序；键值里可能真有 `=`，
// 所以分隔符不能直接用等号——用 {kv} 记号，生成器按同一个记号重画，两侧同形才可对撞）｜读不出来 ⇒ ERR:<类名>
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Properties;

public class Props3Leg {
  static class Ordered extends Properties {
    ArrayList<String> order = new ArrayList<String>();
    public Object put(Object k, Object v) {
      if (k instanceof String) order.add(esc((String) k) + "{kv}" + esc(String.valueOf(v)));
      return super.put(k, v);
    }
  }

  static String[][] F = {
    {"noeol", "a=1"},
    {"noeol_bs", "a=1\\"},
    {"lead_ws", " \ta=1\n"},
    {"cont_blank", "a=1\\\n\nb=2\n"},
    {"cont_ws", "a=1\\\n   2\n"},
    {"upper_u", "a=\\" + "u00E9"},
    {"lower_u", "a=\\" + "u00e9"},
    {"trail_bs_sp", "a=x\\ \n"},
    {"trail_bs2", "a=x\\\\\n"},
    {"dup_key", "a=1\na=2\n"},
    {"key_esc_eq", "a\\=b=1\n"},
    {"comment_bs", "# c\\\na=1\n"},
    {"cr_only", "a=1\rb=2\r"},
    {"crlf", "a=1\r\nb=2\r\n"},
    {"blank_lead", "\n \n a=1\n"},
    {"colon_sep", "a:1\n"},
    {"ws_only_line", "a=1\n   \nb=2\n"},
    // 两个"整段只剩一个反斜杠"的形状：一个测空逻辑行续接后再遇行尾，一个测键段结尾的反斜杠
    {"bs_line", "\\\n\na=1\n"},
    {"bs_key", "\\=1\n"},
    // 键段结尾正好落单根反斜杠（三个反斜杠 + 被转义的分隔符）：打 loadConvert 的"串尾是反斜杠"那一档
    {"bs3_key", "x\\\\\\=1\n"},
  };

  public static void main(String[] args) {
    // 自检：三个已知互不相同的形状（一对 / 两对 / 零对）——相同就说明腿自己坏了
    String g1 = dump("a=1"), g2 = dump("a=1\nb=2"), g3 = dump("#x\n");
    System.out.println("G|guard|" + g1 + "|" + g2 + "|" + g3);
    boolean ok = !g1.equals(g2) && !g2.equals(g3) && !g1.equals(g3) && g3.isEmpty();
    System.out.println(ok ? "G|GUARD_OK|distinct3" : "G|GUARD_FAIL|same-reading");
    for (String[] r : F) {
      System.out.println("P|" + r[0] + "|" + esc(r[1]) + "|" + dump(r[1]));
    }
  }

  static String dump(String text) {
    Ordered p = new Ordered();
    try {
      p.load(new StringReader(text));
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
    StringBuilder sb = new StringBuilder();
    for (String kv : p.order) sb.append(kv).append(";");
    return sb.toString();
  }

  static String esc(String s) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < s.length(); i++) {
      char c = s.charAt(i);
      if (c == '\n') sb.append("{n}");
      else if (c == '\r') sb.append("{r}");
      else if (c == '\t') sb.append("{t}");
      else if (c == ';') sb.append("{s}");
      else if (c == '|') sb.append("{b}");
      else if (c >= 0x20 && c <= 0x7e) sb.append(c);
      else sb.append(String.format("{u%04x}", (int) c));
    }
    return sb.toString();
  }
}
