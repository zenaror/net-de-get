; ROM0 $3E00-$3ED7. PROBABLE static reconstruction and descriptive names.
; HL is supplied by the caller; this file does not establish its allocation.
; Natural held-Select rebuild evidence: docs/research/minigame-maintenance.md.
; $38B0 remains an unresolved external call; do not infer every branch observed.
SECTION "Local minigame list rebuild", ROM0[$3E00]
RebuildLocalMinigameList::
	ld b, $08
	ld c, $00
.initializeBoxes:
	ld [hl], c
	inc hl
	inc c
	dec b
	jr nz, .initializeBoxes
	ld bc, $010A
.clear:
	xor a, a
	ld [hli], a
	dec bc
	ld a, b
	or a, c
	jr nz, .clear
	call CopyLocalListTemplate
	ld a, $0A
	ld [rMBC6RAMEnable], a
	ld bc, $000F
	xor a, a
.builtinPairs:
	ld [hl], b
	inc hl
	ld [hli], a
	inc b
	dec c
	jr nz, .builtinPairs
	xor a, a
	ld [wLocalScanSector], a
	ld e, a
	ld a, LOCAL_SCAN_RESERVED_SECTOR
	ld [wLocalScanReservedSector], a
	ld a, l
	ld [wLocalScanDestinationLow], a
	ld a, h
	ld [wLocalScanDestinationHigh], a
	call EnableFlashReads
.scan:
	di
	ld a, e
	ld [rMBC6WindowBSelector], a
	ldh [hWindowBSelector], a
	ld [wWindowBSelectorMirror], a
	ld a, MBC6_FLASH
	ld [rMBC6WindowBType], a
	ldh [hWindowBType], a
	ld [wWindowBTypeMirror], a
	ei
	ld a, [MINIGAME_VALID_MARKER]
	cp a, GAME_LIST_END
	jr nz, .nextBlock
	ld a, [MINIGAME_BLOCK_COUNT]
	cp a, MINIGAME_MAX_BLOCKS_PLUS_ONE
	jr nc, .nextBlock
	call $38B0
	jr nz, .nextBlock
	ld a, [wLocalScanDestinationLow]
	ld l, a
	ld a, [wLocalScanDestinationHigh]
	ld h, a
	ld a, e
	add a, FIRST_FLASH_GAME_INDEX
	ld [hli], a
	xor a, a
	ld [hli], a
	ld a, l
	ld [wLocalScanDestinationLow], a
	ld a, h
	ld [wLocalScanDestinationHigh], a
	ld a, [MINIGAME_BLOCK_COUNT]
	add a, e
	ld e, a
	jr .sectorBoundary
.nextBlock:
	inc e
.sectorBoundary:
	ld a, [wLocalScanSector]
	xor a, e
	and a, MBC6_FLASH_SECTOR_SELECTORS
	jp z, .scan
.nextSector:
	ld a, [wLocalScanSector]
	add a, MBC6_FLASH_SECTOR_SELECTORS
	ld [wLocalScanSector], a
	ld e, a
	ld a, [wLocalScanReservedSector]
	cp a, e
	jr z, .nextSector
	ld a, e
	cp a, MBC6_FLASH_SELECTOR_COUNT
	jr nz, .scan
	call DisableFlashReads
	ld a, [wLocalScanDestinationLow]
	ld l, a
	ld a, [wLocalScanDestinationHigh]
	ld h, a
	ld a, GAME_LIST_END
	ld [hl], a
	ret
CopyLocalListTemplate::
	di
	ld a, $15
	ldh [hWindowBSelector], a
	ld [rMBC6WindowBSelector], a
	ld [wWindowBSelectorMirror], a
	xor a, a
	ldh [hWindowBType], a
	ld [rMBC6WindowBType], a
	ld [wWindowBTypeMirror], a
	ei
	ld a, $0A
	ld [rMBC6RAMEnable], a
	ld de, $71D4
	ld b, $70
.copy:
	ld a, [de]
	inc de
	ld [hli], a
	dec b
	jr nz, .copy
	xor a, a
	ld [rMBC6RAMEnable], a
	ret
LocalMinigameListRebuildEnd:
ASSERT LocalMinigameListRebuildEnd - RebuildLocalMinigameList == $D8
