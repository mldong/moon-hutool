///|
// moon-hutool/re —— 第二批之一：RegexPool 常量表（ROADMAP 第 10 行第二批）
// 契约真相在 `docs/spec/10-re.md` §9~§12。数据表是生成物 `re/preset_table.mbt`（两列都从腿原文 + 改写规则表推导）。

///|
/// #10.25 预置正则的档位。对位参照的 `cn.hutool.core.lang.RegexPool` 的 34 个 `String` 常量。
/// - Note: 这一格收的是**能机械直译的子集**（owner 10-07 定的范围）：34 条里
///   11 条是电话/身份证/车牌/信用代码这类业务码表族，归 `typex` 的码表件管（那边带校验位与地区表，
///   正则只是它们的切片之一），**不在这里收**；剩下 23 条全部由封闭规则表 R1~R7 从参照原文
///   推导出本库方言，并在 286 条样本上与参照逐条同判（判据与读数见 spec §10）
/// - Note: 档名是参照常量名按 `_` 切词的机械 Pascal 化，所以 `CHINESES` 落 `Chineses`——
///   尾缀那个 S 是参照自己的命名（`CHINESE` 单字 / `CHINESES` 一个或多个），不是拼写失误
/// - Note: `re_preset_name`(#10.26) 给回参照名，两档名的对应关系靠它，不靠这里的声明序
pub(all) enum RePreset {
  General
  Numbers
  Word
  Chinese
  Chineses
  GroupVar
  Ipv4
  Ipv6
  Money
  Email
  EmailWithChinese
  ZipCode
  Birthday
  Uri
  Url
  UrlHttp
  GeneralWithChinese
  Uuid
  UuidSimple
  MacAddress
  Hex
  Time
  ChineseName
}

///|
/// #10.26 参照常量名（大写下划线，与 `RegexPool` 的字段名逐字符同形）。
/// - Note: 存在的理由同 cron 的 `cron_part_name`(#19.7)：调用方要把本库的一档与参照的文案、
///   或与 `PatternPool` 里那个同名常量对上时需要它。腿的 R 行就是这 23 串的来源
/// - Note: 参照另有一张 `PatternPool` 的 33 个 `Pattern` 常量表，**比这里少一条**——
///   `URI` 只在 `RegexPool` 有（腿 D 行 `only_regex_pool URI`）。本库不分两张表，
///   发的是**文本**（#10.27），要编译由调用方 `compile`(#10.1)
pub fn re_preset_name(p : RePreset) -> String {
  preset_name(p)
}

///|
/// #10.27 该档的**本库方言**模式串（可直接喂 `compile`(#10.1) 与第一批全部收模式串的入口）。
/// - Note: **与参照原文不同串**——23 条里有 17 条带 core 编译不过或读法不同的写法
///   （`\d`/`\w`、`\xHH`、`CASE_INSENSITIVE` 旗标、类首的 `:`、类里边缘的裸 `-`、
///   类外裸 `]`、UTF-16 代理对），本库发的是按封闭规则表 R1~R7 推导出来的等价写法；
///   另 6 条与参照逐字同形。规则表在 `scripts/re_preset_rewrite.py`，
///   本串的生成在 `scripts/gen_re2_test.py`（人不手打字符），
///   每条规则"两侧为什么同一个集合"逐条写在 spec §10
/// - Note: 等价性不是推断：23 档 × 样本共 **286 条**判定（整串档 `matches()` 与取组档 `find()` 第 0 组）
///   与参照逐条一致，探针跑在 `wasm`/`js`/`wasm-gc` 三档（spec §10 第 3 条）
/// - Note: 未改写的那 6 档（`WORD`/`IPV6`/`URI`/`UUID_SIMPLE`/`HEX`/`CHINESE_NAME`）与参照逐字同形
pub fn re_preset_pattern(p : RePreset) -> String {
  preset_pattern(p)
}

///|
/// #10.28 用某一档判**整串**（对位参照的 `ReUtil.isMatch`，即 JDK 的 `Matcher.matches()`）。
/// - Parameters:
///   - `p`：档位
///   - `text`：待判串
/// - Returns: 整串被该档模式占满 ⇒ `true`
/// - Raises: `BadPattern` —— 本库 23 条改写串实测都能编译，这一档只可能由**引擎侧**的异常触发；
///   签名仍带 `raise`，因为入口就是第一批那批收模式串的函数同一张嘴
/// - Note: 语义是"整串被匹配"，不是"最左一段恰好占满"（与 #10.4 同一条判别，见 spec §4 第 1 条末行）
/// - Note: 多数档位是**不锚定**的（`NUMBERS`/`TIME`/`URL`/`GROUP_VAR` 这些参照原文就没写 `^…$`），
///   所以整串档对它们会大面积给 `false`——要"串里有没有"用 #10.29 或第一批的 `contains`(#10.5)
pub fn re_match_preset(p : RePreset, text : String) -> Bool raise ReError {
  is_match(preset_pattern(p), text)
}

///|
/// #10.29 用某一档取**串里第一处命中的第 0 组**（对位参照的 `ReUtil.get(pattern, text, 0)`，
/// 即 `Matcher.find()` 后的 `group()`）。
/// - Returns: 无命中 ⇒ `None`
/// - Raises: `BadPattern`（同 #10.28）
/// - Note: 参照的 `get` 在这里给的是"没找到就 `null`"，本库给 `None`——与 #10.7 同一条立场
/// - Note: 腿的 F 行就是这一档的读数来源（286 条里的一半），锚定与不锚定的差别全在里面
pub fn re_find_preset(p : RePreset, text : String) -> String? raise ReError {
  find_first(preset_pattern(p), text)
}

///|
/// #10.30 表全集，**声明序**（＝参照 `RegexPool` 的字段序，也是腿 R 行的行序）。
/// - Note: 存在的理由是把"收了哪 23 档"这件事做成可数的出口，而不是只写在文档里。
///   新增/删除一档要同时改 spec §9 的边界表与这张表的期望（门禁会红）
pub fn re_presets() -> Array[RePreset] {
  // 交副本：`Array` 是可变的，把包内那张表直接递出去等于让调用方能改常量表
  presets.copy()
}

///|
/// #10.31 取串里第一段数字。对位 `ReUtil.getFirstNumber(str)`
/// ——它内部就是 `getStr(PatternPool.NUMBERS, str, 0)`，所以这一件等价于
/// `re_find_preset(Numbers, text)`(#10.29)；单独发一件的理由是参照有这个名字，
/// 且"抓第一个数"是不关心正则的人的默认入口（spec §1 那一行挂账挂的就是它）。
///
/// - Returns: 无数字 ⇒ `None`；空串 ⇒ `None`
/// - Note: 腿的 G 行四条读数：`a20b30`→`20`、`abc`→`null`、`""`→`null`、
///   `getFirstNumber(null)`→`null`（参照对 null 入参**不崩**，走的是 `StrUtil.isEmpty` 那条短路）。
///   第四条在本库的类型上不可表达 ⇒ 不编成断言，只记在 spec §11
/// - Raises: `BadPattern` —— 这条不接模式串，正常永不触发；签名与 #10.29 同张嘴是为了让
///   "把 `Numbers` 档换成调用方自带的数字模式"这条路不改变错误面
pub fn re_first_number(text : String) -> String? raise ReError {
  find_first(preset_pattern(Numbers), text)
}
