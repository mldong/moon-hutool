# moon-hutool

MoonBit 版 [hutool](https://github.com/chinabugotech/hutool) 风格工具库。**零第三方依赖**：只依赖随编译器发布的 `moonbitlang/core`。

```toml
# moon.mod（本库无需任何 import 依赖声明）
```

## 文档索引

| 要看什么 | 去哪 |
|---|---|
| **进度：哪些实现了、哪些在做、哪些暂不做** | [`docs/ROADMAP.md`](https://github.com/mldong/moon-hutool/blob/master/docs/ROADMAP.md) —— 逐包状态（`已实现`/`实现中`/`契约已冻结`/`未开工`/`暂不做`）+ 用例数 + 不做清单 |
| **hutool 能力对照**（这个类在 MoonBit 侧打谁） | [`docs/spec/00-hutool-map.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/00-hutool-map.md) —— 四列：hutool 类.方法 ｜ core 直接可用 ｜ 本库补 ｜ 不做 |
| **某包的契约表**（签名/边界/差异/读数来源/血统） | [`docs/spec/01-text.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/01-text.md)（text）· [`docs/spec/02-digest.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/02-digest.md)（digest）· [`docs/spec/03-date.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/03-date.md)（date）· [`docs/spec/04-id.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/04-id.md)（id）· [`docs/spec/05-codec.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/05-codec.md)（codec）· [`docs/spec/06-coll.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/06-coll.md) · [`docs/spec/07-mapx.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/07-mapx.md) · [`docs/spec/08-num.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/08-num.md) · [`docs/spec/09-conv.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/09-conv.md) · [`docs/spec/10-re.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/10-re.md) · [`docs/spec/11-valid.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/11-valid.md) · [`docs/spec/12-rand.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/12-rand.md) ——**文件名序号＝该包在 ROADMAP 逐包表里的行号**（稳定 ID，不是排名；G13 守）。**这一行不写状态**：状态只在下面的生成物读数块与 `docs/ROADMAP.md` 里，两处各写一遍必漂（G11 拦这个） |
| **某包怎么用**（可执行示例，跑在 CI 里） | [`text/README.mbt.md`](https://github.com/mldong/moon-hutool/blob/master/text/README.mbt.md) · [`digest/README.mbt.md`](https://github.com/mldong/moon-hutool/blob/master/digest/README.mbt.md) · [`date/README.mbt.md`](https://github.com/mldong/moon-hutool/blob/master/date/README.mbt.md) · [`id/README.mbt.md`](https://github.com/mldong/moon-hutool/blob/master/id/README.mbt.md) · [`codec/README.mbt.md`](https://github.com/mldong/moon-hutool/blob/master/codec/README.mbt.md) · [`coll/README.mbt.md`](https://github.com/mldong/moon-hutool/blob/master/coll/README.mbt.md) · [`mapx/README.mbt.md`](https://github.com/mldong/moon-hutool/blob/master/mapx/README.mbt.md) · [`num/README.mbt.md`](https://github.com/mldong/moon-hutool/blob/master/num/README.mbt.md) · [`conv/README.mbt.md`](https://github.com/mldong/moon-hutool/blob/master/conv/README.mbt.md) · [`re/README.mbt.md`](https://github.com/mldong/moon-hutool/blob/master/re/README.mbt.md) · [`valid/README.mbt.md`](https://github.com/mldong/moon-hutool/blob/master/valid/README.mbt.md) · [`rand/README.mbt.md`](https://github.com/mldong/moon-hutool/blob/master/rand/README.mbt.md)；装好后也能直接在 mooncakes 包页看：[mldong/moon-hutool/text](https://mooncakes.io/docs/mldong/moon-hutool/text) |
| **贡献规范与两条红线** | [`AGENTS.md`](https://github.com/mldong/moon-hutool/blob/master/AGENTS.md)（交付形状、与 core 的边界、期望值冻结、文档三层分工、本机语法坑） |
| **门禁判据 G1~G13** | [`scripts/contract_gate.sh`](https://github.com/mldong/moon-hutool/blob/master/scripts/contract_gate.sh) · CI 见 [`.github/workflows/ci.yml`](https://github.com/mldong/moon-hutool/blob/master/.github/workflows/ci.yml) |

> 本表里的仓内链接一律写成 GitHub 绝对地址：发布包根是模块目录，相对路径在 mooncakes 页面上是死链（这条由门禁 G10 盯着，索引不许漂成死链）。

## 状态

**文档契约先行**：每个包先交"契约表 + 签名 + `.mbti` + 期望值已冻结的用例"，再落实现（实现只许把红变绿）。`moon check --target wasm` 与 `js` 档均 0 警告。

下面这块数字**由脚本当场跑出来**，不手写——手写就要靠人记得改，包一多必漏（详见 `AGENTS.md`「状态数字不手写」）：

<!-- READINGS:BEGIN 由 scripts/sync_status.py 生成，勿手改 -->
| 读数（`moon test --target wasm`，当场跑） | 值 |
|---|---|
| 用例总数 | **432** —— 绿 432 / 红 0 |
| 包状态 | 共 22 个：`已实现` 20 · `契约已冻结` 0 · `未开工` 2 |
<!-- READINGS:END -->

逐包的"哪个实现了、哪个在做、哪个暂不做"看 [`docs/ROADMAP.md`](https://github.com/mldong/moon-hutool/blob/master/docs/ROADMAP.md)——它是进度的唯一真相，且每个真实存在的包都必须在那里有一行（门禁 G11 查这条）。

期望值权威顺序：**契约表 + 测试里的期望值 > hutool 行为 > 直觉**。实现期改期望值必须单独一笔并给出外部读数来源（`scripts/contract_gate.sh` G5 拦改）。

## 零依赖是可验的，不是形容词

四条硬判据，CI 逐条跑：

1. `moon tree --json` 输出里除 `moonbitlang/core/*` 外**零节点**；`moon.mod` 无 `deps`（**`moonbitlang/async` 也算第三方**，本库不许出现）；
2. 全仓 `grep 'extern "'` 命中 0 —— 不写任何 JS/C/WASI 绑定；
3. 全库**同步、无 async** ⇒ 同一份 API 在 `wasm` / `wasm-gc` / `js` / `native` 四档都能编译；
4. OS 能力只走 core 给的两扇窗：`@env.now()`（epoch 毫秒）与 `@env.rand(n)`；时钟与熵**必须可注入**。

推论：文件 IO、网络、HTTP 客户端、字符集码表这类能力**结构上就不属于本库**——它们需要 FFI。（Java 的 `hutool-core` 是 JDK-only，本库是 `moonbitlang/core`-only，定位同构。）

## 为什么不复用生态里已有的包

`moonbitlang/x`（官方实验库，自述 "may change frequently"）与 `moonbitstack/*`、`moonbit-community/flate` 等已经覆盖日期、加密、压缩、UUID 等一大片。本库仍自带实现，唯一理由是**零依赖契约**：传递依赖一旦进入，跨 runtime 的可移植性与版本解耦就不再由我们保证。README 里把这句话写明白，比对第三方做沉默替换更诚实。

## 能力对照与不承诺清单

- **对照表**：[`docs/spec/00-hutool-map.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/00-hutool-map.md) —— 四列：hutool 类.方法 ｜ core 直接可用（打哪条）｜ 本库补（哪类）｜ 不做
- **明确不做**：`BeanUtil`/`ReflectUtil`/`MapProxy`/`aop`/`script`（MoonBit **无运行时反射与动态代理**，Bean 拷贝请走内置 `derive(ToJson)/derive(FromJson)` 或手写映射）；`FileUtil`/`IoUtil`/`NetUtil`/`ThreadUtil`（需 FFI）；`http`/`db`/`socket`/`poi`/`captcha`；`DateUtil` 的智能无格式解析与 `java.text` 全套 pattern；命名时区与 DST；Unicode 大小写；完整 `BigDecimal`；cron **调度器**（只算表达式不触发）
- **移植来源声明**：本项目移植的是 hutool 的**能力与语义**，实现按外部规范（RFC / FIPS）或独立设计重写，**未复制 Java 源码**。hutool 本体为 MulanPSL-2.0；少数类（`CharSequenceUtil`、`date/format/*`、`ComparatorChain`、`AntPathMatcher`）自带 Apache Commons / Spring 上游署名，本库对应格子按 Apache 系处理（见各 spec 的"血统"列）。

## 用法（实现相位可用后）

```moonbit
// moon.pkg —— 只带需要的包
import {
  "mldong/moon-hutool/text" @text,
  "mldong/moon-hutool/digest" @digest,
}

fn demo() {
  assert @text.is_blank("  \t ")
  assert @text.format("id={} name={}", ["7"]) == "id=7 name={}" // 参数不足则原样留
  assert @digest.md5_hex("abc") == "900150983cd24fb0d6963f7d28e17f72" // RFC 1321
}
```

## 开发

```bash
export MOON_HOME=<moon 工具链目录>   # Git Bash 下用 /g/ 之类 POSIX 盘符写法
moon check --target wasm && moon test --target wasm
moon info && moon fmt                # .mbti 是公开接口，diff 即 API 变更评审面
scripts/contract_gate.sh             # G1~G13 十三条判据
```

约定见 [`AGENTS.md`](https://github.com/mldong/moon-hutool/blob/master/AGENTS.md)。

## 许可

Apache-2.0（见 `LICENSE`）。与同作者的 `mldong/moon-token`、`mldong/jeeflow-*`、`mldong/mldong-moon` 保持一致。
