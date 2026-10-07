; PROBABLE upper-slot7 and FF restoration helpers, native A1E.
; SYNTHETIC commands/upper FF chains; no natural playback/audio correctness.
SECTION "A1E slot7 and upper termination", ROMX[$502D], BANK[$0F]
ResidualROM0F_502D::
HandleA1ESlot7Commands::
	ld a, [$CF70]
	ld c, a
	ld a, [$CF71]
	ld b, a
A1ESlot7_5035::
	ld a, [bc]
	inc bc
	cp a, $90
	jp c, A1ESlot7_5177
	cp a, $A0
	jp c, A1ESlot7_50FB
	cp a, $B1
	jp z, A1ESlot7_50D5
	cp a, $E0
	jp z, A1ESlot7_506F
	cp a, $E1
	jp z, A1ESlot7_5095
	cp a, $C0
	jp z, A1ESlot7_50F3
	cp a, $FD
	jp z, A1ESlot7_50AD
	cp a, $FE
	jp z, A1ESlot7_50BD
	ld hl, $CF70
	cp a, $FF
	ret nz
	call ClearA1EUpperSlot16Bytes
	call ResetA1ENoiseRegisters
	call ClearA1ESlot7Routing
	ret
A1ESlot7_506F::
	ld a, [bc]
	inc bc
	ld [$CF7E], a
	ld e, a
	ld a, [$CF72]
	srl a
	srl a
	srl a
	srl a
	add a, e
	sla a
	sla a
	sla a
	sla a
	ld e, a
	ld a, [$CF72]
	and a, $07
	or a, e
	ldh [$FF22], a
	jp ReadA1ESlot7Countdown
A1ESlot7_5095::
	ld a, [bc]
	inc bc
	ld [$CF7F], a
	ld e, a
	ld a, [$CF72]
	and a, $07
	add a, e
	ld e, a
	ld a, [$CF72]
	and a, $F0
	or a, e
	ldh [$FF22], a
	jp ReadA1ESlot7Countdown
A1ESlot7_50AD::
	ld a, [bc]
	inc bc
	ld [$CF7C], a
	ld a, b
	ld [$CF7B], a
	ld a, c
	ld [$CF7A], a
	jp ReadA1ESlot7Countdown
A1ESlot7_50BD::
	ld a, [$CF7C]
	or a, a
	jr z, A1ESlot7_50CA
	dec a
	jp z, ReadA1ESlot7Countdown
	ld [$CF7C], a
A1ESlot7_50CA::
	ld a, [$CF7B]
	ld b, a
	ld a, [$CF7A]
	ld c, a
	jp ReadA1ESlot7Countdown
A1ESlot7_50D5::
	ld a, [bc]
	inc bc
	ld hl, $CF89
	cp a, $40
	jr c, A1ESlot7_50E6
	jr z, A1ESlot7_50EC
	set 3, [hl]
	res 7, [hl]
	jr A1ESlot7_50F0
A1ESlot7_50E6::
	res 3, [hl]
	set 7, [hl]
	jr A1ESlot7_50F0
A1ESlot7_50EC::
	set 3, [hl]
	set 7, [hl]
A1ESlot7_50F0::
	jp ReadA1ESlot7Countdown
A1ESlot7_50F3::
	ld a, [bc]
	inc bc
	ld [$CF77], a
	jp ReadA1ESlot7Countdown
A1ESlot7_50FB::
	and a, $0F
	swap a
	ld [$CF76], a
	ld hl, $4B08
	ld a, [bc]
	ld e, a
	ld d, $00
	add hl, de
	ld a, [hl]
	ld [$CF72], a
	ld a, [$CF7E]
	ld e, a
	ld a, [$CF72]
	srl a
	srl a
	srl a
	srl a
	add a, e
	sla a
	sla a
	sla a
	sla a
	ld e, a
	ld a, [$CF72]
	and a, $07
	or a, e
	ld [$CF72], a
	ld a, [$CF7F]
	ld e, a
	ld a, [$CF72]
	and a, $07
	add a, e
	ld e, a
	ld a, [$CF72]
	and a, $F0
	or a, e
	ldh [$FF22], a
	ld a, [$CF76]
	ldh [$FF21], a
	xor a, a
	ldh [$FF20], a
	ld a, $80
	ldh [$FF23], a
	inc bc
ReadA1ESlot7Countdown::
	ld a, [bc]
	inc bc
	or a, a
	jp z, A1ESlot7_5035
	bit 7, a
	jr z, A1ESlot7_516B
	and a, $7F
	ld d, a
	ld a, [bc]
	inc bc
	ld e, a
	srl d
	jr nc, A1ESlot7_5166
	set 7, e
A1ESlot7_5166::
	ld a, d
	ld [$CF75], a
	ld a, e
A1ESlot7_516B::
	ld [$CF74], a
	ld a, c
	ld [$CF70], a
	ld a, b
	ld [$CF71], a
	ret
A1ESlot7_5177::
	ld a, [$CF7E]
	ld e, a
	ld a, [$CF72]
	srl a
	srl a
	srl a
	srl a
	add a, e
	sla a
	sla a
	sla a
	sla a
	ld e, a
	ld a, [$CF72]
	and a, $07
	or a, e
	ld [$CF72], a
	ld a, [$CF7F]
	ld e, a
	ld a, [$CF72]
	and a, $07
	add a, e
	ld e, a
	ld a, [$CF72]
	and a, $F0
	or a, e
	ldh [$FF22], a
	ld a, [$CF77]
	or a, a
	jr nz, A1ESlot7_51B7
	ld a, $08
	ld [$CF76], a
A1ESlot7_51B7::
	ld e, a
	ld a, [$CF76]
	or a, e
	ldh [$FF21], a
	ld a, [$CF73]
	or a, $80
	ldh [$FF23], a
	jr ReadA1ESlot7Countdown
ClearA1EUpperSlot16Bytes::
	ld b, $10
	ld a, $00
A1ESlot7_51CB::
	ld [hli], a
	dec b
	jr nz, A1ESlot7_51CB
	ret
RestoreA1ELowerSlot0Registers::
	xor a, a
	ldh [$FF10], a
	ldh [$FF12], a
	ld a, $80
	ldh [$FF14], a
	ld a, [$CF0E]
	ld e, a
	ld a, [$CF0F]
	ld d, a
	ld a, [$CF02]
	ld l, a
	ld a, [$CF03]
	ld h, a
	add hl, de
	ld a, [$CF07]
	ldh [$FF10], a
	ld a, l
	ldh [$FF13], a
	ld a, [$CF08]
	ldh [$FF11], a
	ld a, [$CF06]
	ldh [$FF12], a
	ld a, h
	and a, $07
	ldh [$FF14], a
	ret
RestoreA1ELowerSlot1Registers::
	xor a, a
	ldh [$FF17], a
	ld a, $80
	ldh [$FF19], a
	ld a, [$CF1E]
	ld e, a
	ld a, [$CF1F]
	ld d, a
	ld a, [$CF12]
	ld l, a
	ld a, [$CF13]
	ld h, a
	add hl, de
	ld a, h
	ldh [$FF18], a
	ld a, [$CF17]
	ldh [$FF16], a
	ld a, [$CF16]
	ldh [$FF17], a
	ld a, l
	and a, $07
	ldh [$FF19], a
	ret
RestoreA1ELowerSlot2Wave::
	xor a, a
	ldh [$FF1A], a
	ldh [$FF1C], a
	ldh [$FF1E], a
	ld a, [$CF27]
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
	ld b, $10
A1ESlot7_524F::
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, A1ESlot7_524F
	ret
ResetA1ENoiseRegisters::
	xor a, a
	ldh [$FF21], a
	ld a, $80
	ldh [$FF23], a
	ret
ClearA1ESlot7Routing::
	xor a, a
	and a, $88
	ld e, a
	ld a, [$CF89]
	and a, $77
	or a, e
	ld [$CF89], a
	ret
ClearA1ESlot6Routing::
	xor a, a
	and a, $44
	ld e, a
	ld a, [$CF89]
	and a, $BB
	or a, e
	ld [$CF89], a
	ret
ClearA1ESlot5Routing::
	xor a, a
	and a, $22
	ld e, a
	ld a, [$CF89]
	and a, $DD
	or a, e
	ld [$CF89], a
	ret
ClearA1ESlot4Routing::
	xor a, a
	and a, $11
	ld e, a
	ld a, [$CF89]
	and a, $EE
	or a, e
	ld [$CF89], a
	ret
ASSERT @ == $5296
