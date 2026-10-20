; PROBABLE: four complete targets of A12VariantGraphicsTargets.
; Static evidence: each block is selected by C5A8 and returns to the
; dispatcher. Resource payloads and natural menu use are not identified here.
SECTION "A12 graphics variant 0 426F-42CD", ROMX[$426F], BANK[$09]
ResidualROM09_426F::
PrepareA12VariantGraphics0::
	ld a, $60
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, $00
	ldh [$FF4F], a
	ld hl, $6000
	call LoadA12GraphicsResourceToVRAM
	ld a, $60
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, $01
	ldh [$FF4F], a
	ld hl, $7481
	call LoadA12GraphicsResourceToVRAM
	ld a, $61
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld hl, $6000
	call CopyA12ResourceToVRAMMap
	ld a, $61
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, $28
	ld [$C1C7], a
	ld a, [$C738]
	ld [$C5CF], a
	call $4CFD
	call $4D0B
	call $50D8
	ld a, $04
	ld hl, $53B2
	call $0177
	ret
ASSERT @ == $42CE

SECTION "A12 graphics variant 1 42CE-4329", ROMX[$42CE], BANK[$09]
PrepareA12VariantGraphics1::
	ld a, $62
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, $00
	ldh [$FF4F], a
	ld hl, $6000
	call LoadA12GraphicsResourceToVRAM
	ld a, $67
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, $01
	ldh [$FF4F], a
	ld hl, $6000
	call LoadA12GraphicsResourceToVRAM
	ld a, $63
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld hl, $6000
	call CopyA12ResourceToVRAMMap
	ld a, $63
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, $28
	ld [$C1C7], a
	ld a, [$C738]
	ld [$C5CF], a
	call $4CFD
	call $4D0B
	ld a, $04
	ld hl, $5432
	call $0177
	ret
ASSERT @ == $432A

SECTION "A12 graphics variant 2 432A-4385", ROMX[$432A], BANK[$09]
PrepareA12VariantGraphics2::
	ld a, $64
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, $00
	ldh [$FF4F], a
	ld hl, $6000
	call LoadA12GraphicsResourceToVRAM
	ld a, $64
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, $01
	ldh [$FF4F], a
	ld hl, $7515
	call LoadA12GraphicsResourceToVRAM
	ld a, $65
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld hl, $6000
	call CopyA12ResourceToVRAMMap
	ld a, $65
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, $28
	ld [$C1C7], a
	ld a, [$C738]
	ld [$C5CF], a
	call $4CFD
	call $4D0B
	ld a, $04
	ld hl, $54B2
	call $0177
	ret
ASSERT @ == $4386

SECTION "A12 graphics variant 3 4386-43BF", ROMX[$4386], BANK[$09]
PrepareA12VariantGraphics3::
	call $0195
	ld a, $66
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, $00
	ldh [$FF4F], a
	ld hl, $6000
	call LoadA12GraphicsResourceToVRAM
	ld a, $66
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	ld a, $28
	ld [$C1C7], a
	ld a, $00
	ld [$C5CF], a
	call $4CFD
	call $4D0B
	ld a, $04
	ld hl, $5532
	call $0177
	ret
ASSERT @ == $43C0
