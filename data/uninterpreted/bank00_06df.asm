; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $06DF-$0721.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:06DF-0721", ROM0[$06DF]
ResidualROM00_06DF::
	db $E5, $0E, $0A, $CD, $46, $20, $7C, $C6, $20, $5F, $7D, $0E, $0A, $CD, $46, $20
	db $7D, $C6, $20, $57, $7C, $C6, $20, $E1, $E5, $72, $23, $22, $73, $23, $E1, $06
	db $02, $0E, $00, $7E, $FE, $10, $20, $08, $79, $A7, $28, $12, $36, $20, $18, $0E
	db $FE, $20, $20, $08, $79, $A7, $20, $06, $36, $10, $18, $02, $0E, $01, $23, $05
	db $20, $E1, $C9
ASSERT @ == $0722
