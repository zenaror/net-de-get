; PROBABLE frame drawing contract, checked with forced CPU calls.
; Each cell writes tile plane 0 and attribute plane 1 with original STAT waits.
; Width zero means 256 interior cells; doubled height zero means 256 middle rows.
; No clipping. EI does not preserve incoming IME. Japanese tile bytes unchanged.
SECTION "Queued text frame 2BFE-2D45", ROM0[$2BFE]
DrawQueuedTextFrame::
	ldh a, [$FF4F]
	and a, $01
	push af
	xor a, a
	ldh [$FF4F], a
	ld a, [$C1AA]
	cp a, $01
	ld e, $6C
	jr z, QueuedFrame_2C11
	ld e, $75
QueuedFrame_2C11::
	push hl
QueuedFrame_2C12::
	di
QueuedFrame_2C13::
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedFrame_2C13
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
	jr nz, QueuedFrame_2C12
	inc hl
	inc e
	ld a, [$C1A8]
	ld b, a
QueuedFrame_2C33::
	di
QueuedFrame_2C34::
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedFrame_2C34
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
	jr nz, QueuedFrame_2C33
	inc hl
	dec b
	jr nz, QueuedFrame_2C33
	inc e
QueuedFrame_2C53::
	di
QueuedFrame_2C54::
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedFrame_2C54
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
	jr nz, QueuedFrame_2C53
	inc e
	pop hl
	ld bc, $0020
	add hl, bc
	ld a, [$C1A9]
	add a, a
	ld c, a
QueuedFrame_2C79::
	push hl
QueuedFrame_2C7A::
	di
QueuedFrame_2C7B::
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedFrame_2C7B
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
	jr nz, QueuedFrame_2C7A
	inc hl
	inc e
	ld a, [$C1A8]
	ld b, a
QueuedFrame_2C9B::
	di
QueuedFrame_2C9C::
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedFrame_2C9C
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
	jr nz, QueuedFrame_2C9B
	inc hl
	dec b
	jr nz, QueuedFrame_2C9B
	inc e
QueuedFrame_2CBB::
	di
QueuedFrame_2CBC::
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedFrame_2CBC
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
	jr nz, QueuedFrame_2CBB
	dec e
	dec e
	pop hl
	push bc
	ld bc, $0020
	add hl, bc
	pop bc
	dec c
	jp nz, QueuedFrame_2C79
	inc e
	inc e
	inc e
QueuedFrame_2CE6::
	di
QueuedFrame_2CE7::
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedFrame_2CE7
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
	jr nz, QueuedFrame_2CE6
	inc hl
	inc e
	ld a, [$C1A8]
	ld b, a
QueuedFrame_2D07::
	di
QueuedFrame_2D08::
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedFrame_2D08
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
	jr nz, QueuedFrame_2D07
	inc hl
	dec b
	jr nz, QueuedFrame_2D07
	inc e
QueuedFrame_2D27::
	di
QueuedFrame_2D28::
	ldh a, [$FF41]
	and a, $02
	jr nz, QueuedFrame_2D28
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
	jr nz, QueuedFrame_2D27
	pop af
	ldh [$FF4F], a
	ret
ASSERT @ == $2D46
