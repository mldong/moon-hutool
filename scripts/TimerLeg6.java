// moon-hutool/date 批② —— 第六条腿：`Math.round` 那一族与百分号档的边界。
//
// 为什么还要一条：`toString()` 的百分号走 `Math.round(100.0 × n / total)`，此前唯一的凭据是
// 字节码里那一次 `invokestatic Math.round` 加 `SN|toString` 的一行形状——**平局档与饱和档都没有读数**。
// 这两档恰好是本批实现里最容易被"顺手统一"到 `NumberFormat` 那一族的地方（spec §9.3.11），
// 所以直接喂选定的 double 给 JDK，把七档取整 + 三档饱和 + 两档无穷打出来（全是纯函数，可复跑）。
//
// 同时补 `Long.parseLong` 的"只剩符号"与"非 ASCII 数字"两档（本包 parse_long 的错误臂此前没数）。
//
// 跑法：
//   javac -encoding UTF-8 -cp hutool-all-5.8.37.jar -d . TimerLeg6.java
//   java  -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -cp hutool-all-5.8.37.jar;. TimerLeg6
import java.text.NumberFormat;

public class TimerLeg6 {

    static String esc(String s) {
        if (s == null) return "{null}";
        StringBuilder b = new StringBuilder();
        for (char c : s.toCharArray()) {
            if (c >= ' ' && c < 0x7f) b.append(c);
            else b.append(String.format("{u%04x}", (int) c));
        }
        return b.toString();
    }

    public static void main(String[] args) {
        double[] RV = { 0.0, 0.4, 0.5, 0.6, 1.5, 2.5, 3.5, -0.5, -1.5, -2.5, -3.5,
                2.4999999999, 1.0e30, -1.0e30, Double.NaN, Double.POSITIVE_INFINITY,
                Double.NEGATIVE_INFINITY, 9223372036854775807.0, -9223372036854775808.0,
                0.49999999999999994, -2.4999999999, -0.4, 9.2E16, -9.2E16 };
        for (double v : RV) {
            System.out.println("JU|round|" + v + "||" + Math.round(v));
        }
        NumberFormat pct = NumberFormat.getPercentInstance();
        pct.setMinimumIntegerDigits(2);
        pct.setGroupingUsed(false);
        double[] PV = { 9.2e16, -9.2e16, 1.0e18, 0.004999999999999999, 1.0 - 1e-16 };
        for (double v : PV) {
            System.out.println("JU|pct|" + v + "||" + esc(pct.format(v)));
        }
        // 与参照件同一条路：GlobalCustomFormat.parse 在只剩符号 / 全角数字上的读数
        String[] P = { "+", "-", "1٣", "٣", "0x10", "010", "-0", "--1", "1 2", "1,2",
                "9223372036854775808", "-9223372036854775809", "9223372036854775807",
                "-9223372036854775808" };
        for (String s : P) {
            System.out.println("JU|parseLong|" + esc(s) + "||" + call(s));
            System.out.println("JU|GCF#sss|" + esc(s) + "||" + gcf(s));
        }
    }

    static String call(String s) {
        try {
            return String.valueOf(Long.parseLong(s));
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getSimpleName() + ":" + esc(t.getMessage());
        }
    }

    static String gcf(String s) {
        try {
            return String.valueOf(cn.hutool.core.date.format.GlobalCustomFormat
                    .parse(s, "#sss").getTime());
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getSimpleName() + ":" + esc(t.getMessage());
        }
    }
}
