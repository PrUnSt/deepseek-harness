@echo off
title DeepSeek Harness
cd /d "%~dp0"

echo ============================================
echo   DeepSeek Harness
echo ============================================
echo.

:: Find pnpm
where pnpm >nul 2>&1
if errorlevel 1 (
    set "PATH=C:\Users\Administrator\AppData\Roaming\npm;%PATH%"
)
where pnpm >nul 2>&1
if errorlevel 1 (
    echo [X] pnpm not found
    echo     Run: npm install -g pnpm@11.7.0
    goto :end
)

:: Install deps if needed
if not exist "node_modules" (
    echo [1/2] Installing dependencies...
    call pnpm install
    if errorlevel 1 goto :end
    echo [2/2] Building...
    call pnpm run build
    if errorlevel 1 goto :end
    echo.
)

:: Kill stale process on port 3080
netstat -ano | findstr ":3080 " | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo Port 3080 busy, killing...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3080 " ^| findstr "LISTENING"') do taskkill /F /PID %%a >nul 2>&1
    timeout /t 2 /nobreak >nul
)

echo Starting web server...
echo Open browser: http://127.0.0.1:3080
echo Press Ctrl+C to stop.
echo.
call pnpm dsh --profile web

:end
echo.
pause
