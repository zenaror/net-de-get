; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2E, address $4027-$4040.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2E:4027-4040", ROMX[$4027], BANK[$2E]
ResidualROM2E_4027::
	db $00, $80, $02, $07, $00, $05, $71, $00, $04, $67, $00, $07, $00, $E0, $07, $00
	db $80, $03, $00, $40, $02, $00, $83, $01, $00, $00
ASSERT @ == $4041
