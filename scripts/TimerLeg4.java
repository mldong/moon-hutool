// moon-hutool/date 批② —— 计时四件的**第四条腿**：把前三条腿没打到的确定档补齐。
//
// 这里每一档都要求"与时钟无关"，所以能直接冻成真期望值：
//   · `TimeUnit.convert(n, NANOSECONDS)` 的整数截断表（正/负/零/溢出四档，纯算术）；
//   · `DateUtil.nanosToSeconds(n)`（除法走 double，专挑能精确表示的读数断言）；
//   · `TaskInfo` 的四个 getter —— 构造器是包级私有，用反射拿，于是能喂**选定纳秒数**；
//   · `sw.start(null)` 这条状态机暗档（参照判"在跑"靠 `currentTaskName != null`，
//     传 null 进去等于"什么都没开始"，后面整条链的行为都可确定）；
//   · `new StopWatch(null)` 的 `{}` 模板读数（`StrUtil.format` 把 null 打成字面 "null"）；
//   · `#sss`/`#SSS` 两档在**负 epoch** 与 0 上的截断方向。
//
// 跑法同前三条腿。
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.date.StopWatch;
import cn.hutool.core.date.format.GlobalCustomFormat;
import java.lang.reflect.Constructor;
import java.util.Date;
import java.util.concurrent.TimeUnit;

public class TimerLeg4 {

    static final TimeUnit[] UNITS = {
        TimeUnit.NANOSECONDS, TimeUnit.MICROSECONDS, TimeUnit.MILLISECONDS,
        TimeUnit.SECONDS, TimeUnit.MINUTES, TimeUnit.HOURS, TimeUnit.DAYS };

    static String esc(String s) {
        if (s == null) return "{null}";
        StringBuilder b = new StringBuilder();
        for (char c : s.toCharArray()) {
            if (c == '\n') b.append("\\n");
            else if (c == '\r') b.append("\\r");
            else if (c >= ' ' && c < 0x7f) b.append(c);
            else b.append(String.format("{u%04x}", (int) c));
        }
        return b.toString();
    }

    static void line(String tag, String key, String v) {
        System.out.println(tag + "|" + key + "||" + v);
    }

    interface C {
        String get() throws Exception;
    }

    static String call(C c) {
        try {
            return c.get();
        } catch (Throwable t) {
            Throwable r = t;
            if (t instanceof java.lang.reflect.InvocationTargetException) r = t.getCause();
            return "ERR:" + r.getClass().getSimpleName() + ":" + esc(r.getMessage());
        }
    }

    public static void main(String[] args) throws Exception {
        // ---- CU：TimeUnit.convert 的截断表（参照 getTotal/TaskInfo.getTime 全靠它） ----
        long[] NV = { 0L, 1L, 999L, 1000L, 1_000_000L, 999_999_999L, 1_000_000_000L,
                60_000_000_000L, 3_600_000_000_000L, 86_400_000_000_000L,
                604_800_000_000_000L, -1L, -999_999_999L, -1_000_000_000L,
                -86_400_000_000_000L, Long.MAX_VALUE, Long.MIN_VALUE };
        for (long n : NV) {
            StringBuilder b = new StringBuilder();
            for (TimeUnit u : UNITS) {
                b.append(u.name()).append('=').append(call(() ->
                        String.valueOf(u.convert(n, TimeUnit.NANOSECONDS)))).append(' ');
            }
            line("CU", String.valueOf(n), b.toString());
        }

        // ---- NS：nanosToSeconds（只挑能精确表示的档进契约） ----
        for (long n : NV) {
            line("NS", String.valueOf(n), esc(call(() -> String.valueOf(DateUtil.nanosToSeconds(n)))));
        }

        // ---- TI：TaskInfo 四个 getter（反射构造，喂选定纳秒） ----
        Constructor<?> tc = StopWatch.TaskInfo.class.getDeclaredConstructor(String.class, long.class);
        tc.setAccessible(true);
        for (long n : NV) {
            final Object ti = tc.newInstance("k", n);
            StringBuilder b = new StringBuilder();
            b.append("name=").append(call(() -> esc(((StopWatch.TaskInfo) ti).getTaskName())));
            for (TimeUnit u : UNITS) {
                b.append(' ').append(u.name()).append('=')
                        .append(call(() -> String.valueOf(((StopWatch.TaskInfo) ti).getTime(u))));
            }
            b.append(" ms=").append(call(() -> String.valueOf(((StopWatch.TaskInfo) ti).getTimeMillis())));
            b.append(" sec=").append(esc(call(() -> String.valueOf(((StopWatch.TaskInfo) ti).getTimeSeconds()))));
            b.append(" nanos=").append(call(() -> String.valueOf(((StopWatch.TaskInfo) ti).getTimeNanos())));
            line("TI", String.valueOf(n), b.toString());
        }

        // ---- SN：start(null) 这条暗档 ----
        StopWatch sn = new StopWatch("sn");
        line("SN", "start(null)之后isRunning", call(() -> String.valueOf(unsafe(sn))));
        sn.start(null);
        line("SN", "currentTaskName", esc(call(sn::currentTaskName)));
        line("SN", "isRunning", call(() -> String.valueOf(sn.isRunning())));
        line("SN", "stop之后", call(() -> {
            try {
                sn.stop();
                return "ok";
            } catch (Exception e) {
                return "ERR:" + e.getClass().getSimpleName() + ":" + esc(e.getMessage());
            }
        }));
        line("SN", "taskCount", call(() -> String.valueOf(sn.getTaskCount())));
        line("SN", "lastTaskName", call(sn::getLastTaskName));
        StopWatch sn2 = new StopWatch("sn2");
        sn2.start(null);
        sn2.start("real");
        line("SN", "null后再start(能进?)", call(() -> String.valueOf(sn2.isRunning())
                + "|" + esc(sn2.currentTaskName())));
        sn2.stop();
        line("SN", "toString", esc(sn2.toString()));
        line("SN", "prettyPrint", esc(sn2.prettyPrint().replace("\r\n", "\\n")));

        // ---- ID：id 为 null / 空 / 带引号 时 shortSummary 的 {} 模板读数 ----
        StopWatch nil = new StopWatch(null);
        line("ID", "null-id-summary", esc(nil.shortSummary()));
        line("ID", "null-id-toString", esc(nil.toString()));
        StopWatch q = new StopWatch("a'b{}c");
        line("ID", "怪id", esc(q.shortSummary()));
        line("ID", "create(id)", esc(call(() -> StopWatch.create("job").getId())));
        line("ID", "create(null)", esc(call(() -> StopWatch.create(null).getId())));
        StopWatch noargs = new StopWatch();
        line("ID", "无参id", esc(noargs.getId()));
        StopWatch keepFalse = new StopWatch("kf", false);
        line("ID", "keep=false的taskList档", call(() -> String.valueOf(keepFalse.getTaskCount())) + "|"
                + call(() -> String.valueOf(keepFalse.getTaskInfo().length)));
        keepFalse.setKeepTaskList(false);
        line("ID", "再set一次false", call(() -> {
            keepFalse.setKeepTaskList(false);
            return "ok";
        }));

        // ---- EP：#sss/#SSS 在负 epoch、0、极值上的截断方向 ----
        long[] EV = { 0L, 999L, 1000L, -1L, -999L, -1000L, -1001L, 1700000000123L,
                -1700000000123L, Long.MIN_VALUE, Long.MAX_VALUE };
        for (long e : EV) {
            final Date d = new Date(e);
            line("EP", String.valueOf(e),
                    call(() -> GlobalCustomFormat.format(d, GlobalCustomFormat.FORMAT_SECONDS))
                            + "|" + call(() -> GlobalCustomFormat.format(d, GlobalCustomFormat.FORMAT_MILLISECONDS))
                            + "|" + call(() -> DateUtil.format(d, "#sss")));
        }
        line("EP", "parse(-1500,#sss)", call(() -> {
            Date r = GlobalCustomFormat.parse("-1500", "#sss");
            return String.valueOf(r.getTime());
        }));
        line("EP", "parse(-1500,#SSS)", call(() -> String.valueOf(
                GlobalCustomFormat.parse("-1500", GlobalCustomFormat.FORMAT_MILLISECONDS).getTime())));
        line("EP", "DateUtil.parse(#sss)", call(() -> String.valueOf(
                DateUtil.parse("1700000000", "#sss").getTime())));
        line("EP", "LocalDateTimeUtil.parse(#sss)", call(() -> String.valueOf(
                cn.hutool.core.date.LocalDateTimeUtil.parse("1700000000", "#sss"))));
        line("EP", "LocalDateTimeUtil.parse(#SSS)", call(() -> String.valueOf(
                cn.hutool.core.date.LocalDateTimeUtil.parse("1700000000123", "#SSS"))));
        line("EP", "LocalDateTimeUtil.parse(plain)", call(() -> String.valueOf(
                cn.hutool.core.date.LocalDateTimeUtil.parse("2023-11-15", "yyyy-MM-dd"))));
    }

    static boolean unsafe(StopWatch s) {
        return s.isRunning();
    }
}
