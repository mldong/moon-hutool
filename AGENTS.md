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

- `.mbt` 里写 `import` 非法：`Invalid import declaration here. Move this declaration to moon.pkg`；测试专用依赖写在包的 `moon.pkg` 里 `} for "test"`。
- `String` 字面量**不隐式转** `StringView`，且 `String` **没有** `as_view` ⇒ 对外 API 用 `String`。
- `\u{...}` 只在 char 字面量合法，写进字符串会成插值 ⇒ `Lexing error: missing expression in string interpolation`。
- `Array<StringView?>` 这种尖括号内的可选类型解析失败 ⇒ 用 `Array[Option[String]]`。
- 骨架函数体里 `let _ = (a, b)` 是消 `unused_value` 警告的必要动作（零警告是门禁），实现落地后随函数体消失。
- 用例首选 `assert_eq`；`inspect` 对集合走 `Show` 会吃废弃警告（core 立场：结果确定的用例用断言）。
- `moon.mod` 是 TOML：注释用 `#`，`//` 会解析失败；`moon fmt` 会把 `[]` 写成 `[ ]`，改字段前先跑 fmt。

### 工具链

`moon check` / `moon test` / `moon fmt --check` / `moon info`（`.mbti` 必须提交，`moon info` 后 `git diff --quiet -- '*.mbti'` 即接口漂移检查；`moon info` **没有** `--check`，只有 `--dry-run`）/ `moon bundle --all` / `moon coverage`。
