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
    parser.add_argument('--verify-build', action='store_true',
                        help='Check complete layout and recorded SHA256 without the reference')
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    entries = read_manifest(repo / 'config/excerpts.tsv')
    sections = [(b, s, e) for b, s, e, _ in entries]
    count, gaps = coverage(sections)
    print(f'Explicit source coverage: {count}/1048576 bytes ({100 * count / 1048576:.4f}%); '
          f'{len(gaps)} unresolved ranges')
    uninterpreted = sum(e - s + 1 for _, s, e, symbol in entries if symbol.startswith('ResidualROM'))
    print(f'Uninterpreted source bytes: {uninterpreted}; byte identity does not establish semantics')
    for lo, hi in gaps:
        print(f'UNRESOLVED file ${lo:06X}-${hi - 1:06X} ({hi - lo} bytes)')
    if args.reference_rom is None and not args.verify_build:
        return
    expected = (repo / 'roms.sha256').read_text().split()[0]
    reference = args.reference_rom.read_bytes() if args.reference_rom else None
    if reference is not None and hashlib.sha256(reference).hexdigest() != expected:
        raise ValueError('Unexpected reference ROM hash')
    sections = check_layout((repo / 'build/excerpts.map').read_text(),
                            (repo / 'build/excerpts.sym').read_text(), entries)
    image = (repo / 'build/excerpts.gb').read_bytes()
    if reference is not None:
        compare_full(image, reference, sections)
    elif gaps or len(image) != 0x100000:
        raise ValueError('Build lacks complete explicit source coverage or correct length')
    if hashlib.sha256(image).hexdigest() != expected:
        raise ValueError('Built image SHA256 differs from roms.sha256')
    if args.reference_rom and hashlib.sha256(args.reference_rom.read_bytes()).hexdigest() != expected:
        raise ValueError('Reference ROM hash changed')
    print(f'PASS complete reconstruction: {len(image)} bytes; SHA256 {expected}')


if __name__ == '__main__':
    try:
        main()
    except ValueError as error:
        raise SystemExit(str(error))
