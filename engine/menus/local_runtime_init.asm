; PROBABLE static initialization; dependent callees are not yet reconstructed.
; Native A $14; physical RGBDS bank $0A lower half.
SECTION "Local menu runtime init", ROMX[$5BC6], BANK[$0A]
InitializeLocalMenuRuntime::
	call $45FF
	ld a, [$C671]
	ld [$D004], a
	call $481B
	ld a, $01
	ld [$C5A3], a
	xor a
	ld [wLocalMenuState], a
	ld [$D021], a
	ld [$D309], a
	di
	ld de, ProcessLocalMenuTransfers
	call StoreRuntimeCallback0
	ei
	ret
.end:
ASSERT .end - InitializeLocalMenuRuntime == $24
