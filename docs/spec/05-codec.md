# 契约 05 · codec（编码解码）

> 状态：**已实现**（10-05）——24 条用例全绿，wasm / js / wasm-gc 三档读数一致，native 档由 CI 出证，
> 且 `moon info` 后 **`.mbti` 零漂移**（实现没动任何公开签名）。实现在 `codec/codec.mbt`，
> 公开接口在 `codec/pkg.generated.mbti`，期望值在 `codec/codec_test.mbt` 与 `codec/README.mbt.md`。
> 改任何期望串须单独一笔并给外部读数来源（门禁 G5）：本轮实现前动过一条——`MZXWE1==` 的非法字符
> 下标从 4 改成 5，判据就是逐位数（M0 Z1 X2 W3 E4 **1=5**）。
>
> **本包只做 core 没有的档位**（`AGENTS.md`「与 core 的边界」）：core 的 `encoding/base64` 只有**标准表**
> （`encode(bytes, padding?)` / `decode(text, ignore_whitespace?)` / `decode_lossy`），`encoding/hex` 就是 Base16，
> `encoding/percent` 就是 percent-encoding。所以这三样在本包里**不重新包装**，只出现在对拍腿与「不做」清单里。

## 0. 三条贯穿性规则

| # | 规则 | 为什么 |
|---|---|---|
| 0.1 | **表的来源写死，不接受调用方传表** | Base32/Base58/Base62 的读数完全由表序决定。同一个字节串换一张表就是另一个文本，允许传表等于允许调用方静默改语义；要自定义表请开新包（本库不背这个兼容负担） |
| 0.2 | **解码严格，宽松只在显式命名的档里** | hutool 的 `decode` 一路宽容（大小写混吃、丢空白、补 padding），"看着能用"的解码器会把脏文本一路带到下游。本库默认**严格**：表外字符报错并给**下标**；`b64_decode_lenient` 这种档必须名字里写清楚它宽松在哪、宽到哪一步 |
| 0.3 | **空输入是合法输入** | `encode(b"") = ""`、`decode("") = b""`（Base58Check 除外：长度不足直接 `BadPadding`/`ChecksumMismatch`）。RFC 4648 §10 的官方向量表**第一条就是空串**，所以这条不是"要不要支持"的问题 |

## 1. 错误面

| 签名 | 语义 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 | 血统 |
|---|---|---|---|---|---|---|
| `pub suberror CodecError { IllegalChar(String, Int) BadPadding(String, Int) RadixOutOfRange(Int, Int) ValueOverflow(String) ChecksumMismatch }` | 本包唯一错误面，只携带读数不携带文案 | — | hutool 抛 `DecodeException`/`IllegalArgumentException`（一个包打天下） | `IllegalChar` 携带**输入原文与第一个表外字符的下标**；`ChecksumMismatch` 不带读数——两个 4 字节摘要对人没有信息量，位置也不指向"哪一位被改过" | — | — |

**`BadPadding(input, at)` 的 `at` 只有一个口径**（不写死的话，实现期会各自发明下标）：

| 情形 | `at` 取哪里 | 例 |
|---|---|---|
| 有 `=`，但数量不对或不在末尾 | **那个 `=` 的下标** | Base64 `Zm9vYmFy=`（长度余 1，填充只有 1 个又落在末尾之外）→ `@8`；Base32 `MZXW======`（4 字符配 6 个填充，该配 4 个）→ `@4` |
| 根本没有 `=`，而去掉填充后的长度余数**不可能**来自任何合法流 | **余数段的起始下标**（`len - len % 组宽`） | Base64 组宽 4：`Zm9vY` → `5 - 1 = 4` → `@4`；Base32 组宽 8：`MZXW6Y`（余 6 不可能，合法余数是 `0/2/4/5/7`）→ `6 - 6 = 0` → `@0` |
| Base58Check 解出来不足 4 字节（连校验位都取不出） | `@0` | `1` → `BadPadding 1@0` |

Base32 的合法余数是 `k mod 5` 决定的：1→2、2→4、3→5、4→7、5→0，所以 **余 1/3/6 三档非法**；
Base64 是 1→非法、2/3→合法、0→合法。这两套余数就是"不可能是任何合法流"的判据来源，
不靠实现者自觉（RFC 4648 §10 的向量表逐条覆盖了这几档）。

## 2. Base64（core 只有标准表，本包补三档）

| # | 签名 | 语义 / 读数 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|---|
| 2.1 | `b64_encode_url(data : Bytes, padding? : Bool = true) -> String` | RFC 4648 §5 表 2：`+`→`-`、`/`→`_`；默认带 `=` 填充。`b'\xff\xff\xff'` → `____`；`bytes(range(16))` → `AAECAwQFBgcICQoLDA0ODw==`；`utf8("中文")` → `5Lit5paH`；空 → `""` | 无（恒不失败） | `Base64.encodeUrlSafe(byte[])`（那侧默认**去填充**） | **默认保留填充**（`padding?=false` 才去）——hutool 的默认档无填充，本库默认档有填充，差异写在签名旁边而不是让调用方猜 | RFC 4648 §10 官方向量（CPython `base64.urlsafe_b64encode` 现算，与规范表逐条一致） |
| 2.2 | `b64_decode_url(text : String) -> Bytes raise CodecError` | 2.1 的逆。`____` → `b'\xff\xff\xff'`；`AAECAwQFBgcICQoLDA0ODw==` → `bytes(range(16))` | 含 `+` 或 `/` ⇒ `IllegalChar(输入, 下标)`（url 表不收标准表的这两个字符，混吃是 2.4 的活）；`=` 数量不是 0/1/2 或不在末尾 ⇒ `BadPadding` | `Base64.decode`（那侧 `-`/`_` 与 `+`/`/` 混吃） | hutool 一个 `decode` 通吃两种表 ⇒ 给脏串不会报；本库严格分档，混吃要走 2.4 | 往返恒等 + 对拍腿（见 2.5） |
| 2.3 | `b64_encode_mime(data : Bytes) -> String` | RFC 2045：标准表，**每 76 字符一行、CRLF 结尾、最后一行后也有 CRLF**。512 字节 ⇒ 684 字符 + 9 个 CRLF；首行 `AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4`；`utf8("中文")` → `"5Lit5paH\r\n"` | 无 | `Base64.encodeMime(byte[])` | 行宽固定 76（RFC 2045 §6.8 的推荐上限），**不给参数**——给了参数就等于承诺"任意行宽的 MIME"，那已经不是 MIME 了 | 两套实现互算：手写 76 切行 + CRLF ↔ CPython `base64.encodebytes` 换行归一，逐字节相等 |
| 2.4 | `b64_decode_lenient(text : String) -> Bytes raise CodecError` | 宽松档：`+`/`/` 与 `-`/`_` **都收**，忽略空格与 CR/LF，缺失的 `=` 自己补。`"5Lit5paH"`、`"5Lit5paH\r\n"`、`"5Lit 5paH"`、`"____"` → `utf8("中文")`/`b'\xff\xff\xff'` | 表外字符（`@`、中文等）⇒ `IllegalChar(输入, 下标)`；去掉空白与填充后长度 `mod 4 == 1` ⇒ `BadPadding`（那种长度数学上不可能来自任何 Base64 流） | `Base64.decode`（hutool 的默认档就是这一路） | **这就是 hutool 的默认档，但在这里必须点名 `lenient`**。命名不松绑，调用方就不会以为自己在用严格解码器 | 逐档现算 + 与 2.2 的负向对照（同输入 2.2 报错、2.4 出值） |
| 2.5 | 对拍腿（用例，不是 API） | 不含 `-`/`_` 的文本上，`b64_decode_url` 与 core `encoding/base64.decode` 同结果；`b64_decode_lenient` 与 core `decode(text, ignore_whitespace=true)` 同结果 | — | — | 门禁 G8：包 core 语义的格子必须留一条"core 改了我们就先红" | 同一批样本两条路对跑 |

## 3. Base32（core 完全没有这档）

| 签名 | 语义 / 读数 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `b32_encode(data : Bytes, hex? : Bool = false, padding? : Bool = true) -> String` | RFC 4648 §6 默认表 `ABCDEFGHIJKLMNOPQRSTUVWXYZ234567`、§7 hex 表 `0123456789ABCDEFGHIJKLMNOPQRSTUV`，`=` 填充。官方向量：`""`→`""`、`"f"`→`MY======`/hex `CO======`、`"fo"`→`MZXQ====`/`CPNG====`、`"fob"`→`MZXWE===`/`CPNM4===`、`"foba"`→`MZXWEYI=`/`CPNM4O8=`、`"fobar"`→`MZXWEYLS`/`CPNM4OBI`、`"foo"`→`MZXW6===`/`CPNMU===`、`"fooba"`→`MZXW6YTB`/`CPNMUOJ1`、`"foobar"`→`MZXW6YTBOI======`/`CPNMUOJ1E8======` | 无 | `Base32.encode(byte[])` / `encode(byte[], useHex)` | hutool 的两个档靠两个方法（`encode` / 带 `useHex`），本库合成一个可选参；两档都要冻结读数，否则 hex 档会实现不到 | RFC 4648 §10 的表（CPython `base64.b32encode` 现算）；hex 档另按表序逐字符搬运独立复算一遍，与标准档同形状 |
| `b32_decode(text : String, hex? : Bool = false) -> Bytes raise CodecError` | 上条的逆（大小写**都收**，因为 Base32 表天然不分大小写且现实中常见小写） | 表外字符 ⇒ `IllegalChar(输入, 下标)`；`=` 数量使总长 `mod 8` 落在不可能的余数 ⇒ `BadPadding` | `Base32.decode` | hutool 解码器 `BASE_CHAR='0'` 那套只处理默认表；本库 `hex?` 两档对称 | 往返恒等 + RFC 向量反解 |

## 4. Base58 与 Base58Check（core 无；表里没有 `0OIl`）

| 签名 | 语义 / 读数 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `b58_encode(data : Bytes) -> String` | Bitcoin 表 `123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz`；**前导零字节按个数折成前导 `1`**。`bytes(range(16))` → `12drXXUifSrRnXLGbXg8E`；`b'\x00\x00hi'` → `118wr`；`b'Hello World!'` → `2NEpo7TZRRrLZSi2U`；`b'\xff\xff\xff'` → `2UzHL`；`utf8("中文")` → `2xu16HBbU`；`b''` → `""`；`b'\x00'` → `1` | 无 | `Base58.encode(byte[])` | 一致（这条 hutool 本身也是照 Bitcoin 规范） | **两套独立实现互算**：大数 `int.from_bytes` 反复折半 ↔ 逐字节长除法，全部样本逐条相等；另加反解恒等 |
| `b58_decode(text : String) -> Bytes raise CodecError` | 上条的逆；`1` 前缀折回等长的前导零字节 | `0`/`O`/`I`/`l` 这四个字符**不在表里** ⇒ `IllegalChar(输入, 下标)`（`"0OIl"` 报 `@0`） | `Base58.decode` | 一致 | 同上 |
| `b58_check_encode(data : Bytes, version? : Int = 0) -> String raise CodecError` | `version`(0..255) ‖ data ‖ 双 SHA-256 的前 4 字节，再整体 Base58。夹具 `data = hash160(sha256("mldong")) = 2d73f6a4885ce62118417eb73fb405a0539efa21`、`version=0` → `159LKv1gGepptdXG7coMf6QhdTrgDsG7i2`（34 字符）；`version=0x80` → `taQYMpAZ9k8ya7NMFKS9j9FQC2qRF1Z741` | `version` 不在 0..255 ⇒ `RadixOutOfRange(version, 255)` | `Base58.encodeChecked(version, data)` | 摘要取的是**双 SHA-256 前 4 字节**（Bitcoin 规则），不是 RIPEMD-160；`digest` 包已有 SHA-256 ⇒ 本包不重复实现摘要 | 校验位由 `hashlib` 现算（SHA-256 本身已被 `digest` 的 FIPS 向量钉住）；文本由 `b58_encode` 的两套实现 |
| `b58_check_decode(text : String, version? : Int) -> Bytes raise CodecError` | 解出 payload；给了 `version` 就同时校验首字节 | 长度不足 5 字节（`version ‖ 校验位` 自己就占 5 字节）⇒ `BadPadding(输入, 0)`；校验位不符 ⇒ `ChecksumMismatch`（改末位后的 `…G7i3` 必报这条）；给了 `version` 而不符 ⇒ `IllegalChar(输入, 0)`（版本位不匹配，本质是"这串不属于该命名空间"） | `Base58.decodeChecked(text, withVersion)` | hutool 那侧返回 `(version, payload)` 二元组且靠 `ValidateException`；本库把 version 变成**调用方给的校验条件**，不返回元组——调用方几乎都是"我知道该是哪个版本才来解" | 正反两档现算 |

## 5. Base62（GMP 表；hutool 自带大小写两版表）

| 签名 | 语义 / 读数 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `b62_encode(data : Bytes, inverted? : Bool = false) -> String` | 默认 GMP 表 `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`；`inverted=true` 走大小写互换表 `0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`。前导零字节折成前导 `0`。`bytes(range(16))` → GMP `0SYW7RiJxkEgOGusQGwp` / INV `0syw7rIjXKeGogUSqgWP`；`b'\xff\xff\xff'` → `18OWF` / `18owf`；`utf8("中文")` → `19PTglOr9` / `19ptGLoR9`；`b'\x00\x00hi'` → `006x7` / `006X7`；`b'Hello World!'` → `T8dgcjRGkZ3aysdN` / `t8DGCJrgKz3AYSDn` | 无 | `Base62Codec.encode(data)` / `encode(data, useInverted)` | hutool 出入口是 `byte[]`（编码结果还是字节数组），本库出 `String`——文本形态才是这类表的用途 | 大数折半 + 往返恒等（两套表各跑一遍） |
| `b62_decode(text : String, inverted? : Bool = false) -> Bytes raise CodecError` | 上条的逆；两版表**互不兼容**，用错版读出的是另一个值 ⇒ 不做自动识别 | 表外字符 ⇒ `IllegalChar(输入, 下标)` | `Base62Codec.decode` | 一致（同样不自动识别） | 同上 |

**两版 Base62 表只差顺序、不差字符集**（都是 `0-9` ‖ 字母 52 个）⇒ 同一串文本用错表**不会报错**，会静默给出另一个值——
这正是 `inverted` 必须是显式参数、且不能"自动识别"的理由。`IllegalChar` 在这一档只对**非字母数字**触发
（例：`T8dgcjRGkZ3aysdN+` 报 `@16`）。

## 6. 任意进制 Radix（hutool 的 `RadixUtil` 档）

| 签名 | 语义 / 读数 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `pub let radix_alphabet : String` | 62 字符表，**取 §5 的 GMP 表前缀**：`0-9A-Za-z` | — | `RadixUtil` 的 `BASE_DIGITS`（hutool 那侧表序也是数字、大写、小写） | 表序写死；`radix=36` 用前 36 个字符（`0-9A-Z`），所以 `Z` 合法而 `z` **非法**——这一档最容易在两栈之间漂 | hutool 源码实测的表序 |
| `radix_encode(value : Int64, radix : Int) -> String raise CodecError` | 位权展开，负数出 `-` 前缀：`4096` 在 base36 → `35S`、base58 → `1Ca`、base62 → `144`；`62` base62 → `10`；`61` base62 → `z`；`0` 任何 radix → `0`；`-4096` base62 → `-144`；`Int64::max()` base62 → `AzL8n0Y58m7`；`Int64::min()` base2 → `-1` + 63 个 `0` | `radix` 不在 2..62 ⇒ `RadixOutOfRange(radix, 62)` | `RadixUtil.toRadix(int, radix)` | hutool 收 `int`，本库收 `Int64` 且**明确支持负数**（hutool 那侧对 `Integer.MIN_VALUE` 会翻成正的算）；`min` 取绝对值这一步在 `Int64` 上仍然溢出 ⇒ 走无符号位权展开，读数按上面这条定死 | Python `divmod` 逐条现算 + 与 `radix_decode` 互逆 |
| `radix_decode(text : String, radix : Int) -> Int64 raise CodecError` | 上条的逆（允许一个前导 `-`） | `radix` 越界 ⇒ `RadixOutOfRange`；字符不属于该 radix 的前 `radix` 个表字符 ⇒ `IllegalChar(输入, 下标)`（`"Z"` 在 base36 合法、`"z"` 报 `@0`）；空串或只有 `-` ⇒ `IllegalChar(输入, 0 或 1)`；超出 `Int64` 范围 ⇒ `ValueOverflow(输入)` | `RadixUtil.parseRadix` | 本库**不做** hutool 的 `parseRadix(String, boolean autoFillToRadix)` 那档（溢出自动补位会静默改变值） | 同上 |

## 7. 这一批不含（写清楚，别让读者以为没做就是漏了）

| 格子 | 结论 | 依据 |
|---|---|---|
| `Base16Codec` / `BCD` | **不做** | `Base16Codec` 就是 core `encoding/hex`（换名转发，AGENTS 直接拒）。`BCD` 在 hutool 里**自己标了 `@Deprecated`**，其逻辑是把两个十六进制位打进一个字节（含 `a-f`/`A-F`，奇数长度左侧补 `0`）——语义与 core hex 重合，唯一增量是"奇数长度左补零"这一档，而那是输入清洗问题不是编码问题 |
| `PercentCodec` | **本批不含，另开 PR-A2** | core `encoding/percent` 已有 RFC 3986 的 percent-encoding；hutool 的增量只有 form-url-encoded 档（空格出 `+`、`+` 解回空格），那是**另一套语义**（表单不是 URI），和 `UrlBuilder` 一起定契约更清楚 |
| `UrlBuilder` | **本批不含，另开 PR-A2** | 它是 URL 语法层（拆 scheme/host/port/path/query + 归一化），不是 codec；和 form 档同批 |
| `Caesar` / `Rot` / `Morse` / `PunyCode` / `Hashids` | **不做 / 排后** | `Caesar`/`Rot` 是三行算术（写了就是转发层）；`Morse` 要符号表且无互解需求；`PunyCode` 要 IDN/ACE 全量规则（RFC 3492 的负载因子与上界表）；`Hashids` 依赖随机盐与数字表语义，归 `rand` 之后再看 |

## 8. 血统与来源汇总

| 格子 | 真上游 | 备注 |
|---|---|---|
| Base64 三档 / Base32 两档 | **RFC 4648**（§4–§7、§10 测试向量）；MIME 换行是 **RFC 2045 §6.8** | 期望值由 CPython `base64` 现算——它是同一节的公开实现，且 RFC 4648 §10 的表本身就给了明文-密文对 |
| Base58 / Base58Check | **Bitcoin Base58 / Base58Check**（表序与"双 SHA-256 取前 4 字节"规则）；hutool `Base58` 亦照此 | 无正式 RFC ⇒ 用两套独立实现互算 + 反解恒等把读数钉住，摘要腿靠 `digest` 已冻结的 FIPS SHA-256 向量兜底 |
| Base62 / Radix 表序 | GMP（`0-9A-Za-z`）；hutool `Base62Codec.GMP` / `INVERTED`、`RadixUtil` 同一表序 | 表序不同结果就不同，所以两版表都写进 spec 并逐字符列出，不靠"应该是" |
| `BCD`（不做） | hutool `cn.hutool.core.codec.BCD`（该类上游已 `@Deprecated`） | 结论来自读 hutool 源码本身，不是猜 |
