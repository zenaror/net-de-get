; PROBABLE static queue/draw roles, no new natural callback or LCD timing trace.
; Native A $14, physical RGBDS bank $0A lower half.
; CPU fixtures enter at $5A0E, after the two external callbacks.
SECTION "Pending local menu transfers", ROMX[$5A08], BANK[$0A]
ProcessLocalMenuTransfers::
	call $FF80
	call $018C
ProcessLocalMenuTransfersAfterCallbacks::
	ld a, [$D021]
	and a
	jp z, .at5AEB
	ld a, $0A
	ld [$C5DA], a
	ld hl, $D028
.at5A1D:
	ld a, [hl]
	ld [$D022], a
	ld a, $FF
	ld [hli], a
	ld a, [hl]
	ld [$D023], a
	ld a, $FF
	ld [hli], a
	ld a, [hli]
	ld [$D024], a
	ld a, [hli]
	ld [$D025], a
	ld a, [hli]
	ld [$D026], a
	ld a, [hli]
	ld [$D027], a
	ld a, [$D022]
	cp $FF
	jr nz, .at5A4A
	ld a, [$D023]
	cp $FF
	jp z, .at5ADD
.at5A4A:
	push hl
	ld a, [$D026]
	ld e, a
	ld a, [$D027]
	ld d, a
	ld a, [$D024]
	and $F8
	swap a
	rlca
	ld [$C5D9], a
.at5A5E:
	ld a, [$D025]
	ld c, a
	ld a, [$D022]
	ld [$C5D7], a
	ld l, a
	ld a, [$D023]
	ld h, a
	ld [$C5D8], a
.at5A70:
	ld a, [$C5D9]
	and a
	jr z, .at5A92
	ld b, a
.at5A77:
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	dec b
	jr nz, .at5A77
.at5A92:
	ld a, [$D024]
	and $04
	jr z, .at5AA5
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
.at5AA5:
	ld a, [$D024]
	and $03
	jr z, .at5AB3
	ld b, a
.at5AAD:
	ld a, [de]
	inc de
	ld [hli], a
	dec b
	jr nz, .at5AAD
.at5AB3:
	ld a, [$C5D7]
	add a, $20
	ld l, a
	ld [$C5D7], a
	jr nc, .at5AC7
	ld a, [$C5D8]
	adc a, $00
	ld h, a
	ld [$C5D8], a
.at5AC7:
	dec c
	jr nz, .at5A70
	ld a, [$D021]
	cp $80
	jr z, .at5ADC
	ldh a, [$FF4F]
	xor $01
	ldh [$FF4F], a
	and $01
	jp nz, .at5A5E
.at5ADC:
	pop hl
.at5ADD:
	ld a, [$C5DA]
	dec a
	ld [$C5DA], a
	jp nz, .at5A1D
	xor a
	ld [$D021], a
.at5AEB:
	ld a, [$D309]
	and a
	jr z, .at5B25
	xor a
	ld [$D309], a
	ld hl, $D34A
.at5AF8:
	ld de, $988D
	ld b, $0A
.at5AFD:
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, e
	add a, $1A
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	dec b
	jr nz, .at5AFD
	ldh a, [$FF4F]
	xor $01
	ldh [$FF4F], a
	and $01
	jp nz, .at5AF8
.at5B25:
	ret
.end:
ASSERT .end - ProcessLocalMenuTransfers == $11E
