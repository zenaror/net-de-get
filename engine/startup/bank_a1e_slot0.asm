; PROBABLE slot0 command interpreter and global-phase clamp.
; SYNTHETIC streams/dispatch/countdowns; no natural playback or format bound.
SECTION "A1E slot0 command handler", ROMX[$43CB], BANK[$0F]
ResidualROM0F_43CB::
ClampA1EValueByGlobalPhase::
	ld [$CF8B], a
	ld a, [$CF86]
	or a, a
	ld a, [$CF8B]
	ret z
	push de
	ld a, [$CF8A]
	ld e, a
	ld a, [$CF8B]
	sub a, e
	jr c, A1ECode_43E3
	pop de
	ret
A1ECode_43E3::
	ld a, $00
	pop de
	ret
HandleA1ESlot0Commands::
	ld a, [$CF00]
	ld c, a
	ld a, [$CF01]
	ld b, a
A1ESlot0_43EF::
	ld a, [bc]
	inc bc
	cp a, $80
	ret c
	cp a, $90
	jp c, A1ESlot0_4569
	cp a, $A0
	jp c, A1ESlot0_44EB
	cp a, $B0
	jp z, A1ESlot0_4479
	cp a, $B1
	jp z, A1ESlot0_444D
	cp a, $C0
	jp z, A1ESlot0_44C6
	cp a, $E0
	jp z, A1ESlot0_4481
	cp a, $FD
	jp z, A1ESlot0_4425
	cp a, $FE
	jp z, A1ESlot0_4435
	ld hl, $CF00
	cp a, $FF
	jp z, ClearA1ESlot16Bytes
	ret
A1ESlot0_4425::
	ld a, [bc]
	inc bc
	ld [$CF0C], a
	ld a, b
	ld [$CF0B], a
	ld a, c
	ld [$CF0A], a
	jp ReadA1ESlot0Countdown
A1ESlot0_4435::
	ld a, [$CF0C]
	or a, a
	jr z, A1ECode_4442
	dec a
	jp z, ReadA1ESlot0Countdown
	ld [$CF0C], a
A1ECode_4442::
	ld a, [$CF0B]
	ld b, a
	ld a, [$CF0A]
	ld c, a
	jp ReadA1ESlot0Countdown
A1ESlot0_444D::
	ld a, [bc]
	inc bc
	ld hl, $CF88
	cp a, $40
	jr c, A1ECode_4463
	jr z, A1ECode_446E
	set 0, [hl]
	res 4, [hl]
	ld a, $FF
	ld [$CF28], a
	jr A1ECode_4476
A1ECode_4463::
	res 0, [hl]
	set 4, [hl]
	ld a, $FF
	ld [$CF28], a
	jr A1ECode_4476
A1ECode_446E::
	set 0, [hl]
	set 4, [hl]
	xor a, a
	ld [$CF28], a
A1ECode_4476::
	jp ReadA1ESlot0Countdown
A1ESlot0_4479::
	ld a, [bc]
	inc bc
	ld [$CF0D], a
	jp ReadA1ESlot0Countdown
A1ESlot0_4481::
	ld a, [bc]
	inc bc
	sub a, $40
	jr c, A1ECode_4494
	ld e, a
	ld d, $00
	ld a, [$CF0D]
A1ECode_448D::
	dec a
	jr z, A1ECode_44A5
	srl e
	jr A1ECode_448D
A1ECode_4494::
	cpl
	ld e, a
	ld d, $FF
	ld a, [$CF0D]
A1ECode_449B::
	dec a
	jr z, A1ECode_44A2
	srl e
	jr A1ECode_449B
A1ECode_44A2::
	ld a, e
	cpl
	ld e, a
A1ECode_44A5::
	ld a, [$CF02]
	ld l, a
	ld a, [$CF03]
	ld h, a
	add hl, de
	ld a, e
	ld [$CF0E], a
	ld a, d
	ld [$CF0F], a
	ld a, [$CF41]
	or a, a
	jp nz, ReadA1ESlot0Countdown
	ld a, l
	ldh [$FF13], a
	ld a, h
	ldh [$FF14], a
	jp ReadA1ESlot0Countdown
A1ESlot0_44C6::
	ld a, [bc]
	and a, $1F
	inc bc
	push bc
	ld b, a
	ld de, $CF94
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc b
A1ECode_44D5::
	inc hl
	inc hl
	inc hl
	dec b
	jr nz, A1ECode_44D5
	ld a, [hli]
	ld [$CF07], a
	ld a, [hli]
	ld [$CF08], a
	ld a, [hl]
	ld [$CF09], a
	pop bc
	jp ReadA1ESlot0Countdown
A1ESlot0_44EB::
	ld e, a
	ld a, [$CF28]
	or a, a
	jr z, A1ECode_44F3
	dec e
A1ECode_44F3::
	ld a, e
	and a, $0F
	call ClampA1EValueByGlobalPhase
	swap a
	ld [$CF06], a
	ld a, [bc]
	inc a
	ld hl, $4A0E
	ld e, a
	ld d, $00
	add hl, de
	add hl, de
	ld a, [hl]
	ld [$CF02], a
	inc hl
	ld a, [hl]
	ld [$CF03], a
	ld a, [$CF41]
	or a, a
	jr nz, A1ECode_4541
	ld a, [$CF0E]
	ld e, a
	ld a, [$CF0F]
	ld d, a
	ld a, [$CF02]
	ld l, a
	ld a, [$CF03]
	ld h, a
	add hl, de
	ld a, [$CF06]
	ldh [$FF12], a
	ld a, [$CF07]
	ldh [$FF10], a
	ld a, l
	ldh [$FF13], a
	ld a, [$CF08]
	and a, $E0
	ldh [$FF11], a
	ld a, h
	or a, $80
	ldh [$FF14], a
A1ECode_4541::
	inc bc
ReadA1ESlot0Countdown::
	ld a, [bc]
	inc bc
	or a, a
	jp z, A1ESlot0_43EF
	bit 7, a
	jr z, A1ECode_455D
	and a, $7F
	ld d, a
	ld a, [bc]
	inc bc
	ld e, a
	srl d
	jr nc, A1ECode_4558
	set 7, e
A1ECode_4558::
	ld a, d
	ld [$CF05], a
	ld a, e
A1ECode_455D::
	ld [$CF04], a
	ld a, c
	ld [$CF00], a
	ld a, b
	ld [$CF01], a
	ret
A1ESlot0_4569::
	ld a, [$CF41]
	or a, a
	jr nz, ReadA1ESlot0Countdown
	ld a, [$CF0E]
	ld e, a
	ld a, [$CF0F]
	ld d, a
	ld a, [$CF02]
	ld l, a
	ld a, [$CF03]
	ld h, a
	add hl, de
	ld a, l
	ldh [$FF13], a
	ld a, [$CF08]
	ldh [$FF11], a
	ld a, [$CF09]
	or a, a
	jr nz, A1ECode_4593
	ld a, $08
	ld [$CF06], a
A1ECode_4593::
	ld e, a
	ld a, [$CF06]
	or a, e
	ldh [$FF12], a
	ld a, h
	or a, $80
	ldh [$FF14], a
	jr ReadA1ESlot0Countdown
ASSERT @ == $45A1
