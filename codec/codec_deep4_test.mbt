///|
// codec 第四批补档（10-08）——三条没人打过的失败通道与三处 RFC 形状档。
// 判据来源逐条点名：本包的 URL 族权威参照是 **RFC 3986**（§3.1 scheme、§3.2.2 reg-name、
// §5.2.4 点段删除）而不是 hutool 的 `UrlBuilder`（spec 05-codec §1 第 133 行写明"不搬其实现"），
// 错误下标口径按 §0 那张「`BadPadding` 的 `at` 只有一个口径」表。
// 所以这一批是**从写下的契约推导期望再真跑**（推导错会被红样打回，不拿实现输出当期望）。
// 复用 `codec_test.mbt` 里的 `err_shape`/`url_of`（同包共享顶层命名空间，本件不重名再定义一件）。

///|
test "@codec 填充之后又来非填充字符：`at` 取那个 `=` 的下标（Base64 腿）" {
  // §0 的口径表第一行：「有 `=`，但数量不对或不在末尾 ⇒ 那个 `=` 的下标」。
  // 现有夹具只打过"余数不可能"那一行（`Zm9vY` ⇒ @4），这一行没人打过 ⇒ codec.mbt:731 长期未覆盖
  assert_eq(
    err_shape(() => @codec.b64_decode_url("Zm9v=Y")),
    "BadPadding Zm9v=Y@4",
  )
  assert_eq(
    err_shape(() => @codec.b64_decode_url("Zm9v==Y=")),
    "BadPadding Zm9v==Y=@4",
  )
}

///|
test "@codec 同一档的 Base32 腿（独立扫描循环，不是复用 Base64 那段）" {
  // 与上一条同一口径，但走 `b32_decode`：两处 `raise BadPadding` 是分开的两份代码（:731 与 :824），
  // 只打一处不能算另一处覆盖——这条就是为 :824 写的
  assert_eq(err_shape(() => @codec.b32_decode("MZXW=Y")), "BadPadding MZXW=Y@4")
}

///|
test "@codec Url::parse 的 `@` 空 userinfo 空 host 档（authority 只写一个 at）" {
  // §1 第 109 行：「authority 给了 `@` 而 userinfo/host 都空同理报出错处」⇒ 报在 `@` 自己那格。
  // `http://@/` 的 authority 区间是 [7,8)，userinfo 取 [7,7) 为空、host 取 [8,8) 为空 ⇒ 出错处 = 7
  assert_eq(
    err_shape(() => @codec.Url::parse("http://@/")),
    "IllegalChar http://@/@7",
  )
  // 对照：只给 userinfo 不给 host 是合法的（RFC 的 `[userinfo "@"] host [":" port]`，host 可为空）
  assert_eq(url_of("http://user@/x").host, "")
  assert_eq(url_of("http://user@/x").userinfo, "user")
}

///|
test "@codec Url::parse 的 host 收 sub-delims 全 11 个字符（RFC 3986 reg-name）" {
  // :1060 那一档列的就是 sub-delims = `!$&'()*+,;=`（§3.2.2 的 reg-name = unreserved + sub-delims + `%`）
  let u = url_of("http://a!$&'()*+,;=b/x")
  assert_eq(u.host, "a!$&'()*+,;=b")
  assert_eq(u.to_string(), "http://a!$&'()*+,;=b/x")
  // `%` 与 unreserved 里的 `~` 同在允许集内；表外字符仍报**那一格**的下标（对照档）
  assert_eq(url_of("http://a~b%20c/").host, "a~b%20c")
  assert_eq(
    err_shape(() => @codec.Url::parse("http://a b/")),
    "IllegalChar http://a b/@8",
  )
}

///|
test "@codec Url::parse 的 scheme 续字符 `+` `-` `.` 与数字（RFC 3986 §3.1）" {
  // :1079 那一档：首字符必须是字母，其后允许 ALPHA / DIGIT / `+` / `-` / `.`
  assert_eq(url_of("ftp+1.2-x://h").scheme, "ftp+1.2-x")
  assert_eq(url_of("My-Scheme.2+1://H").normalize().scheme, "my-scheme.2+1")
  // 对照：首字符不是字母 ⇒ 整串按"没有 scheme"处理（path 吃掉冒号前的部分）
  assert_eq(url_of("1ftp://h").scheme, "")
}

///|
test "@codec normalize 的点段删除：末尾是 `.` 或 `..` 时留尾斜杠（RFC 3986 §5.2.4 2.B/2.C）" {
  // 现有夹具里 `.`/`..` 都不在末段（`/a/../b/./c`），所以 :1189 与 :1193 那两档没被走到。
  // 规范 2.B：末段是 `.` ⇒ 换成空段 ⇒ 留一个尾斜杠；2.C：末段是 `..` ⇒ 删掉前一段并留空段 ⇒ 同样留尾斜杠
  let n : (String) -> String = t => url_of(t).normalize().to_string()
  assert_eq(n("http://a/x/y/."), "http://a/x/y/")
  assert_eq(n("http://a/x/y/.."), "http://a/x/")
  // 这一条本来的推导是 `http://a/x/y/`，被真跑打回：按 §5.2.4 逐档走
  // （`/x` 出 → `/./` 折成 `/` → `/../` 把刚出去的 `/x` 撤回 → `/y` 出 → `/.` 折成 `/`）答案是 `/y/`。
  // 记在这里是因为它正好演示"契约推导也要真跑"：错的是推导，不是实现。
  assert_eq(n("http://a/x/./../y/."), "http://a/y/")
  // 幂等仍然成立：末尾留出的那个尾斜杠不会被下一轮吃掉
  assert_eq(n(n("http://a/x/y/..")), "http://a/x/")
}

///|
test "@codec normalize 走相对路径那一支（没有 authority 也没有前导斜杠）" {
  // :1206 是 `joined` 那条非 absolute 出口。RFC §5.2.4 的第二个 worked example
  // （`mid/content=5/../6` ⇒ `mid/6`）现有测试是**挂在绝对路径上**跑的，相对这一支出过文件但没执行过
  let n : (String) -> String = t => url_of(t).normalize().to_string()
  assert_eq(n("mid/content=5/../6"), "mid/6")
  assert_eq(n("x/y/../z"), "x/z")
  // 空路径档（:1177）：没有 authority 而 path 为空 ⇒ 原样给空串，不许凭空造一个 `/`
  // （§1 第 111 行只承诺「有 authority 而 path 为空 ⇒ 归一为 `/」，两档要分开钉）
  assert_eq(url_of("").normalize().path, "")
  assert_eq(url_of("").normalize().to_string(), "")
}
