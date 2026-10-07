; PROBABLE original list redraw; full forced glyph/terminator CPU chains.
; Counts wrap as bytes; metadata is not validated against the list here.
SECTION "A0F list redraw 65A0-6627", ROMX[$65A0], BANK[$07]
RedrawA0FListText::
	ld a, $46
	ld [$C1C2], a
	ld a, [$C765]
	and a, $01
	inc a
	ld c, $00
	ld de, A0FTextRegionRecordPrefix - $2000
	call ResidentJump01E3
	ld b, $00
	ld c, $00
	ld hl, $C74E
	call ResidentJump01EF
	ld a, $00
	ld [$C1C2], a
	call IsA0FNonMarkerCountBelowCapacity - $2000
	cp a, $00
	jp z, A0FRedraw_4627 - $2000
	ld hl, $9882
	ld a, b
	push af
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [$C76E]
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld d, h
	ld e, l
	ld hl, A0FListFirstVacantCell - $2000
	ld bc, $0101
	call CopyTwoPlaneTilemap
	pop af
	push af
	ld a, a
	ld [$C770], a
	ld a, $01
	ld [$C771], a
	call DrawA0FMarkedTextRow - $2000
	ld a, [$C76F]
	ld b, a
	pop af
	inc a
	cp a, b
	jr nc, A0FRedraw_4627
A0FRedraw_4600::
	push af
	ld hl, $9882
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [$C76E]
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld d, h
	ld e, l
	ld hl, A0FListFollowingVacantCell - $2000
	ld bc, $0101
	call CopyTwoPlaneTilemap
	ld a, [$C76F]
	ld b, a
	pop af
	inc a
	cp a, b
	jr c, A0FRedraw_4600
A0FRedraw_4627::
	ret
ASSERT @ == $6628
