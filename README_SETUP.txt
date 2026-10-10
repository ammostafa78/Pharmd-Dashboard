===============================================================
  PharmD KPI Dashboard — Setup & Usage Guide
  College of Pharmacy · Imam Abdulrahman Bin Faisal University
  Prepared by: Quality Management & Academic Accreditation Unit
===============================================================


WHAT IS THIS?
─────────────
This folder contains everything you need to:
  1. Keep your KPI dashboard updated from a single Excel file
  2. Publish it automatically to a live website (GitHub Pages)
  3. Share the link with the Dean, accreditation bodies, or anyone


FILES IN THIS FOLDER
─────────────────────
  KPIs_Database.xlsx        ← Your data source (edit this!)
  convert_kpi.py            ← Automatic converter (do not edit)
  template.html             ← Dashboard design (do not edit)
  docs/index.html           ← Generated dashboard (auto-created)

  Windows scripts (double-click to run):
    0_setup_github.bat      ← ONE-TIME setup (run this first)
    1_update_dashboard.bat  ← UPDATE & PUBLISH (run every time)
    2_preview_locally.bat   ← Preview without publishing

  Mac scripts:
    0_setup_github_mac.sh   ← ONE-TIME setup (run this first)
    1_update_dashboard_mac.sh ← UPDATE & PUBLISH (run every time)


═══════════════════════════════════════════
  QUICK START — FIRST TIME SETUP
═══════════════════════════════════════════

STEP 1: Install required software (one-time)
─────────────────────────────────────────────
A) Python 3 (free)
   → Download: https://www.python.org/downloads/
   → During install: CHECK "Add Python to PATH"

B) Git (free)
   → Windows: https://git-scm.com/downloads
   → Mac: comes with Xcode Command Line Tools (installer auto-runs)

C) GitHub account (free)
   → Sign up: https://github.com/signup


STEP 2: Create GitHub repository
──────────────────────────────────
1. Go to: https://github.com/new
2. Name it: pharmd-dashboard  (or any name you like)
3. Set it to PUBLIC
4. Do NOT add README, .gitignore, or license
5. Click "Create repository"
6. Copy the URL shown (e.g. https://github.com/YOUR-NAME/pharmd-dashboard.git)


STEP 3: Run the setup script
──────────────────────────────
Windows:  Double-click  0_setup_github.bat
Mac:      Double-click  0_setup_github_mac.sh
          (Right-click → Open if Mac blocks it)

Follow the prompts — enter your GitHub username, email, and
paste the repository URL from Step 2.


STEP 4: Enable GitHub Pages
─────────────────────────────
1. Go to your repository on GitHub
2. Click "Settings" (top tab) → "Pages" (left sidebar)
3. Under "Source" select:
      Branch: main
      Folder: /docs
4. Click "Save"
5. Wait 1-2 minutes
6. Your dashboard is now LIVE at:
      https://YOUR-GITHUB-USERNAME.github.io/pharmd-dashboard/


═══════════════════════════════════════════
  DAILY WORKFLOW — UPDATING DATA
═══════════════════════════════════════════

Every time you update your KPI data:

  1. Edit KPIs_Database.xlsx  (add new values, update figures)
  2. Save and close Excel
  3. Double-click 1_update_dashboard.bat  (Windows)
              OR  1_update_dashboard_mac.sh  (Mac)
  4. Wait ~10 seconds
  5. Done! Your live dashboard is updated.

That's it — 3 steps, no coding, no technical knowledge needed.


═══════════════════════════════════════════
  ADDING NEW KPIs TO THE EXCEL FILE
═══════════════════════════════════════════

The Excel file has these columns (do not change column order!):
  A: KPI (full name)
  B: Key Performance Indicator (code, e.g. KPI-24)
  C: Academic Year (e.g. 2024-2025)
  D: Target
  E: Actual (Male)
  F: Actual (Female)
  G: Actual (Combined)
  H: Internal Benchmark
  I: External Benchmark (KFU)
  J: External Benchmark (KSAHS)
  K: New Target

Rules:
  - Write "NA" (not zero) if a benchmark is not available
  - Leave cell empty if gender breakdown doesn't apply
  - Year can be "2024-2025" or just "2024" for research KPIs
  - Add new KPIs at the BOTTOM of the sheet


═══════════════════════════════════════════
  TROUBLESHOOTING
═══════════════════════════════════════════

Problem: "Python is not installed"
Solution: Install Python from python.org — check "Add to PATH"

Problem: "Git is not installed"
Solution: Install Git from git-scm.com (Windows) or run
          xcode-select --install (Mac)

Problem: "Push to GitHub failed"
Solution: - Check internet connection
          - Make sure you ran the setup script first
          - GitHub may ask you to sign in — do so in the browser

Problem: Script opens and closes instantly (Windows)
Solution: Right-click the .bat file → "Run as administrator"

Problem: Mac blocks the .sh file
Solution: Right-click → Open → Open anyway

Problem: Dashboard not updating after push
Solution: GitHub Pages can take 1-2 minutes. Try refreshing
          the URL or clear browser cache (Ctrl+Shift+R)

Problem: New KPI codes not showing in the dashboard
Solution: The converter automatically picks up new rows from Excel.
          If you want a custom short name for a new KPI, send it to
          the Quality Unit to update the convert_kpi.py script.


═══════════════════════════════════════════
  SUPPORT
═══════════════════════════════════════════

For technical issues, contact:
Quality Management & Academic Accreditation Unit
College of Pharmacy · Imam Abdulrahman Bin Faisal University
Prof. Ahmed Mostafa

===============================================================
