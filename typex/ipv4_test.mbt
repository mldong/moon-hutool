///|
// typex 第二批（Ipv4Util）的期望值全部由生成脚本从参照腿灌入（手打零条）。
// 腿：真 hutool-core-5.8.35.jar，件在 `cn/hutool/core/net/Ipv4Util`，JDK 17.0.14，`javac -encoding UTF-8`。
// 异常档不写 Java 的 class:message 原文，改按 spec §10 的映射表落到本包 `Ipv4Error` 变体；
// 映射证据（类名 + message）留在腿的 ERR 行里。IP 合法性判据复用 `@valid.is_ipv4`（三方零分歧，见 spec §10.3 第 2 条）。

///|
fn itag(e : @typex.Ipv4Error) -> String {
  match e {
    BadIp => "BadIp"
    BadMask => "BadMask"
    BadMaskBit => "BadMaskBit"
    BadRange => "BadRange"
  }
}

///|
test "Ipv4 \u{7b2c}\u{4e8c}\u{6279} long \u{4e0e}\u{70b9}\u{5206}\u{4e32}\u{4e92}\u{8f6c}\u{ff08}\u{542b}\u{9ad8}\u{4f4d}\u{622a}\u{65ad}\u{4e0e}\u{8d1f}\u{6570}\u{6863}\u{ff09}" {
  assert_eq(@typex.long_to_ipv4(0L), "0.0.0.0") // L2I|0
  assert_eq(@typex.long_to_ipv4(1L), "0.0.0.1") // L2I|1
  assert_eq(@typex.long_to_ipv4(255L), "0.0.0.255") // L2I|255
  assert_eq(@typex.long_to_ipv4(256L), "0.0.1.0") // L2I|256
  assert_eq(@typex.long_to_ipv4(16909060L), "1.2.3.4") // L2I|16909060
  assert_eq(@typex.long_to_ipv4(2130706433L), "127.0.0.1") // L2I|2130706433
  assert_eq(@typex.long_to_ipv4(2147483647L), "127.255.255.255") // L2I|2147483647
  assert_eq(@typex.long_to_ipv4(4294967295L), "255.255.255.255") // L2I|4294967295
  assert_eq(@typex.long_to_ipv4(4294967296L), "0.0.0.0") // L2I|4294967296
  assert_eq(@typex.long_to_ipv4(-1L), "255.255.255.255") // L2I|-1
  assert_eq(@typex.long_to_ipv4(-2L), "255.255.255.254") // L2I|-2
  assert_eq(@typex.long_to_ipv4(-9223372036854775808L), "0.0.0.0") // L2I|-9223372036854775808
  assert_eq(@typex.long_to_ipv4(9223372036854775807L), "255.255.255.255") // L2I|9223372036854775807

  let r14 : String = @typex.ipv4_to_long("0.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r14, "0") // TOL|0.0.0.0
  let r15 : String = @typex.ipv4_to_long("1.2.3.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r15, "16909060") // TOL|1.2.3.4
  let r16 : String = @typex.ipv4_to_long("255.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r16, "4294967295") // TOL|255.255.255.255
  let r17 : String = @typex.ipv4_to_long("01.2.3.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r17, "16909060") // TOL|01.2.3.4
  let r18 : String = @typex.ipv4_to_long("001.002.003.004").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r18, "16909060") // TOL|001.002.003.004
  let r19 : String = @typex.ipv4_to_long("1.2.3.04").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r19, "16909060") // TOL|1.2.3.04
  let r20 : String = @typex.ipv4_to_long("127.0.0.1").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r20, "2130706433") // TOL|127.0.0.1
  let r21 : String = @typex.ipv4_to_long("10.0.0.1").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r21, "167772161") // TOL|10.0.0.1
  let r22 : String = @typex.ipv4_to_long("218.240.38.69").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r22, "3673171525") // TOL|218.240.38.69
  let r23 : String = @typex.ipv4_to_long("192.168.1.1").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r23, "3232235777") // TOL|192.168.1.1
  let r24 : String = @typex.ipv4_to_long("256.1.1.1").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r24, "ERR:BadIp") // TOL|256.1.1.1
  let r25 : String = @typex.ipv4_to_long("999.999.999.999").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r25, "ERR:BadIp") // TOL|999.999.999.999
  let r26 : String = @typex.ipv4_to_long("1.2.3").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r26, "ERR:BadIp") // TOL|1.2.3
  let r27 : String = @typex.ipv4_to_long("1.2.3.4.5").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r27, "ERR:BadIp") // TOL|1.2.3.4.5
  let r28 : String = @typex.ipv4_to_long("").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r28, "ERR:BadIp") // TOL|
  let r29 : String = @typex.ipv4_to_long(" ").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r29, "ERR:BadIp") // TOL| 
  let r30 : String = @typex.ipv4_to_long("1.2.3.4 ").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r30, "ERR:BadIp") // TOL|1.2.3.4 
  let r31 : String = @typex.ipv4_to_long(" 1.2.3.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r31, "ERR:BadIp") // TOL| 1.2.3.4
  let r32 : String = @typex.ipv4_to_long("1 .2.3.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r32, "ERR:BadIp") // TOL|1 .2.3.4
  let r33 : String = @typex.ipv4_to_long("1.2.3.-4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r33, "ERR:BadIp") // TOL|1.2.3.-4
  let r34 : String = @typex.ipv4_to_long("1.2.3.0000004").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r34, "ERR:BadIp") // TOL|1.2.3.0000004
  let r35 : String = @typex.ipv4_to_long("1.2.3.4a").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r35, "ERR:BadIp") // TOL|1.2.3.4a
  let r36 : String = @typex.ipv4_to_long("1.2.3.\u{ff14}").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r36, "ERR:BadIp") // TOL|1.2.3.\uff14
  let r37 : String = @typex.ipv4_to_long("\u{661}.2.3.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r37, "ERR:BadIp") // TOL|\u0661.2.3.4

  assert_eq(@typex.ipv4_to_long_or("0.0.0.0", -1L), 0L) // TOLD|0.0.0.0|-1
  assert_eq(@typex.ipv4_to_long_or("1.2.3.4", -1L), 16909060L) // TOLD|1.2.3.4|-1
  assert_eq(@typex.ipv4_to_long_or("255.255.255.255", -1L), 4294967295L) // TOLD|255.255.255.255|-1
  assert_eq(@typex.ipv4_to_long_or("01.2.3.4", -1L), 16909060L) // TOLD|01.2.3.4|-1
  assert_eq(@typex.ipv4_to_long_or("001.002.003.004", -1L), 16909060L) // TOLD|001.002.003.004|-1
  assert_eq(@typex.ipv4_to_long_or("1.2.3.04", -1L), 16909060L) // TOLD|1.2.3.04|-1
  assert_eq(@typex.ipv4_to_long_or("127.0.0.1", -1L), 2130706433L) // TOLD|127.0.0.1|-1
  assert_eq(@typex.ipv4_to_long_or("10.0.0.1", -1L), 167772161L) // TOLD|10.0.0.1|-1
  assert_eq(@typex.ipv4_to_long_or("218.240.38.69", -1L), 3673171525L) // TOLD|218.240.38.69|-1
  assert_eq(@typex.ipv4_to_long_or("192.168.1.1", -1L), 3232235777L) // TOLD|192.168.1.1|-1
  assert_eq(@typex.ipv4_to_long_or("256.1.1.1", -1L), -1L) // TOLD|256.1.1.1|-1
  assert_eq(@typex.ipv4_to_long_or("999.999.999.999", -1L), -1L) // TOLD|999.999.999.999|-1
  assert_eq(@typex.ipv4_to_long_or("1.2.3", -1L), -1L) // TOLD|1.2.3|-1
  assert_eq(@typex.ipv4_to_long_or("1.2.3.4.5", -1L), -1L) // TOLD|1.2.3.4.5|-1
  assert_eq(@typex.ipv4_to_long_or("", -1L), -1L) // TOLD||-1
  assert_eq(@typex.ipv4_to_long_or(" ", -1L), -1L) // TOLD| |-1
  assert_eq(@typex.ipv4_to_long_or("1.2.3.4 ", -1L), -1L) // TOLD|1.2.3.4 |-1
  assert_eq(@typex.ipv4_to_long_or(" 1.2.3.4", -1L), -1L) // TOLD| 1.2.3.4|-1
  assert_eq(@typex.ipv4_to_long_or("1 .2.3.4", -1L), -1L) // TOLD|1 .2.3.4|-1
  assert_eq(@typex.ipv4_to_long_or("1.2.3.-4", -1L), -1L) // TOLD|1.2.3.-4|-1
  assert_eq(@typex.ipv4_to_long_or("1.2.3.0000004", -1L), -1L) // TOLD|1.2.3.0000004|-1
  assert_eq(@typex.ipv4_to_long_or("1.2.3.4a", -1L), -1L) // TOLD|1.2.3.4a|-1
  assert_eq(@typex.ipv4_to_long_or("1.2.3.\u{ff14}", -1L), -1L) // TOLD|1.2.3.\uff14|-1
  assert_eq(@typex.ipv4_to_long_or("\u{661}.2.3.4", -1L), -1L) // TOLD|\u0661.2.3.4|-1
}

///|
test "Ipv4 \u{7b2c}\u{4e8c}\u{6279}\u{7f51}\u{6bb5}\u{8d77}\u{6b62}\u{56db}\u{4ef6}\u{ff08}\u{63a9}\u{7801}\u{4f4d}\u{5168}\u{6863} + \u{975e}\u{6cd5}\u{4f4d}\u{7684}\u{9519}\u{8bef}\u{4f18}\u{5148}\u{5e8f}\u{ff09}" {
  let r62 : String = @typex.ipv4_begin_ip_str("218.240.38.69", -2).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r62, "ERR:BadMaskBit") // BSTR|218.240.38.69|-2
  let r63 : String = @typex.ipv4_begin_ip_str("218.240.38.69", -1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r63, "ERR:BadMaskBit") // BSTR|218.240.38.69|-1
  let r64 : String = @typex.ipv4_begin_ip_str("218.240.38.69", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r64, "ERR:BadMaskBit") // BSTR|218.240.38.69|0
  let r65 : String = @typex.ipv4_begin_ip_str("218.240.38.69", 1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r65, "128.0.0.0") // BSTR|218.240.38.69|1
  let r66 : String = @typex.ipv4_begin_ip_str("218.240.38.69", 8).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r66, "218.0.0.0") // BSTR|218.240.38.69|8
  let r67 : String = @typex.ipv4_begin_ip_str("218.240.38.69", 16).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r67, "218.240.0.0") // BSTR|218.240.38.69|16
  let r68 : String = @typex.ipv4_begin_ip_str("218.240.38.69", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r68, "218.240.38.0") // BSTR|218.240.38.69|24
  let r69 : String = @typex.ipv4_begin_ip_str("218.240.38.69", 30).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r69, "218.240.38.68") // BSTR|218.240.38.69|30
  let r70 : String = @typex.ipv4_begin_ip_str("218.240.38.69", 31).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r70, "218.240.38.68") // BSTR|218.240.38.69|31
  let r71 : String = @typex.ipv4_begin_ip_str("218.240.38.69", 32).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r71, "218.240.38.69") // BSTR|218.240.38.69|32
  let r72 : String = @typex.ipv4_begin_ip_str("218.240.38.69", 33).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r72, "ERR:BadMaskBit") // BSTR|218.240.38.69|33
  let r73 : String = @typex.ipv4_begin_ip_str("218.240.38.69", 64).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r73, "ERR:BadMaskBit") // BSTR|218.240.38.69|64
  let r74 : String = @typex.ipv4_begin_ip_str("192.168.1.1", -2).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r74, "ERR:BadMaskBit") // BSTR|192.168.1.1|-2
  let r75 : String = @typex.ipv4_begin_ip_str("192.168.1.1", -1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r75, "ERR:BadMaskBit") // BSTR|192.168.1.1|-1
  let r76 : String = @typex.ipv4_begin_ip_str("192.168.1.1", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r76, "ERR:BadMaskBit") // BSTR|192.168.1.1|0
  let r77 : String = @typex.ipv4_begin_ip_str("192.168.1.1", 1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r77, "128.0.0.0") // BSTR|192.168.1.1|1
  let r78 : String = @typex.ipv4_begin_ip_str("192.168.1.1", 8).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r78, "192.0.0.0") // BSTR|192.168.1.1|8
  let r79 : String = @typex.ipv4_begin_ip_str("192.168.1.1", 16).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r79, "192.168.0.0") // BSTR|192.168.1.1|16
  let r80 : String = @typex.ipv4_begin_ip_str("192.168.1.1", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r80, "192.168.1.0") // BSTR|192.168.1.1|24
  let r81 : String = @typex.ipv4_begin_ip_str("192.168.1.1", 30).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r81, "192.168.1.0") // BSTR|192.168.1.1|30
  let r82 : String = @typex.ipv4_begin_ip_str("192.168.1.1", 31).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r82, "192.168.1.0") // BSTR|192.168.1.1|31
  let r83 : String = @typex.ipv4_begin_ip_str("192.168.1.1", 32).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r83, "192.168.1.1") // BSTR|192.168.1.1|32
  let r84 : String = @typex.ipv4_begin_ip_str("192.168.1.1", 33).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r84, "ERR:BadMaskBit") // BSTR|192.168.1.1|33
  let r85 : String = @typex.ipv4_begin_ip_str("192.168.1.1", 64).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r85, "ERR:BadMaskBit") // BSTR|192.168.1.1|64
  let r86 : String = @typex.ipv4_begin_ip_str("0.0.0.0", -2).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r86, "ERR:BadMaskBit") // BSTR|0.0.0.0|-2
  let r87 : String = @typex.ipv4_begin_ip_str("0.0.0.0", -1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r87, "ERR:BadMaskBit") // BSTR|0.0.0.0|-1
  let r88 : String = @typex.ipv4_begin_ip_str("0.0.0.0", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r88, "ERR:BadMaskBit") // BSTR|0.0.0.0|0
  let r89 : String = @typex.ipv4_begin_ip_str("0.0.0.0", 1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r89, "0.0.0.0") // BSTR|0.0.0.0|1
  let r90 : String = @typex.ipv4_begin_ip_str("0.0.0.0", 8).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r90, "0.0.0.0") // BSTR|0.0.0.0|8
  let r91 : String = @typex.ipv4_begin_ip_str("0.0.0.0", 16).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r91, "0.0.0.0") // BSTR|0.0.0.0|16
  let r92 : String = @typex.ipv4_begin_ip_str("0.0.0.0", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r92, "0.0.0.0") // BSTR|0.0.0.0|24
  let r93 : String = @typex.ipv4_begin_ip_str("0.0.0.0", 30).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r93, "0.0.0.0") // BSTR|0.0.0.0|30
  let r94 : String = @typex.ipv4_begin_ip_str("0.0.0.0", 31).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r94, "0.0.0.0") // BSTR|0.0.0.0|31
  let r95 : String = @typex.ipv4_begin_ip_str("0.0.0.0", 32).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r95, "0.0.0.0") // BSTR|0.0.0.0|32
  let r96 : String = @typex.ipv4_begin_ip_str("0.0.0.0", 33).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r96, "ERR:BadMaskBit") // BSTR|0.0.0.0|33
  let r97 : String = @typex.ipv4_begin_ip_str("0.0.0.0", 64).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r97, "ERR:BadMaskBit") // BSTR|0.0.0.0|64
  let r98 : String = @typex.ipv4_begin_ip_str("256.1.1.1", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r98, "ERR:BadIp") // BSTR|256.1.1.1|24
  let r99 : String = @typex.ipv4_begin_ip_str("256.1.1.1", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r99, "ERR:BadIp") // BSTR|256.1.1.1|0

  let r100 : String = @typex.ipv4_begin_ip_long("218.240.38.69", -2).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r100, "ERR:BadMaskBit") // BLNG|218.240.38.69|-2
  let r101 : String = @typex.ipv4_begin_ip_long("218.240.38.69", -1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r101, "ERR:BadMaskBit") // BLNG|218.240.38.69|-1
  let r102 : String = @typex.ipv4_begin_ip_long("218.240.38.69", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r102, "ERR:BadMaskBit") // BLNG|218.240.38.69|0
  let r103 : String = @typex.ipv4_begin_ip_long("218.240.38.69", 1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r103, "2147483648") // BLNG|218.240.38.69|1
  let r104 : String = @typex.ipv4_begin_ip_long("218.240.38.69", 8).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r104, "3657433088") // BLNG|218.240.38.69|8
  let r105 : String = @typex.ipv4_begin_ip_long("218.240.38.69", 16).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r105, "3673161728") // BLNG|218.240.38.69|16
  let r106 : String = @typex.ipv4_begin_ip_long("218.240.38.69", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r106, "3673171456") // BLNG|218.240.38.69|24
  let r107 : String = @typex.ipv4_begin_ip_long("218.240.38.69", 30).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r107, "3673171524") // BLNG|218.240.38.69|30
  let r108 : String = @typex.ipv4_begin_ip_long("218.240.38.69", 31).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r108, "3673171524") // BLNG|218.240.38.69|31
  let r109 : String = @typex.ipv4_begin_ip_long("218.240.38.69", 32).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r109, "3673171525") // BLNG|218.240.38.69|32
  let r110 : String = @typex.ipv4_begin_ip_long("218.240.38.69", 33).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r110, "ERR:BadMaskBit") // BLNG|218.240.38.69|33
  let r111 : String = @typex.ipv4_begin_ip_long("218.240.38.69", 64).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r111, "ERR:BadMaskBit") // BLNG|218.240.38.69|64
  let r112 : String = @typex.ipv4_begin_ip_long("192.168.1.1", -2).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r112, "ERR:BadMaskBit") // BLNG|192.168.1.1|-2
  let r113 : String = @typex.ipv4_begin_ip_long("192.168.1.1", -1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r113, "ERR:BadMaskBit") // BLNG|192.168.1.1|-1
  let r114 : String = @typex.ipv4_begin_ip_long("192.168.1.1", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r114, "ERR:BadMaskBit") // BLNG|192.168.1.1|0
  let r115 : String = @typex.ipv4_begin_ip_long("192.168.1.1", 1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r115, "2147483648") // BLNG|192.168.1.1|1
  let r116 : String = @typex.ipv4_begin_ip_long("192.168.1.1", 8).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r116, "3221225472") // BLNG|192.168.1.1|8
  let r117 : String = @typex.ipv4_begin_ip_long("192.168.1.1", 16).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r117, "3232235520") // BLNG|192.168.1.1|16
  let r118 : String = @typex.ipv4_begin_ip_long("192.168.1.1", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r118, "3232235776") // BLNG|192.168.1.1|24
  let r119 : String = @typex.ipv4_begin_ip_long("192.168.1.1", 30).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r119, "3232235776") // BLNG|192.168.1.1|30
  let r120 : String = @typex.ipv4_begin_ip_long("192.168.1.1", 31).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r120, "3232235776") // BLNG|192.168.1.1|31
  let r121 : String = @typex.ipv4_begin_ip_long("192.168.1.1", 32).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r121, "3232235777") // BLNG|192.168.1.1|32
  let r122 : String = @typex.ipv4_begin_ip_long("192.168.1.1", 33).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r122, "ERR:BadMaskBit") // BLNG|192.168.1.1|33
  let r123 : String = @typex.ipv4_begin_ip_long("192.168.1.1", 64).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r123, "ERR:BadMaskBit") // BLNG|192.168.1.1|64
  let r124 : String = @typex.ipv4_begin_ip_long("0.0.0.0", -2).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r124, "ERR:BadMaskBit") // BLNG|0.0.0.0|-2
  let r125 : String = @typex.ipv4_begin_ip_long("0.0.0.0", -1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r125, "ERR:BadMaskBit") // BLNG|0.0.0.0|-1
  let r126 : String = @typex.ipv4_begin_ip_long("0.0.0.0", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r126, "ERR:BadMaskBit") // BLNG|0.0.0.0|0
  let r127 : String = @typex.ipv4_begin_ip_long("0.0.0.0", 1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r127, "0") // BLNG|0.0.0.0|1
  let r128 : String = @typex.ipv4_begin_ip_long("0.0.0.0", 8).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r128, "0") // BLNG|0.0.0.0|8
  let r129 : String = @typex.ipv4_begin_ip_long("0.0.0.0", 16).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r129, "0") // BLNG|0.0.0.0|16
  let r130 : String = @typex.ipv4_begin_ip_long("0.0.0.0", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r130, "0") // BLNG|0.0.0.0|24
  let r131 : String = @typex.ipv4_begin_ip_long("0.0.0.0", 30).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r131, "0") // BLNG|0.0.0.0|30
  let r132 : String = @typex.ipv4_begin_ip_long("0.0.0.0", 31).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r132, "0") // BLNG|0.0.0.0|31
  let r133 : String = @typex.ipv4_begin_ip_long("0.0.0.0", 32).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r133, "0") // BLNG|0.0.0.0|32
  let r134 : String = @typex.ipv4_begin_ip_long("0.0.0.0", 33).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r134, "ERR:BadMaskBit") // BLNG|0.0.0.0|33
  let r135 : String = @typex.ipv4_begin_ip_long("0.0.0.0", 64).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r135, "ERR:BadMaskBit") // BLNG|0.0.0.0|64
  let r136 : String = @typex.ipv4_begin_ip_long("256.1.1.1", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r136, "ERR:BadIp") // BLNG|256.1.1.1|24
  let r137 : String = @typex.ipv4_begin_ip_long("256.1.1.1", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r137, "ERR:BadIp") // BLNG|256.1.1.1|0

  let r138 : String = @typex.ipv4_end_ip_str("218.240.38.69", -2).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r138, "ERR:BadMaskBit") // ESTR|218.240.38.69|-2
  let r139 : String = @typex.ipv4_end_ip_str("218.240.38.69", -1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r139, "ERR:BadMaskBit") // ESTR|218.240.38.69|-1
  let r140 : String = @typex.ipv4_end_ip_str("218.240.38.69", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r140, "ERR:BadMaskBit") // ESTR|218.240.38.69|0
  let r141 : String = @typex.ipv4_end_ip_str("218.240.38.69", 1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r141, "255.255.255.255") // ESTR|218.240.38.69|1
  let r142 : String = @typex.ipv4_end_ip_str("218.240.38.69", 8).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r142, "218.255.255.255") // ESTR|218.240.38.69|8
  let r143 : String = @typex.ipv4_end_ip_str("218.240.38.69", 16).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r143, "218.240.255.255") // ESTR|218.240.38.69|16
  let r144 : String = @typex.ipv4_end_ip_str("218.240.38.69", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r144, "218.240.38.255") // ESTR|218.240.38.69|24
  let r145 : String = @typex.ipv4_end_ip_str("218.240.38.69", 30).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r145, "218.240.38.71") // ESTR|218.240.38.69|30
  let r146 : String = @typex.ipv4_end_ip_str("218.240.38.69", 31).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r146, "218.240.38.69") // ESTR|218.240.38.69|31
  let r147 : String = @typex.ipv4_end_ip_str("218.240.38.69", 32).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r147, "218.240.38.69") // ESTR|218.240.38.69|32
  let r148 : String = @typex.ipv4_end_ip_str("218.240.38.69", 33).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r148, "ERR:BadMaskBit") // ESTR|218.240.38.69|33
  let r149 : String = @typex.ipv4_end_ip_str("218.240.38.69", 64).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r149, "ERR:BadMaskBit") // ESTR|218.240.38.69|64
  let r150 : String = @typex.ipv4_end_ip_str("192.168.1.1", -2).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r150, "ERR:BadMaskBit") // ESTR|192.168.1.1|-2
  let r151 : String = @typex.ipv4_end_ip_str("192.168.1.1", -1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r151, "ERR:BadMaskBit") // ESTR|192.168.1.1|-1
  let r152 : String = @typex.ipv4_end_ip_str("192.168.1.1", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r152, "ERR:BadMaskBit") // ESTR|192.168.1.1|0
  let r153 : String = @typex.ipv4_end_ip_str("192.168.1.1", 1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r153, "255.255.255.255") // ESTR|192.168.1.1|1
  let r154 : String = @typex.ipv4_end_ip_str("192.168.1.1", 8).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r154, "192.255.255.255") // ESTR|192.168.1.1|8
  let r155 : String = @typex.ipv4_end_ip_str("192.168.1.1", 16).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r155, "192.168.255.255") // ESTR|192.168.1.1|16
  let r156 : String = @typex.ipv4_end_ip_str("192.168.1.1", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r156, "192.168.1.255") // ESTR|192.168.1.1|24
  let r157 : String = @typex.ipv4_end_ip_str("192.168.1.1", 30).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r157, "192.168.1.3") // ESTR|192.168.1.1|30
  let r158 : String = @typex.ipv4_end_ip_str("192.168.1.1", 31).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r158, "192.168.1.1") // ESTR|192.168.1.1|31
  let r159 : String = @typex.ipv4_end_ip_str("192.168.1.1", 32).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r159, "192.168.1.1") // ESTR|192.168.1.1|32
  let r160 : String = @typex.ipv4_end_ip_str("192.168.1.1", 33).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r160, "ERR:BadMaskBit") // ESTR|192.168.1.1|33
  let r161 : String = @typex.ipv4_end_ip_str("192.168.1.1", 64).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r161, "ERR:BadMaskBit") // ESTR|192.168.1.1|64
  let r162 : String = @typex.ipv4_end_ip_str("0.0.0.0", -2).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r162, "ERR:BadMaskBit") // ESTR|0.0.0.0|-2
  let r163 : String = @typex.ipv4_end_ip_str("0.0.0.0", -1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r163, "ERR:BadMaskBit") // ESTR|0.0.0.0|-1
  let r164 : String = @typex.ipv4_end_ip_str("0.0.0.0", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r164, "ERR:BadMaskBit") // ESTR|0.0.0.0|0
  let r165 : String = @typex.ipv4_end_ip_str("0.0.0.0", 1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r165, "127.255.255.255") // ESTR|0.0.0.0|1
  let r166 : String = @typex.ipv4_end_ip_str("0.0.0.0", 8).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r166, "0.255.255.255") // ESTR|0.0.0.0|8
  let r167 : String = @typex.ipv4_end_ip_str("0.0.0.0", 16).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r167, "0.0.255.255") // ESTR|0.0.0.0|16
  let r168 : String = @typex.ipv4_end_ip_str("0.0.0.0", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r168, "0.0.0.255") // ESTR|0.0.0.0|24
  let r169 : String = @typex.ipv4_end_ip_str("0.0.0.0", 30).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r169, "0.0.0.3") // ESTR|0.0.0.0|30
  let r170 : String = @typex.ipv4_end_ip_str("0.0.0.0", 31).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r170, "0.0.0.1") // ESTR|0.0.0.0|31
  let r171 : String = @typex.ipv4_end_ip_str("0.0.0.0", 32).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r171, "0.0.0.0") // ESTR|0.0.0.0|32
  let r172 : String = @typex.ipv4_end_ip_str("0.0.0.0", 33).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r172, "ERR:BadMaskBit") // ESTR|0.0.0.0|33
  let r173 : String = @typex.ipv4_end_ip_str("0.0.0.0", 64).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r173, "ERR:BadMaskBit") // ESTR|0.0.0.0|64
  let r174 : String = @typex.ipv4_end_ip_str("256.1.1.1", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r174, "ERR:BadIp") // ESTR|256.1.1.1|24
  let r175 : String = @typex.ipv4_end_ip_str("256.1.1.1", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r175, "ERR:BadIp") // ESTR|256.1.1.1|0

  let r176 : String = @typex.ipv4_end_ip_long("218.240.38.69", -2).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r176, "ERR:BadMaskBit") // ELNG|218.240.38.69|-2
  let r177 : String = @typex.ipv4_end_ip_long("218.240.38.69", -1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r177, "ERR:BadMaskBit") // ELNG|218.240.38.69|-1
  let r178 : String = @typex.ipv4_end_ip_long("218.240.38.69", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r178, "ERR:BadMaskBit") // ELNG|218.240.38.69|0
  let r179 : String = @typex.ipv4_end_ip_long("218.240.38.69", 1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r179, "4294967295") // ELNG|218.240.38.69|1
  let r180 : String = @typex.ipv4_end_ip_long("218.240.38.69", 8).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r180, "3674210303") // ELNG|218.240.38.69|8
  let r181 : String = @typex.ipv4_end_ip_long("218.240.38.69", 16).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r181, "3673227263") // ELNG|218.240.38.69|16
  let r182 : String = @typex.ipv4_end_ip_long("218.240.38.69", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r182, "3673171711") // ELNG|218.240.38.69|24
  let r183 : String = @typex.ipv4_end_ip_long("218.240.38.69", 30).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r183, "3673171527") // ELNG|218.240.38.69|30
  let r184 : String = @typex.ipv4_end_ip_long("218.240.38.69", 31).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r184, "3673171525") // ELNG|218.240.38.69|31
  let r185 : String = @typex.ipv4_end_ip_long("218.240.38.69", 32).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r185, "3673171525") // ELNG|218.240.38.69|32
  let r186 : String = @typex.ipv4_end_ip_long("218.240.38.69", 33).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r186, "ERR:BadMaskBit") // ELNG|218.240.38.69|33
  let r187 : String = @typex.ipv4_end_ip_long("218.240.38.69", 64).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r187, "ERR:BadMaskBit") // ELNG|218.240.38.69|64
  let r188 : String = @typex.ipv4_end_ip_long("192.168.1.1", -2).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r188, "ERR:BadMaskBit") // ELNG|192.168.1.1|-2
  let r189 : String = @typex.ipv4_end_ip_long("192.168.1.1", -1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r189, "ERR:BadMaskBit") // ELNG|192.168.1.1|-1
  let r190 : String = @typex.ipv4_end_ip_long("192.168.1.1", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r190, "ERR:BadMaskBit") // ELNG|192.168.1.1|0
  let r191 : String = @typex.ipv4_end_ip_long("192.168.1.1", 1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r191, "4294967295") // ELNG|192.168.1.1|1
  let r192 : String = @typex.ipv4_end_ip_long("192.168.1.1", 8).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r192, "3238002687") // ELNG|192.168.1.1|8
  let r193 : String = @typex.ipv4_end_ip_long("192.168.1.1", 16).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r193, "3232301055") // ELNG|192.168.1.1|16
  let r194 : String = @typex.ipv4_end_ip_long("192.168.1.1", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r194, "3232236031") // ELNG|192.168.1.1|24
  let r195 : String = @typex.ipv4_end_ip_long("192.168.1.1", 30).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r195, "3232235779") // ELNG|192.168.1.1|30
  let r196 : String = @typex.ipv4_end_ip_long("192.168.1.1", 31).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r196, "3232235777") // ELNG|192.168.1.1|31
  let r197 : String = @typex.ipv4_end_ip_long("192.168.1.1", 32).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r197, "3232235777") // ELNG|192.168.1.1|32
  let r198 : String = @typex.ipv4_end_ip_long("192.168.1.1", 33).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r198, "ERR:BadMaskBit") // ELNG|192.168.1.1|33
  let r199 : String = @typex.ipv4_end_ip_long("192.168.1.1", 64).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r199, "ERR:BadMaskBit") // ELNG|192.168.1.1|64
  let r200 : String = @typex.ipv4_end_ip_long("0.0.0.0", -2).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r200, "ERR:BadMaskBit") // ELNG|0.0.0.0|-2
  let r201 : String = @typex.ipv4_end_ip_long("0.0.0.0", -1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r201, "ERR:BadMaskBit") // ELNG|0.0.0.0|-1
  let r202 : String = @typex.ipv4_end_ip_long("0.0.0.0", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r202, "ERR:BadMaskBit") // ELNG|0.0.0.0|0
  let r203 : String = @typex.ipv4_end_ip_long("0.0.0.0", 1).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r203, "2147483647") // ELNG|0.0.0.0|1
  let r204 : String = @typex.ipv4_end_ip_long("0.0.0.0", 8).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r204, "16777215") // ELNG|0.0.0.0|8
  let r205 : String = @typex.ipv4_end_ip_long("0.0.0.0", 16).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r205, "65535") // ELNG|0.0.0.0|16
  let r206 : String = @typex.ipv4_end_ip_long("0.0.0.0", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r206, "255") // ELNG|0.0.0.0|24
  let r207 : String = @typex.ipv4_end_ip_long("0.0.0.0", 30).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r207, "3") // ELNG|0.0.0.0|30
  let r208 : String = @typex.ipv4_end_ip_long("0.0.0.0", 31).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r208, "1") // ELNG|0.0.0.0|31
  let r209 : String = @typex.ipv4_end_ip_long("0.0.0.0", 32).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r209, "0") // ELNG|0.0.0.0|32
  let r210 : String = @typex.ipv4_end_ip_long("0.0.0.0", 33).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r210, "ERR:BadMaskBit") // ELNG|0.0.0.0|33
  let r211 : String = @typex.ipv4_end_ip_long("0.0.0.0", 64).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r211, "ERR:BadMaskBit") // ELNG|0.0.0.0|64
  let r212 : String = @typex.ipv4_end_ip_long("256.1.1.1", 24).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r212, "ERR:BadIp") // ELNG|256.1.1.1|24
  let r213 : String = @typex.ipv4_end_ip_long("256.1.1.1", 0).to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r213, "ERR:BadIp") // ELNG|256.1.1.1|0
}

///|
test "Ipv4 \u{7b2c}\u{4e8c}\u{6279}\u{63a9}\u{7801}\u{4f4d}\u{4e0e}\u{63a9}\u{7801}\u{4e32}\u{53cc}\u{5411}\u{5168}\u{8868}\u{ff08}0 \u{4e0d}\u{5728}\u{53c2}\u{7167}\u{8868}\u{5185}\u{ff09}" {
  let r214 : String = @typex.mask_bit_by_mask("128.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r214, "1") // MBM|128.0.0.0
  let r215 : String = @typex.mask_bit_by_mask("192.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r215, "2") // MBM|192.0.0.0
  let r216 : String = @typex.mask_bit_by_mask("224.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r216, "3") // MBM|224.0.0.0
  let r217 : String = @typex.mask_bit_by_mask("240.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r217, "4") // MBM|240.0.0.0
  let r218 : String = @typex.mask_bit_by_mask("248.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r218, "5") // MBM|248.0.0.0
  let r219 : String = @typex.mask_bit_by_mask("252.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r219, "6") // MBM|252.0.0.0
  let r220 : String = @typex.mask_bit_by_mask("254.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r220, "7") // MBM|254.0.0.0
  let r221 : String = @typex.mask_bit_by_mask("255.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r221, "8") // MBM|255.0.0.0
  let r222 : String = @typex.mask_bit_by_mask("255.128.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r222, "9") // MBM|255.128.0.0
  let r223 : String = @typex.mask_bit_by_mask("255.192.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r223, "10") // MBM|255.192.0.0
  let r224 : String = @typex.mask_bit_by_mask("255.224.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r224, "11") // MBM|255.224.0.0
  let r225 : String = @typex.mask_bit_by_mask("255.240.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r225, "12") // MBM|255.240.0.0
  let r226 : String = @typex.mask_bit_by_mask("255.248.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r226, "13") // MBM|255.248.0.0
  let r227 : String = @typex.mask_bit_by_mask("255.252.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r227, "14") // MBM|255.252.0.0
  let r228 : String = @typex.mask_bit_by_mask("255.254.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r228, "15") // MBM|255.254.0.0
  let r229 : String = @typex.mask_bit_by_mask("255.255.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r229, "16") // MBM|255.255.0.0
  let r230 : String = @typex.mask_bit_by_mask("255.255.128.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r230, "17") // MBM|255.255.128.0
  let r231 : String = @typex.mask_bit_by_mask("255.255.192.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r231, "18") // MBM|255.255.192.0
  let r232 : String = @typex.mask_bit_by_mask("255.255.224.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r232, "19") // MBM|255.255.224.0
  let r233 : String = @typex.mask_bit_by_mask("255.255.240.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r233, "20") // MBM|255.255.240.0
  let r234 : String = @typex.mask_bit_by_mask("255.255.248.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r234, "21") // MBM|255.255.248.0
  let r235 : String = @typex.mask_bit_by_mask("255.255.252.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r235, "22") // MBM|255.255.252.0
  let r236 : String = @typex.mask_bit_by_mask("255.255.254.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r236, "23") // MBM|255.255.254.0
  let r237 : String = @typex.mask_bit_by_mask("255.255.255.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r237, "24") // MBM|255.255.255.0
  let r238 : String = @typex.mask_bit_by_mask("255.255.255.128").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r238, "25") // MBM|255.255.255.128
  let r239 : String = @typex.mask_bit_by_mask("255.255.255.192").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r239, "26") // MBM|255.255.255.192
  let r240 : String = @typex.mask_bit_by_mask("255.255.255.224").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r240, "27") // MBM|255.255.255.224
  let r241 : String = @typex.mask_bit_by_mask("255.255.255.240").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r241, "28") // MBM|255.255.255.240
  let r242 : String = @typex.mask_bit_by_mask("255.255.255.248").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r242, "29") // MBM|255.255.255.248
  let r243 : String = @typex.mask_bit_by_mask("255.255.255.252").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r243, "30") // MBM|255.255.255.252
  let r244 : String = @typex.mask_bit_by_mask("255.255.255.254").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r244, "31") // MBM|255.255.255.254
  let r245 : String = @typex.mask_bit_by_mask("255.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r245, "32") // MBM|255.255.255.255
  let r246 : String = @typex.mask_bit_by_mask("0.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r246, "ERR:BadMask") // MBM|0.0.0.0
  let r247 : String = @typex.mask_bit_by_mask("255.0.255.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r247, "ERR:BadMask") // MBM|255.0.255.0
  let r248 : String = @typex.mask_bit_by_mask("255.255.255.256").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r248, "ERR:BadMask") // MBM|255.255.255.256
  let r249 : String = @typex.mask_bit_by_mask("abc").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r249, "ERR:BadMask") // MBM|abc
  let r250 : String = @typex.mask_bit_by_mask("").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r250, "ERR:BadMask") // MBM|
  let r251 : String = @typex.mask_bit_by_mask("1.2.3.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r251, "ERR:BadMask") // MBM|1.2.3.4
  let r252 : String = @typex.mask_bit_by_mask("255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r252, "ERR:BadMask") // MBM|255.255.255
  let r253 : String = @typex.mask_bit_by_mask("255.255.255.255.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r253, "ERR:BadMask") // MBM|255.255.255.255.0

  assert_eq(@typex.mask_by_mask_bit(-2), None) // MBMB|-2
  assert_eq(@typex.mask_by_mask_bit(-1), None) // MBMB|-1
  assert_eq(@typex.mask_by_mask_bit(0), None) // MBMB|0
  assert_eq(@typex.mask_by_mask_bit(1), Some("128.0.0.0")) // MBMB|1
  assert_eq(@typex.mask_by_mask_bit(8), Some("255.0.0.0")) // MBMB|8
  assert_eq(@typex.mask_by_mask_bit(16), Some("255.255.0.0")) // MBMB|16
  assert_eq(@typex.mask_by_mask_bit(24), Some("255.255.255.0")) // MBMB|24
  assert_eq(@typex.mask_by_mask_bit(30), Some("255.255.255.252")) // MBMB|30
  assert_eq(@typex.mask_by_mask_bit(31), Some("255.255.255.254")) // MBMB|31
  assert_eq(@typex.mask_by_mask_bit(32), Some("255.255.255.255")) // MBMB|32
  assert_eq(@typex.mask_by_mask_bit(33), None) // MBMB|33
  assert_eq(@typex.mask_by_mask_bit(64), None) // MBMB|64

  assert_eq(@typex.mask_is_valid("128.0.0.0"), true) // IMV|128.0.0.0
  assert_eq(@typex.mask_is_valid("192.0.0.0"), true) // IMV|192.0.0.0
  assert_eq(@typex.mask_is_valid("224.0.0.0"), true) // IMV|224.0.0.0
  assert_eq(@typex.mask_is_valid("240.0.0.0"), true) // IMV|240.0.0.0
  assert_eq(@typex.mask_is_valid("248.0.0.0"), true) // IMV|248.0.0.0
  assert_eq(@typex.mask_is_valid("252.0.0.0"), true) // IMV|252.0.0.0
  assert_eq(@typex.mask_is_valid("254.0.0.0"), true) // IMV|254.0.0.0
  assert_eq(@typex.mask_is_valid("255.0.0.0"), true) // IMV|255.0.0.0
  assert_eq(@typex.mask_is_valid("255.128.0.0"), true) // IMV|255.128.0.0
  assert_eq(@typex.mask_is_valid("255.192.0.0"), true) // IMV|255.192.0.0
  assert_eq(@typex.mask_is_valid("255.224.0.0"), true) // IMV|255.224.0.0
  assert_eq(@typex.mask_is_valid("255.240.0.0"), true) // IMV|255.240.0.0
  assert_eq(@typex.mask_is_valid("255.248.0.0"), true) // IMV|255.248.0.0
  assert_eq(@typex.mask_is_valid("255.252.0.0"), true) // IMV|255.252.0.0
  assert_eq(@typex.mask_is_valid("255.254.0.0"), true) // IMV|255.254.0.0
  assert_eq(@typex.mask_is_valid("255.255.0.0"), true) // IMV|255.255.0.0
  assert_eq(@typex.mask_is_valid("255.255.128.0"), true) // IMV|255.255.128.0
  assert_eq(@typex.mask_is_valid("255.255.192.0"), true) // IMV|255.255.192.0
  assert_eq(@typex.mask_is_valid("255.255.224.0"), true) // IMV|255.255.224.0
  assert_eq(@typex.mask_is_valid("255.255.240.0"), true) // IMV|255.255.240.0
  assert_eq(@typex.mask_is_valid("255.255.248.0"), true) // IMV|255.255.248.0
  assert_eq(@typex.mask_is_valid("255.255.252.0"), true) // IMV|255.255.252.0
  assert_eq(@typex.mask_is_valid("255.255.254.0"), true) // IMV|255.255.254.0
  assert_eq(@typex.mask_is_valid("255.255.255.0"), true) // IMV|255.255.255.0
  assert_eq(@typex.mask_is_valid("255.255.255.128"), true) // IMV|255.255.255.128
  assert_eq(@typex.mask_is_valid("255.255.255.192"), true) // IMV|255.255.255.192
  assert_eq(@typex.mask_is_valid("255.255.255.224"), true) // IMV|255.255.255.224
  assert_eq(@typex.mask_is_valid("255.255.255.240"), true) // IMV|255.255.255.240
  assert_eq(@typex.mask_is_valid("255.255.255.248"), true) // IMV|255.255.255.248
  assert_eq(@typex.mask_is_valid("255.255.255.252"), true) // IMV|255.255.255.252
  assert_eq(@typex.mask_is_valid("255.255.255.254"), true) // IMV|255.255.255.254
  assert_eq(@typex.mask_is_valid("255.255.255.255"), true) // IMV|255.255.255.255
  assert_eq(@typex.mask_is_valid("0.0.0.0"), false) // IMV|0.0.0.0
  assert_eq(@typex.mask_is_valid("255.0.255.0"), false) // IMV|255.0.255.0
  assert_eq(@typex.mask_is_valid("255.255.255.256"), false) // IMV|255.255.255.256
  assert_eq(@typex.mask_is_valid("abc"), false) // IMV|abc
  assert_eq(@typex.mask_is_valid(""), false) // IMV|
  assert_eq(@typex.mask_is_valid("1.2.3.4"), false) // IMV|1.2.3.4
  assert_eq(@typex.mask_is_valid("255.255.255"), false) // IMV|255.255.255
  assert_eq(@typex.mask_is_valid("255.255.255.255.0"), false) // IMV|255.255.255.255.0

  assert_eq(@typex.mask_bit_is_valid(-2), false) // IMBV|-2
  assert_eq(@typex.mask_bit_is_valid(-1), false) // IMBV|-1
  assert_eq(@typex.mask_bit_is_valid(0), false) // IMBV|0
  assert_eq(@typex.mask_bit_is_valid(1), true) // IMBV|1
  assert_eq(@typex.mask_bit_is_valid(8), true) // IMBV|8
  assert_eq(@typex.mask_bit_is_valid(16), true) // IMBV|16
  assert_eq(@typex.mask_bit_is_valid(24), true) // IMBV|24
  assert_eq(@typex.mask_bit_is_valid(30), true) // IMBV|30
  assert_eq(@typex.mask_bit_is_valid(31), true) // IMBV|31
  assert_eq(@typex.mask_bit_is_valid(32), true) // IMBV|32
  assert_eq(@typex.mask_bit_is_valid(33), false) // IMBV|33
  assert_eq(@typex.mask_bit_is_valid(64), false) // IMBV|64
}

///|
test "Ipv4 \u{7b2c}\u{4e8c}\u{6279}\u{5b50}\u{7f51}\u{5927}\u{5c0f}\u{ff08}\u{53c2}\u{7167}\u{8d70} double\u{2192}int \u{9971}\u{548c}\u{7a84}\u{5316}\u{ff09}" {
  assert_eq(@typex.count_by_mask_bit(-2, true), 2147483647) // CBMB|-2|true
  assert_eq(@typex.count_by_mask_bit(-2, false), 0) // CBMB|-2|false
  assert_eq(@typex.count_by_mask_bit(-1, true), 2147483647) // CBMB|-1|true
  assert_eq(@typex.count_by_mask_bit(-1, false), 0) // CBMB|-1|false
  assert_eq(@typex.count_by_mask_bit(0, true), 2147483647) // CBMB|0|true
  assert_eq(@typex.count_by_mask_bit(0, false), 0) // CBMB|0|false
  assert_eq(@typex.count_by_mask_bit(1, true), 2147483647) // CBMB|1|true
  assert_eq(@typex.count_by_mask_bit(1, false), 2147483645) // CBMB|1|false
  assert_eq(@typex.count_by_mask_bit(8, true), 16777216) // CBMB|8|true
  assert_eq(@typex.count_by_mask_bit(8, false), 16777214) // CBMB|8|false
  assert_eq(@typex.count_by_mask_bit(16, true), 65536) // CBMB|16|true
  assert_eq(@typex.count_by_mask_bit(16, false), 65534) // CBMB|16|false
  assert_eq(@typex.count_by_mask_bit(24, true), 256) // CBMB|24|true
  assert_eq(@typex.count_by_mask_bit(24, false), 254) // CBMB|24|false
  assert_eq(@typex.count_by_mask_bit(30, true), 4) // CBMB|30|true
  assert_eq(@typex.count_by_mask_bit(30, false), 2) // CBMB|30|false
  assert_eq(@typex.count_by_mask_bit(31, true), 2) // CBMB|31|true
  assert_eq(@typex.count_by_mask_bit(31, false), 0) // CBMB|31|false
  assert_eq(@typex.count_by_mask_bit(32, true), 1) // CBMB|32|true
  assert_eq(@typex.count_by_mask_bit(32, false), 0) // CBMB|32|false
  assert_eq(@typex.count_by_mask_bit(33, true), 0) // CBMB|33|true
  assert_eq(@typex.count_by_mask_bit(33, false), 0) // CBMB|33|false
  assert_eq(@typex.count_by_mask_bit(64, true), 0) // CBMB|64|true
  assert_eq(@typex.count_by_mask_bit(64, false), 0) // CBMB|64|false
}

///|
test "Ipv4 \u{7b2c}\u{4e8c}\u{6279} IP \u{6bb5}\u{4e24}\u{4ef6}\u{ff08}\u{76f8}\u{7b49}\u{8fb9}\u{754c}\u{76f8}\u{53cd} + \u{5927}\u{6bb5}\u{9971}\u{548c}\u{ff09}" {
  let r342 : String = @typex.mask_by_ip_range("1.2.3.4", "1.2.3.10").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r342, "255.255.255.249") // MBIR|1.2.3.4|1.2.3.10
  let r343 : String = @typex.mask_by_ip_range("1.2.3.4", "1.2.3.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r343, "ERR:BadRange") // MBIR|1.2.3.4|1.2.3.4
  let r344 : String = @typex.mask_by_ip_range("1.2.3.10", "1.2.3.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r344, "ERR:BadRange") // MBIR|1.2.3.10|1.2.3.4
  let r345 : String = @typex.mask_by_ip_range("192.168.0.0", "192.168.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r345, "255.255.0.0") // MBIR|192.168.0.0|192.168.255.255
  let r346 : String = @typex.mask_by_ip_range("0.0.0.0", "255.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r346, "0.0.0.0") // MBIR|0.0.0.0|255.255.255.255
  let r347 : String = @typex.mask_by_ip_range("1.2.3.4", "255.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r347, "1.2.3.4") // MBIR|1.2.3.4|255.255.255.255
  let r348 : String = @typex.mask_by_ip_range("255.255.255.255", "0.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r348, "ERR:BadRange") // MBIR|255.255.255.255|0.0.0.0
  let r349 : String = @typex.mask_by_ip_range("10.0.0.1", "9.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r349, "ERR:BadRange") // MBIR|10.0.0.1|9.255.255.255
  let r350 : String = @typex.mask_by_ip_range("1.2.3.4", "bad").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r350, "ERR:BadIp") // MBIR|1.2.3.4|bad
  let r351 : String = @typex.mask_by_ip_range("1.2.3.010", "1.2.3.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r351, "ERR:BadRange") // MBIR|1.2.3.010|1.2.3.4
  let r352 : String = @typex.mask_by_ip_range("1.2.3.4", "1.2.4.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r352, "255.255.254.255") // MBIR|1.2.3.4|1.2.4.4
  let r353 : String = @typex.mask_by_ip_range("200.100.50.25", "200.100.50.25").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r353, "ERR:BadRange") // MBIR|200.100.50.25|200.100.50.25

  let r354 : String = @typex.count_by_ip_range("1.2.3.4", "1.2.3.10").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r354, "7") // CBIR|1.2.3.4|1.2.3.10
  let r355 : String = @typex.count_by_ip_range("1.2.3.4", "1.2.3.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r355, "1") // CBIR|1.2.3.4|1.2.3.4
  let r356 : String = @typex.count_by_ip_range("1.2.3.10", "1.2.3.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r356, "ERR:BadRange") // CBIR|1.2.3.10|1.2.3.4
  let r357 : String = @typex.count_by_ip_range("192.168.0.0", "192.168.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r357, "65536") // CBIR|192.168.0.0|192.168.255.255
  let r358 : String = @typex.count_by_ip_range("0.0.0.0", "255.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r358, "2147483647") // CBIR|0.0.0.0|255.255.255.255
  let r359 : String = @typex.count_by_ip_range("1.2.3.4", "255.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r359, "2147483647") // CBIR|1.2.3.4|255.255.255.255
  let r360 : String = @typex.count_by_ip_range("255.255.255.255", "0.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r360, "ERR:BadRange") // CBIR|255.255.255.255|0.0.0.0
  let r361 : String = @typex.count_by_ip_range("10.0.0.1", "9.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r361, "ERR:BadRange") // CBIR|10.0.0.1|9.255.255.255
  let r362 : String = @typex.count_by_ip_range("1.2.3.4", "bad").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r362, "ERR:BadIp") // CBIR|1.2.3.4|bad
  let r363 : String = @typex.count_by_ip_range("1.2.3.010", "1.2.3.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r363, "ERR:BadRange") // CBIR|1.2.3.010|1.2.3.4
  let r364 : String = @typex.count_by_ip_range("1.2.3.4", "1.2.4.4").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r364, "257") // CBIR|1.2.3.4|1.2.4.4
  let r365 : String = @typex.count_by_ip_range("200.100.50.25", "200.100.50.25").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r365, "1") // CBIR|200.100.50.25|200.100.50.25
}

///|
test "Ipv4 \u{7b2c}\u{4e8c}\u{6279}\u{5185}\u{7f51}\u{5224}\u{5b9a}\u{4e0e}\u{901a}\u{914d}\u{ff08}\u{6bb5}\u{5185}\u{4e32}\u{6bd4}\u{8f83}\u{3001}\u{661f}\u{53f7}\u{53ea}\u{5f53}\u{6574}\u{6bb5}\u{ff09}" {
  let r366 : String = @typex.ipv4_is_inner("10.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r366, "true") // IIIP|10.0.0.0
  let r367 : String = @typex.ipv4_is_inner("10.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r367, "true") // IIIP|10.255.255.255
  let r368 : String = @typex.ipv4_is_inner("10.255.255.254").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r368, "true") // IIIP|10.255.255.254
  let r369 : String = @typex.ipv4_is_inner("11.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r369, "false") // IIIP|11.0.0.0
  let r370 : String = @typex.ipv4_is_inner("9.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r370, "false") // IIIP|9.255.255.255
  let r371 : String = @typex.ipv4_is_inner("172.16.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r371, "true") // IIIP|172.16.0.0
  let r372 : String = @typex.ipv4_is_inner("172.31.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r372, "true") // IIIP|172.31.255.255
  let r373 : String = @typex.ipv4_is_inner("172.15.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r373, "false") // IIIP|172.15.255.255
  let r374 : String = @typex.ipv4_is_inner("172.32.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r374, "false") // IIIP|172.32.0.0
  let r375 : String = @typex.ipv4_is_inner("192.168.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r375, "true") // IIIP|192.168.0.0
  let r376 : String = @typex.ipv4_is_inner("192.168.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r376, "true") // IIIP|192.168.255.255
  let r377 : String = @typex.ipv4_is_inner("192.169.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r377, "false") // IIIP|192.169.0.0
  let r378 : String = @typex.ipv4_is_inner("127.0.0.1").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r378, "true") // IIIP|127.0.0.1
  let r379 : String = @typex.ipv4_is_inner("127.0.0.2").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r379, "false") // IIIP|127.0.0.2
  let r380 : String = @typex.ipv4_is_inner("127.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r380, "false") // IIIP|127.255.255.255
  let r381 : String = @typex.ipv4_is_inner("8.8.8.8").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r381, "false") // IIIP|8.8.8.8
  let r382 : String = @typex.ipv4_is_inner("0.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r382, "false") // IIIP|0.0.0.0
  let r383 : String = @typex.ipv4_is_inner("255.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r383, "false") // IIIP|255.255.255.255
  let r384 : String = @typex.ipv4_is_inner("256.1.1.1").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r384, "ERR:BadIp") // IIIP|256.1.1.1
  let r385 : String = @typex.ipv4_is_inner("1.2.3").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r385, "ERR:BadIp") // IIIP|1.2.3

  assert_eq(@typex.ipv4_matches("192.168.*.1", "192.168.3.1"), true) // MAT|192.168.*.1|192.168.3.1
  assert_eq(@typex.ipv4_matches("*.*.*.*", "1.2.3.4"), true) // MAT|*.*.*.*|1.2.3.4
  assert_eq(@typex.ipv4_matches("192.168.*.1", "192.168.3.2"), false) // MAT|192.168.*.1|192.168.3.2
  assert_eq(@typex.ipv4_matches("192.168.*", "192.168.3.1"), false) // MAT|192.168.*|192.168.3.1
  assert_eq(@typex.ipv4_matches("192.168.*.1", "192.168.03.1"), true) // MAT|192.168.*.1|192.168.03.1
  assert_eq(@typex.ipv4_matches("192.168.*.1", "bad"), false) // MAT|192.168.*.1|bad
  assert_eq(@typex.ipv4_matches("1.*.*.*", "255.1.1.1"), false) // MAT|1.*.*.*|255.1.1.1
  assert_eq(@typex.ipv4_matches("1.2.3.4", "1.2.3.4"), true) // MAT|1.2.3.4|1.2.3.4
  assert_eq(@typex.ipv4_matches("**.*.*.*", "1.2.3.4"), false) // MAT|**.*.*.*|1.2.3.4
  assert_eq(@typex.ipv4_matches("192.168.*.*", "192.168.9.9"), true) // MAT|192.168.*.*|192.168.9.9
  assert_eq(@typex.ipv4_matches("0.*.*.*", "1.0.0.0"), false) // MAT|0.*.*.*|1.0.0.0
  assert_eq(@typex.ipv4_matches("192.168.*.1", "1.2.3.4.5"), false) // MAT|192.168.*.1|1.2.3.4.5
  assert_eq(@typex.ipv4_matches("192.168.3.1", "192.168.03.1"), false) // MAT|192.168.3.1|192.168.03.1
  assert_eq(@typex.ipv4_matches("1.2.3.4", "01.2.3.4"), false) // MAT|1.2.3.4|01.2.3.4
  assert_eq(@typex.ipv4_matches("1.2.3.04", "1.2.3.4"), false) // MAT|1.2.3.04|1.2.3.4
  assert_eq(@typex.ipv4_matches("*1.2.3.4", "1.2.3.4"), false) // MAT|*1.2.3.4|1.2.3.4
  assert_eq(@typex.ipv4_matches("1.2.3.*", "1.2.3.4"), true) // MAT|1.2.3.*|1.2.3.4
  assert_eq(@typex.ipv4_matches("1.*.*.4", "1.0.0.4"), true) // MAT|1.*.*.4|1.0.0.4
  assert_eq(@typex.ipv4_matches("01.2.3.4", "1.2.3.4"), false) // MAT|01.2.3.4|1.2.3.4
}

///|
test "Ipv4 \u{7b2c}\u{4e8c}\u{6279} format_ip_block \u{4e0d}\u{6821}\u{9a8c} IP \u{53ea}\u{6821}\u{9a8c}\u{63a9}\u{7801}" {
  let r405 : String = @typex.ipv4_format_block("1.2.3.4", "255.255.255.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r405, "1.2.3.4/24") // FIB|1.2.3.4|255.255.255.0
  let r406 : String = @typex.ipv4_format_block("10.0.0.5", "255.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r406, "10.0.0.5/8") // FIB|10.0.0.5|255.0.0.0
  let r407 : String = @typex.ipv4_format_block("1.2.3.4", "255.0.255.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r407, "ERR:BadMask") // FIB|1.2.3.4|255.0.255.0
  let r408 : String = @typex.ipv4_format_block("bad ip", "255.255.255.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r408, "bad ip/24") // FIB|bad ip|255.255.255.0
  let r409 : String = @typex.ipv4_format_block("256.1.1.1", "255.255.255.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r409, "256.1.1.1/24") // FIB|256.1.1.1|255.255.255.0
  let r410 : String = @typex.ipv4_format_block("1.2.3.4", "0.0.0.0").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r410, "ERR:BadMask") // FIB|1.2.3.4|0.0.0.0
  let r411 : String = @typex.ipv4_format_block("1.2.3.04", "255.255.255.255").to_string() catch {
    e => "ERR:" + itag(e)
  }
  assert_eq(r411, "1.2.3.04/32") // FIB|1.2.3.04|255.255.255.255
}
