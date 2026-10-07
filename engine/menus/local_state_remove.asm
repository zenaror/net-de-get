; PROBABLE static handler; state number is its literal table index.
; Native A $14; physical RGBDS bank $0A lower half.
; No new natural execution, flash-operation or capacity evidence.
SECTION "Local menu state 5", ROMX[$43C0], BANK[$0A]
LocalMenuState5::
	ld a, [$D01C]
	and a
	jp nz, .at4484
	ld a, [$D007]
	ld b, a
	ld a, [$D002]
	add a, b
	ld c, a
	ld a, [$D003]
	cp c
	jp z, .at4484
	push bc
	push de
	push hl
	xor a
	ld [$C001], a
	call $517D
	ld a, $02
	ld de, $5BEA
	call $01E3
	xor a
	call $01FE
	ld hl, $5C40
	ld bc, $0000
	call $01EF
	pop hl
	pop de
	pop bc
	ld b, c
	ld a, [$D001]
	ld c, a
	call $4CDA
	ld a, [$C5C3]
	ld [$D013], a
	ld d, h
	ld e, l
	inc hl
	inc hl
.at440B:
	ld a, [hli]
	ld [de], a
	inc de
	cp $FF
	jr z, .at4417
	ld a, [hli]
	ld [de], a
	inc de
	jr .at440B
.at4417:
	xor a
	ld [$C5CC], a
	ld de, $D1E6
	ld a, $02
	ld [$C67E], a
	ld a, [$D06B]
	ld c, a
	ld a, [$C5C3]
	ld b, a
	sub $10
	call $02A0
	ld bc, $02A3
	ld de, $3ED8
	call $01B6
	ld a, l
	or h
	jr z, .at4456
	ld a, [$C5C5]
	and $F0
	swap a
	ld [$D06B], a
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [$D06B]
	ld [hl], a
	call $01B9
.at4456:
	ld a, $09
	ld [$C67E], a
	call $02A0
	ld a, [$D013]
	call $02AC
	call $35D7
	call $1362
	ld hl, $6009
	ld de, $DCF7
	ld b, $04
.at4472:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .at4472
	call $1359
	ld de, $DCF7
	call $01BC
	call $01B3
.at4484:
	ld hl, $450F
	ld de, $9880
	ld bc, $1402
	call $01A4
	ld hl, $450F
	ld de, $98C0
	ld bc, $1402
	call $01A4
	ld hl, $450F
	ld de, $9900
	ld bc, $1402
	call $01A4
	call $517D
	ld hl, $450F
	ld de, $9940
	ld bc, $1402
	call $01A4
	ld hl, $450F
	ld de, $9980
	ld bc, $1402
	call $01A4
	call BuildLocalMinigameTitleList
	ld a, [$D007]
	ld b, a
	ld a, [$D002]
	add a, b
	ld c, a
	ld a, [$D003]
	cp c
	jp nz, .at44EB
	ld hl, $D007
	dec [hl]
	ld a, [hl]
	cp $FF
	jr nz, .at44EB
	ld [hl], $00
	ld a, [$D002]
	sub $05
	jr c, .at44EB
	ld [$D002], a
.at44EB:
	call $50CF
	call $508A
	call $4E98
	call $46C1
	call $5B31
	ld a, $91
	call $024F
	ld a, [$D005]
	ld b, a
	ld a, $70
	sub b
	call $457E
	ld a, $01
	ld [wLocalMenuState], a
	ret
.end:
ASSERT .end - LocalMenuState5 == $14F
