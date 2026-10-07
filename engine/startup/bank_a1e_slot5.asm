; PROBABLE upper-slot5 handler, native A1E tick consumer.
; SYNTHETIC dispatch/B0/B1/C0/FE; no natural playback.
SECTION "A1E slot5 commands", ROMX[$4D23], BANK[$0F]
ResidualROM0F_4D23::
HandleA1ESlot5Commands::
	ld a, [$CF50]
	ld c, a
	ld a, [$CF51]
	ld b, a
A1ESlot5_4D2B::
	ld a, [bc]
	inc bc
	cp a, $90
	jp c, A1ESlot5_4E78
	cp a, $A0
	jp c, A1ESlot5_4E11
	cp a, $B0
	jp z, A1ESlot5_4DAD
	cp a, $B1
	jp z, A1ESlot5_4DF3
	cp a, $C0
	jp z, A1ESlot5_4D8D
	cp a, $E0
	jp z, A1ESlot5_4DB5
	cp a, $FD
	jp z, A1ESlot5_4D65
	cp a, $FE
	jp z, A1ESlot5_4D75
	ld hl, $CF50
	cp a, $FF
	ret nz
	call ClearA1EUpperSlot16Bytes
	call RestoreA1ELowerSlot1Registers
	call ClearA1ESlot5Routing
	ret
A1ESlot5_4D65::
	ld a, [bc]
	inc bc
	ld [$CF5C], a
	ld a, b
	ld [$CF5B], a
	ld a, c
	ld [$CF5A], a
	jp ReadA1ESlot5Countdown
A1ESlot5_4D75::
	ld a, [$CF5C]
	or a, a
	jr z, A1ESlot5_4D82
	dec a
	jp z, ReadA1ESlot5Countdown
	ld [$CF5C], a
A1ESlot5_4D82::
	ld a, [$CF5B]
	ld b, a
	ld a, [$CF5A]
	ld c, a
	jp ReadA1ESlot5Countdown
A1ESlot5_4D8D::
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
A1ESlot5_4D9C::
	inc hl
	inc hl
	dec b
	jr nz, A1ESlot5_4D9C
	ld a, [hli]
	ld [$CF57], a
	ld a, [hl]
	ld [$CF58], a
	pop bc
	jp ReadA1ESlot5Countdown
A1ESlot5_4DAD::
	ld a, [bc]
	inc bc
	ld [$CF5D], a
	jp ReadA1ESlot5Countdown
A1ESlot5_4DB5::
	ld a, [bc]
	inc bc
	sub a, $40
	jr c, A1ESlot5_4DC8
	ld e, a
	ld d, $00
	ld a, [$CF5D]
A1ESlot5_4DC1::
	dec a
	jr z, A1ESlot5_4DD9
	srl e
	jr A1ESlot5_4DC1
A1ESlot5_4DC8::
	cpl
	ld e, a
	ld d, $FF
	ld a, [$CF5D]
A1ESlot5_4DCF::
	dec a
	jr z, A1ESlot5_4DD6
	srl e
	jr A1ESlot5_4DCF
A1ESlot5_4DD6::
	ld a, e
	cpl
	ld e, a
A1ESlot5_4DD9::
	ld a, [$CF52]
	ld l, a
	ld a, [$CF53]
	ld h, a
	add hl, de
	ld a, e
	ld [$CF5E], a
	ld a, d
	ld [$CF5F], a
	ld a, l
	ldh [$FF18], a
	ld a, h
	ldh [$FF19], a
	jp ReadA1ESlot5Countdown
A1ESlot5_4DF3::
	ld a, [bc]
	inc bc
	ld hl, $CF89
	cp a, $40
	jr c, A1ESlot5_4E04
	jr z, A1ESlot5_4E0A
	set 1, [hl]
	res 5, [hl]
	jr A1ESlot5_4E0E
A1ESlot5_4E04::
	res 1, [hl]
	set 5, [hl]
	jr A1ESlot5_4E0E
A1ESlot5_4E0A::
	set 1, [hl]
	set 5, [hl]
A1ESlot5_4E0E::
	jp ReadA1ESlot5Countdown
A1ESlot5_4E11::
	and a, $0F
	swap a
	ld [$CF56], a
	ld a, [bc]
	inc a
	ld hl, $4A0E
	ld e, a
	ld d, $00
	add hl, de
	add hl, de
	ld a, [hl]
	ld [$CF52], a
	inc hl
	ld a, [hl]
	ld [$CF53], a
	ld a, [$CF5E]
	ld e, a
	ld a, [$CF5F]
	ld d, a
	ld a, [$CF52]
	ld l, a
	ld a, [$CF53]
	ld h, a
	add hl, de
	ld a, [$CF56]
	ldh [$FF17], a
	ld a, [$CF57]
	and a, $E0
	ldh [$FF16], a
	ld a, l
	ldh [$FF18], a
	ld a, h
	or a, $80
	ldh [$FF19], a
	inc bc
ReadA1ESlot5Countdown::
	ld a, [bc]
	inc bc
	or a, a
	jp z, A1ESlot5_4D2B
	bit 7, a
	jr z, A1ESlot5_4E6C
	and a, $7F
	ld d, a
	ld a, [bc]
	inc bc
	ld e, a
	srl d
	jr nc, A1ESlot5_4E67
	set 7, e
A1ESlot5_4E67::
	ld a, d
	ld [$CF55], a
	ld a, e
A1ESlot5_4E6C::
	ld [$CF54], a
	ld a, c
	ld [$CF50], a
	ld a, b
	ld [$CF51], a
	ret
A1ESlot5_4E78::
	ld a, [$CF5E]
	ld e, a
	ld a, [$CF5F]
	ld d, a
	ld a, [$CF52]
	ld l, a
	ld a, [$CF53]
	ld h, a
	add hl, de
	ld a, l
	ldh [$FF18], a
	ld a, [$CF57]
	ldh [$FF16], a
	ld a, [$CF58]
	or a, a
	jr nz, A1ESlot5_4E9C
	ld a, $08
	ld [$CF56], a
A1ESlot5_4E9C::
	ld e, a
	ld a, [$CF56]
	or a, e
	ldh [$FF17], a
	ld a, h
	or a, $80
	ldh [$FF19], a
	jr ReadA1ESlot5Countdown
ASSERT @ == $4EAA
