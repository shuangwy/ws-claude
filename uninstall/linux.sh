#!/usr/bin/env bash
set -e
echo "Uninstalling ws-claude (global)..."
npm uninstall -g ws-claude || true
echo "Uninstalling @anthropic-ai/claude-code (global)..."
npm uninstall -g @anthropic-ai/claude-code || true
echo "Uninstall complete."

