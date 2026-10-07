// moon-hutool/date 第五批（默认区与无参便捷入口）契约用例（黑盒）。**生成件，勿手改**：
// 生成器 scripts/gen_default_test.py。
//
// 期望值来源：**同包已冻断言里的读数**，逐条抽取、缺一条就停（不手打、不自己算）——
//   §5 zone_test.mbt 的 zone_offset_minutes（腿 P 行）· §7 format_test.mbt 的
//   format_in（腿 F/G 行）、to_rfc3339_in（腿 R 行）、parse_in 与 ZoneGap（腿 S 行）。
// 本库自订、没有腿读数的三档（兜底值取值 / 表外回落 / set-reset 的优先级与不改值）
// 在行内标「本库自订」，判据与代价见 spec §8.3。
//
// 环境变量档的纪律：每块自带前置（reset_default_zone + 自己 set/unset "TZ"），不依赖块序——
// 实测 set_env_var 之后立即读得到、unset 之后回到 <absent>（wasm/js/wasm-gc 三档一致）。
// helper dflt_tag 带前缀（同包多个 _test.mbt 共享顶层命名空间）；错误形状复用 date_test.mbt 的 shape。
//
// 状态：**契约已冻结**（PR-A），下列各块当前是预期红——函数体是 `abort`，PR-B 只许把红变绿。

///|
fn dflt_tag(s : @date.ZoneSource) -> String {
  match s {
    @date.FromOverride => "FromOverride"
    @date.FromEnv => "FromEnv"
    @date.Fallback => "Fallback"
  }
}

///|
// 本包的 Date/DateTime 只有 Eq/Compare，没有 Debug ⇒ assert_eq 直接比 Option[DateTime] 编译不过。
// 一律落成串再比，顺带让失败输出能同时看见两边读数。
fn dflt_dt(o : @date.DateTime?) -> String {
  match o {
    None => "None"
    Some(v) => v.to_iso_string()
  }
}

///|
fn dflt_d(o : @date.Date?) -> String {
  match o {
    None => "None"
    Some(v) => v.to_iso_string()
  }
}

///|
test "@date 兜底常量与它的闸门读数（本块 4 条）" {
  // 本库自订（spec §8.3 第 1 行）：兜底值本身没有腿读数；它的两条下游判据有。
  assert_eq(@date.fallback_zone, "Asia/Shanghai")
  assert_true(@date.zone_exists(@date.fallback_zone))
  assert_eq(@date.zone_offset_minutes(@date.fallback_zone, 0L), Some(480))
  assert_eq(
    @date.zone_offset_minutes(@date.fallback_zone, 1710052200000L),
    Some(480),
  )
}

///|
test "@date TZ 未设置：走兜底值而不是失败（本块 4 条）" {
  @date.reset_default_zone()
  @env.unset_env_var("TZ")
  // 本库自订（spec §8.3 第 1 行）：没给 ⇒ 取兜底值。
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  assert_eq(@date.default_zone(), "Asia/Shanghai")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(480),
  )
}

///|
test "@date TZ 给表内区：区名与偏移逐区对撞 §5 已冻读数（本块 55 条）" {
  @env.set_env_var("TZ", "Asia/Shanghai")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  assert_eq(@date.default_zone(), "Asia/Shanghai")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1730613600000L),
    Some(480),
  )
  assert_true(@date.zone_exists(@date.default_zone()))
  @env.set_env_var("TZ", "UTC")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  assert_eq(@date.default_zone(), "UTC")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1730613600000L),
    Some(0),
  )
  assert_true(@date.zone_exists(@date.default_zone()))
  @env.set_env_var("TZ", "Etc/GMT+5")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  assert_eq(@date.default_zone(), "Etc/GMT+5")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1730613600000L),
    Some(-300),
  )
  assert_true(@date.zone_exists(@date.default_zone()))
  @env.set_env_var("TZ", "Europe/Berlin")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  assert_eq(@date.default_zone(), "Europe/Berlin")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1730613600000L),
    Some(60),
  )
  assert_true(@date.zone_exists(@date.default_zone()))
  @env.set_env_var("TZ", "America/New_York")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  assert_eq(@date.default_zone(), "America/New_York")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1730613600000L),
    Some(-300),
  )
  assert_true(@date.zone_exists(@date.default_zone()))
  @env.set_env_var("TZ", "Asia/Kathmandu")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  assert_eq(@date.default_zone(), "Asia/Kathmandu")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(345),
  )
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1730613600000L),
    Some(345),
  )
  assert_true(@date.zone_exists(@date.default_zone()))
  @env.set_env_var("TZ", "Pacific/Chatham")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  assert_eq(@date.default_zone(), "Pacific/Chatham")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(825),
  )
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1730613600000L),
    Some(825),
  )
  assert_true(@date.zone_exists(@date.default_zone()))
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  assert_eq(@date.default_zone(), "Australia/Lord_Howe")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1730613600000L),
    Some(660),
  )
  assert_true(@date.zone_exists(@date.default_zone()))
  @env.set_env_var("TZ", "EST5EDT")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  assert_eq(@date.default_zone(), "EST5EDT")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1730613600000L),
    Some(-300),
  )
  assert_true(@date.zone_exists(@date.default_zone()))
  @env.set_env_var("TZ", "GMT0")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  assert_eq(@date.default_zone(), "GMT0")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1730613600000L),
    Some(0),
  )
  assert_true(@date.zone_exists(@date.default_zone()))
  @env.set_env_var("TZ", "Africa/Monrovia")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  assert_eq(@date.default_zone(), "Africa/Monrovia")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1730613600000L),
    Some(0),
  )
  assert_true(@date.zone_exists(@date.default_zone()))
}

///|
test "@date TZ 给表外值：一律回落兜底（偏移仍 480，不是 0）（本块 30 条）" {
  @env.set_env_var("TZ", "")
  // 本库自订（spec §8.3 第 2 行）：表外值回落兜底，**不跟随参照的静默 GMT=0**。
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(480),
  )
  @env.set_env_var("TZ", " ")
  // 本库自订（spec §8.3 第 2 行）：表外值回落兜底，**不跟随参照的静默 GMT=0**。
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(480),
  )
  @env.set_env_var("TZ", "asia/shanghai")
  // 本库自订（spec §8.3 第 2 行）：表外值回落兜底，**不跟随参照的静默 GMT=0**。
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(480),
  )
  @env.set_env_var("TZ", "UTC-8")
  // 本库自订（spec §8.3 第 2 行）：表外值回落兜底，**不跟随参照的静默 GMT=0**。
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(480),
  )
  @env.set_env_var("TZ", "/usr/share/zoneinfo/Asia/Shanghai")
  // 本库自订（spec §8.3 第 2 行）：表外值回落兜底，**不跟随参照的静默 GMT=0**。
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(480),
  )
  @env.set_env_var("TZ", "Factory")
  // 本库自订（spec §8.3 第 2 行）：表外值回落兜底，**不跟随参照的静默 GMT=0**。
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(480),
  )
  @env.set_env_var("TZ", "localtime")
  // 本库自订（spec §8.3 第 2 行）：表外值回落兜底，**不跟随参照的静默 GMT=0**。
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(480),
  )
  @env.set_env_var("TZ", "No/Where")
  // 本库自订（spec §8.3 第 2 行）：表外值回落兜底，**不跟随参照的静默 GMT=0**。
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(480),
  )
  @env.set_env_var("TZ", "Asia/Shanghai ")
  // 本库自订（spec §8.3 第 2 行）：表外值回落兜底，**不跟随参照的静默 GMT=0**。
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(480),
  )
  @env.set_env_var("TZ", "GMT+8:00")
  // 本库自订（spec §8.3 第 2 行）：表外值回落兜底，**不跟随参照的静默 GMT=0**。
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(480),
  )
}

///|
test "@date IANA legacy 区名在表内：走 env 而不是回落（本块 9 条）" {
  @date.reset_default_zone()
  @env.set_env_var("TZ", "EST5EDT")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  @env.set_env_var("TZ", "GMT0")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  @env.set_env_var("TZ", "UTC")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  @env.set_env_var("TZ", "Etc/GMT+5")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  @env.set_env_var("TZ", "Etc/UTC")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  @env.set_env_var("TZ", "GMT")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  // 更正一条想当然：`EST5EDT`/`GMT0` 看着像 POSIX 规则串，实为 IANA 的 legacy 区名，在表内。
  // 与宿主规则同读数（两条都已冻）——legacy link 不是特殊档，走的仍是 §5 那张表。
  assert_eq(@date.zone_offset_minutes("EST5EDT", 1710052200000L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("EST5EDT", 1710052200000L) ==
    @date.zone_offset_minutes("America/New_York", 1710052200000L),
    true,
  )
}

///|
test "@date 覆盖口优先级：压过 TZ 且偏移跟着换（本块 6 条）" {
  @date.reset_default_zone()
  @env.set_env_var("TZ", "UTC")
  // 本库自订（spec §8.3 第 3 行）：覆盖口优先级高于 `TZ`。
  assert_true(@date.set_default_zone("Europe/Berlin"))
  assert_eq(dflt_tag(@date.default_zone_source()), "FromOverride")
  assert_eq(@date.default_zone(), "Europe/Berlin")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(60),
  )
  // env 仍是 UTC：默认区必须不是 UTC，才证明覆盖真的压过它
  assert_eq(@env.get_env_var("TZ"), Some("UTC"))
  assert_eq(@date.default_zone(), "Europe/Berlin")
}

///|
test "@date 覆盖口坏名：给 false 且不落坏值（本块 6 条）" {
  @date.reset_default_zone()
  @env.set_env_var("TZ", "UTC")
  let _ = @date.set_default_zone("Europe/Berlin")
  // 本库自订（spec §8.3 第 4 行）：坏名给 false，且**当前默认区一字不动**。
  assert_false(@date.set_default_zone("No/Where"))
  assert_false(@date.set_default_zone(""))
  assert_false(@date.set_default_zone("asia/shanghai"))
  assert_eq(@date.default_zone(), "Europe/Berlin")
  assert_eq(dflt_tag(@date.default_zone_source()), "FromOverride")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(60),
  )
}

///|
test "@date reset 的三级回路与幂等（本块 7 条）" {
  @date.reset_default_zone()
  @env.set_env_var("TZ", "UTC")
  let _ = @date.set_default_zone("Europe/Berlin")
  // 复位 ⇒ 回到 env 那一档（env 还设着 UTC），不是直接跳到兜底
  @date.reset_default_zone()
  assert_eq(dflt_tag(@date.default_zone_source()), "FromEnv")
  assert_eq(@date.default_zone(), "UTC")
  // 换 env 值立刻跟着走（每次现读，不缓存——spec §8.2 第 1 行）
  @env.set_env_var("TZ", "Etc/GMT+5")
  assert_eq(@date.default_zone(), "Etc/GMT+5")
  assert_eq(
    @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
    Some(-300),
  )
  @env.unset_env_var("TZ")
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  // 复位一个没设过覆盖的进程应当是幂等的
  @date.reset_default_zone()
  assert_eq(dflt_tag(@date.default_zone_source()), "Fallback")
}

///|
test "@date format_local 的读数逐条等于 §7 已冻的 format_in（本块 110 条）" {
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd HH:mm:ss", Africa/Monrovia)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd HH:mm:ss"),
    Some("1969-12-31 23:16:00"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd HH:mm:ss", America/New_York)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd HH:mm:ss"),
    Some("1969-12-31 19:00:00"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd HH:mm:ss", Asia/Kathmandu)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd HH:mm:ss"),
    Some("1970-01-01 05:30:00"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd HH:mm:ss", Asia/Shanghai)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd HH:mm:ss"),
    Some("1970-01-01 08:00:00"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd HH:mm:ss", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd HH:mm:ss"),
    Some("1970-01-01 10:00:00"),
  )
  @env.set_env_var("TZ", "EST5EDT")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd HH:mm:ss", EST5EDT)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd HH:mm:ss"),
    Some("1969-12-31 19:00:00"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd HH:mm:ss", Etc/GMT+5)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd HH:mm:ss"),
    Some("1969-12-31 19:00:00"),
  )
  @env.set_env_var("TZ", "Europe/Berlin")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd HH:mm:ss", Europe/Berlin)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd HH:mm:ss"),
    Some("1970-01-01 01:00:00"),
  )
  @env.set_env_var("TZ", "GMT0")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd HH:mm:ss", GMT0)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd HH:mm:ss"),
    Some("1970-01-01 00:00:00"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd HH:mm:ss", Pacific/Chatham)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd HH:mm:ss"),
    Some("1970-01-01 12:45:00"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd HH:mm:ss", UTC)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd HH:mm:ss"),
    Some("1970-01-01 00:00:00"),
  )
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Africa/Monrovia)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1969-12-31T23:16:00.000"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", America/New_York)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1969-12-31T19:00:00.000"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Asia/Kathmandu)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1970-01-01T05:30:00.000"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Asia/Shanghai)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1970-01-01T08:00:00.000"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1970-01-01T10:00:00.000"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Etc/GMT+5)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1969-12-31T19:00:00.000"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Pacific/Chatham)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1970-01-01T12:45:00.000"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", UTC)
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1970-01-01T00:00:00.000"),
  )
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", Africa/Monrovia)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-03-10 06:30:00"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", America/New_York)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-03-10 01:30:00"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", Asia/Kathmandu)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-03-10 12:15:00"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", Asia/Shanghai)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-03-10 14:30:00"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-03-10 17:30:00"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", Etc/GMT+5)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-03-10 01:30:00"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", Pacific/Chatham)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-03-10 20:15:00"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", UTC)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-03-10 06:30:00"),
  )
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Africa/Monrovia)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-03-10T06:30:00.000"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", America/New_York)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-03-10T01:30:00.000"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Asia/Kathmandu)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-03-10T12:15:00.000"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Asia/Shanghai)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-03-10T14:30:00.000"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-03-10T17:30:00.000"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Etc/GMT+5)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-03-10T01:30:00.000"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Pacific/Chatham)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-03-10T20:15:00.000"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", UTC)
  assert_eq(
    @date.format_local(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-03-10T06:30:00.000"),
  )
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", Africa/Monrovia)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-11-03 06:00:00"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", America/New_York)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-11-03 01:00:00"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", Asia/Kathmandu)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-11-03 11:45:00"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", Asia/Shanghai)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-11-03 14:00:00"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-11-03 17:00:00"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", Etc/GMT+5)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-11-03 01:00:00"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", Pacific/Chatham)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-11-03 19:45:00"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", UTC)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2024-11-03 06:00:00"),
  )
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Africa/Monrovia)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-11-03T06:00:00.000"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", America/New_York)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-11-03T01:00:00.000"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Asia/Kathmandu)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-11-03T11:45:00.000"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Asia/Shanghai)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-11-03T14:00:00.000"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-11-03T17:00:00.000"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Etc/GMT+5)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-11-03T01:00:00.000"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Pacific/Chatham)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-11-03T19:45:00.000"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", UTC)
  assert_eq(
    @date.format_local(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2024-11-03T06:00:00.000"),
  )
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", Africa/Monrovia)
  assert_eq(
    @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2026-10-06 00:00:00"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", America/New_York)
  assert_eq(
    @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2026-10-05 20:00:00"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", Asia/Kathmandu)
  assert_eq(
    @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2026-10-06 05:45:00"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", Asia/Shanghai)
  assert_eq(
    @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2026-10-06 08:00:00"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2026-10-06 11:00:00"),
  )
  @env.set_env_var("TZ", "EST5EDT")
  // 源出 §7 已冻的 format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", EST5EDT)
  assert_eq(
    @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2026-10-05 20:00:00"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", Etc/GMT+5)
  assert_eq(
    @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2026-10-05 19:00:00"),
  )
  @env.set_env_var("TZ", "Europe/Berlin")
  // 源出 §7 已冻的 format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", Europe/Berlin)
  assert_eq(
    @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2026-10-06 02:00:00"),
  )
  @env.set_env_var("TZ", "GMT0")
  // 源出 §7 已冻的 format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", GMT0)
  assert_eq(
    @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2026-10-06 00:00:00"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", Pacific/Chatham)
  assert_eq(
    @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2026-10-06 13:45:00"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", UTC)
  assert_eq(
    @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2026-10-06 00:00:00"),
  )
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", Africa/Monrovia)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2049-12-31 23:59:58"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", America/New_York)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2049-12-31 18:59:58"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", Asia/Kathmandu)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2050-01-01 05:44:58"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", Asia/Shanghai)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2050-01-01 07:59:58"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2050-01-01 10:59:58"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", Etc/GMT+5)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2049-12-31 18:59:58"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", Pacific/Chatham)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2050-01-01 13:44:58"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", UTC)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2049-12-31 23:59:58"),
  )
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Africa/Monrovia)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2049-12-31T23:59:58.000"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", America/New_York)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2049-12-31T18:59:58.000"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Asia/Kathmandu)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2050-01-01T05:44:58.000"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Asia/Shanghai)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2050-01-01T07:59:58.000"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2050-01-01T10:59:58.000"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Etc/GMT+5)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2049-12-31T18:59:58.000"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Pacific/Chatham)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2050-01-01T13:44:58.000"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", UTC)
  assert_eq(
    @date.format_local(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2049-12-31T23:59:58.000"),
  )
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", Africa/Monrovia)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd HH:mm:ss"),
    Some("1986-05-04 02:00:00"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", America/New_York)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd HH:mm:ss"),
    Some("1986-05-03 22:00:00"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", Asia/Kathmandu)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd HH:mm:ss"),
    Some("1986-05-04 07:45:00"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", Asia/Shanghai)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd HH:mm:ss"),
    Some("1986-05-04 11:00:00"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd HH:mm:ss"),
    Some("1986-05-04 12:30:00"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", Etc/GMT+5)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd HH:mm:ss"),
    Some("1986-05-03 21:00:00"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", Pacific/Chatham)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd HH:mm:ss"),
    Some("1986-05-04 14:45:00"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", UTC)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd HH:mm:ss"),
    Some("1986-05-04 02:00:00"),
  )
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Africa/Monrovia)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1986-05-04T02:00:00.000"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", America/New_York)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1986-05-03T22:00:00.000"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Asia/Kathmandu)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1986-05-04T07:45:00.000"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Asia/Shanghai)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1986-05-04T11:00:00.000"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1986-05-04T12:30:00.000"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Etc/GMT+5)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1986-05-03T21:00:00.000"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Pacific/Chatham)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1986-05-04T14:45:00.000"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", UTC)
  assert_eq(
    @date.format_local(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("1986-05-04T02:00:00.000"),
  )
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", Africa/Monrovia)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2000-06-15 12:00:00"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", America/New_York)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2000-06-15 08:00:00"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", Asia/Kathmandu)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2000-06-15 17:45:00"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", Asia/Shanghai)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2000-06-15 20:00:00"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2000-06-15 22:30:00"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", Etc/GMT+5)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2000-06-15 07:00:00"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", Pacific/Chatham)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2000-06-16 00:45:00"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", UTC)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd HH:mm:ss"),
    Some("2000-06-15 12:00:00"),
  )
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Africa/Monrovia)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2000-06-15T12:00:00.000"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", America/New_York)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2000-06-15T08:00:00.000"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Asia/Kathmandu)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2000-06-15T17:45:00.000"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Asia/Shanghai)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2000-06-15T20:00:00.000"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Australia/Lord_Howe)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2000-06-15T22:30:00.000"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Etc/GMT+5)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2000-06-15T07:00:00.000"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", Pacific/Chatham)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2000-06-16T00:45:00.000"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", UTC)
  assert_eq(
    @date.format_local(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS"),
    Some("2000-06-15T12:00:00.000"),
  )
}

///|
test "@date 成对判别：同一瞬间不同默认区必给不同串（本块 25 条）" {
  @date.reset_default_zone()
  // 本库自订判据：默认区换了，同一瞬间的读数必须跟着换（25 对）
  @env.set_env_var("TZ", "Asia/Shanghai")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "UTC")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Asia/Shanghai")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Etc/GMT+5")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Asia/Shanghai")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Europe/Berlin")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Asia/Shanghai")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "America/New_York")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Asia/Shanghai")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Asia/Kathmandu")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Asia/Shanghai")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Pacific/Chatham")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Asia/Shanghai")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Asia/Shanghai")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "EST5EDT")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Asia/Shanghai")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "GMT0")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Asia/Shanghai")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Africa/Monrovia")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "UTC")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Etc/GMT+5")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "UTC")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Europe/Berlin")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "UTC")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "America/New_York")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "UTC")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Asia/Kathmandu")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "UTC")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Pacific/Chatham")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "UTC")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "UTC")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "EST5EDT")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Etc/GMT+5")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Europe/Berlin")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Etc/GMT+5")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "America/New_York")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Etc/GMT+5")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Asia/Kathmandu")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Etc/GMT+5")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Pacific/Chatham")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Etc/GMT+5")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Etc/GMT+5")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "EST5EDT")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Etc/GMT+5")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "GMT0")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
  @env.set_env_var("TZ", "Etc/GMT+5")
  let dflt_x = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  @env.set_env_var("TZ", "Africa/Monrovia")
  let dflt_y = @date.format_local(1791244800000L, "yyyy-MM-dd HH:mm:ss")
  assert_true(dflt_x != dflt_y)
}

///|
test "@date to_rfc3339_local 的读数等于 §7 已冻的 to_rfc3339_in（本块 17 条）" {
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 to_rfc3339_in(0L, Africa/Monrovia)
  assert_eq(@date.to_rfc3339_local(0L), Some("1969-12-31T23:16:00-00:44"))
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 to_rfc3339_in(0L, America/New_York)
  assert_eq(@date.to_rfc3339_local(0L), Some("1969-12-31T19:00:00-05:00"))
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 to_rfc3339_in(0L, Asia/Kathmandu)
  assert_eq(@date.to_rfc3339_local(0L), Some("1970-01-01T05:30:00+05:30"))
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 to_rfc3339_in(0L, Asia/Shanghai)
  assert_eq(@date.to_rfc3339_local(0L), Some("1970-01-01T08:00:00+08:00"))
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 to_rfc3339_in(0L, Australia/Lord_Howe)
  assert_eq(@date.to_rfc3339_local(0L), Some("1970-01-01T10:00:00+10:00"))
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 to_rfc3339_in(0L, Etc/GMT+5)
  assert_eq(@date.to_rfc3339_local(0L), Some("1969-12-31T19:00:00-05:00"))
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 to_rfc3339_in(0L, Pacific/Chatham)
  assert_eq(@date.to_rfc3339_local(0L), Some("1970-01-01T12:45:00+12:45"))
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 to_rfc3339_in(0L, UTC)
  assert_eq(@date.to_rfc3339_local(0L), Some("1970-01-01T00:00:00Z"))
  @env.set_env_var("TZ", "Africa/Monrovia")
  // 源出 §7 已冻的 to_rfc3339_in(1791244800000L, Africa/Monrovia)
  assert_eq(
    @date.to_rfc3339_local(1791244800000L),
    Some("2026-10-06T00:00:00Z"),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 to_rfc3339_in(1791244800000L, America/New_York)
  assert_eq(
    @date.to_rfc3339_local(1791244800000L),
    Some("2026-10-05T20:00:00-04:00"),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 to_rfc3339_in(1791244800000L, Asia/Kathmandu)
  assert_eq(
    @date.to_rfc3339_local(1791244800000L),
    Some("2026-10-06T05:45:00+05:45"),
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 to_rfc3339_in(1791244800000L, Asia/Shanghai)
  assert_eq(
    @date.to_rfc3339_local(1791244800000L),
    Some("2026-10-06T08:00:00+08:00"),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 to_rfc3339_in(1791244800000L, Australia/Lord_Howe)
  assert_eq(
    @date.to_rfc3339_local(1791244800000L),
    Some("2026-10-06T11:00:00+11:00"),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 to_rfc3339_in(1791244800000L, Etc/GMT+5)
  assert_eq(
    @date.to_rfc3339_local(1791244800000L),
    Some("2026-10-05T19:00:00-05:00"),
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 to_rfc3339_in(1791244800000L, Pacific/Chatham)
  assert_eq(
    @date.to_rfc3339_local(1791244800000L),
    Some("2026-10-06T13:45:00+13:45"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 to_rfc3339_in(1791244800000L, UTC)
  assert_eq(
    @date.to_rfc3339_local(1791244800000L),
    Some("2026-10-06T00:00:00Z"),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 to_rfc3339_in(2524608000000L, UTC)
  assert_eq(@date.to_rfc3339_local(2524608000000L), None)
}

///|
test "@date parse_local 的瞬间读数等于 §7 已冻的 parse_in（含重叠末支与窗外 None）（本块 8 条）" {
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 parse_in("1969-12-31 23:59:59", UTC)
  assert_eq(
    @date.parse_local("1969-12-31 23:59:59", "yyyy-MM-dd HH:mm:ss"),
    None,
  )
  @env.set_env_var("TZ", "Pacific/Chatham")
  // 源出 §7 已冻的 parse_in("2024-04-07 00:15:00", Pacific/Chatham)
  assert_eq(
    @date.parse_local("2024-04-07 00:15:00", "yyyy-MM-dd HH:mm:ss"),
    Some(1712399400000L),
  )
  @env.set_env_var("TZ", "Australia/Lord_Howe")
  // 源出 §7 已冻的 parse_in("2024-04-07 02:30:00", Australia/Lord_Howe)
  assert_eq(
    @date.parse_local("2024-04-07 02:30:00", "yyyy-MM-dd HH:mm:ss"),
    Some(1712419200000L),
  )
  @env.set_env_var("TZ", "Asia/Kathmandu")
  // 源出 §7 已冻的 parse_in("2024-06-01 12:00:00", Asia/Kathmandu)
  assert_eq(
    @date.parse_local("2024-06-01 12:00:00", "yyyy-MM-dd HH:mm:ss"),
    Some(1717222500000L),
  )
  @env.set_env_var("TZ", "Etc/GMT+5")
  // 源出 §7 已冻的 parse_in("2024-06-01 12:00:00", Etc/GMT+5)
  assert_eq(
    @date.parse_local("2024-06-01 12:00:00", "yyyy-MM-dd HH:mm:ss"),
    Some(1717261200000L),
  )
  @env.set_env_var("TZ", "UTC")
  // 源出 §7 已冻的 parse_in("2024-06-01 12:00:00", UTC)
  assert_eq(
    @date.parse_local("2024-06-01 12:00:00", "yyyy-MM-dd HH:mm:ss"),
    Some(1717243200000L),
  )
  @env.set_env_var("TZ", "Europe/London")
  // 源出 §7 已冻的 parse_in("2024-10-27 01:30:00", Europe/London)
  assert_eq(
    @date.parse_local("2024-10-27 01:30:00", "yyyy-MM-dd HH:mm:ss"),
    Some(1729992600000L),
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 parse_in("2024-11-03 01:30:00", America/New_York)
  assert_eq(
    @date.parse_local("2024-11-03 01:30:00", "yyyy-MM-dd HH:mm:ss"),
    Some(1730615400000L),
  )
}

///|
test "@date parse_local 在空洞档仍 raise ZoneGap（本块 3 条）" {
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 ZoneGap 档（腿 S 行参照主动抛）：Asia/Shanghai
  assert_eq(
    shape(() => @date.parse_local("1986-05-04 02:00:00", "yyyy-MM-dd HH:mm:ss")),
    "ZoneGap 1986-05-04T02:00:00.000",
  )
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 源出 §7 已冻的 ZoneGap 档（腿 S 行参照主动抛）：Asia/Shanghai
  assert_eq(
    shape(() => @date.parse_local("1986-05-04 02:30:00", "yyyy-MM-dd HH:mm:ss")),
    "ZoneGap 1986-05-04T02:30:00.000",
  )
  @env.set_env_var("TZ", "America/New_York")
  // 源出 §7 已冻的 ZoneGap 档（腿 S 行参照主动抛）：America/New_York
  assert_eq(
    shape(() => @date.parse_local("2024-03-10 02:30:00", "yyyy-MM-dd HH:mm:ss")),
    "ZoneGap 2024-03-10T02:30:00.000",
  )
}

///|
test "@date default_zone 恒在表内：三种状态各钉一次（本块 4 条）" {
  @date.reset_default_zone()
  @env.unset_env_var("TZ")
  assert_true(@date.zone_exists(@date.default_zone()))
  @env.set_env_var("TZ", "No/Where")
  assert_true(@date.zone_exists(@date.default_zone()))
  @env.set_env_var("TZ", "Pacific/Chatham")
  assert_true(@date.zone_exists(@date.default_zone()))
  let _ = @date.set_default_zone("Australia/Lord_Howe")
  assert_true(@date.zone_exists(@date.default_zone()))
  // 这条不变式是便捷件不会因为区名给 None 的全部依据（spec §8.2 第 3 行）
}

///|
test "@date now_local/today_local 与假钟等价式 + 形状下界（本块 17 条）" {
  @date.reset_default_zone()
  @env.set_env_var("TZ", "Asia/Shanghai")
  // 与注入假钟那条已冻等价式同形：now_at(zone, clock_fixed(ms)) ≡ datetime_in(zone, ms)
  assert_eq(
    dflt_dt(@date.now_at(@date.default_zone(), @date.clock_fixed(0L))),
    dflt_dt(@date.datetime_in(@date.default_zone(), 0L)),
  )
  assert_eq(
    dflt_d(
      @date.today_at(@date.default_zone(), @date.clock_fixed(1791244800000L)),
    ),
    dflt_d(@date.date_of(@date.default_zone(), 1791244800000L)),
  )
  assert_eq(
    dflt_dt(
      @date.now_at(@date.default_zone(), @date.clock_fixed(1791244800000L)),
    ),
    dflt_dt(@date.datetime_in(@date.default_zone(), 1791244800000L)),
  )
  // 换区之后这条等价式仍成立（默认区不是常量，两处必须同一个值）
  @env.set_env_var("TZ", "Pacific/Chatham")
  assert_eq(
    dflt_dt(
      @date.now_at(@date.default_zone(), @date.clock_fixed(1791244800000L)),
    ),
    dflt_dt(@date.datetime_in(@date.default_zone(), 1791244800000L)),
  )
  // 真钟那一族只断形状与下界——断两次读数的大小关系是计时依赖，慢机器会假红（§5.5 同纪律）
  assert_true(@date.now_local() is Some(_))
  assert_true(@date.today_local() is Some(_))
  let dflt_now = match @date.now_local() {
    None => abort("窗口内必有值")
    Some(v) => v
  }
  assert_true(dflt_now.date.year >= 2020)
  assert_true(dflt_now.hour >= 0 && dflt_now.hour <= 23)
  assert_true(dflt_now.minute >= 0 && dflt_now.minute <= 59)
  assert_true(dflt_now.second >= 0 && dflt_now.second <= 59)
  assert_true(dflt_now.milli >= 0 && dflt_now.milli <= 999)
  let dflt_today = match @date.today_local() {
    None => abort("窗口内必有值")
    Some(v) => v
  }
  assert_true(dflt_today.month >= 1 && dflt_today.month <= 12)
  assert_true(dflt_today.day >= 1 && dflt_today.day <= 31)
  // 两次读钟之间可以跨日界，但不可能跨出 1 天之外——这条挡的是"今天返回了个别的年份"
  assert_true(dflt_now.date.days_between(dflt_today).abs() <= 1)
  // 区名有效 ⇒ 便捷件不该因为区名给 None（§8.2 第 3 行的不变式落到出口上）
  assert_eq(@date.to_rfc3339_local(0L), Some("1970-01-01T08:00:00+08:00"))
  assert_eq(
    @date.format_local(0L, "yyyy-MM-dd HH:mm:ss"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(@date.zone_offset_minutes(@date.default_zone(), 0L), Some(480))
}
