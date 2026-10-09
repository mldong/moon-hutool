// moon-hutool/text —— escape 的"不转义集"到底是哪一条谓词（**判据腿**，产表用）。
//
// 为什么要这条腿：EscapeLeg2 的抽样把"ª 被留下"外推成"Unicode 字母都被留下"是**错的**。
// javap -c 现读 `EscapeUtil.lambda$static$0` 的字节码，谓词是
//   isDigit(c) || isLowerCase(c) || isUpperCase(c) || NOT_ESCAPE_CHARS.contains(c)
// 三个都是 `Character` 的 **Unicode 分类法**（含 Other_Lowercase/Other_Uppercase，
// 所以 Roman  numeral Ⅰ、全角 Ａ 被留下），而**不是** isLetterOrDigit——这正好解释了
// ƻ(U+01BB, Lt) 被转、あ(U+3041, Lo) 被转、α(Ll)/А(Lu)/ɐ(Ll) 被留。
// MoonBit core 只有 ASCII 档的 Char.is_ascii_alphabetic 一类判据，没有 Unicode 表 ⇒
// 想不自创语义就只能把这条谓词的**结果**当数据带进来。带多大的表由本腿量：
//   ① 先证"谓词==行为"（BMP 全枚举逐码点对拍，任何一处不符都要显式报出来）；
//   ② 再把"被留下"的码点压成区间表；
//   ③ 顺带证一件省掉一整张表的事：**非 BMP 一律走代理对**（两个 Cs 码元都被转），
//      所以"被留下"的集合天然只可能落在 BMP 内，表不需要覆盖 0x10000+。
//
// 跑法同 EscapeLeg。输出行：MISMATCH / RANGES / count / ASTRAL。
import cn.hutool.core.util.EscapeUtil;

public class EscapeLeg3 {

    static final String NOT_ESCAPE_CHARS = "*@-_+./";

    static boolean keep(char c) {
        return Character.isDigit(c) || Character.isLowerCase(c)
                || Character.isUpperCase(c) || NOT_ESCAPE_CHARS.indexOf(c) >= 0;
    }

    public static void main(String[] args) {
        int mismatch = 0;
        StringBuilder ranges = new StringBuilder();
        boolean prev = false;
        int start = -1;
        for (int cp = 0; cp <= 0xffff; cp++) {
            char c = (char) cp;
            String one = EscapeUtil.escape("" + c);
            boolean kept = one.length() == 1 && one.charAt(0) == c;
            if (kept != keep(c)) {
                mismatch++;
                if (mismatch <= 20) {
                    System.out.printf("MISMATCH|%04x|行为=%s|谓词=%s%n", cp, one, keep(c));
                }
            }
            if (kept && !prev) start = cp;
            if (!kept && prev) append(ranges, start, cp - 1);
            prev = kept;
        }
        if (prev) append(ranges, start, 0xffff);
        System.out.println("MISMATCH|count|" + mismatch);
        System.out.println("RANGES|" + ranges);
        System.out.println("RANGES|count|" + (ranges.length() == 0 ? 0 : ranges.toString().split(",").length));

        // ③ 非 BMP：逐个代理码元看，确认"整族都被转"⇒ 表只覆盖 BMP 就够
        int[] astral = {0x10000, 0x1d400, 0x1f600, 0x20000, 0xe0001};
        for (int cp : astral) {
            String s = new String(Character.toChars(cp));
            System.out.println("ASTRAL|" + Integer.toHexString(cp) + "|" + EscapeUtil.escape(s)
                    + "|surrogates=" + Integer.toHexString(s.charAt(0)) + "," + Integer.toHexString(s.charAt(1)));
            // 代理码元按谓词也都该被转
            System.out.println("ASTRAL|keep?|" + Integer.toHexString(cp) + "|"
                    + keep(s.charAt(0)) + "," + keep(s.charAt(1)));
        }
        // 数字档抽查：Nd 之外还有 No/Nl（如上标 ²、罗马数字 Ⅰ）——谓词只认 isDigit(Nd)，
        // 这一条决定了 ² 转不转，必须留读数
        int[] digits = {'0', 0x0660, 0x06f1, 0xb2, 0xb3, 0xb9, 0xbc, 0x2160, 0x2460, 0x1d7ce};
        for (int cp : digits) {
            if (cp <= 0xffff) {
                System.out.println("DIGIT|" + Integer.toHexString(cp) + "|" + EscapeUtil.escape("" + (char) cp)
                        + "|isDigit=" + Character.isDigit(cp) + "|keep?=" + keep((char) cp));
            }
        }
    }

    static void append(StringBuilder sb, int a, int b) {
        if (sb.length() > 0) sb.append(",");
        sb.append(String.format("%04x-%04x", a, b));
    }
}
