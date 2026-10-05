///|
// dfa 第一批的期望值全部由生成脚本从 `dfa_ref.txt`（参照腿读数）灌入，手打零条。
// 参照腿：`hutool-dfa-5.8.35.jar`（**独立 artifact，hutool-core 的 jar 里没有 `cn/hutool/dfa`**）
// + 本机 JDK 17.0.14 跑 `WordTree`；`javac -encoding UTF-8` 编译（digest 轮那条编码教训，本轮开局就带上）。
// 这批全部**预期红**（签名是骨架、函数体 `abort`）——PR-B 只许把红变绿，不许动期望值（门禁 G5）。
// **位置口径 = UTF-16 码元下标**（与参照腿同读、与 `re` 包同一条）；含 emoji 的两条夹具就是这条口径的证据（spec §5 第 2 行）。

///|
// 语义四档：density × greed 的实测组合
test "dfa 语义四档：density × greed 的实测组合" {
  // doc-density：words="ab,b" density=True greed=False limit=-1
  let t = @dfa.new_word_tree(["ab", "b"])
  let r = t.match_all_words_mode("abab", -1, true, false)
  assert_eq(r.length(), 4)
  assert_eq(r[0].word, "ab")
  assert_eq(r[0].found, "ab")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 1)
  assert_eq(r[1].word, "b")
  assert_eq(r[1].found, "b")
  assert_eq(r[1].start, 1)
  assert_eq(r[1].end, 1)
  assert_eq(r[2].word, "ab")
  assert_eq(r[2].found, "ab")
  assert_eq(r[2].start, 2)
  assert_eq(r[2].end, 3)
  assert_eq(r[3].word, "b")
  assert_eq(r[3].found, "b")
  assert_eq(r[3].start, 3)
  assert_eq(r[3].end, 3)
  // doc-greed：words="a,ab" density=False greed=True limit=-1
  let t = @dfa.new_word_tree(["a", "ab"])
  let r = t.match_all_words_mode("ab", -1, false, true)
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "a")
  assert_eq(r[0].found, "a")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 0)
  // base-ab-b：words="ab,b" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["ab", "b"])
  let r = t.match_all_words_mode("abab", -1, false, false)
  assert_eq(r.length(), 2)
  assert_eq(r[0].word, "ab")
  assert_eq(r[0].found, "ab")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 1)
  assert_eq(r[1].word, "ab")
  assert_eq(r[1].found, "ab")
  assert_eq(r[1].start, 2)
  assert_eq(r[1].end, 3)
  // both-ab-b：words="ab,b" density=True greed=True limit=-1
  let t = @dfa.new_word_tree(["ab", "b"])
  let r = t.match_all_words_mode("abab", -1, true, true)
  assert_eq(r.length(), 4)
  assert_eq(r[0].word, "ab")
  assert_eq(r[0].found, "ab")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 1)
  assert_eq(r[1].word, "b")
  assert_eq(r[1].found, "b")
  assert_eq(r[1].start, 1)
  assert_eq(r[1].end, 1)
  assert_eq(r[2].word, "ab")
  assert_eq(r[2].found, "ab")
  assert_eq(r[2].start, 2)
  assert_eq(r[2].end, 3)
  assert_eq(r[3].word, "b")
  assert_eq(r[3].found, "b")
  assert_eq(r[3].start, 3)
  assert_eq(r[3].end, 3)
  // nested-abc：words="abc,ab,a" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["abc", "ab", "a"])
  let r = t.match_all_words_mode("abcabc", -1, false, false)
  assert_eq(r.length(), 2)
  assert_eq(r[0].word, "a")
  assert_eq(r[0].found, "a")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 0)
  assert_eq(r[1].word, "a")
  assert_eq(r[1].found, "a")
  assert_eq(r[1].start, 3)
  assert_eq(r[1].end, 3)
  // nested-abc-den：words="abc,ab,a" density=True greed=False limit=-1
  let t = @dfa.new_word_tree(["abc", "ab", "a"])
  let r = t.match_all_words_mode("abcabc", -1, true, false)
  assert_eq(r.length(), 2)
  assert_eq(r[0].word, "a")
  assert_eq(r[0].found, "a")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 0)
  assert_eq(r[1].word, "a")
  assert_eq(r[1].found, "a")
  assert_eq(r[1].start, 3)
  assert_eq(r[1].end, 3)
  // nested-abc-gre：words="abc,ab,a" density=False greed=True limit=-1
  let t = @dfa.new_word_tree(["abc", "ab", "a"])
  let r = t.match_all_words_mode("abcabc", -1, false, true)
  assert_eq(r.length(), 2)
  assert_eq(r[0].word, "a")
  assert_eq(r[0].found, "a")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 0)
  assert_eq(r[1].word, "a")
  assert_eq(r[1].found, "a")
  assert_eq(r[1].start, 3)
  assert_eq(r[1].end, 3)
  // nested-abc-both：words="abc,ab,a" density=True greed=True limit=-1
  let t = @dfa.new_word_tree(["abc", "ab", "a"])
  let r = t.match_all_words_mode("abcabc", -1, true, true)
  assert_eq(r.length(), 6)
  assert_eq(r[0].word, "a")
  assert_eq(r[0].found, "a")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 0)
  assert_eq(r[1].word, "ab")
  assert_eq(r[1].found, "ab")
  assert_eq(r[1].start, 0)
  assert_eq(r[1].end, 1)
  assert_eq(r[2].word, "abc")
  assert_eq(r[2].found, "abc")
  assert_eq(r[2].start, 0)
  assert_eq(r[2].end, 2)
  assert_eq(r[3].word, "a")
  assert_eq(r[3].found, "a")
  assert_eq(r[3].start, 3)
  assert_eq(r[3].end, 3)
  assert_eq(r[4].word, "ab")
  assert_eq(r[4].found, "ab")
  assert_eq(r[4].start, 3)
  assert_eq(r[4].end, 4)
  assert_eq(r[5].word, "abc")
  assert_eq(r[5].found, "abc")
  assert_eq(r[5].start, 3)
  assert_eq(r[5].end, 5)
  // greed-no-den：words="a,ab,abc" density=False greed=True limit=-1
  let t = @dfa.new_word_tree(["a", "ab", "abc"])
  let r = t.match_all_words_mode("abc", -1, false, true)
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "a")
  assert_eq(r[0].found, "a")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 0)
  // den-no-gre：words="a,ab,abc" density=True greed=False limit=-1
  let t = @dfa.new_word_tree(["a", "ab", "abc"])
  let r = t.match_all_words_mode("abc", -1, true, false)
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "a")
  assert_eq(r[0].found, "a")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 0)
  // den-and-gre：words="a,ab,abc" density=True greed=True limit=-1
  let t = @dfa.new_word_tree(["a", "ab", "abc"])
  let r = t.match_all_words_mode("abc", -1, true, true)
  assert_eq(r.length(), 3)
  assert_eq(r[0].word, "a")
  assert_eq(r[0].found, "a")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 0)
  assert_eq(r[1].word, "ab")
  assert_eq(r[1].found, "ab")
  assert_eq(r[1].start, 0)
  assert_eq(r[1].end, 1)
  assert_eq(r[2].word, "abc")
  assert_eq(r[2].found, "abc")
  assert_eq(r[2].start, 0)
  assert_eq(r[2].end, 2)
}

///|
// 停顿字符：词中随 found 返回、词首跳过、词尾不算结束
test "dfa 停顿字符：词中随 found 返回、词首跳过、词尾不算结束" {
  // stop-mid：words="\u7ea2\u9886\u5dfe" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["\u7ea2\u9886\u5dfe"])
  let r = t.match_all_words_mode(
    "\u7ea2\u3001\u9886\u5dfe a\u7ea2\u3002\u9886\u5dfe", -1, false, false,
  )
  assert_eq(r.length(), 2)
  assert_eq(r[0].word, "\u7ea2\u9886\u5dfe")
  assert_eq(r[0].found, "\u7ea2\u3001\u9886\u5dfe")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 3)
  assert_eq(r[1].word, "\u7ea2\u9886\u5dfe")
  assert_eq(r[1].found, "\u7ea2\u3002\u9886\u5dfe")
  assert_eq(r[1].start, 6)
  assert_eq(r[1].end, 9)
  // stop-mid-both：words="\u7ea2\u9886\u5dfe" density=True greed=True limit=-1
  let t = @dfa.new_word_tree(["\u7ea2\u9886\u5dfe"])
  let r = t.match_all_words_mode("\u7ea2\u3001\u9886\u5dfe", -1, true, true)
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "\u7ea2\u9886\u5dfe")
  assert_eq(r[0].found, "\u7ea2\u3001\u9886\u5dfe")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 3)
  // stop-lead：words="\u7ea2\u9886\u5dfe" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["\u7ea2\u9886\u5dfe"])
  let r = t.match_all_words_mode("\u3001\u7ea2\u9886\u5dfe", -1, false, false)
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "\u7ea2\u9886\u5dfe")
  assert_eq(r[0].found, "\u7ea2\u9886\u5dfe")
  assert_eq(r[0].start, 1)
  assert_eq(r[0].end, 3)
  // stop-two：words="\u7ea2\u9886\u5dfe" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["\u7ea2\u9886\u5dfe"])
  let r = t.match_all_words_mode(
    "\u7ea2\u3001\u3001\u9886\u5dfe", -1, false, false,
  )
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "\u7ea2\u9886\u5dfe")
  assert_eq(r[0].found, "\u7ea2\u3001\u3001\u9886\u5dfe")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 4)
  // stop-tail-noend：words="\u7ea2\u9886\u5dfe" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["\u7ea2\u9886\u5dfe"])
  let r = t.match_all_words_mode("\u7ea2\u9886\u5dfe\u3001", -1, false, false)
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "\u7ea2\u9886\u5dfe")
  assert_eq(r[0].found, "\u7ea2\u9886\u5dfe")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 2)
  // word-vs-found：words="\u7ea2\u9886\u5dfe" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["\u7ea2\u9886\u5dfe"])
  let r = t.match_all_words_mode(
    "x\u7ea2\u3002\u3001\u9886\u5dfe y", -1, false, false,
  )
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "\u7ea2\u9886\u5dfe")
  assert_eq(r[0].found, "\u7ea2\u3002\u3001\u9886\u5dfe")
  assert_eq(r[0].start, 1)
  assert_eq(r[0].end, 5)
}

///|
// limit 档：只有 >0 才生效
test "dfa limit 档：只有 >0 才生效" {
  // limit-1：words="ab,b" density=True greed=True limit=1
  let t = @dfa.new_word_tree(["ab", "b"])
  let r = t.match_all_words_mode("abab", 1, true, true)
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "ab")
  assert_eq(r[0].found, "ab")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 1)
  // limit-2：words="ab,b" density=True greed=True limit=2
  let t = @dfa.new_word_tree(["ab", "b"])
  let r = t.match_all_words_mode("abab", 2, true, true)
  assert_eq(r.length(), 2)
  assert_eq(r[0].word, "ab")
  assert_eq(r[0].found, "ab")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 1)
  assert_eq(r[1].word, "b")
  assert_eq(r[1].found, "b")
  assert_eq(r[1].start, 1)
  assert_eq(r[1].end, 1)
  // limit-0：words="ab,b" density=True greed=True limit=0
  let t = @dfa.new_word_tree(["ab", "b"])
  let r = t.match_all_words_mode("abab", 0, true, true)
  assert_eq(r.length(), 4)
  assert_eq(r[0].word, "ab")
  assert_eq(r[0].found, "ab")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 1)
  assert_eq(r[1].word, "b")
  assert_eq(r[1].found, "b")
  assert_eq(r[1].start, 1)
  assert_eq(r[1].end, 1)
  assert_eq(r[2].word, "ab")
  assert_eq(r[2].found, "ab")
  assert_eq(r[2].start, 2)
  assert_eq(r[2].end, 3)
  assert_eq(r[3].word, "b")
  assert_eq(r[3].found, "b")
  assert_eq(r[3].start, 3)
  assert_eq(r[3].end, 3)
  // limit-neg2：words="ab,b" density=True greed=True limit=-2
  let t = @dfa.new_word_tree(["ab", "b"])
  let r = t.match_all_words_mode("abab", -2, true, true)
  assert_eq(r.length(), 4)
  assert_eq(r[0].word, "ab")
  assert_eq(r[0].found, "ab")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 1)
  assert_eq(r[1].word, "b")
  assert_eq(r[1].found, "b")
  assert_eq(r[1].start, 1)
  assert_eq(r[1].end, 1)
  assert_eq(r[2].word, "ab")
  assert_eq(r[2].found, "ab")
  assert_eq(r[2].start, 2)
  assert_eq(r[2].end, 3)
  assert_eq(r[3].word, "b")
  assert_eq(r[3].found, "b")
  assert_eq(r[3].start, 3)
  assert_eq(r[3].end, 3)
}

///|
// 退化输入：空词/全停顿词/空文本/重复词/前缀不成词/非关键词打断/中文
test "dfa 退化输入：空词/全停顿词/空文本/重复词/前缀不成词/非关键词打断/中文" {
  // empty-word：words=",ab" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["", "ab"])
  let r = t.match_all_words_mode("ab", -1, false, false)
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "ab")
  assert_eq(r[0].found, "ab")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 1)
  // allstop-word：words="\u3001\u3002" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["\u3001\u3002"])
  let r = t.match_all_words_mode("\u3001\u3002ab", -1, false, false)
  assert_eq(r.length(), 0)
  // empty-text：words="ab" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["ab"])
  let r = t.match_all_words_mode("", -1, false, false)
  assert_eq(r.length(), 0)
  // dup-word：words="ab,ab" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["ab", "ab"])
  let r = t.match_all_words_mode("abab", -1, false, false)
  assert_eq(r.length(), 2)
  assert_eq(r[0].word, "ab")
  assert_eq(r[0].found, "ab")
  assert_eq(r[0].start, 0)
  assert_eq(r[0].end, 1)
  assert_eq(r[1].word, "ab")
  assert_eq(r[1].found, "ab")
  assert_eq(r[1].start, 2)
  assert_eq(r[1].end, 3)
  // prefix-only：words="abcd" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["abcd"])
  let r = t.match_all_words_mode("abc", -1, false, false)
  assert_eq(r.length(), 0)
  // break-x：words="abcd" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["abcd"])
  let r = t.match_all_words_mode("abxd cdabcd", -1, false, false)
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "abcd")
  assert_eq(r[0].found, "abcd")
  assert_eq(r[0].start, 7)
  assert_eq(r[0].end, 10)
  // cn：words="\u7ea2\u9886\u5dfe,\u5fd7\u613f\u8005" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["\u7ea2\u9886\u5dfe", "\u5fd7\u613f\u8005"])
  let r = t.match_all_words_mode(
    "\u6211\u662f\u7ea2\u9886\u5dfe\uff0c\u4e5f\u662f\u5fd7\u613f\u8005\u3002", -1,
    false, false,
  )
  assert_eq(r.length(), 2)
  assert_eq(r[0].word, "\u7ea2\u9886\u5dfe")
  assert_eq(r[0].found, "\u7ea2\u9886\u5dfe")
  assert_eq(r[0].start, 2)
  assert_eq(r[0].end, 4)
  assert_eq(r[1].word, "\u5fd7\u613f\u8005")
  assert_eq(r[1].found, "\u5fd7\u613f\u8005")
  assert_eq(r[1].start, 8)
  assert_eq(r[1].end, 10)
}

///|
// 非 BMP：位置按 UTF-16 码元给，两侧同读（emoji 占两个码元）
test "dfa 非 BMP：位置按 UTF-16 码元给，两侧同读（emoji 占两个码元）" {
  // surrogate：words="ab" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["ab"])
  let r = t.match_all_words_mode("\u{1f600}ab", -1, false, false)
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "ab")
  assert_eq(r[0].found, "ab")
  assert_eq(r[0].start, 2)
  assert_eq(r[0].end, 3)
  // surrogate-stop：words="\u7ea2\u9886\u5dfe" density=False greed=False limit=-1
  let t = @dfa.new_word_tree(["\u7ea2\u9886\u5dfe"])
  let r = t.match_all_words_mode(
    "\u{1f600}\u7ea2\u3001\u9886\u5dfe", -1, false, false,
  )
  assert_eq(r.length(), 1)
  assert_eq(r[0].word, "\u7ea2\u9886\u5dfe")
  assert_eq(r[0].found, "\u7ea2\u3001\u9886\u5dfe")
  assert_eq(r[0].start, 2)
  assert_eq(r[0].end, 5)
}

///|
// 停顿字符表的规模读数（参照腿反射 `StopChar.STOP_WORD` + 全 BMP 扫 `isStopChar`）：
// `STOP_WORD` 去重后 303 个码位；`isStopChar` 为真的 BMP 码位共 327 个（多出来的那部分是
// `Character.isWhitespace` 那一半：U+0009\u2009\u2028\u2029\u205f\u3000 等）。
// 逐位不钉进用例——钉 327 位等于把表抄第二遍；改成**扫全 BMP 计数 + 六条边界点**，
// 表里加一位少一位都会让计数或边界翻脸（表本身由生成脚本从参照腿灌进 dfa/stop_chars.mbt）。
// 码点扫描跳过 0xd800\u{dfff} 代理位——参照腿按 UTF-16 码元扫时它们恒假，不影响计数。
test "dfa 停顿字符表规模" {
  let mut n = 0
  for cp in 0..<=65536 {
    if cp >= 0xd800 && cp <= 0xdfff {
      continue
    }
    if @dfa.is_stop_char(cp.unsafe_to_char()) {
      n += 1
    }
  }
  assert_eq(n, 327)
  assert_eq(@dfa.is_stop_char(' '), true)
  assert_eq(@dfa.is_stop_char('\t'), true)
  assert_eq(@dfa.is_stop_char('\u3001'), true)
  assert_eq(@dfa.is_stop_char('\u3000'), true)
  assert_eq(@dfa.is_stop_char('\u205f'), true)
  assert_eq(@dfa.is_stop_char('中'), false)
  assert_eq(@dfa.is_stop_char('a'), false)
  assert_eq(@dfa.is_not_stop_char('\u4e00'), true)
}
