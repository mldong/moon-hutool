# 18 · `bloom` —— 布隆过滤器（位图层 + 过滤器层 + 聚合层）

对位 hutool `cn.hutool.bloomfilter.*`。**件不在 hutool-core**：`unzip -l hutool-core.jar | grep -c bloom` 现读 **0 条**，
本包的参照件全在独立 artifact `hutool-bloomFilter-5.8.35.jar`（19,216 字节、21 个 class）。
进度状态见 `docs/ROADMAP.md` 第 18 行；本文是这一行契约的唯一真相。

---

## 1. 对位与边界（先划清，再写代码）

`unzip -l` 现读的件清单：`BloomFilter`（接口，2 方法）、`BitMapBloomFilter`、`BitSetBloomFilter`、
`BloomFilterUtil`（两个静态工厂）、`bitMap/{BitMap,IntMap,LongMap}`、
`filter/{AbstractFilter,FuncFilter,DefaultFilter,ELFFilter,FNVFilter,HfFilter,HfIpFilter,JSFilter,PJWFilter,RSFilter,SDBMFilter,TianlFilter}`
——11 个 filter 类里除 `FuncFilter`/`AbstractFilter` 外**全是"把一个 `HashUtil` 静态方法塞进 `FuncFilter`"的子类**，
`ROADMAP` 本行原写"只有 `BitMapBloomFilter`"，现读之下真实面是两套实现 + 一层位图 + 一张哈希函数表。

| 处置 | 件 | 理由 |
|---|---|---|
| **本批落地** | `IntMap`/`LongMap` 的位算术、`AbstractFilter`+`FuncFilter` 的位置与 add/contains 语义、`BitMapBloomFilter` 的 m 定档与五个默认过滤器 + varargs 自定义档 | 全是纯位运算与确定性状态机，期望值可由参照腿逐条导出（词表直接反射读 `ints`/`longs` 字段，不靠行为反推） |
| 第二批（排期） | `BitSetBloomFilter`（`bitSetSize = ceil(c*k)`、固定哈希顺序 `rs→js→elf→bkdr→…`、`Math.abs(i % bitSetSize)`） | 它另有一套"按序号取哈希"的顺序表与 `BitSet` 语义，且 `getFalsePositiveProbability()` 是 `Math.pow(1 - Math.exp(-k*n/m), k)`——**超越函数在 wasm/js/native 三档不承诺逐位一致**，要单独拍口径，不能与本批的纯位运算混在同一笔里冻结 |
| 第二批（排期） | `BitSetBloomFilter.init(path, charset)` | 文件 IO 出界（本仓 API 只收 `String`/`Bytes`，同 `csv`/`ini` 两行的边界）；`@Deprecated` 的 `String charsetName` 档不复制 |
| **不建** | `IntMap()` / `LongMap()` 无参构造 | 参照侧硬编码 `new int[93750000]` / `new long[93750000]`（≈375MB / 750MB 一次性预分配）——零依赖库不该替调用方按这个量级占内存；本库容量一律显式传 |
| **不建** | `BloomFilter` 接口（Java 侧的 `implements`） | MoonBit 侧用 struct + 闭包表达"某个哈希函数 + 某个位图"，接口只会在 wasm 档多一层间接；`Serializable`/`serialVersionUID` 同理不做（无 JVM 序列化语义可承接） |
| **不在本包** | 哈希函数本体 | 16 个字符串哈希全在 `hash` 包（`java_default_hash`/`elf_hash`/…/`tianl_hash`，签名现读 `hash/pkg.generated.mbti`：13 个给 `Int`、`hf`/`hf_ip`/`tianl` 给 `Int64`）；本包只做 `longValue()` 之后的取模与位映射，**不重算哈希** |

`BloomFilterUtil.createBitMap(m)` / `createBitSet(c,n,k)` 是薄工厂：前者映射到本包 `new_bloom(m)`，后者属第二批。

---

## 2. 公开面（第一批 23 件 = 1 枚举 + 1 错误 + 1 类型别名 + 3 结构 + 17 函数）

```
pub(all) enum WordWidth { W32 W64 }                    // 对位 BitMap.MACHINE32 / MACHINE64
pub suberror BloomError { BadWidth(Int) ZeroSize BadBitCount(Int64) IndexOutOfRange(Int64, Int) }

pub struct BitField { width, nbits, words }             // 对位 IntMap / LongMap 一家两档
pub struct Filter  { size, hash, field }                // 对位 AbstractFilter + FuncFilter
pub struct Bloom   { filters }                          // 对位 BitMapBloomFilter

宽度折算：word_width(n)（让 `BadWidth` 可达，`machine.16`/`machine.0` 两处读数就钉在这里）

位图层：new_bit_field(nbits, width?) / bit_field_add / bit_field_contains / bit_field_remove /
        bit_field_words / bit_field_word_count
过滤器层：new_filter(size, hash, width?) / filter_position / filter_add / filter_contains / filter_words
聚合层：bloom_bits_for(m) / new_bloom(m) / new_bloom_with(filters) / bloom_add / bloom_contains
```

`hash` 参数类型是 `HashFn = (String) -> Int64`（参照侧 `Function<String, Number>` 之后 `.longValue()`：
`int` 返回值的 `longValue()` 是**符号扩展**，故本库收 `Int64` 并由调用方做同一步扩展，见 §3 第 6 条）。
五个默认过滤器的顺序按参照源码钉：`java_default`、`elf`、`js`、`pjw`、`sdbm`。

---

## 3. 语义条目（每条给参照腿读数标签，标签是 §4 腿 A 的行首）

| # | 判据 | 参照读数 |
|---|---|---|
| 1 | m 定档：`mNum = NumberUtil.div(m, 5).longValue()`（**BigDecimal 商截断到长整型**，不是整数除），`bits = mNum * 1024 * 1024 * 8`，`词数 = (int)(bits / 32)`（W32）或 `(int)(bits / 64)`（W64） | `mnum.6\|1`、`bits.6\|8388608`、`w32.6\|262144`、`w64.6\|131072`，另 `m ∈ {-5,0,1,4,5,10,100,333,1024}` 各一组（`mnum.1\|0`、`bits.1\|0`、`mnum.4\|0.8→0`） |
| 2 | 位置：`bit = Math.abs(hash(s).longValue() % size)`，其中 `hash(s)` 已是 `h % size` ⇒ **取模在前、绝对值在后**，负哈希会先给出负余数再被 `abs` 翻正 | `pos.320.elf.1\|97` 与 `bit.320.elf.1\|97`（同值组），两档 size（320、1000003）× 16 个哈希 × 14 条夹具 = 896 条读数逐条进用例 |
| 3 | W32 位算术：`r = (int)(i / 32)`、`c = i & 31`、`words[r] \|= (1 << c)`；`contains` 用**无符号右移** `(words[r] >>> c) & 1`；`remove` 用 `words[r] &= ~(1 << c)` | `w32.after.*` 词表导出 12 组（每次 add 之后整张 `ints` 反射导出）、`c32.*` 同位回读、`w32.remove31`/`w32.remove31.again`（重复 remove 幂等） |
| 4 | W64 位算术同构：`r = (int)(i / 64)`、`c = i & 63`、`1L << c` | `w64.after.*` 9 组词表（`long` 十进制原值，含 `1L<<63` 的负数读数 `-9223372036854775808`）、`c64.*`、`w64.after.neg` |
| 5 | **负位置不报错**：Java 整除向零截断 ⇒ `r = -1/32 = 0`，而 `-1 & 31 = 31` ⇒ 静默把第 0 个词的**符号位**置起来 | `oob.add.neg\|OK:no-throw`、`w32.after.neg\|[-2147483645, …]`（与上一条读数只差 `1<<31`）、`c32.neg\|true`、`c32.bit31\|true`（同一位从两个入口都读得到） |
| 6 | **超 int 范围的位置先回绕**：`(int)(i/32)` 的窄化在越界之前发生 ⇒ `2^40` 回绕成 `r=0`（静默污染第 0 词），`2^32` 回绕成 `134217728` 才撞越界 | `oob.add.2^40\|OK:no-throw`、`oob.add.2^37.plus` 词表读数、`oob.add.2^32\|ArrayIndexOutOfBoundsException: Index 134217728 out of bounds for length 10` |
| 7 | 词数是**地板除截断**：`size` 不是 32 的整数倍时尾部位不可用（1000 ⇒ 31 个词 ⇒ 位置 999 落 `r=31` 越界，位置 991 合法） | `trunc.words.1000\|31`、`trunc.oob.999\|AIOOBE: Index 31 out of bounds for length 31`、`trunc.inrange.959\|OK:true`、`trunc.max.valid.991\|OK:true` |
| 8 | `filter_add` 语义：已置位 ⇒ `false`（**不覆盖、不计次**）；未置位 ⇒ 置位并 `true` | `f.elf.add1.a\|true`、`f.elf.add2.a\|false`、`f.elf.words` 终态词表 |
| 9 | `filter_contains` 只问那一位；`machineNum` 非 32/64 在**构造时**抛 | `machine.16\|RuntimeException: Error Machine number!`、`machine.0` 同形、`machine.64\|OK:true` |
| 10 | 聚合层 `add` 是各过滤器返回值的**逻辑或**；`contains` 是全命中才算命中。两侧状态不一致的那些档就是 OR 与 AND 的分岔点，本批夹具里有五条 | `q.c.elf.i`/`q.c.sdbm.i`（逐串的两个过滤器各自 contains）与 `q.add.i`/`q.before.i` 并排：`i=3/6/8/9` 是"elf 已含、sdbm 未含 ⇒ `q.add\|true`"，`i=13` 反向；`i=5/12` 是"两侧都已含 ⇒ `q.add\|false`"。同时钉出一条定理：**`bloom_add(b,s)` 恒等于加入前 `bloom_contains(b,s)` 的否**（14 条逐串对读，`q.before.*` 与 `q.add.*` 无一例外）；`filter_add` 单层同构（`f.elf.add1.a\|true`、`f.elf.add2.a\|false`、`tiny.add.*`/`tiny.add.again.*` 14 条成对） |
| 11 | `size == 0` 时构造成功、**第一次取模才炸**（`/ by zero`）；`bits < 0` 在构造时就炸（`NegativeArraySizeException`） | `bf.m1.contains\|ArithmeticException: / by zero`、`bf.m1.add` 同形、`bf.m0.contains` 同形、`bf.negm\|NegativeArraySizeException: -262144` |
| 12 | 假阳性是**定义内行为**：从未加入的串照样报"已存在"，且聚合层的 contains 比单过滤器更松 | 单过滤器档 `tiny.add.{3,5,6,8,9,12}\|false`（这些串此前都没加入过，位置却被占）；聚合档 `q.before.5\|true` 与 `q.before.12\|true` 配 `q.add.5\|false`/`q.add.12\|false`；终态词表 `q.words.elf\|[68190763]`、`q.words.sdbm\|[17078391]` 两条就是这些碰撞的物证 |
| 13 | varargs 构造器 `BitMapBloomFilter(m, filters...)` 先执行 `this(m)` ⇒ **白分配五个大位图**再整体替换 | `bf.one.*`/`bf.mix.*` 只反映替换后的行为；这一条是源码级判定（`this(m); this.filters = filters;` 两行），处置见 §5 第 3 行 |

夹具 14 条（空串、`a`、`abc`、`axc`、`hello`、`HELLO`、两条中文、`🍎a`、`a b c`、`0123456789`、
`Java JavaScript`、`aaaaaaaa`、`zz`）在 Java 侧写 `\uXXXX` 转义并 `javac -encoding UTF-8`（`digest` 轮那条编码教训的形状）。

---

## 4. 两条腿

| 腿 | 载体 | 读数 | 备注 |
|---|---|---|---|
| A 实测 | 真 `hutool-bloomFilter-5.8.35.jar` + 本机 JDK 17.0.14，`javac -encoding UTF-8`；类私有字段（`ints`/`longs`/`bm`/`filters`）走反射导出 | **1325 行**（`bloom_ref.txt`），每条 `tag\|值` 可复算 | 四组：m 定档公式（10 档 × 4 读数）、位置映射（2 档 size × 16 哈希 × 14 夹具 = 896 条，`pos.`/`bit.` 各一次）、位图终态词表（W32 12 组 + W64 9 组 + remove 档 + 越界/回绕/负数档）、行为序列（`f.*`、`bf.*`、`tiny.*`、`tinymix.*`）与异常档；聚合层那组逐串"两个过滤器各自 contains + 聚合 contains/add" 是 §3 第 10、12 条的凭据 |
| B 独立重算（对撞用，不供期望值） | Python：把 A 的 `bit.*`/probes 位置序列喂进一套**独立写的位算术**（`r = int(i/32)` 向零截断 + `c = i & 31` + 32 位回绕后再按符号整数读回），重算每次操作后的词表 | 与 A 的 `w32.after.*`/`w64.after.*`/`trunc.*` 逐条 diff | 词表是"状态终态"而不是行为推断，最容易被第二套实现复算——本包的位图层要的就是这一层可复算性；分岔不进用例，只进 §5 记录 |

---

## 5. 分岔与不跟随（逐条给两侧读数）

| # | 分岔 | 参照 | 本库 | 依据 |
|---|---|---|---|---|
| 1 | 无参构造的预分配 | `new int[93750000]`（≈375MB）/ `new long[93750000]`（≈750MB） | 不建无参构造，容量显式传 | 源码读数在 §1；替调用方按这个量级占内存不是库的职责 |
| 2 | 越界位置 | `ArrayIndexOutOfBoundsException`（未检异常，`add`/`contains` 都能抛） | `raise BloomError.IndexOutOfRange(r, len)` | 同一条 `oob.add.320` 读数两侧都给；本库把"越界"纳入签名可见的错误面（三档一致承诺要求可捕获的失败面） |
| 3 | varargs 构造器白分配 | `this(m)` 先建五个大位图再替换 | `new_bloom_with(m, filters)` 不预分配，`m` 只用于校验/文档 | 参照源码两行；行为面（`bf.one.*`/`bf.mix.*`）与不预分配等价 |
| 4 | 词数地板除截断 | `(int)(size / machineNum)` ⇒ 尾部零头位不可用 | **跟随** | `trunc.oob.999` 与 `trunc.max.valid.991` 两条读数就是这一档；改掉它等于换一套位置空间，`bits`/`pos.` 读数全部作废 |
| 5 | 负位置 / 超 int 位置的静默回绕 | 见 §3 第 5、6 条 | **跟随**（并只对真越界 raise） | 五条读数（`w32.after.neg`、`c32.bit31`、`oob.add.2^40`、`oob.add.2^37.plus`、`oob.add.2^32`）；这不是"参照的坑"而是它的可观测语义，本包同名函数要同值 |
| 6 | `size == 0` 的失败时机 | 构造成功，第一次 `% size` 抛 `/ by zero` | 同点 `raise ZeroSize`；`bits < 0` 在 `new_bloom` 构造期 `raise BadBitCount` | `bf.m1.contains` 与 `bf.negm` 两条读数的时机不同，本库按各自时机报 |
| 7 | 哈希值的宽度 | `Function<String, Number>` 之后 `.longValue()` | `HashFn = (String) -> Int64`，调用方把 `Int` 哈希符号扩展 | 参照 16 个哈希里 13 个 `int`、3 个 `long`（`fnl(HashUtil::hfHash)` 那三条本机编译报错就是凭据：`long 无法转换为 int`）——本库不"统一成 Int"，宽度按 hash 包现读签名 |
| 8 | `BitSetBloomFilter` 的误判率 | `Math.pow(1 - Math.exp(-k*n/m), k)` | **第二批**，且不承诺三档逐位一致 | 超越函数在 wasm/js/native 的结果位数不同（同 `rand` 轮"熵按档位分"一类判定） |
| 9 | `Serializable` / `serialVersionUID` / `init(path, charset)` | 有 | 不做 | 无 JVM 序列化语义可承接；文件 IO 出界 |

---

## 6. 变异对照（落地轮逐条实跑）

| 变异 | 预期抓到它的读数 |
|---|---|
| `contains` 用算术右移 `>>` 替代 `>>>` | §3 第 3 条：词表含符号位的档（`w32.after.31` 之后 `c32.31`） |
| `remove` 写成 `words[r] &= (1 << c)` | `w32.remove31`/`w32.remove31.again` 两条词表读数 |
| 取模与绝对值顺序对调（先 abs 再 `%`） | §3 第 2 条：负哈希那批 `pos.` 与 `bit.` 不等的读数（如 `pos.*.fnv.*` 那族） |
| `c = i & 31` 写成 `i % 32` | 负位置档 `w32.after.neg`（`-1 & 31 = 31` 而 `-1 % 32 = -1`） |
| 词数改成向上取整 | `trunc.oob.999`（本应 raise 的那条会变成可用） |
| `filter_add` 未置位也返回 `false` / 已置位返回 `true` | `f.elf.add1.a`、`f.elf.add2.a`、`tiny.add.*` 全序列 |
| 聚合层 `add` 改成逻辑与 | `q.c.elf.*`/`q.c.sdbm.*` 状态不一致的五档（`i=3/6/8/9/13`：一侧已含、一侧未含 ⇒ `q.add|true`） |
| 聚合层 `contains` 改成"任一命中即真" | `q.c.elf.5|false` 配 `q.c.sdbm.5|true` 那档（聚合 `q.before.5|true` 要求全命中）以及 `tiny.add.*|false` 六条 |
| `mNum` 用整数除 `m / 5` 替 `BigDecimal.longValue()` | §3 第 1 条：`mnum.-5`/`mnum.1`/`mnum.4` 那几档截断方向不同处 |
| 默认五个过滤器顺序调换 | `bf.m6.*` 序列（顺序变了 ⇒ 汇总与词表终态都变） |
落地轮实跑（`moon test --target wasm` 逐条只改一处、跑完按 sha256 字节还原；基线读数 417 = 绿 417 / 红 0）：

| 变异 | 结果 | 红块数 |
|---|---|---|
| 词行号按 32 硬编码（忽略 64 档） | **抓到** | 1 |
| 词内位写成 `i % 宽`（负位置处 `&` 与 `%` 分岔） | **抓到** | 1 |
| 清位写成置位（`& ~m` → `\| m`） | **抓到** | 2 |
| W32 档 add 不做 32 位回绕 | **抓到** | 1 |
| 位置不做 `abs` | **抓到** | 2 |
| 聚合 `add` 改成短路（`\|= ` 语义丢副作用） | **抓到** | 3 |
| 聚合 `contains` 改成"任一命中即真" | **抓到** | 3 |
| `bits <= 0` 就在构造期报（参照侧 size=0 是第一次取模才炸） | **抓到** | 3 |
| 越界判定放宽一格（`>= len` → `> len`） | **抓到** | 3 |
| 默认五过滤器顺序调换 | **等价变异：0 红** | — |

最后一条要**更正本节原先的预测**：上面挂着"顺序调换 ⇒ `bf.m6.*` 序列会变"，实跑 0 红。
归因：聚合层只看集合不看顺序——`contains` 是"逐过滤器与"、`add` 是"逐过滤器或"，两者对过滤器列表的排列都满足交换律，
而五个哈希函数的**集合**没变，所以词表终态与全部布尔读数都不变。顺序这条只在"参照源码读得出"的层面成立
（`BitMapBloomFilter` 构造里那五个 `new XxxFilter(size)` 的字面顺序），不构成可观测契约，
本库把顺序写进 `new_bloom` 是为了与参照逐字对得上，**不承诺它被测**。

一条测试侧的补记（属左边不属右边，期望串一字未动）：
落地轮发现"`oob.add.2^37.plus` 那条断言之前少了一步 `b.add(2^37+3)`"——参照腿是在那次加位之后才打的词表，
少一步就永远等不到 bit 3 被并上。补的是**步骤**，`assert_eq` 的右侧数组一字未改（`git diff` 只有 1 行 `+`）。
---

## 7. 状态

`docs/ROADMAP.md` 第 18 行的状态与本节同步（`scripts/sync_status.py --write` 生成，勿手改）：
本批 12 块用例（8 块断言 + 4 个文档块，417 条里的 bloom 部分）已由落地笔全部转绿，wasm / js / wasm-gc 三档一致，`.mbti` 随实现前进；十条变异对照与那条等价变异都记在 §6。
