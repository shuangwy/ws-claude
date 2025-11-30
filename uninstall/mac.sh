#!/usr/bin/env bash
set +e

echo "[STEP] Uninstall ws-claude"
npm uninstall -g ws-claude || npm rm -g ws-claude || true

SETTINGS_DIR="/Library/Application Support/ClaudeCode"
echo "[STEP] Remove managed settings directory: $SETTINGS_DIR"
rm -rf "$SETTINGS_DIR" || true
if [ -d "$SETTINGS_DIR" ]; then
  echo "[WARN] failed to remove $SETTINGS_DIR"
else
  echo "[OK] removed $SETTINGS_DIR"
fi

CURRENT_USER="$([ -x /usr/bin/stat ] && /usr/bin/stat -f %Su /dev/console 2>/dev/null || true)"
if [ -z "$CURRENT_USER" ] || [ "$CURRENT_USER" = "root" ]; then
  CURRENT_USER="$([ -x /usr/bin/logname ] && /usr/bin/logname 2>/dev/null || echo "$USER")"
fi
CURRENT_HOME=$(eval echo "~$CURRENT_USER")
echo "[STEP] Remove user files under $CURRENT_HOME"
rm -rf "$CURRENT_HOME/.claude" || true
rm -f "$CURRENT_HOME/.claude.json" "$CURRENT_HOME/.claude.json.backup" || true
if [ -d "$CURRENT_HOME/.claude" ] || [ -f "$CURRENT_HOME/.claude.json" ] || [ -f "$CURRENT_HOME/.claude.json.backup" ]; then
  echo "[WARN] failed to remove user artifacts"
else
  echo "[OK] user .claude artifacts removed"
fi

echo "[DONE] Uninstall completed. ws-claude and managed settings removed."
