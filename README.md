# ws-claude

A secure CLI wrapper for Anthropic Claude Code that adds HTTP-based authentication and environment header injection.

## Features

-   Pre-run authentication against `/auth/login` and auto-injects `WS_CLAUDE_TOKEN`, `X_AUTH_SESSION`, `ANTHROPIC_CUSTOM_HEADERS`
-   Library-first execution via `@anthropic-ai/claude-code` with automatic fallback to `npx @anthropic-ai/claude-code`
-   Local package install support via `--install-local <path-to-tgz>`
-   Diagnostics helpers: `WS_CLAUDE_DEBUG_ENV=1` prints injected headers, `WS_CLAUDE_DRY_RUN=1` performs dry-run

## Installation

```bash
npm i -g ws-claude
# Or from the repo root
npm pack && npm i -g ./ws-claude-*.tgz
```

## Usage

```bash
# Start (default auth service http://localhost:4545)
ws-claude [Claude Code original args]

# Force re-authentication
ws-claude --force-auth [Claude Code original args]

# Install a local tgz dependency
ws-claude --install-local ./path/to/pkg.tgz
```

Execution flow:

1. If `WS_CLAUDE_TOKEN` is missing or `--force-auth` is set, call `/auth/login`
2. On success, set `WS_CLAUDE_TOKEN`, `X_AUTH_SESSION`, and `ANTHROPIC_CUSTOM_HEADERS` (includes `bankid` and `x-auth-session`)
3. Prefer library mode: `@anthropic-ai/claude-code` `run({ args, env })`
4. If library call fails, fallback to `npx @anthropic-ai/claude-code@WS_CLAUDE_VERSION`

## Environment Variables

-   `WS_CLAUDE_AUTH_URL`: Auth service URL, default `http://localhost:4545`
-   `WS_CLAUDE_PASSWORD`: Auth password (prompted if not provided)
-   `WS_CLAUDE_TOKEN`: Existing session token (skips login)
-   `WS_CLAUDE_VERSION`: Claude Code version, default `2.0.55`
-   `WS_CLAUDE_DEBUG_ENV`: When `1`, prints injected headers
-   `WS_CLAUDE_DRY_RUN`: When `1`, performs a dry-run without invoking Claude Code

## Examples

```bash
# Use custom auth service and enable debug
WS_CLAUDE_AUTH_URL=https://auth.example.com \
WS_CLAUDE_DEBUG_ENV=1 \
ws-claude --force-auth -- --help

# Dry-run (no actual Claude Code invocation)
WS_CLAUDE_DRY_RUN=1 ws-claude
```

## Runtime Requirements

-   Node.js >= 14
-   `@anthropic-ai/claude-code` (optional in library mode; CLI fallback retrieved via `npx`)

## Testing

```bash
npm test
```

## License

MIT License. See `LICENSE`.
