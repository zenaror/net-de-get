; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $30, address $7913-$7FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 30:7913-7FFF", ROMX[$7913], BANK[$30]
ResidualROM30_7913::
	ds $6ED, $00
ASSERT @ == $8000
