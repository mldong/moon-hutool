///|
/// 字母区间表的自证：**扫全 BMP**，把表判出来的字母集与参照腿的三条全域读数逐条对撞
/// （契约 `docs/spec/05-codec.md` 的表那一节）。表与谓词都是私有的，所以这一份是白盒件。
///
/// 三条都是守恒判据，缺一就不是同判：
/// - 条数与全域码元数（`LR|count`）——少了会漏字母，多了会把标点算进来；
/// - 码位和 mod 2147483647（`LR|sum-mod`）——同数不同位的替换（把 A 段挪成 B 段）抓得住；
/// - 按 0x1000 分块的 16 个计数（`LR|blocks`）——全域量撞不出来的**局部挪动**抓得住。
///
/// 生产者指纹 17.0.14|vendor=Oracle Corporation；换 JDK 大版本这三条就可能挪，届时重跑腿再重出本件，别手改期望值。
test "codec 字母表与参照 isLetter 逐码元同判（BMP 全域三条读数）" {
  let mut total = 0
  let mut sum : Int64 = 0L
  let block_counts : Array[Int32] = []
  for b in 0..<=15 {
    let mut n = 0
    for i in 0..<=0xfff {
      let c = (b << 12) | i
      if is_letter_unit(c) {
        n += 1
        total += 1
        sum = (sum + c.to_int64()) % 2147483647L
      }
    }
    block_counts.push(n)
  }
  assert_eq(total, 48909) // 读数腿  LR|count
  assert_eq(sum, 1536313765L) // 读数腿  LR|sum-mod
  assert_eq(block_counts[0], 2263) // 读数腿  LR|blocks 第 0 块
  assert_eq(block_counts[1], 3071) // 读数腿  LR|blocks 第 1 块
  assert_eq(block_counts[2], 473) // 读数腿  LR|blocks 第 2 块
  assert_eq(block_counts[3], 3449) // 读数腿  LR|blocks 第 3 块
  assert_eq(block_counts[4], 4032) // 读数腿  LR|blocks 第 4 块
  assert_eq(block_counts[5], 4096) // 读数腿  LR|blocks 第 5 块
  assert_eq(block_counts[6], 4096) // 读数腿  LR|blocks 第 6 块
  assert_eq(block_counts[7], 4096) // 读数腿  LR|blocks 第 7 块
  assert_eq(block_counts[8], 4096) // 读数腿  LR|blocks 第 8 块
  assert_eq(block_counts[9], 4093) // 读数腿  LR|blocks 第 9 块
  assert_eq(block_counts[10], 3503) // 读数腿  LR|blocks 第 10 块
  assert_eq(block_counts[11], 4096) // 读数腿  LR|blocks 第 11 块
  assert_eq(block_counts[12], 4096) // 读数腿  LR|blocks 第 12 块
  assert_eq(block_counts[13], 2028) // 读数腿  LR|blocks 第 13 块
  assert_eq(block_counts[14], 0) // 读数腿  LR|blocks 第 14 块
  assert_eq(block_counts[15], 1421) // 读数腿  LR|blocks 第 15 块
  // 没读到的块也要显式钉 0，否则分块判据是残缺的
}

///|
/// 六个跨界码位（区间端点的开闭各钉一刀）+ 代理区四档。
test "codec 字母表的边界点与代理码元档" {
  assert_eq(is_letter_unit(65), true) // 读数腿  LR|edge 65=1
  assert_eq(is_letter_unit(90), true) // 读数腿  LR|edge 90=1
  assert_eq(is_letter_unit(91), false) // 读数腿  LR|edge 91=0
  assert_eq(is_letter_unit(97), true) // 读数腿  LR|edge 97=1
  assert_eq(is_letter_unit(122), true) // 读数腿  LR|edge 122=1
  assert_eq(is_letter_unit(123), false) // 读数腿  LR|edge 123=0
  assert_eq(is_letter_unit(170), true) // 读数腿  LR|edge 170=1
  assert_eq(is_letter_unit(171), false) // 读数腿  LR|edge 171=0
  assert_eq(is_letter_unit(28), false) // 读数腿  LR|edge 28=0
  assert_eq(is_letter_unit(29), false) // 读数腿  LR|edge 29=0
  assert_eq(is_letter_unit(748), true) // 读数腿  LR|edge 748=1
  assert_eq(is_letter_unit(749), false) // 读数腿  LR|edge 749=0
  // 代理码位两侧都不算字母 ⇒ 逐码元摊时代理对整体也不参与移位
  assert_eq(is_letter_unit(55357), false) // 读数腿  LR|surrogate 55357=0
  assert_eq(is_letter_unit(56832), false) // 读数腿  LR|surrogate 56832=0
  assert_eq(is_letter_unit(55295), false) // 读数腿  LR|surrogate 55295=0
  assert_eq(is_letter_unit(57344), false) // 读数腿  LR|surrogate 57344=0
}
