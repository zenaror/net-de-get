; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $3EDC-$3FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:3EDC-3FFF", ROM0[$3EDC]
ResidualROM00_3EDC::
	db $F5, $D5, $F0, $AB, $EA, $7A, $C6, $F0, $AC, $EA, $7B, $C6, $F3, $3E, $10, $E0
	db $AB, $EA, $13, $C1, $EA, $FF, $27, $AF, $E0, $AC, $EA, $14, $C1, $EA, $00, $28
	db $F0, $8E, $EA, $7C, $C6, $F0, $8F, $EA, $7D, $C6, $11, $00, $00, $CD, $50, $01
	db $FB, $D1, $F1, $CD, $90, $4E, $F5, $D5, $F3, $FA, $7A, $C6, $E0, $AB, $EA, $13
	db $C1, $EA, $FF, $27, $FA, $7B, $C6, $E0, $AC, $EA, $14, $C1, $EA, $00, $28, $FA
	db $7C, $C6, $5F, $FA, $7D, $C6, $57, $CD, $50, $01, $FB, $D1, $F1, $C9, $3E, $05
	db $EA, $7E, $C6, $CD, $A0, $02, $C9, $3E, $0E, $EA, $7E, $C6, $CD, $A0, $02, $C9
	db $3E, $06, $EA, $7E, $C6, $CD, $A0, $02, $C9, $F5, $3E, $07, $EA, $7E, $C6, $F1
	db $CD, $A0, $02, $C9, $3E, $08, $EA, $7E, $C6, $CD, $A0, $02, $C9, $EA, $A2, $C2
	db $AF, $EA, $A3, $C2, $1A, $13, $22, $A7, $28, $4B, $FE, $FF, $20, $F6, $2B, $D5
	db $E5, $FA, $A2, $C2, $3D, $28, $36, $EA, $A2, $C2, $07, $C6, $C2, $6F, $3E, $3F
	db $CE, $00, $67, $2A, $56, $5F, $60, $69, $06, $00, $19, $30, $03, $04, $18, $FA
	db $7D, $93, $6F, $7C, $9A, $67, $FA, $A3, $C2, $B0, $20, $04, $3E, $10, $18, $06
	db $EA, $A3, $C2, $3E, $20, $80, $44, $4D, $E1, $22, $E5, $18, $C4, $E1, $79, $C6
	db $20, $22, $D1, $18, $AF, $C9, $FF, $FF, $F6, $FF, $9C, $FF, $18, $FC, $F0, $D8
	ds $34, $00
ASSERT @ == $4000
