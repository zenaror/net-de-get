SECTION "VRAM copy thunk 0198", ROM0[$0198]
CopyVRAMBytes::
	jp CopyVRAMBytesBody
ASSERT @ == $019B

; PROBABLE static copy roles; forced-entry probes do not validate hardware timing.
; Preserve no-op LD A,A and all STAT/DI/EI sequences from the reference.
SECTION "VRAM copy thunks", ROM0[$019E]
CopyBankedVRAMBytes::
	jp CopyBankedVRAMBytesBody
CopyTilemapPlane::
	jp CopyTilemapPlaneBody
.end:
ASSERT .end - CopyBankedVRAMBytes == 6

SECTION "Banked two plane copy thunk", ROM0[$01A7]
CopyBankedTwoPlaneTilemap::
	jp CopyBankedTwoPlaneTilemapBody
.end:
ASSERT .end - CopyBankedTwoPlaneTilemap == 3

SECTION "VRAM byte copy", ROM0[$0A50]
CopyVRAMBytesBody::
.at0A50:
	di
.at0A51:
	ldh a, [$FF41]
	and $02
	jr nz, .at0A51
	ld a, [hl]
	ld [de], a
	ei
	ldh a, [$FF41]
	and $02
	jr nz, .at0A50
	inc hl
	inc de
	dec bc
	ld a, b
	or a, c
	jr nz, .at0A50
	ret
.end:
ASSERT .end - CopyVRAMBytesBody == $18

SECTION "Banked VRAM byte copy", ROM0[$0A68]
CopyBankedVRAMBytesBody::
	ld a, h
	cp $60
	jr nc, .at0AA9
	ldh a, [$FFAB]
	ldh [$FF9D], a
	ldh a, [$FFAC]
	ldh [$FF9E], a
	di
	ld a, [$C21C]
	ld [$27FF], a
	ldh [$FFAB], a
	ld [$C113], a
	ld a, [$C21D]
	ld [$2800], a
	ldh [$FFAC], a
	ld [$C114], a
	ei
	call CopyVRAMBytesBody
	di
	ldh a, [$FF9D]
	ldh [$FFAB], a
	ld [$27FF], a
	ld [$C113], a
	ldh a, [$FF9E]
	ldh [$FFAC], a
	ld a, a
	ld [$2800], a
	ld [$C114], a
	ei
	jr .at0AE3
.at0AA9:
	ldh a, [$FFAD]
	ldh [$FF9D], a
	ldh a, [$FFAE]
	ldh [$FF9E], a
	di
	ld a, [$C21C]
	ld [$37FF], a
	ldh [$FFAD], a
	ld [$C115], a
	ld a, [$C21D]
	ld [$3800], a
	ldh [$FFAE], a
	ld [$C116], a
	ei
	call CopyVRAMBytesBody
	di
	ldh a, [$FF9D]
	ldh [$FFAD], a
	ld [$37FF], a
	ld [$C115], a
	ldh a, [$FF9E]
	ldh [$FFAE], a
	ld a, a
	ld [$3800], a
	ld [$C116], a
	ei
.at0AE3:
	ret
.end:
ASSERT .end - CopyBankedVRAMBytesBody == $7C

SECTION "Single plane tilemap copy", ROM0[$0AE4]
CopyTilemapPlaneBody::
	ld a, b
	ldh [$FF9D], a
.at0AE7:
	ldh a, [$FF9D]
	ld b, a
.at0AEA:
	push bc
.at0AEB:
	di
.at0AEC:
	ldh a, [$FF41]
	and $02
	jr nz, .at0AEC
	ld a, [hl]
	ld [de], a
	ei
	ldh a, [$FF41]
	and $02
	jr nz, .at0AEB
	inc hl
	pop bc
	inc de
	dec b
	jr nz, .at0AEA
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
	jr nz, .at0AE7
	ret
.end:
ASSERT .end - CopyTilemapPlaneBody == $31

SECTION "Banked two plane tilemap copy", ROM0[$0B5F]
CopyBankedTwoPlaneTilemapBody::
	ldh a, [$FF4F]
	and $01
	push af
	xor a
	ldh [$FF4F], a
	ld a, h
	cp $60
	jr nc, .at0BE3
	ldh a, [$FFAB]
	ldh [$FFA5], a
	ldh a, [$FFAC]
	ldh [$FFA6], a
	di
	ld a, [$C21C]
	ld [$27FF], a
	ldh [$FFAB], a
	ld [$C113], a
	ld a, [$C21D]
	ld [$2800], a
	ldh [$FFAC], a
	ld [$C114], a
	ei
.at0B8C:
	push bc
	push de
	ld a, b
	ldh [$FF9D], a
.at0B91:
	ldh a, [$FF9D]
	ld b, a
.at0B94:
	push bc
.at0B95:
	di
.at0B96:
	ldh a, [$FF41]
	and $02
	jr nz, .at0B96
	ld a, [hl]
	ld [de], a
	ei
	ldh a, [$FF41]
	and $02
	jr nz, .at0B95
	inc hl
	pop bc
	inc de
	dec b
	jr nz, .at0B94
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
	jr nz, .at0B91
	pop de
	pop bc
	ldh a, [$FF4F]
	xor $01
	ldh [$FF4F], a
	and $01
	jr nz, .at0B8C
	di
	ldh a, [$FFA5]
	ldh [$FFAB], a
	ld [$27FF], a
	ld [$C113], a
	ldh a, [$FFA6]
	ldh [$FFAC], a
	ld a, a
	ld [$2800], a
	ld [$C114], a
	ei
	jr .at0C58
.at0BE3:
	ldh a, [$FFAD]
	ldh [$FFA5], a
	ldh a, [$FFAE]
	ldh [$FFA6], a
	di
	ld a, [$C21C]
	ld [$37FF], a
	ldh [$FFAD], a
	ld [$C115], a
	ld a, [$C21D]
	ld [$3800], a
	ldh [$FFAE], a
	ld [$C116], a
	ei
.at0C03:
	push bc
	push de
	ld a, b
	ldh [$FF9D], a
.at0C08:
	ldh a, [$FF9D]
	ld b, a
.at0C0B:
	push bc
.at0C0C:
	di
.at0C0D:
	ldh a, [$FF41]
	and $02
	jr nz, .at0C0D
	ld a, [hl]
	ld [de], a
	ei
	ldh a, [$FF41]
	and $02
	jr nz, .at0C0C
	inc hl
	pop bc
	inc de
	dec b
	jr nz, .at0C0B
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
	jr nz, .at0C08
	pop de
	pop bc
	ldh a, [$FF4F]
	xor $01
	ldh [$FF4F], a
	and $01
	jr nz, .at0C03
	di
	ldh a, [$FFA5]
	ldh [$FFAD], a
	ld [$37FF], a
	ld [$C115], a
	ldh a, [$FFA6]
	ldh [$FFAE], a
	ld a, a
	ld [$3800], a
	ld [$C116], a
	ei
.at0C58:
	pop af
	ldh [$FF4F], a
	ret
.end:
ASSERT .end - CopyBankedTwoPlaneTilemapBody == $FD

