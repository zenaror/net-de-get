#!/usr/bin/env python3
"""Exercise the real complete-build gate in disposable source copies.

No reference ROM is loaded. Detect an altered source byte and a missing zero
section whose linker padding still produces the recorded original SHA256.
"""
import hashlib
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[1]
root = Path(tempfile.mkdtemp(prefix='netdeget-full-negative-'))
expected = (repo / 'roms.sha256').read_text().split()[0]


def candidate(name):
    destination = root / name
    destination.mkdir()
    for item in ('Makefile', 'includes.asm', 'roms.sha256', 'home', 'engine', 'data',
                 'constants', 'ram', 'config', 'tools'):
        source = repo / item
        if source.is_dir():
            shutil.copytree(source, destination / item,
                            ignore=shutil.ignore_patterns('__pycache__'))
        else:
            shutil.copy2(source, destination / item)
    return destination


def rejected(tree, message):
    result = subprocess.run(['make'], cwd=tree, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (root / (tree.name + '.log')).write_text(result.stdout)
    if result.returncode == 0 or message not in result.stdout:
        raise SystemExit(f'FAIL expected rejection ({message}): {root / (tree.name + ".log")}')
    return tree / 'build/excerpts.gb'


altered = candidate('altered-byte')
for path in sorted((altered / 'data/uninterpreted').glob('*.asm')):
    source = path.read_text()
    match = re.search(r'(?m)^\tdb \$([0-9A-F]{2})', source)
    if match:
        value = int(match[1], 16) ^ 1
        path.write_text(source[:match.start(1)] + f'{value:02X}' + source[match.end(1):])
        break
else:
    raise SystemExit('No uninterpreted literal source available for mutation')
image = rejected(altered, 'Built image SHA256 differs')
if hashlib.sha256(image.read_bytes()).hexdigest() == expected:
    raise SystemExit('Altered-byte negative fixture did not change the built image')

missing = candidate('equal-linker-padding')
for path in sorted((missing / 'data/uninterpreted').glob('*.asm')):
    source = path.read_text()
    if '\tds $2000, $00\n' in source and '\tdb ' not in source:
        symbol = re.search(r'^(ResidualROM\w+)::', source, re.M)[1]
        path.unlink()
        manifest = missing / 'config/excerpts.tsv'
        manifest.write_text(''.join(line for line in manifest.read_text().splitlines(keepends=True)
                                    if not line.rstrip().endswith('\t' + symbol)))
        break
else:
    raise SystemExit('No full zero-filled page available for padding fixture')
image = rejected(missing, 'Build lacks complete explicit source coverage')
if hashlib.sha256(image.read_bytes()).hexdigest() != expected:
    raise SystemExit('Padding fixture did not preserve the exact original image hash')
print('PASS complete-build negative fixtures: altered byte rejected; exact-hash padding rejected')
print(f'Artifacts: {root}; no reference ROM loaded')
