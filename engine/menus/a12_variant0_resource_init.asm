; PROBABLE resource-frame initialization selected by top-level A12 variant 0.
; Static code flow only; C5A4 bounds, natural use and physical source banks are open.
SECTION "A12 variant 0 resource init dispatch 43DE-43FD", ROMX[$43DE], BANK[$09]
ResidualROM09_43DE::
A12Variant0ResourceInitDispatch::
	ld a, $61
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, [$C5A4]
	ld hl, A12Variant0ResourceInitTargets
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12Variant0ResourceInitReturn
	push hl
	ld l, e
	ld h, d
	jp hl
A12Variant0ResourceInitReturn::
	ret
ASSERT @ == $43FE

SECTION "A12 variant 0 resource init targets 43FE-440B", ROMX[$43FE], BANK[$09]
A12Variant0ResourceInitTargets::
	dw A12Variant0ResourceInitIndex0
	dw A12Variant0ResourceInitIndex1
	dw A12Variant0ResourceInitIndex2
	dw A12Variant0ResourceInitIndex3
	dw A12Variant0ResourceInitIndex4
	dw A12Variant0ResourceInitIndex5
	dw A12Variant0ResourceInitIndex6
ASSERT @ == $440C

SECTION "A12 variant 0 resource init index 0 440C", ROMX[$440C], BANK[$09]
A12Variant0ResourceInitIndex0::
	ret
ASSERT @ == $440D

SECTION "A12 variant 0 resource init index 1 440D-441F", ROMX[$440D], BANK[$09]
A12Variant0ResourceInitIndex1::
	ld hl, $6970
	call InitializeA12TileFrames
	ld hl, $699B
	call InitializeA12TileFrames
	ld hl, $69EA
	call InitializeA12TileFrames
	ret
ASSERT @ == $4420

SECTION "A12 variant 0 resource init index 2 4420-4429", ROMX[$4420], BANK[$09]
A12Variant0ResourceInitIndex2::
	call A12Variant0ResourceInitIndex1
	ld hl, $6A52
	call InitializeA12TileFrames
	ret
ASSERT @ == $442A

SECTION "A12 variant 0 resource init index 3 442A-4439", ROMX[$442A], BANK[$09]
A12Variant0ResourceInitIndex3::
	call A12Variant0ResourceInitIndex2
	ld hl, $6AA9
	call InitializeA12TileFrames
	ld hl, $6B04
	call InitializeA12TileFrames
	ret
ASSERT @ == $443A

SECTION "A12 variant 0 resource init index 4 443A-4443", ROMX[$443A], BANK[$09]
A12Variant0ResourceInitIndex4::
	call A12Variant0ResourceInitIndex3
	ld hl, $6B13
	call InitializeA12TileFrames
	ret
ASSERT @ == $4444

SECTION "A12 variant 0 resource init index 5 4444-444D", ROMX[$4444], BANK[$09]
A12Variant0ResourceInitIndex5::
	call A12Variant0ResourceInitIndex4
	ld hl, $6B3A
	call InitializeA12TileFrames
	ret
ASSERT @ == $444E

SECTION "A12 variant 0 resource init index 6 444E-445D", ROMX[$444E], BANK[$09]
A12Variant0ResourceInitIndex6::
	call A12Variant0ResourceInitIndex5
	ld hl, $6B65
	call InitializeA12TileFrames
	ld hl, $6B8B
	call InitializeA12TileFrames
	ret
ASSERT @ == $445E
