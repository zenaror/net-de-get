; PROBABLE original action/helper; synthetic return/prefix evidence.
SECTION "A0F action helper 63BF-63EF", ROMX[$63BF], BANK[$07]
ResidualROM07_63BF::
SelectA0FModeResourcePointer::
	push af
	ld a, [$C765]
	and a, $01
	cp a, $01
	jr nz, A0FAction_43D0
	pop af
	and a, $01
	add a, $02
	jr A0FAction_43D1
A0FAction_43D0::
	pop af
A0FAction_43D1::
	cp a, $00
	jr nz, A0FAction_43DA
	ld hl, $5334
	jr A0FAction_43EF
A0FAction_43DA::
	cp a, $01
	jr nz, A0FAction_43E3
	ld hl, $537C
	jr A0FAction_43EF
A0FAction_43E3::
	cp a, $02
	jr nz, A0FAction_43EC
	ld hl, $53C4
	jr A0FAction_43EF
A0FAction_43EC::
	ld hl, $540C
A0FAction_43EF::
	ret
ASSERT @ == $63F0

; PROBABLE original action/helper; synthetic return/prefix evidence.
SECTION "A0F action helper 651F-655C", ROMX[$651F], BANK[$07]
TrimA0FListTail::
	ld a, [$C76C]
	cp a, $00
	jr z, A0FAction_455C
	ld a, [$C76C]
	dec a
	ld [$C76C], a
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
	ld [hl], $00
	dec hl
	ld a, [hl]
	cp a, $FE
	jr c, A0FAction_4559
	ld [hl], $00
	ld a, [$C76C]
	dec a
	ld [$C76C], a
	ld a, [$C76D]
	dec a
	ld [$C76D], a
A0FAction_4559::
	call RedrawA0FListText - $2000
A0FAction_455C::
	ret
ASSERT @ == $655D

; PROBABLE original action/helper; synthetic return/prefix evidence.
SECTION "A0F action helper 6628-668A", ROMX[$6628], BANK[$07]
DrawA0FModeIndicatorRow::
	ld c, $00
	ld b, $00
	call ResidentJump0219
	ld bc, $9A02
	add hl, bc
	push hl
	xor a, a
	ldh [$FF4F], a
	ld hl, $C775
	pop de
	ld b, $02
	ld c, $01
	call CopyTwoPlaneTilemap
	ld a, $8E
	ld [$C775], a
	ld a, $8F
	ld [$C776], a
	ld c, $00
	ld b, $00
	call ResidentJump0219
	ld bc, $9A08
	add hl, bc
	push hl
	xor a, a
	ldh [$FF4F], a
	ld hl, $C775
	pop de
	ld b, $02
	ld c, $01
	call CopyTwoPlaneTilemap
	ld a, $90
	ld [$C775], a
	ld a, $91
	ld [$C776], a
	ld c, $00
	ld b, $00
	call ResidentJump0219
	ld bc, $9A0E
	add hl, bc
	push hl
	xor a, a
	ldh [$FF4F], a
	ld hl, $C775
	pop de
	ld b, $02
	ld c, $01
	call CopyTwoPlaneTilemap
	ret
ASSERT @ == $668B
