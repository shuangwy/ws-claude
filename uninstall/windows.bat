@echo off
setlocal
echo Uninstalling ws-claude (global)...
npm uninstall -g ws-claude
echo Uninstalling @anthropic-ai/claude-code (global)...
npm uninstall -g @anthropic-ai/claude-code
echo Uninstall complete.
endlocal

