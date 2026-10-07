; PROBABLE resource wrappers and direct OAM emission, static/synthetic contracts.
; Mapper writes and mirrored selectors are distinct. Raw byte counts remain unclamped.
SECTION "A12 resource wrapper 4A36-4A65", ROMX[$4A36], BANK[$09]
ResidualROM09_4A36::
TickA12Variant0ResourceWrapper::
	ld a, $61
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	call TickA12SecondaryResource
	call CopyA12SecondaryResourcePosition
	call TickA12ResourceFrame
	call CopyA12ResourcePosition
	ld hl, A12Variant0PrimaryOAMTable
	call EmitA12ResourceOAM
	ld hl, A12Variant0SecondaryOAMTable
	call EmitA12SecondaryResourceOAM
	ld hl, $C5CC
	inc [hl]
	ld a, [$C73A]
	and a, a
	jr z, A12ResourceWrapper_4A65
	inc [hl]
	inc [hl]
	inc [hl]
A12ResourceWrapper_4A65::
	ret
ASSERT @ == $4A66

SECTION "A12 resource wrapper 4A66-4A89", ROMX[$4A66], BANK[$09]
TickA12Variant1ResourceWrapper::
	ld a, $63
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	call TickA12ResourceFrame
	call CopyA12ResourcePosition
	ld hl, $6DEF
	call EmitA12ResourceOAM
	ld hl, $C5CC
	inc [hl]
	ld a, [$C73A]
	and a, a
	jr z, A12ResourceWrapper_4A89
	inc [hl]
	inc [hl]
	inc [hl]
A12ResourceWrapper_4A89::
	ret
ASSERT @ == $4A8A

SECTION "A12 resource wrapper 4A8A-4AAD", ROMX[$4A8A], BANK[$09]
TickA12Variant2ResourceWrapper::
	ld a, $65
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	call TickA12ResourceFrame
	call CopyA12ResourcePosition
	ld hl, $6DDC
	call EmitA12ResourceOAM
	ld hl, $C5CC
	inc [hl]
	ld a, [$C73A]
	and a, a
	jr z, A12ResourceWrapper_4AAD
	inc [hl]
	inc [hl]
	inc [hl]
A12ResourceWrapper_4AAD::
	ret
ASSERT @ == $4AAE

SECTION "A12 resource wrapper 4AAE-4AC8", ROMX[$4AAE], BANK[$09]
TickA12Variant3ResourceWrapper::
	ld a, $66
	ld [$C21C], a
	ld a, $00
	ld [$C21D], a
	call TickA12ResourceFrame
	call CopyA12ResourcePosition
	ld hl, $6A84
	call EmitA12ResourceOAM
	ld hl, $C5CC
	inc [hl]
	ret
ASSERT @ == $4AC9

SECTION "A12 resource wrapper 4DFE-4E64", ROMX[$4DFE], BANK[$09]
ResidualROM09_4DFE::
EmitA12ResourceOAM::
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
	ld a, [$C1C7]
	ld [$C5F5], a
	or a, a
	ret z
	ld a, [$C5D0]
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld a, [$C1C7]
	ld b, a
	ld a, $28
	sub a, b
	ld h, $04
	ld l, a
	call MultiplyA12HLBytes
	ld de, $C000
	add hl, de
	push hl
	pop de
	pop hl
	ld a, [hli]
	ld b, a
A12ResourceWrapper_4E40::
	ld a, [$C5F5]
	dec a
	ld [$C5F5], a
	ld a, [hli]
	ld c, a
	ld a, [$C5D6]
	add a, c
	add a, $10
	ld [de], a
	inc e
	ld a, [hli]
	ld c, a
	ld a, [$C5D5]
	add a, c
	add a, $08
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	dec b
	jr nz, A12ResourceWrapper_4E40
	ret
ASSERT @ == $4E65

SECTION "A12 resource wrapper 4E65-4E79", ROMX[$4E65], BANK[$09]
CopyA12ResourcePosition::
	ld a, $00
	ld b, a
	ld a, [$C5D7]
	sub a, b
	ld [$C5D5], a
	ld a, $00
	ld b, a
	ld a, [$C5D8]
	sub a, b
	ld [$C5D6], a
	ret
ASSERT @ == $4E7A

SECTION "A12 resource wrapper 5188-51E4", ROMX[$5188], BANK[$09]
EmitA12SecondaryResourceOAM::
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
	ld a, [$C5F5]
	or a, a
	ret z
	ld a, [$C5F6]
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld a, [$C5F5]
	ld b, a
	ld a, $28
	sub a, b
	ld h, $04
	ld l, a
	call MultiplyA12HLBytes
	ld de, $C000
	add hl, de
	push hl
	pop de
	pop hl
	ld a, [hli]
	ld b, a
A12ResourceWrapper_51C7::
	ld a, [hli]
	ld c, a
	ld a, [$C5EA]
	add a, c
	add a, $10
	ld [de], a
	inc e
	ld a, [hli]
	ld c, a
	ld a, [$C5E9]
	add a, c
	add a, $08
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	dec b
	jr nz, A12ResourceWrapper_51C7
	ret
ASSERT @ == $51E5

SECTION "A12 resource wrapper 51E5-51F9", ROMX[$51E5], BANK[$09]
CopyA12SecondaryResourcePosition::
	ld a, $00
	ld b, a
	ld a, [$C5EB]
	sub a, b
	ld [$C5E9], a
	ld a, $00
	ld b, a
	ld a, [$C5EC]
	sub a, b
	ld [$C5EA], a
	ret
ASSERT @ == $51FA
