; PROBABLE original callbacks/fade/frame wait; synthetic bounded execution.
; Host-injected frame flags/wakes do not establish natural IRQ or audio progress.
SECTION "A0F fade callbacks and wait 67AA-67DF", ROMX[$67AA], BANK[$07]
ResidualROM07_67AA::
FadeAndWaitA0FPalette::
	ld a, $00
	ld [$C1B8], a
	ld a, [$C773]
	ld l, a
	ld a, [$C774]
	ld h, a
	ld a, $04
	call StartColorAddTransition
A0FWait_47BC::
	call StepColorTransition
	call WaitA0FFrameFlag - $2000
	ld a, [$C220]
	ld c, a
	ld a, [$CF86]
	or a, c
	jr nz, A0FWait_47BC
	ret
A0FNoopInterruptCallback::
	ret
A0FOAMAndPaletteCallback::
	call hOAMDMARoutine
	call UploadPendingCGBPalettes
	ret
WaitA0FFrameFlag::
	halt
	nop
A0FWait_47D7::
	ldh a, [$FF8A]
	and a, a
	jr z, A0FWait_47D7
	xor a, a
	ldh [$FF8A], a
	ret
ASSERT @ == $67E0
