#!/usr/bin/env bash
set -euo pipefail
if [[ $# != 5 ]]; then
  echo "usage: $0 ROM MGBA_ROOT MGBA_BUILD DISPOSABLE_BOX2_SAV DISPOSABLE_FLASH" >&2
  exit 2
fi
fixture_root="$(cd "$(dirname "$0")" && pwd)"
run_root="$(mktemp -d /tmp/netdeget-pad-natural-XXXXXX)"
cc -O2 -DENABLE_VFS -DENABLE_DIRECTORIES -DENABLE_INPUT \
  -I"$2/include" -I"$3/include" "$fixture_root/run_natural.c" \
  -L"$3" -Wl,-rpath,"$3" -lmgba -o "$run_root/runner"
python3 - "$1" "$4" "$5" "$fixture_root/input_tester.flash" "$run_root" <<'PY'
import hashlib, pathlib, subprocess, sys
rom, save, flash, payload, root = map(pathlib.Path, sys.argv[1:])
expected = '9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63'
assert hashlib.sha256(rom.read_bytes()).hexdigest() == expected
s = save.read_bytes()
assert len(s) == 32768 and s[0x4F2:0x4F4] == b'\x10\x01', 'requires disposable validated BOX2 slot fixture'
f = bytearray(flash.read_bytes())
p = payload.read_bytes()
assert len(f) == 0x100101 and len(p) == 8192
f[:8192] = p
(root / 'padtest.sav').write_bytes(s)
(root / 'padtest.sav.flash').write_bytes(f)
args = [str(root / 'runner'), str(rom), str(root),
        '0:900', '8:3', '0:180', '1:3', '0:360', '1:3', '0:60',
        '1:3', '0:240', '16:3', '0:90', '1:3', '0:60', '1:3', '0:120']
for key in [1, 2, 8, 4, 16, 32, 64, 128]:
    args += [f'{key}:3', '0:20']
args += ['12:3', '0:300'] + ['128:3', '0:10'] * 16 + ['1:3', '0:60', '1:3', '0:180']
with (root / 'run.log').open('w') as out:
    subprocess.run(args, stdout=out, stderr=subprocess.STDOUT, check=True)
lines = (root / 'run.log').read_text().splitlines()
stages = {int(line.split()[0].split('=')[1]): line for line in lines if line.startswith('stage=')}
assert 'counters=0101010101010101' in stages[30] and 'held=00' in stages[30]
assert 'A=20 B=0' in stages[32], 'expected host menu after exit'
assert 'A=0 B=0' in stages[68] and 'counters=0000000000000000' in stages[68]
assert 'held=00' in stages[68] and 'fixtureFrames=0 ' not in stages[68]
assert (root / 'padtest.sav.flash').read_bytes() == f, 'flash changed while running fixture'
assert (root / 'padtest.sav').read_bytes()[0x4F2:0x4F4] == b'\x10\x00'
assert hashlib.sha256(rom.read_bytes()).hexdigest() == expected
print(f'PASS: natural BOX2 launch, eight inputs, exit, BOX1 item16 relaunch: {root}')
PY
