///|
// typex 第四批第一格（DesensitizedUtil）的期望值全部由生成脚本从参照腿灌入（手打零条）。
// 腿：真 hutool-core-5.8.35.jar + JDK 17.0.14（Temp/convsrc/desens/DesensitizedLeg.java，121 行读数、零 ERR）。
// 这一批的承重事实是**两域混用**：参照的长度闸与计数用 `String.length()`（UTF-16 码元），
// 遮蔽却走 `StrUtil.hide`（码位）⇒ `PASSWORD`/`EMAIL`/`ID_CARD`/`CAR_LICENSE` 都配了 astral 夹具（🍎＝2 码元 1 码位）。
// 参照给 `null` 的档（`CLEAR_TO_NULL` 走调度器那一档）记 `None`；`clear()`/`clearToNull()` 两件常量出口不立公开件（§16.1）。

///|

///|
test "first_mask \u{4e0e} chinese_name\u{ff08}\u{53c2}\u{7167}\u{662f}\u{540c}\u{4e00}\u{6761}\u{5b9e}\u{73b0}\u{7684}\u{4e24}\u{4ef6}\u{ff09}" {
  assert_eq(@typex.desensitize_first_mask("123456789"), "1********") // FIRST_MASK|123456789
  assert_eq(
    @typex.desensitize_first_mask("\u{6bb5}\u{6b63}\u{6df3}"),
    "\u{6bb5}**",
  ) // FIRST_MASK|段正淳
  assert_eq(@typex.desensitize_first_mask("a"), "a") // FIRST_MASK|a
  assert_eq(@typex.desensitize_first_mask("\u{1f34e}\u{1f34e}x"), "\u{1f34e}**") // FIRST_MASK|🍎🍎x
  assert_eq(@typex.desensitize_first_mask("\u{1f34e}"), "\u{1f34e}") // FIRST_MASK|🍎
  assert_eq(@typex.desensitize_first_mask("  "), "") // FIRST_MASK|  
  assert_eq(@typex.desensitize_first_mask(""), "") // FIRST_MASK|

  assert_eq(@typex.desensitize_chinese_name("123456789"), "1********") // CHINESE_NAME|123456789
  assert_eq(
    @typex.desensitize_chinese_name("\u{6bb5}\u{6b63}\u{6df3}"),
    "\u{6bb5}**",
  ) // CHINESE_NAME|段正淳
  assert_eq(@typex.desensitize_chinese_name("a"), "a") // CHINESE_NAME|a
  assert_eq(
    @typex.desensitize_chinese_name("\u{1f34e}\u{1f34e}x"),
    "\u{1f34e}**",
  ) // CHINESE_NAME|🍎🍎x
  assert_eq(@typex.desensitize_chinese_name("\u{1f34e}"), "\u{1f34e}") // CHINESE_NAME|🍎
  assert_eq(@typex.desensitize_chinese_name("  "), "") // CHINESE_NAME|  
  assert_eq(@typex.desensitize_chinese_name(""), "") // CHINESE_NAME|
}

///|
test "id_card\u{ff1a}\u{4e09}\u{9053}\u{95f8}\u{7684}\u{5148}\u{540e} + \u{7801}\u{5143}\u{95f8}\u{914d}\u{7801}\u{4f4d}\u{906e}\u{853d}" {
  assert_eq(
    @typex.desensitize_id_card("51343620000320711X", 1, 2),
    "5***************1X",
  ) // ID_CARD|51343620000320711X,1,2
  assert_eq(
    @typex.desensitize_id_card("51343620000320711X", 0, 0),
    "******************",
  ) // ID_CARD|51343620000320711X,0,0
  assert_eq(
    @typex.desensitize_id_card("51343620000320711X", 7, 7),
    "5134362****320711X",
  ) // ID_CARD|51343620000320711X,7,7
  assert_eq(@typex.desensitize_id_card("12345", 3, 3), "") // ID_CARD|12345,3,3
  assert_eq(@typex.desensitize_id_card("12345", 6, 0), "") // ID_CARD|12345,6,0
  assert_eq(@typex.desensitize_id_card("12345", -1, 2), "") // ID_CARD|12345,-1,2
  assert_eq(@typex.desensitize_id_card("12345", 1, -2), "") // ID_CARD|12345,1,-2
  assert_eq(@typex.desensitize_id_card("  ", 1, 2), "") // ID_CARD|  ,1,2
  assert_eq(@typex.desensitize_id_card("", 1, 2), "") // ID_CARD|,1,2
  assert_eq(
    @typex.desensitize_id_card("\u{1f34e}51343620000320711X", 1, 2),
    "\u{1f34e}*****************X",
  ) // ID_CARD|🍎51343620000320711X,1,2
}

///|
test "\u{56fa}\u{8bdd}\u{4e0e}\u{624b}\u{673a}\u{ff1a}\u{77ed}\u{53f7}\u{65f6} start > end \u{7684}\u{6863}" {
  assert_eq(@typex.desensitize_fixed_phone("09157518479"), "0915*****79") // FIXED_PHONE|09157518479
  assert_eq(@typex.desensitize_fixed_phone("12345"), "12345") // FIXED_PHONE|12345
  assert_eq(@typex.desensitize_fixed_phone("1234"), "1234") // FIXED_PHONE|1234
  assert_eq(@typex.desensitize_fixed_phone("12"), "12") // FIXED_PHONE|12
  assert_eq(@typex.desensitize_fixed_phone(""), "") // FIXED_PHONE|
  assert_eq(@typex.desensitize_fixed_phone("  "), "") // FIXED_PHONE|  
  assert_eq(
    @typex.desensitize_fixed_phone("\u{1f34e}0915751847"),
    "\u{1f34e}091******7",
  ) // FIXED_PHONE|🍎0915751847

  assert_eq(@typex.desensitize_mobile_phone("09157518479"), "091****8479") // MOBILE_PHONE|09157518479
  assert_eq(@typex.desensitize_mobile_phone("12345"), "12345") // MOBILE_PHONE|12345
  assert_eq(@typex.desensitize_mobile_phone("1234"), "1234") // MOBILE_PHONE|1234
  assert_eq(@typex.desensitize_mobile_phone("12"), "12") // MOBILE_PHONE|12
  assert_eq(@typex.desensitize_mobile_phone(""), "") // MOBILE_PHONE|
  assert_eq(@typex.desensitize_mobile_phone("  "), "") // MOBILE_PHONE|  
  assert_eq(
    @typex.desensitize_mobile_phone("\u{1f34e}0915751847"),
    "\u{1f34e}09*****847",
  ) // MOBILE_PHONE|🍎0915751847
}

///|
test "address\u{ff1a}\u{654f}\u{611f}\u{957f}\u{5ea6}\u{5927}\u{4e8e}\u{4e32}\u{957f} \u{21d2} \u{8d1f}\u{8d77}\u{59cb}" {
  assert_eq(
    @typex.desensitize_address(
      "\u{5317}\u{4eac}\u{5e02}\u{6d77}\u{6dc0}\u{533a}\u{9a6c}\u{8fde}\u{6d3c}\u{8857}\u{9053}289\u{53f7}",
      8,
    ),
    "\u{5317}\u{4eac}\u{5e02}\u{6d77}\u{6dc0}\u{533a}\u{9a6c}********",
  ) // ADDRESS|北京市海淀区马连洼街道289号,8
  assert_eq(@typex.desensitize_address("\u{5317}\u{4eac}", 8), "**") // ADDRESS|北京,8
  assert_eq(
    @typex.desensitize_address("\u{5317}\u{4eac}", 0),
    "\u{5317}\u{4eac}",
  ) // ADDRESS|北京,0
  assert_eq(@typex.desensitize_address("\u{5317}\u{4eac}", 2), "**") // ADDRESS|北京,2
  assert_eq(@typex.desensitize_address("\u{5317}\u{4eac}", 99), "**") // ADDRESS|北京,99
  assert_eq(@typex.desensitize_address("", 8), "") // ADDRESS|,8
  assert_eq(@typex.desensitize_address("  ", 8), "") // ADDRESS|  ,8
  assert_eq(
    @typex.desensitize_address("\u{1f34e}\u{1f34e}\u{53f7}\u{8857}\u{9053}", 2),
    "\u{1f34e}\u{1f34e}\u{53f7}\u{8857}\u{9053}",
  ) // ADDRESS|🍎🍎号街道,2
}

///|
test "email\u{ff1a}'@' \u{7d22}\u{5f15}\u{6309}\u{7801}\u{5143}\u{3001}\u{906e}\u{853d}\u{6309}\u{7801}\u{4f4d}\u{ff0c}index<=1 \u{539f}\u{6837}\u{8fd4}\u{56de}" {
  assert_eq(
    @typex.desensitize_email("duandazhi-jack@gmail.com.cn"),
    "d*************@gmail.com.cn",
  ) // EMAIL|duandazhi-jack@gmail.com.cn
  assert_eq(@typex.desensitize_email("a@b.com"), "a@b.com") // EMAIL|a@b.com
  assert_eq(@typex.desensitize_email("@qq.com"), "@qq.com") // EMAIL|@qq.com
  assert_eq(@typex.desensitize_email("no-at-sign"), "no-at-sign") // EMAIL|no-at-sign
  assert_eq(@typex.desensitize_email(""), "") // EMAIL|
  assert_eq(@typex.desensitize_email("  "), "") // EMAIL|  
  assert_eq(
    @typex.desensitize_email("\u{1f34e}\u{1f34e}@x.com"),
    "\u{1f34e}***.com",
  ) // EMAIL|🍎🍎@x.com
  assert_eq(@typex.desensitize_email("x\u{1f34e}@y.com"), "x**y.com") // EMAIL|x🍎@y.com
  assert_eq(@typex.desensitize_email("ab@cd"), "a*@cd") // EMAIL|ab@cd
  assert_eq(@typex.desensitize_email("abc@"), "a**@") // EMAIL|abc@
}

///|
test "password\u{ff1a}\u{661f}\u{53f7}\u{4e2a}\u{6570}\u{6309} UTF-16 \u{7801}\u{5143}\u{6570}" {
  assert_eq(@typex.desensitize_password("1234567890"), "**********") // PASSWORD|1234567890
  assert_eq(@typex.desensitize_password("a"), "*") // PASSWORD|a
  assert_eq(@typex.desensitize_password("\u{1f34e}ab"), "****") // PASSWORD|🍎ab
  assert_eq(@typex.desensitize_password("\u{1f34e}\u{1f34e}"), "****") // PASSWORD|🍎🍎
  assert_eq(@typex.desensitize_password(""), "") // PASSWORD|
  assert_eq(@typex.desensitize_password("  "), "") // PASSWORD|  
  assert_eq(
    @typex.desensitize_password("\u{53e3}\u{4ee4}\u{53e3}\u{4ee4}"),
    "****",
  ) // PASSWORD|口令口令
}

///|
test "car_license\u{ff1a}\u{53ea}\u{52a8}\u{957f}\u{5ea6} 7 \u{4e0e} 8" {
  assert_eq(@typex.desensitize_car_license("\u{82cf}D40000"), "\u{82cf}D4***0") // CAR_LICENSE|苏D40000
  assert_eq(
    @typex.desensitize_car_license("\u{9655}A12345D"),
    "\u{9655}A1****D",
  ) // CAR_LICENSE|陕A12345D
  assert_eq(@typex.desensitize_car_license("\u{4eac}A123"), "\u{4eac}A123") // CAR_LICENSE|京A123
  assert_eq(@typex.desensitize_car_license("ABCDEFGH"), "ABC****H") // CAR_LICENSE|ABCDEFGH
  assert_eq(@typex.desensitize_car_license(""), "") // CAR_LICENSE|
  assert_eq(@typex.desensitize_car_license("  "), "") // CAR_LICENSE|  
  assert_eq(
    @typex.desensitize_car_license("\u{4eac}A1234\u{1f34e}"),
    "\u{4eac}A1****",
  ) // CAR_LICENSE|京A1234🍎
  assert_eq(
    @typex.desensitize_car_license("\u{1f34e}A12345"),
    "\u{1f34e}A1****",
  ) // CAR_LICENSE|🍎A12345
}

///|
test "bank_card\u{ff1a}blank \u{539f}\u{6837}\u{8fd4}\u{56de}\u{5165}\u{53c2}\u{3001}<9 \u{6e05}\u{6d17}\u{540e}\u{539f}\u{6837}\u{3001}\u{5176}\u{4f59}\u{6309} length%4 \u{5206}\u{6863}" {
  assert_eq(@typex.desensitize_bank_card("123456789"), "1234 **** 9") // BANK_CARD|123456789
  assert_eq(@typex.desensitize_bank_card("1234567890"), "1234 **** 90") // BANK_CARD|1234567890
  assert_eq(@typex.desensitize_bank_card("12345678901"), "1234 **** 901") // BANK_CARD|12345678901
  assert_eq(@typex.desensitize_bank_card("123456789012"), "1234 **** 9012") // BANK_CARD|123456789012
  assert_eq(
    @typex.desensitize_bank_card("1234 2222 3333 4444 6789 9"),
    "1234 **** **** **** **** 9",
  ) // BANK_CARD|1234 2222 3333 4444 6789 9
  assert_eq(
    @typex.desensitize_bank_card("1234 2222 3333 4444 6789 91"),
    "1234 **** **** **** **** 91",
  ) // BANK_CARD|1234 2222 3333 4444 6789 91
  assert_eq(
    @typex.desensitize_bank_card("1234567891234567"),
    "1234 **** **** 4567",
  ) // BANK_CARD|1234567891234567
  assert_eq(
    @typex.desensitize_bank_card("12345678912345678"),
    "1234 **** **** **** 8",
  ) // BANK_CARD|12345678912345678
  assert_eq(@typex.desensitize_bank_card("12345678"), "12345678") // BANK_CARD|12345678
  assert_eq(@typex.desensitize_bank_card("  "), "  ") // BANK_CARD|  
  assert_eq(@typex.desensitize_bank_card(""), "") // BANK_CARD|
  assert_eq(
    @typex.desensitize_bank_card("123456789123456789012345"),
    "1234 **** **** **** **** 2345",
  ) // BANK_CARD|123456789123456789012345
}

///|
test "ipv4 / ipv6\u{ff1a}\u{5b8c}\u{5168}\u{4e0d}\u{6821}\u{9a8c}\u{ff0c}\u{65e0}\u{5206}\u{9694}\u{7b26}\u{65f6}\u{6574}\u{4e32}\u{5f53}\u{7b2c}\u{4e00}\u{6bb5}" {
  assert_eq(@typex.desensitize_ipv4("192.168.1.1"), "192.*.*.*") // IPV4|192.168.1.1
  assert_eq(@typex.desensitize_ipv4("1.2"), "1.*.*.*") // IPV4|1.2
  assert_eq(@typex.desensitize_ipv4("abc"), "abc.*.*.*") // IPV4|abc
  assert_eq(@typex.desensitize_ipv4(""), ".*.*.*") // IPV4|
  assert_eq(@typex.desensitize_ipv4("  "), "  .*.*.*") // IPV4|  
  assert_eq(@typex.desensitize_ipv4("192.168.1.1.5"), "192.*.*.*") // IPV4|192.168.1.1.5
  assert_eq(
    @typex.desensitize_ipv4("2001:0db8:86a3:08d3:1319:8a2e:0370:7344"),
    "2001:0db8:86a3:08d3:1319:8a2e:0370:7344.*.*.*",
  ) // IPV4|2001:0db8:86a3:08d3:1319:8a2e:0370:7344
  assert_eq(@typex.desensitize_ipv4("fe80::1"), "fe80::1.*.*.*") // IPV4|fe80::1
  assert_eq(@typex.desensitize_ipv4("abc:def"), "abc:def.*.*.*") // IPV4|abc:def

  assert_eq(@typex.desensitize_ipv6("192.168.1.1"), "192.168.1.1:*:*:*:*:*:*:*") // IPV6|192.168.1.1
  assert_eq(@typex.desensitize_ipv6("1.2"), "1.2:*:*:*:*:*:*:*") // IPV6|1.2
  assert_eq(@typex.desensitize_ipv6("abc"), "abc:*:*:*:*:*:*:*") // IPV6|abc
  assert_eq(@typex.desensitize_ipv6(""), ":*:*:*:*:*:*:*") // IPV6|
  assert_eq(@typex.desensitize_ipv6("  "), "  :*:*:*:*:*:*:*") // IPV6|  
  assert_eq(
    @typex.desensitize_ipv6("192.168.1.1.5"),
    "192.168.1.1.5:*:*:*:*:*:*:*",
  ) // IPV6|192.168.1.1.5
  assert_eq(
    @typex.desensitize_ipv6("2001:0db8:86a3:08d3:1319:8a2e:0370:7344"),
    "2001:*:*:*:*:*:*:*",
  ) // IPV6|2001:0db8:86a3:08d3:1319:8a2e:0370:7344
  assert_eq(@typex.desensitize_ipv6("fe80::1"), "fe80:*:*:*:*:*:*:*") // IPV6|fe80::1
  assert_eq(@typex.desensitize_ipv6("abc:def"), "abc:*:*:*:*:*:*:*") // IPV6|abc:def
}

///|
test "\u{8c03}\u{5ea6}\u{5668} 15 \u{6863} + user_id \u{4e22}\u{5165}\u{53c2}\u{6863}" {
  assert_eq(@typex.desensitize_user_id(), 0L) // USER_ID|-

  assert_eq(@typex.desensitize_kind("100", "USER_ID"), Some("0")) // DP_USER_ID|100

  assert_eq(
    @typex.desensitize_kind("\u{6bb5}\u{6b63}\u{6df3}", "CHINESE_NAME"),
    Some("\u{6bb5}**"),
  ) // DP_CHINESE_NAME|段正淳

  assert_eq(
    @typex.desensitize_kind("51343620000320711X", "ID_CARD"),
    Some("5***************1X"),
  ) // DP_ID_CARD|51343620000320711X
  assert_eq(@typex.desensitize_kind("", "ID_CARD"), Some("")) // DP_ID_CARD|

  assert_eq(
    @typex.desensitize_kind("09157518479", "FIXED_PHONE"),
    Some("0915*****79"),
  ) // DP_FIXED_PHONE|09157518479

  assert_eq(
    @typex.desensitize_kind("18049531999", "MOBILE_PHONE"),
    Some("180****1999"),
  ) // DP_MOBILE_PHONE|18049531999

  assert_eq(
    @typex.desensitize_kind(
      "\u{5317}\u{4eac}\u{5e02}\u{6d77}\u{6dc0}\u{533a}\u{9a6c}\u{8fde}\u{6d3c}\u{8857}\u{9053}289\u{53f7}",
      "ADDRESS",
    ),
    Some("\u{5317}\u{4eac}\u{5e02}\u{6d77}\u{6dc0}\u{533a}\u{9a6c}********"),
  ) // DP_ADDRESS|北京市海淀区马连洼街道289号

  assert_eq(
    @typex.desensitize_kind("duandazhi-jack@gmail.com.cn", "EMAIL"),
    Some("d*************@gmail.com.cn"),
  ) // DP_EMAIL|duandazhi-jack@gmail.com.cn

  assert_eq(
    @typex.desensitize_kind("1234567890", "PASSWORD"),
    Some("**********"),
  ) // DP_PASSWORD|1234567890

  assert_eq(
    @typex.desensitize_kind("\u{82cf}D40000", "CAR_LICENSE"),
    Some("\u{82cf}D4***0"),
  ) // DP_CAR_LICENSE|苏D40000

  assert_eq(
    @typex.desensitize_kind("11011111222233333256", "BANK_CARD"),
    Some("1101 **** **** **** 3256"),
  ) // DP_BANK_CARD|11011111222233333256

  assert_eq(@typex.desensitize_kind("192.168.1.1", "IPV4"), Some("192.*.*.*")) // DP_IPV4|192.168.1.1

  assert_eq(
    @typex.desensitize_kind("2001:0db8:86a3:08d3:1319:8a2e:0370:7344", "IPV6"),
    Some("2001:*:*:*:*:*:*:*"),
  ) // DP_IPV6|2001:0db8:86a3:08d3:1319:8a2e:0370:7344

  assert_eq(
    @typex.desensitize_kind("123456789", "FIRST_MASK"),
    Some("1********"),
  ) // DP_FIRST_MASK|123456789

  assert_eq(@typex.desensitize_kind("abc", "CLEAR_TO_NULL"), Some("null")) // DP_CLEAR_TO_NULL|abc

  assert_eq(@typex.desensitize_kind("abc", "CLEAR_TO_EMPTY"), Some("")) // DP_CLEAR_TO_EMPTY|abc
  assert_eq(@typex.desensitize_kind("  ", "CLEAR_TO_EMPTY"), Some("")) // DP_CLEAR_TO_EMPTY|  
}
