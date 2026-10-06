///|
// typex 第三批 F（DataSizeUtil.format 两族）的期望值全部由生成脚本从参照腿灌入（手打零条）。
// 腿：同批 E 的 Temp/convsrc/datasize/ds_rows.tsv 里 FMT 25 + FMT_AT_* 125 = 150 条现读（真 JDK 17）。
// 冻期望前跑过两族对撞：148 条上参照的 DecimalFormat（二进制族 HALF_EVEN）与本库复用的
// @num 舍入+分组+去尾零（最短十进制族）逐字节相同；只有单位 B 且 |size| >= 2^53 的两条例外——
// 参照在那两条给的是它内部位数截断的值，不可原则化 ⇒ 那两档不收（spec §18.1），本批零期望改写。

///|

///|
test "format(long)\u{ff1a}\u{9009}\u{6863}\u{9760} log10 \u{6bd4}\u{503c}\u{3001}\u{5370}\u{6570}\u{5e26}\u{5343}\u{5206}\u{4f4d}\u{3001}size<=0 \u{7ed9}\u{4e0d}\u{5e26}\u{5355}\u{4f4d}\u{7684} 0" {
  assert_eq(@typex.data_size_format(0L), "0") // FMT|0
  assert_eq(@typex.data_size_format(-1L), "0") // FMT|-1
  assert_eq(@typex.data_size_format(-1024L), "0") // FMT|-1024
  assert_eq(@typex.data_size_format(1L), "1 B") // FMT|1
  assert_eq(@typex.data_size_format(999L), "999 B") // FMT|999
  assert_eq(@typex.data_size_format(1000L), "1,000 B") // FMT|1000
  assert_eq(@typex.data_size_format(1023L), "1,023 B") // FMT|1023
  assert_eq(@typex.data_size_format(1024L), "1 KB") // FMT|1024
  assert_eq(@typex.data_size_format(1025L), "1 KB") // FMT|1025
  assert_eq(@typex.data_size_format(1536L), "1.5 KB") // FMT|1536
  assert_eq(@typex.data_size_format(1126L), "1.1 KB") // FMT|1126
  assert_eq(@typex.data_size_format(9999L), "9.76 KB") // FMT|9999
  assert_eq(@typex.data_size_format(10000L), "9.77 KB") // FMT|10000
  assert_eq(@typex.data_size_format(999999L), "976.56 KB") // FMT|999999
  assert_eq(@typex.data_size_format(1000000L), "976.56 KB") // FMT|1000000
  assert_eq(@typex.data_size_format(1048575L), "1,024 KB") // FMT|1048575
  assert_eq(@typex.data_size_format(1048576L), "1 MB") // FMT|1048576
  assert_eq(@typex.data_size_format(5243392L), "5 MB") // FMT|5243392
  assert_eq(@typex.data_size_format(1073741824L), "1 GB") // FMT|1073741824
  assert_eq(@typex.data_size_format(1073741823L), "1,024 MB") // FMT|1073741823
  assert_eq(@typex.data_size_format(1099511627776L), "1 TB") // FMT|1099511627776
  assert_eq(@typex.data_size_format(1125899906842624L), "1 PB") // FMT|1125899906842624
  assert_eq(@typex.data_size_format(1152921504606846976L), "1 EB") // FMT|1152921504606846976
  assert_eq(@typex.data_size_format(9223372036854775807L), "8 EB") // FMT|9223372036854775807
  assert_eq(@typex.data_size_format(-9223372036854775808L), "0") // FMT|-9223372036854775808
}

///|
test "format_at(long, \u{5355}\u{4f4d}\u{540e}\u{7f00})\u{ff1a}\u{6309}\u{8be5}\u{5355}\u{4f4d}\u{5b9a}\u{6863}\u{3001}\u{65e0}\u{5343}\u{5206}\u{4f4d}\u{ff08}B\u{ff09}" {
  assert_eq(@typex.data_size_format_at(0L, "B"), "0") // FMT_AT_BYTES|0
  assert_eq(@typex.data_size_format_at(-1L, "B"), "0") // FMT_AT_BYTES|-1
  assert_eq(@typex.data_size_format_at(-1024L, "B"), "0") // FMT_AT_BYTES|-1024
  assert_eq(@typex.data_size_format_at(1L, "B"), "1 B") // FMT_AT_BYTES|1
  assert_eq(@typex.data_size_format_at(999L, "B"), "999 B") // FMT_AT_BYTES|999
  assert_eq(@typex.data_size_format_at(1000L, "B"), "1000 B") // FMT_AT_BYTES|1000
  assert_eq(@typex.data_size_format_at(1023L, "B"), "1023 B") // FMT_AT_BYTES|1023
  assert_eq(@typex.data_size_format_at(1024L, "B"), "1024 B") // FMT_AT_BYTES|1024
  assert_eq(@typex.data_size_format_at(1025L, "B"), "1025 B") // FMT_AT_BYTES|1025
  assert_eq(@typex.data_size_format_at(1536L, "B"), "1536 B") // FMT_AT_BYTES|1536
  assert_eq(@typex.data_size_format_at(1126L, "B"), "1126 B") // FMT_AT_BYTES|1126
  assert_eq(@typex.data_size_format_at(9999L, "B"), "9999 B") // FMT_AT_BYTES|9999
  assert_eq(@typex.data_size_format_at(10000L, "B"), "10000 B") // FMT_AT_BYTES|10000
  assert_eq(@typex.data_size_format_at(999999L, "B"), "999999 B") // FMT_AT_BYTES|999999
  assert_eq(@typex.data_size_format_at(1000000L, "B"), "1000000 B") // FMT_AT_BYTES|1000000
  assert_eq(@typex.data_size_format_at(1048575L, "B"), "1048575 B") // FMT_AT_BYTES|1048575
  assert_eq(@typex.data_size_format_at(1048576L, "B"), "1048576 B") // FMT_AT_BYTES|1048576
  assert_eq(@typex.data_size_format_at(5243392L, "B"), "5243392 B") // FMT_AT_BYTES|5243392
  assert_eq(@typex.data_size_format_at(1073741824L, "B"), "1073741824 B") // FMT_AT_BYTES|1073741824
  assert_eq(@typex.data_size_format_at(1073741823L, "B"), "1073741823 B") // FMT_AT_BYTES|1073741823
  assert_eq(@typex.data_size_format_at(1099511627776L, "B"), "1099511627776 B") // FMT_AT_BYTES|1099511627776
  assert_eq(
    @typex.data_size_format_at(1125899906842624L, "B"),
    "1125899906842624 B",
  ) // FMT_AT_BYTES|1125899906842624
  assert_eq(@typex.data_size_format_at(-9223372036854775808L, "B"), "0") // FMT_AT_BYTES|-9223372036854775808
}

///|
test "format_at(long, \u{5355}\u{4f4d}\u{540e}\u{7f00})\u{ff1a}\u{6309}\u{8be5}\u{5355}\u{4f4d}\u{5b9a}\u{6863}\u{3001}\u{65e0}\u{5343}\u{5206}\u{4f4d}\u{ff08}GB\u{ff09}" {
  assert_eq(@typex.data_size_format_at(0L, "GB"), "0") // FMT_AT_GIGABYTES|0
  assert_eq(@typex.data_size_format_at(-1L, "GB"), "0") // FMT_AT_GIGABYTES|-1
  assert_eq(@typex.data_size_format_at(-1024L, "GB"), "0") // FMT_AT_GIGABYTES|-1024
  assert_eq(@typex.data_size_format_at(1L, "GB"), "0 GB") // FMT_AT_GIGABYTES|1
  assert_eq(@typex.data_size_format_at(999L, "GB"), "0 GB") // FMT_AT_GIGABYTES|999
  assert_eq(@typex.data_size_format_at(1000L, "GB"), "0 GB") // FMT_AT_GIGABYTES|1000
  assert_eq(@typex.data_size_format_at(1023L, "GB"), "0 GB") // FMT_AT_GIGABYTES|1023
  assert_eq(@typex.data_size_format_at(1024L, "GB"), "0 GB") // FMT_AT_GIGABYTES|1024
  assert_eq(@typex.data_size_format_at(1025L, "GB"), "0 GB") // FMT_AT_GIGABYTES|1025
  assert_eq(@typex.data_size_format_at(1536L, "GB"), "0 GB") // FMT_AT_GIGABYTES|1536
  assert_eq(@typex.data_size_format_at(1126L, "GB"), "0 GB") // FMT_AT_GIGABYTES|1126
  assert_eq(@typex.data_size_format_at(9999L, "GB"), "0 GB") // FMT_AT_GIGABYTES|9999
  assert_eq(@typex.data_size_format_at(10000L, "GB"), "0 GB") // FMT_AT_GIGABYTES|10000
  assert_eq(@typex.data_size_format_at(999999L, "GB"), "0 GB") // FMT_AT_GIGABYTES|999999
  assert_eq(@typex.data_size_format_at(1000000L, "GB"), "0 GB") // FMT_AT_GIGABYTES|1000000
  assert_eq(@typex.data_size_format_at(1048575L, "GB"), "0 GB") // FMT_AT_GIGABYTES|1048575
  assert_eq(@typex.data_size_format_at(1048576L, "GB"), "0 GB") // FMT_AT_GIGABYTES|1048576
  assert_eq(@typex.data_size_format_at(5243392L, "GB"), "0 GB") // FMT_AT_GIGABYTES|5243392
  assert_eq(@typex.data_size_format_at(1073741824L, "GB"), "1 GB") // FMT_AT_GIGABYTES|1073741824
  assert_eq(@typex.data_size_format_at(1073741823L, "GB"), "1 GB") // FMT_AT_GIGABYTES|1073741823
  assert_eq(@typex.data_size_format_at(1099511627776L, "GB"), "1024 GB") // FMT_AT_GIGABYTES|1099511627776
  assert_eq(@typex.data_size_format_at(1125899906842624L, "GB"), "1048576 GB") // FMT_AT_GIGABYTES|1125899906842624
  assert_eq(
    @typex.data_size_format_at(1152921504606846976L, "GB"),
    "1073741824 GB",
  ) // FMT_AT_GIGABYTES|1152921504606846976
  assert_eq(
    @typex.data_size_format_at(9223372036854775807L, "GB"),
    "8589934592 GB",
  ) // FMT_AT_GIGABYTES|9223372036854775807
  assert_eq(@typex.data_size_format_at(-9223372036854775808L, "GB"), "0") // FMT_AT_GIGABYTES|-9223372036854775808
}

///|
test "format_at(long, \u{5355}\u{4f4d}\u{540e}\u{7f00})\u{ff1a}\u{6309}\u{8be5}\u{5355}\u{4f4d}\u{5b9a}\u{6863}\u{3001}\u{65e0}\u{5343}\u{5206}\u{4f4d}\u{ff08}KB\u{ff09}" {
  assert_eq(@typex.data_size_format_at(0L, "KB"), "0") // FMT_AT_KILOBYTES|0
  assert_eq(@typex.data_size_format_at(-1L, "KB"), "0") // FMT_AT_KILOBYTES|-1
  assert_eq(@typex.data_size_format_at(-1024L, "KB"), "0") // FMT_AT_KILOBYTES|-1024
  assert_eq(@typex.data_size_format_at(1L, "KB"), "0 KB") // FMT_AT_KILOBYTES|1
  assert_eq(@typex.data_size_format_at(999L, "KB"), "0.98 KB") // FMT_AT_KILOBYTES|999
  assert_eq(@typex.data_size_format_at(1000L, "KB"), "0.98 KB") // FMT_AT_KILOBYTES|1000
  assert_eq(@typex.data_size_format_at(1023L, "KB"), "1 KB") // FMT_AT_KILOBYTES|1023
  assert_eq(@typex.data_size_format_at(1024L, "KB"), "1 KB") // FMT_AT_KILOBYTES|1024
  assert_eq(@typex.data_size_format_at(1025L, "KB"), "1 KB") // FMT_AT_KILOBYTES|1025
  assert_eq(@typex.data_size_format_at(1536L, "KB"), "1.5 KB") // FMT_AT_KILOBYTES|1536
  assert_eq(@typex.data_size_format_at(1126L, "KB"), "1.1 KB") // FMT_AT_KILOBYTES|1126
  assert_eq(@typex.data_size_format_at(9999L, "KB"), "9.76 KB") // FMT_AT_KILOBYTES|9999
  assert_eq(@typex.data_size_format_at(10000L, "KB"), "9.77 KB") // FMT_AT_KILOBYTES|10000
  assert_eq(@typex.data_size_format_at(999999L, "KB"), "976.56 KB") // FMT_AT_KILOBYTES|999999
  assert_eq(@typex.data_size_format_at(1000000L, "KB"), "976.56 KB") // FMT_AT_KILOBYTES|1000000
  assert_eq(@typex.data_size_format_at(1048575L, "KB"), "1024 KB") // FMT_AT_KILOBYTES|1048575
  assert_eq(@typex.data_size_format_at(1048576L, "KB"), "1024 KB") // FMT_AT_KILOBYTES|1048576
  assert_eq(@typex.data_size_format_at(5243392L, "KB"), "5120.5 KB") // FMT_AT_KILOBYTES|5243392
  assert_eq(@typex.data_size_format_at(1073741824L, "KB"), "1048576 KB") // FMT_AT_KILOBYTES|1073741824
  assert_eq(@typex.data_size_format_at(1073741823L, "KB"), "1048576 KB") // FMT_AT_KILOBYTES|1073741823
  assert_eq(@typex.data_size_format_at(1099511627776L, "KB"), "1073741824 KB") // FMT_AT_KILOBYTES|1099511627776
  assert_eq(
    @typex.data_size_format_at(1125899906842624L, "KB"),
    "1099511627776 KB",
  ) // FMT_AT_KILOBYTES|1125899906842624
  assert_eq(
    @typex.data_size_format_at(1152921504606846976L, "KB"),
    "1125899906842624 KB",
  ) // FMT_AT_KILOBYTES|1152921504606846976
  assert_eq(
    @typex.data_size_format_at(9223372036854775807L, "KB"),
    "9007199254740992 KB",
  ) // FMT_AT_KILOBYTES|9223372036854775807
  assert_eq(@typex.data_size_format_at(-9223372036854775808L, "KB"), "0") // FMT_AT_KILOBYTES|-9223372036854775808
}

///|
test "format_at(long, \u{5355}\u{4f4d}\u{540e}\u{7f00})\u{ff1a}\u{6309}\u{8be5}\u{5355}\u{4f4d}\u{5b9a}\u{6863}\u{3001}\u{65e0}\u{5343}\u{5206}\u{4f4d}\u{ff08}MB\u{ff09}" {
  assert_eq(@typex.data_size_format_at(0L, "MB"), "0") // FMT_AT_MEGABYTES|0
  assert_eq(@typex.data_size_format_at(-1L, "MB"), "0") // FMT_AT_MEGABYTES|-1
  assert_eq(@typex.data_size_format_at(-1024L, "MB"), "0") // FMT_AT_MEGABYTES|-1024
  assert_eq(@typex.data_size_format_at(1L, "MB"), "0 MB") // FMT_AT_MEGABYTES|1
  assert_eq(@typex.data_size_format_at(999L, "MB"), "0 MB") // FMT_AT_MEGABYTES|999
  assert_eq(@typex.data_size_format_at(1000L, "MB"), "0 MB") // FMT_AT_MEGABYTES|1000
  assert_eq(@typex.data_size_format_at(1023L, "MB"), "0 MB") // FMT_AT_MEGABYTES|1023
  assert_eq(@typex.data_size_format_at(1024L, "MB"), "0 MB") // FMT_AT_MEGABYTES|1024
  assert_eq(@typex.data_size_format_at(1025L, "MB"), "0 MB") // FMT_AT_MEGABYTES|1025
  assert_eq(@typex.data_size_format_at(1536L, "MB"), "0 MB") // FMT_AT_MEGABYTES|1536
  assert_eq(@typex.data_size_format_at(1126L, "MB"), "0 MB") // FMT_AT_MEGABYTES|1126
  assert_eq(@typex.data_size_format_at(9999L, "MB"), "0.01 MB") // FMT_AT_MEGABYTES|9999
  assert_eq(@typex.data_size_format_at(10000L, "MB"), "0.01 MB") // FMT_AT_MEGABYTES|10000
  assert_eq(@typex.data_size_format_at(999999L, "MB"), "0.95 MB") // FMT_AT_MEGABYTES|999999
  assert_eq(@typex.data_size_format_at(1000000L, "MB"), "0.95 MB") // FMT_AT_MEGABYTES|1000000
  assert_eq(@typex.data_size_format_at(1048575L, "MB"), "1 MB") // FMT_AT_MEGABYTES|1048575
  assert_eq(@typex.data_size_format_at(1048576L, "MB"), "1 MB") // FMT_AT_MEGABYTES|1048576
  assert_eq(@typex.data_size_format_at(5243392L, "MB"), "5 MB") // FMT_AT_MEGABYTES|5243392
  assert_eq(@typex.data_size_format_at(1073741824L, "MB"), "1024 MB") // FMT_AT_MEGABYTES|1073741824
  assert_eq(@typex.data_size_format_at(1073741823L, "MB"), "1024 MB") // FMT_AT_MEGABYTES|1073741823
  assert_eq(@typex.data_size_format_at(1099511627776L, "MB"), "1048576 MB") // FMT_AT_MEGABYTES|1099511627776
  assert_eq(
    @typex.data_size_format_at(1125899906842624L, "MB"),
    "1073741824 MB",
  ) // FMT_AT_MEGABYTES|1125899906842624
  assert_eq(
    @typex.data_size_format_at(1152921504606846976L, "MB"),
    "1099511627776 MB",
  ) // FMT_AT_MEGABYTES|1152921504606846976
  assert_eq(
    @typex.data_size_format_at(9223372036854775807L, "MB"),
    "8796093022208 MB",
  ) // FMT_AT_MEGABYTES|9223372036854775807
  assert_eq(@typex.data_size_format_at(-9223372036854775808L, "MB"), "0") // FMT_AT_MEGABYTES|-9223372036854775808
}

///|
test "format_at(long, \u{5355}\u{4f4d}\u{540e}\u{7f00})\u{ff1a}\u{6309}\u{8be5}\u{5355}\u{4f4d}\u{5b9a}\u{6863}\u{3001}\u{65e0}\u{5343}\u{5206}\u{4f4d}\u{ff08}TB\u{ff09}" {
  assert_eq(@typex.data_size_format_at(0L, "TB"), "0") // FMT_AT_TERABYTES|0
  assert_eq(@typex.data_size_format_at(-1L, "TB"), "0") // FMT_AT_TERABYTES|-1
  assert_eq(@typex.data_size_format_at(-1024L, "TB"), "0") // FMT_AT_TERABYTES|-1024
  assert_eq(@typex.data_size_format_at(1L, "TB"), "0 TB") // FMT_AT_TERABYTES|1
  assert_eq(@typex.data_size_format_at(999L, "TB"), "0 TB") // FMT_AT_TERABYTES|999
  assert_eq(@typex.data_size_format_at(1000L, "TB"), "0 TB") // FMT_AT_TERABYTES|1000
  assert_eq(@typex.data_size_format_at(1023L, "TB"), "0 TB") // FMT_AT_TERABYTES|1023
  assert_eq(@typex.data_size_format_at(1024L, "TB"), "0 TB") // FMT_AT_TERABYTES|1024
  assert_eq(@typex.data_size_format_at(1025L, "TB"), "0 TB") // FMT_AT_TERABYTES|1025
  assert_eq(@typex.data_size_format_at(1536L, "TB"), "0 TB") // FMT_AT_TERABYTES|1536
  assert_eq(@typex.data_size_format_at(1126L, "TB"), "0 TB") // FMT_AT_TERABYTES|1126
  assert_eq(@typex.data_size_format_at(9999L, "TB"), "0 TB") // FMT_AT_TERABYTES|9999
  assert_eq(@typex.data_size_format_at(10000L, "TB"), "0 TB") // FMT_AT_TERABYTES|10000
  assert_eq(@typex.data_size_format_at(999999L, "TB"), "0 TB") // FMT_AT_TERABYTES|999999
  assert_eq(@typex.data_size_format_at(1000000L, "TB"), "0 TB") // FMT_AT_TERABYTES|1000000
  assert_eq(@typex.data_size_format_at(1048575L, "TB"), "0 TB") // FMT_AT_TERABYTES|1048575
  assert_eq(@typex.data_size_format_at(1048576L, "TB"), "0 TB") // FMT_AT_TERABYTES|1048576
  assert_eq(@typex.data_size_format_at(5243392L, "TB"), "0 TB") // FMT_AT_TERABYTES|5243392
  assert_eq(@typex.data_size_format_at(1073741824L, "TB"), "0 TB") // FMT_AT_TERABYTES|1073741824
  assert_eq(@typex.data_size_format_at(1073741823L, "TB"), "0 TB") // FMT_AT_TERABYTES|1073741823
  assert_eq(@typex.data_size_format_at(1099511627776L, "TB"), "1 TB") // FMT_AT_TERABYTES|1099511627776
  assert_eq(@typex.data_size_format_at(1125899906842624L, "TB"), "1024 TB") // FMT_AT_TERABYTES|1125899906842624
  assert_eq(
    @typex.data_size_format_at(1152921504606846976L, "TB"),
    "1048576 TB",
  ) // FMT_AT_TERABYTES|1152921504606846976
  assert_eq(
    @typex.data_size_format_at(9223372036854775807L, "TB"),
    "8388608 TB",
  ) // FMT_AT_TERABYTES|9223372036854775807
  assert_eq(@typex.data_size_format_at(-9223372036854775808L, "TB"), "0") // FMT_AT_TERABYTES|-9223372036854775808
}
