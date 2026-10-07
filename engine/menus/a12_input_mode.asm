; PROBABLE input mode and nested variant/action dispatch; synthetic contracts.
; Raw indices wrap at doubled byte offsets; no natural validity clamp.
SECTION "A12 input code 470F-475D", ROMX[$470F], BANK[$09]
UpdateA12InputMode::
	ld a, [$C600]
	cp a, $01
	ret nz
	ldh a, [$FF97]
	bit 0, a
	jr nz, A12InputConfirm
	bit 1, a
	jp nz, A12InputCancel
	jp A12InputIdleReturn
A12InputCancel::
	ld a, $9E
	call ResidentJump024F
	ld a, $01
	call HideA12TextWindowAndCopy
	ld a, $00
	ld [$C213], a
	xor a, a
	ldh [$FF97], a
	ld [$C600], a
	ret
A12InputIdleReturn::
	ret
A12InputConfirm::
	ld a, $9D
	call ResidentJump024F
	xor a, a
	ldh [$FF97], a
	ld a, [$C214]
	ld [$C732], a
	ld a, [$C5A8]
	ld hl, A12InputVariantTargets
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12InputVariantReturn
	push hl
	ld l, e
	ld h, d
	jp hl
A12InputVariantReturn::
	ret
ASSERT @ == $475E

SECTION "A12 input code 4764-4779", ROMX[$4764], BANK[$09]
DispatchA12InputVariant0::
	ld a, [$C214]
	ld hl, A12InputActions0
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12InputActionsReturn0
	push hl
	ld l, e
	ld h, d
	jp hl
A12InputActionsReturn0::
	ret
ASSERT @ == $477A

SECTION "A12 input code 485A-486F", ROMX[$485A], BANK[$09]
DispatchA12InputVariant1::
	ld a, [$C214]
	ld hl, A12InputActions1
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12InputActionsReturn1
	push hl
	ld l, e
	ld h, d
	jp hl
A12InputActionsReturn1::
	ret
ASSERT @ == $4870

SECTION "A12 input code 4940-4955", ROMX[$4940], BANK[$09]
DispatchA12InputVariant2::
	ld a, [$C214]
	ld hl, A12InputActions2
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, A12InputActionsReturn2
	push hl
	ld l, e
	ld h, d
	jp hl
A12InputActionsReturn2::
	ret
ASSERT @ == $4956
