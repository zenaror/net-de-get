; PROBABLE queued text consumer and four-byte display-record producer.
; SYNTHETIC paths; no natural glyph rendering, callback or LCD timing trace.
SECTION "Queued text 118F-11A9", ROM0[$118F]
AppendFourByteDisplayRecord::
	ld hl, $C1C4
	ld a, [hl]
	cp a, $10
	ret nc
	inc [hl]
	push de
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, $C1CA
	add hl, de
	pop de
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
	ld [hl], c
	inc hl
	ld [hl], b
	ret
ASSERT @ == $11AA

SECTION "Queued text 2DD0-2DE6", ROM0[$2DD0]
ResidualROM00_2DD0::
QueueTextCursorDisplayRecord::
	call ComputeQueuedTextCursorDE
	ldh a, [$FF8B]
	srl a
	srl a
	srl a
	and a, $01
	ld c, $FF
	ld h, a
	ld a, $7E
	add a, h
	ld b, a
	jp AppendFourByteDisplayRecord
ASSERT @ == $2DE7

SECTION "Queued text 2DE7-2E14", ROM0[$2DE7]
ComputeQueuedTextCursorDE::
	ld hl, $C1A5
	ld a, [$C1A8]
	add a, [hl]
	inc a
	and a, $1F
	add a, a
	add a, a
	add a, a
	ld e, a
	ld a, $08
	add a, e
	ld e, a
	ld a, [hli]
	swap a
	and a, $0E
	ld d, a
	ld a, [hl]
	swap a
	and a, $30
	or a, d
	ld d, a
	ld a, [$C1A9]
	inc a
	add a, a
	add a, a
	add a, d
	add a, a
	add a, a
	ld d, a
	ld a, $08
	add a, d
	ld d, a
	ret
ASSERT @ == $2E15

SECTION "Queued text 2E15-2EE8", ROM0[$2E15]
AdvanceQueuedTileText::
	ld a, $00
	ld [$C1BE], a
	ld a, [$C1AB]
	ld l, a
	ld a, [$C1AC]
	ld h, a
	ld a, [hli]
	ld b, a
	ld a, l
	ld [$C1AB], a
	ld a, h
	ld [$C1AC], a
	ld a, b
	and a, a
	jr nz, QueuedText_2E50
	ld a, [$C1B9]
	and a, a
	jr z, QueuedText_2E4A
	ld a, [$C1B9]
	dec a
	ld [$C1B9], a
	ld a, [$C1AD]
	ld [$C1AB], a
	ld a, [$C1AE]
	ld [$C1AC], a
	ret
QueuedText_2E4A::
	ld a, $03
	ld [$C1B8], a
	ret
QueuedText_2E50::
	cp a, $01
	jr nz, QueuedText_2E58
	call AdvanceQueuedTextLine
	ret
QueuedText_2E58::
	cp a, $02
	jr nz, QueuedText_2E71
	ld a, [$C1AB]
	ld l, a
	ld a, [$C1AC]
	ld h, a
	ld a, [hli]
	ld [$C1BF], a
	ld a, l
	ld [$C1AB], a
	ld a, h
	ld [$C1AC], a
	ret
QueuedText_2E71::
	cp a, $03
	jr nz, QueuedText_2EA7
	ld a, [$C1AB]
	ld l, a
	ld a, [$C1AC]
	ld h, a
	ld a, [hli]
	ldh [$FF9D], a
	ld a, l
	ld [$C1AB], a
	ld a, h
	ld [$C1AC], a
	ld a, l
	ld [$C1AD], a
	ld a, h
	ld [$C1AE], a
	ld a, [$C1B9]
	inc a
	ld [$C1B9], a
	ld hl, $C1C0
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, d
	ld l, e
	ld a, l
	or a, h
	jr nz, QueuedText_2EA4
	ret
QueuedText_2EA4::
	ldh a, [$FF9D]
	jp hl
QueuedText_2EA7::
	cp a, $04
	jr nz, QueuedText_2EAF
	call FillQueuedTextRectangle
	ret
QueuedText_2EAF::
	cp a, $0F
	jr nz, QueuedText_2EB9
	ld a, $04
	ld [$C1B8], a
	ret
QueuedText_2EB9::
	ldh [$FF9D], a
	ld a, [$C1BC]
	ld b, a
	ld a, [$C1A4]
	add a, b
	ld b, a
	ld a, [$C1BD]
	ld c, a
	ld a, [$C1A7]
	add a, c
	ld c, a
	ldh a, [$FF9D]
	add a, $02
	jr nc, QueuedText_2ED9
	ld a, $01
	ld [$C1BE], a
	dec c
QueuedText_2ED9::
	ldh a, [$FF9D]
	call RenderQueuedTileGlyph
	ld a, [$C1BE]
	and a, a
	jp nz, AdvanceQueuedTileText
	call AdvanceQueuedTextColumn
	ret
ASSERT @ == $2EE9

SECTION "Queued text 2EE9-2EF9", ROM0[$2EE9]
AdvanceQueuedTextColumn::
	ld a, [$C1BC]
	inc a
	ld [$C1BC], a
	ld b, a
	dec b
	ld a, [$C1A8]
	dec a
	ld c, a
	ld a, b
	cp a, c
	ret c
ASSERT @ == $2EFA

SECTION "Queued text 2EFA-2F1B", ROM0[$2EFA]
AdvanceQueuedTextLine::
	ld a, [$C1BC]
	or a, a
	ret z
	xor a, a
	ld [$C1BC], a
	ld a, [$C1BD]
	inc a
	inc a
	ld [$C1BD], a
	ld b, a
	ld a, [$C1A9]
	add a, a
	cp a, b
	ret nz
	xor a, a
	ld [$C1BD], a
	ld a, $02
	ld [$C1B8], a
	ret
ASSERT @ == $2F1C
