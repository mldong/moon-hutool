# 第 2 节 · `digest`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 02 行（`digest`）“用例”列的逐字原文。
编号 02 是稳定 ID：与该包契约 `docs/spec/02-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `digest` | `DigestUtil`（MD5 / SHA-256 / HMAC） | **已实现**（10-04 首批 + 10-05 第二批 HMAC 家族八件；20 块全绿，wasm / js / wasm-gc 三档读数一致，`.mbti` 零漂移） | `docs/spec/02-digest.md` | 20 块（`digest_test.mbt` 9 + `hmac_family_test.mbt` 3 + `README.mbt.md` 8 个文档块）；**本行旧读数"7 条 + 6 个文档块"是 codec/id 轮补 `md5_of_bytes`、`sha256_of_bytes` 之前的切片，已按现读替换**。首批 14 条官方向量（RFC 1321 / FIPS 180-4 / RFC 4231）；第二批八件＝HMAC-MD5 全套 + 裸字节键 + `*_verify_hex`，22 条读数由本机 JDK 17.0.14 `javax.crypto.Mac` 灌入（手打 0 条），其中 `key-20` 的 SHA-256 读数与 RFC 4231 Case 1 **逐字符相同**⇒ 官方向量这条权威在第二批仍成立；键长 64/65 两档夹住"要不要先哈希键"的分界。三条实测教训进了 spec §2.6：**参照腿自己踩了 `javac` 默认 GBK**（中文夹具 `keylen=10/datalen=18` 自证，改 `-encoding UTF-8` 后 22 条只这 2 条变）、`String::to_bytes()` 是 **UTF-16 小端**（把已绿的 README 文档块拖红，改委托时要连旧正例一起看）、verify 的大写档**按实现改注释**（hex 解码大小写都收，拒绝大写是脚坑）；`keylen=0` 判**不承诺**（参照腿抛 `IllegalArgumentException`）；四条变异对照逐条有块红（丢长键哈希 4 红 / 左补零 7 红 / ipad-opad 对调 7 红 / 常量时间比较退化 3 红） |
````

---

**10-15 第三批（SHA-1 / HMAC-SHA1，PR-A 契约笔；需求登记：本仓 Issues #1）**

- **需求**：moon-file-storage 二期要接 OSS / COS 原生签名（OSS Signature v1 与 COS 四级 HMAC-SHA1 链），
  签名原语按「基础件归口」约定落本包；UUID v5 对 SHA-1 的依赖同批解掉原语侧，v5 的调用点另案。
- **公开面 8 件**：`sha1_bytes` / `sha1_hex` / `sha1_of_bytes`（与首批 md5/sha256 三件套逐件同形）
  + `hmac_sha1_bytes` / `_hex` / `_of_bytes` / `_hex_of_bytes` / `_verify_hex`（与第二批 hmac_sha256
  族逐件同形）；HMAC 侧接入第二批那台共用 `hmac_of` 机器（第三把摘要），pad/xor 无第二份实现。
- **两级读数先对撞再冻结**：`scripts/gen_sha1_test.py` 内嵌 13 条官方值（NIST 示例文档 SHA1.pdf /
  HMAC_SHA1.pdf + RFC 3174 §7.3 + RFC 2202 §3），跑时先与 Python hashlib/hmac 现算逐条 assert，
  分岔即拒绝出文件。**首跑就拒出过一次实错**：RFC 3174 §7.3 的 Test4 消息曾被误记成另一条 112 字节串
  ——原文是 `"01234567"` 重复 80 次（640 字节，恰为 512 位整数倍），值 `dea356a2…`。
- **HMAC 的 64 恰边界**：RFC 2202 七条只覆盖 <64 与 >64，恰等于 64 档由 NIST 示例补上
  （`00 01 … 3f` 64 字节键）；两套向量的键/数据都是裸字节，用例走 `_of_bytes` 档。
- **本批不承诺**：空密钥档（与第二批同口径）；NIST 的 `keylen=49 / tag=12` 截断案例不取（本包无截断输出）。
- **本笔状态**：`moon check` 0 警告；`moon test --package digest` 现读 **27 = 绿 20 / 红 7**
  （6 条 `sha1_test.mbt` 块 + 1 条 README 文档块，体是 `PR-B：契约骨架` 的 abort），既有 20 条一字未动。
  （契约笔提交前写下的"26 = 绿 20 / 红 6"是 README 文档块加入之前的瞬时读数，落地笔就地更正。）

---

**10-15 第三批（PR-B 落地笔）**：八件骨架红转绿，`moon test --package digest` 现读 **27 条全绿**
（含 README 新增文档块），期望串一条未动（契约笔 `ba46701`）。变异对照 **7/7 全抓红**：六档核内缺陷
（消息表旋转量 / 40~59 段轮函数 / 丢 30 位旋转 / 常数段 / `h4` 初值 / 取字字节序）各打穿全部七条用例；
一档接线缺陷（HMAC 接 sha256）只打穿 HMAC 侧五条 ⇒「算得对不对」与「接没接对」是两把尺子。
变异与还原均在副本目录做、按原始字节 + sha256 校验还原。逐档红位回填 `02-digest.md` §2.8。
