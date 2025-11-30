const { spawn } = require('child_process');
const chalk = require('chalk');

function tryRequireClaude() {
  try {
    const mod = require('@anthropic-ai/claude-code');
    return mod;
  } catch (_) {
    return null;
  }
}

async function runClaude(args, { env }) {
  if (process.env.WS_CLAUDE_DRY_RUN === '1') {
    console.log(chalk.yellow('[DRY RUN] Authenticated, invoking Claude Code:'), args.join(' '));
    return;
  }

  const lib = tryRequireClaude();
  if (lib && typeof lib.run === 'function') {
    try {
      await Promise.resolve(lib.run({ args, env }));
      return;
    } catch (e) {
      console.warn(chalk.yellow('Library call failed, falling back to npx CLI:'), e.message || e);
    }
  }

  const isWin = process.platform === 'win32';
  const cmd = isWin ? 'npx.cmd' : 'npx';
  const version = process.env.WS_CLAUDE_VERSION || '2.0.55';
  const pkgSpec = `@anthropic-ai/claude-code@${version}`;
  const npxArgs = ['-y', pkgSpec].concat(args);
  await new Promise((resolve, reject) => {
    console.log(chalk.gray(`Executing: ${cmd} ${npxArgs.join(' ')}`));
    const child = spawn(cmd, npxArgs, { stdio: 'inherit', env });
    child.on('exit', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`Claude Code exit code ${code}`));
    });
    child.on('error', reject);
  });
}

function installLocalPackage(tgzPath) {
  return new Promise((resolve, reject) => {
    const npmCmd = process.platform === 'win32' ? 'npm.cmd' : 'npm';
    const args = ['i', '-g', tgzPath];
    console.log(chalk.gray(`Installing local package: ${npmCmd} ${args.join(' ')}`));
    const p = spawn(npmCmd, args, { stdio: 'inherit' });
    p.on('exit', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`Install failed with exit code ${code}`));
    });
    p.on('error', reject);
  });
}

module.exports = { runClaude, installLocalPackage };
