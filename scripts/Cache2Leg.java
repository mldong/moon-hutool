// moon-hutool/cache —— 第九批补档的参照腿（命中档、空表档、remove 缺键档、prune 过期档）。
// 全部 ASCII 输出。时钟一律显式传（腿侧用 hutool 的 ttl + 手工 pruneExpired 对照）。
import cn.hutool.cache.CacheUtil;
import cn.hutool.cache.impl.LRUCache;
import cn.hutool.cache.impl.TimedCache;

public class Cache2Leg {
  public static void main(String[] a) {
    // 1) 命中档：put 之后 get 命中
    LRUCache<String, Integer> lru = CacheUtil.newLRUCache(4);
    lru.put("a", 1);
    lru.put("b", 2);
    System.out.println("HIT|a|" + lru.get("a", false) + "|" + lru.get("zz", false) + "|" + lru.get("cc", () -> 42) + "|" + lru.get("a", () -> 99));

    // 2) 空表档：新建未写入时 isEmpty()
    LRUCache<String, Integer> lru2 = CacheUtil.newLRUCache(4);
    TimedCache<String, Integer> tc2 = CacheUtil.newTimedCache(10L);
    System.out.println("EMPTY|lru|" + lru2.isEmpty() + "|" + lru2.size());
    System.out.println("EMPTY|timed|" + tc2.isEmpty() + "|" + tc2.size());

    // 3) remove 缺键档：cancel 不存在的键 ⇒ false，size 不变
    LRUCache<String, Integer> lru3 = CacheUtil.newLRUCache(4);
    lru3.put("a", 1);
    lru3.remove("nope");
    System.out.println("CANCEL|nope|" + lru3.size() + "|" + lru3.get("a", false) + "|" + lru3.containsKey("nope"));

    // 4) Timed 过期 prune 档：ttl=10，写入后推进到超时，pruneExpired 计数与剩余
    TimedCache<String, Integer> tc = CacheUtil.newTimedCache(10L);
    tc.put("a", 1);
    tc.put("b", 2);
    sleep(30L);
    int pruned = tc.prune();
    System.out.println("PRUNE|timed|" + pruned + "|" + tc.size() + "|" + tc.get("a", false) + "|" + tc.isEmpty());

    // 5) LRU 无过期档：同样两份数据，pruneExpired 应该零移除
    LRUCache<String, Integer> lru4 = CacheUtil.newLRUCache(4);
    lru4.put("a", 1);
    sleep(30L);
    System.out.println("PRUNE|lru|" + lru4.prune() + "|" + lru4.size() + "|" + lru4.get("a", false) + "|" + lru4.isEmpty());

    // 6) 守卫自检：三档出口互不相同
    String g1 = "" + lru.get("a", false);
    String g2 = "" + lru.get("zz", false);
    String g3 = "" + lru2.size();
    System.out.println("G|guard|" + g1 + "|" + g2 + "|" + g3);
    System.out.println(g1.equals(g2) || g1.equals(g3) || g2.equals(g3)
        ? "G|GUARD_BAD|not_distinct" : "G|GUARD_OK|distinct3");
  }

  static void sleep(long ms) {
    try {
      Thread.sleep(ms);
    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
    }
  }
}
