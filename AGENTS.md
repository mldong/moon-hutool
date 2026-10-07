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

只用 `moonbitlang/core`（`moonbitlang/async` 也算第三方）· 零 `extern` · 全同步 · OS 能力只走 `env` 的 `now`/`rand`/`get_env_var` 三件，且**都必须可覆盖或可注入**（时钟走 `clock_fixed`，默认区走 `set_default_zone`）。

> `get_env_var` 是 10-07 第五批加进这一条的：MoonBit core 没有任何时区能力，宿主时区只能从环境变量拿，
> 而 `TZ` 在 js/wasm/wasm-gc 三档实测都读得到（判"读不读得到某个环境量"要并一条自造对照变量一起喂——
> git-bash 会把 `TZ` 自家征用再从子进程环境里摘掉，单看 `TZ` 会把 shell 的坑读成平台限制）。
> 加它之前先量后改口径，不默认"红线里没写就是禁止"，也不静默扩红线。第 4 条的后半句从"只走 env.now/env.rand"
> 改成上面这形；`read_file`、网络、宿主 API 仍然在禁令里。

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

## re 契约轮（10-05）：一条裁决权口径 + 四条门禁与读数坑

这一包的特别之处：**运行时那一侧才有裁决权**。参照腿（真 hutool + JDK）只能证明"Java 那里合法"，
不能证明 MoonBit 这边跑得出同样结果——`@string.Regex` 是纯 MoonBit 的 Brzozowski 导数自动机，
`js` 档也不借宿主 `RegExp`，所以判据一律取**引擎腿**（探针跑 wasm/js/wasm-gc 三档，三份输出逐字节相同才算数）。

- **源码读出来的"会走到哪一支"不是行为**：调研阶段从 core 的 parser 源码推断"`\1`/`\p{L}`/`\A` 不在转义集里
  ⇒ 退化成匹配字面反斜杠"，探针实测是**编译期报错**。这条改判同时删掉了一整个立项理由（"必须自己预检否则静默错"）。
  写进契约前，任何"引擎大概会怎么处理"都要变成一条探针读数。
- **"我以为两腿一致"也要逐夹具对撞**：切分的尾随空段在写契约时被判为两腿一致，腿 B 的读数直接推翻
  （`[,;]` 于 `",a,"`：腿 A `["", "a"]`、腿 B `["", "a", ""]`）⇒ 成了不跟随清单的一行。
  交叉核对不是只挑难料的对，是**同名夹具全对**。
- **PR-A 的门禁要在 `git add` 之后跑**：G10 的死链判定读 `git ls-files`，G4 的 `.mbti` 漂移判定读 `git diff`——
  新包自己的 spec 链接和刚 `moon info` 出来的接口面在这两格里必然"红"，先暂存再跑门禁才是真读数。
- **统计数只认文件**：spec 里手写的"合计 903 / 111 / 编译面 39"三处与读数文件现算的 **917 / 114 / 45** 全不符。
  抬基线、写 ROADMAP 行之前，回到 `wc -l` 与测试文件里 `assert_eq` 的实际条数；生成器自报的块数也算二次来源。
- **`moon.pkg` 的测试侧 import 同样要真被用到**：这批的测试只用本包类型，多写一条 `"moonbitlang/core/string"`
  就出 `unused_package`，G3 拦下。注意 G3 那句"有 2 条警告"是 `grep -c Warning` 数了两行（标题行 + 诊断行），
  实际是 1 条——**先看清日志再改代码**，别照那个数字去找两条警告。

## re 实现轮（10-05）：三条转义与语法裁决 + 一条改判

- **Java 源码层的正则字面量不能照抄进 MoonBit**。`([$\\])` 在 Java 源文里写的是 `"([$\\\\])"`，
  而 MoonBit 的字符串转义是**同一层**：写成 `"([$\\])"` 得到的串是 `([$\])`——类里含 `$` 和被转义的 `]`，
  core 判非法。**每条含反斜杠的夹具都要按目标语言的 literal 层级重打一遍**（期望串不受影响，
  这条更正一字未改期望值，单独一笔 `b275f24`）。
- **`var x : T = e` 在这个工具链上是废弃语法**（`deprecated_syntax` 警告），带类型注解的可变局部量要写
  `let mut x : T = e`；不带注解的 `var x = e` 仍可用。`moon fmt` 会把 `var` 改写成 `let mut`，
  所以**变异锚点要按 fmt 之后的文本找**（与 `num` 轮那条 fmt 坑同源，这次撞的是可变性标记）。
- **整串匹配 ≠ 最左一段占满**：`is_match("a|ab","ab")` 在参照实现里是 `true`。用 `execute()` 再判
  "起点 0 且占满" 会给 `false`——要的是 `^(?:…)$` 那种**把整串要求交给引擎**的写法（非捕获包装不改组号）。
  这条是实现级判别夹具，写在测试第 13 块里，变异一换就三块红。
- **"两腿同判断"也可能只是推断**：契约里写过"`(?<a>x)(?<a>y)` 重名两腿都报错"。实测 **core 接受重名**、
  只有 Java 拒绝。契约冻的是 `BadPattern`，所以实现改成**本包自己预检**（拦在组名扫描那一步，五个出口共用一张判据），
  并在 spec §5 加第 13 行把这条改判记录在案——**引擎比参照宽松，不等于可以悄悄放宽契约**。

## valid 轮（10-05）：码表类包独有的三条

- **文档页的期望值不许凭常识写**。`valid/README.mbt.md` 先写了 `is_money("1.222") ⇒ false`（以为金额限两位小数）
  与 `is_ipv4("01.01.01.01") ⇒ false`（以为前导零不算），两条都被真跑打回 `true`——而正确读数本来就在
  自己生成的语料里（`valid_test.mbt` 第 59、90 行）。**新写的 doctest 块也是一种摘要**：要么取自语料，要么先跑一遍。
- **改写规则本身要有一条变异看着它**。把 MAC 的分隔符从 `(:|-)` 改回 `[:-]`，core 是**编译期报错**，
  于是红形变成内部不变量终止（panic）而不是期望值不符——判"变异有效"要看**失败原因的形状**，
  只数"有几块红"会被骗（G3 那句"有 2 条警告"其实是 1 条，是同一族坑）。
- **码表判定件不 `raise`**：码表是包内常量，编不过只能是本包写错，不该变成调用方要处理的错误面；
  实现把这条收成"不可能到达的路径"（`whole()` 的 `catch` 里终止），而不是给 15 件各配一个错误档。

## rand 轮（10-05）：随机件的四条新规矩

- **参照实现不可注入时，期望值只能钉"与流无关"的东西**。`RandomUtil` 55 个 `public static` 没有一个收 `Random` 参数
  （实测 `javap`），所以"同一条夹具逐条比读数"这条路走不通。钉得住的四类：**常量表原样**（反射读字段，别抄）、
  **单点定义域**（`(0,1)` 含下不含上 ⇒ 恒 `0`；靠 3000 次抽样的计数分布证明"只有那一个值"）、**异常与空输入档**、
  **与流无关的不变量**（长度恰为 `count`、字符 ⊂ 表、去重档互不相同、零权重永不中选）。
  `random_boolean` 一条都没钉——1 位生成拿不出与流无关的性质，钉固定值等于把 core 的取数算法冻进契约。
- **机制面复测的做法：脚本化 `Source` + 消费轨迹**。
  `impl @random.Source for Src with fn next(self) -> UInt64 { ... }` 交回 `Rand::new(generator=... as &Source)`，
  同时把自己吐出的值记进一条 `Array`（`Array` 是引用类型，先在外部建好再塞进结构体，之后还读得到）。
  三条实测：`int(limit=0)` 不报错而是"取全域"；`int(limit<0)` 是 `abort`（panic）而**`try` 抓不到**——探针就停在那一行，
  所以**界值一律本包判死，别把界值透传给引擎**；三档同一脚本源输出逐字节相同（这才是跨档一致的凭据）。
- **变异要挑"能破坏目标不变量"的那一处**，不是挑看起来最错的算法。加权件我先试"权重全当 1 参与"——零权重那条**没倒**
  （累计桶仍先命中正权重项）；换成"先比再累加"（累计边界挪一位）才真的让零权重漏进结果。
  顺序是：先写下这条不变量被什么破坏，再倒推变异。
- **类型界可以留到实现那一笔再补，语义不许**。去重档需要 `Eq`，但骨架期没有体，加了必出 `unused_trait_bound`
  （G3 零警告拦），所以契约里以注释预告、实现那一笔补进签名并由 `.mbti` 记录。**只有类型界可以这样**；
  任何语义改动仍须单独一笔（G5 那条规矩不因它松动）。

## digest HMAC 第二批 + `mac` 判定轮（10-05）：参照腿自己也会错，判不建包要三条现读证据

- **参照腿不是免检的，读数文件要带能自证编码的字段**。首跑 JDK 参照腿时 `javac` 用平台默认编码（GBK）读了
  UTF-8 的 `.java`，中文夹具落成 mojibake——靠读数行里带的 `keylen=10, datalen=18` 才看出不对（正确 UTF-8 是
  `7/12`：`密钥K`=3+3+1、`中文数据`=4×3）。加 `javac -encoding UTF-8` 重跑，22 条里**只有这 2 条变**、其余逐字节相同，
  这才敢判"病灶在腿不在实现"。两条规矩：**参照腿含非 ASCII 字面量就显式 `-encoding UTF-8`**；
  读数文件除十六进制外还要带长度这类元数据，否则错值与对值一样长得像答案。
- **改已有公开项的实现，影响面是它旧的调用点，不是新增用例数**。把 `hmac_sha256_bytes` 重写成委托 `_of_bytes` 时
  顺手写了 `key.to_bytes()`——core 的 `String::to_bytes()` 打的是 **UTF-16 小端码元**（已标废弃），连 ASCII 都摊成
  2 字节，于是 7 条红里包含 `README.mbt.md` 的 RFC 4231 TC2：那条**本来就是绿的**，被这次重写拖红。
  所以改委托后要跑**全包**并把红逐条归因，别只数新块；文档块与断言块同权。
- **签名注释与实测冲突时，先判哪个是标准做法再决定改哪边**。verify 的十六进制档注释初稿写"不做大小写归一，给大写就判假"，
  实测收 `A-F`（任何标准 hex 解码都收）⇒ **按实现改注释**，不改实现：拒大写会让调用方从别处贴来的大写 MAC 验不过，
  是脚坑。反例是上一轮那种"实现跟随参照实现"，两边要分清：语义冲突看权威（RFC/参照实现），注释与实现冲突看哪个更标准。
- **"要不要建新包"是架构判定，要三条现读证据，不看类名像不像**。`mac` 那行的判定链是：
  ① `javap -cp hutool-core-5.8.35.jar cn.hutool.crypto.digest.HMac` 找不到类 ⇒ 它在 crypto 不在 core；
  ② 它是有状态对象（7 构造器 + `update`/`digest`/`digestHex`/`verify`）⇒ `update` 那半属早已挂"暂不做"的流式摘要；
  ③ 剩下的一次性用法薄一层，已由承接包八件覆盖 ⇒ 再开包只造第二张嘴。
  判不建之后**把占位目录删掉**（留着一个零公开项目录，别人会当"排在计划里"）。
  门禁口径注意：ROADMAP 那行的**契约列不许写 `docs/spec/NN-<pkg>.md`**——G13 按"行号=该路径的 NN"判，
  第 13 行指向 `02-digest.md` 会直接报红；承接说明用文字写（"记在 `digest` 的 spec §2.6"），契约列填 `—`。

## dfa 轮（10-05）：移植类算法与门禁机制的四条

- **变异先问"它能不能改变某个可观测读数"再写。** 本轮第五条变异是"二分里把 `<` 写成 `<=`"——**0 红**，
  因为等值分支 `if v == cu` 排在前，走到 `else if` 时 `v != cu` 恒成立，两种写法**语义等价**。
  这不是测试弱，是变异本身不改变行为（空变异）。换成"二分上界写成 `length - 2`"才有红，而且**只有"表规模"那块抓得到**
  （边界谓词抓不到，因为漏的恰恰是最大码位）——说明每一类判据都要有至少一块用例守着。
- **"我只改了注释"要拿读数证明。** 落地轮把测试文件头那句"这批预期红"改成终局读数（不改就被 G11 判措辞与读数矛盾），
  凭据是 `git diff <契约笔> -- <测试文件>` 滤掉注释行后**非注释行数差为 0**。
  另一条通道事实：**G5 只在 PR 事件里被 CI 激活**（`GATE_FREEZE_BASE` 取 `pull_request.base.sha`），
  直推 master 时那一格恒 SKIP ⇒ PR-B 要在本地手动 `GATE_FREEZE_BASE=<契约笔> bash scripts/contract_gate.sh`。
- **码表用"规模读数 + 边界点"钉，不逐位钉。** 停顿字符表 327 个码位，用例是"扫全 BMP 计数 == 327"+ 六条边界谓词；
  钉 327 位等于把表抄第二遍（两份真相必然自己跒）。表本体落在独立的数据文件（只放表、不放逻辑），
  由生成脚本从参照腿灌入。另：**新包目录要先进 git 索引**——`sync_status.py` 的 `packages()` 读 `git ls-files`，
  先 `--write` 后 `git add` 会落出一个少算一个包的既往读数。
- **参照实现可能是 vendored 拷贝，血统问题不能靠"我从哪个 jar 读的"绕开。** 本仓 `path` 那行的对位类
  `cn.hutool.core.text.AntPathMatcher` **确实在 hutool-core 的 jar 里**（实测 15 个 `public` 成员 + 4 个内部类），
  但它自身是 Spring-core 的拷贝（Apache-2.0）——所以"从 hutool 读取"不改变血统判定，写这一包之前必须先拍定许可证口径。
  同时记一条机制：`match` 是 MoonBit 保留字，对位方法名只能改叫 `first_match`（这类坑只有写签名那一刻编译器会告警，骨架期不能省）。

## path 轮（10-05）：血统不等于待办，以及黑盒面的三条编译器裁决

- **先现读仓内文件，再决定某件事是不是待办**。`path` 行只写"血统 = Spring-core（Apache-2.0）"，
  我就顺手把"许可证还没拍"当成开工前置——现读推翻：`LICENSE` 与 `moon.mod` 从骨架那一笔起就是 Apache-2.0。
  **血统是事实，待办是决定**，两者不能混着写；血统照旧写进 spec 单独一节（不藏），但它不构成屏障。
- **参照腿在哪个 jar 里要先 `unzip -l` / `javap` 现读**。`dfa` 轮的结论是"不在 core，要另取件"，
  本轮开局几乎照它去找"Spring 的 jar"——实测 `AntPathMatcher` **就在 hutool-core 的 jar 里**。
  两轮合起来的规矩不是"要不要换件"，而是**先现读再决定从哪取**。
- **黑盒测试要构造记录，得写 `pub(all) struct`**：普通 `pub struct PathOptions { ... }` 字段读得到、
  构造器导不出来（`Cannot create values of the read-only type`）。只想读字段（如 `FoundWord`）就用普通 `pub struct`。
- **错误枚举变体在黑盒面归一成档名，别捷径用 `show`**：骨架期测试里 `show(err)` 报
  `The value identifier show is unbound`（黑盒测试语境里它不在作用域），改成一个 `match` 分支返回档名就稳了。
- **本版废弃新增两条**：`String::starts_with` → **`has_prefix`**；`UInt::reinterpret_as_int` 仍可用，
  但 **`Int::to_uint` 已废弃 → `Int::reinterpret_as_uint`**，而把 `Int` 写进 `Byte` 直接用 **`Int::to_byte`**（截断低 8 位，不报错）。

## path 落地轮（10-05）：G5 与 G11 会互相拉扯，以及"期望值的推导方式"也能错

- **G5（期望值冻结）与 G11（状态措辞一致）盯的是同一批文件**，所以落地笔不可能两者都干净满足：G5 禁止实现 PR 碰
  `*_test.mbt` 与 `docs/spec/*`，而 `sync_status.py` 的 `NOT_DONE` 会在包已全绿时**报错**这些文件里还留着
  「预期红」「函数体是 `abort`」。做法不是把措辞拖到下一笔（那样 G11 红），而是走 `ALLOW_EXPECTATION_CHANGE=1`
  授权通道，并**当场给"期望值没动"的机器证明**：把测试文件剔掉注释行后与 `git show HEAD:<file>` 比字节，相等才谈授权。
- **`for k in lo..hi` 含尾**（`Range` 语义，`moon fmt` 会把它归一化成 `..<=`），与 `IntRange` 的不含尾相反。
  按"半开区间"写出来的切片会多带一个字符——本轮表现为 `{name}` 抽出的键变成 `name}`。端点语义不赌，写 `while` 或显式 `..<=`。
- **期望值可以整体是错的，而测试与编译器都看不出来**：把参照实现"排序后的相邻两两比较"反推成逐对 `<0`，
  忽略了并列档返回 `0` 且稳定排序保留输入序——反推造出了一条参照里并不存在的严格序承诺。
  规矩：**凡期望值来自对参照输出的二次加工（排序、去重、计数），一律改成逐条直读**，且更正单独一笔、来源写明是参照腿读数。
- **变异要能改变某个可观测读数**，否则是空变异：二分里的 `<` 改成 `<=` 跑出 0 条红（相等分支在它前面，语义等价），
  换成把上界改小才被抓到。另一条如实记着：本轮"大小写开关接反"只被 2 块抓到，夹具两侧同升降、区分不出来——
  写进 spec 当**待补强**，不写成覆盖完备。
- **措辞换代要复跑判据而不是背串**：`NOT_DONE` 匹配的是整串（`实现未开工`／`预期全红`／`预期红`／
  ``函数体是 `abort` ``／``函数体 `abort` ``），改写完跑一遍 `python scripts/sync_status.py --check` 才算数。

## cache 契约轮（10-05）：对位类名要现读，挂起可以是读数，编译器裁决再来三条

- **计划里写的对位类名，立约前逐个 `unzip -l | grep` 过一遍**。`cache` 那行原写
  `CacheUtil / SimpleCache（LRU / LFU / TTL）`，实测三处不符：`cn/hutool/cache` 在 hutool-core 的 jar 里 **0 条**（件在
  hutool-cache 这个 artifact），`SimpleCache` 反倒**在 core** 的 `cn/hutool/core/lang/`，而 `MRUCache`/`SoftCache`/`FCFSCache`
  在 5.8.35 **根本不存在**（4.x 旧件）。"不存在"也是结论，要写进 spec 的来源节。
- **一个说不清的挂起，先把它变成可打印的读数再决定怎么办**。`CacheUtil.newTimedCache(100, 50)` 之后 JVM 不退出、
  工装跑到超时；把 `Thread.getAllStackTraces()` 里的非守护线程名打出来，就拿到 `Pure-Timer-1`——
  这条正好是"`schedulePrune`/`GlobalPruneTimer` 不进契约"的证据（守护线程语义不是缓存语义）。
- **本版编译器的三条泛型/枚举形状裁决**（都别靠记忆）：① `pub struct Cache[K : Hash + Eq, V]` **解析错**——
  泛型约束只能写在 `fn` 上；② 约束写在 fn 上而体子是 `abort` ⇒ 逐件 `unused_trait_bound` 警告 ⇒
  骨架豁免要带上这一类，落地那一笔按 G12 撤掉；③ 调用点**不支持** `f[T]` 显式类型实参（会连外层函数的参数个数一起算花），
  类型靠 `let x : T[K, V] = …` 的注解；`pub enum` 的构造子跨包不可构造（`Cannot create values of the read-only type`），
  与"黑盒构造记录要 `pub(all)`"是同一条机制——枚举写作 `pub(all) enum`。
- **别为了断言去 `derive`**：`assert_eq` 比数组要求元素同时有 `Eq` 与 `Debug`，而本仓 `date/extends.mbt` 已写明
  `derive(Eq, …)` 带来的 `implicit_impl_as_method` 提升是废弃路径（零警告是门禁）。改把记录**归化成字符串数组**再比
  （本轮是 `键=访问数:ttl`），顺带让参照腿的计数形状原样出现在断言里。
- **计时依赖只留在参照腿，用例一律换成显式传进来的 `now`**。参照侧造过期只能 `Thread.sleep`；本库把时钟做成参数之后，
  `ttl > 0 && now - last_access > ttl` 这条判据用 `1100`/`1101` 两个整数就把**相等边界**钉死了，还顺手拿到一条读源码才看见的
  反直觉结论：`ttl <= 0`（**含负数**）是"永不过期"，不是"立即过期"（读数 `fifo.neg_ttl_alive|1`）。
- **参照实现自相矛盾时，取可推导那一侧，但两侧读数都要落盘**。本轮两处：`capacity == 0` 在
  `AbstractCache.isFull` 眼里是"不限"（实测 `fifo.cap0_size|5`），在 `FixedLinkedHashMap.removeEldestEntry` 眼里是
  "放进即淘汰"（实测 `lru.cap0_size|0` + 一次回调）；`NoCache.size()==0` 却 `isEmpty()==false`、`cacheObjIterator()` 返回 null。
  本库统一成"`0` = 不限容量"、"`is_empty` 恒等于 `size() == 0`"、空数组代 null，四条分岔连同读数记在 spec §5。

## cache 落地轮（10-05）：夹具写错要可枚举归因，骨架豁免是借的债

- **给不出"字节相等"就给"不等集合可枚举且逐条归因"**。落地笔本该证明期望值未动（`cache_test.mbt` 剔掉注释行后
  与契约笔字节相等），但本轮必须修 4 处**夹具左边的字符串字面量**（插值要写 `\{x}`，见上一节的编译器裁决），
  相等证明不成立。改成给"非注释行 318 对 318、逐行不等只有 4 处、4 处全在左边"这个形状，并把
  "每条 `assert_*` 的右侧未变"写死在提交信息里——**不许把差异藏进汇总数**。
- **选择性提交前先 `git status` 看清暂存区**。本轮想把"夹具更正"拆成独立一笔，但前一步已经把整批改动 `git add` 过，
  那一笔把整批一起吃了进去；于是改用 `--amend` 把提交信息换成 diff 的真实内容（含"与落地同笔、没拆成独立一笔"的说明）。
  判据是**提交信息必须与 diff 事实一致**，比"看起来遵守了两笔纪律"重要。
- **状态措辞与实现必须同笔**：`sync_status.py --check` 是双向判的——既报"已全绿却写『预期红』"，
  也报"已全绿而 ROADMAP 状态还写『契约已冻结』"。所以 docs 换代不能拖到落地笔之后单独一笔（与 G5 的拉扯见上一轮那条）。
- **骨架期压警告是借债，落地笔要还**。契约期把 `unused_trait_bound` 加进 `warnings` 豁免（`abort` 体读不到
  `K : Hash + Eq`）；落地后 G12 撤豁免，才发现约束真正用不到的签名会逐件报警告——10 件降到 `fn[K, V]`、
  `touch` 只留 `K : Eq` 才回到零警告。写骨架时就该顺手标注"哪些约束是真要的"。
- **等价变异会被自己的规则抓到**。上一轮记下"写变异先问它改变哪个可观测读数"，本轮那条
  "LFU 只删等于最小值的几条、不减其余"跑出 **0 红**——均匀减法保序，`min` 与取到 `min` 的集合都不变，
  只有计数逼近溢出才可能可观测。补跑"最小值判定取反""跳过公平减计"各 3 红才算够；
  顺带得出参照实现那句"以便新对象进入后可以公平计数"的归因是**防溢出**，不是选择规则。

## hash 契约轮（10-05）：覆盖缺口要用脚本暴露，骨架期别写 `mut`

- **件位置每轮现读，别照上一轮的结论套**。`dfa`/`cache` 两轮都是"hutool-core 的 jar 里没有、要另取 artifact"，
  本轮反过来——`HashUtil`/`lang.hash.*`/`io.checksum.*` **全在 hutool-core**，一个 jar 够用。
  同轮还翻出行里混着的 `Hashids`：它在 `codec` 且**不是哈希**（可逆编码），已从本行剔除、另判归属。
- **生成脚本必须逐标签 `assert 读数存在`**，缺了就停。本轮第一次跑就报 `缺读数：rs.cn`，暴露的是
  **参照腿夹具覆盖不齐**（只给六件配了非 ASCII 夹具）。两条出路：补腿，或把断言限制在已覆盖的范围——
  本轮选了后者并明确记成欠账；**不许**"照公式自己算一个值填进去"，那是发明语义。
  同类暴露：`crc8.init.31_0` 取不到数——腿里的标签是十进制 `49_0`，脚本按十六进制名找，标签对不上就等于漏断言。
- **骨架期刻意不写 `mut` 字段**。本版 `unused_mut` 是 **error 级**（`Error Warning: The mutability of field … is never used`），
  而骨架体不写状态 ⇒ 写了直接卡零警告门禁，且 `warnings` 豁免压不住 error 级。字段的 `mut` 留给落地笔按语义加
  （`cache` 轮就是这条顺序，`.mbti` 相应前进这一档形状）。
- **`Bytes` 的构造面只能现读**：`Bytes::new(len)` 要长度、`push_byte` 不存在；可用的是
  `Bytes::from_array(ArrayView[Byte])` + `Int::to_byte`（截断低 8 位）。`String` 依旧没有 `slice`——
  长夹具就把字面量直接灌进测试，别留切片依赖，免得把端点语义问题埋进契约。
- **值兼容优先于"更正确"，但两侧读数都要留档**。三处本轮各自处置：`CRC8` 照抄参照的非标准表构造
  （实测 2 对标准式 244，两个数都写进 spec）；`additive/rotating` 的 `prime == 0` 参照侧直接
  `ArithmeticException`，本库换成可枚举的 `raise HashError::ZeroPrime`；Murmur 三参是 `(data, length, seed)`、
  四参才是 `(data, offset, length, seed)`，只差一个位置 ⇒ 分成 `murmur32_len_seed` 与 `murmur32_range`，
  把陷阱摆进名字而不是替参照补重载（64 位参照就没有 offset 档，本库也不发明）。

## hash 落地轮（10-05）：夹具也是期望值的一部分，"字符"在两家语言里不是一个东西

- **字节夹具不许手打**：`b_cn` / `b_emoji` 两份 UTF-8 字节序列按记忆写进生成器，两处都错（`文` 写成 E6 B5 95、
  `🍎` 写成 F0 9F 8C 8E），错到断言红才暴露。凡是字节序列一律由脚本 `s.encode("utf-8")` 现算，与参照腿
  `StandardCharsets.UTF_8` 同源。"不手打"这条红线不止管断言右侧，**左侧的夹具同样适用**。
- **一条病断言比没断言更坏**：`fnv_hash(s) + fnv_hash_bytes(bs) == <某读数>` 左边那个求和式在参照腿里没有对应读数，
  它能"自洽"只因两侧都错。判据：**每条断言的左边必须能在腿里指回一个标签**；指不回就拆。
- **`Char` 是码位、Java `charAt` 是 UTF-16 码元**：逐字符族一律先摊码元（`utf16_codes`），否则非 BMP 字符（emoji）
  整体少一步。跨语言移植里"字符"不是同一个东西——同一位置的另一条表现是字符串插值要写 `"\{x}"`。
- **值兼容优先于"更正确"，但要用中间量定位**：`CRC16Ansi` 参照是 `hi ^= b` 且**不掩 `0xff`**、进来的字节是符号扩展的 -1；
  按常识掩码就给 47297 而非 64705。把 Java 侧逐字节中间量打出来（`-1 → -1 → 49345 → 20480 → 64705`）一次定位，
  比读源码反复猜快得多——**同一条输入两侧都打中间量**是这里的正解。
- **管道会吞掉门禁退出码**：`moon check 2>&1 | grep -c "Warning ("` 之后用 `&&` 串 `git add`，`&&` 看的是 `grep` 的退出码，
  坏文件照样进索引；之后从 `git show :file` 恢复就恢复成坏版本，白跑三轮。定死：
  **先 `moon check` 裸跑并 `echo $?`，通过才 `git add`；恢复一律用 `git show HEAD:<f>`**，别把索引当可信基线。


## bloom 两笔（10-05 · `365d975` + `4ef6f63`）——聚合层等价变异自查，与本版五条工具链裁决

1. **反射导出的终态比行为反推硬**。位图层没有可读的输出面，就把参照侧的私有字段 `ints`/`longs`/`bm`/`filters`
   用反射打出来当期望值（1325 行腿）——词表是**状态读数**，不是"加一串再查几个点"的行为推断；
   异常档同理直接打 `class:message`，再按 spec 的分岔表映射到本库四个错误变体。
2. **"顺序调换"这种变异要先问它交换不交换**。聚合层 `contains` 是逐过滤器之与、`add` 是逐过滤器之或，
   两者对列表排列都满足交换律 ⇒ 调换默认五件顺序 **0 红**，是等价变异。§6 里那条"会被 `bf.m6.*` 序列抓到"
   的预测因此当场更正。留下这条不是凑数：它说明"顺序与参照源码字面对齐"不构成可观测契约。
3. **真正该打的短路变异是副作用那一侧**。`flag |= filter.add(str)` 的 `|=` 不短路——把实现写成
   `if !flag { flag = f.add(s) }` 就有 3 块红（后面的过滤器漏加，词表终态与后续布尔读数一起变）。
   写变异时问"它破坏哪条不变量"（承 `rand` 轮那条），这里破坏的是"每个过滤器都被调过"。
4. **`contains` 用位与而不是右移**：`(w >>> c) & 1 == 1` ⟺ `w & (1 << c) != 0`（右移的符号填充永远碰不到第 0 位）。
   本版 Int64 移位要绕 `reinterpret_as_uint64`/`reinterpret_as_int64`，位与一条就把这层省了，
   还保住 W32 档"符号位被负位置占过"的负读数（`w32.after.neg`）照样复现。
5. **落地轮也会暴露测试自己的缺口**：`oob.add.2^37.plus` 那条断言之前少了左侧一步 `b.add(2^37+3)`。
   补步骤可以，**改期望串不行**——用 `git diff --cached --numstat` 证"1 行新增、0 行删除"，
   再走 G5 授权通道（这正是 cache 轮那条"给不出字节相等就给可枚举且逐条归因"的同族做法）。
6. **本版编译器五则（本轮实撞）**：实参位置不许裸写 `try`（会被解析成匹配模式）⇒ 每个会 raise 的口子配一个
   具名标签辅助件；`let _ = <会 raise 的调用>` 推不出返回类型 ⇒ `let _v = f()`；闭合枚举比对走标签函数而不是
   `derive`（同 `CachePolicy`）；`match` 分支上写闭包字面量 `"elf" => s -> f(s)` 会被当模式 ⇒ 先落具名 `fn h_xxx`；
   结构体字段名撞方法调用（`self.hash(s)` 判 "Type Filter has no method hash"）⇒ 字段改名 `hf`，
   且数组泛型写 `Array[T]` 而不是 `Array<...>`（后者解析成 `=` 附近的词法错）。
7. **工装三条老坑本轮又各撞一次**，照旧记着：中文写进 `python - <<'PY'` 的 heredoc 会被 GBK 重编码成
   `SyntaxError`（要走 Write 落成 .py 再跑）；heredoc 字符串里的 `\b` 之类会被吃成退格（路径一律正斜杠或 `chr(92)`）；
   变异工装必须开局先把工作树按已知逆补丁还原并**跑一次基线读数**，否则崩一次就把脏树当基线（`textsim` 轮那条）。

## textsim 两笔（10-05 · `8fe3b89` + `74762f2`）——三条腿三向对撞，等价变异照记

1. **参照侧的 `private` 不是不能读，而是要先证它存在**。本包的剥离集与分子分母口径只能从
   `isValidChar`/`removeSign`/`longestCommonSubstringLength` 三个私有方法拿。姿势：同一条腿先打
   `priv.names`（`getDeclaredMethods()` 把 7 个方法逐个点名），再 `setAccessible(true)` 取数。
   两件剥离面提到公开（#20.1/#20.2）的理由记 spec §5——不可测的口径等于没口径。
2. **模式分岔要造夹具去撞**。`HALF_UP`（商，10 位）与 `HALF_EVEN`（百分比）这两档，随机夹具撞不到平局：
   专造 `abcdefgh`/`a`（1/8 → 12.5% → `12%`）与 `b×2047+a`/`a`（1/2048 → 第 11 位是 5）。
   这类数还能同时钉住"分母取较大者""剥空给 1.0"两条。
3. **独立实现腿（Python `Decimal`）在写实现之前就能证"算法同值"**：生成脚本开头拿它与参照腿逐格对撞，
   分岔就拒绝出文件。结果是落地笔开局 405 绿、期望值一字未改——这条比"落地后逐条转绿"更省轮次。
4. **串读数一律打 UTF-16 码元十进制表**。`lcsu.24|[32]`（一个空格）、`lcsu.30|[55356,57166]`（整个 emoji）、
   `loc.de` 里的 U+00A0 都是"裸串打出来看不出差别"的位置；转义由脚本配对代理对后生成，全仓零手打。
5. **等价变异照记，并给出能抓到它的夹具**。负 `scale` 不夹成 0 → **0 红**：本轮唯一那条负档夹具的值是 0.0，
   夹与不夹都出 `0%`。教训不是"这条不重要"，而是"夹具没撞上分岔档"，已在 spec §6 标待补强并写出替代夹具
   （`abc`/`axc`：夹住 67%、不夹 70%）。
6. **变异工装本身会污染基线**。本机 `subprocess(text=True)` 撞 GBK 控制台，脚本在第一条变异上抛异常，
   于是"带变异的工作树"被下一轮当成 `ORIG`。规矩：工装开局先按已知逆补丁还原 + 跑一次基线读数，
   再进变异循环；捕获一律字节流 + `decode(errors="replace")`。
7. **本版编译器面五则**（写实现时撞到的）：`var x = …` 已判 deprecated（`let mut x = …`，零警告门禁下 11 条=11 红）；
   core 无 `Array::init`；`StringBuf` 不在 prelude（用 `String::from_array(ArrayView[Char])`）；
   `Array::make(n, 内层数组)` 会把 n 行**共享同一份内层数组**，DP 矩阵必须逐行 `push`；
   labelled 实参传法是同名字段尾随波浪号 `mode~`，写成 `mode: value` 报的是 `suffix is unbound`（misleading）。


## cron 两笔（10-05：契约 `49d2973` → 落地 `29e2da7`，425 全绿三档一致）

- **契约轮的期望值要过两道判据，不是一道**：抄写对不对（`§4` 腿对标签）**加**"本库出口形状产不产得出这条读数"。
  本轮把冻结文件 1112 条用例逐条反抽出来重跑了一遍腿（脚本从 `cron_test.mbt` 抽 (kind, pattern, 时刻, flag) 喂给 Java 腿），
  当场抓到四处 PR-A 缺陷：①`nx/nm` 块第 2 号基准腿是 `2024-12-31 23:59:00`、测试写成 `2024-03-31 12:00:00`（70 处）；
  ②`nx.34.*`/`nm.34.*` 十二条期望直接抄了 `IllegalArgumentException:Invalid matcher: ...YearValueMatcher`——本库的
  `nx_tag` 只会输出 `OK:<时刻>` 或六档标签，**永远产不出**；③块 8 末尾两条把参照值当本库期望，与块 1 的 `BadParts` 矛盾；
  ④`nx_tag`/`nm_tag` 漏 `OK:` 前缀。**"块红"会掩盖"块内未跑"**：`assert_eq` 一红就中断该块，204 条 `nx/nm` 里有 100 多条从没被执行过。
- **改期望值必须留双侧读数**：`-1`、空串、`5L`、年档无未来解这四处本库与参照不同判，处理一律是"取可推导的一侧 +
  参照原文留在标签注释里 + spec §5 单独立一行"。G5 授权通道的自查要说"删了几行期望串、每行属于哪一处改判"，
  不能只报 numstat 的总行数（本轮 `-14/+14`：12 行改判 + 2 行降级为注释）。
- **参照内部是 lenient 容器 ⇒ 出口不许逐字段校验**：cron 的回退查找会把字段送出段区间（分=60、月=13），
  Java 靠 `Calendar` 滚动整体滚进下一时/下一年；本库第一版用 `Date::of`/`DateTime::of` 逐字段验，
  13 月被判非法 ⇒ 2025-01-01 变 1970-01-01。移植 CRC/日期/进制这类"容器会自己滚"的算法时，
  **出口必须同效折算**（本轮：按 epoch 秒/天整体换算 `from_epoch_millis(天秒 × 1000, 0)`）。
- **BoolArray 匹配器的 min 不是首元素**：`5-1,7` 展开成 `{5..59, 0, 1}`，`vs[0]=5` 而真 min=0；
  拿首元素当回绕基准 ⇒ `12:01` 变 `12:05`。照抄参照构造器时，它显式扫 min/max 的那两行不能省。
- **"某段不参与匹配"要先确认该段在这几种段数下存不存在**：PR-A 写"第 7 段既不解析也不匹配"是把 5/6 段的情形
  推广过头——7 段式的年档**参与匹配**（`m.33.*` 为凭）。
- **变异对照里会出现"不是红，是不收敛"**：去掉月末夹取分支后 `nx.49.*` 的逐日重试永远命中不了 ⇒ 120s 墙钟超时。
  这类变异要带超时跑，并且超时本身就是判据（它说明该分支承重的是"总函数"承诺，不是取值）。
  本轮另有两条如实记录：**"段数 ≥5 即放行"是等价变异**（50 条 `ok.*` 里没有 8 段式 ⇒ 判据不可达，列覆盖欠账）；
  **"毫秒清零"无法作为变异挂载**（出口毫秒位没有第二个来源）。
- **本版编译器面六条**：`priv` 不能标注 `fn`；`pub struct` 的字段要写 `priv x : ...` 才能依赖包内类型
  （否则 "A public definition cannot depend on private type"，`moon info` 会出 `// private fields`）；
  数组 `.length()` 是方法（`arr.length` 判 "abstract type and not a struct"）；`Char` 取码位是 `to_int()`；
  单元素进数组用 `push`（`append` 是接另一个数组，报 "wanted ArrayView[...]"），`String.trim()` 出 `StringView` 不出 `String`；
  `while true { ... return x }` 判 "这个 while 要产出 DateTime，请加 nobreak 块" ⇒ 改成条件循环 + 末尾表达式。
- **Windows 腿的两条老坑本轮各撞一次**：`javac -cp "a.jar;b.jar"` 用 `/c/...` 形式的 POSIX 路径会"包不存在"，
  要先 `cygpath -w`；`grep -a` 之前忘了 `tr -d ''` 会让中文读数整段被当 Binary file 吞掉。


## csv PR-A（10-06：契约冻结一笔，432 = 绿 425 / 红 7）——新判据第一次真的拦下了东西

- **「期望串必须能由本库出口形状产出、且腿要给完整形状」这条判据第一次落地就用了 37 次**：参照在
  「要表头却够不到那一行」的组合上于 `read()` 内部就失败（`IllegalArgumentException:No header available!`、
  `NullPointerException ... this.header is null`），表头之后的行/行数/byName 全都没有读数 ⇒ 这 37 组
  **从冻结面里剔除**（384 → 347 条读断言），不拿推导当期望值。**反面教训**：cron 那一轮就是把 Java 异常串
  当期望灌进去了 12 条，落地轮才发现产不出。
- **本版编译器六则（全部实测撞出）**：记录更新语法 `{ base with x = 1 }` **不接**（Parse error:
  unexpected token `with`）⇒ 配置档必须逐字段照抄默认值再改要改的那个；跨包构造值要 `pub(all) struct`，
  否则判 "Cannot create values of the read-only type"；类型别名关键字是 `pub type X = T`（`typealias` 判
  unexpected lowercase id）；函数返回类型只能 `-> T`，`fn f(i : Int) : T` 是解析错；`alias` 是保留字
  （Warning: reserved_keyword，零警告门禁下必须改名）；测试包里用本包类型要写 `@csv.CsvLine`（否则
  Warning: test_unqualified_package）。
- **生成器的转义层要归零**：把 MoonBit 源码嵌进 python 三引号串里，`'''` 会被 python 解码成 `'''` 提前
  终结字符串，于是一个字符字面量把整个生成器打翻，连着三四轮在「补转义」上原地打转。正确形状：**helper 代码
  单独存一个 .txt，脚本只读它做拼接**，断言文本由脚本现算——两层分离后一次通过。腿的输出同理：Windows 上
  `java >` 落的是 GBK，读回要 `encoding="gbk"`，不能当 UTF-8。
- **参照语义里最容易被想当然的几条**（都有读数在 spec §3）：默认 `headerLineNo=-1` 即**不认表头**、
  默认 `skipEmptyRows=true` 但**行号照推**、注释符只在行首生效、引号必须整包裹才剥（`a"b`、`"a"x` 原样留引号）、
  引号内两写 `""` 只出一个 `"`、字段只剥首尾 CR/LF 不剥空白、null 默认写空串而 `always_delimit_text` 下写 `""`、
  **5.8.35 的写方法名是 `writeLine`，没有 `writeRow`**（那是 hutool 6 的命名，照 6 的 API 写契约会整面错）。

## ini（第 22 行）第一批 PR-A 的六则（10-06）

- **本格要另拉 artifact，且腿的类初始化依赖藏在另一个件里**：`unzip -l hutool-core.jar | grep -ciE "props|grouped"` 现读
  **0**——`Props`/`GroupedMap`/`SettingLoader` 全在 `hutool-setting`；而 `SettingLoader` 有
  `private static final Log log = Log.get()`，缺 `hutool-log` 时是 `ExceptionInInitializerError`，第一次跑出 60 行"读数"
  全是 `ERR` 行（**若把 `ERR` 当数据读，就会冻结一批错误期望值**）。跑腿之后先 `grep -c ERR` 再往下走。
- **语义表的权威是逐位扫出来的，不是抄 Java 规范**：hutool 的空白判定比 `Character.isWhitespace` 宽——对 BMP 全量扫
  `trim(c+"x"+c)` 与 `isBlank(c)` 两档，得到 34 位表（多 `00`/`a0`/`180e`/`202a`/`2800`/`3164`/`feff`，不含 `0085`、
  不含 `200b-200f`）。`i.bom_line` 就是这条的可见后果：BOM 开头的行键名是干净的。
- **两条"参照的形状不是笔误"**：`size()` 的缓存在 `remove`/`clear` 时**不失效**（先读后删 ⇒ 读数停在旧值，`is_empty`
  跟着错），双参 `get` **不剥组名**而其余方法剥（`put(" x ")` 后 `get(" x ")` 读不到）。都照搬，spec §5 两侧读数都写。
- **平台量与宿主状态都不许进契约**：`store` 走 `PrintWriter.println` ⇒ 分隔符是平台量（本机腿现读 `\r\n`），本库写死
  `\n`，期望值由脚本做"整串切 `\r\n` 再拼 `\n`"的机械变换，值尾带 CR 紧贴分隔符的夹具就地标注为不可对拍；
  变量替换的最后一档查系统属性（腿给 `${java.version}` ⇒ `17.0.14`）是**这台机器的 JDK 版本**，写进契约就换台机器必红
  ⇒ 该夹具直接从表里摘掉，只在 spec §5 记分岔。
- **本版编译器另三则**：记录构造是 `Type::{ field: value }`——`Type({...})` 判"没有自定义构造器"、`Type{...}` 直接语法错；
  `Array.map(x -> ...)` 的箭头写法不接（`Parse error, unexpected token ->`）⇒ 测试里的形状渲染全走显式 `for` 循环；
  骨架期 `priv` 字段必然"没人读"⇒ G12 豁免串本轮起要多带一个 `-unused_field`。
- **G12 的判据取的是 `abort("moon-hutool` 这个字面串**（不是"用例红没红"）：骨架体的 abort 文案必须带这个前缀，
  否则 G12 判"实现已落地却还压着骨架豁免"。本轮第一次跑 gate 就栽在这条上。

## typex 两笔（10-06：契约 `e46f7eb` → 落地本轮，459 = 绿 459 / 红 0）

- **等价变异先怀疑夹具，不怀疑结论**（ini 轮 M1 那条在这里连中三次）：首轮 M2（大小写不敏感比）、M8（首段不再无条件
  按 `c-'0'` 起算）、M9（`pre` 空档改判更小）**全给 0 红**——不是这三条判据不重要，是 157 条老夹具一条都区分不了它们。
  做法是给腿补 5 对新款（`V25..V29`：`.A`/`.a` 两向、`z1.0` vs `999.0`、`1.2.3` vs `1.2.3-SNAPSHOT`、`""` vs `1.2.3-beta`），
  再重挂 ⇒ 三条分别 1/1/1 红。核对"只增不改"用两条脚本判据：HEAD 的 157 条断言行**逐字节全在**，
  且 143 条期望标签里唯一变化的两条是 `SEGMENT` 注释（对象身份 `@7aec35a` 是宿主态，已从读数里剥掉）。
- **本版编译器另三则**：顶层 `let mut` 直接判词法错（`unexpected token mut`）⇒ 全局可变格子用单元素数组（`let c : Array[Int] = [0]`）；
  `Array.length` 是**方法** `.length()`，写成字段式会报 4028"abstract type and not a struct"这种误导性错误；
  `return` 后换行接 `if` 表达式会被吞掉（4014 + 4139 连发）⇒ 一律写成 `return (if … { … } else { … })` 单行式。
  另：`arr.map(u => …)` 箭头闭包仍不接（M2 第一版因此编译失败被判"未挂载"），变异锚点宁可用位运算折叠（`| 0x20`）也别造新函数。
- **位宽处置要提前定**：MoonBit `Int` 在 wasm/js/wasm-gc 是 32 位而 native 是 64 位，参照的算式全是 Java `int`/`long`
  ⇒ 凡溢出可达处一律 `Int64` 中间量 + 显式取低 32 位补码读（模 2^32 域里 `+`/`*` 同余，所以一次回绕与逐步回绕同值）。
  不定这条的话 `9999999999.1.1` 这类档在三档与 native 之间必有一档在骗人，读数冻结不了（同 `08-num.md` §0.1）。
- **给自己的注释/文档数字一律现读**：本轮 spec 初稿把 `HASH` 档写成"13 条"、`RAINBOW` 写成"17 条"，与腿的现读
  （29 条里 27 false / 22 条 rainbow）都不符——计数要从 TSV 当场 `awk` 出来再写，凭印象写等于再造一个过期源。
- **批量改名别用全串替换**：把 `first_page_no` 换成 `first_page_cell[0]` 时顺手把 `typex_first_page_no` / `typex_set_first_page_no`
  两个**公开函数名**也打坏了（编译报"unexpected token"才发现）——标识符替换要加词边界或先排除 `pub fn` 行；签名是冻结面，改坏就是契约事故。
