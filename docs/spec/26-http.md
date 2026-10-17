# 26 · `http` —— 可注入的 HTTP 传输端口 + 官方 async/http 薄适配

需求登记：本仓 Issues #4（对象存储线的 HTTP 层归口）。行号 26 是稳定 ID（逐包表第 26 行，门禁 G13）。
参照底座：`moonbitlang/async` 0.22.4 的 `src/http`（本机 `.mooncakes` 缓存现读，逐条给行号）。

## §1 定位与例外口径

- **本包不是 hutool 对位件**：hutool 的 http 在独立 artifact（hutool-http），hutool-core 里没有类面；
  本包是基础件补位，与 `sched`（第 24 行）同形——都是"参照生态里绕不开、但不在 hutool-core"的面。
- 端口半（`transport.mbt`）：纯形状 + 两个 trait，零 OS 能力，桩实现不发网络即可断言全部端口语义。
  适配半（`adapter.mbt`）：官方 `moonbitlang/async/http` 之上的薄适配。这是全仓第二个 import
  `moonbitlang/async` 的包（门禁 G1/G19 白名单第二格），底座只用官方件、不引第三方 HTTP 库。
- **只承诺 native+wasm 两档**（摘档照 sched 先例，`supported_targets = "+native+wasm"`）：
  官方 http 包的 `unimplemented.mbt` 写明 `#cfg(not(any(target="native", target="wasm")))` 是
  js/wasm-gc 的占位件（该文件自述 "does not support JavaScript or wasm-gc backend"）；
  js 档另有 `client.js.mbt` 但同文件标注为占位口径的一部分。`moon check` 在 js/wasm-gc 两档
  直接跳过本包（包级 `supported_targets`），四档编译矩阵不受影响。

## §2 端口形状（冻结面）

`http/pkg.generated.mbti` 是唯一权威；这里只记形状与不写进签名的话：

- `Method` 七值（Get/Head/Put/Post/Delete/Patch/Options）：官方 `RequestMethod` 裁掉
  `Connect`（代理隧道是底层能力，端口消费方不走 CONNECT）与 `Trace`（两侧生态都无消费）。
- `Header`：`{name, value}` 单条。端口按 `Array[Header]` **保序携带、允许同名重复**——
  这是端口的携带语义；官方底座适配层对重复的处理是响亮拒绝（§4.2），桩实现不受此限。
- `RequestBody` 三档：`Empty`（显式空体，适配层必带 `content-length: 0`）/ `Bytes` /
  `Stream(&@io.Reader, Int64?)`——给得出长度就 `Content-Length`，给不出走 chunked
  （部分对象存储对 chunked PUT 直接 411/501，能不能用由上层按各家服务器实测决定）。
- `ResponseBody` trait：`read(max_len) -> Bytes?`（None 即 EOF）+ 不 raise 的 `close`。
  close 之后 read **必须报错而不是返回空**——把"忘 close"从静默泄漏变成显式故障。
- `TransportError` 四档：`Network(String)` / `Timeout` / `InvalidRequest(String)` /
  `InvalidResponse(String)`。**状态码不是错误**（§4.6）；Timeout 单列不并入 Network——
  "没在时限内得到应答"与"连接被拒"该走不同重试策略（存储线实测分开后重试层才写得出来）。
- 不投影：cookies、chunked trailer（`Client::trailer`）。存储线五条真腿无一消费；
  先有消费再有形状，不预先投影。

## §3 官方底座 0.22.4 的四条现读事实（每条给出处）

1. **没有 per-request timeout**：`Client::Client` / `Client::request` / `end_request` 均无时限参数
   ⇒ 适配层用 `@async.with_timeout` 自 bounds（§4.4）。`with_timeout(time, f, error? : Error)`
   在 async 根包（`src/async.mbt`），可注入自定义 error——适配层传 `TransportError::Timeout`，
   让端口契约直接收到分型超时而不是再包一层。
2. **头表是 `Map[CaseInsensitiveString, String]`**：构造期持久头（`Sender::new`）与每请求
   `extra_headers`（`Sender::send_headers`）都从 Map 迭代写线上 ⇒ **线上表达不了重复同名头**（§4.2）。
3. **缺省自动加 `Accept-Encoding` 并透明解压**：`send_request` 里
   `auto_decompress = 调用方（持久头与 extra 都）没带 Accept-Encoding`，为真时客户端自己写
   `Accept-Encoding: gzip,identity`，响应侧 `setup_message_body` 在 `auto_decompress` 且
   `Content-Encoding: gzip` 时透明解压（parser.mbt）。
   **注意方向**：Issues #4 原文把这条读反了（"我们不加这个头就拿原始字节"）——实测与源码都是反的：
   *不加*才触发自动加头+解压；*显式带上*才拿原始字节。适配层的对策见 §4.3，
   刀⑤（去掉 identity 注入 → gzip 档红）是对这条读数的实弹验证。
4. **无重定向跟随**：`client.mbt`/`send.mbt`/`parser.mbt` 非测试代码 grep 无 redirect/Location/30x
   处理（issue 原文的"这轮没找到"已在本轮坐实为"没有"）；302 原样作为应答返回。
   真端点腿一（302 + 计数端点确认目标 0 命中）是对这条的实弹验证。
   另：响应侧重复同名头由官方 parser **逗号合并**（`parser.mbt` 的 `"\{value0},\{value}"`），
   端口原样投影合并结果——对多数头是 RFC 合法折叠，对 Set-Cookie 有损，已在此声明。

## §4 适配层决策（六条实现约束的落点）

1. **URL 一字不改（约束①）**：`split_url` 把绝对 URL 按"首个 /"切成 base（`scheme://authority`，
   喂官方 `Client::Client`——它要求 path 恒为 "/"）与 path?query（原样进 `Client::request`，
   请求行逐字节保留）。拒绝三类必错输入而不是静默改写：fragment（不上线上的东西，
   剥离即"传进来的 URL ≠ 实际发的 URL"）、pathless query（官方 `resolve_url` 会把 `?` 并进 host）、
   非 http/https scheme。判据：wbtest 逐字节断言 `%20` 与重复 query 键原样。
2. **重复同名头响亮拒绝（约束②）**：官方底座线上表达不了重复，合并会改签名/元数据语义
   （SigV4 的 canonical 合并只是签名形态，线上要求每条一行；Kodo 的 x-qn-meta-* 是逐条元数据）。
   所以把"静默丢"换成"显式 `InvalidRequest`"。**明文声明：该适配层不承诺携带重复同名头**——
   端口形状留了位置（数组保序），底座有能力后可放开，使用方现在就该当它不可用。
3. **正文一字不改（约束③）**：恒显式带 `Accept-Encoding: identity` 压掉官方件的自动路径
   （§3 第 3 条）；调用方自带该头则原样透传。代价：线上多一个头（identity 不改变服务器语义），
   换来"服务器发什么字节、消费方读到什么字节"。
4. **超时是硬界（约束⑤）**：建连 + 请求行/头 + 泵体 + 收应答头整段包一个 `with_timeout`；
   应答体每次读（`AsyncHttpBody::read`）单独包。默认 30s，`AsyncHttpTransport::new(timeout~)` 可改。
   对照实测：把界放大到事实无限（刀③），黑洞腿挂死、整轮测试被杀（exit 143/124 形状）——
   "没有界"的代价就是这条，不是推断。
5. **响应体显式 close（约束④）**：`AsyncHttpBody::close` 即官方 `Client::close`（幂等、不 raise）。
   真端点腿四在服务端数连接：close 后 FIN 必达（轮询到 0）；刀④（close 置空）该腿红。
6. **非 2xx 不解释（约束⑥）**：官方件本就不校验状态码（无 `with_validate_status` 这类旋钮的需求），
   `status` 原样上交；端口只报"没拿到应答"（Network/Timeout）与"发不出/解析不了"
   （InvalidRequest/InvalidResponse，含长度与声明不符的 `IncorrectBodyLength` 归入 InvalidRequest）。
7. **传输自有的头拒绝显式携带**：`host`（authority 来自 URL）、`content-length`/`transfer-encoding`
   （由 body 档推导——Empty 显式带 0 那条实测教训的另一面：两处真相必然漂移）。
   `user-agent` 走构造期持久头（官方口径 UA 只许 per-client 全局，本适配层一条请求一条连接）。
8. **连接复用按 origin（0.1.5 起，issue #5）**：本文件初版判"官方 Client 一次只走一条请求
   状态机"——与官方文档冲突（`skip_response_body` 原话 "so that the next request can be
   made"），0.1.5 更正并落地连接池。判据三条红线：只有读尽（EOF）的线回池（读一半就
   close = 丢弃，保守档）；任何 Timeout/Network 后绝不回池；`Connection: close` 与无帧
   （关线定界）应答不回池（无帧即 EOF 是对端关线，线已死）。池键 = (base, user-agent)——
   持久头现读只可能带 UA，以后有别的头挪进持久头**键必须跟着变**，不然后一个请求会带着
   前一个请求的头。`pool~ = false` 完全退回每 send 新建；`drain_connections()` 收掉空闲
   连接（端口 trait 刻意不动：send-only，生命周期方法不逼每个实现方陪跑）。
   从池里取出的线若在应答开始前死掉（对端闲置关线是常态），Empty/Bytes 自动换新线重试
   一次（应答阶段失败绝不重试——状态不可知，重试可能双发；Stream 体不能倒带不重试）。
   HTTP/1.0 不判别（官方公开面无版本号）：1.0 默认关线走"无帧不回池"，带 keep-alive 却
   中途关线的由重试一次兜底。组合值 Connection 头（"keep-alive, close"）只做整值等值判，
   如实记为已知限制。超时打断时连接随 cancellation 丢弃，是否泄漏以工装读数为准。

## §5 判据与读数（2026-10-17 本轮实测）

**假传输/白盒（`contract_test.mbt` + `adapter_wbtest.mbt`，不发网络）5 + 10 条**：
URL/头原样抵达桩、重复头顺序保留、EOF None、close 后 read 必报错、流式体保 Int64 长度；
URL 切分逐字节（含拒绝三档）、头表决策（identity 注入/透传、UA 分流、传输自有头拒绝、
重复拒绝）、content-length 四档计划、负长度拒绝、方法映射七值。
wasm 档 `moon test -p mldong/moon-hutool/http` = **18 绿**（live 四腿无 env 时响亮 SKIP——
SKIP 不是 PASS，各腿自带这句打印）。

**真端点九档（`live_test.mbt`，工装 `scripts/http_live_harness.mjs`）**。档间以
accepts 增量计数判连接数——**九档必须串行在一个测试体里跑**：wasm 跑批里多个 async test
互相穿插（探针实测），分档计数窗口会被别的档污染。工装 accepts 口径：只数承载应用路由的
连接、每连接只数一次（探测 /counter、/open 的连接不计）；/close3 以 `% 4 === 3` 循环关线
（计数跨 run 累计，第一次用 `=== 3` 时第二遍起永远判不到关线应答）。

| 腿 | 判据 | 读数 |
|---|---|---|
| 302 不跟随 | 302 原样返回 + `location` 头在位 + `/target` 计数仍 0 | 绿 |
| gzip 原字节 | 强制 gzip 端点（无视 Accept-Encoding），收到字节与夹具逐字节相等 | 绿 |
| 黑洞超时 | 1.5s 界 → `Timeout`，实测 **1502–1506ms**（界 1500ms），< 20s 上限 | 绿 |
| pool=false 回归 | 3 拍串行 = 3 条新连接（"关掉就退回旧形状"） | 绿 |
| 串行复用 | 同 origin 8 拍：accepts 增量 **1**、请求数 8 | 绿 |
| 并发 | 4 拍并发各建一线互不踩（增量 4）+ 随后 2 拍串行零新建 | 绿 |
| Connection: close（负向一） | 第 3 应答关线 ⇒ 第 4 拍新建（增量 2，不是把死线递上去的 Timeout/Network） | 绿 |
| 读一半 close（负向二） | 3 拍读一半各建一线全丢弃 + 第 4 拍新建（增量 4） | 绿 |

`MOONHUTOOL_HTTP_LIVE_BASE` 不设时响亮 SKIP（SKIP 不是 PASS）。native 档同套用例由 CI
出证（本机无 MSVC，编译可过、运行不行——与 sched 同口径）。

**变异五刀（全部在副本仓做，四刀为 issue 点名 + 一刀补约束③的守卫）**：

| 刀 | 变异 | 红 |
|---|---|---|
| ① | URL 规范化（path 归一成 `/`） | wbtest "keeps path and query verbatim" 红 |
| ② | headers 折 Map（重复静默丢弃） | wbtest "rejects duplicate same-name headers loudly" 红 |
| ③ | 去掉超时（界放大到事实无限） | 黑洞腿挂死，整轮被外部杀（exit 124，无汇总行）——挂死即红 |
| ④ | close 置空 | live close 腿红（连接数不落 0） |
| ⑤ | 去掉 identity 注入 | live gzip 腿红（透明解压复活，字节不等）+ wbtest identity 断言红 |

**已知代价两条，明文声明**：超时打断的 send 会随 cancellation 丢连接，未做取消后回收
（官方件没有取消钩子；工装读数下黑洞腿超时后服务端连接正常关闭）；响应侧重复头是官方
parser 的逗号合并结果，端口不二次折叠（Set-Cookie 多条有损）。

## §6 与 issue #4 读数的两处分歧（都已实测裁决）

1. 解压触发方向：issue 写"我们不加这个头就拿原始字节"，实测相反（§3 第 3 条）——
   已按"恒显式 identity"落地并用刀⑤证明。
2. 重复同名头：issue 的端口形状要求保序携带，但官方底座线上表达不了——按"响亮拒绝"落地
   （§4.2），使用方契约里明文写"该适配层不承诺携带重复头"。若未来存储线真需要多条目头，
   出路是换一个线格式可控的 Transport 实现（端口形状不用动），不是放宽这层的静默合并。
