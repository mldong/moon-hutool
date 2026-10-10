///|
/// 批③ 片一（Caesar）的期望面：**全部由腿灌，手打零条**。
/// 契约 `docs/spec/05-codec.md` §13；腿 `scripts/CaesarLeg.java`。
/// 此刻函数体是 `PR-B：契约骨架` 的 abort ⇒ 这批用例红是设计态（门禁 G5：落地笔只许把红变绿）。

///|
/// 由码位数组现造夹具与期望串。
fn cc3(codes : Array[Int]) -> String {
  let out : Array[Char] = []
  for c in codes {
    match c.to_char() {
      Some(ch) => out.push(ch)
      None => abort("夹具码位非法：" + c.to_string())
    }
  }
  String::from_array(out)
}

// 到不了档（不落断言，理由与读数在 spec §13.4）：参照对 `null` 入参抛——
//   ERR:java.lang.IllegalArgumentException:message must be not null!
//   ERR:java.lang.IllegalArgumentException:cipherText must be not null!
// 本库入参是 `String`（非空类型），这一档结构上到不了；造个假错误反而是发明语义。

///|
test "codec #13.1 caesar_table：52 字符交替表（不是 A-Z 再 a-z）" {
  assert_eq(@codec.caesar_table.length(), 52) // 读数腿  CC|table-len
  assert_eq(
    @codec.caesar_table,
    cc3([
      65, 97, 66, 98, 67, 99, 68, 100, 69, 101, 70, 102, 71, 103, 72, 104, 73, 105,
      74, 106, 75, 107, 76, 108, 77, 109, 78, 110, 79, 111, 80, 112, 81, 113, 82,
      114, 83, 115, 84, 116, 85, 117, 86, 118, 87, 119, 88, 120, 89, 121, 90, 122,
    ]),
  ) // 读数腿  CC|table-codes
}

///|
test "codec #13.1 encode shift=-104（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), -104), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_encode(cc3([65]), -104), cc3([65])) // 读数腿  夹具 A
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([97]), -104)),
    "ShiftUnderflow -51",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -51  夹具 a
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([90]), -104)),
    "ShiftUnderflow -2",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -2  夹具 Z
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([122]), -104)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 z
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65, 97, 90, 122]), -104)),
    "ShiftUnderflow -51",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -51  夹具 AaZz
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), -104)),
    "ShiftUnderflow -49",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -49  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), -104), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), -104), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), -104), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), -104), cc3([33])) // 读数腿  夹具 !
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([20013]), -104)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u4e2d
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([233]), -104)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u00e9
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([937]), -104)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u03a9
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([223]), -104)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u00df
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([1488]), -104)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), -104), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), -104), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), -104), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(
    @codec.caesar_encode(cc3([55357, 56832]), -104),
    cc3([55357, 56832]),
  ) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    err_text(() => {
      @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), -104)
    }),
    "ShiftUnderflow -44",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -44  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=-52（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), -52), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_encode(cc3([65]), -52), cc3([65])) // 读数腿  夹具 A
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([97]), -52)),
    "ShiftUnderflow -51",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -51  夹具 a
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([90]), -52)),
    "ShiftUnderflow -2",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -2  夹具 Z
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([122]), -52)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 z
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65, 97, 90, 122]), -52)),
    "ShiftUnderflow -51",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -51  夹具 AaZz
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), -52)),
    "ShiftUnderflow -49",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -49  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), -52), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), -52), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), -52), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), -52), cc3([33])) // 读数腿  夹具 !
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([20013]), -52)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u4e2d
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([233]), -52)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u00e9
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([937]), -52)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u03a9
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([223]), -52)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u00df
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([1488]), -52)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), -52), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), -52), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), -52), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), -52), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), -52)),
    "ShiftUnderflow -44",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -44  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=-26（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), -26), cc3([])) // 读数腿  夹具 
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65]), -26)),
    "ShiftUnderflow -26",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -26  夹具 A
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([97]), -26)),
    "ShiftUnderflow -25",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -25  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), -26), cc3([77])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), -26), cc3([109])) // 读数腿  夹具 z
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65, 97, 90, 122]), -26)),
    "ShiftUnderflow -26",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -26  夹具 AaZz
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), -26)),
    "ShiftUnderflow -26",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -26  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), -26), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), -26), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), -26), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), -26), cc3([33])) // 读数腿  夹具 !
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([20013]), -26)),
    "ShiftUnderflow -27",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -27  夹具 \u4e2d
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([233]), -26)),
    "ShiftUnderflow -27",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -27  夹具 \u00e9
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([937]), -26)),
    "ShiftUnderflow -27",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -27  夹具 \u03a9
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([223]), -26)),
    "ShiftUnderflow -27",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -27  夹具 \u00df
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([1488]), -26)),
    "ShiftUnderflow -27",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -27  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), -26), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), -26), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), -26), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), -26), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), -26)),
    "ShiftUnderflow -18",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -18  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=-13（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), -13), cc3([])) // 读数腿  夹具 
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65]), -13)),
    "ShiftUnderflow -13",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -13  夹具 A
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([97]), -13)),
    "ShiftUnderflow -12",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -12  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), -13), cc3([115])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), -13), cc3([84])) // 读数腿  夹具 z
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65, 97, 90, 122]), -13)),
    "ShiftUnderflow -13",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -13  夹具 AaZz
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), -13)),
    "ShiftUnderflow -13",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -13  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), -13), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), -13), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), -13), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), -13), cc3([33])) // 读数腿  夹具 !
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([20013]), -13)),
    "ShiftUnderflow -14",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -14  夹具 \u4e2d
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([233]), -13)),
    "ShiftUnderflow -14",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -14  夹具 \u00e9
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([937]), -13)),
    "ShiftUnderflow -14",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -14  夹具 \u03a9
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([223]), -13)),
    "ShiftUnderflow -14",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -14  夹具 \u00df
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([1488]), -13)),
    "ShiftUnderflow -14",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -14  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), -13), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), -13), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), -13), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), -13), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), -13)),
    "ShiftUnderflow -5",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -5  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=-1（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), -1), cc3([])) // 读数腿  夹具 
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65]), -1)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 A
  assert_eq(@codec.caesar_encode(cc3([97]), -1), cc3([65])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), -1), cc3([121])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), -1), cc3([90])) // 读数腿  夹具 z
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65, 97, 90, 122]), -1)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 AaZz
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), -1)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), -1), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), -1), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), -1), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), -1), cc3([33])) // 读数腿  夹具 !
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([20013]), -1)),
    "ShiftUnderflow -2",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -2  夹具 \u4e2d
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([233]), -1)),
    "ShiftUnderflow -2",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -2  夹具 \u00e9
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([937]), -1)),
    "ShiftUnderflow -2",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -2  夹具 \u03a9
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([223]), -1)),
    "ShiftUnderflow -2",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -2  夹具 \u00df
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([1488]), -1)),
    "ShiftUnderflow -2",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -2  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), -1), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), -1), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), -1), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), -1), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), -1)),
    "ShiftUnderflow -2",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -2  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=0（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), 0), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_encode(cc3([65]), 0), cc3([65])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_encode(cc3([97]), 0), cc3([97])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), 0), cc3([90])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), 0), cc3([122])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_encode(cc3([65, 97, 90, 122]), 0),
    cc3([65, 97, 90, 122]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 0),
    cc3([65, 98, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), 0), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), 0), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), 0), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), 0), cc3([33])) // 读数腿  夹具 !
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([20013]), 0)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u4e2d
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([233]), 0)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u00e9
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([937]), 0)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u03a9
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([223]), 0)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u00df
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([1488]), 0)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), 0), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), 0), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), 0), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), 0), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    err_text(() => @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 0)),
    "ShiftUnderflow -1",
  ) // 抛档 StringIndexOutOfBoundsException ⇒ String index out of range: -1  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=1（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), 1), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_encode(cc3([65]), 1), cc3([97])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_encode(cc3([97]), 1), cc3([66])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), 1), cc3([122])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), 1), cc3([65])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_encode(cc3([65, 97, 90, 122]), 1),
    cc3([97, 66, 122, 65]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 1),
    cc3([97, 67, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), 1), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), 1), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), 1), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), 1), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_encode(cc3([20013]), 1), cc3([65])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_encode(cc3([233]), 1), cc3([65])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_encode(cc3([937]), 1), cc3([65])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_encode(cc3([223]), 1), cc3([65])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_encode(cc3([1488]), 1), cc3([65])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), 1), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), 1), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), 1), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), 1), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 1),
    cc3([101, 78, 80, 75, 74, 65]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=2（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), 2), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_encode(cc3([65]), 2), cc3([66])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_encode(cc3([97]), 2), cc3([98])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), 2), cc3([65])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), 2), cc3([97])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_encode(cc3([65, 97, 90, 122]), 2),
    cc3([66, 98, 65, 97]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 2),
    cc3([66, 99, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), 2), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), 2), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), 2), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), 2), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_encode(cc3([20013]), 2), cc3([97])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_encode(cc3([233]), 2), cc3([97])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_encode(cc3([937]), 2), cc3([97])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_encode(cc3([223]), 2), cc3([97])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_encode(cc3([1488]), 2), cc3([97])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), 2), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), 2), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), 2), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), 2), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 2),
    cc3([70, 110, 112, 107, 106, 97]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=13（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), 13), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_encode(cc3([65]), 13), cc3([103])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_encode(cc3([97]), 13), cc3([72])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), 13), cc3([102])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), 13), cc3([71])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_encode(cc3([65, 97, 90, 122]), 13),
    cc3([103, 72, 102, 71]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 13),
    cc3([103, 73, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), 13), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), 13), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), 13), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), 13), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_encode(cc3([20013]), 13), cc3([71])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_encode(cc3([233]), 13), cc3([71])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_encode(cc3([937]), 13), cc3([71])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_encode(cc3([223]), 13), cc3([71])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_encode(cc3([1488]), 13), cc3([71])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), 13), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), 13), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), 13), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), 13), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 13),
    cc3([107, 84, 86, 81, 80, 71]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=25（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), 25), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_encode(cc3([65]), 25), cc3([109])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_encode(cc3([97]), 25), cc3([78])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), 25), cc3([108])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), 25), cc3([77])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_encode(cc3([65, 97, 90, 122]), 25),
    cc3([109, 78, 108, 77]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 25),
    cc3([109, 79, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), 25), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), 25), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), 25), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), 25), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_encode(cc3([20013]), 25), cc3([77])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_encode(cc3([233]), 25), cc3([77])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_encode(cc3([937]), 25), cc3([77])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_encode(cc3([223]), 25), cc3([77])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_encode(cc3([1488]), 25), cc3([77])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), 25), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), 25), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), 25), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), 25), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 25),
    cc3([113, 90, 66, 87, 86, 77]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=26（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), 26), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_encode(cc3([65]), 26), cc3([78])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_encode(cc3([97]), 26), cc3([110])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), 26), cc3([77])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), 26), cc3([109])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_encode(cc3([65, 97, 90, 122]), 26),
    cc3([78, 110, 77, 109]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 26),
    cc3([78, 111, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), 26), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), 26), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), 26), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), 26), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_encode(cc3([20013]), 26), cc3([109])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_encode(cc3([233]), 26), cc3([109])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_encode(cc3([937]), 26), cc3([109])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_encode(cc3([223]), 26), cc3([109])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_encode(cc3([1488]), 26), cc3([109])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), 26), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), 26), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), 26), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), 26), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 26),
    cc3([82, 122, 98, 119, 118, 109]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=27（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), 27), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_encode(cc3([65]), 27), cc3([110])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_encode(cc3([97]), 27), cc3([79])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), 27), cc3([109])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), 27), cc3([78])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_encode(cc3([65, 97, 90, 122]), 27),
    cc3([110, 79, 109, 78]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 27),
    cc3([110, 80, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), 27), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), 27), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), 27), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), 27), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_encode(cc3([20013]), 27), cc3([78])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_encode(cc3([233]), 27), cc3([78])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_encode(cc3([937]), 27), cc3([78])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_encode(cc3([223]), 27), cc3([78])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_encode(cc3([1488]), 27), cc3([78])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), 27), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), 27), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), 27), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), 27), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 27),
    cc3([114, 65, 67, 88, 87, 78]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=52（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), 52), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_encode(cc3([65]), 52), cc3([65])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_encode(cc3([97]), 52), cc3([97])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), 52), cc3([90])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), 52), cc3([122])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_encode(cc3([65, 97, 90, 122]), 52),
    cc3([65, 97, 90, 122]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 52),
    cc3([65, 98, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), 52), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), 52), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), 52), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), 52), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_encode(cc3([20013]), 52), cc3([122])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_encode(cc3([233]), 52), cc3([122])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_encode(cc3([937]), 52), cc3([122])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_encode(cc3([223]), 52), cc3([122])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_encode(cc3([1488]), 52), cc3([122])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), 52), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), 52), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), 52), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), 52), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 52),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=53（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), 53), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_encode(cc3([65]), 53), cc3([97])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_encode(cc3([97]), 53), cc3([66])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), 53), cc3([122])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), 53), cc3([65])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_encode(cc3([65, 97, 90, 122]), 53),
    cc3([97, 66, 122, 65]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 53),
    cc3([97, 67, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), 53), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), 53), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), 53), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), 53), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_encode(cc3([20013]), 53), cc3([65])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_encode(cc3([233]), 53), cc3([65])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_encode(cc3([937]), 53), cc3([65])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_encode(cc3([223]), 53), cc3([65])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_encode(cc3([1488]), 53), cc3([65])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), 53), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), 53), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), 53), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), 53), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 53),
    cc3([101, 78, 80, 75, 74, 65]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 encode shift=104（21 档夹具逐个点名）" {
  assert_eq(@codec.caesar_encode(cc3([]), 104), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_encode(cc3([65]), 104), cc3([65])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_encode(cc3([97]), 104), cc3([97])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_encode(cc3([90]), 104), cc3([90])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_encode(cc3([122]), 104), cc3([122])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_encode(cc3([65, 97, 90, 122]), 104),
    cc3([65, 97, 90, 122]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 104),
    cc3([65, 98, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_encode(cc3([48]), 104), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_encode(cc3([57]), 104), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_encode(cc3([32]), 104), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_encode(cc3([33]), 104), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_encode(cc3([20013]), 104), cc3([122])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_encode(cc3([233]), 104), cc3([122])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_encode(cc3([937]), 104), cc3([122])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_encode(cc3([223]), 104), cc3([122])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_encode(cc3([1488]), 104), cc3([122])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_encode(cc3([1635]), 104), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_encode(cc3([0]), 104), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_encode(cc3([9]), 104), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_encode(cc3([55357, 56832]), 104), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 104),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=-104（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), -104), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), -104), cc3([65])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), -104), cc3([97])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), -104), cc3([90])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), -104), cc3([122])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), -104),
    cc3([65, 97, 90, 122]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), -104),
    cc3([65, 98, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), -104), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), -104), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), -104), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), -104), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), -104), cc3([122])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), -104), cc3([122])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), -104), cc3([122])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), -104), cc3([122])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), -104), cc3([122])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), -104), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), -104), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), -104), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(
    @codec.caesar_decode(cc3([55357, 56832]), -104),
    cc3([55357, 56832]),
  ) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), -104),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=-52（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), -52), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), -52), cc3([65])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), -52), cc3([97])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), -52), cc3([90])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), -52), cc3([122])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), -52),
    cc3([65, 97, 90, 122]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), -52),
    cc3([65, 98, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), -52), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), -52), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), -52), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), -52), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), -52), cc3([122])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), -52), cc3([122])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), -52), cc3([122])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), -52), cc3([122])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), -52), cc3([122])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), -52), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), -52), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), -52), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), -52), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), -52),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=-26（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), -26), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), -26), cc3([78])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), -26), cc3([110])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), -26), cc3([77])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), -26), cc3([109])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), -26),
    cc3([78, 110, 77, 109]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), -26),
    cc3([78, 111, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), -26), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), -26), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), -26), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), -26), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), -26), cc3([109])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), -26), cc3([109])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), -26), cc3([109])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), -26), cc3([109])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), -26), cc3([109])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), -26), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), -26), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), -26), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), -26), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), -26),
    cc3([82, 122, 98, 119, 118, 109]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=-13（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), -13), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), -13), cc3([103])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), -13), cc3([72])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), -13), cc3([102])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), -13), cc3([71])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), -13),
    cc3([103, 72, 102, 71]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), -13),
    cc3([103, 73, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), -13), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), -13), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), -13), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), -13), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), -13), cc3([71])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), -13), cc3([71])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), -13), cc3([71])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), -13), cc3([71])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), -13), cc3([71])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), -13), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), -13), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), -13), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), -13), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), -13),
    cc3([107, 84, 86, 81, 80, 71]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=-1（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), -1), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), -1), cc3([97])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), -1), cc3([66])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), -1), cc3([122])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), -1), cc3([65])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), -1),
    cc3([97, 66, 122, 65]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), -1),
    cc3([97, 67, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), -1), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), -1), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), -1), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), -1), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), -1), cc3([65])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), -1), cc3([65])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), -1), cc3([65])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), -1), cc3([65])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), -1), cc3([65])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), -1), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), -1), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), -1), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), -1), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), -1),
    cc3([101, 78, 80, 75, 74, 65]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=0（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), 0), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), 0), cc3([65])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), 0), cc3([97])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), 0), cc3([90])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), 0), cc3([122])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), 0),
    cc3([65, 97, 90, 122]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), 0),
    cc3([65, 98, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), 0), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), 0), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), 0), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), 0), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), 0), cc3([122])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), 0), cc3([122])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), 0), cc3([122])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), 0), cc3([122])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), 0), cc3([122])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), 0), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), 0), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), 0), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), 0), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), 0),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=1（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), 1), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), 1), cc3([122])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), 1), cc3([65])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), 1), cc3([121])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), 1), cc3([90])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), 1),
    cc3([122, 65, 121, 90]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), 1),
    cc3([122, 66, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), 1), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), 1), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), 1), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), 1), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), 1), cc3([90])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), 1), cc3([90])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), 1), cc3([90])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), 1), cc3([90])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), 1), cc3([90])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), 1), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), 1), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), 1), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), 1), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), 1),
    cc3([100, 77, 79, 74, 73, 90]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=2（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), 2), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), 2), cc3([90])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), 2), cc3([122])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), 2), cc3([89])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), 2), cc3([121])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), 2),
    cc3([90, 122, 89, 121]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), 2),
    cc3([90, 97, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), 2), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), 2), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), 2), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), 2), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), 2), cc3([121])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), 2), cc3([121])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), 2), cc3([121])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), 2), cc3([121])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), 2), cc3([121])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), 2), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), 2), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), 2), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), 2), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), 2),
    cc3([68, 108, 110, 105, 104, 121]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=13（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), 13), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), 13), cc3([116])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), 13), cc3([85])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), 13), cc3([115])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), 13), cc3([84])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), 13),
    cc3([116, 85, 115, 84]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), 13),
    cc3([116, 86, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), 13), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), 13), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), 13), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), 13), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), 13), cc3([84])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), 13), cc3([84])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), 13), cc3([84])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), 13), cc3([84])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), 13), cc3([84])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), 13), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), 13), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), 13), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), 13), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), 13),
    cc3([120, 71, 73, 68, 67, 84]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=25（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), 25), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), 25), cc3([110])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), 25), cc3([79])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), 25), cc3([109])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), 25), cc3([78])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), 25),
    cc3([110, 79, 109, 78]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), 25),
    cc3([110, 80, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), 25), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), 25), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), 25), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), 25), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), 25), cc3([78])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), 25), cc3([78])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), 25), cc3([78])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), 25), cc3([78])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), 25), cc3([78])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), 25), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), 25), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), 25), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), 25), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), 25),
    cc3([114, 65, 67, 88, 87, 78]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=26（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), 26), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), 26), cc3([78])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), 26), cc3([110])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), 26), cc3([77])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), 26), cc3([109])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), 26),
    cc3([78, 110, 77, 109]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), 26),
    cc3([78, 111, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), 26), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), 26), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), 26), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), 26), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), 26), cc3([109])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), 26), cc3([109])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), 26), cc3([109])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), 26), cc3([109])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), 26), cc3([109])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), 26), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), 26), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), 26), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), 26), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), 26),
    cc3([82, 122, 98, 119, 118, 109]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=27（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), 27), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), 27), cc3([109])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), 27), cc3([78])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), 27), cc3([108])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), 27), cc3([77])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), 27),
    cc3([109, 78, 108, 77]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), 27),
    cc3([109, 79, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), 27), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), 27), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), 27), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), 27), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), 27), cc3([77])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), 27), cc3([77])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), 27), cc3([77])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), 27), cc3([77])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), 27), cc3([77])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), 27), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), 27), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), 27), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), 27), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), 27),
    cc3([113, 90, 66, 87, 86, 77]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=52（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), 52), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), 52), cc3([65])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), 52), cc3([97])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), 52), cc3([90])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), 52), cc3([122])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), 52),
    cc3([65, 97, 90, 122]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), 52),
    cc3([65, 98, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), 52), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), 52), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), 52), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), 52), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), 52), cc3([122])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), 52), cc3([122])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), 52), cc3([122])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), 52), cc3([122])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), 52), cc3([122])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), 52), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), 52), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), 52), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), 52), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), 52),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=53（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), 53), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), 53), cc3([122])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), 53), cc3([65])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), 53), cc3([121])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), 53), cc3([90])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), 53),
    cc3([122, 65, 121, 90]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), 53),
    cc3([122, 66, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), 53), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), 53), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), 53), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), 53), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), 53), cc3([90])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), 53), cc3([90])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), 53), cc3([90])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), 53), cc3([90])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), 53), cc3([90])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), 53), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), 53), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), 53), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), 53), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), 53),
    cc3([100, 77, 79, 74, 73, 90]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 decode shift=104（21 档夹具；这一侧从不抛）" {
  assert_eq(@codec.caesar_decode(cc3([]), 104), cc3([])) // 读数腿  夹具 
  assert_eq(@codec.caesar_decode(cc3([65]), 104), cc3([65])) // 读数腿  夹具 A
  assert_eq(@codec.caesar_decode(cc3([97]), 104), cc3([97])) // 读数腿  夹具 a
  assert_eq(@codec.caesar_decode(cc3([90]), 104), cc3([90])) // 读数腿  夹具 Z
  assert_eq(@codec.caesar_decode(cc3([122]), 104), cc3([122])) // 读数腿  夹具 z
  assert_eq(
    @codec.caesar_decode(cc3([65, 97, 90, 122]), 104),
    cc3([65, 97, 90, 122]),
  ) // 读数腿  夹具 AaZz
  assert_eq(
    @codec.caesar_decode(cc3([65, 98, 57, 33, 32]), 104),
    cc3([65, 98, 57, 33, 32]),
  ) // 读数腿  夹具 Ab9! 
  assert_eq(@codec.caesar_decode(cc3([48]), 104), cc3([48])) // 读数腿  夹具 0
  assert_eq(@codec.caesar_decode(cc3([57]), 104), cc3([57])) // 读数腿  夹具 9
  assert_eq(@codec.caesar_decode(cc3([32]), 104), cc3([32])) // 读数腿  夹具  
  assert_eq(@codec.caesar_decode(cc3([33]), 104), cc3([33])) // 读数腿  夹具 !
  assert_eq(@codec.caesar_decode(cc3([20013]), 104), cc3([122])) // 读数腿  夹具 \u4e2d
  assert_eq(@codec.caesar_decode(cc3([233]), 104), cc3([122])) // 读数腿  夹具 \u00e9
  assert_eq(@codec.caesar_decode(cc3([937]), 104), cc3([122])) // 读数腿  夹具 \u03a9
  assert_eq(@codec.caesar_decode(cc3([223]), 104), cc3([122])) // 读数腿  夹具 \u00df
  assert_eq(@codec.caesar_decode(cc3([1488]), 104), cc3([122])) // 读数腿  夹具 \u05d0
  assert_eq(@codec.caesar_decode(cc3([1635]), 104), cc3([1635])) // 读数腿  夹具 \u0663
  assert_eq(@codec.caesar_decode(cc3([0]), 104), cc3([0])) // 读数腿  夹具 \u0000
  assert_eq(@codec.caesar_decode(cc3([9]), 104), cc3([9])) // 读数腿  夹具 \u0009
  assert_eq(@codec.caesar_decode(cc3([55357, 56832]), 104), cc3([55357, 56832])) // 读数腿  夹具 \ud83d\ude00
  assert_eq(
    @codec.caesar_decode(cc3([69, 109, 111, 106, 105, 233]), 104),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  夹具 Emoji\u00e9
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=-104：10/21 档复原，其余逐个点名" {
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([]), -104), -104),
    cc3([]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65]), -104), -104),
    cc3([65]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), -104), -104),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), -104), -104),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), -104), -104),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), -104), -104),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), -104), -104),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), -104), -104),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), -104), -104),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), -104), -104),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=-52：10/21 档复原，其余逐个点名" {
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([]), -52), -52),
    cc3([]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65]), -52), -52),
    cc3([65]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), -52), -52),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), -52), -52),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), -52), -52),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), -52), -52),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), -52), -52),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), -52), -52),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), -52), -52),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), -52), -52),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=-26：11/21 档复原，其余逐个点名" {
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([]), -26), -26),
    cc3([]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), -26), -26),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), -26), -26),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), -26), -26),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), -26), -26),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), -26), -26),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), -26), -26),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), -26), -26),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), -26), -26),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), -26), -26),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), -26), -26),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=-13：11/21 档复原，其余逐个点名" {
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([]), -13), -13),
    cc3([]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), -13), -13),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), -13), -13),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), -13), -13),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), -13), -13),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), -13), -13),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), -13), -13),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), -13), -13),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), -13), -13),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), -13), -13),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), -13), -13),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=-1：12/21 档复原，其余逐个点名" {
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([]), -1), -1),
    cc3([]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([97]), -1), -1),
    cc3([97]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), -1), -1),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), -1), -1),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), -1), -1),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), -1), -1),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), -1), -1),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), -1), -1),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), -1), -1),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), -1), -1),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), -1), -1),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), -1), -1),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=0：15/21 档复原，其余逐个点名" {
  assert_eq(@codec.caesar_decode(@codec.caesar_encode(cc3([]), 0), 0), cc3([])) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65]), 0), 0),
    cc3([65]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([97]), 0), 0),
    cc3([97]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), 0), 0),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), 0), 0),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 97, 90, 122]), 0), 0),
    cc3([65, 97, 90, 122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 0), 0),
    cc3([65, 98, 57, 33, 32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), 0), 0),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), 0), 0),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), 0), 0),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), 0), 0),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), 0), 0),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), 0), 0),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), 0), 0),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), 0), 0),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=1：15/21 档复原，其余逐个点名" {
  assert_eq(@codec.caesar_decode(@codec.caesar_encode(cc3([]), 1), 1), cc3([])) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65]), 1), 1),
    cc3([65]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([97]), 1), 1),
    cc3([97]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), 1), 1),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), 1), 1),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 97, 90, 122]), 1), 1),
    cc3([65, 97, 90, 122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 1), 1),
    cc3([65, 98, 57, 33, 32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), 1), 1),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), 1), 1),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), 1), 1),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), 1), 1),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([20013]), 1), 1),
    cc3([122]),
  ) // 读数腿  不复原档 \u4e2d ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([233]), 1), 1),
    cc3([122]),
  ) // 读数腿  不复原档 \u00e9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([937]), 1), 1),
    cc3([122]),
  ) // 读数腿  不复原档 \u03a9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([223]), 1), 1),
    cc3([122]),
  ) // 读数腿  不复原档 \u00df ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1488]), 1), 1),
    cc3([122]),
  ) // 读数腿  不复原档 \u05d0 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), 1), 1),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), 1), 1),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), 1), 1),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), 1), 1),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 1),
      1,
    ),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  不复原档 Emoji\u00e9 ⇒ DIFF:Emojiz
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=2：15/21 档复原，其余逐个点名" {
  assert_eq(@codec.caesar_decode(@codec.caesar_encode(cc3([]), 2), 2), cc3([])) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65]), 2), 2),
    cc3([65]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([97]), 2), 2),
    cc3([97]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), 2), 2),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), 2), 2),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 97, 90, 122]), 2), 2),
    cc3([65, 97, 90, 122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 2), 2),
    cc3([65, 98, 57, 33, 32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), 2), 2),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), 2), 2),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), 2), 2),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), 2), 2),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([20013]), 2), 2),
    cc3([122]),
  ) // 读数腿  不复原档 \u4e2d ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([233]), 2), 2),
    cc3([122]),
  ) // 读数腿  不复原档 \u00e9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([937]), 2), 2),
    cc3([122]),
  ) // 读数腿  不复原档 \u03a9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([223]), 2), 2),
    cc3([122]),
  ) // 读数腿  不复原档 \u00df ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1488]), 2), 2),
    cc3([122]),
  ) // 读数腿  不复原档 \u05d0 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), 2), 2),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), 2), 2),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), 2), 2),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), 2), 2),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 2),
      2,
    ),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  不复原档 Emoji\u00e9 ⇒ DIFF:Emojiz
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=13：15/21 档复原，其余逐个点名" {
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([]), 13), 13),
    cc3([]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65]), 13), 13),
    cc3([65]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([97]), 13), 13),
    cc3([97]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), 13), 13),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), 13), 13),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 97, 90, 122]), 13), 13),
    cc3([65, 97, 90, 122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 13),
      13,
    ),
    cc3([65, 98, 57, 33, 32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), 13), 13),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), 13), 13),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), 13), 13),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), 13), 13),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([20013]), 13), 13),
    cc3([122]),
  ) // 读数腿  不复原档 \u4e2d ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([233]), 13), 13),
    cc3([122]),
  ) // 读数腿  不复原档 \u00e9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([937]), 13), 13),
    cc3([122]),
  ) // 读数腿  不复原档 \u03a9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([223]), 13), 13),
    cc3([122]),
  ) // 读数腿  不复原档 \u00df ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1488]), 13), 13),
    cc3([122]),
  ) // 读数腿  不复原档 \u05d0 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), 13), 13),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), 13), 13),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), 13), 13),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), 13), 13),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 13),
      13,
    ),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  不复原档 Emoji\u00e9 ⇒ DIFF:Emojiz
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=25：15/21 档复原，其余逐个点名" {
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([]), 25), 25),
    cc3([]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65]), 25), 25),
    cc3([65]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([97]), 25), 25),
    cc3([97]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), 25), 25),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), 25), 25),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 97, 90, 122]), 25), 25),
    cc3([65, 97, 90, 122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 25),
      25,
    ),
    cc3([65, 98, 57, 33, 32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), 25), 25),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), 25), 25),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), 25), 25),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), 25), 25),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([20013]), 25), 25),
    cc3([122]),
  ) // 读数腿  不复原档 \u4e2d ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([233]), 25), 25),
    cc3([122]),
  ) // 读数腿  不复原档 \u00e9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([937]), 25), 25),
    cc3([122]),
  ) // 读数腿  不复原档 \u03a9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([223]), 25), 25),
    cc3([122]),
  ) // 读数腿  不复原档 \u00df ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1488]), 25), 25),
    cc3([122]),
  ) // 读数腿  不复原档 \u05d0 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), 25), 25),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), 25), 25),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), 25), 25),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), 25), 25),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 25),
      25,
    ),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  不复原档 Emoji\u00e9 ⇒ DIFF:Emojiz
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=26：15/21 档复原，其余逐个点名" {
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([]), 26), 26),
    cc3([]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65]), 26), 26),
    cc3([65]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([97]), 26), 26),
    cc3([97]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), 26), 26),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), 26), 26),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 97, 90, 122]), 26), 26),
    cc3([65, 97, 90, 122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 26),
      26,
    ),
    cc3([65, 98, 57, 33, 32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), 26), 26),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), 26), 26),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), 26), 26),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), 26), 26),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([20013]), 26), 26),
    cc3([122]),
  ) // 读数腿  不复原档 \u4e2d ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([233]), 26), 26),
    cc3([122]),
  ) // 读数腿  不复原档 \u00e9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([937]), 26), 26),
    cc3([122]),
  ) // 读数腿  不复原档 \u03a9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([223]), 26), 26),
    cc3([122]),
  ) // 读数腿  不复原档 \u00df ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1488]), 26), 26),
    cc3([122]),
  ) // 读数腿  不复原档 \u05d0 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), 26), 26),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), 26), 26),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), 26), 26),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), 26), 26),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 26),
      26,
    ),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  不复原档 Emoji\u00e9 ⇒ DIFF:Emojiz
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=27：15/21 档复原，其余逐个点名" {
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([]), 27), 27),
    cc3([]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65]), 27), 27),
    cc3([65]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([97]), 27), 27),
    cc3([97]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), 27), 27),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), 27), 27),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 97, 90, 122]), 27), 27),
    cc3([65, 97, 90, 122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 27),
      27,
    ),
    cc3([65, 98, 57, 33, 32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), 27), 27),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), 27), 27),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), 27), 27),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), 27), 27),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([20013]), 27), 27),
    cc3([122]),
  ) // 读数腿  不复原档 \u4e2d ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([233]), 27), 27),
    cc3([122]),
  ) // 读数腿  不复原档 \u00e9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([937]), 27), 27),
    cc3([122]),
  ) // 读数腿  不复原档 \u03a9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([223]), 27), 27),
    cc3([122]),
  ) // 读数腿  不复原档 \u00df ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1488]), 27), 27),
    cc3([122]),
  ) // 读数腿  不复原档 \u05d0 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), 27), 27),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), 27), 27),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), 27), 27),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), 27), 27),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 27),
      27,
    ),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  不复原档 Emoji\u00e9 ⇒ DIFF:Emojiz
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=52：15/21 档复原，其余逐个点名" {
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([]), 52), 52),
    cc3([]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65]), 52), 52),
    cc3([65]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([97]), 52), 52),
    cc3([97]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), 52), 52),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), 52), 52),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 97, 90, 122]), 52), 52),
    cc3([65, 97, 90, 122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 52),
      52,
    ),
    cc3([65, 98, 57, 33, 32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), 52), 52),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), 52), 52),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), 52), 52),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), 52), 52),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([20013]), 52), 52),
    cc3([122]),
  ) // 读数腿  不复原档 \u4e2d ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([233]), 52), 52),
    cc3([122]),
  ) // 读数腿  不复原档 \u00e9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([937]), 52), 52),
    cc3([122]),
  ) // 读数腿  不复原档 \u03a9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([223]), 52), 52),
    cc3([122]),
  ) // 读数腿  不复原档 \u00df ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1488]), 52), 52),
    cc3([122]),
  ) // 读数腿  不复原档 \u05d0 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), 52), 52),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), 52), 52),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), 52), 52),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), 52), 52),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 52),
      52,
    ),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  不复原档 Emoji\u00e9 ⇒ DIFF:Emojiz
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=53：15/21 档复原，其余逐个点名" {
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([]), 53), 53),
    cc3([]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65]), 53), 53),
    cc3([65]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([97]), 53), 53),
    cc3([97]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), 53), 53),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), 53), 53),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 97, 90, 122]), 53), 53),
    cc3([65, 97, 90, 122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 53),
      53,
    ),
    cc3([65, 98, 57, 33, 32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), 53), 53),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), 53), 53),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), 53), 53),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), 53), 53),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([20013]), 53), 53),
    cc3([122]),
  ) // 读数腿  不复原档 \u4e2d ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([233]), 53), 53),
    cc3([122]),
  ) // 读数腿  不复原档 \u00e9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([937]), 53), 53),
    cc3([122]),
  ) // 读数腿  不复原档 \u03a9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([223]), 53), 53),
    cc3([122]),
  ) // 读数腿  不复原档 \u00df ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1488]), 53), 53),
    cc3([122]),
  ) // 读数腿  不复原档 \u05d0 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), 53), 53),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), 53), 53),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), 53), 53),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), 53), 53),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 53),
      53,
    ),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  不复原档 Emoji\u00e9 ⇒ DIFF:Emojiz
}

///|
test "codec #13.1 往返 decode(encode(x)) shift=104：15/21 档复原，其余逐个点名" {
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([]), 104), 104),
    cc3([]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65]), 104), 104),
    cc3([65]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([97]), 104), 104),
    cc3([97]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([90]), 104), 104),
    cc3([90]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([122]), 104), 104),
    cc3([122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([65, 97, 90, 122]), 104), 104),
    cc3([65, 97, 90, 122]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([65, 98, 57, 33, 32]), 104),
      104,
    ),
    cc3([65, 98, 57, 33, 32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([48]), 104), 104),
    cc3([48]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([57]), 104), 104),
    cc3([57]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([32]), 104), 104),
    cc3([32]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([33]), 104), 104),
    cc3([33]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([20013]), 104), 104),
    cc3([122]),
  ) // 读数腿  不复原档 \u4e2d ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([233]), 104), 104),
    cc3([122]),
  ) // 读数腿  不复原档 \u00e9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([937]), 104), 104),
    cc3([122]),
  ) // 读数腿  不复原档 \u03a9 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([223]), 104), 104),
    cc3([122]),
  ) // 读数腿  不复原档 \u00df ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1488]), 104), 104),
    cc3([122]),
  ) // 读数腿  不复原档 \u05d0 ⇒ DIFF:z
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([1635]), 104), 104),
    cc3([1635]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([0]), 104), 104),
    cc3([0]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([9]), 104), 104),
    cc3([9]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(@codec.caesar_encode(cc3([55357, 56832]), 104), 104),
    cc3([55357, 56832]),
  ) // 规则腿  腿 CC|rt 该行标 SAME
  assert_eq(
    @codec.caesar_decode(
      @codec.caesar_encode(cc3([69, 109, 111, 106, 105, 233]), 104),
      104,
    ),
    cc3([69, 109, 111, 106, 105, 122]),
  ) // 读数腿  不复原档 Emoji\u00e9 ⇒ DIFF:Emojiz
}
