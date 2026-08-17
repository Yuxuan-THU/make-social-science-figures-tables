from __future__ import annotations

import argparse
import shutil
import subprocess
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input_dir", type=Path)
    parser.add_argument("--xelatex", default="xelatex")
    args = parser.parse_args()
    skill = Path(__file__).resolve().parents[1]
    preamble = (skill / "assets" / "latex" / "preamble.tex").read_text(encoding="utf-8")
    failures = []
    for snippet in sorted(args.input_dir.rglob("*.tex")):
        if snippet.name.startswith("standalone-"):
            continue
        wrapper = snippet.with_name(f"standalone-{snippet.stem}.tex")
        wrapper.write_text("\\documentclass[10pt]{article}\n" + preamble + "\n\\begin{document}\n" + f"\\input{{{snippet.name}}}\n\\end{{document}}\n", encoding="utf-8")
        completed = None
        for _ in range(2):
            completed = subprocess.run([args.xelatex, "-interaction=nonstopmode", "-halt-on-error", wrapper.name], cwd=snippet.parent, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, encoding="utf-8", errors="replace")
            if completed.returncode:
                break
        if completed is not None and completed.returncode:
            failures.append((snippet, completed.stdout[-1800:]))
    if failures:
        for path, output in failures:
            print(f"FAILED {path}\n{output}")
        raise SystemExit(1)
    print(f"Compiled {len(list(args.input_dir.rglob('standalone-*.pdf')))} table PDFs")


if __name__ == "__main__":
    main()
