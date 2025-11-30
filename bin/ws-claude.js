#!/usr/bin/env node
const path = require('path');
const os = require('os');
const chalk = require('chalk');
const prompts = require('prompts');

const { authenticate, ping } = require('../src/auth');
const { runClaude, installLocalPackage } = require('../src/runner');

(async () => {
  try {
    const args = process.argv.slice(2);

    const forceAuth = args.includes('--force-auth');
    const authUrl = process.env.WS_CLAUDE_AUTH_URL || 'http://localhost:4545';

    if (!process.env.WS_CLAUDE_TOKEN || forceAuth) {
      console.log(chalk.gray(`Using auth service: ${authUrl}`));
      const alive = await ping({ baseUrl: authUrl });
      if (!alive) {
        console.log(chalk.yellow('Auth service unreachable, trying login for detailed error'));
      }
      const username = os.userInfo().username;

      let password = process.env.WS_CLAUDE_PASSWORD;
      if (!password) {
        const res = await prompts({
          type: 'password',
          name: 'password',
          message: `Enter password for user ${username}`,
        });
        password = res.password;
      }

      if (!password) {
        console.error(chalk.red('No password provided, aborting authentication'));
        process.exit(1);
      }

      const authRes = await authenticate({ username, password, baseUrl: authUrl });
      const sessionToken = typeof authRes === 'string' ? authRes : (authRes && (authRes.sessionToken || authRes.token || authRes.data));
      if (!sessionToken) {
        console.error(chalk.red('Authentication failed, no token received'));
        process.exit(1);
      }

      process.env.WS_CLAUDE_TOKEN = sessionToken;
      process.env.X_AUTH_SESSION = sessionToken;
      process.env.ANTHROPIC_CUSTOM_HEADERS = `bankid: ${username}\nx-auth-session: ${sessionToken}`;
      console.log(chalk.green('Authentication succeeded, environment prepared'));
    } else {
      console.log(chalk.gray('Existing token detected, skipping auth (use --force-auth to re-auth)'));
    }

    let passThroughArgs = args.filter(a => a !== '--force-auth');

    const installIdx = passThroughArgs.findIndex(a => a === '--install-local');
    if (installIdx !== -1) {
      const tgzPath = passThroughArgs[installIdx + 1];
      passThroughArgs = passThroughArgs.filter((_, i) => i !== installIdx && i !== installIdx + 1);
      if (!tgzPath) {
        console.error(chalk.red('Missing local package path: --install-local <path-to-tgz>'));
        process.exit(1);
      }
      try {
        await installLocalPackage(tgzPath);
        console.log(chalk.green('Local dependency installed successfully'));
      } catch (e) {
        console.error(chalk.red('Failed to install local dependency:'), e.message || e);
        process.exit(1);
      }
    }

    await runClaude(passThroughArgs, { env: process.env });
  } catch (err) {
    console.error(chalk.red('ws-claude error:'), err && err.message ? err.message : err);
    process.exit(1);
  }
})();
