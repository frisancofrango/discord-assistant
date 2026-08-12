// Router: /ide/* -> code-server (8080), everything else -> opencode proxy (4010)
const http = require('http');

const TARGETS = [
  { match: (url) => url.startsWith('/ide'), host: '127.0.0.1', port: 8080 },
  { match: () => true, host: '127.0.0.1', port: 4010 },
];

const server = http.createServer((req, res) => {
  const t = TARGETS.find(t => t.match(req.url)) || TARGETS[1];
  const proxy = http.request({
    host: t.host, port: t.port,
    method: req.method, path: req.url,
    headers: req.headers,
  }, (up) => {
    res.writeHead(up.statusCode, up.headers);
    up.pipe(res);
  });
  proxy.on('error', (e) => {
    res.writeHead(502, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'upstream error', detail: e.message }));
  });
  req.pipe(proxy);
});

server.listen(80, '0.0.0.0', () => console.log('[router] on :80 -> /ide:8080, rest:4010'));
