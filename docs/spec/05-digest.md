# 契约 05 · digest（摘要）

> 状态：**签名与官方向量已冻结，实现未开工**（`digest/digest.mbt` 函数体 `abort`，`digest_test.mbt` 7 条用例预期红）。
> **权威是规范文本，不是 hutool**：hutool-crypto 自己几乎不实现算法（是 `javax.crypto`/JCE 门面，全模块只有 RC4/XXTEA/Vigenere 是手写位运算），所以照它的"实现"抄没有意义；本包对着 RFC 1321 / FIPS 180-4 / RFC 2104 写，**验收只认官方向量**（门禁 G6）。
> 输入一律按 **UTF-8 字节**参与运算（对齐 hutool `digest(String)` 的默认 charset；中文用例专门钉死这一档）。
> core 无任何 digest 能力（本机实测 `md5|sha256|hmac` 在全 core 树命中 0）⇒ 整包自研，纯位运算无状态。

## 2.1 MD5

`md5_hex(data : String) -> String`（32 位小写十六进制）、`md5_bytes(data : String) -> Bytes`（16 字节）。

RFC 1321 附录 A.5 全部七条测试串（本机 `hashlib` 现算，与规范公布值逐条核对过）：

| 输入 | 期望 |
|---|---|
| `""` | `d41d8cd98f00b204e9800998ecf8427e` |
| `"a"` | `0cc175b9c0f1b6a831c399e269772661` |
| `"abc"` | `900150983cd24fb0d6963f7d28e17f72` |
| `"message digest"` | `f96b697d7cb7938d525a2f31aaf161d0` |
| `"abcdefghijklmnopqrstuvwxyz"` | `c3fcd3d76192e4007dfb496cca67e13b` |
| `"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"` | `d174ab98d277d9f5a5611c2c9f419c9f` |
| `"1234...7890"` ×8（80 字符） | `57edf4a22be3c955ac49da2e2107b67a` |
| `"中文"` | `a7bac2239fcdcb3a067903d8077c4a07` ← **UTF-8 档**，非 UTF-16/GB18030 |

hutool 对位 `DigestUtil.md5Hex` ｜ 差异：hutool 可传 `Charset`，本库固定 UTF-8（无字符集表，见 `docs/ROADMAP.md` 的「不做」列）｜ 读数来源：RFC 1321 A.5。

## 2.2 `md5_hex16(data : String) -> String` —— hutool/mldong 私有行为

**取 32 位 hex 的第 8~24 位**（即 `hex[8:24]`），不在任何 RFC 里，但被大量项目当短摘要或口令列存储，语义漂移会打散存量数据 ⇒ 期望值必须对 v5-master 反推后冻结。

| 输入 | 期望 |
|---|---|
| `"message digest"` | `7cb7938d525a2f31` |
| `"中文"` | `9fcdcb3a067903d8` |

**口令列常见形状**（契约的一部分，不只是示例）：`md5_hex(salt + password)`，salt 逐用户随机；本表用固定串 `salt123` + `passw0rd` 只钉算法读数 → `96d950b3c3b90997910b05907037133f`。
hutool 对位 `DigestUtil.md5Hex16` ｜ 读数来源：hutool v5-master 实测 + 本机 hashlib 交叉核对。

## 2.3 SHA-256

`sha256_hex(data : String) -> String`（64 位）、`sha256_bytes -> Bytes`（32 字节）。

FIPS 180-4 §6.1/示例消息摘要：

| 输入 | 期望 |
|---|---|
| `""` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `"abc"` | `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad` |
| `"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"` | `248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1` |
| `"中文"` | `72726d8818f693066ceb69afa364218b692e62ea92b385782363780f47529c21` |

长度断言：`md5_bytes("abc").length() == 16`、`sha256_bytes("abc").length() == 32`、`hmac_sha256_bytes("k","d").length() == 32`。
hutool 对位 `DigestUtil.sha256Hex` ｜ 读数来源：FIPS 180-4（本机 hashlib 核对）。

## 2.4 HMAC-SHA-256

`hmac_sha256_hex(key : String, data : String) -> String`、`hmac_sha256_bytes(key : String, data : String) -> Bytes`。

block size = **64 字节**；键长 > 64 ⇒ **先对键做一次 SHA-256** 再做 ipad/opad（RFC 2104 §5，这是实现最容易漏的一档，故单独一条用例）。

| 用例 | key | data | 期望 |
|---|---|---|---|
| RFC 4231 TC2 | `"Jefe"` | `"what do ya want for nothing?"` | `5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843` |
| 键长 80 > 64 | `"a"` ×80 | `"Test Using Larger Than Block-Size Key - Hash Key First"` | `7502d8b2069f64dcbca4d51628fdc86a17200b3fad268755483946baf3d99fa8` |

hutool 对位 `HMac(HmacAlgorithm.HmacSHA256)` ｜ 读数来源：RFC 2104 §5 + RFC 4231 §4（本机 hashlib 核对）。
⚠ 键的字节解释固定为 **UTF-8**；需要原始二进制密钥（如 JWT 的 32 随机字节）的调用方走 `_bytes` 入口的后续扩展档（此刻不放公开骨架——先证明需要再加（别预铺 API））。

## 2.5 `equal_digest(a : Bytes, b : Bytes) -> Bool`

常量时间比较：先比长度再逐字节异或累积，**不许短路**（`Bytes` 的 `==` 是逐字节短路，签名校验会泄露前缀时序）。

| 用例 | 期望 |
|---|---|
| `equal_digest(md5_bytes("abc"), md5_bytes("abc"))` | true |
| `equal_digest(md5_bytes("abc"), md5_bytes("abd"))` | false |
| `equal_digest(md5_bytes("abc"), md5_bytes(""))` | false（长度不等即假） |

hutool 对位：无（hutool 直接用 `equals`）⇒ **本库主动加的一条安全件**，属"契约形状"而非移植；读数来源：owner 拍板 + OWASP 时序比较惯例。

## 2.6 相位与不承诺

| 项 | 相位 | 说明 |
|---|---|---|
| `md5*` / `sha256*` / `hmac_sha256*` / `equal_digest` | **P1（见 ROADMAP）** | 登录口令列、签名、消息校验的最小集 |
| `sha1*`（含 UUID v5 依赖）、`sha512*` | P6 | 官方向量同法冻结后再实现 |
| `sm3`、`ripemd160`、`sha3/keccak` | `docs/ROADMAP.md` 的「暂不做」档 | 国密合规出口 / 需要新算法工程 |
| `Digester`（salt + saltPosition + digestCount 迭代） | P6 | hutool 私有行为，期望值全量对 v5-master 反推后才进契约 |
| AES / RSA / EC / BCrypt / Argon2 / PBKDF2 | `docs/ROADMAP.md` 的「暂不做」档不排期 | 非对称要自写 `gcd`/`mod_inverse`（core 无）+ ASN.1 DER |
| 流式/增量摘要（`Digest` 对象一次喂一块） | `docs/ROADMAP.md` 的「暂不做」档 | core 无 io；本库不做带状态的写接口 |
