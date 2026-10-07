# Environment and reference ROM

## Reference ROM

The original `Net de Get - Minigame @ 100 (Japan).gbc` is a commercial dump supplied by Rafael. It is intentionally kept outside this Git repository. Its SHA-256 is recorded in `roms.sha256`. To recheck it, run `sha256sum` against the original file at the path recorded in `docs/ROM_INFO.md`; do not copy it into this repository.

## Tools observed

At project setup, Python 3, RGBDS `rgbasm v1.0.3`, Podman `4.9.3`, and Ghidra 12.1.3 with GhidraBoy were already installed in the local environment. No tools were installed for this project.

The incremental disassembly uses RGBDS and Python 3. Run `make` from the repository root to assemble the published excerpts with a shared `includes.asm`, as in the local Mobile Trainer workflow. Output lives in ignored `build/`. This sparse image is not a complete ROM reconstruction.

The optional `make compare REFERENCE_ROM="/external/path/game.gbc"` compares only emitted sections to the known external reference; it never fills missing sections from that reference. The MBC6 research still uses the separate mGBA and MBC6 Test ROM projects.

## Gates for each source change

Run `make verify REFERENCE_ROM="/external/path/game.gbc"`. `sym-check` compares section boundaries and entry symbols to `config/excerpts.tsv`; `test` runs synthetic negative and positive checker fixtures; `compare` rebuilds into a fresh temporary directory and checks emitted bytes against the original hash-checked reference. No full-ROM equivalence is implied by sparse excerpt equivalence.
