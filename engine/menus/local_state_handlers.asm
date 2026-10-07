; Native A selector $14; physical RGBDS bank $0A lower half.
; PROBABLE static handler roles. State numbers are literal table indices.
; External callees remain numeric until reconstructed with their own evidence.
SECTION "Local menu state 1", ROMX[$42CD], BANK[$0A]
LocalMenuState1::
	ld a, [$C21F]
	and a
	jr nz, .return
	call $0279
	call $4940
	call $488E
	call UpdateLocalListIndicators
	call $478D
	call $4656
.return:
	ret
.end:
ASSERT .end - LocalMenuState1 == $19

SECTION "Local menu state 2", ROMX[$42E6], BANK[$0A]
LocalMenuState2::
	call $0279
	call $4940
	call UpdateLocalListIndicators
	call $48DA
	call $478D
	call $4656
	ret
.end:
ASSERT .end - LocalMenuState2 == $13

SECTION "Local menu state 3", ROMX[$42F9], BANK[$0A]
LocalMenuState3::
	call $0279
	call $4C6F
	call $48AB
	ret
.end:
ASSERT .end - LocalMenuState3 == $0A
