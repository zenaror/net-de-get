; PROBABLE slot2 handler, consumed by native A1E tick.
; SYNTHETIC dispatch/B0/B1/C0; no natural playback or universal bounds.
SECTION "A1E slot2 commands", ROMX[$4752], BANK[$0F]
ResidualROM0F_4752::
HandleA1ESlot2Commands::
	ld a, [$CF20]
	ld c, a
	ld a, [$CF21]
	ld b, a
A1ESlot2_475A::
	ld a, [bc]
	inc bc
	cp a, $80
	ret c
	cp a, $90
	jp c, A1ESlot2_48DF
	cp a, $A0
	jp c, A1ESlot2_484F
	cp a, $B0
	jp z, A1ESlot2_47D8
	cp a, $B1
	jp z, A1ESlot2_47B8
	cp a, $E0
	jp z, A1ESlot2_47E0
	cp a, $C0
	jp z, A1ESlot2_4825
	cp a, $FD
	jp z, A1ESlot2_4790
	cp a, $FE
	jp z, A1ESlot2_47A0
	ld hl, $CF20
	cp a, $FF
	jp z, ClearA1ESlot16Bytes
	ret
A1ESlot2_4790::
	ld a, [bc]
	inc bc
	ld [$CF2C], a
	ld a, b
	ld [$CF2B], a
	ld a, c
	ld [$CF2A], a
	jp ReadA1ESlot2Countdown
A1ESlot2_47A0::
	ld a, [$CF2C]
	or a, a
	jr z, A1ESlot2_47AD
	dec a
	jp z, ReadA1ESlot2Countdown
	ld [$CF2C], a
A1ESlot2_47AD::
	ld a, [$CF2B]
	ld b, a
	ld a, [$CF2A]
	ld c, a
	jp ReadA1ESlot2Countdown
A1ESlot2_47B8::
	ld a, [bc]
	inc bc
	ld hl, $CF88
	cp a, $40
	jr c, A1ESlot2_47CA
	jr z, A1ESlot2_47D1
	set 2, [hl]
	res 6, [hl]
	jp A1ESlot2_47D5
A1ESlot2_47CA::
	res 2, [hl]
	set 6, [hl]
	jp A1ESlot2_47D5
A1ESlot2_47D1::
	set 2, [hl]
	set 6, [hl]
A1ESlot2_47D5::
	jp ReadA1ESlot2Countdown
A1ESlot2_47D8::
	ld a, [bc]
	inc bc
	ld [$CF2D], a
	jp ReadA1ESlot2Countdown
A1ESlot2_47E0::
	ld a, [bc]
	inc bc
	sub a, $40
	jr c, A1ESlot2_47F3
	ld e, a
	ld d, $00
	ld a, [$CF2D]
A1ESlot2_47EC::
	dec a
	jr z, A1ESlot2_4804
	srl e
	jr A1ESlot2_47EC
A1ESlot2_47F3::
	cpl
	ld e, a
	ld d, $FF
	ld a, [$CF2D]
A1ESlot2_47FA::
	dec a
	jr z, A1ESlot2_4801
	srl e
	jr A1ESlot2_47FA
A1ESlot2_4801::
	ld a, e
	cpl
	ld e, a
A1ESlot2_4804::
	ld a, [$CF22]
	ld l, a
	ld a, [$CF23]
	ld h, a
	add hl, de
	ld a, e
	ld [$CF2E], a
	ld a, d
	ld [$CF2F], a
	ld a, [$CF61]
	or a, a
	jp nz, ReadA1ESlot2Countdown
	ld a, l
	ldh [$FF1D], a
	ld a, h
	ldh [$FF1E], a
	jp ReadA1ESlot2Countdown
A1ESlot2_4825::
	ld a, [bc]
	and a, $1F
	ld [$CF27], a
	inc bc
	push af
	ld de, $CF98
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	pop af
	ld e, a
	ld d, $00
	add hl, de
	add hl, de
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	ld hl, $FF30
	push bc
	ld b, $10
A1ESlot2_4845::
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, A1ESlot2_4845
	pop bc
	jp ReadA1ESlot2Countdown
A1ESlot2_484F::
	and a, $0F
	call ClampA1EValueByGlobalPhase
	swap a
	cp a, $C0
	jr c, A1ESlot2_4861
	ld a, $20
	ld [$CF26], a
	jr A1ESlot2_4871
A1ESlot2_4861::
	cp a, $80
	jr c, A1ESlot2_486C
	ld a, $40
	ld [$CF26], a
	jr A1ESlot2_4871
A1ESlot2_486C::
	ld a, $60
	ld [$CF26], a
A1ESlot2_4871::
	ld a, [bc]
	inc a
	ld hl, $4A0E
	ld e, a
	ld d, $00
	add hl, de
	add hl, de
	ld a, [hl]
	ld [$CF22], a
	inc hl
	ld a, [hl]
	ld [$CF23], a
	ld a, [$CF61]
	or a, a
	jr nz, A1ESlot2_48B7
	ld a, [$CF2E]
	ld e, a
	ld a, [$CF2F]
	ld d, a
	ld a, [$CF22]
	ld l, a
	ld a, [$CF23]
	ld h, a
	add hl, de
	xor a, a
	ldh [$FF1A], a
	ld a, h
	and a, $7F
	ldh [$FF1E], a
	ld a, [$CF26]
	ldh [$FF1C], a
	xor a, a
	ldh [$FF1B], a
	ld a, l
	ldh [$FF1D], a
	ld a, $80
	ldh [$FF1A], a
	ld a, h
	or a, $80
	ldh [$FF1E], a
A1ESlot2_48B7::
	inc bc
ReadA1ESlot2Countdown::
	ld a, [bc]
	inc bc
	or a, a
	jp z, A1ESlot2_475A
	bit 7, a
	jr z, A1ESlot2_48D3
	and a, $7F
	ld d, a
	ld a, [bc]
	inc bc
	ld e, a
	srl d
	jr nc, A1ESlot2_48CE
	set 7, e
A1ESlot2_48CE::
	ld a, d
	ld [$CF25], a
	ld a, e
A1ESlot2_48D3::
	ld [$CF24], a
	ld a, c
	ld [$CF20], a
	ld a, b
	ld [$CF21], a
	ret
A1ESlot2_48DF::
	ld a, [$CF61]
	or a, a
	jr nz, ReadA1ESlot2Countdown
	xor a, a
	ldh [$FF1A], a
	ldh [$FF1C], a
	jr ReadA1ESlot2Countdown
ASSERT @ == $48EC
