"""Negative gates: padded equality is insufficient without complete sources."""
import unittest
from full_checks import coverage, compare_full


class FullChecksTest(unittest.TestCase):
    def test_complete_coverage_and_bytes(self):
        self.assertEqual(compare_full(b'abcd', b'abcd', [(0, 0, 3)]), 4)

    def test_equal_padding_is_rejected(self):
        # Candidate and reference match, but the middle bytes are linker padding.
        with self.assertRaisesRegex(ValueError, 'Incomplete source coverage'):
            compare_full(b'abcd', b'abcd', [(0, 0, 0), (0, 3, 3)])

    def test_leading_and_trailing_gaps(self):
        self.assertEqual(coverage([(0, 1, 2)], 4), (2, [(0, 1), (3, 4)]))

    def test_adjacent_sections(self):
        self.assertEqual(coverage([(0, 2, 3), (0, 0, 1)], 4), (4, []))

    def test_overlap_and_excess_size(self):
        for sections in ([(0, 0, 2), (0, 2, 3)], [(0, 0, 4)]):
            with self.assertRaises(ValueError):
                coverage(sections, 4)

    def test_truncated_and_oversized_images(self):
        for image in (b'abc', b'abcde'):
            with self.assertRaisesRegex(ValueError, 'image size'):
                compare_full(image, b'abcd', [(0, 0, 3)])

    def test_mutated_image(self):
        with self.assertRaisesRegex(ValueError, 'offset \\$000002'):
            compare_full(b'abXd', b'abcd', [(0, 0, 3)])

    def test_physical_bank_transition(self):
        # Physical ROM0/ROMX are contiguous; MBC6 selectors are not file banks.
        self.assertEqual(coverage([(0, 0, 0x3FFF), (1, 0x4000, 0x7FFF)], 0x8000),
                         (0x8000, []))


if __name__ == '__main__':
    unittest.main()
