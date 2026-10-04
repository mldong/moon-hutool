# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

You can browse and install extra skills here:
<https://github.com/moonbitlang/skills>

## Project Structure

- MoonBit packages are organized per directory; each directory contains a
  `moon.pkg` file listing its dependencies. Each package has its files and
  blackbox test files (ending in `_test.mbt`) and whitebox test files (ending in
  `_wbtest.mbt`).

- In the toplevel directory, there is a `moon.mod` file listing module
  metadata.

## Coding convention

- MoonBit code is organized in block style, each block is separated by `///|`,
  the order of each block is irrelevant. In some refactorings, you can process
  block by block independently.

- Try to keep deprecated blocks in file called `deprecated.mbt` in each
  directory.

## Tooling

- `moon fmt` is used to format your code properly.

- `moon ide` provides project navigation helpers like `peek-def`, `outline`, and
  `find-references`. See $moonbit-agent-guide for details.

- `moon info` is used to update the generated interface of the package, each
  package has a generated interface file `.mbti`, it is a brief formal
  description of the package. If nothing in `.mbti` changes, this means your
  change does not bring the visible changes to the external package users, it is
  typically a safe refactoring.

- In the last step, run `moon info && moon fmt` to update the interface and
  format the code. Check the diffs of `.mbti` file to see if the changes are
  expected.

- Run `moon test` to check tests pass. MoonBit supports snapshot testing; when
  changes affect outputs, run `moon test --update` to refresh snapshots.

- Prefer `assert_eq` or `assert_true(pattern is Pattern(...))` for results that
  are stable or very unlikely to change. For snapshot tests that record
  structured debugging output, derive `Debug` and use `debug_inspect`, rather
  than deriving `Show` for debugging. For solid, well-defined results (e.g.
  scientific computations), prefer assertion tests. You can use
  `moon coverage analyze > uncovered.log` to see which parts of your code are
  not covered by tests.

## 本仓专属规则（moon-hutool）

### 交付形状：文档契约先行

一个包的交付拆两笔：**PR-A 契约**（`docs/spec/NN-<pkg>.md` + 签名骨架 + `.mbti` + 期望值已冻结的用例，函数体 `abort`）→ **PR-B 实现**（只许把红变绿）。
PR-A 的合入标准：`moon check` 必须全绿（签名与类型自洽、文档块能编），`moon test` **允许红**。
"全绿"这一条在骨架期要靠 `moon.pkg` 里一行 `warnings` 豁免才做得到（体全 `abort` ⇒ 类型/变体没人构造那三类警告必响），
豁免的合法边界由门禁 **G12** 守：体里已无 `abort` 却还压着豁免就报红——绝不为消警告去写假实现。

### 与 core 的边界：只包语义层，不写转发层

- 允许包：① 补 hutool 契约形状（null-safe 分档、`{}` 占位、`sub_between`）；② 环境显式化（`Clock`、`offset_minutes`、base64 严格/宽松双档）；③ 把 core 分散零件收成可测出口（`\d\w\s` 语法翻译层、`Map` 插入序上的 LRU、`diff` 外的归一化相似度）。
- **禁止**：给 core 已有函数换名转发同一语义（`@coll.map` 套 `Array::map` 一律拒）。要迁移手感请看 `docs/spec/00-hutool-map.md` 的四列对照表，代码不承担。
- 凡"包 core"的格子，用例里必须带一条**与 core 原函数同输入同输出**的对拍断言（门禁 G8）：core 升级改了语义，这条先红，由我们主动决定跟不跟。
- **不许包出 core 给不了的承诺**：例如把 `to_upper` 包成 `to_upper_case` 却只在 ASCII 生效。要么真做（数据表，二期），要么函数名与文档都写 ASCII 档。

### 两条红线

1. **期望值冻结**：PR-B 不许改 `*_test.mbt` 里的期望串与 spec 表的"读数来源"列。要改必须单独一笔，正文写清外部证据（hutool 实测输出 / RFC 向量 / FIPS 示例 / 评审记录）。多个并行会话会各自发明同一条错语义并改期望值自证绿——这条就是拦这个的。
2. **不搬运表达**：实现里不许出现从 Java 翻译来的注释、成段结构或变量名对应表。移植的是语义与规范（思想侧），不是 hutool 的代码写法（表达侧）；hutool 源码只用来**反推期望值**。少数 hutool 自身也是移植件的格子（`CharSequenceUtil`、`date/format/*`、`ComparatorChain`、`AntPathMatcher`）真上游是 Apache Commons / Spring，spec 的"血统"列必须标注。

### 零依赖四条（违反任何一条直接红）

只用 `moonbitlang/core`（`moonbitlang/async` 也算第三方）· 零 `extern` · 全同步 · OS 能力只走 `env.now`/`env.rand` 且必须可注入。

### 语法坑（本机 moon 0.1.20260920 / moonc v0.10.14 实测，别再撞）

- `priv` **只对类型合法**（`priv struct`），写在 `fn` 上判 `No 'private' visibility for function`；类型不加 `priv` 又不在公开签名里出现，会吃 `missing_priv` 警告。
- `.mbt` 里写 `import` 非法：`Invalid import declaration here. Move this declaration to moon.pkg`；测试专用依赖写在包的 `moon.pkg` 里 `} for "test"`。
- `String` 字面量**不隐式转** `StringView`，且 `String` **没有** `as_view` ⇒ 对外 API 用 `String`。
- `\u{...}` 只在 char 字面量合法，写进字符串会成插值 ⇒ `Lexing error: missing expression in string interpolation`。
- `Array<StringView?>` 这种尖括号内的可选类型解析失败 ⇒ 用 `Array[Option[String]]`。
- 骨架函数体里 `let _ = (a, b)` 是消 `unused_value` 警告的必要动作（零警告是门禁），实现落地后随函数体消失。
  但**方法**的参数标注不能顺手写进 `let _ = (...)`：`(self : Self, days)` 是非法语法（`Parse error, unexpected token :`）。
- **方法上的 `self` 必须显式标注** `self : Self`：骨架体里不用 self 时编译器推不出类型（`Missing type annotation for the parameter self`）。
- **`pub struct` 跨包只读、不可构造**（判 `Cannot create values of the read-only type`），这正好当"构造闸门"；
  但 **`pub enum` 的变体也因此构造不出来** ⇒ 要交给调用方当参数的枚举必须 `pub(all) enum`（本库 `TimeUnit` 就是这么改的）。
- **`derive(Show)` 已废弃**（用 `derive(@debug.Debug)` 或手写 `impl Show`）；`derive(Eq, Compare)` 可用，
  但本版会把实现的方法**隐式提升成同名方法**并报 `implicit_impl_as_method` 警告 ⇒ 必须补显式 `extend`
  （形状抄 `moonbitlang/core/argparse/extends.mbt`，单独放 `extends.mbt`）。`suberror` 变体只收**位置参数**
  （`DayOutOfRange(Int, Int, Int)` 合法，`DayOutOfRange(month : Int, …)` 判词法错）；`raise` 不要求额外 `impl Error`。
- **带效果标注的函数参数类型要写成 `()` 而不是 `Unit`**：`f : () -> A raise E` 合法，
  `f : Unit -> A raise E` 会被读成"参数是 Unit"（`has type: function type, wanted: Unit`）。
  泛型参数要紧跟 `fn` 关键字（写作 `fn[A] shape(...)`）；把 `[A]` 放在函数名后面判词法错
  （编译器原文：Parse error, unexpected fn f[T], you may expect fn[T] f）。文档块里的带标注闭包同形：
  `let show : (String) -> String = (s) => { ... }`（`let show = (s : String) -> String { ... }` 判 `s is unbound`）。
- **native 档的测试驱动不兜 `panic`/`abort`**：一个红用例（骨架期函数体就是 `abort`）会把整个测试
  可执行文件打到 `SIGABRT (core dumped)`，**拿不到 `Total tests:` 汇总**（CI 实测：wasm/js/wasm-gc 三档
  都是 84 条正常报数，native 档 collected=0）。所以"某档一条红都没报出来"不等于"那档没套件"——
  先分清是编不过、被 abort 打死、还是真丢了用例。CI 对该档的例外判据三条同时成立才生效，见
  `.github/workflows/ci.yml`。
- **`moon.pkg` 的 `warnings` 键只能出现一次、值只能是字符串**，多个 flag 要**连写不加空格/逗号**：
  `warnings = "-struct_never_constructed-unused_constructor-unused_error_type"`（写成空格或逗号分隔会被 moonc 打回Usage）。
- **骨架期的三类警告只能就地豁免，且有棘轮**：契约骨架（体全 `abort`）必然触发
  `struct_never_constructed` / `unused_constructor` / `unused_error_type`——它们是"未实现"的机械后果，
  为消警告去写假实现才是本末倒置。豁免只允许出现在**体里还有 `abort`** 的包（门禁 **G12**，带阳性对照），
  实现落地那一笔必须删掉 `warnings` 行。
- **`Bytes::from_array([...].exact_view())` 这种链式写法会挡住元素类型推断**：判
  `has type: Array[Int], wanted: Array[Byte]`，而 `Bytes::from_array` 的参数本来就是 `ArrayView[Byte]`
  ⇒ 直接写 `Bytes::from_array([...])`。同理，外层 `let x : Bytes = ...` 的标注**不会**倒推进数组字面量。
  测试里要放字节夹具就用 `fn bts(xs : Array[Byte]) -> Bytes`（参数标注让字面量在 Array[Byte] 上下文里定型）。
- **字符出口走 `StringBuilder`，`@buffer.Buffer` 只装字节**：本版 `@buffer.Buffer` 的 `write_char` 报废弃，
  且它在 wasm/js 档内部是 UTF-16——按 `write_char_utf8` 落 UTF-8 字节再 `to_string()`，会把两字节当一个
  UTF-16 单元读，ASCII 十六进制串变成一串生僻字（`"00000000"` → `"〰〰〰〰"`，长度直接减半）。
  症状是断言里看到"看着像编码坏了"的期望值，其实错在实现侧；字节流才用 `Buffer` + `to_bytes`（`digest` 那条腿的形状）。
- **wasm 档 `Int` 是 32 位**：`(0xff.to_int() << 24)` 先溢出成 `-1`，再 `.to_int64()` 是符号扩展 ⇒ 拼无符号
  大端字必须**先升到 Int64 再移位**（`id.object_id_timestamp("ffffffff…")` 该读出 `4294967295`，读成 `-1` 就是这个坑）。
  换档读数不同，本机 wasm 三档都能跑出来，别留给 CI 发现。
- `fn` 的返回类型加 `raise E` 时**整行不许被 fmt 拆断**（`-> Unit\n  raise E {` 判 `Unexpected line break here, missing {`）：
  参数多的话把参数列表写成多行，`-> T raise E {` 留在同一行。
- **`0u` / `1u64` 这类 UInt 字面量后缀本版不合法**（判 `Parse error, unexpected token id (lowercase start)`）
  ⇒ 需要 UInt64 的零/边界就写带标注的 `let zero : UInt64 = 0`，大常数直接写十进制裸值靠标注定型。
  配套：`Int64::to_uint64()` 已废弃 ⇒ 用 `reinterpret_as_uint64()`，`UInt64 → Int64` 用 `reinterpret_as_int64()`；
  **`Char` 没有 `to_lowercase`/`to_uppercase`** ⇒ ASCII 档自己按码位加 32（Base32 那种"大小写都收"的反查表就这么做）。
- **一次性工装（字符串替换）改完必须逐处核对**：本轮用 `s.replace(old_multi, ...)` 还原一个多行字节夹具，
  `old_multi` 是从**第一处** `Bytes::from_array([` 切出来的，于是把另一个夹具（3 个 `0xff`）整个换成了 20 字节，
  `moon check` 与 PR-A 的全红都照样通过，直到 PR-B 跑断言才暴露。⇒ 工装改过的文件要 `git diff` 逐块看，
  夹具类改动尤其要单独确认，别信"它编过了"。
- **`Map::keys()` 返回 `Iter[K]`，不是 `Array[K]`**：`Iter` 没有 `Eq` 实例，所以 `assert_eq(m.keys(), [1, 2])`
  判 `Type Iter[Int] does not implement trait Eq`；同时 `[ .. ]` 会被当成**已废弃的 Iter 字面量**吃
  `deprecated_syntax` 警告（新版写 `[| .. |]`）。⇒ 断言键序统一写 `.keys().to_array()`，
  看到 `Iter` 相关这两条报错就是这个漏了。
- **骨架期的泛型界会吃 `unused_trait_bound` 警告**：`fn[A, K : Hash + Eq]` 这类界在体里全是 `abort` 时
  编译器看不到用处 ⇒ 骨架豁免串要带上它（`warnings = "-unused_constructor-unused_error_type-unused_trait_bound"`），
  实现落地那一笔整行删（G12）。
- 划"core 有什么"的边界时，两条**看着像没有其实有**的件要特别核：`Array::search_by(f) -> Int?`（还有
  `find_index` 别名，所以别再造返 `-1` 的 `index_where`）、`Array::dedup(self) -> Unit`（原地、只去**相邻**重复，
  文档自己写"要全去重请先排序"，所以它和保序全去重的 `distinct` 是两档，不能当一件）。
- **`Map::update_or_default(key, default, f)` 在键缺席时直接存 `default`、不套 `f`**（core 注释自己点了它
  mirrors Rust `and_modify(f).or_insert(default)`，而 **Java `Map.merge` 是反的**）⇒ 计数写
  `update_or_default(x, 1, v => v + 1)`，给 0 会让**每个计数静默少 1**（本轮实现期唯一一处红就是这个）。
  配套的 `Map::get_or_init(key, () => v) -> v` 返回**存进去的那个值**，所以分组可以直接
  `m.get_or_init(k, () => []).push(x)`（Array 是引用语义，push 生效）。
- **`Int` 后面直接点方法会被切成字面量的一部分**：`out.push(32.to_byte())` 里的 `32.` 先按 Double 词法吃掉点号，
  判 `has type : Double` ⇒ 写 `(32).to_byte()`。
- **`Int::to_char()` 返回 `Char?`**（非法码位 None）：只在码位区间已被调用方保证时 `.unwrap()`，
  并且把"为什么不可达"写在注释里；编一个替换字符是更坏的选择。
- **`String::split(sep)` 返回 `Iter[StringView]`，不是 `Array[String]`**：要下标就先 `.to_array()`，
  视图转拥有串用 `.to_owned()`（`StringView::to_string()` 已废弃，判词直接指到 `Show::to_string`）。
- **`String::starts_with` 已废弃** ⇒ `has_prefix`（本轮两处调用点都是字符串前缀判断，判词直接点名 `has_prefix`）。
- **布尔/算子表达式续行只能把运算符留在行尾**：行首再写 `||` 判 `Parse error, unexpected token ||`，
  且上一条语句还会被当成"表达式值未显式忽略"（`Bool cannot be implicitly ignored`）——两条错一起报很迷惑。
- `Array` **没有 `iteri`**（core 给的是 `eachi`/`iter`），带下标循环就直接 `for i in 0..<xs.length()`。
- **`Array::clamped_view` 的 `start`/`end` 是带标签可选参**：按位置传判
  `requires 1 positional arguments, but is given 3` ⇒ 写 `xs.clamped_view(start = s, end = e)`。
  它把越界自然夹空，"越界给空数组"这类契约可以直接交给它，不必自己写边界分支。
- **泛型 `suberror` 在 moonc v0.10.14 不支持**：最小样本 `pub suberror E[K] { Conflict(K) }` 判
  `Parse error, unexpected token '['`（落在声明收尾处）。⇒ 错误面要么不带载荷，要么带固定类型；
  别为"错误里夹一个泛型读数"设计整套 `MapError[K]`。
- **泛型结构体的方法必须写全 `Self` 的参数**：`pub fn[K, V] BiMap::get(self : Self, ...)` 判
  `The type constructor Self expects 2 argument(s), but is here given 0` ⇒ 写 `self : BiMap[K, V]`。
- **未使用的类型参数是 4027 错误，不是警告**——`warnings` 豁免串压不住它。⇒ 骨架期（体全是 `abort`）的
  泛型方法必须**碰一下字段**把参数用起来：`let _ = self.forward`。而 `struct_never_constructed`
  只是警告，可以进豁免串。两类错误的分界要写进 `moon.pkg` 注释。
- `Map` 的字面量构造写 **`Map([("a", 1), ("b", 2)])`**。别去点 `Map.of([...])`：一来 `src.of` 判
  `has no method of`，二来按函数形式调判 `Function with labelled arguments can only be applied directly`
  （`of` 那一档是有标签参的构造函数，不能按位置传）。同一份代码里 `Map::new()` 也可用（`new` 无标签参）。
- **空表字面量 `Map([])` 就要键有 `Hash + Eq`**：所以"内部持有两张 `Map`"的容器（如 `BiMap`）
  连 `new` 都必须带 `K : Hash + Eq, V : Hash + Eq`（反向那张的键是 V）。**界也是契约**——
  契约期写松了，实现期就被编译器逼着收紧并动 `.mbti`；写界时说清"这个方法的哪一步用到它的可散列性"。
- 用例首选 `assert_eq`；`inspect` 对集合走 `Show` 会吃废弃警告（core 立场：结果确定的用例用断言）。
- `moon.mod` 是 TOML：注释用 `#`，`//` 会解析失败；`moon fmt` 会把 `[]` 写成 `[ ]`，改字段前先跑 fmt。

### 工具链

`moon check` / `moon test` / `moon fmt --check` / `moon info`（`.mbti` 必须提交，`moon info` 后 `git diff --quiet -- '*.mbti'` 即接口漂移检查；`moon info` **没有** `--check`，只有 `--dry-run`）/ `moon bundle --all` / `moon coverage`。

### 文档规范：使用说明要能在 mooncakes 上直接查

本库的**文档就是契约的一部分**（不只是门面）。形状照 `moonbitlang/core` 实物抄：core 70 个包里 **64 个带 `README.mbt.md`**，函数文档分节样式取自 `array/array.mbt:15-35`。

每个已交付包必须有三层文档，**分工不重复**：

| 层 | 放什么 | 会被执行吗 |
|---|---|---|
| `///` 函数文档 | Summary → `Parameters:` 逐条 → `Returns` → 关键 Notes；一条 `示例见 README.mbt.md` 指路 | 块内若写 ` ```mbt check ` + `test {}` 会被编译执行（core 就这么用），本库**不在 `///` 里放示例**，避免同一期望值两处双写漂移 |
| `<pkg>/README.mbt.md` | 包级说明 + **典型用法**，每段 ```mbt check 里一个 `test { assert… }` | ✅ 真编译真执行：`text/README.mbt.md` 落地后 `moon test` 从 20 条涨到 37 条（多出 17 条全是文档块） |
| `docs/spec/NN-<pkg>.md` | 七列台账：签名｜语义｜边界/错误｜hutool 对位｜差异声明｜读数来源｜血统；**边界与负向矩阵**在这里（`<pkg>_test.mbt` 承接可执行部分） | 人读 + 门禁 G6 查规范引用 |

机制细节（本机实测，别猜）：

- 代码块标记写 ` ```mbt check ` —— core 的 `encoding/base64/README.mbt.md` 就是这个标记，20 个块全部被 `moon test` 收进用例。
- 包文档里**引用自己包用自包别名** `@text.is_blank(...)`，**不要写 `import`**（`.mbt` 里写 import 非法，文档块同样不吃）。
- 判文档是否真被验，看 `moon test` 的 `Total tests` 涨没涨，不看文件存不存在；只 `moon check` 会误判（文档测试属 test 档）。
- 本地预览：`moon doc --serve`（默认 `127.0.0.1:3000`），或 `moon doc <符号名>` 查单个符号的文档。
- 发布页渲染的是**模块目录里那份** README（发布包根＝模块目录）；跨目录链接一律写 GitHub 绝对地址，相对路径在 mooncakes 页面是死链。
- 期望值此刻红是设计态（函数体 `abort`）。文档块里的期望串与 `<pkg>_test.mbt` 同受"期望值冻结"约束：实现期只许把红变绿。

### 引用红线：公开仓只许引用仓内文件

本仓是 **PUBLIC**。决策过程、跨栈计划、任务分派、许可证取舍的来龙去脉都留在协调侧，**不进本仓、也不在本仓的文档里被引用**（引用一个外人打不开的链接，等于把文档写成半句话）。
落法：公开文档只引用仓内路径（`docs/spec/…`、`docs/ROADMAP.md`、`AGENTS.md`）；需要交代"为什么这么定"时，把结论与判据直接写进 spec 的"差异声明/读数来源"两列，不写"见某某方案 §4.5"。门禁 **G9** 扫跟踪文件里的内部叙事词并带阳性对照，命中即红。

### 批量改文档的坑：正则边界要吃掉 `-` 和路径字符

给包文档批量加自包别名时用了 `s/\btext\./@text./g` 一类写法，结果把行内代码与链接里的文件名 `docs/spec/01-text.md` 一起改成 `01-@text.md`——**当场造出一条死链，而且标和 URL 一起坏，肉眼扫不出来**。这类改动的边界必须显式排除 `/`、`-` 与反引号上下文，改完跑 `python scripts/check_doc_links.py`（门禁 G10）验一遍；G10 自带阳性对照（喂两条假死链，要求都抓到），所以它不会悄悄失效。

### 状态数字不手写（G11 的立身理由）

包一多，"记得改文档"这件事一定会失败——本轮 `text` 转绿后有三处文档还写着"实现未开工"，是 owner 逐条点出来的。所以状态改成**生成物 + 漂移检查**，与 `moon info` 管 `.mbti` 同一招：

- `README.md` 与 `docs/ROADMAP.md` 里的 `READINGS:BEGIN/END` 块**由脚本生成**：`python scripts/sync_status.py --write`。手改这些数字，`--check` 当场报红。
- `docs/ROADMAP.md` 的逐包表是进度的唯一真相，两条硬约束：**每个真实存在的包必须有一行**（新包没登记 → 红）；**每行状态词必须等于当场 `moon test --package` 的读数**（绿了写"未开工"、没绿写"已实现" → 红）。
- 包内三处措辞（`<pkg>/README.mbt.md`、`<pkg>_test.mbt` 头、`docs/spec/NN-<pkg>.md` 头）不许与读数矛盾；包转绿后仍写"预期红"就是红。
- **根 `README.md` 的索引行不许逐包写状态**：括号里点了包名又点了状态词的，必须等于当场读数（不指名包的状态口径词表放行）。
  这条是本轮补的——`date`/`id` 转绿时文档索引那行还写着"契约已冻结"，而原判据只扫**包内**文档，根 README 不在面上；
  补完拿旧版 README 复跑过（报 2 条）与新版（0 条）正反对照。状态只有两处真相：生成的读数块 + ROADMAP 逐包表。
- 挂点：CI 的门禁 G11 与本地 `.githooks/pre-push`（`pre-commit` 只跑 `moon check`，逐包跑用例太慢不放提交档）。
- 新增包时的正确顺序：建目录 → **先在 ROADMAP 加一行**（状态"未开工"）→ 再写契约。反过来会被 G11 拦。

### 摘要类实现的四条本机裁决（写实现前先看，别靠常识猜）

- **没有 `0x..u` / `0x..u64` 这种十六进制后缀**（判词法错）⇒ 字面量写裸值靠返回类型推断；
  但 `let mut a0 = 0x67452301` 会**推断成 Int**，与后面 UInt 混算全线 mismatch ⇒ IV 那批必须显式 `: UInt`。
- `Array::create` / `Array::of_length` 在本版**不存在** ⇒ 定长累加用 `let w : Array[UInt] = []` + `w.push(...)`
  （Array 是引用语义，别写 `let mut`，否则吃 `unused_mut` 警告卡零警告门禁）。
- 位运算用中缀 `& | ^ << >>`；`lsl/lsr/land/lor/lxor` 那批方法已报废弃。取反**没有 `~`**，写 `x ^ 0xffffffff`。
  `Int::to_uint` / `UInt::to_int` 也已废弃 ⇒ 用 `reinterpret_as_uint` / `reinterpret_as_int`。
  `String::to_bytes` 废弃 ⇒ 字符串转字节走 `@encoding/utf8.encode`。
- **长度域的字节序必须跟该算法取字的字节序一致**：MD5 是小端字 ⇒ 8 字节比特长度要按小端摆，
  SHA-256 才用网络字节序。统一按大端写的症状很阴——空串（长度 0）与全部 SHA 向量都对，
  只有"非空串的 MD5"才错，本轮就是这么撞的（镜像到 Python 逐向量比对才定位）。
