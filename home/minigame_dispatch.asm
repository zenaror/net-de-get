; ROM0 $254E-$25CA: PROBABLE static dispatcher interpretation.
; Called through ROM0 $026D; natural observations are documented in mbc6-host.md.
; Save only selector A, restore type ROM, and preserve DI/EI ordering.
; Calls $4000 in the newly mapped window; no external-game body is extracted.
SECTION "Local minigame dispatcher", ROM0[$254E]
DispatchLocalMinigame::
	ld b, a
	cp a, FIRST_FLASH_GAME_INDEX
	ldh a, [hWindowASelector]
	ld [wMinigameSavedWindowASelector], a
	jr nc, .flashGame
	ld hl, BuiltinGameWindowBSelectors
	ld a, b
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	di
	ld [rMBC6WindowASelector], a
	ldh [hWindowASelector], a
	ld [wWindowASelectorMirror], a
	xor a, a
	ld [rMBC6WindowAType], a
	ldh [hWindowAType], a
	ld [wWindowATypeMirror], a
	ei
	call $4000
	di
	ld a, [wMinigameSavedWindowASelector]
	ld [rMBC6WindowASelector], a
	ldh [hWindowASelector], a
	ld [wWindowASelectorMirror], a
	xor a, a
	ld [rMBC6WindowAType], a
	ldh [hWindowAType], a
	ld [wWindowATypeMirror], a
	ei
	jr .done
.flashGame:
	call EnableFlashReads
	ld a, b
	sub a, FIRST_FLASH_GAME_INDEX
	di
	ld [rMBC6WindowASelector], a
	ldh [hWindowASelector], a
	ld [wWindowASelectorMirror], a
	ld [wMinigameFlashSelector], a
	ld a, MBC6_FLASH
	ld [rMBC6WindowAType], a
	ldh [hWindowAType], a
	ld [wWindowATypeMirror], a
	ei
	call $4000
	di
	ld a, [wMinigameSavedWindowASelector]
	ld [rMBC6WindowASelector], a
	ldh [hWindowASelector], a
	ld [wWindowASelectorMirror], a
	xor a, a
	ld [rMBC6WindowAType], a
	ldh [hWindowAType], a
	ld [wWindowATypeMirror], a
	ei
	call DisableFlashReads
.done:
	ret
DispatchLocalMinigameEnd:
ASSERT DispatchLocalMinigameEnd - DispatchLocalMinigame == $7D
