@echo off
setlocal
set "SEVEN_ZIP=C:\Program Files\7-Zip\7z.exe"
cd /d "%~dp0"

if not exist "publish" mkdir "publish"
if exist "publish\portal.zip" del /f /q "publish\portal.zip"

"%SEVEN_ZIP%" a -mx=9 "publish\portal.zip" "upgrade.sql" "w4cashPortal\*" "w4cashWebPOS\*"

if errorlevel 1 (
    echo Publish failed: 7z exited with error.
    exit /b 1
)

echo Publish OK: publish\portal.zip
endlocal
exit /b 0
