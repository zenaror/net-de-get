; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2E, address $4043-$406C.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2E:4043-406C", ROMX[$4043], BANK[$2E]
ResidualROM2E_4043::
	db $80, $02, $40, $01, $00, $03, $80, $05, $00, $03, $40, $07, $00, $03, $E0, $01
	db $83, $05, $40, $01, $00, $03, $40, $01, $00, $01, $40, $01, $00, $03, $7B, $60
	db $8B, $60, $9B, $60, $AB, $60, $BB, $60, $CB, $60
ASSERT @ == $406D
