# 契约 05 · codec（编码解码）

> 状态：**两批都已落地**（10-05）。§2~§6（第一批）与 §7~§8（第二批：form 档 + URL 组件）全部绿，
> 三档（wasm / js / wasm-gc）读数一致、`moon info` 后 `.mbti` 零漂移；第二批实现那一笔**期望串一字未改**。
> 实现在 `codec/codec.mbt`，公开接口在 `codec/pkg.generated.mbti`，
> 期望值在 `codec/codec_test.mbt` 与 `codec/README.mbt.md`。
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
| `pub suberror CodecError { IllegalChar(String, Int) BadPadding(String, Int) RadixOutOfRange(Int, Int) ValueOverflow(String) ChecksumMismatch BadUtf8(String) }` | 本包唯一错误面，只携带读数不携带文案 | — | hutool 抛 `DecodeException`/`IllegalArgumentException`（一个包打天下） | `IllegalChar` 携带**输入原文与第一个表外字符的下标**；`ChecksumMismatch` 不带读数——两个 4 字节摘要对人没有信息量，位置也不指向"哪一位被改过"；`BadUtf8` 只带输入不带下标——`%XX` 流解到一半发现不是合法 UTF-8，出错位置在字节层而不在文本下标上，硬给一个位置反而会指错（PR-A2 补的第六个变体，用于 `form_decode`） | — | — |

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

## 7. x-www-form-urlencoded（HTML 序列化器；这是 percent 档之外的真缺口）

core 的 `encoding/percent.encode` 走 **RFC 3986 unreserved**（`A-Za-z0-9-._~`），且空格出 `%20` 而非 `+`——
那是 URI 组件的规矩，不是表单的规矩。表单这一档（`application/x-www-form-urlencoded`）由 HTML 标准定义，
**放行的字符集不同**（数字、大小写字母，外加 `*`、`-`、`.`、`_`；注意 `~` 要转义而 `*` 不转义），
**空格写 `+`、`+` 解回空格**。这四条差异任何一条走错，跨栈拿到的就是另一个值，所以单独一档并点名 `form_`。

| 签名 | 语义 / 读数 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `form_encode(text : String) -> String` | 按 UTF-8 取字节：`A-Za-z0-9*-._` 原样出，空格出 `+`，其余出 `%XX`（**大写**十六进制）。`"hello world"`→`hello+world`；`"中文"`→`%E4%B8%AD%E6%96%87`；`"a=b&c"`→`a%3Db%26c`；`"*-._~"`→`*-._%7E`；`"a+b"`→`a%2Bb`；`"100%"`→`100%25`；`"~!@#$%^&*()"`→`%7E%21%40%23%24%25%5E%26*%28%29`；`""`→`""` | 恒不失败 | `PercentCodec.encode(cs, isFormUrlEncoded=true)` 档 / `HttpUtil.toParams(Map)` | 与 Python `urllib.parse.quote_plus` **不同**：那一档按 RFC 3986 unreserved 放行 `~` 而转义 `*`（`"*-._~"` 它给 `%2A-._~`）——本库跟 HTML/`URLSearchParams`，不跟它 | **两套独立实现互算**：手写 HTML 序列化器 ↔ Node `URLSearchParams` 的序列化，七个样本逐字节相等 |
| `form_decode(text : String) -> String raise CodecError` | 上一条的逆：`+`→空格，`%XX`→字节（十六进制大小写都收），其余原样按 UTF-8 累积字节。`"a%2Bb"`→`"a+b"`；`"n=1+2"` 的值段 →`1 2`；`"%E4%B8%AD"`→`中`；`""`→`""` | `%` 后不是两位十六进制 ⇒ `IllegalChar(输入, %的下标)`；凑出的字节序列不是合法 UTF-8 ⇒ `BadUtf8(输入)` | `PercentCodec.decode` + `HttpUtil.decodeParam` | 与 core `percent.decode_lossy` 的"坏序列换 U+FFFD"不同档：本库**报错**——表单值坏掉通常是上游忘了编码，静默替换会把脏值带进库 | 同上：`URLSearchParams` 的 `get` 反解与 Python `unquote_plus`（+ 本库的坏序列判据）双路 |
| `form_build(pairs : Array[(String, String)]) -> String` | 逐项 `key=value` 用 `&` 连接，键值各走 `form_encode`；**保序、允许重复键**、空数组出空串。`[("a","1"),("b","2")]`→`a=1&b=2`；`[("a","1"),("a","3")]`→`a=1&a=3`；`[("k","")]`→`k=`；`[("","")]`→`=`；`[]`→`""` | 恒不失败 | `UrlQuery.build` / `HttpUtil.toParams(Map)` | 键值都编码（hutool 那侧 charset 为 null 时不编码，是个静默分档）；本库不给"跳过编码"的档 | 逐条按定义算 |
| `form_parse(query : String) -> Array[(String, String)] raise CodecError` | 按 `&` 切项（**空串整体返回空数组**，不是一项），每项按**第一个** `=` 切：没有 `=` 时值为空串；键值各走 `form_decode`。`"a=1&b=2"`→两对；`"t=a%3Db%26c"`→`("t","a=b&c")`；`"k"`→`("k","")`；`"="`→`("","")`；`"a=1&a=3"`→两对同键 | 同 `form_decode` | `UrlQuery.of(String, charset, autoRemovePath, true)` 的解析档 | **不做**"同名键合成数组"那种高级视图（那是 `Map` 层的语义，且各栈实现不同）；给扁平键值对序列，要分组自己 `match` | 往返恒等：`form_parse(form_build(cs)) == cs`（七组夹具） |

## 8. URL 的组件划分、组装与语法归一化（对位 hutool `UrlBuilder` 的 parse/build 档）

hutool `UrlBuilder` 的价值在两处：把一个 URL 串拆成组件（`of(url)`）与再拼回去（`build()`），
外加 path 的 `.`/`..` 段整理。它的 `getSchemeWithDefault`/`getPortWithDefault`/`getPathStr`
那几个"给默认值"的档各自往串里塞东西（补 `http`、path 空时补 `/`），**这些默认值散在 getter 里最容易漂**，
所以本库把它们收敛成一处 `normalize`，并让它**幂等**。

| 签名 | 语义 / 读数 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 |
|---|---|---|---|---|---|
| `pub(all) struct Url { scheme : String, userinfo : String, host : String, port : Int, path : String, query : String?, fragment : String? }` | 七个组件。`userinfo`/`host`/`path` 用空串表示"没有"；`port = -1` 表示未给端口；`query`/`fragment` 用 `None` 表示**连 `?`/`#` 都没有**（与"给了但为空"区分开——这直接影响 `to_string` 的往返恒等） | — | `UrlBuilder` 的字段 + `UrlPath`/`UrlQuery` | 拆成值类型而不是链式 builder：本库全同步、无 null，改一个字段的惯用法是 `Url::{ ...u, host: "x" }` | RFC 3986 §3 的组件定义 |
| `Url::parse(text : String) -> Url raise CodecError` | 按 RFC 3986 §3 的 ABNF 从左到右切：`scheme ":"` → `"//" authority` → path → `"?" query` → `"#" fragment`；`authority` 内 `[userinfo "@"] host [":" port]`。读数：`"http://user@www.example.com:8080/a/b?q=1#frag"` → scheme `http`、userinfo `user`、host `www.example.com`、port `8080`、path `/a/b`、query `Some("q=1")`、fragment `Some("frag")`；`"https://example.com"` → path 空串、`query=None`、`fragment=None`；`"mailto:t@x.com"` → **非 `//` 开头就没有 authority**，`userinfo`/`host` 空、path `t@x.com`；`"urn:isbn:0451450765"` → path `isbn:0451450765`；`"?q=1"` → path 空、query `Some("q=1")`；`"http://example.com/a%2Fb?x=%7E"` → path 原样 `/a%2Fb`（**解析不解码**） | `%` 后不是两位十六进制 ⇒ `IllegalChar`。**端口位的下标口径定死**：端口从 `:` 之后第一个字符起算，遇到非数字就报**那个字符**的下标；空端口（`:` 后直接是 `/` 或结尾）报 **`:` 自己**的下标；全是数字但 `> 65535` ⇒ `RadixOutOfRange(值, 65535)`；authority 给了 `@` 而 userinfo/host 都空同理报出错处 | `UrlBuilder.of(url)` | 不做 IDN/punycode（要表）、不做 percent 解码、不猜缺失的 scheme（那是 `url_of_http` 的活） | 组件切分与 Python `urlsplit` 逐条对跑（含 `mailto`/`urn`/无 scheme 三档）；端口越界档 Python 直接抛 `ValueError`，本库给结构化错误 |
| `Url::to_string(self : Self) -> String` | 有 `query` 就写 `?` 段（哪怕是空串），有 `fragment` 就写 `#` 段；`port >= 0` 才写 `:端口`；`userinfo` 非空才写 `user@`。**parse-then-build 往返恒等**是主判据：上面每一条 `parse` 读数都要求 `to_string` 还原原串 | 恒不失败 | `UrlBuilder.build()` | 与 hutool 不同：它靠三个 `get*WithDefault` 往输出里塞默认值，本库 `to_string` **一个字都不加** | 往返恒等（同一批夹具） |
| `Url::normalize(self : Self) -> Url` | 语法归一：scheme 与 host 转小写；`http:80`/`https:443` 这一档**默认端口省略**；path 走 RFC 3986 §5.2.4 的点段删除；`%XX` 统一大写、落在 unreserved 里的三字节**还原成字符**——**但 `%2E`（点号）例外：不还原**（§6.2.2.2 点过这一档：还原出来的 `.` 会被随后的点段删除当成 `.`/`..` 段吃掉，而原串那一格本是字面段，还原等于改语义）；有 authority 而 path 为空 ⇒ path 归一为 `/`。**幂等**。归一顺序是先 `%XX` 后点段。读数：`HTTP://EXAMPLE.com:80/%7Efoo/a/../b/./c?Q=1#F` → `http://example.com/~foo/b/c?Q=1#F`；`http://example.com/a/b/../.././../x` → `http://example.com/x`；`http://example.com` → `http://example.com/`；`https://example.com:443/` → `https://example.com/`；`http://example.com:8080/` 原样；`http://example.com/a%2fB` → `http://example.com/a%2FB`；`http://example.com/%zz/a` 原样（非法转义**不猜**）；`http://a/%2E%2E/x` 与 `http://a/%2e/b` 原样（点号不还原），`http://a/%7E%2E/b` → `http://a/~%2E/b`（同段里 `~` 还原、点不还原） | 恒不失败 | `UrlBuilder.of(...)` + `UrlPath` 的段整理 + hutool `normalize` 无对应 | **不做**大小写以外的语义归一（末尾斜杠、`index.html` 省略、`http`→`https` 升级都不做，那些会改语义）；query 与 fragment 不重编码 | §6.2.2 的等价对（`%7Efoo` ↔ `~foo`、`Example.com` ↔ `example.com`）＋ §5.2.4 规范自带的两个 worked example（`/a/b/c/./../../g`→`/a/g`、`mid/content=5/../6`→`mid/6`，本实现逐条复现）＋ 幂等断言 |
| `url_of_http(text : String) -> Url raise CodecError` | hutool `ofHttp` 那一档：`text` 不以 `http://`/`https://` 开头（**大小写不敏感**）就补 `http://` 再解析。`"example.com/a"` → scheme `http`、host `example.com`、path `/a`；`"HTTPS://example.com"` → 不补，scheme 归一为 `https` | 同 `Url::parse` | `UrlBuilder.ofHttp(String)` | 命名不含糊：这是"猜测缺失的 scheme"，所以叫 `of_http` 而不是让 `parse` 偷偷做 | 定义即契约 |

**G8 的对拍腿**在这一批挂两条：`form_encode` 的输入不含空格且不含 `+`/`*`/`~` 时与 core
`percent.encode` 同结果；`form_decode` 在纯 `%XX`（无 `+`）输入上与 core `percent.decode` 同结果。
这两条是"新档与 core 既有档在重叠输入上必须一致"的机器判据，不是润色。

## 9. 这一批不含（写清楚，别让读者以为没做就是漏了）

| 格子 | 结论 | 依据 |
|---|---|---|
| `Base16Codec` / `BCD` | **不做** | `Base16Codec` 就是 core `encoding/hex`（换名转发，AGENTS 直接拒）。`BCD` 在 hutool 里**自己标了 `@Deprecated`**，其逻辑是把两个十六进制位打进一个字节（含 `a-f`/`A-F`，奇数长度左侧补 `0`）——语义与 core hex 重合，唯一增量是"奇数长度左补零"这一档，而那是输入清洗问题不是编码问题 |
| `file:///x` 这种"空 host 的 authority" | **不承诺往返** | `Url` 只有七个组件，`userinfo`/`host` 用空串表示"没有"、`port = -1` 表示未给——于是 `file:///x`（authority 存在但 host 为空）与 `file:/x` 在这套模型里**不可区分**，`to_string` 会归一成 `file:/x`。这是**模型的边界不是实现疏漏**：要区分就得再加一个"有 `//`"的布尔位，而那一位的取值组合会把七个组件的等式破坏掉（`has_authority && host == ""` 之类）。本库服务的 http/https 场景一律带 host；真需要 `file:`/`urn:` 的无损往返，就单独提一个"逐字符保留原始串"的类型，别在这一版里偷偷兼容 |
| `PercentCodec` 的 percent 本体 / `UrlBuilder` 的引用解析 | **不做 / 另批** | percent-encoding 的 RFC 3986 档 core 已有（本包只在 §7 做表单那一档）；§5.2.2 的 base+reference 解析是另一套完整算法（另有 §5.4 的向量），要做单独一批 |
| IDN / punycode、`UrlPath`/`UrlQuery` 的链式 builder、`addQuery` 过程式接口 | **不做** | IDN 要 RFC 3492 的表；builder 的"攒参数"用 `form_build(键值对数组)` 效果相同且可测，不必再引入可变链式对象 |
| `Caesar` / `Rot` / `Morse` / `PunyCode` / `Hashids` | **不做 / 排后** | `Caesar`/`Rot` 是三行算术（写了就是转发层）；`Morse` 要符号表且无互解需求；`PunyCode` 要 IDN/ACE 全量规则（RFC 3492 的负载因子与上界表）；`Hashids` 依赖随机盐与数字表语义，归 `rand` 之后再看 |

## 10. 血统与来源汇总

| 格子 | 真上游 | 备注 |
|---|---|---|
| §7 form 档 | **HTML Living Standard 的 application/x-www-form-urlencoded 序列化器**（放行 `A-Za-z0-9*-._`、空格出 `+`） | 不是 RFC 3986、也不是 Python `quote_plus`：三者在 `~` 与 `*` 上不同，spec 里把分歧写死。第二路取 Node `URLSearchParams`（同一序列化器的公开实现） |
| §8 URL 组件与归一化 | **RFC 3986** §3（组件 ABNF）、§5.2.4（点段删除，规范自带两个 worked example）、§6.2.2（语法等价对：%7E↔~、host 小写、默认端口） | hutool 那侧是 `UrlBuilder`/`UrlPath`/`UrlQuery`（内部再靠 JDK `URI`），本库不搬其实现，只把"组件划分 + 组装 + 点段整理"这几档对齐语义 |

| 格子 | 真上游 | 备注 |
|---|---|---|
| Base64 三档 / Base32 两档 | **RFC 4648**（§4–§7、§10 测试向量）；MIME 换行是 **RFC 2045 §6.8** | 期望值由 CPython `base64` 现算——它是同一节的公开实现，且 RFC 4648 §10 的表本身就给了明文-密文对 |
| Base58 / Base58Check | **Bitcoin Base58 / Base58Check**（表序与"双 SHA-256 取前 4 字节"规则）；hutool `Base58` 亦照此 | 无正式 RFC ⇒ 用两套独立实现互算 + 反解恒等把读数钉住，摘要腿靠 `digest` 已冻结的 FIPS SHA-256 向量兜底 |
| Base62 / Radix 表序 | GMP（`0-9A-Za-z`）；hutool `Base62Codec.GMP` / `INVERTED`、`RadixUtil` 同一表序 | 表序不同结果就不同，所以两版表都写进 spec 并逐字符列出，不靠"应该是" |
| `BCD`（不做） | hutool `cn.hutool.core.codec.BCD`（该类上游已 `@Deprecated`） | 结论来自读 hutool 源码本身，不是猜 |

## 11. 第四批补档（10-08，`codec/codec_deep4_test.mbt`）——三条失败通道与三处 RFC 形状档

这批的判据来源与前面几批不同：**URL 族的权威参照是 RFC 3986 本身**（§3.1 scheme、§3.2.2 reg-name、
§5.2.4 点段删除，见 §10 血统表最后一行"本库不搬其实现"），错误下标按 §0 那张 `BadPadding` 口径表。
所以期望是**从写下的契约推导出来的**，然后真跑——推导错了照样会被红样打回（这次就打回了一条，见下）。

7 块覆盖到的九行（codec 未覆盖行 **9 → 0**，本包自此从棘轮清单上消失）：

| 通道 | 夹具 | 依据 |
|---|---|---|
| `:731` Base64 填充后又来非填充字符 | `Zm9v=Y` ⇒ `BadPadding @4`、`Zm9v==Y=` ⇒ `@4` | §0 口径表第一行「那个 `=` 的下标」 |
| `:824` Base32 同一档（**独立的一份代码**） | `MZXW=Y` ⇒ `BadPadding @4` | 同上；两处 raise 只打一处不算另一处覆盖 |
| `:488` authority 只写一个 `@` | `http://@/` ⇒ `IllegalChar @7` | §1 第 109 行「userinfo/host 都空同理报出错处」 |
| `:1060` host 收 sub-delims 全 11 个 | `http://a!$&'()*+,;=b/x` | RFC 3986 §3.2.2 reg-name |
| `:1079` scheme 续字符 `+` `-` `.` 数字 | `ftp+1.2-x://h` | RFC 3986 §3.1 ABNF |
| `:1189`/`:1193` 末段是 `.` / `..` | `http://a/x/y/.` ⇒ `/x/y/`、`http://a/x/y/..` ⇒ `/x/` | §5.2.4 的 2.B / 2.C「留尾斜杠」 |
| `:1206` 相对路径那一支 + `:1177` 空路径 | `mid/content=5/../6` ⇒ `mid/6`；`""` ⇒ path 仍空 | §5.2.4 第二个 worked example 的**相对形状**（原来只挂在绝对路径上跑过） |

**一处推导被真跑打回，记下来防止照抄**：`/x/./../y/.` 当场推的是 `/x/y/`，实测给 `/y/`。
按 §5.2.4 逐步走才看清：`/x` 先出去 → `/./` 折成 `/` → `/../` **把刚出去的 `/x` 撤回** → `/y` 出去 →
`/.` 折成 `/` ⇒ `/y/`。错的是推导不是实现；这一条同时说明"点段删除是**栈操作**，
把 `..` 当字符串替换来推必错"。

变异 7 条（隔离副本，基线先断 0 红、每条还原并字节级复验）：
`C1` 末尾 `.` 不留空段 **1 红**、`C2` 末尾 `..` 不撤回前一段 **1 红**、
`C3` 两处 raise 的 `at` 由 `pad_at` 改成当前下标 **2 红**（两条腿各一，正好证明 :731 与 :824 是两份代码）、
`C4` host 表去掉 `+` **1 红**、`C5` scheme 去掉 `.` **1 红**、
`C6` 空 userinfo 空 host 那档不报错 **1 红**、
`C7` 空路径提前返回改成走点段循环 **0 红 ⇒ 按构造等价**：`path == ""` 时既不是 absolute 也不含 `/`，
循环只把一个空段推进去、`join("/")` 仍是空串 ⇒ 与提前 `""` 同值，那条 `if` 是快路径而非语义档。
这是同日第三条"覆盖到但不可判别"（前两条见 `09-conv.md` §10 的 `X6`、`22-ini.md` §10 的 `M3`）。

## 12. 第五批（10-10 批①）：data URI 组装两件 + `completeUrl` 的改判

契约先行笔（PR-A）：签名 + `.mbti` + 冻结期望 177 条在 `codec/data_uri_test.mbt`，体全是
`PR-B：契约骨架` 的 abort。腿 `scripts/UrlPureLeg.java`（hutool-all 5.8.37 + JDK 17.0.14），
生成器 `scripts/gen_batch1_rest.py`。`encodeBlank` 那 62 条**不在本包**——它的谓词与 `text.is_blank`
同源，收在 `01-text.md` §1.19，归处也写进 `00-hutool-map.md`，别让读者以为 codec 漏了一件。

### 12.1 `data_uri(mime, charset, data)` 与 `data_uri_base64(mime, base64)`

| 件 | 形状（全部现读） |
|---|---|
| `data_uri` | `data:` + mime +（charset 非空则 `;` + charset **原文**）+ `,` + data **原文**。`("text/plain","utf-8","hello world")` → `data:text/plain;utf-8,hello world` |
| `data_uri_base64` | `data:` + mime + `;base64,` + base64 原文。`("text/plain","aGk=")` → `data:text/plain;base64,aGk=` |

四条会被"顺手修正"的形状，都有读数撑着：

1. **数据不编码**。`100%` 就出 `...,100%`，空格、`&`、中文一律原样。它是**拼装器**不是编码器
   （要百分号编码走本包 `Url::normalize` 那一族与 core 的 percent）。
2. **charset 串也不校验**：`GBK`/`gbk`/`nope`/`utf-16` 全照原文带过去（参照没查 charset 表），
   空串 ⇒ 整段 `;charset` 省略 ⇒ `data:text/plain,hi`。
3. **base64 不校验**：`not-base64!!` 照出。给什么串拼什么串。
4. **mime 为空**出 `data:;base64,...`（分号仍在）——参照的空串档如此，不是"省略整段"。

参照的 null 档在腿里打成**字符串 `"null"`**（`getDataUri("text/plain","utf-8",null)` →
`data:text/plain;utf-8,null`，因为它走 `String.valueOf`）；本库 `String` 无 null 档 ⇒ 该形状
不在契约面，也不许"改成空串"——那是替参照决定。

### 12.2 `completeUrl` 为什么改判 deferred（一条"看着是纯串"的读数）

批①开工时把它当纯字符串件列进范围，腿跑完**推翻了这个前提**：`URLUtil.completeUrl(base, spec)`
把"spec 是不是绝对 URL"的判断整个委托给 `java.net.URL` 的**协议处理器**，于是三件事同时成立：

| 读数 | 参照行为 | 为什么不能照搬 |
|---|---|---|
| `data:text/plain,x`、`tel:123`、`urn:isbn:1`、`javascript:alert(1)` | `ERR:UtilException:MalformedURLException: unknown protocol: data` | 抛不抛由 **JDK 内置协议白名单**（http/https/ftp/file/jar/mailto/netdoc）决定，不是由串的形状决定；白名单随 JDK 版本变（腿跑 5.8.37 的 jar，但 handler 表在 JDK 侧） |
| base=`"a"`（无 scheme）+ spec=`"b/c"` | `http://a/b/c` | 参照会**补 scheme**，且补的是 JDK 的默认 handler，不是 RFC 3986 的解析 |
| base=`"a"` + spec=`"./b"` | `http://a/./b`（点段**不归一**） | 而 base=`"http://a.com/api/"` + spec=`"../b"` 又给 `http://a.com/b`（归一了）——同一个函数两套尾巴 |
| base=null | 返回 `null`；spec=null | `ERR:UtilException:...spec is null` | 本库两件 `String` 都无 null 档 |

本包 §8 已经有按 **RFC 3986 §5.2.4** 实现的点段归一（`Url::normalize`，规范自带两个 worked example
都复现），照搬 `completeUrl` 的读数就得在归一之外再造一层"JDK 的半途归一"；不照搬就是**偏离参照**。
两头都不是批①"纯字符串小件"的范围，所以：判 deferred，逐条读数留在
`scripts/UrlPureLeg.java` 的 `C|completeUrl` 共 280 条里，拍板时要不要跟 JDK 的白名单形状，
连同参照那件四参 `getDataUri(String, Charset, String, String)`（第 3 参是**属性段**、
第 4 参才是数据，且 charset 出 `Charset.name()` 的 `UTF-8` 而非传入的 `utf-8`——腿 `D|getDataUri(4)` 五行）
一起拍。

> 本笔附带同一条修正：`getDataUri` 的 charset 为 null 那一档在腿里被印成字面量 `{null}`，
> 生成器把它当合法入参造出断言；现按"本库 `String` 无 null 档"跳过并计数，§12 冻结期望 177 → **150** 条。
