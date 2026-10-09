# codec

hutool `Codec` 家族的 MoonBit 对位：Base64 的 URL/MIME/宽松三档、Base32（含 hex 表）、Base58 与 Base58Check、Base62（两版表）、任意进制 Radix，外加 x-www-form-urlencoded 的编解码/键值对往返，以及 URL 的组件划分、组装与语法归一化。

完整边界矩阵与逐条读数来源见 [`docs/spec/05-codec.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/05-codec.md)。

> 状态：**两批都已落地**（10-05）。第一批是 Base64 三档 / Base32 / Base58 / Base62 / Radix，第二批是
> §7 form 档与 §8 URL 组件——下面每个块的期望值都是当场跑出来的读数，wasm / js / wasm-gc 三档一致。
> 期望串受"期望值冻结"约束：改任何期望须单独一笔并给外部读数来源（门禁 G5）。

## 三条先决口径

**一、表序写死，不接受调用方传表。** Base32/Base58/Base62 的读数完全由表序决定——同一份字节换一张表就是另一个文本。允许传表等于允许静默改语义。

**二、解码默认严格，宽松只在点名 `lenient` 的那一档。** hutool 的 `decode` 一路宽容（大小写混吃、丢空白、补 `=`），本库把"宽容"变成一个必须被叫到的名字：默认档遇到表外字符就报错并给**下标**。

**三、空输入是合法输入。** RFC 4648 §10 的官方向量表第一条就是空串。

`core` 已有的三件（`encoding/base64` 标准表、`encoding/hex`、`encoding/percent`）本包**不重新包装**，理由见 [`docs/ROADMAP.md`](https://github.com/mldong/moon-hutool/blob/master/docs/ROADMAP.md) 与 spec §9。

## Base64：三档不是三个体面名字

```mbt check
///|
test "url 档与 MIME 档的读数" {
  // 判别样本：标准表出 `////`，url 表出 `____`——这两字符就是两张表唯一的不同
  assert_eq(@codec.b64_encode_url(@utf8.encode("中文")), "5Lit5paH")
  assert_eq(@codec.b64_encode_url(bytes_of_fff()), "____")
  assert_eq(@codec.b64_encode_url(bytes_of_fff(), padding=false), "____")
  // 标准表的 + 与 / 落在 url 表之外，MIME 却仍用标准表
  assert_eq(@codec.b64_encode_mime(@utf8.encode("中文")), "5Lit5paH\r\n")
  assert_eq(@codec.b64_decode_url("____"), bytes_of_fff())
}

///|
/// 裸字节字面量会推断成 Array[Int] ⇒ 一律走这个带类型标注的 helper
fn bts(xs : Array[Byte]) -> Bytes {
  Bytes::from_array(xs.exact_view())
}

///|
fn bytes_of_fff() -> Bytes {
  bts([0xff, 0xff, 0xff])
}
```

`b64_decode_url` 与 `b64_decode_lenient` 的分工是**同一串输入，一档报错一档出值**——不是"宽松一点更友好"，而是把"我在用哪一档"交给调用方。

```mbt check
///|
test "严格档报错、宽松档出值" {
  assert_eq(err_text(() => @codec.b64_decode_url("////")), "IllegalChar ////@0")
  assert_eq(@codec.b64_decode_lenient("////"), bts([0xff, 0xff, 0xff]))
  assert_eq(@codec.b64_decode_lenient("____"), bts([0xff, 0xff, 0xff]))
  // 空白与换行被忽略，缺失的 `=` 自己补——这正是 hutool `decode` 的默认行为
  assert_eq(@codec.b64_decode_lenient("5Lit 5paH"), @utf8.encode("中文"))
}

///|
fn[A] err_text(g : () -> A raise @codec.CodecError) -> String {
  try {
    let _ = g()
    "未抛错"
  } catch {
    @codec.IllegalChar(input, at) => "IllegalChar \{input}@\{at}"
    @codec.BadPadding(input, at) => "BadPadding \{input}@\{at}"
    @codec.RadixOutOfRange(v, bound) => "RadixOutOfRange \{v} bound=\{bound}"
    @codec.ValueOverflow(input) => "ValueOverflow \{input}"
    @codec.ChecksumMismatch => "ChecksumMismatch"
    @codec.BadUtf8(input) => "BadUtf8 \{input}"
  }
}
```

## Base32：RFC 4648 §10 的九条向量两张表都要过

```mbt check
///|
test "默认表与 hex 表" {
  assert_eq(@codec.b32_encode(@utf8.encode("foobar")), "MZXW6YTBOI======")
  assert_eq(
    @codec.b32_encode(@utf8.encode("foobar"), hex=true),
    "CPNMUOJ1E8======",
  )
  assert_eq(@codec.b32_encode(@utf8.encode("f"), padding=false), "MY")
  assert_eq(@codec.b32_decode("mzxw6ytboi======"), @utf8.encode("foobar"))
  assert_eq(
    @codec.b32_decode("CPNMUOJ1E8======", hex=true),
    @utf8.encode("foobar"),
  )
}
```

填充的错误分两种报法，下标口径在 spec §1 定死：**有 `=` 就报那个 `=` 的位置，没有 `=` 而余数不可能就报余数段的起始位**。

```mbt check
///|
test "填充的两种下标口径" {
  assert_eq(err_text(() => @codec.b32_decode("MZXW6Y")), "BadPadding MZXW6Y@0")
  assert_eq(
    err_text(() => @codec.b32_decode("MZXW======")),
    "BadPadding MZXW======@4",
  )
  assert_eq(
    err_text(() => @codec.b32_decode("MZXWE1==")),
    "IllegalChar MZXWE1==@5",
  )
}
```

## Base58：前导零折成前导 `1`，表外四个字符必须点名

```mbt check
///|
test "b58 往返与表外字符" {
  assert_eq(
    @codec.b58_encode(@utf8.encode("Hello World!")),
    "2NEpo7TZRRrLZSi2U",
  )
  assert_eq(@codec.b58_encode(bts([0x00, 0x00, 0x68, 0x69])), "118wr")
  assert_eq(@codec.b58_encode(bts([0x00])), "1")
  assert_eq(
    @codec.b58_decode("2NEpo7TZRRrLZSi2U"),
    @utf8.encode("Hello World!"),
  )
  // 表里没有 0、O、I、l——把它们当"看不见的近似"就会一路带到下游
  assert_eq(err_text(() => @codec.b58_decode("0OIl")), "IllegalChar 0OIl@0")
}
```

Base58Check 是 `version ‖ payload ‖ 双 SHA-256 的前 4 字节`。它存在的唯一理由就是"改一位必须红"。

```mbt check
///|
test "校验位不符就失败，绝不返回脏 payload" {
  let addr = "159LKv1gGepptdXG7coMf6QhdTrgDsG7i2"
  assert_eq(@codec.b58_check_encode(hash160_fixture()), addr)
  assert_eq(@codec.b58_check_decode(addr), hash160_fixture())
  assert_eq(
    err_text(() => @codec.b58_check_decode("159LKv1gGepptdXG7coMf6QhdTrgDsG7i3")),
    "ChecksumMismatch",
  )
  assert_eq(err_text(() => @codec.b58_check_decode("1")), "BadPadding 1@0")
}

///|
/// hash160(sha256("mldong"))，Python 现算的 20 字节（见 spec #4 的夹具说明）
fn hash160_fixture() -> Bytes {
  bts([
    0x2d, 0x73, 0xf6, 0xa4, 0x88, 0x5c, 0xe6, 0x21, 0x18, 0x41, 0x7e, 0xb7, 0x3f,
    0xb4, 0x05, 0xa0, 0x53, 0x9e, 0xfa, 0x21,
  ])
}
```

## Base62 两版表只差顺序、不差字符集

同一串文本用错表**不会报错**，会给出另一个值——这就是 `inverted` 必须显式、且不做自动识别的理由。

```mbt check
///|
test "GMP 与 inverted" {
  assert_eq(@codec.b62_encode(@utf8.encode("Hello World!")), "T8dgcjRGkZ3aysdN")
  assert_eq(
    @codec.b62_encode(@utf8.encode("Hello World!"), inverted=true),
    "t8DGCJrgKz3AYSDn",
  )
  assert_eq(@codec.b62_decode("T8dgcjRGkZ3aysdN"), @utf8.encode("Hello World!"))
  assert_true(
    @codec.b62_decode("t8DGCJrgKz3AYSDn") != @utf8.encode("Hello World!"),
  )
  assert_eq(
    err_text(() => @codec.b62_decode("T8dgcjRGkZ3aysdN+")),
    "IllegalChar T8dgcjRGkZ3aysdN+@16",
  )
}
```

## Radix：表序决定大小写合法性

`radix_alphabet` 是 `0-9A-Za-z`，而 `radix=N` 只用**前 N 个字符** ⇒ base36 里 `Z` 合法、`z` 非法。

```mbt check
///|
test "同一个数在三张表里" {
  assert_eq(@codec.radix_alphabet.char_length(), 62)
  assert_eq(@codec.radix_encode(4096L, 36), "35S")
  assert_eq(@codec.radix_encode(4096L, 58), "1Ca")
  assert_eq(@codec.radix_encode(4096L, 62), "144")
  assert_eq(@codec.radix_decode("144", 62), 4096L)
  assert_eq(@codec.radix_decode("Z", 36), 35L)
  assert_eq(err_text(() => @codec.radix_decode("z", 36)), "IllegalChar z@0")
  assert_eq(
    err_text(() => @codec.radix_encode(1L, 63)),
    "RadixOutOfRange 63 bound=62",
  )
}
```

负数走 `-` 前缀，而 `Int64::min()` 取绝对值这一步在 `Int64` 上仍然溢出 ⇒ 按无符号位权展开，读数写死在这里：

```mbt check
///|
test "两个端点" {
  assert_eq(@codec.radix_encode(9223372036854775807L, 62), "AzL8n0Y58m7")
  assert_eq(
    @codec.radix_encode(-9223372036854775808L, 2),
    "-1000000000000000000000000000000000000000000000000000000000000000",
  )
}
```

## x-www-form-urlencoded：表单不是 URI

core 的 `encoding/percent` 走 RFC 3986 的 unreserved 集（空格出 `%20`、`~` 放行、`*` 转义）；
表单那一档由 HTML 标准定义：**空格出 `+`、`~` 要转义、`*` 放行**。三条差异任何一条走错就是另一个值。

```mbt check
///|
test "表单档与 percent 档的分歧点" {
  assert_eq(@codec.form_encode("a b~*"), "a+b%7E*")
  assert_eq(@percent.encode("a b~*"), "a%20b~%2A")
  assert_eq(@codec.form_encode("中文"), "%E4%B8%AD%E6%96%87")
  // `+` 与 `%2B` 不是一回事：前者是空格，后者才是加号
  assert_eq(@codec.form_decode("a+b"), "a b")
  assert_eq(@codec.form_decode("a%2Bb"), "a+b")
  // 两档只在空格、`+`、`*`、`~` 四处不同：**其余输入必须同结果**（重叠区间一致才不是凭空另造一套）
  for s in ["a=b&c", "中文", "100%", "foo.bar-baz_qux"] {
    assert_eq(@codec.form_encode(s), @percent.encode(s))
  }
}
```

坏序列**报错**而不是换 U+FFFD：表单值坏掉通常是上游忘了编码，静默替换只会把脏值带进库。

```mbt check
///|
test "坏转义与非法 UTF-8 各有读数" {
  let got = try {
    let _ = @codec.form_decode("%zz")
    "没抛错"
  } catch {
    @codec.IllegalChar(input, at) => "IllegalChar \{input}@\{at}"
    _ => "错种"
  }
  assert_eq(got, "IllegalChar %zz@0")
  let bad = try {
    let _ = @codec.form_decode("%E4%B8")
    "没抛错"
  } catch {
    @codec.BadUtf8(_) => "BadUtf8"
    _ => "错种"
  }
  assert_eq(bad, "BadUtf8")
}
```

## URL 组件：`to_string` 一个字都不加

hutool `UrlBuilder` 靠三个 `get*WithDefault` 往输出里塞默认值（补 `http`、path 空补 `/`），那是最容易漂的一档。
本库把"补齐"单独收进 `normalize`，`to_string` 只做拼接，于是 **parse-then-build 对任意合法输入恒等**。

```mbt check
///|
test "组件划分与原样往返" {
  let u = @codec.Url::parse("http://user@www.example.com:8080/a/b?q=1#frag") catch {
    _ => abort("夹具必须可解析")
  }
  assert_eq(u.userinfo, "user")
  assert_eq(u.host, "www.example.com")
  assert_eq(u.port, 8080)
  assert_eq(u.query, Some("q=1"))
  assert_eq(u.fragment, Some("frag"))
  // 不以 `//` 开头就没有 authority：`mailto:` 的 `@` 属于 path
  assert_eq(
    (@codec.Url::parse("mailto:t@x.com") catch { _ => abort("夹具") }).path,
    "t@x.com",
  )
  for t in ["https://example.com", "//example.com/p", "?q=1"] {
    assert_eq(
      (@codec.Url::parse(t) catch { _ => abort("夹具") }).to_string(),
      t,
    )
  }
}
```

`normalize` 只做语法等价：scheme/host 小写、默认端口省略、点段删除、`%XX` 大写并把 unreserved 还原，
而且**幂等**；非法转义原样保留，不猜。两处边界要说清：**`%2E`（点号）不参与还原**——还原出来的 `.` 会被
随后的点段删除当成 `.`/`..` 吃掉，而原串那一格本是字面段（RFC 3986 §6.2.2.2 点过这一档）；
**空 host 的 authority 不承诺往返**——`file:///x` 会归成 `file:/x`，因为七个组件里"有没有 `//`"没有位置存。

```mbt check
///|
test "归一化是等价写法而非改语义" {
  let n : (String) -> String = t => {
    (@codec.Url::parse(t) catch { _ => abort("夹具") })
    .normalize()
    .to_string()
  }
  assert_eq(n("HTTP://EXAMPLE.com:80/%7Efoo"), "http://example.com/~foo")
  assert_eq(n("http://example.com/a/b/../../x"), "http://example.com/x")
  assert_eq(n("http://example.com"), "http://example.com/")
  assert_eq(n("http://example.com/%zz/a"), "http://example.com/%zz/a")
  assert_eq(n(n("http://a/x/y/../z")), "http://a/x/z")
}
```


## data URI 组装两件（10-10 批①）

它是**拼装器**不是编码器：数据原样带、charset 串原样带、base64 不校验。四条形状都有腿读数撑着
（`scripts/UrlPureLeg.java`），"顺手加一层 URL 编码"会把这五条全改错。

```mbt check
///|
test "data_uri 四条原样带过" {
  assert_eq(
    @codec.data_uri("text/plain", "utf-8", "hello world"),
    "data:text/plain;utf-8,hello world",
  )
  // charset 空串 ⇒ 整段 `;charset` 省略；不查表，`nope` 也照写
  assert_eq(@codec.data_uri("text/plain", "", "hi"), "data:text/plain,hi")
  assert_eq(
    @codec.data_uri("text/plain", "nope", "100%"),
    "data:text/plain;nope,100%",
  )
  // 数据不编码：百分号、空格、中文一律原样
  assert_eq(
    @codec.data_uri("text/plain", "utf-8", "中文 a"),
    "data:text/plain;utf-8,中文 a",
  )
  // base64 不校验；mime 为空也留分号
  assert_eq(
    @codec.data_uri_base64("text/plain", "aGk="),
    "data:text/plain;base64,aGk=",
  )
  assert_eq(
    @codec.data_uri_base64("", "not-base64!!"),
    "data:;base64,not-base64!!",
  )
}
```

## 这一层不做的事

`Base16Codec`（就是 core `encoding/hex`，换名转发）、`BCD`（**hutool 自己标了 `@Deprecated`**，逻辑是把两个十六进制位打进一个字节，语义与 core hex 重合）；`Caesar`/`Rot`（三行算术）、`Morse`/`PunyCode`/`Hashids`（要符号表或随机盐语义）。URL 这一层**不含** RFC 3986 §5.2.2 的引用解析（`urljoin` 那一套 base + reference，是另一套完整算法，要做另起一批；hutool `URLUtil.completeUrl` 看着像它的对位物，实测它把"是不是绝对 URL"委托给 `java.net.URL` 的协议白名单，判 deferred 的逐条读数在 [`docs/spec/05-codec.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/05-codec.md) §12.2）、IDN/punycode（要 RFC 3492 的表）、`UrlPath`/`UrlQuery` 那种链式可变 builder（本库给值类型，改字段走 `Url::{ ...u, host: "x" }`；攒参数用 `form_build` 直接给键值对列表，效果相同且可测）。逐条理由见 [`docs/ROADMAP.md`](https://github.com/mldong/moon-hutool/blob/master/docs/ROADMAP.md) 的「暂不做」「不做」两节与 spec §9。
