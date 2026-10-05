///|
// bloom 第一批的期望值全部由生成脚本灌入（手打零条）。
// 参照腿：真 hutool-bloomFilter-5.8.35.jar（**件不在 hutool-core**：core 的 jar 里 grep bloom 是 0 条）
//   + 本机 JDK 17.0.14，javac -encoding UTF-8，1325 行读数（bloom_ref.txt）。位图终态是**反射导出的私有字段**
//   （ints/longs/bm/filters），所以词表是状态读数而不是行为反推；异常档直接打 class:message。
// 哈希值不在本包重算：16 件全部委托 hash 包（13 件返回 Int、hf/hf_ip/tianl 返回 Int64，宽度现读签名），
//   下面 hfn 那张对照表把腿里的函数名一一对到本库公开件——名字对不上就编译不过。
// 异常映射（spec §5 第 2、6 行）：AIOOBE(index,len) → IndexOutOfRange(index,len)；
//   / by zero → ZeroSize；NegativeArraySizeException(n) → BadBitCount(n)；Error Machine number! → BadWidth(n)。
// 断言一律把"会抛的调用折成标签串"的辅助件包起来：本版不许在实参位置直接写 try 表达式
//   （会被解析成匹配模式），也不接受 `let _ = <会抛的调用>`（推不出返回类型）。

fn h_java_default(s : String) -> Int64 {
  @hash.java_default_hash(s).to_int64()
}

///|
fn h_elf(s : String) -> Int64 {
  @hash.elf_hash(s).to_int64()
}

///|
fn h_js(s : String) -> Int64 {
  @hash.js_hash(s).to_int64()
}

///|
fn h_pjw(s : String) -> Int64 {
  @hash.pjw_hash(s).to_int64()
}

///|
fn h_sdbm(s : String) -> Int64 {
  @hash.sdbm_hash(s).to_int64()
}

///|
fn h_rs(s : String) -> Int64 {
  @hash.rs_hash(s).to_int64()
}

///|
fn h_bkdr(s : String) -> Int64 {
  @hash.bkdr_hash(s).to_int64()
}

///|
fn h_ap(s : String) -> Int64 {
  @hash.ap_hash(s).to_int64()
}

///|
fn h_fnv(s : String) -> Int64 {
  @hash.fnv_hash(s).to_int64()
}

///|
fn h_hf(s : String) -> Int64 {
  @hash.hf_hash(s)
}

///|
fn h_hf_ip(s : String) -> Int64 {
  @hash.hf_ip_hash(s)
}

///|
fn h_tianl(s : String) -> Int64 {
  @hash.tianl_hash(s)
}

///|
fn h_one_by_one(s : String) -> Int64 {
  @hash.one_by_one_hash(s).to_int64()
}

///|
fn h_bernstein(s : String) -> Int64 {
  @hash.bernstein(s).to_int64()
}

///|
fn h_djb(s : String) -> Int64 {
  @hash.djb_hash(s).to_int64()
}

///|
fn h_dek(s : String) -> Int64 {
  @hash.dek_hash(s).to_int64()
}

///|
fn hfn(name : String) -> @bloom.HashFn {
  match name {
    "java_default" => h_java_default
    "elf" => h_elf
    "js" => h_js
    "pjw" => h_pjw
    "sdbm" => h_sdbm
    "rs" => h_rs
    "bkdr" => h_bkdr
    "ap" => h_ap
    "fnv" => h_fnv
    "hf" => h_hf
    "hf_ip" => h_hf_ip
    "tianl" => h_tianl
    "one_by_one" => h_one_by_one
    "bernstein" => h_bernstein
    "djb" => h_djb
    "dek" => h_dek
    _ => h_dek
  }
}

///|
// 四档错误全覆盖，不留 wildcard（留了就是把"没人实现的那一档"藏起来）
fn tag(e : @bloom.BloomError) -> String {
  match e {
    @bloom.BadWidth(n) => "BadWidth:" + n.to_string()
    @bloom.ZeroSize => "ZeroSize"
    @bloom.BadBitCount(b) => "BadBitCount:" + b.to_string()
    @bloom.IndexOutOfRange(r, len) =>
      "IndexOutOfRange:" + r.to_string() + "," + len.to_string()
  }
}

///|
// 闭合枚举不附 Eq/Debug（同 cache 的 CachePolicy 一条口径），比对走标签函数
fn wtag(w : @bloom.WordWidth) -> String {
  match w {
    @bloom.W32 => "W32"
    @bloom.W64 => "W64"
  }
}

///|
fn bool_of(f : () -> Bool raise @bloom.BloomError) -> String {
  try "OK:" + f().to_string() catch {
    e => tag(e)
  }
}

///|
fn i64_of(f : () -> Int64 raise @bloom.BloomError) -> String {
  try "OK:" + f().to_string() catch {
    e => tag(e)
  }
}

///|
fn unit_of(f : () -> Unit raise @bloom.BloomError) -> String {
  try {
    f()
    "OK"
  } catch {
    e => tag(e)
  }
}

///|
fn bf_of(f : () -> @bloom.BitField raise @bloom.BloomError) -> String {
  try {
    let _v = f()
    "OK"
  } catch {
    e => tag(e)
  }
}

///|
fn bloom_of(f : () -> @bloom.Bloom raise @bloom.BloomError) -> String {
  try {
    let _v = f()
    "OK"
  } catch {
    e => tag(e)
  }
}

///|
fn ww_of(n : Int) -> String {
  try "OK:" + wtag(@bloom.word_width(n)) catch {
    e => tag(e)
  }
}

///|
test "bloom 宽度折算：只有 32/64 两档，其余 BadWidth" {
  assert_eq(ww_of(32), "OK:W32") // BitMap.MACHINE32=32（W32 档的位算术读数在块 4）
  assert_eq(ww_of(64), "OK:W64") // BitMap.MACHINE64=64（machine.64|OK:true，位算术读数在块 5）
  assert_eq(ww_of(16), "BadWidth:16") // machine.16|java.lang.RuntimeException:Error Machine number!
  assert_eq(ww_of(0), "BadWidth:0") // machine.0|java.lang.RuntimeException:Error Machine number!
}

///|
test "bloom m 定档：div(m,5).longValue() 再乘 1024*1024*8" {
  assert_eq(@bloom.bloom_bits_for(-5), -8388608L) // bits.-5（mnum.-5|-1）
  assert_eq(@bloom.bloom_bits_for(0), 0L) // bits.0（mnum.0|0）
  assert_eq(@bloom.bloom_bits_for(1), 0L) // bits.1（mnum.1|0）
  assert_eq(@bloom.bloom_bits_for(4), 0L) // bits.4（mnum.4|0）
  assert_eq(@bloom.bloom_bits_for(5), 8388608L) // bits.5（mnum.5|1）
  assert_eq(@bloom.bloom_bits_for(6), 8388608L) // bits.6（mnum.6|1）
  assert_eq(@bloom.bloom_bits_for(10), 16777216L) // bits.10（mnum.10|2）
  assert_eq(@bloom.bloom_bits_for(100), 167772160L) // bits.100（mnum.100|20）
  assert_eq(@bloom.bloom_bits_for(333), 553648128L) // bits.333（mnum.333|66）
  assert_eq(@bloom.bloom_bits_for(1024), 1711276032L) // bits.1024（mnum.1024|204）
  assert_eq(
    bf_of(() => @bloom.new_bit_field(-8388608L)),
    "BadBitCount:-8388608",
  ) // bits.-5|-8388608、w32.-5|-262144；参照在 new int[负数] 处抛 java.lang.NegativeArraySizeException:-262144
  assert_eq(@bloom.new_bit_field(0L).word_count(), 0) // w32.0
  assert_eq(@bloom.new_bit_field(0L, width=@bloom.W64).word_count(), 0) // w64.0
  assert_eq(@bloom.new_bit_field(0L).word_count(), 0) // w32.1
  assert_eq(@bloom.new_bit_field(0L, width=@bloom.W64).word_count(), 0) // w64.1
  assert_eq(@bloom.new_bit_field(0L).word_count(), 0) // w32.4
  assert_eq(@bloom.new_bit_field(0L, width=@bloom.W64).word_count(), 0) // w64.4
  assert_eq(@bloom.new_bit_field(8388608L).word_count(), 262144) // w32.5
  assert_eq(
    @bloom.new_bit_field(8388608L, width=@bloom.W64).word_count(),
    131072,
  ) // w64.5
  assert_eq(@bloom.new_bit_field(8388608L).word_count(), 262144) // w32.6
  assert_eq(
    @bloom.new_bit_field(8388608L, width=@bloom.W64).word_count(),
    131072,
  ) // w64.6
  // 大档只钉公式不建位图：m=1024 是 53477376 个词（≈430MB），而参照侧的无参构造更狠——
  // new int[93750000] ≈ 375MB，那正是本库拒建无参构造的理由（spec §5 第 1 行）
}

///|
test "bloom 位置映射：16 哈希 × 14 夹具 × 两档 size（取模在前、绝对值在后）" {
  let f_java_default = @bloom.new_filter(320L, hfn("java_default"))
  assert_eq(f_java_default.position(""), 0L) // bit.320.java_default.0（余数 pos=0）
  assert_eq(f_java_default.position("a"), 97L) // bit.320.java_default.1（余数 pos=97）
  assert_eq(f_java_default.position("abc"), 34L) // bit.320.java_default.2（余数 pos=34）
  assert_eq(f_java_default.position("axc"), 76L) // bit.320.java_default.3（余数 pos=76）
  assert_eq(f_java_default.position("hello"), 82L) // bit.320.java_default.4（余数 pos=82）
  assert_eq(f_java_default.position("HELLO"), 242L) // bit.320.java_default.5（余数 pos=242）
  assert_eq(
    f_java_default.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    40L,
  ) // bit.320.java_default.6（余数 pos=-40）
  assert_eq(f_java_default.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 100L) // bit.320.java_default.7（余数 pos=100）
  assert_eq(f_java_default.position("\u{1f34e}a"), 79L) // bit.320.java_default.8（余数 pos=79）
  assert_eq(f_java_default.position("a b c"), 38L) // bit.320.java_default.9（余数 pos=38）
  assert_eq(f_java_default.position("0123456789"), 133L) // bit.320.java_default.10（余数 pos=133）
  assert_eq(f_java_default.position("Java JavaScript"), 75L) // bit.320.java_default.11（余数 pos=75）
  assert_eq(f_java_default.position("aaaaaaaa"), 64L) // bit.320.java_default.12（余数 pos=64）
  assert_eq(f_java_default.position("zz"), 64L) // bit.320.java_default.13（余数 pos=64）
  let f_elf = @bloom.new_filter(320L, hfn("elf"))
  assert_eq(f_elf.position(""), 0L) // bit.320.elf.0（余数 pos=0）
  assert_eq(f_elf.position("a"), 97L) // bit.320.elf.1（余数 pos=97）
  assert_eq(f_elf.position("abc"), 259L) // bit.320.elf.2（余数 pos=259）
  assert_eq(f_elf.position("axc"), 291L) // bit.320.elf.3（余数 pos=291）
  assert_eq(f_elf.position("hello"), 47L) // bit.320.elf.4（余数 pos=47）
  assert_eq(f_elf.position("HELLO"), 207L) // bit.320.elf.5（余数 pos=207）
  assert_eq(
    f_elf.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    47L,
  ) // bit.320.elf.6（余数 pos=47）
  assert_eq(f_elf.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 5L) // bit.320.elf.7（余数 pos=5）
  assert_eq(f_elf.position("\u{1f34e}a"), 129L) // bit.320.elf.8（余数 pos=129）
  assert_eq(f_elf.position("a b c"), 163L) // bit.320.elf.9（余数 pos=163）
  assert_eq(f_elf.position("0123456789"), 41L) // bit.320.elf.10（余数 pos=41）
  assert_eq(f_elf.position("Java JavaScript"), 116L) // bit.320.elf.11（余数 pos=116）
  assert_eq(f_elf.position("aaaaaaaa"), 65L) // bit.320.elf.12（余数 pos=65）
  assert_eq(f_elf.position("zz"), 154L) // bit.320.elf.13（余数 pos=154）
  let f_js = @bloom.new_filter(320L, hfn("js"))
  assert_eq(f_js.position(""), 231L) // bit.320.js.0（余数 pos=231）
  assert_eq(f_js.position("a"), 115L) // bit.320.js.1（余数 pos=115）
  assert_eq(f_js.position("abc"), 95L) // bit.320.js.2（余数 pos=95）
  assert_eq(f_js.position("axc"), 230L) // bit.320.js.3（余数 pos=230）
  assert_eq(f_js.position("hello"), 309L) // bit.320.js.4（余数 pos=309）
  assert_eq(f_js.position("HELLO"), 22L) // bit.320.js.5（余数 pos=22）
  assert_eq(
    f_js.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    48L,
  ) // bit.320.js.6（余数 pos=48）
  assert_eq(f_js.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 162L) // bit.320.js.7（余数 pos=162）
  assert_eq(f_js.position("\u{1f34e}a"), 42L) // bit.320.js.8（余数 pos=42）
  assert_eq(f_js.position("a b c"), 251L) // bit.320.js.9（余数 pos=251）
  assert_eq(f_js.position("0123456789"), 25L) // bit.320.js.10（余数 pos=25）
  assert_eq(f_js.position("Java JavaScript"), 25L) // bit.320.js.11（余数 pos=25）
  assert_eq(f_js.position("aaaaaaaa"), 291L) // bit.320.js.12（余数 pos=291）
  assert_eq(f_js.position("zz"), 263L) // bit.320.js.13（余数 pos=263）
  let f_pjw = @bloom.new_filter(320L, hfn("pjw"))
  assert_eq(f_pjw.position(""), 0L) // bit.320.pjw.0（余数 pos=0）
  assert_eq(f_pjw.position("a"), 97L) // bit.320.pjw.1（余数 pos=97）
  assert_eq(f_pjw.position("abc"), 259L) // bit.320.pjw.2（余数 pos=259）
  assert_eq(f_pjw.position("axc"), 291L) // bit.320.pjw.3（余数 pos=291）
  assert_eq(f_pjw.position("hello"), 47L) // bit.320.pjw.4（余数 pos=47）
  assert_eq(f_pjw.position("HELLO"), 207L) // bit.320.pjw.5（余数 pos=207）
  assert_eq(
    f_pjw.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    303L,
  ) // bit.320.pjw.6（余数 pos=303）
  assert_eq(f_pjw.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 5L) // bit.320.pjw.7（余数 pos=5）
  assert_eq(f_pjw.position("\u{1f34e}a"), 129L) // bit.320.pjw.8（余数 pos=129）
  assert_eq(f_pjw.position("a b c"), 163L) // bit.320.pjw.9（余数 pos=163）
  assert_eq(f_pjw.position("0123456789"), 41L) // bit.320.pjw.10（余数 pos=41）
  assert_eq(f_pjw.position("Java JavaScript"), 116L) // bit.320.pjw.11（余数 pos=116）
  assert_eq(f_pjw.position("aaaaaaaa"), 65L) // bit.320.pjw.12（余数 pos=65）
  assert_eq(f_pjw.position("zz"), 154L) // bit.320.pjw.13（余数 pos=154）
  let f_sdbm = @bloom.new_filter(320L, hfn("sdbm"))
  assert_eq(f_sdbm.position(""), 0L) // bit.320.sdbm.0（余数 pos=0）
  assert_eq(f_sdbm.position("a"), 97L) // bit.320.sdbm.1（余数 pos=97）
  assert_eq(f_sdbm.position("abc"), 226L) // bit.320.sdbm.2（余数 pos=226）
  assert_eq(f_sdbm.position("axc"), 204L) // bit.320.sdbm.3（余数 pos=204）
  assert_eq(f_sdbm.position("hello"), 242L) // bit.320.sdbm.4（余数 pos=242）
  assert_eq(f_sdbm.position("HELLO"), 18L) // bit.320.sdbm.5（余数 pos=18）
  assert_eq(
    f_sdbm.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    184L,
  ) // bit.320.sdbm.6（余数 pos=184）
  assert_eq(f_sdbm.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 100L) // bit.320.sdbm.7（余数 pos=100）
  assert_eq(f_sdbm.position("\u{1f34e}a"), 79L) // bit.320.sdbm.8（余数 pos=79）
  assert_eq(f_sdbm.position("a b c"), 294L) // bit.320.sdbm.9（余数 pos=294）
  assert_eq(f_sdbm.position("0123456789"), 133L) // bit.320.sdbm.10（余数 pos=133）
  assert_eq(f_sdbm.position("Java JavaScript"), 235L) // bit.320.sdbm.11（余数 pos=235）
  assert_eq(f_sdbm.position("aaaaaaaa"), 128L) // bit.320.sdbm.12（余数 pos=128）
  assert_eq(f_sdbm.position("zz"), 0L) // bit.320.sdbm.13（余数 pos=0）
  let f_rs = @bloom.new_filter(320L, hfn("rs"))
  assert_eq(f_rs.position(""), 0L) // bit.320.rs.0（余数 pos=0）
  assert_eq(f_rs.position("a"), 97L) // bit.320.rs.1（余数 pos=97）
  assert_eq(f_rs.position("abc"), 44L) // bit.320.rs.2（余数 pos=44）
  assert_eq(f_rs.position("axc"), 274L) // bit.320.rs.3（余数 pos=274）
  assert_eq(f_rs.position("hello"), 274L) // bit.320.rs.4（余数 pos=274）
  assert_eq(f_rs.position("HELLO"), 178L) // bit.320.rs.5（余数 pos=178）
  assert_eq(
    f_rs.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    36L,
  ) // bit.320.rs.6（余数 pos=36）
  assert_eq(f_rs.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 240L) // bit.320.rs.7（余数 pos=240）
  assert_eq(f_rs.position("\u{1f34e}a"), 227L) // bit.320.rs.8（余数 pos=227）
  assert_eq(f_rs.position("a b c"), 130L) // bit.320.rs.9（余数 pos=130）
  assert_eq(f_rs.position("0123456789"), 113L) // bit.320.rs.10（余数 pos=113）
  assert_eq(f_rs.position("Java JavaScript"), 159L) // bit.320.rs.11（余数 pos=159）
  assert_eq(f_rs.position("aaaaaaaa"), 224L) // bit.320.rs.12（余数 pos=224）
  assert_eq(f_rs.position("zz"), 288L) // bit.320.rs.13（余数 pos=288）
  let f_bkdr = @bloom.new_filter(320L, hfn("bkdr"))
  assert_eq(f_bkdr.position(""), 0L) // bit.320.bkdr.0（余数 pos=0）
  assert_eq(f_bkdr.position("a"), 97L) // bit.320.bkdr.1（余数 pos=97）
  assert_eq(f_bkdr.position("abc"), 114L) // bit.320.bkdr.2（余数 pos=114）
  assert_eq(f_bkdr.position("axc"), 116L) // bit.320.bkdr.3（余数 pos=116）
  assert_eq(f_bkdr.position("hello"), 270L) // bit.320.bkdr.4（余数 pos=270）
  assert_eq(f_bkdr.position("HELLO"), 110L) // bit.320.bkdr.5（余数 pos=110）
  assert_eq(
    f_bkdr.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    36L,
  ) // bit.320.bkdr.6（余数 pos=36）
  assert_eq(f_bkdr.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 52L) // bit.320.bkdr.7（余数 pos=52）
  assert_eq(f_bkdr.position("\u{1f34e}a"), 39L) // bit.320.bkdr.8（余数 pos=39）
  assert_eq(f_bkdr.position("a b c"), 134L) // bit.320.bkdr.9（余数 pos=134）
  assert_eq(f_bkdr.position("0123456789"), 293L) // bit.320.bkdr.10（余数 pos=293）
  assert_eq(f_bkdr.position("Java JavaScript"), 63L) // bit.320.bkdr.11（余数 pos=63）
  assert_eq(f_bkdr.position("aaaaaaaa"), 144L) // bit.320.bkdr.12（余数 pos=144）
  assert_eq(f_bkdr.position("zz"), 104L) // bit.320.bkdr.13（余数 pos=104）
  let f_ap = @bloom.new_filter(320L, hfn("ap"))
  assert_eq(f_ap.position(""), 0L) // bit.320.ap.0（余数 pos=0）
  assert_eq(f_ap.position("a"), 97L) // bit.320.ap.1（余数 pos=97）
  assert_eq(f_ap.position("abc"), 285L) // bit.320.ap.2（余数 pos=-285）
  assert_eq(f_ap.position("axc"), 262L) // bit.320.ap.3（余数 pos=-262）
  assert_eq(f_ap.position("hello"), 294L) // bit.320.ap.4（余数 pos=294）
  assert_eq(f_ap.position("HELLO"), 142L) // bit.320.ap.5（余数 pos=-142）
  assert_eq(
    f_ap.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    152L,
  ) // bit.320.ap.6（余数 pos=152）
  assert_eq(f_ap.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 204L) // bit.320.ap.7（余数 pos=-204）
  assert_eq(f_ap.position("\u{1f34e}a"), 92L) // bit.320.ap.8（余数 pos=-92）
  assert_eq(f_ap.position("a b c"), 176L) // bit.320.ap.9（余数 pos=-176）
  assert_eq(f_ap.position("0123456789"), 96L) // bit.320.ap.10（余数 pos=96）
  assert_eq(f_ap.position("Java JavaScript"), 18L) // bit.320.ap.11（余数 pos=-18）
  assert_eq(f_ap.position("aaaaaaaa"), 212L) // bit.320.ap.12（余数 pos=212）
  assert_eq(f_ap.position("zz"), 260L) // bit.320.ap.13（余数 pos=-260）
  let f_fnv = @bloom.new_filter(320L, hfn("fnv"))
  assert_eq(f_fnv.position(""), 290L) // bit.320.fnv.0（余数 pos=290）
  assert_eq(f_fnv.position("a"), 79L) // bit.320.fnv.1（余数 pos=79）
  assert_eq(f_fnv.position("abc"), 253L) // bit.320.fnv.2（余数 pos=253）
  assert_eq(f_fnv.position("axc"), 246L) // bit.320.fnv.3（余数 pos=246）
  assert_eq(f_fnv.position("hello"), 137L) // bit.320.fnv.4（余数 pos=137）
  assert_eq(f_fnv.position("HELLO"), 26L) // bit.320.fnv.5（余数 pos=26）
  assert_eq(
    f_fnv.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    163L,
  ) // bit.320.fnv.6（余数 pos=163）
  assert_eq(f_fnv.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 49L) // bit.320.fnv.7（余数 pos=49）
  assert_eq(f_fnv.position("\u{1f34e}a"), 135L) // bit.320.fnv.8（余数 pos=135）
  assert_eq(f_fnv.position("a b c"), 272L) // bit.320.fnv.9（余数 pos=272）
  assert_eq(f_fnv.position("0123456789"), 225L) // bit.320.fnv.10（余数 pos=225）
  assert_eq(f_fnv.position("Java JavaScript"), 96L) // bit.320.fnv.11（余数 pos=96）
  assert_eq(f_fnv.position("aaaaaaaa"), 302L) // bit.320.fnv.12（余数 pos=302）
  assert_eq(f_fnv.position("zz"), 81L) // bit.320.fnv.13（余数 pos=81）
  let f_hf = @bloom.new_filter(320L, hfn("hf"))
  assert_eq(f_hf.position(""), 0L) // bit.320.hf.0（余数 pos=0）
  assert_eq(f_hf.position("a"), 0L) // bit.320.hf.1（余数 pos=0）
  assert_eq(f_hf.position("abc"), 248L) // bit.320.hf.2（余数 pos=248）
  assert_eq(f_hf.position("axc"), 314L) // bit.320.hf.3（余数 pos=314）
  assert_eq(f_hf.position("hello"), 55L) // bit.320.hf.4（余数 pos=55）
  assert_eq(f_hf.position("HELLO"), 55L) // bit.320.hf.5（余数 pos=55）
  assert_eq(
    f_hf.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    213L,
  ) // bit.320.hf.6（余数 pos=213）
  assert_eq(f_hf.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 20L) // bit.320.hf.7（余数 pos=20）
  assert_eq(f_hf.position("\u{1f34e}a"), 240L) // bit.320.hf.8（余数 pos=240）
  assert_eq(f_hf.position("a b c"), 240L) // bit.320.hf.9（余数 pos=240）
  assert_eq(f_hf.position("0123456789"), 295L) // bit.320.hf.10（余数 pos=295）
  assert_eq(f_hf.position("Java JavaScript"), 231L) // bit.320.hf.11（余数 pos=231）
  assert_eq(f_hf.position("aaaaaaaa"), 148L) // bit.320.hf.12（余数 pos=148）
  assert_eq(f_hf.position("zz"), 46L) // bit.320.hf.13（余数 pos=46）
  let f_hf_ip = @bloom.new_filter(320L, hfn("hf_ip"))
  assert_eq(f_hf_ip.position(""), 0L) // bit.320.hf_ip.0（余数 pos=0）
  assert_eq(f_hf_ip.position("a"), 0L) // bit.320.hf_ip.1（余数 pos=0）
  assert_eq(f_hf_ip.position("abc"), 0L) // bit.320.hf_ip.2（余数 pos=0）
  assert_eq(f_hf_ip.position("axc"), 0L) // bit.320.hf_ip.3（余数 pos=0）
  assert_eq(f_hf_ip.position("hello"), 7L) // bit.320.hf_ip.4（余数 pos=7）
  assert_eq(f_hf_ip.position("HELLO"), 7L) // bit.320.hf_ip.5（余数 pos=7）
  assert_eq(
    f_hf_ip.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    160L,
  ) // bit.320.hf_ip.6（余数 pos=160）
  assert_eq(f_hf_ip.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 0L) // bit.320.hf_ip.7（余数 pos=0）
  assert_eq(f_hf_ip.position("\u{1f34e}a"), 0L) // bit.320.hf_ip.8（余数 pos=0）
  assert_eq(f_hf_ip.position("a b c"), 2L) // bit.320.hf_ip.9（余数 pos=2）
  assert_eq(f_hf_ip.position("0123456789"), 32L) // bit.320.hf_ip.10（余数 pos=32）
  assert_eq(f_hf_ip.position("Java JavaScript"), 62L) // bit.320.hf_ip.11（余数 pos=62）
  assert_eq(f_hf_ip.position("aaaaaaaa"), 0L) // bit.320.hf_ip.12（余数 pos=0）
  assert_eq(f_hf_ip.position("zz"), 0L) // bit.320.hf_ip.13（余数 pos=0）
  let f_tianl = @bloom.new_filter(320L, hfn("tianl"))
  assert_eq(f_tianl.position(""), 0L) // bit.320.tianl.0（余数 pos=0）
  assert_eq(f_tianl.position("a"), 26L) // bit.320.tianl.1（余数 pos=26）
  assert_eq(f_tianl.position("abc"), 318L) // bit.320.tianl.2（余数 pos=318）
  assert_eq(f_tianl.position("axc"), 116L) // bit.320.tianl.3（余数 pos=116）
  assert_eq(f_tianl.position("hello"), 239L) // bit.320.tianl.4（余数 pos=239）
  assert_eq(f_tianl.position("HELLO"), 239L) // bit.320.tianl.5（余数 pos=239）
  assert_eq(
    f_tianl.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    283L,
  ) // bit.320.tianl.6（余数 pos=283）
  assert_eq(f_tianl.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 96L) // bit.320.tianl.7（余数 pos=96）
  assert_eq(f_tianl.position("\u{1f34e}a"), 123L) // bit.320.tianl.8（余数 pos=123）
  assert_eq(f_tianl.position("a b c"), 7L) // bit.320.tianl.9（余数 pos=7）
  assert_eq(f_tianl.position("0123456789"), 164L) // bit.320.tianl.10（余数 pos=164）
  assert_eq(f_tianl.position("Java JavaScript"), 97L) // bit.320.tianl.11（余数 pos=97）
  assert_eq(f_tianl.position("aaaaaaaa"), 52L) // bit.320.tianl.12（余数 pos=52）
  assert_eq(f_tianl.position("zz"), 187L) // bit.320.tianl.13（余数 pos=187）
  let f_one_by_one = @bloom.new_filter(320L, hfn("one_by_one"))
  assert_eq(f_one_by_one.position(""), 0L) // bit.320.one_by_one.0（余数 pos=0）
  assert_eq(f_one_by_one.position("a"), 254L) // bit.320.one_by_one.1（余数 pos=-254）
  assert_eq(f_one_by_one.position("abc"), 293L) // bit.320.one_by_one.2（余数 pos=-293）
  assert_eq(f_one_by_one.position("axc"), 247L) // bit.320.one_by_one.3（余数 pos=-247）
  assert_eq(f_one_by_one.position("hello"), 293L) // bit.320.one_by_one.4（余数 pos=-293）
  assert_eq(f_one_by_one.position("HELLO"), 48L) // bit.320.one_by_one.5（余数 pos=-48）
  assert_eq(
    f_one_by_one.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    193L,
  ) // bit.320.one_by_one.6（余数 pos=-193）
  assert_eq(f_one_by_one.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 114L) // bit.320.one_by_one.7（余数 pos=114）
  assert_eq(f_one_by_one.position("\u{1f34e}a"), 17L) // bit.320.one_by_one.8（余数 pos=-17）
  assert_eq(f_one_by_one.position("a b c"), 137L) // bit.320.one_by_one.9（余数 pos=137）
  assert_eq(f_one_by_one.position("0123456789"), 224L) // bit.320.one_by_one.10（余数 pos=-224）
  assert_eq(f_one_by_one.position("Java JavaScript"), 155L) // bit.320.one_by_one.11（余数 pos=155）
  assert_eq(f_one_by_one.position("aaaaaaaa"), 50L) // bit.320.one_by_one.12（余数 pos=-50）
  assert_eq(f_one_by_one.position("zz"), 182L) // bit.320.one_by_one.13（余数 pos=182）
  let f_bernstein = @bloom.new_filter(320L, hfn("bernstein"))
  assert_eq(f_bernstein.position(""), 0L) // bit.320.bernstein.0（余数 pos=0）
  assert_eq(f_bernstein.position("a"), 97L) // bit.320.bernstein.1（余数 pos=97）
  assert_eq(f_bernstein.position("abc"), 166L) // bit.320.bernstein.2（余数 pos=166）
  assert_eq(f_bernstein.position("axc"), 252L) // bit.320.bernstein.3（余数 pos=252）
  assert_eq(f_bernstein.position("hello"), 308L) // bit.320.bernstein.4（余数 pos=308）
  assert_eq(f_bernstein.position("HELLO"), 276L) // bit.320.bernstein.5（余数 pos=276）
  assert_eq(
    f_bernstein.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    254L,
  ) // bit.320.bernstein.6（余数 pos=254）
  assert_eq(f_bernstein.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 84L) // bit.320.bernstein.7（余数 pos=84）
  assert_eq(f_bernstein.position("\u{1f34e}a"), 299L) // bit.320.bernstein.8（余数 pos=299）
  assert_eq(f_bernstein.position("a b c"), 38L) // bit.320.bernstein.9（余数 pos=38）
  assert_eq(f_bernstein.position("0123456789"), 13L) // bit.320.bernstein.10（余数 pos=13）
  assert_eq(f_bernstein.position("Java JavaScript"), 199L) // bit.320.bernstein.11（余数 pos=-199）
  assert_eq(f_bernstein.position("aaaaaaaa"), 248L) // bit.320.bernstein.12（余数 pos=-248）
  assert_eq(f_bernstein.position("zz"), 308L) // bit.320.bernstein.13（余数 pos=308）
  let f_djb = @bloom.new_filter(320L, hfn("djb"))
  assert_eq(f_djb.position(""), 261L) // bit.320.djb.0（余数 pos=261）
  assert_eq(f_djb.position("a"), 70L) // bit.320.djb.1（余数 pos=70）
  assert_eq(f_djb.position("abc"), 203L) // bit.320.djb.2（余数 pos=203）
  assert_eq(f_djb.position("axc"), 289L) // bit.320.djb.3（余数 pos=289）
  assert_eq(f_djb.position("hello"), 217L) // bit.320.djb.4（余数 pos=217）
  assert_eq(f_djb.position("HELLO"), 185L) // bit.320.djb.5（余数 pos=185）
  assert_eq(
    f_djb.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    67L,
  ) // bit.320.djb.6（余数 pos=67）
  assert_eq(f_djb.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 281L) // bit.320.djb.7（余数 pos=281）
  assert_eq(f_djb.position("\u{1f34e}a"), 16L) // bit.320.djb.8（余数 pos=16）
  assert_eq(f_djb.position("a b c"), 267L) // bit.320.djb.9（余数 pos=267）
  assert_eq(f_djb.position("0123456789"), 146L) // bit.320.djb.10（余数 pos=146）
  assert_eq(f_djb.position("Java JavaScript"), 222L) // bit.320.djb.11（余数 pos=222）
  assert_eq(f_djb.position("aaaaaaaa"), 13L) // bit.320.djb.12（余数 pos=13）
  assert_eq(f_djb.position("zz"), 57L) // bit.320.djb.13（余数 pos=57）
  let f_dek = @bloom.new_filter(320L, hfn("dek"))
  assert_eq(f_dek.position(""), 0L) // bit.320.dek.0（余数 pos=0）
  assert_eq(f_dek.position("a"), 65L) // bit.320.dek.1（余数 pos=65）
  assert_eq(f_dek.position("abc"), 163L) // bit.320.dek.2（余数 pos=163）
  assert_eq(f_dek.position("axc"), 35L) // bit.320.dek.3（余数 pos=35）
  assert_eq(f_dek.position("hello"), 111L) // bit.320.dek.4（余数 pos=111）
  assert_eq(f_dek.position("HELLO"), 79L) // bit.320.dek.5（余数 pos=79）
  assert_eq(
    f_dek.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    178L,
  ) // bit.320.dek.6（余数 pos=178）
  assert_eq(f_dek.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 309L) // bit.320.dek.7（余数 pos=309）
  assert_eq(f_dek.position("\u{1f34e}a"), 289L) // bit.320.dek.8（余数 pos=289）
  assert_eq(f_dek.position("a b c"), 227L) // bit.320.dek.9（余数 pos=227）
  assert_eq(f_dek.position("0123456789"), 69L) // bit.320.dek.10（余数 pos=69）
  assert_eq(f_dek.position("Java JavaScript"), 190L) // bit.320.dek.11（余数 pos=190）
  assert_eq(f_dek.position("aaaaaaaa"), 78L) // bit.320.dek.12（余数 pos=78）
  assert_eq(f_dek.position("zz"), 250L) // bit.320.dek.13（余数 pos=250）
  let f_java_default = @bloom.new_filter(1000003L, hfn("java_default"))
  assert_eq(f_java_default.position(""), 0L) // bit.1000003.java_default.0（余数 pos=0）
  assert_eq(f_java_default.position("a"), 97L) // bit.1000003.java_default.1（余数 pos=97）
  assert_eq(f_java_default.position("abc"), 96354L) // bit.1000003.java_default.2（余数 pos=96354）
  assert_eq(f_java_default.position("axc"), 97036L) // bit.1000003.java_default.3（余数 pos=97036）
  assert_eq(f_java_default.position("hello"), 162025L) // bit.1000003.java_default.4（余数 pos=162025）
  assert_eq(f_java_default.position("HELLO"), 624358L) // bit.1000003.java_default.5（余数 pos=624358）
  assert_eq(
    f_java_default.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    828373L,
  ) // bit.1000003.java_default.6（余数 pos=-828373）
  assert_eq(f_java_default.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 85914L) // bit.1000003.java_default.7（余数 pos=85914）
  assert_eq(f_java_default.position("\u{1f34e}a"), 969197L) // bit.1000003.java_default.8（余数 pos=969197）
  assert_eq(f_java_default.position("a b c"), 629848L) // bit.1000003.java_default.9（余数 pos=629848）
  assert_eq(f_java_default.position("0123456789"), 870261L) // bit.1000003.java_default.10（余数 pos=870261）
  assert_eq(f_java_default.position("Java JavaScript"), 865749L) // bit.1000003.java_default.11（余数 pos=865749）
  assert_eq(f_java_default.position("aaaaaaaa"), 16088L) // bit.1000003.java_default.12（余数 pos=16088）
  assert_eq(f_java_default.position("zz"), 3904L) // bit.1000003.java_default.13（余数 pos=3904）
  let f_elf = @bloom.new_filter(1000003L, hfn("elf"))
  assert_eq(f_elf.position(""), 0L) // bit.1000003.elf.0（余数 pos=0）
  assert_eq(f_elf.position("a"), 97L) // bit.1000003.elf.1（余数 pos=97）
  assert_eq(f_elf.position("abc"), 26499L) // bit.1000003.elf.2（余数 pos=26499）
  assert_eq(f_elf.position("axc"), 26851L) // bit.1000003.elf.3（余数 pos=26851）
  assert_eq(f_elf.position("hello"), 258906L) // bit.1000003.elf.4（余数 pos=258906）
  assert_eq(f_elf.position("HELLO"), 21952L) // bit.1000003.elf.5（余数 pos=21952）
  assert_eq(
    f_elf.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    166891L,
  ) // bit.1000003.elf.6（余数 pos=166891）
  assert_eq(f_elf.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 110138L) // bit.1000003.elf.7（余数 pos=110138）
  assert_eq(f_elf.position("\u{1f34e}a"), 85844L) // bit.1000003.elf.8（余数 pos=85844）
  assert_eq(f_elf.position("a b c"), 513745L) // bit.1000003.elf.9（余数 pos=513745）
  assert_eq(f_elf.position("0123456789"), 768677L) // bit.1000003.elf.10（余数 pos=768677）
  assert_eq(f_elf.position("Java JavaScript"), 377754L) // bit.1000003.elf.11（余数 pos=377754）
  assert_eq(f_elf.position("aaaaaaaa"), 267850L) // bit.1000003.elf.12（余数 pos=267850）
  assert_eq(f_elf.position("zz"), 2074L) // bit.1000003.elf.13（余数 pos=2074）
  let f_js = @bloom.new_filter(1000003L, hfn("js"))
  assert_eq(f_js.position(""), 419966L) // bit.1000003.js.0（余数 pos=419966）
  assert_eq(f_js.position("a"), 671238L) // bit.1000003.js.1（余数 pos=671238）
  assert_eq(f_js.position("abc"), 802850L) // bit.1000003.js.2（余数 pos=802850）
  assert_eq(f_js.position("axc"), 803305L) // bit.1000003.js.3（余数 pos=803305）
  assert_eq(f_js.position("hello"), 137411L) // bit.1000003.js.4（余数 pos=137411）
  assert_eq(f_js.position("HELLO"), 281275L) // bit.1000003.js.5（余数 pos=281275）
  assert_eq(
    f_js.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    91404L,
  ) // bit.1000003.js.6（余数 pos=91404）
  assert_eq(f_js.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 922645L) // bit.1000003.js.7（余数 pos=922645）
  assert_eq(f_js.position("\u{1f34e}a"), 390169L) // bit.1000003.js.8（余数 pos=390169）
  assert_eq(f_js.position("a b c"), 814303L) // bit.1000003.js.9（余数 pos=814303）
  assert_eq(f_js.position("0123456789"), 221978L) // bit.1000003.js.10（余数 pos=221978）
  assert_eq(f_js.position("Java JavaScript"), 328772L) // bit.1000003.js.11（余数 pos=328772）
  assert_eq(f_js.position("aaaaaaaa"), 46986L) // bit.1000003.js.12（余数 pos=46986）
  assert_eq(f_js.position("zz"), 756479L) // bit.1000003.js.13（余数 pos=756479）
  let f_pjw = @bloom.new_filter(1000003L, hfn("pjw"))
  assert_eq(f_pjw.position(""), 0L) // bit.1000003.pjw.0（余数 pos=0）
  assert_eq(f_pjw.position("a"), 97L) // bit.1000003.pjw.1（余数 pos=97）
  assert_eq(f_pjw.position("abc"), 26499L) // bit.1000003.pjw.2（余数 pos=26499）
  assert_eq(f_pjw.position("axc"), 26851L) // bit.1000003.pjw.3（余数 pos=26851）
  assert_eq(f_pjw.position("hello"), 258906L) // bit.1000003.pjw.4（余数 pos=258906）
  assert_eq(f_pjw.position("HELLO"), 21952L) // bit.1000003.pjw.5（余数 pos=21952）
  assert_eq(
    f_pjw.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    428289L,
  ) // bit.1000003.pjw.6（余数 pos=428289）
  assert_eq(f_pjw.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 110138L) // bit.1000003.pjw.7（余数 pos=110138）
  assert_eq(f_pjw.position("\u{1f34e}a"), 85844L) // bit.1000003.pjw.8（余数 pos=85844）
  assert_eq(f_pjw.position("a b c"), 513745L) // bit.1000003.pjw.9（余数 pos=513745）
  assert_eq(f_pjw.position("0123456789"), 768677L) // bit.1000003.pjw.10（余数 pos=768677）
  assert_eq(f_pjw.position("Java JavaScript"), 377754L) // bit.1000003.pjw.11（余数 pos=377754）
  assert_eq(f_pjw.position("aaaaaaaa"), 267850L) // bit.1000003.pjw.12（余数 pos=267850）
  assert_eq(f_pjw.position("zz"), 2074L) // bit.1000003.pjw.13（余数 pos=2074）
  let f_sdbm = @bloom.new_filter(1000003L, hfn("sdbm"))
  assert_eq(f_sdbm.position(""), 0L) // bit.1000003.sdbm.0（余数 pos=0）
  assert_eq(f_sdbm.position("a"), 97L) // bit.1000003.sdbm.1（余数 pos=97）
  assert_eq(f_sdbm.position("abc"), 792365L) // bit.1000003.sdbm.2（余数 pos=792365）
  assert_eq(f_sdbm.position("axc"), 235537L) // bit.1000003.sdbm.3（余数 pos=235537）
  assert_eq(f_sdbm.position("hello"), 822830L) // bit.1000003.sdbm.4（余数 pos=822830）
  assert_eq(f_sdbm.position("HELLO"), 531948L) // bit.1000003.sdbm.5（余数 pos=531948）
  assert_eq(
    f_sdbm.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    420658L,
  ) // bit.1000003.sdbm.6（余数 pos=420658）
  assert_eq(f_sdbm.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 913983L) // bit.1000003.sdbm.7（余数 pos=913983）
  assert_eq(f_sdbm.position("\u{1f34e}a"), 398103L) // bit.1000003.sdbm.8（余数 pos=398103）
  assert_eq(f_sdbm.position("a b c"), 780226L) // bit.1000003.sdbm.9（余数 pos=780226）
  assert_eq(f_sdbm.position("0123456789"), 85115L) // bit.1000003.sdbm.10（余数 pos=85115）
  assert_eq(f_sdbm.position("Java JavaScript"), 423636L) // bit.1000003.sdbm.11（余数 pos=423636）
  assert_eq(f_sdbm.position("aaaaaaaa"), 391547L) // bit.1000003.sdbm.12（余数 pos=391547）
  assert_eq(f_sdbm.position("zz"), 3176L) // bit.1000003.sdbm.13（余数 pos=3176）
  let f_rs = @bloom.new_filter(1000003L, hfn("rs"))
  assert_eq(f_rs.position(""), 0L) // bit.1000003.rs.0（余数 pos=0）
  assert_eq(f_rs.position("a"), 97L) // bit.1000003.rs.1（余数 pos=97）
  assert_eq(f_rs.position("abc"), 157578L) // bit.1000003.rs.2（余数 pos=157578）
  assert_eq(f_rs.position("axc"), 870745L) // bit.1000003.rs.3（余数 pos=870745）
  assert_eq(f_rs.position("hello"), 9793L) // bit.1000003.rs.4（余数 pos=9793）
  assert_eq(f_rs.position("HELLO"), 733202L) // bit.1000003.rs.5（余数 pos=733202）
  assert_eq(
    f_rs.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    678144L,
  ) // bit.1000003.rs.6（余数 pos=678144）
  assert_eq(f_rs.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 615720L) // bit.1000003.rs.7（余数 pos=615720）
  assert_eq(f_rs.position("\u{1f34e}a"), 18119L) // bit.1000003.rs.8（余数 pos=18119）
  assert_eq(f_rs.position("a b c"), 623332L) // bit.1000003.rs.9（余数 pos=623332）
  assert_eq(f_rs.position("0123456789"), 855326L) // bit.1000003.rs.10（余数 pos=855326）
  assert_eq(f_rs.position("Java JavaScript"), 819812L) // bit.1000003.rs.11（余数 pos=819812）
  assert_eq(f_rs.position("aaaaaaaa"), 422802L) // bit.1000003.rs.12（余数 pos=422802）
  assert_eq(f_rs.position("zz"), 107594L) // bit.1000003.rs.13（余数 pos=107594）
  let f_bkdr = @bloom.new_filter(1000003L, hfn("bkdr"))
  assert_eq(f_bkdr.position(""), 0L) // bit.1000003.bkdr.0（余数 pos=0）
  assert_eq(f_bkdr.position("a"), 97L) // bit.1000003.bkdr.1（余数 pos=97）
  assert_eq(f_bkdr.position("abc"), 677551L) // bit.1000003.bkdr.2（余数 pos=677551）
  assert_eq(f_bkdr.position("axc"), 680433L) // bit.1000003.bkdr.3（余数 pos=680433）
  assert_eq(f_bkdr.position("hello"), 143174L) // bit.1000003.bkdr.4（余数 pos=143174）
  assert_eq(f_bkdr.position("HELLO"), 67931L) // bit.1000003.bkdr.5（余数 pos=67931）
  assert_eq(
    f_bkdr.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    39604L,
  ) // bit.1000003.bkdr.6（余数 pos=39604）
  assert_eq(f_bkdr.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 620143L) // bit.1000003.bkdr.7（余数 pos=620143）
  assert_eq(f_bkdr.position("\u{1f34e}a"), 450288L) // bit.1000003.bkdr.8（余数 pos=450288）
  assert_eq(f_bkdr.position("a b c"), 827728L) // bit.1000003.bkdr.9（余数 pos=827728）
  assert_eq(f_bkdr.position("0123456789"), 623802L) // bit.1000003.bkdr.10（余数 pos=623802）
  assert_eq(f_bkdr.position("Java JavaScript"), 932788L) // bit.1000003.bkdr.11（余数 pos=932788）
  assert_eq(f_bkdr.position("aaaaaaaa"), 489260L) // bit.1000003.bkdr.12（余数 pos=489260）
  assert_eq(f_bkdr.position("zz"), 16104L) // bit.1000003.bkdr.13（余数 pos=16104）
  let f_ap = @bloom.new_filter(1000003L, hfn("ap"))
  assert_eq(f_ap.position(""), 0L) // bit.1000003.ap.0（余数 pos=0）
  assert_eq(f_ap.position("a"), 97L) // bit.1000003.ap.1（余数 pos=97）
  assert_eq(f_ap.position("abc"), 651410L) // bit.1000003.ap.2（余数 pos=-651410）
  assert_eq(f_ap.position("axc"), 650107L) // bit.1000003.ap.3（余数 pos=-650107）
  assert_eq(f_ap.position("hello"), 851907L) // bit.1000003.ap.4（余数 pos=851907）
  assert_eq(f_ap.position("HELLO"), 687721L) // bit.1000003.ap.5（余数 pos=-687721）
  assert_eq(
    f_ap.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    929021L,
  ) // bit.1000003.ap.6（余数 pos=929021）
  assert_eq(f_ap.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 549506L) // bit.1000003.ap.7（余数 pos=-549506）
  assert_eq(f_ap.position("\u{1f34e}a"), 541794L) // bit.1000003.ap.8（余数 pos=-541794）
  assert_eq(f_ap.position("a b c"), 446181L) // bit.1000003.ap.9（余数 pos=-446181）
  assert_eq(f_ap.position("0123456789"), 78065L) // bit.1000003.ap.10（余数 pos=78065）
  assert_eq(f_ap.position("Java JavaScript"), 574714L) // bit.1000003.ap.11（余数 pos=-574714）
  assert_eq(f_ap.position("aaaaaaaa"), 35982L) // bit.1000003.ap.12（余数 pos=35982）
  assert_eq(f_ap.position("zz"), 249860L) // bit.1000003.ap.13（余数 pos=-249860）
  let f_fnv = @bloom.new_filter(1000003L, hfn("fnv"))
  assert_eq(f_fnv.position(""), 214368L) // bit.1000003.fnv.0（余数 pos=214368）
  assert_eq(f_fnv.position("a"), 468212L) // bit.1000003.fnv.1（余数 pos=468212）
  assert_eq(f_fnv.position("abc"), 757271L) // bit.1000003.fnv.2（余数 pos=757271）
  assert_eq(f_fnv.position("axc"), 477802L) // bit.1000003.fnv.3（余数 pos=477802）
  assert_eq(f_fnv.position("hello"), 637167L) // bit.1000003.fnv.4（余数 pos=637167）
  assert_eq(f_fnv.position("HELLO"), 857460L) // bit.1000003.fnv.5（余数 pos=857460）
  assert_eq(
    f_fnv.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    338533L,
  ) // bit.1000003.fnv.6（余数 pos=338533）
  assert_eq(f_fnv.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 677264L) // bit.1000003.fnv.7（余数 pos=677264）
  assert_eq(f_fnv.position("\u{1f34e}a"), 221230L) // bit.1000003.fnv.8（余数 pos=221230）
  assert_eq(f_fnv.position("a b c"), 35236L) // bit.1000003.fnv.9（余数 pos=35236）
  assert_eq(f_fnv.position("0123456789"), 107930L) // bit.1000003.fnv.10（余数 pos=107930）
  assert_eq(f_fnv.position("Java JavaScript"), 365940L) // bit.1000003.fnv.11（余数 pos=365940）
  assert_eq(f_fnv.position("aaaaaaaa"), 670224L) // bit.1000003.fnv.12（余数 pos=670224）
  assert_eq(f_fnv.position("zz"), 181406L) // bit.1000003.fnv.13（余数 pos=181406）
  let f_hf = @bloom.new_filter(1000003L, hfn("hf"))
  assert_eq(f_hf.position(""), 0L) // bit.1000003.hf.0（余数 pos=0）
  assert_eq(f_hf.position("a"), 0L) // bit.1000003.hf.1（余数 pos=0）
  assert_eq(f_hf.position("abc"), 888L) // bit.1000003.hf.2（余数 pos=888）
  assert_eq(f_hf.position("axc"), 954L) // bit.1000003.hf.3（余数 pos=954）
  assert_eq(f_hf.position("hello"), 3255L) // bit.1000003.hf.4（余数 pos=3255）
  assert_eq(f_hf.position("HELLO"), 2295L) // bit.1000003.hf.5（余数 pos=2295）
  assert_eq(
    f_hf.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    95570L,
  ) // bit.1000003.hf.6（余数 pos=95570）
  assert_eq(f_hf.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 568020L) // bit.1000003.hf.7（余数 pos=568020）
  assert_eq(f_hf.position("\u{1f34e}a"), 172080L) // bit.1000003.hf.8（余数 pos=172080）
  assert_eq(f_hf.position("a b c"), 2160L) // bit.1000003.hf.9（余数 pos=2160）
  assert_eq(f_hf.position("0123456789"), 7335L) // bit.1000003.hf.10（余数 pos=7335）
  assert_eq(f_hf.position("Java JavaScript"), 31911L) // bit.1000003.hf.11（余数 pos=31911）
  assert_eq(f_hf.position("aaaaaaaa"), 8148L) // bit.1000003.hf.12（余数 pos=8148）
  assert_eq(f_hf.position("zz"), 366L) // bit.1000003.hf.13（余数 pos=366）
  let f_hf_ip = @bloom.new_filter(1000003L, hfn("hf_ip"))
  assert_eq(f_hf_ip.position(""), 0L) // bit.1000003.hf_ip.0（余数 pos=0）
  assert_eq(f_hf_ip.position("a"), 0L) // bit.1000003.hf_ip.1（余数 pos=0）
  assert_eq(f_hf_ip.position("abc"), 0L) // bit.1000003.hf_ip.2（余数 pos=0）
  assert_eq(f_hf_ip.position("axc"), 0L) // bit.1000003.hf_ip.3（余数 pos=0）
  assert_eq(f_hf_ip.position("hello"), 7L) // bit.1000003.hf_ip.4（余数 pos=7）
  assert_eq(f_hf_ip.position("HELLO"), 7L) // bit.1000003.hf_ip.5（余数 pos=7）
  assert_eq(
    f_hf_ip.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    18400L,
  ) // bit.1000003.hf_ip.6（余数 pos=18400）
  assert_eq(f_hf_ip.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 0L) // bit.1000003.hf_ip.7（余数 pos=0）
  assert_eq(f_hf_ip.position("\u{1f34e}a"), 0L) // bit.1000003.hf_ip.8（余数 pos=0）
  assert_eq(f_hf_ip.position("a b c"), 2L) // bit.1000003.hf_ip.9（余数 pos=2）
  assert_eq(f_hf_ip.position("0123456789"), 32L) // bit.1000003.hf_ip.10（余数 pos=32）
  assert_eq(f_hf_ip.position("Java JavaScript"), 382L) // bit.1000003.hf_ip.11（余数 pos=382）
  assert_eq(f_hf_ip.position("aaaaaaaa"), 0L) // bit.1000003.hf_ip.12（余数 pos=0）
  assert_eq(f_hf_ip.position("zz"), 0L) // bit.1000003.hf_ip.13（余数 pos=0）
  let f_tianl = @bloom.new_filter(1000003L, hfn("tianl"))
  assert_eq(f_tianl.position(""), 0L) // bit.1000003.tianl.0（余数 pos=0）
  assert_eq(f_tianl.position("a"), 29786L) // bit.1000003.tianl.1（余数 pos=29786）
  assert_eq(f_tianl.position("abc"), 734619L) // bit.1000003.tianl.2（余数 pos=734619）
  assert_eq(f_tianl.position("axc"), 763857L) // bit.1000003.tianl.3（余数 pos=763857）
  assert_eq(f_tianl.position("hello"), 646118L) // bit.1000003.tianl.4（余数 pos=646118）
  assert_eq(f_tianl.position("HELLO"), 646118L) // bit.1000003.tianl.5（余数 pos=646118）
  assert_eq(
    f_tianl.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    592566L,
  ) // bit.1000003.tianl.6（余数 pos=592566）
  assert_eq(f_tianl.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 235322L) // bit.1000003.tianl.7（余数 pos=235322）
  assert_eq(f_tianl.position("\u{1f34e}a"), 371774L) // bit.1000003.tianl.8（余数 pos=371774）
  assert_eq(f_tianl.position("a b c"), 398206L) // bit.1000003.tianl.9（余数 pos=398206）
  assert_eq(f_tianl.position("0123456789"), 497631L) // bit.1000003.tianl.10（余数 pos=497631）
  assert_eq(f_tianl.position("Java JavaScript"), 43220L) // bit.1000003.tianl.11（余数 pos=43220）
  assert_eq(f_tianl.position("aaaaaaaa"), 482578L) // bit.1000003.tianl.12（余数 pos=482578）
  assert_eq(f_tianl.position("zz"), 915659L) // bit.1000003.tianl.13（余数 pos=915659）
  let f_one_by_one = @bloom.new_filter(1000003L, hfn("one_by_one"))
  assert_eq(f_one_by_one.position(""), 0L) // bit.1000003.one_by_one.0（余数 pos=0）
  assert_eq(f_one_by_one.position("a"), 914348L) // bit.1000003.one_by_one.1（余数 pos=-914348）
  assert_eq(f_one_by_one.position("abc"), 512942L) // bit.1000003.one_by_one.2（余数 pos=-512942）
  assert_eq(f_one_by_one.position("axc"), 732568L) // bit.1000003.one_by_one.3（余数 pos=-732568）
  assert_eq(f_one_by_one.position("hello"), 42596L) // bit.1000003.one_by_one.4（余数 pos=-42596）
  assert_eq(f_one_by_one.position("HELLO"), 683596L) // bit.1000003.one_by_one.5（余数 pos=-683596）
  assert_eq(
    f_one_by_one.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    772904L,
  ) // bit.1000003.one_by_one.6（余数 pos=-772904）
  assert_eq(f_one_by_one.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 898108L) // bit.1000003.one_by_one.7（余数 pos=898108）
  assert_eq(f_one_by_one.position("\u{1f34e}a"), 496851L) // bit.1000003.one_by_one.8（余数 pos=-496851）
  assert_eq(f_one_by_one.position("a b c"), 839332L) // bit.1000003.one_by_one.9（余数 pos=839332）
  assert_eq(f_one_by_one.position("0123456789"), 143182L) // bit.1000003.one_by_one.10（余数 pos=-143182）
  assert_eq(f_one_by_one.position("Java JavaScript"), 721078L) // bit.1000003.one_by_one.11（余数 pos=721078）
  assert_eq(f_one_by_one.position("aaaaaaaa"), 827682L) // bit.1000003.one_by_one.12（余数 pos=-827682）
  assert_eq(f_one_by_one.position("zz"), 734096L) // bit.1000003.one_by_one.13（余数 pos=734096）
  let f_bernstein = @bloom.new_filter(1000003L, hfn("bernstein"))
  assert_eq(f_bernstein.position(""), 0L) // bit.1000003.bernstein.0（余数 pos=0）
  assert_eq(f_bernstein.position("a"), 97L) // bit.1000003.bernstein.1（余数 pos=97）
  assert_eq(f_bernstein.position("abc"), 108966L) // bit.1000003.bernstein.2（余数 pos=108966）
  assert_eq(f_bernstein.position("axc"), 109692L) // bit.1000003.bernstein.3（余数 pos=109692）
  assert_eq(f_bernstein.position("hello"), 86327L) // bit.1000003.bernstein.4（余数 pos=86327）
  assert_eq(f_bernstein.position("HELLO"), 951055L) // bit.1000003.bernstein.5（余数 pos=951055）
  assert_eq(
    f_bernstein.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    901178L,
  ) // bit.1000003.bernstein.6（余数 pos=901178）
  assert_eq(f_bernstein.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 468240L) // bit.1000003.bernstein.7（余数 pos=468240）
  assert_eq(f_bernstein.position("\u{1f34e}a"), 169073L) // bit.1000003.bernstein.8（余数 pos=169073）
  assert_eq(f_bernstein.position("a b c"), 291850L) // bit.1000003.bernstein.9（余数 pos=291850）
  assert_eq(f_bernstein.position("0123456789"), 184368L) // bit.1000003.bernstein.10（余数 pos=184368）
  assert_eq(f_bernstein.position("Java JavaScript"), 806039L) // bit.1000003.bernstein.11（余数 pos=-806039）
  assert_eq(f_bernstein.position("aaaaaaaa"), 395710L) // bit.1000003.bernstein.12（余数 pos=-395710）
  assert_eq(f_bernstein.position("zz"), 4148L) // bit.1000003.bernstein.13（余数 pos=4148）
  let f_djb = @bloom.new_filter(1000003L, hfn("djb"))
  assert_eq(f_djb.position(""), 5381L) // bit.1000003.djb.0（余数 pos=5381）
  assert_eq(f_djb.position("a"), 177670L) // bit.1000003.djb.1（余数 pos=177670）
  assert_eq(f_djb.position("abc"), 485384L) // bit.1000003.djb.2（余数 pos=485384）
  assert_eq(f_djb.position("axc"), 486110L) // bit.1000003.djb.3（余数 pos=486110）
  assert_eq(f_djb.position("hello"), 238154L) // bit.1000003.djb.4（余数 pos=238154）
  assert_eq(f_djb.position("HELLO"), 102879L) // bit.1000003.djb.5（余数 pos=102879）
  assert_eq(
    f_djb.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    479836L,
  ) // bit.1000003.djb.6（余数 pos=479836）
  assert_eq(f_djb.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 458380L) // bit.1000003.djb.7（余数 pos=458380）
  assert_eq(f_djb.position("\u{1f34e}a"), 545491L) // bit.1000003.djb.8（余数 pos=545491）
  assert_eq(f_djb.position("a b c"), 443677L) // bit.1000003.djb.9（余数 pos=443677）
  assert_eq(f_djb.position("0123456789"), 769001L) // bit.1000003.djb.10（余数 pos=769001）
  assert_eq(f_djb.position("Java JavaScript"), 538038L) // bit.1000003.djb.11（余数 pos=538038）
  assert_eq(f_djb.position("aaaaaaaa"), 945529L) // bit.1000003.djb.12（余数 pos=945529）
  assert_eq(f_djb.position("zz"), 864042L) // bit.1000003.djb.13（余数 pos=864042）
  let f_dek = @bloom.new_filter(1000003L, hfn("dek"))
  assert_eq(f_dek.position(""), 0L) // bit.1000003.dek.0（余数 pos=0）
  assert_eq(f_dek.position("a"), 65L) // bit.1000003.dek.1（余数 pos=65）
  assert_eq(f_dek.position("abc"), 2083L) // bit.1000003.dek.2（余数 pos=2083）
  assert_eq(f_dek.position("axc"), 2915L) // bit.1000003.dek.3（余数 pos=2915）
  assert_eq(f_dek.position("hello"), 72752L) // bit.1000003.dek.4（余数 pos=72752）
  assert_eq(f_dek.position("HELLO"), 610224L) // bit.1000003.dek.5（余数 pos=610224）
  assert_eq(
    f_dek.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    715534L,
  ) // bit.1000003.dek.6（余数 pos=715534）
  assert_eq(f_dek.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 15956L) // bit.1000003.dek.7（余数 pos=15956）
  assert_eq(f_dek.position("\u{1f34e}a"), 366195L) // bit.1000003.dek.8（余数 pos=366195）
  assert_eq(f_dek.position("a b c"), 427464L) // bit.1000003.dek.9（余数 pos=427464）
  assert_eq(f_dek.position("0123456789"), 106212L) // bit.1000003.dek.10（余数 pos=106212）
  assert_eq(f_dek.position("Java JavaScript"), 561383L) // bit.1000003.dek.11（余数 pos=561383）
  assert_eq(f_dek.position("aaaaaaaa"), 205684L) // bit.1000003.dek.12（余数 pos=205684）
  assert_eq(f_dek.position("zz"), 1850L) // bit.1000003.dek.13（余数 pos=1850）
}

///|
test "bloom 位图层（32 位档）：逐次 add 的词表终态、清位幂等与三条越界" {
  let b = @bloom.new_bit_field(320L)
  b.add(0L)
  assert_eq(b.words(), [1L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L]) // w32.after.0
  assert_eq(bool_of(() => b.contains(0L)), "OK:true") // c32.0|OK:true
  b.add(1L)
  assert_eq(b.words(), [3L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L]) // w32.after.1
  assert_eq(bool_of(() => b.contains(1L)), "OK:true") // c32.1|OK:true
  b.add(31L)
  assert_eq(b.words(), [-2147483645L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L]) // w32.after.31
  assert_eq(bool_of(() => b.contains(31L)), "OK:true") // c32.31|OK:true
  b.add(32L)
  assert_eq(b.words(), [-2147483645L, 1L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L]) // w32.after.32
  assert_eq(bool_of(() => b.contains(32L)), "OK:true") // c32.32|OK:true
  b.add(33L)
  assert_eq(b.words(), [-2147483645L, 3L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L]) // w32.after.33
  assert_eq(bool_of(() => b.contains(33L)), "OK:true") // c32.33|OK:true
  b.add(63L)
  assert_eq(b.words(), [
    -2147483645L, -2147483645L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L,
  ]) // w32.after.63
  assert_eq(bool_of(() => b.contains(63L)), "OK:true") // c32.63|OK:true
  b.add(64L)
  assert_eq(b.words(), [
    -2147483645L, -2147483645L, 1L, 0L, 0L, 0L, 0L, 0L, 0L, 0L,
  ]) // w32.after.64
  assert_eq(bool_of(() => b.contains(64L)), "OK:true") // c32.64|OK:true
  b.add(99L)
  assert_eq(b.words(), [
    -2147483645L, -2147483645L, 1L, 8L, 0L, 0L, 0L, 0L, 0L, 0L,
  ]) // w32.after.99
  assert_eq(bool_of(() => b.contains(99L)), "OK:true") // c32.99|OK:true
  b.add(127L)
  assert_eq(b.words(), [
    -2147483645L, -2147483645L, 1L, -2147483640L, 0L, 0L, 0L, 0L, 0L, 0L,
  ]) // w32.after.127
  assert_eq(bool_of(() => b.contains(127L)), "OK:true") // c32.127|OK:true
  b.add(128L)
  assert_eq(b.words(), [
    -2147483645L, -2147483645L, 1L, -2147483640L, 1L, 0L, 0L, 0L, 0L, 0L,
  ]) // w32.after.128
  assert_eq(bool_of(() => b.contains(128L)), "OK:true") // c32.128|OK:true
  b.add(255L)
  assert_eq(b.words(), [
    -2147483645L, -2147483645L, 1L, -2147483640L, 1L, 0L, 0L, -2147483648L, 0L, 0L,
  ]) // w32.after.255
  assert_eq(bool_of(() => b.contains(255L)), "OK:true") // c32.255|OK:true
  b.add(319L)
  assert_eq(b.words(), [
    -2147483645L, -2147483645L, 1L, -2147483640L, 1L, 0L, 0L, -2147483648L, 0L, -2147483648L,
  ]) // w32.after.319
  assert_eq(bool_of(() => b.contains(319L)), "OK:true") // c32.319|OK:true
  b.remove(31L)
  assert_eq(b.words(), [
    3L, -2147483645L, 1L, -2147483640L, 1L, 0L, 0L, -2147483648L, 0L, -2147483648L,
  ]) // w32.remove31
  assert_eq(bool_of(() => b.contains(31L)), "OK:false") // c32.after.remove31
  b.remove(31L)
  assert_eq(b.words(), [
    3L, -2147483645L, 1L, -2147483640L, 1L, 0L, 0L, -2147483648L, 0L, -2147483648L,
  ]) // w32.remove31.again（重复清位 ⇒ 词表不变）
  assert_eq(unit_of(() => b.add(320L)), "IndexOutOfRange:10,10") // oob.add.320|java.lang.ArrayIndexOutOfBoundsException:Index 10 out of bounds for length 10
  assert_eq(bool_of(() => b.contains(320L)), "IndexOutOfRange:10,10") // oob.contains.320|java.lang.ArrayIndexOutOfBoundsException:Index 10 out of bounds for length 10
  // 负位置不越界：向零截断 ⇒ r = -1/32 = 0，而 -1 & 31 = 31 ⇒ 静默污染第 0 词的符号位
  b.add(-1L)
  assert_eq(b.words(), [
    -2147483645L, -2147483645L, 1L, -2147483640L, 1L, 0L, 0L, -2147483648L, 0L, -2147483648L,
  ]) // w32.after.neg
  assert_eq(bool_of(() => b.contains(-1L)), "OK:true") // c32.neg
  assert_eq(bool_of(() => b.contains(31L)), "OK:true") // c32.bit31（同一位从两个入口都读得到）
  // 超 int 范围先窄化回绕：2^40 回绕成 r=0（静默），2^32 回绕成 134217728 才撞越界
  b.add(1099511627776L)
  assert_eq(b.words(), [
    -2147483637L, -2147483645L, 1L, -2147483640L, 1L, 0L, 0L, -2147483648L, 0L, -2147483648L,
  ]) // oob.add.2^37.plus（2^40 那一步之后的终态；oob.add.2^40|OK:no-throw）
  assert_eq(unit_of(() => b.add(4294967296L)), "IndexOutOfRange:134217728,10") // oob.add.2^32|java.lang.ArrayIndexOutOfBoundsException:Index 134217728 out of bounds for length 10
}

///|
test "bloom 位图层（64 位档）：词表含 1L<<63 的负读数" {
  let b = @bloom.new_bit_field(640L, width=@bloom.W64)
  b.add(0L)
  assert_eq(b.words(), [1L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L]) // w64.after.0
  assert_eq(bool_of(() => b.contains(0L)), "OK:true") // c64.0|OK:true
  b.add(1L)
  assert_eq(b.words(), [3L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L]) // w64.after.1
  assert_eq(bool_of(() => b.contains(1L)), "OK:true") // c64.1|OK:true
  b.add(63L)
  assert_eq(b.words(), [
    -9223372036854775805L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L,
  ]) // w64.after.63
  assert_eq(bool_of(() => b.contains(63L)), "OK:true") // c64.63|OK:true
  b.add(64L)
  assert_eq(b.words(), [
    -9223372036854775805L, 1L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L,
  ]) // w64.after.64
  assert_eq(bool_of(() => b.contains(64L)), "OK:true") // c64.64|OK:true
  b.add(65L)
  assert_eq(b.words(), [
    -9223372036854775805L, 3L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L,
  ]) // w64.after.65
  assert_eq(bool_of(() => b.contains(65L)), "OK:true") // c64.65|OK:true
  b.add(127L)
  assert_eq(b.words(), [
    -9223372036854775805L, -9223372036854775805L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L,
  ]) // w64.after.127
  assert_eq(bool_of(() => b.contains(127L)), "OK:true") // c64.127|OK:true
  b.add(128L)
  assert_eq(b.words(), [
    -9223372036854775805L, -9223372036854775805L, 1L, 0L, 0L, 0L, 0L, 0L, 0L, 0L,
  ]) // w64.after.128
  assert_eq(bool_of(() => b.contains(128L)), "OK:true") // c64.128|OK:true
  b.add(199L)
  assert_eq(b.words(), [
    -9223372036854775805L, -9223372036854775805L, 1L, 128L, 0L, 0L, 0L, 0L, 0L, 0L,
  ]) // w64.after.199
  assert_eq(bool_of(() => b.contains(199L)), "OK:true") // c64.199|OK:true
  b.add(639L)
  assert_eq(b.words(), [
    -9223372036854775805L, -9223372036854775805L, 1L, 128L, 0L, 0L, 0L, 0L, 0L, -9223372036854775808L,
  ]) // w64.after.639
  assert_eq(bool_of(() => b.contains(639L)), "OK:true") // c64.639|OK:true
  b.remove(63L)
  assert_eq(b.words(), [
    3L, -9223372036854775805L, 1L, 128L, 0L, 0L, 0L, 0L, 0L, -9223372036854775808L,
  ]) // w64.remove63
  assert_eq(bool_of(() => b.contains(63L)), "OK:false") // c64.after.remove63
  // 负位置在 64 位档同构：-1 & 63 = 63 ⇒ 污染 long 的符号位
  b.add(-1L)
  assert_eq(b.words(), [
    -9223372036854775805L, -9223372036854775805L, 1L, 128L, 0L, 0L, 0L, 0L, 0L, -9223372036854775808L,
  ]) // w64.after.neg
  assert_eq(bool_of(() => b.contains(-1L)), "OK:true") // c64.neg|OK:true
  assert_eq(unit_of(() => b.add(640L)), "IndexOutOfRange:10,10") // oob64.add.640|java.lang.ArrayIndexOutOfBoundsException:Index 10 out of bounds for length 10
}

///|
test "bloom 词数截断：bits 不是 32 的整数倍时尾部位不可用" {
  let b = @bloom.new_bit_field(1000L)
  assert_eq(b.word_count(), 31) // trunc.words.1000（(int)(1000/32)=31 ⇒ 合法下标只有 0..30）
  assert_eq(unit_of(() => b.add(999L)), "IndexOutOfRange:31,31") // trunc.oob.999|java.lang.ArrayIndexOutOfBoundsException:Index 31 out of bounds for length 31
  b.add(959L)
  assert_eq(bool_of(() => b.contains(959L)), "OK:true") // trunc.inrange.959
  b.add(991L)
  assert_eq(bool_of(() => b.contains(991L)), "OK:true") // trunc.max.valid.991（最后一个可用位）
}

///|
test "bloom 过滤器层：首次 add true / 再入 false，contains 只问那一位" {
  let f = @bloom.new_filter(320L, hfn("elf"))
  assert_eq(f.position("a"), 97L) // f.elf.pos.a（与 bit.320.elf.1|97 同值）
  assert_eq(f.add("a"), true) // f.elf.add1.a
  assert_eq(f.add("a"), false) // f.elf.add2.a（已置位 ⇒ false，不覆盖也不计次）
  assert_eq(f.contains("a"), true) // f.elf.contains.a
  assert_eq(f.contains("zz"), false) // f.elf.contains.zz
  assert_eq(f.add("zz"), true) // f.elf.add1.zz
  assert_eq(f.contains("zz"), true) // f.elf.contains.zz.after
  assert_eq(f.words(), [0L, 0L, 0L, 2L, 67108864L, 0L, 0L, 0L, 0L, 0L]) // f.elf.words
  // size=0 的失败时机：构造成功，第一次取模才炸（bf.m1.*）
  assert_eq(
    i64_of(() => @bloom.new_filter(0L, hfn("elf")).position("a")),
    "ZeroSize",
  ) // bf.m1.contains|java.lang.ArithmeticException:/ by zero
  assert_eq(
    bool_of(() => @bloom.new_filter(0L, hfn("elf")).contains("a")),
    "ZeroSize",
  ) // bf.m1.add|java.lang.ArithmeticException:/ by zero
  // f.elf.collides.with.abc|OK:none —— 这批夹具在 size=320 下没有与 abc 同位的另一条串，碰撞在块 8 的极小档上钉
}

///|
test "bloom 极小 size（32 位）：碰撞、假阳性与逐串序列" {
  let f = @bloom.new_filter(32L, hfn("elf"))
  assert_eq(f.position(""), 0L) // tiny.bit.0（pos=0）
  assert_eq(f.add(""), true) // tiny.add.0
  assert_eq(f.add(""), false) // tiny.add.again.0
  assert_eq(f.contains(""), true) // tiny.contains.0
  assert_eq(@bloom.new_filter(32L, hfn("elf")).contains(""), false) // tiny.contains.not.added.0（空过滤器对照档）
  assert_eq(f.position("a"), 1L) // tiny.bit.1（pos=1）
  assert_eq(f.add("a"), true) // tiny.add.1
  assert_eq(f.add("a"), false) // tiny.add.again.1
  assert_eq(f.contains("a"), true) // tiny.contains.1
  assert_eq(@bloom.new_filter(32L, hfn("elf")).contains("a"), false) // tiny.contains.not.added.1（空过滤器对照档）
  assert_eq(f.position("abc"), 3L) // tiny.bit.2（pos=3）
  assert_eq(f.add("abc"), true) // tiny.add.2
  assert_eq(f.add("abc"), false) // tiny.add.again.2
  assert_eq(f.contains("abc"), true) // tiny.contains.2
  assert_eq(@bloom.new_filter(32L, hfn("elf")).contains("abc"), false) // tiny.contains.not.added.2（空过滤器对照档）
  assert_eq(f.position("axc"), 3L) // tiny.bit.3（pos=3）
  assert_eq(f.add("axc"), false) // tiny.add.3
  assert_eq(f.add("axc"), false) // tiny.add.again.3
  assert_eq(f.contains("axc"), true) // tiny.contains.3
  assert_eq(@bloom.new_filter(32L, hfn("elf")).contains("axc"), false) // tiny.contains.not.added.3（空过滤器对照档）
  assert_eq(f.position("hello"), 15L) // tiny.bit.4（pos=15）
  assert_eq(f.add("hello"), true) // tiny.add.4
  assert_eq(f.add("hello"), false) // tiny.add.again.4
  assert_eq(f.contains("hello"), true) // tiny.contains.4
  assert_eq(@bloom.new_filter(32L, hfn("elf")).contains("hello"), false) // tiny.contains.not.added.4（空过滤器对照档）
  assert_eq(f.position("HELLO"), 15L) // tiny.bit.5（pos=15）
  assert_eq(f.add("HELLO"), false) // tiny.add.5
  assert_eq(f.add("HELLO"), false) // tiny.add.again.5
  assert_eq(f.contains("HELLO"), true) // tiny.contains.5
  assert_eq(@bloom.new_filter(32L, hfn("elf")).contains("HELLO"), false) // tiny.contains.not.added.5（空过滤器对照档）
  assert_eq(f.position("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"), 15L) // tiny.bit.6（pos=15）
  assert_eq(f.add("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"), false) // tiny.add.6
  assert_eq(f.add("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"), false) // tiny.add.again.6
  assert_eq(
    f.contains("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    true,
  ) // tiny.contains.6
  assert_eq(
    @bloom.new_filter(32L, hfn("elf")).contains(
      "\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}",
    ),
    false,
  ) // tiny.contains.not.added.6（空过滤器对照档）
  assert_eq(f.position("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), 5L) // tiny.bit.7（pos=5）
  assert_eq(f.add("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), true) // tiny.add.7
  assert_eq(f.add("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), false) // tiny.add.again.7
  assert_eq(f.contains("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), true) // tiny.contains.7
  assert_eq(
    @bloom.new_filter(32L, hfn("elf")).contains(
      "\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}",
    ),
    false,
  ) // tiny.contains.not.added.7（空过滤器对照档）
  assert_eq(f.position("\u{1f34e}a"), 1L) // tiny.bit.8（pos=1）
  assert_eq(f.add("\u{1f34e}a"), false) // tiny.add.8
  assert_eq(f.add("\u{1f34e}a"), false) // tiny.add.again.8
  assert_eq(f.contains("\u{1f34e}a"), true) // tiny.contains.8
  assert_eq(@bloom.new_filter(32L, hfn("elf")).contains("\u{1f34e}a"), false) // tiny.contains.not.added.8（空过滤器对照档）
  assert_eq(f.position("a b c"), 3L) // tiny.bit.9（pos=3）
  assert_eq(f.add("a b c"), false) // tiny.add.9
  assert_eq(f.add("a b c"), false) // tiny.add.again.9
  assert_eq(f.contains("a b c"), true) // tiny.contains.9
  assert_eq(@bloom.new_filter(32L, hfn("elf")).contains("a b c"), false) // tiny.contains.not.added.9（空过滤器对照档）
  assert_eq(f.position("0123456789"), 9L) // tiny.bit.10（pos=9）
  assert_eq(f.add("0123456789"), true) // tiny.add.10
  assert_eq(f.add("0123456789"), false) // tiny.add.again.10
  assert_eq(f.contains("0123456789"), true) // tiny.contains.10
  assert_eq(@bloom.new_filter(32L, hfn("elf")).contains("0123456789"), false) // tiny.contains.not.added.10（空过滤器对照档）
  assert_eq(f.position("Java JavaScript"), 20L) // tiny.bit.11（pos=20）
  assert_eq(f.add("Java JavaScript"), true) // tiny.add.11
  assert_eq(f.add("Java JavaScript"), false) // tiny.add.again.11
  assert_eq(f.contains("Java JavaScript"), true) // tiny.contains.11
  assert_eq(
    @bloom.new_filter(32L, hfn("elf")).contains("Java JavaScript"),
    false,
  ) // tiny.contains.not.added.11（空过滤器对照档）
  assert_eq(f.position("aaaaaaaa"), 1L) // tiny.bit.12（pos=1）
  assert_eq(f.add("aaaaaaaa"), false) // tiny.add.12
  assert_eq(f.add("aaaaaaaa"), false) // tiny.add.again.12
  assert_eq(f.contains("aaaaaaaa"), true) // tiny.contains.12
  assert_eq(@bloom.new_filter(32L, hfn("elf")).contains("aaaaaaaa"), false) // tiny.contains.not.added.12（空过滤器对照档）
  assert_eq(f.position("zz"), 26L) // tiny.bit.13（pos=26）
  assert_eq(f.add("zz"), true) // tiny.add.13
  assert_eq(f.add("zz"), false) // tiny.add.again.13
  assert_eq(f.contains("zz"), true) // tiny.contains.13
  assert_eq(@bloom.new_filter(32L, hfn("elf")).contains("zz"), false) // tiny.contains.not.added.13（空过滤器对照档）
  assert_eq(f.words(), [68190763L]) // tiny.words（终态词表：假阳性的物证）
  // 从未加入却报"已存在"的那几条：i=3, i=5, i=6, i=8, i=9, i=12
}

///|
test "bloom 聚合层：默认五过滤器（java_default/elf/js/pjw/sdbm）的序列读数" {
  let b = @bloom.new_bloom(6)
  assert_eq(b.add("a"), true) // bf.m6.add1.a
  assert_eq(b.add("a"), false) // bf.m6.add2.a
  assert_eq(b.contains("a"), true) // bf.m6.contains.a
  assert_eq(b.contains("zz"), false) // bf.m6.contains.zz
  assert_eq(b.contains(""), false) // bf.m6.contains.0
  assert_eq(b.add(""), true) // bf.m6.add.0
  assert_eq(b.add(""), false) // bf.m6.add.again.0
  assert_eq(b.contains(""), true) // bf.m6.contains.after.0
  assert_eq(b.contains("a"), true) // bf.m6.contains.1
  assert_eq(b.add("a"), false) // bf.m6.add.1
  assert_eq(b.add("a"), false) // bf.m6.add.again.1
  assert_eq(b.contains("a"), true) // bf.m6.contains.after.1
  assert_eq(b.contains("abc"), false) // bf.m6.contains.2
  assert_eq(b.add("abc"), true) // bf.m6.add.2
  assert_eq(b.add("abc"), false) // bf.m6.add.again.2
  assert_eq(b.contains("abc"), true) // bf.m6.contains.after.2
  assert_eq(b.contains("axc"), false) // bf.m6.contains.3
  assert_eq(b.add("axc"), true) // bf.m6.add.3
  assert_eq(b.add("axc"), false) // bf.m6.add.again.3
  assert_eq(b.contains("axc"), true) // bf.m6.contains.after.3
  assert_eq(b.contains("hello"), false) // bf.m6.contains.4
  assert_eq(b.add("hello"), true) // bf.m6.add.4
  assert_eq(b.add("hello"), false) // bf.m6.add.again.4
  assert_eq(b.contains("hello"), true) // bf.m6.contains.after.4
  assert_eq(b.contains("HELLO"), false) // bf.m6.contains.5
  assert_eq(b.add("HELLO"), true) // bf.m6.add.5
  assert_eq(b.add("HELLO"), false) // bf.m6.add.again.5
  assert_eq(b.contains("HELLO"), true) // bf.m6.contains.after.5
  assert_eq(
    b.contains("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    false,
  ) // bf.m6.contains.6
  assert_eq(b.add("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"), true) // bf.m6.add.6
  assert_eq(b.add("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"), false) // bf.m6.add.again.6
  assert_eq(
    b.contains("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    true,
  ) // bf.m6.contains.after.6
  assert_eq(b.contains("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), false) // bf.m6.contains.7
  assert_eq(b.add("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), true) // bf.m6.add.7
  assert_eq(b.add("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), false) // bf.m6.add.again.7
  assert_eq(b.contains("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), true) // bf.m6.contains.after.7
  assert_eq(b.contains("\u{1f34e}a"), false) // bf.m6.contains.8
  assert_eq(b.add("\u{1f34e}a"), true) // bf.m6.add.8
  assert_eq(b.add("\u{1f34e}a"), false) // bf.m6.add.again.8
  assert_eq(b.contains("\u{1f34e}a"), true) // bf.m6.contains.after.8
  assert_eq(b.contains("a b c"), false) // bf.m6.contains.9
  assert_eq(b.add("a b c"), true) // bf.m6.add.9
  assert_eq(b.add("a b c"), false) // bf.m6.add.again.9
  assert_eq(b.contains("a b c"), true) // bf.m6.contains.after.9
  assert_eq(b.contains("0123456789"), false) // bf.m6.contains.10
  assert_eq(b.add("0123456789"), true) // bf.m6.add.10
  assert_eq(b.add("0123456789"), false) // bf.m6.add.again.10
  assert_eq(b.contains("0123456789"), true) // bf.m6.contains.after.10
  assert_eq(b.contains("Java JavaScript"), false) // bf.m6.contains.11
  assert_eq(b.add("Java JavaScript"), true) // bf.m6.add.11
  assert_eq(b.add("Java JavaScript"), false) // bf.m6.add.again.11
  assert_eq(b.contains("Java JavaScript"), true) // bf.m6.contains.after.11
  assert_eq(b.contains("aaaaaaaa"), false) // bf.m6.contains.12
  assert_eq(b.add("aaaaaaaa"), true) // bf.m6.add.12
  assert_eq(b.add("aaaaaaaa"), false) // bf.m6.add.again.12
  assert_eq(b.contains("aaaaaaaa"), true) // bf.m6.contains.after.12
  assert_eq(b.contains("zz"), false) // bf.m6.contains.13
  assert_eq(b.add("zz"), true) // bf.m6.add.13
  assert_eq(b.add("zz"), false) // bf.m6.add.again.13
  assert_eq(b.contains("zz"), true) // bf.m6.contains.after.13
}

///|
test "bloom 聚合层：自定义过滤器组（不重造 varargs 的白分配）" {
  let one = @bloom.new_bloom_with([@bloom.new_filter(320L, hfn("elf"))])
  assert_eq(one.add("abc"), true) // bf.one.add1
  assert_eq(one.add("abc"), false) // bf.one.add2
  let two = @bloom.new_bloom_with([
    @bloom.new_filter(320L, hfn("elf")),
    @bloom.new_filter(320L, hfn("js")),
  ])
  assert_eq(two.add("hello"), true) // bf.two.add1
  assert_eq(two.add("hello"), false) // bf.two.add2
  assert_eq(two.contains("hello"), true) // bf.two.contains
  let mix = @bloom.new_bloom_with([
    @bloom.new_filter(320L, hfn("elf")),
    @bloom.new_filter(1000003L, hfn("elf")),
  ])
  let _ = mix.add("abc")
  assert_eq(mix.add("abc"), false) // bf.mix.again.abc（两侧都已含 ⇒ OR 与 AND 在这里同值，区分档在块 11）
}

///|
test "bloom 聚合层 add 的语义边界：两个过滤器状态不一致的五个档" {
  let q = @bloom.new_bloom_with([
    @bloom.new_filter(32L, hfn("elf")),
    @bloom.new_filter(32L, hfn("sdbm")),
  ])
  let a = @bloom.new_filter(32L, hfn("elf"))
  let b = @bloom.new_filter(32L, hfn("sdbm"))
  // 与参照腿同序重放。q.c.elf.i / q.c.sdbm.i 是反射出来的**两个过滤器各自**的 contains；
  // 状态不一致的五条（i=3/6/8/9/13）就是 add 取逻辑或还是逻辑与的分岔点——改成与就报 false
  assert_eq(a.contains(""), false) // q.c.elf.0
  assert_eq(b.contains(""), false) // q.c.sdbm.0
  assert_eq(q.contains(""), false) // q.before.0（= 两条 contains 之与）
  assert_eq(q.add(""), true) // q.add.0（= 两条 add 之或）
  assert_eq(q.contains(""), true) // q.after.0
  assert_eq(q.add(""), false) // q.again.0
  let _ = a.add("")
  let _ = b.add("")
  assert_eq(a.contains("a"), false) // q.c.elf.1
  assert_eq(b.contains("a"), false) // q.c.sdbm.1
  assert_eq(q.contains("a"), false) // q.before.1（= 两条 contains 之与）
  assert_eq(q.add("a"), true) // q.add.1（= 两条 add 之或）
  assert_eq(q.contains("a"), true) // q.after.1
  assert_eq(q.add("a"), false) // q.again.1
  let _ = a.add("a")
  let _ = b.add("a")
  assert_eq(a.contains("abc"), false) // q.c.elf.2
  assert_eq(b.contains("abc"), false) // q.c.sdbm.2
  assert_eq(q.contains("abc"), false) // q.before.2（= 两条 contains 之与）
  assert_eq(q.add("abc"), true) // q.add.2（= 两条 add 之或）
  assert_eq(q.contains("abc"), true) // q.after.2
  assert_eq(q.add("abc"), false) // q.again.2
  let _ = a.add("abc")
  let _ = b.add("abc")
  assert_eq(a.contains("axc"), true) // q.c.elf.3
  assert_eq(b.contains("axc"), false) // q.c.sdbm.3
  assert_eq(q.contains("axc"), false) // q.before.3（= 两条 contains 之与）
  assert_eq(q.add("axc"), true) // q.add.3（= 两条 add 之或）
  assert_eq(q.contains("axc"), true) // q.after.3
  assert_eq(q.add("axc"), false) // q.again.3
  let _ = a.add("axc")
  let _ = b.add("axc")
  assert_eq(a.contains("hello"), false) // q.c.elf.4
  assert_eq(b.contains("hello"), false) // q.c.sdbm.4
  assert_eq(q.contains("hello"), false) // q.before.4（= 两条 contains 之与）
  assert_eq(q.add("hello"), true) // q.add.4（= 两条 add 之或）
  assert_eq(q.contains("hello"), true) // q.after.4
  assert_eq(q.add("hello"), false) // q.again.4
  let _ = a.add("hello")
  let _ = b.add("hello")
  assert_eq(a.contains("HELLO"), true) // q.c.elf.5
  assert_eq(b.contains("HELLO"), true) // q.c.sdbm.5
  assert_eq(q.contains("HELLO"), true) // q.before.5（= 两条 contains 之与）
  assert_eq(q.add("HELLO"), false) // q.add.5（= 两条 add 之或）
  assert_eq(q.contains("HELLO"), true) // q.after.5
  assert_eq(q.add("HELLO"), false) // q.again.5
  let _ = a.add("HELLO")
  let _ = b.add("HELLO")
  assert_eq(
    a.contains("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    true,
  ) // q.c.elf.6
  assert_eq(
    b.contains("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    false,
  ) // q.c.sdbm.6
  assert_eq(
    q.contains("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    false,
  ) // q.before.6（= 两条 contains 之与）
  assert_eq(q.add("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"), true) // q.add.6（= 两条 add 之或）
  assert_eq(
    q.contains("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"),
    true,
  ) // q.after.6
  assert_eq(q.add("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}"), false) // q.again.6
  let _ = a.add("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}")
  let _ = b.add("\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}")
  assert_eq(a.contains("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), false) // q.c.elf.7
  assert_eq(b.contains("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), false) // q.c.sdbm.7
  assert_eq(q.contains("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), false) // q.before.7（= 两条 contains 之与）
  assert_eq(q.add("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), true) // q.add.7（= 两条 add 之或）
  assert_eq(q.contains("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), true) // q.after.7
  assert_eq(q.add("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}"), false) // q.again.7
  let _ = a.add("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}")
  let _ = b.add("\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}")
  assert_eq(a.contains("\u{1f34e}a"), true) // q.c.elf.8
  assert_eq(b.contains("\u{1f34e}a"), false) // q.c.sdbm.8
  assert_eq(q.contains("\u{1f34e}a"), false) // q.before.8（= 两条 contains 之与）
  assert_eq(q.add("\u{1f34e}a"), true) // q.add.8（= 两条 add 之或）
  assert_eq(q.contains("\u{1f34e}a"), true) // q.after.8
  assert_eq(q.add("\u{1f34e}a"), false) // q.again.8
  let _ = a.add("\u{1f34e}a")
  let _ = b.add("\u{1f34e}a")
  assert_eq(a.contains("a b c"), true) // q.c.elf.9
  assert_eq(b.contains("a b c"), false) // q.c.sdbm.9
  assert_eq(q.contains("a b c"), false) // q.before.9（= 两条 contains 之与）
  assert_eq(q.add("a b c"), true) // q.add.9（= 两条 add 之或）
  assert_eq(q.contains("a b c"), true) // q.after.9
  assert_eq(q.add("a b c"), false) // q.again.9
  let _ = a.add("a b c")
  let _ = b.add("a b c")
  assert_eq(a.contains("0123456789"), false) // q.c.elf.10
  assert_eq(b.contains("0123456789"), false) // q.c.sdbm.10
  assert_eq(q.contains("0123456789"), false) // q.before.10（= 两条 contains 之与）
  assert_eq(q.add("0123456789"), true) // q.add.10（= 两条 add 之或）
  assert_eq(q.contains("0123456789"), true) // q.after.10
  assert_eq(q.add("0123456789"), false) // q.again.10
  let _ = a.add("0123456789")
  let _ = b.add("0123456789")
  assert_eq(a.contains("Java JavaScript"), false) // q.c.elf.11
  assert_eq(b.contains("Java JavaScript"), false) // q.c.sdbm.11
  assert_eq(q.contains("Java JavaScript"), false) // q.before.11（= 两条 contains 之与）
  assert_eq(q.add("Java JavaScript"), true) // q.add.11（= 两条 add 之或）
  assert_eq(q.contains("Java JavaScript"), true) // q.after.11
  assert_eq(q.add("Java JavaScript"), false) // q.again.11
  let _ = a.add("Java JavaScript")
  let _ = b.add("Java JavaScript")
  assert_eq(a.contains("aaaaaaaa"), true) // q.c.elf.12
  assert_eq(b.contains("aaaaaaaa"), true) // q.c.sdbm.12
  assert_eq(q.contains("aaaaaaaa"), true) // q.before.12（= 两条 contains 之与）
  assert_eq(q.add("aaaaaaaa"), false) // q.add.12（= 两条 add 之或）
  assert_eq(q.contains("aaaaaaaa"), true) // q.after.12
  assert_eq(q.add("aaaaaaaa"), false) // q.again.12
  let _ = a.add("aaaaaaaa")
  let _ = b.add("aaaaaaaa")
  assert_eq(a.contains("zz"), false) // q.c.elf.13
  assert_eq(b.contains("zz"), true) // q.c.sdbm.13
  assert_eq(q.contains("zz"), false) // q.before.13（= 两条 contains 之与）
  assert_eq(q.add("zz"), true) // q.add.13（= 两条 add 之或）
  assert_eq(q.contains("zz"), true) // q.after.13
  assert_eq(q.add("zz"), false) // q.again.13
  let _ = a.add("zz")
  let _ = b.add("zz")
  assert_eq(a.words(), [68190763L]) // q.words.elf（两个过滤器终态词表）
  assert_eq(b.words(), [17078391L]) // q.words.sdbm
  // 定义内假阳性两条直读：q.before.5|true、q.before.12|true，而这两条串此前都没 add 过
}

///|
test "bloom 报错档：ZeroSize 在第一次取模、BadBitCount 在构造期" {
  assert_eq(bool_of(() => @bloom.new_bloom(1).contains("a")), "ZeroSize") // bf.m1.contains|java.lang.ArithmeticException:/ by zero（m<5 ⇒ bits=0）
  assert_eq(bool_of(() => @bloom.new_bloom(0).contains("a")), "ZeroSize") // bf.m0.contains|java.lang.ArithmeticException:/ by zero
  assert_eq(bloom_of(() => @bloom.new_bloom(-5)), "BadBitCount:-8388608") // bf.negm|java.lang.NegativeArraySizeException:-262144
  assert_eq(bloom_of(() => @bloom.new_bloom(6)), "OK") // 构造侧：bf.m6.* 那批读数的来路（machine.64|OK:true 一侧见块 5）
}
