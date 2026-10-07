///|
// moon-hutool/typex —— 港澳台 10 位族的「中段夹字母」档（§19.5 第一条欠账的补档，10-07）
//
// 第五批原本那条标签写作「中段夹字母」的夹具**实际长度是 9**（腿工装切片差一位），
// 所以它打到的是长度闸而不是 `Integer.parseInt`——两案在这一档的可观测差别（参照抛 / 本库判假）
// 当时没有读数支撑。这一笔按 §19.5 写在原地的路径补齐：给腿 `Temp/convsrc/HkTwLeg.java`
// 补一条**长度 10、中段夹字母**的样本重跑（读数在 `hktw_rows2.tsv`），再按补档通道加断言。
// 三条断言的期望值一律来自腿读数：两条 `false`、一条 `null` 都是腿上的字面值，不手打。

///|
test "中段夹字母（10 位）：参照抛 NumberFormatException，本库无错误面判假；isValidCard10 两侧同判 null" {
  // 先钉住"原来那条其实是长度档"：9 位串在参照那侧给的就是 false
  assert_eq(@typex.idcard_is_valid_tw_card("A1B34567"), false) // TW_EDGE_midLetter9|A1B34567
  // 真·10 位中段夹字母。腿现读：`ERR NumberFormatException:For input string: "B"`
  // ——参照走 `Integer.parseInt` 直接抛；本库三件都不设错误面（第五批的公开面形状，§19.1），
  // 这类串一律判假。**这是分岔不是同判**：观测到的出口不同（抛 vs 假），假这一侧由本库自订形状给出
  assert_eq(@typex.idcard_is_valid_tw_card("A1B3456789"), false) // TW_EDGE_midLetter10|A1B3456789（参照抛，见上）
  // 上面那条例子单独用**打不死变异**：把夹进来的字母"当 0 算"之后校验位照样对得上，
  // 出口仍是 false ⇒ 与正确实现同判（T8 第一轮就是这么报 0 红的）。所以再补两条**判别样本**：
  // 被替换的那位「数字 × 权重」正好是 10 的倍数（4×5=20、5×4=20），"当 0 算"会让加权和少掉一个
  // 10 的倍数、从而把校验位算成 true——只有这两条能证明断言真走到了 parseInt 那一步。
  // 两条的腿读数同为 `ERR NumberFormatException:For input string: "B"` ⇒ 本库同档判假。
  assert_eq(@typex.idcard_is_valid_tw_card("A123B56789"), false) // TW_EDGE_midLetterB4|A123B56789（参照抛）
  assert_eq(@typex.idcard_is_valid_tw_card("A1234B6789"), false) // TW_EDGE_midLetterB5|A1234B6789（参照抛）
  // 同一串走 #23.111：腿给 `null`（`isValidCard10` 自己的文法闸先挡住，根本走不到 parseInt），
  // 本库出 `None` ⇒ 这一档两侧同判，不是分岔
  assert_eq(tx10_tag(@typex.idcard_info_10("A1B3456789")), "null") // CARD10_midLetter10|A1B3456789
}
