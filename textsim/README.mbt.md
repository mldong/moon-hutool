# moon-hutool/textsim

文本相似度，对位 hutool `cn.hutool.core.text.TextSimilarity`（契约见 [`docs/spec/20-textsim.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/20-textsim.md)）。

分母是**剥离符号后的较大长度**，分子是**最长公共子序列长度**；`similar_percent` 的舍入走
`HALF_EVEN` 且不补零（与参照侧 `NumberFormat` 同档），细节与分岔都按参照腿读数钉。


## 相似度三档直觉

```mbt check
///|
test "textsim README 相似度三档直觉" {
  // 只比字母/数字/汉字，**大小写敏感**：`ABC` 对 `abc` 一个公共字符都没有
  assert_eq(@textsim.similar("abc", "axc"), 0.6666666667) // sim.5
  assert_eq(
    @textsim.similar(
      "\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}", "\u{4e2d}\u{6587}\u{6d4b}\u{8bd5}",
    ),
    1.0,
  ) // sim.11
  assert_eq(@textsim.similar("ABC", "abc"), 0.0) // sim.7
}
```


## 剥离与分母口径

```mbt check
///|
test "textsim README 剥离与分母口径" {
  // 符号与 emoji 先整码位剥掉，分母取**剥离后**的较大长度；两侧都剥空按参照实现给 1.0
  assert_eq(@textsim.similar("a b c", "abc"), 1.0) // sim.8
  assert_eq(@textsim.remove_sign("a b c"), "abc") // rs.8.A
  assert_eq(@textsim.similar("\u{1f34e}a", "a"), 1.0) // sim.10
  assert_eq(@textsim.remove_sign("\u{1f34e}a"), "a") // rs.10.A
  assert_eq(@textsim.similar("  ", " "), 1.0) // sim.24
  assert_eq(@textsim.remove_sign("  "), "") // rs.24.A
}
```


## 百分比四档

```mbt check
///|
test "textsim README 百分比四档" {
  // 同一比值在 {0,1,2,10} 四个档位下都不补尾零（参照侧 `minimumFractionDigits` 是 0）
  assert_eq(@textsim.similar("abc", "axc"), 0.6666666667) // sim.5
  assert_eq(@textsim.similar_percent("abc", "axc", 0), "67%") // pct.5.0
  assert_eq(@textsim.similar_percent("abc", "axc", 1), "66.7%") // pct.5.1
  assert_eq(@textsim.similar_percent("abc", "axc", 2), "66.67%") // pct.5.2
  assert_eq(@textsim.similar_percent("abc", "axc", 10), "66.66666667%") // pct.5.10
  assert_eq(@textsim.similar("ABCBDAB", "BDCABA"), 0.5714285714) // sim.15
  assert_eq(@textsim.similar_percent("ABCBDAB", "BDCABA", 0), "57%") // pct.15.0
  assert_eq(@textsim.similar_percent("ABCBDAB", "BDCABA", 1), "57.1%") // pct.15.1
  assert_eq(@textsim.similar_percent("ABCBDAB", "BDCABA", 2), "57.14%") // pct.15.2
  assert_eq(@textsim.similar_percent("ABCBDAB", "BDCABA", 10), "57.14285714%") // pct.15.10
}
```


## 子序列：不连续、不对称

```mbt check
///|
test "textsim README 子序列：不连续、不对称" {
  // 结果串的字符全部来自第一侧，并列时按回溯择路取——两侧交换会给出不同的那条
  assert_eq(
    @textsim.similar(
      "\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}", "\u{7528}\u{6237}\u{767b}\u{9646}\u{6210}\u{529f}",
    ),
    0.8333333333,
  ) // sim.22
  assert_eq(
    @textsim.longest_common_subsequence(
      "\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}", "\u{7528}\u{6237}\u{767b}\u{9646}\u{6210}\u{529f}",
    ),
    "\u{7528}\u{6237}\u{767b}\u{6210}\u{529f}",
  ) // lcsu.22
  assert_eq(
    @textsim.longest_common_subsequence(
      "\u{7528}\u{6237}\u{767b}\u{9646}\u{6210}\u{529f}", "\u{7528}\u{6237}\u{767b}\u{5f55}\u{6210}\u{529f}",
    ),
    "\u{7528}\u{6237}\u{767b}\u{6210}\u{529f}",
  ) // lcsu.rev.22
  assert_eq(@textsim.similar("ABCBDAB", "BDCABA"), 0.5714285714) // sim.15
  assert_eq(@textsim.longest_common_subsequence("ABCBDAB", "BDCABA"), "BDAB") // lcsu.15
  assert_eq(@textsim.longest_common_subsequence("BDCABA", "ABCBDAB"), "BCBA") // lcsu.rev.15
}
```

