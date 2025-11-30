const axios = require('axios');

async function authenticate({ username, password, baseUrl }) {
  const url = `${baseUrl.replace(/\/$/, '')}/auth/login`;
  try {
    const resp = await axios.post(
      url,
      { username, password },
      { timeout: 10000, headers: { 'Content-Type': 'application/json' } }
    );
    if (resp && resp.data) {
      if (resp.data && resp.data.data && resp.data.data.sessionToken) {
        return { sessionToken: resp.data.data.sessionToken };
      }
      if (resp.data.token) return { sessionToken: resp.data.token };
      if (resp.data.data) return resp.data.data;
    }
  } catch (e) {
    // fallthrough to HTTP fallback
  }

  // Fallback: use Node http/https in case axios is blocked by environment
  const { URL } = require('url');
  const parsed = new URL(url);
  const isHttps = parsed.protocol === 'https:';
  const mod = isHttps ? require('https') : require('http');

  const payload = JSON.stringify({ username, password });
  const options = {
    hostname: parsed.hostname,
    port: Number(parsed.port || (isHttps ? 443 : 80)),
    path: parsed.pathname,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(payload),
    },
  };

  return await new Promise((resolve) => {
    const req = mod.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data || '{}');
          const st = (parsed && parsed.data && parsed.data.sessionToken) || parsed.token || parsed.data;
          resolve(st ? { sessionToken: st } : null);
        } catch (_) {
          resolve(null);
        }
      });
    });
    req.on('error', () => resolve(null));
    req.write(payload);
    req.end();
  });
}

module.exports = { authenticate };

async function ping({ baseUrl }) {
  const url = `${baseUrl.replace(/\/$/, '')}/auth/ping`;
  try {
    const resp = await axios.get(url, { timeout: 3000 });
    return !!(resp && resp.data && (resp.data.ok === true || resp.status === 200));
  } catch (_) {
    return false;
  }
}

module.exports.ping = ping;
