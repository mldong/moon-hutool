// moon-hutool/codec 批③ —— 腿一：`Caesar` 的移位臂。
//
// 为什么这条腿必须先跑：字节码现读两处反直觉——
//   ① 守卫是 `Character.isLetter(c)`（Unicode 档），**不是** "在不在 52 字符表里"；
//   ② `encodeChar` 取模后**不做负数归一**，而 `decodeChar` 做了（`if (i < 0) i += 52`）。
// 两条合起来 ⇒ 一个"是字母但不在表里"的字符（`中`/`é`/`Ω`）在 `encode(s, 0)` 上会走到
// `TABLE.charAt(-1)`，参照侧直接抛 `StringIndexOutOfBoundsException`；`decode` 同一档却正常出字符。
// 这一族只能整片打出来冻，不能"觉得该怎样"就写进契约。
//
// 跑法（含非 ASCII 夹具，必须显式 UTF-8；stdout 也要 UTF-8，否则 Windows 控制台把中文吞成 mojibake）：
//   javac -encoding UTF-8 -cp hutool-all-5.8.37.jar -d . CaesarLeg.java
//   java  -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -cp "hutool-all-5.8.37.jar;." CaesarLeg
import java.lang.reflect.Field;

public class CaesarLeg {

    // 表常量反射读，不手抄
    static String table() {
        try {
            Field f = Class.forName("cn.hutool.core.codec.Caesar").getField("TABLE");
            return (String) f.get(null);
        } catch (Throwable t) {
            return "{ERR}" + t.getClass().getName();
        }
    }

    static String esc(String s) {
        if (s == null) return "{null}";
        StringBuilder b = new StringBuilder();
        for (char c : s.toCharArray()) {
            if (c >= 32 && c < 127 && c != '\\') b.append(c);
            else b.append(String.format("\\u%04x", (int) c));
        }
        return b.toString();
    }

    static String codes(String s) {
        if (s == null) return "{null}";
        StringBuilder b = new StringBuilder();
        for (char c : s.toCharArray()) {
            if (b.length() > 0) b.append(',');
            b.append((int) c);
        }
        return b.toString();
    }

    static String call(String which, String s, int shift) {
        try {
            return which.equals("enc")
                ? esc(cn.hutool.core.codec.Caesar.encode(s, shift))
                : esc(cn.hutool.core.codec.Caesar.decode(s, shift));
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getName() + ":" + esc(String.valueOf(t.getMessage()));
        }
    }

    // 往返：拿**原始串**（不是 esc 之后的）来回喂，只在两边都不抛的档上打
    static String raw(String which, String s, int shift) {
        try {
            return which.equals("enc")
                ? cn.hutool.core.codec.Caesar.encode(s, shift)
                : cn.hutool.core.codec.Caesar.decode(s, shift);
        } catch (Throwable e) {
            return null;
        }
    }

    public static void main(String[] args) {
        String t = table();
        System.out.println("CC|table-len||" + (t.length()));
        System.out.println("CC|table-esc||" + esc(t));
        System.out.println("CC|table-codes||" + codes(t));

        String[] inputs = {
            "", "A", "a", "Z", "z", "AaZz", "Ab9! ", "0", "9", " ", "!",
            "中", "é", "Ω", "ß", "א", "٣", "\u0000", "\t", "\ud83d\ude00", "Emojié"
        };
        int[] shifts = { 0, 1, -1, 2, 13, -13, 25, 26, -26, 27, 52, -52, 53, 104, -104 };

        // isLetter 单独打一列：本库的守卫要跟它对齐还是收窄，这条是判据的根
        for (String s : inputs) {
            StringBuilder b = new StringBuilder();
            for (char c : s.toCharArray()) b.append(Character.isLetter(c) ? 1 : 0);
            System.out.println("CC|isLetter|" + esc(s) + "||" + b);
        }

        for (int sh : shifts) {
            for (String s : inputs) {
                System.out.println("CC|enc|" + esc(s) + "|" + sh + "||" + call("enc", s, sh));
            }
        }
        for (int sh : shifts) {
            for (String s : inputs) {
                System.out.println("CC|dec|" + esc(s) + "|" + sh + "||" + call("dec", s, sh));
            }
        }

        // 往返：只在两边都不抛的档上打
        for (int sh : shifts) {
            for (String s : inputs) {
                String e = raw("enc", s, sh);
                if (e == null) {
                    System.out.println("CC|rt|" + esc(s) + "|" + sh + "||SKIP-enc-throws");
                    continue;
                }
                String back = raw("dec", e, sh);
                if (back == null) {
                    System.out.println("CC|rt|" + esc(s) + "|" + sh + "||SKIP-dec-throws");
                    continue;
                }
                System.out.println("CC|rt|" + esc(s) + "|" + sh + "||"
                    + (back.equals(s) ? "SAME" : "DIFF:" + esc(back)));
            }
        }

        // null 档：Assert.notNull 的异常类名与文案都是契约的一部分
        System.out.println("CC|null-enc||" + call("enc", null, 3));
        System.out.println("CC|null-dec||" + call("dec", null, 3));
        System.exit(0);
    }
}
