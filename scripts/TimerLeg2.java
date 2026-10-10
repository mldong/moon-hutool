// moon-hutool/date —— 计时件的**形状宽度**与**零档**第二条腿（TimerLeg 的姊妹腿）。
//
// 为什么还要一条：TimerLeg 把数字掩成 `#`，那正好把两件必须钉的东西洗掉了——
//   ① `prettyPrint` 的列宽（`%10d`/`%5.0f`/`%-12s` 这类填充规则），
//   ② "没起点/未知键/清空之后"这些档到底给 0 还是抛。
// 所以这里改两种打法：宽度档用 `0` 逐位替换（保住长度，前导空格才看得见）；
// 零档一律打**原值**（这些本来就该是确定的 0，不是计时噪声——真不是 0 就是抛错，两种都算读数）。
import cn.hutool.core.date.StopWatch;
import cn.hutool.core.date.TimeInterval;
import cn.hutool.core.date.GroupTimeInterval;
import cn.hutool.core.date.DateUnit;

public class TimerLeg2 {

    /** 保长度的掩法：每位数字换成 0 ⇒ 前导空格与列宽看得见。 */
    static String w(String s) {
        if (s == null) return "{null}";
        StringBuilder b = new StringBuilder();
        for (char c : s.toCharArray()) {
            b.append(c >= '0' && c <= '9' ? '0' : c);
        }
        return b.toString();
    }

    public static void main(String[] args) {
        // ---- 零档（原值打出来）----
        TimeInterval ti = new TimeInterval();
        System.out.println("Z|Ti.interval@fresh|" + raw(ti::interval));
        System.out.println("Z|Ti.intervalMs@fresh|" + raw(ti::intervalMs));
        System.out.println("Z|Ti.intervalPretty@fresh|" + w(raws(ti::intervalPretty)));
        ti.start();
        System.out.println("Z|Ti.interval(key)@no-key|" + raw(() -> ti.interval("nope")));
        System.out.println("Z|Ti.intervalRestart@fresh|" + raw(ti::intervalRestart));
        GroupTimeInterval g = new GroupTimeInterval(true);
        System.out.println("Z|G.interval@empty|" + raw(() -> g.interval("k")));
        System.out.println("Z|G.intervalMs@empty|" + raw(() -> g.intervalMs("k")));
        g.start("k");
        long first = g.start("k");
        System.out.println("Z|G.start-again-is-long|" + (first >= 0) + "|" + (g.intervalMs("k") <= 1));
        g.clear();
        System.out.println("Z|G.interval-after-clear|" + raw(() -> g.interval("k")));
        System.out.println("Z|G.interval-unstarted|" + raw(() -> g.interval("x")));
        System.out.println("Z|G.interval-null-key|" + raw(() -> g.interval(null)));
        System.out.println("Z|G.interval-null-key-ms|" + raw(() -> g.intervalMs(null)));
        System.out.println("Z|G.interval-unit-null-key|" + raw(() -> g.interval(null, DateUnit.MS)));
        System.out.println("Z|G.intervalPretty-null|" + raws(() -> g.intervalPretty(null)));
        System.out.println("Z|G.interval-empty-key|" + raw(() -> g.interval("")));
        g.start("");
        System.out.println("Z|G.interval-empty-key-after-start|" + raw(() -> g.interval("")));
        // isMillis=false 那档到底改变了谁（同一批操作两边各打一次原值）
        GroupTimeInterval gm = new GroupTimeInterval(false);
        gm.start("a");
        TimeInterval tf = new TimeInterval(false);
        tf.start();
        TimeInterval tm = new TimeInterval(true);
        tm.start();
        System.out.println("Z|isMillis=false|interval|" + raw(tf::interval));
        System.out.println("Z|isMillis=true|interval|" + raw(tm::interval));
        System.out.println("Z|isMillis=false|intervalMs|" + raw(tf::intervalMs));
        System.out.println("Z|group-isMillis=false|interval|" + raw(() -> gm.interval("a")));

        // ---- 宽度档（0 掩码保长度）----
        StopWatch sw = new StopWatch("wid");
        sw.start("t1");
        sw.stop();
        System.out.println("P|shortSummary|" + w(safe(sw::shortSummary)).replace('\n', '|'));
        System.out.println("P|prettyPrint|" + w(safe(sw::prettyPrint)).replace('\n', '|'));
        System.out.println("P|prettyPrint-SECONDS|" + w(safe(() -> sw.prettyPrint(java.util.concurrent.TimeUnit.SECONDS))).replace('\n', '|'));
        System.out.println("P|prettyPrint-MINUTES|" + w(safe(() -> sw.prettyPrint(java.util.concurrent.TimeUnit.MINUTES))).replace('\n', '|'));
        System.out.println("P|toString|" + w(safe(sw::toString)).replace('\n', '|'));
        sw.start("任务名很长很长的那一个");
        sw.stop();
        System.out.println("P|prettyPrint-2|" + w(safe(sw::prettyPrint)).replace('\n', '|'));
        System.out.println("P|shortSummary-2|" + w(safe(sw::shortSummary)));
        StopWatch nested = new StopWatch("n");
        nested.start();
        nested.stop();
        System.out.println("P|prettyPrint-unnamed|" + w(safe(nested::prettyPrint)).replace('\n', '|'));
        System.out.println("P|dash-run-length|" + safe(() -> {
            String pp = nested.prettyPrint();
            for (String line : pp.split("\n")) {
                if (line.startsWith("---")) return String.valueOf(line.length());
            }
            return "无分隔行";
        }));
        System.out.println("P|header|" + safe(() -> {
            String pp = nested.prettyPrint();
            String[] ls = pp.split("\n");
            return ls.length + "|" + (ls.length > 1 ? "[" + ls[1] + "]" : "");
        }));
        // 计时单位换算的确定性档：getTotal(TimeUnit) 与三种 getter 的关系（掩掉值只比形状）
        System.out.println("P|totalSeconds-is-double|" + safe(() -> {
            double s = sw.getTotalTimeSeconds();
            return (s >= 0 ? "非负" : "负") + "|小数=" + (String.valueOf(s).contains("."));
        }));
        System.out.println("P|getTotal(nanos-vs-millis)|" + safe(() -> {
            long nanos = sw.getTotalTimeNanos();
            long ms = sw.getTotalTimeMillis();
            long byUnit = sw.getTotal(java.util.concurrent.TimeUnit.NANOSECONDS);
            return (nanos == byUnit) + "|" + (ms >= 0) + "|" + (nanos >= ms);
        }));
        System.out.println("P|lastTaskInfo-show|" + safe(() -> {
            StopWatch.TaskInfo t = sw.getLastTaskInfo();
            return t.getTaskName() + "|" + (t.getTimeMillis() >= 0) + "|" + (t.getTimeNanos() >= 0)
                    + "|" + (t.getTimeSeconds() >= 0.0) + "|" + t.getTime(java.util.concurrent.TimeUnit.MILLISECONDS);
        }));
    }

    interface L {
        long get() throws Exception;
    }

    interface S {
        Object get() throws Exception;
    }

    static String raw(L c) {
        try {
            return String.valueOf(c.get());
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getSimpleName() + ":" + t.getMessage();
        }
    }

    static String raws(S c) {
        try {
            Object v = c.get();
            return v == null ? "{null}" : String.valueOf(v);
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getSimpleName() + ":" + t.getMessage();
        }
    }

    static String safe(S c) {
        return raws(c);
    }
}
