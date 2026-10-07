; PROBABLE A12 state recurrence and conditional variant1 frame trigger.
; C21C is a resource request, not proof of the current B window at header reads.
; Tests use explicitly prepared mappings; no natural random/menu behavior claim.

SECTION "A12 state seed 4BDD-4BE5", ROMX[$4BDD], BANK[$09]
SeedA12RandomState::
	ld a, l
	ld [$C5D2], a
	ld a, h
	ld [$C5D3], a
	ret
ASSERT @ == $4BE6

SECTION "A12 random state step 4BE6-4C10", ROMX[$4BE6], BANK[$09]
StepA12RandomState::
	ld a, [$C5D2]
	ld l, a
	ld e, a
	ld a, [$C5D3]
	ld d, a
	sla l
	rla
	sla l
	rla
	sla l
	rla
	sla l
	rla
	ld h, a
	ld a, e
	add a, l
	ld l, a
	ld a, h
	adc a, d
	ld h, a
	ld a, l
	add a, $93
	ld [$C5D2], a
	ld d, a
	ld a, h
	adc a, $5C
	ld [$C5D3], a
	ld e, a
	ret
ASSERT @ == $4C11

SECTION "A12 variant1 frame trigger 4C11-4C40", ROMX[$4C11], BANK[$09]
TryA12Variant1TileFrames::
	ld a, [$C5A4]
	cp a, $06
	ret nz
	ld a, [$C5CF]
	cp a, $01
	ret nz
	ld a, [$C5E4]
	cp a, $00
	ret nz
	call StepA12RandomState
	ld a, e
	and a, $FF
	jr nz, A12Trigger_4C32
	ld hl, $6A96
	call InitializeA12TileFrames
	ret
A12Trigger_4C32::
	call StepA12RandomState
	ld a, e
	and a, $0F
	jr nz, A12Trigger_4C40
	ld hl, $6AB1
	call InitializeA12TileFrames
A12Trigger_4C40::
	ret
ASSERT @ == $4C41
