; PROBABLE clear/reset helpers consumed by the A1E global tick path.
; SYNTHETIC state/conditional audio-register checks, no audible/timing proof.
SECTION "A1E global clear and audio reset", ROMX[$406E], BANK[$0F]
ClearLowerBankA1ESlots::
	ld hl, $CF00
	ld b, $40
	xor a, a
.at4074:
	ld [hli], a
	dec b
	jr nz, .at4074
	ld [$CF86], a
	ld [$CF87], a
	ld [$CF8A], a
	ret
ResetInactiveBankA1EAudio::
	ld a, [$CF41]
	or a, a
	jr nz, .at4092
	xor a, a
	ldh [$FF10], a
	xor a, a
	ldh [$FF12], a
	ld a, $80
	ldh [$FF14], a
.at4092:
	ld a, [$CF51]
	or a, a
	jr nz, .at409F
	xor a, a
	ldh [$FF17], a
	ld a, $80
	ldh [$FF19], a
.at409F:
	ld a, [$CF61]
	or a, a
	jr nz, .at40AA
	xor a, a
	ldh [$FF1A], a
	ldh [$FF1C], a
.at40AA:
	ld a, [$CF71]
	or a, a
	jr nz, .at40B7
	xor a, a
	ldh [$FF21], a
	ld a, $80
	ldh [$FF23], a
.at40B7:
	ret
ASSERT @ == $40B8
