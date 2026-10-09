# text

hutool `StrUtil` / `CharSequenceUtil` 的 MoonBit 对位：空白判定、切分连接、子串截取、`{}` 占位、版本比较、脱敏掩码、命名法互转。

契约与边界矩阵见 [`docs/spec/01-text.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/01-text.md)。本页只放**典型用法**，每条都带期望值——这些 `test` 块会被 `moon test` 真编译真执行（抄 `moonbitlang/core/encoding/base64/README.mbt.md` 的机制），所以文档本身就是要通过的检查，不是装饰。

> 状态：**已实现**（10-04 第一批；10-10 批①补转义族与替换引擎）。本页每个 `test` 块都由`moon test` 真跑；块数与条数现读 `moon test --package text`，三档（`wasm`/`js`/`wasm-gc`）读数一致。
> 期望值仍是冻结状态：要改任何一条，必须单独一笔并给外部读数来源（`AGENTS.md` 红线一，门禁 G5/G11 双重盯着）。

## 用法

```mbt check
///|
test "is_blank 空白档" {
  assert_true(@text.is_blank("   "))
  assert_true(@text.is_blank("\t \n"))
  assert_false(@text.is_blank(" a"))
}
```

`is_empty` 与 `is_blank` 是**两档**，不合并：

```mbt check
///|
test "is_empty 与 is_blank 分档" {
  assert_true(@text.is_empty(""))
  assert_false(@text.is_empty(" ")) // 非空但全空白：empty 假、blank 真
  assert_true(@text.is_blank(" "))
}
```

## 截取：未命中时两个方向不对称

`sub_before` 未命中给**整串**，`sub_after` 未命中给**空串**——两个方向不对称，别"顺手统一"。
两者都按**第一个**分隔符切（hutool `isLastSeparator` 默认 false，源码 `CharSequenceUtil.java:2369/2446`）：

```mbt check
///|
test "sub_before / sub_after 未命中" {
  assert_eq(@text.sub_before("path/to/file.txt", "/"), "path") // 首个分隔符，不是最后一个
  assert_eq(@text.sub_before("nope", "/"), "nope") // 未命中 → 整串
  assert_eq(@text.sub_after("path/to/file.txt", "/"), "to/file.txt")
  assert_eq(@text.sub_after("nope", "/"), "") // 未命中 → 空串
}

///|
test "sub_between 可选带界定符" {
  assert_eq(@text.sub_between("hutool{abc}end", "{", "}"), "abc")
  assert_eq(
    @text.sub_between("hutool{abc}end", "{", "}", include_sep=true),
    "{abc}",
  )
  assert_eq(@text.sub_between("hutool abc end", "{", "}"), "")
}
```

## 切分与连接：空段保留

```mbt check
///|
test "split 保留空段" {
  assert_eq(@text.split("a,b,,c", ','), ["a", "b", "", "c"])
  assert_eq(@text.split("", ','), []) // 空输入是空数组，不是 [""]
  assert_eq(@text.split(" a , b ", ',', trim_result=true), ["a", "b"])
}

///|
test "join" {
  assert_eq(@text.join(["a", "b"], "-"), "a-b")
  assert_eq(@text.join(["a", "", "b"], "-"), "a--b")
}
```

## `format`：`{}` 占位，三条硬语义

参数不足时**未填的原样留着**（不报错、不填空）；前一字符是 `\` 的 `{}` 当字面量。位置索引语法 `{0}` **不做**——那是 JDK `MessageFormat` 的语义，与 `{}` 不同。

```mbt check
///|
test "format 三条硬语义" {
  assert_eq(@text.format("a{}b", ["1"]), "a1b")
  assert_eq(@text.format("id={} name={}", ["7"]), "id=7 name={}")
  assert_eq(@text.format("keep \\{}", []), "keep {}")
}
```

## 版本比较按数值，不按字典

```mbt check
///|
test "compare_version" {
  assert_eq(@text.compare_version("1.2.3", "1.2.10"), -1)
  assert_eq(@text.compare_version("1.0.0", "1.0"), 0) // 缺段补零
  assert_eq(@text.compare_version("2", "10"), -1) // 若按字典序这里会得 1
}
```

## 脱敏：下标按码点，越界夹紧

`hide` 的 `[start, end)` 与 `String::length()`（UTF-16 单元）**不是一套下标**，中文串要按码点算：

```mbt check
///|
test "hide 码点下标" {
  assert_eq(@text.hide("13012345678", 3, 7, '*'), "130****5678")
  assert_eq(@text.hide("中文测试", 1, 3, '*'), "中**试") // 区间外字符保留
  assert_eq(@text.hide("abc", 1, 99, '*'), "a**") // 越界夹紧，不报错
}
```

## 命名法互转

转换规则三条坑：连续大写当专有名词不拆；`to_camel_case` **只在含分隔符时转换**，否则原样返回；转换时其余字符转小写。

```mbt check
///|
test "naming 已冻结的三条" {
  assert_eq(@text.to_underline_case("userName"), "user_name")
  assert_eq(@text.to_camel_case("user_name"), "userName")
  assert_eq(@text.to_camel_case("userName"), "userName") // 无分隔符 → 原样返回
}
```

## 转义族（10-10 批①）

每条期望值都来自参照腿（`scripts/EscapeLeg.java` / `scripts/EntityTableLeg.java`），不是"看起来该这样"。
两族唯一的形差在撇号：XML 转、HTML4 不转。

```mbt check
///|
test "escape 实体族：XML 收撇号、HTML4 不收" {
  assert_eq(@text.escape_xml("a<b&c>d\"e'f"), "a&lt;b&amp;c&gt;d&quot;e&apos;f")
  assert_eq(@text.escape_html4("a<b&c>d\"e'f"), "a&lt;b&amp;c&gt;d&quot;e'f")
  // 一次只解一层：`&amp;amp;` → `&amp;`，要回到 `&` 得再解一次
  assert_eq(@text.unescape_xml("&amp;amp;"), "&amp;")
  // HTML4 认 `&copy;`；XML 的还原表只有那 5 条 + `&nbsp;`
  assert_eq(@text.unescape_xml("&copy;"), "&copy;")
  assert_eq(@text.unescape_html4("&copy;"), "\u{00a9}")
}
```

`escape` 是**百分号族**，与 core 的 `encoding/percent` 不是一张嘴：非 ASCII 出的是 IE 风格的
`%uXXXX`（逐 UTF-16 码元、小写十六进制），而且 `%` 自己也被转 ⇒ **不幂等**。

```mbt check
///|
test "escape 百分号族：`%uXXXX` 不是 UTF-8 百分号编码" {
  assert_eq(@text.escape("中文 a"), "%u4e2d%u6587%20a")
  assert_eq(@text.escape_all("ab"), "%61%62")
  assert_eq(@text.escape("%41"), "%2541") // 已编码的再编码一次
  assert_eq(@text.unescape("%41"), "A")
  // 不做 UTF-8 解码：`%e4%b8%ad` 出三个字符，不是"中"
  assert_eq(@text.unescape("%e4%b8%ad"), "\u{00e4}\u{00b8}\u{00ad}")
}
```

还原失败折成错误面；`safe_unescape` 是"吞掉、返回**入参**"（不是空串、不是部分解码）。

```mbt check
///|
test "unescape 的失败两档与 safe 档" {
  let a = try {
    let _ = @text.unescape("%zz")
    "未抛错"
  } catch {
    @text.BadHex(x) => "BadHex " + x
    @text.ShortInput => "ShortInput"
    _ => "其它"
  }
  assert_eq(a, "BadHex zz")
  let b = try {
    let _ = @text.unescape("%2")
    "未抛错"
  } catch {
    @text.BadHex(x) => "BadHex " + x
    @text.ShortInput => "ShortInput"
    _ => "其它"
  }
  assert_eq(b, "ShortInput")
  assert_eq(@text.safe_unescape("%zz"), "%zz")
}
```

`UnicodeUtil` 那三件是一把尺子三种入参：串档只转"不在可打印 ASCII 那段"的字符，
`unicode_of` 走参照 `Integer.toHexString` 的形状（不补到 6 位、负数出 32 位补码）。

```mbt check
///|
test "unicode 三件：一把尺子，三种入参形状" {
  assert_eq(@text.to_unicode("中a文"), "\\u4e2da\\u6587")
  assert_eq(@text.to_unicode_all("ab"), "\\u0061\\u0062")
  assert_eq(@text.unicode_of(0x4e2d), "\\u4e2d")
  assert_eq(@text.unicode_of(-1), "\\uffffffff") // 参照就是给 8 位 f
  assert_eq(@text.unicode_to_string("\\\\u4e2d"), "\\中") // 双反斜杠只挡住第一个：参照吃掉第二个当转义起始
}
```

`encode_blank` 只动空白位（用的就是本包那张 35 位表——整仓一张，`ini`/`typex` 共用）：

```mbt check
///|
test "encode_blank 只动空白" {
  assert_eq(@text.encode_blank(" a "), "%20a%20")
  assert_eq(@text.encode_blank("\t\n"), "%20%20")
  assert_eq(@text.encode_blank("中文"), "中文")
}
```

## 替换引擎（10-10 批①）

四条择路都有读数：长键优先且**与表序无关**、同键**后写的生效**、链是"每位置问第一个命中的"
而不是"依次全文替换"（下面那条给 `1` 而不是 `X`）、空键参照构造即抛。

```mbt check
///|
test "replacer：长键优先、链不回头扫" {
  let t = @text.lookup_replacer([("ab", "X"), ("abc", "Y")])
  assert_eq(t.replace("xaby abc"), "xXy Y")
  let chain = @text.replacer_chain([
    @text.lookup_replacer([("ab", "1")]),
    @text.lookup_replacer([("1", "X")]), // 第一件产出的 `1` 不会被第二件再换掉
  ])
  assert_eq(chain.replace("ab"), "1")
  let empty_key = try {
    let _ = @text.lookup_replacer([("", "E")])
    "未抛错"
  } catch {
    @text.EmptyKey => "EmptyKey"
    _ => "其它"
  }
  assert_eq(empty_key, "EmptyKey")
}
```

## 与 core 的分工（本页不重复的）

`pad_start` / `pad_end` / `repeat` / `has_prefix` / `contains` / `replace` / `to_upper`（ASCII 档）等 core 已有同义能力，**本包不转发**——直接在调用点用 `String::*`。完整对照见 [`docs/spec/00-hutool-map.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/00-hutool-map.md)。
