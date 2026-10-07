; PROBABLE original insertion/marker predicate; forced CPU contracts.
SECTION "A0F insertion helper 63F0-6495", ROMX[$63F0], BANK[$07]
ResidualROM07_63F0::
InsertA0FSelectedListGlyph::
	ld hl, $C74E
	ld a, l
	add a, $00
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [$C76C]
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	push hl
	ld a, [$C76A]
	call SelectA0FModeResourcePointer - $2000
	ld a, [$C766]
	cp a, $05
	jr c, A0FInsert_4414
	add a, $01
A0FInsert_4414::
	cp a, $0B
	jr c, A0FInsert_441A
	add a, $01
A0FInsert_441A::
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [$C767]
	ld b, a
	rlca
	rlca
	rlca
	rlca
	ld c, a
	ld a, b
	rlca
	add a, c
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [$C765]
	or a, a
	jr z, A0FInsert_444A
	ld a, [$C76A]
	and a, $01
	jr z, A0FInsert_444A
	ld a, [$C767]
	cp a, $03
	jr c, A0FInsert_444A
	ld a, $10
	jr A0FInsert_444B
A0FInsert_444A::
	ld a, [hl]
A0FInsert_444B::
	pop hl
	ld e, a
	cp a, $FE
	jr nc, A0FInsert_445B
	call IsA0FNonMarkerCountBelowCapacity - $2000
	cp a, $00
	jr z, A0FInsert_4495
	ld a, e
	jr A0FInsert_4487
A0FInsert_445B::
	dec hl
	dec hl
	ld a, [hl]
	cp a, $FE
	jr nc, A0FInsert_4495
	inc hl
	ld c, [hl]
	ld b, $00
	call ClassifyA0FMarkerCompatibility - $2000
	cp a, $01
	jr z, A0FInsert_4477
	ld c, [hl]
	ld b, $40
	call ClassifyA0FMarkerCompatibility - $2000
	cp a, $00
	jr z, A0FInsert_4495
A0FInsert_4477::
	ld a, [hl]
	inc hl
	ld [hl], a
	dec hl
	ld a, e
	ld [hl], a
	inc hl
	ld a, [$C76D]
	inc a
	ld [$C76D], a
	jr A0FInsert_4488
A0FInsert_4487::
	ld [hl], a
A0FInsert_4488::
	inc hl
	ld [hl], $00
	ld a, [$C76C]
	inc a
	ld [$C76C], a
	call RedrawA0FListText - $2000
A0FInsert_4495::
	ret
ASSERT @ == $6496

; PROBABLE original insertion/marker predicate; forced CPU contracts.
SECTION "A0F insertion helper 64D7-651E", ROMX[$64D7], BANK[$07]
ResidualROM07_64D7::
ClassifyA0FMarkerCompatibility::
	ld a, e
	cp a, $FF
	jr nc, A0FInsert_4506
	ld a, b
	cp a, $00
	jr z, A0FInsert_44E9
	ld d, $85
	add a, d
	ld d, a
	ld a, c
	cp a, d
	jr z, A0FInsert_4518
A0FInsert_44E9::
	ld a, b
	ld d, $96
	add a, d
	ld d, a
	ld a, c
	cp a, d
	jr z, A0FInsert_451C
	ld a, b
	ld d, $8A
	add a, d
	ld d, a
	ld a, c
	cp a, d
	jr c, A0FInsert_451C
	ld a, b
	ld d, $9A
	add a, d
	ld d, a
	ld a, c
	cp a, d
	jr nc, A0FInsert_4506
	jr A0FInsert_4518
A0FInsert_4506::
	ld a, b
	ld d, $9F
	add a, d
	ld d, a
	ld a, c
	cp a, d
	jr c, A0FInsert_451C
	ld a, b
	ld d, $A4
	add a, d
	ld d, a
	ld a, c
	cp a, d
	jr nc, A0FInsert_451C
A0FInsert_4518::
	ld a, $01
	jr A0FInsert_451E
A0FInsert_451C::
	ld a, $00
A0FInsert_451E::
	ret
ASSERT @ == $651F
