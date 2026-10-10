// moon-hutool/date 批② —— 计时四件的**确定档**腿（TimerLeg / TimerLeg2 的第三条姊妹）。
//
// 前两条腿一条掩数字、一条保宽度，都还剩一件事没办：把"参照自己算了几位、什么单位、
// 补不补零、怎么舍入"钉成**与时钟无关**的真读数。计时件的输出里唯一能冻的全在这：
//   ① `DateUtil.getShotName(TimeUnit)` —— 七个单位各给一个短名，常量；
//   ② `prettyPrint` 用的那两个 `java.text.NumberFormat`（数字档最小 9 位、百分号档最小 2 位）
//      —— 直接喂**选定的 double/long** 取读数，比从 prettyPrint 里倒推干净，
//      顺带把舍入模式、小数位上限、NaN/无穷（总时长为 0 时真会算出 NaN）全打出来；
//   ③ 列间空格与分隔行长度 —— 用 shape()（数字→D、空格→·）读，与时钟值无关；
//   ④ 行分隔符（`FileUtil.getLineSeparator()`，Windows 上是 CRLF —— 这条必须现读不能猜）；
//   ⑤ `intervalPretty` 唯一依赖的纯函数 `DateUtil.formatBetween(long)` —— 语料全确定，
//      五个 Level 各打一遍，好判断一参版到底走哪一档；
//   ⑥ `GlobalCustomFormat` 的两档内置表与 put/isCustom/format/parse 联动 —— 全是确定值。
//
// 跑法：
//   javac -encoding UTF-8 -cp hutool-all-5.8.37.jar -d . TimerLeg3.java
//   java  -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -cp hutool-all-5.8.37.jar;. TimerLeg3
//
// ⚠ 本腿第二条要单独打一遍：**prettyPrint 是跟宿主 locale 走的**，默认 locale 一档只是三档之一。
//   复跑（同一条腿换 locale 再跑，第一行 LOCALE 就是当次默认区）：
//     java -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -Duser.language=th -Duser.country=TH \
//          -cp hutool-all-5.8.37.jar;. TimerLeg3 | grep -E '^(LOCALE|NF\|12345|PC\|0.5|PP\|one-task-nanos)'
//   10-10 三档实测（zh_CN / th_TH / ar_SA / de_DE 四打）：
//     zh_CN、th_TH、de_DE 的数字档都是 ASCII 零填充，ar_SA 给阿拉伯-印度数码 `{u0660}..`；
//     百分号档 zh/th 给 `50%`，de_DE 给 `50{u00a0}%`（% 前一个不换行空格），ar_SA 给 `{u0665}0{u066a}{u061c}`
//     （百分号本身换成 U+066A，尾后还挂一个 U+061C 方向标记）；
//     `shortSummary`/`toString` 三档都不变（它们走 `Long.toString` + `StrUtil.format`，不经 NumberFormat）。
//   ⇒ 契约只冻"默认 locale（zh_CN，与 root/en 同形）"那一档，另两档作为**参照行为记录**写进
//     spec §9.7 的差异声明：本库恒给 ASCII 那档，不跟随宿主 locale。
import cn.hutool.core.date.BetweenFormatter;
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.date.StopWatch;
import cn.hutool.core.date.format.GlobalCustomFormat;
import cn.hutool.core.io.FileUtil;
import java.text.NumberFormat;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

public class TimerLeg3 {

    static final TimeUnit[] UNITS = {
        TimeUnit.NANOSECONDS, TimeUnit.MICROSECONDS, TimeUnit.MILLISECONDS,
        TimeUnit.SECONDS, TimeUnit.MINUTES, TimeUnit.HOURS, TimeUnit.DAYS };

    /** 非 ASCII 一律换成 {uXXXX}，输出恒纯 ASCII（腿的落盘编码不靠运气）。 */
    static String esc(String s) {
        if (s == null) return "{null}";
        StringBuilder b = new StringBuilder();
        for (char c : s.toCharArray()) {
            if (c == '\n') b.append("\\n");
            else if (c == '\r') b.append("\\r");
            else if (c == '\t') b.append("\\t");
            else if (c >= ' ' && c < 0x7f) b.append(c);
            else b.append(String.format("{u%04x}", (int) c));
        }
        return b.toString();
    }

    /** 形状档：数字→D、空格→·，其余原样。列宽与时钟值就此解耦。 */
    static String shape(String s) {
        StringBuilder b = new StringBuilder();
        for (char c : s.toCharArray()) {
            if (c >= '0' && c <= '9') b.append('D');
            else if (c == ' ') b.append('·');
            else if (c == '\n') b.append("\\n");
            else if (c == '\r') b.append("\\r");
            else b.append(c);
        }
        return b.toString();
    }

    static void line(String tag, String key, String v) {
        System.out.println(tag + "|" + key + "||" + v);
    }

    static String call(C c) {
        try {
            return c.get();
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getSimpleName() + ":" + esc(t.getMessage());
        }
    }

    interface C {
        String get() throws Exception;
    }

    public static void main(String[] args) throws Exception {
        System.out.println("LOCALE||" + Locale.getDefault());

        // ---- ① getShotName ----
        for (TimeUnit u : UNITS) {
            line("SH", u.name(), esc(call(() -> DateUtil.getShotName(u))));
        }
        line("SH", "null-unit", esc(call(() -> DateUtil.getShotName(null))));

        // ---- ④ 行分隔符 ----
        line("LS", "FileUtil.getLineSeparator", esc(FileUtil.getLineSeparator()));
        line("LS", "System.lineSeparator", esc(System.lineSeparator()));

        // ---- ② 数字档：minIntegerDigits=9、grouping off（与 prettyPrint 里那两行字节码同参数） ----
        NumberFormat num = NumberFormat.getNumberInstance();
        num.setMinimumIntegerDigits(9);
        num.setGroupingUsed(false);
        line("NF", "meta", "minFrac=" + num.getMinimumFractionDigits()
                + " maxFrac=" + num.getMaximumFractionDigits()
                + " round=" + num.getRoundingMode()
                + " maxInt=" + num.getMaximumIntegerDigits());
        long[] NV = { 0L, 1L, 5L, 99L, 12345L, 99999999L, 100000000L, 999999999L,
                1000000000L, 1234567890L, -1L, -12345L };
        for (long v : NV) {
            line("NF", String.valueOf(v), esc(num.format(v)));
        }

        // ---- ② 百分号档：minIntegerDigits=2、grouping off；喂选定比值，舍入与 NaN 全打出来 ----
        NumberFormat pct = NumberFormat.getPercentInstance();
        pct.setMinimumIntegerDigits(2);
        pct.setGroupingUsed(false);
        line("PC", "meta", "minFrac=" + pct.getMinimumFractionDigits()
                + " maxFrac=" + pct.getMaximumFractionDigits()
                + " round=" + pct.getRoundingMode());
        double[] PV = { 0.0, 0.0001, 0.004, 0.005, 0.006, 0.0099, 0.01, 0.015, 0.025,
                0.05, 0.0999, 0.1, 0.15, 0.25, 0.3333, 0.5, 0.55, 0.75, 0.99, 0.999,
                1.0, 1.5, 2.0, 1.0 / 3.0, 2.0 / 3.0, Double.NaN,
                Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY, -0.5, -0.0 };
        for (double v : PV) {
            line("PC", String.valueOf(v), esc(pct.format(v)));
        }
        // 总时长为 0 那一档真的会算出 0.0/0.0：把它经 Sw 走一遍看整行形状
        StopWatch zero = new StopWatch("zero");
        zero.start("z");
        zero.stop();
        line("PC", "zero-total-pretty(不可复现档)", shape(zero.prettyPrint())
                .replace('\n', '|').replace("\r|", "|"));

        // ---- ③ prettyPrint / shortSummary / toString 的列宽（shape 与时钟解耦） ----
        StopWatch sw = new StopWatch("pp");
        sw.start("alpha");
        sw.stop();
        line("PP", "one-task-nanos", shape(sw.prettyPrint()).replace("\r\n", "\\n"));
        line("PP", "one-task-seconds", shape(sw.prettyPrint(TimeUnit.SECONDS)).replace("\r\n", "\\n"));
        line("PP", "one-task-days", shape(sw.prettyPrint(TimeUnit.DAYS)).replace("\r\n", "\\n"));
        line("PP", "shortSummary", shape(sw.shortSummary()).replace("\r\n", "\\n"));
        line("PP", "shortSummary-DE", shape(sw.shortSummary(TimeUnit.DAYS)).replace("\r\n", "\\n"));
        line("PP", "toString", shape(sw.toString()));
        sw.start("b");
        sw.stop();
        sw.start("名字里带空格的 那一个");
        sw.stop();
        line("PP", "three-task", shape(sw.prettyPrint()).replace("\r\n", "\\n"));
        StopWatch nn = new StopWatch("nn");
        nn.start();
        nn.stop();
        line("PP", "unnamed", shape(nn.prettyPrint()).replace("\r\n", "\\n"));
        StopWatch none = new StopWatch("none");
        line("PP", "no-task", shape(none.prettyPrint()).replace("\r\n", "\\n"));
        line("PP", "no-task-toString", shape(none.toString()));
        StopWatch nk = new StopWatch("nk", false);
        nk.start("t");
        nk.stop();
        line("PP", "keep=false-pretty", shape(nk.prettyPrint()).replace("\r\n", "\\n"));
        line("PP", "keep=false-toString", shape(nk.toString()));
        nk.setKeepTaskList(true);
        line("PP", "keep-翻true后-pretty", shape(nk.prettyPrint()).replace("\r\n", "\\n"));
        line("PP", "dash-len", String.valueOf(
                none.prettyPrint().split("\r\n")[1].length()));
        line("PP", "header-seg", shape(none.prettyPrint().split("\r\n")[2]));

        // ---- ⑤ formatBetween：一参版走哪个 Level，五个 Level 并排照出来 ----
        long[] BV = { 0L, 1L, 999L, 1000L, 1001L, 1500L, 59_000L, 60_000L, 61_000L,
                3_540_000L, 3_600_000L, 3_600_001L, 7_260_000L, 86_399_999L, 86_400_000L,
                90_061_000L, 604_800_000L, 604_801_000L, 8_640_000_000L, -1L, -1000L,
                -86_400_000L, Long.MAX_VALUE };
        for (long v : BV) {
            StringBuilder b = new StringBuilder();
            b.append(esc(call(() -> DateUtil.formatBetween(v))));
            for (BetweenFormatter.Level lv : BetweenFormatter.Level.values()) {
                b.append(" ~ ").append(lv.name()).append('=')
                        .append(esc(call(() -> DateUtil.formatBetween(v, lv))));
            }
            line("FB", String.valueOf(v), b.toString());
        }
        for (BetweenFormatter.Level lv : BetweenFormatter.Level.values()) {
            line("FB", "level-name-" + lv.name(), esc(lv.getName()));
        }
        line("FB", "negative-doc", esc(call(() -> DateUtil.formatBetween(-1L))));

        // ---- ⑥ GlobalCustomFormat：常量、两档内置表、put 联动、parse 的异常臂 ----
        line("GF", "FORMAT_SECONDS", esc(GlobalCustomFormat.FORMAT_SECONDS));
        line("GF", "FORMAT_MILLISECONDS", esc(GlobalCustomFormat.FORMAT_MILLISECONDS));
        String[] keys = { "#sss", "#SSS", "#sss ", " #sss", "#ss", "#SS", "sss", "", "#SSSS" };
        for (String k : keys) {
            line("GF", "isCustom[" + esc(k) + "]", esc(call(() ->
                    String.valueOf(GlobalCustomFormat.isCustomFormat(k)))));
        }
        line("GF", "isCustom[null]", esc(call(() ->
                String.valueOf(GlobalCustomFormat.isCustomFormat(null)))));
        Date d = new Date(1700000000123L);
        line("GF", "format(d,#sss)", esc(call(() -> GlobalCustomFormat.format(d, "#sss"))));
        line("GF", "format(d,#SSS)", esc(call(() -> GlobalCustomFormat.format(d, "#SSS"))));
        line("GF", "format(d,plain)", esc(call(() -> GlobalCustomFormat.format(d, "yyyy"))));
        line("GF", "format(d,null-pattern)", esc(call(() -> GlobalCustomFormat.format(d, null))));
        line("GF", "format(null,#SSS)", esc(call(() -> GlobalCustomFormat.format((Date) null, "#SSS"))));
        line("GF", "format(Future,#SSS)", esc(call(() ->
                GlobalCustomFormat.format(java.time.LocalDate.of(2023, 11, 15), "#SSS"))));
        line("GF", "format(LocalTime,#sss)", esc(call(() ->
                GlobalCustomFormat.format(java.time.LocalTime.of(1, 2, 3), "#sss"))));
        String[] inputs = { "1700000000", "1700000000123", "0", "-1", "1.5", "", "abc",
                "99999999999999999999", " 1700000000", "1700000000 ", "+1700000000" };
        for (String s : inputs) {
            line("GF", "parse(" + esc(s) + ",#sss)", esc(call(() -> {
                Date r = GlobalCustomFormat.parse(s, "#sss");
                return r == null ? "{null}" : String.valueOf(r.getTime());
            })));
            line("GF", "parse(" + esc(s) + ",#SSS)", esc(call(() -> {
                Date r = GlobalCustomFormat.parse(s, "#SSS");
                return r == null ? "{null}" : String.valueOf(r.getTime());
            })));
        }
        line("GF", "parse(x,plain)", esc(call(() -> {
            Date r = GlobalCustomFormat.parse("2023", "yyyy");
            return r == null ? "{null}" : String.valueOf(r.getTime());
        })));
        line("GF", "parse(x,null-pattern)", esc(call(() -> {
            Date r = GlobalCustomFormat.parse("2023", null);
            return r == null ? "{null}" : String.valueOf(r.getTime());
        })));
        line("GF", "parse(null,#sss)", esc(call(() -> {
            Date r = GlobalCustomFormat.parse(null, "#sss");
            return r == null ? "{null}" : String.valueOf(r.getTime());
        })));
        // 覆盖内置键：putFormatter 对 "#sss" 再登记一次，改的是**共享表**（后面 DateUtil.format 立刻变）
        line("GF", "override-#sss-before", esc(call(() ->
                DateUtil.format(d, GlobalCustomFormat.FORMAT_SECONDS))));
        GlobalCustomFormat.putFormatter(GlobalCustomFormat.FORMAT_SECONDS, x -> "O" + x.getTime());
        line("GF", "override-#sss-after", esc(call(() ->
                DateUtil.format(d, GlobalCustomFormat.FORMAT_SECONDS))));
        GlobalCustomFormat.putFormatter(GlobalCustomFormat.FORMAT_SECONDS,
                x -> String.valueOf(x.getTime() / 1000L));
        line("GF", "override-#sss-还原", esc(call(() ->
                DateUtil.format(d, GlobalCustomFormat.FORMAT_SECONDS))));
        // 大小写不敏感？pattern 里有 # 才是自定义档
        GlobalCustomFormat.putFormatter("#MiX", x -> "mix");
        line("GF", "put(#MiX)-isCustom[#mix]", esc(call(() ->
                String.valueOf(GlobalCustomFormat.isCustomFormat("#mix")))));
        line("GF", "put(#MiX)-DateUtil.format", esc(call(() -> DateUtil.format(d, "#MiX"))));
        // parser 只 put 一半：有 formatter 无 parser 时 DateUtil.parse 给什么
        GlobalCustomFormat.putFormatter("#half", x -> "H");
        line("GF", "half-parse", esc(call(() -> {
            Date r = DateUtil.parse("H", "#half");
            return r == null ? "{null}" : String.valueOf(r.getTime());
        })));
        line("GF", "half-isCustom", esc(call(() ->
                String.valueOf(GlobalCustomFormat.isCustomFormat("#half")))));
        line("GF", "DateUtil.parse返回null时", esc(call(() -> {
            try {
                Date r = DateUtil.parse("H", "#half");
                return r == null ? "null" : String.valueOf(r.getTime());
            } catch (Exception e) {
                return "ERR:" + e.getClass().getSimpleName() + ":" + esc(e.getMessage());
            }
        })));
        // 注册在 DateUtil 那侧会不会污染普通 pattern（用例要的是"注册后普通档不变"这条回归）
        line("GF", "plain-after-custom", esc(call(() -> DateUtil.format(d, "yyyy-MM-dd"))));
    }
}
