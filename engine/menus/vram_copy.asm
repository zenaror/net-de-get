; PROBABLE byte-copy helper: each source byte is copied to [DE] with a STAT
; check around the write. BC=0 wraps through 65536 bytes because the count is
; tested after decrement. It does not save the caller's interrupt-enable state.
SECTION "Copy BC bytes to DE with STAT wait 5D5C-5D73", ROMX[$5D5C], BANK[$09]
CopyBCBytesToDEWithSTATWait::
.wait
	di
.waitForMode
	ldh a, [$FF41]
	and a, $02
	jr nz, .waitForMode
	ld a, [hl]
	ld [de], a
	ei
	ldh a, [$FF41]
	and a, $02
	jr nz, .wait
	inc hl
	inc de
	dec bc
	ld a, b
	or a, c
	jr nz, .wait
	ret
ASSERT @ == $5D74
