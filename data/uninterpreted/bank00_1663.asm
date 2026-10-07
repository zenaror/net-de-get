; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $1663-$1FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:1663-1FFF", ROM0[$1663]
ResidualROM00_1663::
	db $F3, $11, $41, $C6, $CD, $83, $17, $CD, $27, $42, $11, $41, $C6, $CD, $9F, $17
	db $FB, $C9, $F3, $11, $43, $C6, $CD, $83, $17, $CD, $4D, $42, $F5, $11, $43, $C6
	db $CD, $9F, $17, $F1, $FB, $C9, $F3, $11, $45, $C6, $CD, $83, $17, $CD, $CB, $42
	db $F5, $11, $45, $C6, $CD, $9F, $17, $F1, $FB, $C9, $F3, $11, $47, $C6, $CD, $83
	db $17, $CD, $EF, $42, $F5, $11, $47, $C6, $CD, $9F, $17, $F1, $FB, $C9, $21, $00
	db $C7, $01, $32, $00, $AF, $22, $0B, $79, $B0, $20, $F9, $C9, $F3, $EA, $3A, $C6
	db $D5, $11, $49, $C6, $CD, $83, $17, $D1, $CD, $12, $43, $11, $49, $C6, $CD, $9F
	db $17, $FB, $C9, $F3, $EA, $3A, $C6, $D5, $11, $4B, $C6, $CD, $83, $17, $D1, $CD
	db $91, $43, $11, $4B, $C6, $CD, $9F, $17, $FB, $C9, $F0, $70, $E6, $07, $F5, $3E
	db $07, $E0, $70, $41, $11, $00, $D0, $2A, $12, $13, $A7, $20, $FA, $05, $20, $F7
	db $F3, $11, $00, $00, $CD, $53, $01, $CD, $50, $01, $CD, $56, $01, $CD, $59, $01
	db $CD, $DA, $01, $FB, $11, $4D, $C6, $CD, $83, $17, $21, $00, $D0, $CD, $28, $45
	db $11, $4D, $C6, $CD, $9F, $17, $F1, $E0, $70, $C9, $F0, $70, $E6, $07, $F5, $3E
	db $07, $E0, $70, $C5, $06, $04, $6B, $62, $11, $00, $D0, $2A, $12, $13, $05, $20
	db $FA, $F3, $11, $00, $00, $CD, $53, $01, $CD, $50, $01, $CD, $56, $01, $CD, $59
	db $01, $CD, $DA, $01, $FB, $11, $4F, $C6, $CD, $83, $17, $11, $00, $D0, $C1, $CD
	db $E9, $47, $11, $4F, $C6, $CD, $9F, $17, $F1, $E0, $70, $C9, $F3, $F5, $11, $51
	db $C6, $CD, $83, $17, $F1, $CD, $87, $4C, $11, $51, $C6, $CD, $9F, $17, $FB, $C9
	db $F0, $AB, $12, $13, $F0, $AC, $12, $3E, $16, $EA, $FF, $27, $E0, $AB, $EA, $13
	db $C1, $3E, $00, $EA, $00, $28, $E0, $AC, $EA, $14, $C1, $C9, $1A, $EA, $FF, $27
	db $E0, $AB, $EA, $13, $C1, $13, $1A, $EA, $00, $28, $E0, $AC, $EA, $14, $C1, $C9
	db $53, $59, $53, $30, $CD, $80, $FF, $CD, $8C, $01, $CD, $E8, $39, $C9, $00, $00
	ds $83D, $00
ASSERT @ == $2000
