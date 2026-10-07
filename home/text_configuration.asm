; PROBABLE original resident helper contracts; bounded synthetic CPU probes.
SECTION "Resident helpers 269C-2752", ROM0[$269C]
InitializeQueuedTextPlane::
	ld [$C1AF], a
	xor a, a
	ld [$C1C2], a
	ld [$C1C0], a
	ld [$C1C1], a
	ld [$C219], a
	ld [$C21A], a
	ld hl, $C1B5
	ld a, $00
	ld [hli], a
	ld a, $98
	ld [hl], a
	ldh a, [$FF4F]
	and a, $01
	push af
	ld a, [$C1AF]
	ldh [$FF4F], a
	ld a, [$C1AF]
	or a, a
	ld a, $07
	jr z, TextSetup_26CD
	ld c, $08
	or a, c
TextSetup_26CD::
	ld [$C1A3], a
	ld a, [$C1AF]
	or a, a
	ld a, $00
	jr z, TextSetup_26DB
	ld c, $08
	or a, c
TextSetup_26DB::
	ld [$C1B0], a
	ld a, [$C1AF]
	or a, a
	ld a, $01
	jr z, TextSetup_26E9
	ld c, $08
	or a, c
TextSetup_26E9::
	ld [$C1B1], a
	ld a, [$C1AF]
	or a, a
	ld a, $02
	jr z, TextSetup_26F7
	ld c, $08
	or a, c
TextSetup_26F7::
	ld [$C1B2], a
	ld a, [$C1AF]
	or a, a
	ld a, $00
	jr z, TextSetup_2705
	ld c, $08
	or a, c
TextSetup_2705::
	ld [$C1B7], a
	ld hl, $4EE0
	ld de, $97E0
	ld bc, $0020
	call CopyVRAMBytes
	xor a, a
	ld [$C1BF], a
	pop af
	ldh [$FF4F], a
	ret
SetQueuedTextControlCallback::
	ld hl, $C1C0
	ld [hl], e
	inc hl
	ld [hl], d
	ret
StoreQueuedTextWordC219::
	ld hl, $C219
	ld [hl], e
	inc hl
	ld [hl], d
	ret
StoreQueuedTextPointer::
	ld hl, $C1AB
	ld [hl], e
	inc hl
	ld [hl], d
	ret
LoadQueuedTextFontTiles::
	ldh a, [$FF4F]
	and a, $01
	push af
	ld a, [$C1AF]
	ldh [$FF4F], a
	ld de, $96C0
	ld bc, $0120
	call CopyBankedVRAMBytesBody
	ldh a, [$FF9D]
	ld de, $8760
	ld bc, $00A0
	call CopyBankedVRAMBytesBody
	pop af
	ldh [$FF4F], a
	ret
ASSERT @ == $2753
