///|
// sched 的 PR-A 用例：**只装形状级判据**。
// 这些断言的右侧不是参照读数——参照侧的行为（重复 id 是覆盖还是报错、秒栅格对齐、stop 时执行中任务
// 的去向）现读不出来，必须先由新增腿 `scripts/Cron5Leg.java` 转正，那批期望值另笔补（spec §6 的 N1/P1/P2）。
// 本文件钉的是"契约自己说过、且不依赖参照读数"的那几条恒等式。
// 骨架期这些块**预期红**（函数体是 `abort`，`abort` 抛出的不是本包错误档）；落地那一笔转绿。

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
