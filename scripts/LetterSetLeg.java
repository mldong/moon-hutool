// moon-hutool/codec 批③ —— 腿四：`isLetter` 谓词集对撞用（BMP 逐码元分块计数）。
//
// 为什么需要这一条：`Caesar` 的守卫是 `Character.isLetter(char)`（Unicode 档），而本库拿的是 core 的
// `Char.is_letter`。"两边大概一样"不能进契约——要的是**逐码位同判**的证据，且差异范围得能报出来。
// 姿势照 `dfa` 轮那张空白表扫描：按 0x1000 分块打计数，再加两个全域量（总数、码位和 mod 2^31）。
// MoonBit 侧同一份数字由 `scripts/` 外的临时探针工程产出，两份数字逐块相等才把守卫写成"同判"。
//
// 跑法：
//   javac -encoding UTF-8 -cp hutool-all-5.8.37.jar -d . LetterSetLeg.java
//   java  -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -cp "hutool-all-5.8.37.jar;." LetterSetLeg
public class LetterSetLeg {
    public static void main(String[] args) {
        long total = 0;
        long sum = 0;
        StringBuilder blocks = new StringBuilder();
        for (int b = 0; b < 16; b++) {   // BMP 就是 0..0xFFFF ⇒ 16 个 0x1000 块；写成 64/256 会因为 `(char)` 截断把每个码元数 4/16 次
            int n = 0;
            for (int i = 0; i < 0x1000; i++) {
                int c = (b << 12) | i;
                if (Character.isLetter((char) c)) {
                    n++;
                    total++;
                    sum = (sum + c) % 2147483647L;
                }
            }
            if (n > 0) blocks.append(b).append(':').append(n).append(',');
        }
        System.out.println("LSET|bmp-total||" + total);
        System.out.println("LSET|bmp-sum-mod||" + sum);
        System.out.println("LSET|bmp-blocks||" + blocks);

        // 批③夹具那六个码位的单独读数（腿一里也有，这条是给守卫对撞用的最小集）
        int[] probe = { 0x41, 0x61, 0x5a, 0x7a, 0x30, 0x20, 0x21, 0x00e9, 0x03a9, 0x00df, 0x05d0, 0x0663, 0x4e2d, 0xd83d, 0xde00 };
        StringBuilder bits = new StringBuilder();
        for (int c : probe) bits.append(c).append('=').append(Character.isLetter((char) c) ? 1 : 0).append(',');
        System.out.println("LSET|probe||" + bits);
        System.exit(0);
    }
}
