// scripts/Cron5Leg.java —— hutool-cron 调度族的**行为腿**（javap 给不了行为，只能真跑 JVM）
//
// 用途：把 `docs/spec/24-sched.md` §6 那三条"待腿核"转正成机器读数，再由实现轮把断言灌进
// `sched/sched_test.mbt`。期望值一律取本程序的输出，不手写。
//
// 跑法（jar 从 Maven Central 取，落在工作树外，不提交）：
//   javac -cp hutool-all-5.8.35.jar -d . Cron5Leg.java
//   java -cp hutool-all-5.8.35.jar:. Cron5Leg
//
// 读数种类：
//   N1  重复 id 的 add：覆盖 / 追加 / 抛错，以及三条并行 List 各自长度
//   N2  同一毫秒两次 executeTaskIfMatch：是否重复触发（spawnExecutor 无去重 ⇒ 预期"会"，但由腿定）
//   P1  任务体抛异常：后续任务是否照常触发、异常是否漏到调度线程
//   P2  stop 时执行中的任务：跑完还是被切断

import cn.hutool.cron.CronUtil;
import cn.hutool.cron.Scheduler;
import cn.hutool.cron.TaskTable;
import cn.hutool.cron.pattern.CronPattern;
import cn.hutool.cron.task.Task;

import java.util.concurrent.atomic.AtomicInteger;

public class Cron5Leg {

    static class Counting implements Task {
        final AtomicInteger hits = new AtomicInteger();
        final AtomicInteger done = new AtomicInteger();
        final long busyMillis;
        final boolean boom;

        Counting(long busyMillis, boolean boom) {
            this.busyMillis = busyMillis;
            this.boom = boom;
        }

        @Override
        public void execute() {
            hits.incrementAndGet();
            try {
                if (busyMillis > 0) {
                    Thread.sleep(busyMillis);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            if (boom) {
                throw new IllegalStateException("leg-boom");
            }
            done.incrementAndGet(); // 只有跑完体才 +1 ⇒ P2 判"stop 切断还是放完"就看这一格
        }
    }

    public static void main(String[] args) throws Exception {
        // ---- N1：重复 id ----------------------------------------------------------
        TaskTable table = new TaskTable();
        Counting a = new Counting(0, false);
        Counting b = new Counting(0, false);
        CronPattern p1 = new CronPattern("* * * * * ?");
        CronPattern p2 = new CronPattern("0 0 12 * * ?");
        table.add("dup", p1, a);
        String raised = "none";
        try {
            table.add("dup", p2, b);
        } catch (Exception e) {
            raised = e.getClass().getSimpleName() + ":" + e.getMessage();
        }
        System.out.println("N1|secondAdd=" + raised);
        System.out.println("N1|size=" + table.size()
                + "|ids=" + table.getIds()
                + "|patterns=" + table.getPatterns().size()
                + "|tasks=" + table.getTasks().size()
                + "|getTask==B:" + (table.getTask("dup") == b)
                + "|patternIsP1:" + (table.getPattern("dup") == p1));

        // ---- N2：同一毫秒调两次 --------------------------------------------------
        CronUtil.setMatchSecond(true);
        // 不先 start() 的话 Scheduler.taskExecutorManager 还没建，executeTaskIfMatch 直接 NPE
        // （本轮实测踩到：`getScheduler()` 返回的是半成品，manager 在 start 里才装）
        CronUtil.start();
        Scheduler scheduler = CronUtil.getScheduler();
        TaskTable t2 = new TaskTable();
        Counting once = new Counting(0, false);
        t2.add("n2", new CronPattern("* * * * * ?"), once);
        long stamp = 1717171717000L; // 一个普通秒
        t2.executeTaskIfMatch(scheduler, stamp);
        t2.executeTaskIfMatch(scheduler, stamp);
        Thread.sleep(1200);
        System.out.println("N2|hits=" + once.hits.get());
        CronUtil.stop();

        // ---- P1：抛异常后调度器是否还活着 ----------------------------------------
        StringBuilder surfaced = new StringBuilder();
        Thread.UncaughtExceptionHandler old = Thread.getDefaultUncaughtExceptionHandler();
        Thread.setDefaultUncaughtExceptionHandler((t, e) -> surfaced.append(e.getClass().getSimpleName()));
        Counting boomTask = new Counting(0, true);
        Counting okTask = new Counting(0, false);
        CronUtil.schedule("p1-boom", "* * * * * ?", boomTask);
        CronUtil.schedule("p1-ok", "* * * * * ?", okTask);
        CronUtil.start();
        Thread.sleep(3500);
        int boomHits = boomTask.hits.get();
        CronUtil.stop();
        Thread.setDefaultUncaughtExceptionHandler(old);
        System.out.println("P1|boomHits=" + boomHits
                + "|okHits=" + okTask.hits.get()
                + "|surfaced=" + (surfaced.length() == 0 ? "none" : surfaced.toString()));

        // ---- P2：stop 撞上执行中的任务 -------------------------------------------
        // 上一段 CronUtil.stop() 已把 threadExecutor 置空，手喂 executeTaskIfMatch 会 NPE
        // （本轮实测踩到）⇒ P2 走正常路径：重新 schedule + start，让它自己触发一次再 stop
        Counting slow = new Counting(1800, false);
        CronUtil.schedule("p2", "* * * * * ?", slow);
        CronUtil.start();
        long waited = 0;
        while (slow.hits.get() == 0 && waited < 4000) {
            Thread.sleep(100);
            waited += 100;
        }
        CronUtil.stop();
        Thread.sleep(2200);
        System.out.println("P2|hits=" + slow.hits.get() + "|done=" + slow.done.get() + "|firstHitWaitMs=" + waited);

        System.exit(0);
    }
}
