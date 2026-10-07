# 21 · `csv` —— CSV 的读（解析）与写（序列化）

对位 hutool `cn.hutool.core.text.csv.{CsvReader,CsvBaseReader,CsvParser,CsvRow,CsvData,CsvWriter,CsvReadConfig,CsvWriteConfig,CsvConfig}`。
**件在 hutool-core**：`unzip -l hutool-core.jar | grep -c csv` 现读 **14 条**，与 `dfa`/`cache`/`bloom`/`cron` 四格不同，**不用另拉 artifact**。
进度状态见 `docs/ROADMAP.md` 第 21 行；本文是这一行契约的唯一真相。

---

## 1. 对位与边界（先划清，再写代码）

| 处置 | 件 | 理由 |
|---|---|---|
| **本批落地** | 读：`CsvParser` 的字段化 + 表头 + 行号 + 注释/空行 + trim + 列数校验；写：`CsvWriter.appendLine` 的引号判定与行分隔符 | 纯计算，期望值全部由参照腿逐条直读（468 行） |
| **不做（整片）** | `File`/`Path`/`Reader`/`Writer`/`Charset`/`InputStream` 那批构造器、`CsvUtil.load/read/write`、`writeBeans`、`CsvRowHandler`、`headerAlias` 之外的 map 绑定 | 本库零依赖四条：全同步、不带 OS 能力、不引反射/Bean 内省。读写只过 `String` |
| 第二批（排期） | `CsvRow::to_bean`、`CsvData` 的 `getFieldMap` 出口、`writeComment`、`CsvWriter` 的追加模式（`isAppend`/`appendLine`）与 `setLineDelimiter` 的多字符档 | 都依赖"更多公开形状"或本库暂不提供的记录类型映射 |
| **不在本包** | 引号内的字符集判定（`is_whitespace` 一族） | 用 `text` 包与 core `Char::is_whitespace`，本包不重定义空白 |

> **参照 5.8.35 的写方法名是 `writeLine(String...)` / `write(Iterable)`，没有 `writeRow`**（`writeRow` 是 hutool 6 的命名）。
> 本库对位件因此叫 `csv_write*`，语义逐条对齐 `writeLine` 那条路径（腿也走它取读数）。

---

## 2. 公开面（第一批 15 件 = 1 错误 + 5 结构/类型 + 6 函数 + 3 方法）

```
pub suberror CsvError { UnevenFields(Int, Int, Int) }                 // #21.1
pub struct CsvReadOpts { ... }                                        // #21.2 读配置
pub struct CsvWriteOpts { ... }                                       // #21.3 写配置
pub type CsvLine = Array[String?]                                     // 行写入形状，None＝参照的 null 档
pub struct CsvRow { line_no : Int, fields : Array[String] }            // #21.4
pub struct CsvData { header : Array[String], rows : Array[CsvRow] }     // #21.5
pub fn csv_default_read_opts() -> CsvReadOpts
pub fn csv_default_write_opts() -> CsvWriteOpts
pub fn csv_parse(text : String) -> CsvData raise CsvError
pub fn csv_parse_with_opts(text : String, opts : CsvReadOpts) -> CsvData raise CsvError
pub fn csv_write(rows : Array[CsvLine]) -> String
pub fn csv_write_with_opts(rows : Array[CsvLine], opts : CsvWriteOpts) -> String
pub fn CsvRow::get(self, index : Int) -> String?
pub fn CsvRow::field_count(self) -> Int
pub fn CsvRow::get_by_name(self, name : String) -> String?
pub fn CsvData::row_count(self) -> Int
pub fn CsvData::get_row(self, index : Int) -> CsvRow?
pub fn CsvData::header_names(self) -> Array[String]
```

---

## 3. 语义条目（每条给参照腿读数标签；标签形状 `r.<输入号>.<配置号>` / `w.<行集号>.<配置号>`，全表在 `csv/csv_test.mbt` 注释里逐一回指）

| # | 判据 | 参照读数 |
|---|---|---|
| 1 | 默认配置**不认表头**（参照 `CsvReadConfig.headerLineNo` 初值 -1），`hdr` 一律 `<none>` | `r.*.0` 全部 32 条 |
| 2 | 默认**跳过空行**（`skipEmptyRows=true`），但**行号照样推进**：`a,b\n\nc,d` 默认给两行、行号 0 和 2；关掉开关给三行、行号 0/1/2 | `r.16.0`、`r.16.2` |
| 3 | 注释符只在**行首**（上一字符是 CR/LF 或行起点）且不在引号内时生效；注释整行吞掉并推进行号：`#cmt\na,b` 只给行号 1 的一行 | `r.17.0`、`r.18.0`、`r.*.10`（注释符换成 `%`） |
| 4 | 引号成对且**恰好包住整个字段**才剥引号：`"a,b"` → `a,b`；`a"b` 与 `"a"x` **原样保留引号**；`""` → 空串 | `r.6.0`、`r.10.0`、`r.20.0`、`r.11.0`、`r.26.0` |
| 5 | 引号内两写 `""` 出一个 `"`（`"a""b"` → `a"b`）；引号内的换行/CR **保留**且行号按引号内的换行数推进 | `r.7.0`、`r.8.0`、`r.9.0` |
| 6 | 每个字段入口先剥**首尾的 CR/LF 各一层**（`StrUtil.trim(field,1,c==LF||c==CR)`），**空白不剥**；`trim_field` 打开才剥空白（`" a "` → `a`） | `r.*.0` 全部 + `r.21.3` 对比 `r.21.0` |
| 7 | 列数不等**默认不报错**（`a,b\nc` 给两行）；`error_on_different_field_count` 打开 ⇒ 参照抛 `IORuntimeException:Line 1 has 1 fields, but first line has 2 fields`，本库归口 `UnevenFields(行号, 本行列数, 首行列数)` | `r.22.0` 对比 `r.22.7`；映射的 3 条见 §5 第 3 行 |
| 8 | `begin_line_no`/`end_line_no` 是**按行号区间筛**（含端点）：`begin_line_no=1` 丢掉行号 0；`end_line_no=0` 只留行号 0 | `r.*.5`、`r.*.6` |
| 9 | 表头三档：`header_line_no=0`（第一行当表头，`rows` 不含表头行）；`=1`（第二行当表头，但参照在够不到那一行时整读失败 ⇒ 见 §5 第 2 行）；`header_alias` 把列名改名后**重名只留第一列**（`h1→H1`、`h2→H1` ⇒ header 只有一个 `H1`） | `r.23.1`（`hdr=h1|h2;[1]v1/v2/;nrows=2;byName=v1`）、`r.*.11` |
| 10 | 写侧：字段含引号/分隔符/CR/LF 才加引号，且**内部引号翻倍**（`a"b` → `"a""b"`）；否则原样 | `w.2.*`、`w.1.*`、`w.3.*` |
| 11 | `None`（参照 null）在默认档写成**空串**（`,b`），`always_delimit_text` 打开写成 `""`（`"","b"`） | `w.6.0`、`w.6.1`、`w.8.0` |
| 12 | `always_delimit_text` 打开时**每个字段都加引号**（含空字段：`{""}` → `""`） | `w.0.1`、`w.5.1` |
| 13 | 行分隔符默认 `"\r\n"`，可换单字符串；`ending_line_break` 控制最后一行后是否再给一个分隔符；两行之间恒有一个分隔符（不会重复） | `w.*.0`、`w.*.2`、`w.*.3`、`w.*.6` |
| 14 | 分隔符/引号符可换：`;` 作分隔符时字段里的 `,` **不再触发加引号**（`a,b` 原样出）；`'` 作引号符时 `"a"b"` 里的双引号不是特殊字符 | `w.1.4`、`r.*.8`、`r.*.9` |
| 15 | 未闭合引号到 EOF：参照把剩余内容并进一个字段（`x,y\n"unclosed,z` ⇒ 第二行只有一个字段 `unclosed,z`） | `r.31.0` |
| 16 | 尾随分隔符给一个尾空字段（`a,b,` ⇒ 3 个字段，最后一个是空串）；全空输入 `""` ⇒ 0 行；单换行 `"\n"` ⇒ 视 `skip_empty_rows` 而定 | `r.27.0`、`r.14.0`、`r.15.0`、`r.15.2` |

---

## 4. 参照腿

| 腿 | 载体 | 读数 | 备注 |
|---|---|---|---|
| A 实测 | 真 `hutool-core-5.8.35.jar` + 本机 JDK 17.0.14，`javac -encoding UTF-8`；读走 `new CsvReader(new StringReader(text), cfg).read()`，写走 `new CsvWriter(StringWriter, cfg).writeLine(...)` | **468 行**（`csv_ref.txt`：32 输入 × 12 读配置 + 12 行集 × 7 写配置） | 期望值全部由 `gen_csv_test.py` 从腿灌入，**手打零条**；腿的转义（CR/LF/引号/反斜杠）先解回原文、再按 MoonBit 字面量重新 escape，控制字符走 `\uXXXX`（**NUL 不许原样进源码**） |
| B 源码 | `CsvParser.readLine`/`addField`/`nextRow`、`CsvConfig` 字段初值、`CsvWriter.appendField`、`CsvRow`/`CsvData` 访问器 | 默认值逐字段现读：`fieldSeparator=','`、`textDelimiter='"'`、`commentCharacter='#'`、`headerLineNo=-1`、`skipEmptyRows=true`、`endLineNo=Long.MAX-1`、`trimField=false`、写侧 `alwaysDelimitText=false`、`lineDelimiter={'\r','\n'}`、`endingLineBreak=false` | 参照 `CsvConfig` **没有 escape 字符**（grep `escape` 零命中）⇒ 本库不设该形状 |

---

## 5. 分岔与不跟随（逐条给两侧读数）

| # | 分岔 | 参照 | 本库 | 依据 |
|---|---|---|---|---|
| 1 | `end_line_no` 的"不限制" | `Long.MAX_VALUE - 1`（`long`） | `Int` + 哨兵 `-1` 表示不限制 | 本库 `Int` 位宽随目标变（wasm 是 32 位），装不下 `2^63-2`；哨兵语义由 §3 第 8 条的区间筛读数覆盖 |
| 2 | "要表头但够不到那一行" | `read()` 内部就失败：`IllegalArgumentException:No header available!`（4 条）或 `NullPointerException:Cannot invoke ... because "this.header" is null`（33 条） | **不进冻结夹具**：腿在这些组合上压根没吐出完整形状（表头之后的行、行数、byName 都缺），本库不许拿推导当期望值。这 37 个组合已从生成结果里排除（读断言 384 → 347），语义留给 PR-B 之后按"本库给空 header + 已读到的行"另行验，并在第二批补对照腿 | 与本轮写进 `AGENTS.md` 的判据同一条：期望值必须能由本库形状产出，且必须有完整腿读数 |
| 3 | 列数不等的报错形状 | `IORuntimeException:Line 1 has 1 fields, but first line has 2 fields` | `CsvError.UnevenFields(1, 1, 2)`（行号 / 本行列数 / 首行列数） | 消息模板随 hutool 版本变；契约钉的是"哪一行、差多少"。3 条读数由脚本机械映射，映射前的原文留在断言行尾标签里 |
| 4 | 下标越界 | `List.get(i)` 抛 `IndexOutOfBoundsException` | `get`/`get_row` 给 `None` | 本库出口形状是 `Option`，不跟随一个 Java 集合实现的异常 |
| 5 | `getByName` 在未开表头时 | `CsvRow` 的 `headerMap` 为 null ⇒ 走 null 分支 | 给 `None` | §3 第 9 条的 `byName` 读数只在对齐形状处用 |
| 6 | IO 面 | `File`/`Path`/`Reader`/`Writer`/`Charset`/`InputStream` 全套 + `CsvUtil.load/read/write` | **整片不做**（只 `String` 进、`String` 出） | 零依赖四条；BOM/编码检测属 `codec` 包 |
| 7 | `writeBeans` / `CsvRow::toBean` | 有（依赖反射与 Bean 描述符缓存） | **不做** | 无反射 ⇒ 声明式映射是另一件事，第二批另议 |

---
| 12 | 写侧的 `ending_line_break` 何时落笔 | 参照在 **`close()`** 里补末尾分隔符，`flush()` 不补 | 本库的 String 出口 = 一整份文档，等价于 close 后的形状 ⇒ 开关为真时末尾补一个分隔符 | **契约笔自己的锚点错在这一条上**：PR-A 的 84 条写侧读数取自只做 `flush()` 的腿，于是 `w.*.3`/`w.*.6` 少了末尾分隔符；PR-B 把腿改成 `close()` 重跑 84 条并按新读数重发期望（读侧 347 条一字未动），改后三档 432 全绿 |

| 13 | 期望串里转义文本的**表示层** | 腿给的是转义后的文本（两字符的 `
`、`\"`） | 本库测试的 `esc()` 出口同样是两字符转义 ⇒ 期望必须**照腿的转义形状**嵌入，不可先 unesc 再嵌 | PR-A 把 71 条读侧期望先 unesc 成真 CR/真引号 ⇒ 与 `esc()` 形状永不相等，**这些断言在任何实现下都点不亮**（形状层漏法第三种）；PR-B 连这 71 条一起重发，合计本轮改动 155 条期望（71 读 + 84 写），未动 276 条（脚本按 `r.i.k`/`w.i.k` 标签逐条比对） |

## 6. 变异对照（落地轮逐条跑；先在此挂账，允许被实测推翻）

| 变异 | 预期抓到它的读数 |
|---|---|
| 默认 `header_line_no` 从"不认表头"改成 0 | §3 第 1 条：`r.*.0` 全部 32 条的 `hdr` 位 |
| 默认 `skip_empty_rows` 翻转 | §3 第 2 条：`r.16.0` 对 `r.16.2` |
| 注释判定去掉"行首"限定（任意位置的 `%`/`#` 都当注释起点） | §3 第 3 条：`r.18.0`/`r.*.10` |
| 引号剥离改成"只要字段含引号就剥" | §3 第 4 条：`r.10.0`、`r.20.0` |
| 引号内两写不去重（`""` 留成 `""`） | §3 第 5 条：`r.7.0` |
| 字段首尾 CR/LF 不剥 | §3 第 6 条：`r.*.0` 里 CRLF 组（`r.3/4` 系） |
| `trim_field` 无条件生效 | §3 第 6 条：`r.21.0` 对 `r.21.3` |
| 列数校验的三元组顺序写反 | §3 第 7 条：`r.22.7` 的 `UnevenFields[1,1,2]` |
| 行号区间改成半开（丢掉端点） | §3 第 8 条：`r.*.5`、`r.*.6` |
| 写侧"含特殊字符才加引号"改成恒加/恒不加 | §3 第 10/12 条：`w.1.*`、`w.0.1` |
| 写侧内部引号不翻倍 | §3 第 10 条：`w.2.*` |
| null 档在默认下写成 `""` | §3 第 11 条：`w.6.0` 对 `w.6.1` |
| 行分隔符默认换成 `"\n"` | §3 第 13 条：`w.*.0` 对 `w.*.2` |
| `ending_line_break` 恒真 | §3 第 13 条：`w.*.0` 对 `w.*.3` |

> 落地轮要求：每条变异实跑并记"抓到/等价/不收敛"，**等价变异当场回腿补夹具清账**（cron/textsim 两轮的既有动作，见 `docs/spec/19-cron.md` §6 与 `20-textsim.md` §6）。

---
### 6.1 落地轮实跑结果（10-06 · 基线 绿 7/红 0，逐条改一处、跑 `-p csv`、按 sha256 还原）

| 变异 | 实测 |
|---|---|
| 默认 `header_line_no` 从 -1 改 0 | **抓到**：绿 2/红 5 |
| 默认 `skip_empty_rows` 翻转 | **抓到**：绿 2/红 5 |
| 注释判定去掉「行首」限定 | **等价变异（绿 7/红 0）**：50 个输入里 `#`/`%` 只出现在行首，"
"没有一条中途 `a#b` 夹具 ⇒ 覆盖欠账，补一条即钉得住（须先回腿取真值） |
| 引号两写不塌（两写各入一次） | **抓到**：绿 1/红 6 |
| 字段首尾 CR/LF 不剥 | **等价变异（绿 7/红 0）**：状态机已在行尾消费掉 CR/LF，"
"活不到 `add_field` 这一步 ⇒ 该分支是防御性的，现有夹具抓不到（如实记，不当已覆盖） |
| `trim_field` 无条件生效 | **抓到**：绿 2/红 5 |
| `UnevenFields` 三元组顺序写反 | **抓到**：绿 6/红 1 |
| 行号上界改成半开 | **抓到**：绿 6/红 1 |
| 写侧「含特殊字符才加引号」改成恒加 | **抓到**：绿 6/红 1 |
| 写侧恒不加引号 | **抓到**：绿 6/红 1 |
| 内部引号不翻倍 | **抓到**：绿 6/红 1 |
| null 档默认也写 `""` | **抓到**：绿 6/红 1 |
| `ending_line_break` 恒不生效 | **抓到**：绿 6/红 1 |
| 引号「只判首字符就剥」/「行分隔符默认换 LF」 | **未挂载**：锚点被 `moon fmt` 重排，两轮没对上；"
"这两条语义族分别由 `r.10.0`/`r.20.0`（只判首就会误剥）与 `w.*.0` 对 `w.*.2`（CRLF vs LF）钉住，"
"留作下轮复跑（不是已抓到，不充数） |

**这一轮最重要的一条**：§5 第 12 行——**PR-A 的 84 条写侧期望锚在了只做 `flush()` 的腿上**，"
"参照的 `endingLineBreak` 其实到 `close()` 才落笔。也就是「期望值必须能由本库形状产出」这条判据"
"还有后半句：**腿取读数的时机也要对齐本库出口的形状**（String 出口＝整份文档＝close 之后）。"

## 7. 状态

`docs/ROADMAP.md` 第 21 行的状态与本节同步（`scripts/sync_status.py --write` 生成，勿手改）：
**已实现**（10-06 两笔：`csv` 契约 `PR-A` → PR-B 落地）。三档一致 432 = 绿 432/红 0；§6.1 十四条变异逐条实跑（11 抓到、2 等价变异列为覆盖欠账、2 未挂载如实记）；落地轮重发 155 条期望（写侧 84 条：§5 第 12 行的 flush/close 锚点；读侧 71 条：§5 第 13 行的转义表示层——两类都是形状层错，任何实现都点不亮），其余 276 条期望逐条比对未动。

## 8. 默认档补档（10-08，`csv/csv_default_test.mbt`）

这批打的不是新语义，而是**四件此前一条用例都没打到的公开面**：`csv_parse`（默认档，它只是
`csv_parse_with_opts(text, csv_default_read_opts())` 的一层皮）、`CsvRow::field_count`、
`CsvRow::get`、`CsvData::get_row`。此前 csv 的用例全走 `_with_opts` 那一支，默认入口等于没测。

腿 `Csv2Leg.java`（hutool-core 5.8.35 · JDK 17.0.14）出 9 对夹具 × 两种 skip 档 + 越界档 =
**18 块**进断言，全仓 **1270 = 绿 1270 / 红 0**（三档一致），G15 基线 198 → **192 行**（csv 10 → 4）。

一条必须记下来的形状差：**参照的 `CsvReadConfig.defaultConfig()` 是 `skipEmptyRows=false`，
而本库默认档是 `true`**。所以"对撞参照默认"要用 `skip=false` 的显式 opts（`RD` 族），
"对撞本库默认"用 `csv_parse`（`RS` 族）——两套读数各钉各的入口，不许顺手统一成一种。

| 档 | 参照 | 本库 | 处置 |
|---|---|---|---|
| `parse("")` / `skip("")` | `NumberFormatException`（`beginLineNo` 那条 `Long.parseLong("")`） | `rows=0` | **登记不钉**：没有已有决策行可指，要跟随得先拍"空文本算不算零行" |
| 下标越界（`get_row(-1)`/`get_row(n)`/`get(-1)`/`get(count)`） | `IndexOutOfBoundsException` | `None` | 钉本库形状（§5 第 4 行已声明"不跟随一个 Java 集合实现的异常"），参照原读数在断言注释里 |
| 默认写出档 `WR/WRQ/WRE` | `CsvWriter` 在 `flush()`/`close()` 后给出的串**不带行分隔符** | CRLF 且每行追加 | **不进本批**：要先读清参照分隔符的写出时机，不同形的对撞等于自创映射（`csv_write` 那层皮因此仍未覆盖） |

变异对照：`Y2`（引号跨行的 `st.line_no += st.q_lines` 改成不推进）**0 红＝按构造不可判别**——
本库公开面不导出行号，`line_no` 只驱动内部推进，所以没有任何公开读数会因它改变；要让它可判别，
得先加一件"取该行原始行号"的出口，那是契约扩张、不属于补档。`Y1`（行首 CR/LF 不剥）锚点命中 2 次，
按"锚点唯一"规矩不作证据。剩余 4 行：`188`（`csv_write` 那层皮，见上表第三行）、`338/341`
（行首行尾剥 CR/LF 的两支，`Y1` 想打的就是它，锚点重挂后归下一批）、`410`（`comment` 缺省支）。
