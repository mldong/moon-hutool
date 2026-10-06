///|
// typex 第三批 E（DataSize / DataSizeUtil / DataUnit）的期望值全部由生成脚本从参照腿灌入（手打零条）。
// 腿：真 hutool-core-5.8.35.jar + JDK 17.0.14（Temp/convsrc/datasize/DataSizeLeg.java + DataSizeLeg2.java）。
// 腿共 512 行 = 424 VAL + 88 ERR；本批用 360 条，其余 151 条属 `format` 两族与 `of(long, null)`，见 spec §15.1。
// 公开面**不暴露 enum 值**：以单位为参数处一律收后缀串（形状定案见 spec §15.1 与 §15.5）。
// 行尾标了「参照 XxxException」的期望来自映射表，不是参照返回值。
// `format` 两族本批不收：选档靠 `Math.log10` 浮点边界、印数靠 `DecimalFormat` 千分位 + HALF_EVEN，
// 要先做 core 侧对撞才冻期望（读数已在腿里存着）。

///|
fn etag(e : @typex.DataSizeError) -> String {
  match e {
    BadText => "BadText"
    Overflow => "Overflow"
  }
}

///|
test "DataSize \u{89e3}\u{6790}\u{ff1a}cleanBlank\u{3001}\u{5c0f}\u{6570}\u{5411}\u{96f6}\u{622a}\u{65ad}\u{3001}\u{4e24}\u{5b57}\u{6bcd}\u{540e}\u{7f00}\u{3001}\u{975e}\u{6cd5}\u{6863} raise" {
  assert_eq(@typex.data_size_parse_bytes("12KB"), 12288L) // PARSE|12KB
  assert_eq(@typex.data_size_parse_bytes("12kb"), 12288L) // PARSE|12kb
  assert_eq(@typex.data_size_parse_bytes("12 Kb"), 12288L) // PARSE|12 Kb
  assert_eq(@typex.data_size_parse_bytes("5MB"), 5242880L) // PARSE|5MB
  assert_eq(@typex.data_size_parse_bytes("20"), 20L) // PARSE|20
  assert_eq(@typex.data_size_parse_bytes("20B"), 20L) // PARSE|20B
  assert_eq(@typex.data_size_parse_bytes("-5KB"), -5120L) // PARSE|-5KB
  assert_eq(@typex.data_size_parse_bytes("+7MB"), 7340032L) // PARSE|+7MB
  assert_eq(@typex.data_size_parse_bytes("1.5KB"), 1536L) // PARSE|1.5KB
  assert_eq(@typex.data_size_parse_bytes("1.1KB"), 1126L) // PARSE|1.1KB
  assert_eq(@typex.data_size_parse_bytes("0.9KB"), 921L) // PARSE|0.9KB
  assert_eq(@typex.data_size_parse_bytes("1.999MB"), 2096103L) // PARSE|1.999MB
  assert_eq(@typex.data_size_parse_bytes("1 2 KB"), 12288L) // PARSE|1 2 KB
  assert_eq(@typex.data_size_parse_bytes("  8  GB  "), 8589934592L) // PARSE|  8  GB  
  assert_eq(@typex.data_size_parse_bytes("1TB"), 1099511627776L) // PARSE|1TB
  let r16 : String = @typex.data_size_parse_bytes("1PB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r16, "ERR:BadText") // PARSE|1PB（参照 IllegalArgumentException）
  let r17 : String = @typex.data_size_parse_bytes("1EB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r17, "ERR:BadText") // PARSE|1EB（参照 IllegalArgumentException）
  let r18 : String = @typex.data_size_parse_bytes("1ZB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r18, "ERR:BadText") // PARSE|1ZB（参照 IllegalArgumentException）
  let r19 : String = @typex.data_size_parse_bytes("1B B").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r19, "ERR:BadText") // PARSE|1B B（参照 IllegalArgumentException）
  let r20 : String = @typex.data_size_parse_bytes("1.2.3KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r20, "ERR:BadText") // PARSE|1.2.3KB（参照 IllegalArgumentException）
  let r21 : String = @typex.data_size_parse_bytes("").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r21, "ERR:BadText") // PARSE|（参照 IllegalArgumentException）
  let r22 : String = @typex.data_size_parse_bytes(" ").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r22, "ERR:BadText") // PARSE| （参照 IllegalArgumentException）
  let r23 : String = @typex.data_size_parse_bytes("KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r23, "ERR:BadText") // PARSE|KB（参照 IllegalArgumentException）
  assert_eq(@typex.data_size_parse_bytes("12"), 12L) // PARSE|12
  let r25 : String = @typex.data_size_parse_bytes(".5KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r25, "ERR:BadText") // PARSE|.5KB（参照 IllegalArgumentException）
  let r26 : String = @typex.data_size_parse_bytes("5.").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r26, "ERR:BadText") // PARSE|5.（参照 IllegalArgumentException）
  let r27 : String = @typex.data_size_parse_bytes("1e3").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r27, "ERR:BadText") // PARSE|1e3（参照 IllegalArgumentException）
  let r28 : String = @typex.data_size_parse_bytes("0x10").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r28, "ERR:BadText") // PARSE|0x10（参照 IllegalArgumentException）
  let r29 : String = @typex.data_size_parse_bytes("\u{ff11}\u{ff12}KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r29, "ERR:BadText") // PARSE|１２KB（参照 IllegalArgumentException）
  assert_eq(
    @typex.data_size_parse_bytes("9999999999999999999999KB"),
    -8996245056616662016L,
  ) // PARSE|9999999999999999999999KB
  assert_eq(@typex.data_size_parse_bytes("12KB "), 12288L) // PARSE|12KB 
  let r32 : String = @typex.data_size_parse_bytes("\u{663}KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r32, "ERR:BadText") // PARSE|٣KB（参照 IllegalArgumentException）
  let r33 : String = @typex.data_size_parse_bytes("\u{663}\u{662}").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r33, "ERR:BadText") // PARSE|٣٢（参照 IllegalArgumentException）
  let r34 : String = @typex.data_size_parse_bytes("3\u{663}KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r34, "ERR:BadText") // PARSE|3٣KB（参照 IllegalArgumentException）
  assert_eq(@typex.data_size_parse_bytes("12K"), 12288L) // PARSE|12K
  assert_eq(@typex.data_size_parse_bytes("5M"), 5242880L) // PARSE|5M
  assert_eq(@typex.data_size_parse_bytes("1T"), 1099511627776L) // PARSE|1T
  assert_eq(@typex.data_size_parse_bytes("3b"), 3L) // PARSE|3b
  assert_eq(@typex.data_size_parse_bytes("-1.5KB"), -1536L) // PARSE|-1.5KB
  assert_eq(@typex.data_size_parse_bytes("0.5B"), 0L) // PARSE|0.5B
  assert_eq(@typex.data_size_parse_bytes("-0.5KB"), -512L) // PARSE|-0.5KB
  assert_eq(@typex.data_size_parse_bytes("1.9999999999999999KB"), 2047L) // PARSE|1.9999999999999999KB
  assert_eq(@typex.data_size_parse_bytes("0.0009765625KB"), 1L) // PARSE|0.0009765625KB
  assert_eq(
    @typex.data_size_parse_bytes("9007199254740993B"),
    9007199254740993L,
  ) // PARSE|9007199254740993B
  let r45 : String = @typex.data_size_parse_bytes("1P").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r45, "ERR:BadText") // PARSE|1P（参照 IllegalArgumentException）
}

///|
test "DataSize \u{89e3}\u{6790}\u{ff08}\u{9ed8}\u{8ba4}\u{5355}\u{4f4d}\u{540e}\u{7f00} KB\u{ff09}" {
  assert_eq(@typex.data_size_parse_bytes_with("12KB", "KB"), 12288L) // PARSE_KB|12KB
  assert_eq(@typex.data_size_parse_bytes_with("12kb", "KB"), 12288L) // PARSE_KB|12kb
  assert_eq(@typex.data_size_parse_bytes_with("12 Kb", "KB"), 12288L) // PARSE_KB|12 Kb
  assert_eq(@typex.data_size_parse_bytes_with("5MB", "KB"), 5242880L) // PARSE_KB|5MB
  assert_eq(@typex.data_size_parse_bytes_with("20", "KB"), 20480L) // PARSE_KB|20
  assert_eq(@typex.data_size_parse_bytes_with("20B", "KB"), 20L) // PARSE_KB|20B
  assert_eq(@typex.data_size_parse_bytes_with("-5KB", "KB"), -5120L) // PARSE_KB|-5KB
  assert_eq(@typex.data_size_parse_bytes_with("+7MB", "KB"), 7340032L) // PARSE_KB|+7MB
  assert_eq(@typex.data_size_parse_bytes_with("1.5KB", "KB"), 1536L) // PARSE_KB|1.5KB
  assert_eq(@typex.data_size_parse_bytes_with("1.1KB", "KB"), 1126L) // PARSE_KB|1.1KB
  assert_eq(@typex.data_size_parse_bytes_with("0.9KB", "KB"), 921L) // PARSE_KB|0.9KB
  assert_eq(@typex.data_size_parse_bytes_with("1.999MB", "KB"), 2096103L) // PARSE_KB|1.999MB
  assert_eq(@typex.data_size_parse_bytes_with("1 2 KB", "KB"), 12288L) // PARSE_KB|1 2 KB
  assert_eq(@typex.data_size_parse_bytes_with("  8  GB  ", "KB"), 8589934592L) // PARSE_KB|  8  GB  
  assert_eq(@typex.data_size_parse_bytes_with("1TB", "KB"), 1099511627776L) // PARSE_KB|1TB
  let r61 : String = @typex.data_size_parse_bytes_with("1PB", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r61, "ERR:BadText") // PARSE_KB|1PB（参照 IllegalArgumentException）
  let r62 : String = @typex.data_size_parse_bytes_with("1EB", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r62, "ERR:BadText") // PARSE_KB|1EB（参照 IllegalArgumentException）
  let r63 : String = @typex.data_size_parse_bytes_with("1ZB", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r63, "ERR:BadText") // PARSE_KB|1ZB（参照 IllegalArgumentException）
  let r64 : String = @typex.data_size_parse_bytes_with("1B B", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r64, "ERR:BadText") // PARSE_KB|1B B（参照 IllegalArgumentException）
  let r65 : String = @typex.data_size_parse_bytes_with("1.2.3KB", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r65, "ERR:BadText") // PARSE_KB|1.2.3KB（参照 IllegalArgumentException）
  let r66 : String = @typex.data_size_parse_bytes_with("", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r66, "ERR:BadText") // PARSE_KB|（参照 IllegalArgumentException）
  let r67 : String = @typex.data_size_parse_bytes_with(" ", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r67, "ERR:BadText") // PARSE_KB| （参照 IllegalArgumentException）
  let r68 : String = @typex.data_size_parse_bytes_with("KB", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r68, "ERR:BadText") // PARSE_KB|KB（参照 IllegalArgumentException）
  assert_eq(@typex.data_size_parse_bytes_with("12", "KB"), 12288L) // PARSE_KB|12
  let r70 : String = @typex.data_size_parse_bytes_with(".5KB", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r70, "ERR:BadText") // PARSE_KB|.5KB（参照 IllegalArgumentException）
  let r71 : String = @typex.data_size_parse_bytes_with("5.", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r71, "ERR:BadText") // PARSE_KB|5.（参照 IllegalArgumentException）
  let r72 : String = @typex.data_size_parse_bytes_with("1e3", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r72, "ERR:BadText") // PARSE_KB|1e3（参照 IllegalArgumentException）
  let r73 : String = @typex.data_size_parse_bytes_with("0x10", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r73, "ERR:BadText") // PARSE_KB|0x10（参照 IllegalArgumentException）
  let r74 : String = @typex.data_size_parse_bytes_with(
    "\u{ff11}\u{ff12}KB", "KB",
  ).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r74, "ERR:BadText") // PARSE_KB|１２KB（参照 IllegalArgumentException）
  assert_eq(
    @typex.data_size_parse_bytes_with("9999999999999999999999KB", "KB"),
    -8996245056616662016L,
  ) // PARSE_KB|9999999999999999999999KB
  assert_eq(@typex.data_size_parse_bytes_with("12KB ", "KB"), 12288L) // PARSE_KB|12KB 
  let r77 : String = @typex.data_size_parse_bytes_with("\u{663}KB", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r77, "ERR:BadText") // PARSE_KB|٣KB（参照 IllegalArgumentException）
  let r78 : String = @typex.data_size_parse_bytes_with("\u{663}\u{662}", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r78, "ERR:BadText") // PARSE_KB|٣٢（参照 IllegalArgumentException）
  let r79 : String = @typex.data_size_parse_bytes_with("3\u{663}KB", "KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r79, "ERR:BadText") // PARSE_KB|3٣KB（参照 IllegalArgumentException）
}

///|
test "DataSizeUtil.parse \u{5c31}\u{662f} parse + to_bytes\u{ff08}\u{540c}\u{4e00}\u{6761}\u{5931}\u{8d25}\u{9762}\u{ff09}" {
  assert_eq(@typex.data_size_parse_bytes("12KB"), 12288L) // UTIL_PARSE|12KB
  assert_eq(@typex.data_size_parse_bytes("12kb"), 12288L) // UTIL_PARSE|12kb
  assert_eq(@typex.data_size_parse_bytes("12 Kb"), 12288L) // UTIL_PARSE|12 Kb
  assert_eq(@typex.data_size_parse_bytes("5MB"), 5242880L) // UTIL_PARSE|5MB
  assert_eq(@typex.data_size_parse_bytes("20"), 20L) // UTIL_PARSE|20
  assert_eq(@typex.data_size_parse_bytes("20B"), 20L) // UTIL_PARSE|20B
  assert_eq(@typex.data_size_parse_bytes("-5KB"), -5120L) // UTIL_PARSE|-5KB
  assert_eq(@typex.data_size_parse_bytes("+7MB"), 7340032L) // UTIL_PARSE|+7MB
  assert_eq(@typex.data_size_parse_bytes("1.5KB"), 1536L) // UTIL_PARSE|1.5KB
  assert_eq(@typex.data_size_parse_bytes("1.1KB"), 1126L) // UTIL_PARSE|1.1KB
  assert_eq(@typex.data_size_parse_bytes("0.9KB"), 921L) // UTIL_PARSE|0.9KB
  assert_eq(@typex.data_size_parse_bytes("1.999MB"), 2096103L) // UTIL_PARSE|1.999MB
  assert_eq(@typex.data_size_parse_bytes("1 2 KB"), 12288L) // UTIL_PARSE|1 2 KB
  assert_eq(@typex.data_size_parse_bytes("  8  GB  "), 8589934592L) // UTIL_PARSE|  8  GB  
  assert_eq(@typex.data_size_parse_bytes("1TB"), 1099511627776L) // UTIL_PARSE|1TB
  let r95 : String = @typex.data_size_parse_bytes("1PB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r95, "ERR:BadText") // UTIL_PARSE|1PB（参照 IllegalArgumentException）
  let r96 : String = @typex.data_size_parse_bytes("1EB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r96, "ERR:BadText") // UTIL_PARSE|1EB（参照 IllegalArgumentException）
  let r97 : String = @typex.data_size_parse_bytes("1ZB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r97, "ERR:BadText") // UTIL_PARSE|1ZB（参照 IllegalArgumentException）
  let r98 : String = @typex.data_size_parse_bytes("1B B").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r98, "ERR:BadText") // UTIL_PARSE|1B B（参照 IllegalArgumentException）
  let r99 : String = @typex.data_size_parse_bytes("1.2.3KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r99, "ERR:BadText") // UTIL_PARSE|1.2.3KB（参照 IllegalArgumentException）
  let r100 : String = @typex.data_size_parse_bytes("").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r100, "ERR:BadText") // UTIL_PARSE|（参照 IllegalArgumentException）
  let r101 : String = @typex.data_size_parse_bytes(" ").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r101, "ERR:BadText") // UTIL_PARSE| （参照 IllegalArgumentException）
  let r102 : String = @typex.data_size_parse_bytes("KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r102, "ERR:BadText") // UTIL_PARSE|KB（参照 IllegalArgumentException）
  assert_eq(@typex.data_size_parse_bytes("12"), 12L) // UTIL_PARSE|12
  let r104 : String = @typex.data_size_parse_bytes(".5KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r104, "ERR:BadText") // UTIL_PARSE|.5KB（参照 IllegalArgumentException）
  let r105 : String = @typex.data_size_parse_bytes("5.").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r105, "ERR:BadText") // UTIL_PARSE|5.（参照 IllegalArgumentException）
  let r106 : String = @typex.data_size_parse_bytes("1e3").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r106, "ERR:BadText") // UTIL_PARSE|1e3（参照 IllegalArgumentException）
  let r107 : String = @typex.data_size_parse_bytes("0x10").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r107, "ERR:BadText") // UTIL_PARSE|0x10（参照 IllegalArgumentException）
  let r108 : String = @typex.data_size_parse_bytes("\u{ff11}\u{ff12}KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r108, "ERR:BadText") // UTIL_PARSE|１２KB（参照 IllegalArgumentException）
  assert_eq(
    @typex.data_size_parse_bytes("9999999999999999999999KB"),
    -8996245056616662016L,
  ) // UTIL_PARSE|9999999999999999999999KB
  assert_eq(@typex.data_size_parse_bytes("12KB "), 12288L) // UTIL_PARSE|12KB 
  let r111 : String = @typex.data_size_parse_bytes("\u{663}KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r111, "ERR:BadText") // UTIL_PARSE|٣KB（参照 IllegalArgumentException）
  let r112 : String = @typex.data_size_parse_bytes("\u{663}\u{662}").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r112, "ERR:BadText") // UTIL_PARSE|٣٢（参照 IllegalArgumentException）
  let r113 : String = @typex.data_size_parse_bytes("3\u{663}KB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r113, "ERR:BadText") // UTIL_PARSE|3٣KB（参照 IllegalArgumentException）
}

///|
test "DataSize \u{6784}\u{9020}\u{ff1a}of_bytes \u{4e0d}\u{67e5}\u{91cd}\u{3001}\u{5176}\u{4f59}\u{6ea2}\u{51fa} raise\u{ff08}\u{53c2}\u{7167} multiplyExact\u{ff09}" {
  assert_eq(@typex.data_size_of_bytes(0L), 0L) // OF_BYTES|0
  assert_eq(@typex.data_size_of_bytes(1L), 1L) // OF_BYTES|1
  assert_eq(@typex.data_size_of_bytes(-1L), -1L) // OF_BYTES|-1
  assert_eq(@typex.data_size_of_bytes(1023L), 1023L) // OF_BYTES|1023
  assert_eq(@typex.data_size_of_bytes(1024L), 1024L) // OF_BYTES|1024
  assert_eq(
    @typex.data_size_of_bytes(9223372036854775807L),
    9223372036854775807L,
  ) // OF_BYTES|9223372036854775807
  assert_eq(
    @typex.data_size_of_bytes(-9223372036854775808L),
    -9223372036854775808L,
  ) // OF_BYTES|-9223372036854775808
  assert_eq(@typex.data_size_of_bytes(9007199254740991L), 9007199254740991L) // OF_BYTES|9007199254740991
  assert_eq(@typex.data_size_of_bytes(9007199254740992L), 9007199254740992L) // OF_BYTES|9007199254740992
  assert_eq(@typex.data_size_of_bytes(-9007199254740993L), -9007199254740993L) // OF_BYTES|-9007199254740993
  assert_eq(@typex.data_size_of_bytes(1099511627776L), 1099511627776L) // OF_BYTES|1099511627776
  assert_eq(@typex.data_size_of_bytes(1099511627777L), 1099511627777L) // OF_BYTES|1099511627777
  assert_eq(@typex.data_size_of_bytes(9223372036854L), 9223372036854L) // OF_BYTES|9223372036854

  assert_eq(@typex.data_size_of_kilobytes(0L), 0L) // OF_KB|0
  assert_eq(@typex.data_size_of_kilobytes(1L), 1024L) // OF_KB|1
  assert_eq(@typex.data_size_of_kilobytes(-1L), -1024L) // OF_KB|-1
  assert_eq(@typex.data_size_of_kilobytes(1023L), 1047552L) // OF_KB|1023
  assert_eq(@typex.data_size_of_kilobytes(1024L), 1048576L) // OF_KB|1024
  let r132 : String = @typex.data_size_of_kilobytes(9223372036854775807L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r132, "ERR:Overflow") // OF_KB|9223372036854775807（参照 ArithmeticException）
  let r133 : String = @typex.data_size_of_kilobytes(-9223372036854775808L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r133, "ERR:Overflow") // OF_KB|-9223372036854775808（参照 ArithmeticException）
  assert_eq(
    @typex.data_size_of_kilobytes(9007199254740991L),
    9223372036854774784L,
  ) // OF_KB|9007199254740991
  let r135 : String = @typex.data_size_of_kilobytes(9007199254740992L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r135, "ERR:Overflow") // OF_KB|9007199254740992（参照 ArithmeticException）
  let r136 : String = @typex.data_size_of_kilobytes(-9007199254740993L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r136, "ERR:Overflow") // OF_KB|-9007199254740993（参照 ArithmeticException）
  assert_eq(@typex.data_size_of_kilobytes(1099511627776L), 1125899906842624L) // OF_KB|1099511627776
  assert_eq(@typex.data_size_of_kilobytes(1099511627777L), 1125899906843648L) // OF_KB|1099511627777
  assert_eq(@typex.data_size_of_kilobytes(9223372036854L), 9444732965738496L) // OF_KB|9223372036854

  assert_eq(@typex.data_size_of_megabytes(0L), 0L) // OF_MB|0
  assert_eq(@typex.data_size_of_megabytes(1L), 1048576L) // OF_MB|1
  assert_eq(@typex.data_size_of_megabytes(-1L), -1048576L) // OF_MB|-1
  assert_eq(@typex.data_size_of_megabytes(1023L), 1072693248L) // OF_MB|1023
  assert_eq(@typex.data_size_of_megabytes(1024L), 1073741824L) // OF_MB|1024
  let r145 : String = @typex.data_size_of_megabytes(9223372036854775807L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r145, "ERR:Overflow") // OF_MB|9223372036854775807（参照 ArithmeticException）
  let r146 : String = @typex.data_size_of_megabytes(-9223372036854775808L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r146, "ERR:Overflow") // OF_MB|-9223372036854775808（参照 ArithmeticException）
  let r147 : String = @typex.data_size_of_megabytes(9007199254740991L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r147, "ERR:Overflow") // OF_MB|9007199254740991（参照 ArithmeticException）
  let r148 : String = @typex.data_size_of_megabytes(9007199254740992L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r148, "ERR:Overflow") // OF_MB|9007199254740992（参照 ArithmeticException）
  let r149 : String = @typex.data_size_of_megabytes(-9007199254740993L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r149, "ERR:Overflow") // OF_MB|-9007199254740993（参照 ArithmeticException）
  assert_eq(@typex.data_size_of_megabytes(1099511627776L), 1152921504606846976L) // OF_MB|1099511627776
  assert_eq(@typex.data_size_of_megabytes(1099511627777L), 1152921504607895552L) // OF_MB|1099511627777
  let r152 : String = @typex.data_size_of_megabytes(9223372036854L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r152, "ERR:Overflow") // OF_MB|9223372036854（参照 ArithmeticException）

  assert_eq(@typex.data_size_of_gigabytes(0L), 0L) // OF_GB|0
  assert_eq(@typex.data_size_of_gigabytes(1L), 1073741824L) // OF_GB|1
  assert_eq(@typex.data_size_of_gigabytes(-1L), -1073741824L) // OF_GB|-1
  assert_eq(@typex.data_size_of_gigabytes(1023L), 1098437885952L) // OF_GB|1023
  assert_eq(@typex.data_size_of_gigabytes(1024L), 1099511627776L) // OF_GB|1024
  let r158 : String = @typex.data_size_of_gigabytes(9223372036854775807L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r158, "ERR:Overflow") // OF_GB|9223372036854775807（参照 ArithmeticException）
  let r159 : String = @typex.data_size_of_gigabytes(-9223372036854775808L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r159, "ERR:Overflow") // OF_GB|-9223372036854775808（参照 ArithmeticException）
  let r160 : String = @typex.data_size_of_gigabytes(9007199254740991L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r160, "ERR:Overflow") // OF_GB|9007199254740991（参照 ArithmeticException）
  let r161 : String = @typex.data_size_of_gigabytes(9007199254740992L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r161, "ERR:Overflow") // OF_GB|9007199254740992（参照 ArithmeticException）
  let r162 : String = @typex.data_size_of_gigabytes(-9007199254740993L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r162, "ERR:Overflow") // OF_GB|-9007199254740993（参照 ArithmeticException）
  let r163 : String = @typex.data_size_of_gigabytes(1099511627776L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r163, "ERR:Overflow") // OF_GB|1099511627776（参照 ArithmeticException）
  let r164 : String = @typex.data_size_of_gigabytes(1099511627777L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r164, "ERR:Overflow") // OF_GB|1099511627777（参照 ArithmeticException）
  let r165 : String = @typex.data_size_of_gigabytes(9223372036854L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r165, "ERR:Overflow") // OF_GB|9223372036854（参照 ArithmeticException）

  assert_eq(@typex.data_size_of_terabytes(0L), 0L) // OF_TB|0
  assert_eq(@typex.data_size_of_terabytes(1L), 1099511627776L) // OF_TB|1
  assert_eq(@typex.data_size_of_terabytes(-1L), -1099511627776L) // OF_TB|-1
  assert_eq(@typex.data_size_of_terabytes(1023L), 1124800395214848L) // OF_TB|1023
  assert_eq(@typex.data_size_of_terabytes(1024L), 1125899906842624L) // OF_TB|1024
  let r171 : String = @typex.data_size_of_terabytes(9223372036854775807L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r171, "ERR:Overflow") // OF_TB|9223372036854775807（参照 ArithmeticException）
  let r172 : String = @typex.data_size_of_terabytes(-9223372036854775808L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r172, "ERR:Overflow") // OF_TB|-9223372036854775808（参照 ArithmeticException）
  let r173 : String = @typex.data_size_of_terabytes(9007199254740991L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r173, "ERR:Overflow") // OF_TB|9007199254740991（参照 ArithmeticException）
  let r174 : String = @typex.data_size_of_terabytes(9007199254740992L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r174, "ERR:Overflow") // OF_TB|9007199254740992（参照 ArithmeticException）
  let r175 : String = @typex.data_size_of_terabytes(-9007199254740993L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r175, "ERR:Overflow") // OF_TB|-9007199254740993（参照 ArithmeticException）
  let r176 : String = @typex.data_size_of_terabytes(1099511627776L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r176, "ERR:Overflow") // OF_TB|1099511627776（参照 ArithmeticException）
  let r177 : String = @typex.data_size_of_terabytes(1099511627777L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r177, "ERR:Overflow") // OF_TB|1099511627777（参照 ArithmeticException）
  let r178 : String = @typex.data_size_of_terabytes(9223372036854L).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r178, "ERR:Overflow") // OF_TB|9223372036854（参照 ArithmeticException）

  assert_eq(@typex.data_size_of_amount_suffix(3L, "B"), 3L) // OF_UNIT|BYTES
  assert_eq(@typex.data_size_of_amount_suffix(3L, "KB"), 3072L) // OF_UNIT|KILOBYTES
  assert_eq(@typex.data_size_of_amount_suffix(3L, "MB"), 3145728L) // OF_UNIT|MEGABYTES
  assert_eq(@typex.data_size_of_amount_suffix(3L, "GB"), 3221225472L) // OF_UNIT|GIGABYTES
  assert_eq(@typex.data_size_of_amount_suffix(3L, "TB"), 3298534883328L) // OF_UNIT|TERABYTES

  assert_eq(
    @typex.data_size_of_amount_suffix(9223372036854775807L, "B"),
    9223372036854775807L,
  ) // OF_UNIT_BIG|BYTES
  let r185 : String = @typex.data_size_of_amount_suffix(
    9223372036854775807L, "KB",
  ).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r185, "ERR:Overflow") // OF_UNIT_BIG|KILOBYTES（参照 ArithmeticException）
  let r186 : String = @typex.data_size_of_amount_suffix(
    9223372036854775807L, "MB",
  ).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r186, "ERR:Overflow") // OF_UNIT_BIG|MEGABYTES（参照 ArithmeticException）
  let r187 : String = @typex.data_size_of_amount_suffix(
    9223372036854775807L, "GB",
  ).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r187, "ERR:Overflow") // OF_UNIT_BIG|GIGABYTES（参照 ArithmeticException）
  let r188 : String = @typex.data_size_of_amount_suffix(
    9223372036854775807L, "TB",
  ).to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(r188, "ERR:Overflow") // OF_UNIT_BIG|TERABYTES（参照 ArithmeticException）
}

///|
test "DataSize \u{51fa}\u{53e3}\u{ff1a}Java \u{5411}\u{96f6}\u{9664}\u{7684}\u{4e94}\u{6863}\u{4e0e} is_negative / to_string / compare / equal" {
  assert_eq(@typex.data_size_to_bytes(0L), 0L) // TO_BYTES|0
  assert_eq(@typex.data_size_to_bytes(1L), 1L) // TO_BYTES|1
  assert_eq(@typex.data_size_to_bytes(-1L), -1L) // TO_BYTES|-1
  assert_eq(@typex.data_size_to_bytes(1023L), 1023L) // TO_BYTES|1023
  assert_eq(@typex.data_size_to_bytes(-1023L), -1023L) // TO_BYTES|-1023
  assert_eq(@typex.data_size_to_bytes(1024L), 1024L) // TO_BYTES|1024
  assert_eq(@typex.data_size_to_bytes(-1024L), -1024L) // TO_BYTES|-1024
  assert_eq(@typex.data_size_to_bytes(1536L), 1536L) // TO_BYTES|1536
  assert_eq(@typex.data_size_to_bytes(-1536L), -1536L) // TO_BYTES|-1536
  assert_eq(@typex.data_size_to_bytes(1048575L), 1048575L) // TO_BYTES|1048575
  assert_eq(@typex.data_size_to_bytes(1048576L), 1048576L) // TO_BYTES|1048576
  assert_eq(@typex.data_size_to_bytes(-1048576L), -1048576L) // TO_BYTES|-1048576
  assert_eq(@typex.data_size_to_bytes(1073741824L), 1073741824L) // TO_BYTES|1073741824
  assert_eq(@typex.data_size_to_bytes(1099511627776L), 1099511627776L) // TO_BYTES|1099511627776
  assert_eq(
    @typex.data_size_to_bytes(9223372036854775807L),
    9223372036854775807L,
  ) // TO_BYTES|9223372036854775807
  assert_eq(
    @typex.data_size_to_bytes(-9223372036854775808L),
    -9223372036854775808L,
  ) // TO_BYTES|-9223372036854775808

  assert_eq(@typex.data_size_to_kilobytes(0L), 0L) // TO_KB|0
  assert_eq(@typex.data_size_to_kilobytes(1L), 0L) // TO_KB|1
  assert_eq(@typex.data_size_to_kilobytes(-1L), 0L) // TO_KB|-1
  assert_eq(@typex.data_size_to_kilobytes(1023L), 0L) // TO_KB|1023
  assert_eq(@typex.data_size_to_kilobytes(-1023L), 0L) // TO_KB|-1023
  assert_eq(@typex.data_size_to_kilobytes(1024L), 1L) // TO_KB|1024
  assert_eq(@typex.data_size_to_kilobytes(-1024L), -1L) // TO_KB|-1024
  assert_eq(@typex.data_size_to_kilobytes(1536L), 1L) // TO_KB|1536
  assert_eq(@typex.data_size_to_kilobytes(-1536L), -1L) // TO_KB|-1536
  assert_eq(@typex.data_size_to_kilobytes(1048575L), 1023L) // TO_KB|1048575
  assert_eq(@typex.data_size_to_kilobytes(1048576L), 1024L) // TO_KB|1048576
  assert_eq(@typex.data_size_to_kilobytes(-1048576L), -1024L) // TO_KB|-1048576
  assert_eq(@typex.data_size_to_kilobytes(1073741824L), 1048576L) // TO_KB|1073741824
  assert_eq(@typex.data_size_to_kilobytes(1099511627776L), 1073741824L) // TO_KB|1099511627776
  assert_eq(
    @typex.data_size_to_kilobytes(9223372036854775807L),
    9007199254740991L,
  ) // TO_KB|9223372036854775807
  assert_eq(
    @typex.data_size_to_kilobytes(-9223372036854775808L),
    -9007199254740992L,
  ) // TO_KB|-9223372036854775808

  assert_eq(@typex.data_size_to_megabytes(0L), 0L) // TO_MB|0
  assert_eq(@typex.data_size_to_megabytes(1L), 0L) // TO_MB|1
  assert_eq(@typex.data_size_to_megabytes(-1L), 0L) // TO_MB|-1
  assert_eq(@typex.data_size_to_megabytes(1023L), 0L) // TO_MB|1023
  assert_eq(@typex.data_size_to_megabytes(-1023L), 0L) // TO_MB|-1023
  assert_eq(@typex.data_size_to_megabytes(1024L), 0L) // TO_MB|1024
  assert_eq(@typex.data_size_to_megabytes(-1024L), 0L) // TO_MB|-1024
  assert_eq(@typex.data_size_to_megabytes(1536L), 0L) // TO_MB|1536
  assert_eq(@typex.data_size_to_megabytes(-1536L), 0L) // TO_MB|-1536
  assert_eq(@typex.data_size_to_megabytes(1048575L), 0L) // TO_MB|1048575
  assert_eq(@typex.data_size_to_megabytes(1048576L), 1L) // TO_MB|1048576
  assert_eq(@typex.data_size_to_megabytes(-1048576L), -1L) // TO_MB|-1048576
  assert_eq(@typex.data_size_to_megabytes(1073741824L), 1024L) // TO_MB|1073741824
  assert_eq(@typex.data_size_to_megabytes(1099511627776L), 1048576L) // TO_MB|1099511627776
  assert_eq(@typex.data_size_to_megabytes(9223372036854775807L), 8796093022207L) // TO_MB|9223372036854775807
  assert_eq(
    @typex.data_size_to_megabytes(-9223372036854775808L),
    -8796093022208L,
  ) // TO_MB|-9223372036854775808

  assert_eq(@typex.data_size_to_gigabytes(0L), 0L) // TO_GB|0
  assert_eq(@typex.data_size_to_gigabytes(1L), 0L) // TO_GB|1
  assert_eq(@typex.data_size_to_gigabytes(-1L), 0L) // TO_GB|-1
  assert_eq(@typex.data_size_to_gigabytes(1023L), 0L) // TO_GB|1023
  assert_eq(@typex.data_size_to_gigabytes(-1023L), 0L) // TO_GB|-1023
  assert_eq(@typex.data_size_to_gigabytes(1024L), 0L) // TO_GB|1024
  assert_eq(@typex.data_size_to_gigabytes(-1024L), 0L) // TO_GB|-1024
  assert_eq(@typex.data_size_to_gigabytes(1536L), 0L) // TO_GB|1536
  assert_eq(@typex.data_size_to_gigabytes(-1536L), 0L) // TO_GB|-1536
  assert_eq(@typex.data_size_to_gigabytes(1048575L), 0L) // TO_GB|1048575
  assert_eq(@typex.data_size_to_gigabytes(1048576L), 0L) // TO_GB|1048576
  assert_eq(@typex.data_size_to_gigabytes(-1048576L), 0L) // TO_GB|-1048576
  assert_eq(@typex.data_size_to_gigabytes(1073741824L), 1L) // TO_GB|1073741824
  assert_eq(@typex.data_size_to_gigabytes(1099511627776L), 1024L) // TO_GB|1099511627776
  assert_eq(@typex.data_size_to_gigabytes(9223372036854775807L), 8589934591L) // TO_GB|9223372036854775807
  assert_eq(@typex.data_size_to_gigabytes(-9223372036854775808L), -8589934592L) // TO_GB|-9223372036854775808

  assert_eq(@typex.data_size_to_terabytes(0L), 0L) // TO_TB|0
  assert_eq(@typex.data_size_to_terabytes(1L), 0L) // TO_TB|1
  assert_eq(@typex.data_size_to_terabytes(-1L), 0L) // TO_TB|-1
  assert_eq(@typex.data_size_to_terabytes(1023L), 0L) // TO_TB|1023
  assert_eq(@typex.data_size_to_terabytes(-1023L), 0L) // TO_TB|-1023
  assert_eq(@typex.data_size_to_terabytes(1024L), 0L) // TO_TB|1024
  assert_eq(@typex.data_size_to_terabytes(-1024L), 0L) // TO_TB|-1024
  assert_eq(@typex.data_size_to_terabytes(1536L), 0L) // TO_TB|1536
  assert_eq(@typex.data_size_to_terabytes(-1536L), 0L) // TO_TB|-1536
  assert_eq(@typex.data_size_to_terabytes(1048575L), 0L) // TO_TB|1048575
  assert_eq(@typex.data_size_to_terabytes(1048576L), 0L) // TO_TB|1048576
  assert_eq(@typex.data_size_to_terabytes(-1048576L), 0L) // TO_TB|-1048576
  assert_eq(@typex.data_size_to_terabytes(1073741824L), 0L) // TO_TB|1073741824
  assert_eq(@typex.data_size_to_terabytes(1099511627776L), 1L) // TO_TB|1099511627776
  assert_eq(@typex.data_size_to_terabytes(9223372036854775807L), 8388607L) // TO_TB|9223372036854775807
  assert_eq(@typex.data_size_to_terabytes(-9223372036854775808L), -8388608L) // TO_TB|-9223372036854775808

  assert_eq(@typex.data_size_is_negative(0L), false) // IS_NEG|0
  assert_eq(@typex.data_size_is_negative(1L), false) // IS_NEG|1
  assert_eq(@typex.data_size_is_negative(-1L), true) // IS_NEG|-1
  assert_eq(@typex.data_size_is_negative(1023L), false) // IS_NEG|1023
  assert_eq(@typex.data_size_is_negative(-1023L), true) // IS_NEG|-1023
  assert_eq(@typex.data_size_is_negative(1024L), false) // IS_NEG|1024
  assert_eq(@typex.data_size_is_negative(-1024L), true) // IS_NEG|-1024
  assert_eq(@typex.data_size_is_negative(1536L), false) // IS_NEG|1536
  assert_eq(@typex.data_size_is_negative(-1536L), true) // IS_NEG|-1536
  assert_eq(@typex.data_size_is_negative(1048575L), false) // IS_NEG|1048575
  assert_eq(@typex.data_size_is_negative(1048576L), false) // IS_NEG|1048576
  assert_eq(@typex.data_size_is_negative(-1048576L), true) // IS_NEG|-1048576
  assert_eq(@typex.data_size_is_negative(1073741824L), false) // IS_NEG|1073741824
  assert_eq(@typex.data_size_is_negative(1099511627776L), false) // IS_NEG|1099511627776
  assert_eq(@typex.data_size_is_negative(9223372036854775807L), false) // IS_NEG|9223372036854775807
  assert_eq(@typex.data_size_is_negative(-9223372036854775808L), true) // IS_NEG|-9223372036854775808

  assert_eq(@typex.data_size_to_string(0L), "0B") // TO_STRING|0
  assert_eq(@typex.data_size_to_string(1L), "1B") // TO_STRING|1
  assert_eq(@typex.data_size_to_string(-1L), "-1B") // TO_STRING|-1
  assert_eq(@typex.data_size_to_string(1023L), "1023B") // TO_STRING|1023
  assert_eq(@typex.data_size_to_string(-1023L), "-1023B") // TO_STRING|-1023
  assert_eq(@typex.data_size_to_string(1024L), "1024B") // TO_STRING|1024
  assert_eq(@typex.data_size_to_string(-1024L), "-1024B") // TO_STRING|-1024
  assert_eq(@typex.data_size_to_string(1536L), "1536B") // TO_STRING|1536
  assert_eq(@typex.data_size_to_string(-1536L), "-1536B") // TO_STRING|-1536
  assert_eq(@typex.data_size_to_string(1048575L), "1048575B") // TO_STRING|1048575
  assert_eq(@typex.data_size_to_string(1048576L), "1048576B") // TO_STRING|1048576
  assert_eq(@typex.data_size_to_string(-1048576L), "-1048576B") // TO_STRING|-1048576
  assert_eq(@typex.data_size_to_string(1073741824L), "1073741824B") // TO_STRING|1073741824
  assert_eq(@typex.data_size_to_string(1099511627776L), "1099511627776B") // TO_STRING|1099511627776
  assert_eq(
    @typex.data_size_to_string(9223372036854775807L),
    "9223372036854775807B",
  ) // TO_STRING|9223372036854775807
  assert_eq(
    @typex.data_size_to_string(-9223372036854775808L),
    "-9223372036854775808B",
  ) // TO_STRING|-9223372036854775808

  assert_eq(@typex.data_size_compare(0L, 0L), 0) // CMP_VS_ZERO|0
  assert_eq(@typex.data_size_compare(1L, 0L), 1) // CMP_VS_ZERO|1
  assert_eq(@typex.data_size_compare(-1L, 0L), -1) // CMP_VS_ZERO|-1
  assert_eq(@typex.data_size_compare(1023L, 0L), 1) // CMP_VS_ZERO|1023
  assert_eq(@typex.data_size_compare(-1023L, 0L), -1) // CMP_VS_ZERO|-1023
  assert_eq(@typex.data_size_compare(1024L, 0L), 1) // CMP_VS_ZERO|1024
  assert_eq(@typex.data_size_compare(-1024L, 0L), -1) // CMP_VS_ZERO|-1024
  assert_eq(@typex.data_size_compare(1536L, 0L), 1) // CMP_VS_ZERO|1536
  assert_eq(@typex.data_size_compare(-1536L, 0L), -1) // CMP_VS_ZERO|-1536
  assert_eq(@typex.data_size_compare(1048575L, 0L), 1) // CMP_VS_ZERO|1048575
  assert_eq(@typex.data_size_compare(1048576L, 0L), 1) // CMP_VS_ZERO|1048576
  assert_eq(@typex.data_size_compare(-1048576L, 0L), -1) // CMP_VS_ZERO|-1048576
  assert_eq(@typex.data_size_compare(1073741824L, 0L), 1) // CMP_VS_ZERO|1073741824
  assert_eq(@typex.data_size_compare(1099511627776L, 0L), 1) // CMP_VS_ZERO|1099511627776
  assert_eq(@typex.data_size_compare(9223372036854775807L, 0L), 1) // CMP_VS_ZERO|9223372036854775807
  assert_eq(@typex.data_size_compare(-9223372036854775808L, 0L), -1) // CMP_VS_ZERO|-9223372036854775808

  assert_eq(@typex.data_size_equal(0L, 0L), true) // EQ_VS_ZERO|0
  assert_eq(@typex.data_size_equal(1L, 0L), false) // EQ_VS_ZERO|1
  assert_eq(@typex.data_size_equal(-1L, 0L), false) // EQ_VS_ZERO|-1
  assert_eq(@typex.data_size_equal(1023L, 0L), false) // EQ_VS_ZERO|1023
  assert_eq(@typex.data_size_equal(-1023L, 0L), false) // EQ_VS_ZERO|-1023
  assert_eq(@typex.data_size_equal(1024L, 0L), false) // EQ_VS_ZERO|1024
  assert_eq(@typex.data_size_equal(-1024L, 0L), false) // EQ_VS_ZERO|-1024
  assert_eq(@typex.data_size_equal(1536L, 0L), false) // EQ_VS_ZERO|1536
  assert_eq(@typex.data_size_equal(-1536L, 0L), false) // EQ_VS_ZERO|-1536
  assert_eq(@typex.data_size_equal(1048575L, 0L), false) // EQ_VS_ZERO|1048575
  assert_eq(@typex.data_size_equal(1048576L, 0L), false) // EQ_VS_ZERO|1048576
  assert_eq(@typex.data_size_equal(-1048576L, 0L), false) // EQ_VS_ZERO|-1048576
  assert_eq(@typex.data_size_equal(1073741824L, 0L), false) // EQ_VS_ZERO|1073741824
  assert_eq(@typex.data_size_equal(1099511627776L, 0L), false) // EQ_VS_ZERO|1099511627776
  assert_eq(@typex.data_size_equal(9223372036854775807L, 0L), false) // EQ_VS_ZERO|9223372036854775807
  assert_eq(@typex.data_size_equal(-9223372036854775808L, 0L), false) // EQ_VS_ZERO|-9223372036854775808
}

///|
test "DataUnit \u{8868}\u{ff1a}\u{4e94}\u{679a}\u{5355}\u{4f4d}\u{7684}\u{5b57}\u{8282}\u{6570}\u{4e0e} UNIT_NAMES \u{4e03}\u{679a}\u{ff08}PB/EB \u{53cd}\u{67e5} None\u{ff09}" {
  assert_eq(@typex.data_unit_bytes_by_suffix("B"), Some(1L)) // SUFFIX|"B"
  assert_eq(@typex.data_unit_bytes_by_suffix("KB"), Some(1024L)) // SUFFIX|"KB"
  assert_eq(@typex.data_unit_bytes_by_suffix("MB"), Some(1048576L)) // SUFFIX|"MB"
  assert_eq(@typex.data_unit_bytes_by_suffix("GB"), Some(1073741824L)) // SUFFIX|"GB"
  assert_eq(@typex.data_unit_bytes_by_suffix("TB"), Some(1099511627776L)) // SUFFIX|"TB"

  assert_eq(@typex.data_unit_suffixes(), [
    "B", "KB", "MB", "GB", "TB", "PB", "EB",
  ]) // SRC_UNIT_NAMES|-

  assert_eq(@typex.data_unit_bytes_by_suffix("B"), Some(1L)) // FROM_SUFFIX|B
  assert_eq(@typex.data_unit_bytes_by_suffix("KB"), Some(1024L)) // FROM_SUFFIX|KB
  assert_eq(@typex.data_unit_bytes_by_suffix("MB"), Some(1048576L)) // FROM_SUFFIX|MB
  assert_eq(@typex.data_unit_bytes_by_suffix("GB"), Some(1073741824L)) // FROM_SUFFIX|GB
  assert_eq(@typex.data_unit_bytes_by_suffix("TB"), Some(1099511627776L)) // FROM_SUFFIX|TB
  assert_eq(@typex.data_unit_bytes_by_suffix("kb"), Some(1024L)) // FROM_SUFFIX|kb
  assert_eq(@typex.data_unit_bytes_by_suffix("Kb"), Some(1024L)) // FROM_SUFFIX|Kb
  assert_eq(@typex.data_unit_bytes_by_suffix("PB"), None) // FROM_SUFFIX|PB（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.data_unit_bytes_by_suffix("EB"), None) // FROM_SUFFIX|EB（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.data_unit_bytes_by_suffix(""), Some(1L)) // FROM_SUFFIX|
  assert_eq(@typex.data_unit_bytes_by_suffix(" "), None) // FROM_SUFFIX| （参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.data_unit_bytes_by_suffix("X"), None) // FROM_SUFFIX|X（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.data_unit_bytes_by_suffix("BB"), None) // FROM_SUFFIX|BB（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.data_unit_bytes_by_suffix("K"), Some(1024L)) // FROM_SUFFIX|K
  assert_eq(@typex.data_unit_bytes_by_suffix("M"), Some(1048576L)) // FROM_SUFFIX|M
  assert_eq(@typex.data_unit_bytes_by_suffix("G"), Some(1073741824L)) // FROM_SUFFIX|G
  assert_eq(@typex.data_unit_bytes_by_suffix("T"), Some(1099511627776L)) // FROM_SUFFIX|T
  assert_eq(@typex.data_unit_bytes_by_suffix("b"), Some(1L)) // FROM_SUFFIX|b
  assert_eq(@typex.data_unit_bytes_by_suffix("g"), Some(1073741824L)) // FROM_SUFFIX|g
  assert_eq(@typex.data_unit_bytes_by_suffix("kBB"), None) // FROM_SUFFIX|kBB（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.data_unit_bytes_by_suffix("BBB"), None) // FROM_SUFFIX|BBB（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.data_unit_bytes_by_suffix("TB "), None) // FROM_SUFFIX|TB （参照 IllegalArgumentException → 映射 None）
}
