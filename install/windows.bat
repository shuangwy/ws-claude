@echo off
setlocal
set ROOT=%~dp0..
set PKG=%ROOT%\ws-claude-1.0.0.tgz
set CLAUDE=%ROOT%\anthropic-ai-claude-code-2.0.55.tgz

echo [STEP] 1/3 Installing ws-claude
if exist "%PKG%" (
  npm i -g "%PKG%"
) else (
  npm i -g ws-claude
)
if errorlevel 1 echo [WARN] install ws-claude failed

if exist "%CLAUDE%" (
  echo Installing local claude-code package
  ws-claude --install-local "%CLAUDE%"
  if errorlevel 1 echo [WARN] install local claude-code failed
)

set SETTINGS_DIR=%ProgramData%\ClaudeCode
set SETTINGS_FILE=%SETTINGS_DIR%\managed-settings.json
echo [STEP] 2/3 Writing managed settings: %SETTINGS_FILE%
mkdir "%SETTINGS_DIR%" 2>nul

set REAL_USER=
for /f "tokens=2 delims==" %%a in ('wmic computersystem get username /value 2^>nul ^| findstr /b /c:"UserName="') do set REAL_USER=%%a
if not defined REAL_USER for /f "delims=" %%U in ('powershell -NoProfile -Command "(Get-WmiObject Win32_ComputerSystem).UserName"') do set REAL_USER=%%U
if not defined REAL_USER set REAL_USER=%USERNAME%
for /f "tokens=2 delims=\" %%x in ("%REAL_USER%") do set REAL_USER=%%x
(
echo {
echo   "apiKeyHelper": "type %%USERPROFILE%%\\.claude\\token.txt",
echo   "env": {
echo     "ANTHROPIC_BASE_URL": "https://genai-erg-infer.sp.uat.dbs.corp/devai_v3/genai-infer/api/dev/ai/claude",
echo     "DISABLE_PROMPT_CACHING": 1,
echo     "API_TIMEOUT_MS": 120000,
echo     "CLAUDE_CODE_MAX_OUTPUT_TOKENS": 32000,
echo     "MAX_THINKING_TOKENS": 1024,
echo     "CLAUDE_CODE_ENABLE_TELEMETRY": 1,
echo     "OTEL_METRICS_EXPORTER": "otlp",
echo     "OTEL_LOGS_EXPORTER": "otlp",
echo     "OTEL_EXPORTER_OTLP_PROTOCOL": "http/json",
echo     "OTEL_EXPORTER_OTLP_ENDPOINT": "https://genai-infer.sp.uat.dbs.corp/es-agent",
echo     "OTEL_LOG_USER_PROMPTS": "1",
echo     "OTEL_RESOURCE_ATTRIBUTES": "service.name=claude-code,trace.name=%REAL_USER%,host.name=%COMPUTERNAME%",
echo     "OTEL_LOG_EXPORT_INTERVAL": 5000,
echo     "OTEL_METRIC_EXPORT_INTERVAL": 5000,
echo     "OTEL_EXPORTER_OTLP_INSECURE": "true",
echo     "NODE_TLS_REJECT_UNAUTHORIZED": 0
echo   },
echo   "permissions": {
echo     "allow": [],
echo     "deny": [ "WebFetch", "WebSearch" ]
echo   },
echo   "alwaysThinkingEnabled": false,
echo   "companyAnnouncements": [ "That's one small step for Clauding, one GIANT leap for our team's productivity!" ]
echo }
) > "%SETTINGS_FILE%"
if exist "%SETTINGS_FILE%" (
  echo [OK] managed-settings.json created
) else (
  echo [WARN] managed-settings.json missing
)

echo [STEP] 3/3 Ensuring token file
set TARGET_PROFILE=
for /f "delims=" %%P in ('powershell -NoProfile -Command "$u='%REAL_USER%';$acct=Get-WmiObject Win32_UserAccount -Filter \"Name=''$u''\"; if($acct){$sid=$acct.SID; $prof=Get-WmiObject Win32_UserProfile | Where-Object {$_.SID -eq $sid}; if($prof){$prof.LocalPath}}"') do set TARGET_PROFILE=%%P
if not defined TARGET_PROFILE set TARGET_PROFILE=C:\Users\%REAL_USER%
if not exist "%TARGET_PROFILE%\.claude" mkdir "%TARGET_PROFILE%\.claude"
if not exist "%TARGET_PROFILE%\.claude\token.txt" type nul > "%TARGET_PROFILE%\.claude\token.txt"
if exist "%TARGET_PROFILE%\.claude\token.txt" (
  echo [OK] token.txt ready at %TARGET_PROFILE%\.claude\token.txt
) else (
  echo [WARN] failed to create token.txt
)

echo [DONE] Installation completed. Run: ws-claude --verbose
endlocal
