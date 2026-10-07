; Static six-word interval between the JP HL dispatcher and first target.
; PROBABLE menu-state dispatch role; no universal valid-index bound is proved.
; Native A selector $14; physical RGBDS bank $0A lower half.
SECTION "Local menu state targets", ROMX[$407E], BANK[$0A]
LocalMenuStateTargets::
	dw $408A, $42CD, $42E6, $42F9, $4303, $43C0
.end:
ASSERT .end - LocalMenuStateTargets == 12
