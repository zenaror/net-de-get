; PROBABLE A12 selection variants and callbacks; synthetic bounded contracts.
; Actual variant callees remain numerical/static beyond the tested prefixes.
; No natural IRQ/menu, Japanese interpretation or physical-device proof.

SECTION "A12 variant dispatcher 4157-416C", ROMX[$4157], BANK[$09]
ResidualROM09_4157::
DispatchA12SelectionVariant::
	ld a, [$C5A8]
	ld hl, A12SelectionVariantTargets
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12SelectionVariantReturn
	push hl
	ld l, e
	ld h, d
	jp hl
A12SelectionVariantReturn::
	ret
ASSERT @ == $416D

SECTION "A12 selection variant0 4175-41A1", ROMX[$4175], BANK[$09]
A12SelectionVariant0::
	ld a, $61
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	call TickA12TileFrame
	ld hl, $C5E5
	inc [hl]
	ld a, [$C73A]
	and a, a
	jr z, A12Handler_418F
	inc [hl]
	inc [hl]
	inc [hl]
A12Handler_418F::
	call UpdateA12TextModeController
	call UpdateA12PhaseInputGate
	call UpdateA12InputMode
	call ResidentJump0261
	call TickA12Variant0ResourceWrapper
	call DispatchA12ResourceCommand
	ret
ASSERT @ == $41A2

SECTION "A12 selection variant1 41A2-41D1", ROMX[$41A2], BANK[$09]
A12SelectionVariant1::
	ld a, $63
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	call TickA12TileFrame
	call TryA12Variant1TileFrames
	ld hl, $C5E5
	inc [hl]
	ld a, [$C73A]
	and a, a
	jr z, A12Handler_41BF
	inc [hl]
	inc [hl]
	inc [hl]
A12Handler_41BF::
	call UpdateA12TextModeController
	call UpdateA12PhaseInputGate
	call UpdateA12InputMode
	call ResidentJump0261
	call TickA12Variant1ResourceWrapper
	call DispatchA12ResourceCommand
	ret
ASSERT @ == $41D2

SECTION "A12 selection variant2 41D2-4201", ROMX[$41D2], BANK[$09]
A12SelectionVariant2::
	ld a, $65
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	call TickA12TileFrame
	call CycleA12Variant2TilePairs
	ld hl, $C5E5
	inc [hl]
	ld a, [$C73A]
	and a, a
	jr z, A12Handler_41EF
	inc [hl]
	inc [hl]
	inc [hl]
A12Handler_41EF::
	call UpdateA12TextModeController
	call UpdateA12PhaseInputGate
	call UpdateA12InputMode
	call ResidentJump0261
	call TickA12Variant2ResourceWrapper
	call DispatchA12ResourceCommand
	ret
ASSERT @ == $4202

SECTION "A12 selection variant3 4202-421C", ROMX[$4202], BANK[$09]
A12SelectionVariant3::
	ld a, $66
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	call TickA12TileFrame
	ld hl, $C5E5
	inc [hl]
	call ResidentJump0261
	call TickA12Variant3ResourceWrapper
	call DispatchA12ResourceCommand
	ret
ASSERT @ == $421D

SECTION "A12 idle exit 421D-422E", ROMX[$421D], BANK[$09]
FinishA12SelectionWhenIdle::
	ld a, [$C220]
	ld c, a
	ld a, [$CF86]
	or a, c
	or a, a
	jr z, A12Handler_4229
	ret
A12Handler_4229::
	ld a, $00
	ld [$C5A3], a
	ret
ASSERT @ == $422F

SECTION "A12 interrupt return 422F-422F", ROMX[$422F], BANK[$09]
A12SelectionInterruptReturnOnly::
	ret
ASSERT @ == $4230

SECTION "A12 window position 4230-4238", ROMX[$4230], BANK[$09]
PositionA12SelectionWindow::
	ld a, $A7
	ldh [$FF4B], a
	ld a, $00
	ldh [$FF4A], a
	ret
ASSERT @ == $4239

SECTION "A12 DMA palette callback 4239-4250", ROMX[$4239], BANK[$09]
UpdateA12SelectionDMAAndPalettes::
	ld a, [$C5A9]
	and a, a
	call nz, $FF80
	xor a, a
	ldh [$FF43], a
	ldh [$FF42], a
	ld a, $07
	ldh [$FF4B], a
	ld a, $00
	ldh [$FF4A], a
	call UploadPendingCGBPalettes
	ret
ASSERT @ == $4251

SECTION "A12 variant targets 416D-4174", ROMX[$416D], BANK[$09]
A12SelectionVariantTargets::
	dw A12SelectionVariant0, A12SelectionVariant1, A12SelectionVariant2, A12SelectionVariant3
ASSERT @ == $4175
