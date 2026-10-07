; PROBABLE mapped resource reader and wrapped-byte coordinate helpers.
; FF/FE initial effects remain numeric; synthetic probes stop at their entries.
SECTION "A12 resource reader 4D82-4DFD", ROMX[$4D82], BANK[$09]
ResidualROM09_4D82::
LoadA12ResourceFrame::
	ldh a, [$FFAD]
	ldh [$FF9D], a
	ldh a, [$FFAE]
	ldh [$FF9E], a
	ld a, [$C21C]
	ld [$37FF], a
	ldh [$FFAD], a
	ld a, [$C21D]
	ld [$3800], a
	ldh [$FFAE], a
	ld a, [$C5CF]
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld [$C5CD], a
	push hl
	pop de
	ld a, [$C5CE]
	ld h, a
	ld l, $04
	call MultiplyA12HLBytes
	add hl, de
	ld a, [hl]
	cp a, $FF
	jr nz, A12Resource_4DBD
	call $4FAF
A12Resource_4DBD::
	ld a, [hl]
	cp a, $FE
	jr nz, A12Resource_4DC5
	call $50C8
A12Resource_4DC5::
	ld a, [hli]
	ld [$C5D0], a
	ld a, [hli]
	ld [$C5D7], a
	ld a, [hli]
	ld [$C5D8], a
	ld a, [hli]
	ld [$C5CB], a
	ld a, [hl]
	cp a, $FF
	jr nz, A12Resource_4DDE
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
A12Resource_4DDE::
	ld a, [hl]
	cp a, $FE
	jr nz, A12Resource_4DE7
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
A12Resource_4DE7::
	ld a, [hli]
	ld [$C5D1], a
	ld a, [hli]
	ld [$C5D9], a
	ld a, [hli]
	ld [$C5DA], a
	ld a, [hli]
	ld [$C5FD], a
	call NormalizeA12ResourceCoordinates
	call ComputeA12ResourceDistances
	ret
ASSERT @ == $4DFE

SECTION "A12 resource reader 4E7A-4EA2", ROMX[$4E7A], BANK[$09]
NormalizeA12ResourceCoordinates::
	ld a, $C9
	ld b, a
	ld a, [$C5D7]
	sub a, b
	ld [$C5D7], a
	ld a, $D0
	ld b, a
	ld a, [$C5D8]
	sub a, b
	ld [$C5D8], a
	ld a, $C9
	ld b, a
	ld a, [$C5D9]
	sub a, b
	ld [$C5D9], a
	ld a, $D0
	ld b, a
	ld a, [$C5DA]
	sub a, b
	ld [$C5DA], a
	ret
ASSERT @ == $4EA3

SECTION "A12 resource reader 4EA3-4EE9", ROMX[$4EA3], BANK[$09]
ComputeA12ResourceDistances::
	ld a, [$C5D9]
	ld b, a
	ld a, [$C5D7]
	cp a, b
	jp nc, A12Resource_4EBB
	ld a, [$C5D7]
	ld b, a
	ld a, [$C5D9]
	sub a, b
	ld [$C5DD], a
	jr A12Resource_4EC6
A12Resource_4EBB::
	ld a, [$C5D9]
	ld b, a
	ld a, [$C5D7]
	sub a, b
	ld [$C5DD], a
A12Resource_4EC6::
	ld a, [$C5DA]
	ld b, a
	ld a, [$C5D8]
	cp a, b
	jp nc, A12Resource_4EDE
	ld a, [$C5D8]
	ld b, a
	ld a, [$C5DA]
	sub a, b
	ld [$C5DE], a
	jr A12Resource_4EE9
A12Resource_4EDE::
	ld a, [$C5DA]
	ld b, a
	ld a, [$C5D8]
	sub a, b
	ld [$C5DE], a
A12Resource_4EE9::
	ret
ASSERT @ == $4EEA
