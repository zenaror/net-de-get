#!/usr/bin/env python3
"""Report manifest coverage or require full, byte-identical reconstruction."""
import argparse
import hashlib
from pathlib import Path
from excerpt_checks import check_layout, read_manifest
from full_checks import coverage, compare_full


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('reference_rom', type=Path, nargs='?')
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    entries = read_manifest(repo / 'config/excerpts.tsv')
    sections = [(b, s, e) for b, s, e, _ in entries]
    count, gaps = coverage(sections)
    print(f'Explicit source coverage: {count}/1048576 bytes ({100 * count / 1048576:.4f}%); '
          f'{len(gaps)} unresolved ranges')
    for lo, hi in gaps:
        print(f'UNRESOLVED file ${lo:06X}-${hi - 1:06X} ({hi - lo} bytes)')
    if args.reference_rom is None:
        return
    reference = args.reference_rom.read_bytes()
    expected = (repo / 'roms.sha256').read_text().split()[0]
    if hashlib.sha256(reference).hexdigest() != expected:
        raise ValueError('Unexpected reference ROM hash')
    sections = check_layout((repo / 'build/excerpts.map').read_text(),
                            (repo / 'build/excerpts.sym').read_text(), entries)
    image = (repo / 'build/excerpts.gb').read_bytes()
    compare_full(image, reference, sections)
    if hashlib.sha256(args.reference_rom.read_bytes()).hexdigest() != expected:
        raise ValueError('Reference ROM hash changed')
    print(f'PASS complete reconstruction: {len(image)} bytes; SHA256 {expected}')


if __name__ == '__main__':
    try:
        main()
    except ValueError as error:
        raise SystemExit(str(error))
