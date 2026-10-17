///|
/// 连接池（issue #5）：按 origin 键复用官方 `Client`。键 = (base, user-agent)——
/// 构造期持久头现读只可能带 user-agent（`adapter.mbt` 的 prepare 把它单独分流）；
/// 以后若有别的头挪进持久头，键必须跟着变，**不然后一个请求会带着前一个请求的头**。
///
/// 并发口径：moonbitlang/async 是协作式单线程调度，checkout/deposit 全程无 await 点，
/// 结构性原子——这里不需要锁。上游若引入抢占式调度，本文件是第一个要复查的地方。
///
/// 单元可测性：client 类型与关线动作都是注入口（`Pool[C]` + `discard`），时钟也是——
/// 生产侧给官方 Client 与 `@date.now_millis`，测试侧给桩与假钟（G18 口径：不裸读 @env.now）。
priv struct PoolEntry[C] {
  key : String
  client : C
  deposited_ms : Int64
}

///|
priv struct Pool[C] {
  mut entries : Array[PoolEntry[C]]
  max_idle_per_origin : Int32
  idle_ttl_ms : Int64
  clock : () -> Int64
  discard : (C) -> Unit
}

///|
fn[C] pool_new(
  max_idle_per_origin : Int32,
  idle_ttl_ms : Int64,
  clock : () -> Int64,
  discard : (C) -> Unit,
) -> Pool[C] {
  { entries: [], max_idle_per_origin, idle_ttl_ms, clock, discard, }
}

///|
/// 池键。base 形如 "scheme://host:port"（不含 @），user-agent 可空——"@@ 不出现在 base 里"
/// 由 split_url 的 authority 切分保证（userinfo 根本进不了官方 resolve_host）。
fn pool_key(base : String, ua : String?) -> String {
  let ua_part = match ua {
    Some(v) => v
    None => ""
  }
  base + "@@" + ua_part
}

///|
/// 取一条同键空闲连接：先清过期（TTL 到点的线对端可能早已关掉，宁丢不错），
/// 再取该键**最旧**的一条（FIFO——让老线先复用，免得新线一直占着池直到过期）。
fn[C] Pool::checkout(self : Pool[C], key : String) -> C? {
  let now = (self.clock)()
  let kept : Array[PoolEntry[C]] = []
  let mut found : C? = None
  for entry in self.entries {
    if now - entry.deposited_ms > self.idle_ttl_ms {
      (self.discard)(entry.client)
    } else if found is None && entry.key == key {
      found = Some(entry.client)
    } else {
      kept.push(entry)
    }
  }
  self.entries = kept
  found
}

///|
/// 归还一条读尽且可复用的连接。同键超额时最旧的先关线（FIFO 淘汰）；
/// 上限 <=0 视为"这键不进池"，直接关线。
fn[C] Pool::deposit(self : Pool[C], key : String, client : C) -> Unit {
  if self.max_idle_per_origin <= 0 {
    (self.discard)(client)
    return
  }
  let mut same_key = 0
  for entry in self.entries {
    if entry.key == key {
      same_key += 1
    }
  }
  while same_key >= self.max_idle_per_origin {
    let kept : Array[PoolEntry[C]] = []
    let mut removed = false
    for entry in self.entries {
      if !removed && entry.key == key {
        removed = true
        (self.discard)(entry.client)
      } else {
        kept.push(entry)
      }
    }
    self.entries = kept
    same_key -= 1
  }
  self.entries.push({ key, client, deposited_ms: (self.clock)(), })
}

///|
/// 收掉池里全部空闲连接（进程收尾 / 测试收尾用；生产入口是
/// `AsyncHttpTransport::drain_connections`）。
fn[C] Pool::drain(self : Pool[C]) -> Unit {
  for entry in self.entries {
    (self.discard)(entry.client)
  }
  self.entries = []
}
