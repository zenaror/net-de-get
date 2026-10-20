; PROBABLE bank09 resource helpers; destination/register behavior is static.
; Stream formats and natural use remain unconfirmed without CPU/runtime probes.

SECTION "Counted byte copy 5D74-5D7C", ROMX[$5D74], BANK[$09]
ResidualROM09_5D74::
CopyCountedBytesFromHLToDE::
.copy
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or a, c
	jr nz, .copy
	ret
ASSERT @ == $5D7D

SECTION "Fill forty patterns at C000 5D7D-5D8E", ROMX[$5D7D], BANK[$09]
Fill40FourBytePatternsAtC000::
	xor a, a
	ld hl, $C000
	ld c, $28
	xor a, a
.record
	ld [hli], a
	ld [hli], a
	ld a, $FF
	ld [hli], a
	xor a, a
	ld [hli], a
	dec c
	jr nz, .record
	ret
ASSERT @ == $5D8F

SECTION "Two streams to VRAM 9C00 5D8F-5DA7", ROMX[$5D8F], BANK[$09]
CopyTwoA12StreamsToVRAM9C00::
	ld a, $01
	ldh [$FF4F], a
	ld de, $9C00
	ld c, $A0
	call CopyHighBitRunStreamToVRAM
	ld a, $00
	ldh [$FF4F], a
	ld de, $9C00
	ld c, $A0
	call CopyA12MarkerRunStreamToVRAM
	ret
ASSERT @ == $5DA8

SECTION "Selected A12 map stream loader 5DA8-5E03", ROMX[$5DA8], BANK[$09]
LoadSelectedA12MapResource::
	ld a, h
	cp a, $60
	jr nc, .upperWindow
	ldh a, [$FFAB]
	ldh [$FF9D], a
	ldh a, [$FFAC]
	ldh [$FF9E], a
	ld a, [$C21C]
	ld [$27FF], a
	ldh [$FFAB], a
	ld a, [$C21D]
	ld [$2800], a
	ldh [$FFAC], a
	call CopyA12StreamsToVRAM9800
	ldh a, [$FF9D]
	ldh [$FFAB], a
	ld [$27FF], a
	ldh a, [$FF9E]
	ldh [$FFAC], a
	ld a, a
	ld [$2800], a
	jr .return
.upperWindow
	ldh a, [$FFAD]
	ldh [$FF9D], a
	ldh a, [$FFAE]
	ldh [$FF9E], a
	ld a, [$C21C]
	ld [$37FF], a
	ldh [$FFAD], a
	ld a, [$C21D]
	ld [$3800], a
	ldh [$FFAE], a
	call CopyA12StreamsToVRAM9800
	ldh a, [$FF9D]
	ldh [$FFAD], a
	ld [$37FF], a
	ldh a, [$FF9E]
	ldh [$FFAE], a
	ld a, a
	ld [$3800], a
.return
	ret
ASSERT @ == $5E04

SECTION "Two A12 streams to VRAM 9800 5E04-5E1C", ROMX[$5E04], BANK[$09]
CopyA12StreamsToVRAM9800::
	ld a, $01
	ldh [$FF4F], a
	ld de, $9800
	ld c, $9C
	call CopyHighBitRunStreamToVRAM
	ld a, $00
	ldh [$FF4F], a
	ld de, $9800
	ld c, $9C
	call CopyA12MarkerRunStreamToVRAM
	ret
ASSERT @ == $5E1D

SECTION "Copy raw map to both VRAM banks 5E98-5EB6", ROMX[$5E98], BANK[$09]
ResidualROM09_5E98::
CopyRawA12MapToBothVRAMBanks::
	ld a, $00
	ldh [$FF4F], a
	ld de, $9C00
	ld bc, $0400
	call CopyBCBytesToDEWithSTATWait
	ld a, $01
	ldh [$FF4F], a
	ld de, $9C00
	ld bc, $0400
	call CopyBCBytesToDEWithSTATWait
	ld a, $00
	ldh [$FF4F], a
	ret
ASSERT @ == $5EB7

SECTION "Copy run stream to VRAM bank 1 5EB7-5EC7", ROMX[$5EB7], BANK[$09]
CopyA12RunStreamToVRAMBank1::
	ld a, $01
	ldh [$FF4F], a
	ld de, $9800
	ld c, $9C
	call CopyHighBitRunStreamToVRAM
	ld a, $00
	ldh [$FF4F], a
	ret
ASSERT @ == $5EC8

SECTION "Copy high-bit run stream to VRAM 5EC8-5EFD", ROMX[$5EC8], BANK[$09]
CopyHighBitRunStreamToVRAM::
.next
	ld a, [hl]
	and a, $80
	jr z, .literal
	ld a, [hli]
	and a, $7F
	ld b, a
.repeat
	di
.waitRepeat
	ldh a, [$FF41]
	and a, $02
	jr nz, .waitRepeat
	ld a, [hl]
	ld [de], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, .repeat
	inc de
	dec b
	jr nz, .repeat
	jr .advance
.literal
	di
.waitLiteral
	ldh a, [$FF41]
	and a, $02
	jr nz, .waitLiteral
	ld a, [hl]
	ld [de], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, .literal
	inc de
.advance
	inc hl
	ld a, d
	cp a, c
	jr nz, .next
	ret
ASSERT @ == $5EFE

SECTION "Copy equal-pair run stream to VRAM 5EFE-5F38", ROMX[$5EFE], BANK[$09]
CopyA12MarkerRunStreamToVRAM::
	ld a, [hl]
	push af
	inc hl
.compareNext
	ld a, [hl]
	ld b, a
	pop af
	push af
	cp a, b
	jr nz, .literal
	inc hl
	ld a, [hli]
	ld b, a
.repeat
	di
.waitRepeat
	ldh a, [$FF41]
	and a, $02
	jr nz, .waitRepeat
	ld a, [hl]
	ld [de], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, .repeat
	inc de
	dec b
	jr nz, .repeat
	jr .advance
.literal
	di
.waitLiteral
	ldh a, [$FF41]
	and a, $02
	jr nz, .waitLiteral
	ld a, [hl]
	ld [de], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, .literal
	inc de
.advance
	inc hl
	ld a, d
	cp a, c
	jr nz, .compareNext
	pop af
	ret
ASSERT @ == $5F39

SECTION "Copy 1800 bytes to VRAM 8000 5F39-5F42", ROMX[$5F39], BANK[$09]
Copy1800BytesToVRAM8000::
	ld de, $8000
	ld bc, $1800
	call CopyBCBytesToDEWithSTATWait
	ret
ASSERT @ == $5F43
