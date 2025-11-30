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

SETTINGS_DIR="/Library/Application Support/ClaudeCode"
SETTINGS_FILE="$SETTINGS_DIR/managed-settings.json"
CURRENT_USER="$([ -x /usr/bin/stat ] && /usr/bin/stat -f %Su /dev/console 2>/dev/null || true)"
if [ -z "$CURRENT_USER" ] || [ "$CURRENT_USER" = "root" ]; then
  CURRENT_USER="$([ -x /usr/bin/logname ] && /usr/bin/logname 2>/dev/null || echo "$USER")"
fi
HOST_NAME="$([ -x /bin/hostname ] && /bin/hostname 2>/dev/null || hostname)"
echo "Configuring managed settings at: $SETTINGS_FILE"
mkdir -p "$SETTINGS_DIR"
tee "$SETTINGS_FILE" >/dev/null <<JSON
{
  "apiKeyHelper": "echo | cat ~/.claude/token.txt",
  "env": {
    "ANTHROPIC_BASE_URL": "https://genai-erg-infer.sp.uat.dbs.corp/devai_v3/genai-infer/api/dev/ai/claude",
    "DISABLE_PROMPT_CACHING": 1,
    "API_TIMEOUT_MS": 120000,
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": 32000,
    "MAX_THINKING_TOKENS": 1024,
    "CLAUDE_CODE_ENABLE_TELEMETRY": 1,
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "http/json",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "https://genai-infer.sp.uat.dbs.corp/es-agent",
    "OTEL_LOG_USER_PROMPTS": "1",
    "OTEL_RESOURCE_ATTRIBUTES": "service.name=claude-code,trace.name=$CURRENT_USER,host.name=$HOST_NAME",
    "OTEL_LOG_EXPORT_INTERVAL": 5000,
    "OTEL_METRIC_EXPORT_INTERVAL": 5000,
    "OTEL_EXPORTER_OTLP_INSECURE": "true",
    "NODE_TLS_REJECT_UNAUTHORIZED": 0
  },
  "permissions": {
    "allow": [],
    "deny": ["WebFetch", "WebSearch"]
  },
  "alwaysThinkingEnabled": false,
  "companyAnnouncements": [
    "That's one small step for Clauding, one GIANT leap for our team's productivity!"
  ]
}
JSON

# create token file in the target user's home
CURRENT_HOME=$(eval echo "~$CURRENT_USER")
CLAUDE_DIR="$CURRENT_HOME/.claude"
mkdir -p "$CLAUDE_DIR"
if [ ! -f "$CLAUDE_DIR/token.txt" ]; then
  : > "$CLAUDE_DIR/token.txt"
fi

echo "Done. Run: ws-claude --verbose"
