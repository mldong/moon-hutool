// 本文件的每一条期望都由 `scripts/gen_batch1_rest.py` 从参照腿 `scripts/UrlPureLeg.java` 的读数灌入，**手打零条**。
// 参照版本 hutool-all 5.8.37；判据口径见 docs/spec/05-codec.md §12 与 01-text.md §1.19。
// 期望值冻结（AGENTS）：改这里任何一条都要单独一笔并给新的腿读数。

///|
test "@codec #12.1 data_uri 组装（腿 D 行；charset 串**原样带过**、数据**不编码**）" {
  assert_eq(
    @codec.data_uri("text/plain", "utf-8", "hello world"),
    "data:text/plain;utf-8,hello world",
  ) // D|getDataUri(3)|text/plain|utf-8|hello world|data:text/plain;utf-8,hello world
  assert_eq(
    @codec.data_uri("text/plain", "utf-8", "a b&c=d"),
    "data:text/plain;utf-8,a b&c=d",
  ) // D|getDataUri(3)|text/plain|utf-8|a b&c=d|data:text/plain;utf-8,a b&c=d
  assert_eq(
    @codec.data_uri("text/plain", "utf-8", "\u{4e2d}\u{6587}"),
    "data:text/plain;utf-8,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|text/plain|utf-8|{u4e2d}{u6587}|data:text/plain;utf-8,{u4e2d}{u6587}
  assert_eq(
    @codec.data_uri("text/plain", "utf-8", ""),
    "data:text/plain;utf-8,",
  ) // D|getDataUri(3)|text/plain|utf-8||data:text/plain;utf-8,
  assert_eq(
    @codec.data_uri("text/plain", "utf-8", "100%"),
    "data:text/plain;utf-8,100%",
  ) // D|getDataUri(3)|text/plain|utf-8|100%|data:text/plain;utf-8,100%
  assert_eq(
    @codec.data_uri("text/plain", "utf-8", "x\u{000a}y"),
    "data:text/plain;utf-8,x\u{000a}y",
  ) // D|getDataUri(3)|text/plain|utf-8|x{u000a}y|data:text/plain;utf-8,x{u000a}y
  assert_eq(
    @codec.data_uri("text/plain", "GBK", "hello world"),
    "data:text/plain;GBK,hello world",
  ) // D|getDataUri(3)|text/plain|GBK|hello world|data:text/plain;GBK,hello world
  assert_eq(
    @codec.data_uri("text/plain", "GBK", "a b&c=d"),
    "data:text/plain;GBK,a b&c=d",
  ) // D|getDataUri(3)|text/plain|GBK|a b&c=d|data:text/plain;GBK,a b&c=d
  assert_eq(
    @codec.data_uri("text/plain", "GBK", "\u{4e2d}\u{6587}"),
    "data:text/plain;GBK,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|text/plain|GBK|{u4e2d}{u6587}|data:text/plain;GBK,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("text/plain", "GBK", ""), "data:text/plain;GBK,") // D|getDataUri(3)|text/plain|GBK||data:text/plain;GBK,
  assert_eq(
    @codec.data_uri("text/plain", "GBK", "100%"),
    "data:text/plain;GBK,100%",
  ) // D|getDataUri(3)|text/plain|GBK|100%|data:text/plain;GBK,100%
  assert_eq(
    @codec.data_uri("text/plain", "GBK", "x\u{000a}y"),
    "data:text/plain;GBK,x\u{000a}y",
  ) // D|getDataUri(3)|text/plain|GBK|x{u000a}y|data:text/plain;GBK,x{u000a}y
  assert_eq(
    @codec.data_uri("text/plain", "gbk", "hello world"),
    "data:text/plain;gbk,hello world",
  ) // D|getDataUri(3)|text/plain|gbk|hello world|data:text/plain;gbk,hello world
  assert_eq(
    @codec.data_uri("text/plain", "gbk", "a b&c=d"),
    "data:text/plain;gbk,a b&c=d",
  ) // D|getDataUri(3)|text/plain|gbk|a b&c=d|data:text/plain;gbk,a b&c=d
  assert_eq(
    @codec.data_uri("text/plain", "gbk", "\u{4e2d}\u{6587}"),
    "data:text/plain;gbk,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|text/plain|gbk|{u4e2d}{u6587}|data:text/plain;gbk,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("text/plain", "gbk", ""), "data:text/plain;gbk,") // D|getDataUri(3)|text/plain|gbk||data:text/plain;gbk,
  assert_eq(
    @codec.data_uri("text/plain", "gbk", "100%"),
    "data:text/plain;gbk,100%",
  ) // D|getDataUri(3)|text/plain|gbk|100%|data:text/plain;gbk,100%
  assert_eq(
    @codec.data_uri("text/plain", "gbk", "x\u{000a}y"),
    "data:text/plain;gbk,x\u{000a}y",
  ) // D|getDataUri(3)|text/plain|gbk|x{u000a}y|data:text/plain;gbk,x{u000a}y
  assert_eq(
    @codec.data_uri("text/plain", "", "hello world"),
    "data:text/plain,hello world",
  ) // D|getDataUri(3)|text/plain||hello world|data:text/plain,hello world
  assert_eq(
    @codec.data_uri("text/plain", "", "a b&c=d"),
    "data:text/plain,a b&c=d",
  ) // D|getDataUri(3)|text/plain||a b&c=d|data:text/plain,a b&c=d
  assert_eq(
    @codec.data_uri("text/plain", "", "\u{4e2d}\u{6587}"),
    "data:text/plain,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|text/plain||{u4e2d}{u6587}|data:text/plain,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("text/plain", "", ""), "data:text/plain,") // D|getDataUri(3)|text/plain|||data:text/plain,
  assert_eq(@codec.data_uri("text/plain", "", "100%"), "data:text/plain,100%") // D|getDataUri(3)|text/plain||100%|data:text/plain,100%
  assert_eq(
    @codec.data_uri("text/plain", "", "x\u{000a}y"),
    "data:text/plain,x\u{000a}y",
  ) // D|getDataUri(3)|text/plain||x{u000a}y|data:text/plain,x{u000a}y
  assert_eq(
    @codec.data_uri("text/plain", "\u{007b}null\u{007d}", "hello world"),
    "data:text/plain,hello world",
  ) // D|getDataUri(3)|text/plain|{null}|hello world|data:text/plain,hello world
  assert_eq(
    @codec.data_uri("text/plain", "\u{007b}null\u{007d}", "a b&c=d"),
    "data:text/plain,a b&c=d",
  ) // D|getDataUri(3)|text/plain|{null}|a b&c=d|data:text/plain,a b&c=d
  assert_eq(
    @codec.data_uri("text/plain", "\u{007b}null\u{007d}", "\u{4e2d}\u{6587}"),
    "data:text/plain,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|text/plain|{null}|{u4e2d}{u6587}|data:text/plain,{u4e2d}{u6587}
  assert_eq(
    @codec.data_uri("text/plain", "\u{007b}null\u{007d}", ""),
    "data:text/plain,",
  ) // D|getDataUri(3)|text/plain|{null}||data:text/plain,
  assert_eq(
    @codec.data_uri("text/plain", "\u{007b}null\u{007d}", "100%"),
    "data:text/plain,100%",
  ) // D|getDataUri(3)|text/plain|{null}|100%|data:text/plain,100%
  assert_eq(
    @codec.data_uri("text/plain", "\u{007b}null\u{007d}", "x\u{000a}y"),
    "data:text/plain,x\u{000a}y",
  ) // D|getDataUri(3)|text/plain|{null}|x{u000a}y|data:text/plain,x{u000a}y
  assert_eq(
    @codec.data_uri("text/plain", "utf-16", "hello world"),
    "data:text/plain;utf-16,hello world",
  ) // D|getDataUri(3)|text/plain|utf-16|hello world|data:text/plain;utf-16,hello world
  assert_eq(
    @codec.data_uri("text/plain", "utf-16", "a b&c=d"),
    "data:text/plain;utf-16,a b&c=d",
  ) // D|getDataUri(3)|text/plain|utf-16|a b&c=d|data:text/plain;utf-16,a b&c=d
  assert_eq(
    @codec.data_uri("text/plain", "utf-16", "\u{4e2d}\u{6587}"),
    "data:text/plain;utf-16,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|text/plain|utf-16|{u4e2d}{u6587}|data:text/plain;utf-16,{u4e2d}{u6587}
  assert_eq(
    @codec.data_uri("text/plain", "utf-16", ""),
    "data:text/plain;utf-16,",
  ) // D|getDataUri(3)|text/plain|utf-16||data:text/plain;utf-16,
  assert_eq(
    @codec.data_uri("text/plain", "utf-16", "100%"),
    "data:text/plain;utf-16,100%",
  ) // D|getDataUri(3)|text/plain|utf-16|100%|data:text/plain;utf-16,100%
  assert_eq(
    @codec.data_uri("text/plain", "utf-16", "x\u{000a}y"),
    "data:text/plain;utf-16,x\u{000a}y",
  ) // D|getDataUri(3)|text/plain|utf-16|x{u000a}y|data:text/plain;utf-16,x{u000a}y
  assert_eq(
    @codec.data_uri("text/plain", "nope", "hello world"),
    "data:text/plain;nope,hello world",
  ) // D|getDataUri(3)|text/plain|nope|hello world|data:text/plain;nope,hello world
  assert_eq(
    @codec.data_uri("text/plain", "nope", "a b&c=d"),
    "data:text/plain;nope,a b&c=d",
  ) // D|getDataUri(3)|text/plain|nope|a b&c=d|data:text/plain;nope,a b&c=d
  assert_eq(
    @codec.data_uri("text/plain", "nope", "\u{4e2d}\u{6587}"),
    "data:text/plain;nope,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|text/plain|nope|{u4e2d}{u6587}|data:text/plain;nope,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("text/plain", "nope", ""), "data:text/plain;nope,") // D|getDataUri(3)|text/plain|nope||data:text/plain;nope,
  assert_eq(
    @codec.data_uri("text/plain", "nope", "100%"),
    "data:text/plain;nope,100%",
  ) // D|getDataUri(3)|text/plain|nope|100%|data:text/plain;nope,100%
  assert_eq(
    @codec.data_uri("text/plain", "nope", "x\u{000a}y"),
    "data:text/plain;nope,x\u{000a}y",
  ) // D|getDataUri(3)|text/plain|nope|x{u000a}y|data:text/plain;nope,x{u000a}y
  assert_eq(
    @codec.data_uri("", "utf-8", "hello world"),
    "data:;utf-8,hello world",
  ) // D|getDataUri(3)||utf-8|hello world|data:;utf-8,hello world
  assert_eq(@codec.data_uri("", "utf-8", "a b&c=d"), "data:;utf-8,a b&c=d") // D|getDataUri(3)||utf-8|a b&c=d|data:;utf-8,a b&c=d
  assert_eq(
    @codec.data_uri("", "utf-8", "\u{4e2d}\u{6587}"),
    "data:;utf-8,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)||utf-8|{u4e2d}{u6587}|data:;utf-8,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("", "utf-8", ""), "data:;utf-8,") // D|getDataUri(3)||utf-8||data:;utf-8,
  assert_eq(@codec.data_uri("", "utf-8", "100%"), "data:;utf-8,100%") // D|getDataUri(3)||utf-8|100%|data:;utf-8,100%
  assert_eq(
    @codec.data_uri("", "utf-8", "x\u{000a}y"),
    "data:;utf-8,x\u{000a}y",
  ) // D|getDataUri(3)||utf-8|x{u000a}y|data:;utf-8,x{u000a}y
  assert_eq(@codec.data_uri("", "GBK", "hello world"), "data:;GBK,hello world") // D|getDataUri(3)||GBK|hello world|data:;GBK,hello world
  assert_eq(@codec.data_uri("", "GBK", "a b&c=d"), "data:;GBK,a b&c=d") // D|getDataUri(3)||GBK|a b&c=d|data:;GBK,a b&c=d
  assert_eq(
    @codec.data_uri("", "GBK", "\u{4e2d}\u{6587}"),
    "data:;GBK,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)||GBK|{u4e2d}{u6587}|data:;GBK,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("", "GBK", ""), "data:;GBK,") // D|getDataUri(3)||GBK||data:;GBK,
  assert_eq(@codec.data_uri("", "GBK", "100%"), "data:;GBK,100%") // D|getDataUri(3)||GBK|100%|data:;GBK,100%
  assert_eq(@codec.data_uri("", "GBK", "x\u{000a}y"), "data:;GBK,x\u{000a}y") // D|getDataUri(3)||GBK|x{u000a}y|data:;GBK,x{u000a}y
  assert_eq(@codec.data_uri("", "gbk", "hello world"), "data:;gbk,hello world") // D|getDataUri(3)||gbk|hello world|data:;gbk,hello world
  assert_eq(@codec.data_uri("", "gbk", "a b&c=d"), "data:;gbk,a b&c=d") // D|getDataUri(3)||gbk|a b&c=d|data:;gbk,a b&c=d
  assert_eq(
    @codec.data_uri("", "gbk", "\u{4e2d}\u{6587}"),
    "data:;gbk,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)||gbk|{u4e2d}{u6587}|data:;gbk,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("", "gbk", ""), "data:;gbk,") // D|getDataUri(3)||gbk||data:;gbk,
  assert_eq(@codec.data_uri("", "gbk", "100%"), "data:;gbk,100%") // D|getDataUri(3)||gbk|100%|data:;gbk,100%
  assert_eq(@codec.data_uri("", "gbk", "x\u{000a}y"), "data:;gbk,x\u{000a}y") // D|getDataUri(3)||gbk|x{u000a}y|data:;gbk,x{u000a}y
  assert_eq(@codec.data_uri("", "", "hello world"), "data:,hello world") // D|getDataUri(3)|||hello world|data:,hello world
  assert_eq(@codec.data_uri("", "", "a b&c=d"), "data:,a b&c=d") // D|getDataUri(3)|||a b&c=d|data:,a b&c=d
  assert_eq(
    @codec.data_uri("", "", "\u{4e2d}\u{6587}"),
    "data:,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|||{u4e2d}{u6587}|data:,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("", "", ""), "data:,") // D|getDataUri(3)||||data:,
  assert_eq(@codec.data_uri("", "", "100%"), "data:,100%") // D|getDataUri(3)|||100%|data:,100%
  assert_eq(@codec.data_uri("", "", "x\u{000a}y"), "data:,x\u{000a}y") // D|getDataUri(3)|||x{u000a}y|data:,x{u000a}y
  assert_eq(
    @codec.data_uri("", "\u{007b}null\u{007d}", "hello world"),
    "data:,hello world",
  ) // D|getDataUri(3)||{null}|hello world|data:,hello world
  assert_eq(
    @codec.data_uri("", "\u{007b}null\u{007d}", "a b&c=d"),
    "data:,a b&c=d",
  ) // D|getDataUri(3)||{null}|a b&c=d|data:,a b&c=d
  assert_eq(
    @codec.data_uri("", "\u{007b}null\u{007d}", "\u{4e2d}\u{6587}"),
    "data:,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)||{null}|{u4e2d}{u6587}|data:,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("", "\u{007b}null\u{007d}", ""), "data:,") // D|getDataUri(3)||{null}||data:,
  assert_eq(@codec.data_uri("", "\u{007b}null\u{007d}", "100%"), "data:,100%") // D|getDataUri(3)||{null}|100%|data:,100%
  assert_eq(
    @codec.data_uri("", "\u{007b}null\u{007d}", "x\u{000a}y"),
    "data:,x\u{000a}y",
  ) // D|getDataUri(3)||{null}|x{u000a}y|data:,x{u000a}y
  assert_eq(
    @codec.data_uri("", "utf-16", "hello world"),
    "data:;utf-16,hello world",
  ) // D|getDataUri(3)||utf-16|hello world|data:;utf-16,hello world
  assert_eq(@codec.data_uri("", "utf-16", "a b&c=d"), "data:;utf-16,a b&c=d") // D|getDataUri(3)||utf-16|a b&c=d|data:;utf-16,a b&c=d
  assert_eq(
    @codec.data_uri("", "utf-16", "\u{4e2d}\u{6587}"),
    "data:;utf-16,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)||utf-16|{u4e2d}{u6587}|data:;utf-16,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("", "utf-16", ""), "data:;utf-16,") // D|getDataUri(3)||utf-16||data:;utf-16,
  assert_eq(@codec.data_uri("", "utf-16", "100%"), "data:;utf-16,100%") // D|getDataUri(3)||utf-16|100%|data:;utf-16,100%
  assert_eq(
    @codec.data_uri("", "utf-16", "x\u{000a}y"),
    "data:;utf-16,x\u{000a}y",
  ) // D|getDataUri(3)||utf-16|x{u000a}y|data:;utf-16,x{u000a}y
  assert_eq(
    @codec.data_uri("", "nope", "hello world"),
    "data:;nope,hello world",
  ) // D|getDataUri(3)||nope|hello world|data:;nope,hello world
  assert_eq(@codec.data_uri("", "nope", "a b&c=d"), "data:;nope,a b&c=d") // D|getDataUri(3)||nope|a b&c=d|data:;nope,a b&c=d
  assert_eq(
    @codec.data_uri("", "nope", "\u{4e2d}\u{6587}"),
    "data:;nope,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)||nope|{u4e2d}{u6587}|data:;nope,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("", "nope", ""), "data:;nope,") // D|getDataUri(3)||nope||data:;nope,
  assert_eq(@codec.data_uri("", "nope", "100%"), "data:;nope,100%") // D|getDataUri(3)||nope|100%|data:;nope,100%
  assert_eq(@codec.data_uri("", "nope", "x\u{000a}y"), "data:;nope,x\u{000a}y") // D|getDataUri(3)||nope|x{u000a}y|data:;nope,x{u000a}y
  assert_eq(
    @codec.data_uri("image/png", "utf-8", "hello world"),
    "data:image/png;utf-8,hello world",
  ) // D|getDataUri(3)|image/png|utf-8|hello world|data:image/png;utf-8,hello world
  assert_eq(
    @codec.data_uri("image/png", "utf-8", "a b&c=d"),
    "data:image/png;utf-8,a b&c=d",
  ) // D|getDataUri(3)|image/png|utf-8|a b&c=d|data:image/png;utf-8,a b&c=d
  assert_eq(
    @codec.data_uri("image/png", "utf-8", "\u{4e2d}\u{6587}"),
    "data:image/png;utf-8,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|image/png|utf-8|{u4e2d}{u6587}|data:image/png;utf-8,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("image/png", "utf-8", ""), "data:image/png;utf-8,") // D|getDataUri(3)|image/png|utf-8||data:image/png;utf-8,
  assert_eq(
    @codec.data_uri("image/png", "utf-8", "100%"),
    "data:image/png;utf-8,100%",
  ) // D|getDataUri(3)|image/png|utf-8|100%|data:image/png;utf-8,100%
  assert_eq(
    @codec.data_uri("image/png", "utf-8", "x\u{000a}y"),
    "data:image/png;utf-8,x\u{000a}y",
  ) // D|getDataUri(3)|image/png|utf-8|x{u000a}y|data:image/png;utf-8,x{u000a}y
  assert_eq(
    @codec.data_uri("image/png", "GBK", "hello world"),
    "data:image/png;GBK,hello world",
  ) // D|getDataUri(3)|image/png|GBK|hello world|data:image/png;GBK,hello world
  assert_eq(
    @codec.data_uri("image/png", "GBK", "a b&c=d"),
    "data:image/png;GBK,a b&c=d",
  ) // D|getDataUri(3)|image/png|GBK|a b&c=d|data:image/png;GBK,a b&c=d
  assert_eq(
    @codec.data_uri("image/png", "GBK", "\u{4e2d}\u{6587}"),
    "data:image/png;GBK,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|image/png|GBK|{u4e2d}{u6587}|data:image/png;GBK,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("image/png", "GBK", ""), "data:image/png;GBK,") // D|getDataUri(3)|image/png|GBK||data:image/png;GBK,
  assert_eq(
    @codec.data_uri("image/png", "GBK", "100%"),
    "data:image/png;GBK,100%",
  ) // D|getDataUri(3)|image/png|GBK|100%|data:image/png;GBK,100%
  assert_eq(
    @codec.data_uri("image/png", "GBK", "x\u{000a}y"),
    "data:image/png;GBK,x\u{000a}y",
  ) // D|getDataUri(3)|image/png|GBK|x{u000a}y|data:image/png;GBK,x{u000a}y
  assert_eq(
    @codec.data_uri("image/png", "gbk", "hello world"),
    "data:image/png;gbk,hello world",
  ) // D|getDataUri(3)|image/png|gbk|hello world|data:image/png;gbk,hello world
  assert_eq(
    @codec.data_uri("image/png", "gbk", "a b&c=d"),
    "data:image/png;gbk,a b&c=d",
  ) // D|getDataUri(3)|image/png|gbk|a b&c=d|data:image/png;gbk,a b&c=d
  assert_eq(
    @codec.data_uri("image/png", "gbk", "\u{4e2d}\u{6587}"),
    "data:image/png;gbk,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|image/png|gbk|{u4e2d}{u6587}|data:image/png;gbk,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("image/png", "gbk", ""), "data:image/png;gbk,") // D|getDataUri(3)|image/png|gbk||data:image/png;gbk,
  assert_eq(
    @codec.data_uri("image/png", "gbk", "100%"),
    "data:image/png;gbk,100%",
  ) // D|getDataUri(3)|image/png|gbk|100%|data:image/png;gbk,100%
  assert_eq(
    @codec.data_uri("image/png", "gbk", "x\u{000a}y"),
    "data:image/png;gbk,x\u{000a}y",
  ) // D|getDataUri(3)|image/png|gbk|x{u000a}y|data:image/png;gbk,x{u000a}y
  assert_eq(
    @codec.data_uri("image/png", "", "hello world"),
    "data:image/png,hello world",
  ) // D|getDataUri(3)|image/png||hello world|data:image/png,hello world
  assert_eq(
    @codec.data_uri("image/png", "", "a b&c=d"),
    "data:image/png,a b&c=d",
  ) // D|getDataUri(3)|image/png||a b&c=d|data:image/png,a b&c=d
  assert_eq(
    @codec.data_uri("image/png", "", "\u{4e2d}\u{6587}"),
    "data:image/png,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|image/png||{u4e2d}{u6587}|data:image/png,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("image/png", "", ""), "data:image/png,") // D|getDataUri(3)|image/png|||data:image/png,
  assert_eq(@codec.data_uri("image/png", "", "100%"), "data:image/png,100%") // D|getDataUri(3)|image/png||100%|data:image/png,100%
  assert_eq(
    @codec.data_uri("image/png", "", "x\u{000a}y"),
    "data:image/png,x\u{000a}y",
  ) // D|getDataUri(3)|image/png||x{u000a}y|data:image/png,x{u000a}y
  assert_eq(
    @codec.data_uri("image/png", "\u{007b}null\u{007d}", "hello world"),
    "data:image/png,hello world",
  ) // D|getDataUri(3)|image/png|{null}|hello world|data:image/png,hello world
  assert_eq(
    @codec.data_uri("image/png", "\u{007b}null\u{007d}", "a b&c=d"),
    "data:image/png,a b&c=d",
  ) // D|getDataUri(3)|image/png|{null}|a b&c=d|data:image/png,a b&c=d
  assert_eq(
    @codec.data_uri("image/png", "\u{007b}null\u{007d}", "\u{4e2d}\u{6587}"),
    "data:image/png,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|image/png|{null}|{u4e2d}{u6587}|data:image/png,{u4e2d}{u6587}
  assert_eq(
    @codec.data_uri("image/png", "\u{007b}null\u{007d}", ""),
    "data:image/png,",
  ) // D|getDataUri(3)|image/png|{null}||data:image/png,
  assert_eq(
    @codec.data_uri("image/png", "\u{007b}null\u{007d}", "100%"),
    "data:image/png,100%",
  ) // D|getDataUri(3)|image/png|{null}|100%|data:image/png,100%
  assert_eq(
    @codec.data_uri("image/png", "\u{007b}null\u{007d}", "x\u{000a}y"),
    "data:image/png,x\u{000a}y",
  ) // D|getDataUri(3)|image/png|{null}|x{u000a}y|data:image/png,x{u000a}y
  assert_eq(
    @codec.data_uri("image/png", "utf-16", "hello world"),
    "data:image/png;utf-16,hello world",
  ) // D|getDataUri(3)|image/png|utf-16|hello world|data:image/png;utf-16,hello world
  assert_eq(
    @codec.data_uri("image/png", "utf-16", "a b&c=d"),
    "data:image/png;utf-16,a b&c=d",
  ) // D|getDataUri(3)|image/png|utf-16|a b&c=d|data:image/png;utf-16,a b&c=d
  assert_eq(
    @codec.data_uri("image/png", "utf-16", "\u{4e2d}\u{6587}"),
    "data:image/png;utf-16,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|image/png|utf-16|{u4e2d}{u6587}|data:image/png;utf-16,{u4e2d}{u6587}
  assert_eq(
    @codec.data_uri("image/png", "utf-16", ""),
    "data:image/png;utf-16,",
  ) // D|getDataUri(3)|image/png|utf-16||data:image/png;utf-16,
  assert_eq(
    @codec.data_uri("image/png", "utf-16", "100%"),
    "data:image/png;utf-16,100%",
  ) // D|getDataUri(3)|image/png|utf-16|100%|data:image/png;utf-16,100%
  assert_eq(
    @codec.data_uri("image/png", "utf-16", "x\u{000a}y"),
    "data:image/png;utf-16,x\u{000a}y",
  ) // D|getDataUri(3)|image/png|utf-16|x{u000a}y|data:image/png;utf-16,x{u000a}y
  assert_eq(
    @codec.data_uri("image/png", "nope", "hello world"),
    "data:image/png;nope,hello world",
  ) // D|getDataUri(3)|image/png|nope|hello world|data:image/png;nope,hello world
  assert_eq(
    @codec.data_uri("image/png", "nope", "a b&c=d"),
    "data:image/png;nope,a b&c=d",
  ) // D|getDataUri(3)|image/png|nope|a b&c=d|data:image/png;nope,a b&c=d
  assert_eq(
    @codec.data_uri("image/png", "nope", "\u{4e2d}\u{6587}"),
    "data:image/png;nope,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|image/png|nope|{u4e2d}{u6587}|data:image/png;nope,{u4e2d}{u6587}
  assert_eq(@codec.data_uri("image/png", "nope", ""), "data:image/png;nope,") // D|getDataUri(3)|image/png|nope||data:image/png;nope,
  assert_eq(
    @codec.data_uri("image/png", "nope", "100%"),
    "data:image/png;nope,100%",
  ) // D|getDataUri(3)|image/png|nope|100%|data:image/png;nope,100%
  assert_eq(
    @codec.data_uri("image/png", "nope", "x\u{000a}y"),
    "data:image/png;nope,x\u{000a}y",
  ) // D|getDataUri(3)|image/png|nope|x{u000a}y|data:image/png;nope,x{u000a}y
  assert_eq(
    @codec.data_uri("application/json", "utf-8", "hello world"),
    "data:application/json;utf-8,hello world",
  ) // D|getDataUri(3)|application/json|utf-8|hello world|data:application/json;utf-8,hello world
  assert_eq(
    @codec.data_uri("application/json", "utf-8", "a b&c=d"),
    "data:application/json;utf-8,a b&c=d",
  ) // D|getDataUri(3)|application/json|utf-8|a b&c=d|data:application/json;utf-8,a b&c=d
  assert_eq(
    @codec.data_uri("application/json", "utf-8", "\u{4e2d}\u{6587}"),
    "data:application/json;utf-8,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|application/json|utf-8|{u4e2d}{u6587}|data:application/json;utf-8,{u4e2d}{u6587}
  assert_eq(
    @codec.data_uri("application/json", "utf-8", ""),
    "data:application/json;utf-8,",
  ) // D|getDataUri(3)|application/json|utf-8||data:application/json;utf-8,
  assert_eq(
    @codec.data_uri("application/json", "utf-8", "100%"),
    "data:application/json;utf-8,100%",
  ) // D|getDataUri(3)|application/json|utf-8|100%|data:application/json;utf-8,100%
  assert_eq(
    @codec.data_uri("application/json", "utf-8", "x\u{000a}y"),
    "data:application/json;utf-8,x\u{000a}y",
  ) // D|getDataUri(3)|application/json|utf-8|x{u000a}y|data:application/json;utf-8,x{u000a}y
  assert_eq(
    @codec.data_uri("application/json", "GBK", "hello world"),
    "data:application/json;GBK,hello world",
  ) // D|getDataUri(3)|application/json|GBK|hello world|data:application/json;GBK,hello world
  assert_eq(
    @codec.data_uri("application/json", "GBK", "a b&c=d"),
    "data:application/json;GBK,a b&c=d",
  ) // D|getDataUri(3)|application/json|GBK|a b&c=d|data:application/json;GBK,a b&c=d
  assert_eq(
    @codec.data_uri("application/json", "GBK", "\u{4e2d}\u{6587}"),
    "data:application/json;GBK,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|application/json|GBK|{u4e2d}{u6587}|data:application/json;GBK,{u4e2d}{u6587}
  assert_eq(
    @codec.data_uri("application/json", "GBK", ""),
    "data:application/json;GBK,",
  ) // D|getDataUri(3)|application/json|GBK||data:application/json;GBK,
  assert_eq(
    @codec.data_uri("application/json", "GBK", "100%"),
    "data:application/json;GBK,100%",
  ) // D|getDataUri(3)|application/json|GBK|100%|data:application/json;GBK,100%
  assert_eq(
    @codec.data_uri("application/json", "GBK", "x\u{000a}y"),
    "data:application/json;GBK,x\u{000a}y",
  ) // D|getDataUri(3)|application/json|GBK|x{u000a}y|data:application/json;GBK,x{u000a}y
  assert_eq(
    @codec.data_uri("application/json", "gbk", "hello world"),
    "data:application/json;gbk,hello world",
  ) // D|getDataUri(3)|application/json|gbk|hello world|data:application/json;gbk,hello world
  assert_eq(
    @codec.data_uri("application/json", "gbk", "a b&c=d"),
    "data:application/json;gbk,a b&c=d",
  ) // D|getDataUri(3)|application/json|gbk|a b&c=d|data:application/json;gbk,a b&c=d
  assert_eq(
    @codec.data_uri("application/json", "gbk", "\u{4e2d}\u{6587}"),
    "data:application/json;gbk,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|application/json|gbk|{u4e2d}{u6587}|data:application/json;gbk,{u4e2d}{u6587}
  assert_eq(
    @codec.data_uri("application/json", "gbk", ""),
    "data:application/json;gbk,",
  ) // D|getDataUri(3)|application/json|gbk||data:application/json;gbk,
  assert_eq(
    @codec.data_uri("application/json", "gbk", "100%"),
    "data:application/json;gbk,100%",
  ) // D|getDataUri(3)|application/json|gbk|100%|data:application/json;gbk,100%
  assert_eq(
    @codec.data_uri("application/json", "gbk", "x\u{000a}y"),
    "data:application/json;gbk,x\u{000a}y",
  ) // D|getDataUri(3)|application/json|gbk|x{u000a}y|data:application/json;gbk,x{u000a}y
  assert_eq(
    @codec.data_uri("application/json", "", "hello world"),
    "data:application/json,hello world",
  ) // D|getDataUri(3)|application/json||hello world|data:application/json,hello world
  assert_eq(
    @codec.data_uri("application/json", "", "a b&c=d"),
    "data:application/json,a b&c=d",
  ) // D|getDataUri(3)|application/json||a b&c=d|data:application/json,a b&c=d
  assert_eq(
    @codec.data_uri("application/json", "", "\u{4e2d}\u{6587}"),
    "data:application/json,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|application/json||{u4e2d}{u6587}|data:application/json,{u4e2d}{u6587}
  assert_eq(
    @codec.data_uri("application/json", "", ""),
    "data:application/json,",
  ) // D|getDataUri(3)|application/json|||data:application/json,
  assert_eq(
    @codec.data_uri("application/json", "", "100%"),
    "data:application/json,100%",
  ) // D|getDataUri(3)|application/json||100%|data:application/json,100%
  assert_eq(
    @codec.data_uri("application/json", "", "x\u{000a}y"),
    "data:application/json,x\u{000a}y",
  ) // D|getDataUri(3)|application/json||x{u000a}y|data:application/json,x{u000a}y
  assert_eq(
    @codec.data_uri("application/json", "\u{007b}null\u{007d}", "hello world"),
    "data:application/json,hello world",
  ) // D|getDataUri(3)|application/json|{null}|hello world|data:application/json,hello world
  assert_eq(
    @codec.data_uri("application/json", "\u{007b}null\u{007d}", "a b&c=d"),
    "data:application/json,a b&c=d",
  ) // D|getDataUri(3)|application/json|{null}|a b&c=d|data:application/json,a b&c=d
  assert_eq(
    @codec.data_uri(
      "application/json", "\u{007b}null\u{007d}", "\u{4e2d}\u{6587}",
    ),
    "data:application/json,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|application/json|{null}|{u4e2d}{u6587}|data:application/json,{u4e2d}{u6587}
  assert_eq(
    @codec.data_uri("application/json", "\u{007b}null\u{007d}", ""),
    "data:application/json,",
  ) // D|getDataUri(3)|application/json|{null}||data:application/json,
  assert_eq(
    @codec.data_uri("application/json", "\u{007b}null\u{007d}", "100%"),
    "data:application/json,100%",
  ) // D|getDataUri(3)|application/json|{null}|100%|data:application/json,100%
  assert_eq(
    @codec.data_uri("application/json", "\u{007b}null\u{007d}", "x\u{000a}y"),
    "data:application/json,x\u{000a}y",
  ) // D|getDataUri(3)|application/json|{null}|x{u000a}y|data:application/json,x{u000a}y
  assert_eq(
    @codec.data_uri("application/json", "utf-16", "hello world"),
    "data:application/json;utf-16,hello world",
  ) // D|getDataUri(3)|application/json|utf-16|hello world|data:application/json;utf-16,hello world
  assert_eq(
    @codec.data_uri("application/json", "utf-16", "a b&c=d"),
    "data:application/json;utf-16,a b&c=d",
  ) // D|getDataUri(3)|application/json|utf-16|a b&c=d|data:application/json;utf-16,a b&c=d
  assert_eq(
    @codec.data_uri("application/json", "utf-16", "\u{4e2d}\u{6587}"),
    "data:application/json;utf-16,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|application/json|utf-16|{u4e2d}{u6587}|data:application/json;utf-16,{u4e2d}{u6587}
  assert_eq(
    @codec.data_uri("application/json", "utf-16", ""),
    "data:application/json;utf-16,",
  ) // D|getDataUri(3)|application/json|utf-16||data:application/json;utf-16,
  assert_eq(
    @codec.data_uri("application/json", "utf-16", "100%"),
    "data:application/json;utf-16,100%",
  ) // D|getDataUri(3)|application/json|utf-16|100%|data:application/json;utf-16,100%
  assert_eq(
    @codec.data_uri("application/json", "utf-16", "x\u{000a}y"),
    "data:application/json;utf-16,x\u{000a}y",
  ) // D|getDataUri(3)|application/json|utf-16|x{u000a}y|data:application/json;utf-16,x{u000a}y
  assert_eq(
    @codec.data_uri("application/json", "nope", "hello world"),
    "data:application/json;nope,hello world",
  ) // D|getDataUri(3)|application/json|nope|hello world|data:application/json;nope,hello world
  assert_eq(
    @codec.data_uri("application/json", "nope", "a b&c=d"),
    "data:application/json;nope,a b&c=d",
  ) // D|getDataUri(3)|application/json|nope|a b&c=d|data:application/json;nope,a b&c=d
  assert_eq(
    @codec.data_uri("application/json", "nope", "\u{4e2d}\u{6587}"),
    "data:application/json;nope,\u{4e2d}\u{6587}",
  ) // D|getDataUri(3)|application/json|nope|{u4e2d}{u6587}|data:application/json;nope,{u4e2d}{u6587}
  assert_eq(
    @codec.data_uri("application/json", "nope", ""),
    "data:application/json;nope,",
  ) // D|getDataUri(3)|application/json|nope||data:application/json;nope,
  assert_eq(
    @codec.data_uri("application/json", "nope", "100%"),
    "data:application/json;nope,100%",
  ) // D|getDataUri(3)|application/json|nope|100%|data:application/json;nope,100%
  assert_eq(
    @codec.data_uri("application/json", "nope", "x\u{000a}y"),
    "data:application/json;nope,x\u{000a}y",
  ) // D|getDataUri(3)|application/json|nope|x{u000a}y|data:application/json;nope,x{u000a}y
  assert_eq(
    @codec.data_uri("text/plain", "UTF-8", "aGk="),
    "data:text/plain;base64,aGk=",
  ) // D|getDataUriBase64|text/plain|aGk=|data:text/plain;base64,aGk=
  assert_eq(
    @codec.data_uri("text/plain", "UTF-8", ""),
    "data:text/plain;base64,",
  ) // D|getDataUriBase64|text/plain||data:text/plain;base64,
  assert_eq(
    @codec.data_uri("text/plain", "UTF-8", "not-base64!!"),
    "data:text/plain;base64,not-base64!!",
  ) // D|getDataUriBase64|text/plain|not-base64!!|data:text/plain;base64,not-base64!!
  assert_eq(@codec.data_uri("text/plain", "UTF-8", "aGk="), "data:;base64,aGk=") // D|getDataUriBase64|{null}|aGk=|data:;base64,aGk=
  assert_eq(@codec.data_uri("text/plain", "UTF-8", ""), "data:;base64,") // D|getDataUriBase64|{null}||data:;base64,
  assert_eq(
    @codec.data_uri("text/plain", "UTF-8", "not-base64!!"),
    "data:;base64,not-base64!!",
  ) // D|getDataUriBase64|{null}|not-base64!!|data:;base64,not-base64!!
  assert_eq(@codec.data_uri("text/plain", "UTF-8", "aGk="), "data:;base64,aGk=") // D|getDataUriBase64||aGk=|data:;base64,aGk=
  assert_eq(@codec.data_uri("text/plain", "UTF-8", ""), "data:;base64,") // D|getDataUriBase64|||data:;base64,
  assert_eq(
    @codec.data_uri("text/plain", "UTF-8", "not-base64!!"),
    "data:;base64,not-base64!!",
  ) // D|getDataUriBase64||not-base64!!|data:;base64,not-base64!!
}

// 不落断言的读数：`C|completeUrl` 共 340 条 —— 它不是纯串面（参照把"是不是绝对 URL"
//   的判断委托给 `java.net.URL` 的协议处理器：`data:`/`tel:`/`urn:`/`javascript:` 一律
//   ERR:UtilException（本库收不到这种"协议白名单"），无 scheme 的基串又被它补成 `http://`，
//   且 `http://a` + `./b` 那档**不做点段归一**（与 RFC 3986 不同）。判 deferred 的理由与
//   逐条读数见 docs/spec/05-codec.md §5.10；本库无对位形状档 81 条。
