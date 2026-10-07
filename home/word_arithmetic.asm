; PROBABLE static reconstruction; no new natural trace.
SECTION "Word subtraction and comparison", ROM0[$2000]
SubtractDEFromHL::
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	ret nz
	inc l
	dec l
	ret
CompareHLAndDE::
	push de
	push hl
	call SubtractDEFromHL
	pop hl
	pop de
	ret
SubtractDEFromHLEnd:
ASSERT SubtractDEFromHLEnd - SubtractDEFromHL == $12
