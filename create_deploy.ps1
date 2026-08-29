param(
  [switch]$IncludeSrc = $false,
  [string]$DeployDir = "deploy",
  [int]$Port = 9000,
  [string]$DbPath = "C:\QareebStore\balla.sqlite"
)

$ErrorActionPreference = "Stop"

# 0) اختياري: ضبط الترميز لتجنّب لخبطة الكونسول
$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 1) بناء إنتاج
npm run build

# 2) إنشاء مجلد التسليم من الصفر
if (Test-Path $DeployDir) { Remove-Item -Recurse -Force $DeployDir }
New-Item -ItemType Directory $DeployDir | Out-Null

# 3) نسخ ملفات التشغيل (standalone + static + public)
robocopy ".next\standalone" "$DeployDir\.next\standalone" /MIR /NFL /NDL | Out-Null
robocopy ".next\static" "$DeployDir\.next\static" /MIR /NFL /NDL | Out-Null
if (Test-Path "public") {
  robocopy "public" "$DeployDir\public" /MIR /NFL /NDL | Out-Null
}

# (اختياري) نسخ src لأغراض المراجعة/الأرشفة - غير مطلوب للتشغيل
if ($IncludeSrc -and (Test-Path "src")) {
  robocopy "src" "$DeployDir\src" /MIR /NFL /NDL | Out-Null
}

# (اختياري) نسخ .env.production إن وُجد
if (Test-Path ".env.production") {
  Copy-Item ".env.production" "$DeployDir\.env.production"
}

# 4) إنشاء start.bat (يشغّل السيرفر الإنتاجي ويفتح المتصفح)
$bat = @"
@echo off
setlocal

REM ===== Settings =====
set PORT=$Port
set NODE_ENV=production

REM Database path (edit if needed)
set DB_PATH=$DbPath

REM Run Next standalone server
cd /d "%~dp0\.next\standalone"
start "" /min cmd /c "node server.js"

REM Small wait to ensure server starts
ping 127.0.0.1 -n 5 >nul

REM Open browser
start "" "http://localhost:%PORT%"

endlocal
"@

$bat | Out-File -Encoding ASCII "$DeployDir\start.bat"

Write-Output "Deploy folder '$DeployDir' is ready. Run start.bat"
