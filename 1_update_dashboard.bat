@echo off
setlocal enabledelayedexpansion
title PharmD KPI Dashboard Updater
color 0A

echo.
echo  ============================================
echo   PharmD KPI Dashboard Updater
echo   College of Pharmacy - IAU
echo  ============================================
echo.

REM ── Check Python ─────────────────────────────────────────────────────────────
python --version >nul 2>&1
if errorlevel 1 (
    echo  ERROR: Python is not installed or not in PATH.
    echo  Install from: https://www.python.org/downloads/
    echo  IMPORTANT: Check "Add Python to PATH" during install.
    echo.
    pause & exit /b 1
)

REM ── Check Git ────────────────────────────────────────────────────────────────
git --version >nul 2>&1
if errorlevel 1 (
    echo  ERROR: Git is not installed.
    echo  Download from: https://git-scm.com/downloads
    echo.
    pause & exit /b 1
)

REM ── Check this is a Git repo ─────────────────────────────────────────────────
if not exist ".git" (
    echo  ERROR: Not connected to GitHub yet.
    echo  Please run 0_setup_github.bat first!
    echo.
    pause & exit /b 1
)

REM ── Install openpyxl if needed ───────────────────────────────────────────────
python -c "import openpyxl" >nul 2>&1
if errorlevel 1 (
    echo  Installing required Python package (openpyxl)...
    python -m pip install openpyxl --quiet --break-system-packages 2>nul
    python -m pip install openpyxl --quiet 2>nul
)

REM ══════════════════════════════════════════════════════════════════════════════
REM  STEP 1 — Find the Excel file
REM  Priority: 1) drag-drop  2) KPIs_Database.xlsx in folder  3) ask user
REM ══════════════════════════════════════════════════════════════════════════════

set "XLSX_FILE="

if not "%~1"=="" (
    if exist "%~1" (
        set "XLSX_FILE=%~1"
        echo  Using dragged file: %~1
    )
)

if "!XLSX_FILE!"=="" (
    if exist "KPIs_Database.xlsx" (
        set "XLSX_FILE=KPIs_Database.xlsx"
        echo  Using: KPIs_Database.xlsx
    )
)

if "!XLSX_FILE!"=="" (
    echo  No Excel file found in this folder.
    echo.
    echo  Options:
    echo    A) Drag your Excel file onto 1_update_dashboard.bat
    echo    B) Copy your Excel file into this folder as KPIs_Database.xlsx
    echo    C) Type the full path below
    echo.
    set /p XLSX_FILE="  Path to Excel file: "
    if not exist "!XLSX_FILE!" (
        echo.
        echo  ERROR: File not found.
        pause & exit /b 1
    )
)

echo.

REM ── Copy Excel into folder ───────────────────────────────────────────────────
copy /Y "!XLSX_FILE!" "KPIs_Database.xlsx" >nul 2>&1

REM ══════════════════════════════════════════════════════════════════════════════
REM  STEP 2 — Convert Excel to Dashboard HTML
REM ══════════════════════════════════════════════════════════════════════════════
echo  [1/3] Converting Excel to Dashboard HTML...
python convert_kpi.py KPIs_Database.xlsx
if errorlevel 1 (
    echo.
    echo  ERROR: Conversion failed. See message above.
    pause & exit /b 1
)

REM ══════════════════════════════════════════════════════════════════════════════
REM  STEP 3 — Commit ALL files and push to GitHub
REM ══════════════════════════════════════════════════════════════════════════════
echo.
echo  [2/3] Saving to GitHub...

git add docs\index.html KPIs_Database.xlsx convert_kpi.py template.html

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value 2^>nul') do set "dt=%%a"
if defined dt (
    set "STAMP=%dt:~0,4%-%dt:~4,2%-%dt:~6,2% %dt:~8,2%:%dt:~10,2%"
) else (
    set "STAMP=update"
)
git commit --allow-empty -m "Dashboard update !STAMP!"
if errorlevel 1 (
    echo.
    echo  ERROR: Git commit failed.
    pause & exit /b 1
)

echo.
echo  [3/3] Publishing to GitHub Pages...
git pull --rebase origin main >nul 2>&1
git push origin main
if errorlevel 1 (
    echo.
    echo  ERROR: Push to GitHub failed.
    echo  Check your internet connection and try again.
    echo.
    pause & exit /b 1
)

echo.
echo  ============================================
echo   SUCCESS! Dashboard published.
echo  ============================================
echo.
for /f %%u in ('git remote get-url origin 2^>nul') do set "REMOTE=%%u"
if defined REMOTE (
    echo  Repository: !REMOTE!
    REM Build GitHub Pages URL from repo URL
    set "PAGES_URL=!REMOTE!"
    set "PAGES_URL=!PAGES_URL:https://github.com/=https://!"
    set "PAGES_URL=!PAGES_URL:.git=!"
    for /f "tokens=1,2 delims=/" %%a in ("!PAGES_URL:https://=!") do (
        set "GH_USER=%%a"
        set "GH_REPO=%%b"
    )
    echo  Live dashboard: https://!GH_USER!.github.io/!GH_REPO!/
)
echo.
echo  (Wait 1-2 minutes then refresh your browser)
echo.
pause
