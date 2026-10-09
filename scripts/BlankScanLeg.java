// moon-hutool/text —— "空白"这条谓词的**三方对撞**腿。
//
// 起因：UrlPureLeg 扫出 `URLUtil.encodeBlank` 的空白集是 15 个区间，其中 **U+0085 不在**，
// 而本仓 `text.is_blank` 的口径（spec 1.1 第 3 行）写的是"core `Char::is_whitespace` ∪ hutool
// 独有 7 码点"——core 的白名单里**有** U+0085。两条要是不等价，就不是"文档措辞不齐"，
// 是已交付的 `is_blank`/`trim` 与参照行为有一档差。所以这里把三个来源一次打全：
//   J = `Character.isWhitespace`（Java 标准库那一档，hutool 的原料）
//   B = `StrUtil.isBlank(单字符)`（本仓 is_blank 的对位物，spec 1.1 引的就是它）
//   E = `URLUtil.encodeBlank(单字符)`（是否出 %20）
//   C = `CharUtil.isBlankChar`（hutool 自己的谓词，公开法）
// 输出：每码点一行 `cp|J|B|E|C`，末了四张区间表 + 两两差异清单（差异为空才敢说"同源"）。
import cn.hutool.core.util.CharUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.core.util.URLUtil;

public class BlankScanLeg {
    public static void main(String[] args) {
        StringBuilder jb = new StringBuilder();
        StringBuilder bb = new StringBuilder();
        StringBuilder eb = new StringBuilder();
        StringBuilder cb = new StringBuilder();
        StringBuilder diffBJ = new StringBuilder();
        StringBuilder diffBE = new StringBuilder();
        StringBuilder diffBC = new StringBuilder();
        StringBuilder db = new StringBuilder();
        StringBuilder tb = new StringBuilder();
        StringBuilder diffBD = new StringBuilder();
        StringBuilder diffBT = new StringBuilder();
        for (int cp = 0; cp <= 0xffff; cp++) {
            if (cp >= 0xd800 && cp <= 0xdfff) continue;   // 代理码元不能单独成串
            String one = "" + (char) cp;
            boolean j = Character.isWhitespace(cp);
            boolean b = StrUtil.isBlank(one);
            boolean e = URLUtil.encodeBlank(one).equals("%20");
            boolean c = CharUtil.isBlankChar((char) cp);
            // 第四路：`StrUtil.cleanBlank` 与 `StrUtil.trim` 各自扫一遍——
            // typex/datasize 的 `ds_is_blank` 是照 cleanBlank 建的表，若 cleanBlank 与 isBlank
            // 不同表，那才是"两个谓词"；同表就说明 datasize 那份少抄了几个码点。
            boolean d = StrUtil.cleanBlank(one).isEmpty();
            boolean t = StrUtil.trim(one).isEmpty() && !one.isEmpty();
            if (b) append(bb, cp);
            if (j) append(jb, cp);
            if (e) append(eb, cp);
            if (c) append(cb, cp);
            if (d) append(db, cp);
            if (t) append(tb, cp);
            if (b != j) append(diffBJ, cp);
            if (b != e) append(diffBE, cp);
            if (b != c) append(diffBC, cp);
            if (b != d) append(diffBD, cp);
            if (b != t) append(diffBT, cp);
        }
        System.out.println("RANGES|isBlank(B)|" + bb);
        System.out.println("RANGES|Character.isWhitespace(J)|" + jb);
        System.out.println("RANGES|encodeBlank(E)|" + eb);
        System.out.println("RANGES|CharUtil.isBlankChar(C)|" + cb);
        System.out.println("DIFF|B-vs-J|" + diffBJ);
        System.out.println("DIFF|B-vs-E|" + diffBE);
        System.out.println("DIFF|B-vs-C|" + diffBC);
        System.out.println("RANGES|cleanBlank(D)|" + db);
        System.out.println("RANGES|trim-blank(T)|" + tb);
        System.out.println("DIFF|B-vs-D|" + diffBD);
        System.out.println("DIFF|B-vs-T|" + diffBT);
        // 三个边界档单独再打一次，免得区间表看花眼
        int[] probes = {0x00, 0x08, 0x09, 0x0b, 0x0c, 0x0d, 0x1b, 0x1c, 0x1f, 0x20, 0x85, 0xa0,
            0x1680, 0x180e, 0x2000, 0x200a, 0x200b, 0x200c, 0x2028, 0x2029, 0x202a, 0x202b, 0x202f,
            0x205f, 0x2800, 0x3000, 0x3164, 0xfeff, 0xffff};
        for (int cp : probes) {
            String one = "" + (char) cp;
            System.out.printf("P|%04x|J=%s|B=%s|E=%s|C=%s%n", cp, Character.isWhitespace(cp),
                    StrUtil.isBlank(one), URLUtil.encodeBlank(one).equals("%20"), CharUtil.isBlankChar((char) cp));
        }
    }

    static void append(StringBuilder sb, int cp) {
        if (sb.length() > 0) sb.append(",");
        sb.append(String.format("%04x", cp));
    }
}
