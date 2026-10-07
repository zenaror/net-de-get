"""Layout and byte checks for sparse RGBDS excerpts; never interpret padding."""
import csv
from pathlib import Path
import re


def file_offset(bank, address):
    if bank < 0 or not (0 <= address <= 0x7fff):
        raise ValueError('Invalid ROM coordinates')
    if bank == 0:
        if address >= 0x4000:
            raise ValueError('ROM0 address outside fixed window')
        return address
    if address < 0x4000:
        raise ValueError('ROMX address outside banked window')
    return bank * 0x4000 + address - 0x4000


def read_manifest(path):
    with Path(path).open() as stream:
        rows = csv.DictReader(stream, delimiter='\t')
        if rows.fieldnames != ['bank', 'start', 'end', 'symbol']:
            raise ValueError('Unexpected manifest columns')
        entries = []
        symbols = set()
        for row in rows:
            bank, start, end = (int(row[k], 16) for k in ('bank', 'start', 'end'))
            file_offset(bank, start)
            file_offset(bank, end)
            if end < start or not row['symbol'] or row['symbol'] in symbols:
                raise ValueError('Invalid manifest entry or repeated symbol')
            symbols.add(row['symbol'])
            entries.append((bank, start, end, row['symbol']))
    if not entries:
        raise ValueError('Empty manifest')
    coordinates = [(b, s, e) for b, s, e, _ in entries]
    validate_sections(coordinates)
    return entries


def validate_sections(sections):
    if not sections:
        raise ValueError('No ROM sections')
    previous_end = -1
    for bank, start, end in sorted(sections):
        lo, hi = file_offset(bank, start), file_offset(bank, end)
        if end < start or lo <= previous_end:
            raise ValueError('Invalid or overlapping sections')
        previous_end = hi


def parse_map(text):
    bank = None
    sections = []
    for line in text.splitlines():
        match = re.search(r'ROM[0X] bank #(\d+)', line)
        if match:
            bank = int(match[1])
        if 'SECTION:' in line:
            match = re.search(r'SECTION: \$([0-9a-f]+)-\$([0-9a-f]+)', line, re.I)
            if not match or bank is None:
                raise ValueError('Malformed ROM map section')
            sections.append((bank, int(match[1], 16), int(match[2], 16)))
    validate_sections(sections)
    return sections


def check_layout(map_text, sym_text, entries):
    sections = parse_map(map_text)
    expected = [(b, s, e) for b, s, e, _ in entries]
    if sorted(sections) != sorted(expected):
        raise ValueError('Section layout differs from manifest (missing, extra, or moved)')
    symbols = {}
    for line in sym_text.splitlines():
        match = re.fullmatch(r'([0-9a-f]+):([0-9a-f]+)\s+(\S+)', line.strip(), re.I)
        if match:
            name = match[3]
            if name in symbols:
                raise ValueError('Repeated symbol')
            symbols[name] = (int(match[1], 16), int(match[2], 16))
    for bank, start, _, symbol in entries:
        if symbols.get(symbol) != (bank, start):
            raise ValueError(f'Missing or moved symbol: {symbol}')
    return sections


def compare_sections(image, reference, sections):
    validate_sections(sections)
    count = 0
    for bank, start, end in sections:
        offset = file_offset(bank, start)
        size = end - start + 1
        if offset + size > len(image) or offset + size > len(reference):
            raise ValueError(f'Truncated section at {bank:02X}:{start:04X}')
        if image[offset:offset + size] != reference[offset:offset + size]:
            raise ValueError(f'Byte mismatch at {bank:02X}:{start:04X}')
        count += size
    return count
