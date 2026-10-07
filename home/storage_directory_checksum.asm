; PROBABLE static reconstruction; no new natural trace.
SECTION "Local storage directory checksum", ROM0[$106D]
ComputeStorageDirectoryChecksum::
	ld hl, $A002
	ld de, $0000
	ld bc, $030C
.byte:
	ld a, [hli]
	add a, e
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	dec bc
	ld a, c
	or a, b
	jr nz, .byte
	ld hl, $A000
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld l, c
	ld h, b
	call CompareHLAndDE
	ret
ComputeStorageDirectoryChecksumEnd:
ASSERT ComputeStorageDirectoryChecksumEnd - ComputeStorageDirectoryChecksum == $21
