# 契约 02 · digest（摘要）

> 状态：**已实现**（10-04，`digest/digest.mbt`，14 条用例全绿）。本页期望值先冻结后实现；
> 冻结过程中确实抓出两处我自己的错：MD5 第六条向量誊错一位（`419c9f`→`419d9f`）、`md5_hex16` 的中段口径需对 v5-master 反推——
> **冻结不等于正确**，它的作用是逼每处改动都拿出外部证据。
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
| `"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"` | `d174ab98d277d9f5a5611c2c9f419d9f` |
| `"1234...7890"` ×8（80 字符） | `57edf4a22be3c955ac49da2e2107b67a` |
| `"中文"` | `a7bac2239fcdcb3a067903d8077c4a07` ← **UTF-8 档**，非 UTF-16/GB18030 |

hutool 对位 `DigestUtil.md5Hex` ｜ 差异：hutool 可传 `Charset`，本库固定 UTF-8（无字符集表，见 `docs/ROADMAP.md` 的「不做」列）｜ 读数来源：RFC 1321 A.5。

## 2.1.1 `md5_of_bytes(data : Bytes) -> Bytes` —— 任意字节流的 MD5 入口

`md5_bytes` 吃 `String`（内部固定按 UTF-8 编码），但有一类输入**不是任何字符串**：多段拼接出来的流、含 `0x00` 的原始字节、非 UTF-8 序列。`id.uuid_v3` 要的正是 `namespace 字节 ‖ name 字节` 这种拼接流（见 `docs/spec/04-id.md` #3.3），所以补这个字节版入口——**算法同一个**，只是入口的输入域放宽。

| 输入 | 期望 | 说明 |
|---|---|---|
| `utf8("abc")` | `900150983cd24fb0d6963f7d28e17f72` | 与 2.1 的 `"abc"` 同值（对拍：`md5_of_bytes(utf8(s)) == md5_bytes(s)`） |
| `utf8("中文")` | 与 `md5_bytes("中文")` 相等 | 对拍断言，不重复抄绝对值 |
| DNS namespace 字节 ‖ `utf8("www.example.com")` | `5df418813aed051548a72f4a814cf09e` | 拼接流；这条就是 `uuid_v3(dns, "www.example.com")` 的**未改位**原值（改 version/variant 后是 `5df41881-3aed-3515-88a7-2f4a814cf09e`） |
| 原始字节 `0x00..0x0f` | `1ac1ef01e96caf1be0d329331a4fc2a8` | 含 `0x00`，`String` 入口进不去的那一档 |

hutool 对位 `Digester.digest(byte[])` ｜ 读数来源：RFC 1321 同一批向量 + 本机 `hashlib` 现算 ｜ 血统：无（纯算法入口，不涉及 Java 表达）

## 2.1.2 `sha256_of_bytes(data : Bytes) -> Bytes` —— 任意字节流的 SHA-256 入口

与 2.1.1 同一条理由，另一侧也成立：`sha256_bytes` 吃 `String`，而有一类输入**不是任何字符串**。
`codec.b58_check_encode/decode` 的校验位定义就是对 `version ‖ payload` 这串**二进制**做双 SHA-256
（见 [`docs/spec/05-codec.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/05-codec.md) #4），
走 `String` 入口根本进不去。这条腿原本已作为私有 `sha256_raw` 存在于 HMAC 内部，本轮提升为公开入口——
**算法同一个**，只是输入域放宽。

| 输入 | 期望 | 说明 |
|---|---|---|
| `utf8("abc")` | `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad` | FIPS 180-4 的 `"abc"` 样例，与 `sha256_hex("abc")` 同值（对拍） |
| `utf8("中文")` | 与 `sha256_bytes("中文")` 相等 | 对拍断言，不重复抄绝对值 |
| `utf8("")` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | 空流样例（FIPS 180-4） |
| 原始字节 `0x00..0x0f` | `be45cb2605bf36bebde684841a28f0fd43c69850a3dce5fedba69928ee3a8991` | 含 `0x00`，`String` 入口进不去的那一档 |
| `0x00 ‖ hash160(sha256("mldong"))` 的**双摘要** | `1691915ba1e735a0da235d3de9484308bc5a388ba782fba717f2ba768e26bcdc`（前 4 字节 `1691915b` 即 Base58Check 校验位） | `codec` 的夹具腿：payload 是 `2d73f6a4885ce62118417eb73fb405a0539efa21`，地址读数冻在 05-codec #4 |

hutool 对位 `Digester.digest(byte[])` / `DigestUtil.sha256(byte[])` ｜ 读数来源：FIPS 180-4 样例 + 本机 `hashlib` 现算 ｜ 血统：无（纯算法入口）

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
⚠ 键的字节解释固定为 **UTF-8**；需要原始二进制密钥（如 JWT 的 32 随机字节）的调用方走 `_of_bytes` 档——
初稿那句"此刻不放公开骨架——先证明需要再加"**已在第二批兑现**（证明来自 `id.uuid_v5`/JWT 那类裸字节密钥与 RFC 4231 全套裸字节向量），见 §2.7。

## 2.5 `equal_digest(a : Bytes, b : Bytes) -> Bool`

常量时间比较：先比长度再逐字节异或累积，**不许短路**（`Bytes` 的 `==` 是逐字节短路，签名校验会泄露前缀时序）。

| 用例 | 期望 |
|---|---|
| `equal_digest(md5_bytes("abc"), md5_bytes("abc"))` | true |
| `equal_digest(md5_bytes("abc"), md5_bytes("abd"))` | false |
| `equal_digest(md5_bytes("abc"), md5_bytes(""))` | false（长度不等即假） |

hutool 对位：无（hutool 直接用 `equals`）⇒ **本库主动加的一条安全件**，属"契约形状"而非移植；读数来源：owner 拍板 + OWASP 时序比较惯例。

## 2.6 第二批：HMAC 家族（MD5 全套 + 裸字节键 + verify，10-05）

八个公开项，签名以 `digest/pkg.generated.mbti` 为准：

| 项 | 签名 | 对位 hutool | 说明 |
|---|---|---|---|
| `hmac_md5_bytes` | `(String, String) -> Bytes` | `HMac(HmacMD5, String key)` | 键/数据固定 UTF-8 取字节 |
| `hmac_md5_hex` | `(String, String) -> String` | `HMac#digestHex` 的 MD5 档 | 小写十六进制 |
| `hmac_md5_of_bytes` | `(Bytes, Bytes) -> Bytes` | `HMac(HmacMD5, byte[] key)` | 裸字节键——RFC 4231 全套向量都是这一档 |
| `hmac_md5_hex_of_bytes` | `(Bytes, Bytes) -> String` | 同上 + `digestHex` | |
| `hmac_sha256_of_bytes` | `(Bytes, Bytes) -> Bytes` | `HMac(HmacSHA256, byte[] key)` | 与 §2.4 的 `String` 档同一张嘴，只放开键的编码假定 |
| `hmac_sha256_hex_of_bytes` | `(Bytes, Bytes) -> String` | 同上 + `digestHex` | |
| `hmac_md5_verify_hex` | `(Bytes, Bytes, String) -> Bool` | `HMac#verify(byte[] expected)` 的十六进制形态 | 比较走 §2.5 `equal_digest` |
| `hmac_sha256_verify_hex` | `(Bytes, Bytes, String) -> Bool` | 同上 | |

四条口径：

1. **两台机器合成一台**：MD5 与 SHA-256 的 HMAC 共用同一个私有 `hmac_of(hash, key, data)`，`hash` 传 §2.1.1/§2.1.2 的**字节进字节出**那一档 ⇒ 不存在第二份 pad/xor 实现。块长恒 64（两把摘要相同），键长 > 64 先把键哈希一次，短键**右侧补零**。
2. **`String` 档固定 UTF-8**。这里踩过一次：`String::to_bytes()` 打的是 **UTF-16 小端码元**（core `builtin/string.mbt`，已标废弃），连 ASCII 都摊成 2 字节，任何输入都错。
3. **verify 无错误档**：十六进制按标准解（大小写都收）；奇数长度或含非十六进制字符 ⇒ 解出空字节、长度必然不等 ⇒ 判假。不返回"格式错"这一档，因为调用方拿到的答案都是"不是这条 MAC"。
4. **空密钥档不承诺**：参照腿 JDK 在 `keylen=0` 直接抛 `IllegalArgumentException`（HMAC 的 RFC 也不给空键向量）⇒ 本包不钉这一档的期望值，也不声称与谁一致。

**读数腿**（`jdk_hmac.txt`，22 条十六进制读数 + 键长/数据长度元数据，脚本灌进用例，手打 0 条）：

| 腿 | 来源 | 条数 | 备注 |
|---|---|---|---|
| A 参照实现 | 本机 JDK 17.0.14 `javax.crypto.Mac`（HmacMD5 / HmacSHA256） | 11 夹具 × 2 算法 = 22 | 键长 1/20/25/64/65/100/131 + 空数据 + `key`/`what do you want for lunch today` + 中文 UTF-8 + 含 `0x00`/`0xff` 裸字节 |
| B 官方交叉 | RFC 4231 Case 1 | 1 | 腿 A 的 `key-20` SHA-256 读数与官方向量 `b0344c61…cff7` **逐字符相同** ⇒ "只认官方向量"的规矩（门禁 G6）在这批上成立 |

分界覆盖是这批的核心：`keylen=64` 与 `keylen=65` 一条在"不哈希键"一侧、一条在另一侧，两条都必须钉住（变异 A 就是靠这两条抓的）。

**三条实测更正/事实**：

1. **参照腿自己被编码坑了一次**（这条是本批最值钱的一条，因为它教训的是"权威腿"）：首跑时 `javac` 用平台默认编码（GBK）读了 UTF-8 的 `.java`，中文夹具落成 mojibake——读数文件里 `keylen=10, datalen=18` 就是自证（正确 UTF-8 应为 `7/12`，`密钥K` = 3+3+1、`中文数据` = 4×3）。改 `javac -encoding UTF-8` 重跑，22 条里**只有这 2 条变**，其余 ASCII 夹具逐字节相同；本包实现值与 Python `hmac` 同读 ⇒ 病灶在参照腿不在实现。做法上的规矩由此加一条：**参照腿含非 ASCII 字面量时必须显式 `-encoding UTF-8`，且读数文件要带 `keylen/datalen` 这类能自证编码的字段**。
2. **实现初稿用 `to_bytes()` 把已绿的文档块拖红**：委托到 `_of_bytes` 时顺手把编码写错，7 条红里包含 `digest/README.mbt.md` 的 RFC 4231 TC2——那条此前是绿的（原实现内联 `@utf8.encode`）。教训：**改已有公开项的实现要连它旧的正例一起看**，不能只数新增用例。
3. **verify 的大写档**：签名注释初稿写"不做大小写归一，给大写就判假"，实测十六进制解码器收 `A-F`（任何标准 hex 解码都收），大写串验得过。**按实现改注释、不改实现**——拒绝大写对调用方是脚坑（别处贴来的 MAC 常常是大写）。

**变异对照**（四条逐条有块红，全部 sha256 断言还原到变异前字节）：

| 变异 | 红块数 | 抓它的用例 |
|---|---|---|
| A 丢掉"键长 > 块 ⇒ 先哈希键" | 4 | 键长 100/131 两档（MD5、SHA-256 各二）+ §2.4 长键那条 |
| B 短键改成左侧补零 | 7 | 全部短键档（1/20/25/64…）+ RFC 4231 TC2 |
| C ipad/opad 对调 | 7 | 同上，一把都不剩 |
| D `equal_digest` 退化成只比长度 | 3 | §2.5 三条 + verify 的"改一个字符判假"两条 |

**`mac` 包（ROADMAP 第 13 行）判不建，内容落在这批**：`HMac` 在 **hutool-crypto** 而不是 hutool-core（本机 `javap -cp hutool-core-5.8.35.jar cn.hutool.crypto.digest.HMac` 找不到类，而 `ReUtil`/`Validator` 都在 core），它是**有状态对象**——7 个构造器 + `update(...)`/`digest()`/`digestHex()`/`verify(...)`，`update` 那半属于"流式/增量摘要"，早已在 §2.7（相位与不承诺）的暂不做档；剩下的"一次性算完"薄薄一层，全部已由上表八件覆盖 ⇒ 再开一个 `mac` 包只会造出 `digest` 的第二张嘴。**结论：不建 `mac`，签名口径记在这里。**

## 2.7 相位与不承诺

| 项 | 相位 | 说明 |
|---|---|---|
| `md5*` / `sha256*` / `hmac_sha256*` / `equal_digest` | **P1（见 ROADMAP）** | 登录口令列、签名、消息校验的最小集 |
| HMAC 家族八件（`hmac_md5*` / `*_of_bytes` / `*_verify_hex`） | **已实现（第二批，10-05，§2.6）** | 与 P1 同一张嘴，只是放开"键必须是文本"的假定 |
| `mac` 独立包（ROADMAP 第 13 行） | **判不做，内容并入 §2.6** | `HMac` 在 hutool-crypto 且是有状态对象；一次性用法已由八件覆盖 |
| `sha1*`（含 UUID v5 依赖）、`sha512*` | P6 | 官方向量同法冻结后再实现 |
| `sm3`、`ripemd160`、`sha3/keccak` | `docs/ROADMAP.md` 的「暂不做」档 | 国密合规出口 / 需要新算法工程 |
| `Digester`（salt + saltPosition + digestCount 迭代） | P6 | hutool 私有行为，期望值全量对 v5-master 反推后才进契约 |
| AES / RSA / EC / BCrypt / Argon2 / PBKDF2 | `docs/ROADMAP.md` 的「暂不做」档不排期 | 非对称要自写 `gcd`/`mod_inverse`（core 无）+ ASN.1 DER |
| 流式/增量摘要（`Digest` 对象一次喂一块） | `docs/ROADMAP.md` 的「暂不做」档 | core 无 io；本库不做带状态的写接口 |
