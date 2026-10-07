; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $64D7-$651E.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:64D7-651E", ROMX[$64D7], BANK[$07]
ResidualROM07_64D7::
	db $7B, $FE, $FF, $30, $2A, $78, $FE, $00, $28, $08, $16, $85, $82, $57, $79, $BA
	db $28, $2F, $78, $16, $96, $82, $57, $79, $BA, $28, $2A, $78, $16, $8A, $82, $57
	db $79, $BA, $38, $21, $78, $16, $9A, $82, $57, $79, $BA, $30, $02, $18, $12, $78
	db $16, $9F, $82, $57, $79, $BA, $38, $0D, $78, $16, $A4, $82, $57, $79, $BA, $30
	db $04, $3E, $01, $18, $02, $3E, $00, $C9
ASSERT @ == $651F
