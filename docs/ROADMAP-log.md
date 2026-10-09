# ROADMAP 逐包叙事日志 · 索引

每包的整轮判据、踩坑、变异读数原来挤在 `ROADMAP.md` 逐包表的单元格里；10-09 先整段搬进单一日志文件，
同日再**按包拆成一包一件**（那件已经 64.9 KB，还贴着“能渲染”的边界晃）。
拆的真实理由不是体积，是**逐包表要能一眼扫、每包的留痕要能单独打开、也不许一件养到没人愿意读**。

- **编号是稳定 ID**：每件的文件号 = 该包在逐包表里的行号 = 它的契约文件号（`docs/spec/NN-<pkg>.md`，门禁 G13 钉）。
  所以这里第 13 号位是空的——`mac` 判不做、没有契约也没有详记件。
- **搬整行，不摘要**：每件正文是对应表行“用例”列的逐字原文；拆分工装在写盘前逐行断言原文整行在里面。
- **状态词的真相仍在 `ROADMAP.md` 那一行**：门禁 G11 拿 `moon test --package` 的当场读数比状态词；
  本目录不是门面文档，也不在 G14 的扫描面上。
- **条数不手写**：每包用例条数的唯一真相是 `ROADMAP.md` 末的 READINGS 生成块；
  各件里出现的数字都是当初写进 cell 的历史读数，只作留痕。

| 号 | 包 | 详记 |
|---|---|---|
| 01 | `text` | [`roadmap-log/01-text.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/01-text.md) |
| 02 | `digest` | [`roadmap-log/02-digest.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/02-digest.md) |
| 03 | `date` | [`roadmap-log/03-date.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/03-date.md) |
| 04 | `id` | [`roadmap-log/04-id.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/04-id.md) |
| 05 | `codec` | [`roadmap-log/05-codec.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/05-codec.md) |
| 06 | `coll` | [`roadmap-log/06-coll.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/06-coll.md) |
| 07 | `mapx` | [`roadmap-log/07-mapx.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/07-mapx.md) |
| 08 | `num` | [`roadmap-log/08-num.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/08-num.md) |
| 09 | `conv` | [`roadmap-log/09-conv.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/09-conv.md) |
| 10 | `re` | [`roadmap-log/10-re.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/10-re.md) |
| 11 | `valid` | [`roadmap-log/11-valid.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/11-valid.md) |
| 12 | `rand` | [`roadmap-log/12-rand.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/12-rand.md) |
| 14 | `dfa` | [`roadmap-log/14-dfa.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/14-dfa.md) |
| 15 | `path` | [`roadmap-log/15-path.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/15-path.md) |
| 16 | `cache` | [`roadmap-log/16-cache.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/16-cache.md) |
| 17 | `hash` | [`roadmap-log/17-hash.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/17-hash.md) |
| 18 | `bloom` | [`roadmap-log/18-bloom.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/18-bloom.md) |
| 19 | `cron` | [`roadmap-log/19-cron.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/19-cron.md) |
| 20 | `textsim` | [`roadmap-log/20-textsim.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/20-textsim.md) |
| 21 | `csv` | [`roadmap-log/21-csv.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/21-csv.md) |
| 22 | `ini` | [`roadmap-log/22-ini.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/22-ini.md) |
| 23 | `typex` | [`roadmap-log/23-typex.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/23-typex.md) |
| 24 | `sched` | [`roadmap-log/24-sched.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/24-sched.md) |
| 25 | `cron_expr` | [`roadmap-log/25-cron-expr.md`](https://github.com/mldong/moon-hutool/blob/master/docs/roadmap-log/25-cron-expr.md) |
