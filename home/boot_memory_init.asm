; PROBABLE startup memory clearing from static SM83 flow.
; VRAM/STAT timing has no new CPU or hardware validation.
SECTION "Descending clear from FEFF", ROM0[$0A03]
ResidualROM00_0A03::
Clear256BytesDescendingFromFEFF::
	xor a, a
	ld hl, $FEFF
	ld b, $00
.clearDescending
	ld [hl-], a
	dec b
	jr nz, .clearDescending
	ret
ASSERT @ == $0A0E

SECTION "Clear both VRAM banks", ROM0[$0A0E]
ClearBothVRAMBanks::
	xor a, a
	ldh [$FF4F], a
	ld hl, $8000
	ld bc, $2000
	.clearBank0
	di
.waitBank0
	ldh a, [$FF41]
	and a, $02
	jr nz, .waitBank0
	ld a, $00
	ld [hl], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, .clearBank0
	inc hl
	dec bc
	ld a, c
	or a, b
	jr nz, .clearBank0
	ld a, $01
	ldh [$FF4F], a
	ld hl, $8000
	ld bc, $2000
	.clearBank1
	di
.waitBank1
	ldh a, [$FF41]
	and a, $02
	jr nz, .waitBank1
	ld a, $00
	ld [hl], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, .clearBank1
	inc hl
	dec bc
	ld a, c
	or a, b
	jr nz, .clearBank1
	ret
ASSERT @ == $0A50
