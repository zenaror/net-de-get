; PROBABLE text-step scheduling; static plus SYNTHETIC early-return probes.
; Native A $14, physical RGBDS bank $0A lower half.
SECTION "Local text step", ROMX[$4656], BANK[$0A]
StepLocalMenuText::
	ld a, [$D016]
	and a, a
	jr z, .at46C0
	dec a
	jr z, .at4664
	ld [$D016], a
	jr .at46C0
.at4664:
	ld a, [$C1BA]
	cp a, $02
	jr nz, .at4670
	ld a, $02
	ld [$D016], a
.at4670:
	ld a, [$D019]
	ld [$C1C2], a
	ld hl, $D32A
	ld a, [$D017]
	ld e, a
	ld a, [$D018]
	ld d, a
.at4681:
	ld a, [de]
	inc de
	and a, a
	jr nz, .at4692
	xor a, a
	ld [$D016], a
	ld a, [$C1BA]
	and a, a
	jr z, .at46A0
	jr .at46C0
.at4692:
	cp a, $FE
	jr c, .at4699
	ld [hli], a
	ld a, [de]
	inc de
.at4699:
	ld [hli], a
	ld a, [$C1BA]
	and a, a
	jr z, .at4681
.at46A0:
	ld [hl], $00
	ld a, e
	ld [$D017], a
	ld a, d
	ld [$D018], a
	ld hl, $D32A
	ld c, $00
	ld a, [$D01A]
	ld b, a
	inc a
	ld [$D01A], a
	call ResidentJump01EF
	ld a, [$C1C2]
	ld [$D019], a
.at46C0:
	ret
.end:
ASSERT .end - StepLocalMenuText == $6B
