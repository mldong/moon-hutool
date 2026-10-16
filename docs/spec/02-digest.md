# 契约 02 · digest（摘要）

> 状态：**已实现**（首批 10-04 + 第二批 10-05 + 第三批 SHA-1 / HMAC-SHA1 10-15 + 第四批流式/增量入口 10-16；
> 现读 `digest` 包 **38 条全绿**，三档读数一致，变异 6 档里 4 档有块红、2 档如实记为不可观测）。
> 本页期望值先冻结后实现；
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
（**10-16 更正**：上文那句"暂不做档"已被第四批翻案——`update` 那半现在落在本包 `Md5Ctx`/`Sha1Ctx`/`Sha256Ctx` 三件（§2.9），判不建 `mac` 的**结论不变**，理由更新为"`HMac` 独立剩下的只有一次性薄层，而那层已由八件覆盖；可续算那半已有三个 `Ctx` 承接"。原句保留是取数留痕。）

## 2.7 相位与不承诺

| 项 | 相位 | 说明 |
|---|---|---|
| `md5*` / `sha256*` / `hmac_sha256*` / `equal_digest` | **P1（见 ROADMAP）** | 登录口令列、签名、消息校验的最小集 |
| HMAC 家族八件（`hmac_md5*` / `*_of_bytes` / `*_verify_hex`） | **已实现（第二批，10-05，§2.6）** | 与 P1 同一张嘴，只是放开"键必须是文本"的假定 |
| `mac` 独立包（ROADMAP 第 13 行） | **判不做，内容并入 §2.6** | `HMac` 在 hutool-crypto 且是有状态对象；一次性用法已由八件覆盖 |
| `sha1*`（含 UUID v5 依赖） | **已实现（第三批，10-15，§2.8）** | 官方向量＝NIST 示例文档（FIPS 180-4 附录 A.2 指向）+ RFC 3174 §7.3，两处原文互证；UUID v5 的调用点另案 |
| `sha512*` | P6 | 官方向量同法冻结后再实现 |
| `sm3`、`ripemd160`、`sha3/keccak` | `docs/ROADMAP.md` 的「暂不做」档 | 国密合规出口 / 需要新算法工程 |
| `Digester`（salt + saltPosition + digestCount 迭代） | P6 | hutool 私有行为，期望值全量对 v5-master 反推后才进契约 |
| AES / RSA / EC / BCrypt / Argon2 / PBKDF2 | `docs/ROADMAP.md` 的「暂不做」档不排期 | 非对称要自写 `gcd`/`mod_inverse`（core 无）+ ASN.1 DER |
| 流式/增量摘要（`Digest` 对象一次喂一块） | **已实现（第四批，10-16，§2.9）** | **翻案**：原判据写的"core 无 io"挡住的其实是**读流**，不是可续算的状态——取数由调用方负责，本包只给 `update`/`finish` 那一层。ROADMAP 的「暂不做」清单同笔摘掉这一项 |

## 2.8 第三批：SHA-1 与 HMAC-SHA1（10-15）

> 状态：**已实现**（10-15）——八件从契约骨架落地为真实现，**期望串一条未动**（契约笔 `ba46701`）。
> 需求登记：本仓 Issues #1——moon-file-storage 二期要接 OSS / COS 原生签名（OSS Signature v1
> 与 COS 四级 HMAC-SHA1 链），签名原语按「基础件归口」约定落本包；UUID v5 对 SHA-1 的依赖同批解掉原语侧，
> v5 的调用点另案。

公开件八件，签名以 `digest/pkg.generated.mbti` 为准：

| 项 | 签名 | 对位 hutool | 说明 |
|---|---|---|---|
| `sha1_bytes` | `(String) -> Bytes` | `DigestUtil.sha1` | 20 字节；与 §2.3 `sha256_bytes` 同族（大端、同一台虚拟消息机器） |
| `sha1_hex` | `(String) -> String` | `DigestUtil.sha1Hex` | 小写十六进制 40 位 |
| `sha1_of_bytes` | `(Bytes) -> Bytes` | `Digester.digest(byte[])` | 形状与 §2.1.1／§2.1.2 两档同形 |
| `hmac_sha1_bytes` / `hmac_sha1_hex` | `(String, String) -> Bytes` / `String` | `HMac(HmacSHA1, String key)` | 键/数据固定 UTF-8 |
| `hmac_sha1_of_bytes` / `hmac_sha1_hex_of_bytes` | `(Bytes, Bytes) -> Bytes` / `String` | `HMac(HmacSHA1, byte[] key)` | 裸字节键——两套官方向量都是这一档 |
| `hmac_sha1_verify_hex` | `(Bytes, Bytes, String) -> Bool` | `HMac#verify` 的十六进制形态 | 走 §2.5 `equal_digest` 常量时间比较 |

HMAC 五件与 §2.6 的 hmac_sha256 族**逐件同形**，且共用同一台私有 `hmac_of` 机器（第三把摘要接入）——
pad/xor 不存在第二份实现；块长同样 64、长键同样先哈希一次。

### 官方向量（验收只认这批；门禁 G6）

**SHA-1**（`abc` 与 56 字节两分块两条在 NIST 示例文档与 RFC 3174 §7.3 两处逐字相同）：

| 输入 | 期望 | 来源 |
|---|---|---|
| `"abc"` | `a9993e364706816aba3e25717850c26c9cd0d89d` | NIST `SHA1.pdf` One Block Sample／RFC 3174 §7.3 Test1 |
| 56 字节两分块串（`abcdbcde…nopnopq`） | `84983e441c3bd26ebaae4aa1f95129e5e54670f1` | NIST `SHA1.pdf` Two Block Sample／RFC 3174 §7.3 Test2 |
| `"01234567"` × 80（640 字节，恰为 512 位整数倍） | `dea356a2cddd90c7a7ecedc5ebb563934f460452` | RFC 3174 §7.3 Test4（原文按 64 字符块喂十次） |
| `"a"` × 1,000,000 | `34aa973cd4c4daa4f61eeb2bdbad27316534016f` | RFC 3174 §7.3 Test3 |

**HMAC-SHA1**（RFC 2202 §3 全部七条 + NIST 示例两档）：

| 用例 | key | data | 期望 |
|---|---|---|---|
| RFC 2202 TC1 | `0x0b`×20 | `"Hi There"` | `b617318655057264e28bc0b6fb378c8ef146be00` |
| RFC 2202 TC2 | `"Jefe"` | `"what do ya want for nothing?"` | `effcdf6ae5eb2fa2d27416d5f184df9c259a7c79` |
| RFC 2202 TC3 | `0xaa`×20 | `0xdd`×50 | `125d7342b9ac11cd91a39af48aa17b4f63f175d3` |
| RFC 2202 TC4 | `0x01 02 … 19`（25 字节） | `0xcd`×50 | `4c9007f4026250c6bc8414f9bf50c86c2d7235da` |
| RFC 2202 TC5 | `0x0c`×20 | `"Test With Truncation"` | `4c1a03424b55e07fe7f27be1d58bb9324a9a5a04` |
| RFC 2202 TC6 | `0xaa`×80（> 块长 64） | `"Test Using Larger Than Block-Size Key - Hash Key First"` | `aa4ae5e15272d00e95705637ce8a3b55ed402112` |
| RFC 2202 TC7 | `0xaa`×80 | `"Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data"` | `e8e99d0f45237d786d6bbaa7965c7808bbff1a91` |
| NIST 示例（**恰在 64 边界**） | `00 01 … 3f`（64 字节） | `"Sample message for keylen=blocklen"` | `5fd596ee78d5553c8ff4e72d266dfd192366da29` |
| NIST 示例（超块） | `00 01 … 63`（100 字节） | `"Sample message for keylen=blocklen"`（原文如此，不是笔误） | `2d51b2f7750e410584662e38f133435f4c4fd42a` |

- **原文三处**（2026-10-15 现读）：NIST 示例文档 `SHA1.pdf`／`HMAC_SHA1.pdf`（FIPS 180-4 附录 A.2 指向的
  csrc.nist.gov 示例页）、RFC 3174 §7.3 测试驱动、RFC 2202 §3。
- **两级读数先对撞再冻结**：`scripts/gen_sha1_test.py` 内嵌上表 13 条官方值，跑时先与 Python
  `hashlib.sha1`／`hmac.new(sha1)` 现算逐条 assert（13/13），分岔即拒绝出文件；其余读数（空串 /
  中文 UTF-8 / 裸字节流 `0x00..0x0f` / 键长 65 档 / verify 四档）只有现算一条来源，读数文件逐条标注
  provider。首跑当场拒出过一次实错：RFC 3174 Test4 的消息曾被误记成另一条 112 字节串——两级对撞防的
  正是这类「看着像」的誊写。
- **`64` 与 `> 64` 的分界两侧都有官方值**：RFC 2202 只覆盖 `<64`（TC1~TC5）与 `>64`（TC6／TC7），
  恰等于 64 档由 NIST 示例补上（上表倒数第二行）。
- **不承诺两档**（与 §2.6 同口径）：空密钥档；NIST 文档另有 `keylen=49 / tag=12` 的截断案例，
  本包不提供截断输出（对位 hutool `HMac` 也无截断档），故不取。
- **实现取向**（PR-B 落地笔，**10-16 已被第四批取代**：`make_msg`/`pad_word` 随落地笔删除，
  三把摘要改共用一台增量状态机，见 §2.9；下面这段保留是取数留痕，不是现状）：
  `sha1_core` 沿用同一台 `make_msg` / `pad_word` 大端虚拟消息机器
  （零分配；长度域字节序与 SHA-256 同侧），HMAC 走 §2.6 的 `hmac_of`——文件头"四条实现取向"一条没变，
  位运算与常量公式化的既有裁决原样适用。

### 变异对照（PR-B 落地笔回填，2026-10-15；副本变异 **7/7 全抓红**，`moon test --package digest` 读数）

| 变异 | 红位（27 条中） | 判读 |
|---|---|---|
| M1 消息表扩展的旋转量 1→2 | 7 红 | 六条 SHA-1 用例块 + README 块全部当场点名 |
| M2 40~59 段轮函数 maj→parity | 7 红 | 同上——四段轮函数各有一批向量压着 |
| M3 `b`→`c` 丢 30 位旋转 | 7 红 | 同上 |
| M4 常数段取 `t/16`（错段） | 7 红 | 同上 |
| M5 `h4` 初值抄成 `h3` | 7 红 | 同上 |
| M6 padded 取字改小端 | 7 红 | 同上——长度域字节序那条老坑（文件头第 2 条）在 SHA-1 上同样见红 |
| M7 HMAC 接错摘要（sha1→sha256） | 5 红 | 只有 HMAC 四条用例块 + README 块被抓（SHA-1 裸向量不受扰）⇒ **"算得对不对"与"接没接对"是两把尺子** |

怎么读这张表：前六档是**核内**缺陷，任何一条都打穿全部七条用例；M7 是**接线**缺陷，只打穿 HMAC 侧——
红位形状不同，说明这两类判据各自活着，不是同一把尺子量出来的假绿。变异与还原都在副本目录做，
7 档全部按原始字节还原并通过 sha256 校验（工装不入库，读数即本表）。

## 2.9 第四批：流式/增量入口（10-16，需求登记：本仓 Issues #3）

> 状态：**已实现**（12 件骨架全部转为真实现，10-16 落地笔；`moon test --package digest` 现读
> **38 条全绿**，期望串一条未动——`digest/stream_ctx_test.mbt` 与契约笔 `20a432e` 逐字节相同）。

**这条为什么原来挂在「暂不做」，现在为什么做**：§2.7 那行写的判据是"core 无 io"。现读更正——
被 `io` 挡住的是**读流**（自己打开文件、自己推进度），而 issue #3 要的是**可续算的状态**：
调用方手里已经有段（对象存储客户端逐块读），它缺的是一个能把"上一段算到哪儿"接起来的对象。
所以本批只补这一层，不碰取数：`update` 收 `Bytes`，不给 `Path`、不读句柄、不开宿主 API（零依赖四条一条没动）。
`docs/ROADMAP.md` 的「暂不做」清单同笔摘掉这一项。

### 公开面（三个上下文 × 四件 = 12 件，加一个错误档）

签名以 `digest/pkg.generated.mbti` 为准；三把摘要逐件同形，`update` 都 `raise DigestError`。

| 项 | 签名 | 语义 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 / 血统 |
|---|---|---|---|---|---|---|
| `Md5Ctx` / `Sha1Ctx` / `Sha256Ctx` | `pub struct` | 一把摘要的可续算状态（链字 + 不足一组的尾巴 + 长度位 + 已收尾标记） | — | `Digest` / `java.security.MessageDigest` | 字段包内私有：外部只能走 `new()`，构造面只有一处 | 腿 ② |
| `::new()` | `() -> Self` | 建空上下文（链字取各算法 IV） | 无 | `MessageDigest.getInstance` | 不给 `reset`：本类型是**一次消息一个对象**的生命周期，重算请新建（要复用带 `reset` 的形状请看 `hash.Crc32`） | 腿 ① |
| `::update` | `(Self, Bytes) -> Unit raise DigestError` | 追加一段，分块边界由本件自己兜 | `AlreadyFinished`：已 `finish` 还继续喂 | `MessageDigest.update` | **比参照严**：参照侧收尾后随便续算，本包判这一档"默默出一个看着像的摘要"不可接受（issue 点名"不能默默出错值"），选**明确报错**那一档 | 腿 ① |
| `::finish` | `(Self) -> Bytes` | 补 padding 与长度位、压完最后一段，出原始摘要 | 无 | `digest()` | **幂等**：从链字副本算，不改状态，重复调用逐次同值（issue 点名"幂等性请明确写在文档注释里"）；唯一副作用是把上下文标成已收尾 | 腿 ①② |
| `::finish_hex` | `(Self) -> String` | 同上，出小写十六进制（32/40/64 位） | 无 | `digestHex()` | 必须等于 `hex(finish())`，用例把这条对拍钉死 | 腿 ①② |
| `DigestError` | `pub suberror { AlreadyFinished }` | 上面那一档误用的形状 | — | 无（参照不报错） | 一个档就够：本包不给"输入可失败"的错误面 | 本批新增 |

**一台机器，不是三台**：三个 `Ctx` 共用同一个私有 `CtxState`（链字 / 缓冲 / 长度位 `total_lo`+`total_hi` /
`closed`），压缩器按算法传入——与 §2.6 那条"MD5 与 SHA-256 的 HMAC 共用同一个私有 `hmac_of`"同一条取向。
padding 与长度位**只写一份**：本批把一次性入口 `md5_core` / `sha1_core` / `sha256_core` 三台"虚拟 padded 消息"
机器改造成同一台增量机器的两个出口（一次性 = 建上下文 + 喂一次 + 收尾），
所以"分段与整份同值"不是测试碰巧对上，而是**同一条代码路径**。

### 验收判据（issue #3 的三条，逐条有用例）

1. **长度分档跨分组边界**：`0 / 1 / 55 / 56 / 63 / 64 / 65 / 119 / 120 / 1000000` 十档全跑（三把摘要各自）。
   `55/56` 是"padding + 8 字节长度位刚好装得下 / 装不下要两组"的分界，`63/64/65` 是"尾巴长度 0/1"的分界。
2. **分段取 `1..N` 全档**：`N ∈ {55, 64, 65, 120}` 每档从 1 跑到 N；另加**确定性"随机分段"表**四张
   （LCG 生成，长度 9/11/17/23，值域 1..23）——不许依赖宿主熵或时钟，否则三档读数对不齐。
3. **一次性与增量逐字节相等**：三把摘要各一条 `finish() == *_of_bytes(data)`，外加
   `finish_hex() == hex(finish())`。
4. **一百万字节不整份进内存**：MD5 用**一百万次单字节 `update`**，SHA-1 / SHA-256 用 1024 字节段 × 976 + 576；
   SHA-1 那条同时是 RFC 3174 §7.3 Test3 公布值的重放（§2.8 已冻，值 `34aa973c…`）。
5. `finish` 幂等 + 收尾后 `update` 报错：断 `finish` 两次同值，再断之后那次 `update` 走的是错误档而不是新摘要。

### 读数腿（两级，缺一级不出文件）

- ① **官方向量**：全部取本仓已冻结那批（§2.1 RFC 1321 A.5、§2.3 FIPS 180-4、§2.8 NIST 示例 + RFC 3174 §7.3
  含 1M 个 `a`）——**本批不新造任何官方向量**，只把既有向量在增量入口上重放一遍。
- ② **Python `hashlib`**：对同一批夹具分别做"整份现算"与"按 chunk 分段 update 后 `digest()`"，
  两级必须逐字节相等，然后才灌进用例；跨边界六条（`55/63/64/65/119/120`）没有公布值可用，
  provider 一律标 `hashlib`。
- 工装 `scripts/gen_ctx_test.py`，夹具与期望串手打零条，标签两向完备（缺读数停、有读数没被用到也停）。

### 分岔（两侧行为都写）

| # | 分岔 | 参照侧 | 本库 | 理由 |
|---|---|---|---|---|
| 1 | 收尾后再喂 | `MessageDigest.update` 照常续算，下一次 `digest()` 给一个新值，没有错误 | `update` `raise DigestError::AlreadyFinished` | issue 给的两档里选"明确报错"：续算意味着调用方以为自己算的是第一条消息，而拿到的是两条的混合——这类错在对象存储校验上表现为"上传被服务端拒"而不是本地报错 |
| 2 | `finish` 的副作用 | JDK `digest()` 会**重置**内部状态（等于"收尾即重来"） | 不改链字与长度位，只标 `closed`；要重算新建 | 参照那档"收尾顺带重置"让幂等性讲不清（第二次 `digest()` 给的是空串摘要）；本包把"幂等"钉成断言，第二次读数必须与第一次相同 |
| 3 | 空密钥/空消息类比档 | — | 空消息**有值**（`new()` 后直接 `finish()` 给空串摘要） | 与 HMAC 的空密钥档不同，那档参照腿自己抛异常；这一档 RFC 有值 |

### 变异对照（PR-B 落地笔回填，2026-10-16；副本工装，逐档按原始字节 + sha256 还原）

| 变异 | 红块（38 条中） | 判读 |
|---|---|---|
| M1 `update` 丢掉不足一组的尾巴（不缓冲直接丢） | **36 红** | 一次性入口也一起翻——它现在走同一台机器，这正是"只有一份 padding"的代价与收益 |
| M2 长度位只写 32 位（高半恒 `0`） | **0 红** | **不可观测变异**，如实记着：`bits_hi` 只在输入超过 **512 MiB** 时才非零，本套夹具最大一百万字节 ⇒ 写对写错读不出差别。issue 验收要求点名的这一档**在本库现有能力下测不到**，不是测过了 |
| M2′ 长度高半写成"低半重复一遍"（同一行的可观测变体） | **34 红** | 证明那一行本身被跑到、且敢红——M2 的 0 红是夹具量级不够，不是这行没人走 |
| M3 收尾少补一次 padding（`tail == 128` 那档不压第二组） | 8 红 | 既有 §2.1/§2.3 的块也一起红（跨 56 字节界的夹具在一次性入口上就有），说明这条判据两处都活着 |
| M4 `finish` 改原地写链字（幂等被破坏） | 2 红 | 只有"幂等"块与"对拍"块被抓 ⇒ **幂等这条承诺是这两块在守**，别的块守不住它 |
| M5 去掉长度位进位 | **0 红** | 同 M2 一族：`total_lo` 数的是**字节**，进位要 4 GiB 输入才触发。代码留着（长度位算错在任意长消息上都错），但**这一格没有用例覆盖**，是明确欠账 |

两条按本仓规矩必须写进来的更正：

1. **PR-A 那张计划表对 M2 的预测是错的**。原写"长度位只写 32 位 ⇒ `L56` 以上各档 + 一百万字节块抓"，
   现读 0 红。错因是把"长度位算错"当成一类可观测缺陷，没先算"多长才够把高半抬起来"（8 位长度域的高半
   要 2^32 **比特** = 512 MiB **字节**）。⇒ 记进 `AGENTS` 那一族的形状：**写变异先问它能不能改变某个可观测读数**，
   这条在 `dfa`/`cache`/`textsim` 三轮各抓过一次，本轮第四次。
2. M1 与 M3 的红块里**包含既有批次**的用例（§2.1/§2.3/§2.4），这不是回归坏了，而是本批把一次性入口接到同一台
   机器上的直接后果：既有向量从此也在给增量机器站岗。反过来看，这也是"两台机器合成一台"唯一能被验证的方式。
