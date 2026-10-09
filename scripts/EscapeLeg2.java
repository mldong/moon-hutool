// moon-hutool/text —— EscapeUtil/UnicodeUtil 的**逐字符扫描腿**（EscapeLeg 的姊妹腿）。
//
// EscapeLeg 那批是"夹具级"读数；这一条打的是**完备性**：默认过滤器的"不转义集"、
// escapeChar 的十六进制大小写、unescape 的每一条出口、以及 toUnicode 对**真实文本**（不是
// 已经是转义形状的串）的行为。三件事只能靠全枚举钉死，抽样会被下一个字符打脸：
//   ① escape(CharSequence) 的默认过滤器到底放了谁（NOT_ESCAPE_CHARS 只有 7 个，
//      实测 `& ( ) '` 也原样出，说明出口不止那 7 个 ⇒ 必须逐码点问，不能抄常量）；
//   ② unescape 对 `%uXXXX` / `%41` / 坏序列的每条出口；
//   ③ UnicodeUtil.toString 的"代理对到底合不合成"（实测不合 ⇒ 会产出**孤立代理项**，
//      MoonBit 的 String/Char 接不住这种形状，必须在契约里显式判，不能让实现自己决定）。
//
// 跑法同 EscapeLeg。行形状 `<族>|<键>|<读数>`；不可见字符一律 {uXXXX}。
import cn.hutool.core.text.UnicodeUtil;
import cn.hutool.core.util.EscapeUtil;

public class EscapeLeg2 {

    static final char B = (char) 0x5c;

    static String u(String h) {
        return "" + B + "u" + h;
    }

    public static void main(String[] args) {
        // ① 逐码点问默认过滤器：0x00..0xFF 全枚举 + 三个 BMP 样点 + 一个增补平面字符
        StringBuilder left = new StringBuilder();      // 原样出的码点
        StringBuilder pcts = new StringBuilder();      // 出 %XX 的码点（两位）
        StringBuilder puct = new StringBuilder();      // 出 %uXXXX 的码点（四位）
        StringBuilder other = new StringBuilder();     // 其它形状（三位/一位/异常）
        for (int cp = 0; cp <= 0xff; cp++) {
            final char c = (char) cp;
            String one = esc(safe(() -> EscapeUtil.escape("" + c)));
            classify(cp, one, left, pcts, puct, other);
        }
        for (int cp : new int[] {0x100, 0x2013, 0x2014, 0x300c, 0x4e2d, 0xd800, 0xfffd}) {
            String one = esc(safe(() -> EscapeUtil.escape("" + (char) cp)));
            classify(cp, one, left, pcts, puct, other);
        }
        System.out.println("SET|left|" + left);
        System.out.println("SET|pct2|" + pcts);
        System.out.println("SET|pctU|" + puct);
        System.out.println("SET|other|" + other);

        // 同一个码点在 escapeAll / filterKeepAll 下的形状，用来看大小写与位数规则
        StringBuilder allhex = new StringBuilder();
        for (int cp = 0x20; cp <= 0x7e; cp++) {
            final char c = (char) cp;
            allhex.append(esc(safe(() -> EscapeUtil.escapeAll("" + c))));
        }
        System.out.println("SET|escapeAllAscii|" + allhex);

        // ② unescape 的每条出口：合法/非法/混合，全部现读
        String[] UN = {
            "%41", "%41%42", "%u4e2d", "%u4E2D", "%u0041%u0042", "%" + "4e2d",
            "%", "%2", "%zz", "%4", "abc%41def", "100%", "%25", "%2541", "+", "%2b",
            "%0a", "%0d%0a", "%ff", "%80", "%c3%28", "%e4%b8%ad", "%uD83D%uDE00",
            "%3c%3e", "%20", "%25u4e2d", "", "%2f", "%2F",
            // 落单代理档：本库 `LoneSurrogate` 那条臂唯一的读数来源（不补就是"实现里写了、
            // 却没有任何期望值证明过"）。参照在这里给的是一个**孤立码元**，本库表示不了。
            "%uD83D", "%uDC00", "%uD800", "%u41%uD800", "%ud800%udbff", "abc%ud800def", "%uDFA0",
            "%uD83D%uDE00%uD800", "x%uD83D",
        };
        for (String s : UN) {
            System.out.println("UN|unescape|" + esc(s) + "|" + esc(safe(() -> EscapeUtil.unescape(s))));
            System.out.println("UN|safeUnescape|" + esc(s) + "|" + esc(safe(() -> EscapeUtil.safeUnescape(s))));
        }
        // 闭环：escape→unescape 是否回到原串（逐夹具取数，不假设）
        String[] RT = {"abc", "a b", "*@-_+./", "&()'\"", "~!@#$%^", "中文 a", "😀", "%41", "\n\t"};
        for (String s : RT) {
            final String in = s;
            System.out.println("RT|escape_then_unescape|" + esc(in) + "|"
                    + esc(safe(() -> EscapeUtil.unescape(EscapeUtil.escape(in)))));
            final String in2 = s;
            System.out.println("RT|escapeAll_then_unescape|" + esc(in2) + "|"
                    + esc(safe(() -> EscapeUtil.unescape(EscapeUtil.escapeAll(in2)))));
        }

        // ③ UnicodeUtil 的**真实文本**档（EscapeLeg 只喂了转义形状，那是 toString 的入口料，
        //   不是 toUnicode 的入口料 —— 两族的输入形状不同，必须分开取数）
        String[] RAW = {"abc", "A", "中文", "中a文", "", "a b", "\n", "\t", "\\(literal backslash)",
            "u4e2d(no slash)", "😀", "\uD83D", "\uDE00", "ß", "Ⅷ", "！"};
        for (String s : RAW) {
            System.out.println("RAW|toUnicode|" + esc(s) + "|" + esc(safe(() -> UnicodeUtil.toUnicode(s))));
            System.out.println("RAW|toUnicode(true)|" + esc(s) + "|" + esc(safe(() -> UnicodeUtil.toUnicode(s, true))));
            System.out.println("RAW|toUnicode(false)|" + esc(s) + "|" + esc(safe(() -> UnicodeUtil.toUnicode(s, false))));
            System.out.println("RAW|toString|" + esc(s) + "|" + esc(safe(() -> UnicodeUtil.toString(s))));
        }
        // 真实文本的闭环：toUnicode→toString 回到原串（ASCII 与非 ASCII 分开看）
        for (String s : RAW) {
            final String in = s;
            System.out.println("RT|toUnicode_then_toString|" + esc(in) + "|"
                    + esc(safe(() -> UnicodeUtil.toString(UnicodeUtil.toUnicode(in)))));
            final String in2 = s;
            System.out.println("RT|toUnicodeFalse_then_toString|" + esc(in2) + "|"
                    + esc(safe(() -> UnicodeUtil.toString(UnicodeUtil.toUnicode(in2, false)))));
        }

        // ④ 实体族的补充档：数字引用落在代理区/超 BMP 时的行为（MoonBit 侧接不住孤立代理项）
        String[] NUM = {"&#xD800;", "&#x00;", "&#x7F;", "&#x800;", "&#x10000;", "&#xD83D;&#xDE00;",
            "&#x110000;", "&#xFFFFFFFF;", "&#0065;", "&#X0a;", "&lt;&#65;&gt;"};
        for (String s : NUM) {
            System.out.println("NUM|unescapeXml|" + esc(s) + "|" + esc(safe(() -> EscapeUtil.unescapeXml(s))));
            System.out.println("NUM|unescapeHtml4|" + esc(s) + "|" + esc(safe(() -> EscapeUtil.unescapeHtml4(s))));
        }
        // 命名实体族的"到底认识谁"：只能逐名问，抽样会给出不完整的表
        String[] NAMES = {"quot", "amp", "lt", "gt", "nbsp", "copy", "reg", "trade", "hellip", "mdash",
            "ndash", "bull", "middot", "laquo", "raquo", "lsquo", "rsquo", "ldquo", "rdquo",
            "eacute", "uuml", "pound", "euro", "apos", "colon", "excl", "num", "semi", "ampx"};
        StringBuilder xmlok = new StringBuilder();
        StringBuilder htmlok = new StringBuilder();
        for (String n : NAMES) {
            final String ref = "&" + n + ";";
            String x = safe(() -> EscapeUtil.unescapeXml(ref));
            String h = safe(() -> EscapeUtil.unescapeHtml4(ref));
            if (!("{" + n + ";").equals(esc(x))) xmlok.append(n).append("=").append(esc(x)).append(" ");
            if (!ref.equals(esc(h))) htmlok.append(n).append("=").append(esc(h)).append(" ");
        }
        System.out.println("NAMES|unescapeXml|" + xmlok);
        System.out.println("NAMES|unescapeHtml4|" + htmlok);
        // 转义侧的"到底转谁"：逐码点问 escapeXml / escapeHtml4
        StringBuilder xe = new StringBuilder();
        StringBuilder he = new StringBuilder();
        for (int cp = 0; cp <= 0xff; cp++) {
            final char c = (char) cp;
            String x = safe(() -> EscapeUtil.escapeXml("" + c));
            String h = safe(() -> EscapeUtil.escapeHtml4("" + c));
            if (!x.equals("" + c)) xe.append(String.format("%02x", cp)).append("=").append(esc(x)).append(" ");
            if (!h.equals("" + c)) he.append(String.format("%02x", cp)).append("=").append(esc(h)).append(" ");
        }
        System.out.println("NAMES|escapeXmlChanged|" + xe);
        System.out.println("NAMES|escapeHtml4Changed|" + he);
        for (int cp : new int[] {0x2013, 0x2014, 0x300c, 0x4e2d, 0x00a0, 0x00a9}) {
            final char c = (char) cp;
            System.out.println("NAMES|escapeHtml4_cp|" + cp + "|" + esc(safe(() -> EscapeUtil.escapeHtml4("" + c))));
            System.out.println("NAMES|escapeXml_cp|" + cp + "|" + esc(safe(() -> EscapeUtil.escapeXml("" + c))));
        }
    }

    /** 读数分类：out 是 esc() 之后的形状（可见 ASCII 原样；`|` 与不可见打成 {uXXXX} 四位）。 */
    static void classify(int cp, String out, StringBuilder left, StringBuilder pcts,
            StringBuilder puct, StringBuilder other) {
        String hex = String.format("%02x", cp);
        char c = (char) cp;
        boolean unchanged = out.equals(String.format("{u%04x}", cp)) || (out.length() == 1 && out.charAt(0) == c);
        if (unchanged) {
            left.append(out.length() == 1 && c >= 0x20 && c <= 0x7e && c != '|' ? out : "<" + hex + ">");
        } else if (out.matches("%u[0-9a-fA-F]{4}")) {
            puct.append("<").append(hex).append(">");
        } else if (out.matches("%[0-9a-fA-F]{2}")) {
            pcts.append("<").append(hex).append(">");
        } else {
            other.append("<").append(hex).append(">=[").append(out).append("]");
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
