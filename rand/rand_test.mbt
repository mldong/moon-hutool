///|
// 第一批（rand）的期望值来源与口径：
//   腿 A = 真 hutool-core-5.8.35 + 本机 JDK 17.0.14 跑 `RandomUtil`/`WeightRandom`（`rand_ref.txt`，57 条读数）
//   腿 B = core `@random` 的能力面（`Rand::int` 的界值档、`chacha8` 的 32 字节种子界、无 seed 时回落固定种子）
// 参照实现**不可注入随机源**（55 个 `public static` 里没有一个收 `Random` 参数），所以这里没有
// "第 N 次调用等于某个固定串"这种期望，也没有"抽样里两个值都出现过"这种概率断言——
// 冻下来的全是**对任意随机流都成立**的东西：单点域、长度、字符集包含、错误档、零权重永不中选。
// 规则书与全部出处：docs/spec/12-rand.md。改任何一条期望须单独一笔并给外部读数来源（门禁 G5）。

///|
/// 把错误面折成字符串：变体名 + 携带值一起进断言（携带值也是契约的一部分）
fn show(err : @rand.RandError) -> String {
  match err {
    @rand.EmptyDomain(s) => "EmptyDomain \{s}"
    @rand.EmptyCollection(n) => "EmptyCollection \{n}"
    @rand.EmptyAlphabet(n) => "EmptyAlphabet \{n}"
    @rand.BadCount(s) => "BadCount \{s}"
  }
}

///|
// 跑一次预期会 raise 的调用，返回错误形状；没 raise 就返回「未抛错」
fn[A] cn_err(g : () -> A raise @rand.RandError) -> String {
  try {
    let _ = g()
    "未抛错"
  } catch {
    err => show(err)
  }
}

///|
// 固定 32 字节的种子（core 的 `chacha8` 要求 32 字节）。下面每条断言都与随机流无关，种子取什么不影响结论
fn seeded() -> @random.Rand {
  @random.Rand::chacha8(seed=b"01234567890123456789012345678901")
}

///|
// 数出 `s` 里有多少个字符**不在** `table` 中——用来把"字符取自表"写成一条与流无关的不变量
fn outside(table : String, s : String) -> Int {
  let set : Set[String] = Set([])
  for ch in table.to_array() {
    set.add(ch.to_string())
  }
  let mut n = 0
  for ch in s.to_array() {
    if set.contains(ch.to_string()) == false {
      n += 1
    }
  }
  n
}

///|
// 四张表的内容与长度都由腿 A 反射读出（`table|` 那 4 行），顺序照抄：全表是**大写在前**
test "rand：四张字符表原样（#12.1~#12.4）" {
  assert_eq(@rand.alphabet_number(), "0123456789")
  assert_eq(@rand.alphabet_number().length(), 10)
  assert_eq(@rand.alphabet_lower(), "abcdefghijklmnopqrstuvwxyz")
  assert_eq(@rand.alphabet_lower().length(), 26)
  assert_eq(
    @rand.alphabet_lower_number(),
    "abcdefghijklmnopqrstuvwxyz0123456789",
  )
  assert_eq(@rand.alphabet_lower_number().length(), 36)
  assert_eq(
    @rand.alphabet_all(),
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
  )
  assert_eq(@rand.alphabet_all().length(), 62)
}

///|
// 界值语义四组合全是**单点域**（腿 A 各抽 3000 次，读数只有那一个值）：
// (0,1) 含下不含上 ⇒ 恒 0；不含下含上 ⇒ 恒 1；双不含 ⇒ 空域；双含时等值不是空域（0,0 ⇒ 恒 0）
test "rand：random_int 的界值与空域（#12.5）" {
  assert_eq(@rand.random_int(seeded(), 0, 1), 0)
  assert_eq(@rand.random_int(seeded(), 0, 1, incl_min=false, incl_max=true), 1)
  assert_eq(@rand.random_int(seeded(), 0, 2, incl_min=false, incl_max=false), 1)
  assert_eq(@rand.random_int(seeded(), -1, 0), -1)
  assert_eq(@rand.random_int(seeded(), 0, 0, incl_min=true, incl_max=true), 0)
  assert_eq(
    cn_err(() => @rand.random_int(seeded(), 1, 1)),
    "EmptyDomain min=1,max=1,incl_min=true,incl_max=false",
  )
  assert_eq(
    cn_err(() => @rand.random_int(seeded(), 2, 1)),
    "EmptyDomain min=2,max=1,incl_min=true,incl_max=false",
  )
  assert_eq(
    cn_err(() => {
      @rand.random_int(seeded(), 0, 1, incl_min=false, incl_max=false)
    }),
    "EmptyDomain min=0,max=1,incl_min=false,incl_max=false",
  )
  // 双含的 (0,1) 不是单点域，但"取到的值只能落在 0 或 1"是与流无关的界
  let r = seeded()
  let mut out = 0
  let mut k = 0
  while k < 300 {
    let v = @rand.random_int(r, 0, 2, incl_min=true, incl_max=true)
    if v < 0 || v > 2 {
      out += 1
    }
    k += 1
  }
  assert_eq(out, 0)
}

///|
// `n` 非正没有定义域（腿 A 是底下引擎的 `IllegalArgumentException: bound must be positive`，本包给 `EmptyDomain`）
test "rand：random_int_under 与 random_boolean（#12.6~#12.7）" {
  assert_eq(@rand.random_int_under(seeded(), 1), 0)
  assert_eq(
    cn_err(() => @rand.random_int_under(seeded(), 0)),
    "EmptyDomain n=0",
  )
  assert_eq(
    cn_err(() => @rand.random_int_under(seeded(), -1)),
    "EmptyDomain n=-1",
  )
  let r = seeded()
  let mut bad = 0
  let mut k = 0
  while k < 300 {
    let v = @rand.random_int_under(r, 3)
    if v < 0 || v > 2 {
      bad += 1
    }
    k += 1
  }
  assert_eq(bad, 0)
  // `random_boolean` 在 PR-A **不钉期望值**：1 位生成没有任何"与随机流无关"的性质可钉，
  // 而钉固定值要把 core 的取数算法冻进本包契约。这一件的期望值在实现轮由脚本化 `Source` 补
  // （spec §4 第 5 条），现在钉的是它底下那一次 `random_int_under(2)` 的域。
}

///|
// 字符串族：长度对、字符取自给定表、过滤档真滤掉。
// 两条实测怪癖按本包口径改判：`length=0` 给空串（腿 A 给长度 1，§5 第 1 行）；空表 + 非零长度报错
test "rand：字符串族六件（#12.8~#12.14）" {
  let r = seeded()
  assert_eq(@rand.random_string(r, 0), "")
  assert_eq(@rand.random_string(r, 40).length(), 40)
  assert_eq(outside(@rand.alphabet_all(), @rand.random_string(r, 600)), 0)
  assert_eq(@rand.random_string_lower(r, 30).length(), 30)
  assert_eq(
    outside(@rand.alphabet_lower(), @rand.random_string_lower(r, 300)),
    0,
  )
  assert_eq(outside(@rand.alphabet_number(), @rand.random_numbers(r, 300)), 0)
  // random_string_upper 的结果集实测只有 36 个字符（数字 + 大写），因为 62 表里本来就带数字
  assert_eq(
    outside(
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
      @rand.random_string_upper(r, 400),
    ),
    0,
  )
  assert_eq(outside("ab", @rand.random_string_from(r, "ab", 50)), 0)
  let wo = @rand.random_string_without(r, 400, "aA1")
  assert_eq(wo.length(), 400)
  assert_eq(
    outside("bcdefghijklmnopqrstuvwxyzBCDEFGHIJKLMNOPQRSTUVWXYZ023456789", wo),
    0,
  )
  assert_eq(
    cn_err(() => @rand.random_string_from(seeded(), "", 1)),
    "EmptyAlphabet 0",
  )
  // 空表 + 零长度是"取 0 个字符"，不是错误
  assert_eq(@rand.random_string_from(seeded(), "", 0), "")
  assert_eq(@rand.random_string_without(seeded(), 0, "a").length(), 0)
}

///|
// 取元素族：`limit` 是"只看前 N 个"（腿 A 实测 limit=1 恒返回第 0 个），空集合报错
test "rand：取元素三件（#12.15~#12.17）" {
  let r = seeded()
  let items = ["a", "b", "c"]
  let empty : Array[String] = []
  assert_eq(@rand.random_ele(r, items, limit=1), "a")
  assert_eq(@rand.random_eles(r, items, 7).length(), 7)
  assert_eq(@rand.random_eles(r, items, 0).length(), 0)
  assert_eq(@rand.random_ele_set(r, items, 3).length(), 3)
  assert_eq(cn_err(() => @rand.random_ele(r, empty)), "EmptyCollection 0")
  assert_eq(
    cn_err(() => @rand.random_ele(r, items, limit=0)),
    "EmptyCollection 0",
  )
  assert_eq(
    cn_err(() => @rand.random_ele_set(r, items, 4)),
    "BadCount count=4,available=3",
  )
}

///|
// 加权件：零权重永不中选；空表在 `next` 时报错（构造不校验——腿 A 实测负权重与空表构造都不抛）
test "rand：加权随机（#12.18~#12.19）" {
  let r = seeded()
  let z = @rand.weight_random([("x", 1.0), ("y", 0.0)])
  let mut saw_y = 0
  let mut k = 0
  while k < 300 {
    if @rand.weight_random_next(z, r) == "y" {
      saw_y += 1
    }
    k += 1
  }
  assert_eq(saw_y, 0)
  let empty_w : @rand.WeightRandom[String] = @rand.weight_random([])
  assert_eq(
    cn_err(() => @rand.weight_random_next(empty_w, r)),
    "EmptyCollection 0",
  )
}
