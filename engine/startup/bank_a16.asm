; PROBABLE startup initialization from ROM0 $0373, native MBC6 A $16.
; Static flow and SYNTHETIC DMG register-prefix checks; no natural full boot.
SECTION "Bank A16 startup initialization", ROMX[$4000], BANK[$0B]
ResidualROM0B_4000::
InitializeBankA16::
	xor a, a
	ldh [$FF0F], a
	ldh [$FFFF], a
	call $018F
	ld a, $03
	ldh [$FFFF], a
	ldh a, [$FF9C]
	and a, a
	jp z, InitializeDMGFallback
	xor a, a
	ldh [$FF42], a
	ldh [$FF43], a
	ldh [$FF41], a
	ldh [$FF4A], a
	ldh [$FF8B], a
	ldh [$FF26], a
	ld a, $07
	ldh [$FF4B], a
	call $016B
	call $0270
	call $0282
	call $0279
	ldh a, [$FF96]
	cp a, $0C
	jr nz, .at4050
	call $440C
	ld a, [$C214]
	and a, a
	jr nz, .at4050
	ld a, $0A
	ld [$0000], a
	ld a, $01
	call $01C8
	xor a, a
	call $01C8
	xor a, a
	ld [$0000], a
.at4050:
	call $0285
	ld [$C637], a
	call $0288
	call $4AF0
	ld a, $0B
	ld de, $4F5A
	call $01E6
	ld bc, $0000
	ld hl, $4FCA
	call $01EF
	ld a, $04
	ld hl, $4EDA
	call $0177
.at4075:
	call $017D
	halt
	nop
.at407A:
	ldh a, [$FF8A]
	and a, a
	jr z, .at407A
	xor a, a
	ldh [$FF8A], a
	ld a, [$C21F]
	and a, a
	jr nz, .at4075
	call $3557
	ld a, $04
	ld hl, $4EDA
	call $017A
.at4093:
	call $017D
	halt
	nop
.at4098:
	ldh a, [$FF8A]
	and a, a
	jr z, .at4098
	xor a, a
	ldh [$FF8A], a
	ld a, [$C220]
	and a, a
	jp nz, .at4093
	call $4B78
	ld a, $06
	ld [$37FF], a
	ldh [$FFAD], a
	ld a, $00
	ld [$3800], a
	ldh [$FFAE], a
	call $6000
	and a, a
	jp z, .at4158
	push af
	call $4AF0
	ld a, $04
	ld hl, $4EDA
	call $0177
.at40CB:
	call $017D
	halt
	nop
.at40D0:
	ldh a, [$FF8A]
	and a, a
	jr z, .at40D0
	xor a, a
	ldh [$FF8A], a
	ld a, [$C21F]
	and a, a
	jr nz, .at40CB
	ld de, $41EA
	call $01D7
	ld a, $06
	ld de, $4F5A
	call $01E6
	xor a, a
	ld [$C1BC], a
	ld [$C1BD], a
	ld hl, $5019
	call $01E9
.at40F9:
	call $0279
	call $01EC
	call $017D
	call $0261
	halt
	nop
.at4107:
	ldh a, [$FF8A]
	and a, a
	jr z, .at4107
	xor a, a
	ldh [$FF8A], a
	ld a, [$C1B8]
	and a, a
	jr z, .at4117
	jr .at40F9
.at4117:
	ld a, $0C
	ld de, $4F5A
	call $01E6
	di
	ld de, $0000
	call $0150
	ei
	pop af
	call $34A8
	di
	ld de, $4B91
	call $0150
	ei
	ld a, $04
	ld hl, $4EDA
	call $017A
.at413B:
	call $017D
	halt
	nop
.at4140:
	ldh a, [$FF8A]
	and a, a
	jr z, .at4140
	xor a, a
	ldh [$FF8A], a
	ld a, [$C220]
	and a, a
	jp nz, .at413B
	ld de, $0000
	call $01D7
	call $4B78
.at4158:
	ld a, [$C700]
	ld c, a
	ld a, $02
	sub a, c
	ld [$C1BA], a
	ld a, [$C704]
	ld [$CF84], a
	call $0246
	ret
InitializeDMGFallback::
	ld a, $1F
	ld [$37FF], a
	ldh [$FFAD], a
	ld a, $00
	ld [$3800], a
	ldh [$FFAE], a
	ld a, $E4
	ldh [$FF47], a
	ldh [$FF48], a
	ldh [$FF49], a
	xor a, a
	ldh [$FF42], a
	ldh [$FF43], a
	ldh [$FF41], a
	ldh [$FF4A], a
	ldh [$FF26], a
	ld a, $07
	ldh [$FF4B], a
	ld a, $80
	ldh [$FF26], a
	ld a, $77
	ldh [$FF24], a
	ld a, $FF
	ldh [$FF25], a
	call $0252
	ld hl, $C000
	ld bc, $1000
.at41A6:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, .at41A6
	ld hl, $6000
	ld de, $8800
	ld bc, $0A70
	call $0198
	ld c, $00
	ld b, $00
	call $0219
	ld bc, $9800
	add hl, bc
	push hl
	xor a, a
	ldh [$FF4F], a
	ld hl, $6A70
	pop de
	ld b, $14
	ld c, $12
	call $01A4
	di
	ld de, $4B91
	call $0150
	ei
	call $016B
.at41DE:
	halt
	nop
.at41E0:
	ldh a, [$FF8A]
	and a, a
	jr z, .at41E0
	xor a, a
	ldh [$FF8A], a
	jr .at41DE
.end:
ASSERT .end == $41EA
