@echo off
setlocal enabledelayedexpansion
title PharmD Dashboard - One-Time GitHub Setup
color 0E

echo.
echo  ============================================
echo   One-Time GitHub Setup Wizard
echo   College of Pharmacy - IAU
echo   (Run this ONCE on each new computer)
echo  ============================================
echo.
echo  Before running this you need:
echo    1. A GitHub account  (https://github.com)
echo    2. Git installed     (https://git-scm.com/downloads)
echo    3. Python installed  (https://www.python.org/downloads)
echo       * Check "Add Python to PATH" during Python install
echo.
pause

REM ── Check Git ────────────────────────────────────────────────────────────────
git --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo  ERROR: Git is not installed.
    echo  Download from: https://git-scm.com/downloads
    echo  Then run this setup again.
    echo.
    pause & exit /b 1
)

REM ── Check Python ─────────────────────────────────────────────────────────────
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo  ERROR: Python is not installed or not in PATH.
    echo  Download from: https://www.python.org/downloads/
    echo  IMPORTANT: Check "Add Python to PATH" during install.
    echo  Then run this setup again.
    echo.
    pause & exit /b 1
)

REM ── Install openpyxl ─────────────────────────────────────────────────────────
echo.
echo  Installing required Python package (openpyxl)...
python -m pip install openpyxl --quiet --break-system-packages 2>nul
python -m pip install openpyxl --quiet 2>nul
echo  Done.

REM ── Git identity ─────────────────────────────────────────────────────────────
echo.
echo  Enter your GitHub username (e.g. ammostafa78):
set /p GH_USER="> "

echo.
echo  Enter the email linked to your GitHub account:
set /p GH_EMAIL="> "

echo.
echo  Enter your GitHub repository name (e.g. Pharmd-Dashboard):
set /p REPO_NAME="> "

echo.
git config --global user.name "!GH_USER!"
git config --global user.email "!GH_EMAIL!"
echo  Git identity configured.

REM ── Initialise local repo ────────────────────────────────────────────────────
if not exist ".git" (
    echo.
    echo  Initializing local repository...
    git init
    git branch -M main
) else (
    echo.
    echo  Local repository already exists - skipping init.
)

REM ── GitHub repo URL ──────────────────────────────────────────────────────────
echo.
echo  ============================================
echo   Paste your GitHub repository URL below.
echo   It looks like:
echo     https://github.com/!GH_USER!/!REPO_NAME!.git
echo.
echo   (NOT the github.io website URL)
echo  ============================================
echo.
set /p REPO_URL="> "

REM ── Validate URL ─────────────────────────────────────────────────────────────
echo !REPO_URL! | findstr /i "github.io" >nul
if not errorlevel 1 (
    echo.
    echo  WARNING: That looks like a GitHub Pages URL, not a repository URL.
    echo  The correct URL starts with: https://github.com/
    echo  and ends with: .git
    echo.
    echo  Please re-enter the correct repository URL:
    set /p REPO_URL="> "
)

REM ── Set remote ───────────────────────────────────────────────────────────────
git remote remove origin >nul 2>&1
git remote add origin !REPO_URL!

REM ── Create docs folder if missing ────────────────────────────────────────────
if not exist "docs" mkdir docs

REM ── Stage everything ─────────────────────────────────────────────────────────
echo.
echo  Preparing files...
git add .
git commit --allow-empty -m "Initial dashboard setup"

REM ── Sync with GitHub ─────────────────────────────────────────────────────────
echo.
echo  Syncing with GitHub...
git pull --rebase origin main >nul 2>&1

echo.
echo  Pushing to GitHub...
git push -u origin main
if errorlevel 1 (
    echo.
    echo  First push failed - trying with force...
    git push -u origin main --force
    if errorlevel 1 (
        echo.
        echo  ERROR: Could not push to GitHub.
        echo  A browser window may open asking you to sign in.
        echo  Sign in, then run this setup script again.
        echo.
        pause & exit /b 1
    )
)

REM ── GitHub Pages instructions ─────────────────────────────────────────────────
echo.
echo  ============================================
echo   FINAL STEP: Enable GitHub Pages
echo  ============================================
echo.
echo  1. Open this link in your browser:
echo     https://github.com/!GH_USER!/!REPO_NAME!/settings/pages
echo.
echo  2. Under "Source" select:
echo       Branch: main
echo       Folder: /docs
echo.
echo  3. Click Save.
echo.
echo  4. Wait 2 minutes. Your dashboard will be at:
echo     https://!GH_USER!.github.io/!REPO_NAME!/
echo.
echo  ============================================
echo   Setup complete!
echo   From now on, just double-click:
echo     1_update_dashboard.bat
echo  ============================================
echo.
pause
