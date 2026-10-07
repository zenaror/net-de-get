; PROBABLE static SYS1 loader; existing record capacity is not checked here.
; Native A $14, physical RGBDS bank $0A lower half.
SECTION "Local menu storage load", ROMX[$45FF], BANK[$0A]
LoadLocalMenuStorage::
	ld bc, $02A3
	ld de, LocalMenuStorageName
	call OpenLocalStorageRecord
	ld de, $D064
	ld bc, $02A3
.copy:
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .copy
	call CloseLocalStorageRecord
	ret
.end:
ASSERT .end - LoadLocalMenuStorage == $1B
