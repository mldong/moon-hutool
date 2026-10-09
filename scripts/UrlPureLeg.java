// moon-hutool/codec —— URLUtil 的**纯字符串半边**参照腿。
//
// 为什么只收三件：`URLUtil` 其余公开法要么走 `java.net.URI/URL`（宿主解析器）、要么走
// `Charset` 编解码（`encode/decode` 一族在 `URLEncodeUtil` 父类里，要 UTF-8 字节面），
// 本库 codec 已承接的是"百分号编解码"那一族；这里补的三件是**不碰宿主**的组装面：
//   completeUrl(baseUrl, url)  —— 相对/绝对拼接（判断"是不是全 URL"用的正是已登记的那半）
//   getDataUri(mime, charset, data[, attributes...])  —— data: URI 组装
//   getDataUriBase64(mime, base64)
//   encodeBlank(CharSequence)   —— null/空档的形状
// 三件都只吃串、只出串，腿能全覆盖 ⇒ 期望值一条都不用手写。
//
// 行形状：`<族>|<方法>|<入参1>|<入参2>|<读数>`。
import cn.hutool.core.util.URLUtil;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

public class UrlPureLeg {

    static final String[] BASES = {
        "http://a.com", "http://a.com/", "http://a.com/api", "http://a.com/api/",
        "http://a.com/api?v=1", "http://a.com/api#f", "https://a.com", "ftp://a.com:21/x/",
        "", "/", "a", "a/", null, "http://a.com//", "http:/a", "http://", "://x",
    };
    static final String[] SUBS = {
        "b/c", "/b/c", "http://b.com/x", "https://b.com", "//cdn.b.com/x.js", "data:text/plain,x",
        "mailto:a@b.com", "?v=2", "#frag", "", null, "b", "./b", "../b", "b?c#d", "B/C",
        "javascript:alert(1)", "tel:123", "urn:isbn:1", "x/y/z.w",
    };

    public static void main(String[] args) {
        for (String b : BASES) {
            for (String s : SUBS) {
                System.out.println("C|completeUrl|" + esc(b) + "|" + esc(s) + "|"
                        + esc(safes(() -> URLUtil.completeUrl(b, s), "cu")));
            }
        }
        // getDataUri：mime 缺省、charset 缺省/怪值、data 空/null/含百分号与空格/中文、属性多枚
        String[] mimes = {"text/plain", "", null, "image/png", "application/json"};
        String[] charsets = {"utf-8", "GBK", "gbk", "", null, "utf-16", "nope"};
        String[] datas = {"hello world", "a b&c=d", "中文", "", null, "100%", "x\ny"};
        for (String m : mimes) {
            for (String cs : charsets) {
                for (String d : datas) {
                    System.out.println("D|getDataUri(3)|" + esc(m) + "|" + esc(cs) + "|" + esc(d) + "|"
                            + esc(safes(() -> URLUtil.getDataUri(m, cs, d), "cs=" + esc(cs))));
                }
            }
        }
        // 四参档：javap 现读第 4 参是**单个 String**（不是 varargs），语义由这几条读数定
        String[] attrs = {"a=1", "", null, ";base64", "x y"};
        for (String at : attrs) {
            String out;
            try {
                out = URLUtil.getDataUri("text/plain", StandardCharsets.UTF_8, "hi", at);
            } catch (Throwable t) {
                out = "ERR:" + t.getClass().getSimpleName() + ":" + t.getMessage();
            }
            System.out.println("D|getDataUri(4)|" + esc(at) + "|" + esc(out));
        }
        String[] b64s = {"aGk=", "", null, "not-base64!!"};
        for (String m : new String[] {"text/plain", null, ""}) {
            for (String s : b64s) {
                System.out.println("D|getDataUriBase64|" + esc(m) + "|" + esc(s) + "|"
                        + esc(safes(() -> URLUtil.getDataUriBase64(m, s), "b64")));
            }
        }
        // encodeBlank：null / 空 / 空白 / 有值 / 含空格
        Object[] blanks = {null, "", " ", "  ", "\t", "\n", "a", " a ", "中文"};
        for (Object o : blanks) {
            String s = (String) o;
            System.out.println("B|encodeBlank|" + esc(s) + "|" + esc(safes(() -> URLUtil.encodeBlank(s), "eb")));
        }
        // 参照的 encodeBlank 对 null 的形状是这条腿唯一不能靠猜的出口
        System.out.println("B|encodeBlank(nullCharSeq)|{null}|"
                + esc(safes(() -> URLUtil.encodeBlank((CharSequence) null), "eb")));
        // "空白"到底怎么定义：逐码点问（决定本库的谓词形状——是 isspace 还是只认 0x20）。
        // 非 BMP 也问一档：代理码元各自算不算空白。
        for (int cp = 0; cp <= 0x20; cp++) {
            String one = "" + (char) cp;
            System.out.println("W|encodeBlank|u" + String.format("%04x", cp) + "|" + esc(safes(() -> URLUtil.encodeBlank(one), "w")));
        }
        int[] ws = {0x7f, 0x85, 0xa0, 0x1680, 0x2000, 0x200a, 0x2028, 0x202f, 0x205f, 0x3000, 0xfeff};
        for (int cp : ws) {
            String one = "" + (char) cp;
            System.out.println("W|encodeBlank|u" + String.format("%04x", cp) + "|" + esc(safes(() -> URLUtil.encodeBlank(one), "w"))
                    + "|isWhitespace=" + Character.isWhitespace(cp));
        }
        // 混合串里"整串空白"与"含空白"两档的分别（判断它是逐字符替换还是整串条件）
        String[] mix = {" \t\n", "a\tb", "\u00a0x", "x\u2002y", "  a  ", "\r\n", " "};
        for (String s : mix) {
            System.out.println("W|encodeBlank|mix|" + esc(s) + "|" + esc(safes(() -> URLUtil.encodeBlank(s), "w")));
        }
        // 全 BMP 扫"算不算空白"，压成区间表：这条谓词就是参照 encodeBlank 的全部语义，
        // 抽样会漏（实测 0x00、0xA0、0x202F、0xFEFF 都不在 `Character.isWhitespace` 里，
        // 参照却一样替换成 %20 ⇒ 它是 hutool 的 isBlankChar 那一族，不是 isWhitespace）。
        StringBuilder ranges = new StringBuilder();
        int run = -1;
        for (int cp = 0; cp <= 0xffff; cp++) {
            final char one = (char) cp;
            String out = esc(safes(() -> URLUtil.encodeBlank("" + one), "s"));
            boolean blank = out.equals("%20");
            if (blank && run < 0) run = cp;
            if (!blank && run >= 0) {
                if (ranges.length() > 0) ranges.append(",");
                ranges.append(String.format("%04x-%04x", run, cp - 1));
                run = -1;
            }
        }
        if (run >= 0) {
            if (ranges.length() > 0) ranges.append(",");
            ranges.append(String.format("%04x-%04x", run, 0xffff));
        }
        System.out.println("W|blank_ranges|" + ranges);
        System.out.println("W|blank_ranges|count|" + (ranges.length() == 0 ? 0 : ranges.toString().split(",").length));
        // 非 BMP：代理码元各自算什么（参照按码元走，两半都不是空白 ⇒ 原样出）
        int[] astral = {0x10000, 0x20000, 0x1f600};
        for (int cp : astral) {
            String pair = new String(Character.toChars(cp));
            System.out.println("W|encodeBlank|astral|u" + String.format("%05x", cp) + "|"
                    + esc(safes(() -> URLUtil.encodeBlank(pair), "a")));
        }
    }

    interface Cs {
        String get();
    }

    static String safes(Cs c, String tag) {
        try {
            return c.get();
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getSimpleName() + ":" + t.getMessage();
        }
    }

    static String esc(String s) {
        if (s == null) return "{null}";
        StringBuilder b = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            if (ch >= 0x20 && ch <= 0x7e && ch != '|') b.append(ch);
            else b.append(String.format("{u%04x}", (int) ch));
        }
        return b.toString();
    }
}
