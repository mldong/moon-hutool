# 第 5 节 · `codec`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 05 行（`codec`）“用例”列的逐字原文。
编号 05 是稳定 ID：与该包契约 `docs/spec/05-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `codec` | `Base64`(url-safe·MIME·宽松解码) / `Base32` / `Base58`(含 Check) / `Base62` / `RadixUtil` / `x-www-form-urlencoded` / `UrlBuilder` | **已实现**（10-05 两批全落地，wasm / js / wasm-gc 三档读数一致，`.mbti` 零漂移；**10-08 第四批（纯补档）**：三条从没打过的失败通道（Base64/Base32 各一份 `BadPadding`、authority 只写一个 `@`）+ 三处 RFC 3986 形状档，本包未覆盖行 **9 → 0**、自此退出 G15 清单；一块推导被真跑打回（`/x/./../y/.` ⇒ `/y/` 不是 `/x/y/`）记在 spec §11；块数现读 `moon test --package codec`） | `docs/spec/05-codec.md` | 38 条（25 断言块 + 13 文档块）全绿；读数走 RFC 4648 §10 向量 + 两套独立实现互算（Base58/62 无 RFC），form 档以 HTML 序列化器 ↔ Node `URLSearchParams` 双路互算、URL 档以 RFC 3986 §3/§5.2.4/§6.2.2 加 Python `urlsplit` 对跑；`BCD` 判**不做**（上游已 `@Deprecated`、语义即 core hex），§5.2.2 引用解析与 IDN 另批 |
````

---

**10-10 批①（PR-A 契约冻结笔）**：codec 包新增 §12 两件（`codec/url_assemble.mbt`）：
`data_uri(mime, charset, data)` 与 `data_uri_base64(mime, base64)`，冻结期望 **177 条**、手打零条
（腿 `scripts/UrlPureLeg.java`）。四条形状全都有读数、都不"修正"：数据**不编码**（`100%` 照出）、
charset 串**不校验**（`GBK`/`nope` 原样带过，空串 ⇒ 整段 `;charset` 省略）、base64 **不校验**、
mime 为空出 `data:;base64,...`。参照的 null 入参在它那边落成字符串 `"null"`，本库无该形状。

`URLUtil` 其余两半的去向：`encodeBlank` 的谓词与 `text` 那张 35 位空白表同源 ⇒ 收在
`01-text.md` §1.19（归处也写进 `00-hutool-map.md`）；`completeUrl` **改判 deferred**——
批①开工时把它当纯字符串件，腿跑完推翻了这个前提：`java.net.URL` 的协议白名单决定
"是不是绝对 URL"（`data:`/`tel:`/`urn:`/`javascript:` 一律 `ERR:UtilException`）、无 scheme 的基串
被补成 `http://`、`http://a` + `./b` 那点段**不归一**而 `http://a.com/api/` + `../b` 又归一
⇒ 同一个函数两套尾巴。逐条理由与本包 §8 的 RFC 3986 归一为什么不能直接替它，写在
`05-codec.md` §12.2。

本笔状态：`moon check` 零警告；codec 有 **1 块红**（§12 骨架块）⇒ READINGS 此刻记 `契约已冻结`
是工具按红绿分的类，本包 §2~§11 那几批 0 红、0 改动，PR-B 落地后自动回 `已实现`。

---

**10-10 批①（PR-B 落地笔）**：§12 那块骨架红转绿，`moon test --package codec` 现读 **48 条全绿**
（含 `codec/README.mbt.md` 新增的 data URI 文档块），期望串零改写。一条变异抓到红：
`M13` "charset 为空也写 `;`"（空档整段省略被取消）**2 红**——红正好落在腿 D 行那两片 `data:text/plain,hi`
形状的读数上，说明"省略"这一档不是实现顺手做的、是真被断言钉住的。

---

**10-10 批③ 片一（Caesar / Rot，PR-A 契约笔，非落地笔）**

- **开局先撞出一条能力边界**：`Caesar` 的守卫是 `Character.isLetter(char)`（Unicode 档），而本版 core 的
  `Char` 没有任何 Unicode 字母谓词（现读 `builtin/char.mbt` 17 个 `is_*` 全是 ASCII 档或
  control/digit/whitespace/numeric/printable/bmp，写 `is_letter()` 判 `Type Char has no method is_letter`）。
  三条路里选**自建判定表**：收窄成 ASCII 会让 `caesar_encode("中文", 3)` 从参照的 `"CC"` 变成 `"中文"`，
  那是语义层分岔不是结构层；判 deferred 又白留一条 gap。
- **表的凭据**：腿 `scripts/LetterRangesLeg.java` 扫 BMP 逐码元，出 **380 段半开区间 / 覆盖 48,909 个码元 /
  码位和 mod 2147483647 = 1536313765**，另带 6 个跨界边界点与 4 档代理码元（都判 false ⇒ 守卫必须逐码元摊）。
  生成件 `codec/letter_table.mbt`（表 + 私有二分隔词，**不进 `.mbti`**）与白盒件
  `codec/letter_table_wbtest.mbt`（扫全 BMP 把三条全域读数逐条对撞）。生成器 `scripts/gen_letter_table.py`
  把守恒校验放在出文件之前：区间有序、相邻不可并、Σ覆盖 == 全域计数，任一不成立就停。
  **生产者指纹 `JDK 17.0.14 (Oracle)` 写进表头**——`isLetter` 底层是 JDK 自带 Unicode 数据，这张表冻的是
  "与腿里那台 JDK 同判"，换大版本要重跑腿重出表，不许手改期望。另留一条当初定"core 有没有这谓词"的对撞腿
  `scripts/LetterSetLeg.java`。
- **公开面 7 件**（`.mbti` 现读前进 15 行）：`caesar_table`（52 字符交替表，对位参照那个
  `public static final`）、`caesar_encode`/`caesar_decode`、`rot_encode`/`rot_decode`（三参，参照没有
  2 参重载 ⇒ 不发明）、`rot13_encode`/`rot13_decode`（`encode13` 两档塌成带默认值一个口）。错误面加一个
  `CodecError` 变体 `ShiftUnderflow(Int)`——参照那条异常消息本身带的就是这个负下标，载荷原样交出。
  **加变体的连带面是编译器点名的**：`codec/codec_test.mbt` 与 `codec/README.mbt.md` 里两处对 `CodecError`
  的穷尽匹配各补一条臂才编得过（文档即测试第二次真兑现，第一次是 `num` 批那次）。
- **期望规模**：`moon test --package codec` 现读 **188 = 绿 51 / 红 137**（137 条红全是本批新块，体是
  `PR-B：契约骨架` 的 abort），`moon check` 0 警告 0 错误。`codec/caesar_test.mbt` 46 块 890 断言
  （其中 **57 档是 `ShiftUnderflow` 抛错档**）、`codec/rot_test.mbt` 92 块 2332 断言。四份腿
  （`CaesarLeg` 971 / `RotLeg` 2302 / 两条字母表腿）各跑两遍逐字节相同；夹具与期望串一律由
  `cc3([码位…])` 现造，**手打零条**。
- **五条推翻常识的读数**（写给实现轮，防止"顺手改回去"）：① `Caesar` 的守卫是 Unicode 字母、不是
  "在不在表里"——`é`/`中` 参与移位，`shift=1` 得 `A`、`shift=3` 让 `"中文"` 变 `"CC"`、`shift<=0` 抛；
  ② `encodeChar` **不做负数归一**而 `decodeChar` 做（字节码同一段只差一行）⇒ 编码侧负 shift 必抛
  （`A`−1 就在那 57 档里，不必非拉丁字母也撞到），解码侧从不抛；③ 异常消息带那个负下标
  （`String index out of range: -14`），所以错误载荷是这个数而不是文案；④ `Rot` 的守卫是**三段 ASCII
  码位区间**，与 ① 正相反（`é` 在 `Rot` 原样、在 `Caesar` 要移），且三段各自取模**也不归一** ⇒
  `A`−13 出 `'4'`、`0`−1 出 `'/'`（甩出字母表是参照的行为，不是 bug）；⑤ `Rot.encode13(String)` 单参档的
  `number_support` 实测是 **`true`**（数字夹具 `0189` 只在 `true` 侧相等），而 `decode13` 与 `encode13`
  在 25 条夹具里只有 **18 条**同值——"ROT13 自反"是 folklore，不是这条实现。
- **两条写法裁决**：同包多个 `_test.mbt` 共享顶层命名空间 ⇒ helper `cc3` 只在 Caesar 那份定义、Rot 那份
  复用并在头部点明（重复定义判 `declared twice`）；断言实参位上不许出现 `true`/`false` 字面串（G17 死格
  形状棘轮）⇒ `number_support` 两档走具名常量 `num_on`/`num_off`。
- **census 本轮暂不翻档**：`Caesar`/`Rot` 仍留在 `gap`，等实现笔把体子写真了再逐条指回公开件——本仓 `done`
  的判据是"能力真存在"，不是"签名已冻"。`Morse` 的码表、二进制回退与 locale 敏感的 `toUpperCase` 另立片二。
