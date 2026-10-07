; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $10, address $6D2E-$6D2E.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 10:6D2E-6D2E", ROMX[$6D2E], BANK[$10]
ResidualROM10_6D2E::
	db $2F
ASSERT @ == $6D2F
