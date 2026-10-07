; PROBABLE initialization of fields read by the adjacent joypad selection code.
; Address-based field names; no natural menu extent or parameter validity claim.
SECTION "Selection field initialization 28E3-2944", ROM0[$28E3]
ResidualROM00_28E3::
InitializeSelectionFieldsC20A::
	ld a, l
	ld [$C20A], a
	ld a, h
	ld [$C20B], a
	ld hl, $C20D
	ld [hl], b
	inc hl
	ld [hl], c
	inc hl
	ld [hl], d
	inc hl
	ld [hl], e
	xor a, a
	ld [$C211], a
	ld [$C212], a
	ld [$C213], a
	ld [$C214], a
	ld [$C215], a
	ld [$C216], a
	ld [$C217], a
	ld [$C21B], a
	push bc
	ld a, d
	ld c, e
	call DivideByteByByte
	ld d, l
	pop bc
	ld a, d
	call DivideByteByByte
	ld a, l
	ld [$C217], a
	ld a, h
	or a, a
	ld a, c
	jr z, SelectionFields_2938
	inc l
	ld a, l
	ld [$C217], a
	push hl
	ld a, [$C20F]
	ld c, e
	call DivideByteByByte
	ld a, $00
	cp a, h
	pop hl
	jr z, SelectionFields_2937
	inc h
SelectionFields_2937::
	ld a, h
SelectionFields_2938::
	ld hl, $C211
	ld [hli], a
	xor a, a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld a, $FF
	ld [hli], a
	ld [hli], a
	ret
ASSERT @ == $2945
