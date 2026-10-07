; PROBABLE native A1E stream installation/helpers.
; SYNTHETIC WRAM records; no natural stream validity or playback.
SECTION "A1E stream setup 40B8", ROMX[$40B8], BANK[$0F]
ResidualROM0F_40B8::
EnableA1ELowerRouting::
	ld a, $FF
	ld [$CF88], a
	ret
EnableA1ESlot4Routing::
	ld a, $11
	ld e, a
	ld a, [$CF89]
	and a, $EE
	or a, e
	ld [$CF89], a
	ret
EnableA1ESlot5Routing::
	ld a, $22
	ld e, a
	ld a, [$CF89]
	and a, $DD
	or a, e
	ld [$CF89], a
	ret
EnableA1ESlot6Routing::
	ld a, $44
	ld e, a
	ld a, [$CF89]
	and a, $BB
	or a, e
	ld [$CF89], a
	ret
EnableA1ESlot7Routing::
	ld a, $88
	ld e, a
	ld a, [$CF89]
	and a, $77
	or a, e
	ld [$CF89], a
	ret
ResumeA1ELowerSlots::
	call ClearLowerBankA1ESlots
	call EnableA1ELowerRouting
	xor a, a
	ld [$CF80], a
	ld hl, $CFA0
	ld de, $CF00
	ld b, $40
A1EStreams_4104::
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, A1EStreams_4104
	call RestoreA1ELowerSlot2Wave
	ret
InstallA1ELowerStreams::
	ld a, [$CF80]
	bit 7, a
	ret z
	cp a, $FF
	jp z, ResumeA1ELowerSlots
	and a, $7F
	ld b, a
	xor a, a
	ld [$CF80], a
	push bc
	call BackupA1ELowerSlots
	call ClearLowerBankA1ESlots
	call ResetInactiveBankA1EAudio
	call EnableA1ELowerRouting
	pop bc
	inc b
	ld de, $CF90
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
A1EStreams_4137::
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	dec b
	jr nz, A1EStreams_4137
	ld h, d
	ld l, e
	ld a, [hli]
	ld b, a
	push bc
	inc hl
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld e, a
	push hl
	dec hl
	dec hl
	dec hl
	dec hl
	add hl, de
	ld b, h
	ld c, l
	ld hl, $CF00
	ld a, [bc]
	inc bc
	ld [hl], c
	inc hl
	ld [hl], b
	inc a
	ld [$CF04], a
	pop hl
	pop bc
	dec b
	jr z, A1EStreams_41C7
	push bc
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld e, a
	push hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	add hl, de
	ld b, h
	ld c, l
	ld hl, $CF10
	ld a, [bc]
	inc bc
	ld [hl], c
	inc hl
	ld [hl], b
	inc a
	ld [$CF14], a
	pop hl
	pop bc
	dec b
	jr z, A1EStreams_41C7
	push bc
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld e, a
	push hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	add hl, de
	ld b, h
	ld c, l
	ld hl, $CF20
	ld a, [bc]
	inc bc
	ld [hl], c
	inc hl
	ld [hl], b
	inc a
	ld [$CF24], a
	pop hl
	pop bc
	dec b
	jr z, A1EStreams_41C7
	push bc
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld e, a
	push hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	add hl, de
	ld b, h
	ld c, l
	ld hl, $CF30
	ld a, [bc]
	inc bc
	ld [hl], c
	inc hl
	ld [hl], b
	inc a
	ld [$CF34], a
	pop hl
	pop bc
	dec b
	jr z, A1EStreams_41C7
A1EStreams_41C7::
	ret
InstallA1EUpperStreams::
	ld a, [$CF82]
	bit 7, a
	ret z
	and a, $7F
	ld b, a
	xor a, a
	ld [$CF82], a
	inc b
	ld de, $CF92
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
A1EStreams_41DE::
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	dec b
	jr nz, A1EStreams_41DE
	ld h, d
	ld l, e
	ld bc, $0005
	add hl, bc
A1EStreams_41EB::
	ld a, [de]
	inc de
	cp a, $01
	jp z, A1EStreams_4205
	cp a, $02
	jp z, A1EStreams_4230
	cp a, $03
	jp z, A1EStreams_4259
	cp a, $04
	jp z, A1EStreams_4280
	cp a, $00
	ret z
	ret
A1EStreams_4205::
	xor a, a
	ldh [$FF10], a
	ldh [$FF12], a
	ld a, $80
	ldh [$FF14], a
	push hl
	ld hl, $CF40
	call ClearA1EInstallSlot
	pop hl
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	push hl
	ld hl, $CF40
	ld a, [bc]
	inc bc
	ld [hl], c
	inc hl
	ld [hl], b
	inc a
	ld [$CF44], a
	pop hl
	push de
	call EnableA1ESlot4Routing
	pop de
	jp A1EStreams_41EB
A1EStreams_4230::
	xor a, a
	ldh [$FF17], a
	ld a, $80
	ldh [$FF19], a
	push hl
	ld hl, $CF50
	call ClearA1EInstallSlot
	pop hl
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	push hl
	ld hl, $CF50
	ld a, [bc]
	inc bc
	ld [hl], c
	inc hl
	ld [hl], b
	inc a
	ld [$CF54], a
	pop hl
	push de
	call EnableA1ESlot5Routing
	pop de
	jp A1EStreams_41EB
A1EStreams_4259::
	xor a, a
	ldh [$FF1A], a
	ldh [$FF1C], a
	push hl
	ld hl, $CF60
	call ClearA1EInstallSlot
	pop hl
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	push hl
	ld hl, $CF60
	ld a, [bc]
	inc bc
	ld [hl], c
	inc hl
	ld [hl], b
	inc a
	ld [$CF64], a
	pop hl
	push de
	call EnableA1ESlot6Routing
	pop de
	jp A1EStreams_41EB
A1EStreams_4280::
	xor a, a
	ldh [$FF21], a
	ld a, $80
	ldh [$FF23], a
	push hl
	ld hl, $CF70
	call ClearA1EInstallSlot
	pop hl
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	push hl
	ld hl, $CF70
	ld a, [bc]
	inc bc
	ld [hl], c
	inc hl
	ld [hl], b
	inc a
	ld [$CF74], a
	pop hl
	push de
	call EnableA1ESlot7Routing
	pop de
	jp A1EStreams_41EB
ClearA1EInstallSlot::
	ld b, $10
	xor a, a
A1EStreams_42AC::
	ld [hli], a
	dec b
	jr nz, A1EStreams_42AC
	ret
ASSERT @ == $42B1
