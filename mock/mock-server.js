const http = require('http');
const os = require('os');
const crypto = require('crypto');

const PORT = process.env.WS_TEST_PORT ? Number(process.env.WS_TEST_PORT) : 4545;

const server = http.createServer((req, res) => {
    const { method, url } = req;
    if (method === 'POST' && url === '/auth/login') {
        let body = '';
        req.on('data', (chunk) => (body += chunk));
        req.on('end', () => {
            try {
                const data = JSON.parse(body || '{}');
                const { username, password } = data;
                const user = username || os.userInfo().username;
                if (!password) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ data: null }));
                    return;
                }

                const ok = String(password) === 'shuangwang';
                if (!ok) {
                    res.writeHead(401, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ data: null }));
                    return;
                }

                const token = Array.from(crypto.randomBytes(16))
                    .map((b) => String(b % 10))
                    .join('');

                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(
                    JSON.stringify({
                        status: 200,
                        message: 'user login success',
                        data: { sessionToken: token },
                        bcode: null,
                    })
                );
            } catch (e) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ data: null }));
            }
        });
        return;
    }

    if (method === 'GET' && url === '/auth/ping') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ ok: true }));
        return;
    }

    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'not found' }));
});

server.listen(PORT, () => {
    console.log(`Mock auth server listening on http://localhost:${PORT}`);
});
