; PROBABLE static reconstruction, no new natural trace.
; Preserve all original branches, including JR Z to its immediate successor.
SECTION "Local menu state dispatch", ROMX[$406C], BANK[$0A]
DispatchLocalMenuState::
	ld a, [wLocalMenuState]
	rlca
	add a, LOW(LocalMenuStateTargets)
	ld e, a
	ld a, HIGH(LocalMenuStateTargets)
	adc a, $00
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	jp hl
DispatchLocalMenuStateEnd:
ASSERT DispatchLocalMenuStateEnd - DispatchLocalMenuState == $12
