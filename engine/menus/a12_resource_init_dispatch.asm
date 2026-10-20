; PROBABLE A12 resource-initialization dispatch from InitializeA12Selection.
; Static flow only: selector bounds and natural execution are unproven.
SECTION "A12 resource init dispatcher 43C0-43D5", ROMX[$43C0], BANK[$09]
ResidualROM09_43C0::
InitializeA12ResourceVariantDispatcher::
	ld a, [$C5A8]
	ld hl, A12ResourceVariantInitTargets
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12ResourceVariantDispatchReturn
	push hl
	ld l, e
	ld h, d
	jp hl
A12ResourceVariantDispatchReturn::
	ret
ASSERT @ == $43D6

SECTION "A12 resource init dispatch targets 43D6-43DD", ROMX[$43D6], BANK[$09]
A12ResourceVariantInitTargets::
	dw A12Variant0ResourceInitDispatch, A12Variant1ResourceInitDispatch
	dw A12Variant2ResourceInitDispatch, A12Variant3ResourceInitDispatch
ASSERT @ == $43DE
