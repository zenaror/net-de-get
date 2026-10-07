; PROBABLE original graphics and two-plane tilemap initialization.
; SYNTHETIC LCD-off/on complete calls; not natural menu/timing evidence.
SECTION "A0F graphics initialization 615C-61C4", ROMX[$615C], BANK[$07]
ResidualROM07_615C::
InitializeA0FGraphicsAndTilemap::
	ld hl, A0FDisplayGraphics - $2000
	ld de, $8800
	ld bc, $0640
	call CopyVRAMBytes
	ld a, [$C765]
	or a, a
	jr z, A0FGraphics_418D
	ld c, $00
	ld b, $00
	call ResidentJump0219
	ld bc, $9800
	add hl, bc
	push hl
	xor a, a
	ldh [$FF4F], a
	ld hl, A0FDisplayTilemapMode1 - $2000
	pop de
	ld b, $14
	ld c, $02
	call CopyTwoPlaneTilemap
	ld hl, A0FDisplayRepeatedCell1 - $2000
	jr A0FGraphics_41AA
A0FGraphics_418D::
	ld c, $00
	ld b, $00
	call ResidentJump0219
	ld bc, $9800
	add hl, bc
	push hl
	xor a, a
	ldh [$FF4F], a
	ld hl, A0FDisplayTilemapMode0 - $2000
	pop de
	ld b, $14
	ld c, $02
	call CopyTwoPlaneTilemap
	ld hl, A0FDisplayRepeatedCell0 - $2000
A0FGraphics_41AA::
	ld de, $983C
	ld a, $00
	ld b, $01
	ld c, $01
A0FGraphics_41B3::
	push af
	push bc
	push de
	push hl
	call CopyTwoPlaneTilemap
	pop hl
	pop de
	pop bc
	pop af
	inc de
	inc a
	cp a, $78
	jr c, A0FGraphics_41B3
	ret
ASSERT @ == $61C5
