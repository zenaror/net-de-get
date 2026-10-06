# Environment and reference ROM

## Reference ROM

The original `Net de Get - Minigame @ 100 (Japan).gbc` is a commercial dump supplied by Rafael. It is intentionally kept outside this Git repository. Its SHA-256 is recorded in `roms.sha256`. To recheck it, run `sha256sum` against the original file at the path recorded in `docs/ROM_INFO.md`; do not copy it into this repository.

## Tools observed

At project setup, Python 3, RGBDS `rgbasm v1.0.3`, Podman `4.9.3`, and Ghidra 12.1.3 with GhidraBoy were already installed in the local environment. No tools were installed for this project.

The current scope uses the mGBA checkout and MBC6 Test ROM project for implementation and validation. A full RGBDS reconstruction/build pipeline is not part of this initial milestone.
