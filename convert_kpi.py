#!/usr/bin/env python3
"""
convert_kpi.py  —  PharmD KPI Dashboard Builder
College of Pharmacy · Imam Abdulrahman Bin Faisal University

Usage:  python convert_kpi.py [path/to/KPIs_Database.xlsx]
Output: docs/index.html  (ready for GitHub Pages)
"""

import os, sys, re, json, datetime
import openpyxl

# ── Column indices (0-based) ──────────────────────────────────────────────────
COL_NAME   = 0   # A: KPI full name
COL_CODE   = 1   # B: KPI code  (KPI-01 …)
COL_YEAR   = 2   # C: Academic year
COL_TARGET = 3   # D: Target
COL_MALE   = 4   # E: Actual Male
COL_FEMALE = 5   # F: Actual Female
COL_COMB   = 6   # G: Actual Combined
COL_INT    = 7   # H: Internal benchmark
COL_EXT1   = 8   # I: External benchmark KFU
COL_EXT2   = 9   # J: External benchmark KSAHS

# ── Short display names for sidebar / charts ─────────────────────────────────
SHORT = {
    "KPI-01":  "Learning Experience",
    "KPI-02":  "Course Quality",
    "KPI-03":  "Completion Rate",
    "KPI-04":  "Retention Rate",
    "KPI-05":  "Exam Performance",
    "KPI-06-A":"Graduate Employment",
    "KPI-06-B":"Postgrad Enrollment",
    "KPI-07":  "Employer Evaluation",
    "KPI-08":  "Student:Staff Ratio",
    "KPI-09":  "Faculty Publications",
    "KPI-10":  "Research Rate",
    "KPI-11":  "Citations Rate",
    "KPI-12":  "Student Publications",
    "KPI-13":  "Conference Presentations",
    "KPI-14":  "Partnerships & MoUs",
    "KPI-15":  "Student Community Service",
    "KPI-16":  "Faculty Community Service",
    "KPI-17":  "PD Satisfaction",
    "KPI-18":  "Faculty Lecturing Skills",
    "KPI-19":  "Training Sites",
    "KPI-20":  "Field Experience",
    "KPI-21":  "Extracurricular Activities",
    "KPI-22":  "Faculty Job Satisfaction",
    "KPI-23":  "Faculty Attrition Rate",
}

# ── Value parser ──────────────────────────────────────────────────────────────
def parse_num(v):
    """Return float or None. Handles NA strings, time objects, ratio strings."""
    if v is None:
        return None
    if isinstance(v, (int, float)):
        return float(v)
    if isinstance(v, datetime.time):
        # e.g. 6:01 stored as time → 6.1
        return v.hour + v.minute / 100.0
    s = str(v).strip()
    if s.upper() in ("NA", "N/A", ""):
        return None
    # ratio like "6.3:1"
    m = re.match(r"^([\d.]+)\s*:\s*[\d.]+$", s)
    if m:
        return float(m.group(1))
    try:
        return float(s)
    except ValueError:
        return None

# ── Year normaliser ───────────────────────────────────────────────────────────
# Academic years: integers like 2024 → "2024-2025"
# Calendar years (KPI-09/10/11): kept as strings like "2024"
# Typos like "2024-2026" → corrected to nearest valid academic year
ACADEMIC_YEAR_RE = re.compile(r"^(\d{4})-(\d{4})$")

def normalize_year(raw, code):
    """
    Returns a clean year string.
    - Valid academic year  (e.g. '2024-2025')  → kept as-is
    - Integer year + research KPI (09/10/11)   → kept as string e.g. '2024'
    - Integer year + other KPI                 → expanded to 'YYYY-YYYY+1'
    - Typo academic year (end - start != 1)    → fixed
    """
    research_kpis = {"KPI-09", "KPI-10", "KPI-11"}

    # Already a proper academic year string?
    if isinstance(raw, str):
        m = ACADEMIC_YEAR_RE.match(raw.strip())
        if m:
            start, end = int(m.group(1)), int(m.group(2))
            if end - start == 1:
                return raw.strip()
            else:
                # typo like 2024-2026 → use start year
                if code in research_kpis:
                    return str(start)
                return f"{start}-{start+1}"
        # plain string number?
        try:
            yr = int(raw.strip())
            if code in research_kpis:
                return str(yr)
            return f"{yr}-{yr+1}"
        except ValueError:
            return raw.strip()

    # Integer or float from Excel
    if isinstance(raw, (int, float)):
        yr = int(raw)
        if code in research_kpis:
            return str(yr)
        return f"{yr}-{yr+1}"

    return str(raw)

# ── Excel reader ──────────────────────────────────────────────────────────────
def read_excel(path):
    wb = openpyxl.load_workbook(path, data_only=True)
    ws = wb.active
    rows = []
    for i, raw in enumerate(ws.iter_rows(min_row=2, values_only=True), start=2):
        code = str(raw[COL_CODE]).strip() if raw[COL_CODE] else None
        if not code or not code.startswith("KPI"):
            continue
        name  = str(raw[COL_NAME]).strip().replace("\n", " ") if raw[COL_NAME] else code
        # collapse multiple spaces
        name  = re.sub(r"\s+", " ", name)
        short = SHORT.get(code, code)
        year  = normalize_year(raw[COL_YEAR], code)
        rows.append({
            "n":  name,
            "s":  short,
            "c":  code,
            "y":  year,
            "t":  parse_num(raw[COL_TARGET]),
            "m":  parse_num(raw[COL_MALE]),
            "f":  parse_num(raw[COL_FEMALE]),
            "x":  parse_num(raw[COL_COMB]),
            "i":  parse_num(raw[COL_INT]),
            "e1": parse_num(raw[COL_EXT1]),
            "e2": parse_num(raw[COL_EXT2]),
        })
    return rows

# ── JS serialiser ─────────────────────────────────────────────────────────────
def to_js(v):
    if v is None:
        return "null"
    if isinstance(v, float):
        return str(round(v, 4))
    return json.dumps(v)

def rows_to_js(rows):
    parts = []
    for r in rows:
        parts.append(
            "{" +
            f"n:{to_js(r['n'])},s:{to_js(r['s'])},c:{to_js(r['c'])},"
            f"y:{to_js(r['y'])},t:{to_js(r['t'])},m:{to_js(r['m'])},"
            f"f:{to_js(r['f'])},x:{to_js(r['x'])},i:{to_js(r['i'])},"
            f"e1:{to_js(r['e1'])},e2:{to_js(r['e2'])}" +
            "}"
        )
    return "[\n" + ",\n".join(parts) + "\n]"

# ── HTML injector ─────────────────────────────────────────────────────────────
RAW_PATTERN = re.compile(r"const RAW\s*=\s*\[[\s\S]*?\];", re.MULTILINE)

def inject(template_html, raw_js):
    replacement = f"const RAW = {raw_js};"
    # Use a lambda to avoid regex back-reference interpretation of the replacement string
    new_html, n = RAW_PATTERN.subn(lambda m: replacement, template_html)
    if n == 0:
        raise ValueError("Could not find 'const RAW = [...]' in template.html")
    return new_html

# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Find Excel file
    if len(sys.argv) > 1:
        xlsx_path = sys.argv[1]
    else:
        xlsx_path = os.path.join(script_dir, "KPIs_Database.xlsx")

    if not os.path.exists(xlsx_path):
        print(f"ERROR: Excel file not found: {xlsx_path}")
        sys.exit(1)

    template_path = os.path.join(script_dir, "template.html")
    if not os.path.exists(template_path):
        print(f"ERROR: template.html not found in {script_dir}")
        sys.exit(1)

    out_dir  = os.path.join(script_dir, "docs")
    out_path = os.path.join(out_dir, "index.html")
    os.makedirs(out_dir, exist_ok=True)

    print(f"Reading: {os.path.basename(xlsx_path)}")
    rows = read_excel(xlsx_path)
    print(f"  → {len(rows)} data rows")

    # Report years found
    years = sorted(set(r["y"] for r in rows))
    print(f"  → Years: {years}")

    print("Building dashboard...")
    with open(template_path, "r", encoding="utf-8") as f:
        tmpl = f.read()

    raw_js   = rows_to_js(rows)
    out_html = inject(tmpl, raw_js)

    with open(out_path, "w", encoding="utf-8") as f:
        f.write(out_html)

    print(f"  → Saved: docs/index.html")
    print()
    print("=" * 50)
    print("  Done! Now run 1_update_dashboard.bat to publish.")
    print("=" * 50)

if __name__ == "__main__":
    main()
