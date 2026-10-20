; PROBABLE A12 tile-frame control, source advance and bounded original copying.
; Frame advance uses twice the low byte of width*height; retain overflow behavior.
; InitializeA12TileFrames consumes: column,row,width,height,count,delay,loop byte.
; Static plus synthetic evidence only; no natural menu/IRQ or physical timing proof.

SECTION "A12 tile frame copy 4FFF-5050", ROMX[$4FFF], BANK[$09]
CopyA12TileFrame::
	ld a, [wA12TilemapColumn]
	ldh [$FF9D], a
	ld d, $00
	ld a, [wA12TilemapRow]
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
	ld a, [wA12FrameSourceHigh]
	ld h, a
	ld a, [wA12FrameSourceLow]
	ld l, a
	pop de
	ld a, [wA12FrameWidth]
	ld b, a
	ld a, [wA12FrameHeight]
	ld c, a
	call CopyBankedTwoPlaneTilemap
	ld a, [wA12FrameWidth]
	ld h, a
	ld a, [wA12FrameHeight]
	ld l, a
	call MultiplyA12HLBytes
	ld h, $02
	call MultiplyA12HLBytes
	ld a, [wA12FrameSourceHigh]
	ld d, a
	ld a, [wA12FrameSourceLow]
	ld e, a
	add hl, de
	ld a, h
	ld [wA12FrameSourceHigh], a
	ld a, l
	ld [wA12FrameSourceLow], a
	ret
ASSERT @ == $5051

SECTION "A12 tile frame tick 5051-5092", ROMX[$5051], BANK[$09]
TickA12TileFrame::
	ld a, [wA12FrameDelay]
	cp a, $00
	ret z
	ld b, a
	ld a, [wA12FrameDelayAccumulator]
	sub a, b
	ret c
	xor a, a
	ld [wA12FrameDelayAccumulator], a
	ld a, [wA12FrameCount]
	ld b, a
	ld a, [wA12FrameIndex]
	inc a
	cp a, b
	jr nz, A12Frame_5087
	xor a, a
	ld [wA12FrameIndex], a
	ld a, [wA12FrameLoop]
	cp a, $00
	jr z, A12Frame_508E
	ld a, [wA12FrameSourceStartHigh]
	ld [wA12FrameSourceHigh], a
	ld a, [wA12FrameSourceStartLow]
	ld [wA12FrameSourceLow], a
	call CopyA12TileFrame
	ret
A12Frame_5087::
	ld [wA12FrameIndex], a
	call CopyA12TileFrame
	ret
A12Frame_508E::
	xor a, a
	ld [wA12FrameDelay], a
	ret
ASSERT @ == $5093

SECTION "A12 tile frame setup 5093-50C7", ROMX[$5093], BANK[$09]
InitializeA12TileFrames::
	ld a, [hli]
	ld [wA12TilemapColumn], a
	ld a, [hli]
	ld [wA12TilemapRow], a
	ld a, [hli]
	ld [wA12FrameWidth], a
	ld a, [hli]
	ld [wA12FrameHeight], a
	ld a, [hli]
	ld [wA12FrameCount], a
	ld a, [hli]
	ld [wA12FrameDelay], a
	ld a, [hli]
	ld [wA12FrameLoop], a
	ld a, h
	ld [wA12FrameSourceHigh], a
	ld [wA12FrameSourceStartHigh], a
	ld a, l
	ld [wA12FrameSourceLow], a
	ld [wA12FrameSourceStartLow], a
	call CopyA12TileFrame
	xor a, a
	ld [wA12FrameDelayAccumulator], a
	ld [wA12FrameIndex], a
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
