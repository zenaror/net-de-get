; PROBABLE slot1 handler, reached by native A1E tick $42E2.
; SYNTHETIC dispatcher/B0/B1/C0 streams; no natural playback/stream bound.
SECTION "A1E slot1 commands", ROMX[$45A1], BANK[$0F]
ResidualROM0F_45A1::
HandleA1ESlot1Commands::
	ld a, [$CF10]
	ld c, a
	ld a, [$CF11]
	ld b, a
A1ESlot1_45A9::
	ld a, [bc]
	inc bc
	cp a, $80
	ret c
	cp a, $90
	jp c, A1ESlot1_471A
	cp a, $A0
	jp c, A1ESlot1_46A1
	cp a, $B0
	jp z, A1ESlot1_4607
	cp a, $B1
	jp z, A1ESlot1_460F
	cp a, $E0
	jp z, A1ESlot1_463D
	cp a, $C0
	jp z, A1ESlot1_4682
	cp a, $FD
	jp z, A1ESlot1_45DF
	cp a, $FE
	jp z, A1ESlot1_45EF
	ld hl, $CF10
	cp a, $FF
	jp z, $4A07
	ret
A1ESlot1_45DF::
	ld a, [bc]
	inc bc
	ld [$CF1C], a
	ld a, b
	ld [$CF1B], a
	ld a, c
	ld [$CF1A], a
	jp ReadA1ESlot1Countdown
A1ESlot1_45EF::
	ld a, [$CF1C]
	or a, a
	jr z, A1ESlot1_45FC
	dec a
	jp z, ReadA1ESlot1Countdown
	ld [$CF1C], a
A1ESlot1_45FC::
	ld a, [$CF1B]
	ld b, a
	ld a, [$CF1A]
	ld c, a
	jp ReadA1ESlot1Countdown
A1ESlot1_4607::
	ld a, [bc]
	inc bc
	ld [$CF1D], a
	jp ReadA1ESlot1Countdown
A1ESlot1_460F::
	ld a, [bc]
	inc bc
	ld hl, $CF88
	cp a, $40
	jr c, A1ESlot1_4626
	jr z, A1ESlot1_4632
	set 1, [hl]
	res 5, [hl]
	ld a, $FF
	ld [$CF19], a
	jp A1ESlot1_463A
A1ESlot1_4626::
	res 1, [hl]
	set 5, [hl]
	ld a, $FF
	ld [$CF19], a
	jp A1ESlot1_463A
A1ESlot1_4632::
	set 1, [hl]
	set 5, [hl]
	xor a, a
	ld [$CF19], a
A1ESlot1_463A::
	jp ReadA1ESlot1Countdown
A1ESlot1_463D::
	ld a, [bc]
	inc bc
	sub a, $40
	jr c, A1ESlot1_4650
	ld e, a
	ld d, $00
	ld a, [$CF1D]
A1ESlot1_4649::
	dec a
	jr z, A1ESlot1_4661
	srl e
	jr A1ESlot1_4649
A1ESlot1_4650::
	cpl
	ld e, a
	ld d, $FF
	ld a, [$CF1D]
A1ESlot1_4657::
	dec a
	jr z, A1ESlot1_465E
	srl e
	jr A1ESlot1_4657
A1ESlot1_465E::
	ld a, e
	cpl
	ld e, a
A1ESlot1_4661::
	ld a, [$CF12]
	ld l, a
	ld a, [$CF13]
	ld h, a
	add hl, de
	ld a, e
	ld [$CF1E], a
	ld a, d
	ld [$CF1F], a
	ld a, [$CF51]
	or a, a
	jp nz, ReadA1ESlot1Countdown
	ld a, l
	ldh [$FF18], a
	ld a, h
	ldh [$FF19], a
	jp ReadA1ESlot1Countdown
A1ESlot1_4682::
	ld a, [bc]
	and a, $1F
	inc bc
	push bc
	ld b, a
	ld de, $CF96
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc b
A1ESlot1_4691::
	inc hl
	inc hl
	dec b
	jr nz, A1ESlot1_4691
	ld a, [hli]
	ld [$CF17], a
	ld a, [hl]
	ld [$CF18], a
	pop bc
	jr ReadA1ESlot1Countdown
A1ESlot1_46A1::
	ld e, a
	ld a, [$CF19]
	or a, a
	jr z, A1ESlot1_46A9
	dec e
A1ESlot1_46A9::
	ld a, e
	and a, $0F
	call ClampA1EValueByGlobalPhase
	swap a
	ld [$CF16], a
	ld a, [bc]
	inc a
	ld hl, $4A0E
	ld e, a
	ld d, $00
	add hl, de
	add hl, de
	ld a, [hl]
	ld [$CF12], a
	inc hl
	ld a, [hl]
	ld [$CF13], a
	ld a, [$CF51]
	or a, a
	jr nz, A1ESlot1_46F2
	ld a, [$CF1E]
	ld e, a
	ld a, [$CF1F]
	ld d, a
	ld a, [$CF12]
	ld l, a
	ld a, [$CF13]
	ld h, a
	add hl, de
	ld a, [$CF16]
	ldh [$FF17], a
	ld a, [$CF17]
	and a, $E0
	ldh [$FF16], a
	ld a, l
	ldh [$FF18], a
	ld a, h
	or a, $80
	ldh [$FF19], a
A1ESlot1_46F2::
	inc bc
ReadA1ESlot1Countdown::
	ld a, [bc]
	inc bc
	or a, a
	jp z, A1ESlot1_45A9
	bit 7, a
	jr z, A1ESlot1_470E
	and a, $7F
	ld d, a
	ld a, [bc]
	inc bc
	ld e, a
	srl d
	jr nc, A1ESlot1_4709
	set 7, e
A1ESlot1_4709::
	ld a, d
	ld [$CF15], a
	ld a, e
A1ESlot1_470E::
	ld [$CF14], a
	ld a, c
	ld [$CF10], a
	ld a, b
	ld [$CF11], a
	ret
A1ESlot1_471A::
	ld a, [$CF51]
	or a, a
	jr nz, ReadA1ESlot1Countdown
	ld a, [$CF1E]
	ld e, a
	ld a, [$CF1F]
	ld d, a
	ld a, [$CF12]
	ld l, a
	ld a, [$CF13]
	ld h, a
	add hl, de
	ld a, l
	ldh [$FF18], a
	ld a, [$CF17]
	ldh [$FF16], a
	ld a, [$CF18]
	or a, a
	jr nz, A1ESlot1_4744
	ld a, $08
	ld [$CF16], a
A1ESlot1_4744::
	ld e, a
	ld a, [$CF16]
	or a, e
	ldh [$FF17], a
	ld a, h
	or a, $80
	ldh [$FF19], a
	jr ReadA1ESlot1Countdown
ASSERT @ == $4752
