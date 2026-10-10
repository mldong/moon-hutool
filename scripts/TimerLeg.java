// moon-hutool/date —— 计时四件 + 全局自定义格式表的参照腿（批② PR-A 的取数件）。
//
// owner 拍的口径：**做，走注入时钟**（G18 白名单一字不动 ⇒ 参照那三件读的是
// `System.currentTimeMillis()`/`System.nanoTime()`，本库不跟；本包的构造/推进口收一个
// `() -> Int64` 的毫秒时钟，同 `date/clock.mbt` 的 `clock_system`/`clock_fixed` 一条形状）。
// 时钟一注入，**时长就是确定的差值**；不确定的只剩"参照自己算了几位、什么单位、抛不抛"。
//
// 所以本腿刻意分两类打：
//   ① 形状档：数字一律掩成 `#`（`mask()`），因为跨宿主、跨负载的毫秒数**永远不能进契约**；
//   ② 确定档：状态机出口、抛错臂、任务名、条数、以及 `GlobalCustomFormat` 的表内容
//      ——这些都与时钟无关，逐条可冻结成真期望值。
//
// 跑法同前批：
//   javac -encoding UTF-8 -cp hutool-all-5.8.37.jar -d . TimerLeg.java
//   java  -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -cp hutool-all-5.8.37.jar;. TimerLeg
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.date.DateUnit;
import cn.hutool.core.date.GroupTimeInterval;
import cn.hutool.core.date.StopWatch;
import cn.hutool.core.date.TimeInterval;
import cn.hutool.core.date.format.GlobalCustomFormat;
import java.time.LocalDateTime;
import java.util.Date;

public class TimerLeg {

    public static void main(String[] args) throws Exception {
        // ---- W：StopWatch 状态机与出口 ----
        StopWatch sw = new StopWatch();
        line("W", "default-id", "", safe(sw::getId));
        line("W", "isRunning@fresh", "", safe(sw::isRunning));
        line("W", "currentTaskName@fresh", "", safe(sw::currentTaskName));
        line("W", "taskCount@fresh", "", safe(sw::getTaskCount));
        line("W", "totalMillis@fresh", "", safe(sw::getTotalTimeMillis));
        line("W", "shortSummary@fresh", "", mask(safe(sw::shortSummary)));
        line("W", "prettyPrint@fresh", "", mask(safe(sw::prettyPrint)));
        line("W", "lastTaskName@fresh", "", safe(sw::getLastTaskName));
        line("W", "lastTaskInfo@fresh", "", safe(sw::getLastTaskInfo));
        line("W", "lastTaskMillis@fresh", "", safe(sw::getLastTaskTimeMillis));
        line("W", "stop@never-started", "", safe_v(() -> sw.stop()));
        sw.start();
        line("W", "currentTaskName@unnamed", "", safe(sw::currentTaskName));
        line("W", "isRunning@running", "", safe(sw::isRunning));
        line("W", "start@while-running", "", safe_v(() -> sw.start("second")));
        line("W", "taskCount@one-running", "", safe(sw::getTaskCount));
        sw.stop();
        line("W", "isRunning@after-stop", "", safe(sw::isRunning));
        line("W", "lastTaskName@after-stop-unnamed", "", safe(sw::getLastTaskName));
        line("W", "stop@not-running", "", safe_v(() -> sw.stop()));
        sw.start("task-A");
        sw.stop();
        sw.start("task-B");
        sw.stop();
        line("W", "taskCount@two", "", safe(sw::getTaskCount));
        line("W", "taskNames", "", safe(() -> {
            StringBuilder b = new StringBuilder();
            for (StopWatch.TaskInfo t : sw.getTaskInfo()) {
                b.append(t.getTaskName()).append('/').append(mask(String.valueOf(t.getTimeMillis()))).append(' ');
            }
            return b.toString().trim();
        }));
        line("W", "lastTaskInfo", "", safe(sw::getLastTaskInfo));
        line("W", "shortSummary@two", "", mask(safe(sw::shortSummary)));
        line("W", "prettyPrint@two", "", mask(safe(sw::prettyPrint)).replace('\n', '|'));
        line("W", "prettyPrint-seCONDS", "", mask(safe(() -> sw.prettyPrint(java.util.concurrent.TimeUnit.SECONDS))).replace('\n', '|'));
        line("W", "total-SECONDS", "", mask(safe(() -> sw.getTotal(java.util.concurrent.TimeUnit.SECONDS))));
        line("W", "totalNanos@two", "", mask(safe(sw::getTotalTimeNanos)));
        line("W", "totalSeconds@two", "", mask(safe(sw::getTotalTimeSeconds)));
        line("W", "toString@two", "", mask(safe(sw::toString)).replace('\n', '|'));
        // keepTaskList=false 那一档：表不记，但总时长照累（这是"记不记"与"算不算"分档的读数）
        StopWatch nk = new StopWatch("no-keep", false);
        nk.start("x");
        nk.stop();
        nk.start("y");
        nk.stop();
        line("W", "keep=false|taskCount", "", safe(nk::getTaskCount));
        line("W", "keep=false|taskInfoLen", "", safe(() -> nk.getTaskInfo().length));
        line("W", "keep=false|lastTaskName", "", safe(nk::getLastTaskName));
        line("W", "keep=false|shortSummary", "", mask(safe(nk::shortSummary)));
        line("W", "keep=false|totalMillis>0", "", safe(() -> String.valueOf(nk.getTotalTimeMillis() >= 0)));
        line("W", "create(id)", "", safe(() -> StopWatch.create("job-7").getId()));
        line("W", "setKeepTaskList(true)后", "", safe(() -> {
            nk.setKeepTaskList(true);
            nk.start("z");
            nk.stop();
            return nk.getTaskInfo().length + "/" + nk.getTaskCount();
        }));

        // ---- T：TimeInterval（extends GroupTimeInterval）----
        TimeInterval ti = new TimeInterval();
        line("T", "interval@fresh", "", mask(safe(ti::interval)));
        line("T", "intervalMs@fresh", "", mask(safe(ti::intervalMs)));
        line("T", "intervalPretty@fresh", "", mask(safe(ti::intervalPretty)));
        line("T", "start", "", mask(safe(ti::start)));
        line("T", "interval@after-start", "", mask(safe(ti::interval)));
        line("T", "intervalRestart", "", mask(safe(ti::intervalRestart)));
        line("T", "restart", "", mask(safe(ti::restart)));
        line("T", "second@fresh-after-restart", "", mask(safe(ti::intervalSecond)));
        line("T", "week", "", mask(safe(ti::intervalWeek)));
        line("T", "extends-group?start(key)", "", mask(safe(() -> ti.start("g1"))));
        line("T", "interval(key)", "", mask(safe(() -> ti.interval("g1"))));
        line("T", "interval(unknown-key)", "", mask(safe(() -> ti.interval("nope"))));
        TimeInterval sec = new TimeInterval(false);
        line("T", "isMillis=false|interval", "", mask(safe(sec::interval)));
        sec.start();
        line("T", "isMillis=false|after-start", "", mask(safe(sec::interval)));
        TimeInterval ms = new TimeInterval(true);
        ms.start();
        line("T", "isMillis=true|after-start", "", mask(safe(ms::interval)));

        // ---- G：GroupTimeInterval ----
        GroupTimeInterval g = new GroupTimeInterval(true);
        line("G", "interval@empty", "", mask(safe(() -> g.interval("k"))));
        line("G", "start(k1)", "", mask(safe(() -> g.start("k1"))));
        line("G", "start(k1) again", "", mask(safe(() -> g.start("k1"))));
        line("G", "interval(k1)", "", mask(safe(() -> g.interval("k1"))));
        line("G", "interval(k1,MS)", "", mask(safe(() -> g.interval("k1", DateUnit.MS))));
        line("G", "interval(k1,SECOND)", "", mask(safe(() -> g.interval("k1", DateUnit.SECOND))));
        line("G", "intervalMs/Second/Minute/Week", "", mask(String.valueOf(g.intervalMs("k1"))) + "/" + mask(String.valueOf(g.intervalSecond("k1")))
                + "/" + mask(String.valueOf(g.intervalMinute("k1"))) + "/" + mask(String.valueOf(g.intervalWeek("k1"))));
        line("G", "intervalPretty(k1)", "", mask(safe(() -> g.intervalPretty("k1"))));
        line("G", "intervalRestart(k1)", "", mask(safe(() -> g.intervalRestart("k1"))));
        line("G", "interval(unknown)", "", mask(safe(() -> g.interval("nope"))));
        line("G", "clear then interval", "", mask(safe(() -> {
            g.clear();
            return String.valueOf(g.interval("k1"));
        })));
        // 负数档：把起点"记成将来"——用 start 之后手动等价的键来问（不靠 sleep，跨宿主不稳）
        line("G", "两个键互不干扰", "", mask(safe(() -> {
            g.clear();
            g.start("a");
            g.start("b");
            return g.intervalMs("a") + "<=" + (g.intervalMs("a") >= 0) + "," + (g.intervalMs("b") >= 0);
        })));

        // ---- F：GlobalCustomFormat（全局注册表；公开面，且要被 DateUtil.format 真消费才有效）----
        Date d = new Date(1_700_000_000_123L);
        line("F", "isCustomFormat(#sss)", "", safe(() -> GlobalCustomFormat.isCustomFormat("#sss")));
        line("F", "isCustomFormat(#SSS)", "", safe(() -> GlobalCustomFormat.isCustomFormat("#SSS")));
        line("F", "isCustomFormat(yyyy-MM-dd)", "", safe(() -> GlobalCustomFormat.isCustomFormat("yyyy-MM-dd")));
        line("F", "format(#sss)", "", safe(() -> GlobalCustomFormat.format(d, "#sss")));
        line("F", "format(#SSS)", "", safe(() -> GlobalCustomFormat.format(d, "#SSS")));
        line("F", "DateUtil.format(#sss)", "", safe(() -> DateUtil.format(d, "#sss")));
        line("F", "DateUtil.format(plain)", "", safe(() -> DateUtil.format(d, "yyyy-MM-dd")));
        // 注册一条自定义：键名故意用"看着像普通模式"的形状，问两件事——
        //   ① 注册后 isCustomFormat / DateUtil.format 是否立刻走它；
        //   ② 注册是否覆盖内置（把 `#sss` 抢过来）。
        line("F", "after-put|isCustom(mine)", "", safe(() -> {
            GlobalCustomFormat.putFormatter("mine", dt -> "M" + dt.getTime());
            return String.valueOf(GlobalCustomFormat.isCustomFormat("mine"));
        }));
        line("F", "after-put|DateUtil.format(mine)", "", safe(() -> DateUtil.format(d, "mine")));
        line("F", "after-put|format(mine)", "", safe(() -> GlobalCustomFormat.format(d, "mine")));
        line("F", "override-#sss?|before", "", safe(() -> DateUtil.format(d, "#sss")));
        line("F", "after-put|isCustom(yyyy-MM-dd)", "", safe(() -> GlobalCustomFormat.isCustomFormat("yyyy-MM-dd")));
        line("F", "parse(mine)", "", safe(() -> GlobalCustomFormat.parse("M1700000000123", "mine")));
        GlobalCustomFormat.putParser("minep", cs -> new Date(Long.parseLong(cs.subSequence(1, cs.length()).toString())));
        line("F", "parse(minep)", "", safe(() -> GlobalCustomFormat.parse("X1700000000123", "minep")));
        line("F", "parse(unregistered)", "", safe(() -> GlobalCustomFormat.parse("zz", "nope")));
        line("F", "format(TemporalAccessor,#sss)", "", safe(() -> GlobalCustomFormat.format(LocalDateTime.of(2026, 10, 10, 8, 30, 15), "#sss")));
        line("F", "format(null-date,#sss)", "", safe(() -> GlobalCustomFormat.format((Date) null, "#sss")));
        line("F", "isCustomFormat(null)", "", safe(() -> GlobalCustomFormat.isCustomFormat(null)));
        line("F", "DateUtil.format after custom for plain pattern", "", safe(() -> DateUtil.format(d, "yyyy-MM-dd")));
    }

    interface C {
        Object get() throws Exception;
    }

    static String safe(C c) {
        try {
            Object v = c.get();
            return v == null ? "{null}" : String.valueOf(v);
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getSimpleName() + ":" + t.getMessage();
        }
    }

    interface C0 {
        void run() throws Exception;
    }

    /** void 出口的抛错臂：读数只能是 `ok` 或 `ERR:<类名>:<msg>`，正好是要钉的东西 */
    static String safe_v(C0 c) {
        try {
            c.run();
            return "ok";
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getSimpleName() + ":" + t.getMessage();
        }
    }

    static String mask(String s) {
        return s == null ? "{null}" : s.replaceAll("[0-9]+", "#");
    }

    static void line(String fam, String key, String in, String out) {
        System.out.println(fam + "|" + key + "|" + in + "|" + out.replace('\r', ' ').replace('\n', '|'));
    }
}
