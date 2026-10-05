# moon-hutool/dfa

关键词树（DFA 转移）与停顿字符谓词，对位 hutool **`hutool-dfa`** 模块的 `WordTree` + `StopChar`。
契约：[`docs/spec/14-dfa.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/14-dfa.md)。

一句话定位：**给一棵词树和一段文本，告诉你哪儿命中了哪个词**。树是值、显式传参，
库里没有任何全局表（参照实现那张 `SensitiveUtil` 静态表不在对位面内）。

## 建树与查询

```mbt check
///|
test "dfa 建树与默认档" {
  let t = @dfa.new_word_tree(["ab", "b"])
  assert_eq(@dfa.WordTree::is_match(t, "xxabxx"), true)
  // 默认档 = 最左起点取最短、命中后整段跳过
  assert_eq(@dfa.WordTree::match_all(t, "abab"), ["ab", "ab"])
  assert_eq(@dfa.WordTree::first_match(t, "xxbaxx"), Some("b"))
}
```

`new_word_tree` 会**跳过空串与整词都是停顿字符的词**（`["", "、。", "ab"]` 与 `["ab"]` 等价），
重复词按首次出现去重。

## 命中带位置，且 `word` 与 `found` 是两个形状

词表里的词是"剥掉停顿字符"的那一串，文本里实际匹配到的串**原样带着中间的停顿字符**：

```mbt check
///|
test "dfa 停顿字符留在 found 里" {
  let t = @dfa.new_word_tree(["红领巾"])
  let r = @dfa.WordTree::match_all_words(t, "红、领巾 a红。领巾")
  assert_eq(r.length(), 2)
  assert_eq(r[0].word, "红领巾")
  assert_eq(r[0].found, "红、领巾")
  // 位置口径是 UTF-16 码元下标，闭区间
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 3)
  assert_eq(@dfa.WordTree::match_all(t, "、红领巾"), ["红领巾"])
}
```

词首的停顿字符被整格跳过（起点因此后移），词尾的停顿字符不参与那条命中。

## 三档语义：`density` 与 `greed`

```mbt check
///|
test "dfa 三档语义" {
  let t = @dfa.new_word_tree(["a", "ab", "abc"])
  // 默认档：同起点取最短，命中后整段跳过
  assert_eq(
    @dfa.WordTree::match_all_words_mode(t, "abc", -1, false, false).length(),
    1,
  )
  // density=true + greed=true：同起点由短到长全出
  let ladder = @dfa.WordTree::match_all_words_mode(t, "abc", -1, true, true)
  assert_eq(ladder.map(fn(f) { f.word }), ["a", "ab", "abc"])
  // greed 在 density=false 时完全惰性——与默认档逐条同读
  assert_eq(
    @dfa.WordTree::match_all_words_mode(t, "abc", -1, false, true).map(fn(f) {
      f.word
    }),
    ["a"],
  )
  // limit 只有 > 0 才生效；0 与负数都是不限
  assert_eq(
    @dfa.WordTree::match_all_words_mode(t, "abc", 0, true, true).length(),
    3,
  )
}
```

## 停顿字符谓词

`is_stop_char` 是参照实现 `StopChar.isStopChar` 的全 BMP 对位（标点表 ∪ 空白表，共 327 个码位）。
注意 **U+2007 与 U+202F 不在表里**——它们属于 Java 的另一个谓词 `isSpaceChar`。

```mbt check
///|
test "dfa 停顿字符" {
  assert_eq(@dfa.is_stop_char(' '), true)
  assert_eq(@dfa.is_stop_char('\t'), true)
  assert_eq(@dfa.is_stop_char('、'), true)
  assert_eq(@dfa.is_stop_char('中'), false)
  assert_eq(@dfa.is_not_stop_char('a'), true)
}
```

## 本包不做的事

不做全局敏感词表（参照实现的 `SensitiveUtil.init` 那一套静态单例，以及靠反射取字段的
`containsSensitive(Object)`）；不做流式/增量匹配（树建好就只读，要换词表请重造一棵）；
不提供 `clear`（重造即可）；密集档不承诺性能——参照实现最坏是 `O(n²)` 重扫，本库同形状，
Aho-Corasick 属于另一个算法族，要做会另立包并另取读数腿。
