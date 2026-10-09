// moon-hutool/text —— 实体表的**反射读常量本体**腿（不手抄码表，也不靠抽样猜名字）。
//
// 为什么走反射：`XmlEscape`/`Html4Escape`/`XmlUnescape`/`Html4Unescape` 四个类都 extends
// `ReplacerChain`，转义表就是它们自己的 `protected static final String[][]` 字段
// （javap -p 现读到的六个字段名，见下）。HTML4 的命名实体一共两百多条——
// 手抄必错、抽样只能给出"哪些被认得"而给不出"整表是谁"。本腿把六张表**逐条**打出来，
// 再由生成器把读数落成 `text/html4_entities.mbt` 的数据表（键序、重复键都原样留痕）。
//
// 同时打两份**行为侧**对照，用来证明"表就是行为"而不是"表是历史遗留"：
//   S 行：逐码点喂 escapeXml / escapeHtml4，看实际产出的是哪个实体（同码点多名时看它挑哪个）；
//   N 行：数字实体档（NumericEntityUnescaper 的出口），含代理区、超 BMP、坏位数。
//
// 跑法同 EscapeLeg。行形状见每族注释。
import cn.hutool.core.util.EscapeUtil;
import java.lang.reflect.Field;

public class EntityTableLeg {

    static final String[][] FIELDS = {
        {"cn.hutool.core.text.escape.XmlEscape", "BASIC_ESCAPE"},
        {"cn.hutool.core.text.escape.Html4Escape", "BASIC_ESCAPE"},
        {"cn.hutool.core.text.escape.Html4Escape", "ISO8859_1_ESCAPE"},
        {"cn.hutool.core.text.escape.Html4Escape", "HTML40_EXTENDED_ESCAPE"},
        {"cn.hutool.core.text.escape.XmlUnescape", "BASIC_UNESCAPE"},
        {"cn.hutool.core.text.escape.Html4Unescape", "ISO8859_1_UNESCAPE"},
        {"cn.hutool.core.text.escape.Html4Unescape", "HTML40_EXTENDED_UNESCAPE"},
    };

    public static void main(String[] args) throws Exception {
        // F 行：族|类简名|字段|序号|键|值   （表里若有重复键，序号会把两条都留下来）
        for (String[] f : FIELDS) {
            Class<?> c = Class.forName(f[0]);
            Field f1 = c.getDeclaredField(f[1]);
            f1.setAccessible(true);
            String[][] tbl = (String[][]) f1.get(null);
            for (int i = 0; i < tbl.length; i++) {
                System.out.println("F|" + f[0].substring(f[0].lastIndexOf('.') + 1) + "|" + f[1] + "|" + i
                        + "|" + esc(tbl[i][0]) + "|" + esc(tbl[i][1]));
            }
            System.out.println("F|" + f[0].substring(f[0].lastIndexOf('.') + 1) + "|" + f[1] + "|LEN|" + tbl.length + "|");
        }

        // S 行：逐码点问"你把它转成什么"——BMP 全枚举，只打**变了形**的那些
        for (int cp = 0; cp <= 0xffff; cp++) {
            char c = (char) cp;
            String x = EscapeUtil.escapeXml("" + c);
            String h = EscapeUtil.escapeHtml4("" + c);
            if (!x.equals("" + c)) System.out.println("S|escapeXml|" + hex(cp) + "|" + esc(x));
            if (!h.equals("" + c)) System.out.println("S|escapeHtml4|" + hex(cp) + "|" + esc(h));
        }
        // 反向：逐码点问"unescape 认不认这个码点对应的实体"没法枚举，但可以把上面产出的
        // 实体名逐个喂回去 ⇒ 闭环档（C 行）：escape 后再 unescape，是否回到原字符。
        for (int cp = 0; cp <= 0xffff; cp++) {
            char c = (char) cp;
            String x = EscapeUtil.escapeXml("" + c);
            if (!x.equals("" + c)) {
                String back = EscapeUtil.unescapeXml(x);
                if (!back.equals("" + c)) System.out.println("C|xml|NOTROUND|" + hex(cp) + "|" + esc(x) + "|" + esc(back));
            }
            String h = EscapeUtil.escapeHtml4("" + c);
            if (!h.equals("" + c)) {
                String back = EscapeUtil.unescapeHtml4(h);
                if (!back.equals("" + c)) System.out.println("C|html4|NOTROUND|" + hex(cp) + "|" + esc(h) + "|" + esc(back));
            }
        }
        // 同码点多名的择路（表里 `&quot;` 与 `&QUOT;` 之类）：把两条名都喂回 unescape 看是否同值
        String[] aliases = {"&amp;", "&AMP;", "&QUOT;", "&NewLine;", "&#x41;", "&#X41;", "&nbsp;", "&NBSP;",
            "&copy;", "&COPY;", "&or;"};
        for (String a : aliases) {
            System.out.println("A|unescapeXml|" + esc(a) + "|" + esc(safe(() -> EscapeUtil.unescapeXml(a))));
            System.out.println("A|unescapeHtml4|" + esc(a) + "|" + esc(safe(() -> EscapeUtil.unescapeHtml4(a))));
        }

        // N 行：数字实体的每条出口（位数/进制/越界/代理区/无分号）
        String[] nums = {"&#65;", "&#x41;", "&#X41;", "&#0;", "&#127;", "&#128;", "&#x7FF;", "&#x800;",
            "&#xFFFF;", "&#x10000;", "&#xD800;", "&#xDFFF;", "&#xD83D;&#xDE00;", "&#0065;", "&#0x41;",
            "&#;", "&#x;", "&#ZZ;", "&#xGG;", "&#65", "&#x41", "&#99999999999;", "&#xFFFFFFFF;",
            "&#", "&#", "a&#65;b", "&#65;&#66;", "&# 65;", "&#6 5;", "&#6;", "&#1000000;"};
        for (String n : nums) {
            System.out.println("N|unescapeXml|" + esc(n) + "|" + esc(safe(() -> EscapeUtil.unescapeXml(n))));
            System.out.println("N|unescapeHtml4|" + esc(n) + "|" + esc(safe(() -> EscapeUtil.unescapeHtml4(n))));
        }
        // 混合与重叠：命名实体是另一个实体的一部分（&And; vs &A...）、相邻实体、实体里嵌实体
        String[] mix = {"&Lt;", "&LT;", "&lT;", "&AMPamp;", "&notit;", "&notin;", "&sup;", "&Sup;",
            "&forall;", "&ForAll;", "&amp&;", "&&amp;", "&amp;;", "&nbsp&nbsp;", "&lt;&gt;&amp;",
            "&CounterClockwiseContourIntegral;", "&fjlig;"};
        for (String m : mix) {
            System.out.println("M|unescapeXml|" + esc(m) + "|" + esc(safe(() -> EscapeUtil.unescapeXml(m))));
            System.out.println("M|unescapeHtml4|" + esc(m) + "|" + esc(safe(() -> EscapeUtil.unescapeHtml4(m))));
            System.out.println("M|escapeXml|" + esc(m) + "|" + esc(safe(() -> EscapeUtil.escapeXml(m))));
        }
        // 转义侧的键择路：串里已经带实体时，`&` 会被再转一次（前面读过），这里补档：
        // 长键优先（`&CounterClockwiseContourIntegral;` 不能被 `&C...` 的短前缀抢）
        String[] longk = {"&CounterClockwiseContourIntegral;", "&ClockwiseContourIntegral;", "&not;", "&notin;",
            "&ni;", "&ngE;", "&nGt;", "&gt;", "&Gt;", "&Gg;", "&gg;"};
        for (String k : longk) {
            System.out.println("L|unescapeHtml4|" + esc(k) + "|" + esc(safe(() -> EscapeUtil.unescapeHtml4(k))));
            System.out.println("L|unescapeXml|" + esc(k) + "|" + esc(safe(() -> EscapeUtil.unescapeXml(k))));
        }
    }

    interface Call {
        String get();
    }

    static String safe(Call c) {
        try {
            String r = c.get();
            return r == null ? "{null}" : r;
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getSimpleName() + ":" + (t.getMessage() == null ? "" : t.getMessage());
        }
    }

    static String hex(int cp) {
        return String.format("u%04x", cp);
    }

    static String esc(String s) {
        if (s == null) return "{null}";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            if (ch >= 0x20 && ch <= 0x7e && ch != '|') sb.append(ch);
            else sb.append(String.format("{u%04x}", (int) ch));
        }
        return sb.toString();
    }
}
