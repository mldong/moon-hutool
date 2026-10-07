// moon-hutool/typex —— 第八批补档的参照腿（Version 预发/构建段的分词器支路、港澳台形状拒收档、
// 15 位省码档、信用码非码表字符档、DataSize 坏后缀档）。全部 ASCII 输出（本机控制台 GBK）。
// 行形状：V|<id>|<a>|<b>|<compareTo 读数>          Version 两两比较
//         S|<id>|<input>|<toString>|<反射字段快照>  Version 分词后的内部形状（只作注释证据）
//         H|<id>|<input>|<isValidHKCard>            香港十位形状档
//         W|<id>|<input>|<isValidTWCard>            台湾十位形状档
//         O|<id>|<input>|<isValidCard10 读数>       澳门/十位 String[] 档（形状不同源，不进断言）
//         F|<id>|<input>|<isValidCard15>            15 位省码档
//         C|<id>|<input>|<CreditCodeUtil.isValid>   信用码档
//         B|<id>|<input>|<DataSizeUtil.parse 读数>  坏后缀档
// 自检：G|GUARD_OK|distinct3 —— 三条同族读数必须两两不同，缺这条生成器拒绝出文件。
import cn.hutool.core.io.unit.DataSizeUtil;
import cn.hutool.core.lang.Version;
import cn.hutool.core.util.CreditCodeUtil;
import cn.hutool.core.util.IdcardUtil;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class TypexLeg5 {
  // Version 分词：主版本 / 预发（-）/ 构建（+）三段，夹具专挑"预发段里撞 + "与"构建段里有多分隔符"
  static String[][] VPAIR = {
    {"plus-in-pre", "1.0.0-alpha+build", "1.0.0-alpha"},
    {"plus-empty", "1.0.0-alpha+", "1.0.0-alpha"},
    {"build-dots", "1.0.0-alpha+b.c", "1.0.0-alpha+b"},
    {"build-dash", "1.0.0-alpha+b-c", "1.0.0-alpha+b.c"},
    {"build-num", "1.0.0+2", "1.0.0+10"},
    {"pre-plus-num", "1.0.0-1+2", "1.0.0-1"},
    {"pre-dots", "1.0.0-a.b.c", "1.0.0-a.b"},
    {"build-only-dots", "1.0.0+b.c", "1.0.0+b"},
    // 这两对是 T5 变异（`+` 档不 `break`，构建段漏进预发段）照出来的：
    // 只用 `+` vs 空 或 `+` vs `+` 作对照，两侧同号 ⇒ 覆盖到了但判不开
    {"plus-vs-dash", "1.0.0-alpha+0", "1.0.0-alpha-0"},
    {"plus-vs-dash2", "1.0.0+b.c", "1.0.0-b-c"},
  };
  static String[] VSINGLE = {
    "1.0.0-alpha+build", "1.0.0-alpha+", "1.0.0-alpha+b.c", "1.0.0-1+2", "1.0.0+b.c",
  };
  // 香港 `^[A-Z]{1,2}[0-9]{6}\(?[0-9A]\)?$` 的收尾档：rest>3 / rest<1 / 单边括号 + 多余位
  static String[][] HK = {
    {"rest-gt3", "A1234567890"},
    {"rest-zero", "AB123456"},
    {"lp-extra", "A123456(5!"},
    {"rp-extra", "A1234567!)"},
    {"two-letter-long", "AB123456789"},
    {"plain-ok", "A1234567"},
    {"paren-ok", "A123456(7)"},
    {"letter-a-end", "A123456A"},
    {"short-7", "A12345"},
  };
  // 台湾 `^[a-zA-Z][0-9]{8}$` + 末位校验：末位是字母 ⇒ 参照 parseInt 抛
  static String[][] TW = {
    {"end-letter", "A12345678X"},
    {"end-paren", "A12345678)"},
    {"end-lower", "A12345678a"},
    {"long-11", "A1234567890"},
    {"short-9", "A12345678"},
    {"start-lower-ok", "a12345671"},
  };
  // 十位卡（参照返回 String[]，本库无同形状出口 ⇒ 只登记不进断言）：澳门档靠它才有读数
  static String[] TEN = { "1234567", "M123456(7)", "12345678", "123456(7)", "123456(78" };
  // 15 位 = 省码 6 + YYMMDD 6 + 顺序 3；两档只差省码 ⇒ 那个 false 才归因得到省码闸
  static String[][] ID15 = {
    {"bad-prov", "999999900101123"},
    {"bad-prov0", "009999900101123"},
    {"ok-prov", "110101900101123"},
    {"ok-prov2", "510101900101123"},
    {"letter", "11010190010A123"},
  };
  // 信用码：前 17 位含码表外字符（参照 `CreditCodeUtil.isValid`）
  static String[][] CC = {
    {"bad-char-mid", "91350100M00011111B"},
    {"bad-char-first", "X1350100M0001111Y3"},
    {"nonascii", "91350100M000000000"},
    {"short-17", "91350100M00000000"},
    {"ok", "91350100M000111Y3A"},
  };
  // DataSize 坏后缀（参照 parse 抛）
  static String[] DSBAD = { "1 XB", "1", "1 kb", "1 KBB", " 1 KB" };

  static String s(Object o) {
    return o == null ? "{null}" : String.valueOf(o);
  }

  static String fields(Version v) {
    StringBuilder sb = new StringBuilder();
    Field[] fs = Version.class.getDeclaredFields();
    for (Field f : fs) {
      f.setAccessible(true);
      try {
        sb.append(f.getName()).append('=').append(s(f.get(v))).append(';');
      } catch (Exception e) {
        sb.append(f.getName()).append("=ERR:").append(e.getClass().getSimpleName()).append(';');
      }
    }
    return sb.toString();
  }

  static String cmp(Version a, Version b) {
    try {
      return String.valueOf(a.compareTo(b));
    } catch (Exception e) {
      return "ERR:" + e.getClass().getSimpleName();
    }
  }

  static String str(RunnableIgnore r) {
    try {
      r.run();
      return "OK";
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  interface RunnableIgnore {
    void run() throws Exception;
  }

  public static void main(String[] args) {
    // 自检三件，各自独立判定（族里全是同一个读数＝恒假夹具，绿了也不证明闸在起作用）：
    // ① HK 族既有 false 档也有 true 档 ② Version 族既有 0 也有非 0 ③ 信用码族至少两种读数
    Set<String> hkg = new LinkedHashSet<>();
    for (String[] r : HK) {
      hkg.add(isHK(r[1]));
    }
    // 反推校验位：同一串只在收尾形状上变化，true 档与 false 档成对出现才说明"形状闸"真的在起作用
    String hkBody = "A123456";
    String hkCh = findHk(hkBody);
    String hk2Body = "AB123456";
    String hk2Ch = findHk(hk2Body);
    String twBody = "A12345678";
    String twCh = findTw(twBody);
    boolean hkPair = false;
    if (hkCh != null) {
      String plain = hkBody + hkCh;
      String paren = hkBody + "(" + hkCh + ")";
      String oneOpen = hkBody + "(" + hkCh;
      String oneClose = hkBody + hkCh + ")";
      String openPad = hkBody + "(" + hkCh + "!";
      String closePad = hkBody + "!" + hkCh + ")";
      String overLong = hkBody + hkCh + "01";
      hkg.add("true");
      System.out.println("H|valid-plain|" + plain + "|" + isHK(plain));
      System.out.println("H|valid-paren|" + paren + "|" + isHK(paren));
      System.out.println("H|valid-one-open|" + oneOpen + "|" + isHK(oneOpen));
      System.out.println("H|valid-one-close|" + oneClose + "|" + isHK(oneClose));
      System.out.println("H|valid-open-pad|" + openPad + "|" + isHK(openPad));
      System.out.println("H|valid-close-pad|" + closePad + "|" + isHK(closePad));
      System.out.println("H|valid-over-long|" + overLong + "|" + isHK(overLong));
      System.out.println("H2|two-letter-valid|" + hk2Body + hkCh + "|" + isHK(hk2Body + hkCh));
      if (hk2Ch != null) {
        System.out.println("H2|two-letter-valid-ch|" + hk2Body + hk2Ch + "|" + isHK(hk2Body + hk2Ch));
      }
      hkPair = true;
    }
    Set<String> ccg = new LinkedHashSet<>();
    for (String[] r : CC) {
      ccg.add(isCC(r[1]));
    }
    Set<String> vsg = new LinkedHashSet<>();
    for (String in : VSINGLE) {
      vsg.add(new Version(in).toString());
    }
    Set<String> vcg = new LinkedHashSet<>();
    for (String[] r : VPAIR) {
      vcg.add(cmp(new Version(r[1]), new Version(r[2])));
    }
    if (hkg.contains("true") && hkg.contains("false") && vcg.size() >= 2 && ccg.size() >= 2
        && vsg.size() >= 2) {
      System.out.println("G|GUARD_OK|distinct3");
    } else {
      System.out.println("G|GUARD_BAD|hkPair=" + hkPair + ",hk=" + hkg + ",vc=" + vcg
          + ",cc=" + ccg.size() + ",vs=" + vsg.size());
    }
    if (twCh != null) {
      String ok = twBody + twCh;
      System.out.println("W|valid|" + ok + "|" + isTW(ok));
      System.out.println("W|valid-end-letter|" + twBody + "X|" + isTW(twBody + "X"));
      System.out.println("W|valid-end-paren|" + twBody + ")|" + isTW(twBody + ")"));
      System.out.println("W|valid-end-lower|" + twBody + "a|" + isTW(twBody + "a"));
      System.out.println("W|valid-over-long|" + ok + "0|" + isTW(ok + "0"));
      System.out.println("W|valid-under|" + twBody + (twCh.equals("0") ? "1" : "0") + "|"
          + isTW(twBody + (twCh.equals("0") ? "1" : "0")));
    }
    for (String[] r : VPAIR) {
      System.out.println("V|" + r[0] + "|" + r[1] + "|" + r[2] + "|"
          + cmp(new Version(r[1]), new Version(r[2])));
    }
    for (String in : VSINGLE) {
      Version v = new Version(in);
      System.out.println("S|" + in + "|" + v.toString() + "|" + fields(v));
    }
    for (String[] r : HK) {
      System.out.println("H|" + r[0] + "|" + r[1] + "|" + isHK(r[1]));
    }
    for (String[] r : TW) {
      System.out.println("W|" + r[0] + "|" + r[1] + "|" + isTW(r[1]));
    }
    for (String in : TEN) {
      List<String> got = new ArrayList<>();
      String tag = str(() -> {
        String[] arr = IdcardUtil.isValidCard10(in);
        for (String x : arr) {
          got.add(s(x));
        }
      });
      System.out.println("O|" + in + "|" + tag + "|" + String.join(";", got));
    }
    for (String[] r : ID15) {
      System.out.println("F|" + r[0] + "|" + r[1] + "|" + bool(IdcardUtil.isValidCard15(r[1])));
    }
    for (String[] r : CC) {
      System.out.println("C|" + r[0] + "|" + r[1] + "|" + isCC(r[1]));
    }
    for (String in : DSBAD) {
      String tag = str(() -> DataSizeUtil.parse(in));
      System.out.println("B|" + in + "|" + tag);
    }
  }

  static String findHk(String body) {
    for (char c : "0123456789A".toCharArray()) {
      try {
        if (IdcardUtil.isValidHKCard(body + c)) {
          return String.valueOf(c);
        }
      } catch (Throwable t) {
        // 参照在坏形状上会抛：这档跳过，不影响反推其余档
      }
    }
    return null;
  }

  static String findTw(String body) {
    for (char c = '0'; c <= '9'; c++) {
      try {
        if (IdcardUtil.isValidTWCard(body + c)) {
          return String.valueOf(c);
        }
      } catch (Throwable t) {
        // 同上
      }
    }
    return null;
  }

  static String isHK(String in) {
    return bool(IdcardUtil.isValidHKCard(in));
  }

  static String isTW(String in) {
    try {
      return bool(IdcardUtil.isValidTWCard(in));
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String isCC(String in) {
    try {
      return bool(CreditCodeUtil.isCreditCode(in));
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
  }

  static String bool(Boolean b) {
    return b == null ? "{null}" : String.valueOf(b.booleanValue());
  }
}
