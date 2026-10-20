; PROBABLE resource-frame initialization selected by top-level A12 variant 3.
; Static code flow only; C706 bounds and physical source-window identities are open.
SECTION "A12 variant 3 resource init dispatch 455E-4583", ROMX[$455E], BANK[$09]
ResidualROM09_455E::
A12Variant3ResourceInitDispatch::
	ld a, $66
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld hl, $6941
	call InitializeA12TileFrames
	ld a, [$C706]
	ld hl, A12Variant3ResourceInitTargets
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12Variant3ResourceInitReturn
	push hl
	ld l, e
	ld h, d
	jp hl
A12Variant3ResourceInitReturn::
	ret
ASSERT @ == $4584

SECTION "A12 variant 3 resource init targets 4584-4589", ROMX[$4584], BANK[$09]
A12Variant3ResourceInitTargets::
	dw A12Variant3ResourceInitIndex0
	dw A12Variant3ResourceInitIndex1
	dw A12Variant3ResourceInitIndex2
ASSERT @ == $458A

SECTION "A12 variant 3 resource init index 0 458A-4590", ROMX[$458A], BANK[$09]
A12Variant3ResourceInitIndex0::
	ld hl, $6968
	call InitializeA12TileFrames
	ret
ASSERT @ == $4591

SECTION "A12 variant 3 resource init index 1 4591-4597", ROMX[$4591], BANK[$09]
A12Variant3ResourceInitIndex1::
	ld hl, $69AF
	call InitializeA12TileFrames
	ret
ASSERT @ == $4598

SECTION "A12 variant 3 resource init index 2 4598-459E", ROMX[$4598], BANK[$09]
A12Variant3ResourceInitIndex2::
	ld hl, $69F6
	call InitializeA12TileFrames
	ret
ASSERT @ == $459F
