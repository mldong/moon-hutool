///|
// conv 界外与符号档补档（10-08）——`+`/`-`/空串、`0x` 带符号全族、非有限值、越出位宽、
// NBSP 与全角归一。期望全部由 Conv2Leg.java 现读灌入（hutool-core 5.8.35 · JDK 17.0.14），手打零条。
// 参照改判档钉本库形状、把参照原读数留在注释里（依据见 docs/spec/09-conv.md §5）。
// `0x` 那九档是 §9.1 缺陷修好之后重测的：本库值与参照逐条相等，不需要改判。

///|
test "conv 界外 ti-plus" {
  // @conv.to_int(j(...)) ｜ 入参码点=2b ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"+\"")), None)
}

///|
test "conv 界外 t64-plus" {
  // @conv.to_int64(j(...)) ｜ 入参码点=2b ｜ 参照 Convert.toLong=null
  assert_eq(@conv.to_int64(j("\"+\"")), None)
}

///|
test "conv 界外 ti-minus" {
  // @conv.to_int(j(...)) ｜ 入参码点=2d ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"-\"")), None)
}

///|
test "conv 界外 t64-minus" {
  // @conv.to_int64(j(...)) ｜ 入参码点=2d ｜ 参照 Convert.toLong=null
  assert_eq(@conv.to_int64(j("\"-\"")), None)
}

///|
test "conv 界外 ti-empty" {
  // @conv.to_int(j(...)) ｜ 入参码点= ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"\"")), None)
}

///|
test "conv 界外 t64-empty" {
  // @conv.to_int64(j(...)) ｜ 入参码点= ｜ 参照 Convert.toLong=null
  assert_eq(@conv.to_int64(j("\"\"")), None)
}

///|
test "conv 界外 ti-dotdash" {
  // @conv.to_int(j(...)) ｜ 入参码点=31+2e+65 ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"1.e\"")), None)
}

///|
test "conv 界外 t64-dotdash" {
  // @conv.to_int64(j(...)) ｜ 入参码点=31+2e+65 ｜ 参照 Convert.toLong=1（本库改判：整串匹配文法，不跟随参照的前缀解析，见 09-conv 分岔表）
  assert_eq(@conv.to_int64(j("\"1.e\"")), None)
}

///|
test "conv 界外 ti-hexsign" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+78+2b+31+46 ｜ 参照 Convert.toInt=1
  assert_eq(@conv.to_int(j("\"0x+1F\"")), Some(1))
}

///|
test "conv 界外 t64-hexsign" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+78+2b+31+46 ｜ 参照 Convert.toLong=1
  assert_eq(@conv.to_int64(j("\"0x+1F\"")), Some(1))
}

///|
test "conv 界外 ti-hexneg" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+78+2d+31+46 ｜ 参照 Convert.toInt=-1
  assert_eq(@conv.to_int(j("\"0x-1F\"")), Some(-1))
}

///|
test "conv 界外 t64-hexneg" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+78+2d+31+46 ｜ 参照 Convert.toLong=-1
  assert_eq(@conv.to_int64(j("\"0x-1F\"")), Some(-1))
}

///|
test "conv 界外 ti-hexplus" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+78+2b ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"0x+\"")), None)
}

///|
test "conv 界外 t64-hexplus" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+78+2b ｜ 参照 Convert.toLong=null
  assert_eq(@conv.to_int64(j("\"0x+\"")), None)
}

///|
test "conv 界外 ti-hexminus" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+78+2d ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"0x-\"")), None)
}

///|
test "conv 界外 t64-hexminus" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+78+2d ｜ 参照 Convert.toLong=null
  assert_eq(@conv.to_int64(j("\"0x-\"")), None)
}

///|
test "conv 界外 ti-hexone" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+78+2b+31 ｜ 参照 Convert.toInt=1
  assert_eq(@conv.to_int(j("\"0x+1\"")), Some(1))
}

///|
test "conv 界外 t64-hexone" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+78+2b+31 ｜ 参照 Convert.toLong=1
  assert_eq(@conv.to_int64(j("\"0x+1\"")), Some(1))
}

///|
test "conv 界外 ti-hexg" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+78+2b+47 ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"0x+G\"")), None)
}

///|
test "conv 界外 t64-hexg" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+78+2b+47 ｜ 参照 Convert.toLong=null
  assert_eq(@conv.to_int64(j("\"0x+G\"")), None)
}

///|
test "conv 界外 ti-hexmulti" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+78+66+66 ｜ 参照 Convert.toInt=15
  assert_eq(@conv.to_int(j("\"0xff\"")), Some(15))
}

///|
test "conv 界外 t64-hexmulti" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+78+66+66 ｜ 参照 Convert.toLong=15
  assert_eq(@conv.to_int64(j("\"0xff\"")), Some(15))
}

///|
test "conv 界外 ti-hexuppersign" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+58+2b+46 ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"0X+F\"")), None)
}

///|
test "conv 界外 t64-hexuppersign" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+58+2b+46 ｜ 参照 Convert.toLong=null
  assert_eq(@conv.to_int64(j("\"0X+F\"")), None)
}

///|
test "conv 界外 ti-hexbig" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+78+46+46+46+46+46+46+46+46+46+46 ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"0xFFFFFFFFFF\"")), None)
}

///|
test "conv 界外 t64-hexbig" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+78+46+46+46+46+46+46+46+46+46+46 ｜ 参照 Convert.toLong=68719476735
  assert_eq(@conv.to_int64(j("\"0xFFFFFFFFFF\"")), Some(68719476735))
}

///|
test "conv 界外 ti-hexd" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+78+31+46+4c ｜ 参照 Convert.toInt=31
  assert_eq(@conv.to_int(j("\"0x1FL\"")), Some(31))
}

///|
test "conv 界外 t64-hexd" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+78+31+46+4c ｜ 参照 Convert.toLong=31
  assert_eq(@conv.to_int64(j("\"0x1FL\"")), Some(31))
}

///|
test "conv 界外 ti-hexsignmulti" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+78+2d+66+66 ｜ 参照 Convert.toInt=-15
  assert_eq(@conv.to_int(j("\"0x-ff\"")), Some(-15))
}

///|
test "conv 界外 t64-hexsignmulti" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+78+2d+66+66 ｜ 参照 Convert.toLong=-15
  assert_eq(@conv.to_int64(j("\"0x-ff\"")), Some(-15))
}

///|
test "conv 界外 ti-hexupper" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+58+31+46 ｜ 参照 Convert.toInt=1
  assert_eq(@conv.to_int(j("\"0X1F\"")), Some(1))
}

///|
test "conv 界外 t64-hexupper" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+58+31+46 ｜ 参照 Convert.toLong=1
  assert_eq(@conv.to_int64(j("\"0X1F\"")), Some(1))
}

///|
test "conv 界外 ti-hexbig64" {
  // @conv.to_int(j(...)) ｜ 入参码点=30+78+37+46+46+46+46+46+46+46+46+46+46+46+46+46+46+46+30+30 ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"0x7FFFFFFFFFFFFFFF00\"")), None)
}

///|
test "conv 界外 t64-hexbig64" {
  // @conv.to_int64(j(...)) ｜ 入参码点=30+78+37+46+46+46+46+46+46+46+46+46+46+46+46+46+46+46+30+30 ｜ 参照 Convert.toLong=null
  assert_eq(@conv.to_int64(j("\"0x7FFFFFFFFFFFFFFF00\"")), None)
}

///|
test "conv 界外 ti-big1e20" {
  // @conv.to_int(j(...)) ｜ 入参码点=31+65+32+30 ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"1e20\"")), None)
}

///|
test "conv 界外 t64-big1e20" {
  // @conv.to_int64(j(...)) ｜ 入参码点=31+65+32+30 ｜ 参照 Convert.toLong=1（本库改判：整串匹配文法，不跟随参照的前缀解析，见 09-conv 分岔表）
  assert_eq(@conv.to_int64(j("\"1e20\"")), None)
}

///|
test "conv 界外 ti-big1e100" {
  // @conv.to_int(j(...)) ｜ 入参码点=31+65+31+30+30 ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"1e100\"")), None)
}

///|
test "conv 界外 t64-big1e100" {
  // @conv.to_int64(j(...)) ｜ 入参码点=31+65+31+30+30 ｜ 参照 Convert.toLong=1（本库改判：整串匹配文法，不跟随参照的前缀解析，见 09-conv 分岔表）
  assert_eq(@conv.to_int64(j("\"1e100\"")), None)
}

///|
test "conv 界外 ti-nan" {
  // @conv.to_int(j(...)) ｜ 入参码点=4e+61+4e ｜ 参照 Convert.toInt=0（本库改判：整串匹配文法，不跟随参照的前缀解析，见 09-conv 分岔表）
  assert_eq(@conv.to_int(j("\"NaN\"")), None)
}

///|
test "conv 界外 t64-nan" {
  // @conv.to_int64(j(...)) ｜ 入参码点=4e+61+4e ｜ 参照 Convert.toLong=0（本库改判：整串匹配文法，不跟随参照的前缀解析，见 09-conv 分岔表）
  assert_eq(@conv.to_int64(j("\"NaN\"")), None)
}

///|
test "conv 界外 ti-inf" {
  // @conv.to_int(j(...)) ｜ 入参码点=49+6e+66+69+6e+69+74+79 ｜ 参照 Convert.toInt=null
  assert_eq(@conv.to_int(j("\"Infinity\"")), None)
}

///|
test "conv 界外 t64-inf" {
  // @conv.to_int64(j(...)) ｜ 入参码点=49+6e+66+69+6e+69+74+79 ｜ 参照 Convert.toLong=null
  assert_eq(@conv.to_int64(j("\"Infinity\"")), None)
}

///|
test "conv 界外 ti-nbsp" {
  // @conv.to_int(j(...)) ｜ 入参码点=31+a0+32 ｜ 参照 Convert.toInt=1（本库改判：整串匹配文法，不跟随参照的前缀解析，见 09-conv 分岔表）
  assert_eq(@conv.to_int(j("\"1\u00a02\"")), None)
}

///|
test "conv 界外 t64-nbsp" {
  // @conv.to_int64(j(...)) ｜ 入参码点=31+a0+32 ｜ 参照 Convert.toLong=1（本库改判：整串匹配文法，不跟随参照的前缀解析，见 09-conv 分岔表）
  assert_eq(@conv.to_int64(j("\"1\u00a02\"")), None)
}

///|
test "conv 界外 ti-fullwidth" {
  // @conv.to_int(j(...)) ｜ 入参码点=ff11+ff12+ff13 ｜ 参照 Convert.toInt=123
  assert_eq(@conv.to_int(j("\"\uff11\uff12\uff13\"")), Some(123))
}

///|
test "conv 界外 t64-fullwidth" {
  // @conv.to_int64(j(...)) ｜ 入参码点=ff11+ff12+ff13 ｜ 参照 Convert.toLong=123
  assert_eq(@conv.to_int64(j("\"\uff11\uff12\uff13\"")), Some(123))
}

///|
test "conv 界外 ti-spacey" {
  // @conv.to_int(j(...)) ｜ 入参码点=20+34+32+20 ｜ 参照 Convert.toInt=42
  assert_eq(@conv.to_int(j("\" 42 \"")), Some(42))
}

///|
test "conv 界外 t64-spacey" {
  // @conv.to_int64(j(...)) ｜ 入参码点=20+34+32+20 ｜ 参照 Convert.toLong=42
  assert_eq(@conv.to_int64(j("\" 42 \"")), Some(42))
}
