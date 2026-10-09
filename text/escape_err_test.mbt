///|
/// 本文件**手工维护**（`gen_escape_family.py` 不碰它）：`escape_test.mbt` 全生成，
/// 两个 helper 嵌进生成器就等于把目标语言源码写进 python 字符串（typex 轮记下的那条规矩）。
/// 同包多个 `*_test.mbt` 共享顶层命名空间，所以生成件里直接调用这两个即可。

///|
/// 错误面折成字符串：变体名 + 携带值一起进断言（携带值也是契约的一部分，同 `re`/`num` 的写法）
fn show(e : @text.TextError) -> String {
  match e {
    @text.BadHex(s) => "BadHex \{s}"
    @text.ShortInput => "ShortInput"
    @text.LoneSurrogate(c) => "LoneSurrogate \{c}"
    @text.EmptyKey => "EmptyKey"
  }
}

///|
/// 跑一次预期会 raise 的调用；没 raise 就返回「未抛错」（同 `re/re_test.mbt` 的写法）
fn[A] cn_err(g : () -> A raise @text.TextError) -> String {
  try {
    let _ = g()
    "未抛错"
  } catch {
    e => show(e)
  }
}
