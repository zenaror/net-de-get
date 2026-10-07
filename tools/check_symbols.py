#!/usr/bin/env python3
"""Check emitted sections and stable entry symbols against the maintained manifest."""
import argparse
from pathlib import Path
from excerpt_checks import check_layout, read_manifest

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('map', type=Path)
p.add_argument('sym', type=Path)
a = p.parse_args()
repo = Path(__file__).resolve().parents[1]
try:
    entries = read_manifest(repo / 'config/excerpts.tsv')
    sections = check_layout(a.map.read_text(), a.sym.read_text(), entries)
except ValueError as error:
    raise SystemExit(str(error))
print(f'PASS layout and entry symbols: {len(sections)} sections')
