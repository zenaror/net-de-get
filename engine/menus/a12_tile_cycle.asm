; PROBABLE variant2 stochastic paired-tile cycle, from its published caller.
; Direct current-VBK accesses: no LCD wait, resource-bank switch or bounds check.
; Forced LCD-off probes establish the byte contract, not natural animation.
SECTION "A12 paired tile cycle 4C41-4C87", ROMX[$4C41], BANK[$09]
ResidualROM09_4C41::
CycleA12Variant2TilePairs::
	ld hl, $9920
	ld b, $14
.column
	push hl
	call StepA12RandomState
	pop hl
	ld a, e
	and a, $7F
	jr nz, .next
	ld de, $0020
	ld a, [hl]
	cp a, $A5
	jr z, .fromA5
	cp a, $A6
	jr z, .fromA6
	cp a, $A7
	jr z, .fromA7
	jr .next
.fromA5
	ld a, $A6
	ld [hl], a
	push hl
	add hl, de
	ld a, $A9
	ld [hl], a
	pop hl
	jr .next
.fromA6
	ld a, $A7
	ld [hl], a
	push hl
	add hl, de
	ld a, $AA
	ld [hl], a
	pop hl
	jr .next
.fromA7
	ld a, $A5
	ld [hl], a
	push hl
	add hl, de
	ld a, $A8
	ld [hl], a
	pop hl
	jr .next
.next
	inc hl
	dec b
	jr nz, .column
	ret
ASSERT @ == $4C88
