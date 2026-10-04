///|
/// moon-hutool —— MoonBit 版 hutool 工具库（**零第三方依赖**：只用随编译器发布的 `moonbitlang/core`）
///
/// 本包是**导航根包**，刻意不放任何公开 API：
/// 根包若 re-export 全部子包，就等于逼用户一次性链接整个库——本库的裁剪单位是**包**，
/// `import { "mldong/moon-hutool/text" @text }` 只带 text 那一层。
///
/// 包 ↔ 能力（相位与理由见 `docs/spec/00-hutool-map.md`、`AGENTS.md`）：
/// - 已出契约：`text`（字符串门面）、`digest`（MD5/SHA-256/HMAC）
/// - 已建目录待出契约：`coll mapx codec id date num conv re valid rand cache hash bloom dfa path cron textsim csv ini typex mac`
