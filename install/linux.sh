#!/usr/bin/env bash
set -e
ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
PKG="$ROOT/ws-claude-1.0.0.tgz"
CLAUDE="$ROOT/anthropic-ai-claude-code-2.0.55.tgz"

echo "Installing ws-claude..."
if [ -f "$PKG" ]; then
  npm i -g "$PKG"
else
  npm i -g ws-claude
fi

if [ -f "$CLAUDE" ]; then
  echo "Installing local claude-code..."
  ws-claude --install-local "$CLAUDE"
fi

echo "Done. Run: ws-claude --verbose"

