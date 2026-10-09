# 第 2 节 · `digest`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 02 行（`digest`）“用例”列的逐字原文。
编号 02 是稳定 ID：与该包契约 `docs/spec/02-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `digest` | `DigestUtil`（MD5 / SHA-256 / HMAC） | **已实现**（10-04 首批 + 10-05 第二批 HMAC 家族八件；20 块全绿，wasm / js / wasm-gc 三档读数一致，`.mbti` 零漂移） | `docs/spec/02-digest.md` | 20 块（`digest_test.mbt` 9 + `hmac_family_test.mbt` 3 + `README.mbt.md` 8 个文档块）；**本行旧读数"7 条 + 6 个文档块"是 codec/id 轮补 `md5_of_bytes`、`sha256_of_bytes` 之前的切片，已按现读替换**。首批 14 条官方向量（RFC 1321 / FIPS 180-4 / RFC 4231）；第二批八件＝HMAC-MD5 全套 + 裸字节键 + `*_verify_hex`，22 条读数由本机 JDK 17.0.14 `javax.crypto.Mac` 灌入（手打 0 条），其中 `key-20` 的 SHA-256 读数与 RFC 4231 Case 1 **逐字符相同**⇒ 官方向量这条权威在第二批仍成立；键长 64/65 两档夹住"要不要先哈希键"的分界。三条实测教训进了 spec §2.6：**参照腿自己踩了 `javac` 默认 GBK**（中文夹具 `keylen=10/datalen=18` 自证，改 `-encoding UTF-8` 后 22 条只这 2 条变）、`String::to_bytes()` 是 **UTF-16 小端**（把已绿的 README 文档块拖红，改委托时要连旧正例一起看）、verify 的大写档**按实现改注释**（hex 解码大小写都收，拒绝大写是脚坑）；`keylen=0` 判**不承诺**（参照腿抛 `IllegalArgumentException`）；四条变异对照逐条有块红（丢长键哈希 4 红 / 左补零 7 红 / ipad-opad 对调 7 红 / 常量时间比较退化 3 红） |
````
