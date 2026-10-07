; PROBABLE banked callback dispatch with byte-wrapped triple indexing.
; SYNTHETIC prefixes and independently forced restore tails; no target execution.
SECTION "Banked callback dispatch", ROM0[$23E4]
DispatchBankedCallback::
	ld c, a
	add a, a
	add a, c
	ld e, a
	ld d, $00
	ld hl, BankedCallbackRecords0
	add hl, de
	ld a, b
	or a, a
	jr nz, DispatchCallbackWindowB
	push hl
	ld hl, $C107
	ld a, [$C10E]
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ldh a, [$FFAB]
	ld [hli], a
	ldh a, [$FFAC]
	ld [hl], a
	ld a, [$C10E]
	inc a
	ld [$C10E], a
	pop hl
	ld a, [hli]
	ld e, [hl]
	inc hl
	ld d, [hl]
	di
	ld [$27FF], a
	ldh [$FFAB], a
	ld [$C113], a
	xor a, a
	ld [$2800], a
	ldh [$FFAC], a
	ld [$C114], a
	ei
	ld bc, RestoreCallbackWindowA
	push bc
	ld l, e
	ld h, d
	jp hl
RestoreCallbackWindowA::
	ld a, [$C10E]
	dec a
	ld [$C10E], a
	ld hl, $C107
	ld a, [$C10E]
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hli]
	ldh [$FFAB], a
	ld a, [hl]
	ldh [$FFAC], a
	di
	ldh a, [$FFAB]
	ld [$27FF], a
	ld [$C113], a
	ldh a, [$FFAC]
	ld [$2800], a
	ld [$C114], a
	ei
	ret
DispatchCallbackWindowB::
	push hl
	ld hl, $C10D
	ld a, [$C10F]
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ldh a, [$FFAD]
	ld [hli], a
	ldh a, [$FFAE]
	ld [hl], a
	ld a, [$C10F]
	inc a
	ld [$C10F], a
	pop hl
	ld a, [hli]
	ld e, [hl]
	inc hl
	ld d, [hl]
	di
	ld [$37FF], a
	ldh [$FFAD], a
	ld [$C115], a
	xor a, a
	ld [$3800], a
	ldh [$FFAE], a
	ld [$C116], a
	ei
	ld bc, RestoreCallbackWindowB
	push bc
	ld l, e
	ld h, d
	jp hl
RestoreCallbackWindowB::
	ld a, [$C10F]
	dec a
	ld [$C10F], a
	ld hl, $C10D
	ld a, [$C10F]
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hli]
	ldh [$FFAD], a
	ld a, [hl]
	ldh [$FFAE], a
	di
	ldh a, [$FFAD]
	ld [$37FF], a
	ld [$C115], a
	ldh a, [$FFAE]
	ld [$3800], a
	ld [$C116], a
	ei
	ret
BankedCallbackReturnOnly::
	ret
ASSERT @ == $24B9
