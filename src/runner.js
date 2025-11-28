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
    console.log(chalk.yellow('[DRY RUN] 已通过认证，将调用 Claude Code：'), args.join(' '));
    return;
  }

  const lib = tryRequireClaude();
  if (lib && typeof lib.run === 'function') {
    try {
      await Promise.resolve(lib.run({ args, env }));
      return;
    } catch (e) {
      console.warn(chalk.yellow('库调用失败，改用 npx 调用 CLI：'), e.message || e);
    }
  }

  const isWin = process.platform === 'win32';
  const cmd = isWin ? 'npx.cmd' : 'npx';
  const npxArgs = ['-y', '@anthropic-ai/claude-code'].concat(args);
  await new Promise((resolve, reject) => {
    console.log(chalk.gray(`调用命令: ${cmd} ${npxArgs.join(' ')}`));
    const child = spawn(cmd, npxArgs, { stdio: 'inherit', env });
    child.on('exit', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`Claude Code 退出码 ${code}`));
    });
    child.on('error', reject);
  });
}

module.exports = { runClaude };
