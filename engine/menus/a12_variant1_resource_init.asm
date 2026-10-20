; PROBABLE resource-frame initialization selected by top-level A12 variant 1.
; Static code flow only; C5A4 bounds and physical source-window identities are open.
SECTION "A12 variant 1 resource init dispatch 445E-447D", ROMX[$445E], BANK[$09]
ResidualROM09_445E::
A12Variant1ResourceInitDispatch::
	ld a, $63
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, [$C5A4]
	ld hl, A12Variant1ResourceInitTargets
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12Variant1ResourceInitReturn
	push hl
	ld l, e
	ld h, d
	jp hl
A12Variant1ResourceInitReturn::
	ret
ASSERT @ == $447E

SECTION "A12 variant 1 resource init targets 447E-448B", ROMX[$447E], BANK[$09]
A12Variant1ResourceInitTargets::
	dw A12Variant1ResourceInitIndex0
	dw A12Variant1ResourceInitIndex1
	dw A12Variant1ResourceInitIndex2
	dw A12Variant1ResourceInitIndex3
	dw A12Variant1ResourceInitIndex4
	dw A12Variant1ResourceInitIndex5
	dw A12Variant1ResourceInitIndex6
ASSERT @ == $448C

SECTION "A12 variant 1 resource init index 0 448C", ROMX[$448C], BANK[$09]
A12Variant1ResourceInitIndex0::
	ret
ASSERT @ == $448D

SECTION "A12 variant 1 resource init index 1 448D-4493", ROMX[$448D], BANK[$09]
A12Variant1ResourceInitIndex1::
	ld hl, $6902
	call InitializeA12TileFrames
	ret
ASSERT @ == $4494

SECTION "A12 variant 1 resource init index 2 4494-449D", ROMX[$4494], BANK[$09]
A12Variant1ResourceInitIndex2::
	call A12Variant1ResourceInitIndex1
	ld hl, $6927
	call InitializeA12TileFrames
	ret
ASSERT @ == $449E

SECTION "A12 variant 1 resource init index 3 449E-44AD", ROMX[$449E], BANK[$09]
A12Variant1ResourceInitIndex3::
	call A12Variant1ResourceInitIndex2
	ld hl, $6952
	call InitializeA12TileFrames
	ld hl, $6965
	call InitializeA12TileFrames
	ret
ASSERT @ == $44AE

SECTION "A12 variant 1 resource init index 4 44AE-44B7", ROMX[$44AE], BANK[$09]
A12Variant1ResourceInitIndex4::
	call A12Variant1ResourceInitIndex3
	ld hl, $69A8
	call InitializeA12TileFrames
	ret
ASSERT @ == $44B8

SECTION "A12 variant 1 resource init index 5 44B8-44C1", ROMX[$44B8], BANK[$09]
A12Variant1ResourceInitIndex5::
	call A12Variant1ResourceInitIndex4
	ld hl, $6A13
	call InitializeA12TileFrames
	ret
ASSERT @ == $44C2

SECTION "A12 variant 1 resource init index 6 44C2-44D1", ROMX[$44C2], BANK[$09]
A12Variant1ResourceInitIndex6::
	call A12Variant1ResourceInitIndex5
	ld hl, $6A70
	call InitializeA12TileFrames
	ld hl, $6A3E
	call InitializeA12TileFrames
	ret
ASSERT @ == $44D2
