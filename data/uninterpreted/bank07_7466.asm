; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $7466-$7FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:7466-7FFF", ROMX[$7466], BANK[$07]
ResidualROM07_7466::
	ds $B9A, $00
ASSERT @ == $8000
