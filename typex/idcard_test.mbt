///|
// typex 第三批 C（IdcardUtil）的期望值全部由生成脚本从参照腿灌入（手打零条）。
// 腿：真 hutool-core-5.8.35.jar + JDK 17.0.14；省码表由反射读 `CITY_CODES` 键集，
// 有效码由参照自己的 `isValidCard18` 判定穷举造出（hits 全为 1）；个别「生日被拒」的样本用反射 private
// `getCheckCode18` 取正确校验位——这样「年份那一判」才有单变量夹具（随便挑的校验位会让两种实现同答 false）。
// 年份实参一律取腿执行当年 2026：跨年行为不外推，见 docs/spec/23-typex.md §13.3 第 4 条。

///|
test "Idcard \u{5341}\u{516b}\u{4f4d}\u{6821}\u{9a8c}\u{ff08}\u{7701}\u{7801}\u{95f8} + \u{751f}\u{65e5}\u{95f8} + \u{6821}\u{9a8c}\u{4f4d}\u{ff09}" {
  assert_eq(@typex.idcard_is_valid_18("110101196503125230", 2026), true) // IS_VALID_18|110101196503125230
  assert_eq(@typex.idcard_is_valid_18("140203196503125242", 2026), true) // IS_VALID_18|140203196503125242
  assert_eq(@typex.idcard_is_valid_18("311101196503125239", 2026), true) // IS_VALID_18|311101196503125239
  assert_eq(@typex.idcard_is_valid_18("810101196503125244", 2026), true) // IS_VALID_18|810101196503125244
  assert_eq(@typex.idcard_is_valid_18("820101196503125238", 2026), true) // IS_VALID_18|820101196503125238
  assert_eq(@typex.idcard_is_valid_18("830101196503125248", 2026), true) // IS_VALID_18|830101196503125248
  assert_eq(@typex.idcard_is_valid_18("91010119650312523X", 2026), false) // IS_VALID_18|91010119650312523X
  assert_eq(@typex.idcard_is_valid_18("110101196402295230", 2026), true) // IS_VALID_18|110101196402295230
  assert_eq(@typex.idcard_is_valid_18("110101200002295214", 2026), true) // IS_VALID_18|110101200002295214
  assert_eq(@typex.idcard_is_valid_18("110101202512315237", 2026), true) // IS_VALID_18|110101202512315237
  assert_eq(@typex.idcard_is_valid_18("110101202601015236", 2026), true) // IS_VALID_18|110101202601015236
  assert_eq(@typex.idcard_is_valid_18("110101202612315234", 2026), true) // IS_VALID_18|110101202612315234
  assert_eq(@typex.idcard_is_valid_18("110101202701015233", 2026), false) // IS_VALID_18|110101202701015233
  assert_eq(@typex.idcard_is_valid_18("110101203106155236", 2026), false) // IS_VALID_18|110101203106155236
  assert_eq(@typex.idcard_is_valid_18("911010198802030151", 2026), true) // IS_VALID_18|911010198802030151
  assert_eq(@typex.idcard_is_valid_18("110101650312523", 2026), false) // IS_VALID_18|110101650312523
  assert_eq(@typex.idcard_is_valid_18("310101800101123", 2026), false) // IS_VALID_18|310101800101123
  assert_eq(@typex.idcard_is_valid_18("440301990101001", 2026), false) // IS_VALID_18|440301990101001
  assert_eq(@typex.idcard_is_valid_18("110101000101001", 2026), false) // IS_VALID_18|110101000101001
  assert_eq(@typex.idcard_is_valid_18("110101990101001", 2026), false) // IS_VALID_18|110101990101001
  assert_eq(@typex.idcard_is_valid_18("110101460101001", 2026), false) // IS_VALID_18|110101460101001
  assert_eq(@typex.idcard_is_valid_18("110101450101001", 2026), false) // IS_VALID_18|110101450101001
  assert_eq(@typex.idcard_is_valid_18("110101010101001", 2026), false) // IS_VALID_18|110101010101001
  assert_eq(@typex.idcard_is_valid_18("810000650312523", 2026), false) // IS_VALID_18|810000650312523
  assert_eq(@typex.idcard_is_valid_18("110101020101001", 2026), false) // IS_VALID_18|110101020101001
  assert_eq(@typex.idcard_is_valid_18("110101030101001", 2026), false) // IS_VALID_18|110101030101001
  assert_eq(@typex.idcard_is_valid_18("110101040101001", 2026), false) // IS_VALID_18|110101040101001
  assert_eq(@typex.idcard_is_valid_18("110101050101001", 2026), false) // IS_VALID_18|110101050101001
  assert_eq(@typex.idcard_is_valid_18("110101060101001", 2026), false) // IS_VALID_18|110101060101001
  assert_eq(@typex.idcard_is_valid_18("110101070101001", 2026), false) // IS_VALID_18|110101070101001
  assert_eq(@typex.idcard_is_valid_18("110101080101001", 2026), false) // IS_VALID_18|110101080101001
  assert_eq(@typex.idcard_is_valid_18("110101090101001", 2026), false) // IS_VALID_18|110101090101001
  assert_eq(@typex.idcard_is_valid_18("110101100101001", 2026), false) // IS_VALID_18|110101100101001
  assert_eq(@typex.idcard_is_valid_18("110101110101001", 2026), false) // IS_VALID_18|110101110101001
  assert_eq(@typex.idcard_is_valid_18("110101120101001", 2026), false) // IS_VALID_18|110101120101001
  assert_eq(@typex.idcard_is_valid_18("110101130101001", 2026), false) // IS_VALID_18|110101130101001
  assert_eq(@typex.idcard_is_valid_18("110101140101001", 2026), false) // IS_VALID_18|110101140101001
  assert_eq(@typex.idcard_is_valid_18("110101150101001", 2026), false) // IS_VALID_18|110101150101001
  assert_eq(@typex.idcard_is_valid_18("110101160101001", 2026), false) // IS_VALID_18|110101160101001
  assert_eq(@typex.idcard_is_valid_18("110101170101001", 2026), false) // IS_VALID_18|110101170101001
  assert_eq(@typex.idcard_is_valid_18("110101180101001", 2026), false) // IS_VALID_18|110101180101001
  assert_eq(@typex.idcard_is_valid_18("110101190101001", 2026), false) // IS_VALID_18|110101190101001
  assert_eq(@typex.idcard_is_valid_18("110101200101001", 2026), false) // IS_VALID_18|110101200101001
  assert_eq(@typex.idcard_is_valid_18("110101210101001", 2026), false) // IS_VALID_18|110101210101001
  assert_eq(@typex.idcard_is_valid_18("110101220101001", 2026), false) // IS_VALID_18|110101220101001
  assert_eq(@typex.idcard_is_valid_18("110101230101001", 2026), false) // IS_VALID_18|110101230101001
  assert_eq(@typex.idcard_is_valid_18("110101240101001", 2026), false) // IS_VALID_18|110101240101001
  assert_eq(@typex.idcard_is_valid_18("110101250101001", 2026), false) // IS_VALID_18|110101250101001
  assert_eq(@typex.idcard_is_valid_18("110101260101001", 2026), false) // IS_VALID_18|110101260101001
  assert_eq(@typex.idcard_is_valid_18("110101270101001", 2026), false) // IS_VALID_18|110101270101001
  assert_eq(@typex.idcard_is_valid_18("110101280101001", 2026), false) // IS_VALID_18|110101280101001
  assert_eq(@typex.idcard_is_valid_18("110101290101001", 2026), false) // IS_VALID_18|110101290101001
  assert_eq(@typex.idcard_is_valid_18("110101300101001", 2026), false) // IS_VALID_18|110101300101001
  assert_eq(@typex.idcard_is_valid_18("110101310101001", 2026), false) // IS_VALID_18|110101310101001
  assert_eq(@typex.idcard_is_valid_18("110101320101001", 2026), false) // IS_VALID_18|110101320101001
  assert_eq(@typex.idcard_is_valid_18("110101330101001", 2026), false) // IS_VALID_18|110101330101001
  assert_eq(@typex.idcard_is_valid_18("110101340101001", 2026), false) // IS_VALID_18|110101340101001
  assert_eq(@typex.idcard_is_valid_18("110101350101001", 2026), false) // IS_VALID_18|110101350101001
  assert_eq(@typex.idcard_is_valid_18("110101360101001", 2026), false) // IS_VALID_18|110101360101001
  assert_eq(@typex.idcard_is_valid_18("110101370101001", 2026), false) // IS_VALID_18|110101370101001
  assert_eq(@typex.idcard_is_valid_18("110101380101001", 2026), false) // IS_VALID_18|110101380101001
  assert_eq(@typex.idcard_is_valid_18("110101390101001", 2026), false) // IS_VALID_18|110101390101001
  assert_eq(@typex.idcard_is_valid_18("110101400101001", 2026), false) // IS_VALID_18|110101400101001
  assert_eq(@typex.idcard_is_valid_18("110101410101001", 2026), false) // IS_VALID_18|110101410101001
  assert_eq(@typex.idcard_is_valid_18("110101420101001", 2026), false) // IS_VALID_18|110101420101001
  assert_eq(@typex.idcard_is_valid_18("110101430101001", 2026), false) // IS_VALID_18|110101430101001
  assert_eq(@typex.idcard_is_valid_18("110101440101001", 2026), false) // IS_VALID_18|110101440101001
  assert_eq(@typex.idcard_is_valid_18("110101470101001", 2026), false) // IS_VALID_18|110101470101001
  assert_eq(@typex.idcard_is_valid_18("110101480101001", 2026), false) // IS_VALID_18|110101480101001
  assert_eq(@typex.idcard_is_valid_18("110101490101001", 2026), false) // IS_VALID_18|110101490101001
  assert_eq(@typex.idcard_is_valid_18("110101500101001", 2026), false) // IS_VALID_18|110101500101001
  assert_eq(@typex.idcard_is_valid_18("110101510101001", 2026), false) // IS_VALID_18|110101510101001
  assert_eq(@typex.idcard_is_valid_18("110101520101001", 2026), false) // IS_VALID_18|110101520101001
  assert_eq(@typex.idcard_is_valid_18("110101530101001", 2026), false) // IS_VALID_18|110101530101001
  assert_eq(@typex.idcard_is_valid_18("110101540101001", 2026), false) // IS_VALID_18|110101540101001
  assert_eq(@typex.idcard_is_valid_18("110101550101001", 2026), false) // IS_VALID_18|110101550101001
  assert_eq(@typex.idcard_is_valid_18("110101560101001", 2026), false) // IS_VALID_18|110101560101001
  assert_eq(@typex.idcard_is_valid_18("110101570101001", 2026), false) // IS_VALID_18|110101570101001
  assert_eq(@typex.idcard_is_valid_18("110101580101001", 2026), false) // IS_VALID_18|110101580101001
  assert_eq(@typex.idcard_is_valid_18("110101590101001", 2026), false) // IS_VALID_18|110101590101001
  assert_eq(@typex.idcard_is_valid_18("110101600101001", 2026), false) // IS_VALID_18|110101600101001
  assert_eq(@typex.idcard_is_valid_18("110101610101001", 2026), false) // IS_VALID_18|110101610101001
  assert_eq(@typex.idcard_is_valid_18("110101620101001", 2026), false) // IS_VALID_18|110101620101001
  assert_eq(@typex.idcard_is_valid_18("110101630101001", 2026), false) // IS_VALID_18|110101630101001
  assert_eq(@typex.idcard_is_valid_18("110101640101001", 2026), false) // IS_VALID_18|110101640101001
  assert_eq(@typex.idcard_is_valid_18("110101650101001", 2026), false) // IS_VALID_18|110101650101001
  assert_eq(@typex.idcard_is_valid_18("110101660101001", 2026), false) // IS_VALID_18|110101660101001
  assert_eq(@typex.idcard_is_valid_18("110101670101001", 2026), false) // IS_VALID_18|110101670101001
  assert_eq(@typex.idcard_is_valid_18("110101680101001", 2026), false) // IS_VALID_18|110101680101001
  assert_eq(@typex.idcard_is_valid_18("110101690101001", 2026), false) // IS_VALID_18|110101690101001
  assert_eq(@typex.idcard_is_valid_18("110101700101001", 2026), false) // IS_VALID_18|110101700101001
  assert_eq(@typex.idcard_is_valid_18("110101710101001", 2026), false) // IS_VALID_18|110101710101001
  assert_eq(@typex.idcard_is_valid_18("110101720101001", 2026), false) // IS_VALID_18|110101720101001
  assert_eq(@typex.idcard_is_valid_18("110101730101001", 2026), false) // IS_VALID_18|110101730101001
  assert_eq(@typex.idcard_is_valid_18("110101740101001", 2026), false) // IS_VALID_18|110101740101001
  assert_eq(@typex.idcard_is_valid_18("110101750101001", 2026), false) // IS_VALID_18|110101750101001
  assert_eq(@typex.idcard_is_valid_18("110101760101001", 2026), false) // IS_VALID_18|110101760101001
  assert_eq(@typex.idcard_is_valid_18("110101770101001", 2026), false) // IS_VALID_18|110101770101001
  assert_eq(@typex.idcard_is_valid_18("110101780101001", 2026), false) // IS_VALID_18|110101780101001
  assert_eq(@typex.idcard_is_valid_18("110101790101001", 2026), false) // IS_VALID_18|110101790101001
  assert_eq(@typex.idcard_is_valid_18("110101800101001", 2026), false) // IS_VALID_18|110101800101001
  assert_eq(@typex.idcard_is_valid_18("110101810101001", 2026), false) // IS_VALID_18|110101810101001
  assert_eq(@typex.idcard_is_valid_18("110101820101001", 2026), false) // IS_VALID_18|110101820101001
  assert_eq(@typex.idcard_is_valid_18("110101830101001", 2026), false) // IS_VALID_18|110101830101001
  assert_eq(@typex.idcard_is_valid_18("110101840101001", 2026), false) // IS_VALID_18|110101840101001
  assert_eq(@typex.idcard_is_valid_18("110101850101001", 2026), false) // IS_VALID_18|110101850101001
  assert_eq(@typex.idcard_is_valid_18("110101860101001", 2026), false) // IS_VALID_18|110101860101001
  assert_eq(@typex.idcard_is_valid_18("110101870101001", 2026), false) // IS_VALID_18|110101870101001
  assert_eq(@typex.idcard_is_valid_18("110101880101001", 2026), false) // IS_VALID_18|110101880101001
  assert_eq(@typex.idcard_is_valid_18("110101890101001", 2026), false) // IS_VALID_18|110101890101001
  assert_eq(@typex.idcard_is_valid_18("110101900101001", 2026), false) // IS_VALID_18|110101900101001
  assert_eq(@typex.idcard_is_valid_18("110101910101001", 2026), false) // IS_VALID_18|110101910101001
  assert_eq(@typex.idcard_is_valid_18("110101920101001", 2026), false) // IS_VALID_18|110101920101001
  assert_eq(@typex.idcard_is_valid_18("110101930101001", 2026), false) // IS_VALID_18|110101930101001
  assert_eq(@typex.idcard_is_valid_18("110101940101001", 2026), false) // IS_VALID_18|110101940101001
  assert_eq(@typex.idcard_is_valid_18("110101950101001", 2026), false) // IS_VALID_18|110101950101001
  assert_eq(@typex.idcard_is_valid_18("110101960101001", 2026), false) // IS_VALID_18|110101960101001
  assert_eq(@typex.idcard_is_valid_18("110101970101001", 2026), false) // IS_VALID_18|110101970101001
  assert_eq(@typex.idcard_is_valid_18("110101980101001", 2026), false) // IS_VALID_18|110101980101001
  assert_eq(@typex.idcard_is_valid_18("110101196503125235", 2026), false) // IS_VALID_18|110101196503125235
  assert_eq(@typex.idcard_is_valid_18("11010119650312523X", 2026), false) // IS_VALID_18|11010119650312523X
  assert_eq(@typex.idcard_is_valid_18("1101011965031252 4", 2026), false) // IS_VALID_18|1101011965031252 4
  assert_eq(@typex.idcard_is_valid_18("110101196513125234", 2026), false) // IS_VALID_18|110101196513125234
  assert_eq(@typex.idcard_is_valid_18("110101196502315234", 2026), false) // IS_VALID_18|110101196502315234
  assert_eq(@typex.idcard_is_valid_18("110101196502295234", 2026), false) // IS_VALID_18|110101196502295234
  assert_eq(@typex.idcard_is_valid_18("110101196504315234", 2026), false) // IS_VALID_18|110101196504315234
  assert_eq(@typex.idcard_is_valid_18("110101196500125234", 2026), false) // IS_VALID_18|110101196500125234
  assert_eq(@typex.idcard_is_valid_18("110101196513015234", 2026), false) // IS_VALID_18|110101196513015234
  assert_eq(@typex.idcard_is_valid_18("1101011965031252", 2026), false) // IS_VALID_18|1101011965031252
  assert_eq(@typex.idcard_is_valid_18("1101011965031252344", 2026), false) // IS_VALID_18|1101011965031252344
  assert_eq(@typex.idcard_is_valid_18("110101196503125234X", 2026), false) // IS_VALID_18|110101196503125234X
  assert_eq(@typex.idcard_is_valid_18("99010119650312523X", 2026), false) // IS_VALID_18|99010119650312523X
  assert_eq(@typex.idcard_is_valid_18("000000000000000000", 2026), false) // IS_VALID_18|000000000000000000
  assert_eq(@typex.idcard_is_valid_18("999999999999999999", 2026), false) // IS_VALID_18|999999999999999999
  assert_eq(@typex.idcard_is_valid_18("11010119650312523A", 2026), false) // IS_VALID_18|11010119650312523A
  assert_eq(@typex.idcard_is_valid_18("11010165031252X", 2026), false) // IS_VALID_18|11010165031252X
  assert_eq(@typex.idcard_is_valid_18("11010165031252a", 2026), false) // IS_VALID_18|11010165031252a
  assert_eq(@typex.idcard_is_valid_18("11010165031252", 2026), false) // IS_VALID_18|11010165031252
  assert_eq(@typex.idcard_is_valid_18("1101016503125234", 2026), false) // IS_VALID_18|1101016503125234
  assert_eq(@typex.idcard_is_valid_18("", 2026), false) // IS_VALID_18|
  assert_eq(@typex.idcard_is_valid_18(" ", 2026), false) // IS_VALID_18| 
  assert_eq(@typex.idcard_is_valid_18("\t", 2026), false) // IS_VALID_18|	
  assert_eq(@typex.idcard_is_valid_18("1101011965031252x", 2026), false) // IS_VALID_18|1101011965031252x
  assert_eq(@typex.idcard_is_valid_18("81000019650312523X", 2026), false) // IS_VALID_18|81000019650312523X
  assert_eq(@typex.idcard_is_valid_18("820000196503125235", 2026), false) // IS_VALID_18|820000196503125235
  assert_eq(@typex.idcard_is_valid_18("830000196503125234", 2026), false) // IS_VALID_18|830000196503125234
  assert_eq(@typex.idcard_is_valid_18("710000196503125233", 2026), false) // IS_VALID_18|710000196503125233
  assert_eq(@typex.idcard_is_valid_18("910000196503125232", 2026), false) // IS_VALID_18|910000196503125232
  assert_eq(@typex.idcard_is_valid_18("11010119650312000X", 2026), true) // IS_VALID_18|11010119650312000X
  assert_eq(@typex.idcard_is_valid_18("11010119650312000x", 2026), true) // IS_VALID_18|11010119650312000x
  assert_eq(@typex.idcard_is_valid_18("110101190002295234", 2026), false) // IS_VALID_18|110101190002295234
  assert_eq(@typex.idcard_is_valid_18("110101196602295235", 2026), false) // IS_VALID_18|110101196602295235
  assert_eq(@typex.idcard_is_valid_18("110101199602295239", 2026), true) // IS_VALID_18|110101199602295239
  assert_eq(@typex.idcard_is_valid_18("110101190002285239", 2026), true) // IS_VALID_18|110101190002285239
  assert_eq(@typex.idcard_is_valid_18("110101196506315232", 2026), false) // IS_VALID_18|110101196506315232
  assert_eq(@typex.idcard_is_valid_18("110101196507315234", 2026), true) // IS_VALID_18|110101196507315234
  assert_eq(@typex.idcard_is_valid_18("110101196504315239", 2026), false) // IS_VALID_18|110101196504315239
  assert_eq(@typex.idcard_is_valid_18("110101196513015238", 2026), false) // IS_VALID_18|110101196513015238
  assert_eq(@typex.idcard_is_valid_18("110101196500125235", 2026), false) // IS_VALID_18|110101196500125235
  assert_eq(@typex.idcard_is_valid_18("110101196512325234", 2026), false) // IS_VALID_18|110101196512325234
  assert_eq(@typex.idcard_is_valid_18("210101196503125230", 2026), false) // IS_VALID_18|210101196503125230
  assert_eq(@typex.idcard_is_valid_18("120101196503125230", 2026), false) // IS_VALID_18|120101196503125230
  assert_eq(@typex.idcard_is_valid_18("111101196503125230", 2026), false) // IS_VALID_18|111101196503125230
  assert_eq(@typex.idcard_is_valid_18("110201196503125230", 2026), false) // IS_VALID_18|110201196503125230
  assert_eq(@typex.idcard_is_valid_18("110111196503125230", 2026), false) // IS_VALID_18|110111196503125230
  assert_eq(@typex.idcard_is_valid_18("110102196503125230", 2026), false) // IS_VALID_18|110102196503125230
  assert_eq(@typex.idcard_is_valid_18("110101296503125230", 2026), false) // IS_VALID_18|110101296503125230
  assert_eq(@typex.idcard_is_valid_18("1101011X6503125230", 2026), false) // IS_VALID_18|1101011X6503125230
  assert_eq(@typex.idcard_is_valid_18("110101197503125230", 2026), false) // IS_VALID_18|110101197503125230
  assert_eq(@typex.idcard_is_valid_18("110101196603125230", 2026), false) // IS_VALID_18|110101196603125230
  assert_eq(@typex.idcard_is_valid_18("110101196513125230", 2026), false) // IS_VALID_18|110101196513125230
  assert_eq(@typex.idcard_is_valid_18("110101196504125230", 2026), false) // IS_VALID_18|110101196504125230
  assert_eq(@typex.idcard_is_valid_18("110101196503225230", 2026), false) // IS_VALID_18|110101196503225230
  assert_eq(@typex.idcard_is_valid_18("110101196503135230", 2026), false) // IS_VALID_18|110101196503135230
  assert_eq(@typex.idcard_is_valid_18("110101196503126230", 2026), false) // IS_VALID_18|110101196503126230
  assert_eq(@typex.idcard_is_valid_18("110101196503125330", 2026), false) // IS_VALID_18|110101196503125330
  assert_eq(@typex.idcard_is_valid_18("110101196503125240", 2026), false) // IS_VALID_18|110101196503125240
  assert_eq(@typex.idcard_is_valid_18("110101196503125231", 2026), false) // IS_VALID_18|110101196503125231
  assert_eq(@typex.idcard_is_valid_18("240203196503125242", 2026), false) // IS_VALID_18|240203196503125242
  assert_eq(@typex.idcard_is_valid_18("150203196503125242", 2026), false) // IS_VALID_18|150203196503125242
  assert_eq(@typex.idcard_is_valid_18("141203196503125242", 2026), false) // IS_VALID_18|141203196503125242
  assert_eq(@typex.idcard_is_valid_18("140303196503125242", 2026), false) // IS_VALID_18|140303196503125242
  assert_eq(@typex.idcard_is_valid_18("140213196503125242", 2026), false) // IS_VALID_18|140213196503125242
  assert_eq(@typex.idcard_is_valid_18("140204196503125242", 2026), false) // IS_VALID_18|140204196503125242
  assert_eq(@typex.idcard_is_valid_18("140203296503125242", 2026), false) // IS_VALID_18|140203296503125242
  assert_eq(@typex.idcard_is_valid_18("1402031X6503125242", 2026), false) // IS_VALID_18|1402031X6503125242
  assert_eq(@typex.idcard_is_valid_18("140203197503125242", 2026), false) // IS_VALID_18|140203197503125242
  assert_eq(@typex.idcard_is_valid_18("140203196603125242", 2026), false) // IS_VALID_18|140203196603125242
  assert_eq(@typex.idcard_is_valid_18("140203196513125242", 2026), false) // IS_VALID_18|140203196513125242
  assert_eq(@typex.idcard_is_valid_18("140203196504125242", 2026), false) // IS_VALID_18|140203196504125242
  assert_eq(@typex.idcard_is_valid_18("140203196503225242", 2026), false) // IS_VALID_18|140203196503225242
  assert_eq(@typex.idcard_is_valid_18("140203196503135242", 2026), false) // IS_VALID_18|140203196503135242
  assert_eq(@typex.idcard_is_valid_18("140203196503126242", 2026), false) // IS_VALID_18|140203196503126242
  assert_eq(@typex.idcard_is_valid_18("140203196503125342", 2026), false) // IS_VALID_18|140203196503125342
  assert_eq(@typex.idcard_is_valid_18("140203196503125252", 2026), false) // IS_VALID_18|140203196503125252
  assert_eq(@typex.idcard_is_valid_18("140203196503125243", 2026), false) // IS_VALID_18|140203196503125243
}

///|
test "Idcard \u{5341}\u{516b}\u{4f4d}\u{6821}\u{9a8c}\u{7684}\u{4e25}\u{683c}\u{5927}\u{5c0f}\u{5199}\u{6863}" {
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196503125230", 2026, false),
    true,
  ) // IS_VALID_18_CS|110101196503125230
  assert_eq(
    @typex.idcard_is_valid_18_case("140203196503125242", 2026, false),
    true,
  ) // IS_VALID_18_CS|140203196503125242
  assert_eq(
    @typex.idcard_is_valid_18_case("311101196503125239", 2026, false),
    true,
  ) // IS_VALID_18_CS|311101196503125239
  assert_eq(
    @typex.idcard_is_valid_18_case("810101196503125244", 2026, false),
    true,
  ) // IS_VALID_18_CS|810101196503125244
  assert_eq(
    @typex.idcard_is_valid_18_case("820101196503125238", 2026, false),
    true,
  ) // IS_VALID_18_CS|820101196503125238
  assert_eq(
    @typex.idcard_is_valid_18_case("830101196503125248", 2026, false),
    true,
  ) // IS_VALID_18_CS|830101196503125248
  assert_eq(
    @typex.idcard_is_valid_18_case("91010119650312523X", 2026, false),
    false,
  ) // IS_VALID_18_CS|91010119650312523X
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196402295230", 2026, false),
    true,
  ) // IS_VALID_18_CS|110101196402295230
  assert_eq(
    @typex.idcard_is_valid_18_case("110101200002295214", 2026, false),
    true,
  ) // IS_VALID_18_CS|110101200002295214
  assert_eq(
    @typex.idcard_is_valid_18_case("110101202512315237", 2026, false),
    true,
  ) // IS_VALID_18_CS|110101202512315237
  assert_eq(
    @typex.idcard_is_valid_18_case("110101202601015236", 2026, false),
    true,
  ) // IS_VALID_18_CS|110101202601015236
  assert_eq(
    @typex.idcard_is_valid_18_case("110101202612315234", 2026, false),
    true,
  ) // IS_VALID_18_CS|110101202612315234
  assert_eq(
    @typex.idcard_is_valid_18_case("110101202701015233", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101202701015233
  assert_eq(
    @typex.idcard_is_valid_18_case("110101203106155236", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101203106155236
  assert_eq(
    @typex.idcard_is_valid_18_case("911010198802030151", 2026, false),
    true,
  ) // IS_VALID_18_CS|911010198802030151
  assert_eq(
    @typex.idcard_is_valid_18_case("110101650312523", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101650312523
  assert_eq(
    @typex.idcard_is_valid_18_case("310101800101123", 2026, false),
    false,
  ) // IS_VALID_18_CS|310101800101123
  assert_eq(
    @typex.idcard_is_valid_18_case("440301990101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|440301990101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101000101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101000101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101990101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101990101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101460101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101460101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101450101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101450101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101010101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101010101001
  assert_eq(
    @typex.idcard_is_valid_18_case("810000650312523", 2026, false),
    false,
  ) // IS_VALID_18_CS|810000650312523
  assert_eq(
    @typex.idcard_is_valid_18_case("110101020101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101020101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101030101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101030101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101040101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101040101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101050101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101050101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101060101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101060101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101070101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101070101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101080101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101080101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101090101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101090101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101100101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101100101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101110101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101110101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101120101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101120101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101130101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101130101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101140101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101140101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101150101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101150101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101160101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101160101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101170101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101170101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101180101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101180101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101190101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101190101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101200101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101200101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101210101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101210101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101220101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101220101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101230101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101230101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101240101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101240101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101250101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101250101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101260101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101260101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101270101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101270101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101280101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101280101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101290101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101290101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101300101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101300101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101310101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101310101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101320101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101320101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101330101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101330101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101340101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101340101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101350101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101350101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101360101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101360101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101370101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101370101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101380101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101380101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101390101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101390101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101400101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101400101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101410101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101410101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101420101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101420101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101430101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101430101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101440101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101440101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101470101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101470101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101480101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101480101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101490101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101490101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101500101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101500101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101510101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101510101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101520101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101520101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101530101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101530101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101540101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101540101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101550101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101550101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101560101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101560101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101570101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101570101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101580101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101580101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101590101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101590101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101600101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101600101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101610101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101610101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101620101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101620101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101630101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101630101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101640101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101640101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101650101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101650101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101660101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101660101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101670101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101670101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101680101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101680101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101690101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101690101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101700101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101700101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101710101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101710101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101720101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101720101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101730101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101730101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101740101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101740101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101750101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101750101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101760101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101760101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101770101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101770101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101780101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101780101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101790101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101790101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101800101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101800101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101810101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101810101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101820101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101820101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101830101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101830101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101840101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101840101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101850101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101850101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101860101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101860101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101870101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101870101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101880101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101880101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101890101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101890101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101900101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101900101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101910101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101910101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101920101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101920101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101930101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101930101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101940101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101940101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101950101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101950101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101960101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101960101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101970101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101970101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101980101001", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101980101001
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196503125235", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196503125235
  assert_eq(
    @typex.idcard_is_valid_18_case("11010119650312523X", 2026, false),
    false,
  ) // IS_VALID_18_CS|11010119650312523X
  assert_eq(
    @typex.idcard_is_valid_18_case("1101011965031252 4", 2026, false),
    false,
  ) // IS_VALID_18_CS|1101011965031252 4
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196513125234", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196513125234
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196502315234", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196502315234
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196502295234", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196502295234
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196504315234", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196504315234
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196500125234", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196500125234
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196513015234", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196513015234
  assert_eq(
    @typex.idcard_is_valid_18_case("1101011965031252", 2026, false),
    false,
  ) // IS_VALID_18_CS|1101011965031252
  assert_eq(
    @typex.idcard_is_valid_18_case("1101011965031252344", 2026, false),
    false,
  ) // IS_VALID_18_CS|1101011965031252344
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196503125234X", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196503125234X
  assert_eq(
    @typex.idcard_is_valid_18_case("99010119650312523X", 2026, false),
    false,
  ) // IS_VALID_18_CS|99010119650312523X
  assert_eq(
    @typex.idcard_is_valid_18_case("000000000000000000", 2026, false),
    false,
  ) // IS_VALID_18_CS|000000000000000000
  assert_eq(
    @typex.idcard_is_valid_18_case("999999999999999999", 2026, false),
    false,
  ) // IS_VALID_18_CS|999999999999999999
  assert_eq(
    @typex.idcard_is_valid_18_case("11010119650312523A", 2026, false),
    false,
  ) // IS_VALID_18_CS|11010119650312523A
  assert_eq(
    @typex.idcard_is_valid_18_case("11010165031252X", 2026, false),
    false,
  ) // IS_VALID_18_CS|11010165031252X
  assert_eq(
    @typex.idcard_is_valid_18_case("11010165031252a", 2026, false),
    false,
  ) // IS_VALID_18_CS|11010165031252a
  assert_eq(
    @typex.idcard_is_valid_18_case("11010165031252", 2026, false),
    false,
  ) // IS_VALID_18_CS|11010165031252
  assert_eq(
    @typex.idcard_is_valid_18_case("1101016503125234", 2026, false),
    false,
  ) // IS_VALID_18_CS|1101016503125234
  assert_eq(@typex.idcard_is_valid_18_case("", 2026, false), false) // IS_VALID_18_CS|
  assert_eq(@typex.idcard_is_valid_18_case(" ", 2026, false), false) // IS_VALID_18_CS| 
  assert_eq(@typex.idcard_is_valid_18_case("\t", 2026, false), false) // IS_VALID_18_CS|	
  assert_eq(
    @typex.idcard_is_valid_18_case("1101011965031252x", 2026, false),
    false,
  ) // IS_VALID_18_CS|1101011965031252x
  assert_eq(
    @typex.idcard_is_valid_18_case("81000019650312523X", 2026, false),
    false,
  ) // IS_VALID_18_CS|81000019650312523X
  assert_eq(
    @typex.idcard_is_valid_18_case("820000196503125235", 2026, false),
    false,
  ) // IS_VALID_18_CS|820000196503125235
  assert_eq(
    @typex.idcard_is_valid_18_case("830000196503125234", 2026, false),
    false,
  ) // IS_VALID_18_CS|830000196503125234
  assert_eq(
    @typex.idcard_is_valid_18_case("710000196503125233", 2026, false),
    false,
  ) // IS_VALID_18_CS|710000196503125233
  assert_eq(
    @typex.idcard_is_valid_18_case("910000196503125232", 2026, false),
    false,
  ) // IS_VALID_18_CS|910000196503125232
  assert_eq(
    @typex.idcard_is_valid_18_case("11010119650312000X", 2026, false),
    true,
  ) // IS_VALID_18_CS|11010119650312000X
  assert_eq(
    @typex.idcard_is_valid_18_case("11010119650312000x", 2026, false),
    false,
  ) // IS_VALID_18_CS|11010119650312000x
  assert_eq(
    @typex.idcard_is_valid_18_case("110101190002295234", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101190002295234
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196602295235", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196602295235
  assert_eq(
    @typex.idcard_is_valid_18_case("110101199602295239", 2026, false),
    true,
  ) // IS_VALID_18_CS|110101199602295239
  assert_eq(
    @typex.idcard_is_valid_18_case("110101190002285239", 2026, false),
    true,
  ) // IS_VALID_18_CS|110101190002285239
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196506315232", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196506315232
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196507315234", 2026, false),
    true,
  ) // IS_VALID_18_CS|110101196507315234
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196504315239", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196504315239
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196513015238", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196513015238
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196500125235", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196500125235
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196512325234", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196512325234
  assert_eq(
    @typex.idcard_is_valid_18_case("210101196503125230", 2026, false),
    false,
  ) // IS_VALID_18_CS|210101196503125230
  assert_eq(
    @typex.idcard_is_valid_18_case("120101196503125230", 2026, false),
    false,
  ) // IS_VALID_18_CS|120101196503125230
  assert_eq(
    @typex.idcard_is_valid_18_case("111101196503125230", 2026, false),
    false,
  ) // IS_VALID_18_CS|111101196503125230
  assert_eq(
    @typex.idcard_is_valid_18_case("110201196503125230", 2026, false),
    false,
  ) // IS_VALID_18_CS|110201196503125230
  assert_eq(
    @typex.idcard_is_valid_18_case("110111196503125230", 2026, false),
    false,
  ) // IS_VALID_18_CS|110111196503125230
  assert_eq(
    @typex.idcard_is_valid_18_case("110102196503125230", 2026, false),
    false,
  ) // IS_VALID_18_CS|110102196503125230
  assert_eq(
    @typex.idcard_is_valid_18_case("110101296503125230", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101296503125230
  assert_eq(
    @typex.idcard_is_valid_18_case("1101011X6503125230", 2026, false),
    false,
  ) // IS_VALID_18_CS|1101011X6503125230
  assert_eq(
    @typex.idcard_is_valid_18_case("110101197503125230", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101197503125230
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196603125230", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196603125230
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196513125230", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196513125230
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196504125230", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196504125230
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196503225230", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196503225230
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196503135230", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196503135230
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196503126230", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196503126230
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196503125330", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196503125330
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196503125240", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196503125240
  assert_eq(
    @typex.idcard_is_valid_18_case("110101196503125231", 2026, false),
    false,
  ) // IS_VALID_18_CS|110101196503125231
  assert_eq(
    @typex.idcard_is_valid_18_case("240203196503125242", 2026, false),
    false,
  ) // IS_VALID_18_CS|240203196503125242
  assert_eq(
    @typex.idcard_is_valid_18_case("150203196503125242", 2026, false),
    false,
  ) // IS_VALID_18_CS|150203196503125242
  assert_eq(
    @typex.idcard_is_valid_18_case("141203196503125242", 2026, false),
    false,
  ) // IS_VALID_18_CS|141203196503125242
  assert_eq(
    @typex.idcard_is_valid_18_case("140303196503125242", 2026, false),
    false,
  ) // IS_VALID_18_CS|140303196503125242
  assert_eq(
    @typex.idcard_is_valid_18_case("140213196503125242", 2026, false),
    false,
  ) // IS_VALID_18_CS|140213196503125242
  assert_eq(
    @typex.idcard_is_valid_18_case("140204196503125242", 2026, false),
    false,
  ) // IS_VALID_18_CS|140204196503125242
  assert_eq(
    @typex.idcard_is_valid_18_case("140203296503125242", 2026, false),
    false,
  ) // IS_VALID_18_CS|140203296503125242
  assert_eq(
    @typex.idcard_is_valid_18_case("1402031X6503125242", 2026, false),
    false,
  ) // IS_VALID_18_CS|1402031X6503125242
  assert_eq(
    @typex.idcard_is_valid_18_case("140203197503125242", 2026, false),
    false,
  ) // IS_VALID_18_CS|140203197503125242
  assert_eq(
    @typex.idcard_is_valid_18_case("140203196603125242", 2026, false),
    false,
  ) // IS_VALID_18_CS|140203196603125242
  assert_eq(
    @typex.idcard_is_valid_18_case("140203196513125242", 2026, false),
    false,
  ) // IS_VALID_18_CS|140203196513125242
  assert_eq(
    @typex.idcard_is_valid_18_case("140203196504125242", 2026, false),
    false,
  ) // IS_VALID_18_CS|140203196504125242
  assert_eq(
    @typex.idcard_is_valid_18_case("140203196503225242", 2026, false),
    false,
  ) // IS_VALID_18_CS|140203196503225242
  assert_eq(
    @typex.idcard_is_valid_18_case("140203196503135242", 2026, false),
    false,
  ) // IS_VALID_18_CS|140203196503135242
  assert_eq(
    @typex.idcard_is_valid_18_case("140203196503126242", 2026, false),
    false,
  ) // IS_VALID_18_CS|140203196503126242
  assert_eq(
    @typex.idcard_is_valid_18_case("140203196503125342", 2026, false),
    false,
  ) // IS_VALID_18_CS|140203196503125342
  assert_eq(
    @typex.idcard_is_valid_18_case("140203196503125252", 2026, false),
    false,
  ) // IS_VALID_18_CS|140203196503125252
  assert_eq(
    @typex.idcard_is_valid_18_case("140203196503125243", 2026, false),
    false,
  ) // IS_VALID_18_CS|140203196503125243
}

///|
test "Idcard \u{5341}\u{4e94}\u{4f4d}\u{6821}\u{9a8c}\u{ff08}\u{4e24}\u{4f4d}\u{5e74}\u{8865} 19 \u{524d}\u{7f00}\u{ff09}" {
  assert_eq(@typex.idcard_is_valid_15("110101196503125230"), false) // IS_VALID_15|110101196503125230
  assert_eq(@typex.idcard_is_valid_15("140203196503125242"), false) // IS_VALID_15|140203196503125242
  assert_eq(@typex.idcard_is_valid_15("311101196503125239"), false) // IS_VALID_15|311101196503125239
  assert_eq(@typex.idcard_is_valid_15("810101196503125244"), false) // IS_VALID_15|810101196503125244
  assert_eq(@typex.idcard_is_valid_15("820101196503125238"), false) // IS_VALID_15|820101196503125238
  assert_eq(@typex.idcard_is_valid_15("830101196503125248"), false) // IS_VALID_15|830101196503125248
  assert_eq(@typex.idcard_is_valid_15("91010119650312523X"), false) // IS_VALID_15|91010119650312523X
  assert_eq(@typex.idcard_is_valid_15("110101196402295230"), false) // IS_VALID_15|110101196402295230
  assert_eq(@typex.idcard_is_valid_15("110101200002295214"), false) // IS_VALID_15|110101200002295214
  assert_eq(@typex.idcard_is_valid_15("110101202512315237"), false) // IS_VALID_15|110101202512315237
  assert_eq(@typex.idcard_is_valid_15("110101202601015236"), false) // IS_VALID_15|110101202601015236
  assert_eq(@typex.idcard_is_valid_15("110101202612315234"), false) // IS_VALID_15|110101202612315234
  assert_eq(@typex.idcard_is_valid_15("110101202701015233"), false) // IS_VALID_15|110101202701015233
  assert_eq(@typex.idcard_is_valid_15("110101203106155236"), false) // IS_VALID_15|110101203106155236
  assert_eq(@typex.idcard_is_valid_15("911010198802030151"), false) // IS_VALID_15|911010198802030151
  assert_eq(@typex.idcard_is_valid_15("110101650312523"), true) // IS_VALID_15|110101650312523
  assert_eq(@typex.idcard_is_valid_15("310101800101123"), true) // IS_VALID_15|310101800101123
  assert_eq(@typex.idcard_is_valid_15("440301990101001"), true) // IS_VALID_15|440301990101001
  assert_eq(@typex.idcard_is_valid_15("110101000101001"), true) // IS_VALID_15|110101000101001
  assert_eq(@typex.idcard_is_valid_15("110101990101001"), true) // IS_VALID_15|110101990101001
  assert_eq(@typex.idcard_is_valid_15("110101460101001"), true) // IS_VALID_15|110101460101001
  assert_eq(@typex.idcard_is_valid_15("110101450101001"), true) // IS_VALID_15|110101450101001
  assert_eq(@typex.idcard_is_valid_15("110101010101001"), true) // IS_VALID_15|110101010101001
  assert_eq(@typex.idcard_is_valid_15("810000650312523"), true) // IS_VALID_15|810000650312523
  assert_eq(@typex.idcard_is_valid_15("110101020101001"), true) // IS_VALID_15|110101020101001
  assert_eq(@typex.idcard_is_valid_15("110101030101001"), true) // IS_VALID_15|110101030101001
  assert_eq(@typex.idcard_is_valid_15("110101040101001"), true) // IS_VALID_15|110101040101001
  assert_eq(@typex.idcard_is_valid_15("110101050101001"), true) // IS_VALID_15|110101050101001
  assert_eq(@typex.idcard_is_valid_15("110101060101001"), true) // IS_VALID_15|110101060101001
  assert_eq(@typex.idcard_is_valid_15("110101070101001"), true) // IS_VALID_15|110101070101001
  assert_eq(@typex.idcard_is_valid_15("110101080101001"), true) // IS_VALID_15|110101080101001
  assert_eq(@typex.idcard_is_valid_15("110101090101001"), true) // IS_VALID_15|110101090101001
  assert_eq(@typex.idcard_is_valid_15("110101100101001"), true) // IS_VALID_15|110101100101001
  assert_eq(@typex.idcard_is_valid_15("110101110101001"), true) // IS_VALID_15|110101110101001
  assert_eq(@typex.idcard_is_valid_15("110101120101001"), true) // IS_VALID_15|110101120101001
  assert_eq(@typex.idcard_is_valid_15("110101130101001"), true) // IS_VALID_15|110101130101001
  assert_eq(@typex.idcard_is_valid_15("110101140101001"), true) // IS_VALID_15|110101140101001
  assert_eq(@typex.idcard_is_valid_15("110101150101001"), true) // IS_VALID_15|110101150101001
  assert_eq(@typex.idcard_is_valid_15("110101160101001"), true) // IS_VALID_15|110101160101001
  assert_eq(@typex.idcard_is_valid_15("110101170101001"), true) // IS_VALID_15|110101170101001
  assert_eq(@typex.idcard_is_valid_15("110101180101001"), true) // IS_VALID_15|110101180101001
  assert_eq(@typex.idcard_is_valid_15("110101190101001"), true) // IS_VALID_15|110101190101001
  assert_eq(@typex.idcard_is_valid_15("110101200101001"), true) // IS_VALID_15|110101200101001
  assert_eq(@typex.idcard_is_valid_15("110101210101001"), true) // IS_VALID_15|110101210101001
  assert_eq(@typex.idcard_is_valid_15("110101220101001"), true) // IS_VALID_15|110101220101001
  assert_eq(@typex.idcard_is_valid_15("110101230101001"), true) // IS_VALID_15|110101230101001
  assert_eq(@typex.idcard_is_valid_15("110101240101001"), true) // IS_VALID_15|110101240101001
  assert_eq(@typex.idcard_is_valid_15("110101250101001"), true) // IS_VALID_15|110101250101001
  assert_eq(@typex.idcard_is_valid_15("110101260101001"), true) // IS_VALID_15|110101260101001
  assert_eq(@typex.idcard_is_valid_15("110101270101001"), true) // IS_VALID_15|110101270101001
  assert_eq(@typex.idcard_is_valid_15("110101280101001"), true) // IS_VALID_15|110101280101001
  assert_eq(@typex.idcard_is_valid_15("110101290101001"), true) // IS_VALID_15|110101290101001
  assert_eq(@typex.idcard_is_valid_15("110101300101001"), true) // IS_VALID_15|110101300101001
  assert_eq(@typex.idcard_is_valid_15("110101310101001"), true) // IS_VALID_15|110101310101001
  assert_eq(@typex.idcard_is_valid_15("110101320101001"), true) // IS_VALID_15|110101320101001
  assert_eq(@typex.idcard_is_valid_15("110101330101001"), true) // IS_VALID_15|110101330101001
  assert_eq(@typex.idcard_is_valid_15("110101340101001"), true) // IS_VALID_15|110101340101001
  assert_eq(@typex.idcard_is_valid_15("110101350101001"), true) // IS_VALID_15|110101350101001
  assert_eq(@typex.idcard_is_valid_15("110101360101001"), true) // IS_VALID_15|110101360101001
  assert_eq(@typex.idcard_is_valid_15("110101370101001"), true) // IS_VALID_15|110101370101001
  assert_eq(@typex.idcard_is_valid_15("110101380101001"), true) // IS_VALID_15|110101380101001
  assert_eq(@typex.idcard_is_valid_15("110101390101001"), true) // IS_VALID_15|110101390101001
  assert_eq(@typex.idcard_is_valid_15("110101400101001"), true) // IS_VALID_15|110101400101001
  assert_eq(@typex.idcard_is_valid_15("110101410101001"), true) // IS_VALID_15|110101410101001
  assert_eq(@typex.idcard_is_valid_15("110101420101001"), true) // IS_VALID_15|110101420101001
  assert_eq(@typex.idcard_is_valid_15("110101430101001"), true) // IS_VALID_15|110101430101001
  assert_eq(@typex.idcard_is_valid_15("110101440101001"), true) // IS_VALID_15|110101440101001
  assert_eq(@typex.idcard_is_valid_15("110101470101001"), true) // IS_VALID_15|110101470101001
  assert_eq(@typex.idcard_is_valid_15("110101480101001"), true) // IS_VALID_15|110101480101001
  assert_eq(@typex.idcard_is_valid_15("110101490101001"), true) // IS_VALID_15|110101490101001
  assert_eq(@typex.idcard_is_valid_15("110101500101001"), true) // IS_VALID_15|110101500101001
  assert_eq(@typex.idcard_is_valid_15("110101510101001"), true) // IS_VALID_15|110101510101001
  assert_eq(@typex.idcard_is_valid_15("110101520101001"), true) // IS_VALID_15|110101520101001
  assert_eq(@typex.idcard_is_valid_15("110101530101001"), true) // IS_VALID_15|110101530101001
  assert_eq(@typex.idcard_is_valid_15("110101540101001"), true) // IS_VALID_15|110101540101001
  assert_eq(@typex.idcard_is_valid_15("110101550101001"), true) // IS_VALID_15|110101550101001
  assert_eq(@typex.idcard_is_valid_15("110101560101001"), true) // IS_VALID_15|110101560101001
  assert_eq(@typex.idcard_is_valid_15("110101570101001"), true) // IS_VALID_15|110101570101001
  assert_eq(@typex.idcard_is_valid_15("110101580101001"), true) // IS_VALID_15|110101580101001
  assert_eq(@typex.idcard_is_valid_15("110101590101001"), true) // IS_VALID_15|110101590101001
  assert_eq(@typex.idcard_is_valid_15("110101600101001"), true) // IS_VALID_15|110101600101001
  assert_eq(@typex.idcard_is_valid_15("110101610101001"), true) // IS_VALID_15|110101610101001
  assert_eq(@typex.idcard_is_valid_15("110101620101001"), true) // IS_VALID_15|110101620101001
  assert_eq(@typex.idcard_is_valid_15("110101630101001"), true) // IS_VALID_15|110101630101001
  assert_eq(@typex.idcard_is_valid_15("110101640101001"), true) // IS_VALID_15|110101640101001
  assert_eq(@typex.idcard_is_valid_15("110101650101001"), true) // IS_VALID_15|110101650101001
  assert_eq(@typex.idcard_is_valid_15("110101660101001"), true) // IS_VALID_15|110101660101001
  assert_eq(@typex.idcard_is_valid_15("110101670101001"), true) // IS_VALID_15|110101670101001
  assert_eq(@typex.idcard_is_valid_15("110101680101001"), true) // IS_VALID_15|110101680101001
  assert_eq(@typex.idcard_is_valid_15("110101690101001"), true) // IS_VALID_15|110101690101001
  assert_eq(@typex.idcard_is_valid_15("110101700101001"), true) // IS_VALID_15|110101700101001
  assert_eq(@typex.idcard_is_valid_15("110101710101001"), true) // IS_VALID_15|110101710101001
  assert_eq(@typex.idcard_is_valid_15("110101720101001"), true) // IS_VALID_15|110101720101001
  assert_eq(@typex.idcard_is_valid_15("110101730101001"), true) // IS_VALID_15|110101730101001
  assert_eq(@typex.idcard_is_valid_15("110101740101001"), true) // IS_VALID_15|110101740101001
  assert_eq(@typex.idcard_is_valid_15("110101750101001"), true) // IS_VALID_15|110101750101001
  assert_eq(@typex.idcard_is_valid_15("110101760101001"), true) // IS_VALID_15|110101760101001
  assert_eq(@typex.idcard_is_valid_15("110101770101001"), true) // IS_VALID_15|110101770101001
  assert_eq(@typex.idcard_is_valid_15("110101780101001"), true) // IS_VALID_15|110101780101001
  assert_eq(@typex.idcard_is_valid_15("110101790101001"), true) // IS_VALID_15|110101790101001
  assert_eq(@typex.idcard_is_valid_15("110101800101001"), true) // IS_VALID_15|110101800101001
  assert_eq(@typex.idcard_is_valid_15("110101810101001"), true) // IS_VALID_15|110101810101001
  assert_eq(@typex.idcard_is_valid_15("110101820101001"), true) // IS_VALID_15|110101820101001
  assert_eq(@typex.idcard_is_valid_15("110101830101001"), true) // IS_VALID_15|110101830101001
  assert_eq(@typex.idcard_is_valid_15("110101840101001"), true) // IS_VALID_15|110101840101001
  assert_eq(@typex.idcard_is_valid_15("110101850101001"), true) // IS_VALID_15|110101850101001
  assert_eq(@typex.idcard_is_valid_15("110101860101001"), true) // IS_VALID_15|110101860101001
  assert_eq(@typex.idcard_is_valid_15("110101870101001"), true) // IS_VALID_15|110101870101001
  assert_eq(@typex.idcard_is_valid_15("110101880101001"), true) // IS_VALID_15|110101880101001
  assert_eq(@typex.idcard_is_valid_15("110101890101001"), true) // IS_VALID_15|110101890101001
  assert_eq(@typex.idcard_is_valid_15("110101900101001"), true) // IS_VALID_15|110101900101001
  assert_eq(@typex.idcard_is_valid_15("110101910101001"), true) // IS_VALID_15|110101910101001
  assert_eq(@typex.idcard_is_valid_15("110101920101001"), true) // IS_VALID_15|110101920101001
  assert_eq(@typex.idcard_is_valid_15("110101930101001"), true) // IS_VALID_15|110101930101001
  assert_eq(@typex.idcard_is_valid_15("110101940101001"), true) // IS_VALID_15|110101940101001
  assert_eq(@typex.idcard_is_valid_15("110101950101001"), true) // IS_VALID_15|110101950101001
  assert_eq(@typex.idcard_is_valid_15("110101960101001"), true) // IS_VALID_15|110101960101001
  assert_eq(@typex.idcard_is_valid_15("110101970101001"), true) // IS_VALID_15|110101970101001
  assert_eq(@typex.idcard_is_valid_15("110101980101001"), true) // IS_VALID_15|110101980101001
  assert_eq(@typex.idcard_is_valid_15("110101196503125235"), false) // IS_VALID_15|110101196503125235
  assert_eq(@typex.idcard_is_valid_15("11010119650312523X"), false) // IS_VALID_15|11010119650312523X
  assert_eq(@typex.idcard_is_valid_15("1101011965031252 4"), false) // IS_VALID_15|1101011965031252 4
  assert_eq(@typex.idcard_is_valid_15("110101196513125234"), false) // IS_VALID_15|110101196513125234
  assert_eq(@typex.idcard_is_valid_15("110101196502315234"), false) // IS_VALID_15|110101196502315234
  assert_eq(@typex.idcard_is_valid_15("110101196502295234"), false) // IS_VALID_15|110101196502295234
  assert_eq(@typex.idcard_is_valid_15("110101196504315234"), false) // IS_VALID_15|110101196504315234
  assert_eq(@typex.idcard_is_valid_15("110101196500125234"), false) // IS_VALID_15|110101196500125234
  assert_eq(@typex.idcard_is_valid_15("110101196513015234"), false) // IS_VALID_15|110101196513015234
  assert_eq(@typex.idcard_is_valid_15("1101011965031252"), false) // IS_VALID_15|1101011965031252
  assert_eq(@typex.idcard_is_valid_15("1101011965031252344"), false) // IS_VALID_15|1101011965031252344
  assert_eq(@typex.idcard_is_valid_15("110101196503125234X"), false) // IS_VALID_15|110101196503125234X
  assert_eq(@typex.idcard_is_valid_15("99010119650312523X"), false) // IS_VALID_15|99010119650312523X
  assert_eq(@typex.idcard_is_valid_15("000000000000000000"), false) // IS_VALID_15|000000000000000000
  assert_eq(@typex.idcard_is_valid_15("999999999999999999"), false) // IS_VALID_15|999999999999999999
  assert_eq(@typex.idcard_is_valid_15("11010119650312523A"), false) // IS_VALID_15|11010119650312523A
  assert_eq(@typex.idcard_is_valid_15("11010165031252X"), false) // IS_VALID_15|11010165031252X
  assert_eq(@typex.idcard_is_valid_15("11010165031252a"), false) // IS_VALID_15|11010165031252a
  assert_eq(@typex.idcard_is_valid_15("11010165031252"), false) // IS_VALID_15|11010165031252
  assert_eq(@typex.idcard_is_valid_15("1101016503125234"), false) // IS_VALID_15|1101016503125234
  assert_eq(@typex.idcard_is_valid_15(""), false) // IS_VALID_15|
  assert_eq(@typex.idcard_is_valid_15(" "), false) // IS_VALID_15| 
  assert_eq(@typex.idcard_is_valid_15("\t"), false) // IS_VALID_15|	
  assert_eq(@typex.idcard_is_valid_15("1101011965031252x"), false) // IS_VALID_15|1101011965031252x
  assert_eq(@typex.idcard_is_valid_15("81000019650312523X"), false) // IS_VALID_15|81000019650312523X
  assert_eq(@typex.idcard_is_valid_15("820000196503125235"), false) // IS_VALID_15|820000196503125235
  assert_eq(@typex.idcard_is_valid_15("830000196503125234"), false) // IS_VALID_15|830000196503125234
  assert_eq(@typex.idcard_is_valid_15("710000196503125233"), false) // IS_VALID_15|710000196503125233
  assert_eq(@typex.idcard_is_valid_15("910000196503125232"), false) // IS_VALID_15|910000196503125232
  assert_eq(@typex.idcard_is_valid_15("11010119650312000X"), false) // IS_VALID_15|11010119650312000X
  assert_eq(@typex.idcard_is_valid_15("11010119650312000x"), false) // IS_VALID_15|11010119650312000x
  assert_eq(@typex.idcard_is_valid_15("110101190002295234"), false) // IS_VALID_15|110101190002295234
  assert_eq(@typex.idcard_is_valid_15("110101196602295235"), false) // IS_VALID_15|110101196602295235
  assert_eq(@typex.idcard_is_valid_15("110101199602295239"), false) // IS_VALID_15|110101199602295239
  assert_eq(@typex.idcard_is_valid_15("110101190002285239"), false) // IS_VALID_15|110101190002285239
  assert_eq(@typex.idcard_is_valid_15("110101196506315232"), false) // IS_VALID_15|110101196506315232
  assert_eq(@typex.idcard_is_valid_15("110101196507315234"), false) // IS_VALID_15|110101196507315234
  assert_eq(@typex.idcard_is_valid_15("110101196504315239"), false) // IS_VALID_15|110101196504315239
  assert_eq(@typex.idcard_is_valid_15("110101196513015238"), false) // IS_VALID_15|110101196513015238
  assert_eq(@typex.idcard_is_valid_15("110101196500125235"), false) // IS_VALID_15|110101196500125235
  assert_eq(@typex.idcard_is_valid_15("110101196512325234"), false) // IS_VALID_15|110101196512325234
  assert_eq(@typex.idcard_is_valid_15("210101196503125230"), false) // IS_VALID_15|210101196503125230
  assert_eq(@typex.idcard_is_valid_15("120101196503125230"), false) // IS_VALID_15|120101196503125230
  assert_eq(@typex.idcard_is_valid_15("111101196503125230"), false) // IS_VALID_15|111101196503125230
  assert_eq(@typex.idcard_is_valid_15("110201196503125230"), false) // IS_VALID_15|110201196503125230
  assert_eq(@typex.idcard_is_valid_15("110111196503125230"), false) // IS_VALID_15|110111196503125230
  assert_eq(@typex.idcard_is_valid_15("110102196503125230"), false) // IS_VALID_15|110102196503125230
  assert_eq(@typex.idcard_is_valid_15("110101296503125230"), false) // IS_VALID_15|110101296503125230
  assert_eq(@typex.idcard_is_valid_15("1101011X6503125230"), false) // IS_VALID_15|1101011X6503125230
  assert_eq(@typex.idcard_is_valid_15("110101197503125230"), false) // IS_VALID_15|110101197503125230
  assert_eq(@typex.idcard_is_valid_15("110101196603125230"), false) // IS_VALID_15|110101196603125230
  assert_eq(@typex.idcard_is_valid_15("110101196513125230"), false) // IS_VALID_15|110101196513125230
  assert_eq(@typex.idcard_is_valid_15("110101196504125230"), false) // IS_VALID_15|110101196504125230
  assert_eq(@typex.idcard_is_valid_15("110101196503225230"), false) // IS_VALID_15|110101196503225230
  assert_eq(@typex.idcard_is_valid_15("110101196503135230"), false) // IS_VALID_15|110101196503135230
  assert_eq(@typex.idcard_is_valid_15("110101196503126230"), false) // IS_VALID_15|110101196503126230
  assert_eq(@typex.idcard_is_valid_15("110101196503125330"), false) // IS_VALID_15|110101196503125330
  assert_eq(@typex.idcard_is_valid_15("110101196503125240"), false) // IS_VALID_15|110101196503125240
  assert_eq(@typex.idcard_is_valid_15("110101196503125231"), false) // IS_VALID_15|110101196503125231
  assert_eq(@typex.idcard_is_valid_15("240203196503125242"), false) // IS_VALID_15|240203196503125242
  assert_eq(@typex.idcard_is_valid_15("150203196503125242"), false) // IS_VALID_15|150203196503125242
  assert_eq(@typex.idcard_is_valid_15("141203196503125242"), false) // IS_VALID_15|141203196503125242
  assert_eq(@typex.idcard_is_valid_15("140303196503125242"), false) // IS_VALID_15|140303196503125242
  assert_eq(@typex.idcard_is_valid_15("140213196503125242"), false) // IS_VALID_15|140213196503125242
  assert_eq(@typex.idcard_is_valid_15("140204196503125242"), false) // IS_VALID_15|140204196503125242
  assert_eq(@typex.idcard_is_valid_15("140203296503125242"), false) // IS_VALID_15|140203296503125242
  assert_eq(@typex.idcard_is_valid_15("1402031X6503125242"), false) // IS_VALID_15|1402031X6503125242
  assert_eq(@typex.idcard_is_valid_15("140203197503125242"), false) // IS_VALID_15|140203197503125242
  assert_eq(@typex.idcard_is_valid_15("140203196603125242"), false) // IS_VALID_15|140203196603125242
  assert_eq(@typex.idcard_is_valid_15("140203196513125242"), false) // IS_VALID_15|140203196513125242
  assert_eq(@typex.idcard_is_valid_15("140203196504125242"), false) // IS_VALID_15|140203196504125242
  assert_eq(@typex.idcard_is_valid_15("140203196503225242"), false) // IS_VALID_15|140203196503225242
  assert_eq(@typex.idcard_is_valid_15("140203196503135242"), false) // IS_VALID_15|140203196503135242
  assert_eq(@typex.idcard_is_valid_15("140203196503126242"), false) // IS_VALID_15|140203196503126242
  assert_eq(@typex.idcard_is_valid_15("140203196503125342"), false) // IS_VALID_15|140203196503125342
  assert_eq(@typex.idcard_is_valid_15("140203196503125252"), false) // IS_VALID_15|140203196503125252
  assert_eq(@typex.idcard_is_valid_15("140203196503125243"), false) // IS_VALID_15|140203196503125243
}

///|
test "Idcard \u{5341}\u{4e94}\u{8f6c}\u{5341}\u{516b}\u{ff08}\u{4e16}\u{7eaa}\u{6620}\u{5c04}\u{4e0e}\u{6821}\u{9a8c}\u{4f4d}\u{ff09}" {
  assert_eq(@typex.idcard_convert_15_to_18("110101196503125230"), None) // CONVERT_15_18|110101196503125230
  assert_eq(@typex.idcard_convert_15_to_18("140203196503125242"), None) // CONVERT_15_18|140203196503125242
  assert_eq(@typex.idcard_convert_15_to_18("311101196503125239"), None) // CONVERT_15_18|311101196503125239
  assert_eq(@typex.idcard_convert_15_to_18("810101196503125244"), None) // CONVERT_15_18|810101196503125244
  assert_eq(@typex.idcard_convert_15_to_18("820101196503125238"), None) // CONVERT_15_18|820101196503125238
  assert_eq(@typex.idcard_convert_15_to_18("830101196503125248"), None) // CONVERT_15_18|830101196503125248
  assert_eq(@typex.idcard_convert_15_to_18("91010119650312523X"), None) // CONVERT_15_18|91010119650312523X
  assert_eq(@typex.idcard_convert_15_to_18("110101196402295230"), None) // CONVERT_15_18|110101196402295230
  assert_eq(@typex.idcard_convert_15_to_18("110101200002295214"), None) // CONVERT_15_18|110101200002295214
  assert_eq(@typex.idcard_convert_15_to_18("110101202512315237"), None) // CONVERT_15_18|110101202512315237
  assert_eq(@typex.idcard_convert_15_to_18("110101202601015236"), None) // CONVERT_15_18|110101202601015236
  assert_eq(@typex.idcard_convert_15_to_18("110101202612315234"), None) // CONVERT_15_18|110101202612315234
  assert_eq(@typex.idcard_convert_15_to_18("110101202701015233"), None) // CONVERT_15_18|110101202701015233
  assert_eq(@typex.idcard_convert_15_to_18("110101203106155236"), None) // CONVERT_15_18|110101203106155236
  assert_eq(@typex.idcard_convert_15_to_18("911010198802030151"), None) // CONVERT_15_18|911010198802030151
  assert_eq(
    @typex.idcard_convert_15_to_18("110101650312523"),
    Some("110101196503125230"),
  ) // CONVERT_15_18|110101650312523
  assert_eq(
    @typex.idcard_convert_15_to_18("310101800101123"),
    Some("31010119800101123X"),
  ) // CONVERT_15_18|310101800101123
  assert_eq(
    @typex.idcard_convert_15_to_18("440301990101001"),
    Some("440301199901010018"),
  ) // CONVERT_15_18|440301990101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101000101001"),
    Some("110101200001010010"),
  ) // CONVERT_15_18|110101000101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101990101001"),
    Some("110101199901010010"),
  ) // CONVERT_15_18|110101990101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101460101001"),
    Some("110101194601010016"),
  ) // CONVERT_15_18|110101460101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101450101001"),
    Some("110101194501010019"),
  ) // CONVERT_15_18|110101450101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101010101001"),
    Some("110101190101010011"),
  ) // CONVERT_15_18|110101010101001
  assert_eq(
    @typex.idcard_convert_15_to_18("810000650312523"),
    Some("810000196503125234"),
  ) // CONVERT_15_18|810000650312523
  assert_eq(
    @typex.idcard_convert_15_to_18("110101020101001"),
    Some("110101190201010019"),
  ) // CONVERT_15_18|110101020101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101030101001"),
    Some("110101190301010016"),
  ) // CONVERT_15_18|110101030101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101040101001"),
    Some("110101190401010013"),
  ) // CONVERT_15_18|110101040101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101050101001"),
    Some("110101190501010010"),
  ) // CONVERT_15_18|110101050101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101060101001"),
    Some("110101190601010018"),
  ) // CONVERT_15_18|110101060101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101070101001"),
    Some("110101190701010015"),
  ) // CONVERT_15_18|110101070101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101080101001"),
    Some("110101190801010012"),
  ) // CONVERT_15_18|110101080101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101090101001"),
    Some("11010119090101001X"),
  ) // CONVERT_15_18|110101090101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101100101001"),
    Some("110101191001010019"),
  ) // CONVERT_15_18|110101100101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101110101001"),
    Some("110101191101010016"),
  ) // CONVERT_15_18|110101110101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101120101001"),
    Some("110101191201010013"),
  ) // CONVERT_15_18|110101120101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101130101001"),
    Some("110101191301010010"),
  ) // CONVERT_15_18|110101130101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101140101001"),
    Some("110101191401010018"),
  ) // CONVERT_15_18|110101140101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101150101001"),
    Some("110101191501010015"),
  ) // CONVERT_15_18|110101150101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101160101001"),
    Some("110101191601010012"),
  ) // CONVERT_15_18|110101160101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101170101001"),
    Some("11010119170101001X"),
  ) // CONVERT_15_18|110101170101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101180101001"),
    Some("110101191801010017"),
  ) // CONVERT_15_18|110101180101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101190101001"),
    Some("110101191901010014"),
  ) // CONVERT_15_18|110101190101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101200101001"),
    Some("110101192001010013"),
  ) // CONVERT_15_18|110101200101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101210101001"),
    Some("110101192101010010"),
  ) // CONVERT_15_18|110101210101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101220101001"),
    Some("110101192201010018"),
  ) // CONVERT_15_18|110101220101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101230101001"),
    Some("110101192301010015"),
  ) // CONVERT_15_18|110101230101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101240101001"),
    Some("110101192401010012"),
  ) // CONVERT_15_18|110101240101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101250101001"),
    Some("11010119250101001X"),
  ) // CONVERT_15_18|110101250101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101260101001"),
    Some("110101192601010017"),
  ) // CONVERT_15_18|110101260101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101270101001"),
    Some("110101192701010014"),
  ) // CONVERT_15_18|110101270101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101280101001"),
    Some("110101192801010011"),
  ) // CONVERT_15_18|110101280101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101290101001"),
    Some("110101192901010019"),
  ) // CONVERT_15_18|110101290101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101300101001"),
    Some("110101193001010018"),
  ) // CONVERT_15_18|110101300101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101310101001"),
    Some("110101193101010015"),
  ) // CONVERT_15_18|110101310101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101320101001"),
    Some("110101193201010012"),
  ) // CONVERT_15_18|110101320101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101330101001"),
    Some("11010119330101001X"),
  ) // CONVERT_15_18|110101330101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101340101001"),
    Some("110101193401010017"),
  ) // CONVERT_15_18|110101340101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101350101001"),
    Some("110101193501010014"),
  ) // CONVERT_15_18|110101350101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101360101001"),
    Some("110101193601010011"),
  ) // CONVERT_15_18|110101360101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101370101001"),
    Some("110101193701010019"),
  ) // CONVERT_15_18|110101370101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101380101001"),
    Some("110101193801010016"),
  ) // CONVERT_15_18|110101380101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101390101001"),
    Some("110101193901010013"),
  ) // CONVERT_15_18|110101390101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101400101001"),
    Some("110101194001010012"),
  ) // CONVERT_15_18|110101400101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101410101001"),
    Some("11010119410101001X"),
  ) // CONVERT_15_18|110101410101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101420101001"),
    Some("110101194201010017"),
  ) // CONVERT_15_18|110101420101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101430101001"),
    Some("110101194301010014"),
  ) // CONVERT_15_18|110101430101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101440101001"),
    Some("110101194401010011"),
  ) // CONVERT_15_18|110101440101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101470101001"),
    Some("110101194701010013"),
  ) // CONVERT_15_18|110101470101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101480101001"),
    Some("110101194801010010"),
  ) // CONVERT_15_18|110101480101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101490101001"),
    Some("110101194901010018"),
  ) // CONVERT_15_18|110101490101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101500101001"),
    Some("110101195001010017"),
  ) // CONVERT_15_18|110101500101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101510101001"),
    Some("110101195101010014"),
  ) // CONVERT_15_18|110101510101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101520101001"),
    Some("110101195201010011"),
  ) // CONVERT_15_18|110101520101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101530101001"),
    Some("110101195301010019"),
  ) // CONVERT_15_18|110101530101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101540101001"),
    Some("110101195401010016"),
  ) // CONVERT_15_18|110101540101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101550101001"),
    Some("110101195501010013"),
  ) // CONVERT_15_18|110101550101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101560101001"),
    Some("110101195601010010"),
  ) // CONVERT_15_18|110101560101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101570101001"),
    Some("110101195701010018"),
  ) // CONVERT_15_18|110101570101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101580101001"),
    Some("110101195801010015"),
  ) // CONVERT_15_18|110101580101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101590101001"),
    Some("110101195901010012"),
  ) // CONVERT_15_18|110101590101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101600101001"),
    Some("110101196001010011"),
  ) // CONVERT_15_18|110101600101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101610101001"),
    Some("110101196101010019"),
  ) // CONVERT_15_18|110101610101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101620101001"),
    Some("110101196201010016"),
  ) // CONVERT_15_18|110101620101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101630101001"),
    Some("110101196301010013"),
  ) // CONVERT_15_18|110101630101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101640101001"),
    Some("110101196401010010"),
  ) // CONVERT_15_18|110101640101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101650101001"),
    Some("110101196501010018"),
  ) // CONVERT_15_18|110101650101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101660101001"),
    Some("110101196601010015"),
  ) // CONVERT_15_18|110101660101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101670101001"),
    Some("110101196701010012"),
  ) // CONVERT_15_18|110101670101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101680101001"),
    Some("11010119680101001X"),
  ) // CONVERT_15_18|110101680101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101690101001"),
    Some("110101196901010017"),
  ) // CONVERT_15_18|110101690101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101700101001"),
    Some("110101197001010016"),
  ) // CONVERT_15_18|110101700101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101710101001"),
    Some("110101197101010013"),
  ) // CONVERT_15_18|110101710101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101720101001"),
    Some("110101197201010010"),
  ) // CONVERT_15_18|110101720101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101730101001"),
    Some("110101197301010018"),
  ) // CONVERT_15_18|110101730101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101740101001"),
    Some("110101197401010015"),
  ) // CONVERT_15_18|110101740101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101750101001"),
    Some("110101197501010012"),
  ) // CONVERT_15_18|110101750101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101760101001"),
    Some("11010119760101001X"),
  ) // CONVERT_15_18|110101760101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101770101001"),
    Some("110101197701010017"),
  ) // CONVERT_15_18|110101770101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101780101001"),
    Some("110101197801010014"),
  ) // CONVERT_15_18|110101780101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101790101001"),
    Some("110101197901010011"),
  ) // CONVERT_15_18|110101790101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101800101001"),
    Some("110101198001010010"),
  ) // CONVERT_15_18|110101800101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101810101001"),
    Some("110101198101010018"),
  ) // CONVERT_15_18|110101810101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101820101001"),
    Some("110101198201010015"),
  ) // CONVERT_15_18|110101820101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101830101001"),
    Some("110101198301010012"),
  ) // CONVERT_15_18|110101830101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101840101001"),
    Some("11010119840101001X"),
  ) // CONVERT_15_18|110101840101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101850101001"),
    Some("110101198501010017"),
  ) // CONVERT_15_18|110101850101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101860101001"),
    Some("110101198601010014"),
  ) // CONVERT_15_18|110101860101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101870101001"),
    Some("110101198701010011"),
  ) // CONVERT_15_18|110101870101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101880101001"),
    Some("110101198801010019"),
  ) // CONVERT_15_18|110101880101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101890101001"),
    Some("110101198901010016"),
  ) // CONVERT_15_18|110101890101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101900101001"),
    Some("110101199001010015"),
  ) // CONVERT_15_18|110101900101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101910101001"),
    Some("110101199101010012"),
  ) // CONVERT_15_18|110101910101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101920101001"),
    Some("11010119920101001X"),
  ) // CONVERT_15_18|110101920101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101930101001"),
    Some("110101199301010017"),
  ) // CONVERT_15_18|110101930101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101940101001"),
    Some("110101199401010014"),
  ) // CONVERT_15_18|110101940101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101950101001"),
    Some("110101199501010011"),
  ) // CONVERT_15_18|110101950101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101960101001"),
    Some("110101199601010019"),
  ) // CONVERT_15_18|110101960101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101970101001"),
    Some("110101199701010016"),
  ) // CONVERT_15_18|110101970101001
  assert_eq(
    @typex.idcard_convert_15_to_18("110101980101001"),
    Some("110101199801010013"),
  ) // CONVERT_15_18|110101980101001
  assert_eq(@typex.idcard_convert_15_to_18("110101196503125235"), None) // CONVERT_15_18|110101196503125235
  assert_eq(@typex.idcard_convert_15_to_18("11010119650312523X"), None) // CONVERT_15_18|11010119650312523X
  assert_eq(@typex.idcard_convert_15_to_18("1101011965031252 4"), None) // CONVERT_15_18|1101011965031252 4
  assert_eq(@typex.idcard_convert_15_to_18("110101196513125234"), None) // CONVERT_15_18|110101196513125234
  assert_eq(@typex.idcard_convert_15_to_18("110101196502315234"), None) // CONVERT_15_18|110101196502315234
  assert_eq(@typex.idcard_convert_15_to_18("110101196502295234"), None) // CONVERT_15_18|110101196502295234
  assert_eq(@typex.idcard_convert_15_to_18("110101196504315234"), None) // CONVERT_15_18|110101196504315234
  assert_eq(@typex.idcard_convert_15_to_18("110101196500125234"), None) // CONVERT_15_18|110101196500125234
  assert_eq(@typex.idcard_convert_15_to_18("110101196513015234"), None) // CONVERT_15_18|110101196513015234
  assert_eq(@typex.idcard_convert_15_to_18("1101011965031252"), None) // CONVERT_15_18|1101011965031252
  assert_eq(@typex.idcard_convert_15_to_18("1101011965031252344"), None) // CONVERT_15_18|1101011965031252344
  assert_eq(@typex.idcard_convert_15_to_18("110101196503125234X"), None) // CONVERT_15_18|110101196503125234X
  assert_eq(@typex.idcard_convert_15_to_18("99010119650312523X"), None) // CONVERT_15_18|99010119650312523X
  assert_eq(@typex.idcard_convert_15_to_18("000000000000000000"), None) // CONVERT_15_18|000000000000000000
  assert_eq(@typex.idcard_convert_15_to_18("999999999999999999"), None) // CONVERT_15_18|999999999999999999
  assert_eq(@typex.idcard_convert_15_to_18("11010119650312523A"), None) // CONVERT_15_18|11010119650312523A
  assert_eq(@typex.idcard_convert_15_to_18("11010165031252X"), None) // CONVERT_15_18|11010165031252X
  assert_eq(@typex.idcard_convert_15_to_18("11010165031252a"), None) // CONVERT_15_18|11010165031252a
  assert_eq(@typex.idcard_convert_15_to_18("11010165031252"), None) // CONVERT_15_18|11010165031252
  assert_eq(@typex.idcard_convert_15_to_18("1101016503125234"), None) // CONVERT_15_18|1101016503125234
  assert_eq(@typex.idcard_convert_15_to_18(""), None) // CONVERT_15_18|
  assert_eq(@typex.idcard_convert_15_to_18(" "), None) // CONVERT_15_18| 
  assert_eq(@typex.idcard_convert_15_to_18("\t"), None) // CONVERT_15_18|	
  assert_eq(@typex.idcard_convert_15_to_18("1101011965031252x"), None) // CONVERT_15_18|1101011965031252x
  assert_eq(@typex.idcard_convert_15_to_18("81000019650312523X"), None) // CONVERT_15_18|81000019650312523X
  assert_eq(@typex.idcard_convert_15_to_18("820000196503125235"), None) // CONVERT_15_18|820000196503125235
  assert_eq(@typex.idcard_convert_15_to_18("830000196503125234"), None) // CONVERT_15_18|830000196503125234
  assert_eq(@typex.idcard_convert_15_to_18("710000196503125233"), None) // CONVERT_15_18|710000196503125233
  assert_eq(@typex.idcard_convert_15_to_18("910000196503125232"), None) // CONVERT_15_18|910000196503125232
  assert_eq(@typex.idcard_convert_15_to_18("11010119650312000X"), None) // CONVERT_15_18|11010119650312000X
  assert_eq(@typex.idcard_convert_15_to_18("11010119650312000x"), None) // CONVERT_15_18|11010119650312000x
  assert_eq(@typex.idcard_convert_15_to_18("110101190002295234"), None) // CONVERT_15_18|110101190002295234
  assert_eq(@typex.idcard_convert_15_to_18("110101196602295235"), None) // CONVERT_15_18|110101196602295235
  assert_eq(@typex.idcard_convert_15_to_18("110101199602295239"), None) // CONVERT_15_18|110101199602295239
  assert_eq(@typex.idcard_convert_15_to_18("110101190002285239"), None) // CONVERT_15_18|110101190002285239
  assert_eq(@typex.idcard_convert_15_to_18("110101196506315232"), None) // CONVERT_15_18|110101196506315232
  assert_eq(@typex.idcard_convert_15_to_18("110101196507315234"), None) // CONVERT_15_18|110101196507315234
  assert_eq(@typex.idcard_convert_15_to_18("110101196504315239"), None) // CONVERT_15_18|110101196504315239
  assert_eq(@typex.idcard_convert_15_to_18("110101196513015238"), None) // CONVERT_15_18|110101196513015238
  assert_eq(@typex.idcard_convert_15_to_18("110101196500125235"), None) // CONVERT_15_18|110101196500125235
  assert_eq(@typex.idcard_convert_15_to_18("110101196512325234"), None) // CONVERT_15_18|110101196512325234
  assert_eq(@typex.idcard_convert_15_to_18("210101196503125230"), None) // CONVERT_15_18|210101196503125230
  assert_eq(@typex.idcard_convert_15_to_18("120101196503125230"), None) // CONVERT_15_18|120101196503125230
  assert_eq(@typex.idcard_convert_15_to_18("111101196503125230"), None) // CONVERT_15_18|111101196503125230
  assert_eq(@typex.idcard_convert_15_to_18("110201196503125230"), None) // CONVERT_15_18|110201196503125230
  assert_eq(@typex.idcard_convert_15_to_18("110111196503125230"), None) // CONVERT_15_18|110111196503125230
  assert_eq(@typex.idcard_convert_15_to_18("110102196503125230"), None) // CONVERT_15_18|110102196503125230
  assert_eq(@typex.idcard_convert_15_to_18("110101296503125230"), None) // CONVERT_15_18|110101296503125230
  assert_eq(@typex.idcard_convert_15_to_18("1101011X6503125230"), None) // CONVERT_15_18|1101011X6503125230
  assert_eq(@typex.idcard_convert_15_to_18("110101197503125230"), None) // CONVERT_15_18|110101197503125230
  assert_eq(@typex.idcard_convert_15_to_18("110101196603125230"), None) // CONVERT_15_18|110101196603125230
  assert_eq(@typex.idcard_convert_15_to_18("110101196513125230"), None) // CONVERT_15_18|110101196513125230
  assert_eq(@typex.idcard_convert_15_to_18("110101196504125230"), None) // CONVERT_15_18|110101196504125230
  assert_eq(@typex.idcard_convert_15_to_18("110101196503225230"), None) // CONVERT_15_18|110101196503225230
  assert_eq(@typex.idcard_convert_15_to_18("110101196503135230"), None) // CONVERT_15_18|110101196503135230
  assert_eq(@typex.idcard_convert_15_to_18("110101196503126230"), None) // CONVERT_15_18|110101196503126230
  assert_eq(@typex.idcard_convert_15_to_18("110101196503125330"), None) // CONVERT_15_18|110101196503125330
  assert_eq(@typex.idcard_convert_15_to_18("110101196503125240"), None) // CONVERT_15_18|110101196503125240
  assert_eq(@typex.idcard_convert_15_to_18("110101196503125231"), None) // CONVERT_15_18|110101196503125231
  assert_eq(@typex.idcard_convert_15_to_18("240203196503125242"), None) // CONVERT_15_18|240203196503125242
  assert_eq(@typex.idcard_convert_15_to_18("150203196503125242"), None) // CONVERT_15_18|150203196503125242
  assert_eq(@typex.idcard_convert_15_to_18("141203196503125242"), None) // CONVERT_15_18|141203196503125242
  assert_eq(@typex.idcard_convert_15_to_18("140303196503125242"), None) // CONVERT_15_18|140303196503125242
  assert_eq(@typex.idcard_convert_15_to_18("140213196503125242"), None) // CONVERT_15_18|140213196503125242
  assert_eq(@typex.idcard_convert_15_to_18("140204196503125242"), None) // CONVERT_15_18|140204196503125242
  assert_eq(@typex.idcard_convert_15_to_18("140203296503125242"), None) // CONVERT_15_18|140203296503125242
  assert_eq(@typex.idcard_convert_15_to_18("1402031X6503125242"), None) // CONVERT_15_18|1402031X6503125242
  assert_eq(@typex.idcard_convert_15_to_18("140203197503125242"), None) // CONVERT_15_18|140203197503125242
  assert_eq(@typex.idcard_convert_15_to_18("140203196603125242"), None) // CONVERT_15_18|140203196603125242
  assert_eq(@typex.idcard_convert_15_to_18("140203196513125242"), None) // CONVERT_15_18|140203196513125242
  assert_eq(@typex.idcard_convert_15_to_18("140203196504125242"), None) // CONVERT_15_18|140203196504125242
  assert_eq(@typex.idcard_convert_15_to_18("140203196503225242"), None) // CONVERT_15_18|140203196503225242
  assert_eq(@typex.idcard_convert_15_to_18("140203196503135242"), None) // CONVERT_15_18|140203196503135242
  assert_eq(@typex.idcard_convert_15_to_18("140203196503126242"), None) // CONVERT_15_18|140203196503126242
  assert_eq(@typex.idcard_convert_15_to_18("140203196503125342"), None) // CONVERT_15_18|140203196503125342
  assert_eq(@typex.idcard_convert_15_to_18("140203196503125252"), None) // CONVERT_15_18|140203196503125252
  assert_eq(@typex.idcard_convert_15_to_18("140203196503125243"), None) // CONVERT_15_18|140203196503125243
}

///|
test "Idcard \u{5341}\u{516b}\u{8f6c}\u{5341}\u{4e94}\u{ff08}\u{975e}\u{6cd5}\u{6863}\u{539f}\u{6837}\u{8fd4}\u{56de}\u{ff09}" {
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196503125230", 2026),
    "110101650312523",
  ) // CONVERT_18_15|110101196503125230
  assert_eq(
    @typex.idcard_convert_18_to_15("140203196503125242", 2026),
    "140203650312524",
  ) // CONVERT_18_15|140203196503125242
  assert_eq(
    @typex.idcard_convert_18_to_15("311101196503125239", 2026),
    "311101650312523",
  ) // CONVERT_18_15|311101196503125239
  assert_eq(
    @typex.idcard_convert_18_to_15("810101196503125244", 2026),
    "810101650312524",
  ) // CONVERT_18_15|810101196503125244
  assert_eq(
    @typex.idcard_convert_18_to_15("820101196503125238", 2026),
    "820101650312523",
  ) // CONVERT_18_15|820101196503125238
  assert_eq(
    @typex.idcard_convert_18_to_15("830101196503125248", 2026),
    "830101650312524",
  ) // CONVERT_18_15|830101196503125248
  assert_eq(
    @typex.idcard_convert_18_to_15("91010119650312523X", 2026),
    "91010119650312523X",
  ) // CONVERT_18_15|91010119650312523X
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196402295230", 2026),
    "110101640229523",
  ) // CONVERT_18_15|110101196402295230
  assert_eq(
    @typex.idcard_convert_18_to_15("110101200002295214", 2026),
    "110101000229521",
  ) // CONVERT_18_15|110101200002295214
  assert_eq(
    @typex.idcard_convert_18_to_15("110101202512315237", 2026),
    "110101251231523",
  ) // CONVERT_18_15|110101202512315237
  assert_eq(
    @typex.idcard_convert_18_to_15("110101202601015236", 2026),
    "110101260101523",
  ) // CONVERT_18_15|110101202601015236
  assert_eq(
    @typex.idcard_convert_18_to_15("110101202612315234", 2026),
    "110101261231523",
  ) // CONVERT_18_15|110101202612315234
  assert_eq(
    @typex.idcard_convert_18_to_15("110101202701015233", 2026),
    "110101202701015233",
  ) // CONVERT_18_15|110101202701015233
  assert_eq(
    @typex.idcard_convert_18_to_15("110101203106155236", 2026),
    "110101203106155236",
  ) // CONVERT_18_15|110101203106155236
  assert_eq(
    @typex.idcard_convert_18_to_15("911010198802030151", 2026),
    "911010880203015",
  ) // CONVERT_18_15|911010198802030151
  assert_eq(
    @typex.idcard_convert_18_to_15("110101650312523", 2026),
    "110101650312523",
  ) // CONVERT_18_15|110101650312523
  assert_eq(
    @typex.idcard_convert_18_to_15("310101800101123", 2026),
    "310101800101123",
  ) // CONVERT_18_15|310101800101123
  assert_eq(
    @typex.idcard_convert_18_to_15("440301990101001", 2026),
    "440301990101001",
  ) // CONVERT_18_15|440301990101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101000101001", 2026),
    "110101000101001",
  ) // CONVERT_18_15|110101000101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101990101001", 2026),
    "110101990101001",
  ) // CONVERT_18_15|110101990101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101460101001", 2026),
    "110101460101001",
  ) // CONVERT_18_15|110101460101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101450101001", 2026),
    "110101450101001",
  ) // CONVERT_18_15|110101450101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101010101001", 2026),
    "110101010101001",
  ) // CONVERT_18_15|110101010101001
  assert_eq(
    @typex.idcard_convert_18_to_15("810000650312523", 2026),
    "810000650312523",
  ) // CONVERT_18_15|810000650312523
  assert_eq(
    @typex.idcard_convert_18_to_15("110101020101001", 2026),
    "110101020101001",
  ) // CONVERT_18_15|110101020101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101030101001", 2026),
    "110101030101001",
  ) // CONVERT_18_15|110101030101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101040101001", 2026),
    "110101040101001",
  ) // CONVERT_18_15|110101040101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101050101001", 2026),
    "110101050101001",
  ) // CONVERT_18_15|110101050101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101060101001", 2026),
    "110101060101001",
  ) // CONVERT_18_15|110101060101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101070101001", 2026),
    "110101070101001",
  ) // CONVERT_18_15|110101070101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101080101001", 2026),
    "110101080101001",
  ) // CONVERT_18_15|110101080101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101090101001", 2026),
    "110101090101001",
  ) // CONVERT_18_15|110101090101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101100101001", 2026),
    "110101100101001",
  ) // CONVERT_18_15|110101100101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101110101001", 2026),
    "110101110101001",
  ) // CONVERT_18_15|110101110101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101120101001", 2026),
    "110101120101001",
  ) // CONVERT_18_15|110101120101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101130101001", 2026),
    "110101130101001",
  ) // CONVERT_18_15|110101130101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101140101001", 2026),
    "110101140101001",
  ) // CONVERT_18_15|110101140101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101150101001", 2026),
    "110101150101001",
  ) // CONVERT_18_15|110101150101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101160101001", 2026),
    "110101160101001",
  ) // CONVERT_18_15|110101160101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101170101001", 2026),
    "110101170101001",
  ) // CONVERT_18_15|110101170101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101180101001", 2026),
    "110101180101001",
  ) // CONVERT_18_15|110101180101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101190101001", 2026),
    "110101190101001",
  ) // CONVERT_18_15|110101190101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101200101001", 2026),
    "110101200101001",
  ) // CONVERT_18_15|110101200101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101210101001", 2026),
    "110101210101001",
  ) // CONVERT_18_15|110101210101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101220101001", 2026),
    "110101220101001",
  ) // CONVERT_18_15|110101220101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101230101001", 2026),
    "110101230101001",
  ) // CONVERT_18_15|110101230101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101240101001", 2026),
    "110101240101001",
  ) // CONVERT_18_15|110101240101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101250101001", 2026),
    "110101250101001",
  ) // CONVERT_18_15|110101250101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101260101001", 2026),
    "110101260101001",
  ) // CONVERT_18_15|110101260101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101270101001", 2026),
    "110101270101001",
  ) // CONVERT_18_15|110101270101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101280101001", 2026),
    "110101280101001",
  ) // CONVERT_18_15|110101280101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101290101001", 2026),
    "110101290101001",
  ) // CONVERT_18_15|110101290101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101300101001", 2026),
    "110101300101001",
  ) // CONVERT_18_15|110101300101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101310101001", 2026),
    "110101310101001",
  ) // CONVERT_18_15|110101310101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101320101001", 2026),
    "110101320101001",
  ) // CONVERT_18_15|110101320101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101330101001", 2026),
    "110101330101001",
  ) // CONVERT_18_15|110101330101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101340101001", 2026),
    "110101340101001",
  ) // CONVERT_18_15|110101340101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101350101001", 2026),
    "110101350101001",
  ) // CONVERT_18_15|110101350101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101360101001", 2026),
    "110101360101001",
  ) // CONVERT_18_15|110101360101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101370101001", 2026),
    "110101370101001",
  ) // CONVERT_18_15|110101370101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101380101001", 2026),
    "110101380101001",
  ) // CONVERT_18_15|110101380101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101390101001", 2026),
    "110101390101001",
  ) // CONVERT_18_15|110101390101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101400101001", 2026),
    "110101400101001",
  ) // CONVERT_18_15|110101400101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101410101001", 2026),
    "110101410101001",
  ) // CONVERT_18_15|110101410101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101420101001", 2026),
    "110101420101001",
  ) // CONVERT_18_15|110101420101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101430101001", 2026),
    "110101430101001",
  ) // CONVERT_18_15|110101430101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101440101001", 2026),
    "110101440101001",
  ) // CONVERT_18_15|110101440101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101470101001", 2026),
    "110101470101001",
  ) // CONVERT_18_15|110101470101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101480101001", 2026),
    "110101480101001",
  ) // CONVERT_18_15|110101480101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101490101001", 2026),
    "110101490101001",
  ) // CONVERT_18_15|110101490101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101500101001", 2026),
    "110101500101001",
  ) // CONVERT_18_15|110101500101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101510101001", 2026),
    "110101510101001",
  ) // CONVERT_18_15|110101510101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101520101001", 2026),
    "110101520101001",
  ) // CONVERT_18_15|110101520101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101530101001", 2026),
    "110101530101001",
  ) // CONVERT_18_15|110101530101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101540101001", 2026),
    "110101540101001",
  ) // CONVERT_18_15|110101540101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101550101001", 2026),
    "110101550101001",
  ) // CONVERT_18_15|110101550101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101560101001", 2026),
    "110101560101001",
  ) // CONVERT_18_15|110101560101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101570101001", 2026),
    "110101570101001",
  ) // CONVERT_18_15|110101570101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101580101001", 2026),
    "110101580101001",
  ) // CONVERT_18_15|110101580101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101590101001", 2026),
    "110101590101001",
  ) // CONVERT_18_15|110101590101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101600101001", 2026),
    "110101600101001",
  ) // CONVERT_18_15|110101600101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101610101001", 2026),
    "110101610101001",
  ) // CONVERT_18_15|110101610101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101620101001", 2026),
    "110101620101001",
  ) // CONVERT_18_15|110101620101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101630101001", 2026),
    "110101630101001",
  ) // CONVERT_18_15|110101630101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101640101001", 2026),
    "110101640101001",
  ) // CONVERT_18_15|110101640101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101650101001", 2026),
    "110101650101001",
  ) // CONVERT_18_15|110101650101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101660101001", 2026),
    "110101660101001",
  ) // CONVERT_18_15|110101660101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101670101001", 2026),
    "110101670101001",
  ) // CONVERT_18_15|110101670101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101680101001", 2026),
    "110101680101001",
  ) // CONVERT_18_15|110101680101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101690101001", 2026),
    "110101690101001",
  ) // CONVERT_18_15|110101690101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101700101001", 2026),
    "110101700101001",
  ) // CONVERT_18_15|110101700101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101710101001", 2026),
    "110101710101001",
  ) // CONVERT_18_15|110101710101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101720101001", 2026),
    "110101720101001",
  ) // CONVERT_18_15|110101720101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101730101001", 2026),
    "110101730101001",
  ) // CONVERT_18_15|110101730101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101740101001", 2026),
    "110101740101001",
  ) // CONVERT_18_15|110101740101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101750101001", 2026),
    "110101750101001",
  ) // CONVERT_18_15|110101750101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101760101001", 2026),
    "110101760101001",
  ) // CONVERT_18_15|110101760101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101770101001", 2026),
    "110101770101001",
  ) // CONVERT_18_15|110101770101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101780101001", 2026),
    "110101780101001",
  ) // CONVERT_18_15|110101780101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101790101001", 2026),
    "110101790101001",
  ) // CONVERT_18_15|110101790101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101800101001", 2026),
    "110101800101001",
  ) // CONVERT_18_15|110101800101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101810101001", 2026),
    "110101810101001",
  ) // CONVERT_18_15|110101810101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101820101001", 2026),
    "110101820101001",
  ) // CONVERT_18_15|110101820101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101830101001", 2026),
    "110101830101001",
  ) // CONVERT_18_15|110101830101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101840101001", 2026),
    "110101840101001",
  ) // CONVERT_18_15|110101840101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101850101001", 2026),
    "110101850101001",
  ) // CONVERT_18_15|110101850101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101860101001", 2026),
    "110101860101001",
  ) // CONVERT_18_15|110101860101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101870101001", 2026),
    "110101870101001",
  ) // CONVERT_18_15|110101870101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101880101001", 2026),
    "110101880101001",
  ) // CONVERT_18_15|110101880101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101890101001", 2026),
    "110101890101001",
  ) // CONVERT_18_15|110101890101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101900101001", 2026),
    "110101900101001",
  ) // CONVERT_18_15|110101900101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101910101001", 2026),
    "110101910101001",
  ) // CONVERT_18_15|110101910101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101920101001", 2026),
    "110101920101001",
  ) // CONVERT_18_15|110101920101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101930101001", 2026),
    "110101930101001",
  ) // CONVERT_18_15|110101930101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101940101001", 2026),
    "110101940101001",
  ) // CONVERT_18_15|110101940101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101950101001", 2026),
    "110101950101001",
  ) // CONVERT_18_15|110101950101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101960101001", 2026),
    "110101960101001",
  ) // CONVERT_18_15|110101960101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101970101001", 2026),
    "110101970101001",
  ) // CONVERT_18_15|110101970101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101980101001", 2026),
    "110101980101001",
  ) // CONVERT_18_15|110101980101001
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196503125235", 2026),
    "110101196503125235",
  ) // CONVERT_18_15|110101196503125235
  assert_eq(
    @typex.idcard_convert_18_to_15("11010119650312523X", 2026),
    "11010119650312523X",
  ) // CONVERT_18_15|11010119650312523X
  assert_eq(
    @typex.idcard_convert_18_to_15("1101011965031252 4", 2026),
    "1101011965031252 4",
  ) // CONVERT_18_15|1101011965031252 4
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196513125234", 2026),
    "110101196513125234",
  ) // CONVERT_18_15|110101196513125234
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196502315234", 2026),
    "110101196502315234",
  ) // CONVERT_18_15|110101196502315234
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196502295234", 2026),
    "110101196502295234",
  ) // CONVERT_18_15|110101196502295234
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196504315234", 2026),
    "110101196504315234",
  ) // CONVERT_18_15|110101196504315234
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196500125234", 2026),
    "110101196500125234",
  ) // CONVERT_18_15|110101196500125234
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196513015234", 2026),
    "110101196513015234",
  ) // CONVERT_18_15|110101196513015234
  assert_eq(
    @typex.idcard_convert_18_to_15("1101011965031252", 2026),
    "1101011965031252",
  ) // CONVERT_18_15|1101011965031252
  assert_eq(
    @typex.idcard_convert_18_to_15("1101011965031252344", 2026),
    "1101011965031252344",
  ) // CONVERT_18_15|1101011965031252344
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196503125234X", 2026),
    "110101196503125234X",
  ) // CONVERT_18_15|110101196503125234X
  assert_eq(
    @typex.idcard_convert_18_to_15("99010119650312523X", 2026),
    "99010119650312523X",
  ) // CONVERT_18_15|99010119650312523X
  assert_eq(
    @typex.idcard_convert_18_to_15("000000000000000000", 2026),
    "000000000000000000",
  ) // CONVERT_18_15|000000000000000000
  assert_eq(
    @typex.idcard_convert_18_to_15("999999999999999999", 2026),
    "999999999999999999",
  ) // CONVERT_18_15|999999999999999999
  assert_eq(
    @typex.idcard_convert_18_to_15("11010119650312523A", 2026),
    "11010119650312523A",
  ) // CONVERT_18_15|11010119650312523A
  assert_eq(
    @typex.idcard_convert_18_to_15("11010165031252X", 2026),
    "11010165031252X",
  ) // CONVERT_18_15|11010165031252X
  assert_eq(
    @typex.idcard_convert_18_to_15("11010165031252a", 2026),
    "11010165031252a",
  ) // CONVERT_18_15|11010165031252a
  assert_eq(
    @typex.idcard_convert_18_to_15("11010165031252", 2026),
    "11010165031252",
  ) // CONVERT_18_15|11010165031252
  assert_eq(
    @typex.idcard_convert_18_to_15("1101016503125234", 2026),
    "1101016503125234",
  ) // CONVERT_18_15|1101016503125234
  assert_eq(@typex.idcard_convert_18_to_15("", 2026), "") // CONVERT_18_15|
  assert_eq(@typex.idcard_convert_18_to_15(" ", 2026), " ") // CONVERT_18_15| 
  assert_eq(@typex.idcard_convert_18_to_15("\t", 2026), "\t") // CONVERT_18_15|	
  assert_eq(
    @typex.idcard_convert_18_to_15("1101011965031252x", 2026),
    "1101011965031252x",
  ) // CONVERT_18_15|1101011965031252x
  assert_eq(
    @typex.idcard_convert_18_to_15("81000019650312523X", 2026),
    "81000019650312523X",
  ) // CONVERT_18_15|81000019650312523X
  assert_eq(
    @typex.idcard_convert_18_to_15("820000196503125235", 2026),
    "820000196503125235",
  ) // CONVERT_18_15|820000196503125235
  assert_eq(
    @typex.idcard_convert_18_to_15("830000196503125234", 2026),
    "830000196503125234",
  ) // CONVERT_18_15|830000196503125234
  assert_eq(
    @typex.idcard_convert_18_to_15("710000196503125233", 2026),
    "710000196503125233",
  ) // CONVERT_18_15|710000196503125233
  assert_eq(
    @typex.idcard_convert_18_to_15("910000196503125232", 2026),
    "910000196503125232",
  ) // CONVERT_18_15|910000196503125232
  assert_eq(
    @typex.idcard_convert_18_to_15("11010119650312000X", 2026),
    "110101650312000",
  ) // CONVERT_18_15|11010119650312000X
  assert_eq(
    @typex.idcard_convert_18_to_15("11010119650312000x", 2026),
    "110101650312000",
  ) // CONVERT_18_15|11010119650312000x
  assert_eq(
    @typex.idcard_convert_18_to_15("110101190002295234", 2026),
    "110101190002295234",
  ) // CONVERT_18_15|110101190002295234
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196602295235", 2026),
    "110101196602295235",
  ) // CONVERT_18_15|110101196602295235
  assert_eq(
    @typex.idcard_convert_18_to_15("110101199602295239", 2026),
    "110101960229523",
  ) // CONVERT_18_15|110101199602295239
  assert_eq(
    @typex.idcard_convert_18_to_15("110101190002285239", 2026),
    "110101000228523",
  ) // CONVERT_18_15|110101190002285239
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196506315232", 2026),
    "110101196506315232",
  ) // CONVERT_18_15|110101196506315232
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196507315234", 2026),
    "110101650731523",
  ) // CONVERT_18_15|110101196507315234
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196504315239", 2026),
    "110101196504315239",
  ) // CONVERT_18_15|110101196504315239
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196513015238", 2026),
    "110101196513015238",
  ) // CONVERT_18_15|110101196513015238
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196500125235", 2026),
    "110101196500125235",
  ) // CONVERT_18_15|110101196500125235
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196512325234", 2026),
    "110101196512325234",
  ) // CONVERT_18_15|110101196512325234
  assert_eq(
    @typex.idcard_convert_18_to_15("210101196503125230", 2026),
    "210101196503125230",
  ) // CONVERT_18_15|210101196503125230
  assert_eq(
    @typex.idcard_convert_18_to_15("120101196503125230", 2026),
    "120101196503125230",
  ) // CONVERT_18_15|120101196503125230
  assert_eq(
    @typex.idcard_convert_18_to_15("111101196503125230", 2026),
    "111101196503125230",
  ) // CONVERT_18_15|111101196503125230
  assert_eq(
    @typex.idcard_convert_18_to_15("110201196503125230", 2026),
    "110201196503125230",
  ) // CONVERT_18_15|110201196503125230
  assert_eq(
    @typex.idcard_convert_18_to_15("110111196503125230", 2026),
    "110111196503125230",
  ) // CONVERT_18_15|110111196503125230
  assert_eq(
    @typex.idcard_convert_18_to_15("110102196503125230", 2026),
    "110102196503125230",
  ) // CONVERT_18_15|110102196503125230
  assert_eq(
    @typex.idcard_convert_18_to_15("110101296503125230", 2026),
    "110101296503125230",
  ) // CONVERT_18_15|110101296503125230
  assert_eq(
    @typex.idcard_convert_18_to_15("1101011X6503125230", 2026),
    "1101011X6503125230",
  ) // CONVERT_18_15|1101011X6503125230
  assert_eq(
    @typex.idcard_convert_18_to_15("110101197503125230", 2026),
    "110101197503125230",
  ) // CONVERT_18_15|110101197503125230
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196603125230", 2026),
    "110101196603125230",
  ) // CONVERT_18_15|110101196603125230
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196513125230", 2026),
    "110101196513125230",
  ) // CONVERT_18_15|110101196513125230
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196504125230", 2026),
    "110101196504125230",
  ) // CONVERT_18_15|110101196504125230
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196503225230", 2026),
    "110101196503225230",
  ) // CONVERT_18_15|110101196503225230
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196503135230", 2026),
    "110101196503135230",
  ) // CONVERT_18_15|110101196503135230
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196503126230", 2026),
    "110101196503126230",
  ) // CONVERT_18_15|110101196503126230
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196503125330", 2026),
    "110101196503125330",
  ) // CONVERT_18_15|110101196503125330
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196503125240", 2026),
    "110101196503125240",
  ) // CONVERT_18_15|110101196503125240
  assert_eq(
    @typex.idcard_convert_18_to_15("110101196503125231", 2026),
    "110101196503125231",
  ) // CONVERT_18_15|110101196503125231
  assert_eq(
    @typex.idcard_convert_18_to_15("240203196503125242", 2026),
    "240203196503125242",
  ) // CONVERT_18_15|240203196503125242
  assert_eq(
    @typex.idcard_convert_18_to_15("150203196503125242", 2026),
    "150203196503125242",
  ) // CONVERT_18_15|150203196503125242
  assert_eq(
    @typex.idcard_convert_18_to_15("141203196503125242", 2026),
    "141203196503125242",
  ) // CONVERT_18_15|141203196503125242
  assert_eq(
    @typex.idcard_convert_18_to_15("140303196503125242", 2026),
    "140303196503125242",
  ) // CONVERT_18_15|140303196503125242
  assert_eq(
    @typex.idcard_convert_18_to_15("140213196503125242", 2026),
    "140213196503125242",
  ) // CONVERT_18_15|140213196503125242
  assert_eq(
    @typex.idcard_convert_18_to_15("140204196503125242", 2026),
    "140204196503125242",
  ) // CONVERT_18_15|140204196503125242
  assert_eq(
    @typex.idcard_convert_18_to_15("140203296503125242", 2026),
    "140203296503125242",
  ) // CONVERT_18_15|140203296503125242
  assert_eq(
    @typex.idcard_convert_18_to_15("1402031X6503125242", 2026),
    "1402031X6503125242",
  ) // CONVERT_18_15|1402031X6503125242
  assert_eq(
    @typex.idcard_convert_18_to_15("140203197503125242", 2026),
    "140203197503125242",
  ) // CONVERT_18_15|140203197503125242
  assert_eq(
    @typex.idcard_convert_18_to_15("140203196603125242", 2026),
    "140203196603125242",
  ) // CONVERT_18_15|140203196603125242
  assert_eq(
    @typex.idcard_convert_18_to_15("140203196513125242", 2026),
    "140203196513125242",
  ) // CONVERT_18_15|140203196513125242
  assert_eq(
    @typex.idcard_convert_18_to_15("140203196504125242", 2026),
    "140203196504125242",
  ) // CONVERT_18_15|140203196504125242
  assert_eq(
    @typex.idcard_convert_18_to_15("140203196503225242", 2026),
    "140203196503225242",
  ) // CONVERT_18_15|140203196503225242
  assert_eq(
    @typex.idcard_convert_18_to_15("140203196503135242", 2026),
    "140203196503135242",
  ) // CONVERT_18_15|140203196503135242
  assert_eq(
    @typex.idcard_convert_18_to_15("140203196503126242", 2026),
    "140203196503126242",
  ) // CONVERT_18_15|140203196503126242
  assert_eq(
    @typex.idcard_convert_18_to_15("140203196503125342", 2026),
    "140203196503125342",
  ) // CONVERT_18_15|140203196503125342
  assert_eq(
    @typex.idcard_convert_18_to_15("140203196503125252", 2026),
    "140203196503125252",
  ) // CONVERT_18_15|140203196503125252
  assert_eq(
    @typex.idcard_convert_18_to_15("140203196503125243", 2026),
    "140203196503125243",
  ) // CONVERT_18_15|140203196503125243
}

///|
test "Idcard 十五转十八的日期无效档（参照抛 DateException，本库并入 None）" {
  assert_eq(@typex.idcard_convert_15_to_18("110101650229523"), None) // CONVERT_15_18|110101650229523
  assert_eq(@typex.idcard_convert_15_to_18("110101651331523"), None) // CONVERT_15_18|110101651331523
  assert_eq(@typex.idcard_convert_15_to_18("110101000000001"), None) // CONVERT_15_18|110101000000001
  assert_eq(@typex.idcard_convert_15_to_18("110101999999999"), None) // CONVERT_15_18|110101999999999
  assert_eq(
    @typex.idcard_convert_15_to_18("110101650312523"),
    Some("110101196503125230"),
  ) // CONVERT_15_18|对照：日期有效
  assert_eq(
    @typex.idcard_convert_15_to_18("990101650312523"),
    Some("990101196503125234"),
  ) // CONVERT_15_18|对照：省码不在表内也不管（参照不管）
  assert_eq(
    @typex.idcard_convert_15_to_18("110101000101001"),
    Some("110101200001010010"),
  ) // CONVERT_15_18|世纪档 yy=00 → 2000
}
