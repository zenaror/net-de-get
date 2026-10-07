; PROBABLE original glyph upload and tilemap addressing; SYNTHETIC CPU paths.
; STAT waits/HDMA and forced mapper selection retain original bytes.
SECTION "Queued glyph 2F1C-2FDF", ROM0[$2F1C]
ResidualROM00_2F1C::
RenderQueuedTileGlyph::
	di
	ld d, a
	ldh a, [$FF4F]
	and a, $01
	push af
	ld a, [$C1AF]
	ldh [$FF4F], a
	ld a, $02
	ld [$27FF], a
	ld [$C113], a
	xor a, a
	ld [$2800], a
	ld [$C114], a
	push bc
	ld a, d
	ld c, $10
	call MultiplyAByCToHL
	ld bc, $3F00
	add hl, bc
	ld c, l
	ld b, h
	ld hl, $FF51
	ld [hl], b
	inc hl
	ld [hl], c
	ld a, [$C1C2]
	ld c, a
	ld a, $6B
	sub a, c
	ld [$C1C3], a
	ld a, c
	ld c, $10
	call MultiplyAByCToHL
	ld d, h
	ld e, l
	ld hl, $96B0
	call SubtractDEFromHL
	ld d, h
	ld e, l
	ld hl, $FF53
	ld [hl], d
	inc hl
	ld [hl], e
	pop bc
	call GetQueuedTilemapOffset
	ld a, [$C1B5]
	ld c, a
	ld a, [$C1B6]
	ld b, a
	add hl, bc
	xor a, a
	ldh [$FF4F], a
QueuedGlyph_2F7A::
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedGlyph_2F7A
	ld a, [$C1C3]
	ld [hl], a
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedGlyph_2F7A
	ld a, $01
	ldh [$FF4F], a
QueuedGlyph_2F8E::
	ld c, l
	ld b, h
	ld a, [$C1BF]
	ld hl, $C1B0
	ld d, $00
	ld e, a
	add hl, de
	ld a, [hl]
	ld l, c
	ld h, b
	ld c, a
QueuedGlyph_2F9E::
	ldh a, [$FF41]
	and a, $02
	jr z, QueuedGlyph_2F9E
QueuedGlyph_2FA4::
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedGlyph_2FA4
	ld a, c
	ld [hl], a
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedGlyph_2F8E
QueuedGlyph_2FB2::
	ldh a, [$FF41]
	and a, $03
	jr nz, QueuedGlyph_2FB2
	ld a, $00
	or a, $80
	ldh [$FF55], a
	ldh a, [$FF41]
	and a, $03
	jr nz, QueuedGlyph_2FB2
	ld a, [$C1C2]
	inc a
	ld [$C1C2], a
	ldh a, [$FFAB]
	ld [$27FF], a
	ld [$C113], a
	ldh a, [$FFAC]
	ld [$2800], a
	ld [$C114], a
	pop af
	ldh [$FF4F], a
	ei
	ret
ASSERT @ == $2FE0

SECTION "Queued glyph 2FE0-2FF0", ROM0[$2FE0]
GetQueuedTilemapOffset::
	ld hl, QueuedTilemapRowOffsets
	ld a, c
	add a, a
	ld d, $00
	ld e, a
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, $00
	ld l, b
	add hl, de
	ret
ASSERT @ == $2FF1

SECTION "Queued glyph 2FF1-3030", ROM0[$2FF1]
QueuedTilemapRowOffsets::
	dw $0000, $0020, $0040, $0060, $0080, $00A0, $00C0, $00E0
	dw $0100, $0120, $0140, $0160, $0180, $01A0, $01C0, $01E0
	dw $0200, $0220, $0240, $0260, $0280, $02A0, $02C0, $02E0
	dw $0300, $0320, $0340, $0360, $0380, $03A0, $03C0, $03E0
ASSERT @ == $3031
