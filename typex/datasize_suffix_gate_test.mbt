///|
// 这批断言是**本库自订契约**，不是腿读数：参照那侧 `DataSizeUtil.format(long, DataUnit)` 与
// `DataSize.parse(CharSequence, DataUnit)` 的单位参数是**枚举**，`PB`/`EB` 只存在于 `UNIT_NAMES`
// 那张七枚后缀表里、根本传不进参数 ⇒ 腿拿不到任何读数（§18.1 第二行、§15.5 同一处置）。
// 本库把单位降成后缀串（形状定案在 §15.1），就多出一档"参数不认"，定成 `raise BadText`。
// 出处一律写「自订契约」而不写腿标签；F7 变异（把那一档的 raise 改掉）就是打在这块上的。

///|
test "format_at 收到不认的后缀：PB/EB/X 一律 BadText（本库自订契约，参照类型上不可表达）" {
  // 只进 UNIT_NAMES、不在 DataUnit 枚举里的两枚
  assert_eq(
    @typex.data_size_format_at(2048L, "PB") catch {
      e => "ERR:" + etag(e)
    },
    "ERR:BadText",
  ) // 自订契约 §18.1
  assert_eq(
    @typex.data_size_format_at(2048L, "EB") catch {
      e => "ERR:" + etag(e)
    },
    "ERR:BadText",
  ) // 自订契约 §18.1
  // 表外后缀（大小写与空白都不算）
  assert_eq(
    @typex.data_size_format_at(2048L, "X") catch {
      e => "ERR:" + etag(e)
    },
    "ERR:BadText",
  ) // 自订契约 §18.1
  assert_eq(
    @typex.data_size_format_at(2048L, " PB") catch {
      e => "ERR:" + etag(e)
    },
    "ERR:BadText",
  ) // 自订契约 §18.1
  // 阳性对照：`size <= 0` 那一档**先看字节数**，所以非法后缀在它之后——参照同款
  // （`FMT_AT_KILOBYTES|0` 给 `"0"`）。这一条钉住"坏后缀不是无条件抛"，
  // 把 raise 挪到 size 闸之前就会红在这里。
  assert_eq(@typex.data_size_format_at(0L, "PB"), "0") // 自订契约 §18.1 的对照面（形状对位 FMT_AT_KILOBYTES|0）
  // 阳性对照：枚举里有的五枚照常出，说明上面四条红不是"整件都抛"
  assert_eq(@typex.data_size_format_at(1536L, "KB"), "1.5 KB") // FMT_AT_KILOBYTES|1536
}

///|
test "parse 的兜底后缀不认：只在文本没带后缀时才生效（本库自订契约，参照类型上不可表达）" {
  // 生效档：文本没后缀 ⇒ 去查兜底 ⇒ 兜底不认就 BadText
  let g1 : String = @typex.data_size_parse_bytes_with("12", "PB").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(g1, "ERR:BadText") // 自订契约 §15.5
  let g2 : String = @typex.data_size_parse_bytes_with("12", "X").to_string() catch {
    e => "ERR:" + etag(e)
  }
  assert_eq(g2, "ERR:BadText") // 自订契约 §15.5
  // 不参与档：文本自带后缀就用文本的，兜底后缀**根本不被查**
  // （这条把"逢非法参数就抛"分开钉住；同形状的可表达对照是 `PARSE_KB|5MB`⇒5242880）
  assert_eq(@typex.data_size_parse_bytes_with("12KB", "PB"), 12288L) // 自订契约 §15.5 的对照面
  // 阳性对照：兜底合法时按兜底折算（腿现读的那一格就是这条）
  assert_eq(@typex.data_size_parse_bytes_with("20", "KB"), 20480L) // PARSE_KB|20
}
