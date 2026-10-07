; PROBABLE C601/C5CF text-mode controller; synthetic guards and forced suffixes.
; Downstream pending handlers are named; controller integration remains unproven.
SECTION "A12 text mode control 4B70-4BDC", ROMX[$4B70], BANK[$09]
UpdateA12TextModeController::
	ld a, [$C601]
	and a, a
	ret z
	cp a, $FF
	jp z, A12TextModeWait
	ld a, [$C5CF]
	cp a, $01
	ret nz
	ld a, $02
	ld [$C5CF], a
	call ResetA12ResourceFrame
	ld a, [$C601]
	cp a, $01
	jp z, QueueA12PendingText
	cp a, $02
	jr z, A12TextMode2
	ret
A12TextMode2::
	ld a, $01
	ld [$C73A], a
	ld a, $00
	call PrepareA12TextRegion
	call ShowA12TextWindow
	ld hl, $5695
	call ResidentJump01E9
	ld a, $FF
	ld [$C601], a
	ret
A12TextModeWait::
	ldh a, [$FF97]
	bit 0, a
	jr z, A12TextModeBusyCheck
	xor a, a
	ld [$C1C2], a
A12TextModeBusyCheck::
	ld a, [$C1B8]
	and a, a
	ret nz
	ld a, $00
	call HideA12TextWindowAndCopy
	ld a, $01
	ld [$C5CF], a
	call ResetA12ResourceFrame
	xor a, a
	ld [$C601], a
	ld a, [$C73B]
	cp a, $00
	ret z
	call DispatchA12PendingAction
	ld a, $00
	ld [$C73B], a
	ret
ASSERT @ == $4BDD
