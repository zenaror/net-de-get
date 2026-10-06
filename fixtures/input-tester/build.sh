#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

python3 "$root/gen_font.py" "$tmp/pad_font.inc"
rgbasm -I "$tmp" -o "$tmp/input_tester.o" "$root/input_tester.asm"
rgblink -p 0x00 -o "$tmp/input_tester.gb" "$tmp/input_tester.o"
python3 - "$tmp/input_tester.gb" "$root/input_tester.flash" <<'PY'
import pathlib, sys
rom = pathlib.Path(sys.argv[1]).read_bytes()
payload = rom[0x4000:0x6000]
if len(payload) != 0x2000:
    raise SystemExit(f"expected an 8 KiB payload, got {len(payload)} bytes")
# Preserve the whole declared block: the host checks all 8 KiB.
payload = bytearray(payload)
checksum = (sum(payload) - sum(payload[0x6D:0x6F])) & 0xFFFF
payload[0x6D] = checksum & 0xFF
payload[0x6E] = checksum >> 8
pathlib.Path(sys.argv[2]).write_bytes(payload)
print(f"wrote {sys.argv[2]} ({len(payload)} bytes)")
PY
