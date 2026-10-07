// moon-hutool/path —— 比较器修复笔的参照腿（PR-B 前置：先把"参照怎么判"逐对取全）。
// 参照件：hutool-core 5.8.35 的 `AntPathMatcher.getPatternComparator(path)`（**公开方法**，
// 返回 Comparator<String>，其 compare 就是本库 `compare_patterns` 的对位物），本机 JDK 17.0.14。
// 夹具形状是照 `AntPatternComparator` 源码里七级判定的**每一条出口**配的（含 catch-all、
// 与 path 相等、双前缀、单前缀×无双星、总数差、长度差、单星差、变量差、同级给 0），
// 外加 spec §7.1 表里那六条已登记分岔的原始配对——修复笔要用这张表当判据，不能拿实现输出当期望。
// 行形状：C|<against>|<p1>|<p2>|<读数>   ｜抛错 ⇒ ERR:<类名>
import cn.hutool.core.text.AntPathMatcher;
import java.util.Comparator;

public class PathLeg3 {
  static String[][] P = {
    {"/x", "/**", "/**"},
    {"/x", "/**", "/a/*"},
    {"/x", "/a/*", "/**"},
    {"/a/b", "/a/b", "/a/x"},
    {"/a/b", "/a/x", "/a/b"},
    {"/a/b", "/a/b", "/a/b"},
    {"/a/b", "/x/**", "/y/**"},
    {"/a/b", "/x/**", "/a/*"},
    {"/a/b", "/a/*", "/x/**"},
    {"/a/b", "/**/b", "/a/*"},
    {"/a/b", "/**/b", "/a/?"},
    {"/a/b", "/**/b", "a/*"},
    {"/a/b", "/a/*", "/a/**/b"},
    {"/a/b", "/a/?", "/a/**/b"},
    {"/a/b", "a/*", "/a/**/b"},
    {"/a/b", "/**/y", "/*/*/b"},
    {"/a/b", "/**/xy", "/*/*/b"},
    {"/a/b", "/*/*/b", "/**/xy"},
    {"/a/b", "/{a}/{b}", "/**b"},
    {"/a/b", "/**b", "/{a}/{b}"},
    {"/a/b", "a.*", "/x/*"},
    {"/a/b", "/x/*", "a.*"},
    {"/a/b", "/a/*", "/a/*"},
    {"/a/b", "/*", "/*"},
    // 三条专打 PatternInfo 的两处细节：`.*` 那条判据比的是**从 pos-1 起的整个尾巴**（不是两字符窗口），
    // 以及"有变量时 length 走 `{...}` 折叠成 1 字符"那档（未闭合的 `{` 不被折叠）
    {"/a/b", ".*x", "/x/*"},
    {"/a/b", ".*", "/x/*"},
    {"/a/b", "/{a", "/x/*"},
    {"/a/b", "/{a}x", "/x/*y"},
    {"/a/b", null, "/a/*"},
    {"/a/b", "/a/*", null},
  };

  // 直接问参照的切分器：tokenizePath 是 protected，子类化就能现读它的输出（T 行）。
  // 这一组的用途是把 §8 末段那条根因从"读源码推断"升级成"逐串读数"：空段到底丢不丢。
  // 匹配与抽段的逐对读数（M 行）：五条已登记分岔的原始配对 + 一圈会受"丢空段"影响的邻档，
  // 用来验改 tokenizer 到底有没有把别的东西一起挪走。verb：m=match、s=matchStart、w=extractPathWithinPattern
  static final String[][] M = {
    {"m", "/a/*", "/a/"}, {"s", "/a/*", "/a/"}, {"s", "/a/?", "/a/"},
    {"s", "/abc/", "/abc"}, {"w", "/**/x/", "/a/x/"},
    {"m", "/a/**", "/a/"}, {"m", "/a/", "/a/"}, {"m", "/a/*", "/a"},
    {"m", "/*", "/"}, {"m", "/**", ""}, {"m", "", ""}, {"m", "/", ""},
    {"m", "/a//b", "/a/b"}, {"m", "/a/b", "/a//b"}, {"m", "/*/x", "/a/x"},
    {"m", "/{v}/x", "/a/x"}, {"w", "/WEB-INF/**", "/WEB-INF/web.xml"},
    {"w", "/**", "/a/b"}, {"w", "/a/b", "/a/b"}, {"w", "/a/*", "/a/b/c"},
    {"s", "/a/**", "/a/b/c"}, {"s", "/a/b", "/a"}, {"m", "?/x", "a/x"},
    // 两条"纯空白段"档：参照的 ignoreEmpty 只丢**空串**，不丢空白段（trimTokens=false 时空白段照留）
    {"m", "/ /x", "/ /x"}, {"m", "/a/ ", "/a/ "},
    {"m", "/a//b", "/a/ /b"},
    {"m", "/a/**", "/a/x"},
  };

  // 本轮第二笔：按 `do_match` 的**失败出口**与抽变量/组合各档配的对（N 行）。
  // 反斜杠一律用 (char)92 现拼，别在 Java 源里写 \d（词法先于转义，会报非法转义符）。
  static final String B = String.valueOf((char) 92);
  static final String[][] N = {
    {"m", "/a/{n:" + B + "d+}/b", "/a/12/b"},          // Java-only 子表达式：core 方言编不出来
    {"m", "/a/**/z", "/a/b/y"},                        // 后段循环的"不匹配"出口
    {"x", "/a/**/{*p}", "/a/b/c"},                     // 后段循环里抛出来的错误
    {"x", "/{a}/x/{b}", "/p/x/q"},                     // 两个变量、两次填
    {"m", "/x/**/a/**/y", "/x/b/a/c/z"},               // 中段滑动找不到 ⇒ 失败
    {"m", "/a/**/b/**", "/a/b"},
    {"m", "/**/a/**/b/**", "/a/x/b"},
    {"m", "/a/**/b/c", "/a/x/b"},                      // 收尾循环里余段不是 ** ⇒ 失败
    {"m", "/a/**/*", "/a/b/c"},
    {"m", "/**/**/a", "/b/a"},                         // **/** 相邻那一档
    {"c", "a/{" + "v}/x", "y"},                        // combine：前缀里带非首位 { ⇒ 走 contains_char
    {"c", "/a/*", "/b"},
    {"c", "/*.jsp", "/x.txt"},                         // 两侧后缀都非全能 ⇒ 冲突
    // 四条冲着 do_match 剩下的失败出口配的对：中段滑动找不到、中段循环里抛、
    // 后段循环 leftover 非 **、中段 leftover 非 **
    {"m", "/a/**/q/**/z", "/a/b/x/c/z"},
    {"m", "/a/**/x/y/**/z", "/a/b/z"},
    {"x", "/**/{a(b)}/**", "/p/q/r"},
    {"x", "/x/**/{n:(a)(b)}/**/y", "/x/p/q/y"},        // 中段滑动里抛：子表达式带额外捕获组
    {"x", "/**/{n:(a)(b)}/y", "/p/q/y"},               // 前段循环里抛（对照档）
    {"m", "/a/**/b/**/c/d", "/a/x/b/y"},
    {"m", "/a/**/x/y/**/z", "/a/z"},                   // 后段循环 leftover 里有非 ** ⇒ :450 那一档
  };

  // sep="" 那一档：参照有 `AntPathMatcher(String pathSeparator)`，所以这不是"没有对位物"，
  // 是可以现读的 —— 用它取空分隔符下的判定，本库的 `starts_with_sep`/`ends_with_sep` 空串档就有人对撞了
  static final String[][] E = {
    {"", "/a/b", "/a/b"},
    {"", "/a/b", "/ab"},
    {"", "abc", "abc"},
    {"", "/a/*", "/a/b"},
  };

  static class TK extends AntPathMatcher {
    String[] tk(String p) {
      return tokenizePath(p);
    }
  }

  static final String[] TOK = {
    "/a/b", "/a/", "a/b", "/a//b", "/", "", "//a", "/WEB-INF/**", "/{v}/x", "/abc",
  };

  public static void main(String[] args) {
    AntPathMatcher m = new AntPathMatcher();
    Comparator<String> c = m.getPatternComparator("/a/b");
    String g1 = cmp(c, "/**", "/a/*"), g2 = cmp(c, "/a/b", "/a/x"), g3 = cmp(c, "/a/*", "/a/*");
    System.out.println("G|guard|" + g1 + "|" + g2 + "|" + g3);
    boolean ok = !g1.equals(g2) && !g2.equals(g3) && !g1.equals(g3);
    System.out.println(ok ? "G|GUARD_OK|distinct3" : "G|GUARD_FAIL|same-reading");
    TK t = new TK();
    for (String p : TOK) {
      String[] parts = t.tk(p);
      StringBuilder sb = new StringBuilder();
      for (String q : parts) sb.append(esc(q)).append(",");
      System.out.println("T|" + esc(p) + "|" + parts.length + "|" + sb.toString());
    }
    for (String[] r : N) {
      String verb = r[0], pat = r[1], path = r[2];
      String reading;
      if (verb.equals("m")) reading = String.valueOf(m.match(pat, path));
      else if (verb.equals("x")) {
        try {
          java.util.Map<String, String> vs = m.extractUriTemplateVariables(pat, path);
          java.util.List<String> keys = new java.util.ArrayList<String>(vs.keySet());
          java.util.Collections.sort(keys);
          StringBuilder sb = new StringBuilder();
          for (String k : keys) sb.append(esc(k)).append("=").append(esc(vs.get(k))).append(";");
          reading = sb.toString();
        } catch (Throwable th) {
          reading = "ERR:" + th.getClass().getSimpleName();
        }
      } else {
        try {
          reading = esc(m.combine(pat, path));
        } catch (Throwable th) {
          reading = "ERR:" + th.getClass().getSimpleName();
        }
      }
      System.out.println("N|" + verb + "|" + esc(pat) + "|" + esc(path) + "|" + reading);
    }
    AntPathMatcher ms = new AntPathMatcher("");
    for (String[] r : E) {
      String rd;
      try {
        rd = String.valueOf(ms.match(r[1], r[2]));
      } catch (Throwable th) {
        rd = "ERR:" + th.getClass().getSimpleName();
      }
      System.out.println("E|" + esc(r[1]) + "|" + esc(r[2]) + "|" + rd);
    }
    for (String[] r : M) {
      String verb = r[0], pat = r[1], path = r[2];
      String reading;
      if (verb.equals("m")) reading = String.valueOf(m.match(pat, path));
      else if (verb.equals("s")) reading = String.valueOf(m.matchStart(pat, path));
      else reading = esc(m.extractPathWithinPattern(pat, path));
      System.out.println("M|" + verb + "|" + esc(pat) + "|" + esc(path) + "|" + reading);
    }
    for (String[] r : P) {
      // 比较器绑的是"当前流程要匹配的那条路径"，每对都要按各自的 against 现取
      Comparator<String> cc = m.getPatternComparator(r[0]);
      System.out.println("C|" + r[0] + "|" + esc(r[1]) + "|" + esc(r[2]) + "|" + cmp(cc, r[1], r[2]));
    }
  }

  static String cmp(Comparator<String> c, String a, String b) {
    try {
      return String.valueOf(c.compare(a, b));
    } catch (Throwable t) {
      return "ERR:" + t.getClass().getSimpleName();
    }
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
