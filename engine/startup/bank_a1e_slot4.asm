; PROBABLE upper-slot4 handler, native A1E tick consumer.
; SYNTHETIC dispatch/B0/B1/C0/FE; no natural playback.
; FE decrement writes CF0C, not CF4C: preserve original cross-slot effect.
SECTION "A1E slot4 commands", ROMX[$4B90], BANK[$0F]
HandleA1ESlot4Commands::
	ld a, [$CF40]
	ld c, a
	ld a, [$CF41]
	ld b, a
A1ESlot4_4B98::
	ld a, [bc]
	inc bc
	cp a, $90
	jp c, A1ESlot4_4CF1
	cp a, $A0
	jp c, A1ESlot4_4C83
	cp a, $B0
	jp z, A1ESlot4_4C3D
	cp a, $B1
	jp z, A1ESlot4_4C1F
	cp a, $C0
	jp z, A1ESlot4_4BFA
	cp a, $E0
	jp z, A1ESlot4_4C45
	cp a, $FD
	jp z, A1ESlot4_4BD2
	cp a, $FE
	jp z, A1ESlot4_4BE2
	ld hl, $CF40
	cp a, $FF
	ret nz
	call ClearA1EUpperSlot16Bytes
	call RestoreA1ELowerSlot0Registers
	call ClearA1ESlot4Routing
	ret
A1ESlot4_4BD2::
	ld a, [bc]
	inc bc
	ld [$CF4C], a
	ld a, b
	ld [$CF4B], a
	ld a, c
	ld [$CF4A], a
	jp ReadA1ESlot4Countdown
A1ESlot4_4BE2::
	ld a, [$CF4C]
	or a, a
	jr z, A1ESlot4_4BEF
	dec a
	jp z, ReadA1ESlot4Countdown
	ld [$CF0C], a
A1ESlot4_4BEF::
	ld a, [$CF4B]
	ld b, a
	ld a, [$CF4A]
	ld c, a
	jp ReadA1ESlot4Countdown
A1ESlot4_4BFA::
	ld a, [bc]
	inc bc
	push bc
	and a, $1F
	ld b, a
	ld de, $CF94
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc b
A1ESlot4_4C09::
	inc hl
	inc hl
	inc hl
	dec b
	jr nz, A1ESlot4_4C09
	ld a, [hli]
	ld [$CF47], a
	ld a, [hli]
	ld [$CF48], a
	ld a, [hl]
	ld [$CF49], a
	pop bc
	jp ReadA1ESlot4Countdown
A1ESlot4_4C1F::
	ld a, [bc]
	inc bc
	ld hl, $CF89
	cp a, $40
	jr c, A1ESlot4_4C30
	jr z, A1ESlot4_4C36
	set 0, [hl]
	res 4, [hl]
	jr A1ESlot4_4C3A
A1ESlot4_4C30::
	res 0, [hl]
	set 4, [hl]
	jr A1ESlot4_4C3A
A1ESlot4_4C36::
	set 0, [hl]
	set 4, [hl]
A1ESlot4_4C3A::
	jp ReadA1ESlot4Countdown
A1ESlot4_4C3D::
	ld a, [bc]
	inc bc
	ld [$CF4D], a
	jp ReadA1ESlot4Countdown
A1ESlot4_4C45::
	ld a, [bc]
	inc bc
	sub a, $40
	jr c, A1ESlot4_4C58
	ld e, a
	ld d, $00
	ld a, [$CF4D]
A1ESlot4_4C51::
	dec a
	jr z, A1ESlot4_4C69
	srl e
	jr A1ESlot4_4C51
A1ESlot4_4C58::
	cpl
	ld e, a
	ld d, $FF
	ld a, [$CF4D]
A1ESlot4_4C5F::
	dec a
	jr z, A1ESlot4_4C66
	srl e
	jr A1ESlot4_4C5F
A1ESlot4_4C66::
	ld a, e
	cpl
	ld e, a
A1ESlot4_4C69::
	ld a, [$CF42]
	ld l, a
	ld a, [$CF43]
	ld h, a
	add hl, de
	ld a, e
	ld [$CF4E], a
	ld a, d
	ld [$CF4F], a
	ld a, l
	ldh [$FF13], a
	ld a, h
	ldh [$FF14], a
	jp ReadA1ESlot4Countdown
A1ESlot4_4C83::
	and a, $0F
	swap a
	ld [$CF46], a
	ldh [$FF12], a
	ld a, [bc]
	inc a
	ld hl, $4A0E
	ld e, a
	ld d, $00
	add hl, de
	add hl, de
	ld a, [hl]
	ld [$CF42], a
	inc hl
	ld a, [hl]
	ld [$CF43], a
	ld a, [$CF4E]
	ld e, a
	ld a, [$CF4F]
	ld d, a
	ld a, [$CF42]
	ld l, a
	ld a, [$CF43]
	ld h, a
	add hl, de
	ld a, [$CF46]
	ldh [$FF12], a
	ld a, [$CF47]
	ldh [$FF10], a
	ld a, l
	ldh [$FF13], a
	ld a, [$CF48]
	and a, $E0
	ldh [$FF11], a
	ld a, h
	or a, $80
	ldh [$FF14], a
	inc bc
ReadA1ESlot4Countdown::
	ld a, [bc]
	inc bc
	or a, a
	jp z, A1ESlot4_4B98
	bit 7, a
	jr z, A1ESlot4_4CE5
	and a, $7F
	ld d, a
	ld a, [bc]
	inc bc
	ld e, a
	srl d
	jr nc, A1ESlot4_4CE0
	set 7, e
A1ESlot4_4CE0::
	ld a, d
	ld [$CF45], a
	ld a, e
A1ESlot4_4CE5::
	ld [$CF44], a
	ld a, c
	ld [$CF40], a
	ld a, b
	ld [$CF41], a
	ret
A1ESlot4_4CF1::
	ld a, [$CF4E]
	ld e, a
	ld a, [$CF4F]
	ld d, a
	ld a, [$CF42]
	ld l, a
	ld a, [$CF43]
	ld h, a
	add hl, de
	ld a, l
	ldh [$FF13], a
	ld a, [$CF48]
	ldh [$FF11], a
	ld a, [$CF49]
	or a, a
	jr nz, A1ESlot4_4D15
	ld a, $08
	ld [$CF46], a
A1ESlot4_4D15::
	ld e, a
	ld a, [$CF46]
	or a, e
	ldh [$FF12], a
	ld a, h
	or a, $80
	ldh [$FF14], a
	jr ReadA1ESlot4Countdown
ASSERT @ == $4D23
