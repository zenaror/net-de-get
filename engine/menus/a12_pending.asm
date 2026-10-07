; PROBABLE pending text and action tails; static and synthetic evidence only.
; Six-byte rows are indexed by wrapped (C73B-1); there is no range clamp.
SECTION "A12 pending 5C2F-5C54", ROMX[$5C2F], BANK[$09]
QueueA12PendingText::
	ld a, $00
	call PrepareA12TextRegion
	call ShowA12TextWindow
	ld de, A12PendingRecords
	ld h, $06
	ld a, [$C73B]
	dec a
	ld l, a
	call MultiplyA12HLBytes
	add hl, de
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call ResidentJump01E9
	ld a, $FF
	ld [$C601], a
	ret
ASSERT @ == $5C55

SECTION "A12 pending 5C55-5C76", ROMX[$5C55], BANK[$09]
DispatchA12PendingAction::
	ld de, A12PendingRecords
	ld h, $06
	ld a, [$C73B]
	dec a
	ld l, a
	call MultiplyA12HLBytes
	add hl, de
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	cp a, $00
	ret z
	cp a, $01
	jr z, ApplyA12PendingAction1
	cp a, $02
	jr z, ApplyA12PendingAction2
	cp a, $03
	jr z, ApplyA12PendingAction3
	ret
ASSERT @ == $5C77

SECTION "A12 pending 5C77-5CA3", ROMX[$5C77], BANK[$09]
ApplyA12PendingAction1::
	ld a, $06
	ld [$C708], a
	ld a, $04
	ld [$C214], a
	ld a, $01
	ld [$C706], a
	xor a, a
	ld [$C738], a
	ld a, $00
	ld [$C213], a
	ld a, $00
	ld [$C1C4], a
	ld a, $04
	ld hl, $53B2
	call StartColorAddTransition
	ld a, [$C5A3]
	inc a
	ld [$C5A3], a
	ret
ASSERT @ == $5CA4

SECTION "A12 pending 5CA4-5CD0", ROMX[$5CA4], BANK[$09]
ApplyA12PendingAction2::
	ld a, $06
	ld [$C709], a
	ld a, $04
	ld [$C214], a
	ld a, $02
	ld [$C706], a
	xor a, a
	ld [$C738], a
	ld a, $00
	ld [$C213], a
	ld a, $00
	ld [$C1C4], a
	ld a, $04
	ld hl, $5432
	call StartColorAddTransition
	ld a, [$C5A3]
	inc a
	ld [$C5A3], a
	ret
ASSERT @ == $5CD1

SECTION "A12 pending 5CD1-5CFE", ROMX[$5CD1], BANK[$09]
ApplyA12PendingAction3::
	ld a, $06
	ld [$C708], a
	ld [$C709], a
	ld [$C70A], a
	ld a, $05
	ld [$C214], a
	xor a, a
	ld [$C738], a
	ld a, $00
	ld [$C213], a
	ld a, $00
	ld [$C1C4], a
	ld a, $04
	ld hl, $54B2
	call StartColorAddTransition
	ld a, [$C5A3]
	inc a
	ld [$C5A3], a
	ret
ASSERT @ == $5CFF
