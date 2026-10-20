; PROBABLE resource copier: selected A12 handlers call the entry at $5F43.
; It preserves/restores one of the two selector register pairs around a
; resource stream copy. The stream marker and natural VRAM timing are unproven.
SECTION "A12 graphics resource copy 5F43-5F9E", ROMX[$5F43], BANK[$09]
LoadA12GraphicsResourceToVRAM::
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
	call CopyA12GraphicsResourcePasses
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
	call CopyA12GraphicsResourcePasses
	ldh a, [$FF9D]
	ldh [$FFAD], a
	ld [$37FF], a
	ldh a, [$FF9E]
	ldh [$FFAE], a
	ld a, a
	ld [$3800], a
.return
	ret
ASSERT @ == $5F9F

SECTION "A12 graphics resource copy setup 5F9F-5FAF", ROMX[$5F9F], BANK[$09]
CopyA12GraphicsResourcePasses::
	ld de, $8000
	ld c, $98
	call CopyA12GraphicsResourceStream
	ld de, $8001
	ld c, $98
	call CopyA12GraphicsResourceStream
	ret
ASSERT @ == $5FB0

SECTION "A12 graphics resource stream copy 5FB0-5FEC", ROMX[$5FB0], BANK[$09]
CopyA12GraphicsResourceStream::
.nextRecord
	ld a, [hl]
	push af
	inc hl
.compareNext
	ld a, [hl]
	ld b, a
	pop af
	push af
	cp a, b
	jr nz, .single
	inc hl
	ld a, [hli]
	ld b, a
.repeat
	di
.waitRepeat
	ldh a, [$FF41]
	and a, $02
	jr nz, .waitRepeat
	ld a, [hl]
	ld [de], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, .repeat
	inc de
	inc de
	dec b
	jr nz, .repeat
	jr .advance
.single
	di
.waitSingle
	ldh a, [$FF41]
	and a, $02
	jr nz, .waitSingle
	ld a, [hl]
	ld [de], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, .single
	inc de
	inc de
.advance
	inc hl
	ld a, d
	cp a, c
	jr nz, .compareNext
	pop af
	ret
ASSERT @ == $5FED
