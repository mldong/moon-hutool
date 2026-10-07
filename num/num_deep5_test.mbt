///|
// num 深档补档（10-08）——Money 三族（元/分/串）、分配负余数档、中文数字正向补零档、
// 反向坏档与"万万"档、缩写两位小数档、计算器负指数档。
// 期望全部由 Num5Leg.java 现读灌入（hutool-core 5.8.35 · JDK 17.0.14 · -Dfile.encoding=UTF-8），手打零条。
// 腿给的是 hutool 的读数；异常档只钉"抛不抛"，变体名不由这条腿授权（映射表在 spec 08-num §5 与 §10.4）。

///|
fn n5_tag_of_text(s : String) -> Bool {
  // 只问 Money 的十进制解析收不收，具体哪一档不在本批授权面里
  try {
    let _ = @num.Money::from_yuan_str(s)
    true
  } catch {
    _ => false
  }
}

///|
fn n5_yuan(s : String) -> Double {
  @num.Money::from_yuan_str(s).to_yuan() catch {
    _ => 0.0
  }
}

///|
fn n5_yuan2(s : String) -> String {
  @num.Money::from_yuan_str(s).cent().to_string() catch {
    _ => "RAISE"
  }
}

///|
fn n5_str(s : String) -> String {
  @num.Money::from_yuan_str(s).to_string() catch {
    _ => "RAISE"
  }
}

///|
fn n5_sum(ms : Array[@num.Money]) -> Int64 {
  let mut acc = 0L
  for m in ms {
    acc = acc + m.cent()
  }
  acc
}

///|
fn n5_even_sum(s : String, n : Int) -> Int64 {
  n5_sum(@num.Money::from_yuan_str(s).allocate_even(n)) catch {
    _ => -999999999L
  }
}

///|
fn n5_ratio_sum(s : String, rs : Array[Int]) -> Int64 {
  n5_sum(@num.Money::from_yuan_str(s).allocate_by_ratio(rs)) catch {
    _ => -999999999L
  }
}

///|
fn n5_join(ms : Array[@num.Money]) -> String {
  let mut out = ""
  for m in ms {
    if out != "" {
      out = out + ";"
    }
    out = out + m.cent().to_string()
  }
  out
}

///|
fn n5_even(s : String, n : Int) -> String {
  try {
    let m = @num.Money::from_yuan_str(s)
    n5_join(@num.Money::allocate_even(m, n))
  } catch {
    _ => "RAISE"
  }
}

///|
fn n5_ratio(s : String, rs : Array[Int]) -> String {
  try {
    let m = @num.Money::from_yuan_str(s)
    n5_join(@num.Money::allocate_by_ratio(m, rs))
  } catch {
    _ => "RAISE"
  }
}

///|
fn n5_int(t : String) -> String {
  @num.int_of_chinese(t).to_string() catch {
    _ => "RAISE"
  }
}

///|
fn n5_money(t : String) -> String {
  @num.money_of_chinese(t).to_string() catch {
    _ => "RAISE"
  }
}

///|
fn n5_cn(t : String) -> String {
  @num.chinese_of(t) catch {
    _ => "RAISE"
  }
}

///|
fn n5_cn_upper(t : String) -> String {
  @num.chinese_upper_of(t) catch {
    _ => "RAISE"
  }
}

///|
fn n5_abcn(v : Int64) -> String {
  @num.chinese_abbrev(v)
}

///|
fn n5_aben(v : Int64) -> String {
  @num.english_abbrev(v)
}

///|
fn n5_calc(e : String) -> Double {
  @num.num_calculate(e) catch {
    _ => 0.0
  }
}

///|
test "num 深档 mc-1.5" {
  // Money 分位 ｜ 入参=1.5 ｜ 参照=150
  assert_eq(n5_yuan2("1.5"), "150")
}

///|
test "num 深档 mc-0.07" {
  // Money 分位 ｜ 入参=0.07 ｜ 参照=7
  assert_eq(n5_yuan2("0.07"), "7")
}

///|
test "num 深档 mc-m3.21" {
  // Money 分位 ｜ 入参=-3.21 ｜ 参照=-321
  assert_eq(n5_yuan2("-3.21"), "-321")
}

///|
test "num 深档 mc-12345678.99" {
  // Money 分位 ｜ 入参=12345678.99 ｜ 参照=1234567899
  assert_eq(n5_yuan2("12345678.99"), "1234567899")
}

///|
test "num 深档 mc-0" {
  // Money 分位 ｜ 入参=0 ｜ 参照=0
  assert_eq(n5_yuan2("0"), "0")
}

///|
test "num 深档 mc-100" {
  // Money 分位 ｜ 入参=100 ｜ 参照=10000
  assert_eq(n5_yuan2("100"), "10000")
}

///|
test "num 深档 mc-0.005" {
  // Money 分位 ｜ 入参=0.005 ｜ 参照=0
  assert_eq(n5_yuan2("0.005"), "0")
}

///|
test "num 深档 mc-m1.00" {
  // Money 分位 ｜ 入参=-1.00 ｜ 参照=-100
  assert_eq(n5_yuan2("-1.00"), "-100")
}

///|
test "num 深档 my-1p5" {
  // Money 元值 ｜ 入参=1.5 ｜ 参照 Double.toString=1.5
  assert_eq(n5_yuan("1.5"), 1.5)
}

///|
test "num 深档 my-0p07" {
  // Money 元值 ｜ 入参=0.07 ｜ 参照 Double.toString=0.07
  assert_eq(n5_yuan("0.07"), 0.07)
}

///|
test "num 深档 my-m3p21" {
  // Money 元值 ｜ 入参=-3.21 ｜ 参照 Double.toString=-3.21
  assert_eq(n5_yuan("-3.21"), -3.21)
}

///|
test "num 深档 my-12345678p99" {
  // Money 元值 ｜ 入参=12345678.99 ｜ 参照 Double.toString=1.234567899E7
  assert_eq(n5_yuan("12345678.99"), 1.234567899E7)
}

///|
test "num 深档 my-0" {
  // Money 元值 ｜ 入参=0 ｜ 参照 Double.toString=0.0
  assert_eq(n5_yuan("0"), 0.0)
}

///|
test "num 深档 my-100" {
  // Money 元值 ｜ 入参=100 ｜ 参照 Double.toString=100.0
  assert_eq(n5_yuan("100"), 100.0)
}

///|
test "num 深档 my-0p005" {
  // Money 元值 ｜ 入参=0.005 ｜ 参照 Double.toString=0.0
  assert_eq(n5_yuan("0.005"), 0.0)
}

///|
test "num 深档 my-m1p00" {
  // Money 元值 ｜ 入参=-1.00 ｜ 参照 Double.toString=-1.0
  assert_eq(n5_yuan("-1.00"), -1.0)
}

///|
test "num 深档 ms-1.5" {
  // Money 串形 ｜ 入参=1.5 ｜ 参照 toString=1.50
  assert_eq(n5_str("1.5"), "1.50")
}

///|
test "num 深档 ms-0.07" {
  // Money 串形 ｜ 入参=0.07 ｜ 参照 toString=0.07
  assert_eq(n5_str("0.07"), "0.07")
}

///|
test "num 深档 ms-m3.21" {
  // Money 串形 ｜ 入参=-3.21 ｜ 参照 toString=-3.21
  assert_eq(n5_str("-3.21"), "-3.21")
}

///|
test "num 深档 ms-12345678.99" {
  // Money 串形 ｜ 入参=12345678.99 ｜ 参照 toString=12345678.99
  assert_eq(n5_str("12345678.99"), "12345678.99")
}

///|
test "num 深档 ms-0" {
  // Money 串形 ｜ 入参=0 ｜ 参照 toString=0.00
  assert_eq(n5_str("0"), "0.00")
}

///|
test "num 深档 ms-100" {
  // Money 串形 ｜ 入参=100 ｜ 参照 toString=100.00
  assert_eq(n5_str("100"), "100.00")
}

///|
test "num 深档 ms-0.005" {
  // Money 串形 ｜ 入参=0.005 ｜ 参照 toString=0.00
  assert_eq(n5_str("0.005"), "0.00")
}

///|
test "num 深档 ms-m1.00" {
  // Money 串形 ｜ 入参=-1.00 ｜ 参照 toString=-1.00
  assert_eq(n5_str("-1.00"), "-1.00")
}

///|
test "num 深档 mb-1" {
  // Money 坏输入 ｜ 入参='' ｜ 参照=ERR:NumberFormatException:null
  assert_eq(n5_tag_of_text(""), false)
}

///|
test "num 深档 mb-2" {
  // Money 坏输入 ｜ 入参='abc' ｜ 参照=ERR:NumberFormatException:Character a is neither a decimal digit number, decimal point, nor "e" notation exponential mark.
  assert_eq(n5_tag_of_text("abc"), false)
}

///|
test "num 深档 mb-3" {
  // Money 坏输入 ｜ 入参='1.2.3' ｜ 参照=ERR:NumberFormatException:Character array contains more than one decimal point.
  assert_eq(n5_tag_of_text("1.2.3"), false)
}

///|
test "num 深档 mb-4" {
  // Money 坏输入 ｜ 入参='-' ｜ 参照=ERR:NumberFormatException:No digits found.
  assert_eq(n5_tag_of_text("-"), false)
}

///|
test "num 深档 mb-5" {
  // Money 坏输入 ｜ 入参='1e3' ｜ 参照=1000.0 ｜本库形状=false（依据 08-num §12 表对应行）
  assert_eq(n5_tag_of_text("1e3"), false)
}

///|
test "num 深档 mb-6" {
  // Money 坏输入 ｜ 入参='1..2' ｜ 参照=ERR:NumberFormatException:Character array contains more than one decimal point.
  assert_eq(n5_tag_of_text("1..2"), false)
}

///|
test "num 深档 mb-7" {
  // Money 坏输入 ｜ 入参=' ' ｜ 参照=ERR:NumberFormatException:Character   is neither a decimal digit number, decimal point, nor "e" notation exponential mark.
  assert_eq(n5_tag_of_text(" "), false)
}

///|
test "num 深档 ae-1p00-m3" {
  // allocate_even ｜ 入参=['1.00', '-3'] ｜ 参照=ERR:NegativeArraySizeException:-3
  assert_eq(n5_even("1.00", -3), "RAISE")
}

///|
test "num 深档 ae-m1p00-3" {
  // allocate_even ｜ 入参=['-1.00', '3'] ｜ 参照=ERR:ArrayIndexOutOfBoundsException:Index -1 out of bounds for length 3 ｜本库形状="-34;-33;-33"（依据 08-num §12 表对应行）
  assert_eq(n5_even("-1.00", 3), "-34;-33;-33")
}

///|
test "num 深档 ae-inv-m1p00-3" {
  // allocate_even 负档不变量 ｜ 入参=['-1.00', '3'] ｜ 参照=ERR:ArrayIndexOutOfBoundsException:Index -1 out of bounds for length 3（#8.23：负档不进对撞，改由不变量钉）
  assert_eq(n5_even_sum("-1.00", 3), -100L)
}

///|
test "num 深档 ae-0p05-2" {
  // allocate_even ｜ 入参=['0.05', '2'] ｜ 参照=3;2
  assert_eq(n5_even("0.05", 2), "3;2")
}

///|
test "num 深档 ae-10p00-7" {
  // allocate_even ｜ 入参=['10.00', '7'] ｜ 参照=143;143;143;143;143;143;142
  assert_eq(n5_even("10.00", 7), "143;143;143;143;143;143;142")
}

///|
test "num 深档 ar-1p00-1_1_1" {
  // allocate_by_ratio ｜ 入参=['1.00', '1,1,1'] ｜ 参照=34;33;33
  assert_eq(n5_ratio("1.00", [1, 1, 1]), "34;33;33")
}

///|
test "num 深档 ar-m1p00-1_1_1" {
  // allocate_by_ratio ｜ 入参=['-1.00', '1,1,1'] ｜ 参照=-33;-33;-33 ｜本库形状="-34;-33;-33"（依据 08-num §12 表对应行）
  assert_eq(n5_ratio("-1.00", [1, 1, 1]), "-34;-33;-33")
}

///|
test "num 深档 ar-inv-m1p00-1_1_1" {
  // allocate_by_ratio 负档不变量 ｜ 入参=['-1.00', '1,1,1'] ｜ 参照=-33;-33;-33（#8.24 同一条）
  assert_eq(n5_ratio_sum("-1.00", [1, 1, 1]), -100L)
}

///|
test "num 深档 ar-10p01-3_7" {
  // allocate_by_ratio ｜ 入参=['10.01', '3,7'] ｜ 参照=301;700
  assert_eq(n5_ratio("10.01", [3, 7]), "301;700")
}

///|
test "num 深档 ar-0p03-1_1_1" {
  // allocate_by_ratio ｜ 入参=['0.03', '1,1,1'] ｜ 参照=1;1;1
  assert_eq(n5_ratio("0.03", [1, 1, 1]), "1;1;1")
}

///|
test "num 深档 cf-0" {
  // chinese_of ｜ 入参=0 ｜ 参照 format(v,false)=零
  assert_eq(n5_cn("0"), "零")
}

///|
test "num 深档 cf-1" {
  // chinese_of ｜ 入参=1 ｜ 参照 format(v,false)=一
  assert_eq(n5_cn("1"), "一")
}

///|
test "num 深档 cf-10" {
  // chinese_of ｜ 入参=10 ｜ 参照 format(v,false)=一十
  assert_eq(n5_cn("10"), "一十")
}

///|
test "num 深档 cf-100" {
  // chinese_of ｜ 入参=100 ｜ 参照 format(v,false)=一百
  assert_eq(n5_cn("100"), "一百")
}

///|
test "num 深档 cf-1000" {
  // chinese_of ｜ 入参=1000 ｜ 参照 format(v,false)=一千
  assert_eq(n5_cn("1000"), "一千")
}

///|
test "num 深档 cf-1010" {
  // chinese_of ｜ 入参=1010 ｜ 参照 format(v,false)=一千零一十
  assert_eq(n5_cn("1010"), "一千零一十")
}

///|
test "num 深档 cf-1001" {
  // chinese_of ｜ 入参=1001 ｜ 参照 format(v,false)=一千零一
  assert_eq(n5_cn("1001"), "一千零一")
}

///|
test "num 深档 cf-10010" {
  // chinese_of ｜ 入参=10010 ｜ 参照 format(v,false)=一万零一十
  assert_eq(n5_cn("10010"), "一万零一十")
}

///|
test "num 深档 cf-100000" {
  // chinese_of ｜ 入参=100000 ｜ 参照 format(v,false)=一十万
  assert_eq(n5_cn("100000"), "一十万")
}

///|
test "num 深档 cf-1000000" {
  // chinese_of ｜ 入参=1000000 ｜ 参照 format(v,false)=一百万
  assert_eq(n5_cn("1000000"), "一百万")
}

///|
test "num 深档 cf-10000000" {
  // chinese_of ｜ 入参=10000000 ｜ 参照 format(v,false)=一千万
  assert_eq(n5_cn("10000000"), "一千万")
}

///|
test "num 深档 cf-100000000" {
  // chinese_of ｜ 入参=100000000 ｜ 参照 format(v,false)=一亿
  assert_eq(n5_cn("100000000"), "一亿")
}

///|
test "num 深档 cf-10001000" {
  // chinese_of ｜ 入参=10001000 ｜ 参照 format(v,false)=一千万零一千
  assert_eq(n5_cn("10001000"), "一千万零一千")
}

///|
test "num 深档 cf-100000100" {
  // chinese_of ｜ 入参=100000100 ｜ 参照 format(v,false)=一亿零一百
  assert_eq(n5_cn("100000100"), "一亿零一百")
}

///|
test "num 深档 cf-20000000" {
  // chinese_of ｜ 入参=20000000 ｜ 参照 format(v,false)=二千万
  assert_eq(n5_cn("20000000"), "二千万")
}

///|
test "num 深档 cf-100010001" {
  // chinese_of ｜ 入参=100010001 ｜ 参照 format(v,false)=一亿零一万零一
  assert_eq(n5_cn("100010001"), "一亿零一万零一")
}

///|
test "num 深档 cfu-0" {
  // chinese_upper_of ｜ 入参=0 ｜ 参照 format(v,true)=零
  assert_eq(n5_cn_upper("0"), "零")
}

///|
test "num 深档 cfu-1" {
  // chinese_upper_of ｜ 入参=1 ｜ 参照 format(v,true)=壹
  assert_eq(n5_cn_upper("1"), "壹")
}

///|
test "num 深档 cfu-10" {
  // chinese_upper_of ｜ 入参=10 ｜ 参照 format(v,true)=壹拾
  assert_eq(n5_cn_upper("10"), "壹拾")
}

///|
test "num 深档 cfu-100" {
  // chinese_upper_of ｜ 入参=100 ｜ 参照 format(v,true)=壹佰
  assert_eq(n5_cn_upper("100"), "壹佰")
}

///|
test "num 深档 cfu-1000" {
  // chinese_upper_of ｜ 入参=1000 ｜ 参照 format(v,true)=壹仟
  assert_eq(n5_cn_upper("1000"), "壹仟")
}

///|
test "num 深档 cfu-1010" {
  // chinese_upper_of ｜ 入参=1010 ｜ 参照 format(v,true)=壹仟零壹拾
  assert_eq(n5_cn_upper("1010"), "壹仟零壹拾")
}

///|
test "num 深档 cfu-1001" {
  // chinese_upper_of ｜ 入参=1001 ｜ 参照 format(v,true)=壹仟零壹
  assert_eq(n5_cn_upper("1001"), "壹仟零壹")
}

///|
test "num 深档 cfu-10010" {
  // chinese_upper_of ｜ 入参=10010 ｜ 参照 format(v,true)=壹万零壹拾
  assert_eq(n5_cn_upper("10010"), "壹万零壹拾")
}

///|
test "num 深档 cfu-100000" {
  // chinese_upper_of ｜ 入参=100000 ｜ 参照 format(v,true)=壹拾万
  assert_eq(n5_cn_upper("100000"), "壹拾万")
}

///|
test "num 深档 cfu-1000000" {
  // chinese_upper_of ｜ 入参=1000000 ｜ 参照 format(v,true)=壹佰万
  assert_eq(n5_cn_upper("1000000"), "壹佰万")
}

///|
test "num 深档 cfu-10000000" {
  // chinese_upper_of ｜ 入参=10000000 ｜ 参照 format(v,true)=壹仟万
  assert_eq(n5_cn_upper("10000000"), "壹仟万")
}

///|
test "num 深档 cfu-100000000" {
  // chinese_upper_of ｜ 入参=100000000 ｜ 参照 format(v,true)=壹亿
  assert_eq(n5_cn_upper("100000000"), "壹亿")
}

///|
test "num 深档 cfu-10001000" {
  // chinese_upper_of ｜ 入参=10001000 ｜ 参照 format(v,true)=壹仟万零壹仟
  assert_eq(n5_cn_upper("10001000"), "壹仟万零壹仟")
}

///|
test "num 深档 cfu-100000100" {
  // chinese_upper_of ｜ 入参=100000100 ｜ 参照 format(v,true)=壹亿零壹佰
  assert_eq(n5_cn_upper("100000100"), "壹亿零壹佰")
}

///|
test "num 深档 cfu-20000000" {
  // chinese_upper_of ｜ 入参=20000000 ｜ 参照 format(v,true)=贰仟万
  assert_eq(n5_cn_upper("20000000"), "贰仟万")
}

///|
test "num 深档 cfu-100010001" {
  // chinese_upper_of ｜ 入参=100010001 ｜ 参照 format(v,true)=壹亿零壹万零壹
  assert_eq(n5_cn_upper("100010001"), "壹亿零壹万零壹")
}

///|
test "num 深档 rn-1" {
  // int_of_chinese ｜ 入参=零 ｜ 参照=0
  assert_eq(n5_int("零"), "0")
}

///|
test "num 深档 rn-2" {
  // int_of_chinese ｜ 入参=一百 ｜ 参照=100
  assert_eq(n5_int("一百"), "100")
}

///|
test "num 深档 rn-3" {
  // int_of_chinese ｜ 入参=一千零一 ｜ 参照=1001
  assert_eq(n5_int("一千零一"), "1001")
}

///|
test "num 深档 rn-4" {
  // int_of_chinese ｜ 入参=一万 ｜ 参照=10000
  assert_eq(n5_int("一万"), "10000")
}

///|
test "num 深档 rn-5" {
  // int_of_chinese ｜ 入参=十万 ｜ 参照=100000
  assert_eq(n5_int("十万"), "100000")
}

///|
test "num 深档 rn-6" {
  // int_of_chinese ｜ 入参=一百万 ｜ 参照=1000000
  assert_eq(n5_int("一百万"), "1000000")
}

///|
test "num 深档 rn-7" {
  // int_of_chinese ｜ 入参=一千万 ｜ 参照=10000000
  assert_eq(n5_int("一千万"), "10000000")
}

///|
test "num 深档 rn-8" {
  // int_of_chinese ｜ 入参=一亿 ｜ 参照=100000000
  assert_eq(n5_int("一亿"), "100000000")
}

///|
test "num 深档 rn-9" {
  // int_of_chinese ｜ 入参=一二三 ｜ 参照=ERR:IllegalArgumentException:Bad number '一二' at: 1
  assert_eq(n5_int("一二三"), "RAISE")
}

///|
test "num 深档 rn-10" {
  // int_of_chinese ｜ 入参=abc ｜ 参照=ERR:IllegalArgumentException:Unknown unit 'a' at: 0
  assert_eq(n5_int("abc"), "RAISE")
}

///|
test "num 深档 rn-11" {
  // int_of_chinese ｜ 入参= ｜ 参照=0 ｜本库形状="RAISE"（依据 08-num §12 表对应行）
  assert_eq(n5_int(""), "RAISE")
}

///|
test "num 深档 rn-12" {
  // int_of_chinese ｜ 入参=壹佰贰拾叁拾肆万伍仟陆佰柒拾捌元玖角玖分 ｜ 参照=ERR:IllegalArgumentException:Unknown unit '元' at: 15
  assert_eq(
    n5_int("壹佰贰拾叁拾肆万伍仟陆佰柒拾捌元玖角玖分"),
    "RAISE",
  )
}

///|
test "num 深档 rn-13" {
  // int_of_chinese ｜ 入参=壹元 ｜ 参照=ERR:IllegalArgumentException:Unknown unit '元' at: 1
  assert_eq(n5_int("壹元"), "RAISE")
}

///|
test "num 深档 rm-1" {
  // money_of_chinese ｜ 入参=零 ｜ 参照=0.00
  assert_eq(n5_money("零"), "0.00")
}

///|
test "num 深档 rm-2" {
  // money_of_chinese ｜ 入参=一百 ｜ 参照=0.00 ｜本库形状="100.00"（依据 08-num §12 表对应行）
  assert_eq(n5_money("一百"), "100.00")
}

///|
test "num 深档 rm-3" {
  // money_of_chinese ｜ 入参=一千零一 ｜ 参照=0.00 ｜本库形状="1001.00"（依据 08-num §12 表对应行）
  assert_eq(n5_money("一千零一"), "1001.00")
}

///|
test "num 深档 rm-4" {
  // money_of_chinese ｜ 入参=一万 ｜ 参照=0.00 ｜本库形状="10000.00"（依据 08-num §12 表对应行）
  assert_eq(n5_money("一万"), "10000.00")
}

///|
test "num 深档 rm-5" {
  // money_of_chinese ｜ 入参=十万 ｜ 参照=0.00 ｜本库形状="100000.00"（依据 08-num §12 表对应行）
  assert_eq(n5_money("十万"), "100000.00")
}

///|
test "num 深档 rm-6" {
  // money_of_chinese ｜ 入参=一百万 ｜ 参照=0.00 ｜本库形状="1000000.00"（依据 08-num §12 表对应行）
  assert_eq(n5_money("一百万"), "1000000.00")
}

///|
test "num 深档 rm-7" {
  // money_of_chinese ｜ 入参=一千万 ｜ 参照=0.00 ｜本库形状="10000000.00"（依据 08-num §12 表对应行）
  assert_eq(n5_money("一千万"), "10000000.00")
}

///|
test "num 深档 rm-8" {
  // money_of_chinese ｜ 入参=一亿 ｜ 参照=0.00 ｜本库形状="100000000.00"（依据 08-num §12 表对应行）
  assert_eq(n5_money("一亿"), "100000000.00")
}

///|
test "num 深档 rm-9" {
  // money_of_chinese ｜ 入参=一二三 ｜ 参照=0.00 ｜本库形状="RAISE"（依据 08-num §12 表对应行）
  assert_eq(n5_money("一二三"), "RAISE")
}

///|
test "num 深档 rm-10" {
  // money_of_chinese ｜ 入参=abc ｜ 参照=0.00 ｜本库形状="RAISE"（依据 08-num §12 表对应行）
  assert_eq(n5_money("abc"), "RAISE")
}

///|
test "num 深档 rm-11" {
  // money_of_chinese ｜ 入参= ｜ 参照=null ｜本库形状="RAISE"（依据 08-num §12 表对应行）
  assert_eq(n5_money(""), "RAISE")
}

///|
test "num 深档 rm-12" {
  // money_of_chinese ｜ 入参=壹佰贰拾叁拾肆万伍仟陆佰柒拾捌元玖角玖分 ｜ 参照=1545678.99
  assert_eq(
    n5_money("壹佰贰拾叁拾肆万伍仟陆佰柒拾捌元玖角玖分"),
    "1545678.99",
  )
}

///|
test "num 深档 rm-13" {
  // money_of_chinese ｜ 入参=壹元 ｜ 参照=1.00
  assert_eq(n5_money("壹元"), "1.00")
}

///|
test "num 深档 rb-1" {
  // int_of_chinese 万万档 ｜ 入参=九千九百九十九万万 ｜ 参照=99990000
  assert_eq(n5_int("九千九百九十九万万"), "99990000")
}

///|
test "num 深档 rb-2" {
  // int_of_chinese 万万档 ｜ 入参=九百九十九万九千九百九十九万万 ｜ 参照=109980000
  assert_eq(
    n5_int("九百九十九万九千九百九十九万万"),
    "109980000",
  )
}

///|
test "num 深档 rb-3" {
  // int_of_chinese 万万档 ｜ 入参=十亿 ｜ 参照=1000000000
  assert_eq(n5_int("十亿"), "1000000000")
}

///|
test "num 深档 rbm-1" {
  // money_of_chinese 万万档 ｜ 入参=九千九百九十九万万 ｜ 参照=0.00 ｜本库形状="99990000.00"（依据 08-num §12 表对应行）
  assert_eq(n5_money("九千九百九十九万万"), "99990000.00")
}

///|
test "num 深档 rbm-2" {
  // money_of_chinese 万万档 ｜ 入参=九百九十九万九千九百九十九万万 ｜ 参照=0.00 ｜本库形状="109980000.00"（依据 08-num §12 表对应行）
  assert_eq(
    n5_money("九百九十九万九千九百九十九万万"),
    "109980000.00",
  )
}

///|
test "num 深档 rbm-3" {
  // money_of_chinese 万万档 ｜ 入参=十亿 ｜ 参照=0.00 ｜本库形状="1000000000.00"（依据 08-num §12 表对应行）
  assert_eq(n5_money("十亿"), "1000000000.00")
}

///|
test "num 深档 ac-0" {
  // chinese_abbrev ｜ 入参=0 ｜ 参照 formatSimple=0
  assert_eq(n5_abcn(0L), "0")
}

///|
test "num 深档 ac-1000" {
  // chinese_abbrev ｜ 入参=1000 ｜ 参照 formatSimple=1000
  assert_eq(n5_abcn(1000L), "1000")
}

///|
test "num 深档 ac-1005" {
  // chinese_abbrev ｜ 入参=1005 ｜ 参照 formatSimple=1005
  assert_eq(n5_abcn(1005L), "1005")
}

///|
test "num 深档 ac-10050" {
  // chinese_abbrev ｜ 入参=10050 ｜ 参照 formatSimple=1.01万
  assert_eq(n5_abcn(10050L), "1.01万")
}

///|
test "num 深档 ac-10150" {
  // chinese_abbrev ｜ 入参=10150 ｜ 参照 formatSimple=1.02万
  assert_eq(n5_abcn(10150L), "1.02万")
}

///|
test "num 深档 ac-10500" {
  // chinese_abbrev ｜ 入参=10500 ｜ 参照 formatSimple=1.05万
  assert_eq(n5_abcn(10500L), "1.05万")
}

///|
test "num 深档 ac-100000" {
  // chinese_abbrev ｜ 入参=100000 ｜ 参照 formatSimple=10.0万 ｜本库形状="10.00万"（依据 08-num §12 表对应行）
  assert_eq(n5_abcn(100000L), "10.00万")
}

///|
test "num 深档 ac-105000" {
  // chinese_abbrev ｜ 入参=105000 ｜ 参照 formatSimple=10.5万 ｜本库形状="10.50万"（依据 08-num §12 表对应行）
  assert_eq(n5_abcn(105000L), "10.50万")
}

///|
test "num 深档 ac-1000000" {
  // chinese_abbrev ｜ 入参=1000000 ｜ 参照 formatSimple=100.0万 ｜本库形状="100.00万"（依据 08-num §12 表对应行）
  assert_eq(n5_abcn(1000000L), "100.00万")
}

///|
test "num 深档 ac-10050000" {
  // chinese_abbrev ｜ 入参=10050000 ｜ 参照 formatSimple=1005.0万 ｜本库形状="1005.00万"（依据 08-num §12 表对应行）
  assert_eq(n5_abcn(10050000L), "1005.00万")
}

///|
test "num 深档 ac-m10050" {
  // chinese_abbrev ｜ 入参=-10050 ｜ 参照 formatSimple=-1.01万
  assert_eq(n5_abcn(-10050L), "-1.01万")
}

///|
test "num 深档 aw-0" {
  // english_abbrev ｜ 入参=0 ｜ 参照 formatSimple=0
  assert_eq(n5_aben(0L), "0")
}

///|
test "num 深档 aw-1000" {
  // english_abbrev ｜ 入参=1000 ｜ 参照 formatSimple=1k
  assert_eq(n5_aben(1000L), "1k")
}

///|
test "num 深档 aw-1005" {
  // english_abbrev ｜ 入参=1005 ｜ 参照 formatSimple=1k ｜本库形状="1.01k"（依据 08-num §12 表对应行）
  assert_eq(n5_aben(1005L), "1.01k")
}

///|
test "num 深档 aw-10050" {
  // english_abbrev ｜ 入参=10050 ｜ 参照 formatSimple=1.01w
  assert_eq(n5_aben(10050L), "1.01w")
}

///|
test "num 深档 aw-10150" {
  // english_abbrev ｜ 入参=10150 ｜ 参照 formatSimple=1.02w
  assert_eq(n5_aben(10150L), "1.02w")
}

///|
test "num 深档 aw-10500" {
  // english_abbrev ｜ 入参=10500 ｜ 参照 formatSimple=1.05w
  assert_eq(n5_aben(10500L), "1.05w")
}

///|
test "num 深档 aw-100000" {
  // english_abbrev ｜ 入参=100000 ｜ 参照 formatSimple=10w
  assert_eq(n5_aben(100000L), "10w")
}

///|
test "num 深档 aw-105000" {
  // english_abbrev ｜ 入参=105000 ｜ 参照 formatSimple=10.5w
  assert_eq(n5_aben(105000L), "10.5w")
}

///|
test "num 深档 aw-1000000" {
  // english_abbrev ｜ 入参=1000000 ｜ 参照 formatSimple=100w
  assert_eq(n5_aben(1000000L), "100w")
}

///|
test "num 深档 aw-10050000" {
  // english_abbrev ｜ 入参=10050000 ｜ 参照 formatSimple=1005w
  assert_eq(n5_aben(10050000L), "1005w")
}

///|
test "num 深档 aw-m10050" {
  // english_abbrev ｜ 入参=-10050 ｜ 参照 formatSimple=-10050
  assert_eq(n5_aben(-10050L), "-10050")
}

///|
test "num 深档 cc-1" {
  // num_calculate 负指数档 ｜ 入参=1e-3 ｜ 参照=0.001
  assert_eq(n5_calc("1e-3"), 0.001)
}

///|
test "num 深档 cc-2" {
  // num_calculate 负指数档 ｜ 入参=2E-2 ｜ 参照=0.02
  assert_eq(n5_calc("2E-2"), 0.02)
}

///|
test "num 深档 cc-3" {
  // num_calculate 负指数档 ｜ 入参=1e-3+1 ｜ 参照=1.001
  assert_eq(n5_calc("1e-3+1"), 1.001)
}

///|
test "num 深档 cc-4" {
  // num_calculate 负指数档 ｜ 入参=1e0 ｜ 参照=1.0
  assert_eq(n5_calc("1e0"), 1.0)
}

///|
test "num 深档 cc-5" {
  // num_calculate 负指数档 ｜ 入参=1e-1 ｜ 参照=0.1
  assert_eq(n5_calc("1e-1"), 0.1)
}

///|
test "num 深档 cc-6" {
  // num_calculate 负指数档 ｜ 入参=0.001 ｜ 参照=0.001
  assert_eq(n5_calc("0.001"), 0.001)
}

///|
test "num 深档 cc-7" {
  // num_calculate 负指数档 ｜ 入参=1e21 ｜ 参照=1.0E21
  assert_eq(n5_calc("1e21"), 1.0E21)
}

///|
test "num 深档 cc-8" {
  // num_calculate 负指数档 ｜ 入参=1e-21 ｜ 参照=1.0E-21
  assert_eq(n5_calc("1e-21"), 1.0E-21)
}
