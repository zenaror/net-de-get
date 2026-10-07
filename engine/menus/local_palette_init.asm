; PROBABLE static all-palette initialization; preserve repeated pointer reloads.
; Native A $14; physical RGBDS bank $0A lower half.
SECTION "Local menu palette initialization", ROMX[$481B], BANK[$0A]
InitializeLocalMenuPalettes::
	xor a
REPT 8
	ld hl, LocalMenuWhitePalette
	call UploadBackgroundPaletteEntry
ENDR
	xor a
REPT 8
	ld hl, LocalMenuWhitePalette
	call UploadObjectPaletteEntry
ENDR
	ret
.end:
ASSERT .end - InitializeLocalMenuPalettes == $63
