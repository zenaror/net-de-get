; PROBABLE cursor roles, static plus SYNTHETIC OAM-buffer probes.
; Native A $14, physical bank $0A lower half.
SECTION "Local list cursor", ROMX[$488E], BANK[$0A]
UpdateLocalListCursor::
	ld a, [$D007]
	swap a
	add a, $38
	ld [$C000], a
	call LocalCursorHorizontalJitter
	add a, $08
	ld [$C001], a
	ld a, $76
	ld [$C002], a
	ld a, $08
	ld [$C003], a
	ret
.end:
ASSERT .end - UpdateLocalListCursor == $1D

SECTION "Local remove cursor", ROMX[$48AB], BANK[$0A]
UpdateLocalRemoveCursor::
	ld a, $90
	ld [$C000], a
	xor a, a
	ld [$C001], a
	ld a, [$D01C]
	cp a, $FF
	jr z, .at48D6
	add a, LOW(LocalRemoveCursorOffsets)
	ld l, a
	ld a, HIGH(LocalRemoveCursorOffsets)
	adc a, $00
	ld h, a
	push hl
	call LocalCursorHorizontalJitter
	pop hl
	add a, [hl]
	ld [$C001], a
	ld a, $76
	ld [$C002], a
	ld a, $08
	ld [$C003], a
.at48D6:
	ret
.end:
ASSERT .end - UpdateLocalRemoveCursor == $2C

SECTION "Local move cursor", ROMX[$48DA], BANK[$0A]
UpdateLocalMoveCursor::
	ld a, [$D006]
	and a, $02
	jr nz, .at4923
	ld a, [$D00A]
	ld b, a
	ld a, [$D001]
	cp a, b
	jr nz, .at48FF
	ld a, [$D002]
	ld b, a
	ld a, [$D00B]
	cp a, b
	jr nz, .at48FF
	ld a, [$D007]
	ld b, a
	ld a, [$D00C]
	cp a, b
	jr nz, .at4905
.at48FF:
	xor a, a
	ld [$C000], a
	jr .at493F
.at4905:
	ld a, [$D00C]
	swap a
	add a, $38
	ld [$C000], a
	call LocalCursorHorizontalJitter
	add a, $08
	ld [$C001], a
	ld a, $76
	ld [$C002], a
	ld a, $08
	ld [$C003], a
	jr .at493F
.at4923:
	ld a, [$D007]
	swap a
	add a, $38
	ld [$C000], a
	call LocalCursorHorizontalJitter
	add a, $08
	ld [$C001], a
	ld a, $76
	ld [$C002], a
	ld a, $08
	ld [$C003], a
.at493F:
	ret
.end:
ASSERT .end - UpdateLocalMoveCursor == $66

