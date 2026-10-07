; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2D, address $6027-$6042.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2D:6027-6042", ROMX[$6027], BANK[$2D]
ResidualROM2D_6027::
	db $00, $80, $02, $07, $00, $05, $71, $00, $04, $67, $00, $07, $00, $E0, $07, $00
	db $80, $03, $00, $40, $02, $00, $83, $01, $00, $00, $E0, $02
ASSERT @ == $6043
