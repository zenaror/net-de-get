; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $0C5C-$0CA4.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:0C5C-0CA4", ROM0[$0C5C]
ResidualROM00_0C5C::
	db $C9, $C9, $C9, $3E, $0A, $EA, $00, $00, $C9, $AF, $EA, $00, $00, $C9, $3E, $0A
	db $EA, $00, $00, $AF, $EA, $00, $04, $3E, $01, $EA, $00, $08, $CD, $6D, $10, $3E
	db $00, $28, $15, $CD, $8E, $10, $41, $4F, $B7, $3E, $02, $20, $0B, $3E, $01, $CD
	db $3E, $11, $AF, $CD, $3E, $11, $3E, $01, $F5, $F0, $AF, $EA, $00, $04, $F0, $B0
	db $EA, $00, $08, $AF, $EA, $00, $00, $F1, $C9
ASSERT @ == $0CA5
