#!/usr/bin/env python3
"""Assemble explicit RGBDS sources and compare their sections to a read-only ROM."""
import argparse
import hashlib
from pathlib import Path
from excerpt_checks import check_layout, compare_sections, read_manifest
import subprocess
import tempfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('reference_rom', type=Path)
a = p.parse_args()
rom = a.reference_rom.read_bytes()
expected = '9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63'
if hashlib.sha256(rom).hexdigest() != expected:
    raise SystemExit('Unexpected reference ROM hash')
repo = Path(__file__).resolve().parents[1]
root = Path(tempfile.mkdtemp(prefix='netdeget-excerpt-equivalence-'))
sources = sorted(src for domain in ('home', 'engine', 'data')
                 for src in (repo / domain).rglob('*.asm'))
if not sources:
    raise SystemExit('No excerpt sources found')
objects = []
for n, src in enumerate(sources):
    obj = root / f'{n}.o'
    subprocess.run(['rgbasm', '-I', str(repo) + '/', '-P', str(repo / 'includes.asm'),
                    '-o', str(obj), str(src)], check=True)
    objects.append(str(obj))
out, mp, sym = (root / f'excerpts.{ext}' for ext in ('gb', 'map', 'sym'))
subprocess.run(['rgblink', '-p', '0', '-o', str(out), '-m', str(mp), '-n', str(sym), *objects], check=True)
try:
    entries = read_manifest(repo / 'config/excerpts.tsv')
    sections = check_layout(mp.read_text(), sym.read_text(), entries)
    count = compare_sections(out.read_bytes(), rom, sections)
except ValueError as error:
    raise SystemExit(str(error))
for bank, start, end in sections:
    print(f'PASS equivalent: RGBDS {bank:02X}:{start:04X}-{end:04X} ({end - start + 1} bytes)')
print(f'Compared {len(sections)} sections, {count} bytes; padding was not compared')
if hashlib.sha256(a.reference_rom.read_bytes()).hexdigest() != expected:
    raise SystemExit('Reference ROM hash changed')
print(f'Explicit source section comparison; artifacts: {root}')
