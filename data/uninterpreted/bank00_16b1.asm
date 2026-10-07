; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $16B1-$1782.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:16B1-1782", ROM0[$16B1]
ResidualROM00_16B1::
	db $21, $00, $C7, $01, $32, $00, $AF, $22, $0B, $79, $B0, $20, $F9, $C9, $F3, $EA
	db $3A, $C6, $D5, $11, $49, $C6, $CD, $83, $17, $D1, $CD, $12, $43, $11, $49, $C6
	db $CD, $9F, $17, $FB, $C9, $F3, $EA, $3A, $C6, $D5, $11, $4B, $C6, $CD, $83, $17
	db $D1, $CD, $91, $43, $11, $4B, $C6, $CD, $9F, $17, $FB, $C9, $F0, $70, $E6, $07
	db $F5, $3E, $07, $E0, $70, $41, $11, $00, $D0, $2A, $12, $13, $A7, $20, $FA, $05
	db $20, $F7, $F3, $11, $00, $00, $CD, $53, $01, $CD, $50, $01, $CD, $56, $01, $CD
	db $59, $01, $CD, $DA, $01, $FB, $11, $4D, $C6, $CD, $83, $17, $21, $00, $D0, $CD
	db $28, $45, $11, $4D, $C6, $CD, $9F, $17, $F1, $E0, $70, $C9, $F0, $70, $E6, $07
	db $F5, $3E, $07, $E0, $70, $C5, $06, $04, $6B, $62, $11, $00, $D0, $2A, $12, $13
	db $05, $20, $FA, $F3, $11, $00, $00, $CD, $53, $01, $CD, $50, $01, $CD, $56, $01
	db $CD, $59, $01, $CD, $DA, $01, $FB, $11, $4F, $C6, $CD, $83, $17, $11, $00, $D0
	db $C1, $CD, $E9, $47, $11, $4F, $C6, $CD, $9F, $17, $F1, $E0, $70, $C9, $F3, $F5
	db $11, $51, $C6, $CD, $83, $17, $F1, $CD, $87, $4C, $11, $51, $C6, $CD, $9F, $17
	db $FB, $C9
ASSERT @ == $1783
