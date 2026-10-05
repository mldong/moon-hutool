///|
// conv 包期望值全部由镜像算出：规则 = hutool `convert`/`util` 源码的字面转写，
// 参考腿 = 本机 JDK 17 实跑 `ConvRef.java`（200 条一致 / 30 条声明分岔，逐条理由见 docs/spec/09-conv.md §5）。
// 改任何一条期望值须单独一笔并给外部读数来源（门禁 G5）。

///|
// 夹具一律走 @json.parse——core 的 `Json` 变体是只读类型，测试里构造不出 Number(...)（spec §7）
fn j(s : String) -> Json {
  @json.parse(s) catch {
    _ => abort("夹具不是合法 JSON：" + s)
  }
}

///|
// Json 读数一律折成 stringify 串再断言（三档实测一致），不拿 Show/Debug 的形状当契约
fn shape(o : Json?) -> String {
  match o {
    Some(v) => "命中:" + v.stringify()
    None => "未命中"
  }
}

///|
// 把「会 raise 的那次调用」包成闭包传进来：命中/未命中/BadPath 三态都能断言
fn pshape(g : () -> Json? raise @conv.ConvError) -> String {
  shape(g()) catch {
    @conv.BadPath(s) => "BadPath:" + s
  }
}

///|
// BigInt 读数折成十进制串（同 num 包写法：避免任何一次 to_int 静默回绕）
fn bi(x : BigInt?) -> String {
  match x {
    Some(v) => v.to_string()
    None => "None"
  }
}

///|
// Number 有 repr 用 repr、没有则用 Double 的最短十进制串（实测 -0⇒"0"、1e5⇒"100000"）；Array/Object 走 stringify
test "to_str 的字符串形态（#9.1）" {
  assert_eq(@conv.to_str(j("null")), None)
  assert_eq(@conv.to_str(j("true")), Some("true"))
  assert_eq(@conv.to_str(j("false")), Some("false"))
  assert_eq(@conv.to_str(j("1")), Some("1"))
  assert_eq(@conv.to_str(j("1.0")), Some("1"))
  assert_eq(@conv.to_str(j("1e5")), Some("100000"))
  assert_eq(@conv.to_str(j("9007199254740993")), Some("9007199254740993"))
  assert_eq(@conv.to_str(j("1e309")), Some("1e309"))
  assert_eq(@conv.to_str(j("0.1")), Some("0.1"))
  assert_eq(@conv.to_str(j("-0")), Some("0"))
  assert_eq(@conv.to_str(j("123.456")), Some("123.456"))
  assert_eq(@conv.to_str(j("[1,2,\"x\"]")), Some("[1,2,\"x\"]"))
  assert_eq(
    @conv.to_str(j("{\"b\":1,\"a\":[true,null],\"n\":1.0}")),
    Some("{\"b\":1,\"a\":[true,null],\"n\":1}"),
  )
  assert_eq(@conv.to_str(j("{}")), Some("{}"))
  assert_eq(@conv.to_str(j("[]")), Some("[]"))
  assert_eq(@conv.to_str(j("\"123\"")), Some("123"))
  assert_eq(@conv.to_str(j("\"\"")), Some(""))
  assert_eq(@conv.to_str(j("\" 123 \"")), Some(" 123 "))
  assert_eq(@conv.to_str(j("\"a b\"")), Some("a b"))
  assert_eq(@conv.to_str(j("\"\\u0001x\"")), Some("\u{0001}x"))
}

///|
// 数字档只看「是不是 0」——hutool `0 != doubleValue()`：Infinity 也算 true（JDK 参考腿 num_bool 同读）
test "to_bool 的 Null/Bool/Number/树 档（#9.2）" {
  assert_eq(@conv.to_bool(j("null")), None)
  assert_eq(@conv.to_bool(j("true")), Some(true))
  assert_eq(@conv.to_bool(j("false")), Some(false))
  assert_eq(@conv.to_bool(j("0")), Some(false))
  assert_eq(@conv.to_bool(j("1")), Some(true))
  assert_eq(@conv.to_bool(j("-0")), Some(false))
  assert_eq(@conv.to_bool(j("0.1")), Some(true))
  assert_eq(@conv.to_bool(j("1e5")), Some(true))
  assert_eq(@conv.to_bool(j("1e309")), Some(true))
  assert_eq(@conv.to_bool(j("1e-324")), Some(false))
  assert_eq(@conv.to_bool(j("123.456")), Some(true))
  assert_eq(@conv.to_bool(j("[]")), Some(false))
  assert_eq(@conv.to_bool(j("[1,2,\"x\"]")), Some(false))
  assert_eq(@conv.to_bool(j("{}")), Some(false))
}

///|
// 大小写不敏感只做 ASCII 小写；trim 用 Java String.trim 档（<=U+0020），与数值腿的 @text.trim 不同——两处不对称照抄调用点
test "to_bool 字符串档：TRUE_SET 18 条全命中（#9.2）" {
  assert_eq(@conv.to_bool(j("\"1\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"correct\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"ok\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"on\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"success\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"t\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"true\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"y\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"yes\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"√\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"☑\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"对\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"對\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"开\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"开启\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"是\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"正确\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"真\"")), Some(true))
}

///|
// hutool `BooleanUtil.toBoolean` 没有第三态：非空白又不在 TRUE_SET 就 false（给 null 的是 toBooleanObject，即本包 parse_bool）
test "to_bool 字符串档：FALSE_SET 与未命中一律 Some(false)（#9.2 与 #9.8 的分岔）" {
  assert_eq(@conv.to_bool(j("\"0\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"f\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"fail\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"false\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"n\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"no\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"off\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"wrong\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"×\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"☒\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"假\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"关\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"关闭\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"否\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"錯\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"错\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"错误\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"x\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"2\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"-1\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"0.0\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"00\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"0.5\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"\u{00A0}1\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"\u{00A0}on\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"  \"")), Some(false))
  assert_eq(@conv.to_bool(j("\" y\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"TRUE\"")), Some(true))
  assert_eq(@conv.to_bool(j("\"FALSE\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"on \"")), Some(true))
}

///|
// 字符串形态不 trim（首字符可能是空格）；空白串⇒None（hutool blank⇒默认值，default_face 实测 ' '|X⇒X）
test "to_char 取字符串形态的首码点（#9.3）" {
  assert_eq(@conv.to_char(j("\"abc\"")), Some('a'))
  assert_eq(@conv.to_char(j("\"  x\"")), Some(' '))
  assert_eq(@conv.to_char(j("\"\"")), None)
  assert_eq(@conv.to_char(j("\"   \"")), None)
  assert_eq(@conv.to_char(j("1e5")), Some('1'))
  assert_eq(@conv.to_char(j("123.456")), Some('1'))
  assert_eq(@conv.to_char(j("1")), Some('1'))
  assert_eq(@conv.to_char(j("-0")), Some('0'))
  assert_eq(@conv.to_char(j("[1,2,\"x\"]")), Some('['))
  assert_eq(
    @conv.to_char(j("{\"b\":1,\"a\":[true,null],\"n\":1.0}")),
    Some('{'),
  )
  assert_eq(@conv.to_char(j("\"\\u0001x\"")), Some('\u{0001}'))
  assert_eq(@conv.to_char(j("\"√\"")), Some('√'))
  assert_eq(@conv.to_char(j("\"中\"")), Some('中'))
  assert_eq(@conv.to_char(j("\"☒\"")), Some('☒'))
  assert_eq(@conv.to_char(j("0.1")), Some('0'))
}

///|
// JDK 参考腿实测 toChar(true)=U+0001、toChar(false)=U+0000（BooleanUtil.toChar = (char)toInt）：本包不交付控制字符
test "to_char 的 Bool 档不跟随（#9.3）" {
  assert_eq(@conv.to_char(j("true")), None)
  assert_eq(@conv.to_char(j("false")), None)
}

///|
// 只喂 32 位内可读的夹具：越界读数随 Int 位宽变（wasm 实测 @int.MAX_VALUE=2147483647），界规则由 to_int64 腿钉（spec §0.1）
test "to_int：Number 截断、repr 优先与字符串腿（#9.4）" {
  assert_eq(@conv.to_int(j("1")), Some(1))
  assert_eq(@conv.to_int(j("1.0")), Some(1))
  assert_eq(@conv.to_int(j("1e5")), Some(100000))
  assert_eq(@conv.to_int(j("0.1")), Some(0))
  assert_eq(@conv.to_int(j("123.456")), Some(123))
  assert_eq(@conv.to_int(j("0")), Some(0))
  assert_eq(@conv.to_int(j("-0")), Some(0))
  assert_eq(@conv.to_int(j("null")), None)
  assert_eq(@conv.to_int(j("true")), Some(1))
  assert_eq(@conv.to_int(j("false")), Some(0))
  assert_eq(@conv.to_int(j("[1,2,\"x\"]")), None)
  assert_eq(@conv.to_int(j("{}")), None)
  assert_eq(@conv.to_int(j("\"123\"")), Some(123))
  assert_eq(@conv.to_int(j("\"007\"")), Some(7))
  assert_eq(@conv.to_int(j("\" 123 \"")), Some(123))
  assert_eq(@conv.to_int(j("\"123.56\"")), Some(123))
  assert_eq(@conv.to_int(j("\"0x1F\"")), Some(1))
  assert_eq(@conv.to_int(j("\"1e5\"")), None)
  assert_eq(@conv.to_int(j("\"abc\"")), None)
  assert_eq(@conv.to_int(j("\"\"")), None)
  assert_eq(@conv.to_int(j("\"2147483647\"")), Some(2147483647))
  assert_eq(@conv.to_int(j("\"+123\"")), Some(123))
  assert_eq(@conv.to_int(j("\"-.5\"")), Some(0))
  assert_eq(@conv.to_int(j("\"\\uFF11\\uFF12\\uFF13\"")), Some(123))
}

///|
// 9007199254740993 装不进 Double：core 给它 repr，本包优先读 repr⇒精确；只读 Double 会撞成 ...992（三档实测 rp| 腿）
test "to_int64：repr 优先，大整数不丢精度（#9.5）" {
  assert_eq(@conv.to_int64(j("1")), Some(1))
  assert_eq(@conv.to_int64(j("1.0")), Some(1))
  assert_eq(@conv.to_int64(j("1e5")), Some(100000))
  assert_eq(@conv.to_int64(j("0.1")), Some(0))
  assert_eq(@conv.to_int64(j("123.456")), Some(123))
  assert_eq(@conv.to_int64(j("0")), Some(0))
  assert_eq(@conv.to_int64(j("-0")), Some(0))
  assert_eq(@conv.to_int64(j("9007199254740993")), Some(9007199254740993))
  assert_eq(@conv.to_int64(j("18446744073709551616")), None)
  assert_eq(@conv.to_int64(j("1e309")), None)
  assert_eq(@conv.to_int64(j("1e-324")), Some(0))
  assert_eq(@conv.to_int64(j("null")), None)
  assert_eq(@conv.to_int64(j("true")), Some(1))
  assert_eq(@conv.to_int64(j("false")), Some(0))
  assert_eq(@conv.to_int64(j("[1,2,\"x\"]")), None)
  assert_eq(@conv.to_int64(j("{}")), None)
  assert_eq(@conv.to_int64(j("\"9007199254740993\"")), Some(9007199254740993))
  assert_eq(@conv.to_int64(j("\"2147483648\"")), Some(2147483648))
  assert_eq(@conv.to_int64(j("\"9223372036854775808\"")), None)
  assert_eq(@conv.to_int64(j("\"-2147483649\"")), Some(-2147483649))
  assert_eq(@conv.to_int64(j("\"1e5\"")), Some(100000))
  assert_eq(@conv.to_int64(j("\"1.2e3\"")), Some(1200))
  assert_eq(@conv.to_int64(j("\"5e-3\"")), Some(0))
  assert_eq(@conv.to_int64(j("\"abc\"")), None)
  assert_eq(@conv.to_int64(j("\"\"")), None)
  assert_eq(@conv.to_int64(j("\"   \"")), None)
  assert_eq(@conv.to_int64(j("\"12 L\"")), None)
  assert_eq(@conv.to_int64(j("\"\\u00A0123\"")), Some(123))
  assert_eq(@conv.to_int64(j("\"123X\"")), None)
  assert_eq(@conv.to_int64(j("\"0x1F\"")), Some(1))
}

///|
// JDK 参考腿读数："9223372036854775808"⇒-9223372036854775808、1e309⇒0、Long.MIN⇒Int 0（低位回绕/saturate），本包不给
test "to_int64 的越界档一律 None（#9.5，不跟随 Java 回绕）" {
  assert_eq(@conv.to_int64(j("\"9223372036854775808\"")), None)
  assert_eq(@conv.to_int64(j("\"1e309\"")), None)
  assert_eq(@conv.to_int64(j("1e309")), None)
  assert_eq(@conv.to_int64(j("18446744073709551616")), None)
  assert_eq(@conv.to_int64(j("\"-9223372036854775809\"")), None)
  assert_eq(@conv.to_int64(j("null")), None)
  assert_eq(@conv.to_int64(j("\"1,234.5\"")), None)
  assert_eq(@conv.to_int64(j("\"NaN\"")), None)
  assert_eq(@conv.to_int64(j("\"Infinity\"")), None)
}

///|
// Json 的 1e309 在 core 里就是 +Infinity（实测 rp|1e309 ⇒ d=Infinity repr=1e309），字符串腿的 1e309 则 None（core parse_double 报错）
test "to_double：原值、字符串腿与不跟随档（#9.6）" {
  assert_eq(@conv.to_double(j("1")), Some(1.0))
  assert_eq(@conv.to_double(j("0.1")), Some(0.1))
  assert_eq(@conv.to_double(j("1e5")), Some(100000.0))
  assert_eq(@conv.to_double(j("1e309")), Some(@double.infinity))
  assert_eq(@conv.to_double(j("1e-324")), Some(0.0))
  assert_eq(@conv.to_double(j("123.456")), Some(123.456))
  assert_eq(@conv.to_double(j("0")), Some(0.0))
  assert_eq(@conv.to_double(j("-0")), Some(0.0))
  assert_eq(@conv.to_double(j("true")), Some(1.0))
  assert_eq(@conv.to_double(j("false")), Some(0.0))
  assert_eq(@conv.to_double(j("null")), None)
  assert_eq(@conv.to_double(j("[1,2,\"x\"]")), None)
  assert_eq(@conv.to_double(j("{}")), None)
  assert_eq(@conv.to_double(j("\"123.456\"")), Some(123.456))
  assert_eq(@conv.to_double(j("\"1e5\"")), Some(100000.0))
  assert_eq(@conv.to_double(j("\"5e-3\"")), Some(0.005))
  assert_eq(@conv.to_double(j("\"-0.9\"")), Some(-0.9))
  assert_eq(@conv.to_double(j("\"abc\"")), None)
  assert_eq(@conv.to_double(j("\"NaN\"")), None)
  assert_eq(@conv.to_double(j("\"Infinity\"")), None)
  assert_eq(@conv.to_double(j("\"0x1p3\"")), None)
  assert_eq(@conv.to_double(j("\"1,234.5\"")), None)
  assert_eq(@conv.to_double(j("\"1e309\"")), None)
  assert_eq(@conv.to_double(j("\"123.456.789\"")), None)
  assert_eq(@conv.to_double(j("\"\"")), None)
  assert_eq(@conv.to_double(j("\"123L\"")), Some(123.0))
  assert_eq(@conv.to_double(j("\"1_000\"")), None)
  assert_eq(@conv.to_double(j("\"\\uFF11\\uFF12\\uFF13\"")), Some(123.0))
  assert_eq(@conv.to_double(j("\"0x1F\"")), None)
}

///|
// 空串⇒0 是 NumberUtil.toBigInteger 的 blank⇒ZERO 档（JDK 实测 ci_bigint| ⇒0），与整数腿的 blank⇒None 分岔
test "to_big_int：整数文法、小数 None、空串 0（#9.7）" {
  assert_eq(bi(@conv.to_big_int(j("1"))), "1")
  assert_eq(bi(@conv.to_big_int(j("1.0"))), "1")
  assert_eq(bi(@conv.to_big_int(j("1e5"))), "100000")
  assert_eq(bi(@conv.to_big_int(j("123.456"))), "None")
  assert_eq(bi(@conv.to_big_int(j("0"))), "0")
  assert_eq(bi(@conv.to_big_int(j("-0"))), "0")
  assert_eq(bi(@conv.to_big_int(j("9007199254740993"))), "9007199254740993")
  assert_eq(
    bi(@conv.to_big_int(j("18446744073709551616"))),
    "18446744073709551616",
  )
  assert_eq(bi(@conv.to_big_int(j("1e309"))), "None")
  assert_eq(bi(@conv.to_big_int(j("true"))), "1")
  assert_eq(bi(@conv.to_big_int(j("false"))), "0")
  assert_eq(bi(@conv.to_big_int(j("null"))), "None")
  assert_eq(bi(@conv.to_big_int(j("[1,2,\"x\"]"))), "None")
  assert_eq(bi(@conv.to_big_int(j("\"007\""))), "7")
  assert_eq(bi(@conv.to_big_int(j("\"123.56\""))), "None")
  assert_eq(bi(@conv.to_big_int(j("\"1e5\""))), "None")
  assert_eq(bi(@conv.to_big_int(j("\"abc\""))), "None")
  assert_eq(bi(@conv.to_big_int(j("\"\""))), "0")
  assert_eq(bi(@conv.to_big_int(j("\"   \""))), "0")
  assert_eq(bi(@conv.to_big_int(j("\"-0\""))), "0")
  assert_eq(bi(@conv.to_big_int(j("\"+1\""))), "1")
  assert_eq(bi(@conv.to_big_int(j("\"\\uFF11\\uFF12\\uFF13\""))), "123")
}

///|
// NBSP 三条是两处 trim 定义差的直接推论：String.trim 只吃 <=U+0020 ⇒ U+00A0 留下 ⇒ 不在集合 ⇒ None
test "parse_bool 的三态与两处 trim 分岔（#9.8）" {
  assert_eq(@conv.parse_bool("1"), Some(true))
  assert_eq(@conv.parse_bool("correct"), Some(true))
  assert_eq(@conv.parse_bool("ok"), Some(true))
  assert_eq(@conv.parse_bool("on"), Some(true))
  assert_eq(@conv.parse_bool("success"), Some(true))
  assert_eq(@conv.parse_bool("t"), Some(true))
  assert_eq(@conv.parse_bool("true"), Some(true))
  assert_eq(@conv.parse_bool("y"), Some(true))
  assert_eq(@conv.parse_bool("yes"), Some(true))
  assert_eq(@conv.parse_bool("√"), Some(true))
  assert_eq(@conv.parse_bool("☑"), Some(true))
  assert_eq(@conv.parse_bool("对"), Some(true))
  assert_eq(@conv.parse_bool("對"), Some(true))
  assert_eq(@conv.parse_bool("开"), Some(true))
  assert_eq(@conv.parse_bool("开启"), Some(true))
  assert_eq(@conv.parse_bool("是"), Some(true))
  assert_eq(@conv.parse_bool("正确"), Some(true))
  assert_eq(@conv.parse_bool("真"), Some(true))
  assert_eq(@conv.parse_bool("0"), Some(false))
  assert_eq(@conv.parse_bool("f"), Some(false))
  assert_eq(@conv.parse_bool("fail"), Some(false))
  assert_eq(@conv.parse_bool("false"), Some(false))
  assert_eq(@conv.parse_bool("n"), Some(false))
  assert_eq(@conv.parse_bool("no"), Some(false))
  assert_eq(@conv.parse_bool("off"), Some(false))
  assert_eq(@conv.parse_bool("wrong"), Some(false))
  assert_eq(@conv.parse_bool("×"), Some(false))
  assert_eq(@conv.parse_bool("☒"), Some(false))
  assert_eq(@conv.parse_bool("假"), Some(false))
  assert_eq(@conv.parse_bool("关"), Some(false))
  assert_eq(@conv.parse_bool("关闭"), Some(false))
  assert_eq(@conv.parse_bool("否"), Some(false))
  assert_eq(@conv.parse_bool("錯"), Some(false))
  assert_eq(@conv.parse_bool("错"), Some(false))
  assert_eq(@conv.parse_bool("错误"), Some(false))
  assert_eq(@conv.parse_bool("x"), None)
  assert_eq(@conv.parse_bool("2"), None)
  assert_eq(@conv.parse_bool("-1"), None)
  assert_eq(@conv.parse_bool("00"), None)
  assert_eq(@conv.parse_bool("0.5"), None)
  assert_eq(@conv.parse_bool(""), None)
  assert_eq(@conv.parse_bool("  "), None)
  assert_eq(@conv.parse_bool(" y"), Some(true))
  assert_eq(@conv.parse_bool("on "), Some(true))
  assert_eq(@conv.parse_bool("TRUE"), Some(true))
  assert_eq(@conv.parse_bool("FALSE"), Some(false))
  assert_eq(@conv.parse_bool("\u{00A0}1"), None)
  assert_eq(@conv.parse_bool("\u{00A0}on"), None)
  assert_eq(@conv.parse_bool("\u{00A0}no"), None)
  assert_eq(@conv.parse_bool("\u{0001}"), None)
  assert_eq(@conv.parse_bool("t"), Some(true))
  assert_eq(@conv.parse_bool("☑"), Some(true))
  assert_eq(@conv.parse_bool("☒"), Some(false))
}

///|
// 去尾发生在 hex 判定之前："0x1F"⇒"0x1"⇒1、"0Xff"⇒"0Xf"⇒15（JDK 参考腿 ci_int 逐条同读）
test "parse_int_loose 的 0x 与 D/L/F 去尾相互作用（#9.9）" {
  assert_eq(@conv.parse_int_loose("123"), Some(123))
  assert_eq(@conv.parse_int_loose("007"), Some(7))
  assert_eq(@conv.parse_int_loose("+123"), Some(123))
  assert_eq(@conv.parse_int_loose("-123"), Some(-123))
  assert_eq(@conv.parse_int_loose(" 123 "), Some(123))
  assert_eq(@conv.parse_int_loose("0x1F"), Some(1))
  assert_eq(@conv.parse_int_loose("0Xff"), Some(15))
  assert_eq(@conv.parse_int_loose("0x"), None)
  assert_eq(@conv.parse_int_loose("0xZZ"), None)
  assert_eq(@conv.parse_int_loose("123.56"), Some(123))
  assert_eq(@conv.parse_int_loose(".123"), Some(0))
  assert_eq(@conv.parse_int_loose("123."), Some(123))
  assert_eq(@conv.parse_int_loose("-.5"), Some(0))
  assert_eq(@conv.parse_int_loose("-0.9"), Some(0))
  assert_eq(@conv.parse_int_loose("123L"), Some(123))
  assert_eq(@conv.parse_int_loose("123f"), Some(123))
  assert_eq(@conv.parse_int_loose("123X"), None)
  assert_eq(@conv.parse_int_loose("2147483647"), Some(2147483647))
  assert_eq(@conv.parse_int_loose("0"), Some(0))
  assert_eq(@conv.parse_int_loose("-0"), Some(0))
  assert_eq(@conv.parse_int_loose("12"), Some(12))
  assert_eq(@conv.parse_int_loose("abc"), None)
  assert_eq(@conv.parse_int_loose(""), None)
  assert_eq(@conv.parse_int_loose("   "), None)
  assert_eq(@conv.parse_int_loose("１２３"), Some(123))
  assert_eq(@conv.parse_int_loose("1,234.5"), None)
  assert_eq(@conv.parse_int_loose("1_000"), None)
  assert_eq(@conv.parse_int_loose("12 L"), None)
  assert_eq(@conv.parse_int_loose("true"), None)
  assert_eq(@conv.parse_int_loose("1e5"), None)
  assert_eq(@conv.parse_int_loose("1E5"), None)
  assert_eq(@conv.parse_int_loose("NaN"), None)
  assert_eq(@conv.parse_int_loose("Infinity"), None)
  assert_eq(@conv.parse_int_loose("123.456.789"), None)
  assert_eq(@conv.parse_int_loose("1.234,5"), None)
  assert_eq(@conv.parse_int_loose("\u{3000}"), None)
  assert_eq(@conv.parse_int_loose("123L"), Some(123))
  assert_eq(@conv.parse_int_loose("-123.56"), Some(-123))
}

///|
// parseInt 明确拒绝 E（Unsupported int format），parseLong 不拒绝（走 BigDecimal）：1e5⇒100000、1.2e3⇒1200、5e-3⇒0
test "parse_int64_loose 与 int 腿的指数不对称（#9.10）" {
  assert_eq(@conv.parse_int64_loose("123"), Some(123))
  assert_eq(@conv.parse_int64_loose("007"), Some(7))
  assert_eq(@conv.parse_int64_loose("+123"), Some(123))
  assert_eq(@conv.parse_int64_loose("-123"), Some(-123))
  assert_eq(@conv.parse_int64_loose(" 123 "), Some(123))
  assert_eq(@conv.parse_int64_loose("0x1F"), Some(1))
  assert_eq(@conv.parse_int64_loose("0Xff"), Some(15))
  assert_eq(@conv.parse_int64_loose("0x"), None)
  assert_eq(@conv.parse_int64_loose("0xZZ"), None)
  assert_eq(@conv.parse_int64_loose("123.56"), Some(123))
  assert_eq(@conv.parse_int64_loose(".123"), Some(0))
  assert_eq(@conv.parse_int64_loose("123."), Some(123))
  assert_eq(@conv.parse_int64_loose("-.5"), Some(0))
  assert_eq(@conv.parse_int64_loose("-0.9"), Some(0))
  assert_eq(@conv.parse_int64_loose("123L"), Some(123))
  assert_eq(@conv.parse_int64_loose("123f"), Some(123))
  assert_eq(@conv.parse_int64_loose("123X"), None)
  assert_eq(@conv.parse_int64_loose("2147483647"), Some(2147483647))
  assert_eq(@conv.parse_int64_loose("0"), Some(0))
  assert_eq(@conv.parse_int64_loose("-0"), Some(0))
  assert_eq(@conv.parse_int64_loose("12"), Some(12))
  assert_eq(@conv.parse_int64_loose("abc"), None)
  assert_eq(@conv.parse_int64_loose(""), None)
  assert_eq(@conv.parse_int64_loose("   "), None)
  assert_eq(@conv.parse_int64_loose("１２３"), Some(123))
  assert_eq(@conv.parse_int64_loose("1,234.5"), None)
  assert_eq(@conv.parse_int64_loose("1_000"), None)
  assert_eq(@conv.parse_int64_loose("12 L"), None)
  assert_eq(@conv.parse_int64_loose("true"), None)
  assert_eq(@conv.parse_int64_loose("1e5"), Some(100000))
  assert_eq(@conv.parse_int64_loose("1E5"), Some(100000))
  assert_eq(@conv.parse_int64_loose("NaN"), None)
  assert_eq(@conv.parse_int64_loose("Infinity"), None)
  assert_eq(@conv.parse_int64_loose("123.456.789"), None)
  assert_eq(@conv.parse_int64_loose("1.234,5"), None)
  assert_eq(@conv.parse_int64_loose("\u{3000}"), None)
  assert_eq(@conv.parse_int64_loose("123L"), Some(123))
  assert_eq(@conv.parse_int64_loose("-123.56"), Some(-123))
  assert_eq(@conv.parse_int64_loose("9007199254740993"), Some(9007199254740993))
  assert_eq(@conv.parse_int64_loose("2147483648"), Some(2147483648))
  assert_eq(@conv.parse_int64_loose("-2147483649"), Some(-2147483649))
  assert_eq(@conv.parse_int64_loose("9223372036854775808"), None)
  assert_eq(@conv.parse_int64_loose("1.2e3"), Some(1200))
  assert_eq(@conv.parse_int64_loose("5e-3"), Some(0))
  assert_eq(@conv.parse_int64_loose("-1e-5"), Some(0))
  assert_eq(@conv.parse_int64_loose("1e"), None)
  assert_eq(@conv.parse_int64_loose("1e309"), None)
  assert_eq(@conv.parse_int64_loose("0x1p3"), None)
  assert_eq(@conv.parse_int64_loose("1e-324"), Some(0))
  assert_eq(@conv.parse_int64_loose("\u{00A0}123"), Some(123))
  assert_eq(@conv.parse_int64_loose("12l"), Some(12))
  assert_eq(@conv.parse_int64_loose("12D"), Some(12))
}

///|
// 越界指数/十六进制/NaN/Infinity/分组/下划线/尾随垃圾一律 None：core 的 parse_double 与 Java 的 Double.parseDouble 不是一套文法
test "parse_double_loose 的十进制子集（#9.11）" {
  assert_eq(@conv.parse_double_loose("123"), Some(123.0))
  assert_eq(@conv.parse_double_loose("007"), Some(7.0))
  assert_eq(@conv.parse_double_loose("+123"), Some(123.0))
  assert_eq(@conv.parse_double_loose("-123"), Some(-123.0))
  assert_eq(@conv.parse_double_loose(" 123 "), Some(123.0))
  assert_eq(@conv.parse_double_loose("0x1F"), None)
  assert_eq(@conv.parse_double_loose("0Xff"), None)
  assert_eq(@conv.parse_double_loose("0x"), None)
  assert_eq(@conv.parse_double_loose("0xZZ"), None)
  assert_eq(@conv.parse_double_loose("123.56"), Some(123.56))
  assert_eq(@conv.parse_double_loose(".123"), Some(0.123))
  assert_eq(@conv.parse_double_loose("123."), Some(123.0))
  assert_eq(@conv.parse_double_loose("-.5"), Some(-0.5))
  assert_eq(@conv.parse_double_loose("-0.9"), Some(-0.9))
  assert_eq(@conv.parse_double_loose("123L"), Some(123.0))
  assert_eq(@conv.parse_double_loose("123f"), Some(123.0))
  assert_eq(@conv.parse_double_loose("123X"), None)
  assert_eq(@conv.parse_double_loose("2147483647"), Some(2147483647.0))
  assert_eq(@conv.parse_double_loose("0"), Some(0.0))
  assert_eq(@conv.parse_double_loose("-0"), Some(-0.0))
  assert_eq(@conv.parse_double_loose("12"), Some(12.0))
  assert_eq(@conv.parse_double_loose("abc"), None)
  assert_eq(@conv.parse_double_loose(""), None)
  assert_eq(@conv.parse_double_loose("   "), None)
  assert_eq(@conv.parse_double_loose("１２３"), Some(123.0))
  assert_eq(@conv.parse_double_loose("1,234.5"), None)
  assert_eq(@conv.parse_double_loose("1_000"), None)
  assert_eq(@conv.parse_double_loose("12 L"), None)
  assert_eq(@conv.parse_double_loose("true"), None)
  assert_eq(@conv.parse_double_loose("1e5"), Some(100000.0))
  assert_eq(@conv.parse_double_loose("1E5"), Some(100000.0))
  assert_eq(@conv.parse_double_loose("NaN"), None)
  assert_eq(@conv.parse_double_loose("Infinity"), None)
  assert_eq(@conv.parse_double_loose("123.456.789"), None)
  assert_eq(@conv.parse_double_loose("1.234,5"), None)
  assert_eq(@conv.parse_double_loose("\u{3000}"), None)
  assert_eq(@conv.parse_double_loose("123L"), Some(123.0))
  assert_eq(@conv.parse_double_loose("-123.56"), Some(-123.56))
  assert_eq(@conv.parse_double_loose("1e"), None)
  assert_eq(@conv.parse_double_loose("1e309"), None)
  assert_eq(@conv.parse_double_loose("0x1p3"), None)
  assert_eq(@conv.parse_double_loose("5e-3"), Some(0.005))
  assert_eq(@conv.parse_double_loose("-1e-5"), Some(-1.0e-05))
  assert_eq(@conv.parse_double_loose("2147483648"), Some(2147483648.0))
  assert_eq(
    @conv.parse_double_loose("9007199254740993"),
    Some(9007199254740992.0),
  )
  assert_eq(@conv.parse_double_loose("1.2e3"), Some(1200.0))
  assert_eq(@conv.parse_double_loose("\u{00A0}123"), Some(123.0))
  assert_eq(@conv.parse_double_loose("12d"), Some(12.0))
  assert_eq(@conv.parse_double_loose("-1e-324"), Some(-0.0))
}

///|
// core 把 Json::value/as_object 等 8 条取值方法全线标 @deprecated（json.mbt:17~80），这条腿就是官方建议的那个 match
test "field 只在 Object 上取值（#9.12）" {
  assert_eq(
    shape(
      @conv.field(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a",
      ),
    ),
    "命中:{\"b\":[10,20,{\"c\":\"x\"}]}",
  )
  assert_eq(
    shape(
      @conv.field(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "n",
      ),
    ),
    "命中:1",
  )
  assert_eq(
    shape(
      @conv.field(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "z",
      ),
    ),
    "命中:null",
  )
  assert_eq(
    shape(
      @conv.field(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "nope",
      ),
    ),
    "未命中",
  )
  assert_eq(
    shape(
      @conv.field(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "",
      ),
    ),
    "未命中",
  )
  assert_eq(shape(@conv.field(j("1"), "a")), "未命中")
  assert_eq(shape(@conv.field(j("[1,2]"), "0")), "未命中")
  assert_eq(shape(@conv.field(j("null"), "a")), "未命中")
  assert_eq(shape(@conv.field(j("\"text\""), "a")), "未命中")
}

///|
// 点段走键、方括号段走下标；命中的值用 stringify 形状比对（实测三档一致）
test "get_by_path 命中档（#9.13）" {
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a.b[0]",
      )
    }),
    "命中:10",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a.b[1]",
      )
    }),
    "命中:20",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a.b[2].c",
      )
    }),
    "命中:\"x\"",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "n",
      )
    }),
    "命中:1",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "s",
      )
    }),
    "命中:\"1\"",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "z",
      )
    }),
    "命中:null",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a.b",
      )
    }),
    "命中:[10,20,{\"c\":\"x\"}]",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a",
      )
    }),
    "命中:{\"b\":[10,20,{\"c\":\"x\"}]}",
  )
}

///|
// 下标越界、路径穿过标量、键不存在都是 None；负数下标文法合法但取不到（hutool BeanPath 也取不到）
test "get_by_path 未命中与越界下标 ⇒ None（#9.13）" {
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a.b[3]",
      )
    }),
    "未命中",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a.b[-1]",
      )
    }),
    "未命中",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "x.y",
      )
    }),
    "未命中",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a.b.c",
      )
    }),
    "未命中",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "n.x",
      )
    }),
    "未命中",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "s[0]",
      )
    }),
    "未命中",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a.z.z",
      )
    }),
    "未命中",
  )
  assert_eq(pshape(() => @conv.get_by_path(j("null"), "a")), "未命中")
  assert_eq(pshape(() => @conv.get_by_path(j("[1,2]"), "0")), "未命中")
}

///|
// 本包唯一的 raise 面：路径文法本身写坏。值转换失败一律走 Option（hutool 的 ConvertException 面不跟随，spec §2）
test "get_by_path 坏路径 raise BadPath（#9.13）" {
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "",
      )
    }),
    "BadPath:",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a..b",
      )
    }),
    "BadPath:a..b",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        ".a",
      )
    }),
    "BadPath:.a",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a.",
      )
    }),
    "BadPath:a.",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a[b",
      )
    }),
    "BadPath:a[b",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a]",
      )
    }),
    "BadPath:a]",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a[]",
      )
    }),
    "BadPath:a[]",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a[x]",
      )
    }),
    "BadPath:a[x]",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "[",
      )
    }),
    "BadPath:[",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "]",
      )
    }),
    "BadPath:]",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a[1",
      )
    }),
    "BadPath:a[1",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a[1]b",
      )
    }),
    "BadPath:a[1]b",
  )
  assert_eq(
    pshape(() => {
      @conv.get_by_path(
        j(
          "{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}",
        ),
        "a b",
      )
    }),
    "BadPath:a b",
  )
}

///|
// hutool ArrayConverter 对「单纯字符串」就是按逗号劈开；转不出的元素丢掉——Java 的两套形状（对象数组填 null / 基本类型数组抛错）都不跟随
test "to_array：数组逐项、字符串逗号切分、坏元素跳过（#9.15）" {
  assert_eq(
    @conv.to_array(j("[\"1\",\"2\",0.1,123.456,true,null,{}]"), @conv.to_int64),
    [1, 2, 0, 123, 1],
  )
  assert_eq(@conv.to_array(j("[1,1e5,\"x\"]"), @conv.to_int64), [1, 100000])
  assert_eq(@conv.to_array(j("[]"), @conv.to_int64), [])
  assert_eq(@conv.to_array(j("[\"1\",\"7\"]"), @conv.to_int64), [1, 7])
  assert_eq(@conv.to_array(j("[[\"1\"],\"7\"]"), @conv.to_int64), [7])
  assert_eq(@conv.to_array(j("5"), @conv.to_int64), [])
  assert_eq(@conv.to_array(j("null"), @conv.to_int64), [])
  assert_eq(@conv.to_array(j("{\"a\":1}"), @conv.to_int64), [])
  assert_eq(@conv.to_array(j("\"1,2, 3\""), @conv.to_int64), [1, 2, 3])
  assert_eq(@conv.to_array(j("\"1,,2\""), @conv.to_int64), [1, 2])
  assert_eq(@conv.to_array(j("\"\""), @conv.to_int64), [])
  assert_eq(@conv.to_array(j("\"a,b\""), @conv.to_int64), [])
  assert_eq(@conv.to_array(j("\"1e5,9007199254740993,\""), @conv.to_int64), [
    100000, 9007199254740993,
  ])
  assert_eq(@conv.to_array(j("\"1,2,3\""), @conv.to_int64), [1, 2, 3])
  assert_eq(@conv.to_array(j("[\"1\",\"2\"]"), @conv.to_str), ["1", "2"])
}

///|
// 键保持原字符串与插入序（core 的 Map 本身就是插入序，见 spec §1）；值转不出的条目整条不写，不是补个 0 占位
test "to_map：Object 逐项、坏值整条不写入（#9.16）" {
  let m0 = @conv.to_map(
    j("{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1,\"z\":null,\"s\":\"1\"}"),
    @conv.to_int64,
  )
  assert_eq(m0.keys().to_array(), ["n", "s"])
  assert_eq(m0.values().to_array(), [1, 1])
  let m1 = @conv.to_map(j("{\"a\":\"1\"}"), @conv.to_int64)
  assert_eq(m1.keys().to_array(), ["a"])
  assert_eq(m1.values().to_array(), [1])
  let m2 = @conv.to_map(j("{\"a\":1,\"b\":\"x\",\"c\":2}"), @conv.to_int64)
  assert_eq(m2.keys().to_array(), ["a", "c"])
  assert_eq(m2.values().to_array(), [1, 2])
  let m3 = @conv.to_map(j("{}"), @conv.to_int64)
  assert_eq(m3.keys().to_array(), [])
  assert_eq(m3.values().to_array(), [])
  assert_eq(@conv.to_map(j("5"), @conv.to_int64).keys().to_array(), [])
  assert_eq(@conv.to_map(j("null"), @conv.to_int64).keys().to_array(), [])
  assert_eq(@conv.to_map(j("[1,2]"), @conv.to_int64).keys().to_array(), [])
}

///|
// 雪花 id 的数字形态走 repr：只读 Double 会把 9007199254740993 撞成 ...992（三档实测 rp| 腿）。键缺失/非数组都不报错，给空数组
test "get_ids：ids 键的字符串与数字两形态（#9.14）" {
  assert_eq(@conv.get_ids(j("{\"ids\":[\"1\",\"2\"]}")), [1, 2])
  assert_eq(@conv.get_ids(j("{\"ids\":[1,\"1e5\"]}")), [1, 100000])
  assert_eq(
    @conv.get_ids(j("{\"ids\":[\"9007199254740993\",\"9007199254740993\"]}")),
    [9007199254740993, 9007199254740993],
  )
  assert_eq(@conv.get_ids(j("{\"ids\":[\"x\",123.456,{},null]}")), [123])
  assert_eq(@conv.get_ids(j("{\"ids\":[\"[1]\"]}")), [])
  assert_eq(@conv.get_ids(j("{\"ids\":\"1,2\"}")), [1, 2])
  assert_eq(@conv.get_ids(j("{}")), [])
  assert_eq(@conv.get_ids(j("{\"ids\":null}")), [])
  assert_eq(@conv.get_ids(j("{\"ids\":5}")), [])
  assert_eq(@conv.get_ids(j("null")), [])
  assert_eq(@conv.get_ids(j("5")), [])
  assert_eq(@conv.get_ids(j("\"text\"")), [])
}

///|
// 对位 ConverterRegistry.convert(type, value, default) 的 isCustomFirst=true（源码 :262）——全局注册表换成一等闭包组合，优先序显式写出来
test "chain：自定义闭包优先、None 才落内置（#9.17）" {
  let always7 = fn(_ : Json) -> Int64? { Some((7 : Int64)) }
  assert_eq(@conv.chain(always7, @conv.to_int64)(j("[1]")), Some(7))
  assert_eq(@conv.chain(always7, @conv.to_int64)(j("123")), Some(7))
  assert_eq(@conv.to_int64(j("[1]")), None)
  assert_eq(
    @conv.chain(fn(_ : Json) -> Int64? { None }, @conv.to_int64)(j("123")),
    Some(123),
  )
  // 用户注册的闭包：认 @ 前缀的串。hutool 靠 addConverter(Type, Converter) 注册的东西，
  // 无反射的 MoonBit 里就是闭包本身——目标类型由函数名定，扩展点由闭包参数给（spec §0.2）
  let at_form = fn(x : Json) -> Int64? {
    match x {
      String(s) =>
        if s.length() > 1 && s[0:1].to_owned() == "@" {
          @conv.parse_int64_loose(s[1:].to_owned())
        } else {
          None
        }
      _ => None
    }
  }
  assert_eq(@conv.chain(at_form, @conv.to_int64)(j("\"@10\"")), Some(10))
  assert_eq(@conv.chain(at_form, @conv.to_int64)(j("\"123\"")), Some(123))
  assert_eq(@conv.chain(at_form, @conv.to_int64)(j("\"zz\"")), None)
  assert_eq(
    @conv.to_array(j("[\"@10\",\"5\"]"), @conv.chain(at_form, @conv.to_int64)),
    [10, 5],
  )
}
