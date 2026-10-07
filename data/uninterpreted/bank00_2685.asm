; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $2685-$2752.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:2685-2752", ROM0[$2685]
ResidualROM00_2685::
	db $FE, $10, $30, $0D, $C6, $D8, $6F, $3E, $3C, $CE, $00, $67, $5E, $16, $00, $18
	db $05, $D6, $10, $5F, $16, $08, $C9, $EA, $AF, $C1, $AF, $EA, $C2, $C1, $EA, $C0
	db $C1, $EA, $C1, $C1, $EA, $19, $C2, $EA, $1A, $C2, $21, $B5, $C1, $3E, $00, $22
	db $3E, $98, $77, $F0, $4F, $E6, $01, $F5, $FA, $AF, $C1, $E0, $4F, $FA, $AF, $C1
	db $B7, $3E, $07, $28, $03, $0E, $08, $B1, $EA, $A3, $C1, $FA, $AF, $C1, $B7, $3E
	db $00, $28, $03, $0E, $08, $B1, $EA, $B0, $C1, $FA, $AF, $C1, $B7, $3E, $01, $28
	db $03, $0E, $08, $B1, $EA, $B1, $C1, $FA, $AF, $C1, $B7, $3E, $02, $28, $03, $0E
	db $08, $B1, $EA, $B2, $C1, $FA, $AF, $C1, $B7, $3E, $00, $28, $03, $0E, $08, $B1
	db $EA, $B7, $C1, $21, $E0, $4E, $11, $E0, $97, $01, $20, $00, $CD, $98, $01, $AF
	db $EA, $BF, $C1, $F1, $E0, $4F, $C9, $21, $C0, $C1, $73, $23, $72, $C9, $21, $19
	db $C2, $73, $23, $72, $C9, $21, $AB, $C1, $73, $23, $72, $C9, $F0, $4F, $E6, $01
	db $F5, $FA, $AF, $C1, $E0, $4F, $11, $C0, $96, $01, $20, $01, $CD, $68, $0A, $F0
	db $9D, $11, $60, $87, $01, $A0, $00, $CD, $68, $0A, $F1, $E0, $4F, $C9
ASSERT @ == $2753
