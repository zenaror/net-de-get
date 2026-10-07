"""Structural bootstrap tests; never imply semantics of uninterpreted bytes."""
import re
import unittest
from bootstrap_remaining import literal_lines, source, split_gaps


class BootstrapTest(unittest.TestCase):
    def test_native_page_and_bank_boundaries(self):
        self.assertEqual(split_gaps([(0x1FFE, 0x4002)]), [
            (0, 0x1FFE, 0x1FFF, 0x1FFE, 0x2000),
            (0, 0x2000, 0x3FFF, 0x2000, 0x4000),
            (1, 0x4000, 0x4001, 0x4000, 0x4002)])

    def test_literal_roundtrip_including_constant_runs(self):
        data = bytes(range(256)) + bytes(45) + bytes([255]) * 100 + bytes(range(31))
        rebuilt = bytearray()
        for line in literal_lines(data):
            if line.startswith('\tdb '):
                rebuilt.extend(int(value.strip()[1:], 16) for value in line[4:].split(','))
            else:
                length, value = (int(v.strip()[1:], 16) for v in line[4:].split(','))
                rebuilt.extend(bytes([value]) * length)
        self.assertEqual(bytes(rebuilt), data)

    def test_no_reference_include_and_unknown_classification(self):
        symbol, text = source(10, 0x4000, 0x4002, bytes([0xC3, 0, 0x40]))
        self.assertEqual(symbol, 'ResidualROM0A_4000')
        self.assertIn('HYPOTHESIS classification', text)
        self.assertNotIn('INCBIN', text)
        self.assertIn('ASSERT @ == $4003', text)

    def test_reject_mismatched_length(self):
        with self.assertRaises(ValueError):
            source(1, 0x4000, 0x4002, b'xx')

    def test_constant_fill_is_explicit_source(self):
        self.assertEqual(literal_lines(bytes(32)), ['\tds $20, $00'])
        self.assertEqual(literal_lines(bytes([255]) * 32), ['\tds $20, $FF'])


if __name__ == '__main__':
    unittest.main()
