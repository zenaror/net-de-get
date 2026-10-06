# Synthetic host producer/writer trace

This harness uses the original external ROM read-only and creates fresh saves
under `mktemp /tmp`. It stages an artificial wrapper in SRAM, enters the ROM
producer at selector 16/window A `$4000`, and follows the actual parser,
WRAM output, VBlank wait, callback at selector 6/window B `$61C5`, and flash
programmer. CPU entry and mapper setup are synthetic. This does not test
natural download, HTTP framing, server behavior, or hardware.

Build the PAD fixture first, then run:

```sh
./fixtures/input-tester/build.sh
./fixtures/host-writer/run.sh ORIGINAL_ROM MGBA_ROOT MGBA_BUILD MAKER_COMPRESSOR_PY
```

`MAKER_COMPRESSOR_PY` is the external Maker `bmvj_compress.py`; it is not
copied here. Python 3, a C compiler, mGBA headers/shared library with MBC6
support, and RGBDS for PAD are needed. The runner checks the reference ROM
hash before and after. Outputs remain in the printed temporary directory.

The four cases cover 5,000 deterministic bytes and an 8 KiB PAD payload,
each raw and compressed, with a three-byte comment. Raw staging includes
256 skipped bytes after each <=512-byte chunk, as required by ROM reader
`$4B57`. Do not interpret these gaps as confirmed HTTP framing.

Each run checks declared output bytes, successful return, idle flash, and
persistence after opening a new core. The full PAD block also exercises the
ROM checksum validator, expecting acceptance of original bytes and rejection
after a single-bit corruption (the mutation is restored before unload). It reports callback/program counts and
nonzero bytes outside declared length; partial final buffers retain prior
content, so those bytes are not asserted to be zero. See
`docs/research/mbc6-host.md` for evidence and limits.
