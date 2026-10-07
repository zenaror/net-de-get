; PROBABLE two-plane queued-text fill; forced SYNTHETIC dimensions only.
; Zero byte dimensions decrement through256; natural validity is not established.
SECTION "Queued text rectangle 2D53-2DC2", ROM0[$2D53]
FillQueuedTextRectangle::
	ldh a, [$FF4F]
	and a, $01
	push af
	xor a, a
	ldh [$FF4F], a
	ld a, [$C1AA]
	cp a, $01
	ld a, $6C
	jr z, QueuedFill_2D66
	ld a, $75
QueuedFill_2D66::
	add a, $04
	ld [$C1C3], a
	xor a, a
	ld [$C1BC], a
	ld [$C1BD], a
	ld a, [$C1A7]
	dec a
	ld c, a
	ld a, [$C1A4]
	ld b, a
	call GetQueuedTilemapOffset
	ld a, [$C1B5]
	ld c, a
	ld a, [$C1B6]
	ld b, a
	add hl, bc
	ld a, [$C1C3]
	ld e, a
	ld a, [$C1A9]
	add a, a
	ld c, a
QueuedFill_2D90::
	ld a, [$C1A8]
	ld b, a
	push bc
	push hl
QueuedFill_2D96::
	di
QueuedFill_2D97::
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedFill_2D97
	ld [hl], e
	ld a, $01
	ldh [$FF4F], a
	ld a, [$C1A3]
	ld [hl], a
	ld a, $00
	ldh [$FF4F], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedFill_2D96
	inc hl
	dec b
	jr nz, QueuedFill_2D96
	pop hl
	ld bc, $0020
	add hl, bc
	pop bc
	dec c
	jp nz, QueuedFill_2D90
	pop af
	ldh [$FF4F], a
	ret
ASSERT @ == $2DC3
