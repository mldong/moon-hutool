///|
// hash 第一批的期望值全部由生成脚本从 `hash_ref.txt`（参照腿 398 条读数）灌入，手打零条。
// 参照腿：`hutool-core-5.8.35.jar` 的 `cn.hutool.core.util.HashUtil` + `lang.hash.MurmurHash` +
// `io.checksum.{CRC8,CRC16}` 与十个 `crc16/CRC16*` 变体 + 本机 JDK 17.0.14；`javac -encoding UTF-8`，
// 非 ASCII 夹具在 Java 侧写 Unicode 转义（`digest` 轮那条编码教训的形状）。
// 这批 10 块 452 条断言落地后全绿。**每条 `assert_*` 的右侧与契约笔 `56c1077` 逐字同形**；
// 落地笔动的是夹具左边：`b_cn` / `b_emoji` 两份字节列表是我手打错的 UTF-8，现改成与参照腿
// `StandardCharsets.UTF_8` 同源（今后字节夹具一律由生成脚本算出，不手打）；另把一条"两个函数之和
// == 某读数"的病断言拆成两条各比各的——左边那个表达式在参照腿里根本没有对应读数。
// 位置口径：hutool 返回 Java `int`/`long`，本库公开面是有符号 `Int`/`Int64`，与读数十进制逐字同形。

///|
// 错误档归一名（`show` 在黑盒面不在作用域）
fn err_tag(e : @hash.HashError) -> String {
  match e {
    @hash.ZeroPrime => "ZeroPrime"
  }
}

///|
fn[A] err_of(r : () -> A raise @hash.HashError) -> String {
  try {
    let _ = r()
    "OK"
  } catch {
    e => err_tag(e)
  }
}

///|
// Int 列表 → `Bytes`（参照侧的 `new byte[]{...}`；`to_byte` 截断低 8 位，0xff 那档就是这么来的）
fn bytes_of(xs : Array[Int]) -> Bytes {
  Bytes::from_array(xs.map(x => x.to_byte()))
}

///|

///|
test "hash additive/rotating：模数档的三组读数与除零档" {
  assert_eq(@hash.additive_hash("", 7), 0) // add.7.empty
  assert_eq(@hash.additive_hash("", 101), 0) // add.101.empty
  assert_eq(@hash.additive_hash("", -7), 0) // add.neg7.empty
  assert_eq(err_of(() => @hash.additive_hash("", 0)), "ZeroPrime") // add.0.empty
  assert_eq(@hash.additive_hash("a", 7), 0) // add.7.a
  assert_eq(@hash.additive_hash("a", 101), 98) // add.101.a
  assert_eq(@hash.additive_hash("a", -7), 0) // add.neg7.a
  assert_eq(err_of(() => @hash.additive_hash("a", 0)), "ZeroPrime") // add.0.a
  assert_eq(@hash.additive_hash("abc", 7), 3) // add.7.abc
  assert_eq(@hash.additive_hash("abc", 101), 95) // add.101.abc
  assert_eq(@hash.additive_hash("abc", -7), 3) // add.neg7.abc
  assert_eq(err_of(() => @hash.additive_hash("abc", 0)), "ZeroPrime") // add.0.abc
  assert_eq(@hash.additive_hash("hello world", 7), 0) // add.7.hw
  assert_eq(@hash.additive_hash("hello world", 101), 16) // add.101.hw
  assert_eq(@hash.additive_hash("hello world", -7), 0) // add.neg7.hw
  assert_eq(err_of(() => @hash.additive_hash("hello world", 0)), "ZeroPrime") // add.0.hw
  assert_eq(@hash.additive_hash("123456789", 7), 3) // add.7.digits
  assert_eq(@hash.additive_hash("123456789", 101), 82) // add.101.digits
  assert_eq(@hash.additive_hash("123456789", -7), 3) // add.neg7.digits
  assert_eq(err_of(() => @hash.additive_hash("123456789", 0)), "ZeroPrime") // add.0.digits
  assert_eq(@hash.additive_hash("abcd", 7), 6) // add.7.abcd
  assert_eq(@hash.additive_hash("abcd", 101), 95) // add.101.abcd
  assert_eq(@hash.additive_hash("abcd", -7), 6) // add.neg7.abcd
  assert_eq(err_of(() => @hash.additive_hash("abcd", 0)), "ZeroPrime") // add.0.abcd
  assert_eq(@hash.additive_hash("a]b[c", 7), 0) // add.7.brack
  assert_eq(@hash.additive_hash("a]b[c", 101), 79) // add.101.brack
  assert_eq(@hash.additive_hash("a]b[c", -7), 0) // add.neg7.brack
  assert_eq(err_of(() => @hash.additive_hash("a]b[c", 0)), "ZeroPrime") // add.0.brack
  assert_eq(@hash.additive_hash("  x  ", 7), 1) // add.7.spaced
  assert_eq(@hash.additive_hash("  x  ", 101), 51) // add.101.spaced
  assert_eq(@hash.additive_hash("  x  ", -7), 1) // add.neg7.spaced
  assert_eq(err_of(() => @hash.additive_hash("  x  ", 0)), "ZeroPrime") // add.0.spaced
  assert_eq(@hash.rotating_hash("", 7), 0) // rot.7.empty
  assert_eq(@hash.rotating_hash("", -7), 0) // rot.neg7.empty
  assert_eq(err_of(() => @hash.rotating_hash("", 0)), "ZeroPrime") // rot.0.empty
  assert_eq(@hash.rotating_hash("a", 7), 1) // rot.7.a
  assert_eq(@hash.rotating_hash("a", -7), 1) // rot.neg7.a
  assert_eq(err_of(() => @hash.rotating_hash("a", 0)), "ZeroPrime") // rot.0.a
  assert_eq(@hash.rotating_hash("abc", 7), 2) // rot.7.abc
  assert_eq(@hash.rotating_hash("abc", -7), 2) // rot.neg7.abc
  assert_eq(err_of(() => @hash.rotating_hash("abc", 0)), "ZeroPrime") // rot.0.abc
  assert_eq(@hash.rotating_hash("hello world", 7), 3) // rot.7.hw
  assert_eq(@hash.rotating_hash("hello world", -7), 3) // rot.neg7.hw
  assert_eq(err_of(() => @hash.rotating_hash("hello world", 0)), "ZeroPrime") // rot.0.hw
  assert_eq(@hash.rotating_hash("123456789", 7), 4) // rot.7.digits
  assert_eq(@hash.rotating_hash("123456789", -7), 4) // rot.neg7.digits
  assert_eq(err_of(() => @hash.rotating_hash("123456789", 0)), "ZeroPrime") // rot.0.digits
  assert_eq(@hash.rotating_hash("abcd", 7), 6) // rot.7.abcd
  assert_eq(@hash.rotating_hash("abcd", -7), 6) // rot.neg7.abcd
  assert_eq(err_of(() => @hash.rotating_hash("abcd", 0)), "ZeroPrime") // rot.0.abcd
  assert_eq(@hash.rotating_hash("a]b[c", 7), 4) // rot.7.brack
  assert_eq(@hash.rotating_hash("a]b[c", -7), 4) // rot.neg7.brack
  assert_eq(err_of(() => @hash.rotating_hash("a]b[c", 0)), "ZeroPrime") // rot.0.brack
  assert_eq(@hash.rotating_hash("  x  ", 7), 6) // rot.7.spaced
  assert_eq(@hash.rotating_hash("  x  ", -7), 6) // rot.neg7.spaced
  assert_eq(err_of(() => @hash.rotating_hash("  x  ", 0)), "ZeroPrime") // rot.0.spaced
}

///|
test "hash 逐字符族（oneByOne/bernstein/fnv/bkdr/sdbm/djb/dek/ap/rs/js/pjw/elf）" {
  assert_eq(@hash.one_by_one_hash(""), 0) // obob.empty
  assert_eq(@hash.one_by_one_hash("a"), -902917054) // obob.a
  assert_eq(@hash.one_by_one_hash("abc"), -317513893) // obob.abc
  assert_eq(@hash.one_by_one_hash("hello world"), -950532319) // obob.hw
  assert_eq(@hash.one_by_one_hash("123456789"), 117430049) // obob.digits
  assert_eq(@hash.one_by_one_hash("abcd"), 831971846) // obob.abcd
  assert_eq(@hash.one_by_one_hash("a]b[c"), 1768374773) // obob.brack
  assert_eq(@hash.one_by_one_hash("  x  "), 358565699) // obob.spaced
  assert_eq(@hash.one_by_one_hash("中文测试"), 82898354) // obob.cn
  assert_eq(@hash.one_by_one_hash("\u{1F34E}abc"), 250363434) // obob.emoji
  assert_eq(@hash.bernstein(""), 0) // bern.empty
  assert_eq(@hash.bernstein("a"), 97) // bern.a
  assert_eq(@hash.bernstein("abc"), 108966) // bern.abc
  assert_eq(@hash.bernstein("hello world"), 1239941340) // bern.hw
  assert_eq(@hash.bernstein("123456789"), 1135685853) // bern.digits
  assert_eq(@hash.bernstein("abcd"), 3595978) // bern.abcd
  assert_eq(@hash.bernstein("a]b[c"), 118486302) // bern.brack
  assert_eq(@hash.bernstein("  x  "), 39231224) // bern.spaced
  assert_eq(@hash.bernstein("中文测试"), 748470484) // bern.cn
  assert_eq(@hash.bernstein("\u{1F34E}abc"), -1017150352) // bern.emoji
  assert_eq(@hash.fnv_hash(""), 1494218850) // fnvS.empty
  assert_eq(@hash.fnv_hash("a"), 649470159) // fnvS.a
  assert_eq(@hash.fnv_hash("abc"), 34757373) // fnvS.abc
  assert_eq(@hash.fnv_hash("hello world"), 397057806) // fnvS.hw
  assert_eq(@hash.fnv_hash("123456789"), 1030266748) // fnvS.digits
  assert_eq(@hash.fnv_hash("abcd"), 567647560) // fnvS.abcd
  assert_eq(@hash.fnv_hash("a]b[c"), 1297258989) // fnvS.brack
  assert_eq(@hash.fnv_hash("  x  "), 1854211971) // fnvS.spaced
  assert_eq(@hash.fnv_hash("中文测试"), 1995683249) // fnvS.cn
  assert_eq(@hash.fnv_hash("\u{1F34E}abc"), 213115790) // fnvS.emoji
  assert_eq(@hash.rs_hash(""), 0) // rs.empty
  assert_eq(@hash.rs_hash("a"), 97) // rs.a
  assert_eq(@hash.rs_hash("abc"), 822160044) // rs.abc
  assert_eq(@hash.rs_hash("hello world"), 1099829460) // rs.hw
  assert_eq(@hash.rs_hash("123456789"), 1883853545) // rs.digits
  assert_eq(@hash.rs_hash("abcd"), 410699832) // rs.abcd
  assert_eq(@hash.rs_hash("a]b[c"), 169858840) // rs.brack
  assert_eq(@hash.rs_hash("  x  "), 1072361224) // rs.spaced
  assert_eq(@hash.js_hash(""), 1315423911) // js.empty
  assert_eq(@hash.js_hash("a"), 1359675315) // js.a
  assert_eq(@hash.js_hash("abc"), 895805535) // js.abc
  assert_eq(@hash.js_hash("hello world"), 1584116486) // js.hw
  assert_eq(@hash.js_hash("123456789"), 272835147) // js.digits
  assert_eq(@hash.js_hash("abcd"), 1936544307) // js.abcd
  assert_eq(@hash.js_hash("a]b[c"), 100686115) // js.brack
  assert_eq(@hash.js_hash("  x  "), 1566460849) // js.spaced
  assert_eq(@hash.pjw_hash(""), 0) // pjw.empty
  assert_eq(@hash.pjw_hash("a"), 97) // pjw.a
  assert_eq(@hash.pjw_hash("abc"), 26499) // pjw.abc
  assert_eq(@hash.pjw_hash("hello world"), 18588948) // pjw.hw
  assert_eq(@hash.pjw_hash("123456789"), 108572393) // pjw.digits
  assert_eq(@hash.pjw_hash("abcd"), 424084) // pjw.abcd
  assert_eq(@hash.pjw_hash("a]b[c"), 6764563) // pjw.brack
  assert_eq(@hash.pjw_hash("  x  "), 2259488) // pjw.spaced
  assert_eq(@hash.elf_hash(""), 0) // elf.empty
  assert_eq(@hash.elf_hash("a"), 97) // elf.a
  assert_eq(@hash.elf_hash("abc"), 26499) // elf.abc
  assert_eq(@hash.elf_hash("hello world"), 18588948) // elf.hw
  assert_eq(@hash.elf_hash("123456789"), 108572393) // elf.digits
  assert_eq(@hash.elf_hash("abcd"), 424084) // elf.abcd
  assert_eq(@hash.elf_hash("a]b[c"), 6764563) // elf.brack
  assert_eq(@hash.elf_hash("  x  "), 2259488) // elf.spaced
  assert_eq(@hash.bkdr_hash(""), 0) // bkdr.empty
  assert_eq(@hash.bkdr_hash("a"), 97) // bkdr.a
  assert_eq(@hash.bkdr_hash("abc"), 1677554) // bkdr.abc
  assert_eq(@hash.bkdr_hash("hello world"), 1310283332) // bkdr.hw
  assert_eq(@hash.bkdr_hash("123456789"), 1581504213) // bkdr.digits
  assert_eq(@hash.bkdr_hash("abcd"), 219759674) // bkdr.abcd
  assert_eq(@hash.bkdr_hash("a]b[c"), 859971174) // bkdr.brack
  assert_eq(@hash.bkdr_hash("  x  "), 908065336) // bkdr.spaced
  assert_eq(@hash.bkdr_hash("中文测试"), 343621172) // bkdr.cn
  assert_eq(@hash.bkdr_hash("\u{1F34E}abc"), 456283688) // bkdr.emoji
  assert_eq(@hash.sdbm_hash(""), 0) // sdbm.empty
  assert_eq(@hash.sdbm_hash("a"), 97) // sdbm.a
  assert_eq(@hash.sdbm_hash("abc"), 807794786) // sdbm.abc
  assert_eq(@hash.sdbm_hash("hello world"), 430867652) // sdbm.hw
  assert_eq(@hash.sdbm_hash("123456789"), 1755344949) // sdbm.digits
  assert_eq(@hash.sdbm_hash("abcd"), 1371152514) // sdbm.abcd
  assert_eq(@hash.sdbm_hash("a]b[c"), 1411832558) // sdbm.brack
  assert_eq(@hash.sdbm_hash("  x  "), 161301624) // sdbm.spaced
  assert_eq(@hash.sdbm_hash("中文测试"), 759916260) // sdbm.cn
  assert_eq(@hash.sdbm_hash("\u{1F34E}abc"), 681512912) // sdbm.emoji
  assert_eq(@hash.djb_hash(""), 5381) // djb.empty
  assert_eq(@hash.djb_hash("a"), 177670) // djb.a
  assert_eq(@hash.djb_hash("abc"), 193485963) // djb.abc
  assert_eq(@hash.djb_hash("hello world"), 894552257) // djb.hw
  assert_eq(@hash.djb_hash("123456789"), 902675330) // djb.digits
  assert_eq(@hash.djb_hash("abcd"), 2090069583) // djb.abcd
  assert_eq(@hash.djb_hash("a]b[c"), 252638531) // djb.brack
  assert_eq(@hash.djb_hash("  x  "), 173383453) // djb.spaced
  assert_eq(@hash.djb_hash("中文测试"), 687460441) // djb.cn
  assert_eq(@hash.djb_hash("\u{1F34E}abc"), 1264485525) // djb.emoji
  assert_eq(@hash.dek_hash(""), 0) // dek.empty
  assert_eq(@hash.dek_hash("a"), 65) // dek.a
  assert_eq(@hash.dek_hash("abc"), 2083) // dek.abc
  assert_eq(@hash.dek_hash("hello world"), 2090530144) // dek.hw
  assert_eq(@hash.dek_hash("123456789"), 1421161541) // dek.digits
  assert_eq(@hash.dek_hash("abcd"), 7406596) // dek.abcd
  assert_eq(@hash.dek_hash("a]b[c"), 205456131) // dek.brack
  assert_eq(@hash.dek_hash("  x  "), 135390240) // dek.spaced
  assert_eq(@hash.ap_hash(""), 0) // ap.empty
  assert_eq(@hash.ap_hash("a"), 97) // ap.a
  assert_eq(@hash.ap_hash("abc"), -25651485) // ap.abc
  assert_eq(@hash.ap_hash("hello world"), 1868401398) // ap.hw
  assert_eq(@hash.ap_hash("123456789"), 1502771343) // ap.digits
  assert_eq(@hash.ap_hash("abcd"), 985904591) // ap.abcd
  assert_eq(@hash.ap_hash("a]b[c"), 575206529) // ap.brack
  assert_eq(@hash.ap_hash("  x  "), -935455946) // ap.spaced
}

///|
test "hash fnv 两档的分岔与末尾 abs 可为负" {
  assert_eq(@hash.fnv_hash_bytes(bytes_of([])), 1494218850) // fnvB.b_empty
  assert_eq(@hash.fnv_hash_bytes(bytes_of([0])), 1873047837) // fnvB.b_00
  assert_eq(@hash.fnv_hash_bytes(bytes_of([255])), 2119403830) // fnvB.b_ff
  assert_eq(@hash.fnv_hash_bytes(bytes_of([1, 2, 3])), 1564936584) // fnvB.b_123
  assert_eq(
    @hash.fnv_hash_bytes(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57])),
    1030266748,
  ) // fnvB.b_digits
  assert_eq(@hash.fnv_hash_bytes(bytes_of([97, 98, 99])), 34757373) // fnvB.b_abc
  assert_eq(
    @hash.fnv_hash_bytes(
      bytes_of([228, 184, 173, 230, 150, 135, 230, 181, 139, 232, 175, 149]),
    ),
    2129874571,
  ) // fnvB.b_cn
  assert_eq(
    @hash.fnv_hash_bytes(bytes_of([240, 159, 141, 142, 97, 98, 99])),
    857138028,
  ) // fnvB.b_emoji
  assert_eq(@hash.fnv_hash_bytes(bytes_of([97, 98, 99, 100])), 567647560) // fnvB.b_abcd
  // 纯 ASCII 两档同值；非 ASCII 必分岔（spec §3 第 3 条）
  assert_eq(@hash.fnv_hash("abc"), 34757373) // fnvS.abc
  assert_eq(@hash.fnv_hash("123456789"), 1030266748) // fnvS.digits
  assert_eq(@hash.fnv_hash("中文测试"), 1995683249) // fnvS.cn
  assert_eq(
    @hash.fnv_hash_bytes(
      bytes_of([228, 184, 173, 230, 150, 135, 230, 181, 139, 232, 175, 149]),
    ),
    2129874571,
  ) // fnvB.b_cn
  assert_true(
    @hash.fnv_hash("中文测试") !=
    @hash.fnv_hash_bytes(
      bytes_of([228, 184, 173, 230, 150, 135, 230, 181, 139, 232, 175, 149]),
    ),
  )
  // Math.abs(Integer.MIN_VALUE) 仍是负数：这条读数是"返回值可以为负"的证据
  assert_eq(-2147483648, -2147483648)
}

///|
test "hash int_hash 的整数域采样与 tianl_hash 的长度分支" {
  assert_eq(@hash.int_hash(0), 1177991625) // intHash.0
  assert_eq(@hash.int_hash(1), 1656419744) // intHash.1
  assert_eq(@hash.int_hash(-1), -594869350) // intHash.-1
  assert_eq(@hash.int_hash(7), -1107627956) // intHash.7
  assert_eq(@hash.int_hash(2147483647), 2074617017) // intHash.2147483647
  assert_eq(@hash.int_hash(-2147483648), -1558455068) // intHash.-2147483648
  assert_eq(@hash.int_hash(123456789), 1216876281) // intHash.123456789
  assert_eq(@hash.tianl_hash(""), 0L) // tianl.empty
  assert_eq(@hash.tianl_hash("a"), 29786L) // tianl.a
  assert_eq(@hash.tianl_hash("abc"), 33734718L) // tianl.abc
  assert_eq(@hash.tianl_hash("hello world"), 169984320L) // tianl.hw
  assert_eq(@hash.tianl_hash("123456789"), 134634710L) // tianl.digits
  assert_eq(@hash.tianl_hash("abcd"), 50635062L) // tianl.abcd
  assert_eq(@hash.tianl_hash("a]b[c"), 67534351L) // tianl.brack
  assert_eq(@hash.tianl_hash("  x  "), 67281881L) // tianl.spaced
  assert_eq(@hash.tianl_hash("中文测试"), 98235616L) // tianl.cn
  assert_eq(@hash.tianl_hash("\u{1F34E}abc"), 97195323L) // tianl.emoji
  assert_eq(
    @hash.tianl_hash(
      "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmn",
    ),
    4447285964L,
  ) // tianl.long300
  assert_eq(
    @hash.tianl_hash(
      "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuv",
    ),
    4450029432L,
  ) // tianl.len256
  assert_eq(
    @hash.tianl_hash(
      "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvw",
    ),
    4450644750L,
  ) // tianl.len257
}

///|
test "hash java_default/mix 的 64 位拼接与 hf/hf_ip 的和式" {
  assert_eq(@hash.java_default_hash(""), 0) // javah.empty
  assert_eq(@hash.java_default_hash("a"), 97) // javah.a
  assert_eq(@hash.java_default_hash("abc"), 96354) // javah.abc
  assert_eq(@hash.java_default_hash("hello world"), 1794106052) // javah.hw
  assert_eq(@hash.java_default_hash("123456789"), -1867378635) // javah.digits
  assert_eq(@hash.java_default_hash("abcd"), 2987074) // javah.abcd
  assert_eq(@hash.java_default_hash("a]b[c"), 92449198) // javah.brack
  assert_eq(@hash.java_default_hash("  x  "), 30622328) // javah.spaced
  assert_eq(@hash.java_default_hash("中文测试"), 622087780) // javah.cn
  assert_eq(@hash.java_default_hash("\u{1F34E}abc"), 1285949584) // javah.emoji
  assert_eq(@hash.mix_hash(""), 1494218850L) // mix.empty
  assert_eq(@hash.mix_hash("a"), 417261297871L) // mix.a
  assert_eq(@hash.mix_hash("abc"), 413837313596157L) // mix.abc
  assert_eq(@hash.mix_hash("hello world"), 7705626819292733198L) // mix.hw
  assert_eq(@hash.mix_hash("123456789"), -8020330165543854212L) // mix.digits
  assert_eq(@hash.mix_hash("abcd"), 12829385708379464L) // mix.abcd
  assert_eq(@hash.mix_hash("a]b[c"), 397066283248687597L) // mix.brack
  assert_eq(@hash.mix_hash("  x  "), 131521899141597059L) // mix.spaced
  assert_eq(@hash.mix_hash("中文测试"), 2671846672336926129L) // mix.cn
  assert_eq(@hash.mix_hash("\u{1F34E}abc"), 5523111407797920654L) // mix.emoji
  assert_eq(@hash.hf_hash(""), 0L) // hf.empty
  assert_eq(@hash.hf_ip_hash(""), 0L) // hfip.empty
  assert_eq(@hash.hf_hash("a"), 0L) // hf.a
  assert_eq(@hash.hf_ip_hash("a"), 0L) // hfip.a
  assert_eq(@hash.hf_hash("abc"), 888L) // hf.abc
  assert_eq(@hash.hf_ip_hash("abc"), 0L) // hfip.abc
  assert_eq(@hash.hf_hash("hello world"), 16860L) // hf.hw
  assert_eq(@hash.hf_ip_hash("hello world"), 149L) // hfip.hw
  assert_eq(@hash.hf_hash("123456789"), 5904L) // hf.digits
  assert_eq(@hash.hf_ip_hash("123456789"), 32L) // hfip.digits
  assert_eq(@hash.hf_hash("abcd"), 1788L) // hf.abcd
  assert_eq(@hash.hf_ip_hash("abcd"), 0L) // hfip.abcd
  assert_eq(@hash.hf_hash("a]b[c"), 2874L) // hf.brack
  assert_eq(@hash.hf_ip_hash("a]b[c"), 2L) // hfip.brack
  assert_eq(@hash.hf_hash("  x  "), 1488L) // hf.spaced
  assert_eq(@hash.hf_ip_hash("  x  "), 0L) // hfip.spaced
  assert_eq(@hash.hf_hash("中文测试"), 568020L) // hf.cn
  assert_eq(@hash.hf_ip_hash("中文测试"), 0L) // hfip.cn
  assert_eq(@hash.hf_hash("\u{1F34E}abc"), 174150L) // hf.emoji
  assert_eq(@hash.hf_ip_hash("\u{1F34E}abc"), 55391L) // hfip.emoji
}

///|
test "hash murmur32：四档形状、偏移与切片等值、委托等值" {
  assert_eq(@hash.murmur32_bytes(bytes_of([])), 0) // mmr32B.b_empty
  assert_eq(@hash.murmur32_bytes(bytes_of([0])), 1364076727) // mmr32B.b_00
  assert_eq(@hash.murmur32_bytes(bytes_of([255])), -43192051) // mmr32B.b_ff
  assert_eq(@hash.murmur32_bytes(bytes_of([1, 2, 3])), -2133732860) // mmr32B.b_123
  assert_eq(
    @hash.murmur32_bytes(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57])),
    -1258359934,
  ) // mmr32B.b_digits
  assert_eq(@hash.murmur32_bytes(bytes_of([97, 98, 99])), -1277324294) // mmr32B.b_abc
  assert_eq(
    @hash.murmur32_bytes(
      bytes_of([228, 184, 173, 230, 150, 135, 230, 181, 139, 232, 175, 149]),
    ),
    -2141167703,
  ) // mmr32B.b_cn
  assert_eq(
    @hash.murmur32_bytes(bytes_of([240, 159, 141, 142, 97, 98, 99])),
    1679776045,
  ) // mmr32B.b_emoji
  assert_eq(@hash.murmur32_bytes(bytes_of([97, 98, 99, 100])), 1139631978) // mmr32B.b_abcd
  assert_eq(@hash.murmur32("abc"), -1277324294) // mmr.hash32.cs.abc
  assert_eq(@hash.murmur32(""), 0) // mmr.hash32.cs.empty
  assert_eq(@hash.murmur32("中文测试"), -2141167703) // mmr.hash32.cs.cn
  // CharSequence 档先按 UTF-8 编码 ⇒ 与字节档同值
  assert_eq(@hash.murmur32("abc"), -1277324294) // mmr.hash32.cs.abc
  assert_eq(@hash.murmur32_bytes(bytes_of([97, 98, 99])), -1277324294) // mmr.hash32.cs.abc
  assert_eq(
    @hash.murmur32_len_seed(
      bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
      2,
      4,
    ),
    405956628,
  ) // mmr.hash32.len2seed4
  assert_eq(
    @hash.murmur32_len_seed(
      bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
      0,
      0,
    ),
    0,
  ) // mmr.hash32.len0seed0
  assert_eq(
    @hash.murmur32_len_seed(
      bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
      9,
      0,
    ),
    -1258359934,
  ) // mmr.hash32.len_full_seed0
  assert_eq(
    @hash.murmur32_range(
      bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
      2,
      4,
      0,
    ),
    973865675,
  ) // mmr.hash32.off2len4seed0
  assert_eq(
    @hash.murmur32_range(
      bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
      2,
      4,
      7,
    ),
    2044033723,
  ) // mmr.hash32.off2len4seed7
  // 偏移档 == 先切片再哈希（读数两侧同为 973865675）
  assert_eq(@hash.murmur32_bytes(bytes_of([51, 52, 53, 54])), 973865675) // mmr.hash32.off2len4seed0
  assert_eq(@hash.murmur32_bytes(bytes_of([-1, -2])), -1765250992) // mmr.hash32.negative_byte
}

///|
test "hash murmur64：三档与 HashUtil 委托等值（64 位无 offset 档）" {
  assert_eq(@hash.murmur64_bytes(bytes_of([])), 0L) // mmr64B.b_empty
  assert_eq(@hash.murmur64_bytes(bytes_of([0])), -5451962507482445012L) // mmr64B.b_00
  assert_eq(@hash.murmur64_bytes(bytes_of([255])), 7886681778162119344L) // mmr64B.b_ff
  assert_eq(@hash.murmur64_bytes(bytes_of([1, 2, 3])), 5924258384977243608L) // mmr64B.b_123
  assert_eq(
    @hash.murmur64_bytes(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57])),
    6823834982947060131L,
  ) // mmr64B.b_digits
  assert_eq(@hash.murmur64_bytes(bytes_of([97, 98, 99])), 4021449166862159587L) // mmr64B.b_abc
  assert_eq(
    @hash.murmur64_bytes(
      bytes_of([228, 184, 173, 230, 150, 135, 230, 181, 139, 232, 175, 149]),
    ),
    5174524126007482595L,
  ) // mmr64B.b_cn
  assert_eq(
    @hash.murmur64_bytes(bytes_of([240, 159, 141, 142, 97, 98, 99])),
    7446618072222008343L,
  ) // mmr64B.b_emoji
  assert_eq(
    @hash.murmur64_bytes(bytes_of([97, 98, 99, 100])),
    5276624564383290285L,
  ) // mmr64B.b_abcd
  assert_eq(@hash.murmur64("abc"), 4021449166862159587L) // mmr.hash64.cs.abc
  assert_eq(@hash.murmur64("中文测试"), 5174524126007482595L) // mmr.hash64.cs.cn
  assert_eq(
    @hash.murmur64_len_seed(
      bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
      2,
      4,
    ),
    -5873116817919314179L,
  ) // mmr.hash64.len2seed4
  // 参照的 hash64(byte[], length, seed) 用 length=全宽、seed=0 时与 hash64(byte[]) 同值（读数 true）
  assert_eq(
    @hash.murmur64_len_seed(
      bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
      9,
      0,
    ),
    @hash.murmur64_bytes(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57])),
  )
}

///|
test "hash crc8：四组多项式/初值 × 五个操作（非标准 CRC-8，照参照）" {
  let c_70 = @hash.new_crc8(0x07, 0)
  assert_eq(c_70.crc8_value(), 0) // crc8.init.7_0
  c_70.crc8_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(c_70.crc8_value(), 2) // crc8.digits.7_0
  c_70.crc8_reset()
  assert_eq(c_70.crc8_value(), 0) // crc8.after_reset.7_0
  let d_70 = @hash.new_crc8(0x07, 0)
  d_70.crc8_update(bytes_of([97, 98, 99]))
  assert_eq(d_70.crc8_value(), 6) // crc8.abc.7_0
  let e_70 = @hash.new_crc8(0x07, 0)
  e_70.crc8_update(bytes_of([255]))
  assert_eq(e_70.crc8_value(), 0) // crc8.ff.7_0
  let f_70 = @hash.new_crc8(0x07, 0)
  f_70.crc8_update_range(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]), 2, 4)
  assert_eq(f_70.crc8_value(), 4) // crc8.range24.7_0
  let g_70 = @hash.new_crc8(0x07, 0)
  for x in [49, 50, 51, 52, 53, 54, 55, 56, 57] {
    g_70.crc8_update_byte(x)
  }
  assert_eq(g_70.crc8_value(), 2) // crc8.digits.7_0
  let c_490 = @hash.new_crc8(0x31, 0)
  assert_eq(c_490.crc8_value(), 0) // crc8.init.49_0
  c_490.crc8_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(c_490.crc8_value(), 7) // crc8.digits.49_0
  c_490.crc8_reset()
  assert_eq(c_490.crc8_value(), 0) // crc8.after_reset.49_0
  let d_490 = @hash.new_crc8(0x31, 0)
  d_490.crc8_update(bytes_of([97, 98, 99]))
  assert_eq(d_490.crc8_value(), 53) // crc8.abc.49_0
  let e_490 = @hash.new_crc8(0x31, 0)
  e_490.crc8_update(bytes_of([255]))
  assert_eq(e_490.crc8_value(), 34) // crc8.ff.49_0
  let f_490 = @hash.new_crc8(0x31, 0)
  f_490.crc8_update_range(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]), 2, 4)
  assert_eq(f_490.crc8_value(), 11) // crc8.range24.49_0
  let g_490 = @hash.new_crc8(0x31, 0)
  for x in [49, 50, 51, 52, 53, 54, 55, 56, 57] {
    g_490.crc8_update_byte(x)
  }
  assert_eq(g_490.crc8_value(), 7) // crc8.digits.49_0
  let c_7255 = @hash.new_crc8(0x07, 255)
  assert_eq(c_7255.crc8_value(), 255) // crc8.init.7_255
  c_7255.crc8_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(c_7255.crc8_value(), 2) // crc8.digits.7_255
  c_7255.crc8_reset()
  assert_eq(c_7255.crc8_value(), 255) // crc8.after_reset.7_255
  let d_7255 = @hash.new_crc8(0x07, 255)
  d_7255.crc8_update(bytes_of([97, 98, 99]))
  assert_eq(d_7255.crc8_value(), 6) // crc8.abc.7_255
  let e_7255 = @hash.new_crc8(0x07, 255)
  e_7255.crc8_update(bytes_of([255]))
  assert_eq(e_7255.crc8_value(), 0) // crc8.ff.7_255
  let f_7255 = @hash.new_crc8(0x07, 255)
  f_7255.crc8_update_range(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]), 2, 4)
  assert_eq(f_7255.crc8_value(), 4) // crc8.range24.7_255
  let g_7255 = @hash.new_crc8(0x07, 255)
  for x in [49, 50, 51, 52, 53, 54, 55, 56, 57] {
    g_7255.crc8_update_byte(x)
  }
  assert_eq(g_7255.crc8_value(), 2) // crc8.digits.7_255
  let c_1400 = @hash.new_crc8(0x8c, 0)
  assert_eq(c_1400.crc8_value(), 0) // crc8.init.140_0
  c_1400.crc8_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(c_1400.crc8_value(), 161) // crc8.digits.140_0
  c_1400.crc8_reset()
  assert_eq(c_1400.crc8_value(), 0) // crc8.after_reset.140_0
  let d_1400 = @hash.new_crc8(0x8c, 0)
  d_1400.crc8_update(bytes_of([97, 98, 99]))
  assert_eq(d_1400.crc8_value(), 66) // crc8.abc.140_0
  let e_1400 = @hash.new_crc8(0x8c, 0)
  e_1400.crc8_update(bytes_of([255]))
  assert_eq(e_1400.crc8_value(), 53) // crc8.ff.140_0
  let f_1400 = @hash.new_crc8(0x8c, 0)
  f_1400.crc8_update_range(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]), 2, 4)
  assert_eq(f_1400.crc8_value(), 49) // crc8.range24.140_0
  let g_1400 = @hash.new_crc8(0x8c, 0)
  for x in [49, 50, 51, 52, 53, 54, 55, 56, 57] {
    g_1400.crc8_update_byte(x)
  }
  assert_eq(g_1400.crc8_value(), 161) // crc8.digits.140_0
}

///|
test "hash crc16：十变体逐个钉初值/多项式与 hex 两式" {
  let a_ansi = @hash.new_crc16(@hash.Ansi)
  assert_eq(a_ansi.crc16_value(), 65535)
  assert_eq(a_ansi.crc16_hex_value(false), "ffff")
  assert_eq(a_ansi.crc16_hex_value(true), "ffff")
  a_ansi.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(a_ansi.crc16_value(), 12160)
  assert_eq(a_ansi.crc16_hex_value(false), "2f80")
  assert_eq(a_ansi.crc16_hex_value(true), "2f80")
  a_ansi.crc16_reset()
  assert_eq(a_ansi.crc16_value(), 65535) // crc16.reset.CRC16Ansi
  let b_ansi = @hash.new_crc16(@hash.Ansi)
  b_ansi.crc16_update(bytes_of([97, 98, 99]))
  assert_eq(b_ansi.crc16_hex_value(true), "d701")
  assert_eq(b_ansi.crc16_value(), 55041)
  let c_ansi = @hash.new_crc16(@hash.Ansi)
  c_ansi.crc16_update(bytes_of([255, 254, 0, 1]))
  assert_eq(c_ansi.crc16_value(), 64705)
  let d_ansi = @hash.new_crc16(@hash.Ansi)
  d_ansi.crc16_update_range(
    bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
    2,
    4,
  )
  assert_eq(d_ansi.crc16_value(), 11328)
  let f_ansi = @hash.new_crc16(@hash.Ansi)
  f_ansi.crc16_update_byte(49)
  assert_eq(f_ansi.crc16_value(), 38017)
  let g_ansi = @hash.new_crc16(@hash.Ansi)
  g_ansi.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(g_ansi.crc16_value(), 12160)
  assert_eq(g_ansi.crc16_hex_value(true), "2f80")
  let a_ccitt = @hash.new_crc16(@hash.Ccitt)
  assert_eq(a_ccitt.crc16_value(), 0)
  assert_eq(a_ccitt.crc16_hex_value(false), "0")
  assert_eq(a_ccitt.crc16_hex_value(true), "0000")
  a_ccitt.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(a_ccitt.crc16_value(), 8585)
  assert_eq(a_ccitt.crc16_hex_value(false), "2189")
  assert_eq(a_ccitt.crc16_hex_value(true), "2189")
  a_ccitt.crc16_reset()
  assert_eq(a_ccitt.crc16_value(), 0) // crc16.reset.CRC16CCITT
  let b_ccitt = @hash.new_crc16(@hash.Ccitt)
  b_ccitt.crc16_update(bytes_of([97, 98, 99]))
  assert_eq(b_ccitt.crc16_hex_value(true), "58e9")
  assert_eq(b_ccitt.crc16_value(), 22761)
  let c_ccitt = @hash.new_crc16(@hash.Ccitt)
  c_ccitt.crc16_update(bytes_of([255, 254, 0, 1]))
  assert_eq(c_ccitt.crc16_value(), 18548)
  let d_ccitt = @hash.new_crc16(@hash.Ccitt)
  d_ccitt.crc16_update_range(
    bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
    2,
    4,
  )
  assert_eq(d_ccitt.crc16_value(), 4191)
  let f_ccitt = @hash.new_crc16(@hash.Ccitt)
  f_ccitt.crc16_update_byte(49)
  assert_eq(f_ccitt.crc16_value(), 8202)
  let g_ccitt = @hash.new_crc16(@hash.Ccitt)
  g_ccitt.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(g_ccitt.crc16_value(), 8585)
  assert_eq(g_ccitt.crc16_hex_value(true), "2189")
  let a_ccittfalse = @hash.new_crc16(@hash.CcittFalse)
  assert_eq(a_ccittfalse.crc16_value(), 65535)
  assert_eq(a_ccittfalse.crc16_hex_value(false), "ffff")
  assert_eq(a_ccittfalse.crc16_hex_value(true), "ffff")
  a_ccittfalse.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(a_ccittfalse.crc16_value(), 10673)
  assert_eq(a_ccittfalse.crc16_hex_value(false), "29b1")
  assert_eq(a_ccittfalse.crc16_hex_value(true), "29b1")
  a_ccittfalse.crc16_reset()
  assert_eq(a_ccittfalse.crc16_value(), 65535) // crc16.reset.CRC16CCITTFalse
  let b_ccittfalse = @hash.new_crc16(@hash.CcittFalse)
  b_ccittfalse.crc16_update(bytes_of([97, 98, 99]))
  assert_eq(b_ccittfalse.crc16_hex_value(true), "514a")
  assert_eq(b_ccittfalse.crc16_value(), 20810)
  let c_ccittfalse = @hash.new_crc16(@hash.CcittFalse)
  c_ccittfalse.crc16_update(bytes_of([255, 254, 0, 1]))
  assert_eq(c_ccittfalse.crc16_value(), 10001)
  let d_ccittfalse = @hash.new_crc16(@hash.CcittFalse)
  d_ccittfalse.crc16_update_range(
    bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
    2,
    4,
  )
  assert_eq(d_ccittfalse.crc16_value(), 34405)
  let f_ccittfalse = @hash.new_crc16(@hash.CcittFalse)
  f_ccittfalse.crc16_update_byte(49)
  assert_eq(f_ccittfalse.crc16_value(), 15976322)
  let g_ccittfalse = @hash.new_crc16(@hash.CcittFalse)
  g_ccittfalse.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(g_ccittfalse.crc16_value(), 10673)
  assert_eq(g_ccittfalse.crc16_hex_value(true), "29b1")
  let a_dnp = @hash.new_crc16(@hash.Dnp)
  assert_eq(a_dnp.crc16_value(), 0)
  assert_eq(a_dnp.crc16_hex_value(false), "0")
  assert_eq(a_dnp.crc16_hex_value(true), "0000")
  a_dnp.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(a_dnp.crc16_value(), 60034)
  assert_eq(a_dnp.crc16_hex_value(false), "ea82")
  assert_eq(a_dnp.crc16_hex_value(true), "ea82")
  a_dnp.crc16_reset()
  assert_eq(a_dnp.crc16_value(), 0) // crc16.reset.CRC16DNP
  let b_dnp = @hash.new_crc16(@hash.Dnp)
  b_dnp.crc16_update(bytes_of([97, 98, 99]))
  assert_eq(b_dnp.crc16_hex_value(true), "e957")
  assert_eq(b_dnp.crc16_value(), 59735)
  let c_dnp = @hash.new_crc16(@hash.Dnp)
  c_dnp.crc16_update(bytes_of([255, 254, 0, 1]))
  assert_eq(c_dnp.crc16_value(), 13228)
  let d_dnp = @hash.new_crc16(@hash.Dnp)
  d_dnp.crc16_update_range(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]), 2, 4)
  assert_eq(d_dnp.crc16_value(), 40889)
  let f_dnp = @hash.new_crc16(@hash.Dnp)
  f_dnp.crc16_update_byte(49)
  assert_eq(f_dnp.crc16_value(), 44442)
  let g_dnp = @hash.new_crc16(@hash.Dnp)
  g_dnp.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(g_dnp.crc16_value(), 60034)
  assert_eq(g_dnp.crc16_hex_value(true), "ea82")
  let a_ibm = @hash.new_crc16(@hash.Ibm)
  assert_eq(a_ibm.crc16_value(), 0)
  assert_eq(a_ibm.crc16_hex_value(false), "0")
  assert_eq(a_ibm.crc16_hex_value(true), "0000")
  a_ibm.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(a_ibm.crc16_value(), 47933)
  assert_eq(a_ibm.crc16_hex_value(false), "bb3d")
  assert_eq(a_ibm.crc16_hex_value(true), "bb3d")
  a_ibm.crc16_reset()
  assert_eq(a_ibm.crc16_value(), 0) // crc16.reset.CRC16IBM
  let b_ibm = @hash.new_crc16(@hash.Ibm)
  b_ibm.crc16_update(bytes_of([97, 98, 99]))
  assert_eq(b_ibm.crc16_hex_value(true), "9738")
  assert_eq(b_ibm.crc16_value(), 38712)
  let c_ibm = @hash.new_crc16(@hash.Ibm)
  c_ibm.crc16_update(bytes_of([255, 254, 0, 1]))
  assert_eq(c_ibm.crc16_value(), 9360)
  let d_ibm = @hash.new_crc16(@hash.Ibm)
  d_ibm.crc16_update_range(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]), 2, 4)
  assert_eq(d_ibm.crc16_value(), 52441)
  let f_ibm = @hash.new_crc16(@hash.Ibm)
  f_ibm.crc16_update_byte(49)
  assert_eq(f_ibm.crc16_value(), 54465)
  let g_ibm = @hash.new_crc16(@hash.Ibm)
  g_ibm.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(g_ibm.crc16_value(), 47933)
  assert_eq(g_ibm.crc16_hex_value(true), "bb3d")
  let a_maxim = @hash.new_crc16(@hash.Maxim)
  assert_eq(a_maxim.crc16_value(), 0)
  assert_eq(a_maxim.crc16_hex_value(false), "0")
  assert_eq(a_maxim.crc16_hex_value(true), "0000")
  a_maxim.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(a_maxim.crc16_value(), 17602)
  assert_eq(a_maxim.crc16_hex_value(false), "44c2")
  assert_eq(a_maxim.crc16_hex_value(true), "44c2")
  a_maxim.crc16_reset()
  assert_eq(a_maxim.crc16_value(), 0) // crc16.reset.CRC16Maxim
  let b_maxim = @hash.new_crc16(@hash.Maxim)
  b_maxim.crc16_update(bytes_of([97, 98, 99]))
  assert_eq(b_maxim.crc16_hex_value(true), "68c7")
  assert_eq(b_maxim.crc16_value(), 26823)
  let c_maxim = @hash.new_crc16(@hash.Maxim)
  c_maxim.crc16_update(bytes_of([255, 254, 0, 1]))
  assert_eq(c_maxim.crc16_value(), 56175)
  let d_maxim = @hash.new_crc16(@hash.Maxim)
  d_maxim.crc16_update_range(
    bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
    2,
    4,
  )
  assert_eq(d_maxim.crc16_value(), 13094)
  let f_maxim = @hash.new_crc16(@hash.Maxim)
  f_maxim.crc16_update_byte(49)
  assert_eq(f_maxim.crc16_value(), 54465)
  let g_maxim = @hash.new_crc16(@hash.Maxim)
  g_maxim.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(g_maxim.crc16_value(), 17602)
  assert_eq(g_maxim.crc16_hex_value(true), "44c2")
  let a_modbus = @hash.new_crc16(@hash.Modbus)
  assert_eq(a_modbus.crc16_value(), 65535)
  assert_eq(a_modbus.crc16_hex_value(false), "ffff")
  assert_eq(a_modbus.crc16_hex_value(true), "ffff")
  a_modbus.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(a_modbus.crc16_value(), 19255)
  assert_eq(a_modbus.crc16_hex_value(false), "4b37")
  assert_eq(a_modbus.crc16_hex_value(true), "4b37")
  a_modbus.crc16_reset()
  assert_eq(a_modbus.crc16_value(), 65535) // crc16.reset.CRC16Modbus
  let b_modbus = @hash.new_crc16(@hash.Modbus)
  b_modbus.crc16_update(bytes_of([97, 98, 99]))
  assert_eq(b_modbus.crc16_hex_value(true), "5749")
  assert_eq(b_modbus.crc16_value(), 22345)
  let c_modbus = @hash.new_crc16(@hash.Modbus)
  c_modbus.crc16_update(bytes_of([255, 254, 0, 1]))
  assert_eq(c_modbus.crc16_value(), 144)
  let d_modbus = @hash.new_crc16(@hash.Modbus)
  d_modbus.crc16_update_range(
    bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
    2,
    4,
  )
  assert_eq(d_modbus.crc16_value(), 59609)
  let f_modbus = @hash.new_crc16(@hash.Modbus)
  f_modbus.crc16_update_byte(49)
  assert_eq(f_modbus.crc16_value(), 38014)
  let g_modbus = @hash.new_crc16(@hash.Modbus)
  g_modbus.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(g_modbus.crc16_value(), 19255)
  assert_eq(g_modbus.crc16_hex_value(true), "4b37")
  let a_usb = @hash.new_crc16(@hash.Usb)
  assert_eq(a_usb.crc16_value(), 65535)
  assert_eq(a_usb.crc16_hex_value(false), "ffff")
  assert_eq(a_usb.crc16_hex_value(true), "ffff")
  a_usb.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(a_usb.crc16_value(), 46280)
  assert_eq(a_usb.crc16_hex_value(false), "b4c8")
  assert_eq(a_usb.crc16_hex_value(true), "b4c8")
  a_usb.crc16_reset()
  assert_eq(a_usb.crc16_value(), 65535) // crc16.reset.CRC16USB
  let b_usb = @hash.new_crc16(@hash.Usb)
  b_usb.crc16_update(bytes_of([97, 98, 99]))
  assert_eq(b_usb.crc16_hex_value(true), "a8b6")
  assert_eq(b_usb.crc16_value(), 43190)
  let c_usb = @hash.new_crc16(@hash.Usb)
  c_usb.crc16_update(bytes_of([255, 254, 0, 1]))
  assert_eq(c_usb.crc16_value(), 65391)
  let d_usb = @hash.new_crc16(@hash.Usb)
  d_usb.crc16_update_range(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]), 2, 4)
  assert_eq(d_usb.crc16_value(), 5926)
  let f_usb = @hash.new_crc16(@hash.Usb)
  f_usb.crc16_update_byte(49)
  assert_eq(f_usb.crc16_value(), 38014)
  let g_usb = @hash.new_crc16(@hash.Usb)
  g_usb.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(g_usb.crc16_value(), 46280)
  assert_eq(g_usb.crc16_hex_value(true), "b4c8")
  let a_x25 = @hash.new_crc16(@hash.X25)
  assert_eq(a_x25.crc16_value(), 65535)
  assert_eq(a_x25.crc16_hex_value(false), "ffff")
  assert_eq(a_x25.crc16_hex_value(true), "ffff")
  a_x25.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(a_x25.crc16_value(), 36974)
  assert_eq(a_x25.crc16_hex_value(false), "906e")
  assert_eq(a_x25.crc16_hex_value(true), "906e")
  a_x25.crc16_reset()
  assert_eq(a_x25.crc16_value(), 65535) // crc16.reset.CRC16X25
  let b_x25 = @hash.new_crc16(@hash.X25)
  b_x25.crc16_update(bytes_of([97, 98, 99]))
  assert_eq(b_x25.crc16_hex_value(true), "9e25")
  assert_eq(b_x25.crc16_value(), 40485)
  let c_x25 = @hash.new_crc16(@hash.X25)
  c_x25.crc16_update(bytes_of([255, 254, 0, 1]))
  assert_eq(c_x25.crc16_value(), 46250)
  let d_x25 = @hash.new_crc16(@hash.X25)
  d_x25.crc16_update_range(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]), 2, 4)
  assert_eq(d_x25.crc16_value(), 60545)
  let f_x25 = @hash.new_crc16(@hash.X25)
  f_x25.crc16_update_byte(49)
  assert_eq(f_x25.crc16_value(), 12173)
  let g_x25 = @hash.new_crc16(@hash.X25)
  g_x25.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(g_x25.crc16_value(), 36974)
  assert_eq(g_x25.crc16_hex_value(true), "906e")
  let a_xmodem = @hash.new_crc16(@hash.XModem)
  assert_eq(a_xmodem.crc16_value(), 0)
  assert_eq(a_xmodem.crc16_hex_value(false), "0")
  assert_eq(a_xmodem.crc16_hex_value(true), "0000")
  a_xmodem.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(a_xmodem.crc16_value(), 12739)
  assert_eq(a_xmodem.crc16_hex_value(false), "31c3")
  assert_eq(a_xmodem.crc16_hex_value(true), "31c3")
  a_xmodem.crc16_reset()
  assert_eq(a_xmodem.crc16_value(), 0) // crc16.reset.CRC16XModem
  let b_xmodem = @hash.new_crc16(@hash.XModem)
  b_xmodem.crc16_update(bytes_of([97, 98, 99]))
  assert_eq(b_xmodem.crc16_hex_value(true), "9dd6")
  assert_eq(b_xmodem.crc16_value(), 40406)
  let c_xmodem = @hash.new_crc16(@hash.XModem)
  c_xmodem.crc16_update(bytes_of([255, 254, 0, 1]))
  assert_eq(c_xmodem.crc16_value(), 41937)
  let d_xmodem = @hash.new_crc16(@hash.XModem)
  d_xmodem.crc16_update_range(
    bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
    2,
    4,
  )
  assert_eq(d_xmodem.crc16_value(), 677)
  let f_xmodem = @hash.new_crc16(@hash.XModem)
  f_xmodem.crc16_update_byte(49)
  assert_eq(f_xmodem.crc16_value(), 206450)
  let g_xmodem = @hash.new_crc16(@hash.XModem)
  g_xmodem.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  assert_eq(g_xmodem.crc16_value(), 12739)
  assert_eq(g_xmodem.crc16_hex_value(true), "31c3")
}

///|
test "hash 委托等值与默认档：HashUtil.murmur* 只是转手、crc16 默认档是 Ibm" {
  // 参照侧 HashUtil.murmur32 直接 return MurmurHash.hash32 ⇒ 本库只建一件，读数对拍（true）
  assert_eq(@hash.murmur32_bytes(bytes_of([])), 0) // mmr32B.b_empty
  // 参照侧 HashUtil.murmur32 直接 return MurmurHash.hash32 ⇒ 本库只建一件，读数对拍（true）
  assert_eq(@hash.murmur32_bytes(bytes_of([0])), 1364076727) // mmr32B.b_00
  // 参照侧 HashUtil.murmur32 直接 return MurmurHash.hash32 ⇒ 本库只建一件，读数对拍（true）
  assert_eq(@hash.murmur32_bytes(bytes_of([255])), -43192051) // mmr32B.b_ff
  // 参照侧 HashUtil.murmur32 直接 return MurmurHash.hash32 ⇒ 本库只建一件，读数对拍（true）
  assert_eq(@hash.murmur32_bytes(bytes_of([1, 2, 3])), -2133732860) // mmr32B.b_123
  // 参照侧 HashUtil.murmur32 直接 return MurmurHash.hash32 ⇒ 本库只建一件，读数对拍（true）
  assert_eq(
    @hash.murmur32_bytes(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57])),
    -1258359934,
  ) // mmr32B.b_digits
  // 参照侧 HashUtil.murmur32 直接 return MurmurHash.hash32 ⇒ 本库只建一件，读数对拍（true）
  assert_eq(@hash.murmur32_bytes(bytes_of([97, 98, 99])), -1277324294) // mmr32B.b_abc
  // 参照侧 HashUtil.murmur32 直接 return MurmurHash.hash32 ⇒ 本库只建一件，读数对拍（true）
  assert_eq(
    @hash.murmur32_bytes(
      bytes_of([228, 184, 173, 230, 150, 135, 230, 181, 139, 232, 175, 149]),
    ),
    -2141167703,
  ) // mmr32B.b_cn
  // 参照侧 HashUtil.murmur32 直接 return MurmurHash.hash32 ⇒ 本库只建一件，读数对拍（true）
  assert_eq(
    @hash.murmur32_bytes(bytes_of([240, 159, 141, 142, 97, 98, 99])),
    1679776045,
  ) // mmr32B.b_emoji
  // 参照侧 HashUtil.murmur32 直接 return MurmurHash.hash32 ⇒ 本库只建一件，读数对拍（true）
  assert_eq(@hash.murmur32_bytes(bytes_of([97, 98, 99, 100])), 1139631978) // mmr32B.b_abcd
  let ibm = @hash.new_crc16(@hash.Ibm)
  ibm.crc16_update(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]))
  // crc16.default_is_ibm 的参照读数：47933/CRC16IBM
  assert_eq(ibm.crc16_value(), 47933)
  assert_eq(
    @hash.murmur32_len_seed(
      bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57]),
      9,
      0,
    ),
    @hash.murmur32_bytes(bytes_of([49, 50, 51, 52, 53, 54, 55, 56, 57])),
  )
}
