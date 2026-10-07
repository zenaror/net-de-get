; PROBABLE A12 tile-frame control, source advance and bounded original copying.
; Frame advance uses twice the low byte of width*height; retain overflow behavior.
; Static plus synthetic evidence only; no natural menu/IRQ or physical timing proof.

SECTION "A12 tile frame copy 4FFF-5050", ROMX[$4FFF], BANK[$09]
CopyA12TileFrame::
	ld a, [$C5F9]
	ldh [$FF9D], a
	ld d, $00
	ld a, [$C5FA]
	ld e, a
	ld bc, $0020
	call ResidentJump0231
	ldh a, [$FF9D]
	ld b, $00
	ld c, a
	add hl, bc
	ld bc, $9800
	add hl, bc
	push hl
	ld a, [$C5F7]
	ld h, a
	ld a, [$C5F8]
	ld l, a
	pop de
	ld a, [$C5E2]
	ld b, a
	ld a, [$C5E3]
	ld c, a
	call CopyBankedTwoPlaneTilemap
	ld a, [$C5E2]
	ld h, a
	ld a, [$C5E3]
	ld l, a
	call MultiplyA12HLBytes
	ld h, $02
	call MultiplyA12HLBytes
	ld a, [$C5F7]
	ld d, a
	ld a, [$C5F8]
	ld e, a
	add hl, de
	ld a, h
	ld [$C5F7], a
	ld a, l
	ld [$C5F8], a
	ret
ASSERT @ == $5051

SECTION "A12 tile frame tick 5051-5092", ROMX[$5051], BANK[$09]
TickA12TileFrame::
	ld a, [$C5E4]
	cp a, $00
	ret z
	ld b, a
	ld a, [$C5E5]
	sub a, b
	ret c
	xor a, a
	ld [$C5E5], a
	ld a, [$C5E6]
	ld b, a
	ld a, [$C5E7]
	inc a
	cp a, b
	jr nz, A12Frame_5087
	xor a, a
	ld [$C5E7], a
	ld a, [$C5E8]
	cp a, $00
	jr z, A12Frame_508E
	ld a, [$C5FB]
	ld [$C5F7], a
	ld a, [$C5FC]
	ld [$C5F8], a
	call CopyA12TileFrame
	ret
A12Frame_5087::
	ld [$C5E7], a
	call CopyA12TileFrame
	ret
A12Frame_508E::
	xor a, a
	ld [$C5E4], a
	ret
ASSERT @ == $5093

SECTION "A12 tile frame setup 5093-50C7", ROMX[$5093], BANK[$09]
InitializeA12TileFrames::
	ld a, [hli]
	ld [$C5F9], a
	ld a, [hli]
	ld [$C5FA], a
	ld a, [hli]
	ld [$C5E2], a
	ld a, [hli]
	ld [$C5E3], a
	ld a, [hli]
	ld [$C5E6], a
	ld a, [hli]
	ld [$C5E4], a
	ld a, [hli]
	ld [$C5E8], a
	ld a, h
	ld [$C5F7], a
	ld [$C5FB], a
	ld a, l
	ld [$C5F8], a
	ld [$C5FC], a
	call CopyA12TileFrame
	xor a, a
	ld [$C5E5], a
	ld [$C5E7], a
	ret
ASSERT @ == $50C8

SECTION "A12 byte multiply 5CFF-5D10", ROMX[$5CFF], BANK[$09]
MultiplyA12HLBytes::
	push bc
	push de
	ld e, l
	ld d, $00
	ld l, d
	ld b, $08
A12Frame_5D07::
	add hl, hl
	jr nc, A12Frame_5D0B
	add hl, de
A12Frame_5D0B::
	dec b
	jr nz, A12Frame_5D07
	pop de
	pop bc
	ret
ASSERT @ == $5D11
