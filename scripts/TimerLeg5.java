// moon-hutool/date 批② —— 第五条腿：`GlobalCustomFormat` 两张表的**不对称**。
//
// `isCustomFormat` 只查 **formatter 表**（字节码现读：`formatterMap.containsKey(format)`），
// 于是"只登记 parser 不登记 formatter"这个键在门面上是**隐形的**：`DateUtil.parse` 的挂载点
// 被 `isCustomFormat` 挡在前面 ⇒ 它根本不会去查 parser 表。这条不对称直接决定本库注册表的形状
// （两张表 + 一个只查前者的判据），不能"顺手统一"，否则挂载点行为就变了。
//
// 跑法：
//   javac -encoding UTF-8 -cp hutool-all-5.8.37.jar -d . TimerLeg5.java
//   java  -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -cp hutool-all-5.8.37.jar;. TimerLeg5
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.date.format.GlobalCustomFormat;
import java.util.Date;

public class TimerLeg5 {

    static String esc(String s) {
        if (s == null) return "{null}";
        StringBuilder b = new StringBuilder();
        for (char c : s.toCharArray()) {
            if (c >= ' ' && c < 0x7f) b.append(c);
            else b.append(String.format("{u%04x}", (int) c));
        }
        return b.toString();
    }

    interface C {
        String get() throws Exception;
    }

    static String call(C c) {
        try {
            return c.get();
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getSimpleName() + ":" + esc(t.getMessage());
        }
    }

    static void line(String k, String v) {
        System.out.println("P5|" + k + "||" + v);
    }

    public static void main(String[] args) {
        final Date d = new Date(1700000000123L);
        // 只登记 parser：门面上隐形
        GlobalCustomFormat.putParser("#ponly", s -> new Date(42L));
        line("parser-only|isCustomFormat", call(() -> String.valueOf(GlobalCustomFormat.isCustomFormat("#ponly"))));
        line("parser-only|GlobalCustomFormat.parse", call(() -> String.valueOf(
                GlobalCustomFormat.parse("x", "#ponly").getTime())));
        line("parser-only|DateUtil.parse(走不走这张表)", call(() -> {
            Date r = DateUtil.parse("1970-01-01", "#ponly");
            return r == null ? "{null}" : String.valueOf(r.getTime());
        }));
        line("parser-only|DateUtil.format", call(() -> esc(DateUtil.format(d, "#ponly"))));
        // 只登记 formatter（批④的 half 档）：看得见，但 parse 那侧没有落点
        GlobalCustomFormat.putFormatter("#fonly", x -> "F" + x.getTime());
        line("formatter-only|isCustomFormat", call(() -> String.valueOf(GlobalCustomFormat.isCustomFormat("#fonly"))));
        line("formatter-only|DateUtil.format", call(() -> esc(DateUtil.format(d, "#fonly"))));
        line("formatter-only|DateUtil.parse", call(() -> {
            Date r = DateUtil.parse("F1700000000123", "#fonly");
            return r == null ? "{null}" : String.valueOf(r.getTime()) + "(是不是现在?" + (Math.abs(r.getTime() - System.currentTimeMillis()) < 60000) + ")";
        }));
        line("formatter-only|GlobalCustomFormat.parse", call(() -> {
            Date r = GlobalCustomFormat.parse("F1", "#fonly");
            return r == null ? "{null}" : String.valueOf(r.getTime());
        }));
        // 空串键：把普通档整个劫持
        GlobalCustomFormat.putFormatter("", x -> "EMPTY");
        line("空串键|isCustomFormat", call(() -> String.valueOf(GlobalCustomFormat.isCustomFormat(""))));
        line("空串键|DateUtil.format(d,\"\")", call(() -> esc(DateUtil.format(d, ""))));
        GlobalCustomFormat.putFormatter("", x -> String.valueOf(x.getTime()));
        // 内置两档的 formatter 到底做了什么（字节码 lambda$static$0/2 的形状，用行为验）
        line("内置#sss|负毫秒", call(() -> esc(GlobalCustomFormat.format(new Date(-1700000000123L), "#sss"))));
        line("内置#SSS|formatter返回null那档", call(() -> {
            GlobalCustomFormat.putFormatter("#nullback", x -> null);
            return "{" + String.valueOf(DateUtil.format(d, "#nullback")) + "}";
        }));
        line("内置#SSS|parser返回null那档", call(() -> {
            GlobalCustomFormat.putParser("#nullparse", s -> null);
            Date r = DateUtil.parse("x", "#nullparse");
            return "{" + String.valueOf(r) + "}";
        }));
        // 注册顺序：parser 先、formatter 后 —— 补齐之后 parse 才通得动
        GlobalCustomFormat.putParser("#pair", s -> new Date(7L));
        line("pair|补 formatter 之前 isCustom", call(() -> String.valueOf(GlobalCustomFormat.isCustomFormat("#pair"))));
        GlobalCustomFormat.putFormatter("#pair", x -> "P");
        line("pair|补上之后 isCustom", call(() -> String.valueOf(GlobalCustomFormat.isCustomFormat("#pair"))));
        line("pair|补上之后 DateUtil.parse", call(() -> {
            Date r = DateUtil.parse("x", "#pair");
            return r == null ? "{null}" : String.valueOf(r.getTime());
        }));
        // 收尾：内置两档没被动过（前面几档都是新键）
        line("收尾|isCustom(#sss)", call(() -> String.valueOf(GlobalCustomFormat.isCustomFormat("#sss"))));
        line("收尾|#sss 读数", call(() -> esc(DateUtil.format(d, "#sss"))));
        // parser 的 #sss 那一档内部是 `Math.multiplyExact(parseLong(s), 1000)` ⇒
        // "parseLong 过得去、乘 1000 溢出"是**另一种异常**，与"parseLong 就过不去"要分档
        String[] ov = { "9223372036854775", "9223372036854775807", "-9223372036854775808",
                "9223372036", "-9223372036854776", "1700000000" };
        for (String s : ov) {
            line("overflow臂|parse(" + s + ",#sss)", call(() -> String.valueOf(
                    GlobalCustomFormat.parse(s, GlobalCustomFormat.FORMAT_SECONDS).getTime())));
            line("overflow臂|parse(" + s + ",#SSS)", call(() -> String.valueOf(
                    GlobalCustomFormat.parse(s, GlobalCustomFormat.FORMAT_MILLISECONDS).getTime())));
        }
    }
}
