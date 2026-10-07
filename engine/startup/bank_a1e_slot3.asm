; PROBABLE slot3 handler and shared FF clear, native A1E.
; SYNTHETIC dispatch/B1/C0/countdown/FF, no natural playback.
; Numeric table base $4A0E overlaps the JR operand and RET at $4A0F.
SECTION "A1E slot3 commands and clear", ROMX[$48EC], BANK[$0F]
ResidualROM0F_48EC::
HandleA1ESlot3Commands::
	ld a, [$CF30]
	ld c, a
	ld a, [$CF31]
	ld b, a
A1ESlot3_48F4::
	ld a, [bc]
	inc bc
	cp a, $80
	ret c
	cp a, $90
	jp c, A1ESlot3_49E4
	cp a, $A0
	jp c, A1ESlot3_4979
	cp a, $B1
	jp z, A1ESlot3_4948
	cp a, $C0
	jp z, A1ESlot3_4974
	cp a, $FD
	jp z, A1ESlot3_4920
	cp a, $FE
	jp z, A1ESlot3_4930
	ld hl, $CF30
	cp a, $FF
	jp z, ClearA1ESlot16Bytes
	ret
A1ESlot3_4920::
	ld a, [bc]
	inc bc
	ld [$CF3C], a
	ld a, b
	ld [$CF3B], a
	ld a, c
	ld [$CF3A], a
	jp ReadA1ESlot3Countdown
A1ESlot3_4930::
	ld a, [$CF3C]
	or a, a
	jr z, A1ESlot3_493D
	dec a
	jp z, ReadA1ESlot3Countdown
	ld [$CF3C], a
A1ESlot3_493D::
	ld a, [$CF3B]
	ld b, a
	ld a, [$CF3A]
	ld c, a
	jp ReadA1ESlot3Countdown
A1ESlot3_4948::
	ld a, [bc]
	inc bc
	ld hl, $CF88
	cp a, $40
	jr c, A1ESlot3_495E
	jr z, A1ESlot3_4969
	set 3, [hl]
	res 7, [hl]
	ld a, $FF
	ld [$CF39], a
	jr A1ESlot3_4971
A1ESlot3_495E::
	res 3, [hl]
	set 7, [hl]
	ld a, $FF
	ld [$CF39], a
	jr A1ESlot3_4971
A1ESlot3_4969::
	set 3, [hl]
	set 7, [hl]
	xor a, a
	ld [$CF39], a
A1ESlot3_4971::
	jp ReadA1ESlot3Countdown
A1ESlot3_4974::
	ld a, [bc]
	inc bc
	jp ReadA1ESlot3Countdown
A1ESlot3_4979::
	ld e, a
	ld a, [$CF39]
	or a, a
	jr z, A1ESlot3_4981
	dec e
A1ESlot3_4981::
	ld a, e
	and a, $0F
	call ClampA1EValueByGlobalPhase
	swap a
	ld [$CF36], a
	ld a, [bc]
	sub a, $23
	push af
	ld de, $CF9A
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	pop af
	ld e, a
A1ESlot3_499A::
	ld a, [hli]
	ld [$CF32], a
	ld a, [hli]
	ld [$CF37], a
	dec e
	jr nz, A1ESlot3_499A
	ld a, [$CF71]
	or a, a
	jr nz, A1ESlot3_49BC
	ld a, [$CF32]
	ldh [$FF22], a
	ld a, [$CF36]
	ldh [$FF21], a
	xor a, a
	ldh [$FF20], a
	ld a, $80
	ldh [$FF23], a
A1ESlot3_49BC::
	inc bc
ReadA1ESlot3Countdown::
	ld a, [bc]
	inc bc
	or a, a
	jp z, A1ESlot3_48F4
	bit 7, a
	jr z, A1ESlot3_49D8
	and a, $7F
	ld d, a
	ld a, [bc]
	inc bc
	ld e, a
	srl d
	jr nc, A1ESlot3_49D3
	set 7, e
A1ESlot3_49D3::
	ld a, d
	ld [$CF35], a
	ld a, e
A1ESlot3_49D8::
	ld [$CF34], a
	ld a, c
	ld [$CF30], a
	ld a, b
	ld [$CF31], a
	ret
A1ESlot3_49E4::
	ld a, [$CF71]
	or a, a
	jr nz, ReadA1ESlot3Countdown
	ld a, [$CF32]
	ldh [$FF22], a
	ld a, [$CF37]
	or a, a
	jr nz, A1ESlot3_49FA
	ld a, $08
	ld [$CF36], a
A1ESlot3_49FA::
	ld e, a
	ld a, [$CF36]
	or a, e
	ldh [$FF21], a
	ld a, $80
	ldh [$FF23], a
	jr ReadA1ESlot3Countdown
ClearA1ESlot16Bytes::
	ld b, $10
	ld a, $00
A1ESlot3_4A0B::
	ld [hli], a
	dec b
	jr nz, A1ESlot3_4A0B
	ret
ASSERT @ == $4A10
