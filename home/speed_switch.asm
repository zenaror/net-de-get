; PROBABLE CGB speed helpers from original KEY1/STOP flow and synthetic CPU calls.
; No physical speed-switch timing or natural interrupt trace is claimed.
SECTION "Resident speed switches 25CB-2612", ROM0[$25CB]
ResidualROM00_25CB::
SwitchToDoubleSpeed::
	ldh a, [$FF4D]
	bit 7, a
	ret nz
	ld a, $01
	ldh [$FF4D], a
	ldh a, [$FFFF]
	push af
	xor a
	ldh [$FFFF], a
	ld a, $30
	ldh [$FF00], a
	stop
.wait::
	ldh a, [$FF4D]
	bit 7, a
	jr z, .wait
	xor a
	ldh [$FF00], a
	ldh [$FF0F], a
	pop af
	ldh [$FFFF], a
	ret
SwitchToNormalSpeed::
	ldh a, [$FF4D]
	bit 7, a
	ret z
	ld a, $01
	ldh [$FF4D], a
	ldh a, [$FFFF]
	push af
	xor a
	ldh [$FFFF], a
	ld a, $30
	ldh [$FF00], a
	stop
.wait::
	ldh a, [$FF4D]
	bit 7, a
	jr nz, .wait
	xor a
	ldh [$FF00], a
	ldh [$FF0F], a
	pop af
	ldh [$FFFF], a
	ret
ASSERT @ == $2613
