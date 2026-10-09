// moon-hutool/text —— UnicodeUtil 的"哪些码点原样出"逐位扫（判据腿）。
//
// 为什么还要这条：参照的 toUnicode(String)（默认第二参 true）对字母 a 原样、对换行符却出
// 反斜杠-u-000a ⇒ "只转非 ASCII"这句常识是**错的**。边界（看着像 0x20..0x7E）
// 只能逐位问，抽样会给出一条写进 spec 就骗人的规则。
// 同时扫 false 档：那档应当一位都不留，任何"原样"都是读数异常。
import cn.hutool.core.text.UnicodeUtil;

public class UnicodeScan {
    public static void main(String[] args) {
        StringBuilder keep = new StringBuilder();
        StringBuilder keepFalse = new StringBuilder();
        int run = -1, runF = -1;
        for (int cp = 0; cp <= 0xffff; cp++) {
            if (cp >= 0xd800 && cp <= 0xdfff) continue;   // 孤立代理不参与（本库构造不出该形状）
            char c = (char) cp;
            boolean k = UnicodeUtil.toUnicode("" + c).equals("" + c);
            boolean kf = UnicodeUtil.toUnicode("" + c, false).equals("" + c);
            if (k && run < 0) run = cp;
            if (!k && run >= 0) { append(keep, run, cp - 1); run = -1; }
            if (kf && runF < 0) runF = cp;
            if (!kf && runF >= 0) { append(keepFalse, runF, cp - 1); runF = -1; }
        }
        if (run >= 0) append(keep, run, 0xffff);
        if (runF >= 0) append(keepFalse, runF, 0xffff);
        System.out.println("KEEP|toUnicode(true)|" + keep);
        System.out.println("KEEP|toUnicode(false)|" + keepFalse);
        int[] edges = {0x20, 0x7e, 0x7f, 0x1f, 0xa0, 0xff, 0x100};
        for (int cp : edges) {
            System.out.println("EDGE|" + String.format("%04x", cp) + "|" + UnicodeUtil.toUnicode("" + (char) cp));
        }
    }

    static void append(StringBuilder sb, int a, int b) {
        if (sb.length() > 0) sb.append(",");
        sb.append(String.format("%04x-%04x", a, b));
    }
}
