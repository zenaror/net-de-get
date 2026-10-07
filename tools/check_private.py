#!/usr/bin/env python3
"""Validate a private candidate and preserve every published address symbol."""
import argparse
import io
from pathlib import Path
import re
import shutil
import subprocess
import tarfile
import tempfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('reference_rom', type=Path)
a = p.parse_args()
repo = Path(__file__).resolve().parents[1]
root = Path(tempfile.mkdtemp(prefix='netdeget-private-cycle-'))
base, candidate = root / 'baseline', root / 'candidate'
base.mkdir()
candidate.mkdir()
archive_bytes = subprocess.check_output(['git', 'archive', 'HEAD'], cwd=repo)
with tarfile.open(fileobj=io.BytesIO(archive_bytes)) as archive:
    archive.extractall(base, filter='data')
# Explicit source allowlist: do not copy original ROM, saves, .git or .workspace.
for name in ('Makefile', 'includes.asm', 'roms.sha256', 'home', 'engine', 'data',
             'constants', 'ram', 'config', 'tools'):
    source, destination = repo / name, candidate / name
    if source.is_dir():
        shutil.copytree(source, destination, ignore=shutil.ignore_patterns('__pycache__'))
    else:
        shutil.copy2(source, destination)
for tree, args in ((base, ['make']),
                   (candidate, ['make', 'verify', 'REFERENCE_ROM=' + str(a.reference_rom.resolve())])):
    result = subprocess.run(args, cwd=tree, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (root / (tree.name + '.log')).write_text(result.stdout)
    if result.returncode:
        raise SystemExit(result.stdout)


def symbols(path):
    result = {}
    for line in path.read_text().splitlines():
        match = re.fullmatch(r'([0-9a-f]+):([0-9a-f]+)\s+(\S+)', line, re.I)
        if match:
            result[match[3]] = (int(match[1], 16), int(match[2], 16))
    return result


old = symbols(base / 'build/excerpts.sym')
new = symbols(candidate / 'build/excerpts.sym')
changed = [name for name, value in old.items() if new.get(name) != value]
if changed:
    raise SystemExit('Changed published address symbols: ' + ', '.join(changed))
if (candidate / 'build/excerpts.gb').read_bytes() != (repo / 'build/excerpts.gb').read_bytes():
    raise SystemExit('Private candidate and working-tree images differ')
print(f'PASS private cycle; {len(old)} published symbols unchanged; candidate/main identical')
print(f'Artifacts: {root}')
