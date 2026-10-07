///|
// 本文件是生成物：`python scripts/gen_num4_test.py <腿.tsv> --test num/calc_test.mbt`
// 期望值只从参照腿 `scripts/Num4Leg.java` 的读数来；本生成器另带一份**独立求值器**，
// 它不产期望值，只做两件事：① 腿给数值的每一格都必须与求值器同值（不同值就拒绝生成），
// ② 给 §11.4 第 17 行那族"式子合法、参照自己崩"的格子取值（注释里逐格写明参照读数）。
// 契约与形状决策：docs/spec/08-num.md §11。改任何一条期望串须单独一笔并给外部读数来源（门禁 G5）。
// 一条读数解释的坑：Java 的 `Double.toString` 不总给最短表示——腿把 `1e23` 打成 `9.999999999999999E22`，
// 那与十进制精确值 `1e23` 落进 `Double` 是同一个数（`new BigDecimal(1e23)` ⇒ `99999999999999991611392`）。
// 本文件比对的是两侧的 `Double`，所以期望写 `(1.0e23)` 是**对的**，别照腿的字面串去"改错期望"。

///|
// 值档：抛错就意味着"这一格本该有答案"，直接 abort 让块红得看得见
fn calc_val(body : String) -> Double {
  @num.num_calculate(body) catch {
    _ => abort("不该抛错：" + body)
  }
}

///|
// 错误档：只带变体名；`NotDecimal` 带 token（参照那句 `Unparseable number: "x"` 的就是 x）。
// 末档兜住 `NumError` 的其余变体（这件的匹配必须穷尽，否则 `partial_match` 判错）：
// 真落到兜底就说明本库把这格抛成了别的档，`show` 把变体名原样报出来，块直接红。
fn calc_err(body : String) -> String {
  try {
    let _ = @num.num_calculate(body)
    "未抛错"
  } catch {
    @num.BadExpression(_) => "BadExpression"
    @num.NotDecimal(t) => "NotDecimal \{t}"
    @num.DivZero => "DivZero"
    e => "其他 " + show(e)
  }
}

///|
// #8.40 第四批（Calculator）第 1 块：12 格，每格一条腿读数
test "calc 1" {
  assert_eq(calc_val("5+12*(3+5)/7"), 18.7142857143) // 腿 RET
  assert_eq(calc_val("1+2*3"), 7.0) // 腿 RET
  assert_eq(calc_val("(1+2)*3"), 9.0) // 腿 RET
  assert_eq(calc_val("10-4-3"), 3.0) // 腿 RET
  assert_eq(calc_val("10-(4-3)"), 9.0) // 腿 RET
  assert_eq(calc_val("2*3+4*5"), 26.0) // 腿 RET
  assert_eq(calc_val("1/2"), 0.5) // 腿 RET
  assert_eq(calc_val("1/3"), 0.3333333333) // 腿 RET
  assert_eq(calc_val("2/3"), 0.6666666667) // 腿 RET
  assert_eq(calc_val("-1/3"), -0.3333333333) // 腿 RET
  assert_eq(calc_val("1/-3"), -0.3333333333) // 腿 RET
  assert_eq(calc_val("7%3"), 1.0) // 腿 RET
}

///|
// #8.40 第四批（Calculator）第 2 块：12 格，每格一条腿读数
test "calc 2" {
  assert_eq(calc_val("-7%3"), -1.0) // 腿 RET
  assert_eq(calc_err("7%-3"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_val("10/4"), 2.5) // 腿 RET
  assert_eq(calc_val("100/8"), 12.5) // 腿 RET
  assert_eq(calc_val("0.1+0.2"), 0.3) // 腿 RET
  assert_eq(calc_val("0.1*3"), 0.3) // 腿 RET
  assert_eq(calc_val("1.005*100"), 100.5) // 腿 RET
  assert_eq(calc_val("0.3-0.1"), 0.2) // 腿 RET
  assert_eq(calc_val("2.675*100"), 267.5) // 腿 RET
  assert_eq(calc_val("1/3*3"), 0.9999999999) // 腿 RET
  assert_eq(calc_val("0.1+0.1+0.1"), 0.3) // 腿 RET
  assert_eq(calc_val("1e3"), 1000.0) // 腿 RET
}

///|
// #8.40 第四批（Calculator）第 3 块：12 格，每格一条腿读数
test "calc 3" {
  assert_eq(calc_val("1E3"), 1000.0) // 腿 RET
  assert_eq(calc_val("3E-2"), 0.03) // 腿 RET
  assert_eq(calc_val("1.5e2+1"), 151.0) // 腿 RET
  assert_eq(calc_val("1e-1"), 0.1) // 腿 RET
  assert_eq(calc_val("0.0000001"), 1.0e-07) // 腿 RET
  assert_eq(calc_val("-5"), -5.0) // 腿 RET
  assert_eq(calc_val("- 5"), -5.0) // 腿 RET
  assert_eq(calc_err("--5"), "NotDecimal -") // 腿 ERR_NumberFormatException|Unparseable number: \"-\"｜token 来源=腿
  assert_eq(calc_val("-(-5)"), 5.0) // 腿 RET
  assert_eq(calc_val("5--3"), 8.0) // 腿 RET
  assert_eq(calc_val("5- -3"), 8.0) // 腿 RET
  assert_eq(calc_val("-5+3"), -2.0) // 腿 RET
}

///|
// #8.40 第四批（Calculator）第 4 块：12 格，每格一条腿读数
test "calc 4" {
  assert_eq(calc_val("(-5)"), -5.0) // 腿 RET
  assert_eq(calc_val("-(1+2)"), -3.0) // 腿 RET
  assert_eq(calc_val("~5"), -5.0) // 腿 RET
  assert_eq(calc_val("2x3"), 6.0) // 腿 RET
  assert_eq(calc_val("2X3"), 6.0) // 腿 RET
  assert_eq(calc_val("0x10"), 0.0) // 腿 RET
  assert_eq(calc_val("2x3x4"), 24.0) // 腿 RET
  assert_eq(calc_val(" 1 + 2 "), 3.0) // 腿 RET
  assert_eq(calc_val("1 +2	"), 3.0) // 腿 RET
  assert_eq(calc_val("1+2="), 3.0) // 腿 RET
  assert_eq(calc_val("1+2=3"), 3.0) // 腿 RET
  assert_eq(calc_err("=1+2"), "NotDecimal =1") // 腿 ERR_NumberFormatException|Unparseable number: \"=1\"｜token 来源=腿
}

///|
// #8.40 第四批（Calculator）第 5 块：12 格，每格一条腿读数
test "calc 5" {
  assert_eq(calc_val("1 2"), 12.0) // 腿 RET
  assert_eq(calc_val("(1+2)(3)"), 9.0) // 腿 RET
  assert_eq(calc_val("(1+2)3"), 9.0) // 腿 RET
  assert_eq(calc_val("2(3)"), 6.0) // 腿 RET
  assert_eq(calc_err("(1+2"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("1+2)"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_val("()"), 0.0) // 腿 RET
  assert_eq(calc_err("("), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err(")"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("((1+2)"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("1+(2*3"), "BadExpression") // 腿 ERR_IllegalStateException|Unexpected value: (｜两档同判
  assert_eq(calc_val(""), 0.0) // 腿 ERR_ArrayIndexOutOfBoundsException|Index 0 out of bounds for length 0｜参照自己崩而式子合法：本库给算术值（spec §11
}

///|
// #8.40 第四批（Calculator）第 6 块：12 格，每格一条腿读数
test "calc 6" {
  assert_eq(calc_val(" "), 0.0) // 腿 ERR_ArrayIndexOutOfBoundsException|Index 0 out of bounds for length 0｜参照自己崩而式子合法：本库给算术值（spec §11
  assert_eq(calc_err("+"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("+1"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("*2"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("/"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("%2"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("-"), "NotDecimal -") // 腿 ERR_NumberFormatException|Unparseable number: \"-\"｜token 来源=腿
  assert_eq(calc_val("="), 0.0) // 腿 ERR_ArrayIndexOutOfBoundsException|Index 0 out of bounds for length 0｜参照自己崩而式子合法：本库给算术值（spec §11
  assert_eq(calc_err("abc"), "NotDecimal abc") // 腿 ERR_NumberFormatException|Unparseable number: \"abc\"｜token 来源=腿
  assert_eq(calc_err("1+abc"), "NotDecimal abc") // 腿 ERR_NumberFormatException|Unparseable number: \"abc\"｜token 来源=腿
  assert_eq(calc_err("一+二"), "NotDecimal 一") // 腿 ERR_NumberFormatException|Unparseable number: \"\u4e00\"｜token 来源=腿
  assert_eq(calc_val("1..2"), 1.0) // 腿 RET
}

///|
// #8.40 第四批（Calculator）第 7 块：12 格，每格一条腿读数
test "calc 7" {
  assert_eq(calc_val("1.2.3"), 1.2) // 腿 RET
  assert_eq(calc_val("1e"), 1.0) // 腿 RET
  assert_eq(calc_err("1e+"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_val("07"), 7.0) // 腿 RET
  assert_eq(calc_val("1,000"), 1000.0) // 腿 RET
  assert_eq(calc_val("1_000"), 1.0) // 腿 RET
  assert_eq(calc_err("$5"), "NotDecimal $5") // 腿 ERR_NumberFormatException|Unparseable number: \"$5\"｜token 来源=腿
  assert_eq(calc_val("1^2"), 1.0) // 腿 RET
  assert_eq(calc_val("2^3^2"), 2.0) // 腿 RET
  assert_eq(calc_val("((((1))))"), 1.0) // 腿 RET
  assert_eq(calc_err("1+(2+(3+(4+(5+(6+(7+(8+(9+10)))))))))"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_val("1*2*3*4*5*6*7*8*9*10"), 3628800.0) // 腿 RET
}

///|
// #8.40 第四批（Calculator）第 8 块：12 格，每格一条腿读数
test "calc 8" {
  assert_eq(calc_val("1000000*1000000"), 1000000000000.0) // 腿 RET
  assert_eq(calc_val("1/1000000"), 1.0e-06) // 腿 RET
  assert_eq(calc_val("9999999999999999999+1"), 1.0e19) // 腿 RET
  assert_eq(calc_val("0.0000000001*10"), 1.0e-09) // 腿 RET
  assert_eq(calc_val("1e300+1e300"), 2.0e300) // 腿 RET
  assert_eq(calc_val("1e308*10"), @double.infinity) // 腿 RET
  assert_eq(calc_val("1e-320*10"), 1.0e-319) // 腿 RET
  assert_eq(calc_val("-1e308*10"), @double.neg_infinity) // 腿 RET
  assert_eq(calc_val("10%3*2"), 2.0) // 腿 RET
  assert_eq(calc_val("2+10%3"), 3.0) // 腿 RET
  assert_eq(calc_val("(10%3)*2"), 2.0) // 腿 RET
  assert_eq(calc_err("1%0"), "DivZero") // 腿 ERR_ArithmeticException|Division by zero
}

///|
// #8.40 第四批（Calculator）第 9 块：12 格，每格一条腿读数
test "calc 9" {
  assert_eq(calc_err("1/0"), "DivZero") // 腿 ERR_ArithmeticException|/ by zero
  assert_eq(calc_err("0/0"), "DivZero") // 腿 ERR_ArithmeticException|/ by zero
  assert_eq(calc_err("0%0"), "DivZero") // 腿 ERR_ArithmeticException|Division undefined
  assert_eq(calc_val("1+(2)"), 3.0) // 腿 RET
  assert_eq(calc_val("1+(1+(2))"), 4.0) // 腿 RET
  assert_eq(calc_val("1+(1+(1+(2)))"), 5.0) // 腿 RET
  assert_eq(calc_val("1+(1+(1+(1+(2))))"), 6.0) // 腿 RET
  assert_eq(calc_val("1+(1+(1+(1+(1+(2)))))"), 7.0) // 腿 RET
  assert_eq(calc_val("1+(1+(1+(1+(1+(1+(2))))))"), 8.0) // 腿 RET
  assert_eq(calc_val("1+(1+(1+(1+(1+(1+(1+(2)))))))"), 9.0) // 腿 RET
  assert_eq(calc_val("1+(1+(1+(1+(1+(1+(1+(1+(2))))))))"), 10.0) // 腿 RET
  assert_eq(calc_val("1+(1+(1+(1+(1+(1+(1+(1+(1+(2)))))))))"), 11.0) // 腿 RET
}

///|
// #8.40 第四批（Calculator）第 10 块：12 格，每格一条腿读数
test "calc 10" {
  assert_eq(calc_val("1+(1+(1+(1+(1+(1+(1+(1+(1+(1+(2))))))))))"), 12.0) // 腿 RET
  assert_eq(calc_val("1+(1+(1+(1+(1+(1+(1+(1+(1+(1+(1+(2)))))))))))"), 13.0) // 腿 RET
  assert_eq(calc_val("1+(1+(1+(1+(1+(1+(1+(1+(1+(1+(1+(1+(2))))))))))))"), 14.0) // 腿 RET
  assert_eq(calc_val("1+(2+(3+(4+5)))"), 15.0) // 腿 RET
  assert_eq(calc_val("1+(2+(3+(4+(5+6))))"), 21.0) // 腿 RET
  assert_eq(calc_val("1+(2+(3+(4+(5+(6+7)))))"), 28.0) // 腿 RET
  assert_eq(calc_err("1+(2+(3+(4+(5+(6+(7+8)))))))"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("1+(2+(3+(4+(5+(6+(7+(8+9))))))))"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("1+(2+(3+(4+(5+(6+(7+(8+(9+9)))))))))"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("1+(2+(3+(4+(5+(6+(7+(8+(9+1)))))))))"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("1+(2+(3+(4+(5+(6+(7+(8+(99+1)))))))))"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("1+(2+(3+(4+(5+(6+(7+(8+(9+100)))))))))"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
}

///|
// #8.40 第四批（Calculator）第 11 块：12 格，每格一条腿读数
test "calc 11" {
  assert_eq(calc_err("1+(2+(3+(4+(5+(6+(7+(8+(99+99)))))))))"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_val("1+(2+(3+4))"), 10.0) // 腿 RET
  assert_eq(calc_val("2*(3+(4+5))"), 24.0) // 腿 RET
  assert_eq(calc_val("((1)+2)"), 3.0) // 腿 RET
  assert_eq(calc_val("1%3%2"), 1.0) // 腿 RET
  assert_eq(calc_val("1--2"), 3.0) // 腿 RET
  assert_eq(calc_val("2^-3"), -1.0) // 腿 RET
  assert_eq(calc_err("1)-2"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_val("1 = 2"), 1.0) // 腿 RET
  assert_eq(calc_val("1+2 = "), 3.0) // 腿 RET
  assert_eq(calc_val("- 5+3"), -2.0) // 腿 RET
  assert_eq(calc_val("1+-2"), -1.0) // 腿 RET
}

///|
// #8.40 第四批（Calculator）第 12 块：12 格，每格一条腿读数
test "calc 12" {
  assert_eq(calc_err("1+*2"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("1**2"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("1//2"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("5%"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("%"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_val("1%2"), 1.0) // 腿 RET
  assert_eq(calc_val("(())"), 0.0) // 腿 RET
  assert_eq(calc_err("1+()"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_val("0"), 0.0) // 腿 RET
  assert_eq(calc_val("-0"), 0.0) // 腿 RET
  assert_eq(calc_val("0.0"), 0.0) // 腿 RET
  assert_eq(calc_val("1.0"), 1.0) // 腿 RET
}

///|
// #8.40 第四批（Calculator）第 13 块：12 格，每格一条腿读数
test "calc 13" {
  assert_eq(calc_val("00.0"), 0.0) // 腿 RET
  assert_eq(calc_val("0.1.0"), 0.1) // 腿 RET
  assert_eq(calc_val(".5"), 0.5) // 腿 RET
  assert_eq(calc_val("5."), 5.0) // 腿 RET
  assert_eq(calc_err("+.5"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_val("-.5"), -0.5) // 腿 RET
  assert_eq(calc_val("1e2"), 100.0) // 腿 RET
  assert_eq(calc_val("1E-2"), 0.01) // 腿 RET
  assert_eq(calc_val("1e+2"), 3.0) // 腿 RET
  assert_eq(calc_val("1e2e2"), 1.0) // 腿 RET
  assert_eq(calc_val("1,23"), 123.0) // 腿 RET
  assert_eq(calc_val("1 . 2"), 1.2) // 腿 RET
}

///|
// #8.40 第四批（Calculator）第 14 块：12 格，每格一条腿读数
test "calc 14" {
  assert_eq(calc_val("1.."), 1.0) // 腿 RET
  assert_eq(calc_err("..1"), "NotDecimal ..1") // 腿 ERR_NumberFormatException|Unparseable number: \"..1\"｜token 来源=腿
  assert_eq(calc_val("1e.5"), 1.0) // 腿 RET
  assert_eq(calc_val("3e2%2"), 0.0) // 腿 RET
  assert_eq(calc_err("2x"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("x2"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("1x"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("1+x"), "BadExpression") // 腿 ERR_EmptyStackException|null｜两档同判
  assert_eq(calc_err("~"), "NotDecimal -") // 腿 ERR_NumberFormatException|Unparseable number: \"-\"｜token 来源=腿
  assert_eq(calc_err("~~5"), "NotDecimal --5") // 腿 ERR_NumberFormatException|Unparseable number: \"--5\"｜token 来源=腿
  assert_eq(calc_err("-~5"), "NotDecimal --5") // 腿 ERR_NumberFormatException|Unparseable number: \"--5\"｜token 来源=腿
  assert_eq(calc_val("99999999999999999999*2"), 2.0e20) // 腿 RET
}

///|
// #8.40 第四批（Calculator）第 15 块：12 格，每格一条腿读数
test "calc 15" {
  assert_eq(calc_val("1/7"), 0.1428571429) // 腿 RET
  assert_eq(calc_val("1/11"), 0.0909090909) // 腿 RET
  assert_eq(calc_val("1/13"), 0.0769230769) // 腿 RET
  assert_eq(calc_val("0.00000000004+0"), 4.0e-11) // 腿 RET
  assert_eq(calc_val("1/3+1/3+1/3"), 0.9999999999) // 腿 RET
  assert_eq(calc_val("10=2"), 10.0) // 腿 RET
  assert_eq(calc_val("1+2=3=4"), 3.0) // 腿 RET
  assert_eq(calc_val("1/2048"), 0.0004882813) // 腿 RET
  assert_eq(calc_val("-1/2048"), -0.0004882813) // 腿 RET
  assert_eq(calc_val("1/32768"), 3.05176e-05) // 腿 RET
  assert_eq(calc_val("3/2048"), 0.0014648438) // 腿 RET
  assert_eq(calc_val("5f"), 5.0) // 腿 RET
}

///|
// #8.40 第四批（Calculator）第 16 块：12 格，每格一条腿读数
test "calc 16" {
  assert_eq(calc_val("5d"), 5.0) // 腿 RET
  assert_eq(calc_val("1d"), 1.0) // 腿 RET
  assert_eq(calc_val("1f"), 1.0) // 腿 RET
  assert_eq(calc_val("1e2a"), 1.0) // 腿 RET
  assert_eq(calc_val("1E2a"), 100.0) // 腿 RET
  assert_eq(calc_val("1e23"), 1.0e23) // 腿 RET
  assert_eq(calc_val("1E23"), 1.0e23) // 腿 RET
  assert_eq(calc_val("12e3"), 12000.0) // 腿 RET
  assert_eq(calc_val("1e2.5"), 1.0) // 腿 RET
  assert_eq(calc_val("1E2.5"), 100.0) // 腿 RET
  assert_eq(calc_val("1e2e"), 1.0) // 腿 RET
  assert_eq(calc_val("2e3e4"), 2.0) // 腿 RET
}

///|
// #8.40 第四批（Calculator）第 17 块：10 格，每格一条腿读数
test "calc 17" {
  assert_eq(calc_val("1e2e3"), 1.0) // 腿 RET
  assert_eq(calc_val("1E2e3"), 100.0) // 腿 RET
  assert_eq(calc_val("1e2 "), 100.0) // 腿 RET
  assert_eq(calc_val("1E2X3"), 300.0) // 腿 RET
  assert_eq(calc_val("0x1p3"), 0.0) // 腿 RET
  assert_eq(calc_err("١٢"), "NotDecimal ١٢") // 腿 12.0｜分岔：参照认 Unicode 十进制数字（§11.4 第 19 行），本库只认 ASCII ⇒ 该位置判坏
  assert_eq(calc_err("Infinity"), "NotDecimal Infinity") // 腿 ERR_NumberFormatException|Unparseable number: \"Infinity\"｜token 来源=腿
  assert_eq(calc_err("NaN"), "NotDecimal NaN") // 腿 ERR_IllegalArgumentException|Number is invalid!｜token 来源=求值器（参照那句不带 token）
  assert_eq(calc_err("-Infinity"), "NotDecimal -Infinity") // 腿 ERR_NumberFormatException|Unparseable number: \"-Infinity\"｜token 来源=腿
  assert_eq(calc_err("NaN+1"), "NotDecimal NaN") // 腿 ERR_IllegalArgumentException|Number is invalid!｜token 来源=求值器（参照那句不带 token）
}
