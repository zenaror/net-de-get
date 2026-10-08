; PROBABLE phase/input gates and variant text setup, static extraction.
; Original input/state bytes and saturation retained; no natural meaning assigned.
SECTION "A12 phase input 459F-45C6", ROMX[$459F], BANK[$09]
UpdateA12PhaseInputGate::
	ld a, [$C5CF]
	cp a, $01
	jp nz, IncrementA12PhaseInputCounter
	ld a, [$C600]
	cp a, $00
	ret nz
	ld a, [$C601]
	cp a, $00
	ret nz
	ldh a, [$FF97]
	bit 0, a
	jr nz, A12PhaseInput_45BE
	bit 1, a
	jr nz, A12PhaseInput_45C3
	ret
A12PhaseInput_45BE:
	call DispatchA12PhaseInputVariant
	jr A12PhaseInput_45C3
A12PhaseInput_45C3:
	xor a, a
	ldh [$FF97], a
	ret
ASSERT @ == $45C7

SECTION "A12 phase input 45C7-45D9", ROMX[$45C7], BANK[$09]
DispatchA12PhaseInputVariant::
	ld a, [$C5A8]
	cp a, $00
	jp z, PrepareA12PhaseInputVariant0
	cp a, $01
	jp z, PrepareA12PhaseInputVariant1
	cp a, $02
	jp z, PrepareA12PhaseInputVariant2
	ret
ASSERT @ == $45DA

SECTION "A12 phase input 45DA-4640", ROMX[$45DA], BANK[$09]
PrepareA12PhaseInputVariant0::
	ld a, [$C5A4]
	cp a, $06
	jp nc, A12PhaseInput_460F
	cp a, $01
	jp nc, A12PhaseInput_45FB
	ld a, $00
	ld [$C214], a
	ld a, $03
	call PrepareA12TextRegion
	ld b, $05
	ld e, $01
	ld c, $03
	ld d, $03
	jr A12PhaseInput_4621
A12PhaseInput_45FB:
	ld a, $00
	ld [$C214], a
	ld a, $02
	call PrepareA12TextRegion
	ld b, $05
	ld e, $02
	ld c, $02
	ld d, $04
	jr A12PhaseInput_4621
A12PhaseInput_460F:
	ld a, $00
	ld [$C214], a
	ld a, $01
	call PrepareA12TextRegion
	ld b, $06
	ld e, $02
	ld c, $03
	ld d, $06
A12PhaseInput_4621:
	ld a, d
	ld [$C602], a
	ld hl, $5334
	call ResidentJump01F2
	call ResidentJump01F5
	call ShowA12TextWindow
	ld a, $01
	ld [$C600], a
	call ResidentJump0288
	ld a, [$C703]
	and a, a
	ret z
	jp ApplyA12PhaseInputCap
ASSERT @ == $4641

SECTION "A12 phase input 4641-468E", ROMX[$4641], BANK[$09]
PrepareA12PhaseInputVariant1::
	ld a, [$C5A4]
	cp a, $06
	jp nc, A12PhaseInput_465D
	ld a, $00
	ld [$C214], a
	ld a, $02
	call PrepareA12TextRegion
	ld b, $05
	ld e, $02
	ld c, $02
	ld d, $04
	jr A12PhaseInput_466F
A12PhaseInput_465D:
	ld a, $00
	ld [$C214], a
	ld a, $01
	call PrepareA12TextRegion
	ld b, $06
	ld e, $02
	ld c, $03
	ld d, $06
A12PhaseInput_466F:
	ld a, d
	ld [$C602], a
	ld hl, $535E
	call ResidentJump01F2
	call ResidentJump01F5
	call ShowA12TextWindow
	ld a, $01
	ld [$C600], a
	call ResidentJump0288
	ld a, [$C703]
	and a, a
	ret z
	jp ApplyA12PhaseInputCap
ASSERT @ == $468F

SECTION "A12 phase input 468F-46D9", ROMX[$468F], BANK[$09]
PrepareA12PhaseInputVariant2::
	ld a, [$C5A4]
	cp a, $06
	jp nc, A12PhaseInput_46AB
	ld a, $00
	ld [$C214], a
	ld a, $02
	call PrepareA12TextRegion
	ld b, $05
	ld e, $02
	ld c, $02
	ld d, $04
	jr A12PhaseInput_46BD
A12PhaseInput_46AB:
	ld a, $00
	ld [$C214], a
	ld a, $01
	call PrepareA12TextRegion
	ld b, $06
	ld e, $02
	ld c, $03
	ld d, $06
A12PhaseInput_46BD:
	ld a, d
	ld [$C602], a
	ld hl, $5387
	call ResidentJump01F2
	call ResidentJump01F5
	call ShowA12TextWindow
	ld a, $01
	ld [$C600], a
	call ResidentJump0288
	ld a, [$C703]
	and a, a
	ret z
ASSERT @ == $46DA

SECTION "A12 phase input 46DA-46F1", ROMX[$46DA], BANK[$09]
ApplyA12PhaseInputCap::
	ld a, [$C602]
	ld c, a
	ld a, [$C732]
	cp a, c
	jr z, A12PhaseInput_46E7
	jp nc, A12PhaseInput_46EB
A12PhaseInput_46E7:
	call ResidentJump02B2
	ret
A12PhaseInput_46EB:
	ld a, [$C602]
	call ResidentJump02B2
	ret
ASSERT @ == $46F2

SECTION "A12 phase input 46F2-470E", ROMX[$46F2], BANK[$09]
IncrementA12PhaseInputCounter::
	ldh a, [$FF97]
	bit 0, a
	jr nz, A12PhaseInput_4705
	bit 1, a
	jr nz, A12PhaseInput_4705
	bit 2, a
	jr nz, A12PhaseInput_4705
	bit 3, a
	jr nz, A12PhaseInput_4705
	ret
A12PhaseInput_4705:
	ld a, [$C739]
	add a, $01
	ret c
	ld [$C739], a
	ret
ASSERT @ == $470F
