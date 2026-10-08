; PROBABLE clamped selection index to byte-divided page/row/column fields.
; Zero limit/divisors and wrapped product retain original behavior.
SECTION "Selection index 318A-31C2", ROM0[$318A]
ResidualROM00_318A::
SetSelectionIndexFields::
	push af
	ld a, [$C20F]
	ld b, a
	pop af
	cp a, b
	jr c, SelectionIndex_3197
	ld a, [$C20F]
	dec a
SelectionIndex_3197:
	push af
	ld a, [$C20E]
	ld c, a
	ld a, [$C20D]
	call MultiplyAByCLowByte
	ld c, a
	pop af
	call DivideByteByByte
	ld a, l
	ld [$C212], a
	ld [$C215], a
	ld a, [$C210]
	ld a, a
	ld c, a
	ld a, h
	call DivideByteByByte
	ld a, h
	ld [$C21B], a
	ld a, l
	ld [$C214], a
	ld [$C216], a
	ret
ASSERT @ == $31C3
