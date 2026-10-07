; PROBABLE original fixed-width arithmetic, reached through resident thunks.
; SYNTHETIC full input domains/edge cases; not natural caller admissibility.
SECTION "Arithmetic 2012-2022", ROM0[$2012]
ResidualROM00_2012::
MultiplyAByCLowByte::
	push de
	ld b, $08
	ld d, a
	xor a, a
Arithmetic_2017::
	sla a
	rlc c
	jr nc, Arithmetic_201E
	add a, d
Arithmetic_201E::
	dec b
	jr nz, Arithmetic_2017
	pop de
	ret
ASSERT @ == $2023

SECTION "Arithmetic 2023-2034", ROM0[$2023]
MultiplyAByCToHL::
	ld hl, $0000
	ld b, $08
	ld e, a
	ld d, $00
Arithmetic_202B::
	add hl, hl
	rlc c
	jr nc, Arithmetic_2031
	add hl, de
Arithmetic_2031::
	dec b
	jr nz, Arithmetic_202B
	ret
ASSERT @ == $2035

SECTION "Arithmetic 2035-2045", ROM0[$2035]
MultiplyDEByBCLowWord::
	ld hl, $0000
	ld a, $10
Arithmetic_203A::
	add hl, hl
	sla e
	rl d
	jr nc, Arithmetic_2042
	add hl, bc
Arithmetic_2042::
	dec a
	jr nz, Arithmetic_203A
	ret
ASSERT @ == $2046

SECTION "Arithmetic 2046-2056", ROM0[$2046]
DivideByteByByte::
	ld l, a
	ld h, $00
	ld b, $08
Arithmetic_204B::
	add hl, hl
	ld a, h
	cp a, c
	jr c, Arithmetic_2053
	sub a, c
	ld h, a
	inc l
Arithmetic_2053::
	dec b
	jr nz, Arithmetic_204B
	ret
ASSERT @ == $2057

SECTION "Arithmetic 2057-2069", ROM0[$2057]
DivideWordByByte::
	ld e, $00
	ld b, $10
Arithmetic_205B::
	add hl, hl
	rl e
	ld a, e
	cp a, c
	jr c, Arithmetic_2065
	sub a, c
	ld e, a
	inc l
Arithmetic_2065::
	dec b
	jr nz, Arithmetic_205B
	ld h, e
	ret
ASSERT @ == $206A
