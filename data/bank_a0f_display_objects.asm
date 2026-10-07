; PROBABLE original display-table setup prefix and bounded two-variant objects.
; Physical bank07 upper8KiB is A0F4000-5FFF: pointer words retain -2000.
SECTION "A0F display 609C-60B1", ROMX[$609C], BANK[$07]
PrepareA0FDisplayTablePrefix::
	di
	xor a, a
	ldh [$FF4F], a
	ldh [$FF70], a
	ld a, $0F
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld hl, A0FDisplayTablePrefix - $2000
	call ResidentJump0258
ASSERT @ == $60B2

SECTION "A0F display 7288-7289", ROMX[$7288], BANK[$07]
A0FDisplayTablePrefix::
	dw A0FDisplayVariants0 - $2000
ASSERT @ == $728A

SECTION "A0F display 729E-72A1", ROMX[$729E], BANK[$07]
A0FDisplayVariants0::
	dw A0FDisplayObject0 - $2000, A0FDisplayObject1 - $2000
ASSERT @ == $72A2

SECTION "A0F display 72A2-72C2", ROMX[$72A2], BANK[$07]
A0FDisplayObject0::
	db $08 ; number of four-byte pieces
	db $F8, $F8, $80, $00
	db $F8, $00, $81, $00
	db $F8, $08, $82, $00
	db $00, $F8, $83, $00
	db $00, $08, $84, $00
	db $08, $F8, $85, $00
	db $08, $00, $86, $00
	db $08, $08, $87, $00
ASSERT @ == $72C3

SECTION "A0F display 72C3-72EB", ROMX[$72C3], BANK[$07]
A0FDisplayObject1::
	db $0A ; number of four-byte pieces
	db $F8, $F8, $80, $00
	db $F8, $00, $81, $00
	db $F8, $08, $81, $00
	db $F8, $10, $82, $00
	db $00, $F8, $83, $00
	db $00, $10, $84, $00
	db $08, $F8, $85, $00
	db $08, $00, $86, $00
	db $08, $08, $86, $00
	db $08, $10, $87, $00
ASSERT @ == $72EC
