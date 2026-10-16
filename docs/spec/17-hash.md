# 17 · `hash` —— 非密码学哈希与校验和

对位 hutool `cn.hutool.core.util.HashUtil` + `cn.hutool.core.lang.hash.*` +
`cn.hutool.core.io.checksum.{CRC8,CRC16}`（件全在 **hutool-core** 一个 jar 里，`unzip -l` 现读）。
进度状态见 `docs/ROADMAP.md` 第 17 行；本文是这一行契约的唯一真相。

---

## 1. 对位与边界（先划清，再写代码）

`javap` 现读的件清单：`HashUtil` 39 个 `public static`、`MurmurHash` 11 个重载（类内共 14 个方法）、
`CityHash`/`MetroHash`/`KetamaHash`/`Hash32`/`Hash64`/`Hash128`/`Number128`、
`io/checksum/CRC8` + `CRC16` + `crc16/` 十个变体 + 抽象基类 `CRC16Checksum`、
`lang/ConsistentHash`、`builder/HashCodeBuilder`、`codec/Hashids`、`text/Simhash`。

| 处置 | 件 | 理由 |
|---|---|---|
| **本批落地** | `HashUtil` 的字符串/字节非密码学族 21 件、`MurmurHash` 32/64 七个可用重载、CRC8、CRC16 十变体 | 都是纯算术、期望值可从参照腿逐条直读 |
| 第二批（排期） | `HashUtil.murmur128`/`cityHash32/64/128`/`metroHash64/128`、`CityHash`/`MetroHash`/`Number128` | 128 位族要先把 `Number128` 的返回形状定下来（两字 `Array[Int64]` 还是独立记录），与本批 32/64 的形状不是同一件事 |
| 第二批（排期） | `KetamaHash`、`ConsistentHash` | 一致性哈希环是**数据结构 + 哈希**两件事，`ConsistentHash` 依赖 `SortedMap`/虚拟节点，形状要单独评 |
| **不建** | `HashUtil.universal(char[], mask, tab)` / `zobrist(char[], mask, tab)` | 期望值由调用方传入的**随机表**决定（`tab`/`tab[][]` 是入参），没有表就没有可对拍的数；参照实现的 javadoc 也说表要"预先随机生成"——本库不代替调用方造随机表，也不建需要外部表才能定义值的哈希 |
| **不建** | `HashUtil.identityHashCode(Object)` | 就是 `System.identityHashCode`——JVM 内存地址派生值，跨平台不可复现（与 `WeakCache` 同一类判定） |
| **不建** | `builder/HashCodeBuilder` | 多字段组合哈希码是"把若干值喂进一个可累加器"，形状属于 `coll`/`typex` 的相等性面，不属本包；且它产出的是 `java.util.Objects.hash` 式值，跨语言无对拍意义 |
| **不建（另判）** | `codec/Hashids` | **不是哈希**，是可逆编码（salt + 长度 + 字母表 → 短串），归属应到 `codec`；本行只在普查里记一条"待判"，`docs/spec/00-hutool-map.md` 已同步 |
| 不在本包 | `text/Simhash` | 归 `textsim`（ROADMAP 第 20 行），`00-hutool-map.md` 那行已写明 |

与 `digest` 的分工一句话讲清：**`digest` 是密码学摘要**（MD5/SHA/HMAC，输出字节串，有 RFC 验收基准），
**本包是非密码学哈希与校验和**（输出 `Int`/`Int64` 数值，没有标准文档可依，只能对拍参照实现）。
两者件不重叠，本包不含任何 MD5/SHA 变体。

---

## 2. 公开面（第一批 45 件 = 2 枚举 + 2 记录 + 41 函数）

**字符串/字节族（21 件）**：`additive_hash(text, prime)`、`rotating_hash(text, prime)`（这两件 `raise HashError`）、
`one_by_one_hash`、`bernstein`、`fnv_hash`（String）、`fnv_hash_bytes`、`int_hash`、
`rs_hash`、`js_hash`、`pjw_hash`、`elf_hash`、`bkdr_hash`、`sdbm_hash`、`djb_hash`、`dek_hash`、`ap_hash`、
`tianl_hash`、`java_default_hash`、`mix_hash`、`hf_hash`、`hf_ip_hash`。

**Murmur 族（7 件，按语义分名，见 §3 第 8 条的位置陷阱）**：
`murmur32(text)`、`murmur32_bytes(data)`、`murmur32_len_seed(data, length, seed)`、
`murmur32_range(data, offset, length, seed)`、
`murmur64(text)`、`murmur64_bytes(data)`、`murmur64_len_seed(data, length, seed)`。
**64 位没有 offset 档**（javap 现读只有 `(CharSequence)`/`(byte[])`/`(byte[],int,int)` 三个重载），
本库不替参照补这个重载。

**CRC 族（12 件）**：`new_crc8(polynomial, init)` + `crc8_update` / `crc8_update_range` / `crc8_update_byte` /
`crc8_value` / `crc8_reset`；`new_crc16(variant)` + `crc16_update` / `crc16_update_range` / `crc16_update_byte` /
`crc16_value` / `crc16_reset` / `crc16_hex_value(padding)`。
`Crc16Variant` 十档：`Ansi`/`Ccitt`/`CcittFalse`/`Dnp`/`Ibm`/`Maxim`/`Modbus`/`Usb`/`X25`/`XModem`
（对位十个 `CRC16*` 类，`CRC16` 包装器无参构造就是 `Ibm`，读数 `crc16.default_is_ibm`）。

类型口径：hutool 返回 Java `int`/`long`，本库公开面给 **有符号 `Int` / `Int64`**，
与参照腿的十进制读数逐字同形；实现内部 32 位环路走 `UInt`（`digest` 包既有的同一条口径），出口转回有符号。

---

## 3. 语义条目（每条给参照腿读数标签，标签是 §4 腿 A 的行首）

| # | 判据 | 参照读数 |
|---|---|---|
| 1 | `additive_hash`/`rotating_hash` 的第二参是**模数**：`(h & 0x7FFFFFFF) % prime`。`prime == 0` 参照侧直接抛 `ArithmeticException: / by zero`，本库 `raise HashError::ZeroPrime`（同一档错误，换成可枚举的类型） | `rot.0.*` / `add.0.*` 共 16 条 |
| 2 | 同一档的**负数模数**照算（Java `%` 保留符号），本库跟 | `add.neg7.*`、`rot.neg7.*` |
| 3 | `fnv_hash(String)` 走 **UTF-16 码元**（`charAt`），`fnv_hash_bytes` 走**字节**并对字节做符号扩展 XOR。纯 ASCII 时两者同值，非 ASCII 必分岔 | `fnvB_vs_fnvS.abc`（同）、`fnvB_vs_fnvS.digits`（同）、`fnvS.cn\|1995683249` 对 `fnvB.b_cn\|2129874571`（分） |
| 4 | 两档 FNV 末尾都过一遍 `hash += hash<<13; hash ^= hash>>7; …` 的搅拌，最后 `Math.abs`——而 `Math.abs(Integer.MIN_VALUE)` 仍是负数，所以**返回值可以为负** | `fnvS.empty_abs_note\|1494218850 / -2147483648` |
| 5 | `fnvHash` 里的 `>>` 是**算术**右移（符号位保留），而 `int_hash` 用的是 `>>>` 逻辑右移——两族不是一套移位 | `intHash.*` 七条（含 0 / -1 / `Int::MAX` / `Int::MIN`） |
| 6 | `java_default_hash` 就是 `String.hashCode` 的 31 进制展开；`mix_hash` = `hashCode << 32 \| fnv_hash(text)`（两半拼成一个 64 位值） | `javah.*`、`mix.abc\|413837313596157` |
| 7 | `tianl_hash` 在长度 `<= 256` 与 `> 256` 走两个分支；空串直接返回 0 | `tianl.len256`、`tianl.len257`、`tianl.long300`、`tianl.empty` |
| 8 | **位置陷阱**：`MurmurHash` 的三参重载是 `(data, **length**, **seed**)`，四参才是 `(data, **offset**, **length**, **seed**)`。本库按语义分成 `*_len_seed` 与 `*_range` 两个名，把陷阱摆进名字里 | `mmr.hash32.len2seed4\|405956628` 对 `mmr.hash32.off2len4seed0\|973865675`；`mmr.hash32.len_full_seed0_eq_plain\|true` |
| 9 | 偏移档与"先切片再哈希"必须同值（源码用 `offset + …`  indexing，实测成立） | `mmr.hash32.slice_eq\|973865675 vs 973865675` |
| 10 | `MurmurHash` 对 `CharSequence` 先按 **UTF-8** 编码再走字节档（类内 `DEFAULT_CHARSET = CharsetUtil.CHARSET_UTF_8`）；`DEFAULT_SEED = 0`、`DEFAULT_ORDER = LITTLE_ENDIAN` | `mmr.hash32.cs.eq_bytes.abc\|true`、`mmr.hash32.cs.cn` 与 `mmr.hash32.cs.empty\|0` |
| 11 | `HashUtil.murmur32/64` 只是 `MurmurHash.hash32/64` 的**委托**——本库不建两套公开面，一件实现 + 读数对拍等值 | `mmr32.eq.*`、`mmr64.eq.*` 九条全 true |
| 12 | CRC8 **不是标准 CRC-8**：参照实现的表构造是 `remainder = dividend`（没有 `<< 8`），`update` 里 `crcTable[data & 0xff] ^ (value << 8)` 也在 16 位上滑。实测 `poly=0x07, init=0` 对 `"123456789"` 给 **2**，而标准 CRC-8(SAE-J185) 给 **244**（0xf4，本地按标准算式另算）。本库**照参照**（值兼容优先），分岔写进 §5 第 3 行 | `crc8.digits.7_0\|2`、`crc8.abc.7_0`、`crc8.init.*`、`crc8.after_reset.*` |
| 13 | CRC8 的 `update(byte)` 走的是 `update(int)` ⇒ 只取低 8 位；`update(buffer, offset, len)` 与"逐字节喂"必须同值 | `crc8.per_byte_eq.*`、`crc8.range24.*`、`crc8.ff.*` |
| 14 | `crc8_value` 出口是 `value & 0xff`（8 位），`crc16_value` 出口是 `wCRCin` 全值 | `crc8.digits.*`（≤255）与 `crc16.digits.*`（可达 65535） |
| 15 | CRC16 十变体各自钉 `reset` 的初值与多项式，`Ibm` 是 `CRC16` 无参构造的默认；`getHexValue()` 默认**不补零**，`getHexValue(true)` 补到 4 位 | `crc16.init.*`（含 hex 两式）、`crc16.wrap.*`、`crc16.default_is_ibm\|47933/CRC16IBM` |
| 16 | `hf_hash`/`hf_ip_hash` 的和式与哈希质量无关（`hf` 累加 `char * 3 * i`，`hfip` 累加 `charAt(i % 4) ^ charAt(i)`），但它们是参照家族成员，值照对 | `hf.*`、`hfip.*`（`hfip.cn\|0` 就是这条的直白证据） |
| 17 | 空串与空字节是合法输入且各档值不同（不是统一 0） | `add.7.empty\|0`、`fnvS.empty\|1494218850`、`fnvB.b_empty\|1494218850`、`mmr.hash32.cs.empty\|0` |

---

## 4. 参照腿

| 腿 | 载体 | 读数 | 备注 |
|---|---|---|---|
| A 实测 | `hutool-core-5.8.35.jar` + 本机 JDK 17.0.14，`javac -encoding UTF-8` | **398 条**（`hash_ref.txt`），每条 `tag\|值` 可复算 | 夹具：8 个 ASCII 串 + 中文串 + emoji 代理对串 + 9 个字节 blob（含空/0x00/0xff/UTF-8 中文）；CRC16 十个变体逐个喂同一批 |
| B 源码 | `HashUtil.java` 721 行 + `MurmurHash.java` + `CRC8.java` 72 行 + `CRC16Checksum.java` + 十个变体全文 | 移位方向（条目 5）、UTF-16 码元 vs 字节（条目 3）、`(length, seed)` 位置（条目 8）、CRC8 表构造（条目 12）四处只有源码给得出"为什么" | 非 ASCII 夹具在 Java 源里写 Unicode 转义，避免 `javac` 默认编码把字面量打坏（`digest` 轮那条教训的形状） |

---

## 5. 分岔与不跟（两侧读数都留）

| # | 分岔 | 参照侧 | 本库 | 理由 |
|---|---|---|---|---|
| 1 | `prime == 0` | 抛 `ArithmeticException`（不受检） | `raise HashError::ZeroPrime` | 同一档错误，本库要给出可枚举、可断言的形状；读数逐条留档 |
| 2 | `universal`/`zobrist`/`identityHashCode` | 存在 | 不建 | 见 §1 表：外部随机表 / JVM 地址，值不可对拍 |
| 3 | CRC8 的算法本体 | 非标准（`crc8.digits.7_0\|2`） | **照参照**（值兼容优先），标准值 244 只作对照记录 | 本包的定位是"与参照实现同值"，改成标准 CRC-8 会让同名函数在两个库里给不同数；想同时要标准值的人按 §12 的算式自取 |
| 4 | Murmur 重载的形状 | `(data,length,seed)` 与 `(data,offset,length,seed)` 只差一个位置 | 分名 `*_len_seed` / `*_range` | 位置陷阱在同名重载里不可见；分名之后误用变编译错 |
| 5 | `hash64` 的 offset 档 | 不存在 | 不补 | 替参照补重载等于发明值 |
| 6 | 返回值类型 | Java `int`/`long` | `Int`/`Int64` 有符号，与参照十进制读数逐字同形 | 换成无符号就让每个读数多一次换算，对拍反而更易错 |
| 7 | CRC32 的算法本体 | hutool **无对位件**（类面清单现读 `io.checksum` 只有 CRC8 / CRC16 与十个变体）；`java.util.zip.CRC32` 是 JDK 件 | **标准式**（IEEE 802.3 反射位序：`init=0xFFFFFFFF`、末异或同值、查表 `0xEDB88320`） | §3 第 3 行那条"照参照"在这里没有参照可照；七牛 Kodo 的块级校验、gzip / zip / PNG 取的都是标准值，自创一套就等于把同一个数在两个库里打成两个数。与 `Crc8` 的反差就摆在这行，不藏 |

---

## 6. 变异对照（PR-B 那一笔要做够六条，逐条必须至少一块红）

| 变异 | 期待抓住它的块 |
|---|---|
| 把 FNV 的 `Math.abs` 去掉 | 条目 4（含空串与短串那组绝对值断言） |
| 把 `fnv_hash` 的码元迭代改成字节迭代 | 条目 3（中文/emoji 分岔那两条） |
| `int_hash` 的 `>>>` 改成 `>>` | 条目 5（`intHash.-1` / `Int::MIN` 那几条） |
| Murmur 的 `*_range` 里把 `offset` 加成绝对索引 | 条目 8、9（偏移与切片等值那组） |
| CRC16 某变体的 `reset` 初值统一成 0 | 条目 15（十变体初值逐个钉） |
| CRC8 表构造补上 `<< 8`（改成标准式） | 条目 12（`crc8.digits` 给 2 而不是 244） |

写变异先问"它能改变哪个可观测读数"（`dfa` 轮与 `cache` 轮两条等价变异教训并在前）。

---

## 7. 阶段

| 相位 | 状态 | 读数 |
|---|---|---|
| 本文件 45 件公开面 | **已实现**（10-05 三笔：契约 `56c1077` + 文字更正 `c9b5c6d` + 落地） | 10 块 452 条断言全绿，wasm / js / wasm-gc 三档一致；`.mbti` 相对契约笔只前进 `mut` 字段这一档形状（`Crc8.value`/`Crc16.value` 要可写），公开函数签名一字未改 |
| 变异对照 | **五条有块红 + 一条无效** | 去掉 FNV 末尾 `abs` ⇒ 3 红 / 码元档改码位档 ⇒ 3 红 / `int_hash` 的 `>>>` 改算术右移 ⇒ 1 红 / `Ansi` 初值改 0 ⇒ 1 红 / `crc8` 表补 `<< 8` ⇒ 1 红，全部按 sha256 字节还原。**一条无效如实记着**：`murmur32_range` 丢掉 `offset` 会让该参数变成未用而**编译失败**，等于没做成变异；下一轮要挑能改变可观测读数的位置（例如把尾块的 `rem > 0` 改成恒假） |
| 第二批 | 排期 | 128 位族（city/metro/murmur128 + `Number128` 形状）、`KetamaHash`、`ConsistentHash` |
| 第二批·CRC32 | **已实现**（10-16 两笔：契约 `a41726c` + 落地，期望串逐字节未动） | `moon test --package hash` 现读 **20 条全绿**；三档一致（wasm / js / wasm-gc 各 20）；`.mbti` 相对契约笔只前进记录形状一档（`table` + `mut value`），九个公开函数签名一字未改；覆盖率 8 → 2（骨架那六行随实现消失） |

---

## 8. 第二批 · CRC32（需求登记：本仓 Issues #2，10-16）

> **归口改判**：issue 原文把这件写在 `digest` 名下（"digest 现在只有 md5/sha1/sha256，没有 CRC32"）。
> 本轮判落**本包**，三条现读证据：① CRC 族早已在本包（`Crc8` / `Crc16` 两套有状态件，§2 表第 12 组），
> §1 那句分工线写的是"校验和属本包、`digest` 不含任何校验和"；② `digest` 现读 27 件全是无状态一次性入口，
> 把有状态的 `Crc32` 摆进去等于给它开第二张嘴（本仓红线"再开一个包/第二张嘴"的同一条）；
> ③ issue #2 建议的增量形状（`new`/`update`/`value`/`reset`）在本包已有实物可对位，落 `digest` 反而要新造一套。
> 两族的**调用姿势**仍按 issue 的要求对齐：`update` 都是"追加一段、可重复调"，出口都各归各的档
> （CRC32 出数值、摘要出字节）。

**血统**：hutool 没有 CRC32 对位件（类面清单现读），本件属**基础件补位**——先例是 `digest` §2.5 的
`equal_digest`（本库主动加的安全件）。算法权威是 IEEE 802.3 反射位序那族（zlib / GZIP / `java.util.zip.CRC32` 同值），
验收只认官方向量（门禁 G6），分岔记在 §5 第 7 行。

### 公开面（九件 = 一个累加器 + 八件函数）

| 项 | 签名 | 语义 | 边界/错误 | hutool 对位 | 差异声明 | 读数来源 / 血统 |
|---|---|---|---|---|---|---|
| `Crc32` | `pub struct` | 有状态累加器，对外读数 `UInt32` | 无 | 无（JDK `java.util.zip.CRC32` 同形） | 本包 `Crc8`/`Crc16` 同形状 | 腿 C |
| `new_crc32` | `() -> Crc32` | 建空累加器，`crc32_value` 读 0 | 无 | 无 | 参照侧 `new CRC32()` 后 `getValue()==0` | 腿 B/C |
| `crc32_update` | `(Crc32, Bytes) -> Unit` | 追加整段 | 无 | 无 | 分段喂与整份喂逐字节等值 | 腿 B/C |
| `crc32_update_range` | `(Crc32, Bytes, Int32, Int32) -> Unit` | 追加 `[offset, offset+length)` | 无 | 无 | 对位 `update(byte[],int,int)` | 腿 C `*.range`、`offset56` |
| `crc32_update_byte` | `(Crc32, Int32) -> Unit` | 追加一字节（取低 8 位） | 无 | 无 | 对位 `update(int)` | 腿 C `*.perbyte` |
| `crc32_value` | `(Crc32) -> Int64` | 当前值 | 无 | 无 | **无符号 32 位放 `Int64`，恒 `0..4294967295`**（见下"位扩展"） | 腿 A/B/C |
| `crc32_reset` | `(Crc32) -> Unit` | 回到空态 | 无 | 无 | 可重复调，不消耗对象 | 腿 C `after_reset` |
| `crc32_of_bytes` | `(Bytes) -> Int64` | 一次性整份 | 无 | 无 | 名字里的 `of_bytes` 指**入口**吃 `Bytes`（与 `digest` 的 `*_of_bytes` 同形），出口是数值 | 腿 A/B/C |
| `crc32_hex` | `(Bytes) -> String` | 一次性整份 → 八位小写十六进制 | 无 | 无 | **零填充**：空串给 `"00000000"` 而非 `"0"` | 腿 A/B/C |

### 出口位扩展（契约的一部分，最容易在 wasm 档悄悄错的一档）

`crc32_value` / `crc32_of_bytes` 走 `UInt32::to_int64` 的**零扩展**口。症状摆在这里：先降成 `Int32`
再升 `Int64` 时，`"a"` 那条 `0xE8B7BE43`（3904355907，过 2^31）在 wasm 档符号扩展成负读数——
空串与所有低位夹具都看不出错。用例的"出口值域"块把六条夹具全走一遍实现出口，逐条断
`>= 0` 且 `< 4294967296`，同时断 `crc32_hex` 长度恒 8（挡"不补零"那一档）。

### 官方向量与三级读数腿

| 夹具 | 期望（十进制） | 十六进制 | 长度 | 来源 |
|---|---|---|---|---|
| `""` | 0 | `00000000` | 0 | 腿 A（公布值）+ B + C |
| `"a"` | 3904355907 | `e8b7be43` | 1 | 腿 A + B + C |
| `"123456789"` | 3421780262 | `cbf43926` | 9 | 腿 A（该族标准 CHECK 常数）+ B + C |
| `"The quick brown fox jumps over the lazy dog"` | 1095738169 | `414fa339` | 43 | 腿 A + B + C |
| `utf8("中文")` | 1510599991 | `5a09ed37` | 6 | 腿 B + C |
| 裸字节 `0x00..0x0f` | 3469664904 | `cecee288` | 16 | 腿 B + C |
| `'a'`×55 / 56 / 63 / 64 / 65 / 119 / 120 | 2866799438 / 2037976375 / 1747240414 / 2310301013 / 4081037149 / 1095035822 / 3650647111 | — | 见左 | 腿 B + C（长度分档） |
| `'a'`×1,000,000 | 3693461436 | — | 1000000 | 腿 B + C（分块喂，不整份进内存） |
| `'a'`×10,000 | 现算入用例 | — | 10000 | 腿 B（次数档） |

- **腿 A 官方向量**：CRC-32 族（IEEE 802.3 / zlib / PKZIP 同族）公布的 check 值与三条常用样例。
- **腿 B 独立实现**：Python `zlib.crc32` 现算全部夹具，与腿 A 逐条 `assert` 相等。
- **腿 C 参照实现**：JDK 17.0.14 `java.util.zip.CRC32`（`scripts/Crc32Leg.java`，`javac -encoding UTF-8`），
  三条入口 `update(byte[])` / `update(byte[],int,int)` / `update(int)` 各自跑同一批夹具，与腿 B 逐条相等。
- **三级不齐就拒绝出文件**（工装 `scripts/gen_crc32_test.py`，夹具与期望串全走脚本、手打零条；
  字节夹具一律 `s.encode("utf-8")` 现算——`hash` 轮那条"字节夹具不许手打"的形状）。
- **形状读数**：`offset56`（从 120 字节夹具取 `[7, 63)`）与 `rep56` 同值、`after_reset` 与 `empty` 同值，
  这两条是腿自己给的等值判据，脚本会先 assert 再生成用例。

### 分段判据（issue 验收要求第 2 条）

分段长度取 **`1..N` 全档**而不是挑两档：`"123456789"`（1..9）、裸字节流（1..16）、fox（1..43）、
`'a'`×120（1..120）、`'a'`×65（1..65），每条都要求与整份读数逐字节等值。

### 不承诺

- 不提供 CRC-32C（Castagnoli）与 `crc32d` 等变体档——七牛 Kodo / gzip / zip / PNG 用的都是 IEEE 反射位序，
  要变体时按 `Crc16Variant` 那档形状另立契约，不在本批悄悄放宽多项式。
- 不做 `Checksum` 通用抽象基类（同 `CRC16Checksum` 的 `excluded` 判定：本库用记录 + 方法承接，无基类对位面）。
- 不提供 `String` 入口（CRC 不关心文本解释；要摘要文本就 `crc32_of_bytes(@encoding/utf8.encode(s))`，
  本包不给"按哪个字符集"这一档发明默认值）。
- 空输入档**有值**（`0` / `"00000000"`），与 `HMac` 的空密钥不同——这一档三级腿都给得出读数。

### 实现取向（PR-B 落地笔）

- **对外存的是已取反的读数**，`crc32_update_range` 进循环前异或一次、出循环再异或一次。这样
  `new_crc32` 的初值自然地写成 `0`（与 `java.util.zip.CRC32` 的 `getValue()` 同形），寄存器态
  `0xFFFFFFFF` 只在循环里出现，分段续算不需要额外的"是否首段"标记。
- **256 项表随累加器建一次**（`Crc32.table` 字段，与 `Crc8` 同形），不在每次 `update` 里重建——
  本批的夹具有一万段单字节喂与一百万字节分块喂两档，逐次建表会把这些用例变成建表基准测试。
- **环路全走 `UInt32`**：`digest` 包头那条"js 档 `Int` 只有 31 位语义"在这里同样适用，
  所以取字节用 `Byte::to_uint`、索引处一次 `reinterpret_as_int`，中间不做有符号运算。
- 十六进制出口从高位起逐 nibble 取（`hex_of_u32`），不走 `hex_of_u16` 那条"除 16 再倒序"的路——
  那条要为"恒八位补零"和零值各加一个分支。

### 变异对照（PR-B 落地笔回填，2026-10-16；副本变异 **4/4 全抓红**，各 9 块）

| 变异 | 红块（20 条中） | 判读 |
|---|---|---|
| M1 建表去反射（低位判定改高位、右移改左移） | 9 红 | 官方向量 / 非文本夹具 / 长度分档 / 三段分段全档 / 一百万字节 / 区间档 / 逐字节档 / reset 全部当场点名 |
| M2 去掉进循环前的取反（等于寄存器从 0 起算） | 9 红 | 同上 |
| M3 删掉末异或（直接返回寄存器态） | 9 红 | 同上——`""` 那档从 0 变 4294967295，`>= 0` 与 `< 2^32` 两条界都还成立，所以挡住它的是公布值而不是值域 |
| M4 段界写错（每段丢掉最后一个字节） | 9 红 | 同上——这条专挡"分段续算"，一次性入口因为只喂一段所以照对，是**分段全档那三块**把它抓出来的 |

怎么读这张表：四档红位形状相同（都是 9 块），因为 CRC32 只有一条环路——任何一处坏，所有喂法都出同一个错值。
唯一没被抓的第三块是"出口值域"块，它是**位扩展那把尺子**（断 `>=0`、`<2^32`、hex 恒八位），
不参与算法对错；把它单独摆着的原因是 M2/M3 那两类缺陷在别的库里常以"负读数"出现，而本件不会。
另外如实记一条覆盖面事实：**值域块在 M1~M4 下恒绿**，所以"无符号放进 `Int64`"这档的承诺
靠的是 `"a"`/`digits`/`fox` 三条过 2^31 的**公布值断言**，不是靠值域断言——值域断言兜的是"哪天改用
有符号中间量"那一类回归。变异与还原都在副本目录做，四档全部按原始字节还原并通过 sha256 校验
（工装不入库，读数即本表）。
