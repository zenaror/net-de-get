; PROBABLE resource-frame reset/dispatch/tick; mapped reader is separate; movement has a separate source; natural integration remains unproven.
; Prefix tests stop at actual reader or movement entry; no natural timing claim.
SECTION "A12 resource control 4CFD-4D0A", ROMX[$4CFD], BANK[$09]
ResidualROM09_4CFD::
ResetA12ResourceFrame::
	xor a, a
	ld [$C5CC], a
	ld [$C5CE], a
	call SelectA12VariantResourceTable
	call LoadA12ResourceFrame
	ret
ASSERT @ == $4D0B

SECTION "A12 resource control 4D0B-4D25", ROMX[$4D0B], BANK[$09]
ResetA12ResourceAndTileFrames::
	xor a, a
	ld [$C5E5], a
	ld [$C5E7], a
	ld [$C5E6], a
	ld [$C5E4], a
	xor a, a
	ld [$C5CC], a
	ld [$C5CE], a
	call SelectA12VariantResourceTable
	call LoadA12ResourceFrame
	ret
ASSERT @ == $4D26

SECTION "A12 resource control 4D26-4D3B", ROMX[$4D26], BANK[$09]
SelectA12VariantResourceTable::
	ld a, [$C5A8]
	ld hl, A12VariantResourceTablePointers
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12ResourceDispatchReturn
	push hl
	ld l, e
	ld h, d
	jp hl
A12ResourceDispatchReturn::
	ret
ASSERT @ == $4D3C

SECTION "A12 resource control 4D3C-4D43", ROMX[$4D3C], BANK[$09]
A12VariantResourceTablePointers::
	dw SelectA12Variant0ResourceTable, SelectA12Variant1ResourceTable, SelectA12Variant2ResourceTable, SelectA12Variant3ResourceTable
ASSERT @ == $4D44

SECTION "A12 resource control 4D44-4D47", ROMX[$4D44], BANK[$09]
SelectA12Variant0ResourceTable::
	ld hl, A12Variant0PrimaryResourceTable
	ret
ASSERT @ == $4D48

SECTION "A12 resource control 4D48-4D4B", ROMX[$4D48], BANK[$09]
SelectA12Variant1ResourceTable::
	ld hl, $6AD0
	ret
ASSERT @ == $4D4C

SECTION "A12 resource control 4D4C-4D4F", ROMX[$4D4C], BANK[$09]
SelectA12Variant2ResourceTable::
	ld hl, $6AE5
	ret
ASSERT @ == $4D50

SECTION "A12 resource control 4D50-4D53", ROMX[$4D50], BANK[$09]
SelectA12Variant3ResourceTable::
	ld hl, $6A3D
	ret
ASSERT @ == $4D54

SECTION "A12 resource control 4D54-4D81", ROMX[$4D54], BANK[$09]
TickA12ResourceFrame::
	ld a, [$C5CB]
	ld b, a
	ld a, [$C5CC]
	sub a, b
	jp c, MoveA12ResourceCoordinates
	xor a, a
	ld [$C5CC], a
	ld a, [$C5CD]
	ld b, a
	ld a, [$C5CE]
	inc a
	cp a, b
	jr nz, A12ResourceNextFrame
	ld a, [$C5D1]
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ret
A12ResourceNextFrame::
	ld [$C5CE], a
	call SelectA12VariantResourceTable
	call LoadA12ResourceFrame
	ret
ASSERT @ == $4D82
