; PROBABLE original four-byte resource effects; complete synthetic integrations.
; FF installs/copies a seven-byte tile header, FE requests original upper streams.
SECTION "A12 resource effect 4FAF-4FFE", ROMX[$4FAF], BANK[$09]
ApplyA12ResourceTileEffect::
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
	ld [$C5F8], a
	ld a, [hli]
	ld [$C5F7], a
	push hl
	ld a, [$C5F7]
	ld h, a
	ld a, [$C5F8]
	ld l, a
	ld a, [hli]
	ld [$C5F9], a
	ld a, [hli]
	ld [$C5FA], a
	ld a, [hli]
	ld [$C5E2], a
	ld a, [hli]
	ld [$C5E3], a
	ld a, [hli]
	ld [$C5E6], a
	ld a, [hli]
	ld [$C5E4], a
	ld a, [hli]
	ld [$C5E8], a
	ld a, h
	ld [$C5F7], a
	ld [$C5FB], a
	ld a, l
	ld [$C5F8], a
	ld [$C5FC], a
	call $4FFF
	ld a, [$C5CE]
	inc a
	ld [$C5CE], a
	xor a, a
	ld [$C5E5], a
	ld [$C5E7], a
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
