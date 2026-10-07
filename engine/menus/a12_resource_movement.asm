; PROBABLE wrapped-byte resource movement/division/step recurrence.
; Zero divisor and zero loop count are original behavior, not clamped.
SECTION "A12 resource movement 4EEA-4F4E", ROMX[$4EEA], BANK[$09]
ResidualROM09_4EEA::
MoveA12ResourceCoordinates::
	ld a, [$C5D7]
	ld b, a
	ld a, [$C5D9]
	sub a, b
	ld c, a
	ld a, [$C5D8]
	ld b, a
	ld a, [$C5DA]
	sub a, b
	or a, c
	ret z
	call ComputeA12ResourceSteps
	ld a, [$C5D7]
	ld b, a
	ld a, [$C5D9]
	cp a, b
	jr z, A12Movement_4F28
	cp a, b
	jp nc, A12Movement_4F1B
	ld a, [$C5DB]
	ld b, a
	ld a, [$C5D7]
	sub a, b
	ld [$C5D7], a
	jr A12Movement_4F28
A12Movement_4F1B::
	ld a, [$C5DB]
	ld b, a
	ld a, [$C5D7]
	add a, b
	ld [$C5D7], a
	jr A12Movement_4F28
A12Movement_4F28::
	ld a, [$C5D8]
	ld b, a
	ld a, [$C5DA]
	cp a, b
	jr z, A12Movement_4F4E
	cp a, b
	jp nc, A12Movement_4F43
	ld a, [$C5DC]
	ld b, a
	ld a, [$C5D8]
	sub a, b
	ld [$C5D8], a
	jr A12Movement_4F4E
A12Movement_4F43::
	ld a, [$C5DC]
	ld b, a
	ld a, [$C5D8]
	add a, b
	ld [$C5D8], a
A12Movement_4F4E::
	ret
ASSERT @ == $4F4F

SECTION "A12 resource movement 4F4F-4F69", ROMX[$4F4F], BANK[$09]
DivideA12AByC::
	push bc
	ld l, a
	ld h, $00
	cp a, c
	jp c, A12Movement_4F68
	ld b, $08
A12Movement_4F59::
	add hl, hl
	ld a, h
	cp a, c
	jr c, A12Movement_4F61
	sub a, c
	ld h, a
	inc l
A12Movement_4F61::
	dec b
	jr nz, A12Movement_4F59
	ld b, h
	ld c, l
	ld h, c
	ld l, b
A12Movement_4F68::
	pop bc
	ret
ASSERT @ == $4F6A

SECTION "A12 resource movement 4F6A-4FAE", ROMX[$4F6A], BANK[$09]
ComputeA12ResourceSteps::
	xor a, a
	ld [$C5DF], a
	ld a, [$C5CC]
	ld b, a
A12Movement_4F72::
	ld a, [$C5CB]
	ld c, a
	ld a, [$C5DF]
	ld h, a
	ld a, [$C5DD]
	add a, h
	call DivideA12AByC
	ld a, h
	ld [$C5DB], a
	ld a, l
	ld [$C5DF], a
	dec b
	jr nz, A12Movement_4F72
	xor a, a
	ld [$C5E0], a
	ld a, [$C5CC]
	ld b, a
A12Movement_4F94::
	ld a, [$C5CB]
	ld c, a
	ld a, [$C5E0]
	ld h, a
	ld a, [$C5DE]
	add a, h
	call DivideA12AByC
	ld a, h
	ld [$C5DC], a
	ld a, l
	ld [$C5E0], a
	dec b
	jr nz, A12Movement_4F94
	ret
ASSERT @ == $4FAF
