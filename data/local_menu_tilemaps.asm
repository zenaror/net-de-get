; PROBABLE static two-plane maps, bounded by B*C bytes per plane.
; Native A $14; physical RGBDS bank $0A lower half. Preserve original bytes.
SECTION "LocalMenuMap426D", ROMX[$426D], BANK[$0A]
LocalMenuMap426D::
	db $8C, $85, $86, $87, $00, $00, $00, $00
.end:
ASSERT .end - LocalMenuMap426D == 8

SECTION "LocalMenuMap4275", ROMX[$4275], BANK[$0A]
LocalMenuMap4275::
	db $EC, $ED, $EE, $EF, $00, $00, $00, $00
.end:
ASSERT .end - LocalMenuMap4275 == 8

SECTION "LocalMenuMap427D", ROMX[$427D], BANK[$0A]
LocalMenuMap427D::
	db $10, $FD, $FD, $FD, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA, $FB, $FC
	db $FD, $FD, $FD, $11, $12, $0D, $0D, $0D, $01, $02, $03, $04, $05, $06, $07, $08
	db $09, $0A, $0B, $0C, $0D, $0D, $0D, $13, $03, $03, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03
.end:
ASSERT .end - LocalMenuMap427D == 80

SECTION "LocalMenuMap450F", ROMX[$450F], BANK[$0A]
LocalMenuMap450F::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
.end:
ASSERT .end - LocalMenuMap450F == 80

