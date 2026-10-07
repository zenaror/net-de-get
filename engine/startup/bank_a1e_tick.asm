; PROBABLE native A1E tick body, reached by ROM0 $2242.
; SYNTHETIC slot counter/routing paths; external handlers remain numeric.
SECTION "Native A1E tick entry", ROMX[$4000], BANK[$0F]
ResidualROM0F_4000::
NativeA1EEntry::
	jp TickBankA1EState
ASSERT @ == $4003

SECTION "Native A1E state tick", ROMX[$42B1], BANK[$0F]
TickBankA1EState::
	ld a, [$CF01]
	or a, a
	jr z, .at42CB
	ld hl, $CF04
	dec [hl]
	jr nz, .at42CB
	inc hl
	ld a, [hl]
	or a, a
	jr z, .at42C8
	dec [hl]
	dec hl
	ld [hl], $FF
	jr .at42CB
.at42C8:
	call HandleA1ESlot0Commands
.at42CB:
	ld a, [$CF11]
	or a, a
	jr z, .at42E5
	ld hl, $CF14
	dec [hl]
	jr nz, .at42E5
	inc hl
	ld a, [hl]
	or a, a
	jr z, .at42E2
	dec [hl]
	dec hl
	ld [hl], $FF
	jr .at42E5
.at42E2:
	call HandleA1ESlot1Commands
.at42E5:
	ld a, [$CF21]
	or a, a
	jr z, .at42FF
	ld hl, $CF24
	dec [hl]
	jr nz, .at42FF
	inc hl
	ld a, [hl]
	or a, a
	jr z, .at42FC
	dec [hl]
	dec hl
	ld [hl], $FF
	jr .at42FF
.at42FC:
	call HandleA1ESlot2Commands
.at42FF:
	ld a, [$CF31]
	or a, a
	jr z, .at4319
	ld hl, $CF34
	dec [hl]
	jr nz, .at4319
	inc hl
	ld a, [hl]
	or a, a
	jr z, .at4316
	dec [hl]
	dec hl
	ld [hl], $FF
	jr .at4319
.at4316:
	call HandleA1ESlot3Commands
.at4319:
	ld a, [$CF41]
	or a, a
	jr z, .at4333
	ld hl, $CF44
	dec [hl]
	jr nz, .at4333
	inc hl
	ld a, [hl]
	or a, a
	jr z, .at4330
	dec [hl]
	dec hl
	ld [hl], $FF
	jr .at4333
.at4330:
	call HandleA1ESlot4Commands
.at4333:
	ld a, [$CF51]
	or a, a
	jr z, .at434D
	ld hl, $CF54
	dec [hl]
	jr nz, .at434D
	inc hl
	ld a, [hl]
	or a, a
	jr z, .at434A
	dec [hl]
	dec hl
	ld [hl], $FF
	jr .at434D
.at434A:
	call $4D23
.at434D:
	ld a, [$CF61]
	or a, a
	jr z, .at4367
	ld hl, $CF64
	dec [hl]
	jr nz, .at4367
	inc hl
	ld a, [hl]
	or a, a
	jr z, .at4364
	dec [hl]
	dec hl
	ld [hl], $FF
	jr .at4367
.at4364:
	call $4EAA
.at4367:
	ld a, [$CF71]
	or a, a
	jr z, .at4381
	ld hl, $CF74
	dec [hl]
	jr nz, .at4381
	inc hl
	ld a, [hl]
	or a, a
	jr z, .at437E
	dec [hl]
	dec hl
	ld [hl], $FF
	jr .at4381
.at437E:
	call $502D
.at4381:
	ld a, [$CF86]
	or a, a
	jr z, UpdateBankA1EAudioRouting
	ld a, [$CF87]
	dec a
	ld [$CF87], a
	or a, a
	jr nz, UpdateBankA1EAudioRouting
	ld a, [$CF86]
	ld [$CF87], a
	ld a, [$CF8A]
	inc a
	ld [$CF8A], a
	cp a, $0F
	jr nz, UpdateBankA1EAudioRouting
	call ResetInactiveBankA1EAudio
	call ClearLowerBankA1ESlots
UpdateBankA1EAudioRouting::
	ld a, [$CF84]
	or a, a
	ret z
	ld a, [$CF88]
	ld d, a
	ld a, [$CF89]
	cp a, $00
	jr z, .at43C5
	ld e, a
	swap a
	xor a, e
	xor a, d
	ld e, a
	ld a, [$CF89]
	or a, e
	ldh [$FF25], a
	ret
.at43C5:
	ld a, [$CF88]
	ldh [$FF25], a
	ret
ASSERT @ == $43CB
