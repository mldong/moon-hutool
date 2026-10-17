#!/usr/bin/env node
// moon-hutool http 包 live 三档的本地工装（需求登记：本仓 Issues #4）。
// 跑法：node scripts/http_live_harness.mjs [port] &
//       MOONHUTOOL_HTTP_LIVE_BASE=http://127.0.0.1:<port> moon test --target native http/
// 四条腿：
//   /redirect → 302（Location: /target，且逐请求计数）——验"不得自动跟随"；
//   /gzip     → 无条件回 gzip 正文（无视 Accept-Encoding）——验"正文一字不改"；
//   /never    → 收下请求永不回——验"超时是硬界"（黑洞腿）；
//   /bytes + /open → 应答后保持连接，靠 close 释放——验"close 必须真的关"。
//   /counter?name=… → 各端点命中数；/open → 除当前探测连接外的在连套接字数。
import http from 'node:http';
import zlib from 'node:zlib';

const GZIP = zlib.gzipSync(
  Buffer.from('moon-hutool http live gzip leg — 正文一字不改\n', 'utf8'),
  { level: 9 },
);
let redirectHits = 0;
let targetHits = 0;
let gzipHits = 0;
const sockets = new Set();

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
    const body = 'moon-hutool-close-probe\n';
    res.writeHead(200, { 'content-length': Buffer.byteLength(body) });
    res.end(body);
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
    const value =
      name === 'redirect' ? redirectHits : name === 'target' ? targetHits : name === 'gzip' ? gzipHits : -1;
    res.writeHead(200, { 'content-type': 'text/plain' });
    res.end(String(value));
    return;
  }
  res.writeHead(404, { 'content-type': 'text/plain' });
  res.end('no route');
});

server.on('connection', socket => {
  sockets.add(socket);
  socket.on('close', () => sockets.delete(socket));
});

const port = Number(process.argv[2] || 18400);
server.listen(port, '127.0.0.1', () => {
  console.log(`moon-hutool http live harness on 127.0.0.1:${port}`);
});
