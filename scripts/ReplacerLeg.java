// moon-hutool/text —— replacer 三件的参照腿（LookupReplacer / ReplacerChain / StrReplacer）。
//
// 为什么必须先跑这条：`EscapeUtil` 的实体族（见 EntityTableLeg）就是 `ReplacerChain` +
// `LookupReplacer` 拼出来的（javap 现读：XmlEscape/Html4Escape/XmlUnescape/Html4Unescape
// 全部 extends ReplacerChain，码表是它们的 `String[][]` 静态字段）。也就是说
// **替换引擎的择路规则决定了实体转义的行为**——长键优先还是表内先出现者优先、
// 单字符键、跨尾键（串不够长时匹不匹）、链里第一个匹配后还试不试第二个，
// 这四条一旦写错，实体表和 Unicode 档的读数会整片跟着错。
//
// 出口形状：`<族>|<键>|<读数>`；`R|full` 打整串替换结果，`R|step` 打
// `protected int replace(CharSequence,int,StrBuilder)` 的**返回值**（消费长度 / -1）与
// 写进 StrBuilder 的片段——protected 法用子类包一层就能现读，这是整条链的判据面。
// 不可见字符一律 {uXXXX}，`|` 一律 {u007c}。
import cn.hutool.core.text.StrBuilder;
import cn.hutool.core.text.replacer.LookupReplacer;
import cn.hutool.core.text.replacer.ReplacerChain;
import cn.hutool.core.text.replacer.StrReplacer;
import java.lang.reflect.Method;
import java.util.Iterator;

public class ReplacerLeg {

    /** 只为把 protected 的逐步进打开：参照的公开面是 replace(CharSequence)，
     *  但链的语义全在这个 step 里，不打开就只能靠整串输出反推。 */
    static class Open extends LookupReplacer {
        Open(String[][] pairs) {
            super(pairs);
        }

        int step(CharSequence s, int at, StrBuilder out) {
            return super.replace(s, at, out);
        }
    }

    static class Boom extends StrReplacer {
        final String name;
        final int ret;
        final String write;

        Boom(String name, int ret, String write) {
            this.name = name;
            this.ret = ret;
            this.write = write;
        }

        @Override
        protected int replace(CharSequence str, int start, StrBuilder out) {
            calls++;
            if (ret >= 0) out.append(write);
            return ret;
        }

        int calls = 0;
    }

    public static void main(String[] args) throws Exception {
        // ---- L 族：LookupReplacer 的择路 ----
        // 长键 vs 短键：表里短的先出现，长的在后（颠倒表序再打一次，看择路跟不跟表序走）
        String[][] shortFirst = {{"ab", "X"}, {"abc", "Y"}};
        String[][] longFirst = {{"abc", "Y"}, {"ab", "X"}};
        String[][] sameKey = {{"ab", "1"}, {"ab", "2"}};
        String[][] oneChar = {{"a", "A"}};
        String[][] withEmpty = {{"", "E"}};
        String[][] multiSameHead = {{"a1", "P"}, {"a22", "Q"}, {"a2", "R"}};
        String[][] nonAscii = {{"中", "M"}, {"中文", "N"}};
        String[][] special = {{"|", "PIPE"}, {"\\", "BS"}};

        String[][][] sets = {shortFirst, longFirst, sameKey, oneChar, withEmpty, multiSameHead, nonAscii, special};
        String[][] inputs = {
            {"shortFirst", "xaby abc"},
            {"longFirst", "xaby abc"},
            {"sameKey", "ab"},
            {"oneChar", "aaa"},
            {"withEmpty", "xy"},
            {"multiSameHead", "a1 a22 a2 a"},
            {"nonAscii", "中 中文"},
            {"special", "a|b\\c"},
        };
        for (int i = 0; i < sets.length; i++) {
            // 构造本身可能抛（键长为 0 那条：参照在构造器里就 charAt(0)）⇒ 逐集包一层
            Open lr;
            try {
                lr = new Open(sets[i]);
            } catch (Throwable t) {
                System.out.println("L|ctor|set" + i + "|ERR:" + t.getClass().getSimpleName());
                continue;
            }
            String s = inputs[i][1];
            System.out.println("L|full|set" + i + "|" + esc(s) + "|" + esc(str(lr.replace(s))));
            // 全域扫一遍（同一条表喂整串，看匹配位置是否互不干扰）
            String probe = s;
            for (int at = 0; at <= probe.length(); at++) {
                StrBuilder sb = StrBuilder.create();
                int r;
                String err = "";
                try {
                    r = lr.step(probe, at, sb);
                } catch (Throwable t) {
                    r = -999;
                    err = "ERR:" + t.getClass().getSimpleName();
                }
                System.out.println("L|step|set" + i + "|" + at + "|" + r + "|" + esc(sb.toString()) + err);
            }
        }
        // 空表 / null 表 / 表里键长为 0
        for (String probe : new String[] {"abc", ""}) {
            try {
                Open e = new Open(new String[][] {});
                System.out.println("L|empty|" + esc(probe) + "|" + esc(str(e.replace(probe))));
            } catch (Throwable t) {
                System.out.println("L|empty|" + esc(probe) + "|ERR:" + t.getClass().getSimpleName());
            }
        }

        // ---- C 族：ReplacerChain 的链语义 ----
        LookupReplacer a = new LookupReplacer(new String[][] {{"ab", "1"}});
        LookupReplacer b = new LookupReplacer(new String[][] {{"bc", "2"}});
        LookupReplacer c = new LookupReplacer(new String[][] {{"cd", "3"}});
        ReplacerChain chain = new ReplacerChain(a, b);
        chain.addChain(c);
        String[] cins = {"abcd", "ab", "bc", "zz", ""};
        for (String s : cins) {
            System.out.println("C|chain|" + esc(s) + "|" + esc(str(chain.replace(s))));
        }
        // 迭代器：addChain 之后里面有几个、顺序是谁
        StringBuilder it = new StringBuilder();
        for (Iterator<StrReplacer> i = chain.iterator(); i.hasNext();) {
            it.append(i.next().getClass().getSimpleName()).append(" ");
        }
        System.out.println("C|iterator|" + it);
        // 空链与单元素链
        ReplacerChain empty = new ReplacerChain();
        System.out.println("C|empty|" + esc(str(empty.replace("abc"))) + "|n=" + size(empty));
        // 同一个 Replacer 被挂两次：会不会替换两轮（`aaaa` 一轮出 `ba`，两轮会出 `bb`…）
        LookupReplacer dup = new LookupReplacer(new String[][] {{"aa", "b"}});
        ReplacerChain twice = new ReplacerChain(dup, dup);
        System.out.println("C|dup|" + esc(str(twice.replace("aaaa"))));
        // 覆盖档：`ab→1` 与 `1→X` 同在一条链里，第二件会不会把第一件的产出再改一遍
        // （用 Boom 计数才能证"第二件被调了几次"——它每次被调到都记一笔）
        LookupReplacer p1 = new LookupReplacer(new String[][] {{"ab", "1"}});
        LookupReplacer p2 = new LookupReplacer(new String[][] {{"1", "X"}});
        System.out.println("C|overlap|" + esc(str(new ReplacerChain(p1, p2).replace("ab"))));
        Boom watch = new Boom("watch", -1, "");
        System.out.println("C|watch|" + esc(str(new ReplacerChain(p1, watch).replace("ab")))
                + "|watch_calls=" + watch.calls + "|len=4");

        // ---- B 族：step 的返回值直接喂给链（用 Boom 造四档出口）----
        Boom ret0 = new Boom("ret0", 0, "");
        Boom retNeg = new Boom("retNeg", -1, "");
        Boom ret2 = new Boom("ret2", 2, "ZZ");
        Boom retBig = new Boom("retBig", 9, "BIG");
        for (Boom r : new Boom[] {ret0, retNeg, ret2, retBig}) {
            // **必须带超时跑**：参照的驱动循环是 `i += 消费长度`，消费 0 就永远不前进
            // ——ret0 那一档如果真不退出，腿会挂住把整批读数带走。守护线程 + join 两秒，
            // 超时就打 TIMEOUT（这条读数本身就是要进契约的判据）。
            String out = withTimeout(() -> esc(str(r.replace("abcd"))));
            // 标签打**语义**不打类名：四个 Boom 同类名，只打类名就会把"哪一档不收敛"读丢
            // （本轮第一版就把它读丢过一次，四条线全叫 Boom|…|calls=N）。
            System.out.println("B|solo|" + r.name + "|ret=" + r.ret + "|" + out + "|calls=" + r.calls);
        }
        // 链里一个返 2、一个返 -1：顺序影响什么
        Boom first = new Boom("f", 2, "F");
        Boom second = new Boom("s", 1, "S");
        System.out.println("B|chain_fs|" + esc(str(new ReplacerChain(first, second).replace("abcd"))));
        System.out.println("B|chain_sf|" + esc(str(new ReplacerChain(second, first).replace("abcd"))));
        System.out.println("B|calls|first=" + first.calls + " second=" + second.calls);

        // ---- S 族：StrReplacer 公开面的形状（返回 CharSequence，null/空/超长各档）----
        LookupReplacer nn = new LookupReplacer(new String[][] {{"x", ""}});
        System.out.println("S|empty_value|" + esc(str(nn.replace("x"))) + "|");
        LookupReplacer longv = new LookupReplacer(new String[][] {{"ab", "1"}});
        System.out.println("S|null_input|" + longv.replace((CharSequence) null) + "|");
        // 序列化面（StrReplacer implements Serializable）：本库不承诺 ⇒ 只留读数
        System.out.println("S|serializable|" + (longv instanceof java.io.Serializable) + "|");
    }

    /** 两秒超时守护：返回 `TIMEOUT:>0 消费` 或读数/异常名。守护线程 ⇒ 主线程能退出。 */
    static String withTimeout(Call0 c) {
        final String[] box = new String[1];
        Thread t = new Thread(() -> {
            try {
                box[0] = c.get();
            } catch (Throwable e) {
                box[0] = "ERR:" + e.getClass().getSimpleName() + ":" + esc(e.getMessage());
            }
        });
        t.setDaemon(true);
        t.start();
        try {
            t.join(2000);
        } catch (InterruptedException ignored) {
            Thread.currentThread().interrupt();
        }
        return t.isAlive() ? "TIMEOUT(不收敛：负数消费让游标倒退，驱动循环永远走不到串尾)" : box[0];
    }

    interface Call0 {
        String get();
    }

    static int size(ReplacerChain c) {
        int n = 0;
        for (Iterator<StrReplacer> i = c.iterator(); i.hasNext();) {
            i.next();
            n++;
        }
        return n;
    }

    static String str(CharSequence cs) {
        return cs == null ? null : cs.toString();
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
