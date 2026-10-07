; PROBABLE wrappers and window-A save/restore helpers.
; SYNTHETIC helpers, prefixes and independent return tails; no target execution.

SECTION "Bank A16 call wrappers", ROM0[$1663]
ResidualROM00_1663::
CallBankA16_4227::
	di
	ld de, $C641
	call SaveWindowAAndSelect16
	call $4227
	ld de, $C641
	call RestoreSavedWindowA
	ei
	ret
CallBankA16_424D::
	di
	ld de, $C643
	call SaveWindowAAndSelect16
	call $424D
	push af
	ld de, $C643
	call RestoreSavedWindowA
	pop af
	ei
	ret
CallBankA16_42CB::
	di
	ld de, $C645
	call SaveWindowAAndSelect16
	call $42CB
	push af
	ld de, $C645
	call RestoreSavedWindowA
	pop af
	ei
	ret
CallBankA16_42EF::
	di
	ld de, $C647
	call SaveWindowAAndSelect16
	call $42EF
	push af
	ld de, $C647
	call RestoreSavedWindowA
	pop af
	ei
	ret
ASSERT @ == $16B1

SECTION "Bank A16 window helpers", ROM0[$1783]
SaveWindowAAndSelect16::
	ldh a, [$FFAB]
	ld [de], a
	inc de
	ldh a, [$FFAC]
	ld [de], a
	ld a, $16
	ld [$27FF], a
	ldh [$FFAB], a
	ld [$C113], a
	ld a, $00
	ld [$2800], a
	ldh [$FFAC], a
	ld [$C114], a
	ret
RestoreSavedWindowA::
	ld a, [de]
	ld [$27FF], a
	ldh [$FFAB], a
	ld [$C113], a
	inc de
	ld a, [de]
	ld [$2800], a
	ldh [$FFAC], a
	ld [$C114], a
	ret
ASSERT @ == $17B3
