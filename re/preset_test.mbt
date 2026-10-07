///|
// 本文件是生成物：`python scripts/gen_re2_test.py <leg.tsv> --test re/preset_test.mbt`
// 期望值全部来自参照腿 `scripts/RePoolLeg.java` 的机器读数与改写规则表
// `scripts/re_preset_rewrite.py`（R1~R7）的推导——手打零条。改规则或重跑腿都要重跑本生成器。
// 契约、边界与全部出处：docs/spec/10-re.md §9~§12。改任何一条期望串须单独一笔并给外部读数来源（门禁 G5）。

///|
// 三档判定的取数helper：命中给 `true`/`false`，取组给第 0 组或 `NONE`，raise 给错误形状（携带值一起进断言）
fn pshow(err : @re.ReError) -> String {
  match err {
    @re.BadPattern(s) => "BadPattern \{s}"
    @re.BadReference(s) => "BadReference \{s}"
  }
}

///|
fn pm(p : @re.RePreset, text : String) -> String {
  @re.re_match_preset(p, text).to_string() catch {
    e => pshow(e)
  }
}

///|
fn pf(p : @re.RePreset, text : String) -> String {
  try {
    match @re.re_find_preset(p, text) {
      None => "NONE"
      Some(v) => v
    }
  } catch {
    e => pshow(e)
  }
}

///|
fn pnum(text : String) -> String {
  try {
    match @re.re_first_number(text) {
      None => "NONE"
      Some(v) => v
    }
  } catch {
    e => pshow(e)
  }
}

///|
// 常量 GENERAL：参照原文经规则表 R1 得到下面的改写串；每条判定逐条取腿的读数
test "preset GENERAL" {
  assert_eq(@re.re_preset_pattern(@re.RePreset::General), "^[0-9A-Za-z_]+$")
  assert_eq(pm(@re.RePreset::General, "abc_1"), "true") // 腿 M.GENERAL 第 0 条
  assert_eq(pf(@re.RePreset::General, "abc_1"), "abc_1") // 腿 F.GENERAL 第 1 条
  assert_eq(pm(@re.RePreset::General, "12"), "true") // 腿 M.GENERAL 第 2 条
  assert_eq(pf(@re.RePreset::General, "12"), "12") // 腿 F.GENERAL 第 3 条
  assert_eq(pm(@re.RePreset::General, ""), "false") // 腿 M.GENERAL 第 4 条
  assert_eq(pf(@re.RePreset::General, ""), "NONE") // 腿 F.GENERAL 第 5 条
  assert_eq(pm(@re.RePreset::General, "ab c"), "false") // 腿 M.GENERAL 第 6 条
  assert_eq(pf(@re.RePreset::General, "ab c"), "NONE") // 腿 F.GENERAL 第 7 条
  assert_eq(pm(@re.RePreset::General, "中文"), "false") // 腿 M.GENERAL 第 8 条
  assert_eq(pf(@re.RePreset::General, "中文"), "NONE") // 腿 F.GENERAL 第 9 条
  assert_eq(pm(@re.RePreset::General, "_"), "true") // 腿 M.GENERAL 第 10 条
  assert_eq(pf(@re.RePreset::General, "_"), "_") // 腿 F.GENERAL 第 11 条
  assert_eq(pm(@re.RePreset::General, "中"), "false") // 腿 M.GENERAL 第 12 条
  assert_eq(pf(@re.RePreset::General, "中"), "NONE") // 腿 F.GENERAL 第 13 条
}

///|
// 常量 NUMBERS：参照原文经规则表 R1 得到下面的改写串；每条判定逐条取腿的读数
test "preset NUMBERS" {
  assert_eq(@re.re_preset_pattern(@re.RePreset::Numbers), "[0-9]+")
  assert_eq(pm(@re.RePreset::Numbers, "123"), "true") // 腿 M.NUMBERS 第 0 条
  assert_eq(pf(@re.RePreset::Numbers, "123"), "123") // 腿 F.NUMBERS 第 1 条
  assert_eq(pm(@re.RePreset::Numbers, "12a"), "false") // 腿 M.NUMBERS 第 2 条
  assert_eq(pf(@re.RePreset::Numbers, "12a"), "12") // 腿 F.NUMBERS 第 3 条
  assert_eq(pm(@re.RePreset::Numbers, "a1"), "false") // 腿 M.NUMBERS 第 4 条
  assert_eq(pf(@re.RePreset::Numbers, "a1"), "1") // 腿 F.NUMBERS 第 5 条
  assert_eq(pm(@re.RePreset::Numbers, ""), "false") // 腿 M.NUMBERS 第 6 条
  assert_eq(pf(@re.RePreset::Numbers, ""), "NONE") // 腿 F.NUMBERS 第 7 条
  assert_eq(pm(@re.RePreset::Numbers, "0"), "true") // 腿 M.NUMBERS 第 8 条
  assert_eq(pf(@re.RePreset::Numbers, "0"), "0") // 腿 F.NUMBERS 第 9 条
  assert_eq(pm(@re.RePreset::Numbers, "中"), "false") // 腿 M.NUMBERS 第 10 条
  assert_eq(pf(@re.RePreset::Numbers, "中"), "NONE") // 腿 F.NUMBERS 第 11 条
}

///|
// 常量 WORD：参照原文经规则表 无需改写（与参照逐字同形） 得到下面的改写串；每条判定逐条取腿的读数
test "preset WORD" {
  assert_eq(@re.re_preset_pattern(@re.RePreset::Word), "[a-zA-Z]+")
  assert_eq(pm(@re.RePreset::Word, "abc"), "true") // 腿 M.WORD 第 0 条
  assert_eq(pf(@re.RePreset::Word, "abc"), "abc") // 腿 F.WORD 第 1 条
  assert_eq(pm(@re.RePreset::Word, "ab1"), "false") // 腿 M.WORD 第 2 条
  assert_eq(pf(@re.RePreset::Word, "ab1"), "ab") // 腿 F.WORD 第 3 条
  assert_eq(pm(@re.RePreset::Word, "1"), "false") // 腿 M.WORD 第 4 条
  assert_eq(pf(@re.RePreset::Word, "1"), "NONE") // 腿 F.WORD 第 5 条
  assert_eq(pm(@re.RePreset::Word, ""), "false") // 腿 M.WORD 第 6 条
  assert_eq(pf(@re.RePreset::Word, ""), "NONE") // 腿 F.WORD 第 7 条
  assert_eq(pm(@re.RePreset::Word, "中"), "false") // 腿 M.WORD 第 8 条
  assert_eq(pf(@re.RePreset::Word, "中"), "NONE") // 腿 F.WORD 第 9 条
}

///|
// 常量 CHINESE：参照原文经规则表 R6 得到下面的改写串；每条判定逐条取腿的读数
test "preset CHINESE" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::Chinese),
    "[⺀-⻿⼀-⿟㇀-㇯㐀-䶿一-鿿豈-﫿𠀀-𪛟𪜀-𫜿𫝀-𫠟𫠠-𬺯丽-𯨟]",
  )
  assert_eq(pm(@re.RePreset::Chinese, "中"), "true") // 腿 M.CHINESE 第 0 条
  assert_eq(pf(@re.RePreset::Chinese, "中"), "中") // 腿 F.CHINESE 第 1 条
  assert_eq(pm(@re.RePreset::Chinese, "a"), "false") // 腿 M.CHINESE 第 2 条
  assert_eq(pf(@re.RePreset::Chinese, "a"), "NONE") // 腿 F.CHINESE 第 3 条
  assert_eq(pm(@re.RePreset::Chinese, "⺀"), "true") // 腿 M.CHINESE 第 4 条
  assert_eq(pf(@re.RePreset::Chinese, "⺀"), "⺀") // 腿 F.CHINESE 第 5 条
  assert_eq(pm(@re.RePreset::Chinese, "豈"), "true") // 腿 M.CHINESE 第 6 条
  assert_eq(pf(@re.RePreset::Chinese, "豈"), "豈") // 腿 F.CHINESE 第 7 条
  assert_eq(pm(@re.RePreset::Chinese, "鿿"), "true") // 腿 M.CHINESE 第 8 条
  assert_eq(pf(@re.RePreset::Chinese, "鿿"), "鿿") // 腿 F.CHINESE 第 9 条
  assert_eq(pm(@re.RePreset::Chinese, "𠀀"), "true") // 腿 M.CHINESE 第 10 条
  assert_eq(pf(@re.RePreset::Chinese, "𠀀"), "𠀀") // 腿 F.CHINESE 第 11 条
  assert_eq(pm(@re.RePreset::Chinese, "𪛟"), "true") // 腿 M.CHINESE 第 12 条
  assert_eq(pf(@re.RePreset::Chinese, "𪛟"), "𪛟") // 腿 F.CHINESE 第 13 条
  assert_eq(pm(@re.RePreset::Chinese, "𪜀"), "true") // 腿 M.CHINESE 第 14 条
  assert_eq(pf(@re.RePreset::Chinese, "𪜀"), "𪜀") // 腿 F.CHINESE 第 15 条
  assert_eq(pm(@re.RePreset::Chinese, "丽"), "true") // 腿 M.CHINESE 第 16 条
  assert_eq(pf(@re.RePreset::Chinese, "丽"), "丽") // 腿 F.CHINESE 第 17 条
  assert_eq(pm(@re.RePreset::Chinese, "𯨠"), "false") // 腿 M.CHINESE 第 18 条
  assert_eq(pf(@re.RePreset::Chinese, "𯨠"), "NONE") // 腿 F.CHINESE 第 19 条
  assert_eq(pm(@re.RePreset::Chinese, " "), "false") // 腿 M.CHINESE 第 20 条
  assert_eq(pf(@re.RePreset::Chinese, " "), "NONE") // 腿 F.CHINESE 第 21 条
}

///|
// 常量 CHINESES：参照原文经规则表 R6 得到下面的改写串；每条判定逐条取腿的读数
test "preset CHINESES" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::Chineses),
    "[⺀-⻿⼀-⿟㇀-㇯㐀-䶿一-鿿豈-﫿𠀀-𪛟𪜀-𫜿𫝀-𫠟𫠠-𬺯丽-𯨟]+",
  )
  assert_eq(pm(@re.RePreset::Chineses, "中文"), "true") // 腿 M.CHINESES 第 0 条
  assert_eq(pf(@re.RePreset::Chineses, "中文"), "中文") // 腿 F.CHINESES 第 1 条
  assert_eq(pm(@re.RePreset::Chineses, "中a"), "false") // 腿 M.CHINESES 第 2 条
  assert_eq(pf(@re.RePreset::Chineses, "中a"), "中") // 腿 F.CHINESES 第 3 条
  assert_eq(pm(@re.RePreset::Chineses, "𠀀𠀀"), "true") // 腿 M.CHINESES 第 4 条
  assert_eq(pf(@re.RePreset::Chineses, "𠀀𠀀"), "𠀀𠀀") // 腿 F.CHINESES 第 5 条
  assert_eq(pm(@re.RePreset::Chineses, ""), "false") // 腿 M.CHINESES 第 6 条
  assert_eq(pf(@re.RePreset::Chineses, ""), "NONE") // 腿 F.CHINESES 第 7 条
}

///|
// 常量 GROUP_VAR：参照原文经规则表 R1 得到下面的改写串；每条判定逐条取腿的读数
test "preset GROUP_VAR" {
  assert_eq(@re.re_preset_pattern(@re.RePreset::GroupVar), "\\$([0-9]+)")
  assert_eq(pm(@re.RePreset::GroupVar, "$12"), "true") // 腿 M.GROUP_VAR 第 0 条
  assert_eq(pf(@re.RePreset::GroupVar, "$12"), "$12") // 腿 F.GROUP_VAR 第 1 条
  assert_eq(pm(@re.RePreset::GroupVar, "x12"), "false") // 腿 M.GROUP_VAR 第 2 条
  assert_eq(pf(@re.RePreset::GroupVar, "x12"), "NONE") // 腿 F.GROUP_VAR 第 3 条
  assert_eq(pm(@re.RePreset::GroupVar, "$"), "false") // 腿 M.GROUP_VAR 第 4 条
  assert_eq(pf(@re.RePreset::GroupVar, "$"), "NONE") // 腿 F.GROUP_VAR 第 5 条
  assert_eq(pm(@re.RePreset::GroupVar, "$0"), "true") // 腿 M.GROUP_VAR 第 6 条
  assert_eq(pf(@re.RePreset::GroupVar, "$0"), "$0") // 腿 F.GROUP_VAR 第 7 条
  assert_eq(pm(@re.RePreset::GroupVar, "12"), "false") // 腿 M.GROUP_VAR 第 8 条
  assert_eq(pf(@re.RePreset::GroupVar, "12"), "NONE") // 腿 F.GROUP_VAR 第 9 条
}

///|
// 常量 IPV4：参照原文经规则表 R1 得到下面的改写串；每条判定逐条取腿的读数
test "preset IPV4" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::Ipv4),
    "^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]?[0-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]?[0-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]?[0-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]?[0-9])$",
  )
  assert_eq(pm(@re.RePreset::Ipv4, "1.2.3.4"), "true") // 腿 M.IPV4 第 0 条
  assert_eq(pf(@re.RePreset::Ipv4, "1.2.3.4"), "1.2.3.4") // 腿 F.IPV4 第 1 条
  assert_eq(pm(@re.RePreset::Ipv4, "255.255.255.255"), "true") // 腿 M.IPV4 第 2 条
  assert_eq(pf(@re.RePreset::Ipv4, "255.255.255.255"), "255.255.255.255") // 腿 F.IPV4 第 3 条
  assert_eq(pm(@re.RePreset::Ipv4, "0.0.0.0"), "true") // 腿 M.IPV4 第 4 条
  assert_eq(pf(@re.RePreset::Ipv4, "0.0.0.0"), "0.0.0.0") // 腿 F.IPV4 第 5 条
  assert_eq(pm(@re.RePreset::Ipv4, "256.1.1.1"), "false") // 腿 M.IPV4 第 6 条
  assert_eq(pf(@re.RePreset::Ipv4, "256.1.1.1"), "NONE") // 腿 F.IPV4 第 7 条
  assert_eq(pm(@re.RePreset::Ipv4, "1.2.3"), "false") // 腿 M.IPV4 第 8 条
  assert_eq(pf(@re.RePreset::Ipv4, "1.2.3"), "NONE") // 腿 F.IPV4 第 9 条
  assert_eq(pm(@re.RePreset::Ipv4, "01.2.3.4"), "true") // 腿 M.IPV4 第 10 条
  assert_eq(pf(@re.RePreset::Ipv4, "01.2.3.4"), "01.2.3.4") // 腿 F.IPV4 第 11 条
  assert_eq(pm(@re.RePreset::Ipv4, "1.2.3.4.5"), "false") // 腿 M.IPV4 第 12 条
  assert_eq(pf(@re.RePreset::Ipv4, "1.2.3.4.5"), "NONE") // 腿 F.IPV4 第 13 条
  assert_eq(pm(@re.RePreset::Ipv4, "x1.2.3.4"), "false") // 腿 M.IPV4 第 14 条
  assert_eq(pf(@re.RePreset::Ipv4, "x1.2.3.4"), "NONE") // 腿 F.IPV4 第 15 条
}

///|
// 常量 IPV6：参照原文经规则表 无需改写（与参照逐字同形） 得到下面的改写串；每条判定逐条取腿的读数
test "preset IPV6" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::Ipv6),
    "(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]+|::(ffff(:0{1,4})?:)?((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9]))",
  )
  assert_eq(pm(@re.RePreset::Ipv6, "::1"), "true") // 腿 M.IPV6 第 0 条
  assert_eq(pf(@re.RePreset::Ipv6, "::1"), "::1") // 腿 F.IPV6 第 1 条
  assert_eq(pm(@re.RePreset::Ipv6, "2001:db8::1"), "true") // 腿 M.IPV6 第 2 条
  assert_eq(pf(@re.RePreset::Ipv6, "2001:db8::1"), "2001:db8::") // 腿 F.IPV6 第 3 条
  assert_eq(pm(@re.RePreset::Ipv6, "fe80::1%eth0"), "true") // 腿 M.IPV6 第 4 条
  assert_eq(pf(@re.RePreset::Ipv6, "fe80::1%eth0"), "fe80::") // 腿 F.IPV6 第 5 条
  assert_eq(pm(@re.RePreset::Ipv6, "::ffff:1.2.3.4"), "true") // 腿 M.IPV6 第 6 条
  assert_eq(pf(@re.RePreset::Ipv6, "::ffff:1.2.3.4"), "::ffff:1") // 腿 F.IPV6 第 7 条
  assert_eq(pm(@re.RePreset::Ipv6, "12345::"), "false") // 腿 M.IPV6 第 8 条
  assert_eq(pf(@re.RePreset::Ipv6, "12345::"), "2345::") // 腿 F.IPV6 第 9 条
  assert_eq(pm(@re.RePreset::Ipv6, "::"), "true") // 腿 M.IPV6 第 10 条
  assert_eq(pf(@re.RePreset::Ipv6, "::"), "::") // 腿 F.IPV6 第 11 条
  assert_eq(pm(@re.RePreset::Ipv6, "1:2:3:4:5:6:7:8"), "true") // 腿 M.IPV6 第 12 条
  assert_eq(pf(@re.RePreset::Ipv6, "1:2:3:4:5:6:7:8"), "1:2:3:4:5:6:7:8") // 腿 F.IPV6 第 13 条
  assert_eq(pm(@re.RePreset::Ipv6, "1:2:3:4:5:6:7:8:9"), "false") // 腿 M.IPV6 第 14 条
  assert_eq(pf(@re.RePreset::Ipv6, "1:2:3:4:5:6:7:8:9"), "1:2:3:4:5:6:7:8") // 腿 F.IPV6 第 15 条
}

///|
// 常量 MONEY：参照原文经规则表 R1 得到下面的改写串；每条判定逐条取腿的读数
test "preset MONEY" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::Money),
    "^([0-9]+(?:\\.[0-9]+)?)$",
  )
  assert_eq(pm(@re.RePreset::Money, "12.30"), "true") // 腿 M.MONEY 第 0 条
  assert_eq(pf(@re.RePreset::Money, "12.30"), "12.30") // 腿 F.MONEY 第 1 条
  assert_eq(pm(@re.RePreset::Money, "12"), "true") // 腿 M.MONEY 第 2 条
  assert_eq(pf(@re.RePreset::Money, "12"), "12") // 腿 F.MONEY 第 3 条
  assert_eq(pm(@re.RePreset::Money, "12."), "false") // 腿 M.MONEY 第 4 条
  assert_eq(pf(@re.RePreset::Money, "12."), "NONE") // 腿 F.MONEY 第 5 条
  assert_eq(pm(@re.RePreset::Money, "-12"), "false") // 腿 M.MONEY 第 6 条
  assert_eq(pf(@re.RePreset::Money, "-12"), "NONE") // 腿 F.MONEY 第 7 条
  assert_eq(pm(@re.RePreset::Money, "1e3"), "false") // 腿 M.MONEY 第 8 条
  assert_eq(pf(@re.RePreset::Money, "1e3"), "NONE") // 腿 F.MONEY 第 9 条
  assert_eq(pm(@re.RePreset::Money, "."), "false") // 腿 M.MONEY 第 10 条
  assert_eq(pf(@re.RePreset::Money, "."), "NONE") // 腿 F.MONEY 第 11 条
  assert_eq(pm(@re.RePreset::Money, "0.0"), "true") // 腿 M.MONEY 第 12 条
  assert_eq(pf(@re.RePreset::Money, "0.0"), "0.0") // 腿 F.MONEY 第 13 条
}

///|
// 常量 EMAIL：参照原文经规则表 R2+R4+R5+R7 得到下面的改写串；每条判定逐条取腿的读数
test "preset EMAIL" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::Email),
    "(?i:(?:[a-z0-9!#$%&'*+/=?^_`{|}~\\-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~\\-]+)*|\"(?:[\\u0001-\\u0008\\u000b\\u000c\\u000e-\\u001f\\u0021\\u0023-\\u005b\\u005d-\\u007f]|\\\\[\\u0001-\\u0009\\u000b\\u000c\\u000e-\\u007f])*\")@(?:(?:[a-z0-9](?:[a-z0-9\\-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9\\-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9\\-]*[a-z0-9]:(?:[\\u0001-\\u0008\\u000b\\u000c\\u000e-\\u001f\\u0021-\\u005a\\u0053-\\u007f]|\\\\[\\u0001-\\u0009\\u000b\\u000c\\u000e-\\u007f])+)\\]))",
  )
  assert_eq(pm(@re.RePreset::Email, "a@b.co"), "true") // 腿 M.EMAIL 第 0 条
  assert_eq(pf(@re.RePreset::Email, "a@b.co"), "a@b.co") // 腿 F.EMAIL 第 1 条
  assert_eq(pm(@re.RePreset::Email, "A@B.CO"), "true") // 腿 M.EMAIL 第 2 条
  assert_eq(pf(@re.RePreset::Email, "A@B.CO"), "A@B.CO") // 腿 F.EMAIL 第 3 条
  assert_eq(pm(@re.RePreset::Email, "a@b"), "false") // 腿 M.EMAIL 第 4 条
  assert_eq(pf(@re.RePreset::Email, "a@b"), "NONE") // 腿 F.EMAIL 第 5 条
  assert_eq(pm(@re.RePreset::Email, "中文@a.com"), "false") // 腿 M.EMAIL 第 6 条
  assert_eq(pf(@re.RePreset::Email, "中文@a.com"), "NONE") // 腿 F.EMAIL 第 7 条
  assert_eq(pm(@re.RePreset::Email, "x.y@z.cn"), "true") // 腿 M.EMAIL 第 8 条
  assert_eq(pf(@re.RePreset::Email, "x.y@z.cn"), "x.y@z.cn") // 腿 F.EMAIL 第 9 条
  assert_eq(pm(@re.RePreset::Email, "a b@c.com"), "false") // 腿 M.EMAIL 第 10 条
  assert_eq(pf(@re.RePreset::Email, "a b@c.com"), "b@c.com") // 腿 F.EMAIL 第 11 条
  assert_eq(pm(@re.RePreset::Email, "\"a b\"@c.com"), "false") // 腿 M.EMAIL 第 12 条
  assert_eq(pf(@re.RePreset::Email, "\"a b\"@c.com"), "NONE") // 腿 F.EMAIL 第 13 条
  assert_eq(pm(@re.RePreset::Email, "a@b.co."), "false") // 腿 M.EMAIL 第 14 条
  assert_eq(pf(@re.RePreset::Email, "a@b.co."), "a@b.co") // 腿 F.EMAIL 第 15 条
}

///|
// 常量 EMAIL_WITH_CHINESE：参照原文经规则表 R2+R4+R5+R7 得到下面的改写串；每条判定逐条取腿的读数
test "preset EMAIL_WITH_CHINESE" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::EmailWithChinese),
    "(?i:(?:[a-z0-9\\u4e00-\\u9fa5!#$%&'*+/=?^_`{|}~\\-]+(?:\\.[a-z0-9\\u4e00-\\u9fa5!#$%&'*+/=?^_`{|}~\\-]+)*|\"(?:[\\u0001-\\u0008\\u000b\\u000c\\u000e-\\u001f\\u0021\\u0023-\\u005b\\u005d-\\u007f]|\\\\[\\u0001-\\u0009\\u000b\\u000c\\u000e-\\u007f])*\")@(?:(?:[a-z0-9\\u4e00-\\u9fa5](?:[a-z0-9\\u4e00-\\u9fa5\\-]*[a-z0-9\\u4e00-\\u9fa5])?\\.)+[a-z0-9\\u4e00-\\u9fa5](?:[a-z0-9\\u4e00-\\u9fa5\\-]*[a-z0-9\\u4e00-\\u9fa5])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9\\u4e00-\\u9fa5\\-]*[a-z0-9\\u4e00-\\u9fa5]:(?:[\\u0001-\\u0008\\u000b\\u000c\\u000e-\\u001f\\u0021-\\u005a\\u0053-\\u007f]|\\\\[\\u0001-\\u0009\\u000b\\u000c\\u000e-\\u007f])+)\\]))",
  )
  assert_eq(pm(@re.RePreset::EmailWithChinese, "中文@b.co"), "true") // 腿 M.EMAIL_WITH_CHINESE 第 0 条
  assert_eq(pf(@re.RePreset::EmailWithChinese, "中文@b.co"), "中文@b.co") // 腿 F.EMAIL_WITH_CHINESE 第 1 条
  assert_eq(pm(@re.RePreset::EmailWithChinese, "a@b.co"), "true") // 腿 M.EMAIL_WITH_CHINESE 第 2 条
  assert_eq(pf(@re.RePreset::EmailWithChinese, "a@b.co"), "a@b.co") // 腿 F.EMAIL_WITH_CHINESE 第 3 条
  assert_eq(pm(@re.RePreset::EmailWithChinese, "A@B.CO"), "true") // 腿 M.EMAIL_WITH_CHINESE 第 4 条
  assert_eq(pf(@re.RePreset::EmailWithChinese, "A@B.CO"), "A@B.CO") // 腿 F.EMAIL_WITH_CHINESE 第 5 条
  assert_eq(pm(@re.RePreset::EmailWithChinese, "a@b"), "false") // 腿 M.EMAIL_WITH_CHINESE 第 6 条
  assert_eq(pf(@re.RePreset::EmailWithChinese, "a@b"), "NONE") // 腿 F.EMAIL_WITH_CHINESE 第 7 条
}

///|
// 常量 ZIP_CODE：参照原文经规则表 R1 得到下面的改写串；每条判定逐条取腿的读数
test "preset ZIP_CODE" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::ZipCode),
    "^(0[1-7]|1[0-356]|2[0-7]|3[0-6]|4[0-7]|5[0-7]|6[0-7]|7[0-5]|8[0-9]|9[0-8])[0-9]{4}|99907[78]$",
  )
  assert_eq(pm(@re.RePreset::ZipCode, "100000"), "true") // 腿 M.ZIP_CODE 第 0 条
  assert_eq(pf(@re.RePreset::ZipCode, "100000"), "100000") // 腿 F.ZIP_CODE 第 1 条
  assert_eq(pm(@re.RePreset::ZipCode, "999077"), "true") // 腿 M.ZIP_CODE 第 2 条
  assert_eq(pf(@re.RePreset::ZipCode, "999077"), "999077") // 腿 F.ZIP_CODE 第 3 条
  assert_eq(pm(@re.RePreset::ZipCode, "999078"), "true") // 腿 M.ZIP_CODE 第 4 条
  assert_eq(pf(@re.RePreset::ZipCode, "999078"), "999078") // 腿 F.ZIP_CODE 第 5 条
  assert_eq(pm(@re.RePreset::ZipCode, "999079"), "false") // 腿 M.ZIP_CODE 第 6 条
  assert_eq(pf(@re.RePreset::ZipCode, "999079"), "NONE") // 腿 F.ZIP_CODE 第 7 条
  assert_eq(pm(@re.RePreset::ZipCode, "010000"), "true") // 腿 M.ZIP_CODE 第 8 条
  assert_eq(pf(@re.RePreset::ZipCode, "010000"), "010000") // 腿 F.ZIP_CODE 第 9 条
  assert_eq(pm(@re.RePreset::ZipCode, "12345"), "false") // 腿 M.ZIP_CODE 第 10 条
  assert_eq(pf(@re.RePreset::ZipCode, "12345"), "NONE") // 腿 F.ZIP_CODE 第 11 条
  assert_eq(pm(@re.RePreset::ZipCode, "99907"), "false") // 腿 M.ZIP_CODE 第 12 条
  assert_eq(pf(@re.RePreset::ZipCode, "99907"), "NONE") // 腿 F.ZIP_CODE 第 13 条
  assert_eq(pm(@re.RePreset::ZipCode, "1000000"), "false") // 腿 M.ZIP_CODE 第 14 条
  assert_eq(pf(@re.RePreset::ZipCode, "1000000"), "100000") // 腿 F.ZIP_CODE 第 15 条
}

///|
// 常量 BIRTHDAY：参照原文经规则表 R1 得到下面的改写串；每条判定逐条取腿的读数
test "preset BIRTHDAY" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::Birthday),
    "^([0-9]{2,4})([/\\-.年]?)([0-9]{1,2})([/\\-.月]?)([0-9]{1,2})日?$",
  )
  assert_eq(pm(@re.RePreset::Birthday, "1991-01-01"), "true") // 腿 M.BIRTHDAY 第 0 条
  assert_eq(pf(@re.RePreset::Birthday, "1991-01-01"), "1991-01-01") // 腿 F.BIRTHDAY 第 1 条
  assert_eq(pm(@re.RePreset::Birthday, "1991年1月1日"), "true") // 腿 M.BIRTHDAY 第 2 条
  assert_eq(pf(@re.RePreset::Birthday, "1991年1月1日"), "1991年1月1日") // 腿 F.BIRTHDAY 第 3 条
  assert_eq(pm(@re.RePreset::Birthday, "91.1.1"), "true") // 腿 M.BIRTHDAY 第 4 条
  assert_eq(pf(@re.RePreset::Birthday, "91.1.1"), "91.1.1") // 腿 F.BIRTHDAY 第 5 条
  assert_eq(pm(@re.RePreset::Birthday, "1991-01-0"), "true") // 腿 M.BIRTHDAY 第 6 条
  assert_eq(pf(@re.RePreset::Birthday, "1991-01-0"), "1991-01-0") // 腿 F.BIRTHDAY 第 7 条
  assert_eq(pm(@re.RePreset::Birthday, "1991/13/1"), "true") // 腿 M.BIRTHDAY 第 8 条
  assert_eq(pf(@re.RePreset::Birthday, "1991/13/1"), "1991/13/1") // 腿 F.BIRTHDAY 第 9 条
  assert_eq(pm(@re.RePreset::Birthday, "中"), "false") // 腿 M.BIRTHDAY 第 10 条
  assert_eq(pf(@re.RePreset::Birthday, "中"), "NONE") // 腿 F.BIRTHDAY 第 11 条
}

///|
// 常量 URI：参照原文经规则表 无需改写（与参照逐字同形） 得到下面的改写串；每条判定逐条取腿的读数
test "preset URI" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::Uri),
    "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?",
  )
  assert_eq(pm(@re.RePreset::Uri, "a/b"), "true") // 腿 M.URI 第 0 条
  assert_eq(pf(@re.RePreset::Uri, "a/b"), "a/b") // 腿 F.URI 第 1 条
  assert_eq(pm(@re.RePreset::Uri, ""), "true") // 腿 M.URI 第 2 条
  assert_eq(pf(@re.RePreset::Uri, ""), "") // 腿 F.URI 第 3 条
  assert_eq(pm(@re.RePreset::Uri, "http://x/y?z#w"), "true") // 腿 M.URI 第 4 条
  assert_eq(pf(@re.RePreset::Uri, "http://x/y?z#w"), "http://x/y?z#w") // 腿 F.URI 第 5 条
  assert_eq(pm(@re.RePreset::Uri, "urn:x:x"), "true") // 腿 M.URI 第 6 条
  assert_eq(pf(@re.RePreset::Uri, "urn:x:x"), "urn:x:x") // 腿 F.URI 第 7 条
  assert_eq(pm(@re.RePreset::Uri, "中"), "true") // 腿 M.URI 第 8 条
  assert_eq(pf(@re.RePreset::Uri, "中"), "中") // 腿 F.URI 第 9 条
}

///|
// 常量 URL：参照原文经规则表 R1+R4 得到下面的改写串；每条判定逐条取腿的读数
test "preset URL" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::Url),
    "[a-zA-Z]+://[0-9A-Za-z_\\-+&@#/%?=~_|!:,.;]*[0-9A-Za-z_\\-+&@#/%=~_|]",
  )
  assert_eq(pm(@re.RePreset::Url, "http://a"), "true") // 腿 M.URL 第 0 条
  assert_eq(pf(@re.RePreset::Url, "http://a"), "http://a") // 腿 F.URL 第 1 条
  assert_eq(pm(@re.RePreset::Url, "://a"), "false") // 腿 M.URL 第 2 条
  assert_eq(pf(@re.RePreset::Url, "://a"), "NONE") // 腿 F.URL 第 3 条
  assert_eq(pm(@re.RePreset::Url, "ftp://x.cn/p?a=b#c"), "true") // 腿 M.URL 第 4 条
  assert_eq(pf(@re.RePreset::Url, "ftp://x.cn/p?a=b#c"), "ftp://x.cn/p?a=b#c") // 腿 F.URL 第 5 条
  assert_eq(pm(@re.RePreset::Url, "HTTP://A"), "true") // 腿 M.URL 第 6 条
  assert_eq(pf(@re.RePreset::Url, "HTTP://A"), "HTTP://A") // 腿 F.URL 第 7 条
  assert_eq(pm(@re.RePreset::Url, "http://"), "false") // 腿 M.URL 第 8 条
  assert_eq(pf(@re.RePreset::Url, "http://"), "NONE") // 腿 F.URL 第 9 条
  assert_eq(pm(@re.RePreset::Url, "a://b"), "true") // 腿 M.URL 第 10 条
  assert_eq(pf(@re.RePreset::Url, "a://b"), "a://b") // 腿 F.URL 第 11 条
}

///|
// 常量 URL_HTTP：参照原文经规则表 R1+R4+R5 得到下面的改写串；每条判定逐条取腿的读数
test "preset URL_HTTP" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::UrlHttp),
    "(?i:(https?|ftp|file)://[0-9A-Za-z_\\-+&@#/%?=~_|!:,.;]*[0-9A-Za-z_\\-+&@#/%=~_|])",
  )
  assert_eq(pm(@re.RePreset::UrlHttp, "https://x.cn/a"), "true") // 腿 M.URL_HTTP 第 0 条
  assert_eq(pf(@re.RePreset::UrlHttp, "https://x.cn/a"), "https://x.cn/a") // 腿 F.URL_HTTP 第 1 条
  assert_eq(pm(@re.RePreset::UrlHttp, "x.cn"), "false") // 腿 M.URL_HTTP 第 2 条
  assert_eq(pf(@re.RePreset::UrlHttp, "x.cn"), "NONE") // 腿 F.URL_HTTP 第 3 条
  assert_eq(pm(@re.RePreset::UrlHttp, "HTTPS://X.CN"), "true") // 腿 M.URL_HTTP 第 4 条
  assert_eq(pf(@re.RePreset::UrlHttp, "HTTPS://X.CN"), "HTTPS://X.CN") // 腿 F.URL_HTTP 第 5 条
  assert_eq(pm(@re.RePreset::UrlHttp, "file:///a"), "true") // 腿 M.URL_HTTP 第 6 条
  assert_eq(pf(@re.RePreset::UrlHttp, "file:///a"), "file:///a") // 腿 F.URL_HTTP 第 7 条
  assert_eq(pm(@re.RePreset::UrlHttp, "mailto:a@b"), "false") // 腿 M.URL_HTTP 第 8 条
  assert_eq(pf(@re.RePreset::UrlHttp, "mailto:a@b"), "NONE") // 腿 F.URL_HTTP 第 9 条
}

///|
// 常量 GENERAL_WITH_CHINESE：参照原文经规则表 R1 得到下面的改写串；每条判定逐条取腿的读数
test "preset GENERAL_WITH_CHINESE" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::GeneralWithChinese),
    "^[一-鿿0-9A-Za-z_]+$",
  )
  assert_eq(pm(@re.RePreset::GeneralWithChinese, "中文_1"), "true") // 腿 M.GENERAL_WITH_CHINESE 第 0 条
  assert_eq(pf(@re.RePreset::GeneralWithChinese, "中文_1"), "中文_1") // 腿 F.GENERAL_WITH_CHINESE 第 1 条
  assert_eq(pm(@re.RePreset::GeneralWithChinese, "abc"), "true") // 腿 M.GENERAL_WITH_CHINESE 第 2 条
  assert_eq(pf(@re.RePreset::GeneralWithChinese, "abc"), "abc") // 腿 F.GENERAL_WITH_CHINESE 第 3 条
  assert_eq(pm(@re.RePreset::GeneralWithChinese, "a b"), "false") // 腿 M.GENERAL_WITH_CHINESE 第 4 条
  assert_eq(pf(@re.RePreset::GeneralWithChinese, "a b"), "NONE") // 腿 F.GENERAL_WITH_CHINESE 第 5 条
  assert_eq(pm(@re.RePreset::GeneralWithChinese, "中 文"), "false") // 腿 M.GENERAL_WITH_CHINESE 第 6 条
  assert_eq(pf(@re.RePreset::GeneralWithChinese, "中 文"), "NONE") // 腿 F.GENERAL_WITH_CHINESE 第 7 条
  assert_eq(pm(@re.RePreset::GeneralWithChinese, "12"), "true") // 腿 M.GENERAL_WITH_CHINESE 第 8 条
  assert_eq(pf(@re.RePreset::GeneralWithChinese, "12"), "12") // 腿 F.GENERAL_WITH_CHINESE 第 9 条
  assert_eq(pm(@re.RePreset::GeneralWithChinese, ""), "false") // 腿 M.GENERAL_WITH_CHINESE 第 10 条
  assert_eq(pf(@re.RePreset::GeneralWithChinese, ""), "NONE") // 腿 F.GENERAL_WITH_CHINESE 第 11 条
}

///|
// 常量 UUID：参照原文经规则表 R5 得到下面的改写串；每条判定逐条取腿的读数
test "preset UUID" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::Uuid),
    "(?i:^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$)",
  )
  assert_eq(
    pm(@re.RePreset::Uuid, "6ba7b810-9dad-11d1-80b4-00c04fd430c8"),
    "true",
  ) // 腿 M.UUID 第 0 条
  assert_eq(
    pf(@re.RePreset::Uuid, "6ba7b810-9dad-11d1-80b4-00c04fd430c8"),
    "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
  ) // 腿 F.UUID 第 1 条
  assert_eq(
    pm(@re.RePreset::Uuid, "6BA7B810-9DAD-11D1-80B4-00C04FD430C8"),
    "true",
  ) // 腿 M.UUID 第 2 条
  assert_eq(
    pf(@re.RePreset::Uuid, "6BA7B810-9DAD-11D1-80B4-00C04FD430C8"),
    "6BA7B810-9DAD-11D1-80B4-00C04FD430C8",
  ) // 腿 F.UUID 第 3 条
  assert_eq(
    pm(@re.RePreset::Uuid, "6ba7b810-9dad-11d1-80b4-00c04fd430c"),
    "false",
  ) // 腿 M.UUID 第 4 条
  assert_eq(
    pf(@re.RePreset::Uuid, "6ba7b810-9dad-11d1-80b4-00c04fd430c"),
    "NONE",
  ) // 腿 F.UUID 第 5 条
  assert_eq(pm(@re.RePreset::Uuid, "6ba7b8109dad11d180b400c04fd430c8"), "false") // 腿 M.UUID 第 6 条
  assert_eq(pf(@re.RePreset::Uuid, "6ba7b8109dad11d180b400c04fd430c8"), "NONE") // 腿 F.UUID 第 7 条
  assert_eq(
    pm(@re.RePreset::Uuid, "gba7b810-9dad-11d1-80b4-00c04fd430c8"),
    "false",
  ) // 腿 M.UUID 第 8 条
  assert_eq(
    pf(@re.RePreset::Uuid, "gba7b810-9dad-11d1-80b4-00c04fd430c8"),
    "NONE",
  ) // 腿 F.UUID 第 9 条
}

///|
// 常量 UUID_SIMPLE：参照原文经规则表 无需改写（与参照逐字同形） 得到下面的改写串；每条判定逐条取腿的读数
test "preset UUID_SIMPLE" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::UuidSimple),
    "^[0-9a-fA-F]{32}$",
  )
  assert_eq(
    pm(@re.RePreset::UuidSimple, "6ba7b8109dad11d180b400c04fd430c8"),
    "true",
  ) // 腿 M.UUID_SIMPLE 第 0 条
  assert_eq(
    pf(@re.RePreset::UuidSimple, "6ba7b8109dad11d180b400c04fd430c8"),
    "6ba7b8109dad11d180b400c04fd430c8",
  ) // 腿 F.UUID_SIMPLE 第 1 条
  assert_eq(
    pm(@re.RePreset::UuidSimple, "6BA7B8109DAD11D180B400C04FD430C8"),
    "true",
  ) // 腿 M.UUID_SIMPLE 第 2 条
  assert_eq(
    pf(@re.RePreset::UuidSimple, "6BA7B8109DAD11D180B400C04FD430C8"),
    "6BA7B8109DAD11D180B400C04FD430C8",
  ) // 腿 F.UUID_SIMPLE 第 3 条
  assert_eq(pm(@re.RePreset::UuidSimple, "6ba7b810"), "false") // 腿 M.UUID_SIMPLE 第 4 条
  assert_eq(pf(@re.RePreset::UuidSimple, "6ba7b810"), "NONE") // 腿 F.UUID_SIMPLE 第 5 条
  assert_eq(
    pm(@re.RePreset::UuidSimple, "6ba7b8109dad11d180b400c04fd430c8g"),
    "false",
  ) // 腿 M.UUID_SIMPLE 第 6 条
  assert_eq(
    pf(@re.RePreset::UuidSimple, "6ba7b8109dad11d180b400c04fd430c8g"),
    "NONE",
  ) // 腿 F.UUID_SIMPLE 第 7 条
}

///|
// 常量 MAC_ADDRESS：参照原文经规则表 R1+R3+R4+R5 得到下面的改写串；每条判定逐条取腿的读数
test "preset MAC_ADDRESS" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::MacAddress),
    "(?i:((?:[a-fA-F0-9]{1,2}[\\-:]){5}[a-fA-F0-9]{1,2})|((?:[a-fA-F0-9]{1,4}[.]){2}[a-fA-F0-9]{1,4})|[a-fA-F0-9]{12}|0x([0-9]{12}).+ETHER)",
  )
  assert_eq(pm(@re.RePreset::MacAddress, "00-1A-2B-3C-4D-5E"), "true") // 腿 M.MAC_ADDRESS 第 0 条
  assert_eq(
    pf(@re.RePreset::MacAddress, "00-1A-2B-3C-4D-5E"),
    "00-1A-2B-3C-4D-5E",
  ) // 腿 F.MAC_ADDRESS 第 1 条
  assert_eq(pm(@re.RePreset::MacAddress, "00:1a:2b:3c:4d:5e"), "true") // 腿 M.MAC_ADDRESS 第 2 条
  assert_eq(
    pf(@re.RePreset::MacAddress, "00:1a:2b:3c:4d:5e"),
    "00:1a:2b:3c:4d:5e",
  ) // 腿 F.MAC_ADDRESS 第 3 条
  assert_eq(pm(@re.RePreset::MacAddress, "001A.2B3C.4D5E"), "true") // 腿 M.MAC_ADDRESS 第 4 条
  assert_eq(pf(@re.RePreset::MacAddress, "001A.2B3C.4D5E"), "001A.2B3C.4D5E") // 腿 F.MAC_ADDRESS 第 5 条
  assert_eq(pm(@re.RePreset::MacAddress, "001122334455"), "true") // 腿 M.MAC_ADDRESS 第 6 条
  assert_eq(pf(@re.RePreset::MacAddress, "001122334455"), "001122334455") // 腿 F.MAC_ADDRESS 第 7 条
  assert_eq(pm(@re.RePreset::MacAddress, "0x123456789012 abcETHER"), "true") // 腿 M.MAC_ADDRESS 第 8 条
  assert_eq(
    pf(@re.RePreset::MacAddress, "0x123456789012 abcETHER"),
    "0x123456789012 abcETHER",
  ) // 腿 F.MAC_ADDRESS 第 9 条
  assert_eq(pm(@re.RePreset::MacAddress, "00-1A-2B-3C-4D"), "false") // 腿 M.MAC_ADDRESS 第 10 条
  assert_eq(pf(@re.RePreset::MacAddress, "00-1A-2B-3C-4D"), "NONE") // 腿 F.MAC_ADDRESS 第 11 条
  assert_eq(pm(@re.RePreset::MacAddress, "zz:1a:2b:3c:4d:5e"), "false") // 腿 M.MAC_ADDRESS 第 12 条
  assert_eq(pf(@re.RePreset::MacAddress, "zz:1a:2b:3c:4d:5e"), "NONE") // 腿 F.MAC_ADDRESS 第 13 条
}

///|
// 常量 HEX：参照原文经规则表 无需改写（与参照逐字同形） 得到下面的改写串；每条判定逐条取腿的读数
test "preset HEX" {
  assert_eq(@re.re_preset_pattern(@re.RePreset::Hex), "^[a-fA-F0-9]+$")
  assert_eq(pm(@re.RePreset::Hex, "deadBEEF"), "true") // 腿 M.HEX 第 0 条
  assert_eq(pf(@re.RePreset::Hex, "deadBEEF"), "deadBEEF") // 腿 F.HEX 第 1 条
  assert_eq(pm(@re.RePreset::Hex, "dead BE E"), "false") // 腿 M.HEX 第 2 条
  assert_eq(pf(@re.RePreset::Hex, "dead BE E"), "NONE") // 腿 F.HEX 第 3 条
  assert_eq(pm(@re.RePreset::Hex, "g"), "false") // 腿 M.HEX 第 4 条
  assert_eq(pf(@re.RePreset::Hex, "g"), "NONE") // 腿 F.HEX 第 5 条
  assert_eq(pm(@re.RePreset::Hex, ""), "false") // 腿 M.HEX 第 6 条
  assert_eq(pf(@re.RePreset::Hex, ""), "NONE") // 腿 F.HEX 第 7 条
  assert_eq(pm(@re.RePreset::Hex, "0"), "true") // 腿 M.HEX 第 8 条
  assert_eq(pf(@re.RePreset::Hex, "0"), "0") // 腿 F.HEX 第 9 条
}

///|
// 常量 TIME：参照原文经规则表 R1+R3 得到下面的改写串；每条判定逐条取腿的读数
test "preset TIME" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::Time),
    "[0-9]{1,2}[时:][0-9]{1,2}([分:][0-9]{1,2})?秒?",
  )
  assert_eq(pm(@re.RePreset::Time, "12:30"), "true") // 腿 M.TIME 第 0 条
  assert_eq(pf(@re.RePreset::Time, "12:30"), "12:30") // 腿 F.TIME 第 1 条
  assert_eq(pm(@re.RePreset::Time, "12时30分"), "false") // 腿 M.TIME 第 2 条
  assert_eq(pf(@re.RePreset::Time, "12时30分"), "12时30") // 腿 F.TIME 第 3 条
  assert_eq(pm(@re.RePreset::Time, "1:2"), "true") // 腿 M.TIME 第 4 条
  assert_eq(pf(@re.RePreset::Time, "1:2"), "1:2") // 腿 F.TIME 第 5 条
  assert_eq(pm(@re.RePreset::Time, "12:30:61"), "true") // 腿 M.TIME 第 6 条
  assert_eq(pf(@re.RePreset::Time, "12:30:61"), "12:30:61") // 腿 F.TIME 第 7 条
  assert_eq(pm(@re.RePreset::Time, "25:00"), "true") // 腿 M.TIME 第 8 条
  assert_eq(pf(@re.RePreset::Time, "25:00"), "25:00") // 腿 F.TIME 第 9 条
  assert_eq(pm(@re.RePreset::Time, "中"), "false") // 腿 M.TIME 第 10 条
  assert_eq(pf(@re.RePreset::Time, "中"), "NONE") // 腿 F.TIME 第 11 条
  assert_eq(pm(@re.RePreset::Time, "12时30分15秒"), "true") // 腿 M.TIME 第 12 条
  assert_eq(pf(@re.RePreset::Time, "12时30分15秒"), "12时30分15秒") // 腿 F.TIME 第 13 条
}

///|
// 常量 CHINESE_NAME：参照原文经规则表 无需改写（与参照逐字同形） 得到下面的改写串；每条判定逐条取腿的读数
test "preset CHINESE_NAME" {
  assert_eq(
    @re.re_preset_pattern(@re.RePreset::ChineseName),
    "^[㐀-鿿·]{2,60}$",
  )
  assert_eq(pm(@re.RePreset::ChineseName, "欧阳·三"), "true") // 腿 M.CHINESE_NAME 第 0 条
  assert_eq(pf(@re.RePreset::ChineseName, "欧阳·三"), "欧阳·三") // 腿 F.CHINESE_NAME 第 1 条
  assert_eq(pm(@re.RePreset::ChineseName, "李三"), "true") // 腿 M.CHINESE_NAME 第 2 条
  assert_eq(pf(@re.RePreset::ChineseName, "李三"), "李三") // 腿 F.CHINESE_NAME 第 3 条
  assert_eq(pm(@re.RePreset::ChineseName, "李"), "false") // 腿 M.CHINESE_NAME 第 4 条
  assert_eq(pf(@re.RePreset::ChineseName, "李"), "NONE") // 腿 F.CHINESE_NAME 第 5 条
  assert_eq(pm(@re.RePreset::ChineseName, "欧阳 "), "false") // 腿 M.CHINESE_NAME 第 6 条
  assert_eq(pf(@re.RePreset::ChineseName, "欧阳 "), "NONE") // 腿 F.CHINESE_NAME 第 7 条
  assert_eq(pm(@re.RePreset::ChineseName, "㐀"), "false") // 腿 M.CHINESE_NAME 第 8 条
  assert_eq(pf(@re.RePreset::ChineseName, "㐀"), "NONE") // 腿 F.CHINESE_NAME 第 9 条
  assert_eq(pm(@re.RePreset::ChineseName, "中·中·中"), "true") // 腿 M.CHINESE_NAME 第 10 条
  assert_eq(pf(@re.RePreset::ChineseName, "中·中·中"), "中·中·中") // 腿 F.CHINESE_NAME 第 11 条
}

///|
// 名字表：本库档名 → 参照常量名（逐字符取腿 R 行的键名——要把本库的档与参照的文案对上就靠它）
test "preset 名字表" {
  assert_eq(@re.re_preset_name(@re.RePreset::General), "GENERAL") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Numbers), "NUMBERS") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Word), "WORD") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Chinese), "CHINESE") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Chineses), "CHINESES") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::GroupVar), "GROUP_VAR") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Ipv4), "IPV4") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Ipv6), "IPV6") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Money), "MONEY") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Email), "EMAIL") // 腿 R 行的键名
  assert_eq(
    @re.re_preset_name(@re.RePreset::EmailWithChinese),
    "EMAIL_WITH_CHINESE",
  ) // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::ZipCode), "ZIP_CODE") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Birthday), "BIRTHDAY") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Uri), "URI") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Url), "URL") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::UrlHttp), "URL_HTTP") // 腿 R 行的键名
  assert_eq(
    @re.re_preset_name(@re.RePreset::GeneralWithChinese),
    "GENERAL_WITH_CHINESE",
  ) // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Uuid), "UUID") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::UuidSimple), "UUID_SIMPLE") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::MacAddress), "MAC_ADDRESS") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Hex), "HEX") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::Time), "TIME") // 腿 R 行的键名
  assert_eq(@re.re_preset_name(@re.RePreset::ChineseName), "CHINESE_NAME") // 腿 R 行的键名
}

///|
// 表全集：条数与顺序都钉住（顺序＝腿 R 行的声明序）。新增或删除一档必须连带改 spec §9 的边界表
test "preset 表全集" {
  assert_eq(@re.re_presets().map(p => @re.re_preset_name(p)), [
    "GENERAL", "NUMBERS", "WORD", "CHINESE", "CHINESES", "GROUP_VAR", "IPV4", "IPV6",
    "MONEY", "EMAIL", "EMAIL_WITH_CHINESE", "ZIP_CODE", "BIRTHDAY", "URI", "URL",
    "URL_HTTP", "GENERAL_WITH_CHINESE", "UUID", "UUID_SIMPLE", "MAC_ADDRESS", "HEX",
    "TIME", "CHINESE_NAME",
  ])
  assert_eq(@re.re_presets().length(), 23)
}

///|
// 数字提取：对位 `ReUtil.getFirstNumber`，三条出口形状取腿的 G 行读数。
// 腿另有一条 `getFirstNumber(null)` → `null`（参照对 null 入参不崩），
// 本库的参数类型是 `String`，那一档在类型上不可表达 ⇒ 记在 spec §11，不编成断言
test "first_number" {
  assert_eq(pnum("a20b30"), "20") // 腿 G.get_first_number
  assert_eq(pnum("abc"), "NONE") // 腿 G.get_first_number_none
  assert_eq(pnum(""), "NONE") // 腿 G.get_first_number_empty
}
