///|
// moon-hutool/num —— 第四批：`Calculator` 表达式求值（ROADMAP 第 8 行第四批）
// 契约真相在 `docs/spec/08-num.md` §11。四段流水（transform → prepare → 按推入序消费后缀 →
// 余栈整体相乘）逐段对位参照 `cn.hutool.core.math.Calculator`，读数出处在 §11.2 与 §11.4。

///|
/// #8.40 算一条四则表达式。对位参照 `cn.hutool.core.math.Calculator`——
/// 它的两件公开入口（`static conversion(String)` 与实例 `calculate(String)`）在腿的 V 行
/// **99 条对照逐条同值**（`conversion` 就是 `new Calculator().calculate(e)` 的一行壳），
/// 所以本库只发一件。
///
/// - Note: **全程十进制定点，最后一步才落 `Double`**。内部形状是「`BigInt` 尾数 + 非负 `scale`」
///   （spec §11.1）：加/减对齐 `scale`、乘 `scale` 相加、除恒 `scale=10` 且 `HalfUp`、
///   取余商向零截断且余数符号跟被除数、`scale` 取 `max`。
///   这批存在的全部理由就是三条读数：`0.1+0.2`⇒`0.3`、`1.005*100`⇒`100.5`、`2.675*100`⇒`267.5`
///   ——中途转 `Double` 会得 `0.30000000000000004` / `100.49999999999999` / `267.49999999999994`
/// - Note: 算子只有 `+ - * / %` 与 `( )`；**`^` 不是运算符**（`1^2`⇒`1`、`2^-3`⇒`-1`，
///   因为 `2^` 被当成一个数的前缀）。优先级 `+ -` = 1、`* / %` = 2、同优先级左结合
/// - Note: 跟随参照的四条"非语法"行为，都不修：`x`/`X` 当乘号（`0x10`⇒`0`）、
///   去掉**所有**空白而非 trim（`1 2`⇒`12`）、剥一个尾随 `=`（`1+2=3=4`⇒`3`）、
///   栈里剩多个数就整体相乘即隐式乘法（`(1+2)3`⇒`9`、`2(3)`⇒`6`）
/// - Note: 操作数是**最长可解析前缀**档（Java `NumberFormat` 的宽松读法，spec §11.2 末段）：
///   `1,000`⇒`1000`、`1..2`⇒`1`、`.5`⇒`0.5`、`5f`⇒`5`，且**指数档大小写不对称**——
///   大写 `E` 后跟垃圾仍算数（`1E2a`⇒`100`），小写 `e` 必须到串尾（`1e2a`⇒`1`、`12e3`⇒`12000`）。
///   本库不复刻 JDK 的解释、只复刻读数
/// - Returns: 表达式的值。中间精确、出口按 IEEE 最近舍入，超出 `Double` 范围 ⇒ `±Infinity`
///   （腿三条：`1e308*10`⇒`Infinity`、`-1e308*10`⇒`-Infinity`、`1e300+1e300`⇒`2.0E300`）
/// - Raises:
///   - `BadExpression(原式)` —— 形状坏了（括号失衡、以算子结尾、空串、纯 `=`、`(` 被当成操作数）；
///     参照在这族输入上随机抛四类异常，本库合成一档（spec §11.4 第 16 行）
///   - `NotDecimal(token)` —— 那个位置的串不是一个数（`abc`、`--5` 里剩下的那个 `-`、`..1`）
///   - `DivZero` —— 除或取余的右操作数为 0
/// - Note: 数字扫描**只认 ASCII `0-9`**：参照走 JDK 的 `Character.digit(c,10)`，`١٢` 在它那边是 `12`
///   （腿 S 行现读），本库判 `NotDecimal("١٢")`——复刻那一档要带一张 Unicode `Nd` 表而本库没有消费方
///   （spec §11.4 第 19 行）
pub fn num_calculate(expression : String) -> Double raise NumError {
  dec_as_double(calc_eval(expression, calc_transform(expression)))
}

///|
// 内部形状（spec §11.1）：值 = `m × 10^(-s)`，`s` **非负**。全程十进制精确，只在出口落 `Double`
priv struct Dec {
  m : @bigint.BigInt
  s : Int
}

///|
fn dec_int(v : Int) -> Dec {
  Dec::{ m: @bigint.BigInt::from_int(v), s: 0, }
}

///|
fn big_neg(x : @bigint.BigInt) -> @bigint.BigInt {
  if x.compare_int(0) < 0 {
    x.neg()
  } else {
    x
  }
}

///|
fn big10(n : Int) -> @bigint.BigInt {
  if n <= 0 {
    @bigint.BigInt::from_int(1)
  } else {
    @bigint.BigInt::from_int(10).pow(@bigint.BigInt::from_int(n))
  }
}

///|
// 加与减同一张嘴，只差第二个尾数取不取负；对齐到两侧 `scale` 的较大者
fn dec_join(op : Char, a : Dec, b : Dec) -> Dec {
  let s = if a.s > b.s { a.s } else { b.s }
  let x = a.m.mul(big10(s - a.s))
  let y = b.m.mul(big10(s - b.s))
  Dec::{ m: if op == '-' { x.sub(y) } else { x.add(y) }, s, }
}

///|
fn dec_mul(a : Dec, b : Dec) -> Dec {
  Dec::{ m: a.m.mul(b.m), s: a.s + b.s, }
}

///|
// `HalfUp` 的绝对值远离零商（`-0.5` 那档给 `-1`，与 core `Double::round()` 相反——#8.11 已就这条
// 分岔写过契约）；`tie_up` 只在除法那一档打开，取余要的数是**向零截断**的商
fn big_quot(
  num : @bigint.BigInt,
  den : @bigint.BigInt,
  half_up : Bool,
) -> @bigint.BigInt {
  let neg = (num.compare_int(0) < 0) != (den.compare_int(0) < 0)
  let an = big_neg(num)
  let dn = big_neg(den)
  let q = an.div(dn)
  let r = an.mod(dn)
  let q2 = if half_up && r.mul(@bigint.BigInt::from_int(2)).compare(dn) >= 0 {
    q.add(@bigint.BigInt::from_int(1))
  } else {
    q
  }
  if neg && !q2.is_zero() {
    q2.neg()
  } else {
    q2
  }
}

///|
// 除恒 `scale=10` + `HalfUp`（腿 C 行把 `div` 的读数与显式 `divide(x, 10, HALF_UP)` 逐条比**完全相同**）：
// `result_m = half_up(a.m × 10^(b.s - a.s + 10) / b.m)`
fn calc_div(a : Dec, b : Dec) -> Dec raise NumError {
  if b.m.is_zero() {
    raise DivZero
  }
  let e = b.s - a.s + 10
  let num = if e >= 0 { a.m.mul(big10(e)) } else { a.m }
  let den = if e >= 0 { b.m } else { b.m.mul(big10(0 - e)) }
  Dec::{ m: big_quot(num, den, true), s: 10, }
}

///|
// 取余：商向零截断、余数符号跟被除数（`-7%3`⇒`-1`），`scale` 由对齐自然取 `max`
fn calc_rem(a : Dec, b : Dec) -> Dec raise NumError {
  if b.m.is_zero() {
    raise DivZero
  }
  let e = b.s - a.s
  let num = if e >= 0 { a.m.mul(big10(e)) } else { a.m }
  let den = if e >= 0 { b.m } else { b.m.mul(big10(0 - e)) }
  let t = big_quot(num, den, false)
  dec_join('-', a, dec_mul(Dec::{ m: t, s: 0, }, b))
}

///|
// 第 1 段 `transform`：去掉**所有**空白 → 剥一个尾随 `=` → 处在"串首或紧跟 `+ - * / ( E e`"的 `-`
// 改成记号 `~` → `x`/`X` 就地换成 `*` → 串首是 `~` 且第二位是 `(` 时改回 `-` 并在前面补 `0`
fn calc_transform(expr : String) -> String {
  let a : Array[Char] = []
  for c in expr.to_array() {
    if !is_blank(c) {
      a.push(c)
    }
  }
  if a.length() > 0 && a[a.length() - 1] == '=' {
    let _ = a.pop()
  }
  let mut i = 0
  while i < a.length() {
    let c = a[i]
    if c == '-' {
      if i == 0 || is_sign_anchor(a[i - 1]) {
        a[i] = '~'
      }
    } else if c == 'x' || c == 'X' {
      a[i] = '*'
    }
    i += 1
  }
  if a.length() > 1 && a[0] == '~' && a[1] == '(' {
    a[0] = '-'
    return "0" + String::from_array(a)
  }
  String::from_array(a)
}

///|
fn is_blank(c : Char) -> Bool {
  let v = c.to_int()
  v == 32 || v == 9 || v == 10 || v == 13 || v == 11 || v == 12
}

///|
// 一元负号的锚：只有串首的、或紧跟在 `+ - * / ( E e` 之后的 `-` 才记成 `~`。
// 判的是**已就地改过的前一格**，所以 `--5` 的第二个 `-` 前面是 `~`（不在这串字符里）⇒ 记号不成立
fn is_sign_anchor(c : Char) -> Bool {
  c == '+' ||
  c == '-' ||
  c == '*' ||
  c == '/' ||
  c == '(' ||
  c == 'E' ||
  c == 'e'
}

///|
fn is_calc_op(c : Char) -> Bool {
  c == '+' ||
  c == '-' ||
  c == '*' ||
  c == '/' ||
  c == '(' ||
  c == ')' ||
  c == '%'
}

///|
fn is_arith(c : Char) -> Bool {
  c == '+' || c == '-' || c == '*' || c == '/' || c == '%'
}

///|
// Java 那句 `operatPriority = {0,3,2,1,-1,1,0,2}` 按 `ASCII-40` 下标摊开（spec §11.2 第 2 段）：
// `+`/`-` = 1、`*`/`/`/`%` = 2、`(` = 0、`)` = 3、栈底哨兵 `,` = -1
fn calc_prio(c : Char) -> Int {
  if c == '(' {
    0
  } else if c == ')' {
    3
  } else if c == ',' {
    -1
  } else if c == '*' || c == '/' || c == '%' {
    2
  } else {
    1
  }
}

///|

///|
// `Array::pop()` 在本版返回 `T?`，栈位的取出统一走这两件。哨位 `,` 永远留在算子栈底、
// 值栈取之前先判过长度，所以 `None` 分支是**不可达的不变量**（不是 PR-A 骨架文案）
fn pop_char(ops : Array[Char]) -> Char {
  match ops.pop() {
    Some(c) => c
    None => abort("moon-hutool/num 内部：算子栈在哨位之前被取空")
  }
}

///|
fn pop_str(st : Array[String]) -> String {
  match st.pop() {
    Some(s) => s
    None => abort("moon-hutool/num 内部：值栈在长度闸之外被取空")
  }
}

///|
fn top(ops : Array[Char]) -> Char {
  ops[ops.length() - 1]
}

///|
// 第 2 段 `prepare`：shunting-yard 出后缀栈。`cur`/`count` 那对手动游标照参照逐字搬——
// 最后那段"长度 1 且不是算子就不入栈"的规矩（`-` 单独剩在串尾时不产出操作数）是参照自己的形状
fn calc_prepare(orig : String, expr : String) -> Array[String] raise NumError {
  let arr = expr.to_array()
  let postfix : Array[String] = []
  let ops : Array[Char] = [',']
  let mut cur = 0
  let mut count = 0
  let mut i = 0
  while i < arr.length() {
    let c = arr[i]
    if is_calc_op(c) {
      if count > 0 {
        postfix.push(chars_to_string(arr, cur, count))
      }
      if c == ')' {
        if !ops.any(x => x == '(') {
          raise BadExpression(orig)
        }
        while top(ops) != '(' {
          postfix.push(String::from_array([pop_char(ops)]))
        }
        let _ = ops.pop()
      } else {
        let want = calc_prio(c)
        while c != '(' && top(ops) != ',' && calc_prio(top(ops)) >= want {
          postfix.push(String::from_array([pop_char(ops)]))
        }
        ops.push(c)
      }
      count = 0
      cur = i + 1
    } else {
      count += 1
    }
    i += 1
  }
  if count > 1 || (count == 1 && !(cur < arr.length() && is_calc_op(arr[cur]))) {
    postfix.push(chars_to_string(arr, cur, count))
  }
  while top(ops) != ',' {
    postfix.push(String::from_array([pop_char(ops)]))
  }
  if ops.any(x => x == '(') || postfix.any(x => x == ")") {
    raise BadExpression(orig)
  }
  postfix
}

///|
fn chars_to_string(arr : Array[Char], from : Int, len : Int) -> String {
  let out : Array[Char] = []
  let mut i = 0
  while i < len {
    out.push(arr[from + i])
    i += 1
  }
  String::from_array(out)
}

///|
// 第 3、4 段：按**推入序**消费后缀（参照先 `Collections.reverse` 再一路 `pop`，两步相抵就是正向），
// 栈里剩几个数就整体相乘——那正是参照的隐式乘法
fn calc_eval(orig : String, expr : String) -> Dec raise NumError {
  let stack : Array[String] = []
  for item in calc_prepare(orig, expr) {
    let ic = item.to_array()
    if ic.length() == 1 && is_arith(ic[0]) {
      if stack.length() < 2 {
        raise BadExpression(orig)
      }
      let second = pop_str(stack)
      let first = pop_str(stack)
      let a = calc_parse(orig, first)
      let b = calc_parse(orig, second)
      let v = match ic[0] {
        '+' => dec_join('+', a, b)
        '-' => dec_join('-', a, b)
        '*' => dec_mul(a, b)
        '/' => calc_div(a, b)
        _ => calc_rem(a, b)
      }
      stack.push(dec_plain(v))
    } else {
      stack.push(item)
    }
  }
  if stack.length() == 0 {
    return dec_int(0)
  }
  let mut out = dec_int(1)
  for x in stack {
    out = dec_mul(out, calc_parse(orig, x))
  }
  out
}

///|
// 操作数＝**最长可解析前缀**（spec §11.2 末段，52 个 token × 解析器三档 + 23 格计算器层读数钉死）：
// 符号 → 整数位 → `.` 与小数位 → 分组逗号（只在两侧都是数字时算）→ 指数。
// 指数尾缀的**大小写不对称**照搬不修：小写 `e` 必须一路读到串尾才算指数，大写 `E` 后面跟垃圾也算数
fn calc_parse(orig : String, tok : String) -> Dec raise NumError {
  let shown = String::from_array(
    tok.to_array().map(c => if c == '~' { '-' } else { c }),
  )
  let cs : Array[Char] = []
  for c in shown.to_array() {
    if c != ' ' {
      cs.push(c)
    }
  }
  if shown == "(" || shown == ")" || shown == "" {
    // 括号走到操作数这一格，说明栈已经失衡（`(` 是被留在余栈里当操作数用的）——
    // 参照在这族输入上抛的是栈机异常，本库按 §11.4 第 16 行合成 BadExpression
    raise BadExpression(orig)
  }
  let n = cs.length()
  let mut i = 0
  if i < n && (cs[i] == '+' || cs[i] == '-') {
    i += 1
  }
  let neg = i > 0 && cs[0] == '-'
  let start = i
  while i < n && is_digit(cs[i]) {
    i += 1
  }
  let has_int = i > start
  let mut dot = -1
  if i < n && cs[i] == '.' {
    dot = i
    i += 1
    while i < n && is_digit(cs[i]) {
      i += 1
    }
  }
  let has_frac = dot >= 0 && i > dot + 1
  if !has_int && !has_frac {
    raise NotDecimal(shown)
  }
  let mut end = i
  while end < n && cs[end] == ',' && end + 1 < n && is_digit(cs[end + 1]) {
    let mut j = end + 1
    while j < n && is_digit(cs[j]) {
      j += 1
    }
    end = j
  }
  let mut exp = 0
  let mend = end
  if end < n && (cs[end] == 'e' || cs[end] == 'E') {
    let mut j = end + 1
    let mut esign = 1
    if j < n && (cs[j] == '+' || cs[j] == '-') {
      if cs[j] == '-' {
        esign = -1
      }
      j += 1
    }
    let mut k = j
    let mut e = 0
    while k < n && is_digit(cs[k]) {
      e = e * 10 + (cs[k].to_int() - 48)
      k += 1
    }
    if k > j && (cs[end] == 'E' || k == n) {
      exp = esign * e
      end = k
    }
  }
  let digits : Array[Char] = []
  let mut frac = 0
  let mut t = 0
  while t < mend {
    let c = cs[t]
    if is_digit(c) {
      digits.push(c)
      if dot >= 0 && t > dot {
        frac += 1
      }
    }
    t += 1
  }
  let scale = frac - exp
  let mut m = @bigint.BigInt::from_string(String::from_array(digits))
  let mut s = scale
  if s < 0 {
    m = m.mul(big10(0 - s))
    s = 0
  }
  if m.is_zero() {
    s = 0
  } else if neg {
    m = m.neg()
  }
  Dec::{ m, s, }
}

///|
fn is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
// 中间值回栈用的**平格式**串（与参照一样不进指数记法）；零一律出 `"0"`，不留 `-0`
fn dec_plain(x : Dec) -> String {
  if x.m.is_zero() {
    return "0"
  }
  let neg = x.m.compare_int(0) < 0
  let ds = big_neg(x.m).to_string()
  let sign = if neg { "-" } else { "" }
  if x.s == 0 {
    return sign + ds
  }
  let d = if ds.length() > x.s {
    ds
  } else {
    zero_run(x.s - ds.length() + 1) + ds
  }
  let cs = d.to_array()
  let ip = cs.length() - x.s
  sign +
  chars_to_string(cs, 0, ip) +
  "." +
  chars_to_string(cs, ip, cs.length() - ip)
}

///|
// 出口：十进制精确值 → 最短科学记法 → `parse_double`。越界由解析报错转成 `±Infinity`——
// 参照内部也是"精确十进制算完，最后一步才 `doubleValue()`"（spec §11.4 第 18 行，三条 D 行读数为凭）。
// 尾零在这里才去掉（`1e23` 的尾数是一长串零，最短记法才是 `1e23`），指数按**原始位数**算，
// 与去尾零无关
fn dec_as_double(x : Dec) -> Double {
  if x.m.is_zero() {
    return 0.0
  }
  let neg = x.m.compare_int(0) < 0
  let cs = big_neg(x.m).to_string().to_array()
  let mut e = cs.length()
  while e > 1 && cs[e - 1] == '0' {
    e -= 1
  }
  let head = chars_to_string(cs, 0, 1)
  let rest = chars_to_string(cs, 1, e - 1)
  let exp = cs.length() - 1 - x.s
  let body = if rest.length() > 0 { head + "." + rest } else { head }
  let text = (if neg { "-" } else { "" }) + body + "e" + exp.to_string()
  @string.parse_double(text) catch {
    _ => if neg { @double.neg_infinity } else { @double.infinity }
  }
}
