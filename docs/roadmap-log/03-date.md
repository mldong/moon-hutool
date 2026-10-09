# 第 3 节 · `date`（逐包表原行逐字留痕）

来源：`docs/ROADMAP.md` 逐包表第 03 行（`date`）“用例”列的逐字原文。
编号 03 是稳定 ID：与该包契约 `docs/spec/03-…md`、与该行在表里的行号同源同值（第 13 号位是 `mac`，判不做、无详记件），门禁 G13 钉这条不许各漂各的。
状态与条数的真相见该行与 `ROADMAP.md` 末的 READINGS 生成块；索引在 [`../ROADMAP-log.md`](../ROADMAP-log.md)。


````text
| `date` | `DateUtil` / `CalendarUtil` / `DatePattern` / `DateUnit` | **已实现**（**10-08 补档一笔**：RFC 3339 严格腿的位置档 + pattern 引号/重复字段/贪婪数字八块，取值档七条与 JDK 逐条同判；date 未覆盖行 13 → 3，三条剩行全给推导（其中一条带 603 个区的全量探针读数），变异 9 条全抓红零等价——判据与两处被真跑打回的推导写在 spec §9）；第五批 10-07 两笔收口：契约 `dcc6bad` + 落地笔——默认区一层九件 + `ZoneSource` 一个类型，`default_test.mbt` 15 块 305 条冻结期望全部转绿，`moon test --package date` 124 = 绿 124 / 红 0（wasm/js/wasm-gc 三档一致、零警告、既有件签名一字未动、`.mbti` 只前进 26 行），§8.7 十一条变异全部抓红零等价；三级降级 `set_default_zone` → `TZ` → `fallback_zone`，`default_zone_source()` 把参照那个查不到来源的进程级全局量做成可查询；动笔前实测三条承重前提（三档都读得到 `TZ`、测试档 `set_env_var` 立即可见、JDK 在 Windows 不跟 `TZ`），并纠掉上一轮我自己一条想当然（`EST5EDT`/`GMT0` 是 IANA legacy 区名、在表内走 env，不是"POSIX 串不收"那一档）。已收口的前四批读数：首批 10-05 的 47 条三档一致；第二批 10-06 两笔 `85143d7` + `e60ee84`，内置 IANA 时区段表 603 区 / **36701 段** + 命名时区入口七件，31 块转绿、Z1–Z8 八条变异全部抓红零等价，落地轮修腿把 `getTransitions()` 漏掉的规则驱动那些年补回来，段数 18713 ⇒ 36701；第三批 10-06 可注入时钟源五件（`clock_system` / `clock_fixed` / `date_of` / `now_at` / `today_at`）两笔收口 `c984f49` + `cbbc9f9`，13 块转绿、C1–C7 五条抓红两条等价各给推导；第四批 10-06 命名时区版 format/parse 三件 + `ZoneGap` 一个错误变体，两笔收口 `fceabad` + 落地笔，12 块转绿、D1–D8 八条变异全部抓红零等价；本包偏移承诺到**整分钟**，窗口内非整分钟只有 `Africa/Monrovia` 一区两年，已作显式分岔两栏并读 | `docs/spec/03-date.md` | 47 条（31 断言块 + 16 文档块），全绿；core **无任何 time 包**，本库最大"从无到有"块（整包自研：偏移显式传、无 tzdb/DST、proleptic Gregorian + 天文纪年） |
````
