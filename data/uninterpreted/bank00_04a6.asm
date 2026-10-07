; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $04A6-$051D.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:04A6-051D", ROM0[$04A6]
ResidualROM00_04A6::
	db $CD, $88, $02, $FA, $06, $C7, $87, $16, $00, $5F, $21, $D7, $04, $19, $5E, $23
	db $56, $23, $E5, $21, $66, $C6, $4E, $23, $46, $69, $60, $CD, $28, $02, $E1, $C2
	db $D2, $04, $FA, $65, $C6, $FE, $81, $3E, $00, $CA, $DD, $04, $3E, $01, $C3, $DD
	db $04, $21, $00, $5B, $00, $5C, $00, $A7, $28, $41, $CD, $88, $02, $FA, $06, $C7
	db $21, $ED, $04, $E5, $C3, $F5, $05, $F3, $04, $03, $05, $13, $05, $21, $00, $60
	db $11, $21, $00, $CD, $46, $02, $3E, $81, $CD, $4C, $02, $18, $1E, $21, $00, $60
	db $11, $5B, $00, $CD, $46, $02, $3E, $81, $CD, $4C, $02, $18, $0E, $21, $00, $60
	db $11, $5C, $00, $CD, $46, $02, $3E, $81
ASSERT @ == $051E
