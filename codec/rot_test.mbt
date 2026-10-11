///|
/// 批③ 片一（Rot）的期望面：**全部由腿灌，手打零条**。
/// 契约 `docs/spec/05-codec.md` §13；腿 `scripts/RotLeg.java`。
/// 此刻函数体是 `PR-B：契约骨架` 的 abort ⇒ 这批用例红是设计态（门禁 G5：落地笔只许把红变绿）。

///|
/// 夹具与期望串一律由码位数组现造（`cc3` 定义在同包的 `caesar_test.mbt` 里——
/// 同包多个 `_test.mbt` 共享顶层命名空间，重复定义判 `declared twice`）。
///
/// - Note: 腿的输出是 Java 层转义（`\uXXXX` 显形非 ASCII），MoonBit 字符串里那层写法不合法，
///   所以这里一律按十进制码位现造——夹具与期望串同一条通道，杜绝手打。

///|
/// `number_support` 两档的具名常量（断言实参位上出现 `true`/`false` 字面串会被 G17 计数）
let num_on : Bool = true

///|
let num_off : Bool = false

// 到不了档（不落断言，理由与读数在 spec §13.4）：参照对 `null` 入参抛——
//   ERR:java.lang.IllegalArgumentException:message must not be null
//   ERR:java.lang.IllegalArgumentException:rot must not be null
// 两条文案不同（`message must not be null` / `rot must not be null`），留档就是为了这条：
// 参照那两个形参名不同，本库都到不了，但读数不许合并。

///|
test "codec #13.3 encode13 的默认档：number_support 实测是 true（不是 false）" {
  // 空夹具更正（期望值冻结线的合法更正笔，证据见提交信息）：腿行
  // `RT|e13|||true?1|false?1` 的 `||` 在空夹具处塌缩，生成脚本 rpartition 把判别尾巴
  // 灌成了期望值；Rot.encode13("") 循环零次必然返回空串，且尾巴 true?1|false?1 本身
  // 就读作"true 侧同、false 侧同"——两侧都是空串，这一档判别不了默认值（判别由数字夹具承担）
  assert_eq(@codec.rot13_encode(cc3([])), cc3([])) // 读数腿  RT|e13  ⇒ （空）
  assert_eq(@codec.rot_encode(cc3([]), 13, num_on), cc3([])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([65])), cc3([78])) // 读数腿  RT|e13 A ⇒ N
  assert_eq(@codec.rot_encode(cc3([65]), 13, num_on), cc3([78])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([97])), cc3([110])) // 读数腿  RT|e13 a ⇒ n
  assert_eq(@codec.rot_encode(cc3([97]), 13, num_on), cc3([110])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([90])), cc3([77])) // 读数腿  RT|e13 Z ⇒ M
  assert_eq(@codec.rot_encode(cc3([90]), 13, num_on), cc3([77])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([122])), cc3([109])) // 读数腿  RT|e13 z ⇒ m
  assert_eq(@codec.rot_encode(cc3([122]), 13, num_on), cc3([109])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([48])), cc3([51])) // 读数腿  RT|e13 0 ⇒ 3
  assert_eq(@codec.rot_encode(cc3([48]), 13, num_on), cc3([51])) // 规则腿  单参档走 true 侧
  assert_true(@codec.rot_encode(cc3([48]), 13, num_off) != cc3([51])) // 读数腿  同夹具 false 侧是 0 ⇒ 默认值只能是 true
  assert_eq(@codec.rot13_encode(cc3([57])), cc3([50])) // 读数腿  RT|e13 9 ⇒ 2
  assert_eq(@codec.rot_encode(cc3([57]), 13, num_on), cc3([50])) // 规则腿  单参档走 true 侧
  assert_true(@codec.rot_encode(cc3([57]), 13, num_off) != cc3([50])) // 读数腿  同夹具 false 侧是 9 ⇒ 默认值只能是 true
  assert_eq(@codec.rot13_encode(cc3([53])), cc3([56])) // 读数腿  RT|e13 5 ⇒ 8
  assert_eq(@codec.rot_encode(cc3([53]), 13, num_on), cc3([56])) // 规则腿  单参档走 true 侧
  assert_true(@codec.rot_encode(cc3([53]), 13, num_off) != cc3([56])) // 读数腿  同夹具 false 侧是 5 ⇒ 默认值只能是 true
  assert_eq(
    @codec.rot13_encode(cc3([97, 98, 99, 88, 89, 90])),
    cc3([110, 111, 112, 75, 76, 77]),
  ) // 读数腿  RT|e13 abcXYZ ⇒ nopKLM
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 13, num_on),
    cc3([110, 111, 112, 75, 76, 77]),
  ) // 规则腿  单参档走 true 侧
  assert_eq(
    @codec.rot13_encode(cc3([65, 66, 67, 120, 121, 122])),
    cc3([78, 79, 80, 107, 108, 109]),
  ) // 读数腿  RT|e13 ABCxyz ⇒ NOPklm
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 13, num_on),
    cc3([78, 79, 80, 107, 108, 109]),
  ) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([48, 49, 56, 57])), cc3([51, 52, 49, 50])) // 读数腿  RT|e13 0189 ⇒ 3412
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 13, num_on),
    cc3([51, 52, 49, 50]),
  ) // 规则腿  单参档走 true 侧
  assert_true(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 13, num_off) !=
    cc3([51, 52, 49, 50]),
  ) // 读数腿  同夹具 false 侧是 0189 ⇒ 默认值只能是 true
  assert_eq(
    @codec.rot13_encode(cc3([97, 48, 122, 57])),
    cc3([110, 51, 109, 50]),
  ) // 读数腿  RT|e13 a0z9 ⇒ n3m2
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 13, num_on),
    cc3([110, 51, 109, 50]),
  ) // 规则腿  单参档走 true 侧
  assert_true(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 13, num_off) !=
    cc3([110, 51, 109, 50]),
  ) // 读数腿  同夹具 false 侧是 n0m9 ⇒ 默认值只能是 true
  assert_eq(
    @codec.rot13_encode(cc3([32, 49, 33, 122, 90])),
    cc3([32, 52, 33, 109, 77]),
  ) // 读数腿  RT|e13  1!zZ ⇒  4!mM
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 13, num_on),
    cc3([32, 52, 33, 109, 77]),
  ) // 规则腿  单参档走 true 侧
  assert_true(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 13, num_off) !=
    cc3([32, 52, 33, 109, 77]),
  ) // 读数腿  同夹具 false 侧是  1!mM ⇒ 默认值只能是 true
  assert_eq(
    @codec.rot13_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
    ),
    cc3([85, 114, 121, 121, 98, 44, 32, 74, 98, 101, 121, 113, 33]),
  ) // 读数腿  RT|e13 Hello, World! ⇒ Uryyb, Jbeyq!
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      13,
      num_on,
    ),
    cc3([85, 114, 121, 121, 98, 44, 32, 74, 98, 101, 121, 113, 33]),
  ) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([20013])), cc3([20013])) // 读数腿  RT|e13 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([20013]), 13, num_on), cc3([20013])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([233])), cc3([233])) // 读数腿  RT|e13 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([233]), 13, num_on), cc3([233])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([937])), cc3([937])) // 读数腿  RT|e13 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([937]), 13, num_on), cc3([937])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([223])), cc3([223])) // 读数腿  RT|e13 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([223]), 13, num_on), cc3([223])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([1635])), cc3([1635])) // 读数腿  RT|e13 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([1635]), 13, num_on), cc3([1635])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([0])), cc3([0])) // 读数腿  RT|e13 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([0]), 13, num_on), cc3([0])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([9])), cc3([9])) // 读数腿  RT|e13 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([9]), 13, num_on), cc3([9])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([91])), cc3([91])) // 读数腿  RT|e13 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([91]), 13, num_on), cc3([91])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([96])), cc3([96])) // 读数腿  RT|e13 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([96]), 13, num_on), cc3([96])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([58])), cc3([58])) // 读数腿  RT|e13 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([58]), 13, num_on), cc3([58])) // 规则腿  单参档走 true 侧
  assert_eq(@codec.rot13_encode(cc3([64])), cc3([64])) // 读数腿  RT|e13 @ ⇒ @
  assert_eq(@codec.rot_encode(cc3([64]), 13, num_on), cc3([64])) // 规则腿  单参档走 true 侧
  // 判别档共 7 条：不含数字的夹具两侧同值，靠这些条定不了默认值
}

///|
test "codec #13.3 decode13 与 encode13 不是互逆（腿逐条给分布）" {
  // 25 条夹具里 18 条 `decode13 == encode13`，其余不等 ⇒ 自逆只能逐档钉
  // 空夹具更正（同上，`||` 塌缩把 dec13selfinv|1 尾巴灌成了期望值）；Rot.decode13("") 必然空串，
  // 且 dec13selfinv|1 读作"decode13("")==encode13("")"——两侧都是空串，恒真
  assert_eq(@codec.rot13_decode(cc3([])), cc3([])) // 读数腿  RT|d13  ⇒ （空）
  assert_eq(@codec.rot13_decode(cc3([65])), cc3([78])) // 读数腿  RT|d13 A ⇒ N
  assert_eq(@codec.rot13_decode(cc3([97])), cc3([110])) // 读数腿  RT|d13 a ⇒ n
  assert_eq(@codec.rot13_decode(cc3([90])), cc3([77])) // 读数腿  RT|d13 Z ⇒ M
  assert_eq(@codec.rot13_decode(cc3([122])), cc3([109])) // 读数腿  RT|d13 z ⇒ m
  assert_eq(@codec.rot13_decode(cc3([48])), cc3([55])) // 读数腿  RT|d13 0 ⇒ 7
  assert_eq(@codec.rot13_decode(cc3([57])), cc3([54])) // 读数腿  RT|d13 9 ⇒ 6
  assert_eq(@codec.rot13_decode(cc3([53])), cc3([50])) // 读数腿  RT|d13 5 ⇒ 2
  assert_eq(
    @codec.rot13_decode(cc3([97, 98, 99, 88, 89, 90])),
    cc3([110, 111, 112, 75, 76, 77]),
  ) // 读数腿  RT|d13 abcXYZ ⇒ nopKLM
  assert_eq(
    @codec.rot13_decode(cc3([65, 66, 67, 120, 121, 122])),
    cc3([78, 79, 80, 107, 108, 109]),
  ) // 读数腿  RT|d13 ABCxyz ⇒ NOPklm
  assert_eq(@codec.rot13_decode(cc3([48, 49, 56, 57])), cc3([55, 56, 53, 54])) // 读数腿  RT|d13 0189 ⇒ 7856
  assert_eq(
    @codec.rot13_decode(cc3([97, 48, 122, 57])),
    cc3([110, 55, 109, 54]),
  ) // 读数腿  RT|d13 a0z9 ⇒ n7m6
  assert_eq(
    @codec.rot13_decode(cc3([32, 49, 33, 122, 90])),
    cc3([32, 56, 33, 109, 77]),
  ) // 读数腿  RT|d13  1!zZ ⇒  8!mM
  assert_eq(
    @codec.rot13_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
    ),
    cc3([85, 114, 121, 121, 98, 44, 32, 74, 98, 101, 121, 113, 33]),
  ) // 读数腿  RT|d13 Hello, World! ⇒ Uryyb, Jbeyq!
  assert_eq(@codec.rot13_decode(cc3([20013])), cc3([20013])) // 读数腿  RT|d13 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot13_decode(cc3([233])), cc3([233])) // 读数腿  RT|d13 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot13_decode(cc3([937])), cc3([937])) // 读数腿  RT|d13 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot13_decode(cc3([223])), cc3([223])) // 读数腿  RT|d13 \u00df ⇒ \u00df
  assert_eq(@codec.rot13_decode(cc3([1635])), cc3([1635])) // 读数腿  RT|d13 \u0663 ⇒ \u0663
  assert_eq(@codec.rot13_decode(cc3([0])), cc3([0])) // 读数腿  RT|d13 \u0000 ⇒ \u0000
  assert_eq(@codec.rot13_decode(cc3([9])), cc3([9])) // 读数腿  RT|d13 \u0009 ⇒ \u0009
  assert_eq(@codec.rot13_decode(cc3([91])), cc3([91])) // 读数腿  RT|d13 [ ⇒ [
  assert_eq(@codec.rot13_decode(cc3([96])), cc3([96])) // 读数腿  RT|d13 ` ⇒ `
  assert_eq(@codec.rot13_decode(cc3([58])), cc3([58])) // 读数腿  RT|d13 : ⇒ :
  assert_eq(@codec.rot13_decode(cc3([64])), cc3([64])) // 读数腿  RT|d13 @ ⇒ @
}

///|
test "codec #13.3 encode shift=-104 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), -104, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), -104, num_off), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_encode(cc3([97]), -104, num_off), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_encode(cc3([90]), -104, num_off), cc3([64])) // 读数腿  夹具 Z ⇒ @
  assert_eq(@codec.rot_encode(cc3([122]), -104, num_off), cc3([96])) // 读数腿  夹具 z ⇒ `
  assert_eq(@codec.rot_encode(cc3([48]), -104, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), -104, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), -104, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -104, num_off),
    cc3([97, 72, 73, 62, 63, 64]),
  ) // 读数腿  夹具 abcXYZ ⇒ aHI>?@
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -104, num_off),
    cc3([65, 40, 41, 94, 95, 96]),
  ) // 读数腿  夹具 ABCxyz ⇒ A()^_`
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), -104, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), -104, num_off),
    cc3([97, 48, 96, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ a0`9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -104, num_off),
    cc3([32, 49, 33, 96, 64]),
  ) // 读数腿  夹具  1!zZ ⇒  1!`@
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -104,
      num_off,
    ),
    cc3([46, 75, 82, 82, 85, 44, 32, 61, 85, 88, 82, 74, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ .KRRU, =UXRJ!
  assert_eq(@codec.rot_encode(cc3([20013]), -104, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), -104, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), -104, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), -104, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), -104, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), -104, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), -104, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), -104, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), -104, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), -104, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), -104, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=-104 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), -104, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), -104, num_on), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_encode(cc3([97]), -104, num_on), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_encode(cc3([90]), -104, num_on), cc3([64])) // 读数腿  夹具 Z ⇒ @
  assert_eq(@codec.rot_encode(cc3([122]), -104, num_on), cc3([96])) // 读数腿  夹具 z ⇒ `
  assert_eq(@codec.rot_encode(cc3([48]), -104, num_on), cc3([44])) // 读数腿  夹具 0 ⇒ ,
  assert_eq(@codec.rot_encode(cc3([57]), -104, num_on), cc3([43])) // 读数腿  夹具 9 ⇒ +
  assert_eq(@codec.rot_encode(cc3([53]), -104, num_on), cc3([39])) // 读数腿  夹具 5 ⇒ '
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -104, num_on),
    cc3([97, 72, 73, 62, 63, 64]),
  ) // 读数腿  夹具 abcXYZ ⇒ aHI>?@
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -104, num_on),
    cc3([65, 40, 41, 94, 95, 96]),
  ) // 读数腿  夹具 ABCxyz ⇒ A()^_`
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), -104, num_on),
    cc3([44, 45, 42, 43]),
  ) // 读数腿  夹具 0189 ⇒ ,-*+
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), -104, num_on),
    cc3([97, 44, 96, 43]),
  ) // 读数腿  夹具 a0z9 ⇒ a,`+
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -104, num_on),
    cc3([32, 45, 33, 96, 64]),
  ) // 读数腿  夹具  1!zZ ⇒  -!`@
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -104,
      num_on,
    ),
    cc3([46, 75, 82, 82, 85, 44, 32, 61, 85, 88, 82, 74, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ .KRRU, =UXRJ!
  assert_eq(@codec.rot_encode(cc3([20013]), -104, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), -104, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), -104, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), -104, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), -104, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), -104, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), -104, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), -104, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), -104, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), -104, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), -104, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=-26 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), -26, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), -26, num_off), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_encode(cc3([97]), -26, num_off), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_encode(cc3([90]), -26, num_off), cc3([64])) // 读数腿  夹具 Z ⇒ @
  assert_eq(@codec.rot_encode(cc3([122]), -26, num_off), cc3([96])) // 读数腿  夹具 z ⇒ `
  assert_eq(@codec.rot_encode(cc3([48]), -26, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), -26, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), -26, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -26, num_off),
    cc3([97, 72, 73, 62, 63, 64]),
  ) // 读数腿  夹具 abcXYZ ⇒ aHI>?@
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -26, num_off),
    cc3([65, 40, 41, 94, 95, 96]),
  ) // 读数腿  夹具 ABCxyz ⇒ A()^_`
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), -26, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), -26, num_off),
    cc3([97, 48, 96, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ a0`9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -26, num_off),
    cc3([32, 49, 33, 96, 64]),
  ) // 读数腿  夹具  1!zZ ⇒  1!`@
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -26,
      num_off,
    ),
    cc3([46, 75, 82, 82, 85, 44, 32, 61, 85, 88, 82, 74, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ .KRRU, =UXRJ!
  assert_eq(@codec.rot_encode(cc3([20013]), -26, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), -26, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), -26, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), -26, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), -26, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), -26, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), -26, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), -26, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), -26, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), -26, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), -26, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=-26 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), -26, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), -26, num_on), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_encode(cc3([97]), -26, num_on), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_encode(cc3([90]), -26, num_on), cc3([64])) // 读数腿  夹具 Z ⇒ @
  assert_eq(@codec.rot_encode(cc3([122]), -26, num_on), cc3([96])) // 读数腿  夹具 z ⇒ `
  assert_eq(@codec.rot_encode(cc3([48]), -26, num_on), cc3([42])) // 读数腿  夹具 0 ⇒ *
  assert_eq(@codec.rot_encode(cc3([57]), -26, num_on), cc3([41])) // 读数腿  夹具 9 ⇒ )
  assert_eq(@codec.rot_encode(cc3([53]), -26, num_on), cc3([47])) // 读数腿  夹具 5 ⇒ /
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -26, num_on),
    cc3([97, 72, 73, 62, 63, 64]),
  ) // 读数腿  夹具 abcXYZ ⇒ aHI>?@
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -26, num_on),
    cc3([65, 40, 41, 94, 95, 96]),
  ) // 读数腿  夹具 ABCxyz ⇒ A()^_`
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), -26, num_on),
    cc3([42, 43, 40, 41]),
  ) // 读数腿  夹具 0189 ⇒ *+()
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), -26, num_on),
    cc3([97, 42, 96, 41]),
  ) // 读数腿  夹具 a0z9 ⇒ a*`)
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -26, num_on),
    cc3([32, 43, 33, 96, 64]),
  ) // 读数腿  夹具  1!zZ ⇒  +!`@
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -26,
      num_on,
    ),
    cc3([46, 75, 82, 82, 85, 44, 32, 61, 85, 88, 82, 74, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ .KRRU, =UXRJ!
  assert_eq(@codec.rot_encode(cc3([20013]), -26, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), -26, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), -26, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), -26, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), -26, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), -26, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), -26, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), -26, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), -26, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), -26, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), -26, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=-13 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), -13, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), -13, num_off), cc3([52])) // 读数腿  夹具 A ⇒ 4
  assert_eq(@codec.rot_encode(cc3([97]), -13, num_off), cc3([84])) // 读数腿  夹具 a ⇒ T
  assert_eq(@codec.rot_encode(cc3([90]), -13, num_off), cc3([77])) // 读数腿  夹具 Z ⇒ M
  assert_eq(@codec.rot_encode(cc3([122]), -13, num_off), cc3([109])) // 读数腿  夹具 z ⇒ m
  assert_eq(@codec.rot_encode(cc3([48]), -13, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), -13, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), -13, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -13, num_off),
    cc3([84, 85, 86, 75, 76, 77]),
  ) // 读数腿  夹具 abcXYZ ⇒ TUVKLM
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -13, num_off),
    cc3([52, 53, 54, 107, 108, 109]),
  ) // 读数腿  夹具 ABCxyz ⇒ 456klm
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), -13, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), -13, num_off),
    cc3([84, 48, 109, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ T0m9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -13, num_off),
    cc3([32, 49, 33, 109, 77]),
  ) // 读数腿  夹具  1!zZ ⇒  1!mM
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -13,
      num_off,
    ),
    cc3([59, 88, 95, 95, 98, 44, 32, 74, 98, 101, 95, 87, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ ;X__b, Jbe_W!
  assert_eq(@codec.rot_encode(cc3([20013]), -13, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), -13, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), -13, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), -13, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), -13, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), -13, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), -13, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), -13, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), -13, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), -13, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), -13, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=-13 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), -13, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), -13, num_on), cc3([52])) // 读数腿  夹具 A ⇒ 4
  assert_eq(@codec.rot_encode(cc3([97]), -13, num_on), cc3([84])) // 读数腿  夹具 a ⇒ T
  assert_eq(@codec.rot_encode(cc3([90]), -13, num_on), cc3([77])) // 读数腿  夹具 Z ⇒ M
  assert_eq(@codec.rot_encode(cc3([122]), -13, num_on), cc3([109])) // 读数腿  夹具 z ⇒ m
  assert_eq(@codec.rot_encode(cc3([48]), -13, num_on), cc3([45])) // 读数腿  夹具 0 ⇒ -
  assert_eq(@codec.rot_encode(cc3([57]), -13, num_on), cc3([44])) // 读数腿  夹具 9 ⇒ ,
  assert_eq(@codec.rot_encode(cc3([53]), -13, num_on), cc3([40])) // 读数腿  夹具 5 ⇒ (
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -13, num_on),
    cc3([84, 85, 86, 75, 76, 77]),
  ) // 读数腿  夹具 abcXYZ ⇒ TUVKLM
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -13, num_on),
    cc3([52, 53, 54, 107, 108, 109]),
  ) // 读数腿  夹具 ABCxyz ⇒ 456klm
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), -13, num_on),
    cc3([45, 46, 43, 44]),
  ) // 读数腿  夹具 0189 ⇒ -.+,
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), -13, num_on),
    cc3([84, 45, 109, 44]),
  ) // 读数腿  夹具 a0z9 ⇒ T-m,
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -13, num_on),
    cc3([32, 46, 33, 109, 77]),
  ) // 读数腿  夹具  1!zZ ⇒  .!mM
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -13,
      num_on,
    ),
    cc3([59, 88, 95, 95, 98, 44, 32, 74, 98, 101, 95, 87, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ ;X__b, Jbe_W!
  assert_eq(@codec.rot_encode(cc3([20013]), -13, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), -13, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), -13, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), -13, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), -13, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), -13, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), -13, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), -13, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), -13, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), -13, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), -13, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=-10 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), -10, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), -10, num_off), cc3([55])) // 读数腿  夹具 A ⇒ 7
  assert_eq(@codec.rot_encode(cc3([97]), -10, num_off), cc3([87])) // 读数腿  夹具 a ⇒ W
  assert_eq(@codec.rot_encode(cc3([90]), -10, num_off), cc3([80])) // 读数腿  夹具 Z ⇒ P
  assert_eq(@codec.rot_encode(cc3([122]), -10, num_off), cc3([112])) // 读数腿  夹具 z ⇒ p
  assert_eq(@codec.rot_encode(cc3([48]), -10, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), -10, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), -10, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -10, num_off),
    cc3([87, 88, 89, 78, 79, 80]),
  ) // 读数腿  夹具 abcXYZ ⇒ WXYNOP
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -10, num_off),
    cc3([55, 56, 57, 110, 111, 112]),
  ) // 读数腿  夹具 ABCxyz ⇒ 789nop
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), -10, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), -10, num_off),
    cc3([87, 48, 112, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ W0p9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -10, num_off),
    cc3([32, 49, 33, 112, 80]),
  ) // 读数腿  夹具  1!zZ ⇒  1!pP
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -10,
      num_off,
    ),
    cc3([62, 91, 98, 98, 101, 44, 32, 77, 101, 104, 98, 90, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ >[bbe, MehbZ!
  assert_eq(@codec.rot_encode(cc3([20013]), -10, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), -10, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), -10, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), -10, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), -10, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), -10, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), -10, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), -10, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), -10, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), -10, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), -10, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=-10 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), -10, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), -10, num_on), cc3([55])) // 读数腿  夹具 A ⇒ 7
  assert_eq(@codec.rot_encode(cc3([97]), -10, num_on), cc3([87])) // 读数腿  夹具 a ⇒ W
  assert_eq(@codec.rot_encode(cc3([90]), -10, num_on), cc3([80])) // 读数腿  夹具 Z ⇒ P
  assert_eq(@codec.rot_encode(cc3([122]), -10, num_on), cc3([112])) // 读数腿  夹具 z ⇒ p
  assert_eq(@codec.rot_encode(cc3([48]), -10, num_on), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), -10, num_on), cc3([47])) // 读数腿  夹具 9 ⇒ /
  assert_eq(@codec.rot_encode(cc3([53]), -10, num_on), cc3([43])) // 读数腿  夹具 5 ⇒ +
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -10, num_on),
    cc3([87, 88, 89, 78, 79, 80]),
  ) // 读数腿  夹具 abcXYZ ⇒ WXYNOP
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -10, num_on),
    cc3([55, 56, 57, 110, 111, 112]),
  ) // 读数腿  夹具 ABCxyz ⇒ 789nop
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), -10, num_on),
    cc3([48, 39, 46, 47]),
  ) // 读数腿  夹具 0189 ⇒ 0'./
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), -10, num_on),
    cc3([87, 48, 112, 47]),
  ) // 读数腿  夹具 a0z9 ⇒ W0p/
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -10, num_on),
    cc3([32, 39, 33, 112, 80]),
  ) // 读数腿  夹具  1!zZ ⇒  '!pP
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -10,
      num_on,
    ),
    cc3([62, 91, 98, 98, 101, 44, 32, 77, 101, 104, 98, 90, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ >[bbe, MehbZ!
  assert_eq(@codec.rot_encode(cc3([20013]), -10, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), -10, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), -10, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), -10, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), -10, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), -10, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), -10, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), -10, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), -10, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), -10, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), -10, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=-1 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), -1, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), -1, num_off), cc3([64])) // 读数腿  夹具 A ⇒ @
  assert_eq(@codec.rot_encode(cc3([97]), -1, num_off), cc3([96])) // 读数腿  夹具 a ⇒ `
  assert_eq(@codec.rot_encode(cc3([90]), -1, num_off), cc3([89])) // 读数腿  夹具 Z ⇒ Y
  assert_eq(@codec.rot_encode(cc3([122]), -1, num_off), cc3([121])) // 读数腿  夹具 z ⇒ y
  assert_eq(@codec.rot_encode(cc3([48]), -1, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), -1, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), -1, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -1, num_off),
    cc3([96, 97, 98, 87, 88, 89]),
  ) // 读数腿  夹具 abcXYZ ⇒ `abWXY
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -1, num_off),
    cc3([64, 65, 66, 119, 120, 121]),
  ) // 读数腿  夹具 ABCxyz ⇒ @ABwxy
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), -1, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), -1, num_off),
    cc3([96, 48, 121, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ `0y9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -1, num_off),
    cc3([32, 49, 33, 121, 89]),
  ) // 读数腿  夹具  1!zZ ⇒  1!yY
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -1,
      num_off,
    ),
    cc3([71, 100, 107, 107, 110, 44, 32, 86, 110, 113, 107, 99, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Gdkkn, Vnqkc!
  assert_eq(@codec.rot_encode(cc3([20013]), -1, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), -1, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), -1, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), -1, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), -1, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), -1, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), -1, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), -1, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), -1, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), -1, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), -1, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=-1 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), -1, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), -1, num_on), cc3([64])) // 读数腿  夹具 A ⇒ @
  assert_eq(@codec.rot_encode(cc3([97]), -1, num_on), cc3([96])) // 读数腿  夹具 a ⇒ `
  assert_eq(@codec.rot_encode(cc3([90]), -1, num_on), cc3([89])) // 读数腿  夹具 Z ⇒ Y
  assert_eq(@codec.rot_encode(cc3([122]), -1, num_on), cc3([121])) // 读数腿  夹具 z ⇒ y
  assert_eq(@codec.rot_encode(cc3([48]), -1, num_on), cc3([47])) // 读数腿  夹具 0 ⇒ /
  assert_eq(@codec.rot_encode(cc3([57]), -1, num_on), cc3([56])) // 读数腿  夹具 9 ⇒ 8
  assert_eq(@codec.rot_encode(cc3([53]), -1, num_on), cc3([52])) // 读数腿  夹具 5 ⇒ 4
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -1, num_on),
    cc3([96, 97, 98, 87, 88, 89]),
  ) // 读数腿  夹具 abcXYZ ⇒ `abWXY
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -1, num_on),
    cc3([64, 65, 66, 119, 120, 121]),
  ) // 读数腿  夹具 ABCxyz ⇒ @ABwxy
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), -1, num_on),
    cc3([47, 48, 55, 56]),
  ) // 读数腿  夹具 0189 ⇒ /078
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), -1, num_on),
    cc3([96, 47, 121, 56]),
  ) // 读数腿  夹具 a0z9 ⇒ `/y8
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -1, num_on),
    cc3([32, 48, 33, 121, 89]),
  ) // 读数腿  夹具  1!zZ ⇒  0!yY
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -1,
      num_on,
    ),
    cc3([71, 100, 107, 107, 110, 44, 32, 86, 110, 113, 107, 99, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Gdkkn, Vnqkc!
  assert_eq(@codec.rot_encode(cc3([20013]), -1, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), -1, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), -1, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), -1, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), -1, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), -1, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), -1, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), -1, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), -1, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), -1, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), -1, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=0 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 0, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 0, num_off), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_encode(cc3([97]), 0, num_off), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_encode(cc3([90]), 0, num_off), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_encode(cc3([122]), 0, num_off), cc3([122])) // 读数腿  夹具 z ⇒ z
  assert_eq(@codec.rot_encode(cc3([48]), 0, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), 0, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), 0, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 0, num_off),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ abcXYZ
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 0, num_off),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABCxyz
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 0, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 0, num_off),
    cc3([97, 48, 122, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ a0z9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 0, num_off),
    cc3([32, 49, 33, 122, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  1!zZ
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      0,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Hello, World!
  assert_eq(@codec.rot_encode(cc3([20013]), 0, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 0, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 0, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 0, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 0, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 0, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 0, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 0, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 0, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 0, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 0, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=0 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 0, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 0, num_on), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_encode(cc3([97]), 0, num_on), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_encode(cc3([90]), 0, num_on), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_encode(cc3([122]), 0, num_on), cc3([122])) // 读数腿  夹具 z ⇒ z
  assert_eq(@codec.rot_encode(cc3([48]), 0, num_on), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), 0, num_on), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), 0, num_on), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 0, num_on),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ abcXYZ
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 0, num_on),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABCxyz
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 0, num_on),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 0, num_on),
    cc3([97, 48, 122, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ a0z9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 0, num_on),
    cc3([32, 49, 33, 122, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  1!zZ
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      0,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Hello, World!
  assert_eq(@codec.rot_encode(cc3([20013]), 0, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 0, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 0, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 0, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 0, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 0, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 0, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 0, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 0, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 0, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 0, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=1 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 1, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 1, num_off), cc3([66])) // 读数腿  夹具 A ⇒ B
  assert_eq(@codec.rot_encode(cc3([97]), 1, num_off), cc3([98])) // 读数腿  夹具 a ⇒ b
  assert_eq(@codec.rot_encode(cc3([90]), 1, num_off), cc3([65])) // 读数腿  夹具 Z ⇒ A
  assert_eq(@codec.rot_encode(cc3([122]), 1, num_off), cc3([97])) // 读数腿  夹具 z ⇒ a
  assert_eq(@codec.rot_encode(cc3([48]), 1, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), 1, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), 1, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 1, num_off),
    cc3([98, 99, 100, 89, 90, 65]),
  ) // 读数腿  夹具 abcXYZ ⇒ bcdYZA
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 1, num_off),
    cc3([66, 67, 68, 121, 122, 97]),
  ) // 读数腿  夹具 ABCxyz ⇒ BCDyza
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 1, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 1, num_off),
    cc3([98, 48, 97, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ b0a9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 1, num_off),
    cc3([32, 49, 33, 97, 65]),
  ) // 读数腿  夹具  1!zZ ⇒  1!aA
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      1,
      num_off,
    ),
    cc3([73, 102, 109, 109, 112, 44, 32, 88, 112, 115, 109, 101, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Ifmmp, Xpsme!
  assert_eq(@codec.rot_encode(cc3([20013]), 1, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 1, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 1, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 1, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 1, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 1, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 1, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 1, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 1, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 1, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 1, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=1 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 1, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 1, num_on), cc3([66])) // 读数腿  夹具 A ⇒ B
  assert_eq(@codec.rot_encode(cc3([97]), 1, num_on), cc3([98])) // 读数腿  夹具 a ⇒ b
  assert_eq(@codec.rot_encode(cc3([90]), 1, num_on), cc3([65])) // 读数腿  夹具 Z ⇒ A
  assert_eq(@codec.rot_encode(cc3([122]), 1, num_on), cc3([97])) // 读数腿  夹具 z ⇒ a
  assert_eq(@codec.rot_encode(cc3([48]), 1, num_on), cc3([49])) // 读数腿  夹具 0 ⇒ 1
  assert_eq(@codec.rot_encode(cc3([57]), 1, num_on), cc3([48])) // 读数腿  夹具 9 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([53]), 1, num_on), cc3([54])) // 读数腿  夹具 5 ⇒ 6
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 1, num_on),
    cc3([98, 99, 100, 89, 90, 65]),
  ) // 读数腿  夹具 abcXYZ ⇒ bcdYZA
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 1, num_on),
    cc3([66, 67, 68, 121, 122, 97]),
  ) // 读数腿  夹具 ABCxyz ⇒ BCDyza
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 1, num_on),
    cc3([49, 50, 57, 48]),
  ) // 读数腿  夹具 0189 ⇒ 1290
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 1, num_on),
    cc3([98, 49, 97, 48]),
  ) // 读数腿  夹具 a0z9 ⇒ b1a0
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 1, num_on),
    cc3([32, 50, 33, 97, 65]),
  ) // 读数腿  夹具  1!zZ ⇒  2!aA
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      1,
      num_on,
    ),
    cc3([73, 102, 109, 109, 112, 44, 32, 88, 112, 115, 109, 101, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Ifmmp, Xpsme!
  assert_eq(@codec.rot_encode(cc3([20013]), 1, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 1, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 1, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 1, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 1, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 1, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 1, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 1, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 1, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 1, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 1, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=5 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 5, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 5, num_off), cc3([70])) // 读数腿  夹具 A ⇒ F
  assert_eq(@codec.rot_encode(cc3([97]), 5, num_off), cc3([102])) // 读数腿  夹具 a ⇒ f
  assert_eq(@codec.rot_encode(cc3([90]), 5, num_off), cc3([69])) // 读数腿  夹具 Z ⇒ E
  assert_eq(@codec.rot_encode(cc3([122]), 5, num_off), cc3([101])) // 读数腿  夹具 z ⇒ e
  assert_eq(@codec.rot_encode(cc3([48]), 5, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), 5, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), 5, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 5, num_off),
    cc3([102, 103, 104, 67, 68, 69]),
  ) // 读数腿  夹具 abcXYZ ⇒ fghCDE
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 5, num_off),
    cc3([70, 71, 72, 99, 100, 101]),
  ) // 读数腿  夹具 ABCxyz ⇒ FGHcde
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 5, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 5, num_off),
    cc3([102, 48, 101, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ f0e9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 5, num_off),
    cc3([32, 49, 33, 101, 69]),
  ) // 读数腿  夹具  1!zZ ⇒  1!eE
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      5,
      num_off,
    ),
    cc3([77, 106, 113, 113, 116, 44, 32, 66, 116, 119, 113, 105, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Mjqqt, Btwqi!
  assert_eq(@codec.rot_encode(cc3([20013]), 5, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 5, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 5, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 5, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 5, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 5, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 5, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 5, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 5, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 5, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 5, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=5 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 5, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 5, num_on), cc3([70])) // 读数腿  夹具 A ⇒ F
  assert_eq(@codec.rot_encode(cc3([97]), 5, num_on), cc3([102])) // 读数腿  夹具 a ⇒ f
  assert_eq(@codec.rot_encode(cc3([90]), 5, num_on), cc3([69])) // 读数腿  夹具 Z ⇒ E
  assert_eq(@codec.rot_encode(cc3([122]), 5, num_on), cc3([101])) // 读数腿  夹具 z ⇒ e
  assert_eq(@codec.rot_encode(cc3([48]), 5, num_on), cc3([53])) // 读数腿  夹具 0 ⇒ 5
  assert_eq(@codec.rot_encode(cc3([57]), 5, num_on), cc3([52])) // 读数腿  夹具 9 ⇒ 4
  assert_eq(@codec.rot_encode(cc3([53]), 5, num_on), cc3([48])) // 读数腿  夹具 5 ⇒ 0
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 5, num_on),
    cc3([102, 103, 104, 67, 68, 69]),
  ) // 读数腿  夹具 abcXYZ ⇒ fghCDE
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 5, num_on),
    cc3([70, 71, 72, 99, 100, 101]),
  ) // 读数腿  夹具 ABCxyz ⇒ FGHcde
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 5, num_on),
    cc3([53, 54, 51, 52]),
  ) // 读数腿  夹具 0189 ⇒ 5634
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 5, num_on),
    cc3([102, 53, 101, 52]),
  ) // 读数腿  夹具 a0z9 ⇒ f5e4
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 5, num_on),
    cc3([32, 54, 33, 101, 69]),
  ) // 读数腿  夹具  1!zZ ⇒  6!eE
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      5,
      num_on,
    ),
    cc3([77, 106, 113, 113, 116, 44, 32, 66, 116, 119, 113, 105, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Mjqqt, Btwqi!
  assert_eq(@codec.rot_encode(cc3([20013]), 5, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 5, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 5, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 5, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 5, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 5, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 5, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 5, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 5, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 5, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 5, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=10 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 10, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 10, num_off), cc3([75])) // 读数腿  夹具 A ⇒ K
  assert_eq(@codec.rot_encode(cc3([97]), 10, num_off), cc3([107])) // 读数腿  夹具 a ⇒ k
  assert_eq(@codec.rot_encode(cc3([90]), 10, num_off), cc3([74])) // 读数腿  夹具 Z ⇒ J
  assert_eq(@codec.rot_encode(cc3([122]), 10, num_off), cc3([106])) // 读数腿  夹具 z ⇒ j
  assert_eq(@codec.rot_encode(cc3([48]), 10, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), 10, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), 10, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 10, num_off),
    cc3([107, 108, 109, 72, 73, 74]),
  ) // 读数腿  夹具 abcXYZ ⇒ klmHIJ
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 10, num_off),
    cc3([75, 76, 77, 104, 105, 106]),
  ) // 读数腿  夹具 ABCxyz ⇒ KLMhij
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 10, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 10, num_off),
    cc3([107, 48, 106, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ k0j9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 10, num_off),
    cc3([32, 49, 33, 106, 74]),
  ) // 读数腿  夹具  1!zZ ⇒  1!jJ
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      10,
      num_off,
    ),
    cc3([82, 111, 118, 118, 121, 44, 32, 71, 121, 98, 118, 110, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Rovvy, Gybvn!
  assert_eq(@codec.rot_encode(cc3([20013]), 10, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 10, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 10, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 10, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 10, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 10, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 10, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 10, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 10, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 10, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 10, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=10 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 10, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 10, num_on), cc3([75])) // 读数腿  夹具 A ⇒ K
  assert_eq(@codec.rot_encode(cc3([97]), 10, num_on), cc3([107])) // 读数腿  夹具 a ⇒ k
  assert_eq(@codec.rot_encode(cc3([90]), 10, num_on), cc3([74])) // 读数腿  夹具 Z ⇒ J
  assert_eq(@codec.rot_encode(cc3([122]), 10, num_on), cc3([106])) // 读数腿  夹具 z ⇒ j
  assert_eq(@codec.rot_encode(cc3([48]), 10, num_on), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), 10, num_on), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), 10, num_on), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 10, num_on),
    cc3([107, 108, 109, 72, 73, 74]),
  ) // 读数腿  夹具 abcXYZ ⇒ klmHIJ
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 10, num_on),
    cc3([75, 76, 77, 104, 105, 106]),
  ) // 读数腿  夹具 ABCxyz ⇒ KLMhij
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 10, num_on),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 10, num_on),
    cc3([107, 48, 106, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ k0j9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 10, num_on),
    cc3([32, 49, 33, 106, 74]),
  ) // 读数腿  夹具  1!zZ ⇒  1!jJ
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      10,
      num_on,
    ),
    cc3([82, 111, 118, 118, 121, 44, 32, 71, 121, 98, 118, 110, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Rovvy, Gybvn!
  assert_eq(@codec.rot_encode(cc3([20013]), 10, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 10, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 10, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 10, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 10, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 10, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 10, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 10, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 10, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 10, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 10, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=13 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 13, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 13, num_off), cc3([78])) // 读数腿  夹具 A ⇒ N
  assert_eq(@codec.rot_encode(cc3([97]), 13, num_off), cc3([110])) // 读数腿  夹具 a ⇒ n
  assert_eq(@codec.rot_encode(cc3([90]), 13, num_off), cc3([77])) // 读数腿  夹具 Z ⇒ M
  assert_eq(@codec.rot_encode(cc3([122]), 13, num_off), cc3([109])) // 读数腿  夹具 z ⇒ m
  assert_eq(@codec.rot_encode(cc3([48]), 13, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), 13, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), 13, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 13, num_off),
    cc3([110, 111, 112, 75, 76, 77]),
  ) // 读数腿  夹具 abcXYZ ⇒ nopKLM
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 13, num_off),
    cc3([78, 79, 80, 107, 108, 109]),
  ) // 读数腿  夹具 ABCxyz ⇒ NOPklm
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 13, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 13, num_off),
    cc3([110, 48, 109, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ n0m9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 13, num_off),
    cc3([32, 49, 33, 109, 77]),
  ) // 读数腿  夹具  1!zZ ⇒  1!mM
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      13,
      num_off,
    ),
    cc3([85, 114, 121, 121, 98, 44, 32, 74, 98, 101, 121, 113, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Uryyb, Jbeyq!
  assert_eq(@codec.rot_encode(cc3([20013]), 13, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 13, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 13, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 13, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 13, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 13, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 13, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 13, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 13, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 13, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 13, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=13 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 13, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 13, num_on), cc3([78])) // 读数腿  夹具 A ⇒ N
  assert_eq(@codec.rot_encode(cc3([97]), 13, num_on), cc3([110])) // 读数腿  夹具 a ⇒ n
  assert_eq(@codec.rot_encode(cc3([90]), 13, num_on), cc3([77])) // 读数腿  夹具 Z ⇒ M
  assert_eq(@codec.rot_encode(cc3([122]), 13, num_on), cc3([109])) // 读数腿  夹具 z ⇒ m
  assert_eq(@codec.rot_encode(cc3([48]), 13, num_on), cc3([51])) // 读数腿  夹具 0 ⇒ 3
  assert_eq(@codec.rot_encode(cc3([57]), 13, num_on), cc3([50])) // 读数腿  夹具 9 ⇒ 2
  assert_eq(@codec.rot_encode(cc3([53]), 13, num_on), cc3([56])) // 读数腿  夹具 5 ⇒ 8
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 13, num_on),
    cc3([110, 111, 112, 75, 76, 77]),
  ) // 读数腿  夹具 abcXYZ ⇒ nopKLM
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 13, num_on),
    cc3([78, 79, 80, 107, 108, 109]),
  ) // 读数腿  夹具 ABCxyz ⇒ NOPklm
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 13, num_on),
    cc3([51, 52, 49, 50]),
  ) // 读数腿  夹具 0189 ⇒ 3412
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 13, num_on),
    cc3([110, 51, 109, 50]),
  ) // 读数腿  夹具 a0z9 ⇒ n3m2
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 13, num_on),
    cc3([32, 52, 33, 109, 77]),
  ) // 读数腿  夹具  1!zZ ⇒  4!mM
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      13,
      num_on,
    ),
    cc3([85, 114, 121, 121, 98, 44, 32, 74, 98, 101, 121, 113, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Uryyb, Jbeyq!
  assert_eq(@codec.rot_encode(cc3([20013]), 13, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 13, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 13, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 13, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 13, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 13, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 13, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 13, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 13, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 13, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 13, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=25 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 25, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 25, num_off), cc3([90])) // 读数腿  夹具 A ⇒ Z
  assert_eq(@codec.rot_encode(cc3([97]), 25, num_off), cc3([122])) // 读数腿  夹具 a ⇒ z
  assert_eq(@codec.rot_encode(cc3([90]), 25, num_off), cc3([89])) // 读数腿  夹具 Z ⇒ Y
  assert_eq(@codec.rot_encode(cc3([122]), 25, num_off), cc3([121])) // 读数腿  夹具 z ⇒ y
  assert_eq(@codec.rot_encode(cc3([48]), 25, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), 25, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), 25, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 25, num_off),
    cc3([122, 97, 98, 87, 88, 89]),
  ) // 读数腿  夹具 abcXYZ ⇒ zabWXY
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 25, num_off),
    cc3([90, 65, 66, 119, 120, 121]),
  ) // 读数腿  夹具 ABCxyz ⇒ ZABwxy
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 25, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 25, num_off),
    cc3([122, 48, 121, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ z0y9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 25, num_off),
    cc3([32, 49, 33, 121, 89]),
  ) // 读数腿  夹具  1!zZ ⇒  1!yY
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      25,
      num_off,
    ),
    cc3([71, 100, 107, 107, 110, 44, 32, 86, 110, 113, 107, 99, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Gdkkn, Vnqkc!
  assert_eq(@codec.rot_encode(cc3([20013]), 25, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 25, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 25, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 25, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 25, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 25, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 25, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 25, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 25, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 25, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 25, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=25 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 25, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 25, num_on), cc3([90])) // 读数腿  夹具 A ⇒ Z
  assert_eq(@codec.rot_encode(cc3([97]), 25, num_on), cc3([122])) // 读数腿  夹具 a ⇒ z
  assert_eq(@codec.rot_encode(cc3([90]), 25, num_on), cc3([89])) // 读数腿  夹具 Z ⇒ Y
  assert_eq(@codec.rot_encode(cc3([122]), 25, num_on), cc3([121])) // 读数腿  夹具 z ⇒ y
  assert_eq(@codec.rot_encode(cc3([48]), 25, num_on), cc3([53])) // 读数腿  夹具 0 ⇒ 5
  assert_eq(@codec.rot_encode(cc3([57]), 25, num_on), cc3([52])) // 读数腿  夹具 9 ⇒ 4
  assert_eq(@codec.rot_encode(cc3([53]), 25, num_on), cc3([48])) // 读数腿  夹具 5 ⇒ 0
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 25, num_on),
    cc3([122, 97, 98, 87, 88, 89]),
  ) // 读数腿  夹具 abcXYZ ⇒ zabWXY
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 25, num_on),
    cc3([90, 65, 66, 119, 120, 121]),
  ) // 读数腿  夹具 ABCxyz ⇒ ZABwxy
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 25, num_on),
    cc3([53, 54, 51, 52]),
  ) // 读数腿  夹具 0189 ⇒ 5634
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 25, num_on),
    cc3([122, 53, 121, 52]),
  ) // 读数腿  夹具 a0z9 ⇒ z5y4
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 25, num_on),
    cc3([32, 54, 33, 121, 89]),
  ) // 读数腿  夹具  1!zZ ⇒  6!yY
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      25,
      num_on,
    ),
    cc3([71, 100, 107, 107, 110, 44, 32, 86, 110, 113, 107, 99, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Gdkkn, Vnqkc!
  assert_eq(@codec.rot_encode(cc3([20013]), 25, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 25, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 25, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 25, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 25, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 25, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 25, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 25, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 25, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 25, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 25, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=26 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 26, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 26, num_off), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_encode(cc3([97]), 26, num_off), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_encode(cc3([90]), 26, num_off), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_encode(cc3([122]), 26, num_off), cc3([122])) // 读数腿  夹具 z ⇒ z
  assert_eq(@codec.rot_encode(cc3([48]), 26, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), 26, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), 26, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 26, num_off),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ abcXYZ
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 26, num_off),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABCxyz
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 26, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 26, num_off),
    cc3([97, 48, 122, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ a0z9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 26, num_off),
    cc3([32, 49, 33, 122, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  1!zZ
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      26,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Hello, World!
  assert_eq(@codec.rot_encode(cc3([20013]), 26, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 26, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 26, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 26, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 26, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 26, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 26, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 26, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 26, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 26, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 26, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=26 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 26, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 26, num_on), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_encode(cc3([97]), 26, num_on), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_encode(cc3([90]), 26, num_on), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_encode(cc3([122]), 26, num_on), cc3([122])) // 读数腿  夹具 z ⇒ z
  assert_eq(@codec.rot_encode(cc3([48]), 26, num_on), cc3([54])) // 读数腿  夹具 0 ⇒ 6
  assert_eq(@codec.rot_encode(cc3([57]), 26, num_on), cc3([53])) // 读数腿  夹具 9 ⇒ 5
  assert_eq(@codec.rot_encode(cc3([53]), 26, num_on), cc3([49])) // 读数腿  夹具 5 ⇒ 1
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 26, num_on),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ abcXYZ
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 26, num_on),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABCxyz
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 26, num_on),
    cc3([54, 55, 52, 53]),
  ) // 读数腿  夹具 0189 ⇒ 6745
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 26, num_on),
    cc3([97, 54, 122, 53]),
  ) // 读数腿  夹具 a0z9 ⇒ a6z5
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 26, num_on),
    cc3([32, 55, 33, 122, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  7!zZ
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      26,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Hello, World!
  assert_eq(@codec.rot_encode(cc3([20013]), 26, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 26, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 26, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 26, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 26, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 26, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 26, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 26, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 26, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 26, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 26, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=27 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 27, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 27, num_off), cc3([66])) // 读数腿  夹具 A ⇒ B
  assert_eq(@codec.rot_encode(cc3([97]), 27, num_off), cc3([98])) // 读数腿  夹具 a ⇒ b
  assert_eq(@codec.rot_encode(cc3([90]), 27, num_off), cc3([65])) // 读数腿  夹具 Z ⇒ A
  assert_eq(@codec.rot_encode(cc3([122]), 27, num_off), cc3([97])) // 读数腿  夹具 z ⇒ a
  assert_eq(@codec.rot_encode(cc3([48]), 27, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), 27, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), 27, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 27, num_off),
    cc3([98, 99, 100, 89, 90, 65]),
  ) // 读数腿  夹具 abcXYZ ⇒ bcdYZA
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 27, num_off),
    cc3([66, 67, 68, 121, 122, 97]),
  ) // 读数腿  夹具 ABCxyz ⇒ BCDyza
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 27, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 27, num_off),
    cc3([98, 48, 97, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ b0a9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 27, num_off),
    cc3([32, 49, 33, 97, 65]),
  ) // 读数腿  夹具  1!zZ ⇒  1!aA
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      27,
      num_off,
    ),
    cc3([73, 102, 109, 109, 112, 44, 32, 88, 112, 115, 109, 101, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Ifmmp, Xpsme!
  assert_eq(@codec.rot_encode(cc3([20013]), 27, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 27, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 27, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 27, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 27, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 27, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 27, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 27, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 27, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 27, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 27, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=27 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 27, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 27, num_on), cc3([66])) // 读数腿  夹具 A ⇒ B
  assert_eq(@codec.rot_encode(cc3([97]), 27, num_on), cc3([98])) // 读数腿  夹具 a ⇒ b
  assert_eq(@codec.rot_encode(cc3([90]), 27, num_on), cc3([65])) // 读数腿  夹具 Z ⇒ A
  assert_eq(@codec.rot_encode(cc3([122]), 27, num_on), cc3([97])) // 读数腿  夹具 z ⇒ a
  assert_eq(@codec.rot_encode(cc3([48]), 27, num_on), cc3([55])) // 读数腿  夹具 0 ⇒ 7
  assert_eq(@codec.rot_encode(cc3([57]), 27, num_on), cc3([54])) // 读数腿  夹具 9 ⇒ 6
  assert_eq(@codec.rot_encode(cc3([53]), 27, num_on), cc3([50])) // 读数腿  夹具 5 ⇒ 2
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 27, num_on),
    cc3([98, 99, 100, 89, 90, 65]),
  ) // 读数腿  夹具 abcXYZ ⇒ bcdYZA
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 27, num_on),
    cc3([66, 67, 68, 121, 122, 97]),
  ) // 读数腿  夹具 ABCxyz ⇒ BCDyza
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 27, num_on),
    cc3([55, 56, 53, 54]),
  ) // 读数腿  夹具 0189 ⇒ 7856
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 27, num_on),
    cc3([98, 55, 97, 54]),
  ) // 读数腿  夹具 a0z9 ⇒ b7a6
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 27, num_on),
    cc3([32, 56, 33, 97, 65]),
  ) // 读数腿  夹具  1!zZ ⇒  8!aA
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      27,
      num_on,
    ),
    cc3([73, 102, 109, 109, 112, 44, 32, 88, 112, 115, 109, 101, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Ifmmp, Xpsme!
  assert_eq(@codec.rot_encode(cc3([20013]), 27, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 27, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 27, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 27, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 27, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 27, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 27, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 27, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 27, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 27, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 27, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=52 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 52, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 52, num_off), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_encode(cc3([97]), 52, num_off), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_encode(cc3([90]), 52, num_off), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_encode(cc3([122]), 52, num_off), cc3([122])) // 读数腿  夹具 z ⇒ z
  assert_eq(@codec.rot_encode(cc3([48]), 52, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), 52, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), 52, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 52, num_off),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ abcXYZ
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 52, num_off),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABCxyz
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 52, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 52, num_off),
    cc3([97, 48, 122, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ a0z9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 52, num_off),
    cc3([32, 49, 33, 122, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  1!zZ
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      52,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Hello, World!
  assert_eq(@codec.rot_encode(cc3([20013]), 52, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 52, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 52, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 52, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 52, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 52, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 52, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 52, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 52, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 52, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 52, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=52 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 52, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 52, num_on), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_encode(cc3([97]), 52, num_on), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_encode(cc3([90]), 52, num_on), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_encode(cc3([122]), 52, num_on), cc3([122])) // 读数腿  夹具 z ⇒ z
  assert_eq(@codec.rot_encode(cc3([48]), 52, num_on), cc3([50])) // 读数腿  夹具 0 ⇒ 2
  assert_eq(@codec.rot_encode(cc3([57]), 52, num_on), cc3([49])) // 读数腿  夹具 9 ⇒ 1
  assert_eq(@codec.rot_encode(cc3([53]), 52, num_on), cc3([55])) // 读数腿  夹具 5 ⇒ 7
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 52, num_on),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ abcXYZ
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 52, num_on),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABCxyz
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 52, num_on),
    cc3([50, 51, 48, 49]),
  ) // 读数腿  夹具 0189 ⇒ 2301
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 52, num_on),
    cc3([97, 50, 122, 49]),
  ) // 读数腿  夹具 a0z9 ⇒ a2z1
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 52, num_on),
    cc3([32, 51, 33, 122, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  3!zZ
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      52,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Hello, World!
  assert_eq(@codec.rot_encode(cc3([20013]), 52, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 52, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 52, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 52, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 52, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 52, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 52, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 52, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 52, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 52, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 52, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=104 num_off（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 104, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 104, num_off), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_encode(cc3([97]), 104, num_off), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_encode(cc3([90]), 104, num_off), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_encode(cc3([122]), 104, num_off), cc3([122])) // 读数腿  夹具 z ⇒ z
  assert_eq(@codec.rot_encode(cc3([48]), 104, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_encode(cc3([57]), 104, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_encode(cc3([53]), 104, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 104, num_off),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ abcXYZ
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 104, num_off),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABCxyz
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 104, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 104, num_off),
    cc3([97, 48, 122, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ a0z9
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 104, num_off),
    cc3([32, 49, 33, 122, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  1!zZ
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      104,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Hello, World!
  assert_eq(@codec.rot_encode(cc3([20013]), 104, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 104, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 104, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 104, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 104, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 104, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 104, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 104, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 104, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 104, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 104, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 encode shift=104 num_on（25 档夹具）" {
  assert_eq(@codec.rot_encode(cc3([]), 104, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_encode(cc3([65]), 104, num_on), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_encode(cc3([97]), 104, num_on), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_encode(cc3([90]), 104, num_on), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_encode(cc3([122]), 104, num_on), cc3([122])) // 读数腿  夹具 z ⇒ z
  assert_eq(@codec.rot_encode(cc3([48]), 104, num_on), cc3([52])) // 读数腿  夹具 0 ⇒ 4
  assert_eq(@codec.rot_encode(cc3([57]), 104, num_on), cc3([51])) // 读数腿  夹具 9 ⇒ 3
  assert_eq(@codec.rot_encode(cc3([53]), 104, num_on), cc3([57])) // 读数腿  夹具 5 ⇒ 9
  assert_eq(
    @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 104, num_on),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ abcXYZ
  assert_eq(
    @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 104, num_on),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABCxyz
  assert_eq(
    @codec.rot_encode(cc3([48, 49, 56, 57]), 104, num_on),
    cc3([52, 53, 50, 51]),
  ) // 读数腿  夹具 0189 ⇒ 4523
  assert_eq(
    @codec.rot_encode(cc3([97, 48, 122, 57]), 104, num_on),
    cc3([97, 52, 122, 51]),
  ) // 读数腿  夹具 a0z9 ⇒ a4z3
  assert_eq(
    @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 104, num_on),
    cc3([32, 53, 33, 122, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  5!zZ
  assert_eq(
    @codec.rot_encode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      104,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Hello, World!
  assert_eq(@codec.rot_encode(cc3([20013]), 104, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_encode(cc3([233]), 104, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_encode(cc3([937]), 104, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_encode(cc3([223]), 104, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_encode(cc3([1635]), 104, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_encode(cc3([0]), 104, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_encode(cc3([9]), 104, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_encode(cc3([91]), 104, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_encode(cc3([96]), 104, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_encode(cc3([58]), 104, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_encode(cc3([64]), 104, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=-104 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), -104, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), -104, num_off), cc3([169])) // 读数腿  夹具 A ⇒ \u00a9
  assert_eq(@codec.rot_decode(cc3([97]), -104, num_off), cc3([201])) // 读数腿  夹具 a ⇒ \u00c9
  assert_eq(@codec.rot_decode(cc3([90]), -104, num_off), cc3([194])) // 读数腿  夹具 Z ⇒ \u00c2
  assert_eq(@codec.rot_decode(cc3([122]), -104, num_off), cc3([226])) // 读数腿  夹具 z ⇒ \u00e2
  assert_eq(@codec.rot_decode(cc3([48]), -104, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), -104, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), -104, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), -104, num_off),
    cc3([201, 202, 203, 192, 193, 194]),
  ) // 读数腿  夹具 abcXYZ ⇒ \u00c9\u00ca\u00cb\u00c0\u00c1\u00c2
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), -104, num_off),
    cc3([169, 170, 171, 224, 225, 226]),
  ) // 读数腿  夹具 ABCxyz ⇒ \u00a9\u00aa\u00ab\u00e0\u00e1\u00e2
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), -104, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), -104, num_off),
    cc3([201, 48, 226, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ \u00c90\u00e29
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), -104, num_off),
    cc3([32, 49, 33, 226, 194]),
  ) // 读数腿  夹具  1!zZ ⇒  1!\u00e2\u00c2
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -104,
      num_off,
    ),
    cc3([176, 205, 212, 212, 215, 44, 32, 191, 215, 218, 212, 204, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ \u00b0\u00cd\u00d4\u00d4\u00d7, \u00bf\u00d7\u00da\u00d4\u00cc!
  assert_eq(@codec.rot_decode(cc3([20013]), -104, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), -104, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), -104, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), -104, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), -104, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), -104, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), -104, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), -104, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), -104, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), -104, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), -104, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=-104 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), -104, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), -104, num_on), cc3([169])) // 读数腿  夹具 A ⇒ \u00a9
  assert_eq(@codec.rot_decode(cc3([97]), -104, num_on), cc3([201])) // 读数腿  夹具 a ⇒ \u00c9
  assert_eq(@codec.rot_decode(cc3([90]), -104, num_on), cc3([194])) // 读数腿  夹具 Z ⇒ \u00c2
  assert_eq(@codec.rot_decode(cc3([122]), -104, num_on), cc3([226])) // 读数腿  夹具 z ⇒ \u00e2
  assert_eq(@codec.rot_decode(cc3([48]), -104, num_on), cc3([152])) // 读数腿  夹具 0 ⇒ \u0098
  assert_eq(@codec.rot_decode(cc3([57]), -104, num_on), cc3([161])) // 读数腿  夹具 9 ⇒ \u00a1
  assert_eq(@codec.rot_decode(cc3([53]), -104, num_on), cc3([157])) // 读数腿  夹具 5 ⇒ \u009d
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), -104, num_on),
    cc3([201, 202, 203, 192, 193, 194]),
  ) // 读数腿  夹具 abcXYZ ⇒ \u00c9\u00ca\u00cb\u00c0\u00c1\u00c2
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), -104, num_on),
    cc3([169, 170, 171, 224, 225, 226]),
  ) // 读数腿  夹具 ABCxyz ⇒ \u00a9\u00aa\u00ab\u00e0\u00e1\u00e2
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), -104, num_on),
    cc3([152, 153, 160, 161]),
  ) // 读数腿  夹具 0189 ⇒ \u0098\u0099\u00a0\u00a1
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), -104, num_on),
    cc3([201, 152, 226, 161]),
  ) // 读数腿  夹具 a0z9 ⇒ \u00c9\u0098\u00e2\u00a1
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), -104, num_on),
    cc3([32, 153, 33, 226, 194]),
  ) // 读数腿  夹具  1!zZ ⇒  \u0099!\u00e2\u00c2
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -104,
      num_on,
    ),
    cc3([176, 205, 212, 212, 215, 44, 32, 191, 215, 218, 212, 204, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ \u00b0\u00cd\u00d4\u00d4\u00d7, \u00bf\u00d7\u00da\u00d4\u00cc!
  assert_eq(@codec.rot_decode(cc3([20013]), -104, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), -104, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), -104, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), -104, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), -104, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), -104, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), -104, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), -104, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), -104, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), -104, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), -104, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=-26 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), -26, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), -26, num_off), cc3([91])) // 读数腿  夹具 A ⇒ [
  assert_eq(@codec.rot_decode(cc3([97]), -26, num_off), cc3([123])) // 读数腿  夹具 a ⇒ {
  assert_eq(@codec.rot_decode(cc3([90]), -26, num_off), cc3([116])) // 读数腿  夹具 Z ⇒ t
  assert_eq(@codec.rot_decode(cc3([122]), -26, num_off), cc3([148])) // 读数腿  夹具 z ⇒ \u0094
  assert_eq(@codec.rot_decode(cc3([48]), -26, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), -26, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), -26, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), -26, num_off),
    cc3([123, 124, 125, 114, 115, 116]),
  ) // 读数腿  夹具 abcXYZ ⇒ {|}rst
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), -26, num_off),
    cc3([91, 92, 93, 146, 147, 148]),
  ) // 读数腿  夹具 ABCxyz ⇒ [\u005c]\u0092\u0093\u0094
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), -26, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), -26, num_off),
    cc3([123, 48, 148, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ {0\u00949
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), -26, num_off),
    cc3([32, 49, 33, 148, 116]),
  ) // 读数腿  夹具  1!zZ ⇒  1!\u0094t
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -26,
      num_off,
    ),
    cc3([98, 127, 134, 134, 137, 44, 32, 113, 137, 140, 134, 126, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ b\u007f\u0086\u0086\u0089, q\u0089\u008c\u0086~!
  assert_eq(@codec.rot_decode(cc3([20013]), -26, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), -26, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), -26, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), -26, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), -26, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), -26, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), -26, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), -26, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), -26, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), -26, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), -26, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=-26 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), -26, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), -26, num_on), cc3([91])) // 读数腿  夹具 A ⇒ [
  assert_eq(@codec.rot_decode(cc3([97]), -26, num_on), cc3([123])) // 读数腿  夹具 a ⇒ {
  assert_eq(@codec.rot_decode(cc3([90]), -26, num_on), cc3([116])) // 读数腿  夹具 Z ⇒ t
  assert_eq(@codec.rot_decode(cc3([122]), -26, num_on), cc3([148])) // 读数腿  夹具 z ⇒ \u0094
  assert_eq(@codec.rot_decode(cc3([48]), -26, num_on), cc3([100])) // 读数腿  夹具 0 ⇒ d
  assert_eq(@codec.rot_decode(cc3([57]), -26, num_on), cc3([109])) // 读数腿  夹具 9 ⇒ m
  assert_eq(@codec.rot_decode(cc3([53]), -26, num_on), cc3([105])) // 读数腿  夹具 5 ⇒ i
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), -26, num_on),
    cc3([123, 124, 125, 114, 115, 116]),
  ) // 读数腿  夹具 abcXYZ ⇒ {|}rst
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), -26, num_on),
    cc3([91, 92, 93, 146, 147, 148]),
  ) // 读数腿  夹具 ABCxyz ⇒ [\u005c]\u0092\u0093\u0094
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), -26, num_on),
    cc3([100, 101, 108, 109]),
  ) // 读数腿  夹具 0189 ⇒ delm
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), -26, num_on),
    cc3([123, 100, 148, 109]),
  ) // 读数腿  夹具 a0z9 ⇒ {d\u0094m
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), -26, num_on),
    cc3([32, 101, 33, 148, 116]),
  ) // 读数腿  夹具  1!zZ ⇒  e!\u0094t
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -26,
      num_on,
    ),
    cc3([98, 127, 134, 134, 137, 44, 32, 113, 137, 140, 134, 126, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ b\u007f\u0086\u0086\u0089, q\u0089\u008c\u0086~!
  assert_eq(@codec.rot_decode(cc3([20013]), -26, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), -26, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), -26, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), -26, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), -26, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), -26, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), -26, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), -26, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), -26, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), -26, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), -26, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=-13 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), -13, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), -13, num_off), cc3([78])) // 读数腿  夹具 A ⇒ N
  assert_eq(@codec.rot_decode(cc3([97]), -13, num_off), cc3([110])) // 读数腿  夹具 a ⇒ n
  assert_eq(@codec.rot_decode(cc3([90]), -13, num_off), cc3([103])) // 读数腿  夹具 Z ⇒ g
  assert_eq(@codec.rot_decode(cc3([122]), -13, num_off), cc3([135])) // 读数腿  夹具 z ⇒ \u0087
  assert_eq(@codec.rot_decode(cc3([48]), -13, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), -13, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), -13, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), -13, num_off),
    cc3([110, 111, 112, 101, 102, 103]),
  ) // 读数腿  夹具 abcXYZ ⇒ nopefg
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), -13, num_off),
    cc3([78, 79, 80, 133, 134, 135]),
  ) // 读数腿  夹具 ABCxyz ⇒ NOP\u0085\u0086\u0087
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), -13, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), -13, num_off),
    cc3([110, 48, 135, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ n0\u00879
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), -13, num_off),
    cc3([32, 49, 33, 135, 103]),
  ) // 读数腿  夹具  1!zZ ⇒  1!\u0087g
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -13,
      num_off,
    ),
    cc3([85, 114, 121, 121, 124, 44, 32, 100, 124, 127, 121, 113, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Uryy|, d|\u007fyq!
  assert_eq(@codec.rot_decode(cc3([20013]), -13, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), -13, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), -13, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), -13, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), -13, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), -13, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), -13, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), -13, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), -13, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), -13, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), -13, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=-13 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), -13, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), -13, num_on), cc3([78])) // 读数腿  夹具 A ⇒ N
  assert_eq(@codec.rot_decode(cc3([97]), -13, num_on), cc3([110])) // 读数腿  夹具 a ⇒ n
  assert_eq(@codec.rot_decode(cc3([90]), -13, num_on), cc3([103])) // 读数腿  夹具 Z ⇒ g
  assert_eq(@codec.rot_decode(cc3([122]), -13, num_on), cc3([135])) // 读数腿  夹具 z ⇒ \u0087
  assert_eq(@codec.rot_decode(cc3([48]), -13, num_on), cc3([61])) // 读数腿  夹具 0 ⇒ =
  assert_eq(@codec.rot_decode(cc3([57]), -13, num_on), cc3([83])) // 读数腿  夹具 9 ⇒ S
  assert_eq(@codec.rot_decode(cc3([53]), -13, num_on), cc3([79])) // 读数腿  夹具 5 ⇒ O
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), -13, num_on),
    cc3([110, 111, 112, 101, 102, 103]),
  ) // 读数腿  夹具 abcXYZ ⇒ nopefg
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), -13, num_on),
    cc3([78, 79, 80, 133, 134, 135]),
  ) // 读数腿  夹具 ABCxyz ⇒ NOP\u0085\u0086\u0087
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), -13, num_on),
    cc3([61, 62, 82, 83]),
  ) // 读数腿  夹具 0189 ⇒ =>RS
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), -13, num_on),
    cc3([110, 61, 135, 83]),
  ) // 读数腿  夹具 a0z9 ⇒ n=\u0087S
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), -13, num_on),
    cc3([32, 62, 33, 135, 103]),
  ) // 读数腿  夹具  1!zZ ⇒  >!\u0087g
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -13,
      num_on,
    ),
    cc3([85, 114, 121, 121, 124, 44, 32, 100, 124, 127, 121, 113, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Uryy|, d|\u007fyq!
  assert_eq(@codec.rot_decode(cc3([20013]), -13, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), -13, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), -13, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), -13, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), -13, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), -13, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), -13, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), -13, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), -13, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), -13, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), -13, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=-10 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), -10, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), -10, num_off), cc3([75])) // 读数腿  夹具 A ⇒ K
  assert_eq(@codec.rot_decode(cc3([97]), -10, num_off), cc3([107])) // 读数腿  夹具 a ⇒ k
  assert_eq(@codec.rot_decode(cc3([90]), -10, num_off), cc3([100])) // 读数腿  夹具 Z ⇒ d
  assert_eq(@codec.rot_decode(cc3([122]), -10, num_off), cc3([132])) // 读数腿  夹具 z ⇒ \u0084
  assert_eq(@codec.rot_decode(cc3([48]), -10, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), -10, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), -10, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), -10, num_off),
    cc3([107, 108, 109, 98, 99, 100]),
  ) // 读数腿  夹具 abcXYZ ⇒ klmbcd
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), -10, num_off),
    cc3([75, 76, 77, 130, 131, 132]),
  ) // 读数腿  夹具 ABCxyz ⇒ KLM\u0082\u0083\u0084
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), -10, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), -10, num_off),
    cc3([107, 48, 132, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ k0\u00849
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), -10, num_off),
    cc3([32, 49, 33, 132, 100]),
  ) // 读数腿  夹具  1!zZ ⇒  1!\u0084d
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -10,
      num_off,
    ),
    cc3([82, 111, 118, 118, 121, 44, 32, 97, 121, 124, 118, 110, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Rovvy, ay|vn!
  assert_eq(@codec.rot_decode(cc3([20013]), -10, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), -10, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), -10, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), -10, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), -10, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), -10, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), -10, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), -10, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), -10, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), -10, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), -10, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=-10 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), -10, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), -10, num_on), cc3([75])) // 读数腿  夹具 A ⇒ K
  assert_eq(@codec.rot_decode(cc3([97]), -10, num_on), cc3([107])) // 读数腿  夹具 a ⇒ k
  assert_eq(@codec.rot_decode(cc3([90]), -10, num_on), cc3([100])) // 读数腿  夹具 Z ⇒ d
  assert_eq(@codec.rot_decode(cc3([122]), -10, num_on), cc3([132])) // 读数腿  夹具 z ⇒ \u0084
  assert_eq(@codec.rot_decode(cc3([48]), -10, num_on), cc3([58])) // 读数腿  夹具 0 ⇒ :
  assert_eq(@codec.rot_decode(cc3([57]), -10, num_on), cc3([77])) // 读数腿  夹具 9 ⇒ M
  assert_eq(@codec.rot_decode(cc3([53]), -10, num_on), cc3([63])) // 读数腿  夹具 5 ⇒ ?
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), -10, num_on),
    cc3([107, 108, 109, 98, 99, 100]),
  ) // 读数腿  夹具 abcXYZ ⇒ klmbcd
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), -10, num_on),
    cc3([75, 76, 77, 130, 131, 132]),
  ) // 读数腿  夹具 ABCxyz ⇒ KLM\u0082\u0083\u0084
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), -10, num_on),
    cc3([58, 59, 76, 77]),
  ) // 读数腿  夹具 0189 ⇒ :;LM
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), -10, num_on),
    cc3([107, 58, 132, 77]),
  ) // 读数腿  夹具 a0z9 ⇒ k:\u0084M
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), -10, num_on),
    cc3([32, 59, 33, 132, 100]),
  ) // 读数腿  夹具  1!zZ ⇒  ;!\u0084d
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -10,
      num_on,
    ),
    cc3([82, 111, 118, 118, 121, 44, 32, 97, 121, 124, 118, 110, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Rovvy, ay|vn!
  assert_eq(@codec.rot_decode(cc3([20013]), -10, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), -10, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), -10, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), -10, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), -10, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), -10, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), -10, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), -10, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), -10, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), -10, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), -10, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=-1 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), -1, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), -1, num_off), cc3([66])) // 读数腿  夹具 A ⇒ B
  assert_eq(@codec.rot_decode(cc3([97]), -1, num_off), cc3([98])) // 读数腿  夹具 a ⇒ b
  assert_eq(@codec.rot_decode(cc3([90]), -1, num_off), cc3([91])) // 读数腿  夹具 Z ⇒ [
  assert_eq(@codec.rot_decode(cc3([122]), -1, num_off), cc3([123])) // 读数腿  夹具 z ⇒ {
  assert_eq(@codec.rot_decode(cc3([48]), -1, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), -1, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), -1, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), -1, num_off),
    cc3([98, 99, 100, 89, 90, 91]),
  ) // 读数腿  夹具 abcXYZ ⇒ bcdYZ[
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), -1, num_off),
    cc3([66, 67, 68, 121, 122, 123]),
  ) // 读数腿  夹具 ABCxyz ⇒ BCDyz{
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), -1, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), -1, num_off),
    cc3([98, 48, 123, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ b0{9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), -1, num_off),
    cc3([32, 49, 33, 123, 91]),
  ) // 读数腿  夹具  1!zZ ⇒  1!{[
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -1,
      num_off,
    ),
    cc3([73, 102, 109, 109, 112, 44, 32, 88, 112, 115, 109, 101, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Ifmmp, Xpsme!
  assert_eq(@codec.rot_decode(cc3([20013]), -1, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), -1, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), -1, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), -1, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), -1, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), -1, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), -1, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), -1, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), -1, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), -1, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), -1, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=-1 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), -1, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), -1, num_on), cc3([66])) // 读数腿  夹具 A ⇒ B
  assert_eq(@codec.rot_decode(cc3([97]), -1, num_on), cc3([98])) // 读数腿  夹具 a ⇒ b
  assert_eq(@codec.rot_decode(cc3([90]), -1, num_on), cc3([91])) // 读数腿  夹具 Z ⇒ [
  assert_eq(@codec.rot_decode(cc3([122]), -1, num_on), cc3([123])) // 读数腿  夹具 z ⇒ {
  assert_eq(@codec.rot_decode(cc3([48]), -1, num_on), cc3([49])) // 读数腿  夹具 0 ⇒ 1
  assert_eq(@codec.rot_decode(cc3([57]), -1, num_on), cc3([58])) // 读数腿  夹具 9 ⇒ :
  assert_eq(@codec.rot_decode(cc3([53]), -1, num_on), cc3([54])) // 读数腿  夹具 5 ⇒ 6
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), -1, num_on),
    cc3([98, 99, 100, 89, 90, 91]),
  ) // 读数腿  夹具 abcXYZ ⇒ bcdYZ[
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), -1, num_on),
    cc3([66, 67, 68, 121, 122, 123]),
  ) // 读数腿  夹具 ABCxyz ⇒ BCDyz{
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), -1, num_on),
    cc3([49, 50, 57, 58]),
  ) // 读数腿  夹具 0189 ⇒ 129:
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), -1, num_on),
    cc3([98, 49, 123, 58]),
  ) // 读数腿  夹具 a0z9 ⇒ b1{:
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), -1, num_on),
    cc3([32, 50, 33, 123, 91]),
  ) // 读数腿  夹具  1!zZ ⇒  2!{[
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      -1,
      num_on,
    ),
    cc3([73, 102, 109, 109, 112, 44, 32, 88, 112, 115, 109, 101, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Ifmmp, Xpsme!
  assert_eq(@codec.rot_decode(cc3([20013]), -1, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), -1, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), -1, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), -1, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), -1, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), -1, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), -1, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), -1, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), -1, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), -1, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), -1, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=0 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 0, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 0, num_off), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_decode(cc3([97]), 0, num_off), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_decode(cc3([90]), 0, num_off), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_decode(cc3([122]), 0, num_off), cc3([122])) // 读数腿  夹具 z ⇒ z
  assert_eq(@codec.rot_decode(cc3([48]), 0, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), 0, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), 0, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 0, num_off),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ abcXYZ
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 0, num_off),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABCxyz
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 0, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 0, num_off),
    cc3([97, 48, 122, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ a0z9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 0, num_off),
    cc3([32, 49, 33, 122, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  1!zZ
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      0,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Hello, World!
  assert_eq(@codec.rot_decode(cc3([20013]), 0, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 0, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 0, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 0, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 0, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 0, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 0, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 0, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 0, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 0, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 0, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=0 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 0, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 0, num_on), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_decode(cc3([97]), 0, num_on), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_decode(cc3([90]), 0, num_on), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_decode(cc3([122]), 0, num_on), cc3([122])) // 读数腿  夹具 z ⇒ z
  assert_eq(@codec.rot_decode(cc3([48]), 0, num_on), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), 0, num_on), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), 0, num_on), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 0, num_on),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ abcXYZ
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 0, num_on),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABCxyz
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 0, num_on),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 0, num_on),
    cc3([97, 48, 122, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ a0z9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 0, num_on),
    cc3([32, 49, 33, 122, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  1!zZ
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      0,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Hello, World!
  assert_eq(@codec.rot_decode(cc3([20013]), 0, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 0, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 0, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 0, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 0, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 0, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 0, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 0, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 0, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 0, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 0, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=1 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 1, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 1, num_off), cc3([90])) // 读数腿  夹具 A ⇒ Z
  assert_eq(@codec.rot_decode(cc3([97]), 1, num_off), cc3([122])) // 读数腿  夹具 a ⇒ z
  assert_eq(@codec.rot_decode(cc3([90]), 1, num_off), cc3([89])) // 读数腿  夹具 Z ⇒ Y
  assert_eq(@codec.rot_decode(cc3([122]), 1, num_off), cc3([121])) // 读数腿  夹具 z ⇒ y
  assert_eq(@codec.rot_decode(cc3([48]), 1, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), 1, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), 1, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 1, num_off),
    cc3([122, 97, 98, 87, 88, 89]),
  ) // 读数腿  夹具 abcXYZ ⇒ zabWXY
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 1, num_off),
    cc3([90, 65, 66, 119, 120, 121]),
  ) // 读数腿  夹具 ABCxyz ⇒ ZABwxy
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 1, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 1, num_off),
    cc3([122, 48, 121, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ z0y9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 1, num_off),
    cc3([32, 49, 33, 121, 89]),
  ) // 读数腿  夹具  1!zZ ⇒  1!yY
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      1,
      num_off,
    ),
    cc3([71, 100, 107, 107, 110, 44, 32, 86, 110, 113, 107, 99, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Gdkkn, Vnqkc!
  assert_eq(@codec.rot_decode(cc3([20013]), 1, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 1, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 1, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 1, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 1, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 1, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 1, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 1, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 1, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 1, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 1, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=1 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 1, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 1, num_on), cc3([90])) // 读数腿  夹具 A ⇒ Z
  assert_eq(@codec.rot_decode(cc3([97]), 1, num_on), cc3([122])) // 读数腿  夹具 a ⇒ z
  assert_eq(@codec.rot_decode(cc3([90]), 1, num_on), cc3([89])) // 读数腿  夹具 Z ⇒ Y
  assert_eq(@codec.rot_decode(cc3([122]), 1, num_on), cc3([121])) // 读数腿  夹具 z ⇒ y
  assert_eq(@codec.rot_decode(cc3([48]), 1, num_on), cc3([57])) // 读数腿  夹具 0 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([57]), 1, num_on), cc3([56])) // 读数腿  夹具 9 ⇒ 8
  assert_eq(@codec.rot_decode(cc3([53]), 1, num_on), cc3([52])) // 读数腿  夹具 5 ⇒ 4
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 1, num_on),
    cc3([122, 97, 98, 87, 88, 89]),
  ) // 读数腿  夹具 abcXYZ ⇒ zabWXY
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 1, num_on),
    cc3([90, 65, 66, 119, 120, 121]),
  ) // 读数腿  夹具 ABCxyz ⇒ ZABwxy
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 1, num_on),
    cc3([57, 48, 55, 56]),
  ) // 读数腿  夹具 0189 ⇒ 9078
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 1, num_on),
    cc3([122, 57, 121, 56]),
  ) // 读数腿  夹具 a0z9 ⇒ z9y8
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 1, num_on),
    cc3([32, 48, 33, 121, 89]),
  ) // 读数腿  夹具  1!zZ ⇒  0!yY
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      1,
      num_on,
    ),
    cc3([71, 100, 107, 107, 110, 44, 32, 86, 110, 113, 107, 99, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Gdkkn, Vnqkc!
  assert_eq(@codec.rot_decode(cc3([20013]), 1, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 1, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 1, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 1, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 1, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 1, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 1, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 1, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 1, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 1, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 1, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=5 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 5, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 5, num_off), cc3([86])) // 读数腿  夹具 A ⇒ V
  assert_eq(@codec.rot_decode(cc3([97]), 5, num_off), cc3([118])) // 读数腿  夹具 a ⇒ v
  assert_eq(@codec.rot_decode(cc3([90]), 5, num_off), cc3([85])) // 读数腿  夹具 Z ⇒ U
  assert_eq(@codec.rot_decode(cc3([122]), 5, num_off), cc3([117])) // 读数腿  夹具 z ⇒ u
  assert_eq(@codec.rot_decode(cc3([48]), 5, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), 5, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), 5, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 5, num_off),
    cc3([118, 119, 120, 83, 84, 85]),
  ) // 读数腿  夹具 abcXYZ ⇒ vwxSTU
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 5, num_off),
    cc3([86, 87, 88, 115, 116, 117]),
  ) // 读数腿  夹具 ABCxyz ⇒ VWXstu
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 5, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 5, num_off),
    cc3([118, 48, 117, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ v0u9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 5, num_off),
    cc3([32, 49, 33, 117, 85]),
  ) // 读数腿  夹具  1!zZ ⇒  1!uU
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      5,
      num_off,
    ),
    cc3([67, 122, 103, 103, 106, 44, 32, 82, 106, 109, 103, 121, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Czggj, Rjmgy!
  assert_eq(@codec.rot_decode(cc3([20013]), 5, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 5, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 5, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 5, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 5, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 5, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 5, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 5, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 5, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 5, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 5, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=5 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 5, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 5, num_on), cc3([86])) // 读数腿  夹具 A ⇒ V
  assert_eq(@codec.rot_decode(cc3([97]), 5, num_on), cc3([118])) // 读数腿  夹具 a ⇒ v
  assert_eq(@codec.rot_decode(cc3([90]), 5, num_on), cc3([85])) // 读数腿  夹具 Z ⇒ U
  assert_eq(@codec.rot_decode(cc3([122]), 5, num_on), cc3([117])) // 读数腿  夹具 z ⇒ u
  assert_eq(@codec.rot_decode(cc3([48]), 5, num_on), cc3([53])) // 读数腿  夹具 0 ⇒ 5
  assert_eq(@codec.rot_decode(cc3([57]), 5, num_on), cc3([52])) // 读数腿  夹具 9 ⇒ 4
  assert_eq(@codec.rot_decode(cc3([53]), 5, num_on), cc3([48])) // 读数腿  夹具 5 ⇒ 0
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 5, num_on),
    cc3([118, 119, 120, 83, 84, 85]),
  ) // 读数腿  夹具 abcXYZ ⇒ vwxSTU
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 5, num_on),
    cc3([86, 87, 88, 115, 116, 117]),
  ) // 读数腿  夹具 ABCxyz ⇒ VWXstu
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 5, num_on),
    cc3([53, 54, 51, 52]),
  ) // 读数腿  夹具 0189 ⇒ 5634
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 5, num_on),
    cc3([118, 53, 117, 52]),
  ) // 读数腿  夹具 a0z9 ⇒ v5u4
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 5, num_on),
    cc3([32, 54, 33, 117, 85]),
  ) // 读数腿  夹具  1!zZ ⇒  6!uU
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      5,
      num_on,
    ),
    cc3([67, 122, 103, 103, 106, 44, 32, 82, 106, 109, 103, 121, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Czggj, Rjmgy!
  assert_eq(@codec.rot_decode(cc3([20013]), 5, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 5, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 5, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 5, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 5, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 5, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 5, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 5, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 5, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 5, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 5, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=10 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 10, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 10, num_off), cc3([81])) // 读数腿  夹具 A ⇒ Q
  assert_eq(@codec.rot_decode(cc3([97]), 10, num_off), cc3([113])) // 读数腿  夹具 a ⇒ q
  assert_eq(@codec.rot_decode(cc3([90]), 10, num_off), cc3([80])) // 读数腿  夹具 Z ⇒ P
  assert_eq(@codec.rot_decode(cc3([122]), 10, num_off), cc3([112])) // 读数腿  夹具 z ⇒ p
  assert_eq(@codec.rot_decode(cc3([48]), 10, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), 10, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), 10, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 10, num_off),
    cc3([113, 114, 115, 78, 79, 80]),
  ) // 读数腿  夹具 abcXYZ ⇒ qrsNOP
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 10, num_off),
    cc3([81, 82, 83, 110, 111, 112]),
  ) // 读数腿  夹具 ABCxyz ⇒ QRSnop
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 10, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 10, num_off),
    cc3([113, 48, 112, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ q0p9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 10, num_off),
    cc3([32, 49, 33, 112, 80]),
  ) // 读数腿  夹具  1!zZ ⇒  1!pP
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      10,
      num_off,
    ),
    cc3([88, 117, 98, 98, 101, 44, 32, 77, 101, 104, 98, 116, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Xubbe, Mehbt!
  assert_eq(@codec.rot_decode(cc3([20013]), 10, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 10, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 10, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 10, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 10, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 10, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 10, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 10, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 10, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 10, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 10, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=10 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 10, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 10, num_on), cc3([81])) // 读数腿  夹具 A ⇒ Q
  assert_eq(@codec.rot_decode(cc3([97]), 10, num_on), cc3([113])) // 读数腿  夹具 a ⇒ q
  assert_eq(@codec.rot_decode(cc3([90]), 10, num_on), cc3([80])) // 读数腿  夹具 Z ⇒ P
  assert_eq(@codec.rot_decode(cc3([122]), 10, num_on), cc3([112])) // 读数腿  夹具 z ⇒ p
  assert_eq(@codec.rot_decode(cc3([48]), 10, num_on), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), 10, num_on), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), 10, num_on), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 10, num_on),
    cc3([113, 114, 115, 78, 79, 80]),
  ) // 读数腿  夹具 abcXYZ ⇒ qrsNOP
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 10, num_on),
    cc3([81, 82, 83, 110, 111, 112]),
  ) // 读数腿  夹具 ABCxyz ⇒ QRSnop
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 10, num_on),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 10, num_on),
    cc3([113, 48, 112, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ q0p9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 10, num_on),
    cc3([32, 49, 33, 112, 80]),
  ) // 读数腿  夹具  1!zZ ⇒  1!pP
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      10,
      num_on,
    ),
    cc3([88, 117, 98, 98, 101, 44, 32, 77, 101, 104, 98, 116, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Xubbe, Mehbt!
  assert_eq(@codec.rot_decode(cc3([20013]), 10, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 10, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 10, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 10, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 10, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 10, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 10, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 10, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 10, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 10, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 10, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=13 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 13, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 13, num_off), cc3([78])) // 读数腿  夹具 A ⇒ N
  assert_eq(@codec.rot_decode(cc3([97]), 13, num_off), cc3([110])) // 读数腿  夹具 a ⇒ n
  assert_eq(@codec.rot_decode(cc3([90]), 13, num_off), cc3([77])) // 读数腿  夹具 Z ⇒ M
  assert_eq(@codec.rot_decode(cc3([122]), 13, num_off), cc3([109])) // 读数腿  夹具 z ⇒ m
  assert_eq(@codec.rot_decode(cc3([48]), 13, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), 13, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), 13, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 13, num_off),
    cc3([110, 111, 112, 75, 76, 77]),
  ) // 读数腿  夹具 abcXYZ ⇒ nopKLM
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 13, num_off),
    cc3([78, 79, 80, 107, 108, 109]),
  ) // 读数腿  夹具 ABCxyz ⇒ NOPklm
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 13, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 13, num_off),
    cc3([110, 48, 109, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ n0m9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 13, num_off),
    cc3([32, 49, 33, 109, 77]),
  ) // 读数腿  夹具  1!zZ ⇒  1!mM
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      13,
      num_off,
    ),
    cc3([85, 114, 121, 121, 98, 44, 32, 74, 98, 101, 121, 113, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Uryyb, Jbeyq!
  assert_eq(@codec.rot_decode(cc3([20013]), 13, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 13, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 13, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 13, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 13, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 13, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 13, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 13, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 13, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 13, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 13, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=13 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 13, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 13, num_on), cc3([78])) // 读数腿  夹具 A ⇒ N
  assert_eq(@codec.rot_decode(cc3([97]), 13, num_on), cc3([110])) // 读数腿  夹具 a ⇒ n
  assert_eq(@codec.rot_decode(cc3([90]), 13, num_on), cc3([77])) // 读数腿  夹具 Z ⇒ M
  assert_eq(@codec.rot_decode(cc3([122]), 13, num_on), cc3([109])) // 读数腿  夹具 z ⇒ m
  assert_eq(@codec.rot_decode(cc3([48]), 13, num_on), cc3([55])) // 读数腿  夹具 0 ⇒ 7
  assert_eq(@codec.rot_decode(cc3([57]), 13, num_on), cc3([54])) // 读数腿  夹具 9 ⇒ 6
  assert_eq(@codec.rot_decode(cc3([53]), 13, num_on), cc3([50])) // 读数腿  夹具 5 ⇒ 2
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 13, num_on),
    cc3([110, 111, 112, 75, 76, 77]),
  ) // 读数腿  夹具 abcXYZ ⇒ nopKLM
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 13, num_on),
    cc3([78, 79, 80, 107, 108, 109]),
  ) // 读数腿  夹具 ABCxyz ⇒ NOPklm
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 13, num_on),
    cc3([55, 56, 53, 54]),
  ) // 读数腿  夹具 0189 ⇒ 7856
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 13, num_on),
    cc3([110, 55, 109, 54]),
  ) // 读数腿  夹具 a0z9 ⇒ n7m6
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 13, num_on),
    cc3([32, 56, 33, 109, 77]),
  ) // 读数腿  夹具  1!zZ ⇒  8!mM
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      13,
      num_on,
    ),
    cc3([85, 114, 121, 121, 98, 44, 32, 74, 98, 101, 121, 113, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Uryyb, Jbeyq!
  assert_eq(@codec.rot_decode(cc3([20013]), 13, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 13, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 13, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 13, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 13, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 13, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 13, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 13, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 13, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 13, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 13, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=25 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 25, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 25, num_off), cc3([66])) // 读数腿  夹具 A ⇒ B
  assert_eq(@codec.rot_decode(cc3([97]), 25, num_off), cc3([98])) // 读数腿  夹具 a ⇒ b
  assert_eq(@codec.rot_decode(cc3([90]), 25, num_off), cc3([65])) // 读数腿  夹具 Z ⇒ A
  assert_eq(@codec.rot_decode(cc3([122]), 25, num_off), cc3([97])) // 读数腿  夹具 z ⇒ a
  assert_eq(@codec.rot_decode(cc3([48]), 25, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), 25, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), 25, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 25, num_off),
    cc3([98, 99, 100, 89, 90, 65]),
  ) // 读数腿  夹具 abcXYZ ⇒ bcdYZA
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 25, num_off),
    cc3([66, 67, 68, 121, 122, 97]),
  ) // 读数腿  夹具 ABCxyz ⇒ BCDyza
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 25, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 25, num_off),
    cc3([98, 48, 97, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ b0a9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 25, num_off),
    cc3([32, 49, 33, 97, 65]),
  ) // 读数腿  夹具  1!zZ ⇒  1!aA
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      25,
      num_off,
    ),
    cc3([73, 102, 109, 109, 112, 44, 32, 88, 112, 115, 109, 101, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Ifmmp, Xpsme!
  assert_eq(@codec.rot_decode(cc3([20013]), 25, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 25, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 25, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 25, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 25, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 25, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 25, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 25, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 25, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 25, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 25, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=25 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 25, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 25, num_on), cc3([66])) // 读数腿  夹具 A ⇒ B
  assert_eq(@codec.rot_decode(cc3([97]), 25, num_on), cc3([98])) // 读数腿  夹具 a ⇒ b
  assert_eq(@codec.rot_decode(cc3([90]), 25, num_on), cc3([65])) // 读数腿  夹具 Z ⇒ A
  assert_eq(@codec.rot_decode(cc3([122]), 25, num_on), cc3([97])) // 读数腿  夹具 z ⇒ a
  assert_eq(@codec.rot_decode(cc3([48]), 25, num_on), cc3([53])) // 读数腿  夹具 0 ⇒ 5
  assert_eq(@codec.rot_decode(cc3([57]), 25, num_on), cc3([52])) // 读数腿  夹具 9 ⇒ 4
  assert_eq(@codec.rot_decode(cc3([53]), 25, num_on), cc3([48])) // 读数腿  夹具 5 ⇒ 0
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 25, num_on),
    cc3([98, 99, 100, 89, 90, 65]),
  ) // 读数腿  夹具 abcXYZ ⇒ bcdYZA
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 25, num_on),
    cc3([66, 67, 68, 121, 122, 97]),
  ) // 读数腿  夹具 ABCxyz ⇒ BCDyza
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 25, num_on),
    cc3([53, 54, 51, 52]),
  ) // 读数腿  夹具 0189 ⇒ 5634
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 25, num_on),
    cc3([98, 53, 97, 52]),
  ) // 读数腿  夹具 a0z9 ⇒ b5a4
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 25, num_on),
    cc3([32, 54, 33, 97, 65]),
  ) // 读数腿  夹具  1!zZ ⇒  6!aA
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      25,
      num_on,
    ),
    cc3([73, 102, 109, 109, 112, 44, 32, 88, 112, 115, 109, 101, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Ifmmp, Xpsme!
  assert_eq(@codec.rot_decode(cc3([20013]), 25, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 25, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 25, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 25, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 25, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 25, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 25, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 25, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 25, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 25, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 25, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=26 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 26, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 26, num_off), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_decode(cc3([97]), 26, num_off), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_decode(cc3([90]), 26, num_off), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_decode(cc3([122]), 26, num_off), cc3([122])) // 读数腿  夹具 z ⇒ z
  assert_eq(@codec.rot_decode(cc3([48]), 26, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), 26, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), 26, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 26, num_off),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ abcXYZ
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 26, num_off),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABCxyz
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 26, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 26, num_off),
    cc3([97, 48, 122, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ a0z9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 26, num_off),
    cc3([32, 49, 33, 122, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  1!zZ
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      26,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Hello, World!
  assert_eq(@codec.rot_decode(cc3([20013]), 26, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 26, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 26, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 26, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 26, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 26, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 26, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 26, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 26, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 26, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 26, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=26 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 26, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 26, num_on), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_decode(cc3([97]), 26, num_on), cc3([97])) // 读数腿  夹具 a ⇒ a
  assert_eq(@codec.rot_decode(cc3([90]), 26, num_on), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_decode(cc3([122]), 26, num_on), cc3([122])) // 读数腿  夹具 z ⇒ z
  assert_eq(@codec.rot_decode(cc3([48]), 26, num_on), cc3([52])) // 读数腿  夹具 0 ⇒ 4
  assert_eq(@codec.rot_decode(cc3([57]), 26, num_on), cc3([51])) // 读数腿  夹具 9 ⇒ 3
  assert_eq(@codec.rot_decode(cc3([53]), 26, num_on), cc3([57])) // 读数腿  夹具 5 ⇒ 9
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 26, num_on),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ abcXYZ
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 26, num_on),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABCxyz
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 26, num_on),
    cc3([52, 53, 50, 51]),
  ) // 读数腿  夹具 0189 ⇒ 4523
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 26, num_on),
    cc3([97, 52, 122, 51]),
  ) // 读数腿  夹具 a0z9 ⇒ a4z3
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 26, num_on),
    cc3([32, 53, 33, 122, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  5!zZ
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      26,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Hello, World!
  assert_eq(@codec.rot_decode(cc3([20013]), 26, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 26, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 26, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 26, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 26, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 26, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 26, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 26, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 26, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 26, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 26, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=27 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 27, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 27, num_off), cc3([90])) // 读数腿  夹具 A ⇒ Z
  assert_eq(@codec.rot_decode(cc3([97]), 27, num_off), cc3([96])) // 读数腿  夹具 a ⇒ `
  assert_eq(@codec.rot_decode(cc3([90]), 27, num_off), cc3([89])) // 读数腿  夹具 Z ⇒ Y
  assert_eq(@codec.rot_decode(cc3([122]), 27, num_off), cc3([121])) // 读数腿  夹具 z ⇒ y
  assert_eq(@codec.rot_decode(cc3([48]), 27, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), 27, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), 27, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 27, num_off),
    cc3([96, 97, 98, 87, 88, 89]),
  ) // 读数腿  夹具 abcXYZ ⇒ `abWXY
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 27, num_off),
    cc3([90, 65, 66, 119, 120, 121]),
  ) // 读数腿  夹具 ABCxyz ⇒ ZABwxy
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 27, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 27, num_off),
    cc3([96, 48, 121, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ `0y9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 27, num_off),
    cc3([32, 49, 33, 121, 89]),
  ) // 读数腿  夹具  1!zZ ⇒  1!yY
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      27,
      num_off,
    ),
    cc3([71, 100, 107, 107, 110, 44, 32, 86, 110, 113, 107, 99, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Gdkkn, Vnqkc!
  assert_eq(@codec.rot_decode(cc3([20013]), 27, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 27, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 27, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 27, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 27, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 27, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 27, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 27, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 27, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 27, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 27, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=27 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 27, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 27, num_on), cc3([90])) // 读数腿  夹具 A ⇒ Z
  assert_eq(@codec.rot_decode(cc3([97]), 27, num_on), cc3([96])) // 读数腿  夹具 a ⇒ `
  assert_eq(@codec.rot_decode(cc3([90]), 27, num_on), cc3([89])) // 读数腿  夹具 Z ⇒ Y
  assert_eq(@codec.rot_decode(cc3([122]), 27, num_on), cc3([121])) // 读数腿  夹具 z ⇒ y
  assert_eq(@codec.rot_decode(cc3([48]), 27, num_on), cc3([51])) // 读数腿  夹具 0 ⇒ 3
  assert_eq(@codec.rot_decode(cc3([57]), 27, num_on), cc3([50])) // 读数腿  夹具 9 ⇒ 2
  assert_eq(@codec.rot_decode(cc3([53]), 27, num_on), cc3([56])) // 读数腿  夹具 5 ⇒ 8
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 27, num_on),
    cc3([96, 97, 98, 87, 88, 89]),
  ) // 读数腿  夹具 abcXYZ ⇒ `abWXY
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 27, num_on),
    cc3([90, 65, 66, 119, 120, 121]),
  ) // 读数腿  夹具 ABCxyz ⇒ ZABwxy
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 27, num_on),
    cc3([51, 52, 49, 50]),
  ) // 读数腿  夹具 0189 ⇒ 3412
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 27, num_on),
    cc3([96, 51, 121, 50]),
  ) // 读数腿  夹具 a0z9 ⇒ `3y2
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 27, num_on),
    cc3([32, 52, 33, 121, 89]),
  ) // 读数腿  夹具  1!zZ ⇒  4!yY
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      27,
      num_on,
    ),
    cc3([71, 100, 107, 107, 110, 44, 32, 86, 110, 113, 107, 99, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ Gdkkn, Vnqkc!
  assert_eq(@codec.rot_decode(cc3([20013]), 27, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 27, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 27, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 27, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 27, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 27, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 27, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 27, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 27, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 27, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 27, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=52 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 52, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 52, num_off), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_decode(cc3([97]), 52, num_off), cc3([71])) // 读数腿  夹具 a ⇒ G
  assert_eq(@codec.rot_decode(cc3([90]), 52, num_off), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_decode(cc3([122]), 52, num_off), cc3([96])) // 读数腿  夹具 z ⇒ `
  assert_eq(@codec.rot_decode(cc3([48]), 52, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), 52, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), 52, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 52, num_off),
    cc3([71, 72, 73, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ GHIXYZ
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 52, num_off),
    cc3([65, 66, 67, 94, 95, 96]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABC^_`
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 52, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 52, num_off),
    cc3([71, 48, 96, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ G0`9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 52, num_off),
    cc3([32, 49, 33, 96, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  1!`Z
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      52,
      num_off,
    ),
    cc3([72, 75, 82, 82, 85, 44, 32, 87, 85, 88, 82, 74, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ HKRRU, WUXRJ!
  assert_eq(@codec.rot_decode(cc3([20013]), 52, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 52, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 52, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 52, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 52, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 52, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 52, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 52, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 52, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 52, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 52, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=52 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 52, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 52, num_on), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_decode(cc3([97]), 52, num_on), cc3([71])) // 读数腿  夹具 a ⇒ G
  assert_eq(@codec.rot_decode(cc3([90]), 52, num_on), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_decode(cc3([122]), 52, num_on), cc3([96])) // 读数腿  夹具 z ⇒ `
  assert_eq(@codec.rot_decode(cc3([48]), 52, num_on), cc3([56])) // 读数腿  夹具 0 ⇒ 8
  assert_eq(@codec.rot_decode(cc3([57]), 52, num_on), cc3([55])) // 读数腿  夹具 9 ⇒ 7
  assert_eq(@codec.rot_decode(cc3([53]), 52, num_on), cc3([51])) // 读数腿  夹具 5 ⇒ 3
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 52, num_on),
    cc3([71, 72, 73, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ GHIXYZ
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 52, num_on),
    cc3([65, 66, 67, 94, 95, 96]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABC^_`
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 52, num_on),
    cc3([56, 57, 54, 55]),
  ) // 读数腿  夹具 0189 ⇒ 8967
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 52, num_on),
    cc3([71, 56, 96, 55]),
  ) // 读数腿  夹具 a0z9 ⇒ G8`7
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 52, num_on),
    cc3([32, 57, 33, 96, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  9!`Z
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      52,
      num_on,
    ),
    cc3([72, 75, 82, 82, 85, 44, 32, 87, 85, 88, 82, 74, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ HKRRU, WUXRJ!
  assert_eq(@codec.rot_decode(cc3([20013]), 52, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 52, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 52, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 52, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 52, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 52, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 52, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 52, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 52, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 52, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 52, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=104 num_off（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 104, num_off), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 104, num_off), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_decode(cc3([97]), 104, num_off), cc3([19])) // 读数腿  夹具 a ⇒ \u0013
  assert_eq(@codec.rot_decode(cc3([90]), 104, num_off), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_decode(cc3([122]), 104, num_off), cc3([44])) // 读数腿  夹具 z ⇒ ,
  assert_eq(@codec.rot_decode(cc3([48]), 104, num_off), cc3([48])) // 读数腿  夹具 0 ⇒ 0
  assert_eq(@codec.rot_decode(cc3([57]), 104, num_off), cc3([57])) // 读数腿  夹具 9 ⇒ 9
  assert_eq(@codec.rot_decode(cc3([53]), 104, num_off), cc3([53])) // 读数腿  夹具 5 ⇒ 5
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 104, num_off),
    cc3([19, 20, 21, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ \u0013\u0014\u0015XYZ
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 104, num_off),
    cc3([65, 66, 67, 42, 43, 44]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABC*+,
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 104, num_off),
    cc3([48, 49, 56, 57]),
  ) // 读数腿  夹具 0189 ⇒ 0189
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 104, num_off),
    cc3([19, 48, 44, 57]),
  ) // 读数腿  夹具 a0z9 ⇒ \u00130,9
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 104, num_off),
    cc3([32, 49, 33, 44, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  1!,Z
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      104,
      num_off,
    ),
    cc3([72, 23, 30, 30, 33, 44, 32, 87, 33, 36, 30, 22, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ H\u0017\u001e\u001e!, W!$\u001e\u0016!
  assert_eq(@codec.rot_decode(cc3([20013]), 104, num_off), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 104, num_off), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 104, num_off), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 104, num_off), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 104, num_off), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 104, num_off), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 104, num_off), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 104, num_off), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 104, num_off), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 104, num_off), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 104, num_off), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 decode shift=104 num_on（25 档夹具）" {
  assert_eq(@codec.rot_decode(cc3([]), 104, num_on), cc3([])) // 读数腿  夹具  ⇒ 
  assert_eq(@codec.rot_decode(cc3([65]), 104, num_on), cc3([65])) // 读数腿  夹具 A ⇒ A
  assert_eq(@codec.rot_decode(cc3([97]), 104, num_on), cc3([19])) // 读数腿  夹具 a ⇒ \u0013
  assert_eq(@codec.rot_decode(cc3([90]), 104, num_on), cc3([90])) // 读数腿  夹具 Z ⇒ Z
  assert_eq(@codec.rot_decode(cc3([122]), 104, num_on), cc3([44])) // 读数腿  夹具 z ⇒ ,
  assert_eq(@codec.rot_decode(cc3([48]), 104, num_on), cc3([54])) // 读数腿  夹具 0 ⇒ 6
  assert_eq(@codec.rot_decode(cc3([57]), 104, num_on), cc3([53])) // 读数腿  夹具 9 ⇒ 5
  assert_eq(@codec.rot_decode(cc3([53]), 104, num_on), cc3([49])) // 读数腿  夹具 5 ⇒ 1
  assert_eq(
    @codec.rot_decode(cc3([97, 98, 99, 88, 89, 90]), 104, num_on),
    cc3([19, 20, 21, 88, 89, 90]),
  ) // 读数腿  夹具 abcXYZ ⇒ \u0013\u0014\u0015XYZ
  assert_eq(
    @codec.rot_decode(cc3([65, 66, 67, 120, 121, 122]), 104, num_on),
    cc3([65, 66, 67, 42, 43, 44]),
  ) // 读数腿  夹具 ABCxyz ⇒ ABC*+,
  assert_eq(
    @codec.rot_decode(cc3([48, 49, 56, 57]), 104, num_on),
    cc3([54, 55, 52, 53]),
  ) // 读数腿  夹具 0189 ⇒ 6745
  assert_eq(
    @codec.rot_decode(cc3([97, 48, 122, 57]), 104, num_on),
    cc3([19, 54, 44, 53]),
  ) // 读数腿  夹具 a0z9 ⇒ \u00136,5
  assert_eq(
    @codec.rot_decode(cc3([32, 49, 33, 122, 90]), 104, num_on),
    cc3([32, 55, 33, 44, 90]),
  ) // 读数腿  夹具  1!zZ ⇒  7!,Z
  assert_eq(
    @codec.rot_decode(
      cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
      104,
      num_on,
    ),
    cc3([72, 23, 30, 30, 33, 44, 32, 87, 33, 36, 30, 22, 33]),
  ) // 读数腿  夹具 Hello, World! ⇒ H\u0017\u001e\u001e!, W!$\u001e\u0016!
  assert_eq(@codec.rot_decode(cc3([20013]), 104, num_on), cc3([20013])) // 读数腿  夹具 \u4e2d ⇒ \u4e2d
  assert_eq(@codec.rot_decode(cc3([233]), 104, num_on), cc3([233])) // 读数腿  夹具 \u00e9 ⇒ \u00e9
  assert_eq(@codec.rot_decode(cc3([937]), 104, num_on), cc3([937])) // 读数腿  夹具 \u03a9 ⇒ \u03a9
  assert_eq(@codec.rot_decode(cc3([223]), 104, num_on), cc3([223])) // 读数腿  夹具 \u00df ⇒ \u00df
  assert_eq(@codec.rot_decode(cc3([1635]), 104, num_on), cc3([1635])) // 读数腿  夹具 \u0663 ⇒ \u0663
  assert_eq(@codec.rot_decode(cc3([0]), 104, num_on), cc3([0])) // 读数腿  夹具 \u0000 ⇒ \u0000
  assert_eq(@codec.rot_decode(cc3([9]), 104, num_on), cc3([9])) // 读数腿  夹具 \u0009 ⇒ \u0009
  assert_eq(@codec.rot_decode(cc3([91]), 104, num_on), cc3([91])) // 读数腿  夹具 [ ⇒ [
  assert_eq(@codec.rot_decode(cc3([96]), 104, num_on), cc3([96])) // 读数腿  夹具 ` ⇒ `
  assert_eq(@codec.rot_decode(cc3([58]), 104, num_on), cc3([58])) // 读数腿  夹具 : ⇒ :
  assert_eq(@codec.rot_decode(cc3([64]), 104, num_on), cc3([64])) // 读数腿  夹具 @ ⇒ @
}

///|
test "codec #13.3 往返 shift=-104 num_off：16/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), -104, num_off), -104, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([169]),
  ) // 读数腿  不复原档 A ⇒ DIFF:\u00a9
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([201]),
  ) // 读数腿  不复原档 a ⇒ DIFF:\u00c9
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([90]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([64]),
  ) // 读数腿  不复原档 Z ⇒ DIFF:@
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([122]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([96]),
  ) // 读数腿  不复原档 z ⇒ DIFF:`
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([57]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([53]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([201, 176, 177, 62, 63, 64]),
  ) // 读数腿  不复原档 abcXYZ ⇒ DIFF:\u00c9\u00b0\u00b1>?@
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([169, 40, 41, 94, 95, 96]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:\u00a9()^_`
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([201, 48, 96, 57]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:\u00c90`9
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([32, 49, 33, 96, 64]),
  ) // 读数腿  不复原档  1!zZ ⇒ DIFF: 1!`@
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        -104,
        num_off,
      ),
      -104,
      num_off,
    ),
    cc3([46, 179, 186, 186, 189, 44, 32, 61, 189, 192, 186, 178, 33]),
  ) // 读数腿  不复原档 Hello, World! ⇒ DIFF:.\u00b3\u00ba\u00ba\u00bd, =\u00bd\u00c0\u00ba\u00b2!
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([20013]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([233]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([937]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([223]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([1635]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), -104, num_off), -104, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), -104, num_off), -104, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([91]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([96]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([58]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([64]), -104, num_off),
      -104,
      num_off,
    ),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=-104 num_on：12/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), -104, num_on), -104, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), -104, num_on), -104, num_on),
    cc3([169]),
  ) // 读数腿  不复原档 A ⇒ DIFF:\u00a9
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), -104, num_on), -104, num_on),
    cc3([201]),
  ) // 读数腿  不复原档 a ⇒ DIFF:\u00c9
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), -104, num_on), -104, num_on),
    cc3([64]),
  ) // 读数腿  不复原档 Z ⇒ DIFF:@
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), -104, num_on), -104, num_on),
    cc3([96]),
  ) // 读数腿  不复原档 z ⇒ DIFF:`
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), -104, num_on), -104, num_on),
    cc3([44]),
  ) // 读数腿  不复原档 0 ⇒ DIFF:,
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), -104, num_on), -104, num_on),
    cc3([43]),
  ) // 读数腿  不复原档 9 ⇒ DIFF:+
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), -104, num_on), -104, num_on),
    cc3([39]),
  ) // 读数腿  不复原档 5 ⇒ DIFF:'
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -104, num_on),
      -104,
      num_on,
    ),
    cc3([201, 176, 177, 62, 63, 64]),
  ) // 读数腿  不复原档 abcXYZ ⇒ DIFF:\u00c9\u00b0\u00b1>?@
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -104, num_on),
      -104,
      num_on,
    ),
    cc3([169, 40, 41, 94, 95, 96]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:\u00a9()^_`
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), -104, num_on),
      -104,
      num_on,
    ),
    cc3([44, 45, 42, 43]),
  ) // 读数腿  不复原档 0189 ⇒ DIFF:,-*+
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), -104, num_on),
      -104,
      num_on,
    ),
    cc3([201, 44, 96, 43]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:\u00c9,`+
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -104, num_on),
      -104,
      num_on,
    ),
    cc3([32, 45, 33, 96, 64]),
  ) // 读数腿  不复原档  1!zZ ⇒ DIFF: -!`@
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        -104,
        num_on,
      ),
      -104,
      num_on,
    ),
    cc3([46, 179, 186, 186, 189, 44, 32, 61, 189, 192, 186, 178, 33]),
  ) // 读数腿  不复原档 Hello, World! ⇒ DIFF:.\u00b3\u00ba\u00ba\u00bd, =\u00bd\u00c0\u00ba\u00b2!
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([20013]), -104, num_on),
      -104,
      num_on,
    ),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), -104, num_on), -104, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), -104, num_on), -104, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), -104, num_on), -104, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([1635]), -104, num_on),
      -104,
      num_on,
    ),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), -104, num_on), -104, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), -104, num_on), -104, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), -104, num_on), -104, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), -104, num_on), -104, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), -104, num_on), -104, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), -104, num_on), -104, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=-26 num_off：16/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), -26, num_off), -26, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), -26, num_off), -26, num_off),
    cc3([91]),
  ) // 读数腿  不复原档 A ⇒ DIFF:[
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), -26, num_off), -26, num_off),
    cc3([123]),
  ) // 读数腿  不复原档 a ⇒ DIFF:{
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), -26, num_off), -26, num_off),
    cc3([64]),
  ) // 读数腿  不复原档 Z ⇒ DIFF:@
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), -26, num_off), -26, num_off),
    cc3([96]),
  ) // 读数腿  不复原档 z ⇒ DIFF:`
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), -26, num_off), -26, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), -26, num_off), -26, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), -26, num_off), -26, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -26, num_off),
      -26,
      num_off,
    ),
    cc3([123, 98, 99, 62, 63, 64]),
  ) // 读数腿  不复原档 abcXYZ ⇒ DIFF:{bc>?@
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -26, num_off),
      -26,
      num_off,
    ),
    cc3([91, 40, 41, 94, 95, 96]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:[()^_`
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), -26, num_off),
      -26,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), -26, num_off),
      -26,
      num_off,
    ),
    cc3([123, 48, 96, 57]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:{0`9
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -26, num_off),
      -26,
      num_off,
    ),
    cc3([32, 49, 33, 96, 64]),
  ) // 读数腿  不复原档  1!zZ ⇒ DIFF: 1!`@
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        -26,
        num_off,
      ),
      -26,
      num_off,
    ),
    cc3([46, 101, 108, 108, 111, 44, 32, 61, 111, 114, 108, 100, 33]),
  ) // 读数腿  不复原档 Hello, World! ⇒ DIFF:.ello, =orld!
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([20013]), -26, num_off),
      -26,
      num_off,
    ),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), -26, num_off), -26, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), -26, num_off), -26, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), -26, num_off), -26, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([1635]), -26, num_off),
      -26,
      num_off,
    ),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), -26, num_off), -26, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), -26, num_off), -26, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), -26, num_off), -26, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), -26, num_off), -26, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), -26, num_off), -26, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), -26, num_off), -26, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=-26 num_on：12/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), -26, num_on), -26, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), -26, num_on), -26, num_on),
    cc3([91]),
  ) // 读数腿  不复原档 A ⇒ DIFF:[
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), -26, num_on), -26, num_on),
    cc3([123]),
  ) // 读数腿  不复原档 a ⇒ DIFF:{
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), -26, num_on), -26, num_on),
    cc3([64]),
  ) // 读数腿  不复原档 Z ⇒ DIFF:@
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), -26, num_on), -26, num_on),
    cc3([96]),
  ) // 读数腿  不复原档 z ⇒ DIFF:`
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), -26, num_on), -26, num_on),
    cc3([42]),
  ) // 读数腿  不复原档 0 ⇒ DIFF:*
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), -26, num_on), -26, num_on),
    cc3([41]),
  ) // 读数腿  不复原档 9 ⇒ DIFF:)
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), -26, num_on), -26, num_on),
    cc3([47]),
  ) // 读数腿  不复原档 5 ⇒ DIFF:/
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -26, num_on),
      -26,
      num_on,
    ),
    cc3([123, 98, 99, 62, 63, 64]),
  ) // 读数腿  不复原档 abcXYZ ⇒ DIFF:{bc>?@
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -26, num_on),
      -26,
      num_on,
    ),
    cc3([91, 40, 41, 94, 95, 96]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:[()^_`
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), -26, num_on),
      -26,
      num_on,
    ),
    cc3([42, 43, 40, 41]),
  ) // 读数腿  不复原档 0189 ⇒ DIFF:*+()
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), -26, num_on),
      -26,
      num_on,
    ),
    cc3([123, 42, 96, 41]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:{*`)
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -26, num_on),
      -26,
      num_on,
    ),
    cc3([32, 43, 33, 96, 64]),
  ) // 读数腿  不复原档  1!zZ ⇒ DIFF: +!`@
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        -26,
        num_on,
      ),
      -26,
      num_on,
    ),
    cc3([46, 101, 108, 108, 111, 44, 32, 61, 111, 114, 108, 100, 33]),
  ) // 读数腿  不复原档 Hello, World! ⇒ DIFF:.ello, =orld!
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), -26, num_on), -26, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), -26, num_on), -26, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), -26, num_on), -26, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), -26, num_on), -26, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), -26, num_on), -26, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), -26, num_on), -26, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), -26, num_on), -26, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), -26, num_on), -26, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), -26, num_on), -26, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), -26, num_on), -26, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), -26, num_on), -26, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=-13 num_off：22/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), -13, num_off), -13, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), -13, num_off), -13, num_off),
    cc3([52]),
  ) // 读数腿  不复原档 A ⇒ DIFF:4
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), -13, num_off), -13, num_off),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), -13, num_off), -13, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), -13, num_off), -13, num_off),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), -13, num_off), -13, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), -13, num_off), -13, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), -13, num_off), -13, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -13, num_off),
      -13,
      num_off,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -13, num_off),
      -13,
      num_off,
    ),
    cc3([52, 53, 54, 120, 121, 122]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:456xyz
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), -13, num_off),
      -13,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), -13, num_off),
      -13,
      num_off,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -13, num_off),
      -13,
      num_off,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        -13,
        num_off,
      ),
      -13,
      num_off,
    ),
    cc3([59, 101, 95, 95, 111, 44, 32, 87, 111, 114, 95, 100, 33]),
  ) // 读数腿  不复原档 Hello, World! ⇒ DIFF:;e__o, Wor_d!
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([20013]), -13, num_off),
      -13,
      num_off,
    ),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), -13, num_off), -13, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), -13, num_off), -13, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), -13, num_off), -13, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([1635]), -13, num_off),
      -13,
      num_off,
    ),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), -13, num_off), -13, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), -13, num_off), -13, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), -13, num_off), -13, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), -13, num_off), -13, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), -13, num_off), -13, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), -13, num_off), -13, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=-13 num_on：16/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), -13, num_on), -13, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), -13, num_on), -13, num_on),
    cc3([78]),
  ) // 读数腿  不复原档 A ⇒ DIFF:N
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), -13, num_on), -13, num_on),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), -13, num_on), -13, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), -13, num_on), -13, num_on),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), -13, num_on), -13, num_on),
    cc3([45]),
  ) // 读数腿  不复原档 0 ⇒ DIFF:-
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), -13, num_on), -13, num_on),
    cc3([44]),
  ) // 读数腿  不复原档 9 ⇒ DIFF:,
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), -13, num_on), -13, num_on),
    cc3([40]),
  ) // 读数腿  不复原档 5 ⇒ DIFF:(
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -13, num_on),
      -13,
      num_on,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -13, num_on),
      -13,
      num_on,
    ),
    cc3([78, 79, 80, 120, 121, 122]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:NOPxyz
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), -13, num_on),
      -13,
      num_on,
    ),
    cc3([45, 46, 43, 44]),
  ) // 读数腿  不复原档 0189 ⇒ DIFF:-.+,
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), -13, num_on),
      -13,
      num_on,
    ),
    cc3([97, 45, 122, 44]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:a-z,
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -13, num_on),
      -13,
      num_on,
    ),
    cc3([32, 46, 33, 122, 90]),
  ) // 读数腿  不复原档  1!zZ ⇒ DIFF: .!zZ
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        -13,
        num_on,
      ),
      -13,
      num_on,
    ),
    cc3([59, 101, 95, 95, 111, 44, 32, 87, 111, 114, 95, 100, 33]),
  ) // 读数腿  不复原档 Hello, World! ⇒ DIFF:;e__o, Wor_d!
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), -13, num_on), -13, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), -13, num_on), -13, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), -13, num_on), -13, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), -13, num_on), -13, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), -13, num_on), -13, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), -13, num_on), -13, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), -13, num_on), -13, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), -13, num_on), -13, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), -13, num_on), -13, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), -13, num_on), -13, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), -13, num_on), -13, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=-10 num_off：22/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), -10, num_off), -10, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), -10, num_off), -10, num_off),
    cc3([55]),
  ) // 读数腿  不复原档 A ⇒ DIFF:7
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), -10, num_off), -10, num_off),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), -10, num_off), -10, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), -10, num_off), -10, num_off),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), -10, num_off), -10, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), -10, num_off), -10, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), -10, num_off), -10, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -10, num_off),
      -10,
      num_off,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -10, num_off),
      -10,
      num_off,
    ),
    cc3([55, 56, 57, 120, 121, 122]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:789xyz
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), -10, num_off),
      -10,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), -10, num_off),
      -10,
      num_off,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -10, num_off),
      -10,
      num_off,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        -10,
        num_off,
      ),
      -10,
      num_off,
    ),
    cc3([62, 91, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  不复原档 Hello, World! ⇒ DIFF:>[llo, World!
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([20013]), -10, num_off),
      -10,
      num_off,
    ),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), -10, num_off), -10, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), -10, num_off), -10, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), -10, num_off), -10, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([1635]), -10, num_off),
      -10,
      num_off,
    ),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), -10, num_off), -10, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), -10, num_off), -10, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), -10, num_off), -10, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), -10, num_off), -10, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), -10, num_off), -10, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), -10, num_off), -10, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=-10 num_on：16/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), -10, num_on), -10, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), -10, num_on), -10, num_on),
    cc3([75]),
  ) // 读数腿  不复原档 A ⇒ DIFF:K
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), -10, num_on), -10, num_on),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), -10, num_on), -10, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), -10, num_on), -10, num_on),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), -10, num_on), -10, num_on),
    cc3([58]),
  ) // 读数腿  不复原档 0 ⇒ DIFF::
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), -10, num_on), -10, num_on),
    cc3([47]),
  ) // 读数腿  不复原档 9 ⇒ DIFF:/
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), -10, num_on), -10, num_on),
    cc3([43]),
  ) // 读数腿  不复原档 5 ⇒ DIFF:+
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -10, num_on),
      -10,
      num_on,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -10, num_on),
      -10,
      num_on,
    ),
    cc3([75, 76, 77, 120, 121, 122]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:KLMxyz
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), -10, num_on),
      -10,
      num_on,
    ),
    cc3([58, 39, 46, 47]),
  ) // 读数腿  不复原档 0189 ⇒ DIFF::'./
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), -10, num_on),
      -10,
      num_on,
    ),
    cc3([97, 58, 122, 47]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:a:z/
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -10, num_on),
      -10,
      num_on,
    ),
    cc3([32, 39, 33, 122, 90]),
  ) // 读数腿  不复原档  1!zZ ⇒ DIFF: '!zZ
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        -10,
        num_on,
      ),
      -10,
      num_on,
    ),
    cc3([62, 91, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 读数腿  不复原档 Hello, World! ⇒ DIFF:>[llo, World!
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), -10, num_on), -10, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), -10, num_on), -10, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), -10, num_on), -10, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), -10, num_on), -10, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), -10, num_on), -10, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), -10, num_on), -10, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), -10, num_on), -10, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), -10, num_on), -10, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), -10, num_on), -10, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), -10, num_on), -10, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), -10, num_on), -10, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=-1 num_off：20/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), -1, num_off), -1, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), -1, num_off), -1, num_off),
    cc3([64]),
  ) // 读数腿  不复原档 A ⇒ DIFF:@
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), -1, num_off), -1, num_off),
    cc3([96]),
  ) // 读数腿  不复原档 a ⇒ DIFF:`
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), -1, num_off), -1, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), -1, num_off), -1, num_off),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), -1, num_off), -1, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), -1, num_off), -1, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), -1, num_off), -1, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -1, num_off),
      -1,
      num_off,
    ),
    cc3([96, 98, 99, 88, 89, 90]),
  ) // 读数腿  不复原档 abcXYZ ⇒ DIFF:`bcXYZ
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -1, num_off),
      -1,
      num_off,
    ),
    cc3([64, 66, 67, 120, 121, 122]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:@BCxyz
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), -1, num_off),
      -1,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), -1, num_off),
      -1,
      num_off,
    ),
    cc3([96, 48, 122, 57]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:`0z9
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -1, num_off),
      -1,
      num_off,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        -1,
        num_off,
      ),
      -1,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), -1, num_off), -1, num_off),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), -1, num_off), -1, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), -1, num_off), -1, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), -1, num_off), -1, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), -1, num_off), -1, num_off),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), -1, num_off), -1, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), -1, num_off), -1, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), -1, num_off), -1, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), -1, num_off), -1, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), -1, num_off), -1, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), -1, num_off), -1, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=-1 num_on：18/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), -1, num_on), -1, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), -1, num_on), -1, num_on),
    cc3([64]),
  ) // 读数腿  不复原档 A ⇒ DIFF:@
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), -1, num_on), -1, num_on),
    cc3([96]),
  ) // 读数腿  不复原档 a ⇒ DIFF:`
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), -1, num_on), -1, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), -1, num_on), -1, num_on),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), -1, num_on), -1, num_on),
    cc3([47]),
  ) // 读数腿  不复原档 0 ⇒ DIFF:/
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), -1, num_on), -1, num_on),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), -1, num_on), -1, num_on),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), -1, num_on),
      -1,
      num_on,
    ),
    cc3([96, 98, 99, 88, 89, 90]),
  ) // 读数腿  不复原档 abcXYZ ⇒ DIFF:`bcXYZ
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), -1, num_on),
      -1,
      num_on,
    ),
    cc3([64, 66, 67, 120, 121, 122]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:@BCxyz
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), -1, num_on),
      -1,
      num_on,
    ),
    cc3([47, 49, 56, 57]),
  ) // 读数腿  不复原档 0189 ⇒ DIFF:/189
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), -1, num_on),
      -1,
      num_on,
    ),
    cc3([96, 47, 122, 57]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:`/z9
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), -1, num_on),
      -1,
      num_on,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        -1,
        num_on,
      ),
      -1,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), -1, num_on), -1, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), -1, num_on), -1, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), -1, num_on), -1, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), -1, num_on), -1, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), -1, num_on), -1, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), -1, num_on), -1, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), -1, num_on), -1, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), -1, num_on), -1, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), -1, num_on), -1, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), -1, num_on), -1, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), -1, num_on), -1, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=0 num_off：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 0, num_off), 0, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 0, num_off), 0, num_off),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 0, num_off), 0, num_off),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 0, num_off), 0, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 0, num_off), 0, num_off),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 0, num_off), 0, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 0, num_off), 0, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 0, num_off), 0, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 0, num_off),
      0,
      num_off,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 0, num_off),
      0,
      num_off,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 0, num_off),
      0,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 0, num_off),
      0,
      num_off,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 0, num_off),
      0,
      num_off,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        0,
        num_off,
      ),
      0,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 0, num_off), 0, num_off),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 0, num_off), 0, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 0, num_off), 0, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 0, num_off), 0, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 0, num_off), 0, num_off),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 0, num_off), 0, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 0, num_off), 0, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 0, num_off), 0, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 0, num_off), 0, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 0, num_off), 0, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 0, num_off), 0, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=0 num_on：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 0, num_on), 0, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 0, num_on), 0, num_on),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 0, num_on), 0, num_on),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 0, num_on), 0, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 0, num_on), 0, num_on),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 0, num_on), 0, num_on),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 0, num_on), 0, num_on),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 0, num_on), 0, num_on),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 0, num_on),
      0,
      num_on,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 0, num_on),
      0,
      num_on,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 0, num_on),
      0,
      num_on,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 0, num_on),
      0,
      num_on,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 0, num_on),
      0,
      num_on,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        0,
        num_on,
      ),
      0,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 0, num_on), 0, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 0, num_on), 0, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 0, num_on), 0, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 0, num_on), 0, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 0, num_on), 0, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 0, num_on), 0, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 0, num_on), 0, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 0, num_on), 0, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 0, num_on), 0, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 0, num_on), 0, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 0, num_on), 0, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=1 num_off：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 1, num_off), 1, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 1, num_off), 1, num_off),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 1, num_off), 1, num_off),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 1, num_off), 1, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 1, num_off), 1, num_off),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 1, num_off), 1, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 1, num_off), 1, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 1, num_off), 1, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 1, num_off),
      1,
      num_off,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 1, num_off),
      1,
      num_off,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 1, num_off),
      1,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 1, num_off),
      1,
      num_off,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 1, num_off),
      1,
      num_off,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        1,
        num_off,
      ),
      1,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 1, num_off), 1, num_off),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 1, num_off), 1, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 1, num_off), 1, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 1, num_off), 1, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 1, num_off), 1, num_off),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 1, num_off), 1, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 1, num_off), 1, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 1, num_off), 1, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 1, num_off), 1, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 1, num_off), 1, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 1, num_off), 1, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=1 num_on：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 1, num_on), 1, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 1, num_on), 1, num_on),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 1, num_on), 1, num_on),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 1, num_on), 1, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 1, num_on), 1, num_on),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 1, num_on), 1, num_on),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 1, num_on), 1, num_on),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 1, num_on), 1, num_on),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 1, num_on),
      1,
      num_on,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 1, num_on),
      1,
      num_on,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 1, num_on),
      1,
      num_on,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 1, num_on),
      1,
      num_on,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 1, num_on),
      1,
      num_on,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        1,
        num_on,
      ),
      1,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 1, num_on), 1, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 1, num_on), 1, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 1, num_on), 1, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 1, num_on), 1, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 1, num_on), 1, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 1, num_on), 1, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 1, num_on), 1, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 1, num_on), 1, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 1, num_on), 1, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 1, num_on), 1, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 1, num_on), 1, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=5 num_off：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 5, num_off), 5, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 5, num_off), 5, num_off),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 5, num_off), 5, num_off),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 5, num_off), 5, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 5, num_off), 5, num_off),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 5, num_off), 5, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 5, num_off), 5, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 5, num_off), 5, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 5, num_off),
      5,
      num_off,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 5, num_off),
      5,
      num_off,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 5, num_off),
      5,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 5, num_off),
      5,
      num_off,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 5, num_off),
      5,
      num_off,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        5,
        num_off,
      ),
      5,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 5, num_off), 5, num_off),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 5, num_off), 5, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 5, num_off), 5, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 5, num_off), 5, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 5, num_off), 5, num_off),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 5, num_off), 5, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 5, num_off), 5, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 5, num_off), 5, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 5, num_off), 5, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 5, num_off), 5, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 5, num_off), 5, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=5 num_on：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 5, num_on), 5, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 5, num_on), 5, num_on),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 5, num_on), 5, num_on),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 5, num_on), 5, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 5, num_on), 5, num_on),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 5, num_on), 5, num_on),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 5, num_on), 5, num_on),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 5, num_on), 5, num_on),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 5, num_on),
      5,
      num_on,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 5, num_on),
      5,
      num_on,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 5, num_on),
      5,
      num_on,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 5, num_on),
      5,
      num_on,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 5, num_on),
      5,
      num_on,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        5,
        num_on,
      ),
      5,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 5, num_on), 5, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 5, num_on), 5, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 5, num_on), 5, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 5, num_on), 5, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 5, num_on), 5, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 5, num_on), 5, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 5, num_on), 5, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 5, num_on), 5, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 5, num_on), 5, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 5, num_on), 5, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 5, num_on), 5, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=10 num_off：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 10, num_off), 10, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 10, num_off), 10, num_off),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 10, num_off), 10, num_off),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 10, num_off), 10, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 10, num_off), 10, num_off),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 10, num_off), 10, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 10, num_off), 10, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 10, num_off), 10, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 10, num_off),
      10,
      num_off,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 10, num_off),
      10,
      num_off,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 10, num_off),
      10,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 10, num_off),
      10,
      num_off,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 10, num_off),
      10,
      num_off,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        10,
        num_off,
      ),
      10,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 10, num_off), 10, num_off),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 10, num_off), 10, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 10, num_off), 10, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 10, num_off), 10, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 10, num_off), 10, num_off),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 10, num_off), 10, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 10, num_off), 10, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 10, num_off), 10, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 10, num_off), 10, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 10, num_off), 10, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 10, num_off), 10, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=10 num_on：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 10, num_on), 10, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 10, num_on), 10, num_on),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 10, num_on), 10, num_on),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 10, num_on), 10, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 10, num_on), 10, num_on),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 10, num_on), 10, num_on),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 10, num_on), 10, num_on),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 10, num_on), 10, num_on),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 10, num_on),
      10,
      num_on,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 10, num_on),
      10,
      num_on,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 10, num_on),
      10,
      num_on,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 10, num_on),
      10,
      num_on,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 10, num_on),
      10,
      num_on,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        10,
        num_on,
      ),
      10,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 10, num_on), 10, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 10, num_on), 10, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 10, num_on), 10, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 10, num_on), 10, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 10, num_on), 10, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 10, num_on), 10, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 10, num_on), 10, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 10, num_on), 10, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 10, num_on), 10, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 10, num_on), 10, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 10, num_on), 10, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=13 num_off：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 13, num_off), 13, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 13, num_off), 13, num_off),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 13, num_off), 13, num_off),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 13, num_off), 13, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 13, num_off), 13, num_off),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 13, num_off), 13, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 13, num_off), 13, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 13, num_off), 13, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 13, num_off),
      13,
      num_off,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 13, num_off),
      13,
      num_off,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 13, num_off),
      13,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 13, num_off),
      13,
      num_off,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 13, num_off),
      13,
      num_off,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        13,
        num_off,
      ),
      13,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 13, num_off), 13, num_off),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 13, num_off), 13, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 13, num_off), 13, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 13, num_off), 13, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 13, num_off), 13, num_off),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 13, num_off), 13, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 13, num_off), 13, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 13, num_off), 13, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 13, num_off), 13, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 13, num_off), 13, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 13, num_off), 13, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=13 num_on：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 13, num_on), 13, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 13, num_on), 13, num_on),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 13, num_on), 13, num_on),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 13, num_on), 13, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 13, num_on), 13, num_on),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 13, num_on), 13, num_on),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 13, num_on), 13, num_on),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 13, num_on), 13, num_on),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 13, num_on),
      13,
      num_on,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 13, num_on),
      13,
      num_on,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 13, num_on),
      13,
      num_on,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 13, num_on),
      13,
      num_on,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 13, num_on),
      13,
      num_on,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        13,
        num_on,
      ),
      13,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 13, num_on), 13, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 13, num_on), 13, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 13, num_on), 13, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 13, num_on), 13, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 13, num_on), 13, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 13, num_on), 13, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 13, num_on), 13, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 13, num_on), 13, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 13, num_on), 13, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 13, num_on), 13, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 13, num_on), 13, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=25 num_off：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 25, num_off), 25, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 25, num_off), 25, num_off),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 25, num_off), 25, num_off),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 25, num_off), 25, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 25, num_off), 25, num_off),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 25, num_off), 25, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 25, num_off), 25, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 25, num_off), 25, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 25, num_off),
      25,
      num_off,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 25, num_off),
      25,
      num_off,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 25, num_off),
      25,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 25, num_off),
      25,
      num_off,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 25, num_off),
      25,
      num_off,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        25,
        num_off,
      ),
      25,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 25, num_off), 25, num_off),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 25, num_off), 25, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 25, num_off), 25, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 25, num_off), 25, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 25, num_off), 25, num_off),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 25, num_off), 25, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 25, num_off), 25, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 25, num_off), 25, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 25, num_off), 25, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 25, num_off), 25, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 25, num_off), 25, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=25 num_on：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 25, num_on), 25, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 25, num_on), 25, num_on),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 25, num_on), 25, num_on),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 25, num_on), 25, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 25, num_on), 25, num_on),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 25, num_on), 25, num_on),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 25, num_on), 25, num_on),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 25, num_on), 25, num_on),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 25, num_on),
      25,
      num_on,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 25, num_on),
      25,
      num_on,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 25, num_on),
      25,
      num_on,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 25, num_on),
      25,
      num_on,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 25, num_on),
      25,
      num_on,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        25,
        num_on,
      ),
      25,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 25, num_on), 25, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 25, num_on), 25, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 25, num_on), 25, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 25, num_on), 25, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 25, num_on), 25, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 25, num_on), 25, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 25, num_on), 25, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 25, num_on), 25, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 25, num_on), 25, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 25, num_on), 25, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 25, num_on), 25, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=26 num_off：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 26, num_off), 26, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 26, num_off), 26, num_off),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 26, num_off), 26, num_off),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 26, num_off), 26, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 26, num_off), 26, num_off),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 26, num_off), 26, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 26, num_off), 26, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 26, num_off), 26, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 26, num_off),
      26,
      num_off,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 26, num_off),
      26,
      num_off,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 26, num_off),
      26,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 26, num_off),
      26,
      num_off,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 26, num_off),
      26,
      num_off,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        26,
        num_off,
      ),
      26,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 26, num_off), 26, num_off),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 26, num_off), 26, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 26, num_off), 26, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 26, num_off), 26, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 26, num_off), 26, num_off),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 26, num_off), 26, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 26, num_off), 26, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 26, num_off), 26, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 26, num_off), 26, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 26, num_off), 26, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 26, num_off), 26, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=26 num_on：25/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 26, num_on), 26, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 26, num_on), 26, num_on),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 26, num_on), 26, num_on),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 26, num_on), 26, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 26, num_on), 26, num_on),
    cc3([122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 26, num_on), 26, num_on),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 26, num_on), 26, num_on),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 26, num_on), 26, num_on),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 26, num_on),
      26,
      num_on,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 26, num_on),
      26,
      num_on,
    ),
    cc3([65, 66, 67, 120, 121, 122]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 26, num_on),
      26,
      num_on,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 26, num_on),
      26,
      num_on,
    ),
    cc3([97, 48, 122, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 26, num_on),
      26,
      num_on,
    ),
    cc3([32, 49, 33, 122, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        26,
        num_on,
      ),
      26,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 26, num_on), 26, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 26, num_on), 26, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 26, num_on), 26, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 26, num_on), 26, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 26, num_on), 26, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 26, num_on), 26, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 26, num_on), 26, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 26, num_on), 26, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 26, num_on), 26, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 26, num_on), 26, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 26, num_on), 26, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=27 num_off：21/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 27, num_off), 27, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 27, num_off), 27, num_off),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 27, num_off), 27, num_off),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 27, num_off), 27, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 27, num_off), 27, num_off),
    cc3([96]),
  ) // 读数腿  不复原档 z ⇒ DIFF:`
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 27, num_off), 27, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 27, num_off), 27, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 27, num_off), 27, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 27, num_off),
      27,
      num_off,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 27, num_off),
      27,
      num_off,
    ),
    cc3([65, 66, 67, 120, 121, 96]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:ABCxy`
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 27, num_off),
      27,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 27, num_off),
      27,
      num_off,
    ),
    cc3([97, 48, 96, 57]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:a0`9
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 27, num_off),
      27,
      num_off,
    ),
    cc3([32, 49, 33, 96, 90]),
  ) // 读数腿  不复原档  1!zZ ⇒ DIFF: 1!`Z
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        27,
        num_off,
      ),
      27,
      num_off,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 27, num_off), 27, num_off),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 27, num_off), 27, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 27, num_off), 27, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 27, num_off), 27, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 27, num_off), 27, num_off),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 27, num_off), 27, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 27, num_off), 27, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 27, num_off), 27, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 27, num_off), 27, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 27, num_off), 27, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 27, num_off), 27, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=27 num_on：21/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 27, num_on), 27, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 27, num_on), 27, num_on),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 27, num_on), 27, num_on),
    cc3([97]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 27, num_on), 27, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 27, num_on), 27, num_on),
    cc3([96]),
  ) // 读数腿  不复原档 z ⇒ DIFF:`
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 27, num_on), 27, num_on),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 27, num_on), 27, num_on),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 27, num_on), 27, num_on),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 27, num_on),
      27,
      num_on,
    ),
    cc3([97, 98, 99, 88, 89, 90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 27, num_on),
      27,
      num_on,
    ),
    cc3([65, 66, 67, 120, 121, 96]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:ABCxy`
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 27, num_on),
      27,
      num_on,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 27, num_on),
      27,
      num_on,
    ),
    cc3([97, 48, 96, 57]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:a0`9
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 27, num_on),
      27,
      num_on,
    ),
    cc3([32, 49, 33, 96, 90]),
  ) // 读数腿  不复原档  1!zZ ⇒ DIFF: 1!`Z
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        27,
        num_on,
      ),
      27,
      num_on,
    ),
    cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 27, num_on), 27, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 27, num_on), 27, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 27, num_on), 27, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 27, num_on), 27, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 27, num_on), 27, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 27, num_on), 27, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 27, num_on), 27, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 27, num_on), 27, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 27, num_on), 27, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 27, num_on), 27, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 27, num_on), 27, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=52 num_off：18/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 52, num_off), 52, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 52, num_off), 52, num_off),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 52, num_off), 52, num_off),
    cc3([71]),
  ) // 读数腿  不复原档 a ⇒ DIFF:G
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 52, num_off), 52, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 52, num_off), 52, num_off),
    cc3([96]),
  ) // 读数腿  不复原档 z ⇒ DIFF:`
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 52, num_off), 52, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 52, num_off), 52, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 52, num_off), 52, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 52, num_off),
      52,
      num_off,
    ),
    cc3([71, 72, 73, 88, 89, 90]),
  ) // 读数腿  不复原档 abcXYZ ⇒ DIFF:GHIXYZ
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 52, num_off),
      52,
      num_off,
    ),
    cc3([65, 66, 67, 94, 95, 96]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:ABC^_`
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 52, num_off),
      52,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 52, num_off),
      52,
      num_off,
    ),
    cc3([71, 48, 96, 57]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:G0`9
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 52, num_off),
      52,
      num_off,
    ),
    cc3([32, 49, 33, 96, 90]),
  ) // 读数腿  不复原档  1!zZ ⇒ DIFF: 1!`Z
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        52,
        num_off,
      ),
      52,
      num_off,
    ),
    cc3([72, 75, 82, 82, 85, 44, 32, 87, 85, 88, 82, 74, 33]),
  ) // 读数腿  不复原档 Hello, World! ⇒ DIFF:HKRRU, WUXRJ!
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 52, num_off), 52, num_off),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 52, num_off), 52, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 52, num_off), 52, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 52, num_off), 52, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 52, num_off), 52, num_off),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 52, num_off), 52, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 52, num_off), 52, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 52, num_off), 52, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 52, num_off), 52, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 52, num_off), 52, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 52, num_off), 52, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=52 num_on：18/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 52, num_on), 52, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 52, num_on), 52, num_on),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 52, num_on), 52, num_on),
    cc3([71]),
  ) // 读数腿  不复原档 a ⇒ DIFF:G
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 52, num_on), 52, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 52, num_on), 52, num_on),
    cc3([96]),
  ) // 读数腿  不复原档 z ⇒ DIFF:`
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 52, num_on), 52, num_on),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 52, num_on), 52, num_on),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 52, num_on), 52, num_on),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 52, num_on),
      52,
      num_on,
    ),
    cc3([71, 72, 73, 88, 89, 90]),
  ) // 读数腿  不复原档 abcXYZ ⇒ DIFF:GHIXYZ
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 52, num_on),
      52,
      num_on,
    ),
    cc3([65, 66, 67, 94, 95, 96]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:ABC^_`
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 52, num_on),
      52,
      num_on,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 52, num_on),
      52,
      num_on,
    ),
    cc3([71, 48, 96, 57]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:G0`9
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 52, num_on),
      52,
      num_on,
    ),
    cc3([32, 49, 33, 96, 90]),
  ) // 读数腿  不复原档  1!zZ ⇒ DIFF: 1!`Z
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        52,
        num_on,
      ),
      52,
      num_on,
    ),
    cc3([72, 75, 82, 82, 85, 44, 32, 87, 85, 88, 82, 74, 33]),
  ) // 读数腿  不复原档 Hello, World! ⇒ DIFF:HKRRU, WUXRJ!
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 52, num_on), 52, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 52, num_on), 52, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 52, num_on), 52, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 52, num_on), 52, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 52, num_on), 52, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 52, num_on), 52, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 52, num_on), 52, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 52, num_on), 52, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 52, num_on), 52, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 52, num_on), 52, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 52, num_on), 52, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=104 num_off：18/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 104, num_off), 104, num_off),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 104, num_off), 104, num_off),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 104, num_off), 104, num_off),
    cc3([19]),
  ) // 读数腿  不复原档 a ⇒ DIFF:\u0013
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 104, num_off), 104, num_off),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 104, num_off), 104, num_off),
    cc3([44]),
  ) // 读数腿  不复原档 z ⇒ DIFF:,
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 104, num_off), 104, num_off),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 104, num_off), 104, num_off),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 104, num_off), 104, num_off),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 104, num_off),
      104,
      num_off,
    ),
    cc3([19, 20, 21, 88, 89, 90]),
  ) // 读数腿  不复原档 abcXYZ ⇒ DIFF:\u0013\u0014\u0015XYZ
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 104, num_off),
      104,
      num_off,
    ),
    cc3([65, 66, 67, 42, 43, 44]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:ABC*+,
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 104, num_off),
      104,
      num_off,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 104, num_off),
      104,
      num_off,
    ),
    cc3([19, 48, 44, 57]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:\u00130,9
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 104, num_off),
      104,
      num_off,
    ),
    cc3([32, 49, 33, 44, 90]),
  ) // 读数腿  不复原档  1!zZ ⇒ DIFF: 1!,Z
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        104,
        num_off,
      ),
      104,
      num_off,
    ),
    cc3([72, 23, 30, 30, 33, 44, 32, 87, 33, 36, 30, 22, 33]),
  ) // 读数腿  不复原档 Hello, World! ⇒ DIFF:H\u0017\u001e\u001e!, W!$\u001e\u0016!
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([20013]), 104, num_off),
      104,
      num_off,
    ),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 104, num_off), 104, num_off),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 104, num_off), 104, num_off),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 104, num_off), 104, num_off),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([1635]), 104, num_off),
      104,
      num_off,
    ),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 104, num_off), 104, num_off),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 104, num_off), 104, num_off),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 104, num_off), 104, num_off),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 104, num_off), 104, num_off),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 104, num_off), 104, num_off),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 104, num_off), 104, num_off),
    cc3([64]),
  ) // 规则腿  SAME 档
}

///|
test "codec #13.3 往返 shift=104 num_on：18/25 档复原" {
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([]), 104, num_on), 104, num_on),
    cc3([]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([65]), 104, num_on), 104, num_on),
    cc3([65]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([97]), 104, num_on), 104, num_on),
    cc3([19]),
  ) // 读数腿  不复原档 a ⇒ DIFF:\u0013
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([90]), 104, num_on), 104, num_on),
    cc3([90]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([122]), 104, num_on), 104, num_on),
    cc3([44]),
  ) // 读数腿  不复原档 z ⇒ DIFF:,
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([48]), 104, num_on), 104, num_on),
    cc3([48]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([57]), 104, num_on), 104, num_on),
    cc3([57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([53]), 104, num_on), 104, num_on),
    cc3([53]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 98, 99, 88, 89, 90]), 104, num_on),
      104,
      num_on,
    ),
    cc3([19, 20, 21, 88, 89, 90]),
  ) // 读数腿  不复原档 abcXYZ ⇒ DIFF:\u0013\u0014\u0015XYZ
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([65, 66, 67, 120, 121, 122]), 104, num_on),
      104,
      num_on,
    ),
    cc3([65, 66, 67, 42, 43, 44]),
  ) // 读数腿  不复原档 ABCxyz ⇒ DIFF:ABC*+,
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([48, 49, 56, 57]), 104, num_on),
      104,
      num_on,
    ),
    cc3([48, 49, 56, 57]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([97, 48, 122, 57]), 104, num_on),
      104,
      num_on,
    ),
    cc3([19, 48, 44, 57]),
  ) // 读数腿  不复原档 a0z9 ⇒ DIFF:\u00130,9
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(cc3([32, 49, 33, 122, 90]), 104, num_on),
      104,
      num_on,
    ),
    cc3([32, 49, 33, 44, 90]),
  ) // 读数腿  不复原档  1!zZ ⇒ DIFF: 1!,Z
  assert_eq(
    @codec.rot_decode(
      @codec.rot_encode(
        cc3([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]),
        104,
        num_on,
      ),
      104,
      num_on,
    ),
    cc3([72, 23, 30, 30, 33, 44, 32, 87, 33, 36, 30, 22, 33]),
  ) // 读数腿  不复原档 Hello, World! ⇒ DIFF:H\u0017\u001e\u001e!, W!$\u001e\u0016!
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([20013]), 104, num_on), 104, num_on),
    cc3([20013]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([233]), 104, num_on), 104, num_on),
    cc3([233]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([937]), 104, num_on), 104, num_on),
    cc3([937]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([223]), 104, num_on), 104, num_on),
    cc3([223]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([1635]), 104, num_on), 104, num_on),
    cc3([1635]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([0]), 104, num_on), 104, num_on),
    cc3([0]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([9]), 104, num_on), 104, num_on),
    cc3([9]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([91]), 104, num_on), 104, num_on),
    cc3([91]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([96]), 104, num_on), 104, num_on),
    cc3([96]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([58]), 104, num_on), 104, num_on),
    cc3([58]),
  ) // 规则腿  SAME 档
  assert_eq(
    @codec.rot_decode(@codec.rot_encode(cc3([64]), 104, num_on), 104, num_on),
    cc3([64]),
  ) // 规则腿  SAME 档
}
