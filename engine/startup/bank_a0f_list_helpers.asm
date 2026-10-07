; PROBABLE original list/redraw dependency; bounded synthetic CPU evidence.
SECTION "A0F list helper 6496-64AD", ROMX[$6496], BANK[$07]
IsA0FNonMarkerCountBelowCapacity::
	ld a, [$C76D]
	ld b, a
	ld a, [$C76C]
	sub a, b
	ld b, a
	ld a, [$C76F]
	ld c, a
	ld a, b
	cp a, c
	jr c, A0FList_44AB
	ld a, $00
	jr A0FList_44AD
A0FList_44AB::
	ld a, $01
A0FList_44AD::
	ret
ASSERT @ == $64AE

; PROBABLE original list/redraw dependency; bounded synthetic CPU evidence.
SECTION "A0F list helper 674C-67A9", ROMX[$674C], BANK[$07]
DrawA0FMarkedTextRow::
	ldh a, [$FF4F]
	and a, $01
	push af
	xor a, a
	ldh [$FF4F], a
	xor a, a
	ld [$C1BC], a
	ld [$C1BD], a
	ld a, $00
	ld [$C1BA], a
	ld d, $00
	ld a, [$C1A7]
	dec a
	ld e, a
	ld bc, $0020
	call ResidentJump0231
	ld a, [$C1A4]
	ld b, $00
	ld c, a
	add hl, bc
	ld bc, $9800
	add hl, bc
	ld a, [$C770]
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, $88
	ld e, a
	ld a, [$C771]
	ld b, a
A0FList_4788::
	di
A0FList_4789::
	ldh a, [$FF41]
	and a, $02
	jr nz, A0FList_4789
	ld [hl], e
	ld a, $01
	ldh [$FF4F], a
	ld a, $07
	ld [hl], a
	ld a, $00
	ldh [$FF4F], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, A0FList_4788
	inc hl
	dec b
	jr nz, A0FList_4788
	pop af
	ldh [$FF4F], a
	ret
ASSERT @ == $67AA
