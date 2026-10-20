; PROBABLE bank09 utility roles from complete local control flow.
; Direct callers were not found by an opcode-pattern scan; indirect use is open.
; The STAT loops and DI/EI are static facts, not a timing or IME-preservation claim.

SECTION "Subtract DE from HL 5D11-5D17", ROMX[$5D11], BANK[$09]
ResidualROM09_5D11::
SubtractDEFromHLPreservingSBCFlags::
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	ret
ASSERT @ == $5D18

SECTION "Write A as three decimal digits 5D18-5D43", ROMX[$5D18], BANK[$09]
WriteAAsThreeDecimalDigits::
	push bc
	ld b, $00
.hundreds
	or a, a
	ld c, a
	sub a, $64
	jr c, .writeHundreds
	inc b
	jr .hundreds
.writeHundreds
	ld a, b
	ld [hli], a
	ld a, c
	ld b, $00
.tens
	or a, a
	ld c, a
	sub a, $0A
	jr c, .writeTens
	inc b
	jr .tens
.writeTens
	ld a, b
	ld [hli], a
	ld a, c
	ld b, $00
.ones
	or a, a
	ld c, a
	sub a, $01
	jr c, .writeOnes
	inc b
	jr .ones
.writeOnes
	ld a, b
	ld [hli], a
	pop bc
	ret
ASSERT @ == $5D44

SECTION "Wait for STAT bit 1 clear and write A to HL 5D44-5D4F", ROMX[$5D44], BANK[$09]
WaitForSTATBit1ClearAndWriteAToHL::
	push af
	di
.wait
	ldh a, [$FF41]
	and a, $02
	jr nz, .wait
	pop af
	ld [hl], a
	ei
	ret
ASSERT @ == $5D50

SECTION "Wait for STAT bit 1 clear and write A to DE 5D50-5D5B", ROMX[$5D50], BANK[$09]
WaitForSTATBit1ClearAndWriteAToDE::
	push af
	di
.wait
	ldh a, [$FF41]
	and a, $02
	jr nz, .wait
	pop af
	ld [de], a
	ei
	ret
ASSERT @ == $5D5C
