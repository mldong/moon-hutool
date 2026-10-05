///|
// moon-hutool/textsim —— 文本相似度，对位 hutool `cn.hutool.core.text.TextSimilarity`
// （件在 **hutool-core** 一个 jar 里，`priv.names` 读数把该类 7 个方法逐个点名）。
// 契约真相在 `docs/spec/20-textsim.md`；本文件是签名骨架——**体全是 `abort`，落地笔（PR-B）替换**。
//
// 一句话口径：`similar` 的分子是**剥离符号后的最长公共子序列长度**，分母是**剥离后的较大长度**，
// 商按 10 位小数 `HALF_UP`；`longest_common_subsequence` 走的是**不剥离**的另一条路径（`nostrip.proof`）。
// javadoc 自称"莱文斯坦距离"，与实现无关——本契约按实现钉，不按注释钉。

///|
/// 码位是否参与相似度计算：`0x4E00–0x9FFF`、`a–z`、`A–Z`、`0–9` 四档区间**含两端**，其余一律不算。
///
/// - Parameters:
///   - `c`：一个码位。MoonBit 的 `Char` 是**码位**而参照实现的 `char` 是 **UTF-16 码元**，
///     本件只对 BMP 内的四档区间给真值，astral 码位（含代理对的两个码元）恒 `false`，
///     两侧同值由 `valid.cp.1f34e|false,false` 与 `valid.d83c|false`/`valid.df4e|false` 三条读数钉住
/// - Returns: 落在四档区间内为 `true`
/// - Raises: 无
/// - Note: hutool 对位 `private static boolean isValidChar(char)`——参照侧是私有方法，本库提到公开面
///   （理由见 spec §5 第 2 行：剥离集是本包唯一"改写输入"的地方，不可测就等于不可评审），
///   读数由反射腿出（`priv.names` 先证明方法真存在）
pub fn is_valid_char(c : Char) -> Bool {
  abort("moon-hutool textsim: 契约已冻结，实现待落地")
}

///|
/// 剥掉不参与计算的码位，只留字母/数字/汉字（判定逐位走 #20.1）。
///
/// - Parameters:
///   - `s`：任意串
/// - Returns: 保序的子串。**空串与全符号串都给空串**（`rs.1.A|[]`、`rs.31.A|[]`），
///   引用符号与全角标点（`，`、`。`、`０`）一律剥掉（`rs.18.A|[20013,25991]`）
/// - Raises: 无
/// - Note: hutool 对位 `private static String removeSign(String)`，同上提到公开面
pub fn remove_sign(s : String) -> String {
  abort("moon-hutool textsim: 契约已冻结，实现待落地")
}

///|
/// 最长公共**子序列**（不要求连续），按参照实现的动态规划 + 回溯逐条同形。
///
/// - Parameters:
///   - `str_a`：取字符的那一侧——结果串里的字符**全部来自 `str_a`**（回溯命中对角时才落字符），
///     所以两件不满足交换律，两条反向读数各钉一次（`lcsu.13|[25991]` 对 `lcsu.rev.13|[20013]`）
///   - `str_b`：另一侧
/// - Returns: 一条最长公共子序列。并列时取哪一条由回溯择路决定：
///   先 `g[i][j] == g[i][j-1]` 则左移，再 `== g[i-1][j]` 则上移，否则取 `str_a[i-1]`；
///   经典夹具 `ABCBDAB`/`BDCABA` 两侧读数 `BDAB` 与 `BCBA` 就是这个择路的证据（`lcsu.15`/`lcsu.rev.15`）。
///   不要求连续：**`用户登录成功`/`用户登陆成功` 给 `用户登成功`**（`lcsu.22`，跳过"录/陆"那一格）
/// - Raises: 无
/// - Note: hutool 对位 `public static String longestCommonSubstring(String, String)`——**名字是误名**
///   （实现是子序列，javadoc 自己也写"不要求…连续"），本库按实现改名，见 spec §5 第 1 行。
///   本件**不做 #20.2 的剥离**（`nostrip.proof.A|[32]`：`"  "` 与 `" "` 给一个空格），
///   而 #20.4 走的是剥离后的另一条路径——同一条夹具两侧读数 `nostrip.proof.B|1` 对 `strip.sim.B|1.0`
pub fn longest_common_subsequence(str_a : String, str_b : String) -> String {
  abort("moon-hutool textsim: 契约已冻结，实现待落地")
}

///|
/// 相似度：`最长公共子序列长度 / 两侧剥离后的较大长度`，商按 **10 位小数 HALF_UP**。
///
/// - Parameters:
///   - `str_a`、`str_b`：两侧输入，**顺序不影响结果**（33 组夹具的 `sim.N` 与 `sim.rev.N` 逐条相等，
///     含 `den.swap.proof|0.125` 那条"分母取较大者而不是取第一个"的专门读数）
/// - Returns: `0.0`–`1.0` 的 `Double`。三条反直觉档都按参照实现钉住：
///   ① **两侧剥离后都是空串 ⇒ `1.0`**（`sim.1`/`sim.24`/`sim.31` 三条：`""`/`""`、`"  "`/`" "`、`"!!!"`/`"???"`）；
///   ② **大小写敏感**（`sim.7|0.0`：`ABC` 对 `abc` 一个公共字符都没有）；
///   ③ 分母是**剥离后**的较大长度，不是原始长度（`strip.denom.proof.2|0.6666666667`：`axb`/`ab` 给 2/3 而不是 2/3 同值，
///     但 `strip.denom.proof.1|1.0` 的 `a b c`/`abc` 给 3/3——原始长度 5 的话就是 0.6）
///   值是精确十进制的第 10 位舍入结果：`sim.33|4.882813E-4` 与裸商 `div.tie.raw|4.8828125E-4`
///   同档对读，把 `HALF_UP` 与 `HALF_EVEN` 在第 10 位分开钉住
/// - Raises: 无。参照侧收 `null` 直接 NPE（`exc.sim.null`/`exc.sim.null2` 两条读数），
///   MoonBit 的 `String` 不可空 ⇒ 该档在本库不可表示
/// - Note: hutool 对位 `public static double similar(String, String)`，
///   分母 `Math.max`、分子用私有的**不剥离**版长度函数（分子分母两侧读数由反射腿逐条给出 `num.N`/`den.N`）
pub fn similar(str_a : String, str_b : String) -> Double {
  abort("moon-hutool textsim: 契约已冻结，实现待落地")
}

///|
/// 相似度的百分比写法：#20.4 的值挪两位十进制小数点，舍到**至多** `scale` 位小数（`HALF_EVEN`），
/// 去掉尾随零，挂 `"%"`。
///
/// - Parameters:
///   - `str_a`、`str_b`：同 #20.4
///   - `scale`：百分号前那个数的最大小数位数。**负数按 `0` 档处理**——参照侧
///     `NumberFormat.setMaximumFractionDigits(-1)` 走 `Math.max(0, …)` 静默夹住而不是抛
///     （`exc.pct.neg|OK:50%`、`exc.sim.neg|OK:0%` 两条读数为凭）；上限随 `num` 的 `308`
///     （hutool 那侧无上限，但位数再多也不出新数字，见 spec §5 第 6 行）
/// - Returns: 如 `"67%"`、`"66.67%"`、`"100%"`。**四个档位都不补零**（`pct.1.10|100%` 而不是 `100.0000000000%`），
///   因为参照侧 `minimumFractionDigits` 是 0
/// - Raises: `num.NumError.ScaleOutOfRange`——`scale` 超出 `num` 的 `[-323, 308]`（本件已在负档夹成 0，
///   实际只有正溢出这一条腿）
/// - Note: hutool 对位 `public static String similar(String, String, int)` →
///   `NumberUtil.formatPercent(double, int)`，其实现是 `NumberFormat.getPercentInstance()`——
///   **随 JVM 默认 locale 变**（`loc.de|[54,54,44,54,55,160,37]` 即 `66,67 %`：逗号做小数点、`%` 前带 U+00A0），
///   且走 `DecimalFormat` 的二进制精确值。本库**不跟随**：固定 `.` 分隔符、不分组、`%` 紧跟数字，
///   舍入用十进制精确值 + `HALF_EVEN`。实测 132 格 + 40 格直探针**零分岔**（Python `Decimal` 独立腿逐条对撞）
pub fn similar_percent(
  str_a : String,
  str_b : String,
  scale : Int,
) -> String raise @num.NumError {
  abort("moon-hutool textsim: 契约已冻结，实现待落地")
}
