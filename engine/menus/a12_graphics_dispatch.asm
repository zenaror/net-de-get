; PROBABLE variant graphics dispatch from initialization consumer.
; Byte index doubles with wrap; table bounds are not checked by the original.
SECTION "A12 graphics dispatch 4251-4266", ROMX[$4251], BANK[$09]
ResidualROM09_4251::
DispatchA12VariantGraphics::
	ld a, [$C5A8]
	ld hl, A12VariantGraphicsTargets
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12GraphicsDispatchReturn
	push hl
	ld l, e
	ld h, d
	jp hl
A12GraphicsDispatchReturn::
	ret
ASSERT @ == $4267

SECTION "A12 graphics dispatch targets 4267-426E", ROMX[$4267], BANK[$09]
A12VariantGraphicsTargets::
	dw PrepareA12VariantGraphics0
	dw PrepareA12VariantGraphics1
	dw PrepareA12VariantGraphics2
	dw PrepareA12VariantGraphics3
ASSERT @ == $426F
