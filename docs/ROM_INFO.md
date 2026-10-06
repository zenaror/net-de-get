# ROM identification

Reference: `Net de Get - Minigame @ 100 (Japan).gbc` supplied by Rafael and kept outside this repository at:

`/media/rafael/Dados/Arquivos/Projetos/Gameboy Projects/MobileAdapterGB/mgba/Net de Get - Minigame @ 100 (Japan).gbc`

- SHA-256: `9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63`
- Size: 1,048,576 bytes (1 MiB)
- Header title/game code bytes: `MINIGAME100BMVJ`
- CGB flag: `$C0` (CGB-only)
- Cartridge type `$20`: MBC6
- ROM size code `$05`: 1 MiB (64 physical 16 KiB banks / 128 MBC6 8 KiB selectors)
- RAM size code `$03`: 32 KiB (8 MBC6 4 KiB banks)
- Destination code `$00`: Japan
- Header checksum: stored `$50`, computed `$50`
- Global checksum: stored `$BCC3`, computed `$BCC3`

The header and both checksums were computed directly from the external ROM. The project No-Intro database also contains a matching game entry. This identifies the host cartridge, not the identity or validity of a minigame installed in flash.
