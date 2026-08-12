// Self-contained OpenAI-compatible server on :4010 wrapping `opencode run`
// One Fly app = one fresh IP = one free bucket. No plugin dependency.
const http = require('http');
const { execFile } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

const PORT = process.env.OPENCODE_LLM_PROXY_PORT || 4010;
const TOKEN = process.env.OPENCODE_LLM_PROXY_TOKEN || 'change-me';
const MODEL = process.env.MODEL || 'opencode/mimo-v2.5-free';

function promptFromBody(body) {
  const msgs = (body.messages || []).map(m =>
    `${m.role === 'user' ? 'User' : m.role === 'assistant' ? 'Assistant' : 'System'}: ` +
    (typeof m.content === 'string' ? m.content : JSON.stringify(m.content))
  ).join('\n');
  return msgs || '';
}

function callOpencode(prompt, cb) {
  // opencode run HANGS when stdout is a pipe — redirect to files (proven working)
  const outFile = path.join(os.tmpdir(), `oc_out_${Date.now()}_${Math.random().toString(36).slice(2)}.log`);
  const errFile = path.join(os.tmpdir(), `oc_err_${Date.now()}_${Math.random().toString(36).slice(2)}.log`);
  const fdOut = fs.openSync(outFile, 'w');
  const fdErr = fs.openSync(errFile, 'w');
  const args = ['run', '--model', MODEL, '--format', 'json', '--pure', prompt];
  const child = require('child_process').spawn('opencode', args, {
    env: { ...process.env },
    stdio: ['ignore', fdOut, fdErr],
  });
  const timer = setTimeout(() => { child.kill('SIGKILL'); }, 300000);
  child.on('error', (e) => { clearTimeout(timer); fs.closeSync(fdOut); fs.closeSync(fdErr); cb(e); });
  child.on('exit', (code) => {
    clearTimeout(timer);
    fs.closeSync(fdOut); fs.closeSync(fdErr);
    let stdout = '', stderr = '';
    try { stdout = fs.readFileSync(outFile, 'utf8'); } catch {}
    try { stderr = fs.readFileSync(errFile, 'utf8'); } catch {}
    try { fs.unlinkSync(outFile); } catch {}
    try { fs.unlinkSync(errFile); } catch {}
    if (code !== 0 && !stdout) return cb(new Error(`opencode exit ${code}: ${stderr.slice(0,300)}`));
    cb(null, stdout || '');
  });
  return child;
}

function extractText(stdout) {
  // parse last JSON event containing text/part output
  let best = '';
  for (const line of stdout.split('\n')) {
    const t = line.trim();
    if (!t) continue;
    try {
      const ev = JSON.parse(t);
      if (ev && typeof ev === 'object') {
        if (ev.type === 'text' && ev.text) best = ev.text;
        else if (ev.text) best = ev.text;
        else if (ev.part && ev.part.type === 'text' && ev.part.text) best = ev.part.text;
      }
    } catch {}
  }
  if (best) return best;
  // fallback: strip JSON lines
  return stdout.replace(/^\{.*\}\n?/gm, '').trim();
}

const server = http.createServer((req, res) => {
  const auth = req.headers['authorization'] || '';
  if (TOKEN && auth !== `Bearer ${TOKEN}` && auth !== TOKEN) {
    res.writeHead(401, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ error: 'unauthorized' }));
  }

  if (req.method === 'GET' && (req.url === '/health' || req.url === '/')) {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ healthy: true, service: 'opencode-farm', port: PORT }));
  }

  if (req.method === 'GET' && req.url.startsWith('/v1/models')) {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ object: 'list', data: [
      { id: MODEL, object: 'model', owned_by: 'opencode' },
    ]}));
  }

  if (req.method === 'POST' && (req.url === '/v1/chat/completions' || req.url === '/v1/responses' || req.url === '/v1/messages')) {
    let body = '';
    req.on('data', c => { body += c; if (body.length > 4 * 1024 * 1024) req.destroy(); });
    req.on('end', () => {
      let parsed;
      try { parsed = JSON.parse(body); } catch { 
        res.writeHead(400, { 'Content-Type': 'application/json' });
        return res.end(JSON.stringify({ error: 'bad json' }));
      }
      const prompt = promptFromBody(parsed);
      if (!prompt) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        return res.end(JSON.stringify({ error: 'no messages' }));
      }
      const start = Date.now();
      callOpencode(prompt, (err, stdout) => {
        if (err) {
          res.writeHead(502, { 'Content-Type': 'application/json' });
          return res.end(JSON.stringify({ error: err.message.slice(0, 300) }));
        }
        const text = extractText(stdout);
        const usage = { prompt_tokens: 0, completion_tokens: 0, total_tokens: 0 };
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          id: 'chatcmpl-' + Math.random().toString(36).slice(2),
          object: 'chat.completion',
          created: Math.floor(Date.now() / 1000),
          model: MODEL,
          choices: [{ index: 0, message: { role: 'assistant', content: text }, finish_reason: 'stop' }],
          usage,
          _ms: Date.now() - start,
        }));
      });
    });
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'not found', url: req.url }));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`[farm] listening on 0.0.0.0:${PORT} model=${MODEL}`);
});
