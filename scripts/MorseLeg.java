// moon-hutool/codec 批③ —— 腿三：`Morse` 的码表与编解码臂。
//
// 两件私有可能量表（`ALPHABETS: Map<Integer,String>`、`DICTIONARIES: Map<String,Integer>`）由静态块
// `registerMorse` 灌进来，反射读原表、不手抄（先例：`rand` 轮常量表反射读、`bloom` 轮私有字段反射读）。
// 三个实例字段 `dit`/`dah`/`split` 是可覆盖的字符，所以编码形状不是常量——契约要分开冻：
// 默认档（`.`/`-`/空格）的整表读数 + 自定义档的一档对照，外加"表里没有的字符怎么办""反解撞到未知串怎么办"
// 这两族最容易顺手发明行为的臂。
//
// 跑法：
//   javac -encoding UTF-8 -cp hutool-all-5.8.37.jar -d . MorseLeg.java
//   java  -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -cp "hutool-all-5.8.37.jar;." MorseLeg
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class MorseLeg {

    static Object priv(String name) {
        try {
            Field f = Class.forName("cn.hutool.core.codec.Morse").getDeclaredField(name);
            f.setAccessible(true);
            return f.get(null);
        } catch (Throwable t) {
            return null;
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

    @SuppressWarnings("unchecked")
    static String enc(String s, char dit, char dah, char split) {
        try {
            return esc(new cn.hutool.core.codec.Morse(dit, dah, split).encode(s));
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getName() + ":" + esc(String.valueOf(t.getMessage()));
        }
    }

    @SuppressWarnings("unchecked")
    static String dec(String s, char dit, char dah, char split) {
        try {
            return esc(new cn.hutool.core.codec.Morse(dit, dah, split).decode(s));
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getName() + ":" + esc(String.valueOf(t.getMessage()));
        }
    }

    @SuppressWarnings("unchecked")
    public static void main(String[] args) {
        // ① 码表本体：规模 + 逐条（码位十进制 + 莫尔斯串），排序稳定可复跑
        Map<Integer, String> alph = (Map<Integer, String>) priv("ALPHABETS");
        Map<String, Integer> dict = (Map<String, Integer>) priv("DICTIONARIES");
        System.out.println("MS|alph-size||" + (alph == null ? "{no-field}" : alph.size()));
        System.out.println("MS|dict-size||" + (dict == null ? "{no-field}" : dict.size()));
        if (alph != null) {
            List<Integer> keys = new ArrayList<Integer>(alph.keySet());
            Collections.sort(keys);
            StringBuilder sizes = new StringBuilder();
            for (int k : keys) {
                String v = alph.get(k);
                sizes.append(v.length()).append(',');
                System.out.println("MS|row|" + k + "||" + esc(v));
            }
            System.out.println("MS|code-len-csv||" + sizes);
            // 码表里出现过的符号字符（默认表用哪两个符号写的，反射表才是权威）
            java.util.TreeSet<String> sym = new java.util.TreeSet<String>();
            for (int k : keys) {
                for (char c : alph.get(k).toCharArray()) sym.add(String.format("\\u%04x", (int) c));
            }
            System.out.println("MS|symbols||" + sym);
        }
        if (dict != null) {
            // 反查表与正表是否严格互逆（撞车会在这里现形：同一个莫尔斯串注册了两个字符）
            int conflict = 0;
            for (Integer k : new ArrayList<Integer>(alph.keySet())) {
                String v = alph.get(k);
                Integer back = dict.get(v);
                if (back == null || back.intValue() != k.intValue()) conflict++;
            }
            System.out.println("MS|inverse-conflicts||" + conflict);
        }

        // ② 默认构造口的三个符号到底是什么（私有 final 字段，反射读）
        try {
            Class<?> mc = Class.forName("cn.hutool.core.codec.Morse");
            Object def = mc.getConstructor().newInstance();
            for (String name : new String[] { "dit", "dah", "split" }) {
                Field f = mc.getDeclaredField(name);
                f.setAccessible(true);
                char c = fChar(def, f);
                System.out.println("MS|default|" + name + "||" + ((int) c));
            }
        } catch (Throwable t) {
            System.out.println("MS|default||ERR:" + t.getClass().getName() + ":" + esc(String.valueOf(t.getMessage())));
        }

        // ③ 正表逐字符 encode（默认档）——一次把所有单字符读数拿到
        if (alph != null) {
            List<Integer> keys = new ArrayList<Integer>(alph.keySet());
            Collections.sort(keys);
            for (int k : keys) {
                String ch = new String(Character.toChars(k));
                System.out.println("MS|enc1|" + k + "||" + enc(ch, '.', '-', ' '));
            }
        }

        // ④ 表外字符与特殊档（默认档 + 自定义档各打一遍）
        String[] inputs = {
            "", " ", "  ", "SOS", "sos", "hello world", "a b", "1 2", "中", "é",
            ".", "-", ".-", "-..", "+", "/", "\t", "\n", "S  O", "SOS!", ",??", "..---.", "0"
        };
        char[][] sym = { { '.', '-', ' ' }, { '+', '-', '/' }, { '_', '=', ' ' }, { '.', '-', ',' } };
        for (char[] s : sym) {
            for (String in : inputs) {
                System.out.println("MS|enc|" + esc(in) + "|" + s[0] + s[1] + s[2] + "||" + enc(in, s[0], s[1], s[2]));
            }
        }

        // ⑤ decode 档：正表编出来的串、未知莫尔斯段、连续分隔符、表外符号
        String[] seqs = {
            "", " ", "  ", "...", "... --- ...", "...---...", "... ...", "...  ...", ".../", "...+",
            "-.", ".-", "-----", "--------", "...---...", ".--.-", "!", ".,", ".. ... --", "---.", "..--"
        };
        for (char[] s : sym) {
            for (String q : seqs) {
                System.out.println("MS|dec|" + esc(q) + "|" + s[0] + s[1] + s[2] + "||" + dec(q, s[0], s[1], s[2]));
            }
        }

        // ⑥ 往返：整表逐字符 enc→dec，只在两边都不抛的档上打
        if (alph != null) {
            List<Integer> keys = new ArrayList<Integer>(alph.keySet());
            Collections.sort(keys);
            for (int k : keys) {
                String ch = new String(Character.toChars(k));
                String e = enc(ch, '.', '-', ' ');
                if (e.startsWith("ERR:")) continue;
                System.out.println("MS|rt|" + k + "||" + dec(rawEnc(ch, '.', '-', ' '), '.', '-', ' '));
            }
        }

        System.out.println("MS|null-enc||" + enc(null, '.', '-', ' '));
        System.out.println("MS|null-dec||" + dec(null, '.', '-', ' '));
        System.exit(0);
    }

    static char fChar(Object target, Field f) throws Exception {
        Object v = f.get(target);
        return ((Character) v).charValue();
    }

    // 往返要的是**原始串**（esc 之后喂回去就变了）
    static String rawEnc(String s, char dit, char dah, char split) {
        return new cn.hutool.core.codec.Morse(dit, dah, split).encode(s);
    }
}
