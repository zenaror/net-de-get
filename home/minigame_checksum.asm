; ROM0 $38B0-$391B. PROBABLE checksum interpretation from static arithmetic.
; Stored $B33B takes the early return path. Other cases sum bytes into BC,
; starting with the negative sum of the two stored checksum bytes.
; D is RLCA(SWAP(block count)), not a widened block count times 32.
; Zero D wraps the decrement loop. Do not infer support for all block counts.
; No new natural execution or hardware evidence is asserted.
SECTION "Local minigame checksum", ROM0[$38B0]
CheckLocalMinigameChecksum::
	ld a, [MINIGAME_CHECKSUM_LOW]
	cp a, $3B
	jr nz, .sum
	ld a, [MINIGAME_CHECKSUM_HIGH]
	cp a, $B3
	jr z, .done
.sum:
	ldh a, [hWindowBSelector]
	ld d, a
	push de
	ld a, [MINIGAME_BLOCK_COUNT]
	swap a
	rlca
	ld d, a
	ld e, $00
	ld hl, $6000
	ld b, $00
	ld a, [MINIGAME_CHECKSUM_LOW]
	ld c, a
	ld a, [MINIGAME_CHECKSUM_HIGH]
	add a, c
	ld c, a
	ld a, b
	adc a, $00
	xor a, $FF
	ld b, a
	ld a, c
	xor a, $FF
	ld c, a
	inc bc
.byte:
	ld a, [hli]
	add a, c
	ld c, a
	jr nc, .nextByte
	inc b
.nextByte:
	dec e
	jr nz, .byte
	ld a, h
	cp a, $80
	jr nz, .nextPage
	ld hl, $6000
	ldh a, [hWindowBSelector]
	inc a
	di
	ldh [hWindowBSelector], a
	ld [wWindowBSelectorMirror], a
	ld [rMBC6WindowBSelector], a
	ei
.nextPage:
	dec d
	jr nz, .byte
	pop de
	ld a, d
	di
	ldh [hWindowBSelector], a
	ld [wWindowBSelectorMirror], a
	ld [rMBC6WindowBSelector], a
	ei
	ld a, [MINIGAME_CHECKSUM_LOW]
	cp a, c
	jr nz, .done
	ld a, [MINIGAME_CHECKSUM_HIGH]
	cp a, b
.done:
	ret
LocalMinigameChecksumEnd:
ASSERT LocalMinigameChecksumEnd - CheckLocalMinigameChecksum == $6C
