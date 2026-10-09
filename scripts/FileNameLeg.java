// moon-hutool/path —— FileNameUtil 的纯字符串档参照腿（本库只收 String 重载）。
//
// 范围切法（写进契约的口径）：`FileNameUtil` 每个方法都有 `File` 与 `String` 两个重载，
// `File` 档带宿主语义（`File.separator`、`isDirectory` 尾斜杠规则）——本库零 FFI，
// **只收 String 档**，File 档整条判 excluded。这一条腿因此只喂串。
//
// 反射读两个私有常量（不手抄）：
//   SPECIAL_SUFFIX —— "复合扩展名"名单，决定 `archive.tar.gz` 的 extName 到底给 `gz` 还是 `tar.gz`；
//   FILE_NAME_INVALID_PATTERN_WIN —— 非法字符正则，决定 cleanInvalid/containsInvalid 的字符集。
//
// 行形状：`<族>|<方法>|<入参>|<读数>`；null 打成 {null}，抛错打 ERR:<类名>:<msg>。
import cn.hutool.core.io.file.FileNameUtil;
import java.lang.reflect.Field;
import java.util.regex.Pattern;

public class FileNameLeg {

    public static void main(String[] args) throws Exception {
        // ---- 私有常量现读 ----
        Field fs = FileNameUtil.class.getDeclaredField("SPECIAL_SUFFIX");
        fs.setAccessible(true);
        CharSequence[] suffix = (CharSequence[]) fs.get(null);
        StringBuilder sb = new StringBuilder();
        for (CharSequence c : suffix) sb.append(c).append(" ");
        System.out.println("CONST|SPECIAL_SUFFIX|" + sb);
        Field fp = FileNameUtil.class.getDeclaredField("FILE_NAME_INVALID_PATTERN_WIN");
        fp.setAccessible(true);
        Pattern p = (Pattern) fp.get(null);
        System.out.println("CONST|INVALID_PATTERN|" + esc(p.pattern()));
        System.out.println("CONST|EXT_JAVA|" + FileNameUtil.EXT_JAVA + "|EXT_CLASS|" + FileNameUtil.EXT_CLASS
                + "|EXT_JAR|" + FileNameUtil.EXT_JAR);
        System.out.println("CONST|UNIX_SEP|" + (int) FileNameUtil.UNIX_SEPARATOR + "|WIN_SEP|"
                + (int) FileNameUtil.WINDOWS_SEPARATOR);

        String[] names = {
            "/a/b/c.txt",                 // Unix 全路径
            "C:\\a\\b.txt",               // Windows 全路径
            "C:/a/b.txt",                 // 盘符 + 正斜杠
            "\\\\server\\share\\f.bin",   // UNC
            "a\\b/c.txt",                 // 混分隔符
            "c.txt",                      // 裸文件名
            "/tmp/",                      // 尾分隔符
            "/tmp", "tmp/", "tmp",
            "a.b.c",                      // 多个点
            ".bashrc",                    // 点开头（主名是空还是 .bashrc？）
            "archive.tar.gz",             // 复合扩展名（SPECIAL_SUFFIX 命中）
            "archive.tar.bz2", "archive.tar.xz", "archive.tar", "x.tar.gz.txt",
            "noext",                      // 无扩展名
            "a.", ".a", ".", "..", "...", // 点档
            "",                           // 空串
            "/",                          // 仅分隔符
            "中文 文件.txt",                 // 非 ASCII
            "a b.txt",                    // 带空格
            "bad:name?.txt",              // Windows 非法字符
            "a<b>c|d.txt",                // 更多非法字符
            "tab\there.txt",              // 制表符（非法档）
            "line\nbreak.txt",            // 换行（非法档）
        };
        for (String n : names) {
            call("getName", n, () -> FileNameUtil.getName(n));
            call("getSuffix", n, () -> FileNameUtil.getSuffix(n));
            call("getPrefix", n, () -> FileNameUtil.getPrefix(n));
            call("mainName", n, () -> FileNameUtil.mainName(n));
            call("extName", n, () -> FileNameUtil.extName(n));
            call("cleanInvalid", n, () -> FileNameUtil.cleanInvalid(n));
            callb("containsInvalid", n, () -> FileNameUtil.containsInvalid(n));
        }
        for (String n : new String[] {null, ""}) {
            call("getName(null)", n, () -> FileNameUtil.getName(n));
            call("extName(null)", n, () -> FileNameUtil.extName(n));
            call("mainName(null)", n, () -> FileNameUtil.mainName(n));
            call("getSuffix(null)", n, () -> FileNameUtil.getSuffix(n));
            call("getPrefix(null)", n, () -> FileNameUtil.getPrefix(n));
            call("cleanInvalid(null)", n, () -> FileNameUtil.cleanInvalid(n));
            callb("containsInvalid(null)", n, () -> FileNameUtil.containsInvalid(n));
        }
        // ---- isType：多类型、大小写、带点/不带点、null 参数、空数组 ----
        String[] its = {"a.txt", "a.TXT", "a.tar.gz", "noext", "a.", ".txt", "a.jpg", "/d/b.png", "中文.txt"};
        String[][] types = {{"txt"}, {"TXT"}, {"txt", "jpg"}, {"jpg", "txt"}, {".txt"},
            {""}, {}, {null}, {"txt", ""}, {"gz"}, {"tar.gz"}, {"Tar.GZ"}, {"ar.gz"}};
        for (String s : its) {
            for (String[] t : types) {
                System.out.println("IT|isType|" + esc(s) + "|" + typesOf(t) + "|" + safei(() -> FileNameUtil.isType(s, t)));
            }
        }
        // null 文件名 + 各类型表
        for (String[] t : types) {
            System.out.println("IT|isType|null|" + typesOf(t) + "|" + safei(() -> FileNameUtil.isType(null, t)));
        }
    }

    static String typesOf(String[] t) {
        if (t == null) return "{nullArray}";
        StringBuilder b = new StringBuilder();
        for (String s : t) b.append(s == null ? "{null}" : esc(s)).append(",");
        return "[" + b + "]";
    }

    interface Cs {
        String get();
    }

    interface Cb {
        boolean get();
    }

    static void call(String m, String in, Cs c) {
        System.out.println("N|" + m + "|" + esc(in) + "|" + esc(safes(c)));
    }

    static void callb(String m, String in, Cb c) {
        System.out.println("N|" + m + "|" + esc(in) + "|" + safei(c));
    }

    static String safes(Cs c) {
        try {
            return c.get();
        } catch (Throwable t) {
            return "ERR:" + t.getClass().getSimpleName() + ":" + t.getMessage();
        }
    }

    static String safei(Cb c) {
        try {
            return String.valueOf(c.get());
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
