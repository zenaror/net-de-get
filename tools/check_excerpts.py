#!/usr/bin/env python3
"""Assemble partial RGBDS excerpts and compare only their sections to a read-only ROM."""
import argparse
import hashlib
from pathlib import Path
import re
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
out, mp = root / 'excerpts.gb', root / 'excerpts.map'
subprocess.run(['rgblink', '-p', '0', '-o', str(out), '-m', str(mp), *objects], check=True)
image = out.read_bytes()
bank = count = sections = 0
for line in mp.read_text().splitlines():
    b = re.search(r'ROM[0X] bank #(\d+)', line)
    if b:
        bank = int(b[1])
    m = re.search(r'SECTION: \$([0-9a-f]+)-\$([0-9a-f]+)', line, re.I)
    if m:
        start, end = (int(x, 16) for x in m.groups())
        offset = start if bank == 0 else bank * 0x4000 + start - 0x4000
        size = end - start + 1
        if image[offset:offset + size] != rom[offset:offset + size]:
            raise SystemExit(f'Mismatch: RGBDS bank {bank:02X}, address {start:04X}')
        print(f'PASS equivalent: RGBDS {bank:02X}:{start:04X}-{end:04X} ({size} bytes)')
        count += size
        sections += 1
if not sections:
    raise SystemExit('No ROM sections checked')
print(f'Compared {sections} sections, {count} bytes; padding was not compared')
if hashlib.sha256(a.reference_rom.read_bytes()).hexdigest() != expected:
    raise SystemExit('Reference ROM hash changed')
print(f'Partial excerpt comparison only; artifacts: {root}')
