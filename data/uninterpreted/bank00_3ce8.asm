; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $3CE8-$3DFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:3CE8-3DFF", ROM0[$3CE8]
ResidualROM00_3CE8::
	db $F3, $11, $00, $00, $CD, $50, $01, $FB, $3E, $01, $CD, $82, $02, $F3, $3E, $14
	db $E0, $AB, $EA, $FF, $27, $EA, $13, $C1, $AF, $E0, $AC, $EA, $00, $28, $EA, $14
	db $C1, $11, $08, $5A, $CD, $50, $01, $FB, $C9, $3E, $03, $21, $88, $51, $CD, $7A
	db $01, $CD, $6E, $51, $CD, $26, $5B, $F3, $11, $00, $00, $CD, $50, $01, $FB, $FA
	db $01, $D0, $EA, $1B, $C8, $AF, $EA, $65, $C7, $06, $00, $3E, $0C, $CD, $64, $02
	db $3E, $01, $E0, $70, $FA, $1B, $C8, $EA, $01, $D0, $F3, $3E, $14, $E0, $AB, $EA
	db $FF, $27, $EA, $13, $C1, $AF, $E0, $AC, $EA, $00, $28, $EA, $14, $C1, $FB, $FA
	db $64, $C7, $A7, $28, $03, $CD, $8C, $5B, $CD, $C6, $5B, $CD, $88, $02, $FA, $06
	db $C7, $87, $16, $00, $5F, $21, $94, $3D, $19, $5E, $23, $56, $23, $E5, $21, $66
	db $C6, $4E, $23, $46, $69, $60, $CD, $28, $02, $E1, $C2, $8F, $3D, $FA, $65, $C6
	db $FE, $81, $3E, $00, $CA, $9A, $3D, $3E, $01, $C3, $9A, $3D, $21, $00, $5B, $00
	db $5C, $00, $A7, $28, $41, $CD, $88, $02, $FA, $06, $C7, $21, $AA, $3D, $E5, $C3
	db $F5, $05, $B0, $3D, $C0, $3D, $D0, $3D, $21, $00, $60, $11, $21, $00, $CD, $46
	db $02, $3E, $81, $CD, $4C, $02, $18, $1E, $21, $00, $60, $11, $5B, $00, $CD, $46
	db $02, $3E, $81, $CD, $4C, $02, $18, $0E, $21, $00, $60, $11, $5C, $00, $CD, $46
	db $02, $3E, $81, $CD, $4C, $02, $C9, $01, $A3, $02, $11, $D8, $3E, $CD, $B6, $01
	db $F5, $C5, $D5, $E5, $7D, $B4, $28, $0B, $79, $A7, $CA, $F8, $3D, $CD, $00, $3E
	db $CD, $B9, $01, $E1, $D1, $C1, $F1, $C9
ASSERT @ == $3E00
