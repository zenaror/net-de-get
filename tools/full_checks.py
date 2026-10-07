"""Require explicit byte coverage before accepting a complete reconstruction."""
from excerpt_checks import file_offset, validate_sections

ROM_SIZE = 0x100000


def coverage(sections, size=ROM_SIZE):
    validate_sections(sections)
    cursor = covered = 0
    gaps = []
    for bank, start, end in sorted(sections):
        lo, hi = file_offset(bank, start), file_offset(bank, end) + 1
        if hi > size:
            raise ValueError('Section exceeds reference size')
        if lo > cursor:
            gaps.append((cursor, lo))
        covered += hi - lo
        cursor = hi
    if cursor < size:
        gaps.append((cursor, size))
    return covered, gaps


def compare_full(image, reference, sections):
    covered, gaps = coverage(sections, len(reference))
    if gaps:
        lo, hi = gaps[0]
        raise ValueError(f'Incomplete source coverage: {covered}/{len(reference)} bytes; '
                         f'first gap file offset ${lo:06X}-${hi - 1:06X}')
    if len(image) != len(reference):
        raise ValueError('Complete image size differs from reference')
    if image != reference:
        first = next(i for i, (a, b) in enumerate(zip(image, reference)) if a != b)
        raise ValueError(f'Complete image byte differs at file offset ${first:06X}')
    return covered
