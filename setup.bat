@echo off
setlocal

echo Pruefe Voraussetzungen...

REM --- 1. Pruefe, ob .NET SDK installiert ist ---
where dotnet >nul 2>nul
if %errorlevel% neq 0 (
    echo [FEHLER] .NET SDK nicht gefunden.
    echo Bitte installiere es von hier: https://dotnet.microsoft.com/download
    pause
    exit /b
)
echo .NET SDK: OK

REM --- 2. Pruefe, ob Google Chrome installiert ist ---
reg query "HKEY_CURRENT_USER\Software\Google\Chrome" >nul 2>nul
if %errorlevel% neq 0 (
    echo [FEHLER] Google Chrome nicht gefunden.
    echo Bitte installiere es von hier: https://www.google.com/chrome/
    pause
    exit /b
)
echo Google Chrome: OK

echo.
echo Alle Voraussetzungen erfuellt.
echo Starte die Anwendung jetzt...
echo.
echo =================================================================
echo.

REM --- 3. Starte die C# Anwendung ---
dotnet run --verbosity quiet

echo.
echo =================================================================
echo.
echo Anwendung beendet.
pause