///|
// 第一批（valid）的期望值由生成器从两条腿的读数文件灌入，手打零条：
//   腿 A = 真 hutool-core-5.8.35 + 本机 JDK 17.0.14 跑 Validator（valid_ref.txt，判定件 × 样本，另附每条模式的源文与 flags）
//   腿 B = core @string.Regex 探针（vp_wasm.txt，189 条；改写后的码表在同一批样本上跑，wasm/js/wasm-gc 三档逐字节相同）
// 本批只收**两腿读数逐条相同**的判定件：127 条样本 / 15 件，0 条分岔——分岔不需要声明，是因为改写到命中集一致为止。
// 规则书与全部出处：docs/spec/11-valid.md。

///|
// 判定件都是 Bool，没有错误面，所以本包不需要 `show`；每条断言的形状是 `is_xxx(样本) == 期望`

///|
// 字母与通用名（#11.1~#11.1）——样本集与腿 A 完全同形，正例在前负例在后
test "valid：字母与通用名" {
  assert_eq(@valid.is_word("ABC"), true)
  assert_eq(@valid.is_word("abc"), true)
  assert_eq(@valid.is_word(""), false)
  assert_eq(@valid.is_word("-"), false)
  assert_eq(@valid.is_word("123"), false)
  assert_eq(@valid.is_word("a_b"), false)
  assert_eq(@valid.is_word("abc123"), false)
  assert_eq(@valid.is_word("ì"), false)
  assert_eq(@valid.is_word("中文"), false)
  assert_eq(@valid.is_general("A"), true)
  assert_eq(@valid.is_general("_"), true)
  assert_eq(@valid.is_general("abc_123"), true)
  assert_eq(@valid.is_general(""), false)
  assert_eq(@valid.is_general("a b"), false)
  assert_eq(@valid.is_general("a-b"), false)
  assert_eq(@valid.is_general("ab\t"), false)
  assert_eq(@valid.is_general("ì0"), false)
  assert_eq(@valid.is_general("中文x"), false)
  assert_eq(@valid.is_general_between("A", 1, 3), true)
  assert_eq(@valid.is_general_between("_", 1, 3), true)
  assert_eq(@valid.is_general_between("", 1, 3), false)
  assert_eq(@valid.is_general_between("a b", 1, 3), false)
  assert_eq(@valid.is_general_between("a-b", 1, 3), false)
  assert_eq(@valid.is_general_between("ab\t", 1, 3), false)
  assert_eq(@valid.is_general_between("abc_123", 1, 3), false)
  assert_eq(@valid.is_general_between("ì0", 1, 3), false)
  assert_eq(@valid.is_general_between("中文x", 1, 3), false)
  assert_eq(@valid.is_general_at_least("abc_123", 2), true)
  assert_eq(@valid.is_general_at_least("", 2), false)
  assert_eq(@valid.is_general_at_least("A", 2), false)
  assert_eq(@valid.is_general_at_least("_", 2), false)
  assert_eq(@valid.is_general_at_least("a b", 2), false)
  assert_eq(@valid.is_general_at_least("a-b", 2), false)
  assert_eq(@valid.is_general_at_least("ab\t", 2), false)
  assert_eq(@valid.is_general_at_least("ì0", 2), false)
  assert_eq(@valid.is_general_at_least("中文x", 2), false)
}

///|
// 金额与邮编与手机（#11.2~#11.2）——样本集与腿 A 完全同形，正例在前负例在后
test "valid：金额与邮编与手机" {
  assert_eq(@valid.is_money("0"), true)
  assert_eq(@valid.is_money("1"), true)
  assert_eq(@valid.is_money("1.2"), true)
  assert_eq(@valid.is_money("1.22"), true)
  assert_eq(@valid.is_money("1.222"), true)
  assert_eq(@valid.is_money(""), false)
  assert_eq(@valid.is_money("-1"), false)
  assert_eq(@valid.is_money(".5"), false)
  assert_eq(@valid.is_money("1,000"), false)
  assert_eq(@valid.is_money("a"), false)
  assert_eq(@valid.is_money("中文"), false)
  assert_eq(@valid.is_zip_code("100000"), true)
  assert_eq(@valid.is_zip_code("999077"), true)
  assert_eq(@valid.is_zip_code("999078"), true)
  assert_eq(@valid.is_zip_code(""), false)
  assert_eq(@valid.is_zip_code("0100000"), false)
  assert_eq(@valid.is_zip_code("1234"), false)
  assert_eq(@valid.is_zip_code("12345"), false)
  assert_eq(@valid.is_zip_code("999079"), false)
  assert_eq(@valid.is_zip_code("中文"), false)
  assert_eq(@valid.is_mobile("+8613800138000"), true)
  assert_eq(@valid.is_mobile("013800138000"), true)
  assert_eq(@valid.is_mobile("13800138000"), true)
  assert_eq(@valid.is_mobile("8613800138000"), true)
  assert_eq(@valid.is_mobile(""), false)
  assert_eq(@valid.is_mobile("12345678901"), false)
  assert_eq(@valid.is_mobile("1380013800"), false)
  assert_eq(@valid.is_mobile("138001380001"), false)
  assert_eq(@valid.is_mobile("中文"), false)
}

///|
// 网络地址三件（#11.3~#11.3）——样本集与腿 A 完全同形，正例在前负例在后
test "valid：网络地址三件" {
  assert_eq(@valid.is_ipv4("0.0.0.0"), true)
  assert_eq(@valid.is_ipv4("01.01.01.01"), true)
  assert_eq(@valid.is_ipv4("192.168.1.1"), true)
  assert_eq(@valid.is_ipv4("255.255.255.255"), true)
  assert_eq(@valid.is_ipv4(""), false)
  assert_eq(@valid.is_ipv4("1.1.1"), false)
  assert_eq(@valid.is_ipv4("1.1.1.1 "), false)
  assert_eq(@valid.is_ipv4("1.1.1.1.1"), false)
  assert_eq(@valid.is_ipv4("256.1.1.1"), false)
  assert_eq(@valid.is_ipv4("中文"), false)
  assert_eq(@valid.is_ipv6("2001:0db8:85a3:0000:0000:8a2e:0370:7334"), true)
  assert_eq(@valid.is_ipv6("::"), true)
  assert_eq(@valid.is_ipv6("::1"), true)
  assert_eq(@valid.is_ipv6("fe80::1%1"), true)
  assert_eq(@valid.is_ipv6(""), false)
  assert_eq(@valid.is_ipv6("1.2.3.4"), false)
  assert_eq(@valid.is_ipv6("2001:db8::::1"), false)
  assert_eq(@valid.is_ipv6("abcd"), false)
  assert_eq(@valid.is_ipv6("gz::1"), false)
  assert_eq(@valid.is_mac("00-11-22-33-44-55"), true)
  assert_eq(@valid.is_mac("0011.2233.4455"), true)
  assert_eq(@valid.is_mac("00:11:22:33:44:55"), true)
  assert_eq(@valid.is_mac(""), false)
  assert_eq(@valid.is_mac("00-11-22-33-44"), false)
  assert_eq(@valid.is_mac("0x112233445566ETHER"), false)
  assert_eq(@valid.is_mac("gg:11:22:33:44:55"), false)
  assert_eq(@valid.is_mac("中文"), false)
}

///|
// 标识与编码（#11.4~#11.4）——样本集与腿 A 完全同形，正例在前负例在后
test "valid：标识与编码" {
  assert_eq(@valid.is_uuid("00000000-0000-0000-0000-000000000000"), true)
  assert_eq(@valid.is_uuid("DCD01AC8892E4A4788D9F8ED2CB74EEE"), true)
  assert_eq(@valid.is_uuid("dCd01aC8-892E-4a47-88D9-f8eD2cB74eEE"), true)
  assert_eq(@valid.is_uuid("dcd01ac8-892e-4a47-88d9-f8ed2cb74eee"), true)
  assert_eq(@valid.is_uuid("dcd01ac8892e4a4788d9f8ed2cb74eee"), true)
  assert_eq(@valid.is_uuid(""), false)
  assert_eq(@valid.is_uuid("dcd01ac8-892e-4a47-88d9-f8ed2cb74ee"), false)
  assert_eq(@valid.is_uuid("dcd01ac8-892e-4a47-88d9-f8ed2cb74eee-z"), false)
  assert_eq(@valid.is_uuid("dcd01ac8-892e-4a47-88d9-f8ed2cb74eeez"), false)
  assert_eq(@valid.is_uuid("dcd01ac8892e4a4788d9f8ed2cb74ee"), false)
  assert_eq(@valid.is_uuid("中文"), false)
  assert_eq(@valid.is_hex("1a2B3c"), true)
  assert_eq(@valid.is_hex("ABCDEF0123456789"), true)
  assert_eq(@valid.is_hex(""), false)
  assert_eq(@valid.is_hex("0x1a"), false)
  assert_eq(@valid.is_hex("g"), false)
  assert_eq(@valid.is_hex("中文"), false)
}

///|
// 车辆两证（#11.5~#11.5）——样本集与腿 A 完全同形，正例在前负例在后
test "valid：车辆两证" {
  assert_eq(@valid.is_car_vin("1HBAJ1SJ6KJ021064"), true)
  assert_eq(@valid.is_car_vin(""), false)
  assert_eq(@valid.is_car_vin("1HBAJ1SJ6KJ02106"), false)
  assert_eq(@valid.is_car_vin("1HBAJ1SJ6KJ0210645"), false)
  assert_eq(@valid.is_car_vin("ABCDEFGHIJKLMNOPQRS"), false)
  assert_eq(@valid.is_car_vin("IOIIOIOIOIOIOIOIO"), false)
  assert_eq(@valid.is_car_driving_licence("123456789012"), true)
  assert_eq(@valid.is_car_driving_licence(""), false)
  assert_eq(@valid.is_car_driving_licence("12345678901"), false)
  assert_eq(@valid.is_car_driving_licence("1234567890123"), false)
  assert_eq(@valid.is_car_driving_licence("abcdefghijkl"), false)
  assert_eq(@valid.is_plate_number("京A12345"), true)
  assert_eq(@valid.is_plate_number("京AF12345"), true)
  assert_eq(@valid.is_plate_number("粤Z1234港"), true)
  assert_eq(@valid.is_plate_number(""), false)
  assert_eq(@valid.is_plate_number("A12345"), false)
  assert_eq(@valid.is_plate_number("中文"), false)
  assert_eq(@valid.is_plate_number("京A1234"), false)
}
