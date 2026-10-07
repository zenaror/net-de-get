; PROBABLE static directory reconstruction from consecutive record headers.
; C=1 on a checksum mismatch; C=0 on the decoded termination paths.
; A is the HRAM count on return. No universal bounds or natural trace claimed.
SECTION "Local storage recovery and window clear", ROM0[$108E]
RebuildLocalStorageDirectory::
	ld bc, $030E
	ld hl, $A000
.clearDirectory:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, .clearDirectory
	ld hl, $A30E
	ld a, $00
	ldh [$FF9D], a
	ld a, $00
	ldh [$FF9E], a
.record:
	push hl
	push hl
	inc hl
	inc hl
	push hl
	ld b, $04
	ld a, l
	add a, b
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld hl, $0007
	add hl, bc
	ld c, l
	ld b, h
	pop hl
	ld de, $0000
.checksumByte:
	ld a, [hli]
	add a, e
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	dec bc
	ld a, c
	or a, b
	jr nz, .checksumByte
	pop hl
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld l, c
	ld h, b
	call CompareHLAndDE
	ld c, $01
	jr nz, .discardHeader
	ld c, $00
	ld a, l
	or a, h
	jr z, .discardHeader
	ldh a, [$FF9D]
	call GetStorageDirectoryEntry
	pop hl
	push hl
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	inc hl
	inc hl
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	call ComputeStorageDirectoryChecksum
	ld hl, $A000
	ld [hl], e
	inc hl
	ld [hl], d
	ldh a, [$FF9D]
	inc a
	ldh [$FF9D], a
	pop hl
	push hl
	push hl
	ld b, $08
	ld a, l
	add a, b
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	or a, a
	jr nz, .continue
	pop hl
	pop hl
	ld c, $00
	jr .done
.continue:
	pop hl
	ld b, $06
	ld a, l
	add a, b
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld c, [hl]
	inc hl
	ld b, [hl]
	pop hl
	ld e, $09
	ld a, l
	add a, e
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	add hl, bc
	jp .record
.discardHeader:
	pop hl
.done:
	ldh a, [$FF9D]
	ret
ClearLocalSRAMWindow::
	ld [$0400], a
	ld bc, $1000
	ld hl, $A000
.clear:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, .clear
	ret
RebuildLocalStorageDirectoryEnd:
ASSERT RebuildLocalStorageDirectoryEnd - RebuildLocalStorageDirectory == $C1
