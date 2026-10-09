# 契约 01 · text（字符串门面）

> 状态：**已实现 20 件 + 批①新增 14 件是契约骨架**（10-04 那批 18 件、10-10 又补 `is_blank_char` 与一批转义/替换件；老件此刻仍全绿，新件体是 `abort`、14 块按设计红——三档读数一致这条对绿的部分成立）。本页期望值先冻结后实现；
> 其中两条曾被我自己冻结错（`sub_before` 取首个分隔符、`hide` 保留区间外字符），已按 hutool 源码单独一笔更正并在 1.7/1.11 标注证据
> ——**冻结不等于正确**，它的价值是逼每次改动出具外部证据。
> 权威顺序：**本表 + `text_test.mbt` 的期望值 > hutool 行为 > 个人直觉**。实现期要改任何期望值，必须单独一笔 commit 并给出"读数来源"列的新证据（门禁 G5 拦改）。
> 表头说明：**血统**列指 hutool 自己也不是原创的那几格（`CharSequenceUtil` 明写 "Thanks to Apache Commons Lang 3.5"）——移植这些格时真上游是 Apache 系，别按"木兰来源"处理。

## 1.1 包级三条口径（本机编译器裁决，不是风格偏好）

| 口径 | 定案 | 依据 |
|---|---|---|
| 入参类型 | 一律 `String`，不在每个函数上铺 `Option` | MoonBit 无 null。hutool `isBlank(null)=true` 由调用方边界 `unwrap_or("")` 等价达成；只有"缺失本身是业务语义"的两处保留 Option（1.4 `trim_opt`、1.10 `first_non_blank`） |
| 返回类型 | 一律 `String`，**不把 `StringView` 作对外契约** | 编译器实证：`String` 字面量不隐式转 `StringView`，且 `String` **没有** `as_view` 方法 ⇒ 视图入参会让每个调用点手工转换 |
| 空白判定 | **一张实测码表**（35 位，`text.is_blank_char`，整仓共用），不再是"core 白名单 ∪ 独有码点" | `scripts/BlankScanLeg.java` 对整个 BMP 逐位扫参照的**五个出口**（`StrUtil.isBlank`/`StrUtil.trim`/`StrUtil.cleanBlank`/`URLUtil.encodeBlank`/`CharUtil.isBlankChar`），命中集**逐位相同** ⇒ 参照侧本来就是一条谓词。表：`00 09-0d 1c-20 a0 1680 180e 2000-200a 200c 2028-202a 202f 205f 2800 3000 3164 feff`。**本轮更正两处旧账**：① 旧口径写的"core 已覆盖 U+0085"——core 认 U+0085 而参照**不认**，照旧口径就多剥一位；② core 的 ASCII 档只到 `09-0d|20`，参照还算 `1c-1f`，旧口径**少剥四位**。另记一条换代读数：`200c` 是 hutool **5.8.37** 才加进 `isBlankChar` 的（同一支腿跑 5.8.35 的 jar 给 false；javap 现读两版常量表，37 多一枚 `sipush 8204`）⇒ 参照版本统一到这代之后本表才含它。`ini`/`typex` 原有两份副本（各自抄漏：ini 少 `200c`、typex 少 `00/180e/2800/3164`），已收敛到本包这一处 |
| 转义限制 | `\u{...}` 只能写在 **char 字面量**，不能写进字符串 | 写进字符串会被切成插值 ⇒ `Lexing error: missing expression in string interpolation`（本机实测） |

## 1.2 `is_blank(s : String) -> Bool`

| 输入 | 期望 | 备注 |
|---|---|---|
| `""` | true | |
| `"   "` / `"\t \n"` | true | 制表与换行算空白 |
| U+0000 / U+3000 单字符 | true | 见 1.1 第三行 |
| `"a"` / `" a"` | false | 有一个非空白即假 |

hutool 对位 `StrUtil.isBlank` ｜ 差异：不收 null ｜ 读数来源：`scripts/BlankScanLeg.java`（整 BMP 逐位扫参照五个出口，命中集逐位相同；表见 1.1 第 3 行）｜ 血统：`CharSequenceUtil` 源自 Apache Commons Lang 3.5

## 1.3 `is_empty(s : String) -> Bool`

`""` → true；`" "` → **false**。与 `is_blank` 分档不合并（hutool `isEmpty`）。读数来源：hutool v5-master 实测。

## 1.4 `trim(s : String) -> String` ／ `trim_opt(s : Option[String]) -> Option[String]`

| 用例 | 期望 |
|---|---|
| `trim("  ab  ")` | `"ab"` |
| `trim("\tab\n")` | `"ab"` |
| `trim("")` | `""` |
| `trim_opt(None)` | `None` |
| `trim_opt(Some("  ab "))` | `Some("ab")` |
| `trim_opt(Some("   "))` | `Some("")` —— **只把 null 变 null，全空白仍出空串**（hutool `trimToNull` 语义，容易多做一步） |

hutool 对位 `trim` / `trimToNull` ｜ 读数来源：hutool v5-master 实测。

## 1.5 `split(s : String, sep : Char, trim_result? : Bool = false) -> Array[String]`

| 用例 | 期望 |
|---|---|
| `split("a,b,,c", ',')` | `["a","b","","c"]` —— **保留空段** |
| `split("", ',')` | `[]` —— 空输入是空数组，不是 `[""]` |
| `split(" a , b ", ',', trim_result=true)` | `["a","b"]` |

hutool 对位 `splitTrim` ｜ 差异：Java `String.split` 吞尾空串，本库按 hutool 不吞 ｜ 读数来源：hutool v5-master 实测（`StrSplitter`）。

## 1.6 `join(items : Array[String], sep : String) -> String`

`["a","b"], "-"` → `"a-b"`；`["a","","b"], "-"` → `"a--b"`；`[], "-"` → `""`。
hutool 对位 `CollUtil.join` ｜ 差异：MoonBit 侧元素无 null，故不出 `join([a,None,b])` 形态（Java 出 `a--b`）；空串元素照原样产出 ｜ 读数来源：hutool v5-master 实测。

## 1.7 `sub_before` / `sub_after` / `sub_between`（未命中行为**不对称**）

| 用例 | 期望 | 要点 |
|---|---|---|
| `sub_before("path/to/file.txt", "/")` | `"path"` | 按**首个**分隔符（`CharSequenceUtil.java:2369` 的 `isLastSeparator` 默认 false） |
| `sub_before("nope", "/")` | `"nope"` | 未命中 → **整串** |
| `sub_after("path/to/file.txt", "/")` | `"to/file.txt"` | 首个分隔符之后的**全部**（`:2446` 同默认） |
| `sub_after("nope", "/")` | `""` | 未命中 → **空串**（与上一行不对称，别"顺手统一"） |
| `sub_between("hutool{abc}end", "{", "}")` | `"abc"` | |
| `sub_between(..., include_sep=true)` | `"{abc}"` | |
| `sub_between("hutool abc end", "{", "}")` | `""` | 任一界定符缺失 → 空串 |

hutool 对位 `subBefore/subAfter/subBetween` ｜ 差异：hutool 的 `isLastSeparator=true` 取尾档**本库不出**（先证明需要再加）｜ 读数来源：hutool v5-master 源码 `text/CharSequenceUtil.java:2359-2470`。

## 1.8 `format(template : String, args : Array[String]) -> String`

| 用例 | 期望 | 规则 |
|---|---|---|
| `format("a{}b", ["1"])` | `"a1b"` | `{}` 依次填 |
| `format("id={} name={}", ["7"])` | `"id=7 name={}"` | 参数少于占位符 → **未填的原样留**（不报错、不填空） |
| `format("keep \\{}", [])` | `"keep {}"` | 前一字符是 `\` 时当字面量，并把 `\\` 折成 `\` |
| `format("", [])` | `""` | |

hutool 对位 `StrUtil.format` → `text/StrFormatter`（65 行线性扫描）｜ **明确不做**：`{0}` 位置索引（那是 `indexedFormat` 委托 JDK `MessageFormat`，语义与 `{}` 不同）、Map 模板 `{key}`（二期再评估）｜ 读数来源：hutool v5-master 源码实测。

## 1.9 `compare_version(a : String, b : String) -> Int`

`("1.2.3","1.2.10")` → `-1`（按数值不按字典）；`("1.0.0","1.0")` → `0`（缺段补零）；`("2","10")` → `-1`。
hutool 对位 `CharSequenceUtil.compareVersion` ｜ 返回约定：`<0 / 0 / >0`（本库不定死 ±1，实现不许"顺手归一"）｜ 读数来源：hutool v5-master 实测。

## 1.10 `first_non_blank(candidates : Array[Option[String]]) -> Option[String]`

`[None, Some("  "), Some("x"), Some("y")]` → `Some("x")`；`[Some(" "), None]` → `None`。
hutool 对位 `firstNonBlank` ｜ 读数来源：hutool v5-master 实测。

## 1.11 `hide(s : String, start : Int, end : Int, mask : Char) -> String`

| 用例 | 期望 | 要点 |
|---|---|---|
| `hide("13012345678", 3, 7, '*')` | `"130****5678"` | 区间 `[start, end)` |
| `hide("中文测试", 1, 3, '*')` | `"中**试"` | **码点**下标，且区间外字符全保留（hutool javadoc：`hide("jackduan@163.com",2,3)` → `ja*kduan@163.com`） |
| `hide("abc", 1, 99, '*')` | `"a**"` | 越界**夹紧**不报错 |

hutool 对位 `CharSequenceUtil.hide` ｜ 读数来源：hutool v5-master 实测 + core `String::char_length` 语义。

## 1.12 命名法互转（`to_underline_case` / `to_camel_case` / `to_kebab_case` / `to_pascal_case`）

此刻**只冻结三条最确定的**，其余形状必须在实现相位从 v5-master 的 `text/NamingCase` 逐条反推后再冻结——不凭印象写：

| 用例 | 期望 |
|---|---|
| `to_underline_case("userName")` | `"user_name"` |
| `to_camel_case("user_name")` | `"userName"` |
| `to_camel_case("userName")` | `"userName"` —— **无分隔符则原样返回**（hutool 规则，不是幂等化简） |

待定档（spec 挂着，实现相位补齐并各带一条用例）：连续大写串（`HTTPServer`）、尾随大写（`aBC`）、`ABcc` 形状、数字参与判定、`otherCharToLower` 三态、全大写输入。
hutool 对位 `NamingCase`（全仓唯一实现处，`StrUtil.*` 全是委托）｜ 血统：**Commons Lang 派生**｜ 读数来源：hutool v5-master 源码实测（部分待补，故只冻结三条）。

## 1.13 `upper_first` / `lower_first`（ASCII 档）

`upper_first("hutool")` → `"Hutool"`；`upper_first("")` → `""`。
**差异声明（重要）**：core `String::to_upper/to_lower` 文档原文只处理 `A–Z`/`a–z`，非 ASCII 字母原样返回 ⇒ 本库**不承诺 Unicode 大小写**（不假装 hutool/Java 的 `toUpperCase()`）。要 Unicode 档就等数据表件（hub 方案 `docs/ROADMAP.md` 的「暂不做」档），届时另开函数名而不是改这里的语义。

## 1.14 `is_blank_char(c : Char) -> Bool`（hutool `CharUtil.isBlankChar`）

公开的用途是**让整仓共用一张表**，不是给调用方一个泛用谓词：`ini` 的剥边、`typex` 的 `clean_blank`、
本包的 `is_blank`/`trim`/`trim_opt`/`first_non_blank` 与 1.16 的 `encode_blank` 全走这一处。
表体与两处旧账更正（U+0085 参照不算、U+001C–U+001F 参照算）在 1.1 第 3 行，逐位读数在 `scripts/BlankScanLeg.java`。

| 输入 | 期望 | 要点 |
|---|---|---|
| `' '` / `'\t'` / `'\u{0000}'` / `'\u{202A}'` / `'\u{200C}'` | true | 后三位都是参照自己表的出口，core 的白名单里没有（`0000`/`202a` 靠并集补，`200c` 是 5.8.37 换代加的） |
| `'\u{001C}'`..`'\u{001F}'` | true | core `Char::is_whitespace` 判 false —— 旧口径就是在这里少剥四位 |
| `'\u{0085}'`（NEL） | **false** | core 判 true，参照判 false ⇒ 跟参照，不跟 core |
| `'a'` / `'\u{00a0}'`… 见 1.1 表 | 按 1.1 第 3 行那张表逐位判 | 星平面（码位 > `0xffff`）一律 false：参照按 UTF-16 码元走，代理码元不属于任何空白类 |

hutool 对位 `CharUtil.isBlankChar` ｜ 差异：入参是 `Char`（码位），参照是 `char`（码元）；非 BMP 在参照里落成两个代理码元、各自判非空白，本库直接给一个 `false`，同判 ｜ 读数来源：`scripts/BlankScanLeg.java`（五个出口逐位对撞，差异清单为空）。

## 1.15 本批的数据表（生成物，不是手写件）

| 文件 | 内容 | 生成器 / 腿 |
|---|---|---|
| `text/escape_tables.mbt` | 四张实体表（XML 转义 5 / HTML4 转义 251 / XML 还原 5 / HTML4 还原 252）+ `escape` 的**不转义区间表** 146 段 | `scripts/gen_escape_family.py` ← `scripts/EntityTableLeg.java`（反射读四个类自己的 `String[][]`）+ `scripts/EscapeLeg3.java`（BMP 全枚举对撞） |
| `text/escape_test.mbt` | 699 条冻结期望，行尾带腿的读数三段 | 同上 |
| `text/encode_blank_test.mbt`、`text/replacer_test.mbt` | 62 + 18 条 | `scripts/gen_batch1_rest.py` ← `scripts/UrlPureLeg.java`、`scripts/ReplacerLeg.java` |

三条判据形状值得单独记住（都是腿**推翻**了按常识的写法）：

1. **实体表不能抄 Apache/Commons 的清单**。`XmlEscape`/`Html4Escape` 们自己就是 `ReplacerChain` 的子类，
   码表是它们的 `protected static final String[][]` 字段——反射读出来的才是本参照的真相
   （同名不同条目的差异真实存在：XML 的转义表把 `'` 收进来，HTML4 的不收）。
2. **`escape` 的"不转义集"是一条 Unicode 大小写谓词**，javap -c 现读：
   `isDigit || isLowerCase || isUpperCase || "*@-_+./".contains(c)` —— 是**大小写/数字**，不是
   `isLetterOrDigit`。这解释了 `ª`(U+00AA) 被留、`ƻ`(U+01BB, Lt) 被转、`あ`(U+3041, Lo) 被转、
   `Ⅰ`(U+2160, Other_Uppercase) 被留。core 只有 ASCII 档谓词 ⇒ 不自创"只承诺 ASCII"，
   把 146 段区间表带进来（约 1.5 KB）。对撞读数：`MISMATCH|count|0`（整个 BMP 零分岔）。
3. **不转义集与"表外只剩永远转"是同一件事**：非 BMP 的字符在参照侧是两个代理码元、各自判，
   两个都不属数字/大小写 ⇒ 永远转。所以区间表只需覆盖 BMP，`EscapeLeg3` 的 ASTRAL 行五对现读全 false。

## 1.16 实体族：`escape_xml` / `unescape_xml` / `escape_html4` / `unescape_html4`

签名：`String -> String`（转义侧两件）与 `String -> String raise TextError`（还原侧两件，理由见下）。

| 用例（腿 E 行，同输入四法并排） | 读数 | 要点 |
|---|---|---|
| `escape_xml("a<b&c>d\"e'f")` | `a&lt;b&amp;c&gt;d&quot;e&apos;f` | XML 收 `'` |
| `escape_html4("a<b&c>d\"e'f")` | `a&lt;b&amp;c&gt;d&quot;e'f` | **HTML4 不收 `'`** —— 两族唯一的形式差在 `'`，别"顺手统一" |
| `escape_html4("中文—–「")` | `中文&mdash;&ndash;「` | 只有进了表的码点才出实体名；`中`/`「` 原样 |
| `unescape_xml("&nbsp;&lt;…&copy;&pound;")` | `&nbsp;` 解出、`&copy;`/`&pound;` **原样留** | XML 的还原表只有 5 条 + 参照额外认 `&nbsp;`（读数如此，不按 XML 规范常识改） |
| `unescape_html4("&copy;&pound;")` | `©`/`£` | 还原表 252 条 |
| `unescape_xml("&#65;&#x41;&#X41;&#999;")` | `AAA` + `γ` | 数字引用：十进制、小写 `x`、大写 `X` 都认 |
| `unescape_xml("&amp;amp;")` | `&amp;` | **一次只解一层**（多次调用才逐层剥） |
| `unescape_html4("&notanentity;&amp")` | 原样 | 未知名、缺分号：不猜、不报错 |
| `unescape_html4("&#;&#xZZ;")` | 原样 | 坏数字引用同样原样 |

**闭环判据**：整 BMP 逐位扫"转义再还原"，`EntityTableLeg` 的 C 行**一条不剩**（0 条 NOTROUND）
——即表内每一位都能回到原字符。这条是本批最强的一条对撞，别拿"抽样通过"代替它。

**代理区数字实体是本批唯一的形状分岔**：`&#xD800;` 在参照解成一个**孤立代理码元**，
MoonBit 的 `String` 表示不了那个形状 ⇒ 本库出 `raise(LoneSurrogate(55296))`。
成对代理（`&#xD83D;&#xDE00;`）合成码位，与参照表示同一字符，**零偏差**。
不选"替换成 U+FFFD"（那是自创语义），也不选"原样留实体名"（那是替参照决定"解不动"）。

hutool 对位 `EscapeUtil.escapeXml/unescapeXml/escapeHtml4/unescapeHtml4` ｜
差异：null 入参在参照是 NPE（腿 E 行四档都在），本库 `String` 无 null 档 ⇒ 该形状不在契约面 ｜
读数来源：`scripts/EscapeLeg.java`（语料）、`scripts/EscapeLeg2.java`（逐码点扫"到底谁被转/谁被认"）、
`scripts/EntityTableLeg.java`（四张表反射读数 + S/C/N/M/L/A 档）｜
血统：hutool 的 HTML4 表源自 **Apache Commons Text**（`Html4Escape` 类注释自承），
但条目以 jar 现读为准，不跟随 Apache 的当代清单。

## 1.17 百分号族：`escape` / `escape_all` / `escape_by` / `unescape` / `safe_unescape`

| 用例 | 读数 | 要点 |
|---|---|---|
| `escape("abc ABC 123")` | `abc%20ABC%20123` | 空格也转 |
| `escape("*@-_.+/ !")` | `*@-_.+/%20%21` | 表里那 7 个不转 |
| `escape("中文 a")` | **`%u4e2d%u6587%20a`** | 非 ASCII 出的是 IE 风格 `%uXXXX`（**逐码元**），不是 UTF-8 的 `%E4%B8%AD` |
| `escape("😀")` | `%ud83d%ude00` | 星平面拆代理对、各出一个 `%u`；小写十六进制 |
| `escape_all("abc")` | `%61%62%63` | 一位都不留；ASCII 出 `%XX`（两位小写） |
| `escape("%41")` | `%2541` | `%` 本身被转 ⇒ **不幂等**，别当"已编码就不动" |
| `unescape("%41")` | `A` | |
| `unescape("%e4%b8%ad")` | `ä¸\xad` 三个字符 | **不做 UTF-8 解码**：`%XX` 就是一个码元 |
| `unescape("+")` | `+` | 不当空格（与 `URLUtil.decode` 一族分档） |
| `unescape("%25u4e2d")` | `%u4e2d` | 一次一层 |
| `unescape("%zz")` | `raise(BadHex("zz"))` | 参照 `NumberFormatException`；载荷 = 被取走的那 2/4 位原文 |
| `unescape("%")` / `unescape("%2")` | `raise(ShortInput)` | 参照 `StringIndexOutOfBoundsException` |
| `unescape("%uD83D")` | `raise(LoneSurrogate(55296))` | 同 1.16 的代理档处理 |
| `safe_unescape(以上任一坏样本)` | **原串返回** | 参照吞掉异常返回入参，不是返回空串、也不是 null |

`escape_by(s, to_escape)` 是参照的 `escape(CharSequence, Filter<Character>)`，**方向照参照**：
谓词为真 ⇒ 该字符被转（腿 P 行 keepAll/keepNone 两档就是这条判据：keepAll 把字母数字也转成
`%61%62…`，keepNone 一位都不转）。
形状差一条：**参照把过滤器喂给每个 UTF-16 码元，本库喂码位**（`Char`）。
差异只在"星平面字符上过滤器被调几次"——本库一次、参照两次；产出串同形。
这一条是公开面的实话，不写成"等价"。

hutool 对位 `EscapeUtil.escape/escapeAll/unescape/safeUnescape` ｜
读数来源：`scripts/EscapeLeg.java`（语料）、`scripts/EscapeLeg2.java`（`SET`/`UN`/`RT`/`NAMES` 四族逐位）、
`scripts/EscapeLeg3.java`（不转义集的 BMP 全枚举对撞）｜ 血统：`InternalEscapeUtil` 源自 Apache Commons Lang。

## 1.18 UnicodeUtil：`to_unicode` / `to_unicode_all` / `unicode_of` / `unicode_to_string`

| 用例 | 读数 | 要点 |
|---|---|---|
| `to_unicode("abc")` / `to_unicode("a b")` | `abc` / `a b` | 原样档 = **0x20..0x7E 一整段**（`scripts/UnicodeScan.java` 对整 BMP 逐位扫，命中就一段：`0020-007e`） |
| `to_unicode("\n")` | `\u000a` | ⚠ "只转非 ASCII"那句常识是错的：换行是 ASCII，但不在 0x20..0x7E ⇒ 转 |
| `to_unicode("中文")` | `\u4e2d\u6587` | **小写**十六进制、四位 |
| `to_unicode("😀")` | `\ud83d\ude00` | 参照按码元出两枚 `\u`；本库把码位拆成同一对代理 ⇒ 同串（非 BMP 一律走这一档） |
| `to_unicode_all("abc")` | `\u0061\u0062\u0063` | 第二参 false 那档**一位都不留**（扫描：`KEEP|toUnicode(false)` 为空段），反斜杠自己出 `\u005c` |
| `unicode_of(0x4e2d)` | `\u4e2d` | 与串档同小写、同最少四位——三件是一把尺子，不存在"大小写分档" |
| `unicode_of(-1)` | `\uffffffff` | 参照是 `Integer.toHexString`：取低 32 位、不校验范围、不补到 6 位 |
| `unicode_of(0x10000)` | `\u10000`（5 位） | 同上——参照真出 5 位，"补成 6 位"就是自创 |
| `unicode_to_string("\u4e2d\u6587")` | `中文` | |
| `unicode_to_string("\u12345")` | 一位字符 + `5` | **固定吃四位**，不贪婪 |
| `unicode_to_string("\u4e2")` | 原样 | 位数不足 ⇒ 不解、不报错 |
| `unicode_to_string("\uZZZZ")` | 原样 | 非十六进制位同理 |
| `unicode_to_string("\\u4e2d")` | `\` + `中` | **双反斜杠挡不住它**——参照不认转义反斜杠，这是行为不是笔误 |
| `unicode_to_string("\uD83D")` | `raise(LoneSurrogate(55296))` | 参照给孤立代理码元；成对代理合成码位（`\uD83D\uDE00` → 😀），零偏差 |

参照的 `toUnicode(char)` 与 `toUnicode(int)` **逐档同读数**（腿 N 行成对打出，BMP 内每一条两侧同串）
⇒ 本库只出 `unicode_of(Int)` 一件，char 档在调用点 `.to_int()`。这不是删功能，是同义委托不出二名。

hutool 对位 `cn.hutool.core.text.UnicodeUtil`（**注意包是 `core.text` 不是 `core.util`**：
`cn.hutool.core.util.UnicodeUtil` 这个 FQN 在 jar 里不存在，javap 实测报"找不到类"）｜
读数来源：`scripts/EscapeLeg.java`（U/N/R/I 四族）与 `scripts/EscapeLeg2.java`（RAW 真实文本档）｜
差异：null 档参照给 null，本库无该形状。

## 1.19 `encode_blank(s : String) -> String`（hutool `URLUtil.encodeBlank`）

空白位逐位出 `%20`，其余**原样**（不碰非空白、不做 URL 编码）。
判据用的就是 1.14 那一张 35 位表——腿对 `encodeBlank(c)` 逐位扫与 `isBlank`/`trim`/`cleanBlank`/
`isBlankChar` 五个出口**命中集完全一致**（`scripts/BlankScanLeg.java` 三条 DIFF 行均为空），
所以本件收在 text、与本包 `is_blank` 同源，不留第二张表。
非 BMP：参照的两个代理码元都不属空白 ⇒ 原样出，本库同判。

hutool 对位 `URLUtil.encodeBlank` ｜ 差异：挂在 `URLUtil` 上的这件在语义上是"串级空白处理"，
本库归 text（归处写进 `00-hutool-map.md`，别让读者以为 codec 漏了）｜ 读数来源：
`scripts/UrlPureLeg.java`（B/W 两族 + `W|blank_ranges` 全 BMP 扫）+ `scripts/BlankScanLeg.java`。

## 1.20 替换引擎：`lookup_replacer` / `replacer_chain` / `Replacer::replace`

实体族（1.16）在参照那边就是**这三件拼出来的**（`XmlEscape` 等 `extends ReplacerChain`），
所以择路规则一旦写错，1.15/1.16 的表会整片跟着错。四条判据全部来自 `scripts/ReplacerLeg.java`：

| 判据 | 读数 | 形状 |
|---|---|---|
| **长键优先，与表序无关** | `[(ab→X),(abc→Y)]` 与 `[(abc→Y),(ab→X)]` 两张表对 `"xaby abc"` 都给 `xXy Y` | 实现按最长匹配，不许"表序第一命中" |
| **同键两条 ⇒ 后写的生效** | `[(ab→1),(ab→2)]` 对 `"ab"` 给 `2` | 逐位读数如此；不许改成"先到先得" |
| **串尾不够长就不匹配** | 腿 `L|step` 的 at=串尾档 | 不回绕、不部分命中 |
| **一遍左到右，产出不回头** | `[(ab→1)]` 链上再接 `[(1→X)]` 对 `"ab"` 给 `1`；带计数的第二件在该位置**根本没被调到** | 链 = 每位置问第一个命中的，不是依次全文替换 |
| **空键 ⇒ 参照构造即抛** | 腿 `L|ctor` 打 `StringIndexOutOfBoundsException` | 本库收成 `raise(EmptyKey)` |

**不开放逐步钩子**（参照的 `protected int replace(CharSequence,int,StrBuilder)` 不进公开面）。
理由是一条读数而不是洁癖：自造子类的返回值为**负数**时，参照的驱动循环游标倒退 ⇒
**永不收敛**（腿 `B|solo|retNeg` 在两秒超时守护下跑出 16.5 亿次调用）。
只要不开放这个钩子，这一档就构造不出来；开放了就等于把"调用方可以写出不收敛"写进契约面。
返回值 0 在参照是"不匹配"（`B|solo|ret0` 原样出、四位各调一次），与"消费 0 位"不同——
这也是只有整串面才安全的原因。

`StrReplacer`（抽象父类）与 `Replacer`（`cn.hutool.core.lang.Replacer<T>` 接口）在本库**无对位公开件**：
前者是"不开放钩子"的直接后果，后者在 MoonBit 就是函数值 `String -> String`，无需再造接口
（census 里 `Replacer` 那行判 `core` 的旧理由因此更准了，本批把它点名到件）。

hutool 对位 `text.replacer.LookupReplacer` / `ReplacerChain` / `StrReplacer` ｜
差异：参照 `replace` 返回 `CharSequence`（实为 `StrBuilder`），本库返回 `String`，无额外承诺；
参照的 `ReplacerChain.addChain`/`iterator` 是可变链形状，本库用一次构造给完 ⇒ 不做可变追加 ｜
读数来源：`scripts/ReplacerLeg.java`（L/C/B/S 四族，含 protected 档的逐位 step 读数）。

## 1.21 本包不承诺清单

`pad_start/pad_end/repeat/has_prefix/contains/replace/split_once/to_upper(ASCII)/trim_space` 等 **core 已有同义能力，本包一律不转发**（边界规则见 `AGENTS.md`「与 core 的边界」）。需要时在调用点直接用 `@string` / `String::*`。判据与理由见 `AGENTS.md`；对拍腿（门禁 G8）只适用于"包了语义层"的格子，这里没有格子可拍。
