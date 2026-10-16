# 17 · `hash`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 17 行（`hash`）“用例”列的逐字原文。
编号 17 是稳定 ID：与该包契约 `docs/spec/17-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `hash` | `HashUtil`（39 个 `public static`，javap 现读）+ `lang.hash.MurmurHash`/`CityHash`/`MetroHash`/`KetamaHash` + `io.checksum.CRC8`/`CRC16` 与 `crc16/` 十变体——**全在 hutool-core 一个 jar 里**（与 `dfa`/`cache` 两行相反，这行不用另取 artifact） | **已实现**（10-05 三笔：契约 `56c1077` + 文字更正 `c9b5c6d` + 落地；10 块 452 条断言全绿，三档一致） | `docs/spec/17-hash.md` | 第一批 45 件 = 2 枚举 + 2 记录 + 41 函数；452 条断言由脚本从参照腿 **398 条读数**灌入（`javac -encoding UTF-8`，非 ASCII 夹具在 Java 侧写 Unicode 转义）。三条反直觉判据钉住：① `additive_hash`/`rotating_hash` 的第二参是**模数**，`prime == 0` 参照侧直接 `ArithmeticException: / by zero`（16 条读数），本库换成 `raise HashError::ZeroPrime`，负数模数照算；② FNV 两档**只在纯 ASCII 同值**——`fnv_hash(String)` 走 UTF-16 码元、`fnv_hash_bytes` 走字节且对字节做符号扩展 XOR（中文两档 1995683249 对 2129874571），末尾还有 `<<13/>>7/<<3/>>17/<<5` 搅拌 + `Math.abs`，而 `abs(Integer.MIN_VALUE)` 仍是负数 ⇒ **返回值可以为负**；移位方向也不统一（FNV 用算术 `>>`、`int_hash` 用逻辑 `>>>`）；③ `tianl_hash` 在长度 256/257 两侧走不同分支、空串给 0；`hf`/`hf_ip` 两档与哈希质量无关（`hfip.cn` 就是 0）但家族成员照对。**CRC8 不是标准 CRC-8**：参照的表构造少了 `<< 8`，实测 `poly=0x07,init=0` 对 `"123456789"` 给 **2**，标准式给 244——本库照参照（同名函数跨库同值是这个包的存在理由），两侧都记在 spec §5。Murmur 的**位置陷阱**摆进函数名：参照的三参重载是 `(data, length, seed)`、四参才是 `(data, offset, length, seed)`，本库分成 `murmur32_len_seed` 与 `murmur32_range`，并实测偏移档与"先切片再哈希"同值；**64 位没有 offset 档**（javap 现读只有三个重载），本库不替参照补。`HashUtil.murmur32/64`、`cityHash*`、`metroHash*` 全是转手委托 ⇒ 不建两套公开面。不建三件带证据：`universal`/`zobrist`（值由调用方传入的随机表决定，没表就没有可对拍的数）、`identityHashCode`（JVM 地址派生，跨平台不可复现）、`Hashids`（**不是哈希**，是可逆编码，归属另判，00-hutool-map 已记待判）。排期两件别顺手做：128 位族（city/metro/murmur128）要先定 `Number128` 的返回形状，`KetamaHash`/`ConsistentHash` 是"数据结构 + 哈希"要单独评 。落地轮四条硬教训：**测试里的字节夹具必须由生成器按 `s.encode("utf-8")` 现算**（两份手打的 UTF-8 都是错的，错到断言红才发现）；**MoonBit 的 `Char` 是码位而 Java `charAt` 是 UTF-16 码元** ⇒ 逐字符族先摊码元；本版**无符号字面量后缀不可用**（`0u`/`0x..u` 判词法错），改用带类型注解的常量绑定；`CRC16Ansi` 参照是 `hi ^= b` **不掩 0xff**、喂进来的字节还要符号扩展（本机 Java 探针逐字节打中间量才定位到）。变异四条有块红（去 FNV 末尾 `abs` / `int_hash` 的 `>>>` 改算术右移 / `Ansi` 初值改 0 / `Ansi` 掩码改回 `& 0xff`），另有一条**无效变异**（丢 `offset` 让参数未用而编译失败）如实记在 spec §6 |
````

---

**10-16 第二批 · CRC32（PR-A 契约笔）**：需求登记本仓 Issues #2（七牛 Kodo 客户端的块级校验要 CRC32，
表单上传的可选 `crc32` 与 `mkblk`/`bput`/`mkfile` 每块响应的 `crc32` 比对都靠它）。

- **归口落本包而不是 `digest`**，三条现读证据：CRC 族早在本包（`Crc8`/`Crc16` 两套有状态件）、§1 那句分工线
  写的是"校验和属本包"、`digest` 现读 27 件全是无状态一次性入口。issue 原文写在 `digest` 名下，改判记在 spec §8 头。
- **本件没有 hutool 对位**（类面清单现读 `io.checksum` 只有 CRC8/CRC16 与十个变体），属基础件补位，
  先例是 `digest` §2.5 的 `equal_digest`。因此与 §3 第 3 行那条"照参照的非标准 CRC8"取向相反，
  本件用**标准式**（IEEE 802.3 反射位序）——反差摆进 spec §5 第 7 行，不藏。
- **三级读数对撞后才冻结**（工装 `scripts/gen_crc32_test.py`，夹具与期望串手打零条）：
  ① CRC-32 族公布值四条（`""`／`"a"`／`"123456789"` 的 CHECK 常数／quick-brown-fox）；
  ② Python `zlib.crc32` 对全部夹具现算并与 ① 逐条 assert；
  ③ JDK 17.0.14 `java.util.zip.CRC32`（`scripts/Crc32Leg.java`，`javac -encoding UTF-8`）三条入口
  `update(byte[])`／`update(byte[],int,int)`／`update(int)` 各跑同一批夹具并与 ② 逐条相等。
  腿侧的两条等值判据（`offset56` 等于 `rep56`、`after_reset` 等于 `empty`）脚本先 assert 再生成。
- **契约面 9 件**：`Crc32` 累加器 + `new_crc32` / `crc32_update` / `_update_range` / `_update_byte` /
  `_value` / `_reset` + 一次性 `crc32_of_bytes` / `crc32_hex`。出口位扩展是契约的一部分：无符号 32 位
  放进 `Int64`，恒 `0..4294967295`（`"a"` 那条过 2^31，专挡"先降 `Int32` 再升 `Int64`"的符号扩展）。
- **本笔状态**：`moon check` 0 警告（骨架豁免按 G12 只压 `struct_never_constructed` 一类）；
  `moon test --package hash` 现读 **20 = 绿 10 / 红 10**，红的 10 块全是本批骨架（体是 `PR-B：契约骨架`
  的 abort），既有 10 块一字未动。全仓 wasm 1748 = 绿 1738 / 红 10、wasm-gc 1736 = 绿 1726 / 红 10，
  用例地板与 CI FLOOR 同笔抬（1738→1748、1726→1736）。
