///|
// 替换引擎（hutool `text.replacer` 三件：`StrReplacer` / `LookupReplacer` / `ReplacerChain`）。
//
// 为什么这一批要连着实体族一起做：`XmlEscape`/`Html4Escape`/`XmlUnescape`/`Html4Unescape`
// **全都 extends `ReplacerChain`**（javap -p 现读），实体转义就是"查表替换 + 链"拼出来的。
// 择路规则一旦定错，实体表与数字实体的读数会整片跟着错。规则由 `scripts/ReplacerLeg.java` 逐档钉：
//   * 长键优先，**与表序无关**（同一条表把 `{ab→X, abc→Y}` 倒过来放，两侧读数一样）；
//   * 同键两条 ⇒ **后写的生效**（腿 set2 单字符档读数给 `2`）；
//   * 串不够长就不匹配（不回绕、不部分命中）；
//   * **一遍左到右扫，命中后从那一段之后继续**，产出不回头再扫（腿 C|overlap：`ab→1` 与 `1→X`
//     同链给 `1`；C|watch 那件的调用计数为 0，证第二件在同一位置根本没被调到）；
//   * 空键 ⇒ 参照在构造器里 `charAt(0)` 就抛（腿 L|ctor），本库收成 `raise(EmptyKey)`。
//
// **公开的只有整串面**（`replace(s)`），参照那个 `protected int replace(CharSequence,int,StrBuilder)`
// 不进公开面。原因是一条读数：参照的驱动循环把"返回负数"当成消费负数 ⇒ 游标倒退、
// **永不收敛**（腿 B|solo|retNeg 两秒超时守护下跑出 16.5 亿次调用；0 才是"不匹配"）。
// 只要不开放逐步钩子，这一档就构造不出来；开了就等于把"调用方可以写出不收敛"放进契约面。

///|
/// 一条替换规则。构造只有两条路：`lookup_replacer`（查表）与 `replacer_chain`（把若干条串起来），
/// 与参照的 `LookupReplacer`/`ReplacerChain` 一一对应；`StrReplacer` 本体是它们的抽象父类，
/// 在本库没有对位公开件（不开放逐步钩子，理由见本文件头注）。
pub struct Replacer {
  // 形状冻在这里、字段全 `priv`：公开面只有 `lookup_replacer`/`replacer_chain` 两条构造路，
  // 手工拼一条规则等于自己决定"命中后游标前进几位"，那一档语义没冻（同 dfa 的 WordTree 口径）。
  priv kind : Int // 0 = 查表（LookupReplacer），1 = 链（ReplacerChain）
  priv pairs : Array[(String, String)] // kind=0 的表，(键, 值)
  priv chain : Array[Replacer] // kind=1 的链，按链序问
}

///|
/// 查表替换器（`LookupReplacer(String[]...)`）。表里每条是 `(键, 值)`；
/// 空键在本库是 `raise(EmptyKey)`（参照是同位置直接 `StringIndexOutOfBoundsException`）。
pub fn lookup_replacer(
  pairs : Array[(String, String)],
) -> Replacer raise TextError {
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.20")
}

///|
/// 链式替换器（`ReplacerChain(StrReplacer...)` + `addChain`）。
/// 语义是"每个位置按链序问第一个命中的"，**不是**"依次全文替换"（腿 C|overlap、B|chain_fs/sf 三档实测）。
pub fn replacer_chain(rs : Array[Replacer]) -> Replacer {
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.20")
}

///|
/// 整串替换（`StrReplacer.replace(CharSequence)` 的公开面）。
/// 参照返回 `CharSequence`，本库返回 `String`——参照那条返回类型没有任何额外承诺
/// （它实际给的就是 `StrBuilder`，`toString` 即本库的返回值），构不成语义差。
pub fn Replacer::replace(self : Replacer, s : String) -> String {
  abort("PR-B：契约骨架，契约见 docs/spec/01-text.md #1.20")
}
