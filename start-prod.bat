@echo off
setlocal
set PORT=9002
set NODE_ENV=production
set DB_PATH=%~dp0standalone\balla.sqlite

cd /d %~dp0

REM ÔÛøá ÇáÓíÑÝÑ Ýí ÚãáíÉ ÎáÝíÉ (start) Ëã ÇÝÊÍ ÇáãÊÕÝÍ
start "" /B cmd /c "node standalone\server.js"
REM ÇäÊÙÑ ÈÓíØ
timeout /t 3 /nobreak >nul


endlocal
