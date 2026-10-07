; PROBABLE C5FD command dispatcher; full synthetic original-code contracts.
; Color pointer is 53B2+128*C5A8 without a clamp; raw variants need context.
SECTION "A12 resource commands 4AC9-4B6F", ROMX[$4AC9], BANK[$09]
DispatchA12ResourceCommand::
	ld a, [$C5FD]
	cp a, $00
	ret z
	cp a, $F0
	jr z, A12ResourceCommand_4AF4
	cp a, $F1
	jr z, A12ResourceCommand_4AFA
	cp a, $F2
	jr z, A12ResourceCommand_4B03
	cp a, $F3
	jr z, A12ResourceCommand_4B0A
	cp a, $F4
	jr z, A12ResourceCommand_4B11
	cp a, $F5
	jr z, A12ResourceCommand_4B20
	cp a, $F6
	jr z, A12ResourceCommand_4B2F
	cp a, $F7
	jr z, A12ResourceCommand_4B3E
	cp a, $FE
	jr z, A12ResourceCommand_4B45
	ret
A12ResourceCommand_4AF4::
	ld a, $01
	ld [$C738], a
	ret
A12ResourceCommand_4AFA::
	xor a, a
	ld [$C214], a
	ld [$C624], a
	jr A12ResourceCommand_4B4C
A12ResourceCommand_4B03::
	ld a, $01
	ld [$C214], a
	jr A12ResourceCommand_4B4C
A12ResourceCommand_4B0A::
	ld a, $02
	ld [$C214], a
	jr A12ResourceCommand_4B4C
A12ResourceCommand_4B11::
	call ResidentJump0255
	ld a, $04
	ld [$C214], a
	ld a, $01
	ld [$C706], a
	jr A12ResourceCommand_4B4C
A12ResourceCommand_4B20::
	call ResidentJump0255
	ld a, $04
	ld [$C214], a
	ld a, $02
	ld [$C706], a
	jr A12ResourceCommand_4B4C
A12ResourceCommand_4B2F::
	call ResidentJump0255
	ld a, $04
	ld [$C214], a
	ld a, $00
	ld [$C706], a
	jr A12ResourceCommand_4B4C
A12ResourceCommand_4B3E::
	ld a, $06
	ld [$C214], a
	jr A12ResourceCommand_4B4C
A12ResourceCommand_4B45::
	ld a, $04
	ld [$C214], a
	jr A12ResourceCommand_4B4C
A12ResourceCommand_4B4C::
	ld a, $00
	ld [$C213], a
	ld a, $00
	ld [$C1C4], a
	ld de, $53B2
	ld h, $80
	ld a, [$C5A8]
	ld l, a
	call MultiplyA12HLBytes
	add hl, de
	ld a, $04
	call StartColorAddTransition
	ld a, [$C5A3]
	inc a
	ld [$C5A3], a
	ret
ASSERT @ == $4B70
