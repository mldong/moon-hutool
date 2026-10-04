# text

hutool `StrUtil` / `CharSequenceUtil` 的 MoonBit 对位：空白判定、切分连接、子串截取、`{}` 占位、版本比较、脱敏掩码、命名法互转。

契约与边界矩阵见 [`docs/spec/01-text.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/01-text.md)。本页只放**典型用法**，每条都带期望值——这些 `test` 块会被 `moon test` 真编译真执行（抄 `moonbitlang/core/encoding/base64/README.mbt.md` 的机制），所以文档本身就是要通过的检查，不是装饰。

> 状态：**已实现**（10-04）。本页 10 个示例块由 `moon test` 真跑，text 侧共 23 条用例全绿（`wasm`/`js`/`wasm-gc` 三档读数一致）。
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

## 与 core 的分工（本页不重复的）

`pad_start` / `pad_end` / `repeat` / `has_prefix` / `contains` / `replace` / `to_upper`（ASCII 档）等 core 已有同义能力，**本包不转发**——直接在调用点用 `String::*`。完整对照见 [`docs/spec/00-hutool-map.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/00-hutool-map.md)。
