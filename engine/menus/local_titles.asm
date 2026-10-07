; Partial RGBDS disassembly, original Japanese title bytes remain untouched.
; PROBABLE: routine/field names from static decode. Natural observations
; CONFIRMED for specific stores are recorded in docs/research/minigame-maintenance.md.
; This file does not claim a natural trace of every branch.
; RGBDS physical bank $0A lower half = native MBC6 A selector $14 (20 decimal).
SECTION "Local minigame title list", ROMX[$4D43], BANK[$0A]

; Native A selector $14: CPU $4D43; file $28D43.
BuildLocalMinigameTitleList::
	ldh a, [hWindowBSelector]
	ld [wTitleListBankOrIndex], a
	ldh a, [hWindowBType]
	ld [wTitleListSavedType], a
	ld a, LOW(wGameTitleList)
	ld [wTitleListDestinationLow], a
	ld a, HIGH(wGameTitleList)
	ld [wTitleListDestinationHigh], a
	xor a, a
	ld [wGameTitleList], a
	ld [wGameTitleList + 1], a
	xor a, a
	ld [wTitleListCount], a
	ld a, GAME_LIST_END
	ld [wTitleListItemIndex], a
	ld hl, wGameIndexBoxPairs
.nextPair:
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld a, GAME_LIST_END
	cp a, c
	jr z, .finish
	ld a, [wCurrentGameBox]
	cp a, b
	jr nz, .continue
	ld a, [wTitleListItemIndex]
	inc a
	ld [wTitleListItemIndex], a

; The following store replaces the saved selector with the raw game Index.
	ld a, c
	ld [wTitleListBankOrIndex], a
	cp a, FIRST_FLASH_GAME_INDEX
	jr nc, .flashGame

; Form ROM0 $3CD8 + Index without changing the carry propagation.
	add a, LOW(BuiltinGameWindowBSelectors)
	ld e, a
	ld a, HIGH(BuiltinGameWindowBSelectors)
	adc a, $00
	ld d, a
	di
	ld a, [de]
	ldh [hWindowBSelector], a
	ld [rMBC6WindowBSelector], a
	ld [wWindowBSelectorMirror], a
	xor a, a
	ldh [hWindowBType], a
	ld [rMBC6WindowBType], a
	ld [wWindowBTypeMirror], a
	ei
	push hl
	call AppendLocalMinigameTitle
	pop hl
	jr .continue
.flashGame:
	sub a, FIRST_FLASH_GAME_INDEX
	di
	ld [rMBC6WindowBSelector], a
	ldh [hWindowBSelector], a
	ld [wWindowBSelectorMirror], a
	ld a, MBC6_FLASH
	ld [rMBC6WindowBType], a
	ldh [hWindowBType], a
	ld [wWindowBTypeMirror], a
	ei
	push hl
	call EnableFlashReads
	pop hl
	ld a, [MINIGAME_VALID_MARKER]
	cp a, GAME_LIST_END
	jr nz, .disableFlash
	ld a, [MINIGAME_BLOCK_COUNT]
	cp a, MINIGAME_MAX_BLOCKS_PLUS_ONE
	jr nc, .disableFlash
	push hl
	call AppendLocalMinigameTitle
	pop hl
.disableFlash:
	call DisableFlashReads
.continue:
	jp .nextPair
.finish:
	ld a, [wTitleListDestinationLow]
	ld l, a
	ld a, [wTitleListDestinationHigh]
	ld h, a
	xor a, a
	ld [hl], a
	di

; Preserve the original restore behavior: this may now be an Index.
	ld a, [wTitleListBankOrIndex]
	ldh [hWindowBSelector], a
	ld [rMBC6WindowBSelector], a
	ld [wWindowBSelectorMirror], a
	ld a, [wTitleListSavedType]
	ldh [hWindowBType], a
	ld [rMBC6WindowBType], a
	ld [wWindowBTypeMirror], a
	ei
	ret

; Copies at most $18 source bytes; adds a NUL if that limit is reached.
AppendLocalMinigameTitle:
	ld hl, MINIGAME_TITLE
	ld a, [wTitleListDestinationLow]
	ld e, a
	ld a, [wTitleListDestinationHigh]
	ld d, a
	ld b, MINIGAME_TITLE_COPY_LIMIT
.copy:
	ld a, [hli]
	ld [de], a
	inc de
	and a, a
	jr z, .saveDestination
	dec b
	jr nz, .copy
	xor a, a
	ld [de], a
	inc de
.saveDestination:
	ld a, e
	ld [wTitleListDestinationLow], a
	ld a, d
	ld [wTitleListDestinationHigh], a
	ld hl, wTitleListCount
	inc [hl]
	ret
BuildLocalMinigameTitleListEnd:
ASSERT BuildLocalMinigameTitleListEnd - BuildLocalMinigameTitleList == $E5
