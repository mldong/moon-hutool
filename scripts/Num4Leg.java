// moon-hutool/num —— 第四批（Calculator 表达式求值器）的参照腿
//
// 参照件：`cn.hutool.core.math.Calculator`（`hutool-core` 里，源码 6497 字节，现读全文）。
// 公开面只有两件：`static double conversion(String)` 与实例 `double calculate(String)`——
// 后者是前者的实现（`new Calculator().calculate(e)`），**没有可见状态**。
//
// 这条腿回答三件事，全部只出机器读数：
//   D 行：`calculate(表达式)` 的结果或异常——把 shunting-yard 那套（空白清理、`=` 后缀剥离、
//          负号记号 `~`、`x`/`X` 当 `*`、隐式乘法、`%` 优先级最高、`^` 根本不是运算符）逐格钉住；
//   C 行：`NumberUtil.add/sub/mul/div/remainder` 的两两读数——这一件决定"十进制精确算术用什么形状"，
//          特别是 **div 的默认 scale 与舍入**（源码走 `div(v1,v2)`，是不是 10 位 HALF_UP 要读出来）；
//   V 行：`conversion` 与实例 `calculate` 是否同值（两件收成一件的依据）。
//
// 用法（必须给 Windows 风格路径，分号分隔）：
//   javac -encoding UTF-8 -cp hutool-core.jar scripts/Num4Leg.java -d <cls>
//   java  -cp "<cls>;hutool-core.jar" Num4Leg > num4_leg.tsv
// 全部 ASCII 输出（本机控制台是 GBK）。
import cn.hutool.core.math.Calculator;
import cn.hutool.core.util.NumberUtil;
import java.math.BigDecimal;
import java.math.RoundingMode;

public class Num4Leg {
  // D 行夹具：每格一条表达式。分组的注释就是这一格要钉的构造，读数本身不含注释。
  static String[] EXPRS = {
      // 基本四则与优先级
      "5+12*(3+5)/7", "1+2*3", "(1+2)*3", "10-4-3", "10-(4-3)", "2*3+4*5", "1/2", "1/3", "2/3",
      "-1/3", "1/-3", "7%3", "-7%3", "7%-3", "10/4", "100/8",
      // scale 与精度：十进制精确在 double 出口上看得见的地方
      "0.1+0.2", "0.1*3", "1.005*100", "0.3-0.1", "2.675*100", "1/3*3", "0.1+0.1+0.1",
      "1e3", "1E3", "3E-2", "1.5e2+1", "1e-1", "0.0000001",
      // 一元负号与 ~ 记号
      "-5", "- 5", "--5", "-(-5)", "5--3", "5- -3", "-5+3", "(-5)", "-(1+2)", "~5",
      // x/X 当乘号（issue#3787）
      "2x3", "2X3", "0x10", "2x3x4",
      // 空白与 `=` 后缀
      " 1 + 2 ", "1 +2\t", "1+2=", "1+2=3", "=1+2", "1 2", "(1+2)(3)", "(1+2)3", "2(3)",
      // 括号失衡与坏形状
      "(1+2", "1+2)", "()", "(", ")", "((1+2)", "1+(2*3",
      // 空串与纯符号
      "", " ", "+", "+1", "*2", "/", "%2", "-", "=",
      // 非数字
      "abc", "1+abc", "一+二", "1..2", "1.2.3", "1e", "1e+", "07", "1,000", "1_000", "$5",
      // `^` 不是运算符（源码 isOperator 只有 + - * / ( ) %）
      "1^2", "2^3^2",
      // 长式与嵌套
      "((((1))))", "1+(2+(3+(4+(5+(6+(7+(8+(9+10)))))))))", "1*2*3*4*5*6*7*8*9*10",
      "1000000*1000000", "1/1000000", "9999999999999999999+1", "0.0000000001*10",
      // 大数与小结果
      "1e300+1e300", "1e308*10", "1e-320*10", "-1e308*10",
      // % 与括号混用
      "10%3*2", "2+10%3", "(10%3)*2", "1%0", "1/0", "0/0", "0%0",
  };

  static String esc(Object o) {
    String s = String.valueOf(o);
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

  static String guarded(Sup f) {
    try {
      return esc(f.run());
    } catch (Throwable e) {
      return "ERR_" + e.getClass().getSimpleName() + "|" + esc(e.getMessage());
    }
  }

  interface Sup {
    Object run() throws Exception;
  }

  public static void main(String[] a) {
    System.out.println("T\tJAVA\t" + System.getProperty("java.version"));
    System.out.println("T\tHUTOOL\tcore 5.8.35");
    // ---- D 行：Calculator.calculate ----
    for (final String e : EXPRS) {
      System.out.println("D\t" + esc(e) + "\t" + guarded(new Sup() {
        public Object run() {
          return new Calculator().calculate(e);
        }
      }));
      // 同一格的静态入口对照（V 行只在两者不同的时候才有信息量，这里逐格都记）
      System.out.println("V\t" + esc(e) + "\t" + guarded(new Sup() {
        public Object run() {
          return Calculator.conversion(e);
        }
      }));
    }
    // ---- C 行：十进制算术的形状（分步算子，直接问 NumberUtil）----
    String[][] pair = {
        { "0.1", "0.2" }, { "1.005", "100" }, { "2.675", "100" }, { "-7", "3" }, { "7", "-3" },
        { "1", "3" }, { "2", "3" }, { "-1", "3" }, { "1", "-3" }, { "10", "3" }, { "1", "0" },
        { "0", "0" }, { "5", "2" }, { "1", "7" }, { "0.1", "3" }, { "100", "8" }, { "1", "6" },
        { "123456789012345678901234567890", "3" }, { "1e10", "3" }, { "1", "1000000" },
    };
    for (String[] p : pair) {
      final String x = p[0], y = p[1];
      System.out.println("C\tadd\t" + esc(x) + "\t" + esc(y) + "\t" + guarded(new Sup() {
        public Object run() {
          return NumberUtil.add(x, y);
        }
      }));
      System.out.println("C\tsub\t" + esc(x) + "\t" + esc(y) + "\t" + guarded(new Sup() {
        public Object run() {
          return NumberUtil.sub(x, y);
        }
      }));
      System.out.println("C\tmul\t" + esc(x) + "\t" + esc(y) + "\t" + guarded(new Sup() {
        public Object run() {
          return NumberUtil.mul(x, y);
        }
      }));
      System.out.println("C\tdiv\t" + esc(x) + "\t" + esc(y) + "\t" + guarded(new Sup() {
        public Object run() {
          return NumberUtil.div(x, y);
        }
      }));
      System.out.println("C\trem\t" + esc(x) + "\t" + esc(y) + "\t" + guarded(new Sup() {
        public Object run() {
          return new BigDecimal(x).remainder(new BigDecimal(y));
        }
      }));
      // div 默认档到底是不是 scale=10 HALF_UP：同格并排给出显式档
      System.out.println("C\tdiv10halfup\t" + esc(x) + "\t" + esc(y) + "\t" + guarded(new Sup() {
        public Object run() {
          return new BigDecimal(x).divide(new BigDecimal(y), 10, RoundingMode.HALF_UP);
        }
      }));
      System.out.println("C\tdivfloor\t" + esc(x) + "\t" + esc(y) + "\t" + guarded(new Sup() {
        public Object run() {
          return new BigDecimal(x).divide(new BigDecimal(y), 10, RoundingMode.FLOOR);
        }
      }));
    }
    // ---- S 行：深度扫描与几条构造补齐（写契约前要知道崩在哪一层，别再"以为是深度"）----
    for (int k = 1; k <= 12; k++) {
      final StringBuilder sb = new StringBuilder();
      for (int i = 0; i < k; i++) {
        sb.append("1+(");
      }
      sb.append("2");
      for (int i = 0; i < k; i++) {
        sb.append(")");
      }
      final String expr = sb.toString();
      System.out.println("S\tdepth_" + k + "\t" + esc(expr) + "\t" + guarded(new Sup() {
        public Object run() {
          return new Calculator().calculate(expr);
        }
      }));
    }
    String[] MORE = {
        "1+(2+(3+(4+5)))", "1+(2+(3+(4+(5+6))))", "1+(2+(3+(4+(5+(6+7)))))",
        "1+(2+(3+(4+(5+(6+(7+8)))))))", "1+(2+(3+(4+(5+(6+(7+(8+9))))))))",
        "1+(2+(3+(4+(5+(6+(7+(8+(9+10)))))))))", "1+(2+(3+(4+(5+(6+(7+(8+(9+9)))))))))",
        "1+(2+(3+(4+(5+(6+(7+(8+(9+1)))))))))", "1+(2+(3+(4+(5+(6+(7+(8+(99+1)))))))))",
        "1+(2+(3+(4+(5+(6+(7+(8+(9+100)))))))))", "1+(2+(3+(4+(5+(6+(7+(8+(99+99)))))))))",
        "1+(2+(3+4))", "2*(3+(4+5))", "1+(2)", "((1)+2)", "1%3%2", "1--2", "2^-3", "1)-2",
        "1 = 2", "1+2 = ", "- 5+3", "1+-2", "1+*2", "1**2", "1//2", "5%", "%", "1%2", "()",
        "(())", "1+()", "0", "-0", "0.0", "1.0", "00.0", "0.1.0", ".5", "5.", "+.5", "-.5",
        "1e2", "1E-2", "1e+2", "1e2e2", "1,23", "1 . 2", "1..", "..1", "1e.5", "3e2%2",
        "2x", "x2", "1x", "1+x", "~", "~~5", "-~5", "99999999999999999999*2", "1/7", "1/11",
        "1/13", "0.00000000004+0", "1/3+1/3+1/3", "10=2", "1+2=3=4",
        // 操作数「最长可解析前缀」这一族在**计算器这一层**的读数（上面 F 行只到
        // `NumberUtil.add(t,"0")`，那是解析器层；本库发的是 `num_calculate`，契约必须钉在自己这件上）。
        // 大小写不对称（`1e2a` 与 `1E2a`）、后缀字母（`5f`/`5d`）、非 ASCII 数字、`Infinity`/`NaN`
        // 走的是参照自己的分支，全部现读。
        "5f", "5d", "1d", "1f", "1e2a", "1E2a", "1e23", "1E23", "12e3", "1e2.5", "1E2.5",
        "1e2e", "2e3e4", "1e2e3", "1E2e3", "1e2 ", "1E2X3", "0x1p3", "١٢", "Infinity", "NaN",
        "-Infinity", "NaN+1",
    };
    for (final String e : MORE) {
      System.out.println("S\tmore\t" + esc(e) + "\t" + guarded(new Sup() {
        public Object run() {
          return new Calculator().calculate(e);
        }
      }));
    }
    // ---- F 行：操作数解析器到底是哪种（NumberFormat 宽松档还是 BigDecimal）----
    // 后一半是"宽松前缀"的边界：`1e2e2` 这种"指数位后面又跟了垃圾"的读法必须实测，别按直觉定。
    String[] TOK = { "1e", "1_000", "1,000", "1,000,000", "1..2", "1.2.3", "07", ".5", "5.",
        "-5", "5f", "5d", "Infinity", "NaN", "0x1p3", "١٢", "1 2", " 1", "1 ", "e5", "1e-", "1E",
        "1e2a", "1e2.5", "1e2e", "2e3e4", "1e22e", "1e-2a", "1E2X3", "1.5e3e-1", "1e2 ",
        "0e0", "1e0a", "12e3", "-1e2a", "1e2,3", "1,e2", "1e2e2e2", "1E2a", "1E2 ", "1e23", "1E23", "1E2.5", "1E22E", "1e2E3",
        "1E2e3", "0E0", "1e2e2", "1_0", "1d", "1f", "1E2d", };
    for (final String t : TOK) {
      System.out.println("F\tnumutil_add\t" + esc(t) + "\t0\t" + guarded(new Sup() {
        public Object run() {
          return NumberUtil.add(t, "0");
        }
      }));
      System.out.println("F\tbcd_direct\t" + esc(t) + "\t0\t" + guarded(new Sup() {
        public Object run() {
          return new BigDecimal(t);
        }
      }));
      System.out.println("F\tis_number\t" + esc(t) + "\t0\t" + guarded(new Sup() {
        public Object run() {
          return NumberUtil.isNumber(t);
        }
      }));
    }
    // ---- N 行：多操作数与 scale 细节（Calculator 最后一步是 mul(数组)）----
    System.out.println("N\tmul_varargs_empty\t" + guarded(new Sup() {
      public Object run() {
        return NumberUtil.mul(new String[0]);
      }
    }));
    System.out.println("N\tmul_varargs_one\t" + guarded(new Sup() {
      public Object run() {
        return NumberUtil.mul(new String[] { "1.50" });
      }
    }));
    System.out.println("N\tmul_varargs_three\t" + guarded(new Sup() {
      public Object run() {
        return NumberUtil.mul(new String[] { "1.50", "2", "0" });
      }
    }));
    System.out.println("N\tdiv_default_scale\t" + guarded(new Sup() {
      public Object run() {
        return NumberUtil.div("1", "3", 20);
      }
    }));
    System.out.println("N\tadd_scale_from_string\t" + guarded(new Sup() {
      public Object run() {
        return NumberUtil.add("1.10", "2.20");
      }
    }));
    System.out.println("N\tto_bcd_sci\t" + guarded(new Sup() {
      public Object run() {
        return NumberUtil.toBigDecimal("3E-2");
      }
    }));
    System.out.println("N\tto_bcd_bad\t" + guarded(new Sup() {
      public Object run() {
        return NumberUtil.toBigDecimal("1e");
      }
    }));
    System.out.println("N\tto_bcd_under\t" + guarded(new Sup() {
      public Object run() {
        return NumberUtil.toBigDecimal("-");
      }
    }));
  }
}
