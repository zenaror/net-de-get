; PROBABLE static two-plane tilemap copy; no hardware timing validation.
SECTION "Two plane tilemap copy thunk", ROM0[$01A4]
CopyTwoPlaneTilemap::
	jp CopyTwoPlaneTilemapBody
.end:
ASSERT .end - CopyTwoPlaneTilemap == 3

SECTION "Two plane tilemap copy", ROM0[$0B15]
CopyTwoPlaneTilemapBody::
	ldh a, [$FF4F]
	and $01
	push af
	xor a
	ldh [$FF4F], a
.at0B1D:
	push bc
	push de
	ld a, b
	ldh [$FF9D], a
.at0B22:
	ldh a, [$FF9D]
	ld b, a
.at0B25:
	push bc
.at0B26:
	di
.at0B27:
	ldh a, [$FF41]
	and $02
	jr nz, .at0B27
	ld a, [hl]
	ld [de], a
	ei
	ldh a, [$FF41]
	and $02
	jr nz, .at0B26
	inc hl
	pop bc
	inc de
	dec b
	jr nz, .at0B25
	push hl
	ld hl, $FF9D
	ld a, $20
	sub [hl]
	ld l, a
	ld h, $00
	add hl, de
	ld d, h
	ld e, l
	pop hl
	dec c
	ld a, c
	or a
	jr nz, .at0B22
	pop de
	pop bc
	ldh a, [$FF4F]
	xor $01
	ldh [$FF4F], a
	and $01
	jr nz, .at0B1D
	pop af
	ldh [$FF4F], a
	ret
.end:
ASSERT .end - CopyTwoPlaneTilemapBody == $4A
