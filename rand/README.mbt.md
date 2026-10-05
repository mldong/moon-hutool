# rand

hutool `RandomUtil` / `WeightRandom` 的 **MoonBit 对位·第一批**：19 件取样与判定，随机源一律显式注入。

完整边界矩阵与逐条读数来源见 [`docs/spec/12-rand.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/12-rand.md)。本页只放**典型用法**，
每条都带期望值——这些 `test` 块会被 `moon test` 真编译真执行。

> 状态：**已实现**（10-05 两笔：契约 `5f5097f`、落地见 `docs/ROADMAP.md` 第 12 行）。文档块与 `rand_test.mbt` 同受
> “期望值冻结”约束（门禁 G5）；`wasm`/`js`/`wasm-gc` 三档读数一致，native 档由 CI 出证。

## 这一包钉得住的东西只有四类

参照实现（实测 `javap`）55 个 `public static` **没有一个收 `Random` 参数**，结果序列不可复现。
所以本包的期望值全是“对任意随机流都成立”的东西：单点定义域、长度、字符集包含、错误档。

```mbt check
///|
test "四张字符表是数据，不需要随机源" {
  assert_eq(@rand.alphabet_number(), "0123456789")
  assert_eq(@rand.alphabet_lower().length(), 26)
  assert_eq(@rand.alphabet_lower_number().length(), 36)
  // 全表 62 字符且大写在前——所以 random_string_upper 的结果集是 36 而不是 26
  assert_eq(@rand.alphabet_all().length(), 62)
}
```

```mbt check
///|
test "界值：默认 [min, max)，四组合各有单点档" {
  let r = @random.Rand::chacha8(seed=b"01234567890123456789012345678901")
  assert_eq(@rand.random_int(r, 0, 1), 0)
  assert_eq(@rand.random_int(r, 0, 1, incl_min=false, incl_max=true), 1)
  assert_eq(@rand.random_int(r, 0, 2, incl_min=false, incl_max=false), 1)
  let err = try {
    let _ = @rand.random_int(r, 1, 1)
    "未抛错"
  } catch {
    _ => "抛错"
  }
  assert_eq(err, "抛错")
}
```

```mbt check
///|
test "字符串族：长度与字符集是契约，具体字符不是" {
  let r = @random.Rand::chacha8(seed=b"01234567890123456789012345678901")
  assert_eq(@rand.random_string(r, 0), "")
  assert_eq(@rand.random_string(r, 24).length(), 24)
  assert_eq(@rand.random_numbers(r, 12).length(), 12)
  // 参照实现实测 randomString(0) 给长度 1 的串；本包判给空串（spec §5 第 1 行）
  assert_eq(@rand.random_string_from(r, "ab", 8).length(), 8)
}
```

```mbt check
///|
test "取样：limit 是前 N 个，去重档互不相同、超界报错" {
  let r = @random.Rand::chacha8(seed=b"01234567890123456789012345678901")
  let items = ["a", "b", "c"]
  assert_eq(@rand.random_ele(r, items, limit=1), "a")
  assert_eq(@rand.random_eles(r, items, 5).length(), 5)
  assert_eq(@rand.random_ele_set(r, items, 3).length(), 3)
  let err = try {
    let _ = @rand.random_ele_set(r, items, 4)
    "未抛错"
  } catch {
    _ => "抛错"
  }
  assert_eq(err, "抛错")
}
```

```mbt check
///|
test "加权：零权重的项永不中选；构造不校验、错误留到 next" {
  let r = @random.Rand::chacha8(seed=b"01234567890123456789012345678901")
  let w = @rand.weight_random([("x", 1.0), ("y", 0.0)])
  let mut saw_y = 0
  let mut k = 0
  while k < 200 {
    if @rand.weight_random_next(w, r) == "y" {
      saw_y += 1
    }
    k += 1
  }
  assert_eq(saw_y, 0)
}
```

## 这一包不做什么

| 不做 | 为什么 |
|---|---|
| secure / pseudo 双通道 | 参照实现有 `getSecureRandom()`/`getSecureRandomStrong()`/`getSHA1PRNGRandom(seed)` 三条；core 只有一条 chacha8 流，且实测 `Rand::new()` 在拿不到平台熵时**静默回落到固定种子** ⇒ 承诺“安全”没有凭据 |
| 全局随机源、库内取熵 | 每一件都收 `@random.Rand`；要可复现就注入脚本化 `Source`（core 的 `Source` 是 `pub(open)` trait） |
| `getRandom()` 一类“供应生成器”的件 | 本包的生成器是**入参**不是出货件 |
| `randomChinese()` | 要引 CJK 码表；本库把码表独立成数据件（同 `num` 的区划码表判例） |
| `randomDay` / `randomDate` | 参照实现读墙钟（`DateUtil`），与本库“时间一律显式传参”冲突，界值要先想办法进签名 |
| `random_float` / `random_double` / `randomBigDecimal`、`randomBytes` | 第二批；`BigDecimal` 那一档还压着 `num` 的“完整十进制算术不做”口径 |
