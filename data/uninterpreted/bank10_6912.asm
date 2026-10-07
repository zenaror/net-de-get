; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $10, address $6912-$6912.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 10:6912-6912", ROMX[$6912], BANK[$10]
ResidualROM10_6912::
	db $2F
ASSERT @ == $6913
