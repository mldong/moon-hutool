///|
// sched 的 PR-A 用例：**只装形状级判据**。
// 这些断言的右侧不是参照读数——参照侧的行为（重复 id 是覆盖还是报错、秒栅格对齐、stop 时执行中任务
// 的去向）现读不出来，必须先由新增腿 `scripts/Cron5Leg.java` 转正，那批期望值另笔补（spec §6 的 N1/P1/P2）。
// 本文件钉的是"契约自己说过、且不依赖参照读数"的那几条恒等式。
// 落地轮终局读数：`moon test --target wasm` 与 `--target js` 均 12 块全绿（0 警告），变异对照 7 条全抓到，明细见 `docs/spec/24-sched.md` §8。

///|
test "#24.4/#24.11/#24.12/#24.8 空表恒等式：条数 0、判空真、id 表空" {
  let t = @sched.table_new()
  assert_eq(@sched.table_size(t), 0)
  assert_eq(@sched.table_is_empty(t), true)
  assert_eq(@sched.table_ids(t).length(), 0)
}

///|
test "#24.3 默认配置的 `match_second` 缺省为假（参照 `CronConfig` 默认 `false`，本库跟随）" {
  let c = @sched.config_default()
  assert_eq(c.match_second, false)
}

///|
test "#24.6 摘一个不存在的键给假，而不是抛错（本库形状：`remove` 返回 Bool，缺件不当异常）" {
  let t = @sched.table_new()
  assert_eq(@sched.table_remove(t, "not-registered"), false)
}

///|
test "#24.13 空表在任何时刻都不该有该触发的下标（`due_indices` 是纯函数，不推进状态）" {
  let t = @sched.table_new()
  let c = @sched.config_default()
  // UTC 的 1970-01-01 在 date 区表窗口内；取不到就让 unwrap 把这条判据炸红，
  // 不写兜底——静默跳过等于这条格没测
  let now = @date.datetime_in("UTC", 0L).unwrap()
  assert_eq(@sched.due_indices(t, c, now).length(), 0)
}

///|
// ============ 下面这几块是 spec §2 验收线第 1 条 ============
// 到点触发、不到点不触发、**同一瞬间连喂两次就执行两次**（腿 N2 现读 `hits=2`，参照不去重 ⇒ 本库同形）。
// 全程假时钟 + 假 sleeper，没有计时依赖。
//
// 本版裁决三条（别再撞）：
//   ① `Sleeper = async (Int) -> Unit` 不收普通函数值（"has type (Int) -> Unit, wanted async (Int) -> Unit"），
//      `async (…) => …` 箭头写法判 Parse error ⇒ 假 sleeper 只能写成顶层 `async fn`；
//   ② 而 **impl trait 方法时不写 async**（照 mldong-moon 的 DevQueryApi 实现形状），与 ① 不同形；
//   ③ 顶层 `let mut` 非法 ⇒ 计数器用单元素 `Array[Int]`（数组是引用语义）。

async fn noop_sleep(_ms : Int) -> Unit {
  // 本版两头堵：普通 fn 塞不进 `async (Int) -> Unit`，而空转的 async 吃 unused_async（零警告门禁）
  // ⇒ 真 await 一手的本包 default_sleeper(0)：0 毫秒，不落计时依赖
  @sched.default_sleeper(0)
}

///|
priv struct Tally {
  hits : Array[Int]
}

///|
impl Task for Tally with fn execute(self : Tally) -> Unit {
  self.hits[0] = self.hits[0] + 1
}

///|
priv suberror Boom {
  BoomNow
}

///|
priv struct Bomber {}

///|
impl Task for Bomber with fn execute(self : Bomber) -> Unit raise Error {
  let _ = self // 任务体不用状态，本版仍会报 unused_value ⇒ 显式忽略
  raise Boom::BoomNow
}

// 2024-01-01 12:00:00 UTC

///|
let noon_utc_millis : Int64 = 1704110400000L

///|
// 段序按 秒 分 时…：`0 0 12 * * ?` 命中 12:00:00，`0 30 12 * * ?` 不命中。
// 夹具差在"分位"上，match_second 开或关都同判 ⇒ 判据不吃秒档歧义。
// unit 随 match_second：本用例 cfg 开了秒档 ⇒ 对齐步长是 1000，不是 60000
fn cfg_utc() -> @sched.CronConfig {
  @sched.CronConfig::{ match_second: true, zone: "UTC", }
}

///|
// 只被"start 唤醒对齐"那一条用例用的两格（其余用例不碰，避免并发用例互盖全局槽）
let leg_seen : Array[Int] = []

///|
let leg_held : Array[@sched.Scheduler] = []

///|
async fn sleep_and_stop(ms : Int) -> Unit {
  noop_sleep(ms) // 真 await，免得 async 注解空转吃 unused_async
  leg_seen.push(ms)
  if leg_seen.length() >= 2 && leg_held.length() > 0 {
    @sched.scheduler_stop(leg_held[0])
  }
}

///|
async test "到点触发一次：tick 返回执行条数 1，任务体进了一次" {
  let hits : Array[Int] = [0]
  let t = @sched.table_new()
  @sched.table_add(t, "noon", "0 0 12 * * ?", Tally::{ hits, })
  let s = @sched.scheduler_new(t, cfg_utc(), () => noon_utc_millis, noop_sleep)
  assert_eq(@sched.scheduler_tick(s), 1)
  assert_eq(hits[0], 1)
}

///|
async test "不到点不触发：tick 给 0，任务体一次都没进" {
  let hits : Array[Int] = [0]
  let t = @sched.table_new()
  @sched.table_add(t, "half", "0 30 12 * * ?", Tally::{ hits, })
  let s = @sched.scheduler_new(t, cfg_utc(), () => noon_utc_millis, noop_sleep)
  assert_eq(@sched.scheduler_tick(s), 0)
  assert_eq(hits[0], 0)
}

///|
async test "同一瞬间连喂两次就执行两次（与参照同形，本库不去重）" {
  let hits : Array[Int] = [0]
  let t = @sched.table_new()
  @sched.table_add(t, "noon", "0 0 12 * * ?", Tally::{ hits, })
  let s = @sched.scheduler_new(t, cfg_utc(), () => noon_utc_millis, noop_sleep)
  assert_eq(@sched.scheduler_tick(s), 1)
  assert_eq(@sched.scheduler_tick(s), 1)
  assert_eq(hits[0], 2)
}

///|
async test "start 的唤醒对齐 =(now/unit+1)*unit-now，unit 随 match_second 取 1000/60000；第二次进 sleeper 时 stop 生效" {
  let hits : Array[Int] = [0]
  leg_seen.clear()
  leg_held.clear()
  let t = @sched.table_new()
  @sched.table_add(t, "noon", "0 0 12 * * ?", Tally::{ hits, })
  let s = @sched.scheduler_new(
    t,
    cfg_utc(),
    () => noon_utc_millis,
    sleep_and_stop,
  )
  leg_held.push(s)
  assert_eq(@sched.scheduler_is_started(s), false)
  @sched.scheduler_start(s)
  assert_eq(leg_seen.length(), 2)
  assert_eq(leg_seen[0], 1000)
  // 第一拍跑了任务；第二拍只置停 ⇒ 循环退出，不该再跑第二次
  assert_eq(hits[0], 1)
  assert_eq(@sched.scheduler_is_started(s), false)
}

///|
async test "缺省不注册回调则任务体的错误被忽略（参照同形）；注册后失败那条的 id 递得出来（P9）" {
  let hits : Array[Int] = [0]
  let failed : Array[String] = []
  let t = @sched.table_new()
  @sched.table_add(t, "boom", "0 0 12 * * ?", Bomber::{ })
  @sched.table_add(t, "noon", "0 0 12 * * ?", Tally::{ hits, })
  let s = @sched.scheduler_new(t, cfg_utc(), () => noon_utc_millis, noop_sleep)
  // 没注册回调：抛错那条照样算执行过，错误不漏给调用方，后面的任务照跑
  assert_eq(@sched.scheduler_tick(s), 2)
  assert_eq(hits[0], 1)
  assert_eq(failed.length(), 0)
  // 注册回调：拿到失败那条的 id
  @sched.scheduler_on_failed(s, (id : String, _err : Error) => failed.push(id))
  assert_eq(@sched.scheduler_tick(s), 2)
  assert_eq(failed.length(), 1)
  assert_eq(failed[0], "boom")
}

///|
test "摘除一条：三条并行数组同步收缩，剩下的那条仍按原下标取得到（跟参照的 List 形状同构）" {
  let hits : Array[Int] = [0]
  let t = @sched.table_new()
  @sched.table_add(t, "a", "0 0 12 * * ?", Tally::{ hits, })
  @sched.table_add(t, "b", "0 30 12 * * ?", Tally::{ hits, })
  assert_eq(@sched.table_size(t), 2)
  assert_eq(@sched.table_remove(t, "a"), true)
  assert_eq(@sched.table_size(t), 1)
  assert_eq(@sched.table_ids(t), ["b"]) // 本版 Array::to_string 走 Show（已废弃）⇒ 直接比数组
  assert_eq(@sched.table_pattern_text(t, "b"), "0 30 12 * * ?")
  assert_eq(@sched.table_remove(t, "a"), false)
}

///|
test "改表达式不换任务体：在册文本跟着换，摘不存在的键给 false" {
  let hits : Array[Int] = [0]
  let t = @sched.table_new()
  @sched.table_add(t, "a", "0 0 12 * * ?", Tally::{ hits, })
  assert_eq(@sched.table_update_pattern(t, "a", "0 30 12 * * ?"), true)
  assert_eq(@sched.table_pattern_text(t, "a"), "0 30 12 * * ?")
  assert_eq(@sched.table_update_pattern(t, "nope", "0 0 12 * * ?"), false)
  let bad = try {
    let _ = @sched.table_add(t, "c", "not a cron", Tally::{ hits, })
    "no-raise"
  } catch {
    _ => "raised"
  }
  assert_eq(bad, "raised")
}

///|
test "重复 id 第二次登记必须抛，且三条并行数组一格都不动（腿 N1 现读：参照抛 CronException 且表不变）" {
  let hits : Array[Int] = [0]
  let t = @sched.table_new()
  @sched.table_add(t, "dup", "0 0 12 * * ?", Tally::{ hits, })
  let shape = try {
    let _ = @sched.table_add(t, "dup", "0 30 12 * * ?", Tally::{ hits, })
    "no-raise"
  } catch {
    _ => "raised"
  }
  assert_eq(shape, "raised")
  assert_eq(@sched.table_size(t), 1)
  assert_eq(@sched.table_ids(t), ["dup"])
  // 第一个 task 与 pattern 必须原样保留（不是覆盖）
  assert_eq(@sched.table_pattern_text(t, "dup"), "0 0 12 * * ?")
}
