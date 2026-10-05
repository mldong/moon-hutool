# 契约 14 · dfa（关键词树与停顿字符·第一批）

对应 hutool **`hutool-dfa`** 模块（`WordTree` 334 行 + `StopChar` 51 行 + `SensitiveUtil` 249 行）。
进度状态看 [`docs/ROADMAP.md`](../ROADMAP.md) 第 14 行；本文件的序号 14 就是那一行的行号（门禁 G13）。

## 0. 四条贯穿性规则

1. **不做全局单例**。参照实现另有一张静态表 `SensitiveUtil`：`init(Collection, boolean)` 把词表装进进程全局，
   `containsSensitive(String)`/`getFoundFirstSensitive(String)` 读它，还有 `containsSensitive(Object)`
   靠反射取字段。本库一律**树是值、显式传进函数**，与 `conv`/`re` 的"没有全局可变注册表"同一条立场；
   反射那一半结构上做不到（无运行时反射），已在"不做"清单。
2. **位置口径 = UTF-16 码元下标**，与参照腿（Java `char` 下标）逐条同读，也与 `re` 包同一条
   （`re` 的位置来自 core 的 `StringView`，本来就是码元）。同一个库不许有两家 `start/end` 语义，
   所以本包**不**改成码点下标——含 emoji 的两条夹具就是这条口径的证据（§5 第 2 行）。
3. **只有三档语义，不是四档**。`(density, greed)` 里 `greed` **只在 `density=true` 时有效**：
   参照实现的 `if (!isDensityMatch) { i = j; break }` 排在贪婪判定之前，非密集档根本走不到那一行。
   javadoc 把贪婪单列成"最长匹配"，那句在实测档不成立 ⇒ **以实现为准**，四档各钉一条（§3.2）。
4. **无 null 出口**。`matchAllWords(null, …)` 参照实现返回 Java `null`，本库返回**空数组**；
   `Option` 只出现在"取第一个"那一族。

## 1. 边界：这一批只交"建树 + 查询 + 停顿字符谓词"

| 交 | 不交（挂账与理由） |
|---|---|
| `WordTree`（值语义的关键词树）、`FoundWord`（带位置与两形文本） | `clear()`——重造一棵树就行，不值得为它引入"可变绑定"的调用面 |
| 建树 1 件 + 查询 6 件 + 停顿字符谓词 2 件（共 9 个公开函数、2 个公开类型） | `set_char_filter`——参照实现把过滤谓词做成 `Filter<Character>` 可替换件；本库第一批固定用 `is_stop_char`，等真出现"自定义停顿集"的需求再加，且那时要先定"词表按哪个谓词建、查询按哪个谓词读"的一致性口径 |
| 停顿字符表（`stop_chars.mbt`，**数据件**：只放表、不放逻辑） | `SensitiveUtil` 全套静态面（`init`/`isInited`/`containsSensitive`/`getFoundFirstSensitive`）、`SensitiveProcessor` 接口、`containsSensitive(Object)` 反射档 |
| | 词表文件装载（`init(String path, char sep, …)`）——要 IO，违反零依赖与纯函数定位 |

**方法名的一条硬约束**：`match` 是 MoonBit 保留字，不能作方法名（本机编译器判词法错）。
所以对位 `WordTree#match` 的两件改名 `first_match`（给 `found` 串）与 `first_found`（给 `FoundWord?`），
名字仍逐字对得上参照语义。

## 2. 建树

`new_word_tree(words : Array[String]) -> WordTree`

- 重复词按首次出现去重（参照实现走 `HashSet`，顺序无关；树形与插入序无关，两侧同读）。
- **空串不进树**：参照实现 `addWord("")` 里 `parent` 恒 null ⇒ 不打结束标记 ⇒ 永不命中（实测 `words=["", "ab"]` 对 `"ab"` 只给 `ab@0-1`）。
- **整词都是停顿字符的词不进树**：`words=["、。"]` 对 `"、。ab"` 零命中（实测）。
- 建树没有可失败输入 ⇒ **无 `raise` 面**，与 `valid` 同一条立场。

## 3. 查询

### 3.1 六件的层级

```
is_match(text)                    = first_found(text) is Some(_)
first_match(text)                 = first_found(text)?.found
first_found(text)                 = match_all_words_mode(text, 1, false, false)[0]
match_all(text)                   = match_all_mode(text, -1, false, false) → found 串列表
match_all_words(text)             = match_all_words_mode(text, -1, false, false)
match_all_mode(…)                 = match_all_words_mode(…) 的 .found 投影
```

参照实现的 `match()` 出口是 `FoundWord#toString()`，而 `toString()` 返回 **`foundWord`**（文本里那一串），
不是词表里的 `word`——`["红领巾"]` 对 `"红。、领巾"` 给的是 `红。、领巾`。本库跟随（实测 §4 第 3 条腿的
`word-vs-found` 夹具），并把两形都放进 `FoundWord`，调用方不必自己再算。

### 3.2 `(density, greed)` 的实测四档（全部来自参照腿读数，不是推演）

词表与文本都是参照实现 javadoc 自己用的那两组，读数逐条来自 `dfa_ref.txt`：

| density | greed | 语义 | 夹具 `["ab","b"]` vs `"abab"` | 夹具 `["a","ab","abc"]` vs `"abc"` |
|---|---|---|---|---|
| false | false | **默认档**：最左起点、同起点取最短、命中后整段跳过 | `ab@0-1, ab@2-3` | `a@0-0`（+ 下一段） |
| true | false | 每个起点重扫，同起点仍取最短 | `ab@0-1, b@1-1, ab@2-3, b@3-3` | `a@0-0` |
| false | true | **与默认档逐条同读**（`greed` 惰性，规则 3） | — | `a@0-0` |
| true | true | 每个起点由短到长全出 | `ab@0-1, b@1-1, ab@2-3, b@3-3` | `a@0-0, ab@0-1, abc@0-2` |

`limit` 一档：**只有 `> 0` 生效**。实测 `limit=0`、`limit=-2` 与 `limit=-1` 三条读数完全相同
（参照实现写的是 `if (limit > 0 && size >= limit)`）。本库跟随，不做"`limit=0` 当空结果"那种改写。

### 3.3 停顿字符在匹配里的三条实测档

| 档 | 夹具 | 读数 | 出口形状 |
|---|---|---|---|
| 词中 | `["红领巾"]` vs `"红、领巾 a红。领巾"` | `红领巾@0-3/红、领巾`、`红领巾@6-9/红。领巾` | `word` 剥掉停顿字符、`found` **原样带着**，`start`/`end` 覆盖整段 |
| 词首 | `["红领巾"]` vs `"、红领巾"` | `红领巾@1-3/红领巾` | 词首停顿字符被跳过，起点因此后移（参照实现是 `i++`） |
| 词尾 | `["红领巾"]` vs `"红领巾、"` | `红领巾@0-2/红领巾` | 结束标记在"巾"就成立，后面的停顿字符不参与这一条 |

## 4. 读数腿

| 腿 | 来源 | 条数 | 说明 |
|---|---|---|---|
| A | **`hutool-dfa-5.8.35.jar`（独立 artifact）** + 本机 JDK 17.0.14 跑 `WordTree` | 30 条命中读数（含位置与两形文本）+ 2 条码表规模读数 | 编译带 `javac -encoding UTF-8`（`digest` 轮那条编码教训，本轮开局就带上）；`dfa_ref.txt` 里每条都带 `limit/density/greed` 三个参数，读数不可复算就没人能改 |
| B | 参照实现**源码**（`hutool-dfa-5.8.35-sources.jar`，`WordTree.java` 334 行全文读过） | 3 条机制判定 | 三件事只能由源码给：`greed` 为什么在非密集档惰性（那行 `break` 排在前面）、`match()` 为什么给 `found`（`FoundWord#toString()`）、空词为什么不建节点（`parent == null` 就不 `setEnd`） |
| C | 码表规模与构成 | 3 条 | `StopChar.STOP_WORD` 反射去重后 **303** 个码位；全 BMP 扫 `isStopChar` 为真 **327** 个；两表**差集实测 24 个码位**（`isStopChar` 多出来的正是 `Character.isWhitespace` 那一半）：U+0009–U+000D、U+001C–U+001F、U+1680、U+2000–U+2006、U+2008–U+200A、U+2028、U+2029、U+205F、U+3000。**注意两处"看着该有其实没有"**：U+2007 FIGURE SPACE 与 U+202F NARROW NO-BREAK SPACE 都**不在**表里（Java 的 `isWhitespace` 不收它们，收它们的是另一个谓词 `isSpaceChar`）——按"空白字符"三个字凭常识建表就会多收两位。反向差集为空（`STOP_WORD ⊆ isStopChar 全集`，读数自证） |

**用例只钉规模 + 边界点，不逐位钉表**：钉 327 位等于把表抄第二遍（两份真相）。
判据形状是"扫全 BMP 计数 == 327" + 六条边界谓词（空格/`\t`/`、`/全角空格/U+205F 真，`中`/`a` 假）。
表本体在实现那一笔由生成脚本从腿 C 灌进 `dfa/stop_chars.mbt`。

## 5. 不跟随与分岔（每条带两侧读数）

| # | 项 | 参照实现 | 本库 | 依据 |
|---|---|---|---|---|
| 1 | `match_all_words(null)` | 返回 Java `null` | 空数组 | MoonBit 无 null；把"没有命中"和"没给文本"合成一个出口，比造一个 `Option[Array[…]]` 更好用 |
| 2 | 位置口径 | UTF-16 码元下标 | **同**（不换算） | 规则 2；夹具 `["ab"]` vs `"😀ab"` 两侧都给 `ab@2-3`（emoji 占两个码元） |
| 3 | `add_words` 的容器 | `HashSet`，顺序丢 | 保序去重 | 树形与插入序无关 ⇒ 对同一批词两侧匹配逐条同读；本库不需要一个"顺序无意义"的参数形状 |
| 4 | `SensitiveUtil` 全局表 + `Object` 反射档 | 静态 init / 反射取字段 | **不做** | 规则 1 + 无反射 |
| 5 | `match()` 出口 | `found`（含停顿字符那一串） | 同（`first_match`） | 腿 B：`FoundWord#toString()` 返回 `foundWord`；实测 `word-vs-found` 夹具 |
| 6 | `clear()` | 有 | 第一批不放 | §1 表；重造一棵树即可 |
| 7 | `setCharFilter` | 可换谓词 | 第一批固定 `is_stop_char` | §1 表；一致性口径没定，先不铺 API |

## 6. 相位与不承诺

| 项 | 相位 | 说明 |
|---|---|---|
| 本文件 9 件 + 2 类型 + 停顿字符表 | **已实现**（10-05 两笔：契约 `822b8ef` + 落地） | 10 块全绿（`dfa_test.mbt` 6 + `README.mbt.md` 4），wasm / js / wasm-gc 三档读数一致；期望值一字未改（G5 对照基线取契约那一笔） |
| 变异对照 | **已做六条，逐条有块红** | A 非密集档不跳整段 2 红 / B `word` 与 `found` 写反 3 红 / C 词中停顿字符进 `word` 3 红 / D `limit>0` 写成 `>=0` 2 红 / E 二分上界写成 `length-2` 1 红（只有"表规模"那块抓得到——**边界项只有计数断言守**）/ F 拿掉词首 `i++` 2 红。全部按 sha256 还原到变异前字节 |
| 一条**空变异**的教训 | 记在这儿，别当战果 | 初版第五条变异是"二分把 `<` 写成 `<=`"——**0 红**，因为等值分支 `v == cu` 排在前面，`v <= cu` 与 `v < cu` 在该位置**语义等价**。这不是测试弱，是变异本身不改变行为；换成"上界少一项"才有红。判据：写变异先问"它能不能改变某个可观测读数" |
| 密集档的性能承诺 | **不承诺** | 参照实现最坏 `O(n²)`（两层循环重扫），本库同形状；不做 Aho-Corasick——那是另一个算法族，要另立包与另取读数腿 |
| `SensitiveProcessor`（命中后逐个加工的回调面） | 不做 | 一条 `map` 就是它，再造一个接口是第二个名字 |
