# conv

hutool `Convert` 的 **MoonBit 无反射版**：`Json` → 各目标类型的宽松转换、字符串的宽松解析腿、
`Json` 树取值腿，以及用**一等闭包**替掉的运行时转换器注册表。

完整边界矩阵与逐条读数来源见 [`docs/spec/09-conv.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/09-conv.md)。本页只放**典型用法**，
每条都带期望值——这些 `test` 块会被 `moon test` 真编译真执行。

> 状态：**契约已冻结**（10-05），10 个文档块 + 23 个用例块此刻全红是设计态。
> 期望串与 `conv_test.mbt` 同受"期望值冻结"约束：实现期只许把红变绿（门禁 G5）。

## 这一包的架构差在"没有运行时类型令牌"

hutool 的入口是 `Convert.convert(Class<T> type, Object value)`：目标类型是**运行期的值**，
`ConverterRegistry` 按 `Type` 查表，用户用 `addConverter(Type, Converter)` 注册。MoonBit 里
目标类型只能在**编译期**定（`to_int` / `to_int64` / `to_double` 各一个函数名），源值也只剩
`Json` 这一种动态树。于是：

- 注册表换成一等闭包：元素类型由调用点传进来的 `JsonConv[A]` 表达，组合用 `chain`
  （custom 先、`None` 才落内置——对位 `ConverterRegistry.convert(..., isCustomFirst=true)`，源码 `:262`）；
- **不再带进程级可变注册表**：纯计算库不该有全局状态，优先序在调用点写出来；
- `defaultValue` 形参不跟随：那是 Java 没有 `Option` 的补偿，本包失败一律 `None`，要默认值自己 `unwrap_or`。

另一处是这条腿本来就该有：core 的 `Json` 里 `Number` 变体带 `repr~ : String?`（原文数字串），
而 `Json::value` / `as_string` 等 8 条取值方法已被 core 全线标 `@deprecated`（`json.mbt:17~80`）。
本包把"官方建议的那个 `match`"收成可测出口，并且优先读 `repr`。

```mbt check
///|
test "to_str：Number 有 repr 就用原文" {
  let j = fn(s : String) -> Json {
    @json.parse(s) catch {
      _ => abort("夹具不是合法 JSON")
    }
  }
  assert_eq(@conv.to_str(j("1e5")), Some("100000"))
  assert_eq(@conv.to_str(j("9007199254740993")), Some("9007199254740993"))
  assert_eq(@conv.to_str(j("\" 123 \"")), Some(" 123 "))
  assert_eq(@conv.to_str(j("true")), Some("true"))
  assert_eq(@conv.to_str(j("null")), None)
}
```

```mbt check
///|
test "to_bool 没有第三态：未命中 TRUE_SET 就是 false" {
  let j = fn(s : String) -> Json {
    @json.parse(s) catch {
      _ => abort("夹具不是合法 JSON")
    }
  }
  assert_eq(@conv.to_bool(j("\"maybe\"")), Some(false))
  assert_eq(@conv.to_bool(j("\"Yes\"")), Some(true))
  assert_eq(@conv.to_bool(j("0")), Some(false))
  assert_eq(@conv.to_bool(j("1e309")), Some(true))
  assert_eq(@conv.to_bool(j("null")), None)
}
```

```mbt check
///|
test "parse_bool 才是三态：两条腿的分工写在名字上" {
  assert_eq(@conv.parse_bool("maybe"), None)
  assert_eq(@conv.parse_bool(" OFF "), Some(false))
  assert_eq(@conv.parse_bool("\u{00A0}1"), None)
}
```

```mbt check
///|
test "to_int64：大整数走 repr，不撞 Double 精度" {
  let j = fn(s : String) -> Json {
    @json.parse(s) catch {
      _ => abort("夹具不是合法 JSON")
    }
  }
  assert_eq(@conv.to_int64(j("9007199254740993")), Some(9007199254740993))
  assert_eq(@conv.to_int64(j("\"9007199254740993\"")), Some(9007199254740993))
  assert_eq(@conv.to_int64(j("1e5")), Some(100000))
  assert_eq(@conv.to_int64(j("1e309")), None)
}
```

```mbt check
///|
test "parse_int_loose：去尾发生在 hex 判定之前" {
  assert_eq(@conv.parse_int_loose("0x1F"), Some(1))
  assert_eq(@conv.parse_int_loose("0Xff"), Some(15))
  assert_eq(@conv.parse_int_loose(" 123 "), Some(123))
  assert_eq(@conv.parse_int_loose("123.56"), Some(123))
  assert_eq(@conv.parse_int_loose("1e5"), None)
}
```

```mbt check
///|
test "parse_int64_loose 不拒绝指数：不对称是实测读数不是笔误" {
  assert_eq(@conv.parse_int64_loose("1e5"), Some(100000))
  assert_eq(@conv.parse_int64_loose("1.2e3"), Some(1200))
  assert_eq(@conv.parse_int64_loose("5e-3"), Some(0))
  assert_eq(@conv.parse_int64_loose("9223372036854775808"), None)
}
```

```mbt check
///|
test "get_by_path：点段走键、方括号段走下标" {
  let j = fn(s : String) -> Json {
    @json.parse(s) catch {
      _ => abort("夹具不是合法 JSON")
    }
  }
  let got = fn(g : () -> Json? raise @conv.ConvError) -> String {
    try {
      match g() {
        Some(v) => "命中:" + v.stringify()
        None => "未命中"
      }
    } catch {
      @conv.BadPath(s) => "BadPath:" + s
    }
  }
  let body = j("{\"a\":{\"b\":[10,20,{\"c\":\"x\"}]},\"n\":1}")
  assert_eq(got(() => @conv.get_by_path(body, "a.b[2].c")), "命中:\"x\"")
  assert_eq(got(() => @conv.get_by_path(body, "a.b[3]")), "未命中")
  assert_eq(got(() => @conv.get_by_path(body, "a..b")), "BadPath:a..b")
}
```

```mbt check
///|
test "get_ids：批量 id 的字符串与数字两形态都收" {
  let j = fn(s : String) -> Json {
    @json.parse(s) catch {
      _ => abort("夹具不是合法 JSON")
    }
  }
  assert_eq(@conv.get_ids(j("{\"ids\":[\"1\",2,\"9007199254740993\"]}")), [
    1, 2, 9007199254740993,
  ])
  assert_eq(@conv.get_ids(j("{}")), [])
  assert_eq(@conv.get_ids(j("{\"ids\":\"1,2\"}")), [1, 2])
  assert_eq(@conv.get_ids(j("{\"ids\":[\"x\",123.456]}")), [123])
}
```

```mbt check
///|
test "to_array：坏元素跳过，不填 0 也不填 null" {
  let j = fn(s : String) -> Json {
    @json.parse(s) catch {
      _ => abort("夹具不是合法 JSON")
    }
  }
  assert_eq(
    @conv.to_array(j("[\"1\",\"x\",123.456,true,null]"), @conv.to_int64),
    [1, 123, 1],
  )
  assert_eq(@conv.to_array(j("\"1,2, 3\""), @conv.to_int64), [1, 2, 3])
  assert_eq(@conv.to_array(j("5"), @conv.to_int64), [])
}
```

```mbt check
///|
test "chain：注册用户闭包优先，转不出才落内置" {
  let j = fn(s : String) -> Json {
    @json.parse(s) catch {
      _ => abort("夹具不是合法 JSON")
    }
  }
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
}
```

## 三条不跟随，都有实测分岔为据

| 分岔 | hutool（本机 JDK 17 实跑） | 本包 |
|---|---|---|
| 越界整数 | `"2147483648"` → `-2147483648`（取低 32 位） | `None` |
| locale 分组 | `"1,234.5"` 在 zh_CN → `1234`、在 de_DE → `1`（同一条输入两个读数） | `None` |
| 布尔转字符 | `toChar(true)` → `U+0001` 控制字符 | `None` |

其余 27 条同表（`0x1p3` 十六进制浮点、`NaN`/`Infinity` 字面量、`1e309`→`Infinity`、
尾随垃圾前缀解析、下划线分隔……），逐条理由在 spec §5。

## 这些块此刻是红的

它们全是**期望值**，实现落地前必然失败——`moon test` 真收集、真跑，所以文档不会与代码各说各话。
