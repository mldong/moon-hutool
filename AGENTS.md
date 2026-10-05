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
- **`Option::is_none()` 已废弃** ⇒ 写 `x is None`（判词直接给这句）。同族：`Option::map`/`unwrap_or` 仍可用。
- **`Map::remove` 不返回旧值**（`Set::add`/`Set::remove`/`Map::clear` 都返回 `Unit`）⇒ "删掉并拿到被删的值"
  必须先 `get` 再 `remove`，两步之间不能假设有原子性（本库全单线程同步所以成立，但**写法上必须显式**，
  否则以后有人加并发封装时这里就是暗坑）。
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


### num 轮（10-05）编译器语法五条 + core 数值语义六条实测

语法侧（本轮编译器逐条裁决，别再靠猜）：

- **带默认值的实参必须是标注参数**，写法 `mode~ : T = V`。`mode : T~ = V` 判词法错
  （`unrecognized character "~"`），`mode : T = V` 判 `Only labelled arguments can have default value`；
  `.mbti` 里这一档显示成 `mode? : T`。
- **字符串插值要转义**：`"值 \{x}"` 才插值，裸 `{x}` 原样输出（`println("plain {s}")` 打出 `plain {s}`）。
- **`expr catch { pat => arm }` 的各分支必须与 `expr` 同型**：`Int` 返回的调用配 `String` 分支判
  `has type String, wanted Int`。要断"错误形状"就写 `try { let _ = f(); "未抛错" } catch { … }`
  （`coll`/`date` 的 `err_shape` 本来就是这型，别自创糖）。
- **指数面浮点字面量必须带小数点**：`5e-324` 判词法错，`1.0e-7`、`1.0e21` 通过；
  且 **`Int` 字面量按当前目标位宽校验**——`4611686018427387904` 在 wasm 档直接判 out of range，
  大整数夹具一律走 `BigInt::from_string`。
- 数字字面量点方法要加括号（`(1500000000).next_power_of_two()`，同上一轮 `32.to_byte()` 那条）。

core 数值语义侧（全部当场实测，三档 `wasm`/`js`/`wasm-gc` 读数一致；native 由 CI 出证）：

- **越界是静默回绕，不是 abort**：`(2147483647).mul(2)` 给 `-2`、`(-2147483647 - 1).abs()` 给
  `-2147483648`、`BigInt::from_string("2147483648").to_int()` 给 `-2147483648`、20 位的
  `99999999999999999999.to_int()` 给 `1661992959`（就是 `mod 2^32` 的补码读法）、
  `Int64(2^40).to_int()` 给 `0`。⇒ 本库的增长型算术只在 `BigInt` 域，断言里**一次 `.to_int()` 都不做**，
  全比 `.to_string()`。
- `Int::next_power_of_two` 的**源码把 32 位写死**（`let max_power_of_two = 1073741824` 与
  `2147483647 >> ((self - 1).clz() - 1)`）⇒ 在 64 位 `Int` 的 native 档这条语义可疑，本库不依赖也不包装。
- `Double::round()` 是 `floor(x + 0.5)`：`(-0.5)→0`、`(-3.5)→-3`（**向数轴正向**），
  与 `java.math.RoundingMode.HALF_UP`（向绝对值增大）在负半边分岔 ⇒ `num` 的件不叫 `round` 叫 `round_to`，
  并把这处分岔钉成用例。
- `Double::to_string` 形如 ECMAScript `Number::toString`（`1e+21`、`123456789012345680`、`-0.0` 打 `0`），
  三档逐值一致；位数超 21 走指数记法。**"最短十进制"这条在四档上是同一个数**，所以十进制舍入可以跨档冻结。
- `@string.parse_*` 的口径（格式化那批要用）：`parse_int` **拒绝**首尾空白、接受 `_` 分隔与 `0x` 前缀、
  超范围报错；`parse_double` 接受 `nan`/`inf`/`Infinity`/`.5`/`1.`/`+1.5`、拒绝空白与 `1,0`；
  `"1e309"` **报错**（不给 Infinity）、`"1e-324"` 给 `0`（下溢不报）。
- `@math.pi` 已废弃 ⇒ 用 `@math.PI`（本库不装常数，只在文档记一条）。

镜像侧一条硬教训：**Python 的 `//` 是 floor 除，MoonBit/Java 的整除是向零取整**。
用 Python 复算扩展欧几里得 / 模逆 / 贝祖系数时必须写显式 `trunc_div`，否则负半边整片错——
本轮就是先按 floor 除法跑出一批读数，靠"负数夹具的界断言不过"才发现。


### num 第二批（10-05）四条编译器裁决 + 一条"两个族"的读数裁决

- **方法定义不能写 `pub fn (m : Money) cent() -> Int64`**（本版判 `Parse error, unexpected token \`(\``）。
  正写法与 core 的 `.mbti` 一致：`pub fn Money::cent(self : Money) -> Int64`。
- **结构体字段不用逗号**：`cent : Int64,` 判 `Expecting a newline or \`;\` here`；裸换行分隔（照 `mapx` 的 `BiMap`/`Table` 抄）。
- **Char 默认值不能再 `as Char`**：`sep~ : Char = ',' as Char` 判
  `\`Char\` is not a trait object type, it cannot be used on the right hand side of \`as\``；裸 `','` 已是 `Char`。
- **给 `suberror` 加变体会让既有的穷尽 `match` 当场报 `partial_match`**：第二批给 `NumError` 加五个变体后，
  第一批 `num_test.mbt` 的 `show(err)` 立刻红。这是好事——新变体不会悄悄漏出错误形状展示面。
- **Java 有两个舍入族，读数必须先选族**：`BigDecimal.valueOf(v)` 走 `Double.toString` 的**最短十进制**，
  `DecimalFormat` 走 `double` 的**二进制精确值**。本机 JDK 17 同输入对撞：`2.675` 舍 2 位 ⇒ `"2.68"` / `"2.67"`；
  `-0.0` 舍 2 位 ⇒ `"0.00"` / `"-0.00"`；`0.145` 舍 0 位（百分号那侧）⇒ `"15%"` / `"14%"`。
  hutool 的 `round`/`Money` 在前一族、`decimalFormat`/`formatPercent` 在后一族（还随 JVM 默认 locale 变），
  **它自己两半就不一致**。本库全线只认最短十进制这一族，与 `Double::to_string` 三档逐值一致是前提；
  写格式化件之前必须先确认参照实现属于哪一族，否则"两腿对撞"会拿一个族去核对另一个族。


### num 第二批（10-05）四条编译器裁决 + 一条"族别"读数裁决

- **本版没有 `Array::remove_at`**：要从头上丢元素就用"起始索引跳过"（`emit_shortest` 跳前导零就是这么写的）。
  `Array::pop()` 返回 `T?`，忽略也要写 `let _ = d.pop()`，否则吃"值不可隐式忽略"。
- **`/* … */` 块注释不存在**（分隔说明写成块注释会判词法错，中文全角标点还会先炸一次）⇒ 一律 `//` 行注释。
- **`moon fmt` 把跨行的字符串拼接重排成前置 `~+`，而那种形式编译器不认**（判 `The value identifier ~+ is unbound`）
  ⇒ 长表达式拆成"先算片段，再一行串起来"，别留操作符续行。
- **`Int64` 侧取负写 `x.neg()`，别写 `0 - x`**：裸 `0` 会被推成 `Int`，判 `Expr Type Mismatch`；
  同理三元的另一支 `… else { 0 }` 要给整条 `let` 标类型。数组只 `push` 不重新赋值时 `mut` 会吃 `unused_mut`。
- **格式化件先确认"参照实现属于哪个族"**：`BigDecimal.valueOf` = 最短十进制、`DecimalFormat` = 二进制精确值，
  同一台 JDK 对同一个数会给两种读数（`2.675` 舍 2 位 `2.68` / `2.67`；`-0.0` 保不保留负号 `0.00` / `-0.00`）。
  拿一个族去核对另一个族，会产出一堆"两腿不符"的假故障。

### conv 第一批（10-05）编译器语法七条裁决 + 镜像腿三条

- **泛型函数的参数表挂在 `fn` 上，不挂在名字上**：写 `pub fn[A] chain(custom : JsonConv[A], …)`；
  `pub fn chain[A](…)` 判 `Parse error, unexpected fn f[T], you may expect fn[T] f`。
- **透明别名没有 `alias` 关键字**（`alias` 是保留字，写出来既是语法错又吃 `reserved_keyword` 警告）：
  `pub type JsonConv[A] = (Json) -> A?` 就是别名本体，能当形参类型、能隐式接函数值与闭包。
- **`var x = e` 已进弃用通知**（`Warning (deprecated_syntax) … Use let mut`）⇒ 一律 `let mut`。
  本版工具链：moon 0.1.20260920 / moonc 0.10.14+7d59c7ec9。
- **会 raise 的匿名函数**要么写成箭头形 `() => expr`，要么显式标 raise；`fn (x) { 里面会 raise }` 吃
  `deprecated_syntax`（效应推断那种写法正在被拆掉）。把"会 raise 的调用"传给形参时，形参类型写
  `() -> A raise E`，调用点用 `g()`。
- **`Json` 变体是只读类型**：`Number(1.0)` 直接判 `Cannot create values of the read-only type` +
  `The labels repr~ are required` ⇒ 夹具一律 `@json.parse`/`@json.to_json`；模式匹配仍可以写
  `Number(d, repr~)`（core 自己也用这个形式，见 `json_path.mbt` 的 `Key(parent, key~)`）。
- **`Double::inf(1)` 已 deprecated** ⇒ 用 `@double.infinity` / `@double.neg_infinity`（`pub let`）。
  零警告门禁下，deprecated 警告与 error 同价。
- **core 的 `String` 没有 `to_lowercase`/`trim`/`split(Char)` 公开面**（`Type String has no method to_lowercase`），
  `string/*.mbt` 的 `pub fn String::` 全表数下来是 `all/any/char_length/compare_ignore_ascii_case/iter/rev_iter/`
  `substring/suffixes/to_array/to_bytes/unsafe_substring/…` 那一套 ⇒ 大小写折叠自写 ASCII 档，trim/切分用本仓 `@text`。
- **镜像腿要跑"同一条输入 × 两个 locale"**：`NumberFormat.getInstance()` 那支在 hutool 自己的运行时上
  就会给两个答案（本机 JDK 17：`"123.56"` 在 zh_CN 是 `123`、在 de_DE 是 `12356`，41 条不同）。
  这不是"我们不喜欢 locale"，是**参照实现不确定**——拿到这种读数就整支不跟随，并把两读并排放进 spec。
- **分岔表必须自证**：声明"不跟随"的每一条都要断言两边读数**确实不同**，相同就报"水分"。
  本轮真抓到一条水分（`int` 腿的 `"Infinity"` 两边都是 `None`），删掉才算闭环。
  反向判据（不同而未声明 ⇒ assert 失败）也要在，否则分岔表就是一张许愿池。
- **`git ls-files` 型的死链检查意味着"新文件必须先 `git add` 再跑门禁"**：`scripts/check_doc_links.py`
  故意不用 `os.path.exists`（本地有、没提交的文件克隆出去就是死链），G10 会在 add 之前判红——
  这不是门禁坏，是它在告诉你工作还没做完。

### conv 实现轮（10-05）四条写法坑 + 两条判据教训

- **`try { Some(e) } catch { _ => None }` 会被 `moon fmt` 折成 `e catch { _ => None }`**，折完类型就错
  （`catch` 的分支必须与 `e` 同型，而我们要的是 `T?`）⇒ 直接写 `Some(@string.parse_int(t)) catch { _ => None }`，
  把 `Some(...)` 放进被 `catch` 的那个表达式里，fmt 就不会再拆坏。
- **core 的严格解析件比 hutool 的文法宽**：实测 `@string.parse_int("1_000")` 给 1000（收下划线分隔）、
  `@string.parse_double("NaN")`/`("Infinity")` 直接给值，而它**不做 trim**（`" 123 "` 报错）。
  ⇒ 宽松腿的"能不能转"必须本包自己扫字符定文法，core 只负责求值与位宽界校验；
  把文本直接丢给 `parse_int` 就等于偷偷跟回了 Java 的 `NumberFormat` 分支。
- **`Json` 变体是只读类型**：构造用 `Json::null()` / `@json.to_json(v)` / `@json.parse(s)`，
  匹配可以用 `Number(d, repr~)`；忽略带标签的字段写 `Number(d, ..)`，写 `Number(d, _)` 报
  `requires 1 positional arguments, but is given 2`。
- **私有枚举别挂 `derive(Eq)`**：`derive(Eq)` 会生成 `impl Eq`，而本版把"impl 方法被当普通方法隐式调用"
  标成 `implicit_impl_as_method` 弃用警告——一个用不到的 `Eq` 就吃掉两条警告。要么标 `priv enum` 并删掉
  `derive(Eq)`，要么补 `pub extend 名 with Eq::{equal, not_equal}`。
- **优先序类规则必须有"两边都能做"的判别夹具**：`chain` 那 9 条断言原本全喂"内置转不出、自定义能转"的样本，
  把优先序整个反过来仍然 277 全绿——是变异对照（`chain` 反过来 ⇒ 8 块红）把它抓出来的。
  以后写这类规则先问一句"把实现反过来会红吗"，不会红就是没测。
- **期望值自身也会错**：本轮两处（`to_char("-0")` 把 JSON 源文本当 Double 形态、`to_big_int` 对带 `repr`
  的大整数绕了一次 `float`）。两处都按"单独一笔 + 外部读数来源"处理，来源是 `Number` 变体 19 条
  `(d, repr)` 实测表与 spec §4 的腿，不是"实现给什么就改成什么"。


## num 第三批实现轮（10-05）：四条判据 + 三条写法坑

**判据类**（都是本轮自己被自己的产物骗到之后才立住的）：

- **值档与错档对同一输入必须互斥**。本轮 `负一十` 同时被钉成 `-10`（认负块）和
  `UnknownChineseUnit 负 0`（错档块）——生成器把"参照侧报 ERR 的夹具"无条件塞进错档，
  没排掉**已声明分岔**的那几条。以后写生成器先写这条排除，别等实现轮来撞。
- **新增一条分岔声明必须能指向一条参照读数**。`亿亿亿亿亿亿亿亿亿亿` 被钉成 `OutOfRange`，
  是反向模型的推演被当成 JDK 读数冻进契约；现读是 `0`。凡是只有模型支撑、没有腿支撑的形状，
  不许进期望值。
- **变异先跑出来没红，缺的是夹具不是代码**：中文/英文缩写的平局档 `>=` 改窄两轮全绿，
  补 `10050 / 10150 / -10050 / 100000050` 与 `1005 / 10050 / 10150` 才各转成 1 块红。
  另一面更值得记：**变异要打在"对立的那一族"上**——金额腿第一次换成"×1000 取整再 /10"
  还是浮点族，所以照样绿；换成纯十进制 HALF_UP 才红两块。打在同一个族里等于给自己看想看的结论。
- **一个错误面只有一个 `show`**：第三批写成 `NotDecimal "abc"`，第二批已冻结 `NotDecimal abc`
  （无引号）⇒ 同变体两种读法必有一种错，按**已交付批次**的形状统一，不动旧块。

**写法坑**（本机编译器与 `moon fmt` 现决）：

- Int64 语境的字面量该带 `L`：`if scaled % div * 2 >= div` 会被整体判成 Int，
  在 `scaled` 和末位 `div` 各报一处"has type Int64, wanted Int"；写成 `2L`、`100L`、`0L - q` 就干净。
- **`moon fmt` 会去掉保护性括号并把 `if/else` 表达式折成多行**，所以变异锚点必须按
  **格式化之后的真实文本**写（本轮三条锚点因此静默失效过一次——那正是"变异自己坏了"的形状）。
  打完变异还要断言文件确实变了、跑完按 sha256 还原。
- `String::from_array(cs[1:])` 与 `cs[2:]` 差一位就是"吃掉那个数字还是吃掉两位"：
  `chinese_colloquial_of("10")` 读出空串那次是 `一十 → 十` 写成了 `cs[2:]`。
  跟随 `replaceFirst(key, value)` 时，**先算 key 长度与 value 长度的差**，别凭感觉切。
