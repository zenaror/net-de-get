; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0A, address $5C1A-$5CE1.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0A:5C1A-5CE1", ROMX[$5C1A], BANK[$0A]
ResidualROM0A_5C1A::
	db $10, $81, $93, $FE, $A1, $10, $10, $83, $B2, $8A, $87, $00, $10, $81, $93, $FE
	db $A1, $10, $10, $83, $B2, $8A, $87, $10, $10, $8D, $91, $00, $10, $9F, $83, $10
	db $10, $10, $83, $83, $87, $00, $FE, $D8, $3C, $D4, $B6, $10, $8D, $90, $98, $83
	db $A4, $91, $00, $8D, $90, $94, $FE, $D8, $3C, $D4, $9F, $10, $A8, $85, $83, $95
	db $FE, $99, $00, $CE, $F7, $D8, $F7, $D7, $B0, $AE, $85, $B0, $AD, $85, $B6, $9F
	db $AF, $96, $98, $00, $FE, $D4, $C5, $F7, $F3, $3C, $FE, $D9, $90, $9A, $83, $99
	db $10, $81, $93, $FE, $A1, $8E, $99, $00, $FE, $8A, $10, $FE, $98, $8B, $A4, $92
	db $B7, $10, $AE, $B3, $90, $83, $FE, $98, $91, $8A, $2F, $00, $00, $8A, $B7, $B0
	db $FE, $D8, $3C, $D4, $FE, $8A, $10, $9A, $89, $92, $A4, $92, $B7, $3F, $10, $00
	db $90, $AD, $8B, $8A, $90, $98, $10, $8C, $FE, $94, $8F, $83, $3F, $93, $9E, $99
	db $8B, $00, $83, $A4, $A4, $FE, $98, $10, $FE, $D4, $C5, $F7, $F3, $3C, $FE, $D9
	db $90, $94, $00, $FE, $CD, $3C, $E6, $FE, $8A, $10, $83, $95, $FE, $A1, $10, $8B
	db $87, $A4, $91, $3F, $00, $00, $0A, $00
ASSERT @ == $5CE2
