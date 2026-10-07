"""Synthetic checker fixtures only; these tests do not validate game execution."""
from pathlib import Path
import tempfile
import unittest
from excerpt_checks import (check_layout, compare_sections, file_offset,
                            parse_map, read_manifest, validate_sections)

MAP = 'ROM0 bank #0:\n SECTION: $0010-$0011\nROMX bank #10:\n SECTION: $4000-$4001\n'
SYM = '00:0010 Fixed\n0a:4000 Banked\n'
ENTRIES = [(0, 0x10, 0x11, 'Fixed'), (10, 0x4000, 0x4001, 'Banked')]


class ExcerptChecksTest(unittest.TestCase):
    def test_mapper_coordinates(self):
        self.assertEqual(file_offset(10, 0x4d43), 0x28d43)
        # Native A selector $17 -> CPU $4A93 -> physical $0B:$6A93.
        self.assertEqual(file_offset(11, 0x6a93), 0x17 * 0x2000 + 0xa93)
        self.assertEqual(file_offset(0, 0x1359), 0x1359)

    def test_invalid_coordinates(self):
        for bank, address in [(0, 0x4000), (1, 0x2000), (-1, 0), (1, 0x8000)]:
            with self.subTest(bank=bank, address=address), self.assertRaises(ValueError):
                file_offset(bank, address)

    def test_layout_and_symbols(self):
        self.assertEqual(check_layout(MAP, SYM, ENTRIES), [(0, 16, 17), (10, 0x4000, 0x4001)])

    def test_missing_extra_moved_sections(self):
        for changed in [MAP.split('ROMX')[0], MAP + ' SECTION: $4010-$4011\n',
                        MAP.replace('$4001', '$4002')]:
            with self.subTest(map=changed), self.assertRaises(ValueError):
                check_layout(changed, SYM, ENTRIES)

    def test_missing_moved_duplicate_symbols(self):
        for changed in [SYM.splitlines()[0], SYM.replace('0a:4000', '0a:4001'), SYM + SYM]:
            with self.subTest(sym=changed), self.assertRaises(ValueError):
                check_layout(MAP, changed, ENTRIES)

    def test_malformed_empty_map(self):
        for changed in ['', 'SECTION: $0010-$0011', 'ROM0 bank #0:\nSECTION: ???']:
            with self.subTest(map=changed), self.assertRaises(ValueError):
                parse_map(changed)

    def test_overlapping_reversed_sections(self):
        for sections in [[(0, 16, 17), (0, 17, 18)], [(0, 16, 17)] * 2, [(0, 17, 16)], []]:
            with self.subTest(sections=sections), self.assertRaises(ValueError):
                validate_sections(sections)

    def test_byte_comparison_excludes_padding(self):
        reference = bytearray(0x28002)
        reference[16:18] = b'AB'
        reference[0x28000:] = b'CD'
        image = reference.copy()
        image[0x100] = 99  # Padding is deliberately outside the contract.
        self.assertEqual(compare_sections(image, reference, parse_map(MAP)), 4)

    def test_mutated_section_is_rejected(self):
        reference = b'\0' * 18
        image = bytearray(reference)
        image[16] = 1
        with self.assertRaisesRegex(ValueError, 'Byte mismatch'):
            compare_sections(image, reference, [(0, 16, 17)])

    def test_truncated_equal_slices_are_rejected(self):
        # A plain slice comparison would accept two equally truncated images.
        with self.assertRaisesRegex(ValueError, 'Truncated'):
            compare_sections(b'\0' * 17, b'\0' * 17, [(0, 16, 17)])

    def test_manifest_validation(self):
        header = 'bank\tstart\tend\tsymbol\n'
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'excerpts.tsv'
            path.write_text(header + '00\t0010\t0011\tFixed\n')
            self.assertEqual(read_manifest(path), [(0, 16, 17, 'Fixed')])
            for body in ['', header, header + '00\t0011\t0010\tFixed\n',
                         header + '00\t0010\t0011\tFixed\n' * 2]:
                path.write_text(body)
                with self.subTest(body=body), self.assertRaises(ValueError):
                    read_manifest(path)


if __name__ == '__main__':
    unittest.main()
