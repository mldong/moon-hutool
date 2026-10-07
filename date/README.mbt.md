# date

hutool `DateUtil` / `CalendarUtil` / `DatePattern` / `DateUnit` 的 MoonBit 对位：公历日期与墙上时刻的换算、日历派生量（星期/周/季/月末）、封闭子集的格式化与解析、RFC 3339、时间差与周岁。

MoonBit 的 `moonbitlang/core` **没有任何时间能力**（没有 `time`/`date`/`calendar` 包；全树 `grep ZonedDateTime|weekday|leap_year` 在非测试代码命中 0），所以本包整包自研，唯一能借的 OS 窗口是 `env.now()`。完整边界矩阵与逐条读数来源见 [`docs/spec/03-date.md`](https://github.com/mldong/moon-hutool/blob/master/docs/spec/03-date.md)。

> 状态：**五批都已收口**（首批 10-05；第二批 内置 IANA 时区段表 + 命名时区入口七件；第三批 可注入时钟源；第四批 命名时区版 format/parse 见 spec §7；第五批 默认区与无参便捷入口见 spec §8）——本文件的文档块覆盖首批与第五批；第二/三/四批的用例面只在各批自己的 `*_test.mbt`，本文件没写它们的示例。

## 两条先决口径

**一、没有宿主时区可探测，所以偏移要么显式传、要么走默认区那一层。** `DateTime` 是**墙上时钟**（读表结果），本身不带偏移；同一瞬间在 `+00:00` 与 `+08:00` 下是两个不同的 `DateTime`。参照靠进程默认时区（`TimeZone.getDefault()`），而 `moonbitlang/core` **没有任何时间/时区能力**（全树 grep `timezone|utc_offset|localtime` 在非测试代码命中 0，`@env` 也没有"取宿主偏移"的出口），参照那个隐式全局量在这里没有对应物——宿主只能给区名（`TZ`），给不了偏移。
第二批之后本库自带一张 IANA 段表，所以**命名时区与 DST 都做**（`now_in(zone)` / `format_in(ms, pattern, zone)` / `zone_offsets_at_wall`，见 spec §5 与 §7）；第五批补的是"不必每次传"的默认区一层（`TZ` 环境变量优先、否则取兜底常量，`default_zone_source()` 可查来源，见 spec §8）。**先写这段时那句"不做命名时区、也因此不做 DST"是过期承诺，10-07 就地删改**。

**二、proleptic Gregorian + 天文纪年。** 1582-10-15 之前照公历规则往前算，并且存在公元 0 年（`= 公元前 1 年`）。JDK `GregorianCalendar` 有 1582 切换点，本库没有。

`Date`/`DateTime` 的构造入口只有 `of`、`from_epoch_days`、`from_epoch_millis`、`parse` 四个，其中 `of`/`parse` 会 `raise`。本文的示例统一用**不 raise 的入口**（`from_epoch_days`/`from_epoch_millis`）摆夹具，需要展示错误形状的地方才写 `try/catch`。

## 瞬间 ↔ 墙上时钟

```mbt check
///|
test "显式偏移下的两个读数" {
  assert_eq(
    @date.DateTime::from_epoch_millis(1791117296789L, 0).to_iso_string(),
    "2026-10-04T12:34:56.789",
  )
  assert_eq(
    @date.DateTime::from_epoch_millis(1791117296789L, 480).to_iso_string(),
    "2026-10-04T20:34:56.789",
  )
  // 反向：同一个墙上时刻（20:34:56.789），当成 +08:00 读到的比当成 UTC 读到的早 8 小时
  let x = @date.DateTime::from_epoch_millis(1791117296789L, 480)
  assert_eq(x.to_epoch_millis(480), 1791117296789L)
  assert_eq(x.to_epoch_millis(0), 1791146096789L)
}
```

**负 epoch 向下取整**：MoonBit 的 `/` 与 `%` 对负数**向零截断**，而 Unix 时间要求 `-1` 毫秒落在 1969-12-31 的末尾。这一档最容易写错，所以直接写进文档：

```mbt check
///|
test "1970 之前" {
  assert_eq(
    @date.DateTime::from_epoch_millis(-1L, 0).to_iso_string(),
    "1969-12-31T23:59:59.999",
  )
  assert_eq(
    @date.DateTime::from_epoch_millis(-86400000L, 0).to_iso_string(),
    "1969-12-31T00:00:00.000",
  )
  assert_eq(
    @date.DateTime::from_epoch_millis(0L, -450).to_iso_string(),
    "1969-12-31T16:30:00.000",
  )
}
```

## 日期构造闸门与日历派生量

`Date::of` 是构造闸门：2 月 30 日不会被"滚"成 3 月 1 日（JDK `Calendar` 的 lenient 模式会滚，本库不滚），而是带着读数 `raise`。

```mbt check
///|
test "非法日期到不了下一步" {
  let got = try {
    let _ = @date.Date::of(2026, 2, 30)
    "居然构造成功了"
  } catch {
    @date.DayOutOfRange(y, m, d) => "\{y}-\{m}-\{d} 不存在"
    _ => "错种"
  }
  assert_eq(got, "2026-2-30 不存在")
  assert_eq(@date.Date::from_epoch_days(20730L).to_iso_string(), "2026-10-04")
}
```

星期与周序号取 **ISO 8601**：周一是 1，含该年第一个周四的那周是第 1 周。`week_of_year` 必须与 `week_based_year` 配对读，否则跨年那一周会归错年。

```mbt check
///|
test "ISO 档" {
  let sunday = @date.Date::from_epoch_days(20730L)
  let monday = @date.Date::from_epoch_days(20731L)
  assert_eq(sunday.weekday(), 7)
  assert_eq(monday.weekday(), 1)
  assert_eq(sunday.is_weekend(), true)
  assert_eq(monday.is_weekend(), false)
  assert_eq(sunday.day_of_year(), 277)
  assert_eq(sunday.quarter(), 4)
}
```

```mbt check
///|
test "跨年那一周归上一年" {
  let d = @date.Date::from_epoch_days(18628L) // 2021-01-01
  assert_eq(d.to_iso_string(), "2021-01-01")
  assert_eq(d.weekday(), 5)
  assert_eq(d.week_of_year(), 53)
  assert_eq(d.week_based_year(), 2020)
}
```

## 区间端点与加减

`end_of_*` 在毫秒档封顶 `.999`（本库最细就是毫秒）。月/年加减**夹紧到月末**，不滚到下个月——这是 hutool `offsetMonth` 的档位，也是业务最不容易出错的一档。

```mbt check
///|
test "端点" {
  // 1791117296789 在 +08:00 下读表 = 2026-10-04T20:34:56.789（周日）
  let x = @date.DateTime::from_epoch_millis(1791117296789L, 480)
  assert_eq(x.begin_of_day().to_iso_string(), "2026-10-04T00:00:00.000")
  assert_eq(x.end_of_day().to_iso_string(), "2026-10-04T23:59:59.999")
  assert_eq(x.begin_of_week().to_iso_string(), "2026-09-28T00:00:00.000")
  assert_eq(x.begin_of_month().to_iso_string(), "2026-10-01T00:00:00.000")
  assert_eq(x.end_of_month().to_iso_string(), "2026-10-31T23:59:59.999")
  assert_eq(x.end_of_quarter().to_iso_string(), "2026-12-31T23:59:59.999")
}
```

```mbt check
///|
test "月末夹紧" {
  assert_eq(
    @date.Date::from_epoch_days(19753L).add_months(1).to_iso_string(), // 2024-01-31
    "2024-02-29",
  )
  assert_eq(
    @date.Date::from_epoch_days(19388L).add_months(1).to_iso_string(), // 2023-01-31
    "2023-02-28",
  )
  assert_eq(
    @date.Date::from_epoch_days(19753L).add_months(-1).to_iso_string(),
    "2023-12-31",
  )
  assert_eq(
    @date.Date::from_epoch_days(20730L).add_days(1).to_iso_string(),
    "2026-10-05",
  )
  assert_eq(
    @date.Date::from_epoch_days(19782L).add_years(1).to_iso_string(), // 2024-02-29
    "2025-02-28",
  )
}
```

## 格式化与解析：封闭 pattern 子集

只认 `yyyy yy MM M dd d HH H hh h mm m ss s SSS` 与单引号转义。表外的字母**显式报错**，不做"不认识就当字面量"的宽容——那会把 `EEEE` 这种拼写错误变成静默的错误输出。

```mbt check
///|
test "子集内的读数" {
  // 1767604023045 = UTC 墙上 2026-01-05T09:07:03.045
  let x = @date.DateTime::from_epoch_millis(1767604023045L, 0)
  let show : (String) -> String = s => {
    x.format(s) catch {
      _ => abort("夹具 pattern 必须合法")
    }
  }
  assert_eq(show("yyyy-MM-dd HH:mm:ss"), "2026-01-05 09:07:03")
  assert_eq(show("yyyy-MM-dd HH:mm:ss.SSS"), "2026-01-05 09:07:03.045")
  assert_eq(show("yyyyMMddHHmmss"), "20260105090703")
  assert_eq(show("yy-M-d H:m:s"), "26-1-5 9:7:3")
  assert_eq(show("'<'yyyy'>'MM"), "<2026>01")
  assert_eq(show("yyyy年MM月dd日"), "2026年01月05日")
  assert_eq(show("hh:mm"), "09:07")
}
```

12 小时制**只在输出侧**支持：没有 AM/PM 档时 `hh` 不可逆，所以解析遇到 `hh`/`h` 判 `UnknownPatternToken`。同理，`Date` 没有时分秒，给它时间占位串也报错，而不是编造 `00:00:00`。

```mbt check
///|
test "表外占位串与不对称的两档" {
  let x = @date.DateTime::from_epoch_millis(0L, 0)
  let got = try {
    let _ = x.format("yyyy-MM-dd EEEE")
    "没有报错"
  } catch {
    @date.UnknownPatternToken(t) => "UnknownPatternToken \{t}"
    _ => "错种"
  }
  assert_eq(got, "UnknownPatternToken EEEE")
  let d = @date.Date::from_epoch_days(20730L)
  assert_eq(
    try {
      let _ = d.format("yyyy-MM-dd HH:mm:ss")
      "没有报错"
    } catch {
      @date.UnknownPatternToken(t) => "UnknownPatternToken \{t}"
      _ => "错种"
    },
    "UnknownPatternToken HH",
  )
  assert_eq(
    try {
      let _ = @date.DateTime::parse("2026-10-04 09:07", "yyyy-MM-dd hh:mm")
      "没有报错"
    } catch {
      @date.UnknownPatternToken(t) => "UnknownPatternToken \{t}"
      _ => "错种"
    },
    "UnknownPatternToken hh",
  )
}
```

宽度规则一次定死：`yyyy` 恰好 4 位（可带前导 `-`），`yy`/`MM`/`dd`/`HH`/`hh`/`mm`/`ss` 恰好 2 位，`M`/`d`/`H`/`h`/`m`/`s` 允许 1~2 位，`SSS` 恰好 3 位。缺字段按最小合法值补（年 0、月 1、日 1、时分秒毫 0）。

```mbt check
///|
test "宽度不对就是不对" {
  let got = try {
    let _ = @date.Date::parse("2026-1-4", "yyyy-MM-dd")
    "居然解析成功了"
  } catch {
    @date.ParseFailed(_, at) => "在第 \{at} 个码元处断掉"
    _ => "错种"
  }
  assert_eq(got, "在第 5 个码元处断掉")
  assert_eq(
    @date.Date::parse("2026-1-5", "yyyy-M-d").to_iso_string(),
    "2026-01-05",
  )
  // 两位年：窗口 [1970, 2069]
  assert_eq(
    @date.Date::parse("69-01-01", "yy-MM-dd").to_iso_string(),
    "2069-01-01",
  )
  assert_eq(
    @date.Date::parse("99-12-31", "yy-MM-dd").to_iso_string(),
    "1999-12-31",
  )
}
```

`Date` 与 `DateTime` 共用同一个解析器：`Date::parse` 允许 pattern 里带时间占位串——读出来再丢弃，这是"从更宽的输入里取日期"；`Date::format` 则不允许（它没有那份数据）。

```mbt check
///|
test "取日期可以带时间" {
  let got = @date.Date::parse("2026-10-04 12:34:56", "yyyy-MM-dd HH:mm:ss").to_iso_string() catch {
    _ => abort("夹具不该解析失败")
  }
  assert_eq(got, "2026-10-04")
}
```

## RFC 3339

偏移 0 出 `Z`，其余出 `+HH:MM`；毫秒为 0 时省略小数秒，非 0 时出 3 位。解析侧接受 `T`/`t`、`Z`/`z`（RFC 3339 §5 判大小写不敏感），小数秒**多于 3 位截断**、少于 3 位按十进制补（`.52` = 520 毫秒）；缺偏移量报错（不"当本地时间猜"）；闰秒 `:60` 不支持。

```mbt check
///|
test "输出" {
  assert_eq(@date.to_rfc3339(0L, 0), "1970-01-01T00:00:00Z")
  assert_eq(@date.to_rfc3339(0L, 480), "1970-01-01T08:00:00+08:00")
  assert_eq(@date.to_rfc3339(482196050520L, 0), "1985-04-12T23:20:50.520Z")
  assert_eq(@date.to_rfc3339(-1L, 0), "1969-12-31T23:59:59.999Z")
  assert_eq(
    @date.to_rfc3339(482196050520L, -450),
    "1985-04-12T15:50:50.520-07:30",
  )
}
```

```mbt check
///|
test "输入（RFC 3339 §5.6 正文里的示例串）" {
  let p : (String) -> Int64 = s => {
    @date.from_rfc3339(s) catch {
      _ => abort("规范示例串必须可解析：\{s}")
    }
  }
  assert_eq(p("1985-04-12T23:20:50.52Z"), 482196050520L)
  assert_eq(p("1937-01-01T12:00:27.87+00:20"), -1041337172130L)
  assert_eq(p("1985-04-12t23:20:50.52z"), 482196050520L)
  assert_eq(p("1985-04-12T23:20:50.5235Z"), 482196050523L)
}
```

## 时间差与周岁

`TimeUnit` **刻意没有月/年**：它们长度不固定，一旦能换算成毫秒就等于承诺"1 个月 = N 毫秒"。月/年走 `add_months`/`add_years`。

```mbt check
///|
test "between 取绝对值，difference 带符号" {
  let a = @date.DateTime::from_epoch_millis(1709161200000L, 0) // 2024-02-28T23:00
  let b = @date.DateTime::from_epoch_millis(1709256600000L, 0) // 2024-03-01T01:30（闰年 2 月 29 日在中间）
  assert_eq(@date.Hour.to_millis(), 3600000L)
  assert_eq(@date.Week.to_millis(), 604800000L)
  assert_eq(@date.between(a, b, @date.Hour), 26L) // 26.5 小时，截断
  assert_eq(@date.between(b, a, @date.Hour), 26L)
  assert_eq(@date.difference(a, b, @date.Hour), 26L)
  assert_eq(@date.difference(b, a, @date.Hour), -26L)
  assert_eq(@date.between(a, b, @date.Day), 1L)
  assert_eq(@date.between(a, b, @date.Week), 0L)
}
```

```mbt check
///|
test "周岁：2 月 29 日出生者在平年 2 月 28 日还没过完生日" {
  let b = @date.Date::from_epoch_days(11016L) // 2000-02-29
  let age : (Int64) -> Int = on => {
    @date.age(b, @date.Date::from_epoch_days(on)) catch {
      _ => abort("夹具不该触发 FutureBirth")
    }
  }
  assert_eq(age(19781L), 23) // 2024-02-28
  assert_eq(age(19782L), 24) // 2024-02-29
}
```

`age` 在参照日早于出生日时**报错而不是返回负数**——负数年龄是没有的东西，猜一个只会把脏数据带到下游。

## 时钟入口

`now_millis()` 是全库**唯一**读时钟的地方（OS 能力只走 `env.now`），其余函数都吃显式传入的值——这让上面所有期望值不依赖墙上时钟，也就不会在慢机器上偶发假红。

```mbt check
///|
test "只做单调下界断言" {
  assert_true(@date.now_millis() > 1700000000000L)
  let ms = @date.now_millis()
  assert_eq(@date.DateTime::from_epoch_millis(ms, 480).to_epoch_millis(480), ms)
}
```

## 默认区：不想每次传区名的一档

`now_in(zone)` / `format_in(ms, pattern, zone)` 那批显式件一字未动；这一层只解决"我这个进程就固定用某个区"。
三级降级：**显式覆盖 → 环境变量 `TZ` → `fallback_zone`**，而 `default_zone_source()` 能问出这一次到底来自哪一级——
参照那边 `TimeZone.getDefault()` 是个查不到来源的进程级全局量，本库把它做成可查询、可覆盖、可复位。

```mbt check
///|
test "三级降级与它的来源" {
  // 一、谁都没设 ⇒ 兜底值（本库自订，判据见 spec §8.3 第 1 行）
  @date.reset_default_zone()
  @env.unset_env_var("TZ")
  assert_eq(@date.default_zone(), @date.fallback_zone)
  assert_true(@date.default_zone_source() is @date.Fallback)
  // 二、TZ 给了表内区名 ⇒ 跟着走（实测 js/wasm/wasm-gc 三档都读得到环境变量）
  @env.set_env_var("TZ", "Asia/Kathmandu")
  assert_eq(@date.default_zone(), "Asia/Kathmandu")
  assert_true(@date.default_zone_source() is @date.FromEnv)
  // 三、显式覆盖压过 TZ
  assert_true(@date.set_default_zone("Europe/Berlin"))
  assert_eq(@date.default_zone(), "Europe/Berlin")
  assert_true(@date.default_zone_source() is @date.FromOverride)
  @date.reset_default_zone()
  assert_eq(@date.default_zone(), "Asia/Kathmandu")
}
```

**表外的 `TZ` 值不会漏到下游**：参照侧 `TimeZone.getTimeZone(坏名)` 是静默按 GMT 解析成功，本库不跟随——
坏名一律回落兜底值，且来源如实报 `Fallback`。POSIX 规则串（`UTC-8`）与路径式
（`/usr/share/zoneinfo/…`）都在表外，同样回落（不收的理由见 spec §8.3 第 3 行）。

```mbt check
///|
test "坏的环境变量值给兜底值，而不是给个 0 偏移" {
  @date.reset_default_zone()
  for
    bad in [
      "", " ", "asia/shanghai", "UTC-8", "/usr/share/zoneinfo/Asia/Shanghai", "No/Where",
    ] {
    @env.set_env_var("TZ", bad)
    assert_eq(@date.default_zone(), @date.fallback_zone)
    assert_true(@date.default_zone_source() is @date.Fallback)
    // 这条才是要害：偏移仍是 +08:00 的 480，不是参照那个静默的 0
    assert_eq(
      @date.zone_offset_minutes(@date.default_zone(), 1710052200000L),
      Some(480),
    )
  }
  @env.unset_env_var("TZ")
}
```

`default_zone()` **恒为表内区名**，这条不变式就是下面五个便捷件不会因为区名给 `None` 的全部依据
（唯一剩下的失败原因是瞬间落出表的覆盖窗口 `[1970, 2050)`）：

```mbt check
///|
test "五个便捷件都是显式件的薄封装，判据不新增" {
  @date.reset_default_zone()
  @env.set_env_var("TZ", "Asia/Shanghai")
  assert_true(@date.zone_exists(@date.default_zone()))
  let ms = 1791244800000L
  // format_local ≡ format_in(…, default_zone())，串与 §7 已冻读数同值
  assert_eq(
    @date.format_local(ms, "yyyy-MM-dd HH:mm:ss"),
    @date.format_in(ms, "yyyy-MM-dd HH:mm:ss", @date.default_zone()),
  )
  assert_eq(
    @date.format_local(ms, "yyyy-MM-dd HH:mm:ss"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(@date.to_rfc3339_local(ms), Some("2026-10-06T08:00:00+08:00"))
  // parse_local 的空洞档仍 raise ZoneGap，不并成 None（"这个时间不存在" ≠ "这个区名我不认"）
  let gap = try {
    let _ = @date.parse_local("1986-05-04 02:30:00", "yyyy-MM-dd HH:mm:ss")
    "未抛错"
  } catch {
    @date.ZoneGap(w) => "ZoneGap \{w}"
    _ => "错种"
  }
  assert_eq(gap, "ZoneGap 1986-05-04T02:30:00.000")
  // 真钟那一族只断形状与下界；可冻的等价式挂在"毫秒作参数"的那批上（计时依赖不进契约）
  assert_true(@date.now_local() is Some(_))
  // Option[DateTime] 进 assert_eq 要 Debug，本包只给 Eq/Compare ⇒ 落成串再比，失败时两边都看得见
  let show = (v : @date.DateTime) => v.to_iso_string()
  assert_eq(
    @date.now_at(@date.default_zone(), @date.clock_fixed(ms)).map(show),
    @date.datetime_in(@date.default_zone(), ms).map(show),
  )
}
```

业务侧最常见的用法就是"一个进程一个区"，写在启动处即可，其余调用不带区名：

```mbt check
///|
test "启动时设一次，之后到处不带区名" {
  assert_true(@date.set_default_zone("Asia/Shanghai"))
  let d = match @date.today_local() {
    None => abort("表窗内必有值")
    Some(v) => v
  }
  assert_true(d.year >= 2020)
  let now = match @date.now_local() {
    None => abort("表窗内必有值")
    Some(v) => v
  }
  assert_eq(now.to_iso_string().length(), 23)
  @date.reset_default_zone()
}
```

## 这一层不做的事

命名时区与 DST 已由内置表支持（见上，spec §5/§7）；本层仍不做的是：`java.text` 全套 pattern（`EEEE`/`MMM`/`a`/`Z`/`X`/`ww`/`D`）、JDK 的 lenient 滚动语义、闰秒、农历/节气/生肖、调休与法定节假日表、微秒/纳秒精度、RFC 7231 IMF 日期（要英文星期/月名表，随 `EEE`/`MMM` 一起再定）。逐条理由见 [`docs/ROADMAP.md`](https://github.com/mldong/moon-hutool/blob/master/docs/ROADMAP.md) 的「暂不做」「不做」两节。
