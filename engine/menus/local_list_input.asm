; PROBABLE input handler roles; unknown callees remain numeric.
; Native A $14, physical bank $0A lower half.
SECTION "Local list input", ROMX[$4940], BANK[$0A]
HandleLocalListInput::
	ldh a, [$FF98]
	and a, $80
	jr z, .at4991
	ld a, $9B
	call ResidentJump024F
	ld c, $00
	ld a, [$D004]
	cp a, $04
	jr z, .at495D
	ld a, [$D000]
	cp a, $02
	jr z, .at495D
	ld c, $01
.at495D:
	ld a, [$D003]
	ld b, a
	ld hl, $D007
	ld a, [$D002]
	add a, [hl]
	add a, c
	cp a, b
	jp nc, .at498B
	ld a, [hl]
	ld [$D008], a
	inc [hl]
	ld a, [hl]
	cp a, $05
	jp nz, .at498B
	xor a, a
	ld [hl], a
	ld a, [$D002]
	add a, $05
	ld [$D002], a
	call $50CF
	call $508A
	call $4E98
.at498B:
	call PrepareLocalDescription
	jp .at4C3D
.at4991:
	ldh a, [$FF98]
	and a, $40
	jr z, .at49CD
	ld a, $9B
	call ResidentJump024F
	ld hl, $D007
	ld a, [hl]
	ld [$D008], a
	ld a, [hl]
	dec [hl]
	and a, a
	jp nz, .at49C7
	ld a, [$D002]
	and a, a
	jr nz, .at49B3
	ld [hl], a
	jp .at49C7
.at49B3:
	ld a, $04
	ld [hl], a
	ld a, [$D002]
	sub a, $05
	ld [$D002], a
	call $50CF
	call $508A
	call $4E98
.at49C7:
	call PrepareLocalDescription
	jp .at4C3D
.at49CD:
	ldh a, [$FF97]
	and a, $01
	jp z, .at4B7E
	ld a, $9D
	call ResidentJump024F
	ld a, [$D000]
	cp a, $02
	jp z, .at4A7D
	ld a, [$D004]
	cp a, $04
	jr nz, .at4A06
	ld a, [$D001]
	ld [$C671], a
	ld a, [$D007]
	ld b, a
	ld a, [$D002]
	add a, b
	ld [$C5DE], a
	ld [$C81A], a
	call $455F
	xor a, a
	ld [$C5A3], a
	jp .at4C3D
.at4A06:
	xor a, a
	ld [$D016], a
	ld a, $02
	ld de, $5BEA
	call ResidentJump01E3
	xor a, a
	call ResidentJump01FE
	ld a, [$D01B]
	ld [$C1C2], a
	ld a, $04
	ld [$D01D], a
	ld a, [$D020]
	ld [$D01C], a
	ld hl, $D1E6
	ld a, [$D007]
	ld b, a
	ld a, [$D002]
	add a, b
	ld b, a
	ld a, [$D001]
	ld c, a
	call FindLocalListEntry
	cp a, $FF
	jp z, .at4C3D
	ld a, [$C5C3]
	cp a, $10
	jr nc, .at4A67
	ld a, [$D020]
	cp a, $02
	jr nz, .at4A51
	xor a, a
	ld [$D01C], a
.at4A51:
	ld hl, $5C1A
	ld bc, $0000
	call ResidentJump01EF
	ld a, $03
	ld [$D000], a
	ld a, $02
	ld [$D01E], a
	jp .at4C3D
.at4A67:
	ld hl, $5C26
	ld bc, $0000
	call ResidentJump01EF
	ld a, $03
	ld [$D000], a
	ld a, $03
	ld [$D01E], a
	jp .at4C3D
.at4A7D:
	ld hl, $D1E6
	ld d, $FF
.at4A82:
	ld a, [hli]
	inc hl
	cp a, $FF
	jr nz, .at4A82
	dec hl
	dec hl
	ld a, l
	ld [$C5C7], a
	ld a, h
	ld [$C5C8], a
	ld de, $0000
	ld a, [$D007]
	ld b, a
	ld a, [$D002]
	add a, b
	ld b, a
	ld a, [$D003]
	cp a, b
	jr nz, .at4AB4
	ld a, [$C5C7]
	ld [$C5C5], a
	ld a, [$C5C8]
	ld [$C5C6], a
	ld d, $FF
	jr .at4AC8
.at4AB4:
	ld a, [$D001]
	ld c, a
	call FindLocalListEntry
	cp a, $FF
	jp z, .at4C3D
	ld a, l
	ld [$C5C5], a
	ld a, h
	ld [$C5C6], a
.at4AC8:
	ld a, [$D00C]
	ld b, a
	ld a, [$D00B]
	add a, b
	ld b, a
	ld a, [$D00D]
	cp a, b
	jr nz, .at4AE7
	ld a, [$C5C7]
	ld [$C5C9], a
	ld a, [$C5C8]
	ld [$C5CA], a
	ld e, $FF
	jr .at4AFB
.at4AE7:
	ld a, [$D00A]
	ld c, a
	call FindLocalListEntry
	cp a, $FF
	jp z, .at4C3D
	ld a, l
	ld [$C5C9], a
	ld a, h
	ld [$C5CA], a
.at4AFB:
	ld a, [$C5C9]
	ld b, a
	ld a, [$C5C5]
	cp a, b
	jr nz, .at4B10
	ld a, [$C5CA]
	ld b, a
	ld a, [$C5C6]
	cp a, b
	jp z, .at4C3D
.at4B10:
	ld a, $FF
	cp a, d
	jr nz, .at4B23
	ld a, [$C5C9]
	ld l, a
	ld a, [$C5CA]
	ld h, a
	ld a, [$D001]
	ld b, a
	jr .at4B34
.at4B23:
	ld a, $FF
	cp a, e
	jr nz, .at4B49
	ld a, [$C5C5]
	ld l, a
	ld a, [$C5C6]
	ld h, a
	ld a, [$D00A]
	ld b, a
.at4B34:
	ld d, h
	ld e, l
	ld a, [hli]
	ld c, a
	inc hl
.at4B39:
	ld a, [hli]
	cp a, $FF
	jr z, .at4B42
	ld [de], a
	inc de
	jr .at4B39
.at4B42:
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	jr .at4B5F
.at4B49:
	ld a, [$C5C9]
	ld l, a
	ld a, [$C5CA]
	ld h, a
	ld a, [$C5C5]
	ld e, a
	ld a, [$C5C6]
	ld d, a
	ld a, [hl]
	ld c, a
	ld a, [de]
	ld [hl], a
	ld a, c
	ld [de], a
.at4B5F:
	ld a, $09
	ld [$C67E], a
	call ResidentJump02A0
	call BuildLocalMinigameTitleList
	call $50CF
	call $508A
	call $4E98
	call PrepareLocalDescription
	ld a, $01
	ld [$D000], a
	jp .at4C3D
.at4B7E:
	ld a, [$D004]
	cp a, $04
	jr z, .at4BC7
	ldh a, [$FF98]
	and a, $02
	jr z, .at4BC7
	ld a, $9E
	call ResidentJump024F
	ld a, [$D000]
	cp a, $02
	jr z, .at4BC0
	ld a, $FF
	ld [$C671], a
	xor a, a
	ld [$C5A3], a
	call ResidentJump0288
	ld a, [$C703]
	and a, a
	jp z, .at4C3D
	ld a, [$D001]
	ld [$C733], a
	ld a, [$D002]
	ld b, a
	ld a, [$D007]
	add a, b
	ld [$C734], a
	call ResidentJump028B
	jr .at4C3D
.at4BC0:
	ld a, $01
	ld [$D000], a
	jr .at4C3D
.at4BC7:
	ldh a, [$FF98]
	and a, $10
	jr z, .at4BDF
	ld a, $9C
	call ResidentJump024F
	ld hl, $D001
	inc [hl]
	ld a, [hl]
	cp a, $07
	jr nz, .at4BF6
	xor a, a
	ld [hl], a
	jr .at4BF6
.at4BDF:
	ldh a, [$FF98]
	and a, $20
	jr z, .at4C19
	ld a, $9C
	call ResidentJump024F
	ld hl, $D001
	dec [hl]
	ld a, [hl]
	cp a, $FF
	jr nz, .at4BF6
	ld a, $06
	ld [hl], a
.at4BF6:
	ld a, [$D007]
	ld [$D008], a
	ld a, $08
	ld [$D014], a
	xor a, a
	ld [$D002], a
	ld [$D007], a
	call BuildLocalMinigameTitleList
	call $50CF
	call $508A
	call $4E98
	call PrepareLocalDescription
	jr .at4C3D
.at4C19:
	ldh a, [$FF98]
	and a, $08
	jr z, .at4C3D
	ld a, [$D001]
	swap a
	add a, $76
	ld l, a
	ld a, $D1
	adc a, $00
	ld h, a
	ld de, $C74E
	ld b, $10
.at4C31:
	ld a, [hli]
	ld [de], a
	inc de
	and a, a
	jr z, .at4C3A
	dec b
	jr nz, .at4C31
.at4C3A:
	call $3D11
.at4C3D:
	ret
.end:
ASSERT .end - HandleLocalListInput == $2FE
