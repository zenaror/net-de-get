; PROBABLE static state-0 initialization; no new natural execution trace.
; Native A $14, physical RGBDS bank $0A lower half.
; Stops at RET $421D; subsequent bytes are not decoded as instructions.
SECTION "Local menu state 0", ROMX[$408A], BANK[$0A]
LocalMenuState0::
	call ClearLocalOAMBuffer
	ld a, $01
	ldh [$FF4F], a
	ld a, $14
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld hl, LocalMenuTilePlane1
	ld de, $9000
	ld bc, $0010
	call CopyBankedVRAMBytes
	xor a
	ldh [$FF4F], a
	ld a, $15
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld hl, LocalMenuTilesBeforeTemplate
	ld de, $8000
	ld bc, $1800
	call CopyBankedVRAMBytes
	ld a, $14
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld hl, LocalMenuAdditionalTiles
	ld de, $8100
	ld bc, $00A0
	call CopyBankedVRAMBytes
	ld a, $15
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld hl, LocalMenuTilesBeforeTemplate + $11B2
	ld de, $8000
	ld bc, $0020
	call CopyBankedVRAMBytes
	ld hl, LocalMenuFullTilemap
	ld de, $9800
	ld bc, $2020
	call CopyTwoPlaneTilemap
	ld a, [$D004]
	cp $04
	jr nz, .at410B
	ld hl, LocalMenuMap427D
	ld de, $9800
	ld bc, $1402
	call CopyTwoPlaneTilemap
.at410B:
	ld a, $FF
	ld [$D028], a
	ld [$D029], a
	ld [$D02E], a
	ld [$D02F], a
	ld [$D034], a
	ld [$D035], a
	ld [$D03A], a
	ld [$D03B], a
	ld [$D040], a
	ld [$D041], a
	ld [$D046], a
	ld [$D047], a
	ld [$D04C], a
	ld [$D04D], a
	ld [$D052], a
	ld [$D053], a
	ld [$D058], a
	ld [$D059], a
	ld [$D05E], a
	ld [$D05F], a
	call $3CE8
	ld a, $01
	ld [wLocalMenuState], a
	xor a
	ld [$D001], a
	ld [$D002], a
	ld [$D007], a
	ld [$D014], a
	ld [$D015], a
	ld [$D016], a
	ld [$D020], a
	ld a, $FF
	ld [$D008], a
	call $0288
	ld a, [$C703]
	and a
	jr z, .at418E
	ld a, [$C733]
	ld [$D001], a
	ld a, [$C734]
	ld c, $05
	call $0234
	ld a, h
	ld [$D007], a
	ld a, [$C734]
	sub h
	ld [$D002], a
.at418E:
	ld hl, $D028
	ld a, $A1
	ld [hli], a
	ld a, $98
	ld [hli], a
	ld a, $01
	ld [hli], a
	ld a, $09
	ld [hli], a
	ld a, LOW(LocalMenuColumn)
	ld [hli], a
	ld a, HIGH(LocalMenuColumn)
	ld [hli], a
	ld a, $80
	ld [$D021], a
	call $517D
	call BuildLocalMinigameTitleList
	call $508A
	call $4E98
	call $517D
	call $50CF
	call PrepareLocalDescription
	ld a, $02
	ld c, $02
	ld de, $5BEA
	call $01E6
	xor a
	call $01FE
	ld a, [$D004]
	cp $04
	jr z, .at41EC
	ld hl, LocalMenuMap426D
	ld de, $9A2F
	ld bc, $0401
	call CopyTwoPlaneTilemap
	ld hl, LocalMenuMap4275
	ld de, $9A2A
	ld bc, $0401
	call CopyTwoPlaneTilemap
	jr .at41F8
.at41EC:
	ld hl, LocalMenuMap4275
	ld de, $9A2F
	ld bc, $0401
	call CopyTwoPlaneTilemap
.at41F8:
	ldh a, [$FF40]
	or $02
	and $EF
	ldh [$FF40], a
	ld a, $80
	ld [$D021], a
	call $517D
	call SumLocalFlashHeaderCounts
	ld a, [$D005]
	ld b, a
	ld a, $70
	sub b
	call $457E
	ld a, $03
	ld hl, $5188
	call $0177
	ret
.end:
ASSERT .end - LocalMenuState0 == $194
