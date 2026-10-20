; PROBABLE fixed-ROM display helpers from static SM83 flow.
; Hardware timing and natural callers are not established here.
SECTION "A16 digit tile helper", ROM0[$0747]
ResidualROM00_0747::
WriteA16DigitTileOrMarker::
	cp a, $09
	jr z, .digit
	jp nc, .marker
.digit
	add a, $20
	ld [hli], a
	ret
.marker
	ld a, $4E
	ld [hli], a
	ret
ASSERT @ == $0756

SECTION "Display status helper from A", ROM0[$0756]
; The first instruction writes A to LY; the conditional then tests A.
ConfigureSTATAndIEFromA::
	ldh [$FF45], a
	and a
	jr nz, .nonzeroLY
	ldh a, [$FF41]
	and a, $3F
	ldh [$FF41], a
	ldh a, [$FFFF]
	and a, $0D
	ldh [$FFFF], a
	ret
.nonzeroLY
	ldh a, [$FF41]
	and a, $3F
	or a, $40
	ldh [$FF41], a
	ldh a, [$FFFF]
	or a, $02
	ldh [$FFFF], a
	ret
ASSERT @ == $0777

SECTION "Initialize LCDC control", ROM0[$0777]
InitializeLCDCToC3::
	xor a, a
	ldh [$FF0F], a
	call ConfigureSTATAndIEFromA
	ld a, $C3
	ldh [$FF40], a
	ret
ASSERT @ == $0782

SECTION "Wait for LY 91 then disable LCDC", ROM0[$0782]
WaitForLY91AndDisableLCDC::
	ldh a, [$FFFF]
	push af
	and a, $FE
	ldh [$FFFF], a
.waitLY91
	ldh a, [$FF44]
	cp a, $91
	jr nz, .waitLY91
	ldh a, [$FF40]
	and a, $7F
	ldh [$FF40], a
	pop af
	ldh [$FFFF], a
	ret
ASSERT @ == $0799
