; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $0747-$0798.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:0747-0798", ROM0[$0747]
ResidualROM00_0747::
	db $FE, $09, $28, $03, $D2, $52, $07, $C6, $20, $22, $C9, $3E, $4E, $22, $C9, $E0
	db $45, $A7, $20, $0D, $F0, $41, $E6, $3F, $E0, $41, $F0, $FF, $E6, $0D, $E0, $FF
	db $C9, $F0, $41, $E6, $3F, $F6, $40, $E0, $41, $F0, $FF, $F6, $02, $E0, $FF, $C9
	db $AF, $E0, $0F, $CD, $56, $07, $3E, $C3, $E0, $40, $C9, $F0, $FF, $F5, $E6, $FE
	db $E0, $FF, $F0, $44, $FE, $91, $20, $FA, $F0, $40, $E6, $7F, $E0, $40, $F1, $E0
	db $FF, $C9
ASSERT @ == $0799
