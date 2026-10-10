// moon-hutool/codec 批③ —— 腿二：`Rot` 的移位臂（ASCII 档，与 Caesar 的 Unicode 守卫正相反）。
//
// 字节码现读的三族：digit（`0..9`，仅 `numberSupport=true` 时参与）、upper（`A..Z`）、lower（`a..z`），
// 全部是**码位区间判断**，所以 `中`/`é` 原样透传——与 `Caesar` 用 `Character.isLetter` 那条正好对撞，
// 两件的守卫必须在契约里分开写，不能"顺手统一成一个字母表"。
// 另两处要冻：`encode13(String)` 单参档把 `numberSupport` 给的是 `true` 还是 `false`（字节码 `iconst_1` ⇒ true）；
// 以及负 shift 下 `% 10` / `% 26` 在 Java 里保留被除数符号 ⇒ 结果可以落到区间外（`'0' + (-1)` 变 `/`）。
//
// 跑法：
//   javac -encoding UTF-8 -cp hutool-all-5.8.37.jar -d . RotLeg.java
//   java  -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -cp "hutool-all-5.8.37.jar;." RotLeg
public class RotLeg {

    static String esc(String s) {
        if (s == null) return "{null}";
        StringBuilder b = new StringBuilder();
        for (char c : s.toCharArray()) {
            if (c >= 32 && c < 127 && c != '\\') b.append(c);
            else b.append(String.format("\\u%04x", (int) c));
        }
        return b.toString();
    }

    static String callEnc(String s, int shift, boolean num) {
        try {
            return esc(cn.hutool.core.codec.Rot.encode(s, shift, num));
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getName() + ":" + esc(String.valueOf(t.getMessage()));
        }
    }

    static String callDec(String s, int shift, boolean num) {
        try {
            return esc(cn.hutool.core.codec.Rot.decode(s, shift, num));
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getName() + ":" + esc(String.valueOf(t.getMessage()));
        }
    }

    public static void main(String[] args) {
        String[] inputs = {
            "", "A", "a", "Z", "z", "0", "9", "5", "abcXYZ", "ABCxyz", "0189", "a0z9",
            " 1!zZ", "Hello, World!", "中", "é", "Ω", "ß", "٣", "\u0000", "\t", "[", "`", ":", "@"
        };
        int[] shifts = { 0, 1, -1, 5, 10, -10, 13, -13, 25, 26, -26, 27, 52, 104, -104 };

        // 单参档：encode13(s) 到底是哪一档 numberSupport——拿一条含数字的夹具对撞
        for (String s : inputs) {
            String one = esc(cn.hutool.core.codec.Rot.encode13(s));
            String withTrue = callEnc(s, 13, true);
            String withFalse = callEnc(s, 13, false);
            System.out.println("RT|e13|" + esc(s) + "||" + one
                + "|true?" + (one.equals(withTrue) ? 1 : 0)
                + "|false?" + (one.equals(withFalse) ? 1 : 0));
            String d13 = esc(cn.hutool.core.codec.Rot.decode13(s));
            System.out.println("RT|d13|" + esc(s) + "||" + d13
                + "|dec13selfinv|" + (d13.equals(one) ? 1 : 0));
        }

        for (boolean num : new boolean[] { false, true }) {
            for (int sh : shifts) {
                for (String s : inputs) {
                    System.out.println("RT|enc|" + esc(s) + "|" + sh + "|" + num + "||" + callEnc(s, sh, num));
                }
            }
            for (int sh : shifts) {
                for (String s : inputs) {
                    System.out.println("RT|dec|" + esc(s) + "|" + sh + "|" + num + "||" + callDec(s, sh, num));
                }
            }
        }

        // 往返：encode(sh) 再 decode(sh)，同 num 档
        for (boolean num : new boolean[] { false, true }) {
            for (int sh : shifts) {
                for (String s : inputs) {
                    try {
                        String e = cn.hutool.core.codec.Rot.encode(s, sh, num);
                        String back = cn.hutool.core.codec.Rot.decode(e, sh, num);
                        System.out.println("RT|rt|" + esc(s) + "|" + sh + "|" + num + "||"
                            + (back.equals(s) ? "SAME" : "DIFF:" + esc(back)));
                    } catch (Throwable t) {
                        System.out.println("RT|rt|" + esc(s) + "|" + sh + "|" + num + "||ERR:" + t.getClass().getName());
                    }
                }
            }
        }

        System.out.println("RT|null-enc||" + callEnc(null, 3, true));
        System.out.println("RT|null-dec||" + callDec(null, 3, true));
        System.exit(0);
    }
}
