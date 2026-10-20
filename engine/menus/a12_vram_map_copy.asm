; PROBABLE A12 map-resource path based on callers and destinations $9800/$9C00.
; Selector values are restored after the copy; natural menu use is unproven.
SECTION "A12 VRAM map resource copy 5E1D-5E78", ROMX[$5E1D], BANK[$09]
CopyA12ResourceToVRAMMap::
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
	call CopyA12ResourceToBothVRAMBanks
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
	call CopyA12ResourceToBothVRAMBanks
	ldh a, [$FF9D]
	ldh [$FFAD], a
	ld [$37FF], a
	ldh a, [$FF9E]
	ldh [$FFAE], a
	ld a, a
	ld [$3800], a
.return
	ret
ASSERT @ == $5E79

SECTION "A12 VRAM map copy to both banks 5E79-5E97", ROMX[$5E79], BANK[$09]
CopyA12ResourceToBothVRAMBanks::
	ld a, $00
	ldh [$FF4F], a
	ld de, $9800
	ld bc, $0400
	call CopyBCBytesToDEWithSTATWait
	ld a, $01
	ldh [$FF4F], a
	ld de, $9800
	ld bc, $0400
	call CopyBCBytesToDEWithSTATWait
	ld a, $00
	ldh [$FF4F], a
	ret
ASSERT @ == $5E98
