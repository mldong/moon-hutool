// moon-hutool/csv —— 第八批补档的参照腿（默认配置读档、引号跨行的行号档、行首行尾 CR/LF 档、
// 越界档、默认写档）。全部 ASCII 输出（本机控制台 GBK）。夹具用 0xNN 码点序列承载，读数行不含裸换行。
import cn.hutool.core.text.csv.CsvData;
import cn.hutool.core.text.csv.CsvReadConfig;
import cn.hutool.core.text.csv.CsvReader;
import cn.hutool.core.text.csv.CsvRow;
import cn.hutool.core.text.csv.CsvWriteConfig;
import cn.hutool.core.text.csv.CsvWriter;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;

public class Csv2Leg {
  static String[][] READ = {
    {"plain", cps("a,b,c\n1,2,3\n")},
    {"quoted_multiline", cps("a,\"b\nc\",d\n")},
    {"leading_blank_line", cps("\na,b\n")},
    {"trailing_crlf", cps("a,b\r\n")},
    {"crlf_only_sep", cps("a,b\r\nc,d\r\n")},
    {"skip_empty", cps("a,b\n\nc,d\n")},
    {"uneven", cps("a,b,c\n1,2\n")},
    {"empty_text", cps("")},
    {"only_newlines", cps("\n\n")},
  };

  public static void main(String[] a) throws Exception {
    String g1 = dump(READ[0][1], false, false);
    String g2 = dump(READ[6][1], false, true);
    String g3 = wr("x,y");
    System.out.println("G|guard|" + g1 + "|" + g2 + "|" + g3);
    if (g1.equals(g2) || g1.equals(g3) || g2.equals(g3)) {
      System.out.println("G|GUARD_BAD|not_distinct");
    } else {
      System.out.println("G|GUARD_OK|distinct3");
    }
    for (String[] r : READ) {
      System.out.println("RD|" + r[0] + "|" + r[1] + "|" + dump(r[1], false, false));
      System.out.println("RS|" + r[0] + "|" + r[1] + "|" + dump(r[1], true, false));
    }
    // 越界档：参照抛，本库给 None ⇒ 读数只作对照，不同形
    for (int i = 0; i < 2; i++) {
      System.out.println("OOB|" + READ[i][0] + "|" + READ[i][1] + "|" + oob(READ[i][1]));
    }
    System.out.println("WR|w_simple|" + wr("x,y"));
    System.out.println("WRQ|w_quote|" + wr(new String(Character.toChars(0x22)) + "q,d"));
    System.out.println("WRE|w_empty|");
  }

  static String cps(String s) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < s.length(); i++) {
      if (sb.length() > 0) sb.append("+");
      sb.append(Integer.toHexString(s.charAt(i)));
    }
    return sb.toString();
  }

  static String fromCps(String s) {
    StringBuilder sb = new StringBuilder();
    for (String h : s.split("\\+")) sb.append((char) Integer.parseInt(h, 16));
    return sb.toString();
  }

  static String dump(String ctext, boolean skipEmpty, boolean errorOnDiff) {
    try {
      CsvReadConfig cfg = CsvReadConfig.defaultConfig();
      cfg.setContainsHeader(false);
      cfg.setSkipEmptyRows(skipEmpty);
      cfg.setErrorOnDifferentFieldCount(errorOnDiff);
      CsvReader reader = new CsvReader(new StringReader(fromCps(ctext)), cfg);
      CsvData data = reader.read();
      StringBuilder sb = new StringBuilder();
      sb.append("rows=").append(data.getRowCount());
      for (int i = 0; i < data.getRowCount(); i++) {
        CsvRow row = data.getRow(i);
        sb.append(" | r").append(i).append(" n=").append(row.getFieldCount()).append(" [");
        for (int j = 0; j < row.getFieldCount(); j++) {
          if (j > 0) sb.append(",");
          sb.append(ascii(row.get(j)));
        }
        sb.append("]");
      }
      return sb.toString();
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String oob(String ctext) {
    try {
      CsvData data = new CsvReader(new StringReader(fromCps(ctext)), CsvReadConfig.defaultConfig()).read();
      int n = data.getRowCount();
      return "row[-1]=" + safe(data, -1) + " row[n]=" + safe(data, n)
          + " field[-1]=" + safeField(data.getRow(0), -1)
          + " field[n]=" + safeField(data.getRow(0), data.getRow(0).getFieldCount());
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String safe(CsvData d, int i) {
    try {
      CsvRow r = d.getRow(i);
      return r == null ? "null" : "ok";
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String safeGet(CsvRow r, int i) {
    return r.get(i);
  }

  static String safeField(CsvRow r, int i) {
    try {
      return String.valueOf(safeGet(r,i));
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  // 默认写出档：参照的写出器只落文件，所以写进临时文件再整串读回（腿侧 IO，不进本库）
  // 默认写出档：用 StringWriter 接住，读数行不留裸换行
  static String wr(String line) {
    try {
      java.io.StringWriter sw = new java.io.StringWriter();
      CsvWriter writer = new CsvWriter(sw, new CsvWriteConfig());
      writer.write(line.split(","));
      writer.close();
      return ascii(sw.toString());
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String ascii(String s) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < s.length(); i++) {
      char c = s.charAt(i);
      if (c == '\r') sb.append("{CR}");
      else if (c == '\n') sb.append("{LF}");
      else if (c == '"') sb.append("{DQ}");
      else if (c < 0x20 || c > 0x7e) sb.append("{u").append(Integer.toHexString(c)).append("}");
      else sb.append(c);
    }
    return sb.toString().replace("|", "{bar}");
  }
}
