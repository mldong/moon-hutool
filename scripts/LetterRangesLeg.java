// moon-hutool/codec 批③ —— 腿五：`Character.isLetter` 的 BMP 区间表（Caesar 守卫的数据来源）。
//
// 为什么要有这条腿：`Caesar.encode` 的守卫是 `Character.isLetter(char)`（Unicode 档：Lu/Ll/Lt/Lm/Lo），
// 而本版 MoonBit core 的 `Char` **没有任何 Unicode 字母谓词**（现读 builtin/char.mbt：公开 is_* 只有
// ASCII 档与 control/digit/whitespace/numeric/printable/bmp）。⇒ 守卫要忠于参照，只能把这张判定表
// 自己带进来（先例：`date/zone_table.mbt` 那种生成件 + `dfa` 轮"码表用规模读数 + 边界点钉，不逐位钉"）。
//
// 本腿输出的三件事，正好是生成件与用例的两类判据：
//   ① 全域量（count / sum-mod）——生成件表与参照**同判**的凭据，用例里逐条对撞；
//   ② 区间表（半开 [lo,hi)，相邻字母区间合并）——表本体，由 `scripts/gen_letter_table.py` 灌进 `.mbt`；
//   ③ 生产者指纹（java.version）——`isLetter` 的底层是 JDK 自带的 Unicode 数据，换 JDK 大版本可能挪区间，
//      所以这张表冻的是"参照代次 5.8.37 × 这台 JDK"的同判，spec 必须把这个依赖写死而不是含糊过去。
// 另带一小段 surrogate 事实：`isLetter` 按 **UTF-16 码元**判，代理对的两个码元都不算字母
// ⇒ 本库逐码元摊（`utf16_codes`），不许按码位走（先例：hash 轮那条"字符在两家语言里不是一个东西"）。
//
// 跑法：
//   javac -encoding UTF-8 -cp hutool-all-5.8.37.jar -d . LetterRangesLeg.java
//   java  -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -cp "hutool-all-5.8.37.jar;." LetterRangesLeg
public class LetterRangesLeg {
    public static void main(String[] args) {
        System.out.println("LR|java-version||" + System.getProperty("java.version")
            + "|vendor=" + System.getProperty("java.vendor"));

        long total = 0;
        long sum = 0;
        int start = -1;
        int ranges = 0;
        StringBuilder digestBlocks = new StringBuilder();
        for (int block = 0; block < 16; block++) {
            int n = 0;
            for (int i = 0; i < 0x1000; i++) {
                int c = (block << 12) | i;
                boolean letter = Character.isLetter((char) c);
                if (letter) {
                    n++;
                    total++;
                    sum = (sum + c) % 2147483647L;
                    if (start < 0) start = c;
                }
                if (letter != Character.isLetter((char) (c + 1)) && start >= 0) {
                    // 区间收尾：半开 [start, c+1)
                    System.out.println("LR|range||" + start + "," + (c + 1));
                    ranges++;
                    start = -1;
                }
            }
            digestBlocks.append(block).append(':').append(n).append(',');
        }
        System.out.println("LR|count||" + total);
        System.out.println("LR|sum-mod||" + sum);
        System.out.println("LR|range-count||" + ranges);
        System.out.println("LR|blocks||" + digestBlocks);

        // 代理码元都不算字母（这条决定本库必须逐 UTF-16 码元摊，而不是逐码位）
        int[] sur = { 0xd83d, 0xde00, 0xd7ff, 0xe000 };
        StringBuilder b = new StringBuilder();
        for (int c : sur) b.append(c).append('=').append(Character.isLetter((char) c) ? 1 : 0).append(',');
        System.out.println("LR|surrogate||" + b);

        // 六个边界点（生成件的"边界点"判据就钉这几个 + 上面两个全域量）
        int[] edge = { 0x41, 0x5a, 0x5b, 0x61, 0x7a, 0x7b, 0xaa, 0xab, 0x1c, 0x1d, 0x2ec, 0x2ed };
        StringBuilder e = new StringBuilder();
        for (int c : edge) e.append(c).append('=').append(Character.isLetter((char) c) ? 1 : 0).append(',');
        System.out.println("LR|edge||" + e);
        System.exit(0);
    }
}
