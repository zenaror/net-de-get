# Uninterpreted source ranges

These 161 ranges complete the initial matching build, alongside the existing
hand-analyzed sources. They contain literal `db` bytes and explicitly sized
constant `ds` runs. They are not reference-ROM includes and do not require the
original file to assemble.

Classification is **HYPOTHESIS / unknown**: an interval may contain code, graphics,
text, tables or reserved space. Byte identity and fixed source boundaries are
verified, but no natural-execution or semantic claim follows from these files.

Files are split at physical 16 KiB bank and native 8 KiB page boundaries. A
physical RGBDS bank number is not an MBC6 selector. Named `ResidualROM` symbols
pin the starts; preserve them as aliases when replacing ranges with typed code
or assets. Avoid interpreting linear decoding of arbitrary bytes as proven code.

The one-time private bootstrap is retained in `tools/bootstrap_remaining.py` as
provenance. It refuses writes into this project and refuses a second import.
Refine the committed sources and canonical manifest, preserving complete byte
coverage and all published symbols. The canonical work plan is in the root README.
