; Original serialized header fields; do not run rgbfix on a partial image.
SECTION "Cartridge header", ROM0[$0104]
CartridgeHeader::
NintendoLogo::
	db $CE, $ED, $66, $66, $CC, $0D, $00, $0B
	db $03, $73, $00, $83, $00, $0C, $00, $0D
	db $00, $08, $11, $1F, $88, $89, $00, $0E
	db $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
	db $BB, $BB, $67, $63, $6E, $0E, $EC, $CC
	db $DD, $DC, $99, $9F, $BB, $B9, $33, $3E
CartridgeTitle::
	db "MINIGAME100"
CartridgeGameCode::
	db "BMVJ"
	db $C0 ; CGB-only flag
	db "A4" ; new licensee code
	db $00 ; SGB flag
	db $20 ; MBC6 cartridge
	db $05 ; ROM size: 1 MiB
	db $03 ; RAM size: 32 KiB
	db $00 ; destination code
	db $33 ; old licensee: use new code
	db $00 ; version
	db $50 ; original header checksum
	db $BC, $C3 ; original big-endian global checksum
.end:
ASSERT .end - CartridgeHeader == $4C
ASSERT CartridgeTitle == $0134
ASSERT CartridgeGameCode == $013F
