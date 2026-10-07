; PROBABLE secondary resource reader/tick and wrapped-byte coordinate helpers.
; Static and synthetic contracts; natural resource/timing integration unproven.
SECTION "A12 secondary resource 50D8-50DE", ROMX[$50D8], BANK[$09]
ResidualROM09_50D8::
LoadA12SecondaryResource::
	ld hl, $6EE0
	call ReadA12SecondaryResource
	ret
ASSERT @ == $50DF

SECTION "A12 secondary resource 50DF-5116", ROMX[$50DF], BANK[$09]
TickA12SecondaryResource::
	ld a, [$C5CB]
	ld b, a
	ld a, [$C5CC]
	sub a, b
	jp c, MoveA12SecondaryCoordinates
	ld a, [$C5CD]
	ld b, a
	ld a, [$C5CE]
	inc a
	cp a, b
	jr nz, A12Secondary_5106
	dec a
	push af
	xor a, a
	ld [$C5CE], a
	ld hl, $6EE0
	call ReadA12SecondaryResource
	pop af
	ld [$C5CE], a
	ret
A12Secondary_5106::
	ld [$C5CE], a
	ld hl, $6EE0
	call ReadA12SecondaryResource
	ld a, [$C5CE]
	dec a
	ld [$C5CE], a
	ret
ASSERT @ == $5117

SECTION "A12 secondary resource 5117-5187", ROMX[$5117], BANK[$09]
ReadA12SecondaryResource::
	ldh a, [$FFAD]
	ldh [$FF9D], a
	ldh a, [$FFAE]
	ldh [$FF9E], a
	ld a, [$C21C]
	ld [$37FF], a
	ldh [$FFAD], a
	ld a, [$C21D]
	ld [$3800], a
	ldh [$FFAE], a
	ld a, [$C5CF]
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	push hl
	pop de
	ld a, [$C5CE]
	ld h, a
	ld l, $04
	call $5CFF
	add hl, de
	ld a, [hl]
	cp a, $FF
	jr nz, A12Secondary_5150
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
A12Secondary_5150::
	ld a, [hl]
	cp a, $FE
	jr nz, A12Secondary_5159
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
A12Secondary_5159::
	ld a, [hli]
	ld [$C5F6], a
	ld a, [hli]
	ld [$C5EB], a
	ld a, [hli]
	ld [$C5EC], a
	ld a, [hli]
	ld a, [hl]
	cp a, $FF
	jr nz, A12Secondary_516F
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
A12Secondary_516F::
	ld a, [hl]
	cp a, $FE
	jr nz, A12Secondary_5178
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
A12Secondary_5178::
	ld a, [hli]
	ld a, [hli]
	ld [$C5ED], a
	ld a, [hli]
	ld [$C5EE], a
	call NormalizeA12SecondaryCoordinates
	call ComputeA12SecondaryDistances
	ret
ASSERT @ == $5188

SECTION "A12 secondary resource 51FA-5222", ROMX[$51FA], BANK[$09]
ResidualROM09_51FA::
NormalizeA12SecondaryCoordinates::
	ld a, $C9
	ld b, a
	ld a, [$C5EB]
	sub a, b
	ld [$C5EB], a
	ld a, $D0
	ld b, a
	ld a, [$C5EC]
	sub a, b
	ld [$C5EC], a
	ld a, $C9
	ld b, a
	ld a, [$C5ED]
	sub a, b
	ld [$C5ED], a
	ld a, $D0
	ld b, a
	ld a, [$C5EE]
	sub a, b
	ld [$C5EE], a
	ret
ASSERT @ == $5223

SECTION "A12 secondary resource 5223-5269", ROMX[$5223], BANK[$09]
ComputeA12SecondaryDistances::
	ld a, [$C5ED]
	ld b, a
	ld a, [$C5EB]
	cp a, b
	jp nc, A12Secondary_523B
	ld a, [$C5EB]
	ld b, a
	ld a, [$C5ED]
	sub a, b
	ld [$C5F1], a
	jr A12Secondary_5246
A12Secondary_523B::
	ld a, [$C5ED]
	ld b, a
	ld a, [$C5EB]
	sub a, b
	ld [$C5F1], a
A12Secondary_5246::
	ld a, [$C5EE]
	ld b, a
	ld a, [$C5EC]
	cp a, b
	jp nc, A12Secondary_525E
	ld a, [$C5EC]
	ld b, a
	ld a, [$C5EE]
	sub a, b
	ld [$C5F2], a
	jr A12Secondary_5269
A12Secondary_525E::
	ld a, [$C5EE]
	ld b, a
	ld a, [$C5EC]
	sub a, b
	ld [$C5F2], a
A12Secondary_5269::
	ret
ASSERT @ == $526A

SECTION "A12 secondary resource 526A-52CE", ROMX[$526A], BANK[$09]
MoveA12SecondaryCoordinates::
	ld a, [$C5EB]
	ld b, a
	ld a, [$C5ED]
	sub a, b
	ld c, a
	ld a, [$C5EC]
	ld b, a
	ld a, [$C5EE]
	sub a, b
	or a, c
	ret z
	call ComputeA12SecondarySteps
	ld a, [$C5EB]
	ld b, a
	ld a, [$C5ED]
	cp a, b
	jr z, A12Secondary_52A8
	cp a, b
	jp nc, A12Secondary_529B
	ld a, [$C5EF]
	ld b, a
	ld a, [$C5EB]
	sub a, b
	ld [$C5EB], a
	jr A12Secondary_52A8
A12Secondary_529B::
	ld a, [$C5EF]
	ld b, a
	ld a, [$C5EB]
	add a, b
	ld [$C5EB], a
	jr A12Secondary_52A8
A12Secondary_52A8::
	ld a, [$C5EC]
	ld b, a
	ld a, [$C5EE]
	cp a, b
	jr z, A12Secondary_52CE
	cp a, b
	jp nc, A12Secondary_52C3
	ld a, [$C5F0]
	ld b, a
	ld a, [$C5EC]
	sub a, b
	ld [$C5EC], a
	jr A12Secondary_52CE
A12Secondary_52C3::
	ld a, [$C5F0]
	ld b, a
	ld a, [$C5EC]
	add a, b
	ld [$C5EC], a
A12Secondary_52CE::
	ret
ASSERT @ == $52CF

SECTION "A12 secondary resource 52CF-5313", ROMX[$52CF], BANK[$09]
ComputeA12SecondarySteps::
	xor a, a
	ld [$C5F3], a
	ld a, [$C5CC]
	ld b, a
A12Secondary_52D7::
	ld a, [$C5CB]
	ld c, a
	ld a, [$C5F3]
	ld h, a
	ld a, [$C5F1]
	add a, h
	call DivideA12AByC
	ld a, h
	ld [$C5EF], a
	ld a, l
	ld [$C5F3], a
	dec b
	jr nz, A12Secondary_52D7
	xor a, a
	ld [$C5F4], a
	ld a, [$C5CC]
	ld b, a
A12Secondary_52F9::
	ld a, [$C5CB]
	ld c, a
	ld a, [$C5F4]
	ld h, a
	ld a, [$C5F2]
	add a, h
	call DivideA12AByC
	ld a, h
	ld [$C5F0], a
	ld a, l
	ld [$C5F4], a
	dec b
	jr nz, A12Secondary_52F9
	ret
ASSERT @ == $5314
