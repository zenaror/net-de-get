; PROBABLE original color transition; synthetic preparation and tick probes.
SECTION "Color transition 07E7-0804", ROM0[$07E7]
ResidualROM00_07E7::
PrepareColorSubtractTransition::
	push af
	ld de, $C422
	ld c, $40
	call ExpandInvertedColorDeltas
	ld c, $C0
	ld hl, $C2A2
ColorTransition_07F5::
	xor a, a
	ld [hli], a
	ld a, $F8
	ld [hli], a
	dec c
	jr nz, ColorTransition_07F5
	pop af
	call ScaleColorDeltaWords
	ld [$C21F], a
	ret
ASSERT @ == $0805

; PROBABLE original color transition; synthetic preparation and tick probes.
SECTION "Color transition 0805-082F", ROM0[$0805]
PrepareColorAddTransition::
	push af
	ld de, $C2A2
	ld c, $40
	call ExpandPackedColorComponents
	ld c, $C0
	ld hl, $C2A3
ColorTransition_0813::
	ld a, $F8
	sub a, [hl]
	inc hl
	inc hl
	rlca
	rlca
	rlca
	ld b, a
	and a, $C0
	ld [de], a
	inc de
	ld a, b
	and a, $07
	ld [de], a
	inc de
	dec c
	jr nz, ColorTransition_0813
	pop af
	call ScaleColorDeltaWords
	ld [$C220], a
	ret
ASSERT @ == $0830

; PROBABLE original color transition; synthetic preparation and tick probes.
SECTION "Color transition 0830-088C", ROM0[$0830]
AdvanceColorTransition::
	ld a, [$C220]
	and a, a
	jr z, ColorTransition_085F
	dec a
	ld [$C220], a
	ld c, $C0
	ld de, $C2A2
	ld hl, $C422
ColorTransition_0842::
	ld a, [de]
	add a, [hl]
	ld [de], a
	inc de
	inc hl
	ld a, [de]
	adc a, [hl]
	ld [de], a
	inc de
	inc hl
	dec c
	jr nz, ColorTransition_0842
	ld hl, $C2A3
	ld de, $C222
	call Pack64ColorComponents
	ld a, $01
	ld [$C221], a
	jr ColorTransition_088C
ColorTransition_085F::
	ld a, [$C21F]
	and a, a
	jr z, ColorTransition_088C
	dec a
	ld [$C21F], a
	ld c, $C0
	ld de, $C2A2
	ld hl, $C422
ColorTransition_0871::
	ld a, [de]
	sub a, [hl]
	ld [de], a
	inc hl
	inc de
	ld a, [de]
	sbc a, [hl]
	ld [de], a
	inc de
	inc hl
	dec c
	jr nz, ColorTransition_0871
	ld hl, $C2A3
	ld de, $C222
	call Pack64ColorComponents
	ld a, $01
	ld [$C221], a
ColorTransition_088C::
	ret
ASSERT @ == $088D

; PROBABLE original color transition; synthetic preparation and tick probes.
SECTION "Color transition 088D-08F1", ROM0[$088D]
ScaleColorDeltaWords::
	cp a, $02
	jr z, ColorTransition_08EF
	jr c, ColorTransition_08C0
	sub a, $02
	ld [$C5A2], a
	ld c, $C0
	ld hl, $C422
ColorTransition_089D::
	ld a, [$C5A2]
	ld b, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	dec hl
ColorTransition_08A5::
	sla e
	rl d
	dec b
	jr nz, ColorTransition_08A5
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
	dec c
	jr nz, ColorTransition_089D
	ld a, [$C5A2]
	add a, LOW(ColorTransitionCountPrefix)
	ld l, a
	ld a, HIGH(ColorTransitionCountPrefix)
	adc a, $00
	ld h, a
	ld a, [hl]
	ret
ColorTransition_08C0::
	ld b, a
	ld a, $02
	sub a, b
	ld [$C5A2], a
	ld c, $C0
	ld hl, $C422
ColorTransition_08CC::
	ld a, [$C5A2]
	ld b, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	dec hl
ColorTransition_08D4::
	srl d
	rr e
	dec b
	jr nz, ColorTransition_08D4
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
	dec c
	jr nz, ColorTransition_08CC
	ld a, [$C5A2]
	add a, LOW(ColorTransitionRightCounts)
	ld l, a
	ld a, HIGH(ColorTransitionCountPrefix)
	adc a, $00
	ld h, a
	ld a, [hl]
	ret
ColorTransition_08EF::
	ld a, $20
	ret
ASSERT @ == $08F2
