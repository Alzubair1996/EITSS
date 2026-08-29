@echo off
setlocal

set PORT=9000
set NODE_ENV=production

cd /d %~dp0

REM Title the window so user can identify it
title AdalatPay Server

:START_SERVER
echo [EITSS] Starting server on port %PORT%...

REM Open the browser after a 2-second delay to give the server time to start up
start /b cmd /c "timeout /t 2 /nobreak >nul && start http://localhost:%PORT%"

REM Run the standalone server - node server.js
if exist "server.js" (
  node server.js
) else if exist ".next\standalone\server.js" (
  node .next\standalone\server.js
) else (
  echo [EITSS] Error: server.js not found in current directory or in .next\standalone.
  echo Please make sure you have run the build command first.
  pause
  exit /b 1
)

REM If server exits (e.g. after update), check the exit code:
REM   Exit code 0  = normal shutdown (update applied) → restart automatically
REM   Exit code 1+ = crash → still restart (graceful recovery)
echo [EITSS] Server stopped. Restarting in 3 seconds...
timeout /t 3 /nobreak >nul
goto START_SERVER

endlocal
