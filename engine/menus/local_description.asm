; PROBABLE static role, no translation. Native A $14 / physical bank $0A.
SECTION "Local description preparation", ROMX[$46C1], BANK[$0A]
PrepareLocalDescription::
	xor a, a
	ld [$D016], a
	ld a, $02
	ld de, $5BEA
	call ResidentJump01E3
	xor a, a
	call ResidentJump01FE
	ldh a, [$FFAD]
	ld [$C5C7], a
	ldh a, [$FFAE]
	ld [$C5C8], a
	ld hl, $D1E6
	ld a, [$D007]
	ld b, a
	ld a, [$D002]
	add a, b
	ld b, a
	inc b
	ld a, [$D001]
	ld c, a
.at46EC:
	ld a, [hli]
	ld [$C5C5], a
	cp a, $FF
	jp z, .at4774
	ld a, [hli]
	cp a, c
	jr nz, .at46EC
	dec b
	jr nz, .at46EC
	dec hl
	dec hl
	ld a, [$C5C5]
	cp a, $10
	jr nc, .at472F
	add a, $D8
	ld e, a
	ld a, $3C
	adc a, $00
	ld d, a
	di
	ld a, [de]
	ldh [$FFAD], a
	ld [$37FF], a
	ld [$C115], a
	xor a, a
	ldh [$FFAE], a
	ld [$3800], a
	ld [$C116], a
	ei
	ld hl, $6024
	ld de, $D30A
.at4727:
	ld a, [hli]
	ld [de], a
	inc de
	and a, a
	jr nz, .at4727
	jr .at4757
.at472F:
	sbc a, $10
	di
	ldh [$FFAD], a
	ld [$37FF], a
	ld [$C115], a
	ld a, $08
	ldh [$FFAE], a
	ld [$3800], a
	ld [$C116], a
	ei
	call $1362
	ld hl, $6024
	ld de, $D30A
.at474E:
	ld a, [hli]
	ld [de], a
	inc de
	and a, a
	jr nz, .at474E
	call DisableFlashReads
.at4757:
	ld a, [$D01B]
	ld [$D019], a
	ld a, $0A
	ld [$D017], a
	ld a, $D3
	ld [$D018], a
	xor a, a
	ld [$D01A], a
	ld a, [$C1BA]
	and a, a
	ld a, $05
	ld [$D016], a
.at4774:
	di
	ld a, [$C5C7]
	ldh [$FFAD], a
	ld [$37FF], a
	ld [$C115], a
	ld a, [$C5C8]
	ldh [$FFAE], a
	ld [$3800], a
	ld [$C116], a
	ei
	ret
.end:
ASSERT .end - PrepareLocalDescription == $CC
