; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $261C-$2752.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:261C-2752", ROM0[$261C]
ResidualROM00_261C::
	db $21, $8B, $FF, $34, $3E, $20, $E0, $00, $F0, $00, $F0, $00, $2F, $E6, $0F, $CB
	db $37, $47, $3E, $10, $E0, $00, $F0, $00, $F0, $00, $F0, $00, $F0, $00, $F0, $00
	db $F0, $00, $2F, $E6, $0F, $B0, $4F, $F0, $96, $A9, $A1, $E0, $97, $79, $E0, $96
	db $3E, $30, $E0, $00, $21, $9A, $FF, $F0, $96, $E6, $F3, $4F, $F0, $99, $B9, $28
	db $0E, $36, $00, $79, $E0, $99, $F0, $97, $E0, $98, $3E, $01, $E0, $9B, $C9, $7E
	db $3C, $E6, $9F, $20, $02, $3E, $80, $77, $CB, $7F, $28, $EA, $E6, $03, $20, $E6
	db $F0, $97, $B1, $E0, $98, $AF, $E0, $9B, $C9, $FE, $10, $30, $0D, $C6, $D8, $6F
	db $3E, $3C, $CE, $00, $67, $5E, $16, $00, $18, $05, $D6, $10, $5F, $16, $08, $C9
	db $EA, $AF, $C1, $AF, $EA, $C2, $C1, $EA, $C0, $C1, $EA, $C1, $C1, $EA, $19, $C2
	db $EA, $1A, $C2, $21, $B5, $C1, $3E, $00, $22, $3E, $98, $77, $F0, $4F, $E6, $01
	db $F5, $FA, $AF, $C1, $E0, $4F, $FA, $AF, $C1, $B7, $3E, $07, $28, $03, $0E, $08
	db $B1, $EA, $A3, $C1, $FA, $AF, $C1, $B7, $3E, $00, $28, $03, $0E, $08, $B1, $EA
	db $B0, $C1, $FA, $AF, $C1, $B7, $3E, $01, $28, $03, $0E, $08, $B1, $EA, $B1, $C1
	db $FA, $AF, $C1, $B7, $3E, $02, $28, $03, $0E, $08, $B1, $EA, $B2, $C1, $FA, $AF
	db $C1, $B7, $3E, $00, $28, $03, $0E, $08, $B1, $EA, $B7, $C1, $21, $E0, $4E, $11
	db $E0, $97, $01, $20, $00, $CD, $98, $01, $AF, $EA, $BF, $C1, $F1, $E0, $4F, $C9
	db $21, $C0, $C1, $73, $23, $72, $C9, $21, $19, $C2, $73, $23, $72, $C9, $21, $AB
	db $C1, $73, $23, $72, $C9, $F0, $4F, $E6, $01, $F5, $FA, $AF, $C1, $E0, $4F, $11
	db $C0, $96, $01, $20, $01, $CD, $68, $0A, $F0, $9D, $11, $60, $87, $01, $A0, $00
	db $CD, $68, $0A, $F1, $E0, $4F, $C9
ASSERT @ == $2753
