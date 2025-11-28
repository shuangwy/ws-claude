const { spawn } = require('child_process');

function run() {
  const env = Object.assign({}, process.env, {
    WS_CLAUDE_AUTH_URL: 'http://localhost:4545',
    WS_CLAUDE_PASSWORD: 'shuangwang',
    WS_CLAUDE_DRY_RUN: '1',
  });

  const child = spawn('node', ['bin/ws-claude.js'], { env });
  child.stdout.on('data', (d) => process.stdout.write(d));
  child.stderr.on('data', (d) => process.stderr.write(d));

  child.on('exit', (code) => {
    if (code === 0) {
      console.log('CLI test passed');
      process.exit(0);
    } else {
      console.error('CLI test failed with code', code);
      process.exit(code);
    }
  });
}

run();
