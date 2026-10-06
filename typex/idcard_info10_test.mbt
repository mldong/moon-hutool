///|
// moon-hutool/typex —— IdcardInfo10 三槽（ROADMAP 第 23 行第六批，#23.111）
// 期望值全部由生成脚本从参照腿灌入（手打零条）：腿 Temp/convsrc/hktw_rows.tsv 的 `CARD10*`/`C10B`
// 共 29 条唯一读数。三槽按腿原样比：`region|gender|valid`，参照的 `null` 出口在这里读成 `null`。
// 槽里除地区名/性别外没有别的值域，`valid` 那一档由参照的 "true"/"false" 串归一成 Bool（映射机械，见 spec §20.1）。

///|
// 黑盒面把三槽归成一条串再比，避免同一个夹具拆成三条断言（标签与腿行一一对应）
fn tx10_tag(info : @typex.IdcardInfo10?) -> String {
  match info {
    None => "null"
    Some(i) => {
      let v = if i.valid { "true" } else { "false" }
      i.region + "|" + i.gender + "|" + v
    }
  }
}

///|
test "IdcardInfo10 \u{4e09}\u{69fd}\u{ff1a}\u{53f0}/\u{6fb3}/\u{6e2f}\u{4e09}\u{5730}\u{533a}\u{3001}\u{6027}\u{522b} M/F/N\u{ff08}\u{542b}\u{53f0}\u{6e7e}\u{7b2c} 2 \u{4f4d}\u{975e} 1/2 \u{7684}\u{65e9}\u{9000} N\u{ff09}\u{3001}null \u{51fa}\u{53e3}\u{5404}\u{6863}" {
  assert_eq(
    tx10_tag(@typex.idcard_info_10("1123456(A)")),
    "\u{6fb3}\u{95e8}|N|true",
  ) // C10B|1123456(A)
  assert_eq(tx10_tag(@typex.idcard_info_10("1234567")), "null") // C10B|1234567
  assert_eq(
    tx10_tag(@typex.idcard_info_10("5123456Z)")),
    "\u{6fb3}\u{95e8}|N|true",
  ) // C10B|5123456Z)
  assert_eq(
    tx10_tag(@typex.idcard_info_10("7123456(9")),
    "\u{6fb3}\u{95e8}|N|true",
  ) // C10B|7123456(9
  assert_eq(tx10_tag(@typex.idcard_info_10("9999999999")), "null") // C10B|9999999999
  assert_eq(
    tx10_tag(@typex.idcard_info_10("A123456789")),
    "\u{53f0}\u{6e7e}|M|true",
  ) // C10B|A123456789
  assert_eq(
    tx10_tag(@typex.idcard_info_10("A223456781")),
    "\u{53f0}\u{6e7e}|F|true",
  ) // C10B|A223456781
  assert_eq(
    tx10_tag(@typex.idcard_info_10("C323456789")),
    "\u{53f0}\u{6e7e}|N|false",
  ) // C10B|C323456789
  assert_eq(
    tx10_tag(@typex.idcard_info_10("G123456A")),
    "\u{9999}\u{6e2f}|N|true",
  ) // C10B|G123456A
  assert_eq(
    tx10_tag(@typex.idcard_info_10("X999999999")),
    "\u{53f0}\u{6e7e}|N|false",
  ) // C10B|X999999999
  assert_eq(tx10_tag(@typex.idcard_info_10("\u{3000}")), "null") // C10B|\u3000
  assert_eq(tx10_tag(@typex.idcard_info_10("")), "null") // CARD10|
  assert_eq(tx10_tag(@typex.idcard_info_10(" ")), "null") // CARD10| 
  assert_eq(tx10_tag(@typex.idcard_info_10("1123456789")), "null") // CARD10|1123456789
  assert_eq(tx10_tag(@typex.idcard_info_10("11234567890")), "null") // CARD10|11234567890
  assert_eq(
    tx10_tag(@typex.idcard_info_10("5123456(7)")),
    "\u{6fb3}\u{95e8}|N|true",
  ) // CARD10|5123456(7)
  assert_eq(
    tx10_tag(@typex.idcard_info_10("7123456(9)")),
    "\u{6fb3}\u{95e8}|N|true",
  ) // CARD10|7123456(9)
  assert_eq(
    tx10_tag(@typex.idcard_info_10("A123456(7)")),
    "\u{9999}\u{6e2f}|N|false",
  ) // CARD10|A123456(7)
  assert_eq(
    tx10_tag(@typex.idcard_info_10("A1234563")),
    "\u{9999}\u{6e2f}|N|true",
  ) // CARD10|A1234563
  assert_eq(tx10_tag(@typex.idcard_info_10("A12345678")), "null") // CARD10|A12345678
  assert_eq(
    tx10_tag(@typex.idcard_info_10("A123456789")),
    "\u{53f0}\u{6e7e}|M|true",
  ) // CARD10|A123456789
  assert_eq(tx10_tag(@typex.idcard_info_10("AB12345(6)")), "null") // CARD10|AB12345(6)
  assert_eq(
    tx10_tag(@typex.idcard_info_10("AB1234569")),
    "\u{9999}\u{6e2f}|N|true",
  ) // CARD10|AB1234569
  assert_eq(tx10_tag(@typex.idcard_info_10("M12345678")), "null") // CARD10|M12345678
  assert_eq(tx10_tag(@typex.idcard_info_10("Z12345678")), "null") // CARD10|Z12345678
  assert_eq(
    tx10_tag(@typex.idcard_info_10("a123456789")),
    "\u{53f0}\u{6e7e}|M|false",
  ) // CARD10|a123456789
  assert_eq(
    tx10_tag(@typex.idcard_info_10("A1234567")),
    "\u{9999}\u{6e2f}|N|false",
  ) // CARD10_len8|A1234567
  assert_eq(
    tx10_tag(@typex.idcard_info_10("AB1234567")),
    "\u{9999}\u{6e2f}|N|false",
  ) // CARD10_len9|AB1234567
  assert_eq(tx10_tag(@typex.idcard_info_10("AB12345(6)")), "null") // CARD10_len9paren|AB12345(6)
}
