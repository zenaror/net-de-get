; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $06A6-$0798.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:06A6-0798", ROM0[$06A6]
ResidualROM00_06A6::
	db $E5, $E5, $6B, $62, $0E, $64, $CD, $57, $20, $7D, $54, $E1, $D5, $CD, $22, $07
	db $F1, $CD, $22, $07, $E1, $06, $04, $0E, $00, $7E, $FE, $10, $20, $08, $79, $A7
	db $28, $12, $36, $20, $18, $0E, $FE, $20, $20, $08, $79, $A7, $20, $06, $36, $10
	db $18, $02, $0E, $01, $23, $05, $20, $E1, $C9, $E5, $0E, $0A, $CD, $46, $20, $7C
	db $C6, $20, $5F, $7D, $0E, $0A, $CD, $46, $20, $7D, $C6, $20, $57, $7C, $C6, $20
	db $E1, $E5, $72, $23, $22, $73, $23, $E1, $06, $02, $0E, $00, $7E, $FE, $10, $20
	db $08, $79, $A7, $28, $12, $36, $20, $18, $0E, $FE, $20, $20, $08, $79, $A7, $20
	db $06, $36, $10, $18, $02, $0E, $01, $23, $05, $20, $E1, $C9, $FE, $63, $28, $03
	db $D2, $40, $07, $E5, $0E, $0A, $CD, $46, $20, $11, $20, $20, $19, $7D, $FE, $20
	db $20, $02, $3E, $10, $5C, $E1, $22, $73, $23, $C9, $3E, $4E, $22, $3E, $47, $22
	db $C9, $FE, $09, $28, $03, $D2, $52, $07, $C6, $20, $22, $C9, $3E, $4E, $22, $C9
	db $E0, $45, $A7, $20, $0D, $F0, $41, $E6, $3F, $E0, $41, $F0, $FF, $E6, $0D, $E0
	db $FF, $C9, $F0, $41, $E6, $3F, $F6, $40, $E0, $41, $F0, $FF, $F6, $02, $E0, $FF
	db $C9, $AF, $E0, $0F, $CD, $56, $07, $3E, $C3, $E0, $40, $C9, $F0, $FF, $F5, $E6
	db $FE, $E0, $FF, $F0, $44, $FE, $91, $20, $FA, $F0, $40, $E6, $7F, $E0, $40, $F1
	db $E0, $FF, $C9
ASSERT @ == $0799
