///|
// 第三批（中文数字与英文 word）的期望值全部来自参考腿读数：hutool `NumberChineseFormatter` /
// `NumberWordFormatter` 的逐字转写跑在本机 JDK 17（Java 才是 hutool 的运行时），读数表与规则
// 出处在 `docs/spec/08-num.md` §10；反向另加一份 Python 复刻算法与 JDK 逐条对撞（越过 32 位上界
// 的截断除外）。改任何一条期望串须单独一笔并给外部读数来源（门禁 G5）。

///|
// 错误面读数：复用 `num_test.mbt` 里的 show（同一测试包内可见，三条新档已在 show 里补齐）
fn[A] cn_err(g : () -> A raise @num.NumError) -> String {
  try {
    let _ = g()
    "未抛错"
  } catch {
    err => show(err)
  }
}

///|
// 读数 = 本机 JDK 17 上 hutool `format(BigDecimal, false, false)` 的逐条输出；千位段内的空位补零（1001 ⇒ 一千零一、1010 ⇒ 一千零一十），节与节之间不补零（1000000 ⇒ 一百万）
test "chinese_of：节权位与零的折叠（#8.26）" {
  assert_eq(@num.chinese_of("0"), "零")
  assert_eq(@num.chinese_of("1"), "一")
  assert_eq(@num.chinese_of("9"), "九")
  assert_eq(@num.chinese_of("10"), "一十")
  assert_eq(@num.chinese_of("11"), "一十一")
  assert_eq(@num.chinese_of("20"), "二十")
  assert_eq(@num.chinese_of("99"), "九十九")
  assert_eq(@num.chinese_of("100"), "一百")
  assert_eq(@num.chinese_of("101"), "一百零一")
  assert_eq(@num.chinese_of("110"), "一百一十")
  assert_eq(@num.chinese_of("121"), "一百二十一")
  assert_eq(@num.chinese_of("1000"), "一千")
  assert_eq(@num.chinese_of("1001"), "一千零一")
  assert_eq(@num.chinese_of("1010"), "一千零一十")
  assert_eq(@num.chinese_of("1100"), "一千一百")
  assert_eq(@num.chinese_of("10000"), "一万")
  assert_eq(@num.chinese_of("10010"), "一万零一十")
  assert_eq(@num.chinese_of("100000"), "一十万")
  assert_eq(@num.chinese_of("1000000"), "一百万")
  assert_eq(@num.chinese_of("100000000"), "一亿")
  assert_eq(@num.chinese_of("100000001"), "一亿零一")
  assert_eq(
    @num.chinese_of("123456789"),
    "一亿二千三百四十五万六千七百八十九",
  )
  assert_eq(@num.chinese_of("1000000000000"), "一万亿")
  assert_eq(@num.chinese_of("-1"), "负一")
  assert_eq(@num.chinese_of("-11"), "负一十一")
  assert_eq(
    @num.chinese_of("-12345.67"),
    "负一万二千三百四十五点六七",
  )
}

///|
// 小数部分逐位读、尾零保留（0.10 ⇒ 零点一零、1.00 ⇒ 一点零零）——这两条正是 `Double` 入口会丢的读数：同一输入 hutool 的 double 路给 零点一 / 一（实测），所以本批入口只收十进制原文串
test "chinese_of：小数逐位与尾零（#8.26）" {
  assert_eq(@num.chinese_of("0"), "零")
  assert_eq(@num.chinese_of("0.05"), "零点零五")
  assert_eq(@num.chinese_of("0.5"), "零点五")
  assert_eq(@num.chinese_of("1.105"), "一点一零五")
  assert_eq(
    @num.chinese_of("12345.678"),
    "一万二千三百四十五点六七八",
  )
  assert_eq(@num.chinese_of("0.10"), "零点一零")
  assert_eq(@num.chinese_of("1.00"), "一点零零")
  assert_eq(
    @num.chinese_of("-12345.67"),
    "负一万二千三百四十五点六七",
  )
  assert_eq(@num.chinese_of("0.1"), "零点一")
}

///|
// 万/亿两档简繁同形（10000 ⇒ 壹万）；个位与十百千全表换成记账大写
test "chinese_upper_of：繁体字表对照（#8.27）" {
  assert_eq(@num.chinese_upper_of("0"), "零")
  assert_eq(@num.chinese_upper_of("1"), "壹")
  assert_eq(@num.chinese_upper_of("10"), "壹拾")
  assert_eq(@num.chinese_upper_of("11"), "壹拾壹")
  assert_eq(@num.chinese_upper_of("15"), "壹拾伍")
  assert_eq(@num.chinese_upper_of("20"), "贰拾")
  assert_eq(@num.chinese_upper_of("100"), "壹佰")
  assert_eq(@num.chinese_upper_of("101"), "壹佰零壹")
  assert_eq(@num.chinese_upper_of("1000"), "壹仟")
  assert_eq(@num.chinese_upper_of("1010"), "壹仟零壹拾")
  assert_eq(@num.chinese_upper_of("10000"), "壹万")
  assert_eq(@num.chinese_upper_of("100000"), "壹拾万")
  assert_eq(@num.chinese_upper_of("1000000"), "壹佰万")
  assert_eq(
    @num.chinese_upper_of("123456789"),
    "壹亿贰仟叁佰肆拾伍万陆仟柒佰捌拾玖",
  )
  assert_eq(
    @num.chinese_upper_of("-12345.67"),
    "负壹万贰仟叁佰肆拾伍点陆柒",
  )
  assert_eq(@num.chinese_upper_of("1.105"), "壹点壹零伍")
}

///|
// hutool 的口语映射一共四条（一十→十、一拾→拾、负一十→负十、负一拾→负拾），所以 115 ⇒ 一百一十五 里那个「一十」不动——档做窄是有依据的，不是省事
test "chinese_colloquial_of 只改「一十」这一处（#8.28/#8.29）" {
  assert_eq(@num.chinese_colloquial_of("10"), "十")
  assert_eq(@num.chinese_colloquial_of("11"), "十一")
  assert_eq(@num.chinese_colloquial_of("15"), "十五")
  assert_eq(@num.chinese_colloquial_of("19"), "十九")
  assert_eq(@num.chinese_colloquial_of("20"), "二十")
  assert_eq(@num.chinese_colloquial_of("100000"), "十万")
  assert_eq(@num.chinese_colloquial_of("-10"), "负十")
  assert_eq(@num.chinese_colloquial_of("-11"), "负十一")
  assert_eq(@num.chinese_colloquial_of("115"), "一百一十五")
  assert_eq(@num.chinese_colloquial_of("110"), "一百一十")
  assert_eq(@num.chinese_colloquial_of("121"), "一百二十一")
  assert_eq(@num.chinese_upper_colloquial_of("10"), "壹拾")
  assert_eq(@num.chinese_upper_colloquial_of("11"), "壹拾壹")
  assert_eq(@num.chinese_upper_colloquial_of("-11"), "负壹拾壹")
  assert_eq(@num.chinese_upper_colloquial_of("115"), "壹佰壹拾伍")
  assert_eq(@num.chinese_upper_colloquial_of("100000"), "壹拾万")
}

///|
// 界内上界是 ±99_9999_9999_9999.99（hutool `Assert.checkBetween` 那句 `Number support only: (-99999999999999.99 ~ 99999999999999.99)！` 只当证据，文案不进错误载荷）；原文串不做 trim、不接受 `+` 前缀与指数写法（hutool 的 `BigDecimal` 路两者都收：`+1` 读「一」、`1e5` 读「一十万」，实测），本包按整串文法判非十进制。
// 「超 Int64」那一档本包给 OutOfRange 而不是回绕读数：实测 hutool 拿 `BigDecimal.longValue()` 的低 64 位再判界，`18446744073709551621`（2^64+5）回绕成 5 ⇒ 它读出「五」、`18446744073709551616` 回绕成 0 ⇒ 读出「零」——回绕落点决定读数是错是对，本包不赌。
test "正向界与非十进制输入（#8.26~#8.31）" {
  assert_eq(
    cn_err(() => @num.chinese_of("100000000000000000")),
    "OutOfRange \"100000000000000000\"",
  )
  assert_eq(
    cn_err(() => @num.chinese_of("-100000000000000000")),
    "OutOfRange \"-100000000000000000\"",
  )
  assert_eq(
    cn_err(() => @num.chinese_of("18446744073709551621")),
    "OutOfRange \"18446744073709551621\"",
  )
  assert_eq(
    cn_err(() => @num.chinese_money_of("100000000000000000")),
    "OutOfRange \"100000000000000000\"",
  )
  assert_eq(cn_err(() => @num.chinese_of("")), "NotDecimal \"\"")
  assert_eq(cn_err(() => @num.chinese_of("abc")), "NotDecimal \"abc\"")
  assert_eq(cn_err(() => @num.chinese_of("1.2.3")), "NotDecimal \"1.2.3\"")
  assert_eq(cn_err(() => @num.chinese_of("12 ")), "NotDecimal \"12 \"")
  assert_eq(cn_err(() => @num.chinese_of("+1")), "NotDecimal \"+1\"")
  assert_eq(cn_err(() => @num.chinese_of("1e5")), "NotDecimal \"1e5\"")
}

///|
// 文法收的四条怪形状（JDK 逐条实测：`007 ⇒ 七`、`1. ⇒ 一`、`.5 ⇒ 零点五`、`0.000 ⇒ 零点零零零`），另有一条**不跟随**：hutool 的 BigDecimal 路在 `|x| < 1` 的负小数上把「负」弄丢了（实测 `-0.05 ⇒ 零点零五`、`-.5 ⇒ 零点五`），因为整数部分截断成 0 就走了「零」那条早退；本包按原串保号，`-0.05 ⇒ 负零点零五`，而真零（`-0`、`-0.00`）仍不带「负」（零没有符号）。
test "文法允许的怪形状与丢号一档（#8.26）" {
  assert_eq(@num.chinese_of("007"), "七")
  assert_eq(@num.chinese_of("1."), "一")
  assert_eq(@num.chinese_of(".5"), "零点五")
  assert_eq(@num.chinese_of("0.000"), "零点零零零")
  assert_eq(@num.chinese_of("-0.05"), "负零点零五")
  assert_eq(@num.chinese_of("-0.00"), "零点零零")
  assert_eq(@num.chinese_of("-0"), "零")
  assert_eq(@num.chinese_of("-1.5"), "负一点五")
}

///|
// 不足一元不写「零元」（0.05 ⇒ 伍分、0.5 ⇒ 伍角）；整元带「元整」；负数带「负」但角分段按绝对值读；小数先两位 HALF_UP 再拆角/分（1.105 ⇒ 壹角壹分、0.005 ⇒ 壹分）
test "chinese_money_of：元/角/分/整的档（#8.30）" {
  assert_eq(@num.chinese_money_of("0"), "零元整")
  assert_eq(@num.chinese_money_of("1"), "壹元整")
  assert_eq(@num.chinese_money_of("10"), "壹拾元整")
  assert_eq(@num.chinese_money_of("11"), "壹拾壹元整")
  assert_eq(@num.chinese_money_of("100"), "壹佰元整")
  assert_eq(@num.chinese_money_of("101"), "壹佰零壹元整")
  assert_eq(@num.chinese_money_of("1000"), "壹仟元整")
  assert_eq(@num.chinese_money_of("10000"), "壹万元整")
  assert_eq(
    @num.chinese_money_of("123456789"),
    "壹亿贰仟叁佰肆拾伍万陆仟柒佰捌拾玖元整",
  )
  assert_eq(@num.chinese_money_of("1000000000000"), "壹万亿元整")
  assert_eq(
    @num.chinese_money_of("99999999999999.99"),
    "玖拾玖万玖仟玖佰玖拾玖亿玖仟玖佰玖拾玖万玖仟玖佰玖拾玖元玖角捌分",
  )
  assert_eq(@num.chinese_money_of("0.05"), "伍分")
  assert_eq(@num.chinese_money_of("0.5"), "伍角")
  assert_eq(@num.chinese_money_of("1.105"), "壹元壹角壹分")
  assert_eq(@num.chinese_money_of("1.235"), "壹元贰角肆分")
  assert_eq(@num.chinese_money_of("1.245"), "壹元贰角伍分")
  assert_eq(@num.chinese_money_of("0.005"), "壹分")
  assert_eq(@num.chinese_money_of("0.004"), "整")
  assert_eq(
    @num.chinese_money_of("-12345.67"),
    "负壹万贰仟叁佰肆拾伍元陆角柒分",
  )
  assert_eq(@num.chinese_money_of("1.00"), "壹元整")
  assert_eq(@num.chinese_money_of("0.10"), "壹角")
  assert_eq(
    @num.chinese_money_of("12345.678"),
    "壹万贰仟叁佰肆拾伍元陆角捌分",
  )
  assert_eq(@num.chinese_money_of("0.999"), "壹元整")
  assert_eq(@num.chinese_money_of("1.015"), "壹元零壹分")
  assert_eq(@num.chinese_money_of("2.675"), "贰元陆角捌分")
  assert_eq(@num.chinese_money_of("1000000.01"), "壹佰万元零壹分")
  assert_eq(@num.chinese_money_of("-0.004"), "负整")
  assert_eq(@num.chinese_money_of("-0.05"), "负伍分")
  assert_eq(@num.chinese_money_of("-0"), "零元整")
  assert_eq(@num.chinese_money_of("0.0"), "零元整")
}

///|
// 与繁体档只差字表、段的取舍完全一致；`0.004 ⇒ 整` 与 `-0.004 ⇒ 负整` 是同一档的正负两面（元/角/分全为零时只留「整」）
test "chinese_money_simple_of 简写金额（#8.31）" {
  assert_eq(@num.chinese_money_simple_of("0"), "零元整")
  assert_eq(@num.chinese_money_simple_of("1"), "一元整")
  assert_eq(@num.chinese_money_simple_of("10"), "一十元整")
  assert_eq(@num.chinese_money_simple_of("11"), "一十一元整")
  assert_eq(@num.chinese_money_simple_of("100"), "一百元整")
  assert_eq(@num.chinese_money_simple_of("101"), "一百零一元整")
  assert_eq(@num.chinese_money_simple_of("1000"), "一千元整")
  assert_eq(@num.chinese_money_simple_of("10000"), "一万元整")
  assert_eq(
    @num.chinese_money_simple_of("123456789"),
    "一亿二千三百四十五万六千七百八十九元整",
  )
  assert_eq(@num.chinese_money_simple_of("1000000000000"), "一万亿元整")
  assert_eq(
    @num.chinese_money_simple_of("99999999999999.99"),
    "九十九万九千九百九十九亿九千九百九十九万九千九百九十九元九角八分",
  )
  assert_eq(@num.chinese_money_simple_of("0.05"), "五分")
  assert_eq(@num.chinese_money_simple_of("0.5"), "五角")
  assert_eq(@num.chinese_money_simple_of("1.105"), "一元一角一分")
  assert_eq(@num.chinese_money_simple_of("1.235"), "一元二角四分")
  assert_eq(@num.chinese_money_simple_of("1.245"), "一元二角五分")
  assert_eq(@num.chinese_money_simple_of("0.005"), "一分")
  assert_eq(@num.chinese_money_simple_of("0.004"), "整")
  assert_eq(
    @num.chinese_money_simple_of("-12345.67"),
    "负一万二千三百四十五元六角七分",
  )
  assert_eq(@num.chinese_money_simple_of("1.00"), "一元整")
  assert_eq(@num.chinese_money_simple_of("0.10"), "一角")
  assert_eq(
    @num.chinese_money_simple_of("12345.678"),
    "一万二千三百四十五元六角八分",
  )
  assert_eq(@num.chinese_money_simple_of("1.015"), "一元零一分")
  assert_eq(@num.chinese_money_simple_of("2.675"), "二元六角八分")
  assert_eq(@num.chinese_money_simple_of("1000000.01"), "一百万元零一分")
  assert_eq(@num.chinese_money_simple_of("-1.5"), "负一元五角")
  assert_eq(@num.chinese_money_simple_of("-0.004"), "负整")
}

///|
// hutool 自己两条路不同族：`NumberUtil.round` 默认 HALF_UP，而 `Money.DEFAULT_ROUNDING_MODE` 是 HALF_EVEN。本包不强行统一（两边都有权威读数），但把分岔钉成夹具：1.105 走金额中文 ⇒ 壹角壹分，走 Money ⇒ 110 分（= 1.10）
test "金额档舍入族分岔：这里跟 HalfUp 而不是 Money 的 HalfEven（#8.30 与 #8.18）" {
  assert_eq(@num.chinese_money_of("1.105"), "壹元壹角壹分")
  assert_eq(@num.chinese_money_of("0.005"), "壹分")
  assert_eq(@num.Money::from_yuan_str("1.105").cent(), 110)
  assert_eq(@num.Money::from_yuan_str("0.005").cent(), 0)
}

///|
// 这条档才是 hutool「10~19 去掉一」的住处（`formatThousand`）；#8.26 的通用档保留「一十」——两个档分开命名而不是布尔开关。界外读数：hutool 抛 `Number support only: (-999 ~ 999)！`
test "chinese_of_thousand：10~19 去「一」与 ±999 界（#8.32）" {
  assert_eq(@num.chinese_of_thousand(0), "零")
  assert_eq(@num.chinese_of_thousand(1), "一")
  assert_eq(@num.chinese_of_thousand(9), "九")
  assert_eq(@num.chinese_of_thousand(10), "十")
  assert_eq(@num.chinese_of_thousand(11), "十一")
  assert_eq(@num.chinese_of_thousand(15), "十五")
  assert_eq(@num.chinese_of_thousand(19), "十九")
  assert_eq(@num.chinese_of_thousand(20), "二十")
  assert_eq(@num.chinese_of_thousand(21), "二十一")
  assert_eq(@num.chinese_of_thousand(99), "九十九")
  assert_eq(@num.chinese_of_thousand(100), "一百")
  assert_eq(@num.chinese_of_thousand(101), "一百零一")
  assert_eq(@num.chinese_of_thousand(110), "一百一十")
  assert_eq(@num.chinese_of_thousand(115), "一百一十五")
  assert_eq(@num.chinese_of_thousand(119), "一百一十九")
  assert_eq(@num.chinese_of_thousand(190), "一百九十")
  assert_eq(@num.chinese_of_thousand(199), "一百九十九")
  assert_eq(@num.chinese_of_thousand(200), "二百")
  assert_eq(@num.chinese_of_thousand(909), "九百零九")
  assert_eq(@num.chinese_of_thousand(990), "九百九十")
  assert_eq(@num.chinese_of_thousand(999), "九百九十九")
  assert_eq(@num.chinese_of_thousand(-1), "")
  assert_eq(@num.chinese_of_thousand(-10), "")
  assert_eq(@num.chinese_of_thousand(-100), "")
  assert_eq(@num.chinese_of_thousand(-999), "")
  assert_eq(cn_err(() => @num.chinese_of_thousand(1000)), "OutOfRange \"1000\"")
  assert_eq(
    cn_err(() => @num.chinese_of_thousand(-1000)),
    "OutOfRange \"-1000\"",
  )
}

///|
// 繁体档同样去「一」（11 ⇒ 拾壹），与简写档一致，只换字表
test "chinese_upper_of_thousand 繁体千分位（#8.33）" {
  assert_eq(@num.chinese_upper_of_thousand(10), "拾")
  assert_eq(@num.chinese_upper_of_thousand(11), "拾壹")
  assert_eq(@num.chinese_upper_of_thousand(15), "拾伍")
  assert_eq(@num.chinese_upper_of_thousand(19), "拾玖")
  assert_eq(@num.chinese_upper_of_thousand(20), "贰拾")
  assert_eq(@num.chinese_upper_of_thousand(110), "壹佰壹拾")
  assert_eq(@num.chinese_upper_of_thousand(115), "壹佰壹拾伍")
  assert_eq(@num.chinese_upper_of_thousand(119), "壹佰壹拾玖")
  assert_eq(@num.chinese_upper_of_thousand(190), "壹佰玖拾")
  assert_eq(@num.chinese_upper_of_thousand(999), "玖佰玖拾玖")
  assert_eq(@num.chinese_upper_of_thousand(-10), "")
}

///|
// hutool 在这里没有任何校验（`numberCharToChinese` 对非数字字符掉进查表 -1 再往下走），本包对非 '0'~'9' 给错并带上那个字符与位置
test "chinese_digit：单字符档与非数字（#8.34）" {
  assert_eq(@num.chinese_digit('0'), '零')
  assert_eq(@num.chinese_digit('1'), '一')
  assert_eq(@num.chinese_digit('2'), '二')
  assert_eq(@num.chinese_digit('3'), '三')
  assert_eq(@num.chinese_digit('4'), '四')
  assert_eq(@num.chinese_digit('5'), '五')
  assert_eq(@num.chinese_digit('6'), '六')
  assert_eq(@num.chinese_digit('7'), '七')
  assert_eq(@num.chinese_digit('8'), '八')
  assert_eq(@num.chinese_digit('9'), '九')
  assert_eq(@num.chinese_digit('7', upper=true), '柒')
  assert_eq(cn_err(() => @num.chinese_digit('十')), "UnknownChineseUnit 十 0")
  assert_eq(cn_err(() => @num.chinese_digit('a')), "UnknownChineseUnit a 0")
}

///|
// 读数 = JDK 上 hutool `chineseToNumber`；本包模型逐条对撞一致（截断档除外）。裸单位补一（十 ⇒ 10、百 ⇒ 100）是 hutool 为「十二」这类口语立的规则，原样跟随
test "int_of_chinese：基本档与裸单位（#8.35）" {
  assert_eq(@num.int_of_chinese("零"), 0)
  assert_eq(@num.int_of_chinese("一"), 1)
  assert_eq(@num.int_of_chinese("二"), 2)
  assert_eq(@num.int_of_chinese("两"), 2)
  assert_eq(@num.int_of_chinese("十"), 10)
  assert_eq(@num.int_of_chinese("一十"), 10)
  assert_eq(@num.int_of_chinese("十一"), 11)
  assert_eq(@num.int_of_chinese("一百"), 100)
  assert_eq(@num.int_of_chinese("百"), 100)
  assert_eq(@num.int_of_chinese("拾"), 10)
  assert_eq(@num.int_of_chinese("仟"), 1000)
  assert_eq(@num.int_of_chinese("一万"), 10000)
  assert_eq(@num.int_of_chinese("十万"), 100000)
  assert_eq(@num.int_of_chinese("一十万"), 100000)
  assert_eq(@num.int_of_chinese("一百万"), 1000000)
  assert_eq(@num.int_of_chinese("一亿"), 100000000)
  assert_eq(@num.int_of_chinese("壹拾贰"), 12)
  assert_eq(@num.int_of_chinese("两千"), 2000)
  assert_eq(@num.int_of_chinese("二千"), 2000)
  assert_eq(@num.int_of_chinese("一十一"), 11)
  assert_eq(@num.int_of_chinese("零壹拾"), 10)
  assert_eq(@num.int_of_chinese("壹"), 1)
  assert_eq(@num.int_of_chinese("壹佰"), 100)
  assert_eq(@num.int_of_chinese("九万"), 90000)
  assert_eq(@num.int_of_chinese("壹拾亿"), 1000000000)
}

///|
// 「一千零一百」⇒ 1100（零只当占位，不做减法）、「万一」⇒ 1000、「亿亿」⇒ 0——参照实现的算法就是这样的累乘/覆盖，本包原样钉住不改，越界处另立一档
test "int_of_chinese：跨节、零的折叠与怪形状（#8.35）" {
  assert_eq(@num.int_of_chinese("一百零一"), 101)
  assert_eq(@num.int_of_chinese("一百一十"), 110)
  assert_eq(@num.int_of_chinese("一百二十一"), 121)
  assert_eq(@num.int_of_chinese("一千零一"), 1001)
  assert_eq(@num.int_of_chinese("一千零一百"), 1100)
  assert_eq(@num.int_of_chinese("一千一百"), 1100)
  assert_eq(@num.int_of_chinese("一万二千三百四十五"), 12345)
  assert_eq(@num.int_of_chinese("一万零一十"), 10010)
  assert_eq(@num.int_of_chinese("一亿零一"), 100000001)
  assert_eq(@num.int_of_chinese("拾万"), 100000)
  assert_eq(@num.int_of_chinese("万一"), 1000)
  assert_eq(@num.int_of_chinese("亿亿"), 0)
  assert_eq(@num.int_of_chinese("万万千"), 0)
  assert_eq(@num.int_of_chinese("一零零"), 0)
  assert_eq(@num.int_of_chinese("一千万"), 10000000)
  assert_eq(@num.int_of_chinese("一千亿"), 100000000000)
  assert_eq(
    @num.int_of_chinese("九十九万九千九百九十九亿"),
    999900990000,
  )
  assert_eq(@num.int_of_chinese("一千万亿"), 10000000)
  assert_eq(
    @num.int_of_chinese("壹佰贰拾叁万肆仟伍佰陆拾柒"),
    1234567,
  )
  // 空格在 hutool 的单位表里是一个值为 1 的单位（spec §10.4 第 8 条说的是"整串空白"那条哨兵）：
  // 实测 `" 一十" ⇒ 11`、`"一十 一" ⇒ 10`（末尾那条是 `number * (unit.value / 10)` 的整数除把 1 削成 0）
  assert_eq(@num.int_of_chinese(" 一十"), 11)
  assert_eq(@num.int_of_chinese("一十 一"), 10)
}

///|
// hutool 在这里抛 `Unknown unit '负' at: 0`（实测四条都在读数表里），而它自己的正向会产出带「负」的串⇒ 往返不通。本包认前缀「负」并按剩余部分取负；「负」出现在其他位置仍是 UnknownChineseUnit
test "int_of_chinese 认「负」：一处对 hutool 的修正（#8.35）" {
  assert_eq(@num.int_of_chinese("负一百二十一"), -121)
  assert_eq(@num.int_of_chinese("负一十"), -10)
  assert_eq(@num.int_of_chinese("负一十一"), -11)
  assert_eq(@num.int_of_chinese("负一万二千三百四十五"), -12345)
}

///|
// 位置与两字窗口跟随 JDK 实测文案（如 `Bad number '壹贰' at: 1`、`Unknown unit '〇' at: 0`），文案本身不进载荷——本包三档都只带读数：档位名 + 那个字符/两字窗口 + 码点位置。JDK 侧报 ERR 的夹具全部自动进这一块，**除 spec §10.4 第 2 条已声明分岔的「负」前缀四条**——本包认负，那四条读出的是值不是错，钉在「认负」块里；原先两个块并排钉同一个输入是自相矛盾（JDK 对 `负一十` 报 `Unknown unit '负' at: 0` 正是那四条）
test "int_of_chinese 的错误形状带位置（#8.35）" {
  assert_eq(cn_err(() => @num.int_of_chinese("10")), "UnknownChineseUnit 1 0")
  assert_eq(
    cn_err(() => @num.int_of_chinese("〇")),
    "UnknownChineseUnit 〇 0",
  )
  assert_eq(
    cn_err(() => @num.int_of_chinese("一二三")),
    "BadChineseNumber 一二 1",
  )
  assert_eq(
    cn_err(() => @num.int_of_chinese("二○二五")),
    "UnknownChineseUnit ○ 1",
  )
  assert_eq(
    cn_err(() => @num.int_of_chinese("卅")),
    "UnknownChineseUnit 卅 0",
  )
  assert_eq(
    cn_err(() => @num.int_of_chinese("壹贰叁")),
    "BadChineseNumber 壹贰 1",
  )
  assert_eq(
    cn_err(() => @num.int_of_chinese("廿")),
    "UnknownChineseUnit 廿 0",
  )
  assert_eq(
    cn_err(() => @num.int_of_chinese("元")),
    "UnknownChineseUnit 元 0",
  )
  assert_eq(cn_err(() => @num.int_of_chinese("")), "NotDecimal \"\"")
  assert_eq(cn_err(() => @num.int_of_chinese("  ")), "NotDecimal \"  \"")
}

///|
// JDK 侧越 int 上界的实测截断读数：{"一千亿": ["1215752192", 100000000000], "九十九万九千九百九十九亿": ["-826389968", 999900990000]}——本包用 Int64 累加给真值（与第一批「增长型算术只在精确域」一脉）。
// `OutOfRange` 这一档在反向腿**发不出来**，不是漏钉：hutool 的算法每遇一个节单位就把 `section` 清零（实测「亿亿亿亿亿亿亿亿亿亿」⇒ 0，十个节单位互相抵消），增量只随输入长度线性增长，要越出 Int64 需要 10^7 量级字符的串。实现里保留溢出防线（宁可报错也不静默回绕），但这一档没有夹具能为它变红。
test "int_of_chinese 的界走 Int64：截断档不跟随（#8.35）" {
  assert_eq(@num.int_of_chinese("一千亿"), 100000000000)
  assert_eq(
    @num.int_of_chinese("九十九万九千九百九十九亿"),
    999900990000,
  )
  assert_eq(@num.int_of_chinese("亿亿亿亿亿亿亿亿亿亿"), 0)
  assert_eq(@num.int_of_chinese("壹亿贰拾万"), 100200000)
}

///|
// 24 条带元/角/分键的档与 JDK 逐条相等（含「圆」别名与 `壹分壹厘` 这种尾随垃圾两边都忽略）。声明分岔（左 JDK、右本包）：{"壹亿": [0, 10000000000], "壹佰": [0, 10000], "壹佰贰拾拾": [0, 12000]}——hutool 按「元」切段，整串没有元键就把内容丢掉（实测 `壹佰 ⇒ 0.00`），本包按元段读
test "money_of_chinese：键位切分与「没有元」不丢值（#8.36）" {
  assert_eq(@num.money_of_chinese("伍分").cent(), 5)
  assert_eq(@num.money_of_chinese("伍角").cent(), 50)
  assert_eq(@num.money_of_chinese("伍角伍分").cent(), 55)
  assert_eq(@num.money_of_chinese("壹仟零伍元伍角").cent(), 100550)
  assert_eq(@num.money_of_chinese("壹佰元").cent(), 10000)
  assert_eq(@num.money_of_chinese("壹佰元零伍分").cent(), 10005)
  assert_eq(
    @num.money_of_chinese(
      "壹佰贰拾叁万肆仟伍佰陆拾柒元捌角玖分",
    ).cent(),
    123456789,
  )
  assert_eq(
    @num.money_of_chinese("壹佰贰拾叁元肆角伍分").cent(),
    12345,
  )
  assert_eq(@num.money_of_chinese("壹佰贰拾壹元整").cent(), 12100)
  assert_eq(@num.money_of_chinese("壹元壹角壹分整").cent(), 111)
  assert_eq(@num.money_of_chinese("壹元整").cent(), 100)
  assert_eq(@num.money_of_chinese("壹元贰分").cent(), 102)
  assert_eq(@num.money_of_chinese("壹分").cent(), 1)
  assert_eq(@num.money_of_chinese("壹分壹厘").cent(), 1)
  assert_eq(@num.money_of_chinese("壹拾万元整").cent(), 10000000)
  assert_eq(@num.money_of_chinese("壹拾壹元").cent(), 1100)
  assert_eq(@num.money_of_chinese("壹拾壹元壹角壹分").cent(), 1111)
  assert_eq(@num.money_of_chinese("壹角").cent(), 10)
  assert_eq(@num.money_of_chinese("拾万元整").cent(), 10000000)
  assert_eq(@num.money_of_chinese("拾元整").cent(), 1000)
  assert_eq(@num.money_of_chinese("贰仟零壹元壹角").cent(), 200110)
  assert_eq(@num.money_of_chinese("贰拾万元").cent(), 20000000)
  assert_eq(@num.money_of_chinese("零元").cent(), 0)
  assert_eq(@num.money_of_chinese("零元零角零分").cent(), 0)
  assert_eq(@num.money_of_chinese("壹亿").cent(), 10000000000)
  assert_eq(@num.money_of_chinese("壹佰").cent(), 10000)
  assert_eq(@num.money_of_chinese("壹佰贰拾拾").cent(), 12000)
  assert_eq(@num.money_of_chinese("壹圆贰分").cent(), 102)
  assert_eq(@num.money_of_chinese("拾圆整").cent(), 1000)
  assert_eq(@num.money_of_chinese("壹亿贰角").cent(), 1200000000)
  assert_eq(@num.money_of_chinese("壹角壹拾分").cent(), 20)
  assert_eq(@num.money_of_chinese("角壹分").cent(), 1)
}

///|
// hutool 对空/全空白返回 null（哨兵）、对「负」与阿拉伯数字抛 `Unknown unit`；本包统一成 NotDecimal（空与无内容）或 UnknownChineseUnit（带字符与位置），逐条对照的 JDK 原读数在 spec §10.5
test "money_of_chinese 的错误形状（#8.36）" {
  assert_eq(cn_err(() => @num.money_of_chinese("")), "NotDecimal \"\"")
  assert_eq(cn_err(() => @num.money_of_chinese("  ")), "NotDecimal \"  \"")
  assert_eq(
    cn_err(() => @num.money_of_chinese("123元")),
    "UnknownChineseUnit 1 0",
  )
  assert_eq(
    cn_err(() => @num.money_of_chinese("元整")),
    "NotDecimal \"元整\"",
  )
  assert_eq(
    cn_err(() => @num.money_of_chinese("负壹佰元整")),
    "UnknownChineseUnit 负 0",
  )
  assert_eq(cn_err(() => @num.money_of_chinese("元")), "NotDecimal \"元\"")
  assert_eq(cn_err(() => @num.money_of_chinese("分")), "NotDecimal \"分\"")
}

///|
// 阈值实测：>=1e4 走「万」、>=1e8 走「亿」、>=1e12 走「万亿」，其余原样十进制；除数走 BigDecimal 两位 HALF_UP ⇒ 10000 ⇒ 1.00万 带尾零，且与 locale 无关
test "chinese_abbrev：万/亿/万亿 三档与两位 HALF_UP（#8.37）" {
  assert_eq(@num.chinese_abbrev(0), "0")
  assert_eq(@num.chinese_abbrev(1), "1")
  assert_eq(@num.chinese_abbrev(9), "9")
  assert_eq(@num.chinese_abbrev(10), "10")
  assert_eq(@num.chinese_abbrev(99), "99")
  assert_eq(@num.chinese_abbrev(100), "100")
  assert_eq(@num.chinese_abbrev(999), "999")
  assert_eq(@num.chinese_abbrev(1000), "1000")
  assert_eq(@num.chinese_abbrev(9999), "9999")
  assert_eq(@num.chinese_abbrev(10000), "1.00万")
  assert_eq(@num.chinese_abbrev(99999), "10.00万")
  assert_eq(@num.chinese_abbrev(100000), "10.00万")
  assert_eq(@num.chinese_abbrev(999999), "100.00万")
  assert_eq(@num.chinese_abbrev(1000000), "100.00万")
  assert_eq(@num.chinese_abbrev(9999999), "1000.00万")
  assert_eq(@num.chinese_abbrev(10000000), "1000.00万")
  assert_eq(@num.chinese_abbrev(99999999), "10000.00万")
  assert_eq(@num.chinese_abbrev(100000000), "1.00亿")
  assert_eq(@num.chinese_abbrev(999999999999), "10000.00亿")
  assert_eq(@num.chinese_abbrev(1000000000000), "1.00万亿")
  assert_eq(@num.chinese_abbrev(1234567890123), "1.23万亿")
  assert_eq(@num.chinese_abbrev(9999999999999999), "10000.00万亿")
  assert_eq(@num.chinese_abbrev(-1), "-1")
  assert_eq(@num.chinese_abbrev(-12345), "-1.23万")
  assert_eq(@num.chinese_abbrev(-10000), "-1.00万")
  assert_eq(@num.chinese_abbrev(-9999), "-9999")
  assert_eq(@num.chinese_abbrev(100000000000000), "100.00万亿")
  assert_eq(@num.chinese_abbrev(9223372036854775807), "9223372.04万亿")
  assert_eq(@num.chinese_abbrev(-9223372036854775807 - 1), "-9223372.04万亿")
}

///|
// 阈值实测（含 hutool 那两处不对称）：`value < 1000` 一条早退把**所有负数**留在原样十进制（`-10000 ⇒ -10000`，中文腿同量级给 `-1.00万`），而 `>= 10000` 才换 `w`、否则 `k`。
// locale：hutool 走 `NumberUtil.decimalFormat("#.##", …)` ⇒ 随 JVM 默认 locale 变（de 档实测 `1234567890123 ⇒ 123456789,01w`，本包固定 `.`，判据与 `conv` 轮同源——参照实现在自己运行时上给两种读数时，跟随就等于把环境写进语义）。
// 舍入族声明：hutool 这腿先 `value / 10000.0` 走 double，再 `DecimalFormat("#.##")`——本机实测 `Int64::MAX ⇒ 922337203685477.6w`（double 装不下那 19 位，尾数被并成 …6），本包与 #8.37 同族走**精确十进制**，同输入给 `922337203685477.58w`；两条读数都在，分岔是明码的。
test "english_abbrev：同阈值但单位是 w 且去尾零（#8.38）" {
  assert_eq(@num.english_abbrev(0), "0")
  assert_eq(@num.english_abbrev(1), "1")
  assert_eq(@num.english_abbrev(9), "9")
  assert_eq(@num.english_abbrev(10), "10")
  assert_eq(@num.english_abbrev(99), "99")
  assert_eq(@num.english_abbrev(100), "100")
  assert_eq(@num.english_abbrev(999), "999")
  assert_eq(@num.english_abbrev(1000), "1k")
  assert_eq(@num.english_abbrev(9999), "10k")
  assert_eq(@num.english_abbrev(10000), "1w")
  assert_eq(@num.english_abbrev(99999), "10w")
  assert_eq(@num.english_abbrev(100000), "10w")
  assert_eq(@num.english_abbrev(999999), "100w")
  assert_eq(@num.english_abbrev(1000000), "100w")
  assert_eq(@num.english_abbrev(9999999), "1000w")
  assert_eq(@num.english_abbrev(10000000), "1000w")
  assert_eq(@num.english_abbrev(99999999), "10000w")
  assert_eq(@num.english_abbrev(100000000), "10000w")
  assert_eq(@num.english_abbrev(999999999999), "100000000w")
  assert_eq(@num.english_abbrev(1000000000000), "100000000w")
  assert_eq(@num.english_abbrev(1234567890123), "123456789.01w")
  assert_eq(@num.english_abbrev(9999999999999999), "1000000000000w")
  assert_eq(@num.english_abbrev(-1), "-1")
  assert_eq(@num.english_abbrev(-12345), "-12345")
  assert_eq(@num.english_abbrev(-10000), "-10000")
  assert_eq(
    @num.english_abbrev(-9223372036854775807 - 1),
    "-9223372036854775808",
  )
  assert_eq(@num.english_abbrev(9223372036854775807), "922337203685477.58w")
}

///|
// 读数 = JDK 上 `NumberWordFormatter.format(Object)`；百位与后段之间才插 AND，有小数时读 `AND CENTS <逐位>`
test "english_word_of：三位一节与 ONLY（#8.39）" {
  assert_eq(@num.english_word_of("0"), "ZERO ONLY")
  assert_eq(@num.english_word_of("1"), "ONE ONLY")
  assert_eq(@num.english_word_of("12"), "TWELVE ONLY")
  assert_eq(@num.english_word_of("19"), "NINETEEN ONLY")
  assert_eq(@num.english_word_of("20"), "TWENTY ONLY")
  assert_eq(@num.english_word_of("100"), "ONE HUNDRED ONLY")
  assert_eq(@num.english_word_of("101"), "ONE HUNDRED AND ONE ONLY")
  assert_eq(@num.english_word_of("255"), "TWO HUNDRED AND FIFTY FIVE ONLY")
  assert_eq(
    @num.english_word_of("1234"),
    "ONE THOUSAND TWO HUNDRED AND THIRTY FOUR ONLY",
  )
  assert_eq(
    @num.english_word_of("1234567"),
    "ONE MILLION TWO HUNDRED AND THIRTY FOUR THOUSAND FIVE HUNDRED AND SIXTY SEVEN ONLY",
  )
  assert_eq(@num.english_word_of("1000000"), "ONE MILLION ONLY")
  assert_eq(@num.english_word_of("1000000000"), "ONE BILLION ONLY")
  assert_eq(@num.english_word_of("0.05"), "ZERO AND CENTS FIVE ONLY")
  assert_eq(@num.english_word_of("0.5"), "ZERO AND CENTS FIFTY ONLY")
  assert_eq(@num.english_word_of("1.10"), "ONE AND CENTS TEN ONLY")
  assert_eq(
    @num.english_word_of("255.5"),
    "TWO HUNDRED AND FIFTY FIVE AND CENTS FIFTY ONLY",
  )
  assert_eq(
    @num.english_word_of("1234.56"),
    "ONE THOUSAND TWO HUNDRED AND THIRTY FOUR AND CENTS FIFTY SIX ONLY",
  )
  // 「AND」只在**百位段内部**出现（transThree 那一支），节与节之间靠空格拼接：
  // 实测 `1001 ⇒ ONE THOUSAND ONE ONLY`（没有 AND）、`10101 ⇒ TEN THOUSAND ONE HUNDRED AND ONE ONLY`
  assert_eq(@num.english_word_of("110"), "ONE HUNDRED AND TEN ONLY")
  assert_eq(@num.english_word_of("1001"), "ONE THOUSAND ONE ONLY")
  assert_eq(
    @num.english_word_of("10101"),
    "TEN THOUSAND ONE HUNDRED AND ONE ONLY",
  )
  assert_eq(@num.english_word_of("100010"), "ONE HUNDRED THOUSAND TEN ONLY")
  assert_eq(@num.english_word_of("1000000000000"), "ONE TRILLION ONLY")
  assert_eq(
    @num.english_word_of("123456789012345"),
    "ONE HUNDRED AND TWENTY THREE TRILLION FOUR HUNDRED AND FIFTY SIX BILLION SEVEN HUNDRED AND EIGHTY NINE MILLION TWELVE THOUSAND THREE HUNDRED AND FORTY FIVE ONLY",
  )
}

///|
// hutool 对 1.0 输出 `ONE AND CENTS  ONLY`（两个空格，实测读数）、对负数直接炸在内部 `Integer.parseInt("-")`（实测 `NumberFormatException: For input string: "-"`）：前者是段拼接事故、后者是把内部异常当契约，本包分别改成不输出 cents 段与 OutOfRange
test "english_word_of 的三处不跟随：零分档、负数档、表外位数（#8.39）" {
  assert_eq(@num.english_word_of("1.0"), "ONE ONLY")
  assert_eq(@num.english_word_of("1.00"), "ONE ONLY")
  assert_eq(@num.english_word_of("0.00"), "ZERO ONLY")
  assert_eq(@num.english_word_of("1.005"), "ONE ONLY")
  assert_eq(@num.english_word_of("-0"), "ZERO ONLY")
  assert_eq(cn_err(() => @num.english_word_of("-1234")), "OutOfRange \"-1234\"")
  assert_eq(cn_err(() => @num.english_word_of("-0.5")), "OutOfRange \"-0.5\"")
  // 第三条不跟随：`NUMBER_MORE` 只有 5 档（…~TRILLION ⇒ 15 位），hutool 到 16 位是
  // 内部数组越界（实测 `ArrayIndexOutOfBoundsException: Index 5 out of bounds for length 5`），
  // 把内部越界当契约不成立 ⇒ 本包给 OutOfRange
  assert_eq(
    cn_err(() => @num.english_word_of("1234567890123456")),
    "OutOfRange \"1234567890123456\"",
  )
}
