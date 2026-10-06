///|
// typex 第三批 B（CreditCodeUtil）的期望值全部由生成脚本从参照腿灌入（手打零条）。
// 腿：真 hutool-core-5.8.35.jar + JDK 17.0.14，`javac -encoding UTF-8`；码表与权重由反射读 `PatternPool.CREDIT_CODE`/`WEIGHT`/`BASE_CODE_ARRAY`。
// 有效码不是本腿算的：对 17 位前缀在参照码表上穷举第 18 位、取参照判 true 的那枚（命中枚数一并留档）。

///|
test "CreditCode \u{5f62}\u{72b6}\u{6863}\u{ff1a}\u{5148}\u{8fc7} 18 \u{4f4d}\u{6b63}\u{5219}\u{4e14}\u{975e}\u{7a7a}\u{767d}" {
  assert_eq(@typex.typex_credit_code_is_simple(""), false) // SIMPLE|
  assert_eq(@typex.typex_credit_code_is_simple(" "), false) // SIMPLE| 
  assert_eq(@typex.typex_credit_code_is_simple("\t"), false) // SIMPLE|	
  assert_eq(@typex.typex_credit_code_is_simple("  "), false) // SIMPLE|  
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01RRR9X"), false) // SIMPLE|91110000MA01RRR9X
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01RRR9X4X"), false) // SIMPLE|91110000MA01RRR9X4X
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01RRR9X4"), true) // SIMPLE|91110000MA01RRR9X4
  assert_eq(@typex.typex_credit_code_is_simple("91110000ma01rrr9x4"), false) // SIMPLE|91110000ma01rrr9x4
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01RRI9X4"), false) // SIMPLE|91110000MA01RRI9X4
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01RRS9X4"), false) // SIMPLE|91110000MA01RRS9X4
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01RRT9X4"), true) // SIMPLE|91110000MA01RRT9X4
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01RRV9X4"), false) // SIMPLE|91110000MA01RRV9X4
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01RRZ9X4"), false) // SIMPLE|91110000MA01RRZ9X4
  assert_eq(@typex.typex_credit_code_is_simple("91110000000000000X"), true) // SIMPLE|91110000000000000X
  assert_eq(@typex.typex_credit_code_is_simple("911100000000000000"), true) // SIMPLE|911100000000000000
  assert_eq(@typex.typex_credit_code_is_simple("91110000000000000A"), true) // SIMPLE|91110000000000000A
  assert_eq(@typex.typex_credit_code_is_simple("ABCDEFGHJKLMNPQRTUWXY0"), false) // SIMPLE|ABCDEFGHJKLMNPQRTUWXY0
  assert_eq(
    @typex.typex_credit_code_is_simple("0123456789ABCDEFGHJKLMNPQRTUWXY"),
    false,
  ) // SIMPLE|0123456789ABCDEFGHJKLMNPQRTUWXY
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01R RR9X4"), false) // SIMPLE|91110000MA01R RR9X4
  assert_eq(
    @typex.typex_credit_code_is_simple("91110000MA01R\u{3000}RR9X4"),
    false,
  ) // SIMPLE|91110000MA01R　RR9X4
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01RRR9X4 "), false) // SIMPLE|91110000MA01RRR9X4 
  assert_eq(@typex.typex_credit_code_is_simple(" 91110000MA01RRR9X4"), false) // SIMPLE| 91110000MA01RRR9X4
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01RRR9X."), false) // SIMPLE|91110000MA01RRR9X.
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01RRR9X-"), false) // SIMPLE|91110000MA01RRR9X-
  assert_eq(@typex.typex_credit_code_is_simple("91ABCDEFGHMA01R007"), false) // SIMPLE|91ABCDEFGHMA01R007
  assert_eq(@typex.typex_credit_code_is_simple("91AB12CDDE01R00005"), false) // SIMPLE|91AB12CDDE01R00005
  assert_eq(@typex.typex_credit_code_is_simple("9133A100MA200R0009"), false) // SIMPLE|9133A100MA200R0009
  assert_eq(@typex.typex_credit_code_is_simple("Y1ABCDEFMA01R0000Y"), false) // SIMPLE|Y1ABCDEFMA01R0000Y
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01R0000MM"), false) // SIMPLE|91110000MA01R0000MM
  assert_eq(@typex.typex_credit_code_is_simple("91110000ma01r0000m"), false) // SIMPLE|91110000ma01r0000m
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01R0000."), false) // SIMPLE|91110000MA01R0000.
  assert_eq(@typex.typex_credit_code_is_simple("12345678901234567X"), true) // SIMPLE|12345678901234567X
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01R0000M"), true) // SIMPLE|91110000MA01R0000M
  assert_eq(@typex.typex_credit_code_is_simple("91310000MA1K000006"), true) // SIMPLE|91310000MA1K000006
  assert_eq(@typex.typex_credit_code_is_simple("92440101MA5000000H"), true) // SIMPLE|92440101MA5000000H
  assert_eq(@typex.typex_credit_code_is_simple("935101000000000008"), true) // SIMPLE|935101000000000008
  assert_eq(@typex.typex_credit_code_is_simple("Y1110000MA01R00000"), true) // SIMPLE|Y1110000MA01R00000
  assert_eq(@typex.typex_credit_code_is_simple("91330100MA2000000Q"), true) // SIMPLE|91330100MA2000000Q
  assert_eq(@typex.typex_credit_code_is_simple("92320506MA1000000N"), true) // SIMPLE|92320506MA1000000N
  assert_eq(@typex.typex_credit_code_is_simple("91650102MA5000000L"), true) // SIMPLE|91650102MA5000000L
  assert_eq(@typex.typex_credit_code_is_simple("91230103MA10000007"), true) // SIMPLE|91230103MA10000007
  assert_eq(@typex.typex_credit_code_is_simple("91500000MA6000000D"), true) // SIMPLE|91500000MA6000000D
  assert_eq(@typex.typex_credit_code_is_simple("A1110000MA01R0000M"), true) // SIMPLE|A1110000MA01R0000M
  assert_eq(@typex.typex_credit_code_is_simple("92110000MA01R0000M"), true) // SIMPLE|92110000MA01R0000M
  assert_eq(@typex.typex_credit_code_is_simple("91210000MA01R0000M"), true) // SIMPLE|91210000MA01R0000M
  assert_eq(@typex.typex_credit_code_is_simple("91120000MA01R0000M"), true) // SIMPLE|91120000MA01R0000M
  assert_eq(@typex.typex_credit_code_is_simple("91111000MA01R0000M"), true) // SIMPLE|91111000MA01R0000M
  assert_eq(@typex.typex_credit_code_is_simple("91110100MA01R0000M"), true) // SIMPLE|91110100MA01R0000M
  assert_eq(@typex.typex_credit_code_is_simple("91110010MA01R0000M"), true) // SIMPLE|91110010MA01R0000M
  assert_eq(@typex.typex_credit_code_is_simple("91110001MA01R0000M"), true) // SIMPLE|91110001MA01R0000M
  assert_eq(@typex.typex_credit_code_is_simple("91110000NA01R0000M"), true) // SIMPLE|91110000NA01R0000M
  assert_eq(@typex.typex_credit_code_is_simple("91110000MB01R0000M"), true) // SIMPLE|91110000MB01R0000M
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA11R0000M"), true) // SIMPLE|91110000MA11R0000M
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA02R0000M"), true) // SIMPLE|91110000MA02R0000M
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01T0000M"), true) // SIMPLE|91110000MA01T0000M
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01R1000M"), true) // SIMPLE|91110000MA01R1000M
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01R0100M"), true) // SIMPLE|91110000MA01R0100M
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01R0010M"), true) // SIMPLE|91110000MA01R0010M
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01R0001M"), true) // SIMPLE|91110000MA01R0001M
  assert_eq(@typex.typex_credit_code_is_simple("91110000MA01R0000N"), true) // SIMPLE|91110000MA01R0000N
  assert_eq(@typex.typex_credit_code_is_simple("A1310000MA1K000006"), true) // SIMPLE|A1310000MA1K000006
  assert_eq(@typex.typex_credit_code_is_simple("92310000MA1K000006"), true) // SIMPLE|92310000MA1K000006
  assert_eq(@typex.typex_credit_code_is_simple("91410000MA1K000006"), true) // SIMPLE|91410000MA1K000006
  assert_eq(@typex.typex_credit_code_is_simple("91320000MA1K000006"), true) // SIMPLE|91320000MA1K000006
  assert_eq(@typex.typex_credit_code_is_simple("91311000MA1K000006"), true) // SIMPLE|91311000MA1K000006
  assert_eq(@typex.typex_credit_code_is_simple("91310100MA1K000006"), true) // SIMPLE|91310100MA1K000006
  assert_eq(@typex.typex_credit_code_is_simple("91310010MA1K000006"), true) // SIMPLE|91310010MA1K000006
  assert_eq(@typex.typex_credit_code_is_simple("91310001MA1K000006"), true) // SIMPLE|91310001MA1K000006
  assert_eq(@typex.typex_credit_code_is_simple("91310000NA1K000006"), true) // SIMPLE|91310000NA1K000006
  assert_eq(@typex.typex_credit_code_is_simple("91310000MB1K000006"), true) // SIMPLE|91310000MB1K000006
  assert_eq(@typex.typex_credit_code_is_simple("91310000MA2K000006"), true) // SIMPLE|91310000MA2K000006
  assert_eq(@typex.typex_credit_code_is_simple("91310000MA1L000006"), true) // SIMPLE|91310000MA1L000006
  assert_eq(@typex.typex_credit_code_is_simple("91310000MA1K100006"), true) // SIMPLE|91310000MA1K100006
  assert_eq(@typex.typex_credit_code_is_simple("91310000MA1K010006"), true) // SIMPLE|91310000MA1K010006
  assert_eq(@typex.typex_credit_code_is_simple("91310000MA1K001006"), true) // SIMPLE|91310000MA1K001006
  assert_eq(@typex.typex_credit_code_is_simple("91310000MA1K000106"), true) // SIMPLE|91310000MA1K000106
  assert_eq(@typex.typex_credit_code_is_simple("91310000MA1K000016"), true) // SIMPLE|91310000MA1K000016
  assert_eq(@typex.typex_credit_code_is_simple("91310000MA1K000007"), true) // SIMPLE|91310000MA1K000007
  assert_eq(@typex.typex_credit_code_is_simple("A2440101MA5000000H"), true) // SIMPLE|A2440101MA5000000H
  assert_eq(@typex.typex_credit_code_is_simple("93440101MA5000000H"), true) // SIMPLE|93440101MA5000000H
  assert_eq(@typex.typex_credit_code_is_simple("92540101MA5000000H"), true) // SIMPLE|92540101MA5000000H
  assert_eq(@typex.typex_credit_code_is_simple("92450101MA5000000H"), true) // SIMPLE|92450101MA5000000H
  assert_eq(@typex.typex_credit_code_is_simple("92441101MA5000000H"), true) // SIMPLE|92441101MA5000000H
  assert_eq(@typex.typex_credit_code_is_simple("92440201MA5000000H"), true) // SIMPLE|92440201MA5000000H
  assert_eq(@typex.typex_credit_code_is_simple("92440111MA5000000H"), true) // SIMPLE|92440111MA5000000H
  assert_eq(@typex.typex_credit_code_is_simple("92440102MA5000000H"), true) // SIMPLE|92440102MA5000000H
  assert_eq(@typex.typex_credit_code_is_simple("92440101NA5000000H"), true) // SIMPLE|92440101NA5000000H
  assert_eq(@typex.typex_credit_code_is_simple("92440101MB5000000H"), true) // SIMPLE|92440101MB5000000H
  assert_eq(@typex.typex_credit_code_is_simple("92440101MA6000000H"), true) // SIMPLE|92440101MA6000000H
  assert_eq(@typex.typex_credit_code_is_simple("92440101MA5100000H"), true) // SIMPLE|92440101MA5100000H
  assert_eq(@typex.typex_credit_code_is_simple("92440101MA5010000H"), true) // SIMPLE|92440101MA5010000H
  assert_eq(@typex.typex_credit_code_is_simple("92440101MA5001000H"), true) // SIMPLE|92440101MA5001000H
  assert_eq(@typex.typex_credit_code_is_simple("92440101MA5000100H"), true) // SIMPLE|92440101MA5000100H
  assert_eq(@typex.typex_credit_code_is_simple("92440101MA5000010H"), true) // SIMPLE|92440101MA5000010H
  assert_eq(@typex.typex_credit_code_is_simple("92440101MA5000001H"), true) // SIMPLE|92440101MA5000001H
  assert_eq(@typex.typex_credit_code_is_simple("92440101MA5000000J"), true) // SIMPLE|92440101MA5000000J
  assert_eq(@typex.typex_credit_code_is_simple("A35101000000000008"), true) // SIMPLE|A35101000000000008
  assert_eq(@typex.typex_credit_code_is_simple("945101000000000008"), true) // SIMPLE|945101000000000008
  assert_eq(@typex.typex_credit_code_is_simple("936101000000000008"), true) // SIMPLE|936101000000000008
  assert_eq(@typex.typex_credit_code_is_simple("935201000000000008"), true) // SIMPLE|935201000000000008
  assert_eq(@typex.typex_credit_code_is_simple("935111000000000008"), true) // SIMPLE|935111000000000008
  assert_eq(@typex.typex_credit_code_is_simple("935102000000000008"), true) // SIMPLE|935102000000000008
  assert_eq(@typex.typex_credit_code_is_simple("935101100000000008"), true) // SIMPLE|935101100000000008
  assert_eq(@typex.typex_credit_code_is_simple("935101010000000008"), true) // SIMPLE|935101010000000008
  assert_eq(@typex.typex_credit_code_is_simple("935101001000000008"), true) // SIMPLE|935101001000000008
  assert_eq(@typex.typex_credit_code_is_simple("935101000100000008"), true) // SIMPLE|935101000100000008
  assert_eq(@typex.typex_credit_code_is_simple("935101000010000008"), true) // SIMPLE|935101000010000008
  assert_eq(@typex.typex_credit_code_is_simple("935101000001000008"), true) // SIMPLE|935101000001000008
  assert_eq(@typex.typex_credit_code_is_simple("935101000000100008"), true) // SIMPLE|935101000000100008
  assert_eq(@typex.typex_credit_code_is_simple("935101000000010008"), true) // SIMPLE|935101000000010008
  assert_eq(@typex.typex_credit_code_is_simple("935101000000001008"), true) // SIMPLE|935101000000001008
  assert_eq(@typex.typex_credit_code_is_simple("935101000000000108"), true) // SIMPLE|935101000000000108
  assert_eq(@typex.typex_credit_code_is_simple("935101000000000018"), true) // SIMPLE|935101000000000018
  assert_eq(@typex.typex_credit_code_is_simple("935101000000000009"), true) // SIMPLE|935101000000000009
}

///|
test "CreditCode \u{6821}\u{9a8c}\u{4f4d}\u{6863}\u{ff1a}mod-31 \u{52a0}\u{6743}\u{4e14}\u{5fc5}\u{987b}\u{5148}\u{8fc7}\u{5f62}\u{72b6}\u{95f8}" {
  assert_eq(@typex.typex_credit_code_is_valid(""), false) // VALID|
  assert_eq(@typex.typex_credit_code_is_valid(" "), false) // VALID| 
  assert_eq(@typex.typex_credit_code_is_valid("\t"), false) // VALID|	
  assert_eq(@typex.typex_credit_code_is_valid("  "), false) // VALID|  
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01RRR9X"), false) // VALID|91110000MA01RRR9X
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01RRR9X4X"), false) // VALID|91110000MA01RRR9X4X
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01RRR9X4"), false) // VALID|91110000MA01RRR9X4
  assert_eq(@typex.typex_credit_code_is_valid("91110000ma01rrr9x4"), false) // VALID|91110000ma01rrr9x4
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01RRI9X4"), false) // VALID|91110000MA01RRI9X4
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01RRS9X4"), false) // VALID|91110000MA01RRS9X4
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01RRT9X4"), false) // VALID|91110000MA01RRT9X4
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01RRV9X4"), false) // VALID|91110000MA01RRV9X4
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01RRZ9X4"), false) // VALID|91110000MA01RRZ9X4
  assert_eq(@typex.typex_credit_code_is_valid("91110000000000000X"), false) // VALID|91110000000000000X
  assert_eq(@typex.typex_credit_code_is_valid("911100000000000000"), false) // VALID|911100000000000000
  assert_eq(@typex.typex_credit_code_is_valid("91110000000000000A"), false) // VALID|91110000000000000A
  assert_eq(@typex.typex_credit_code_is_valid("ABCDEFGHJKLMNPQRTUWXY0"), false) // VALID|ABCDEFGHJKLMNPQRTUWXY0
  assert_eq(
    @typex.typex_credit_code_is_valid("0123456789ABCDEFGHJKLMNPQRTUWXY"),
    false,
  ) // VALID|0123456789ABCDEFGHJKLMNPQRTUWXY
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01R RR9X4"), false) // VALID|91110000MA01R RR9X4
  assert_eq(
    @typex.typex_credit_code_is_valid("91110000MA01R\u{3000}RR9X4"),
    false,
  ) // VALID|91110000MA01R　RR9X4
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01RRR9X4 "), false) // VALID|91110000MA01RRR9X4 
  assert_eq(@typex.typex_credit_code_is_valid(" 91110000MA01RRR9X4"), false) // VALID| 91110000MA01RRR9X4
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01RRR9X."), false) // VALID|91110000MA01RRR9X.
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01RRR9X-"), false) // VALID|91110000MA01RRR9X-
  assert_eq(@typex.typex_credit_code_is_valid("91ABCDEFGHMA01R007"), false) // VALID|91ABCDEFGHMA01R007
  assert_eq(@typex.typex_credit_code_is_valid("91AB12CDDE01R00005"), false) // VALID|91AB12CDDE01R00005
  assert_eq(@typex.typex_credit_code_is_valid("9133A100MA200R0009"), false) // VALID|9133A100MA200R0009
  assert_eq(@typex.typex_credit_code_is_valid("Y1ABCDEFMA01R0000Y"), false) // VALID|Y1ABCDEFMA01R0000Y
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01R0000MM"), false) // VALID|91110000MA01R0000MM
  assert_eq(@typex.typex_credit_code_is_valid("91110000ma01r0000m"), false) // VALID|91110000ma01r0000m
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01R0000."), false) // VALID|91110000MA01R0000.
  assert_eq(@typex.typex_credit_code_is_valid("12345678901234567X"), false) // VALID|12345678901234567X
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01R0000M"), true) // VALID|91110000MA01R0000M
  assert_eq(@typex.typex_credit_code_is_valid("91310000MA1K000006"), true) // VALID|91310000MA1K000006
  assert_eq(@typex.typex_credit_code_is_valid("92440101MA5000000H"), true) // VALID|92440101MA5000000H
  assert_eq(@typex.typex_credit_code_is_valid("935101000000000008"), true) // VALID|935101000000000008
  assert_eq(@typex.typex_credit_code_is_valid("Y1110000MA01R00000"), true) // VALID|Y1110000MA01R00000
  assert_eq(@typex.typex_credit_code_is_valid("91330100MA2000000Q"), true) // VALID|91330100MA2000000Q
  assert_eq(@typex.typex_credit_code_is_valid("92320506MA1000000N"), true) // VALID|92320506MA1000000N
  assert_eq(@typex.typex_credit_code_is_valid("91650102MA5000000L"), true) // VALID|91650102MA5000000L
  assert_eq(@typex.typex_credit_code_is_valid("91230103MA10000007"), true) // VALID|91230103MA10000007
  assert_eq(@typex.typex_credit_code_is_valid("91500000MA6000000D"), true) // VALID|91500000MA6000000D
  assert_eq(@typex.typex_credit_code_is_valid("A1110000MA01R0000M"), false) // VALID|A1110000MA01R0000M
  assert_eq(@typex.typex_credit_code_is_valid("92110000MA01R0000M"), false) // VALID|92110000MA01R0000M
  assert_eq(@typex.typex_credit_code_is_valid("91210000MA01R0000M"), false) // VALID|91210000MA01R0000M
  assert_eq(@typex.typex_credit_code_is_valid("91120000MA01R0000M"), false) // VALID|91120000MA01R0000M
  assert_eq(@typex.typex_credit_code_is_valid("91111000MA01R0000M"), false) // VALID|91111000MA01R0000M
  assert_eq(@typex.typex_credit_code_is_valid("91110100MA01R0000M"), false) // VALID|91110100MA01R0000M
  assert_eq(@typex.typex_credit_code_is_valid("91110010MA01R0000M"), false) // VALID|91110010MA01R0000M
  assert_eq(@typex.typex_credit_code_is_valid("91110001MA01R0000M"), false) // VALID|91110001MA01R0000M
  assert_eq(@typex.typex_credit_code_is_valid("91110000NA01R0000M"), false) // VALID|91110000NA01R0000M
  assert_eq(@typex.typex_credit_code_is_valid("91110000MB01R0000M"), false) // VALID|91110000MB01R0000M
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA11R0000M"), false) // VALID|91110000MA11R0000M
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA02R0000M"), false) // VALID|91110000MA02R0000M
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01T0000M"), false) // VALID|91110000MA01T0000M
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01R1000M"), false) // VALID|91110000MA01R1000M
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01R0100M"), false) // VALID|91110000MA01R0100M
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01R0010M"), false) // VALID|91110000MA01R0010M
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01R0001M"), false) // VALID|91110000MA01R0001M
  assert_eq(@typex.typex_credit_code_is_valid("91110000MA01R0000N"), false) // VALID|91110000MA01R0000N
  assert_eq(@typex.typex_credit_code_is_valid("A1310000MA1K000006"), false) // VALID|A1310000MA1K000006
  assert_eq(@typex.typex_credit_code_is_valid("92310000MA1K000006"), false) // VALID|92310000MA1K000006
  assert_eq(@typex.typex_credit_code_is_valid("91410000MA1K000006"), false) // VALID|91410000MA1K000006
  assert_eq(@typex.typex_credit_code_is_valid("91320000MA1K000006"), false) // VALID|91320000MA1K000006
  assert_eq(@typex.typex_credit_code_is_valid("91311000MA1K000006"), false) // VALID|91311000MA1K000006
  assert_eq(@typex.typex_credit_code_is_valid("91310100MA1K000006"), false) // VALID|91310100MA1K000006
  assert_eq(@typex.typex_credit_code_is_valid("91310010MA1K000006"), false) // VALID|91310010MA1K000006
  assert_eq(@typex.typex_credit_code_is_valid("91310001MA1K000006"), false) // VALID|91310001MA1K000006
  assert_eq(@typex.typex_credit_code_is_valid("91310000NA1K000006"), false) // VALID|91310000NA1K000006
  assert_eq(@typex.typex_credit_code_is_valid("91310000MB1K000006"), false) // VALID|91310000MB1K000006
  assert_eq(@typex.typex_credit_code_is_valid("91310000MA2K000006"), false) // VALID|91310000MA2K000006
  assert_eq(@typex.typex_credit_code_is_valid("91310000MA1L000006"), false) // VALID|91310000MA1L000006
  assert_eq(@typex.typex_credit_code_is_valid("91310000MA1K100006"), false) // VALID|91310000MA1K100006
  assert_eq(@typex.typex_credit_code_is_valid("91310000MA1K010006"), false) // VALID|91310000MA1K010006
  assert_eq(@typex.typex_credit_code_is_valid("91310000MA1K001006"), false) // VALID|91310000MA1K001006
  assert_eq(@typex.typex_credit_code_is_valid("91310000MA1K000106"), false) // VALID|91310000MA1K000106
  assert_eq(@typex.typex_credit_code_is_valid("91310000MA1K000016"), false) // VALID|91310000MA1K000016
  assert_eq(@typex.typex_credit_code_is_valid("91310000MA1K000007"), false) // VALID|91310000MA1K000007
  assert_eq(@typex.typex_credit_code_is_valid("A2440101MA5000000H"), false) // VALID|A2440101MA5000000H
  assert_eq(@typex.typex_credit_code_is_valid("93440101MA5000000H"), false) // VALID|93440101MA5000000H
  assert_eq(@typex.typex_credit_code_is_valid("92540101MA5000000H"), false) // VALID|92540101MA5000000H
  assert_eq(@typex.typex_credit_code_is_valid("92450101MA5000000H"), false) // VALID|92450101MA5000000H
  assert_eq(@typex.typex_credit_code_is_valid("92441101MA5000000H"), false) // VALID|92441101MA5000000H
  assert_eq(@typex.typex_credit_code_is_valid("92440201MA5000000H"), false) // VALID|92440201MA5000000H
  assert_eq(@typex.typex_credit_code_is_valid("92440111MA5000000H"), false) // VALID|92440111MA5000000H
  assert_eq(@typex.typex_credit_code_is_valid("92440102MA5000000H"), false) // VALID|92440102MA5000000H
  assert_eq(@typex.typex_credit_code_is_valid("92440101NA5000000H"), false) // VALID|92440101NA5000000H
  assert_eq(@typex.typex_credit_code_is_valid("92440101MB5000000H"), false) // VALID|92440101MB5000000H
  assert_eq(@typex.typex_credit_code_is_valid("92440101MA6000000H"), false) // VALID|92440101MA6000000H
  assert_eq(@typex.typex_credit_code_is_valid("92440101MA5100000H"), false) // VALID|92440101MA5100000H
  assert_eq(@typex.typex_credit_code_is_valid("92440101MA5010000H"), false) // VALID|92440101MA5010000H
  assert_eq(@typex.typex_credit_code_is_valid("92440101MA5001000H"), false) // VALID|92440101MA5001000H
  assert_eq(@typex.typex_credit_code_is_valid("92440101MA5000100H"), false) // VALID|92440101MA5000100H
  assert_eq(@typex.typex_credit_code_is_valid("92440101MA5000010H"), false) // VALID|92440101MA5000010H
  assert_eq(@typex.typex_credit_code_is_valid("92440101MA5000001H"), false) // VALID|92440101MA5000001H
  assert_eq(@typex.typex_credit_code_is_valid("92440101MA5000000J"), false) // VALID|92440101MA5000000J
  assert_eq(@typex.typex_credit_code_is_valid("A35101000000000008"), false) // VALID|A35101000000000008
  assert_eq(@typex.typex_credit_code_is_valid("945101000000000008"), false) // VALID|945101000000000008
  assert_eq(@typex.typex_credit_code_is_valid("936101000000000008"), false) // VALID|936101000000000008
  assert_eq(@typex.typex_credit_code_is_valid("935201000000000008"), false) // VALID|935201000000000008
  assert_eq(@typex.typex_credit_code_is_valid("935111000000000008"), false) // VALID|935111000000000008
  assert_eq(@typex.typex_credit_code_is_valid("935102000000000008"), false) // VALID|935102000000000008
  assert_eq(@typex.typex_credit_code_is_valid("935101100000000008"), false) // VALID|935101100000000008
  assert_eq(@typex.typex_credit_code_is_valid("935101010000000008"), false) // VALID|935101010000000008
  assert_eq(@typex.typex_credit_code_is_valid("935101001000000008"), false) // VALID|935101001000000008
  assert_eq(@typex.typex_credit_code_is_valid("935101000100000008"), false) // VALID|935101000100000008
  assert_eq(@typex.typex_credit_code_is_valid("935101000010000008"), false) // VALID|935101000010000008
  assert_eq(@typex.typex_credit_code_is_valid("935101000001000008"), false) // VALID|935101000001000008
  assert_eq(@typex.typex_credit_code_is_valid("935101000000100008"), false) // VALID|935101000000100008
  assert_eq(@typex.typex_credit_code_is_valid("935101000000010008"), false) // VALID|935101000000010008
  assert_eq(@typex.typex_credit_code_is_valid("935101000000001008"), false) // VALID|935101000000001008
  assert_eq(@typex.typex_credit_code_is_valid("935101000000000108"), false) // VALID|935101000000000108
  assert_eq(@typex.typex_credit_code_is_valid("935101000000000018"), false) // VALID|935101000000000018
  assert_eq(@typex.typex_credit_code_is_valid("935101000000000009"), false) // VALID|935101000000000009
}
