#!/usr/bin/env python3
"""One-time explicit-source bootstrap, emitted to a private directory only.

Existing interpreted sections are preserved. Remaining bytes have unknown
classification and are emitted as literal source, never as a reference INCBIN.
This is a matching-build baseline, not a completed semantic disassembly.
"""
import argparse
import hashlib
from pathlib import Path
from excerpt_checks import read_manifest
from full_checks import coverage


def split_gaps(gaps):
    """Split physical offsets at every native 8 KiB page boundary."""
    result = []
    for lo, hi in gaps:
        while lo < hi:
            stop = min(hi, (lo // 0x2000 + 1) * 0x2000)
            bank = lo // 0x4000
            start = lo if bank == 0 else 0x4000 + lo % 0x4000
            result.append((bank, start, start + stop - lo - 1, lo, stop))
            lo = stop
    return result


def literal_lines(data):
    """Exact db bytes and explicitly sized constant runs; no linker padding."""
    lines = []
    pos = 0
    while pos < len(data):
        end = pos + 1
        if data[pos] in (0, 255):
            while end < len(data) and data[end] == data[pos]:
                end += 1
            if end - pos >= 16:
                lines.append(f'\tds ${end - pos:X}, ${data[pos]:02X}')
                pos = end
                continue
        end = min(pos + 16, len(data))
        lines.append('\tdb ' + ', '.join(f'${value:02X}' for value in data[pos:end]))
        pos = end
    return lines


def source(bank, start, end, data):
    if len(data) != end - start + 1:
        raise ValueError('Source length differs from coordinates')
    symbol = f'ResidualROM{bank:02X}_{start:04X}'
    lines = [
        '; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.',
        '; Byte preservation is checked; this source needs later consumer/flow analysis.',
        f'; Physical bank ${bank:02X}, address ${start:04X}-${end:04X}.',
        '; Literal source only; building does not read the external reference ROM.',
        f'SECTION "Uninterpreted {bank:02X}:{start:04X}-{end:04X}", ' +
        (f'ROM0[${start:04X}]' if bank == 0 else f'ROMX[${start:04X}], BANK[${bank:02X}]'),
        f'{symbol}::',
        *literal_lines(data),
        f'ASSERT @ == ${end + 1:04X}',
        ''
    ]
    return symbol, '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('reference_rom', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    output = args.out.resolve()
    if output.is_relative_to(repo) or (output.exists() and any(output.iterdir())):
        raise ValueError('Use an empty private output directory outside the project')
    reference_path = args.reference_rom.resolve()
    if reference_path.is_relative_to(repo):
        raise ValueError('The reference ROM must remain external')
    reference = reference_path.read_bytes()
    expected = (repo / 'roms.sha256').read_text().split()[0]
    if hashlib.sha256(reference).hexdigest() != expected:
        raise ValueError('Unexpected reference hash')
    entries = read_manifest(repo / 'config/excerpts.tsv')
    if any(symbol.startswith('ResidualROM') for _, _, _, symbol in entries):
        raise ValueError('Bootstrap already imported; refine committed source instead')
    count, gaps = coverage([(b, s, e) for b, s, e, _ in entries])
    output.mkdir(parents=True, exist_ok=True)
    directory = output / 'data/uninterpreted'
    directory.mkdir(parents=True)
    for bank, start, end, lo, hi in split_gaps(gaps):
        symbol, text = source(bank, start, end, reference[lo:hi])
        (directory / f'bank{bank:02x}_{start:04x}.asm').write_text(text)
        entries.append((bank, start, end, symbol))
    (output / 'config').mkdir()
    manifest = 'bank\tstart\tend\tsymbol\n'
    manifest += ''.join(f'{b:02X}\t{s:04X}\t{e:04X}\t{name}\n' for b, s, e, name in sorted(entries))
    (output / 'config/excerpts.tsv').write_text(manifest)
    coverage([(b, s, e) for b, s, e, _ in entries])
    if hashlib.sha256(reference_path.read_bytes()).hexdigest() != expected:
        raise ValueError('Reference hash changed')
    print(f'Private source bootstrap: {count} existing bytes preserved; '
          f'{len(reference) - count} uninterpreted bytes; {len(entries)} sections')
    print(f'Sources and manifest: {output}; reference unchanged')


if __name__ == '__main__':
    try:
        main()
    except ValueError as error:
        raise SystemExit(str(error))
