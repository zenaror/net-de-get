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
for n, src in enumerate(sorted((repo / 'src').rglob('*.asm'))):
    obj, out, mp = (root / f'{n}{ext}' for ext in ('.o', '.gb', '.map'))
    subprocess.run(['rgbasm', '-o', str(obj), str(src)], check=True)
    subprocess.run(['rgblink', '-p', '0', '-o', str(out), '-m', str(mp), str(obj)], check=True)
    image = out.read_bytes()
    bank = count = 0
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
                raise SystemExit(f'Mismatch: {src.relative_to(repo)} at {start:04X}')
            count += size
    if not count:
        raise SystemExit(f'No ROM sections checked: {src}')
    print(f'PASS equivalent: {src.relative_to(repo)} ({count} bytes)')
if hashlib.sha256(a.reference_rom.read_bytes()).hexdigest() != expected:
    raise SystemExit('Reference ROM hash changed')
print(f'Partial excerpt comparison only; artifacts: {root}')
