// moon-hutool/text —— EscapeUtil + UnicodeUtil 的参照腿（期望值唯一来源，不手写）。
//
// 参照件：hutool-all 5.8.37 的 `cn.hutool.core.util.EscapeUtil`（9 个公开静态法）与
// `cn.hutool.core.text.UnicodeUtil`（5 个）。**UnicodeUtil 的真实包是 core.text 不是 core.util**
// ——census 那行登记的就是 text；`cn.hutool.core.util.UnicodeUtil` 这个 FQN 在 jar 里不存在
// （javap 实测报"找不到类"），照着它写 spec 会指到空气。
//
// 跑法（jar 从 Maven Central 取，落工作树外、不提交；Windows 上 classpath 必须 cygpath -w）：
//   javac -encoding UTF-8 -cp hutool-all-5.8.37.jar -d . EscapeLeg.java
//   java -Dfile.encoding=UTF-8 -cp hutool-all-5.8.37.jar;. EscapeLeg
//
// 行形状：`<族>|<方法>|<入参转义>|<读数>`
//   入参/读数转义：可见 ASCII 原样（`|` 换成 `{u007c}`），其余一律 `{uXXXX}`，null 档打成 `{null}`；
//   抛错 ⇒ `ERR:<异常类名>[:<message 转义>]`。int 档入参打成 `int:<值>`。
//
// ⚠ 词法坑（本腿的第一版就踩了）：**Java 源码里写"双反斜杠 + u4e2d"得到的是 1 个汉字，不是 6 个字符**。
//   斜杠-u-四位十六进制 由编译器的词法前置翻译处理，多一个反斜杠挡不住它（实测 len=1），
//   连注释里出现这个形状都会编译报错"非法的 Unicode 转换"。所以喂 UnicodeUtil 的
//   "带反斜杠的转义串"一律用 `(char)0x5c` 在运行期拼（见 u/uu 两个 helper），
//   否则腿测的是"已经是汉字的串"，整族读数全假。
import cn.hutool.core.lang.Filter;
import cn.hutool.core.text.UnicodeUtil;
import cn.hutool.core.util.EscapeUtil;

public class EscapeLeg {

    static final char B = (char) 0x5c;

    /** 运行期拼"斜杠 uXXXX"（6 字符），绕开词法前置翻译。 */
    static String u(String h) {
        return "" + B + "u" + h;
    }

    /** 运行期拼"双斜杠 uXXXX"（7 字符）：UnicodeUtil 不该认它是转义。 */
    static String uu(String h) {
        return "" + B + B + "u" + h;
    }

    // ---- 实体族的输入夹具：每条都打在一个具体的出口上 ----
    static final String[] ENT = {
        "a<b&c>d\"e'f",                 // 五个 markup 字符同屏
        "<tag attr=\"v\">&amp;中</tag>",   // 已含实体的混合串
        "&nbsp;&lt;&gt;&quot;&apos;&copy;&pound;", // HTML4 命名实体（含 XML 里没有的）
        "&#65;&#x41;&#X41;&#999;",         // 数字引用：十进制/十六进制/大写 X/超 BMP 内
        "&amp;amp;",                    // 双重转义：一次解一层还是全解
        "&notanentity;&amp",            // 未知名 + 无分号
        "&#;&#xZZ;",                    // 坏数字引用
        "中文—–「",                     // 非 ASCII：转不转
        "a😀b",                         // 增补平面（代理对）
        "",                             // 空串
        "line1\nline2\ttab \r\n",       // 控制字符
        "  leading and trailing  ",     // 空格
        "'\\\"\"",                      // 引号与反斜杠混排
        "%41%E4%B8%AD",                 // 百分号串（实体族不该动它）
    };

    // ---- 百分号族的输入夹具 ----
    static final String[] PCT = {
        "abc ABC 123",                  // alnum 全保留
        "*@-_.+/ !",                    // NOT_ESCAPE_CHARS 那 7 个 + 空格
        "中文 a",                        // 非 ASCII ⇒ UTF-8 三字节
        "😀",                            // 代理对 ⇒ UTF-8 四字节
        "",
        "%41",                          // 已转义的要不要二次转义
        "~`!@#$%^&*()_+-=[]{}\\|;':\",./<>?", // 全部标点（逐字符看谁被留）
    };

    // ---- UnicodeUtil 的输入夹具（全部运行期拼，见上面词法坑）----
    static final String[] UNI = {
        u("4e2d") + u("6587"),          // 两个 BMP 码点
        u("D83D") + u("DE00"),          // 代理对（合法配对）
        u("0041") + u("0042"),          // ASCII 区间的转义
        u("ZZZZ") + u("12"),            // 坏十六进制 / 不足四位数
        "" + B + "u",                    // 裸的一个"斜杠 u"
        "no escapes",
        uu("4e2d"),                      // 双反斜杠：不该被认成转义
        "" + B,                          // 单个反斜杠结尾
        u("0000") + u("0009"),          // 控制字符码点
        u("FFFF"),                       // 上边界
        "x" + u("4e2d") + "y",          // 混合
        "",
    };

    public static void main(String[] args) {
        // 自检：夹具长度不对 ⇒ 词法又吃掉了转义，整批读数作废
        expectLen(u("4e2d"), 6);
        expectLen(uu("4e2d"), 7);
        expectLen("a" + u("4e2d") + "b", 8);

        for (String s : ENT) {
            row("E", "escapeXml", s, () -> EscapeUtil.escapeXml(s));
            row("E", "unescapeXml", s, () -> EscapeUtil.unescapeXml(s));
            row("E", "escapeHtml4", s, () -> EscapeUtil.escapeHtml4(s));
            row("E", "unescapeHtml4", s, () -> EscapeUtil.unescapeHtml4(s));
        }
        // null 档：CharSequence 重载与 String 重载分开问（两条出口可能不同）
        row("E", "escapeXml(null)", null, () -> EscapeUtil.escapeXml((CharSequence) null));
        row("E", "escapeHtml4(null)", null, () -> EscapeUtil.escapeHtml4((CharSequence) null));
        row("E", "unescapeXml(null)", null, () -> EscapeUtil.unescapeXml((CharSequence) null));
        row("E", "unescapeHtml4(null)", null, () -> EscapeUtil.unescapeHtml4((CharSequence) null));
        row("E", "unescape(null)", null, () -> EscapeUtil.unescape((String) null));
        row("E", "safeUnescape(null)", null, () -> EscapeUtil.safeUnescape((String) null));

        for (String s : PCT) {
            row("P", "escape", s, () -> EscapeUtil.escape(s));
            row("P", "escapeAll", s, () -> EscapeUtil.escapeAll(s));
            row("P", "unescape", s, () -> EscapeUtil.unescape(s));
            row("P", "safeUnescape", s, () -> EscapeUtil.safeUnescape(s));
            // Filter 变体：三条判据各打一档——全收、全拒、只收 ASCII 字母
            //（原先那档用 `Character.isLetter` 的 Unicode 类别表，MoonBit core 没有对位谓词，
            //  造出来的用例在实现侧只能再抄一张表——收范围到 ASCII，两侧就是同一张嘴）
            row("P", "escape(filterKeepAll)", s, () -> EscapeUtil.escape(s, c -> true));
            row("P", "escape(filterKeepNone)", s, () -> EscapeUtil.escape(s, c -> false));
            row("P", "escape(filterAsciiAlpha)", s, () -> EscapeUtil.escape(s, c -> c != null && Character.isLetter(c.charValue()) && c.charValue() < 0x80));
        }
        row("P", "escape(null)", null, () -> EscapeUtil.escape((CharSequence) null));
        row("P", "escapeAll(null)", null, () -> EscapeUtil.escapeAll((CharSequence) null));
        row("P", "escape(null,keepAll)", null, () -> EscapeUtil.escape((CharSequence) null, c -> true));

        // escape(CharSequence) 的默认过滤器是 private 常量（NOT_ESCAPE_CHARS = "*@-_+./"，javap 现读），
        // 这里用同形状的公开过滤器把"过滤器参与方式"钉住：只收非 ASCII 字母数字。
        Filter<Character> notAlnumAscii = c -> c == null || !(c.charValue() >= 'a' && c.charValue() <= 'z'
                || c.charValue() >= 'A' && c.charValue() <= 'Z' || c.charValue() >= '0' && c.charValue() <= '9');
        for (String s : PCT) {
            row("P", "escape(filterNotAlnum)", s, () -> EscapeUtil.escape(s, notAlnumAscii));
        }

        for (String s : UNI) {
            row("U", "toString", s, () -> UnicodeUtil.toString(s));
            row("U", "toUnicode", s, () -> UnicodeUtil.toUnicode(s));
            row("U", "toUnicode(true)", s, () -> UnicodeUtil.toUnicode(s, true));
            row("U", "toUnicode(false)", s, () -> UnicodeUtil.toUnicode(s, false));
        }
        row("U", "toString(null)", null, () -> UnicodeUtil.toString((String) null));
        row("U", "toUnicode(null)", null, () -> UnicodeUtil.toUnicode((String) null));
        row("U", "toUnicode(char)", "zhong", () -> UnicodeUtil.toUnicode('中'));

        // char/int 档逐码点取样：ASCII 边界、BMP、代理区、以及 int 的越界档
        int[] cps = {0, 9, 32, 65, 127, 128, 255, 0x2000, 0x4e2d, 0xd800, 0xdfff, 0xffff, 0x10000, 0x1f600, -1, 0x7fffffff};
        for (int cp : cps) {
            out("N", "toUnicode(int)", "int:" + cp, safe(() -> UnicodeUtil.toUnicode(cp)));
            if (cp >= 0 && cp <= 0xffff) {
                out("N", "toUnicode(char)", "char:" + cp, safe(() -> UnicodeUtil.toUnicode((char) cp)));
            }
        }
        // toString 的逐档：只喂**字面转义串**，看它认不认代理对、位数不足的、越界的
        String[] raws = {u("4e2d"), u("D83D"), u("DC00"), u("D83D") + u("DE00"), u("4e2"), u("12345"),
            uu("4e2d"), u("ZZZZ"), u("0000"), u("ffff"), u("FFFF"), u("8000"), u("8fff"),
            "x" + u("4e2d") + "y", "" + B + "u4e", u("4e2d") + "" + B};
        for (String r : raws) {
            out("R", "toString", esc(r), safe(() -> UnicodeUtil.toString(r)));
        }
        // 反向闭环：toUnicode 的输出喂回 toString，应当回到原串（幂等档，逐夹具取数）
        for (String s : UNI) {
            row("I", "roundtrip", s, () -> UnicodeUtil.toString(UnicodeUtil.toUnicode(s)));
            row("I", "roundtrip(true)", s, () -> UnicodeUtil.toString(UnicodeUtil.toUnicode(s, true)));
        }
    }

    static void expectLen(String s, int want) {
        if (s.length() != want) {
            throw new IllegalStateException("fixture length " + s.length() + " != " + want
                    + " —— 词法前置翻译吃掉了斜杠-u，本批读数作废");
        }
    }

    interface Call {
        String get();
    }

    static void row(String fam, String m, String in, Call c) {
        out(fam, m, esc(in), safe(c));
    }

    static String safe(Call c) {
        try {
            String r = c.get();
            return r == null ? "{null}" : esc(r);
        } catch (Throwable t) {
            String msg = t.getMessage();
            return "ERR:" + t.getClass().getSimpleName() + (msg == null ? "" : ":" + esc(msg));
        }
    }

    static void out(String fam, String m, String in, String r) {
        System.out.println(fam + "|" + m + "|" + in + "|" + r);
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
