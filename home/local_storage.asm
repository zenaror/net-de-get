; PROBABLE static interpretation: local record lookup, creation and pointers.
; These routines have not received a new natural instruction trace.
; Keep error-path POP, flag results, fall-throughs and register stores unchanged.
; Directory-checksum and word-comparison callees are extracted separately.

SECTION "Local storage entry thunks", ROM0[$01B6]
OpenLocalStorageRecord::
	jp OpenLocalStorageRecordImpl
CloseLocalStorageRecord::
	jp CloseLocalStorageRecordImpl
OpenLocalStorageRecordEnd:
ASSERT OpenLocalStorageRecordEnd - OpenLocalStorageRecord == $6

SECTION "Local storage open and close", ROM0[$0CA5]
OpenLocalStorageRecordImpl::
	ld hl, hStorageRecordNameLow
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
	ld [hl], c
	inc hl
	ld [hl], b
	xor a, a
	ld [$0400], a
	ld a, $01
	ld [$0800], a
	ld a, $0A
	ld [rMBC6RAMEnable], a
	call FindStorageRecord
	cp a, $00
	jp z, OpenLocalStorageRecordImpl.create
	cp a, $01
	jp z, OpenLocalStorageRecordImpl.existing
	cp a, $02
	jp z, OpenLocalStorageRecordImpl.directoryFull
	ld hl, rMBC6RAMEnable
	ld a, $FF
	ld c, $00
	ld b, $03
	call SetStorageRecordResult
	ret
.existing:
	ld a, b
	call CompareStorageRecordName
	cp a, $01
	jp z, OpenLocalStorageRecordImpl.discardReturn
	ld l, e
	ld h, d
	ld de, $0009
	add hl, de
	ldh a, [hStorageRecordSlot]
	ld c, $00
	ld b, $00
	call SetStorageRecordResult
	ret
.create:
	ld a, b
	call CreateStorageRecord
	cp a, $01
	jp z, OpenLocalStorageRecordImpl.createFailed
	ldh a, [hStorageRecordSlot]
	ld c, $01
	ld b, $00
	call SetStorageRecordResult
	ret
.directoryFull:
	ld hl, rMBC6RAMEnable
	ld a, $FF
	ld c, $00
	ld b, $01
	call SetStorageRecordResult
	ret
.discardReturn:
	pop hl
	ld hl, rMBC6RAMEnable
	ld a, $FF
	ld c, $00
	ld b, $02
	call SetStorageRecordResult
	ret
.createFailed:
	ld hl, rMBC6RAMEnable
	ld a, $FF
	ld c, $00
	ld b, $02
	call SetStorageRecordResult
	ret
CloseLocalStorageRecordImpl::
	ld a, [wStorageRecordSlot]
	call ComputeStorageRecordChecksum
	ld a, [wStorageRecordSlot]
	call GetStorageRecordHeader
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	xor a, a
	ld [rMBC6RAMEnable], a
	ldh a, [hSavedRegister0400]
	ld [$0400], a
	ldh a, [hSavedRegister0800]
	ld [$0800], a
	ret
OpenLocalStorageRecordImplEnd:
ASSERT OpenLocalStorageRecordImplEnd - OpenLocalStorageRecordImpl == $AB

SECTION "Local storage checksum and search", ROM0[$0F15]
ComputeStorageRecordChecksum::
	call GetStorageRecordHeader
	push de
	ld hl, $0006
	add hl, de
	ld a, [hl]
	ld c, a
	inc hl
	ld a, [hl]
	ld b, a
	ld hl, $0007
	add hl, bc
	push hl
	pop bc
	pop de
	inc de
	inc de
	ld hl, rMBC6RAMEnable
.byte:
	ld a, [de]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	inc de
	dec bc
	ld a, c
	or a, b
	jr nz, ComputeStorageRecordChecksum.byte
	ld c, l
	ld b, h
	ret
FindStorageRecord::
	ld b, $00
.entry:
	ld a, b
	call GetStorageDirectoryEntry
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	ld a, l
	or a, h
	jr z, FindStorageRecord.freeEntry
	ld a, b
	ldh [hStorageRecordSlot], a
	ldh a, [hStorageRecordNameLow]
	ld l, a
	ldh a, [hStorageRecordNameHigh]
	ld h, a
	ld b, $04
	ld c, $00
.compareByte:
	ld a, [de]
	inc de
	cp a, [hl]
	jp z, FindStorageRecord.nextNameByte
	inc c
.nextNameByte:
	inc hl
	dec b
	jr nz, FindStorageRecord.compareByte
	ld a, c
	or a, a
	jr z, FindStorageRecord.matched
	ldh a, [hStorageRecordSlot]
	ld b, a
	inc b
	ld a, b
	cp a, $82
	jp c, FindStorageRecord.entry
	ld b, $00
	ld a, $02
	ret
.freeEntry:
	xor a, a
	ret
.matched:
	ldh a, [hStorageRecordSlot]
	ld b, a
	ld a, $01
	ret
ComputeStorageRecordChecksumEnd:
ASSERT ComputeStorageRecordChecksumEnd - ComputeStorageRecordChecksum == $6C

SECTION "Local storage comparison and creation", ROM0[$0F81]
CompareStorageRecordName::
	call GetStorageRecordHeader
	push de
	inc de
	inc de
	ld a, b
	ldh [hStorageRecordSlot], a
	ldh a, [hStorageRecordNameLow]
	ld l, a
	ldh a, [hStorageRecordNameHigh]
	ld h, a
	ld b, $04
	ld c, $00
.compareByte:
	ld a, [de]
	inc de
	cp a, [hl]
	jp z, CompareStorageRecordName.nextNameByte
	inc c
.nextNameByte:
	inc hl
	dec b
	jr nz, CompareStorageRecordName.compareByte
	pop de
	ld a, c
	or a, a
	jr nz, CompareStorageRecordName.mismatch
	xor a, a
	ret
.mismatch:
	ld a, $01
	ld de, rMBC6RAMEnable
	ret
CreateStorageRecord::
	ldh [hStorageRecordSlot], a
	ld b, a
	or a, a
	jr z, CreateStorageRecord.firstRecord
	dec b
	ld a, b
	call GetStorageRecordHeader
	push de
	ld hl, $0006
	add hl, de
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld l, c
	ld h, b
	add hl, de
	ld de, $0009
	add hl, de
	push hl
	ldh a, [hStorageRecordSizeLow]
	ld c, a
	ldh a, [hStorageRecordSizeHigh]
	ld b, a
	add hl, bc
	jr c, CreateStorageRecord.noSpace
	dec hl
	push hl
	ld hl, $C000
	pop de
	call CompareHLAndDE
	jr c, CreateStorageRecord.noSpace
	pop hl
	pop de
	push hl
	ld hl, $0008
	add hl, de
	ld a, $01
	ld [hl], a
	push de
	ldh a, [hStorageRecordSlot]
	dec a
	call ComputeStorageRecordChecksum
	pop de
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	pop hl
	jr CreateStorageRecord.directory
.noSpace:
	ld a, $01
	pop hl
	pop hl
	ld de, rMBC6RAMEnable
	ret
.firstRecord:
	ld hl, $A30E
.directory:
	ldh a, [hStorageRecordSlot]
	call GetStorageDirectoryEntry
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	ldh a, [hStorageRecordNameLow]
	ld l, a
	ldh a, [hStorageRecordNameHigh]
	ld h, a
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
	ldh a, [hStorageRecordSlot]
	call GetStorageRecordHeader
	push de
	inc de
	inc de
	ldh a, [hStorageRecordNameLow]
	ld l, a
	ldh a, [hStorageRecordNameHigh]
	ld h, a
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
	ldh a, [hStorageRecordSizeLow]
	ld l, a
	ldh a, [hStorageRecordSizeHigh]
	ld h, a
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	ld a, $00
	ld [de], a
	inc de
	push hl
	pop bc
	push de
	pop hl
.clearData:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, CreateStorageRecord.clearData
	ldh a, [hStorageRecordSlot]
	call ComputeStorageRecordChecksum
	pop de
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	inc de
	ld hl, $0007
	add hl, de
	xor a, a
	ret
CompareStorageRecordNameEnd:
ASSERT CompareStorageRecordNameEnd - CompareStorageRecordName == $EC

SECTION "Local storage directory helpers", ROM0[$114F]
GetStorageDirectoryEntry::
	push hl
	ld l, a
	ld h, $00
	add hl, hl
	push hl
	pop de
	add hl, hl
	add hl, de
	push hl
	pop de
	ld hl, $A002
	add hl, de
	ld e, l
	ld d, h
	pop hl
	ret
GetStorageRecordHeader::
	push hl
	ld l, a
	ld h, $00
	add hl, hl
	push hl
	pop de
	add hl, hl
	add hl, de
	push hl
	pop de
	ld hl, $A002
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	ret
SetStorageRecordResult::
	push de
	ld [wStorageRecordSlot], a
	push af
	ld de, wStorageRecordDataLow
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	pop af
	pop de
	ret
GetStorageDirectoryEntryEnd:
ASSERT GetStorageDirectoryEntryEnd - GetStorageDirectoryEntry == $37
