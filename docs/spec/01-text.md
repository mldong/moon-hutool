# 契约 01 · text（字符串门面）

> 状态：**已实现**（10-04，`text/text.mbt` 18 个公开函数，text 侧 23 条用例全绿，三档读数一致）。本页期望值先冻结后实现；
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

## 1.15 本包不承诺清单

`pad_start/pad_end/repeat/has_prefix/contains/replace/split_once/to_upper(ASCII)/trim_space` 等 **core 已有同义能力，本包一律不转发**（边界规则见 `AGENTS.md`「与 core 的边界」）。需要时在调用点直接用 `@string` / `String::*`。判据与理由见 `AGENTS.md`；对拍腿（门禁 G8）只适用于"包了语义层"的格子，这里没有格子可拍。
