; PROBABLE pair-list search; preserve eight-bit B increment/decrement.
; Native A $14, physical bank $0A lower half.
SECTION "Local list entry lookup", ROMX[$4CDA], BANK[$0A]
FindLocalListEntry::
	ld hl, $D1E6
	inc b
.at4CDE:
	ld a, [hli]
	ld [$C5C3], a
	cp a, $FF
	jr z, .at4CEF
	ld a, [hli]
	cp a, c
	jr nz, .at4CDE
	dec b
	jr nz, .at4CDE
	dec hl
	dec hl
.at4CEF:
	ret
.end:
ASSERT .end - FindLocalListEntry == $16
