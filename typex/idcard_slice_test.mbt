///|
// typex 第三批 D（IdcardUtil 切片族）的期望值全部由生成脚本从参照腿灌入（手打零条）。
// VAL 行是参照返回值（参照给 null 也记 None）；**行尾标了异常类名的断言来自 ERR 行**——
// 参照在那一档是崩的（NPE / NumberFormatException / IllegalArgumentException / DateException），
// 本批九件一律不 raise，按 spec §14.4 的映射表统一记 None。映射是设计决定，不是参照读数。

///|
test "Idcard \u{5207}\u{7247}\u{53d6}\u{751f}\u{65e5}\u{ff08}15 \u{4f4d}\u{5148}\u{8f6c} 18 \u{4f4d}\u{ff0c}\u{5d29}\u{4e0e}\u{7a7a}\u{4e00}\u{5f8b} None\u{ff09}" {
  assert_eq(@typex.idcard_birth("110101196503125230"), Some("19650312")) // BIRTH|110101196503125230
  assert_eq(@typex.idcard_birth("140203196503125242"), Some("19650312")) // BIRTH|140203196503125242
  assert_eq(@typex.idcard_birth("311101196503125239"), Some("19650312")) // BIRTH|311101196503125239
  assert_eq(@typex.idcard_birth("810101196503125244"), Some("19650312")) // BIRTH|810101196503125244
  assert_eq(@typex.idcard_birth("911010198802030151"), Some("19880203")) // BIRTH|911010198802030151
  assert_eq(@typex.idcard_birth("110101200002295214"), Some("20000229")) // BIRTH|110101200002295214
  assert_eq(@typex.idcard_birth("110101650312523"), Some("19650312")) // BIRTH|110101650312523
  assert_eq(@typex.idcard_birth("310101800101123"), Some("19800101")) // BIRTH|310101800101123
  assert_eq(@typex.idcard_birth("440301990101001"), Some("19990101")) // BIRTH|440301990101001
  assert_eq(@typex.idcard_birth("110101000101001"), Some("20000101")) // BIRTH|110101000101001
  assert_eq(@typex.idcard_birth("810000650312523"), Some("19650312")) // BIRTH|810000650312523
  assert_eq(@typex.idcard_birth("110101990101001"), Some("19990101")) // BIRTH|110101990101001
  assert_eq(@typex.idcard_birth("110101650312X23"), None) // BIRTH|110101650312X23（参照 NullPointerException → 映射 None）
  assert_eq(@typex.idcard_birth("990101650312523"), Some("19650312")) // BIRTH|990101650312523
  assert_eq(@typex.idcard_birth("110101651331523"), None) // BIRTH|110101651331523（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_birth("110101650229523"), None) // BIRTH|110101650229523（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_birth("11010165031252 "), None) // BIRTH|11010165031252 （参照 NullPointerException → 映射 None）
  assert_eq(@typex.idcard_birth("11010165031252"), None) // BIRTH|11010165031252
  assert_eq(@typex.idcard_birth("1101011965031252"), Some("19650312")) // BIRTH|1101011965031252
  assert_eq(@typex.idcard_birth("11010119650312523"), Some("19650312")) // BIRTH|11010119650312523
  assert_eq(@typex.idcard_birth("110101196503125234"), Some("19650312")) // BIRTH|110101196503125234
  assert_eq(@typex.idcard_birth("1101011965031252345"), Some("19650312")) // BIRTH|1101011965031252345
  assert_eq(@typex.idcard_birth("11010119650312523456"), Some("19650312")) // BIRTH|11010119650312523456
  assert_eq(@typex.idcard_birth("abcdefghijklmnopqrst"), Some("ghijklmn")) // BIRTH|abcdefghijklmnopqrst
  assert_eq(@typex.idcard_birth("1101011965031252A4"), Some("19650312")) // BIRTH|1101011965031252A4
  assert_eq(@typex.idcard_birth("1101011965031252a4"), Some("19650312")) // BIRTH|1101011965031252a4
  assert_eq(@typex.idcard_birth("1101011965031252 X"), Some("19650312")) // BIRTH|1101011965031252 X
  assert_eq(@typex.idcard_birth("11010119650312523 "), Some("19650312")) // BIRTH|11010119650312523 
  assert_eq(@typex.idcard_birth(" 110101196503125234"), Some("11965031")) // BIRTH| 110101196503125234
  assert_eq(@typex.idcard_birth(""), None) // BIRTH|（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_birth(" "), None) // BIRTH| （参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_birth("\t"), None) // BIRTH|	（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_birth("00000000000000"), None) // BIRTH|00000000000000
  assert_eq(@typex.idcard_birth("000000000000000"), None) // BIRTH|000000000000000（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_birth("000000000000000000"), Some("00000000")) // BIRTH|000000000000000000
  assert_eq(@typex.idcard_birth("999999999999999"), None) // BIRTH|999999999999999（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_birth("999999999999999999"), Some("99999999")) // BIRTH|999999999999999999
  assert_eq(@typex.idcard_birth("110101999999999999"), Some("99999999")) // BIRTH|110101999999999999
  assert_eq(@typex.idcard_birth("110101000000005234"), Some("00000000")) // BIRTH|110101000000005234
}

///|
test "Idcard \u{5207}\u{7247}\u{53d6}\u{5e74}\u{6708}\u{65e5}\u{ff08}\u{975e}\u{6570}\u{5b57}\u{5207}\u{7247}\u{53c2}\u{7167}\u{629b}\u{ff0c}\u{672c}\u{5e93}\u{7ed9} None\u{ff09}" {
  assert_eq(@typex.idcard_year("110101196503125230"), Some(1965)) // YEAR|110101196503125230
  assert_eq(@typex.idcard_year("140203196503125242"), Some(1965)) // YEAR|140203196503125242
  assert_eq(@typex.idcard_year("311101196503125239"), Some(1965)) // YEAR|311101196503125239
  assert_eq(@typex.idcard_year("810101196503125244"), Some(1965)) // YEAR|810101196503125244
  assert_eq(@typex.idcard_year("911010198802030151"), Some(1988)) // YEAR|911010198802030151
  assert_eq(@typex.idcard_year("110101200002295214"), Some(2000)) // YEAR|110101200002295214
  assert_eq(@typex.idcard_year("110101650312523"), Some(1965)) // YEAR|110101650312523
  assert_eq(@typex.idcard_year("310101800101123"), Some(1980)) // YEAR|310101800101123
  assert_eq(@typex.idcard_year("440301990101001"), Some(1999)) // YEAR|440301990101001
  assert_eq(@typex.idcard_year("110101000101001"), Some(2000)) // YEAR|110101000101001
  assert_eq(@typex.idcard_year("810000650312523"), Some(1965)) // YEAR|810000650312523
  assert_eq(@typex.idcard_year("110101990101001"), Some(1999)) // YEAR|110101990101001
  assert_eq(@typex.idcard_year("110101650312X23"), None) // YEAR|110101650312X23（参照 NullPointerException → 映射 None）
  assert_eq(@typex.idcard_year("990101650312523"), Some(1965)) // YEAR|990101650312523
  assert_eq(@typex.idcard_year("110101651331523"), None) // YEAR|110101651331523（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_year("110101650229523"), None) // YEAR|110101650229523（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_year("11010165031252 "), None) // YEAR|11010165031252 （参照 NullPointerException → 映射 None）
  assert_eq(@typex.idcard_year("11010165031252"), None) // YEAR|11010165031252
  assert_eq(@typex.idcard_year("1101011965031252"), Some(1965)) // YEAR|1101011965031252
  assert_eq(@typex.idcard_year("11010119650312523"), Some(1965)) // YEAR|11010119650312523
  assert_eq(@typex.idcard_year("110101196503125234"), Some(1965)) // YEAR|110101196503125234
  assert_eq(@typex.idcard_year("1101011965031252345"), Some(1965)) // YEAR|1101011965031252345
  assert_eq(@typex.idcard_year("11010119650312523456"), Some(1965)) // YEAR|11010119650312523456
  assert_eq(@typex.idcard_year("abcdefghijklmnopqrst"), None) // YEAR|abcdefghijklmnopqrst（参照 NumberFormatException → 映射 None）
  assert_eq(@typex.idcard_year("1101011965031252A4"), Some(1965)) // YEAR|1101011965031252A4
  assert_eq(@typex.idcard_year("1101011965031252a4"), Some(1965)) // YEAR|1101011965031252a4
  assert_eq(@typex.idcard_year("1101011965031252 X"), Some(1965)) // YEAR|1101011965031252 X
  assert_eq(@typex.idcard_year("11010119650312523 "), Some(1965)) // YEAR|11010119650312523 
  assert_eq(@typex.idcard_year(" 110101196503125234"), Some(1196)) // YEAR| 110101196503125234
  assert_eq(@typex.idcard_year(""), None) // YEAR|
  assert_eq(@typex.idcard_year(" "), None) // YEAR| 
  assert_eq(@typex.idcard_year("\t"), None) // YEAR|	
  assert_eq(@typex.idcard_year("00000000000000"), None) // YEAR|00000000000000
  assert_eq(@typex.idcard_year("000000000000000"), None) // YEAR|000000000000000（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_year("000000000000000000"), Some(0)) // YEAR|000000000000000000
  assert_eq(@typex.idcard_year("999999999999999"), None) // YEAR|999999999999999（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_year("999999999999999999"), Some(9999)) // YEAR|999999999999999999
  assert_eq(@typex.idcard_year("110101999999999999"), Some(9999)) // YEAR|110101999999999999
  assert_eq(@typex.idcard_year("110101000000005234"), Some(0)) // YEAR|110101000000005234

  assert_eq(@typex.idcard_month("110101196503125230"), Some(3)) // MONTH|110101196503125230
  assert_eq(@typex.idcard_month("140203196503125242"), Some(3)) // MONTH|140203196503125242
  assert_eq(@typex.idcard_month("311101196503125239"), Some(3)) // MONTH|311101196503125239
  assert_eq(@typex.idcard_month("810101196503125244"), Some(3)) // MONTH|810101196503125244
  assert_eq(@typex.idcard_month("911010198802030151"), Some(2)) // MONTH|911010198802030151
  assert_eq(@typex.idcard_month("110101200002295214"), Some(2)) // MONTH|110101200002295214
  assert_eq(@typex.idcard_month("110101650312523"), Some(3)) // MONTH|110101650312523
  assert_eq(@typex.idcard_month("310101800101123"), Some(1)) // MONTH|310101800101123
  assert_eq(@typex.idcard_month("440301990101001"), Some(1)) // MONTH|440301990101001
  assert_eq(@typex.idcard_month("110101000101001"), Some(1)) // MONTH|110101000101001
  assert_eq(@typex.idcard_month("810000650312523"), Some(3)) // MONTH|810000650312523
  assert_eq(@typex.idcard_month("110101990101001"), Some(1)) // MONTH|110101990101001
  assert_eq(@typex.idcard_month("110101650312X23"), None) // MONTH|110101650312X23（参照 NullPointerException → 映射 None）
  assert_eq(@typex.idcard_month("990101650312523"), Some(3)) // MONTH|990101650312523
  assert_eq(@typex.idcard_month("110101651331523"), None) // MONTH|110101651331523（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_month("110101650229523"), None) // MONTH|110101650229523（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_month("11010165031252 "), None) // MONTH|11010165031252 （参照 NullPointerException → 映射 None）
  assert_eq(@typex.idcard_month("11010165031252"), None) // MONTH|11010165031252
  assert_eq(@typex.idcard_month("1101011965031252"), Some(3)) // MONTH|1101011965031252
  assert_eq(@typex.idcard_month("11010119650312523"), Some(3)) // MONTH|11010119650312523
  assert_eq(@typex.idcard_month("110101196503125234"), Some(3)) // MONTH|110101196503125234
  assert_eq(@typex.idcard_month("1101011965031252345"), Some(3)) // MONTH|1101011965031252345
  assert_eq(@typex.idcard_month("11010119650312523456"), Some(3)) // MONTH|11010119650312523456
  assert_eq(@typex.idcard_month("abcdefghijklmnopqrst"), None) // MONTH|abcdefghijklmnopqrst（参照 NumberFormatException → 映射 None）
  assert_eq(@typex.idcard_month("1101011965031252A4"), Some(3)) // MONTH|1101011965031252A4
  assert_eq(@typex.idcard_month("1101011965031252a4"), Some(3)) // MONTH|1101011965031252a4
  assert_eq(@typex.idcard_month("1101011965031252 X"), Some(3)) // MONTH|1101011965031252 X
  assert_eq(@typex.idcard_month("11010119650312523 "), Some(3)) // MONTH|11010119650312523 
  assert_eq(@typex.idcard_month(" 110101196503125234"), Some(50)) // MONTH| 110101196503125234
  assert_eq(@typex.idcard_month(""), None) // MONTH|
  assert_eq(@typex.idcard_month(" "), None) // MONTH| 
  assert_eq(@typex.idcard_month("\t"), None) // MONTH|	
  assert_eq(@typex.idcard_month("00000000000000"), None) // MONTH|00000000000000
  assert_eq(@typex.idcard_month("000000000000000"), None) // MONTH|000000000000000（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_month("000000000000000000"), Some(0)) // MONTH|000000000000000000
  assert_eq(@typex.idcard_month("999999999999999"), None) // MONTH|999999999999999（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_month("999999999999999999"), Some(99)) // MONTH|999999999999999999
  assert_eq(@typex.idcard_month("110101999999999999"), Some(99)) // MONTH|110101999999999999
  assert_eq(@typex.idcard_month("110101000000005234"), Some(0)) // MONTH|110101000000005234

  assert_eq(@typex.idcard_day("110101196503125230"), Some(12)) // DAY|110101196503125230
  assert_eq(@typex.idcard_day("140203196503125242"), Some(12)) // DAY|140203196503125242
  assert_eq(@typex.idcard_day("311101196503125239"), Some(12)) // DAY|311101196503125239
  assert_eq(@typex.idcard_day("810101196503125244"), Some(12)) // DAY|810101196503125244
  assert_eq(@typex.idcard_day("911010198802030151"), Some(3)) // DAY|911010198802030151
  assert_eq(@typex.idcard_day("110101200002295214"), Some(29)) // DAY|110101200002295214
  assert_eq(@typex.idcard_day("110101650312523"), Some(12)) // DAY|110101650312523
  assert_eq(@typex.idcard_day("310101800101123"), Some(1)) // DAY|310101800101123
  assert_eq(@typex.idcard_day("440301990101001"), Some(1)) // DAY|440301990101001
  assert_eq(@typex.idcard_day("110101000101001"), Some(1)) // DAY|110101000101001
  assert_eq(@typex.idcard_day("810000650312523"), Some(12)) // DAY|810000650312523
  assert_eq(@typex.idcard_day("110101990101001"), Some(1)) // DAY|110101990101001
  assert_eq(@typex.idcard_day("110101650312X23"), None) // DAY|110101650312X23（参照 NullPointerException → 映射 None）
  assert_eq(@typex.idcard_day("990101650312523"), Some(12)) // DAY|990101650312523
  assert_eq(@typex.idcard_day("110101651331523"), None) // DAY|110101651331523（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_day("110101650229523"), None) // DAY|110101650229523（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_day("11010165031252 "), None) // DAY|11010165031252 （参照 NullPointerException → 映射 None）
  assert_eq(@typex.idcard_day("11010165031252"), None) // DAY|11010165031252
  assert_eq(@typex.idcard_day("1101011965031252"), Some(12)) // DAY|1101011965031252
  assert_eq(@typex.idcard_day("11010119650312523"), Some(12)) // DAY|11010119650312523
  assert_eq(@typex.idcard_day("110101196503125234"), Some(12)) // DAY|110101196503125234
  assert_eq(@typex.idcard_day("1101011965031252345"), Some(12)) // DAY|1101011965031252345
  assert_eq(@typex.idcard_day("11010119650312523456"), Some(12)) // DAY|11010119650312523456
  assert_eq(@typex.idcard_day("abcdefghijklmnopqrst"), None) // DAY|abcdefghijklmnopqrst（参照 NumberFormatException → 映射 None）
  assert_eq(@typex.idcard_day("1101011965031252A4"), Some(12)) // DAY|1101011965031252A4
  assert_eq(@typex.idcard_day("1101011965031252a4"), Some(12)) // DAY|1101011965031252a4
  assert_eq(@typex.idcard_day("1101011965031252 X"), Some(12)) // DAY|1101011965031252 X
  assert_eq(@typex.idcard_day("11010119650312523 "), Some(12)) // DAY|11010119650312523 
  assert_eq(@typex.idcard_day(" 110101196503125234"), Some(31)) // DAY| 110101196503125234
  assert_eq(@typex.idcard_day(""), None) // DAY|
  assert_eq(@typex.idcard_day(" "), None) // DAY| 
  assert_eq(@typex.idcard_day("\t"), None) // DAY|	
  assert_eq(@typex.idcard_day("00000000000000"), None) // DAY|00000000000000
  assert_eq(@typex.idcard_day("000000000000000"), None) // DAY|000000000000000（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_day("000000000000000000"), Some(0)) // DAY|000000000000000000
  assert_eq(@typex.idcard_day("999999999999999"), None) // DAY|999999999999999（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_day("999999999999999999"), Some(99)) // DAY|999999999999999999
  assert_eq(@typex.idcard_day("110101999999999999"), Some(99)) // DAY|110101999999999999
  assert_eq(@typex.idcard_day("110101000000005234"), Some(0)) // DAY|110101000000005234
}

///|
test "Idcard \u{5207}\u{7247}\u{53d6}\u{6027}\u{522b}\u{ff08}charAt(16) \u{7684}\u{7801}\u{4f4d}\u{5947}\u{5076}\u{ff0c}\u{4e0d}\u{662f}\u{6570}\u{5b57}\u{5947}\u{5076}\u{ff09}" {
  assert_eq(@typex.idcard_gender("110101196503125230"), Some(1)) // GENDER|110101196503125230
  assert_eq(@typex.idcard_gender("140203196503125242"), Some(0)) // GENDER|140203196503125242
  assert_eq(@typex.idcard_gender("311101196503125239"), Some(1)) // GENDER|311101196503125239
  assert_eq(@typex.idcard_gender("810101196503125244"), Some(0)) // GENDER|810101196503125244
  assert_eq(@typex.idcard_gender("911010198802030151"), Some(1)) // GENDER|911010198802030151
  assert_eq(@typex.idcard_gender("110101200002295214"), Some(1)) // GENDER|110101200002295214
  assert_eq(@typex.idcard_gender("110101650312523"), Some(1)) // GENDER|110101650312523
  assert_eq(@typex.idcard_gender("310101800101123"), Some(1)) // GENDER|310101800101123
  assert_eq(@typex.idcard_gender("440301990101001"), Some(1)) // GENDER|440301990101001
  assert_eq(@typex.idcard_gender("110101000101001"), Some(1)) // GENDER|110101000101001
  assert_eq(@typex.idcard_gender("810000650312523"), Some(1)) // GENDER|810000650312523
  assert_eq(@typex.idcard_gender("110101990101001"), Some(1)) // GENDER|110101990101001
  assert_eq(@typex.idcard_gender("110101650312X23"), None) // GENDER|110101650312X23（参照 NullPointerException → 映射 None）
  assert_eq(@typex.idcard_gender("990101650312523"), Some(1)) // GENDER|990101650312523
  assert_eq(@typex.idcard_gender("110101651331523"), None) // GENDER|110101651331523（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_gender("110101650229523"), None) // GENDER|110101650229523（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_gender("11010165031252 "), None) // GENDER|11010165031252 （参照 NullPointerException → 映射 None）
  assert_eq(@typex.idcard_gender("11010165031252"), None) // GENDER|11010165031252（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_gender("1101011965031252"), None) // GENDER|1101011965031252（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_gender("11010119650312523"), None) // GENDER|11010119650312523（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_gender("110101196503125234"), Some(1)) // GENDER|110101196503125234
  assert_eq(@typex.idcard_gender("1101011965031252345"), None) // GENDER|1101011965031252345（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_gender("11010119650312523456"), None) // GENDER|11010119650312523456（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_gender("abcdefghijklmnopqrst"), None) // GENDER|abcdefghijklmnopqrst（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_gender("1101011965031252A4"), Some(1)) // GENDER|1101011965031252A4
  assert_eq(@typex.idcard_gender("1101011965031252a4"), Some(1)) // GENDER|1101011965031252a4
  assert_eq(@typex.idcard_gender("1101011965031252 X"), Some(0)) // GENDER|1101011965031252 X
  assert_eq(@typex.idcard_gender("11010119650312523 "), Some(1)) // GENDER|11010119650312523 
  assert_eq(@typex.idcard_gender(" 110101196503125234"), None) // GENDER| 110101196503125234（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_gender(""), None) // GENDER|（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_gender(" "), None) // GENDER| （参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_gender("\t"), None) // GENDER|	（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_gender("00000000000000"), None) // GENDER|00000000000000（参照 IllegalArgumentException → 映射 None）
  assert_eq(@typex.idcard_gender("000000000000000"), None) // GENDER|000000000000000（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_gender("000000000000000000"), Some(0)) // GENDER|000000000000000000
  assert_eq(@typex.idcard_gender("999999999999999"), None) // GENDER|999999999999999（参照 DateException → 映射 None）
  assert_eq(@typex.idcard_gender("999999999999999999"), Some(1)) // GENDER|999999999999999999
  assert_eq(@typex.idcard_gender("110101999999999999"), Some(1)) // GENDER|110101999999999999
  assert_eq(@typex.idcard_gender("110101000000005234"), Some(1)) // GENDER|110101000000005234
}

///|
test "Idcard \u{4e09}\u{4ef6}\u{7f16}\u{7801}\u{5207}\u{7247}\u{53ea}\u{770b}\u{957f}\u{5ea6} 15/18" {
  assert_eq(@typex.idcard_province_code("110101196503125230"), Some("11")) // PRO_CODE|110101196503125230
  assert_eq(@typex.idcard_province_code("140203196503125242"), Some("14")) // PRO_CODE|140203196503125242
  assert_eq(@typex.idcard_province_code("311101196503125239"), Some("31")) // PRO_CODE|311101196503125239
  assert_eq(@typex.idcard_province_code("810101196503125244"), Some("81")) // PRO_CODE|810101196503125244
  assert_eq(@typex.idcard_province_code("911010198802030151"), Some("91")) // PRO_CODE|911010198802030151
  assert_eq(@typex.idcard_province_code("110101200002295214"), Some("11")) // PRO_CODE|110101200002295214
  assert_eq(@typex.idcard_province_code("110101650312523"), Some("11")) // PRO_CODE|110101650312523
  assert_eq(@typex.idcard_province_code("310101800101123"), Some("31")) // PRO_CODE|310101800101123
  assert_eq(@typex.idcard_province_code("440301990101001"), Some("44")) // PRO_CODE|440301990101001
  assert_eq(@typex.idcard_province_code("110101000101001"), Some("11")) // PRO_CODE|110101000101001
  assert_eq(@typex.idcard_province_code("810000650312523"), Some("81")) // PRO_CODE|810000650312523
  assert_eq(@typex.idcard_province_code("110101990101001"), Some("11")) // PRO_CODE|110101990101001
  assert_eq(@typex.idcard_province_code("110101650312X23"), Some("11")) // PRO_CODE|110101650312X23
  assert_eq(@typex.idcard_province_code("990101650312523"), Some("99")) // PRO_CODE|990101650312523
  assert_eq(@typex.idcard_province_code("110101651331523"), Some("11")) // PRO_CODE|110101651331523
  assert_eq(@typex.idcard_province_code("110101650229523"), Some("11")) // PRO_CODE|110101650229523
  assert_eq(@typex.idcard_province_code("11010165031252 "), Some("11")) // PRO_CODE|11010165031252 
  assert_eq(@typex.idcard_province_code("11010165031252"), None) // PRO_CODE|11010165031252
  assert_eq(@typex.idcard_province_code("1101011965031252"), None) // PRO_CODE|1101011965031252
  assert_eq(@typex.idcard_province_code("11010119650312523"), None) // PRO_CODE|11010119650312523
  assert_eq(@typex.idcard_province_code("110101196503125234"), Some("11")) // PRO_CODE|110101196503125234
  assert_eq(@typex.idcard_province_code("1101011965031252345"), None) // PRO_CODE|1101011965031252345
  assert_eq(@typex.idcard_province_code("11010119650312523456"), None) // PRO_CODE|11010119650312523456
  assert_eq(@typex.idcard_province_code("abcdefghijklmnopqrst"), None) // PRO_CODE|abcdefghijklmnopqrst
  assert_eq(@typex.idcard_province_code("1101011965031252A4"), Some("11")) // PRO_CODE|1101011965031252A4
  assert_eq(@typex.idcard_province_code("1101011965031252a4"), Some("11")) // PRO_CODE|1101011965031252a4
  assert_eq(@typex.idcard_province_code("1101011965031252 X"), Some("11")) // PRO_CODE|1101011965031252 X
  assert_eq(@typex.idcard_province_code("11010119650312523 "), Some("11")) // PRO_CODE|11010119650312523 
  assert_eq(@typex.idcard_province_code(" 110101196503125234"), None) // PRO_CODE| 110101196503125234
  assert_eq(@typex.idcard_province_code(""), None) // PRO_CODE|
  assert_eq(@typex.idcard_province_code(" "), None) // PRO_CODE| 
  assert_eq(@typex.idcard_province_code("\t"), None) // PRO_CODE|	
  assert_eq(@typex.idcard_province_code("00000000000000"), None) // PRO_CODE|00000000000000
  assert_eq(@typex.idcard_province_code("000000000000000"), Some("00")) // PRO_CODE|000000000000000
  assert_eq(@typex.idcard_province_code("000000000000000000"), Some("00")) // PRO_CODE|000000000000000000
  assert_eq(@typex.idcard_province_code("999999999999999"), Some("99")) // PRO_CODE|999999999999999
  assert_eq(@typex.idcard_province_code("999999999999999999"), Some("99")) // PRO_CODE|999999999999999999
  assert_eq(@typex.idcard_province_code("110101999999999999"), Some("11")) // PRO_CODE|110101999999999999
  assert_eq(@typex.idcard_province_code("110101000000005234"), Some("11")) // PRO_CODE|110101000000005234

  assert_eq(@typex.idcard_city_code("110101196503125230"), Some("1101")) // CITY_CODE|110101196503125230
  assert_eq(@typex.idcard_city_code("140203196503125242"), Some("1402")) // CITY_CODE|140203196503125242
  assert_eq(@typex.idcard_city_code("311101196503125239"), Some("3111")) // CITY_CODE|311101196503125239
  assert_eq(@typex.idcard_city_code("810101196503125244"), Some("8101")) // CITY_CODE|810101196503125244
  assert_eq(@typex.idcard_city_code("911010198802030151"), Some("9110")) // CITY_CODE|911010198802030151
  assert_eq(@typex.idcard_city_code("110101200002295214"), Some("1101")) // CITY_CODE|110101200002295214
  assert_eq(@typex.idcard_city_code("110101650312523"), Some("1101")) // CITY_CODE|110101650312523
  assert_eq(@typex.idcard_city_code("310101800101123"), Some("3101")) // CITY_CODE|310101800101123
  assert_eq(@typex.idcard_city_code("440301990101001"), Some("4403")) // CITY_CODE|440301990101001
  assert_eq(@typex.idcard_city_code("110101000101001"), Some("1101")) // CITY_CODE|110101000101001
  assert_eq(@typex.idcard_city_code("810000650312523"), Some("8100")) // CITY_CODE|810000650312523
  assert_eq(@typex.idcard_city_code("110101990101001"), Some("1101")) // CITY_CODE|110101990101001
  assert_eq(@typex.idcard_city_code("110101650312X23"), Some("1101")) // CITY_CODE|110101650312X23
  assert_eq(@typex.idcard_city_code("990101650312523"), Some("9901")) // CITY_CODE|990101650312523
  assert_eq(@typex.idcard_city_code("110101651331523"), Some("1101")) // CITY_CODE|110101651331523
  assert_eq(@typex.idcard_city_code("110101650229523"), Some("1101")) // CITY_CODE|110101650229523
  assert_eq(@typex.idcard_city_code("11010165031252 "), Some("1101")) // CITY_CODE|11010165031252 
  assert_eq(@typex.idcard_city_code("11010165031252"), None) // CITY_CODE|11010165031252
  assert_eq(@typex.idcard_city_code("1101011965031252"), None) // CITY_CODE|1101011965031252
  assert_eq(@typex.idcard_city_code("11010119650312523"), None) // CITY_CODE|11010119650312523
  assert_eq(@typex.idcard_city_code("110101196503125234"), Some("1101")) // CITY_CODE|110101196503125234
  assert_eq(@typex.idcard_city_code("1101011965031252345"), None) // CITY_CODE|1101011965031252345
  assert_eq(@typex.idcard_city_code("11010119650312523456"), None) // CITY_CODE|11010119650312523456
  assert_eq(@typex.idcard_city_code("abcdefghijklmnopqrst"), None) // CITY_CODE|abcdefghijklmnopqrst
  assert_eq(@typex.idcard_city_code("1101011965031252A4"), Some("1101")) // CITY_CODE|1101011965031252A4
  assert_eq(@typex.idcard_city_code("1101011965031252a4"), Some("1101")) // CITY_CODE|1101011965031252a4
  assert_eq(@typex.idcard_city_code("1101011965031252 X"), Some("1101")) // CITY_CODE|1101011965031252 X
  assert_eq(@typex.idcard_city_code("11010119650312523 "), Some("1101")) // CITY_CODE|11010119650312523 
  assert_eq(@typex.idcard_city_code(" 110101196503125234"), None) // CITY_CODE| 110101196503125234
  assert_eq(@typex.idcard_city_code(""), None) // CITY_CODE|
  assert_eq(@typex.idcard_city_code(" "), None) // CITY_CODE| 
  assert_eq(@typex.idcard_city_code("\t"), None) // CITY_CODE|	
  assert_eq(@typex.idcard_city_code("00000000000000"), None) // CITY_CODE|00000000000000
  assert_eq(@typex.idcard_city_code("000000000000000"), Some("0000")) // CITY_CODE|000000000000000
  assert_eq(@typex.idcard_city_code("000000000000000000"), Some("0000")) // CITY_CODE|000000000000000000
  assert_eq(@typex.idcard_city_code("999999999999999"), Some("9999")) // CITY_CODE|999999999999999
  assert_eq(@typex.idcard_city_code("999999999999999999"), Some("9999")) // CITY_CODE|999999999999999999
  assert_eq(@typex.idcard_city_code("110101999999999999"), Some("1101")) // CITY_CODE|110101999999999999
  assert_eq(@typex.idcard_city_code("110101000000005234"), Some("1101")) // CITY_CODE|110101000000005234

  assert_eq(@typex.idcard_district_code("110101196503125230"), Some("110101")) // DISTRICT_CODE|110101196503125230
  assert_eq(@typex.idcard_district_code("140203196503125242"), Some("140203")) // DISTRICT_CODE|140203196503125242
  assert_eq(@typex.idcard_district_code("311101196503125239"), Some("311101")) // DISTRICT_CODE|311101196503125239
  assert_eq(@typex.idcard_district_code("810101196503125244"), Some("810101")) // DISTRICT_CODE|810101196503125244
  assert_eq(@typex.idcard_district_code("911010198802030151"), Some("911010")) // DISTRICT_CODE|911010198802030151
  assert_eq(@typex.idcard_district_code("110101200002295214"), Some("110101")) // DISTRICT_CODE|110101200002295214
  assert_eq(@typex.idcard_district_code("110101650312523"), Some("110101")) // DISTRICT_CODE|110101650312523
  assert_eq(@typex.idcard_district_code("310101800101123"), Some("310101")) // DISTRICT_CODE|310101800101123
  assert_eq(@typex.idcard_district_code("440301990101001"), Some("440301")) // DISTRICT_CODE|440301990101001
  assert_eq(@typex.idcard_district_code("110101000101001"), Some("110101")) // DISTRICT_CODE|110101000101001
  assert_eq(@typex.idcard_district_code("810000650312523"), Some("810000")) // DISTRICT_CODE|810000650312523
  assert_eq(@typex.idcard_district_code("110101990101001"), Some("110101")) // DISTRICT_CODE|110101990101001
  assert_eq(@typex.idcard_district_code("110101650312X23"), Some("110101")) // DISTRICT_CODE|110101650312X23
  assert_eq(@typex.idcard_district_code("990101650312523"), Some("990101")) // DISTRICT_CODE|990101650312523
  assert_eq(@typex.idcard_district_code("110101651331523"), Some("110101")) // DISTRICT_CODE|110101651331523
  assert_eq(@typex.idcard_district_code("110101650229523"), Some("110101")) // DISTRICT_CODE|110101650229523
  assert_eq(@typex.idcard_district_code("11010165031252 "), Some("110101")) // DISTRICT_CODE|11010165031252 
  assert_eq(@typex.idcard_district_code("11010165031252"), None) // DISTRICT_CODE|11010165031252
  assert_eq(@typex.idcard_district_code("1101011965031252"), None) // DISTRICT_CODE|1101011965031252
  assert_eq(@typex.idcard_district_code("11010119650312523"), None) // DISTRICT_CODE|11010119650312523
  assert_eq(@typex.idcard_district_code("110101196503125234"), Some("110101")) // DISTRICT_CODE|110101196503125234
  assert_eq(@typex.idcard_district_code("1101011965031252345"), None) // DISTRICT_CODE|1101011965031252345
  assert_eq(@typex.idcard_district_code("11010119650312523456"), None) // DISTRICT_CODE|11010119650312523456
  assert_eq(@typex.idcard_district_code("abcdefghijklmnopqrst"), None) // DISTRICT_CODE|abcdefghijklmnopqrst
  assert_eq(@typex.idcard_district_code("1101011965031252A4"), Some("110101")) // DISTRICT_CODE|1101011965031252A4
  assert_eq(@typex.idcard_district_code("1101011965031252a4"), Some("110101")) // DISTRICT_CODE|1101011965031252a4
  assert_eq(@typex.idcard_district_code("1101011965031252 X"), Some("110101")) // DISTRICT_CODE|1101011965031252 X
  assert_eq(@typex.idcard_district_code("11010119650312523 "), Some("110101")) // DISTRICT_CODE|11010119650312523 
  assert_eq(@typex.idcard_district_code(" 110101196503125234"), None) // DISTRICT_CODE| 110101196503125234
  assert_eq(@typex.idcard_district_code(""), None) // DISTRICT_CODE|
  assert_eq(@typex.idcard_district_code(" "), None) // DISTRICT_CODE| 
  assert_eq(@typex.idcard_district_code("\t"), None) // DISTRICT_CODE|	
  assert_eq(@typex.idcard_district_code("00000000000000"), None) // DISTRICT_CODE|00000000000000
  assert_eq(@typex.idcard_district_code("000000000000000"), Some("000000")) // DISTRICT_CODE|000000000000000
  assert_eq(@typex.idcard_district_code("000000000000000000"), Some("000000")) // DISTRICT_CODE|000000000000000000
  assert_eq(@typex.idcard_district_code("999999999999999"), Some("999999")) // DISTRICT_CODE|999999999999999
  assert_eq(@typex.idcard_district_code("999999999999999999"), Some("999999")) // DISTRICT_CODE|999999999999999999
  assert_eq(@typex.idcard_district_code("110101999999999999"), Some("110101")) // DISTRICT_CODE|110101999999999999
  assert_eq(@typex.idcard_district_code("110101000000005234"), Some("110101")) // DISTRICT_CODE|110101000000005234
}

///|
test "Idcard \u{63a9}\u{7801}\u{5207}\u{7247}\u{8d70}\u{7801}\u{4f4d}\u{ff08}\u{53c2}\u{7167}\u{59d4}\u{6258} StrUtil.hide\u{ff09}" {
  assert_eq(
    @typex.idcard_hide("110101196503125230", 6, 14),
    "110101********5230",
  ) // HIDE_6_14|110101196503125230
  assert_eq(
    @typex.idcard_hide("140203196503125242", 6, 14),
    "140203********5242",
  ) // HIDE_6_14|140203196503125242
  assert_eq(
    @typex.idcard_hide("311101196503125239", 6, 14),
    "311101********5239",
  ) // HIDE_6_14|311101196503125239
  assert_eq(
    @typex.idcard_hide("810101196503125244", 6, 14),
    "810101********5244",
  ) // HIDE_6_14|810101196503125244
  assert_eq(
    @typex.idcard_hide("911010198802030151", 6, 14),
    "911010********0151",
  ) // HIDE_6_14|911010198802030151
  assert_eq(
    @typex.idcard_hide("110101200002295214", 6, 14),
    "110101********5214",
  ) // HIDE_6_14|110101200002295214
  assert_eq(@typex.idcard_hide("110101650312523", 6, 14), "110101********3") // HIDE_6_14|110101650312523
  assert_eq(@typex.idcard_hide("310101800101123", 6, 14), "310101********3") // HIDE_6_14|310101800101123
  assert_eq(@typex.idcard_hide("440301990101001", 6, 14), "440301********1") // HIDE_6_14|440301990101001
  assert_eq(@typex.idcard_hide("110101000101001", 6, 14), "110101********1") // HIDE_6_14|110101000101001
  assert_eq(@typex.idcard_hide("810000650312523", 6, 14), "810000********3") // HIDE_6_14|810000650312523
  assert_eq(@typex.idcard_hide("110101990101001", 6, 14), "110101********1") // HIDE_6_14|110101990101001
  assert_eq(@typex.idcard_hide("110101650312X23", 6, 14), "110101********3") // HIDE_6_14|110101650312X23
  assert_eq(@typex.idcard_hide("990101650312523", 6, 14), "990101********3") // HIDE_6_14|990101650312523
  assert_eq(@typex.idcard_hide("110101651331523", 6, 14), "110101********3") // HIDE_6_14|110101651331523
  assert_eq(@typex.idcard_hide("110101650229523", 6, 14), "110101********3") // HIDE_6_14|110101650229523
  assert_eq(@typex.idcard_hide("11010165031252 ", 6, 14), "110101******** ") // HIDE_6_14|11010165031252 
  assert_eq(@typex.idcard_hide("11010165031252", 6, 14), "110101********") // HIDE_6_14|11010165031252
  assert_eq(@typex.idcard_hide("1101011965031252", 6, 14), "110101********52") // HIDE_6_14|1101011965031252
  assert_eq(@typex.idcard_hide("11010119650312523", 6, 14), "110101********523") // HIDE_6_14|11010119650312523
  assert_eq(
    @typex.idcard_hide("110101196503125234", 6, 14),
    "110101********5234",
  ) // HIDE_6_14|110101196503125234
  assert_eq(
    @typex.idcard_hide("1101011965031252345", 6, 14),
    "110101********52345",
  ) // HIDE_6_14|1101011965031252345
  assert_eq(
    @typex.idcard_hide("11010119650312523456", 6, 14),
    "110101********523456",
  ) // HIDE_6_14|11010119650312523456
  assert_eq(
    @typex.idcard_hide("abcdefghijklmnopqrst", 6, 14),
    "abcdef********opqrst",
  ) // HIDE_6_14|abcdefghijklmnopqrst
  assert_eq(
    @typex.idcard_hide("1101011965031252A4", 6, 14),
    "110101********52A4",
  ) // HIDE_6_14|1101011965031252A4
  assert_eq(
    @typex.idcard_hide("1101011965031252a4", 6, 14),
    "110101********52a4",
  ) // HIDE_6_14|1101011965031252a4
  assert_eq(
    @typex.idcard_hide("1101011965031252 X", 6, 14),
    "110101********52 X",
  ) // HIDE_6_14|1101011965031252 X
  assert_eq(
    @typex.idcard_hide("11010119650312523 ", 6, 14),
    "110101********523 ",
  ) // HIDE_6_14|11010119650312523 
  assert_eq(
    @typex.idcard_hide(" 110101196503125234", 6, 14),
    " 11010********25234",
  ) // HIDE_6_14| 110101196503125234
  assert_eq(@typex.idcard_hide("", 6, 14), "") // HIDE_6_14|
  assert_eq(@typex.idcard_hide(" ", 6, 14), " ") // HIDE_6_14| 
  assert_eq(@typex.idcard_hide("\t", 6, 14), "\t") // HIDE_6_14|	
  assert_eq(@typex.idcard_hide("00000000000000", 6, 14), "000000********") // HIDE_6_14|00000000000000
  assert_eq(@typex.idcard_hide("000000000000000", 6, 14), "000000********0") // HIDE_6_14|000000000000000
  assert_eq(
    @typex.idcard_hide("000000000000000000", 6, 14),
    "000000********0000",
  ) // HIDE_6_14|000000000000000000
  assert_eq(@typex.idcard_hide("999999999999999", 6, 14), "999999********9") // HIDE_6_14|999999999999999
  assert_eq(
    @typex.idcard_hide("999999999999999999", 6, 14),
    "999999********9999",
  ) // HIDE_6_14|999999999999999999
  assert_eq(
    @typex.idcard_hide("110101999999999999", 6, 14),
    "110101********9999",
  ) // HIDE_6_14|110101999999999999
  assert_eq(
    @typex.idcard_hide("110101000000005234", 6, 14),
    "110101********5234",
  ) // HIDE_6_14|110101000000005234
}
