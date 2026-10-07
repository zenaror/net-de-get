; PROBABLE original resource grid/mode cycle; forced complete CPU calls.
SECTION "A0F grid helper 655D-659F", ROMX[$655D], BANK[$07]
ResidualROM07_655D::
CycleA0FResourceMode::
	ld a, [$C76A]
	inc a
	cp a, $04
	jr nz, A0FGrid_4567
	ld a, $00
A0FGrid_4567::
	ld a, a
	ld [$C76A], a
	call DrawA0FResourceGrid - $2000
	ld a, [$C76A]
	call SelectA0FModeResourcePointer - $2000
	ld b, $94
	cp a, $01
	jr nz, A0FGrid_457E
	ld b, $96
	jr A0FGrid_4594
A0FGrid_457E::
	cp a, $02
	jr nz, A0FGrid_4586
	ld b, $98
	jr A0FGrid_4594
A0FGrid_4586::
	cp a, $03
	jr nz, A0FGrid_4594
	ld b, $92
	ld a, [$C765]
	or a, a
	jr z, A0FGrid_4594
	ld b, $96
A0FGrid_4594::
	ld a, b
	ld [$C775], a
	inc a
	ld [$C776], a
	call DrawA0FModeIndicatorRow - $2000
	ret
ASSERT @ == $65A0

; PROBABLE original resource grid/mode cycle; forced complete CPU calls.
SECTION "A0F grid helper 668B-674B", ROMX[$668B], BANK[$07]
ResidualROM07_668B::
DrawA0FResourceGrid::
	push af
	ld a, $00
	ld c, $00
	ld de, A0FTextRegionRecordPrefix - $2000
	call ResidentJump01E3
	pop af
	push af
	ld b, $00
	cp a, $02
	jr nc, A0FGrid_46A4
	ld b, $30
	ld c, $70
	jr A0FGrid_46A8
A0FGrid_46A4::
	ld b, $10
	ld c, $50
A0FGrid_46A8::
	ld a, $01
	ld [$C771], a
	push bc
	ld a, b
	ld [$C770], a
	call DrawA0FMarkedTextRow - $2000
	pop bc
	ld a, c
	ld [$C770], a
	call DrawA0FMarkedTextRow - $2000
	ld a, [$C765]
	or a, a
	jr z, A0FGrid_46DF
	ld c, $00
	ld b, $00
	call ResidentJump0219
	ld bc, $99E0
	add hl, bc
	push hl
	xor a, a
	ldh [$FF4F], a
	ld hl, A0FGridFooterNonzero - $2000
	pop de
	ld b, $14
	ld c, $01
	call CopyTwoPlaneTilemap
	jr A0FGrid_46F9
A0FGrid_46DF::
	ld c, $00
	ld b, $00
	call ResidentJump0219
	ld bc, $99E0
	add hl, bc
	push hl
	xor a, a
	ldh [$FF4F], a
	ld hl, A0FGridFooterZero - $2000
	pop de
	ld b, $14
	ld c, $01
	call CopyTwoPlaneTilemap
A0FGrid_46F9::
	pop af
	call SelectA0FModeResourcePointer - $2000
	ld c, $00
	ld d, $00
	ld a, $00
	ld [$C1C2], a
A0FGrid_4706::
	ld b, $00
	push de
A0FGrid_4709::
	push bc
	ld a, [$C765]
	or a, a
	jr z, A0FGrid_4724
	ld a, [$C76A]
	and a, $01
	jr z, A0FGrid_4724
	ld a, d
	cp a, $03
	jr c, A0FGrid_4724
	ld hl, A0FGridFallbackStream - $2000
	call ResidentJump01EF
	jr A0FGrid_4727
A0FGrid_4724::
	call ResidentJump01EF
A0FGrid_4727::
	pop bc
	ld a, b
	add a, $06
	ld b, a
	cp a, $12
	jr nc, A0FGrid_4739
	ld a, [$C1C2]
	inc a
	ld [$C1C2], a
	jr A0FGrid_4709
A0FGrid_4739::
	ld a, c
	add a, $02
	ld c, a
	pop de
	inc d
	ld a, d
	cp a, $04
	jr nc, A0FGrid_4746
	jr A0FGrid_4706
A0FGrid_4746::
	ld a, $00
	ld [$C1C2], a
	ret
ASSERT @ == $674C
