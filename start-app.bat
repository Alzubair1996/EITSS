@echo off
setlocal

REM ===== Settings =====
set PORT=9002
set NODE_ENV=production
REM (اختياري) لو تطبيقك يقرأ مسار DB من env:
REM set DB_PATH=C:\QareebStore\balla.sqlite

cd /d "%~dp0"

REM لو ما في build، اعمل build أولاً (ينفع تشيل السطرين لو ما تبيه يبني تلقائي)
if not exist ".next" (
  echo No .next folder found. Running build...
  call npm run build || goto :END
)

REM حاول تشغيل standalone لو موجود
if exist ".next\standalone\server.js" (
  echo Starting standalone server...
  REM مهم: لا نغيّر الـ CWD عشان يلقى .next\static و public
  start "" /min cmd /c "node .next\standalone\server.js"
) else (
  echo standalone server.js not found. Falling back to "next start"...
  start "" /min cmd /c "npm run start -- -p %PORT%"
)

REM انتظر ثم افتح المتصفح
ping 127.0.0.1 -n 5 >nul
start "" "http://localhost:%PORT%"

echo.
echo ✅ Production server launching on http://localhost:%PORT%
echo اضغط Ctrl+C لإيقافه لو فتحت الملف بدون start ^
(لو فتحت النافذة مصغّرة، أغلقها من شريط المهام).
echo.
pause

:END
endlocal
