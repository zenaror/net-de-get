; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $10, address $6BA4-$6BA7.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 10:6BA4-6BA7", ROMX[$6BA4], BANK[$10]
ResidualROM10_6BA4::
	db $FE, $00, $FF, $2F
ASSERT @ == $6BA8
