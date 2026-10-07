#!/usr/bin/env python3
"""Compile/run forced-entry ROM0 probes using the matching mGBA build ABI."""
import argparse
import ctypes
import hashlib
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('reference_rom', type=Path)
p.add_argument('mgba_source', type=Path)
p.add_argument('mgba_build', type=Path)
a = p.parse_args()
expected = '9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63'
digest = lambda: hashlib.sha256(a.reference_rom.read_bytes()).hexdigest()
if digest() != expected:
    raise SystemExit('Unexpected reference ROM hash')
root = Path(tempfile.mkdtemp(prefix='netdeget-storage-probes-'))
flags = (a.mgba_build / 'CMakeFiles/mgba.dir/flags.make').read_text().split('C_DEFINES = ')[1].splitlines()[0]
defines = [value.replace('\\"', '"') for value in shlex.split(flags)]
library = (a.mgba_build / 'libmgba.so').resolve()
loaded = ctypes.CDLL(str(library))
version = ctypes.c_char_p.in_dll(loaded, 'projectVersion').value.decode()
commit = ctypes.c_char_p.in_dll(loaded, 'gitCommit').value.decode()
subprocess.run(['cc', '-O2', *defines, '-I'+str(a.mgba_source/'include'),
                '-I'+str(a.mgba_build/'include'),
                '-I'+str(a.mgba_source/'src/third-party/libmobile'),
                '-I'+str(a.mgba_build/'libmobile'), str(Path(__file__).with_name('probe.c')),
                str(library), '-Wl,-rpath,'+str(library.parent), '-o', str(root/'probe')], check=True)
env = dict(os.environ)
for key in ('LD_PRELOAD', 'LD_LIBRARY_PATH'):
    env.pop(key, None)
result = subprocess.run([str(root/'probe'), str(a.reference_rom.resolve())], cwd=root,
                        env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
(root/'run.log').write_text(result.stdout)
if digest() != expected:
    raise SystemExit('Reference ROM hash changed')
if result.returncode or f'version={version} commit={commit}' not in result.stdout:
    raise SystemExit(result.stdout)
print(result.stdout.strip())
print(f'Artifacts: {root}; original ROM unchanged; no disk save loaded')
