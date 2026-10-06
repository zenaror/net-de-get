#!/usr/bin/env bash
set -euo pipefail
if [[ $# != 4 ]]; then
  echo "usage: $0 ORIGINAL_ROM MGBA_ROOT MGBA_BUILD MAKER_COMPRESSOR_PY" >&2
  exit 2
fi
rom="$1"
mgba_root="$2"
mgba_build="$3"
compressor="$4"
fixture_root="$(cd "$(dirname "$0")" && pwd)"
run_root="$(mktemp -d /tmp/netdeget-producer-XXXXXX)"
expected_hash=9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63
actual_hash="$(sha256sum "$rom" | cut -d ' ' -f 1)"
[[ "$actual_hash" == "$expected_hash" ]] || { echo 'Unexpected reference ROM hash' >&2; exit 2; }
echo "Disposable artifacts: $run_root"
cc -O2 -DENABLE_VFS -DENABLE_DIRECTORIES -DENABLE_INPUT \
  -I"$mgba_root/include" "$fixture_root/trace.c" \
  -L"$mgba_build" -Wl,-rpath,"$mgba_build" -lmgba -o "$run_root/trace"
python3 - "$run_root" "$compressor" "$fixture_root/../input-tester/input_tester.flash" <<'PY'
import importlib.util, pathlib, sys
root = pathlib.Path(sys.argv[1])
spec = importlib.util.spec_from_file_location('maker_codec', sys.argv[2])
codec = importlib.util.module_from_spec(spec)
spec.loader.exec_module(codec)
cases = {
    'multi': bytes((i * 37 + (i // 256) * 11 + 3) & 255 for i in range(5000)),
    'pad': pathlib.Path(sys.argv[3]).read_bytes(),
}
for name, data in cases.items():
    (root / (name + '.bin')).write_bytes(data)
    # Contract of ROM reader $4B57: each <=512-byte raw chunk is followed
    # by 256 skipped bytes. This is synthetic SRAM layout, not HTTP framing.
    framed = b''.join(data[i:i+512] + bytes(256) for i in range(0, len(data), 512))
    raw = b'\x03abc\x00\x00' + len(data).to_bytes(2, 'little') * 2 + bytes(2) + framed
    compressed = b'\x03abc' + codec.bmvj_compress(data)[1:]
    for mode, wrapper in [('raw', raw), ('compressed', compressed)]:
        (root / (name + '-' + mode + '.cgb')).write_bytes(wrapper)
        (root / (name + '-' + mode)).mkdir()
PY
for case_name in multi pad; do
  for mode_name in raw compressed; do
    "$run_root/trace" "$rom" "$run_root/$case_name-$mode_name" \
      "$run_root/$case_name-$mode_name.cgb" "$run_root/$case_name.bin" \
      | tee "$run_root/$case_name-$mode_name.log"
  done
done
[[ "$(sha256sum "$rom" | cut -d ' ' -f 1)" == "$expected_hash" ]]
echo 'PASS: four producer/writer runs, fresh-core persistence, reference ROM unchanged'
