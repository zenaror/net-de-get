; PROBABLE upper-slot6 handler, native A1E tick consumer.
; SYNTHETIC dispatch/B0/B1/C0/FE; wave copy only with channel disabled.
SECTION "A1E slot6 commands", ROMX[$4EAA], BANK[$0F]
ResidualROM0F_4EAA::
HandleA1ESlot6Commands::
	ld a, [$CF60]
	ld c, a
	ld a, [$CF61]
	ld b, a
A1ESlot6_4EB2::
	ld a, [bc]
	inc bc
	cp a, $90
	jp c, A1ESlot6_5026
	cp a, $A0
	jp c, A1ESlot6_4F9F
	cp a, $B0
	jp z, A1ESlot6_4F32
	cp a, $B1
	jp z, A1ESlot6_4F14
	cp a, $C0
	jp z, A1ESlot6_4F78
	cp a, $E0
	jp z, A1ESlot6_4F3A
	cp a, $FD
	jp z, A1ESlot6_4EEC
	cp a, $FE
	jp z, A1ESlot6_4EFC
	ld hl, $CF60
	cp a, $FF
	ret nz
	call $51C7
	call $522D
	call $526C
	ret
A1ESlot6_4EEC::
	ld a, [bc]
	inc bc
	ld [$CF6C], a
	ld a, b
	ld [$CF6B], a
	ld a, c
	ld [$CF6A], a
	jp ReadA1ESlot6Countdown
A1ESlot6_4EFC::
	ld a, [$CF6C]
	or a, a
	jr z, A1ESlot6_4F09
	dec a
	jp z, ReadA1ESlot6Countdown
	ld [$CF6C], a
A1ESlot6_4F09::
	ld a, [$CF6B]
	ld b, a
	ld a, [$CF6A]
	ld c, a
	jp ReadA1ESlot6Countdown
A1ESlot6_4F14::
	ld a, [bc]
	inc bc
	ld hl, $CF89
	cp a, $40
	jr c, A1ESlot6_4F25
	jr z, A1ESlot6_4F2B
	set 2, [hl]
	res 6, [hl]
	jr A1ESlot6_4F2F
A1ESlot6_4F25::
	res 2, [hl]
	set 6, [hl]
	jr A1ESlot6_4F2F
A1ESlot6_4F2B::
	set 2, [hl]
	set 6, [hl]
A1ESlot6_4F2F::
	jp ReadA1ESlot6Countdown
A1ESlot6_4F32::
	ld a, [bc]
	inc bc
	ld [$CF6D], a
	jp ReadA1ESlot6Countdown
A1ESlot6_4F3A::
	ld a, [bc]
	inc bc
	sub a, $40
	jr c, A1ESlot6_4F4D
	ld e, a
	ld d, $00
	ld a, [$CF6D]
A1ESlot6_4F46::
	dec a
	jr z, A1ESlot6_4F5E
	srl e
	jr A1ESlot6_4F46
A1ESlot6_4F4D::
	cpl
	ld e, a
	ld d, $FF
	ld a, [$CF6D]
A1ESlot6_4F54::
	dec a
	jr z, A1ESlot6_4F5B
	srl e
	jr A1ESlot6_4F54
A1ESlot6_4F5B::
	ld a, e
	cpl
	ld e, a
A1ESlot6_4F5E::
	ld a, [$CF62]
	ld l, a
	ld a, [$CF63]
	ld h, a
	add hl, de
	ld a, e
	ld [$CF6E], a
	ld a, d
	ld [$CF6F], a
	ld a, l
	ldh [$FF1D], a
	ld a, h
	ldh [$FF1E], a
	jp ReadA1ESlot6Countdown
A1ESlot6_4F78::
	ld a, [bc]
	and a, $1F
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
A1ESlot6_4F95::
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, A1ESlot6_4F95
	pop bc
	jp ReadA1ESlot6Countdown
A1ESlot6_4F9F::
	and a, $0F
	swap a
	cp a, $C0
	jr c, A1ESlot6_4FAE
	ld a, $20
	ld [$CF66], a
	jr A1ESlot6_4FBE
A1ESlot6_4FAE::
	cp a, $80
	jr c, A1ESlot6_4FB9
	ld a, $40
	ld [$CF66], a
	jr A1ESlot6_4FBE
A1ESlot6_4FB9::
	ld a, $60
	ld [$CF66], a
A1ESlot6_4FBE::
	ld a, [bc]
	inc a
	ld hl, $4A0E
	ld e, a
	ld d, $00
	add hl, de
	add hl, de
	ld a, [hl]
	ld [$CF62], a
	inc hl
	ld a, [hl]
	ld [$CF63], a
	ld a, [$CF6E]
	ld e, a
	ld a, [$CF6F]
	ld d, a
	ld a, [$CF62]
	ld l, a
	ld a, [$CF63]
	ld h, a
	add hl, de
	xor a, a
	ldh [$FF1A], a
	ld a, h
	and a, $7F
	ldh [$FF1E], a
	ld a, [$CF66]
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
	inc bc
ReadA1ESlot6Countdown::
	ld a, [bc]
	inc bc
	or a, a
	jp z, A1ESlot6_4EB2
	bit 7, a
	jr z, A1ESlot6_501A
	and a, $7F
	ld d, a
	ld a, [bc]
	inc bc
	ld e, a
	srl d
	jr nc, A1ESlot6_5015
	set 7, e
A1ESlot6_5015::
	ld a, d
	ld [$CF65], a
	ld a, e
A1ESlot6_501A::
	ld [$CF64], a
	ld a, c
	ld [$CF60], a
	ld a, b
	ld [$CF61], a
	ret
A1ESlot6_5026::
	xor a, a
	ldh [$FF1A], a
	ldh [$FF1C], a
	jr ReadA1ESlot6Countdown
ASSERT @ == $502D
