from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    "SKILL.md", "manifest.yaml", "agents/openai.yaml",
    "assets/R/polisci_theme.R", "assets/R/polisci_tables.R",
    "assets/latex/preamble.tex", "references/apsr-style.md",
    "references/ajps-style.md", "references/qa-contract.md",
]


def main() -> None:
    missing = [name for name in REQUIRED if not (ROOT / name).exists()]
    if missing:
        raise SystemExit("Missing: " + ", ".join(missing))
    skill = (ROOT / "SKILL.md").read_text(encoding="utf-8")
    for interface in ("theme_apsr", "theme_ajps", "save_polisci_figure", "table_apsr", "table_ajps"):
        if interface not in skill:
            raise SystemExit(f"Stable interface absent from SKILL.md: {interface}")
    report = {"status": "ok", "required_files": len(REQUIRED), "stable_interfaces": 5}
    (ROOT / "validation-report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps(report))


if __name__ == "__main__":
    main()
