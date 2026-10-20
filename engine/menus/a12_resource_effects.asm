; PROBABLE original four-byte resource effects; complete synthetic integrations.
; FF installs/copies a seven-byte tile header, FE requests original upper streams.
SECTION "A12 resource effect 4FAF-4FFE", ROMX[$4FAF], BANK[$09]
ApplyA12ResourceTileEffect::
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
	ld [wA12FrameSourceLow], a
	ld a, [hli]
	ld [wA12FrameSourceHigh], a
	push hl
	ld a, [wA12FrameSourceHigh]
	ld h, a
	ld a, [wA12FrameSourceLow]
	ld l, a
	ld a, [hli]
	ld [wA12TilemapColumn], a
	ld a, [hli]
	ld [wA12TilemapRow], a
	ld a, [hli]
	ld [wA12FrameWidth], a
	ld a, [hli]
	ld [wA12FrameHeight], a
	ld a, [hli]
	ld [wA12FrameCount], a
	ld a, [hli]
	ld [wA12FrameDelay], a
	ld a, [hli]
	ld [wA12FrameLoop], a
	ld a, h
	ld [wA12FrameSourceHigh], a
	ld [wA12FrameSourceStartHigh], a
	ld a, l
	ld [wA12FrameSourceLow], a
	ld [wA12FrameSourceStartLow], a
	call $4FFF
	ld a, [$C5CE]
	inc a
	ld [$C5CE], a
	xor a, a
	ld [wA12FrameDelayAccumulator], a
	ld [wA12FrameIndex], a
	pop hl
	ret
ASSERT @ == $4FFF

SECTION "A12 resource effect 50C8-50D7", ROMX[$50C8], BANK[$09]
ResidualROM09_50C8::
ApplyA12ResourceAudioEffect::
	ld a, [hli]
	ld a, [hli]
	ld a, a
	call $024F
	ld a, [hli]
	ld a, [hli]
	ld a, [$C5CE]
	inc a
	ld [$C5CE], a
	ret
ASSERT @ == $50D8
