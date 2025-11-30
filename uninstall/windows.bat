@echo off
setlocal

echo [STEP] Uninstall ws-claude
npm uninstall -g ws-claude
if errorlevel 1 npm rm -g ws-claude
if errorlevel 1 echo [WARN] npm uninstall failed

set SETTINGS_DIR=%ProgramData%\ClaudeCode
echo [STEP] Remove managed settings directory: %SETTINGS_DIR%
if exist "%SETTINGS_DIR%" (
  rmdir /s /q "%SETTINGS_DIR%"
  if exist "%SETTINGS_DIR%" (
    echo [WARN] failed to remove %SETTINGS_DIR%
  ) else (
    echo [OK] removed %SETTINGS_DIR%
  )
) else (
  echo [INFO] managed settings directory not found
)

set REAL_USER=
for /f "tokens=2 delims==" %%a in ('wmic computersystem get username /value 2^>nul ^| findstr /b /c:"UserName="') do set REAL_USER=%%a
if not defined REAL_USER for /f "delims=" %%U in ('powershell -NoProfile -Command "(Get-WmiObject Win32_ComputerSystem).UserName"') do set REAL_USER=%%U
if not defined REAL_USER set REAL_USER=%USERNAME%
for /f "tokens=2 delims=\" %%x in ("%REAL_USER%") do set REAL_USER=%%x

set TARGET_PROFILE=
for /f "delims=" %%P in ('powershell -NoProfile -Command "$u='%REAL_USER%';$acct=Get-WmiObject Win32_UserAccount -Filter \"Name=''$u''\"; if($acct){$sid=$acct.SID; $prof=Get-WmiObject Win32_UserProfile ^| Where-Object {$_.SID -eq $sid}; if($prof){$prof.LocalPath}}"') do set TARGET_PROFILE=%%P
if not defined TARGET_PROFILE set TARGET_PROFILE=C:\Users\%REAL_USER%
echo [STEP] Remove user files under %TARGET_PROFILE%
if exist "%TARGET_PROFILE%\.claude" (
  rmdir /s /q "%TARGET_PROFILE%\.claude"
)
if exist "%TARGET_PROFILE%\.claude.json" del /f /q "%TARGET_PROFILE%\.claude.json"
if exist "%TARGET_PROFILE%\.claude.json.backup" del /f /q "%TARGET_PROFILE%\.claude.json.backup"
if exist "%TARGET_PROFILE%\.claude" (
  echo [WARN] failed to remove %TARGET_PROFILE%\.claude
) else (
  echo [OK] user .claude artifacts removed
)

echo [DONE] Uninstall completed. ws-claude and managed settings removed.
endlocal
