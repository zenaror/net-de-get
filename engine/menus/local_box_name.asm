; PROBABLE static role, no translation. Native A $14 / physical bank $0A.
SECTION "Store local box name", ROMX[$4C3E], BANK[$0A]
StoreLocalBoxName::
	push de
	ld bc, $02A3
	ld de, $3ED8
	call OpenLocalStorageRecord
	pop de
	ld a, l
	or a, h
	jr z, .at4C6B
	ld a, [$D001]
	swap a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, l
	add a, $12
	ld l, a
	ld a, h
	adc a, $01
	ld h, a
	ld b, $10
.at4C62:
	ld a, [de]
	inc de
	ld [hli], a
	and a, a
	jr z, .at4C6B
	dec b
	jr nz, .at4C62
.at4C6B:
	call $01B9
	ret
.end:
ASSERT .end - StoreLocalBoxName == $31
