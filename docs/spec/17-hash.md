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

## 2. 公开面（第一批 40 件 = 2 枚举 + 2 记录 + 36 函数）

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
| 6 | 返回值类型 | Java `int`/`long` | `Int`/`Int64` 有符号，与参照十进制读数逐字同形 | 换成无符号就得让每个读数多一次换算，对拍反而更易错 |

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
| 本文件 40 件公开面 | **契约已冻结**（10-05 本笔） | 骨架函数体尚未实现，用例按设计态红落库；落地那一笔只许把红变绿（门禁 G5） |
| 变异对照 | PR-B | 见 §6 六条 |
| 第二批 | 排期 | 128 位族（city/metro/murmur128 + `Number128` 形状）、`KetamaHash`、`ConsistentHash` |
