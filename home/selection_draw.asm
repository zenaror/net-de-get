; PROBABLE bounded selection-text draw flow; synthetic terminated records only.
; Preserve original byte arithmetic and asymmetric abort cleanup.
SECTION "Selection activation 2945-294D", ROM0[$2945]
ResidualROM00_2945::
ActivateSelectionText::
	ld a, $01
	ld [$C213], a
	call DrawSelectionText
	ret
ASSERT @ == $294E

SECTION "Selection text drawing 30BC-3189", ROM0[$30BC]
DrawSelectionText::
	push af
	push bc
	push de
	push hl
	call FillQueuedTextRectangle
	ld a, [$C20A]
	ld l, a
	ld a, [$C20B]
	ld h, a
	ld a, [$C20E]
	ld c, a
	ld a, [$C212]
	call MultiplyAByCLowByte
	ld c, a
	ld a, [$C210]
	call MultiplyAByCLowByte
	ld e, a
	ld a, $00
SelectionDraw_30DF::
	push af
	cp a, e
	jr nc, SelectionDraw_30F7
SelectionDraw_30E3::
	ld a, [hl]
	inc hl
	or a, a
	jr nz, SelectionDraw_30E3
	dec hl
	dec hl
	ld a, [hl]
	inc hl
	inc hl
	cp a, $02
	jr nz, SelectionDraw_30F3
	jr SelectionDraw_30E3
SelectionDraw_30F3::
	pop af
	inc a
	jr SelectionDraw_30DF
SelectionDraw_30F7::
	pop af
	ld a, [$C1BD]
	push af
	ld a, [$C20E]
	ld [$C1BD], a
	ld a, $00
	ld d, a
SelectionDraw_3105::
	ld a, [$C1BD]
	push af
	push de
	ld c, a
	ld a, [$C20E]
	sub a, c
	rlca
	ld c, a
	ld a, [$C212]
	call MultiplyAByCLowByte
	add a, c
	sra a
	ld e, a
	ld a, [$C20F]
	inc a
	cp a, e
	jr c, SelectionDraw_3182
	ld e, c
	ld a, [$C20D]
	inc a
	inc a
	ld c, d
	call MultiplyAByCLowByte
	ld b, a
	ld c, e
	push bc
	ld a, [$C20E]
	ld c, a
	ld a, [$C212]
	call MultiplyAByCLowByte
	ld c, a
	ld a, [$C210]
	call MultiplyAByCLowByte
	ld e, a
	ld a, [$C1BD]
	ld c, a
	ld a, [$C20E]
	sub a, c
	ld c, a
	ld a, [$C210]
	call MultiplyAByCLowByte
	add a, d
	add a, e
	ld e, a
	pop bc
	ld a, [$C20F]
	dec a
	cp a, e
	jr c, SelectionDraw_3182
	call RenderQueuedTextBlocking
	pop de
	pop af
	ld [$C1BD], a
	ld a, [$C210]
	ld e, a
	inc d
	ld a, d
	cp a, e
	jr c, SelectionDraw_3105
	ld a, $00
	ld d, a
	ld a, [$C1BD]
	dec a
	ld [$C1BD], a
	ld a, [$C1BD]
	or a, a
	jr nz, SelectionDraw_3105
	pop af
	ld [$C1BD], a
	jr SelectionDraw_3185
SelectionDraw_3182::
	pop de
	pop af
	pop af
SelectionDraw_3185::
	pop hl
	pop de
	pop bc
	pop af
	ret
ASSERT @ == $318A
