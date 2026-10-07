///|
// ini 第三批的声明档两块（10-08）——两条内部通道此前没有任何夹具走到：
// `replace_var` 的"未闭合 `${`"那一支（ini.mbt:306）与 `grouped_map_remove` 的
// "组在、键不在"那一支（ini.mbt:461）。参照在 §3 里已经把这两条规则冻成读数标签
// （`i.var_basic.*` 一族与 `g.remove.*`），换到本批这两个新形状时**没有可取的参照读数**
// （参照腿只在已登记的夹具上跑过），所以这里钉的是**本库形状 + 依据行**，不是新分岔。
// 与 `ini_props3_test.mbt` 分开成件：那件全部由腿灌入，本件手写，两者判据不同源不许混。

///|
test "ini 变量替换：未闭合的 dollar-brace 原样留着" {
  // 依据 22-ini §3 的 replaceVar 行：参照正则匹配不到 ⇒ 不替换；
  // 本库的扫描在"找不到右花括号"时把游标推过这两个字符（ini.mbt:306），落到同一个出口。
  let gm = @ini.ini_parse_with_opts("[g]\na=1\nb=x${a\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(@ini.ini_get_str(gm, "b", Some("g"), None), Some("x${a"))
}

///|
test "ini 变量替换：未闭合档不影响同组其它变量" {
  // 同一批里两个变量、一个闭合一个未闭合：闭合的照替换，未闭合的原样（顺序无关）
  let gm = @ini.ini_parse_with_opts("[g]\na=1\nb=${a}x${c\nd=${a}\n", @ini.IniParseOpts::{
    use_variable: true,
    assign_flag: '=',
  })
  assert_eq(@ini.ini_get_str(gm, "b", Some("g"), None), Some("1x${c"))
  assert_eq(@ini.ini_get_str(gm, "d", Some("g"), None), Some("1"))
}

///|
test "GroupedMap：组存在而键不存在时 remove 给 None 且容器不动" {
  // 依据 22-ini §3 的 #22.7 行（参照 `String remove(String group, String key)`：键不在 ⇒ null）；
  // 已有夹具只覆盖"组不存在"那一支（ini_test.mbt 的 缺组缺键档），本块补"组在、键不在"（ini.mbt:461）
  let gm = @ini.grouped_map_new()
  let _ = @ini.grouped_map_put(gm, Some("g"), "a", Some("1"))
  let _ = @ini.grouped_map_put(gm, Some("g"), "b", Some("2"))
  assert_eq(@ini.grouped_map_remove(gm, Some("g"), "zzz"), None)
  assert_eq(@ini.grouped_map_size(gm), 2)
  assert_eq(@ini.grouped_map_keys(gm, Some("g")), ["a", "b"])
}
