; PROBABLE static OAM indicators. Retain eight-bit offset+5 wrap semantics.
; Native A $14; physical RGBDS bank $0A lower half.
SECTION "Local list OAM indicators", ROMX[$461A], BANK[$0A]
UpdateLocalListIndicators::
	xor a
	ld [$C070], a
	ld [$C074], a
	ld a, [$D006]
	and $10
	jr nz, .return
	ld a, [$D002]
	and a
	jr z, .lower
	ld hl, $C070
	ld a, $30
	ld [hli], a
	ld a, $A0
	ld [hli], a
	xor a
	ld [hli], a
	xor a
	ld [hli], a
.lower:
	ld a, [wTitleListCount]
	ld b, a
	ld a, [$D002]
	add a, $05
	cp b
	jr nc, .return
	ld hl, $C074
	ld a, $78
	ld [hli], a
	ld a, $A0
	ld [hli], a
	ld a, $01
	ld [hli], a
	xor a
	ld [hli], a
.return:
	ret
.end:
ASSERT .end - UpdateLocalListIndicators == $3C
