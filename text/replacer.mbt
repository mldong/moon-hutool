///|
// 替换引擎（hutool `text.replacer` 三件：`StrReplacer` / `LookupReplacer` / `ReplacerChain`）。
//
// 为什么这一批要连着实体族一起做：`XmlEscape`/`Html4Escape`/`XmlUnescape`/`Html4Unescape`
// **全都 extends `ReplacerChain`**（javap -p 现读），实体转义就是"查表替换 + 链"拼出来的。
// 择路规则一旦定错，实体表与数字实体的读数会整片跟着错。四条判据全部来自
// `scripts/ReplacerLeg.java`：
//   * 长键优先，**与表序无关**（同一条表把 `{ab→X, abc→Y}` 倒过来放，两侧读数一样）；
//   * 同键两条 ⇒ **后写的生效**（腿 set2 单字符档读数给 `2`）；
//   * 串尾不够长就不匹配（不回绕、不部分命中）；
//   * **一遍左到右扫，命中后从那一段之后继续**，产出不回头再扫（腿 C|overlap：`ab→1` 与 `1→X`
//     同链给 `1`；C|watch 那件的调用计数为 0，证第二件在同一位置根本没被调到）；
//   * 空键 ⇒ 参照在构造器里 `charAt(0)` 就抛（腿 L|ctor），本库收成 `raise(EmptyKey)`。
//
// **公开的只有整串面**（`replace(s)`），参照那个 `protected int replace(CharSequence,int,StrBuilder)`
// 不进公开面。原因是一条读数而不是洁癖：参照的驱动循环把"返回负数"当成消费负数 ⇒ 游标倒退、
// **永不收敛**（腿 B|solo|retNeg 两秒超时守护下跑出 16.5 亿次调用；0 才是"不匹配"）。
// 只要不开放逐步钩子，这一档就构造不出来；开放了就等于把"调用方可以写出不收敛"放进契约面。
//
// 形状：`kind` 0 = 查表（`LookupReplacer`）、1 = 链（`ReplacerChain`）；字段全 `priv`，
// 公开面只有两条构造路，手工拼一条规则等于自己决定"命中后游标前进几位"，那一档语义没冻
// （同 dfa 的 `WordTree` 口径）。

pub struct Replacer {
  priv kind : Int
  priv pairs : Array[(String, String)]
  priv chain : Array[Replacer]
}

///|
/// 内部构造件：跳过空键检查，供**表里根本不存在空键**的本包内部使用（实体表由反射读来，
/// 键最短就是 `&lt;` 那 4 个字符；单字符键也在 1 以上）。公开面走 `lookup_replacer`。
fn make_lookup(pairs : Array[(String, String)]) -> Replacer {
  Replacer::{ kind: 0, pairs, chain: [], }
}

///|
/// 查表替换器（`LookupReplacer(String[]...)`）。表里每条是 `(键, 值)`；
/// 空键在本库是 `raise(EmptyKey)`（参照是同位置直接 `StringIndexOutOfBoundsException`）。
pub fn lookup_replacer(
  pairs : Array[(String, String)],
) -> Replacer raise TextError {
  for (key, _) in pairs {
    if key.is_empty() {
      raise EmptyKey
    }
  }
  make_lookup(pairs)
}

///|
/// 链式替换器（`ReplacerChain(StrReplacer...)` + `addChain`）。
/// 语义是"每个位置按链序问第一个命中的"，**不是**"依次全文替换"（腿 C|overlap、B|chain_fs/sf）。
pub fn replacer_chain(rs : Array[Replacer]) -> Replacer {
  Replacer::{ kind: 1, pairs: [], chain: rs, }
}

///|
/// 从 `cs[at]` 起问一次：命中给 `(吃了几个码位, 要写出的串)`，否则 None。
/// 长键优先；等长时**后出现的生效**（腿 set2 读数如此，不是"先到先得"）。
fn step_at(r : Replacer, cs : Array[Char], at : Int) -> (Int, String)? {
  if r.kind == 0 {
    longest_of(r.pairs, cs, at)
  } else {
    let mut found : (Int, String)? = None
    for child in r.chain {
      if found is None {
        found = step_at(child, cs, at)
      }
    }
    found
  }
}

///|
fn longest_of(
  pairs : Array[(String, String)],
  cs : Array[Char],
  at : Int,
) -> (Int, String)? {
  let mut best_len = 0
  let mut best_val = ""
  for (key, value) in pairs {
    let kc = key.iter().collect()
    let m = kc.length()
    // `== best_len` 也要走过去 ⇒ 同长度时表里**后**那条生效（腿 set2 给 `2`）
    if m < best_len || at + m > cs.length() || m == 0 {
      continue
    }
    let mut hit = true
    let mut k = 0
    while k < m {
      if cs[at + k] != kc[k] {
        hit = false
      }
      k += 1
    }
    if hit {
      best_len = m
      best_val = value
    }
  }
  if best_len == 0 {
    None
  } else {
    Some((best_len, best_val))
  }
}

///|
/// 整串替换（`StrReplacer.replace(CharSequence)` 的公开面）。
/// 参照返回 `CharSequence`，实为 `StrBuilder`；本库直接给 `String`，那条返回类型没有额外承诺。
pub fn Replacer::replace(self : Replacer, s : String) -> String {
  let cs = s.iter().collect()
  let buf = StringBuilder()
  let mut i = 0
  while i < cs.length() {
    match step_at(self, cs, i) {
      Some((consumed, text)) => {
        buf.write_string(text)
        i += consumed
      }
      None => {
        buf.write_char(cs[i])
        i += 1
      }
    }
  }
  buf.to_string()
}
