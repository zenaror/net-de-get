; PROBABLE original menu refresh callback and banked two-plane copy.
; SYNTHETIC LCD-off full paths with HRAM DMA stub; no natural menu/timing.
SECTION "A16 refresh 4391-440B", ROMX[$4391], BANK[$0B]
CopyA16BankedBackgroundRectangle::
	ldh a, [$FF70]
	and a, $07
	push af
	push de
	push hl
	push bc
	ld a, $20
	call ResidentJump022E
	pop bc
	ld c, b
	ld b, $00
	add hl, bc
	ld bc, $9800
	ld a, [$C63A]
	bit 7, a
	jr z, A16Refresh_43B0
	ld bc, $9C00
A16Refresh_43B0::
	add hl, bc
	ld a, [$C63A]
	and a, $07
	ld a, a
	ldh [$FF70], a
	ld a, $00
	ldh [$FF4F], a
	ld e, l
	ld d, h
	pop bc
	pop hl
	ldh a, [$FF4F]
	and a, $01
	push af
	xor a, a
	ldh [$FF4F], a
A16Refresh_43C9::
	push bc
	push de
	ld a, b
	ldh [$FF9D], a
A16Refresh_43CE::
	ldh a, [$FF9D]
	ld b, a
A16Refresh_43D1::
	push bc
A16Refresh_43D2::
	ldh a, [$FF41]
	and a, $02
	jr nz, A16Refresh_43D2
	ld a, [hl]
	ld [de], a
	ldh a, [$FF41]
	and a, $02
	jr nz, A16Refresh_43D2
	inc hl
	pop bc
	inc de
	dec b
	jr nz, A16Refresh_43D1
	push hl
	ld hl, $FF9D
	ld a, $20
	sub a, [hl]
	ld l, a
	ld h, $00
	add hl, de
	ld d, h
	ld e, l
	pop hl
	dec c
	ld a, c
	or a, a
	jr nz, A16Refresh_43CE
	pop de
	pop bc
	ldh a, [$FF4F]
	xor a, $01
	ldh [$FF4F], a
	and a, $01
	jr nz, A16Refresh_43C9
	pop af
	ldh [$FF4F], a
	pop af
	ldh [$FF70], a
	ret
ASSERT @ == $440C

SECTION "A16 refresh 4B91-4BC9", ROMX[$4B91], BANK[$0B]
ResidualROM0B_4B91::
RefreshA16MenuDisplay::
	ld a, [$C5A9]
	and a, a
	jr z, A16Refresh_4BC3
	ld a, $07
	ld [$C63A], a
	ld bc, $0000
	ld hl, $0E06
	ld de, $D000
	call CopyA16BankedBackgroundRectangle
	ld c, $11
	ld b, $0F
	call ResidentJump0219
	ld bc, $9800
	add hl, bc
	push hl
	ld hl, A16MenuOverlayBytes
	pop de
	ld b, $04
	ld c, $01
	call CopyTwoPlaneTilemap
	xor a, a
	ld [$C5A9], a
A16Refresh_4BC3::
	call $FF80
	call UploadPendingCGBPalettes
	ret
ASSERT @ == $4BCA
