; PROBABLE wrapper targets under native MBC6 A $16.
; Existing SYS0 load/store SYNTHETIC chain; initialization paths are static only.
SECTION "A16 wrapper target bodies", ROMX[$4227], BANK[$0B]
BankA16_4227::
	ld a, $01
	call ResidentJump01D4
	ld hl, $C21C
	ld e, [hl]
	inc hl
	ld d, [hl]
	push de
	ld a, $03
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld hl, $6000
	call ResidentJump01E0
	pop de
	ld a, e
	ld [$C21C], a
	ld a, d
	ld [$C21D], a
	ret
BankA16_424D::
	ld a, $00
	ld [$C637], a
	xor a, a
	ld [$0400], a
	inc a
	ld [$0800], a
	ld a, $0A
	ld [$0000], a
	ld a, $FF
	ld [$A000], a
	ld a, $FF
	ld [$A001], a
	xor a, a
	ld [$0000], a
	ldh a, [$FFAF]
	ld [$0400], a
	ldh a, [$FFB0]
	ld [$0800], a
	call $01B3
	ld a, b
	and a, a
	jr z, .at4283
	ld a, $01
	ld [$C637], a
.at4283:
	ld bc, $0032
	ld de, SYS0RecordName
	call OpenLocalStorageRecord
	ld a, c
	ld [$C638], a
	ld a, l
	or a, h
	jr nz, .at429A
	call CloseLocalStorageRecord
	ld a, $02
	ret
.at429A:
	ld a, [$C638]
	and a, a
	jr z, .at42BA
	push hl
	ldh a, [$FF70]
	and a, $07
	push af
	ld a, $02
	ldh [$FF70], a
	call ResidentJump028E
	pop de
	ld hl, $D000
	ld bc, $0032
	call ResidentJump0276
	pop af
	ldh [$FF70], a
.at42BA:
	call CloseLocalStorageRecord
	call $3DDF
	ld a, l
	or a, h
	jr nz, .at42C7
	ld a, $02
	ret
.at42C7:
	ld a, [$C637]
	ret
LoadSYS0Record50Bytes::
	ld bc, $0032
	ld de, SYS0RecordName
	call OpenLocalStorageRecord
	ld a, l
	or a, h
	jr nz, .at42E1
	call ResidentJump028E
	call CloseLocalStorageRecord
	ld a, $01
	ret
.at42E1:
	ld de, $C700
	ld bc, $0032
	call ResidentJump0276
	call CloseLocalStorageRecord
	xor a, a
	ret
StoreSYS0Record50Bytes::
	ld bc, $0032
	ld de, SYS0RecordName
	call OpenLocalStorageRecord
	ld a, l
	or a, h
	jr nz, .at4302
	call CloseLocalStorageRecord
	ld a, $01
	ret
.at4302:
	ld e, l
	ld d, h
	ld hl, $C700
	ld bc, $0032
	call ResidentJump0276
	call CloseLocalStorageRecord
	xor a, a
	ret
ASSERT @ == $4312
