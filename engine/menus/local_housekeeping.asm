; PROBABLE static helper roles; native A $14, physical RGBDS bank $0A.
SECTION "Clear local OAM buffer", ROMX[$5B26], BANK[$0A]
ClearLocalOAMBuffer::
	ld hl, $C000
	xor a
	ld b, $A0
.at5B2C:
	ld [hli], a
	dec b
	jr nz, .at5B2C
	ret
.end:
ASSERT .end - ClearLocalOAMBuffer == $B

SECTION "Sum local flash header counts", ROMX[$5B31], BANK[$0A]
SumLocalFlashHeaderCounts::
	ld a, [$D06B]
	swap a
	ld [$C5CB], a
	xor a
	ld [$C5C4], a
	xor a
	ld [$C5C9], a
	call EnableFlashReads
	ld hl, $D1E6
.at5B47:
	ld a, [hli]
	inc hl
	cp $FF
	jr z, .at5B82
	sub $10
	jr c, .at5B47
	ld e, a
	di
	ld a, e
	ld [$37FF], a
	ldh [$FFAD], a
	ld [$C115], a
	ld a, $08
	ld [$3800], a
	ldh [$FFAE], a
	ld [$C116], a
	ei
	ld a, [$6044]
	cp $FF
	jr nz, .at5B47
	ld a, [$6005]
	cp $11
	jr nc, .at5B47
	ld a, [$C5C9]
	ld c, a
	ld a, [$6005]
	add a, c
	ld [$C5C9], a
	jr .at5B47
.at5B82:
	call DisableFlashReads
	ld a, [$C5C9]
	ld [$D005], a
	ret
.end:
ASSERT .end - SumLocalFlashHeaderCounts == $5B

