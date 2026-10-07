; PROBABLE original indexed setup/blocking text contract; synthetic complete calls.
SECTION "Indexed and blocking text 2753-2798", ROM0[$2753]
ConfigureQueuedTextFromIndexedRecord::
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	ld a, c
	ldh [$FF9E], a
	ld a, [hli]
	ld b, a
	inc a
	ld [$C1A4], a
	ld a, [hli]
	ld c, a
	inc a
	inc a
	ld [$C1A7], a
	push hl
	call GetQueuedTilemapOffset
	ld a, [$C1B5]
	ld c, a
	ld a, [$C1B6]
	ld b, a
	add hl, bc
	ld e, l
	ld d, h
	pop hl
	ldh a, [$FF9E]
	ld c, a
	ld a, [hli]
	ld [$C1A8], a
	ld a, [hli]
	or a, a
	jr nz, IndexedText_2786
	ld a, c
IndexedText_2786::
	ld [$C1A9], a
	ld a, [hli]
	ld [$C1AA], a
	or a, a
	ld a, e
	ld [$C1A5], a
	ld a, d
	ld [$C1A6], a
	ld l, e
	ld h, d
	ret
ASSERT @ == $2799

; PROBABLE original indexed setup/blocking text contract; synthetic complete calls.
SECTION "Indexed and blocking text 28BE-28E2", ROM0[$28BE]
ResidualROM00_28BE::
RenderQueuedTextBlocking::
	ld a, b
	ld [$C1BC], a
	ld a, c
	ld [$C1BD], a
	ld a, l
	ld [$C1AB], a
	ld a, h
	ld [$C1AC], a
	ld a, $01
	ld [$C1B8], a
IndexedText_28D3::
	call AdvanceQueuedTileText
	ld a, [$C1B8]
	cp a, $03
	jp nz, IndexedText_28D3
	xor a, a
	ld [$C1B8], a
	ret
ASSERT @ == $28E3

; PROBABLE preparation route; nonzero-kind helper remains a bounded prefix.
SECTION "Indexed text preparation 2799-27A9", ROM0[$2799]
ResidualROM00_2799::
ConfigureAndPrepareQueuedTextRegion::
 call ConfigureQueuedTextFromIndexedRecord
 ld a, [$C1AA]
 or a, a
 jr z, .fill
 call $2BFE
 ret
.fill:
 call FillQueuedTextRectangle
 ret
ASSERT @ == $27AA
