///|
// 失败通道补档（10-07，配合门禁 G15 的未覆盖行棘轮）
//
// 这些断言的**期望形状全部取自 spec 已冻的报错映射**，不引入新读数：
//   #8.15 / #8.19 `NaN`/`±Infinity` ⇒ `NotFinite`
//   #8.16 非法串 ⇒ `NotDecimal` 带原串（`abc`、`1.2.3` 两条就在表里）
//   #8.36 三个键都没内容 ⇒ `NotDecimal`（`元整`/`元`/`分` 三条是腿的现读）
//   #8.36 反向那侧的界外 ⇒ `OutOfRange`；`english_word_of` 的负数档同样判 `OutOfRange`
//   （三条不跟随的理由写在 `num/num.mbt` 的函数文档与 spec §10.4，这里不重复）
//
// 补档前这些 `raise` 点在 `moon coverage analyze` 里一条都没被执行过——错误面只有实现自己在走。
// 档名渲染沿用已冻形状：`NotDecimal abc` 不带引号（同一个错误面不许有两套读法）。

///|
fn chan_tag(e : @num.NumError) -> String {
  match e {
    @num.ScaleOutOfRange(s) => "ScaleOutOfRange " + s.to_string()
    @num.NotFinite => "NotFinite"
    @num.NegativeRadicand(n) => "NegativeRadicand " + n.to_string()
    @num.InvalidModulus(n) => "InvalidModulus " + n.to_string()
    @num.NonCoprime(a, b) => "NonCoprime " + a.to_string() + "/" + b.to_string()
    @num.NegativeFactorial(n) => "NegativeFactorial " + n.to_string()
    @num.NegativeCount(a, b) => "NegativeCount " + a.to_string() + "/" + b.to_string()
    @num.NotDecimal(t) => "NotDecimal " + t
    @num.NonPositiveTargets(n) => "NonPositiveTargets " + n.to_string()
    @num.NegativeRatio(n) => "NegativeRatio " + n.to_string()
    @num.RatioSumNotPositive(n) => "RatioSumNotPositive " + n.to_string()
    @num.MoneyOverflow => "MoneyOverflow"
    @num.OutOfRange(t) => "OutOfRange " + t
    @num.UnknownChineseUnit(c, i) =>
      "UnknownChineseUnit " + (c.to_int()).to_string() + "/" + i.to_string()
    @num.BadChineseNumber(t, i) => "BadChineseNumber " + t + "/" + i.to_string()
    @num.BadExpression(t) => "BadExpression " + t
    @num.DivZero => "DivZero"
  }
}

///|
/// 跑一次预期会 raise 的调用并把错误形状读成档名；没 raise 就返回「未抛错」。
/// 写法走 `num_test.mbt` 的既有形状（`try` 在被 catch 的那个表达式里，`fmt` 不会再拆坏）。
fn[A] chan_run(g : () -> A raise @num.NumError) -> String {
  try {
    let _ = g()
    "未抛错"
  } catch {
    e => chan_tag(e)
  }
}

///|
test "@num 失败通道 #8.19：Money 的元构造收到 ±Infinity 判 NotFinite（NaN 与它同档）" {
  assert_eq(chan_run(() => @num.Money::from_yuan(@double.infinity)), "NotFinite")
  assert_eq(chan_run(() => @num.Money::from_yuan(@double.neg_infinity)), "NotFinite")
}

///|
test "@num 失败通道 #8.15：format_percent 收到非有限值判 NotFinite，与 #8.11 同一套报错" {
  assert_eq(chan_run(() => @num.format_percent(@double.infinity, 2)), "NotFinite")
  assert_eq(chan_run(() => @num.format_percent(@double.neg_infinity, 0)), "NotFinite")
}

///|
test "@num 失败通道 #8.16：trim_trailing_zeros 的非法串两条，NotDecimal 带原串" {
  assert_eq(chan_run(() => @num.trim_trailing_zeros("abc")), "NotDecimal abc")
  assert_eq(chan_run(() => @num.trim_trailing_zeros("1.2.3")), "NotDecimal 1.2.3")
}

///|
test "@num 失败通道 #8.36：中文金额三个键都没内容 ⇒ NotDecimal（腿的三条现读）" {
  assert_eq(chan_run(() => @num.money_of_chinese("元整")), "NotDecimal 元整")
  assert_eq(chan_run(() => @num.money_of_chinese("元")), "NotDecimal 元")
  assert_eq(chan_run(() => @num.money_of_chinese("分")), "NotDecimal 分")
}

///|
test "@num 失败通道：english_word_of 的负数档判 OutOfRange（hutool 那侧炸在内部 parseInt）" {
  assert_eq(chan_run(() => @num.english_word_of("-1")), "OutOfRange -1")
}
