///|
/// moon-hutool/dfa —— 敏感词/关键词树（hutool `WordTree` + `StopChar` 的 MoonBit 对位·第一批）
///
/// 契约：`docs/spec/14-dfa.md`；进度：`docs/ROADMAP.md`。这一批**只有签名与冻结期望值，函数体是 `abort`**
/// （状态＝契约已冻结，用例预期红）；实现那一笔只许把红变绿（门禁 G5）。
///
/// 四条贯穿性规则（都来自参照腿源码与本机读数，不是设计偏好）：
/// 1. **不做全局单例**。参照实现另有一张 `SensitiveUtil` 静态表（`init(...)` 装全局、
///    `containsSensitive(Object)` 靠反射取字段）。本库一律"树是值、显式传进函数"，
///    与 `conv`/`re` 的"没有全局可变注册表"同一条立场；反射那一半结构上就做不到。
/// 2. **位置口径 = UTF-16 码元下标**，与参照腿（Java `char` 下标）同读，也与 `re` 包同一条
///    （`re` 的位置来自 core 的 `StringView`，本来就是码元）。一个库不许有两家 `start/end` 语义。
/// 3. **只有三档语义，不是四档**。`match_all_words(text, limit, density, greed)` 里
///    `greed` **只在 `density=true` 时起作用**——实测 `density=false, greed=true` 与
///    `density=false, greed=false` 逐条同读（参照实现的 `if (!isDensityMatch) { i = j; break }`
///    排在贪婪判定之前）。参照实现的 javadoc 把贪婪单列成"最长匹配"，那句在实测档不成立，
///    以实现为准并在用例里各钉一条。
/// 4. **无 null 出口**。参照实现的 `matchAllWords(null, ...)` 返回 Java `null`，
///    本库返回空数组——`Option` 只出现在"取第一个"那一族（`match`/`match_word`）。

///|
/// 一条命中：`word` 是词表里的词（停顿字符已剥掉），`found` 是文本里实际匹配到的串
/// （**词中间的停顿字符原样带着**），`start`/`end` 是 **闭区间**、UTF-16 码元下标。
///
/// - Note: 参照实现的 `toString()` 返回 `found` 而非 `word`，`match()` 因此给出的是文本里的
///   那一串；本库把两个字段都摆出来，`match` 仍跟随返回 `found`（spec §5 第 5 行）。
pub struct FoundWord {
  word : String
  found : String
  start : Int
  end : Int
}

///|
/// 关键词树（DFA 式逐字符转移）。构造只认词表，之后是只读的匹配器。
///
/// - Note: 树是值，建完只读。两个字段会进 `.mbti`（MoonBit 的 `pub struct` 默认把形状摊给接口文件，
///   本仓 `mapx` 的 `BiMap`/`Table` 同形），但**契约只承诺经 `new_word_tree` 构造的树**——
///   手工拼一棵树等于自己决定"结束标记放哪儿"，那一档语义没冻。
pub struct WordTree {
  // 节点表：`children[i][c] = j` 表示节点 i 吃字符 c 转到节点 j，`ends[j]` 表示"走到 j 就是完整词"。
  // 参照实现把结束标记挂在**父节点的字符集**上（`parent.setEnd(currentChar)`），这里等价地挂在目标节点上——
  // 只是形状不同；`红、领巾` 命中 `红领巾` 靠的是"停顿字符不进转移、但占住 found 区间"。
  children : Array[Map[Char, Int]]
  ends : Array[Bool]
}

///|
// 新节点：空转移表 + 非终止。返回新节点下标（根是 0，所以首个新节点恒为 1）。
fn new_node(children : Array[Map[Char, Int]], ends : Array[Bool]) -> Int {
  children.push(Map([]))
  ends.push(false)
  children.length() - 1
}

///|
// 把一个词并进树里：只有"参与匹配"的字符进转移（停顿字符直接跳过，参照实现同一条），
// 路径最后一个节点标终止。**一个字符都没进过树就不标终止**——这正是"空串/全停顿词永不命中"的来处。
fn add_word(
  children : Array[Map[Char, Int]],
  ends : Array[Bool],
  word : String,
) -> Unit {
  let mut cur = 0
  let mut last = -1
  for c in word.to_array() {
    if is_stop_char(c) {
      continue
    }
    if children[cur].contains(c) {
      cur = children[cur][c]
    } else {
      let idx = new_node(children, ends)
      children[cur][c] = idx
      cur = idx
    }
    last = cur
  }
  if last >= 0 {
    ends[last] = true
  }
}

///|
// 码点 → 该码点起点的 **UTF-16 码元**下标（承诺口径见契约 §0 规则 2：非 BMP 字符占两位）。
fn unit_offsets(cs : Array[Char]) -> Array[Int] {
  let out : Array[Int] = []
  let mut acc = 0
  for c in cs {
    out.push(acc)
    // 运算符只能落在行尾（core 语法），所以 if 先成一个绑定再加
    let w = if c.to_int() > 0xffff { 2 } else { 1 }
    acc = acc + w
  }
  out
}

///|
// 取码点闭区间 `lo..=hi` 的原文（`found` 用，停顿字符原样在内）。
fn span(cs : Array[Char], lo : Int, hi : Int) -> String {
  let buf = StringBuilder()
  let mut k = lo
  while k <= hi {
    buf.write_char(cs[k])
    k = k + 1
  }
  buf.to_string()
}

///|
// 走过路径上的字符（`word` 用，停顿字符已剥掉）。
fn key_text(ks : Array[Char]) -> String {
  let buf = StringBuilder()
  for c in ks {
    buf.write_char(c)
  }
  buf.to_string()
}

///|
/// 用一批词建树。重复词按首次出现去重（参照实现走 `HashSet`，本库保序去重——树形与插入序无关，
/// 两侧对同一批词建出的树匹配结果逐条同读，spec §4 第 3 条腿）。
///
/// - Parameters:
///   - words: 词表。空串、以及**整词都是停顿字符**的词（如 `"、。"`）不进树（参照实现的
///     `addWord` 里 `parent` 保持 null 就不打结束标记），实测都不产生命中。
/// - Returns: 一棵树；不返回 `raise`，建树没有可失败输入
/// - Raises: 无——纯构造
///
/// ```mbt nocheck
/// let t = @dfa.new_word_tree(["ab", "b"])
/// ```
pub fn new_word_tree(words : Array[String]) -> WordTree {
  let children : Array[Map[Char, Int]] = []
  let ends : Array[Bool] = []
  let _ = new_node(children, ends)
  for w in words {
    add_word(children, ends, w)
  }
  WordTree::{ children, ends, }
}

///|
/// 文本里是否出现任一词。等价于 `first_found(text) is Some(_)`。
///
/// - Raises: 无——纯查询
pub fn WordTree::is_match(self : WordTree, text : String) -> Bool {
  self.first_found(text) is Some(_)
}

///|
/// 第一个命中的**文本串**（含词中间的停顿字符），没有命中给 `None`。
/// 跟随参照实现的 `match()`：给的是 `found` 而不是词表里的 `word`。
///
/// - Raises: 无——纯查询
pub fn WordTree::first_match(self : WordTree, text : String) -> String? {
  match self.first_found(text) {
    Some(f) => Some(f.found)
    None => None
  }
}

///|
/// 第一个命中，带位置。"第一个"＝**最左起点里最短的那条**（`limit=1`、`density=false`、`greed=false`）。
///
/// - Raises: 无——纯查询
pub fn WordTree::first_found(self : WordTree, text : String) -> FoundWord? {
  let r = self.match_all_words_mode(text, 1, false, false)
  if r.length() > 0 {
    Some(r[0])
  } else {
    None
  }
}

///|
/// 全部命中，默认档：`limit=-1, density=false, greed=false`（最左一段命中即整段跳过，同起点取最短）。
///
/// - Raises: 无——纯查询
pub fn WordTree::match_all(self : WordTree, text : String) -> Array[String] {
  self.match_all_mode(text, -1, false, false)
}

///|
/// 默认档的全部命中，带位置与词表原词。
///
/// - Raises: 无——纯查询
pub fn WordTree::match_all_words(
  self : WordTree,
  text : String,
) -> Array[FoundWord] {
  self.match_all_words_mode(text, -1, false, false)
}

///|
/// 三档语义的出口（`String` 形态，给脱敏/高亮直接用）。
///
/// - Parameters:
///   - text: 待查文本
///   - limit: 命中条数上限；**只有 `> 0` 才生效**，`0` 与任何负数都当不限（实测 `limit=0` 与
///     `limit=-2` 与 `-1` 同读）
///   - density: 密集匹配——命中后**不跳过整段**，继续在同一处往后找（`["ab","b"]` 对 `"abab"`
///     给 `ab, b, ab, b`；默认档只给 `ab, ab`）
///   - greed: 贪婪（同起点往长里读）——**只在 `density=true` 时有效**，`density=false` 时该参数
///     不起作用（见文件头规则 3）
/// - Raises: 无——纯查询
pub fn WordTree::match_all_mode(
  self : WordTree,
  text : String,
  limit : Int,
  density : Bool,
  greed : Bool,
) -> Array[String] {
  let out : Array[String] = []
  for f in self.match_all_words_mode(text, limit, density, greed) {
    out.push(f.found)
  }
  out
}

///|
/// 三档语义的出口（带位置的完整形态；上面所有查询都是它的特例）。
///
/// - Raises: 无——纯查询
pub fn WordTree::match_all_words_mode(
  self : WordTree,
  text : String,
  limit : Int,
  density : Bool,
  greed : Bool,
) -> Array[FoundWord] {
  let cs = text.to_array()
  let n = cs.length()
  let off = unit_offsets(cs)
  let out : Array[FoundWord] = []
  let mut done = false
  let mut i = 0
  while i < n && !done {
    let ks : Array[Char] = []
    let mut cur = 0
    let mut j = i
    let mut stop = false
    while j < n && !stop {
      let c = cs[j]
      if is_stop_char(c) {
        // 词中间的停顿字符留在 found 区间里、不进 word；词首的整格跳过
        // （参照实现那句 `i++` 就是这一档，实测起点因此后移）
        if ks.length() == 0 {
          i = i + 1
        }
        j = j + 1
      } else if false == self.children[cur].contains(c) {
        // 非关键字：整段放弃，下一起点重扫
        stop = true
      } else {
        ks.push(c)
        let child = self.children[cur][c]
        if self.ends[child] {
          out.push(FoundWord::{
            word: key_text(ks),
            found: span(cs, i, j),
            start: off[i],
            end: off[j],
          })
          if limit > 0 && out.length() >= limit {
            done = true
            stop = true
          } else if false == density {
            // 非密集档：命中后整段跳过（下一起点 = j + 1）
            i = j
            stop = true
          } else if false == greed {
            // 密集档 + 非贪婢：同起点不往长里读
            stop = true
          }
        }
        if !stop {
          cur = child
          j = j + 1
        }
      }
    }
    i = i + 1
  }
  out
}

///|
/// 是否停顿字符：建树与匹配时都不参与转移（词中间的停顿字符被**吸收进 `found`**、
/// 不进 `word`；词首的停顿字符被跳过，见 spec §3 的三条实测档）。
///
/// 这一张嘴是参照实现 `StopChar.isStopChar` 的**全 BMP 对位**：`STOP_WORD` 表（去重 303 个码位）
/// ∪ `Character.isWhitespace`（一并扫出全表 327 个码位）。表由生成脚本从参照腿灌进来，
/// 用例只钉规模读数与边界点——钉 327 位等于把表抄第二遍（spec §4 第 2 条腿）。
///
/// - Note: **码表按口径独立成数据件**：`stop_chars.mbt` 只放数据、不放逻辑，实现那一笔一起进。
/// - Raises: 无——纯查表
pub fn is_stop_char(c : Char) -> Bool {
  let cu = c.to_int()
  // 表有序，二分；表本体在 stop_chars.mbt（数据件）
  let mut lo = 0
  let mut hi = stop_cache.length() - 1
  let mut found = false
  while !found && lo <= hi {
    let mid = (lo + hi) / 2
    let v = stop_cache[mid]
    if v == cu {
      found = true
    } else if v < cu {
      lo = mid + 1
    } else {
      hi = mid - 1
    }
  }
  found
}

///|
/// 是否参与匹配（`is_stop_char` 的反面，名字跟着参照实现的 `isNotStopChar` 留一条——
/// 建树时的过滤谓词用它，读起来不必再取反）。
/// - Raises: 无——纯查表
pub fn is_not_stop_char(c : Char) -> Bool {
  false == is_stop_char(c)
}

///|
// 停顿字符表的**只读缓存**（顶层绑定，不是全局可变注册表——没有一个写入口）。
// 每个字符重新 alloc 一张 327 项的表，BMP 扫描那种调用量下会白烧分配。
let stop_cache : Array[Int] = stop_table()
