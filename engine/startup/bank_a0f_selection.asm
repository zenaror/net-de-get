; PROBABLE original selection adjustment; forced full byte-domain CPU calls.
SECTION "A0F selection adjustment 631A-633E", ROMX[$631A], BANK[$07]
ResidualROM07_631A::
SnapA0FColumnForIncomingRow::
	push af
	cp a, $04
	jr c, A0FSelection_433D
	ld a, [$C766]
	cp a, $05
	jr nc, A0FSelection_432D
	ld a, $01
	ld [$C766], a
	jr A0FSelection_433D
A0FSelection_432D::
	cp a, $0A
	jr nc, A0FSelection_4338
	ld a, $06
	ld [$C766], a
	jr A0FSelection_433D
A0FSelection_4338::
	ld a, $0B
	ld [$C766], a
A0FSelection_433D::
	pop af
	ret
ASSERT @ == $633F

; PROBABLE original selection adjustment; forced full byte-domain CPU calls.
SECTION "A0F selection adjustment 633F-6389", ROMX[$633F], BANK[$07]
RemapA0FColumnOnLastRow::
	ld a, [$C767]
	cp a, $04
	jr c, A0FSelection_4389
	ld a, [$C766]
	cp a, $00
	jr nz, A0FSelection_4354
	ld a, $0B
	ld [$C766], a
	jr A0FSelection_4389
A0FSelection_4354::
	cp a, $02
	jr nz, A0FSelection_435F
	ld a, $06
	ld [$C766], a
	jr A0FSelection_4389
A0FSelection_435F::
	cp a, $05
	jr nz, A0FSelection_436A
	ld a, $01
	ld [$C766], a
	jr A0FSelection_4389
A0FSelection_436A::
	cp a, $07
	jr nz, A0FSelection_4375
	ld a, $0B
	ld [$C766], a
	jr A0FSelection_4389
A0FSelection_4375::
	cp a, $0A
	jr nz, A0FSelection_4380
	ld a, $06
	ld [$C766], a
	jr A0FSelection_4389
A0FSelection_4380::
	cp a, $0C
	jr nz, A0FSelection_4389
	ld a, $01
	ld [$C766], a
A0FSelection_4389::
	ret
ASSERT @ == $638A
