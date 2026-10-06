///|
// typex 第三批 A（PhoneUtil）的期望值全部由生成脚本从参照腿灌入（手打零条）。
// 腿：真 hutool-core-5.8.35.jar + JDK 17.0.14，`javac -encoding UTF-8`；六枚码表由反射读 `PatternPool` 的源文与 flags。
// 关键分档：含 astral 字符的样本同时落在「码位档（hide 三件）」与「码元档（sub 三件）」里——两族索引域不同，见 spec §11.3 第 1 条。

///|
test "Phone \u{5224}\u{5b9a}\u{624b}\u{673a}\u{4e0e}\u{6e2f}\u{6fb3}\u{53f0}\u{6fb3}\u{56db}\u{6863}" {
  assert_eq(@typex.phone_is_mobile("13800138000"), true) // IS_MOBILE|13800138000
  assert_eq(@typex.phone_is_mobile("013800138000"), true) // IS_MOBILE|013800138000
  assert_eq(@typex.phone_is_mobile("8613800138000"), true) // IS_MOBILE|8613800138000
  assert_eq(@typex.phone_is_mobile("+8613800138000"), true) // IS_MOBILE|+8613800138000
  assert_eq(@typex.phone_is_mobile("138001380001"), false) // IS_MOBILE|138001380001
  assert_eq(@typex.phone_is_mobile("1380013800"), false) // IS_MOBILE|1380013800
  assert_eq(@typex.phone_is_mobile("12345678901"), false) // IS_MOBILE|12345678901
  assert_eq(@typex.phone_is_mobile("23800138000"), false) // IS_MOBILE|23800138000
  assert_eq(@typex.phone_is_mobile("1380013800a"), false) // IS_MOBILE|1380013800a
  assert_eq(@typex.phone_is_mobile("51234567"), false) // IS_MOBILE|51234567
  assert_eq(@typex.phone_is_mobile("512345678"), false) // IS_MOBILE|512345678
  assert_eq(@typex.phone_is_mobile("61234567"), false) // IS_MOBILE|61234567
  assert_eq(@typex.phone_is_mobile("91234567"), false) // IS_MOBILE|91234567
  assert_eq(@typex.phone_is_mobile("41234567"), false) // IS_MOBILE|41234567
  assert_eq(@typex.phone_is_mobile("912345678"), false) // IS_MOBILE|912345678
  assert_eq(@typex.phone_is_mobile("60012345"), false) // IS_MOBILE|60012345
  assert_eq(@typex.phone_is_mobile("00853-61234567"), false) // IS_MOBILE|00853-61234567
  assert_eq(@typex.phone_is_mobile("010-12345678"), false) // IS_MOBILE|010-12345678
  assert_eq(@typex.phone_is_mobile("01012345678"), false) // IS_MOBILE|01012345678
  assert_eq(@typex.phone_is_mobile("(010)12345678"), false) // IS_MOBILE|(010)12345678
  assert_eq(@typex.phone_is_mobile("0755-1234567"), false) // IS_MOBILE|0755-1234567
  assert_eq(@typex.phone_is_mobile("07551234567"), false) // IS_MOBILE|07551234567
  assert_eq(@typex.phone_is_mobile("400-123-4567"), false) // IS_MOBILE|400-123-4567
  assert_eq(@typex.phone_is_mobile("4001234567"), false) // IS_MOBILE|4001234567
  assert_eq(@typex.phone_is_mobile("800-1234567"), false) // IS_MOBILE|800-1234567
  assert_eq(@typex.phone_is_mobile("8001234567"), false) // IS_MOBILE|8001234567
  assert_eq(@typex.phone_is_mobile("400-12-345678"), false) // IS_MOBILE|400-12-345678
  assert_eq(@typex.phone_is_mobile("12345"), false) // IS_MOBILE|12345
  assert_eq(@typex.phone_is_mobile(""), false) // IS_MOBILE|
  assert_eq(@typex.phone_is_mobile(" "), false) // IS_MOBILE| 
  assert_eq(@typex.phone_is_mobile("010-123456789"), false) // IS_MOBILE|010-123456789
  assert_eq(@typex.phone_is_mobile("\u{1f34e}13800138000"), false) // IS_MOBILE|🍎13800138000

  assert_eq(@typex.phone_is_mobile_hk("13800138000"), false) // IS_MOBILE_HK|13800138000
  assert_eq(@typex.phone_is_mobile_hk("013800138000"), false) // IS_MOBILE_HK|013800138000
  assert_eq(@typex.phone_is_mobile_hk("8613800138000"), false) // IS_MOBILE_HK|8613800138000
  assert_eq(@typex.phone_is_mobile_hk("+8613800138000"), false) // IS_MOBILE_HK|+8613800138000
  assert_eq(@typex.phone_is_mobile_hk("138001380001"), false) // IS_MOBILE_HK|138001380001
  assert_eq(@typex.phone_is_mobile_hk("1380013800"), false) // IS_MOBILE_HK|1380013800
  assert_eq(@typex.phone_is_mobile_hk("12345678901"), false) // IS_MOBILE_HK|12345678901
  assert_eq(@typex.phone_is_mobile_hk("23800138000"), false) // IS_MOBILE_HK|23800138000
  assert_eq(@typex.phone_is_mobile_hk("1380013800a"), false) // IS_MOBILE_HK|1380013800a
  assert_eq(@typex.phone_is_mobile_hk("51234567"), true) // IS_MOBILE_HK|51234567
  assert_eq(@typex.phone_is_mobile_hk("512345678"), false) // IS_MOBILE_HK|512345678
  assert_eq(@typex.phone_is_mobile_hk("61234567"), true) // IS_MOBILE_HK|61234567
  assert_eq(@typex.phone_is_mobile_hk("91234567"), true) // IS_MOBILE_HK|91234567
  assert_eq(@typex.phone_is_mobile_hk("41234567"), true) // IS_MOBILE_HK|41234567
  assert_eq(@typex.phone_is_mobile_hk("912345678"), false) // IS_MOBILE_HK|912345678
  assert_eq(@typex.phone_is_mobile_hk("60012345"), true) // IS_MOBILE_HK|60012345
  assert_eq(@typex.phone_is_mobile_hk("00853-61234567"), false) // IS_MOBILE_HK|00853-61234567
  assert_eq(@typex.phone_is_mobile_hk("010-12345678"), false) // IS_MOBILE_HK|010-12345678
  assert_eq(@typex.phone_is_mobile_hk("01012345678"), false) // IS_MOBILE_HK|01012345678
  assert_eq(@typex.phone_is_mobile_hk("(010)12345678"), false) // IS_MOBILE_HK|(010)12345678
  assert_eq(@typex.phone_is_mobile_hk("0755-1234567"), false) // IS_MOBILE_HK|0755-1234567
  assert_eq(@typex.phone_is_mobile_hk("07551234567"), false) // IS_MOBILE_HK|07551234567
  assert_eq(@typex.phone_is_mobile_hk("400-123-4567"), false) // IS_MOBILE_HK|400-123-4567
  assert_eq(@typex.phone_is_mobile_hk("4001234567"), false) // IS_MOBILE_HK|4001234567
  assert_eq(@typex.phone_is_mobile_hk("800-1234567"), false) // IS_MOBILE_HK|800-1234567
  assert_eq(@typex.phone_is_mobile_hk("8001234567"), false) // IS_MOBILE_HK|8001234567
  assert_eq(@typex.phone_is_mobile_hk("400-12-345678"), false) // IS_MOBILE_HK|400-12-345678
  assert_eq(@typex.phone_is_mobile_hk("12345"), false) // IS_MOBILE_HK|12345
  assert_eq(@typex.phone_is_mobile_hk(""), false) // IS_MOBILE_HK|
  assert_eq(@typex.phone_is_mobile_hk(" "), false) // IS_MOBILE_HK| 
  assert_eq(@typex.phone_is_mobile_hk("010-123456789"), false) // IS_MOBILE_HK|010-123456789
  assert_eq(@typex.phone_is_mobile_hk("\u{1f34e}13800138000"), false) // IS_MOBILE_HK|🍎13800138000

  assert_eq(@typex.phone_is_mobile_tw("13800138000"), false) // IS_MOBILE_TW|13800138000
  assert_eq(@typex.phone_is_mobile_tw("013800138000"), false) // IS_MOBILE_TW|013800138000
  assert_eq(@typex.phone_is_mobile_tw("8613800138000"), false) // IS_MOBILE_TW|8613800138000
  assert_eq(@typex.phone_is_mobile_tw("+8613800138000"), false) // IS_MOBILE_TW|+8613800138000
  assert_eq(@typex.phone_is_mobile_tw("138001380001"), false) // IS_MOBILE_TW|138001380001
  assert_eq(@typex.phone_is_mobile_tw("1380013800"), false) // IS_MOBILE_TW|1380013800
  assert_eq(@typex.phone_is_mobile_tw("12345678901"), false) // IS_MOBILE_TW|12345678901
  assert_eq(@typex.phone_is_mobile_tw("23800138000"), false) // IS_MOBILE_TW|23800138000
  assert_eq(@typex.phone_is_mobile_tw("1380013800a"), false) // IS_MOBILE_TW|1380013800a
  assert_eq(@typex.phone_is_mobile_tw("51234567"), false) // IS_MOBILE_TW|51234567
  assert_eq(@typex.phone_is_mobile_tw("512345678"), false) // IS_MOBILE_TW|512345678
  assert_eq(@typex.phone_is_mobile_tw("61234567"), false) // IS_MOBILE_TW|61234567
  assert_eq(@typex.phone_is_mobile_tw("91234567"), false) // IS_MOBILE_TW|91234567
  assert_eq(@typex.phone_is_mobile_tw("41234567"), false) // IS_MOBILE_TW|41234567
  assert_eq(@typex.phone_is_mobile_tw("912345678"), false) // IS_MOBILE_TW|912345678
  assert_eq(@typex.phone_is_mobile_tw("60012345"), false) // IS_MOBILE_TW|60012345
  assert_eq(@typex.phone_is_mobile_tw("00853-61234567"), false) // IS_MOBILE_TW|00853-61234567
  assert_eq(@typex.phone_is_mobile_tw("010-12345678"), false) // IS_MOBILE_TW|010-12345678
  assert_eq(@typex.phone_is_mobile_tw("01012345678"), false) // IS_MOBILE_TW|01012345678
  assert_eq(@typex.phone_is_mobile_tw("(010)12345678"), false) // IS_MOBILE_TW|(010)12345678
  assert_eq(@typex.phone_is_mobile_tw("0755-1234567"), false) // IS_MOBILE_TW|0755-1234567
  assert_eq(@typex.phone_is_mobile_tw("07551234567"), false) // IS_MOBILE_TW|07551234567
  assert_eq(@typex.phone_is_mobile_tw("400-123-4567"), false) // IS_MOBILE_TW|400-123-4567
  assert_eq(@typex.phone_is_mobile_tw("4001234567"), false) // IS_MOBILE_TW|4001234567
  assert_eq(@typex.phone_is_mobile_tw("800-1234567"), false) // IS_MOBILE_TW|800-1234567
  assert_eq(@typex.phone_is_mobile_tw("8001234567"), false) // IS_MOBILE_TW|8001234567
  assert_eq(@typex.phone_is_mobile_tw("400-12-345678"), false) // IS_MOBILE_TW|400-12-345678
  assert_eq(@typex.phone_is_mobile_tw("12345"), false) // IS_MOBILE_TW|12345
  assert_eq(@typex.phone_is_mobile_tw(""), false) // IS_MOBILE_TW|
  assert_eq(@typex.phone_is_mobile_tw(" "), false) // IS_MOBILE_TW| 
  assert_eq(@typex.phone_is_mobile_tw("010-123456789"), false) // IS_MOBILE_TW|010-123456789
  assert_eq(@typex.phone_is_mobile_tw("\u{1f34e}13800138000"), false) // IS_MOBILE_TW|🍎13800138000

  assert_eq(@typex.phone_is_mobile_mo("13800138000"), false) // IS_MOBILE_MO|13800138000
  assert_eq(@typex.phone_is_mobile_mo("013800138000"), false) // IS_MOBILE_MO|013800138000
  assert_eq(@typex.phone_is_mobile_mo("8613800138000"), false) // IS_MOBILE_MO|8613800138000
  assert_eq(@typex.phone_is_mobile_mo("+8613800138000"), false) // IS_MOBILE_MO|+8613800138000
  assert_eq(@typex.phone_is_mobile_mo("138001380001"), false) // IS_MOBILE_MO|138001380001
  assert_eq(@typex.phone_is_mobile_mo("1380013800"), false) // IS_MOBILE_MO|1380013800
  assert_eq(@typex.phone_is_mobile_mo("12345678901"), false) // IS_MOBILE_MO|12345678901
  assert_eq(@typex.phone_is_mobile_mo("23800138000"), false) // IS_MOBILE_MO|23800138000
  assert_eq(@typex.phone_is_mobile_mo("1380013800a"), false) // IS_MOBILE_MO|1380013800a
  assert_eq(@typex.phone_is_mobile_mo("51234567"), false) // IS_MOBILE_MO|51234567
  assert_eq(@typex.phone_is_mobile_mo("512345678"), false) // IS_MOBILE_MO|512345678
  assert_eq(@typex.phone_is_mobile_mo("61234567"), true) // IS_MOBILE_MO|61234567
  assert_eq(@typex.phone_is_mobile_mo("91234567"), false) // IS_MOBILE_MO|91234567
  assert_eq(@typex.phone_is_mobile_mo("41234567"), false) // IS_MOBILE_MO|41234567
  assert_eq(@typex.phone_is_mobile_mo("912345678"), false) // IS_MOBILE_MO|912345678
  assert_eq(@typex.phone_is_mobile_mo("60012345"), true) // IS_MOBILE_MO|60012345
  assert_eq(@typex.phone_is_mobile_mo("00853-61234567"), false) // IS_MOBILE_MO|00853-61234567
  assert_eq(@typex.phone_is_mobile_mo("010-12345678"), false) // IS_MOBILE_MO|010-12345678
  assert_eq(@typex.phone_is_mobile_mo("01012345678"), false) // IS_MOBILE_MO|01012345678
  assert_eq(@typex.phone_is_mobile_mo("(010)12345678"), false) // IS_MOBILE_MO|(010)12345678
  assert_eq(@typex.phone_is_mobile_mo("0755-1234567"), false) // IS_MOBILE_MO|0755-1234567
  assert_eq(@typex.phone_is_mobile_mo("07551234567"), false) // IS_MOBILE_MO|07551234567
  assert_eq(@typex.phone_is_mobile_mo("400-123-4567"), false) // IS_MOBILE_MO|400-123-4567
  assert_eq(@typex.phone_is_mobile_mo("4001234567"), false) // IS_MOBILE_MO|4001234567
  assert_eq(@typex.phone_is_mobile_mo("800-1234567"), false) // IS_MOBILE_MO|800-1234567
  assert_eq(@typex.phone_is_mobile_mo("8001234567"), false) // IS_MOBILE_MO|8001234567
  assert_eq(@typex.phone_is_mobile_mo("400-12-345678"), false) // IS_MOBILE_MO|400-12-345678
  assert_eq(@typex.phone_is_mobile_mo("12345"), false) // IS_MOBILE_MO|12345
  assert_eq(@typex.phone_is_mobile_mo(""), false) // IS_MOBILE_MO|
  assert_eq(@typex.phone_is_mobile_mo(" "), false) // IS_MOBILE_MO| 
  assert_eq(@typex.phone_is_mobile_mo("010-123456789"), false) // IS_MOBILE_MO|010-123456789
  assert_eq(@typex.phone_is_mobile_mo("\u{1f34e}13800138000"), false) // IS_MOBILE_MO|🍎13800138000
}

///|
test "Phone \u{5224}\u{5b9a}\u{56fa}\u{8bdd}\u{4e0e} 400\u{b7}800 \u{4ee5}\u{53ca} is_phone \u{7684}\u{4e94}\u{8def}\u{6216}" {
  assert_eq(@typex.phone_is_tel("13800138000"), false) // IS_TEL|13800138000
  assert_eq(@typex.phone_is_tel("013800138000"), false) // IS_TEL|013800138000
  assert_eq(@typex.phone_is_tel("8613800138000"), false) // IS_TEL|8613800138000
  assert_eq(@typex.phone_is_tel("+8613800138000"), false) // IS_TEL|+8613800138000
  assert_eq(@typex.phone_is_tel("138001380001"), false) // IS_TEL|138001380001
  assert_eq(@typex.phone_is_tel("1380013800"), false) // IS_TEL|1380013800
  assert_eq(@typex.phone_is_tel("12345678901"), false) // IS_TEL|12345678901
  assert_eq(@typex.phone_is_tel("23800138000"), false) // IS_TEL|23800138000
  assert_eq(@typex.phone_is_tel("1380013800a"), false) // IS_TEL|1380013800a
  assert_eq(@typex.phone_is_tel("51234567"), false) // IS_TEL|51234567
  assert_eq(@typex.phone_is_tel("512345678"), false) // IS_TEL|512345678
  assert_eq(@typex.phone_is_tel("61234567"), false) // IS_TEL|61234567
  assert_eq(@typex.phone_is_tel("91234567"), false) // IS_TEL|91234567
  assert_eq(@typex.phone_is_tel("41234567"), false) // IS_TEL|41234567
  assert_eq(@typex.phone_is_tel("912345678"), false) // IS_TEL|912345678
  assert_eq(@typex.phone_is_tel("60012345"), false) // IS_TEL|60012345
  assert_eq(@typex.phone_is_tel("00853-61234567"), false) // IS_TEL|00853-61234567
  assert_eq(@typex.phone_is_tel("010-12345678"), true) // IS_TEL|010-12345678
  assert_eq(@typex.phone_is_tel("01012345678"), true) // IS_TEL|01012345678
  assert_eq(@typex.phone_is_tel("(010)12345678"), false) // IS_TEL|(010)12345678
  assert_eq(@typex.phone_is_tel("0755-1234567"), true) // IS_TEL|0755-1234567
  assert_eq(@typex.phone_is_tel("07551234567"), true) // IS_TEL|07551234567
  assert_eq(@typex.phone_is_tel("400-123-4567"), false) // IS_TEL|400-123-4567
  assert_eq(@typex.phone_is_tel("4001234567"), false) // IS_TEL|4001234567
  assert_eq(@typex.phone_is_tel("800-1234567"), false) // IS_TEL|800-1234567
  assert_eq(@typex.phone_is_tel("8001234567"), false) // IS_TEL|8001234567
  assert_eq(@typex.phone_is_tel("400-12-345678"), false) // IS_TEL|400-12-345678
  assert_eq(@typex.phone_is_tel("12345"), false) // IS_TEL|12345
  assert_eq(@typex.phone_is_tel(""), false) // IS_TEL|
  assert_eq(@typex.phone_is_tel(" "), false) // IS_TEL| 
  assert_eq(@typex.phone_is_tel("010-123456789"), false) // IS_TEL|010-123456789
  assert_eq(@typex.phone_is_tel("\u{1f34e}13800138000"), false) // IS_TEL|🍎13800138000

  assert_eq(@typex.phone_is_tel400800("13800138000"), false) // IS_TEL_400_800|13800138000
  assert_eq(@typex.phone_is_tel400800("013800138000"), false) // IS_TEL_400_800|013800138000
  assert_eq(@typex.phone_is_tel400800("8613800138000"), false) // IS_TEL_400_800|8613800138000
  assert_eq(@typex.phone_is_tel400800("+8613800138000"), false) // IS_TEL_400_800|+8613800138000
  assert_eq(@typex.phone_is_tel400800("138001380001"), false) // IS_TEL_400_800|138001380001
  assert_eq(@typex.phone_is_tel400800("1380013800"), false) // IS_TEL_400_800|1380013800
  assert_eq(@typex.phone_is_tel400800("12345678901"), false) // IS_TEL_400_800|12345678901
  assert_eq(@typex.phone_is_tel400800("23800138000"), false) // IS_TEL_400_800|23800138000
  assert_eq(@typex.phone_is_tel400800("1380013800a"), false) // IS_TEL_400_800|1380013800a
  assert_eq(@typex.phone_is_tel400800("51234567"), false) // IS_TEL_400_800|51234567
  assert_eq(@typex.phone_is_tel400800("512345678"), false) // IS_TEL_400_800|512345678
  assert_eq(@typex.phone_is_tel400800("61234567"), false) // IS_TEL_400_800|61234567
  assert_eq(@typex.phone_is_tel400800("91234567"), false) // IS_TEL_400_800|91234567
  assert_eq(@typex.phone_is_tel400800("41234567"), false) // IS_TEL_400_800|41234567
  assert_eq(@typex.phone_is_tel400800("912345678"), false) // IS_TEL_400_800|912345678
  assert_eq(@typex.phone_is_tel400800("60012345"), false) // IS_TEL_400_800|60012345
  assert_eq(@typex.phone_is_tel400800("00853-61234567"), false) // IS_TEL_400_800|00853-61234567
  assert_eq(@typex.phone_is_tel400800("010-12345678"), true) // IS_TEL_400_800|010-12345678
  assert_eq(@typex.phone_is_tel400800("01012345678"), true) // IS_TEL_400_800|01012345678
  assert_eq(@typex.phone_is_tel400800("(010)12345678"), false) // IS_TEL_400_800|(010)12345678
  assert_eq(@typex.phone_is_tel400800("0755-1234567"), true) // IS_TEL_400_800|0755-1234567
  assert_eq(@typex.phone_is_tel400800("07551234567"), true) // IS_TEL_400_800|07551234567
  assert_eq(@typex.phone_is_tel400800("400-123-4567"), true) // IS_TEL_400_800|400-123-4567
  assert_eq(@typex.phone_is_tel400800("4001234567"), true) // IS_TEL_400_800|4001234567
  assert_eq(@typex.phone_is_tel400800("800-1234567"), true) // IS_TEL_400_800|800-1234567
  assert_eq(@typex.phone_is_tel400800("8001234567"), true) // IS_TEL_400_800|8001234567
  assert_eq(@typex.phone_is_tel400800("400-12-345678"), false) // IS_TEL_400_800|400-12-345678
  assert_eq(@typex.phone_is_tel400800("12345"), false) // IS_TEL_400_800|12345
  assert_eq(@typex.phone_is_tel400800(""), false) // IS_TEL_400_800|
  assert_eq(@typex.phone_is_tel400800(" "), false) // IS_TEL_400_800| 
  assert_eq(@typex.phone_is_tel400800("010-123456789"), false) // IS_TEL_400_800|010-123456789
  assert_eq(@typex.phone_is_tel400800("\u{1f34e}13800138000"), false) // IS_TEL_400_800|🍎13800138000

  assert_eq(@typex.phone_is_phone("13800138000"), true) // IS_PHONE|13800138000
  assert_eq(@typex.phone_is_phone("013800138000"), true) // IS_PHONE|013800138000
  assert_eq(@typex.phone_is_phone("8613800138000"), true) // IS_PHONE|8613800138000
  assert_eq(@typex.phone_is_phone("+8613800138000"), true) // IS_PHONE|+8613800138000
  assert_eq(@typex.phone_is_phone("138001380001"), false) // IS_PHONE|138001380001
  assert_eq(@typex.phone_is_phone("1380013800"), false) // IS_PHONE|1380013800
  assert_eq(@typex.phone_is_phone("12345678901"), false) // IS_PHONE|12345678901
  assert_eq(@typex.phone_is_phone("23800138000"), false) // IS_PHONE|23800138000
  assert_eq(@typex.phone_is_phone("1380013800a"), false) // IS_PHONE|1380013800a
  assert_eq(@typex.phone_is_phone("51234567"), true) // IS_PHONE|51234567
  assert_eq(@typex.phone_is_phone("512345678"), false) // IS_PHONE|512345678
  assert_eq(@typex.phone_is_phone("61234567"), true) // IS_PHONE|61234567
  assert_eq(@typex.phone_is_phone("91234567"), true) // IS_PHONE|91234567
  assert_eq(@typex.phone_is_phone("41234567"), true) // IS_PHONE|41234567
  assert_eq(@typex.phone_is_phone("912345678"), false) // IS_PHONE|912345678
  assert_eq(@typex.phone_is_phone("60012345"), true) // IS_PHONE|60012345
  assert_eq(@typex.phone_is_phone("00853-61234567"), false) // IS_PHONE|00853-61234567
  assert_eq(@typex.phone_is_phone("010-12345678"), true) // IS_PHONE|010-12345678
  assert_eq(@typex.phone_is_phone("01012345678"), true) // IS_PHONE|01012345678
  assert_eq(@typex.phone_is_phone("(010)12345678"), false) // IS_PHONE|(010)12345678
  assert_eq(@typex.phone_is_phone("0755-1234567"), true) // IS_PHONE|0755-1234567
  assert_eq(@typex.phone_is_phone("07551234567"), true) // IS_PHONE|07551234567
  assert_eq(@typex.phone_is_phone("400-123-4567"), true) // IS_PHONE|400-123-4567
  assert_eq(@typex.phone_is_phone("4001234567"), true) // IS_PHONE|4001234567
  assert_eq(@typex.phone_is_phone("800-1234567"), true) // IS_PHONE|800-1234567
  assert_eq(@typex.phone_is_phone("8001234567"), true) // IS_PHONE|8001234567
  assert_eq(@typex.phone_is_phone("400-12-345678"), false) // IS_PHONE|400-12-345678
  assert_eq(@typex.phone_is_phone("12345"), false) // IS_PHONE|12345
  assert_eq(@typex.phone_is_phone(""), false) // IS_PHONE|
  assert_eq(@typex.phone_is_phone(" "), false) // IS_PHONE| 
  assert_eq(@typex.phone_is_phone("010-123456789"), false) // IS_PHONE|010-123456789
  assert_eq(@typex.phone_is_phone("\u{1f34e}13800138000"), false) // IS_PHONE|🍎13800138000
}

///|
test "Phone \u{63a9}\u{7801}\u{4e09}\u{4ef6}\u{6309}\u{7801}\u{4f4d}\u{53d6}\u{4e32}\u{4e09}\u{4ef6}\u{6309}\u{7801}\u{5143}" {
  assert_eq(@typex.phone_hide_before("13800138000"), "*******8000") // HIDE_BEFORE|13800138000
  assert_eq(@typex.phone_hide_before("010-12345678"), "*******45678") // HIDE_BEFORE|010-12345678
  assert_eq(@typex.phone_hide_before("400-123-4567"), "*******-4567") // HIDE_BEFORE|400-123-4567
  assert_eq(@typex.phone_hide_before("1380013800"), "*******800") // HIDE_BEFORE|1380013800
  assert_eq(@typex.phone_hide_before("138001380001234"), "*******80001234") // HIDE_BEFORE|138001380001234
  assert_eq(@typex.phone_hide_before("12345"), "*****") // HIDE_BEFORE|12345
  assert_eq(@typex.phone_hide_before(""), "") // HIDE_BEFORE|
  assert_eq(
    @typex.phone_hide_before("1380013\u{1f34e}8000"),
    "*******\u{1f34e}8000",
  ) // HIDE_BEFORE|1380013🍎8000
  assert_eq(@typex.phone_hide_before("a\u{e9}1380013800"), "*******13800") // HIDE_BEFORE|aé1380013800

  assert_eq(@typex.phone_hide_between("13800138000"), "138****8000") // HIDE_BETWEEN|13800138000
  assert_eq(@typex.phone_hide_between("010-12345678"), "010****45678") // HIDE_BETWEEN|010-12345678
  assert_eq(@typex.phone_hide_between("400-123-4567"), "400****-4567") // HIDE_BETWEEN|400-123-4567
  assert_eq(@typex.phone_hide_between("1380013800"), "138****800") // HIDE_BETWEEN|1380013800
  assert_eq(@typex.phone_hide_between("138001380001234"), "138****80001234") // HIDE_BETWEEN|138001380001234
  assert_eq(@typex.phone_hide_between("12345"), "123**") // HIDE_BETWEEN|12345
  assert_eq(@typex.phone_hide_between(""), "") // HIDE_BETWEEN|
  assert_eq(
    @typex.phone_hide_between("1380013\u{1f34e}8000"),
    "138****\u{1f34e}8000",
  ) // HIDE_BETWEEN|1380013🍎8000
  assert_eq(@typex.phone_hide_between("a\u{e9}1380013800"), "a\u{e9}1****13800") // HIDE_BETWEEN|aé1380013800

  assert_eq(@typex.phone_hide_after("13800138000"), "1380013****") // HIDE_AFTER|13800138000
  assert_eq(@typex.phone_hide_after("010-12345678"), "010-123****8") // HIDE_AFTER|010-12345678
  assert_eq(@typex.phone_hide_after("400-123-4567"), "400-123****7") // HIDE_AFTER|400-123-4567
  assert_eq(@typex.phone_hide_after("1380013800"), "1380013***") // HIDE_AFTER|1380013800
  assert_eq(@typex.phone_hide_after("138001380001234"), "1380013****1234") // HIDE_AFTER|138001380001234
  assert_eq(@typex.phone_hide_after("12345"), "12345") // HIDE_AFTER|12345
  assert_eq(@typex.phone_hide_after(""), "") // HIDE_AFTER|
  assert_eq(@typex.phone_hide_after("1380013\u{1f34e}8000"), "1380013****0") // HIDE_AFTER|1380013🍎8000
  assert_eq(@typex.phone_hide_after("a\u{e9}1380013800"), "a\u{e9}13800****0") // HIDE_AFTER|aé1380013800

  assert_eq(@typex.phone_sub_before("13800138000"), "138") // SUB_BEFORE|13800138000
  assert_eq(@typex.phone_sub_before("010-12345678"), "010") // SUB_BEFORE|010-12345678
  assert_eq(@typex.phone_sub_before("400-123-4567"), "400") // SUB_BEFORE|400-123-4567
  assert_eq(@typex.phone_sub_before("1380013800"), "138") // SUB_BEFORE|1380013800
  assert_eq(@typex.phone_sub_before("138001380001234"), "138") // SUB_BEFORE|138001380001234
  assert_eq(@typex.phone_sub_before("12345"), "123") // SUB_BEFORE|12345
  assert_eq(@typex.phone_sub_before(""), "") // SUB_BEFORE|
  assert_eq(@typex.phone_sub_before("1380013\u{1f34e}8000"), "138") // SUB_BEFORE|1380013🍎8000
  assert_eq(@typex.phone_sub_before("a\u{e9}1380013800"), "a\u{e9}1") // SUB_BEFORE|aé1380013800

  assert_eq(@typex.phone_sub_between("13800138000"), "0013") // SUB_BETWEEN|13800138000
  assert_eq(@typex.phone_sub_between("010-12345678"), "-123") // SUB_BETWEEN|010-12345678
  assert_eq(@typex.phone_sub_between("400-123-4567"), "-123") // SUB_BETWEEN|400-123-4567
  assert_eq(@typex.phone_sub_between("1380013800"), "0013") // SUB_BETWEEN|1380013800
  assert_eq(@typex.phone_sub_between("138001380001234"), "0013") // SUB_BETWEEN|138001380001234
  assert_eq(@typex.phone_sub_between("12345"), "45") // SUB_BETWEEN|12345
  assert_eq(@typex.phone_sub_between(""), "") // SUB_BETWEEN|
  assert_eq(@typex.phone_sub_between("1380013\u{1f34e}8000"), "0013") // SUB_BETWEEN|1380013🍎8000
  assert_eq(@typex.phone_sub_between("a\u{e9}1380013800"), "3800") // SUB_BETWEEN|aé1380013800

  assert_eq(@typex.phone_sub_after("13800138000"), "8000") // SUB_AFTER|13800138000
  assert_eq(@typex.phone_sub_after("010-12345678"), "4567") // SUB_AFTER|010-12345678
  assert_eq(@typex.phone_sub_after("400-123-4567"), "-456") // SUB_AFTER|400-123-4567
  assert_eq(@typex.phone_sub_after("1380013800"), "800") // SUB_AFTER|1380013800
  assert_eq(@typex.phone_sub_after("138001380001234"), "8000") // SUB_AFTER|138001380001234
  assert_eq(@typex.phone_sub_after("12345"), "") // SUB_AFTER|12345
  assert_eq(@typex.phone_sub_after(""), "") // SUB_AFTER|
  assert_eq(@typex.phone_sub_after("1380013\u{1f34e}8000"), "\u{1f34e}80") // SUB_AFTER|1380013🍎8000
  assert_eq(@typex.phone_sub_after("a\u{e9}1380013800"), "1380") // SUB_AFTER|aé1380013800
}

///|
test "Phone \u{56fa}\u{8bdd}\u{53d6}\u{7ec4}\u{662f}\u{67e5}\u{627e}\u{5f0f}\u{4e14}\u{65e0}\u{5339}\u{914d}\u{7ed9} None" {
  assert_eq(@typex.phone_sub_tel_before("13800138000"), None) // SUB_TEL_BEFORE|13800138000
  assert_eq(@typex.phone_sub_tel_before("010-12345678"), Some("010")) // SUB_TEL_BEFORE|010-12345678
  assert_eq(@typex.phone_sub_tel_before("400-123-4567"), None) // SUB_TEL_BEFORE|400-123-4567
  assert_eq(@typex.phone_sub_tel_before("1380013800"), None) // SUB_TEL_BEFORE|1380013800
  assert_eq(@typex.phone_sub_tel_before("138001380001234"), None) // SUB_TEL_BEFORE|138001380001234
  assert_eq(@typex.phone_sub_tel_before("12345"), None) // SUB_TEL_BEFORE|12345
  assert_eq(@typex.phone_sub_tel_before(""), None) // SUB_TEL_BEFORE|
  assert_eq(@typex.phone_sub_tel_before("1380013\u{1f34e}8000"), None) // SUB_TEL_BEFORE|1380013🍎8000
  assert_eq(@typex.phone_sub_tel_before("a\u{e9}1380013800"), None) // SUB_TEL_BEFORE|aé1380013800

  assert_eq(@typex.phone_sub_tel_after("13800138000"), None) // SUB_TEL_AFTER|13800138000
  assert_eq(@typex.phone_sub_tel_after("010-12345678"), Some("12345678")) // SUB_TEL_AFTER|010-12345678
  assert_eq(@typex.phone_sub_tel_after("400-123-4567"), None) // SUB_TEL_AFTER|400-123-4567
  assert_eq(@typex.phone_sub_tel_after("1380013800"), None) // SUB_TEL_AFTER|1380013800
  assert_eq(@typex.phone_sub_tel_after("138001380001234"), None) // SUB_TEL_AFTER|138001380001234
  assert_eq(@typex.phone_sub_tel_after("12345"), None) // SUB_TEL_AFTER|12345
  assert_eq(@typex.phone_sub_tel_after(""), None) // SUB_TEL_AFTER|
  assert_eq(@typex.phone_sub_tel_after("1380013\u{1f34e}8000"), None) // SUB_TEL_AFTER|1380013🍎8000
  assert_eq(@typex.phone_sub_tel_after("a\u{e9}1380013800"), None) // SUB_TEL_AFTER|aé1380013800
}
