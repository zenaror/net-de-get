; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $22A7-$23E3.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:22A7-23E3", ROM0[$22A7]
ResidualROM00_22A7::
	db $F5, $C5, $D5, $E5, $F3, $EA, $80, $CF, $EA, $6B, $C6, $EA, $65, $C6, $FA, $63
	db $C6, $EA, $66, $C6, $FA, $64, $C6, $EA, $67, $C6, $FA, $63, $C6, $EA, $FF, $37
	db $EA, $15, $C1, $FA, $64, $C6, $EA, $00, $38, $EA, $16, $C1, $3E, $1E, $EA, $FF
	db $27, $EA, $13, $C1, $3E, $00, $EA, $00, $28, $EA, $14, $C1, $CD, $03, $40, $F0
	db $AB, $EA, $FF, $27, $EA, $13, $C1, $F0, $AC, $EA, $00, $28, $EA, $14, $C1, $F0
	db $AD, $EA, $FF, $37, $EA, $15, $C1, $F0, $AE, $EA, $00, $38, $EA, $16, $C1, $FB
	db $E1, $D1, $C1, $F1, $C9, $F5, $C5, $D5, $E5, $F3, $EA, $82, $CF, $FA, $63, $C6
	db $EA, $FF, $37, $EA, $15, $C1, $FA, $64, $C6, $EA, $00, $38, $EA, $16, $C1, $3E
	db $1E, $EA, $FF, $27, $EA, $13, $C1, $3E, $00, $EA, $00, $28, $EA, $14, $C1, $CD
	db $06, $40, $F0, $AB, $EA, $FF, $27, $EA, $13, $C1, $F0, $AC, $EA, $00, $28, $EA
	db $14, $C1, $F0, $AD, $EA, $FF, $37, $EA, $15, $C1, $F0, $AE, $EA, $00, $38, $EA
	db $16, $C1, $FB, $E1, $D1, $C1, $F1, $C9, $F5, $C5, $D5, $E5, $F3, $3E, $80, $EA
	db $80, $CF, $3E, $80, $EA, $82, $CF, $FA, $63, $C6, $EA, $FF, $37, $EA, $15, $C1
	db $FA, $64, $C6, $EA, $00, $38, $EA, $16, $C1, $3E, $1E, $EA, $FF, $27, $EA, $13
	db $C1, $3E, $00, $EA, $00, $28, $EA, $14, $C1, $CD, $03, $40, $CD, $06, $40, $CD
	db $00, $40, $F0, $AB, $EA, $FF, $27, $EA, $13, $C1, $F0, $AC, $EA, $00, $28, $EA
	db $14, $C1, $F0, $AD, $EA, $FF, $37, $EA, $15, $C1, $F0, $AE, $EA, $00, $38, $EA
	db $16, $C1, $AF, $EA, $65, $C6, $EA, $66, $C6, $EA, $67, $C6, $EA, $6B, $C6, $FB
	db $E1, $D1, $C1, $F1, $C9, $3E, $02, $EA, $86, $CF, $3E, $01, $EA, $87, $CF, $AF
	db $EA, $65, $C6, $EA, $66, $C6, $EA, $67, $C6, $EA, $6B, $C6, $C9
ASSERT @ == $23E4
