; PROBABLE resource-frame initialization selected by top-level A12 variant 2.
; Static code flow only; C5A4 bounds and physical source-window identities are open.
SECTION "A12 variant 2 resource init dispatch 44D2-44F1", ROMX[$44D2], BANK[$09]
ResidualROM09_44D2::
A12Variant2ResourceInitDispatch::
	ld a, $65
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, [$C5A4]
	ld hl, A12Variant2ResourceInitTargets
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12Variant2ResourceInitReturn
	push hl
	ld l, e
	ld h, d
	jp hl
A12Variant2ResourceInitReturn::
	ret
ASSERT @ == $44F2

SECTION "A12 variant 2 resource init targets 44F2-44FF", ROMX[$44F2], BANK[$09]
A12Variant2ResourceInitTargets::
	dw A12Variant2ResourceInitIndex0
	dw A12Variant2ResourceInitIndex1
	dw A12Variant2ResourceInitIndex2
	dw A12Variant2ResourceInitIndex3
	dw A12Variant2ResourceInitIndex4
	dw A12Variant2ResourceInitIndex5
	dw A12Variant2ResourceInitIndex6
ASSERT @ == $4500

SECTION "A12 variant 2 resource init index 0 4500", ROMX[$4500], BANK[$09]
A12Variant2ResourceInitIndex0::
	ret
ASSERT @ == $4501

SECTION "A12 variant 2 resource init index 1 4501-450D", ROMX[$4501], BANK[$09]
A12Variant2ResourceInitIndex1::
	ld hl, $6893
	call InitializeA12TileFrames
	ld hl, $68AE
	call InitializeA12TileFrames
	ret
ASSERT @ == $450E

SECTION "A12 variant 2 resource init index 2 450E-4517", ROMX[$450E], BANK[$09]
A12Variant2ResourceInitIndex2::
	call A12Variant2ResourceInitIndex1
	ld hl, $68C7
	call InitializeA12TileFrames
	ret
ASSERT @ == $4518

SECTION "A12 variant 2 resource init index 3 4518-4539", ROMX[$4518], BANK[$09]
A12Variant2ResourceInitIndex3::
	call A12Variant2ResourceInitIndex2
	ld hl, $6922
	call InitializeA12TileFrames
	ld hl, $694D
	call InitializeA12TileFrames
	ld hl, $695C
	call InitializeA12TileFrames
	ld hl, $6981
	call InitializeA12TileFrames
	ld hl, $69B0
	call InitializeA12TileFrames
	ret
ASSERT @ == $453A

SECTION "A12 variant 2 resource init index 4 453A-4543", ROMX[$453A], BANK[$09]
A12Variant2ResourceInitIndex4::
	call A12Variant2ResourceInitIndex3
	ld hl, $69C3
	call InitializeA12TileFrames
	ret
ASSERT @ == $4544

SECTION "A12 variant 2 resource init index 5 4544-454D", ROMX[$4544], BANK[$09]
A12Variant2ResourceInitIndex5::
	call A12Variant2ResourceInitIndex4
	ld hl, $6A6A
	call InitializeA12TileFrames
	ret
ASSERT @ == $454E

SECTION "A12 variant 2 resource init index 6 454E-455D", ROMX[$454E], BANK[$09]
A12Variant2ResourceInitIndex6::
	call A12Variant2ResourceInitIndex5
	ld hl, $6A99
	call InitializeA12TileFrames
	ld hl, $6ABF
	call InitializeA12TileFrames
	ret
ASSERT @ == $455E
