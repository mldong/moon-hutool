# 契约 01 · text（字符串门面）

> 状态：**签名与期望值已冻结，实现未开工**（`text/text.mbt` 函数体是 `abort`，`text/text_test.mbt` 19 条用例里的 text 部分预期红）。
> 权威顺序：**本表 + `text_test.mbt` 的期望值 > hutool 行为 > 个人直觉**。实现期要改任何期望值，必须单独一笔 commit 并给出"读数来源"列的新证据（门禁 G5 拦改）。
> 表头说明：**血统**列指 hutool 自己也不是原创的那几格（`CharSequenceUtil` 明写 "Thanks to Apache Commons Lang 3.5"）——移植这些格时真上游是 Apache 系，别按"木兰来源"处理。

## 1.1 包级三条口径（本机编译器裁决，不是风格偏好）

| 口径 | 定案 | 依据 |
|---|---|---|
| 入参类型 | 一律 `String`，不在每个函数上铺 `Option` | MoonBit 无 null。hutool `isBlank(null)=true` 由调用方边界 `unwrap_or("")` 等价达成；只有"缺失本身是业务语义"的两处保留 Option（1.4 `trim_opt`、1.10 `first_non_blank`） |
| 返回类型 | 一律 `String`，**不把 `StringView` 作对外契约** | 编译器实证：`String` 字面量不隐式转 `StringView`，且 `String` **没有** `as_view` 方法 ⇒ 视图入参会让每个调用点手工转换 |
| 空白判定 | core `Char::is_whitespace`（Unicode White_Space 子集）**并集** hutool 独有 7 码点 | core 侧已覆盖 U+0085/U+00A0/U+1680/U+2000–U+200A/U+2028/U+2029/U+202F/U+205F/U+3000；hutool 另算 **U+0000 U+200C U+180E U+2800 U+3164 U+FEFF U+202A** ⇒ U+0000 这条必须保留（多数实现会漏） |
| 转义限制 | `\u{...}` 只能写在 **char 字面量**，不能写进字符串 | 写进字符串会被切成插值 ⇒ `Lexing error: missing expression in string interpolation`（本机实测） |

## 1.2 `is_blank(s : String) -> Bool`

| 输入 | 期望 | 备注 |
|---|---|---|
| `""` | true | |
| `"   "` / `"\t \n"` | true | 制表与换行算空白 |
| U+0000 / U+3000 单字符 | true | 见 1.1 第三行 |
| `"a"` / `" a"` | false | 有一个非空白即假 |

hutool 对位 `StrUtil.isBlank` ｜ 差异：不收 null ｜ 读数来源：hutool v5-master 实测（`CharUtil.isBlankChar` 码点清单）+ core `builtin/char.mbt:166` ｜ 血统：`CharSequenceUtil` 源自 Apache Commons Lang 3.5

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
| `sub_before("path/to/file.txt", "/")` | `"path/to"` | 按**首个**分隔符 |
| `sub_before("nope", "/")` | `"nope"` | 未命中 → **整串** |
| `sub_after("path/to/file.txt", "/")` | `"file.txt"` | 按**首个**分隔符之后全部 |
| `sub_after("nope", "/")` | `""` | 未命中 → **空串**（与上一行不对称，别"顺手统一"） |
| `sub_between("hutool{abc}end", "{", "}")` | `"abc"` | |
| `sub_between(..., include_sep=true)` | `"{abc}"` | |
| `sub_between("hutool abc end", "{", "}")` | `""` | 任一界定符缺失 → 空串 |

hutool 对位 `subBefore/subAfter/subBetween` ｜ 读数来源：hutool v5-master 实测。

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
| `hide("中文测试", 1, 3, '*')` | `"中**"` | **码点**下标，不是 UTF-16 单元（core `length()` 是 UTF-16 计数，这里必须用 `char_length()`） |
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

## 1.14 本包不承诺清单

`pad_start/pad_end/repeat/has_prefix/contains/replace/split_once/to_upper(ASCII)/trim_space` 等 **core 已有同义能力，本包一律不转发**（边界规则见 `AGENTS.md`「与 core 的边界」）。需要时在调用点直接用 `@string` / `String::*`。判据与理由见 `AGENTS.md`；对拍腿（门禁 G8）只适用于"包了语义层"的格子，这里没有格子可拍。
