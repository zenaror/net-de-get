; PROBABLE queued tile-text state machine; synthetic isolated paths only.
; Unknown rendering/input dependencies remain numeric; no natural display trace.
SECTION "Queued tile text 27AA-27C0", ROM0[$27AA]
QueueTileTextPointer::
	ld a, l
	ld [$C1AB], a
	ld a, h
	ld [$C1AC], a
	ld de, $0001
	ld hl, $C1B8
	ld [hl], e
	xor a, a
	ld [$C1B3], a
	ld [$C1B4], a
	ret
ASSERT @ == $27C1

SECTION "Queued tile text 27C1-27CA", ROM0[$27C1]
DispatchQueuedTileTextState::
	ld a, [$C1B8]
	ld hl, QueuedTileTextStatePointers
	push hl
	jp DispatchReturnTable
ASSERT @ == $27CB

SECTION "Queued tile text 27CB-27D4", ROM0[$27CB]
QueuedTileTextStatePointers::
	dw QueuedTileTextState0, QueuedTileTextState1, QueuedTileTextState2, QueuedTileTextState3, QueuedTileTextState4
ASSERT @ == $27D5

SECTION "Queued tile text 27D5-27D5", ROM0[$27D5]
QueuedTileTextState0::
	ret
ASSERT @ == $27D6

SECTION "Queued tile text 27D6-287A", ROM0[$27D6]
QueuedTileTextState1::
	ld a, [$C1BA]
	and a, a
	jr z, QueuedTileText_2801
	ldh a, [$FF96]
	and a, $01
	jr nz, QueuedTileText_2801
	ld a, [$C1BB]
	inc a
	ld [$C1BB], a
	ld a, [$C1BA]
	dec a
	jr nz, QueuedTileText_27F9
	ld a, [$C1BB]
	cp a, $04
	jp nz, QueuedTileText_281E
	jr QueuedTileText_2801
QueuedTileText_27F9::
	ld a, [$C1BB]
	cp a, $0A
	jp nz, QueuedTileText_281E
QueuedTileText_2801::
	xor a, a
	ld [$C1BB], a
	call $2E15
	ld a, [$C1BA]
	and a, a
	jr nz, QueuedTileText_281E
	ld a, [$C1B3]
	inc a
	ld [$C1B3], a
	cp a, $04
	jr nz, QueuedTileText_2878
	xor a, a
	ld [$C1B3], a
	ret
QueuedTileText_281E::
	ld a, $20
	ldh [$FF00], a
	ldh a, [$FF00]
	ldh a, [$FF00]
	cpl
	and a, $0F
	swap a
	ld b, a
	ld a, $10
	ldh [$FF00], a
	ldh a, [$FF00]
	ldh a, [$FF00]
	ldh a, [$FF00]
	ldh a, [$FF00]
	ldh a, [$FF00]
	ldh a, [$FF00]
	cpl
	and a, $0F
	or a, b
	ld c, a
	ld a, [$C110]
	xor a, c
	and a, c
	ld [$C111], a
	ld a, c
	ld [$C110], a
	ld a, $30
	ldh [$FF00], a
	ld a, [$C110]
	and a, $01
	jr nz, QueuedTileText_285D
	ld a, $01
	ld [$C1B4], a
QueuedTileText_285D::
	ldh a, [$FF97]
	and a, $FE
	ldh [$FF97], a
	ld a, [$C1B4]
	and a, a
	ret z
	ld a, [$C1B3]
	inc a
	ld [$C1B3], a
	cp a, $04
	jr nz, QueuedTileText_2878
	xor a, a
	ld [$C1B3], a
	ret
QueuedTileText_2878::
	jp DispatchQueuedTileTextState
ASSERT @ == $287B

SECTION "Queued tile text 287B-28A6", ROM0[$287B]
QueuedTileTextState2::
	ld a, [$C1AB]
	ld l, a
	ld a, [$C1AC]
	ld h, a
	ld a, [hl]
	and a, a
	jr nz, QueuedTileText_2892
	ld a, [$C1B9]
	and a, a
	jr nz, QueuedTileText_2892
	xor a, a
	ld [$C1B8], a
	ret
QueuedTileText_2892::
	call $2DD0
	ldh a, [$FF97]
	and a, $01
	ret z
	call $2D53
	ld a, $01
	ld [$C1B8], a
	xor a, a
	ld [$C1B4], a
	ret
ASSERT @ == $28A7

SECTION "Queued tile text 28A7-28AB", ROM0[$28A7]
QueuedTileTextState3::
	xor a, a
	ld [$C1B8], a
	ret
ASSERT @ == $28AC

SECTION "Queued tile text 28AC-28BD", ROM0[$28AC]
QueuedTileTextState4::
	call $2DD0
	ldh a, [$FF97]
	and a, $01
	ret z
	ld a, $01
	ld [$C1B8], a
	xor a, a
	ld [$C1B4], a
	ret
ASSERT @ == $28BE
