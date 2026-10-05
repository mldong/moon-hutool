# 20 · `textsim` —— 文本相似度（`TextSimilarity`）

对位 hutool `cn.hutool.core.text.TextSimilarity`。件在 **hutool-core** 一个 jar 里
（`unzip -l` 现读：`TextSimilarity.class` 2,908 字节、`Simhash.class` 5,187、`PasswdStrength.class` 4,910 + 两个内部枚举类）。
进度状态见 `docs/ROADMAP.md` 第 20 行；本文是这一行契约的唯一真相。

---

## 1. 对位与边界（先划清，再写代码）

参照类 `public static` 面只有三件（`priv.names` 那条反射读数把 7 个方法逐个点名）：

```
public static double similar(String, String)
public static String similar(String, String, int)
public static String longestCommonSubstring(String, String)
private  static String removeSign(String)
private  static boolean isValidChar(char)
private  static int longestCommonSubstringLength(String, String)
private  static int[][] generateMatrix(String, String)
```

| 处置 | 件 | 理由 |
|---|---|---|
| **本批落地** | `similar` 的两档 + `longestCommonSubstring`，另把 `isValidChar`/`removeSign` 提到公开面 | 都是纯字符串算术，期望值可从参照腿逐条直读 |
| 第二批（排期） | `cn.hutool.core.text.Simhash` | **有状态**：`Simhash(int width, int bit)` + `hash(Collection<? extends CharSequence>)` + `equals(Collection)` + `store(Long)`——先要拍"指纹存储"那一半的返回形状（`store` 存的是什么、`equals` 的阈值语义），与本批三个纯函数不是同一件事。`hash` 家族那批 128 位族也挂在同一处（见 `docs/spec/17-hash.md` §1） |
| 第二批（排期） | `cn.hutool.core.text.PasswdStrength` | 强度分级要 `PASSWD_LEVEL`/`CHAR_TYPE` 两枚枚举 + 打分权重表，形状与相似度无关；`ROADMAP` 那一行把三件并排放是同族归类的历史遗留，本批先把 `TextSimilarity` 收口 |
| **不在本包** | `diff::{edit_distance_str, edit_distance_str_within, levenshtein_edits}` | 三件都在 **`moonbitlang/core` 的 `diff` 包**（不是本库的 `text` 包）——编辑距离族 core 已有，本包一律不重造；本包给的是"公共子序列 / 剥离集 / 较大分母"这套**非编辑距离**口径 |

**javadoc 与实现不一致，本契约按实现钉**：`similar` 的注释自称"利用莱文斯坦距离(Levenshtein distance)算法"，
而实现走的是最长公共**子序列** DP（`generateMatrix` 是 LCS 的二维表）＋`Math.max` 分母。
`longestCommonSubstring` 的注释自己也写"不要求所求得的字符在所给的字符串中是连续的"——名字是误名。

---

## 2. 公开面（第一批 5 件）

| # | 签名 | hutool 对位 |
|---|---|---|
| #20.1 | `is_valid_char(Char) -> Bool` | `private static boolean isValidChar(char)` |
| #20.2 | `remove_sign(String) -> String` | `private static String removeSign(String)` |
| #20.3 | `longest_common_subsequence(String, String) -> String` | `public static String longestCommonSubstring(String, String)` |
| #20.4 | `similar(String, String) -> Double` | `public static double similar(String, String)` |
| #20.5 | `similar_percent(String, String, Int) -> String raise @num.NumError` | `public static String similar(String, String, int)` |

类型口径：hutool 的 `double` 对应本库 `Double`（定宽 64 位，三档同宽）；`String` 读数是**码元表**（§4）。
本包**不新建错误类型**：#20.5 的 raise 面就是 `num` 既有的 `NumError`（#8.11 的舍入面已在 `num` 钉过，本包不重复钉它的读数）。

---

## 3. 语义条目（每条给参照腿读数标签，标签是 §4 腿 A/B 的行首）

| # | 判据 | 参照读数 |
|---|---|---|
| 1 | 有效字符 = 四档区间**含两端**：`0x4E00–0x9FFF`、`a–z`、`A–Z`、`0–9`；其余（空白、标点、全角、假名、阿拉伯文、上标、带圈数字）一律无效 | `valid.4dff\|false`、`valid.4e00\|true`、`valid.9fff\|true`、`valid.a000\|false`、`valid.60/61`、`valid.7a/7b`、`valid.40/41`、`valid.5a/5b`、`valid.2f/30`、`valid.39/3a`、`valid.20`、`valid.9`、`valid.3002`、`valid.ff0c`、`valid.ff10`、`valid.30a2`、`valid.600`、`valid.3007`、`valid.3005`、`valid.b2`、`valid.2460`、`valid.fe33`（30 条，逐条进用例） |
| 2 | astral 码位在参照侧被拆成两个码元分别判，两个码元都无效 ⇒ 与"整码位无效"同结果 | `valid.cp.1f34e\|false,false`、`valid.d83c\|false`、`valid.df4e\|false` |
| 3 | `remove_sign` 保序拼接有效字符；空串/全符号串给空串；**不裁剪、不折叠大小写** | `rs.N.A`/`rs.N.B`（33 组 × 2 = 66 条，逐条进用例），如 `rs.8.A` = `a b c`→`abc`、`rs.18.A` = `，。！中文`→`中文`、`rs.10.A` = `🍎a`→`a` |
| 4 | #20.3 是**最长公共子序列**（不要求连续），结果串的字符全部来自第一侧 | `lcsu.22\|[用户登成功]`（跳过"录/陆"）、`lcsu.15\|[BDAB]`（`ABCBDAB`/`BDCABA` 的 CLRS 经典例） |
| 5 | 回溯择路：先比 `g[i][j] == g[i][j-1]` 左移，再比 `== g[i-1][j]` 上移，否则取 `str_a[i-1]` 并同时左移上移 ⇒ **不满足交换律** | `lcsu.15\|BDAB` 对 `lcsu.rev.15\|BCBA`、`lcsu.13\|文` 对 `lcsu.rev.13\|中`、`lcsu.20\|d` 对 `lcsu.rev.20\|a`、`lcsu.25\|5` 对 `lcsu.rev.25\|0`（66 条两侧读数全进用例） |
| 6 | **公开面 #20.3 不做剥离**，而 #20.4 走剥离后的另一条路径 | `nostrip.proof.A\|[32]`（`"  "` 与 `" "` 给一个空格）、`nostrip.proof.B\|1`、`strip.sim.B\|1.0`（同一条夹具在 #20.4 给 1.0） |
| 7 | #20.4 的分母 = **剥离后**两侧较大长度（不是原始长度、不是第一个参数） | `den.N`（腿 B 反射逐条给）、`strip.denom.proof.1\|1.0`（`a b c`/`abc` 给 3/3 而不是 3/5）、`den.swap.proof\|0.125`（换向同值） |
| 8 | 分子 = 剥离后的 LCS 长度（走私有 `longestCommonSubstringLength`，该函数自身不剥离） | `num.N`（腿 B 反射逐条给），与 `sim.N` 两两对齐，如 `num.33\|1`/`den.33\|2048` 对 `sim.33\|4.882813E-4` |
| 9 | **分母为 0 ⇒ 返回 1.0**（两侧都剥空：空串、纯空白、纯符号） | `sim.1\|1.0`（`""`/`""`）、`sim.24\|1.0`（`"  "`/`" "`）、`sim.31\|1.0`（`"!!!"`/`"???"`）、`num.1/24/31\|-1`（分母 0 时不取分子） |
| 10 | **大小写敏感**、**符号不参与**、emoji 整码位剥掉 ⇒ 三条直觉都得反过来读 | `sim.7\|0.0`（`ABC`/`abc`）、`sim.9\|1.0`（`a,b!c`/`abc`）、`sim.10\|1.0`（`🍎a`/`a`）、`sim.18\|1.0`（`，。！中文`/`中文`） |
| 11 | 商按 **10 位小数 HALF_UP**（`NumberUtil.div` 的 `DEFAULT_DIV_SCALE = 10`，源码级判定 + tie 实测） | `sim.33\|4.882813E-4` 对裸商 `div.tie.raw\|4.8828125E-4`（第 11 位是 5：HALF_UP 给 …813，HALF_EVEN 会给 …812）；`sim.5\|0.6666666667`、`sim.15\|0.5714285714` |
| 12 | #20.4 与参数顺序无关（分母取较大者、分子对称） | 33 组 `sim.N` 与 `sim.rev.N` **逐条相等**（用例两侧各钉一次） |
| 13 | #20.5 = 值挪两位十进制小数点 → 舍到**至多** `scale` 位（**HALF_EVEN**）→ 去尾随零 → 挂 `"%"`；**不补零**（参照侧 `minimumFractionDigits` 是 0） | `pct.5.0\|67%`、`pct.5.1\|66.7%`、`pct.5.2\|66.67%`、`pct.5.10\|66.66666667%`、`pct.1.10\|100%`（补零会成 `100.0000000000%`）、`pct.33.2\|0.05%`、`pct.33.10\|0.04882813%`（132 格全进用例） |
| 14 | 舍入模式是 **HALF_EVEN**（`DecimalFormat` 的默认档），不是 `div` 那一步的 HALF_UP——同一个数两步两种模式 | tie 直探针（`NumberUtil.formatPercent` 本体）：`fp.0.0\|12%`（12.5→12）、`fp.1.0\|38%`（37.5→38）、`fp.2.0\|62%`（62.5→62）、`fp.3.0\|88%`（87.5→88）、`fp.6.0\|0%`（0.5→0）、`fp.7.0\|2%`（1.5→2）。**同一条规则在 33 组相似度上也成立**：`pct.26.0\|12%`、`pct.27.0\|62%` |
| 15 | `scale` 为负 ⇒ **静默夹成 0**（参照侧 `NumberFormat.setMaximumFractionDigits` 走 `Math.max(0, …)`，不是 `IllegalArgumentException`） | `exc.pct.neg\|OK:50%`（`formatPercent(0.5, -1)` 照样出串）、`exc.sim.neg\|OK:0%`（`similar("a","b",-1)`） |
| 16 | `scale` 很大不报错、也不出新数字 | `exc.sim.big\|OK:0%`（scale=100） |
| 17 | 参照侧收 `null` 直接 NPE；本库 `String` 不可空 ⇒ 该档**不可表示**，不设错误分支 | `exc.sim.null\|NullPointerException: Cannot invoke "String.length()" because "strA" is null`、`exc.sim.null2`（strB 同形）、`exc.lcs.null` |
| 18 | 空串两侧走 #20.3 不炸（矩阵第 0 行/列恒 0，回溯循环立即退出） | `exc.lcs.empty\|OK:`（结果为空串） |
| 19 | 百分比的**分隔符与后缀不随 locale** | `sys.locale\|zh_CN` 下 `loc.zh\|66.67%`、`loc.en\|66.67%`、`loc.de\|66,67 %`（码元读数 `[54,54,44,54,55,160,37]`，小数点是逗号、`%` 前是 U+00A0） |

---

## 4. 三条腿

| 腿 | 载体 | 读数 | 备注 |
|---|---|---|---|
| A 实测（公开面） | 真 `hutool-core-5.8.35.jar` 的 `TextSimilarity` + 本机 JDK 17.0.14，`javac -encoding UTF-8` | **524 行**（`textsim_ref.txt`），每条 `tag\|值` 可复算 | 夹具 33 组：空串、单字符、emoji 代理对、中文四组、CLRS 经典例、纯符号、纯空白、`0.5`/`5.0`、以及**专造的四条 tie**（`abcdefgh`/`a` 给 1/8、`abcdefgh`/`abcde` 给 5/8、`0×171+1×29`/`1×29` 给 0.145、`b×2047+a`/`a` 给 1/2048）。非 ASCII 在 Java 源里写 `\uXXXX` 转义（`digest` 轮那条 `javac` 默认 GBK 教训的形状） |
| B 反射（私有面） | 同一 jar，`getDeclaredMethod` + `setAccessible(true)` 读 `isValidChar`/`removeSign`/`longestCommonSubstringLength` | **202 行**（`textsim_ref3.txt`） | `priv.names` 那条先把类的 7 个方法逐个点名——**不许猜私有方法存在**（`rand` 轮反射读常量表的同一姿势）。分子 `num.N`、分母 `den.N` 由这条腿逐条给，A 腿只给最终的商 |
| C 独立实现（对撞） | Python `Decimal`（`ROUND_HALF_UP` / `ROUND_HALF_EVEN`）+ 纯 Python 的 LCS DP，从 A 腿的码元读数重建夹具 | **241 行**（`textsim_cross.txt`） | 生成脚本 `gen_textsim.py` 开头就拿它逐格对撞 A：**任何一格分岔就不出文件**。本批 33 组 `sim`、66 条 `lcsu`、132 格 `pct`、40 格 `fp` **全部 0 分岔**。C 腿不供期望值，只证"本库准备写的算法与参照同值" |

串读数一律是 **UTF-16 码元十进制表**（`cu()` 打的），因为空白与代理对按文本打出来看不出差别：
`lcsu.24|[32]` 是"一个空格"，`lcsu.30|[55356,57166]` 是"整个 🍎"，`pct.*` 里若混进 U+00A0 也会当场显形（`loc.de` 就是这么抓出来的）。
生成脚本配对代理对后统一写 `\u{...}` 转义，**用例与 README 里没有一个字节是手打的**。

---

## 5. 分岔与不跟随（逐条给两侧读数）

| # | 分岔 | 参照 | 本库 | 依据 |
|---|---|---|---|---|
| 1 | `longestCommonSubstring` 的名字 | 名字说"子串"，实现与它自己的 javadoc 都说"子序列" | 改名 `longest_common_subsequence` | `lcsu.22\|用户登成功`、`lcsu.15\|BDAB` 两条非连续实锤 |
| 2 | `similar(String,String,int)` 的重载 | Java 靠签名区分 | 独立命名 `similar_percent` | MoonBit 无函数重载 |
| 3 | `isValidChar`/`removeSign` 的可见性 | `private` | 提到公开面（#20.1/#20.2） | 剥离集是本包唯一"改写输入"的地方，不可测就等于不可评审；读数由反射腿 B 给，不靠猜 |
| 4 | 位置口径 | `charAt` 逐**码元** | `to_array` 逐**码位** | 四档区间全在 BMP 内（`valid.*` 30 条），astral 两码元都无效（`valid.cp.1f34e`）⇒ 33 组夹具两侧同值；**唯一形状差**是参照侧的回溯可能吐出半截代理对（它按码元取 `str_a.charAt(m-1)`），而本库的输入域是合法 UTF-8、根本表示不了 lone surrogate，故该风险面不存在（源码级判定 + `lcsu.30` 读数） |
| 5 | 百分比的求值路径 | `NumberFormat`/`DecimalFormat`：先按 double 的**二进制精确展开**取位 | 十进制精确值（值本身就是 10 位小数的商）+ `HALF_EVEN` + 去尾零，委托 `num` 的 #8.11/#8.12 | 同一条 `num` 轮的裁定（"不跟随二进制路"）。实测 **172 格 0 分岔**（132 格相似度百分比 + 40 格 `formatPercent` 直探针，含 12.5/37.5/62.5/87.5/14.5/35.5/0.5/1.5 八个 tie 档），所以本行只承诺"目前无可观测分岔"，不承诺极端二进制尾数档 |
| 6 | `scale` 上限 | 无上限（`setMaximumFractionDigits(1000)` 照收，位数够久会把二进制展开的尾巴吐出来） | 随 `num` 的 `308`，超出 `raise NumError.ScaleOutOfRange` | `exc.sim.big\|OK:0%` 证大档不报错；本库选"报错而不是吐二进制垃圾位"。负档两侧都夹成 0（条目 15） |
| 7 | locale | 随 JVM 默认 locale（本机 `zh_CN`） | 固定 `.` 小数点、不分组、`%` 紧跟数字 | 条目 19 三份读数 |
| 8 | `Simhash`/`PasswdStrength` | 同包同类族 | **本批不做**，第二批（§1 表） | 一个要有状态 + 指纹存储形状，一个要两枚枚举 + 权重表 |
| 9 | 编辑距离族 | 参照的 javadoc 提"莱文斯坦" | 本包**不提供**编辑距离 | core 已有 `diff::{edit_distance_str, edit_distance_str_within, levenshtein_edits}`（现读 `moonbitlang/core/diff`），重造就是第二张嘴 |

---

## 6. 变异对照（落地轮实跑：`moon test --target wasm` 逐条改一处、跑完按 sha256 字节还原）

基线读数：落地笔开局 **405 = 绿 405 / 红 0**（wasm / js / wasm-gc 三档一致，native 由 CI 出证——本机
`moon test --target native` 需要 MSVC，同 `jeeflow-moon` 那条已实测的口径）。

| 变异 | 结果 | 红块数 |
|---|---|---|
| 下界 `0x4e00` 写成排它 | **抓到** | 1（#20.1 那张表） |
| 上界 `0x9fff` 写成排它 | **抓到** | 1 |
| 剥空两侧改给 `0.0` | **抓到** | 4（`sim.1/24/31` + 百分比块 100%→0%） |
| 第 10 位由 `HALF_UP` 退成 `HALF_DOWN` | **抓到** | 3（`sim.33` 与两处百分比） |
| 百分比档 `HALF_EVEN` → `HALF_UP` | **抓到** | 1（tie 档 `12%`/`62%` 那几个格） |
| 回溯择路两条分支顺序对调 | **抓到** | 2（`lcsu.*` 与 `lcsu.rev.*` 至少一侧变值） |
| #20.3 顺手先剥离 | **抓到** | 1（`lcsu.24`/`lcsu.31`） |
| 分母取第一个参数的长度 | **抓到** | 3（`den.swap.proof` + 两条不对称夹具） |
| 负 `scale` 不再夹成 0 | **补强后抓到**（10-05 追加批）：绿 11/红 1 | 1 |

最后一条原本是本轮唯一一条负 `scale` 断言用 `similar("a","b",-1)`，其值 0.0 在"夹成 0 档"与"直接当 −1 档喂
`num`"两条路上**都出 `0%`** ⇒ 等价变异。**10-05 追加批已清账**：新腿（`TextSimNeg.java`，真 hutool-core 5.8.35 +
JDK 17.0.14）实测非 tie 夹具 `abc`/`axc` 与 `ab`/`abc` 在 `scale=-1/-2` 上参照给的是 **`OK:67%`**，
而不是当初推导的 `70%`——`DecimalFormat` 拿到负的最大小数位是当"不限制"处理，不是"按十位舍"。
两条事实因此同时钉住：①本库"负 `scale` 夹成 0"与参照**同值**（不是分岔，不需要 §5 行）；
②`4` 条 `neg.*` 断言把这条变异从"0 红"做成"绿 11/红 1"（去掉夹紧后 `@num.format_percent(v, -1)` 出的不是 `67%`）。
**教训**：等价变异要清账，得先回腿里把"替代夹具的真值"读出来再补断言——当初写在 spec 里的那句"不夹给 70%"
正是**没回腿的推导**，实测把它推翻了；变异能不能抓，只由可观测读数说话。

一条工装教训留在此处：变异脚本若在第一条上崩掉（本机 `subprocess` 用 `text=True` 撞上 GBK 控制台），
留下的工作树就成了"带变异的基线"——脚本必须**开局先把工作树按上一条已知逆补丁还原并跑一次基线**再进循环，
本轮就是这么发现并逆回来的（`cp > 0x4e00` 那一处）。

---

## 7. 状态

`docs/ROADMAP.md` 第 20 行的状态与本节同步（`scripts/sync_status.py --write` 生成，勿手改）：
两笔都在——契约笔冻结签名与期望值，落地笔把本批 12 块（8 块断言 + 4 个文档块，473 条断言行）全部转绿，
三档一致、`.mbti` 无漂移；九条变异对照的读数与那条等价变异都记在 §6。
