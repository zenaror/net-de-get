; PROBABLE A12 indexed text preparation and window/copy wrappers.
; Forced tests distinguish callee boundaries from complete mapped execution.
SECTION "A12 text helper 4C88-4CA5", ROMX[$4C88], BANK[$09]
ResidualROM09_4C88::
PrepareA12TextRegion::
	ld [$C5C4], a
	ld de, A12TextRegionRecords
	call ResidentJump01E3
	ld a, [$C5C4]
	ld de, A12TextRegionRecords
	call ResidentJump01E6
	ld a, [$C5C4]
	ld [$C5A5], a
	ld a, $00
	ld [$C1C2], a
	ret
ASSERT @ == $4CA6

SECTION "A12 text helper 4CA6-4CB7", ROMX[$4CA6], BANK[$09]
ShowA12TextWindow::
.wait
	ldh a, [$FF41]
	and a, $02
	jr nz, .wait
	ldh a, [$FF40]
	or a, $60
	ldh [$FF40], a
	ld a, $9A
	call ResidentJump024F
	ret
ASSERT @ == $4CB8

SECTION "A12 text helper 4CB8-4CD7", ROMX[$4CB8], BANK[$09]
HideA12TextWindowAndCopy::
.wait
	ldh a, [$FF41]
	and a, $02
	jr nz, .wait
	ldh a, [$FF40]
	and a, $9F
	ldh [$FF40], a
	ld bc, $0000
	ld a, $14
	ld h, a
	ld a, $08
	ld l, a
	ld de, $D000
	ld a, $07
	or a, $80
	call ResidentJump0294
	ret
ASSERT @ == $4CD8

SECTION "A12 text helper 4CD8-4CFC", ROMX[$4CD8], BANK[$09]
CopyA12CurrentTextRegion::
	ld a, [$C5A5]
	ld [$C5C4], a
	ld de, A12TextRegionRecords
	call ResidentJump01E3
	ld bc, $0000
	ld a, [$C1A8]
	inc a
	inc a
	ld h, a
	ld a, [$C1A9]
	add a, a
	inc a
	inc a
	ld l, a
	ld de, $D000
	ld a, $07
	call ResidentJump0294
	ret
ASSERT @ == $4CFD
