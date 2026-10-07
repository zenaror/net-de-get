# Environment and reference ROM

## Reference ROM

The original `Net de Get - Minigame @ 100 (Japan).gbc` is a commercial dump supplied by the Operator. It is intentionally kept outside this Git repository. Its SHA-256 is recorded in `roms.sha256`. To recheck it, run `sha256sum` against the original file at the path recorded in `docs/ROM_INFO.md`; do not copy it into this repository.

## Tools observed

At project setup, Python 3, RGBDS `rgbasm v1.0.3`, Podman `4.9.3`, and Ghidra 12.1.3 with GhidraBoy were already installed in the local environment. No tools were installed for this project.

The disassembly uses RGBDS and Python 3. Run `make` to assemble all committed sources into `build/net-de-get.gbc` with shared `includes.asm`. The build checks explicit byte coverage, image length and the recorded original SHA-256. No reference ROM is needed to build. Output lives in ignored `build/`. Large source ranges are still explicitly uninterpreted; binary identity does not imply complete semantic analysis.

The optional `make compare REFERENCE_ROM="/external/path/game.gbc"` checks every emitted section against the known external reference; `verify-full` additionally checks whole-image identity. Building never fills missing sections from the reference. The MBC6 research still uses the separate mGBA and MBC6 Test ROM projects.

## Gates for each source change

Run `make verify REFERENCE_ROM="/external/path/game.gbc"`. `sym-check` compares section boundaries and entry symbols to `config/excerpts.tsv`; `test` runs synthetic negative and positive checker fixtures; `compare` rebuilds into a fresh temporary directory and checks emitted bytes against the original hash-checked reference. The complete-build gate checks coverage and SHA-256 independently; whole-file equivalence is also checked against the external reference.

## Complete reconstruction gate

`make coverage` reports the explicit-source byte count and unresolved physical
file ranges from the manifest. `make verify-full REFERENCE_ROM="/external/path/game.gbc"`
requires the partial gates, full source coverage, correct image length and exact
whole-file bytes. It passes for the complete source baseline, including explicitly uninterpreted regions.
Linker padding is never counted as source, even if it matches the reference.
The original is read only for comparison, never as an assembly input or gap filler.

## Real negative build fixtures

`make full-negative-check` builds disposable source copies without the reference.
It rejects a changed literal byte and a deleted zero-filled page. The second
image still has the original SHA-256 because linker padding matches, but lacks
explicit source coverage and must fail. Scripts and contracts live in `tools/`;
temporary logs are disposable evidence, not the only way to reproduce the checks.
