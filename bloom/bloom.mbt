///|
// moon-hutool/bloom —— 布隆过滤器（位图层 + 过滤器层 + 聚合层）
// 对位 hutool `cn.hutool.bloomfilter.*`——**件不在 hutool-core**：`unzip -l hutool-core.jar` 现读 `bloom` 是 0 条，
// 全在独立 artifact `hutool-bloomFilter-5.8.35.jar`（19,216 字节、21 个 class，与 `dfa`/`cache` 两行同形）。
// 契约真相在 `docs/spec/18-bloom.md`；本文件是签名骨架——函数体是 abort，落地笔（PR-B）替换。
//
// 一句话口径：位置 = `abs(hash(s).longValue() % size)`（**取模在前、绝对值在后**），
// 词下标 = `(int)(i / 32或64)`（Java 整除向零截断 + 窄化回绕都跟随），词内位 = `i & (宽-1)`；
// 哈希值一律来自 `hash` 包，本包不重算（16 件里 13 件给 `Int`、`hf`/`hf_ip`/`tianl` 给 `Int64`，宽度现读签名）。

///|
/// #18.1 词宽，对位参照侧 `BitMap.MACHINE32 = 32` / `MACHINE64 = 64` 两枚常量。
/// 闭合枚举不附 `Eq`/`Debug`（同 `cache` 的 `CachePolicy` 一条口径：比对走标签函数，不为断言给公开面加 derive）
pub(all) enum WordWidth {
  W32
  W64
}

///|
/// #18.2 本包错误面。四档全部来自参照侧可观测的失败点（spec §3 第 7、9、11 条与 §5 第 2、6 行），
/// 且**四档都从公开面可达**——`BadWidth` 靠 #18.7 才有落脚点
pub suberror BloomError {
  /// 宽不是 32/64：参照 `AbstractFilter.init` 构造期抛 `RuntimeException("Error Machine number!")`
  /// （读数 `machine.16`、`machine.0`）
  BadWidth(Int)
  /// `size == 0`：参照侧构造成功、第一次 `h % size` 才抛 `ArithmeticException: / by zero`
  /// （`bf.m1.contains`/`bf.m1.add`/`bf.m0.contains`），本库**同点**报，不提前
  ZeroSize
  /// 位数是负数：参照在 `new int[负数]` 处抛 `NegativeArraySizeException: -262144`（`bf.negm`），
  /// 时机同样在构造期
  BadBitCount(Int64)
  /// 词下标越界：参照抛未检的 `ArrayIndexOutOfBoundsException`
  /// （`oob.add.320`、`trunc.oob.999`、`oob.add.2^32`），本库换成可捕获的 typed 错误（两侧读数都在案）
  IndexOutOfRange(Int64, Int)
}

///|
/// #18.3 字符串哈希的形态。参照侧是 `Function<String, Number>` 之后 `.longValue()`，
/// 而 `int` 返回值的 `longValue()` 是**符号扩展** ⇒ 本库收 `Int64`，扩展那一步交给调用方
/// （宽度凭据不是查文档：本机把三条 `long` 返回的哈希塞进 `ToIntFunction` 直接编译报错）
pub type HashFn = (String) -> Int64

///|
/// #18.4 位图层：`nbits` 位的位图，底层按 #18.1 的档位存词数组。对位 `IntMap` / `LongMap` 一家两档。
/// 参照侧还各有一个无参构造硬编码 `new int[93750000]`（≈375MB）/ `new long[93750000]`（≈750MB）——
/// **本库不建**（spec §5 第 1 行）
pub struct BitField {
  width : WordWidth
  nbits : Int64
  words : Array[Int64]
}

///|
/// #18.5 过滤器层：`size` 个可用位 + 一个哈希函数 + 一张位图。对位 `AbstractFilter` + `FuncFilter`。
/// 参照侧另外 10 个子类（`DefaultFilter`/`ELFFilter`/…）都只是"把一个 `HashUtil` 静态方法塞进 `FuncFilter`"，
/// 本库用闭包表达，不建类族
pub struct Filter {
  size : Int64
  hash : HashFn
  field : BitField
}

///|
/// #18.6 聚合层：一组过滤器，`contains` 要全命中、`add` 是各层返回值的逻辑或。对位 `BitMapBloomFilter`
pub struct Bloom {
  filters : Array[Filter]
}

///|
/// #18.7 把参照侧的 `machineNum` 整数常量折成 #18.1。只有 32/64 两档可用。
///
/// 这一件的存在理由是**报错面可达性**：若公开面只给闭合枚举，`BadWidth` 那条分支永远走不到，
/// 而参照侧的 `machine.16`/`machine.0` 是实打实的构造期失败——把"整数 → 档位"做成公开件，
/// 那两条读数才有落点（永真死格比红灯更危险）
///
/// - Raises: `BloomError.BadWidth(n)`：`n` 不是 32 也不是 64
pub fn word_width(n : Int) -> WordWidth raise BloomError {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.8 建位图：词数 = `nbits / 宽` 的**地板除截断**（读数 `trunc.words.1000|31` ⇒ 合法下标只有 0..30）。
/// 这条截断是跟随项而不是本库取舍：改成向上取整等于换一套位置空间，`bits.*`/`pos.*` 读数全部作废
///
/// - Raises: `BloomError.BadBitCount(nbits)`：`nbits < 0`（参照同点在 `new int[负数]`）
pub fn new_bit_field(
  nbits : Int64,
  width? : WordWidth = WordWidth::W32,
) -> BitField raise BloomError {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.9 置位：`r = i / 宽`（向零截断后**窄化回绕**），`c = i & (宽-1)`，`words[r] |= (1 << c)`。
/// 两条反直觉都在案：负位置不越界而是静默污染第 0 词的符号位（`-1 & 31 = 31`，读数 `w32.after.neg`、
/// `c32.neg`、`c32.bit31`）；`2^40` 回绕成 `r=0`（`oob.add.2^40|OK:no-throw`），`2^32` 才撞越界
///
/// - Raises: `BloomError.IndexOutOfRange(r, len)`：参照侧的 `ArrayIndexOutOfBoundsException`
pub fn BitField::add(self : BitField, i : Int64) -> Unit raise BloomError {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.10 读位：参照侧用**无符号右移** `(words[r] >>> c) & 1`——改成算术右移就会在含符号位的词上读错
/// （变异清单项，spec §6）
///
/// - Raises: 同 #18.9
pub fn BitField::contains(self : BitField, i : Int64) -> Bool raise BloomError {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.11 清位：`words[r] &= ~(1 << c)`，**重复清位幂等**
/// （`w32.remove31` 与 `w32.remove31.again` 词表逐字同值，W64 档同构）
///
/// - Raises: 同 #18.9
pub fn BitField::remove(self : BitField, i : Int64) -> Unit raise BloomError {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.12 词表导出。W32 档的值按 **32 位符号整数**读回，与参照侧打印的 `ints` 逐字同形
/// （如 `w32.after.neg|[-2147483645, …]`）；W64 档直接是 `long`，含 `1L << 63` 的负读数
/// （`w64.after.639` 末位是 `-9223372036854775808`）
pub fn BitField::words(self : BitField) -> Array[Int64] {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.13 词数 = `nbits / 宽` 的截断值（不是向上取整，理由同 #18.8；两侧读数 `w32.*`/`w64.*`）
pub fn BitField::word_count(self : BitField) -> Int {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.14 建过滤器：`size` 是取模用的位数，位图长度按 #18.8 的截断词数算。
/// `size == 0` 在**这里不报错**——参照侧也是构造成功、第一次取模才炸（`bf.m1.*`），时机跟着钉
///
/// - Raises: `BloomError.BadWidth`：#18.7 的同一档（`machine.16`/`machine.0`）
pub fn new_filter(
  size : Int64,
  hash : HashFn,
  width? : WordWidth = WordWidth::W32,
) -> Filter raise BloomError {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.15 位位置 = `abs(hash(s) % size)`：**取模在前、绝对值在后**。
/// 896 条成对读数钉住（两档 size × 16 哈希 × 14 夹具），其中 40 条余数为负——
/// 如 `pos.320.ap.2|-285` 配 `bit.320.ap.2|285`；先 abs 再取模会得到另一个数，这就是变异的落点
///
/// - Raises: `BloomError.ZeroSize`：`size == 0`
pub fn Filter::position(self : Filter, s : String) -> Int64 raise BloomError {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.16 单过滤器加入：该位**已置 ⇒ false（不覆盖、不计次）**；未置 ⇒ 置位并 true
/// （`f.elf.add1.a|true` 对 `f.elf.add2.a|false`；size=32 的极小档 `tiny.add.*`/`tiny.add.again.*` 逐串成对）
///
/// - Raises: #18.15 与 #18.9 的并
pub fn Filter::add(self : Filter, s : String) -> Bool raise BloomError {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.17 单过滤器查询（存在误判，报"不含"则必不含）。
/// 假阳性是定义内行为：`tiny.add.*|false` 那六条串此前从未加入过，位置却被占
///
/// - Raises: 同 #18.16
pub fn Filter::contains(self : Filter, s : String) -> Bool raise BloomError {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.18 该过滤器的词表终态（`f.elf.words|[0, 0, 0, 2, 67108864, 0, …]`、`tiny.words`、
/// `q.words.elf|[68190763]` 三条就是它——终态而不是行为反推）
pub fn Filter::words(self : Filter) -> Array[Int64] {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.19 m 定档：`mNum = NumberUtil.div(m, 5).longValue()`（**BigDecimal 商截断**，不是整数除），
/// `bits = mNum * 1024 * 1024 * 8`。总函数，负 m 照样算出负位数（`bits.-5|-8388608`），
/// 报错留给 #18.8 与 #18.20 各自的时机
pub fn bloom_bits_for(m : Int) -> Int64 {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.20 默认五过滤器聚合，顺序按参照源码钉：`java_default`、`elf`、`js`、`pjw`、`sdbm`
/// （`bf.m6.*` 那 60 条序列读数的来源就是这个定档 + 这个顺序，顺序调换在落地轮会被抓到）
///
/// - Raises: `BloomError.BadBitCount(bits)`：`bits < 0`（`bf.negm`）；`ZeroSize` 在第一次查询时（`bf.m1.*`）
pub fn new_bloom(m : Int) -> Bloom raise BloomError {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.21 自定义过滤器组。**不重造参照侧 varargs 构造器"先 `this(m)` 再整体替换"的白分配**
/// （spec §5 第 3 行），故本件不收 `m`；终态与 `BitMapBloomFilter(m, filters...)` 替换后等价
/// （`bf.one.*`、`bf.two.*`、`bf.mix.*`、`q.*` 四组读数为凭）
pub fn new_bloom_with(filters : Array[Filter]) -> Bloom {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.22 聚合层加入：各过滤器 `add` 的**逻辑或**。钉两条：
/// ① 与"加入前 `contains` 的否"恒等（14 条逐串对读无一例外）；
/// ② 与逻辑与的分岔点是**两个过滤器状态不一致**的那五条（`q.c.elf.3|true` 配 `q.c.sdbm.3|false` ⇒ `q.add.3|true`，
/// i 另含 6/8/9/13）——这批读数是把参照腿重跑、补 `q.c.*` 探针才拿到的，第一版夹具一条都区分不出来
///
/// - Raises: 各过滤器 #18.16 的并
pub fn Bloom::add(self : Bloom, s : String) -> Bool raise BloomError {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}

///|
/// #18.23 聚合层查询：**全命中才算命中**，任一过滤器说不含即刻 false。
/// 定义内的假阳性直读两条：`q.before.5|true`、`q.before.12|true`（这两条串此前都没 `add` 过）
///
/// - Raises: 各过滤器 #18.17 的并
pub fn Bloom::contains(self : Bloom, s : String) -> Bool raise BloomError {
  abort("moon-hutool bloom: 契约已冻结，实现待落地")
}
