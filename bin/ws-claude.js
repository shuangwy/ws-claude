#!/usr/bin/env node
const path = require('path');
const os = require('os');
const chalk = require('chalk');
const prompts = require('prompts');

const { authenticate } = require('../src/auth');
const { runClaude } = require('../src/runner');

(async () => {
    try {
        const args = process.argv.slice(2);

        const forceAuth = args.includes('--force-auth');
        const authUrl = process.env.WS_CLAUDE_AUTH_URL || 'http://localhost:4545';

        if (!process.env.WS_CLAUDE_TOKEN || forceAuth) {
            const username = os.userInfo().username;

            let password = process.env.WS_CLAUDE_PASSWORD;
            if (!password) {
                const res = await prompts({
                    type: 'password',
                    name: 'password',
                    message: `为用户 ${username} 输入密码进行认证`,
                });
                password = res.password;
            }

            if (!password) {
                console.error(chalk.red('未提供密码，认证流程终止'));
                process.exit(1);
            }

            const token = await authenticate({ username, password, baseUrl: authUrl });
            if (!token) {
                console.error(chalk.red('认证失败，未获取到令牌'));
                process.exit(1);
            }

            process.env.WS_CLAUDE_TOKEN = token;
            console.log(chalk.green('认证成功，令牌已写入进程环境'));
        } else {
            console.log(chalk.gray('检测到现有令牌，跳过认证（使用 --force-auth 重新认证）'));
        }

        const passThroughArgs = args.filter(a => a !== '--force-auth');
        await runClaude(passThroughArgs, { env: process.env });
    } catch (err) {
        console.error(chalk.red('ws-claude 发生错误：'), err && err.message ? err.message : err);
        process.exit(1);
    }
})();

