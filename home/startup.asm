; PROBABLE static startup/main dispatch; SYNTHETIC startup-prefix probes.
SECTION "Cartridge startup and main dispatch", ROM0[$02B8]
StartCartridgeProgram::
	di
	cp a, $11
	ld a, $00
	jr nz, .at02C0
	inc a
.at02C0:
	ld [$C000], a
	ld hl, $FF80
	ld bc, $0080
.at02C9:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, .at02C9
	ld a, [$C000]
	ldh [$FF9C], a
	ld sp, $FFFE
	ld hl, $C000
	ld bc, $1000
.at02DE:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, .at02DE
	ld a, $01
	ldh [$FF70], a
	ld hl, $D000
	ld bc, $1000
.at02EF:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, .at02EF
	ld a, $02
	ldh [$FF70], a
	ld hl, $D000
	ld bc, $1000
.at0300:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, .at0300
	ld a, $03
	ldh [$FF70], a
	ld hl, $D000
	ld bc, $1000
.at0311:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, .at0311
	ld a, $04
	ldh [$FF70], a
	ld hl, $D000
	ld bc, $1000
.at0322:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, .at0322
	ld a, $05
	ldh [$FF70], a
	ld hl, $D000
	ld bc, $1000
.at0333:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, .at0333
	ld a, $06
	ldh [$FF70], a
	ld hl, $D000
	ld bc, $1000
.at0344:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, .at0344
	ld a, $07
	ldh [$FF70], a
	ld hl, $D000
	ld bc, $1000
.at0355:
	xor a, a
	ld [hli], a
	dec bc
	ld a, c
	or a, b
	jr nz, .at0355
	ld a, $D9
	ld [$C67F], a
	ld [$C682], a
	ei
	ld a, $16
	ld [$27FF], a
	ldh [$FFAB], a
	ld a, $00
	ld [$2800], a
	ldh [$FFAC], a
	call InitializeBankA16
	ld a, $80
	ldh [$FF26], a
	ld a, $77
	ldh [$FF24], a
	ld a, $FF
	ldh [$FF25], a
	call ResidentJump0252
	ld a, [$C637]
	cp a, $02
	jr nz, DispatchMainState
	ld a, $09
	ld [$C623], a
DispatchMainState::
	ld a, [$C623]
	ld hl, MainStatePointers
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, MainStateReturn
	push hl
	ld l, e
	ld h, d
	jp hl
MainStateReturn::
	jr DispatchMainState
ASSERT @ == $03A8
