#!/usr/bin/env node
// moon-hutool http 包 live 档的本地工装（issue #4 三档 + issue #5 连接池五档）。
// 跑法：node scripts/http_live_harness.mjs [port] &
//       MOONHUTOOL_HTTP_LIVE_BASE=http://127.0.0.1:<port> moon test --target wasm -p mldong/moon-hutool/http
// 端点：
//   /redirect → 302（Location: /target，逐请求计数）——验"不得自动跟随"；
//   /gzip     → 无条件回 gzip 正文（无视 Accept-Encoding）——验"正文一字不改"；
//   /never    → 收下请求永不回——验"超时是硬界"（黑洞腿）；
//   /bytes    → 小应答、保持连接——复用/回归档的主力路由；
//   /close3   → 第 3 个应答带 Connection: close 并掐线——验"关线应答不回池"；
//   /big      → 8KB 应答——验"读一半 close 即丢弃"（有剩余可读才叫读一半）；
//   /open     → 除当前探测连接外的在连套接字数；
//   /counter?name=… → 各路由命中数与 accepts。
// accepts 口径：只数承载应用路由的连接（探测 /counter、/open 的连接不计），
// 每条连接只数一次（keep-alive 复用同一条连接不算第二次）。
import http from 'node:http';
import zlib from 'node:zlib';

const GZIP = zlib.gzipSync(
  Buffer.from('moon-hutool http live gzip leg — 正文一字不改\n', 'utf8'),
  { level: 9 },
);
let redirectHits = 0;
let targetHits = 0;
let gzipHits = 0;
let bytesHits = 0;
let bigHits = 0;
let close3Hits = 0;
let accepts = 0;
const sockets = new Set();
const APP_ROUTES = new Set([
  '/redirect',
  '/target',
  '/gzip',
  '/bytes',
  '/big',
  '/close3',
]);

const server = http.createServer((req, res) => {
  const url = new URL(req.url, 'http://harness.invalid');
  const path = url.pathname;
  if (path === '/redirect') {
    redirectHits += 1;
    res.writeHead(302, { location: '/target' });
    res.end();
    return;
  }
  if (path === '/target') {
    targetHits += 1;
    res.writeHead(200, { 'content-type': 'text/plain' });
    res.end('target');
    return;
  }
  if (path === '/gzip') {
    gzipHits += 1;
    res.writeHead(200, {
      'content-encoding': 'gzip',
      'content-length': GZIP.length,
    });
    res.end(GZIP);
    return;
  }
  if (path === '/bytes') {
    bytesHits += 1;
    const body = 'moon-hutool-close-probe\n';
    res.writeHead(200, { 'content-length': Buffer.byteLength(body) });
    res.end(body);
    return;
  }
  if (path === '/big') {
    bigHits += 1;
    const body = 'a'.repeat(8192);
    res.writeHead(200, { 'content-length': body.length });
    res.end(body);
    return;
  }
  if (path === '/close3') {
    close3Hits += 1;
    const headers = { 'content-type': 'text/plain', 'content-length': 2 };
    if (close3Hits % 4 === 3) {
      // Node 会无视 writeHead 里的 Connection 头自己写 keep-alive，
      // 必须先关 shouldKeepAlive 才真的发 Connection: close 并掐线
      res.shouldKeepAlive = false;
      headers.connection = 'close';
    }
    res.writeHead(200, headers);
    res.end('ok');
    return;
  }
  if (path === '/never') {
    // 收下连接但不回：连应答头都不给，连接由客户端的超时界来断
    return;
  }
  if (path === '/open') {
    res.writeHead(200, { 'content-type': 'text/plain' });
    res.end(String(sockets.size - 1));
    return;
  }
  if (path === '/counter') {
    const name = url.searchParams.get('name');
    let value = -1;
    if (name === 'redirect') {
      value = redirectHits;
    } else if (name === 'target') {
      value = targetHits;
    } else if (name === 'gzip') {
      value = gzipHits;
    } else if (name === 'bytes') {
      value = bytesHits;
    } else if (name === 'big') {
      value = bigHits;
    } else if (name === 'close3') {
      value = close3Hits;
    } else if (name === 'accepts') {
      value = accepts;
    }
    res.writeHead(200, { 'content-type': 'text/plain' });
    res.end(String(value));
    return;
  }
  res.writeHead(404, { 'content-type': 'text/plain' });
  res.end('no route');
});

let nextSeq = 0;
server.on('connection', socket => {
  socket.seq = nextSeq;
  socket.rport = socket.remotePort;
  nextSeq += 1;
  sockets.add(socket);
  socket.on('close', () => sockets.delete(socket));
  console.log(`[conn +${socket.seq} rport=${socket.rport}]`);
});

// 应用连接计数：每条连接只数一次，且只有首请求打在应用路由上才算
//（探测 /counter、/open 的连接不进 accepts，免得探测自己污染判据）。
server.on('request', (req, res) => {
  const socket = res.socket;
  if (!socket || socket.countedApp) {
    return;
  }
  const path = (req.url || '').split('?')[0];
  if (APP_ROUTES.has(path)) {
    socket.countedApp = true;
    accepts += 1;
  }
  console.log(`[req ${socket.seq} rport=${socket.rport}] ${path}`);
});

const port = Number(process.argv[2] || 18400);
server.listen(port, '127.0.0.1', () => {
  console.log(`moon-hutool http live harness on 127.0.0.1:${port}`);
});
