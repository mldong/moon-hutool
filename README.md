# moon-hutool

MoonBit 版 [hutool](https://github.com/chinabugotech/hutool) 风格工具库。**零第三方依赖**：只依赖随编译器发布的 `moonbitlang/core`。

```toml
# moon.mod（本库无需任何 import 依赖声明）
```

## 状态：骨架 + 契约（实现未开工）

本仓当前处于**文档契约先行**阶段：签名、公开接口（`.mbti`）与期望值已冻结，函数体是 `abort("未实现…")`。

| 读数 | 值 |
|---|---|
| `moon check --target wasm` | 全绿（0 warnings 0 errors） |
| `moon test --target wasm` | **Total tests: 19, passed: 0, failed: 19** —— 每条都停在 `abort`，红就是设计态 |
| 已出契约的包 | `text`（字符串门面）、`digest`（MD5 / SHA-256 / HMAC-SHA-256） |
| 已建目录待出契约 | 21 个包（见 `docs/spec/00-hutool-map.md`） |

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
scripts/contract_gate.sh             # G1~G8 八条判据
```

约定见 [`AGENTS.md`](https://github.com/mldong/moon-hutool/blob/master/AGENTS.md)。

## 许可

Apache-2.0（见 `LICENSE`）。与同作者的 `mldong/moon-token`、`mldong/jeeflow-*`、`mldong/mldong-moon` 保持一致。
