; PROBABLE display-record expansion into the160-byte C000 shadow.
; Forced SYNTHETIC inputs; no natural OAM DMA or menu evidence.
SECTION "Queued display shadow 11AA-12B8", ROM0[$11AA]
ResidualROM00_11AA::
BuildQueuedDisplayShadow::
	ld hl, $C000
	ld bc, $00A0
DisplayShadow_11B0::
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, DisplayShadow_11B0
	ld hl, $C1C4
	ld a, [hl]
	or a, a
	jp z, DisplayShadow_12B8
	ld [hl], $00
	ld b, a
	di
	ld a, [$C1C6]
	cp a, $60
	jr nc, DisplayShadow_11DE
	ld a, [$C21C]
	ld [$27FF], a
	ld [$C113], a
	ld a, [$C21D]
	ld [$2800], a
	ld [$C114], a
	jr DisplayShadow_11F0
DisplayShadow_11DE::
	ld a, [$C21C]
	ld [$37FF], a
	ld [$C115], a
	ld a, [$C21D]
	ld [$3800], a
	ld [$C116], a
DisplayShadow_11F0::
	ld a, $28
	ld [$C1C7], a
	ld hl, $C1CA
	ld de, $C000
DisplayShadow_11FB::
	push bc
	push hl
	push de
	ld a, [hli]
	ld [$C1C8], a
	ld a, [hli]
	ld [$C1C9], a
	ld a, [hli]
	cp a, $FF
	jr nz, DisplayShadow_1239
	pop de
	ld a, [hl]
	push af
	ld a, [$C1C7]
	or a, a
	jr z, DisplayShadow_122A
	dec a
	ld [$C1C7], a
	ld a, [$C1C9]
	ld [de], a
	inc de
	ld a, [$C1C8]
	ld [de], a
	inc de
	pop af
	ld [de], a
	inc de
	ld a, [$C1B7]
	ld [de], a
	inc de
DisplayShadow_122A::
	pop hl
	pop bc
	push de
	ld de, $0004
	add hl, de
	pop de
	dec b
	jp nz, DisplayShadow_11FB
	jp DisplayShadow_128E
DisplayShadow_1239::
	push hl
	add a, a
	ld e, a
	ld d, $00
	ld a, [$C1C5]
	ld l, a
	ld a, [$C1C6]
	ld h, a
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	ld a, [hl]
	add a, a
	ld h, d
	ld l, e
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, d
	ld l, e
	pop de
	ld a, [hli]
	ld b, a
	and a, a
	jr z, DisplayShadow_1282
DisplayShadow_125E::
	ld a, [$C1C7]
	or a, a
	jr z, DisplayShadow_127F
	dec a
	ld [$C1C7], a
	ld a, [hl]
	ld c, a
	inc hl
	ld a, [$C1C9]
	add a, c
	ld [de], a
	inc de
	ld c, [hl]
	inc hl
	ld a, [$C1C8]
	add a, c
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
DisplayShadow_127F::
	dec b
	jr nz, DisplayShadow_125E
DisplayShadow_1282::
	pop hl
	pop bc
	push de
	ld de, $0004
	add hl, de
	pop de
	dec b
	jp nz, DisplayShadow_11FB
DisplayShadow_128E::
	ld a, [$C1C6]
	cp a, $60
	jr nc, DisplayShadow_12A7
	ldh a, [$FFAB]
	ld [$27FF], a
	ld [$C113], a
	ldh a, [$FFAC]
	ld [$2800], a
	ld [$C114], a
	jr DisplayShadow_12B7
DisplayShadow_12A7::
	ldh a, [$FFAD]
	ld [$37FF], a
	ld [$C115], a
	ldh a, [$FFAE]
	ld [$3800], a
	ld [$C116], a
DisplayShadow_12B7::
	ei
DisplayShadow_12B8::
	ret
ASSERT @ == $12B9
