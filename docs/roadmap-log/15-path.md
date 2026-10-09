# 15 · `path`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 15 行（`path`）“用例”列的逐字原文。
编号 15 是稳定 ID：与该包契约 `docs/spec/15-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `path` | `AntPathMatcher` | **已实现**（10-05 四笔：骨架 `8bc6423` + 契约补充 `9cfaf16` + 期望值更正 `137e248` + 落地；**10-08 比较器闭合笔**：§7.1 那六条分岔照 `AntPatternComparator` 源码修掉（双星按两个计数、有变量时长度走 `{...}` 折叠、`.*` 判据比整条尾巴），六条转成 28 对逐对直读、path 未覆盖行 26→17，剩下五条次日内按**同一根因**闭合：`tokenize` 改成丢空段——参照 `splitToArray` 的第五参 `ignoreEmpty` 与第四参 `trimTokens` 是两个独立开关（本库曾把两者当成一个），腿的 T 行把 `"/a/"`⇒1 段、`"/"`⇒0 段、空白段照留逐串钉死；那条特判从此不再空转，§7.1 十一条分岔至此零条未决。判据、两组变异（比较器 7 条全抓红、切分器 6 条全抓红）与 27 对匹配/抽段直读写在 spec §8/§9；**同日第五批（纯补档）**再按出口配 24 对（`do_match` 失败档、抽变量、组合、`sep=空串` 四档），path 未覆盖行 16 → **3**、全仓 148 → **135**；剩三行给「未覆盖 + 推导 + 删掉仍全绿」三种证据（§10：其中 `R1` 是一条**新的夹具缺口**，`R2`/`R3` 是「同一函数作用在两侧再比较」的按构造等价）；块数现读 `moon test --package path`） | `docs/spec/15-path.md` | 件数与块数现读 `moon test --package path` 与本包 `pkg.generated.mbti`；10 件公开函数 + `PathOptions` 记录 + `PathError` 四变体。**血统先说清**：参照腿**就在 hutool-core 的 jar 里**（`cn/hutool/core/text/AntPathMatcher.class` 11,349 字节 + 4 个内部类、源码 945 行），它本身是 **Spring-core 同名类的 vendored 拷贝**（Apache-2.0）⇒ 本库 `LICENSE`/`moon.mod` 从骨架那一笔起就是 Apache-2.0，许可**没有悬挂**（早前文档里"许可证待拍板"那句已按现读更正）。101 条参照腿读数（`javac -encoding UTF-8`）+ 源码 4 条机制判定定档：`?` 单段单字符、`*` 单段不跨分隔符、`**` **必须整段**且可吞零段（`a:**:c` 对 `a:c` 真；混用分隔符的 `a:**/c` 恒假——**这是本契约的夹具纪律，不是参照实现的坑**）；默认档由源码字段 + 实测双证钉：`caseSensitive=true`、**`trimTokens=false`（hutool 与 Spring 原版不同，Spring 默认裁空格）**⇒ 本库跟所对位的那个实现而不跟祖上文档。`extract_variables` 三条抛点 + `combine` 一条后缀冲突抛点共同构成本包 raise 面（第四档是 PR-A 之后读源码才撞上的，所以补了一笔契约而非在实现里顺手改签名），四档各收一个变体，其中 `{n:(a)(b)}` 那档最阴——**同一模式 `match` 给真、`extract` 抛错**，所以"能匹配"不蕴含"能抽变量"。`{*path}` 判**明确不支持**（参照实现自己 `match` 恒假 + 抛 "Capturing patterns are not supported by the AntPathMatcher"），不补 Spring 的 `PathPatternParser`。`{name:regex}` 的子表达式一律按 **core 方言**（Java-only 的 `\d` 判非法模式，分岔行带两侧读数）。不跟四件都带理由：四枚可变 setter（收成 `PathOptions`）、`setCachePatterns`（`re` 轮"不建全局模式池"同一条）、`match(pattern,path)` 改名 `match_path`（**`match` 是 MoonBit 保留字**，`dfa` 轮撞过）落地轮另三条：`chars_of` 原来写 `for k in lo..hi` 以为是半开区间，实测**含尾**（fmt 把它写成 `..<=`），于是 `{name}` 抽出来的键变成 `name}`——端点语义不赌，改成手写 while；比较器期望从「排序后的相邻对」改成**逐对直读**，并列时稳定排序留下输入序，反推会造出不存在的严格序承诺（`/**/b` 与 `/a/**` 实测给 0）；五条变异逐条有块红（`**` 整段判定 3 / 不拆段 5 / 大小写接反 2 / `combine` 截断 2 / 双前缀分支挪位 1），全部按 sha256 字节还原——其中「大小写接反」只被 2 块抓到，反向夹具没把它区分开，这一格记成待补强而不是已完备、`protected doMatch/tokenize*` 扩展点（无子类语义可承接）；比较器返回 `Int` 不返回 `Ordering`（本仓无 `Ordering` 先例，`Array::sort` 正好要 `Int`）。普查自曝两处坑：分隔符夹具混用两种分隔符差点写成"自定义分隔符不生效"的假结论；给 Java 源码补 `\\d` 被脚本剥成一个反斜杠（**同一类"脚本改转义"坑第三次**，规矩：先 grep 出原始 bytes 再改） |
````

---

**10-10 批①（PR-A 契约冻结笔）**：path 包新增 §11 六件（`path/filename.mbt`）：
`name_of` / `main_name` / `ext_name` / `clean_invalid` / `contains_invalid` / `is_type`，
对位 `io.file.FileNameUtil` 的 **String 档**（`File` 重载挂宿主分隔符与 `isDirectory`，整条判 excluded）。
冻结期望 **285 条**，手打零条——腿 `scripts/FileNameLeg.java`（反射读 `SPECIAL_SUFFIX` 四条
`tar.bz2`/`tar.Z`/`tar.gz`/`tar.xz` 与非法字符正则 `[\/:*?"<>|\r\n]`，逐档 22 条路径 × 8 法 +
`is_type` 的 10×13 择路矩阵），生成器 `gen_batch1_rest.py`。

两条按常识会写错的账：`.bashrc` 的主名是**空串**而 ext 是 `bashrc`（参照如此）；
`is_type` 的空串类型是个真值档（`noext` 对 `[""]` 给 **true**），带点的 `.txt` 反而永不命中。
参照的 `getSuffix`/`getPrefix` 与 `extName`/`mainName` 逐档同读数 ⇒ 不出第二个名字。

本笔状态：`moon check` 零警告；path 有 **2 块红**（§11 的两个骨架块），体是
`PR-B：契约骨架` 的 abort ⇒ READINGS 此刻把 `path` 记成 `契约已冻结`，是工具按红绿分的类，
不是本包 §1~§10 那 10 件退回契约态（它们 0 红、0 改动）。PR-B 落地后自动回 `已实现`。
