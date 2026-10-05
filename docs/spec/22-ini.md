# 22 · ini —— INI 分组文本的读与写 + `GroupedMap`

对位 hutool：`cn.hutool.setting.GroupedMap`、`cn.hutool.setting.SettingLoader`（逐行解析主体 + `private store(PrintWriter)`）、
`cn.hutool.setting.Setting` 的分组读取面（`getByGroup` / `getStr(key, group, default)` / `getStrNotEmpty` / `toProperties` / `getGroups`）、
`cn.hutool.setting.dialect.Props` 的**非 IO** 部分。参照版本 5.8.35。

## 1. 边界

**件在 hutool-setting，不在 core**：`unzip -l hutool-core.jar | grep -ciE "props|grouped"` 现读 **0**
（core 的 `cn/hutool/core/map/` 里只有 `BiMap`/`TableMap`/`ForestMap` 等，没有 `GroupedMap`；`cn/hutool/core/util/` 只有
`SystemPropsUtil`）。本格因此**另拉 artifact**（与 `dfa`/`cache`/`bloom`/`cron` 同性质，与 `hash`/`csv` 相反）：
`hutool-setting-5.8.35.jar` 现读 `cn/hutool/setting/GroupedMap.class` + `dialect/Props.class` + `SettingLoader.class` 三件齐；
运行期还要 `hutool-log-5.8.35.jar`——`SettingLoader` 的 `private static final Log log = Log.get()` 是类初始化依赖，
缺它腿直接 `NoClassDefFoundError`（本轮实踩，第一次跑出的 60 条"读数"全是 `ERR` 行）。

**零 IO**：参照 `Props` 的 12 个构造重载 + `getProp` 三档 + `load(URL|Resource|File|String path)`、`Setting` 的
`SettingUtil`/`SettingLoader(Resource)`、`autoLoad(boolean)`（`WatchMonitor` 文件监听）、`store(String|File)` 全部不收；
`toBean`/`fillBean`/`getAndRemoveStr` 走反射或别名语义，不收；`YamlUtil`/`Profile` 与本格无关。
变量的最后一档查找 `SystemPropsUtil.get(key)`（系统属性 → 环境变量）是**宿主状态**，跨机器不可复现，
本库不收（§5 第 4 行给出两侧读数）。

**分批**：行 22 的第二半——`java.util.Properties` 的严格语义（`\` 续行、`!` 也当注释、键值分隔符是
`=`/`:`/空格三档、`\uXXXX` 解码、ISO-8859-1、`store` 的转义表）落在 `dialect/Props` 转手的 `super.load(reader)` 上，
权威参照是 JDK 而不是 hutool，形状与本格的"剥边 + 单分隔符 + 无转义"几乎处处相反 ⇒ **另立第二批**（同一 `ini/` 包、
`#22.26` 起续号），不混进本批的语义表里。

## 2. 公开面（24 件）

| # | 项 | 参照 |
|---|---|---|
| 22.1 | `pub struct GroupedMap`（`priv order`/`priv buckets`/`priv cached_size`） | `cn.hutool.setting.GroupedMap` |
| 22.2 | `pub(all) struct IniParseOpts { use_variable : Bool, assign_flag : Char }` | `SettingLoader` 构造参数 + `setAssignFlag(char)` |
| 22.3 | `ini_default_parse_opts()` | `new SettingLoader(groupedMap)`（转手 `this(gm, UTF_8, false)`）＋字段初值 `assignFlag = '='` |
| 22.4 | `grouped_map_new()` | `new GroupedMap()` |
| 22.5 | `grouped_map_put(gm, group?, key, value?) -> String?` | `String put(String group, String key, String value)` |
| 22.6 | `grouped_map_get(gm, group?, key) -> String?` | `String get(String group, String key)`（**双参档不剥边**） |
| 22.7 | `grouped_map_remove(gm, group?, key) -> String?` | `String remove(String group, String key)` |
| 22.8 | `grouped_map_clear_group(gm, group?) -> Unit` | `GroupedMap clear(String group)` |
| 22.9 | `grouped_map_size(gm) -> Int` | `int size()`（带缓存） |
| 22.10 | `grouped_map_is_empty(gm) -> Bool` | `boolean isEmpty()`（`size() == 0`） |
| 22.11 | `grouped_map_is_group_empty(gm, group?) -> Bool` | `boolean isEmpty(String group)` |
| 22.12 | `grouped_map_contains_key(gm, group?, key) -> Bool` | `boolean containsKey(String group, String key)` |
| 22.13 | `grouped_map_contains_value(gm, group?, value?) -> Bool` | `boolean containsValue(String group, String value)` |
| 22.14 | `grouped_map_groups(gm) -> Array[String]` | `keySet()` / `Setting.getGroups()` |
| 22.15 | `grouped_map_keys(gm, group?) -> Array[String]` | `Set<String> keySet(String group)` |
| 22.16 | `grouped_map_values(gm, group?) -> Array[String?]` | `Collection<String> values(String group)` |
| 22.17 | `grouped_map_entries(gm, group?) -> Array[(String, String?)]` | `entrySet(String group)` / `Setting.getMap(group)` |
| 22.18 | `grouped_map_put_all(gm, group?, entries) -> Unit` | `GroupedMap putAll(String group, Map<..> m)` |
| 22.19 | `grouped_map_flatten(gm) -> Array[(String, String?)]` | `Setting.toProperties()` 的键拼接规则 |
| 22.20 | `ini_parse(text) -> GroupedMap` | `SettingLoader.load(InputStream)` 主体 |
| 22.21 | `ini_parse_with_opts(text, opts) -> GroupedMap` | 同上 + `setAssignFlag` |
| 22.22 | `ini_store(gm) -> String` | `private store(PrintWriter)` |
| 22.23 | `ini_get_str(gm, key, group?, default?) -> String?` | `AbsSetting.getStr(key, group, default)` |
| 22.24 | `ini_get_str_not_empty(gm, key, group?, default?) -> String?` | `AbsSetting.getStrNotEmpty(key, group, default)` |
| 22.25 | `ini_store_with_opts(gm, opts) -> String` | `SettingLoader.store(PrintWriter)` 读的正是该 loader 的 `assignFlag` 字段（**PR-B 补的公开项**，见 §5 第 10 行） |

**无 raise 面**：参照在这条文本路径上不报错——不合规的行是**丢弃**（`keyValue.length < 2 ⇒ continue`），
`load(InputStream)` 只 `return true`；`SettingRuntimeException` 属 `SettingUtil` 的 IO 路径，不进本库。
公开项一律 `String?` 表达"读不到"，参照的 null 全部映射成 `None`。
**键的 null 档不进契约**：参照 Java 签名收 `String key`，`LinkedHashMap` 也容得下 null 键，
腿有一档读数（`o.S14.8`：`get(null, null)` ⇒ `null`），本库键类型是 `String` ⇒ 该档在测试里就地标注、不写断言。

## 3. 语义（每条挂读数标签；读数由 §4 的腿灌入）

1. **剥边用的空白码位表不是 `Character.isWhitespace`**：腿对**整个 BMP 逐位扫**（`trim(c+"x"+c)=="x"` 与
   `isBlank(c)` 两档），命中集完全一致，共 34 位：
   `00 09 0a 0b 0c 0d 1c 1d 1e 1f 20 a0 1680 180e 2000-200a 2028 2029 202a 202f 205f 2800 3000 3164 feff`。
   比 Java 多出 `00`、`a0`、`180e`、`202a`、`2800`、`3164`、`feff`；`0085`（NEL）与 `200b-200f`（ZW 系列）**不在表内**。
   两侧同表 ⇒ 本库只需一个 `is_blank_char`。BMP 外未扫（`Character.isWhitespace` 在 Unicode 里没有星平面真值），
   实现按"码位 > 0xffff 一律非空白"处理，`i.emoji_key`/`i.emoji_value` 是这条的现读旁证（键 `\U0001f600k` 原样保留）。
   `i.form_feed`（`a=\f b` ⇒ 值 `b`）、`i.nbsp`（⇒ `b`）、`i.bom_line`（`\ufeffa=1` ⇒ 键 `a`）、
   `i.u2028_in_value`（`\u2028` 在**值中间**原样留着——它是剥边字符，不是行分隔符）、
   `i.u0085_in_value`（NEL 完全不参与，既不作行分隔也不剥）。
2. **整行先剥边，再判注释/空行/分组**：`i.comment_indented`（`   # c` 也是注释）、`i.blank_lines`（纯空白行跳过、
   `\u00a0` 行也算空白行——两档同表）。注释符只有 `#`：`i.comment_semi` 的 `; c` 不是注释，但因不含 `=` 而被丢弃，
   读数是"这一行什么都没进"而不是"进了一个键 `; c`"——两档都在表里，别把 `;` 当注释符。
3. **分组行必须是整行被 `[` `]` 包住**（参照 `StrUtil.isSurround`）：`p.surround` 现读 `"[]"→true`、`"["→false`、
   `"a]"→false`、`"[a]]"→true`、`"[a]=[b]"→true`。于是 `i.group_spaces`（`[ g ]` ⇒ 组 `g`）、
   `i.group_open_only`（`[` 单独一行不算分组，且它不含 `=` ⇒ 整行丢弃）、`i.value_brackets`（`[a]=b` 不是分组行 ⇒ 键 `[a]`）、
   `i.both_brackets`（`[a]=[b]` **算分组行**，组名成了 `a]=[b`，但分组行不建组 ⇒ 容器仍是空）、
   `i.group_bracket_inner`（`[a[b]]` ⇒ 组名 `a[b]`）、`i.group_with_eq`（`[a=b]` ⇒ 组名 `a=b`）、
   `i.group_chinese`（`[分组]内=k` 不是分组行 ⇒ 键带方括号原样进）。
4. **分组行本身不进数据，组在首次写入时才出现**：`i.only_group`（`[g]` 一行 ⇒ 0 条、`groups` 空）、
   `i.group_reopen`（`[g] a=1 / [h] b=2 / [g] c=3` ⇒ 组顺序仍是 `g|h`，`c` 追加进已有的 `g`）。
5. **键值只切第一刀**（`StrUtil.splitToArray(line, assign, 2)`；`p.split2` 现读 `"a=b=c"→["a","b=c"]`、
   `"=="→["","="]`、`"a"→["a"]` 长度 1、`""→[""]`）：`i.multi_eq`（`a=b=c=d` ⇒ 值 `b=c=d`）、
   `i.line_only_assigns`（`===` ⇒ 键空串、值 `==`）。
6. **切不开就整行丢弃，裸键不成空值**：`i.no_assign`（`onlykey` ⇒ 0 条）——这是与 `java.util.Properties`
   最扎眼的分岔（§5 第 1 行给两侧读数）。
7. **键与值各自再剥边，空串两侧都合法**：`i.empty_key`（`=v` ⇒ 键空串）、`i.key_ws_only`（`   =   ` ⇒ 键空串、值空串）、
   `i.val_blank_only`/`i.val_nbsp_only`/`i.value_only_space`（值一律空串 `""`，**不是 `None`**）、
   `i.tab_around`、`i.key_inner_space`（键内空格保留）。
8. **同组重复键：值后写覆盖，位置保持首次**：`i.dup_key`（⇒ `a=2`）、`i.dup_three`（键序 `a,b,c` 而 `a` 的值是 `5`）、
   `o.S1.3`（`put` 返回旧值 `1`）、`o.S1.10`（`values` 跟着键位走 ⇒ `9,2`）。
9. **无分组 = 空串组**（参照 `group = null` 进 `put` 后 `nullToEmpty`）：`i.ws_group`（`[  ]` ⇒ 空串组）、
   `i.merge_default`（`x=1` 与 `[  ]` 后的 `y=2` 落进**同一个**空串组，顺序 `x,y`）、
   `o.S5.2`/`o.S5.5`/`o.S6.2`（`None` 组、`""` 组、`"  "` 组三者互相可见）。
10. **容器对组名"兜底 + 剥边"，但对键名不剥边**：`o.S11.2`（键 `" k "` 原样进 `keys`）、`o.S11.3`（`get(g,"k")` 读不到）、
    `o.S11.4`（`get(g," k ")` 才读到）。
11. **双参 `get` 不剥边，与其余方法不对称**：`o.S2.1` 用组名 `" x "` 写入 ⇒ `o.S2.2` 组表是 `x`，
    而 `o.S2.3` 的 `get(" x ")` 给 `None`、`o.S2.4` 的 `get("x")` 给 `Some("v")`；
    `has_key`/`has_value`/`keys`/`values`/`remove`/`clear`/`is_group_empty` 都剥边（`o.S2.5`–`o.S2.9`、`o.S2.10`）。
12. **总条数是带缓存的，且 `remove`/`clear` 不失效它**：`o.S3.3` 读 `2` → `o.S3.4` 删一条 → `o.S3.5` **仍读 2**，
    `o.S3.7` 的 `is_empty` 跟着错；`o.S8.1`–`o.S8.9` 是同一条链的更长读数（删空后 `size` 停在 2、`put` 一条新的才复活）；
    `o.S13.3`/`o.S4.5` 是反面：缓存从未填过时删完再读 ⇒ **正确**的 0。
    ⇒ 本库照搬（同名同值是本包的存在理由），但这是"逻辑计数会骗人"的一档，§5 第 5 行两侧都写。
13. **`clear(group)` 只清条目、不摘组**：`o.S4.2`–`o.S4.4`（组 `g` 仍在组表里、`keys` 空）、`o.S4.6` `is_group_empty` true；
    `o.S2.13` 同理（键删空后组名仍留着）。
14. **`putAll` 是逐条转手**（不是整组合并）：`o.S9`（S9.1 之后的 `keys` ⇒ `a,b`，条目序按传入序）。
15. **缺组缺键一律静默**：`o.S14.1`（删不存在的键 ⇒ `None`）、`o.S14.4`–`o.S14.6`（不存在组的 `groups`/`keys`/`values` ⇒ 空数组）、
    `o.S14.7`（`is_group_empty(None)` ⇒ true）、`o.S12`（值为 `None` 的条目：`get` ⇒ `None`、`has_value(g, None)` ⇒ **true**、
    `values` ⇒ `<null>`，即"键存在但值是 null"与"键不存在"在 `get` 档不可分辨，只在 `has_value`/`values` 档可分辨）。
16. **变量替换只在 `use_variable` 打开时做，且只看本行之前已写入的值**：正则 `\$\{(.*?)\}`（参照 `varRegex` 字段初值），
    `i.var_basic` ⇒ `b=1`；`i.var_forward_ref` ⇒ **原样 `${a}`**（写在前面才可见）；`i.var_same_group` 同组命中；
    `i.var_cross_group` 按**第一个点**切成组+键命中；`i.var_multi_dot`（`${g.a.b}` ⇒ 切成 `g` + `a.b` ⇒ 读不到 ⇒ 原样留着）；
    `i.var_in_group_name`（组名本身带点 ⇒ 跨组查找必然落空）；`i.var_dotted_key`（同组优先：键就叫 `g.a` 时同组直接命中）；
    `i.var_missing`/`i.var_undefined_keeps`/`i.var_self_ref`/`i.var_empty_inner`（`${}` 内层是空白 ⇒ 整档跳过）；
    `i.var_twice`/`i.var_spaced`/`i.var_partial`（按字面串整串替换，出现几次换几次）；
    `i.var_prefix_collide`（`${a}-${ab}` 各自独立解析，不串）；`i.var_blank_value`（变量解析成空串 ⇒ **仍然替换**，
    因为参照判的是 `null != varValue`）；`i.nested_brace`/`i.brace_only`/`i.var_blank_after_trim`（`${ a }` 内层带空格 ⇒
    当作键 `" a "` 查，查不到就原样留着）；`i.var_no_flag`（开关关掉时同一段文本整档不替换）。
17. **写侧格式固定、一律不转义**：`[组名]` 单独一行（空串组写 `[]`），条目行是 `键 + 空格 + assign + 空格 + 值`，
    **每行都以分隔符结尾**，空容器给空串；`i.assign_is_space` 的 store 因此出现三个连续空格（`a␣␣␣b c`），
    `w.S15.store` 是坏形状总集合（值含 `\n` 就写出多行、`None` 写成字面 `null`、组名含 `]` 写成 `[a]b]`）；
    `w.S16.store` 是"清空组后仍写组头"那一档（`[g]\n` 之后什么都没有）。
18. **读取面的分界：`get_str` 只在读不到时兜底，`not_empty` 连空值一起兜底**：
    `s.b/g/D.str3` ⇒ 空串（值真的是空串，不兜底）、`s.b/g/D.not_empty` ⇒ `D`；
    `s.missing/g/D` 两档都给 `D`；`s.n//D`、`s.n/null/D` ⇒ 组名换成空串/`None` 后读不到 ⇒ `D`（组 `g` 的东西看不见）；
    `s.n/g/D.by_group` ⇒ `1`（#22.6 的裸读档与 #22.23 在同一条腿路上）。

## 4. 参照腿

| 腿 | 内容 |
|---|---|
| 件 | `hutool-setting-5.8.35.jar`（`GroupedMap`/`SettingLoader`/`Setting`/`dialect/Props`）+ `hutool-core-5.8.35.jar` + `hutool-log-5.8.35.jar`，本机 JDK 17.0.14，`javac -encoding UTF-8` |
| 解析路 | `new SettingLoader(gm, UTF_8, isUseVariable)` + `setAssignFlag(c)` + `load(new ByteArrayInputStream(text.getBytes(UTF_8)))`——就是参照自己 `Setting.load` 的下游 |
| 写侧路 | 反射取 `SettingLoader` 的 `private store(PrintWriter)`（`setAccessible`），`StringWriter` 收字节；`File`/`InputStream` 那批入口只在腿里出现，不在本库公开面 |
| 摊平规则 | `Setting.create()` → 逐条 `putByGroup` → `toProperties()`，把 `Hashtable` 的键**排序后**对账：本库按"组顺序 × 键顺序"给出的扁平集，必须与腿的键集逐字相同 ⇒ 生成脚本内断言（82 个输入逐条核，`i.group_reopen` 给 `g.a/g.c/h.b`，空串组给裸键） |
| 空白表 | `IniRef3` 对 BMP 全量扫（`0x0000-0xD7FF` + `0xE000-0xFFFF`），`trim(c+"x"+c)` 与 `isBlank(c)` 两档一致 ⇒ 34 位表 |
| 夹具 | `gen_cases.py`/`gen_cases2.py`/`gen_cases3.py`/`gen_ops_final.py` 生成 `cases*.tsv`（文本 base64 承载，杜绝转义层歧义）+ `opsF.tsv`（113 步操作脚本），腿输出与 MoonBit 测试都由同一批 JSON 灌入 |
| 读数 | 612 + 366 + 139（本轮补跑）+ BMP 扫描行；测试文件 14 块 634 条断言，逐条挂 `i.<夹具>.<档>` / `o.<脚本>.<步>.<档>` / `s.<探针>` / `w.<脚本>.<步>.store` |
| 分隔符口径 | 参照的 `store` 走 `PrintWriter.println` ⇒ **平台量**，本机腿现读 `lineSep=\r\n`。本库钉死 `\n`：期望值由腿读数做"整串按 `\r\n` 切、用 `\n` 拼回"的变换（切分是机械的、非手打）。腿读数里出现 `\r\r\n`（值尾带 CR 紧贴分隔符）的夹具**不做对拍**，在测试里就地标注——本轮实际命中的是 `w.S15.store` 那一条（值 `x\ry` 后跟分隔符） |

## 5. 与参照的分岔（两侧读数都写）

1. **裸键**：`java.util.Properties.load` 里 `onlykey` ⇒ 键 `onlykey` 值空串；本格的 `SettingLoader` ⇒ **整行丢弃**
   （`i.no_assign` 读数 0 条）。第二批（`Props` 严格语义）要给的是相反的那一档，别在这里跟随。
2. **反斜杠**：`java.util.Properties` 认 `\` 续行与 `\uXXXX`；本格两者都不参与（`i.backslash` ⇒ 值 `c:\d`、
   `i.unicode_escape` ⇒ 值字面 `\u4e2d`、`i.esc_seq_value` ⇒ 值 `\nb` 四字符）。
3. **注释符**：`java.util.Properties` 认 `#` 与 `!`；本格只认 `#`（`i.comment_semi` 的 `;` 档不是注释；`!` 档本批未开夹具，
   留第二批一并给）。
4. **变量的宿主档**：腿 `i.var_system_prop` 现读 `${java.version}` ⇒ `17.0.14`（走 `SystemPropsUtil`），
   `i.var_system_prop_missing` ⇒ 原样留着。本库**没有宿主那一档** ⇒ 同夹具在本库只可能得到"原样留着"。
   这是有意分岔，且**宿主读数根本不进测试**：`17.0.14` 是这台机器的 JDK 版本，写进契约就是一条换台机器必红的期望值——
   生成脚本里已把 `var_system_prop` 从夹具表摘掉（`var_system_prop_missing` 保留，它的期望与宿主无关）。
   记在这里只是为了说明"参照多做了一档查找"，两侧读数都不需要可对拍。
5. **`size` 的陈旧读数**：参照删完仍报旧数（`o.S3.5` = 2，逻辑值 1）。本库跟随。判据：`grouped_map_size`
   的契约不是"当前条数"，而是"最后一次 `put` 之后、首次读取时冻结的条数"。
6. **双参 `get` 不剥边**（`o.S2.3` vs `o.S2.4`）：本库跟随——不对称是参照的形状，不是笔误可以顺手修。
7. **行分隔符**：参照 `println` ⇒ 平台量（本机 `\r\n`）；本库固定 `\n`（§4 末行口径）。wasm/js/native 四档里
   "平台"没有唯一答案，写死才可对拍。
8. **键的 null 档**：参照签名容 `null` 键（`o.S14.8` 读数 `null`），本库键类型 `String` ⇒ 该档不进契约。
9. **并发面**：参照 `GroupedMap` 内部是 `ReentrantReadWriteLock`；本库全单线程，锁不进契约（无共享状态可保护）。

10. **序列化要拿得到分隔符**：PR-A 只给了 `ini_store(gm)`（默认 `=`），但参照 `store` 输出的是它自己 loader 的 `assignFlag` 档 ⇒ 腿的 `i.assign_colon`（`a : b`）、`i.assign_is_space`（`a` 后三个空格）、`i.assign_is_tab` 三条读数用默认档点不亮。**落地时补 #22.25 `ini_store_with_opts`，三条断言只换调用式、期望串逐字未动**（不删期望、不改期望——那是 PR-A 的漏，不是腿的错）。

## 6. 变异对照（PR-B 实测读数，10-06）

工装：整树 `tar` 到隔离副本（`Temp/mutini/proj`）后逐条改源码跑 `moon test ./ini --target wasm`，
每条写完立刻还原，收尾断言"副本与基线字节相同 + 基线复跑仍 0 红"。
**开局先断基线**：上一版工装在第一条测试调用处被 GBK 解码异常打断，把已改的源码留成了"基线"，
于是那一轮的 10 条读数全是相对脏基线测的——本轮加了三道判据（开局断言基线 0 红、逐条 finally 还原、
收尾字节比对 + 复跑），修完重跑才是下面这组数。

| # | 变异 | 读数 | 判据落点 |
|---|---|---|---|
| M1 | 注释符把 `;` 也算注释 | 红 1 / 14 | 首轮是**等价变异**（红 0）——老夹具里 `;` 起头的行本来就不含 `=`，两种走法都落进"丢弃"。补 `;k=v`、`  ; k = v  `、`;[g]` 三条夹具后这条判据才可达（腿现读键 `;k` 值 `v`） |
| M2 | 分组判定放宽成"行首是 `[` 就算" | 红 1 / 14 | `i.value_brackets`（`[a]=b` 的键是 `[a]`） |
| M3 | 切分改成切最后一刀 | 红 2 / 14 | `i.multi_eq`、`i.line_only_assigns` |
| M4 | 裸键不丢弃（当空值收） | 红 3 / 14 | `i.no_assign`、`i.comment_semi`、`i.semi_group_line` |
| M5 | 键与值都不剥边 | 红 3 / 14 | `i.tab_around`、`i.val_blank_only`、`i.blank_lines` |
| M6 | 重复键改成"移到末尾" | 红 2 / 14 | `i.dup_three`（键序须是 `a,b,c`）、`o.S6` 系列 |
| M7 | 双参 `get` 也剥组名边（修掉不对称） | 红 1 / 14 | `o.S2.3`/`o.S2.4`——**跟随参照的不对称确实被钉住了** |
| M8 | `remove` 之后也失效总条数缓存 | 红 2 / 14 | `o.S3.5`/`o.S8.7`——陈旧读数同样确实被钉住 |
| M9 | 变量查找改成跨组优先 | 红 1 / 14 | `i.var_dotted_key`（同组里就有键 `g.a`） |
| M10 | 查不到的变量替换成空串 | 红 1 / 14 | `i.var_missing` 等"原样留着 `${...}`"档 |
| M11 | `store` 对值里的换行做转义 | 红 1 / 14 | `w.S15.store`（值含 `\n` 就写出多行） |
| M14 | 值一律写成空串（抹掉 null 档与真空串档的差别） | 红 11 / 14 | 覆盖面最广的一条，说明形状断言不是摆设 |
| M12 | 空白码表去掉 `feff` | **未挂载** | `moon fmt` 把 17 项布尔式折成多行，按源码字面挂锚点失败。判据本身可达（`i.bom_line` 的键 `a` 就靠这条），留第二批连同 M13 一起补挂（改法是把码表数据化成数组再判） |
| M13 | 空白码表加入 `0085` | **未挂载** | 同上锚点问题；另注：现有夹具只在**值中间**放过 `0085`（`i.u0085_in_value`），没在行/键/值的**边上**放过 ⇒ 即便挂上也仍是等价变异，要连夹具一起补 |

等价变异一条（M1 首测）已用补夹具的方式转成可达判据；两条未挂载（M12/M13）如实记着，不写成"已覆盖"。

## 7. 状态

第一批已落地、第二批契约已冻结（10-06：PR-A `ad64808` 冻结 INI 面、PR-B 落地转绿；第二批 PR-A 冻结 `#22.26`–`#22.40`，7 块设计态红）。
落地轮读数以 `docs/ROADMAP.md` 逐包表与 README 读数块的当场生成值为准（本包 14 块、674 条断言，
wasm / wasm-gc / js 三档一致；`moon check` 0 警告 0 错误，`.mbti` 由 `moon info` 现生成）。
PR-B 对契约的**两处更正**都记在案：
① 新增公开项 **#22.25 `ini_store_with_opts`**——参照的 `store` 读的是它自己 loader 的 `assignFlag` 字段，
   PR-A 只给默认档，落地时点不亮 `i.assign_colon`/`i.assign_is_space`/`i.assign_is_tab` 三条腿读数；
   因此这三条断言的调用改成带选项档（**期望串逐字未动**，只换调用式，见 §5 第 10 行）。
② 新增 9 条注释符夹具（M1 等价变异暴露的覆盖面缺口）。
第二批（`Props` 的 `java.util.Properties` 严格语义，`#22.26` 起，权威参照是 JDK）仍待开工。

## 8. 第二批腿读数（已跑，签名待定 —— 权威参照是 JDK 不是 hutool）

**为什么要单列**：参照 `dialect.Props` 的解析全部转手 `super.load(reader)`（源码里只有一行 `super.load(reader)`），
所以这一半的真相在 `java.util.Properties`。腿只用 JDK（本机 `jdk-17`，17.0.14），
`load(StringReader)` + `store(StringWriter, null|"CMT")`，45 个多行夹具 + 49 条单行直档探针 = **383 行读数**
（夹具经 base64 承载，转义歧义归零）。本节的读数只作**证据**，签名与冻结期望值另走一轮 PR-A；已核事实如下。

1. **分隔符是三档不是两档**：`=`、`:`、空白（空格 / Tab / `\f`）都能当键值分隔符
   （`Q.0`/`Q.1`/`Q.2`/`Q.42` 一律给键 `k` 值 `v`），且**分隔符前的空白全部被吃掉**
   （`Q.6` `k = v` ⇒ 键 `k` 值 `v`）——与第一批"先整行剥边再按单字符切"完全不同形状。
2. **裸键给空值**：`onlykey` ⇒ 键 `onlykey` 值空串（`Q.21`/`Q.22`），正是 §5 第 1 行记的那一侧：
   INI 面丢弃、Properties 面收空值，两批各钉一侧。
3. **注释符是 `#` 与 `!` 两个**（`comment_bang` ⇒ 该行不进数据），且**注释行尾的 `\` 会把下一行整行吞掉**
   （`cont_comment_swallow`：`#c\` 之后的 `a=1` 这条**不存在**，只剩 `b=2`）。
4. **续行规则**：行尾 `\` 拼下一行并**吃掉下一行前导空白**（`Q.29` `k=v\` + ` w` ⇒ 值 `vw`；
   `cont_backslash` 三段拼接）；文件尾孤立 `\` 不报错（`cont_trailing_eof`）；
   被续行合并出的行首 `=` 仍正确切分（`Q.28` `c\` + `=d` ⇒ 键 `c` 值 `d`）。
5. **转义表**：`\t`/`\n`/`\r`/`\f` 各还原成真控制字符（`esc_tab` 等 ⇒ 值里是真 Tab/LF/CR/FF）、
   `\\` 出一个 `\`（`esc_backslash` ⇒ `a\b`）、**被转义的分隔符归进键名**
   （`Q.9` `k\:v` ⇒ 键 `k:v`、值空串——转义掉的 `:` 不再充当分隔符）、键里空格要 `\ ` 才保住
   （`Q.10` ⇒ 键 `k v`）、未知转义**丢掉反斜杠**（`Q.16` `\q` ⇒ `q`）。
6. **`\uXXXX` 真解码，畸形输入抛异常**：`\u0041` ⇒ `A`（`Q.17`）、键位也解（`unicode_esc_key` ⇒ 键 `A`），
   而 `\u00zz` ⇒ **`IllegalArgumentException: Malformed \uxxxx encoding.`**（`Q.18`；
   这一轮 4 条 `ERR` 读数全在这一族）⇒ 第二批必须决定这一档映射成 `raise` 还是丢行，
   **这是本格第一个可能的 raise 面**。
7. **NBSP / 全角空格不当空白**：`nbsp_value`、`ideo_value` 的值里 `\u00a0`/`\u3000` **原样保留**——
   与第一批（§3-1 的 34 位表会把它们剥掉）**逐字符相反**，两批不能共用同一个 trim。
8. **`Properties` 是 `Hashtable`，顺序不可用**：腿的 `STORE` 输出顺序跨运行不稳定 ⇒ 第二批的键序只能是**本库自定**
   （候选是"首次出现顺序"，并在 §5 记明参照无序这一侧）；内容用排序后的 `PAIR` 集对账，
   顺序另用"逐行喂入求得的 `ORDER` 序列"作旁证。
9. **`store` 头部是注释行 + 时间戳**：`store(w, "CMT")` 先写 `#CMT` 再写 `#<日期>`，
   `store(w, null)` 只写 `#<日期>` —— 时间戳属宿主状态，**按 §5 的"宿主状态不进契约"判据不进公开面**
   （第二批的 `props_store` 只出条目行）。
10. **`store` 的转义表与 `load` 不对称**：键里的空格写成 `\ `、`\t`/`\n`/`\r`/`\f`/`\\` 都转义，
    而**值里的空格不转义**（`Q.*` 的 `STORE` 行逐条可查）⇒ 往返不是恒等，第二批要配"先 store 再 parse"的往返夹具。

**下一轮 PR-A 先拍三件**：① 畸形 `\u` 那档怎么映射（`raise` 还是丢行）；② 键序规则挑哪一条并声明参照无序；
③ `store` 要不要注释参数（参照有两个重载，时间戳一律不收）。签名从 `#22.26` 起续号。

## 9. 第二批（`Props` 严格语义）契约冻结（10-06 PR-A）

签名从 `#22.26` 起，公开面 15 件：`PropsError`（唯一变体 `BadUnicodeEscape`）+ `Props` + 13 个函数
（`props_new`/`props_parse`/`props_get`/`props_get_or`/`props_set`/`props_remove`/`props_has_key`/
`props_size`/`props_is_empty`/`props_keys`/`props_values`/`props_entries`/`props_store`）。
**本格第一个 raise 面就在 `props_parse`**（畸形 `\u`）。

### 9.1 已定死的三件（§8 末列的待拍项）

1. **畸形 `\u` 映射成 `raise PropsError::BadUnicodeEscape`**——参照抛 `IllegalArgumentException`
   （腿 4 条 `ERR` 读数：`bad_u_short`/`bad_u_hex`/`bad_u_in_key`/`bad_u_after_ok`，文案全是
   `Malformed \uxxxx encoding.`）。不复制文案、不带位置（参照自己也没给位置）；`bad_u_after_ok` 说明
   **一行里先解出合法 `\u0041` 再撞畸形 ⇒ 整条 load 失败**，本库同判（不留半表）。
2. **键序自定为"首次出现位置"**（后写覆盖值不改位置）：参照是 `Hashtable` 无序，
   内容对账用排序后的 `PAIR` 集，顺序另用腿的 `ORDER`（逐行喂入求得的**新键出现序**）作旁证 ⇒
   顺序这一维是本库形状，spec 上声明清楚，不冒充参照。
3. **`props_store` 不收注释参数、不出时间戳行**：参照 `store(w, null)` 也要写 `#<日期>`（宿主状态，
   §5 的"宿主状态不进契约"直接排除）；腿的 STORE 读数按"切掉首行 + 整串切 `\r\n` 拼 `\n`"变换后作期望。

### 9.2 语义行（每条挂 `props2` 腿读数标签；标签形如 `p.<夹具>.<档>` / `o.<脚本>.<步>.<档>`）

| # | 判据 | 读数 |
|---|---|---|
| 1 | 分隔符三档：`=`/`:`/空白，且**分隔符前空白被吃掉**、分隔符后**只有第一个空格**被吸收（Tab 不吸） | `p.sep_space_multi`（`a   b   c` ⇒ 键 `a` 值 `b   c`）、`p.ws_before_sep`、`p.ws_after_sep_one`（`a=\ b` ⇒ 值 ` b`，空格是转义保住的）、`p.sep_colon_then_space` |
| 2 | 裸键给空串值 | `p.bare_then_sep`、`Q.21`/`Q.22` |
| 3 | 注释符 `#` 与 `!`，且**注释行的行尾 `\` 会吞掉下一行** | `p.comment_bang_cont`、`p.comment_hash_cont`（`a=1` 不在表里） |
| 4 | 行尾 `\` 续行；续行吃掉下一行前导空白；EOF 孤立 `\` 不报错 | `p.cont_backslash`、`p.cont_lf_only`、`p.cont_trailing_eof`、`p.cont_crlf`、`p.trailing_cont_crlf` |
| 5 | `\t`/`\n`/`\r`/`\f`/`\\` 各还原成真字符；**被转义的分隔符归进键名**（不再充当分隔符）；未知转义丢掉反斜杠 | `p.key_escaped_tab`（键 `a<TAB>b`）、`p.key_escaped_eq`、`p.key_escaped_colon`、`p.value_escaped_ff`、`p.value_double_bs`、`Q.16`（`\q` ⇒ `q`） |
| 6 | `\uXXXX` 真解码，键位也解 | `p.value_unicode_esc`（值 `\u4e2d`）、`p.key_unicode_esc`（键 `Ab`）、`p.value_nul_esc`（值是真 NUL） |
| 7 | BMP 外码位逐 UTF-16 码元往返 | `p.value_astral`（值 `\ud83d\ude00b`）、`p.o3` 的 `uni` 值 |
| 8 | 空白表与第一批的 34 位表**不同**：`00a0`/`3000` 在这里不当事务空白 | `p.value_ideo_raw`（值两侧全角空格原样留）、`Q.*` 的 `nbsp` 档 |
| 9 | 键/值都允许空串；重复键后写覆盖值（顺序见 9.1 第 2 条） | `p.empty_key_colon`、`p.only_separators`、`p.dup_order` |
| 10 | 行分隔符是 `\n`/`\r`/`\r\n` 三种，`U+2028`/`U+0085` 不算 | `p.crlf_input`、`p.lone_cr`、`p.cr_only_values` |
| 11 | `set` 返回旧值、`remove` 返回被删值、`getProperty` 两档；**参照存不了 null 值**（`put(k,null)` ⇒ `NullPointerException`） | `o.O1.1`–`o.O1.10`、`o.O2.1`–`o.O2.7`、`ERR` 行 `o.O2.3` ⇒ 本库值类型收成非空 `String`，该档在类型层排除 |
| 12 | `store` 的转义表：键侧空格逐格写 `\ `，值侧只有**首个**空格写 `\ `；`\t`→`\t`、`\`→`\\`、非 Latin-1 与 BMP 外逐码元写 `\uXXXX`；条目行是 `键=值`（**没有空格**，与第一批的 `key = value` 相反） | `o.O3.6.dump`、`p.value_space`、`p.key_escaped_space`、`p.value_escaped_tab`、`p.value_astral` |

### 9.3 本轮状态（诚实标注）

**本轮只交腿读数与契约草案，代码骨架与冻结期望值尚未进仓**（`#22.26`–`#22.40` 的签名与测试在 Temp 起草，
两次尝试都没过编译器：① **关键字是 `raise` 不是 `raises`**（`pub fn csv_parse(text : String) -> CsvData raise CsvError`，`csv/csv.mbt:121` 现读）——我先按 `-> Props raises PropsError` 写，本版判 `Parse error, unexpected token id (lowercase start), you may expect \`\{\`；下一轮把骨架里 15 处注解改成 `raise` 即可续上。原写作
"Parse error, unexpected token id"；
   （排查线索：`grep -rn "raises" csv/csv.mbt cron/cron.mbt` 零命中，而 `grep -rn "raise " csv/csv.mbt` 命中 121/130 两行。）② 生成器在"顺序旁证"一维上有夹具级 bug
（`ORDER` 里的键在排序 `PAIR` 集取不到值），要改成缺值就跳过该条顺序断言）。
所以 §9.1/§9.2 的三条已定与十二条判据**只有 spec 与腿读数作依据**，不能当已冻结的契约引用；
所以 §9.1/§9.2 的三条已定与十二条判据，依据是 spec 与腿读数；第二批的签名骨架与冻结期望值此刻已在仓内
（见文末 10-06 更正），ROADMAP 第 22 行的状态词按当场读数走——本包仍有设计态红，别把 §9 当已落地实现引用。

> **10-06 更正（覆盖 §9.3 的"未进仓"标注）**：第二批的签名骨架与冻结期望值**已进仓**——
> `ini/ini.mbt` 补 `#22.26`–`#22.40`（15 件，含 `PropsError::BadUnicodeEscape`），新增 `ini/props_test.mbt`
> 7 块 205 条断言，读数由 JDK 腿 `props2_results.tsv`（179 行：36 夹具 + 22 步写侧）灌入。
> 两处卡点都已解：错误注解的关键字是 **`raise`**（`csv/csv.mbt:121` 现读），以及生成器的顺序旁证改为
> "取不到值就跳过并就地标注"（本轮跳过 2 条：`cont_*` 与 `cr_only_values` 族——逐行喂入得到的新键序
> 与整串 load 的键集不等，这条判据本身要留 PR-B 重定，别当已冻结）。
> 另两条 PR-A 现场学到的：**测试块名里不许出现反斜杠**（`moon test` 生成的驱动把它当字符串字面量解析，
> `Invalid escape sequence: \u`）；同一测试包内两个 `_test.mbt` 的 helper **共享顶层命名空间**，
> `esc`/`joinx` 这类同名 helper 必须加前缀（本轮 props 侧统一改 `pesc`/`pjoin`）。
> 本轮 `moon test ./ini` 是设计态红（第一批 14 块绿、第二批 7 块红），基线棘轮 446 → 453。
