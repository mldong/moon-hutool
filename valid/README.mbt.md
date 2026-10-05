# valid

hutool `Validator` 的 **MoonBit 对位·第一批**：15 件码表判定，全部 `String -> Bool`，**没有错误面**。

完整边界矩阵与逐条读数来源见 [`docs/spec/11-valid.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/11-valid.md)。本页只放**典型用法**，
每条都带期望值——这些 `test` 块会被 `moon test` 真编译真执行。

> 状态：**已实现**（10-05 两笔：契约 `a772ca9`、落地见 ROADMAP 第 11 行）。文档块与 `valid_test.mbt` 同受
> "期望值冻结"约束（门禁 G5），`wasm`/`js`/`wasm-gc` 三档读数一致，native 档由 CI 编译出证。

## 这一包的全部工作其实是"改写码表"

hutool 的判定走 `RegexPool` 常量，而实测 **34 条里 24 条带 core 不收的写法**（`\d` 18 / `\w` 4 / `\xHH` 2）。
本包的立场是**改写到命中集相同为止**：每条码表都在同一批样本上与参照实现逐条对撞（127 条、0 分岔），
改不到相同的整件挂账，不做"大概一样"的翻译。

```mbt check
///|
test "码表已改写成 core 方言：POSIX 类替代 \\d \\w" {
  assert_eq(@valid.is_general("abc_123"), true)
  assert_eq(@valid.is_general("a b"), false)
  // Java 的 `\w` 与 core 的 `[[:word:]]` 同为 ASCII 档，所以这一件不需要声明分岔
  assert_eq(@valid.is_word("ABC"), true)
  assert_eq(@valid.is_word("abc123"), false)
}
```

```mbt check
///|
test "整串语义：不是「有一处命中」" {
  assert_eq(@valid.is_money("1.25"), true)
  // 参照实现的小数位不封顶（实测腿 A：`1.222` 判真）⇒ 本包照收，不替它加"两位小数"的想当然
  assert_eq(@valid.is_money("1.222"), true)
  assert_eq(@valid.is_money(".5"), false)
  assert_eq(@valid.is_mobile("13800138000"), true)
  assert_eq(@valid.is_mobile("8613800138000"), true)
  assert_eq(@valid.is_mobile("138001380001"), false)
}
```

```mbt check
///|
test "IPv4 的段界值是逐段量出来的（前导零照收）" {
  assert_eq(@valid.is_ipv4("192.168.1.1"), true)
  assert_eq(@valid.is_ipv4("255.255.255.255"), true)
  assert_eq(@valid.is_ipv4("256.1.1.1"), false)
  // 参照实现的码表允许每段 1~3 位数字，实测 `01.01.01.01` 判真 ⇒ 同档跟随
  assert_eq(@valid.is_ipv4("01.01.01.01"), true)
  assert_eq(@valid.is_ipv4("1.1.1"), false)
  assert_eq(@valid.is_ipv6("fe80::1%1"), true)
  assert_eq(@valid.is_ipv6("2001:db8::::1"), false)
}
```

```mbt check
///|
test "MAC 的分隔符写成择路：字符类里 `-` 不能与别的字符并排" {
  assert_eq(@valid.is_mac("00-11-22-33-44-55"), true)
  assert_eq(@valid.is_mac("00:11:22:33:44:55"), true)
  assert_eq(@valid.is_mac("0011.2233.4455"), true)
  assert_eq(@valid.is_mac("gg:11:22:33:44:55"), false)
  // `[:-]` 这种写法在本方言里编译期报错，实测；写成 `(:|-)` 才编得过且命中集与参照实现相同
}
```

```mbt check
///|
test "UUID 认两种形状：带横线 8-4-4-4-12 与 32 位无横线，大小写不敏感" {
  assert_eq(@valid.is_uuid("dcd01ac8-892e-4a47-88d9-f8ed2cb74eee"), true)
  assert_eq(@valid.is_uuid("DCD01AC8892E4A4788D9F8ED2CB74EEE"), true)
  assert_eq(@valid.is_uuid("dCd01aC8-892E-4a47-88D9-f8eD2cB74eEE"), true)
  assert_eq(@valid.is_uuid("dcd01ac8-892e-4a47-88d9-f8ed2cb74ee"), false)
}
```

```mbt check
///|
test "限长档的两个件：界值只当长度，不当内容校验" {
  assert_eq(@valid.is_general_between("abc", 1, 3), true)
  assert_eq(@valid.is_general_between("abcd", 1, 3), false)
  assert_eq(@valid.is_general_at_least("ab", 2), true)
  assert_eq(@valid.is_general_at_least("a", 2), false)
  assert_eq(@valid.is_zip_code("100000"), true)
  assert_eq(@valid.is_zip_code("999077"), true)
  assert_eq(@valid.is_zip_code("999079"), false)
}
```

## 这一包不做什么

| 不做 | 为什么 |
|---|---|
| `validateXxx(value, errorMsg)` 那 38 个变体 | 参照实现抛 `ValidateException` 并做 `{}` 模板；本库错误面由调用方决定，不搬这一套 |
| 18 个存在性判定（`isNull`/`isEmpty`/`equal`/`isTrue`…） | MoonBit 有 `Option` 与 `==`，搬过来是噪音 |
| 全局模式池 | 与 `re` 同一条立场：纯计算库不带进程级可变表 |
| `is_letter`/`is_upper_case`/`is_lower_case` | 参照实现是 `Character.isLetter/isUpperCase/isLowerCase`——**Unicode 类别表**；core 只有 ASCII 档谓词。引码表还是只承诺 ASCII 档，这条口径待拍，先不进契约 |
| `is_email` 一族、中文族 | 码表分别含 `\xHH` 类与代理对码元区间，改写量大且要逐条对撞 ⇒ 第二批 |
| `is_birthday` | 参照实现走 `find()` + 取组，且年界值读 `DateUtil.thisYear()`（墙钟）⇒ 与本库"时间显式传参"冲突，界值怎么进签名待拍 |
| `is_url` | 参照实现走 `java.net.URL` 的协议解析器（实测 `URL`/`URL_HTTP` 两条常量它根本没用） |
| `is_number`/`has_number`、`is_between` | 数值文法要与 `conv` 对齐成一张嘴，不能一处两判 ⇒ 第二批 |
| `is_citizen_id`/`is_credit_code` | 实质是 mod-11 / mod-31 校验位 + 区划码表，归 ROADMAP 第 19 行 `typex` |
