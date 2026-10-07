#!/usr/bin/env python
# cache 第九批补档生成器：把 Cache2Leg.java 的读数灌成 cache/cache_default2_test.mbt。
# 用法：python scripts/gen_cache2_test.py <cache2_leg.txt>
# 期望只从腿的读数取，手打零条；每档的 MoonBit 表达式在下面的表里，表只写"怎么调用"，不写值。
import io
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if len(sys.argv) < 2:
    raise SystemExit("用法：python scripts/gen_cache2_test.py <cache2_leg.txt>")
LEG = os.path.abspath(sys.argv[1])
OUT = os.path.join(REPO, "cache", "cache_default2_test.mbt")

HEAD = '''///|
// cache 默认档补档（10-08）——命中档、空表档、remove 缺键档、prune 过期档此前一条用例都没打到
// （既有测试全走 fifo/lfu 的踢出与公平减计那几支）。
// 期望全部由 Cache2Leg.java 现读灌入（hutool-cache 5.8.35 · JDK 17.0.14），手打零条。
// 本库时钟由调用方显式传 now（参照读墙钟），所以每条都写明用的时刻。

'''

BLOCKS = []


def blk(name, comment, expr):
    BLOCKS.append((name, comment, expr))


def main():
    rows = {}
    for raw in io.open(LEG, encoding="utf-8", errors="replace").read().replace("\r", "").splitlines():
        f = raw.split("|")
        if f[0] == "G":
            continue
        rows[f[0] + "-" + f[1]] = f[2:]

    def vals(key):
        return rows[key]

    # HIT-a: get 命中 / get 缺键 / get_or_put 缺键 / get_or_put 命中
    h = vals("HIT-a")
    blk("hit-get",
        "put 之后 get 命中 ｜ 参照=%s ｜ 缺键参照=%s" % (h[0], h[1]),
        '''let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.CachePolicy::Lru, 4, 0L)
  @cache.Cache::put(c, "a", 1, 0L)
  @cache.Cache::put(c, "b", 2, 0L)
  assert_eq(c.get("a", 0L), Some(1))
  assert_eq(c.get("zz", 0L), None)''')
    blk("hit-get_or_put",
        "get_or_put：缺键走 supplier、命中不回表 ｜ 参照 get(k, Func0) 缺键=%s 命中=%s" % (h[2], h[3]),
        '''let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.CachePolicy::Lru, 4, 0L)
  @cache.Cache::put(c, "a", 1, 0L)
  assert_eq(c.get_or_put("cc", 0L, () => 42), 42)
  assert_eq(c.get_or_put("a", 0L, () => 99), 1)''')
    # 空表档
    for k, pol in (("EMPTY-lru", "Lru"), ("EMPTY-timed", "Timed")):
        v = vals(k)
        blk("empty-" + k.split("-")[1],
            "新建未写入 ｜ 参照 isEmpty=%s size=%s" % (v[0], v[1]),
            '''let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.CachePolicy::%s, 4, 10L)
  assert_eq(c.is_empty(), %s)
  assert_eq(c.size(), %s)''' % (pol, v[0], v[1]))
    # remove 缺键档
    c = vals("CANCEL-nope")
    blk("remove-missing",
        "remove 不存在的键 ｜ 参照 remove 后 size=%s a=%s containsKey=%s" % (c[0], c[1], c[2]),
        '''let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.CachePolicy::Lru, 4, 0L)
  @cache.Cache::put(c, "a", 1, 0L)
  c.remove("nope")
  assert_eq(c.size(), %s)
  assert_eq(c.get("a", 0L), Some(%s))
  assert_eq(c.contains_key("nope", 0L), %s)''' % (c[0], c[1], c[2]))
    # prune 过期档（Timed）与不过期档（Lru）
    t = vals("PRUNE-timed")
    blk("prune-timed",
        "Timed ttl=10，t=0 写两条，t=30 prune ｜ 参照 prune=%s size=%s get=%s isEmpty=%s"
        % (t[0], t[1], t[2], t[3]),
        '''let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.CachePolicy::Timed, 8, 10L)
  @cache.Cache::put(c, "a", 1, 0L)
  @cache.Cache::put(c, "b", 2, 0L)
  assert_eq(c.prune(30L), %s)
  assert_eq(c.size(), %s)
  assert_eq(c.get("a", 30L), %s)
  assert_eq(c.is_empty(), %s)''' % (t[0], t[1], "None" if t[2] == "null" else "Some(%s)" % t[2], t[3]))
    l = vals("PRUNE-lru")
    blk("prune-lru",
        "Lru 且 timeout=0（腿用的是 newLRUCache(4)，无缺省超时）推进到 t=30 ｜ 参照 prune=%s size=%s a=%s isEmpty=%s"
        % (l[0], l[1], l[2], l[3]),
        '''let c : @cache.Cache[String, Int] = @cache.Cache::new_cache(@cache.CachePolicy::Lru, 4, 0L)
  @cache.Cache::put(c, "a", 1, 0L)
  assert_eq(c.prune(30L), %s)
  assert_eq(c.size(), %s)
  assert_eq(c.get("a", 30L), %s)
  assert_eq(c.is_empty(), %s)''' % (l[0], l[1], "None" if l[2] == "null" else "Some(%s)" % l[2], l[3]))

    body = HEAD + "\n\n".join(
        '///|\ntest "cache 默认档 %s" {\n  // %s\n  %s\n}' % (n, c, e) for n, c, e in BLOCKS) + "\n"
    io.open(OUT, "w", encoding="utf-8", newline="\n").write(body)
    print("blocks=%d file=%s" % (len(BLOCKS), OUT))


main()
